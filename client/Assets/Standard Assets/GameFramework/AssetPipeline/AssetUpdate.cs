using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using LITJson;
using Priority_Queue;
using UnityEngine.Networking;
using UnityEngine.SceneManagement;
using Debug = UnityEngine.Debug;
using Object = UnityEngine.Object;
using System.Text.RegularExpressions;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace AssetPipeline
{
    public class AssetUpdate : MonoBehaviour
    {
        public static AssetUpdate Instance;
        private static bool _isQuit = false;

        public static void CreateInstance()
        {
            if (Instance != null)
            {
                GameDebug.LogError("AssetUpdate.Instance already exist");
                return;
            }

            GameObject go = new GameObject("AssetUpdate");
            Instance = go.AddComponent<AssetUpdate>();
        }

        private const int MAX_RETRYCOUNT = 3;
        private const int MAX_DOWNLOADCOUNT = 5;
        
        private static bool _cleanUpResFlag;

        private Action<string> _logMessageHandler;
        private Action<string> _loadErrorHandler;

        private List<string> _cdnUrls;
        private string _cdnUrlRoot;
        private int _cdnUrlIndex;
        private VersionConfig _localVersionConfig;
        public VersionConfig _versionConfig;
        private DllVersion _dllVersion;
        private ScriptVersion _scriptPatchVersion;
        private ResConfig _packageResConfig;
        private ResConfig _curResConfig;
        private StaticConfig _staticConfig;
        public string _staticConfigData;

        public LuaScript _curScript = null;

        //非WIFI情况下,询问玩家是否更新标记
        //当为true时,代表玩家已确认在非WIFI情况下更新数据了
        private bool _requestUpdateFlag;

        public VersionConfig CurVersionConfig
        {
            get { return _versionConfig; }
        }

        public VersionConfig LocalVersionConfig
        {
            get
            {
                if (_localVersionConfig == null)
                {
                    _localVersionConfig = ReadLocalVersionConfig();
                    if (_localVersionConfig != null)
                    {
                        GameDebug.Log("Local_VersionConfig:\n" + _localVersionConfig.ToString());
                    }
                    else
                    {
                        GameDebug.Log("Local_VersionConfig is null");
                    }
                }
                return _localVersionConfig;
            }
        }

        public ResConfig CurResConfig
        {
            get { return _curResConfig; }
        }
        private MiniResConfig _miniResConfig;

        public MiniResConfig MiniResConfig
        {
            get { return _miniResConfig; }
        }

        void Awake()
        {

        }

        public void DoApplicationQuit()
        {
            _isQuit = true;
            //GameDebug.Log("AssetUpdate OnApplicationQuit");
            //如果玩家直接终止游戏进程是不会触发OnApplicationQuit,
            //所以在资源更新时,玩家杀掉游戏进程,会导致玩家需要重新下载所有更新数据
            Dispose();
        }
        
        #region 资源管理初始化流程
        
        public void Setup(List<string> cdnUrls)
        {
            _cdnUrls = cdnUrls;
            _cdnUrlRoot = cdnUrls[0];
            _fatalError = false;
            _requestUpdateFlag = false;
        }

        public void SetLogHanlder(Action<string> logHandler, Action<string> onError)
        {
            _logMessageHandler = logHandler;
            _loadErrorHandler = onError;
        }

        public void StartLoadPackageGameConfig(Action onFinish)
        {
            StartCoroutine(LoadPackageGameConfig(onFinish));
        }

        public void LoadStaticConfig(bool isTestHttpRoot, Action onFinish, Action<string> onError)
        {
            Action<string> staticJsonProcess = (string json) =>
            {
                string savePath = Path.Combine(GameResPath.persistentDataPath, GameResPath.STATICCONFIG_FILE);
                FileHelper.SaveJsonText(json, savePath, false);

                this._staticConfig = JsonMapper.ToObject<StaticConfig>(json);
                if (this._staticConfig != null)
                {
                    this._staticConfigData = json;

                    GameSetting.SetupServerUrlConfig(this._staticConfig);
                    Setup(GameSetting.PlatformResPathList);
                    onFinish();
                }
                else
                {
                    onError("网络异常，连接服务器失败");
                    GameDebug.Log("加载游戏配置信息失败");
                }
            };

            if (GameLauncher.andriodUpdateInfo != null && GameLauncher.andriodUpdateInfo.cndUrls != null)
            {
                GameDebug.Log("andriod 已经下载过不再重新获取");
                staticJsonProcess(GameLauncher.andriodUpdateInfo.cndUrls);
                return;
            }
            if (isTestHttpRoot)
            {
                if (GameSetting.Channel == "demi")
                {
                    GameSetting.CONFIG_SERVER = string.Format("{0}/{1}/{2}", GameSetting.TestHttpRoot, GameSetting.ResDir, GameSetting.PlatformTypeNameForDemi);
                }
                else
                {
                    GameSetting.CONFIG_SERVER = string.Format("{0}/{1}/{2}", GameSetting.TestHttpRoot, GameSetting.ResDir, GameSetting.PlatformTypeName);
                }
                
            }
            else
            {
                if (GameSetting.Channel == "demi")
                {
                    GameSetting.CONFIG_SERVER = string.Format("{0}/{1}/{2}", GameSetting.HttpRoot, GameSetting.ResDir, GameSetting.PlatformTypeNameForDemi);
                }
                else
                {
                    GameSetting.CONFIG_SERVER = string.Format("{0}/{1}/{2}", GameSetting.HttpRoot, GameSetting.ResDir, GameSetting.PlatformTypeName);
                }
            }
            GameDebug.Log("LoadStaticConfig GameSetting.CONFIG_SERVER:" + GameSetting.CONFIG_SERVER);

            LoadStaticConfig(GameResPath.STATICCONFIG_FILE, json =>
            {
                if (!string.IsNullOrEmpty(json))
                {
                    staticJsonProcess(json);
                }
                else
                {
                    onError("网络异常，连接服务器失败");
                    GameDebug.Log("加载游戏配置信息失败");
                }
            }, onError);
        }
        public void LoadStaticConfig(string configName, Action<string> onLoadFinish, Action<string> onError)
        {
            string url = string.Format("{0}/servers/{1}?ver={2}", GameSetting.CONFIG_SERVER, configName, DateTime.Now.Ticks.ToString());
            GameDebug.Log("LoadStaticConfig url= " + url);
            HttpController.Instance.DownLoad(url, delegate(ByteArray byteArray)
            {
                string json = byteArray.ToUTF8String();
                onLoadFinish(json);
            },
            null,
            delegate(Exception obj)
            {
                onError("网络异常，连接服务器失败");
                GameDebug.Log(string.Format("{0}加载出错，请重试", url));
            }, false, SimpleWWW.ConnectionType.Short_Connect);
        }

        public IEnumerator LoadPackageGameConfig(Action onFinish)
        {
            string srcUrl = Path.Combine(GameResPath.packageResUrlRoot, GameResPath.RESCONFIG_FILE);
            string dstUrl = Path.Combine(GameResPath.persistentDataPath, GameResPath.RESCONFIG_FILE);
            if (FileHelper.IsExist(dstUrl))
            {
                byte[] data = FileHelper.ReadAllBytes(dstUrl);
                _curResConfig = ResConfig.ReadFile(data, true);
            }
            if (_curResConfig == null)
            {
                using (var www = new WWW(srcUrl))
                {
                    yield return www;
                    if (!string.IsNullOrEmpty(www.error))
                    {
                        ThrowFatalException(string.Format("Load url:{0}\nerror:{1}", srcUrl, www.error));
                    }
                    _curResConfig = ResConfig.ReadFile(www.bytes, true);
                    //_curResConfig = FileHelper.ReadJsonBytes<ResConfig>(www.bytes);
                    if (_curResConfig == null)
                    {
                        ThrowFatalException("包内资源配置信息丢失，请重新下载游戏");
                        yield break;
                    }

                    FileHelper.WriteAllBytes(dstUrl, www.bytes);
                }
            }

            dstUrl = Path.Combine(GameResPath.persistentDataPath, GameResPath.SCRIPT_FILE);
            srcUrl = Path.Combine(GameResPath.packageResUrlRoot, GameResPath.SCRIPT_FILE);

            if (!FileHelper.IsExist(dstUrl))
            {
                using (var www = new WWW(srcUrl))
                {
                    yield return www;
                    if (string.IsNullOrEmpty(www.error))
                    {
                        try
                        {
                            FileHelper.WriteAllBytes(dstUrl, www.bytes);
                        }
                        catch (Exception e)
                        {
                            ThrowFatalException("11网络异常，连接服务器失败");
                            GameDebug.Log("Copy Script Error: " + srcUrl + "\n" + e.Message);
                            //ThrowFatalException("Copy Script Error: " + srcUrl + "\n" + e.Message);
                        }
                    }
                    else
                    {
                        ThrowFatalException("22网络异常，连接服务器失败");
                        //ThrowFatalException("Load Script Error: " + www.error);
                    }
                }
            }
            
            onFinish();
        }

        public void StartCheckOutGameRes(Action<bool> onFinish)
        {
            StartCoroutine(CheckOutGameRes(onFinish));
        }

        /// <summary>
        /// 检查包外资源,如果包外缺失resConfig,dllVersion,miniResConfig将从包内拷贝至包外
        /// </summary>
        private IEnumerator CheckOutGameRes(Action<bool> onFinish)
        {
            PrintInfo("验证游戏资源完整性");
            string packageResUrlRoot = GameResPath.packageResUrlRoot;
            string url = null;
            var dllHasChanged = false;

            if ((GameLauncher.andriodUpdateInfo==null) && IsSupportUpdateDllPlatform())
            {
                DllVersion packageDllVersion = null;
                url = Path.Combine(packageResUrlRoot, GameResPath.DLLVERSION_FILE);
                using (var www = new WWW(url))
                {
                    yield return www;

                    if (!string.IsNullOrEmpty(www.error))
                    {
                        ThrowFatalException(string.Format("Load url:{0}\nerror:{1}", url, www.error));
                    }

                    packageDllVersion = JsonMapper.ToObject<DllVersion>(www.text);
                }

                var dllVersionPath = Path.Combine(GameResPath.persistentDataPath, GameResPath.DLLVERSION_FILE);
                if (File.Exists(dllVersionPath))
                {
                    _dllVersion = FileHelper.ReadJsonFile<DllVersion>(dllVersionPath);
                    if (_dllVersion.Version < packageDllVersion.Version)
                    {
                        CleanUpDllFolder();
                        GameDebug.Log("包内的dll比较新，需要清空包外dll");

                        if (onFinish != null)
                        {
                            onFinish(true);
                        }
                        yield break;
                    }

                    dllHasChanged = _dllVersion.Version != packageDllVersion.Version;
                }
                else
                {
                    // 没陪dllversion，但是有dll的低概率事件，也做下清除以防万一
                    CleanUpDllFolder();

                    _dllVersion = packageDllVersion;
                    SaveDllVersion();
                    GameDebug.Log("拷贝包内dllVersion到包外");
                }
            }


            url = Path.Combine(packageResUrlRoot, GameResPath.RESCONFIG_FILE);
            using (var www = new WWW(url))
            {
                yield return www;

                if (!string.IsNullOrEmpty(www.error))
                {
                    ThrowFatalException(string.Format("Load url:{0}\nerror:{1}", url, www.error));
                }

                _packageResConfig = ResConfig.ReadFile(www.bytes, true);
                if (_packageResConfig == null)
                {
                    ThrowFatalException("包内资源配置信息丢失，请重新下载游戏");
                    yield break;
                }
            }

            //尝试加载包外ResConfig
            string configPath = Path.Combine(GameResPath.persistentDataPath, GameResPath.RESCONFIG_FILE);
            if (FileHelper.IsExist(configPath))
            {
                byte[] data = FileHelper.ReadAllBytes(configPath);
                _curResConfig = ResConfig.ReadFile(data, true);
                if (_curResConfig == null)
                {
                    GameDebug.LogError("包外resConfig已损坏,将会重新从包内拷贝出去");
                }
            }

            if (IsNewerPackageRes())
            {
                GameDebug.Log("包内资源更新,清空包外资源,重新拷贝包内resConfig到包外!!!!");
                CleanUpBundleResFolder();
                _curResConfig = _packageResConfig;
                SaveResConfig();

                if (dllHasChanged)
                {
                    CleanUpDllFolder();
                    GameDebug.Log("包内资源更新，dll对应不上，需要清空重启");

                    if (onFinish != null)
                    {
                        onFinish(true);
                    }
                    yield break;
                }
            }

            //如果当前为小包资源,拷贝包内miniResConfig到包外
            //当小包升级为整包时,isMiniRes标志将置为false
            if (_curResConfig.isMiniRes)
            {
                string miniResConfigPath = Path.Combine(GameResPath.persistentDataPath, GameResPath.MINIRESCONFIG_FILE);
                if (FileHelper.IsExist(miniResConfigPath))
                {
                    _miniResConfig = FileHelper.ReadJsonFile<MiniResConfig>(miniResConfigPath, true);
                }
                else
                {
                    url = Path.Combine(packageResUrlRoot, GameResPath.MINIRESCONFIG_FILE);
                    using (var www = new WWW(url))
                    {
                        yield return www;

                        if (!string.IsNullOrEmpty(www.error))
                        {
                            ThrowFatalException(string.Format("Load url:{0}\nerror:{1}", url, www.error));
                        }

                        _miniResConfig = FileHelper.ReadJsonBytes<MiniResConfig>(www.bytes);
                        SaveMiniResConfig();
                        GameDebug.Log("拷贝包内miniResConfig到包外");
                    }
                }
            }

            if (onFinish != null)
                onFinish(false);
        }


        //满足以下其中一个条件,则认为玩家是首次安装游戏,需要清空包外资源目录,需要从包内拷贝resConfig到包外
        //1.首次安装游戏或者用户手动删除了包外的resConfig
        //2.包外版本号低于包内版本号,最为特殊的情况用户没有进入游戏更新的情况下,用新安装包覆盖了旧包,使得包内资源更新
        // 用buildtime来做包的更改的记录
        private bool IsNewerPackageRes()
        {
            return _curResConfig == null || (_packageResConfig.BuildTime != _curResConfig.BuildTime);
        }
        #endregion

        #region 获取VersionConfig信息
        /// <summary>
        /// 根据版本信息类型获取指定的VersionConfig信息
        /// </summary>
        public void FetchVersionConfig(bool isTestVersionConfig, Action onFinish)
        {
            if (isTestVersionConfig)
            {
                StartCoroutine(DownloadVersionConfig(VersionConfig.GetTestFileName(), onFinish));
            }
            else
            {
                StartCoroutine(DownloadVersionConfig(VersionConfig.GetFileName(), onFinish));
            }
        }

        private IEnumerator DownloadVersionConfig(string versionConfigName, Action onFinish)
        {
            PrintInfo("检查游戏版本更新");

            string versionConfigUrl = string.Format("{0}?ver={1}", _cdnUrlRoot + "/" + versionConfigName, DateTime.Now.Ticks);

            yield return StartCoroutine(DownloadByUnityWebRequest(versionConfigUrl, www =>
            {
                _versionConfig = JsonMapper.ToObject<VersionConfig>(www.downloadHandler.text);
                if (_versionConfig == null)
                {
                    ThrowFatalException("网络异常，连接服务器失败");
                    GameDebug.Log("VersionConfig is null");
                    //ThrowFatalException("VersionConfig is null");
                }
                else
                {
                    GameDebug.Log("CDN_VersionConfig:\n" + _versionConfig.ToString());
                }

                // 如果服务器版本不一样，记录下来，这样子下次就不会取到不一样的服务器版本
                //if (IsChangeVersionConfigType())
                //{
                //    SaveLocalVersionConfig();
                //}

                if (onFinish != null)
                    onFinish();
            },
            msg =>
            {
                _cdnUrlIndex += 1;
                //int index = _cdnUrls.IndexOf(_cdnUrlRoot);
                if (_cdnUrlIndex + 1 >= _cdnUrls.Count)
                {
                    // var log = string.Format("游戏资源加载失败，请重试\n{0}", msg);
                    GameDebug.Log(string.Format("游戏资源加载失败，请重试\n{0}", msg));
                    var log = "网络异常，连接服务器失败";
                    if (_loadErrorHandler != null)
                    {
                        _loadErrorHandler(log);
                    }
                    else
                    {
                        PrintInfo(log);
                    }
                    throw new Exception(msg);
                }
                else
                {
                    CdnReportHelper.Report(versionConfigUrl);
                    _cdnUrlRoot = _cdnUrls[_cdnUrlIndex];
                    StartCoroutine(DownloadVersionConfig(versionConfigName, onFinish));
                }
            }));
        }

        /// <summary>
        /// 判断玩家是否变更过游戏服类型
        /// 注:如果变更过游戏服类型,后面只能用 "==" 来判断,而不能用 ">=" ,因为根据游戏服类型拿到不同的VersionConfig有可能出现回退版本的需要
        /// 例如从公测服资源版本号为10升级到Beta服资源版本号为20,然后玩家又切回公测服,这时候就要从20回退到10
        /// </summary>
        /// <returns></returns>
        //private bool IsChangeVersionConfigType()
        //{
        //    return _localVersionConfig == null || (_localVersionConfig.serverType != _versionConfig.serverType);
        //}

        #endregion

        #region Dll更新流程

        /// <summary>
        /// 返回true代表不需要更新Dll
        /// </summary>
        /// <param name="onFinish">Dll更新完毕回调,一般用于提示用户重启游戏</param>
        /// <returns></returns>
        public bool ValidateDllVersion(Action onFinish)
        {
            if (!IsSupportUpdateDllPlatform())

                return true;

            //一般更新流程下,本地版本号大于等于VersionConfig的值都直接跳过
            if (_dllVersion.Version >= _versionConfig.dllVersion)
                return true;

            PrintInfo("获取程序版本信息");
            string dllUrl = string.Format("{0}/{1}/{2}", _cdnUrlRoot, GameResPath.DLL_VERSION_ROOT, DllVersion.GetFileName(_versionConfig.dllVersion));

            StartCoroutine(DownloadByUnityWebRequest(dllUrl, www =>
            {
                var newDllVersion = JsonMapper.ToObject<DllVersion>(www.downloadHandler.text);
                if (newDllVersion == null)
                {
                    GameDebug.Log("DllVersion is null");
                    return;
                }

                //构建dll更新下载队列
                long totalFileSize = 0L;
                var downloadQueue = new Queue<DllInfo>(newDllVersion.Manifest.Count);
                foreach (var pair in newDllVersion.Manifest)
                {
                    DllInfo newDllInfo = pair.Value;
                    DllInfo oldDllInfo;
                    if (_dllVersion.Manifest.TryGetValue(pair.Key, out oldDllInfo))
                    {
                        if (oldDllInfo.MD5 != newDllInfo.MD5 && !File.Exists(GetBackupDllPath(newDllInfo)))
                        {
                            totalFileSize += newDllInfo.size;
                            downloadQueue.Enqueue(newDllInfo);
                            GameDebug.Log("加入dll更新队列 " + newDllInfo.dllName);
                        }
                    }
                    else
                    {
                        totalFileSize += newDllInfo.size;
                        downloadQueue.Enqueue(newDllInfo);
                        GameDebug.Log("加入dll更新队列 " + newDllInfo.dllName);
                    }
                }

                string netType = PlatformAPI.getNetworkType();
                if (netType == PlatformAPI.NET_STATE_WIFI || _requestUpdateFlag)
                {
                    StartCoroutine(UpdateDllFile(newDllVersion, downloadQueue, totalFileSize, onFinish));
                }
                else
                {
                    GameLauncherViewController._instance.ShowUpdateInfo(() => {
                        _requestUpdateFlag = true;
                        StartCoroutine(UpdateDllFile(newDllVersion, downloadQueue, totalFileSize, onFinish));
                    }, FormatBytes(totalFileSize));

//                    BuiltInDialogueViewController.OpenView(string.Format("当前使用非WIFI网络， 有{0}的补丁需要更新， 是否进行更新", FormatBytes(totalFileSize)), () => {
//                      _requestUpdateFlag = true;
//                        StartCoroutine(UpdateDllFile(newDllVersion, downloadQueue, totalFileSize, onFinish));
//                    }, () => {
//                        _loadErrorHandler(null);
//                    }, UIWidget.Pivot.Left, "更新", "退出");
                }
            }, ThrowFatalException));
            return false;
        }

        /// <summary>
        /// 根据最新DllVersion信息更新dll
        /// </summary>
        private IEnumerator UpdateDllFile(DllVersion newDllVersion, Queue<DllInfo> downloadQueue, long totalFileSize, Action onFinish)
        {
            if (ValidateStorageSpace(totalFileSize))
            {
                long remainingSize = totalFileSize;
                int totalCount = downloadQueue.Count;
//                PrintInfo(string.Format("下载Dll中，剩余{0}({1}/{2})", FormatBytes(remainingSize), 0, totalCount));
                string[] sizeList = FormatBytes(remainingSize).Split(' ');
                float totleSize = float.Parse(sizeList[0]);
                string proportion = string.Format("{0}/{1} {2}", totleSize, totleSize, sizeList[1]);
                GameLauncherViewController._instance.ShowUpdateSlider(null, 0, proportion);
                while (downloadQueue.Count > 0)
                {
                    var newDllInfo = downloadQueue.Dequeue();
                    string dllUrl = _cdnUrlRoot + "/" + GameResPath.DLL_FILE_ROOT + "/" + newDllInfo.ToFileName();
                    yield return StartCoroutine(DownloadByUnityWebRequest(dllUrl, www =>
                    {
                        // 备份的依旧使用md5命名，方便校验文件是否已经下载
                        var dllPath = GetBackupDllPath(newDllInfo);
                        try
                        {
                            FileHelper.WriteAllBytes(dllPath, www.downloadHandler.data);
                            remainingSize -= newDllInfo.size;
                            GameDebug.Log(string.Format("写入dll文件:{0}", dllPath));
                        }
                        catch (Exception e)
                        {
                            GameDebug.Log("Save Dll Error: " + dllPath + "\n" + e.Message);
                        }
                    }, ThrowFatalException));

                    yield return null;
//                    PrintInfo(string.Format("下载资源中，剩余{0}({1}/{2})", FormatBytes(remainingSize), totalCount - downloadQueue.Count, totalCount));
                    sizeList = FormatBytes(remainingSize).Split(' ');
                    int progress = Mathf.FloorToInt((1 - float.Parse(sizeList[0])/totleSize) * 100);
                    proportion = string.Format("{0}/{1} {2}", sizeList[0], totleSize, sizeList[1]);
                    GameLauncherViewController._instance.ShowUpdateSlider(null, progress, proportion);
                }

                if (!_fatalError)
                {
                    try
                    {
                        UseNewDllFile(newDllVersion);
                    }
                    catch (Exception e)
                    {
                        ThrowFatalException(e.Message);
                    }
                }

                GameLauncherViewController._instance.ResetTipsObj();
                ClearBackupDllFile();

                //下载完毕,保存最新DllVersion到本地
                PrintInfo("引擎更新完毕,请重启游戏");

                if (onFinish != null)
                    onFinish();
            }
        }


        private void UseNewDllFile(DllVersion newDllVersion)
        {
            // 这里重新计算一遍，防止多拷贝文件
            foreach (var pair in newDllVersion.Manifest)
            {
                var newDllInfo = pair.Value;
                DllInfo oldDllInfo;
                _dllVersion.Manifest.TryGetValue(pair.Key, out oldDllInfo);
                if (oldDllInfo == null || oldDllInfo.MD5 != newDllInfo.MD5)
                {
                    // dll服务器格式是先压缩，再加密
                    // 这里拿到dll得先解密，再解压缩，再加密
                    // 非项目dll不做加密处理
                    var fileBytes = FileHelper.ReadAllBytes(GetBackupDllPath(newDllInfo));
                    var zipBytes = DllHelper.IsProjectDll(newDllInfo.dllName) ? DllHelper.DecryptDll(fileBytes) : fileBytes;
                    var realBytes = ZipLibUtils.Uncompress(zipBytes);
                    var encryptBytes = DllHelper.IsProjectDll(newDllInfo.dllName) ? DllHelper.EncryptDll(realBytes) : realBytes;

                    var dllPath = GameResPath.dllRoot + "/" + newDllInfo.dllName + ".dll";
                    FileHelper.WriteAllBytes(dllPath, encryptBytes);
                }
                //else
                //{
                //    //GameDebug.LogError("Dll更新中不可能出现新增dll,请检查: " + pair.Key);
                //}
            }

            _dllVersion = newDllVersion;
            SaveDllVersion(true);
        }


        private string GetBackupDllPath(DllInfo info)
        {
            return GameResPath.dllBackupRoot + "/" + info.ToFileName();
        }

        /// <summary>
        /// 当保证已经更新完毕，做清空处理
        /// </summary>
        private void ClearBackupDllFile()
        {
            FileHelper.DeleteDirectory(GameResPath.dllBackupRoot, true);
        }


        #endregion

        #region Script更新流程
        public void UpdateScript(Action onFinish, bool checkVersion = true)
        {
            StartCoroutine(UpdateScriptFile(onFinish, checkVersion));
        }

        public IEnumerator FetchScriptVersion()
        {
            if (_scriptPatchVersion == null)
            {
                string url = string.Format("{0}/{1}/{2}?ver={3}", _cdnUrlRoot, GameResPath.SCRIPT_ROOT, ScriptVersion.GetFileName(), DateTime.Now.Ticks.ToString());
                yield return StartCoroutine(DownloadByUnityWebRequest(url, www =>
                {
                    _scriptPatchVersion = JsonMapper.ToObject<ScriptVersion>(www.downloadHandler.text);
                    if (_scriptPatchVersion == null)
                    {
                        GameDebug.Log("Download ScriptVersion Error");
                    }
                }, ThrowFatalException));
            }
        }

        private IEnumerator UpdateScriptFile(Action onFinish, bool checkVersion = true)
        {
            string dstUrl = Path.Combine(GameResPath.persistentDataPath, GameResPath.SCRIPT_FILE);
            string srcUrl = Path.Combine(GameResPath.packageResUrlRoot, GameResPath.SCRIPT_FILE);

            if (!File.Exists(dstUrl))
            {
                GameDebug.Log("包外无script，从包内拷贝");
                using (var www = new WWW(srcUrl))
                {
                    yield return www;
                    if (string.IsNullOrEmpty(www.error))
                    {
                        try
                        {
                            FileHelper.WriteAllBytes(dstUrl, www.bytes);
                        }
                        catch (Exception e)
                        {
                            ThrowFatalException("Copy Script Error: " + srcUrl + "\n" + e.Message);
                        }
                    }
                    else
                    {
                        ThrowFatalException("Load Script Error: " + www.error);
                    }
                }
            }

            try
            {
                _curScript = new LuaScript();
                _curScript.LoadFrom(dstUrl);
            }
            catch
            {
                _curScript = null;
            }
            if (_curScript == null)
            {
                GameDebug.Log(string.Format("加载脚本文件失败"));
                onFinish();
                yield break;
            }

            if (checkVersion) {
                int curScriptVer = _curScript.scriptVersion;
                int newScriptVer = _versionConfig.scriptVersion;

                GameDebug.Log(string.Format("检查脚本版本 curScriptVer={0} newScriptVersion={1}", curScriptVer, newScriptVer));
                PrintInfo("获取补丁信息");

                yield return StartCoroutine(FetchScriptVersion());

            if (newScriptVer > curScriptVer)   //升级补丁
            {
                long totalFileSize = 0L;

                List<int> patchVersionList = _scriptPatchVersion.GetPatchList(curScriptVer, newScriptVer);
                if(patchVersionList == null)
                {
                    ThrowFatalException(string.Format("获取补丁信息失败 {0}->{1}", curScriptVer, newScriptVer));
                }


                var downloadQueue = new Queue<ScriptInfo>();
                for (int i = 1; i < patchVersionList.Count; i++)
                {
                    string patchName = string.Format("patch_{0}_{1}", patchVersionList[i-1], patchVersionList[i]);
                    ScriptInfo patch;
                    if (_scriptPatchVersion.Patchs.TryGetValue(patchName, out patch))
                    {
                        totalFileSize += patch.size;
                        downloadQueue.Enqueue(patch);
                    }
                    else
                    {
                        ThrowFatalException(string.Format("无法获取{0}信息", patchName));
                    }
                }

                    string netType = PlatformAPI.getNetworkType();
                    if (netType == PlatformAPI.NET_STATE_WIFI || _requestUpdateFlag)
                    {
                        StartCoroutine(UpdateScriptFile(newScriptVer, downloadQueue, totalFileSize, onFinish));
                    }
                    else
                    {
                        GameLauncherViewController._instance.ShowUpdateInfo(() => {
                            _requestUpdateFlag = true;
                            StartCoroutine(UpdateScriptFile(newScriptVer, downloadQueue, totalFileSize, onFinish));
                        }, FormatBytes(totalFileSize));
                    }
                }
                else
                {
                    onFinish();
                }
            }
            else
            {
                onFinish();
            }
        }

        private IEnumerator UpdateScriptFile(int newVerson, Queue<ScriptInfo> downloadQueue, long totalFileSize, Action onFinish)
        {
            GameDebug.Log("检查脚本更新  补丁数量 = " + downloadQueue.Count);
            if (ValidateStorageSpace(totalFileSize))
            {
                long remainingSize = totalFileSize;
                int totalCount = downloadQueue.Count;
//              PrintInfo(string.Format("下载补丁中，剩余{0}({1}/{2})", FormatBytes(remainingSize), 0, totalCount));
                string[] sizeList = FormatBytes(remainingSize).Split(' ');
                float totleSize = float.Parse(sizeList[0]);
                string proportion = string.Format("{0}/{1} {2}", totleSize, totleSize, sizeList[1]);
                GameLauncherViewController._instance.ShowUpdateSlider(null, 0, proportion);
                while (downloadQueue.Count > 0)
                {
                    ScriptInfo patchInfo = downloadQueue.Dequeue();
                    string url = string.Format("{0}/{1}/{2}", _cdnUrlRoot, GameResPath.SCRIPT_ROOT, patchInfo.name);
                    yield return StartCoroutine(DownloadByUnityWebRequest(url, www =>
                    {
                        try
                        {
                            string md5 = MD5Hashing.HashBytes(www.downloadHandler.data);
                            if (md5 != patchInfo.md5)
                            {
                                GameDebug.Log(string.Format("{0} MD5 Error! LocalMD5={1} RemoteMD5={2}", patchInfo.name, md5, patchInfo.md5));
                            }

                            LuaScript luaScript = new LuaScript();
                            luaScript.LoadFrom(www.downloadHandler.data);
                            _curScript.MergePatch(luaScript);
                        }
                        catch (Exception e)
                        {
                            GameDebug.Log("Merge Patch Error: " + patchInfo.name + "\n" + e.Message);
                        }
                        remainingSize -= patchInfo.size;

#if UNITY_EDITOR
                        string path = Path.Combine(GameResPath.persistentDataPath, "patch/" + patchInfo.name);
                        FileHelper.WriteAllBytes(path, www.downloadHandler.data);
#endif
                    }, ThrowFatalException));

                    yield return null;
//                    PrintInfo(string.Format("下载补丁中，剩余{0}({1}/{2})", FormatBytes(remainingSize), totalCount - downloadQueue.Count, totalCount));
                    sizeList = FormatBytes(remainingSize).Split(' ');
                    int progress = Mathf.FloorToInt((1 - float.Parse(sizeList[0])/totleSize) * 100);
                    proportion = string.Format("{0}/{1} {2}", sizeList[0], totleSize, sizeList[1]);
                    GameLauncherViewController._instance.ShowUpdateSlider(null, progress, proportion);
                }
                
                GameLauncherViewController._instance.ResetTipsObj();
                
                string scriptName = "script_" + newVerson;
                ScriptInfo scriptInfo = _scriptPatchVersion.Scripts[scriptName];
                string dstUrl = Path.Combine(GameResPath.persistentDataPath, GameResPath.SCRIPT_FILE);
                byte[] data = _curScript.GetEncryptByte();
                string scriptmd5 = MD5Hashing.HashBytes(data);
                //if (scriptmd5 == scriptInfo.md5)
                //{
                FileHelper.WriteAllBytes(dstUrl, data);
                if (onFinish != null)
                {
                    onFinish();
                }
                //}
                //else
                //{
                //    ThrowFatalException(string.Format("{0} MD5 Error! LocalMD5={1} RemoteMD5={2}", scriptName, scriptmd5, scriptInfo.md5));
                //}
            }

            yield return null;
        }

        public void ValidateScript(Action onFinish)
        {
            StartCoroutine(ValidateScriptFile(onFinish));
        }

        public IEnumerator ValidateScriptFile(Action onFinish)
        {
            yield return StartCoroutine(FetchScriptVersion());

            int newScriptVer = _versionConfig.scriptVersion;
            if (_curScript != null && _curScript.scriptVersion > newScriptVer)
            {
                onFinish();
                yield break;
            }

            string dstUrl = Path.Combine(GameResPath.persistentDataPath, GameResPath.SCRIPT_FILE);
            ScriptInfo scriptInfo;
            string scriptName = "script_" + newScriptVer;
            PrintInfo("检查资源文件");
            if (_scriptPatchVersion.Scripts.TryGetValue(scriptName, out scriptInfo))
            {
                string md5 = MD5Hashing.HashFile(dstUrl);
                if (md5 == scriptInfo.md5)
                {
                    onFinish();
                }
                else
                {
                    string url = string.Format("{0}/{1}/{2}", _cdnUrlRoot, GameResPath.SCRIPT_ROOT, scriptName);
                    GameDebug.Log("检测到错误，重新下载脚本文件");
                    yield return StartCoroutine(DownloadByUnityWebRequest(url, www =>
                    {
                        md5 = MD5Hashing.HashBytes(www.downloadHandler.data);
                        if (md5 == scriptInfo.md5)
                        {
                            FileHelper.WriteAllBytes(dstUrl, www.downloadHandler.data);
                            onFinish();
                        }
                        else
                        {
                            GameDebug.Log(string.Format("Download {0} Error! LocalMD5={1} RemoteMD5={2}", scriptInfo.name, md5, scriptInfo.md5));
                        }
                    }, ThrowFatalException));
                }
            }
            else
            {
                ThrowFatalException(string.Format("无法获取{0}信息", scriptName));
            }
        }

        #endregion

        #region GameRes更新流程
        public event Action OnBeginResUpdate;
        public event Action OnFinishResUpdate;

        public void UpdateGameRes(Action onFinish)
        {
            if (_curResConfig.Version >= _versionConfig.resVersion)
            {
                onFinish();
            }
            else
            {
                StartCoroutine(FetchLastestResConfig(onFinish));
            }
        }

        private IEnumerator FetchLastestResConfig(Action onFinish)
        {
            PrintInfo("获取最新游戏资源版本信息");
            string resConfigUrl = _cdnUrlRoot + "/" + GameResPath.RESCONFIG_ROOT + "/" + ResConfig.GetRemoteFile(_versionConfig.resVersion);
            yield return StartCoroutine(DownloadByUnityWebRequest(resConfigUrl, www =>
            {
                var newResConfig = ResConfig.ReadFile(www.downloadHandler.data, true);
                if (newResConfig == null)
                {
                    GameDebug.Log("Fetch resConfig is null");
                    ThrowFatalException("未找到有效的资源下载地址，请保持网络通畅");
                    return;
                }

                //WIFI情况下不做任何提示，直接更新资源
                //手机移动网络下，提示资源更新大小，若强制更新，跳过直接退出游戏
                //小包未完全升级为整包时,必须走游戏更新流程,因为需要把新PatchInfo的信息覆盖到curResConfig,否则玩家进入游戏后下载的就是旧的资源了
                string netType = PlatformAPI.getNetworkType();
                AutoUpgrade = netType == PlatformAPI.NET_STATE_WIFI ? AutoUpgradeType.WIFI : AutoUpgradeType.NONE;
                var patchInfo = GeneratePatchInfo(_curResConfig, newResConfig);
                if (patchInfo != null)
                {
                    UploadDataManager.Instance.patchSize = patchInfo.TotalFileSize;
                    if (netType == PlatformAPI.NET_STATE_WIFI || _curResConfig.isMiniRes || _requestUpdateFlag)
                    {
                        StartDownloadRes(patchInfo, onFinish);
                    }
                    else
                    {
                        GameLauncherViewController._instance.ShowUpdateInfo(() => {
                            _requestUpdateFlag = true;
                            StartDownloadRes(patchInfo, onFinish);
                        }, FormatBytes(patchInfo.TotalFileSize));
                        
//                      BuiltInDialogueViewController.OpenView(string.Format("当前使用非WIFI网络， 有{0}的资源需要更新， 是否进行更新", FormatBytes(patchInfo.TotalFileSize)), () => {
//                            _requestUpdateFlag = true;
//                            StartDownloadRes(patchInfo, onFinish);
//                        }, () => {
//                            _loadErrorHandler(null);
//                        }, UIWidget.Pivot.Left, "更新", "退出");
                    }
                }
                else
                {
                    PrintInfo("PatchInfo为空,没有需要更新的资源");
                    if (onFinish != null)
                        onFinish();
                }
            }, ThrowFatalException));
        }

        /// <summary>
        /// 游戏运行时生成两个版本间的版本更新信息
        /// </summary>
        private ResPatchInfo GeneratePatchInfo(ResConfig oldResConfig, ResConfig newResConfig)
        {
            if (oldResConfig == null || newResConfig == null)
            {
                return null;
            }

            //无需生成当前版本PatchInfo
            if (oldResConfig.Version == newResConfig.Version)
            {
                return null;
            }

            ResPatchInfo patchInfo = new ResPatchInfo
            {
                CurVer = oldResConfig.Version,
                CurSvnVer = oldResConfig.svnVersion,
                CurLz4CRC = oldResConfig.lz4CRC,
                CurLzmaCRC = oldResConfig.lzmaCRC,
                EndVer = newResConfig.Version,
                EndSvnVer = newResConfig.svnVersion,
                EndLz4CRC = newResConfig.lz4CRC,
                EndLzmaCRC = newResConfig.lzmaCRC
            };

            //生成更新列表
            //CRC不为0，且CRC值发生变更的，加入更新列表
            //oldResConfig不存在的，直接加入更新列表
            foreach (var newRes in newResConfig.Manifest)
            {
                if (oldResConfig.Manifest.ContainsKey(newRes.Key))
                {
                    if (oldResConfig.Manifest[newRes.Key].CRC != newRes.Value.CRC)
                    {
                        patchInfo.updateList.Add(newRes.Value);
                        patchInfo.TotalFileSize += newRes.Value.size;
                    }
                }
                else
                {
                    patchInfo.updateList.Add(newRes.Value);
                    patchInfo.TotalFileSize += newRes.Value.size;
                }
            }

            //生成删除列表
            //oldResConfig的key在newResConfig中找不到对应key的，证明该资源已被删除
            foreach (var oldRes in oldResConfig.Manifest)
            {
                if (!newResConfig.Manifest.ContainsKey(oldRes.Key))
                {
                    patchInfo.removeList.Add(oldRes.Key);
                }
            }

            return patchInfo;
        }

        private void StartDownloadRes(ResPatchInfo resPatchInfo, Action onFinish)
        {
            //如果获取的patchInfo版本号与本地resConfig的版本号不一致，直接忽略
            if (resPatchInfo.CurVer == _curResConfig.Version)
            {
                //对比版本号信息，patch最终版本号与本地资源版本号不一致，需要下载更新资源包
                if (resPatchInfo.EndVer != _curResConfig.Version)
                {
                    //  开始下载更新包
                    LogMgr.SendLog(1);
                    string newVer = string.Format("1.{0}.{1}.{2}", GameVersion.frameworkVersion, GameVersion.dllVersion, resPatchInfo.EndVer);
                    LogMgr.UpdateGameStartLog(GameVersion.ResVersion, newVer);
                    RemoveOutdatedAsset(resPatchInfo);

                    StartCoroutine(DownloadAssetBatch(resPatchInfo, onFinish));
                }
                else
                {
                    if (onFinish != null)
                        onFinish();
                }
            }
            else
            {
                GameDebug.LogError("取得的patchInfo与本地resConfig版本号不一致，可能生成patchInfo流程有问题，请检查");
                if (onFinish != null)
                    onFinish();
            }
        }

        private void RemoveOutdatedAsset(ResPatchInfo resPatchInfo)
        {
            if (resPatchInfo.removeList.Count == 0) return;

            string resFileRoot = GameResPath.bundleRoot;
            //根据patchManifest信息删除旧版本冗余资源
            for (int i = 0; i < resPatchInfo.removeList.Count; i++)
            {
                string bundleName = resPatchInfo.removeList[i];
                ResInfo resInfo;
                if (_curResConfig.Manifest.TryGetValue(bundleName, out resInfo))
                {
                    string abFile = resInfo.GetABPath(resFileRoot);
                    if (FileHelper.IsExist(abFile))
                    {
                        File.Delete(abFile);
#if GAMERES_LOG
                    GameDebug.LogError(string.Format("AB Delete:{0}", abFile));
#endif
                    }
                    _curResConfig.Manifest.Remove(bundleName);
                }
            }
        }

        private int _finishedCount;
        private int _downloadingCount;
        private long _remainingSize;
        private IEnumerator DownloadAssetBatch(ResPatchInfo resPatchInfo, Action onFinish)
        {
            PrintInfo("准备游戏资源下载中");

            //验证手机剩余空间大小
            if (ValidateStorageSpace(resPatchInfo.TotalFileSize))
            {
                if (OnBeginResUpdate != null)
                    OnBeginResUpdate();

                var stopwatch = new Stopwatch();
                stopwatch.Start();

                string remoteRoot = GetCDNBundleRoot();
                string bundleRoot = GameResPath.bundleRoot;
                _finishedCount = 0;
                _downloadingCount = 0;
                _remainingSize = resPatchInfo.TotalFileSize;
                var downloadQueue = new Queue<ResInfo>(resPatchInfo.updateList.Count);

                int alreadyUpdateCount = 0;
                //构建资源下载队列，已下载过的资源直接忽略
                for (int i = 0; i < resPatchInfo.updateList.Count; i++)
                {
                    ResInfo newResInfo = resPatchInfo.updateList[i];
                    string newResKey = newResInfo.bundleName;
                    ResInfo oldResInfo;
                    bool needDownload = true;
                    if (_curResConfig.Manifest.TryGetValue(newResKey, out oldResInfo))
                    {
                        //版本号一致，CRC一致，且存在该文件已经更新过了无需重复下载
                        //这种情况只存在于玩家在资源更新的过程中退出游戏了,重新进入游戏后要忽略已更新过的资源
                        if (oldResInfo.CRC == newResInfo.CRC)
                        {
                            var packageResInfo = _packageResConfig.GetResInfo(newResKey);
                            if (packageResInfo != null &&
                                packageResInfo.CRC == newResInfo.CRC)
                            {
                                //包内已有该资源了,就无需更新了
                                //这种情况很特殊,只有玩家不删除旧包的情况下安装了最新包才会这样
                                needDownload = false;
                                ++alreadyUpdateCount;
                                _remainingSize -= newResInfo.size;
                            }
                            else
                            {
                                //包内ResConfig没有该资源,判断包外目录是否存在该文件,有就跳过不下载
                                string filePath = newResInfo.GetABPath(bundleRoot);
                                if (FileHelper.IsExist(filePath))
                                {
                                    needDownload = false;
                                    ++alreadyUpdateCount;
                                    _remainingSize -= newResInfo.size;
                                }
                            }
                        }
                    }

                    //小包模式下跳过miniResConfig记录的资源ID,因为这部分资源可以游戏时动态下载
                    if (_curResConfig.isMiniRes && _miniResConfig.replaceResConfig.ContainsKey(newResKey))
                    {
                        needDownload = false;
                        _remainingSize -= newResInfo.size;
                        //小包未下载的资源,直接用最新版本的ResInfo覆盖,因为游戏运行时要根据这个ResInfo信息动态下载该资源
                        _curResConfig.Manifest[newResKey] = newResInfo;
                    }

                    if (needDownload)
                    {
                        downloadQueue.Enqueue(newResInfo);
                    }
                }

                int totalUpdateCount = downloadQueue.Count;
                GameDebug.Log(string.Format("Begin Download Asset:\n 已更新过的资源数:{0}\n 需要进入游戏前更新资源数:{1}\n 游戏运行时需下载的小包资源数:{2}\n 更新资源总数:{3}\n",
                    alreadyUpdateCount,
                    totalUpdateCount,
                    _miniResConfig != null ? _miniResConfig.replaceResConfig.Count : 0,
                    resPatchInfo.updateList.Count));

                ZipManager.Instance.StarWork();
                
                
                string[] sizeList = FormatBytes(_remainingSize).Split(' ');
                float totleSize = float.Parse(sizeList[0]);
                string proportion = string.Format("{0}/{1} {2}", totleSize, totleSize, sizeList[1]);
                GameLauncherViewController._instance.ShowUpdateSlider(null, 0, proportion);
                //等待资源更新完毕
                while (_finishedCount < totalUpdateCount)
                {
                    while (downloadQueue.Count > 0 && _downloadingCount < MAX_DOWNLOADCOUNT)
                    {
                        var newResInfo = downloadQueue.Dequeue();
                        ++_downloadingCount;
                        StartCoroutine(DownloadAssetTask(remoteRoot, newResInfo));
                    }
                    yield return null;
//                    PrintInfo(string.Format("下载资源中，剩余{0}({1}/{2})", FormatBytes(_remainingSize), _finishedCount, totalUpdateCount));
                    sizeList = FormatBytes(_remainingSize).Split(' ');
                    int progress = Mathf.FloorToInt((1 - float.Parse(sizeList[0])/totleSize) * 100);
                    proportion = string.Format("{0}/{1} {2}", sizeList[0], totleSize, sizeList[1]);
                    GameLauncherViewController._instance.ShowUpdateSlider(null, progress, proportion);
                }
                
                GameLauncherViewController._instance.ResetTipsObj();
                ZipManager.Instance.StopWork();

                string oldGameVersion = GameVersion.ResVersion;

                //更新过程中没有发生错误才将本地ResConfig版本号更新为最新版本
                if (!_fatalError)
                {
                    //  开始解压安装
                    LogMgr.SendLog(2);
                    PrintInfo("下载资源完成，正在加载游戏资源");
                    _curResConfig.Version = resPatchInfo.EndVer;
                    _curResConfig.svnVersion = resPatchInfo.EndSvnVer;
                    _curResConfig.lz4CRC = resPatchInfo.EndLz4CRC;
                    _curResConfig.lzmaCRC = resPatchInfo.EndLzmaCRC;
                }

                //无论更新过程是否出错都需要保存一下ResConfig,否则重走更新流程时又需要重新下载一遍没有出错的资源了
                SaveResConfig(!_fatalError);
                if (_curResConfig.isMiniRes)
                {
                    SaveMiniResConfig();
                }

                ////每次下载完新版本资源，清空Cache缓存，保证Cache的旧资源不会占用磁盘空间
                //GameDebug.Log(string.Format("GameResource:Clean Cache {0}", Caching.CleanCache()));

                stopwatch.Stop();
                var elapsed = stopwatch.Elapsed;
                GameDebug.Log(string.Format("下载更新资源总耗时:{0:00}:{1:00}:{2:00}:{3:00}", elapsed.Hours, elapsed.Minutes, elapsed.Seconds, elapsed.Milliseconds / 10));
                //  安装完成
                LogMgr.SendLog(3);
                LogMgr.UpdateGameEndLog(oldGameVersion, GameVersion.ResVersion, true, resPatchInfo.TotalFileSize);

                if (!_fatalError)
                {
                    if (onFinish != null)
                        onFinish();
                }

                if (OnFinishResUpdate != null)
                    OnFinishResUpdate();
            }
        }

        private IEnumerator DownloadAssetTask(string remoteRoot, ResInfo newResInfo)
        {
            string url = newResInfo.GetRemotePath(remoteRoot);
            string outputDir = GameResPath.bundleRoot;

            yield return StartCoroutine(DownloadByUnityWebRequest(url, www =>
            {
                var fileBytes = www.downloadHandler.data;
                if (!string.IsNullOrEmpty(newResInfo.MD5))
                {
                    var fileMD5 = MD5Hashing.HashBytes(fileBytes);
                    if (fileMD5 != newResInfo.MD5)
                    {
                        OnDownloadAssetError(newResInfo, string.Format("url:{0} MD5值不匹配\n{1}|{2}", www.url, newResInfo.MD5, fileMD5));
                        return;
                    }
                }

                if (newResInfo.remoteZipType == CompressType.CustomZip)
                {
                    string outFolder = Path.GetDirectoryName(outputDir + "/" + newResInfo.bundleName);
                    var ms = new MemoryStream(fileBytes, false);
                    //资源解压更新完成，覆盖resConfig旧资源信息
                    ZipManager.Instance.Extract(url, outFolder, ms,
                        proxy => OnDownloadAssetFinish(newResInfo),
                        e => ThrowFatalException(string.Format("ZipExtract url:{0} error:{1}", url, e.Message)));
                }
                else
                {
                    //下载的是AssetBundle直接保存到指定目录，覆盖resConfig旧资源信息
                    string filePath = newResInfo.GetABPath(outputDir);
                    try
                    {
                        FileHelper.WriteAllBytes(filePath, fileBytes);
                        OnDownloadAssetFinish(newResInfo);
#if UNITY_EDITOR
                        GameDebug.Log(string.Format("Name:{0}\nFinish", filePath));
#endif
                    }
                    catch (Exception e)
                    {
                        ThrowFatalException("Save Asset Error: " + filePath + "\n" + e.Message);
                    }
                }
            }, e => OnDownloadAssetError(newResInfo, e)));
        }

        /// <summary>
        /// 更新资源失败,
        /// </summary>
        private void OnDownloadAssetError(ResInfo newResInfo, string error)
        {
            ++_finishedCount;
            --_downloadingCount;
            _remainingSize -= newResInfo.size;
            ThrowFatalException(error);
        }

        private void OnDownloadAssetFinish(ResInfo newResInfo)
        {
            newResInfo.isPackageRes = false;

            // 删除包内同key不同后缀资源
            ResInfo oldResInfo = null;
            if (_curResConfig.Manifest.TryGetValue(newResInfo.bundleName, out oldResInfo))
            {
                if (!oldResInfo.isPackageRes)
                {
                    var filePath = oldResInfo.GetABPath(GameResPath.bundleRoot);
                    try
                    {
                        FileHelper.DeleteFile(filePath);
                    }
                    catch (Exception e)
                    {
                        GameDebug.LogException(e);
                    }
                }
            }

            _curResConfig.Manifest[newResInfo.bundleName] = newResInfo;
            ++_finishedCount;
            --_downloadingCount;
            _remainingSize -= newResInfo.size;
        }


        private string GetCDNBundleRoot()
        {
            return _cdnUrlRoot + "/" + GameResPath.REMOTE_BUNDLE_ROOT;
        }

        #region 小包资源运行时下载
        private StringBuilder _minResDownloadInfo;

        public event Action OnMinResUpdateBegin;        //小包资源下载开始事件
        public event Action OnMinResUpdateFinish;       //小包资源下载成功事件
        public AutoUpgradeType AutoUpgrade = AutoUpgradeType.WIFI;             //小包自动下载资源开关
        public enum AutoUpgradeType
        {
            NONE,   //禁用小包资源自动下载
            WIFI,   //仅WIFI下自动下载
            ALL     //所有网络下自动下载
        }

        private long _totalMiniResSize;
        private long _remainMiniResSize;
        private Coroutine _upgradeTotalResTask;
        private HashSet<string> _miniResDownloadingSet;   //记录当前正在下载中的小包缺失资源Key

        /// <summary>
        /// 当前升级到整包缺少的资源总大小
        /// </summary>
        public long TotalMiniResSize
        {
            get { return _totalMiniResSize; }
        }

        /// <summary>
        /// 剩余小包资源大小
        /// </summary>
        public long RemainMiniResSize
        {
            get { return _remainMiniResSize; }
        }

        /// <summary>
        /// 标记是否正在升级为整包
        /// </summary>
        public bool IsUpgradeTotalRes
        {
            get { return _upgradeTotalResTask != null; }
        }

        /// <summary>
        /// 初始化小包资源下载信息,计算升级到整包还需下载多少资源
        /// </summary>
        public void SetupMiniResDownloadInfo()
        {
            if (_curResConfig == null || !_curResConfig.isMiniRes)
            {
                return;
            }

            _miniResDownloadingSet = new HashSet<string>();
            foreach (var pair in _miniResConfig.replaceResConfig)
            {
                var resInfo = _curResConfig.GetResInfo(pair.Key);
                if (resInfo != null)
                {
                    _totalMiniResSize += resInfo.size;
                }
                else
                {
                    GameDebug.LogError("当前ResConfig不存在该小包资源信息,请检查: " + pair.Key);
                }
            }

            _remainMiniResSize = _totalMiniResSize;
        }

        public bool StartUpgrade()
        {
            if (_upgradeTotalResTask != null)
                return false;

            _upgradeTotalResTask = StartCoroutine(UpgradeTotalRes());
            return true;
        }

        public bool StopUpgrade()
        {
            if (_upgradeTotalResTask == null)
                return false;

            StopCoroutine(_upgradeTotalResTask);
            _upgradeTotalResTask = null;
            return true;
        }

        /// <summary>
        /// 返回true,代表该资源是小包缺失资源,还没有下载下来
        /// </summary>
        /// <param name="bundleName"></param>
        /// <returns></returns>
        public bool ValidateMiniRes(string bundleName)
        {
            return _miniResConfig != null && _miniResConfig.replaceResConfig.ContainsKey(bundleName);
        }

        /// <summary>
        /// 返回true,代表该资源是小包资源,还没有下载下来,并返回其替代资源Key
        /// </summary>
        /// <param name="bundleName"></param>
        /// <param name="replaceKey"></param>
        /// <returns></returns>
        public bool TryGetReplaceRes(string bundleName, out string replaceKey)
        {
            replaceKey = "";
            return _miniResConfig != null && _miniResConfig.replaceResConfig.TryGetValue(bundleName, out replaceKey);
        }

        private IEnumerator UpgradeTotalRes()
        {
            var downloadQueue = new Queue<string>(_miniResConfig.replaceResConfig.Keys);
            string remoteRoot = GetCDNBundleRoot();

            while (downloadQueue.Count > 0)
            {
                while (downloadQueue.Count > 0 && _miniResDownloadingSet.Count < MAX_DOWNLOADCOUNT)
                {
                    string bundleName = downloadQueue.Dequeue();
                    StartCoroutine(DownloadMiniResTask(remoteRoot, bundleName));
                }
                yield return null;
            }

            while (_miniResConfig.replaceResConfig.Count > 0)
            {
                yield return new WaitForSeconds(0.5f);
            }

            //小包资源下载完毕,清空小包下载协程
            _upgradeTotalResTask = null;
            GameDebug.Log("Finish UpgradeTotalRes");
        }

        private IEnumerator DownloadMiniResTask(string remoteRoot, string bundleName)
        {
            //正在下载该小包资源或者已下载的直接跳过
            if (_miniResDownloadingSet.Contains(bundleName)
                || !_miniResConfig.replaceResConfig.ContainsKey(bundleName))
            {
                yield break;
            }

            var resInfo = _curResConfig.GetResInfo(bundleName);
            if (resInfo != null)
            {
                string url = resInfo.GetRemotePath(remoteRoot);
                _miniResDownloadingSet.Add(bundleName);
                yield return StartCoroutine(DownloadByUnityWebRequest(url,
                    www => SaveMiniRes(bundleName, www),
                    error =>
                    {
                        //下载失败从下载列表中移除
                        _miniResDownloadingSet.Remove(bundleName);
                        GameDebug.LogError("DownloadMinResTask: " + url + " failed");
                    }));
            }
            else
            {
                GameDebug.LogError("当前ResConfig不存在该小包资源信息,请检查: " + bundleName);
            }
        }

        /// <summary>
        /// 小包资源下载完毕后缓存到本地,并将小包信息从miniResConfig中移除
        /// </summary>
        /// <param name="bundleName"></param>
        /// <param name="www"></param>
        private void SaveMiniRes(string bundleName, UnityWebRequest www)
        {
            if (!_miniResConfig.replaceResConfig.ContainsKey(bundleName))
                return;

            var newResInfo = _curResConfig.GetResInfo(bundleName);
            var fileBytes = www.downloadHandler.data;
            if (!string.IsNullOrEmpty(newResInfo.MD5))
            {
                var fileMD5 = MD5Hashing.HashBytes(fileBytes);
                if (fileMD5 != newResInfo.MD5)
                {
                    _miniResDownloadingSet.Remove(bundleName);
                    GameDebug.LogError(string.Format("url:{0} MD5值不匹配\n{1}|{2}", www.url, newResInfo.MD5, fileMD5));
                    return;
                }
            }

            string outputDir = GameResPath.bundleRoot;
            if (newResInfo.remoteZipType == CompressType.CustomZip)
            {
                ZipManager.Instance.StarWork();
                string outFolder = Path.GetDirectoryName(outputDir + "/" + newResInfo.bundleName);
                var ms = new MemoryStream(fileBytes, false);
                ZipManager.Instance.Extract(www.url, outFolder, ms,
                    proxy => OnSaveMiniResFinish(newResInfo),
                    e =>
                    {
                        _miniResDownloadingSet.Remove(newResInfo.bundleName);
                        GameDebug.LogError(string.Format("ZipExtract url:{0}\nerror:{1}", www.url, e.Message));
                    });
            }
            else
            {
                string filePath = newResInfo.GetABPath(GameResPath.bundleRoot);
                try
                {
                    FileHelper.WriteAllBytes(filePath, fileBytes);
                    OnSaveMiniResFinish(newResInfo);
                }
                catch (Exception e)
                {
                    _miniResDownloadingSet.Remove(newResInfo.bundleName);
                    GameDebug.LogError("Save MiniRes Error: " + filePath + "\n" + e.Message);
                }
            }
        }

        /// <summary>
        /// 小包资源下载保存成功后,更新本地miniResConfig和resConfig的信息
        /// </summary>
        /// <param name="newResInfo"></param>
        private void OnSaveMiniResFinish(ResInfo newResInfo)
        {
            //小包资源下载完毕,将包内资源标志置为false,并从小包配置信息中移除
            _miniResConfig.replaceResConfig.Remove(newResInfo.bundleName);
            newResInfo.isPackageRes = false;
#if UNITY_EDITOR
            if (_minResDownloadInfo == null)
                _minResDownloadInfo = new StringBuilder();
            _minResDownloadInfo.AppendLine(newResInfo.bundleName);
            GameDebug.Log(string.Format("=======小包资源下载成功:{0}", newResInfo.bundleName));
#endif

            long remainSize = _remainMiniResSize - newResInfo.size;
            _remainMiniResSize = remainSize > 0 ? remainSize : 0L;
            //每下载5个资源,保存一下配置,防止玩家意外终止游戏进程,丢失下载信息
            if (_miniResConfig.replaceResConfig.Count % 5 == 0)
            {
                //小包资源全部下载完毕,将当前小包标记置为false
                if (_miniResConfig.replaceResConfig.Count == 0)
                {
                    _curResConfig.isMiniRes = false;
                    ZipManager.Instance.StopWork();
                }
                SaveMiniResConfig();
                SaveResConfig();
            }

            if (OnMinResUpdateFinish != null)
                OnMinResUpdateFinish();

            //缓存完毕,从下载队列中移除
            _miniResDownloadingSet.Remove(newResInfo.bundleName);
        }

        public delegate void OnDownloadMiniResFinish();

        /// <summary>
        /// 静默下载小包资源,等下载完毕后再次触发资源加载处理回调
        /// </summary>
        /// <param name="loadRequest"></param>
        public void SlientDownloadMiniRes(AssetLoadRequest loadRequest, OnDownloadMiniResFinish onFinish)
        {
            if (AutoUpgrade == AutoUpgradeType.NONE)
                return;
            if (AutoUpgrade == AutoUpgradeType.WIFI && PlatformAPI.getNetworkType() != PlatformAPI.NET_STATE_WIFI)
                return;
            if (_miniResDownloadingSet.Contains(loadRequest.bundleName))
                return;

            StartCoroutine(SlientDownloadMiniResTask(loadRequest, onFinish));
        }

        private IEnumerator SlientDownloadMiniResTask(AssetLoadRequest loadRequest, OnDownloadMiniResFinish onFinish)
        {
            var newResInfo = _curResConfig.GetResInfo(loadRequest.bundleName);
            if (newResInfo != null)
            {
                if (OnMinResUpdateBegin != null)
                    OnMinResUpdateBegin();

                string remoteRoot = GetCDNBundleRoot();

                //必须先下载该资源,保证不会重复下载该资源,再下载其依赖资源
                StartCoroutine(DownloadMiniResTask(remoteRoot, loadRequest.bundleName));

                if (newResInfo.Dependencies.Count > 0)
                {
                    var allDependencies = _curResConfig.GetAllDependencies(loadRequest.bundleName);
                    for (int i = 0; i < allDependencies.Count; i++)
                    {
                        string refBundleName = allDependencies[i];
                        StartCoroutine(DownloadMiniResTask(remoteRoot, refBundleName));
                    }

                    //等待所有依赖资源下载完毕
                    while (allDependencies.Any(s => _miniResDownloadingSet.Contains(s)))
                    {
                        yield return null;
                    }
                }

                //等待该资源下载完毕
                while (_miniResDownloadingSet.Contains(loadRequest.bundleName))
                {
                    yield return null;
                }

                onFinish();
                //所有相关资源下载完毕,重新触发整包资源加载流程
                //_loadingQueue.Enqueue(loadRequest.bundleName, 0);
                //ProcessLoadQueue();
            }
        }
        #endregion

        #endregion

        #region WWW,UnityWebRequest读取数据接口

        /// <summary>
        /// 通过WWW读取或者下载文件,可用于读取本地文件,也可以下载服务器上的
        /// </summary>
        /// <param name="url"></param>
        /// <param name="onFinish"></param>
        /// <param name="onError"></param>
        /// <param name="maxRetry"></param>
        /// <param name="retryDelay"></param>
        /// <param name="converText">转换为text需要转换文件编码非常耗时，某些操作下不需要</param>
        public void LoadFileByWWW(string url, Action<WWW> onFinish, Action<string> onError = null, int maxRetry = 1, float retryDelay = 0.5f, bool converText = true)
        {
            if (string.IsNullOrEmpty(url))
            {
                if (onError != null)
                    onError("LoadFileByWWW:url is null");
                else
                    GameDebug.LogError("LoadFileByWWW:url is null");
                return;
            }
            StartCoroutine(DownloadByWWW(url, onFinish, onError, maxRetry, retryDelay, converText));
        }

        private IEnumerator DownloadByWWW(string url, Action<WWW> onFinish, Action<string> onError, int maxRetry = MAX_RETRYCOUNT, float retryDelay = 0.5f, bool converText = true)
        {
            int retry = 0;
            while (retry++ < maxRetry)
            {
                using (var www = new WWW(url))
                {
                    yield return www;

                    if (!string.IsNullOrEmpty(www.error))
                    {
                        if (retry >= maxRetry)
                        {
                            string error = string.Format("Load url error:{0}", www.url);
                            if (onError != null)
                                onError(error);
                            else
                                GameDebug.LogError(error);
                        }
                        else
                        {
                            GameDebug.Log(string.Format("Try again Link url : {0} , time : {1}", url, retry));
                            yield return new WaitForSeconds(retryDelay);
                        }
                    }
                    else
                    {
                        //转换为text需要转换文件编码非常耗时，某些操作下不需要
                        if (converText && www.text.StartsWith("<html>"))
                        {
                            string error = string.Format("Load url error:{0}", www.url);
                            if (onError != null)
                                onError(error);
                            else
                                GameDebug.LogError(error);
                        }
                        else
                        {
                            if (onFinish != null)
                                onFinish(www);
                        }

                        break; //跳出重试循环
                    }
                }
            }
        }

        /// <summary>
        /// 一般用于加载一些服务器上的临时资源,如:个人空间的图片,注意:不支持读取jar包内的文件
        /// </summary>
        public void LoadFileByUnityWebRequest(string url, Action<UnityWebRequest> onFinish, Action<string> onError)
        {
            LoadFileByUnityWebRequest(UnityWebRequest.Get(url), onFinish, onError);
        }

        public void LoadFileByUnityWebRequest(UnityWebRequest www, Action<UnityWebRequest> onFinish, Action<string> onError)
        {
            if (www == null || string.IsNullOrEmpty(www.url))
            {
                if (onError != null)
                    onError("LoadFileByWWW:url is null");
                else
                    GameDebug.LogError("LoadFileByWWW:url is null");
                return;
            }

            StartCoroutine(LoadFileByUnityWebRequestTask(www, onFinish, onError));
        }

        private IEnumerator LoadFileByUnityWebRequestTask(UnityWebRequest www, Action<UnityWebRequest> onFinish, Action<string> onError)
        {
            yield return www.Send();

            if (www.isError)
            {
                string error = string.Format("Load url:{0}\nerror:{1}", www.url, www.error);
                if (onError != null)
                    onError(error);
                else
                    GameDebug.LogError(error);
            }
            else
            {
                if (onFinish != null)
                    onFinish(www);
            }
        }

        private IEnumerator DownloadByUnityWebRequest(string url, Action<UnityWebRequest> onFinish, Action<string> onError, int maxRetry = MAX_RETRYCOUNT, float retryDelay = 2.0f)
        {
            GameDebug.Log("DownloadByUnityWebRequest  " + url);
            int retry = 0;
            while (retry++ < maxRetry)
            {
                using (var www = UnityWebRequest.Get(url))
                {
                    yield return www.Send();

                    if (www.isError)
                    {
                        if (retry >= maxRetry)
                        {
                            string error = string.Format("Load url error:{0}", www.url);
                            if (onError != null)
                                onError(error);
                            else
                                GameDebug.LogError(error);
                        }
                        else
                        {
                            GameDebug.Log(string.Format("Try again Link url : {0} , time : {1}", www.url, retry));
                            yield return new WaitForSeconds(retryDelay);
                        }
                    }
                    else
                    {
                        if (www.downloadHandler.text.StartsWith("<html>"))
                        {
                            string error = string.Format("Load url error:{0}", www.url);
                            if (onError != null)
                                onError(error);
                            else
                                GameDebug.LogError(error);
                        }
                        else
                        {
                            if (onFinish != null)
                                onFinish(www);
                        }

                        break; //跳出重试循环
                    }
                }
            }
        }

        #endregion
        
        public void Dispose()
        {
#if UNITY_EDITOR
            if (_minResDownloadInfo != null)
            {
                string logPath = Path.Combine(GameResPath.EXPORT_FOLDER, "minResLog.txt");
                FileHelper.WriteAllText(logPath, _minResDownloadInfo.ToString());
            }
#endif

            if (AssetManager.ResLoadMode != AssetManager.LoadMode.EditorLocal)
            {
                if (_cleanUpResFlag)
                {
                    CleanUpResFolder();
                }
                else
                {
                    SaveResConfig();
                }
            }

            //清空异步加载信息
            //this.StopAllCoroutines();
            //if (_loadingQueue != null)
            //    _loadingQueue.Clear();
            //if (_loadRequestDic != null)
            //    _loadRequestDic.Clear();
            _curResConfig = null;
        }

        #region 清空包外更新资源

        /// <summary>
        ///     设置清空包外游戏资源标记，在退出游戏时做清空处理
        /// </summary>
        public void MarkCleanUpResFlag()
        {
            _cleanUpResFlag = true;
        }

        /// <summary>
        ///     清空persistentDataPath下的所有资源目录，以及Cache目录下的资源
        /// </summary>
        private void CleanUpResFolder()
        {
            _cleanUpResFlag = false;

            CleanUpDllFolder();
            CleanUpBundleResFolder();
        }

        public void CleanUpBundleResFolder()
        {
            try
            {
                //清空包外script
                string scriptPath = Path.Combine(GameResPath.persistentDataPath, GameResPath.SCRIPT_FILE);
                if (File.Exists(scriptPath))
                {
                    File.Delete(scriptPath);
                    GameDebug.Log("GameResource:Remove scriptPath File: " + scriptPath);
                }

                //清空包外data
                string dataPath = Path.Combine(GameResPath.persistentDataPath, GameResPath.DATA_SCRIPT_FILE);
                if (File.Exists(dataPath))
                {
                    File.Delete(dataPath);
                    GameDebug.Log("GameResource:Remove dataPath File: " + dataPath);
                }

                //清空包外VersionConfig
                string verConfigPath = Path.Combine(GameResPath.persistentDataPath, GameResPath.VERSIONCONFIG_FILE);
                if (File.Exists(verConfigPath))
                {
                    File.Delete(verConfigPath);
                    GameDebug.Log("GameResource:Remove VersionConfig File: " + verConfigPath);
                }

                //清空包外ResConfig
                string resConfigPath = Path.Combine(GameResPath.persistentDataPath, GameResPath.RESCONFIG_FILE);
                if (File.Exists(resConfigPath))
                {
                    File.Delete(resConfigPath);
                    GameDebug.Log("GameResource:Remove ResConfig File: " + resConfigPath);
                }

                //清空包外miniResConfig
                string miniResConfigPath = Path.Combine(GameResPath.persistentDataPath, GameResPath.MINIRESCONFIG_FILE);
                if (FileHelper.IsExist(miniResConfigPath))
                {
                    File.Delete(miniResConfigPath);
                    GameDebug.Log("GameResource:Remove MiniResConfig File: " + miniResConfigPath);
                }

                //清空包外资源Bundle目录
                string gameResDir = GameResPath.bundleRoot;
                if (Directory.Exists(gameResDir))
                {
                    Directory.Delete(gameResDir, true);
                    GameDebug.Log("GameResource:Remove GameRes Folder: " + gameResDir);
                }

                GameDebug.Log("GameResource:Clean Cache " + Caching.CleanCache());
            }
            catch (Exception e)
            {
                GameDebug.LogError(e.Message);
            }
        }


        public void CleanUpDllFolder()
        {
            if (GameLauncher.andriodUpdateInfo != null)
            {
                return;
            }
            try
            {

                //清空包外dllVersion
                string dllVersionPath = Path.Combine(GameResPath.persistentDataPath, GameResPath.DLLVERSION_FILE);
                if (FileHelper.IsExist(dllVersionPath))
                {
                    File.Delete(dllVersionPath);
                    GameDebug.Log("GameResource:Remove DllVersion File: " + dllVersionPath);
                }

                //清空包外备份dll更新目录
                var dllBackupRootDir = GameResPath.dllBackupRoot;
                if (Directory.Exists(dllBackupRootDir))
                {
                    Directory.Delete(dllBackupRootDir, true);
                    GameDebug.Log("GameResource:Remove DllBackupRoot Folder: " + dllBackupRootDir);
                }

                //清空包外dll更新目录
                string dllRootDir = GameResPath.dllRoot;
                if (Directory.Exists(dllRootDir))
                {
                    Directory.Delete(dllRootDir, true);
                    GameDebug.Log("GameResource:Remove DllRoot Folder: " + dllRootDir);
                }
            }
            catch (Exception e)
            {
                GameDebug.LogError(e.Message);
            }
        }
        #endregion

        #region Helper Func

        ///// <summary>
        ///// 判断是否使用包内资源
        ///// </summary>
        ///// <param name="bundleName"></param>
        ///// <returns></returns>
        //private bool UsePackageRes(string bundleName)
        //{
        //    if (_packageResConfig == null || _curResConfig == null)
        //        return false;

        //    var packageResInfo = _packageResConfig.GetResInfo(bundleName);
        //    if (packageResInfo != null)
        //    {
        //        var curResInfo = _curResConfig.GetResInfo(bundleName);
        //        //这种情况是玩家安装了最新版本的游戏包,且没有发生过资源版本更新.
        //        if (packageResInfo.CRC == curResInfo.CRC)
        //        {
        //            return curResInfo.isPackageRes;
        //        }
        //        else
        //        {
        //            if (_curResConfig.Version > _packageResConfig.Version)
        //            {
        //                //这种情况下是玩家安装了旧版本游戏包,并且通过版本更新升级到最新版本
        //                //所以包外资源打包时间比包内的新
        //                return false;
        //            }
        //            else
        //            {
        //                //这种情况最为特殊,即包内资源比包外新,只会发生在玩家安装了旧版本游戏包,进入过游戏,然后AFK了一段时间,
        //                //期间发生过版本更新,然后玩家没有通过进入游戏走游戏内的版本更新流程,而是直接安装了最新版本游戏包,进行覆盖安装时就会出现这种情况
        //                return true;
        //            }
        //        }
        //    }

        //    return false;
        //}

        private void SaveResConfig(bool saveServerType = false)
        {
            if (_curResConfig == null)
                return;

            string savePath = Path.Combine(GameResPath.persistentDataPath, GameResPath.RESCONFIG_FILE);
            _curResConfig.SaveFile(savePath, true);
        }

        private void SaveDllVersion(bool saveServerType = false)
        {
            if (_dllVersion == null)
                return;

            string savePath = Path.Combine(GameResPath.persistentDataPath, GameResPath.DLLVERSION_FILE);
            FileHelper.SaveJsonObj(_dllVersion, savePath);
        }

        private void SaveMiniResConfig()
        {
            if (_miniResConfig == null)
                return;
            string savePath = Path.Combine(GameResPath.persistentDataPath, GameResPath.MINIRESCONFIG_FILE);
            FileHelper.SaveJsonObj(_miniResConfig, savePath, true);
        }

        public void SaveVersionConfig()
        {
            if (_versionConfig == null)
                return;

            string savePath = Path.Combine(GameResPath.persistentDataPath, GameResPath.VERSIONCONFIG_FILE);
            FileHelper.SaveJsonObj(_versionConfig, savePath);
        }
        
        /// <summary>
        /// 读取本地最近一次缓存的StaticConfig信息
        /// </summary>
        /// <returns></returns>
        public StaticConfig ReadLocalStaticConfig()
        {
            string savePath = Path.Combine(GameResPath.persistentDataPath, GameResPath.STATICCONFIG_FILE);
            if (FileHelper.IsExist(savePath))
            {
                var config = FileHelper.ReadJsonFile<StaticConfig>(savePath);
                return config;
            }
            return null;
        }
        
        /// <summary>
        /// 读取本地最近一次缓存的VersionConfig信息
        /// </summary>
        /// <returns></returns>
        private VersionConfig ReadLocalVersionConfig()
        {
            string savePath = Path.Combine(GameResPath.persistentDataPath, GameResPath.VERSIONCONFIG_FILE);
            if (FileHelper.IsExist(savePath))
            {
                return FileHelper.ReadJsonFile<VersionConfig>(savePath);
            }
            return null;
        }

        /// <summary>
        /// 判断当前运行时平台是否支持更新Dll
        /// </summary>
        /// <returns></returns>
        public static bool IsSupportUpdateDllPlatform()
        {
            var runtimePlatform = Application.platform;
            return runtimePlatform == RuntimePlatform.Android || runtimePlatform == RuntimePlatform.WindowsPlayer;
        }

        private bool ValidateStorageSpace(long needSize)
        {
            if (Application.isMobilePlatform)
            {
                long freeSpace = PlatformAPI.getExternalStorageAvailable() * 1024L;
                if (freeSpace < needSize)
                {
                    if (_loadErrorHandler != null)
                    {
                        _loadErrorHandler(string.Format("当前剩余手机空间不足，需要{0}，请清理手机空间再尝试。", FormatBytes(needSize - freeSpace)));
                    }
                    return false;
                }
            }

            return true;
        }

        #endregion

        #region Debug Func

        private bool _fatalError;

        private void ThrowFatalException(string msg)
        {
            _fatalError = true;
            if (_loadErrorHandler != null)
            {
                _loadErrorHandler(msg);
            }
            else
            {
                PrintInfo(msg);
            }
            throw new Exception(msg);
        }

        private void PrintInfo(string msg)
        {
            GameDebug.Log(msg);
            if (_logMessageHandler != null)
                _logMessageHandler(msg);
        }

        public static void LogMemory()
        {
            if (Application.isMobilePlatform)
            {
                long freeMemory = PlatformAPI.getFreeMemory() / 1024;
                long totalMemory = PlatformAPI.getTotalMemory() / 1024;
                GameDebug.Log("memory " + freeMemory + "/" + totalMemory);
            }
        }

        public static string FormatBytes(long bytes)
        {
            string[] sizes = { "B", "KB", "MB", "GB" };
            int order = 0;
            double len = bytes;
            while (len >= 1024 && order + 1 < sizes.Length)
            {
                order++;
                len = len / 1024;
            }

//          if (sizes [order] == "MB")
//          {
//              len *= 0.38f;
//          }

            // Adjust the format string to your preferences. For example "{0:0.#}{1}" would
            // show a single decimal place, and no space.
            return string.Format("{0:0.##} {1}", len, sizes[order]);
        }

        #endregion
    }
}
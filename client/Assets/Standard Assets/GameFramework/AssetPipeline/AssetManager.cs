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
using System.Text.RegularExpressions;
using System.Threading;

using Debug = UnityEngine.Debug;
using Object = UnityEngine.Object;


#if UNITY_EDITOR
using UnityEditor;
#endif


namespace AssetPipeline
{
    public delegate void OnLoadFinish(Object asset);

    public delegate void OnLoadError();

    /// <summary>
    /// disposed标记了该资源加载回调处理是否无效了
    /// 如果异步加载时间过长,相应的Controller已经销毁了,销毁前记得把diposed置为true
    /// </summary>
    public class AssetHandler
    {
        public bool disposed { get; private set; } //用于标记资源加载回调是否已丢弃
        public readonly string assetName;
        public readonly string assetPath;
        public readonly Type type;
        private OnLoadError onError;
        private OnLoadFinish onFinish;

        public AssetHandler(string assetPath, string assetName, Type type, OnLoadFinish onFinish, OnLoadError onError)
        {
            this.assetPath = assetPath;
            this.assetName = assetName;
            this.type = type;
            this.onFinish = onFinish;
            this.onError = onError;
        }

        public void Excute(Object asset)
        {
            if (disposed) return;

            if (onFinish != null)
            {
                onFinish(asset);
            }
        }

        public void OnError()
        {
            if (disposed) return;

            if (onError != null)
            {
                onError();
            }
        }

        public void Dispose()
        {
            disposed = true;
            onFinish = null;
            onError = null;
        }

        public override string ToString()
        {
            return "Target: " + (this.onFinish == null ? "Null" : this.onFinish.Target.ToString())
                + ",Method: " + (this.onFinish == null ? "Null" : this.onFinish.Method.ToString());
        }
    }

    /// <summary>
    /// 资源加载请求实体,封装了每个Bundle的异步加载请求
    /// 在请求未处理之前,业务层请求加载相同的Bundle时只会增加AssetHandler
    /// </summary>
    public class AssetLoadRequest
    {
        public readonly string bundleName;
        internal readonly List<AssetHandler> Handlers;

        public AssetLoadRequest(string bundleName)
        {
            this.bundleName = bundleName;
            Handlers = new List<AssetHandler>();
        }

        public bool isValid
        {
            get { return Handlers.Count > 0 && Handlers.Any(t => !t.disposed); }
        }

        public AssetHandler AddHandler(string path, string assetName, Type type, OnLoadFinish onFinish, OnLoadError onError)
        {
            var handler = new AssetHandler(path, assetName, type, onFinish, onError);
            Handlers.Add(handler);
            return handler;
        }

        public bool RemoveHandler(AssetHandler handler)
        {
            return Handlers.Remove(handler);
        }
    }

    public class AssetNameInfo
    {
        public static Dictionary<string, AssetNameInfo> assetNameInfoDict = new Dictionary<string, AssetNameInfo>();

        public ResGroup resGroup;
        public string bundleName;
        public string assetName;

        public static AssetNameInfo ParseAssetPath(string assetPath)
        {
            if (assetNameInfoDict.ContainsKey(assetPath))
            {
                return assetNameInfoDict[assetPath];
            }

            int index = assetPath.IndexOf("/");
            if (index > 0)
            {
                string resGroupName = assetPath.Substring(0, index);
                string assetName = assetPath.Substring(index + 1);
                string bundleName = string.Format("{0}/{1}", resGroupName.ToLower(), Path.GetFileNameWithoutExtension(assetPath.Substring(index + 1)).ToLower());
				if (AssetManager.ResLoadMode == AssetManager.LoadMode.Assetbundle) {
					if (bundleName.Contains ("_mask")) {
						index = bundleName.IndexOf("_");
						bundleName = bundleName.Substring(0, index) + "_mat";
					}else if(assetPath.Contains(".ani") && !assetPath.Contains("Base")){
                        index = assetPath.IndexOf("/Anim");
                        string modelName = assetPath.Substring(0, index);
                        index = modelName.LastIndexOf("/");
                        modelName = modelName.Substring(index + 1);
                        bundleName = bundleName + modelName + "_ani";
                    }
				}
                AssetNameInfo assetNameInfo = new AssetNameInfo
                {
                    resGroup = (ResGroup)Enum.Parse(typeof(ResGroup), resGroupName, true),
                    assetName = assetName,
                    bundleName = bundleName,
                };
                assetNameInfoDict[assetPath] = assetNameInfo;
                return assetNameInfo;
            }
            else
            {
                return new AssetNameInfo();
            }
        }
    }

    public static class AssetType
    {
        public static Type GetAssetType(string assetName)
        {
            if(AssetType.IsPrefabFile(assetName))
            {
                return typeof(GameObject);
            }
            else if(AssetType.IsTextureFile(assetName))
            {
                return typeof(Texture);
            }
            else if(AssetType.IsAudioFile(assetName))
            {
                return typeof(AudioClip);
            }
            else if(AssetType.IsTextFile(assetName))
            {
                return typeof(TextAsset);
            }
            return typeof(UnityEngine.Object);
        }

        public static bool IsPrefabFile(string path)
        {
            return path.EndsWith(".prefab", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsTextFile(string path)
        {
            return path.EndsWith(".bytes", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".json", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".txt", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsAudioFile(string path)
        {
            return path.EndsWith(".ogg", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".mp3", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".wav", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsTextureFile(string path)
        {
            return path.EndsWith(".png", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".tga", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsShaderFile(string path)
        {
            return path.EndsWith(".shader", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsAnimFile(string path)
        {
            return path.EndsWith(".anim", StringComparison.OrdinalIgnoreCase);
        }
    }


    public class AssetManager : MonoBehaviour
    {
        public enum LoadMode
        {
            EditorLocal,
            Assetbundle,
        }
        private UnloadBundleManager _unloadBundleManager;

        public static AssetManager Instance;

        public static void CreateInstance()
        {
            if (Instance != null)
            {
                GameDebug.LogError("AssetManager.Instance already exist");
                return;
            }

            GameObject go = new GameObject("AssetManager");
            Instance = go.AddComponent<AssetManager>();

            Instance._unloadBundleManager = new UnloadBundleManager(Instance);
        }

        public static float EditorLoadDelay = 0f;         //编辑器下模拟资源加载延迟
#if UNITY_EDITOR
        public static LoadMode ResLoadMode = (LoadMode)EditorPrefs.GetInt("ResLoadMode", 0);
#else
        public static LoadMode ResLoadMode = LoadMode.Assetbundle;
#endif

        //记录已加载的所有Bundle内的Shader信息
        public Dictionary<string, Shader> shaderInfoDic
        {
            private set;
            get;
        }

        //记录已加载AssetBundle信息
        public Dictionary<string, AssetBundleInfo> abInfoDic
        {
            private set;
            get;
        }

        private List<string> tempList = new List<string>();

        public ResConfig curResConfig
        {
            get
            {
                return AssetUpdate.Instance.CurResConfig;
            }
        }

        public static bool UseAssetBundle
        {
            get
            {
#if UNITY_EDITOR
                if (ResLoadMode == LoadMode.EditorLocal)
                {
                    return false;
                }
                else
                {
                    return true;
                }
#else
            return true;
#endif
            }
        }

        private AssetBundleInfo GetAssetBundleInfo(string bundleName)
        {
            if (!abInfoDic.ContainsKey(bundleName))
            {
                AssetBundleInfo assetBundleInfo = new AssetBundleInfo(bundleName, null);
                abInfoDic.Add(bundleName, assetBundleInfo);
            }
            return abInfoDic[bundleName];
        }

        public void LoadCommonAsset(Action onFinish)
        {
            StartCoroutine(PreloadCommonAsset(onFinish));
        }

        private IEnumerator PreloadCommonAsset(Action onFinish)
        {
            abInfoDic = new Dictionary<string, AssetBundleInfo>(curResConfig.Manifest.Count);
            foreach (var resInfo in curResConfig.Manifest.Values)
            {
                if (!resInfo.preload)
                    continue;

                AssetBundleInfo commonBundleInfo = GetAssetBundleInfo(resInfo.bundleName);
                commonBundleInfo.AddRef("preload");

                var request = AssetBundle.LoadFromFileAsync(resInfo.loadPath, 0, resInfo.bundleOffset);
                yield return request;

                var assetBundle = request.assetBundle;
                if (assetBundle != null)
                {
                    commonBundleInfo.Load(assetBundle);
                    if (resInfo.bundleName == GameResPath.AllShaderBundleName)
                    {
                        var shaders = assetBundle.LoadAllAssets<Shader>();
                        if (shaders != null)
                        {
                            shaderInfoDic = new Dictionary<string, Shader>(shaders.Length);
                            for (int i = 0; i < shaders.Length; i++)
                            {
                                Shader shader = shaders[i];
                                if (shader != null)
                                {
                                    shaderInfoDic.Add(shader.name, shader);
                                }
                            }
                        }
                        //耗时屏蔽
                        //Shader.WarmupAllShaders();
                    }
                    //依赖的bundle无需LoadAllAssetsAsync，暂屏蔽
                    //else
                    //{
                    //    yield return commonBundleInfo.assetBundle.LoadAllAssetsAsync();
                    //}
                }
                else
                {
                    GameDebug.LogError("加载AssetBundle失败: " + resInfo.bundleName);
                }
            }

            AssetUpdate.Instance.SetupMiniResDownloadInfo();
            //更新流程结束,记录一下本次更新的VersionConfig信息
            AssetUpdate.Instance.SaveVersionConfig();

            //AssetUpdate.Instance. PrintInfo("加载游戏");
            yield return null;
            if (onFinish != null)
                onFinish();
        }

        public Shader FindShader(string shaderName)
        {
            Shader shader = null;
            if (shaderInfoDic != null)
            {
                shaderInfoDic.TryGetValue(shaderName, out shader);
            }

            return shader ?? Shader.Find(shaderName);
        }

        public static string GetBundleName(string assetPath, ResGroup resGroup)
        {
            AssetNameInfo assetNameInfo = AssetNameInfo.ParseAssetPath(assetPath);
            return assetNameInfo.bundleName;
        }

        //public bool ContainBundleName(string assetName, ResGroup resGroup)
        //{
        //    return ContainBundleName(GetBundleName(assetName, resGroup));
        //}

        ///// <summary>
        ///// 检查是否存在指定BundleName
        ///// </summary>
        ///// <param name="bundleName"></param>
        ///// <returns></returns>
        //public bool ContainBundleName(string bundleName)
        //{
        //    //编辑器本地模式下直接跳过判断
        //    if (ResLoadMode == LoadMode.EditorLocal)
        //        return true;

        //    if (_curResConfig == null)
        //        return false;

        //    if (_curResConfig.Manifest.ContainsKey(bundleName))
        //        return true;

        //    return false;
        //}

        #region 同步加载Bundle资源接口


        //public T LoadAsset<T>(string assetPath) where T : UnityEngine.Object
        //{
        //    var asset = LoadAsset(assetPath, typeof(T)) as T;
        //    return asset;
        //}

        /// <summary>
        /// 一般业务层只需要使用资源名和资源分组类型来加载资源,因为一般来说都是一个资源对应一个Bundle的
        /// </summary>

        public Object LoadAsset(string assetPath, Type type = null)
        {
            if (type == null)
            {
                type = AssetType.GetAssetType(assetPath);
            }
            if (UseAssetBundle)
            {
                return LoadAssetBundleImmediate(assetPath, type);
            }
            else
            {
                return LoadAssetFromProject(assetPath, type);
            }
        }

        /// <summary>
        ///     同步方式加载资源,直接加载工程内的资源,无需处理依赖资源加载
        /// </summary>
        private Object LoadAssetFromProject(string assetPath, Type type)
        {
#if UNITY_EDITOR
            string path = "Assets/GameRes/" + assetPath;
            Object asset = AssetDatabase.LoadAssetAtPath(path, type);
            if (asset == null)
            {
                GameDebug.LogError(string.Format("Load Asset is null, assetPath = {0}", path));
            }
            return asset;
#else
            return null;
#endif
        }


        /// <summary>
        ///     同步方式加载AssetBundle
        /// </summary>
        private Object LoadAssetBundleImmediate(string assetPath, Type type)
        {
            AssetNameInfo assetNameInfo = AssetNameInfo.ParseAssetPath(assetPath);
            return LoadAssetBundleImmediate(assetNameInfo.bundleName, assetNameInfo.assetName, type);
        }

        /// <summary>
        ///     同步方式加载AssetBundle
        /// </summary>
        private Object LoadAssetBundleImmediate(string bundleName, string assetName, Type type)
        {
            if (curResConfig == null)
                return null;

            var resInfo = curResConfig.GetResInfo(bundleName);
            if (resInfo == null)
            {
                GameDebug.LogError(string.Format("加载失败，没有<{0}>资源的信息", bundleName));
                return null;
            }

            AssetBundleInfo abInfo = GetAssetBundleInfo(bundleName);
            Object asset = null;
            if (abInfo.assetBundle != null)
            {
                asset = abInfo.LoadAsset(assetName, type);
            }
            else
            {
                if (resInfo.Dependencies.Count > 0)
                {
                    var allDependencies = curResConfig.GetAllDependencies(bundleName);
                    for (int i = 0; i < allDependencies.Count; i++)
                    {
                        string refBundleName = allDependencies[i];
                        AssetBundleInfo refAbInfo = GetAssetBundleInfo(refBundleName);
                        if (refAbInfo.assetBundle == null)
                        {
                            var refResInfo = curResConfig.GetResInfo(refBundleName);
                            if (refResInfo != null)
                            {
                                AssetBundle refAb = AssetBundle.LoadFromFile(refResInfo.loadPath, 0, refResInfo.bundleOffset);
                                if (refAb == null)
                                {
                                    GameDebug.LogError(string.Format("Load <{0}> AssetBundle is null", bundleName));
                                }
                                refAbInfo.Load(refAb);
                            }
                            else
                            {
                                GameDebug.LogError("refResInfo is null: " + refBundleName);
                            }
                        }
                    }
                }

                var ab = AssetBundle.LoadFromFile(resInfo.loadPath, 0, resInfo.bundleOffset);
                if (ab == null)
                {
                    GameDebug.LogError(string.Format("Load <{0}> AssetBundle is null", bundleName));
                }
                abInfo.Load(ab);
                asset = abInfo.LoadAsset(assetName, type);
            }
            return asset;
        }

        #endregion


        #region 异步加载Bundle资源接口


        public AssetHandler LoadAssetAsync(string path, OnLoadFinish onFinish, OnLoadError onError = null, Type type = null, float priority = 100f)
        {
			AssetNameInfo assetNameInfo = AssetNameInfo.ParseAssetPath(path);
			if (ResLoadMode == LoadMode.Assetbundle)
			{
				if (path.Contains ("_mask.mat"))
				{
					int index = path.IndexOf("_");
					if (index > 0)
					{
						path = path.Substring(0, index) + ".mat";
					}
				}
			}
			return LoadAssetAsync(path, assetNameInfo.bundleName, assetNameInfo.assetName, onFinish, onError, type, priority);
        }

        public AssetHandler LoadAssetAsync(string path, string bundleName, string assetName, OnLoadFinish onFinish, OnLoadError onError = null, Type type = null, float priority = 100f)
        {
            if (type == null)
            {
                type = AssetType.GetAssetType(assetName);
            }

            if (_loadingQueue == null)
                _loadingQueue = new SimplePriorityQueue<string>();

            if (_loadRequestDic == null)
                _loadRequestDic = new Dictionary<string, AssetLoadRequest>(32);

            return CreateLoadAssetRequest(path, bundleName, assetName, type, onFinish, onError, priority);
        }

		public void CleanLoadQueue()
		{
			SimplePriorityQueue<string> tmpQueue = new SimplePriorityQueue<string> ();
			while (_loadingQueue.Count > 0)
			{
				string bundleName = _loadingQueue.Dequeue();
				if (bundleName.Contains("ui/")){
					tmpQueue.Enqueue(bundleName, 100f);
				} else {
					AssetLoadRequest loadRequest;
					if (_loadRequestDic.TryGetValue(bundleName, out loadRequest))
					{

						for (int i = 0; i < loadRequest.Handlers.Count; i++)
						{
							AssetHandler handler = loadRequest.Handlers[i];
							handler.Excute(null);
						}
					}
				}
			}
			_loadingQueue.Clear ();
			_loadingQueue = tmpQueue;
		}

        //异步加载请求Key优先级队列
        private SimplePriorityQueue<string> _loadingQueue;
        //异步加载请求信息字典
        private Dictionary<string, AssetLoadRequest> _loadRequestDic;

        /// <summary>
        /// 创建Bundle异步加载请求,如果已存在于加载队列中时,只添加回调处理方法
        /// 返回AssetHandler供业务层控制其diposed状态
        /// </summary>
        private AssetHandler CreateLoadAssetRequest(string assetPath, string bundleName, string assetName, Type type, OnLoadFinish onFinish, OnLoadError onError, float priority)
        {
            AssetHandler handler;
            AssetLoadRequest loadRequest;
            bool isMiniRes = AssetUpdate.Instance.ValidateMiniRes(bundleName);
            if (_loadRequestDic.TryGetValue(bundleName, out loadRequest))
            {
                handler = loadRequest.AddHandler(assetPath, assetName, type, onFinish, onError);
            }
            else
            {
                loadRequest = new AssetLoadRequest(bundleName);
                handler = loadRequest.AddHandler(assetPath, assetName, type, onFinish, onError);
                _loadRequestDic.Add(bundleName, loadRequest);
                //非缺失资源,直接加入加载队列
                if (!isMiniRes)
                    _loadingQueue.Enqueue(bundleName, priority);
            }

            if (isMiniRes)
            {
                //这个小包资源的loadRequest会一直保留下来
                //小包资源下载期间,如果又触发了相同的资源加载请求,只会增加其Handler,等待下载完毕重新触发资源加载流程才会移除
                //如果玩家关闭了小包资源下载开关,这个loadRequest会一直保留下来
                AssetUpdate.Instance.SlientDownloadMiniRes(loadRequest, () =>
                {
                    _loadingQueue.Enqueue(loadRequest.bundleName, 0);
                    ProcessLoadQueue();
                });
            }

            ProcessLoadQueue();
            return handler;
        }

        /// <summary>
        /// 最大同时处理加载资源请求数
        /// </summary>
        private int _maxProcessCount = 8;
        private bool processingActive; //标记资源加载协程是否启动
        private HashSet<AssetLoadRequest> _processingRequests; //记录当前正在加载中的请求列表
        private Dictionary<string, AssetBundleCreateRequest> _createBundleRequestDic; //记录当前异步加载AssetBundle创建请求信息

        private void ProcessLoadQueue()
        {
            //检验是否需要启动处理资源加载请求协程
            if (processingActive || _loadingQueue.Count <= 0) 
                return;

            this.processingActive = true;
            StartCoroutine(ProcessLoadQueueCoroutine());
        }

        private IEnumerator ProcessLoadQueueCoroutine()
        {
            if (_processingRequests == null)
                _processingRequests = new HashSet<AssetLoadRequest>();

            if (_createBundleRequestDic == null)
                _createBundleRequestDic = new Dictionary<string, AssetBundleCreateRequest>();

            while (_loadingQueue.Count > 0)
            {
                //先等待一帧,这样同一帧内的相同资源请求都会创建好
                yield return null;
                if (_processingRequests.Count < _maxProcessCount)
                {
                    //每帧同时开启多个协程处理加载请求
                    for (int i = 0, imax = Mathf.Min(_loadingQueue.Count, _maxProcessCount - _processingRequests.Count); i < imax; i++)
                    {
                        string bundleName = _loadingQueue.Dequeue();
                        AssetLoadRequest loadRequest;
                        if (_loadRequestDic.TryGetValue(bundleName, out loadRequest))
                        {
                            _processingRequests.Add(loadRequest);
                            if (UseAssetBundle)
                            {
                                StartCoroutine(LoadAssetAsyncFromAssetBundle(loadRequest));
                            }
                            else
                            {
                                StartCoroutine(LoadAssetFromProjectAsync(loadRequest));
                            }
                        }
                    }
                }
            }
            this.processingActive = false;
            yield return null;
        }


        /// <summary>
        /// 编辑器下模拟异步加载资源，实际上还是同步加载,通过WaitForSeconds来模拟手机上异步加载情况
        /// </summary>
        private IEnumerator LoadAssetFromProjectAsync(AssetLoadRequest loadRequest)
        {
            int delay = UnityEngine.Random.Range(0, 3);
            while (delay >= 0)
            {
                yield return null;
                delay--;
            }
            if (EditorLoadDelay != 0f)
                yield return new WaitForSecondsRealtime(EditorLoadDelay);

            //编辑器模式下无需加载依赖资源
            if (loadRequest.isValid)
            {
                for (int i = 0; i < loadRequest.Handlers.Count; i++)
                {
                    AssetHandler handler = loadRequest.Handlers[i];
                    if (handler.disposed) continue;

                    var asset = LoadAssetFromProject(handler.assetPath, handler.type);
                    if (asset == null)
                    {
                        GameDebug.LogError(string.Format("Load <{0}> Asset is null,assetName = {1}", loadRequest.bundleName, handler.assetName));
                    }
                    handler.Excute(asset);
                }
            }
            else
            {
                //请求已失效，所有的AssetHandler都disposed了,跳过加载该资源
#if GAMERES_LOG
                GameDebug.LogError("AssetLoadRequest请求已失效: " + loadRequest.bundleName);
#endif
            }

            //处理完毕,从处理列表中移除
            _processingRequests.Remove(loadRequest);
            _loadRequestDic.Remove(loadRequest.bundleName);
        }

        /// <summary>
        /// 1.整包资源->加载Bundle->加载Asset->触发回调
        /// 2.小包资源->开始静默下载->存在替代资源->加载替代资源->触发回调->等待资源下载完毕->跳转到整包资源加载流程
        ///                    └>不存在替代资源->跳过加载步骤─────────────────┘
        /// </summary>
        /// <param name="loadRequest"></param>
        /// <returns></returns>
        private IEnumerator LoadAssetAsyncFromAssetBundle(AssetLoadRequest loadRequest)
        {
            //请求已失效，所有的AssetHandler都disposed了,跳过加载该资源
            if (!loadRequest.isValid)
            {
#if GAMERES_LOG
                GameDebug.LogError("AssetLoadRequest请求已失效: " + loadRequest.bundleName);
#endif
                _processingRequests.Remove(loadRequest);
                _loadRequestDic.Remove(loadRequest.bundleName);
                yield break;
            }

            var resInfo = curResConfig.GetResInfo(loadRequest.bundleName);
            if (resInfo == null)
            {
                GameDebug.LogError(string.Format("加载失败，没有<{0}>资源的信息", loadRequest.bundleName));
                _processingRequests.Remove(loadRequest);
                _loadRequestDic.Remove(loadRequest.bundleName);
                yield break;
            }

            AssetBundleInfo abInfo = GetAssetBundleInfo(loadRequest.bundleName);
            List<string> allDependencies = null;

            //所有依赖添加引用
            abInfo.AddLoadingCount();
            if (resInfo.Dependencies.Count > 0)
            {
                allDependencies = curResConfig.GetAllDependencies(loadRequest.bundleName);
                for (int i = 0; i < allDependencies.Count; i++)
                {
                    AssetBundleInfo refAbInfo = GetAssetBundleInfo(allDependencies[i]);
                    refAbInfo.AddLoadingCount();
                }
            }

            if (allDependencies != null)
            {
                for (int i = 0; i < allDependencies.Count; i++)
                {
                    //如果该依赖资源已加载,直接跳过,否则创建所有依赖资源Bundle加载请求
                    string refBundleName = allDependencies[i];
                    AssetBundleInfo refAbInfo = GetAssetBundleInfo(refBundleName);
                    if (refAbInfo.assetBundle == null)
                    {
                        var refResInfo = curResConfig.GetResInfo(refBundleName);
                        if (refResInfo != null)
                        {
                            if (!_createBundleRequestDic.ContainsKey(refBundleName))
                            {
                                _createBundleRequestDic.Add(refBundleName, AssetBundle.LoadFromFileAsync(refResInfo.loadPath, 0, refResInfo.bundleOffset));
                            }
                            //else
                            //{
                            //    GameDebug.Log("已存在AssetBundleCreateRequest,无需重复创建:" + refBundleName);
                            //}
                        }
                        else
                        {
                            GameDebug.LogError("refResInfo is null: " + refBundleName);
                        }
                    }
                }

                //等待所有Bundle创建请求加载完毕
                for (int i = 0; i < allDependencies.Count; i++)
                {
                    string refBundleName = allDependencies[i];
                    AssetBundleInfo refAbInfo = GetAssetBundleInfo(refBundleName);
                    if (refAbInfo.assetBundle == null)
                    {
                        AssetBundleCreateRequest request;
                        if (_createBundleRequestDic.TryGetValue(refBundleName, out request))
                        {
                            //等待当前依赖资源Bundle加载完成
                            while (!request.isDone)
                            {
                                yield return null;
                            }

                            var refBundle = request.assetBundle;
                            if (refBundle != null)
                            {
                                refAbInfo.Load(refBundle);
                            }
                            else
                            {
                                GameDebug.LogError("加载AssetBundle失败: " + refBundleName);
                            }
                            _createBundleRequestDic.Remove(refBundleName);
                        }
                    }
                }
            }

            if (abInfo.assetBundle == null)
            {
                var createRequest = AssetBundle.LoadFromFileAsync(resInfo.loadPath, 0, resInfo.bundleOffset);
                yield return createRequest;

                var assetBundle = createRequest.assetBundle;
                if (assetBundle != null)
                {
                    abInfo.Load(assetBundle);
                }
                else
                {
                    GameDebug.LogError("加载AssetBundle失败: " + resInfo.bundleName);
                }
            }


            if (abInfo != null)
            {
                //相关Bundle加载完毕,异步加载Bundle内的所有资源,如果已经加载过直接跳过
                if (abInfo.onlyAsset == null && abInfo.assetList == null)
                {
                    yield return StartCoroutine(abInfo.CacheAllAssetAsync());
                }

                //根据disposed标记决定是否触发回调
                for (int i = 0; i < loadRequest.Handlers.Count; i++)
                {
                    AssetHandler handler = loadRequest.Handlers[i];
                    if (handler.disposed) continue;

                    if (abInfo.onlyAsset != null)
                    {
                        handler.Excute(abInfo.onlyAsset);
                    }
                    else if (abInfo.assetList != null)
                    {
                        Object asset = abInfo.FindAsset(handler.assetName, handler.type);
                        if (asset != null)
                        {
                            handler.Excute(asset);
                        }
                        else
                        {
                            handler.OnError();
                        }
                    }
                    else
                    {
                        handler.OnError();
                    }

#if GAMERES_LOG
                    GameDebug.LogError(handler.ToString());
#endif
                }
            }

            abInfo.DelLoaingCount();
            if (allDependencies != null)
            {
                for (int i = 0; i < allDependencies.Count; i++)
                {
                    AssetBundleInfo refAbInfo = GetAssetBundleInfo(allDependencies[i]);
                    refAbInfo.DelLoaingCount();
                }
            }

            //处理完毕,从处理列表中移除
            _processingRequests.Remove(loadRequest);
            _loadRequestDic.Remove(loadRequest.bundleName);
        }

        #endregion


        #region 资源释放接口
         
        public void UnloadAllAtlas()
        {
            if (abInfoDic == null)
                return;

            foreach(AssetBundleInfo abinfo in abInfoDic.Values)
            {
                abinfo.UnloadAtlas();
            }
        }

        public void AddAssetBundleRef(string assetPath)
        {
            if (abInfoDic == null)
                return;

            AssetNameInfo abNameInfo = AssetNameInfo.ParseAssetPath(assetPath);
            if (abInfoDic.ContainsKey(abNameInfo.bundleName))
            {
                AssetBundleInfo abInfo = abInfoDic[abNameInfo.bundleName];
                abInfo.AddRef(assetPath);

                var allDependencies = curResConfig.GetAllDependencies(abNameInfo.bundleName);
                for (int i = 0; i < allDependencies.Count; i++)
                {
                    string dependName = allDependencies[i];
                    if (abInfoDic.ContainsKey(dependName))
                    {
                        AssetBundleInfo dependInfo = abInfoDic[dependName];
                        dependInfo.AddRef(assetPath);
                    }
//                    else
//                    {
//                        Debug.LogError("AddAssetBundleRef Error! " + dependName);
//                    }
                }
            }
//            else
//            {
//                Debug.LogError("AddAssetBundleRef Error! " + abNameInfo.bundleName);
//            }
        }
   
        public void DelAssetBundleRef(string assetPath)
        {
            if (abInfoDic == null)
                return;

            AssetNameInfo abNameInfo = AssetNameInfo.ParseAssetPath(assetPath);
            if (abInfoDic.ContainsKey(abNameInfo.bundleName))
            {
                AssetBundleInfo abInfo = abInfoDic[abNameInfo.bundleName];
                abInfo.DelRef(assetPath);

                var allDependencies = curResConfig.GetAllDependencies(abNameInfo.bundleName);
                for (int i = 0; i < allDependencies.Count; i++)
                {
                    string dependName = allDependencies[i];
                    if (abInfoDic.ContainsKey(dependName))
                    {
                        AssetBundleInfo dependInfo = abInfoDic[dependName];
                        dependInfo.DelRef(assetPath);
                    }
                    else
                    {
                        Debug.LogError("DelAssetBundleRef Error! " + dependName);
                    }
                }
            }
            else
            {
                Debug.LogError("DelAssetBundleRef Error! " + abNameInfo.bundleName);
            }
        }

        public void UnloadAssetBundle(string assetPath, bool unloadAll = false)
        {
            if (abInfoDic == null)
                return;

            AssetNameInfo abNameInfo = AssetNameInfo.ParseAssetPath(assetPath);
            if (abNameInfo.bundleName.StartsWith("atlas/") || abNameInfo.bundleName.StartsWith("font/"))
            {
                return;
            }

            if (abInfoDic.ContainsKey(abNameInfo.bundleName))
            {
                AssetBundleInfo abInfo = abInfoDic[abNameInfo.bundleName];
                var allDependencies = curResConfig.GetAllDependencies(abNameInfo.bundleName);
                for (int i = 0; i < allDependencies.Count; i++)
                {
                    string refName = allDependencies[i];
                    if (refName.StartsWith("atlas/") || refName.StartsWith("font/"))
                    {
                        continue;
                    }
                    if (abInfoDic.ContainsKey(refName))
                    {
                        AssetBundleInfo refabInfo = abInfoDic[refName];
                        if (refabInfo.Unload(unloadAll))
                        {
                            abInfoDic.Remove(refName);
                        }
                    }
                }
                if (abInfo.Unload(unloadAll))
                {
                    abInfoDic.Remove(abNameInfo.bundleName);
                }
            }
        }

        public void UnloadUnusedAssetBundle()
        {
            if (abInfoDic == null)
                return;

            tempList.Clear();
            foreach (var one in abInfoDic)
            {
                AssetBundleInfo abinfo = one.Value;
                if (abinfo.bundleName.StartsWith("atlas/") || abinfo.bundleName.StartsWith("font/"))
                {
                    continue;
                }
                
                if(abinfo.Unload())
                {
                    tempList.Add(one.Key);
                }
            }

            for (int i = 0; i < tempList.Count; i++)
            {
                abInfoDic.Remove(tempList[i]);
            }
        }

		public static Texture LoadStreamingAssetsTexture(string path)
		{
			Texture2D texture2d = new Texture2D(0, 0);
			texture2d.wrapMode = TextureWrapMode.Clamp;
			WWW www = LoadStreamingFile(path);
			byte[] rawBytes = www != null ? www.bytes : null;
			texture2d.LoadImage(rawBytes);
			return texture2d;
		}

		public static string LoadStreamingAssetsText(string path)
		{
			WWW www = LoadStreamingFile(path);
			return www != null ? www.text : null;
		}
		private static WWW LoadStreamingFile(string path)
		{
			string loadPath = string.Concat(GameResPath.packageResUrlRoot, "/", path);
			WWW www = new WWW(loadPath);
			int sleepCount = 0;
			while (www.isDone == false)
			{
				Thread.Sleep(5);
				sleepCount++;
				if (sleepCount > 3000 / 5)    //超过3秒，直接返回
					return null;
			}
			return www;
		}

        #endregion

        #region 资源释放接口

        //public bool UnloadBundle(string assetName, ResGroup resGroup, bool unloadAll = false)
        //{
        //    return UnloadBundle(GetBundleName(assetName, resGroup), unloadAll);
        //}

        ///// <summary>
        /////     释放相关资源的AssetBundle
        ///// </summary>
        ///// <param name="bundleName"></param>
        ///// <param name="unloadAll"></param>
        //public bool UnloadBundle(string bundleName, bool unloadAll = false)
        //{
        //    if (_curResConfig == null)
        //        return false;
        //    if (string.IsNullOrEmpty(bundleName))
        //        return false;

        //    var resInfo = _curResConfig.GetResInfo(bundleName);
        //    if (resInfo == null)
        //    {
        //        Debug.LogError(string.Format("加载失败，没有<{0}>资源的信息", bundleName));
        //        return false;
        //    }

        //    AssetBundleInfo abInfo;
        //    if (_abInfoDic.TryGetValue(bundleName, out abInfo))
        //    {
        //        if (abInfo.Unload(unloadAll))
        //        {
        //            _abInfoDic.Remove(bundleName);
        //            if (resInfo.Dependencies.Count > 0)
        //            {
        //                var allDependencies = _curResConfig.GetAllDependencies(bundleName);
        //                foreach (string refBundleName in allDependencies)
        //                {
        //                    AssetBundleInfo refBundleInfo;
        //                    if (_abInfoDic.TryGetValue(refBundleName, out refBundleInfo))
        //                    {
        //                        refBundleInfo.RemoveRef(bundleName);
        //                    }
        //                    //else
        //                    //{
        //                    //    Debug.LogError(string.Format("不存在该资源<{0}> 依赖的资源<{1}>,请检查加载流程是否有误!", bundleName, refBundleName));
        //                    //}
        //                }
        //            }
        //            return true;
        //        }
        //    }
        //    return false;
        //}

        //public void UnloadDependencies(string assetName, ResGroup resGroup, bool unloadAll = false, bool refBundleUnloadAll = false)
        //{
        //    UnloadDependencies(GetBundleName(assetName, resGroup), unloadAll, refBundleUnloadAll);
        //}

        ///// <summary>
        ///// 尝试卸载该BundleName相关的所有Bundle,包括它本身及其依赖的Bundle
        ///// </summary>
        ///// <param name="bundleName"></param>
        ///// <param name="unloadAll"></param>
        //public void UnloadDependencies(string bundleName, bool unloadAll = false, bool refBundleUnloadAll = false)
        //{
        //    if (_curResConfig == null)
        //        return;
        //    if (string.IsNullOrEmpty(bundleName))
        //        return;

        //    var resInfo = _curResConfig.GetResInfo(bundleName);
        //    if (resInfo == null)
        //    {
        //        Debug.LogError(string.Format("加载失败，没有<{0}>资源的信息", bundleName));
        //        return;
        //    }

        //    UnloadBundle(bundleName, unloadAll);
        //    if (resInfo.Dependencies.Count > 0)
        //    {
        //        var allDependencies = _curResConfig.GetAllDependencies(bundleName);
        //        foreach (string refBundleName in allDependencies)
        //        {
        //            ResGroup resGroup = GetResGroup(refBundleName);
        //            //图集和字体用引用计数管理
        //            if (resGroup != ResGroup.UIAtlas && resGroup != ResGroup.UIFont)
        //                UnloadBundle(refBundleName, refBundleUnloadAll);
        //        }
        //    }
        //}
        public void AddUnloadBundleToQueue(string bundleName)
        {
            _unloadBundleManager.AddBundle(bundleName);
        }

        public void RemoveUnloadBundleToQueue(string bundleName)
        {
            _unloadBundleManager.RemoveBundle(bundleName);
        }
        private class UnloadBundleManager
        {
            private readonly HashSet<string> unloadBundleSet;
            private readonly AssetManager master;
            private Coroutine runCoroutine;
            public UnloadBundleManager(AssetManager master)
            {
                this.master = master;
                unloadBundleSet = new HashSet<string>();
            }

            public void AddBundle(string bundleName)
            {
                if (unloadBundleSet.Contains(bundleName))
                    return;

                unloadBundleSet.Add(bundleName);

                if (runCoroutine == null)
                {
                    runCoroutine = master.StartCoroutine(RemoveCoroutine());
                }
            }

            public void RemoveBundle(string bundleName)
            {
                unloadBundleSet.Remove(bundleName);
            }
            private IEnumerator RemoveCoroutine()
            {
                while (unloadBundleSet.Count > 0)
                {
                    yield return null;
                    //加载中Unload 会导致Unity BUG
                    if (master._processingRequests.Count > 0)
                        continue;
                    var tor = unloadBundleSet.GetEnumerator();
                    if (tor.MoveNext())
                    {
                        string bundleName = tor.Current;
                        unloadBundleSet.Remove(bundleName);
                        //AssetManager.Instance.UnloadDependencies(bundleName);
                    }
                }
                runCoroutine = null;
            }

            public void Dispose()
            {
                if (runCoroutine != null)
                {
                    master.StopCoroutine(runCoroutine);
                    runCoroutine = null;
                }
            }
        }
        #endregion
    }
}
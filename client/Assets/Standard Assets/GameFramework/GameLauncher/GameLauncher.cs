using System;
using LITJson;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using AssetPipeline;
using Debug = UnityEngine.Debug;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class GameLauncher : MonoBehaviour
{
    //进游戏之前andriod更新的数据
    public class AndriodUpdateInfo
    {
        public string cndUrls;
        public int testMode;
    }

    public static string andriodUpdateFileName = "andriodUpdateInfo.json";

    public static AndriodUpdateInfo andriodUpdateInfo
    {
        get;
        private set;
    }

    public static GameLauncher Instance
    {
        get;
        private set;
    }

    public GameObject GameRoot
    {
        get;
        private set;
    }

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        //通知android unity初始化完成
        SPSDK.UnityInitFinish();
        InitGameUpdateSetting();
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            BuiltInDialogueViewController.OpenView("退出游戏", ExitGame, () =>
            {
                GameDebug.Log("Cancel ExitGame");
            });
        }
    }


    /// <summary>
    /// 防止意外界面大小不正常
    /// </summary>
    private void ResolutionCheck()
    {
        if (Application.platform == RuntimePlatform.WindowsPlayer)
        {
            //    // 临时定死值
            //    if (Screen.width < 500 || Screen.height < 300)
            //    {
            Screen.SetResolution(960, 600, false);
            //    }
        }
    }


    /// <summary>
    ///     初始化游戏更新环境
    /// </summary>
    private void InitGameUpdateSetting()
    {
#if UNITY_STANDALONE && !UNITY_EDITOR
        var limitedNum = 30;
        if (GameLauncherMutex.GetMutexTag(GameSetting.GameName) > limitedNum)
        {
            string msg = string.Format ("同时最多只能开{0}个游戏客户端", StringHelper.GetSingleChineseNum (limitedNum));
            BuiltInDialogueViewController.OpenView(msg, ExitGame, null, UIWidget.Pivot.Center);
            return;
        }
#endif

        ResolutionCheck();
        Screen.sleepTimeout = SleepTimeout.NeverSleep;  //游戏设置为不自动休眠屏幕

        ProjectIconSetting.Setup();
        GameSetting.Setup();
        GameDebug.Init(GameSetting.ShowUpdateLog);
        PlatformAPI.Setup();
        HttpController.Instance.Setup();
        UploadDataManager.CreateInstance();
        AssetManager.CreateInstance();
        AssetUpdate.CreateInstance();
        AssetUpdate.Instance.SetLogHanlder(ShowTips, ShowError);

        Crasheye.StartInitCrasheye(GameSetting.Channel, GameConfig.CRASHEYE_APPKEY);
        Crasheye.SetAppVersion(GameVersion.ResVersion);
        //  游戏启动日志
        LogMgr.StartGameLog();

        //  屏蔽信鸽
        /*
        XinGeSdk.Setup();
        XinGeSdk.Register();
        XinGeSdk.EnableDebug(true);
        */

        StartCoroutine(ShowLoading());
    }

    public IEnumerator ShowLoading()
    {
        GameLauncherViewController.OpenView("");
#if !UNITY_EDITOR && UNITY_ANDROID
        //  不显示splash
        //        GameLauncherViewController._instance.ShowSplash();
        //        yield return new WaitForSeconds(3.0f);
#endif
        GameLauncherViewController._instance.ShowLoadingBg();
        ShowTips("初始化游戏");
        yield return null;
        JudgeNetExist();
    }


    private void JudgeNetExist()
    {
        if (Application.isMobilePlatform)
        {
            string curNetType = PlatformAPI.getNetworkType();
            if (curNetType == PlatformAPI.NET_STATE_NONE)
            {
                BuiltInDialogueViewController.OpenView("网络异常，请检查网络后重新连接", JudgeNetExist, ExitGame, UIWidget.Pivot.Center, "重新连接", "退出游戏");
                return;
            }
        }
        LoadAndriodUpdateInfo();
        CheckUpdate();
        //OnLoadCommonAssetFinish();
        //OnUpdateAssetFinish();
    }

    private void CheckUpdate()
    {
        if (AssetManager.ResLoadMode == AssetManager.LoadMode.EditorLocal)
        {
            OnLoadCommonAssetFinish();
        }
        else if (AssetManager.ResLoadMode == AssetManager.LoadMode.Assetbundle)
        {
            AssetUpdate.Instance.StartCheckOutGameRes(needRestart =>
            {
                if (needRestart)
                {
                    RestartGame();
                }
                else
                {
                    AssetUpdate.Instance.StartLoadPackageGameConfig(OnUpdateAssetFinish);
      //               GameLauncherViewController._instance.ShowVersion();
      //               if (GameSetting.updateMode == GameSetting.UpdateMode.TestUpdate)
      //               {
                        // if (andriodUpdateInfo != null && andriodUpdateInfo.testMode != null)
                        // {
                            
                        //  var andriodChooseMode = (UpdateSettingViewController.UpdateMode)andriodUpdateInfo.testMode;
                        //  SetTestMode(andriodChooseMode);
                        // }
                        // else
                        // {
                        //  ShowUpdateSettingView();
                        // }
      //               }
      //               else if (GameSetting.updateMode == GameSetting.UpdateMode.Update)
      //               {
      //                   LoadStaticConfig();
      //               }
      //               else
      //               {
      //                   AssetUpdate.Instance.StartLoadPackageGameConfig(OnUpdateAssetFinish);
      //               }
                }
            });
        }
    }

    private void LoadAndriodUpdateInfo()
    {
        var path = Application.persistentDataPath + "/" + andriodUpdateFileName;
        if (FileHelper.IsExist(path))
        {
            andriodUpdateInfo = FileHelper.ReadJsonFile<AndriodUpdateInfo>(path);
        }
        Debug.Log("LoadAndriodUpdateInfo :" + (andriodUpdateInfo!=null));
    }

    private static bool isTestVersionConfig = false;
    private static bool isTestHttpRoot = false;


    private void ShowUpdateSettingView()
    {
        UpdateSettingViewController.OpenView((mode) =>
        {
            SetTestMode(mode);
        });
    }

    private void SetTestMode(UpdateSettingViewController.UpdateMode mode)
    {
        if (mode == UpdateSettingViewController.UpdateMode.DEV_TEST)
        {
            isTestVersionConfig = true;
            isTestHttpRoot = true;
        }
        else if (mode == UpdateSettingViewController.UpdateMode.OFFICIAL_TEST)
        {
            isTestVersionConfig = true;
            isTestHttpRoot = false;
        }
        else if (mode == UpdateSettingViewController.UpdateMode.OFFICIAL)
        {
            isTestVersionConfig = false;
            isTestHttpRoot = false;
        }
        else if (mode == UpdateSettingViewController.UpdateMode.SKIP_UPDATE)
        {
            AssetUpdate.Instance.StartLoadPackageGameConfig(OnUpdateAssetFinish);
            return;
        }
        LoadStaticConfig();
    }


    public static void ShowTips(string tips)
    {
        GameLauncherViewController.ShowTips(tips);
    }

    public void DestroyGameLoader()
    {
        gameObject.SetActive(false);
        Destroy(gameObject);
    }


    private void ExitGame()
    {
        Application.Quit();

#if UNITY_EDITOR
        EditorApplication.isPlaying = false;
#endif
    }

    private void ShowError(string msg)
    {
        if (string.IsNullOrEmpty(msg))
        {
            ExitGame();
        }
        else
        {
            BuiltInDialogueViewController.OpenView(msg, ExitGame, null, UIWidget.Pivot.Center);
        }
    }


    private void LoadStaticConfig()
    {
        ShowTips("加载游戏配置信息");
        AssetUpdate.Instance.LoadStaticConfig(isTestHttpRoot,
        () =>
        {
            StartUpdateAsset();
        },
        (tips) =>
        {
            BuiltInDialogueViewController.OpenView(tips, LoadStaticConfig, ExitGame, UIWidget.Pivot.Left, "重试", "退出");
        });
    }

    /// <summary>
    ///     开始更新游戏资源
    /// </summary>
    private void StartUpdateAsset()
    {
        StaticConfig staticConfig = AssetUpdate.Instance.ReadLocalStaticConfig ();
        if (staticConfig.channelVersion != null)
        {
            string p = "commom";
            //  判断渠道
#if (UNITY_EDITOR || UNITY_STANDALONE)
            p = GameSetting.Channel;
#elif UNITY_ANDROID
            string subChannelId = SPSDK.GetSubChannelId();
            if (!string.IsNullOrEmpty(subChannelId)) {
                p = subChannelId;
            }
            if (!string.IsNullOrEmpty(SPSDK.ChannelAreaFlag)) {
                p += "_" + SPSDK.ChannelAreaFlag;
            }
#elif UNITY_IPHONE
            string subChannel = SPSDK.GetSubChannelId();
            if (!string.IsNullOrEmpty(subChannel)) {
                p = subChannel;
            }
            p += "_ios";
            if (!string.IsNullOrEmpty(SPSDK.ChannelAreaFlag)) {
                p += "_" + SPSDK.ChannelAreaFlag;
            }
#endif
            GameDebug.Log("===== 当前本地的 P 参数 =====:" + p);
            if (staticConfig.channelVersion.ContainsKey(p)) {
                string ver = staticConfig.channelVersion[p];
                GameDebug.Log(string.Format("当前CurVer:{0} | 远端TarVer:{1}", GameVersion.AppVersion, ver));
                if (ver != null && ver == GameVersion.AppVersion) {
                    // 不需要更新资源等
                    AssetUpdate.Instance.UpdateScript(OnUpdateAssetFinish, false);
                    return;
                }
            }
        }

        AssetUpdate.Instance.FetchVersionConfig(isTestVersionConfig, () =>
        {
            CheckClientUpdate();
        });
    }

    /// <summary>
    /// 检查客户端整包更新
    /// </summary>
    private void CheckClientUpdate()
    {
        GameDebug.Log("检查客户端整包更新");
        var versionConfig = AssetUpdate.Instance.CurVersionConfig;
        if (versionConfig == null)
        {
            BuiltInDialogueViewController.OpenView("获取版本信息失败", StartUpdateAsset);
            return;
        }

        GameDebug.Log(string.Format("RemoteFrameworkVersion={0} LocalFrameworkVersion={1}", versionConfig.frameworkVer, GameVersion.frameworkVersion));
        if (versionConfig.frameworkVer > GameVersion.frameworkVersion)
        {
            if (versionConfig.forceUpdate)
            {
                //  判空
                if (string.IsNullOrEmpty(versionConfig.helpUrl))
                {
                    GameLauncherViewController._instance.ShowUpdateTip(CheckClientUpdate);
                }
                else
                {
                    GameLauncherViewController._instance.ShowDownloadTip(() => {
                        Application.OpenURL(versionConfig.helpUrl);
                        CheckClientUpdate();
                    });
                }
            }
            else
            {
                GameLauncherViewController._instance.ShowDownloadTip(() => {
                    Application.OpenURL(versionConfig.helpUrl);
                    CheckClientUpdate();
                });
            }
        }
        else
        {
            UpdateDll();
        }
    }


    private void RestartGame()
    {
        if (Application.platform == RuntimePlatform.Android)
        {
            BuiltInDialogueViewController.OpenView("检查到更新，点击确认后片刻重新启动", PlatformAPI.RestartGame);
        }
        else
        {
            PlatformAPI.RestartGame();
        }
    }

    private void UpdateDll()
    {
        if (GameLauncher.andriodUpdateInfo != null)
        {
            UpdateGameRes();
        }
        else if (AssetUpdate.Instance.ValidateDllVersion(RestartGame))
        {
            UpdateGameRes();
        }
    }

    private void UpdateGameRes()
    {
        AssetUpdate.Instance.UpdateGameRes(UpdateScript);
    }

    private void UpdateScript()
    {
        AssetUpdate.Instance.UpdateScript(ValidateScript);
    }

    private void ValidateScript()
    {
        AssetUpdate.Instance.ValidateScript(OnUpdateAssetFinish);
    }

    /// <summary>
    ///     资源更新完成
    /// </summary>
    private void OnUpdateAssetFinish()
    {
        if (Application.isMobilePlatform)
        {
            long freeMemory = PlatformAPI.getFreeMemory() / 1024;
            GameDebug.Log("PhoneFreeMemory : " + freeMemory);

#if UNITY_ANDROID
            if (freeMemory < 150L)
            {
                BuiltInDialogueViewController.OpenView("您的手机剩余内存剩余较低，运行游戏可能会出现闪退情况，建议先清理内存",
                    ExitGame, OnUpdateAssetFinish,
                    UIWidget.Pivot.Left, "退出", "继续");
                return;
            }
#endif
        }

        string path = System.IO.Path.Combine(GameResPath.persistentDataPath, "firstrun");
        if (FileHelper.IsExist(path))
        {
            ShowTips("加载公共资源");
        }
        else
        {
            ShowTips("首次加载游戏可能需要等待较长时间（本过程不消耗流量）");
            FileHelper.WriteAllText(path, "");
        }

        AssetManager.Instance.LoadCommonAsset(OnLoadCommonAssetFinish);
    }

    /// <summary>
    ///     加载公共资源完毕,加载GameRoot,启动AppGameManager
    /// </summary>
    private void OnLoadCommonAssetFinish()
    {
        GameObject prefab = AssetManager.Instance.LoadAsset("UI/GameRoot.prefab") as GameObject;
        GameObject gameRoot =  Instantiate(prefab);
        gameRoot.name = "GameRoot";
        AssetManager.Instance.UnloadAssetBundle("UI/GameRoot.prefab");
        DontDestroyOnLoad(gameRoot);
        GameRoot = gameRoot;
        var appGameType = Type.GetType("LuaMain, Assembly-CSharp, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null");
        gameRoot.AddComponent(appGameType);
    }
}

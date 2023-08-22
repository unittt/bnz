using System;
using System.Text;
using LITJson;
using UnityEngine;
using System.Collections.Generic;
using AssetPipeline;

public static class GameSetting
{
    public enum DebugInfoType
    {
        None,
        Default,
        Verbose
    }

    public enum UpdateMode
    {
        NoUpdate,
        TestUpdate,
        Update
    }

    public enum PlatformType
    {
        Win = 1,
        Android = 2,
        IOS = 3,
    }

    public enum PlatformTypeForDemi
    {
        Android = 1,
        ROOTIOS = 2,
        IOS = 3,
        Win = 4
    }

    public const string Config_WritePathInAssetV2 = "Assets/StreamingAssets/GameSettingDataInAssetV2.txt";
    public const string Config_WritePathV2 = "Assets/Resources/Setting/GameSettingDataV2.txt";
    public const string Config_ReadPathV2 = "Setting/GameSettingDataV2";

    private static GameSettingData _gameSettingData;

    public static bool CheckUpdate
    { 
        get; 
        private set; 
    }

    public static UpdateMode updateMode;

    public static bool ShowUpdateLog
    { 
        get;
        private set;
    }

    private static string _gameName;
	public static string GameName {
		get
        {
            if (String.IsNullOrEmpty(_gameName))
            {
                if (_gameSettingData == null)
                {
                    return "";
                }
                else
                {
                    string name = _gameSettingData.gamename;
                    if (string.IsNullOrEmpty(name))
                    {
                        name = "游戏";
                    }
                    return name;
                }
            }
            return _gameName;
        }

        set { _gameName = value; }
	}

    public static bool QRcodeLogin { get; private set; }

    public static void Setup()
    {
        _gameSettingData = LoadGameSettingData();
        if (_gameSettingData != null)
        {
            QRcodeLogin = _gameSettingData.qrpc;
            Platform = _gameSettingData.platformType;

            if (Platform == PlatformType.Android)
            {
                PlatformForDemi = PlatformTypeForDemi.Android;
            }
            else if(Platform == PlatformType.IOS)
            {
                PlatformForDemi = PlatformTypeForDemi.IOS;
            }
            else
            {
                PlatformForDemi = PlatformTypeForDemi.Win;
            }

            HttpRoot = _gameSettingData.httpRoot;

            if (_gameSettingData.channel == "demi")
            {
                PlatformHttpRoot = String.Format("{0}/{1}/{2}", _gameSettingData.httpRoot,
                    _gameSettingData.resdir,
                    PlatformTypeNameForDemi);
            }
            else
            {
                PlatformHttpRoot = String.Format("{0}/{1}/{2}", _gameSettingData.httpRoot,
                    _gameSettingData.resdir,
                    PlatformTypeName);
            }

            TestHttpRoot = _gameSettingData.testHttpRoot;
            DomainName = _gameSettingData.domainType;
            ResDir = _gameSettingData.resdir;
            Channel = _gameSettingData.channel;
            ShowUpdateLog = _gameSettingData.showUpdateLog;
            updateMode = _gameSettingData.updateMode;
			GameName = GetAppName();

            BundleId = Application.bundleIdentifier;

            if (_gameSettingData.domainType == "release")
                DEMISDK_SERVER = "https://sdk.demigame.com/v1";

            SubChannel = GetSubChannel();
            MutilPackageId = GetMutilPackageId();
            //APP_ID = GetGameId();
        }
        else
        {
            GameDebug.LogError(" GameSettingData Setup Error !!");
        }
    }

    /// <summary>
    /// 初始化服务器Http请求地址
    /// </summary>
    /// <param name="config"></param>
    public static void SetupServerUrlConfig(StaticConfig config)
    {
        if (config == null)
        {
            GameDebug.LogError("ServerUrlConfig is null ");
            return;
        }

        string resDir = ResDir;
        CDN_SERVER_LIST.Clear();

        GameDebug.Log("config.demiSdkUrl:" + config.demiSdkUrl + " Channel:" + Channel + " config.paySwitch:" + config.paySwitch + " PAY_SWITCH:" + PAY_SWITCH);
        if (Channel == "demi")
        {
            CDN_SERVER_LIST.Add(config.masterCdnUrl + "/" + ResDir + "/" + PlatformTypeNameForDemi);
            if (!string.IsNullOrEmpty(config.slaveCdnUrl))
            {
                CDN_SERVER_LIST.Add(config.slaveCdnUrl + "/" + ResDir + "/" + PlatformTypeNameForDemi);
            }
            if (!string.IsNullOrEmpty(config.srcCdnUrl))
            {
                CDN_SERVER_LIST.Add(config.srcCdnUrl + "/" + ResDir + "/" + PlatformTypeNameForDemi);
            }
            CDN_SERVER = CDN_SERVER_LIST[0];

            if (!string.IsNullOrEmpty(config.demiSdkUrl))
            {
                DEMISDK_SERVER = config.demiSdkUrl;
            }

            if (!string.IsNullOrEmpty(config.paySwitch))
            {
                if (config.paySwitch == "0")
                {
                    PAY_SWITCH = false;
                }
                else
                {
                    PAY_SWITCH = true;
                }
            }
        }
        else
        {
            CDN_SERVER_LIST.Add(config.masterCdnUrl + "/" + ResDir + "/" + PlatformTypeName);
            if (!string.IsNullOrEmpty(config.slaveCdnUrl))
            {
                CDN_SERVER_LIST.Add(config.slaveCdnUrl + "/" + ResDir + "/" + PlatformTypeName);
            }
            if (!string.IsNullOrEmpty(config.srcCdnUrl))
            {
                CDN_SERVER_LIST.Add(config.srcCdnUrl + "/" + ResDir + "/" + PlatformTypeName);
            }
            CDN_SERVER = CDN_SERVER_LIST[0];
        }
        
        GameDebug.Log("SetupServerUrlConfig DEMISDK_SERVER:" + DEMISDK_SERVER + " PAY_SWITCH:" + PAY_SWITCH);
    }


    public static GameSettingData LoadGameSettingData()
    {
        var assetV2 = Resources.Load(Config_ReadPathV2) as TextAsset;
        if (assetV2 != null)
        {
            string json = Encoding.UTF8.GetString(assetV2.bytes);
            GameSettingData data = JsonMapper.ToObject<GameSettingData>(json);
            return data;
        }
        else
        {
            return null;
        }
    }

    /// <summary>
    /// 游戏金币名字
    /// </summary>
    public static string PayProductName = "元宝";

    /// <summary>
    /// 游戏金币描述
    /// </summary>
    public static string PayProductDesc = "用于购买特殊道具";


    #region 平台相关属性


    public static string HttpRoot { get; set; }

    /// <summary>
    ///     域类型名
    /// </summary>
    public static string DomainName { get; set; }



    public static string TestHttpRoot { get; set; }

    /// <summary>
    ///     资源目录
    /// </summary>
    public static string ResDir { get; set; }


    /// <summary>
    ///     平台根目录 例如：内开发 /localdev/android
    /// </summary>
    public static string PlatformTypeNameForDemi
    {
        get { return PlatformForDemi.ToString().ToLower(); }
    }

    /// <summary>
    ///     平台标识
    /// </summary>
    public static int PlatformTypeIdForDemi
    {
        get { return (int)PlatformForDemi; }
    }

    /// <summary>
    ///     平台枚举值
    /// </summary>
    public static PlatformTypeForDemi PlatformForDemi { get; set; }


    /// <summary>
    ///     平台枚举值
    /// </summary>
    public static PlatformType Platform { get; set; }
    
    public static string PlatformTypeName
    {
        get
        {
#if UNITY_ANDROID
            return "android";
#elif UNITY_IPHONE
        return "ios";
#else
        return "win";
#endif
        }
    }

    /// <summary>
    ///     包名
    /// </summary>
    public static string BundleId = "";

    /// <summary>
    ///     游戏ID
    /// </summary>
    public static int APP_ID = 6;

    /// <summary>
    ///     融合sdk，运营商，如sm， demi， yijie
    /// </summary>
    public static string Channel = "";

    /// <summary>
    ///     渠道号，比如uc、huawei
    /// </summary>
    public static string SubChannel = "";

    //分包标识，比如demi渠道下的acfun分包 demi_acfun
    public static string MutilPackageId = "";


    /// <summary>
    ///     demi 渠道服务器
    /// </summary>
    public static string DEMISDK_SERVER = "https://dev.sdk.cilugame.com/v1";

    public static string DEMISDK_SERVER_RELEASE = "https://sdk.demigame.com/v1";

    /// <summary>
    ///     SSO服务器地址
    /// </summary>
    public static string SSO_SERVER = "http://dev.h7.cilugame.com/h7";

    /// <summary>
    ///     PAY服务器地址
    /// </summary>
    public static string PAY_SERVER = "http://dev.h7.cilugame.com/h7";

    public static bool PAY_SWITCH = false;

    public static bool DEMI_SDK_USE_NEW = false;
    public static string DEMI_SDK_CODE = "1";
    public static string DEMI_SDK_CODE_PAY = "1";
    public static int DEMI_SDK_UILayer = 550505;
    /// <summary>
    /// 广告app_id
    /// </summary>
    public static string ad_app_id_for_ios = "1001";

    /// <summary>
    /// 广告activity_id
    /// </summary>
    public static string ad_activity_id_for_ios = "0";

    //trackingIO appId
    public static string trackingIO_appId = "";
    


    public static List<string> PlatformResPathList
    {
        get
        {
            List<string> list = new List<string>();
            for (int i = 0; i < CDN_SERVER_LIST.Count; i++)
            {
                list.Add(CDN_SERVER_LIST[i]);
            }
            return list;
        }
    }

    /// <summary>
    ///     配置后缀
    /// </summary>
    public static string ConfigSuffix
    {
        get
        {
            if (_gameSettingData == null)
            {
                return "";
            }
            else
            {
                string suffix = _gameSettingData.configSuffix;
                if (string.IsNullOrEmpty(suffix))
                {
                    suffix = "";
                }
                return suffix;
            }
        }
    }

    #endregion

    ///// <summary>
    /////     CONFIG服务器地址
    ///// </summary>
    private static string _CONFIG_SERVER = "";

    /// <summary>
    ///     CONFIG服务器地址
    /// </summary>
    public static string CONFIG_SERVER
    {
        get { return _CONFIG_SERVER; }
        set
        {
            _CONFIG_SERVER = value;
        }
    }

    ///// <summary>
    /////     CDN服务器地址列表，提供轮询
    ///// </summary>
    public static List<string> CDN_SERVER_LIST = new List<string>();

    ///// <summary>
    /////     CDN服务器地址
    ///// </summary>
    public static string CDN_SERVER = "";

    //此版本号用来判断是否需要整包更新，因为框架的版本不能动态更新。
    public static int csrooturlid = 27000;
    public static int CSRootUrlID
    {
        get
        {
            return csrooturlid;
        }
    }

    /// <summary>
    ///     平台对应http根目录
    ///     .../{domain}/{platform}
    /// </summary>
    public static string PlatformHttpRoot { get; set; }

    #region Win特用

    /// <summary>
    /// 获取平台原始值，Win特用
    /// </summary>
    public static PlatformType OriginPlatform
    {
        get { return _gameSettingData.platformType; }
    }

    public static bool IsOriginWinPlatform
    {
        get { return OriginPlatform == PlatformType.Win; }
    }

    public static string OriginPlatformTypeName
    {
        get { return OriginPlatform.ToString().ToLower(); }
    }

    #endregion

    public static string GetChannel()
    {
        if (GameSetting.Channel != "nucleus")
        {
#if (UNITY_EDITOR || UNITY_STANDALONE)
            // win下取Android的值
            return GameSetting.Channel;
#elif UNITY_ANDROID || UNITY_IPHONE
            var id = SPSDK.GetChannelId();
            CSGameDebuger.Log("SPSDK GetChannelId is: " + id);
            return !string.IsNullOrEmpty(id) ? id : "errorID";
#else
            return GameSetting.Channel;
#endif
        }
        else
        {
            return GameSetting.Channel;
        }
    }

    public static string GetSubChannel()
    {
        if (GameSetting.Channel != "nucleus")
        {
#if (UNITY_EDITOR || UNITY_STANDALONE)
            if (GetChannel() == "demi")
            {
                return "demi";
            }
            return GameSetting.Channel;
#elif UNITY_ANDROID || UNITY_IPHONE
            return SPSDK.GetSubChannelId();
#else
            return GetChannel();
#endif
        }
        else
        {
            return GetChannel();
        }
    }

    public static string GetMutilPackageId()
    {
        if (GameSetting.Channel != "nucleus")
        {
#if (UNITY_EDITOR || UNITY_STANDALONE)
            // win下取Android的值
            return GameSetting.MutilPackageId;
#elif UNITY_ANDROID || UNITY_IPHONE
            var id = SPSDK.GetMutilPackageId();
            CSGameDebuger.Log("SPSDK GetMutilPackageId is: " + id);
            return id;
#else
            return GameSetting.MutilPackageId;
#endif
        }
        else
        {
            return GameSetting.MutilPackageId;
        }
    }

    /// <summary>
    /// 获取游戏ID，仅android
    /// </summary>
    /// <returns></returns>
    public static int GetGameId()
    {
#if UNITY_ANDROID
        string gameID = SPSDK.GetGameId();
        //母包没有配置gameID，直接使用unity的gameID
        if (gameID == "")
        {
            return GameSetting.APP_ID;
        }
        int appID;
        if (int.TryParse(gameID, out appID))
        {
            return appID;
        }
        return GameSetting.APP_ID;
#endif
        return GameSetting.APP_ID;
    }

    public static string GetAppName()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        // win下取Android的值
        return GameSetting.GameName;
#elif UNITY_ANDROID || UNITY_IPHONE
        var name = SPSDK.GetAppName();
        CSGameDebuger.Log("SPSDK GetAppName is: " + name);
        return name;
#else
        return GameSetting.GameName;
#endif
    }
}

public class GameSettingData
{
    //渠道
    public string channel = "";
    ////游戏类型
    public string gameType;
    ////域类型
    public string domainType;

    //正式环境入口域名
    public string httpRoot = "";

    //测试环境域名
    public string testHttpRoot = "";

	//cs服务器地址
	public string csRoot = "";

    //资源目录
    public string resdir = "";

    //游戏名字
    public string gamename = "";

    //配置后缀
    public string configSuffix = "";

    public GameSetting.DebugInfoType logType;
    public GameSetting.PlatformType platformType;

    public bool showUpdateLog = false;

	public GameSetting.UpdateMode updateMode;
	
	//是否扫码PC端
	public bool qrpc = false;
}

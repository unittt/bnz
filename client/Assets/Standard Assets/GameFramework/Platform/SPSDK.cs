
using System;
using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;
using LuaInterface;

public class SdkCallbackInfo
{
    public string type;
    public int code;
    public string data;
}


public class SPSDK
{
	#if UNITY_IPHONE

	[DllImport("__Internal")]
	private static extern uint __spsdk_shenhe(bool b);

    [DllImport("__Internal")]
    private static extern uint __spsdk_init();

    [DllImport("__Internal")]
    private static extern string __spsdk_getChannelId();

    [DllImport("__Internal")]
    private static extern string __spsdk_getSubChannelId();

    [DllImport("__Internal")]
    private static extern void __spsdk_login();

    [DllImport("__Internal")]
	private static extern void __spsdk_submitRoleData(string json);

    [DllImport("__Internal")]
    private static extern void __spsdk_bind();

    [DllImport("__Internal")]
    private static extern void __spsdk_logout();

    [DllImport("__Internal")]
    private static extern bool __spsdk_isSupportUserCenter();

    [DllImport("__Internal")]
    private static extern void __spsdk_enterUserCenter();

    [DllImport("__Internal")]
    private static extern bool __spsdk_isSupportBBS();

    [DllImport("__Internal")]
    private static extern void __spsdk_enterSdkBBS();

    [DllImport("__Internal")]
    private static extern void __spsdk_pay(string json);

    [DllImport("__Internal")]
    private static extern void __spsdk_payExt(string payWay, string dataJson);

    [DllImport("__Internal")]
    private static extern string __spsdk_getAppName();
    
#endif
    private const string SDK_JAVA_CLASS = "com.cilugame.h1.CLSDKPlugin";
	private static AndroidJavaClass cls;
    public static LuaFunction luaCallback;
    private static AndroidJavaClass Sdk_Class
    {
        get
        {
            if (cls == null)
            {
                cls = AndroidAPI.GetAndroidJavaClass(SDK_JAVA_CLASS);
            }
            return cls;
        }
    }

    /// <summary>
    ///额外配置的分区标识，通过ProjectIconSetting传入
    /// </summary>
    public static string ChannelAreaFlag { get; set; }

	//Unity初始化完成
	internal static void UnityInitFinish()
	{

#if UNITY_ANDROID && !UNITY_EDITOR
		//unity初始化完成，通知android层，android层去掉自绘闪屏
		callSdkApi("UnityInitFinish");
#endif
	}

    public static void Setup()
    {
#if UNITY_ANDROID
        //执行延后初始化处理
        callSdkApi("AfterInit");
#endif
    }

    private static void callSdkApi(string apiName, params object[] args)
    {
#if UNITY_ANDROID
		AndroidAPI.CallStatic(Sdk_Class, apiName, args);
#endif
    }

	public static void SetShenhe(bool bshenhe)
	{
#if UNITY_ANDROID
		//	没有
#elif UNITY_IPHONE
		__spsdk_shenhe(bshenhe);
#endif
	}

    public static void Init()
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("Init");
#elif UNITY_IPHONE
        __spsdk_init();
#endif
    }

    public static void Login()
    {
		//	登录账号
		LogMgr.SendLog (4);
#if UNITY_ANDROID
        Sdk_Class.CallStatic("Login");
#elif UNITY_IPHONE
        __spsdk_login();
#endif
    }

    public static void SwitchAccount()
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("SwitchAccount");
#elif UNITY_IPHONE
        __spsdk_login();
#endif
    }

    public static void Bind()
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("Bind");
#elif UNITY_IPHONE
        __spsdk_bind();
#endif
    }

    public static bool IsSupportLogout()
    {
#if UNITY_ANDROID
		return Sdk_Class.CallStatic<bool>("IsSupportLogout");
#elif UNITY_IPHONE
		return true;
#else
        return true;
#endif
    }

    public static bool Logout()
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("Logout");
#elif UNITY_IPHONE
        __spsdk_logout();
#endif
        return false;
    }


    public static bool DoExiter()
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("DoExiter");
#else
#endif
        return false;
    }

    public static void Exit()
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("Exit");
#endif
    }

    public static void Regster(string account, string uid)
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("Regster", account, uid);
#elif UNITY_IPHONE

#endif
    }

    public static void UpdateUserInfo(string uid)
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("UpdateUserInfo", uid);
#elif UNITY_IPHONE

#endif
    }

    public static void SubmitRoleData(string roleJson)
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("SubmitRoleData", roleJson);
#elif UNITY_IPHONE
        __spsdk_submitRoleData(roleJson);
#endif
    }

    public static void GainGameCoin(string jsonStr)
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("GainGameCoin", jsonStr);
#elif UNITY_IPHONE
        return;
#endif
    }

    public static void ConsumeGameCoin(string jsonStr)
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("ConsumeGameCoin", jsonStr);
#elif UNITY_IPHONE
        return;
#endif
    }

    public static string GetChannelId()
    {
#if UNITY_ANDROID
        return Sdk_Class.CallStatic<string>("GetChannelId");
#elif UNITY_IPHONE
        return __spsdk_getChannelId();
#endif
        return null;
    }

    public static string GetSubChannelId()
    {
#if UNITY_ANDROID
        return Sdk_Class.CallStatic<string>("GetSubChannelId");
#elif UNITY_IPHONE
        return __spsdk_getSubChannelId();
#endif
        return null;
    }

    public static string GetMutilPackageId()
    {
#if UNITY_ANDROID
        return Sdk_Class.CallStatic<string>("GetMutilPackageId");
#elif UNITY_IPHONE
        return "";
#endif
        return "";
    }

    /// <summary>
    /// 只有android的获取，留意
    /// </summary>
    /// <returns></returns>
    public static string GetGameId()
    {
        #if UNITY_ANDROID
        if (Sdk_Class != null)
        {
            return Sdk_Class.CallStatic<string>("GetGameId");
        }
#elif UNITY_IPHONE
        return "";
#endif
        return "";
    }

    public static string GetAppName()
    {
#if UNITY_ANDROID
        if (Sdk_Class != null)
        {
            return Sdk_Class.CallStatic<string>("GetAppName");
        }
#elif UNITY_IPHONE
        return __spsdk_getAppName();
#endif
        return "";
    }

    public static bool IsSupportUserCenter()
    {
#if UNITY_ANDROID
        return Sdk_Class.CallStatic<bool>("IsSupportUserCenter");
#elif UNITY_IPHONE
        return __spsdk_isSupportUserCenter();
#else
        return false;
#endif
    }


    public static void EnterUserCenter()
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("EnterUserCenter");
#elif UNITY_IPHONE
		__spsdk_enterUserCenter();
#else
        return;
#endif
    }


    public static bool IsSupportBBS()
    {
#if UNITY_ANDROID
        return Sdk_Class.CallStatic<bool>("IsSupportBBS");
#elif UNITY_IPHONE
        return __spsdk_isSupportBBS();
#else
        return false;
#endif
    }


    public static void EnterSdkBBS()
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("EnterSdkBBS");
#elif UNITY_IPHONE
		__spsdk_enterSdkBBS();
#else
        return;
#endif
    }

    public static bool IsSupportShowOrHideToolbar()
    {
#if UNITY_ANDROID
        return Sdk_Class.CallStatic<bool>("IsSupportShowOrHideToolbar");
#else
        return false;
#endif
    }


    public static void ShowFloatToolBar()
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("ShowFloatToolBar");
#else
        return;
#endif
    }

    public static void HideFloatToolBar()
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("HideFloatToolBar");
#else
        return;
#endif
    }

    public static void DoPay(string json)
    {
#if UNITY_ANDROID
        Sdk_Class.CallStatic("DoPay", json);
#elif UNITY_IPHONE
        __spsdk_pay(json);
#else
        return;
#endif
    }

    public static void SetLuaCallback(LuaFunction function)
    {
        if(luaCallback != null)
        {
            luaCallback.Dispose();
            luaCallback = null;
        }
        luaCallback = function;
    }

    public static void OnSdkCallback(string json)
    {
        // Debug.Log("OnSdkCallback json=" + json);
        if(luaCallback != null){
            luaCallback.BeginPCall();
            luaCallback.Push(json);
            luaCallback.PCall();
            luaCallback.EndPCall();
        }
    }

    public static void DoIosWechatAliPay(string payWay, string dataJson)
    {
#if UNITY_IPHONE
        try
        {
            GameDebug.Log("SPSDK.DoIosWechatAliPay payWay:" + payWay + " | dataJson:" + dataJson);
            __spsdk_payExt(payWay, dataJson);
        }
        catch (Exception e)
        {

        }
#endif
    }
}

using System;
using UnityEngine;

//using UnityEngine.UI;
using System.Collections;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public class TrackingIO: MonoBehaviour
{


	private static TrackingIO _instance = null;

	public static TrackingIO Instance {
		get {
			if (!_instance) {
				_instance = GameObject.FindObjectOfType (typeof(TrackingIO)) as TrackingIO;
				if (!_instance) {
					GameObject am = new GameObject ("TrackingIO");
					_instance = am.AddComponent (typeof(TrackingIO)) as TrackingIO;
				}
			}
			return _instance;           
		}
	}

	void Awake ()
	{
		DontDestroyOnLoad (this);
	}
#if UNITY_IOS

	[DllImport ("__Internal")]
	private static extern void __initTkioWithappKey (string appKey, string channelId);

	[DllImport ("__Internal")]
	private static extern void __setTkioRegisterWithAccountID (string account);

	[DllImport ("__Internal")]
	private static extern void __setTkioLoginWithAccountID (string account);

	[DllImport ("__Internal")]
	private static extern void __setTkioryzfStart (string transactionId, string ryzfType, string currencyType, float currencyAmount);

	[DllImport ("__Internal")]
	private static extern void __setTkioryzf (string transactionId, string ryzfType, string currencyType, float currencyAmount);

	[DllImport ("__Internal")]
	private static extern void __setTkioEvent (string EventName, string json);

	[DllImport ("__Internal")]
	private static extern void __setTkioProfile (string json);

	[DllImport ("__Internal")]
	private static extern string __getTkioDeviceId ();

	[DllImport ("__Internal")]
	private static extern void __setTkioPrintLog (bool print);
#endif

#if UNITY_ANDROID
	public static AndroidJavaObject getApplicationContext () {
		
		using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
		{
			using (AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
			{
				return jo.Call<AndroidJavaObject>("getApplicationContext");
			}
		}
		
		return null;
	}
#endif

    private bool isInitSuccess;
	/// <summary>
	/// 初始化方法   
	/// </summary>
	/// <param name="appId">appKey</param>
	/// <param name="channelId">标识推广渠道的字符</param>
	public void init (string appKey, string channelId)
	{

#if UNITY_IOS
        try
	    {
	        __initTkioWithappKey(appKey, channelId);
            isInitSuccess = true;
	    }
	    catch (Exception e)
	    {
	        isInitSuccess = false;
	    }
#endif

#if UNITY_ANDROID
        try
	    {
		    using (AndroidJavaClass TrackingIO = new AndroidJavaClass("com.reyun.sdk.TrackingIO")) {
			    TrackingIO.CallStatic ("initWithKeyAndChannelId", getApplicationContext(), appKey, channelId);
                isInitSuccess = true;
		    }
        }
        catch (Exception e)
	    {
	        isInitSuccess = false;
	    }
#endif

    }

    /// <summary>
    /// 玩家服务器注册
    /// </summary>
    /// <param name="account">账号ID</param>
    /// 
    public void register (string account)
    {
        if (!isInitSuccess)
            return;

#if UNITY_IOS
		__setTkioRegisterWithAccountID (account);
#endif

#if UNITY_ANDROID
		using (AndroidJavaClass TrackingIO = new AndroidJavaClass("com.reyun.sdk.TrackingIO")) {
			TrackingIO.CallStatic ("setRegisterWithAccountID", account);
		}
#endif

    }

    /// <summary>
    /// 玩家的账号登陆服务器
    /// </summary>
    /// <param name="account">账号</param>

    public void login (string account)
	{
        if (!isInitSuccess)
            return;

#if UNITY_IOS
		__setTkioLoginWithAccountID (account);
#endif

#if UNITY_ANDROID
		using (AndroidJavaClass TrackingIO = new AndroidJavaClass("com.reyun.sdk.TrackingIO")) {
			TrackingIO.CallStatic ("setLoginSuccessBusiness", account);
		}
#endif
    }

    /// <summary>
    /// 玩家开始充值数据
    /// </summary>
    /// <param name="transactionId">交易的流水号</param>
    /// <param name="paymentType">支付类型</param>
    /// <param name="currencyType">货币类型</param>
    /// <param name="currencyAmount">支付的真实货币的金额</param>

    public void setryzfStart (string transactionId, string ryzfType, string currencyType, float currencyAmount)
	{
        if (!isInitSuccess)
            return;

#if UNITY_IOS
		__setTkioryzfStart (transactionId, ryzfType, currencyType, currencyAmount);
#endif
#if UNITY_ANDROID

		using(AndroidJavaClass TrackingIO = new AndroidJavaClass ("com.reyun.sdk.TrackingIO"))
		{
			TrackingIO.CallStatic ("setPaymentStart", transactionId, ryzfType, currencyType, currencyAmount);
		}
#endif

    }

    /// <summary>
    /// 玩家的充值数据
    /// </summary>
    /// <param name="transactionId">交易的流水号</param>
    /// <param name="paymentType">支付类型</param>
    /// <param name="currencyType">货币类型</param>
    /// <param name="currencyAmount">支付的真实货币的金额</param>

    public void setryzf (string transactionId, string ryzfType, string currencyType, float currencyAmount)
	{
        if (!isInitSuccess)
            return;

#if UNITY_IOS
		__setTkioryzf (transactionId, ryzfType, currencyType, currencyAmount);
#endif

#if UNITY_ANDROID

		using(AndroidJavaClass TrackingIO = new AndroidJavaClass ("com.reyun.sdk.TrackingIO"))
		{
			TrackingIO.CallStatic ("setPayment", transactionId, ryzfType, currencyType, currencyAmount);
		}
#endif

    }

    /// <summary>
    /// 统计玩家的自定义事件
    /// </summary>
    /// <param name="eventName">事件名</param>

    public void setEvent (string eventName, Dictionary<string, string> dict)
	{
        if (!isInitSuccess)
            return;

#if UNITY_IOS
		if (dict == null) {
			__setTkioEvent (eventName, "{}");

		} else {
			int nLength = dict.Count;
			List<string> dicKey = new List<string> (dict.Keys);
			List<string> dicValue = new List<string> (dict.Values);
			string json = "{";
			for (int i = 0; i < nLength; i++) {
				string subKeyValue = "\"" + dicKey [i] + "\"" + ":" + "\"" + dicValue [i] + "\"";
				json += subKeyValue;
				if (i != nLength - 1) {
					json += ",";
				}
			}
			json += "}"; 
			__setTkioEvent (eventName, json);
		}

#endif

#if UNITY_ANDROID
		using(AndroidJavaClass TrackingIO = new AndroidJavaClass ("com.reyun.sdk.TrackingIO"))
		{
			TrackingIO.CallStatic ("setEvent", eventName);
		}
#endif
    }

    public void setProfile (Dictionary<string, string> dict)
	{
        if (!isInitSuccess)
            return;

#if UNITY_IOS
		if (dict == null) {
			__setTkioProfile ("{}");

		} else {
			int nLength = dict.Count;
			List<string> dicKey = new List<string> (dict.Keys);
			List<string> dicValue = new List<string> (dict.Values);
			string json = "{";
			for (int i = 0; i < nLength; i++) {
				string subKeyValue = "\"" + dicKey [i] + "\"" + ":" + "\"" + dicValue [i] + "\"";
				json += subKeyValue;
				if (i != nLength - 1) {
					json += ",";
				}
			}
			json += "}"; 
			__setTkioProfile (json);
		}
#endif

#if UNITY_ANDROID
		if (dict == null) {
			using (AndroidJavaClass reyun = new AndroidJavaClass ("com.reyun.sdk.TrackingIO")) {
				reyun.CallStatic ("setProfile", null);
			}
		} else {
			using (AndroidJavaClass reyun = new AndroidJavaClass ("com.reyun.sdk.TrackingIO")) {
				using (AndroidJavaObject obj_HashMap = new AndroidJavaObject ("java.util.HashMap")) {
					System.IntPtr method_Put = AndroidJNIHelper.GetMethodID (obj_HashMap.GetRawClass (), "put",
						                        "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
					object[] args = new object[2];
					foreach (KeyValuePair<string, string> kvp in dict) {
						using (AndroidJavaObject k = new AndroidJavaObject ("java.lang.String", kvp.Key)) {
							using (AndroidJavaObject v = new AndroidJavaObject ("java.lang.String", kvp.Value)) {
								args [0] = k;
								args [1] = v;
								AndroidJNI.CallObjectMethod (obj_HashMap.GetRawObject (),
									method_Put, AndroidJNIHelper.CreateJNIArgArray (args));

							}
						}
					}
					reyun.CallStatic ("setProfile", obj_HashMap);
				}
			}
		}
#endif
    }

    /// <summary>
    /// 获取用户的设备ID信息
    /// </summary>
    public string getDeviceId ()
	{
        if (!isInitSuccess)
            return "unkonow";

#if UNITY_IOS
		return __getTkioDeviceId ();
#endif

#if UNITY_ANDROID
		string str = "unkonow";

		using(AndroidJavaClass TrackingIO = new AndroidJavaClass ("com.reyun.sdk.TrackingIO"))
		{
			str = TrackingIO.CallStatic<string> ("getDeviceId");
		}
		return str;
#endif
        return "unknown";
	}

	/// 开启日志打印
	public void setPrintLog (bool print)
	{
        if (!isInitSuccess)
            return;

#if UNITY_IOS
		__setTkioPrintLog (print);
#endif
#if UNITY_ANDROID
		using(AndroidJavaClass reyunConst = new AndroidJavaClass ("com.reyun.common.TrackingIOConst"))
		{
			reyunConst.SetStatic <bool> ("DebugMode",print);
		}
#endif
    }
}


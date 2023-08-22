
using UnityEngine;


#if (UNITY_EDITOR || UNITY_IPHONE)
using System.Runtime.InteropServices;
#endif

public static class XinGeIOSSdk
{
#if UNITY_IPHONE
	public static string appid = "2200270181";
	public static string appKey = "IQQ1G7239ZXI";
#else
	public static string appid = "2100264708";
	public static string appKey = "A73FBBXE782K";
#endif

#if (UNITY_EDITOR || UNITY_IPHONE)
    [DllImport("__Internal")]
	private static extern void XGRegisterPush(string appId, string appKey);

	[DllImport("__Internal")]
	private static extern void XGRegisterDevice();

	[DllImport("__Internal")]
	private static extern void XGDebugEnable(bool enable);

	[DllImport("__Internal")]
	private static extern void XGRegisterDeviceWithAccount(string account);

	[DllImport("__Internal")]
	private static extern void XGSetTag(string tagName);

	[DllImport("__Internal")]
	private static extern void XGDelTag(string tagName);
#endif

	public static void Setup()
	{
#if (UNITY_EDITOR || UNITY_IPHONE)
//      var appId = "2100264708";
//		var appKey = "A73FBBXE782K";
//		XGRegisterPush(appId, appKey);
		UnityEngine.iOS.NotificationServices.RegisterForNotifications(UnityEngine.iOS.NotificationType.Alert | UnityEngine.iOS.NotificationType.Sound);
#endif
    }

    public static void Register()
    {
		//Objectc回调处理
    }


    public static void EnableDebug(bool enable)
    {
#if (UNITY_EDITOR || UNITY_IPHONE)
        XGDebugEnable(enable);
#endif
    }


    public static void RegisterWithAccount(string account)
    {
#if (UNITY_EDITOR || UNITY_IPHONE)
        XGRegisterDeviceWithAccount(account);
#endif
    }


	public static void SetTag(string tagName)
    {
#if (UNITY_EDITOR || UNITY_IPHONE)
        XGSetTag(tagName);
#endif
	}


	public static void DeleteTag(string tagName)
	{
#if (UNITY_EDITOR || UNITY_IPHONE)
        XGDelTag(tagName);
#endif
	}
}

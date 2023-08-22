
// 安卓常开，先简单处理
//#define ENABLE_XINGE

using UnityEngine;

public static class XinGeAndroidSdk
{

	private const string SDK_JAVA_CLASS = "com.xinge.XinGeBridge";

#if UNITY_EDITOR || UNITY_ANDROID
	private static AndroidJavaClass cls;
#endif

	public static void Setup()
	{
		Debug.Log("XinGeAndroidSdk:Setup 1");

#if UNITY_EDITOR || UNITY_ANDROID
		Debug.Log("XinGeAndroidSdk:Setup 2");
        cls = AndroidAPI.GetAndroidJavaClass(SDK_JAVA_CLASS);

        AndroidAPI.CallStatic(cls, "Setup", "2100264708", "A73FBBXE782K");
#endif
    }

    public static void EnableDebug(bool enable)
    {
#if UNITY_EDITOR || UNITY_ANDROID
        AndroidAPI.CallStatic(cls, "enableDebug", enable);
#endif
    }

    public static void Register()
	{
#if UNITY_EDITOR || UNITY_ANDROID
        AndroidAPI.CallStatic(cls, "RegisterPush");
#endif
	}

 
	public static void RegisterWithAccount(string account)
	{
#if UNITY_EDITOR || UNITY_ANDROID
        AndroidAPI.CallStatic(cls, "RegisterPushWithAccount", account);
#endif
	}

	public static void SetTag(string tagName)
	{
#if UNITY_EDITOR || UNITY_ANDROID
        AndroidAPI.CallStatic(cls, "SetTag", tagName);
#endif
	}

	public static void DeleteTag(string tagName)
	{
#if UNITY_EDITOR || UNITY_ANDROID
        AndroidAPI.CallStatic(cls, "DeleteTag", tagName);
#endif
	}

}

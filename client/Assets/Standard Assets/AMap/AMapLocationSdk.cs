using System.Collections;
using UnityEngine;

public class AMapLocationSdk 
{
#if UNITY_ANDROID && !UNITY_EDITOR
    private const string SDK_JAVA_CLASS = "com.amap.amapLocation.LBSLocationMain";
    private static AndroidJavaClass m_Cls;
#endif

    public static void Init() 
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        if (m_Cls == null){
            m_Cls = new AndroidJavaClass(SDK_JAVA_CLASS);
        }
        Debug.Log("Unity ------------ initLocation");
        AndroidJavaClass unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        AndroidJavaObject curActivity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
        m_Cls.CallStatic("initLocation", curActivity);
#endif
    }

    /**
     * 可选择设置
     * gpsFirst: bool
     * mode: string ( Hight_Accuracy | Device_Sensors | Battery_Saving)
     * timeOut: default 30000
     * interval: default 2000
     * needAddress: bool
     * killProcess: bool
     * once: bool
     * wifiScan: bool
     * cacheEnable: bool
     * onceLatest: bool
     * sensorEnable: bool
     */
    public static void SetLocationOption(string option)
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        Debug.Log("Unity -------- setLocationOption: " + option);
        m_Cls.CallStatic("setLocationOption", option);
#endif
    }

    public static string GetLocationOption()
    {
        string result = "";
#if UNITY_ANDROID && !UNITY_EDITOR
        result = m_Cls.CallStatic<string>("getLoctionOption");
#endif
        return result;
    }

    public static void SetLocationOptionDefatult()
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        Debug.Log("Unity ------------ setDefault");
        m_Cls.CallStatic("setDefaultOption");
#endif
    }

    public static void StartLocation() {
#if UNITY_ANDROID && !UNITY_EDITOR
        Debug.Log("Unity ------------ startLocation");
        m_Cls.CallStatic("startLocation");
#endif
    }

    public static void StopLocation() {
#if UNITY_ANDROID && !UNITY_EDITOR
        Debug.Log("Unity ------------ stopLocation");
        m_Cls.CallStatic("stopLocation");
#endif
    }

    //定位成功后释放
    public static void DestroyLocation() {
#if UNITY_ANDROID && !UNITY_EDITOR
        Debug.Log("Unity ----------- destroyLocation");
        m_Cls.CallStatic("destroyLocation");
#endif
    }
}

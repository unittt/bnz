using System;
using UnityEngine;
using System.IO;

public class AndroidAPI
{
    private const string SDK_JAVA_DeviceUtils = "com.cilugame.android.commons.DeviceUtils";
    private const string SDK_JAVA_AssetsUtils = "com.cilugame.android.commons.AssetsUtils";
    // private const string SDK_JAVA_YeSDKHelpUtils = "com.demiframe.game.api.ye.yeutils.YeSdkHelper";

    private static AndroidJavaClass SDK_DeviceUtils;
    private static AndroidJavaClass SDK_AssetsUtils;
    private static AndroidJavaClass SDK_YeSDKHelpUtils;
    private static AndroidJavaClass SDK_ZPHTemp;
    private static AndroidJavaClass SDK_PatchUtils;

    public static bool _powerRegistered = false;

    public static AndroidJavaClass GetAndroidJavaClass(string path)
    {
        if (Application.platform == RuntimePlatform.Android)
        {
            try
            {
                return new AndroidJavaClass(path);
            }
            catch (Exception e)
            {
                GameDebug.LogException(e);
            }
        }

        return null;
    }

    public static void CallStatic(AndroidJavaClass javaClass, string apiName, params object[] args)
    {
        if (Application.platform == RuntimePlatform.Android)
        {
            if (javaClass != null)
            {
                try
                {
                    javaClass.CallStatic(apiName, args);
                }
                catch (Exception e)
                {
                    GameDebug.LogException(e);
                }
            }
            else
            {
                GameDebug.LogError("Cannot find javaClass with " + apiName);
            }
        }
    }


    public static T CallStatic<T>(AndroidJavaClass javaClass, string apiName, params object[] args)
    {
        if (Application.platform == RuntimePlatform.Android)
        {
            if (javaClass != null)
            {
                try
                {
                    return javaClass.CallStatic<T>(apiName, args);
                }
                catch (Exception e)
                {
                    GameDebug.LogException(e);
                }
            }
            else
            {
                GameDebug.LogError("Cannot find javaClass with " + apiName);
            }
        }

        return default(T);
    }

    public static void Setup()
    {
        SDK_DeviceUtils = GetAndroidJavaClass(SDK_JAVA_DeviceUtils);
        SDK_AssetsUtils = GetAndroidJavaClass(SDK_JAVA_AssetsUtils);
        // SDK_YeSDKHelpUtils = GetAndroidJavaClass(SDK_JAVA_YeSDKHelpUtils);
    }

    public static void RestartGame()
    {
        CallStatic(SDK_DeviceUtils, "RestartGame", 0);
    }

    public static void GetPermisson()
    {
        CallStatic(SDK_DeviceUtils, "GetPermisson");
    }

    public static void CheckWriteExternalPermission()
    {
        CallStatic(SDK_DeviceUtils, "CheckWriteExternalPermission");
    }

    public static void RegisterPower()
    {
        if (_powerRegistered)
        {
            return;
        }
        _powerRegistered = true;

        CallStatic(SDK_DeviceUtils, "RegisterPower");
    }

    public static void UnregisterPower()
    {
        if (_powerRegistered == false)
        {
            return;
        }

        _powerRegistered = false;

        CallStatic(SDK_DeviceUtils, "UnregisterPower");
    }

    public static long getFreeMemory()
    {
        return CallStatic<long>(SDK_DeviceUtils, "getFreeMemory");
    }

    public static long getTotalMemory()
    {
        return CallStatic<long>(SDK_DeviceUtils, "getTotalMemory");
    }

    public static long getExternalStorageAvailable()
    {
        return CallStatic<long>(SDK_DeviceUtils, "getExternalStorageAvailable");
    }

    public static string getNetworkType()
    {
        return CallStatic<string>(SDK_DeviceUtils, "getNetworkType");
    }

    public static void RegisterGsmSignalStrength()
    {
        CallStatic(SDK_DeviceUtils, "RegisterGsmSignalStrength");
    }

    public static void UnregisterGsmSignalStrength()
    {
        CallStatic(SDK_DeviceUtils, "UnregisterGsmSignalStrength");
    }

    public static int getWifiSignal()
    {
        return CallStatic<int>(SDK_DeviceUtils, "getWifiSignal");
    }

    public static string getLocalMacAddress()
    {
        return CallStatic<string>(SDK_DeviceUtils, "getLocalMacAddress");
    }

    public static string getStorageInfos()
    {
        return CallStatic<string>(SDK_DeviceUtils, "getStorageInfos");
    }

    public static bool hasExternalStorage()
    {
        return CallStatic<bool>(SDK_DeviceUtils, "externalStorageAvailable");
    }

    public static string GetAndroidInternalPersistencePath()
    {
        return CallStatic<string>(SDK_DeviceUtils, "GetInternalPersistencePath");
    }

    public static string GetAndroidPersistencePath()
    {
        string p = Application.persistentDataPath;
        if (string.IsNullOrEmpty(p))
        {

            try
            {
                p = CallStatic<string>(SDK_DeviceUtils, "GetExternalPersistencePath");
            }
            catch (Exception e)
            {
                GameDebug.LogException(e);
            }

            if (!string.IsNullOrEmpty(p) && !Directory.Exists(p))
            {
                try { Directory.CreateDirectory(p); }
                catch { }
            }

            bool ok = (!string.IsNullOrEmpty(p) && Directory.Exists(p));

            if (!ok)
            {
                try
                {
                    p = CallStatic<string>(SDK_DeviceUtils, "GetInternalPersistencePath");
                }
                catch (Exception e)
                {
                    GameDebug.LogException(e);
                }
            }
        }
        return p;
    }

    public static void showSettingsInstallNonMarketApps()
    {
        CallStatic(SDK_DeviceUtils, "showSettingsInstallNonMarketApps");
    }

    public static string GetGetBundleId()
    {
        return CallStatic<string>(SDK_DeviceUtils, "GetBundleId");
    }

    public static string GetDeviceUID()
    {
        return CallStatic<string>(SDK_DeviceUtils, "getUUID");
    }

    public static string GetDeviceID()
    {
        return CallStatic<string>(SDK_DeviceUtils, "GetDeviceId");
    }

    public static string GetDeviceName()
    {
        return CallStatic<string>(SDK_DeviceUtils, "getDeviceName");
    }

    public static bool isAutoBrightness()
    {
        return CallStatic<bool>(SDK_DeviceUtils, "isAutoBrightness");
    }

    public static void stopAutoBrightness()
    {
        CallStatic(SDK_DeviceUtils, "stopAutoBrightness");
    }

    public static void startAutoBrightness()
    {
        CallStatic(SDK_DeviceUtils, "startAutoBrightness");
    }

    public static int getScreenBrightness()
    {
        return CallStatic<int>(SDK_DeviceUtils, "getScreenBrightness");
    }

    public static void setBrightness(int brightness)
    {
        CallStatic(SDK_DeviceUtils, "setBrightness", brightness);
    }

    public static void SetClipBoardText(string text)
    {
        CallStatic(SDK_DeviceUtils, "SetClipBoardText", text);
    }

    public static string GetClipBoardText()
    {
        return CallStatic<string>(SDK_DeviceUtils, "GetClipBoardText");
    }

    public static string getMetaData(string name)
    {
        return CallStatic<string>(SDK_AssetsUtils, "getMetaData", name);
    }

    // ysdk 下可用
    public static string getYeSDKExtra()
    {
        // return CallStatic<string>(SDK_YeSDKHelpUtils, "GetExtraMeta");
		return "";
    }

    // ysdk 下可用
    public static int getYeSDKChannelId()
    {
        // return CallStatic<int>(SDK_YeSDKHelpUtils, "GetChannelIdMeta");
		return 0;
    }

    public static void HideEditDialog()
    {
        CallStatic(SDK_DeviceUtils, "HideEditDialog");
    }

    public static void SetEditText(string text)
    {
        CallStatic(SDK_DeviceUtils, "SetEditText", text);
    }

    public static void ShowEditDialog(string text, UnityEditTextStyle style)
    {
        CallStatic(SDK_DeviceUtils, "ShowEditDialog", text, style.obj);
    }
}


using System;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using UnityEngine;
using System.IO;
using System.Runtime.InteropServices;

public class PlatformAPI : MonoBehaviour
{
    public static int BATTERY_STATUS_CHARGING = 2;
    public static int batteryLevelOfAndroid = 100;
    public static bool batteryChargingOfAndroid = false;

    public const string NET_STATE_NONE = "NONE";
    public const string NET_STATE_2G = "2G";
    public const string NET_STATE_3G = "3G";
	public const string NET_STATE_WIFI = "WIFI";
	
	public const string DEVICE_UNIQUE_IDENTIFIER_KEY = "demi-deviceUniqueIdentifier";

    public static void Setup()
    {
        GameObject go = GameObject.Find("PlatformAPI");
        if (go == null)
        {
            go = new GameObject("PlatformAPI");
            DontDestroyOnLoad(go);
            go.AddComponent<PlatformAPI>();
        }
#if UNITY_ANDROID
        AndroidAPI.Setup();
#endif
    }

    public static void Init()
    {
        RegisterPower();
    }

    public static void Release()
    {
        UnregisterPower();
    }


    public static void RestartGame()
    {
#if UNITY_EDITOR
#elif UNITY_ANDROID
        AndroidAPI.RestartGame();
#elif UNITY_STANDALONE
        var curApp = System.Diagnostics.Process.GetCurrentProcess();
        System.Diagnostics.Process.Start(curApp.ProcessName + ".exe");
        Application.Quit();
#endif
    }

    public static int GetBatteryLevel()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return 100;
#elif UNITY_ANDROID
		return batteryLevelOfAndroid;
#elif UNITY_IPHONE
		return IosAPI.GetBatteryLevel();
#else
		return 100;
#endif
    }

    public static bool IsBattleCharging()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return false;
#elif UNITY_ANDROID
		return batteryChargingOfAndroid;
#elif UNITY_IPHONE
		return IosAPI.IsBattleCharging();
#else
		return false;
#endif
    }

    public static void RegisterPower()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return;
#elif UNITY_ANDROID
        AndroidAPI.RegisterPower(); 
#else
        return;
#endif
    }

    public static void UnregisterPower()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return;
#elif UNITY_ANDROID
        AndroidAPI.UnregisterPower(); 
#else
        return;
#endif
    }

    public static long getFreeMemory()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return 0;
#elif UNITY_ANDROID
        return AndroidAPI.getFreeMemory(); 
#elif UNITY_IPHONE
		return (long)IosAPI.GetFreeMemory();
#else
        return 0;
#endif
    }

    public static long getTotalMemory()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return 0;
#elif UNITY_ANDROID
        return AndroidAPI.getTotalMemory();
#elif UNITY_IPHONE
		return (long)IosAPI.GetTotalMemory();
#else
		return 0;
#endif
    }

    public static long getExternalStorageAvailable()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return 0;
#elif UNITY_ANDROID
        return AndroidAPI.getExternalStorageAvailable();
#elif UNITY_IPHONE
		long freeDisk = (long)IosAPI.GetFreeDiskSpaceInBytes ( );
		return freeDisk >> 10;
#else
		return 0;
#endif
    }

    /**
     * <pre>
     * 获取网络类型
     * 无网络: NONE
     * 未知类型: UNKNOWN
     * WIFI: WIFI
     * 2G: 2G
     * 3G: 3G
     * 4G: 4G
     * </pre>
     * @return 网络类型标识
     */
    public static string getNetworkType()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE || UNITY_IPHONE)
        NetworkReachability ability = Application.internetReachability;

        if (ability == NetworkReachability.NotReachable)
        {
            return NET_STATE_NONE;
        }
        else if (ability == NetworkReachability.ReachableViaLocalAreaNetwork)
        {
            return NET_STATE_WIFI;
        }
        else
        {
            return NET_STATE_3G;
        }
#elif UNITY_ANDROID
        return AndroidAPI.getNetworkType();
#else
        return NET_STATE_WIFI;
#endif
    }

    public static int getWifiSignal()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return 100;
#elif UNITY_ANDROID
        return AndroidAPI.getWifiSignal();
#elif UNITY_IPHONE
		return 100;
#else
		return 100;
#endif
    }

    /**
     * 获取本机网卡Mac地址
     * @return
     */
    public static string getLocalMacAddress()
    {
#if UNITY_EDITOR || UNITY_STANDALONE || UNITY_IPHONE
        try
        {
            var interfaces = NetworkInterface.GetAllNetworkInterfaces();
            for (int i = 0; i < interfaces.Length; i++)
            {
                var inter = interfaces[i];
                if (!string.IsNullOrEmpty(inter.GetPhysicalAddress().ToString()))
                {
                    var mac = inter.GetPhysicalAddress().ToString();
                    for (int j = mac.Length - 1 - 1; j >= 1; j = j - 2)
                    {
                        mac = mac.Insert(j, "-");
                    }
                    return mac;
                }
            }
        }
        catch (Exception e)
        {
            GameDebug.LogException(e);
        }
#elif UNITY_ANDROID
        return AndroidAPI.getLocalMacAddress();
#endif
        return "111-11-11-111";
    }

    /**
     * 取sdcard容量与本机容量, 返回字符串(sdcard容量|手机容量)
     * @return
     */
    public static string getStorageInfos()
    {
        GameDebug.Log("Unity3D getStorageInfos calling.....");
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return "1|1";

#elif UNITY_ANDROID
        return AndroidAPI.getStorageInfos();
#elif UNITY_IPHONE
		long freeDisk = (long)IosAPI.GetFreeDiskSpaceInBytes ( );
		freeDisk >>= 10;
		return "0|" + freeDisk.ToString( );
#else
		return "1|1";
#endif
    }

    public static string GetAndroidInternalPersistencePath()
    {
#if UNITY_EDITOR
#elif UNITY_ANDROID
        return AndroidAPI.GetAndroidInternalPersistencePath();
#endif
        return string.Empty;
    }

    //获取安装包ID
    public static string GetBundleId()
    {
#if UNITY_EDITOR
		return "pc";
#elif UNITY_STANDALONE
        return "pc";
#elif UNITY_ANDROID
        try
        {
            return AndroidAPI.GetGetBundleId();
        }
        catch (Exception e)
        {
            Debug.LogException(e);
            return "";
        }
#elif UNITY_IPHONE
        return IosAPI.GetBundleId();
#else
        return "";
#endif
    }

    public static string GetDeviceUID()
    {
        string uuid = null;
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
            uuid = IosAPI.GetKeychainDarta(DEVICE_UNIQUE_IDENTIFIER_KEY);
            if (uuid == null || uuid.Equals(""))
            {
                uuid = SystemInfo.deviceUniqueIdentifier;
                if (uuid != null && uuid.Equals("") == false)
                    IosAPI.SaveKeychainData(DEVICE_UNIQUE_IDENTIFIER_KEY, uuid);
            }
        }
        else
        {
            uuid = SystemInfo.deviceUniqueIdentifier;
        }
            
         

        Debug.Log("Unity3D getUUID = " + uuid);

        return uuid;

//#if (UNITY_EDITOR || UNITY_STANDALONE)
//      return SystemInfo.deviceUniqueIdentifier;
//#elif UNITY_ANDROID
//      if (SDK_DeviceUtils != null)
//      {
//          return AndroidAPI.GetDeviceUID();
//      }
//      else
//      {
//      return SystemInfo.deviceUniqueIdentifier;
//      }
//#elif UNITY_IPHONE
//      return SystemInfo.deviceUniqueIdentifier;
//#else
//      return SystemInfo.deviceUniqueIdentifier;
//#endif
    }

    //获取手机唯一设备ID， 安卓是IMEI， ios是ADID
    //注意0.6.0及之前的版本包，可能会返回null
    public static string GetDeviceId()
    {
        #if UNITY_EDITOR
        return "";
#elif UNITY_STANDALONE
        return "";
#elif UNITY_ANDROID
        try
        {
            return AndroidAPI.GetDeviceID();
        }
        catch (Exception e)
        {
        Debug.LogException(e);
        return "";
        }
#elif UNITY_IPHONE
        return IosAPI.GetAdId();
#else
        return "";
#endif
    }

    public static string GetIdfv()
    {
#if UNITY_EDITOR
        return "";
#elif UNITY_STANDALONE
        return "";
#elif UNITY_ANDROID
        return "";
#elif UNITY_IPHONE
        return IosAPI.GetIdfv();
#else
        return "";
#endif
    }

    public static string GetDeviceName()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return SystemInfo.deviceName;
#elif UNITY_ANDROID
        return AndroidAPI.GetDeviceName();
#elif UNITY_IPHONE
        return SystemInfo.deviceName;
#else
        return SystemInfo.deviceName;
#endif   
    }

    /**
    * 获取当前屏幕亮度
    */
    public static int getScreenBrightness()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return 255;
#elif UNITY_ANDROID
        return AndroidAPI.getScreenBrightness();
#elif UNITY_IPHONE
		return IosAPI.GetBrightness(); 
#else
		return 255;
#endif
    }


    /**
        * 省电模式,设置亮度
        */
    public static void setBrightness(int brightness)
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return;
#elif UNITY_ANDROID
        AndroidAPI.setBrightness(brightness);
#elif UNITY_IPHONE
		IosAPI.SetBrightness(brightness);
#else
		return;
#endif
    }

    //设置剪贴板

    public static void SetClipBoardText(string text)
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        GUIUtility.systemCopyBuffer = text;
#elif UNITY_ANDROID
        AndroidAPI.SetClipBoardText(text);
#elif UNITY_IPHONE
		IosAPI.CopyToClipboard(text);
#else
		return;
#endif
    }


    public static string GetClipBoardText()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return GUIUtility.systemCopyBuffer;
#elif UNITY_ANDROID
        return AndroidAPI.GetClipBoardText();
#else
		return null;
#endif
    }


    public void OnPower(string value)
    {
        int intValue = 0;
        int.TryParse(value, out intValue);
        int status = intValue / 1000;
        int power = intValue % 1000;
        //GameDebug.Log("OnPower:" + power);
        if (status == BATTERY_STATUS_CHARGING)
        {
            PlatformAPI.batteryChargingOfAndroid = true;
        }
        else
        {
            PlatformAPI.batteryChargingOfAndroid = false;
        }

        PlatformAPI.batteryLevelOfAndroid = power;
    }

    /// <summary>
    /// Raises the XG register result event.
    /// </summary>
    /// <param name="flag">Flag.  0 success   1 fail</param>
    public void OnXGRegisterResult(string flag)
    {
        string json = "{\"type\":\"XGRegisterResult\",\"code\":\"0\",\"data\":"+flag+"}";
        GameDebug.Log("OnXGRegisterResult json=" + json);
        SPSDK.OnSdkCallback(json);
    }



    /// Raises the XG register result event.
    /// </summary>
    /// <param name="flag">Flag.  0 success   1 fail</param>
    public void OnXGRegisterWithAccountResult(string flag)
    {
        string json = "{\"type\":\"XGRegisterWithAccountResult\",\"code\":\"0\",\"data\":"+flag+"}";
        GameDebug.Log("OnXGRegisterWithAccountResult json=" + json);
        SPSDK.OnSdkCallback(json);

        //0 success  1 fail
        //ServiceRequestAction.requestServer(PlayerService.pigeon(GameSetting.BundleId, info.data == "0", GameSetting.PlatformTypeId));
    }

    public void OnSdkCallback(string json)
    {
        SPSDK.OnSdkCallback(json);
    }

    public void OnInputTextChanged(string text)
    {
        UnityEditDialog.OnInputTextChanged(text);
    }

    public void OnInputReturn()
    {
        UnityEditDialog.OnInputReturn();
    }

    public void OnEditDialogShow()
    {
        UnityEditDialog.OnDialogShow();
    }

    public void OnEditDialogHide()
    {
        UnityEditDialog.OnDialogHide();
    }

    public void OnSoftInputHeight(string height)
    {
        UnityEditDialog.OnSoftInputHeight(height);
    }

    public void OnLocationResult(string result)
    {
        string json = "{\"type\":\"LocationResult\",\"code\":\"0\",\"data\":" + result + "}";
        GameDebug.Log("OnLocationResult json=" + json);
        SPSDK.OnSdkCallback(json);
    }
}

using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.IO;


public class IosAPI
{
#if UNITY_EDITOR || UNITY_IPHONE
    [DllImport("__Internal")]
    private static extern string __getValueFromInfoPlist(string keyPath);

    [DllImport("__Internal")]
    private static extern void __copyToClipboard(string value);

    [DllImport("__Internal")]
    private static extern void _XcodeLog(string message);

    [DllImport("__Internal")]
    private static extern uint _GetFreeMemory();

    [DllImport("__Internal")]
    private static extern uint _GetTotalMemory();

    [DllImport("__Internal")]
    private static extern float _GetTotalDiskSpaceInBytes();

    [DllImport("__Internal")]
    private static extern float _GetFreeDiskSpaceInBytes();

    [DllImport("__Internal")]
    private static extern bool _IsBattleCharging();

    [DllImport("__Internal")]
    private static extern float _GetBatteryLevel();

    [DllImport("__Internal")]
    private static extern float _ExcludeFromBackupUrl(string url);

    [DllImport("__Internal")]
    private static extern void saveToGallery(string path);

    [DllImport("__Internal")]
    private static extern float _GetBrightness();

    [DllImport("__Internal")]
	private static extern void _SetBrightness(float brightness);
	
	[DllImport("__Internal")]
	private static extern string _GetBundleId ();

	[DllImport("__Internal")]
	private static extern string _GetAdId ();

	[DllImport("__Internal")]
	private static extern string _GetIdfv ();

    [DllImport("__Internal")]
    private static extern void _SaveKeychainData(string key,string data);
    [DllImport("__Internal")]
    private static extern string _GetKeychainData(string key);

#endif

    public static string GetValueFromInfoPlist(string keyPath)
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            return __getValueFromInfoPlist(keyPath);
#endif
        }

        return null;
    }

    public static void CopyToClipboard(string value)
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            __copyToClipboard(value);
#endif
        }
    }

    public static void XCodeLog(string message)
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            _XcodeLog(message);
#endif
        }
    }
    //in Kbytes
    public static uint GetFreeMemory()
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            return _GetFreeMemory();
#endif
        }
        return 0;
    }

    //in Kbytes
    public static uint GetTotalMemory()
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            return _GetTotalMemory();
#endif
        }
        return 0;
    }

    public static float GetTotalDiskSpaceInBytes()
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            return _GetTotalDiskSpaceInBytes();
#endif
        }
        return 0f;
    }

    public static float GetFreeDiskSpaceInBytes()
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            return _GetFreeDiskSpaceInBytes();
#endif
        }
        return 0f;
    }

    public static int GetBatteryLevel()
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            float level = _GetBatteryLevel();
            return (int)level;
#endif
        }
        return 100;
    }

    public static bool IsBattleCharging()
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            return _IsBattleCharging();
#endif
        }
        return false;
    }

    public static void ExcludeFromBackupUrl(string url)
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            UnityEngine.iOS.Device.SetNoBackupFlag(url);
#endif
        }
    }

    public static void SaveToGallery(string path)
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            saveToGallery(path);
#endif
        }
    }

    public static int GetBrightness()
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            float iosBrightness = _GetBrightness();
            GameDebug.Log("GetBrightness " + iosBrightness);
            return (int)(iosBrightness * 255f);
#endif
        }
        return 255;
    }

    public static void SetBrightness(int brightness)
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            float iosBrightness = (float)brightness / 255f;
            GameDebug.Log("SetBrightness " + iosBrightness);
            _SetBrightness(iosBrightness);
#endif
        }
	}
	
	public static string GetBundleId ()
	{
		if ( Application.platform == RuntimePlatform.IPhonePlayer )
		{
#if UNITY_EDITOR || UNITY_IPHONE
			return _GetBundleId();
#endif
		}
		return "";
	}

    public static string GetAdId()
    {
        if ( Application.platform == RuntimePlatform.IPhonePlayer )
        {
#if UNITY_EDITOR || UNITY_IPHONE
            return _GetAdId();
#endif
        }
        return "";
    }

    public static string GetIdfv()
    {
        if ( Application.platform == RuntimePlatform.IPhonePlayer )
        {
#if UNITY_EDITOR || UNITY_IPHONE
            return _GetIdfv();
#endif
        }
        return "";
    }

    public static void SaveKeychainData(string key, string data)
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            _SaveKeychainData(key, data);
#endif
        }
    }
    
    public static string GetKeychainDarta(string key)
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
#if UNITY_EDITOR || UNITY_IPHONE
            return _GetKeychainData(key);
#endif
        }
        return "";
    }

}

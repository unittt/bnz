using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor.XCodeEditor;


public static class XCFileChecker
{
    private static SPChannel _curChannel;

    private static readonly string[] _modSortArray =
    {
        "ShareSDK",
    };

    /// <summary>
    /// 初始化
    /// </summary>
    public static void InitModeDict()
    {
        GameSettingData settingData = GameSetting.LoadGameSettingData();
        ChannelConfig channelData = ChannelConfig.LoadChannelConfig(settingData.configSuffix);
        _curChannel = channelData._spChannelDic[GameSetting.LoadGameSettingData().channel];
    }


    /// <summary>
    /// 某些mod排在后面比较方便
    /// 如果有需要排在前面的，再进行重构
    /// </summary>
    /// <param name="mods"></param>
    public static void SortMods(ref string[] mods)
    {
        if (mods != null && mods.Length > 1)
        {
            var modList = mods.ToList();
            modList.Sort(CompareMod);
            mods = modList.ToArray();
        }
    }

    private static int CompareMod(string mod1, string mod2)
    {
        return Array.IndexOf(_modSortArray, Path.GetFileNameWithoutExtension(mod1)).CompareTo(Array.IndexOf(_modSortArray, Path.GetFileNameWithoutExtension(mod2)));
    }


    /// <summary>
    /// 检查哪些需要应用
    /// </summary>
    /// <param name="file"></param>
    /// <returns></returns>
    public static bool CheckApplyMod(string file)
    {
        if (file.Contains(_curChannel.projmods) ||
            file.Contains("https.projmods") ||
            // file.Contains("ShareSDK.projmods") ||
            file.Contains("ImagePicker.projmods") ||
			file.Contains("XinGeSDK.projmods")
		)
        {
            return true;
        }

        if (file.Contains("TdAdSDK.projmods") &&
            (_curChannel.symbol != null &&
            _curChannel.symbol.Contains("ENABLE_TDAD")))
        {
            return true;
        }

        if (file.Contains("iosNativeSDK.projmods") &&
            (_curChannel.symbol != null &&
            _curChannel.symbol.Contains("IOSNATIVE_ENABLED")))
        {
            return true;
        }

        if (file.Contains("XinGeSDK.projmods") &&
            (_curChannel.symbol != null &&
            _curChannel.symbol.Contains("ENABLE_XINGE")))
        {
            return true;
        }

        return false;
    }

    /// <summary>
    /// 不可以使用宏，否则会跪
    /// </summary>
    /// <param name="path"></param>
    /// <returns></returns>
    public static bool CheckAddFile(string path)
    {
        if (path.Contains("extends/WeChatSDK/libWeChatSDK.a") &&
            (_curChannel.projmods.Contains("tbtSDK") ||
            _curChannel.projmods.Contains("hmSDK") ||
            _curChannel.projmods.Contains("i4SDK") ||
            _curChannel.projmods.Contains("itoolsSDK") ||
            _curChannel.projmods.Contains("pywSDK") ||
            _curChannel.projmods.Contains("xySDK")))
        {
            return false;
        }

        return true;
    }


    /// <summary>
    /// 编辑代码
    /// </summary>
    /// <param name="filePath"></param>
    public static void EditCode(string filePath)
    {
        string.Format("{0}", "ken");
        XClass UnityAppController = new XClass(filePath + "/Classes/UnityAppController.mm");

        if (_curChannel.symbol != null && _curChannel.symbol.Contains("ENABLE_XINGE"))
        {
            UnityAppController.WriteBelow(@"PluginBase/AppDelegateListener.h", "\n#include \"XGPush.h\"\n#include \"XinGeIOSPlugin.h\"\n");

			UnityAppController.WriteBelow (
				"UnitySendDeviceToken(deviceToken);",
				string.Format("\n\t[XGPush startApp:{0} appKey:@\"{1}\"];", XinGeIOSSdk.appid, XinGeIOSSdk.appKey)+
				"\n\t[XinGeIOSPlugin SetDeviceToken:deviceToken];" +
				"\n\tNSString *deviceTokenStr = [XGPush registerDevice:deviceToken account:nil successCallback:nil errorCallback:nil];"+
				"\n\tNSLog(@\"[Xinge] device token is %@\", deviceTokenStr);");

            UnityAppController.WriteBelow(
                "[self preStartUnity];",
                "\n\t[XGPush handleLaunching:launchOptions successCallback:nil errorCallback:nil];");

            UnityAppController.WriteBelow(
                "UnitySendRemoteNotification(userInfo);",
                "\n\t[XGPush handleReceiveNotification:userInfo successCallback:nil errorCallback:nil];");
        }

        // 修复AirPlay；Unity在5.6.5.p3，2017.3.?，2018.1.?修复
        var displayManager = new XClass(filePath + "/Classes/Unity/DisplayManager.mm");
        displayManager.Replace("[[NSNotificationCenter defaultCenter]", "/* [[NSNotificationCenter defaultCenter]");
        displayManager.Replace("object:nil\n\t\t];", "object:nil\n\t\t]; */");
    }
}

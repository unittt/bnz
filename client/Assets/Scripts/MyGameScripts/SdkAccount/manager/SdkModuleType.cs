using System;
using System.Collections.Generic;

public class SdkModuleType
{
    public enum ModuleType
    {
        SmallArea,//应用于小区域的打开、关闭动画
        BigArea,
    }

    private static readonly Dictionary<string, ModuleType> _moduleTypeDict = new Dictionary<string, ModuleType>()
    {
        { SdkBindView.NAME, ModuleType.SmallArea},
        { SdkBindCodeView.NAME, ModuleType.SmallArea},
        { SdkBindConfirmView.NAME, ModuleType.SmallArea},
        { SdkFindPasswordView.NAME, ModuleType.SmallArea},
        { SdkFindPasswordConfirmView.NAME, ModuleType.SmallArea},
        { SdkQuickLoginView.NAME, ModuleType.SmallArea},
        { SdkPlatformLoginView.NAME, ModuleType.SmallArea},
        { SdkPlatformRegisterView.NAME, ModuleType.SmallArea},
        { SdkRegisterConfirmView.NAME, ModuleType.SmallArea},
        { SdkSelectLoginView.NAME, ModuleType.SmallArea},
        { SdkDeviceNotice.NAME, ModuleType.SmallArea },

        { SdkGameCenterView.NAME, ModuleType.BigArea},
        { SdkModifyPasswordView.NAME, ModuleType.BigArea},
        { SdkModifyPasswordConfirmView.NAME, ModuleType.BigArea},
        { SdkOfficialView.NAME, ModuleType.BigArea },//实际大小并不完全符合是BigArea
    };

    public static ModuleType GetModuleType(string name)
    {
        if (_moduleTypeDict.ContainsKey(name))
            return _moduleTypeDict[name];

        return ModuleType.SmallArea;
    }
}

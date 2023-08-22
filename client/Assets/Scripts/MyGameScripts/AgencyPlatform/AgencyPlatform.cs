public class AgencyPlatform
{
    //ciluSDK 免密登陆开发用
    public static string Channel_Appstore = "appstore";

	//ciluSDK 免密登陆开发用
    public static string Channel_cilugame = "nucleus";

    //demiSDK 免密登陆开发用
    public static string Channel_demi = "demi";

    public static string Channel_sm = "sm";

    //手盟自运营渠道
    public static string Channel_shoumengself = "shoumeng";

    //畅梦渠道
    public static string Channel_nb = "deminb";

    //鲸旗ios渠道
    public static string Channel_jingqi1 = "jingqi1";

    public static bool IsDemiChannel()
    {
        return GameSetting.Channel == Channel_demi &&
               (GameSetting.SubChannel == Channel_demi ||
                GameSetting.SubChannel == "0");
    }

    public static bool IsSmPcChannel()
    {
        return GameSetting.Channel == Channel_sm
            && GameSetting.IsOriginWinPlatform;
    }

    public static bool IsSmChannel()
    {
        return GameSetting.Channel == Channel_sm;
    }

    public static bool IsDemiNBSdk()
    {
        return GameSetting.Channel == Channel_demi && GameSetting.SubChannel == Channel_nb;
    }

    public static bool IsIosJingqiSdk()
    {
        return GameSetting.Channel == Channel_demi && GameSetting.SubChannel == Channel_jingqi1;
    }

    public static bool IsMutiPackageNull()
    {
        return string.IsNullOrEmpty(GameSetting.MutilPackageId);
    }
}

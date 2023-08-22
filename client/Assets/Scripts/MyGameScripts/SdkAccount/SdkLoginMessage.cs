using System;

/// <summary>
/// 所有与游戏层的交互都通过此类(SdkLoginMessageBase, SdkLoginMessage)进行
/// </summary>
class SdkLoginMessage : SdkLoginMessageBase
{
    public static readonly SdkLoginMessage Instance = new SdkLoginMessage();

    public override void Sdk2CLogin(bool bGuest, string sid)
    {
        //非扫码登录
        LoginManager.Instance.IsQrLogin = false;

        SPSdkManager.Instance.CallbackLoginSuccess(false, sid);
    }

    public override void Sdk2CLogout()
    {
        //SPSdkManager.Instance.CallbackLogout(true);
        //游戏层销毁成功后需回发成功给sdk端

        ExitGameScript.Instance.DoReloginAccount();

    }

    public override void Sdk2CReLogin()
    {
        //xxj begin
        //ExitGameScript.Instance.DoReloginAccount();
        //xxj end
    }

    /// <summary>
    /// 重新执行登录，主要为了处理返回扫码登录
    /// </summary>
    public override void Sdk2CLoginForQR()
    {
        //xxj begin
        //SPSdkManager.Instance.Login();
        //xxj end

        GameDebuger.Log("SdkLoginMessage Sdk2CLoginForQR");

        if (GameSetting.QRcodeLogin)
        {
            // 刷新一下数据
            WinGameSetting.Setup(WinGameSetting.WinGameSettingData.CreateOriginWinGameSettingData(),
                () =>
                {
                    //xxj begin
                    //ProxyQRCodeModule.OpenQRCodeLoginView();
                    //xxj end

                    string dataJson = "{}";
                    string json = "{\"type\":\"login2Show\",\"code\":\"0\",\"data\":" + dataJson + "}";
                    GameDebug.Log("login json=" + json);
                    SPSDK.OnSdkCallback(json);
                },
                error =>
                {
                    ProxyWindowModule.OpenMessageWindow(error, null, Sdk2CLoginForQR);
                });
        }
        //xxj begin
        //else if (GameSetting.Channel == AgencyPlatform.Channel_cilugame || GameSetting.GMMode)
        //{
        //    ProxyLoginModule.OpenTestSdk();
        //}
        //xxj end
        else if (SPSdkManager.Instance.IsDemiChannel())
        {
            SdkLoginMessage.Instance.C2SdkLogin();
        }
        else
        {
            //xxj begin
            //#if (UNITY_EDITOR || UNITY_STANDALONE)
            //            OnLoginFail();
            //#elif UNITY_ANDROID || UNITY_IPHONE
            //			WaitingLoginResult = true;
            //			SPSDK.Login();
            //#else
            //xxj end
            
            SPSdkManager.Instance.CallbackLoginFail();

            //xxj begin
            //#endif
            //xxj end
        }
    }

    public override int GetGameID()
    {
        //H7游戏ID
        return GameSetting.APP_ID;
    }

    /// <summary>
    /// 控制Sdk UI的层次为最高
    /// 若游戏的最高的Layer高于此，请修改
    /// </summary>
    /// <returns></returns>
    public override int GetLayer()
    {
        return GameSetting.DEMI_SDK_UILayer;
    }

    /// <summary>
    /// 游戏是否支持扫码登录（PC端），是的话屏蔽QQ登录按钮
    /// </summary>
    /// <returns></returns>
    public override bool GetIsSupportQRLogin()
    {
        return GameSetting.QRcodeLogin;
    }
}

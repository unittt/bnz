using System;
using UnityEngine;

public abstract class SdkLoginMessageBase
{
    /// <summary>
    /// 登录成功
    /// </summary>
    /// <param name="bGuest">是否是设备号登录</param>
    /// <param name="sid"></param>
    public abstract void Sdk2CLogin(bool bGuest, string sid);


    /// <summary>
    /// SDK登出
    /// </summary>
    public abstract void Sdk2CLogout();

    /// <summary>
    /// 切换账号, 游戏内做清除工作并返回到登录场景
    /// </summary>
    public abstract void Sdk2CReLogin();

    /// <summary>
    /// 重新执行登录，主要为了处理返回扫码登录
    /// </summary>
    public abstract void Sdk2CLoginForQR();

    /// <summary>
    /// 设置LoginSDK的UI根结点
    /// </summary>
    /// <param name="root"></param>
    public void C2SdkInitRoot(GameObject root)
    {
        SdkModuleMgr.Instance.InitRoot(root);
    }

    /// <summary>
    /// 打开登录界面
    /// </summary>
    public void C2SdkLogin()
    {
        SdkProxyModule.ClearModule();
        SdkProxyModule.OpenLogin();
    }

    /// <summary>
    /// 打开绑定界面
    /// </summary>
    public void C2SdkBind()
    {
        SdkProxyModule.OpenBind();
    }

    /// <summary>
    /// 打开用户中心
    /// </summary>
    public void C2SdkUserCenter()
    {
        SdkProxyModule.OpenGameCenter();
    }

    public bool IsSupportUserCenter()
    {
        return true;
    }

    public void C2SdkEnterBBS()
    {
        SdkProxyModule.OpenBBS();
    }

    public bool IsSupportBBS()
    {
        return true;
    }

    public void C2SdkLogout()
    {
        SdkAccountModel.Instance.Game2Logout();
    }

    public void C2SdkRegister()
    {
        //不处理
        return;
    }

    public string GetServerUrl()
    {
        return GameSetting.DEMISDK_SERVER;
    }

    /// <summary>
    /// 注册
    /// </summary>
    /// <returns></returns>
    public string GetRegistUrl()
    {
        return GetServerUrl() + "/sdkc/account/register.json";
    }

    public string GetFindPasswordUrl()
    {
        return GetServerUrl() + "/sdkc/account/findPassword.json";
    }

    public string GetModifyPasswordUrl()
    {
        return GetServerUrl() + "/sdkc/account/updatePassword.json"; ;
    }

    public string GetLoginUrl()
    {
        return GetServerUrl() + "/sdkc/account/login.json";
    }

    public string GetBoundUrl()
    {
        return GetServerUrl() + "/sdkc/account/bound.json";
    }
    
    //实名制
    public string GetNameAuthedUrl()
    {
        return GetServerUrl() + "/sdkc/account/realNameAuth.json";
    }

    public string GetCheckSessionUrl()
    {
        return GetServerUrl() + "/sdkc/account/checkSession.json";
    }

    public string GetQQLoginUrl()
    {
        return GetServerUrl() + "/sdkc/account/qqlogin";
    }

    /// <summary>
    /// 获取手机验证码
    /// </summary>
    /// <returns></returns>
    public string GetPhoneCodeUrl()
    {
        return GetServerUrl() + "/sdkc/account/phoneVerifyCode.json";
    }

    /// <summary>
    /// 获取发送验证码url，做账号的手机绑定
    /// </summary>
    /// <returns>The send verify code URL.</returns>
    public string GetSendVerifyCodeUrl()
    {
        return GetServerUrl() + "/sdkc/account/smsCode.json";
    }

    /// <summary>
    /// 获取绑定手机号码
    /// </summary>
    /// <returns>The send verify code URL.</returns>
    public string GetBindMobileNum()
    {
        return GetServerUrl() + "/sdkc/account/showPhone.json";
    }

    public string GetChannelExtUrl()
    {
        return GetServerUrl() + "/sdkc/area/info.json";
    }

    public string GetEnterBBSUrl()
    {
        return GetServerUrl() + "/sdkc/ucenter/enterbbs";
    }

    public string GetUUID()
    {
        //xxj begin
        //return BaoyugameSdk.getUUID();
        //xxj end
        return PlatformAPI.GetDeviceUID();
    }

    public void GetPay()
    {

    }

    /// <summary>
    /// 获取项目游戏ID
    /// </summary>
    public abstract int GetGameID();
    public abstract int GetLayer();

    public virtual bool GetIsSupportQRLogin()
    {
        return false;
    }

    //是否已实名制
    public bool IsRealAuth()
    {
        return SdkAccountModel.Instance.IsRealAuth();
    }

    //是否忽略实名制
    public bool IsIngotAuth()
    {
        if (Application.platform == RuntimePlatform.Android)
        {
            //分包为空时（即官网包），屏蔽实名制
            return AgencyPlatform.IsMutiPackageNull();
        }
        return false;
    }


    public void OpenRealAuth(Action<bool> callback=null)
    {
        SdkProxyModule.OpenOfficialCardView(callback);
    }

    public void OpenPayView(Action<int> callback = null)
    {
        SdkProxyModule.OpnePaySelectView(callback);
    }

    //获取登录账号类型
    /// <summary>
    /// 返回 
    /// 0 free,
    /// 1 phone,//自平台（手机）
    /// 2 mail,
    /// 3 device,//设备号
    /// 4 qq,
    /// 5 weixin,
    /// </summary>
    /// <returns></returns>
    public int GetCurAccountType()
    {
        if (SdkAccountModel.Instance.loginAccount == null)
            return 0;
        return (int)SdkAccountModel.Instance.loginAccount.type;
    }

    //是否可充值
    public bool CheckCanPay()
    {
        if (SdkAccountModel.Instance.IsTempLogin() && !SdkAccountModel.Instance.IsBound())
        {
            SdkProxyModule.ShowTips("快捷登录账号不允许充值，请先绑定手机成为正式账号");
            return false;
        }
        return true;
    }

    //Sdk层是否有界面显示
    public bool HashModuleShow()
    {
        return SdkProxyModule.HasModuleShow();
    }

    public void ClearModule()
    {
        SdkProxyModule.ClearModule();
    }
}

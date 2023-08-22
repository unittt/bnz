// **********************************************************************
// Copyright (c) 2015 cilugame. All rights reserved.
// File     : SPSdkManager.cs
// Author   : senkay <senkay@126.com>
// Created  : 11/18/2015 
// Porpuse  : 
// **********************************************************************
//
using UnityEngine;
using System;
using System.Collections.Generic;
using AssetPipeline;
using System.Collections;

public class SPSdkManager
{
    private static readonly SPSdkManager instance = new SPSdkManager();

    public static SPSdkManager Instance
    {
        get
        {
            return instance;
        }
    }

#if UNITY_EDITOR
    public static Dictionary<string, SPChannel> SpChannelDic(string configSuffix = "", bool forceLoad = false)
    {
        if (forceLoad)
        {
            LoadSPChannelConfigAtEditor(configSuffix);
        }
        else
        {
            if (_spChannelDic == null)
            {
                LoadSPChannelConfigAtEditor(configSuffix);
            }
        }
        return _spChannelDic;
    }

#endif

    private static Dictionary<string, SPChannel> _spChannelDic;

    public bool WaitingLoginResult = false;

    #region SDK callback handler

    public event System.Action<bool, string> OnInitCallback;

    public event System.Action<bool, string> OnLoginSuccess;
    public event System.Action OnLoginFail;
    public event System.Action OnLoginCancel;
    public event System.Action OnReLogin;

    public event System.Action<bool> OnLogoutNotify;
    public event System.Action<bool> OnLogoutCallback;
    public event System.Action<bool> OnExitCallback;
    public event System.Action OnNoExiterProvideCallback;

    public event System.Action<bool> OnPayCallback;

    public bool IsDemiChannel()
    {
        return AgencyPlatform.IsDemiChannel();
    }

    public void CallbackInit(bool success, string param)
    {
        GameDebuger.Log("CallbackInit " + success);

        if (OnInitCallback != null)
        {
            OnInitCallback(success, param);
        }
    }

    public void CallbackLoginSuccess(bool isGuest, string sid)
    {
        GameDebuger.Log(string.Format("CallbackLoginSuccess isGuest={0} sid={1}", isGuest, sid));

        WaitingLoginResult = false;

        if (OnLoginSuccess != null)
        {
            OnLoginSuccess(isGuest, sid);
        }
    }

    public void CallbackLoginFail()
    {
        GameDebuger.Log("CallbackLoginFail");

        WaitingLoginResult = false;

        if (OnLoginFail != null)
        {
            OnLoginFail();
        }
    }

    public void CallbackLoginCancel()
    {
        GameDebuger.Log("CallbackLoginCancel");

        WaitingLoginResult = false;

        if (OnLoginCancel != null)
        {
            OnLoginCancel();
        }
    }

    public void CallbackLogout(bool success)
    {
        GameDebuger.Log("CallbackLogout " + success);

        if (OnLogoutCallback != null)
        {
            OnLogoutCallback(success);
            OnLogoutCallback = null;
        }
        else
        {
            if (OnLogoutNotify != null)
            {
                OnLogoutNotify(success);
            }
        }
    }

    public void CallbackNoExiterProvide()
    {
        GameDebuger.Log("CallbackNoExiterProvide");
        if (IsDemiChannel())
        {
            if (SdkLoginMessage.Instance.HashModuleShow())
            {
                SdkLoginMessage.Instance.ClearModule();
                CallbackLoginCancel();
                return;
            }
        }

        if (OnNoExiterProvideCallback != null)
        {
            OnNoExiterProvideCallback();
        }
    }

    public void CallbackExit(bool success)
    {
        GameDebuger.Log("CallbackExit " + success);

        if (OnExitCallback != null)
        {
            OnExitCallback(success);
        }
    }

    public void CallbackPay(bool success)
    {
        GameDebuger.Log("CallbackPay " + success);

        if (OnPayCallback != null)
        {
            OnPayCallback(success);
            OnPayCallback = null;
        }
    }

    #endregion

    #region SDK CALL

    public void Setup(int demiSdkUILayer)
    {
        GameDebuger.Log("SPSDK Setup demiSdkUILayer:" + demiSdkUILayer);

        SPSDK.Setup();

        if (IsDemiChannel())
        {
            GameSetting.DEMI_SDK_UILayer = demiSdkUILayer;
            //string strIsDemiFirstRun = PlayerPrefs.GetString("IsDemiFirstRun", "YES");
            //if (strIsDemiFirstRun == "YES")
            {
                //PlayerPrefs.SetString("IsDemiFirstRun", "NO");

                string dataJson = "{}";
                string json = "{\"type\":\"demiFirstRun\",\"code\":\"0\",\"data\":" + dataJson + "}";
                GameDebug.Log("demiFirstRun json=" + json);
                SPSDK.OnSdkCallback(json);
            }
        }
    }

    public void Init()
    {
        GameDebuger.Log("SPSDK Init");

        GameSetting.Channel = SPSdkManager.Instance.GetChannel();
        GameSetting.SubChannel = SPSdkManager.Instance.GetSubChannel();

        GameDebuger.Log("Channel:" + GameSetting.Channel + " SubChannel:" + GameSetting.SubChannel);

        //xxj begin
        //OnInitCallback = callback;
        //
        //if (GameSetting.Channel == AgencyPlatform.Channel_cilugame)
        //{
        //    OnInitCallback(true, "");
        //}
        //else
        //xxj end

        GameLauncher.Instance.GameRoot.gameObject.GetMissingComponent<LayerManager>();
        GameLauncher.Instance.GameRoot.gameObject.GetMissingComponent<ExitGameScript>();

        AssetPipeline.ResourcePoolManager.Instance.Setup();
        if (IsDemiChannel())
        {
            //xxj begin
            //SdkLoginMessage.Instance.C2SdkInitRoot(LayerManager.Root.UIModuleRoot);
            //xxj end

            //SdkLoginMessage.Instance.C2SdkInitRoot(GameLauncher.Instance.GameRoot);
            SdkLoginMessage.Instance.C2SdkInitRoot(LayerManager.Root.UIModuleRoot);
            ProxyLoginModule.Open();
        }
        //xxj begin
        //        else
        //        {

        //#if (UNITY_EDITOR || UNITY_STANDALONE)
        //            OnInitCallback(true, "");
        //#elif UNITY_ANDROID || UNITY_IPHONE
        //            SPSDK.Init();
        //#else
        //			OnInitCallback(false, "");
        //#endif
        //        }
        //xxj end
    }

    public void Login()
    {
        GameDebuger.Log("SPSDK Login, QRcodeLogin:" + GameSetting.QRcodeLogin.ToString());


        if (GameSetting.QRcodeLogin)
        {
            // 刷新一下数据
            WinGameSetting.Setup(WinGameSetting.WinGameSettingData.CreateOriginWinGameSettingData(),
                () =>
                {
                    //xxj begin
                    //ProxyQRCodeModule.OpenQRCodeLoginView();
                    //xxj end
                },
                error =>
                {
                    ProxyWindowModule.OpenMessageWindow(error, null, Login);
                });
        }
        //xxj begin
        //else if (GameSetting.Channel == AgencyPlatform.Channel_cilugame || GameSetting.GMMode)
        //{
        //    ProxyLoginModule.OpenTestSdk();
        //}
        //xxj end
        else if (IsDemiChannel())
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
            CallbackLoginFail();
            //xxj begin
            //#endif
            //xxj end
        }
    }

    public void Bind()
    {
        GameDebuger.Log("SPSDK Bind");

        if (IsDemiChannel())
        {
            SdkLoginMessage.Instance.C2SdkBind();
        }
        //xxj begin
        //        else
        //        {
        //#if (UNITY_EDITOR || UNITY_STANDALONE)
        //            OnLoginFail();
        //#elif UNITY_ANDROID || UNITY_IPHONE
        //		    SPSDK.Bind();
        //#else
        //		    OnLoginFail();
        //#endif
        //        }
        //xxj end
    }

    public bool IsSupportLogout()
    {
        GameDebuger.Log("SPSDK IsSupportLogout");

        //xxj begin
        //if (GameSetting.Channel == AgencyPlatform.Channel_cilugame)
        //{
        //    return true;
        //}
        //else 
        //xxj end
        if (IsDemiChannel())
        {
            return true;
        }
        //xxj begin
        //     else
        //     {
        //         #if (UNITY_EDITOR || UNITY_STANDALONE)
        //         return true;
        //         #elif UNITY_ANDROID || UNITY_IPHONE
        //return SPSDK.IsSupportLogout();
        //         #else
        //return true;
        //         #endif
        //     }
        //xxj end

        return true;
    }

    public void Logout(Action<bool> callback)
    {
        OnLogoutCallback = callback;
        GameDebuger.Log("SPSDK Logout");

        //xxj begin
        //if (GameSetting.Channel == AgencyPlatform.Channel_cilugame)
        //{
        //    OnLogoutCallback(true);
        //}
        //else 
        //xxj end
        if (IsDemiChannel())
        {
            SdkLoginMessage.Instance.C2SdkLogout();
            OnLogoutCallback(true);
        }
        //xxj begin
        //        else
        //        {
        //#if (UNITY_EDITOR || UNITY_STANDALONE)
        //            OnLogoutCallback(true);
        //#elif UNITY_ANDROID || UNITY_IPHONE
        //			//如果立即注销，则马上回调，否则等待
        //            if (SPSDK.Logout())
        //            {
        //                OnLogoutCallback(true);
        //            }
        //			else
        //			{
        //				//等待SDK回调callback后处理
        //			}
        //#else
        //			OnLogoutCallback(true);
        //#endif
        //        }
        //xxj end
    }

    public void DoInit()
    {
        GameDebuger.Log("SPSDKManager DoInit");

        Setup(GameSetting.DEMI_SDK_UILayer);

        Init();

        if (IsDemiChannel())
        {
            PayManager.Instance.SetupForDemi();
        }
    }

    public void DoLogin()
    {
        GameDebuger.Log("SPSDKManager DoLogin");

        if (ExitGameScript.Instance != null)
            ExitGameScript.Instance.Login();
    }

    public void DoLogout()
    {
        GameDebuger.Log("SPSDKManager DoLogout");

        if (ExitGameScript.Instance != null)
            ExitGameScript.Instance.ReloginAccount(true, true);
    }

    public void DoExiter()
    {
        GameDebuger.Log("SPSDKManager DoExiter");

        if (ExitGameScript.Instance != null)
            ExitGameScript.Instance.DoExiter();
    }

    public void DoExit()
    {
        GameDebuger.Log("SPSDKManager DoExit");
        if (ExitGameScript.Instance != null)
            ExitGameScript.Instance.HanderExitGame(true);
    }

    public void DoReLogin()
    {
        GameDebuger.Log("SPSDKManager DoReLogin");
        if (ExitGameScript.Instance != null && SdkAccountModel.Instance != null)
        {
            ExitGameScript.Instance.ReloginAccount(true, false);
            if (OnReLogin != null)
            {
                OnReLogin();
            }

            SdkAccountModel.Instance.DoLogin(ServerManager.Instance.account, ServerManager.Instance.password, SdkAccountDto.AccountDto.AccountType.phone, ServerManager.Instance.bSaveAccount);
        }
    }

    public void TrackingioSetup()
    {
        GameDebuger.Log("SPSDKManager TrackingioSetup");
        TrackingIOHelper.Setup();
    }

    public void TrackingioRegister(string uid)
    {
        GameDebuger.Log("SPSDKManager TrackingioRegister uid:" + uid);
        TrackingIOHelper.Register(uid);
    }

    public void TrackingioLogin(string uid)
    {
        GameDebuger.Log("SPSDKManager TrackingioLogin uid:" + uid);
        TrackingIOHelper.Login(uid);
    }

    public string GetAdAppIdForIOS()
    {
        return GameSetting.ad_app_id_for_ios;
    }

    public string GetAdActivityIdForIOS()
    {
        return GameSetting.ad_activity_id_for_ios;
    }

    public string GetTrackingIOAppId()
    {
        return GameSetting.trackingIO_appId;
    }

    public void SetDemiSdkUseNew(bool isNew)
    {
        GameSetting.DEMI_SDK_USE_NEW = isNew;
    }

    public void SetDemiSdkCode(string code)
    {
        GameSetting.DEMI_SDK_CODE = code;
    }

    public void SetDemiSdkCodePay(string codePay)
    {
        GameSetting.DEMI_SDK_CODE_PAY = codePay;
    }

    public void DoDemiLoginForIOS()
    {
        var data = WinGameSetting.WinGameSettingData.CreateOriginWinGameSettingData();
        data.PlatformType = GameSetting.PlatformType.IOS;
        data.Channel = AgencyPlatform.Channel_demi;
        data.SubChannel = data.Channel;
        //data.ChannelAreaFlag = "";

        WinGameSetting.Setup(data,
            () =>
            {
                GameDebuger.Log("DoDemiLoginForIOS SdkLoginMessage.Instance.C2SdkLogin");
                SdkLoginMessage.Instance.C2SdkLogin();
            },
            error =>
            {
                ProxyWindowModule.OpenMessageWindow(error, null);
            });
    }

    public void DoDemiLoginForAndroid()
    {
        var data = WinGameSetting.WinGameSettingData.CreateOriginWinGameSettingData();
        data.PlatformType = GameSetting.PlatformType.Android;
        data.Channel = AgencyPlatform.Channel_demi;
        data.SubChannel = data.Channel;
        //data.ChannelAreaFlag = "";

        WinGameSetting.Setup(data,
            () =>
            {
                GameDebuger.Log("DoDemiLoginForAndroid SdkLoginMessage.Instance.C2SdkLogin");
                SdkLoginMessage.Instance.C2SdkLogin();
            },
            error =>
            {
                ProxyWindowModule.OpenMessageWindow(error, null);
            });
    }

    public void DoExiter(Action<bool> exitCallback, Action noExiterCallback)
    {
        OnExitCallback = exitCallback;
        OnNoExiterProvideCallback = noExiterCallback;
        GameDebuger.Log("SPSDKManager DoExiter 2");

        OnNoExiterProvideCallback();


        if (GameSetting.Channel == AgencyPlatform.Channel_cilugame)
        {
            OnNoExiterProvideCallback();
        }
        else
        {
#if (UNITY_EDITOR || UNITY_STANDALONE)
            OnNoExiterProvideCallback();
#elif UNITY_ANDROID || UNITY_IPHONE
            if (SPSDK.DoExiter())
            {
                OnNoExiterProvideCallback();
            }
#endif
        }
    }

    public void Exit()
    {
        GameDebuger.Log("SPSDK Exit");

        #if (UNITY_EDITOR || UNITY_STANDALONE)
            return;
        #elif UNITY_ANDROID || UNITY_IPHONE
		    SPSDK.Exit();
        #endif
    }

    //注册
    public void Regster(string account, string uid)
    {
        GameDebuger.Log(string.Format("SPSDK Regster account={0} uid={1}", account, uid));

        //xxj begin
        //if (GameSetting.Channel == AgencyPlatform.Channel_cilugame)
        //    return;
        //xxj end
        if (IsDemiChannel())
        {
            SdkLoginMessage.Instance.C2SdkRegister();
        }

        //xxj begin
//#if (UNITY_EDITOR || UNITY_STANDALONE)
//        return;
//        #elif UNITY_ANDROID || UNITY_IPHONE
//		SPSDK.Regster(account, uid);
//        #endif
        //xxj end
    }

    public void UpdateUserInfo(string uid)
    {
        if (string.IsNullOrEmpty(uid))
        {
            return;
        }

        GameDebuger.Log("SPSDK UpdateUserInfo uid=" + uid);

        if (GameSetting.Channel == AgencyPlatform.Channel_cilugame)
            return;

//         if (GameSetting.Channel == AgencyPlatform.Channel_demi)
//             return;

#if (UNITY_EDITOR || UNITY_STANDALONE)
        return;
#elif UNITY_ANDROID || UNITY_IPHONE
		SPSDK.UpdateUserInfo(uid);
#endif

        SPSDK.UpdateUserInfo(uid);
    }

    /// 部分渠道要求创建角色、角色升级、进入服务器时需要上传数据 login createrole levelup
    public void SubmitRoleData(string roleJson)
    {
        GameDebuger.Log("SPSDK SubmitRoleData");

        //if (GameSetting.Channel == AgencyPlatform.Channel_cilugame)
        //    return;

#if (UNITY_EDITOR || UNITY_STANDALONE)
        return;
#elif UNITY_ANDROID || UNITY_IPHONE
		SPSDK.SubmitRoleData(roleJson);
#endif
    }

    public void GainGameCoin(string amount, string playerId, string playerName,
        string playerLevel, string serverId, string changeTime)
    {
        GameDebuger.Log("SPSDK GainGameCoin");

        if (GameSetting.Channel == AgencyPlatform.Channel_cilugame)
            return;
        
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return;
#elif UNITY_ANDROID || UNITY_IPHONE
        Hashtable hash = new Hashtable();
        hash.Add("amount", amount);
        hash.Add("playerId", playerId);
        hash.Add("playerName", playerName);
        hash.Add("playerLevel", playerLevel);
        hash.Add("serverId", serverId);
        hash.Add("changeTime", changeTime);
        string jsonStr = JsHelper.ToJson(hash);

		SPSDK.GainGameCoin(jsonStr);
#endif

    }

    public void ConsumeGameCoin(string amount, string playerId, string playerName,
        string playerLevel, string serverId, string changeTime)
    {
        GameDebuger.Log("SPSDK ConsumeGameCoin");

        if (GameSetting.Channel == AgencyPlatform.Channel_cilugame)
            return;

#if (UNITY_EDITOR || UNITY_STANDALONE)
        return;
#elif UNITY_ANDROID || UNITY_IPHONE
        Hashtable hash = new Hashtable();
        hash.Add("amount", amount);
        hash.Add("playerId", playerId);
        hash.Add("playerName", playerName);
        hash.Add("playerLevel", playerLevel);
        hash.Add("serverId", serverId);
        hash.Add("changeTime", changeTime);
        string jsonStr = JsHelper.ToJson(hash);

		SPSDK.ConsumeGameCoin(jsonStr);
#endif
    }

    public string GetChannel()
    {
        if (GameSetting.Channel != AgencyPlatform.Channel_cilugame)
        {
#if (UNITY_EDITOR || UNITY_STANDALONE)
            // win下取Android的值
			var id = !GameSetting.QRcodeLogin ? GameSetting.Channel : WinGameSetting.Channel;
			GameDebuger.Log("SPSdkManager.GetChannel is: " + id);
			return id;
#elif UNITY_ANDROID || UNITY_IPHONE
            var id = SPSDK.GetChannelId();
			GameDebuger.Log("SPSdkManager.GetChannel is: " + id);
            return !string.IsNullOrEmpty(id) ? id : "errorID";
#else
            return GameSetting.ClientMode.ToString();
#endif
        }
        else
        {
            return GameSetting.Channel;
        }
    }

    public string GetSubChannel()
    {
        GameDebuger.Log("SPSDK GetSubChannelId");
        if (GameSetting.Channel != AgencyPlatform.Channel_cilugame)
        {
#if (UNITY_EDITOR || UNITY_STANDALONE)
            if (GameSetting.QRcodeLogin)
            {
                return WinGameSetting.SubChannel;
            }

			string channel = GetChannel();
            if (channel == AgencyPlatform.Channel_demi)
            {
                return AgencyPlatform.Channel_demi;
            }
            else if (channel == AgencyPlatform.Channel_sm)
            {
                //返回手盟自运营渠道
                return AgencyPlatform.Channel_shoumengself;
            }

            return !GameSetting.IsOriginWinPlatform ? "" : WinGameSetting.SubChannel;
#elif UNITY_ANDROID || UNITY_IPHONE
            var id = SPSDK.GetSubChannelId();
            GameDebuger.Log("SPSDKManager GetSubChannelId is: " + id);
            return id;
#else
            return GameSetting.ClientMode.ToString();
#endif
        }
        else
        {
            return GameSetting.Channel;
        }
    }

    //前后端统一称为分包标识
    //使用subchannel + "_" + GameSetting.ChannelAreaFlag 进行拼接。
    //由于历史遗留原因，加上旧分包标识MutilPackageId的处理
    public string GetPackId()
    {
        string packId = GetSubChannel();
        //xxj begin
        //if (!string.IsNullOrEmpty(GameSetting.ChannelAreaFlag))
        //{
        //    packId = packId + "_" + GameSetting.ChannelAreaFlag;
        //}
        //else
        //xxj end
        if (!string.IsNullOrEmpty(GameSetting.MutilPackageId))
        {
            if (GameSetting.MutilPackageId.Contains(packId))
            {
                packId = GameSetting.MutilPackageId;
            }
            else
            {
                packId = packId + "_" + GameSetting.MutilPackageId;
            }
        }

        return packId;
    }

    public string GetMutilPackageId()
    {
        GameDebuger.Log("SPSDK GetMutilPackageId");
        if (GameSetting.Channel != AgencyPlatform.Channel_cilugame)
        {
#if (UNITY_EDITOR || UNITY_STANDALONE)
            return "";
#elif UNITY_IPHONE || UNITY_ANDROID
            var id = SPSDK.GetMutilPackageId();
            GameDebuger.Log("SPSDK GetMutilPackageId is: " + id);
            return id;
#else
            return "";
#endif
        }
        else
        {
            return GameSetting.MutilPackageId;
        }
    }

    public bool IsSupportUserCenter()
    {
        GameDebuger.Log("SPSDK IsSupportUserCenter");

        if (GameSetting.Channel == AgencyPlatform.Channel_cilugame)
        {
            return false;
        }
        else if (IsDemiChannel())
            return SdkLoginMessage.Instance.IsSupportUserCenter();
        else
        {
#if (UNITY_EDITOR || UNITY_STANDALONE)
            return false;
#elif UNITY_ANDROID || UNITY_IPHONE
            return SPSDK.IsSupportUserCenter();
#else
			return false;
#endif
        }
    }

    public void EnterUserCenter()
    {
        GameDebuger.Log("SPSDK EnterUserCenter");
        if (IsDemiChannel())
        {
            SdkLoginMessage.Instance.C2SdkUserCenter();
        }
        {
#if (UNITY_EDITOR || UNITY_STANDALONE)
            return;
#elif UNITY_ANDROID || UNITY_IPHONE
		    SPSDK.EnterUserCenter();
#else
		    return;
#endif
        }
    }

    public bool IsSupportBBS()
    {
        GameDebuger.Log("SPSDK IsSupportBBS");

        //xxj begin
        //审核服不显示
        //if (ServerManager.Instance.isReviewMode)
        //{
        //    return false;
        //}
        //xxj end

        if (GameSetting.Channel == AgencyPlatform.Channel_cilugame)
        {
            return false;
        }
        else if (IsDemiChannel())
        {
            return SdkLoginMessage.Instance.IsSupportBBS();
        }
        else
        {
#if (UNITY_EDITOR || UNITY_STANDALONE)
            return false;
#elif UNITY_ANDROID || UNITY_IPHONE
            return SPSDK.IsSupportBBS();
#else
			return true;
#endif
        }
    }

    public void EnterSdkBBS()
    {
#if UNITY_EDITOR
        //xxj begin
        //TipManager.AddTip("调用了打开BBS接口。（测试，无需理会）");
        //xxj end
        return;
#endif

        if (IsDemiChannel())
        {
            SdkLoginMessage.Instance.C2SdkEnterBBS();
        }
        
        GameDebuger.Log("SPSDK EnterSdkBBS");
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return;
#elif UNITY_ANDROID || UNITY_IPHONE
		SPSDK.EnterSdkBBS();
#else
		return;
#endif
    }

    public bool IsShoumengChannel()
    {
        return GetChannel() == "sm";
    }

    public bool IsShowMainUIBBSBtn()
    {
        //xxj begin
        //审核服不显示
        //if (ServerManager.Instance.isReviewMode)
        //{
        //    return false;
        //}
        //xxj end
#if UNITY_EDITOR
        //测试
        return true;
#endif
        string subChannel = GetSubChannel();
        if (IsShoumengChannel() && (subChannel == "2144" || subChannel == "game2144"))
        {
            return IsSupportBBS();
        }

        return false;
    }

    public bool IsSupportShowOrHideToolbar()
    {
        GameDebuger.Log("SPSDK IsSupportShowOrHideToolbar");
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return false;
#elif UNITY_ANDROID || UNITY_IPHONE
        return SPSDK.IsSupportShowOrHideToolbar();
#else
		return false;
#endif
    }

    public void ShowFloatToolBar()
    {
        GameDebuger.Log("SPSDK ShowFloatToolBar");
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return;
#elif UNITY_ANDROID || UNITY_IPHONE
		SPSDK.ShowFloatToolBar();
#else
		return;
#endif
    }

    public void HideFloatToolBar()
    {
        GameDebuger.Log("SPSDK HideFloatToolBar");
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return;
#elif UNITY_ANDROID || UNITY_IPHONE
		SPSDK.HideFloatToolBar();
#else
		return;
#endif
    }

    public void DoPay(
        string payJson,
        Action<bool> payCallback
    )
    {
        GameDebug.Log("222222222222222222 IsDemiChannel:" + IsDemiChannel() + " Channel:" + GameSetting.Channel + " SubChannel:" + GameSetting.SubChannel);
        //TODO 集成talkingdata的充值统计
        //AdTracking.OnPlaceOrder(orderSerial, productName, int.Parse(productPrice));
        OnPayCallback = payCallback;
        if (IsDemiChannel())
        {
            GameDebug.Log("333333333333333333 CheckCanPay:" + SdkLoginMessage.Instance.CheckCanPay());
            if (!SdkLoginMessage.Instance.CheckCanPay())
            {
                GameDebug.Log("4444444444444444444");
                return;
            }
            if (!SdkLoginMessage.Instance.IsIngotAuth() && !SdkLoginMessage.Instance.IsRealAuth())
            {
                GameDebug.Log("555555555555555555 IsIngotAuth:" + SdkLoginMessage.Instance.IsIngotAuth() + " IsRealAuth:" + SdkLoginMessage.Instance.IsRealAuth());
                //跳过也能继续支付
                SdkLoginMessage.Instance.OpenRealAuth((success) =>
                {
                    GameDebug.Log("66666666666666");
                    CommitDoPay(payJson);
                });
                return;
            }
        }
        GameDebug.Log("7777777777777");
        CommitDoPay(payJson);
    }

    //被顶号后，sid是否会失效,是否需要清除
    public bool IsKickClearSid()
    {
        return AgencyPlatform.IsSmChannel();
    }

    public void DoIosWechatAliPay(string payWay, string dataJson, Action<bool> payCallback)
    {
#if UNITY_IPHONE
        OnPayCallback = payCallback;
        try
        {
			GameDebug.Log("SPSdkManager.DoIosWechatAliPay payWay:" + payWay + " | dataJson:" + dataJson);
            SPSDK.DoIosWechatAliPay(payWay, dataJson);
        }
        catch (Exception e)
        {
            GameDebuger.LogError(e);
        }
#endif
    }

    public void CommitDoPay(string payJson)
    {
        GameDebuger.Log("SPSDK DoPay");
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return;
#elif UNITY_ANDROID || UNITY_IPHONE
        SPSDK.DoPay(payJson);
#else
		return;
#endif
    }

    #endregion

#if UNITY_EDITOR
    private const string Config_Path = "Assets/Editor/BuildTools/Configs/SPChannelConfig{0}.json";

    public static void LoadSPChannelConfigAtEditor(string configSuffix)
    {
        if (configSuffix == null)
        {
            configSuffix = "";
        }

        if (!string.IsNullOrEmpty(configSuffix))
        {
            configSuffix = "_" + configSuffix;
        }

        _spChannelDic = new Dictionary<string, SPChannel>();

        string path = string.Format(Config_Path, configSuffix);
        GameDebuger.Log("path=" + path);
        string json = FileHelper.ReadAllText(path);
        if (!string.IsNullOrEmpty(json))
        {
            var spChannels = JsHelper.ToCollection<List<SPChannel>, SPChannel>(json);
            for (int i = 0; i < spChannels.Count; i++)
            {
                SPChannel channel = spChannels[i];
                _spChannelDic[channel.name] = channel;
            }
        }
    }
#endif

    public static void LoadSPChannelConfig(Action<bool> callback)
    {
        _spChannelDic = new Dictionary<string, SPChannel>();
        callback(true);
    }

    public static string GetChannelBundleId(string id)
    {
        SPChannel info = null;
        if (_spChannelDic.TryGetValue(id, out info))
        {
            return info.bundleId;
        }
        else
        {
            return "";
        }
    }
                       
    public static void ModifyTrackingIOHelperAppID(string newAppID)
    {
        TrackingIOHelper.appID = newAppID;
    }

    public static bool IsHideAgreementTitle()
    {
        return GameSetting.BundleId == "xianling.waizhuan.cm";
    }

    //是否使用demi热云
    public bool IsUseDemiReyun()
    {
#if (UNITY_EDITOR || UNITY_STANDALONE)
        return false;
#elif UNITY_ANDROID
        //return DemiReyun.IsReyunOpen();
        return false;
#elif UNITY_IPHONE
        //ios先不接入,后面接入需增加框架号判断
        return false;
#else
		return;
#endif
    }
}


using System;
using System.Collections;
using UnityEngine;
using System.Collections.Generic;
using LITJson;

public class LoginController : MonoViewController<LoginView>
{
    //xxj begin
	//private ModelDisplayController _modelController;
	//private OneShotUIEffect _loginEffect;
    //xxj end
	#region IViewController

	/// <summary>
	/// 从DataModel中取得相关数据对界面进行初始化
	/// </summary>


    protected override void InitView ()
	{
        //xxj begin
        //View.MovieButton_UIButton.gameObject.SetActive(AppGameVersion.startMovieMode);
        //View.LogoTexture_UITexture.gameObject.AddMissingComponent<LogoAutoLocation>();
        //xxj end

        ResizeWindow();
    }

    /// <summary>
    /// Registers the event.
    /// DateModel中的监听和界面控件的事件绑定,这个方法将在InitView中调用
    /// </summary>
    protected override void RegisterEvent ()
	{
        //xxj begin
		//EventDelegate.Set(View.StartGameButton_UIButton.onClick, OnClickStartGameButton);
		//EventDelegate.Set(View.LastLoginInfo_UIButton.onClick, OnClickLastLoginInfoButton);
		//EventDelegate.Set(View.LastLoginRoleInfo_UIButton.onClick, OnClickLastLoginInfoButton);
		//EventDelegate.Set(View.MovieButton_UIButton.onClick, OnClickMovieButton);
		//EventDelegate.Set(View.NoticeButton_UIButton.onClick, OnNoticeButton);
		//EventDelegate.Set(View.AccountButton_UIButton.onClick, OnClickAccountButton);
		//EventDelegate.Set(View.AgreementButton_UIButton.onClick, OnClickAgreementButton);
		//EventDelegate.Set(View.QRCodeScanBtn_UIButton.onClick, OnQRCodeScanBtnClick);

		//EventDelegate.Set(View.SPLoginButton_UIButton.onClick, OnSPLoginButtonClick);

  //      EventDelegate.Set(View.VersionLabel_UIButton.onClick, OnVersionLabelButtonClick);

        //GameServerInfoManager.onServerListReturn += OnServerListReturn;

        //LoginManager.Instance.OnLoginMessage += OnLoginMessage;
		//LoginManager.Instance.OnLoginProcess += OnLoginProcess;
        //xxj end
        //LoginManager.Instance.OnWaitForLoginQueue += OnWaitForLoginQueue;
        ScreenResizeManager.Instance.OnOrientationChanged += ResizeWindow;
    }

	protected override void OnDispose ()
	{
        //xxj begin
  //      if (_loginEffect != null)
		//{
		//	_loginEffect.Dispose();
		//	_loginEffect = null;
		//}
        //xxj end

        //GameServerInfoManager.onServerListReturn -= OnServerListReturn;
        ReleaseTexture(View.LoadingTexture_UITexture);
        ReleaseTexture(View.LogoTexture_UITexture);

        //xxj begin
		//LoginManager.Instance.OnLoginMessage -= OnLoginMessage;
		//LoginManager.Instance.OnLoginProcess -= OnLoginProcess;
        //xxj end
		//LoginManager.Instance.OnWaitForLoginQueue -= OnWaitForLoginQueue;

		SPSdkManager.Instance.OnLoginSuccess -= OnLoginSuccess;
		SPSdkManager.Instance.OnLoginCancel -= OnLoginCancel;
		SPSdkManager.Instance.OnLoginFail -= OnLoginFail;
        SPSdkManager.Instance.OnReLogin -= OnReLogin;

        SPSdkManager.Instance.OnLoginSuccess -= OnSwitchLoginSuccess;
		SPSdkManager.Instance.OnLogoutNotify -= OnLogout;
        ScreenResizeManager.Instance.OnOrientationChanged -= ResizeWindow;
    }

    #endregion


    #region 调整界面
    void ResizeWindow()
    {
        ScreenResizeManager.Instance.ResizePanel(gameObject);

        //xxj begin
        //if (ScreenResizeManager.Instance.IsPhoneViersionX())
        //{
        //    _view.LoadingTexture_UITexture.aspectRatio = 2.167f;
        //}
        //xxj end
    }
    #endregion

    //xxj begin
    //private GameServerInfo _currentServerInfo;
    //xxj end

	private bool _isLogined = false;

	public void Open()
	{
        GameDebug.Log("Open loginAccountDto:" + ServerManager.Instance.loginAccountDto + " sid:" + ServerManager.Instance.sid + " QRcodeLogin:" + GameSetting.QRcodeLogin);

		_isLogined = false;

        //xxj begin
        //_currentServerInfo = null;
        //xxj end

        //xxj begin
        //View.VersionLabel_UILabel.text = AppGameVersion.ShowVersion+"_"+FrameworkVersion.ShowVersion;
		//View.BanhaoLabel_UILabel.text = AppGameVersion.GetBanhao();
		//ShowVersion(true);

		//View.loadingSlider_UISlider.value = 0.1f;
		//View.LoadingLabel_UILabel.text = "";
		//View.LoadingTips_UILabel.text = LoadingTipManager.GetLoadingTip();
        //xxj end

		//View.LogoTexture_UITexture.cachedGameObject.SetActive(!GameSetting.QRcodeLogin);
		//View.LogoTexture_UITexture.mainTexture = AssetPipeline.AssetManager.LoadStreamingAssetsTexture("Textures/logo");
        //View.LogoTexture_UITexture.MakePixelPerfect();
		//View.LoadingTexture_UITexture.mainTexture = AssetPipeline.AssetManager.LoadStreamingAssetsTexture("Textures/loginBG");
        //LoadEffect();

        //View.ButtonGroup.SetActive(true);
        //View.AgreementButton_UIButton.gameObject.SetActive(false);
		//View.NoticeButton_UIButton.gameObject.SetActive(false);
		//View.AccountButton_UIButton.gameObject.SetActive(false);
		//View.QRCodeScanBtn_UIButton.gameObject.SetActive(false);

        //View.HealthTipLabel_UILabel.gameObject.SetActive(true);

        //xxj begin
        //if (ServerManager.Instance.loginAccountDto != null)
        //{
        //    View.VersionLabel_UIButton.enabled = ServerManager.Instance.loginAccountDto.white;
        //}
        //xxj end

		HideSPLoginButton();

   
        ProxyWindowModule.closeSimpleWinForTop();


        //xxj begin
        //if (ProxyLoginModule.serverInfo != null)
        //      {
        //          OnServerListReturn();
        //          HideOtherUI();

        //          Login(ProxyLoginModule.serverInfo, ProxyLoginModule.accountPlayerDto);
        //          ProxyLoginModule.serverInfo = null;
        //          ProxyLoginModule.accountPlayerDto = null;
        //      }
        //else
        //xxj end
        {
            if (ServerManager.Instance.loginAccountDto == null)
            {
                if (string.IsNullOrEmpty(ServerManager.Instance.sid))
                {
                    OnClickAccountButton();
                }
                else
                {
                    HideOtherUI();
                    OnLoginSuccess(ServerManager.Instance.isGuest, ServerManager.Instance.sid);
                }
            }
            else
            {
                HideOtherUI();

                // 苹果PC端特殊处理
                if (!GameSetting.QRcodeLogin)
                {
                    OnLoginSdkSuccess(ServerManager.Instance.loginAccountDto);
                }
                else
                {
                    OnLoginSuccess(ServerManager.Instance.isGuest, ServerManager.Instance.sid);
                }
            }
        }

        //AudioManager.Instance.PlayMusic("music_login");
        //LayerManager.Instance.SwitchLayerMode(UIMode.LOGIN);

        //LayerManager.Instance.LockUICamera(false);

        CheckHideWithChannel();

        //OpenSdk();
    }

    private void CheckHideWithChannel()
    {
        //xxj begin
        //if (AgencyPlatform.IsSmPcChannel())
        //{
        //    View.LogoTexture_UITexture.gameObject.SetActive(false);
        //    View.BanhaoLabel_UILabel.gameObject.SetActive(false);
        //}
        //xxj end
    }

	private void ShowVersion(bool show)
	{
        //xxj begin
        //View.VersionLabel_UILabel.gameObject.SetActive(show);
		//View.BanhaoLabel_UILabel.gameObject.SetActive(show);
        //xxj end
	}

	private void LoadEffect()
	{
        //xxj begin
		//if (SystemSetting.LowMemory)
		//	return;

		//if (_loginEffect == null)
		//{
		//	_loginEffect = OneShotUIEffect.BeginFollowEffect("ui_eff_Login_Effect", View.LoadingTexture_UITexture,
		//		Vector2.zero, 1);
		//}
		//else
		//{
		//	_loginEffect.SetActive(true);
		//}
        //xxj end
	}

	private void OnLoginSdkSuccess(LoginAccountDto account)
	{
        GameDebug.Log("OnLoginSdkSuccess uid:" + account.uid + " aid:" + account.accountId.ToString());

        //xxj begin
        //TalkingDataHelper.OnEventSetp("AppGameManager/LoginAccountSuccess"); //进入游戏登陆界面
        //xxj end

        ServerManager.Instance.loginAccountDto = account;
		ServerManager.Instance.uid = account.uid;
        ServerManager.Instance.aid = account.accountId.ToString();
		SPSdkManager.Instance.UpdateUserInfo(account.uid);

        //xxj begin
        //GameServerInfoManager.InitDefaultServer();

        //OnServerListReturn();
        //xxj end

        string token = account.token;
        GameDebuger.Log("token = " + token);

        //xxj begin
        //if (!SPSdkManager.IsHideAgreementTitle())
        //{
        //	ShopAccountTip(string.Format("欢迎进入{0}", GameSetting.GameName));	
        //}
        //xxj end

        string accountId = account.accountId.ToString();
        if (account.firstRegister)
        {
            SPSdkManager.Instance.Regster(accountId, account.uid);
        }

        if (AgencyPlatform.IsDemiChannel())
        {
            FrameworkUpgradeHelper.Call(() =>
                {
                    //根据投放部门的需求，把热云的激活调用时序， 改为了注册时调用
                    if (IsDemiChannel())
                    {
                        TrackingIOHelper.Setup();

                        //暂时不开德米热云，因为还没有集成完善
                        //DemiReyun.Setup();
                    }

                    if (account.firstRegister)
                    {
                        TrackingIOHelper.Register(account.uid);
                    }
                    else
                    {
                       
                        TrackingIOHelper.Login(account.uid);
                    }
                }, FrameworkUpgradeHelper.REYUN_VERSION);

            FrameworkUpgradeHelper.Call(() =>
            {
                if (account.firstRegister)
                {
                    //DemiReyun.Register(account.uid);
                }
            }, FrameworkUpgradeHelper.DEMI_REYUN_GDY);
        }

        //xxj begin
        //View.StartPanel_Transform.gameObject.SetActive(true);
        //View.ButtonGroup.SetActive(true);

        //View.LogoTexture_UITexture.cachedGameObject.SetActive(true);

        //View.AgreementButton_UIButton.gameObject.SetActive(IsAgreementSupport());
        //View.NoticeButton_UIButton.gameObject.SetActive(true);
        //View.AccountButton_UIButton.gameObject.SetActive(true);
        //xxj end

        CheckQRCodeScanSupport();

        //xxj begin
        //AnnouncementDataManager.Instance.CheckUpdate();

        //PayManager.Instance.Setup();
        //xxj end

        CheckHideWithChannel();
    }

    private bool IsDemiChannel()
    {
        return GameSetting.Channel == "demi" &&
            (GameSetting.SubChannel == "demi" ||
                GameSetting.SubChannel == "0");
    }

	//是否支持用户协议
	private bool IsAgreementSupport()
	{
        return true;
	}

	/// <summary>
	/// 统一使用读表判断是否允许使用扫码
	/// </summary>
	private void CheckQRCodeScanSupport()
	{
        //先关闭扫码
        //View.QRCodeScanBtn_UIButton.gameObject.SetActive(false);
        //return;

		if (GameSetting.IsOriginWinPlatform)
		{
            //xxj begin
            //View.QRCodeScanBtn_UIButton.gameObject.SetActive(false);
            //xxj end
			return;
		}

        //xxj begin
  //      if (!SystemSetting.SupportQRCodeScan)
  //      {
  //          View.QRCodeScanBtn_UIButton.gameObject.SetActive(false);
  //          return;            
  //      }

		//GameStaticConfigManager.Instance.LoadStaticConfig(GameStaticConfigManager.Type_StaticVersion,
		//	json =>
		//	{
		//		var dic = JsHelper.ToObject<Dictionary<string, object>>(json);
		//		try
		//		{
		//			string qrCodeKey = "supportQRCodeVer";
  //                  if (GameSetting.Platform != GameSetting.PlatformType.IOS)
  //                  {
	 //                   qrCodeKey = "androidQRCodeVer";
  //                  }

		//			if (dic.ContainsKey(qrCodeKey) && !string.IsNullOrEmpty((string)dic[qrCodeKey]))
		//			{
		//				View.QRCodeScanBtn_UIButton.gameObject.SetActive(AppGameVersion.SpVersionCode <= GameSetting.ParseVersionCode((string)dic[qrCodeKey]));
		//			}
		//			else
		//			{
		//				// IOS 默认关闭，其它相反
		//				View.QRCodeScanBtn_UIButton.gameObject.SetActive(GameSetting.Platform != GameSetting.PlatformType.IOS);
		//			}
		//		}
		//		catch
		//		{
		//			View.QRCodeScanBtn_UIButton.gameObject.SetActive(false);
		//		}
		//	}, delegate (string obj)
		//	{
		//		View.QRCodeScanBtn_UIButton.gameObject.SetActive(false);
		//	});
        //xxj end
	}

	private void ShopAccountTip(string accountTip)
	{
		View.AccountTipGroupWidget.cachedGameObject.SetActive(true);
		View.AccountTipLabel_UILabel.text = accountTip;

        //xxj begin
		//UIHelper.PlayAlphaTween(View.AccountTipGroupWidget, 1f, 0f, 1f, 2f);
        //xxj end
	}

	private void OnServerListReturn()
	{
        //xxj begin
		//OnSelectionChange(PlayerPrefs.GetString(GameSetting.LastServerPrefsName));
        //xxj end
	}

	private void OnClickMovieButton()
	{
        //xxj begin
//        TalkingDataHelper.OnEventSetp("PlayCG", "OpenFromClick");
//#if UNITY_STANDALONE && UNITY_EDITOR
//		CGPlayer.PlayCG("Assets/GameResources/ArtResources/" + PathHelper.CG_Asset_PATH, null);
//#else
//        CGPlayer.PlayCG(PathHelper.CG_Asset_PATH, null);
//#endif
        //xxj end
	}

	private void OnNoticeButton()
	{
        //xxj begin
		//TalkingDataHelper.OnEventSetp("Announcement", "Open");
        //xxj end

		ProxyLoginModule.OpenAnnouncement();
	}

	private void OnSPLoginButtonClick()
	{
        RequestLoadingTip.Show("", true, false, 1f);

        OpenSdk();
	}

    private void OnVersionLabelButtonClick()
    {
        //xxj begin
        //LoginAccountDto loginAccountDto = ServerManager.Instance.loginAccountDto;
        //if (loginAccountDto != null && loginAccountDto.white)
        //{
        //    ProxyWindowModule.OpenInputWindow(0, 20, "指令", "请输入正确指令", "请点击输入", "",
        //        (e) =>
        //        {
        //            string inputValue = e as string;
        //            GMLogic(inputValue);
        //        }, null, UIWidget.Pivot.Left, "确定", "取消", 0, UILayerType.FiveModule, 0);
        //}
        //xxj end
    }

    private void GMLogic(string input)
    {
        //xxj begin
        //if (string.IsNullOrEmpty(input))
        //{
        //    TipManager.AddTip("请输入正确指令");
        //}
        //input = input.Trim();


        //if (input.Contains("ver=")) //版本号
        //{
        //    string sp_version = input.Replace("ver=","");
        //    int SpVersionCode = GameSetting.ParseVersionCode(sp_version);
        //    GameServerInfoManager.RefreshServerList(SpVersionCode);
        //}
        //else if (input.Contains("device=")) //设备号
        //{
        //    ProxyWindowModule.OpenSimpleConfirmWindow(BaoyugameSdk.getUUID());
        //    return;
        //}
        //xxj end
    }

	private void OnClickAccountButton()
	{
        GameDebug.Log("OnClickAccountButton");
        //xxj begin
        //TalkingDataHelper.OnEvent("AccountButton");
        ////GameSetting.DeviceLoginMode = !GameSetting.DeviceLoginMode;
        //xxj end

        HideAccountUI();

        if (string.IsNullOrEmpty(ServerManager.Instance.sid))
        {
            OpenAccountLogin();
        }
        else
        {
            SPSdkManager.Instance.Logout(delegate (bool success) { OpenAccountLogin(); });
        }
    }

    private void HideAccountUI()
    {
        HideOtherUI();

        //xxj begin
        //View.NoticeButton_UIButton.gameObject.SetActive(false);
        //View.AccountButton_UIButton.gameObject.SetActive(false);
        //View.QRCodeScanBtn_UIButton.gameObject.SetActive(false);
        //View.LogoTexture_UITexture.cachedGameObject.SetActive(!GameSetting.QRcodeLogin);
        //xxj end
    }

    private void OnQRCodeScanBtnClick()
	{
        ProxyLoginModule.Hide();

        //xxj begin
        //ProxyQRCodeModule.OpenQRCodeScanView(OnQRCodeScanReturn);
        //xxj end
	}

	private void OnQRCodeScanReturn()
	{
        ProxyLoginModule.Show();
	}

	private void OpenAccountLogin()
	{
        //xxj begin
        //      if (PlayerPrefsExt.GetBool("PassAgreement") || !IsAgreementSupport())
        //{
        //        JSTimer.Instance.StartCoroutine(WaitOpenSDK());
        //}
        //else
        //{
        //	ProxyLoginModule.OpenAgreement(OpenSdk);
        //}
        //xxj end

        OpenSdk();
    }

	private IEnumerator WaitOpenSDK()
	{
		if (GameSetting.QRcodeLogin)
		{
			yield return new WaitForSeconds(0.3f);
			//            yield return null;
		}
		OpenSdk();
	}

	private void OpenSdk()
	{
        GameDebug.Log("OpenSdk...");
		//登录前移除旧监听
		SPSdkManager.Instance.OnLoginSuccess -= OnSwitchLoginSuccess;
		SPSdkManager.Instance.OnLogoutNotify -= OnLogout;
		SPSdkManager.Instance.OnLoginSuccess -= OnLoginSuccess;
		SPSdkManager.Instance.OnLoginCancel -= OnLoginCancel;
		SPSdkManager.Instance.OnLoginFail -= OnLoginFail;
        SPSdkManager.Instance.OnReLogin -= OnReLogin;
        //xxj begin
        //TalkingDataHelper.OnEventSetp("AppGameManager/OpenSdk"); //进入SDK登陆
        //xxj end
        SPSdkManager.Instance.OnLoginSuccess += OnLoginSuccess;
        SPSdkManager.Instance.OnLoginCancel += OnLoginCancel;
		SPSdkManager.Instance.OnLoginFail += OnLoginFail;
 
        //xxj begin
        //CancelInvoke("DelayShowSPLoginButton");
        //Invoke("DelayShowSPLoginButton", 2f);
        //xxj end

        //xxj begin
        //if (GameSetting.IsOriginWinPlatform && !ModelManager.SystemData.GetAndSaveInitScreenResolution())
        //{
        //    ProxySystemSettingModule.OpenSystemResolutionView(() => SPSdkManager.Instance.Login());
        //}
        //else
        //xxj end
        {
            SPSdkManager.Instance.Login();
        }
    }

	private void DelayShowSPLoginButton()
	{
        //xxj begin
  //      if (SPSdkManager.Instance.WaitingLoginResult)
		//{
		//	View.SPLoginButton_UIButton.gameObject.SetActive(true);
		//}
        //xxj end
	}

	private void HideSPLoginButton()
	{
        //xxj begin
	    //CancelInvoke("DelayShowSPLoginButton");
		//View.SPLoginButton_UIButton.gameObject.SetActive(false);
        //xxj end
	}

	private void OnLoginSuccess(bool isGuest, string sid)
	{
        GameDebug.Log("OnLoginSuccess isGuest:" + isGuest.ToString() + " sid:" + sid + " GameSetting.QRcodeLogin:" + GameSetting.QRcodeLogin.ToString() + " loginAccount:" + SdkAccountModel.Instance.loginAccount);

        HideSPLoginButton();

        //xxj begin
        //View.LoadingTips_UILabel.text = LoadingTipManager.GetLoadingTip();
        //xxj end

        ProxyWindowModule.closeSimpleWinForTop();

        ServerManager.Instance.isGuest = isGuest;
        ServerManager.Instance.sid = sid;

        SPSdkManager.Instance.OnLoginSuccess -= OnLoginSuccess;
        SPSdkManager.Instance.OnLoginCancel -= OnLoginCancel;
        SPSdkManager.Instance.OnLoginFail -= OnLoginFail;
        SPSdkManager.Instance.OnReLogin -= OnReLogin;

        SPSdkManager.Instance.OnLoginSuccess += OnSwitchLoginSuccess;
        SPSdkManager.Instance.OnLogoutNotify += OnLogout;
        SPSdkManager.Instance.OnReLogin += OnReLogin;

        //xxj begin
        //if (GameSetting.GMMode)
        //{
        //	LoginAccountDto loginAccountDto = new LoginAccountDto();
        //	loginAccountDto.token = sid;
        //	loginAccountDto.players = new List<AccountPlayerDto>();
        //	OnLoginSdkSuccess(loginAccountDto);
        //}
        //else
        //xxj end
        if (GameSetting.QRcodeLogin && SdkAccountModel.Instance.loginAccount == null)
        {
            GameDebug.Log("GameSetting.QRcodeLogin:" + GameSetting.QRcodeLogin + " SdkAccountModel.Instance.loginAccount:" + SdkAccountModel.Instance.loginAccount);

           OnLoginSdkSuccess(ServerManager.Instance.loginAccountDto);
        }
        else
        {
            //xxj begin
            //DoCommitLogin(sid);
            //xxj end

            string dataJson = "{\"sessionId\":\"" + sid + "\", \"uid\":\"\"}";
            string json = "{\"type\":\"login\",\"code\":\"0\",\"data\":" + dataJson + "}";
            GameDebug.Log("login json=" + json);
            SPSDK.OnSdkCallback(json);
        }
    }

    private void ShowErrorMsg(string msg)
    {
        if (string.IsNullOrEmpty(msg))
        {
            msg = "账号登陆失败， 请重试";
        }

        ProxyWindowModule.OpenMessageWindow(msg, "", OnClickAccountButton);
    }

    //xxj begin
    //private void DoCommitLogin(string sid)
    //{
    //    TalkingDataHelper.OnEventSetp("AppGameManager/RequestSsoAccountLogin"); //请求token
    //    ServiceProviderManager.RequestSsoAccountLogin(sid, ServerManager.Instance.uid, GameSetting.Channel, GameSetting.MutilPackageId,
    //        GameSetting.LoginWay, GameSetting.APP_ID, GameSetting.PlatformTypeId, BaoyugameSdk.getUUID(), GameSetting.CiluChannel, GameSetting.BundleId, AppGameVersion.BundleVersion,
    //        SPSdkManager.Instance.GetPackId(),
    //        delegate (LoginAccountDto response)
    //            {
    //                if (response != null && response.code == 0)
    //                {
    //                    OnLoginSdkSuccess(response);
    //                }
    //                else
    //                {
    //                    string msg = "账号登陆失败， 请重试";
    //                    if (response != null)
    //                    {
    //                        msg = response.msg;
    //                    }
    //                    ShowErrorMsg(msg);
    //                }
    //            });
    //}
    //xxj end

    private void OnLoginCancel()
	{
        GameDebug.Log("OnLoginCancel...");

        SPSdkManager.Instance.OnLoginSuccess -= OnLoginSuccess;
		SPSdkManager.Instance.OnLoginCancel -= OnLoginCancel;
		SPSdkManager.Instance.OnLoginFail -= OnLoginFail;
        SPSdkManager.Instance.OnReLogin -= OnReLogin;

        //因为渠道SDK的回调时序不固定， 会引发客户端重新打开SDK登陆后， SDK又关闭了，所以收到此回调后延迟一下再调用OpenSDK
        //CancelInvoke("OpenSdk");
        RequestLoadingTip.Show("", true, false, 0.5f);
		//Invoke("OpenSdk", 0.5f);

		View.SPLoginButton_UIButton.gameObject.SetActive(true);
	}

	private void OnLoginFail()
	{
        GameDebug.Log("OnLoginFail...");

        SPSdkManager.Instance.OnLoginSuccess -= OnLoginSuccess;
		SPSdkManager.Instance.OnLoginCancel -= OnLoginCancel;
		SPSdkManager.Instance.OnLoginFail -= OnLoginFail;
        SPSdkManager.Instance.OnReLogin -= OnReLogin;

        ProxyWindowModule.OpenMessageWindow("登陆失败", "提示");

		View.SPLoginButton_UIButton.gameObject.SetActive(true);
	}

    private void OnReLogin()
    {
        GameDebug.Log("OnReLogin...");

        //登录前移除旧监听
        SPSdkManager.Instance.OnLoginSuccess -= OnSwitchLoginSuccess;
        SPSdkManager.Instance.OnLogoutNotify -= OnLogout;
        SPSdkManager.Instance.OnLoginSuccess -= OnLoginSuccess;
        SPSdkManager.Instance.OnLoginCancel -= OnLoginCancel;
        SPSdkManager.Instance.OnLoginFail -= OnLoginFail;
        SPSdkManager.Instance.OnReLogin -= OnReLogin;

        SPSdkManager.Instance.OnLoginSuccess += OnLoginSuccess;
        SPSdkManager.Instance.OnLoginCancel += OnLoginCancel;
        SPSdkManager.Instance.OnLoginFail += OnLoginFail;
    }


    private void OnSwitchLoginSuccess(bool isGuest, string sid)
	{
        GameDebug.Log("OnSwitchLoginSuccess...  isGuest:" + isGuest.ToString() + " sid:" + sid);

        if (ServerManager.Instance.sid != sid)
        {
            ServerManager.Instance.isGuest = isGuest;
            ServerManager.Instance.sid = sid;

            ExitGameScript.Instance.DoReloginAccount(false);
        }
        else
        {
            ProxyWindowModule.closeSimpleWinForTop();
        }
    }

	private void OnLogout(bool success)
	{
        GameDebug.Log("OnLogout...  success:" + success.ToString());

        if (success)
		{
            ExitGameScript.OpenReloginTipWindow("您已经注销了账号， 请重新游戏", true);
        }
	}

	void OnApplicationPause(bool paused)
	{
	    CancelInvoke("CheckLoginResult");

		if (!paused)
		{
			if (SPSdkManager.Instance.WaitingLoginResult)
			{
				RequestLoadingTip.Show("", true, false, 0.5f);

				//Invoke("CheckLoginResult", 0.5f);
			}
		}
		else
		{

		}
	}

	private void CheckLoginResult()
	{
		if (SPSdkManager.Instance.WaitingLoginResult)
		{
			GameDebuger.Log("Check WaitingLoginResult and CancleLogin");
			SPSdkManager.Instance.CallbackLoginCancel();
		}
	}

	private void HideOtherUI()
	{
        //xxj begin
		//View.LoadingPanel_Transform.gameObject.SetActive(false);
		//View.AccountTipGroupWidget.cachedGameObject.SetActive(false);
		//View.StartPanel_Transform.gameObject.SetActive(false);
        //xxj end

		//View.ButtonGroup.SetActive(false);
	}

	private void OnClickAgreementButton()
	{
        //xxj begin
        //TalkingDataHelper.OnEventSetp("Agreement", "Open");
        //xxj end

		ProxyLoginModule.OpenAgreement();
	}


    //xxj begin
 //   private void OnClickStartGameButton()
	//{
 //       if (_currentServerInfo == null)
 //       {
 //           TipManager.AddTip("提示：选择服务器为空");
 //           return;
 //       }
 //       TalkingDataHelper.OnEvent("GameStart");

 //       AccountPlayerDto playerDto = null;

 //       if (GameDebuger.Debug_PlayerId != 0)
 //       {
 //           playerDto = new AccountPlayerDto();
 //           playerDto.nickname = GameDebuger.Debug_PlayerId.ToString();
 //           playerDto.id = GameDebuger.Debug_PlayerId;
 //           playerDto.gameServerId = 0;
 //       }
 //       else
 //       {
 //           playerDto = ServerManager.Instance.HasPlayerAtServer(_currentServerInfo.serverId);
 //       }

 //       Login(_currentServerInfo, playerDto);
 //   }
    //xxj end

    //xxj begin
    //    public void Login(GameServerInfo serverInfo, AccountPlayerDto accountPlayerDto)
    //	{
    //		if (serverInfo.runState == 3)
    //		{
    //			//TipManager.AddTip("服务器维护中，请稍候");
    //			//return;
    //		}

    //		if (_isLogined == false)
    //		{
    //			_isLogined = true;

    //			PlayerPrefs.SetString(GameSetting.LastServerPrefsName, serverInfo.GetServerUID());

    //			HideOtherUI();
    //			View.ButtonGroup.SetActive(false);

    //			ScreenMaskManager.FadeInOut(() =>
    //			{
    //                    //先屏蔽进度宠物显示
    ////                if (_modelController == null)
    ////                {
    ////                    _modelController = ModelDisplayController.GenerateUICom(_view.loadingSliderThumb);
    ////                    _modelController.Init(200, 200, new Vector3(-16.5f, -33.9f, 8.5f), 1f, ModelHelper.Anim_run, false);
    ////                    _modelController.SetOrthographic(1.2f);
    ////                    _modelController.SetupModel(2000);
    ////                    _modelController.transform.localPosition = new Vector3(-20f, 56f, 0f);
    ////                }

    //				View.LogoTexture_UITexture.cachedGameObject.SetActive(false);
    //				View.LoadingPanel_Transform.gameObject.SetActive(true);
    //                View.HealthTipLabel_UILabel.gameObject.SetActive(false);

    //				ShowVersion(false);

    //				if (_loginEffect != null)
    //				{
    //					_loginEffect.SetActive(false);
    //				}

    //				ServerManager.Instance.SetServerInfo(serverInfo);
    //				LoginManager.Instance.start(ServerManager.Instance.loginAccountDto.token, serverInfo, accountPlayerDto);
    //			}, 0f, 0.3f);
    //		}
    //	}
    //xxj end
    #region 排队

    //private QueueWindowPrefabController queueWindowCon;

    //private void OnWaitForLoginQueue(LoginQueuePlayerDto dto)
    //{
    //    _isLogined = false;
    //    //        if (queueWindowCon == null)
    //    //        {
    //    //            queueWindowCon = ProxyWindowModule.OpenQueueWindow("test", dto.waitCount.ToString(), dto.waitCd.ToString());
    //    //        }
    //    //        else
    //    //        {
    //    //            queueWindowCon.UpdateData("test",dto.waitCount.ToString(),dto.waitCd.ToString());
    //    //        }
    //}

    #endregion

    //xxj begin
    //   public void OnSelectionChange(string name)
    //{
    //	UpdateCurrentServerInfo(GameServerInfoManager.GetServerInfoByName(name));
    //}

    //private void UpdateCurrentServerInfo(GameServerInfo serverInfo)
    //{
    //	if (serverInfo != null && serverInfo.dboState == 1)
    //	{
    //		_currentServerInfo = serverInfo;
    //		PlayerPrefs.SetString(GameSetting.LastServerPrefsName, serverInfo.GetServerUID());
    //		ServerManager.Instance.SetServerInfo(serverInfo);
    //		View.LastLoginInfo_label_UILabel.text = ServerNameGetter.GetServerName(_currentServerInfo);
    //		View.LastLoginInfo_state_UISprite.spriteName =
    //               ServerNameGetter.GetServiceRunStateSpriteName(_currentServerInfo);
    //		AccountPlayerDto accountPlayerDto = ServerManager.Instance.HasPlayerAtServer(_currentServerInfo.serverId);
    //		if (accountPlayerDto != null)
    //		{
    //			View.LastLoginRoleInfo_label_UILabel.text = accountPlayerDto.nickname;
    //			View.LastLoginRoleInfo.SetActive(true);
    //		}
    //		else
    //		{
    //			View.LastLoginRoleInfo_label_UILabel.text = "";
    //			View.LastLoginRoleInfo.SetActive(false);
    //		}
    //	}
    //	else
    //	{
    //		View.LastLoginInfo_label_UILabel.text = "选择服务器";
    //		View.LastLoginInfo_state_UISprite.spriteName = "";
    //	}
    //}
    //xxj end


    //xxj begin
    //   private void OnClickLastLoginInfoButton()
    //{
    //       TalkingDataHelper.OnEventSetp("SelectServer", "显示服务器选择框");
    //       OpenServerListModule();
    //   }
    //xxj end

    //xxj begin
    //   public void OpenServerListModule()
    //{
    //       ProxyServerListModule.Open((serverInfo, accountPlayerDto) =>
    //       {
    //           UpdateCurrentServerInfo(serverInfo);

    //           Login(serverInfo, accountPlayerDto);
    //       });

    //   }
    //xxj end

    void OnLoginMessage(string msg)
	{
		View.LoadingLabel_UILabel.text = msg;
	}

	void OnLoginProcess(float percent)
	{
		View.loadingSlider_UISlider.value = percent;
	}
    private void ReleaseTexture(UITexture uiTexture)
    {
        if (uiTexture != null)
        {
            Texture tex = uiTexture.mainTexture;
            if (tex != null)
            {
                uiTexture.mainTexture = null;
                Destroy(tex);
            }
        }
    }

}
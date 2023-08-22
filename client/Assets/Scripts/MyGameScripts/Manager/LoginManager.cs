using System;
using System.Collections.Generic;
//using AppDto;
//using AppServices;
using GamePlot;
using UnityEngine;

public class LoginManager
{
	public static readonly LoginManager _instance = new LoginManager ();

	public static LoginManager Instance {
		get { return _instance; }
	}

	/**
     *登录管理器
     * @author senkay
     * @date Nov 6, 2010
     */
	public static readonly string ERROR_time_out = "链接超时";
	public static readonly string ERROR_socket_error = "网络错误";
	public static readonly string ERROR_socket_close = "网络已断开";
	public static readonly string ERROR_sid_error = "用户账号错误";
	public static readonly string ERROR_user_invalid = "用户无效";

	//private static readonly int MAX_TRY_COUNT = 5;

	//leave state
	public static uint LeaveState = 0;
	//close state
	public static uint CloseState = 0;

	private AccountPlayerDto _accountPlayerDto;

	public PayExtInfo PayExtInfo;

	private bool _afterLogin;

	private bool _keepSocket;

	//private PlayerDto _playerDto;

	private bool _reLogin;

	//	public delegate void CallOnTokenNotExist();
	//	public CallOnTokenNotExist callOnTokenNotExist;

	//private GameServerInfo _serverInfo;

	//public List<ServiceInfo> serviceInfoList = new List<ServiceInfo>();

	public string Token { get; private set; }

	public string LoginId { get; set; }

    //是否通过扫码登录
    public bool IsQrLogin { get; set; }

	public uint HaState { get; private set; }

	public bool KeepSocket {
		get { return _keepSocket; }
	}

	private HashSet<string> _requestingDataSet = new HashSet<string> ();

	private LoginManager ()
	{
		_keepSocket = true;
	}

	public event Action<string> OnLoginMessage;
	public event Action<float> OnLoginProcess;
	//public event Action<LoginQueuePlayerDto> OnWaitForLoginQueue;

	//断线重连成功后的回调//
	public event Action OnReloginSuccess;

    //xxj begin
	//public void start (string token, GameServerInfo serverInfo, AccountPlayerDto accountPlayerDto)
	//{
	//	_reLogin = false;
	//	HaState = HaStage.CONNECTED;

	//	_serverInfo = serverInfo;
	//	_accountPlayerDto = accountPlayerDto;
	//	_playerDto = null;
	//	_afterLogin = false;

	//	SPSdkManager.Instance.OnLoginSuccess += OnLoginSuccess;
	//	SPSdkManager.Instance.OnLogoutNotify += OnLogout;

	//	//        if (ServiceProviderManager.HasSP())
	//	//        {
	//	//            _token = null;
	//	//        }
	//	//        else
	//	//        {
	//	Token = token;
	//	//        }

	//	if (GameSetting.GMMode) {
	//		if (GameDebuger.Debug_PlayerId != 0) {
	//			_accountPlayerDto = new AccountPlayerDto ();
	//			_accountPlayerDto.nickname = GameDebuger.Debug_PlayerId.ToString ();
	//			_accountPlayerDto.id = GameDebuger.Debug_PlayerId;
	//			_accountPlayerDto.gameServerId = 0;
	//		}
	//	}

	//	if (!DataManager.AllDataLoadFinish) {
	//		UpdateStaticData ();
	//	} else {
	//		DataLoadingMsgProcess (1f);
	//		ConnectSocket ();
	//	}
	//}
    //xxj end

	private void ConnectSocket ()
	{
		ProxyLoginModule.Show ();

        //xxj begin
		//ServiceRequestActionMgr.Setup ();

		//SocketManager.Instance.Setup ();
		//SocketManager.Instance.OnHAConnected += HandleOnHAConnected;
		//SocketManager.Instance.OnHaError += HandleOnHaError;
		//SocketManager.Instance.OnHaCloseed += HandleOnHaCloseed;
		//SocketManager.Instance.OnStateEvent += HandleOnStateEvent;

		//GameDebuger.Log ("Login With " + Token + " At " + _serverInfo.host + ":" + _serverInfo.port + " accessId=" +
		//_serverInfo.serviceId + " gameServerId=" + _serverInfo.serverId);
		//PrintLog ("连接服务器...");

  //      TalkingDataHelper.OnEventSetp ("AppGameManager/ConnectSocket"); //连接服务器
		//Connect ();
        //xxj end
	}

	private void HandleOnStateEvent (uint state)
	{
		HaState = state;

        //xxj begin
		//if (HaState == HaStage.LOGINED && _playerDto != null && DataManager.AllDataLoadFinish) {
		//	DoLogin (_playerDto);
		//}
        //xxj end
	}

	private void HandleOnHAConnected ()
	{
		GameDebuger.Log ("OnHAConnected");
		
		ShowMessageBox ("账号验证中，请稍候...");

		if (_reLogin) {
            //xxj begin
			//_playerDto = null;
            //xxj end
		}
        else
        {
            //xxj begin
            //TalkingDataHelper.OnEventSetp ("AppGameManager/HandleOnHAConnected"); //连接服务器成功
            //xxj end
        }

		OnRequestTokenCallback (Token, "");

		ExitGameScript.CheckConnected = true;
		ExitGameScript.NeedReturnToLogin = false;
		ExitGameScript.WaitForReConnect = false;
	}

	private void HandleOnHaError (string msg)
	{
        //xxj begin
        //如果服务器是维护状态， 则修改下提示语
        //if (_serverInfo.runState == 3)
        //{
        //    msg = "服务器维护中， 请稍后访问";
        //}
        //xxj end

		Destroy ();

		LayerManager.Instance.LockUICamera (false);

        //xxj begin
		//ProxyWindowModule.OpenSimpleMessageWindow (msg, delegate {
  //          ProxyRoleCreateModule.Close();
  //          ProxyRoleCreateModule.CloseAnotherCreateRoleView();
  //          GotoLoginScene ();
		//}, UIWidget.Pivot.Left, null,
		//	UILayerType.TopDialogue);
        //xxj end

		ShowMessageBox (msg);
	}

	private void HandleOnHaCloseed (uint status)
	{
		LayerManager.Instance.LockUICamera (false);

        //xxj begin
		//GameCheatManager.Instance.Dispose();
        //xxj end

		if (LayerManager.Instance.CurUIMode == UIMode.NULL) {
            //处理创建HA断开的提示
            if (status == HaNet.EventObject.Close_status_ConnectOutTime || status == HaNet.EventObject.Close_status_StarConnectClose)
            {
                ExitGameScript.OpenReloginTipWindow (string.Format ("无法连接服务器，请检查网络设置[{0}]", status));
            }
            else
            {
                ExitGameScript.OpenReloginTipWindow (string.Format ("网络中断, 请重新进入游戏[{0}]", status));
            }            
		} else {
			ExitGameScript.CheckConnected = true;
		}
	}

	private void Connect ()
	{
        //xxj begin
		//SocketManager.Instance.Connect (_serverInfo);
        //xxj end
	}

    public void OnRequestTokenCallback(string token, string errorMsg)
    {
        //测试审核服
        //ServerManager.Instance.isReviewMode = true;

        Token = token;
        if (Token == null)
        {
            ShowMessageBox("账号验证失败:" + errorMsg);

            LayerManager.Instance.LockUICamera(false);

            ProxyWindowModule.OpenSimpleMessageWindow("账号验证失败:" + errorMsg, delegate
            {
                GotoLoginScene();
            },
                UIWidget.Pivot.Left, null, UILayerType.TopDialogue);
        }
        else
        {
            //xxj begin
            //if (ProxyRoleCreateModule.IsOpen() || ProxyRoleCreateModule.IsAnotherCreateRoleViewOpen() && ServerManager.Instance.isReviewMode)
            //{
            //    LayerManager.Instance.LockUICamera(false);
            //    Login();
            //}
            //else
            //{

            //    if (_accountPlayerDto == null)
            //    {
            //        ServiceRequestAction.requestServer(PlayerLoginService.whiteListCheck(token, _serverInfo.serverId), "whiteListCheck", (e) =>
            //        {
            //            _onLoadCreateFinish = OnLoadCreateFinish;
            //            if (ServerManager.Instance.isReviewMode == false)
            //            {
            //                AssetPipeline.AssetManager.Instance.LoadLevelAsync("CreatePlayer", false,
            //                () =>
            //                {
            //                    if (_onLoadCreateFinish != null)
            //                    {
            //                        _onLoadCreateFinish();
            //                        _onLoadCreateFinish = null;
            //                    }
            //                });
            //            }
            //            else
            //            {
            //                if (_onLoadCreateFinish != null)
            //                {
            //                    _onLoadCreateFinish();
            //                    _onLoadCreateFinish = null;
            //                }
            //            }
            //        }, (err) =>
            //        {
            //            ExitGameScript.OpenReloginTipWindow(err.message, false);
            //        });

            //    }
            //    else
            //    {
            //        Login();
            //    }
            //}
            //xxj end
        }
    }


    private System.Action _onLoadCreateFinish;
    public void OnLoadCreateFinish()
    {
        RequestLoadingTip.Reset();

        //xxj begin
        //ProxyLoginModule.Hide();
        //if(ServerManager.Instance.isReviewMode == false)
        //{
        //    ProxyRoleCreateModule.Open(_serverInfo, CreatePlayerSuccess);
        //}
        //else
        //{
        //    ProxyRoleCreateModule.OpenAnotherCreateRoleView(_serverInfo, CreatePlayerSuccess);
        //}
        //xxj end
    }

    public bool SupportRelogin ()
	{
        //xxj begin
		//return _serverInfo != null && SocketManager.Instance.IsSetup ();
        //xxj end

        return false;
	}

	public void ReConnect ()
	{
        //xxj begin
		//if (_serverInfo != null) {
		//	_reLogin = true;
		//	_afterLogin = false;

		//	LayerManager.Instance.LockUICamera (true);

		//	Connect ();
		//}
        //xxj end
	}

    //xxj begin
	//private void Login ()
	//{
	//	if (Token != null)
	//	{
 //           if (HaState == HaStage.LOGINED && _playerDto != null) {
	//			DoLogin (_playerDto);
	//		} else {
	//			PrintLog ("账号登录...");
	//			string ip = HaApplicationContext.getConfiguration().getLocalIp();

	//			GameDebuger.Log ("LoginFromIp = " + ip);

	//			if (_accountPlayerDto != null) {
 //                   TalkingDataHelper.OnEventSetp ("AppGameManager/ReqeustLogin"); //请求登陆
	//				ServiceRequestAction.requestServer (
	//					PlayerLoginService.loginWithDeviceId (Token, ip,
	//						_accountPlayerDto.id, BaoyugameSdk.getUUID ()), "账号登录",
	//					OnLogin, OnNotLogin);
	//			} else {
	//				if (_reLogin) {
	//					RequestLoadingTip.Reset ();
	//					CallBackReLogin ();
	//				}
	//			}
	//		}
	//	}
	//}
    //xxj end

    //xxj begin
	//private void CreatePlayerSuccess (GeneralResponse e)
	//{
	//	ProxyLoginModule.Show ();

 //       PlayerDto playerDto = null;
	//    if (e is QueInfoDto)
	//    {
	//        playerDto = (e as QueInfoDto).playerDto;
 //       }
 //       else if (e is PlayerDto)
 //       {
 //           playerDto = e as PlayerDto;
 //       }
	//    if (playerDto != null)
	//    {
	//        ModelManager.Player.SubmitCreateRoleData(1, playerDto);
	//    }

 //       LoginHandle(e);
	//}
    //xxj end

    //xxj begin
 //   private void OnNotLogin (ErrorResponse e)
	//{
	//	GameDebuger.Log ("OnNotLogin: ErrorResponse Message:" + e.message);
	//	PrintLog ("登录失败！");

	//	if (e.id == 19) {
 //           //如果是PC端扫码登录，直接提示重新进入扫码流程
	//	    if (GameSetting.QRcodeLogin && IsQrLogin)
	//	    {
 //               ExitGameScript.OpenReloginTipWindow("会话超时，请重新登录", true);
	//	        return;
	//	    }
	//		//会话ID失效
	//		ServiceProviderManager.RequestSsoAccountLogin (ServerManager.Instance.sid, ServerManager.Instance.uid, GameSetting.Channel,
 //               GameSetting.MutilPackageId, GameSetting.LoginWay, GameSetting.APP_ID, GameSetting.PlatformTypeId, BaoyugameSdk.getUUID (), GameSetting.CiluChannel, GameSetting.BundleId, AppGameVersion.BundleVersion,
	//			SPSdkManager.Instance.GetPackId(),
 //               delegate (LoginAccountDto response) {
	//				if (response != null && response.code == 0) {
	//					Token = response.token;
	//					Login ();
	//				} else {
	//					string msg = "服务器请求失败，请检查网络";
	//					if (response != null) {
	//						msg = response.msg;
	//					}

	//					ExitGameScript.OpenReloginTipWindow (msg, true);
	//				}
	//			});
	//	} else if (e.id == 28) {
	//		//访问受限，白名单
	//		ExitGameScript.OpenReloginTipWindow (e.message, false);
	//	} else {
	//		//其它错误
	//		ExitGameScript.OpenReloginTipWindow (e.message, false);
	//	}
	//}
    //xxj end

    //xxj begin
	//private void OnLogin (GeneralResponse e)
	//{
	//    LoginHandle(e);
 //   }

 //   private void LoginHandle(GeneralResponse e)
 //   {
 //       if (e is QueInfoDto)
 //       {
 //           var queInfoDto = (QueInfoDto)e;

 //           if (queInfoDto.createDto != null)
 //           {
 //               _accountPlayerDto = ServerManager.Instance.AddAccountPlayer(queInfoDto.createDto);
 //           }

 //           if (queInfoDto.playerDto != null)
 //           {
 //               SystemTimeManager.Instance.Setup(queInfoDto.playerDto.gameServerTime);
 //               _accountPlayerDto = ServerManager.Instance.AddAccountPlayer(queInfoDto.playerDto);

 //               if (HaState == HaStage.LOGINED)
 //               {
 //                   GameDebuger.Log("登录成功");
 //                   if (DataManager.AllDataLoadFinish)
 //                   {
 //                       DoLogin(queInfoDto.playerDto);
 //                   }
 //                   else
 //                   {
 //                       GameDebuger.Log("等待allDataLoadFinish");
 //                       _playerDto = queInfoDto.playerDto;
 //                   }
 //               }
 //               else
 //               {
 //                   GameDebuger.Log("等待HaStage.LOGINED");
 //                   _playerDto = queInfoDto.playerDto;
 //               }
 //           }
 //           //排队
 //           else
 //           {
 //               GameDebuger.Log("登陆排队");
 //               LoginQueue1((QueInfoDto)e);
 //           }
 //       }
 //       else if (e is PlayerDto)
 //       {
 //           // 2017-8-15 和 后端小巫了解过
 //           // PlayerLoginService.loginWithDeviceId
 //           // PlayerLoginService.createWithDeviceId
 //           // 服务器是不会返回 PlayerDto,统一用 QueInfoDto 
 //           // by willson
 //           var playerDto = e as PlayerDto;

 //           SystemTimeManager.Instance.Setup(playerDto.gameServerTime);
 //           _accountPlayerDto = ServerManager.Instance.AddAccountPlayer(playerDto);

 //           if (HaState == HaStage.LOGINED)
 //           {
 //               GameDebuger.Log("登录成功");
 //               if (DataManager.AllDataLoadFinish)
 //               {
 //                   DoLogin(playerDto);
 //               }
 //               else
 //               {
 //                   GameDebuger.Log("等待allDataLoadFinish");
 //                   _playerDto = playerDto;
 //               }
 //           }
 //           else
 //           {
 //               GameDebuger.Log("等待HaStage.LOGINED");
 //               _playerDto = playerDto;
 //           }
 //       }
 //   }
    //xxj end

    //xxj begin
 //   private void OnQueueLogin (PlayerDto playerDto)
	//{
	//	SystemTimeManager.Instance.Setup (playerDto.gameServerTime);
	//	_accountPlayerDto = ServerManager.Instance.AddAccountPlayer (playerDto);
	//	//        Debug.LogError("haState++++++++++++++" + haState + "----------" + HaStage.LOGINED);
	//	if (HaState == HaStage.LOGINED) {
	//		GameDebuger.Log ("登录成功");
	//		DoLogin (playerDto);
	//	} else {
	//		GameDebuger.Log ("等待HaStage.LOGINED");
	//		_playerDto = playerDto;
	//	}
	//}
    //xxj end

    //xxj begin
	//private void DoLogin (PlayerDto playerDto)
	//{
	//	PlayerPrefs.SetString (GameSetting.LastRolePrefsName, playerDto.id.ToString ());

	//	if (playerDto.sceneId == 0) {
	//		Debug.LogError ("set test data PlayerDto.sceneId = 1003");
	//		playerDto.sceneId = 1003;
	//	}
        
	//	ModelManager.Player.Setup (playerDto);

	//	if (_afterLogin == false) {
	//		AfterLogin ();
	//	}

	//	// 由于登陆那里还没有PlayerId，所以无法恢复购买
	//	// 因此在这里做恢复购买的操作
	//	PayManager.Instance.RestoreCompletedTransactions ();


 //       //初始化完成后，上传角色数据
 //       ModelManager.Player.SubmitRoleData(0);
 //       //		if (_reLogin)
 //       //		{
 //       //			CallBackReLogin();
 //       //
 //       //			int sceneId = ModelManager.Player.GetPlayer ().sceneId;
 //       //			ServiceRequestAction.requestServer (SceneService.enter (sceneId));
 //       //		}
 //   }
    //xxj end

	//private void OnReLogin(GeneralResponse e)
	//{
	//    var playerDto = e as PlayerDto;

	//    if (playerDto != null)
	//    {
	//        GameDebuger.Log("重新登录成功");
	//        TipManager.AddTip("重新登录成功");
	//        ModelManager.Player.Setup(playerDto);

	//        //统一在重新登陆后调用logon， 来获取新的信息, 例如战斗
	//        //ServiceRequestAction.requestServer(PlayerService.logon());
	//        CallBackReLogin();

	//        //WorldManager.Instance.ReEnterScene();
	//    }
	//    else
	//    {
	//        GameDebuger.Log("重新登录失败");

	//        ExitGameScript.OpenReloginTipWindow("重新登陆失败， 请重新进入游戏");
	//    }
	//}

	public void UpdateStaticData ()
	{
        //xxj begin
  //      TalkingDataHelper.OnEventSetp ("AppGameManager/UpdateStaticData"); //更新静态数据并加载
		//DataManager.Instance.UpdateStaticData (OnPreLoadDataFinish, OnAllStaticDataFinish, DataLoadingMessage, DataLoadingMsgProcess);
        //xxj end
	}

	private void DataLoadingMessage (string msg)
	{
		if (OnLoginMessage != null) {
			OnLoginMessage (msg);
		}
	}

	private void DataLoadingMsgProcess (float msgProcess)
	{
		if (OnLoginProcess != null) {
			OnLoginProcess (msgProcess);
		}
	}

	private void OnPreLoadDataFinish ()
	{
		GameDebuger.Log ("OnPreLoadDataFinish");

		//创建新角色
		if (_accountPlayerDto == null) {
			ConnectSocket ();
		}
	}

	private void OnAllStaticDataFinish ()
	{
        //xxj begin
  //      TalkingDataHelper.OnEventSetp ("AppGameManager/GetStaticDataSuccess"); //游戏数据加载完成
		//DataLoadingMsgProcess (1f);

  //      try
  //      {
  //          //检查执行在线更新
  //          OnlineUpdate.CheckExcOnlineUpdate();
  //      }
  //      catch (Exception e)
  //      {
  //          //显示处理，方便处理bug
  //          TipManager.AddTip("静态数据执行出错");
  //          GameDebuger.LogError(e);
  //      }

  //      if (_playerDto == null && _accountPlayerDto != null) {
		//	ConnectSocket ();
		//} else {
		//	Login ();
		//}
        //xxj end
	}

	public void InitRequestDataFlag ()
	{
		_requestingDataSet.Clear ();
		LayerManager.Instance.LockUICamera (true);

        //xxj begin
		//_requestingDataSet.Add (ModelManager.Guild.ToString ());
		//_requestingDataSet.Add (ModelManager.Backpack.ToString ());
		//_requestingDataSet.Add (ModelManager.Warehouse.ToString ());
       
		//_requestingDataSet.Add (ModelManager.Fashion.ToString ());
		//_requestingDataSet.Add (ModelManager.Email.ToString ());
		//_requestingDataSet.Add (ModelManager.Friend.ToString ());
		//_requestingDataSet.Add (ModelManager.MissionModel.ToString ());
		//_requestingDataSet.Add (ModelManager.Crew.ToString ());
        //xxj end
	}

    private void AfterLogin()
    {
        InitRequestDataFlag();

        //xxj begin
//        NotifyListenerRegister.Setup();
//        FunctionOpenHelper.Setup();

//        PrintLog("获取角色数据...");

//        TalkingDataHelper.OnEventSetp("AppGameManager/RequestAfterLogin"); //请求AfterLogin


//        ServiceRequestAction.requestServer(PlayerService.afterLogin(), "AfterLogin", e =>
//        {
////            ProfileHelper.SystimeEnd_FishLog("AfterLogin response----------");
//            if (HaApplicationContext.getConnector() != null)
//            {
//                HaApplicationContext.getConnector().IgnoreMaxHandleMgr();
//            }
//            else
//            {
//                GameDebuger.LogError("afterLogin.getConnector == null");
//            }
//            //设置保存的自动巡逻
//            ModelManager.Player.IsAutoFram = PlayerGameState.IsAutoFram;

//            _afterLogin = true;
//            var afterLoginDto = e as AfterLoginDto;

//            ModelManager.Setup(afterLoginDto);

//            /** 玩家相关信息 */
//            ModelManager.Player.SetupFromAfterLogin(afterLoginDto);

//            ModelManager.Activity.Setup(afterLoginDto);

//            //武道赛
//            ModelManager.BodoModel.SetUp();

//            // 注意这个一定要放在玩家数据初始化后 : ModelManager.Player.SetupFromAfterLogin 后面
//            ModelManager.Team.Setup(afterLoginDto);

//            /** 当天已卖出宠物次数 */
//            ModelManager.TradePet.DayCanSellAmount = afterLoginDto.dailyTotalSellPet;

//            /** 门派技能信息 */
//            ModelManager.FactionSkill.Setup(afterLoginDto.factionSkillsInfo);

//            /** 辅助技能信息 */
//            ModelManager.AssistSkill.Setup(afterLoginDto.assistSkillInfo);

//            /** 剧情技能 */
//            ModelManager.ScenarioSkill.Setup(afterLoginDto.scenarioSkillInfo);

//            /** 修炼技能*/
//            ModelManager.Spell.Setup(afterLoginDto.spellsInfo);

//            /** 宠物信息 */
//            ModelManager.Pet.Setup(afterLoginDto.petCharactorDtos, afterLoginDto.companyPetVacancy, afterLoginDto.petBlessValues);


//            //BattleValueChangeModel 的创建 需要在 PlayerModel，， PetModel 这些创建之后才创建自己， 否则战力计算时没有相关数据， 以后战力计算规则改变这里得相应修改
//            ModelManager.BattleValueChange.SetUp();

//            /** 玩家状态栏信息 */
//            ModelManager.PlayerBuff.Setup(afterLoginDto.stateBarDtos);

//            /** 帮派信息 */
//            ModelManager.Guild.UpDateGuildInfo();

//            GameDataManager.Instance.Setup(() =>
//            {
//                ModelManager.Backpack.Setup();
//                ModelManager.Warehouse.Setup();
//                ModelManager.Fashion.Setup();
//                ModelManager.MagicEquipment.Setup();
//            });

//            ModelManager.DailyPush.Setup(afterLoginDto.state);
//            ModelManager.WeeklyMissionContent.Setup();
//            // 获取邮件
//            /** 玩家已赠送数量-价值信息 */
//            ModelManager.Email.Setup(afterLoginDto.giftDto);
//            //初始化聊天系统数据
//            ModelManager.Chat.Setup();
//            //初始化好友聊天记录
//            ModelManager.Friend.Setup();

//            //登陆播放剧情
//            GamePlotManager.Instance.Setup();
//            GamePlotManager.Instance.SetLastPlotId(afterLoginDto.plotId);

//            //交易系统Model
//            ModelManager.TradeData.SetupFromAfterLogin(afterLoginDto);

//            //	摆摊系统红点
//            ModelManager.TradeData.SetUpMarketRemind();

//            //	拍卖系统红点
//            ModelManager.TradeData.SetUpAuctionRemind();

//            // 成就系统奖励红点
//            ModelManager.Achievement.GetMyAchievementInfo();
//            //	奖励系统相关
//            ModelManager.Reward.Setup(afterLoginDto);
//            //渠道开关设置
//            ChannelManager.Instance.UpdateState(afterLoginDto.channelState);

//            //	场景怪物战斗模块数据处理
//            ModelManager.SceneMonster.SetUp(afterLoginDto.starRewardCount, afterLoginDto.worldBossRewardCount);

//            //	获取任务数据( 外联海上贸易 \ 外联帮派任务 \ 外联封妖日常 \ 内联全部任务 )
//            ModelManager.MissionModel.Setup(()=>
//            {
//                ModelManager.MissionView.Setup(ModelManager.MissionModel);
//                //	商店购买物品数据
//                ModelManager.MissionShopItemMarkModel.GetCollectionMarkItemIDListByTradeShopType(true);

//                ModelManager.BusinessModel.Enter();
//                ModelManager.FieldMonster.SetUp();
//                // ModelManager.MissionModel.GetGuildMissionFormService(true);
//                //功能开放中添加完成任务条件
//                //以下系统必须要在主线任务数据初始化完毕之后才能初始化
//                //如果后续还有其他任务，则继续添加在这个回调中即可

//                //坐骑系统
//                ModelManager.Ride.Setup();

//                //神器
//                ModelManager.Artifact.SetUp();

//                //法宝系统
//                ModelManager.TalismanSystem.SetUp(afterLoginDto.talismanGrowTimes);

//                //假面舞会活动
//                ModelManager.MasqueradeModel.SetupFromAfterLogin(afterLoginDto);

//                //押镖任务
//                ModelManager.EscortDartModel.SetupFromAfterLogin(afterLoginDto);
//            });
//            ModelManager.Trial.EnterTrialData();

//            NpcModelModule.Instance.SetUpNpcModelModule();

//            ModelManager.Crew.Setup();
//            ModelManager.Crew.SetupCrewRelation(afterLoginDto.crewRelationEnterDto);

//            //银宝箱
//            ProxyTreasureMapModule.openPreciousBoxCount = afterLoginDto.openPreciousBox;
//            //摇钱树
//            ModelManager.DailyPush.MoneyTreeDto = afterLoginDto.moneyTreeDto;

//            ModelManager.InstanceZonesModule.SetUp();
            
//            //	比武\争霸
//            ModelManager.Tournament.SetUp();
//            ModelManager.ChiefPlay.SetUp();
//            ModelManager.HeroTrial.SetUp();

//            //竞技场
//            ModelManager.Arena.SetUp();

//            //	幻境
//            ModelManager.DreamlandData.SetUp();

//            //开服活动通知
//            ModelManager.NewestActivity.Setup(afterLoginDto.gameActivityOpenNotifyList);

//            //	系统设置
//            ModelManager.SystemData.SetUpOnLogined();

//            // 结婚信息
//            ModelManager.Marry.Setup();

//            //成长指引
//            ModelManager.GrowUpGuide.SetUp(afterLoginDto.growthMissions);
//            ModelManager.GrowUpGuide.InitOpenIds();

//            // 红包数据
//            ModelManager.RedPacket.UpdateUnOpenedRedPacketList(afterLoginDto.packIds);

//            //	帮派竞赛
//            ModelManager.GuildCompetitionData.SetUp();

//            //	大闹天宫
//            ModelManager.CampWarData.SetUp();

//            //	护送国宝
//            ModelManager.Escort.SetUp();

//            // 世界Boss
//            ModelManager.SnowWorldBoss.SetUp();

//            //	月光宝盒
//            ModelManager.MoollightBox.Setup();

//            // 师徒系统（玩家师徒状态）
//            //ModelManager.TeacherPupil.Setup();

//            ModelManager.Report.SetSelfReportTimes(afterLoginDto.reportCount);


//            ModelManager.TargetGuide.Setup(afterLoginDto);

//            // 帮派百草谷
//            ModelManager.GuildHundredGrassValley.Setup();

//            // 迷宫
//            ModelManager.ArtifactMaze.Setup();

//            //暂时不需要
////			ModelManager.Consignment.Setup (afterLoginDto);

//            ModelManager.CSPK.Setup(afterLoginDto);

//            //周卡月卡
//            ModelManager.FavourableCardReward.CheckOutFavourableCardState();

//            //饱食度
//            ModelManager.Player.CheckOutSatiationState();

//            //大唐无双
//            ModelManager.Tang.SetUp();

//            //	决斗
//            ModelManager.DuelData.SetUp();

//            //世界答题数据
//            ModelManager.Question.SetUp();

//            // 赏月
//            ModelManager.MoonEnjoy.Setup();

//            //奖励找回
//            ModelManager.FindbackReward.Setup();

//            // 新手常量数据初始化
//            ModelManager.NewBieGuide.Setup();

//            //阵营数据初始化
//            ModelManager.CampBattleData.SetUp();

//            //官职
//            ModelManager.OfficialPosition.Setup(() => { ModelManager.OfficialPosition.UpdateOfficialPositionRedPoint(); });

//            //八卦炉
//            ModelManager.GossipFurnace.Setup();

//            //红点管理
//            ModelManager.RedPoint.SetUp();

//            //手机验证
//            ModelManager.PhoneVerify.SetUp(ModelManager.Player.GetPlayer());

//            //客服反馈
//            ModelManager.CustomerService.SetUp();

//            //赏金任务
//            ModelManager.Bounty.SetUpByAfterLogin();

//            //开服大甩卖活动
//            ModelManager.NewGuyPromotionReward.SetUp(afterLoginDto);

//            //天宫赐福
//            ModelManager.TreasureActivity.SetUp();

//            //超级返利
//            ModelManager.SuperRebateActivity.SetUp();

//            //幸运转盘
//            ModelManager.LuckyRewardTurntableModel.SetupFromAfterLogin();

//            //商城
//            ModelManager.MallShopping.Setup();

//            //子女系统
//            ModelManager.OffspringsModelData.SetUp();

//            //海底冒险
//            ModelManager.SeabedAdventureModel.SetupFromAfterLogin(afterLoginDto);

//            //装饰
//            ModelManager.RoleDecorateData.Setup();
//            // 累计消费
//            ModelManager.AccumulatedConsumptionData.SetUp(afterLoginDto);

//            //头像框
//            ModelManager.HeadPortraitModel.SetupFromAfterLogin(afterLoginDto);

//            //气泡
//            ModelManager.BubbleModel.SetupFromAfterLogin(afterLoginDto);

//            //表情
//            ModelManager.EmoticonModel.SetupFromAfterLogin(afterLoginDto);

//            //烟花豪礼
//            ModelManager.fireworkGiftModel.SetUp(afterLoginDto);

//            //天天福缘
//            ModelManager.DaydayBlessRewardModel.SetUp(afterLoginDto);

//            //天天豪礼
//            ModelManager.DaydayBigGiftRewardModel.SetUp(afterLoginDto);

//            //连续登录
//            ModelManager.ContinueLoginRewardModel.SetUp(afterLoginDto);

//            //初始化本地通知数据
//            NotificationInterface.InitLocalData();

//            //投资基金
//            ModelManager.InvestmentFundModel.SetUp(afterLoginDto);

//            //开服竞赛
//            ModelManager.OpenSeverRaceModel.SetUp();

//            //发呆一定时间推送推荐活动
//            ModelManager.PopupRecommendActivityModel.SetupPopupActivityCheck();

//            //节日集字
//            ModelManager.FestivalCollectData.SetUp(afterLoginDto);

//            //中秋礼盒
//            ModelManager.MidAutumnBoxModel.SetUp(afterLoginDto);

//            //国泰民安（国庆单人活动)
//            ModelManager.NationalDayPersonMissionModel.SetupFromAfterLogin(afterLoginDto);

//            //双节入口
//            ModelManager.DoubleFestivalEntranceModel.SetUp(afterLoginDto);

//            ModelManager.NationalSignin.SetUp(afterLoginDto);

//            //元宝狂欢
//            ModelManager.IngotCarnivalModel.SetUp();

//            //连环礼包
//            ModelManager.ChainGiftReward.Setup(afterLoginDto);

         

//            //打地鼠
//            //ModelManager.HitMonkeyModel.SetUp();

//            //微端
//            ModelManager.GameResManagementModel.SetUp(afterLoginDto);

//            //宝石转换
//            ModelManager.ChangeGem.SetupFromAfterLogin(afterLoginDto);

//            //许愿树
//            ModelManager.LuckyWishingTreeModel.SetUp();

//            //每日榜
//            ModelManager.EveryDayRankingModel.SetUp();

//            //连环消费
//            ModelManager.ChainConsumeUIModel.Setup();

//            //个人空间
//            ModelManager.SelfZone.SetUp();

//            //入口
//            ModelManager.EntranceModel.SetupFromAfterLogin(afterLoginDto);

//            //圣诞单人任务
//            ModelManager.ChristmasSingleMissionModel.SetupFromAfterLogin(afterLoginDto);

//            //孵蛋狂欢
//            ModelManager.IncubateCarnivalModel.SetupFromAfterLogin(afterLoginDto);

//            //连环消费
//            ModelManager.ContinueConsumeModel.Setup();

//            //圣诞翻翻乐
//            ModelManager.ChristmasHappyRollModel.SetUp();

//            //小游戏
//            ModelManager.SmallGameModel.SetupFromAfterLogin(afterLoginDto);

//            //角色转换
//            ModelManager.ChangePartBaeControllerModel.Setup(afterLoginDto);

//            //武器转换
//            ModelManager.ChangeWeaponControllerModel.Setup(afterLoginDto);

//            //精英乱斗
//            ModelManager.EliteScuffleModel.SetupFromAfterLogin(afterLoginDto);

//            //神秘商店
//            ModelManager.SercretShopWinModel.SetUp(afterLoginDto);

//            //跨服工具
//            ModelManager.CrossServerModel.SetUp();

//            //葫芦娃
//            ModelManager.CalabashBroModel.SetUp();

//            //葫芦娃翻翻乐
//            ModelManager.FlipFlipHappyModel.SetupFromAfterLogin(afterLoginDto);

//            //神秘宝箱
//            ModelManager.SecretBoxModel.SetUp(afterLoginDto);

//            //春节大礼包
//            ModelManager.SpringFestivalGiftModel.SetUp(afterLoginDto);

//            //春节商城打折
//            ModelManager.SpringFestivalShopDiscountModel.SetUp(afterLoginDto);


//            //春节大拜年
//            ModelManager.SpringFestivalCallOnModel.SetupFromAfterLogin(afterLoginDto);

//            //元宵闹花灯
//            ModelManager.DisportFestivalLanternModel.SetupFromAfterLogin(afterLoginDto);

//            //大富翁地图数据
//            ModelManager.MillionaireMapGridModel.SetupFromAfterLogin(afterLoginDto);

//            //守岁除年
//            ModelManager.MonsterNianModel.SetUp(afterLoginDto);

//            //春节累计充值
//            ModelManager.SpringFestivalRechargeModel.SetUp(afterLoginDto);

//            //春节合家欢
//            ModelManager.ReunionDinnerModel.Setup();

//            //元宵灯谜任务
//            ModelManager.LanternRiddlesMissionModel.SetUp();

//            //打地鼠
//            ModelManager.HitMonkeyModel.SetUp();
    
//        });
    //xxj end
    }

public void RemoveRequestDataFlag (string key)
	{
		_requestingDataSet.Remove (key);
		GameDebuger.Log ("_requestingDataSet.Count = " + _requestingDataSet.Count + " key=" + key);

        //xxj begin
		//if (_requestingDataSet.Count == 0) {
		//	LayerManager.Instance.LockUICamera (false);
		//	GameDebuger.Log ("登录数据加载完成");
  //          if (HaApplicationContext.getConnector() != null)
  //          {
  //              HaApplicationContext.getConnector().ResetMaxHandleCount();
  //          }

  //          EnterScene();
		//}
        //xxj end
	}

    //进入游戏场景
    private void EnterScene()
    {
        RequestLoadingTip.Reset();

        GameDebuger.Log ("EnterScene");

        //xxj begin
        //TalkingDataHelper.OnEventSetp ("AppGameManager/EnterGame"); //进入游戏
        //xxj end

        if (_reLogin) {
            CallBackReLogin ();
        }

        PrintLog("载入场景资源...");

        //xxj begin
        //if (GamePlotManager.Instance.HasLastPlot())
        //{
        //    GamePlotManager.Instance.OnFinishPlot += OnFinishPlot;
        //    GamePlotManager.Instance.PlayLastPlot();
        //}
        //else
        //{
        //    ProxyMainUIModule.Open ();
        //    if (!_reLogin) {
        //        ModelManager.MissionView.CheckRefreshMissionPanel (true, true, true);
        //    }
        //    WorldManager.Instance.FirstEnterScene ();            
        //}
        //xxj end
    }

    private void OnFinishPlot (Plot plot)
	{
        //xxj begin
        //GamePlotManager.Instance.OnFinishPlot -= OnFinishPlot;
        //ProxyMainUIModule.Open();

        //if (plot.plotEndEvent.id == 3 || plot.plotEndEvent.id == 4)
        //{
        //    WorldManager.Instance.NeedFadeIn = true;
        //    ScreenMaskManager.FadeOut(null, 0f, 0f);
        //}

        //if (plot.plotEndEvent.id != 3)
        //{
        //    WorldManager.Instance.FirstEnterScene ();
        //}
        //xxj end
	}

	private void ShowMessageBox (string msg)
	{
		PrintLog (msg);
		_keepSocket = false;
	}

	private void PrintLog (string msg)
	{
		GameDebuger.Log (msg);
		if (OnLoginMessage != null) {
			OnLoginMessage (msg);
		}
	}

	private void OnLoginSuccess (bool isGuest, string sid)
	{
        //xxj begin
		//if (ServerManager.Instance.sid != sid) {
  //          //应用宝特殊处理,在登录的情况下，返回登录不处理
  //          if (GameSetting.CiluChannel == "1008")
  //          {
  //              return;
  //          }

  //          bool bindTip = false;
		//	if (ServerManager.Instance.isGuest && !isGuest) {
		//		bindTip = true;
		//	}
		//	ServerManager.Instance.isGuest = isGuest;

		//	if (!string.IsNullOrEmpty (sid) && sid != "(null)") {
		//		ServerManager.Instance.sid = sid;
		//		ExitGameScript.Instance.DoReloginAccount (false);
		//	} else {
		//		if (bindTip) {
		//			TipManager.AddTip ("账号绑定成功");
		//		}
		//		ProxyWindowModule.closeSimpleWinForTop ();
		//	}
		//} else
        //xxj end
        {
			ProxyWindowModule.closeSimpleWinForTop ();
		}

        //string json = "{\"type\":\"XGRegisterResult\",\"code\":\"0\",\"data\":" + flag + "}";
        //GameDebug.Log("OnXGRegisterResult json=" + json);
        //SPSDK.OnSdkCallback(json);

    }

	private void OnLogout (bool success)
	{
		if (success) {
			ExitGameScript.OpenReloginTipWindow ("您已经注销了账号， 请重新游戏", true);
		}
	}

	public void RemoveListener ()
	{
        //xxj begin
		//SocketManager.Instance.OnHAConnected -= HandleOnHAConnected;
		//SocketManager.Instance.OnHaError -= HandleOnHaError;
		//SocketManager.Instance.OnHaCloseed -= HandleOnHaCloseed;
		//SocketManager.Instance.OnStateEvent -= HandleOnStateEvent;
        //xxj end

		SPSdkManager.Instance.OnLoginSuccess -= OnLoginSuccess;
		SPSdkManager.Instance.OnLogoutNotify -= OnLogout;

        //xxj begin
		//GamePlotManager.Instance.OnFinishPlot -= OnFinishPlot;
        //xxj end
	}

	private void Destroy ()
	{
		RemoveListener ();

        //xxj begin
		//_serverInfo = null;
        //xxj end

	    _onLoadCreateFinish = null;
	}

	private void CloseSocket ()
	{
        //xxj begin
		//SocketManager.Instance.Close (true);
		//SocketManager.Instance.Destroy ();
        //xxj end
	}

	public void CallBackReLogin ()
	{
		//重新登录后的回调//
		if (OnReloginSuccess != null) {
			OnReloginSuccess ();
		}
	}

	//open loginScene
	public void GotoLoginScene (bool isOpen = true)
	{
		GameDebuger.Log ("GotoLoginScene!!!");

		ExitGameScript.CheckConnected = false;
		Destroy ();
		CloseSocket ();


        RequestLoadingTip.Reset ();
        //xxj begin
        //      //fix播放剧情的时候，服务器重启，返回登录页没还原ScreenMaskManager的bug
        //      WorldManager.Instance.NeedFadeIn = false;
        //      ScreenMaskManager.Reset();
        //xxj end

        if (isOpen)
            ProxyLoginModule.Open ();
	}

    #region 排队

    //xxj begin
    //private QueueWindowPrefabController _queueWindowCon;
    //xxj end

    //xxj begin
    //private void LoginQueue1 (QueInfoDto dto)
    //   {
    //       var serverInfo = ServerManager.Instance.GetServerInfo();
    //       if (_queueWindowCon == null)
    //       {
    //           _queueWindowCon = ProxyWindowModule.OpenQueueWindow(serverInfo.name + " 已满", dto.index, dto.secLeft);
    //       }
    //       else
    //       {
    //           _queueWindowCon.UpdateData(serverInfo.name + " 已满", dto.index, dto.secLeft);
    //       }
    //   }
    //xxj end

    private const float CanLoginWaitTime = 600f;

    //xxj begin
 //   public void UpdateLoginQueueData (QueInfoDto dto)
	//{
        
 //       var serverInfo = ServerManager.Instance.GetServerInfo();
 //       if (_queueWindowCon == null)
 //       {
 //           _queueWindowCon = ProxyWindowModule.OpenQueueWindow(serverInfo.name + " 已满", dto.index, dto.secLeft);
 //       }
 //       else
 //       {
 //           _queueWindowCon.UpdateData(serverInfo.name + " 已满", dto.index, dto.secLeft);
 //       }

 //       //        Debug.LogError("排队数据变更");
 //       if (dto.playerDto != null)
 //       {
 //           _queueWindowCon.SetCloseTime(CanLoginWaitTime, () =>
 //           {
 //               OnQueueLogin(dto.playerDto);
 //           });
 //       }
       
 //   }
    //xxj end
    #endregion
}
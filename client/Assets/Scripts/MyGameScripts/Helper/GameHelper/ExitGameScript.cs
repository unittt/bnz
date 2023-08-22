// **********************************************************************
// Copyright  2013 Baoyugame. All rights reserved.
// File     :  ExitGameScript.cs
// Author   : senkay
// Created  : 6/26/2013 9:29:59 AM
// Purpose  : 检查是否按了退出按钮
// **********************************************************************

using System;
using UnityEngine;
//using AppServices;
using GamePlot;
using AssetPipeline;
//using AppDto;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class ExitGameScript : MonoBehaviour
{

    private static ExitGameScript _instance = null;

    public static ExitGameScript Instance
    {
        get
        {
            return _instance;
        }
    }

    private bool isClick;

    static public bool CheckConnected = false;
    static public bool NeedReturnToLogin = false;

    static public bool WaitForReConnect = false;

    private int ReConnectTryCount = 0;

    private int ReConnectMaxCount = 2;

	private int ReConnectTipMaxCount = 5;

    public Action LogOutNotify;

    void Awake()
    {
        _instance = this;

        ReConnectMaxCount = 2;

        //xxj begin
        //if (GameSetting.Release)
        //{
        //    ReConnectMaxCount = 2;
        //}
        //else
        //{
        //    ReConnectMaxCount = 1;
        //}
        //xxj end

        UICamera.onKey += OnPressKey;

        if (!Application.isMobilePlatform)
        {
            UICamera.onScreenResize += OnScreenResize;
        }
    }

    void OnDestroy()
    {
        UICamera.onKey -= OnPressKey;

        if (!Application.isMobilePlatform)
        {
            UICamera.onScreenResize -= OnScreenResize;
        }
    }

	private void OnPressKey(GameObject go, KeyCode key)
    {
        if (key == KeyCode.Escape)
        {
			if (!Application.isEditor && !GameSetting.IsOriginWinPlatform || GameDebuger.DebugForExit)
            {
                OpenExitDialogue();
            }

            //BattleManager.Instance.ExitBattle();

            DumpPlayerInfo();
        }
    }

	private void OnScreenResize()
	{
//		LayerManager.Root.SceneHUDCamera.Render();

        //xxj begin
		//LayerManager.Root.SceneHUDCamera.ResetAspect();
        //xxj end
	}

	public void DumpPlayerInfo()
    {
        //xxj begin
        //Debug Info
        //if (GameSetting.Release) return;


        //string info = " 账号:" + LoginManager.Instance.LoginId;
        //info += " aid:" + ServerManager.Instance.aid;

        //PlayerDto playerDto = ModelManager.Player.GetPlayer();
        //if (playerDto != null)
        //{
        //    info += " PlayerID:" + playerDto.id;
        //    info += " 昵称:" + playerDto.nickname;
        //    info += " 等级:" + playerDto.grade;
        //    info += " 门派:" + playerDto.faction.name;
        //    //info += " token:" + LoginManager.Instance.GetPlayerID();            
        //}

        //GameServerInfo serverInfo =
        //    GameServerInfoManager.GetServerInfoByName(PlayerPrefs.GetString(GameSetting.LastServerPrefsName));
        //if (serverInfo != null)
        //{
        //    info += " 服务器:" + serverInfo.name;
        //}

        //info += " 时间:" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");

        //SceneDto sceneDto = WorldManager.Instance.GetModel().GetSceneDto();
        //if (sceneDto != null)
        //{
        //    info += " 当前场景:" + sceneDto.name;
        //}

        //info += BattleManager.Instance.GetBattleInfo();

        //FileHelper.ClipBoard = info;

        //GameDebuger.Log(info);

        //TipManager.AddTip(info);
        //Debug Info
        //xxj end
    }

    public void OpenExitDialogue()
    {
        if (isClick == false)
        {
            isClick = true;

            GameDebuger.Log("InputKey is Escape");
            if (GameDebuger.DebugForLogout)
            {
                isClick = false;
                SPSdkManager.Instance.CallbackLogout(true);
            }
            else if (GameDebuger.DebugForDisconnect)
            {
                isClick = false;

                //xxj begin
                //SocketManager.Instance.Close(false);
                //xxj end
            }
            else
            {
                DoExiter();
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        //xxj begin
    //    if (CheckConnected && !NeedReturnToLogin)
    //    {
    //        if (reConnecting)
    //        {
    //            reConnecting = false;
    //            //RequestLoadingTip.Reset();
    //        }

    //        if (SocketManager.IsOnLink == false)
    //        {
				//LayerManager.Instance.LockUICamera(false);

    //            RequestLoadingTip.Reset();

    //            ProxyWorldMapModule.CloseMiniMap();

    //            if (LoginManager.LeaveState == EventObject.Leave_status_duplicate)
    //            {
    //                // 苹果PC端特殊处理
    //                if (!GameSetting.QRcodeLogin)
    //                {
    //                    ServerManager.Instance.loginAccountDto = null;
    //                }

    //                OpenServerCloseTip("你的角色已从其他客户端登录，如非本人操作，请注意账号安全！", true);
    //            }
    //            else if (LoginManager.LeaveState == EventObject.Leave_status_kickout)
    //            {
    //                OpenServerCloseTip("网络中断, 请重新进入游戏");
    //            }
    //            else if (LoginManager.LeaveState == EventObject.Leave_status_destroy)
    //            {
    //                OpenServerCloseTip("服务器维护，请重新进入游戏");
    //            }
    //            else if (LoginManager.LeaveState == EventObject.Leave_status_logout)
    //            {
    //                OpenServerCloseTip("网络中断, 请重新进入游戏");
    //            }
    //            else if (LoginManager.LeaveState == EventObject.Leave_status_disconnect)
    //            {
    //                OpenReloginTip();
    //            }
    //            else if (LoginManager.LeaveState == EventObject.Leave_status_unkonwn)
    //            {
    //                OpenReloginTip();
    //            }
    //            else
    //            {
    //                OpenReloginTip();
    //            }

				//PlayerGameState.Save();
    //            ModelManager.Player.StopAutoRun();

    //            CheckConnected = false;
    //        }
    //        else
    //        {
    //            ReConnectTryCount = 0;
    //        }
    //    }
    //xxj end
    }

    //xxj begin
  //  void OnApplicationPause(bool paused)
  //  {
  //      GameDebuger.Log("OnApplicationPause " + paused);

		//if (!paused)
		//{
		//	TalkingDataHelper.Setup();
  //          ModelManager.SystemData.ResetIdleCheck();
		//    ModelManager.SystemData.CheckUpdateBright();
  //          BattleManager.Instance.CheckResumeBattle();

		//	CancelInvoke("CheckClickFlag");
		//	Invoke("CheckClickFlag",0.5f);

  //          NotificationInterface.CleanNotification();
            
  //          //后台切前台检测更新
  //          CheckPatchVersion();
		//}
		//else
		//{
  //          ModelManager.SystemData.CheckBrightneessRecovery();
  //          CancelInvoke("CheckClickFlag");
  //          TalkingDataHelper.Dispose();

  //          NotificationInterface.PushLocalNotification();

  //          //释放检查更新
  //          _onDownloadVersionFinish = null;
  //      }
  //  }
    //xxj end

	private void CheckClickFlag()
	{
		if (isClick)
		{
			GameDebuger.Log("Check isClick and set false");
			isClick = false;
		}
	}

    //xxj begin
    //void OnApplicationQuit()
    //{
    //    TalkingDataHelper.Dispose();

    //    GameDebuger.Log("OnApplicationQuit");

    //    if (SocketManager.IsOnLink)
    //    {
    //        LoginManager.Instance.RemoveListener();
    //        ServiceRequestAction.requestServer(PlayerService.logout());
    //    }
    //    SocketManager.Instance.Close(false);

    //    GameDebuger.Log("Exit Game!!!");

    //    DisposeOnApplicationQuit();
        
    //    FixedAnimatorDeactiveBug();

    //    GameDebuger.Log("Exit Game Success");
    //}
    //xxj end

    /// <summary>
    /// 修复Unity当PC关闭之后，Animator关闭激活状态时候的内存释放问题
    /// </summary>
    private void FixedAnimatorDeactiveBug()
    {
#if !UNITY_STANDALONE
        return;
#endif

        var objs = FindObjectsOfType<Animator>();
        if (objs != null)
        {
            for (int i = 0; i < objs.Length; i++)
            {
                // 关脚本还不行，一定得将gameobject的激活关掉
                //                objs[i].enabled = false;
                objs[i].gameObject.SetActive(false);
            }
        }
    }

    //	void OnApplicationFocus(bool isFocus)
    //	{
    //		GameDebuger.Log("OnApplicationFocus " + isFocus);
    //	}

    //重新连接销毁处理
    void DisposeOnReconnect()
    {
        GameDebuger.Log("DisposeOnReconnect");

        DisposeModuleData();
    }

    //重新登陆销毁处理
    void DisposeOnReLogin()
    {
        GameDebuger.Log("DisposeOnReLogin");

        DisposeSceneData();
        //	模块数据先处理
        DisposeModuleData();
		//聊天模块改为重登时候才销毁

        //xxj begin
        //ModelManager.Chat.Clear();
		//PlayerGameState.Reset();
        //xxj end
        SavePlayerData();

        //清空游戏内的计时器
        JSTimer.Instance.Dispose();
        UIModulePool.Instance.SetupTimer();

        //xxj begin
        //ProxyMainUIModule.Hide();
        //MainUIGameActivityManager.Instance.Dispose();
        //ProxyRoleCreateModule.Close();
        //ProxyRoleCreateModule.CloseAnotherCreateRoleView();
        //xxj end

        //xxj begin
        //if (SocketManager.IsOnLink)
        //{
        //    ServiceRequestAction.requestServer(PlayerService.logout());
        //}
        //xxj end

        LoginManager.Instance.RemoveListener();

        //xxj begin
        //SocketManager.Instance.Close(false);
        //DataManager.Reset();
        //xxj end

        string dataJson = "{}";
        string json = "{\"type\":\"logout\",\"code\":\"0\",\"data\":" + dataJson + "}";
        GameDebug.Log("DisposeOnReLogin logout json=" + json);
        SPSDK.OnSdkCallback(json);
    }

    //应用退出的销毁处理
    void DisposeOnApplicationQuit()
    {
        GameDebuger.Log("DisposeOnApplicationQuit");

        SavePlayerData();

        JSTimer.Instance.Dispose();
        CSTimer.Instance.Dispose();

        //xxj begin
        //ModelManager.SystemData.QuitDispose();
        //xxj end
        Screen.sleepTimeout = SleepTimeout.SystemSetting;
        //VoiceRecognitionManager.Instance.DelTalkCache();
        //xxj begin
        //VoiceRecognitionManager.Instance.CleanupVoiceCache();
        //xxj end
        PlatformAPI.UnregisterPower();
        //BaoyugameSdk.Destroy();
        //xxj begin
        //PlatformAPI.UnregisterGsmSignalStrength();
        //xxj end
    }

    //保存用户数据
    void SavePlayerData()
    {
        GameDebuger.Log("SavePlayerData");

//        ModelManager.Friend.Dispose();   //好友数据的保存

        //xxj begin
        //ModelManager.Chat.SaveChatRecord();//聊天-表情-记录 
        //ModelManager.Barrage.SaveRecord();//保存弹幕发送的记录
        //if (NewBieGuideManager.HasInstance)
        //{
        //    NewBieGuideManager.Instance.Dispose(); //新手引导数据保存
        //}
        //ModelManager.DailyPush.Dispose(); //日程数据保存，主要是弹窗的
        //xxj end

        PlayerPrefs.Save();

        //xxj begin
        //GameDataManager.Instance.SaveData(); //游戏数据保存
        //ModelManager.Player.Dispose();     //最后清空玩家数据，某些Dispose操作需要依赖玩家数据

        //// 释放红包数据
        //ModelManager.RedPacket.Dispose();
        ////释放限时活动数据
        //ModelManager.AccumulatedConsumptionData.Dispose();
        //xxj end
    }

    //销毁功能模块数据
    void DisposeModuleData()
    {
        GameDebuger.Log("DisposeModuleData");

        
        LoginManager.LeaveState = HaNet.EventObject.Leave_status_unkonwn;

        //xxj begin
        //WorldManager.FirstEnter = true;
        //WorldManager.Instance.Reset();
        //ModelManager.Dispose();
        //GamePlotManager.Instance.Dispose();
        //MarryPlotManager.Instance.Dispose();
        //SedanVisitChangAnPlotManager.Instance.Dispose();

        //FunctionOpenHelper.Dispose();

        //JoystickModule.Instance.Dispose();
        //PromoteManager.Instance.Dispose();
        //RedPointManager.Instance.Dispose();
        //xxj end

        UIModuleManager.Instance.Dispose();

        //xxj begin
  //      GameServerInfoManager.Dispose();
  //      if (SystemTimeManager.Instance != null)
  //      {
  //          SystemTimeManager.Instance.Dispose();
  //      }

  //      // 重设不在提示标志
  //      ConsumerTipsViewController.ClearMarks();
        
		////	屏幕中间固定文字数据清理
		//ScreenFixedTipManager.Instance.Dispose();

  //      TipManager.Dispose();  ///tip数据 避免切换角色后出现前数据提示内容BUG

  //      NotificationInterface.Dispose();
        //xxj end
    }

    //销毁场景数据
    void DisposeSceneData()
    {
        GameDebuger.Log("DisposeSceneData");

        //xxj begin
        //WorldManager.Instance.Destroy();
        //WorldMapLoader.Instance.Destroy();
        //BattleManager.Instance.Destroy();
        //xxj end
    }

    public void DoExiter()
    {
		LayerManager.Instance.LockUICamera(false);

		CancelInvoke("CheckClickFlag");
		Invoke("CheckClickFlag",0.5f);

        SPSdkManager.Instance.DoExiter(
        delegate (bool exited)
        {
			//渠道有提供退出确认窗口，游戏处理是否退出逻辑
            isClick = false;
            if (exited)
            {
				//确认退出
				HanderExitGame(false);
            }
            else
            {
				//取消退出
                if (reConnecting == false)
                {
                    if (LoginManager.Instance.SupportRelogin())
                    {
                        //xxj begin
                        //if (SocketManager.IsOnLink == false)
                        //{
                        //    CheckConnected = true;
                        //}
                        //xxj end
                    }
                }
            }
        },
        delegate ()
        {
			CancelInvoke("CheckClickFlag");
			//渠道没有提供退出确认窗口，需要自己实现
			OpenExitConfirmWindow();
        });
    }

    private void OpenExitConfirmWindow()
    {
        ProxyWindowModule.OpenConfirmWindow("退出游戏\n\n离线自动挂机", "",
            () =>
            {
                isClick = false;
                HanderExitGame(true);
            },
            () =>
            {
                if (reConnecting == false)
                {
                    if (LoginManager.Instance.SupportRelogin())
                    {
                        //xxj begin
                        //if (SocketManager.IsOnLink == false)
                        //{
                        //    CheckConnected = true;
                        //}
                        //xxj end
                    }
                }

                isClick = false;
            }, UIWidget.Pivot.Left, null, null, 0);
    }

	//处理退出游戏
	public void HanderExitGame(bool exitSDK = true)
    {
		if (exitSDK)
		{
			SPSdkManager.Instance.Exit();
		}

        LoginManager.Instance.RemoveListener();
        CheckConnected = false;

        ExitGame();
    }

    public void Login()
    {
        ProxyLoginModule.Open();
    }

    public void ReloginAccount(bool needLogout, bool isOpen = true)
    {
        if (needLogout)
        {
            SPSdkManager.Instance.Logout(delegate (bool success)
            {
                if (success)
                {
                    DoReloginAccount(true, isOpen);
                }
                else
                {
                    ProxyWindowModule.OpenMessageWindow("账号退出失败");
                }
            });
        }
        else
        {
            DoReloginAccount(true, isOpen);
        }
    }

    public void DoReloginAccount(bool cleanSid = true, bool isOpen = true)
    {
        //xxj begin
        //ProxyLoginModule.serverInfo = null;
        //xxj end

        ServerManager.Instance.loginAccountDto = null;
        if (cleanSid)
        {
            ServerManager.Instance.sid = null;
            ServerManager.Instance.payExt = "";
        }
       
        HanderRelogin(isOpen);
    }

    public void HanderRelogin(bool isOpen = true)
    {
        GameDebuger.Log("HanderRelogin");

        if (LogOutNotify != null)
        {
            LogOutNotify();
        }

        _relogin = false;

        DisposeOnReLogin();

        GotoLoginScene(isOpen);
    }

    private bool _exited = false;

    private void ExitGame()
    {
        ServerManager.Instance.loginAccountDto = null;
        ServerManager.Instance.sid = null;
        ServerManager.Instance.payExt = "";

#if UNITY_ANDROID
		DoExitGame();
#else
        if (GameDebuger.DebugForExit)
        {
            DoExitGame();
        }
        else
        {
            HanderRelogin();
        }
#endif
    }

    private void DoExitGame()
    {
        if (_exited)
        {
            return;
        }

        _exited = true;
        Application.Quit();

#if UNITY_EDITOR
        EditorApplication.isPlaying = false;
#endif

        //		if (SocketManager.IsOnLink)
        //		{
        //			ServiceRequestAction.requestServer(PlayerService.logout());
        //		}
        //		else
        //		{
        //			SocketManager.Instance.Close(false);
        //		}
        //		
        //		//		//ServiceProviderManager.Exit();
        //		
        //		// 关闭统计
        //		//UmengAnalyticsHelper.onPause();
        //		
        //		Debug.Log("Exit Game!!!");
        //
        //		DisposeOnApplicationQuit();
        //		
        //		//MachineManager.Instance.EndErrorInformation();
        //		
        //		//等待0.5秒后，关闭
        //		Invoke("_ExitGame", 0.2f);	
    }

    private bool _relogin = false;
    private void GotoLoginScene(bool isOpen)
    {
        if (_relogin)
        {
            return;
        }
        _relogin = true;

        LoginManager.Instance.GotoLoginScene(isOpen);

        //重登时检查版本更新
        CheckPatchVersion();
    }

    void ChangeIsClick()
    {
        isClick = false;
    }

    public void EnableClick()
    {
        ChangeIsClick();
    }

    //checkSid 顶号后，检测渠道sid是否还有效
    private void OpenServerCloseTip(string tip, bool checkSid=false)
    {
        ProxyWindowModule.OpenSimpleMessageWindow(tip, delegate ()
        {
            if (checkSid && SPSdkManager.Instance.IsKickClearSid())
            {
                DoReloginAccount(true);
            }
            else
            {
                HanderRelogin();
            }
        }, UIWidget.Pivot.Left, null, UILayerType.TopDialogue);
    }

    private void OpenReloginTip()
    {
        string tip = "网络不稳定，请重新连接";
        //处理创建HA断开的提示
        if (LoginManager.CloseState == HaNet.EventObject.Close_status_ConnectOutTime || LoginManager.CloseState == HaNet.EventObject.Close_status_StarConnectClose)
        {
            tip = "无法连接服务器，请检查网络设置";
        }

        if (forceCheck)
        {
            tip = "网络中断了，请重新游戏";
        }

		tip = string.Format(tip + "[{0}]", LoginManager.CloseState);

        if (forceCheck)
        {
			ProxyWindowModule.OpenSimpleMessageWindow(tip, delegate ()
            {
                HanderRelogin();
            }, UIWidget.Pivot.Left, null, UILayerType.TopDialogue);
        }
        else
        {
            if (reConnecting == false)
            {
                WaitForReConnect = true;

                if (ReConnectTryCount >= ReConnectMaxCount || !Application.isPlaying)
                {
					if (ReConnectTryCount >= ReConnectTipMaxCount)
					{
						ProxyWindowModule.OpenSimpleConfirmWindow(tip,
							() =>
							{
								ReConnectTryCount = 0;
								DelayCheckReConnect();
							},
							() =>
							{
								HanderRelogin();
							},
							UIWidget.Pivot.Left, "重新连接", "返回登陆");
					}
					else
					{
						ProxyWindowModule.OpenSimpleConfirmWindow(tip,
							() =>
							{
								DelayCheckReConnect();
							},
							() =>
							{
								HanderRelogin();
							},
							UIWidget.Pivot.Left, "重连", "返回登陆", ReConnectTryCount*20, UILayerType.Dialogue, true);
					}
                }
                else
                {
                    DelayCheckReConnect();
                }
            }
        }
    }

    private void DelayCheckReConnect()
    {
		GameDebuger.Log("DelayCheckReConnect ReConnectTryCount=" + ReConnectTryCount);
        //xxj begin
  //      RequestLoadingTip.Show("正在连接服务器", true, true);
  //      CancelInvoke("CheckReConnect");
		//float delayTime = 0.5f;
		//if (ReConnectTryCount >= ReConnectMaxCount)
		//{
		//	delayTime = 0.5f;
		//}
		//else
		//{
		//	delayTime = ReConnectTryCount*3f+0.5f;
		//}
		//Invoke("CheckReConnect", delayTime);
        //xxj end
    }


    private static bool reConnecting = false;

    private void CheckReConnect()
    {
        if (!(LoginManager.LeaveState == HaNet.EventObject.Leave_status_duplicate))
        {
            ReConnectTryCount++;

            DisposeOnReconnect();

            reConnecting = true;
            //RequestLoadingTip.Show("正在连接服务器", true, true);
            WaitForReConnect = false;
            LoginManager.Instance.ReConnect();
            //TipManager.AddTip("正在尝试重新连接");
        }
    }

    private static bool forceCheck = false;
    //当网络断开时检查是否需要重连
    static public void CheckReloginWhenConnectClose(bool forceCheck_ = false)
    {
        forceCheck = forceCheck_;

        if (forceCheck)
        {
            reConnecting = true;
        }

        if (reConnecting == true)
        {
            CheckConnected = true;
        }
    }

    public static void OpenReloginTipWindow(string tip, bool exitAccount = false, bool needLogout = false)
    {
		LayerManager.Instance.LockUICamera(false);

        ProxyWindowModule.OpenSimpleMessageWindow(tip, delegate ()
        {
            if (exitAccount)
            {
                ExitGameScript.Instance.ReloginAccount(needLogout);
            }
            else
            {
                ExitGameScript.Instance.HanderRelogin();
            }
        }, UIWidget.Pivot.Left, null, UILayerType.TopDialogue);
    }

    public static void OpenExitTipWindow(string tip)
    {
		LayerManager.Instance.LockUICamera(false);

        BuiltInDialogueViewController.OpenView(tip, ()=> Instance.HanderExitGame(), null, UIWidget.Pivot.Left);
    }
    

    private event System.Action<ByteArray> _onDownloadVersionFinish;
    public void CheckPatchVersion()
    {
        //xxj begin
        //if (AssetManager.Instance.CurVersionConfig == null)
        //{
        //    GameDebuger.Log("CurVersionConfig 为空，跳过版本检查");
        //    return;
        //}

        //string versionConfigFileName = AssetManager.Instance.CurVersionConfig.ToFileName();
        //string cdnUrl = GameSetting.PlatformResPathList[GameSetting.PlatformResPathList.Count-1];
        //string versionConfigUrl = string.Format("{0}?ver={1}", cdnUrl + "/" + versionConfigFileName, DateTime.Now.Ticks);
        //GameDebuger.Log(string.Format("DownloadVersionConfig url={0}", versionConfigUrl));
        ////正在检测
        //if (_onDownloadVersionFinish != null)
        //    return;

        //_onDownloadVersionFinish = OnDownloadVersionFinish;
        //HttpController.Instance.DownLoad(versionConfigUrl, (byteArray) =>
        //{
        //    if (_onDownloadVersionFinish != null)
        //    {
        //        _onDownloadVersionFinish(byteArray);
        //        _onDownloadVersionFinish = null;
        //    }
        //}, null, (e) =>
        //{
        //    GameDebuger.LogError("下载补丁版本信息出错");
        //    _onDownloadVersionFinish = null;
        //});
        //xxj end
    }

    private void OnDownloadVersionFinish(ByteArray byteArray)
    {
        //xxj begin
        //if (AssetManager.Instance.CurVersionConfig == null)
        //{
        //    GameDebuger.Log("CurVersionConfig 为空，跳过版本检查");
        //    return;
        //}

        //string json = byteArray.ToUTF8String();
        //VersionConfig version = JsHelper.ToObject<VersionConfig>(json);

        //if (version.resVersion > AssetManager.Instance.CurVersionConfig.resVersion)
        //{
        //    if (Application.platform == RuntimePlatform.Android)
        //    {
        //        BuiltInDialogueViewController.OpenView("检查到新版本，点击确认后片刻重新启动", DllHelper.RestartGame);
        //    }
        //    else if (Application.platform == RuntimePlatform.WindowsPlayer)
        //    {
        //        BuiltInDialogueViewController.OpenView("检查到新版本，点击确认后重新启动", DllHelper.RestartGame);
        //    }
        //    //ios直接退出游戏
        //    else
        //    {
        //        BuiltInDialogueViewController.OpenView("检查到新版本，请重新打开游戏。点击确认完成退出", () =>
        //        {
        //            DoExitGame();
        //        });
        //    }
        //}
        //else
        //{
        //    //检查处理在线更新,不同服务器不一样且要做判空，先不使用
        //    //OnlineUpdate.CheckOnlineUpdateVersion();
        //}
        //xxj end
    }

	#if USE_JSZ
	private void OnGUI()
	{
		if (Application.isEditor)
		{
			GUI.color = Color.red;
			GUILayout.Label("JSB模式");
		}
	}
	#endif
}

// **********************************************************************
// Copyright (c) 2013 Baoyugame. All rights reserved.
// File     :  LayerManager.cs
// Author   : SK
// Created  : 2013/1/30
// Purpose  : 
// **********************************************************************
using UnityEngine;
//using AppDto;
using System;

public enum UILayerType
{
    #region 玩法功能模块层级
    Invalid = -100,
    JOYSTICK = -20,
    HudLayer = -10,

    BaseModule = 0,
    //底层模块

    //弹幕层
    BarrageLayer = 3,

    SceneChange = 10,
    //场景切换提示SceneChange

    ChatModule = 20,
    //聊天模块层

    //public const int BottomModule = 0; //模块

    DefaultModule = 550501,
    //模块

    SubModule = 550540,
    //2层子模块

    ThreeModule = 550550,
    //3层子模块

    FourModule = 550560,
    //4层子模块

    FiveModule = 550570,
    // 5层子模块

    #endregion
    Dialogue = 550600,
    //对话框

    ItemTip = 550610,
    // 物品信息

    Guide = 550620,
    //引导层

    FloatTip = 550630,
    //飘窗提示

    FadeInOut = 550640,
    //黑屏过渡

    LockScreen = 550650,
    //锁屏

    TopDialogue = 550660,
    //对话框

    TopLockScreen = 550670,
    //锁屏层

    QRCodeScan = 550680,
    // 二维码扫描层

    WebScreen = 550710,
    //网页层
}

public enum UIMode
{
	NULL = 0,
	LOGIN,
	GAME,
	BATTLE,
	STORY,
    MARRY,
}

public class LayerManager:MonoBehaviour
{
	private static GameRoot _root = null;

	public static GameRoot Root {
		get {
			return _root;
		}
	}

    //xxj begin
	//public BattleShakeEffectHelper BattleShakeEffectHelper;
    //xxj end

	//场景特效引用
	public GameObject SceneEffect = null;

	private const float BaseScreenScale = 1024f / 768f;
	private const float AdjustScale = 0.97f;

	public event System.Action<UIMode> OnChangeUIMode;

	private static LayerManager _instance = null;

	public static LayerManager Instance {
		get {
			return _instance;
		}
	}

	void Awake ()
	{
		_instance = this;

        
  	     _root = new GameRoot();
  	     _root.Setup (this.transform);
        //xxj begin
        //_root.SceneUIHUDPanel.depth = GetOriginDepthByLayerType(UILayerType.HudLayer);
        //_root.PlotUIHUDPanel.depth = GetOriginDepthByLayerType(UILayerType.HudLayer);
        //_root.BattleUIHUDPanel.depth = GetOriginDepthByLayerType(UILayerType.HudLayer);//legacy 2017-02-28 11:41:29

        //_root.FloatTipPanel.depth = GetOriginDepthByLayerType(UILayerType.FloatTip);
        //_root.TopFloatTipPanel.depth = GetOriginDepthByLayerType(UILayerType.TopDialogue);
        //_root.LockScreenPanel.depth = GetOriginDepthByLayerType(UILayerType.LockScreen);

        //_root.SceneCameraTrans.parent.gameObject.GetMissingComponent<CameraController>();

        //BattleShakeEffectHelper = _root.BattleCamera.gameObject.GetMissingComponent<BattleShakeEffectHelper> ();
        //BattleShakeEffectHelper.Setup ();
        //xxj end
    }

    void Start ()
	{
		//LayerManager.Root.SceneCamera.audio.volume = 0.2f;
		//_root.SceneHudTextPanel.startingRenderQueue = 2455;
		//_root.PlotHudTextPanel.startingRenderQueue = 2455;
	}

    public UIMode CurUIMode
    {
        get { return _uiMode; }
    }

    private UIMode _uiMode = UIMode.NULL;

    public void SwitchLayerMode (UIMode mode, bool forceSwitch = false)
	{
        if (_uiMode == mode && !forceSwitch) {
			return;
		}

		_uiMode = mode;

        //xxj begin
		//if (MainUIViewController.Instance != null) {
		//	MainUIViewController.Instance.ChangeMode (mode);
		//}
		//CameraController.Instance.ChangeMode (mode);
		//AdjustCameraPosition (mode == UIMode.BATTLE);

		////JoystickModule.Instance.SetActive (mode == UIMode.GAME);

  //      //弹幕面板
  //      if (mode == UIMode.BATTLE && FunctionOpenHelper.isFuncOpen(FunctionOpen.FunctionOpenEnum_Barrage, false))
  //          ProxyBarrageModule.OpenBarrageLayer();
  //      else
  //      {
  //          ProxyBarrageModule.CloseBarraylayer();
  //          ProxyBarrageModule.CloseChat();
  //      }
            

  //      _root.BattleLayer.SetActive (mode == UIMode.BATTLE && BattleManager.NeedBattleMap);
		//_root.SceneLayer.SetActive (mode != UIMode.BATTLE || !BattleManager.NeedBattleMap);

		//_root.BattleActors.SetActive (mode == UIMode.BATTLE);
		//_root.WorldActors.SetActive (mode == UIMode.GAME || mode == UIMode.MARRY);//结婚的时候其他玩家也要显示
  //      _root.Character2dLayer.SetActive(mode == UIMode.GAME || mode == UIMode.MARRY);
  //      _root.Scene2dHudLayer.SetActive(mode == UIMode.GAME || mode == UIMode.MARRY);
  //      _root.StoryActors.SetActive (mode == UIMode.STORY);

		//_root.BattleCamera.enabled = (mode == UIMode.BATTLE);
  //      if (_root.BattleBgTexture.mainTexture == null || _root.Battle2dBg.mainTexture == null)
  //      {
  //          var battleBg = Resources.Load<Texture>("Textures/battleLogo");
  //          _root.BattleBgTexture.mainTexture = battleBg;
  //          _root.Battle2dBg.mainTexture = battleBg;
  //      }
  //      _root.BattleBgTexture.cachedGameObject.SetActive (mode == UIMode.BATTLE && !BattleManager.NeedBattleMap);

  //      _root.BattleHudTextPanel.cachedGameObject.SetActive (mode == UIMode.BATTLE);
		//_root.BattleUIHUDPanel.cachedGameObject.SetActive (mode == UIMode.BATTLE);
  //      _root.Battle2dGUI.SetActive(mode == UIMode.BATTLE);

	 //   if (mode == UIMode.GAME)
	 //   {
	 //       _root.SceneHudTextPanel.cachedGameObject.SetActive(true);
	 //       _root.SceneUIHUDPanel.cachedGameObject.SetActive(true);

  //          _root.Scene2dHeadHudPanel.cachedGameObject.SetActive(true);
  //          _root.Scene2dSkyHeadHudPanel.cachedGameObject.SetActive(true);
	 //   }
	 //   else if (mode == UIMode.MARRY)
	 //   {
  //          _root.SceneHudTextPanel.cachedGameObject.SetActive(false);
  //          _root.SceneUIHUDPanel.cachedGameObject.SetActive(false);

  //          _root.Scene2dHeadHudPanel.cachedGameObject.SetActive(false);
  //          _root.Scene2dSkyHeadHudPanel.cachedGameObject.SetActive(false);
  //      }
	 //   else
	 //   {
  //          _root.SceneHudTextPanel.cachedGameObject.SetActive(false);
  //          _root.SceneUIHUDPanel.cachedGameObject.SetActive(false);

  //          _root.Scene2dHeadHudPanel.cachedGameObject.SetActive(false);
  //          _root.Scene2dSkyHeadHudPanel.cachedGameObject.SetActive(false);
  //      }
		//_root.PlotHudTextPanel.cachedGameObject.SetActive (mode == UIMode.STORY || mode == UIMode.MARRY);
  //      _root.Plot2dHudPanel.cachedGameObject.SetActive(mode == UIMode.STORY || mode == UIMode.MARRY);
  //      _root.PlotUIHUDPanel.cachedGameObject.SetActive (mode == UIMode.STORY|| mode == UIMode.MARRY);

		//if (mode == UIMode.BATTLE && !BattleManager.NeedBattleMap) {
		//	_root.EffectsAnchor.layer = LayerMask.NameToLayer (GameTag.Tag_BattleActor);
		//} else {
		//	_root.EffectsAnchor.layer = LayerMask.NameToLayer (GameTag.Tag_Default);
		//}

		//if (mode == UIMode.GAME) {
		//	TipManager.CheckDelayShow ();
		//	ScreenFixedTipManager.Instance.CheckDelayShow();
		//	ModelManager.Player.CheckDelayShow ();
		//	ModelManager.Pet.CheckDelayShow ();
		//	ModelManager.MissionView.CheckRefreshMissionPanel();
		//    ModelManager.Achievement.CheckDelayShow();
		//} else if (mode == UIMode.STORY) {
  //          ModelManager.MissionView.CheckRefreshMissionPanel(false);
		//}

  //      if(FunctionOpenHelper.isFuncOpen(FunctionOpen.FunctionOpenEnum_CampBattle,false)
  //          &&ModelManager.CampBattleData.IsInActivityScene())
  //      {
  //          ProxyCampBattleModule.HideCampBattleWindow(mode != UIMode.BATTLE);
  //      }
  //xxj end

		if (OnChangeUIMode != null)
			OnChangeUIMode (mode);
	}

	private void AdjustCameraPosition (bool battleMode)
	{
        //xxj begin
		//if (battleMode) {
		//	float scaleFactor = ((float)Screen.width / (float)Screen.height) / BaseScreenScale;
		//	scaleFactor *= AdjustScale;
			
		//	_root.BattleCamera.transform.localPosition = CameraConst.BattleCameraLocalPosition;
		//	_root.BattleCamera.transform.localEulerAngles = CameraConst.BattleCameraLocalEulerAngles;
		//	_root.BattleCamera.fieldOfView = CameraConst.BattleCameraFieldOfView;
		//	_root.BattleCamera.orthographicSize = CameraConst.BattleCameraOrthographicSize / scaleFactor;
		//	_root.BattleCamera.orthographic = !BattleManager.NeedBattleMap;
			
		//	if (BattleManager.NeedBattleMap) {
		//		_root.SceneCameraTrans.localPosition = CameraConst.BattleCameraLocalPosition;
		//		_root.SceneCameraTrans.localEulerAngles = CameraConst.BattleCameraLocalEulerAngles;
		//		_root.SceneCamera.fieldOfView = CameraConst.BattleCameraFieldOfView;
		//	}
		//} else {
		//	_root.SceneCamera.fieldOfView = CameraConst.WorldCameraFieldOfView;
		//	_root.BattleCamera.fieldOfView = CameraConst.WorldCameraFieldOfView;
		//}
        //xxj end

	}

    public void LockUICamera(bool isLock)
    {
        //if (_root != null)
        //{
        //    _root.UICamera.enabled = !isLock;
        //}
    }

    public int GetOriginDepthByLayerType(UILayerType type){
        return (int)type * 10;  //temporary solution, get from cfg is a better way  -- todo fish
    }

    public UILayerType GetLayerTypeByDepth (int depth){
        var type = UILayerType.DefaultModule;

        System.Array etypes = Enum.GetValues(typeof(UILayerType));

        for (int i = 0; i < etypes.Length; ++i) {
            if (depth >= GetOriginDepthByLayerType((UILayerType)etypes.GetValue(i))) {
                return type;
            }
        }

        return type;
    }

    public void SetUIModuleRootActive(bool b)
    {
        //if (_root != null)
        //{
        //    _root.UIModuleRoot.SetActive(b);
        //}
    }

    private void OnApplicationPause(bool paused)
    {
        GameDebuger.Log("LayerManager OnApplicationPause " + paused);
        if (!paused)
        {
            //xxj begin
            //WorldManager.Instance.isPause2Start = true;
            //xxj end
        }
    }

    public void ClearBattleUIHUDPanel()
    {
        //xxj begin
        //_root.BattleUIHUDPanel.cachedTransform.RemoveChildren();
        //xxj end
    }
}


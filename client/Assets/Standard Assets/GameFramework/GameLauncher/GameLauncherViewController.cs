
using System;
using UnityEngine;
using AssetPipeline;

public class GameLauncherViewController : MonoBehaviour
{
    public static GameLauncherViewController _instance;
	private GameLauncherView _view;
	private Action _callback;
	
    public static GameLauncherViewController OpenView(string version)
    {
        if (_instance == null)
        {
            GameObject prefab = Resources.Load<GameObject>("Built-inAssets/GameLauncherView");
            GameObject module = NGUITools.AddChild(UICamera.eventHandler.gameObject, prefab);
            var com = module.AddMissingComponent<GameLauncherViewController>();
            com.InitView(version);
            _instance = com;
        }
        return _instance;
	}
	
	public static void CloseView()
	{
		if (_instance != null)
		{
			_instance.Dispose();
			Destroy(_instance.gameObject);
			_instance = null;
		}
	}
	
	private void InitView(string version)
	{
		_view = gameObject.AddMissingComponent<GameLauncherView>();
		_view.Setup(transform);
		//		NGUITools.FitToRootSize(_view.InitBgTexture_UITexture, 2);
		_view.tipsLbl.cachedGameObject.SetActive(false);
		
		_view.VersionLabel_UILabel.text = version;
		_view.UpdateRes_OkLabel.text = "立刻更新";
		
		EventDelegate.Set(_view.UpdateTip_OkBtn.onClick, OnClickUpdateTipOkBtn);
		EventDelegate.Set(_view.UpdateAll_OkBtn.onClick, OnClickUpdateAllOkBtn);
		EventDelegate.Set(_view.UpdateRes_OkBtn.onClick, OnClickUpdateResOkBtn);
		EventDelegate.Set(_view.UpdateRes_CloseBtn.onClick, OnClickUpdateTipCloseBtn);
		ResetTipsObj ();
	}

	public void ResetTipsObj() {
		_view.UpdateRes_CloseBtn.gameObject.SetActive (false);
		_view.DownloadObj.gameObject.SetActive (false);
		_view.UpdateTipObj.gameObject.SetActive (false);
		_view.UpdateInfoObj.gameObject.SetActive (false);
		_view.UpdateSlider.gameObject.SetActive (false);
	}
	
	private void OnClickUpdateTipOkBtn() {
		if (_callback != null)
		{
			_callback();
		}
		ResetTipsObj ();
	}
	
	private void OnClickUpdateAllOkBtn() {
		if (_callback != null)
		{
			_callback();
		}
		ResetTipsObj ();
	}
	
	private void OnClickUpdateResOkBtn() {
		if (_callback != null)
		{
			_callback();
		}
		ResetTipsObj ();
	}
	
	private void OnClickUpdateTipCloseBtn() {
		CloseView ();
	}
	
	//	显示UpdateTip
	public void ShowDownloadTip (Action cb) {
		_view.DownloadObj.gameObject.SetActive (true);
		_view.UpdateTipObj.gameObject.SetActive (false);
		_view.UpdateInfoObj.gameObject.SetActive (false);
		_view.UpdateSlider.gameObject.SetActive (false);
		_view.tipsLbl.gameObject.SetActive (false);
		_view.VersionLabel_UILabel.gameObject.SetActive (false);
		_callback = cb;
	}
	
	
	//	显示UpdateAll
	public void ShowUpdateTip (Action cb) {
		_view.DownloadObj.gameObject.SetActive (false);
		_view.UpdateTipObj.gameObject.SetActive (true);
		_view.UpdateInfoObj.gameObject.SetActive (false);
		_view.UpdateSlider.gameObject.SetActive (false);
		_view.tipsLbl.gameObject.SetActive (false);
		_view.VersionLabel_UILabel.gameObject.SetActive (false);
		_callback = cb;
	}
	
	//	显示UpdateRes
	public void ShowUpdateInfo (Action cb, string totleSize) {
		_view.DownloadObj.gameObject.SetActive (false);
		_view.UpdateTipObj.gameObject.SetActive (false);
		_view.UpdateInfoObj.gameObject.SetActive (true);
		_view.UpdateSlider.gameObject.SetActive (false);
		_view.tipsLbl.gameObject.SetActive (false);
		_view.VersionLabel_UILabel.gameObject.SetActive (false);
		_callback = cb;

		_view.UpdateRes_CurVersion.text = "";//string.Format("当前版本号：{0}", GameVersion.LocalShowVersion);
		_view.UpdateRes_TargetVersion.text = "";//string.Format("发现新版本");
		_view.UpdateRes_TotleSize.text = string.Format("需要更新 {0}游戏内容", totleSize);
	}
	
	//	显示Slider
	public void ShowUpdateSlider (Action cb, int progress, string proportion) {
		if (progress < 0) {
			proportion = "100%";
		}
		_view.DownloadObj.gameObject.SetActive (false);
		_view.UpdateTipObj.gameObject.SetActive (false);
		_view.UpdateInfoObj.gameObject.SetActive (false);
		_view.UpdateSlider.gameObject.SetActive (true);
		_view.tipsLbl.gameObject.SetActive (false);
		_view.VersionLabel_UILabel.gameObject.SetActive (false);
		_callback = cb;

		_view.UpdateSlider_Slider.value = progress * 0.01f;
		_view.UpdateSlider_NetType.text = string.Format("正在使用{0}网络", PlatformAPI.getNetworkType());
		_view.UpdateSlider_CurVersion.text = "";//string.Format ("当前版本号：{0}", GameVersion.LocalShowVersion);
		_view.UpdateSlider_UpdatePro.text = string.Format("更新进度{0}%", progress >= 0? progress : 100);
		_view.UpdateSlider_Proportion.text = proportion;
	}

	public static void ChangeParentLayer(GameObject parentGO)
	{
        if (parentGO == null) return;

        if (_instance != null)
        {
            UIPanel panel = _instance.GetComponent<UIPanel>();
            if (panel != null)
            {
                panel.cachedTransform.parent = parentGO.transform;
                panel.cachedTransform.localPosition = Vector3.zero;
            }
        }
    }

    public static void ShowTips(string tips)
	{
		if (_instance != null)
		{
			_instance.DoUpdateTips(tips);
		}
	}

    public void ShowVersion()
    {
		_view.VersionLabel_UILabel.text = "";//string.Format("资源号：{0}", GameVersion.ResVersion);
    }

    public void ShowLoadingBg()
    {
		ReleaseTexture(_view.InitBgTexture_UITexture);
		_view.InitBgTexture_UITexture.mainTexture = AssetManager.LoadStreamingAssetsTexture("Textures/loginBG");

		if (GameSetting.QRcodeLogin && SPSDK.GetChannelId() != "demi")
		{

		}
		else
		{
			_view.LogoTexture_UITexture.mainTexture = AssetManager.LoadStreamingAssetsTexture ("Textures/logo");
		}
    }

    public void ShowSplash()
    {
        ReleaseTexture(_view.InitBgTexture_UITexture);
        _view.InitBgTexture_UITexture.mainTexture = AssetManager.LoadStreamingAssetsTexture("Textures/splash");
    }

    private void Dispose()
    {
        ReleaseTexture(_view.LogoTexture_UITexture);
        ReleaseTexture(_view.InitBgTexture_UITexture);
    }

    private void OnDestroy()
    {
		Dispose ();
        _instance = null;
    }

    private void ReleaseTexture(UITexture uiTexture)
    {
        if (uiTexture != null)
        {
            Texture tex = uiTexture.mainTexture;
            if (tex != null)
            {
                uiTexture.mainTexture = null;
                // Resources.UnloadAsset(tex);
                Destroy(tex);
            }
        }
    }

    private void DoUpdateTips(string tips)
    {
        if (string.IsNullOrEmpty(tips))
        {
            _view.tipsLbl.cachedGameObject.SetActive(false);
        }
        else
        {
            _view.tipsLbl.text = tips;
            _view.tipsLbl.cachedGameObject.SetActive(true);
        }
    }
}
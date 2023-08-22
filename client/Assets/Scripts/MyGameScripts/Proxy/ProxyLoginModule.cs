using UnityEngine;
using System;

public class ProxyLoginModule
{
	public const string NAME = "UI/Login/LoginViewNull.prefab";

	//these attributes set on serverlistmodule
	//public static GameServerInfo serverInfo = null;

	public static void Open()
	{
		GameObject ui = UIModuleManager.Instance.OpenFunModule(NAME, UILayerType.DefaultModule, false);
		
		var controller = ui.GetMissingComponent<LoginController>();
		controller.Open ();
	}
	
	public static void Close()
	{
		UIModuleManager.Instance.CloseModule (NAME);
	}

	public static void Hide()
	{
		UIModuleManager.Instance.HideModule (NAME);
	}

	public static void Show()
	{
		if (UIModuleManager.Instance.IsModuleCacheContainsModule(NAME))
		{
			UIModuleManager.Instance.OpenFunModule(NAME, UILayerType.DefaultModule, false);
	    }
	}

	public static bool IsOpen()
	{
        //return UIModuleManager.Instance.IsModuleCacheContainsModule(NAME);
        return false;
	}

	public static void ShowAndOpenServerList()
	{
		//GameObject ui = UIModuleManager.Instance.OpenFunModule(NAME, UILayerType.DefaultModule, false);
		//
		//var controller = ui.GetMissingComponent<LoginController>();
		//controller.OpenServerListModule ();
	}

	#region TestSdk
	public const string NAME_TESTSDK = "TestSdkView";
	public static void OpenTestSdk()
	{
		//GameObject ui = UIModuleManager.Instance.OpenFunModule(NAME_TESTSDK, UILayerType.FourModule, false, false);
		
		//var controller = ui.GetMissingComponent<TestSdkController>();
		//controller.Open ();
	}

	public static void CloseTestSdk()
	{
		//UIModuleManager.Instance.CloseModule (NAME_TESTSDK);
	}
	#endregion

	#region Announcement
	private const string NAME_Announcement = "AnnouncementView";
	public static void OpenAnnouncement()
	{
		//GameObject ui = UIModuleManager.Instance.OpenFunModule(NAME_Announcement, UILayerType.FiveModule, true, true);
		
		//var controller = ui.GetMissingComponent<AnnouncementController>();
		//controller.Open ();
	}
	
	public static void CloseAnnouncement()
	{
		//UIModuleManager.Instance.CloseModule (NAME_Announcement);
	}
	#endregion

	#region Agreement
	private const string NAME_Agreement = "AgreementView";
	public static void OpenAgreement(Action callback = null)
	{
		//GameObject ui = UIModuleManager.Instance.OpenFunModule(NAME_Agreement, UILayerType.FiveModule, true, false);
		
		//var controller = ui.GetMissingComponent<AgreementController>();
		//controller.Open (callback);
	}
	
	public static void CloseAgreement()
	{
		//UIModuleManager.Instance.CloseModule (NAME_Agreement);
	}
	#endregion
}


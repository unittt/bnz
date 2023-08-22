﻿//------------------------------------------------------------------------------
// <auto-generated>
// This code was generated by a tool.
// </auto-generated>
//------------------------------------------------------------------------------
using UnityEngine;
using System.Collections;

/// <summary>
/// Generates a safe wrapper for SdkQuickLoginView.
/// </summary>
public partial class SdkQuickLoginView : BaseView
{
	public const string NAME = "UI/SdkAcccountPrefabs/SdkQuickLoginView.prefab";
	public UIButton LoginBtn;
	public UIButton LastAccountBtn;
	public UIButton PlatformBtn;
	public UIButton TencentBtn;
	public UIGrid AccountGrid;
	public UISprite LastIcon;
	public UILabel LastLabel;
	public UIButton BackBtn_UIButton;
    public UIButton RegBtn;

    protected override void InitElementBinding ()
	{
		var root = this.gameObject.transform;
		LoginBtn = root.Find("LoginButton").GetComponent<UIButton>();
		LastAccountBtn = root.Find("LastAccount").GetComponent<UIButton>();
		PlatformBtn = root.Find("PlatformBtn").GetComponent<UIButton>();
		TencentBtn = root.Find("TencentBtn").GetComponent<UIButton>();
		AccountGrid = root.Find("AccountGrid").GetComponent<UIGrid>();
		LastIcon = root.Find("LastAccount/LastIcon").GetComponent<UISprite>();
		LastLabel = root.Find("LastAccount/LastLabel").GetComponent<UILabel>();
		BackBtn_UIButton = root.Find("BackBtn").GetComponent<UIButton>();
        RegBtn = root.Find("RegButton").GetComponent<UIButton>();
    }
}
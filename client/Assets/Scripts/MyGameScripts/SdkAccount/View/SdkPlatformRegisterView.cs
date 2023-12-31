﻿//------------------------------------------------------------------------------
// <auto-generated>
// This code was generated by a tool.
// </auto-generated>
//------------------------------------------------------------------------------
using UnityEngine;
using System.Collections;

/// <summary>
/// Generates a safe wrapper for PlatformRegisterView.
/// </summary>
public partial class SdkPlatformRegisterView : BaseView
{
	public const string NAME = "UI/SdkAcccountPrefabs/SdkPlatformRegisterView.prefab";
	public UIInput AccoutInput;
	public UIButton RegisterBtn;
	public UIButton BackBtn;

	protected override void InitElementBinding ()
    {
        var root = this.gameObject.transform;
		AccoutInput = root.Find("AccoutInput").GetComponent<UIInput>();
		RegisterBtn = root.Find("RegisterBtn").GetComponent<UIButton>();
		BackBtn = root.Find("BackBtn").GetComponent<UIButton>();
	}
}

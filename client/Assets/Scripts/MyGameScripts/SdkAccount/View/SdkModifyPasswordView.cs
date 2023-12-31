﻿//------------------------------------------------------------------------------
// <auto-generated>
// This code was generated by a tool.
// </auto-generated>
//------------------------------------------------------------------------------
using UnityEngine;
using System.Collections;

/// <summary>
/// Generates a safe wrapper for ModifyPasswordView.
/// </summary>
public partial class SdkModifyPasswordView : BaseView
{
	public const string NAME = "UI/SdkAcccountPrefabs/SdkModifyPasswordView.prefab";
	public UIInput AccoutInput;
	public UIButton GetCodeBtn;
	public UIButton BackBtn;

	protected override void InitElementBinding ()
    {
        var root = this.gameObject.transform;
		AccoutInput = root.Find("AccoutInput").GetComponent<UIInput>();
		GetCodeBtn = root.Find("GetCodeBtn").GetComponent<UIButton>();
		BackBtn = root.Find("BackBtn").GetComponent<UIButton>();
	}
}

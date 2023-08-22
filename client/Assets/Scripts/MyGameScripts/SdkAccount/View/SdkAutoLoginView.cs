﻿//------------------------------------------------------------------------------
// <auto-generated>
// This code was generated by a tool.
// </auto-generated>
//------------------------------------------------------------------------------
using UnityEngine;
using System.Collections;

/// <summary>
/// Generates a safe wrapper for SdkAutoLoginView.
/// </summary>
public partial class SdkAutoLoginView : BaseView
{
	public const string NAME = "UI/SdkAcccountPrefabs/SdkAutoLoginView.prefab";
	public UIButton SwichAccountBtn;
	public UILabel AccountLabel;

	protected override void InitElementBinding ()
	{
		var root = this.gameObject.transform;
		SwichAccountBtn = root.Find("SwichAccountBtn").GetComponent<UIButton>();
		AccountLabel = root.Find("LoginGroup/AccountLabel").GetComponent<UILabel>();
	}
}

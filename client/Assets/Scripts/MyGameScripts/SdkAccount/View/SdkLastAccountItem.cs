﻿//------------------------------------------------------------------------------
// <auto-generated>
// This code was generated by a tool.
// </auto-generated>
//------------------------------------------------------------------------------
using UnityEngine;
using System.Collections;

/// <summary>
/// Generates a safe wrapper for LastAccountItem.
/// </summary>
public partial class SdkLastAccountItem : BaseView
{
	public const string NAME = "UI/SdkAcccountPrefabs/SdkLastAccountItem.prefab";
	public UIButton LastAccountItemBtn;
	public UILabel LastLabel;
	public UISprite LastIcon;
	public UIButton DeleteBtn;

	protected override void InitElementBinding ()
    {
        var root = this.gameObject.transform;
	LastAccountItemBtn = root.GetComponent<UIButton>();
		LastLabel = root.Find("LastLabel").GetComponent<UILabel>();
		LastIcon = root.Find("LastIcon").GetComponent<UISprite>();
		DeleteBtn = root.Find("DeleteBtn").GetComponent<UIButton>();
	}
}

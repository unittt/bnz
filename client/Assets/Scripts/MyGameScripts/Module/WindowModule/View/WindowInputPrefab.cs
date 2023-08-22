﻿//------------------------------------------------------------------------------
// <auto-generated>
// This code was generated by a tool.
// </auto-generated>
//------------------------------------------------------------------------------
using UnityEngine;
using System.Collections;

/// <summary>
/// Generates a safe wrapper for WindowInputPrefab.
/// </summary>
public partial class WindowInputPrefab : BaseView
{
	public UIInput NameInput;
	public UIButton CancelButton;
	public UIButton CloseBtn;
	public UIButton OKButton;
	public UILabel tipsLabel;
	public UIButton DefaultButton;
	public UILabel TitleLabel;
	public UILabel CancelLabel;
	public UILabel OKLabel;
	public UILabel defaultLabel;
	public UILabel desLabel;

	protected override void InitElementBinding ()
    {
        var root = this.gameObject.transform;
		NameInput = root.Find("ContentFrame/NameInput").GetComponent<UIInput>();
		CancelButton = root.Find("ContentFrame/CancelButton").GetComponent<UIButton>();
		CloseBtn = root.Find("ContentFrame/CloseBtn").GetComponent<UIButton>();
		OKButton = root.Find("ContentFrame/OKButton").GetComponent<UIButton>();
		tipsLabel = root.Find("ContentFrame/tipsLabel").GetComponent<UILabel>();
		DefaultButton = root.Find("ContentFrame/DefaultButton").GetComponent<UIButton>();
		TitleLabel = root.Find("ContentFrame/TitleLabel").GetComponent<UILabel>();
		CancelLabel = root.Find("ContentFrame/CancelButton/CancelLabel").GetComponent<UILabel>();
		OKLabel = root.Find("ContentFrame/OKButton/OKLabel").GetComponent<UILabel>();
		defaultLabel = root.Find("ContentFrame/DefaultButton/defaultLabel").GetComponent<UILabel>();
		desLabel = root.Find("ContentFrame/desLabel").GetComponent<UILabel>();
	}
}

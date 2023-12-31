﻿//------------------------------------------------------------------------------
// <auto-generated>
// This code was generated by a tool.
// </auto-generated>
//------------------------------------------------------------------------------
using UnityEngine;
using System.Collections;

/// <summary>
/// Generates a safe wrapper for WindowWithRewardPrefab.
/// </summary>
public partial class WindowWithRewardPrefab : BaseView
{
	public const string NAME ="WindowWithRewardPrefab";
	public UILabel TitleLabel;
	public UILabel InfoLabel;
	public UILabel CancelLabel;
	public UIButton OKButton;
	public UILabel OKLabel;
	public UIButton CloseBtn;
	public UISprite ContentBg_UISprite;
	public UISprite Sprite_UISprite;
	public UIButton CancelButton;
	public UIGrid BtnGrid_UIGrid;
	public UILabel InfoTipsLabel;
	public UIGrid RewardItemGrid;

	protected override void InitElementBinding ()
	{
		var root = this.gameObject.transform;
		TitleLabel = root.Find("ContentFrame/CntrTitle/TitleLabel").GetComponent<UILabel>();
		InfoLabel = root.Find("ContentFrame/InfoLabel").GetComponent<UILabel>();
		CancelLabel = root.Find("ContentFrame/BtnGrid/CancelButton/CancelLabel").GetComponent<UILabel>();
		OKButton = root.Find("ContentFrame/BtnGrid/OKButton").GetComponent<UIButton>();
		OKLabel = root.Find("ContentFrame/BtnGrid/OKButton/OKLabel").GetComponent<UILabel>();
		CloseBtn = root.Find("CloseBtn").GetComponent<UIButton>();
		ContentBg_UISprite = root.Find("ContentFrame/ContentBg").GetComponent<UISprite>();
		Sprite_UISprite = root.Find("ContentFrame/Sprite").GetComponent<UISprite>();
		CancelButton = root.Find("ContentFrame/BtnGrid/CancelButton").GetComponent<UIButton>();
		BtnGrid_UIGrid = root.Find("ContentFrame/BtnGrid").GetComponent<UIGrid>();
		InfoTipsLabel = root.Find("ContentFrame/InfoTipsLabel").GetComponent<UILabel>();
		RewardItemGrid = root.Find("ContentFrame/ContentBg/RewardItemGrid").GetComponent<UIGrid>();
	}
}

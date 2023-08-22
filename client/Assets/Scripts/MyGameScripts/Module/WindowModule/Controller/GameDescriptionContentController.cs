
// **********************************************************************
//	Copyright (C), 2011-2015, CILU Game Company Tech. Co., Ltd. All rights reserved
//	Work:		For H1 Project With .cs
//  FileName:	GameDescriptionContent.cs
//  Version:	Beat R&D

//  CreatedBy:	_Alot
//  Date:		2016.01.15
//	Modify:		__

//	Url:		http://www.cilugame.com/

//	Description:
//	This program files for detailed instructions to complete the main functions,
//	or functions with other modules interface, the output value of the range,
//	between meaning and parameter control, sequence, independence or dependence relations
// **********************************************************************

using UnityEngine;
using System.Collections.Generic;

//using AppDto;

public class GameDescriptionContentController : MonoViewController<GameDescriptionView> {

    //xxj begin
	//private Dictionary<int, FunTooltip> _infoDic;
	//xxj end

	private GameObject _announcementTitleCellPrefab;
	private GameObject _announcementContentCellPrefab;
	
	#region IViewController
	/// <summary>
	/// 从DataModel中取得相关数据对界面进行初始化
	/// </summary>


    protected override void InitView () {
	base.InitView ();
	}
	
	/// <summary>
	/// Registers the event.
	/// DateModel中的监听和界面控件的事件绑定,这个方法将在InitView中调用
	/// </summary>
	protected override void RegisterEvent ()
	{
		base.RegisterEvent ();		EventDelegate.Set(View.CloseButton_UIButton.onClick, OnCloseButtonClick);
		//EventDelegate.Set(View.dragRegion_UIEventTrigger.onClick, OnContentClick);
	}

	/*
	private void OnContentClick() {
		for (int i = 0; i < _contentUiLabels.Count; i++) {
			string urlStr = _contentUiLabels[i].GetUrlAtPosition(UICamera.lastWorldPosition);
			if (!string.IsNullOrEmpty(urlStr)) {
				ModelManager.Chat.DecodeUrlMsg(urlStr, null);
				break;
			}
		}
		
	}
	*/
	
	
	#endregion
	
	public void Open(int mainFunToolTipID) {
		
        //xxj begin
		//FunTooltip tMainFunTooltip = ModelManager.GameDescription.GetFunTooltipByID(mainFunToolTipID);
		//View.TitleLabel_UILabel.text = tMainFunTooltip == null? "" : tMainFunTooltip.title.WrapColor(ColorConstantV3.Color_SealBrown_Str);
		//View.ContentTable_UITable.gameObject.RemoveChildren();
		
		//_infoDic = ModelManager.GameDescription.GetFunTooltipDicByMainID(mainFunToolTipID);
		//if (_infoDic != null) {
		//	foreach (FunTooltip info in _infoDic.Values) {
		//		ShowFunTooltipInfo(info);
		//	}
		//}
		
		//View.ContentTable_UITable.Reposition();
		//View.ContentScrollView_UIScrollView.ResetPosition();
        //xxj end
	}
	
	private List<UILabel> _contentUiLabels = new List<UILabel>();

    //xxj begin
	//private void ShowFunTooltipInfo(FunTooltip info) {
	//	GameObject announcementTitleCell = AddCachedChild(View.ContentTable_UITable.gameObject,"AnnouncementTitleCell");
	//	GameObject announcementContentCell = AddCachedChild(View.ContentTable_UITable.gameObject,"AnnouncementContentCell");
		
	//	announcementTitleCell.GetComponentInChildren<UILabel>().text = info.title;
	//	UILabel lbl = announcementContentCell.GetComponentInChildren<UILabel>();
	//	lbl.pivot = UIWidget.Pivot.TopLeft;
	//	lbl.spacingY = 10;
	//	lbl.width = 770;
	//	lbl.text = info.description;
	//	_contentUiLabels.Add(lbl);
	//}
    //xxj end
	
	private void OnCloseButtonClick() {
        //xxj begin
		//TalkingDataHelper.OnEventSetp("Announcement","Close");
		//ProxyGameDescriptionModule.Close();
        //xxj end
	}
}


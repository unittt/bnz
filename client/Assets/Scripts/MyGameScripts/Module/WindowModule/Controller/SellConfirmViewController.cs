// **********************************************************************
// Author : hongjie
// Created : 2018-2-9
// Desc	: 
// **********************************************************************
//using AppDto;
using System;
using System.Collections.Generic;
using UnityEngine;

public class SellConfirmViewController : MonoViewController<SellConfirmView>
{
    private Action yesBtnCallBack;
    private Action noBtnCallBack;
    //xxj begin
    //private H5GridWrapContent mSellCellGridWrap;
    //private List<PackItemDto> mSellPackItemDtoList = null;
    //xxj end
    private const int MinGridNum = 36;
    protected override void InitView()
    {
        base.InitView();

        //xxj begin
        //mSellCellGridWrap = new H5GridWrapContent(View.SellItemListGrid_GridWrapContent);
        //xxj end
    }

    protected override void RegisterEvent()
    {
        base.RegisterEvent();
        EventDelegate.Set(View.YesBtn_UIButton.onClick, OnClickYesBtn);
        EventDelegate.Set(View.CloseBtn_UIButton.onClick, OnClickCloseBtn);
    }

    protected override void OnDispose()
    {
        base.OnDispose();
    }

    private void DisplayTotalSellCell()
    {
        //xxj begin
        //GridWrapContent.CellsConfig tCellConfig = H5GridWrapContent.CreateNewCellConfig();
        //tCellConfig.mCellName = ItemCell.NAME;
        //tCellConfig.mCellXOffset = 47;
        //tCellConfig.mCellYOffset = -44;
        //tCellConfig.mDisplayFun = DisplaySellCell;
        //tCellConfig.mCount = (mSellPackItemDtoList!=null && mSellPackItemDtoList.Count > MinGridNum)? mSellPackItemDtoList.Count:MinGridNum;

        //mSellCellGridWrap.mGridWrapoContent.Display(tCellConfig, GridArrange.ArrangeType.Vertical);
        //xxj end
    }

    private void DisplaySellCell(GameObject pGo, int pIndex)
    {
        //xxj begin
        //ItemCellController tController = mSellCellGridWrap.GetMonolessController<ItemCellController>(pGo, (tGo) =>
        //{
        //    return new ItemCellController(tGo);
        //});

        //PackItemDto tData = GetPackItemDto(pIndex);
        //tController.SetData(tData, null);
        //xxj end
    }

    //xxj begin
    //private PackItemDto GetPackItemDto(int index)
    //{
    //    if (index<0||mSellPackItemDtoList == null || index >= mSellPackItemDtoList.Count)
    //        return null;
    //    return mSellPackItemDtoList[index];
    //}


    //public void Open(List<PackItemDto> batchSelectList, Action _yesBtnCallBack, Action _noBtnCallBack)
    //{
    //    mSellPackItemDtoList = batchSelectList;
    //    yesBtnCallBack = _yesBtnCallBack;
    //    noBtnCallBack = _noBtnCallBack;
    //    DisplayTotalSellCell();
    //}
    //xxj end
    private void OnClickYesBtn()
    {
        ProxyWindowModule.CloseSellConfirmWin();
        if (yesBtnCallBack != null)
        {
            yesBtnCallBack();
            yesBtnCallBack = null;
        }
            
    }

    private void OnClickCloseBtn()
    {
        ProxyWindowModule.CloseSellConfirmWin();
        if (noBtnCallBack != null)
        {
            noBtnCallBack();
            noBtnCallBack = null;
        }
    }
}

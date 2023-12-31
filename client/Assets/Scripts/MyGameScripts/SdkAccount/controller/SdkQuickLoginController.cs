﻿// **********************************************************************
// Copyright (c) 2016 Baoyugame. All rights reserved.
// Author : Xianjian
// Created : 9/26/2016 11:53:06 AM
// Desc	: Auto generated by MarsZ. update this if need.
// **********************************************************************

using UnityEngine;
using System.Collections.Generic;
using SdkAccountDto;

 /// <summary>
 /// This is the controller class for module AccountQuickLogin, use this to control the ui or view , such as it's init , update or dispose.
 /// @Xianjian in 9/26/2016 11:53:06 AM
 /// </summary>
public class SdkQuickLoginController : MonoViewController<SdkQuickLoginView>
{
    #region property and field
    #region const
    #endregion
    
    private List<SdkLastAccountItemController> _lastItemList;
    private AccountDto _selectAccount;

    #endregion

    #region interface functions
    protected override void InitView ()
    {
        _view.BackBtn_UIButton.gameObject.SetActive(SdkLoginMessage.Instance.GetIsSupportQRLogin());
        var accountList = SdkAccountModel.Instance.GetLastAccount();
        if (accountList == null)
            CreateLastListItem();
        else
        {
            CreateLastListItem(accountList.Count);
        }
        RefreshAccount(accountList);
    }

    protected override void RegisterEvent()
    {
        EventDelegate.Set(_view.PlatformBtn.onClick, OnDemiAccount);
        EventDelegate.Set(_view.TencentBtn.onClick, OnTencentAccount);
        EventDelegate.Set(_view.LoginBtn.onClick, OnLogin);
        EventDelegate.Set(_view.LastAccountBtn.onClick, SwitchAccountGrid);
        EventDelegate.Set(_view.BackBtn_UIButton.onClick, OnBackBtn);
        EventDelegate.Set(_view.RegBtn.onClick, OnRegBtn);  

        SdkAccountModel.Instance.OnRemoveAccount += OnRemoveAccount;
    }

     protected override void OnDispose()
     {
         SdkAccountModel.Instance.OnRemoveAccount -= OnRemoveAccount;
     }
     #endregion

    public void CreateLastListItem(int count=3)
    {
        _lastItemList = new List<SdkLastAccountItemController>();
        //xxj begin
        //GameObject prefab = AssetPipeline.ResourcePoolManager.Instance.LoadUI(SdkLastAccountItem.NAME) as GameObject;
        //xxj end

        GameObject prefab = ResourceManager.Load(SdkLastAccountItem.NAME) as GameObject;
        for (int i=0; i<count; ++i)
        {
            var item = NGUITools.AddChild(_view.AccountGrid.gameObject, prefab);
            var com = new SdkLastAccountItemController(item);
            com.InitItem(i, OnSelectItem, OnDeleteItem);
            _lastItemList.Add(com);
        }
    }

    public void RefreshAccount(List<AccountDto> accountList)
    {
        for(int i = 0; i< _lastItemList.Count; ++i)
        {
            var com = _lastItemList[i];
            if(i < accountList.Count)
            {
                com.RefreshShow(accountList[i]);
                com.gameObject.SetActive(true);
            }
            else com.gameObject.SetActive(false);
        }

        if(accountList.Count > 0) SetSelectAccount(accountList[0]);
    }

    public void SetSelectAccount(AccountDto dto)
    {
        _selectAccount = dto;

        if (dto == null)
        {
            _view.LastLabel.text = "";
            _view.LastIcon.spriteName = "";
            return;
        }

        _view.LastLabel.text = dto.name;
        _view.LastIcon.spriteName = SdkAccountModel.Instance.GetAccountIcon(dto.type); 
    }

    public void OnSelectItem(int index)
    {
        var accountList = SdkAccountModel.Instance.GetLastAccount();
        SetSelectAccount(accountList[index]);
        SwitchAccountGrid();
    }

    public void OnDeleteItem(int index)
    {
        var accountList = SdkAccountModel.Instance.GetLastAccount();
        var deleteDto = accountList[index];
        SwitchAccountGrid();
        SdkAccountModel.Instance.RemoveAccount(deleteDto.UID);
    }

     public void OnRemoveAccount(string uid)
     {
        if (uid == _selectAccount.UID)
        {
            var accountList = SdkAccountModel.Instance.GetLastAccount();
            if (accountList.Count <= 0)
            {
                SdkProxyModule.ClearModule();
                SdkProxyModule.OpenLogin();
                return;
            }
            SetSelectAccount(accountList[0]);
        }
        RefreshAccount(SdkAccountModel.Instance.GetLastAccount());
    }

    private void OnLogin()
    {
        if (_selectAccount == null) return;
        
        GameDebuger.Log(_selectAccount.name+"  "+ _selectAccount.Sid+" "+ _selectAccount.UID);
        SdkAccountModel.Instance.DoSessionLogin(_selectAccount.Sid, _selectAccount.UID, _selectAccount.type);
    }

    private void SwitchAccountGrid()
    {
        GameObject obj = _view.AccountGrid.gameObject;
        obj.SetActive(!obj.activeSelf);
    }

    private void OnRegBtn()
    {
        SdkProxyModule.OpenModule<SdkPlatformRegisterController>(SdkPlatformRegisterView.NAME);
    }

    private void OnDemiAccount()
    {
        SdkProxyModule.OpenModule<SdkPlatformLoginController>(SdkPlatformLoginView.NAME);
    }

    private void OnTencentAccount()
    {
        SdkAccountModel.Instance.DoQQLogin();
    }

    private void OnBackBtn()
    {
        SdkProxyModule.CloseModuleNow(SdkQuickLoginView.NAME);
        SdkLoginMessage.Instance.Sdk2CLoginForQR();
    }
}

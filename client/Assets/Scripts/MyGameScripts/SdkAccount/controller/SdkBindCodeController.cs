﻿// **********************************************************************
// Copyright (c) 2016 Baoyugame. All rights reserved.
// Author : Xianjian
// Created : 9/29/2016 5:18:22 PM
// Desc	: Auto generated by MarsZ. update this if need.
// **********************************************************************

using UnityEngine;
using SdkAccountDto;

public class SdkBindCodeController : MonoViewController<SdkBindCodeView>
{
    private AccountDto.AccountType _editType;

    /// <summary>
    /// 目前只处理手机，即type一定为phone
    /// </summary>
    /// <param name="title"></param>
    /// <param name="success"></param>
    /// <param name="type"></param>
    public void InitData(string title, AccountDto.AccountType type = AccountDto.AccountType.phone)
    {
        _editType = type;

        _view.TitleLabel.text = title;
    }

    protected override void RegisterEvent()
    {
        EventDelegate.Set(_view.BackBtn.onClick, () => { SdkProxyModule.CloseModuleSlow(SdkBindCodeView.NAME); });
        EventDelegate.Set(_view.GetCodeBtn.onClick, OnGetCode);
    }
	
    public void OnGetCode()
    {
        string account = _view.AccoutInput.value;
        if(_editType == AccountDto.AccountType.phone)
        {
            if (!SdkAccountModel.CheckPhone(account)) return;
        }
        else
        {
            if (!SdkAccountModel.CheckEmail(account)) return;
        }


        SdkService.RequestPhoneCode(account, (code) =>
        {
            if (code == 0)
            {
                if (BaseView.IsViewDestroy(View))
                    return;

                var com = SdkProxyModule.OpenModule<SdkBindConfirmController>(SdkBindConfirmView.NAME);
                com.InitData("账号绑定", account, _editType);
            }
        });
    }
}
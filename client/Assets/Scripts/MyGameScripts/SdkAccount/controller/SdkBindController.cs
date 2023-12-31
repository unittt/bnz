﻿// **********************************************************************
// Copyright (c) 2016 Baoyugame. All rights reserved.
// Author : Xianjian
// Created : 10/8/2016 2:29:23 PM
// Desc	: Auto generated by MarsZ. update this if need.
// **********************************************************************

using UnityEngine;
using SdkAccountDto;


public class SdkBindController : MonoViewController<SdkBindView>
{
    protected override void RegisterEvent()
    {
        EventDelegate.Set(_view.BackBtn.onClick, () => { SdkProxyModule.CloseModuleSlow(SdkBindView.NAME); });
        EventDelegate.Set(_view.PhoneBtn.onClick, OnPhoneBtn);
        EventDelegate.Set(_view.WeixinBtn.onClick, OnWeixinBtn);
        EventDelegate.Set(_view.QQBtn.onClick, OnQQBtn);
    }

    public void OnPhoneBtn()
    {
        var com = SdkProxyModule.OpenModule<SdkBindCodeController>(SdkBindCodeView.NAME);
        com.InitData("账号绑定", AccountDto.AccountType.phone);
    }

    public void OnWeixinBtn()
    {
        SdkProxyModule.ShowTips("此版本暂不支持微信绑定");
    }

    public void OnQQBtn()
    {
        SdkProxyModule.ShowTips("此版本暂不支持QQ绑定");
    }
}

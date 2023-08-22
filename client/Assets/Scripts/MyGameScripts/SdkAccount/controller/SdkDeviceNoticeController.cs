﻿// **********************************************************************
// Copyright (c) 2016 Baoyugame. All rights reserved.
// Author : Xianjian
// Desc	: Auto generated by MarsZ. update this if need.
// **********************************************************************

using UnityEngine;
using SdkAccountDto;

/// <summary>
/// This is the controller class for module SelectLogin, use this to control the ui or view , such as it's init , update or dispose.
/// @Xianjian
/// </summary>
public class SdkDeviceNoticeController : MonoViewController<SdkDeviceNotice>
{
    protected override void RegisterEvent()
    {
        EventDelegate.Set(View.BackBtn.onClick, OnBackBtn);
        EventDelegate.Set(View.LoginButton.onClick, OnLoginBtn);
    }

    private void OnLoginBtn()
    {
        string uuid = SdkLoginMessage.Instance.GetUUID();
        SdkAccountModel.Instance.DoLogin(string.Empty, uuid, AccountDto.AccountType.device);
    }

    private void OnBackBtn()
    {
        SdkProxyModule.CloseModuleSlow(SdkDeviceNotice.NAME);
    }
}

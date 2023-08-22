// **********************************************************************
// Copyright (c) 2016 cilugame. All rights reserved.
// File     : QQLoginHelper.cs
// Author   : senkay <senkay@126.com>
// Created  : 12/19/2016 
// Porpuse  : 德米游戏的QQ登陆方式
// **********************************************************************
//
using System;
using System.Diagnostics;
using UnityEngine;
using System.Text.RegularExpressions;
using SdkAccountDto;

public class QQLoginHelper
{
    public const string QQLogin_APPID = "101369233";//德米游戏
    public const string QQLogin_scope = "get_user_info";
    public const string QQLogin_URL = "https://graph.qq.com/oauth2.0/authorize?response_type=code&client_id={0}&redirect_uri={1}&scope={2}&display={3}&state={4}";

    public static string QQ_accessToken = "";
    public static string QQ_OpenId = "";

    private static Action<AccountDto> LoginFinishCallBack;

    //打开登录页
    static public void OpenLoginPage(Action<AccountDto> _loginFinishCallBack)
    {
        LoginFinishCallBack = _loginFinishCallBack;

        string display = "mobile"; //pc or mobile

        string qqLoginUrl = SdkLoginMessage.Instance.GetQQLoginUrl() + "?deviceId={0}";
        string loginUrl = string.Format(QQLogin_URL, QQLogin_APPID, 
            WWW.EscapeURL(string.Format(qqLoginUrl, SdkLoginMessage.Instance.GetUUID())), 
            QQLogin_scope, display, GameSetting.APP_ID.ToString());
        GameDebug.Log("qqLoginUrl:" + qqLoginUrl);
        GameDebug.Log("loginUrl:" + loginUrl);
        GameDebug.Log("SdkLoginMessage.Instance.GetUUID():" + SdkLoginMessage.Instance.GetUUID() + " QQLogin_scope:" + QQLogin_scope + " display:" + display + " GameSetting.APP_ID:" + GameSetting.APP_ID.ToString());
        ProxyBuiltInWebModule.Open(loginUrl);

        GameEventCenter.RemoveListener(GameEvent.BuiltInWebView_OnReceivedMessage, BuiltInWebView_OnReceivedMessage);
        GameEventCenter.AddListener(GameEvent.BuiltInWebView_OnReceivedMessage, BuiltInWebView_OnReceivedMessage);
    }

    static private void BuiltInWebView_OnReceivedMessage(UniWebViewMessage message)
    {
        GameEventCenter.RemoveListener(GameEvent.BuiltInWebView_OnReceivedMessage, BuiltInWebView_OnReceivedMessage);

        ProxyBuiltInWebModule.Close();

        if (message.path == "logincallback")
        {
            string json = message.args["msg"];
            GameDebuger.Log("logincallback=" + json);

            ResponseDto responseDto = JsHelper.ToObject<ResponseDto>(json);
            if (CheckDtoValid(responseDto))
            {
                var dto = JsHelper.ToObject<LoginResponseDto>(json);
                if (CheckDtoValid(dto))
                {
                    AccountDto dAccount = new AccountDto(dto);
                    dAccount.type = AccountDto.AccountType.qq;
                    if (LoginFinishCallBack != null)
                    {
                        LoginFinishCallBack(dAccount);
                        LoginFinishCallBack = null;
                    }
                }
            }
        }
    }

    public static bool CheckDtoValid(ResponseDto dto)
    {
        if (dto == null)
        {
            SdkProxyModule.ShowTips("请求超时");
            return false;
        }
        if (dto.code > 0)
        {
            if (string.IsNullOrEmpty(dto.msg))
            {
                SdkProxyModule.ShowTips("未知错误-" + dto.code);
            }
            else
            {
                SdkProxyModule.ShowTips(dto.msg);
            }
            return false;
        }

        return true;
    }
}
    

public class QQOpenIDInfo
{
    public string client_id;
    public string openid;
}
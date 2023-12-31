﻿// **********************************************************************
// Copyright (c) 2016 Baoyugame. All rights reserved.
// Author : Xianjian
// Created : 9/26/2016 11:39:52 AM
// Desc	: Auto generated by MarsZ. update this if need.
// **********************************************************************

using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using SdkAccountDto;

/// <summary>
/// This is the model class for module AccountSDK, use this to manage the data of module AccountSDK.
/// @Xianjian in 9/26/2016 11:39:52 AM
/// </summary>
public class SdkAccountModel
{
    private static readonly SdkAccountModel _instance = new SdkAccountModel();

    public static SdkAccountModel Instance
    {
        get { return _instance; }
    }

    public SdkAccountModel()
    {
        
    }

    //验证码时间限制
    public const float CODE_LIMIT_SEC = 100f;
    //seesion最高数量
    public const int SAVE_LIMIT = 6;
    public const string LOGINCACHE_KEY = "sdkloginsession";
    public const string LOGINENTERACCOUNT_KEY = "sdkaccountlist";

    public System.Action<string> OnRemoveAccount;
    public System.Action<AccountDto> OnAccountReset;
    
    private AccountDto _loginAccount;
    public AccountDto loginAccount
    {
        get { return _loginAccount; }
        set
        {
            if (OnAccountReset != null)
                OnAccountReset(value);

            _loginAccount = value;
        }
    }

    //是否已实名认证
    public bool IsRealAuth()
    {
        if (loginAccount == null)
            return false;

        return loginAccount.loginSeesionDto.realNameAuthed;
    }

    public void SetIsRealAuth()
    {
        if (loginAccount == null)
            return;

        loginAccount.loginSeesionDto.realNameAuthed = true;
    }

    private List<AccountDto> _accountList;
    public List<AccountDto> GetLastAccount()
    {
        if (_accountList != null) return _accountList;

        _accountList = new List<AccountDto>();
        string sCache = PlayerPrefs.GetString(LOGINCACHE_KEY);
        
        if (string.IsNullOrEmpty(sCache)) return _accountList;

        string[] sAccountList = sCache.Split('|');
        foreach(string sInfo in sAccountList)
        {
            string[] sList = sInfo.Split('&');
            if (sList.Length != 5) continue;

            AccountDto dto = new AccountDto();
            dto.type = (AccountDto.AccountType)int.Parse(sList[0]);
            dto.UID = sList[1];
            dto.name = sList[2];
            dto.Sid = sList[3];
            //dto.AccountSeesion = sList[4];
            _accountList.Add(dto);
        }
        return _accountList;
    }

    public void SaveAccount(AccountDto dto)
    {
        loginAccount = dto;
        //是否保存登录状态
        if (!_isSaveAccount)
            return;

        List<AccountDto> newList = new List<AccountDto>();
        newList.Add(dto);
        for (int i = 0; i < _accountList.Count; ++i)
        {
            if (newList.Count >= SAVE_LIMIT)
                break;

            if (_accountList[i].UID == dto.UID)
                continue;
            newList.Add(_accountList[i]);
        }
        _accountList = newList;

        DoSaveAccountList();
    }

    public void RemoveAccount(string uid)
    {
        List<AccountDto> newList = new List<AccountDto>();
        for (int i = 0; i < _accountList.Count; ++i)
        {
            if (_accountList[i].UID == uid)
                continue;
            newList.Add(_accountList[i]);
        }
        _accountList = newList;
        DoSaveAccountList();

        if (OnRemoveAccount != null)
            OnRemoveAccount(uid);
    }

    public void DoSaveAccountList()
    {
        string sSave = "";
        for (int i = 0; i < _accountList.Count; ++i)
        {
            AccountDto account = _accountList[i];
            sSave += string.Format("{0}&{1}&{2}&{3}&{4}", (int)account.type,
                account.UID, account.name, account.Sid, account.AccountSeesion);
            if (i != _accountList.Count - 1) sSave += "|";
        }
        PlayerPrefs.SetString(LOGINCACHE_KEY, sSave);
    }

    private const int LASTENTER_MAXCOUNT = 6;
    private List<string> _lastEnterAccount;

    public List<string> GetLastEnterAccount()
    {
        if (_lastEnterAccount == null)
        {
            string sCache = PlayerPrefs.GetString(LOGINENTERACCOUNT_KEY);
            if (!string.IsNullOrEmpty(sCache))
            {
                string[] sAccountList = sCache.Split('|');
                _lastEnterAccount = new List<string>(sAccountList);
            }
            else
            {
                _lastEnterAccount = new List<string>();
            }
        }
        return _lastEnterAccount;
    }
    public void SaveLastEnterAccount(string account)
    {
        var lastList = GetLastEnterAccount();
        var newList = new List<string>();
        newList.Add(account);
        for (int i = 0; i < lastList.Count; ++i)
        {
            if (i > LASTENTER_MAXCOUNT)
                break;

            if (lastList[i].Equals(account))
                continue;

            newList.Add(lastList[i]);
        }
        _lastEnterAccount = newList;

        DoSaveLastEnterAccount();
    }

    public void DelLastEnterAccount(int index)
    {
        var lastList = GetLastEnterAccount();
        if (index < lastList.Count)
        {
            lastList.RemoveAt(index);
        }

        DoSaveLastEnterAccount();
    }


    public void DoSaveLastEnterAccount()
    {
        string sSave = string.Join("|", _lastEnterAccount.ToArray());
        PlayerPrefs.SetString(LOGINENTERACCOUNT_KEY, sSave);
    }

    public void DoQQLogin()
    {
#if UNITY_STANDALONE_WIN || UNITY_EDITOR
        SdkProxyModule.ShowTips("PC版本不支持QQ登录");
        return;
#endif

        //SdkProxyModule.ShowTips("暂不支持QQ登录");
        //return;

        //xxj begin
        QQLoginHelper.OpenLoginPage((dto) =>
        {
            OnLoginSuccess(dto, true);
        });
        //xxj end
    }

    public void DoLogin(string account, string password, AccountDto.AccountType type, bool bSaveAccount=true)
    {
        if (type == AccountDto.AccountType.device)
        {
#if UNITY_STANDALONE_WIN && !UNITY_EDITOR
            SdkProxyModule.ShowTips("此版本不支持快捷登录");
            return;
#endif
        }
        else if (type == AccountDto.AccountType.qq)
        {
#if UNITY_STANDALONE_WIN || UNITY_EDITOR
            SdkProxyModule.ShowTips("PC版本不支持QQ登录");
            return;
#endif
        }

        SdkService.RequestLogin(account, password, 
            SdkLoginMessage.Instance.GetUUID(), type, (dto) =>
            {
                OnLoginSuccess(dto as AccountDto, bSaveAccount);
                if (type == AccountDto.AccountType.phone)
                {
                    SaveLastEnterAccount(account);
                }
            });
    }

    public void DoSessionLogin(string token, string uid, AccountDto.AccountType type)
    {
        SdkService.RequestSessionLogin(token, uid,
            SdkLoginMessage.Instance.GetUUID(), type,
            (dto) =>
            {
                OnLoginSuccess(dto, true);
            }, 
            OnSessionInvalid);
    }

    //是否记住密码（即是否保存登录状态）
    private bool _isSaveAccount;
    public void OnLoginSuccess(AccountDto dto, bool bSaveAccount = true)
    {
        _isSaveAccount = bSaveAccount;
        SaveAccount(dto);
        //RemoveAccount(dto.UID);

        SdkProxyModule.ClearModule();

        bool bGuest = (dto.type == AccountDto.AccountType.device);
        GameDebug.Log("bGuest:" + bGuest + " dto.Sid:" + dto.Sid + " dto.UID:" + dto.UID);
        SdkLoginMessage.Instance.Sdk2CLogin(bGuest, dto.Sid);
        if (bGuest)
            SdkProxyModule.OpenBind();
    }

    //会话失效
    public void OnSessionInvalid(string uid)
    {
        RemoveAccount(uid);
    }

    public void OnRequestBind(string sid, string name, string password,
        AccountDto.AccountType type, string verifyCode)
    {
        SdkService.RequestBind(sid, name, password, type, verifyCode, (backcode) =>
        {
            if (backcode == 0)
            {
                //绑定成功，先清除显示
                SdkProxyModule.ClearModule();
                SdkProxyModule.ShowTips("绑定成功");

                //绑定成功，更改账户类型及登录名
                if (_loginAccount == null || _loginAccount.type != AccountDto.AccountType.device)
                    return;

                _loginAccount.type = type;
                _loginAccount.name = name;
                SaveAccount(_loginAccount);
            }
        });
    }

    //实名认证
    public void OnRequestRealAuth(string realName, string idCardNo, System.Action<bool> success)
    {

        if (realName == "")
        {
            SdkProxyModule.ShowTips("姓名不能为空");
            return;
        }

        SdkService.RequestRealNameAuth(GetSid(), realName, idCardNo, null, (code) =>
        {
            SetIsRealAuth();
            success(true);
        });
    }

    //切换账号,会等待游戏层login
    public void ChangeAccount()
    {
        loginAccount = null;
        SdkProxyModule.ClearModule();

        SdkLoginMessage.Instance.Sdk2CLogout();
    }

    //游戏层通知退出账号
    public void Game2Logout()
    {
        loginAccount = null;
        SdkProxyModule.ClearModule();
//        SdkProxyModule.OpenLogin();
    }

    /// <summary>
    /// 是否处于登录状态
    /// </summary>
    /// <returns></returns>
    public bool IsLogin()
    {
        return _loginAccount != null;
    }

    public string GetSid()
    {
        if (_loginAccount == null)
            return "";

        return _loginAccount.Sid;
    }

    public string GetUid()
    {
        if (_loginAccount == null)
            return "";

        return _loginAccount.UID;
    }

    public string GetAccountId()
    {
        if (_loginAccount == null || _loginAccount.loginSeesionDto == null)
            return "";

        return _loginAccount.loginSeesionDto.accountId;
    }

    //demi账号登录，用户名即手机号
    public string GetAccountName()
    {
        if (_loginAccount == null || _loginAccount.loginSeesionDto == null)
            return "";

        return _loginAccount.loginSeesionDto.accountName;
    }

    public bool IsBound()
    {
        if (_loginAccount == null) return false;

        return _loginAccount.loginSeesionDto.accountBound;
    }

    //临时账号登录
    public bool IsTempLogin()
    {
        if (_loginAccount == null) return false;

        return _loginAccount.type == AccountDto.AccountType.device;
    }

    //demi 即手机登录
    public bool IsDemiLogin()
    {
        if (_loginAccount == null) return false;

        return _loginAccount.type == AccountDto.AccountType.phone;
    }

    public static bool CheckAccount(string account)
    {
        return true;
    }

    public static bool CheckPhone(string phone)
    {
        if(string.IsNullOrEmpty(phone) || phone.Length != 11 || !IsDigit(phone))
        {
            SdkProxyModule.ShowTips("请输入正确的手机号");
            return false;
        }

        return true;
    }

    public static bool CheckEmail(string email)
    {
        if (string.IsNullOrEmpty(email))
        {
            SdkProxyModule.ShowTips("请输入正确的邮箱");
            return false;
        }
        return true;
    }

    public static bool CheckPassword(string password1, string password2)
    {
        if (string.IsNullOrEmpty(password1))
        {
            SdkProxyModule.ShowTips("密码不能为空");
            return false;
        }

        if(password1 != password2)
        {
            SdkProxyModule.ShowTips("两次密码不一致");
            return false;
        }

        //密码其它规则交给服务端

        return true;
    }

    //检测验证码
    public static bool CheckVerifyCode(string code)
    {
        if (string.IsNullOrEmpty(code))
        {
            SdkProxyModule.ShowTips("验证码不能为空");
            return false;
        }
        return true;
    }

    public static bool IsDigit(string str)
    {
        return Regex.IsMatch(str, @"^[0-9]+$");
    }

    public string GetAccountIcon(AccountDto.AccountType type)
    {
        string spriteName = "device-icon";
        //switch (type)
        //{
        //    case AccountDto.AccountType.device:
        //        spriteName = "device-icon";
        //        break;

        //    case AccountDto.AccountType.phone:
        //        spriteName = "demi-icon";
        //        break;

        //    case AccountDto.AccountType.qq:
        //        spriteName = "qq-icon";
        //        break;

        //    case AccountDto.AccountType.weixin:
        //        break;
        //}
        return spriteName;
    }
}
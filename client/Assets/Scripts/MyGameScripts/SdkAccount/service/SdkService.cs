using System;
using System.Collections;
using System.Collections.Generic;
using SdkAccountDto;
using UnityEngine;
using LuaInterface;

class SdkService
{
    private static Dictionary<string, string> _jsonDics = new Dictionary<string, string>();

    /// <summary>
    /// 登录
    /// </summary>
    /// <param name="name">账号名</param>
    /// <param name="password">md5密码</param>
    /// <param name="deviceId">设备号</param>
    /// <param name="type">账号类型0自由；1手机；2邮箱；3设备；4QQ登录；5微信登录；目前暂支持1,2,3.</param>
    /// <param name="successCallback"></param>
    public static void RequestLogin(string name, string password, string deviceId,
        AccountDto.AccountType type, 
        Action<AccountDto> successCallback)
    {
        var manager = SdkLoginMessage.Instance;
        string url = manager.GetLoginUrl();

        //设备号登录，用户名仅显示用，密码作为登录账户
        if(type == AccountDto.AccountType.device)
        {
            url = url + string.Format("?gameId={0}&name={1}&type={2}&deviceId={3}",
                manager.GetGameID(), password, (int)type, deviceId);
        }
        else
        {
            url = url + string.Format("?gameId={0}&name={1}&password={2}&type={3}&deviceId={4}", 
                manager.GetGameID(), name, password, (int)type, deviceId);
        }

        RequestJson(url, "SdkLogin", "登录中", delegate (string json)
        {
            var dto = JsHelper.ToObject<LoginResponseDto>(json);
            if (CheckDtoValid(dto))
            {
                AccountDto dAccount = new AccountDto(dto);
                dAccount.type = type;
                successCallback(dAccount);
            }
        }, true, true);
    }

    /// <summary>
    /// 通过会话session登录
    /// </summary>
    /// <param name="token"></param>
    /// <param name="uid"></param>
    /// <param name="deviceId"></param>
    /// <param name="type"></param>
    /// <param name="successCallback"></param>
    /// <param name="seesionInvalidCallback">会话失效</param>
    public static void RequestSessionLogin(
        string token,
        string uid,
        string deviceId,
        AccountDto.AccountType type,
        Action<AccountDto> successCallback,
        Action<string> seesionInvalidCallback
        )
    {
        var manager = SdkLoginMessage.Instance;
        var url = manager.GetCheckSessionUrl() + string.Format("?gameId={0}&token={1}&deviceId={2}",
            manager.GetGameID(), token, deviceId);

        RequestJson(url, "SdkLogin", "登录中", delegate (string json)
        {
            var dto = JsHelper.ToObject<LoginResponseDto>(json);
            if (CheckDtoValid(dto))
            {
                AccountDto dAccount = new AccountDto(dto);
                dAccount.type = type;
                successCallback(dAccount);
            }
            //会话失效
            else if (dto != null && dto.code == ResponseDto.ACCOUNT_SESSION_EXPIRED)
            {
                seesionInvalidCallback(uid);
            }
        }, true, true);
    }

    /// <summary>
    /// 自动使用seesion登录，不锁屏，不检测接受到的数据
    /// </summary>
    /// <param name="token"></param>
    /// <param name="uid"></param>
    /// <param name="deviceId"></param>
    /// <param name="type"></param>
    /// <param name="callback"></param>
    public static void RequestSessionLogin(
        string token,
        string uid,
        string deviceId,
        AccountDto.AccountType type,
        Action<LoginResponseDto> callback
        )
    {
        var manager = SdkLoginMessage.Instance;
        var url = manager.GetCheckSessionUrl() + string.Format("?gameId={0}&token={1}&deviceId={2}",
            manager.GetGameID(), token, deviceId);

        RequestJson(url, "SdkLogin", "登录中", delegate (string json)
        {
            var dto = JsHelper.ToObject<LoginResponseDto>(json);
            callback(dto);
        }, false, true);
    }

    /// <summary>
    /// 请求验证码
    /// </summary>
    /// <param name="phone"></param>
    /// <param name="downLoadFinishCallBack"></param>
    public static void RequestPhoneCode(string phone,
        Action<int> downLoadFinishCallBack)
    {
        var manager = SdkLoginMessage.Instance;
        string url = "";

        if (!GameSetting.DEMI_SDK_USE_NEW)
        {
            url = manager.GetPhoneCodeUrl();
            url = url + "?phone=" + phone;
        }
        else
        {
            url = manager.GetPhoneCodeUrl();
            url = url + "?phone=" + phone + "&sdk=" + GameSetting.DEMI_SDK_CODE;
        }
        
        RequestJson(url, "SdkRegister", "请求验证码中", delegate (string json)
        {
            ResponseDto dto = JsHelper.ToObject<ResponseDto>(json);
            if (CheckDtoValid(dto))
            {
                downLoadFinishCallBack(0);
            }
        }, true, true);
    }

    /// <summary>
    /// 注册、修改密码、找回密码
    /// </summary>
    /// <param name="name">目前只支持手机号</param>
    /// <param name="password"></param>
    /// <param name="type"></param>
    /// <param name="verifyCode"></param>
    /// <param name="optType">操作类型:1注册；2修改密码；3找回密码</param>
    /// <param name="downLoadFinishCallBack"></param>
    public static void RequestRegister(string name, string password, string deviceId, AccountDto.AccountType type,
         string verifyCode, Action<int> downLoadFinishCallBack)
    {
        var manager = SdkLoginMessage.Instance;
        string url = manager.GetRegistUrl();
        url = url + string.Format("?gameId={0}&name={1}&password={2}&type={3}&verifyCode={4}&deviceId={5}",
            manager.GetGameID(), name, password, (int)type, verifyCode, deviceId);

        RequestJson(url, "SdkRegister", "请求中", delegate (string json)
        {
            ResponseDto dto = JsHelper.ToObject<ResponseDto>(json);
            if (CheckDtoValid(dto))
            {
                downLoadFinishCallBack(0);
            }
        }, true, true);
    }


    public static void RequestFindPassword(string name, string password, AccountDto.AccountType type, 
        string verifyCode, Action<int> downLoadFinishCallBack)
    {
        var manager = SdkLoginMessage.Instance;
        string url = manager.GetFindPasswordUrl();

        url = url + string.Format("?gameId={0}&name={1}&password={2}&type={3}&verifyCode={4}",
           manager.GetGameID(), name, password, (int)type, verifyCode);

        RequestJson(url, "SdkFindPassword", "请求中", delegate (string json)
        {
            ResponseDto dto = JsHelper.ToObject<ResponseDto>(json);
            if (CheckDtoValid(dto))
            {
                downLoadFinishCallBack(0);
            }
        }, true, true);
    }

    public static void RequestModifyPassword(string sid, string password, 
        string verifyCode, Action<int> downLoadFinishCallBack)
    {
        var manager = SdkLoginMessage.Instance;
        string url = manager.GetModifyPasswordUrl();

        url = url + string.Format("?gameId={0}&sid={1}&password={2}&verifyCode={3}",
           manager.GetGameID(), sid, password, verifyCode);

        RequestJson(url, "SdkModifyPassword", "请求中", delegate (string json)
        {
            ResponseDto dto = JsHelper.ToObject<ResponseDto>(json);
            if (CheckDtoValid(dto))
            {
                downLoadFinishCallBack(0);
            }
        }, true, true);
    }

    /// <summary>
    /// 账号绑定
    /// </summary>
    /// <param name="sid">已登录的会话ID</param>
    /// <param name="name">绑定目标账号名</param>
    /// <param name="password"></param>
    /// <param name="type">绑定目标账号类型</param>
    /// <param name="verifyCode"></param>
    /// <param name="downLoadFinishCallBack"></param>
    public static void RequestBind(string sid, string name, string password,
        AccountDto.AccountType type, string verifyCode, Action<int> downLoadFinishCallBack)
    {
        var manager = SdkLoginMessage.Instance;
        string url = manager.GetBoundUrl();
        url = url + string.Format("?gameId={0}&sid={1}&name={2}&password={3}&type={4}&verifyCode={5}",
            manager.GetGameID(), sid, name, password, (int)type, verifyCode);

        RequestJson(url, "SdkBind", "请求绑定中", delegate (string json)
        {
            ResponseDto dto = JsHelper.ToObject<ResponseDto>(json);
            if (CheckDtoValid(dto))
            {
                downLoadFinishCallBack(0);
            }
        }, true, true);
    }

    public static void RequestRealNameAuth(string sid, string realName, string idCardNo, string mobileNo,
        Action<int> downLoadFinishCallBack)
    {
        var manager = SdkLoginMessage.Instance;
        string url = manager.GetNameAuthedUrl() + string.Format("?sid={0}&realName={1}&idCardNo={2}", 
            sid, WWW.EscapeURL(realName), idCardNo);

        if (mobileNo != null)
        {
            url = url + "&mobileNo=" + mobileNo;
        }

        RequestJson(url, "RequestRealNameAuth", "提交实名制数据", delegate (string json)
        {
            ResponseDto dto = JsHelper.ToObject<ResponseDto>(json);
            if (CheckDtoValid(dto))
            {
                downLoadFinishCallBack(0);
            }
        }, true, true);
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

    #region 手机绑定相关
    /// <summary>
    /// 发送验证码
    /// </summary>
    /// <param name="sid">Sid.</param>
    /// <param name="phone">手机号码.</param>
    /// <param name="code">加密过的验证码.</param>
    /// <param name="sign">md5串,aid,appId,phone,data,加密key用"|"拼接，生成md5值并转换成大写</param>
    /// <param name="downLoadFinishCallBack">Down load finish call back.</param>
    public static void RequestSendVerifyCode(string aid, string phone, string appId, string data,
        Action<int> downLoadFinishCallBack)
    {
        var manager = SdkLoginMessage.Instance;
        string rootUrl = manager.GetSendVerifyCodeUrl();

        string srcSign = aid + "|" + appId + "|" + phone + "|" + data + "|" + "11WJL5Te";
        string sign = MD5Hashing.HashString(srcSign).ToUpper();
        data = WWW.EscapeURL(data);
        string url = "";

        if (!GameSetting.DEMI_SDK_USE_NEW)
        {
            url = rootUrl + "?aid={0}&appId={1}&phone={2}&data={3}&sign={4}";
            url = string.Format(url, aid, appId, phone, data, sign);
        }
        else
        {
            url = rootUrl + "?aid={0}&appId={1}&phone={2}&data={3}&sign={4}&sdk={5}";
            url = string.Format(url, aid, appId, phone, data, sign, GameSetting.DEMI_SDK_CODE);
        }

        RequestJson(url, "RequestSendVerifyCode", "发送验证码中", delegate (string json)
        {
            SdkResponseDto dto = JsHelper.ToObject<SdkResponseDto>(json);
            if (dto == null)
            {
                //xxj begin
                //TipManager.AddTip("请求超时");
                //xxj end

                LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.tip");
                func.Call("请求超时");
                func.Dispose();
            }
            else
            {
                if (dto.code > 0)
                {
                    //xxj begin
                    //TipManager.AddTip(dto.msg);
                    //xxj end

                    LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.tip");
                    func.Call(dto.msg);
                    func.Dispose();
                }
                else
                {
                    downLoadFinishCallBack(0);
                }
            }
        }, true, true);
    }

    /// <summary>
    /// 获取账号绑定的手机号码
    /// </summary>
    /// <param name="aid">Aid.</param>
    /// <param name="downLoadFinishCallBack">Down load finish call back.</param>
    public static void RequestBindMobile(string aid, string appId,
        Action<string> downLoadFinishCallBack)
    {
        var manager = SdkLoginMessage.Instance;
        string rootUrl = manager.GetBindMobileNum();
        string url = rootUrl + "?aid={0}&appId={1}";
        url = string.Format(url, aid, appId);

        RequestJson(url, "RequestBindMobile", "", delegate (string json)
            {
                SdkResponseDto dto = JsHelper.ToObject<SdkResponseDto>(json);
                if (dto == null)
                {
                    //xxj begin
                    //TipManager.AddTip("请求超时");
                    //xxj end

                    LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.tip");
                    func.Call("请求超时");
                    func.Dispose();
                }
                else
                {
                    if (dto.code > 0)
                    {
                        //xxj begin
                        //TipManager.AddTip(dto.msg);
                        //xxj end

                        LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.tip");
                        func.Call(dto.msg);
                        func.Dispose();
                    }
                    else
                    {
                        downLoadFinishCallBack(dto.item);
                    }
                }
            }, true, true);
    }

    //向sdk请求区id及转换过后的渠道
    public static void RequestChannelExtInfo(string appId, 
        string channelId,
        string subChannelId,
        Action<SdkChannelExtInfoDto> downLoadFinishCallBack,
        Action<string> onError=null)
    {
        string url = SdkLoginMessage.Instance.GetChannelExtUrl() + string.Format("?appId={0}&channel={1}&p={2}", appId, channelId, subChannelId);

        RequestJson(url, "ChannelExtInfo", "获取渠道参数", delegate (string json)
        {
            ResponseDto dto = JsHelper.ToObject<ResponseDto>(json);
            if (dto == null)
            {
                GameDebuger.LogError("无法获取服务器区号");
                if(onError != null)
                    onError("无法获取服务器区号");
            }
            else
            {
                if (dto.code > 0)
                {
                    GameDebuger.LogError(dto.msg);
                    if (onError != null)
                        onError(dto.msg);
                }
                else
                {
                    SdkChannelExtInfoDto channelExtDto = JsHelper.ToObject<SdkChannelExtInfoDto>(json);
                    downLoadFinishCallBack(channelExtDto);
                }
            }
        }, true, true);
    }
    
    /// <summary>
    /// 请求打开论坛
    /// </summary>
    public static void OpenBBS(string token, string session)
    {
        string url = SdkLoginMessage.Instance.GetEnterBBSUrl() +
                     string.Format("?gameId={0}&token={1}&session={2}", SdkLoginMessage.Instance.GetGameID(), token,
                         session);
        GameDebuger.Log(url);
        //先改用系统的
        //ProxyBuiltInWebModule.Open(url);
        Application.OpenURL(url);
    }

    #endregion

    public static void RequestJson(string url, string jsonName, string tips, Action<string> downLoadFinishCallBack,
        bool needLock = true, bool refresh = false, Dictionary<string, string> headers = null)
    {
        if (!refresh && _jsonDics.ContainsKey(jsonName))
        {
            string json = _jsonDics[jsonName];
            downLoadFinishCallBack(json);
            return;
        }

        GameDebuger.Log("2 RequestJson " + url);


        if (needLock)
        {
            GameDebuger.Log("2222222222 RequestJson " + url);
            SdkLoadingTipController.Show(tips, true, true);
        }

        Hashtable hashHeaders = null;
        if (headers != null)
        {
            hashHeaders = new Hashtable();
            foreach (var header in headers)
            {
                hashHeaders[header.Key] = header.Value;
            }
        }

        HttpController.Instance.DownLoad(url, delegate (ByteArray byteArray)
        {
            if (needLock)
            {
                SdkLoadingTipController.Stop(tips);
            }

            string json = byteArray.ToUTF8String();

            _jsonDics[jsonName] = json;

            GameDebuger.Log("下载成功");
            GameDebuger.Log(json);

            downLoadFinishCallBack(json);
        }, null, delegate (Exception exception)
        {
            if (needLock)
            {
                SdkLoadingTipController.Stop(tips);
            }

            GameDebuger.Log(string.Format("RequestJson url={0} error={1}", url, exception.ToString()));

            downLoadFinishCallBack(null);
        }, false, SimpleWWW.ConnectionType.Short_Connect, hashHeaders);
    }
}

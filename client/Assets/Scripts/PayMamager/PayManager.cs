
using System.Collections.Generic;
using LuaInterface;
using LITJson;
using System.Web;
using UnityEngine;

public class PayManager
{
    public static PayManager Instance
    {
        get;
        private set;
    }

    public static void CreateInstance()
    {
        if (Instance != null)
        {
            return;
        }
        Instance = new PayManager();
    }

    public class OrderCustomInfo
    {
        //------------------------
        //德米-支付
        public string account;
        //------------------------ 
        //德米-广告
        public string ad_app_id;
        public string active_id;
        public string system_id;
        public string role_name;
        //------------------------ 
    }

    public class OrderCustomInfoAndroid
    {
        //------------------------
        //德米-支付
        public string demiPayCallbackURL;
        public string account;
        public string yesdkOrderId;
        public string gameOrderExtend;
        public string gameOrderDesc;
        public string productExtend;
        public string paymentTile;
        public string sdk;
        //------------------------ 
        //德米-热云
        public string appKey;
        public string campaignid;
        public bool   useDemiReyun;
        //------------------------ 
        //德米-广告
        public string ad_app_id;
        public string active_id;
        public string system_id;
        public string role_name;
        //------------------------ 
    }

    //public class TrackingIOInfo
    //{
    //    public string campaignid;
    //    public string imei;
    //}

    private Dictionary<string, OrderItemJsonDto> _payItemDicWithStringId;
	public Dictionary<string, int> productIdDic = new Dictionary<string, int>();

    // 购买成功返回
	private System.Action<bool> _onPayCallBack;
	private LuaFunction _luaCallback;

    #region ios 微信支付宝支付
    //是否开启切支付功能
    public static bool openSwitchPay = false;

    //框架是否支持微信/支付宝支付
    public static bool isSupportThirdPay = false;

    public static bool thirdPayIsAli = false;
    #endregion

    public void Setup(string payInfoStr)
	{
		Debugger.Log ("PayManager.Setup:" + payInfoStr);

        AppStoreInAppManager.Setup();
		string[] infos = payInfoStr.Split(';');
		string[] ids =  new string[infos.Length];
		for (int i = 0, len = infos.Length; i < len; i++) {
			string[] strs = infos[i].Split(',');
			string key = strs [0];
			ids[i] = key;
			productIdDic [key] = int.Parse(strs[1]);
		}
		AppStoreInAppManager.Instance.Init(ids);

        Debugger.Log("PayManager.Setup openSwitchPay:" + openSwitchPay + " isSupportThirdPay:" + isSupportThirdPay);
    }

    public void SetupForDemi()
    {
        Debugger.Log("PayManager.SetupForDemi");

        //初始化判断是否支持微信/支付宝支付
        isSupportThirdPay = FrameworkUpgradeHelper.IsSupported(FrameworkUpgradeHelper.H5_ALI_PAY) || FrameworkUpgradeHelper.IsSupported(FrameworkUpgradeHelper.IOS_WX_PAY);

        openSwitchPay = GameSetting.PAY_SWITCH;

        Debugger.Log("PayManager.SetupForDemi openSwitchPay:" + openSwitchPay + " isSupportThirdPay:" + isSupportThirdPay);
    }

	public void ResetCallbackURL(string url) {
		AppStoreInAppManager.Instance.ResetCallbackURL(url);
	}
	
	#region IOS支付
	public void ChargeByIOSInAppPurchase(string productIdentifier, int quantity, string orderId, LuaFunction cb = null)
	{
        GameDebuger.Log("PayManager.ChargeByIOSInAppPurchase productIdentifier:" + productIdentifier + " SupportInAppPurchase:" + SupportInAppPurchase());

        _luaCallback = cb;

		AppStoreInAppManager.Instance.onAppStorePurchaseSuccessed -= onBaoyugamePurchaseSuccessed;
		AppStoreInAppManager.Instance.onAppStorePurchaseSuccessed += onBaoyugamePurchaseSuccessed;
		
		AppStoreInAppManager.Instance.onAppStorePurchaseFailed -= onBaoyugamePurchaseFailed;
		AppStoreInAppManager.Instance.onAppStorePurchaseFailed += onBaoyugamePurchaseFailed;
		
		AppStoreInAppManager.Instance.onAppStorePurchaseCancel -= onBaoyugamePurchaseFailed;
		AppStoreInAppManager.Instance.onAppStorePurchaseCancel += onBaoyugamePurchaseFailed;
		
		AppStoreInAppManager.Instance.PurchaseProduct(productIdentifier, quantity, orderId);
	}
	
	//	重新获取订单
	public void RestoreCompletedTransactions(LuaFunction cb)
    {
		AppStoreInAppManager.Instance.RestoreCompletedTransactions(cb);
	}

	//	订单重新传送
	public void StartCoroutineSendReceiptToServer(IOSStoreKitResult result, string orderId, bool delay) {
		AppStoreInAppManager.Instance.StartCoroutineSendReceiptToServer(result, orderId, delay);
	}

	//	支付成功
    private void onBaoyugamePurchaseSuccessed()
    {
		string msg = "支付完成，如充值成功请等待到账";
		DoBaoyugamePurchase (true, msg);
    }

	//	支付失败
    private void onBaoyugamePurchaseFailed(string error)
	{
		string msg = error;
		DoBaoyugamePurchase (false, msg);
		GameDebug.Log(error);
    }

	private void DoBaoyugamePurchase(bool success, string msg) {
		GameDebug.Log(msg);
//		TipManager.AddTip(msg);
//		RequestLoadingTip.Reset();

		AppStoreInAppManager.Instance.onAppStorePurchaseSuccessed -= onBaoyugamePurchaseSuccessed;
		AppStoreInAppManager.Instance.onAppStorePurchaseFailed -= onBaoyugamePurchaseFailed;
		AppStoreInAppManager.Instance.onAppStorePurchaseCancel -= onBaoyugamePurchaseFailed;
		if (_luaCallback != null)
		{
			_luaCallback.BeginPCall();
			_luaCallback.Push(success);
			_luaCallback.Push(msg);
			_luaCallback.PCall();
			_luaCallback.EndPCall();
		}
	}
    #endregion

    #region demi
    public static bool IosUseWechatAliPay()
    {
        //#if UNITY_EDITOR
        //        return true;
        //#endif
        if (GameSetting.Platform == GameSetting.PlatformType.IOS && GameSetting.Channel == AgencyPlatform.Channel_demi
    && GameSetting.SubChannel == AgencyPlatform.Channel_demi && openSwitchPay)
        {
            return isSupportThirdPay;
        }
        else
        {
            return false;
        }
    }

    public static bool SupportInAppPurchase()
    {
        if (IosUseWechatAliPay())
            return false;

        if (GameSetting.Platform == GameSetting.PlatformType.IOS && GameSetting.Channel == AgencyPlatform.Channel_demi
            && GameSetting.SubChannel == AgencyPlatform.Channel_demi)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    //    hash.Add("payWay", payWay);//支付渠道(alipay/wechat/appstore)
    //    hash.Add("appId", appId);//服务器分配的游戏ID
    //    hash.Add("sid", sid);//SDK帐号登录会话ID
    //    hash.Add("appOrderId", appOrderId);//应用订单号
    //    hash.Add("serverId", serverId);//服务器ID
    //    hash.Add("playerId", playerId);//游戏角色标识
    //    hash.Add("deliverUrl", deliverUrl);//游戏回调url(通知发货)
    //    hash.Add("customInfo", customInfo);//游戏回调信息(透传)
    //    hash.Add("payAmount", payAmount);//支付金额(元)
    public void ChargeByOrderJsonDto(
        string productId, 
        int quantity, 
        string sid, 
        string orderId,
        string  serverId, 
        string playerId, 
        string payAmount, 
        string extraString,
        LuaFunction cb = null)
    {
        GameDebug.Log("AAAAAAAAAAAAAAAA" + orderId + " extraString:" + extraString);
        if (!string.IsNullOrEmpty(orderId))
		{
			JsonData jsondata = JsonMapper.ToObject(extraString);
			string callbackurl = (string)jsondata["demiPayCallbackURL"];
            string account = (string)jsondata["account"];
            string customTitle = (string)jsondata["customTitle"];
			string str_sdk = (string)GameSetting.DEMI_SDK_CODE_PAY;
            string ad_appid = (string)jsondata["ad_app_id"];
            string ad_activity_id = (string)jsondata["active_id"];
            string ad_system_id = (string)jsondata["system_id"];
            string ad_role_name = (string)jsondata["role_name"];
            GameDebug.Log("BBBBBBBBBBBBBBB orderId:" + orderId + " account:" + account + " callbackurl:" + callbackurl + " customTitle:" + customTitle + " ad_appid:" + ad_appid + " ad_activity_id:" + ad_activity_id + " ad_system_id:" + ad_system_id + " ad_role_name:" + ad_role_name);

            OrderCustomInfo _curOrderCustomInfo = new OrderCustomInfo();
            _curOrderCustomInfo.account = account;
            _curOrderCustomInfo.ad_app_id = ad_appid;
            _curOrderCustomInfo.active_id = ad_activity_id;
            _curOrderCustomInfo.system_id = ad_system_id;
            _curOrderCustomInfo.role_name = ad_role_name;
            string orderCustomInfoJson = JsonMapper.ToJson(_curOrderCustomInfo);
            GameDebuger.Log("orderCustomInfoJson:" + orderCustomInfoJson);


			//	P参数字符串拼接
            string p = "_default_";
            //	判断渠道
#if (UNITY_EDITOR || UNITY_STANDALONE)
            p = GameSetting.Channel;
#elif UNITY_ANDROID
			string subChannelId = SPSDK.GetSubChannelId();
			if (!string.IsNullOrEmpty(subChannelId)) {
				p = subChannelId;
			}
			if (!string.IsNullOrEmpty(SPSDK.ChannelAreaFlag)) {
				p += "_" + SPSDK.ChannelAreaFlag;
			}
#elif UNITY_IPHONE
			string subChannel = SPSDK.GetSubChannelId();
			if (!string.IsNullOrEmpty(subChannel)) {
				p = subChannel;
			}
			p += "_ios";
			if (!string.IsNullOrEmpty(SPSDK.ChannelAreaFlag)) {
				p += "_" + SPSDK.ChannelAreaFlag;
			}
#endif


            if (IosUseWechatAliPay())
            {
				GameDebug.Log("CCCCCCCCCCCCCC" + orderId + " | " + callbackurl);
                SdkLoginMessage.Instance.OpenPayView((code) =>
                {
                    if (code == 0)
                    {
                        //支付取消
                        if (_onPayCallBack != null)
                        {
                            _onPayCallBack(false);
                            _onPayCallBack = null;
                        }
                        return;
                    }

                    string payWay = code == 1 ? "AliPayH5" : "wechatH5";
                    if (payWay == "AliPayH5")
                    {
                        string url = ServiceProviderManager.GetDemiH5OrderUrl(
                            payWay,
                            GameSetting.APP_ID.ToString(),
                            sid,
                            orderId,
                            serverId,
                            playerId,
							callbackurl,
                            orderCustomInfoJson,
                            payAmount);
                        GameDebuger.Log(url);
                        GameDebuger.Log("AliPayH5 SPSdkManager.Instance.DoIosWechatAliPay payWay:" + payWay);
                        SPSdkManager.Instance.DoIosWechatAliPay(payWay, url, OnPayResult);
                    }
                    else
                    {
                        GameDebuger.Log("wechatH5 ServiceProviderManager.RequestDemiOrderId payWay:" + payWay);
                        ServiceProviderManager.RequestDemiOrderId(
                        payWay,
                        GameSetting.APP_ID.ToString(),
                        sid,
                        orderId,
                        serverId,
                        playerId,
                        callbackurl,
                        orderCustomInfoJson,
                        payAmount,
                        delegate (string jsonStr)
                        {
                            var dto = JsHelper.ToObject<DemiOrderJsonDto>(jsonStr);
                            GameDebuger.Log("dto.code:" + dto.code);
                            if (dto.code == 0 && dto.item != null)
                            {
                                GameDebuger.Log(dto.item);
                                GameDebuger.Log("wechatH5 SPSdkManager.Instance.DoIosWechatAliPay payWay:" + payWay);
                                SPSdkManager.Instance.DoIosWechatAliPay(payWay, jsonStr, OnPayResult);
                            }
                            else
                            {
                                GameDebuger.Log(dto.msg);

                                //xxj begin
                                //TipManager.AddTip(dto.msg);
                                //xxj end

                                LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.tip");
                                func.Call(dto.msg);
                                func.Dispose();

                                RequestLoadingTip.Reset();

                                if (_onPayCallBack != null)
                                {
                                    _onPayCallBack(false);
                                    _onPayCallBack = null;
                                }
                            }
                        });
                    }
                });
            }
            else if (SupportInAppPurchase())
            {
                GameDebug.Log("SSSSSSSSSSSSSSSSSSSSSS:" + orderId);

                ServiceProviderManager.RequestDemiOrderId(
                    "appstore",
                    GameSetting.APP_ID.ToString(),
                    sid,
                    orderId,
                    serverId,
                    playerId,
                    callbackurl,
                    orderCustomInfoJson,
                    payAmount,
                    delegate (DemiOrderJsonDto dto)
                    {
                        GameDebuger.Log("dto.code:" + dto.code);
                        if (dto.code == 0 && dto.item != null)
                        {
                            ChargeByIOSInAppPurchase(productId, quantity, dto.item.orderId, cb);
                        }
                        else
                        {
                            GameDebuger.Log("error:" + dto.msg);

                            //xxj begin
                            //TipManager.AddTip(dto.msg);
                            //xxj end

                            LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.tip");
                            func.Call(dto.msg);
                            func.Dispose();

                            RequestLoadingTip.Reset();

                            if (_onPayCallBack != null)
                            {
                                _onPayCallBack(false);
                                _onPayCallBack = null;
                            }
                        }
                    });

                //ChargeByIOSInAppPurchase(productId, quantity, orderId, cb);
            }
            else
            {
                GameDebug.Log("1111111111111111" + orderId + " GameSetting.IsOriginWinPlatform:" + GameSetting.IsOriginWinPlatform);
                if (GameSetting.IsOriginWinPlatform)
                {
                    //ProxyQRCodeModule.OpenQRCodePayView(itemDto, quantity, orderDto);
                }
                else
                {
					OrderCustomInfoAndroid orderCustomInfoAndroid = new OrderCustomInfoAndroid();
					orderCustomInfoAndroid.demiPayCallbackURL = callbackurl;
					orderCustomInfoAndroid.account = account;
					orderCustomInfoAndroid.yesdkOrderId = "";
					orderCustomInfoAndroid.gameOrderExtend = "";
					orderCustomInfoAndroid.gameOrderDesc = "";
					orderCustomInfoAndroid.productExtend = "";
					orderCustomInfoAndroid.paymentTile = customTitle;
					orderCustomInfoAndroid.sdk = str_sdk;
					orderCustomInfoAndroid.appKey = TrackingIOHelper.appID;
					orderCustomInfoAndroid.campaignid = p;
					orderCustomInfoAndroid.useDemiReyun = true;
					orderCustomInfoAndroid.ad_app_id = ad_appid;
					orderCustomInfoAndroid.active_id = ad_activity_id;
					orderCustomInfoAndroid.system_id = ad_system_id;
					orderCustomInfoAndroid.role_name = ad_role_name;
					string orderCustomInfoAndroidJson = JsonMapper.ToJson(orderCustomInfoAndroid);
					GameDebuger.Log("orderCustomInfoAndroidJson:" + orderCustomInfoAndroidJson);

                    DoGamePay(productId,
                              quantity,
                              sid,
                              orderId,
                              serverId,
                              playerId,
                              payAmount,
                              orderCustomInfoAndroidJson
                   );
                }
            }
        }
        else
        {
            //xxj begin
            //if (orderDto != null)
            //{
            //    GameDebuger.Log(orderDto.msg);
            //    TipManager.AddTip(orderDto.msg);  
            //}
            //xxj end

            RequestLoadingTip.Reset();

            if (_onPayCallBack != null)
            {
                _onPayCallBack(false);
                _onPayCallBack = null;
            }
        }

    }

    private void DoGamePay(
        string productId,
        int quantity,
        string sid,
        string orderId,
        string serverId,
        string playerId,
        string payAmount,
        string extraString)
    {
        Dictionary<string, string> dics = new Dictionary<string, string>();
        dics.Add("appOrderId", orderId);
        dics.Add("productId", productId);
        dics.Add("productName", GameSetting.PayProductName);
        dics.Add("productDes", GameSetting.PayProductDesc);
        dics.Add("gainGold", "0");
        dics.Add("productPrice", payAmount);
        dics.Add("productCount", quantity.ToString());
        //仅用于非demi融合SDK渠道,如手盟。demi融合SDK渠道使用extraJson字段里的链接
        //hash.Add("payNotifyUrl", GetPayNotifyUrl());
        dics.Add("serverId", serverId);

        //xxj begin
        //JsonData extraData = orderDto.extra;
        //JsonData extraData = null;
        //if (extraData == null)
        //{
        //    extraData = new JsonData();
        //}
        //xxj end

        //xxj begin
        //string extraJson = JsHelper.ToJson(extraData);
        //xxj end

        //GameDebuger.Log("extraString:" + extraString);
        //string extraStringUTF8 = WWW.EscapeURL(extraString, System.Text.Encoding.UTF8);
        //GameDebuger.Log("extraStringUTF8:" + extraStringUTF8);

        ////各个渠道的扩展字段，json格式，不解析直接传递给sdk处理
        dics.Add("extraJson", extraString);
        //xxj end
        dics.Add("appId", GameSetting.APP_ID.ToString());
        dics.Add("sid", sid);
        dics.Add("playerId", playerId);
        dics.Add("balance", "0");

        //元宝余额
        //xxj begin
        //if (ModelManager.Player.GetWealth() == null)
        //{
        //    dics.Add("balance", "0");
        //}
        //else
        //{
        //    dics.Add("balance", ModelManager.Player.GetWealth().ingot.ToString());
        //}
        //xxj end

        JsonData jsondata = JsonMapper.ToObject(extraString);
        string callbackurl = (string)jsondata["demiPayCallbackURL"];
        string account = (string)jsondata["account"];
        string ad_appid = (string)jsondata["ad_app_id"];
        string ad_activity_id = (string)jsondata["active_id"];
        string ad_system_id = (string)jsondata["system_id"];
        string ad_role_name = (string)jsondata["role_name"];

       
        dics.Add("appKey", TrackingIOHelper.appID);
        dics.Add("returnUrl", callbackurl);
        //dics.Add("imei", PlatformAPI.GetDeviceId());
        dics.Add("deliverUrl", "");

        OrderCustomInfo _curOrderCustomInfo = new OrderCustomInfo();
        _curOrderCustomInfo.account = account;
        _curOrderCustomInfo.ad_app_id = ad_appid;
        _curOrderCustomInfo.active_id = ad_activity_id;
        _curOrderCustomInfo.system_id = ad_system_id;
        _curOrderCustomInfo.role_name = ad_role_name;
        string orderCustomInfoJson = JsonMapper.ToJson(_curOrderCustomInfo);
        GameDebuger.Log("orderCustomInfoJson:" + orderCustomInfoJson);
        string orderCustomInfoJsonUTF8 = WWW.EscapeURL(orderCustomInfoJson, System.Text.Encoding.UTF8);
        GameDebuger.Log("orderCustomInfoJsonUTF8:" + orderCustomInfoJsonUTF8);
        dics.Add("payCustomInfo", orderCustomInfoJsonUTF8);
        //dics.Add("payCustomInfo", orderCustomInfoJson);

        //dics.Add("campaignid", "_default_");
        //dics.Add("idfa.idfa", IosAPI.GetAdId());
        //dics.Add("idfv.idfv", IosAPI.GetIdfv());

  
        string payJson = JsHelper.ToJson(dics);
        GameDebuger.Log("payJson=" + payJson);
        DoPay(payJson);
    }

    private void DoPay(string payJson)
    {
        SPSdkManager.Instance.DoPay(payJson, OnPayResult);
    }

    private void OnPayResult(bool success)
    {
        if (success)
        {
            //xxj begin
            //TipManager.AddTip("支付完成，如充值成功请等待到账");
            //xxj end

            LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.tip");
            func.Call("支付完成，如充值成功请等待到账");
            func.Dispose();
        }

        RequestLoadingTip.Reset();

        if (_onPayCallBack != null)
        {
            _onPayCallBack(success);
            _onPayCallBack = null;
        }
    }

    public string GetGameSettingDemiSdkServer()
    {
        return GameSetting.DEMISDK_SERVER;
    }
    #endregion demi
}
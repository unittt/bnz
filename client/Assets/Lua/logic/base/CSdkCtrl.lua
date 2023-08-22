local CSdkCtrl = class("CSdkCtrl", CCtrlBase)

CSdkCtrl.SubmitType = {
	Login = 0,
	Create = 1,
	Upgrade = 2,
	exit = 3
}

function CSdkCtrl.ctor(self)
	CCtrlBase.ctor(self)
	
	self.m_SdkMgr = C_api.SPSDK
	self.m_CallbackDic = {
		["init"] = callback(self, "OnInitCallabck");
		["login"] = callback(self, "OnLoginCallback");
		["logout"] = callback(self, "OnLogoutCallback");
		["noExiterProvide"] = callback(self, "OnNoExiterProvideCallback");
		["exit"] = callback(self, "OnExitCallback");
		["pay"] = callback(self, "OnPayCallback");
		["error"] = callback(self, "OnErrorCallback");
		["switchAccount"] = callback(self, "OnSwitchAccountCallback");
		["XGRegisterResult"] = callback(self, "OnXGRegisterResult");
		["XGRegisterWithAccountResult"] = callback(self, "OnXGRegisterWithAccountResult");
		["LocationResult"] = callback(self, "OnLocationResult");
		["login2Show"] = callback(self, "OnLogin2ShowCallback");
		["demiFirstRun"] = callback(self, "OnDemiFirstRun"); 				--德米 
		["demiRegisterResult"] = callback(self, "OnDemiRegisterResult"); 	--德米
	}

	self.m_VerifyPhoneUid = nil
	self.m_VerifyPhoneToken = nil
	self.m_ChannelId = self:GetChannelId()
	self.m_SubChannelId = self:GetSubChannelId()
	self.m_ChannelAreaFlag = nil
	self.m_SdkInit = false
	self.m_DemiChannelID = 0
	self.m_DemiChannelAreaList = {}
	self.m_DemiChannelCallback = nil
	self.m_isGuest = false
	self.m_IsInitXG = false --信鸽SDK的初始化状态记录
	self.m_IsInitAMap = false
	self.m_IsRegisterXG = false

	self:InitSdkCallback()
end

function CSdkCtrl.InitSdkCallback(self)
	self.m_SdkMgr.SetLuaCallback(callback(self, "OnSdkCallback"))
end

function CSdkCtrl.GetChannelAreaFlag(self)
	if not self.m_ChannelAreaFlag then
		self.m_ChannelAreaFlag = self.m_SdkMgr.ChannelAreaFlag
	end
	return self.m_ChannelAreaFlag
end

-------------------sdk操作----------------------------
function CSdkCtrl.Setup(self)
	printc("CSdkCtrl, Setup")
	self.m_SdkMgr.Setup()
end

function CSdkCtrl.SetShenhe(self)
	local isshenhe = string.find(g_UrlRootCtrl.m_CSRootUrl, "shenhe")
	if isshenhe then
		self.m_SdkMgr.SetShenhe(true)
	else
		self.m_SdkMgr.SetShenhe(false)
	end
end

function CSdkCtrl.Init(self)
	-- 德米不作为第三方SDK，不走SPSDK
	if g_GameDataCtrl:GetChannel() == "demi" then
	else
		if self:IsIOSNativePay() then
			self:SetShenhe()
		end
		self.m_SdkMgr.Init()
	end
end

function CSdkCtrl.Login(self)
	if g_GameDataCtrl:GetChannel() == "demi" then
		C_api.SPSdkManager.Instance:DoLogin()
	else
		self.m_SdkMgr.Login()
	end
end

function CSdkCtrl.Bind(self)
	self.m_SdkMgr.Bind()
end

function CSdkCtrl.Logout(self)
	if g_GameDataCtrl:GetChannel() == "demi" then
		C_api.SPSdkManager.Instance:DoLogout()
	else
		self.m_SdkMgr.Logout()
	end
end

function CSdkCtrl.DoExiter(self)
	self.m_SdkMgr.DoExiter()
end

function CSdkCtrl.Exit(self)
	self.m_SdkMgr.Exit()
end

function CSdkCtrl.UpdaeUserInfo(self)
	self.m_SdkMgr.UpdaeUserInfo()
end

function CSdkCtrl.SubmitRoleData(self, iSubmitType)
	if g_LoginPhoneCtrl.m_IsPC or g_LoginPhoneCtrl.m_IsQrPC then
		return
	end
	local roleId = g_AttrCtrl.pid
	local roleName = g_AttrCtrl.name
	local roleLevel = g_AttrCtrl.grade
	local roleCTime = g_AttrCtrl.create_time
	local zoneId = g_ServerPhoneCtrl:GetCurServerData().id
	local zoneName = g_ServerPhoneCtrl:GetCurServerName()
	local extendMsg = ""
	if iSubmitType == CSdkCtrl.SubmitType.Login then
		extendMsg = "report"
	elseif iSubmitType == CSdkCtrl.SubmitType.Create then
		extendMsg = "create"
	elseif iSubmitType == CSdkCtrl.SubmitType.Upgrade then
		extendMsg = "change" 
	end

	local dRole = {submittype = iSubmitType, roleId = roleId, roleName = roleName, roleLevel = roleLevel, zoneId = zoneId, zoneName = zoneName, extendMsg = extendMsg, roleCTime = roleCTime}
	C_api.SPSdkManager.Instance:SubmitRoleData(cjson.encode(dRole))
end

function CSdkCtrl.SubmitGoldInfo(self, changeGold)
	if changeGold == 0 then return end

	if g_GameDataCtrl:GetChannel() == "demi" then
		return
	else
		if Utils.IsAndroid() or Utils.IsIOS() then
			local goldinfo = {
				amount = Mathf.Abs(changeGold),
				playerId = g_AttrCtrl.pid,
				playerName = g_AttrCtrl.name,
				playerLevel = g_AttrCtrl.grade,
				serverId = g_ServerPhoneCtrl:GetCurServerData().id,
				changeTime = g_TimeCtrl:GetTimeS(),
			}
			local jsonInfo = cjson.encode(goldinfo)
			if changeGold > 0 then
			    self:GainGameCoin(jsonInfo)
		    else
		        self:ConsumeGameCoin(jsonInfo)
		    end
		end
	end
end

function CSdkCtrl.GainGameCoin(self, json)
	self.m_SdkMgr.GainGameCoin(json)
end

function CSdkCtrl.ConsumeGameCoin(self, json)
	self.m_SdkMgr.ConsumeGameCoin(json)
end

function CSdkCtrl.GetChannelId(self)
	if not self.m_ChannelId then
		self.m_ChannelId = C_api.SPSdkManager.Instance:GetChannel()
	end
	return self.m_ChannelId
end

function CSdkCtrl.GetSubChannelId(self)
	if not self.m_SubChannelId then
		self.m_SubChannelId = C_api.SPSdkManager.Instance:GetSubChannel()
	end
	return self.m_SubChannelId
end

function CSdkCtrl.IsSupportUserCenter(self)
	return self.m_SdkMgr.IsSupportUserCenter()
end

function CSdkCtrl.EnterUserCenter(self)
	self.m_SdkMgr.EnterUserCenter()
end

function CSdkCtrl.IsSupportBBS(self)
	return self.m_SdkMgr.IsSupportBBS()
end

function CSdkCtrl.EnterSdkBBS(self)
	self.m_SdkMgr.EnterSdkBBS()
end

function CSdkCtrl.IsSupportShowOrHideToolbar(self)
	return self.m_SdkMgr.IsSupportShowOrHideToolbar()
end

function CSdkCtrl.ShowFloatToolBar(self)
	self.m_SdkMgr.ShowFloatToolBar()
end

function CSdkCtrl.HideFloatToolBar(self)
	self.m_SdkMgr.HideFloatToolBar()
end

function CSdkCtrl.DoPay(self, dPay)
	if g_LoginPhoneCtrl.m_IsPC or g_LoginPhoneCtrl.m_IsQrPC then
		return
	end
	if Utils.IsAndroid() then
		self.m_SdkMgr.DoPay(cjson.encode(dPay))
	elseif Utils.IsIOS() then
		if self:IsIOSNativePay() then
			C_api.PayManager.Instance:ChargeByIOSInAppPurchase(dPay.productId, 1, dPay.appOrderId, function (success)
				printc("IOS充值回调状态", dPay.productId, success)
				g_PayCtrl:UnLockByPayID(dPay.productId)
			end)
		else
			self.m_SdkMgr.DoPay(cjson.encode(dPay))
		end
	end
end

function CSdkCtrl.SwitchAccount(self)
	self.m_SdkMgr.SwitchAccount()
end

---------------------------- AMap ------------------------------------
-- setting: json, 定位设置，不设置则使用默认
--[[
     * 可选择设置
     * gpsFirst: bool
     * mode: string ( Hight_Accuracy | Device_Sensors | Battery_Saving)
     * timeOut: default 30000
     * interval: default 2000
     * needAddress: bool
     * killProcess: bool
     * once: bool
     * wifiScan: bool
     * cacheEnable: bool
     * onceLatest: bool
     * sensorEnable: bool
     */
]]--
function CSdkCtrl.StartLocation(self, setting)
	if not self.m_IsInitAMap then
		C_api.AMapLocationSdk.Init()
		self.m_IsInitAMap = true
	end
	if setting then
		C_api.AMapLocationSdk.SetLocationOption(setting)
	end
	C_api.AMapLocationSdk.StartLocation()
end

function CSdkCtrl.StopLocation(self)
	C_api.AMapLocationSdk.StopLocation()
	if self.m_IsInitAMap then
		C_api.AMapLocationSdk.DestroyLocation()
		self.m_IsInitAMap = false
	end
end

-------------------------callback-----------------------------------------
function CSdkCtrl.OnSdkCallback(self, sJson)
	local dInfo = decodejson(sJson)
	printc("============ OnSdkCallback form jar to lau ============", type(dInfo.code), sJson)
	local cb = self.m_CallbackDic[dInfo.type]
	if cb then
		cb(tonumber(dInfo.code), dInfo.data)
	end
end

function CSdkCtrl.OnInitCallabck(self, iCode, dData)
	local success = iCode == 0
	if not success then
		local windowConfirmInfo = {
			msg	= "游戏初始化失败，请重新启动游戏",
			thirdCallback = function() Utils.QuitGame() end,
			style = CWindowNetComfirmView.Style.Single,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		return
	end

	if Utils.IsIOS() then
		self:Login()
		if self:IsIOSNativePay() then
			self:SetIOSNativePayProductKeys()
		end
	end
	self:OnEvent(define.Sdk.Event.Init, success)
end

function CSdkCtrl.OnLoginCallback(self, iCode, dData)
	printc("CSdkCtrl.OnLoginCallback iCode:", iCode, " dData:", dData, " self.m_DemiChannelID:", self.m_DemiChannelID)
	local success = (iCode == 0) or (iCode == 1)

	local function cb()
		self:DoLoginCallback(iCode, dData)
	end
	self.m_DemiChannelCallback = nil
	if self.m_DemiChannelID == 0 then
		self.m_DemiChannelCallback = cb
		return
	end
	cb()
end

function CSdkCtrl.DoLoginCallback(self, iCode, dData)
	self.m_VerifyPhoneUid = nil
	self.m_VerifyPhoneToken = nil
	self.m_isGuest = iCode == 1
	table.print(dData)
	printc("CSdkCtrl.DoLoginCallback iCode:", iCode, " dData:", dData)
	if iCode == 0 then
		local dUserInfo = type(dData) == "table" and dData or decodejson(dData)
		self.m_VerifyPhoneUid = tostring(dUserInfo.uid)
		self.m_VerifyPhoneToken = tostring(dUserInfo.sessionId)
		table.print(dUserInfo, "CSdkCtrl.OnLoginCallback iCode 0 dData")
		printc("CSdkCtrl.OnLoginCallback iCode 0 m_VerifyPhoneUid:", self.m_VerifyPhoneUid)
		printc("CSdkCtrl.OnLoginCallback iCode 0 m_VerifyPhoneToken:", self.m_VerifyPhoneToken)
		if Utils.IsAndroid() then
			
		elseif Utils.IsIOS() then
			-- self.m_VerifyPhoneToken = dData
			self.m_VerifyPhoneUid = ""
		end

		local platformID = g_LoginPhoneCtrl:GetPlatform()
		local needData = {
			token = self.m_VerifyPhoneToken,
			demi_channel = self.m_DemiChannelID,
			device_id = Utils.GetDeviceUID(),
			cps = "",
			account = self.m_VerifyPhoneUid,
			platform = platformID,
			notice_ver = g_LoginPhoneCtrl:GetLocalUpdateNoticeVersion(),
			area = self.m_DemiChannelAreaList,
			ckey = g_GameDataCtrl:GetGameDomainType(),
			cname = g_UrlRootCtrl.m_Pname,
			startver = g_UrlRootCtrl.m_AppVer,
		}
		table.print(needData, "请求服务器列表，需要发送的数据 iCode 0")
		g_ServerPhoneCtrl:PostServerList(needData)
		g_ServerPhoneCtrl:SetServerRequestGSTime(300)
		g_UploadDataCtrl:SetDotUpload("12")
		self:OnEvent(define.Sdk.Event.LoginSuccess)	
	elseif iCode == 1 then
		local dUserInfo = decodejson(dData)
		self.m_VerifyPhoneUid = tostring(dUserInfo.uid)
		self.m_VerifyPhoneToken = tostring(dUserInfo.sessionId)
		table.print(dUserInfo, "CSdkCtrl.OnLoginCallback iCode 1 dData")
		printc("CSdkCtrl.OnLoginCallback iCode 1 m_VerifyPhoneUid:", self.m_VerifyPhoneUid)
		printc("CSdkCtrl.OnLoginCallback iCode 1 m_VerifyPhoneToken:", self.m_VerifyPhoneToken)
		
		local platformID = g_LoginPhoneCtrl:GetPlatform()
		local needData = {
			token = self.m_VerifyPhoneToken,
			demi_channel = self.m_DemiChannelID,
			device_id = Utils.GetDeviceUID(),
			cps = "",
			account = self.m_VerifyPhoneUid,
			platform = platformID,
			notice_ver = g_LoginPhoneCtrl:GetLocalUpdateNoticeVersion(),
			area = self.m_DemiChannelAreaList,
			ckey = g_GameDataCtrl:GetGameDomainType(),
			cname = g_UrlRootCtrl.m_Pname,
			startver = g_UrlRootCtrl.m_AppVer,
		}
		table.print(needData, "请求服务器列表，需要发送的数据 iCode 1")
		g_ServerPhoneCtrl:PostServerList(needData)
		g_ServerPhoneCtrl:SetServerRequestGSTime(300)
		g_UploadDataCtrl:SetDotUpload("12")
		self:OnEvent(define.Sdk.Event.LoginSuccess)
	elseif iCode == 2 then
		self:OnEvent(define.Sdk.Event.LoginCancel)
	else
		self:OnEvent(define.Sdk.Event.LoginFail)
	end
end

function CSdkCtrl.OnLogoutCallback(self, iCode, dData)
	local success = iCode == 0
	if success then
		self.m_VerifyPhoneUid = nil
		self.m_VerifyPhoneToken = nil
		self.m_ChannelId = nil
		g_LoginPhoneCtrl:ResetAllData()
		CLoginPhoneView:ShowView(function (oView)
            oView:RefreshUI()
        end)
	end
	self:OnEvent(define.Sdk.Event.Logout, success)
end

function CSdkCtrl.OnLogin2ShowCallback(self)
	printc("CSdkCtrl.OnLogin2ShowCallback m_IsQrPC:", g_LoginPhoneCtrl.m_IsQrPC, " m_DemiIsQr:", g_QRCtrl.m_DemiIsQr)
	if g_LoginPhoneCtrl.m_IsQrPC then
		g_QRCtrl.m_DemiIsQr = true
		CQRCodeLoginView:CloseView()
		CQRCodeLoginView:ShowView()
	end
end

function CSdkCtrl.OnExitCallback(self, iCode, dData)
	local bIsSuccess = iCode == 0
	self:OnEvent(define.Sdk.Event.Exit, bIsSuccess)
end

function CSdkCtrl.OnNoExiterProvideCallback(self, iCode, dData)
	printc("CSdkCtrl.OnNoExiterProvideCallback")
	self:OnEvent(define.Sdk.Event.NoExiterProvide)
end

function CSdkCtrl.OnPayCallback(self, iCode, dData)
	printc("CSdkCtrl.OnPayCallback==========>result:", iCode)
	local bIsSuccess = iCode == 0
	self:OnEvent(define.Sdk.Event.Pay, bIsSuccess)
end

function CSdkCtrl.OnErrorCallback(self, iCode, dData)
	printerror(string.format("CSdkCtrl.OnErrorCallback==========>code = %d, error = %s", iCode, dData))
end

function CSdkCtrl.OnSwitchAccountCallback(self, iCode, dData)
	printc("CSdkCtrl.OnSwitchAccountCallback==========>result:", iCode, dData)
end

function CSdkCtrl.OnXGRegisterResult(self, iCode, dData)
	printc("CSdkCtrl.OnXGRegisterResult==========>result:", iCode, dData)
	self.m_IsInitXG = dData == 0
	printc(self.m_IsInitXG)
end

function CSdkCtrl.OnXGRegisterWithAccountResult(self, iCode, dData)
	printc("CSdkCtrl.OnXGRegisterWithAccountResult==========>result:", iCode, dData)
	self.m_IsRegisterXG = tonumber(dData) == 0
end

function CSdkCtrl.OnDemiFirstRun(self)
	printc("CSdkCtrl.OnDemiFirstRun...")

	--广告埋点 1:激活
	local str_ad_app_id = "1001"
	local str_ad_activity_id = "10000"
	local str_ad_system_id = 1
	local str_idfa = ""
	local str_imei = ""

	if Utils.IsIOS() then
		str_ad_app_id = C_api.SPSdkManager.Instance:GetAdAppIdForIOS()
		str_ad_activity_id = C_api.SPSdkManager.Instance:GetAdActivityIdForIOS()
		str_ad_system_id = 2
		str_idfa = C_api.PlatformAPI.GetDeviceId()
	else
		str_ad_app_id = Utils.GetAndroidMeta("demi_ad_appId")
		str_ad_activity_id = Utils.GetAndroidMeta("demi_ad_activity_id")
		str_ad_system_id = 1
		str_imei = C_api.PlatformAPI.GetDeviceId()
	end


	local ad_url = define.DemiAD.Url_dev
	local csroot = g_GameDataCtrl:GetCSRoot()
	if string.find(csroot, "csh7d") then
		ad_url = define.DemiAD.Url_release
	else
		ad_url = define.DemiAD.Url_dev
	end

	printc("ad_app_id:", str_ad_app_id, " ad_activity_id:", str_ad_activity_id, " ad_system_id:", str_ad_system_id, " idfa:", str_idfa, " imei:", str_imei)

	local advContent = string.format("do=%s&app_id=%s&activity_id=%s&system_id=%d&mac=%s&idfa=%s&imei=%s", "active", str_ad_app_id, str_ad_activity_id, str_ad_system_id, Utils.GetMac(), str_idfa, str_imei)
	printc("advContent:", advContent)
	local advContent = IOTools.EncodeString(advContent)
	local advSign = Utils.MD5HashString(advContent.."&"..define.DemiAD.Key)
	local advData = "data="..advContent.."&sign="..advSign
	g_HttpCtrl:PostHttp(ad_url, "data", advContent, "sign", advSign)
end

function CSdkCtrl.OnAdvertisingFirstRunCB(self, data)
	printc("CSdkCtrl.OnAdvertisingFirstRunCB data:", data)
	table.print(data, "CSdkCtrl.OnAdvertisingFirstRunCB")
	local ret = decodejson(data)
	if ret.code ~= nil and ret.code == 0 then
		printc("埋点广告激活 code:", ret.code, " message:", ret.message)
	else
		if ret.code ~= nil then
			printc("埋点广告激活 code:", ret.code, " message:", ret.message)
		else
			printc("埋点广告激活 result:error")
		end
	end 
end

function CSdkCtrl.OnDemiRegisterResult(self)
	printc("CSdkCtrl.OnDemiRegisterResult ok.")
end

function CSdkCtrl.OnAdvertisingRegisterCB(self, ret)
	local ret = decodejson(json)
	if ret.code ~= nil and ret.code == 0 then
		printc("埋点广告注册 code:", ret.code, " message:", ret.message)
	else
		if ret.code ~= nil then
			printc("埋点广告注册 code:", ret.code, " message:", ret.message)
		else
			printc("埋点广告注册 result:error")
		end
	end 
end

------------------------other-------------------------------
function CSdkCtrl.IsInitXG(self)
	return self.m_IsInitXG or self.m_IsRegisterXG
end

function CSdkCtrl.BeforInit(self)
	if g_LoginPhoneCtrl.m_IsPC then
		return
	end

	if g_LoginPhoneCtrl.m_IsQrPC and g_GameDataCtrl:GetChannel() == "shoumeng" then
		return
	end
	
	local appid = Utils.GetAppID()
	local appKey = self:GetChannelId()
	local p = g_UrlRootCtrl.m_Pname

	if g_GameDataCtrl:GetChannel() == "demi" then
		local demiSdkUILayer = tonumber(define.Depth.Panel.DemiSdk)
		printc("demiSdkUILayer:", demiSdkUILayer)
		C_api.SPSdkManager.Instance:Setup(demiSdkUILayer)  --
		C_api.SPSdkManager.Instance:Init()
		C_api.PayManager.Instance:SetupForDemi()

		if p == "demi" then
			--已经出去的第一个demi换皮包 这里不处理.
			printc("CSdkCtrl.BeforInit demi is old")
		else
			--切换支付
			C_api.PayManager.Instance.openSwitchPay = g_DemiCtrl:GetDemiPaySwitch()
			printc("C_api.PayManager.Instance.openSwitchPay:", C_api.PayManager.Instance.openSwitchPay)

			--热云appId的处理begin
			local trackingIOAppId = C_api.SPSdkManager.Instance:GetTrackingIOAppId()
			printc("trackingIOAppId:", trackingIOAppId)
			if trackingIOAppId == nil or trackingIOAppId == "" then
				--老的包，此处不配置或配置为空字符串"
			else
				C_api.SPSdkManager.Instance:ModifyTrackingIOHelperAppID(trackingIOAppId)
			end
			--热云appId的处理end
		end

		--TrackingIO setup
		C_api.SPSdkManager.Instance:TrackingioSetup()
		

		C_api.SPSdkManager.Instance:SetDemiSdkUseNew(true)
		C_api.SPSdkManager.Instance:SetDemiSdkCode("1")
		C_api.SPSdkManager.Instance:SetDemiSdkCodePay("0")
		
		if self:IsIOSNativePay() then
			self:SetIOSNativePayProductKeys()
		end
	end

	local purl = string.format(g_UrlRootCtrl.m_DemiPInfoUrl, appid, appKey, p)
	g_HttpCtrl:Get(purl, callback(self, "OnDemiPCallback"), {json_result=true})
end

function CSdkCtrl.OnDemiPCallback(self, success, result)
	print("CSdkCtrl.DemiP Result", success, result)
	table.print(result)
	if success then
		if result.code > 0 then
			printc("CSdkCtrl.OnDemiPCallback", result.msg)
			local strs = string.split(result.msg, ':')
			local windowConfirmInfo = {
				title = "渠道标识错误",
				msg = string.format("当前包渠道标识错误:%s", strs[3]),
				okCallback = function()
					self:BeforInit()
				end,
				okStr = "重新连接",
				cancelCallback = function ()
					Utils.QuitGame()
				end,
				cancelStr = "退出游戏",
				closeType = 3,
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
			return
		end

		if result.item.close then
			local msg = "渠道已关闭"
			if result.item.notice and string.len(result.item.notice) > 0 then
				msg = result.item.notice
			end
			local windowConfirmInfo = {
				msg	= msg,
				thirdCallback = function() Utils.QuitGame() end,
				style = CWindowNetComfirmView.Style.Single,
				pivot = enum.UIWidget.Pivot.Center,
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
			return
		end

		self.m_DemiChannelID = result.item.channelId
		self.m_DemiChannelAreaList = {}
		local areaStringList = string.split(result.item.area, ",")
		for _,v in ipairs(areaStringList) do
			table.insert(self.m_DemiChannelAreaList, tonumber(v))
		end
		if result.item.notice and string.len(result.item.notice) > 0 then
			local windowConfirmInfo = {
				title = "公告",
				msg = result.item.notice,
				thirdCallback = function()
					if self.m_DemiChannelCallback then
						self.m_DemiChannelCallback()
						self.m_DemiChannelCallback = nil
						return
					end
					self:Init()
				end,
				style = CWindowNetComfirmView.Style.Single,
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		else
			if self.m_DemiChannelCallback then
				self.m_DemiChannelCallback()
				self.m_DemiChannelCallback = nil
				return
			end
			self:Init()
		end
	end
end

function CSdkCtrl.OnLocationResult(self, iCode, dData)
	print("location result ------------ ", iCode)
	table.print(dData)
	if dData.error then
		print(dData.errorStr)
	else
		local sProvince = dData.province or ""
		local sCity = dData.city or ""
		print("location -------- ", sProvince, sCity)
		if string.len(sCity) > 0 then
			if sCity == sProvince then
				netplayer.C2GSSyncPosition(sProvince)
			else
				netplayer.C2GSSyncPosition(sProvince .. sCity)
			end
		end
	end
	self:StopLocation()
end

-- 注意这个接口在 晨之科 发行下直接 判定是否ios平台即可
-- 补充：修改实现后，现在demi也可用
function CSdkCtrl.IsIOSNativePay(self)
	if not Utils.IsPC() and Utils.IsIOS() then
		local subChannelId = self:GetSubChannelId()
		local isgulu = subChannelId == "gulu"

		local paySwitch = C_api.PayManager.Instance.openSwitchPay
		local isdemi = subChannelId == "demi" and not paySwitch
		printc("CSdkCtrl.IsIOSNativePay isgulu", isgulu, "paySwitch:", paySwitch, "isdemi:", isdemi)
		return isgulu or isdemi
	end
end

function CSdkCtrl.SetIOSNativePayProductKeys(self)
	-- IOS 	设置内购ID
	local payInfoDic = data.paydata.PAY
	local strs = ""
	for k,v in pairs(payInfoDic) do
		if k ~= "com.cilu.dhxx.giftbag_10" then
			local s = strs == "" and "" or ";"
			strs = strs .. s .. k .. "," .. v.value
		end
	end
	C_api.PayManager.Instance:Setup(strs)
	C_api.PayManager.Instance:ResetCallbackURL(g_UrlRootCtrl.m_DemiPayUrl)
end

function CSdkCtrl.Getsid(self)
	return self.m_VerifyPhoneToken
end

function CSdkCtrl.Getuid(self)
	return self.m_VerifyPhoneUid
end

return CSdkCtrl

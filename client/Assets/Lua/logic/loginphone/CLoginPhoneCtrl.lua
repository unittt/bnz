local CLoginPhoneCtrl = class("CLoginPhoneCtrl", CCtrlBase)

function CLoginPhoneCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_IsHasCG = false
	self.m_IsUseOld = false

	--纯粹的pc,即是否在编辑器下运行
	self.m_IsPC = true
	--可以扫码登录的pc
	self.m_IsQrPC = false

	self.m_IsUseBack = true
	self.m_RoleCreateScene = nil
	self.m_IsShowingActor = false
	self.m_IsFirstTime = true
	self.m_IsShowingRoleCreateScene = false
	self.m_IsRoleCreateEffectCache = false

	self.m_LoginInfo = {account=nil, pwd = nil, role_list={}} --登录成功数据
	self.m_ReconnectInfo = {} --重登数据
	self.m_VerifyInfo = {
		account = nil,
		pwd = nil,
		ispidlogin = false,
	} --验证数据
	self.m_Logined = false

	self.m_LoginPhoneInfo = {account=nil, role_list={}} --登录成功数据
	self.m_PhoneReconnectInfo = {}
	self.m_PhoneChooseInfo = {}

	self.m_ServerListData = {}
	self.m_UpdateNoticeData = {}
	self.m_LocalUpdateNoticeVersion = 0

	self.m_RecordLoginRolePid = nil
	self.m_RecordLoginRolePlatform = nil
	self.m_RecordConnectIp = nil

	self.m_RoleToken = nil

	self.m_IsReconnect = false
	-- 用于排队登陆数据
	self.m_SelectdSever = 0

	self.m_UsedNameCache = {}
end

function CLoginPhoneCtrl.InitCtrl(self)
	-- if Utils.IsPC() then
	-- 	if g_GameDataCtrl:IsQRPC() then
	-- 		self.m_IsPC = false
	-- 		self.m_IsQrPC = true
	-- 	end

	-- 	if g_GameDataCtrl:GetChannel() == "demi" then
	-- 		self.m_IsPC = false
	-- 	end
	-- end
end

function CLoginPhoneCtrl.Clear(self)
	self.m_RoleToken = nil
	self.m_IsReconnect = false
	-- 用于排队登陆数据
	self.m_SelectdSever = 0
	self.m_UsedNameCache = {}
end

-----------------登录协议相关--------------------

--1.连通服务器
function CLoginPhoneCtrl.OnServerHello(self)
	--检查导表数据更新
	local lFilePaths = IOTools.GetFilterFiles(IOTools.GetPersistentDataPath("/data"), function(s) return not string.find(s, "%.meta") end, false)
	local lFileVersiosns = {}
	for i, path in ipairs(lFilePaths) do
		local dFielVersion = {}
		dFielVersion.file_name = IOTools.GetFileName(path, true)
		local iVer = 0
		local sData = IOTools.LoadStringByLua(path, "rb", 4)
		if sData then
			iVer = IOTools.ReadNumber(sData, 4)
		end
		dFielVersion.version = iVer
		table.insert(lFileVersiosns, dFielVersion)
	end
	netlogin.C2GSQueryLogin(lFileVersiosns)
end

--1.1 导表数据更新完成
function CLoginPhoneCtrl.OnDataUpdateFinished(self)
	--处理跨服相关
	if next(g_KuafuCtrl.m_EnterKsData) then	
		local oData = g_KuafuCtrl.m_EnterKsData
		printc("连接跨服服务器成功，请求协议进入原本的角色", oData.pid, oData.token, oData.serverkey)
		netlogin.C2GSKSLoginRole(oData.pid, oData.token, oData.serverkey, oData.device, oData.platform, oData.mac, oData.app_ver, oData.imei, oData.os, oData.client_ver, oData.udid)
		g_KuafuCtrl.m_EnterKsData = {}
		return
	elseif next(g_KuafuCtrl.m_BackGsData) then	
		local oData = g_KuafuCtrl.m_BackGsData
		printc("从跨服返回，连接原本的服务器成功，请求协议进入原本的角色", oData.pid, oData.token)
		netlogin.C2GSBackLoginRole(oData.pid, oData.token, oData.device, oData.platform, oData.mac, oData.app_ver, oData.imei, oData.os, oData.client_ver, oData.udid)
		g_KuafuCtrl.m_BackGsData = {}
		return
	end

	--sdk登录用角色token重连
	if self.m_IsReconnect then
		self:PhoneReconnect()
		return
	end

	local _, v1, v2, v3 = C_api.Utils.GetResVersion()
	local version = string.format("%s.%s.%s",v1, v2, v3)
	if self.m_IsPC then
		if self.m_VerifyInfo.ispidlogin then
			netlogin.C2GSGMLoginPid(tonumber(self.m_VerifyInfo.account), Utils.GetDeviceModel(), self:GetPlatform(), Utils.GetMac(), gameconfig.Version.AppVer, "", UnityEngine.SystemInfo.operatingSystem, version, Utils.GetDeviceUID())
		else
			netlogin.C2GSLoginAccount(self.m_VerifyInfo.account, nil, Utils.GetDeviceModel(), self:GetPlatform(), Utils.GetMac(), gameconfig.Version.AppVer, "", UnityEngine.SystemInfo.operatingSystem, version, Utils.GetDeviceUID())
		end
	else
		printc("Utils GetDeviceModel"..Utils.GetDeviceModel())
		if not next(g_ServerPhoneCtrl.m_PostServerData) or not g_ServerPhoneCtrl.m_PostServerData.info.token then
			printc("CLoginPhoneCtrl.OnServerHello 没有中心服数据 用户信息发生错误")
			return
		end
		--不管是否重连
		--注意，这里发的token不是sdk的，是服务端发过来的
		--这里扫码pc端和手机端的设备名、平台、设备uid、都有可能改变
		netlogin.C2GSLoginAccount(nil, g_ServerPhoneCtrl.m_PostServerData.info.token, Utils.GetDeviceModel(), self:GetPlatform(), Utils.GetMac(), gameconfig.Version.AppVer, "", UnityEngine.SystemInfo.operatingSystem, version, Utils.GetDeviceUID())
	end
end

--2.账号密码验证成功
function CLoginPhoneCtrl.LoginAccountSuccess(self, account, lSimpleRole)
	if self.m_IsPC then
		self:ResetAllData(true)

		--重置缓存的数据
		self.m_LoginInfo = {account=nil, pwd = nil, role_list={}}

		self.m_LoginInfo["account"] = account

		if next(lSimpleRole) then
			self.m_LoginInfo["role_list"] = lSimpleRole
			self.m_RecordLoginRolePid = lSimpleRole[1].pid
			self.m_RecordLoginRolePlatform = self:GetPlatform()
			netlogin.C2GSLoginRole(lSimpleRole[1].pid, (g_KuafuCtrl.m_ConnectKsFail and {1} or {nil})[1] )
			g_KuafuCtrl.m_ConnectKsFail = false
			
			-- 发送打点Log(选择历史角色)
			g_LogCtrl:SendLog(6)
		end

		if self:IsNeedCreateRole() then
			if not g_RoleCreateScene.m_RoleCreateScene then
				g_RoleCreateScene:OnCreateScene()
			end
		end
	else
		--重置缓存的数据
		self.m_LoginPhoneInfo = {account=nil, role_list={}}

		self.m_LoginPhoneInfo["account"] = account

		if next(lSimpleRole) then
			self.m_LoginPhoneInfo["role_list"] = lSimpleRole
		end

		if self.m_PhoneChooseInfo.role.pid == -1 then
			--暂时屏蔽
			-- if table.count(lSimpleRole) >= 3 then
			-- 	g_NotifyCtrl:FloatMsg("您在同一服务器拥有的角色不能超过3个哦")
			-- 	return
			-- end
			self:ResetAllData(true)
			if not g_RoleCreateScene.m_RoleCreateScene then
				g_RoleCreateScene:OnCreateScene()
			end
		else
			self:ResetAllData(true)
			self.m_RecordLoginRolePid = self.m_PhoneChooseInfo.role.pid
			self.m_RecordLoginRolePlatform = self:GetPlatform()
			netlogin.C2GSLoginRole(self.m_PhoneChooseInfo.role.pid, (g_KuafuCtrl.m_ConnectKsFail and {1} or {nil})[1] )
			g_KuafuCtrl.m_ConnectKsFail = false

			-- 发送打点Log(选择历史角色)
			g_LogCtrl:SendLog(6)
		end
	end
end

function CLoginPhoneCtrl.C2GSCreateRole(self, iRoleType, sName, iSchoolID, oServerKey)
	netlogin.C2GSCreateRole(iRoleType, sName, iSchoolID, oServerKey)
end

--3.角色登录成功
function CLoginPhoneCtrl.LoginRoleSuccess(self, iRole)
	if self.m_IsPC then
		self.m_ReconnectInfo = {}
	else
		self.m_PhoneReconnectInfo = {}
	end
	self.m_Logined = true
	-- TODO:频繁点击请求登录有可能导致loginSuccess返回后仍请求登录，此时账号已清空，引bug，暂时屏蔽，以后加loadingview再恢复
	-- self.m_VerifyInfo = {}
	local list = {"COrgInfoView"}
	local cls = {}
	for k,v in pairs(list) do
		cls.classname = v	
		local view = g_ViewCtrl:GetView(cls)
		if view then
			printc("重登关闭界面")
			view:OnClose()
		end
	end
end

function CLoginPhoneCtrl.CreateRoleSuccess(self, account, tSimpleRole)
	local function createSuccess()
		if self.m_IsPC then
			if account == self.m_LoginInfo["account"] then
				table.insert(self.m_LoginInfo["role_list"], tSimpleRole)
			else
				self.m_LoginInfo["account"] = account
				self.m_LoginInfo["role_list"] = {tSimpleRole}
			end
			self.m_RecordLoginRolePid = tSimpleRole.pid
			self.m_RecordLoginRolePlatform = self:GetPlatform()
			netlogin.C2GSLoginRole(tSimpleRole.pid, (g_KuafuCtrl.m_ConnectKsFail and {1} or {nil})[1])
			g_KuafuCtrl.m_ConnectKsFail = false
		else
			if account == self.m_LoginPhoneInfo["account"] then
				table.insert(self.m_LoginPhoneInfo["role_list"], tSimpleRole)
			else
				self.m_LoginPhoneInfo["account"] = account
				self.m_LoginPhoneInfo["role_list"] = {tSimpleRole}
			end
			self.m_RecordLoginRolePid = tSimpleRole.pid
			self.m_RecordLoginRolePlatform = self:GetPlatform()
			netlogin.C2GSLoginRole(tSimpleRole.pid, (g_KuafuCtrl.m_ConnectKsFail and {1} or {nil})[1])
			g_KuafuCtrl.m_ConnectKsFail = false
		end
	end

	g_RoleCreateScene:OnDestroyScene()
	createSuccess()

	g_UploadDataCtrl:CreateRoleUpload({click = "RoleSuccess"})
end

function CLoginPhoneCtrl.OnCameraPathAnimator3PlayFinish(self, cb)
	if cb then
		cb()
	end
	printc("OnCameraPathAnimator3PlayFinish")
end

--------------PC上的登录逻辑----------

function CLoginPhoneCtrl.UpdateVerifyInfo(self, dInfo)
	table.update(self.m_VerifyInfo, dInfo)
end

function CLoginPhoneCtrl.ConnnectServer(self, sIP, lPort, serverInfo)
	self:ConnnectPhoneServer(sIP, lPort, serverInfo)
end

function CLoginPhoneCtrl.GetLoginInfo(self, sKey)
	return self.m_LoginInfo[sKey]
end

function CLoginPhoneCtrl.ClearLoginInfo(self)
	self.m_LoginInfo = {account=nil, pwd = nil, role_list={}}
end

function CLoginPhoneCtrl.HasLoginInfo(self)
	return self.m_LoginInfo.account~=nil
end

function CLoginPhoneCtrl.IsNeedCreateRole(self)
	return self:HasLoginInfo() and next(self.m_LoginInfo["role_list"]) == nil
end

function CLoginPhoneCtrl.IsShenhePack(self)
	local shenheState = false
	if not g_LoginPhoneCtrl.m_IsPC then
		shenheState = g_UrlRootCtrl.m_ServerType == 1
	end
	return shenheState
end

function CLoginPhoneCtrl.IsBusinessPack(self)
	local businessState = false
	if not g_LoginPhoneCtrl.m_IsPC then
		businessState = g_UrlRootCtrl.m_ServerType == 2
	end
	return businessState
end

--------------------重置数据------------------

--重登很有用,还原数据
--声音需要自己判断处理,现在处理是在登录界面初始化后处理,或创建角色界面后处理
--登录界面需要自己判断处理
--是否接收协议需要自己判断,现在处理是在登录界面初始化后处理
function CLoginPhoneCtrl.ResetAllData(self, bIsNotCloseView)
	g_MapCtrl:Clear(true)
	
	if not bIsNotCloseView then
		g_ViewCtrl:CloseAll() --g_ViewCtrl.m_LoginCloseAllNeedList
		CNotifyView:ShowView()
	end
	self:Clear()
	g_AttrCtrl:Clear()
	g_TitleCtrl:ClearAll()
	g_SummonCtrl:Clear()
	g_MapCtrl:ClearVisibilityAll()
	g_UpgradePacksCtrl:ClearAll()
	g_WarCtrl:ClearData()
	g_TimeCtrl:StopBeat()
	g_NotifyCtrl:Clear()
	g_HorseCtrl:Clear()
	g_WishBottleCtrl:Clear()
	g_LingxiCtrl:Clear()
	g_BaikeCtrl:Clear(true)
	g_InteractionCtrl:Clear()
	g_TaskCtrl:Clear()
	g_MainMenuCtrl:Clear()
	g_GuideHelpCtrl:Clear()
	g_TalkCtrl:Clear()
	g_ItemTempBagCtrl:Clear()
	g_ItemCtrl:Reset()
	g_GuideCtrl:Clear()
	g_EcononmyCtrl:Reset()
	g_DancingCtrl:Clear()
	g_FlyRideAniCtrl:ResetAll()
	g_OrgCtrl:Clear()
	g_HeroTrialCtrl:Clear()
	g_RedPacketCtrl:Clear()
	g_PartnerCtrl:Clear()
	g_ShopCtrl:Reset()
	g_TeamCtrl:Clear()
	g_LotteryCtrl:Reset()
	g_GuessRiddleCtrl:Clear()
	g_CelebrationCtrl:Clear()
	g_SystemSettingsCtrl:Clear()
	g_WelfareCtrl:Clear()
	g_FriendCtrl:Clear()
	g_SignCtrl:Clear()
	g_TimelimitCtrl:Clear()
	g_EveryDayChargeCtrl:ClearAll()
	g_ActiveGiftBagCtrl:ClearAll()
	g_OnlineGiftCtrl:Clear()
	g_AccumChargeCtrl:Clear()
	g_ScheduleCtrl:Clear()
	g_PlotCtrl:Clear()
	g_DungeonCtrl:Clear()
	g_HeShenQiFuCtrl:Clear()
	g_AssembleTreasureCtrl:Clear()
	g_ContActivityCtrl:Clear()
	g_QuickGetCtrl:Reset()
	g_WingCtrl:Reset()
	g_YuanBaoJoyCtrl:Clear()
	g_DungeonTaskCtrl:Clear()
	g_MasterCtrl:Clear()
	g_RebateJoyCtrl:Clear()
	g_ArtifactCtrl:Clear()
	g_SingleBiwuCtrl:Clear()
	g_RoleCreateScene:Clear()
	g_MarryPlotCtrl:Reset()
	g_MarryCtrl:Reset()
	g_ExaminationCtrl:Clear()
	g_ForgeCtrl:Reset()
	g_SkillCtrl:Reset()
	g_JieBaiCtrl:Clear()
	g_SpiritCtrl:Clear()
	g_BigProfitCtrl:Clear()
	g_KuafuCtrl:Clear()
	g_YibaoCtrl:Clear()
	g_WaiGuanCtrl:Clear()
	g_FirstPayCtrl:Clear()
	g_ZhenmoCtrl:Clear()
	g_FaBaoCtrl:Clear()
	g_ItemInvestCtrl:Clear()
	g_FeedbackCtrl:Clear()
	g_MiBaoConvoyCtrl:Clear()
	g_SuperRebateCtrl:Clear()
	g_ZeroBuyCtrl:Clear()
	g_MysticalBoxCtrl:Clear()
	g_ExpRecycleCtrl:Reset()
	g_SoccerWorldCupGuessCtrl:ClearAll()
	g_SoccerTeamSupportCtrl:ClearAll()
	g_SoccerWorldCupGuessHistoryTipCtrl:ClearAll()
	g_SoccerWorldCupCtrl:ClearAll()
	g_DuanWuHuodongCtrl:Clear()

	g_ResCtrl:UnloadAtlas(true)
	g_ResCtrl:GC(true)
end

--这个跟上边的函数目的一致，只不过这个是在GS2CLoginRole里面Reset，有可能一些上边的一些reset不需要
function CLoginPhoneCtrl.ResetAllDataBeforeLoginRole(self)
	g_MapCtrl:Clear(true)
	g_AttrCtrl.m_IsMoneyInit = false
	g_TitleCtrl:ClearAll()
	self:ClearTaskNotify()
	g_TaskCtrl.m_OnlineAddTaskRectEffectList = {}
	g_KuafuCtrl:Clear()
	g_SkillCtrl:Reset()
	g_GuideHelpCtrl:ClearAfterLoginRole()
	g_GuideCtrl:Clear()
	g_ItemTempBagCtrl:Clear()
	g_YibaoCtrl:Clear()
	g_TalkCtrl:Clear()
	g_SuperRebateCtrl:Clear()
end

function CLoginPhoneCtrl.ClearTaskNotify(self)
	local oView = CMainMenuView:GetView()
	if oView then 
		local oMainBox = oView.m_RT.m_ExpandBox.m_TaskPart.m_MainTaskBox
		if not Utils.IsNil(oMainBox) then
			oMainBox:DelEffect("FingerInterval")
		end
	end
end

-------------手机上的逻辑------------

function CLoginPhoneCtrl.SetPhoneChooseInfo(self, server, role)
	self.m_PhoneChooseInfo = {}
	self.m_PhoneChooseInfo.server = {}
	self.m_PhoneChooseInfo.role = {}

	local oNowServer = g_ServerPhoneCtrl:GetServerOrderDataById(server.id) --server.linkserver or 
	table.copy(oNowServer, self.m_PhoneChooseInfo.server)
	table.copy(role, self.m_PhoneChooseInfo.role)
end

function CLoginPhoneCtrl.GetLoginPhoneInfo(self, sKey)
	return self.m_LoginPhoneInfo[sKey]
end

function CLoginPhoneCtrl.ConnnectPhoneServer(self, sIP, lPort, serverInfo)
	if serverInfo then
		serverInfo = g_ServerPhoneCtrl:GetServerOrderDataById(serverInfo.id) --serverInfo.linkserver or 
	end
	if not sIP or sIP == "" then
		local oNotifyMsg = ""
		if g_LoginPhoneCtrl.m_IsPC then
			oNotifyMsg = "服务器即将开放敬请期待"
		else
			oNotifyMsg = serverInfo.desc or "服务器即将开放敬请期待"
		end
		local windowConfirmInfo = {
			msg				= oNotifyMsg,
			thirdCallback	= function ()  end,
			thirdStr		= "确定",
			closeType		= 3,
			style 			= CWindowNetComfirmView.Style.Single,
			pivot 			= enum.UIWidget.Pivot.Center,
		}
		g_WindowTipCtrl:SetWindowNetConfirm(windowConfirmInfo)
		return
	end
	self.m_RecordConnectIp = sIP
	local lPort = lPort or {}
	lPort = table.extend(lPort, g_ServerPhoneCtrl:GetCommonPort(serverInfo))
	g_NetCtrl:ConnectServer(sIP, lPort)
end

--断线重连(Android / IOS)
function CLoginPhoneCtrl.PhoneReconnect(self)
	if not g_AttrCtrl.pid or g_AttrCtrl.pid == 0 or not self.m_RoleToken then
		-- 重新打开登录界面	
	    self:ResetAllData()	
	    CLoginPhoneView:ShowView(function (oView)
			oView:RefreshUI()
			--这里是在有中心服的数据情况下
			if self.m_IsQrPC then
				g_ServerPhoneCtrl:OnEvent(define.Login.Event.ServerListSuccess)
			end
		end)
		return
	end

	netlogin.C2GSReLoginRole(g_AttrCtrl.pid, self.m_RoleToken, gameconfig.Version.AppVer)
	self:ResetCtrl()
end

function CLoginPhoneCtrl.ResetCtrl(self)
	g_WarCtrl:End()
end

-------------发送事件---------------

function CLoginPhoneCtrl.SendActorShowEvent(self, isfinish)
	self:OnEvent(define.Login.Event.ShowActor, isfinish)
end

function CLoginPhoneCtrl.SendActorSelectEvent(self, iRoleId)
	self:OnEvent(define.Login.Event.SelectActor, iRoleId)
end

function CLoginPhoneCtrl.SendClickRoleCreateModelEvent(self, roleconfigid)
	self:OnEvent(define.Login.Event.ClickRoleCreateModel, roleconfigid)
end

function CLoginPhoneCtrl.SendRoleCreateRandomNameEvent(self)
	self:OnEvent(define.Login.Event.RoleCreateRandomName)
end

---------------版本检查---------------

--暂时没有用(没用的)
function CLoginPhoneCtrl.GetUpdateNoticeData(self)
	-- "https://devh7.cilugame.com/h7/business/android/servers/announcementData.txt?ver=85675773453"
	local url
	if self.m_IsPC then
		url = "http://devh7.cilugame.com/getnotice/"
	else
		if self.m_IsUseBack then
			url = "http://devh7.cilugame.com/getnotice/"
		else
			url = "http://devh7.cilugame.com/getnotice/"
		end
	end
	local version
	local fileData = IOTools.GetClientData("loginphone_version")
	if fileData then
		version = type(fileData) == "number" and fileData or 0
	else
		version = 0
	end
	self.m_LocalUpdateNoticeVersion = version
	local data = {version = version}
	table.print(data, "CLoginPhoneCtrl.GetUpdateNoticeData data")
	printc("CLoginPhoneCtrl.GetUpdateNoticeData url:", url)
	local path = IOTools.GetPersistentDataPath("/updatenoticeData")
	IOTools.SaveJsonFile(path, data)
	local saveData = IOTools.LoadJsonFile(path)
	table.print(saveData, "CLoginPhoneCtrl.GetUpdateNoticeData saveData")

	local handler = C_api.FileHandler.OpenByte(path)
	if not handler then
		printc("CLoginPhoneCtrl.GetUpdateNoticeData no handler")
		return
	end
	local bytes = handler:ReadByte()
	handler:Close()

	local headers = {
		["Content-Type"]="application/json;charset=utf-8",
		["Content-Length"]= tostring(bytes.Length),
	}
	-- g_HttpCtrl:Post(url, callback(self, "OnUpdateNoticeDataGet"), headers, bytes, {json_result=true})
	--公告的特殊做法，后边要传一个本地版本号
	url = url..version
	g_HttpCtrl:Get(url, callback(self, "OnUpdateNoticeDataGet"), {json_result=true})
end

--暂时没有用（没用的）
function CLoginPhoneCtrl.OnUpdateNoticeDataGet(self, success, tResult)
	if success then
		self.m_UpdateNoticeData = {}
		table.copy(tResult, self.m_UpdateNoticeData)
		print("CLoginPhoneCtrl.OnUpdateNoticeDataGet success")		
		table.print(tResult, "CSpeechCtrl.OnUpdateNoticeDataGet-->")
	else
		print("CLoginPhoneCtrl.OnUpdateNoticeDataGet err")
	end
end

function CLoginPhoneCtrl.CheckIsVersionNew(self)
	if not next(g_ServerPhoneCtrl.m_PostServerData) or not g_ServerPhoneCtrl.m_PostServerData.info.server_info.notice_version then
		return false
	end
	
	self.m_LocalUpdateNoticeVersion = self:GetLocalUpdateNoticeVersion()
	if self.m_LocalUpdateNoticeVersion ~= g_ServerPhoneCtrl.m_PostServerData.info.server_info.notice_version then
		local list = {}
		if next(g_ServerPhoneCtrl.m_PostServerData) and g_ServerPhoneCtrl.m_PostServerData.info.server_info.infoList and next(g_ServerPhoneCtrl.m_PostServerData.info.server_info.infoList) then
			table.copy(g_ServerPhoneCtrl.m_PostServerData.info.server_info.infoList, list)
		end
		self:SetLocalUpdateNoticeFileData(list)
		return true
	else
		return false
	end
end

function CLoginPhoneCtrl.GetLocalUpdateNoticeVersion(self)
	local version = 0
	local fileData = IOTools.GetClientData("loginphone_version")
	if fileData then
		version = type(fileData) == "number" and fileData or 0
	else
		version = 0
	end
	return version
end

--暂时没有用
function CLoginPhoneCtrl.GetStaticServerData(self)
	if not self.m_IsPC then
		--serverListData里面包含字段:version ssoUrl ports serverInfoList dataUrl(公告地址),还需要一个推荐服务器的数据RecommendServerList
		self.m_ServerListData = {}
		local path = IOTools.GetPersistentDataPath("/staticServerList.txt")
		local serverListData = IOTools.LoadJsonFile(path)
		if serverListData then
			-- table.copy(serverListData, self.m_ServerListData)

			-- g_ServerPhoneCtrl:SetUpServerData()

			printc("CLoginPhoneCtrl.GetStaticServerData version", serverListData.version)
			table.print(self.m_ServerListData, "CLoginPhoneCtrl.GetStaticServerData")
		else
			printc("CLoginPhoneCtrl.GetStaticServerData 不存在")
		end
	end
end

--暂时屏蔽了
function CLoginPhoneCtrl.SetLoginPhoneServerData(self, data)
	local path = IOTools.GetPersistentDataPath("/loginphoneServerData")
	IOTools.SaveJsonFile(path, data)
end

--暂时屏蔽了
function CLoginPhoneCtrl.GetLoginPhoneServerData(self)
	local path = IOTools.GetPersistentDataPath("/loginphoneServerData")
	local data = IOTools.LoadJsonFile(path)
	return data
end

function CLoginPhoneCtrl.SetLocalUpdateNoticeFileData(self, data)
	local path = IOTools.GetPersistentDataPath("/loginphoneUpdateNoticeData")
	IOTools.SaveJsonFile(path, data)
end

function CLoginPhoneCtrl.GetLocalUpdateNoticeFileData(self)
	local path = IOTools.GetPersistentDataPath("/loginphoneUpdateNoticeData")
	local data = IOTools.LoadJsonFile(path) or {}
	return data
end

--------------------排队相关----------------------

--退出排队
function CLoginPhoneCtrl.C2GSQuitLoginQueue(self)
	netlogin.C2GSQuitLoginQueue()
end

--开始排队
function CLoginPhoneCtrl.GS2CLoginPendingUI(self, pbdata)
	g_RoleCreateScene:OnDestroyScene()

	CLineUpTipsView:ShowView(function (oView)
		self:OnEvent(define.Login.Event.UpdateWaitTime, pbdata)
	end)
end

--排队结束，进入服务器
function CLoginPhoneCtrl.GS2CLoginPendingEnd(self)
	if self.m_RecordLoginRolePid and self.m_RecordLoginRolePlatform then
	    netlogin.C2GSLoginRole(self.m_RecordLoginRolePid, (g_KuafuCtrl.m_ConnectKsFail and {1} or {nil})[1])
	    g_KuafuCtrl.m_ConnectKsFail = false
	end
	self:OnEvent(define.Login.Event.LineOver)
end

-----------------一些接口---------------

--1 android, 2 rootios, 3 ios, 4 pc
function CLoginPhoneCtrl.GetPlatform(self)
	local platform

	if g_GameDataCtrl:GetChannel() == "demi" then
		printc("CLoginPhoneCtrl.GetPlatform Channel == \"demi\"", " m_IsQrPC:", self.m_IsQrPC, " platform:", platform, " g_QRCtrl.m_DemiIsQr:", g_QRCtrl.m_DemiIsQr)
		if self.m_IsQrPC then
			if g_QRCtrl.m_DemiIsQr then
				platform = 4
			else
				platform = g_QRCtrl.m_DemiNotQrPlatform	
			end
		else
			platform = 1
			if Utils.IsIOS() then
				platform = 3
			elseif Utils.IsAndroid() then
				platform = 1
			end
		end
		printc("CLoginPhoneCtrl.GetPlatform:", platform)
		return platform
	else
		if self.m_IsPC then
			platform = 4
		else
			platform = 1
			if self.m_IsQrPC then
				platform = 4
			else
				if Utils.IsIOS() then
					platform = 3
				elseif Utils.IsAndroid() then
					platform = 1
				end
			end
		end
		return platform
	end
end

--获取本地保存的之前登录过的服务器和角色数据
function CLoginPhoneCtrl.GetLocalServerAndRoleData(self)
	local dServer = g_ServerPhoneCtrl:GetRecentServer()
	local dRole = g_ServerPhoneCtrl:GetServerOrderDataById(dServer.id).role[1]
	return dServer, dRole
end

function CLoginPhoneCtrl.SetSelectdSeverState(self, data)
	if data == nil then
		self.m_SelectdSever = 0
	else
		self.m_SelectdSever = data
	end
end

function CLoginPhoneCtrl.GetSelectdSeverState(self)
	if self.m_SelectdSever then
		return self.m_SelectdSever
	end
end

function CLoginPhoneCtrl.GetRandomName(self)
	local function getone()
		local first = table.randomvalue(data.randomnamedata.FIRST)
		local last = ""
		local iSex = Utils.RandomInt(1, 2)
		if iSex == define.Sex.Male then
			last = table.randomvalue(data.randomnamedata.MALE)
		else
			last = table.randomvalue(data.randomnamedata.FEMALE)
		end
		if false then
			--插入多少个特殊字段，最多3个
			local numlist = {1, 2, 3}

			local totalstr = ""
			--字符总数
			local totalcount = 0
			local speciallist = {}
			--插入到哪个位置:1, 2, 3
			local poslist = {1, 2, 3}
			--每个特殊字段包含多少个字符，最多4个
			local countlist = {1, 2, 3, 4}
			--特殊字段的字符总数最多4个

			for i=1, table.randomvalue(numlist) do
				local count = table.randomvalue(countlist)
				totalcount = totalcount + count
				if totalcount > 4 then
					break
				end
				local str = ""
				for i=1, count do
					str = str..table.randomvalue(data.randomnamedata.SPECITY)
				end
				local list = {count = count, str = str}
				table.insert(speciallist, list)
			end
			-- table.print(speciallist, "speciallist")
			local eachposstr = {"", "", ""}
			for k,v in ipairs(speciallist) do
				local key = table.randomkey(poslist)
				local pos = poslist[key]
				table.remove(poslist, key)
				eachposstr[pos] = v.str
			end
			return eachposstr[1]..first..eachposstr[2]..last..eachposstr[3]
		else
			return first..last
		end
	end
	local iMax = 10
	local sName = nil
	for i = 1, iMax + 1 do
		local sOne = getone()
		if not self.m_UsedNameCache[sOne] then
			self.m_UsedNameCache[sOne] = true
			sName = sOne
			break
		end
		if i == iMax then
			self.m_UsedNameCache = {}
		end
	end
	if not sName then
		sName = "一个名字"
	end
	return sName
end

function CLoginPhoneCtrl.HasLoginRole(self)
	return self:HasLoginInfo() and (g_AttrCtrl.pid ~= 0)
end


return CLoginPhoneCtrl
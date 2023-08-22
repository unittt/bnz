local CLoginPhoneView = class("CLoginPhoneView", CViewBase)

function CLoginPhoneView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Login/LoginView.prefab", cb)
	--界面设置
	-- self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CLoginPhoneView.OnCreateView(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_VersionLbl = self:NewUI(2, CLabel)
	self.m_TipsLbl = self:NewUI(3, CLabel)
	self.m_ChangeAccountBtn = self:NewUI(4, CButton)
	self.m_UserAgreeBtn = self:NewUI(5, CButton)
	self.m_UpdateNoticeBtn = self:NewUI(6, CButton)
	self.m_ServerBox = self:NewUI(7, CBox)
	self.m_ServerBox.m_NameLbl = self.m_ServerBox:NewUI(1, CLabel)
	self.m_ServerBox.m_StateSp = self.m_ServerBox:NewUI(2, CSprite)
	self.m_RoleBox = self:NewUI(8, CBox)
	self.m_RoleBox.m_NameLbl = self.m_RoleBox:NewUI(1, CLabel)
	self.m_LoginGameBtn = self:NewUI(9, CButton)
	self.m_LoginBtn = self:NewUI(10, CButton)
	self.m_AccountBox = self:NewUI(11, CBox)
	self.m_QrBtn = self:NewUI(12, CButton)
	self.m_NoServerSelectBox = self:NewUI(13, CBox)
	self.m_LoginViewBg = self:NewUI(14, CTexture)
	self.m_LoginViewLogo = self:NewUI(15, CTexture)
	self.m_CopyrightLbl_1 = self:NewUI(16, CLabel)
	self.m_CopyrightLbl_2 = self:NewUI(17, CLabel)

	--PC上的逻辑
	self.m_AccountInput = self.m_AccountBox:NewUI(1, CInput)
	self.m_PwdInput = self.m_AccountBox:NewUI(2, CInput)
	self.m_LoginAccountBtn = self.m_AccountBox:NewUI(3, CButton)
	self.m_PidSelectBtn = self.m_AccountBox:NewUI(4, CButton)
	self.m_LoginAccountBtn:AddUIEvent("click", callback(self, "OnLogin"))

	self.m_MinInputChar = 1
	self.m_MaxInputChar = 20
	self.m_PermittedCharStart = '!'
	self.m_PermittedCharEnd = '~'

	local verify = IOTools.GetClientData("loginphone_pc_verify")
	if not gameconfig.Model.YunceModel and verify then
		self.m_AccountInput:SetText(verify.account)
		self.m_PwdInput:SetText(verify.pwd)
		self.m_PidSelectBtn:SetSelected(verify.ispidlogin or false)
	else
		local sStr = string.GetRandomString(16)
		self.m_AccountInput:SetText(sStr)
	end
	self:SetCharLimits(self.m_PermittedCharStart, self.m_PermittedCharEnd)
	self:SetPermittedChars(self.m_PermittedCharStart, self.m_PermittedCharEnd)
	
	self:InitContent()
	self:InitTexture()
	self:InitCopyrightLabel()

	--TODO:在进入游戏前进行部分模型的预加载
	g_MapWalkerCacheCtrl:CreatePrePlayer()
end

function CLoginPhoneView.InitContent(self)
	self.m_RoleBox:SetActive(false)
	self:ResetUI()

	self.m_ChangeAccountBtn:AddUIEvent("click", callback(self, "OnClickChangeAccount"))
	self.m_UserAgreeBtn:AddUIEvent("click", callback(self, "OnClickUserAgree"))
	self.m_UpdateNoticeBtn:AddUIEvent("click", callback(self, "OnClickUpdateNotice"))
	self.m_ServerBox:AddUIEvent("click", callback(self, "OnClickOpenServerView"))
	self.m_RoleBox:AddUIEvent("click", callback(self, "OnClickOpenServerView"))
	self.m_LoginGameBtn:AddUIEvent("click", callback(self, "OnClickLoginGame"))
	self.m_LoginBtn:AddUIEvent("click", callback(self, "OnClickLogin"))
	self.m_NoServerSelectBox:AddUIEvent("click", callback(self, "OnClickLogin"))
	self.m_QrBtn:AddUIEvent("click", callback(self, "OnClickQr"))

	g_SdkCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_ServerPhoneCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlServerEvent"))
end

function CLoginPhoneView.InitTexture(self)
	local sPath = "Textures/loginBG"
	self:LoadTexture(sPath, function (prefab, errcode)
		self.m_LoginViewBg:SetMainTexture(prefab)
		self.m_LoginBgFlag = true
		self:HideGameLoading()
	end)
	
	if g_LoginPhoneCtrl.m_IsQrPC or g_LoginPhoneCtrl.m_IsPC and g_SdkCtrl:GetChannelId() == "demi" then
		self.m_LoginFlag = true
		self:HideGameLoading()
	else
		sPath = "Textures/logo"
		self:LoadTexture(sPath, function (prefab, errcode)
			self.m_LoginViewLogo:SetMainTexture(prefab)
			self.m_LoginFlag = true
			self:HideGameLoading()
		end)
	end
end

function CLoginPhoneView.InitCopyrightLabel(self)
	local sBanhao = Utils.GetBanhao()
	if sBanhao == "" then
		return 
	end
	if Utils.IsIOS() then
		return
	end

	local strArr = string.split(sBanhao, "\n")
	self.m_CopyrightLbl_1:SetText(strArr[1] or "")
	self.m_CopyrightLbl_2:SetText(strArr[2] or "")

	local showCopyright = not (g_LoginPhoneCtrl:IsShenhePack() or g_LoginPhoneCtrl:IsBusinessPack())
	self.m_CopyrightLbl_1:SetActive(showCopyright)
	self.m_CopyrightLbl_2:SetActive(showCopyright)
end

function CLoginPhoneView.HideGameLoading(self)
	if self.m_LoginBgFlag and self.m_LoginFlag then
		-- 移除启动游戏界面UI
		Utils.AddTimer(function ()
			C_api.Utils.HideGameLoading()
			-- self:InitEffect()
		end, 0, 0)
	end
end

function CLoginPhoneView.InitEffect(self)
	self.m_LoginEffectList = {}
	local effectPath = {
		"Effect/UI/ui_eff_login_1/Prefabs/ui_eff_login_1.prefab",
		"Effect/UI/ui_eff_login_2/Prefabs/ui_eff_login_2.prefab"
	}
	for _,v in ipairs(effectPath) do
		g_ResCtrl:LoadCloneAsync(v, callback(self, "OnEffLoad", v), false)
	end
end

function CLoginPhoneView.LoadTexture(self, sPath, cb)
	g_ResCtrl:LoadStreamingAssetsTexture(sPath, cb)
end

function CLoginPhoneView.OnEffLoad(self, path, oClone, errcode)
	if Utils.IsNil(self) then
		return
	end
	if oClone then
		local effect = CObject.New(oClone)
		effect:SetParent(self.m_Transform)
		self:SetLocalPos(Vector2.zero)
		table.insert(self.m_LoginEffectList, effect)
	end
end

function CLoginPhoneView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Sdk.Event.LoginSuccess then
		--sdk成功后的逻辑
		--手机上的显示登录主界面ui
		-- self:ShowPhoneMainUI()
		-- self.m_AccountBox:SetActive(false)
	elseif oCtrl.m_EventID == define.Sdk.Event.LoginFail or oCtrl.m_EventID == define.Sdk.Event.LoginCancel then
		-- g_NotifyCtrl:FloatMsg("账号登录失败，请检查你的网络环境")
		local args ={
			title = "登录失败",
			msg = "账号登录失败，请调整您当前使用的网络后再登录游戏",
			okStr = "重新登录",
			okCallback = function()
				self:ResetUI()
				if g_LoginPhoneCtrl.m_IsPC then
					self:ResetUI()
		        elseif g_LoginPhoneCtrl.m_IsQrPC then
	        		self:ResetUI()
	                --这里是在有中心服的数据情况下
	                g_ServerPhoneCtrl:OnEvent(define.Login.Event.ServerListSuccess)
	        	else
	            	g_SdkCtrl:Login()
		        end
			end,
			cancelStr = "退出游戏",
			cancelCallback = function()
				Utils.QuitGame()
			end,
			closeType = 3,
			isOkNotClose = false,
			hideClose = true,
		}
		g_WindowTipCtrl:SetWindowNetConfirm(args)
		-- self:ResetUI()
	end
end

function CLoginPhoneView.OnCtrlServerEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Login.Event.ServerListSuccess then
		if g_LoginPhoneCtrl.m_IsPC or not next(g_ServerPhoneCtrl.m_PostServerData) then
			return
		end
		--sdk成功后的逻辑
		CQRCodeLoginView:CloseView()
		--显示用户公告和协议
		self:ShowUserAndNotice()
		--手机上的显示登录主界面ui
		self:ShowPhoneMainUI()
		self.m_AccountBox:SetActive(false)
		printc("CLoginPhoneView.OnCtrlServerEvent:服务器列表数据请求成功")
	end
end

function CLoginPhoneView.ResetUI(self)
	self.m_ChangeAccountBtn:SetActive(false)
	self.m_UserAgreeBtn:SetActive(false)
	self.m_UpdateNoticeBtn:SetActive(false)
	self.m_ServerBox:SetActive(false)
	self.m_RoleBox:SetActive(false)
	self.m_LoginGameBtn:SetActive(false)
	self.m_LoginBtn:SetActive(true)
	self.m_NoServerSelectBox:SetActive(true)
	self.m_AccountBox:SetActive(false)
	self.m_QrBtn:SetActive(false)
end

function CLoginPhoneView.ResetAllUI(self)
	self.m_ChangeAccountBtn:SetActive(false)
	self.m_UserAgreeBtn:SetActive(false)
	self.m_UpdateNoticeBtn:SetActive(false)
	self.m_ServerBox:SetActive(false)
	self.m_RoleBox:SetActive(false)
	self.m_LoginGameBtn:SetActive(false)
	self.m_LoginBtn:SetActive(false)
	self.m_NoServerSelectBox:SetActive(false)
	self.m_AccountBox:SetActive(false)
	self.m_QrBtn:SetActive(false)
end

function CLoginPhoneView.RefreshUI(self)
	self.m_IsClickLoginGame = false
	g_AttrCtrl.pid = 0
	g_AudioCtrl:PlayMusic(define.Audio.MusicPath.login)
	printc("CLoginPhoneView.RefreshUI 销毁m_MainNetObj")
	if g_NetCtrl.m_MainNetObj then
		g_NetCtrl.m_MainNetObj:Release()
		g_NetCtrl.m_MainNetObj = nil
	end
	g_RoleCreateScene.m_HasAskCreateScene = false
	g_RoleCreateScene:OnDestroyScene()
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then oNotifyView:SetSortOrder(4) end

	g_UploadDataCtrl:SetDotUpload("13")

	--重置界面，只显示一个登录按钮
	self:ResetUI()


	--版本信息(这里显示版本和技术更新所用版本为两个完全不同的表示)
	
	-- ShowVersion
	local showVer = "版本号：" .. gameconfig.Version.ShowVer

	local fixver2, framever2, gamever2, resver2 = C_api.Utils.GetResVersion()
	local resVer = string.format("Res：%s_%s_%s", framever2, gamever2, resver2)
	self.m_VersionLbl:SetText(showVer .. "  " .. resVer)

	local fixver, framever, gamever, resver = C_api.Utils.GetAppVersion()
	local svnver = C_api.Utils.GetSvnVersion()
	resver = resver and "." .. resver or ""
	local appVer = string.format("App:%s.%s.%s%s", fixver, framever, gamever, resver)
	local resVer = string.format(" Res:%s.%s.%s.%s v%s", fixver2, framever2, gamever2, resver2, svnver)
	local curVersion = appVer .. resVer
	-- 不要删掉这个输出，便于Log下查看当前包的技术版本号
	printc("技术版本号：" .. curVersion)

	local function login()
		if g_LoginPhoneCtrl.m_IsPC then
			--PC上显示账号注册登录ui
			self.m_LoginBtn:SetActive(false)
			self.m_NoServerSelectBox:SetActive(false)
			self.m_AccountBox:SetActive(true)
		else
			if g_LoginPhoneCtrl.m_IsQrPC then
				self:ResetAllUI()
				CQRCodeLoginView:CloseView()
				CQRCodeLoginView:ShowView()
			else
				--调用sdk登录
				-- printc("CLoginPhoneView.RefreshUI 调用sdk登录")
				g_SdkCtrl:Login()
			end
		end	
	end
	
	--有cg动画并且本地没有播放cg的记录
	if g_LoginPhoneCtrl.m_IsHasCG and not IOTools.GetClientData("cgrecord") then
		--播放cg，以后在这里修改
		login()
	else
		login()
	end
end

function CLoginPhoneView.ShowUserAndNotice(self)
	local function login2()
		--显示公告,是否显示公告界面
		if g_LoginPhoneCtrl:CheckIsVersionNew() then
			CUpdateNoticeView:ShowView(function (oView)
				-- local list = {{title = "更新福利", content = [[{link21,"www.baidu.com",[u]www.baidu.com[/u]}]]}}
				oView:SetSortOrder(3)
				oView.m_BehidLayer:SetSortOrder(3)
				oView.m_ScrollView:SetSortOrder(3)
				oView:RefreshUI()
			end)
		else
		end
	end

	--本地已有useragree纪录,是否显示协议界面
	if IOTools.GetClientData("useragree") then
		login2()
	else
		self:OnClickUserAgree(login2)
	end
end

--显示服务器的信息以及角色名的信息
function CLoginPhoneView.ShowPCMainUI(self)
	self.m_ChangeAccountBtn:SetActive(true)
	self.m_UserAgreeBtn:SetActive(true)
	self.m_UpdateNoticeBtn:SetActive(true)
	self.m_ServerBox:SetActive(true)
	self.m_RoleBox:SetActive(false)
	self.m_LoginGameBtn:SetActive(true)
	self.m_LoginBtn:SetActive(false)
	self.m_NoServerSelectBox:SetActive(false)
	self.m_QrBtn:SetActive(false)

	if g_LoginPhoneCtrl.m_IsPC then
		local dServer = IOTools.GetClientData("loginphone_pc_server")
		if not dServer or not dServer.id then
			dServer = g_ServerPhoneCtrl:GetTuijianServerList()[1]
		else
			if g_ServerPhoneCtrl:GetServerOrderDataById(dServer.id) then
				dServer = g_ServerPhoneCtrl:GetServerOrderDataById(dServer.id)
			else
				dServer = g_ServerPhoneCtrl:GetTuijianServerList()[1]
			end
		end
		self:SetServer(dServer)
	end
end

function CLoginPhoneView.ShowPhoneMainUI(self)
	self.m_ChangeAccountBtn:SetActive(true)
	self.m_UserAgreeBtn:SetActive(true)
	self.m_UpdateNoticeBtn:SetActive(true)
	self.m_ServerBox:SetActive(true)
	self.m_RoleBox:SetActive(false)
	self.m_LoginGameBtn:SetActive(true)
	self.m_LoginBtn:SetActive(false)
	self.m_NoServerSelectBox:SetActive(false)
	if g_LoginPhoneCtrl.m_IsQrPC then
		self.m_QrBtn:SetActive(false)
	else
		self.m_QrBtn:SetActive(true)
	end

	if not g_LoginPhoneCtrl.m_IsPC then
		local dServer, dRole = g_LoginPhoneCtrl:GetLocalServerAndRoleData()
		printc("CLoginPhoneView.ShowPhoneMainUI dServer type:"..type(dServer))
		printc("CLoginPhoneView.ShowPhoneMainUI dRole type:"..type(dRole))
		table.print(dServer, "CLoginPhoneView.ShowPhoneMainUI dServer")
		table.print(dRole, "CLoginPhoneView.ShowPhoneMainUI dRole")
		self:SetPhoneServer(dServer, dRole)
	end
end

-------------pid登录的逻辑---------------

function CLoginPhoneView.OnClickPidLogin(self)
	local oPidStr = self.m_PidAccountInput:GetText()
	if not oPidStr or oPidStr == "" then
		g_NotifyCtrl:FloatMsg("请输入Pid")
		return
	end
end

-------------PC上的逻辑--------------

function CLoginPhoneView.SetCharLimits(self)
	self.m_AccountInput:SetCharLimit(self.m_MaxInputChar)
	self.m_PwdInput:SetCharLimit(self.m_MaxInputChar)
end

function CLoginPhoneView.SetPermittedChars(self, charStart, charEnd)
	self.m_AccountInput:SetPermittedChars(charStart, charEnd)
	self.m_PwdInput:SetPermittedChars(charStart, charEnd)
end

function CLoginPhoneView.OnLogin(self)
	if not define.Sdk.IsDebug then
		if g_LoginPhoneCtrl.m_IsQrPC then
			self:ResetAllUI()
			CQRCodeLoginView:CloseView()
			CQRCodeLoginView:ShowView()
		else
			g_SdkCtrl:Login()
		end
		return
	end
	local t = {
		account = self.m_AccountInput:GetText(),
		pwd = self.m_PwdInput:GetText(),
		ispidlogin = self.m_PidSelectBtn:GetSelected(),
	}
	if not t.ispidlogin then
		if #t.account < self.m_MinInputChar then
			g_NotifyCtrl:FloatMsg("请输入用户名")
			return
		end
	else
		if not t.account or t.account == "" then
			g_NotifyCtrl:FloatMsg("请输入Pid")
			return
		end
	end
	IOTools.SetClientData("loginphone_pc_verify", t)
	g_LoginPhoneCtrl:UpdateVerifyInfo(t)

	--显示用户公告和协议
	self:ShowUserAndNotice()
	--PC上的显示登录主界面ui
	self:ShowPCMainUI()
	self.m_AccountBox:SetActive(false)
end

function CLoginPhoneView.SetServer(self, dServer)
	self.m_Server = dServer
	--printc("CLoginPhoneView.SetServer")
	--table.print(self.m_Server)
	IOTools.SetClientData("loginphone_pc_server", self.m_Server)
	self.m_ServerBox.m_NameLbl:SetText(self.m_Server.name) --self.m_Server.serverindex.."-"..
	local serverState = 0
	if self.m_Server.state then
		serverState = self.m_Server.state
	end
	self.m_ServerBox.m_StateSp:SetSpriteName(g_ServerPhoneCtrl:GetServerStateSpriteName(serverState))
end

-----------------手机上的逻辑---------------------

function CLoginPhoneView.SetPhoneServer(self, dServer, dRole)
	self.m_PhoneServer = dServer
	self.m_PhoneRole = dRole	
	self.m_ServerBox.m_NameLbl:SetText(self.m_PhoneServer.name) --self.m_PhoneServer.serverindex.."-"..
	local serverState = 0
	if self.m_PhoneServer.state then
		serverState = self.m_PhoneServer.state
	end
	self.m_ServerBox.m_StateSp:SetSpriteName(g_ServerPhoneCtrl:GetServerStateSpriteName(serverState))
	if self.m_PhoneRole.pid == -1 then
		self.m_RoleBox:SetActive(false)
	else
		--暂时屏蔽掉显示角色信息，以后需要可开启
		self.m_RoleBox:SetActive(false)
		self.m_RoleBox.m_NameLbl:SetText(self.m_PhoneRole.name)
	end
	-- local list = {server = self.m_PhoneServer, role = self.m_PhoneRole}
	-- g_LoginPhoneCtrl:SetLoginPhoneServerData(list)
end

----------------以下是点击事件-----------------------

function CLoginPhoneView.OnClickChangeAccount(self)
	if g_LoginPhoneCtrl.m_IsPC then
		--PC上显示账号注册登录ui
		self:ResetUI()
		self.m_LoginBtn:SetActive(false)
		self.m_NoServerSelectBox:SetActive(false)
		self.m_AccountBox:SetActive(true)
	else
		if g_LoginPhoneCtrl.m_IsQrPC then
			self:ResetAllUI()
			CQRCodeLoginView:CloseView()
			CQRCodeLoginView:ShowView()
		else
			-- self:ResetUI()
			g_SdkCtrl:Logout()
		end
	end
end

function CLoginPhoneView.OnClickUserAgree(self, oLoginCb)
	CUserAgreementView:ShowView(function (oView)
		oView:SetLoginCallback(oLoginCb)
		oView:SetSortOrder(3)
		oView.m_BehidLayer:SetSortOrder(3)
		oView.m_ScrollView:SetSortOrder(3)
	end)
end

function CLoginPhoneView.OnClickUpdateNotice(self)
	CUpdateNoticeView:ShowView(function (oView)
		-- local list = {{title = "更新福利", content = [[{link21,"www.baidu.com",[u]www.baidu.com[/u]}]]}}
		oView:SetSortOrder(3)
		oView.m_BehidLayer:SetSortOrder(3)
		oView.m_ScrollView:SetSortOrder(3)
		oView:RefreshUI()
	end)
end

function CLoginPhoneView.OnClickOpenServerView(self)
	--主要是为了请求角色信息
    --更新中心服数据
	g_ServerPhoneCtrl:UpdateGSData()
    
	CServerSelectPhoneView:ShowView(function (oView)
		oView:RefreshUI()
		oView:SetSortOrder(3)
		oView.m_BehidLayer:SetSortOrder(3)
		oView.m_TypeScrollView:SetSortOrder(3)
		oView.m_RightScrollView:SetSortOrder(3)
	end)
end

function CLoginPhoneView.OnClickLoginGame(self)
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.OnClickLoginGame, self:GetInstanceID()) then
		return
	end
	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.OnClickLoginGame, self:GetInstanceID(), 2)
	if g_LoginPhoneCtrl.m_IsPC then
		if not self.m_Server then
			return
		end

		--重要，标识不是重连的连接
		g_LoginPhoneCtrl.m_IsReconnect = false
		g_LoginPhoneCtrl:ConnnectServer(self.m_Server.ip, self.m_Server.ports, self.m_Server)
	else
		if not self.m_PhoneServer or not self.m_PhoneRole then
			return
		end

		g_LoginPhoneCtrl:SetPhoneChooseInfo(self.m_PhoneServer, self.m_PhoneRole)
		--重要，标识不是重连的连接
		g_LoginPhoneCtrl.m_IsReconnect = false
		g_LoginPhoneCtrl:ConnnectPhoneServer(self.m_PhoneServer.ip, self.m_PhoneServer.ports, self.m_PhoneServer)
	end

	g_UploadDataCtrl:SetDotUpload("16")
	g_UploadDataCtrl:SetDotUpload("23")
	-- if not self.m_IsClickLoginGame then	
	-- 	self.m_IsClickLoginGame = true
	-- end
end

function CLoginPhoneView.OnClickLogin(self)
	if not g_LoginPhoneCtrl.m_IsPC then
		--这里不需要判断是否显示扫码
		--调用sdk登录
		-- printc("CLoginPhoneView.OnClickLogin 调用sdk登录")
		g_SdkCtrl:Login()
	end
end

function CLoginPhoneView.OnClickQr(self)
	local oLoginView = CLoginPhoneView:GetView()
	if oLoginView then
		oLoginView:SetActive(false)
	end
	local oSelectView = CServerSelectPhoneView:GetView()
	if oSelectView then
		oSelectView:SetActive(false)
	end
	local function closeCallback()
		local oLoginView = CLoginPhoneView:GetView()
		if oLoginView then
			oLoginView:SetActive(true)
		end
		local oSelectView = CServerSelectPhoneView:GetView()
		if oSelectView then
			oSelectView:SetActive(true)
		end
	end
	CQRCodeScanView:CloseView()
	CQRCodeScanView:ShowView(function (oView)
		oView:SetData(closeCallback)
	end)
end

return CLoginPhoneView
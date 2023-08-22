local CQRCodeLoginView = class("CQRCodeLoginView", CViewBase)

function CQRCodeLoginView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Qr/QRCodeLoginView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CQRCodeLoginView.OnCreateView(self)
	self.m_WaitScanBox = self:NewUI(1, CBox)
	self.m_WaitEnsureBox = self:NewUI(2, CBox)
	self.m_DemiLoginGroupBox = self:NewUI(3, CBox)

	self.m_WaitScanBox.m_QRTexture = self.m_WaitScanBox:NewUI(1, CTexture)
	self.m_WaitScanBox.m_OverTimeBox = self.m_WaitScanBox:NewUI(2, CBox)
	self.m_WaitScanBox.m_OverTimeBox.m_RefreshLbl = self.m_WaitScanBox.m_OverTimeBox:NewUI(1, CLabel)
	self.m_WaitScanBox.m_OverTimeBox.m_RefreshBtn = self.m_WaitScanBox.m_OverTimeBox:NewUI(2, CButton)
	self.m_WaitScanBox.m_DescLbl1 = self.m_WaitScanBox:NewUI(3, CLabel)
	self.m_WaitScanBox.m_DescLbl2 = self.m_WaitScanBox:NewUI(4, CLabel)
	self.m_WaitScanBox.m_ClickLbl1 = self.m_WaitScanBox:NewUI(5, CLabel)
	self.m_WaitScanBox.m_ClickLbl2 = self.m_WaitScanBox:NewUI(6, CLabel)
	self.m_WaitScanBox.m_TipsBox = self.m_WaitScanBox:NewUI(7, CBox)
	self.m_WaitScanBox.m_TipsBg = self.m_WaitScanBox:NewUI(8, CSprite)
	self.m_WaitScanBox.m_TipsTex = self.m_WaitScanBox:NewUI(9, CTexture)
	self.m_WaitScanBox.m_LogoTex = self.m_WaitScanBox:NewUI(10, CTexture)
	self.m_WaitScanBox.m_Icon = self.m_WaitScanBox:NewUI(11, CSprite)

	if g_GameDataCtrl:GetChannel() == "demi" then
		self.m_WaitScanBox.m_Icon:SetSpriteName("dm")
	end

	self.m_WaitEnsureBox.m_RefreshScanBtn = self.m_WaitEnsureBox:NewUI(1, CButton)

	self.m_DemiLoginGroupBox.m_AndroidBtn = self.m_DemiLoginGroupBox:NewUI(1, CButton)
	self.m_DemiLoginGroupBox.m_IOSBtn = self.m_DemiLoginGroupBox:NewUI(2, CButton)

	self.m_Interval = 1
	--暂时屏蔽
	-- self.m_QrCodeSid = ""
	self.m_RequestLoginNow = false
	
	self:InitContent()
end

function CQRCodeLoginView.InitContent(self)
	--停止二维码超时计算
	g_QRCtrl:ResetQrLeftTimer()
		
	self.m_WaitScanBox:SetActive(true)
	self.m_WaitScanBox.m_QRTexture:SetActive(false)
	self.m_WaitScanBox.m_OverTimeBox.m_RefreshLbl:SetText("请检查网络哦")
	self.m_WaitScanBox.m_OverTimeBox:SetActive(true)
	self.m_WaitEnsureBox:SetActive(false)

	if g_LoginPhoneCtrl.m_IsQrPC and g_SdkCtrl:GetChannelId() ~= "demi" then
		self.m_DemiLoginGroupBox.m_AndroidBtn:SetActive(false)
		self.m_DemiLoginGroupBox.m_IOSBtn:SetActive(false)
	end

	self.m_WaitScanBox.m_OverTimeBox.m_RefreshBtn:AddUIEvent("click", callback(self, "OnClickRequestQRCode"))
	self.m_WaitEnsureBox.m_RefreshScanBtn:AddUIEvent("click", callback(self, "OnClickEnsureRequestQRCode"))
	self.m_WaitScanBox.m_ClickLbl1:AddUIEvent("click", callback(self, "OnClickQRTips", 1))
	self.m_WaitScanBox.m_ClickLbl2:AddUIEvent("click", callback(self, "OnClickQRTips", 2))
	self.m_WaitScanBox.m_TipsBg:AddUIEvent("click", callback(self, "OnClickQRTipsBg"))

	self.m_DemiLoginGroupBox.m_AndroidBtn:AddUIEvent("click", callback(self, "OnClickAndroidQR"))
	self.m_DemiLoginGroupBox.m_IOSBtn:AddUIEvent("click", callback(self, "OnClickIOSQR"))

	g_QRCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlQREvent"))

	g_NetCtrl:ConnectServer(g_UrlRootCtrl.m_CSRootUrlDomainName, g_QRCtrl.m_PCConnectPort)
end

function CQRCodeLoginView.OnCtrlQREvent(self, oCtrl)
	if oCtrl.m_EventID == define.QR.Event.QRSid then
		self.m_WaitScanBox:SetActive(true)
		self.m_WaitScanBox.m_OverTimeBox:SetActive(false)
		self.m_WaitEnsureBox:SetActive(false)

		--暂时屏蔽
		-- self.m_QrCodeSid = oCtrl.m_EventData.token
		self:UpdateQRCodeTexture()
	elseif oCtrl.m_EventID == define.QR.Event.QRCScanSuccess then
		--停止二维码超时计算
		g_QRCtrl:ResetQrLeftTimer()

		self.m_WaitScanBox:SetActive(false)
		self.m_WaitEnsureBox:SetActive(true)
	elseif oCtrl.m_EventID == define.QR.Event.QRCInvalid then
		--停止二维码超时计算
		g_QRCtrl:ResetQrLeftTimer()

		self.m_WaitScanBox:SetActive(true)
		self.m_WaitScanBox.m_QRTexture:SetActive(false)
		self.m_WaitScanBox.m_OverTimeBox.m_RefreshLbl:SetText("二维码失效")
		self.m_WaitScanBox.m_OverTimeBox:SetActive(true)
		self.m_WaitEnsureBox:SetActive(false)
	elseif oCtrl.m_EventID == define.QR.Event.QRTimeOut then
		self.m_WaitScanBox:SetActive(true)
		self.m_WaitScanBox.m_QRTexture:SetActive(false)
		self.m_WaitScanBox.m_OverTimeBox.m_RefreshLbl:SetText("二维码失效")
		self.m_WaitScanBox.m_OverTimeBox:SetActive(true)
		self.m_WaitEnsureBox:SetActive(false)
	end
end

function CQRCodeLoginView.UpdateQRCodeTexture(self)
	--这里没有版本号比对
	local jsonStr = cjson.encode({sid = g_QRCtrl.m_QrCodeSid, notice_ver = g_LoginPhoneCtrl:GetLocalUpdateNoticeVersion()})
	local tex = C_api.AntaresQRCodeUtil.Encode(jsonStr, self.m_WaitScanBox.m_QRTexture.m_UIWidget.width)
	self.m_WaitScanBox.m_QRTexture:SetActive(true)
	self.m_WaitScanBox.m_QRTexture.m_UIWidget.mainTexture = tex
end

-----------------点击事件----------------

function CQRCodeLoginView.OnClickRequestQRCode(self)
	if g_NetCtrl.m_MainNetObj then
		g_NetCtrl.m_MainNetObj:Release()
		g_NetCtrl.m_MainNetObj = nil
	end
	g_NetCtrl:ConnectServer(g_UrlRootCtrl.m_CSRootUrlDomainName, g_QRCtrl.m_PCConnectPort)
end

function CQRCodeLoginView.OnClickEnsureRequestQRCode(self)
	if g_NetCtrl.m_MainNetObj then
		g_NetCtrl.m_MainNetObj:Release()
		g_NetCtrl.m_MainNetObj = nil
	end
	g_NetCtrl:ConnectServer(g_UrlRootCtrl.m_CSRootUrlDomainName, g_QRCtrl.m_PCConnectPort)
end

function CQRCodeLoginView.OnClickAndroidQR(self)
	printc("CQRCodeLoginView.OnClickAndroidQR")
	g_QRCtrl.m_DemiNotQrPlatform = 1
	g_QRCtrl.m_DemiIsQr = false
	self:CloseView()
	C_api.SPSdkManager.Instance:DoDemiLoginForAndroid()
end
	
function CQRCodeLoginView.OnClickIOSQR(self)
	printc("CQRCodeLoginView.OnClickIOSQR")
	g_QRCtrl.m_DemiNotQrPlatform = 3
	g_QRCtrl.m_DemiIsQr = false
	self:CloseView()
	C_api.SPSdkManager.Instance:DoDemiLoginForIOS()
end

--暂时没有用
function CQRCodeLoginView.RequestQRCode(self)
	if self.m_LoginTimer then
		Utils.DelTimer(self.m_LoginTimer)
		self.m_LoginTimer = nil
	end
	self.m_WaitScanBox:SetActive(true)
	self.m_WaitScanBox.m_OverTimeBox:SetActive(false)
	self.m_WaitEnsureBox:SetActive(false)

	g_QRCtrl:PostQRSid(function (tResult)
		if Utils.IsNil(self) then
			return
		end

		if tResult ~= nil then
			if tResult.code == 0 then
				self.m_QrCodeSid = tResult.msg
				self:UpdateQRCodeTexture()
				self.m_RequestLoginNow = false
				self.m_LoginTimer = Utils.AddTimer(callback(self, "CheckQRCodeLogin"), self.m_Interval, 0)
			else
				local windowConfirmInfo = {
					msg = "二维码获取发生错误，请重试",
					thirdCallback = function ()
						self:RequestQRCode()
					end,
					cancelCallback = function ()
						self:RequestQRCode()
					end,
					thirdStr = "确定",
					closeType = 3,
					style = CWindowNetComfirmView.Style.Single,
					pivot = enum.UIWidget.Pivot.Center,
				}
				g_WindowTipCtrl:SetWindowNetConfirm(windowConfirmInfo)
			end
		else
			self:RequestQRCode()
		end
	end)
end

--暂时没有用
function CQRCodeLoginView.CheckQRCodeLogin(self)
	if self.m_RequestLoginNow then
		return
	end
	self.m_RequestLoginNow = true

	g_QRCtrl:PostQRLoginState(function (tResult)
		self.m_RequestLoginNow = false

		if Utils.IsNil(self) then
			return
		end

		if not tResult then
			return
		end

		if tResult.code == 0 then
			if self.m_LoginTimer then
				Utils.DelTimer(self.m_LoginTimer)
				self.m_LoginTimer = nil
			end

			--进行登录
			-- local needData = {token = self.m_VerifyPhoneToken, channel = self.m_ChannelId, account = self.m_VerifyPhoneUid, notice_ver = g_LoginPhoneCtrl:GetLocalUpdateNoticeVersion()}
			-- g_ServerPhoneCtrl:PostServerList(needData)

			self:CloseView()
		elseif tResult.code == 1101 then
			--等待
		elseif tResult.code == 1102 then
			self.m_WaitScanBox:SetActive(false)
			self.m_WaitEnsureBox:SetActive(true)
		elseif tResult.code == 1100 then
			if self.m_LoginTimer then
				Utils.DelTimer(self.m_LoginTimer)
				self.m_LoginTimer = nil
			end

			self.m_WaitScanBox.m_QRTexture:SetActive(false)
			self.m_WaitScanBox.m_OverTimeBox:SetActive(true)
			self.m_WaitScanBox:SetActive(true)
			self.m_WaitEnsureBox:SetActive(false)
		elseif tResult.code == 1104 then
			if self.m_LoginTimer then
				Utils.DelTimer(self.m_LoginTimer)
				self.m_LoginTimer = nil
			end

			local windowConfirmInfo = {
				-- msg = "账号登录会话(token)失效，请重试",
				msg = "账号登录会话失效，请重试",
				thirdCallback = function ()
					self:RequestQRCode()
				end,
				cancelCallback = function ()
					self:RequestQRCode()
				end,
				thirdStr = "确定",
				closeType = 3,
				style = CWindowNetComfirmView.Style.Single,
				pivot = enum.UIWidget.Pivot.Center,
			}
			g_WindowTipCtrl:SetWindowNetConfirm(windowConfirmInfo)
		else
			if self.m_LoginTimer then
				Utils.DelTimer(self.m_LoginTimer)
				self.m_LoginTimer = nil
			end

			local windowConfirmInfo = {
				msg = "登录出现问题了哦，请重试",
				thirdCallback = function ()
					self:RequestQRCode()
				end,
				cancelCallback = function ()
					self:RequestQRCode()
				end,
				thirdStr = "确定",
				closeType = 3,
				style = CWindowNetComfirmView.Style.Single,
				pivot = enum.UIWidget.Pivot.Center,
			}
			g_WindowTipCtrl:SetWindowNetConfirm(windowConfirmInfo)
		end
	end)
end

function CQRCodeLoginView.OnClickQRTips(self, index)
	self.m_WaitScanBox.m_TipsBox:SetActive(true)
	local showLogo = index == 1
	-- 背景图
	local sTextureName = showLogo and "Texture/Login/h7_shezhihuamian_1.png" or "Texture/Login/h7_shezhihuamian.png"
	g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetTipsTexture"))

	-- Logo图
	self.m_WaitScanBox.m_LogoTex:SetActive(showLogo)
	if showLogo then
		-- local sLogoPath = string.format("Texture/Login/logo_%s.png", g_GameDataCtrl:GetGameType())
		-- g_ResCtrl:LoadAsync(sLogoPath, callback(self, "SetLogoTexture"))
		if g_LoginPhoneCtrl.m_IsQrPC and g_SdkCtrl:GetChannelId() == "demi" then
			g_ResCtrl:LoadStreamingAssetsTexture("Textures/logo", callback(self, "SetLogoTexture"))
		end
	end
end

function CQRCodeLoginView.SetTipsTexture(self, prefab, errcode)
	if prefab then
		self.m_WaitScanBox.m_TipsTex:SetMainTexture(prefab)
	end
end

function CQRCodeLoginView.SetLogoTexture(self, prefab, errcode)
	if prefab then
		self.m_WaitScanBox.m_LogoTex:SetMainTexture(prefab)
		self.m_WaitScanBox.m_LogoTex:MakePixelPerfect()
		self.m_WaitScanBox.m_LogoTex:SetLocalScale(Vector3.one * 0.6)
	end
end

function CQRCodeLoginView.OnClickQRTipsBg(self)
	self.m_WaitScanBox.m_TipsBox:SetActive(false)
	self.m_WaitScanBox.m_TipsTex:SetMainTexture(nil)
	self.m_WaitScanBox.m_LogoTex:SetMainTexture(nil)
end

return CQRCodeLoginView
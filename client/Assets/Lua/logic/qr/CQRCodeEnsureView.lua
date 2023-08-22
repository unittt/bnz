local CQRCodeEnsureView = class("CQRCodeEnsureView", CViewBase)

function CQRCodeEnsureView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Qr/QRCodeEnsureView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondGuide"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CQRCodeEnsureView.OnCreateView(self)
	self.m_EnsureBtn = self:NewUI(1, CButton)
	self.m_ReturnBtn = self:NewUI(2, CButton)
	self.m_TipLbl = self:NewUI(3, CLabel)

	self.m_CloseCallback = nil
	self.m_QrSid = ""
	self.m_NoticeVer = 0
	
	self:InitContent()
end

function CQRCodeEnsureView.InitContent(self)
	self.m_EnsureBtn:AddUIEvent("click", callback(self, "OnEnsureBtnClick"))
	self.m_ReturnBtn:AddUIEvent("click", callback(self, "OnReturnBtnClick"))
	
	self.m_TipLbl:SetText(g_GameDataCtrl:GetGameName() .. "电脑微端登录")
end

function CQRCodeEnsureView.SetData(self, closeCallback, sid, notice_ver)
	self.m_CloseCallback = closeCallback
	self.m_QrSid = sid
	self.m_NoticeVer = notice_ver
end

function CQRCodeEnsureView.OnEnsureBtnClick(self)
	local needList = {
		account_token = g_ServerPhoneCtrl.m_PostServerData.info.token,
		code_token = self.m_QrSid, notice_ver = self.m_NoticeVer,
		transfer_info = {account = g_SdkCtrl.m_VerifyPhoneUid, channel = g_SdkCtrl.m_ChannelId}
	}
	
	g_QRCtrl:PostQRLoginEnsure(needList, function (tResult)
		if Utils.IsNil(self) or not tResult then
			return
		end

		local floatMsg = ""
		if tResult.errcode == 0 then
			floatMsg = "你已成功登录PC端"
		elseif tResult.errcode == 402 then
			floatMsg = "PC端二维码已过期,请重刷二维码"
		elseif tResult.errcode == 401 then
			floatMsg = "账号登录失效,请手机端重新登录账号"
		elseif tResult.errcode == 403 then
			floatMsg = "PC端二维码已过期,请重刷二维码"
		else
			floatMsg = "登录失败,请手机端重新登录账号"
		end
		g_NotifyCtrl:FloatMsg(floatMsg)
		self:OnReturnBtnClick()
	end)
end

function CQRCodeEnsureView.OnReturnBtnClick(self)
	if self.m_CloseCallback then
		self.m_CloseCallback()
		self.m_CloseCallback = nil
	end
	self:CloseView()
end

return CQRCodeEnsureView
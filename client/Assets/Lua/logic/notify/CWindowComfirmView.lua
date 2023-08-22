local CWindowComfirmView = class("CWindowComfirmView", CViewBase)

CWindowComfirmView.Button = {
	Cancel = 0,
	OK = 1,
	Other = 2
}

CWindowComfirmView.Style = {
	Single = 1,
	Multiple = 2,
}

function CWindowComfirmView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/WindowComfirmView.prefab", cb)
	self.m_DepthType = "Notify"
	self.m_ExtendClose = "Black"

	self.NotNotifyType = {
		XuanShang = "XuanShang",
		YuanBaoJoy = "YuanBaoJoy",
	}
end

function CWindowComfirmView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_InfoLabel = self:NewUI(2, CLabel)
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_CancelBtn = self:NewUI(4, CButton)
	self.m_OKBtn = self:NewUI(5, CButton)
	self.m_ThirdBtn = self:NewUI(6, CButton)
	self.m_ContentBg = self:NewUI(7, CSprite)
	self.m_NotNotifyBtn = self:NewUI(8, CWidget)
	self.m_BtnWidget = self:NewUI(9, CWidget)
	self.m_BgSp = self:NewUI(10, CSprite)
	self.m_TipBox = self:NewUI(11, CWidget)
	self.m_TipBoxNode = self:NewUI(12, CWidget)
	self.m_NotNotifyBtnLbl = self:NewUI(13, CLabel)

	self.m_Buttons = {}
	self.m_Buttons[self.Button.Cancel] = self.m_CancelBtn
	self.m_Buttons[self.Button.OK] = self.m_OKBtn
	self.m_Buttons[self.Button.Other] = self.m_ThirdBtn

	self.m_ButtonTexts = {}
	self.Style = self.Style.Multiple
	self.m_ClickCancel = false
	self:InitContent()
end

function CWindowComfirmView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancelBtn"))
	self.m_OKBtn:AddUIEvent("click", callback(self, "OnOKBtn"))
	self.m_ThirdBtn:AddUIEvent("click", callback(self, "OnThirdBtn"))
	self.m_NotNotifyBtn:AddUIEvent("click", callback(self, "OnClickNotNotifyBtn"))
	self.m_TipBox:AddUIEvent("click", callback(self, "OnClickTipBoxBtn"))
end

function CWindowComfirmView.OnShowView(self)
	if Utils.IsNil(self) then
		return
	end
	local oView = CSpiritInfoView:GetView()
	if oView and oView:GetActive() then
		oView:SetActive(false)
		self.m_IsSpiritInfoViewHide = true
	end
end

function CWindowComfirmView.OnClose(self)
	self:OnCancel(self.m_IsCloseBtnSend)

	self:OnSpiritCallback()
end

function CWindowComfirmView.OnSpiritCallback(self)
	if self.m_IsSpiritInfoViewHide then
		local oView = CSpiritInfoView:GetView()
		if oView then
			oView:SetActive(true)
		end
		self.m_IsSpiritInfoViewHide = false
	end
end

function CWindowComfirmView.OnCancelBtn(self)
	self.m_ClickCancel = true
	self:OnCancel()
end

function CWindowComfirmView.OnCancel(self, bIsCloseBtnSend)
	self:Clear()
	if (self.m_CloseCallback == nil or self.m_ClickCancel) and self.m_CancelCallback then
		if bIsCloseBtnSend ~= 0 then
			self.m_CancelCallback(self)
		end
	elseif self.m_CloseCallback then
		self.m_CloseCallback()
	end
end

function CWindowComfirmView.OnOKBtn(self)
	if not self.m_Args.okButNotClose then 
		self:Clear()
	end 
	if self.m_OkCallback then
		self.m_OkCallback(self)
	end	
end

function CWindowComfirmView.OnThirdBtn(self)
	self:Clear()
	if self.m_ThirdCallback then
		self.m_ThirdCallback()
	end	
end

function CWindowComfirmView.OnClickNotNotifyBtn(self)
	
end

function CWindowComfirmView.Clear(self)
	self:StopCountdownTimer()
	CViewBase.OnClose(self)
	self:OnSpiritCallback()
end

function CWindowComfirmView.SetWindowConfirm(self, args)
	self.m_Args = args

	self.m_ContentBg:SetActive((args.hideContentBg and {false} or {true})[1])
	if args.color then
		self.m_InfoLabel:SetColor(args.color)
	end
	self.m_InfoLabel:SetPivot(args.pivot)
	self.m_TitleLabel:SetText(args.title)
	self.m_InfoLabel:SetRichText(args.msg)

	self.m_CancelCallback = args.cancelCallback
	self.m_OkCallback = args.okCallback
	self.m_CloseCallback = args.closeCallback
	self.m_ThirdCallback = args.thirdCallback

	self.m_IsCloseBtnSend = args.close_btn

	if args.alignmemt then
		self.m_InfoLabel:SetAlignment(args.alignmemt)
	end

	self.m_OKBtn:SetText(args.okStr)
	self.m_CancelBtn:SetText(args.cancelStr)
	if args.thirdStr == "" or self.m_ThirdCallback == nil then
		self.m_ThirdBtn:SetActive(false)
	else
		self.m_ThirdBtn:SetText(args.thirdStr)
	end 

	local bIsMult = true
	if args.style and args.style == CWindowComfirmView.Style.Single then
		bIsMult = false
	end
	self.m_OKBtn:SetActive(bIsMult)
	self.m_CancelBtn:SetActive(bIsMult)

	self.m_ButtonTexts[self.Button.Cancel] = args.cancelStr
	self.m_ButtonTexts[self.Button.OK] = args.okStr
	self.m_ButtonTexts[self.Button.Other] = args.thirdStr

	for k,str in pairs(self.m_ButtonTexts) do
		if string.utfStrlen(str) > 2 then
			self.m_Buttons[k].m_ChildLabel:SetSpacingX(0)
		end
	end

	self:StopCountdownTimer()
	if args.countdown > 0 then
		self.m_Buttons[args.default].m_ChildLabel:SetSpacingX(0)
		self:StartCountdownTimer()
	end

	if args.notnotifytype and not args.TipBoxCb then 
		if args.notnotifytype then
			self.m_NotNotifyBtnLbl:SetText("本次登录不再提示")
			if args.notnotifytext then
				self.m_NotNotifyBtnLbl:SetText(args.notnotifytext)
			end
			self.m_NotNotifyBtn:SetActive(true)
			self.m_NotNotifyBtn:SetSelected(false)
			self.m_BtnWidget:SetAnchor("topAnchor", -32, 0)        
			self.m_BtnWidget:ResetAndUpdateAnchors()
			self.m_BgSp:SetAnchor("bottomAnchor", 6, 0)       
			self.m_BgSp:ResetAndUpdateAnchors()
		else
			self.m_NotNotifyBtn:SetActive(false)
			self.m_BtnWidget:SetAnchor("topAnchor", 20, 0) 
			self.m_BgSp:SetAnchor("bottomAnchor", 30, 0)         
			self.m_BtnWidget:ResetAndUpdateAnchors()     
			self.m_BgSp:ResetAndUpdateAnchors()
		end	
	end 

	if args.TipBoxCb and not args.notnotifytype then 
		if args.TipBoxCb then 
			self.m_TipBoxCb = args.TipBoxCb
			self.m_TipBoxNode:SetActive(true)
			self.m_BgSp:SetAnchor("bottomAnchor", -30, 0)      
			self.m_BgSp:ResetAndUpdateAnchors()
		else
			self.m_TipBoxCb = nil
			self.m_TipBoxNode:SetActive(false)
			self.m_BgSp:SetAnchor("bottomAnchor", 30, 0)      
			self.m_BgSp:ResetAndUpdateAnchors()
		end 
	end 

end

function CWindowComfirmView.OnClickTipBoxBtn(self)

	if self.m_TipBoxCb then 
		self.m_TipBoxCb(self.m_TipBox:GetSelected())
	end 

end

function CWindowComfirmView.StartCountdownTimer(self)
	local update = function()
		if Utils.IsNil(self) then
			return false
		end

		local iCountdown = self.m_Args.countdown
		local iDefalut = self.m_Args.default

		if iCountdown > 0 then
			local str = string.format("%s(%ds)",self.m_ButtonTexts[iDefalut],iCountdown)
			self.m_Buttons[iDefalut]:SetText(str)
			iCountdown = iCountdown - 1
			self.m_Args.countdown = iCountdown
		else
			self.m_Buttons[iDefalut]:Notify(enum.UIEvent["click"])
			self:StopCountdownTimer()
		end
		return iCountdown >= 0
	end
	self.m_Timer = Utils.AddTimer(update, 1, 0)
end

function CWindowComfirmView.StopCountdownTimer(self)
	if not self.m_Timer then
		return
	end
	Utils.DelTimer(self.m_Timer)
	self.m_Timer = nil
end

return CWindowComfirmView
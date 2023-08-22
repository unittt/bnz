local CWindowNetComfirmView = class("CWindowNetComfirmView", CViewBase)

CWindowNetComfirmView.Button = {
	Cancel = 0,
	OK = 1,
	Other = 2
}

CWindowNetComfirmView.Style = {
	Single = 1,
	Multiple = 2,
}

function CWindowNetComfirmView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/WindowComfirmView.prefab", cb)
	self.m_DepthType = "BeyondGuide"
	self.m_ExtendClose = "Black"
end

function CWindowNetComfirmView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_InfoLabel = self:NewUI(2, CLabel)
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_CancelBtn = self:NewUI(4, CButton)
	self.m_OKBtn = self:NewUI(5, CButton)
	self.m_ThirdBtn = self:NewUI(6, CButton)

	self.m_Buttons = {}
	self.m_Buttons[self.Button.Cancel] = self.m_CancelBtn
	self.m_Buttons[self.Button.OK] = self.m_OKBtn
	self.m_Buttons[self.Button.Other] = self.m_ThirdBtn

	self.m_ButtonTexts = {}
	self.Style = self.Style.Multiple
	self:InitContent()
end

function CWindowNetComfirmView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancelBtn"))
	self.m_OKBtn:AddUIEvent("click", callback(self, "OnOKBtn"))
	self.m_ThirdBtn:AddUIEvent("click", callback(self, "OnThirdBtn"))
end

function CWindowNetComfirmView.OnShowView(self)
	if Utils.IsNil(self) then
		return
	end
	local oView = CSpiritInfoView:GetView()
	if oView and oView:GetActive() then
		oView:SetActive(false)
		self.m_IsSpiritInfoViewHide = true
	end
end

function CWindowNetComfirmView.OnClose(self)
	if self.m_CancelCallback then
		self.m_CancelCallback()
	end
	self:Clear()

	if self.m_IsSpiritInfoViewHide then
		local oView = CSpiritInfoView:GetView()
		if oView then
			oView:SetActive(true)
		end
		self.m_IsSpiritInfoViewHide = false
	end
end

function CWindowNetComfirmView.OnCancelBtn(self)
	self:OnClose()
end

function CWindowNetComfirmView.OnOKBtn(self)
	if self.m_OkCallback then
		self.m_OkCallback()
	end
	if not self.m_Args.isOkNotClose then
		self:Clear()
	end
end

function CWindowNetComfirmView.OnThirdBtn(self)
	if self.m_ThirdCallback then
		self.m_ThirdCallback()
	end
	self:Clear()
end

function CWindowNetComfirmView.Clear(self)
	self:StopCountdownTimer()
	CViewBase.OnClose(self)
end

function CWindowNetComfirmView.SetWindowConfirm(self, args)
	self.m_Args = args

	if args.color then
		self.m_InfoLabel:SetColor(args.color)
	end
	self.m_InfoLabel:SetPivot(args.pivot)
	self.m_TitleLabel:SetText(args.title)
	self.m_InfoLabel:SetRichText(args.msg)

	self.m_CancelCallback = args.cancelCallback
	self.m_OkCallback = args.okCallback
	self.m_ThirdCallback = args.thirdCallback

	self.m_OKBtn:SetText(args.okStr)
	self.m_CancelBtn:SetText(args.cancelStr)
	if args.thirdStr == "" or self.m_ThirdCallback == nil then
		self.m_ThirdBtn:SetActive(false)
	else
		self.m_ThirdBtn:SetText(args.thirdStr)
	end 

	local bIsMult = true
	if args.style and args.style == CWindowNetComfirmView.Style.Single then
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

	if args.countdown > 0 then
		self.m_Buttons[args.default].m_ChildLabel:SetSpacingX(0)
		self:StartCountdownTimer()
	end
end

function CWindowNetComfirmView.StartCountdownTimer(self)
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

function CWindowNetComfirmView.StopCountdownTimer(self)
	if not self.m_Timer then
		return
	end
	Utils.DelTimer(self.m_Timer)
	self.m_Timer = nil
end
return CWindowNetComfirmView
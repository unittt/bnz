local CFeedbackMainView = class("CFeedbackMainView", CViewBase)

function CFeedbackMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Feedback/FeedbackMainView.prefab", cb)
	self.m_GroupName = "main"
    self.m_ExtendClose = "Black"

    self.m_SelectIdx = 1  --1.联系客服、2,官方消息
end

function CFeedbackMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TabBtnGrid = self:NewUI(2, CGrid)

	self.m_ContactPage = self:NewPage(3, CContactPage)
	self.m_GeneralInfoPage = self:NewPage(4, CGeneralInfoPage)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_OpenSysCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOpenSysEvent"))

	self:RefreshUI()
end

function CFeedbackMainView.RefreshUI(self)
	local bFeedbackOpen = g_OpenSysCtrl:GetOpenSysState("FEEDBACK") and g_FeedbackCtrl.m_bFeedbackOpen
	local bFeedbackInfoOpen = g_OpenSysCtrl:GetOpenSysState("FEEDBACKINFO") and g_FeedbackCtrl.m_bFeedbackInfoOpen

	if bFeedbackOpen and bFeedbackInfoOpen then
		local groupId = self.m_TabBtnGrid:GetInstanceID()
		local function Init(obj, idx)
			local oBtn = CButton.New(obj, false)
			oBtn:SetGroup(groupId)
			oBtn:AddUIEvent("click", callback(self, "OnTabSelect", idx))
			return oBtn  
		end
		self.m_TabBtnGrid:InitChild(Init)
		self.m_TabBtnGrid:GetChild(self.m_SelectIdx):SetSelected(true)
		self:ShowSubPageByIndex(self.m_SelectIdx)
	else
		self.m_TabBtnGrid:SetActive(false)
		if bFeedbackOpen then
			self:ShowSubPageByIndex(1) --反馈交流
		elseif bFeedbackInfoOpen then
			self:ShowSubPageByIndex(2) --官方信息
		else
			self:CloseView()
		end
	end
end

function CFeedbackMainView.OnTabSelect(self, idx)
	if self.m_SelectIdx == idx then
		return
	end
	self.m_SelectIdx = idx
	self:ShowSubPageByIndex(self.m_SelectIdx)
end

function CFeedbackMainView.OnOpenSysEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SysOpen.Event.Change then
		self:RefreshUI()
	end
end

return CFeedbackMainView
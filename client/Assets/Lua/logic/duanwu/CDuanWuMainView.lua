local CDuanWuMainView = class("CDuanWuMainView", CViewBase)

function CDuanWuMainView.ctor(self, cb)

	CViewBase.ctor(self, "UI/DuanWu/DuanWuMainView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"

end

function CDuanWuMainView.OnCreateView(self)

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_QiFuPart = self:NewPage(2, CDuanWuQiFuPart)
	self.m_MatchPart = self:NewPage(3, CDuanWuMatchPart)
	self.m_QiFuBtn = self:NewUI(4, CButton)
	self.m_MatchBtn = self:NewUI(5, CButton)
	self.m_SelectIndex = 1

	self:InitContent()

end

function CDuanWuMainView.InitContent(self)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_DuanWuHuodongCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))
	self.m_QiFuBtn:AddUIEvent("click", callback(self, "ShowSubPageByIndex", 1))
	self.m_MatchBtn:AddUIEvent("click",  callback(self, "ShowSubPageByIndex", 2))

	local index = 1
	local isMatchOpen = g_DuanWuHuodongCtrl:IsMatchHuodongOpen()
	local isQiFuOpen = g_DuanWuHuodongCtrl:IsQiFuHuoDongOpen()
	self.m_QiFuBtn:SetActive(isQiFuOpen)
	self.m_MatchBtn:SetActive(isMatchOpen)
	if isQiFuOpen and isMatchOpen then 
		index = 1
		self.m_QiFuBtn:SetSelected(true)
		self.m_MatchBtn:SetSelected(false)
	elseif isQiFuOpen then 
		index = 1
		self.m_QiFuBtn:SetSelected(true)
		self.m_MatchBtn:SetSelected(false)
	elseif isMatchOpen then 
		index = 2
		self.m_QiFuBtn:SetSelected(false)
		self.m_MatchBtn:SetSelected(true)
	end 
	self:ShowSubPageByIndex(index)

end 
function CDuanWuMainView.ShowSubPageByIndex(self, tabIndex)

	CGameObjContainer.ShowSubPageByIndex(self, tabIndex)

end

function CDuanWuMainView.OpenQiFuView(self)

	self.m_QiFuBtn:SetSelected(true)
	self:ShowSubPageByIndex(1)

end

function CDuanWuMainView.OpenMatchView(self)

	self.m_MatchBtn:SetSelected(true)
	self:ShowSubPageByIndex(1)

end

function CDuanWuMainView.OnEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.DuanWuHuodong.Event.MatchState or oCtrl.m_EventID == define.DuanWuHuodong.Event.QiFuState then
		local isMatchOpen = g_DuanWuHuodongCtrl:IsMatchHuodongOpen()
		local isQiFuOpen = g_DuanWuHuodongCtrl:IsQiFuHuoDongOpen()
		if not isMatchOpen or not isQiFuOpen then 
			self:OnClose()
		end
	end 

end

return CDuanWuMainView
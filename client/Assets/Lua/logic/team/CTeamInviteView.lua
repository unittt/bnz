local CTeamInviteView = class("CTeamInviteView", CViewBase)

function CTeamInviteView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamInviteView.prefab", cb)

	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CTeamInviteView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_InviteGrid = self:NewUI(2, CGrid)
	self.m_InviteBox = self:NewUI(3, CTeamInviteBox)
	self.m_CntLabel = self:NewUI(4, CLabel)
	self.m_ClearBtn = self:NewUI(5, CButton)

	self.m_CurIndex = 0
	self.m_ShowLimit = 20
	self.m_ClickRecord = {}

	self:InitContent()
end

function CTeamInviteView.InitContent(self)
	self.m_InviteBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ClearBtn:AddUIEvent("click", callback(self, "ClearAll"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_TeamCtrl:ReadInvite()
	-- self:RefreshInvite()
	self:RefreshInviteGrid()
end

function CTeamInviteView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.ClearInvite then
		self:ClearAll()
	elseif oCtrl.m_EventID == define.Team.Event.DelInvite then
		self:RefreshInviteGrid()
	elseif oCtrl.m_EventID == define.Team.Event.AddInvite then
		self:RefreshInviteGrid()
	end
end

function CTeamInviteView.ClearAll(self)
	netteam.C2GSClearInvite()
	self:CloseView()
end

function CTeamInviteView.RefreshInviteGrid(self)
	self.m_InviteList = g_TeamCtrl:GetInviteList()
	local iInviteCnt = #self.m_InviteList
	local iGridCnt = self.m_InviteGrid:GetCount()
	local iMax = math.max(iGridCnt, iInviteCnt)

	for i=1, iMax do
		local oBox = self.m_InviteGrid:GetChild(i)
		local dInvite = self.m_InviteList[i]
		if not oBox then
			oBox = self:CreateInviteBox()
			self.m_InviteGrid:AddChild(oBox)
		end
		if dInvite then
			self:UpdateInvite(oBox, dInvite)
		else
			oBox:SetActive(false)
		end
	end
	self.m_CntLabel:SetText(iInviteCnt)
	if iInviteCnt == 0 then
		self:CloseView()
	end
end

function CTeamInviteView.CreateInviteBox(self)
	local oBox = self.m_InviteBox:Clone()
	return oBox
end

function CTeamInviteView.UpdateInvite(self, oBox, dInvite)
	oBox:SetInvite(dInvite, self.m_ClickRecord[dInvite.teamid])
	oBox:SetClickCallback()
	oBox:SetActive(true)
end

function CTeamInviteView.UpdateRecord(self, iTeamId)
	self.m_ClickRecord[iTeamId] = true
end

return CTeamInviteView
local CTeamMainView = class("CTeamMainView", CViewBase)

function CTeamMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CTeamMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_MainPart = self:NewPage(2, CTeamMainPart)
	self.m_ApplyPart = self:NewPage(3, CTeamApplyPart)
	self.m_TabGrid = self:NewUI(4, CTabGrid)

	g_TeamCtrl:ClearUIData()
	self:InitContent()
end

function CTeamMainView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamEvent"))

	self.m_TabGrid:InitChild(function(obj, idx)
		local oBtn = CButton.New(obj)
		oBtn:SetGroup(self:GetInstanceID())
		return oBtn
	end)

	local list = self.m_TabGrid:GetChildList()
	for i,oBtn in ipairs(list) do
		if i == 1 then
			oBtn:SetSelected(true)
		end
		oBtn:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i))
	end
	self:ShowSubPageByIndex(1)
	self:RefreshRedPoint()
end

function CTeamMainView.CloseView(self)
	if g_WarCtrl:IsWar() and (g_TeamCtrl.m_IsPartnerChanged or g_TeamCtrl.m_IsPlayerChanged) then
		g_NotifyCtrl:FloatMsg("战斗结束后生效")
	end
	CViewBase.CloseView(self)
end

function CTeamMainView.OnTeamEvent(self, oCtrl)
	if  oCtrl.m_EventID == define.Team.Event.NotifyApply or
		oCtrl.m_EventID == define.Team.Event.ClearApply or
		oCtrl.m_EventID == define.Team.Event.AddTeam then
		self:RefreshRedPoint()
	end
end

function CTeamMainView.RefreshRedPoint(self)
	local bIsApply = g_TeamCtrl:IsJoinTeam() and table.count(g_TeamCtrl.m_UnreadApply) > 0 and g_TeamCtrl:IsLeader(g_AttrCtrl.pid)
	local oTab = self.m_TabGrid:GetChild(self:GetPageIndex("Apply"))
	if bIsApply then
		-- self.m_BtnGrid:GetChild(2).m_IgnoreCheckEffect = true
        oTab:AddEffect("RedDot", 20, Vector2(-13, -17))
    else
       	oTab:DelEffect("RedDot")
	end
end

function CTeamMainView.ShowSubPageByIndex(self, iTab)
	if iTab == 2 and not g_TeamCtrl:IsJoinTeam() then
		g_NotifyCtrl:FloatMsg("你尚未创建队伍")
		self:ShowSubPageByIndex(1)
		return
	end
	printc("")
	self.m_TabGrid:GetChild(iTab):SetSelected(true)
	self.m_CurTabIndex = iTab
	CGameObjContainer.ShowSubPageByIndex(self, iTab)
end

return CTeamMainView
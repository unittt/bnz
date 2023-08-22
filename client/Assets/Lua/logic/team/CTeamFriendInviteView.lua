local CTeamFriendInviteView = class("CTeamFriendInviteView", CViewBase)

function CTeamFriendInviteView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamFriendInviteView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CTeamFriendInviteView.OnCreateView(self)
	self.m_FriendTab = self:NewUI(1, CButton)
	self.m_OrgTab = self:NewUI(2, CButton)
	self.m_PlayerGrid = self:NewUI(3, CGrid)
	self.m_BoxClone = self:NewUI(4, CBox)
	self.m_ScrollView = self:NewUI(5, CScrollView)
	self.m_CloseBtn = self:NewUI(6, CButton)
	self.m_EmptyObj = self:NewUI(7, CObject)

	self.m_Type = {
		Friend = 1,
		Org = 2,
	}
	self.m_CurType = 0
	self.m_BoxDict = {}
	self.m_LoadTimer = nil
	self.m_InviteRecords = {}

	self:InitContent()
end

function CTeamFriendInviteView.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_FriendTab:AddUIEvent("click", callback(self, "ChangeTab", self.m_Type.Friend))
	self.m_OrgTab:AddUIEvent("click", callback(self, "ChangeTab", self.m_Type.Org))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamCtrlEvent"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgCtrlEvent"))
	self.m_FriendTab:SetSelected(true)
	self:ChangeTab(self.m_Type.Friend)
	self:RequestOrgOnlineMember()
end

function CTeamFriendInviteView.OnTeamCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.RefreshInviteeStatus then
		self:RefreshInviteeStatus(oCtrl.m_EventData.pid, oCtrl.m_EventData.status)
	end
end

function CTeamFriendInviteView.OnOrgCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.UpdateOnlineMember then
		if self.m_CurType == self.m_Type.Org then
			self:RefreshAll()
		end
	end
end

function CTeamFriendInviteView.RequestOrgOnlineMember(self)
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.TeamUpdateInvite, g_AttrCtrl.pid) then
		return
	end
	netorg.C2GSGetOnlineMember()
	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.TeamUpdateInvite, g_AttrCtrl.pid, 100)
end

function CTeamFriendInviteView.RefreshAll(self)
	self:InitInviteList()
	self:RefreshGrid()
end

function CTeamFriendInviteView.InitInviteList(self)
	self.m_PlayerList = nil
	if self.m_CurType == self.m_Type.Friend then
		self.m_PlayerList = g_FriendCtrl:GetOnlineFriendList()
	else
		self.m_PlayerList = g_OrgCtrl:GetOnlineMemberList()
	end
end

function CTeamFriendInviteView.RefreshGrid(self)
	-- printc("refresh")
	if self.m_LoadTimer then
		Utils.DelTimer(self.m_LoadTimer)
		self.m_LoadTimer = nil
	end
	self.m_ScrollView:ResetPosition()
	self.m_PlayerGrid:Clear()
	if not self.m_PlayerList then
		printerror("not found")
		return
	end
	local iIndex = 1
	local iCount = #self.m_PlayerList
	local bIsEmpty = true
	local function LoadPlayer()
		if Utils.IsNil(self) then
			return false
		end

		local iLastIndex = iIndex + 10
		for i = iIndex, iLastIndex do
			local tPlayer = self.m_PlayerList[i]
			if tPlayer and not g_TeamCtrl:IsTeamMember(tPlayer.pid) and
				(not self.m_InviteRecords[tPlayer.pid] or self.m_InviteRecords[tPlayer.pid] == 0) then
				self:AddPlayerBox(tPlayer)
				bIsEmpty = false
				self.m_ScrollView:SetActive(true)
				self.m_EmptyObj:SetActive(false)
			end
			if iIndex >= iCount then
				self.m_ScrollView:SetActive(not bIsEmpty)
				self.m_EmptyObj:SetActive(bIsEmpty)
				return false
			end
			iIndex = iIndex + 1
		end
		return true
	end
	self.m_LoadTimer = Utils.AddTimer(LoadPlayer, 1/30, 0)
end

function CTeamFriendInviteView.AddPlayerBox(self, tPlayer)
	local oBox = self.m_BoxClone:Clone()
	oBox.m_Player = tPlayer
	oBox.m_SchoolSpr = oBox:NewUI(1, CSprite)
	oBox.m_AvatarSpr = oBox:NewUI(2, CSprite)
	oBox.m_GradeLabel = oBox:NewUI(3, CLabel)
	oBox.m_NameLabel = oBox:NewUI(4, CLabel)
	oBox.m_SchoolLabel = oBox:NewUI(5, CLabel)
	oBox.m_InviteBtn = oBox:NewUI(6, CButton)

	oBox:SetActive(true)
	oBox.m_InviteBtn:AddUIEvent("click", callback(self, "OnClickCInivte", tPlayer.pid))
	self:UpdatePlayerBox(oBox, tPlayer)
	self.m_PlayerGrid:AddChild(oBox)
	self.m_PlayerGrid:Reposition()
	self.m_BoxDict[tPlayer.pid] = oBox
	if self.m_InviteRecords[tPlayer.pid] then
		self:RefreshInviteeStatus(tPlayer.pid, self.m_InviteRecords[tPlayer.pid])
	end
end

function CTeamFriendInviteView.UpdatePlayerBox(self, oBox, tPlayer)
	local sSchoolName = data.schooldata.DATA[tPlayer.school].name
	oBox.m_NameLabel:SetText(tPlayer.name)
	oBox.m_GradeLabel:SetText(tPlayer.grade.."级")
	oBox.m_SchoolLabel:SetText(sSchoolName)
	oBox.m_SchoolSpr:SpriteSchool(tPlayer.school)
	local icon = tPlayer.icon
	oBox.m_AvatarSpr:SpriteAvatar(icon)
end

function CTeamFriendInviteView.RefreshInviteeStatus(self, iPid, iStatus)
	local oBox = self.m_BoxDict[iPid]
	if not oBox then
		return
	end
	if iStatus == 0 then
		oBox.m_InviteBtn:SetText("已邀请")
		oBox.m_InviteBtn:EnableTouch(false)
		oBox.m_InviteBtn:SetEnabled(false)
		oBox.m_InviteBtn:SetGrey(true)
	else 
		self.m_PlayerGrid:RemoveChild(oBox)
		self.m_PlayerGrid:Reposition()
	end
	self.m_InviteRecords[iPid] = iStatus
end

function CTeamFriendInviteView.ChangeTab(self, iTab)
	-- if oTab:GetSelected() then
	-- 	return
	-- end
	-- oTab:SetSelected(true)
	self.m_CurType = iTab--self.m_CurType%2 + 1
	self:RefreshAll()
end

function CTeamFriendInviteView.OnClickCInivte(self, iPid)
	netteam.C2GSInviteTeam(iPid)
end

return CTeamFriendInviteView
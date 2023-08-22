local CTeamMemberBox = class("CTeamMemberBox", CBox)

function CTeamMemberBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_SchoolSpr = self:NewUI(3, CSprite)
	self.m_GradeLabel = self:NewUI(4, CLabel)
	self.m_StatusSpr = self:NewUI(5, CSprite)
	self.m_LeaderSpr = self:NewUI(6, CSprite)
	self.m_AppointLabel = self:NewUI(7, CLabel)
	self.m_LocWidget = self:NewUI(8, CWidget)
	self.m_SignSpr = self:NewUI(9, CWidget)
	self.m_AppointWidget = self:NewUI(10, CWidget)
	self.m_RelationLabel = self:NewUI(11, CLabel)
	self.m_EffectBoxs = {
		self:NewUI(12, CBox),
		self:NewUI(13, CBox)
	}
	self.m_SwitchBtn = self:NewUI(14, CSprite)
	self.m_AppointFlagSpr = self:NewUI(15, CLabel)

	self.m_AppointStatus = {
		Cancel = 0,
		Appoint = 1
	}
	self.m_CurStatus = self.m_AppointStatus.Cancel

	self.m_Member = nil
	self:InitContent()
end

function CTeamMemberBox.InitContent(self)
	self:InitEffectBox()
	self.m_AppointWidget:AddUIEvent("click", callback(self, "OnClickAppoint"))
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnClickSwitchPos"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CTeamMemberBox.InitEffectBox(self)
	for i,oBox in ipairs(self.m_EffectBoxs) do
		oBox.m_EffectL = oBox:NewUI(1, CLabel)
		oBox.m_ArrowSpr = oBox:NewUI(2, CSprite)
	end
end

function CTeamMemberBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.RefreshAppoint then
		self:RefreshAppoint()
		self:RefreshAppointFlag()
	end
end

function CTeamMemberBox.SetFormationEffect(self, tEffectInfo)
	self.m_EffectBoxs[1]:SetActive(false)
	self.m_EffectBoxs[2]:SetActive(false)
	if not tEffectInfo or (g_TeamCtrl:IsJoinTeam(self.m_Pid) and
		 not g_TeamCtrl:IsInTeam(self.m_Pid)) then 
		return
	end
	for i,dInfo in ipairs(tEffectInfo) do
		local oBox = self.m_EffectBoxs[i]
		oBox:SetActive(true)
		oBox.m_EffectL:SetText(dInfo.name)
		if dInfo.value >= 0 then
			oBox.m_ArrowSpr:SetSpriteName("h7_sheng")
		else
			oBox.m_ArrowSpr:SetSpriteName("h7_jiang")
		end
	end
end

function CTeamMemberBox.SetMember(self, dMember, iDelay)
	local pid = dMember.pid
	self.m_Pid = pid
	self.m_Member = dMember
	self.m_LeaderSpr:SetActive(g_TeamCtrl:IsLeader(pid))
	self.m_NameLabel:SetText(dMember.name)
	self.m_GradeLabel:SetText("等级:"..tostring(dMember.grade))
	if g_TeamCtrl:IsLeave(pid) then
		self.m_StatusSpr:SetActive(true)
		self.m_StatusSpr:SetSpriteName("h7_zanli")
	elseif g_TeamCtrl:IsOffline(pid) then
		self.m_StatusSpr:SetActive(true)
		self.m_StatusSpr:SetSpriteName("h7_lixian")
	else
		self.m_StatusSpr:SetActive(false)
	end
	self:RefreshRelationLabel()
	self.m_SchoolSpr:SpriteSchool(dMember.school)
	-- self.m_ActorTexture:ChangeShape(dMember.model_info.shape, dMember.model_info)
	if self.m_LoadTimer then
		Utils.DelTimer(self.m_LoadTimer)
		self.m_LoadTimer = nil
	end
	local function loadShape()
		if not Utils.IsNil(self) then
			local dInfo = table.copy(dMember.model_info)
			dInfo.horse = nil
			self.m_ActorTexture:ChangeShape(dInfo)
		end
	end
	self.m_LoadTimer = Utils.AddTimer(loadShape, 0, iDelay)
	--TODO:策划争议，是否在自己的名字下加选定框
	-- self.m_SignSpr:SetActive(dMember.pid == g_AttrCtrl.pid)
	self.m_SignSpr:SetActive(false)
	if dMember.pid == g_AttrCtrl.pid then
		self.m_NameLabel:SetColor(Color.RGBAToColor("A84D0D"))
	else
		self.m_NameLabel:SetColor(Color.RGBAToColor("244B4E"))
	end
	self:RefreshAppointFlag()
end

function CTeamMemberBox.RefreshAppointFlag(self)
	self.m_AppointFlagSpr:SetActive(g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsCommander(self.m_Pid))
end

function CTeamMemberBox.RefreshRelationLabel(self)
	if g_AttrCtrl.pid == self.m_Member.pid then
		self.m_RelationLabel:SetActive(false)
		return
	end
	self.m_RelationLabel:SetActive(true)
	if g_FriendCtrl:IsMyFriend(self.m_Pid) then
		self.m_RelationLabel:SetText("[c]#D好友#n")
	elseif g_AttrCtrl.org_id ~= 0 and g_AttrCtrl.org_id == self.m_Member.orgid then
		self.m_RelationLabel:SetText("[c]#P同帮#n")
	else
		self.m_RelationLabel:SetActive(false)
	end
end

function CTeamMemberBox.RefreshAppoint(self)
	if g_TeamCtrl:IsCommander(self.m_Pid) then
		self.m_AppointLabel:SetText("取消\n战斗指挥")
		self.m_CurStatus = self.m_AppointStatus.Cancel
	else
		self.m_AppointLabel:SetText("委任\n战斗指挥")
		self.m_CurStatus = self.m_AppointStatus.Appoint
	end
end

function CTeamMemberBox.ShowAppointPanel(self)
	if g_TeamCtrl:IsLeader(self.m_Pid) then
		return
	end
	self:RefreshAppoint()
	self.m_AppointLabel:SetActive(true)
end

function CTeamMemberBox.HideAppointPanel(self)
	self.m_AppointLabel:SetActive(false)
end

function CTeamMemberBox.OnClickAppoint(self)
	if g_TeamCtrl:IsLeave(self.m_Pid) or g_TeamCtrl:IsOffline(self.m_Pid) then
		g_NotifyCtrl:FloatMsg("只能委任归队队员")
		return
	end
	netteam.C2GSSetAppointMem(self.m_Pid, self.m_CurStatus)
end

function CTeamMemberBox.ShowSwitchPanel(self)
	self.m_SwitchBtn:SetActive(false)
	if g_TeamCtrl:IsLeader(self.m_Pid) or g_TeamCtrl.m_SelectedPid == self.m_Pid or 
		(g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsInTeam(self.m_Pid)) then
		return false
	end
	self.m_SwitchBtn:SetActive(true)
	return true
end

function CTeamMemberBox.HideSwitchPanel(self)
	self.m_SwitchBtn:SetActive(false)
end

function CTeamMemberBox.OnClickSwitchPos(self)
	local tPlayerPosList = g_TeamCtrl.m_PlayerPosList
	local tPartnerPosList = g_TeamCtrl.m_PartnerPosList
	local iSelectedPid = g_TeamCtrl.m_SelectedPid
	local iFmtId = g_TeamCtrl:GetFormationInfo().fmt_id

	if g_WarCtrl:IsWar() then
		if not g_TeamCtrl.m_OriginalPos["player"] then
			g_TeamCtrl.m_OriginalPos["player"] = table.copy(tPlayerPosList)
		end
	end

	for i,pid in ipairs(tPlayerPosList) do
		if pid == iSelectedPid then
			tPlayerPosList[i] = self.m_Pid
		elseif pid == self.m_Pid then
			tPlayerPosList[i] = iSelectedPid
		end
	end
	netformation.C2GSSetPlayerPosInfo(iFmtId, tPlayerPosList, tPartnerPosList)

	if g_WarCtrl:IsWar() then
		g_TeamCtrl.m_IsPlayerChanged = false
		for i,pid in ipairs(g_TeamCtrl.m_OriginalPos["player"]) do
			if pid ~= tPlayerPosList[i] then
				g_TeamCtrl.m_IsPlayerChanged = true
				break
			end
		end
	end
end

return CTeamMemberBox
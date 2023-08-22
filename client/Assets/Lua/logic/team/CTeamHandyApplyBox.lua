local CTeamHandyApplyBox = class("CTeamHandyApplyBox", CBox)

function CTeamHandyApplyBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_TargetLabel = self:NewUI(1, CLabel)
	self.m_MemberGrid = self:NewUI(2, CGrid)
	self.m_HandyApplyBtn = self:NewUI(3, CButton)
	self.m_TeamID = -1
	self.m_LeaderID = -1
	self.m_TargetID = 0
	self.m_ApplyStatus = false
	self.m_Callback = nil

	self.m_Status = {
		None = 0,
		Applying = 1,
		-- TeamFull = 2,
		-- ApplyFull = 3
	}
	self:InitContent()
end

function CTeamHandyApplyBox.SetCallback(self, cb)
	self.m_Callback = cb
end

function CTeamHandyApplyBox.InitContent(self)
	self.m_HandyApplyBtn:AddUIEvent("click", callback(self, "OnHandyApply"))
	local function initbox(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_SchoolSpr = oBox:NewUI(1, CSprite)
		oBox.m_AvatarSpr = oBox:NewUI(2, CSprite)
		oBox.m_GradeLabel = oBox:NewUI(3, CLabel)
		oBox.m_NameLabel = oBox:NewUI(4, CLabel)
		return oBox
	end
	self.m_MemberGrid:InitChild(initbox)
end

function CTeamHandyApplyBox.SetHandyApply(self, dTargetTeam)
	self.m_TeamID = dTargetTeam.teamid
	self.m_LeaderID = dTargetTeam.leader
	local tTargetInfo = dTargetTeam.target_info
	if tTargetInfo then
		self.m_AutoTeamData = data.teamdata.AUTO_TEAM[tTargetInfo.auto_target]
	end

	self:RefreshMemberGrid(dTargetTeam)
	self:RefreshTargetDesc(dTargetTeam)
	self:RefreshButtonStatus(dTargetTeam.status)
end

function CTeamHandyApplyBox.SetTargetID(self, iTargetId)
	self.m_TargetID = iTargetId
end

function CTeamHandyApplyBox.RefreshMemberGrid(self, dTargetTeam)
	for i, oBox in ipairs(self.m_MemberGrid:GetChildList()) do
		local dMember = dTargetTeam.member[i]
		if dMember then
			local tStatusInfo = dMember.status_info
			oBox.m_AvatarSpr:SpriteAvatar(tStatusInfo.icon)
			oBox.m_AvatarSpr:AddUIEvent("click", callback(self, "ShowPlayerTip", dMember.pid))
			oBox.m_SchoolSpr:SpriteSchool(tStatusInfo.school)
			oBox.m_GradeLabel:SetText(tostring(tStatusInfo.grade).."级")
			oBox.m_NameLabel:SetText(tStatusInfo.name)
		end
		oBox.m_AvatarSpr:SetActive(dMember~=nil)
		oBox.m_SchoolSpr:SetActive(dMember~=nil)
		oBox.m_GradeLabel:SetActive(dMember~=nil)
		oBox.m_NameLabel:SetActive(dMember~=nil)
		oBox:SetActive(true)
		if self.m_AutoTeamData and self.m_AutoTeamData.id ~= CTeamCtrl.TARGET_NONE and
			i > self.m_AutoTeamData.max_count then
			oBox:SetActive(false)
		end
	end
end

function CTeamHandyApplyBox.RefreshTargetDesc(self, dTargetTeam)
	local tTargetInfo = dTargetTeam.target_info
	local sDesc = ""
	if self.m_AutoTeamData then
		sDesc = string.format("目标：%s（%d-%d）级",self.m_AutoTeamData.name, tTargetInfo.min_grade, tTargetInfo.max_grade)
	end
	self.m_TargetLabel:SetText(sDesc)
end

function CTeamHandyApplyBox.RefreshButtonStatus(self, iStatus)
	self.m_HandyApplyBtn:SetGrey(false)
	if iStatus == self.m_Status.Applying then
		self.m_HandyApplyBtn:SetText("取消")
	elseif iStatus == self.m_Status.None then
		self.m_HandyApplyBtn:SetText("申请")
	end
	self.m_ApplyStatus = iStatus
end

function CTeamHandyApplyBox.OnHandyApply(self)
	if not g_MapCtrl:IsTeamAllowed() then
		g_NotifyCtrl:FloatMsg("当前场景禁止组队")
		return
	end
	local iTarget = self.m_TargetID
	if self.m_ApplyStatus == self.m_Status.Applying then
		netteam.C2GSCancelApply(self.m_TeamID, iTarget, 1)
	elseif self.m_ApplyStatus == self.m_Status.None then
		if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.TeamApply, self.m_TeamID) then
			g_NotifyCtrl:FloatMsg("申请太频繁，请稍后再试")
			return
		end
		netteam.C2GSApplyTeam(self.m_TeamID, iTarget, 1)
		g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.TeamApply, self.m_TeamID, 10)
	end
	if self.m_Callback then
		self.m_Callback()
	end
end

function CTeamHandyApplyBox.ShowPlayerTip(self, iPid)
	netplayer.C2GSGetPlayerInfo(iPid)
end

return CTeamHandyApplyBox
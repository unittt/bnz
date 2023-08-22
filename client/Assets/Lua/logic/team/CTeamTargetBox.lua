local CTeamTargetBox = class("CTeamTargetBox", CBox)

function CTeamTargetBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_TargetChangeBtn = self:NewUI(1, CButton, true, false)
	self.m_StatusBtn = {
		leader_auto = self:NewUI(2, CButton, true, false),
		leader_not_auto = self:NewUI(3, CButton, true, false),
		member_auto = self:NewUI(4, CButton, true, false),
		member_not_auto = self:NewUI(5, CButton, true, false)
	} 
	self:InitContent()
end

function CTeamTargetBox.InitContent(self)
	self.m_TargetChangeBtn:AddUIEvent("click", callback(self, "OnClickTargetChange"))
	for k,btn in pairs(self.m_StatusBtn) do
		btn:AddUIEvent("click", callback(self, "OnClickAutoTeam"))
	end
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamCtrlEvent"))
end

function CTeamTargetBox.OnTeamCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch then
		self:RefreshButtonStatus()
		-- if not g_TeamCtrl:IsLeader() then		--TODO:忘记是为什么要判断了
		if g_TeamCtrl:IsPlayerAutoMatch() then
			local tTargetInfo = {
				auto_target = g_TeamCtrl:GetPlayerAutoTarget(),
				min_grade = -1,
				max_grade = -1}
			self:RefreshTargetBtton(tTargetInfo)
		else
			self:RefreshTargetBtton(g_TeamCtrl:GetTargetInfo())
		end
	end
end

function CTeamTargetBox.RefreshButtonStatus(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsTeamAutoMatch = g_TeamCtrl:IsTeamAutoMatch()
	local bIsPlayerAutoMatch = g_TeamCtrl:IsPlayerAutoMatch()
	local bIsLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)
	local dTargetInfo = g_TeamCtrl:GetTargetInfo()
	local bIsDefaultTask = dTargetInfo.auto_target == g_TeamCtrl.TARGET_NONE

	-- 目标为无时隐藏所有操作按钮
	-- if bIsDefaultTask then
	-- 	for _,btn in pairs(self.m_StatusBtn) do
	-- 		btn:SetActive(false)
	-- 	end
	-- 	return
	-- end
	local bRequirement1 = bIsJoinTeam and not bIsTeamAutoMatch and not bIsPlayerAutoMatch
	-- local bRequirement2 = bIsJoinTeam and not bIsLeader
	self.m_StatusBtn.leader_auto:SetActive(bRequirement1)
	self.m_StatusBtn.leader_not_auto:SetActive((bIsLeader and bIsTeamAutoMatch) or bIsPlayerAutoMatch)
	self.m_StatusBtn.member_auto:SetActive(not bIsLeader and bIsTeamAutoMatch and not bIsPlayerAutoMatch)
	self.m_StatusBtn.member_not_auto:SetActive(false)
	
	-- self.m_StatusBtn.leader_auto:SetActive(bIsLeader and not bIsTeamAutoMatch and not bIsPlayerAutoMatch)
	-- self.m_StatusBtn.leader_not_auto:SetActive((bIsLeader and bIsTeamAutoMatch) or bIsPlayerAutoMatch)
	-- self.m_StatusBtn.member_auto:SetActive(not bIsLeader and bIsTeamAutoMatch and not bIsPlayerAutoMatch)
	-- self.m_StatusBtn.member_not_auto:SetActive(not bIsLeader and not bIsTeamAutoMatch and not bIsPlayerAutoMatch)
end

function CTeamTargetBox.RefreshTargetBtton(self, dAutoInfo)
	if next(dAutoInfo) == nil then
		return
	end
	local sTarget = "无"
	local tData = data.teamdata.AUTO_TEAM[dAutoInfo.auto_target]
	if tData then
		sTarget = tData.name
	end
	
	local sDesc = ""
	if dAutoInfo.min_grade < 0 then
		sDesc = string.format("%s-便捷组队中...", sTarget)
		self.m_TargetChangeBtn:SetSpriteName("h7_bg_5")
	else
		sDesc = string.format("目标：%s（%d-%d）级", sTarget, dAutoInfo.min_grade, dAutoInfo.max_grade)
		self.m_TargetChangeBtn:SetSpriteName("h7_xinxikuang")
	end
	self.m_TargetChangeBtn:SetText(sDesc)
end

function CTeamTargetBox.OnClickTargetChange(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsPlayerAutoMatch = g_TeamCtrl:IsPlayerAutoMatch()
	local bIsLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)

	if bIsJoinTeam and not bIsLeader then
		g_NotifyCtrl:FloatMsg("只有队长才可以设置哦")
		return
	end

	if bIsLeader then
		CTeamFilterView:ShowView(function(oView)
			oView:SetListener(callback(self, "OnTargetChange"))
		end)
	else
		CTeamHandyBuildView:ShowView()
	end
end

function CTeamTargetBox.OnClickAutoTeam(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsTeamAutoMatch = g_TeamCtrl:IsTeamAutoMatch()
	local bIsPlayerAutoMatch = g_TeamCtrl:IsPlayerAutoMatch()
	local bIsLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)
	local dTargetInfo = g_TeamCtrl:GetTargetInfo()
	local bIsDefaultTask = dTargetInfo.auto_target == g_TeamCtrl.TARGET_NONE

	if bIsPlayerAutoMatch then
		netteam.C2GSPlayerCancelAutoMatch()
		return
	end

	if bIsJoinTeam and not bIsLeader then
		g_NotifyCtrl:FloatMsg("只有队长才可以设置哦")
		return
	end

	if bIsDefaultTask then
		g_NotifyCtrl:FloatMsg("请先调整目标")
		CTeamFilterView:ShowView(function(oView)
			oView:SetListener(callback(self, "OnTargetChange"))
		end)
		return
	end

	if bIsTeamAutoMatch then
		-- TODO:取消自动匹配
		netteam.C2GSTeamCancelAutoMatch()
	else
		-- TODO:请求自动匹配
		local dAutoInfo = g_TeamCtrl:GetLocalTargetInfo()
		local tData = data.teamdata.AUTO_TEAM[dAutoInfo.auto_target]
		if g_TeamCtrl:GetMemberSize() >= tData.max_count then
			g_NotifyCtrl:FloatMsg("队伍人数已满,无法自动匹配")
			return
		end
		netteam.C2GSTeamAutoMatch(dAutoInfo.auto_target, dAutoInfo.min_grade, dAutoInfo.max_grade, 1)
	end 
end

function CTeamTargetBox.OnTargetChange(self, view)
	local iTaskId,iLowerLv,iUpperLv = view:GetTeamFilterInfo()	
	local tAutoInfo = {
		auto_target = iTaskId,
		min_grade = iLowerLv,
		max_grade = iUpperLv
	}
	self:RefreshTargetBtton(tAutoInfo)
end
return CTeamTargetBox
local CTeamCtrl = class("CTeamCtrl", CCtrlBase)

CTeamCtrl.TARGET_NONE = 0 --特殊任务id

CTeamCtrl.LEADER_UNACTIVE_TIME_MAX = 60   -- 队长最大不活跃时间间隔
CTeamCtrl.LEADER_UNACTIVE_CHECK_TIME = 5  -- 队长最大不活跃时间间隔检查时间

CTeamCtrl.EnumLeaderActiveState = {
	Sleep = 0,
	Awake = 1,
}

CTeamCtrl.INVITE_LIMIT = 20  -- 队长最大不活跃时间间隔检查时间

function CTeamCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Init()
end

function CTeamCtrl.Init(self)
	self.m_TeamID = nil
	self.m_LeaderID = nil
	self.m_Members = {}
	self.m_PosList = {}

	self.m_Applys = {}
	self.m_RefApplys = {}
	self.m_UnreadApply = {}
	self.m_Invites = {}
	self.m_UnreadInvite = {}
	self.m_IsClickInvite = false
	--便捷组队相关
	self.m_TargetTeams = {}
	self.m_IsTeamMatch = false
	self.m_IsPlayerMatch = false
	self.m_TargetInfo = {}
	self.m_LocalTargetInfo = {} --界面临时信息
	self.m_PlayerAutoTarget = 0
	self.m_CountAutoMatch = {}
	self.m_AutoRecruit = false
	self.m_RecruitChannel = 0

	--战斗指挥
	self.m_WarCmds = {}
	self.m_AppointPid = -1
	
	--队长活跃检测
	self.m_LeaderActiveStatus = 1 --1：活跃 0：不活跃
	self.m_AutoCheckLeaderActiveTimer = nil	 --定时检测队长是否在活跃状态
	self.m_LeaderPos = nil
	self.m_IsLeaderTouchUI = false
	self.m_LeaderUnActiveElapseTimer = 0 	 --队长不活跃时间

	self.m_NetCacheCmd = {}  --战斗中缓存的操作指令
	--组队状态下队长的伙伴及阵法数据
	self.m_FmtInfo = nil
	self.m_PartnerDic = {}
	self.m_PartnerPosList = {}
	self.m_PlayerPosList = {}
	self.m_SelectedPid = -1	--界面数据，组队换位目标
	self.m_OriginalPos = {} --存储初始化阵型列表用于比较是否变化,策划强烈要求在战斗中飘是否阵型变化
	self.m_IsPlayerChanged = false
	self.m_IsPartnerChanged = false

	self.m_ShowInviteWin = false

	self.m_IsTeamSendInit = false

	self:OnEvent(define.Team.Event.NotifyApply)
	self:OnEvent(define.Team.Event.NotifyInvite)
end

function CTeamCtrl.Reset(self)
	self:Init()
	self:OnEvent(define.Team.Event.Reset)
end

function CTeamCtrl.Clear(self)
	self:Init()
	self:OnEvent(define.Team.Event.Reset)
end

function CTeamCtrl.ClearUIData(self)
	self.m_OriginalPos = {}
	self.m_IsPartnerChanged = false
	self.m_IsPlayerChanged = false
end

function CTeamCtrl.AddTeam(self, iTeamID, iLeader, lMember, tTargetInfo)
	self.m_TeamID = iTeamID
	self.m_LeaderID = iLeader
	self.m_LeaderActiveStatus = 1
	self.m_Members = {}
	self.m_PosList = {}
	self.m_PlayerPosList = {}
	for i, v in ipairs(lMember) do
		local dMember = self:CopyProtoMember(v)
		self.m_Members[dMember.pid] = dMember
		table.insert(self.m_PosList, dMember.pid)
		if self:IsInTeam(dMember.pid) then
			table.insert(self.m_PlayerPosList, dMember.pid)
		end
	end
	self:SetTargetInfo(tTargetInfo)

	self:OnEvent(define.Team.Event.AddTeam, {isCreate = true})
	g_GuideCtrl:CheckTeamGuide()
	
	self:ClearInvite()
	--组队频道的特殊消息，暂时屏蔽
	-- g_ChatCtrl:SetSendLimitMsg("team", false)

	--开始检测队长的活跃状态
	self:StartCheckLeaderActive()
	g_FriendCtrl:UpdateTeamerFriend()  --好友模块的最近队友
--	g_SummonCtrl:NotFollowSummon()--收回所有宠物
end

function CTeamCtrl.DelTeam(self)
	self.m_AppointPid = -1
	self.m_TeamID = nil
	self.m_LeaderID = nil
	self.m_FmtInfo = nil
	self.m_LeaderActiveStatus = 1
	self.m_Members = {}
	self.m_PosList = {}
	self.m_PartnerDic = {}
	self.m_PlayerPosList = {}
	self.m_PartnerPosList = {}
	self:OnEvent(define.Team.Event.DelTeam)
	g_GuideCtrl:CheckTeamGuide()
	g_FormationCtrl:UpdatePosStatus(self.m_PosList)

	self:ClearApply()
	--组队频道的特殊消息，暂时屏蔽
	-- g_ChatCtrl:SetSendLimitMsg("team", true)


	--停止检测队长的活跃状态
	self:StopCheckLeaderActive()
end

function CTeamCtrl.UpdateTeamStatus(self, lStatus)
	local lPidPos = {}
	for i, v in ipairs(lStatus) do
		local dMember = self.m_Members[v.pid]
		if i == 1 then
			self.m_LeaderID = v.pid
		elseif v.pid == g_AttrCtrl.pid then
			--队员状态修改后解除任务自动寻路
			local oHero = g_MapCtrl:GetHero()
			if oHero then
				oHero:StopWalk()
			end
			g_NotifyCtrl:CancelProgress()
		end
		if dMember and v.status ~= dMember.status then
			dMember.status = v.status
		end
		table.insert(lPidPos, v.pid)
	end
	self.m_PosList = lPidPos

	g_FriendCtrl:UpdateTeamerFriend()
	g_FormationCtrl:UpdatePosStatus(lPidPos)
	g_FormationCtrl:UpdatePosStatus(lPidPos, self.m_PlayerPosList)

	self:OnEvent(define.Team.Event.AddTeam)
	g_GuideCtrl:CheckTeamGuide()

	--队伍状态发生变化，重新检测队长活跃状态
	self:StartCheckLeaderActive()

	--巡逻相关
	if g_TeamCtrl:IsJoinTeam() and (not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave()) then
		g_MapCtrl:SetAutoPatrol(false, false, false)
	end
end

function CTeamCtrl.UpdateMember(self, dPb)
	local dMember = self:CopyProtoMember(dPb)
	self.m_Members[dMember.pid] = dMember
	self:OnEvent(define.Team.Event.MemberUpdate, dMember)
	g_FriendCtrl:UpdateTeamerFriend()
end

function CTeamCtrl.UpdateMemberAttr(self, iPid, dStatusInfo)
	local dMember = self.m_Members[iPid]
	for k,v in pairs(dStatusInfo) do
		dMember[k] = v
	end
	self.m_Members[iPid] = dMember
	self:OnEvent(define.Team.Event.MemberUpdate, dMember)
	g_FriendCtrl:UpdateTeamerFriend()
end

--??为什么要copy
function CTeamCtrl.CopyProtoMember(self, dPb)
    local tInfo = dPb.status_info
	local d = {
		pid = dPb.pid,
		name = tInfo.name,
		model_info = tInfo.model_info,
		school = tInfo.school,
		grade = tInfo.grade,
		status = tInfo.status,
		hp = tInfo.hp,
		max_hp = tInfo.max_hp,
		mp = tInfo.mp,
		max_mp = tInfo.max_mp,
		orgid = tInfo.orgid,
		icon = tInfo.icon,
		score = tInfo.score,
	}
	return d
end

function CTeamCtrl.SetTeamFormationInfo(self, fmt_id, fmt_grade)
	local dInfo = {
			fmt_id = fmt_id,
			exp = 0,
			grade = fmt_grade,
	}
	self.m_FmtInfo = dInfo
end

function CTeamCtrl.SetTeamPartnerList(self, partner_list)
	self.m_PartnerDic = {}
	self.m_PartnerPosList = {}
	for i,partner in ipairs(partner_list) do
	 	self.m_PartnerDic[partner.id] = partner
	 	table.insert(self.m_PartnerPosList, partner.id)
	end 
end

function CTeamCtrl.SetTeamPosList(self, lPlayerList, lPartnerList)
	self.m_PlayerPosList = lPlayerList
	self.m_PartnerPosList = lPartnerList
end

function CTeamCtrl.GetPartnerPosList(self)
	return self.m_PartnerPosList
end

function CTeamCtrl.GetTeamPartnerById(self, iPartnerId)
	return self.m_PartnerDic[iPartnerId]
end

function CTeamCtrl.GetFormationInfo(self)
	return self.m_FmtInfo
end

function CTeamCtrl.GetMember(self, pid)
	return self.m_Members[pid]
end

function CTeamCtrl.GetMemberSize(self)
	return #self.m_PosList
end

--队员
function CTeamCtrl.GetMemberList(self)
	local newPosList = {}
	local fmtPosList = self.m_PlayerPosList
	local fmtPosDic = {}
	if fmtPosList == nil or #fmtPosList == 0 then
		newPosList = self.m_PosList
	else
		for i,pid in ipairs(fmtPosList) do
			table.insert(newPosList, pid)
			fmtPosDic[pid] = i
		end
		for i,pid in ipairs(self.m_PosList) do
			if not fmtPosDic[pid] then
				table.insert(newPosList, pid)
			end
		end
	end

	local list = {}
	for i, pid in ipairs(newPosList) do
		table.insert(list, self.m_Members[pid])
	end
	return list
end

--伙伴和队员
function CTeamCtrl.GetMixedList(self)
	local list = {}
	if self:IsJoinTeam() then
		list = self:GetMemberList()
	else
		local dHero = {
			pid = g_AttrCtrl.pid,
			name = g_AttrCtrl.name,
			model_info = g_AttrCtrl.model_info,
			school = g_AttrCtrl.school,
			grade = g_AttrCtrl.grade,
			status = 0,
		}
		table.insert(list, dHero)
	end
	return list
end

--判断是否有队员离队
function CTeamCtrl.HasMemberLeave(self)
	for pid,v in pairs(self.m_Members) do
		if self:IsLeave(pid) then
			return true
		end
	end
	return false
end

--状态判断 start
function CTeamCtrl.IsJoinTeam(self)
	return self.m_TeamID ~= nil 
end

function CTeamCtrl.IsLeader(self, pid)
	pid = pid or g_AttrCtrl.pid
	return pid == self.m_LeaderID
end

function CTeamCtrl.IsStatus(self, pid, cmpStatus)
	pid = pid or g_AttrCtrl.pid
	local dMember = self.m_Members[pid]
	if dMember then
		return dMember.status == cmpStatus
	else
		return false
	end
end

function CTeamCtrl.IsLeave(self, pid)
	return self:IsStatus(pid, define.Team.MemberStatus.Leave)
end

function CTeamCtrl.IsOffline(self, pid)
	return self:IsStatus(pid, define.Team.MemberStatus.Offline)
end

function CTeamCtrl.IsInTeam(self, pid)
	return self:IsStatus(pid, define.Team.MemberStatus.Normal)
end

function CTeamCtrl.IsPlayerAutoMatch(self)
	return self.m_IsPlayerMatch
end

function CTeamCtrl.IsTeamAutoMatch(self)
	return self.m_IsTeamMatch
end

function CTeamCtrl.IsCommander(self, pid)
	return (self.m_AppointPid ~= -1 and self.m_AppointPid == pid) or (self:IsLeader(pid) and self.m_AppointPid == -1)
end

function CTeamCtrl.IsCacheLeave(self, iPid)
	return self.m_NetCacheCmd[iPid] and self.m_NetCacheCmd[iPid][define.Team.NetCmd.Leave]
end

function CTeamCtrl.IsCacheShortLeave(self, iPid)
	return self.m_NetCacheCmd[iPid] and self.m_NetCacheCmd[iPid][define.Team.NetCmd.ShortLeave]
end

function CTeamCtrl.IsCacheSkickOut(self, iPid)
	return self.m_NetCacheCmd[iPid] and self.m_NetCacheCmd[iPid][define.Team.NetCmd.SKickOut]
end

function CTeamCtrl.IsCacheBackTeam(self, iPid)
	return self.m_NetCacheCmd[iPid] and self.m_NetCacheCmd[iPid][define.Team.NetCmd.BackTeam]
end

function CTeamCtrl.IsCacheSetLeader(self, iPid)
	return self.m_NetCacheCmd[iPid] and self.m_NetCacheCmd[iPid][define.Team.NetCmd.SetLeader]
end

function CTeamCtrl.IsTeamMember(self, iPid)
	for i,pid in ipairs(self.m_PosList) do
		if iPid == pid then
			return true
		end
	end
	return false
end
--状态判断 end

function CTeamCtrl.GetApplyList(self)
	local list = {}
	for pid, dApply in ipairs(self.m_Applys) do
		table.insert(list, dApply)
	end
	return list
end

function CTeamCtrl.GetInviteList(self)
	local list = {}
	for pid, dInvite in ipairs(self.m_Invites) do
		table.insert(list, dInvite)
	end
	return list
end

function CTeamCtrl.AddApply(self, dApply)
	if self.m_RefApplys[dApply.pid] ~= nil then
		printc("已存在："..dApply.pid)
		return
	end
	local oView = CTeamMainView:GetView()
	if not oView or oView.m_CurTabIndex ~= oView:GetPageIndex("Apply") then
		self.m_UnreadApply[dApply.pid] = true
	end
	table.insert(self.m_Applys, dApply)
	self.m_RefApplys[dApply.pid] = 1
	self:OnEvent(define.Team.Event.AddApply, dApply)
	self:OnEvent(define.Team.Event.NotifyApply)
	-- printc("申请列表")
	-- table.print(self.m_Applys)
end

function CTeamCtrl.DelApply(self, pid)
	local index = 0
	for i, apply in pairs(self.m_Applys) do
		if apply.pid == pid then
			index = i
			break
		end
	end
	table.remove(self.m_Applys, index)
	self.m_RefApplys[pid] = nil
	self.m_UnreadApply[pid] = nil
	self:OnEvent(define.Team.Event.DelApply, {pid = pid})
	self:OnEvent(define.Team.Event.NotifyApply)
end

function CTeamCtrl.UpdateApplyList(self, lApplyInfo)
	self.m_RefApplys = {}
	self.m_Applys = {} 
	self.m_UnreadApply = {}

	for i,dApply in ipairs(lApplyInfo) do
		self.m_Applys[i] = dApply
	end

	self:OnEvent(define.Team.Event.RefreshAllApply)
end

--TODO:功能修改-邀请相关代码示情况可删除
function CTeamCtrl.AddInvite(self, dInvite)
	if not CTeamInviteView:GetView() then
		self.m_UnreadInvite[dInvite.teamid] = true
	end
	table.insert(self.m_Invites, 1, dInvite)
	self.m_IsClickInvite = false

	local dInvite = self.m_Invites[CTeamCtrl.INVITE_LIMIT + 1]
	if dInvite then
		self:DelInvite(dInvite.teamid, true)
	end

	self:OnEvent(define.Team.Event.AddInvite, dInvite)
	self:OnEvent(define.Team.Event.NotifyInvite)
end

function CTeamCtrl.DelInvite(self, iTeamID, bIsSkip)
	local index = 0
	local iCnt = #self.m_Invites
	for i = iCnt, 1, -1 do
		local dInvite = self.m_Invites[i]
		if dInvite.teamid == iTeamID then
			index = i
			break
		end
	end

	table.remove(self.m_Invites, index)
	self.m_UnreadInvite[iTeamID] = nil
	if not bIsSkip then
		self:OnEvent(define.Team.Event.DelInvite, {teamid = iTeamID})
		self:OnEvent(define.Team.Event.NotifyInvite)
	end
end

function CTeamCtrl.UpdateInviteList(self, lInviteInfo)
	local dInfo = {}
	local lNewInvite = {}
	for i,dInvite in ipairs(lInviteInfo) do
		dInfo[dInvite.teamid] = dInvite
		lNewInvite[i] = dInvite
	end
	for i,dInvite in ipairs(self.m_Invites) do
		local dInviteNew = dInfo[dInvite.teamid]
		if not dInviteNew then
			self.m_UnreadInvite[dInvite.teamid] = nil
		end
	end
	self.m_Invites = lNewInvite

	self:OnEvent(define.Team.Event.RefreshAllInvite)
end

function CTeamCtrl.ClearApply(self)
	self.m_RefApplys = {}
	self.m_Applys = {}
	self.m_UnreadApply = {}
	self:OnEvent(define.Team.Event.ClearApply)
end

function CTeamCtrl.ClearInvite(self)
	self.m_Invites = {}
	self.m_UnreadInvite = {}
	self.m_IsClickInvite = false
	self:OnEvent(define.Team.Event.ClearInvite)
end

function CTeamCtrl.ReadApply(self)
	self.m_UnreadApply = {}
	self:OnEvent(define.Team.Event.NotifyApply)
end

function CTeamCtrl.ReadInvite(self)
	self.m_UnreadInvite = {}
	self:OnEvent(define.Team.Event.NotifyInvite)
end

function CTeamCtrl.AddTargetTeamList(self, teaminfo, iTargetId)
	local function addTargetTeam(iTargetId, dTeam)
		iTargetId = iTargetId or 0
		if not self.m_TargetTeams[iTargetId] then
			self.m_TargetTeams[iTargetId] = {}
		end
		if dTeam then
			table.insert(self.m_TargetTeams[iTargetId], dTeam)
		end
	end 
	if teaminfo ~= nil and next(teaminfo) then
		for k, dTeam in pairs(teaminfo) do
			addTargetTeam(iTargetId, dTeam)
		end
	else
		addTargetTeam(iTargetId, nil)
	end
	-- g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.TeamTargetRefresh, iTargetId, 5)
	self:OnEvent(define.Team.Event.AddTargetTeam, iTargetId)
end

function CTeamCtrl.ClearTargetTeamList(self, iTargetId)
	if self.m_TargetTeams[iTargetId] then
		self.m_TargetTeams[iTargetId] = {}
	end
end

function CTeamCtrl.GetTargetTeamList(self, iTargetId)
	local list = {}
	local targetTeams = self.m_TargetTeams[iTargetId]
	if targetTeams then
		for pid, dTeam in ipairs(targetTeams) do
			table.insert(list, dTeam)
		end
	end
	local function sort(team1, team2)
		return team1.match_time < team2.match_time
	end 
	table.sort(list, sort)
	return list
end

function CTeamCtrl.SetPlayerMatchStatus(self, iAutoMatch, iTargetId)
	self.m_IsPlayerMatch = (iAutoMatch == 1)
	if self.m_IsPlayerMatch then
		self.m_PlayerAutoTarget = iTargetId
		if g_LingxiCtrl.m_IsLingxiMatching then
			nethuodong.C2GSLingxiStopMatch()
		end
	end
	self:OnEvent(define.Team.Event.NotifyAutoMatch)
end

function CTeamCtrl.SetTargetInfo(self, autoInfo)
    self.m_TargetInfo = autoInfo
    self:SetLocalTargetInfo(autoInfo.auto_target, autoInfo.min_grade, autoInfo.max_grade)
    self.m_IsTeamMatch = (autoInfo.team_match == 1)
    self:OnEvent(define.Team.Event.NotifyAutoMatch)
    if self.m_IsTeamSendInit then
    	self:SendTeamMsg(autoInfo.auto_target, autoInfo.min_grade, autoInfo.max_grade)
    end
    self.m_IsTeamSendInit = true
end

function CTeamCtrl.GetTargetInfo(self)
	return self.m_TargetInfo
end

function CTeamCtrl.SetLocalTargetInfo(self, iTargetId, iMinGrade, iMaxGrade)
	self.m_LocalTargetInfo = {
		auto_target = iTargetId,
		min_grade = iMinGrade,
		max_grade = iMaxGrade
	}
end

function CTeamCtrl.GetLocalTargetInfo(self)
	return self.m_LocalTargetInfo
end

function CTeamCtrl.SetPlayerAutoTarget(self, iTaskId)
	self.m_PlayerAutoTarget = iTaskId
	self:OnEvent(define.Team.Event.NotifyAutoMatch)
end

function CTeamCtrl.GetPlayerAutoTarget(self)
	return self.m_PlayerAutoTarget
end

function CTeamCtrl.SetCountAutoMatch(self, dPb)
	self.m_CountAutoMatch[dPb.auto_target] = dPb
	self:OnEvent(define.Team.Event.NotifyCountAutoMatch)
end

function CTeamCtrl.GetCountAutoMatch(self, iTargetId)
	return self.m_CountAutoMatch[iTargetId]
end

function CTeamCtrl.InitLocalWarCmdList(self)
	if self.m_WarCmds[1] ~= nil and self.m_WarCmds[1][1] ~= nil then
		return
	end
	for _,dWarCmdInfo in ipairs(data.teamdata.WAR_CMD) do
		if not self.m_WarCmds[dWarCmdInfo.type] then
			self.m_WarCmds[dWarCmdInfo.type] = {}
		end
		for i,sCmd in ipairs(dWarCmdInfo.content) do
			self.m_WarCmds[dWarCmdInfo.type][i] = sCmd
		end
	end
end

function CTeamCtrl.SetWarCmdList(self, dWarcmds)
	for k,cmd in pairs(dWarcmds) do
		if not self.m_WarCmds[cmd.type] then
			self.m_WarCmds[cmd.type] = {}
		end
		for i,sCmd in ipairs(cmd.cmds) do
			self.m_WarCmds[cmd.type][i + 5] = sCmd
		end
	end
	self:OnEvent(define.Team.Event.RefreshWarCmd)
end

function CTeamCtrl.GetWarCmdList(self, iType)
	return self.m_WarCmds[iType]
end

function CTeamCtrl.UpdateWarCmd(self, iType, iPos, sCmd)
	if not sCmd or sCmd == "" then
		table.remove(self.m_WarCmds[iType], iPos)
	else
		self.m_WarCmds[iType][iPos] = sCmd
	end
	self:OnEvent(define.Team.Event.RefreshWarCmd)
	table.print(self.m_WarCmds[iType])
end

function CTeamCtrl.DelWarCmd(self, dWarcmd)
	for index,cmd in pairs(self.m_WarCmds[dWarcmd.type]) do
		if cmd == dWarcmd.cmd then
			self.m_WarCmds[index] = ""
			break
		end
	end
	self:OnEvent(define.Team.Event.RefreshWarCmd)
end

function CTeamCtrl.SetTeamAppoint(self, iPid)
	self.m_AppointPid = iPid
	self:OnEvent(define.Team.Event.RefreshAppoint)
end

function CTeamCtrl.GetTeamAppoint(self)
	return self.m_AppointPid
end

function CTeamCtrl.InitNetCacheCmdList(self, iLeave, tSkickList, iShortleave, iBack, iSetLeader)
	self.m_NetCacheCmd = {}
	if iLeave == 1 then
		self:AddNetCacheCmd(g_AttrCtrl.pid, define.Team.NetCmd.Leave)
	end
	for i,pid in ipairs(tSkickList) do
		self:AddNetCacheCmd(pid, define.Team.NetCmd.SKickOut)
	end
	if iShortleave == 1 then
		self:AddNetCacheCmd(g_AttrCtrl.pid, define.Team.NetCmd.ShortLeave)
	end
	if iBack == 1 then
		self:AddNetCacheCmd(g_AttrCtrl.pid, define.Team.NetCmd.BackTeam)
	end
	if iSetLeader > 0 then
		self:AddNetCacheCmd(iSetLeader, define.Team.NetCmd.SetLeader)
	end
	self:OnEvent(define.Team.Event.RefreshCacheCmd)
end

function CTeamCtrl.AddNetCacheCmd(self, iPid, iCmd)
	if self.m_NetCacheCmd[iPid] == nil then
		self.m_NetCacheCmd[iPid] = {}
	end
	self.m_NetCacheCmd[iPid][iCmd] = true
end

function CTeamCtrl.ExcuteCacheCmd(self)
	-- local stopWalk = function()
	-- 	local oHero = g_MapCtrl:GetHero()
	-- 	if oHero then
	-- 		oHero:StopWalk()
	-- 	end
	-- end
	-- for iPid, iCmd in pairs(self.m_NetCacheCmd) do
	-- 	if iCmd == define.Team.NetCmd.Leave then
	-- 		netteam.C2GSLeaveTeam()
	-- 		stopWalk()
	-- 	elseif iCmd == define.Team.NetCmd.ShortLeave then
	-- 		netteam.C2GSShortLeave()
	-- 		stopWalk()
	-- 	elseif iCmd == define.Team.NetCmd.SKickOut then
	-- 		netteam.C2GSKickOutTeam(iPid)
	-- 	elseif iCmd == define.Team.NetCmd.BackTeam then
	-- 		netteam.C2GSBackTeam()
	-- 	end
	-- end
	self.m_NetCacheCmd = {}
end

function CTeamCtrl.SetLeaderActiveStatus(self, iStatus)
	self.m_LeaderActiveStatus = iStatus
	if iStatus == CTeamCtrl.EnumLeaderActiveState.Awake then
		self.m_LeaderUnActiveElapseTimer = 0
	end
end

function CTeamCtrl.IsLeaderActive(self)
	return self.m_LeaderActiveStatus == CTeamCtrl.EnumLeaderActiveState.Awake
end

function CTeamCtrl.SetLeaderTouchUI(self, state)
	self.m_IsLeaderTouchUI = state
	if g_TeamCtrl:IsLeader() and not g_WarCtrl:IsWar() and self.m_IsLeaderTouchUI then
		if not g_TeamCtrl:IsLeaderActive() then	--队长不活跃状态下主动通知服务器活跃
			-- 客户端也维护这个状态，不单由服务器下发
			self.m_LeaderActiveStatus = CTeamCtrl.EnumLeaderActiveState.Awake
			self.m_IsLeaderTouchUI = false
			netother.C2GSSetActive(1)
		end
	end
end

function CTeamCtrl.IsLeaderTouchUI(self)
	return self.m_IsLeaderTouchUI
end

function CTeamCtrl.StartCheckLeaderActive(self)
	-- if self:IsJoinTeam() and self:IsLeader() and not g_WarCtrl:IsWar() then
	-- 	if self.m_IsLeaderTouchUI == true then
	-- 		if not self:IsLeaderActive() then
	-- 			netother.C2GSSetActive(CTeamCtrl.EnumLeaderActiveState.Awake)
	-- 		end
	-- 		self:SetLeaderActiveStatus(CTeamCtrl.EnumLeaderActiveState.Awake)
	-- 		self.m_IsLeaderTouchUI = false
	-- 	else
	-- 		local pos = {}
	-- 		if g_MapCtrl:GetHero() then
	-- 			pos = g_MapCtrl:GetHero():GetPos()
	-- 		end
	-- 		local x = pos.x or 0
	-- 		local y = pos.y or 0
	-- 		x = math.floor(x * 100000)
	-- 		y = math.floor(y * 100000)
	-- 		local curPos = Vector2.New(x, y)
	-- 		if curPos ~= self.m_LeaderPos then
	-- 			if not self:IsLeaderActive() then
	-- 				netother.C2GSSetActive(CTeamCtrl.EnumLeaderActiveState.Awake)
	-- 			end	
	-- 			self:SetLeaderActiveStatus(CTeamCtrl.EnumLeaderActiveState.Awake)
	-- 			self.m_LeaderPos = curPos			
	-- 		else
	-- 			self.m_LeaderUnActiveElapseTimer = self.m_LeaderUnActiveElapseTimer + CTeamCtrl.LEADER_UNACTIVE_CHECK_TIME
	-- 			if CTeamCtrl.LEADER_UNACTIVE_TIME_MAX <= self.m_LeaderUnActiveElapseTimer then
	-- 				self.m_LeaderUnActiveElapseTimer = 0
	-- 				self:SetLeaderActiveStatus(CTeamCtrl.EnumLeaderActiveState.Sleep)
	-- 				netother.C2GSSetActive(CTeamCtrl.EnumLeaderActiveState.Sleep)
	-- 			end
	-- 		end
	-- 	end
	-- 	-- x(LEADER_UNACTIVE_CHECK_TIME = 60)秒检测1次
	-- 	if self.m_AutoCheckLeaderActiveTimer ~= nil then
	-- 		Utils.DelTimer(self.m_AutoCheckLeaderActiveTimer)
	-- 		self.m_AutoCheckLeaderActiveTimer = nil
	-- 	end		
	-- 	self.m_AutoCheckLeaderActiveTimer = Utils.AddTimer(callback(self, "StartCheckLeaderActive"), 0, CTeamCtrl.LEADER_UNACTIVE_CHECK_TIME)				
	-- else
	-- 	self:StopCheckLeaderActive()
	-- end
end

function CTeamCtrl.StopCheckLeaderActive(self)
	-- if self.m_AutoCheckLeaderActiveTimer ~= nil then
	-- 	Utils.DelTimer(self.m_AutoCheckLeaderActiveTimer)
	-- 	self.m_AutoCheckLeaderActiveTimer = nil
	-- end
	-- self.m_LeaderUnActiveElapseTimer = 0
	-- self:SetLeaderActiveStatus(CTeamCtrl.EnumLeaderActiveState.Awake)
end

function CTeamCtrl.SendTeamMsg(self, oAutoTarget, min_grade, max_grade)
	if oAutoTarget == 0 then
		return
	end
	local bIsTeamAutoMatch = g_TeamCtrl:IsTeamAutoMatch()
	local bIsLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)
	if not (bIsLeader and bIsTeamAutoMatch) then
		return
	end
	-- printc("7777777777777777")
	local tData = data.teamdata.AUTO_TEAM[oAutoTarget]
	local iMatchCount = tData.max_count
	local sTeamCount  = string.format("（%d/%d）", #g_TeamCtrl:GetMixedList(), iMatchCount)
	local sTarget = string.format("[%s%s%d-%d级]进组啦", tData.name, sTeamCount, min_grade, max_grade)
	local targetLink = LinkTools.GenerateGetTeamInfoLink(g_TeamCtrl.m_TeamID, sTarget)
	local applyLink = LinkTools.GenerateApplyTeamLink(g_TeamCtrl.m_TeamID)
	local msg = targetLink..applyLink
	netchat.C2GSMatchTeamChat(msg, tonumber(min_grade), tonumber(max_grade), 1)
end

--便捷组队的功能
function CTeamCtrl.TeamAutoMatch(self, auto_target)
	if g_TeamCtrl:IsJoinTeam() then
		if g_TeamCtrl:IsLeader() then
			CTeamFilterView:ShowView(function(oView)
				oView:SetSelectedTarget(auto_target)
			end)
		else
			g_NotifyCtrl:FloatMsg("只有队长才可以设置目标匹配哦")
		end
	else 
		CTeamHandyBuildView:ShowView(function (oView)
			oView:SetSelectedAutoTeam(auto_target)
		end)
	end
end

return CTeamCtrl
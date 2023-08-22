module(..., package.seeall)

--GS2C--

function GS2CAddTeam(pbdata)
	local teamid = pbdata.teamid
	local leader = pbdata.leader
	local member = pbdata.member
	local target_info = pbdata.target_info
	local partner_list = pbdata.partner_list
	local fmt_id = pbdata.fmt_id
	local fmt_grade = pbdata.fmt_grade
	--todo
	local oIsHasTeam = g_TeamCtrl:IsJoinTeam()
	g_TeamCtrl:SetTeamFormationInfo(fmt_id, fmt_grade)
	g_TeamCtrl:SetTeamPartnerList(partner_list)
	g_TeamCtrl:AddTeam(teamid, leader, member, target_info)
	g_ScheduleCtrl:SetStopNotifyTime()
	g_TaskCtrl:SetTaskIntervalNotifyTime()
	--暂时屏蔽
	-- if not oIsHasTeam and g_TeamCtrl:IsJoinTeam() then
	-- 	g_ChatCtrl:ClearUpChannelMsg(define.Channel.Team)
	-- end
end

function GS2CDelTeam(pbdata)
	--todo
	g_TeamCtrl:DelTeam()
	g_ScheduleCtrl:SetStopNotifyTime()
	g_TaskCtrl:SetTaskIntervalNotifyTime()
end

function GS2CAddTeamMember(pbdata)
	local mem_info = pbdata.mem_info
	--todo
	g_TeamCtrl:UpdateMember(mem_info)
end

function GS2CRefreshTeamStatus(pbdata)
	local team_status = pbdata.team_status
	--todo
	g_TeamCtrl:UpdateTeamStatus(team_status)
	g_NetCtrl:CheckClientStatus()
	g_ScheduleCtrl:SetStopNotifyTime()
	g_TaskCtrl:SetTaskIntervalNotifyTime()
end

function GS2CRefreshMemberInfo(pbdata)
	local pid = pbdata.pid
	local status_info = pbdata.status_info
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(status_info, "team")
	g_TeamCtrl:UpdateMemberAttr(pid, dDecode)
end

function GS2CTeamApplyInfo(pbdata)
	local apply_info = pbdata.apply_info
	local open = pbdata.open --0.不打开 1.打开
	--todo
	if next(apply_info) then
		if open == 0 then
			for i, dApply in pairs(apply_info) do
				g_TeamCtrl:AddApply(dApply)
			end
		else
			g_TeamCtrl:UpdateApplyList(apply_info)
			--CTeamApplyView:ShowView()
			CTeamMainView:ShowView(function(oView)
				oView:ShowSubPageByIndex(oView:GetPageIndex("Apply"))
			end)
		end
	else
		g_TeamCtrl:ClearApply()
	end
end

function GS2CDelTeamApplyInfo(pbdata)
	local pid = pbdata.pid
	--todo
	g_TeamCtrl:DelApply(pid)
end

function GS2CAddTeamApplyInfo(pbdata)
	local apply_info = pbdata.apply_info
	--todo
	g_TeamCtrl:AddApply(apply_info)
end

function GS2CInviteInfo(pbdata)
	local teaminfo = pbdata.teaminfo
	local login = pbdata.login --1.登录 0.非登录
	--todo
	if next(teaminfo) then
		if login == 1 then
			for i, dInvite in pairs(teaminfo) do
				g_TeamCtrl:AddInvite(dInvite)
			end
		else
			g_TeamCtrl:UpdateInviteList(teaminfo)
			CTeamInviteView:ShowView()
		end
	else
		g_TeamCtrl:ClearInvite()
	end
	
end

function GS2CRemoveInvite(pbdata)
	local teamid = pbdata.teamid
	--todo
	g_TeamCtrl:DelInvite(teamid)
end

function GS2CAddInviteInfo(pbdata)
	local teaminfo = pbdata.teaminfo
	--todo
	g_TeamCtrl:AddInvite(teaminfo)
	if not g_TeamCtrl.m_ShowInviteWin then
		local sName = teaminfo.member[1].status_info.name
		
		local sMsg = string.format("[c]#I%s#n[/c]邀请你组队，是否同意入队。", sName)
		local windowConfirmInfo = {
			msg				= sMsg,
			okCallback		= function ()
				if not g_MapCtrl:IsTeamAllowed() then
					g_NotifyCtrl:FloatMsg("当前场景禁止组队")
					return
				end
				netteam.C2GSInvitePass(teaminfo.teamid)
			end,
			cancelCallback  = function()
				g_TeamCtrl.m_ShowInviteWin = false
				netteam.C2GSClearTeamInvite(teaminfo.teamid)
			end,
			closeCallback = function()
				g_TeamCtrl.m_ShowInviteWin = false
			end,
			okStr			= "确定",
			cancelStr		= "拒绝",
			countdown       = 15,
			default         = 0,
			closeType		= extend_close,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		g_TeamCtrl.m_ShowInviteWin = true
	end 
end

function GS2CTargetInfo(pbdata)
	local target_info = pbdata.target_info
	--todo
	g_TeamCtrl:SetTargetInfo(target_info)
end

function GS2CNotifyAutoMatch(pbdata)
	local player_match = pbdata.player_match --1-正在匹配，0-取消匹配
	local auto_target = pbdata.auto_target --目标id
	--todo
	g_TeamCtrl:SetPlayerMatchStatus(player_match, auto_target)
end

function GS2CTargetTeamInfo(pbdata)
	local teaminfo = pbdata.teaminfo
	--todo
	CTeamInfoView:ShowView(function(oView)
		oView:SetTeamInfo(teaminfo)
	end)
end

function GS2CTargetTeamInfoList(pbdata)
	local teaminfo = pbdata.teaminfo
	local auto_target = pbdata.auto_target
	--todo
	g_TeamCtrl:ClearTargetTeamList(auto_target)
	g_TeamCtrl:AddTargetTeamList(teaminfo, auto_target)
end

function GS2CCountAutoMatch(pbdata)
	local auto_target = pbdata.auto_target
	local member_count = pbdata.member_count
	local team_count = pbdata.team_count
	--todo
	g_TeamCtrl:SetCountAutoMatch(pbdata)
end

function GS2CLeaderActiveStatus(pbdata)
	local active = pbdata.active --0-呆滞可申请队长，1-活跃不可申请队长
	--todo
	g_TeamCtrl:SetLeaderActiveStatus(active)
end

function GS2CTargetTeamStatus(pbdata)
	local teamid = pbdata.teamid
	local status = pbdata.status --0-没申请,1-正在申请，2-删除
	--todo
	g_TeamCtrl:OnEvent(define.Team.Event.RefreshApply, {teamid = teamid, status = status})
end

function GS2CRefreshTeamAppoint(pbdata)
	local pid = pbdata.pid --刷新委任目标id
	--todo
	g_TeamCtrl:SetTeamAppoint(pid)
end

function GS2CRefreshDelWarCmd(pbdata)
	local type = pbdata.type
	local pos = pbdata.pos
	--todo
	g_TeamCtrl:UpdateWarCmd(type, pos, "")
end

function GS2CRefreshWarCmd(pbdata)
	local warcmds = pbdata.warcmds
	--todo
	g_TeamCtrl:SetWarCmdList(warcmds)
end

function GS2CRefreshTeamWarCmd(pbdata)
	local type = pbdata.type
	local pos = pbdata.pos
	local cmd = pbdata.cmd
	--todo
	g_TeamCtrl:UpdateWarCmd(type, pos, cmd)
end

function GS2CInviteeStatus(pbdata)
	local target = pbdata.target --被邀请者pid
	local target_status = pbdata.target_status --0:已邀请;1:玩家已下线;2:邀请列表已满;3:玩家已有队伍
	--todo
	g_TeamCtrl:OnEvent(define.Team.Event.RefreshInviteeStatus, {pid = target, status = target_status})
end

function GS2CGetTeamAllPos(pbdata)
	local player_list = pbdata.player_list
	local partner_list = pbdata.partner_list
	--todo
	g_TeamCtrl:SetTeamPosList(player_list, partner_list)
	g_TeamCtrl:OnEvent(define.Team.Event.RefreshFormationPos)
end

function GS2CTeamPartners(pbdata)
	local partner_list = pbdata.partner_list
	--todo
	g_TeamCtrl:SetTeamPartnerList(partner_list)
end

function GS2CTeamLeaderFmt(pbdata)
	local fmt_id = pbdata.fmt_id
	local fmt_grade = pbdata.fmt_grade
	--todo
	g_TeamCtrl:SetTeamFormationInfo(fmt_id, fmt_grade)
end

function GS2CButtonState(pbdata)
	local leave = pbdata.leave --离队按钮 0-无 1-灰
	local kick = pbdata.kick --请离玩家列表
	local shortleave = pbdata.shortleave --0-无 1-取消
	local back = pbdata.back --0-无 1-取消
	local setleader = pbdata.setleader --0-无 玩家ID-取消
	--todo
	g_TeamCtrl:InitNetCacheCmdList(leave, kick, shortleave, back, setleader)
end


--C2GS--

function C2GSCreateTeam(auto_target)
	local t = {
		auto_target = auto_target,
	}
	g_NetCtrl:Send("team", "C2GSCreateTeam", t)
end

function C2GSTeamInfo(teamid)
	local t = {
		teamid = teamid,
	}
	g_NetCtrl:Send("team", "C2GSTeamInfo", t)
end

function C2GSApplyTeam(teamid, auto_target, auto)
	local t = {
		teamid = teamid,
		auto_target = auto_target,
		auto = auto,
	}
	g_NetCtrl:Send("team", "C2GSApplyTeam", t)
end

function C2GSTeamApplyInfo()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSTeamApplyInfo", t)
end

function C2GSApplyTeamPass(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("team", "C2GSApplyTeamPass", t)
end

function C2GSClearApply()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSClearApply", t)
end

function C2GSCancelApply(teamid, auto_target, auto)
	local t = {
		teamid = teamid,
		auto_target = auto_target,
		auto = auto,
	}
	g_NetCtrl:Send("team", "C2GSCancelApply", t)
end

function C2GSInviteTeam(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("team", "C2GSInviteTeam", t)
end

function C2GSTeamInviteInfo()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSTeamInviteInfo", t)
end

function C2GSInvitePass(teamid)
	local t = {
		teamid = teamid,
	}
	g_NetCtrl:Send("team", "C2GSInvitePass", t)
end

function C2GSClearInvite()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSClearInvite", t)
end

function C2GSClearTeamInvite(teamid)
	local t = {
		teamid = teamid,
	}
	g_NetCtrl:Send("team", "C2GSClearTeamInvite", t)
end

function C2GSShortLeave()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSShortLeave", t)
end

function C2GSLeaveTeam()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSLeaveTeam", t)
end

function C2GSKickOutTeam(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("team", "C2GSKickOutTeam", t)
end

function C2GSBackTeam()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSBackTeam", t)
end

function C2GSTeamSummon(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("team", "C2GSTeamSummon", t)
end

function C2GSApplyLeader()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSApplyLeader", t)
end

function C2GSSetLeader(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("team", "C2GSSetLeader", t)
end

function C2GSTeamAutoMatch(auto_target, min_grade, max_grade, team_match)
	local t = {
		auto_target = auto_target,
		min_grade = min_grade,
		max_grade = max_grade,
		team_match = team_match,
	}
	g_NetCtrl:Send("team", "C2GSTeamAutoMatch", t)
end

function C2GSTeamCancelAutoMatch()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSTeamCancelAutoMatch", t)
end

function C2GSPlayerAutoMatch(auto_target)
	local t = {
		auto_target = auto_target,
	}
	g_NetCtrl:Send("team", "C2GSPlayerAutoMatch", t)
end

function C2GSPlayerCancelAutoMatch()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSPlayerCancelAutoMatch", t)
end

function C2GSGetTargetTeamInfo(auto_target)
	local t = {
		auto_target = auto_target,
	}
	g_NetCtrl:Send("team", "C2GSGetTargetTeamInfo", t)
end

function C2GSSetAppointMem(pid, appoint)
	local t = {
		pid = pid,
		appoint = appoint,
	}
	g_NetCtrl:Send("team", "C2GSSetAppointMem", t)
end

function C2GSSetTeamWarCmd(cmd, pos, type)
	local t = {
		cmd = cmd,
		pos = pos,
		type = type,
	}
	g_NetCtrl:Send("team", "C2GSSetTeamWarCmd", t)
end

function C2GSAddTeamWarCmd(type, cmd)
	local t = {
		type = type,
		cmd = cmd,
	}
	g_NetCtrl:Send("team", "C2GSAddTeamWarCmd", t)
end


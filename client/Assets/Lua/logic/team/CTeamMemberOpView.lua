local CTeamMemberOpView = class("CTeamMemberOpView", CViewBase)

function CTeamMemberOpView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamMemberOpView.prefab", cb)
	--界面设置
	self.m_GroupName = "teamsub"
	-- self.m_ExtendClose = "ClickOut"
	-- self.m_BehindStrike = false
end

function CTeamMemberOpView.OnCreateView(self)
	self.m_OpTable = self:NewUI(1, CTable)
	self.m_OpBtn = self:NewUI(2, CButton, true, false)
	self.m_Bg = self:NewUI(3, CSprite)
	self.m_ArrowSpr = self:NewUI(4, CSprite)

	self.m_OpBtn:SetActive(false)
	self.m_Pid = nil

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CTeamMemberOpView.ShowExpandViewOp(self, pid)
	self.m_Pid = pid
	local bLeader = g_TeamCtrl:IsLeader()
	local bSelf = g_AttrCtrl.pid == pid
	local bInTeam = g_TeamCtrl:IsInTeam()
	local bLeave = g_TeamCtrl:IsLeave()
	local bIsCacheLeave = g_TeamCtrl:IsCacheLeave(g_AttrCtrl.pid)
	local bIsCacheShortLeave = g_TeamCtrl:IsCacheShortLeave(g_AttrCtrl.pid)
	local bIsCacheSkickOut = g_TeamCtrl:IsCacheSkickOut(pid)
	local bIsCacheBackTeam = g_TeamCtrl:IsCacheBackTeam(g_AttrCtrl.pid)
	local bIsCacheSetLeader = g_TeamCtrl:IsCacheSetLeader(pid)
	local bIsFriend = g_FriendCtrl:IsMyFriend(pid)
	-- 取消战斗中协议缓存
	local bIsWar = g_WarCtrl:IsWar()

	self.m_OpTable:Clear()
	if bLeader and g_TeamCtrl:IsLeave(pid) then
		self:AddOp("召回队员", callback(self, "SummonMember", bIsWar))
	end

	if bLeader and g_TeamCtrl:IsInTeam(pid) and not bSelf then
		self:CreateSetLeaderBtn(pid, bIsWar, bIsCacheSetLeader)
	end

	if bInTeam and not bLeader then
		self:CreateApplyLeader(bIsWar)
	end

	if not bLeader then
		self:CreateShortLeaveOrBackBtn(g_AttrCtrl.pid, bLeave, bIsWar, bIsCacheShortLeave, bIsCacheBackTeam)
	end

	if (bLeader and not bSelf) then
		self:CreateSKickOutBtn(pid, bIsWar, bIsCacheSkickOut)
	end

	if bLeader and g_TeamCtrl:IsInTeam(pid) and not bSelf then
		self:CreateAppointBtn(pid)
	end

	if not bLeader or bSelf then
		self:CreateLeaveBtn(g_AttrCtrl.pid, bIsWar, bIsCacheLeave)
	end

	if not bSelf then
		self:AddOp("查看信息", callback(self, "ShowPlayerInfo", pid))
	end

	if not bSelf then
		self:CreateAddFriend(bIsFriend, pid)
	end
	self:ResizeBg()
end

function CTeamMemberOpView.ShowTeamViewOp(self, pid)
	local bIsCacheLeave = g_TeamCtrl:IsCacheLeave(pid)
	local bIsCacheShortLeave = g_TeamCtrl:IsCacheShortLeave(pid)
	local bIsCacheSkickOut = g_TeamCtrl:IsCacheSkickOut(pid)
	local bIsCacheSetLeader = g_TeamCtrl:IsCacheSetLeader(pid) 
	local bIsWar = g_WarCtrl:IsWar()
	local bIsFriend = g_FriendCtrl:IsMyFriend(pid)
	
	self.m_Pid = pid
	self.m_OpTable:Clear()
	if g_TeamCtrl:IsLeader() then
		self:AddOp("调整站位", callback(self, "SwitchPos", pid))
		if g_TeamCtrl:IsInTeam(pid) then
			self:CreateSetLeaderBtn(pid, bIsWar, bIsCacheSetLeader)
		end
		self:CreateSKickOutBtn(pid, bIsWar, bIsCacheSkickOut)
		self:CreateAppointBtn(pid)
	else
		if g_TeamCtrl:IsInTeam() and g_TeamCtrl:IsLeader(pid) then
			self:CreateApplyLeader(bIsWar)
		end
	end
	self:AddOp("查看信息", callback(self, "ShowPlayerInfo", pid))
	self:CreateAddFriend(bIsFriend, pid)
	self:ResizeBg()
end

function CTeamMemberOpView.CreateAppointBtn(self, pid)
	if g_TeamCtrl:IsCommander(pid) then
		self:AddOp("取消委任", callback(self, "AppointMember", pid, 0))
	else
		self:AddOp("委任指挥", callback(self, "AppointMember", pid, 1))
	end
end

function CTeamMemberOpView.CreateShortLeaveOrBackBtn(self, pid, bLeave, bIsWar, bIsCacheShortLeave, bIsCacheBackTeam)
	if bLeave then
		if bIsWar and bIsCacheBackTeam then
			self:AddOp("取消归队", function()
				if g_LimitCtrl:CheckIsCannotMove() then
					return
				end
				netteam.C2GSBackTeam() 
			end)
		else
			self:AddOp("回归队伍", function() 
				if g_LimitCtrl:CheckIsCannotMove() then
					return
				end
				netteam.C2GSBackTeam() 
			end)
		end
	else
		if bIsWar and bIsCacheShortLeave then
			self:AddOp("取消暂离", function()
				if g_LimitCtrl:CheckIsCannotMove() then
					return
				end
				netteam.C2GSShortLeave() 
			end)
		else
			self:AddOp("暂离队伍", function()
				if g_LimitCtrl:CheckIsCannotMove() then
					return
				end
				netteam.C2GSShortLeave() 
				local oHero = g_MapCtrl:GetHero()
				if oHero then
					oHero:StopWalk()
				end
			end)
		end
	end
end

function CTeamMemberOpView.CreateSKickOutBtn(self, pid, bIsWar, bIsCacheSkickOut)
	if bIsWar and bIsCacheSkickOut then
		self:AddOp("取消请离", callback(self, "SKickOutTeam", pid, bIsWar, bIsCacheSkickOut))--function()
			-- g_NotifyCtrl:FloatMsg("已取消请离该玩家")
			-- g_TeamCtrl:AddNetCacheCmd(pid, define.Team.NetCmd.Normal)

		-- end)
	else
		self:AddOp("请离队伍", callback(self, "SKickOutTeam", pid, bIsWar, bIsCacheSkickOut))
	end
end

function CTeamMemberOpView.CreateLeaveBtn(self, pid, bIsWar, bIsCacheLeave)
	if bIsWar and bIsCacheLeave then
		self:AddOp("取消退队", callback(self, "LeaveTeam", pid, bIsWar, bIsCacheLeave))
	else
		self:AddOp("离开队伍", callback(self, "LeaveTeam", pid, bIsWar, bIsCacheLeave))
	end
end

function CTeamMemberOpView.CreateApplyLeader(self, bIsWar)
	if bIsWar then
		return
	end
	local oBtn = self:AddOp("申请带队", function() self:ApplyLeader() end)
	if g_TeamCtrl:IsLeaderActive() then
		oBtn:SetGrey(true)
	end
end

function CTeamMemberOpView.CreateSetLeaderBtn(self, pid, bIsWar, bIsCacheSetLeader)
	if bIsWar and bIsCacheSetLeader then
		self:AddOp("取消移交", callback(self, "SetLeader", pid, bIsWar, bIsCacheSetLeader))
	else
		self:AddOp("移交队长", callback(self, "SetLeader", pid, bIsWar, bIsCacheSetLeader))
	end
end

function CTeamMemberOpView.CreateAddFriend(self, bIsFriend, pid)
	if not bIsFriend then
		self:AddOp("添加好友", function() netfriend.C2GSApplyAddFriend(pid) end)
	end
end

function CTeamMemberOpView.ResizeBg(self)
	self.m_OpTable:Reposition()
	local bounds = UITools.CalculateRelativeWidgetBounds(self.m_OpTable.m_Transform)
	self.m_Bg:SetHeight(bounds.max.y - bounds.min.y + 30)
end

function CTeamMemberOpView.AddOp(self, sText, func)
	local oBtn = self.m_OpBtn:Clone(false)
	oBtn:SetActive(true)
	local function wrapclose()
		func()
		if Utils.IsExist(self) then
			CTeamMemberOpView:CloseView()
		end
	end
	oBtn:AddUIEvent("click", wrapclose)
	oBtn:SetText(sText)
	self.m_OpTable:AddChild(oBtn)
	return oBtn
end

function CTeamMemberOpView.ShowPlayerInfo(self, pid)
	netplayer.C2GSGetPlayerInfo(pid)
end

function CTeamMemberOpView.SwitchPos(self, pid)
	if g_LimitCtrl:CheckIsCannotMove() then
		return
	end
	if not g_TeamCtrl:IsInTeam(pid) then
		g_NotifyCtrl:FloatMsg("只可操作在线队员")
		return
	end
	local oView = CTeamMainView:GetView()
	if oView and oView.m_MainPart then
		oView.m_MainPart:ShowSwitchPanel(pid, false)
	end
end

function CTeamMemberOpView.ShowArrow(self)
	self.m_ArrowSpr:SetActive(true)
end

function CTeamMemberOpView.ApplyLeader(self)
	if g_LimitCtrl:CheckIsCannotMove() then
		return
	end
	
	local record = g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.TeamApplyLeader,
		 g_TeamCtrl.m_TeamID) 
	if g_TeamCtrl:IsLeaderActive() then
		local iTime = DataTools.GetGlobalData(106).value or 12
		g_NotifyCtrl:FloatMsg(string.format("队长离开%d分钟后，才能申请成为队长", iTime)) --12分钟我早怒退游戏
	else
		if record then
			g_NotifyCtrl:FloatMsg("申请太频繁，请稍后再试")
		else
			local iCDTime = tonumber(DataTools.GetGlobalData(114).value)
			netteam.C2GSApplyLeader()
			g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.TeamApplyLeader,
				 g_TeamCtrl.m_TeamID, iCDTime) 
		end
	end
end

function CTeamMemberOpView.LeaveTeam(self, pid, bIsWar, bIsCacheLeave)
	if g_LimitCtrl:CheckIsCannotMove() then
		return
	end
	local func = function() 
		netteam.C2GSLeaveTeam() 
		local oHero = g_MapCtrl:GetHero()
		if oHero then
			oHero:StopWalk()
		end
	end
	local iSize = g_TeamCtrl:GetMemberSize()
	if iSize < 2 then
		func()
	else
		if bIsCacheLeave then
			func()
			return
		end
		local sMsg = "是否确定离开队伍？"
		if next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.LINGXI.ID]) then
			sMsg = "强行退出队伍会导致任务失败，是否继续？"
		end
		self:OpenConfirmWindow(sMsg, func, 30, 0)
	end
end

function CTeamMemberOpView.SKickOutTeam(self, pid, bIsWar, bIsCacheSkickOut)
	if g_LimitCtrl:CheckIsCannotMove() then
		return
	end
	local func = function() 
		netteam.C2GSKickOutTeam(pid)
	end
	if bIsCacheSkickOut then
		func()
		return
	end
	local sName = g_TeamCtrl:GetMember(pid).name
	local sMsg = string.format("你是否要请离[c]#G%s#n", sName)
	self:OpenConfirmWindow(sMsg, func)
end

function CTeamMemberOpView.SetLeader(self, pid, bIsWar, bIsCacheSetLeader)
	if g_LimitCtrl:CheckIsCannotMove() then
		return
	end

	local func = function() 
		netteam.C2GSSetLeader(pid)
	end
	if bIsCacheSetLeader then
		func()
		return
	end
	local sName = g_TeamCtrl:GetMember(pid).name
	local sMsg = ""
	if g_MapCtrl.m_MapID == 503000 then
		sMsg = "只有队长能获得首席积分，切换队长后新队长将获得首席积分，确定转移队长吗？"
	else
		sMsg = string.format("你确定要将队长移交给[c]#G%s#n", sName)
	end
	self:OpenConfirmWindow(sMsg, func)
end

function CTeamMemberOpView.OpenConfirmWindow(self, sMsg, func, iCountdown, iDefault)
	local windowConfirmInfo = {
		msg = sMsg,
		okCallback = func,	
		pivot = enum.UIWidget.Pivot.Center,
		countdown = iCountdown or 0,
		default = iDefault or 0,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CTeamMemberOpView.SummonMember(self, bIsWar)
	if bIsWar then
		g_NotifyCtrl:FloatMsg("队长战斗中无法召回")
		return
	end
	netteam.C2GSTeamSummon(self.m_Pid)
end

function CTeamMemberOpView.AppointMember(self, pid, status)
	if g_LimitCtrl:CheckIsCannotMove() then
		return
	end
	if g_TeamCtrl:IsLeave(self.m_Pid) or g_TeamCtrl:IsOffline(self.m_Pid) then
		g_NotifyCtrl:FloatMsg("只能委任归队队员")
		return
	end
	netteam.C2GSSetAppointMem(pid, status)
end
return CTeamMemberOpView
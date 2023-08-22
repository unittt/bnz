CWorldBossCtrl = class("CWorldBossCtrl", CCtrlBase)

function CWorldBossCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_CurStep = -1
	self.m_CurTimes = 0
	self.m_EventList = {}
	self.m_BossStartTime = 0    --活动开始时间
	self.m_BossTime = -1		--挑战波旬的CD时间
	self.m_PlunderTime = -1		--掠夺积分的CD时间
	self.m_OrgRankList = {}
	self.m_PlayerRankList = {}
	self.m_MyOrgInfo = {} 
	self.m_MyRankInfo = {}
	self.m_PlunderList = {}
	self.m_RefreshInterval = 30 --自动刷新频率
	self.m_ActiveStatus = define.WorldBoss.Status.NotStart
end

function CWorldBossCtrl.SetPlayerRankList(self, tPlayrList, iMyRank, iMyPoint)
	self.m_PlayerRankList = tPlayrList
	self.m_MyRankInfo.rank = iMyRank
	self.m_MyRankInfo.point = iMyPoint
	self:InitStepInfo()
	self:OnEvent(define.WorldBoss.Event.RefreshPlayerList)
end

function CWorldBossCtrl.SetOrgRankList(self, tOrgList, iMyRank, iMyPoint, iTotal, sChairman)
	self.m_OrgRankList = tOrgList
	self.m_MyOrgInfo.rank = iMyRank
	self.m_MyOrgInfo.point = iMyPoint
	self.m_MyOrgInfo.total = iTotal
	self.m_MyOrgInfo.chairman = sChairman
	self:OnEvent(define.WorldBoss.Event.RefreshOrgList)
end

function CWorldBossCtrl.SetBossStartTime(self, iTime)
	self.m_BossStartTime = iTime
	if self.m_BossStartTime > g_TimeCtrl:GetTimeS() then
		self:SetCDTime(self.m_BossStartTime, self.m_BossStartTime)
	end
end

function CWorldBossCtrl.SetCDTime(self, iBossTime, iPlunderTime)
	self.m_BossTime = iBossTime
	self.m_PlunderTime = iPlunderTime
end

function CWorldBossCtrl.SetEventList(self, tEventList)
	self.m_EventList = tEventList
	self:OnEvent(define.WorldBoss.Event.RefreshEventList)
end

function CWorldBossCtrl.SetPlunderList(self, tPlunderList)
	self.m_PlunderList = tPlunderList
	self:OnEvent(define.WorldBoss.Event.RefreshPlunderList)
end

function CWorldBossCtrl.UpdatePlunderStatus(self, iPid, iProtectTime)
	self:OnEvent(define.WorldBoss.Event.RefreshPlunderStatus, {pid = iPid, time = iProtectTime})
end

function CWorldBossCtrl.SetStepStatus(self, iStep, iTimes)
	self.m_CurStep = iStep
	self.m_CurTimes = iTimes
end

function CWorldBossCtrl.GetCurrentStep(self)
	return self.m_CurStep
end

function CWorldBossCtrl.GetCurrentTimes(self)
	return self.m_CurTimes
end

function CWorldBossCtrl.GetBossStartTime(self)
	return self.m_BossStartTime
end

function CWorldBossCtrl.GetBossCDTime(self)
	return self.m_BossTime
end

function CWorldBossCtrl.GetPlunderCDTime(self)
	return self.m_PlunderTime
end

function CWorldBossCtrl.GetOrgList(self)
	return self.m_OrgRankList
end

function CWorldBossCtrl.GetPlayerList(self)
	return self.m_PlayerRankList
end

function CWorldBossCtrl.GetMyOrgInfo(self)
	return self.m_MyOrgInfo
end

function CWorldBossCtrl.GetPlunderList(self)
	return self.m_PlunderList
end

function CWorldBossCtrl.GetEventList(self)
	local list = {}
	for i,sEvent in ipairs(self.m_EventList) do
		table.insert(list, 1, sEvent)
	end
	return list
end

function CWorldBossCtrl.GetMyRankInfo(self)
	return self.m_MyRankInfo
end

function CWorldBossCtrl.InitStepInfo(self)
	local tConfigList = data.worldbossdata.DATA[1].step_config
	local iNextStepTime = self.m_BossStartTime
	local iCurTime = g_TimeCtrl:GetTimeS()
	self:SetStepStatus(0, 0)
	if iCurTime < self.m_BossStartTime then
		self:OnEvent(define.WorldBoss.Event.RefreshStepStatus)
		self:StartRefreshTimer(0, self.m_BossStartTime - iCurTime)
		if self.m_BossStartTime - iCurTime > 60*5 then
			self:SetCDTime(0, 0)
			self:StopRefreshTimer()
			self.m_ActiveStatus = define.WorldBoss.Status.End
		else
			self.m_ActiveStatus = define.WorldBoss.Status.NotStart
		end
		return
	end
	self.m_ActiveStatus = define.WorldBoss.Status.End
	for i,dStepInfo in ipairs(tConfigList) do
		iNextStepTime = dStepInfo.time*60 + iNextStepTime
		if iNextStepTime > iCurTime then
			self:SetStepStatus(dStepInfo.step, dStepInfo.ratio)
			self:StartStepTimer(iNextStepTime)
			self.m_ActiveStatus = define.WorldBoss.Status.Start
			break
		end
	end
	if self:IsEnd() then
		self:SetCDTime(0, 0)
		self:StopRefreshTimer()
	end
	self:OnEvent(define.WorldBoss.Event.RefreshStepStatus)
end

function CWorldBossCtrl.StartStepTimer(self, iNextStepTime)
	if self.m_StepTimer then
		Utils.DelTimer(self.m_StepTimer)
		self.m_StepTimer = nil
	end
	local function update()
		if iNextStepTime <= g_TimeCtrl:GetTimeS() then
			self:InitStepInfo()
			return false
		end
		return true
	end
	self.m_StepTimer = Utils.AddTimer(update, 1, 0)
end

function CWorldBossCtrl.StartRefreshTimer(self, iDelta, iDelay, bAutoRefresh)
	self:StopRefreshTimer()
	local function check()
		self:InitStepInfo()
		nethuodong.C2GSMengzhuOpenPlayerRank()
		nethuodong.C2GSMengzhuOpenOrgRank()
		if bAutoRefresh then
			return CWorldBossMainView:GetView() ~= nil
		else
			--定时请求刷新
			self:StartRefreshTimer(self.m_RefreshInterval, self.m_RefreshInterval, true)
		end
	end
	self.m_RefreshTimer = Utils.AddTimer(check, iDelta, iDelay + 1)
end

function CWorldBossCtrl.StopRefreshTimer(self)
	if self.m_RefreshTimer then
		Utils.DelTimer(self.m_RefreshTimer)
		self.m_RefreshTimer = nil
	end
end

function CWorldBossCtrl.OpenWorldBossView(self, iState)
	if iState == 1 or iState == 1007 then
		local oView = CWorldBossMainView:GetView()
		if oView then
			oView:CloseView()
		end
		if iState == 1007 then
			local sText = data.worldbossdata.TEXT[iState].content
			g_NotifyCtrl:FloatMsg(sText)
			return
		end
		CWorldBossMainView:ShowView()
	else
		local sText = data.worldbossdata.TEXT[iState].content
		if iState == 1004 then
			local windowConfirmInfo = {
				msg				= sText,
				okCallback		= function ()
					g_OrgCtrl:OpenOrgView()
				end,
				cancelCallback  = function()
				end,
				okStr			= "加入帮派",
				cancelStr		= "关闭",
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		else
			g_NotifyCtrl:FloatMsg(sText)
		end
	end
end

function CWorldBossCtrl.IsEnd(self)
	return self.m_ActiveStatus == define.WorldBoss.Status.End
end

function CWorldBossCtrl.IsStart(self)
	return self.m_ActiveStatus == define.WorldBoss.Status.Start
end

function CWorldBossCtrl.GS2CMengzhuBossResult(self, dPbData)
	CWorldBossWarResultView:ShowView(function(oView)
		oView:SetData(dPbData)
	end)
end

return CWorldBossCtrl
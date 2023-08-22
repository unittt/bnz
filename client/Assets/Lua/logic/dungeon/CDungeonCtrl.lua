local CDungeonCtrl = class("CDungeonCtrl", CCtrlBase)

function CDungeonCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Clear()
end

function CDungeonCtrl.Clear(self)
	--副本进去确认信息
	self.m_DungeonId = -1
	self.m_FinishTime = 0
	self.m_PlayerStatusDict = {}
	self.m_SessionIdx = -1
	self.m_RewardDict = {}
end

function CDungeonCtrl.UpdateConfirmState(self, iFubenId, iTime, Playerlist, iSessionIdx)
	self.m_PlayerStatusDict = {}
	
	self.m_DungeonId = iFubenId
	self.m_FinishTime = g_TimeCtrl:GetTimeS() + iTime
	for i,player in ipairs(Playerlist) do
		self.m_PlayerStatusDict[player.pid] = player.state
	end
	if iSessionIdx then
		self.m_SessionIdx = iSessionIdx
	end
	self:OnEvent(define.Dungeon.Event.RefreshComfirm)
end

function CDungeonCtrl.SetPlayerConfirmStatus(self, iPid)
	self.m_PlayerStatusDict[iPid] = 1
	if self:CheckConfirmFinish() then
		self:OnEvent(define.Dungeon.Event.FinishComfirm)
		return
	end
	self:OnEvent(define.Dungeon.Event.RefreshPlayerComfirm, iPid)
end

function CDungeonCtrl.CheckConfirmFinish(self)
	for k,state in pairs(self.m_PlayerStatusDict) do
		if state == 0 then
			return false
		end
	end
	return true
end

function CDungeonCtrl.GeConfirmFinishTime(self)
	return self.m_FinishTime or 0
end

function CDungeonCtrl.GetPlayerConfirmState(self, iPid)
	return self.m_PlayerStatusDict[iPid]
end

function CDungeonCtrl.GetConfirmSession(self)
	return self.m_SessionIdx
end

function CDungeonCtrl.GetDungeonId(self)
	return self.m_DungeonId
end

function CDungeonCtrl.GetDungeonRewardCnt(self, iFubenId)
	return self.m_RewardDict[iFubenId] or 0
end

function CDungeonCtrl.GS2CJYFBGameOver(self, pbdata)
	-- 播放胜利音效
	if pbdata.open == 1 then
		g_AudioCtrl:NpcPath(define.Audio.MusicPath.warwin, 0.1)
		CDungeonRewardView:CloseView()
		CDungeonRewardView:ShowView(function(oView)
			oView:SetEliteDungeonInfo(pbdata)
		end)
	else
		self:OnEvent(define.Dungeon.Event.RefreshRewardView, pbdata)
	end
	g_DungeonTaskCtrl:JyFubenOver()
end

function CDungeonCtrl.GS2CJYFubenFloorName(self, iFloor, sName)
    CDungeonTitleView:ShowView(function(oView)
        oView:SetInfo(iFloor, sName)
    end)
    g_DungeonTaskCtrl:UpdateJyFubenFloor(sName, iFloor)
end

function CDungeonCtrl.GS2CRefreshFubenRewardCnt(self, rewardList)
	for i, v in ipairs(rewardList) do
		self.m_RewardDict[v.fuben_id] = v.reward_cnt or 0
	end
end

return CDungeonCtrl
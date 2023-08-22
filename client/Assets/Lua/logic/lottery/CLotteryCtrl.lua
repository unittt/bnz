local CLotteryCtrl = class("CLotteryCtrl", CCtrlBase)

function CLotteryCtrl.ctor(self)
	-- body
	CCtrlBase.ctor(self)
	self:Reset()
end

function CLotteryCtrl.Reset(self)
	self.m_CaishenCostIdx = -1
	self.m_LotteryData = {}
	self.m_lotteryCount = 0
	self.m_LastRecordTime = 0
	self.m_EndTime = nil
	self.m_HasClickCaishen = false
	self.m_GroupKey = nil
	self.m_CaishenCount = 0
	self.m_CaishenStatus = 0
end

function CLotteryCtrl.GetLotteryData(self)
	return self.m_LotteryData
end

function CLotteryCtrl.IsCaishenOpen(self)
    if 1 ~= self.m_CaishenStatus or not g_OpenSysCtrl:GetOpenSysState(define.System.CaiShen) then
        return false
    end
	local iCurIdx = self.m_CaishenCostIdx
	local bOpen = true
    if self.m_CaishenCount <= 0 then
		bOpen = false
	else
		-- local config = DataTools.GetLotteryData("CAISHEN_CONFIG", 1)
		local iCurTime = g_TimeCtrl:GetTimeS()
	    -- local year,month,day,hour,min,sec= config.end_time:match('^(%d+)%-(%d+)%-(%d+) (%d+)%:(%d+)%:(%d+)')
	    -- local iEndTime = os.time({
	    --     year = tonumber(year),
	    --     month = tonumber(month),
	    --     day = tonumber(day),
	    --     hour = tonumber(hour),
	    --     min = tonumber(min),
	    --     sec = tonumber(sec),
	    -- })
	    if not self.m_EndTime or iCurTime > self.m_EndTime then
	    	bOpen = false
	    end
	end
	return bOpen
end

function CLotteryCtrl.SetClickCaishen(self)
	self.m_HasClickCaishen = true
	self:OnEvent(define.WelFare.Event.UpdateCaishenRedPoint)
end

function CLotteryCtrl.GetIsHasCaishenRedPoint(self)
    if g_LotteryCtrl:IsCaishenOpen() then
        return not self.m_HasClickCaishen
    end
    return false
end

function CLotteryCtrl.AskForCaishenRecords(self)
	nethuodong.C2GSCaishenRefreshRecordList(g_LotteryCtrl.m_LastRecordTime)
end

function CLotteryCtrl.GS2CPlayLottery(self, data)
    --data.sessionidx)
	--data.type)
	--data.idx)  配置表index
	self.m_LotteryData = data
	if data.type == 1001 then
		CLotteryView:GetView():StartToPlayLottery(data)
	else
		self:OnEvent(define.WelFare.Event.StartLottery, data)
	end
end

--抽奖剩余次数
function CLotteryCtrl.GS2CLotteryCount(self, count)
	
	 self.m_lotteryCount = count
	 
	 if CLotteryView:GetView() ~= nil then 

		CLotteryView:GetView():UpdateLotteryCount(count)

	 end 
	 

end

function CLotteryCtrl.GS2CCaishenRefreshRewardKey(self, pbdata)
	self.m_CaishenCostIdx = pbdata.reward_key or 0
	self.m_GroupKey = pbdata.group_key
	self.m_EndTime = pbdata.end_time
	self.m_CaishenCount = pbdata.reward_surplus
	self.m_CaishenStatus = pbdata.status
	self:OnEvent(define.WelFare.Event.UpdateCaishenPnl)
end

function CLotteryCtrl.GS2CCaishenRefreshRewardRecord(self, pbdata)
	self.m_LastRecordTime = pbdata.last_time
	self:OnEvent(define.WelFare.Event.ReceiveCaishenRecords, pbdata.record_list)
end

return CLotteryCtrl
local CEveryDayChargeCtrl = class("CEveryDayChargeCtrl", CCtrlBase)


function CEveryDayChargeCtrl.ctor(self)
	CCtrlBase.ctor(self)
	
	self.m_ServerEndtime = nil
	self.m_ServerRewardList = nil
	self.m_RewardKey = nil
	self.m_IsOpening = false
	self.m_OldDay = 0
	self.m_CurDay = 0
	-- self.m_EveryDayTimer = nil
end

function CEveryDayChargeCtrl.ClearAll(self)
	self.m_ServerEndtime = nil
	self.m_ServerRewardList = nil
	self.m_IsOpening = false
	self.m_OldDay = 0
	
	-- if (self.m_EveryDayTimer ~= nil) then
	-- 	Utils.DelTimer(self.m_EveryDayTimer)
	-- 	self.m_EveryDayTimer = nil
	-- end
end

function CEveryDayChargeCtrl.IsOpening(self)
	if (self.m_ServerEndtime ~= nil) then
		local s = self.m_ServerEndtime - g_TimeCtrl:GetTimeS()
		if s > 0 then
			return true
		end
	end
		
	return false
end

function CEveryDayChargeCtrl.GS2CEveryDayChargeStart(self, pbdata)
	self.m_ServerEndtime = pbdata.endtime
	self.m_RewardKey = pbdata.reward_key
	self.m_IsOpening = true
	printc(self.m_ServerEndtime, "开启每日单充活动")
	
	--抛出事件
	self:OnEvent(define.EveryDayCharge.Event.EveryDayChargeStart, self)
	
	
	-- if (self.m_EveryDayTimer ~= nil) then
	-- 	Utils.DelTimer(self.m_EveryDayTimer)
	-- 	self.m_EveryDayTimer = nil
	-- end
	
	-- self.m_EveryDayTimer = Utils.AddTimer(function()
	-- 	local curDay = self:GetCurDay()
	-- 	--printc(self.m_OldDay, curDay, "~~~~~~~~~~~~~~111111111")
	-- 	if self.m_OldDay ~= 0 and self.m_OldDay ~= curDay then
	-- 		--抛出事件
	-- 		--printc(self.m_OldDay, curDay, "~~~~~~~~~~~~~~2222222")
	-- 		g_EveryDayChargeCtrl:OnEvent(define.EveryDayCharge.Event.EveryDayChargeNotifyChangeDay)
	-- 	end
	-- 	self.m_OldDay = curDay
	-- 	return true
	-- end, 1, 0)
end

function CEveryDayChargeCtrl.GS2CEveryDayChargeEnd(self)
	self:ClearAll()
	printc("关闭每日单充活动")
	
	--抛出事件
	self:OnEvent(define.EveryDayCharge.Event.EveryDayChargeEnd, self)
	self:OnEvent(define.EveryDayCharge.Event.EveryDayChargeNotifyRefreshRedPoint)
end

function CEveryDayChargeCtrl.GS2CEveryDayChargeReward(self, pbdata)
	local data = pbdata.rewardlist
	self.m_CurDay = pbdata.curday
	self.m_ServerRewardList = {}
	table.copy(data, self.m_ServerRewardList) 
	printc("每日单充活动的数据有刷新")
	table.print(self.m_ServerRewardList)
	
	--抛出事件
	self:OnEvent(define.EveryDayCharge.Event.EveryDayChargeChanged, self)
	self:OnEvent(define.EveryDayCharge.Event.EveryDayChargeNotifyRefreshRedPoint)
end

function CEveryDayChargeCtrl.GetCurDay(self)
	return self.m_CurDay or -1
	-- if self.m_ServerEndtime == nil then
	-- 	return -1
	-- end
		
	-- local s = self.m_ServerEndtime - g_TimeCtrl:GetTimeS()
	-- if s <= 0 then
	-- 	return -1
	-- end
	
	-- local configTable = data.everydaychargedata.CONFIG
	-- local d = s / 86400
	-- if d > configTable[1].gameday then
	-- 	d = configTable[1].gameday
	-- end

	-- local currDay = configTable[1].gameday - self:GetIntPart(d)
	-- if currDay == 0 then
	-- 	currDay = 1
	-- end
	-- return currDay
end

function CEveryDayChargeCtrl.GetIntPart(self, f)
	if f <= 0 then
		return math.ceil(f)
	end
	
	if math.ceil(f) == f then
		f = math.ceil(f)
	else
		f = math.ceil(f) - 1
	end
	
	return f
end

function CEveryDayChargeCtrl.CheckRedPoint(self)
	if self.m_ServerRewardList == nil or table.count(self.m_ServerRewardList) == 0 then
		return false
	end
	
	local currDay = self:GetCurDay()
	--printc(currDay)
	if currDay == -1 then
		return false
	end
	
	for i, v in ipairs(self.m_ServerRewardList) do
		local rewarded = 0
		if v.rewarded ~= nil then
			rewarded = v.rewarded
		end
		if currDay == v.day and v.reward - rewarded > 0 then
			return true
		end
	end
	
	return false
end 

return CEveryDayChargeCtrl
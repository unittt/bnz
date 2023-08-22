local CEveryDayChargePart = class("CEveryDayChargePart", CPageBase)

function CEveryDayChargePart.ctor(self, cb)
	
	CPageBase.ctor(self, cb)

	self.m_EveryDayChargeBox = self:NewUI(1, CEveryDayChargeBox)
	self.m_BoxGrid = self:NewUI(2, CGrid)
	self.m_LabelTime = self:NewUI(3, CLabel)

	self.m_EveryDayChargeBox:SetActive(false)

	self.m_CurrEndTime = nil
end

function CEveryDayChargePart.Destroy(self)
	self.m_CurrEndTime = nil
	g_TimeCtrl:DelTimer(self)
	CPageBase.Destroy(self)
end

function CEveryDayChargePart.OnInitPage(self)
	--printc("OnInitPage")
	if g_EveryDayChargeCtrl.m_IsOpening then
		self:RefreshEventStart()
	else
		self:HideAllBoxs()
	end

	g_EveryDayChargeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CEveryDayChargePart.RefreshEventStart(self)
	--printc("RefreshEventStart")
	self:RefreshAllBoxs()
	
	local configTable = data.everydaychargedata.CONFIG
	if (g_EveryDayChargeCtrl.m_ServerEndtime ~= nil) then
		local s = g_EveryDayChargeCtrl.m_ServerEndtime - g_TimeCtrl:GetTimeS()
		self.m_CurrEndTime = s
		if self.m_CurrEndTime > 0 then
			g_EveryDayChargeCtrl.m_IsRunning = true
		else
			g_EveryDayChargeCtrl.m_IsRunning = false
		end
	else
		self.m_CurrEndTime = configTable[1].gameday * 86400
	end
	
	self:RefreshEndTime()
end

function CEveryDayChargePart.RefreshEventChanged(self)
	--printc("RefreshEventChanged")
	self:RefreshAllBoxs()
end

function CEveryDayChargePart.RefreshEventEnd(self)
	--printc("RefreshEventEnd")
	self:HideAllBoxs()
end


--隐藏所有格子
function CEveryDayChargePart.HideAllBoxs(self)
	local boxList = self.m_BoxGrid:GetChildList()
	if #boxList ~= 0 then 
		for k, v in pairs(boxList) do 
			v:SetActive(false)
		end 
	end 
	
	self.m_LabelTime:SetActive(false)
end

function CEveryDayChargePart.RefreshAllBoxs(self)
	--printc("RefreshAllBoxs")
	self:HideAllBoxs()
	
	-- local configTable = data.everydaychargedata.CONFIG
	local rewardTable = data.everydaychargedata.REWARD
	local rewardList = table.dict2list(rewardTable, "dbkey", false)
	table.sort(rewardList, 
			function(l, r) 
				local li = self:GetCurDayRewardIndex(l["payflag"])
				local ri = self:GetCurDayRewardIndex(r["payflag"])
				--printc(g_EveryDayChargeCtrl, "g_EveryDayChargeCtrl-------------------------")
				--printc(g_EveryDayChargeCtrl.m_ServerRewardList, "g_EveryDayChargeCtrl.m_ServerRewardList-------------------------")
				local lr = (g_EveryDayChargeCtrl.m_ServerRewardList and g_EveryDayChargeCtrl.m_ServerRewardList[li] and g_EveryDayChargeCtrl.m_ServerRewardList[li].reward) or 0
				local lrd = (g_EveryDayChargeCtrl.m_ServerRewardList and g_EveryDayChargeCtrl.m_ServerRewardList[li] and g_EveryDayChargeCtrl.m_ServerRewardList[li].rewarded) or 0						
				local rr = (g_EveryDayChargeCtrl.m_ServerRewardList and g_EveryDayChargeCtrl.m_ServerRewardList[ri] and g_EveryDayChargeCtrl.m_ServerRewardList[ri].reward) or 0
				local rrd = (g_EveryDayChargeCtrl.m_ServerRewardList and g_EveryDayChargeCtrl.m_ServerRewardList[ri] and g_EveryDayChargeCtrl.m_ServerRewardList[ri].rewarded) or 0		
				local lrp = self:IsThereRedPoint(lr, lrd, l.rewardcnt)-- configTable[1].rewardcnt)
				local rrp = self:IsThereRedPoint(rr, rrd, r.rewardcnt)-- configTable[1].rewardcnt)
				if lrp then
					if rrp then
						return tonumber(l["dbkey"]) > tonumber(r["dbkey"]) 
					else
						return true
					end
				else
					if rrp then
						return false
					else
						return tonumber(l["dbkey"]) < tonumber(r["dbkey"]) 
					end
				end
				return tonumber(l["dbkey"]) < tonumber(r["dbkey"]) 
			end)
			
	for i, v in ipairs(rewardList) do
		local box = self.m_BoxGrid:GetChild(i)
			if box == nil then 
				box = self.m_EveryDayChargeBox:Clone()
				self.m_BoxGrid:AddChild(box)
			end 
			box:SetLocalRewardData(v)
			box:SetActive(true)
	end

	--local configTable = data.everydaychargedata.CONFIG
	local boxList = self.m_BoxGrid:GetChildList()
	if #boxList ~= 0 then 
		for k, v in pairs(boxList) do 
			local iMax = v.m_LocalRewardData and v.m_LocalRewardData.rewardcnt
			v:SetLocalMaxRewardCount(iMax)--configTable[1].rewardcnt)
		end 
	end
	
	self.m_LabelTime:SetActive(true)
end

function CEveryDayChargePart.IsThereRedPoint(self, canGetCount, hasGetCount, maxGetCount)
	if hasGetCount >= maxGetCount then
		return false
	else
		if canGetCount - hasGetCount > 0 then
			return true
		else
			return false
		end
	end
end

function CEveryDayChargePart.GetCurDayRewardIndex(self, payFlag)
	local currDay = self:GetCurDay()
	--printc(currDay)
	if currDay == -1 then
		return -1
	end
	
	local flagNumber = DataTools.GetEveryDayChargeFlagToNumber(payFlag)
	for i, v in ipairs(g_EveryDayChargeCtrl.m_ServerRewardList) do
		if v.day == currDay and tonumber(v.flag) == flagNumber then
			return i
		end
	end
	
	return -1
end


function CEveryDayChargePart.GetCurDay(self)
	-- local s = g_EveryDayChargeCtrl.m_ServerEndtime - g_TimeCtrl:GetTimeS()
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
	return g_EveryDayChargeCtrl:GetCurDay() --currDay
end

function CEveryDayChargePart.GetIntPart(self, f)
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

function CEveryDayChargePart.RefreshEndTime(self)
	g_TimeCtrl:StartCountDown(self, self.m_CurrEndTime, 1, function (sTime, iTime)
		if iTime <= 0 then
			g_EveryDayChargeCtrl.m_IsOpening = false

			--抛出事件
			g_EveryDayChargeCtrl:OnEvent(define.EveryDayCharge.Event.EveryDayChargeTimeOut)
            return false
        end
        self.m_LabelTime:SetText(sTime)
	end)
end

--事件
function CEveryDayChargePart.OnCtrlEvent(self, oCtrl)
	--printc(oCtrl.m_EventID, "CEveryDayChargePart.OnCtrlEvent ")
	if oCtrl.m_EventID == define.EveryDayCharge.Event.EveryDayChargeStart then 
		self:RefreshEventStart()
	elseif oCtrl.m_EventID == define.EveryDayCharge.Event.EveryDayChargeChanged then
		self:RefreshEventChanged()		
	elseif oCtrl.m_EventID == define.EveryDayCharge.Event.EveryDayChargeEnd then
		self:RefreshEventEnd()	
	end
end


return CEveryDayChargePart
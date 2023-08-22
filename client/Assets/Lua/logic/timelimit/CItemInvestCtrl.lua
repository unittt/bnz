local CItemInvestCtrl = class("CItemInvestCtrl", CCtrlBase)

function CItemInvestCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self:Clear()
end

function CItemInvestCtrl.Clear(self)
	self.m_State = 0
	self.m_InvestTime = 0
	self.m_RewardTime = 0

	self.m_InvestMode = 0

	self.m_ItemInvestDic = {} --投资信息表, 键为投资道具的id
	self.m_ItemInvestConfig = {}
end

function CItemInvestCtrl.GS2CItemInvestState(self, state, invest_endtime, reward_endtime, mode)	
	self.m_State = state
	self.m_InvestTime = invest_endtime
	self.m_RewardTime = reward_endtime

	self.m_InvestMode = mode --1、新服

	if state == 3 then
		self.m_ItemInvestDic = {}
	end
	self:OnEvent(define.ItemInvest.Event.RefreshItemInvestState)
end

function CItemInvestCtrl.GS2CItemInvest(self, itemInfo)
	for i, v in ipairs(itemInfo) do
		local id = v.invest_id
		self.m_ItemInvestDic[id] = v.day_info
	end
	self:OnEvent(define.ItemInvest.Event.RefreshItemInvestState)
end

function CItemInvestCtrl.GS2CItemInvestUnit(self, invest_id, day_info)
	self.m_ItemInvestDic[invest_id] = day_info
	self:OnEvent(define.ItemInvest.Event.RefreshItemInvestUnit)
end

--活动开启或者开启后第一次登录时活动图标加光圈特效
function CItemInvestCtrl.IsShowFirstEffect(self)
	local bFirst = IOTools.GetRoleData("ItemInvest") or 0
	local opendata = DataTools.GetViewOpenData(define.System.ItemInvest)
	local blevel = g_AttrCtrl.grade >= opendata.p_level
	local bState = self.m_State > 0 and self.m_State < 3

	return (bFirst) == 0 and bState and blevel
end

function CItemInvestCtrl.SaveFirstRecord(self)
	local bFirst = IOTools.GetRoleData("ItemInvest") or 0
	if bFirst == 0 then
		bFirst = 1
		IOTools.SetRoleData("ItemInvest", bFirst)
	end
end

function CItemInvestCtrl.CheckIsRedPoint(self)
	for k, v in pairs(self.m_ItemInvestDic) do
		local bGet = self:IsRewardGet(k)
		if not bGet then --若有未领取的，显示红点
			return true
		end
	end
	return false
end

--道具投资信息
function CItemInvestCtrl.GetItemInvestInfo(self, invest_id)
	local sInfo = self.m_ItemInvestDic[invest_id]
	return sInfo 
end

-- 道具是否已投资
function CItemInvestCtrl.IsItemInvested(self, invest_id)
	local dItem = self.m_ItemInvestDic[invest_id]
	if dItem then
		return true
	else
		return false
	end
end

--奖励是否领取
function CItemInvestCtrl.IsRewardGet(self, invest_id)
	local sInfo = self:GetItemInvestInfo(invest_id)
	local bGet = true
	for i, v in pairs(sInfo) do
		if v.status == 1 then
			bGet = false
			break
		end
	end
	return bGet
end

--奖励是否已全部(10天的奖励)领取
function CItemInvestCtrl.IsRewardAllGet(self, invest_id)
	local sInfo = self:GetItemInvestInfo(invest_id)

	local bGet = true
	if sInfo then
		if table.count(sInfo) < 10 then
			return false
		end
		for i, v in pairs(sInfo) do
			if v.status == 1 then
				bGet = false
			end
		end
	else
		return false
	end
	return bGet
end

--投资时间是否结束
function CItemInvestCtrl.IsInvestTimeEnd(self)
	local dt = self.m_InvestTime - g_TimeCtrl:GetTimeS()
	return dt <= 0
end

--奖励时间是否结束
function CItemInvestCtrl.IsRewardTimeEnd(self)
	local dt = self.m_RewardTime - g_TimeCtrl:GetTimeS()
	return dt <= 0
end

--仅在打开界面时数据排序一次，调用这个接口
function CItemInvestCtrl.GetItemConfigBySort(self)
	if next(self.m_ItemInvestConfig) then
		self.m_ItemInvestConfig = {}
	end

	local dConfig = self:GetItemInvestConfig()

	-- -3、有待领取奖励  -2、当天之前奖励已领完  -1、10天奖励已领完  4、未投资
	for i, v in pairs(dConfig) do
		if not self:IsItemInvested(v.invest_id) then
			v.idx = v.sort
		elseif self:IsRewardAllGet(v.invest_id) then
			v.idx = -1
		elseif self:IsRewardGet(v.invest_id) then
			v.idx = -2
		else
			v.idx = -3
		end
		table.insert(self.m_ItemInvestConfig, v)
	end

	table.sort(self.m_ItemInvestConfig, function(a, b)
		return a.idx < b.idx
	end)

	return self.m_ItemInvestConfig
end

--界面内刷新数据不在重新排序，调用这个接口
function CItemInvestCtrl.GetItemConfigNoSort(self)
	return self.m_ItemInvestConfig
end

--道具配置表
function CItemInvestCtrl.GetItemInvestConfig(self)
	local dConfig 
	if self.m_InvestMode == 1 then
		dConfig = data.iteminvestdata.NEW_ITEM
	else
		dConfig = data.iteminvestdata.OLD_ITEM
	end

	table.sort( dConfig, function(a, b)
		return a.sort < b.sort
	end )

	return dConfig
end

--投资道具的奖励信息
function CItemInvestCtrl.GetItemRewardInfo(self, invest_id)
	local config = self:GetItemInvestConfig()
	for k, v in pairs(config) do
		if v.invest_id == invest_id then
			return v
		end
	end
end

-- 投资指定道具可获得的全部奖励
function CItemInvestCtrl.GetRewardTotalAmount(self, invest_id)
	local config = self:GetItemInvestConfig()
	local dItem = config[invest_id]

	local amount = 0
	for i, v in pairs(dItem.amount) do
		amount = amount + v
	end
	return amount
end

--指定道具下一天可领取的奖励数量
function CItemInvestCtrl.GetNextDayRewardAmount(self, invest_id)
	local sReward = self:GetItemInvestInfo(invest_id)
	local dReward = self:GetItemRewardInfo(invest_id)

	local count = table.count(sReward)
	count = math.clamp(count, 1, 9)

	local amount = dReward.amount[count + 1]
	return amount
end

--活动是否开启
function CItemInvestCtrl.IsItemInvestOpen(self)
	if self.m_State == 0 or self.m_State == 3 then
		return false
	end

	--投资时间结束后没有投资内容，界面关闭
	local investAmount = table.count(self.m_ItemInvestDic)
	if self.m_State == 2 and investAmount <= 0 then
		return false 
	elseif investAmount <= 0 then
		return true
	end

	--所以已投资道具的奖励都已领完
	local bOpen = false
	for k, v in pairs(self.m_ItemInvestDic) do
		local sInfo = self:GetItemInvestInfo(k)
		if table.count(sInfo) < 10 then --未满10天，继续打开
			return true
		end
		local bGet = self:IsRewardGet(k)
		if not bGet then --只要有一个没领完，界面就继续打开
			bOpen = true
		end
	end
	return bOpen
end

return CItemInvestCtrl
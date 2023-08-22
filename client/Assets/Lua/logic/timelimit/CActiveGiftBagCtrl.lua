local CActiveGiftBagCtrl = class("CActiveGiftBagCtrl", CCtrlBase)

function CActiveGiftBagCtrl.ctor(self)
	CCtrlBase.ctor(self)
	
	self:ClearAll()
end

function CActiveGiftBagCtrl.ClearAll(self)
	self.m_GiftState = {}
	self.m_GiftDic = {}
	for i,v in ipairs(data.activegiftbagdata.REWARD) do
		self.m_GiftDic[i] = {reward_state = 0, gridDic = {}}
	end
	self.m_GiftTotalPoint = 0
end

-- 以下协议接收处理
function CActiveGiftBagCtrl.GS2COpenActivePointGiftView(self, gift_list)
	for _,v in ipairs(gift_list) do
		local gridDic = {}
		for _,y in ipairs(v.grid_list) do
			gridDic[y.grid_id] = y.option
		end
		self.m_GiftDic[v.point_key] = {reward_state = v.reward_state, gridDic = gridDic}
	end
	self:OnEvent(define.ActiveGiftBag.Event.ActiveGiftBagInfoChanged)
end

function CActiveGiftBagCtrl.GS2CActivePointGiftTotalPoint(self, total_point)
	self.m_GiftTotalPoint = total_point
	self:OnEvent(define.ActiveGiftBag.Event.ActiveGiftBagTotalPointChanged)
end

function CActiveGiftBagCtrl.GS2CActivePointGiftState(self, giftState)
	self.m_GiftState = giftState
	if giftState.state == nil or giftState.state == 0 then
		self:OnEvent(define.ActiveGiftBag.Event.ActiveGiftBagEnd)
		self:ClearAll()
	elseif giftState.state == 1 then
		self:OnEvent(define.ActiveGiftBag.Event.ActiveGiftBagStart)
	elseif giftState.state == 2 then
		printerror("@服务器错误数据：“等待开启”暂时没有用的状态")
	end
end

function CActiveGiftBagCtrl.GS2CActivePointSetGridOptionResult(self, point_key, grid_id, option)
	if not self.m_GiftDic[point_key] then
		self.m_GiftDic[point_key] = {}
	end
	if not self.m_GiftDic[point_key].gridDic then
		self.m_GiftDic[point_key].gridDic = {}
	end
	self.m_GiftDic[point_key].gridDic[grid_id] = option

	self:OnEvent(define.ActiveGiftBag.Event.ActiveGiftBagSlotChanged)
end

-- 获取数据
function CActiveGiftBagCtrl.GetCDTime(self)
	local timeSpan = 0
	if self.m_GiftState and self.m_GiftState.state == 1 and self.m_GiftState.end_time then
		timeSpan = self.m_GiftState.end_time - g_TimeCtrl:GetTimeS()
	end
	return timeSpan
end

-- 获取显示的奖励档位
function CActiveGiftBagCtrl.GetShowGiftBagSelectIndex(self)
	local giftIndex = 1
	if self.m_GiftDic and next(self.m_GiftDic) then
		local pointKey = 999
		table.print(self.m_GiftDic, "获取显示的奖励档位")
		for k,v in pairs(self.m_GiftDic) do
			if v.reward_state and v.reward_state < 2 then
				if k < pointKey then
					pointKey = k
				end
			end
		end
		if pointKey < 999 then
			return pointKey
		end
	end
	return 1
end

-- 获取每档配置信息
function CActiveGiftBagCtrl.GetGiftBagConfig(self, giftIndex)
	return data.activegiftbagdata.REWARD[giftIndex]
end

-- 获取服务器奖励信息
function CActiveGiftBagCtrl.GetGiftBagInfo(self, giftIndex)
	if self.m_GiftDic then
		return self.m_GiftDic[giftIndex]
	end
end

-- 获取显示的slot列表
function CActiveGiftBagCtrl.GetGiftSlotList(self, giftIndex)
	local giftBagConfig = self:GetGiftBagConfig(giftIndex)
	local slotList = {}
	for i=1,5 do
		local slot = giftBagConfig["slot"..i]
		if slot and next(slot) then
			table.insert(slotList, slot)
		else
			break
		end
	end
	return slotList
end

-- 获取当前需要显示的奖励
function CActiveGiftBagCtrl.GetGiftSlotRewardInifo(self, giftIdx, slotIdx)
	local slotList = self:GetGiftSlotList(giftIdx)
	local slot = slotList[slotIdx]
	local slotIndex = self:GetGiftSlotRewardIndex(giftIdx, slotIdx)
	return slot[slotIndex]
end

-- 获取当前选择的奖励下标
function CActiveGiftBagCtrl.GetGiftSlotRewardIndex(self, giftIdx, slotIdx)
	local slotIndex = 1
	local giftBagInfo = self:GetGiftBagInfo(giftIdx)
	if giftBagInfo and giftBagInfo.gridDic then
		local idx = giftBagInfo.gridDic[slotIdx]
		if idx and idx > 0 then
			slotIndex = idx
		end
	end
	return slotIndex
end

function CActiveGiftBagCtrl.CheckRedPoint(self)
	local bHasRedPoint = false
	if self:GetCDTime() > 0 then
		if self.m_GiftDic then
			for _,v in pairs(self.m_GiftDic) do
				if v.reward_state == 1 then
					bHasRedPoint = true
					break
				end
			end
		end
	end
	-- printerror(bHasRedPoint, " ========== CActiveGiftBagCtrl.CheckRedPoint")
	return bHasRedPoint
end 


return CActiveGiftBagCtrl
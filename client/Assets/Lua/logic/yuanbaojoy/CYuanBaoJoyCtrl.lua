local CYuanBaoJoyCtrl = class("CYuanBaoJoyCtrl", CCtrlBase)

function CYuanBaoJoyCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Clear()
	self:CheckPrizeConfig()
end

function CYuanBaoJoyCtrl.Clear(self)
	self.m_IsOpenState = false
	self.m_BaoxiangPoint = 0
	self.m_BaoxiangRewardList = {}
	self.m_RecordList = {}
	self.m_PrizeShowRewardList = {}
	self.m_AllGoldCoin = 0
	self.m_EndTime = 0
	self.m_QuestionState = true
end

function CYuanBaoJoyCtrl.GS2CGoldCoinPartyStart(self, pbdata)
	self.m_IsOpenState = true
	self:OnEvent(define.YuanBaoJoy.Event.RefreshOpenState)
end

function CYuanBaoJoyCtrl.GS2CGoldCoinPartyEnd(self, pbdata)
	self.m_IsOpenState = false
	self:OnEvent(define.YuanBaoJoy.Event.RefreshOpenState)
end

function CYuanBaoJoyCtrl.GS2CGoldCoinPartyReward(self, pbdata)
	self.m_BaoxiangPoint = pbdata.point
	self.m_BaoxiangRewardList = pbdata.rewardlist
	self.m_RecordList = pbdata.recordlist
	self.m_AllGoldCoin = pbdata.allgoldcoin
	self.m_EndTime = pbdata.endtime
	self:OnEvent(define.YuanBaoJoy.Event.RefreshInfo)
end

function CYuanBaoJoyCtrl.GS2CGoldCoinPartyLottery(self, pbdata)
	self.m_PrizeShowRewardList = pbdata.rewardlist
	self:OnEvent(define.YuanBaoJoy.Event.RefreshPrizeEffect)
end

function CYuanBaoJoyCtrl.GS2CGoldCoinPartyUpdateInfo(self, pbdata)
	self.m_AllGoldCoin = pbdata.allgoldcoin
	self.m_RecordList = pbdata.recordlist
	self:OnEvent(define.YuanBaoJoy.Event.RefreshInfo)
end

function CYuanBaoJoyCtrl.OnShowYuanBaoMainView(self)
	if not g_OpenSysCtrl:GetOpenSysState(define.System.YuanBaoJoy, true) then
		return
	end
	CYuanBaoJoyView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

function CYuanBaoJoyCtrl.CheckIsYuanBaoJoyOpen(self)
	return g_OpenSysCtrl:GetOpenSysState(define.System.YuanBaoJoy) and self.m_IsOpenState
end

function CYuanBaoJoyCtrl.CheckIsYuanBaoJoyRedPoint(self)
	for k,v in pairs(self.m_BaoxiangRewardList) do
		if v == 1 then
			return true
		end
	end
end

function CYuanBaoJoyCtrl.CheckIsYuanBaoJoyEnd(self, bNotFloat)
	-- if (self.m_EndTime - g_TimeCtrl:GetTimeS()) <= 0 then
	if not self.m_IsOpenState then
		if not bNotFloat then
			g_NotifyCtrl:FloatMsg("活动已结束了哦")
		end
		return true
	end
end

function CYuanBaoJoyCtrl.CheckPrizeConfig(self)
	self.m_PrizeConfigList = {}
	self.m_PrizeConfigHashList = {}
	for k,v in pairs(data.yuanbaojoydata.PRIZEREWARD) do
		if v.sort ~= 0 then
			table.insert(self.m_PrizeConfigList, v)
			self.m_PrizeConfigHashList[v.pos] = v
		end
	end
	table.sort(self.m_PrizeConfigList, function (a, b)
		return a.sort < b.sort
	end)
end

function CYuanBaoJoyCtrl.GetPrizeRadioMinToPos(self)
	local oPos
	local oValue
	for k,v in pairs(self.m_PrizeShowRewardList) do
		if not oPos then
			oPos = v.pos
			oValue = v
		else
			if tonumber(self.m_PrizeConfigHashList[oPos].ratio) > tonumber(self.m_PrizeConfigHashList[v.pos].ratio) then
				oPos = v.pos
				oValue = v
			end
		end
	end
	return oPos, oValue
end

--十抽的时候一些图标是特殊显示
function CYuanBaoJoyCtrl.GetPrizeTenShowList(self)
	local oList = {}
	for k,v in ipairs(self.m_PrizeShowRewardList) do
		if v.pos == 14 then
			table.insert(oList, {id = "yuanbaojoy1", amount = 1, sid = "yuanbaojoy1"})
		elseif v.pos == 13 then
			table.insert(oList, {id = "yuanbaojoy2", amount = 1, sid = "yuanbaojoy2"})
		elseif v.pos == 12 then
			table.insert(oList, {id = "yuanbaojoy3", amount = 1, sid = "yuanbaojoy3"})
		else
			table.insert(oList, {id = tonumber(self.m_PrizeConfigHashList[v.pos].itemsid), amount = v.amount, sid = tonumber(self.m_PrizeConfigHashList[v.pos].itemsid)})
		end
	end
	return oList
end

return CYuanBaoJoyCtrl
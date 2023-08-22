local CSuperRebateCtrl = class("CSuperRebateCtrl", CCtrlBase)

function CSuperRebateCtrl.ctor(self)
	-- body
	CCtrlBase.ctor(self)
	self:Clear()
end

function CSuperRebateCtrl.Clear(self)
	-- body
	self.m_MaxLotteryCnt = data.superrebatedata.CONFIG[1].lotterycnt
	self.m_HasLotteryCnt = 0
	self.m_GoldCoinValue = nil
	self.m_RebateMul = nil
	self.m_SuperrebateTime = 0
	-- self.m_Timer = nil
	self.m_RecordList = {}
end

function CSuperRebateCtrl.SuperRebateStart(self, time)
	-- if time and time >  0 then		
	-- end
	self.m_SuperrebateTime = time 
	self:OnEvent(define.SuperRebate.Event.SuperRebateStart)
end

function CSuperRebateCtrl.GS2CSuperRebateEnd(self)
	-- body
	self.m_SuperrebateTime = 0
	self:OnEvent(define.SuperRebate.Event.SuperRebateEnd)
end

function CSuperRebateCtrl.GS2CSuperRebateReward(self, pbdata)
	-- body
	self.m_HasLotteryCnt = pbdata.lotterycnt or 0
	self.m_GoldCoinValue = pbdata.value or 0
	self.m_RebateMul = pbdata.rebate  or 0
	if self.m_GoldCoinValue and self.m_GoldCoinValue >=0 and self.m_RebateMul == 0 then
		self:OnEvent(define.SuperRebate.Event.RereshSuperRebateValue)
	end
	if self.m_RebateMul and self.m_RebateMul> 0 then
		self:OnEvent(define.SuperRebate.Event.RefreshSuperRebateMul)
	end
end
--领取按钮 红点提示
function CSuperRebateCtrl.HasReceiveBtnRedPoint(self)
	-- body
	if self.m_GoldCoinValue and self.m_GoldCoinValue > 0  then
		return true
	end
	return false
end
-- --主界面, 
function CSuperRebateCtrl.MainMenuSuperrebateRedPoint(self)
	-- body
	return self:HasReceiveBtnRedPoint() or self:LotteryBtnHasRedPoint()
end
-- 抽奖按钮
function CSuperRebateCtrl.LotteryBtnHasRedPoint(self)
	local sign = true
	if self.m_RebateMul and self.m_RebateMul> 0  then
		sign =  false
	end
	if self.m_MaxLotteryCnt - self.m_HasLotteryCnt <= 0 then
		sign = false
	end
	return sign
end

function CSuperRebateCtrl.GS2CSuperRebateRecord(self, recordlist)
	-- body
	self.m_RecordList = recordlist
	self:OnEvent(define.SuperRebate.Event.RecordList)
end




return CSuperRebateCtrl
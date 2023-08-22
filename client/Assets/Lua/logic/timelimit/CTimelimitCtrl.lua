local CTimelimitCtrl = class("CTimelimitCtrl", CCtrlBase)

function CTimelimitCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:InitTabList()
    self:RegisterRedPointFuncs()
    self:RegisterOpenChecks()
    self:Clear()
    -- 关闭系统表
    self.m_BanSys = {
        -- "RebateExplain",
        -- "Exchange",
        -- "ActiveGiftBag",
    }
    self.m_FlopTotal = 6
end

-- 重登需要清除的数据
function CTimelimitCtrl.Clear(self)
    self.m_SevenDayStart = 0
    self.m_SevenDayEnd = 0
    self.m_SevenDayRewardList = {}
    self.m_GroupKey = nil --奖励组id（来源于运营后台）
    self.m_AccConsumeRewardList =  {}--奖励列表
    self.m_TodayConsume =  0--今日花费的元宝数
    self.m_DayExpenseEndTime = 0  --活动结束时间
    self.m_DayExpenseState = 0 --活动状态(控制活动ui是否显示)
    self.m_NextTimer = nil
    self.m_FlopEndTime = 0
    self.m_FlopOpenState = 0
    self.m_FlopCouldResetTime = 0
    self.m_FlopHasPurchaseTime = 0
    self.m_FlopCardList = {}
    self.m_FlopCardHashList = {}
    self.m_FlopRandomCardList = {}
    self.m_NotFlopCardCount = 0

    --限时活动：每日冲榜
    self.m_EverydayRankStartTime = 0
    self.m_EverydayRankEndTime = 0

    self.m_FlopPopupState = 0
    self.m_FlopCardShowEffectList = {}

    self.m_FlopCardInit = false
    self.m_FlopCardResetInit = false
    self.m_IsFlopCheckRedPoint = false

    self.m_CurDiscountDay = 0
    self.m_IsBuyDiscount = false
    self.m_DiscountSaleTime = nil
    self.m_DiscountSaleInfo = nil
    self.m_FirstOpenDiscount = true
    self:StopDiscountCloseTimer()
end

function CTimelimitCtrl.InitTabList(self)
    local allTabList = define.Timelimit.Tab
    self.m_AllTabList = {}
    for sys, idx in pairs(allTabList) do
        table.insert(self.m_AllTabList, {idx = idx, sys = sys})
    end
    table.sort(self.m_AllTabList, function(a, b)
        return a.idx < b.idx
    end)
end

-- 注册红点检测函数(名称)，返回bool
function CTimelimitCtrl.RegisterRedPointFuncs(self)
    self.m_RedPointCheckers = {
        SevenDay = "CheckSevenDayRedPoint",
        EveryDayCharge = "CheckEveryDayChargeRedPoint",
        AccCharge = "CheckAccumChargeRedPoint",
        --CaiShen = "CheckCaishenRedPoint",
        AccConsume = "AccmulConsumeRedPoint",
        ActiveGiftBag = "CheckActiveGiftBagRedPoint",
        Flop = "CheckFlopRedPoint",
        HeShenQiFu = "CheckQiFuPoint",
        CollectGift = "CheckCollectRedPoint",
        ContCharge = "CheckContChargeRedPoint",
        ContConsume = "CheckContConsumeRedPoint",
        ItemInvest = "CheckItemInvestRedPoint",
    }
end

-- 特殊开启条件检测
function CTimelimitCtrl.RegisterOpenChecks(self)
    self.m_OpenChecks = {
        AccCharge = "CheckAccumChargeOpen",
        SevenDay = "CheckSevenDayOpen",
        --CaiShen = "CheckCaishenOpen",
		EveryDayCharge = "CheckEveryDayChargeOpen",
        AccConsume =  "AccmulativeConsume",
        ActiveGiftBag = "CheckActiveGiftBagOpen",
        Flop = "CheckIsFlopIsOpen",
        HeShenQiFu = "CheckIsQiFuOpen",
        CollectGift = "CheckCollectOpen",
        ContCharge = "CheckContChargeOpen",
        ContConsume = "CheckContConsumeOpen",
        ItemInvest = "CheckItemInvestOpen"
    }
end

-- 活动已开启的页签列表
function CTimelimitCtrl.GetOpenTabList(self)
    local openTabList = {}
    --do return openTabList end  --临时屏蔽
    for i, v in ipairs(self.m_AllTabList) do
        if self:IsSysOpen(v.sys) then
            local sSys = define.System[v.sys]
            local dOpen = DataTools.GetViewOpenData(sSys)
            local dTab = {
                name = dOpen.name,
                sys = v.sys,
                idx = v.idx,
            }
            table.insert(openTabList, dTab)
        end
    end
    return openTabList
end

function CTimelimitCtrl.IsSysOpen(self, sys)
    local bOpen = false

    -- 屏蔽的系统
    if table.index(self.m_BanSys, sys) then
        return bOpen
    end

    local sKey = define.System[sys]
    if sKey and g_OpenSysCtrl:GetOpenSysState(sKey) then
        bOpen = true
        -- 有特殊开启条件的系统在这做判断
        local sChecker = self.m_OpenChecks[sys]
        if sChecker and self[sChecker] then
            bOpen = self[sChecker](self)
        end
    end

    return bOpen

end

-- sys为空时检测全部
function CTimelimitCtrl.IsHasRedPoint(self, sys)
    if sys then
        local sChecker = self.m_RedPointCheckers[sys]
        if self:IsSysOpen(sys) and sChecker and self[sChecker] then
            return self[sChecker](self)
        end
    else
        for k, sChecker in pairs(self.m_RedPointCheckers) do
            if self:IsSysOpen(k) and self[sChecker] and self[sChecker](self) then
                return true
            end
        end
    end
    return false
end

--七星宝箱活动时间
function CTimelimitCtrl.GetSevenDayDuration(self)
    local startTime = self.m_SevenDayStart
    local endTime = self.m_SevenDayEnd

    return startTime, endTime
end

--当前登录天数
function CTimelimitCtrl.GetCurLoginDay(self)
    local loginDays = self.m_SevenDayRewardList  --奖励列表，1.可领取 2已领取 ；下标是第几天
    return table.count(loginDays)
end

--------------------- 红点判断 ----------------------
--七星宝箱是否需要红点提示
function CTimelimitCtrl.CheckSevenDayRedPoint(self)
    if self.m_SevenDayEnd == 0 then
        return false
    end
    local rewardList = self.m_SevenDayRewardList
    for i, v in ipairs(rewardList) do
        if v == 1 then
            return true
        end
    end
    return false
end

function CTimelimitCtrl.CheckEveryDayChargeRedPoint(self)
	if g_EveryDayChargeCtrl:CheckRedPoint() then
		return true
	end
	
	return false
end

function CTimelimitCtrl.CheckActiveGiftBagRedPoint(self)
	if g_ActiveGiftBagCtrl:CheckRedPoint() then
		return true
	end
	
	return false
end

function CTimelimitCtrl.CheckAccumChargeRedPoint(self)
    return g_AccumChargeCtrl:IsHasRedDot()
end

function CTimelimitCtrl.CheckCaishenRedPoint(self)
    return g_LotteryCtrl:GetIsHasCaishenRedPoint()
end

function CTimelimitCtrl.AccmulConsumeRedPoint(self)
    local sign = false
    for i,v in ipairs(self.m_AccConsumeRewardList) do
        if v.reward_state == 1  then
            sign = true
        end
    end
    return sign
end

function CTimelimitCtrl.CheckFlopRedPoint(self)
    return self.m_IsFlopHasRedPoint
end

function CTimelimitCtrl.CheckQiFuPoint(self)
    
    return g_HeShenQiFuCtrl:IsHadUnReceiveReward()

end

function CTimelimitCtrl.CheckCollectRedPoint(self)
    return g_WelfareCtrl:IsHadCollectRedPoint()
end

function CTimelimitCtrl.CheckContChargeRedPoint(self)
    return g_ContActivityCtrl:IsChargeHasRedDot()
end

function CTimelimitCtrl.CheckContConsumeRedPoint(self)
    return g_ContActivityCtrl:IsConsumeHasRedDot()
end

function CTimelimitCtrl.CheckItemInvestRedPoint(self)
    local bRedPoint = g_ItemInvestCtrl:CheckIsRedPoint()
    local bFirstOpen = g_ItemInvestCtrl:IsShowFirstEffect()
    return bRedPoint or bFirstOpen
end

--------------------- 系统开启判断 ---------------------
function CTimelimitCtrl.CheckAccumChargeOpen(self)
    return g_AccumChargeCtrl:IsOpen()
end

function CTimelimitCtrl.CheckSevenDayOpen(self) 
    local endTime = self.m_SevenDayEnd or 0
    local leftTime = endTime - g_TimeCtrl:GetTimeS()
    return leftTime > 0 
end

function CTimelimitCtrl.CheckCaishenOpen(self)
    return g_LotteryCtrl:IsCaishenOpen()
end

function CTimelimitCtrl.CheckEveryDayChargeOpen(self)
	local isOpen = g_EveryDayChargeCtrl:IsOpening()
	return isOpen
end

function CTimelimitCtrl.CheckActiveGiftBagOpen(self)
	return g_ActiveGiftBagCtrl:GetCDTime() > 0
end

function CTimelimitCtrl.AccmulativeConsume(self)
    -- body
    return self.m_DayExpenseState == 1 -- 1开启，其他关闭
end

function CTimelimitCtrl.CheckIsFlopIsOpen(self)
    return self.m_FlopOpenState == 1
end

function CTimelimitCtrl.CheckIsQiFuOpen(self)

    return g_HeShenQiFuCtrl:IsHuoDongOpen()

end

function CTimelimitCtrl.CheckEverydayRankOpen(self)
    --TODO:TEST
    local bIsOpen = g_OpenSysCtrl:GetOpenSysState(define.System.EverydayRank)
    local bIsStart = true--g_TimeCtrl:GetTimeS() >= self.m_EverydayRankStartTime
    local bIsEnd = g_TimeCtrl:GetTimeS() > self.m_EverydayRankEndTime
    return bIsOpen and bIsStart and not bIsEnd
end

function CTimelimitCtrl.CheckCollectOpen(self)
    return g_WelfareCtrl:IsCollectOpen()
end

function CTimelimitCtrl.CheckContChargeOpen(self)
    return g_ContActivityCtrl:IsChargeOpen()
end

function CTimelimitCtrl.CheckContConsumeOpen(self)
    return g_ContActivityCtrl:IsConsumeOpen()
end

function CTimelimitCtrl.CheckItemInvestOpen(self)
    return g_ItemInvestCtrl:IsItemInvestOpen()
end

-------------C2GS------------
function CTimelimitCtrl.C2GSSevenDayGetReward(self, day)
    nethuodong.C2GSSevenDayGetReward(day)
end

-------------GS2C------------
function CTimelimitCtrl.GS2CSevenDayDuration(self, starttime, endtime)
    self.m_SevenDayEnd = endtime
    self.m_SevenDayStart = starttime
    self:OnEvent(define.Timelimit.Event.RefreshRedPoint)
end

function CTimelimitCtrl.GS2CSevenDayEnd(self)
    self.m_SevenDayEnd = 0
    self:OnEvent(define.Timelimit.Event.SevenDayEnd)
    self:OnEvent(define.Timelimit.Event.RefreshRedPoint)
end

function CTimelimitCtrl.GS2CSevenDayReward(self, reward)
    self.m_SevenDayRewardList = reward
    self:OnEvent(define.Timelimit.Event.RefreshRedPoint)
    self:OnEvent(define.Timelimit.Event.RefreshSevenLogin)
end

function CTimelimitCtrl.GS2CDayExpenseReward(self, pbdata)
    -- body
    self.m_GroupKey = pbdata.group_key --奖励组id（来源于运营后台）
    self.m_AccConsumeRewardList = pbdata.reward_list or {} --奖励列表
    self.m_TodayConsume = pbdata.goldcoin --今日花费的元宝数
    self.m_DayExpenseEndTime = pbdata.end_time  --活动结束时间
    self.m_DayExpenseState = pbdata.state or 0 --活动状态(控制活动ui是否显示)
    self:OnEvent(define.Timelimit.Event.RefreshDayExpense)
    self:OnEvent(define.Timelimit.Event.RefreshRedPoint)
end

function CTimelimitCtrl.GetDayExpenseStateByIdx(self, idx)
    -- body
    local sign = false
    if next(self.m_AccConsumeRewardList) then
        for i,v in ipairs(self.m_AccConsumeRewardList) do
            if idx == v.reward_key and v.reward_state == 1 then
                sign = true
            end
        end

    end
    return sign
end

function CTimelimitCtrl.GS2CDrawCardState(self, pbdata)
    self.m_FlopEndTime = pbdata.end_time
    self.m_FlopOpenState = pbdata.state

    self:OnEvent(define.Timelimit.Event.RefreshRedPoint)
    self:OnEvent(define.Timelimit.Event.UpdateFlopOpenState)
end

function CTimelimitCtrl.GS2CDrawCardTimes(self, pbdata)
    self.m_FlopCouldResetTime = pbdata.times
    self.m_FlopHasPurchaseTime = pbdata.purchased_times
    self.m_FlopCardResetInit = true
    if not self.m_IsFlopCheckRedPoint then
        if self.m_FlopCouldResetTime > 0 then
            self.m_IsFlopHasRedPoint = true
        else
            self.m_IsFlopHasRedPoint = false
        end
        self.m_IsFlopCheckRedPoint = true
    end
    self:OnEvent(define.Timelimit.Event.RefreshRedPoint)
    self:OnEvent(define.Timelimit.Event.UpdateFlopCardTimes)
end

function CTimelimitCtrl.GS2CDrawCardGetList(self, pbdata)
    self.m_FlopCardList = {}
    self.m_FlopCardHashList = {}
    for k,v in pairs(pbdata.card_list) do
        self.m_FlopCardList[k] = v
        self.m_FlopCardHashList[v.card_id] = v
    end
    self.m_FlopRandomCardList = {}
    table.copy(self.m_FlopCardList, self.m_FlopRandomCardList)
    table.shuffle(self.m_FlopRandomCardList)
    self.m_NotFlopCardCount = pbdata.card_count
    self.m_FlopCardInit = true
    self:OnEvent(define.Timelimit.Event.UpdateFlopCardList)
end

function CTimelimitCtrl.GS2CEveryDayRankStart(self, pbdata)
    self.m_EverydayRankStartTime = pbdata.start_time
    self.m_EverydayRankEndTime = pbdata.end_time
    self.m_RandomRankIndex = pbdata.rank_idx

    self:OnEvent(define.Timelimit.Event.UpdateEverydayRank)
end

function CTimelimitCtrl.GS2CEveryDayRankEnd(self, pbdata)
    self.m_EverydayRankStartTime = 0
    self.m_EverydayRankEndTime = 0
    self:OnEvent(define.Timelimit.Event.UpdateEverydayRank)
end

function CTimelimitCtrl.GS2CDrawCardDrawResult(self, pbdata)
    for k,v in pairs(pbdata.card_list) do
        for g,h in pairs(self.m_FlopCardList) do
            if v.card_id == h.card_id then
                h.card_id = v.card_id
                h.card_info = v.card_info
                h.card_state = v.card_state
                break
            end
        end
        self.m_FlopCardHashList[v.card_id] = v
    end
    
    self.m_FlopCardShowEffectList = {}
    if pbdata.success == 1 then
        self.m_NotFlopCardCount = pbdata.card_count
        for k,v in ipairs(pbdata.card_list) do
            table.insert(self.m_FlopCardShowEffectList, v.card_id)
        end
    end
    self:OnEvent(define.Timelimit.Event.UpdateFlopShowCardEffect)
end

--------------翻牌相关----------------

function CTimelimitCtrl.GetAddResetCost(self)
    local oBuyTime = self.m_FlopHasPurchaseTime + 1
    for k,v in ipairs(data.flopdata.TIMECOST) do
        if v.times_interval[1] <= oBuyTime and oBuyTime <= v.times_interval[2] then
            return v
        end
    end
end

----------------优惠甩卖-----------------------------------
function CTimelimitCtrl.GS2CDiscountSale(self, starttime, buyinfo)
    self.m_CurDiscountDay = 0
    self.m_IsBuyDiscount = false
    self.m_DiscountSaleTime = starttime
    self.m_DiscountSaleInfo = buyinfo
    self.m_MaxDiscountDay = #data.huodongdata.DISCOUNT_GOODS
    self:AutoCloseDiscountSale()
    self:OnEvent(define.Timelimit.Event.RefreshDiscountSale)
end

function CTimelimitCtrl.IsInDiscountTime(self, iDay)
    local iEndTime = self.m_DiscountSaleTime + iDay*(24 * 60 * 60)
    local iStartTime = iEndTime - (24 * 60 * 60)
    local iCurTime = g_TimeCtrl:GetTimeS()

    local bIsInDiscountTime = iEndTime >= iCurTime
    local iRemainTime = (bIsInDiscountTime and iStartTime <= iCurTime) and iEndTime - iCurTime or 0
    local iOpenLeftTime = 0
    if iRemainTime > 0 then
        self.m_CurDiscountDay = iDay
        self.m_IsBuyDiscount = self.m_DiscountSaleInfo[iDay].status == 1
    end
    if iDay - 1 == self.m_CurDiscountDay then
        iOpenLeftTime = self.m_IsBuyDiscount and (iStartTime - iCurTime) or 0
    end
    return bIsInDiscountTime, iRemainTime, iOpenLeftTime
end

function CTimelimitCtrl.CheckDiscountSaleOpen(self)
    if not self.m_DiscountSaleTime then
        return false
    end

    local bIsOpen = g_OpenSysCtrl:GetOpenSysState(define.System.DiscountSale)
    local iStartTime = self.m_DiscountSaleTime
    local iEndTime = self.m_DiscountSaleTime + (24 * 60 * 60)*self.m_MaxDiscountDay
    local iCurTime = g_TimeCtrl:GetTimeS()
    return bIsOpen and iCurTime >= iStartTime and iCurTime <= iEndTime
end

function CTimelimitCtrl.AutoCloseDiscountSale(self)
    self:StopDiscountCloseTimer()
    if not self:CheckDiscountSaleOpen() then
        self:OnEvent(define.Timelimit.Event.RefreshDiscountSale)
        return 
    end

    local iEndTime = self.m_DiscountSaleTime + (24 * 60 * 60)*self.m_MaxDiscountDay
    local function update()
        if g_TimeCtrl:GetTimeS() > iEndTime then
            self:OnEvent(define.Timelimit.Event.RefreshDiscountSale)
            return
        end
        return true
    end
    self.m_DiscountCloseTimer = Utils.AddTimer(update, 1, 0)
end

function CTimelimitCtrl.StopDiscountCloseTimer(self)
    if self.m_DiscountCloseTimer then
        Utils.DelTimer(self.m_DiscountCloseTimer)
        self.m_DiscountCloseTimer = nil
    end
end

return CTimelimitCtrl
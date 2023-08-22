local CContActivityCtrl = class("CContActivityCtrl", CCtrlBase)

function CContActivityCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:Clear()
end

function CContActivityCtrl.Clear(self)
    -- 充值
    self.m_IsChargeOpen = false
    self.m_DayCharge = 0
    self.m_CurChargeDay = 1
    self.m_AccuCharge = 0
    self.m_ChargeDayStates = {}
    self.m_ChargeAccuStates = {}
    self.m_ChargeDayChoices = {}
    self.m_ChargeAccuChoices = {}
    self.m_ChargeStartTime = 0
    self.m_ChargeEndTime = 0
    self.m_ChargeMode = 1
    -- 消费
    self.m_IsConsumeOpen = false
    self.m_DayConsume = 0
    self.m_CurConsumeDay = 1
    self.m_AccuConsume = 0
    self.m_ConsumeDayStates = {}
    self.m_ConsumeAccuStates = {}
    self.m_ConsumeDayChoices = {}
    self.m_ConsumeAccuChoices = {}
    self.m_ConsumeStartTime = 0
    self.m_ConsumeEndTime = 0
    self.m_ConsumeMode = 1
end

------------------------ charge ------------------------
function CContActivityCtrl.IsChargeOpen(self)
    return self.m_IsChargeOpen and g_TimeCtrl:GetTimeS() < self.m_ChargeEndTime
end

function CContActivityCtrl.IsChargeHasRedDot(self)
    local bHas = false
    for i, s in pairs(self.m_ChargeDayStates) do
        if s == 2 then
            bHas = true
            break
        end
    end
    bHas = bHas or self:IsChargeTotalHasRedDot()
    return bHas
end

function CContActivityCtrl.IsChargeTotalHasRedDot(self)
    local bHas = false
    for i, s in pairs(self.m_ChargeAccuStates) do
        if s == 1 then
            bHas = true
            break
        end
    end
    return bHas
end

function CContActivityCtrl.GetChargeDayStatus(self, iDay)
    return self.m_ChargeDayStates[iDay] or 1
end

function CContActivityCtrl.GetChargeAccuStatus(self, iDay)
    return self.m_ChargeAccuStates[iDay] or 0
end

function CContActivityCtrl.GetChargeDayChoice(self, iDay)
    return self.m_ChargeDayChoices[iDay] or {}
end

function CContActivityCtrl.GetChargeAccuChoice(self, iDay)
    return self.m_ChargeAccuChoices[iDay] or {}
end

function CContActivityCtrl.GetChargeAccuDay(self)
    local iAccum = 0
    for i, v in pairs(self.m_ChargeDayStates) do
        if v == 2 or v == 3 then
            iAccum = iAccum + 1
        end
    end
    return iAccum
end

function CContActivityCtrl.GS2CContinuousChargeEnd(self)
    self.m_IsChargeOpen = false
    self:OnEvent(define.Timelimit.Event.EndContCharge)
end

function CContActivityCtrl.GS2CContinuousChargeStart(self, pbData)
    self.m_IsChargeOpen = true
    self.m_ChargeStartTime = pbData.starttime
    self.m_ChargeEndTime = pbData.endtime
    self.m_ChargeMode = pbData.mode
end

function CContActivityCtrl.GS2CContinuousChargeReward(self, pbData)
    self.m_AccuCharge = pbData.totalcoldcoin
    self.m_CurChargeDay = pbData.curday or 1
    self.m_DayCharge = pbData.curgoldcoin
    self.m_ChargeDayStates = {}
    for i, v in ipairs(pbData.states) do
        self.m_ChargeDayStates[v.day] = v.state or 0
    end
    self.m_ChargeAccuStates = {}
    for i, v in ipairs(pbData.totalstates) do
        self.m_ChargeAccuStates[v.day] = v.state or 0
    end
    self.m_ChargeDayChoices = {}
    for i, v in ipairs(pbData.choice) do
        local d = self.m_ChargeDayChoices[v.day]
        if not d then
            d = {}
            self.m_ChargeDayChoices[v.day] = d
        end
        d[v.slot] = v.index
    end
    self.m_ChargeAccuChoices = {}
    for i, v in ipairs(pbData.totalchoice) do
        local d = self.m_ChargeAccuChoices[v.day]
        if not d then
            d = {}
            self.m_ChargeAccuChoices[v.day] = d
        end
        d[v.slot] = v.index
    end
    self:OnEvent(define.Timelimit.Event.UpdateContCharge)
end

--------------------- Consume ----------------------
function CContActivityCtrl.IsConsumeOpen(self)
    return self.m_IsConsumeOpen and g_TimeCtrl:GetTimeS() < self.m_ConsumeEndTime
end

function CContActivityCtrl.IsConsumeHasRedDot(self)
    local bHas = false
    for i, s in pairs(self.m_ConsumeDayStates) do
        if s == 2 then
            bHas = true
            break
        end
    end
    bHas = bHas or self:IsConsumeTotalHasRedDot()
    return bHas
end

function CContActivityCtrl.IsConsumeTotalHasRedDot(self)
    local bHas = false
    for i, s in pairs(self.m_ConsumeAccuStates) do
        if s == 1 then
            bHas = true
            break
        end
    end
    return bHas
end

function CContActivityCtrl.GetConsumeDayStatus(self, iDay)
    return self.m_ConsumeDayStates[iDay] or 1
end

function CContActivityCtrl.GetConsumeAccuStatus(self, iDay)
    return self.m_ConsumeAccuStates[iDay] or 0
end

function CContActivityCtrl.GetConsumeDayChoice(self, iDay)
    return self.m_ConsumeDayChoices[iDay] or {}
end

function CContActivityCtrl.GetConsumeAccuChoice(self, iDay)
    return self.m_ConsumeAccuChoices[iDay] or {}
end

function CContActivityCtrl.GetConsumeAccuDay(self)
    local iAccum = 0
    for i, v in pairs(self.m_ConsumeDayStates) do
        if v == 2 or v == 3 then
            iAccum = iAccum + 1
        end
    end
    return iAccum
end

function CContActivityCtrl.GS2CContinuousExpenseEnd(self)
    self.m_IsConsumeOpen = false
    self:OnEvent(define.Timelimit.Event.EndContConsume)
end

function CContActivityCtrl.GS2CContinuousExpenseStart(self, pbData)
    self.m_IsConsumeOpen = true
    self.m_ConsumeStartTime = pbData.starttime
    self.m_ConsumeEndTime = pbData.endtime
    self.m_ConsumeMode = pbData.mode
end

function CContActivityCtrl.GS2CContinuousExpenseReward(self, pbData)
    self.m_AccuConsume = pbData.totalcoldcoin
    self.m_CurConsumeDay = pbData.curday or 1
    self.m_DayConsume = pbData.curgoldcoin
    self.m_ConsumeDayStates = {}
    for i, v in ipairs(pbData.states) do
        self.m_ConsumeDayStates[v.day] = v.state or 0
    end
    self.m_ConsumeAccuStates = {}
    for i, v in ipairs(pbData.totalstates) do
        self.m_ConsumeAccuStates[v.day] = v.state or 0
    end
    self.m_ConsumeDayChoices = {}
    for i, v in ipairs(pbData.choice) do
        local d = self.m_ConsumeDayChoices[v.day]
        if not d then
            d = {}
            self.m_ConsumeDayChoices[v.day] = d
        end
        d[v.slot] = v.index
    end
    self.m_ConsumeAccuChoices = {}
    for i, v in ipairs(pbData.totalchoice) do
        local d = self.m_ConsumeAccuChoices[v.day]
        if not d then
            d = {}
            self.m_ConsumeAccuChoices[v.day] = d
        end
        d[v.slot] = v.index
    end
    self:OnEvent(define.Timelimit.Event.UpdateContConsume)
end

------------------------- Config ----------------------------
function CContActivityCtrl.GetChargeDayConfig(self, iDay)
    local sKey = 2==self.m_ChargeMode and "OLD_REWARD" or "NEW_REWARD"
    local d = data.continuouschargedata[sKey]
    local dConfig = d and d[iDay]
    return dConfig
end

function CContActivityCtrl.GetChargeDayRewards(self, iDay)
    local dDayConfig = self:GetChargeDayConfig(iDay)
    return self:GetRewardItems(dDayConfig, "CONTINUOUSCHARGE")
end

function CContActivityCtrl.GetChargeAccuConfig(self, iDay)
    local sKey = 2==self.m_ChargeMode and "OLD_TOTAL_REWARD" or "NEW_TOTAL_REWARD"
    local d = data.continuouschargedata[sKey]
    local dConfig
    if iDay then
        dConfig = d and d[iDay]
    else
        dConfig = {}
        for k, v in pairs(d) do
            table.insert(dConfig, v)
        end
        table.sort(dConfig, function(a, b)
            return a.totalday < b.totalday
        end)
    end
    return dConfig
end

function CContActivityCtrl.GetChargeAccuRewards(self, iDay)
    local dAccuConfig = self:GetChargeAccuConfig(iDay)
    return self:GetRewardItems(dAccuConfig, "CONTINUOUSCHARGE")
end

function CContActivityCtrl.GetConsumeDayConfig(self, iDay)
    local sKey = 2==self.m_ConsumeMode and "OLD_REWARD" or "NEW_REWARD"
    local d = data.continuousconsumedata[sKey]
    local dConfig = d and d[iDay]
    return dConfig
end

function CContActivityCtrl.GetConsumeDayRewards(self, iDay)
    local dDayConfig = self:GetConsumeDayConfig(iDay)
    return self:GetRewardItems(dDayConfig, "CONTINUOUSEXPENSE")
end

function CContActivityCtrl.GetConsumeAccuConfig(self, iDay)
    local sKey = 2==self.m_ConsumeMode and "OLD_TOTAL_REWARD" or "NEW_TOTAL_REWARD"
    local d = data.continuousconsumedata[sKey]
    local dConfig
    if iDay then
        dConfig = d and d[iDay]
    else
        dConfig = {}
        for k, v in pairs(d) do
            table.insert(dConfig, v)
        end
        table.sort(dConfig, function(a, b)
            return a.totalday < b.totalday
        end)
    end
    return dConfig
end

function CContActivityCtrl.GetConsumeAccuRewards(self, iDay)
    local dAccuConfig = self:GetConsumeAccuConfig(iDay)
    return self:GetRewardItems(dAccuConfig, "CONTINUOUSEXPENSE")
end

function CContActivityCtrl.GetRewardItems(self, dDayConfig, sReward)
    if not dDayConfig then return end
    local itemList = {}
    for i = 1, 5 do
        local rewards = dDayConfig["slot"..i]
        if rewards and next(rewards) then
            local items = {}
            for _, rewardId in ipairs(rewards) do
                local dItems = DataTools.GetRewardItems(sReward, rewardId)
                if dItems then
                    local dFinal = table.copy(dItems[1])
                    if dFinal then
                        local sArg = dFinal.itemarg
                        if sArg and string.len(sArg)>0 then
                            local amount = sArg:match("^%(Value=(%d+)%)")
                            if amount then
                                dFinal.amount = amount
                            end
                        end
                    else
                        break
                    end
                    table.insert(items, dFinal)
                end
            end
            table.insert(itemList, items)
        else
            break
        end
    end
    return itemList
end

return CContActivityCtrl
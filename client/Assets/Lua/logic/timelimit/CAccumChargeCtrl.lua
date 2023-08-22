local CAccumChargeCtrl = class("CAccumChargeCtrl", CCtrlBase)

function CAccumChargeCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:Clear()
end

function CAccumChargeCtrl.Clear(self)
    self.m_RewardDict = {}
    self.m_Open = false
    self.m_EndTime = 0
    self.m_Mode = 0
    self.m_DayPayGoldcoin = 0
end

function CAccumChargeCtrl.GetRewardInfo(self, lv)
    if lv then
        return self.m_RewardDict[lv]
    else
        return self.m_RewardDict
    end
end

function CAccumChargeCtrl.IsOpen(self)
    return self.m_Open and self.m_EndTime > g_TimeCtrl:GetTimeS()
end

function CAccumChargeCtrl.IsHasRedDot(self)
    local bHas = false
    if self:IsOpen() then
        for i, v in pairs(self.m_RewardDict) do
            if v.status == 1 then
                bHas = true
                break
            end
        end
    end
    return bHas
end

function CAccumChargeCtrl.GetDayPayGoldcoin(self)
    return self.m_DayPayGoldcoin
end

function CAccumChargeCtrl.GS2CTotalChargeReward(self, rewardList, goldcoin)
    self.m_RewardDict = {}
    rewardList = rewardList or {}
    self.m_DayPayGoldcoin = goldcoin or 0
    for i, v in ipairs(rewardList) do
        local iStatus = 0
        iStatus = (1==v.rewarded and 2) or (1==v.reward and 1 or 0)
        v.status = iStatus
        self.m_RewardDict[v.level] = v
    end
    self:OnEvent(define.Timelimit.Event.RefreshAccCharge)
end

function CAccumChargeCtrl.GS2CTotalChargeStart(self, dPb)
    self.m_EndTime = dPb.endtime
    self.m_Mode = dPb.mode
    self.m_Open = true
    self:OnEvent(define.Timelimit.Event.RefreshAccCharge)
end

function CAccumChargeCtrl.GS2CTotalChargeEnd(self)
    self.m_Open = false
    self:OnEvent(define.Timelimit.Event.RefreshAccCharge)
end

return CAccumChargeCtrl
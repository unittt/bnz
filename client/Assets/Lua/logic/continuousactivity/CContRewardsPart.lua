local CContRewardsPart = class("CContRewardsPart", CBox)

function CContRewardsPart.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_CurDayL = self:NewUI(1, CLabel)
    self.m_LeftTimeL = self:NewUI(2, CLabel)
    self.m_RewardBox = self:NewUI(10, CContDayBox)
    self.m_RewardBox:SetActive(false)
    self.m_DayRewards = {}
    for i = 1, 7 do
        local obj = self:NewUI(i+2, CObject)
        local oBox = self.m_RewardBox:Clone()
        oBox:SetLocalPos(Vector3.zero)
        oBox:SetParent(obj.m_Transform)
        oBox:SetDay(i)
        oBox:SetSelState(false)
        oBox:SetActive(true)
        self.m_DayRewards[i] = oBox
    end
    self.m_SelDay = 0
    self.m_CurDay = 0
end

function CContRewardsPart.SetSelDay(self, iDay)
    local oSel = self.m_DayRewards[self.m_SelDay]
    if oSel then
        oSel:SetSelState(false)
    end
    self.m_SelDay = iDay
    local oBox = self.m_DayRewards[iDay]
    if oBox then
        oBox:SetSelState(true)
    end
end

function CContRewardsPart.RefreshBtnInfo(self, info)
    for i, v in ipairs(info) do
        local oBox = self.m_DayRewards[i]
        if oBox then
            oBox:SetInfo(v)
        end
    end
end

function CContRewardsPart.SetCurDay(self, iCurDay)
    self.m_CurDayL:SetText(string.format("第%d天", iCurDay))
    self.m_CurDay = iCurDay
    for i, oBox in pairs(self.m_DayRewards) do
        oBox:SetCurDay(iCurDay)
    end
end

function CContRewardsPart.SetEndTime(self, iEndTime)
    local iLeft = math.max(iEndTime - g_TimeCtrl:GetTimeS(), 0)
    local sTime = g_TimeCtrl:GetLeftTimeDHM(iLeft) or "0"
    self.m_LeftTimeL:SetText(sTime)
    --string.format("[FFF9E3FF]活动剩余时间：[-][49C038FF]%s[-]", sTime))
end

function CContRewardsPart.SetSelCallback(self, cb)
    local onClk = function(iDay)
        self:SetSelDay(iDay)
        if cb then
            cb(iDay)
        end
    end
    for i, oBox in pairs(self.m_DayRewards) do
        oBox:SetSelCallback(onClk)
    end
end

function CContRewardsPart.SetClkBtnCallback(self, cb)
    for i, oBox in pairs(self.m_DayRewards) do
        oBox:SetClkBtnCallback(cb)
    end
end

return CContRewardsPart
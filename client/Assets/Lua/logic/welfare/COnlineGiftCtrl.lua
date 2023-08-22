local COnlineGiftCtrl = class("COnlineGiftCtrl", CCtrlBase)

function COnlineGiftCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:Clear()
end

function COnlineGiftCtrl.Clear(self)
    self.m_StartTime = nil
    self.m_EndTime = nil
    self.m_LoginTime = nil
    self.m_StatusDict = {}
    self.m_HasClk = false
end

function COnlineGiftCtrl.GetHuodongTime(self)
    return self.m_StartTime, self.m_EndTime
end

function COnlineGiftCtrl.GetStatusInfo(self, iKey)
    if iKey then
        return self.m_StatusDict and self.m_StatusDict[iKey]
    else
        return self.m_StatusDict
    end
end

function COnlineGiftCtrl.IsHasRedPoint(self)
    local bHas = false
    --if self:IsOnlineGiftOpen() and not self.m_HasClk then
    if self:IsOnlineGiftOpen() then
        for i, s in pairs(self.m_StatusDict) do
            if s == 1 then
                bHas = true
                break
            end
        end
    end
    return bHas
end

function COnlineGiftCtrl.IsOnlineGiftOpen(self)
    local bOpen = false
    if self.m_StartTime and self.m_EndTime then
        local iCurTime = g_TimeCtrl:GetTimeS()
        bOpen = iCurTime >= self.m_StartTime and iCurTime < self.m_EndTime
    end
    return bOpen
end

-- function COnlineGiftCtrl.SetHasClk(self)
--     if not self.m_HasClk then
--         self.m_HasClk = true
--         self:OnEvent(define.OnlineGift.Event.UpdateRedPoint, false)
--     end
-- end

function COnlineGiftCtrl.GS2COnlineGift(self, dPbData)
    self.m_StatusDict = {}
    local statusList = dPbData.statuslist
    self.m_StartTime = dPbData.start_time
    self.m_EndTime = dPbData.end_time
    self.m_LoginTime = dPbData.login_time

    for i, v in ipairs(statusList) do
        self.m_StatusDict[v.key] = v.status
    end

    self:OnEvent(define.OnlineGift.Event.UpdateRedPoint)
    self:OnEvent(define.OnlineGift.Event.UpdateAllStatus)
end

function COnlineGiftCtrl.GS2COnlineGiftUnit(self, dUnit)
    self.m_StatusDict[dUnit.key] = dUnit.status
    -- if dUnit.status == 1 then
    --     --self.m_HasClk = false
        
    -- end
    self:OnEvent(define.OnlineGift.Event.UpdateRedPoint)
    self:OnEvent(define.OnlineGift.Event.UpdateStatus, dUnit)
end

return COnlineGiftCtrl
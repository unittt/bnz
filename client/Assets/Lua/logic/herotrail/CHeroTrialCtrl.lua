local CHeroTrialCtrl = class("CHeroTrialCtrl", CCtrlBase)

function CHeroTrialCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:Clear()
end

function CHeroTrialCtrl.Clear(self)
    self.m_Length = 0
    self.m_IsFinish = nil
    self.m_IsCheck = false
    self.m_CheckTime = nil
    self.m_TrialData = nil
end

function CHeroTrialCtrl.SetLength(self, length)
    self.m_Length = length
end

function CHeroTrialCtrl.GetLength(self)
    return self.m_Length
end

function CHeroTrialCtrl.CheckTrialInfo(self)
    if not g_OpenSysCtrl:GetOpenSysState("HEROTRIAL") then
        return
    end
    if self.m_IsFinish ~= nil then
        return
    end
    if self.m_IsCheck and self.m_CheckTime and os.time()-self.m_CheckTime < 2 then
        return
    end
    self.m_CheckTime = os.time()
    self.m_IsCheck = true
    nethuodong.C2GSTrialOpenUI()
end

-- 是否完成全部并领取完奖励
function CHeroTrialCtrl.IsFinish(self, dPbData)
    if #dPbData.trial_list < dPbData.total then
        return false
    end
    for i, v in ipairs(dPbData.trial_list) do
        if v.status < 2 then
            return false
        end
    end
    return true
end

function CHeroTrialCtrl.HasReward(self)
    local trialList = self.m_TrialData and self.m_TrialData.trial_list
    if trialList then
        for i, v in ipairs(trialList) do
            if v.status == 1 then
                return true
            end
        end
    end
    return false
end

function CHeroTrialCtrl.C2GSTrialOpenUI(self)
    -- if self.m_TrialData then
    --     self:GS2CTrialOpenUI(self.m_TrialData)
    -- else
    nethuodong.C2GSTrialOpenUI()
    -- end
end

function CHeroTrialCtrl.GS2CTrialOpenUI(self, pbdata)
    self.m_IsFinish = self:IsFinish(pbdata)
    self.m_TrialData = pbdata
    if self.m_IsCheck then
        self.m_IsCheck = false
        self.m_CheckTime = nil
        self:OnEvent(define.HeroTrial.Event.CheckIsFinish, self.m_IsFinish)
        g_ScheduleCtrl:ResetMainUIBtnEffect()
        return
    -- elseif self.m_IsFinish then
    --     return
    end
    local trialList = table.copy(pbdata.trial_list)
    local iTime = pbdata.ret_time
    local iTotal = pbdata.total
    CHeroTrialView:ShowView(function(oView)
        oView:SetInfos(trialList, iTime, iTotal)
    end)
end

function CHeroTrialCtrl.GS2CTrialRefreshUnit(self, trailInfo, pos)
    if self.m_TrialData then
        self.m_TrialData.trial_list[pos] = trailInfo
        self.m_IsFinish = self:IsFinish(self.m_TrialData)
    end
    self:OnEvent(define.HeroTrial.Event.UpdateTrialUnit, {info = trailInfo, pos = pos})
    g_ScheduleCtrl:ResetMainUIBtnEffect()
end

return CHeroTrialCtrl
local CBigProfitCtrl = class("CBigProfitCtrl", CCtrlBase)

function CBigProfitCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self.m_IsShowBoth = false
    self:InitInfo()
    self:Clear()
end

function CBigProfitCtrl.Clear(self)
    self.m_HasClkGradeGiftTab = false
end

-- 切换显示模式
function CBigProfitCtrl.SwitchShowMode(self, bShowBoth)
    self.m_IsShowBoth = bShowBoth
    if bShowBoth then
        self:InitInfo()
    else
        data.sortdata = reimport "logic.data.sortdata"
        g_WelfareCtrl:InitTabConfig()
    end
end

function CBigProfitCtrl.InitInfo(self)
    if self.m_IsShowBoth then
        local sortData = data.sortdata.WELFARE 
        local iBigProfit = sortData.GIFT_GRADE
        for k, v in pairs(sortData) do
            if v > iBigProfit then
                sortData[k] = v + 1
            end
        end
        sortData.GIFT_GRADE2 = iBigProfit + 1
        g_WelfareCtrl:InitTabConfig()
    end
end

function CBigProfitCtrl.UpdatePnl(self, lChargeInfo)
    local iGradePnlLv = self:GetGradePnlLevel()
    if not self.m_HasClkGradeGiftTab then
        for _, v in ipairs(lChargeInfo) do
            local stateLv1 = iGradePnlLv == 1 and not v.key:match("grade_gift1")
            local stateLv2 = iGradePnlLv == 2 and not v.key:match("grade_gift2")
            if not (stateLv1 or stateLv2) then
                if v.val ~= define.WelFare.Status.Unobtainable then
                    self.m_HasClkGradeGiftTab = true
                    break
                end
            end
        end
    end
    g_WelfareCtrl:OnEvent(define.WelFare.Event.UpdateBigProfitPnl, lChargeInfo)
end

function CBigProfitCtrl.GetGradePnlLevel(self)
    if self.m_IsShowBoth then
        return 1
    end
    local iGrade = 60
    for key, info in pairs(DataTools.GetChargeData("BIGPROFIT")) do
        if iGrade >= info.grade and key ~= "grade_gift2_0" then
            local iVal = g_WelfareCtrl:GetChargeItemInfo(key)
            if not iVal or iVal ~= 2 then
                return 1
            end
        end
    end
    return 2
end

function CBigProfitCtrl.IsBigProfitPay(self, iGradePnlLv)
    iGradePnlLv = iGradePnlLv or self:GetGradePnlLevel()
    local key = iGradePnlLv == 1 and "grade_gift1_0" or "grade_gift2_0"
    local val = g_WelfareCtrl:GetChargeItemInfo(key)
    return not (val == define.WelFare.Status.Unobtainable)
end

function CBigProfitCtrl.GetBigProfitPayId(self, iGradePnlLv)
    iGradePnlLv = iGradePnlLv or self:GetGradePnlLevel()
    local key = iGradePnlLv == 1 and "grade_gift1_0" or "grade_gift2_0"
    return DataTools.GetChargeData("BIGPROFIT", key).payid
end

function CBigProfitCtrl.SetHasClkGradeGiftTab(self)
    self.m_HasClkGradeGiftTab = true
    if not self:IsHadRedPoint() then
        g_WelfareCtrl:OnEvent(define.WelFare.Event.UpdateBigProfitPnl)
    end
end

function CBigProfitCtrl.IsHadRedPoint(self)
    if not g_OpenSysCtrl:GetOpenSysState("GIFT_GRADE") then
        return false
    elseif not self.m_HasClkGradeGiftTab then
        return true
    end
    local bHas = false
    local iGrade = g_AttrCtrl.grade
    for key, info in pairs(DataTools.GetChargeData("BIGPROFIT")) do
        local val = g_WelfareCtrl:GetChargeItemInfo(key)
        if val and val == define.WelFare.Status.Get and iGrade >= info.grade then
            if self.m_IsShowBoth then
                if key:match("grade_gift1") then
                    bHas = true
                end
            else
                bHas = true 
            end
            if bHas then
                break
            end
        end
    end
    return bHas
end

function CBigProfitCtrl.UpdateBigProfitTab(self)
    g_WelfareCtrl:OnEvent(define.WelFare.Event.UpdateBigProfitTab)
end

function CBigProfitCtrl.IsShowBoth(self)
    return self.m_IsShowBoth
end

return CBigProfitCtrl
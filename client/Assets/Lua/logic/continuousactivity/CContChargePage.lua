local CContChargePage = class("CContChargePage", CPageBase)

function CContChargePage.ctor(self, cb)
    CPageBase.ctor(self,cb)
    self.m_CurSelDay = 1
end

function CContChargePage.OnInitPage(self)
    self.m_RewardsPart = self:NewUI(1, CContRewardsPart)
    self.m_DayRewardPart = self:NewUI(2, CSelectRewardsPart)
    self.m_AccumRewardSpr = self:NewUI(3, CSprite)
    self.m_DayChargeValL = self:NewUI(4, CLabel)
    self.m_DayChargeObj = self:NewUI(5, CObject)
    self.m_TipBtn = self:NewUI(6, CButton)
    self:InitContent()
end

function CContChargePage.InitContent(self)
    self.m_CurSelDay = g_ContActivityCtrl.m_CurChargeDay
    self.m_RewardsPart:SetSelDay(self.m_CurSelDay)
    self.m_AccumRewardSpr.m_IgnoreCheckEffect = true
    self:RefreshRewards()
    self:RegisterEvents()
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTip"))
end

function CContChargePage.RegisterEvents(self)
    self.m_RewardsPart:SetSelCallback(function(iDay)
        self:SetSelDay(iDay)
    end)
    self.m_RewardsPart:SetClkBtnCallback(function(iStatus, iDay)
        if iDay > self.m_CurDay then
            g_NotifyCtrl:FloatMsg("活动天数未到，请耐心等待")
        elseif iStatus == 1 then
            CNpcShopMainView:ShowView(function(oView)
                oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
            end)
        elseif iStatus == 2 then
            self:OnGetDayReward(iDay)
        end
    end)
    self.m_DayRewardPart:SetSelCallback(function(iSlot, idx, iCurIdx)
        if iCurIdx ~= idx then
            nethuodong.C2GSContinuousChargeSetChoice(1, self.m_CurSelDay, iSlot, idx)
        end
    end)
    self.m_AccumRewardSpr:AddUIEvent("click", callback(self, "OnClickAccumReward"))
    g_ContActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnContActCtrl"))
end

function CContChargePage.RefreshRewards(self)
    local oCtrl = g_ContActivityCtrl
    self.m_RewardsPart:SetCurDay(oCtrl.m_CurChargeDay)
    self.m_RewardsPart:SetEndTime(oCtrl.m_ChargeEndTime or 0)
    self.m_CurDay = oCtrl.m_CurChargeDay
    local btnInfos = {}
    for i = 1, 7 do
        local iStatus = oCtrl:GetChargeDayStatus(i)
        table.insert(btnInfos, {status = iStatus, disableText = "充 值"})
    end
    self.m_RewardsPart:RefreshBtnInfo(btnInfos)
    self:RefreshDayReward()
end

function CContChargePage.SetSelDay(self, iDay)
    if iDay == self.m_CurSelDay then return end
    self.m_CurSelDay = iDay
    self:RefreshDayReward()
end

function CContChargePage.RefreshDayReward(self)
    local iDay = self.m_CurSelDay
    local bCurDay = iDay == self.m_CurDay
    self.m_DayChargeObj:SetActive(bCurDay)
    if bCurDay then
        local iNeed = self:GetDayNeedCnt() or 0
        local iCnt = g_ContActivityCtrl.m_DayCharge
        self.m_DayChargeValL:SetText(string.format("%d/%d", iCnt, iNeed))
    end
    local dChoice = g_ContActivityCtrl:GetChargeDayChoice(iDay)
    local items = g_ContActivityCtrl:GetChargeDayRewards(iDay)
    local iStatus = g_ContActivityCtrl:GetChargeDayStatus(iDay)
    local bCanSel = iStatus == 2
    self.m_DayRewardPart:SetInfo(dChoice, items, bCanSel)
    if g_ContActivityCtrl:IsChargeTotalHasRedDot() then
        self.m_AccumRewardSpr:AddEffect("RedDot", 20, Vector2(-20,-20))
    else
        self.m_AccumRewardSpr:DelEffect("RedDot")
    end
end

function CContChargePage.GetDayNeedCnt(self)
    local dConfig = g_ContActivityCtrl:GetChargeDayConfig(self.m_CurSelDay)
    if dConfig then
        return dConfig.glodcoin
    end
end

function CContChargePage.OnClickAccumReward(self)
    CContAccumView:ShowView(function(oView)
        oView:ShowChargeAccum()
    end)
end

function CContChargePage.OnGetDayReward(self, iDay)
    local itemList = g_ContActivityCtrl:GetChargeDayRewards(iDay)
    local multiItems = {}
    for i, v in ipairs(itemList) do
        if #v > 1 then
            table.insert(multiItems, {idx = i, items = v})
        end
    end
    local iTotal = #multiItems
    if iTotal > 0 then
        local dChoice = g_ContActivityCtrl:GetChargeDayChoice(iDay)
        local iRc = 1
        local dItem = multiItems[iRc]
        local iSlot = dItem.idx
        local iCurIdx = dChoice[iSlot] or 1
        local function cb(idx)
            if idx ~= iCurIdx then
                nethuodong.C2GSContinuousChargeSetChoice(1, iDay, iSlot, idx)
            end
            if iRc >= iTotal then
                nethuodong.C2GSContinuousChargeReward(iDay)
            else
                iRc = iRc + 1
                dItem = multiItems[iRc]
                iSlot = dItem.idx
                iCurIdx = dChoice[iSlot] or 1
                Utils.AddTimer(function()
                    if Utils.IsNil(self) then return end
                    g_WindowTipCtrl:ShowSelectRewardItemView(dItem.items, iCurIdx, cb)
                end, 0, 0)
            end
        end
        g_WindowTipCtrl:ShowSelectRewardItemView(dItem.items, iCurIdx, cb)
    else
        nethuodong.C2GSContinuousChargeReward(iDay)
    end
end

function CContChargePage.OnClickTip(self)
    local instructionConfig = data.instructiondata.DESC[13008]
    if instructionConfig then
        local zContent = {
            title = instructionConfig.title,
            desc = instructionConfig.desc,
        }
        g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
    end
end

function CContChargePage.OnContActCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Timelimit.Event.UpdateContCharge then
        self:RefreshRewards()
    end
end

return CContChargePage
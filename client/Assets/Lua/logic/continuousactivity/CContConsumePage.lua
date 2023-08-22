local CContConsumePage = class("CContConsumePage", CPageBase)

function CContConsumePage.ctor(self, cb)
    CPageBase.ctor(self,cb)
    self.m_CurSelDay = 1
end

function CContConsumePage.OnInitPage(self)
    self.m_RewardsPart = self:NewUI(1, CContRewardsPart)
    self.m_DayRewardPart = self:NewUI(2, CSelectRewardsPart)
    self.m_AccumRewardSpr = self:NewUI(3, CSprite)
    self.m_DayConsumeValL = self:NewUI(4, CLabel)
    self.m_DayConsumeObj = self:NewUI(5, CObject)
    self.m_TipBtn = self:NewUI(6, CButton)
    self:InitContent()
end

function CContConsumePage.InitContent(self)
    self.m_CurSelDay = g_ContActivityCtrl.m_CurConsumeDay
    self.m_RewardsPart:SetSelDay(self.m_CurSelDay)
    self.m_AccumRewardSpr.m_IgnoreCheckEffect = true
    self:RefreshRewards()
    self:RegisterEvents()
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTip"))
end

function CContConsumePage.RegisterEvents(self)
    self.m_RewardsPart:SetSelCallback(function(iDay)
        self:SetSelDay(iDay)
    end)
    self.m_RewardsPart:SetClkBtnCallback(function(iStatus, iDay)
        if iDay > self.m_CurDay then
            g_NotifyCtrl:FloatMsg("活动天数未到，请耐心等待")
        elseif iStatus == 1 then
            -- g_NotifyCtrl:FloatMsg("消费元宝未达成领取条件，请先进行元宝消费")
            CNpcShopMainView:ShowView()
        elseif iStatus == 2 then
            self:OnGetDayReward(iDay)
        end
    end)
    self.m_DayRewardPart:SetSelCallback(function(iSlot, idx, iCurIdx)
        if iCurIdx ~= idx then
            nethuodong.C2GSContinuousExpenseSetChoice(1, self.m_CurSelDay, iSlot, idx)
        end
    end)
    self.m_AccumRewardSpr:AddUIEvent("click", callback(self, "OnClickAccumReward"))
    g_ContActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnContActCtrl"))
end

function CContConsumePage.RefreshRewards(self)
    local oCtrl = g_ContActivityCtrl
    self.m_RewardsPart:SetCurDay(oCtrl.m_CurConsumeDay)
    self.m_RewardsPart:SetEndTime(oCtrl.m_ConsumeEndTime or 0)
    self.m_CurDay = oCtrl.m_CurConsumeDay
    local btnInfos = {}
    for i = 1, 7 do
        local iStatus = oCtrl:GetConsumeDayStatus(i)
        table.insert(btnInfos, {status = iStatus, disableText = "前往消费"})
    end
    self.m_RewardsPart:RefreshBtnInfo(btnInfos)
    self:RefreshDayReward()
end

function CContConsumePage.SetSelDay(self, iDay)
    if iDay == self.m_CurSelDay then return end
    self.m_CurSelDay = iDay
    self:RefreshDayReward()
end

function CContConsumePage.RefreshDayReward(self)
    local iDay = self.m_CurSelDay
    local bCurDay = iDay == self.m_CurDay
    self.m_DayConsumeObj:SetActive(bCurDay)
    if bCurDay then
        local iNeed = self:GetDayNeedCnt() or 0
        local iCnt = g_ContActivityCtrl.m_DayConsume
        self.m_DayConsumeValL:SetText(string.format("%d/%d", iCnt, iNeed))
    end
    local dChoice = g_ContActivityCtrl:GetConsumeDayChoice(iDay)
    local items = g_ContActivityCtrl:GetConsumeDayRewards(iDay)
    local iStatus = g_ContActivityCtrl:GetConsumeDayStatus(iDay)
    local bCanSel = iStatus == 2
    self.m_DayRewardPart:SetInfo(dChoice, items, bCanSel)
    if g_ContActivityCtrl:IsConsumeTotalHasRedDot() then
        self.m_AccumRewardSpr:AddEffect("RedDot", 20, Vector2(-20,-20))
    else
        self.m_AccumRewardSpr:DelEffect("RedDot")
    end
end

function CContConsumePage.GetDayNeedCnt(self)
    local dConfig = g_ContActivityCtrl:GetConsumeDayConfig(self.m_CurSelDay)
    if dConfig then
        return dConfig.glodcoin
    end
end

function CContConsumePage.OnClickAccumReward(self)
    CContAccumView:ShowView(function(oView)
        oView:ShowConsumeAccum()
    end)
end

function CContConsumePage.OnGetDayReward(self, iDay)
    local itemList = g_ContActivityCtrl:GetConsumeDayRewards(iDay)
    local multiItems = {}
    for i, v in ipairs(itemList) do
        if #v > 1 then
            table.insert(multiItems, {idx = i, items = v})
        end
    end
    local iTotal = #multiItems
    if iTotal > 0 then
        local dChoice = g_ContActivityCtrl:GetConsumeDayChoice(iDay)
        local iRc = 1
        local dItem = multiItems[iRc]
        local iSlot = dItem.idx
        local iCurIdx = dChoice[iSlot] or 1
        local function cb(idx)
            if idx ~= iCurIdx then
                nethuodong.C2GSContinuousExpenseSetChoice(1, iDay, iSlot, idx)
            end
            if iRc >= iTotal then
                nethuodong.C2GSContinuousExpenseReward(iDay)
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
        nethuodong.C2GSContinuousExpenseReward(iDay)
    end
end

function CContConsumePage.OnClickTip(self)
    local instructionConfig = data.instructiondata.DESC[13009]
    if instructionConfig then
        local zContent = {
            title = instructionConfig.title,
            desc = instructionConfig.desc,
        }
        g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
    end
end

function CContConsumePage.OnContActCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Timelimit.Event.UpdateContConsume then
        self:RefreshRewards()
    end
end

return CContConsumePage
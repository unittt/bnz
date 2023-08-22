local CContAccumView = class("CContAccumView", CViewBase)

function CContAccumView.ctor(self, cb)
    CViewBase.ctor(self, "UI/TimeLimit/ContAccumView.prefab", cb)
    --界面设置
    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "Black"
    self.m_Mode = 0 --0: 充值 1: 消费
end

function CContAccumView.OnCreateView(self)
    self.m_ScrollView = self:NewUI(1, CScrollView)
    self.m_Grid = self:NewUI(2, CGrid)
    self.m_RewardBox = self:NewUI(3, CBox)
    self.m_CloseBtn = self:NewUI(4, CButton)
    self.m_RewardBox:SetActive(false)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_ContActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnContActCtrl"))
end

function CContAccumView.InitRewardBox(self, oBox)
    oBox.rewardsBox = oBox:NewUI(1, CSelectRewardsPart)
    oBox.msgL = oBox:NewUI(2, CLabel)
    oBox.getBtn = oBox:NewUI(3, CButton)
    oBox.fbBtn = oBox:NewUI(4, CButton)
    oBox.gotSpr = oBox:NewUI(5, CSprite)
    oBox.getBtn.m_IgnoreCheckEffect = true
    oBox.rewardsBox:SetSelCallback(function(iSlot, idx, iCurIdx)
        if not oBox.day or iCurIdx == idx then
            return
        end
        self:SetChoice(oBox.day, iSlot, idx)
    end)
    oBox.getBtn:AddUIEvent("click", callback(self, "OnClickGetBtn", oBox))
    oBox.fbBtn:AddUIEvent("click", callback(self, "OnClickFbBtn"))
end

function CContAccumView.ShowChargeAccum(self)
    self.m_Mode = 0
    self:RefreshRewards()
end

function CContAccumView.ShowConsumeAccum(self)
    self.m_Mode = 1
    self:RefreshRewards()
end

function CContAccumView.GetRewardBox(self, i)
    local oBox = self.m_Grid:GetChild(i)
    if not oBox then
        oBox = self.m_RewardBox:Clone()
        self.m_Grid:AddChild(oBox)
        self:InitRewardBox(oBox)
    end
    return oBox
end

function CContAccumView.RefreshRewards(self)
    local iAccumDay, iAccumGold, configs
    local bCharge = self.m_Mode == 0
    if bCharge then
        iAccumDay = g_ContActivityCtrl:GetChargeAccuDay()
        iAccumGold = g_ContActivityCtrl.m_AccuCharge
        configs = g_ContActivityCtrl:GetChargeAccuConfig()
    else
        iAccumDay = g_ContActivityCtrl:GetConsumeAccuDay()
        iAccumGold = g_ContActivityCtrl.m_AccuConsume
        configs = g_ContActivityCtrl:GetConsumeAccuConfig()
    end
    for i, v in ipairs(configs) do
        local iDay = v.totalday
        local oBox = self:GetRewardBox(i)
        local dChoice, items, iStatus
        if bCharge then
            dChoice = g_ContActivityCtrl:GetChargeAccuChoice(iDay)
            items = g_ContActivityCtrl:GetChargeAccuRewards(iDay)
            iStatus = g_ContActivityCtrl:GetChargeAccuStatus(iDay)
        else
            dChoice = g_ContActivityCtrl:GetConsumeAccuChoice(iDay)
            items = g_ContActivityCtrl:GetConsumeAccuRewards(iDay)
            iStatus = g_ContActivityCtrl:GetConsumeAccuStatus(iDay)
        end
        local bCanSel = iStatus == 1
        oBox.rewardsBox:SetInfo(dChoice, items, bCanSel)
        oBox.day = iDay
        self:SetBtnState(oBox, iStatus)
        oBox:SetActive(true)
        local sMsg
        if self.m_Mode == 0 then
            sMsg = "达成%d/%d天 并 累计充值%d/%d元宝"
        else
            sMsg = "达成%d/%d天 并 累计消费%d/%d元宝"
        end
        oBox.msgL:SetText(string.format(sMsg, iAccumDay, v.totalday, iAccumGold, v.glodcoin))
    end
end

function CContAccumView.SetBtnState(self, oBox, iStatus)
    local bCanGet = iStatus==1
    oBox.fbBtn:SetActive(iStatus==0)
    oBox.getBtn:SetActive(bCanGet)
    oBox.gotSpr:SetActive(iStatus==2)
    if bCanGet then
        oBox.getBtn:AddEffect("RedDot", 20, Vector2(-15,-15))
    else
        oBox.getBtn:DelEffect("RedDot")
    end
end

function CContAccumView.OnClickGetBtn(self, oBox)
    local iDay = oBox.day
    if not iDay then
        return
    end
    local itemList
    if self.m_Mode == 0 then
        itemList = g_ContActivityCtrl:GetChargeAccuRewards(iDay)
    else
        itemList = g_ContActivityCtrl:GetConsumeAccuRewards(iDay)
    end
    local multiItems = {}
    for i, v in ipairs(itemList) do
        if #v > 1 then
            table.insert(multiItems, {idx = i, items = v})
        end
    end
    local iTotal = #multiItems
    if iTotal > 0 then
        local dChoice
        if self.m_Mode == 0 then
            dChoice = g_ContActivityCtrl:GetChargeAccuChoice(iDay)
        else
            dChoice = g_ContActivityCtrl:GetConsumeAccuChoice(iDay)
        end
        local iRc = 1
        local dItem = multiItems[iRc]
        local iSlot = dItem.idx
        local iCurIdx = dChoice[iSlot] or 1
        local function cb(idx)
            if idx ~= iCurIdx then
                self:SetChoice(iDay, iSlot, idx)
            end
            if iRc >= iTotal then
                self:RequestReward(iDay)
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
        self:RequestReward(iDay)
    end
end

function CContAccumView.SetChoice(self, iDay, iSlot, idx)
    if self.m_Mode == 0 then
        nethuodong.C2GSContinuousChargeSetChoice(2, iDay, iSlot, idx)
    else
        nethuodong.C2GSContinuousExpenseSetChoice(2, iDay, iSlot, idx)
    end
end

function CContAccumView.RequestReward(self, iDay)
    if self.m_Mode == 0 then
        nethuodong.C2GSContinuousChargeTotalReward(iDay)
    else
        nethuodong.C2GSContinuousExpenseTotalReward(iDay)
    end
end

function CContAccumView.OnClickFbBtn(self)
    g_NotifyCtrl:FloatMsg("未到成奖励领取条件，无法领取")
end

function CContAccumView.OnContActCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Timelimit.Event.UpdateContCharge and self.m_Mode == 0 then
        self:RefreshRewards()
    elseif oCtrl.m_EventID == define.Timelimit.Event.UpdateContConsume and self.m_Mode == 1 then
        self:RefreshRewards()
    end
end

return CContAccumView
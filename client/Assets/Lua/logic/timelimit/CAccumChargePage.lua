local CAccumChargePage = class("CAccumChargePage", CPageBase)

function CAccumChargePage.ctor(self, cb)
    CPageBase.ctor(self,cb)
end

function CAccumChargePage.OnInitPage(self)
    self.m_ChargeItemBox = self:NewUI(1, CBox)
    self.m_ChargeGrid = self:NewUI(2, CGrid)
    self.m_LeftTimeL = self:NewUI(3, CLabel)
    self.m_ChargeItemBox:SetActive(false)
    self:InitContent()
end

function CAccumChargePage.InitContent(self)
    self:RefreshAll()
    g_AccumChargeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAccumChargeCtrl"))
end

function CAccumChargePage.RefreshAll(self)
    local accumChargeList = self:GetAccumChargeInfo()
    if not accumChargeList then return end
    local leftTime = g_AccumChargeCtrl.m_EndTime - g_TimeCtrl:GetTimeS()
    self.m_LeftTimeL:SetText(g_TimeCtrl:GetLeftTimeDHM(leftTime))
    self.m_ChargeGrid:HideAllChilds()
    for i, dCharge in ipairs(accumChargeList) do
        local oBox = self:GetChargeItemBox(i)
        oBox:SetActive(true)
        self:SetChargeItemInfo(oBox, dCharge)
        oBox.bgSpr:SetSpriteName(i%2==0 and "h7_1di" or "h7_2di")
    end
    self.m_ChargeGrid:Reposition()
end

function CAccumChargePage.GetChargeItemBox(self, idx)
    local oBox = self.m_ChargeGrid:GetChild(idx)
    if not oBox then
        oBox = self.m_ChargeItemBox:Clone()
        oBox.chargeL = oBox:NewUI(1, CLabel)
        oBox.needL = oBox:NewUI(2, CLabel)
        oBox.rewardBtn = oBox:NewUI(3, CButton)
        oBox.itemBox = oBox:NewUI(4, CBox)
        oBox.payBtn = oBox:NewUI(5, CButton)
        oBox.gotSpr = oBox:NewUI(6, CSprite)
        oBox.itemGrid = oBox:NewUI(7, CGrid)
        oBox.bgSpr = oBox:NewUI(8, CSprite)
        oBox.rewardBtn.m_IgnoreCheckEffect = true
        oBox.rewardBtn:AddUIEvent("click", callback(self, "OnClickRewardBtn", oBox))
        oBox.payBtn:AddUIEvent("click", callback(self, "OnClickPayBtn"))
        oBox.itemBox:SetActive(false)
        self.m_ChargeGrid:AddChild(oBox)
    end
    return oBox
end

function CAccumChargePage.SetChargeItemInfo(self, oBox, dInfo)
    oBox.lv = dInfo.level
    oBox.info = dInfo.info
    oBox.chargeL:SetText(dInfo.level)
    self:SetBtnState(oBox, dInfo.status)
    self:SetChargeRewards(oBox, dInfo.slots, dInfo.status)
end

function CAccumChargePage.SetBtnState(self, oBox, iStatus)
    oBox.payBtn:SetActive(0 == iStatus)
    oBox.rewardBtn:SetActive(1 == iStatus)
    oBox.gotSpr:SetActive(2 == iStatus)
    oBox.needL:SetActive(0 == iStatus)
    if iStatus == 0 then
        local iCharge = g_AccumChargeCtrl:GetDayPayGoldcoin()
        local iNeed = math.max(0, oBox.lv - iCharge)
        oBox.needL:SetText(string.format("[63432c]只差[1d8e00]%d[-]元宝[-]", iNeed))
    elseif iStatus then
        oBox.rewardBtn:AddEffect("RedDot")
    end
end

function CAccumChargePage.SetChargeRewards(self, oBox, slots, iStatus)
    oBox.rewardsData = slots
    for i, dSlot in ipairs(slots) do
        local oItem = self:GetRewardItemBox(oBox, i)
        oItem:SetActive(true)
        oItem.status = iStatus
        self:SetRewardItemInfo(oItem, dSlot)
    end
    oBox.itemGrid:Reposition()
end

function CAccumChargePage.GetRewardItemBox(self, oBox, idx)
    local oItem = oBox.itemGrid:GetChild(idx)
    if not oItem then
        oItem = oBox.itemBox:Clone()
        oItem.iconSpr = oItem:NewUI(1, CSprite)
        oItem.cntL = oItem:NewUI(2, CLabel)
        oItem.qualityL = oItem:NewUI(3, CSprite)
        oItem.chooseSpr = oItem:NewUI(4, CSprite)
        oItem.lv = oBox.lv
        oItem.iconSpr:SetSpriteName("")
        oItem.cntL:SetText("")
        oItem.qualityL:SetSpriteName("")
        oItem:AddUIEvent("click", callback(self, "OnClickRewardItem"))
        oBox.itemGrid:AddChild(oItem)
    end
    return oItem
end

function CAccumChargePage.SetRewardItemInfo(self, oItem, dSlot)
    local lSlot = dSlot.rewards
    local iReward = lSlot[dSlot.idx]
    if not iReward then
        oItem:SetActive(false)
        return
    end
    local dRewardItem = self:GetRewardConfig(iReward)
    if not dRewardItem then return end
    local sid = tonumber(dRewardItem.sid)
    local amount = dRewardItem.amount
    if not sid then
        sid, amount = (dRewardItem.sid):match("^(%d+)%(Value=(%d+)%)")
        if sid == 1003 and 1 == dRewardItem.bind then
            sid = 1004
        end
    end
    local dItem = DataTools.GetItemData(sid)
    oItem.iconSpr:SpriteItemShape(dItem.icon)
    oItem.qualityL:SetItemQuality(dItem.quality)
    oItem.cntL:SetText(amount)
    oItem.isSingle = #lSlot == 1
    oItem.chooseSpr:SetActive(not oItem.isSingle)
    oItem.idx = dSlot.idx
    oItem.slot = dSlot.slot
    if oItem.isSingle then
        oItem.itemId = dItem.id
    else
        local rewardList = {}
        for i, v in ipairs(lSlot) do
            local d = self:GetRewardConfig(v)
            table.insert(rewardList, d)
        end
        oItem.itemList = rewardList
    end
end

function CAccumChargePage.GetAccumChargeInfo(self)
    local accumList = {}
    local dAccum = self:GetConfig()
    for lv, d in pairs(dAccum) do
        local dCharge = self:GetSingleInfo(lv, d)
        table.insert(accumList, dCharge)
    end
    table.sort(accumList, function(a, b)
        return a.level < b.level
    end)
    return accumList
end

function CAccumChargePage.GetSingleInfo(self, lv, dConfig)
    if not dConfig then
        dConfig = self:GetConfig(lv)
    end
    local dCharge = table.copy(dConfig)
    local dPb = g_AccumChargeCtrl:GetRewardInfo(lv)
    dPb = dPb or {status = 0, slotlist = {}}
    local slots = {}
    for k, v in pairs(dCharge) do
        local idx = k:match("slot(%d+)")
        if idx and type(v) == "table" then
            table.insert(slots, {idx = idx, key = k, val = v})
        end
    end
    dCharge.status = dPb.status
    if #slots > 0 then
        local slotPb = dPb.slotlist
        table.sort(slots, function(a, b)
            return a.idx < b.idx
        end)
        local rewards = {}
        for i, slot in ipairs(slots) do
            local idx = 1
            for _, s in ipairs(slotPb) do
                if s.slot == i then
                    idx = s.index
                    break
                end
            end
            table.insert(rewards,{
                rewards = slot.val,
                idx = idx,
                slot = i,
            })
            dCharge[slot.key] = nil
        end
        dCharge.slots = rewards
    end
    return dCharge
end

function CAccumChargePage.GetRewardConfig(self, iReward)
    for i, v in ipairs(data.rewarddata.TOTALCHARGE) do
        if v.idx == iReward then
            return v
        end
    end
end

CAccumChargePage.m_ModeKeys = {
    [1] = "NEWREWARD",
    [2] = "OLDREWARD",
    [3] = "THIRDREWARD",
}

function CAccumChargePage.GetConfig(self, iLv)
    local sKey = self.m_ModeKeys[g_AccumChargeCtrl.m_Mode]
    local dConfig = data.accumchargedata[sKey]
    dConfig = dConfig or {}
    if iLv then
        return dConfig[iLv]
    else
        return dConfig
    end
end

function CAccumChargePage.OnClickRewardItem(self, oItem)
    if oItem.isSingle and oItem.itemId then
        local config = {widget = oItem}
        g_WindowTipCtrl:SetWindowItemTip(oItem.itemId, config)
    elseif not oItem.isSingle and oItem.itemList then
        local lv, slot = oItem.lv, oItem.slot
        local curIdx = oItem.idx
        if 1 ~= oItem.status then
            g_WindowTipCtrl:ShowItemBoxView({
                title = "可选",
                hideBtn = true,
                desc = "达到领取条件时，可以选择任意一样物品作为奖励",
                items = oItem.itemList,
                comfirmText = "确定",
                desc = "达到领取条件，可以选择任意一样物品作为奖励",
            })
        else
            g_WindowTipCtrl:ShowSelectRewardItemView(oItem.itemList, curIdx, function(idx, dItem)
                if curIdx ~= idx then
                    nethuodong.C2GSTotalChargeSetChoice(lv, slot, idx)
                end
            end)
        end
    end
end

function CAccumChargePage.OnClickRewardBtn(self, oBox)
    local iLv = oBox.lv
    local dRewardList = oBox.rewardsData
    local multiItems = {}
    for i, v in ipairs(dRewardList) do
        if v.rewards and #v.rewards > 1 then
            local items = {}
            for _, rewardId in ipairs(v.rewards) do
                table.insert(items, self:GetRewardConfig(rewardId))
            end
            table.insert(multiItems, {idx = i, items = items, choice = v.idx})
        end
    end
    local iTotal = #multiItems
    if iTotal > 0 then
        local iRc = 1
        local dItem = multiItems[iRc]
        local iSlot = dItem.idx
        local iCurIdx = dItem.choice or 1
        local function cb(idx)
            if idx ~= iCurIdx then
                nethuodong.C2GSTotalChargeSetChoice(iLv, iSlot, idx)
            end
            if iRc >= iTotal then
                nethuodong.C2GSTotalChargeGetReward(iLv)
            else
                iRc = iRc + 1
                dItem = multiItems[iRc]
                iSlot = dItem.idx
                iCurIdx = dItem.choice or 1
                Utils.AddTimer(function()
                    if Utils.IsNil(self) then return end
                    g_WindowTipCtrl:ShowSelectRewardItemView(dItem.items, iCurIdx, cb)
                end, 0, 0)
            end
        end
        g_WindowTipCtrl:ShowSelectRewardItemView(dItem.items, iCurIdx, cb)
    else
        nethuodong.C2GSTotalChargeGetReward(iLv)
    end
end

function CAccumChargePage.OnClickPayBtn(self)
    CNpcShopMainView:ShowView(function(oView)
        oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
    end)
end

function CAccumChargePage.OnAccumChargeCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Timelimit.Event.RefreshAccCharge then
        self:RefreshAll()
    end
end

return CAccumChargePage
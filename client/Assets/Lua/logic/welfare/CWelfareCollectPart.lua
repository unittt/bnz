local CWelfareCollectPart = class("CWelfareCollectPart", CPageBase)

function CWelfareCollectPart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    self.m_TipBtn = self:NewUI(1, CButton)
    self.m_ActTimeL = self:NewUI(2, CLabel)
    self.m_GetWayL = self:NewUI(3, CLabel)
    self.m_ExchangeGrid = self:NewUI(4, CGrid)
    self.m_GiftItem = self:NewUI(5, CBox)

    local sprite = CSprite.New(self:Find("BgContainer/TitleSpr1").gameObject)
    sprite:SetSpriteName("h7_liuyikuaile")
    sprite:MakePixelPerfect()

    self:InitContent()
end

function CWelfareCollectPart.InitContent(self)
    self.m_GiftItemDict = {}
    self.m_GiftInfo = {}
    self.m_CollectKey = g_WelfareCtrl.m_CollectKey

    self.m_ActTimeL:SetText("")
    self.m_GiftItem:SetActive(false)
    -- self.m_GetWayL:SetText("活动期间内：参加日常活动有概率获得【千】【年】【寻】【仙】字牌")
    self.m_GetWayL:SetText("活动期间内：参加日常活动有概率获得【六】【一】【快】【乐】字牌")
end

function CWelfareCollectPart.OnInitPage(self)
    self:InitGiftInfo()
    self:CreateGiftItemGroup()
    self:SetTopMsg()
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTipBtn"))
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self, "OnCtrlEvent"))
end

function CWelfareCollectPart.InitGiftInfo(self)
    local dGiftConfig = DataTools.GetCollectData("GIFT")
    if dGiftConfig then
        for _, dInfo in pairs(dGiftConfig) do
            if dInfo.collect_key == self.m_CollectKey then
                table.insert(self.m_GiftInfo, dInfo)
            end
        end
    end
    table.sort(self.m_GiftInfo, function(a, b)
        return a.redeem_num > b.redeem_num
    end)
end

function CWelfareCollectPart.CreateGiftItemGroup(self)
    for idx, dInfo in ipairs(self.m_GiftInfo) do
        local sKey = dInfo.key
        local oBox = self:CreateGiftItem()
        if idx%2 == 0 then
            oBox.bgSpr:SetSpriteName("h7_1di")
        end
        self.m_GiftItemDict[sKey] = oBox
        self:SetGiftItemInfo(oBox, dInfo)
    end
end

function CWelfareCollectPart.CreateGiftItem(self)
    local oBox = self.m_GiftItem:Clone()
    oBox.exBtn = oBox:NewUI(1, CButton)
    oBox.btnL = oBox:NewUI(2, CLabel)
    oBox.timeL = oBox:NewUI(3, CLabel)
    oBox.giftTable = oBox:NewUI(4, CTable)
    oBox.rewardItem = oBox:NewUI(5, CBox)
    oBox.equalWidget = oBox:NewUI(6, CWidget)
    oBox.wordItem = oBox:NewUI(7, CBox)
    oBox.addWidget = oBox:NewUI(8, CWidget)
    oBox.bgSpr = oBox:NewUI(9, CSprite)
    oBox.costs = {}
    oBox.rewards = {}

    oBox.exBtn:AddUIEvent("click", callback(self, "OnClickGetBtn", oBox))
    oBox.rewardItem:SetActive(false)
    oBox.wordItem:SetActive(false)
    oBox.addWidget:SetActive(false)
    self.m_ExchangeGrid:AddChild(oBox)
    oBox:SetActive(true)
    return oBox
end

function CWelfareCollectPart.SetGiftItemInfo(self, oItem, dInfo)
    oItem.key = dInfo.key
    oItem.redeemNum = dInfo.redeem_num
    self:SetGiftItemRewards(oItem, dInfo.reward)
    self:SetGiftItemCosts(oItem, dInfo.cost_item)
    self:SetGiftItemStatus(oItem)
    self:ReposGiftItemView(oItem)
end

function CWelfareCollectPart.SetGiftItemCosts(self, oItem, lCost)
    oItem.enough = true
    for i, v in ipairs(lCost) do
        local oCost = oItem.costs[v.sid]
        if not oCost then
            oCost = oItem.wordItem:Clone()
            self:InitItemIcon(oCost)
            oItem.costs[v.sid] = oCost
        end
        local dItemInfo = DataTools.GetItemData(v.sid)
        local iAmount = g_ItemCtrl:GetBagItemAmountBySid(v.sid)
        oCost.itemId = v.sid
        oCost.idx = i
        oCost.iconSpr:SpriteItemShape(dItemInfo.icon)
        oCost.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dItemInfo.id, dItemInfo.quality or 0 ) )
        oCost.cntL:SetText(iAmount)
        oCost.curCnt = iAmount
        oCost.needCnt = v.num
        if iAmount < v.num and oItem.enough then
            oItem.enough = false
        end
        oCost.bgSpr:AddUIEvent("click", callback(self, "OnClickItemIcon", v.sid))
        oCost:SetActive(true)
    end
end

function CWelfareCollectPart.SetGiftItemRewards(self, oItem, iReward)
    local dRewardInfo = DataTools.GetReward("COLLECT", iReward)
    if not dRewardInfo then return end
    local lItem = dRewardInfo.item
    if not lItem then return end
    for i, v in ipairs(lItem) do
        local iKey = v.sid
        local oReward = oItem.rewards[iKey]
        if not oReward then
            oReward = oItem.rewardItem:Clone()
            oItem.giftTable:AddChild(oReward)
            self:InitItemIcon(oReward)
            oItem.rewards[iKey] = oReward
        end
        local dItemInfo = DataTools.GetItemData(iKey)
        oReward.itemId = iKey
        oReward.iconSpr:SpriteItemShape(dItemInfo.icon)
        oReward.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dItemInfo.id, dItemInfo.quality or 0 ) )
        -- oReward.cntL:SetText(v.amount)
        oReward.cntL:SetActive(false)
        oReward.bgSpr:AddUIEvent("click", callback(self, "OnClickItemIcon", iKey))
        oReward:SetActive(true)
    end
end

function CWelfareCollectPart.SetGiftItemStatus(self, oItem)
    local iTime = g_WelfareCtrl:GetCollectGiftInfo(oItem.key) or 0
    iTime = oItem.redeemNum - iTime
    local bGet = iTime > 0 and oItem.enough and true or false
    oItem.exBtn:SetEnabled(bGet)
    oItem.btnL:SetColor(bGet and Color.white or Color.RGBAToColor("50585B"))
    oItem.timeL:SetText(string.format("%d/%d",iTime,oItem.redeemNum))
end

function CWelfareCollectPart.UpdateGiftItemCnt(self, oItem)
    oItem.enough = true
    for _, oCost in pairs(oItem.costs) do
        oCost.curCnt = g_ItemCtrl:GetBagItemAmountBySid(oCost.itemId)
        oCost.cntL:SetText(oCost.curCnt)
        if oItem.enough and oCost.curCnt < oCost.needCnt then
            oItem.enough = false
        end
    end
end

function CWelfareCollectPart.ReposGiftItemView(self, oItem)
    local lItemObjs = {}
    for i, obj in pairs(oItem.costs) do
        table.insert(lItemObjs, obj)
    end
    table.sort(lItemObjs, function(a, b)
        return a.idx > b.idx
    end)
    for idx, oCost in ipairs(lItemObjs) do
        if idx == 1 then
            oItem.equalWidget:SetAsLastSibling()
        else
            local oAdd = oItem.addWidget:Clone()
            oAdd:SetActive(true)
            oItem.giftTable:AddChild(oAdd)
        end
        oItem.giftTable:AddChild(oCost)
    end
end

function CWelfareCollectPart.InitItemIcon(self, oIcon)
    oIcon.bgSpr = oIcon:NewUI(1, CSprite)
    oIcon.qualitySpr = oIcon:NewUI(2, CSprite)
    oIcon.iconSpr = oIcon:NewUI(3, CSprite)
    oIcon.cntL = oIcon:NewUI(4, CLabel)
end

function CWelfareCollectPart.SetTopMsg(self)
    local dConfig = DataTools.GetCollectData("CONFIG", self.m_CollectKey)
    if dConfig then
        local dCollect = g_WelfareCtrl.m_CollectGiftInfo
        local sStartTime = self:TransTimeStr(dCollect.start_time)
        local sEndTime = self:TransTimeStr(dCollect.end_time)
        self.m_ActTimeL:SetText(string.format("活动时间：%s-%s", sStartTime, sEndTime))
    end
end

function CWelfareCollectPart.TransTimeStr(self, sTime)
    if not sTime then return "" end
    return os.date("%m月%d日%H:%M:%S", tonumber(sTime))
end

function CWelfareCollectPart.OnClickGetBtn(self, oBox)
    if oBox.key and oBox.enough then
        nethuodong.C2GSRedeemCollectGift(oBox.key)
    end
end

function CWelfareCollectPart.OnClickItemIcon(self, id, oItem)
    local config = {widget = oItem}
    g_WindowTipCtrl:SetWindowItemTip(id, config)
end

function CWelfareCollectPart.OnClickTipBtn(self)
    local instructionConfig = data.instructiondata.DESC[10024]
    if instructionConfig then
        local zContent = {
            title = instructionConfig.title,
            desc = instructionConfig.desc,
        }
        g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
    end
end

function CWelfareCollectPart.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateCollectPnl then
        if not oCtrl.m_EventData then return end
        for i, oItem in pairs(self.m_GiftItemDict) do
            self:UpdateGiftItemCnt(oItem)
            self:SetGiftItemStatus(oItem)
        end
    end
end

return CWelfareCollectPart
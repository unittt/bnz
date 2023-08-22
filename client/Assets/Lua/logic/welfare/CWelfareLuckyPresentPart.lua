local CWelfareLuckyPresentPart = class("CWelfareLuckyPresentPart", CPageBase)

function CWelfareLuckyPresentPart.ctor(self,cb)
    CPageBase.ctor(self, cb)

    self.m_Grid = self:NewUI(1,CGrid)
    self.m_GridBox = self:NewUI(2,CBox)
    self.m_BuyButton = self:NewUI(3,CButton)
    self.m_BuyLabel = self:NewUI(4,CLabel)
    self.m_BtnRimImg = self:NewUI(5,CSprite)
    self.m_BtnTag = self:NewUI(6,CSprite)
    self.m_TipLabel = self:NewUI(7,CLabel)

    self.m_BuyTextColor = self.m_BuyLabel:GetColor()
    self.m_DisableTextColor = Color.RGBAToColor("50585B")
    self.m_BoxBtnTextColor = nil
    self.m_BoxDict = {}
end

function CWelfareLuckyPresentPart.OnInitPage(self)
    self.m_GridBox:SetActive(false)
    self:InitGrids()
    self:SetBuyBtnEnable(g_WelfareCtrl:IsCanBuyAllDaily())
    self.m_BuyButton:AddUIEvent("click", callback(self,"OnClickBuyAll"))
    self.m_BuyLabel:SetText("60元购买(7天)")
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    -- ios 屏蔽十元充值
    -- if Utils.IsIOS() then
    --     self.m_BuyButton:SetActive(false)
    -- end
end

function CWelfareLuckyPresentPart.CreateGrid(self, id)
    local oBox = self.m_GridBox:Clone()
    oBox:SetActive(true)
    oBox.packId = id
    oBox.iconSprite = oBox:NewUI(1,CSprite)
    oBox.mustGrid = oBox:NewUI(2,CGrid)
    oBox.itemBox = oBox:NewUI(3,CBox)
    oBox.itemBox:SetActive(false)
    oBox.randomGrid = oBox:NewUI(4,CGrid)
    oBox.buyBtn = oBox:NewUI(5,CButton)
    oBox.btnLabel = oBox:NewUI(6,CLabel)
    oBox.titleLabel = oBox:NewUI(7,CLabel)
    oBox.descLabel = oBox:NewUI(8,CLabel)
    oBox.btnRimImg = oBox:NewUI(9,CSprite)
    if not self.m_BoxBtnTextColor then
        self.m_BoxBtnTextColor = oBox.btnLabel:GetColor()
    end
    oBox.mustGrid.itemBox = oBox.itemBox
    oBox.randomGrid.itemBox = oBox.itemBox
    self.m_BoxDict[id] = oBox
    self.m_Grid:AddChild(oBox)
    oBox.buyBtn:AddUIEvent("click", callback(self,"OnClickBuyPack", id))
    oBox:SetGroup(self.m_Grid:GetInstanceID())
    return oBox
end

function CWelfareLuckyPresentPart.InitGrids(self)
    local lConfig = {}
    for k, v in pairs(DataTools.GetChargeData("DAILY")) do
        if k ~= "gift_day_all" then
            table.insert(lConfig, v)
        end
    end
    table.sort(lConfig, function(a,b)
        return a.cost < b.cost
    end)
    local iconList = {"h7_1yuan_1","h7_3yuan_1","h7_6yuan_1"}
    for id, info in ipairs(lConfig) do
        local oBox = self.m_Grid:GetChild(id)
        if not oBox then
            oBox = self:CreateGrid(info.key)
        end
        local state = g_WelfareCtrl:GetChargeItemInfo(info.key)
        oBox.payText = info.cost .. "元购买"
        oBox.getText = "已购买"
        oBox.rewardText = "领 取"
        oBox.key = info.key
        oBox.info = info
        oBox.state = state
        oBox.iconSprite:SetSpriteName(iconList[id])
        oBox.titleLabel:SetText(info.cost .. "元礼包")
        oBox.descLabel:SetText(string.ConvertToArt(info.goldcoin_first or 0))
        self:SetBoxBtnState(info.key, state)
        self:InitItemGrid(oBox.mustGrid, info.gift_1)
        self:InitItemGrid(oBox.randomGrid, info.gift_2)
    end
end

function CWelfareLuckyPresentPart.InitItemGrid(self, oGrid, iPackId)
    local lPackInfo = self:GetRewardInfo(iPackId)
    if not lPackInfo then return end
    for idx, info in ipairs(lPackInfo) do
        local oItemBox = oGrid:GetChild(idx)
        local itemId = info.id
        local dItemData = DataTools.GetItemData(itemId)
        if not oItemBox then
            oItemBox = oGrid.itemBox:Clone()
            oItemBox:SetActive(true)
            oItemBox.iconSprite = oItemBox:NewUI(1,CSprite)
            oItemBox.countLabel = oItemBox:NewUI(2,CLabel)
            oItemBox.borderSprite = oItemBox:NewUI(3,CSprite)
            oItemBox:SetGroup(oGrid:GetInstanceID())
            oGrid:AddChild(oItemBox)
            oItemBox:AddUIEvent("click", callback(self, "OnClickItem"), oItemBox)
        end
        oItemBox.itemId = itemId
        oItemBox.iconSprite:SpriteItemShape(dItemData.icon)
        oItemBox.countLabel:SetText(info.num)
        oItemBox.borderSprite:SetItemQuality(g_ItemCtrl:GetQualityVal( dItemData.id, dItemData.quality or 0 ) )
    end
end

function CWelfareLuckyPresentPart.GetRewardInfo(self, iPackId)
    local dPackInfo = DataTools.GetReward("CHARGE", iPackId)
    if not dPackInfo then return end
    local lRewards = {}
    local addInfoFunc = function(id, num)
        if num and num > 0 then
            table.insert(lRewards, {id = id, num = num})
        end
    end
    addInfoFunc(1001, tonumber(dPackInfo.gold))
    addInfoFunc(1002, tonumber(dPackInfo.silver))
    addInfoFunc(1004, tonumber(dPackInfo.goldcoin))
    for _, info in ipairs(dPackInfo.item) do
        addInfoFunc(info.sid, info.amount)
    end
    return lRewards
end

function CWelfareLuckyPresentPart.SetBoxBtnState(self, id, state)
    local oBox = self.m_BoxDict[id]
    if oBox then
        local bEnable = not (state == define.WelFare.Status.Got)
        local labelColor = bEnable and self.m_BoxBtnTextColor or self.m_DisableTextColor
        local sBtnText
        if state == define.WelFare.Status.Unobtainable then
            sBtnText = oBox.payText
        elseif state == define.WelFare.Status.Get then
            sBtnText = oBox.rewardText
        else
            sBtnText = oBox.getText
        end
        oBox.buyBtn:SetEnabled(bEnable)
        oBox.btnRimImg:SetGrey(not bEnable)
        oBox.btnLabel:SetColor(labelColor)
        oBox.btnLabel:SetText(sBtnText)
    end
end

function CWelfareLuckyPresentPart.SetBuyBtnEnable(self, bEnable)
    local labelColor = bEnable and self.m_BuyTextColor or self.m_DisableTextColor
    self.m_BuyButton:SetEnabled(bEnable)
    self.m_BtnRimImg:SetGrey(not bEnable)
    self.m_BtnTag:SetGrey(not bEnable)
    self.m_BuyLabel:SetColor(labelColor)
end

function CWelfareLuckyPresentPart.OnClickBuyPack(self, id)
    local oBox = self.m_BoxDict[id]
    if oBox then
        local state = oBox.state
        if not state then return end
        if state == define.WelFare.Status.Unobtainable then
            -- printc("click buy pack -------- ", id)
            -- table.print(oBox.info, "每日充值回调数据信息")
            -- if oBox.info.payid and string.len(oBox.info.payid) > 0 then 
                nethuodong.C2GSChargeCheckBuy(id)
            -- end
        elseif state == define.WelFare.Status.Get then
            nethuodong.C2GSChargeGetDayReward(id)
        end
    end
end

function CWelfareLuckyPresentPart.OnClickBuyAll(self)

    -- local dPayInfo = DataTools.GetChargeData("DAILY", "gift_day_all")
    -- if dPayInfo then
    --     table.print(dPayInfo, "每日充值(全购)回调数据信息")
    --     if dPayInfo.payid and string.len(dPayInfo.payid) > 0 then
            nethuodong.C2GSChargeCheckBuy("gift_day_all")
    --     end 
    -- end
end

function CWelfareLuckyPresentPart.OnClickItem(self, oItemBox)
    local config = {widget = oItemBox}
    g_WindowTipCtrl:SetWindowItemTip(oItemBox.itemId, config)
end

function CWelfareLuckyPresentPart.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateDailyPnl then
        for _, lChargeInfo in ipairs(oCtrl.m_EventData) do
            self:SetBoxBtnState(lChargeInfo.key, lChargeInfo.val)
            local bBtnEnable = g_WelfareCtrl:IsCanBuyAllDaily()
            self:SetBuyBtnEnable(bBtnEnable)
        end
    end
end

return CWelfareLuckyPresentPart
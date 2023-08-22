local CWingCultureBox = class("CWingCultureBox", CBox)

function CWingCultureBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_LvItemBox = self:NewUI(1, CBox)
    self.m_LvBtn = self:NewUI(2, CButton)
    self.m_StarItemBox = self:NewUI(3, CBox)
    self.m_StarBtn = self:NewUI(4, CButton)
    self.m_StarSlider = self:NewUI(5, CSlider)
    self.m_QuickBuyBox = self:NewUI(6, CQuickBuyBox)
    self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)
    self.m_StarObj = self:NewUI(7, CObject)
    self.m_LvObj = self:NewUI(8, CObject)
    self.m_EffAttrBox = self:NewUI(9, CWingEffectAttrBox)
    self.m_UpgradeL = self:NewUI(10, CLabel)
    self.m_MaxLvL = self:NewUI(11, CLabel)
    self.m_IsFullStar = false
    self:InitContent()
end

function CWingCultureBox.InitContent(self)
    self.m_StarObj:SetActive(false)
    self.m_LvObj:SetActive(false)
    self:InitItemBox(self.m_LvItemBox)
    self:InitItemBox(self.m_StarItemBox)
    self.m_LvBtn:AddUIEvent("click", callback(self, "OnClickLvBtn"))
    self.m_StarBtn:AddUIEvent("click", callback(self, "OnClickStarBtn"))
end

function CWingCultureBox.InitItemBox(self, oBox)
    oBox.iconSpr = oBox:NewUI(1, CSprite)
    oBox.qualitySpr = oBox:NewUI(2, CSprite)
    oBox.amountL = oBox:NewUI(3, CLabel)
    oBox.nameL = oBox:NewUI(4, CLabel)
    oBox.countL = oBox:NewUI(5, CLabel)
    oBox.amountL:SetText("")
    oBox.nameL:SetText("")
    oBox:AddUIEvent("click", callback(self, "OnClickItemBox"))
end

function CWingCultureBox.RefreshInfo(self)
    if not g_WingCtrl:HasActiveWing() then
        self:ShowDefaultMsg()
        return
    end
    local bFullStar = g_WingCtrl:IsMaxStar()
    self.m_IsFullStar = bFullStar
    self.m_StarObj:SetActive(not bFullStar)
    self.m_LvObj:SetActive(bFullStar)
    self.m_EffAttrBox:RefreshAttr(g_WingCtrl:GetNextEffectAttrs())
    if bFullStar then
        self:RefreshLevel()
    else
        self:RefreshStar()
    end
end

function CWingCultureBox.RefreshItemBox(self, oBox, itemId, iNeed, bFull)
    oBox.itemId = itemId
    oBox.needCnt = iNeed
    local dItem = DataTools.GetItemData(itemId)
    oBox.iconSpr:SpriteItemShape(dItem.icon)
    oBox.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dItem.id, dItem.quality or 0 ))
    oBox.nameL:SetText(dItem.name)
    local iOwn = g_ItemCtrl:GetBagItemAmountBySid(itemId)
    if iNeed <= 0 then
        oBox.amountL:SetText("")
    elseif iNeed <= iOwn then
        oBox.amountL:SetText("[b][0fff32]"..iOwn)
        oBox.amountL:SetEffectColor(Color.RGBAToColor("003C41"))
        oBox.countL:SetText("[b]/" .. iNeed)
    else
        oBox.amountL:SetText("[b][ffb398]"..iOwn)
        oBox.amountL:SetEffectColor(Color.RGBAToColor("cd0000"))
        oBox.countL:SetText("[b]/" .. iNeed)
    end
    if bFull then
        self.m_QuickBuyBox:SetActive(false)
        return
    end
    local iTitle, iQuickId
    if self.m_IsFullStar then
        iTitle = "便捷升阶"
        iQuickId = define.QuickBuy.WingLevel
    else
        iTitle = "便捷升星"
        iQuickId = define.QuickBuy.WingStar
    end

    self.m_QuickBuyBox:SetInfo({
        id = iQuickId,
        name = iTitle,
        offset = Vector3(-30,0,0),
        items = {{id = itemId, cnt = iNeed}},
    })
end

function CWingCultureBox.RefreshLevel(self)
    local dConfig = g_WingCtrl:GetCurUpLvConfig()
    local iNeed, itemId = 0, 0
    if dConfig then
        local dCost = dConfig.up_level_cost[1]
        itemId = dCost.sid
        iNeed = dCost.amount
    else
        local dUp = g_WingCtrl:GetUpLvConfig(1)
        if dUp then
            itemId = dUp.up_level_cost[1].sid
        end
    end
    local bMax = not dConfig
    if bMax then
        self.m_QuickBuyBox:HideForce()
    else
        self:RefreshItemBox(self.m_LvItemBox, itemId, iNeed, bMax)
        self.m_LvBtn:SetBtnGrey(not g_WingCtrl:IsCanUpLevel() or bMax)
        self.m_UpgradeL:SetText("升阶提升")
    end
    self.m_MaxLvL:SetActive(bMax)
    self.m_LvItemBox:SetActive(not bMax)
    self.m_LvBtn:SetActive(not bMax)
end

function CWingCultureBox.RefreshStar(self)
    local iExp = 0
    local bActiveWing = g_WingCtrl:HasActiveWing()
    if bActiveWing then
        iExp = g_WingCtrl:GetCurUpStarExp()
    else
        iExp = g_WingCtrl:GetUpStarExp(0,0)
    end
    self.m_StarBtn:SetBtnGrey(not bActiveWing)
    local itemId = g_WingCtrl.starCost
    local dItem = DataTools.GetItemData(itemId)
    local iAddExp = tonumber(dItem.item_formula)
    local iNeed = math.ceil((iExp - g_WingCtrl.exp)/iAddExp)
    self:RefreshItemBox(self.m_StarItemBox, itemId, iNeed)

    local iCurExp = math.min(g_WingCtrl.exp, iExp)
    self.m_StarSlider:SetSliderText(string.format("%d/%d", iCurExp, iExp))
    self.m_StarSlider:SetValue(iCurExp/iExp)
    self.m_UpgradeL:SetText("升星提升")
    self.m_MaxLvL:SetActive(false)
end

function CWingCultureBox.CheckCostEnough(self, oBox)
    if not oBox.itemId then return false end
    if self.m_QuickBuyBox:IsSelected() then
        return self.m_QuickBuyBox:CheckCostEnough()
    else
        local iOwn = g_ItemCtrl:GetBagItemAmountBySid(oBox.itemId)
        local bEnough = iOwn >= oBox.needCnt
        if not bEnough then
            local t = {
                sid = oBox.itemId,
                count = iOwn,
                amount = oBox.needCnt,
            }
            g_QuickGetCtrl:CurrLackItemInfo({t},{}, nil, function()
                if g_WingCtrl:IsMaxStar() then
                    netwing.C2GSWingUpLevel(1)
                else
                    netwing.C2GSWingUpStar(1)
                end
            end)
        end
        return bEnough
    end
end

function CWingCultureBox.ShowDefaultMsg(self)
    self.m_StarObj:SetActive(true)
    self.m_LvObj:SetActive(false)
    self:RefreshStar()
    local dAttr = g_WingCtrl:GetStateEffectAttrs(0,0)
    self.m_EffAttrBox:RefreshAttr(dAttr)
    self.m_UpgradeL:SetText("激活提升")
end

function CWingCultureBox.OnClickLvBtn(self)
    if not g_WingCtrl:IsCanUpLevel() then
        -- g_WingCtrl:WingFloatMsg(2002)
        local dLimit = g_WingCtrl:GetLvLimit((g_WingCtrl.level or 0) + 1)
        if dLimit then
            g_NotifyCtrl:FloatMsg(string.format("已达到当前升阶上限，#G%d#n级可进阶", dLimit.player_grade))
        else
            g_NotifyCtrl:FloatMsg("羽翼已进阶至最高等级")
        end
        return
    end
    if self:CheckCostEnough(self.m_LvItemBox) then
        local iQuickSel = self.m_QuickBuyBox:IsSelected() and 1 or 0
        netwing.C2GSWingUpLevel(iQuickSel)
    end
end

function CWingCultureBox.OnClickStarBtn(self)
    if g_WingCtrl:HasActiveWing() then
        if self:CheckCostEnough(self.m_StarItemBox) then
            local iQuickSel = self.m_QuickBuyBox:IsSelected() and 1 or 0
            netwing.C2GSWingUpStar(iQuickSel)
        end
    else
        g_WingCtrl:WingFloatMsg(6002)
    end
end

function CWingCultureBox.OnClickItemBox(self, oBox)
    if not oBox.itemId then return end
    g_WindowTipCtrl:SetWindowGainItemTip(oBox.itemId)
end

return CWingCultureBox
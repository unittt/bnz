local CSummonCulturePart = class("CSummonCulturePart", CBox)

function CSummonCulturePart.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_CurIdx = nil
    self.m_ItemId = 10034
    self.m_ItemCnt = 0
    self:InitContent()
end

function CSummonCulturePart.InitContent(self)
    self.m_ItemBox = self:NewUI(1, CBox)
    self.m_UpgradeBtn = self:NewUI(2, CButton)
    self.m_DesBtn = self:NewUI(3, CButton)
    self.m_AptiBox = self:NewUI(4, CSummonCultureAptiBox)
    self.m_QuickBuyBox = self:NewUI(5, CQuickBuyBox)
    self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)
    self.m_QuickBuyBox:SetInfo({
        id = define.QuickBuy.SummonCulture,
        name = "便捷购买",
        offset = Vector3(-15,0,0),
    })
    self:InitItemBox()
    self:RegisterEvents()
end

function CSummonCulturePart.RegisterEvents(self)
    local aptiBoxs = self.m_AptiBox:GetGridChildList()
    for i, oBox in ipairs(aptiBoxs) do
        if i > 5 then
            break
        end
        oBox:AddUIEvent("click", callback(self, "OnClickApti", i))
    end
    self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnClickUpgrade"))
    self.m_UpgradeBtn.m_ClkDelta = 0.34
    self.m_DesBtn:AddUIEvent("click", callback(self, "OnClickDes"))
    self.m_ItemBox:AddUIEvent("click", callback(self, "OnClickItem"))
end

function CSummonCulturePart.InitItemBox(self)
    local dItem = DataTools.GetItemData(self.m_ItemId)
    local oItem = self.m_ItemBox
    oItem.iconSpr = oItem:NewUI(1, CSprite)
    oItem.nameL = oItem:NewUI(2, CLabel)
    oItem.cntL = oItem:NewUI(3, CLabel)
    oItem.qualitySpr = oItem:NewUI(4, CSprite)
    oItem.descL = oItem:NewUI(5, CLabel)
    oItem.iconSpr:SpriteItemShape(dItem.icon)
    oItem.nameL:SetText(dItem.name)
    oItem.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dItem.id, dItem.quality or 0 ) )
    self:RefreshItemDesc()
    self:RefreshItemCnt()
end

function CSummonCulturePart.OnActive(self, bActive)
    CBox.OnActive(self, bActive)
    if not bActive then
        self.m_CurIdx = nil
    end
end

function CSummonCulturePart.SetInfo(self, dSummon)
    local iSel = self.m_AptiBox:SetInfo(dSummon)
    if not self.m_CurIdx or dSummon.id ~= self.m_CurSummonId then
        self.m_CurIdx = iSel
    end
    self.m_CurSummonId = dSummon.id
    self.m_SummonData = dSummon
    local oBox = self.m_AptiBox:GetGridChild(self.m_CurIdx)
    if oBox then
        oBox:SetSelected(true)
    end
    self:RefreshItemDesc()
end

function CSummonCulturePart.RefreshItemCnt(self)
    local iCnt = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
    local oItem = self.m_ItemBox
    self.m_ItemCnt = iCnt
    if iCnt > 0 then
        oItem.cntL:SetEffectColor(Color.RGBAToColor("003C41"))
        oItem.cntL:SetText("[0fff32]"..iCnt)
    else
        oItem.cntL:SetEffectColor(Color.RGBAToColor("cd0000"))
        oItem.cntL:SetText("[ffb398]"..iCnt)
    end
    self.m_QuickBuyBox:SetItemsInfo({{id = self.m_ItemId, cnt = 1}})
end

function CSummonCulturePart.RefreshItemDesc(self)
    local oLabel = self.m_ItemBox.descL
    if not self.m_CurIdx then
        oLabel:SetText("")
    else
        local oBox = self.m_AptiBox:GetGridChild(self.m_CurIdx)
        if oBox.isFull then
            oLabel:SetText((oBox.nameText or "").."资质已满")
        else
            local dAdd = SummonDataTool.CalcSummonAptitudeAdd(self.m_SummonData, oBox.attrKey)
            if dAdd then
                oLabel:SetText(string.format("增加%d～%d点资质", dAdd[1], dAdd[2]))    
            end
        end
    end
end

function CSummonCulturePart.OnClickApti(self, idx)
    self.m_CurIdx = idx
    self:RefreshItemDesc()
end

function CSummonCulturePart.OnClickUpgrade(self)
    if not self.m_CurIdx then
        g_NotifyCtrl:FloatSummonMsg(1043)
        return
    end
    local oBox = self.m_AptiBox:GetGridChild(self.m_CurIdx)
    if oBox.isFull then
        g_NotifyCtrl:FloatSummonMsg(1044)
        return
    end
    local bQuickSel = self.m_QuickBuyBox:IsSelected()
    if bQuickSel then
        if not self.m_QuickBuyBox:CheckCostEnough() then
            return
        end
    else
        if self.m_ItemCnt <= 0 then
            local t = {
                sid = self.m_ItemId,
                count = 0,
                amount = 1,
            }
            g_QuickGetCtrl:CurrLackItemInfo({t},{}, nil, function()
                g_SummonCtrl:C2GSUseAptitudePellet(self.m_CurSummonId, self.m_CurIdx, 1)
            end)
            return
        end
    end
    g_SummonCtrl:C2GSUseAptitudePellet(self.m_CurSummonId, self.m_CurIdx, bQuickSel and 1 or 0)
end

function CSummonCulturePart.OnClickDes(self)
    local dContent = {title = "培养",desc = SummonDataTool.GetText(2001)}
    g_WindowTipCtrl:SetWindowInstructionInfo(dContent)
end

function CSummonCulturePart.OnClickItem(self)
    g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemId)
end

return CSummonCulturePart
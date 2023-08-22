local CGoldGoinShopItemBox = class("CGoldGoinShopItemBox", CBox)

function CGoldGoinShopItemBox.ctor(self, obj)

    CBox.ctor(self, obj)

    self.m_Name = self:NewUI(1, CLabel)
    self.m_Icon = self:NewUI(2, CSprite)
    self.m_MoneyBox = self:NewUI(3, CBox)
    self.m_MoneyGrid = self:NewUI(4, CGrid)
    self.m_NeedIcon = self:NewUI(5, CSprite)
    self.m_QualitySpr = self:NewUI(6, CSprite)
    self.m_ItemTagSpr = self:NewUI(7, CSprite)
    self.m_AmountL = self:NewUI(8, CLabel)
    self.m_NameSel = self:NewUI(9, CLabel)

    self.m_newTip = self:NewUI(10, CSprite)

    self.m_newTip:SetActive(false)
    self.m_MoneyBox:SetActive(false)

end

CGoldGoinShopItemBox.m_DiscountSprList = {
    [3] = "h7_3zhe", [5] = "h7_5zhe", [7] = "h7_7zhe", [9] = "h7_9zhe"
}

function CGoldGoinShopItemBox.SetData(self, shopItemData)
    self.m_Data = shopItemData
    
    local item = DataTools.GetItemData(shopItemData.item_id)

    if item ~= nil then 
        self.m_Name:SetText(item.name)
        self.m_NameSel:SetText(item.name)
        self.m_Icon:SpriteItemShape(item.icon)
        if DataTools.GetItemData(item.id, "EQUIP") == nil then
            self.m_QualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( item.id, item.quality or 0 ))
        end

        --新商品提示(仅限元宝商店和限时购买)
        if self.m_Data.shop_id == 301 or self.m_Data.shop_id == 302 then
            local oldGoodList = g_ShopCtrl:GetShopDataRecord()
            
            local id = tostring(self.m_Data.id)
            if not oldGoodList[id] then 
                self.m_newTip:SetActive(true)
            end
        end   

    end 

    --[[
        限时打折开启后，元宝商城(301)的商品价格需显示为折后价
        但是不同商店共用同一个脚本，建议在初始化价格时分开处理
    ]]--
    local dPrice, discount =0, 10
    local idx = 1
    for k, v in pairs(shopItemData.virtual_coin) do 
        local oBox = self.m_MoneyGrid:GetChild(idx)
        if not oBox then 
            oBox = self:CloneMoneyBox()
        end
        
        dPrice, discount = g_ShopCtrl:GetDiscountPrice(v.count, shopItemData.limittime_discount)
        self:RefreshMoneyBox(oBox, v, dPrice, shopItemData.shop_id)

        oBox:SetActive(true)
        self.m_MoneyGrid:AddChild(oBox)
        idx = idx + 1
        break
    end

     --[限时打折]--
    if shopItemData.shop_id == 301 then
        if discount < 10 then
            local spriteName = self.m_DiscountSprList[discount]
            self.m_ItemTagSpr:SetSpriteName(spriteName)
            self.m_ItemTagSpr:SetActive(true)
        else
            self.m_ItemTagSpr:SetActive(false)
        end
    else
        --[此处为正常打折，与限时打折无关]--
        if string.len(shopItemData.discount) > 0 then
            self.m_ItemTagSpr:SetSpriteName(shopItemData.discount)
            self.m_ItemTagSpr:SetActive(true)
        else
            self.m_ItemTagSpr:SetActive(false)
        end
    end
    
    if shopItemData.shop_id == 302 then
        self.m_AmountL:SetActive(false)
    else
        local iLeft = g_ShopCtrl:GetLeftAmount(shopItemData)
        self:UpdateRemainCnt(iLeft)
    end
end

function CGoldGoinShopItemBox.UpdateRemainCnt(self, iCnt)
    if iCnt > 0 then
        self.m_AmountL:SetText(iCnt)
        self.m_AmountL:SetActive(true)
    elseif iCnt == 0 then
        self:SetActive(false)
    else
        self.m_AmountL:SetActive(false)
    end
end

function CGoldGoinShopItemBox.ActiveNeedIcon(self, isActive)
    self.m_NeedIcon:SetActive(isActive)
end

function CGoldGoinShopItemBox.CloneMoneyBox(self)
    local oBox = self.m_MoneyBox:Clone()
    oBox.m_MoneyCount = oBox:NewUI(1, CLabel)
    oBox.m_MoneyIcon = oBox:NewUI(2, CSprite)
    return oBox
end

function CGoldGoinShopItemBox.RefreshMoneyBox(self, oBox, moneyData, price, shopId)
    oBox.m_MoneyCount:SetCommaNum(price)
    if shopId == 301 then
        oBox.m_MoneyIcon:SpriteItemShape(10221)
    else
        local dMoneyInfo = DataTools.GetItemData(moneyData.id, "VIRTUAL")
        oBox.m_MoneyIcon:SpriteItemShape(dMoneyInfo.icon)
    end
end

return CGoldGoinShopItemBox
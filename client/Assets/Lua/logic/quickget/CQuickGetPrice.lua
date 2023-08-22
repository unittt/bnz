local CQuickGetPrice = class("CQuickGetPrice")

function CQuickGetPrice.ctor(self, itemId)
    self.itemId = itemId
    self.storeType = 0
    self.serverPrice = nil
    self.cachePrice = nil
    self.matInfo = nil
    self.composeList = {}

    self.m_CacheTimer = nil
    self.m_CacheTime = 3
    self.m_IsGetting = false
    self.m_GetTimer = nil
    self.m_GetOutTime = 1

    self:InitComposeInfo()
    self:InitStoreType()
end

function CQuickGetPrice.InitComposeInfo(self)
    self.isPartnerChip = self:IsPartnerChip()
    self.isAttachSoul = self:IsAttachSoulItem()

    local itemId = self.itemId
    if self.isPartnerChip or self.isAttachSoul then
        local itemList = DataTools.GetItemComposeCompound(itemId)
        if itemList and next(itemList) then
            local d = itemList[1]
            local iCompose = d.sid
            self.matInfo = {
                amount = d.amount,
                id = iCompose,
            }
        end
    end
end

function CQuickGetPrice.InitStoreType(self)
    local dItem = DataTools.GetItemData(self.itemId)
    local iStore
    if dItem then
        local bStore, bAuction, bStall
        for _, v in ipairs(dItem.gainWayIdStr) do
            if v == 3 or v == 21 or v == 42 then
                bStore = true
            elseif v == 5 then
                bStall = true
            elseif v == 6 then
                bAuction = true
            end
        end
        if bStore and bStall then
            iStore = 3
        elseif bAuction then
            iStore = 1
        elseif bStall then
            iStore = 4
        elseif bStore then
            iStore = 2
        end
    end
    self.storeType = iStore or 0
end

function CQuickGetPrice.IsPartnerChip(self)
    return self.itemId >= 30600 and self.itemId < 30630
end

function CQuickGetPrice.IsAttachSoulItem(self)
    return DataTools.GetItemData(self.itemId, "EQUIPSOUL") and true or false
end

function CQuickGetPrice.RecordComposeItem(self, iTarget, iAmount)
    table.insert(self.composeList, {sid = iTarget, amount = iAmount})
end

function CQuickGetPrice.GetOwnItemAmount(self)
    local sid = self.itemId
    local iBag = g_ItemCtrl:GetBagItemAmountBySid(sid)
    local iMat, iAmount = self:GetMatInfo(sid)
    if iMat then
        -- 碎片
        iBag = iBag + g_ItemCtrl:GetBagItemAmountBySid(iMat)/iAmount
    else
        -- 打造素材
        if sid >= 11092 and sid <= 11096 then
            iBag = iBag + g_ItemCtrl:CalculateStrengthItemCnt(sid)
        end
    end
    return iBag
end

function CQuickGetPrice.GetMatInfo(self)
    local dMat = self.matInfo
    if dMat then
        return dMat.id, dMat.amount
    end
end

function CQuickGetPrice.GetPriceInfo(self, bOnlyGet)
    local dPrice = self.cachePrice
    if not dPrice and not bOnlyGet then
        if self.m_IsGetting then
            return
        end
        self:AddGetTimer()
        local iStoreType = self.storeType
        local itemId = self.itemId
        if self.matInfo then
            local iMat = self.matInfo.id
            local oMat = g_QuickGetCtrl:GetQuickGetObj(iMat)
            iStoreType = oMat.storeType
            oMat:RecordComposeItem(itemId, self.matInfo.amount)
            itemId = iMat
        end
        netitem.C2GSFastBuyItemPrice(itemId, iStoreType)
        return nil
    end
    return dPrice
end

function CQuickGetPrice.GetAskInfo(self, bRecord)
    if self.m_IsGetting then
        return
    end
    self:AddGetTimer()
    if self.matInfo then
        local iMat = self.matInfo.id
        local oMat = g_QuickGetCtrl:GetQuickGetObj(iMat)
        if bRecord then
            oMat:RecordComposeItem(self.itemId, self.matInfo.amount)
        end
        return {sid = iMat, store_type = oMat.storeType}
    end
    return {sid = self.itemId, store_type = self.storeType}
end

function CQuickGetPrice.HandlePriceInfo(self, dPrice)
    local bSave = dPrice.money_type == define.Currency.Type.GoldCoin
    self.serverPrice = dPrice
    self.cachePrice = dPrice
    if not bSave then
        self:AddPriceCacheTimer()
    end
    self:DelGetTimer()
    self.m_IsGetting = false
    if next(self.composeList) then
        local idx = 1
        local dCompose = self.composeList[idx]
        local iCompose = dCompose.sid
        dPrice = {
            money_type = dPrice.money_type,
            price = dCompose.amount * dPrice.price,
            sid = iCompose,
        }
        table.remove(self.composeList, idx)
        local oCompose = g_QuickGetCtrl:GetQuickGetObj(iCompose)
        oCompose:HandlePriceInfo(dPrice)
    end
    return dPrice
end

function CQuickGetPrice.AddPriceCacheTimer(self)
    if self.m_CacheTimer then
        Utils.DelTimer(self.m_CacheTimer)
        self.m_CacheTimer = nil
    end
    self.m_CacheTimer = Utils.AddTimer(callback(self, "DelPriceCache"), 0, self.m_CacheTime)
end

function CQuickGetPrice.DelPriceCache(self)
    self.cachePrice = nil
    return false
end

function CQuickGetPrice.AddGetTimer(self)
    self:DelGetTimer()
    self.m_IsGetting = true
    self.m_GetTimer = Utils.AddTimer(function()
        self.m_IsGetting = false
    end, 0, self.m_GetOutTime)
end

function CQuickGetPrice.DelGetTimer(self)
    if self.m_GetTimer then
        Utils.DelTimer(self.m_GetTimer)
        self.m_GetTimer = nil
    end
end

function CQuickGetPrice.Destroy(self)
    if self.m_CacheTimer then
        Utils.DelTimer(self.m_CacheTimer)
        self.m_CacheTimer = nil
    end
    self:DelGetTimer()
    self.composeList = nil
    self.matInfo = nil
    self.serverPrice = nil
    self.cachePrice = nil
    end

return CQuickGetPrice
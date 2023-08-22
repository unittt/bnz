local CQuickBuyBox = class("CQuickBuyBox", CBox)

function CQuickBuyBox.ctor(self, obj)
    CBox.ctor(self, obj)   
    self.m_IsSel = false
    self.m_Name = nil
    self.m_Id = nil
    self.m_OffsetVec = 0
    self.m_ItemDict = {}
    self.m_ItemIds = nil
    self.m_Currencys =nil

    self.m_Toggle = self:NewUI(1, CWidget)
    self.m_NameL = self:NewUI(2, CLabel)
    self.m_SelWgt = self:NewUI(3, CWidget)
    self.m_CostBox = self:NewUI(4, CCurrencyBox)
    self.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)
    self.m_CostBox.m_CountLabel:SetColor(Color.white)
    self.m_CostBox:SetActive(false)
    g_AttrCtrl:DelCtrlEvent(self.m_CostBox:GetInstanceID())

    self.m_DefaultPos = self:GetLocalPos()
    self.m_ActiveState = self:GetActive()
    self:BaseSetActive(false)

    self.m_IsValid = true
    self.m_RefreshItems = nil
    self.m_RefreshCost = false
    self.m_CurrencyVal = 0
    self.m_CostAmount = 0

    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))
    g_QuickGetCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnQuickGetEvent"))
    self.m_Toggle:AddUIEvent("click", callback(self, "OnToggle"))
end

--[[ args
    id      define.QuickBuy.
    name    名字，如: 快捷打造
    offset 勾选后位置偏移量，Vector3
    
    items(list):
        id/sid  物品sid
        cnt/amount 需要数量
        costdirect 是否先消耗当前类型货币，不足部分再转换成元宝

    currencys(list):
        money_type 货币type
        price 价格 

    allBuy  全部购买，不使用背包，默认false
]]
function CQuickBuyBox.SetInfo(self, args)
    self.m_Id = args.id
    self.m_Name = args.name or "便捷购买"
    self.m_OffsetVec = args.offset or Vector3.zero
    self.m_Currencys = args.currencys
    self.m_AllBuy = args.allBuy or false

    self.m_NameL:SetText(self.m_Name)
    self:SetSelected()
    self:SetItemsInfo(args.items)
end

function CQuickBuyBox.SetItemsInfo(self, items, bForce)
    if g_KuafuCtrl:IsInKS() then
        -- bForce = true
        self:BaseSetActive(false)
        return
    end
    if not bForce then
        local bCache = not self:IsNeedRefreshNow() and items and next(items)
        if bCache then
            if self.m_ActiveState and not self:GetActive() then
                self:BaseSetActive(true)
            end
            self.m_RefreshItems = items
            return
        end
    end
    self.m_ItemDict, self.m_ItemIds = g_QuickGetCtrl:HandleItems(items)
    self:CheckItemsValid(bForce)
    self:RefreshCost()
end

function CQuickBuyBox.SetCurrencys(self, currencys)
    self:HandleCurrencys(currencys)
    self:RefreshCost()
end

function CQuickBuyBox.SetItemsAndCurrencys(self, items, currencys)
    self:HandleCurrencys(currencys)
    self:SetItemsInfo(items)
end

function CQuickBuyBox.HandleCurrencys(self, currencys)
    if currencys and #currencys > 0 then
        if not currencys[1].money_type then
            currencys = CQuickGetCostHelp.ConvertItem2Currency(currencys)
        end
    end
    self.m_Currencys = currencys
end

function CQuickBuyBox.SetName(self, sName)
    self.m_Name = sName
    self.m_NameL:SetText(sName)
end

function CQuickBuyBox.RefreshCost(self)
    if not self.m_IsValid then
        return
    end
    if self.m_ActiveState and not self:GetActive() then
        self:BaseSetActive(true)
    end
    if not self:IsNeedRefreshNow() then
        self.m_RefreshCost = true
        return
    end
    self.m_RefreshCost = false
    local iTotal, iMoneyType = 0
    -- if self.m_Currencys then
    iTotal, iMoneyType = CQuickGetCostHelp.CalcTotalCost(self.m_ItemDict, self.m_Currencys, self.m_AllBuy)
    -- else
    --     iTotal, iMoneyType = CQuickGetCostHelp.CalcItemsDirectCost(self.m_ItemDict, self.m_AllBuy)
    -- end
    iMoneyType = iMoneyType or define.Currency.Type.GoldCoin
    if iMoneyType ~= self:GetMoneyType() then
        local iCurrency = iMoneyType
        if iCurrency == define.Currency.Type.GoldCoin then
            iCurrency = define.Currency.Type.AnyGoldCoin
        end
        self.m_CostBox:SetCurrencyType(iCurrency, true)
    end
    self.m_CurrencyVal = CQuickGetCostHelp.GetOwnMoney(iMoneyType)
    local bEnough = CQuickGetCostHelp.IsCostEnough(iMoneyType, iTotal)
    if bEnough then
        self.m_CostBox.m_CountLabel:SetText("[1d8e00]"..iTotal)
    else
        self.m_CostBox.m_CountLabel:SetText("#R"..iTotal)
    end
    self.m_CostAmount = iTotal
end

function CQuickBuyBox.RefreshPos(self)
    local pos = self.m_DefaultPos
    if self.m_IsSel then
        pos = pos + self.m_OffsetVec
    end
    self.m_CostBox:SetActive(self.m_IsSel)
    self.m_SelWgt:SetActive(self.m_IsSel)
    self:SetLocalPos(pos)
end

function CQuickBuyBox.SetSelected(self, bSel)
    self.m_IsSel = bSel
    if bSel == nil then
        bSel = false
        if self.m_Id then
            bSel = g_QuickGetCtrl:GetQuickBuyState(self.m_Id)
        end
        self.m_IsSel = bSel
    else
        if bSel then
            self:CheckCacheInfo()
        end
        g_QuickGetCtrl:SetQuickBuyState(self.m_Id, bSel)
    end
    self:RefreshPos()
end

function CQuickBuyBox.IsSelected(self)
    if not self:GetActive() then
        return false
    end
    return self.m_IsSel
end

function CQuickBuyBox.CheckCostEnough(self)
    local iMoneyType = self:GetMoneyType()
    local bEnough = CQuickGetCostHelp.IsCostEnough(iMoneyType, self.m_CostAmount)
    if not bEnough then
        g_QuickGetCtrl:OnShowNotEnoughGoldCoin()
    end
    return bEnough
end

function CQuickBuyBox.GetMoneyType(self)
    local iMoneyType = self.m_CostBox.m_CurrencyType
    if iMoneyType == define.Currency.Type.AnyGoldCoin then
        iMoneyType = define.Currency.Type.GoldCoin
    end
    return iMoneyType
end

function CQuickBuyBox.GetCostAmount(self)
    return self.m_CostAmount
end

function CQuickBuyBox.GetTotalGoldCoinCost(self)
    return g_QuickGetCtrl:GetTotalGoldCoinCost(self.m_ItemDict, self.m_Currencys, self.m_AllBuy)
end

function CQuickBuyBox.CheckItemsValid(self, bForce)
    local bValid = true
    if (not self.m_ItemIds or not next(self.m_ItemIds)) and not self.m_Currencys then
        self:BaseSetActive(false)
        bValid = false
    else
        for k, dItem in pairs(self.m_ItemDict) do
            local dPrice = dItem.price
            if not dPrice then
                if not bForce then
                    bValid = false
                end
            elseif not dPrice.price or dPrice.price <= 0 then
                self:BaseSetActive(false)
                bValid = false
            end
        end
    end
    self.m_IsValid = bValid
    return bValid
end

function CQuickBuyBox.IsNeedRefreshNow(self)
    return self.m_ActiveState and self.m_IsSel
end

function CQuickBuyBox.CheckCacheInfo(self, bForce)
    if self.m_RefreshItems then
        self:SetItemsInfo(self.m_RefreshItems, bForce)
        self.m_RefreshItems = nil
    elseif self.m_RefreshCost then
        self:RefreshCost()
    end
end

function CQuickBuyBox.OnToggle(self)
    if not self.m_Id then return end
    if self.m_IsSel then
        self:SetSelected(false)
    else
        self:CheckCacheInfo(true)
        if not self.m_IsValid then
            return
        end
        local sNames = CQuickGetCostHelp.GetCostNameText(self.m_Currencys, self.m_ItemIds)
        if not sNames then
            return
        end
        local sMsg = string.format("使用%s，将花费元宝自动购买%s。是否确定开启", self.m_Name, sNames or "")
        local windowConfirmInfo = {
            msg = sMsg,
            okCallback = callback(self, "SetSelected", true),
            cancelokCallback = callback(self, "SetSelected", false),
        }
        g_WindowTipCtrl:SetWindowNetConfirm(windowConfirmInfo)
    end
end

function CQuickBuyBox.OnItemCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
        oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
        self:RefreshCost()
    end
end

function CQuickBuyBox.OnQuickGetEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.ReceiveQuickBuyPrice then
        local dInfo = oCtrl.m_EventData
        if dInfo and self.m_ItemDict[dInfo.sid or 0] then
            self.m_ItemDict[dInfo.sid].price = dInfo
            self:CheckItemsValid()
            self:RefreshCost()
        end
    elseif oCtrl.m_EventID == define.Item.Event.ReceiveQuickBuyPriceList then
        local infoList = oCtrl.m_EventData
        local bRefresh = false
        local dItem = nil
        for _, dInfo in ipairs(infoList) do
            dItem = self.m_ItemDict[dInfo.sid or 0]
            if dItem then
                dItem.price = dInfo
                bRefresh = true
            end
        end
        if bRefresh then
            self:CheckItemsValid()
            self:RefreshCost()
        end
    end
end

function CQuickBuyBox.OnAttrCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
        local dChange = oCtrl.m_EventData.dAttr
        if dChange.gold or dChange.silver or dChange.goldcoin or dChange.rplgoldcoin then
            self:RefreshCost()
        end
    end
end

function CQuickBuyBox.SetActive(self, bActive)
    if g_KuafuCtrl:IsInKS() then
        bActive = false
    end
    CBox.SetActive(self, bActive)
    self.m_ActiveState = bActive
    if bActive then
        self:CheckCacheInfo()
    end
end

function CQuickBuyBox.BaseSetActive(self, bActive)
    if g_KuafuCtrl:IsInKS() then
        bActive = false
    end
    CBox.SetActive(self, bActive)
end

function CQuickBuyBox.HideForce(self, bHide)
    local bActive
    if bHide == nil then
        bActive = false
    else
        bActive = not bHide
    end
    self:SetActive(bActive)
end

return CQuickBuyBox
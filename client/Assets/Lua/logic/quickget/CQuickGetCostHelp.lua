local CQuickGetCostHelp = class("CQuickGetCostHelp")

local CurrencyInfo = {
    [define.Currency.Type.GoldCoin] = {
        key = "goldcoin",
        name = "元宝",
        weight = 3,
        text = "#cur_2",
    },
    [define.Currency.Type.Gold] = {
        key = "gold",
        name = "金币",
        weight = 2,
        text = "#cur_3",
    },
    [define.Currency.Type.Silver] = {
        key = "silver",
        name = "银币",
        weight = 1,
        text = "#cur_4",
    },
}

local AttrDict = {}

function CQuickGetCostHelp.ConvertItem2Currency(items)
    if not items or not next(items) then
        return
    end
    local currencys = {}
    local sid, moneyType = 0
    for i, v in ipairs(items) do
        sid = v.sid or v.id
        moneyType = 0
        if sid == 1001 then
            moneyType = define.Currency.Type.Gold
        elseif sid == 1002 then
            moneyType = define.Currency.Type.Silver
        elseif sid == 1003 or sid == 1004 then
            moneyType = define.Currency.Type.GoldCoin
        end
        if moneyType > 0 then
            table.insert(currencys, {
                money_type = moneyType,
                price = v.amount,
            })
        end
    end
    return currencys
end

function CQuickGetCostHelp.Convert2GoldCoin(iType, iVal)
    if iType == define.Currency.Type.GoldCoin or iVal <= 0 then
        return iVal
    else
        local dExch = data.storedata.EXCHANGEMONEY[iType]
        if dExch then
            local sFormula = dExch.goldcoin
            return string.eval(sFormula, {value = iVal, SLV = g_AttrCtrl.server_grade, math = math})
        end
        return 0
    end
end

function CQuickGetCostHelp.CalcTotalCostOld(items, currencys, bAllBuy)
    local iTotal, iMoneyType = 0
    AttrDict = {}
    if currencys then
        iTotal = iTotal + CQuickGetCostHelp.CalcCurrencysCost(currencys)
    end
    if items then
        local iItemCost
        if iTotal > 0 then
            iItemCost, iMoneyType = CQuickGetCostHelp.CalcItemsCost(items, bAllBuy)
        else
            iItemCost, iMoneyType = CQuickGetCostHelp.CalcItemsDirectCost(items, bAllBuy)
        end
        iTotal = iItemCost + iTotal
    end
    return iTotal, iMoneyType
end

function CQuickGetCostHelp.CalcTotalCost(items, currencys, bAllBuy)
    local iTotal, iMoneyType = 0
    AttrDict = {}
    local dCost, dDirect = CQuickGetCostHelp.GetItemsCostInfo(items, bAllBuy)
    if currencys then
        for _, d in ipairs(currencys) do
            local k, v = d.money_type, d.price
            CQuickGetCostHelp.RecordCost(dCost, k, v)
            CQuickGetCostHelp.RecordCost(dDirect, k, v)
        end
    end
    iTotal = CQuickGetCostHelp.CalcCost(dCost, dDirect)
    if iTotal <= 0 then
        for k, v in pairs(dCost) do
            if v > 0 then
                if iMoneyType then
                    if CurrencyInfo[k].weight > CurrencyInfo[iMoneyType].weight then
                        iMoneyType = k
                        iTotal = v
                    end
                else
                    iMoneyType = k
                    iTotal = v
                end
            end
        end
    end
    return iTotal, iMoneyType
end

function CQuickGetCostHelp.CalcCurrencysCost(currencys)
    local dCost = {}
    local dDirect = {}
    local k, v
    for _, d in ipairs(currencys) do
        k, v = d.money_type, d.price
        CQuickGetCostHelp.RecordCost(dCost, k, v)
        CQuickGetCostHelp.RecordCost(dDirect, k, v)
    end
    return CQuickGetCostHelp.CalcCost(dCost, dDirect)
end

function CQuickGetCostHelp.CalcItemsDirectCost(items, bAllBuy)
    local dCost, dDirect = CQuickGetCostHelp.GetItemsCostInfo(items, bAllBuy)
    local iCost = CQuickGetCostHelp.CalcCost(dCost, dDirect)
    if iCost <= 0 then
        local iMoney
        for k, v in pairs(dCost) do
            if dDirect[k] then
                return v, k
            end
        end
    end
    return iCost
end

function CQuickGetCostHelp.CalcItemsCost(items, bAllBuy)
    local dCost, dDirect = CQuickGetCostHelp.GetItemsCostInfo(items, bAllBuy)
    return CQuickGetCostHelp.CalcCost(dCost, dDirect)
end

function CQuickGetCostHelp.GetItemsCostInfo(items, bAllBuy)
    local dCost = {}
    local dDirect = {}
    if items then
        local k, v
        for _, d in pairs(items) do
            local p = d.price
            if not p then
                break
            end
            local itemId = d.id or d.sid
            local iCnt = d.cnt or d.amount
            if not bAllBuy and iCnt > 0 then
                local obj = g_QuickGetCtrl:GetQuickGetObj(itemId)
                iCnt = iCnt - obj:GetOwnItemAmount()
            end
            iCnt = math.max(iCnt, 0)
            k = p.money_type
            v = iCnt * p.price
            CQuickGetCostHelp.RecordCost(dCost, k, v)
            if k ~= define.Currency.Type.GoldCoin then
                CQuickGetCostHelp.RecordCost(dDirect, k, v)
            end
        end
    end
    return dCost, dDirect
end

function CQuickGetCostHelp.RecordCost(dRecord, k, v)
    if not k or not v or v <= 0 then return end
    if not dRecord[k] then
        dRecord[k] = 0
    end
    dRecord[k] = dRecord[k] + v
end

function CQuickGetCostHelp.CalcCost(dCost, dDirect)
    local iTotal = 0
    for k, v in pairs(dCost) do
        local iDir = dDirect[k]
        if iDir then
            local iOwn = AttrDict[k]
            if not iOwn then
                iOwn = CQuickGetCostHelp.GetOwnMoney(k)
            end
            if iDir > iOwn then
                v = v - iOwn
                AttrDict[k] = 0
            else
                v = v - iDir
                AttrDict[k] = iOwn - iDir
            end
        end
        iTotal = iTotal + CQuickGetCostHelp.Convert2GoldCoin(k, v)
    end
    return math.floor(iTotal)
end

function CQuickGetCostHelp.GetOwnMoney(iMoneyType)
    if not iMoneyType then
        return 0
    elseif iMoneyType == define.Currency.Type.GoldCoin then
        return g_AttrCtrl:GetGoldCoin()
    end
    local dMoneyInfo = CurrencyInfo[iMoneyType]
    local iKey = dMoneyInfo and dMoneyInfo.key
    local iOwn = iKey and g_AttrCtrl[iKey]
    return iOwn or 0
end

function CQuickGetCostHelp.IsCostEnough(iMoneyType, iCost)
    return CQuickGetCostHelp.GetOwnMoney(iMoneyType) >= iCost
end

function CQuickGetCostHelp.GetCostNameText(currencys, itemIds)
    local sNames = nil
    for _, id in ipairs(itemIds) do
        local dItem = DataTools.GetItemData(id)
        if not sNames then
            sNames = dItem.name
        else
            sNames = string.format("%s和%s", sNames, dItem.name)
        end
    end
    if currencys then
        for _, dMoney in ipairs(currencys) do
            local sName = CurrencyInfo[dMoney.money_type].name
            if not sNames then
                sNames = sName
            else
                sNames = string.format("%s和%s", sNames, sName)
            end
        end
    end
    return sNames
end

function CQuickGetCostHelp.GetCostText(iMoneyType)
    iMoneyType = iMoneyType or define.Currency.Type.GoldCoin
    local dCost = CurrencyInfo[iMoneyType]
    return dCost and dCost.text or ""
end

return CQuickGetCostHelp
local CQuickGetCtrl = class("CQuickGetCtrl", CCtrlBase)

function CQuickGetCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:Reset()
end

function CQuickGetCtrl.Reset(self)
    self.m_IsLackItem = false
    if self.m_ObjDict then
        for _, o in pairs(self.m_ObjDict) do
            o:Destroy()
        end
    end
    self.m_ObjDict = {}
    self.m_QuickBuyDict = {}
end

function CQuickGetCtrl.GetTotalGoldCoinCost(self, items, currencys, bUseBag)
    return CQuickGetCostHelp.CalcTotalCost(items, currencys, bUseBag)
end

function CQuickGetCtrl.GetQuickGetObj(self, itemId)
    local obj = self.m_ObjDict[itemId]
    if not obj then
        obj = CQuickGetPrice.New(itemId)
        self.m_ObjDict[itemId] = obj
    end
    return obj
end

function CQuickGetCtrl.RemoveQuickGetObj(self, itemId)
    local obj = self.m_ObjDict[itemId]
    if obj then
        obj:Destroy()
        self.m_ObjDict[itemId] = nil
    end
end

function CQuickGetCtrl.GetQuickBuyPriceInfo(self, itemId, bOnlyGet)
    local obj = self:GetQuickGetObj(itemId)
    return obj:GetPriceInfo(bOnlyGet)
end

function CQuickGetCtrl.SetQuickBuyState(self, id, bState)
    self.m_QuickBuyDict[id] = bState
end

function CQuickGetCtrl.GetQuickBuyState(self, id)
    return self.m_QuickBuyDict[id] or false
end

function CQuickGetCtrl.HandleItems(self, items)
    local dItemDict = {}
    local itemIds = {}
    if items then
        local bMul = #items > 1
        local askList
        if bMul then
            askList = {}
        end
        for i, v in ipairs(items) do
            local sid = v.id or v.sid
            local obj = self:GetQuickGetObj(sid)
            v.price = obj:GetPriceInfo(bMul)
            dItemDict[sid] = v
            table.insert(itemIds, sid)
            if bMul and not v.price then
                table.insert(askList, sid)
            end
        end
        if askList then
            if #askList > 1 then
                self:AskPriceInfoList(askList)
            elseif #askList == 1 then
                local obj = self:GetQuickGetObj(askList[1])
                obj:GetPriceInfo(false)
            end
        end
    end
    return dItemDict, itemIds
end

--showCb, hideCb, needChangeCb一般不传
function CQuickGetCtrl.CurrLackItemInfo(self, itemlist, coinlist, exchangeCost, exchangeCb, showCb, hideCb, needChangeCb)
    self:CheckLackItemInfo({
        itemlist = itemlist,
        coinlist = coinlist,
        exchangeCost = exchangeCost,
        exchangeCb = exchangeCb,
        showCb = showCb,
        hideCb = hideCb,
        needChangeCb = needChangeCb,
    })
end

-- 新接口，效果同CurrLackItemInfo(参数太冗长，不好拓展)
--[[ args:
itemlist/coinlist: {sid = itemsid, amount= --需要的 }
exchangeCost:1、int(按钮中所需的元宝数)  2、string(按钮文字)
exchangeCb: 兑换回调
showCb
hideCb
needChangeCb
buyAll   全部购买，不使用背包物品
]]--
function CQuickGetCtrl.CheckLackItemInfo(self, args)
    if not args.itemlist or not next(args.itemlist) then
        if args.coinlist and next(args.coinlist) then
            self.m_IsLackItem = self:OnCurrLackCoinInfo(args.coinlist, args.exchangeCb)
        end
        return self.m_IsLackItem
    end
    if args.itemlist and next(args.itemlist) then
        self.m_IsLackItem = true
        CQuickGetItemView:ShowView(function (oView)
            oView:InitAllInfo(args)
            if args.depthType then
                oView.m_DepthType = args.depthType
                g_ViewCtrl:TopView(oView)
            end
        end)
    end
    return self.m_IsLackItem
end

function CQuickGetCtrl.ConvertItem2Currency(self, items)
    return CQuickGetCostHelp.ConvertItem2Currency(items)
end

------------------ View -------------------
function CQuickGetCtrl.OnCurrLackCoinInfo(self, coinlist, exchangeCb)
    local bLack = self:IsLackCoin(coinlist)
    if bLack then
        self:ShowCostExchView(function (oView)
            oView:SetExchangeCallback(exchangeCb)
            oView:InitCoinInfo(coinlist)
        end)
    end
    return bLack
end

function CQuickGetCtrl.IsLackCoin(self, coinlist)
    local bLack = false
    if coinlist then
        for i, v in ipairs(coinlist) do
            if (v.count or 0) < (v.amount or 0) then
                bLack = true
                break
            end
        end
    end
    return bLack
end

--元宝不足显示去充值提示
function CQuickGetCtrl.OnShowNotEnoughGoldCoin(self, oText)
    -- if g_KuafuCtrl:IsInKS() then
    --     return
    -- end
    -- local windowTipInfo = {
    --     msg = oText and oText or "你的元宝不够哦,是否充值",
    --     pivot = enum.UIWidget.Pivot.Center,
    --     okCallback = callback(self, "ShowChargeView"),
    --     cancelCallback = function ()

    --     end,
    --     okStr = "去充值",
    --     cancelStr = "以后再说",
    -- }
    -- g_WindowTipCtrl:SetWindowConfirm(windowTipInfo)
    g_ShopCtrl:ShowChargeComfirm()
end

function CQuickGetCtrl.ShowCostExchView(self, cb)
    if g_KuafuCtrl:IsInKS() then
        return
    end
    CQuickGetCoinView:ShowView(cb)
end

-------------------- Proto ----------------------
function CQuickGetCtrl.AskPriceInfoList(self, itemList)
    local askList = {}
    for _, id in ipairs(itemList) do
        local obj = self:GetQuickGetObj(id)
        local dInfo = obj:GetAskInfo(true)
        if dInfo then
            table.insert(askList, dInfo)
        end
    end
    if #askList > 0 then
        netitem.C2GSFastBuyItemListPrice(askList)
    end
end

function CQuickGetCtrl.C2GSExchangeCash(self, moneytype, goldcoin)
    netopenui.C2GSExchangeCash(moneytype, goldcoin)
end

function CQuickGetCtrl.C2GSExchangeItem(self, itemlist)
    netopenui.C2GSExchangeItem(itemlist)
end

function CQuickGetCtrl.GS2CExchangeMoney(self, moneytype, goldcoin, value)
    local coinlist = {}
    local sid = 1001
    local count = g_AttrCtrl.goldcoin
    if moneytype == 2 then
        sid = 1002
        count = g_AttrCtrl.silver
    end
    local t = {sid = sid, count = count, amount = count+value}
    table.insert(coinlist, t)
    self:ShowCostExchView(function (oView)
        oView:InitCoinInfo(coinlist)
    end)
end

function CQuickGetCtrl.GS2CExchangeItem(self, itemlist)

end

function CQuickGetCtrl.GS2CExecAfterExchange(self, moneytype, goldcoin, moneyvalue, itemlist, sessionidx, exchangemoneyvalue)
    local sid = 1001
    if moneytype == 2 then
        sid = 1002
    end
    local info = {
        moneyId = sid,
        goldcoin = goldcoin,
        moneyvalue = moneyvalue,
        exchangemoneyvalue = exchangemoneyvalue,
        cb = function ()
            netother.C2GSCallback(sessionidx, 1)
        end,
    }
    self:ShowCostExchView(function (oView)
        oView:SetInfo(info)
    end)
end

function CQuickGetCtrl.GS2CFastBuyItemPrice(self, pbdata)
    local itemId = pbdata.sid
    if not itemId then return end
    local obj = self:GetQuickGetObj(itemId)
    pbdata = obj:HandlePriceInfo(pbdata)
    self:OnEvent(define.Item.Event.ReceiveQuickBuyPrice, pbdata)
end

function CQuickGetCtrl.GS2CFastBuyItemListPrice(self, pbdata)
    local handleList = {}
    local itemList = pbdata.item_list
    for i, dPrice in ipairs(itemList) do
        local obj = self:GetQuickGetObj(dPrice.sid)
        table.insert(handleList, obj:HandlePriceInfo(dPrice))
    end
    self:OnEvent(define.Item.Event.ReceiveQuickBuyPriceList, handleList)
end

return CQuickGetCtrl
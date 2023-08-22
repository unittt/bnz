local CScoreShopPart = class("CScoreShopPart", CPageBase)

function CScoreShopPart.ctor(self, cb)
    CPageBase.ctor(self, cb) 
end

function CScoreShopPart.OnInitPage(self)
    self.m_ItemScroll = self:NewUI(1, CScrollView)
    self.m_ItemGrid = self:NewUI(2, CGrid)
    self.m_ItemCellClone = self:NewUI(3, CGoldGoinShopItemBox)
    self.m_ShopItemName = self:NewUI(4, CLabel)
    self.m_TipBtn = self:NewUI(5, CButton)
    self.m_TotalMoneyIcon = self:NewUI(6, CSprite)
    self.m_TotalMoneyCount = self:NewUI(7, CLabel)
    self.m_TotalPriceIcon = self:NewUI(8, CSprite)
    self.m_TotalPriceCount = self:NewUI(9, CLabel)
    self.m_BuyCount = self:NewUI(10, CLabel)
    self.m_AddBtn = self:NewUI(11, CSprite)
    self.m_SubBtn = self:NewUI(12, CSprite)
    self.m_KeyBoard = self:NewUI(13, CSprite)   
    self.m_BuyBtn = self:NewUI(14, CSprite)
    self.m_ShopItemDes = self:NewUI(15, CLabel)
    self.m_TabGrid = self:NewUI(16, CGrid)
    self.m_GridTabBox = self:NewUI(17, CBox)
    self.m_RemainL = self:NewUI(18, CLabel)
    self.m_DescPart = self:NewUI(19, CWidget)
    self.m_PeoplePart = self:NewUI(20, CWidget)
    self.m_AccumulatedScoreBox = self:NewUI(21, CBox)
    self.m_TodayScoreLab = self.m_AccumulatedScoreBox:NewUI(1, CLabel)
    self.m_ScoreTipsLab = self.m_AccumulatedScoreBox:NewUI(2, CLabel)
    self.m_ScoreTipsBtn = self.m_AccumulatedScoreBox:NewUI(3, CButton)

    self.m_ItemCellList = {}

    self.m_ShopItemList = {}
    self.m_Count = 1
    self.m_TotalPrice = 0
    self.m_TotalMoney = 0
    self.m_MaxBuy = nil
    self.m_TargetItemId = -1

    self:InitContent()
end

function CScoreShopPart.InitContent(self)
    self.m_ItemCellClone:SetActive(false)
    self.m_GridTabBox:SetActive(false)
    self:RegisterEvents()
    self:InitShopTabs()
end

function CScoreShopPart.InitShopTabs(self)
    self.m_GridTabBox:SetActive(false)
    self.m_ShopTabInfo = {}
    self.m_TabInfo = g_ShopCtrl:GetScoreShopSys()
    for _, info in ipairs(self.m_TabInfo) do
        if g_OpenSysCtrl:GetOpenSysState(info.sysName) then
            local dOpen = DataTools.GetViewOpenData(info.sysName)
            info.name = dOpen.name
            table.insert(self.m_ShopTabInfo, info)
       end
    end
    for idx, tabInfo in ipairs(self.m_ShopTabInfo) do
        local oTab = self.m_GridTabBox:Clone()
        oTab.nameL = oTab:NewUI(1, CLabel)
        oTab.nameSelL = oTab:NewUI(2, CLabel)
        oTab.nameL:SetText(tabInfo.name)
        oTab.nameSelL:SetText(tabInfo.name)
        oTab:AddUIEvent("click", callback(self, "AskForShopData", tabInfo.id))
        oTab.id = tabInfo.id
        oTab:SetGroup(self.m_TabGrid:GetInstanceID())
        oTab:SetActive(true)
        self.m_TabGrid:AddChild(oTab)
    end
    if not next(self.m_TabInfo) then
        self:RefreshAll()
    end
end

function CScoreShopPart.RegisterEvents(self)
    self.m_AddBtn:AddUIEvent("click",callback(self, "OnClickAddBtn"))
    self.m_SubBtn:AddUIEvent("click",callback(self, "OnClickSubBtn"))
    self.m_BuyBtn:AddUIEvent("click", callback(self, "OnClickBuyBtn"))
    self.m_KeyBoard:AddUIEvent("click",callback(self,"OnKeyBoard"))
    self.m_TipBtn:AddUIEvent("click",callback(self,"OnClickTip"))
    self.m_ScoreTipsBtn:AddUIEvent("click", callback(self, "OnScoreTipBtn"))

    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
    g_ShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnShopCtrlEvent"))
end

function CScoreShopPart.AskForShopData(self, id)
    if id == self.m_CurShopId then
        return
    end
    self.m_CurShopId = id
    self:RefreshPoint(id, nil)
    netshop.C2GSEnterShop(id)
   
    if self.m_SelectItem then
        self.m_SelectItem:ForceSelected(false)
        self.m_SelectItem = nil
    end
    self.m_ItemGrid:HideAllChilds()
    self.m_ShopItemList = {}
    self.m_Count = 1
    self:UpdateItemBoxIdDict()
    self:RefreshItemDes()
    self:RefreshTotalPrice()
    self:RefreshMoney()
    self:ShowDescEmpty()
    
end

function CScoreShopPart.ShowSubShopById(self, id)
    self.CreateShopItems(self, id)
    self:UpdateItemBoxIdDict()
end

function CScoreShopPart.CreateShopItems(self, id)
    self.m_ShopItemList = self:GetShopItemsData(id) or {}
    for k, v in ipairs(self.m_ShopItemList) do
        local oItem = self.m_ItemCellList[k]
        if not oItem then
            oItem = self.m_ItemCellClone:Clone()
            self.m_ItemGrid:AddChild(oItem)
            table.insert(self.m_ItemCellList, oItem)
            oItem:AddUIEvent("click", callback(self, "OnClickShopItem", oItem))
        end
        oItem:SetActive(true)
        oItem:SetData(v)
        if (k==1 and self.m_TargetItemId == -1) or v.item_id == self.m_TargetItemId then
            self.m_TargetItemId = -1
            self.m_SelectItem = oItem
            self:RefreshAll()
            UITools.MoveToTarget(self.m_ItemScroll, oItem)
            oItem:ForceSelected(true)
        end
    end
    if not next(self.m_ShopItemList) then
        self:RefreshAll()
    end
    self.m_ItemGrid:Reposition()
end

function CScoreShopPart.GetItemHandleData(self, info, dConfig)
    local dHandle = table.copy(info)
    local sDiscount
    if dConfig then
        sDiscount = dConfig.discount_icon
    end
    dHandle.discount = sDiscount or ""
    dHandle.virtual_coin = self:GetVirtualInfo(dHandle.money)
    dHandle.limit_cnt = dHandle.limit or 0
    dHandle.remain_cnt = dHandle.dayamount or dHandle.weekamount or dHandle.foreveramount or 0
    dHandle.item_id = info.itemsid
    local discount = info.discount
    if discount and discount > 0 and discount < 100 then
        discount = discount * 0.01
        for k, v in pairs(dHandle.virtual_coin) do
            v.count = math.floor(v.count * discount)
        end
    end
    return dHandle
end

function CScoreShopPart.GetVirtualInfo(self, config)
    local dItemDict = {
        [1] = 1001,
        [2] = 1002,
        [3] = 1003,
        [4] = 1004,
        [6] = 1013,
        [7] = 1014,
        [8] = 1021,
        [9] = 1022,
        [10] = 1025,
        [13] = 1027,
    }
    local dVirtualInfo = {}
    for _, v in ipairs(config) do
        local k = v.moneytype
        local key = dItemDict[k]
        key = key or k
        dVirtualInfo[key] = {id = key, count = v.moneyvalue}
    end
    return dVirtualInfo
end

function CScoreShopPart.GetShopItemConfig(self, iShopId, iGoodId)
    local dConfig = data.scoredata.SHOP[iShopId] or {}
    return dConfig[iGoodId]
end

function CScoreShopPart.GetShopItemsData(self, id)
    local iGrade = g_AttrCtrl.grade
    local dShopData = g_ShopCtrl:GetScoreShopInfo(id)
    local dShopConfig = data.scoredata.SHOP[id]
    if not dShopData then
        return
    end
    local lItems = {}
    for k, v in pairs(dShopData) do
        local dItemConfig = dShopConfig[k]
        local bShow = true
        if not dItemConfig or iGrade < dItemConfig.grade_limit then
            bShow = false
        elseif v.limit > 0 and v.dayamount <= 0 and v.weekamount <= 0 and v.foreveramount <= 0 then
            bShow = false
        end
        if bShow then
            local dHandle = self:GetItemHandleData(v, dItemConfig)
            table.insert(lItems, dHandle)
        end
    end
    table.sort(lItems, function(a, b)
        return a.goodid < b.goodid
    end)
    return lItems
end

function CScoreShopPart.GetMoneyInfo(self, id)
    local dMoneyInfo = DataTools.GetItemData(id, "VIRTUAL")
    return dMoneyInfo
end

function CScoreShopPart.UpdateItemBoxIdDict(self)
    self.m_ItemBoxIdDict = {}
    for idx, item in ipairs(self.m_ShopItemList) do
        local itemId = item.goodid
        self.m_ItemBoxIdDict[itemId] = idx
    end
end

function CScoreShopPart.RefreshAll(self)
    self:RefreshItemDes()
    self:RefreshTotalPrice()
    self:RefreshMoney()
    self:RefreshBuyCount()
end

function CScoreShopPart.RefreshItemDes(self)
    local bHasItem = self.m_SelectItem and true or false
    self.m_DescPart:SetActive(bHasItem)
    self.m_TotalPriceCount:SetActive(bHasItem)
    self.m_PeoplePart:SetActive(not bHasItem)
    if not self.m_SelectItem then return end
    local itemData = self.m_SelectItem.m_Data
    local data = DataTools.GetItemData(itemData.item_id)
    if data then
        self.m_ShopItemName:SetText(data.name)
        if data.introduction and data.description then
            local text = ""
            local sDesc = g_ItemCtrl:GetItemDesc(itemData.item_id)
            if data.equipLevel then 
                text = data.introduction.."\n\n".."等级:"..tostring(data.equipLevel).."\n\n"..sDesc
            else
                ------------商店内的宝图item数据的地图坐标无法查询时用某地代替----------
                if data.id == define.Treasure.Config.Item5 or data.id == define.Treasure.Config.Item4 then
                    local sInfo = "某地"
                    local description = string.format(data.description,sInfo)
                    text = data.introduction.."\n\n"..description
                else
                    text = data.introduction.."\n\n"..sDesc
               end
            end
            self.m_ShopItemDes:SetText(text)
            self:RefreshItemRemain()
        end
    end
end

function CScoreShopPart.RefreshTotalPrice(self)
    if self.m_SelectItem then
        local itemData = self.m_SelectItem.m_Data
        local i = 1
        local moneyInfo = nil
        for k ,v in pairs(itemData.virtual_coin) do 
            moneyInfo = v;
            i = i + 1
            if i > 1 then 
                break;
            end 
        end
        self.m_TotalPrice = moneyInfo.count * self.m_Count
        local dMoney = self:GetMoneyInfo(moneyInfo.id)
        self.m_TotalPriceIcon:SpriteItemShape(dMoney.icon)
        self.m_TotalPriceIcon:SetActive(true)
    else
        self.m_TotalPrice = 0
        self.m_TotalPriceIcon:SetActive(false)
    end
    self.m_TotalPriceCount:SetCommaNum(self.m_TotalPrice)
end

function CScoreShopPart.RefreshMoney(self)
    if not self.m_SelectItem then
        self.m_TotalMoneyIcon:SetActive(false)
        return
    end
    local i = 1
    local moneyInfo = nil
    local itemData = self.m_SelectItem.m_Data
    for k ,v in pairs(itemData.virtual_coin) do 
        moneyInfo = v;
        i = i + 1
        if i > 1 then 
            break;
        end 
    end
    local dMoney = self:GetMoneyInfo(moneyInfo.id)
    self.m_TotalMoneyIcon:SpriteItemShape(dMoney.icon)
    self.m_TotalMoneyIcon:SetActive(true)
    if moneyInfo.id == 1001 then 
        self.m_TotalMoney = g_AttrCtrl.gold
    elseif moneyInfo.id == 1002  then
        self.m_TotalMoney = g_AttrCtrl.silver
    elseif moneyInfo.id == 1003 then 
        self.m_TotalMoney =g_AttrCtrl.goldcoin + g_AttrCtrl.rplgoldcoin
    elseif moneyInfo.id == 1013 then
        self.m_TotalMoney = g_AttrCtrl.wuxun
    elseif moneyInfo.id == 1014 then
        self.m_TotalMoney = g_AttrCtrl.jjcpoint
    elseif moneyInfo.id == 1021 then
        self.m_TotalMoney = g_AttrCtrl.leaderpoint
    elseif moneyInfo.id == 1022 then
        self.m_TotalMoney = g_AttrCtrl.xiayipoint
    elseif moneyInfo.id == 1025 then
        self.m_TotalMoney = g_AttrCtrl.summonpoint
    elseif moneyInfo.id == 1027 then
        self.m_TotalMoney = g_AttrCtrl.chumopoint
    end
    
    self.m_TotalMoney = self.m_TotalMoney or 0
    self.m_TotalMoneyCount:SetCommaNum(self.m_TotalMoney)
end

function CScoreShopPart.RefreshItemRemain(self)
    if self.m_SelectItem then
        local itemData = self.m_SelectItem.m_Data
        if itemData.limit_cnt > 0 then
            -- local iBuyCnt = g_ShopCtrl:GetItemBuyCnt(itemData.id)
            local iRemain = itemData.remain_cnt or 0
            self.m_RemainL:SetText(string.format("[1d8e00]还可以购买：%d个[-]", iRemain))
            --(string.format("[000000]今天购买了[AF302A]%d[-]个，每天限制购买[AF302A]%d[-]个[-]", itemData.limit_cnt - itemData.buy_cnt, itemData.limit_cnt))
            self.m_RemainL:SetActive(true)
            self.m_MaxBuy = math.max(0, iRemain)
        else
            self.m_MaxBuy = nil
            self.m_RemainL:SetActive(false)
        end
    end
end

function CScoreShopPart.RefreshBuyCount(self)
    self.m_BuyCount:SetText(self.m_Count)
end

function CScoreShopPart.ShowDescEmpty(self)
    self.m_RemainL:SetActive(false)
    self.m_ShopItemDes:SetText("")
    self.m_ShopItemName:SetText("")
    self.m_DescPart:SetActive(true)
    self.m_PeoplePart:SetActive(false)
end

function CScoreShopPart.RefreshPoint(self, id, dServerData)
    -- body
    if id then  -- 点击按钮时，客户端先刷新一次; 103 队长积分 104 侠义值
        if id == 103 or id == 104 or id == 106 then
            g_ShopCtrl.m_ShopPointList = {}  -- 点击之后清空数据
            self.m_AccumulatedScoreBox:SetActive(true)
            local info = data.shoppointdata.LIMITPOINT
            local dData        
            for _,v in pairs(info) do
                if id == v.shopid then
                    dData = v
                    break
                end
            end
            for _,tabInfo in ipairs(self.m_ShopTabInfo) do
                if id == tabInfo.id then
                    self.m_TodayScoreLab:SetText("今日获得：0/"..tostring(dData.day_limit)..tabInfo.name)
                    self.m_ScoreTipsLab:SetText(dData.des)
                end
            end
        else
            self.m_AccumulatedScoreBox:SetActive(false)
        end

    elseif dServerData then             -- 收到服务器下行协议，再次刷新；
        if dServerData.moneytype == 8 and self.m_CurShopId == 103 then
            local dData = data.shoppointdata.LIMITPOINT.leaderpoint
            local val = dServerData.dailyrewardamount or 0 
            self.m_TodayScoreLab:SetText("今日获得："..tostring(val) .."/"..tostring(dData.day_limit).."队长积分")
        elseif dServerData.moneytype == 9 and self.m_CurShopId == 104 then
            local dData = data.shoppointdata.LIMITPOINT.xiayipoint
            --侠义值特殊处理，由于dServerData.dailyrewardamount会计算师徒的，所以不使用
            local val = 0--dServerData.dailyrewardamount or 0 
            if g_ShopCtrl.m_ShopPointHashList[dServerData.moneytype] then
                for k,v in pairs(g_ShopCtrl.m_ShopPointHashList[dServerData.moneytype]) do
                    val = val + v.moneyvalue
                end
            end
            self.m_TodayScoreLab:SetText("今日获得："..tostring(val) .."/"..tostring(dData.day_limit).."侠义值")
        elseif dServerData.moneytype == 13 and self.m_CurShopId == 106 then --除魔积分
            local dData = data.shoppointdata.LIMITPOINT.chumopoint
            local val = dServerData.dailyrewardamount or 0
            self.m_TodayScoreLab:SetText(string.format("今日获得: %d/%d除魔值", val, dData.day_limit))
        end
    end
end

function CScoreShopPart.OnScoreTipBtn(self)
    -- body
    CShopPointView:ShowView(function (oView)
        -- body
        oView:SetNpcShowPoint(self.m_CurShopId , g_ShopCtrl.m_ShopPointList)
    end)
end

function CScoreShopPart.SelectNextItem(self, iCurIdx)
    local iNext = iCurIdx
    local iCount = 0
    local function FindNext()
        iNext = iNext + 1
        if iNext > #self.m_ShopItemList then
            iNext = 1
        end
        iCount = iCount + 1
    end
    while iCount < #self.m_ShopItemList - 1 do
        FindNext()
        local oItem = self.m_ItemGrid:GetChild(iNext)
        if oItem and oItem:GetActive() then
            self:OnClickShopItem(oItem)
            oItem:ForceSelected(true)
            self.m_SelectItem = oItem
            return
        end
    end
    self.m_SelectItem = nil
    self:RefreshAll()
end

function CScoreShopPart.OnClickAddBtn(self)
    if not self.m_SelectItem then 
        g_NotifyCtrl:FloatMsg("请选择商品!")
    else 
        local iMax = self.m_MaxBuy or 99
        if self.m_Count < iMax then 
            self.m_Count = self.m_Count + 1
            self:RefreshBuyCount()
            self:RefreshTotalPrice()
        end
        if self.m_Count == iMax then 
            g_NotifyCtrl:FloatMsg("输入范围1~" .. iMax)
        end
    end
end

function CScoreShopPart.OnClickSubBtn(self)
    if not self.m_SelectItem then 
        g_NotifyCtrl:FloatMsg("请选择商品!")
    else
        local iMax = self.m_MaxBuy or 99
        if self.m_Count > 1 then 
            self.m_Count = self.m_Count - 1
            self:RefreshBuyCount()
            self:RefreshTotalPrice()
        else
            g_NotifyCtrl:FloatMsg("输入范围1~" .. iMax)
        end 
    end
end

function CScoreShopPart.OnClickTip(self)
    if not self.m_CurShopId then return end
    local dTipDict = {
        [101] = 10034,
        [102] = 10035,
        [103] = 10036,
        [104] = 10037,
        [105] = 10046,
        [106] = 11006,
    }
    local iTip = dTipDict[self.m_CurShopId]
    if not iTip then return end
    local instructionConfig = data.instructiondata.DESC[iTip]
    if instructionConfig then
        local zContent = {
            title = instructionConfig.title,
            desc = instructionConfig.desc,
        }
        g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
    end
end

function CScoreShopPart.OnKeyBoard(self)
    if not self.m_SelectItem then
        g_NotifyCtrl:FloatMsg("请选择商品!")
        return
    end 
    local keycallback = callback(self, "KeyboardCallback")
    local buycallback = callback(self, "OnClickBuyBtn")
    local iMax = self.m_MaxBuy or 99
    CSmallKeyboardView:ShowView(function (oView)
        oView:SetData(self.m_BuyCount, keycallback, nil, nil, 1, iMax)
    end)
end

function CScoreShopPart.KeyboardCallback(self)
    local oView = CSmallKeyboardView:GetView()
    if oView then
        self.m_Count = oView:GetNumber()
        self:RefreshTotalPrice()
    end
end

function CScoreShopPart.OnClickBuyBtn(self)
    if not self.m_SelectItem then
        g_NotifyCtrl:FloatMsg("请选择商品!")
        return
    end 
    local data = self.m_SelectItem.m_Data

    if self.m_TotalPrice > self.m_TotalMoney then
        local moneyId
        for k, v in pairs(data.virtual_coin) do 
            moneyId = k
            break
        end
        local name = self:GetMoneyInfo(moneyId).name
        g_NotifyCtrl:FloatMsg(name .. "不足!")
        return
    end
    netshop.C2GSBuyGood(self.m_CurShopId, data.goodid, data.money[1].moneytype, self.m_Count)
end

function CScoreShopPart.OnClickShopItem(self, oItem)
    if self.m_SelectItem ~= oItem then
        self.m_SelectItem = oItem
        self.m_Count = 1
    end 
    self:RefreshAll()
end

function CScoreShopPart.OnShopCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Shop.Event.RefreshScoreShopItem then
        local iCurIdx = nil
        local iCurSelId = self.m_SelectItem.m_Data.goodid
        local dInfo = oCtrl.m_EventData.info
        local iShopId = oCtrl.m_EventData.shop
        local itemId = dInfo.goodid
        local itemBoxIdx = self.m_ItemBoxIdDict[itemId]
        if itemBoxIdx then
            local oItem = self.m_ItemGrid:GetChild(itemBoxIdx)
            if not oItem then return end
            local dConfig = self:GetShopItemConfig(iShopId, itemId)
            local dHandle = self:GetItemHandleData(dInfo, dConfig)
            oItem:SetData(dHandle)
            local iLimit = dHandle.remain_cnt or 0
            if iCurSelId == itemId then
                self:RefreshItemRemain()
                if iLimit <= 0 then
                    --买完选中下一个
                    iCurIdx = itemBoxIdx
                    oItem:SetActive(false)
                    oItem:ForceSelected(false)
                end
            end
        end
        if iCurIdx then
            self:SelectNextItem(iCurIdx)
        end
        self.m_ItemGrid:Reposition()
    elseif oCtrl.m_EventID == define.Shop.Event.EnterScoreShop then
        self:ShowSubShopById(oCtrl.m_EventData)
    elseif oCtrl.m_EventID == define.Shop.Event.RefreshShopPoint then
        self:RefreshPoint(nil, oCtrl.m_EventData)
    end
end

function CScoreShopPart.SelectShop(self, idx)
    local oTab = self.m_TabGrid:GetChild(idx)
    if oTab then
        oTab:SetSelected(true)
    end
    local iShopId = oTab.id
    self:AskForShopData(iShopId)
end

function CScoreShopPart.SelectShopById(self, iShopId)
    for i, oTab in ipairs(self.m_TabGrid:GetChildList()) do
        if oTab.id == iShopId then
            oTab:SetSelected(true)
            self:AskForShopData(iShopId)
            return
        end
    end
end

function CScoreShopPart.OnAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
        self:RefreshMoney()
    end
end

function CScoreShopPart.JumpToTargetItem(self, iItemId)
    self.m_TargetItemId = iItemId
end

return CScoreShopPart
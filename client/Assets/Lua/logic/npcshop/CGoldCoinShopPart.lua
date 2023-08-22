local CGoldCoinShopPart =  class("CGoldCoinShopPart", CNpcShopViewBase, CPageBase)

function CGoldCoinShopPart.ctor(self, cb)

	CPageBase.ctor(self, cb)
	
end

function CGoldCoinShopPart.OnInitPage(self)

	CNpcShopViewBase.OnCreateView(self)
    self.m_ItemCellClone = self:NewUI(3, CGoldGoinShopItemBox)
    self.m_TabGrid = self:NewUI(19, CGrid)
    self.m_GridTabBox = self:NewUI(20, CBox)
    self.m_RemainL = self:NewUI(21, CLabel)
    self.m_RemainTimeL = self:NewUI(22, CLabel)
    self.m_DescNode = self:NewUI(23, CWidget)
    self.m_Bubble = self:NewUI(24, CWidget)
    -- self.m_DiscountLbl = self:NewUI(26, CLabel)
    self.m_TipLabel = self:NewUI(27, CLabel)
    self.m_DiscountLbl = self.m_RemainTimeL:Clone()
    self.m_DiscountLbl:SetParent(self.m_RemainTimeL:GetParent())

    self.m_ItemCellClone:SetActive(false)
    self.m_RemainL:SetActive(false)
    self.m_ItemBoxIdDict = {}
    self:InitShopTabs()

    g_ShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnShopCtrlEvent"))

end

function CGoldCoinShopPart.Destroy(self)
    self.m_DiscountLbl:Destroy()
end

function CGoldCoinShopPart.InitShopTabs(self)
    self.m_GridTabBox:SetActive(false)
    self.m_ShopTabInfo = {}
    local lTabInfo = {
        [2] = {id = 302, name = "每周限购", sysName = define.System.StoreSys301},
        [1] = {id = 301, name = "商城", sysName = define.System.StoreSys302},
        [3] = {id = 303, name = "礼包", sysName = define.System.StoreSys303},
        [4] = {id = 304, name = "元宝商城", sysName = define.System.StoreSys304},
    }
    for _, info in ipairs(lTabInfo) do
        if g_OpenSysCtrl:GetOpenSysState(info.sysName) then
            table.insert(self.m_ShopTabInfo, info)
        end
    end
    for idx, tabInfo in ipairs(self.m_ShopTabInfo) do
        local oTab = self.m_GridTabBox:Clone()
        oTab.nameL = oTab:NewUI(1, CLabel)
        oTab.nameSelL = oTab:NewUI(2, CLabel)
        oTab.nameL:SetText(tabInfo.name)
        oTab.nameSelL:SetText(tabInfo.name)
        if string.utfStrlen(tabInfo.name) > 2 then
            oTab.nameL:SetSpacingX(0)
            oTab.nameSelL:SetSpacingX(0)
        end

        --有新商品，显示小红点提示
        local newGoodsList = g_ShopCtrl:GetNewGoodInShop()
        for k, v in pairs(newGoodsList) do
            if tabInfo.id == v.shop_id  then
                oTab:AddEffect("RedDot", 22, Vector2(-15, -17))
                oTab.m_IgnoreCheckEffect = true
                break
            end
        end
        
        oTab:AddUIEvent("click", callback(self, "ShowSubShopById", tabInfo.id))
        oTab:SetGroup(self.m_TabGrid:GetInstanceID())
        oTab:SetActive(true)
        self.m_TabGrid:AddChild(oTab)
        if tabInfo.id == 302 then
            self:ShowSubShopById(tabInfo.id)
            oTab:SetSelected(true)
        end
    end
end

------检查还有没有新商品需要提示--------
function CGoldCoinShopPart.CheckShopRedDot(self)
    
    for idx, tabInfo in ipairs(self.m_ShopTabInfo) do
        local newGoodsList = g_ShopCtrl:GetNewGoodInShop()
        local curShopdata = {} --筛选出当前tab对应的商店的数据
        for k, v in pairs(newGoodsList) do
            if v.shop_id == tabInfo.id then
                curShopdata[k] = v
            end
        end

        if table.count(curShopdata) == 0 then
            local oTab = self.m_TabGrid:GetChild(idx)
            if oTab.m_IgnoreCheckEffect then
                oTab:DelEffect("RedDot")
            end     
        end
    end 

end

function CGoldCoinShopPart.JumpToTargetItem(self, iItemid)
    for i,tabInfo in ipairs(self.m_ShopTabInfo) do
        local dItem = DataTools.GetNpcStoreItemByShopId(tabInfo.id, iItemid)
        if dItem then
            if g_ShopCtrl:GetLeftAmount(dItem) then
                local oTab = self.m_TabGrid:GetChild(i)
                if oTab then
                    oTab:SetSelected(true)
                    self:ShowSubShopById(tabInfo.id)
                end
                return CNpcShopViewBase.JumpToTargetItem(self, iItemid)
            end
        end
    end
	return false
end

function CGoldCoinShopPart.RefreshItemDes(self)
    CNpcShopViewBase.RefreshItemDes(self)
    
    local itemData =  self.m_selectItem.m_Data
    local data = DataTools.GetItemData(itemData.item_id)
    self.m_ShopItemName:SetText(data.name)
    
    self:RefreshItemRemain()
    self.m_DescNode:SetActive(true)
end

function CGoldCoinShopPart.RefreshItemRemain(self)
    if self.m_selectItem then
        local itemData = self.m_selectItem.m_Data
        local iRemainCnt = g_ShopCtrl:GetLeftAmount(itemData)
        if iRemainCnt >= 0 then
            self.m_RemainL:SetText(string.format("还可以购买：%d个", iRemainCnt))
            self.m_RemainL:SetActive(true)
            self.m_MaxBuy = iRemainCnt
        else
            self.m_MaxBuy = nil
            self.m_RemainL:SetActive(false)
        end
    end
end

function CGoldCoinShopPart.ShowSubShopById(self, id)
    if id == self.m_CurShopId then
        return
    end
    self.m_CurShopId = id
    self:RefreshShopUI(id)
end

function CGoldCoinShopPart.RefreshShopUI(self, id)
    if self.m_selectItem then
        self.m_selectItem:ForceSelected(false)
        self.m_selectItem = nil
    end
    self.m_ItemGrid:Clear()
    self.m_shopItemList = {}
    self.m_Count = 1
    self:ReposScrollView()
    CNpcShopViewBase.CreateShopItems(self, id)
    self:UpdateItemBoxIdDict()
    self:UpdateTipLabel()
    if not self.m_selectItem then
        self:ShowNoneItemDesc()
    else
        self.m_Bubble:SetActive(false)
    end
end

function CGoldCoinShopPart.UpdateTipLabel(self)
    local dText = data.textdata.SHOP
    if self.m_CurShopId == 301 then
        local text = dText[1020].content
        self.m_TipLabel:SetText(text)
    else
        local text = dText[1019].content
        self.m_TipLabel:SetText(text)
    end
end

function CGoldCoinShopPart.UpdateItemBoxIdDict(self)
    self.m_ItemBoxIdDict = {}
    for idx, item in ipairs(self.m_shopItemList) do
        local itemId = item.id
        self.m_ItemBoxIdDict[itemId] = idx
    end
end

function CGoldCoinShopPart.ShowNoneItemDesc(self)
    self.m_DescNode:SetActive(false)
    -- self.m_ShopItemName:SetText("[63432cff]" .."在左侧选择需要购买的物品吧!" .. "[-]")
    self.m_Texture:SetActive(true)
    self.m_Bubble:SetActive(true)
    self.m_TotalPriceCount:SetText("")
    self.m_BuyCount:SetText(0)
end

function CGoldCoinShopPart.SelectNextItem(self, iCurIdx)
    local iNext = iCurIdx
    local iCount = 0
    local function FindNext()
        iNext = iNext + 1
        if iNext > #self.m_shopItemList then
            iNext = 1
        end
        iCount = iCount + 1
    end
    while iCount < #self.m_shopItemList - 1 do
        FindNext()
        local oItem = self.m_ItemGrid:GetChild(iNext)
        if oItem and oItem:GetActive() then
            self:OnClickShopItem(oItem)
            oItem:ForceSelected(true)
            self.m_selectItem = oItem
            return
        end
    end
    self:ShowNoneItemDesc()
end

function CGoldCoinShopPart.ReposScrollView(self)
    local sizeX = self.m_ItemScroll:GetSize()
    self.m_ItemScroll:SetRect(-370, -88, sizeX, 488)

    self.m_RemainTimeL:SetActive(self.m_CurShopId == 302)
   

    local discountTime = g_ShopCtrl:GetDiscountEndTime()
    local lefttime = discountTime - g_TimeCtrl:GetTimeS()
    if self.m_CurShopId == 301 and lefttime > 0 then
        self.m_DiscountLbl:SetActive(true)
        local text = data.textdata.ITEM[1056].content
        local cb = function(time)
            if not time or Utils.IsNil(self) then
                return
            end

            local timetext = string.gsub(text, "#time", time)
            self.m_DiscountLbl:SetText("[c][63432C]" .. timetext)
        end

        g_TimeCtrl:StartCountDown(self, lefttime, 4, cb)
    else
        self.m_DiscountLbl:SetActive(false)
    end
    
    -- self.m_ItemScroll:ResetPosition()
end

function CGoldCoinShopPart.OnShopCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Shop.Event.RefreshShopItem then
        local iCurIdx = nil
        local iCurSelId = self.m_selectItem.m_Data.id
        for _, dInfo in ipairs(oCtrl.m_EventData) do
            local itemId = dInfo.item_id
            local itemBoxIdx = self.m_ItemBoxIdDict[itemId]
            if itemBoxIdx then
                local oItem = self.m_ItemGrid:GetChild(itemBoxIdx)
                if not oItem then return end
                local iCnt = dInfo.buy_cnt
                local iLeft = g_ShopCtrl:GetLeftAmount(oItem.m_Data)
                oItem:UpdateRemainCnt(iLeft)
                if iCurSelId == itemId and iLeft >= 0 then
                    self:RefreshItemRemain()
                    if iLeft == 0 then
                        --买完选中下一个
                        iCurIdx = itemBoxIdx
                        oItem:ForceSelected(false)
                    end
                end
            end
        end
        if iCurIdx then
            self:SelectNextItem(iCurIdx)
        end
        self.m_ItemGrid:Reposition()
         --//入袋动画
            
            if not g_ShopCtrl.m_FloatItemList then
                return
            end
            for i=#g_ShopCtrl.m_FloatItemList,1,-1 do
                local v = g_ShopCtrl.m_FloatItemList[i]
                if data.shopdata.NPCSHOP[itemId].item_id == v.itemid then
                    local oView = CNpcShopMainView:GetView()
                    local oItemData = DataTools.GetItemData(v.itemid)
                    if oView then
                        local sPos = g_CameraCtrl:GetUICamera():WorldToScreenPoint(v.pos)
                        if sPos.y >= 250 then
                            g_NotifyCtrl:FloatItemBox(oItemData.icon, nil, v.pos)
                        else --低于一定高度不进行优化  还有高于一定高度呢 o(╯□╰)o
                            g_NotifyCtrl:FloatItemBox(oItemData.icon)
                        end
                    else
                        g_NotifyCtrl:FloatItemBox(oItemData.icon)
                    end
                end
                table.remove(g_ShopCtrl.m_FloatItemList, i)
            end
            --//入袋动画

    elseif oCtrl.m_EventID == define.Shop.Event.RefreshNpcShop then
        self:CheckShopRedDot()
    elseif oCtrl.m_EventID == define.Shop.Event.NpcShopDiscount then
        -- 刷新元宝商城界面 --
        if self.m_CurShopId == 301 then
            self:RefreshShopUI(301)
        end
    end
end

return CGoldCoinShopPart
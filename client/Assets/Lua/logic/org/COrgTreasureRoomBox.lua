local COrgTreasureRoomBox = class("COrgTreasureRoomBox", CBox)

function COrgTreasureRoomBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_CloseBtn                 = self:NewUI(1, CButton)
    self.m_iBtn                     = self:NewUI(2, CButton)
    self.m_RefreshTimeLabel         = self:NewUI(3, CLabel)
    self.m_ReduceCountBtn           = self:NewUI(4, CButton)
    self.m_AddCountBtn              = self:NewUI(5, CButton)
    self.m_CountNumLabel            = self:NewUI(6, CLabel)
    self.m_TotlePriceLabel          = self:NewUI(7, CLabel)
    self.m_OwnNumLabel              = self:NewUI(8, CLabel)
    self.m_AddOwnBtn                = self:NewUI(9, CButton)
    self.m_BuyBtn                   = self:NewUI(10, CButton)
    self.m_ItemClone                = self:NewUI(11, CBox)
    self.m_Grid                     = self:NewUI(12, CGrid)
    self.m_TitleLabel               = self:NewUI(13, CLabel)
    self:InitContent()
end

function COrgTreasureRoomBox.InitContent(self)
    self.m_CloseBtn                 :AddUIEvent("click", callback(self, "OnClickCloseBtn"))
    self.m_iBtn                     :AddUIEvent("click", callback(self, "OnClickIBtn"))
    self.m_ReduceCountBtn           :AddUIEvent("click", callback(self, "OnClickReduceCountBtn"))
    self.m_AddCountBtn              :AddUIEvent("click", callback(self, "OnClickAddCountBtn"))
    self.m_AddOwnBtn                :AddUIEvent("click", callback(self, "OnShowTips"))
    self.m_BuyBtn                   :AddUIEvent("click", callback(self, "OnClickBuyCountBtn")) 
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    self.m_CountNumLabel:SetText(0)
    -- self.m_OwnNumLabel:SetText(g_AttrCtrl.org_offer)
    self:RefreshOwnNumberLabel()
    self.m_TitleLabel:SetText(g_OrgCtrl.m_Buildings[102].level)--"珍宝阁[c][fff9e3]"..g_OrgCtrl.m_Buildings[102].level.."[-][/c]级")
end

function COrgTreasureRoomBox.RefreshOwnNumberLabel(self)
    local iCost = tonumber(self.m_TotlePriceLabel:GetText()) or 0
    if iCost > g_AttrCtrl.org_offer then
        self.m_OwnNumLabel:SetText("[c]#R"..g_AttrCtrl.org_offer.."#n[/c]")
    else
        self.m_OwnNumLabel:SetText(g_AttrCtrl.org_offer)
    end
end

function COrgTreasureRoomBox.SetData(self, level)
    self.m_TitleLabel:SetText(level)
end

function COrgTreasureRoomBox.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
        -- self.m_OwnNumLabel:SetText(g_AttrCtrl.org_offer)
        self:RefreshOwnNumberLabel()
	end	
    if oCtrl.m_EventID == define.Org.Event.BuyItemResult then
        local iItemId = oCtrl.m_EventData and oCtrl.m_EventData.item
        local iCnt = oCtrl.m_EventData and oCtrl.m_EventData.cnt
        self:UpdateItemCount(iItemId, iCnt)
        g_NotifyCtrl:FloatMsg("购买成功！")
        self:FloatItemBox()
    end
    if oCtrl.m_EventID == define.Org.Event.UpdateOrgBuildingInfos then
        self.m_TitleLabel:SetText(g_OrgCtrl.m_Buildings[102].level)
    end
end

function COrgTreasureRoomBox.FloatItemBox(self)
    if g_OrgCtrl.m_FloatItemList  then
        for i=#g_OrgCtrl.m_FloatItemList,1,-1 do
            local v = g_OrgCtrl.m_FloatItemList[i]
            local oItemData = DataTools.GetItemData(v.itemid)
            local spos = g_CameraCtrl:GetUICamera():WorldToScreenPoint(v.pos)
            if spos.y >250 then
                g_NotifyCtrl:FloatItemBox(oItemData.icon, nil, v.pos)
            else
                g_NotifyCtrl:FloatItemBox(oItemData.icon)
            end
            table.remove(g_OrgCtrl.m_FloatItemList, i)
        end
    end
end

function COrgTreasureRoomBox.InitItemGrid(self, info)
    self.m_Grid:Clear()
    self.m_CurItemInfo = {}
    local shopData = data.orgdata.BUILDSHOP
    for k,v in pairs(info) do
        local itemData = DataTools.GetItemData(shopData[v.item_id].item)
        local item = self.m_ItemClone:Clone()
        item:SetActive(true)
        item.icon = item:NewUI(1, CSprite)
        item.name = item:NewUI(2, CLabel)
        item.price = item:NewUI(3, CLabel)
        item.remain = item:NewUI(4, CLabel)
        item.icon:SpriteItemShape(itemData.icon)
        item.name:SetText(itemData.name)
        item.price:SetText(shopData[v.item_id].cost.val)
        item:SetGroup(self.m_Grid:GetInstanceID())
        item.sid = itemData.id
        item.icon:AddUIEvent("click", callback(self,"OnTips", itemData.id, item))
        item:AddUIEvent("click", callback(self,"OnSelectItem", v, item))
        --printc(v.item_id)
        if shopData[v.item_id].sell_num == 0 then 
            --999以上为特殊物品，用服务器数据表示剩余个数
            if v.item_id >=  999 then
                item.remain:SetText(v.buy_cnt)
            else
                item.remain:SetText("无限")
            end
            
        else
            item.remain:SetText(shopData[v.item_id].sell_num - v.buy_cnt)    
        end  
        self.m_Grid:AddChild(item)
        if k == 1 then
            item:SetSelected(true)
            self:OnSelectItem(v, item)
        end
    end
end

function COrgTreasureRoomBox.OnSelectItem(self, v, item)
    self.m_CurItemInfo = {}
    self.m_CurItemInfo.id = v.item_id
    self.m_CurItemInfo.buy_cnt = v.buy_cnt
    self.m_CurItem = item
    self.m_CurItemInfo.price = data.orgdata.BUILDSHOP[v.item_id].cost.val 
    self.m_CurItemInfo.sell_num = data.orgdata.BUILDSHOP[v.item_id].sell_num
    self.m_CountNumLabel:SetText(1)
    --local cont = tonumber(self.m_CountNumLabel:GetText())
    self.m_TotlePriceLabel:SetText(self.m_CurItemInfo.price)
    self:RefreshOwnNumberLabel()
end

function COrgTreasureRoomBox.UpdateItemCount(self, iItemId, iCnt)
    if iItemId == 999 and self.m_CurItem ~= nil then
        printc("return", iCnt)
        self.m_CurItem.remain:SetText(iCnt)
        return
    end
    local cont = tonumber(self.m_CountNumLabel:GetText())
    if self.m_CurItem == nil or self.m_CurItemInfo.sell_num <= 0 then
        return
    end
    local oldcount = tonumber(self.m_CurItem.remain:GetText())
    if oldcount-cont >= 0 then
        self.m_CurItem.remain:SetText(oldcount-cont)
    end
end

function COrgTreasureRoomBox.OnClickCloseBtn(self)
    g_OrgCtrl:CloseBuildingTreasureRoom()
end

function COrgTreasureRoomBox.OnClickBanggoneTreasureRoomBtn(self)
    printc("点击：帮贡珍宝")
end

function COrgTreasureRoomBox.OnClickIBtn(self)
    COrgBuildShopTipsView:ShowView()
end

function COrgTreasureRoomBox.OnClickReduceCountBtn(self)
    if next(self.m_CurItemInfo) == nil then
        g_NotifyCtrl:FloatMsg("请选择商品！")
        return
    end
    local num = tonumber(self.m_CountNumLabel:GetText())
    if num <= 0 then
       return
    end
    num = num - 1
    self.m_CountNumLabel:SetText(tostring(num))
    self.m_TotlePriceLabel:SetText(self.m_CurItemInfo.price*num)
    self:RefreshOwnNumberLabel()
end

function COrgTreasureRoomBox.OnClickAddCountBtn(self)
    if next(self.m_CurItemInfo) == nil then
        g_NotifyCtrl:FloatMsg("请选择商品！")
        return
    end
    local num = tonumber(self.m_CountNumLabel:GetText())
    num = num + 1
    local sell_num =  data.orgdata.BUILDSHOP[self.m_CurItemInfo.id].sell_num
    if sell_num ~= 0 and num > tonumber(self.m_CurItem.remain:GetText()) then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1093].content)
        return
    end
    self.m_CountNumLabel:SetText(tostring(num))
    self.m_TotlePriceLabel:SetText(self.m_CurItemInfo.price*num)
    self:RefreshOwnNumberLabel()
end

function COrgTreasureRoomBox.OnShowTips(self)
    local id = define.Instruction.Config.OrgOffer
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function COrgTreasureRoomBox.OnClickBuyCountBtn(self)
    if next(self.m_CurItemInfo) == nil then
        g_NotifyCtrl:FloatMsg("请选择商品！")
        return
    end
    if tonumber(self.m_CountNumLabel:GetText()) <= 0 then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1094].content)
        return
    end
    if g_AttrCtrl.org_offer < tonumber(self.m_TotlePriceLabel:GetText()) then
        g_NotifyCtrl:FloatMsg("帮贡不足！")
        return
    end
    if self.m_CurItem.remain:GetText() ~= "无限" then
        if tonumber(self.m_CountNumLabel:GetText()) > tonumber(self.m_CurItem.remain:GetText()) then
            g_NotifyCtrl:FloatMsg("商品不足！")
            return
        end
    end
    -- local t = {itemid = self.m_CurItem.sid, pos = self.m_CurItem.icon:GetPos()}
    -- local tb = {}
    -- table.insert(tb, t)
    -- g_ItemCtrl:SetUnneedDoTween(tb)
    -- g_OrgCtrl:SelectItemList(tb)
    g_OrgCtrl:C2GSBuyItem(self.m_CurItemInfo.id, tonumber(self.m_CountNumLabel:GetText()))
end

function COrgTreasureRoomBox.OnTips(self, id, box)
    g_WindowTipCtrl:SetWindowItemTip(id, {widget = box, side = enum.UIAnchor.Side.Top})
end

return COrgTreasureRoomBox
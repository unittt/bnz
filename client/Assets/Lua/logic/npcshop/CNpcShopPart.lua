local CNpcShopPart = class("CNpcShopPart", CPageBase)

function CNpcShopPart.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CNpcShopPart.OnInitPage(self)
	self.m_ItemScroll = self:NewUI(1, CScrollView)
	self.m_ItemGrid = self:NewUI(2, CGrid)
	self.m_ItemCellClone = self:NewUI(3, CBox)
	self.m_SubCountBtn = self:NewUI(4, CButton)
	self.m_CountText = self:NewUI(5, CLabel)
	self.m_AddCountBtn = self:NewUI(6, CButton)
	self.m_MoneySum = self:NewUI(7, CLabel)
	self.m_Money = self:NewUI(8, CLabel)
	self.m_AddMoneyBtn = self:NewUI(9, CButton)
	self.m_BuyBtn = self:NewUI(10, CButton)
	self.m_HintText = self:NewUI(11, CTextList)
	self.m_TextTure = self:NewUI(12, CTexture)
	self.m_MoneySumIcon = self:NewUI(13, CSprite)
	self.m_m_MoneyIcon = self:NewUI(14, CSprite)
	self.m_KeyBoard = self:NewUI(15, CButton)
	self:InitContent()
end

function CNpcShopPart.InitContent(self)
	self.m_ItemCellClone:SetActive(false)
	self.m_AddMoneyBtn:AddUIEvent("click",callback(self,"OnAddMoney"))
	self.m_SubCountBtn:AddUIEvent("click",callback(self,"OnSubCount"))
	self.m_AddCountBtn:AddUIEvent("click",callback(self,"OnAddCount"))
	self.m_KeyBoard:AddUIEvent("click",callback(self,"OnKeyBoard"))
	self.m_BuyBtn:AddUIEvent("click",callback(self,"OnBuy"))
	self.m_Count = tonumber(self.m_CountText:GetText())
	self.m_Money:SetCommaNum(g_AttrCtrl.silver)
	self.m_MoneySum:SetCommaNum("0")
	self.m_CoinType = {
	[1001] = {name = "金币",value = g_AttrCtrl.gold,icon = "10002"},
	[1002] = {name = "银币",value = g_AttrCtrl.silver,icon = "10003"},
	[1003] = {name = "元宝",value = g_AttrCtrl:GetGoldCoin(),icon = "10001"}
	}
	self.CurcoinTypeVal = {[1001] = g_AttrCtrl.gold,[1002] = g_AttrCtrl.silver,[1003] = g_AttrCtrl:GetGoldCoin()}
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshMoney"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self.m_HintText:Clear()
	self.m_HintText:Add("在左侧选择需要购买的物品吧!")
	self:InitGridBox()
end


function CNpcShopPart.RefreshMoney(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self.CurcoinTypeVal = {[1001] = g_AttrCtrl.gold,[1002] = g_AttrCtrl.silver,[1003] = g_AttrCtrl:GetGoldCoin()}
		if self.m_CurCoinId == nil then 
			self.m_CurCoinId = 1001
		end
		self.m_Money:SetCommaNum(self.CurcoinTypeVal[self.m_CurCoinId])
	end
end

function CNpcShopPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.AddTask or oCtrl.m_EventID == define.Task.Event.DelTask then
		self:InitGridBox()
	end
end

function CNpcShopPart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
	or oCtrl.m_EventID == define.Item.Event.ItemAmount then
		self:InitGridBox()
	end
end

function CNpcShopPart.SetItemList(self)
	local list = {}
	for k,v in pairs(g_ShopCtrl:GetNpcShopDic()) do
		table.insert(list, v)
	end
	table.sort(list, function (a, b) return a.id < b.id end)

	local optionCount = #list
	local GridList = self.m_ItemGrid:GetChildList() or {}
	local oItem
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oItem = self.m_ItemCellClone:Clone(false)
			else
				oItem = GridList[i]
			end
			self:SetItemBox(oItem, list[i], i)
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	-- self.m_ItemGrid:Reposition()
	-- self.m_ScrollView:ResetPosition()
end

function CNpcShopPart.SetItemBox(self, oItem, oData, index)
	oItem:SetActive(true)
	oItem:NewUI(1,CLabel):SetText(DataTools.GetItemData(oData.item_id).name)
	local rItemCellIcon = oItem:NewUI(2, CSprite)
	rItemCellIcon:SpriteItemShape(DataTools.GetItemData(oData.item_id).icon)
	rItemCellIcon:AddUIEvent("click",callback(self,"OnTips"))				
	local coinId = 1001
	for k, v in pairs(oData.virtual_coin) do          
	  	oItem:NewUI(3,CLabel):SetCommaNum(v.count)	
	  	oItem:NewUI(4,CSprite):SetSpriteName(self.m_CoinType[k].icon)
	  	coinId = k	
	end
    if g_TaskCtrl:GetIsTaskNeedItem(oData.item_id) then
    	oItem:NewUI(5,CSprite):SetActive(true)
    else
    	oItem:NewUI(5,CSprite):SetActive(false)
    end
	oItem:AddUIEvent("click",callback(self,"OnItemCellClick", oData.id, coinId))
	oItem:SetActive(true)
	self.m_ItemGrid:AddChild(oItem)
	oItem:SetGroup(self.m_ItemGrid:GetInstanceID())

	if CTaskHelp.GetClickTaskShopSelect() then
		--CTaskHelp.GetClickTaskShopSelect():GetSValueByKey("needitem")[1]
		local needitem = g_TaskCtrl:GetTaskNeedItemList(CTaskHelp.GetClickTaskShopSelect(), true)[1]
		if needitem and oData.item_id == needitem then
			-- printc("选中商店item")
			local _,h = self.m_ItemGrid:GetCellSize()
            local scrollPos = Vector3.New(0, (math.ceil(index/2)-2) * h, 0)
            if index % 2 == 0 then
            	scrollPos = Vector3.New(0, (math.ceil(index/2)-1) * h, 0)
            else
            	scrollPos = Vector3.New(0, (math.ceil(index/2)-2) * h, 0)
            end
            self.m_ItemScroll:MoveRelative(scrollPos)
			self:ShowShopItemContent(oData.id, coinId)
			oItem:ForceSelected(true)
			CTaskHelp.SetClickTaskShopSelect(nil)
		end			
	end
end

function CNpcShopPart.InitGridBox(self)
	self:SetItemList()	
end

function CNpcShopPart.OnTips(self)

end

function CNpcShopPart.OnItemCellClick(self, id, coinId)
	self:ShowShopItemContent(id, coinId)
	-- local view = CSmallKeyboardView:GetView()
	-- if view then 
	-- 	view:OnClose()
	-- end 
end

function CNpcShopPart.ShowShopItemContent(self, id, coinId)
	if id == self.m_CurshopId then
		return
	end
	if self.m_CurshopId == nil then
		self.m_TextTure:SetActive(false)
	end

	local npcStoreInfo = g_ShopCtrl:GetNpcShopDic()[id]
	if not npcStoreInfo then
		return
	end

	self.m_CurshopId = id
	self.m_CurCoinId = coinId
	self.m_Count = 1
	
	self.m_MoneySum:SetCommaNum(self.m_Count * npcStoreInfo.virtual_coin[self.m_CurCoinId].count)
	self.m_CountText:SetText(self.m_Count)
	self.m_MoneySumIcon:SetSpriteName(self.m_CoinType[coinId].icon)
	self.m_m_MoneyIcon:SetSpriteName(self.m_CoinType[coinId].icon)
	self.m_Money:SetCommaNum(self.CurcoinTypeVal[self.m_CurCoinId])
	local desc = g_ItemCtrl:GetItemDesc(npcStoreInfo.item_id)
	local text = DataTools.GetItemData(npcStoreInfo.item_id).introduction.."\n\n"..desc
	self.m_HintText:Clear()
	self.m_HintText:Add(text)
	self.m_HintText:Add("                                                                                                                    ") 
	self.m_HintText:SetScrollValue(0)
end


function CNpcShopPart.OnSubCount(self)
	if nil == self.m_CurshopId then
	g_NotifyCtrl:FloatMsg("请选择商品!")
	return
	end
	if tonumber(self.m_Count) == nil or math.floor(self.m_Count) < self.m_Count then
		return
	end

	if self.m_Count-1 < 1 then
		return
	end	
	self.m_Count = self.m_Count-1
	self.m_CountText:SetText(self.m_Count)
	local npcStoreInfo = g_ShopCtrl:GetNpcShopDic()[self.m_CurshopId]
	self.m_MoneySum:SetCommaNum(self.m_Count * npcStoreInfo.virtual_coin[self.m_CurCoinId].count)
end

function CNpcShopPart.KeyboardCallback(self, oView, isHint)
	self.m_Count = oView:GetNumber()--tonumber(self.m_CountText:GetText())
	local npcStoreInfo = g_ShopCtrl:GetNpcShopDic()[self.m_CurshopId]
	self.m_MoneySum:SetCommaNum(self.m_Count * npcStoreInfo.virtual_coin[self.m_CurCoinId].count)
	if isHint then
		g_NotifyCtrl:FloatMsg("最多购买99个道具")
	end
end

function CNpcShopPart.OnKeyBoard(self)
	if nil == self.m_CurshopId then
		g_NotifyCtrl:FloatMsg("请选择商品!")
		return
	end
	local function keycallback(oView)
		self:KeyboardCallback(oView)
	end
	local function buycallback()
		self:OnBuy()
	end	
	CSmallKeyboardView:ShowView(function (oView)
		oView:SetData(self.m_CountText, keycallback, nil, nil, 1, 99)
	end)
end

function CNpcShopPart.OnAddCount(self)	
	if nil == self.m_CurshopId then
	g_NotifyCtrl:FloatMsg("请选择商品!")
	return
	end
	if  tonumber(self.m_Count) == nil or math.floor(self.m_Count) < self.m_Count then
		return
	end	
	if self.m_Count + 1 > 99999 then --默认不超过99999		
		return
	end	
    self.m_Count = self.m_Count + 1
    self.m_CountText:SetText(self.m_Count)
	local npcStoreInfo = g_ShopCtrl:GetNpcShopDic()[self.m_CurshopId]
    self.m_MoneySum:SetCommaNum(self.m_Count * npcStoreInfo.virtual_coin[self.m_CurCoinId].count)
end

function CNpcShopPart.OnAddMoney(self)
	self.m_ParentView:ShowSpecificPart(2)
end

function CNpcShopPart.OnBuy(self)
	if nil == self.m_CurshopId then
		g_NotifyCtrl:FloatMsg("请选择商品!")
		return
	end	
	local npcStoreInfo = g_ShopCtrl:GetNpcShopDic()[self.m_CurshopId]
	if npcStoreInfo.virtual_coin[self.m_CurCoinId].count * self.m_Count > self.CurcoinTypeVal[self.m_CurCoinId] then
		g_NotifyCtrl:FloatMsg(self.m_CoinType[self.m_CurCoinId].name .. "不足!")
		return
	end
	netstore.C2GSNpcStoreBuy(self.m_CurshopId,self.m_Count)
end


return CNpcShopPart
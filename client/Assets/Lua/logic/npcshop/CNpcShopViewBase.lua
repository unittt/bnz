local CNpcShopViewBase = class("CNpcShopViewBase", CObject)

--货币icon的映射
CNpcShopViewBase.CoinType = {
	[1001] = 10002,
	[1002] = 10003,
	[1003] = 10001,
}

CNpcShopViewBase.TitleStyle = {
	[201] = "h7_zhuangbeidian",
	[202] = "h7_wuqidian",
	[203] = "h7_yaodian",
	[204] = "h7_zahuodian",
}

function CNpcShopViewBase.OnCreateView(self)
	
	self.m_ItemScroll = self:NewUI(1, CScrollView)
	self.m_ItemGrid = self:NewUI(2, CGrid)
	self.m_ItemCellClone = self:NewUI(3, CNpcShopItemBox)
	self.m_ShopItemName = self:NewUI(4, CLabel)
	self.m_Texture = self:NewUI(5, CTexture)
	self.m_TotalMoneyIcon = self:NewUI(6, CSprite)
	self.m_TotalMoneyCount = self:NewUI(7, CLabel)
	self.m_TotalPriceIcon = self:NewUI(8, CSprite)
	self.m_TotalPriceCount = self:NewUI(9, CLabel)
	self.m_BuyCount = self:NewUI(10, CLabel)

	self.m_AddBtn = self:NewUI(11, CSprite)
	self.m_SubBtn = self:NewUI(12, CSprite)
	self.m_KeyBoard = self:NewUI(13, CSprite)	
	self.m_Close = self:NewUI(14, CSprite)
	self.m_BuyBtn = self:NewUI(15, CSprite)
	self.m_ShopItemDes = self:NewUI(16, CLabel)
	self.m_TitleSpr = self:NewUI(17, CSprite)
	self.m_AddMoneyBtn = self:NewUI(18, CSprite)


	if table.count(self.m_GameObjects) > 18 then
		self.m_TotalMoneyBDCount = self:NewUI(28, CLabel)
		self.m_AddMoneyBDBtn = self:NewUI(29, CSprite)
		self.m_TotalMoneyBDIcon = self:NewUI(30, CSprite)
	end

	g_GuideCtrl:AddGuideUI("npcshop_close_btn", self.m_Close)
	g_GuideCtrl:AddGuideUI("npcshop_buy_btn", self.m_BuyBtn)

	self.m_Count = 1

	self.m_TotalPrice = 0
	self.m_TotalMoney = 0
	self.m_MaxBuy = nil	 --限制购买数量
	self.m_DelayTimer = nil
	self.m_shopItemList = {}

	--主要为了购买足够的任务物品，关闭商店界面
	self.m_ClickTaskShopSelect = nil

	self.m_BuyCount:SetText(self.m_Count)
	self.m_ShopItemName:SetText("[63432cff]" .."在左侧选择需要购买的物品吧!" .. "[-]")
	self.m_ShopItemDes:SetActive(false)

	self.m_AddBtn:AddUIEvent("click",callback(self, "OnClickAddBtn"))
	self.m_SubBtn:AddUIEvent("click",callback(self, "OnClickSubBtn"))
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnClickBuyBtn"))
	self.m_KeyBoard:AddUIEvent("click",callback(self,"OnKeyBoard"))
	--self.m_TotalMoneyCount:AddUIEvent("click", callback(self, "OnClickIngot"))
	self.m_AddMoneyBtn:AddUIEvent("click", callback(self, "OnClickAddMoney"))

	--self.m_TotalMoneyBDCount:AddUIEvent("click", callback(self, "OnClickIngot"))
	if self.m_AddMoneyBDBtn then
		self.m_AddMoneyBDBtn:AddUIEvent("click", callback(self, "OnClickAddMoney"))
	end

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_ShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpdateItemEvent"))

end


--创建商店所有物品
function CNpcShopViewBase.CreateShopItems(self, shopId)
	local iGrade = g_AttrCtrl.grade
	local goodList = g_ShopCtrl:GetCurLevelShopData()
	for k , v in pairs(goodList) do 
		if v.shop_id ~= nil and v.shop_id == shopId then
			local bShow = true
			if iGrade < v.limit_level then
				bShow = false
			elseif g_ShopCtrl:GetLeftAmount(v) == 0 then
				bShow = false
			end
			if bShow then
				table.insert(self.m_shopItemList, v)
			end
		end 
	end
	table.sort(self.m_shopItemList, function (a, b)
		if a.sort and b.sort and a.sort ~= b.sort then
			return a.sort < b.sort
		end
		return a.id < b.id
	end)
	for k, v in ipairs(self.m_shopItemList) do 
		local oItem = self.m_ItemGrid:GetChild(k)
		if not oItem then
			oItem = self.m_ItemCellClone:Clone()
			self.m_ItemGrid:AddChild(oItem)
	 		oItem:AddUIEvent("click",callback(self,"OnClickShopItem", oItem))
	 	end
	 	oItem:SetActive(true)
		oItem:SetData(v)
	 	--默认选择第一行第一个
	 	if k == 1 then
	 		if 	self.m_selectItem ~= oItem then
	 			self.m_selectItem = oItem
	 			self:RefrehAll()
	 			UITools.MoveToTarget(self.m_ItemScroll, oItem)
				oItem:ForceSelected(true)
			end
	 	end
	end
	self.m_ItemGrid:Reposition()
	self:CheckTask()
	self:RefreshTitle(shopId)
end


function CNpcShopViewBase.OnTaskEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.AddTask or oCtrl.m_EventID == define.Task.Event.DelTask then
		self:RefreshNeedIcon()
	end
end

function CNpcShopViewBase.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
	or oCtrl.m_EventID == define.Item.Event.ItemAmount then
		self:RefreshNeedIcon()
	end
end

function CNpcShopViewBase.CheckTask(self)
	
	if CTaskHelp.GetClickTaskShopSelect() then 
		self.m_ClickTaskShopSelect = {}
		table.copy(CTaskHelp.GetClickTaskShopSelect(), self.m_ClickTaskShopSelect)
		local taskNeedList = g_TaskCtrl:GetTaskNeedItemList(CTaskHelp.GetClickTaskShopSelect(), true)
		if taskNeedList then 
			local needitem = taskNeedList[1]
			self:JumpToTargetItem(needitem)
		end 
	end 

end

--
function CNpcShopViewBase.JumpToTargetItem(self, iItemId)
	iItemId = DataTools.GetPartnerCellItem(iItemId) or iItemId
	for k, v in pairs(self.m_shopItemList) do
		if iItemId and v.item_id == iItemId then
			local oItem = self.m_ItemGrid:GetChild(k)
			if oItem then 
				if g_TaskCtrl:GetIsTaskNeedItem(v.item_id) then
					oItem:ActiveNeedIcon(true)
				else
					oItem:ActiveNeedIcon(false)
				end		
				self:OnClickShopItem(oItem)
				UITools.MoveToTarget(self.m_ItemScroll, oItem)
				oItem:ForceSelected(true)
			end 
			return true
		end
	end	
	return false
end

function CNpcShopViewBase.OnClickShopItem(self, oItem)
	if self.m_selectItem ~= oItem then
		self.m_selectItem = oItem
		self.m_Count = 1
	end 

	--点击商品后若有新品提示则隐藏提示,并刷新已查看过商品的记录
	if oItem.m_newTip:GetActive() then

		local id = tostring(oItem.m_Data.id)
		local oldGoodList = g_ShopCtrl:GetShopDataRecord()
		oldGoodList[id] = true
		IOTools.SetRoleData("shopdataRecord", oldGoodList)
		oItem.m_newTip:SetActive(false)
		
		g_ShopCtrl:OnEvent(define.Shop.Event.RefreshNpcShop)

	end
	
	self:RefrehAll()
end

function CNpcShopViewBase.RefrehAll(self)
	
	self:RefreshItemDes()
	self:RefreshTotalPrice()
	self:RefreshMoney()
	self:RefreshBuyCount()

end

function CNpcShopViewBase.RefreshTitle(self, shopId)
	local sSprName = CNpcShopViewBase.TitleStyle[shopId]
	if sSprName then
		self.m_TitleSpr:SetSpriteName(sSprName)
	end
end

function CNpcShopViewBase.RefreshNeedIcon(self)

	for k, v in pairs(self.m_shopItemList) do
		local oItem = self.m_ItemGrid:GetChild(k)
		if oItem then 
			if g_TaskCtrl:GetIsTaskNeedItem(v.item_id) then
				oItem:ActiveNeedIcon(true)
			else
				oItem:ActiveNeedIcon(false)
			end
		end 
	end	

end

--刷新物品描述和名称
function CNpcShopViewBase.RefreshItemDes(self)

	local  itemData =  self.m_selectItem.m_Data
	local data = DataTools.GetItemData(itemData.item_id)
	if data ~= nil then
		if data.name ~= nil then 
			self.m_ShopItemName:SetText("[244b4eff]" ..data.name .. "[-]")
		end 
		if data.introduction ~= nil and data.description ~= nil then 
			local text = ""
			local sDesc = g_ItemCtrl:GetItemDesc(itemData.item_id)
			if data.equipLevel then 
				text = data.introduction.. "\n\n".."等级:" .. tostring(data.equipLevel).."\n\n"..sDesc
			else
				text = data.introduction.."\n\n"..sDesc
			end 
			self.m_ShopItemDes:SetText(text)
		end 
	end 
	self.m_Texture:SetActive(false)
	self.m_ShopItemDes:SetActive(true)

end

--刷新总价
function CNpcShopViewBase.RefreshTotalPrice(self)
	
	local itemData = self.m_selectItem.m_Data
	local i = 1
	local moneyInfo = nil
	local discount = itemData.limittime_discount
	for k ,v in pairs(itemData.virtual_coin) do 
		moneyInfo = v;
		i = i + 1
		if i > 1 then 
			break;
		end 
	end
	--限时打折显示折后价--
	local dPrice = g_ShopCtrl:GetDiscountPrice(moneyInfo.count, discount)
	self.m_TotalPrice = dPrice * self.m_Count
	if itemData.shop_id == 301 then
		self.m_TotalPriceIcon:SetSpriteName(10221)
	else
		self.m_TotalPriceIcon:SetSpriteName(CNpcShopViewBase.CoinType[moneyInfo.id])
	end
	self.m_TotalPriceIcon:SetActive(true)
	self.m_TotalPriceCount:SetCommaNum(self.m_TotalPrice)
end

function CNpcShopViewBase.OnCtrlEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshMoney()
	end

end


--刷新玩家拥有的货币
function CNpcShopViewBase.RefreshMoney(self)
	if not self.m_selectItem then
		return
	end
	local i = 1
	local moneyInfo = nil
	local itemData = self.m_selectItem.m_Data
	for k ,v in pairs(itemData.virtual_coin) do 
		moneyInfo = v;
		i = i + 1
		if i > 1 then 
			break;
		end 
	end

	if moneyInfo.id == 1001 then 
		self.m_TotalMoney = g_AttrCtrl.gold
	elseif moneyInfo.id == 1002  then 
		self.m_TotalMoney = g_AttrCtrl.silver
	elseif moneyInfo.id == 1003 then
		if itemData.shop_id == 301 then
			self.m_TotalMoney = g_AttrCtrl.goldcoin + g_AttrCtrl.rplgoldcoin
		else
			self.m_TotalMoney = g_AttrCtrl.goldcoin
		end
	end

	if self.m_TotalMoneyIcon then
		if moneyInfo.id == 1002 then --药店
			self.m_TotalMoneyIcon:SetSpriteName(CNpcShopViewBase.CoinType[moneyInfo.id])
			self.m_TotalMoneyCount:SetCommaNum(self.m_TotalMoney)
		else --商城
			self.m_TotalMoneyIcon:SetSpriteName(10001)
			self.m_TotalMoneyCount:SetCommaNum(g_AttrCtrl.goldcoin)
		end
		self.m_TotalMoneyIcon:SetActive(true)
	end
	if self.m_TotalMoneyBDIcon then
		self.m_TotalMoneyBDIcon:SetSpriteName(10221)
		self.m_TotalMoneyBDIcon:SetActive(true)
		self.m_TotalMoneyBDCount:SetCommaNum(g_AttrCtrl.rplgoldcoin)
	end
end

--刷新购买数量
function CNpcShopViewBase.RefreshBuyCount(self)
	
	self.m_BuyCount:SetText(self.m_Count)

end

function CNpcShopViewBase.OnClickAddBtn(self)

	if self.m_selectItem == nil then 
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

function CNpcShopViewBase.OnClickSubBtn(self)
	
	if self.m_selectItem == nil then 
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

function CNpcShopViewBase.OnClickIngot(self)
	g_NotifyCtrl:ShowClickIngot(self.m_TotalMoneyCount)
end

function CNpcShopViewBase.OnClickAddMoney(self)
	local i = 1
	local moneyInfo = nil
	local data = self.m_selectItem.m_Data
	for k ,v in pairs(data.virtual_coin) do 
		moneyInfo = v;
		i = i + 1
		if i > 1 then 
			break;
		end 
	end

	printerror("AAAAAAAAAAAAAAAAA", moneyInfo)
	table.print(moneyInfo)

	local moneyType = 0
	if moneyInfo.id == 1001 then
		moneyType = define.Currency.Type.Gold
	elseif moneyInfo.id == 1002 then
		moneyType = define.Currency.Type.Silver
	elseif moneyInfo.id == 1003 or moneyInfo.id == 1004 then
		moneyType = define.Currency.Type.GoldCoin
	end

	g_ShopCtrl:ShowAddMoney(moneyType)
end

function CNpcShopViewBase.OnKeyBoard(self)

	if self.m_selectItem == nil then
		g_NotifyCtrl:FloatMsg("请选择商品!")
		return
	end	
	local function keycallback(oView)
		self:KeyboardCallback(oView)
	end
	local function buycallback()
		self:OnClickBuyBtn()
	end	
	local iMax = self.m_MaxBuy or 99
	CSmallKeyboardView:ShowView(function (oView)
		oView:SetData(self.m_BuyCount, keycallback, nil, nil, 1, iMax)
	end)
end

function CNpcShopViewBase.KeyboardCallback(self, oView, isHint)
	self.m_Count = oView:GetNumber()
	self:RefreshTotalPrice()
	printc(self.m_Count)
	if isHint then
		g_NotifyCtrl:FloatMsg("最多购买99个道具")
	end
end

function CNpcShopViewBase.OnClickBuyBtn(self)
	
	if self.m_selectItem == nil then
		g_NotifyCtrl:FloatMsg("请选择商品!")
		return
	end	
	local data = self.m_selectItem.m_Data
	if self.m_TotalPrice > self.m_TotalMoney then

		local coinlist = {}
		for i,v in pairs(data.virtual_coin)	 do
			local t = {sid=i, count = self.m_TotalMoney, amount = self.m_TotalPrice}
			table.insert(coinlist, t)
		end	
		g_QuickGetCtrl:CurrLackItemInfo({}, coinlist)
		-- local i = 1
		-- local moneyInfo = nil
		-- for k ,v in pairs(data.virtual_coin) do 
		-- 	moneyInfo = v;
		-- 	i = i + 1
		-- 	if i > 1 then 
		-- 		break;
		-- 	end 
		-- end

		-- local name = ""
		-- if moneyInfo.id == 1001  then 
		-- 	name = "金币"
		-- elseif moneyInfo.id == 1002  then 
		-- 	name = "银币"
		-- elseif moneyInfo.id == 1003  then 
		-- 	name = "元宝"
		-- end 
		-- g_NotifyCtrl:FloatMsg(name .. "不足!")
		return
	end
	-- 
	-- local tb = {}
	-- table.insert(tb, {itemid = data.item_id, pos = self.m_selectItem.m_Icon:GetPos() } )
	-- g_ItemCtrl:SetUnneedDoTween(tb)
	-- g_ShopCtrl:SelectItemList(tb)
	netstore.C2GSNpcStoreBuy(data.id, self.m_Count, self.m_TotalPrice)

end

function CNpcShopViewBase.OnUpdateItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Shop.Event.RefreshShopItem then
		--购买时都是单个物品，个人感觉没必要遍历一个list
		for _,v in pairs(oCtrl.m_EventData) do
			if not g_ShopCtrl.m_FloatItemList then
				return
			end
			for i=#g_ShopCtrl.m_FloatItemList,1,-1 do
				local  k = g_ShopCtrl.m_FloatItemList[i]
				if data.shopdata.NPCSHOP[v.item_id].item_id ==  k.itemid then
					local oView = nil
					local shopId  =  data.shopdata.NPCSHOP[v.item_id].shop_id
					local oItemData = DataTools.GetItemData(k.itemid)

					if shopId == 201 then
						oView = CNpcEquipShopView:GetView()
					elseif shopId == 202 then
						oView = CNpcWeaponShopView:GetView()
					elseif shopId == 203 then
						oView = CNpcMedicineShopView:GetView()
					elseif shopId == 204 then
						oView = CNpcGroceryShopView:GetView()
					end
					
					if oView then
						local sPos = g_CameraCtrl:GetUICamera():WorldToScreenPoint(k.pos)
						if sPos.y >= 250 then
							g_NotifyCtrl:FloatItemBox(oItemData.icon, nil, k.pos)
						else --低于一定高度不进行优化  还有高于一定高度呢 o(╯□╰)o
							g_NotifyCtrl:FloatItemBox(oItemData.icon)
						end
				    else
				    	g_NotifyCtrl:FloatItemBox(oItemData.icon)
				    end
				end
				table.remove( g_ShopCtrl.m_FloatItemList, i)
			end
		end
	end
end

function CNpcShopViewBase.OnHideView(self)
	--暂时屏蔽
    -- g_TaskCtrl.m_HelpOtherTaskData = {}
    -- g_TaskCtrl.m_OpenShopForTaskSessionidx = nil
end

return CNpcShopViewBase
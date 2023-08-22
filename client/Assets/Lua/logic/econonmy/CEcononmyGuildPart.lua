local CEcononmyGuildPart = class("CEcononmyGuildPart", CPageBase)

function CEcononmyGuildPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CEcononmyGuildPart.OnInitPage(self)
	self.m_CatalogListBox = self:NewUI(1, CEcononmyCatalogListBoxNew)
	self.m_CurrencyBox = self:NewUI(2, CCurrencyBox)
	self.m_CostBox = self:NewUI(3, CCurrencyBox)
	self.m_GuildItemListBox = self:NewUI(4, CEcononmyGuildItemListBox)
	self.m_BuyBtn = self:NewUI(5, CButton)
	self.m_AmountBox = self:NewUI(6, CAmountSettingBox)
	self.m_BagItemListBox = self:NewUI(7, CEcononmyBagItemListBox)

	self.m_IsLoadDone = false
	self.m_SelectedItemId = -1
	self.m_Cost = 0
	self.m_Price = 0
	self.m_Amount = 0
	self:InitContent()
end

function CEcononmyGuildPart.InitContent(self)
	self.m_BagItemListBox:SetEcononmyType(define.Econonmy.Type.Guild)
	self.m_GuildItemListBox:SetClickCallback(callback(self, "OnItemChange"))
	self.m_BuyBtn:AddUIEvent("click", callback(self, "RequestBuy"))

	self.m_CurrencyBox:SetCurrencyType(define.Currency.Type.Gold)
	self.m_CostBox:SetCurrencyType(define.Currency.Type.Gold, true)
	self.m_AmountBox:SetCallback(callback(self, "OnAmountChange"))

	g_EcononmyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:InitCatalogListBox()
	self:RefreshCost()
end

function CEcononmyGuildPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Econonmy.Event.RefreshGuildItemList then
		self:RefreshGuildItemListBox()
	elseif oCtrl.m_EventID == define.Econonmy.Event.RefreshGuildItem then
		local dInfo = oCtrl.m_EventData
		self.m_GuildItemListBox:UpdateGuildItemByGoodId(dInfo.good_id, dInfo)
		if self.m_SelectedItemId == dInfo.good_id then
			self.m_Price = dInfo.price
			local iAmount = self.m_Amount 
			self:RefreshAmountBox(dInfo.amount, dInfo.has_buy, dInfo.good_id)
			if self.m_AmountBox.m_MaxValue < iAmount then
				self.m_AmountBox:SetValue(self.m_AmountBox.m_MaxValue)
			end
		end
	end
end

function CEcononmyGuildPart.FloatItemBox(self, dInfo)
	if g_EcononmyCtrl.m_FloatItemList then
		local oItemData =  DataTools.GetItemData(dInfo.sid)
		local oView = CEcononmyMainView:GetView()
		for i = #g_EcononmyCtrl.m_FloatItemList,1,-1 do
			local v = g_EcononmyCtrl.m_FloatItemList[i]
			if oView then --高度待商榷
				if g_CameraCtrl:GetUICamera():WorldToScreenPoint(v.pos).y>250 then
					g_NotifyCtrl:FloatItemBox(oItemData.icon,nil,v.pos)
				else
					g_NotifyCtrl:FloatItemBox(oItemData.icon)
				end
			else
				g_NotifyCtrl:FloatItemBox(oItemData.icon)
			end
			table.remove(g_EcononmyCtrl.m_FloatItemList, i)
		end
	end
end

function CEcononmyGuildPart.InitCatalogListBox(self)
	self.m_CatalogListBox:SetCatalogCallback(callback(self, "OnCatalogChange"), callback(self, "OnSubCatalogChange"))
	self.m_CatalogListBox:SetCatalogData(data.guilddata.CATALOG, define.Econonmy.Type.Guild)
end

function CEcononmyGuildPart.LoadDone(self)
	self.m_IsLoadDone = true
	if g_EcononmyCtrl:HasTaskItem(define.Econonmy.Type.Guild) then 
		local iCatalogId = g_EcononmyCtrl:GetTargetTaskCatalog(define.Econonmy.Type.Guild)
		local iIndex = DataTools.GetEcononmyGuildCatalogIndex(iCatalogId)
		self.m_CatalogListBox:JumpToCatalog(iIndex)
	else
		self.m_CatalogListBox:JumpToCatalog(1, 1)
	end
end

function CEcononmyGuildPart.JumpToTargetCatalog(self, iCatalogId, iSubCatalogId)
	local iIndex = DataTools.GetEcononmyGuildCatalogIndex(iCatalogId)
	self.m_CatalogListBox:JumpToCatalog(iIndex, iSubCatalogId)
end

function CEcononmyGuildPart.GetCurrentCatalog(self)
	return self.m_CatalogId, self.m_SubCatalogId
end

function CEcononmyGuildPart.GetDayBuyLimitText(self, iGoodId, iBuyCnt)
	local dGuildData = data.guilddata.ITEMINFO[iGoodId]
	local dItemData = DataTools.GetItemData(dGuildData.item_sid)
	if dGuildData.day_buy_limit > 0 then
		local iQuaity = g_ItemCtrl:GetQualityVal(dItemData.id, dItemData.quality or 0)
		local sItemName = string.format(data.colorinfodata.ITEM[iQuaity].color, dItemData.name) 
		local iLeftCnt = dGuildData.day_buy_limit - iBuyCnt
		if iLeftCnt == 0 then
			local sText = data.guilddata.TEXT[1015].content
			sText = string.gsub(sText, "#amount", iBuyCnt)
			sText = string.gsub(sText, "#item", sItemName)
			return sText
		else
			local sText = data.guilddata.TEXT[1013].content
			sText = string.gsub(sText, "#amount", iLeftCnt)
			sText = string.gsub(sText, "#item", sItemName)
			return sText
		end
	end
end
---------------------------UI refresh------------------------------------
function CEcononmyGuildPart.RefreshCost(self)
	self.m_Cost = self.m_Price * self.m_Amount
	self.m_CostBox:SetCurrencyCount(self.m_Cost)
	self.m_CurrencyBox:SetWarningValue(self.m_Cost)
end

function CEcononmyGuildPart.RefreshGuildItemListBox(self)
	self.m_GuildItemListBox:SetCatalog(self.m_CatalogId, self.m_SubCatalogId)
	self.m_GuildItemListBox:RefreshAll()
end

function CEcononmyGuildPart.RefreshAmountBox(self, iGoodAmount, iBuyCnt, iGoodId)
	local dData = data.guilddata.ITEMINFO[iGoodId]
	local iMaxAmount = math.min(iGoodAmount, 99)
	local iMinAmount = 1
	self.m_AmountBox:SetWarningMsg(nil, nil)
	if dData.day_buy_limit > 0 then
		iMaxAmount = math.min(iMaxAmount, dData.day_buy_limit - iBuyCnt)
		local sWarningMsg = self:GetDayBuyLimitText(iGoodId, iBuyCnt)
		if iMaxAmount == 0 then
			self.m_AmountBox:SetWarningMsg(sWarningMsg, sWarningMsg)
		else
			self.m_AmountBox:SetWarningMsg(nil, sWarningMsg)
		end
	end
	iMinAmount = math.min(iMinAmount, iMaxAmount)
	self.m_AmountBox:SetAmountRange(iMinAmount, iMaxAmount)
	self.m_AmountBox:SetValue(iMinAmount)
end

----------------------------UI click or event--------------------------------
function CEcononmyGuildPart.OnCatalogChange(self, oBox)
	self.m_CatalogId = oBox.m_CatalogId
	local list = DataTools.GetEcononmySubCatalogListById(self.m_CatalogId, define.Econonmy.Type.Guild, g_AttrCtrl.server_grade)
	-- table.print(list)
	if #list == 0 then
		self.m_SubCatalogId = 0
		--TODO:向服务器请求商品信息
		netguild.C2GSOpenGuild(self.m_CatalogId, 0)
		-- self:RefreshSubCatalogListBox(list)
		self:RefreshGuildItemListBox()
	end
	self.m_CatalogListBox:HideOther(oBox)
end

function CEcononmyGuildPart.OnSubCatalogChange(self, oBox)
	self.m_SubCatalogId = oBox.m_Id
	-- TODO:向服务器请求商品信息
	netguild.C2GSOpenGuild(self.m_CatalogId, self.m_SubCatalogId)
	self:RefreshGuildItemListBox()
end

function CEcononmyGuildPart.OnItemChange(self, oBox)
	self.m_ItemBox = oBox
	self.m_SelectedItemId = oBox.m_GoodId
	self.m_Price = oBox.m_Price
	self.m_Amount = 1
	self:RefreshAmountBox(oBox.m_Amount, oBox.m_BuyCnt, oBox.m_GoodId)
	self:RefreshCost()
end

function CEcononmyGuildPart.RequestBuy(self)
	--TODO:请求购买商品
	if self.m_SelectedItemId == -1 then
		return
	end
	local iAmount = self.m_AmountBox:GetValue()
	if iAmount == 0 then
		local sWarning = self:GetDayBuyLimitText(self.m_SelectedItemId, self.m_ItemBox.m_BuyCnt)
		if sWarning then
			g_NotifyCtrl:FloatMsg(sWarning)
			return
		end
		g_NotifyCtrl:FloatMsg("数量不能为0")
		return
	end
	self:JudgeLackList()
	if g_QuickGetCtrl.m_IsLackItem then
		return
	end
	netguild.C2GSBuyGuildItem(self.m_SelectedItemId, iAmount)
end

function CEcononmyGuildPart.OnAmountChange(self, iAmount)
	self.m_Amount = iAmount
	self:RefreshCost()
end

function CEcononmyGuildPart.JudgeLackList(self)
	local coinlist = {}
	if self.m_Cost > g_AttrCtrl.gold then
		local t = {sid = 1001, count = g_AttrCtrl.gold , amount = self.m_Cost}
		table.insert(coinlist, t)
	end
	local iAmount = self.m_AmountBox:GetValue()

	g_QuickGetCtrl:CurrLackItemInfo({}, coinlist, nil, function ()
		-- body
		netguild.C2GSBuyGuildItem(self.m_SelectedItemId, iAmount)
	end)
end

return CEcononmyGuildPart
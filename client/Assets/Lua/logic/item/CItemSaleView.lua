local CItemSaleView = class("CItemSaleView", CViewBase)

function CItemSaleView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemSaleView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_ExtendClose = "Black"
end

function CItemSaleView.OnCreateView(self)
	self.m_BgSpr = self:NewUI(1, CSprite)
	self.m_ItemIconSpr = self:NewUI(2, CSprite)
	self.m_QualitySpr = self:NewUI(3, CSprite)
	self.m_NameL = self:NewUI(4, CLabel)
	self.m_IntroductionL = self:NewUI(5, CLabel)
	self.m_DescLabelClone = self:NewUI(6, CLabel)
	self.m_DescTable = self:NewUI(7, CTable)
	self.m_SaleBtn = self:NewUI(8, CButton)
	self.m_AmountL = self:NewUI(9, CLabel)
	self.m_AmountBox = self:NewUI(10, CAmountSettingBox)
	self.m_PriceL = self:NewUI(11, CLabel)
	self.m_TotalPriceL = self:NewUI(12, CLabel)
	self.m_CloseBtn = self:NewUI(13, CButton)
	self.m_PriceIconSp = self:NewUI(14, CSprite)

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnTouchOutDetect"))

	self.m_Price = 0
	self:InitContent()
end

function CItemSaleView.OnTouchOutDetect(self)
	if CSmallKeyboardView:GetView() == nil then
    	self:CloseView()
    end
end

function CItemSaleView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SaleBtn:AddUIEvent("click", callback(self, "OnClickSale"))
	self.m_AmountBox:SetCallback(callback(self, "OnValueChange"))
end

function CItemSaleView.SetItemInfo(self, oItem)
	self.m_Item = oItem
	self.m_GoodId = data.guilddata.ITEM2GOOD[oItem:GetCValueByKey("id")][1]
	netguild.C2GSGetGuildPrice(self.m_GoodId)
	self:RefreshAll()
	self.m_PriceIconSp:SetSpriteName("10002")
end

function CItemSaleView.SetNotGuildItemInfo(self, oItem)
	self.m_NotGuildItem = true
	self.m_Item = oItem
	self:SetPrice()
	self:RefreshAll()
	self.m_PriceIconSp:SetSpriteName("10003")
end

function CItemSaleView.SetPrice(self, iPrice)
	if self.m_NotGuildItem then
		self.m_Price = self.m_Item:GetCValueByKey("salePrice")
	else
		self.m_Price = iPrice
		local iBuyPrice = self.m_Item:GetSValueByKey("guild_buy_price")
		if iBuyPrice and iBuyPrice > 0 then
			self.m_Price = math.min(iPrice, iBuyPrice)
		end
	end
	self:RefreshPriceLabel()
	self:RefreshTotalPriceLabel()
end

function CItemSaleView.RefreshAll(self)
	self:RefreshItemBasePanel()
	self:RefreshPriceLabel()
	self:RefreshTotalPriceLabel()
end

function CItemSaleView.RefreshItemBasePanel(self)
	local icon = self.m_Item:GetCValueByKey("icon")
	self.m_ItemIconSpr:SpriteItemShape(icon)
	local quality = self.m_Item:GetQuality()
	local textName = string.format(data.colorinfodata.ITEM[quality].color, self.m_Item:GetItemName())
	self.m_NameL:SetText(textName)
	self.m_IntroductionL:SetText(self.m_Item:GetCValueByKey("introduction"))
	self.m_QualitySpr:SetItemQuality(quality)

	local iAmount = self.m_Item:GetSValueByKey("amount")
	self.m_AmountBox:SetAmountRange(1, iAmount)
	self.m_AmountBox:SetValue(iAmount)
	self.m_AmountL:SetText(iAmount)

	self:CreateItemDesc()
end

function CItemSaleView.CreateItemDesc(self)
	local tableList = self.m_DescTable:GetChildList()

	local function createDes(index, des)
		local oLabel = nil
		if index > #tableList then
			oLabel = self.m_DescLabelClone:Clone()
			self.m_DescTable:AddChild(oLabel)
		else	
			oLabel = tableList[index]
		end
		--对一些description进行特殊处理，如根据宝图item数据设置地图坐标描述
		local function SetLabel(sText)
			local itemsid = self.m_Item:GetSValueByKey("sid")
			if itemsid == define.Treasure.Config.Item5 or itemsid == define.Treasure.Config.Item4 then
				local treasureInfo = g_ItemViewCtrl:GetTreasureInfo(self.m_Item)
				local sInfo = DataTools.GetSceneNameByMapId(treasureInfo.treasure_mapid)
				oLabel:SetText(string.format(sText,sInfo))
			else
				oLabel:SetText(sText)
			end
		end
		SetLabel(des)
		-- oLabel:SetText(des)
		oLabel:SetActive(true)
	end

	local description = self.m_Item:GetCValueByKey("description")
	if type(description) == "table" then
		for i,v in ipairs(description) do
			createDes(v)
		end
	elseif type(description) == "string" then
		createDes(1, description)
	end
end

function CItemSaleView.RefreshPriceLabel(self)
	self.m_PriceL:SetText(self.m_Price)
end

function CItemSaleView.RefreshTotalPriceLabel(self)
	if self.m_NotGuildItem then
		local iAmount = self.m_AmountBox:GetValue()
		local iIncome = math.floor(iAmount*self.m_Price)
		self.m_TotalPriceL:SetText(iIncome)
	else
		local dGuidItem = DataTools.GetEcononmyGuildItem(self.m_Item:GetCValueByKey("id"))
		local iTax = dGuidItem.tax
		local iAmount = self.m_AmountBox:GetValue()
		local iIncome = math.floor(iAmount*(100-iTax)/100*self.m_Price)
		self.m_TotalPriceL:SetText(iIncome)
	end
end

function CItemSaleView.OnClickSale(self)
	if self.m_Item:IsBinding() then
		g_NotifyCtrl:FloatMsg("绑定道具无法出售")
		self:CloseView()
		return
	end
	if self.m_NotGuildItem then
		local iAmount = self.m_AmountBox:GetValue()
		netitem.C2GSRecycleItem(self.m_Item:GetSValueByKey("id"), iAmount)
		self:CloseView()
	else
		if not self.m_Item:IsTreasureItem() then
			self:RequestSale()
			return
		end
		local windowConfirmInfo = {
			msg = "你选中的出售物品中属于珍稀物品，是否确认出售",
			okCallback = function () 
				self:RequestSale()
			end,	
			cancelCallback = function ()
				self:CloseView()
			end,
			pivot = enum.UIWidget.Pivot.Center,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	end
end

function CItemSaleView.RequestSale(self)
	local iAmount = self.m_AmountBox:GetValue()
	netguild.C2GSSellGuildItem(self.m_Item.m_ID, iAmount)
	self:CloseView()
end

function CItemSaleView.OnValueChange(self, iValue)
	self:RefreshTotalPriceLabel()
end

return CItemSaleView
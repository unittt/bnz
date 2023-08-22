local CEcononmyStallItemListBox = class("CEcononmyStallItemListBox", CBox)

function CEcononmyStallItemListBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_CallBack = cb

	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_StallItemClone = self:NewUI(2, CBox)

	self.m_ItemBoxs = {}	
	self:InitContent()
end

function CEcononmyStallItemListBox.InitContent(self)
	self.m_StallItemClone:SetActive(false)
end

function CEcononmyStallItemListBox.InitItemList(self)
	self.m_ItemList = g_EcononmyCtrl:GetStallItemList()
end

function CEcononmyStallItemListBox.SetCallback(self, cb)
	self.m_CallBack = cb
end

function CEcononmyStallItemListBox.RefreshAll(self)
	self:InitItemList()
	self:RefreshItemGrid()
end

function CEcononmyStallItemListBox.RefreshItemGrid(self)
	for i = 1, 8 do
		local oBox = self.m_ItemBoxs[i]
		if not oBox then
			oBox = self:CreateGuildItem()
			self.m_ItemBoxs[i] = oBox
			self.m_ItemGrid:AddChild(oBox)
		end
		oBox:SetActive(false)
	end
	for i,dInfo in ipairs(self.m_ItemList) do
		local dInfo = self.m_ItemList[i]
		if not dInfo then
			break
		end
		local oBox = self.m_ItemBoxs[i]
		self:UpdateGuildItem(oBox, dInfo, i)
	end
	self.m_ItemGrid:Reposition()
end

function CEcononmyStallItemListBox.CreateGuildItem(self)
	local oBox = self.m_StallItemClone:Clone()
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_IconSpr = oBox:NewUI(2, CSprite)
	oBox.m_CurrencySpr = oBox:NewUI(3, CSprite)
	oBox.m_PriceL = oBox:NewUI(4, CLabel)
	oBox.m_AmountL = oBox:NewUI(5, CLabel)
	
	local func = function()
		if self.m_CallBack then
			self.m_CallBack(oBox)
		end
	end
	oBox:AddUIEvent("click", func)
	return oBox
end

function CEcononmyStallItemListBox.UpdateGuildItem(self, oBox, dInfo, iPos)
	oBox:SetActive(true)
	local dItemData = DataTools.GetItemData(dInfo.sid)
	if not dItemData then
		oBox:SetActive(false)
		return
	end
	oBox.m_Pos = iPos
	oBox.m_Sid = dInfo.sid
	oBox.m_Amount = dInfo.amount
	local sPriceColor = "#I"
	if dInfo.up_flag < 0 then
		sPriceColor = "#R"
	end
	oBox.m_NameL:SetText(dItemData.name)
	oBox.m_IconSpr:SpriteItemShape(dItemData.icon)
	oBox.m_CurrencySpr:SpriteCurrency(define.Currency.Type.Gold)
	oBox.m_PriceL:SetText(string.format("%s%d#n", sPriceColor, dInfo.price))
	if dInfo.amount == 0 then
		oBox.m_AmountL:SetText("售罄")
	else
		oBox.m_AmountL:SetText("数量:"..dInfo.amount)
	end
end

function CEcononmyStallItemListBox.UpdateGuildItemBySid(self, sid, dInfo)
	local list = self.m_ItemGrid:GetChildList()
	for _,oBox in ipairs(list) do
		if oBox.m_Sid == sid then
			self:UpdateGuildItem(oBox, dInfo)
			break
		end
	end
end

return CEcononmyStallItemListBox
local CNpcShopItemBox = class("CNpcShopItemBox", CBox)

function CNpcShopItemBox.ctor(self, obj)

	CBox.ctor(self, obj)

	self.m_Name = self:NewUI(1, CLabel)
	self.m_Icon = self:NewUI(2, CSprite)
	self.m_MoneyBox = self:NewUI(3, CBox)
	self.m_MoneyGrid = self:NewUI(4, CGrid)
	self.m_NeedIcon = self:NewUI(5, CSprite)
	self.m_QualitySpr = self:NewUI(6, CSprite)
	self.m_SelectName = self:NewUI(7, CLabel)
	self.m_newTip = self:NewUI(10, CSprite)

	self.m_newTip:SetActive(false)
	self.m_MoneyBox:SetActive(false)

end

function CNpcShopItemBox.SetData(self, shopItemData)

	self.m_Data = shopItemData
	
	local item = DataTools.GetItemData(shopItemData.item_id)

	if item ~= nil then 
		self.m_Name:SetText(item.name)
		self.m_SelectName:SetText(item.name)
		self.m_Icon:SpriteItemShape(item.icon)
		if DataTools.GetItemData(item.id, "EQUIP") == nil then
			self.m_QualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( item.id, item.quality or 0 ))
		end	
	end 

	for k, v in pairs(shopItemData.virtual_coin) do 

		local oBox = self:CloneMoneyBox()
		self:RefreshMoneyBox(oBox, v)
		oBox:SetActive(true)
		self.m_MoneyGrid:AddChild(oBox)

	end 

end

function CNpcShopItemBox.ActiveNeedIcon(self, isActive)
	
	self.m_NeedIcon:SetActive(isActive)

end

function CNpcShopItemBox.CloneMoneyBox(self)
	
	local oBox = self.m_MoneyBox:Clone()
	oBox.m_MoneyCount = oBox:NewUI(1, CLabel)
	oBox.m_MoneyIcon = oBox:NewUI(2, CSprite)

	return oBox

end

function CNpcShopItemBox.RefreshMoneyBox(self, oBox, moneyData)
	
	oBox.m_MoneyCount:SetCommaNum(moneyData.count)
	oBox.m_MoneyIcon:SetSpriteName(CNpcShopViewBase.CoinType[moneyData.id])

end

return CNpcShopItemBox
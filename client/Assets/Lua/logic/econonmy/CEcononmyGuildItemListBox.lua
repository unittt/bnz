local CEcononmyGuildItemListBox = class("CEcononmyGuildItemListBox", CBox)

function CEcononmyGuildItemListBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_CallBack = cb

	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_ScrollAreaW = self:NewUI(2, CWidget)
	self.m_ItemGrid = self:NewUI(3, CGrid)
	self.m_GuildItemClone = self:NewUI(4, CBox)

	self.m_CatalogId = 1
	self.m_SubCatalogId = 1

	self:InitContent()
end

function CEcononmyGuildItemListBox.InitContent(self)
	self.m_GuildItemClone:SetActive(false)
	-- self.m_PreBtn:AddUIEvent("click", callback(self, "OnPageChange", -1))
	-- self.m_NextBtn:AddUIEvent("click", callback(self, "OnPageChange", 1))
end

function CEcononmyGuildItemListBox.SetCatalog(self, iCatId, iSubCatId)
	self.m_CatalogId = iCatId
	self.m_SubCatalogId = iSubCatId
end

function CEcononmyGuildItemListBox.InitItemList(self)
	self.m_ItemList = g_EcononmyCtrl:GetGuildItemList(self.m_CatalogId, self.m_SubCatalogId)
end

function CEcononmyGuildItemListBox.SetClickCallback(self, cb)
	self.m_CallBack = cb
end

function CEcononmyGuildItemListBox.SetActive(self, b)
	CBox.SetActive(self, b)
	self:OnPageChange(0)
end

function CEcononmyGuildItemListBox.RefreshAll(self)
	self:InitItemList()
	self:RefreshItemGrid()
end

function CEcononmyGuildItemListBox.RefreshItemGrid(self)
	self.m_ItemGrid:Clear()
	local bHasTaskItem = g_EcononmyCtrl:HasTaskItem(define.Econonmy.Type.Guild)
	local bIsInit = true
	local oTargetBox = nil
	for i = 1, #self.m_ItemList do
		local dInfo = self.m_ItemList[i]
		if not dInfo then
			break
		end
		local oBox = self:CreateGuildItem()
		self:UpdateGuildItem(oBox, dInfo)
		self.m_ItemGrid:AddChild(oBox)
		if g_EcononmyCtrl.m_TargetGuildItem and g_EcononmyCtrl.m_TargetGuildItem == dInfo.sid then
			self:OnClickGuildItemBox(oBox)
			bIsInit = false
			oTargetBox = oBox
			g_EcononmyCtrl:ClearTargetItem()
		elseif bHasTaskItem then 
			if oBox.m_IsTargetTaskItem and bIsInit then
				-- oBox:SetSelected(true)
				self:OnClickGuildItemBox(oBox)
				oTargetBox = oBox
				bIsInit = false
			end
		elseif i == 1 then
			-- oBox:SetSelected(true)
			self:OnClickGuildItemBox(oBox)
		end
	end
	self.m_ItemGrid:Reposition()
	self.m_ScrollView:ResetPosition()
	if oTargetBox then
		UITools.MoveToTarget(self.m_ScrollView, oTargetBox)
	end
end

function CEcononmyGuildItemListBox.CreateGuildItem(self)
	local oBox = self.m_GuildItemClone:Clone()
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_IconSpr = oBox:NewUI(2, CSprite)
	oBox.m_CurrencySpr = oBox:NewUI(3, CSprite)
	oBox.m_PriceL = oBox:NewUI(4, CLabel)
	oBox.m_AmountL = oBox:NewUI(5, CLabel)
	oBox.m_TaskSpr = oBox:NewUI(6, CSprite)
	oBox.m_PriceChangeL = oBox:NewUI(7, CLabel)
	oBox.m_StatusSpr = oBox:NewUI(8, CSprite)
	oBox.m_SelNameL = oBox:NewUI(9, CLabel)
	oBox.m_ItemBtn = oBox:NewUI(10, CSprite)
	oBox.m_EquipFlagSpr = oBox:NewUI(11, CSprite)
	oBox.m_QualitySpr = oBox:NewUI(12, CSprite)

	oBox:SetActive(true)
	local showItemTips = function()
		-- g_WindowTipCtrl:SetWindowGainItemTip(oBox.m_Sid)
		g_WindowTipCtrl:SetWindowItemTip(oBox.m_Sid,
			{widget = oBox.m_ItemBtn, side = enum.UIAnchor.Side.Right,offset = Vector2.New(10, 50)})
	end
	oBox:AddUIEvent("click", callback(self, "OnClickGuildItemBox"))
	oBox:AddUIEvent("dragstart", self.m_DragStartCb)
	oBox:AddUIEvent("drag", self.m_DragCb)
	oBox:AddUIEvent("dragend", self.m_DragEndCb)
	oBox.m_ItemBtn:AddUIEvent("click", showItemTips)
	return oBox
end

function CEcononmyGuildItemListBox.UpdateGuildItem(self, oBox, dInfo)
	local dItemData = DataTools.GetItemData(dInfo.sid)
	if not dItemData then
		oBox:SetActive(false)
		return
	end
	oBox.m_GoodId = dInfo.good_id
	oBox.m_Sid = dInfo.sid
	oBox.m_Amount = dInfo.amount
	oBox.m_Price = dInfo.price
	oBox.m_BuyCnt = dInfo.has_buy or 0
	oBox.m_IsTaskItem, oBox.m_IsTargetTaskItem = g_EcononmyCtrl:IsTaskItem(define.Econonmy.Type.Guild, dInfo.sid)

	local sPriceColor
	local iAdjust = dInfo.up_flag <= 0 and 0 or 0.005
	local sChange = string.format("%.2f",dInfo.up_flag*100/(dInfo.price - dInfo.up_flag) - iAdjust)--tostring(dInfo.up_flag) 

	local iUpValue = tonumber(sChange)
	if iUpValue < 0 then
		sPriceColor = "#R"
		oBox.m_StatusSpr:SetSpriteName("h7_jiang")
		sChange = sChange.."%"
	elseif iUpValue == 0 or dInfo.up_flag == 0 then
		sPriceColor = "#F"
		sChange = "--"
	else 
		sPriceColor = "#I"
		oBox.m_StatusSpr:SetSpriteName("h7_sheng")
		sChange = sChange.."%"
	end
	oBox.m_StatusSpr:SetActive(iUpValue ~= 0)
	oBox.m_NameL:SetText(dItemData.name)
	oBox.m_SelNameL:SetText(dItemData.name)
	oBox.m_IconSpr:SpriteItemShape(dItemData.icon)
	oBox.m_QualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dItemData.id, dItemData.quality or 0 ))
	oBox.m_CurrencySpr:SpriteCurrency(define.Currency.Type.Gold)
	oBox.m_PriceL:SetCommaNum(dInfo.price)
	oBox.m_TaskSpr:SetActive(oBox.m_IsTaskItem)
	oBox.m_PriceChangeL:SetText(string.format("%s%s#n", sPriceColor, sChange))
	if dInfo.amount == 0 then
		oBox.m_AmountL:SetText("售罄")
	else
		oBox.m_AmountL:SetText(dInfo.amount)
	end
	local dEquipbook = DataTools.GetItemData(dInfo.sid, "EQUIPBOOK")
	oBox.m_EquipFlagSpr:SetActive(dEquipbook and dEquipbook.sex == g_AttrCtrl.sex and dEquipbook.school == g_AttrCtrl.school)
end

function CEcononmyGuildItemListBox.UpdateGuildItemByGoodId(self, iGoodId, dInfo)
	local list = self.m_ItemGrid:GetChildList()
	for _,oBox in ipairs(list) do
		if oBox.m_GoodId == iGoodId then
			self:UpdateGuildItem(oBox, dInfo)
			break
		end
	end
end

function CEcononmyGuildItemListBox.OnClickGuildItemBox(self, oBox)
	oBox:SetSelected(true)
	if self.m_CallBack then
		self.m_CallBack(oBox)
	end
end

return CEcononmyGuildItemListBox
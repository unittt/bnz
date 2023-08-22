local CItemDecomposeBox = class("CItemDecomposeBox", CBox)

function CItemDecomposeBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_BagItemScroll = self:NewUI(1, CScrollView)
	self.m_BagItemGrid = self:NewUI(2, CGrid)
	self.m_BagItemClone = self:NewUI(3, CItemBaseBox)
	self.m_DeComposeBox = self:NewUI(4, CItemDecomposeResultBox)
	self.m_AmountBox = self:NewUI(5, CAmountSettingBox)

	self.m_BagItemBoxs = {}
	self.m_SelectedId = -1
	self.m_ScrollToTargetItem = false
	self:InitContent()
end

function CItemDecomposeBox.InitContent(self)
	self.m_BagItemClone:SetActive(false)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self.m_AmountBox:SetCallback(callback(self, "OnValueChange"))

	self:RefreshBagItemGrid()
end

function CItemDecomposeBox.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.DelItem then
		self.m_DeComposeBox:DelDecomposeItem(oCtrl.m_EventData, true)
		self:UpdateBagItemBoxByItem(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self.m_DeComposeBox:DelDecomposeItem(oCtrl.m_EventData.m_ID, false)
		if oCtrl.m_EventData:IsDeComposeEnable() then
			self:UpdateBagItemBoxByItem(oCtrl.m_EventData.m_ID)
		end
	elseif oCtrl.m_EventID == define.Item.Event.AddBagItem then
		if oCtrl.m_EventData:IsDeComposeEnable() then
			self:UpdateBagItemBoxByItem(oCtrl.m_EventData.m_ID, true)
		end
	end
end

function CItemDecomposeBox.ChangeSelectId(self, iItemId)
	if not iItemId then
		return
	end
	self.m_SelectedId = iItemId
	self.m_ScrollToTargetItem = true
	self:RefreshBagItemGrid()
end

function CItemDecomposeBox.ResetAllBagItem(self)
	for i,oBox in ipairs(self.m_BagItemBoxs) do
		oBox:SetActive(false)
	end
end

function CItemDecomposeBox.RefreshBagItemGrid(self)
	local tItemList = g_ItemCtrl:GetDeComposeItemList()
	self:ResetAllBagItem()
	local iUnlockCount = g_ItemCtrl:GetBagOpenCount()
	local oSelBox = nil
	local iSelIndex = 1

	for i=1, iUnlockCount do
		local oItem = tItemList[i]
		local oBox = self.m_BagItemBoxs[i]
		if not oBox then
			oBox = self:CreateBagItemBox() 
			self.m_BagItemGrid:AddChild(oBox)
			self.m_BagItemBoxs[i] = oBox
		end
		self:UpdateBagItemBox(oBox, oItem)
		if oItem and self.m_SelectedId == oItem.m_ID then
			self:OnClickBagItem(oBox)
			oSelBox = oBox
			iSelIndex = i
		end
	end

	self.m_BagItemGrid:Reposition()
	if oSelBox and self.m_ScrollToTargetItem and iSelIndex > 20 then
		UITools.MoveToTarget(self.m_BagItemScroll, oSelBox)
	end
	self.m_ScrollToTargetItem = false
end

function CItemDecomposeBox.CreateBagItemBox(self)
	local oBox = self.m_BagItemClone:Clone()
	oBox.m_DelSpr = oBox:NewUI(6, CSprite)
	oBox:SetClickCallback(callback(self, "OnClickBagItem"))
	return oBox
end

function CItemDecomposeBox.UpdateBagItemBox(self, oBox, oItem)
	local bIsSelected = oItem and self.m_DeComposeBox:IsSelected(oItem.m_ID)
	oBox.m_DelSpr:SetActive((oItem and bIsSelected))
	oBox:ShowEquipLevel(true)
	oBox:SetBagItem(oItem)
	oBox:SetActive(true)
	oBox:SetEnableTouch(true)
end

function CItemDecomposeBox.UpdateBagItemBoxByItem(self, iItemId, bAdd)
	local iInsertIndex = 0
	for i,oBox in ipairs(self.m_BagItemBoxs) do
		if not oBox.m_Item and iInsertIndex == 0 then
			iInsertIndex = i
		end
		if oBox.m_Item and oBox.m_Item.m_ID == iItemId then
			bAdd = false
			self:UpdateBagItemBox(oBox, g_ItemCtrl.m_BagItems[iItemId])
			break
		end
	end
	if bAdd and iInsertIndex > 0 then
		local oBox = self.m_BagItemBoxs[iInsertIndex]
		self:UpdateBagItemBox(oBox, g_ItemCtrl.m_BagItems[iItemId])
	end
end

function CItemDecomposeBox.RefreshAmountBox(self)
	if self.m_SelectedId == -1 then
		self.m_AmountBox:SetValue(0)
		return
	end
	local iAmount = self.m_SelectedItem:GetSValueByKey("amount")
	if iAmount == 1 then
		return
	end
	self.m_AmountBox:SetValue(1)
	self.m_AmountBox:SetAmountRange(1, iAmount)
	self.m_AmountBox:OpenKeyBoard()
	self.m_AmountBox:SetActive(true)
end

function CItemDecomposeBox.OnValueChange(self, iValue)
	if self.m_SelectedId == -1 then
		return
	end
	self.m_AmountBox:SetActive(false)
	self.m_DeComposeBox:UpdateDecomposeItem(self.m_SelectedId, iValue)
end

function CItemDecomposeBox.OnClickBagItem(self, oBox)
	if not oBox.m_Item then
		return
	end
	local bIsSelected = self.m_DeComposeBox:IsSelected(oBox.m_Item.m_ID)
	if bIsSelected then
		self.m_DeComposeBox:DelDecomposeItem(oBox.m_Item.m_ID, true)
		bIsSelected = false
	else
		bIsSelected = self.m_DeComposeBox:AddDecomposeItem(oBox.m_Item)
		if bIsSelected then
			self.m_SelectedId = oBox.m_Item.m_ID
			self.m_SelectedItem = oBox.m_Item
			self:RefreshAmountBox()
		end
	end
	oBox.m_DelSpr:SetActive(bIsSelected)
end

return CItemDecomposeBox
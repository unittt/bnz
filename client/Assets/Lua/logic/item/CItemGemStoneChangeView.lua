local CItemGemStoneChangeView = class("CItemGemStoneChangeView", CViewBase)

function CItemGemStoneChangeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemGemStoneChangeView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "sub"
	self.m_ExtendClose = "Black"
end

function CItemGemStoneChangeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CurAttrL = self:NewUI(2, CLabel)
	self.m_NewAttrL = self:NewUI(3, CLabel)
	self.m_SwitchBtn = self:NewUI(4, CButton)
	self.m_CostItemSpr = self:NewUI(5, CSprite)
	self.m_ScrollView = self:NewUI(6, CScrollView)
	self.m_AttrGrid = self:NewUI(7, CGrid)
	self.m_AttrBoxClone = self:NewUI(8, CBox)

	self.m_SelectItem = nil
	self.m_CostItemId = 11182
	self:InitContent()
end

function CItemGemStoneChangeView.InitContent(self)
	self.m_AttrBoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnClickSwitch"))
end

function CItemGemStoneChangeView.SetItem(self, oItem)
	self.m_Item = oItem
	local dInfo = self.m_Item:GetGemStoneInfo()
	self.m_Grade = dInfo.grade
	self:RefreshAll()
end

function CItemGemStoneChangeView.GetAttr(self, oItem)
	local list = oItem:GetGemStoneAttr()
	if not list then
		return ""
	end
	local sAttr = ""
	for i,dAttr in ipairs(list) do
		sAttr = string.format("%s  %s +%d    ", sAttr, dAttr.attrname, dAttr.value)
	end
	return sAttr
end

function CItemGemStoneChangeView.RefreshAll(self)
	self:RefreshCurrentAttr()
	self:RefreshCostItem()
	self:RefreshGrid()
end

function CItemGemStoneChangeView.RefreshCurrentAttr(self)
	local sAttr = self:GetAttr(self.m_Item)
	self.m_CurAttrL:SetText(sAttr)
end

function CItemGemStoneChangeView.RefreshNewAttr(self)
	local sAttr = self:GetAttr(self.m_SelectItem)
	self.m_NewAttrL:SetText(sAttr)
end

function CItemGemStoneChangeView.RefreshCostItem(self)
	local iAmount = 0
	local itemList = g_ItemCtrl:GetBagItemListBySid(self.m_CostItemId)
	if itemList then
		for _,v in ipairs(itemList) do
			if v:GetSValueByKey("itemlevel") >= self.m_Grade then
				iAmount = iAmount + v:GetSValueByKey("amount")
			end
		end
	end
	self.m_IsEnough = iAmount > 0
	local dItem = DataTools.GetItemData(self.m_CostItemId)
	self.m_CostItemName = self.m_Grade.."级"..dItem.name
	self.m_CostItemName = string.format(data.colorinfodata.ITEM[dItem.quality].color, self.m_CostItemName)

	self.m_CostItemSpr:SpriteItemShape(dItem.icon)
	self.m_CostItemSpr:SetGrey(iAmount == 0)
	self.m_CostItemSpr:AddUIEvent("click", callback(self, "OnClickCostItem"))
end

function CItemGemStoneChangeView.RefreshGrid(self)
	local dInfo = self.m_Item:GetGemStoneInfo()
	local sCurAttr = dInfo.addattr[1]
	local iGrade = dInfo.grade
	local iCnt = 1
	for i,v in ipairs(data.hunshidata.ATTR) do
		local iColor = v.color	
		local dColor = data.hunshidata.COLOR[iColor]
		if dColor.level == 1 and v.attr ~= sCurAttr then
			local dGemStoneInfo = {grade = iGrade, addattr = {[1] = v.attr}}
			local oItem = CItem.CreateDefault(dColor.itemsid, dGemStoneInfo)
			local oBox = self:CreateItemBox(oItem)
			self.m_AttrGrid:AddChild(oBox)
			if iCnt == 1 then
				oBox:SetSelected(true)
				self:OnClickItem(oBox)
			end
			iCnt = iCnt + 1
		end	
	end
end

function CItemGemStoneChangeView.CreateItemBox(self, oItem)
	local oBox = self.m_AttrBoxClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_Item = oItem

	oBox:SetActive(true)
	oBox.m_IconSpr:SpriteItemShape(oItem:GetCValueByKey("icon"))
	oBox:AddUIEvent("click", callback(self, "OnClickItem"))
	return oBox
end

function CItemGemStoneChangeView.OnClickCostItem(self)
	local oItem = CItem.CreateDefault(self.m_CostItemId)
	oItem.m_SData.itemlevel = self.m_Grade
	g_WindowTipCtrl:SetWindowGainItemTipByItem(oItem)
end

function CItemGemStoneChangeView.OnClickItem(self, oBox)
	self.m_SelectItem = oBox.m_Item
	self:RefreshNewAttr()
end

function CItemGemStoneChangeView.OnClickSwitch(self)
	--TODO:Switch attr
	if not self.m_IsEnough then
		g_NotifyCtrl:FloatMsg(self.m_CostItemName.."不足")
		return
	end
	local dInfo = self.m_SelectItem:GetGemStoneInfo()
	local iColor = data.hunshidata.ITEM2COLOR[self.m_SelectItem.m_SID]
	netitem.C2GSChangeHS(self.m_Item.m_ID, dInfo.addattr[1], iColor)
	self:CloseView()
end

return CItemGemStoneChangeView 
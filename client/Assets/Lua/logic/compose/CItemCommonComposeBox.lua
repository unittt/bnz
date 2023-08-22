local CItemCommonComposeBox = class("CItemCommonComposeBox", CBox)

function CItemCommonComposeBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_ComposeItemBox = self:NewUI(1, CBox)
	self.m_CostItemBox = self:NewUI(2, CBox)
	self.m_ComposeBtn = self:NewUI(3, CWidget)
	self.m_AmountBox = self:NewUI(4, CAmountSettingBox) 

	self:InitContent()
end

function CItemCommonComposeBox.InitContent(self)
	self:InitItemBox()
	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnClickCompose"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function CItemCommonComposeBox.InitItemBox(self)
	local oBox = self.m_ComposeItemBox
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_IconSpr:AddUIEvent("click", function()
		g_WindowTipCtrl:SetWindowGainItemTip(self.m_SelectedItem)
	end)

	oBox = self.m_CostItemBox
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_AmountL = oBox:NewUI(3, CLabel)
	oBox.m_CountL = oBox:NewUI(4, CLabel)
	oBox.m_IconSpr:AddUIEvent("click", function()
		if self.m_CostInfo then
			g_WindowTipCtrl:SetWindowGainItemTip(self.m_CostInfo.sid)
		end
	end)
end

function CItemCommonComposeBox.SetSelectedItem(self, iItemId)
	self.m_SelectedItem = iItemId
	self:RefreshAll()
end

function CItemCommonComposeBox.OnCtrlItemEvent(self, oCtrl)
	if not self:GetActive() then
		return
	end
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:RefreshAll()
	end
end

function CItemCommonComposeBox.RefreshAll(self)
	self:RefreshCostItem()
	self:RefreshComposeItem()
end

function CItemCommonComposeBox.RefreshComposeItem(self)
	local tData = DataTools.GetItemData(self.m_SelectedItem)
	local oBox = self.m_ComposeItemBox
	oBox:SetActive(tData ~= nil)
	if not tData then
		return
	end
	oBox.m_IconSpr:SpriteItemShape(tData.icon)
	oBox.m_NameL:SetText(tData.name)
end

function CItemCommonComposeBox.RefreshCostItem(self)
	local tComposeData = data.itemcomposedata.ITEMCOMPOUND[self.m_SelectedItem]
	local oBox = self.m_CostItemBox
	oBox:SetActive(tComposeData ~= nil)
	if not tComposeData then
		return
	end
	local dCost = tComposeData.sid_item_list[1]
	oBox.m_CountL:SetText("/" .. dCost.amount)
	local tItemData = DataTools.GetItemData(dCost.sid)
	local iSum = g_ItemCtrl:GetBagItemAmountBySid(dCost.sid)
	if iSum == 0 or iSum < dCost.amount then
        oBox.m_AmountL:SetText("[ffb398]"..iSum)
        oBox.m_AmountL:SetEffectColor(Color.RGBAToColor("cd0000"))
		self:RefreshAmount(0, 0)
    else
        oBox.m_AmountL:SetText("[0fff32]"..iSum)
        oBox.m_AmountL:SetEffectColor(Color.RGBAToColor("003C41"))
        self:RefreshAmount(1, math.floor(iSum/dCost.amount))
    end
    oBox.m_AmountL:ResetAndUpdateAnchors()
	oBox.m_IconSpr:SpriteItemShape(tItemData.icon)
	oBox.m_NameL:SetText(tItemData.name)
	self.m_CostInfo = dCost
end

function CItemCommonComposeBox.RefreshAmount(self, iMin, iMax)
	self.m_AmountBox:SetValue(iMin)
	self.m_AmountBox:SetAmountRange(iMin, iMax)	
end

function CItemCommonComposeBox.OnClickCompose(self)
	local iAmount = self.m_AmountBox:GetValue()
	if not self.m_SelectedItem or self.m_SelectedItem <= 0 then
		g_NotifyCtrl:FloatMsg("请选择合成物品")
		return
	end	
	if iAmount == 0 then
		g_NotifyCtrl:FloatMsg("合成材料不足")
		return
	end
	local oBox = self.m_CostItemBox
	local lItem = g_ItemCtrl:GetBagItemListBySid(self.m_CostInfo.sid)
	netitem.C2GSComposeItem(nil, iAmount, self.m_SelectedItem)
end

return CItemCommonComposeBox
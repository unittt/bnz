local CItemGemStoneComposeBox = class("CItemGemStoneComposeBox", CBox)

function CItemGemStoneComposeBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_ComposeItemBox = self:NewUI(1, CBox)
	self.m_ComposeBtn = self:NewUI(2, CButton)
	self.m_SuccessRatioL = self:NewUI(3, CLabel)
	self.m_AssistItemBox = self:NewUI(4, CBox)
	self.m_CostItemGrid = self:NewUI(5, CGrid)
	self.m_CostItemBox = self:NewUI(6, CBox)
	self.m_TipsL = self:NewUI(7, CLabel)

	self.m_SelectedItem = nil
	self.m_ProtectItemId = 11181
	self.m_ComposeCost = 0
	self.m_IsEnough = false
	self:InitContent()
end

function CItemGemStoneComposeBox.InitContent(self)
	self:InitItemBox()
	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnClickCompose"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function CItemGemStoneComposeBox.InitItemBox(self)
	local oBox = self.m_ComposeItemBox
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_IconSpr:AddUIEvent("click", function()
		if self.m_SelectedItem then
			local dShowInfo = {
				grade = self.m_SelectedItem.grade + 1,
				addattr = self.m_SelectedItem.addattr
			}
			g_WindowTipCtrl:SetWindowGainItemTip(self.m_SelectedItem.sid , nil, nil, dShowInfo)
		end
	end)

	local oBox = self.m_CostItemBox
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_AmountL = oBox:NewUI(3, CLabel)
	oBox.m_AddSpr = oBox:NewUI(4, CSprite)
	oBox.m_ItemInfoObj = oBox:NewUI(5, CObject)
	oBox.m_CountL = oBox:NewUI(6, CLabel)
	oBox:AddUIEvent("click", function()
		--TOTO:打开物品选择列表
		CItemGemStoneItemListView:ShowView(function(oView)
			oView:SetGradeArea(1, DataTools.GetGemStoneMaxComposeLv() - 1)
			oView:RefreshItemGrid()
			oView:SetClickCallback(callback(self, "SetSelectedItem"))
		end)
	end)

	local oBox = self.m_AssistItemBox
	oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_AmountL = oBox:NewUI(3, CLabel)
	oBox.m_CheckBox = oBox:NewUI(4, CWidget)
	oBox.m_EffL = oBox:NewUI(5, CLabel)
	oBox.m_CountL = oBox:NewUI(6, CLabel)
	oBox.m_ItemSpr:AddUIEvent("click", function()
		g_WindowTipCtrl:SetWindowGainItemTip(self.m_ProtectItemId)
	end)
	oBox.m_CheckBox:AddUIEvent("click", callback(self, "OnClickCheckBox"))
end

function CItemGemStoneComposeBox.SetSelectedItem(self, oItem)
	if not oItem then
		self.m_SelectedItem = nil
		self.m_ComposeData = nil
		self:RefreshAll()
		return
	end
	local dInfo = oItem:GetGemStoneInfo()
	self.m_SelectedItem = {
		id = oItem.m_ID,
		sid = oItem.m_SID,
		grade = dInfo.grade,
		addattr = table.copy(dInfo.addattr)
	}
	self.m_Grade = oItem:GetGemStoneInfo().grade or 0
	self.m_ComposeData = data.hunshidata.COMPOSE[self.m_Grade + 1]
	local iColor = data.hunshidata.ITEM2COLOR[oItem.m_SID]
	local dColor = data.hunshidata.COLOR[iColor]
	self.m_ComposeCost = dColor.upgrade_cost --混色的升级只需要2颗
	self:RefreshAll()
end

function CItemGemStoneComposeBox.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.DelItem then
		--TODO:当前物品消耗完需重新寻找可消耗的物品id
		local iDelId = oCtrl.m_EventData
		if self.m_SelectedItem and self.m_SelectedItem.id == iDelId then
			local iItemId = g_ItemCtrl:GetGemStoneItemId(self.m_SelectedItem.sid, 
				self.m_SelectedItem.grade, self.m_SelectedItem.addattr)
			self.m_SelectedItem.id = iItemId
		end
	end
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:RefreshAll()
	end
end

function CItemGemStoneComposeBox.RefreshAll(self)
	self:RefreshCostItem()
	self:RefreshComposeItem()
	self:RefreshAssistItem()
	self:RefreshSuccessRatio()
end

function CItemGemStoneComposeBox.RefreshComposeItem(self)
	local oBox = self.m_ComposeItemBox
	oBox:SetActive(self.m_SelectedItem ~= nil)
	if not self.m_SelectedItem then
		return
	end
	local dItemData = DataTools.GetItemData(self.m_SelectedItem.sid)
	oBox.m_IconSpr:SpriteItemShape(dItemData.icon)
	local sName = (self.m_SelectedItem.grade + 1).."级"..dItemData.name
	oBox.m_NameL:SetText(sName)
end

function CItemGemStoneComposeBox.RefreshCostItem(self)
	local oBox = self.m_CostItemBox
	local dItem = self.m_SelectedItem
	oBox.m_ItemInfoObj:SetActive(dItem ~= nil)
	oBox.m_AddSpr:SetActive(dItem == nil)
	if not dItem then
		return
	end
	oBox.m_CountL:SetText("/" .. self.m_ComposeCost)
	local iSum = g_ItemCtrl:GetGemStoneAmount(dItem.sid, dItem.grade, dItem.addattr)
	self.m_IsEnough = iSum > 0 and iSum >= self.m_ComposeCost
	if self.m_IsEnough then
        oBox.m_AmountL:SetText("[0fff32]"..iSum)
        oBox.m_AmountL:SetEffectColor(Color.RGBAToColor("003C41"))
    else
        oBox.m_AmountL:SetText("[ffb398]"..iSum)
        oBox.m_AmountL:SetEffectColor(Color.RGBAToColor("cd0000"))
    end

	local dItemData = DataTools.GetItemData(dItem.sid)
	oBox.m_IconSpr:SpriteItemShape(dItemData.icon)
	oBox.m_NameL:SetText("")
end

function CItemGemStoneComposeBox.RefreshAssistItem(self)
	--TODO:获取保护石信息
	local dItem = DataTools.GetItemData(self.m_ProtectItemId)
	local iSum = g_ItemCtrl:GetBagItemAmountBySid(self.m_ProtectItemId)
	local iCost = self.m_ComposeData and self.m_ComposeData.protectneed or 0
	local oBox = self.m_AssistItemBox
	oBox:SetActive(iCost > 0)
	self.m_TipsL:SetActive(iCost == 0)
	if iCost == 0 then
		return
	end
	oBox.m_ItemSpr:SpriteItemShape(dItem.icon)
	oBox.m_NameL:SetText(dItem.name)
	oBox.m_CountL:SetText("/" .. iCost)
	if iSum < iCost then
        oBox.m_AmountL:SetText("[ffb398]"..iSum)
        oBox.m_AmountL:SetEffectColor(Color.RGBAToColor("cd0000"))
	else
        oBox.m_AmountL:SetText("[0fff32]"..iSum)
        oBox.m_AmountL:SetEffectColor(Color.RGBAToColor("003C41"))
	end
	oBox.m_AmountL:ResetAndUpdateAnchors()
	oBox.m_CheckBox:SetSelected(g_ItemCtrl.m_ComposeProtect)
	oBox.m_EffL:SetText("100%")
end

function CItemGemStoneComposeBox.RefreshSuccessRatio(self)
	if not self.m_ComposeData then
		return
	end
	local iRatio = self.m_ComposeData.ratio
	self.m_SuccessRatioL:SetText(iRatio.."%")
end

function CItemGemStoneComposeBox.OnClickCheckBox(self)
	g_ItemCtrl.m_ComposeProtect = self.m_AssistItemBox.m_CheckBox:GetSelected()
end

function CItemGemStoneComposeBox.OnClickCompose(self)
	if not self.m_SelectedItem then
		g_NotifyCtrl:FloatMsg("请选择合成物品")
		return
	end	
	if not self.m_IsEnough then
		g_NotifyCtrl:FloatMsg("升级材料不足")
		return
	end
	local bIsProtect = self.m_AssistItemBox.m_CheckBox:GetSelected() and 1 or 0
	netitem.C2GSHSCompose1(self.m_SelectedItem.id, bIsProtect)
end

return CItemGemStoneComposeBox
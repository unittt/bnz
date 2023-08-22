local CItemGemStoneMixBox = class("CItemGemStoneMixBox", CBox)

function CItemGemStoneMixBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_MixItemBox = self:NewUI(1, CBox)
	self.m_MixBtn = self:NewUI(2, CButton)
	self.m_SuccessRatioL = self:NewUI(3, CLabel)
	self.m_AssistItemBox = self:NewUI(4, CBox)
	self.m_CostItemGrid = self:NewUI(5, CGrid)
	self.m_CostItemBox = {
		[1] = self:NewUI(6, CBox),
		[2] = self:NewUI(7, CBox),
	}
	self.m_TipsL = self:NewUI(8, CLabel)

	self.m_SelectedItem = {}
	self.m_ProtectItemId = 11181
	self:InitContent()
end

function CItemGemStoneMixBox.InitContent(self)
	self:InitItemBox()
	self.m_MixBtn:AddUIEvent("click", callback(self, "OnClickMix"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function CItemGemStoneMixBox.InitItemBox(self)
	local oBox = self.m_MixItemBox
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_IconSpr:AddUIEvent("click", function()
		if self.m_SelectedItem[1] and self.m_SelectedItem[2] then
			local lAttr = table.copy(self.m_SelectedItem[1].addattr)
			table.extend(lAttr, self.m_SelectedItem[2].addattr)
			local dShowInfo = {
				grade = self.m_SelectedItem[1].grade,
				addattr = lAttr
			}
			g_WindowTipCtrl:SetWindowGainItemTip(oBox.m_ItemSid , nil, nil, dShowInfo)
		end
	end)

	local function InitCostItem(oBox, bIsMain)
		oBox.m_IsMainCost = bIsMain
		oBox.m_IconSpr = oBox:NewUI(1, CSprite)
		oBox.m_NameL = oBox:NewUI(2, CLabel)
		oBox.m_AmountL = oBox:NewUI(3, CLabel)
		oBox.m_AddSpr = oBox:NewUI(4, CSprite)
		oBox.m_ItemInfoObj = oBox:NewUI(5, CObject)
		oBox:AddUIEvent("click", callback(self, "OnClickItemSelect", oBox))
	end
	InitCostItem(self.m_CostItemBox[1], true)
	InitCostItem(self.m_CostItemBox[2], false)
	
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

function CItemGemStoneMixBox.SetSelectedItem(self, oItem, iIndex)
	iIndex = iIndex or 1
	local bIsMain = iIndex == 1
	if bIsMain then
		self:SetSelectedItem(nil, 2)
		self.m_MixData = nil
	end
	if not oItem then
		self.m_SelectedItem[iIndex] = nil
		self:RefreshAll()
		return
	end
	local dInfo = oItem:GetGemStoneInfo()
	self.m_SelectedItem[iIndex] = {
		id = oItem.m_ID,
		sid = oItem.m_SID,
		grade = dInfo.grade,
		addattr = table.copy(dInfo.addattr),
		color = data.hunshidata.ITEM2COLOR[oItem.m_SID],
	}
	if bIsMain then
		self.m_MixData = data.hunshidata.REFINE[dInfo.grade]
	end
	table.print(self.m_SelectedItem)
	self:RefreshAll()
end

function CItemGemStoneMixBox.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.DelItem then
		--TODO:当前物品消耗完需重新寻找可消耗的物品id
		local iDelId = oCtrl.m_EventData
		if self.m_SelectedItem then
			for i=1,2 do
				local dItem = self.m_SelectedItem[i]
				if dItem and dItem.id == iDelId then
					local iItemId = g_ItemCtrl:GetGemStoneItemId(dItem.sid, dItem.grade, dItem.addattr)
					self.m_SelectedItem[i].id = iItemId
				end
			end
		end
	end
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:RefreshAll()
	end
end

function CItemGemStoneMixBox.RefreshAll(self)
	self:RefreshCostItem(1)
	self:RefreshCostItem(2)
	self:RefreshMixItem()
	self:RefreshAssistItem()
	self:RefreshSuccessRatio()
end

function CItemGemStoneMixBox.RefreshMixItem(self)
	local bIsCanMix = self.m_SelectedItem[1] ~= nil and self.m_SelectedItem[2] ~= nil
	local oBox = self.m_MixItemBox
	oBox:SetActive(bIsCanMix)
	if not bIsCanMix then
		return
	end
	local dColor = DataTools.GetGemStoneMixColor(self.m_SelectedItem[1].color, self.m_SelectedItem[2].color)
	local dItemData = DataTools.GetItemData(dColor.itemsid)
	oBox.m_ItemSid = dColor.itemsid
	oBox.m_IconSpr:SpriteItemShape(dItemData.icon)
	local sName = self.m_SelectedItem[1].grade.."级"..dItemData.name
	oBox.m_NameL:SetText(sName)
end

function CItemGemStoneMixBox.RefreshCostItem(self, iIndex)
	local dItem = self.m_SelectedItem[iIndex]
	local bIsEmpty = dItem == nil
	local oBox = self.m_CostItemBox[iIndex]
	oBox.m_ItemInfoObj:SetActive(not bIsEmpty)
	oBox.m_AddSpr:SetActive(bIsEmpty)
	if bIsEmpty then
		return
	end
	local dItemData = DataTools.GetItemData(dItem.sid)
	oBox.m_IconSpr:SpriteItemShape(dItemData.icon)
	oBox.m_NameL:SetText(dItem.grade.."级"..dItemData.name)
	local iSum = g_ItemCtrl:GetGemStoneAmount(dItem.sid, dItem.grade, dItem.addattr)
	dItem.amount = iSum
	if iSum <= 0 then
		oBox.m_AmountL:SetText(string.format("[c]#R%d#n[/c]", iSum))
	else
		oBox.m_AmountL:SetText(iSum)
	end
end

function CItemGemStoneMixBox.RefreshAssistItem(self)
	--TODO:获取保护石信息
	local dItem = DataTools.GetItemData(self.m_ProtectItemId)
	local iSum = g_ItemCtrl:GetBagItemAmountBySid(self.m_ProtectItemId)
	local iCost = self.m_MixData and self.m_MixData.protectneed or 0
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
	oBox.m_CheckBox:SetSelected(g_ItemCtrl.m_MixProtect)
	oBox.m_EffL:SetText("100%")
end

function CItemGemStoneMixBox.RefreshSuccessRatio(self)
	if not self.m_MixData then
		return
	end
	local iRatio = self.m_MixData.ratio
	self.m_SuccessRatioL:SetText(iRatio.."%")
end

function CItemGemStoneMixBox.OnClickCheckBox(self)
	g_ItemCtrl.m_MixProtect = self.m_AssistItemBox.m_CheckBox:GetSelected()
end

function CItemGemStoneMixBox.OnClickMix(self)
	if not self.m_SelectedItem[1] or not self.m_SelectedItem[2] then
		g_NotifyCtrl:FloatMsg("请选择合成物品")
		return
	end	
	if self.m_SelectedItem[1].amount == 0 or self.m_SelectedItem[2].amount == 0 then
		g_NotifyCtrl:FloatMsg("合成材料不足")
		return
	end
	local bIsProtect = self.m_AssistItemBox.m_CheckBox:GetSelected() and 1 or 0
	netitem.C2GSHSCompose2(self.m_SelectedItem[1].id, self.m_SelectedItem[2].id, bIsProtect)
end

function CItemGemStoneMixBox.OnClickItemSelect(self, oBox)
	if not oBox.m_IsMainCost and not self.m_SelectedItem[1] then
		g_NotifyCtrl:FloatMsg("请先选择主材料")
		return
	end
	CItemGemStoneItemListView:ShowView(function(oView)
		if not oBox.m_IsMainCost then 
			oView:SetGradeArea(self.m_SelectedItem[1].grade, self.m_SelectedItem[1].grade)
			oView:SetFiterCondition(self.m_SelectedItem[1].color, 2, true)
			oView:SetTipsText("（副材料需要等级相同颜色不同的宝石）")
			oView:SetClickCallback(callback(self, "SetSelectedItem"))
		else
			oView:SetGradeArea(1, DataTools.GetGemStoneMaxComposeLv())
			oView:SetFiterCondition(nil, 2, true)
			oView:SetTipsText("（主材料需要单颜色的宝石）")
			oView:SetClickCallback(callback(self, "SetSelectedItem"))
		end
		oView:RefreshItemGrid()
	end)
end

return CItemGemStoneMixBox
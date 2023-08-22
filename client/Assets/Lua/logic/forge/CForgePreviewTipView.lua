local CForgePreviewTipView = class("CForgePreviewTipView", CViewBase)

function CForgePreviewTipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgePreviewTipView.prefab", cb)
	self.m_DepthType = "Dialog"
	-- self.m_ExtendClose = "ClickOut"
end

function CForgePreviewTipView.OnCreateView(self)
	self.m_ItemBox = self:NewUI(1, CItemBaseBox)
	self.m_EquipLevelL = self:NewUI(2, CLabel)
	self.m_EquipNameL = self:NewUI(3, CLabel)
	self.m_EquipTypeL = self:NewUI(4, CLabel)
	self.m_AttrTable =self:NewUI(6, CTable)
	self.m_AttrLabelClone = self:NewUI(7, CLabel)
	self.m_RangeLabelClone = self:NewUI(8, CLabel)
	self.m_CloseBtn = self:NewUI(9, CButton)
end

function CForgePreviewTipView.InitView(self)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AttrLabelClone:SetActive(false)
	self.m_RangeLabelClone:SetActive(false)
	
	self.m_ItemBox:SetBagItem(self.m_CItem)
	self.m_ItemBox:SetEnableTouch(false)
	self.m_ItemBox:SetBaseItemQuality(false, 1)
	
	self.m_EquipLevelL:SetText(self.m_CItem:GetItemEquipLevel().."级")
	self.m_EquipNameL:SetText(self.m_CItem:GetItemName())
	self.m_EquipTypeL:SetText(self.m_CItem:GetCValueByKey("partName")) 

	local tData = g_ItemCtrl:GetEquipPreview(self.m_CItem)
	for k,attr in pairs(tData) do
		local oAttrLabel = self.m_AttrLabelClone:Clone()
		local oRangeLabel = self.m_RangeLabelClone:Clone()

		oRangeLabel:SetActive(true)
		oAttrLabel:SetActive(true)

		oAttrLabel:SetText(attr.name)
		oRangeLabel:SetText(string.format("+%d～%d", attr.min, attr.max))

		self.m_AttrTable:AddChild(oAttrLabel)
		self.m_AttrTable:AddChild(oRangeLabel)
	end
end

function CForgePreviewTipView.SetItem(self, citem)
	self.m_CItem = citem
	self:InitView()
end

return CForgePreviewTipView
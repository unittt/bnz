local CForgeAttrPreviewBox = class("CForgeAttrPreviewBox", CBox)

function CForgeAttrPreviewBox.ctor(self, obj, boxType)
	CBox.ctor(self, obj)
	self.m_AttrTable =self:NewUI(1, CTable)
	self.m_AttrLabelClone = self:NewUI(2, CLabel)
	self.m_RangeLabelClone = self:NewUI(3, CLabel)

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "SetActive", false))
	self.m_AttrLabelClone:SetActive(false)
	self.m_RangeLabelClone:SetActive(false)
end

function CForgeAttrPreviewBox.SetItem(self, cItem)
	self.m_CItem = cItem
	self:RefreshAttr()
end

function CForgeAttrPreviewBox.RefreshAttr(self)
	self:SetActive(true)
	self.m_AttrTable:Clear()
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
	self.m_AttrTable:Reposition()
end

return CForgeAttrPreviewBox
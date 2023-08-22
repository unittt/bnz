local CItemPreviewBox = class("CItemPreviewBox", CBox)

function CItemPreviewBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_BaseTable = self:NewUI(1, CTable)
	self.m_SoulTable = self:NewUI(2, CTable)
	self.m_AttrLabelClone = self:NewUI(3, CLabel)
	self.m_RangeLabelClone = self:NewUI(4, CLabel)
	self.m_ValueLabelClone = self:NewUI(5, CLabel)

	self.m_AttrLabelClone:SetActive(false)
	self.m_RangeLabelClone:SetActive(false)
	self.m_ValueLabelClone:SetActive(false)
	
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "SetActive", false))
end 

function CItemPreviewBox.SetItem(self, cItem)
	self.m_BaseTable:Clear()
	self.m_SoulTable:Clear()
	self.m_CItem = cItem
	self:RefreshAttr()
end

function CItemPreviewBox.RefreshAttr(self)
	self:RefreshBaseTable()
	self:RefreshSoulTable()
end

function CItemPreviewBox.RefreshBaseTable(self)
	local function GetAttrValue(sKey)
		local dInfo = self.m_CItem:GetSValueByKey("apply_info")
		for i,v in ipairs(dInfo) do
			if v.key == sKey then
				return v.value
			end
		end
		return 0
	end
	self.m_BaseTable:Clear()
	local tData = g_ItemCtrl:GetEquipPreview(self.m_CItem)
	if tData and next(tData) then
		for k,attr in pairs(tData) do
			local oAttrLabel = self.m_AttrLabelClone:Clone()
			local oValueLabel = self.m_ValueLabelClone:Clone()
			local oRangeLabel = self.m_RangeLabelClone:Clone()

			oAttrLabel:SetActive(true)
			oValueLabel:SetActive(true)
			oRangeLabel:SetActive(true)

			oAttrLabel:SetText(attr.name)
			oValueLabel:SetText("+"..GetAttrValue(attr.attr))
			oRangeLabel:SetText(string.format("%d～%d", attr.min, attr.max))

			self.m_BaseTable:AddChild(oAttrLabel)
			self.m_BaseTable:AddChild(oValueLabel)
			self.m_BaseTable:AddChild(oRangeLabel)
		end
	end
	self.m_BaseTable:Reposition()
end

function CItemPreviewBox.RefreshSoulTable(self)
	local dSoulInfo = nil
	if self.m_CItem:HasAttachSoul() then
		dSoulInfo = self.m_CItem:GetSValueByKey("equip_info").fuhun_attr
	end
	self.m_SoulTable:Clear()
	for k,v in ipairs(self.m_CItem:GetSValueByKey("apply_info")) do
		local sAttrName = data.attrnamedata.DATA[v.key].name
		local iAttr = 100
		local iProgress = 0
		if dSoulInfo then
			for _,attrInfo in ipairs(dSoulInfo) do
				if attrInfo.key == v.key then
					local iSoulAttr = math.floor(attrInfo.value*100/v.value)
					iAttr = iAttr + iSoulAttr
				end
			end
		end
		local iMin,iMax = DataTools.GetEquipSoulEffectRange(self.m_CItem:GetItemEquipLevel())

		local oAttrLabel = self.m_AttrLabelClone:Clone()
		local oValueLabel = self.m_ValueLabelClone:Clone()
		local oRangeLabel = self.m_RangeLabelClone:Clone()

		oAttrLabel:SetActive(true)
		oValueLabel:SetActive(true)
		oRangeLabel:SetActive(true)

		oAttrLabel:SetText(sAttrName)
		oValueLabel:SetText(self.m_CItem:HasAttachSoul() and iAttr.."%" or "未附魂")
		oRangeLabel:SetText(string.format("%d%%～%d%%", 100 + iMin, 100 + iMax))

		self.m_SoulTable:AddChild(oAttrLabel)
		self.m_SoulTable:AddChild(oValueLabel)
		self.m_SoulTable:AddChild(oRangeLabel)
	end	
	self.m_SoulTable:Reposition()
end
return CItemPreviewBox
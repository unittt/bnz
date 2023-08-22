local CForgeSoulAttrBox = class("CForgeSoulAttrBox", CBox)

function CForgeSoulAttrBox.ctor(self, obj, boxType)
	CBox.ctor(self, obj)
	self.m_AttrTable = self:NewUI(1, CTable)
	self.m_AttrBoxClone = self:NewUI(2, CBox)

	self.m_AttrBoxClone:SetActive(false)
end

function CForgeSoulAttrBox.SetItem(self, cItem)
	self.m_Item = cItem
	self:RefreshAttr()
end

function CForgeSoulAttrBox.RefreshAttr(self)
	self.m_AttrTable:Clear()
	if not self.m_Item then
		return
	end
	local dEquipInfo = self.m_Item.m_SData.equip_info
	--普通属性
	self:CreateBaseAttr(dEquipInfo)
	--神魂灵性
	self:CreateSoulAttr(dEquipInfo)
end

function CForgeSoulAttrBox.CreateBaseAttr(self, dEquipInfo)
	local sDesc = "[c][1d8e00]基本属性提升[-]"
	local oBox = self:CreateAttr(sDesc)
	self.m_AttrTable:AddChild(oBox)

	local dSoulInfo = nil
	if self.m_Item:HasAttachSoul() then
		dSoulInfo = self.m_Item:GetSValueByKey("equip_info").fuhun_attr
	end

	local function GetSoulAttr(sKey, dSoulInfo)
		for i,v in ipairs(dSoulInfo) do
			if v.key == sKey then
				return v.value
			end
		end
		return 0
	end

	for k,v in ipairs(self.m_Item:GetSValueByKey("apply_info")) do
		local sAttrName = data.attrnamedata.DATA[v.key].name
		local iBaseAttr = 100
		local iProgress = 0
		if dSoulInfo then
			local iMin,iMax = DataTools.GetEquipSoulEffectRange(self.m_Item:GetItemEquipLevel())
			local iSoulAttr = math.floor(GetSoulAttr(v.key, dSoulInfo)*1000/v.value)/10
			iBaseAttr = string.format("%.1f%%(%d%%)", iBaseAttr + iSoulAttr, iBaseAttr + iMax)
			iProgress = iSoulAttr/iMax
		end
		oBox = self:CreateAttr(sAttrName, iBaseAttr, iProgress)
		self.m_AttrTable:AddChild(oBox)
	end
end

function CForgeSoulAttrBox.CreateSoulAttr(self, dEquipInfo)
	if table.count(dEquipInfo.fuhun_extra) > 0 then
		local sDesc =  "[c][1d8e00]神魂灵性[-]"
		local oBox = self:CreateAttr(sDesc)
		self.m_AttrTable:AddChild(oBox)
		for k,v in ipairs(dEquipInfo.fuhun_extra) do
			local dAttr = data.attrnamedata.DATA[v.key]
			local sAttr = dAttr.name
			local iVal = v.value
			if dAttr.attr == "seal_ratio" or dAttr.attr == "res_seal_ratio" then
				iVal = iVal * 10
			end
			oBox = self:CreateAttr(string.format("%s+%d", sAttr, iVal))
			self.m_AttrTable:AddChild(oBox)
		end
	end
end

function CForgeSoulAttrBox.CreateAttr(self, sArg1, sArg2, iArg3)
	local oBox = self.m_AttrBoxClone:Clone()
	oBox:SetActive(true)
	oBox.m_AttrL = oBox:NewUI(1, CLabel)
	oBox.m_Slider = oBox:NewUI(2, CSlider)
	oBox.m_ValueL = oBox:NewUI(3, CLabel)

	oBox.m_AttrL:SetRichText(sArg1)
	if sArg2 then
		oBox.m_ValueL:SetRichText(sArg2)
		oBox.m_Slider:SetValue(iArg3)
	else
		oBox.m_ValueL:SetActive(false)
		oBox.m_Slider:SetActive(false)
	end
	return oBox
end
return CForgeSoulAttrBox
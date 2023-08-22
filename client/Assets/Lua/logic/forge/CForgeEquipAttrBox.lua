local CForgeEquipAttrBox = class("CForgeEquipAttrBox", CBox)

function CForgeEquipAttrBox.ctor(self, obj, boxType)
	CBox.ctor(self, obj)
	self.m_AttrTable = self:NewUI(1, CTable)
	self.m_AttrBoxClone = self:NewUI(2, CBox)

	self.m_AttrBoxClone:SetActive(false)
end

function CForgeEquipAttrBox.SetItem(self, cItem)
	self.m_Item = cItem
	self:RefreshAttr()
end

function CForgeEquipAttrBox.RefreshAttr(self)
	self.m_AttrTable:Clear()
	if not self.m_Item then
		return
	end
	local dEquipInfo = self.m_Item.m_SData.equip_info
	--普通属性
	self:CreateBaseAttr(dEquipInfo)
	--特效
	self:CreateSpecialEffc(dEquipInfo)
	--特技
	self:CreateSpecialSkill(dEquipInfo)
end

function CForgeEquipAttrBox.CreateBaseAttr(self, dEquipInfo)
	local oCurEquip = g_ItemCtrl:GetEquipedByPos(self.m_Item:GetCValueByKey("equipPos"))

	local sDesc = "[c][1d8900]基本属性[-]"
	local oBox = self:CreateAttr(sDesc)
	self.m_AttrTable:AddChild(oBox)

	local function GetAttrValue(sKey)
		local dInfo = oCurEquip:GetSValueByKey("apply_info")
		for i,v in ipairs(dInfo) do
			if v.key == sKey then
				return v.value
			end
		end
		return 0
	end

	for k,v in ipairs(self.m_Item:GetSValueByKey("apply_info")) do
		local sAttr = data.attrnamedata.DATA[v.key].name
		local iCompare = nil
		if oCurEquip then
			iCompare = v.value - GetAttrValue(v.key)
			if iCompare == 0 then
				iCompare = nil
			end
		end
		oBox = self:CreateAttr(sAttr, "+"..v.value, iCompare)
		self.m_AttrTable:AddChild(oBox)
	end
end

function CForgeEquipAttrBox.CreateSpecialEffc(self, dEquipInfo)
	if dEquipInfo.se ~= nil then
		for k,v in pairs(dEquipInfo.se) do
			local iEffectId = tonumber(v)
			local sEffName = data.skilldata.SPECIAL_EFFC[iEffectId].name
			local sDesc = string.format("特效:#B[u]%s[/u]#n", sEffName)
			local oBox = self:CreateAttr(sDesc)
			oBox:AddUIEvent("click", callback(self, "OnClickSpecialSkill", iEffectId, false))
			self.m_AttrTable:AddChild(oBox)
		end
	end 
end

function CForgeEquipAttrBox.CreateSpecialSkill(self, dEquipInfo)
	if dEquipInfo.sk ~= nil then
		for k,v in pairs(dEquipInfo.sk) do
			local iSkillId = tonumber(v)
			local sSkillName = data.skilldata.SPECIAL_EFFC[iSkillId].name
			local sDesc = string.format("特技:#B[u]%s[/u]#n", sSkillName)
			local oBox = self:CreateAttr(sDesc)
			oBox:AddUIEvent("click", callback(self, "OnClickSpecialSkill", iSkillId, true))
			self.m_AttrTable:AddChild(oBox)
		end
	end 
end

function CForgeEquipAttrBox.CreateAttr(self, sAttr1, sAttr2, iCompare)
	local oBox = self.m_AttrBoxClone:Clone()
	oBox:SetActive(true)
	oBox.m_AttrLabel = oBox:NewUI(1, CLabel)
	oBox.m_ValueLabel = oBox:NewUI(2, CLabel)
	oBox.m_CompareSpr = oBox:NewUI(3, CSprite)

	oBox.m_AttrLabel:SetRichText(sAttr1)
	if sAttr2 then
		oBox.m_ValueLabel:SetRichText(sAttr2)
	else
		oBox.m_ValueLabel:SetActive(false)
	end
	oBox.m_CompareSpr:SetActive(iCompare ~= nil)
	if iCompare then
		if iCompare > 0 then
			oBox.m_CompareSpr:SetSpriteName("h7_sheng")
		else
			oBox.m_CompareSpr:SetSpriteName("h7_jiang")
		end
	end
	return oBox
end

function CForgeEquipAttrBox.OnClickSpecialSkill(self, iId, bIsSkill)
	local args = {widget =  self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(-140, 50)}
	g_WindowTipCtrl:SetWindowEquipEffectTipInfo(iId, args, bIsSkill) 
end

return CForgeEquipAttrBox
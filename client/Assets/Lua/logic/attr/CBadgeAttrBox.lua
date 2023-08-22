local CBadgeAttrBox = class("CBadgeAttrBox", CBox)

function CBadgeAttrBox.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_NameIcon = self:NewUI(2, CSprite)
	self.m_ItemClone = self:NewUI(3, CBox)
	self.m_Score = self:NewUI(4, CLabel)
	self.m_Grid = self:NewUI(5, CGrid)

	self.m_AttrList = {
    phy_defense = "物防",
    phy_attack = "物攻", 
    max_hp = "气血", 
    cure_power = "治疗强度", 
    endurance = "耐力", 
    speed = "速度", 
    mag_attack = "法攻", 
    mag_defense = "法防",
    seal_ratio = "封印强度",
    res_seal_ratio = "封印抗性",
  }

end

--parameter 头衔等级
function CBadgeAttrBox.SetInfo(self, id, isFullLevel)
	
	local config = data.touxiandata.DATA[id]
	if not config then 
		return
	end 

	local lastConfig = data.touxiandata.DATA[id - 1]
	
	self.m_Icon:SetSpriteName(config.tid)
	self.m_Icon:SetActive(config.tid and config.tid ~= "")


	self.m_NameIcon:SetSpriteName(config.icon)
	self.m_NameIcon:MakePixelPerfect()

	local w, h = self.m_NameIcon:GetSize()
    self.m_NameIcon:SetSize(w*config.uiscale, h*config.uiscale)

	self.m_NameIcon:SetActive(config.icon and config.icon ~= "")
	self.m_Score:SetText(config.power)

	local attrList = config.apply

	local lastAttrList = nil
	if lastConfig then 
		lastAttrList = lastConfig.apply
	end 

	self.m_Grid:HideAllChilds()

	local childCount = 0

	for k, v in ipairs(attrList) do 

		local item = self.m_Grid:GetChild(k) 
		if not item then 
			item = self.m_ItemClone:Clone()
			item:SetActive(true)
			self.m_Grid:AddChild(item)
		end 

		item:SetActive(true)
		childCount = childCount + 1

		item.m_Name = item:NewUI(1, CLabel)
		item.m_Value = item:NewUI(2, CLabel)

		local attr = v.attr
		local value = v.value

		if lastAttrList then 
			--value = value - lastAttrList[k].value
		end 

		if value == 0 then 
			item:SetActive(false)
		else
			item.m_Name:SetText(self.m_AttrList[attr])
			item.m_Value:SetText("+" .. tostring(value))
		end 

		if isFullLevel then 
			item:SetActive(true)
			item.m_Name:SetText(self.m_AttrList[attr])
			item.m_Value:SetText("+" .. tostring(v.value))
		end 

	end 

	local effectList = config.effect

	local lastEffectList = nil
	if lastConfig then 
		lastEffectList = lastConfig.effect
	end 

	local i = 1
	for k, v in pairs(effectList) do 

		if v.level > 0 then 

			local id = v.id
			local tSkillData = DataTools.GetCultivationData(id)

			local item = self.m_Grid:GetChild(childCount + i) 
			if not item then 
				item = self.m_ItemClone:Clone()
				item:SetActive(true)
				self.m_Grid:AddChild(item)
			end 

			item:SetActive(true)
			i = i + 1

			item.m_Name = item:NewUI(1, CLabel)
			item.m_Value = item:NewUI(2, CLabel)

			local level = v.level

			if lastEffectList then 
				--level = level - lastEffectList[v.id].level
			end 

			if level == 0 then 
				item:SetActive(false)
			else
				item.m_Name:SetText(tSkillData.name)
				item.m_Value:SetText("+" .. tostring(level))
			end 

			if isFullLevel then 
				item:SetActive(true)
				item.m_Name:SetText(tSkillData.name)
				item.m_Value:SetText("+" .. tostring(v.level))
			end 
			
		end 

	end 


end

return CBadgeAttrBox
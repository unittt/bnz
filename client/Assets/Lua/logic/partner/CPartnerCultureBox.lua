local CPartnerCultureBox = class("CPartnerCultureBox", CBox)

function CPartnerCultureBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_PartnerName = self:NewUI(1, CLabel)
	self.m_ScoreLabel = self:NewUI(2, CLabel)
	self.m_GradeLabel = self:NewUI(3, CLabel)
	self.m_DetailsProp = self:NewUI(4, CBox)
	self.m_SkillBoxScroll = self:NewUI(5, CScrollView)
	self.m_SkillBoxGrid = self:NewUI(6, CGrid)
	self.m_SkillBoxClone = self:NewUI(7, CBox)
	self.m_StartGrid = self:NewUI(8, CGrid)
	self.m_StartClone = self:NewUI(9, CSprite)
	self.m_ExpSlider = self:NewUI(10, CSlider)
	-- self.m_ItemBoxGrid = self:NewUI(11, CGrid)
	-- self.m_ItemBoxClone = self:NewUI(12, CButton, true, false)
	self.m_PrivityValue = self:NewUI(13, CLabel)
	-- self.m_HintTipBtn = self:NewUI(14, CSprite)
	self.m_EquipBox = self:NewUI(15, CBox)
	self.m_EquipBox.m_Weapon = self.m_EquipBox:NewUI(1, CSprite)
	self.m_EquipBox.m_Armor = self.m_EquipBox:NewUI(2, CSprite)
	-- self.m_UseItemBtn = self:NewUI(16, CButton)
	-- PartnerProp
	for i,v in ipairs(CPartnerMainView.PropNameList) do
		self.m_DetailsProp[v[2]] = self.m_DetailsProp:NewUI(i, CLabel)
	end
	-- 默契度 暂时没有
	self.m_PrivityValue:SetActive(false)
	self.m_StartClone:SetActive(false)
	self.m_SkillBoxClone:SetActive(false)
	-- self.m_ItemBoxClone:SetActive(false)
	self.m_SelectItem = nil
end

function CPartnerCultureBox.ResetPartnerInfo(self, partnerInfo, partnerData)
	self.m_PartnerInfo = partnerInfo
	self.m_PartnerData = partnerData

	self:ResetPartnerEquip()
	self:ResetPartnerProp()
	self:ResetSkillGrid()
end

function CPartnerCultureBox.ResetPartnerEquip(self)
	local showWeapon = false
	local showArmor = false
	if self.m_PartnerData and self.m_PartnerData.equipsid then
		for _,v in ipairs(self.m_PartnerData.equipsid) do
			local equip = DataTools.GetItemData(v, "PARTNEREQUIP")
			if equip.equippos == 1 and not showWeapon then
				showWeapon = true
			elseif equip.equippos == 2 and not showArmor then
				showArmor = true
			end
		end
	end
	self.m_EquipBox.m_Weapon:SetGrey(not showWeapon)
	self.m_EquipBox.m_Armor:SetGrey(not showArmor)
end

function CPartnerCultureBox.ResetPartnerProp(self)
	self.m_PartnerName:SetText(self.m_PartnerInfo.name)
	self.m_ScoreLabel:SetText(self.m_PartnerData.score)
	self.m_GradeLabel:SetText("等级 " .. self.m_PartnerData.grade)
	self.m_PrivityValue:SetText("默契度：" .. 9999999)

	for i,v in ipairs(CPartnerMainView.PropNameList) do
		local val = self.m_PartnerData[v[2]]
		if v[2] == "seal_ratio" or v[2] == "res_seal_ratio" then
			val = val * 10
		end
		local suffix = "[A64E00]" .. val .. (i <= 8 and "" or "%") .. "[-]"
		local textStr = "[386D6F]" .. v[1] .. "[-]" .. " " .. suffix
		textStr = "[c]" .. textStr
		self.m_DetailsProp[v[2]]:SetText(textStr)
	end

	local startBoxList = self.m_StartGrid:GetChildList()
	local startBox = nil
	for i=1,5 do
		if i > #startBoxList then
			startBox = self.m_StartClone:Clone()
			self.m_StartGrid:AddChild(startBox)
			startBox:SetActive(true)
		else
			startBox = startBoxList[i]
		end
		startBox:SetGrey(i > self.m_PartnerData.upper)
	end
end

function CPartnerCultureBox.GetPartnerScore(self)
	local quality = 1
	local upper = 1
	local grade = 1
	local lvSum = 0
	quality = self.m_PartnerData.quality
	upper = self.m_PartnerData.upper
	grade = self.m_PartnerData.grade
	local skillList = self.m_PartnerData.skill
	for _,v in ipairs(skillList) do
		lvSum = lvSum + v.level
	end
	local qualityRatio = DataTools.GetPartnerQualityInfo(quality).factor
	local upperRatio = DataTools.GetPartnerUpperInfo(upper).factor
	local score = 1.5*grade*qualityRatio + 150*upperRatio + 200*lvSum
	return Mathf.Floor(score)
end

function CPartnerCultureBox.ResetSkillGrid(self)
	local skillBoxList = self.m_SkillBoxGrid:GetChildList()
	local skillInfoList = g_PartnerCtrl:GetPartnerSkillInfoList(self.m_PartnerInfo.id)
	for i,v in ipairs(skillInfoList) do
		local oSkillBox = nil
		if i > #skillBoxList then
			oSkillBox = self.m_SkillBoxClone:Clone()
			oSkillBox.m_Icon = oSkillBox:NewUI(1, CSprite)
			oSkillBox.m_Lv = oSkillBox:NewUI(2, CLabel)
			oSkillBox.m_Tip = oSkillBox:NewUI(3, CSprite)
			oSkillBox.m_Bg = oSkillBox:NewUI(4, CSprite)
			self.m_SkillBoxGrid:AddChild(oSkillBox)
		else
			oSkillBox = skillBoxList[i]
		end
		local skillInfo = DataTools.GetPartnerSpecialSkill(v.sk)
		local bgSprName = skillInfo.protect == 0 and "h7_weupinkuang" or "h7_weupinkuang1"
		oSkillBox.m_Bg:SetSpriteName(bgSprName)
		oSkillBox.m_Bg:MakePixelPerfect()
		oSkillBox.m_Icon:SpriteSkill(skillInfo.icon)
		local skillData = self:GetPartnerSkillData(v.sk)
		oSkillBox.m_Lv:SetText(skillData and "Lv." .. skillData.level or "")
		oSkillBox.m_Tip:SetActive(not skillData)
		oSkillBox:AddUIEvent("click", function ()
			local dConfig = table.copy(skillInfo)
			dConfig.widget = oSkillBox
			g_WindowTipCtrl:SetWindowSkillTip(dConfig)
		end)
		oSkillBox:SetActive(true)
	end
	for i=#skillInfoList+1,#skillBoxList do
		skillBoxList[i]:SetActive(false)
	end
	self.m_SkillBoxGrid:Reposition()
	self.m_SkillBoxScroll:ResetPosition()
end

function CPartnerCultureBox.GetPartnerSkillData(self, skillID)
	local skillList = self.m_PartnerData.skill
	for _,v in ipairs(skillList) do
		if v.sk == skillID then
			return v
		end
	end
end

return CPartnerCultureBox
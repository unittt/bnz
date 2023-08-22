local CPartnerCultureSuccessBox = class("CPartnerCultureSuccessBox", CBox)

function CPartnerCultureSuccessBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_PartnerModeTexture = self:NewUI(1, CActorTexture)
	self.m_NameL = self:NewUI(2, CLabel)
	self.m_StarGrid = self:NewUI(3, CGrid)
	self.m_StarSprClone = self:NewUI(4, CSprite)
	self.m_OldSkillLvL = self:NewUI(5, CLabel)
	self.m_NewSkillLvL = self:NewUI(6, CLabel)
	self.m_AttrBox = self:NewUI(7, CBox) 

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "SetActive", false))

	self.m_AttrList = {
		{"气血", "max_hp",},	
		{"法力", "max_mp",},
		{"物攻", "phy_attack"},
		{"物防", "phy_defense"},
		{"治疗", "cure_power"},
		{"法攻", "mag_attack"},
		{"法防", "mag_defense"},
		{"速度", "speed"},
	}

	for i,v in ipairs(self.m_AttrList) do
		self.m_AttrBox[v[2]] = self.m_AttrBox:NewUI(i, CLabel) 
		self.m_AttrBox[v[2].."_up"] = self.m_AttrBox:NewUI(i + 8, CLabel) 
	end
end

function CPartnerCultureSuccessBox.SetPartnerCultureSuccessBoxInfo(self, cultureInfo)
	printc("SetPartnerCultureSuccessBoxInfo")
	table.print(cultureInfo)
	self.m_CultureInfo = cultureInfo
	local showBox = cultureInfo.cultureType > 0
	self:SetActive(showBox)
	if showBox then
		self:RefreshBaseInfo()
		self:RefreshAttrInfo()
	end
end

function CPartnerCultureSuccessBox.RefreshBaseInfo(self)
	self.m_PartnerModeTexture:ChangeShape({shape = self.m_CultureInfo.partnerData.model_info.shape})
	local function playSound()
		local partnerInfo = DataTools.GetPartnerInfo(self.m_CultureInfo.partnerData.sid)
		local path = DataTools.GetAudioSound(partnerInfo.sound)
		g_AudioCtrl:NpcPath(path)
	end
	self.m_PartnerModeTexture:SetClickCallback(playSound)

	local iGrade = self.m_CultureInfo.partnerData.grade
	local sName = self.m_CultureInfo.partnerData.name
	self.m_NameL:SetText(string.format("%d级 %s", iGrade, sName))

	local dSkill = g_PartnerCtrl:GetPartnerProtectSkill(self.m_CultureInfo.partnerid)
	local skillInfo = DataTools.GetPartnerSpecialSkill(dSkill.sk)
	self.m_OldSkillLvL:SetText(dSkill.level - 1)
	self.m_NewSkillLvL:SetText(dSkill.level)

	local iStarCnt = self.m_CultureInfo.partnerData.quality
	local starBoxList = self.m_StarGrid:GetChildList()
	local oStarSpr = nil
	for i=1,5 do
		if i > #starBoxList then
			oStarSpr = self.m_StarSprClone:Clone()
			self.m_StarGrid:AddChild(oStarSpr)
			oStarSpr:SetActive(true)
		else
			oStarSpr = starBoxList[i]
		end
		oStarSpr:SetGrey(i > iStarCnt)
	end
end

function CPartnerCultureSuccessBox.RefreshAttrInfo(self)
	for i,v in ipairs(self.m_AttrList) do
		local iUpValue = self.m_CultureInfo.offsetData[v[2]] or 0
		local sText = string.format("%s %d", v[1], self.m_CultureInfo.partnerData[v[2]])
		self.m_AttrBox[v[2]]:SetText(sText)
		if iUpValue > 0 then
			local sText = "#I+#n "..iUpValue
			self.m_AttrBox[v[2].."_up"]:SetText(sText)
		else
			self.m_AttrBox[v[2].."_up"]:SetText("")
		end
		if i == 8 then
			break
		end
	end
end

return CPartnerCultureSuccessBox
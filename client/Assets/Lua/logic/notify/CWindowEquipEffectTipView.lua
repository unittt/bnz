local CWindowEquipEffectTipView = class("CWindowEquipEffectTipView", CViewBase)

function CWindowEquipEffectTipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/WindowEquipEffectTipView.prefab", cb)
	self.m_DepthType = "Dialog"
	-- self.m_ExtendClose = "ClickOut"
end

function CWindowEquipEffectTipView.OnCreateView(self)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_DescLabel = self:NewUI(2, CLabel)
	self.m_TipWidget = self:NewUI(3, CWidget)
	self.m_SkillSpr = self:NewUI(4, CSprite)
	self.m_Level = self:NewUI(5, CLabel)

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CWindowEquipEffectTipView.SetWindowEffectTipInfo(self, iEffectId, bIsSkill)
	local tData = nil
	-- if bIsSkill then
	-- 	tData = data.skilldata.SPECIAL_SKILL[tonumber(iEffectId)]
	-- else
	if iEffectId == 8501 then
		tData = data.skilldata.MARRY[tonumber(iEffectId)]
	else
		tData = data.skilldata.SPECIAL_EFFC[tonumber(iEffectId)]
	end
	-- end
	self.m_NameLabel:SetText(tData.name)
	self.m_DescLabel:SetText(tData.desc)
	self.m_SkillSpr:SpriteMagic(tData.icon)
	-- if tData.skill then
	-- 	self.m_Level:SetActive(true)
	-- 	local tLevel = "等级: "..tData.skill
	-- 	self.m_Level:SetText(tLevel)
	-- end
end

-- 宠物装备
function CWindowEquipEffectTipView.SetSummonSkillTipInfo(self, iSkill)
	local dConfig = SummonDataTool.GetSummonSkillInfo(iSkill)
	if dConfig then
		self.m_NameLabel:SetText(dConfig.name)
		self.m_DescLabel:SetText(dConfig.des)
		self.m_SkillSpr:SpriteSkill(dConfig.iconlv[1].icon)
	end
end

return CWindowEquipEffectTipView
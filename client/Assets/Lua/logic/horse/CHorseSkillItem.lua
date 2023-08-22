local CHorseSkillItem = class("CHorseSkillItem", CBox)

function CHorseSkillItem.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)

end

function CHorseSkillItem.SetInfo(self, skillInfo)

	self.m_SkillInfo = skillInfo

	local config = skillInfo.config

	self.m_Icon:SpriteSkill(tostring(config.icon))
	self.m_Icon:SetActive(true)

end

function CHorseSkillItem.GetInfo(self)
	
	return self.m_SkillInfo

end

return CHorseSkillItem
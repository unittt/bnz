local CJjcGroupBox = class("CJjcGroupBox", CBox)

--竞技场挑战界面的Box
function CJjcGroupBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSp = self:NewUI(1, CSprite)
	self.m_LevelLbl = self:NewUI(2, CLabel)
	self.m_NameLbl = self:NewUI(3, CLabel)
	self.m_FightValueLbl = self:NewUI(4, CLabel)
end

function CJjcGroupBox.SetContent(self, oData)
	self:SetActive(false)
	-- self.m_IconSp:SpriteAvatar(oData.icon)
	-- self.m_LevelLbl:SetText("Lv."..oData.grade)
	-- self.m_NameLbl:SetText(oData.name)
	-- self.m_FightValueLbl:SetText(oData.fight_power)
end

return CJjcGroupBox
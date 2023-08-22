local CTongYuSummonSkillTip = class("CTongYuSummonSkillTip", CBox)

function CTongYuSummonSkillTip.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Name =  self:NewUI(1, CLabel)
    self.m_Lv =  self:NewUI(2, CLabel)
    self.m_Des =  self:NewUI(3, CLabel)
    self.m_Quality =  self:NewUI(4, CSprite)
    self.m_Icon =  self:NewUI(5, CSprite)

end

function CTongYuSummonSkillTip.SetInfo(self, id)

	self.m_Id = id
    local summonSkillInfo = data.summondata.SKILL[id]
    if summonSkillInfo then 
        self.m_Icon:SpriteSkill(summonSkillInfo.iconlv[1].icon)
        local quality = summonSkillInfo.quality
        self.m_Quality:SetItemQuality(quality)
        self.m_Name:SetText(summonSkillInfo.name)
        self.m_Des:SetText(summonSkillInfo.des)
    end 

end

return CTongYuSummonSkillTip
local CSummonLinkRPart = class("CSummonLinkRPart", CBox)

function CSummonLinkRPart.ctor(self, obj)
    CBox.ctor(self, obj)

    self:InitContent()
end

function CSummonLinkRPart.InitContent(self)
    self.m_SkillBox = self:NewUI(1, CSummonSkillBox)
    self.m_AptiBox = self:NewUI(2, CSummonAptiBox)
    self.m_EquipedBox = self:NewUI(3, CSummonViewEquipBox)
    self.m_AptiBox:InitSliderUI()
end

function CSummonLinkRPart.SetInfo(self, info)
    self.m_AptiBox:SetInfo(info)
    local skills = SummonDataTool.GetSkillInfo(info)
    self.m_SkillBox:SetInfo(skills)
    self.m_EquipedBox:SetInfo(info)
end

return CSummonLinkRPart
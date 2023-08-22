local CSchoolItem = class("CSchoolItem", CBox)

function CSchoolItem.ctor(self, obj)
    CBox.ctor(self, obj)
    
    self.m_SchoolSprite = self:NewUI(1, CSprite)
    self.m_SchoolLabel = self:NewUI(2, CLabel)
    self.m_ChooseSprite = self:NewUI(3, CSprite)
    self.m_DescLbl = self:NewUI(4, CLabel)
    self.m_OpenObject = self:NewUI(5, CObject)
    self.m_NotOpenObject = self:NewUI(6, CObject)
end

function CSchoolItem.SetBoxInfo(self, schoolID)
    if schoolID == -1 then
        self.m_OpenObject:SetActive(false)
        self.m_NotOpenObject:SetActive(true)
    else
        self.m_OpenObject:SetActive(true)
        self.m_NotOpenObject:SetActive(false)
        -- 门派图标\名称
        self.m_SchoolSprite:SpriteSchool(schoolID + 500)
        local schoolInfo = DataTools.GetSchoolInfo(schoolID)
        self.m_SchoolLabel:SetText(schoolInfo.name)
        self.m_DescLbl:SetText(schoolInfo.desc)
    end
end

return CSchoolItem
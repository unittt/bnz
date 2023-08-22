local CJieBaiTeamActivityItem = class("CJieBaiTeamActivityItem", CBox)

function CJieBaiTeamActivityItem.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Des = self:NewUI(1, CLabel)
    self.m_AgreeBtn = self:NewUI(2, CSprite)
    self.m_DisgreeBtn = self:NewUI(3, CSprite)
    self.m_CheckBtn = self:NewUI(4, CSprite)
    self.m_Time = self:NewUI(5, CLabel)

    self:InitContent()

end

function CJieBaiTeamActivityItem.InitContent(self)
    -- body
end

function CJieBaiTeamActivityItem.SetInfo(self)
    
    

end

return CJieBaiTeamActivityItem
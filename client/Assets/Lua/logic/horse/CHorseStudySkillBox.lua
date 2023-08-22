local CHorseStudySkillBox = class("CHorseStudySkillBox", CBox)

function CHorseStudySkillBox.ctor(self, obj)
	CBox.ctor(self, obj)
    self.m_Icon = self:NewUI(1, CSprite)
    self.m_Name = self:NewUI(2, CLabel)
    self.m_Mask = self:NewUI(4, CSprite)

    self.m_Id = nil

    self.m_Icon:AddUIEvent("click", callback(self, "OnClickIcon"))

end

function CHorseStudySkillBox.SetInfo(self, info)

	self.m_Id = info.id
    self.m_Icon:SpriteSkill(tostring(info.icon))
    self.m_Name:SetText(info.name)

end

function CHorseStudySkillBox.ShowMask(self, isShow)
    
    self.m_Mask:SetActive(isShow)

end

function CHorseStudySkillBox.OnClickIcon(self)
	
    local args = {
        widget= self,
        side = enum.UIAnchor.Side.Left,
        skId = self.m_Id
    }
     g_WindowTipCtrl:SetWindowHorseSkillTip(args)

end

return CHorseStudySkillBox
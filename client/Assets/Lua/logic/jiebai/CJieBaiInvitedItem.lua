local CJieBaiInvitedItem = class("CJieBaiInvitedItem", CBox)

function CJieBaiInvitedItem.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Icon = self:NewUI(1, CSprite)
    self.m_RemoveBtn = self:NewUI(2, CSprite)
    self.m_Lv = self:NewUI(3, CLabel)
    self.m_Name = self:NewUI(4, CLabel)
    self.m_SchoolSprite = self:NewUI(5, CSprite)
    self.m_FriendShip = self:NewUI(6, CLabel)
    self.m_State = self:NewUI(7, CSprite)

end

function CJieBaiInvitedItem.SetInfo(self, info)
    
    local icon = info.icon
    local name = info.name
    local lv = info.lv
    local friendShip = info.friendShip
    local school = info.school
    local state = info.state
    self.m_Info = info
    self.m_Pid = info.pid
    self.m_Icon:SpriteAvatar(icon)
    self.m_Name:SetText(name)
    self.m_Lv:SetText(lv)
    self.m_SchoolSprite:SpriteSchool(school)

    local stateName = state == 1 and "h7_yijieshou" or "h7_querenzhong"
    self.m_State:SetSpriteName(stateName)

    self.m_Icon:SetGrey(not g_JieBaiCtrl:IsInviterOnLine(info.pid))

end

return CJieBaiInvitedItem
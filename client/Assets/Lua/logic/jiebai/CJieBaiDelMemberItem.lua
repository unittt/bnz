local CJieBaiDelMemberItem = class("CJieBaiDelMemberItem", CBox)

function CJieBaiDelMemberItem.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Icon = self:NewUI(1, CSprite)
    self.m_DelBtn = self:NewUI(2, CSprite)
    self.m_Lv = self:NewUI(3, CLabel)
    self.m_Name = self:NewUI(4, CLabel)
    self.m_SchoolSprite = self:NewUI(5, CSprite)
    self.m_FriendShip = self:NewUI(6, CLabel)

    self:InitContent()

end

function CJieBaiDelMemberItem.InitContent(self)

    self.m_DelBtn:AddUIEvent("click", callback(self, "OnClickDelBtn"))

end

function CJieBaiDelMemberItem.SetInfo(self, info, cb)
    
    local icon = info.icon
    local name = info.name
    local lv = info.lv
    local friendShip = info.friendShip
    local school = info.school
    self.m_Pid = info.pid

    self.m_Icon:SpriteAvatar(icon)
    self.m_Name:SetText(name)
    self.m_Lv:SetText(lv)
    self.m_FriendShip:SetText("好友度:" .. friendShip)
    self.m_SchoolSprite:SpriteSchool(school)

    self.m_Cb = cb

end

function CJieBaiDelMemberItem.OnClickDelBtn(self)
     
    g_JieBaiCtrl:C2GSJBKickMember(self.m_Pid)

    if self.m_Cb then 
        self.m_Cb()
    end 

end

return CJieBaiDelMemberItem
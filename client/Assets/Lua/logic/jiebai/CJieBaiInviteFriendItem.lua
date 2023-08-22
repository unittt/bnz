local CJieBaiInviteFriendItem = class("CJieBaiInviteFriendItem", CBox)

function CJieBaiInviteFriendItem.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Icon = self:NewUI(1, CSprite)
    self.m_InviteBtn = self:NewUI(2, CSprite)
    self.m_Lv = self:NewUI(3, CLabel)
    self.m_Name = self:NewUI(4, CLabel)
    self.m_SchoolSprite = self:NewUI(5, CSprite)
    self.m_FriendShip = self:NewUI(6, CLabel)
    self.m_InviteBtnText = self:NewUI(7, CLabel)

    self:InitContent()

end

function CJieBaiInviteFriendItem.InitContent(self)

    self.m_InviteBtn:AddUIEvent("click", callback(self, "OnClickInvite"))

end

function CJieBaiInviteFriendItem.SetInfo(self, pid, cb)

    local frdobj = g_FriendCtrl:GetFriend(pid)
    if frdobj then 
        self.m_Pid = pid
        local name = frdobj.name
        local icon = frdobj.icon
        local lv = frdobj.grade
        local friendShip = frdobj.friend_degree
        local school = frdobj.school
        self.m_Icon:SpriteAvatar(icon)
        self.m_Name:SetText(name)
        self.m_Lv:SetText(lv)
        self.m_FriendShip:SetText("好友度:" .. friendShip)
        self.m_SchoolSprite:SpriteSchool(school)
        self.m_Cb = cb
    end

end

function CJieBaiInviteFriendItem.OnClickInvite(self)
      
    g_JieBaiCtrl:C2GSJBInvite(self.m_Pid)

    if self.m_Cb then 
        self.m_Cb()
    end 

end

return CJieBaiInviteFriendItem
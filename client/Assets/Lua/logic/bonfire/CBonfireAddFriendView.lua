local CBonfireAddFriendView = class("CBonfireAddFriendView", CViewBase)

function CBonfireAddFriendView.ctor(self, cb)
	CViewBase.ctor(self, "UI/bonfire/BonfireAddFriendView.prefab", cb)
	self.m_GroupName = "sub"
	self.m_ExtendClose = "Black"
end

function CBonfireAddFriendView.OnCreateView(self)
    self.m_HintLabel = self:NewUI(1, CLabel)
    self.m_CancelBtn = self:NewUI(2, CButton)
    self.m_SureBtn = self:NewUI(3, CButton)
    self.m_CloseBtn = self:NewUI(4, CButton)
    self:InitContent()
end

function CBonfireAddFriendView.InitContent(self)
    self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_SureBtn:AddUIEvent("click", callback(self, "OnAddFriend"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CBonfireAddFriendView.SetInfo(self, info)
    self.m_PlayerInfo = info
    self.m_HintLabel:SetText("[008585FF]【"..info.name.."】[-][896055FF]在活动中频频和你互动，是否加为好友深入交流。[-]")
end

function CBonfireAddFriendView.OnAddFriend(self)
	netfriend.C2GSApplyAddFriend(self.m_PlayerInfo.pid)
    self:OnClose()
end

function CBonfireAddFriendView.OnClose(self)
    local count = #g_BonfireCtrl.m_AddFriendList
    if count > 0 then
        self:SetInfo(g_BonfireCtrl.m_AddFriendList[1])
        table.remove(g_BonfireCtrl.m_AddFriendList, 1)
        return
    end
    self:CloseView()
end

return CBonfireAddFriendView
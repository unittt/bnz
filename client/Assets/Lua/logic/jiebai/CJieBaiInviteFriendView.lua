local CJieBaiInviteFriendView = class("CJieBaiInviteFriendView", CViewBase)

function CJieBaiInviteFriendView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiInviteFriendView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"

end

function CJieBaiInviteFriendView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_Grid = self:NewUI(2, CGrid)
    self.m_Item = self:NewUI(3, CJieBaiInviteFriendItem)
    self.m_TipNode = self:NewUI(4, CObject)
    self.m_Des = self:NewUI(5, CLabel)

    self:InitContent()

end

function CJieBaiInviteFriendView.QureyInvitesInfo(self)
    self.m_FriendList = g_JieBaiCtrl:GetValidInviterList()
    -- 获取最新好友信息
    if self.m_FriendList and #self.m_FriendList > 0 then
        g_FriendCtrl:QueryFriend(self.m_FriendList)
        g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendCtrlEvent"))
    else
        self:RefreshAll()
    end
end

function CJieBaiInviteFriendView.InitContent(self)
  
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_JieBaiCtrl:QureyValidInviter(function ()
        self:QureyInvitesInfo()
    end)

end

function CJieBaiInviteFriendView.RefreshAll(self)
    self:RefreshInviteList()
    self:RefreshNode()
    self:RefreshDes()
end

function CJieBaiInviteFriendView.RefreshDes(self)
    
    local tip = g_JieBaiCtrl:GetTextTip(1087)
    local friendShip = data.huodongdata.JIEBAI_CONFIG[1].friend_degree
    tip = string.gsub(tip, "#cunt", friendShip)
    self.m_Des:SetText(tip)

end

function CJieBaiInviteFriendView.RefreshInviteList(self)
    self.m_Grid:HideAllChilds()
    for k, pid in ipairs(self.m_FriendList) do 
        local item = self.m_Grid:GetChild(k)
        if item == nil then
            item = self.m_Item:Clone() 
            item:SetActive(true)
            self.m_Grid:AddChild(item)  
        end
        item:SetActive(true)
        item:SetInfo(pid, callback(self, "OnClickItem"))
    end 

end

function CJieBaiInviteFriendView.OnClickItem(self)
    
    self:OnClose()

end

function CJieBaiInviteFriendView.RefreshNode(self)
    
    self.m_TipNode:SetActive(not self.m_FriendList or not next(self.m_FriendList))

end

function CJieBaiInviteFriendView.OnFriendCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Friend.Event.Update then
        self:RefreshAll()
    end
end

return CJieBaiInviteFriendView
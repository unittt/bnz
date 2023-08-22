local CMarryXTFriendListView = class("CMarryXTFriendListView", CViewBase)

function CMarryXTFriendListView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Marry/MarryXTFriendListView.prefab", cb)
    self.m_DepthType = "Dialog"

    self.m_CurSelBox = nil
    self.m_ExtendClose = "ClickOut"
    self.m_IsPresentDirect = false
    self.m_Amount = 0
end

function CMarryXTFriendListView.OnCreateView(self)
    self.m_PlayerBox = self:NewUI(1, CBox)
    self.m_ComfirmBtn = self:NewUI(2, CButton)
    self.m_ScrollView = self:NewUI(3, CScrollView)
    self.m_Grid = self:NewUI(4, CGrid)
    self.m_PlayerBox:SetActive(false)
    self.m_ComfirmBtn:AddUIEvent("click", callback(self, "OnClickComfirm"))
end

function CMarryXTFriendListView.RefreshFriends(self, iAmount, bDirect)
    self.m_IsPresentDirect = bDirect
    self.m_Amount = iAmount
    local lFriend = g_FriendCtrl:GetMyFriend()
    self.m_Grid:HideAllChilds()
    -- local iAddPt = iAmount * 30
    table.sort(lFriend, g_FriendCtrl.Sort)
    for i, v in ipairs(lFriend) do
        local dFriend = g_FriendCtrl:GetFriend(v)
        local oBox = self:GetPlayerBox(i)
        oBox.pid = dFriend.pid
        oBox.name = dFriend.name
        oBox.playerIcon:SpriteAvatar(dFriend.icon)
        oBox.lvL:SetText(dFriend.grade.."级")
        oBox.friendDegreeL:SetText(string.format("[af302a]%d[-]", dFriend.friend_degree))
        -- oBox.friendDegreeL:SetText(string.format("[af302a]%d[-][1d8e00]+%d[-]", dFriend.friend_degree, iAddPt))
        oBox.nameL:SetText(dFriend.name)
        if i == 1 then
            self:OnClickPlayer(oBox)
        else
            oBox.selSpr:SetActive(false)
        end
    end
    if bDirect then
        self.m_BehidLayer:SetActive(false)
    end
end

function CMarryXTFriendListView.GetPlayerBox(self, idx)
    local oBox = self.m_Grid:GetChild(idx)
    if not oBox then
        oBox = self.m_PlayerBox:Clone()
        self.m_Grid:AddChild(oBox)
        oBox.playerIcon = oBox:NewUI(1, CSprite)
        oBox.lvL = oBox:NewUI(2, CLabel)
        oBox.nameL = oBox:NewUI(3, CLabel)
        oBox.friendDegreeL = oBox:NewUI(4, CLabel)
        oBox.selSpr = oBox:NewUI(5, CSprite)
        oBox:AddUIEvent("click", callback(self, "OnClickPlayer", oBox))
    end
    oBox:SetActive(true)
    return oBox
end

function CMarryXTFriendListView.OnClickPlayer(self, oBox)
    if oBox == self.m_CurSelBox then return end
    if self.m_CurSelBox then
        self.m_CurSelBox.selSpr:SetActive(false)
    end
    oBox.selSpr:SetActive(true)
    self.m_CurSelBox = oBox
end

function CMarryXTFriendListView.OnClickComfirm(self)
    local oBox = self.m_CurSelBox
    if not oBox then
        g_NotifyCtrl:FloatMsg("请选择赠送人")
        return
    end
    local iPid, sName = oBox.pid, oBox.name
    if self.m_IsPresentDirect then
        g_MarryCtrl:ShowXTComfirm({
            amount = self.m_Amount,
            name = oBox.name,
            pid = oBox.pid,
            cb = callback(self, "OnClose")
        })
    else
        g_MarryCtrl:OnEvent(define.Engage.Event.SelectXTPresentPlayer, iPid)
        self:OnClose()
    end
end

function CMarryXTFriendListView.OnClose(self)
    if self.m_IsPresentDirect then
        CMarryXTGiftView:CloseView()
    end
    self:CloseView()
end

return CMarryXTFriendListView
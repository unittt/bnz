local CBriefView = class("CBriefView", CBox)

local MenuTab = {
    CURBTN = nil,
    FRIEND = "friend",
    MAIL = "mail",
    RECENT = "recent",
}

function CBriefView.ctor(self, obj, cb, cb2)
    CBox.ctor(self, obj)
    self.m_FriendTabBtn = self:NewUI(1, CButton, true, false)
    self.m_MailTabBtn = self:NewUI(2, CButton, true, false)
    self.m_FriendPart = self:NewPage(3, CFriendPart)
    self.m_MailPart = self:NewPage(4, CMailPart)
    self.m_UnopenedMailNumSprite = self:NewUI(5, CSprite)
    self.m_UnopenedMailNumLabel = self:NewUI(6, CLabel)
    self.m_TalkPart = self:NewPage(7, CTalkPart)
    self.m_RecentPart = self:NewPage(8, CRecentPart)
    self.m_RecentTabBtn = self:NewUI(9, CButton, true, false)
    self.m_MsgAmountBtn = self:NewUI(10, CButton, true, false)
    self.m_TeamerPart = self:NewPage(11, CTeamerPart)
    self.m_BlackPart = self:NewPage(12, CBlackPart)
    self.m_BlackFriendBtn = self:NewUI(13, CButton)
    self.m_HomeBtn = self:NewUI(14, CButton)
    self.m_AddFriendBtn = self:NewUI(15, CButton)
    self.m_TeamerBtn = self:NewUI(16, CButton)
    self.m_BottomGo = self:NewUI(17, CObject)
    self.m_SysSettingBtn = self:NewUI(18, CButton)
    
    self.m_FriendInfoView = cb()
    self.m_DetailContainer = cb2()
    self:InitContent()
end

function CBriefView.InitContent(self)
    self.m_RecentTabBtn:SetSelected(true)
    -- listeners
    self.m_FriendTabBtn:AddUIEvent("click", callback(self, "SetTab", MenuTab.FRIEND))
    self.m_MailTabBtn:AddUIEvent("click", callback(self,"SetTab", MenuTab.MAIL))
    self.m_RecentTabBtn:AddUIEvent("click", callback(self,"SetTab", MenuTab.RECENT))
    self.m_BlackFriendBtn:AddUIEvent("click", callback(self, "GetBalckFriend"))
    self.m_HomeBtn:AddUIEvent("click", callback(self, "OnHome"))
    self.m_AddFriendBtn:AddUIEvent("click", callback(self, "AddFriend"))
    self.m_TeamerBtn:AddUIEvent("click", callback(self, "GetTeamer"))
    self.m_SysSettingBtn:AddUIEvent("click", callback(self, "OnClickSysSetting"))
    g_TalkCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMailEvent"))
    -- 好友 / 邮件设置单选状态
    self.m_FriendTabBtn:SetGroup(self:GetInstanceID())
    self.m_MailTabBtn:SetGroup(self:GetInstanceID())
    self.m_RecentTabBtn:SetGroup(self:GetInstanceID())
    self.m_BlackFriendBtn:SetGroup(self:GetInstanceID())
    self.m_TeamerBtn:SetGroup(self:GetInstanceID())
    self:RefreshNotify()
    self:UpdateUnopenedMailNum()
end

--协议通知返回
function CBriefView.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Talk.Event.AddNotify then
        self:RefreshNotify(oCtrl.m_EventData)
    elseif oCtrl.m_EventID == define.Talk.Event.DelNotify then
        --阅读对应pid的消息之后，删除消息通知返回
        self:RefreshNotify(oCtrl.m_EventData)
    elseif oCtrl.m_EventID == define.Talk.Event.AddMsg then
        if self.m_RecentPart:IsShow() then
            self:ShowRecent()
        end
    end
end

--打开好友界面的通用接口
function CBriefView.ShowFriend(self)
    self.m_BottomGo:SetActive(true)
    self.m_TalkPart.m_DelTalkToTab = 1
    self.m_FriendTabBtn:SetSelected(true)
    self:ShowSubPage(self.m_FriendPart)
    self.m_FriendPart:InitContent()
    g_MailCtrl:OnEvent(define.Mail.Event.OpenMails) -- 通知主界面邮件按钮是否显示
end

--打开最近联系人界面的通用接口
function CBriefView.ShowRecent(self)
    self.m_BottomGo:SetActive(true)
    self.m_TalkPart.m_DelTalkToTab = 0
    --暂时屏蔽一条消息打开聊天界面
    -- if g_TalkCtrl:GetRecentTalkRoleCount() == 1 then
    --     local pid = g_TalkCtrl:GetRecentTalk()
    --     if g_TalkCtrl:GetTotalNotify() and pid then
    --         CFriendInfoView:ShowView(function (oView)
    --         oView:ShowTalk(pid)
    --         end)
    --     end
    -- else 
    --     self:ShowSubPage(self.m_RecentPart)
    --     self.m_RecentPart:InitContent()
    -- end
    self:ShowSubPage(self.m_RecentPart)
    self.m_RecentPart:InitContent()
    self.m_RecentTabBtn:SetSelected(true)
    
    local oView = CMainMenuView:GetView()
    oView.m_RB.m_QuickMsgBox:RefreshFriendMsgBtn(false)
end

--打开最近队伍界面的通用接口
function CBriefView.ShowTeamer(self)
    -- if #g_FriendCtrl:GetTeamerFriend() <= 0 then
    --     g_NotifyCtrl:FloatMsg("暂时没有队友信息，快加入队伍吧")
    -- else
    self.m_BottomGo:SetActive(true)
    self:ShowSubPage(self.m_TeamerPart)
    self.m_TeamerPart:InitContent()
    -- end
end

--打开黑名单界面的通用接口
function CBriefView.ShowBlack(self)
    -- if #g_FriendCtrl:GetBlackList() <= 0 then
    --     g_NotifyCtrl:FloatMsg("暂时没有黑名单成员")
    -- else
    self.m_BottomGo:SetActive(true)
    self:ShowSubPage(self.m_BlackPart)
    self.m_BlackPart:InitContent()
    -- end
end

--打开好友或陌生人聊天界面的通用接口，传一个pid
function CBriefView.ShowTalk(self, pid)
    self.m_BottomGo:SetActive(false)
    self:ShowSubPage(self.m_TalkPart)
    self.m_TalkPart:SetPlayer(pid)
    local oView = CMainMenuView:GetView()
    oView.m_RB.m_QuickMsgBox:RefreshFriendMsgBtn(false)
    g_MailCtrl:OnEvent(define.Mail.Event.OpenMails) -- 通知主界面邮件按钮是否显示
end

--打开邮件界面的通用接口
function CBriefView.ShowMail(self)
    self.m_BottomGo:SetActive(false)
    self:ShowSubPage(self.m_MailPart)
    self.m_MailTabBtn:SetSelected(true)
end

--隐藏聊天界面
function CBriefView.ClosePart(self)
    self.m_TalkPart:HidePage()
end

--点击最近联系人、好友、邮件tab
function CBriefView.SetTab(self, sTab)
    if sTab == MenuTab.FRIEND then
        self:ShowFriend()
        g_MailCtrl:CloseMail()
    elseif sTab == MenuTab.MAIL then
        self:ShowMail()
    elseif sTab == MenuTab.RECENT then
        -- printc("发来消息的最近联系人的数量"..g_TalkCtrl:GetRecentTalkRoleCount())
        self:ShowRecent()
        g_MailCtrl:CloseMail()
    end
    self:UpdateUnopenedMailNum()
    MenuTab.CURBTN = sTab
end

--打开黑名单界面
function CBriefView.GetBalckFriend(self)
    self:ShowBlack()
end

--打开主页界面
function CBriefView.OnHome(self)
    
end

--打开添加推荐好友界面
function CBriefView.AddFriend(self)
    CFindFrdView:ShowView()
end

--打开最近队伍界面
function CBriefView.GetTeamer(self)
    self:ShowTeamer()
end

function CBriefView.OnClickSysSetting(self)
    CFriendFilterView:ShowView()
end

--邮件更新ui相关
function CBriefView.UpdateUnopenedMailNum(self)
    -- 全部邮件 >= 100，满
    -- 0 不显示
    -- 0 < 未读邮件 < 100，显示未读

    local numMail = g_MailCtrl:GetMailsNum()
    if numMail >= 100 then
        self.m_UnopenedMailNumSprite:SetActive(true)
        self.m_UnopenedMailNumLabel:SetText("满")
        return
    end

    local nUnopenedNum = g_MailCtrl:GetUnOpenedMailsNum()
    if nUnopenedNum <= 0 then
        self.m_UnopenedMailNumSprite:SetActive(false)
        return
    end
    if nUnopenedNum <= 99 then
        self.m_UnopenedMailNumSprite:SetActive(true)
        self.m_UnopenedMailNumLabel:SetText(nUnopenedNum)
    end
end

function CBriefView.OnMailEvent(self)
    self:UpdateUnopenedMailNum()
end

--阅读对应pid的消息之后，删除消息通知返回，更新联系人tab里面的消息通知ui
function CBriefView.RefreshNotify(self, pid)
    local iAmount = g_TalkCtrl:GetTotalNotify()
    if pid then
        self.m_RecentPart:RefreshNotify(pid)
    end
    if iAmount > 0 then
        self.m_MsgAmountBtn:SetActive(true)
        self.m_MsgAmountBtn:SetText(iAmount)
    else
        self.m_MsgAmountBtn:SetActive(false)
    end
end

return CBriefView
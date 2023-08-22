local CJieBaiTeamView = class("CJieBaiTeamView", CViewBase)

function CJieBaiTeamView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiTeamView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"

end

function CJieBaiTeamView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_DeclarationTip = self:NewUI(2, CSprite)
    self.m_DeclarationInput = self:NewUI(3, CInput)
    self.m_JieYiValue = self:NewUI(4, CLabel)
    self.m_TitleBtn = self:NewUI(5, CSprite)
    self.m_Title = self:NewUI(6, CLabel)
    self.m_CutBtn = self:NewUI(7, CSprite)
    self.m_InviteBtn = self:NewUI(8, CSprite)
    self.m_RemoveBtn = self:NewUI(9, CSprite)
    self.m_MemberGrid = self:NewUI(10, CGrid)
    self.m_MemberItem = self:NewUI(11, CJieBaiTeamMemberItem)
    self.m_TipNode = self:NewUI(12, CObject)
    self.m_ActivityGrid = self:NewUI(13, CGrid)
    self.m_ActivityItem = self:NewUI(14, CJieBaiVoteActivity)
    self.m_CutBtnText = self:NewUI(15, CLabel)
    self.m_InviteActivity = self:NewUI(16, CJieBaiInviteActivity)

    self.m_ActivityList = {}

    self:InitContent()

end


function CJieBaiTeamView.InitContent(self)
    
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_DeclarationInput:AddUIEvent("click", callback(self, "OnClickDeclaration"))
    self.m_DeclarationTip:AddUIEvent("click", callback(self, "OnClickDeclarationTip"))
    self.m_TitleBtn:AddUIEvent("click", callback(self, "OnClickTitleBtn"))

    self.m_CutBtn:AddUIEvent("click", callback(self, "OnClickCutBtn"))
    self.m_InviteBtn:AddUIEvent("click", callback(self, "OnClickInviteBtn"))
    self.m_RemoveBtn:AddUIEvent("click", callback(self, "OnClickRemoveBtn"))

    g_JieBaiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnJieBaiEvent"))

    g_JieBaiCtrl:ResetKickRedPoint()

    self:RefreshAll()

end

function CJieBaiTeamView.RefreshAll(self)
   
   self:RefreshDeclaration()
   self:RefreshTitle()
   self:RefreshJieYiValue()
   self:RefreshMemberList()
   self:RefreshActivity()
   self:RefreshAllBtns()
   self:RefreshTitleBtn()
   self:RefreshTip()

end

function CJieBaiTeamView.RefreshTip(self)
    
    self.m_TipNode:SetActive(not next(self.m_ActivityList))

end

function CJieBaiTeamView.RefreshTitleBtn(self)

    local isSponsor = g_JieBaiCtrl:IsJieBaiSponsor()
    if isSponsor then 
        self.m_TitleBtn:SetActive(true)
        local jieyi = g_JieBaiCtrl:GetJieYiValue()
        local cnt = g_ItemCtrl:GetBagItemAmountBySid(10198)
         self.m_TitleBtn:SetGrey(jieyi <= 0 and cnt <= 0)
    else
        self.m_TitleBtn:SetActive(false)
    end 

end

function CJieBaiTeamView.RefreshMemberList(self)
    
    local memberList = g_JieBaiCtrl:GetMemberList()
    local sponsor = g_JieBaiCtrl:GetSponsorInfo()
    local sponsorPid = sponsor.pid
    local pid = g_AttrCtrl.pid
    table.sort(memberList, function (a, b)
        if a.pid == sponsorPid then
            return true
        elseif b.pid == sponsorPid then 
            return false
        elseif a.pid == pid then 
            return true
        elseif b.pid == pid then 
            return false
        elseif a.pid > b.pid then
            return true
        end 

    end)

    self.m_MemberGrid:HideAllChilds()
    for k, v in ipairs(memberList) do 
        local item =  self.m_MemberGrid:GetChild(k)
        if not item then 
            item = self.m_MemberItem:Clone()
            item:SetActive(true)
            self.m_MemberGrid:AddChild(item)
        end 
        item:SetActive(true)
        item:SetInfo(v)
    end 

end

function CJieBaiTeamView.RefreshActivity(self)
    
    for k, v in pairs(self.m_ActivityList) do 
        v:SetActive(false)
    end 

    self.m_ActivityList = {}

    --邀请结义活动
    local actInfo = g_JieBaiCtrl:GetKickOutActivity()
    if actInfo then
        if not self.m_ActivityList["vote"] then 
            self.m_ActivityList["vote"] = self.m_ActivityItem
            self.m_ActivityList["vote"]:SetActive(true)
            self.m_ActivityGrid:AddChild(self.m_ActivityItem)
            self.m_ActivityList["vote"]:SetInfo(actInfo)
        else
            self.m_ActivityList["vote"]:SetInfo(actInfo)
            self.m_ActivityList["vote"]:SetActive(true)
        end 
    end  

    --接纳新人公告
    local inviteActInfo = g_JieBaiCtrl:GetInviteActivity()
    if inviteActInfo then 
        if not self.m_ActivityList["invite"] then 
            self.m_ActivityList["invite"] = self.m_InviteActivity
            self.m_ActivityList["invite"]:SetActive(true)
            self.m_ActivityGrid:AddChild(self.m_InviteActivity)
            self.m_ActivityList["invite"]:SetInfo(inviteActInfo)
        else
            self.m_ActivityList["invite"]:SetInfo(inviteActInfo)
            self.m_ActivityList["invite"]:SetActive(true)
        end 
    end 

    --割袍断义公告

    self.m_ActivityGrid:Reposition()


end


function CJieBaiTeamView.RefreshDeclaration(self)
        
    self.m_OrgDec = g_JieBaiCtrl:GetDeclaration()
    self.m_DeclarationInput:SetText(self.m_OrgDec)
    local isSponsor = g_JieBaiCtrl:IsJieBaiSponsor()
    if not isSponsor then 
        self.m_DeclarationInput.m_UIInput.enabled = false
    end 

end

function CJieBaiTeamView.RefreshTitle(self)
    
    local title = g_JieBaiCtrl:GetTitle()
    self.m_Title:SetText(title)

end

function CJieBaiTeamView.RefreshJieYiValue(self)
    
    local jieyi = g_JieBaiCtrl:GetJieYiValue()
    self.m_JieYiValue:SetText(jieyi)

end

function CJieBaiTeamView.RefreshAllBtns(self)
   
   self:RefershRemoveBtn()
   self:RefreshInviteBtn()
   self:RefreshCutBtn()

end

function CJieBaiTeamView.RefreshCutBtn(self)
    
    local memberList = g_JieBaiCtrl:GetMemberList()
    if #memberList == 1 then 
        self.m_CutBtnText:SetText("解散团队")
    else
        self.m_CutBtnText:SetText("割袍断义")
    end  
    
end

function CJieBaiTeamView.RefreshInviteBtn(self)
    
    local inviteActivity = g_JieBaiCtrl:GetInviteActivity()
    local isFull = g_JieBaiCtrl:IsMemberFull() 
    local isGrey = false
    if inviteActivity or isFull then 
        isGrey = true
    end 
    self.m_InviteBtn:SetGrey(isGrey)

end

function CJieBaiTeamView.RefershRemoveBtn(self)
    
    local act = g_JieBaiCtrl:GetKickOutActivity()
    self.m_RemoveBtn:SetGrey(act and true or false)

end

function CJieBaiTeamView.OnClickDeclaration(self)
    
    local isSponsor = g_JieBaiCtrl:IsJieBaiSponsor()
    if not isSponsor then 
        local tip = g_JieBaiCtrl:GetTextTip(1040)
        g_NotifyCtrl:FloatMsg(tip)
        return
    end 

end

function CJieBaiTeamView.OnClickTitleBtn(self)
    
    local jieyi = g_JieBaiCtrl:GetJieYiValue()
    local cnt = g_ItemCtrl:GetBagItemAmountBySid(10198)
    if cnt > 0 then 
        CJieBaiTeamSetTitleView:ShowView()
    else
        if jieyi <= 0 then 
            local tip = g_JieBaiCtrl:GetTextTip(1041)
            g_NotifyCtrl:FloatMsg(tip)
            return
        end 
        CJieBaiTeamSetTitleView:ShowView()
    end 

end

function CJieBaiTeamView.OnClose(self)
    
    CViewBase.OnClose(self)
    local dec = self.m_DeclarationInput:GetText()
    if dec ~= self.m_OrgDec then 
         g_JieBaiCtrl:C2GSJBEnounce(dec)
    end 

end

function CJieBaiTeamView.OnClickDeclarationTip(self)
    
    g_JieBaiCtrl:ShowIntruction(10068)

end

function CJieBaiTeamView.OnJieBaiEvent(self, oCtrl)
    
    if oCtrl.m_EventID == define.JieBai.Event.JieBaiInfoChange then
        self:RefreshAll()
    end

end

function CJieBaiTeamView.OnClickCutBtn(self)

    local memberList = g_JieBaiCtrl:GetMemberList()

    if #memberList == 1 then 
        local tip = g_JieBaiCtrl:GetTextTip(1047)
        local windowConfirmInfo = {
            msg = tip,
            okCallback = function()
                g_JieBaiCtrl:C2GSReleaseJieBai()    
            end,  
            pivot = enum.UIWidget.Pivot.Center,
            okStr = "确定",
            cancelStr = "取消"
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    else
        local isSponsor = g_JieBaiCtrl:IsJieBaiSponsor()
        if isSponsor then 
            local tip = g_JieBaiCtrl:GetTextTip(1083)
            g_NotifyCtrl:FloatMsg(tip)
        else
            local tip = g_JieBaiCtrl:GetTextTip(1046)
            local windowConfirmInfo = {
                msg = tip,
                okCallback = function()
                    g_JieBaiCtrl:C2GSQuitJieBai()
                end,  
                pivot = enum.UIWidget.Pivot.Center,
                okStr = "确定",
                cancelStr = "取消"
            }
            g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
        end  
    end 

end

function CJieBaiTeamView.OnClickInviteBtn(self)
    
    local act = g_JieBaiCtrl:GetInviteActivity()
    if act then 
        local tip = g_JieBaiCtrl:GetTextTip(1094)
        g_NotifyCtrl:FloatMsg(tip)
        return
    end 

    if g_JieBaiCtrl:IsMemberFull() then 
        local tip = g_JieBaiCtrl:GetTextTip(1093)
        g_NotifyCtrl:FloatMsg(tip)
        return
    end 

    CJieBaiInviteFriendView:ShowView()

end

function CJieBaiTeamView.OnClickRemoveBtn(self)
    
    local act = g_JieBaiCtrl:GetKickOutActivity()
    if act then 
        local tip = g_JieBaiCtrl:GetTextTip(1095)
        g_NotifyCtrl:FloatMsg(tip)
        return
    end 
    CJieBaiDelMemberView:ShowView()

end

return CJieBaiTeamView
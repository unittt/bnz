local CJieBaiMainView = class("CJieBaiMainView", CViewBase)

function CJieBaiMainView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiMainView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"

end

function CJieBaiMainView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_SponsorIcon = self:NewUI(2, CSprite)
    self.m_SponsorLv = self:NewUI(3, CLabel)
    self.m_SponsorName = self:NewUI(4, CLabel)
    self.m_ValidTime = self:NewUI(5, CLabel)
    self.m_Grid = self:NewUI(6, CGrid)
    self.m_Item = self:NewUI(7, CJieBaiItem)
    self.m_AddItem = self:NewUI(8, CBox)
    self.m_Count = self:NewUI(9, CLabel)
    self.m_CancelBtn = self:NewUI(10, CBox)
    self.m_ConfirmBtn = self:NewUI(11, CBox)
    self.m_ColdTime = self:NewUI(12, CLabel)

    self:InitContent()

end

function CJieBaiMainView.InitBtn(self, btn, cb)

    btn.icon = btn:NewUI(1, CSprite)
    btn.text = btn:NewUI(2, CLabel)
    btn.icon:AddUIEvent("click", callback(self, cb))

end

function CJieBaiMainView.InitContent(self)
  
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_AddItem:AddUIEvent("click", callback(self, "OnClickAddItem"))
    self:InitBtn(self.m_CancelBtn, "OnClickCancelBtn")
    self:InitBtn(self.m_ConfirmBtn, "OnClickConfirmBtn")

    g_JieBaiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnJieBaiEvent"))
    g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
    g_JieBaiCtrl:ResetInviterChangeState()

    self:RefreshAll()

end

function CJieBaiMainView.RefreshAll(self)
 
    self:RefreshSponsor()
    self:RefreshInviteList()
    self:RefreshValidTime()
    self:RefreshBottom()
    self:RefreshCount()
    self:RefreshColdTime()

end

function CJieBaiMainView.RefreshSponsor(self)
    
    local sponsorInfo = g_JieBaiCtrl:GetSponsorInfo()
    if sponsorInfo then 
        local icon = sponsorInfo.icon
        local lv = sponsorInfo.lv
        local name = sponsorInfo.name

        self.m_SponsorIcon:SpriteAvatar(icon)
        self.m_SponsorLv:SetText(lv)
        self.m_SponsorName:SetText(name)
    end 

end

--invited
function CJieBaiMainView.RefreshInviteList(self)
 
    local invitedList = g_JieBaiCtrl:GetInvitedList()

    table.insert(invitedList,1, {id = 0})

    self.m_Grid:HideAllChilds()

    for k, v in ipairs(invitedList) do 
        if v.id == 0 then 
            local item = self.m_Grid:GetChild(k)
            if item == nil then
                item = self.m_AddItem
                item:SetActive(true)
                self.m_Grid:AddChild(item) 
            end
            item:SetActive(true)
            self:RefreshAddItemState(item)

        else
            local item = self.m_Grid:GetChild(k)
            if item == nil then
                item = self.m_Item:Clone() 
                item:SetActive(true)
                self.m_Grid:AddChild(item)  
            end
            item:SetActive(true)
            item:SetInfo(v)
        end 
 
    end 

end

function CJieBaiMainView.RefreshAddItemState(self, item)
    
    local icon = item:NewUI(1, CSprite)
    local isEnough = g_JieBaiCtrl:IsInvitedCountEnough()
    local state = g_JieBaiCtrl:GetJieBaiState()
    icon:SetGrey(isEnough or (state == define.JieBai.State.InYiShi))

end

function CJieBaiMainView.RefreshConfirmState(self, text, isGrey)

    self.m_ConfirmBtn.icon:SetGrey(isGrey)
    self.m_ConfirmBtn.text:SetText(text)
    local comp = self.m_ConfirmBtn.icon:GetComponent(classtype.UIButtonColor)
    if comp then 
       comp.isEnabled = not isGrey
    end 

end

function CJieBaiMainView.RefreshCancelState(self, text, isGrey)

    self.m_CancelBtn.icon:SetGrey(isGrey)
    self.m_CancelBtn.text:SetText(text)
    local comp = self.m_CancelBtn.icon:GetComponent(classtype.UIButtonColor)
    if comp then 
       comp.isEnabled = not isGrey
    end 
    
end

function CJieBaiMainView.RefreshBottom(self)
    
    local isAllInviterConfirm = g_JieBaiCtrl:IsAllInviterConfirm()
    local isInColdTime = g_JieBaiCtrl:IsInColdTime()
    local isHadInviter = g_JieBaiCtrl:IsHadInviter()
    local isOnLine = g_JieBaiCtrl:IsInvitersOnLine()
    local jiebaiState = g_JieBaiCtrl:GetJieBaiState()
    if jiebaiState == define.JieBai.State.BeforeYiShi then 
        if isHadInviter and isAllInviterConfirm and not isInColdTime and isOnLine then 
            self:RefreshConfirmState("发起结拜仪式", false)
        else
            self:RefreshConfirmState("发起结拜仪式", true)
        end 
        self:RefreshCancelState("取消结拜仪式", false)
    elseif jiebaiState == define.JieBai.State.InYiShi then 
        self:RefreshConfirmState("前往结拜仪式", false)
        self:RefreshCancelState("取消结拜仪式", true)
    end 

end

function CJieBaiMainView.RefreshColdTime(self)
    
    local leftTime = g_JieBaiCtrl:GetJieBaiColdTime()
    if leftTime and leftTime > 0 then 
        local cb = function (time)
            if not time then 
                self.m_ColdTime:SetActive(false)
                self:RefreshAll()
            else
                self.m_ColdTime:SetActive(true)
                self.m_ColdTime:SetText("[244B4EFF]冷却中:[-][a64e00ff]" .. time .. "[-]")
            end 
        end
        g_TimeCtrl:StartCountDown(self.m_ColdTime, leftTime, 1, cb)
    else
        self.m_ColdTime:SetActive(false)
    end 

end

function CJieBaiMainView.RefreshCount(self)
    
    local count = g_JieBaiCtrl:GetRemainInviteCount()
     self.m_Count:SetText("[244B4EFF]还可以邀请[-][a64e00ff]" .. tostring(count) .. "[-][244B4EFF]人[-]")

end

function CJieBaiMainView.RefreshValidTime(self)
    
    local leftTime = g_JieBaiCtrl:GetJieBaiLeftTime()
    local cb = function (time)
        if not time then 
            self.m_ValidTime:SetText("[244B4EFF]结拜邀请:[-][A64E00FF]过期[-]")
        else
            self.m_ValidTime:SetText("[244B4EFF]结拜邀请[-][a64e00ff]" .. time .. "[-][244B4EFF]后过期[-]")
        end 
    end
    g_TimeCtrl:StartCountDown(self.m_ValidTime, leftTime, 1, cb)

end

function CJieBaiMainView.OnClickAddItem(self)
    
    local isEnough = g_JieBaiCtrl:IsInvitedCountEnough()

    if isEnough then 
        g_NotifyCtrl:FloatMsg("人数已满")
        return
    end 

    local state = g_JieBaiCtrl:GetJieBaiState()

    if state == define.JieBai.State.InYiShi then 
        local tip =  g_JieBaiCtrl:GetTextTip(1027)
        g_NotifyCtrl:FloatMsg(tip)
        return
    end 

    CJieBaiInviteFriendView:ShowView()

    
end

function CJieBaiMainView.OnClickCancelBtn(self)

    local state = g_JieBaiCtrl:GetJieBaiState()

    if state == define.JieBai.State.InYiShi then 
        g_NotifyCtrl:FloatMsg("已发起结拜仪式，不能取消")
    else
        local tip =  g_JieBaiCtrl:GetTextTip(1010)
        local windowConfirmInfo = {
            msg = tip,
            okCallback = function()
                g_JieBaiCtrl:C2GSReleaseJieBai()
            end,    
            pivot = enum.UIWidget.Pivot.Center,
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    end 

end

function CJieBaiMainView.OnClickConfirmBtn(self)

    local isAllInviterConfirm = g_JieBaiCtrl:IsAllInviterConfirm()
    local isInColdTime = g_JieBaiCtrl:IsInColdTime()
    local isHadInviter = g_JieBaiCtrl:IsHadInviter()
    local isOnLine = g_JieBaiCtrl:IsInvitersOnLine()

    if not isHadInviter then 
         local tip =  g_JieBaiCtrl:GetTextTip(1014)
         g_NotifyCtrl:FloatMsg(tip)
         return
    end 

    if not isAllInviterConfirm then 
        local tip =  g_JieBaiCtrl:GetTextTip(1015)
        g_NotifyCtrl:FloatMsg(tip)
        return
    end 

    if not isOnLine then 
        local tip =  g_JieBaiCtrl:GetTextTip(1016)
        g_NotifyCtrl:FloatMsg(tip)
        return
    end 

    if isInColdTime then 
        local tip = g_JieBaiCtrl:GetTextTip(1021)
        g_NotifyCtrl:FloatMsg(tip)
        return
    end 

    local state = g_JieBaiCtrl:GetJieBaiState()
    if state == define.JieBai.State.InYiShi then 
        g_JieBaiCtrl:C2GSJBJoinYiShi()
        self:OnClose()
    else
        local tip =  g_JieBaiCtrl:GetTextTip(1017)
        local windowConfirmInfo = {
           msg = tip,
           okCallback = function()
               g_JieBaiCtrl:C2GSJBPreStart()
               self:OnClose()
           end,    
           pivot = enum.UIWidget.Pivot.Center,
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    end 

end

function CJieBaiMainView.OnJieBaiEvent(self, oCtrl)
    
    if oCtrl.m_EventID == define.JieBai.Event.JieBaiInfoChange then
        self:RefreshAll()
    end

end

function CJieBaiMainView.OnFriendEvent(self, oCtrl)

    if oCtrl.m_EventID == define.Friend.Event.Update then
        self:RefreshAll()
    end
    
end


return CJieBaiMainView
local CJieBaiInvitedMainView = class("CJieBaiInvitedMainView", CViewBase)

function CJieBaiInvitedMainView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiInvitedMainView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"

end

function CJieBaiInvitedMainView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_SponsorIcon = self:NewUI(2, CSprite)
    self.m_SponsorLv = self:NewUI(3, CLabel)
    self.m_SponsorName = self:NewUI(4, CLabel)
    self.m_ValidTime = self:NewUI(5, CLabel)
    self.m_Grid = self:NewUI(6, CGrid)
    self.m_Item = self:NewUI(7, CJieBaiInvitedItem)
    self.m_Count = self:NewUI(8, CLabel)
    self.m_Btn = self:NewUI(9, CBox)

    self:InitContent()

end

function CJieBaiInvitedMainView.InitBtn(self, btn, cb)

    btn.icon = btn:NewUI(1, CSprite)
    btn.text = btn:NewUI(2, CLabel)
    btn.icon:AddUIEvent("click", callback(self, cb))

end

function CJieBaiInvitedMainView.InitContent(self)
  
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self:InitBtn(self.m_Btn, "OnClickBtn")
    g_JieBaiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnJieBaiEvent"))
    g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
    self.m_IsAddItemValid = false

    self:RefreshAll()

end

function CJieBaiInvitedMainView.RefreshAll(self)
    
    self:RefreshSponsor()
    self:RefreshInviteList()
    self:RefreshValidTime()
    self:RefreshCount()
    self:RefreshBottom()

end

function CJieBaiInvitedMainView.RefreshCancelState(self, text)

    self.m_Btn.text:SetText(text)

end

function CJieBaiInvitedMainView.RefreshBottom(self)
    
    local jiebaiState = g_JieBaiCtrl:GetJieBaiState()
    if jiebaiState == define.JieBai.State.BeforeYiShi then 
        self:RefreshCancelState("退出结拜邀请")
    elseif jiebaiState == define.JieBai.State.InYiShi then 
        self:RefreshCancelState("前往结拜仪式")
    end 

end

function CJieBaiInvitedMainView.RefreshSponsor(self)
    
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

function CJieBaiInvitedMainView.RefreshInviteList(self)

    local invitedList = g_JieBaiCtrl:GetInvitedList()

    self.m_Grid:HideAllChilds()

    for k, v in ipairs(invitedList) do 
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


function CJieBaiInvitedMainView.RefreshCount(self)
    
    local count = g_JieBaiCtrl:GetRemainInviteCount()
    self.m_Count:SetText("[244B4EFF]还可以邀请[-][a64e00ff]" .. tostring(count) .. "[-][244B4EFF]人[-]")

end

function CJieBaiInvitedMainView.RefreshValidTime(self)
    
    local leftTime = g_JieBaiCtrl:GetJieBaiLeftTime()
    local cb = function (time)
        if not time then 
            self.m_ValidTime:SetText("[244B4EFF]结拜邀请:[-][A64E00FF]过期[-]")
        else
            self.m_ValidTime:SetText("[244B4EFF]结拜邀请[-][a64e00ff]" .. time .. "[-][244B4EFF]后过期[-]")
        end 
    end
    g_TimeCtrl:StartCountDown(self, leftTime, 1, cb)

end


function CJieBaiInvitedMainView.OnClickBtn(self)

    local jiebaiState = g_JieBaiCtrl:GetJieBaiState()

    if jiebaiState == define.JieBai.State.BeforeYiShi then 
        local tip =  g_JieBaiCtrl:GetTextTip(1080)
        local windowConfirmInfo = {
            msg = tip,
            okCallback = function()
                g_JieBaiCtrl:C2GSQuitJieBai()
            end,    
            pivot = enum.UIWidget.Pivot.Center,
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    elseif jiebaiState == define.JieBai.State.InYiShi then 
        g_JieBaiCtrl:C2GSJBJoinYiShi()
        self:OnClose()
    end

end

function CJieBaiInvitedMainView.OnJieBaiEvent(self, oCtrl)
    
    if oCtrl.m_EventID == define.JieBai.Event.JieBaiInfoChange  then
        self:RefreshAll()
    end

end

function CJieBaiInvitedMainView.OnFriendEvent(self, oCtrl)

    if oCtrl.m_EventID == define.Friend.Event.Update then
        self:RefreshAll()
    end
    
end



return CJieBaiInvitedMainView
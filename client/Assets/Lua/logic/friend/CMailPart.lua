local CMailPart = class("CMailPart", CPageBase)

function CMailPart.ctor(self, obj)
    CPageBase.ctor(self, obj)
end

function CMailPart.OnInitPage(self)
    self.m_OneClickRetrieve = self:NewUI(1, CButton, true, false)
    self.m_OneClickDelete = self:NewUI(2, CButton, true, false)
    self.m_Grid = self:NewUI(3, CGrid)
    self.m_ItemClone = self:NewUI(4, CMailItem)
    self.m_ScrollView = self:NewUI(5, CScrollView)
    self.m_EmptyHint = self:NewUI(6, CBox)
    self.m_EmptyHintDes = self:NewUI(7, CLabel)
    g_MailCtrl.m_CurMailId = nil
    self.m_ItemTable = {}   -- key = mailid, value = oItem
    self:InitContent()
end

function CMailPart.InitContent(self)
    self.m_OneClickRetrieve:AddUIEvent("click", callback(self, "OnOneClickRetrieve"))
    self.m_OneClickDelete:AddUIEvent("click", callback(self, "OnOneClickDelete"))
    g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMailEvent"))
    self.m_EmptyHintDes:SetText(DataTools.GetMiscText(1008).content)
    self:RebuildMailList()
end

function CMailPart.RebuildMailList(self)
    self.m_ItemTable = {}
    if #g_MailCtrl.m_SortedMails > 0 then
        self.m_EmptyHint:SetActive(false)      
    else
        self.m_EmptyHint:SetActive(true)
    end
    self:InitItem()
    self:FloatItemBox()
    g_MailCtrl:UpdateUnopenedMailNum()
end

function CMailPart.FloatItemBox(self)
    if g_FriendCtrl.m_FloatItemList then
        for i =#g_FriendCtrl.m_FloatItemList,1,-1 do
            local v  = g_FriendCtrl.m_FloatItemList[i]
            local oItemData = DataTools.GetItemData(v.itemid)
            g_NotifyCtrl:FloatItemBox(oItemData.icon, nil, v.pos)
            table.remove( g_FriendCtrl.m_FloatItemList, i)
        end
    end

end


function CMailPart.OnMailEvent(self, callbackBase)
    if callbackBase.m_EventID == define.Mail.Event.Sort then
        self:RebuildMailList()
    end
    if callbackBase.m_EventID == define.Mail.Event.Opened then
        self:InitItem()
    end
end

function CMailPart.DelMailItem(self, mailid)
    if mailid == nil or self.m_ItemTable[mailid] == nil then
        return
    end
    self.m_ItemTable[mailid]:SetActive(false)
    --self.m_Grid:RepositionLater()
    if self.m_Grid:GetCount() > 0 then
        self.m_EmptyHint:SetActive(false)      
    else
        self.m_EmptyHint:SetActive(true)
    end
    --self.m_ScrollView:ResetPosition()
end

function CMailPart.SetMailOpened(self, mailid)
    if self.m_ItemTable[mailid] then
        self.m_ItemTable[mailid]:SetOpened()
    end
end

function CMailPart.OnOneClickRetrieve(self)
    netmail.C2GSAcceptAllAttach()
end

function CMailPart.OnOneClickDelete(self)
    if not g_MailCtrl:HasMail() then
        g_NotifyCtrl:FloatMsg(data.textdata.TEXT[1005].content)
        return
    end
    local windowConfirmInfo = {
        title = "一键删除",
        msg = data.textdata.TEXT[1009].content,
        okStr = "确定",
        cancelStr = "取消",
        okCallback = function()
            netmail.C2GSDeleteAllMail(0)
        end
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo,
        function (oView)
            self.m_WinTipViwe = oView
        end
    )
end

function CMailPart.InitItem(self)
    if self.m_LoadTimer then
        Utils.DelTimer(self.m_LoadTimer)
        self.m_LoadTimer = nil
    end
    self.m_LoadIndex = 1
    self.m_LoadTimer = Utils.AddTimer(callback(self, "LoadMail"), 0.03, 0)    
    self.m_ScrollView:SetActive(false)
end

function CMailPart.LoadMail(self)
    if Utils.IsNil(self) then
        return
    end
    for i=1, 6 do
        local dMail = g_MailCtrl.m_SortedMails[self.m_LoadIndex]
        if dMail then
            local oItem = self.m_Grid:GetChild(self.m_LoadIndex)
            if oItem then
                oItem:SetActive(true)
                oItem:SetBoxInfo(dMail)
                oItem:AddUIEvent("click", callback(self, "ItemCallBack", dMail))
            else
                oItem = self:AddMailItem(dMail)
            end
            oItem.m_MailData = dMail
            self.m_ItemTable[dMail.mailid] = oItem
        end
        self.m_LoadIndex = self.m_LoadIndex + 1
        if self.m_LoadIndex > #g_MailCtrl.m_SortedMails then
            for i = #g_MailCtrl.m_SortedMails + 1, self.m_Grid:GetCount() do
                self.m_Grid:GetChild(i):SetActive(false)
            end
            self.m_ScrollView:SetActive(true)
            self.m_Grid:Reposition()
            Utils.AddTimer(function ()
                if self.m_ItemTable[g_MailCtrl.m_CurMailId] then
                    self:ItemCallBack(self.m_ItemTable[g_MailCtrl.m_CurMailId].m_MailData)
                end
                self.m_ScrollView:ResetPosition()
                return false
            end, 0, 0.03)
            return false
        end
    end
    self.m_Grid:Reposition()
    return true
end

function CMailPart.AddMailItem(self, mail)
    local oItem = self.m_ItemClone:Clone()
    oItem:SetActive(true)
    oItem:SetBoxInfo(mail)
    oItem:SetGroup(self.m_Grid:GetInstanceID())
    oItem:AddUIEvent("click", callback(self, "ItemCallBack", mail))
    self.m_Grid:AddChild(oItem)
    return oItem
end

function CMailPart.ItemCallBack(self, mail)
    if mail.mailid ~= g_MailCtrl.m_CurMailId then
        g_MailCtrl:CloseMail(g_MailCtrl.m_CurMailId)
    end 
    --将可以领取的物品设置为空
    -- g_FriendCtrl:FloatItemList(nil)
    --self.m_ItemTable[mail.mailid]:SetSelTitleColor()
    -- self.m_CurMailId = mail.mailid
    g_MailCtrl:ShowMailDetail(mail)
end

function CMailPart.SetItemSelected(self, mailid, bSelected)
    if mailid == nil then
        return
    end
    if self.m_ItemTable[mailid] then
        self.m_ItemTable[mailid]:ForceSelected(bSelected)
    end
end

return CMailPart
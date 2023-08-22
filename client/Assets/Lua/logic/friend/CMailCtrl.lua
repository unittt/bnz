local CMailCtrl = class("CMailCtrl", CCtrlBase)

CMailCtrl.MAIL_STATUS = {
    UNOPENED = 0,
    OPENED = 1,
    READ_TO_DEL = false,
}
CMailCtrl.ATTACH_STATUS = {
    NO_ATTACH = 0,
    HAS_ATTACH = 1,
    ATTACH_RETRIEVED = 2,
}
CMailCtrl.OPE = {
    CLOSE_MAIL = 0,
    DEL_MAIL = 1,   -- 手动删除邮件，打开下一封未读
    OPEN_MAIL = 2,  -- 读后自动删除邮件，无需打开下一封未读
    RETRIEVE_ATTACH = 3,
}

function CMailCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:Reset()
end

function CMailCtrl.Reset(self)
    self.m_Mails = {}
    self.m_SortedMails = {}
    self.m_CurMailId = nil

    self:OnEvent(define.Mail.Event.Sort)
end

----------------------------- 客户端数据处理

function CMailCtrl.GetMailsNum(self)
    local num = 0
    for k, v in pairs(self.m_Mails) do
        num = num + 1
    end
    return num
end

function CMailCtrl.HasMail(self)
    local num = self:GetMailsNum()
    return num > 0
end

function CMailCtrl.GetMailsNum(self)
    local num = 0
    for _, mail in pairs(self.m_Mails) do
        num = num + 1
    end
    -- printc("邮件总数 = " .. num)
    return num
end

function CMailCtrl.GetUnOpenedMailsNum(self)
    local nUnopend = 0
    for _, mail in pairs(self.m_Mails) do
        if not self:IsMailOpened(mail.mailid) then
            nUnopend = nUnopend + 1
        end
    end
    -- printc("未读邮件数 = " .. nUnopend)
    return nUnopend
end

function CMailCtrl.GetIsHasUnOpenedMails(self)
    for _, mail in pairs(self.m_Mails) do
        if not self:IsMailOpened(mail.mailid) then
            return true
        end
    end
end

function CMailCtrl.GetMail(self, mailid)
    if mailid then
        return self.m_Mails[mailid]
    else
        return nil
    end
end

function CMailCtrl.PrintSortedMails(self)
    printc("排序后的邮件列表：")
    for i = 1, #self.m_SortedMails do
        local mail = self.m_SortedMails[i]
        printc("mailid = " .. mail.mailid .. ", createtime = " .. mail.createtime .. ", opened = " .. mail.opened)
    end
end

function CMailCtrl.SortMails(self)
    self.m_SortedMails = {}
    for _, mail in pairs(self.m_Mails) do
        table.insert(self.m_SortedMails, mail)
    end
    table.sort(self.m_SortedMails, self.SortFunc)
end

function CMailCtrl.SortFunc(mailA, mailB)
    if mailA and mailB then
        if mailA.opened == mailB.opened then    -- 都是未读或都是已读，旧的排在前面，新的排在后面
            return mailA.createtime < mailB.createtime
        else
            return mailA.opened > mailB.opened  --  已读读排在前面，未读排在后面
        end
    end
end

function CMailCtrl.IsMailOpened(self, mailid)
    if mailid and self.m_Mails[mailid] then
        return self.m_Mails[mailid].opened == self.MAIL_STATUS.OPENED
    else
        return true
    end
end

function CMailCtrl.IsMailReadToDel(self, mailid)
    if mailid == nil then
        return false
    end
    local mail = self.m_Mails[mailid]
    if mail then
        return mail.readtodel == 1
    else
        return false
    end
end

function CMailCtrl.SetMailAdded(self, mail)
    if mail == nil then
        return
    end
    self.m_Mails[mail.mailid] = mail
    self:AddToSortedMails(mail)
end

-- 把 mailid 插入到 m_SortedMails，避免重新排序
function CMailCtrl.AddToSortedMails(self, addMail)
    if addMail == nil then
        return
    end
    -- 找出插入的位置
    local addIdx = 1
    local found = false
    for i = #self.m_SortedMails, 1, -1 do
        addIdx = i
        local mail = self.m_SortedMails[i]
        if addMail.opened == mail.opened then
            if mail.createtime < addMail.createtime then
                found = true
                break
            end
        elseif addMail.opened < mail.opened then -- 插入未读，遇到已读
            found = true
            break
        elseif addMail.opened > mail.opened then  -- 插入已读，遇到未读，跳过，直到遍历到已读
        end
    end
    if found then
        table.insert(self.m_SortedMails, addIdx + 1, addMail)
    else
        table.insert(self.m_SortedMails, 1, addMail)
    end
    self:OnEvent(define.Mail.Event.Sort)
end

function CMailCtrl.SetMailDeleted(self, mailid)
    if mailid == nil then
        return
    end
    self.m_Mails[mailid] = nil
    local view = CFriendInfoView:GetView()
    if view and view.m_Detail and view.m_Detail.m_MailId == mailid then
        view.m_Detail:OnClose()
    end
    self:DelFromSortedMails(mailid)
end

-- 从有序列表中删除邮件
function CMailCtrl.DelFromSortedMails(self, mailid)
    if mailid == nil then
        return
    end
    -- 找出 mailid 对应的 idx
    local delIdx = nil
    for i = 1, #self.m_SortedMails do
        if self.m_SortedMails[i].mailid == mailid then
            delIdx = i
            break
        end
    end
    if delIdx then
        table.remove(self.m_SortedMails, delIdx)
    end
    self:OnEvent(define.Mail.Event.Sort)
end

function CMailCtrl.SetMailOpenedAttachRetrieved(self, mailid)  -- 已读 == 附件已领取
    if mailid == nil then
        return
    end
    if self.m_Mails[mailid] then
        self.m_Mails[mailid].opened = self.MAIL_STATUS.OPENED
        self.m_Mails[mailid].hasattach = self.ATTACH_STATUS.ATTACH_RETRIEVED
    end
    self:ReinsertToSortedMails(mailid)
end

-- 一封邮件从未读变成已读，要重新对其排序，现在的做法是先删除，再插入，避免整个列表重新排序
function CMailCtrl.ReinsertToSortedMails(self, mailid)
    if mailid == nil then
        return
    end
    self:DelFromSortedMails(mailid)
    local mail = self:GetMail(mailid)
    if mail == nil then
        return
    end
    self:AddToSortedMails(mail)
end

function CMailCtrl.GetDate(self, timestamp)
    local month = os.date("%m", timestamp)
    local day = os.date("%d", timestamp)
    return month .. "-" .. day
end

function CMailCtrl.GetTime(self, timestamp)
    local sDate = self:GetDate(timestamp)
    local hour = os.date("%H", timestamp)
    local minute = os.date("%M", timestamp)
    return sDate .. " " .. hour .. ":" .. minute
end

function CMailCtrl.GetFullTime(self, timestamp)
    local sTime = self:GetTime(timestamp)
    local second = os.date("%S", timestamp)
    return sTime .. ":" .. second
end

----------------------------- 同步服务端数据，并刷新界面

function CMailCtrl.PullUpdateMailInfo(self, pbdata)
    for k, v in pairs(pbdata) do
        self.m_Mails[pbdata.mailid][k] = v   -- 在 simpleInfo 基础上增加数据
    end
    --self:ReinsertToSortedMails(pbdata.mailid)
    self:OnEvent(define.Mail.Event.GetDetail, pbdata.mailid)
    -- if pbdata.opened == 1 then
    --     self:OnEvent(define.Mail.Event.Opened, pbdata.mailid)
    -- end
end

-- 一键删除多封无附件邮件（不管已读/未读）
function CMailCtrl.PullDelMails(self, mailids)
    for _, mid in pairs(mailids) do
        self:SetMailDeleted(mid)   
    end
    self:UpdateUnopenedMailNum()
    self:OnEvent(define.Mail.Event.Sort)
end

function CMailCtrl.PullAddMail(self, simpleInfo)
    self:SetMailAdded(simpleInfo)
    if simpleInfo.audio ~= "" then
        g_AudioCtrl:PlaySound(simpleInfo.audio)
    end
end

-- 一键领取时，需要把多封邮件设为已读
function CMailCtrl.PullOpenMails(self, mailids)
    local delList = {}
    for _, mid in pairs(mailids) do
        if self:IsMailReadToDel(mid) then
            table.insert(delList, mid)         
        else
            self:SetMailOpenedAttachRetrieved(mid)
            self:UpdateOpenMailUI(mid)  
        end
    end
    self:PushDelMails(delList)
    self:OnEvent(define.Mail.Event.Sort)
end

----------------------------- 界面操作后，更新客户端数据，并同步到服务端
function CMailCtrl.IsMailDetailShowing(self, mailid)
    if mailid == nil then
        return false
    end
    local isShowing = false
    if CFriendInfoView:GetView() and CFriendInfoView:GetView().m_Detail and CFriendInfoView:GetView().m_Detail:GetActive() then
        isShowing = CFriendInfoView:GetView().m_Detail.m_MailId == mailid
    else
        isShowing = false
    end
    return isShowing
end

function CMailCtrl.UpdateUnopenedMailNum(self)
    local view = CFriendInfoView:GetView()
    if view and CFriendInfoView:GetView().m_Brief then
        view.m_Brief:UpdateUnopenedMailNum()
    end
    self:OnEvent(define.Mail.Event.OpenMails)
end

function CMailCtrl.PushOpenMail(self, mailid)  -- ope 表示发哪个协议，因为前面的操作都一样，只是发的协议不同
    self:UpdateOpenMailUI(mailid)
    self:SetMailOpenedAttachRetrieved(mailid)
    if self:IsMailReadToDel(mailid) and mailid ~= self.m_CurMailId then
        self:PushDelMail(mailid, self.OPE.CLOSE_MAIL)
    else
        local view = CFriendInfoView:GetView()
        if view and view.m_Brief then
            view.m_Brief.m_MailPart:SetMailOpened(mailid)
        end   
    end
    self:OnEvent(define.Mail.Event.Sort)
end

function CMailCtrl.UpdateOpenMailUI(self, mailid)
    if mailid == nil then
        return
    end
    local view = CFriendInfoView:GetView()  
    self:UpdateUnopenedMailNum()
    if view and view.m_Detail then
        view.m_Detail:ShowAttachRetrieved(mailid)
    end
end

function CMailCtrl.PushDelMail(self, mailid, ope)  -- ope 区分是手动删除，还是自动删除（不显示读后删除的邮件后自动删除）
    -- 更新客户端数据（这里要放在更新 UI 之后，否则 ShowNextUnopenedMail 会失败）
    self:SetMailDeleted(mailid)
    -- 发协议给服务端（服务端不回协议）
    self:UpdateDelMailUI(mailid, ope)
    netmail.C2GSDeleteMail({mailid})
end

function CMailCtrl.PushDelMails(self, mailids)
    for i,v in ipairs(mailids) do
        self:SetMailDeleted(v)
    end
    netmail.C2GSDeleteMail(mailids)
end

function CMailCtrl.UpdateDelMailUI(self, mailid, ope)
   self:OnEvent(define.Mail.Event.Sort) 
   self:ShowNextUnopenedMail(mailid, ope)
end

-- 显示返回 true，不显示返回 false
function CMailCtrl.ShowNextUnopenedMail(self, lastDelMailId, ope)
    -- 不是手动删除操作，不显示下一封未读
    if ope ~= self.OPE.DEL_MAIL then
        return false
    end
    -- 是否有下一封未读
    local nextUnopenMail = self:GetNextUnopenedMail(lastDelMailId)
    local view = CFriendInfoView:GetView()
    if nextUnopenMail then
        self:ShowMailDetail(nextUnopenMail)     
    elseif view then
        view.m_Detail:OnClose()
    end
end

function CMailCtrl.GetNextUnopenedMail(self, lastDelMailId)
    -- 显示第一封未读
    local nextUnopenMail = nil
    for i = #self.m_SortedMails, 1, -1 do  -- 在 self.m_SortedMails 里的顺序是时间从小到大排序，所以这里要反向遍历
        if not self:IsMailOpened(self.m_SortedMails[i].mailid) then
            nextUnopenMail = self.m_SortedMails[i]
            break
        end
    end
    return nextUnopenMail
end

function CMailCtrl.ShowMailDetail(self, mail)
    local view = CFriendInfoView:GetView()
    if mail == nil or view == nil then
        return
    end
    -- 选中 mail item
    if view.m_Brief then
       view.m_Brief.m_MailPart:SetItemSelected(mail.mailid, true)
    end
    
    if view.m_Detail:GetActive() and mail.mailid == self.m_CurMailId then
        return
    end
    
    -- 打开 mail detail
    if view.m_Detail then 
        -- view.m_Detail:SetActive(true)
        view.m_Detail:SetDetailInfo(mail)
        self.m_CurMailId = mail.mailid
    end    
end

function CMailCtrl.CloseMail(self, mailId)
    self.m_CurMailId = nil
    if mailId == nil then
        return
    end 
    if self:IsMailOpened(mailId) and self:IsMailReadToDel(mailId) then
        self:PushDelMail(mailId, self.OPE_CLOSE_MAIL)
    end
end

function CMailCtrl.C2GSAcceptAttach(self, mailid)
    netmail.C2GSAcceptAttach(mailid)
end

return CMailCtrl
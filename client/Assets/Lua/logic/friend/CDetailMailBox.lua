local CDetailMailBox = class("CDetailMailBox", CBox)

function CDetailMailBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_RetrieveAttachBtn = self:NewUI(1, CButton)
    self.m_MailTextLabel     = self:NewUI(2, CLabel)
    self.m_ReceiveTimeLabel  = self:NewUI(3, CLabel)
    self.m_SenderLabel       = self:NewUI(4, CLabel)
    self.m_Grid              = self:NewUI(5, CGrid)
    self.m_ItemClone         = self:NewUI(6, CAttachItem)
    self.m_TitleLabel        = self:NewUI(7, CLabel)
    self.m_DelBtn            = self:NewUI(8, CButton)
    self.m_AttachTitle       = self:NewUI(9, CLabel)
    self.m_AttachScrollView  = self:NewUI(10, CScrollView)
    self.m_CloseBtn          = self:NewUI(11, CButton)
    self.m_Tail              = self:NewUI(12, CBox)
    self.m_TextScrollView    = self:NewUI(13, CScrollView)
    self.m_AudioBox          = self:NewUI(14, CDetailAudioBox)
    self.m_ImageBox          = self:NewUI(15, CDetailImageBox)
    self.m_FloatSprite       = self:NewUI(16, CWidget)

    self.m_ItemClone:SetActive(false)
    self.m_MailId            = nil
    self:InitContent()
end

function CDetailMailBox.InitContent(self)
    self.m_RetrieveAttachBtn:AddUIEvent("click", callback(self, "OnClickedRetrieveAttach"))
    self.m_DelBtn:AddUIEvent("click", callback(self, "OnClickedDelMail"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_AudioBox:SetActive(false)
    self.m_ImageBox:SetActive(false)
    g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMailEvent"))
end

function CDetailMailBox.InitAttachItem(self, attachList, hasAttach)
    local itemlist = {}
    for k,v in pairs(attachList) do  --剔除附件物品小于0的
        if v.val > 0 then
           itemlist[#itemlist + 1] = v
        end
    end
    for k, attach in pairs(itemlist) do
        local oItem = self.m_Grid:GetChild(k)
        if oItem == nil then 
            self:AddAttachItem(attach, hasAttach)
        else
            oItem:SetActive(true)
            oItem:SetBoxInfo(attach, hasAttach)
        end 
    end
    if self.m_Grid:GetCount() <= #itemlist then 
        return
    end 
    for i = #itemlist+1, self.m_Grid:GetCount() do
        self.m_Grid:GetChild(i):SetActive(false)
    end
    self.m_AttachScrollView:ResetPosition()
end

function CDetailMailBox.AddAttachItem(self, attach, hasAttach)
    local oItem = self.m_ItemClone:Clone(function()
        self:ItemCallBack(attach)
    end)
    oItem:SetActive(true)
    oItem:SetBoxInfo(attach, hasAttach)
    oItem.attach = attach
    oItem:SetGroup(self.m_Grid:GetInstanceID())
    self.m_Grid:AddChild(oItem)
end

function CDetailMailBox.OnClickedRetrieveAttach(self)
    g_MailCtrl:C2GSAcceptAttach(self.m_MailId)
end

function CDetailMailBox.OnClickedDelMail(self)
    g_MailCtrl:PushDelMail(self.m_MailId, g_MailCtrl.OPE.DEL_MAIL)
end

function CDetailMailBox.SetDetailInfo(self, mail)
    if mail == nil then
        printerror("CDetailMailPart.SetDetailInfo, mail == nil")
        return
    end
    -- 更新 mailid
    self.m_MailId = mail.mailid

    -- 标题
    self.m_TitleLabel:SetText(mail.title)

    -- 附件
    if mail.hasattach == g_MailCtrl.ATTACH_STATUS.NO_ATTACH then
        self:ShowHasNoAttach()
    elseif mail.hasattach == g_MailCtrl.ATTACH_STATUS.HAS_ATTACH then
        self:ShowHasAttach()
    elseif mail.hasattach == g_MailCtrl.ATTACH_STATUS.ATTACH_RETRIEVED then
        self:ShowAttachRetrieved(self.m_MailId)
    --elseif mail.hasattach == 

    end
    -- 请求详细数据
    netmail.C2GSOpenMail(mail.mailid)
end

function CDetailMailBox.OnMailEvent(self, callbackBase)
    local eventID = callbackBase.m_EventID
    if eventID == define.Mail.Event.GetDetail then
        local mailid = callbackBase.m_EventData
        printc("邮件详情"..mailid)
        self:UpdateInfo(mailid)
    end
end

function CDetailMailBox.UpdateInfo(self, mailid)
    self:SetActive(true)
    -- 需要刷新数据的邮件 == 当前打开邮件，才刷新
    if mailid == self.m_MailId then
        local mail = g_MailCtrl:GetMail(mailid)
        if mail then
            local audioPos = self:CheckAudio(mail) --检查是否有语音标签
            local imagePos = self:CheckImage(mail) --检查是否有图片标签
            local context = mail.context
            if imagePos then
                context = string.sub(mail.context, 1, imagePos) 
            end
            if audioPos then
                context = string.sub(mail.context, 1, audioPos)
            end
            local sUrlText = "#D"..context.."#n"
            sUrlText = string.gsub(sUrlText,"%\\n","\n")  --表里填\n读出的数据是\\n
            self.m_MailTextLabel:SetText("")
            self.m_MailTextLabel:SetRichText("    " .. sUrlText)
            self.m_TextScrollView:ResetPosition()
            self.m_SenderLabel:SetText(mail.name)
            self.m_ReceiveTimeLabel:SetText(g_MailCtrl:GetFullTime(mail.createtime))  -- 接收时间 == 创建时间
            if mail.hasattach ~= g_MailCtrl.ATTACH_STATUS.NO_ATTACH then
                self:InitAttachItem(mail.attachs, mail.hasattach)
            end
            local target = nil
            if audioPos then
                --UITools.NearTarget(self.m_MailTextLabel, self.m_AudioBox, enum.UIAnchor.Side.Bottom)
                target = self.m_AudioBox.m_TranslateLabel
            else
                target = self.m_MailTextLabel
            end
            Utils.AddTimer(function ()
                UITools.NearTarget(target, self.m_ImageBox, enum.UIAnchor.Side.Bottom)
                return false
            end, 0, 0.1)             
        end
    end
end

function CDetailMailBox.CheckAudio(self, mail)
    local k, startpos = string.find(mail.context, "audio")
    local endpos, j = string.find(mail.context, "/audio")
    if startpos == nil or endpos == nil then
        self.m_AudioBox:SetActive(false)
        return nil
    end
    local audioData = string.sub(mail.context, startpos+2, endpos-2)
    local list = string.split(audioData, ",")
    local data = {
        key = list[1],
        translate = list[2],
        time = list[3],
    }
    self.m_AudioBox:SetData(data)
    self.m_AudioBox:SetActive(true)
    return k - 2
end

function CDetailMailBox.CheckImage(self, mail)
    local k, startpos = string.find(mail.context, "image")
    local endpos, j = string.find(mail.context, "/image")
    if startpos == nil or endpos == nil then
        self.m_ImageBox:SetActive(false)
        return nil
    end
    local imageData = string.sub(mail.context, startpos+2, endpos-2)
    local list = string.split(imageData, ",")
    local data = {
        key = list[1],
        width = list[2],
        height = list[3],
        link = list[4],
    }
    self.m_ImageBox:SetData(data)
    --self.m_ImageBox:SetActive(true)
    return k - 2
end

function CDetailMailBox.ShowHasAttach(self)
    self:SetViewStyle(true)

    self.m_AttachScrollView:SetActive(true)
    self.m_RetrieveAttachBtn:SetActive(true)
    self.m_AttachTitle:SetActive(true)
    self.m_DelBtn:SetActive(false)
end

function CDetailMailBox.ShowHasNoAttach(self)
    self:SetViewStyle(false)

    self.m_AttachScrollView:SetActive(false)
    self.m_RetrieveAttachBtn:SetActive(false)
    self.m_DelBtn:SetActive(true)
    self.m_AttachTitle:SetActive(false)
end

function CDetailMailBox.ShowAttachRetrieved(self, mailid)
    if mailid == self.m_MailId then
        self:SetViewStyle(true)

        self.m_AttachScrollView:SetActive(true)
        self:SetAttachGrey()
         self.m_AttachTitle:SetActive(true)
        self.m_RetrieveAttachBtn:SetActive(false)
        self.m_DelBtn:SetActive(true)
    end
end

function CDetailMailBox.SetViewStyle(self, bAttach)
    local scrollViewY = bAttach and 110 or 40
    local scrollViewClipY = bAttach and 310 or 460

    self.m_TextScrollView:SetLocalPos(Vector3.New(0, scrollViewY, 0))
    self.m_TextScrollView:SetBaseClipRegion(Vector4.New(0, 0, 452, scrollViewClipY))
    self.m_TextScrollView:SetClipOffset(Vector2.zero)
    self.m_FloatSprite:ResetAndUpdateAnchors()
end

function CDetailMailBox.SetAttachGrey(self)
    for _, oAttach in pairs(self.m_Grid:GetChildList()) do
        if oAttach then
            oAttach:SetRetrieved(true)
        end
    end
end

function CDetailMailBox.OnClose(self)
    g_MailCtrl:OnEvent(define.Mail.Event.Sort)
    g_MailCtrl:CloseMail(self.m_MailId)
    self.m_AudioBox:OnClose()
    self:SetActive(false)
end

return CDetailMailBox
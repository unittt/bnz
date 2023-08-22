local CEditOrgMailView = class("CEditOrgMailView", CViewBase)

CEditOrgMailView.MAX_CHINESE_CHAR_NUM = 100  -- 最多 100 个汉字

function CEditOrgMailView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/EditOrgMailView.prefab", cb)
    self.m_DepthType = "Dialog"
    -- self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CEditOrgMailView.OnCreateView(self)
    self.m_CloseBtn        = self:NewUI(1, CButton)
    self.m_ExplainLabel    = self:NewUI(2, CLabel)
    self.m_MailInput        = self:NewUI(3, CInput)
    self.m_NumWordLabel    = self:NewUI(4, CLabel)
    self.m_ConfirmBtn      = self:NewUI(5, CButton)
    self.m_CoverLabel      = self:NewUI(6, CLabel)
    self.m_CostL           = self:NewUI(7, CLabel)
    self:InitContent()
end

function CEditOrgMailView.InitContent(self)
    self.m_CloseBtn   :AddUIEvent("click", callback(self, "CloseView"))
    self.m_MailInput   :AddUIEvent("change", callback(self, "OnMailTextChange"))
    self.m_ConfirmBtn :AddUIEvent("click", callback(self, "OnConfirmSubmit"))
    self:RecoverLastEditMail()
end

function CEditOrgMailView.CloseView(self)    -- 覆盖 CViewBase.CloseView()，使得在点击 BehindLayer 时能调用到
    if self.m_MailInput ~= nil then
        local tempMail = self.m_MailInput:GetText()
        g_OrgCtrl:SaveOrgTempMail(tempMail)
        -- printc("关闭编辑帮派宗旨界面：临时保存宗旨：" .. tempMail)
    end
    g_ViewCtrl:CloseView(self)
end

function CEditOrgMailView.RecoverLastEditMail(self)
    -- 如果有临时保存的宗旨，就显示，否则显示原宗旨
    local tempMail = g_OrgCtrl:GetOrgTempMail()
    if tempMail ~= nil and tempMail ~= "" then
        -- printc("编辑帮派宗旨界面：恢复临时保存的宗旨：" .. tempMail)
        self.m_MailInput:SetText(tempMail)
    -- else
    --     self.m_MailInput:SetText("点击输入邮件内容")
    end
end

function CEditOrgMailView.OnMailTextChange(self)
    self.m_CoverLabel:SetColor(Color.clear)
    self.m_MailInput.activeTextColor = Color.brown

    local curMail = self.m_MailInput:GetText()
    local charList = g_MaskWordCtrl:GetCharList(curMail)
    local curCharNum = 0
    for i = 1, #charList do
        local curChar = charList[i]
        local utf8 = string.byte(curChar, 1)
        if utf8 > 127 then      -- 如果是 ASCII 字符，那么 +0.5，否则 +1
            curCharNum = curCharNum + 1
        else
            curCharNum = curCharNum + 0.5
        end
    end
    self.m_NumWordLabel:SetText(math.floor(curCharNum) .. "/" .. CEditOrgMailView.MAX_CHINESE_CHAR_NUM)
end

function CEditOrgMailView.OnConfirmSubmit(self)
    local newMail = self.m_MailInput:GetText()
    if g_OrgCtrl:ContainsMaskWordAndHighlight(newMail, self.m_MailInput, self.m_CoverLabel, "内含敏感字") then
        return
    end
    if newMail == "" then
        g_NotifyCtrl:FloatMsg("不能发送空邮件")
        return
    end
    if g_AttrCtrl.energy < data.orgdata.OTHERS[1].mail_cost_energy then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1163].content)
        return
    end
    local iLeftCnt = g_OrgCtrl.m_Org.left_mail_cnt 
    if iLeftCnt > 0 then
        g_OrgCtrl.m_Org.left_mail_cnt = iLeftCnt - 1
        if iLeftCnt - 1 == 0 then
            local oView = COrgInfoView:GetView()
            if oView then
                oView.m_InfoPart:RefreshMailButton()
            end
            self.m_ConfirmBtn:SetGrey(false)
        end
    elseif iLeftCnt == 0 then
        local sText = data.orgdata.TEXT[1174].content 
        local iMailTimes = data.orgdata.OTHERS[1].mail_times
        sText = string.gsub(sText, "#amount", iMailTimes)
        g_NotifyCtrl:FloatMsg(sText)
        return
    end
    -- 没有敏感词，合法提交
    g_OrgCtrl:SaveOrgTempMail("")
    netorg.C2GSSendOrgMail(newMail)
    self:CloseView()
end

return CEditOrgMailView
local CEditOrgAimView = class("CEditOrgAimView", CViewBase)

CEditOrgAimView.MAX_CHINESE_CHAR_NUM = 60  -- 宗旨最多 60 个汉字

function CEditOrgAimView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/EditOrgAimView.prefab", cb)
    self.m_DepthType = "Dialog"
    -- self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CEditOrgAimView.OnCreateView(self)
    self.m_CloseBtn        = self:NewUI(1, CButton)
    self.m_ExplainLabel    = self:NewUI(2, CLabel)
    self.m_AimInput        = self:NewUI(3, CInput)
    self.m_NumWordLabel    = self:NewUI(4, CLabel)
    self.m_ConfirmBtn      = self:NewUI(5, CButton)
    self.m_CoverLabel = self:NewUI(6, CLabel)
    self:InitContent()
end

function CEditOrgAimView.InitContent(self)
    self.m_CloseBtn   :AddUIEvent("click", callback(self, "CloseView"))
    self.m_AimInput   :AddUIEvent("change", callback(self, "OnAimTextChange"))
    self.m_ConfirmBtn :AddUIEvent("click", callback(self, "OnConfirmSubmit"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
    self:RecoverLastEditAim()
end

function CEditOrgAimView.CloseView(self)    -- 覆盖 CViewBase.CloseView()，使得在点击 BehindLayer 时能调用到
    if self.m_AimInput ~= nil then
        local tempAim = self.m_AimInput:GetText()
        g_OrgCtrl:SaveCreateOrgTempInfo("", tempAim)
        -- printc("关闭编辑帮派宗旨界面：临时保存宗旨：" .. tempAim)
    end
    g_ViewCtrl:CloseView(self)
end

function CEditOrgAimView.OnAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
        if g_AttrCtrl.org_id == 0 then
            self:OnClose()
        end
    end
end

function CEditOrgAimView.RecoverLastEditAim(self)
    -- 如果有临时保存的宗旨，就显示，否则显示原宗旨
    local tempName, tempAim = g_OrgCtrl:GetCreateOrgTempInfo()
    if tempAim ~= nil and tempAim ~= "" then
        -- printc("编辑帮派宗旨界面：恢复临时保存的宗旨：" .. tempAim)
        self.m_AimInput:SetText(tempAim)
    else
        -- printc("编辑帮派宗旨界面：没有临时保存的宗旨，显示原宗旨：" .. g_OrgCtrl.m_Org.aim)
        self.m_AimInput:SetText(g_OrgCtrl.m_Org.aim)
    end
end

function CEditOrgAimView.OnAimTextChange(self)
    self.m_CoverLabel:SetColor(Color.clear)
    self.m_AimInput.activeTextColor = Color.brown


    local curAim = self.m_AimInput:GetText()
    local charList = g_MaskWordCtrl:GetCharList(curAim)
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
    self.m_NumWordLabel:SetText(math.floor(curCharNum) .. "/" .. CEditOrgAimView.MAX_CHINESE_CHAR_NUM)
end

function CEditOrgAimView.OnConfirmSubmit(self)
    local newAim = self.m_AimInput:GetText()
    if g_OrgCtrl:ContainsMaskWordAndHighlight(newAim, self.m_AimInput, self.m_CoverLabel, data.orgdata.TEXT[1018].content) then
        return
    end

    -- 没有敏感词，合法提交
    g_OrgCtrl:SaveCreateOrgTempInfo("", newAim)
    netorg.C2GSUpdateAim(newAim)
end

return CEditOrgAimView
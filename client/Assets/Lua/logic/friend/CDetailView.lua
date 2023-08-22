local CDetailView = class("CDetailView", CBox)

function CDetailView.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_MailPart = self:NewUI(2, CDetailMailPart)
    self:InitContent()
end

function CDetailView.InitContent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CDetailView.OnClose(self)
    g_MailCtrl:CloseMail()
end

function CDetailView.SetSimpleInfo(self, mail)
    self.m_MailPart:SetDetailInfo(mail)
end

return CDetailView
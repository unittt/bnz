local COrgPrestigeTipsView = class("COrgPrestigeTipsView", CViewBase)

function COrgPrestigeTipsView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/OrgPrestigeTipsView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main2"
    self.m_ExtendClose = "ClickOut"
end

function COrgPrestigeTipsView.OnCreateView(self)
    self.m_MyPrestigeL = self:NewUI(1, CLabel)
    self.m_RankL = self:NewUI(2, CLabel)
    self.m_GainL = self:NewUI(3, CLabel)

    self:InitContent()
end

function COrgPrestigeTipsView.InitContent(self)
    netorg.C2GSOrgPrestigeInfo()
    self:RefreshTips()

    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
end

function COrgPrestigeTipsView.OnOrgEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Org.Event.UpdatePrestige then
        self:RefreshTips()
    end
end

function COrgPrestigeTipsView.RefreshTips(self)
    self.m_MyPrestigeL:SetText(g_OrgCtrl.m_MyPrestige or 0)
    self.m_RankL:SetText(g_OrgCtrl.m_MyPrestigeRank or 0)
    self.m_GainL:SetText(data.orgdata.TEXT[1147].content)
end

return COrgPrestigeTipsView
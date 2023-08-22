local COrgVaultView = class("COrgVaultView", CViewBase)

function COrgVaultView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/OrgVaultView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main2"
    self.m_ExtendClose = "ClickOut"
end

function COrgVaultView.OnCreateView(self)
    self:InitContent()
end

function COrgVaultView.InitContent(self)
end

return COrgVaultView
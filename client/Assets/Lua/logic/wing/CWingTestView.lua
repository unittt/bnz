local CWingTestView = class("CWingTestView", CViewBase)

function CWingTestView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Wing/WingTestView.prefab", cb)
    --界面设置
    self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"
end

function CWingTestView.OnCreateView(self)
    self.m_ShapeTex = self:NewUI(1, CActorTexture)
    self.m_NameL = self:NewUI(2, CLabel)
    self.m_CloseBtn = self:NewUI(3, CButton)
    self.m_NameL:SetText("")
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CWingTestView.SetWingId(self, iWing)
    local dModelInfo = table.copy(g_AttrCtrl.model_info)
    dModelInfo.show_wing = iWing
    dModelInfo.rendertexSize = 1
    dModelInfo.pos = Vector3(0, -0.75, 3)
    dModelInfo.horse = nil
    self.m_ShapeTex:ChangeShape(dModelInfo)
    local dConfig = g_WingCtrl:GetWingConfig(iWing)
    self.m_NameL:SetText(dConfig.name)
end

return CWingTestView
local CSummonAdjustViewPart = class("CSummonAdjustViewPart", CBox)

function CSummonAdjustViewPart.ctor(self, obj)
    CBox.ctor(self, obj)
    self:InitContent()
end

function CSummonAdjustViewPart.InitContent(self)
    self.m_ViewBox = self:NewUI(1, CSummonViewBox)
    self.m_EquipBox = self:NewUI(2, CSummonViewEquipBox)
end

function CSummonAdjustViewPart.SetInfo(self, info)
    local bNotEmpty = info and true or false
    self.m_ViewBox:SetActive(bNotEmpty)
    self.m_EquipBox:SetActive(bNotEmpty)
    if info then
        self.m_ViewBox:SetInfo(info)
        self.m_EquipBox:SetInfo(info, true)
        self.m_EquipBox:RefreshRedDot()
    end
end

return CSummonAdjustViewPart
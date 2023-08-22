local CSummonBookItemBox = class("CSummonBookItemBox", CBox)

function CSummonBookItemBox.ctor(self, obj)
    CBox.ctor(self, obj)

    self:InitContent()
end

function CSummonBookItemBox.InitContent(self)
    self.m_IconSpr = self:NewUI(1, CSprite)
    self.m_SelSpr = self:NewUI(2, CSprite)
    self.m_QualitySpr = self:NewUI(3, CSprite)
end

function CSummonBookItemBox.SetInfo(self, info)
    self.m_Info = info
    self:RefreshSummonItem(info)
end

function CSummonBookItemBox.RefreshSummonItem(self, info)
    self.m_IconSpr:SetActive(true)
    self.m_IconSpr:SetSpriteName(tostring(info.shape))
    local bGrey = info.carry > g_AttrCtrl.grade
    self.m_IconSpr:SetGrey(bGrey)
end

return CSummonBookItemBox
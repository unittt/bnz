local CWingTipView = class("CWingTipView", CViewBase)

function CWingTipView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Wing/CWingTipView.prefab", cb)
    self.m_DepthType = "Dialog"
end

function CWingTipView.OnCreateView(self)
    self.m_ItemIconSpr = self:NewUI(1, CSprite)
    self.m_QualitySpr = self:NewUI(2, CSprite)
    self.m_NameL = self:NewUI(3, CLabel)
    self.m_LvL = self:NewUI(4, CLabel)
    self.m_StarL = self:NewUI(5, CLabel)
    self.m_DescL = self:NewUI(6, CLabel)
    self.m_DetailBtn = self:NewUI(7, CButton)
    self.m_BgSpr = self:NewUI(8, CSprite)
    self.m_TypeL = self:NewUI(9, CLabel)
    self.m_LvNode = self:NewUI(10, CObject)
    self:InitContent()
end

function CWingTipView.InitContent(self)
    self:RefreshInfo()
    self.m_DetailBtn:AddUIEvent("click", callback(self, "OnClickDetailBtn"))
    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CWingTipView.RefreshInfo(self)
    local dWing = g_WingCtrl:GetBagWingConfig()
    local bTimeWing = dWing.time_wing == 1
    local dItem = g_WingCtrl:GetWingItemData(dWing.wing_id)
    if not dItem then
        self:OnClose()
        return
    end
    self.m_ItemIconSpr:SpriteItemShape(dWing and dWing.icon or dItem.icon)
    self.m_QualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal(dItem.id, dItem.quality or 0))
    self.m_NameL:SetRichText(dItem.name, nil, nil, true)
    self.m_LvNode:SetActive(not bTimeWing)
    self.m_TypeL:SetText("羽翼")
    if bTimeWing then
        self.m_DescL:SetRichText("", nil, nil, true)
        self.m_DescL:SetLocalPos(Vector3(-163, -67, 0))
    else
        self.m_DescL:SetRichText(dItem.description, nil, nil, true)
        self.m_LvL:SetText(math.max(g_WingCtrl.level, 0))
        self.m_StarL:SetText(math.max(g_WingCtrl.star, 0))
        self.m_DescL:SetLocalPos(Vector3(-163, -181, 0))
    end
end

function CWingTipView.OnClickDetailBtn(self)
    if g_WingCtrl:ShowWingPropertyPage() then
        self:OnClose()
    end
end

return CWingTipView
local CWingAttrBox = class("CWingAttrBox", CBox)

function CWingAttrBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_Grid = self:NewUI(1, CGrid)
    self.m_AttrItem = self:NewUI(2, CBox)
    self.m_ScrollView = self:NewUI(3, CScrollView)
    self.m_AttrItem:SetActive(false)
end

-- attrs: repeated {key = xxx, val = xxx}
function CWingAttrBox.RefreshAttr(self, attrs)
    self.m_Grid:HideAllChilds()
    for i, dAttr in ipairs(attrs) do
        local oBox = self:GetAttrItemBox(i)
        local dConfig = g_WingCtrl:GetAttrNameData(dAttr.key)
        if string.find(dAttr.key, "ratio") then
            oBox.valL:SetText(string.format("%d%%", dAttr.val))
        else
            oBox.valL:SetText(dAttr.val)
        end
        oBox.nameL:SetText(dConfig.name)
        if string.len(dConfig.name) > 6 then
            oBox.nameL:SetSpacingX(0)
        else
            oBox.nameL:SetSpacingX(40)
        end
    end
end

function CWingAttrBox.GetAttrItemBox(self, i)
    local oBox = self.m_Grid:GetChild(i)
    if not oBox then
        oBox = self.m_AttrItem:Clone()
        oBox.nameL = oBox:NewUI(1, CLabel)
        oBox.valL = oBox:NewUI(2, CLabel)
        self.m_Grid:AddChild(oBox)
    end
    oBox:SetActive(true)
    return oBox
end

return CWingAttrBox
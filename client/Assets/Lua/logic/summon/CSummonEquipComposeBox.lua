local CSummonEquipComposeBox = class("CSummonEquipComposeBox", CBox)

function CSummonEquipComposeBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_ItemGrid = self:NewUI(1, CGrid)
    self.m_ItemBox = self:NewUI(2, CBox)
    self.m_ItemBox:SetActive(false)
    self.m_SelList = {}
end

function CSummonEquipComposeBox.SetInfo(self, oItem, bChoosed)
    if oItem then
        if bChoosed then
            table.insert(self.m_SelList, oItem)
        else
            local idx = table.index(self.m_SelList, oItem)
            if idx then
                table.remove(self.m_SelList, idx)
            end
        end
    else
        self.m_SelList = {}
    end
    self:RefreshEquips()
end

function CSummonEquipComposeBox.RefreshEquips(self)
    self.m_ItemGrid:HideAllChilds()
    for i, oItem in ipairs(self.m_SelList) do
        local oBox = self:GetItemBox(i)
        oBox:SetActive(true)
        oBox.itemObj = oItem
        oBox.iconSpr:SpriteItemShape(oItem:GetCValueByKey("icon"))
        oBox.qualitySpr:SetItemQuality(oItem:GetCValueByKey("quality"))
    end
end

function CSummonEquipComposeBox.GetItemBox(self, idx)
    local oBox = self.m_ItemGrid:GetChild(idx)
    if not oBox then
        oBox = self.m_ItemBox:Clone()
        oBox.iconSpr = oBox:NewUI(1, CSprite)
        oBox.qualitySpr = oBox:NewUI(2, CSprite)
        oBox:AddUIEvent("click", callback(self, "OnClickItem", oBox))
        self.m_ItemGrid:AddChild(oBox)
    end
    return oBox
end

function CSummonEquipComposeBox.GetEquipIds(self)
    local ids = {}
    for i, oItem in ipairs(self.m_SelList) do
        table.insert(ids, oItem.m_ID)
    end
    return ids
end

function CSummonEquipComposeBox.OnClickItem(self, oBox)
    if not oBox.itemObj then return end
    local oView = CSummonEquipEditView:GetView()
    if oView then
        oView:ShowItemTip(oBox.itemObj)
    end
end

return CSummonEquipComposeBox
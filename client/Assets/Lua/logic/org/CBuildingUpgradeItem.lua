local CBuildingUpgradeItem = class("CBuildingUpgradeItem", CBox)

function CBuildingUpgradeItem.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_ItemBG = self:NewUI(1, CSprite)
    self.m_Sprite = self:NewUI(2, CSprite)
    self.m_Label  = self:NewUI(3, CLabel)
    self.m_Info = nil
    self:InitContent()
end

function CBuildingUpgradeItem.InitContent(self)
    self.m_ItemBG:AddUIEvent("click", callback(self, "ItemCallBack"))
end

function CBuildingUpgradeItem.SetGroup(self, groupId)
    self.m_ItemBG:SetGroup(groupId)
end

function CBuildingUpgradeItem.SetBoxInfo(self, building, callback)
    if building == nil or next(building) == nil then
        return
    end
    self.m_CallBack = callback
    self.m_Info = building
    self.m_Sprite:SetSpriteName(data.orgdata.BUILDLEVEL[building.bid][1].icon)
    self.m_Label:SetText(data.orgdata.BUILDLEVEL[building.bid][1].name)
    if building.level <= 0 then
        self.m_Sprite:SetGrey(true)
    else
        self.m_Sprite:SetGrey(false)
    end
end

function CBuildingUpgradeItem.ItemCallBack(self)
    if self.m_CallBack then
        self.m_CallBack()                    
    end
end

function CBuildingUpgradeItem.SetSelected(self)
    self.m_ItemBG:SetSelected(true)
end

return CBuildingUpgradeItem
local CScheduleCrapsItemBox = class("CScheduleCrapsItemBox", CBox)

function CScheduleCrapsItemBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
    self.m_ItemGrid = self:NewUI(1, CGrid)
    self.m_ItemClone = self:NewUI(2, CBox)
    self.m_SureBtn = self:NewUI(3, CButton)
    self.m_SureBtn:AddUIEvent("click",function ()
        self:SetActive(false)
    end)
end

function CScheduleCrapsItemBox.SetInfo(self, info)
    self.m_ItemGrid:Clear()
    for k,v in pairs(info) do
        local item = self.m_ItemClone:Clone()
        item:SetActive(true)
        local itemData = DataTools.GetItemData(v)
        item.icon = item:NewUI(1, CSprite)
        item.name = item:NewUI(2, CLabel)
        item.icon:SetSpriteName(tostring(itemData.icon))
        item.name:SetText(itemData.name)
        item.icon:AddUIEvent("click", callback(self, "OnShowItemTips", v, item))
        self.m_ItemGrid:AddChild(item)
    end
     self.m_ItemGrid:Reposition()
end

function CScheduleCrapsItemBox.OnShowItemTips(self, id, item)
    g_WindowTipCtrl:SetWindowItemTip(id, {widget = item, side = enum.UIAnchor.Side.Top}) 
end

return CScheduleCrapsItemBox
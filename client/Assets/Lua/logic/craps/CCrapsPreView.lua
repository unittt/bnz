local CCrapsPreView = class("CCrapsPreView", CViewBase)

function CCrapsPreView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Schedule/Carapspreview.prefab", cb)
    self.m_ExtendClose = "Black"
end

function CCrapsPreView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_Grid = self:NewUI(2, CGrid)
    self.m_ItemClone = self:NewUI(3, CBox)
    self.m_ItemClone:SetActive(false)

    self:InitContent()
end

function CCrapsPreView.InitContent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    local rewardInfo = data.scheduledata.LUCKYREWARD[1].m_info
    for k,v in pairs(rewardInfo) do
        local clone = nil
        clone = self.m_ItemClone:Clone()
        clone.icon = clone:NewUI(1, CSprite)
        clone:SetActive(true) 
        clone:SetGroup(self.m_Grid:GetInstanceID())
        self.m_Grid:AddChild(clone)
        clone:AddUIEvent("click", callback(self, "OnTips",v.itemsid,clone))
        clone.icon:SpriteItemShape(DataTools.GetItemData(v.itemsid).icon)
    end
end

function CCrapsPreView.OnTips(self, id, box)
    g_WindowTipCtrl:SetWindowItemTip(id, {widget = box, side = enum.UIAnchor.Side.Top})
end

return CCrapsPreView
local COrgWelfareItemTipsView = class("COrgWelfareItemTipsView", CViewBase)

function COrgWelfareItemTipsView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/OrgWelfareItemTipsView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "ClickOut"
end

function COrgWelfareItemTipsView.OnCreateView(self)
    self.m_Grid           = self:NewUI(1, CGrid)
    self.m_ItemClone      = self:NewUI(2, CBox)
    self.m_Bg             = self:NewUI(3, CSprite)
    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function COrgWelfareItemTipsView.InitContent(self, info, targetWid)
    UITools.NearTarget(targetWid, self.m_Bg, enum.UIAnchor.Side.Right)
    self.m_Grid:Clear()
    for k,v in pairs(info) do
        local item = self.m_ItemClone:Clone()
        item:SetActive(true)
        item.icon = item:NewUI(1, CSprite)
        item.count = item:NewUI(2, CLabel)
        local t = DataTools.GetItemData(v.id)
        item.icon:SetSpriteName(tostring(t.icon))
        item.count:SetText(v.val)
        item:AddUIEvent("click", callback(self, "OnItemTips", item, v.id))
        self.m_Grid:AddChild(item)
    end
end

function COrgWelfareItemTipsView.OnItemTips(self, item, id)
    local config = {widget = item}
	g_WindowTipCtrl:SetWindowItemTip(id, config)
end

return COrgWelfareItemTipsView
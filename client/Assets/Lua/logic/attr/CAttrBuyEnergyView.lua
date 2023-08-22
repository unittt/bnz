local CAttrBuyEnergyView = class("CAttrBuyEnergyView", CViewBase)

function CAttrBuyEnergyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/AttrBuyEnergyView.prefab", cb)
	self.m_ExtendClose = "Black"
    self.m_ItemId = 10010
end

function CAttrBuyEnergyView.OnCreateView(self)
    self.m_Icon = self:NewUI(1, CSprite)
	self.m_BuyBtn = self:NewUI(2, CButton)
    self.m_ItemName = self:NewUI(3, CLabel)
    self.m_Spend = self:NewUI(4, CLabel)
    self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_BuyBtn:AddUIEvent("click",callback(self, "OnBuy"))
    self.m_CloseBtn:AddUIEvent("click",callback(self, "OnClose"))
    local itemInfo = DataTools.GetItemData(self.m_ItemId)
    self.m_Icon:SetSpriteName(itemInfo.icon)
    self.m_ItemName:SetText(itemInfo.name)
    self.m_Spend:SetText(itemInfo.buyPrice)
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnQuickUse"))
end

function CAttrBuyEnergyView.OnBuy(self)
    --printc("购买")
    -- local t = {itemid = self.m_ItemId, pos = self.m_Icon:GetPos()}
    -- local tb = {}
    -- table.insert(tb, t)
    -- g_ItemCtrl:NeedFloatItemView(tb)
	netstore.C2GSFastBuyItem(self.m_ItemId, 1)
    self:CloseView()
end

function CAttrBuyEnergyView.OnQuickUse(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
       self:CloseView()
    end
end

return CAttrBuyEnergyView
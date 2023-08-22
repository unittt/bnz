local CSummonStorePart = class("CSummonStorePart", CPageBase)

function CSummonStorePart.ctor(self, cb)
	CPageBase.ctor(self, cb)
    self.m_ItemId = 10031
end

function CSummonStorePart.OnInitPage(self)
	self.m_BuyBtn = self:NewUI(1, CButton)
    self.m_CoinsLabel = self:NewUI(2, CLabel)
    self.m_AddCoinsBtn = self:NewUI(3, CButton)
    self.m_RItemGrid = self:NewUI(4, CGrid)
    self.m_RItemClone = self:NewUI(5, CBox)
    self.m_ScrollView = self:NewUI(6, CScrollView)
    self.m_LItemGrid = self:NewUI(7, CGrid)
    self.m_LItemClone = self:NewUI(8, CButton)
    self.m_HintLabel = self:NewUI(9, CLabel)
    self.m_CoinName = self:NewUI(10, CLabel)
    self.m_CostLabel = self:NewUI(11, CLabel)
	self:InitContent()
    self:InitLGird()
end

function CSummonStorePart.InitContent(self)
    self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuySummon"))
	self.m_AddCoinsBtn:AddUIEvent("click", callback(self, "OnSilverAddBtn"))
    self.m_CoinsLabel:SetCommaNum(g_AttrCtrl.silver)
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
    g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlSummonEvent"))
    self.m_CostLabel:SetText(0)
end

function CSummonStorePart.InitLGird(self)
    local list = {}
    for k,v in pairs(data.summondata.USEGRADE) do
        table.insert(list, k)
    end
    table.sort(list, function (v1, v2)
        return v1 < v2
    end)
    for k,v in pairs(list) do
        local item = self.m_LItemClone:Clone()
        item:SetActive(true)
        item:SetGroup(self.m_LItemGrid:GetInstanceID())
        item:SetText("携带等级"..v)
        item:AddUIEvent("click", callback(self, "OnSelectUseGrade", v))
        self.m_LItemGrid:AddChild(item)
    end
    self:OnSelectUseGrade(0)  --默认显示携带等级为0级的宠物
    self.m_LItemGrid:GetChild(1):SetSelected(true)
end

function CSummonStorePart.OnSelectUseGrade(self, grade)
    for k,v in pairs(data.summondata.USEGRADE[grade]) do
        local item = self.m_RItemGrid:GetChild(k)
        if item == nil then
            item = self.m_RItemClone:Clone()
            item:SetGroup(self.m_RItemGrid:GetInstanceID())
            item.name = item:NewUI(1, CLabel)
            item.icon = item:NewUI(2, CSprite)
            self.m_RItemGrid:AddChild(item)    
        end
        item:SetActive(true)
        local summonInfo = DataTools.GetSummonInfo(v)
        item.name:SetText(summonInfo.name)
        item.icon:SetSpriteName(tostring(summonInfo.shape))
        item:SetSelected(false)
        item:AddUIEvent("click", callback(self, "OnSelectSummon", v))
    end
    local count = #data.summondata.USEGRADE[grade]
    for i = count + 1, self.m_RItemGrid:GetCount() do
        self.m_RItemGrid:GetChild(i):SetActive(false)               
    end
    self.m_ScrollView:ResetPosition()
    --self.m_CoinName:SetText("拥有")
    self.m_CoinsLabel:SetText(g_AttrCtrl.silver)
    self.m_CurSummonId = nil
    self.m_CostLabel:SetText(0)
end

function CSummonStorePart.OnSelectSummon(self, id)
    --local summonInfo = DataTools.GetSummonInfo(id)
    --self.m_CoinName:SetText("消耗")
    self.m_CostLabel:SetText(data.summondata.STORE[id].price)
    --self.m_CoinsLabel:SetText(data.summondata.STORE[id].price)
    self.m_CurSummonId = id
end

function CSummonStorePart.OnAttrEvent(self, oCtrl)
   self.m_CoinsLabel:SetText(g_AttrCtrl.silver)
end

function CSummonStorePart.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Task.Event.AddTask or oCtrl.m_EventID == define.Task.Event.DelTask then
        --self:InitGridBox()
    end
end

function CSummonStorePart.OnCtrlSummonEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Summon.Event.AddSummon or oCtrl.m_EventID == define.Summon.Event.DelSummon then
       -- self:InitGridBox()
    end
end

function CSummonStorePart.OnBuySummon(self)
    if self.m_CurSummonId == nil then
        g_NotifyCtrl:FloatMsg("请选择宠物")
        return
    end
    if (g_AttrCtrl.silver < self:GetSummonPrice(self.m_CurSummonId)) then
        g_NotifyCtrl:FloatMsg("银币不足，购买失败")
        return
    end
    if g_AttrCtrl.grade < data.summondata.STORE[self.m_CurSummonId].usegrade then
        g_NotifyCtrl:FloatMsg("等级不足")
        return
    end
    netsummon.C2GSBuySummon(self.m_CurSummonId)
end

function CSummonStorePart.GetSummonPrice(self, summonId)
    if data.summondata.STORE[summonId] then
        return data.summondata.STORE[summonId].price
    end
end

function CSummonStorePart.GetSummonName(self, summonId)
    if data.summondata.STORE[summonId] then
        return data.summondata.STORE[summonId].name
    end
end

function CSummonStorePart.OnSilverAddBtn(self)
    -- CCurrencyView:ShowView(
    --     function(oView)
    --         oView:SetCurrencyView(define.Currency.Type.Silver)
    --     end
    -- )
    g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
end

return CSummonStorePart
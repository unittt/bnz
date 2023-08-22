local CPKFailView = class("CPKFailView", CViewBase)

function CPKFailView.ctor(self, cb)
    CViewBase.ctor(self, "UI/PK/PkFailView.prefab", cb)
    self.m_ExtendClose = "Black"
end

function CPKFailView.OnCreateView(self)
    self.m_Grid = self:NewUI(1, CGrid)      --奖励物品列表
    self.m_RewardClone = self:NewUI(2, CBox) --奖励物品克隆体
    self.m_OkBtn = self:NewUI(3, CButton)   --确定按钮
    self.m_Result = self:NewUI(4, CLabel)

    self.m_OkBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_RewardClone:SetActive(false)
end

function CPKFailView.InitContent(self, info)
    if info.prewincount then
       self.m_Result:SetActive(info.prewincount > 0)
    end 
    self:RefreshItem(info)
    self:InitReward(info.itemlist)
end

function CPKFailView.InitReward(self, rewardlist)
    for i,v in pairs(rewardlist) do
        if v.amount > 0 then
            local data = DataTools.GetItemData(v.itemsid)
            self:InitItemBox(v.amount, data)
        end
    end
end

function CPKFailView.OnClose(self)
    self:CloseView()
end

function CPKFailView.InitItemBox(self, value, data)
    local oItemBox = self.m_RewardClone:Clone()
    oItemBox.icon = oItemBox:NewUI(1, CSprite)
    oItemBox.num = oItemBox:NewUI(2, CLabel)
    oItemBox.qulity = oItemBox:NewUI(3, CSprite)
    self.m_Grid:AddChild(oItemBox)
    oItemBox:SetActive(true)

    oItemBox.icon:AddUIEvent("click", function ()
        local config = {widget = oItemBox.icon}
        g_WindowTipCtrl:SetWindowItemTip(data.id, config)
        -- g_WindowTipCtrl:SetWindowGainItemTip(v.info.id)
    end)

    oItemBox.num:SetText(value)
    oItemBox.icon:SetSpriteName(data.icon)
    oItemBox.qulity:SetItemQuality(g_ItemCtrl:GetQualityVal( data.id, data.quality or 0 ))
end

function CPKFailView.RefreshItem(self, info)
    if info.exp > 0 then
        local expData = DataTools.GetItemData(1005)
        self:InitItemBox(info.exp, expData)
    end
    if info.silver > 0 then
        local silverData = DataTools.GetItemData(1002)
        self:InitItemBox(info.silver, silverData)
    end
    if info.sumexp > 0 then
        local sumexpData = DataTools.GetItemData(1007)
        self:InitItemBox(info.sumexp, sumexpData)
    end
    -- self:InitItemBox(info.point, 10008)
end

return CPKFailView
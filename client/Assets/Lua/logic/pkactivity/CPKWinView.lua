local CPKWinView = class("CPKWinView", CViewBase)

function CPKWinView.ctor(self, cb)
    CViewBase.ctor(self, "UI/PK/PkWinView.prefab", cb)
    self.m_ExtendClose = "Black"
end

function CPKWinView.OnCreateView(self)
    self.m_WinNum = self:NewUI(1, CLabel)
    self.m_Grid = self:NewUI(2, CGrid)
    self.m_RewardClone = self:NewUI(3, CBox)
    self.m_OkBtn = self:NewUI(4, CButton)
    
    self.m_RewardClone:SetActive(false)
    self.m_OkBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CPKWinView.InitContent(self,info)
    local bwInfo = info 
    self.m_WinNum:SetText("连胜："..bwInfo.wincount)
    self:RefreshItem(bwInfo)
    self:InitReward(bwInfo.itemlist)
end

function CPKWinView.InitReward(self,rewardlist)
    for i,v in pairs(rewardlist) do
        if v.amount > 0 then
            local data = DataTools.GetItemData(v.itemsid)
            self:InitItemBox(v.amount, data)
        end
    end
end

function CPKWinView.OnClose(self)
    self:CloseView()
end

function CPKWinView.InitItemBox(self, value, data)
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

function CPKWinView.RefreshItem(self, info)
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

return CPKWinView
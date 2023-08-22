local CBonfireWineView = class("CBonfireWineView", CViewBase)

function CBonfireWineView.ctor(self, cb)
	CViewBase.ctor(self, "UI/bonfire/BonfireWineView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
    self.m_ItemId = 11140
end

function CBonfireWineView.OnCreateView(self)
    for i=1, 4 do
        self["m_Item_0"..i] = self:NewUI(i, CBox)
    end
    self.m_CancelBtn = self:NewUI(5, CButton)
	self.m_SureBtn = self:NewUI(6, CButton)
    self.m_PaySureBox = self:NewUI(7, CBox)
    self.m_CloseBtn = self:NewUI(8, CButton)
    self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_SureBtn:AddUIEvent("click", callback(self, "OnSure"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_BonfireCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))
    self:InitWine()
    self:InitAward()
    self:InitCoin()
    self:InitPaySureBox()
end

function CBonfireWineView.InitWine(self)
    self.m_WineIcon = self.m_Item_01:NewUI(1, CSprite)
    self.m_WineAddBtn = self.m_Item_01:NewUI(2, CButton)
    self.m_WineReduceBtn = self.m_Item_01:NewUI(3, CButton)
    self.m_WineCount = self.m_Item_01:NewUI(4, CLabel)
    self.m_WineNumber = 0
    self.m_WineCount:SetText(self.m_WineNumber)
    self.m_WineAddBtn:AddUIEvent("click", callback(self, "OnAdd"))
    self.m_WineReduceBtn:AddUIEvent("click", callback(self, "OnReduce"))
    local item = DataTools.GetItemData(self.m_ItemId)
    self.m_WineIcon:SpriteItemShape(tostring(item.icon))
end

function CBonfireWineView.InitCoin(self)
    self.m_CoinIcon = self.m_Item_02:NewUI(1, CSprite)
    self.m_CoinCount = self.m_Item_02:NewUI(2, CLabel)
    self.m_ExpRate = self.m_Item_03:NewUI(1, CLabel)
    self.m_OrgOffer = self.m_Item_04:NewUI(1, CLabel)
    self.m_ExpRate:SetText(0)
    self.m_OrgOffer:SetText(0)
end

function CBonfireWineView.InitAward(self)
    self.m_Addition = self.m_Item_03:NewUI(1, CLabel)
    self.m_OrgContribute = self.m_Item_04:NewUI(1, CLabel)
end

function CBonfireWineView.InitPaySureBox(self)
    self.m_PaySureHintLabel = self.m_PaySureBox:NewUI(1, CLabel)
    self.m_PaySureCoinCount = self.m_PaySureBox:NewUI(2, CLabel)
    self.m_PaySureBoxCancelBtn = self.m_PaySureBox:NewUI(3, CButton)
    self.m_PaySureBoxSureBtn = self.m_PaySureBox:NewUI(4, CButton)
    self.m_PaySureItemIcon = self.m_PaySureBox:NewUI(5, CSprite)
    self.m_PaySureBoxCloseBtn = self.m_PaySureBox:NewUI(6, CButton)
    self.m_buyPrice = DataTools.GetItemData(self.m_ItemId).buyPrice
    self.m_PaySureBoxCancelBtn:AddUIEvent("click", function ()
        self.m_PaySureBox:SetActive(false)
        self.BagItemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
        self.m_CoinCount:SetText((self.m_WineNumber-self.BagItemCount)*self.m_buyPrice)
    end)
    self.m_PaySureBoxCloseBtn:AddUIEvent("click", function ()
        self.m_PaySureBox:SetActive(false)
        self.BagItemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
        self.m_CoinCount:SetText((self.m_WineNumber-self.BagItemCount)*self.m_buyPrice)
    end)
    self.m_PaySureBoxSureBtn:AddUIEvent("click", callback(self, "OnPaySure"))
    local item = DataTools.GetItemData(self.m_ItemId)
    --self.m_PaySureItemIcon:SetSpriteName(tostring(item.icon))
end

function CBonfireWineView.OnEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Bonfire.Event.SwitchScene then
        if oCtrl.m_EventData == 0 then
            self:OnClose()
        end
    end
    if oCtrl.m_EventID == define.Bonfire.Event.EndBonfireActive then
        self:OnClose()
    end
end

function CBonfireWineView.OnSure(self)
    if self.m_WineNumber <= 0 then
        g_NotifyCtrl:FloatMsg("请输入数量！")
        return
    end
    self.BagItemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
    local count = self.m_WineNumber-self.BagItemCount
    if count > 0 then
        self.m_PaySureHintLabel:SetText(string.format("你确定需要进行%d次祝酒？", count))
        self.m_PaySureCoinCount:SetText(count*self.m_buyPrice)
        self.m_PaySureBox:SetActive(true)
    elseif self.m_WineNumber > 0 then
        g_BonfireCtrl:C2GSCampfireDrink(self.m_WineNumber)
    end
end

function CBonfireWineView.OnAdd(self)
    if  self.m_WineNumber >= 5 then
        return
    end
    self.m_WineNumber = self.m_WineNumber + 1
    self:SetCount()
end

function CBonfireWineView.OnReduce(self)
    if self.m_WineNumber <= 0 then
        return
    end
    self.m_WineNumber = self.m_WineNumber - 1
    if self.m_WineNumber <= 0 then
        self.m_CoinCount:SetText(0)
    end
    self:SetCount()
end

function CBonfireWineView.SetCount(self)
    if self.m_WineNumber < 0 then
        return
    end
    self.m_WineCount:SetText(self.m_WineNumber)
    self.m_ExpRate:SetText(data.bonfiredata.CONFIG.adds_per_drink*self.m_WineNumber.."%")
    self.m_OrgOffer:SetText(DataTools.GetBonfireWineReward(self.m_WineNumber))
    self.BagItemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
    if self.m_WineNumber >= self.BagItemCount then
        self.m_CoinCount:SetText((self.m_WineNumber-self.BagItemCount)*self.m_buyPrice)
    else
        self.m_CoinCount:SetText(0)
    end
end

function CBonfireWineView.OnPaySure(self)
    --local count = self.m_WineNumber-self.BagItemCount
    g_BonfireCtrl:C2GSCampfireDrink(self.m_WineNumber)
    self.m_PaySureBox:SetActive(false)
    -- if count > 0 then
    --     netstore.C2GSFastBuyItem(self.m_ItemId, count)
    -- end
end

return CBonfireWineView

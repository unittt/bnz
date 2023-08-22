local CBonfireGiveView = class("CBonfireGiveView", CViewBase)

function CBonfireGiveView.ctor(self, cb)
	CViewBase.ctor(self, "UI/bonfire/BonfireGiveView.prefab", cb)
	self.m_GroupName = "sub"
	self.m_ExtendClose = "Black"
    self.m_ItemId = 11141
end

function CBonfireGiveView.OnCreateView(self)
    self.m_ItemGrid = self:NewUI(1, CGrid)
    self.m_ItemClone = self:NewUI(2, CBox)
    self.m_ColseBtn = self:NewUI(3, CButton)
    self.m_CancelBtn = self:NewUI(4, CButton)
    self.m_SureBtn = self:NewUI(5, CButton)
    self.m_GiveHint = self:NewUI(6, CLabel)
    self.m_GiveSureBox = self:NewUI(7, CBox)
    self.m_BuyBox = self:NewUI(8, CBox)
    self.m_BuyBoxHint = self:NewUI(9, CLabel)
    self.m_BuyBoxCancelBtn = self:NewUI(10, CButton)
    self.m_BuyBoxSureBtn = self:NewUI(11, CButton)
    self.m_GiftItemIcon = self:NewUI(12, CSprite)
    self.m_EmptyHint = self:NewUI(13, CBox)
    self.m_RemainCount = self:NewUI(14, CLabel)
    self.m_BuyBoxClose = self:NewUI(15, CButton)
    self.m_m_GiveSureBoxCloseBtn = self:NewUI(16, CButton)
    self.m_GoldcoinLabel = self:NewUI(17, CLabel)

    self:InitContent()
    self.m_ItemInfo = DataTools.GetItemData(self.m_ItemId)
    if g_BonfireCtrl.m_GivenTimes then
        self.m_RemainCount:SetText(string.format("还可赠送%s/%s", g_BonfireCtrl.m_GivenTimes.give_times_limit-g_BonfireCtrl.m_GivenTimes.given_times, g_BonfireCtrl.m_GivenTimes.give_times_limit))
    end
end

function CBonfireGiveView.InitContent(self)
    self.m_ItemClone:SetActive(false)
    self.m_GiveSureBox:SetActive(false)
    self.m_BuyBox:SetActive(false)

    self.m_ColseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_CancelBtn:AddUIEvent("click", callback(self.m_GiveSureBox, "SetActive", false))
    self.m_m_GiveSureBoxCloseBtn:AddUIEvent("click", callback(self.m_GiveSureBox, "SetActive", false))
    self.m_BuyBoxCancelBtn:AddUIEvent("click", callback(self.m_BuyBox, "SetActive", false))
    self.m_BuyBoxClose:AddUIEvent("click", callback(self.m_BuyBox, "SetActive", false))
    self.m_BuyBoxSureBtn:AddUIEvent("click", callback(self, "OnSureBuy"))
    self.m_SureBtn:AddUIEvent("click", callback(self, "OnSure"))
    
    g_BonfireCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRefreshItem"))
end

function CBonfireGiveView.OnEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Bonfire.Event.ShowGiftables then
        self:InitGrid(oCtrl.m_EventData)   
    end       
    if oCtrl.m_EventID == define.Bonfire.Event.SwitchScene then
        if oCtrl.m_EventData == 0 then
            self:OnClose()
        end
    end
    if oCtrl.m_EventID == define.Bonfire.Event.EndBonfireActive then
        self:OnClose()
    end
    if oCtrl.m_EventID == define.Bonfire.Event.GiftTimes then
        self.m_RemainCount:SetText(string.format("还可赠送%s/%s个", oCtrl.m_EventData.give_times_limit-oCtrl.m_EventData.given_times, oCtrl.m_EventData.give_times_limit))
    end
end

function CBonfireGiveView.OnRefreshItem(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddBagItem or 
    oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
        local itemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
        for k,v in pairs(self.m_ItemGrid:GetChildList()) do
            if itemCount <= 0 then
                v.count:SetText("[af302a]"..itemCount.."[-]")
                v.count:SetEffectColor(Color.RGBAToColor("FFF9E3FF"))
            else
                v.count:SetText(itemCount)
                v.count:SetEffectColor(Color.RGBAToColor("043A4CFF"))            
            end
        end
	end
end

function CBonfireGiveView.InitGrid(self, info)
    if next(info) == nil then
        self.m_EmptyHint:SetActive(true)
        self.m_ItemGrid:SetActive(false)
        return
    end
    self.m_EmptyHint:SetActive(false)
    self.m_ItemGrid:SetActive(true)
    self.m_ItemGrid:Clear()
    local itemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
    for k,v in pairs(info) do
        local item = self.m_ItemClone:Clone()
        item:SetActive(true)
        item.icon = item:NewUI(1, CSprite)
        item.title = item:NewUI(2, CLabel)
        item.name = item:NewUI(3, CLabel)
        item.grade = item:NewUI(4, CLabel)
        item.duty = item:NewUI(5, CLabel)
        item.relation = item:NewUI(6, CLabel)
        item.givebtn = item:NewUI(7, CButton)
        item.count = item:NewUI(8, CLabel)
        item.icon:SetSpriteName(tostring(v.icon))
        if itemCount >= 1 then
            item.count:SetText("[0fff32]"..itemCount)
            item.count:SetEffectColor(Color.RGBAToColor("003C41"))
        else
            item.count:SetText("[ffb398]"..itemCount)
            item.count:SetEffectColor(Color.RGBAToColor("cd0000"))
        end
        item.name:SetText(v.name)
        item.grade:SetText(v.grade.."级")
        local pos = data.orgdata.POSITIONID[v.org_pos]
        if pos then
            item.duty:SetText(pos.name)
        else
            item.duty:SetText("帮众")
        end
        if g_FriendCtrl:IsMyFriend(v.pid) then
            item.relation:SetText("#G好友#n")
        else
            item.relation:SetText("[896055FF]普通[-]")
        end
        item.givebtn:AddUIEvent("click", callback(self, "OnGive", v))
        self.m_ItemGrid:AddChild(item)
    end
end

function CBonfireGiveView.OnGive(self, info)
    self.m_CurInfo = info 
    self.m_GiveHint:SetText(string.format("[896055FF]是否赠送一个%s给\n[-][008585FF]【%s】[-]", self.m_ItemInfo.name, self.m_CurInfo.name))
    self.m_GiveSureBox:SetActive(true)
end

function CBonfireGiveView.OnSure(self)
    self.BagItemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
    if self.BagItemCount < 1 then
        self.m_BuyBoxHint:SetText(string.format("[896055FF]%s不足，是否购买并赠送给[-]\n[008585FF]【%s】[-]", self.m_ItemInfo.name, self.m_CurInfo.name))
        self.m_GoldcoinLabel:SetText(self.m_ItemInfo.buyPrice)
        self.m_BuyBox:SetActive(true)
    else
        g_BonfireCtrl:C2GSCampfireToGift(self.m_CurInfo.pid)
    end
    self.m_GiveSureBox:SetActive(false)
end

function CBonfireGiveView.OnSureBuy(self)
    g_BonfireCtrl:C2GSCampfireToGift(self.m_CurInfo.pid)  
    self.m_BuyBox:SetActive(false)
end

return CBonfireGiveView
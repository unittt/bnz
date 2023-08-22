local CBonfireGetItemView = class("CBonfireGetItemView", CViewBase)

function CBonfireGetItemView.ctor(self, cb)
	CViewBase.ctor(self, "UI/bonfire/BonfireGetItemView.prefab", cb)
	self.m_GroupName = "sub"
	self.m_ExtendClose = "Black"
    self.m_ItemId = 11141
    self.m_IsRecordTime = true
end

function CBonfireGetItemView.OnCreateView(self)
    self.m_ShowTime = self:NewUI(1, CLabel)
    self.m_HintLabel = self:NewUI(2, CLabel)
    self.m_ThankBtn = self:NewUI(3, CButton)
    self.m_QuickThankBtn = self:NewUI(4, CButton)
    self.m_CloseBtn = self:NewUI(5, CButton)
    self.m_QuickAcknowledgeBox = self:NewUI(6, CBonfireQuickAcknowledgeBox)
    self.m_AddFriendHint = self:NewUI(7, CLabel)
    self.m_CancelBtn = self:NewUI(8, CButton)
    self.m_SureBtn = self:NewUI(9, CButton)
    self.m_AddFriendBox = self:NewUI(10, CBox)
    self.m_GiveSureBox = self:NewUI(11, CBox)
    self.m_BuyBox = self:NewUI(12, CBox)
    self.m_ThankBtn:AddUIEvent("click", callback(self, "OnThank"))
    self.m_QuickThankBtn:AddUIEvent("click", callback(self, "OnQuickThank"))
    self.m_CancelBtn:AddUIEvent("click", function ()
        self.m_AddFriendBox:SetActive(false)
    end)
    self.m_SureBtn:AddUIEvent("click", callback(self, "OnAddFriend"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_BonfireCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))
    self.m_QuickAcknowledgeBox:SetActive(false)
    self.m_AddFriendBox:SetActive(false)
    self:InitBuyGiftBox()
    self:InitGiveSureBox()
    self:ShowCountDown()
    self.m_ItemInfo = DataTools.GetItemData(self.m_ItemId)
end

function CBonfireGetItemView.OnEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Bonfire.Event.SwitchScene then
        if oCtrl.m_EventData == 0 then
            self:OnClose()
        end
    end
    if oCtrl.m_EventID == define.Bonfire.Event.EndBonfireActive then
        self:OnClose()
    end
end

function CBonfireGetItemView.ShowCountDown(self) --显示倒计时
    local total = 30 
    local function update()
        if self.m_IsRecordTime == false then
            return true
        end
        if self.m_ShowTime:IsDestroy() or total <= 0 then
            self:OnClose()
            return false
        end
        self.m_ShowTime:SetText("界面[FF530FFF]"..total.."[-]s后自动关闭")
        total = total - 1
        return true         
    end
    if self.m_UpdateTimer then
        Utils.DelTimer(self.m_UpdateTimer)
    end
    self.m_UpdateTimer = Utils.AddTimer(update, 1, 0)
end

function CBonfireGetItemView.InitGiveSureBox(self)
    self.m_GiveSureBox:SetActive(false)
    self.m_GiveGiftHint = self.m_GiveSureBox:NewUI(1, CLabel)
    self.m_GiveGiftCancelBtn = self.m_GiveSureBox:NewUI(2, CButton)
    self.m_GiveGiftSureBtn = self.m_GiveSureBox:NewUI(3, CButton)
    self.m_GiveGiftCloseBtn = self.m_GiveSureBox:NewUI(4, CButton)
    self.m_GiveGiftCancelBtn:AddUIEvent("click", function ()
        self.m_IsRecordTime = true
        self.m_GiveSureBox:SetActive(false)
    end)
    self.m_GiveGiftCloseBtn:AddUIEvent("click", function ()
        self.m_IsRecordTime = true
        self.m_GiveSureBox:SetActive(false)
    end)
    self.m_GiveGiftSureBtn:AddUIEvent("click", callback(self, "OnGiveGift"))
end

function CBonfireGetItemView.OnGiveGift(self)
    printc("赠送")
    local count = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
    if count < 1 then
        printc("显示赠送")
        self.m_BuyGiftHint:SetText(string.format("[896055FF]%s不足，是否购买并赠送给[-]\n[008585FF]【%s】[-]", 
        self.m_ItemInfo.name, self.m_CurInfo.fromer_name))
        self.m_BuyBox:SetActive(true)
    else
        g_BonfireCtrl:C2GSCampfireToGift(self.m_CurInfo.fromer)
        self.m_AddFriendBox:SetActive(true)
        g_BonfireCtrl:C2GSCampfireThankGift(self.m_CurInfo.fromer)
        self:OnClose()    
    end
end 

function CBonfireGetItemView.InitBuyGiftBox(self)
    self.m_BuyBox:SetActive(false)
    self.m_BuyGiftHint = self.m_BuyBox:NewUI(1, CLabel)
    self.m_BuyGiftCancelBtn = self.m_BuyBox:NewUI(2, CButton)
    self.m_BuyGiftSureBtn = self.m_BuyBox:NewUI(3, CButton)
    self.m_GiftItemIcon = self.m_BuyBox:NewUI(4, CSprite)
    self.m_BuyGiftCloseBtn = self.m_BuyBox:NewUI(5, CButton)
    self.m_BuyPriceL = self.m_BuyBox:NewUI(6, CLabel)
    self.m_BuyGiftCancelBtn:AddUIEvent("click", callback(self.m_BuyBox, "SetActive", false))
    self.m_BuyGiftCloseBtn:AddUIEvent("click", callback(self.m_BuyBox, "SetActive", false))
    self.m_BuyGiftSureBtn:AddUIEvent("click", callback(self, "OnBuyGiftSure"))
end

function CBonfireGetItemView.OnBuyGiftSure(self)
    g_BonfireCtrl:C2GSCampfireToGift(self.m_CurInfo.fromer)
    self.m_BuyBox:SetActive(false)
    self:AddFriend(self.m_CurInfo)
    if g_AttrCtrl:GetGoldCoin() >= 50 then
        self:OnClose()
    end
    g_BonfireCtrl:C2GSCampfireThankGift(self.m_CurInfo.fromer)
end

function CBonfireGetItemView.SetInfo(self, info)
    self.m_CurInfo = info
    local str = string.format("[896055FF]帮派成员[008585FF]【%s】[-]\n送给你1个%s\n(你获得了#G%d#n经验)[-]", info.fromer_name, self.m_ItemInfo.name, info.exp)
    self.m_HintLabel:SetText(str)
    self.m_GiveGiftHint:SetText(string.format("[896055FF]是否赠送一个%s送给[-]\n[008585FF]【%s】[-]", self.m_ItemInfo.name, info.fromer_name))
    self.m_BuyGiftHint:SetText(string.format("[896055FF]%s不足,是否购买并赠送给[-]\n[008585FF]【%s】[-]", self.m_ItemInfo.name, info.fromer_name))
    self.m_BuyPriceL:SetText(self.m_ItemInfo.buyPrice)
end

function CBonfireGetItemView.OnThank(self)
    if self.m_UpdateTimer then
        self.m_IsRecordTime = false
        --Utils.DelTimer(self.m_UpdateTimer)
    end
    self.m_GiveSureBox:SetActive(true)
end

function CBonfireGetItemView.OnQuickThank(self)
    if self.m_UpdateTimer then
        --Utils.DelTimer(self.m_UpdateTimer)
         self.m_IsRecordTime = false
    end
    self.m_QuickAcknowledgeBox:SetInfo(self.m_CurInfo, function ()
         self.m_AddFriendBox:SetActive(true)
    end)
    self.m_QuickAcknowledgeBox:SetActive(true)
end

function CBonfireGetItemView.OnAddFriend(self)
    if self.m_CurInfo.fromer == g_AttrCtrl.pid then
		g_NotifyCtrl:FloatMsg("不能添加自己为好友!")
		return
	end
	if g_FriendCtrl:IsMyFriend(self.m_CurInfo.fromer) then
		g_NotifyCtrl:FloatMsg("对方已经是您的好友了!")
		return
	end
	netfriend.C2GSApplyAddFriend(self.m_CurInfo.fromer)
    self:OnClose()
end

function CBonfireGetItemView.OnClose(self)
    local count = #g_BonfireCtrl.m_GetGiftList
    if count > 0 then  
        self:SetInfo(g_BonfireCtrl.m_GetGiftList[1])
        self:ShowCountDown()
        table.remove(g_BonfireCtrl.m_GetGiftList, 1)
        return
    end
    self:CloseView()
end

function CBonfireGetItemView.AddFriend(self, dInfo)
    if not g_FriendCtrl:IsMyFriend(dInfo.fromer) then
        local view = CBonfireAddFriendView:GetView()
        local info = {pid = dInfo.fromer, name = dInfo.fromer_name}
        if view then
            table.insert(g_BonfireCtrl.m_AddFriendList, info)
        else
            CBonfireAddFriendView:ShowView(function (oView)
                oView:SetInfo(info)
            end)
        end
     end
end

return CBonfireGetItemView
local CWingActiveView = class("CWingActiveView", CViewBase)

function CWingActiveView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Wing/WingActiveView.prefab", cb)
    --界面设置
    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "Black"
end

function CWingActiveView.OnCreateView(self)
    self.m_ShapeTex = self:NewUI(1, CActorTexture)
    self.m_NameL = self:NewUI(2, CLabel)
    self.m_LeftTimeL = self:NewUI(3, CLabel)
    self.m_ActiveGrid = self:NewUI(4, CGrid)
    self.m_ActiveBox = self:NewUI(5, CBox)
    self.m_CloseBtn = self:NewUI(6, CButton)

    self.m_NameL:SetText("")
    self.m_ActiveBox:SetActive(false)
    self.m_ActiveGrid:SetHideinactive(true)
    self.m_MoneyDict = {
        [1] = {icon = 10002, name = "金币", id = 1001},
        [2] = {icon = 10003, name = "银币", id = 1002},
        [3] = {icon = 10001, name = "元宝", id = 1003},
    }
    g_WingCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWingEvent"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CWingActiveView.SetWingId(self, iWing)
    self.m_WingId = iWing
    local bShow = self:RefreshLeftTime()
    if not bShow then
        return
    end
    local dModelInfo = table.copy(g_AttrCtrl.model_info)
    dModelInfo.show_wing = iWing
    dModelInfo.horse = nil
    dModelInfo.rendertexSize = 1
    dModelInfo.pos = Vector3(0, -0.75, 3)
    self.m_ShapeTex:ChangeShape(dModelInfo)
    self:RefreshActiveGrid(iWing)
end

function CWingActiveView.RefreshLeftTime(self)
    if not self.m_WingId then return end
    local iExpire = g_WingCtrl:GetTimeWingExpireTime(self.m_WingId) or 0
    if iExpire < 0 then
        self:OnClose()
        return false
    end
    local iLeftTime = iExpire - g_TimeCtrl:GetTimeS()
    if iLeftTime > 0 then
        self.m_LeftTimeL:SetText(g_TimeCtrl:GetLeftTimeDHM(iLeftTime))
    else
        self.m_LeftTimeL:SetText("已过期")
    end
    return true
end

function CWingActiveView.RefreshActiveGrid(self, iWing)
    local dConfig = g_WingCtrl:GetWingConfig(iWing)
    self.m_NameL:SetText(dConfig.name)
    self.m_ActiveGrid:HideAllChilds()
    local activeList = table.copy(dConfig.buy_times)
    table.sort(activeList, function(a, b)
        if a.days < 0 then
            return false
        elseif b.days < 0 then
            return true
        end
        return a.days < b.days
    end)
    for i, v in ipairs(activeList) do
        local oBox = self:GetActiveBox(i)
        oBox.time = v.days
        oBox.cost = v.cost
        oBox.moneyType = v.money_type
        oBox.costL:SetText(v.cost)
        oBox.moneySpr:SetSpriteName(self:GetCostIcon(v.money_type))
        if v.days > 0 then
            oBox.buyBtn:SetText(v.days.."天")
            oBox.buyBtn:SetSpriteName("h7_an_1")
        else
            oBox.buyBtn:SetText("永久")
            oBox.buyBtn:SetSpriteName("h7_an_2")
        end
    end
end

function CWingActiveView.GetCostIcon(self, iCost)
    if iCost < 50 then
        return self.m_MoneyDict[iCost].icon
    else
        local dItem = DataTools.GetItemData(iCost)
        return dItem and dItem.icon
    end
end

function CWingActiveView.GetCostName(self, iCost)
    if iCost < 50 then
        return self.m_MoneyDict[iCost].name
    else
        local dItem = DataTools.GetItemData(iCost)
        return dItem and dItem.name
    end
end

function CWingActiveView.GetActiveBox(self, idx)
    local oBox = self.m_ActiveGrid:GetChild(idx)
    if not oBox then
        oBox = self.m_ActiveBox:Clone()
        oBox.costL = oBox:NewUI(1, CLabel)
        oBox.buyBtn = oBox:NewUI(2, CButton)
        oBox.moneySpr = oBox:NewUI(3, CSprite)
        oBox.buyBtn:AddUIEvent("click", callback(self, "OnClickBuy", oBox))
        oBox.moneySpr:AddUIEvent("click", callback(self, "OnClickCostItem", oBox))
        self.m_ActiveGrid:AddChild(oBox)
    end
    oBox:SetActive(true)
    return oBox
end

function CWingActiveView.OnClickBuy(self, oBox)
    if not oBox.time then
        return
    end
    local iOwn = 0
    local iMoneyType = oBox.moneyType
    if iMoneyType < 50 then
        if iMoneyType == 1 then
            iOwn = g_AttrCtrl.gold
        elseif iMoneyType == 2 then
            iOwn = g_AttrCtrl.silver
        elseif iMoneyType == 3 then
            iOwn = g_AttrCtrl:GetGoldCoin()
        end
    else
        iOwn = g_ItemCtrl:GetBagItemAmountBySid(iMoneyType)
    end
    if iOwn < oBox.cost then
        if iMoneyType == 3 then
            -- CNpcShopMainView:ShowView(function (oView)
            --     oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
            -- end)
            if g_ShopCtrl:ShowChargeView() then
                self:OnClose()
            end
        else
            local sName = self:GetCostName(iMoneyType)
            if iMoneyType < 50 then
                g_NotifyCtrl:FloatMsg(string.format("%s不足，请先购买", sName))
            else
                g_NotifyCtrl:FloatMsg("永久激活道具不足，请先集齐道具")
            end
        end
        return
    end
    netwing.C2GSAddWingTime(self.m_WingId, oBox.time)
end

function CWingActiveView.OnClickCostItem(self, oBox)
    if oBox then
        local iMoneyType = oBox.moneyType
        local iItemId
        if self.m_MoneyDict[iMoneyType] then
            iItemId = self.m_MoneyDict[iMoneyType].id
        else
            iItemId = iMoneyType
        end
        g_WindowTipCtrl:SetWindowGainItemTip(iItemId)
    end
end

function CWingActiveView.OnWingEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Wing.Event.RefreshWing then
        self:RefreshLeftTime()
    elseif oCtrl.m_EventID == define.Wing.Event.RefreshTimeWing then
        if oCtrl.m_EventData == self.m_WingId then
            self:RefreshLeftTime()
        end
    end
end

return CWingActiveView
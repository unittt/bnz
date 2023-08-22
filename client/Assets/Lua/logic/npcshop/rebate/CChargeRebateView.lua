local CChargeRebateView = class("CChargeRebateView", CViewBase)

function CChargeRebateView.ctor(self, cb)
    CViewBase.ctor(self, "UI/NpcShop/ChargeRebateView.prefab", cb)
    --界面设置
    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "ClickOut"
end

function CChargeRebateView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_RebateBox = self:NewUI(2, CChargeRebateBox)
    self.m_RebateGrid = self:NewUI(3, CGrid)
    self.m_ScrollView = self:NewUI(4, CScrollView)

    self.m_RebateBox:SetActive(false)
    self.m_CurIdx = 0

    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareCtrlEvent"))

    self:RefreshAll()
end

function CChargeRebateView.RefreshAll(self)
    self.m_RebateInfo = {}
    local dRebateInfo = DataTools.GetWelfareData("REBATE")
    if not dRebateInfo then return end
    for _, v in pairs(dRebateInfo) do
        table.insert(self.m_RebateInfo, v)
    end
    table.sort(self.m_RebateInfo, function(a, b)
        return a.goldcoin < b.goldcoin
    end)
    local iPayCnt = g_WelfareCtrl:GetChargeItemInfo("rebate_gold_coin")
    for i, dRebate in ipairs(self.m_RebateInfo) do
        if dRebate.show_num > iPayCnt then
            break
        end
        self:CreateRebateItem(dRebate)
    end
end

function CChargeRebateView.CreateRebateItem(self, dRebate)
    if not dRebate then return end
    self.m_CurIdx = self.m_CurIdx + 1
    local oRebate = self.m_RebateGrid:GetChild(self.m_CurIdx)
    if not oRebate then
        oRebate = self.m_RebateBox:Clone()
        oRebate.pageScrollView = self.m_ScrollView
        oRebate.idx = self.m_CurIdx
        self.m_RebateGrid:AddChild(oRebate)
    end
    oRebate:SetActive(true)
    oRebate:RefreshAll(dRebate)
    return oRebate
end

function CChargeRebateView.UpdateAllItemsCnt(self)
    for i, oItem in ipairs(self.m_RebateGrid:GetChildList()) do
        local dInfo = self.m_RebateInfo[oItem.idx]
        if dInfo then
            oItem:RefreshChargeCnt()
        end
    end
end

function CChargeRebateView.GetRebateItemByKey(self, sKey)
    for k, v in ipairs(self.m_RebateInfo) do
        if v.key == sKey then
            local oItem = self.m_RebateGrid:GetChild(k)
            return oItem, k
        end
    end
end

function CChargeRebateView.CheckRebateItems(self, iPayCnt)
    if not iPayCnt then
        iPayCnt = g_WelfareCtrl:GetChargeItemInfo("rebate_gold_coin")
    end
    for i = self.m_CurIdx+1, #self.m_RebateInfo do
        local info = self.m_RebateInfo[i]
        if info and info.show_num <= iPayCnt then
            self:CreateRebateItem(info)
        else
            break
        end
    end
end

function CChargeRebateView.OnWelfareCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateRebatePnl then
        local iCurVal, sLastKey
        if self.m_RebateInfo[self.m_CurIdx] then
            sLastKey = self.m_RebateInfo[self.m_CurIdx].key
        end
        for _, dInfo in ipairs(oCtrl.m_EventData) do
            if dInfo.key == "rebate_gold_coin" then
                self:CheckRebateItems(dInfo.val)
            else
                local oItem, iCurIdx = self:GetRebateItemByKey(dInfo.key)
                if oItem then
                    oItem:RefreshBtnState(dInfo.val)
                end
                if dInfo.key == sLastKey then
                    iCurVal = dInfo.val
                end
            end
        end
        self:UpdateAllItemsCnt()
    end
end

return CChargeRebateView
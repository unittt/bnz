local CSummonAdvanceView = class("CSummonAdvanceView", CViewBase)

function CSummonAdvanceView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Summon/SummonAdvanceView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"

    self.m_CostItemId = nil
    self.m_CurSummonId = nil
    self.m_CurItemCnt = 0
    self.m_NeedItemCnt = 0
    self.m_ItemQuality = 0
    self.m_ItemName = ""
    self.m_IsZhenshou = false
end

function CSummonAdvanceView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_CostItemBox = self:NewUI(2, CBox)
    self.m_TipBtn = self:NewUI(3, CButton)
    self.m_ComfirmBtn = self:NewUI(4, CButton)
    self.m_AptiBox = self:NewUI(5, CSummonAdvAptiBox)
    self.m_SkillBox = self:NewUI(6, CSummonSkillBox)
    self.m_SummListBox = self:NewUI(7, CSummonListBox)
    self.m_EquipBox = self:NewUI(8, CSummonViewEquipBox)
    self.m_ViewBox = self:NewUI(9, CSummonViewBox)
    self.m_RequireLvL = self:NewUI(10, CLabel)
    self.m_ArriveTopL = self:NewUI(11, CLabel)
    self.m_TitleSpr = self:NewUI(12, CSprite)
    self.m_TitleL = self:NewUI(13, CLabel)
    self.m_TipBtn:SetActive(false)
end

function CSummonAdvanceView.ShowZhenshouView(self)
    self.m_CostItemId = 10181
    self.m_IsZhenshou = true
    self.m_TitleSpr:SetSpriteName("h7_zhenshoujinjie")
    self:InitCostItemBox()
    self:RefreshSummonList()
    self:InitOther()
end

function CSummonAdvanceView.ShowGodSummView(self)
    self.m_CostItemId = 11176
    self.m_IsZhenshou = false
    self:InitCostItemBox()
    self:RefreshSummonList()
    self:InitOther()
end

function CSummonAdvanceView.InitOther(self)
    self.m_CostItemBox:AddUIEvent("click", callback(self, "OnClickCostItem"))
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSummonCtrl"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTip"))
    self.m_ComfirmBtn:AddUIEvent("click", callback(self, "OnClickComfirm"))
end

function CSummonAdvanceView.InitCostItemBox(self)
    local oBox = self.m_CostItemBox
    oBox.iconSpr = oBox:NewUI(1, CSprite)
    oBox.qualitySpr = oBox:NewUI(2, CSprite)
    oBox.cntL = oBox:NewUI(3, CLabel)
    oBox.nameL = oBox:NewUI(4, CLabel)
    local dItem = DataTools.GetItemData(self.m_CostItemId)
    oBox.iconSpr:SpriteItemShape(dItem.icon)
    oBox.nameL:SetText(dItem.name)
    self.m_ItemName = dItem.name
    oBox.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal(dItem.id, dItem.quality or 0))
    self.m_ItemQuality = dItem.quality or 0
    self:RefreshCostItemCnt()
end

-- function CSummonAdvanceView.InitSummons(self, summonList)
--     self.m_SummListBox.m_ShowRedPt = false
--     self.m_SummListBox:RefreshSummonInfos(summonList)
--     -- local bHasSumm = false
--     -- self.m_ViewBox:SetActive(bHasSumm)
--     -- self.m_AptiBox:SetActive(bHasSumm)
--     -- self.m_SkillBox:SetActive(bHasSumm)
--     -- self.m_CostItemBox:SetActive(bHasSumm)
-- end

function CSummonAdvanceView.RefreshSummonList(self)
    local summonList
    if self.m_IsZhenshou then
        summonList = g_SummonCtrl:GetSummonZhenshouAdvList()
    else
        summonList = g_SummonCtrl:GetSummonAdvList()
    end
    self.m_SummListBox.m_ShowRedPt = false
    self.m_SummListBox:RefreshSummonInfos(summonList)
end

function CSummonAdvanceView.SelectSummon(self, dSummon)
    local iSummon = dSummon.id
    if SummonDataTool.IsGodSummon(dSummon.type) then
        self:ShowGodSummView()
    else
        self:ShowZhenshouView()
    end
    local dSelSumm
    for i, v in ipairs(g_SummonCtrl.m_SummonsSort) do
        if v.typeid == iSummon then
            dSelSumm = v
            break
        end
    end
    if dSelSumm then
        self.m_ViewBox:SetActive(true)
        self.m_AptiBox:SetActive(true)
        self.m_SkillBox:SetActive(true)
        self:RefreshSelSummon(dSelSumm)
        self.m_SummListBox:SetSelSummonId(dSelSumm.id)
    end
end

function CSummonAdvanceView.RefreshSelSummon(self, dSummon)
    self.m_CurSummonId = dSummon.id
    self.m_SummonInfo = dSummon
    self.m_ViewBox:SetInfo(dSummon)
    self.m_AptiBox:SetInfo(dSummon)
    self.m_EquipBox:SetInfo(dSummon)

    local skills = SummonDataTool.GetSkillInfo(dSummon)
    self.m_SkillBox:SetInfo(skills)
    self:RefreshCostItemCnt()
end

function CSummonAdvanceView.RefreshCostItemCnt(self)
    local oLabel = self.m_CostItemBox.cntL
    self.m_NeedItemCnt = 0
    if self.m_SummonInfo then
        local iLv = (self.m_SummonInfo.advance_level or 0) + 1
        local dLevel = SummonDataTool.GetAdvanceLvData(iLv, self.m_SummonInfo.type)
        local bTop = not dLevel
        self.m_CostItemBox:SetActive(not bTop)
        self.m_ComfirmBtn:SetActive(not bTop)
        self.m_ArriveTopL:SetActive(bTop)
        if dLevel then
            local iNeed = dLevel.cost_amount
            local iCur = g_ItemCtrl:GetBagItemAmountBySid(self.m_CostItemId)
            if iCur >= iNeed then
                oLabel:SetText(string.format("[1D8E00]%d/%d", iCur, iNeed))
            else
                oLabel:SetText(string.format("[af302a]%d[-][63432c]/%d", iCur, iNeed))
            end
            local iMixLv = dLevel.mix_lv
            if iMixLv > self.m_SummonInfo.grade then
                self.m_RequireLvL:SetText(string.format("[FB3636]%s级可进阶", iMixLv))
            else
                self.m_RequireLvL:SetText(string.format("[244B4E]%s级可进阶", iMixLv))
            end
            self.m_CurItemCnt = iCur
            self.m_NeedItemCnt = iNeed
        else
            self.m_RequireLvL:SetText("")
            oLabel:SetText("")
        end
    else
        oLabel:SetText("")
    end
end

function CSummonAdvanceView.CheckCostItemCnt(self)
    if self.m_NeedItemCnt > 0 then
        local bEnough = self.m_NeedItemCnt <= self.m_CurItemCnt
        if not bEnough then
            local sName = string.format(data.colorinfodata.ITEM[self.m_ItemQuality].color, self.m_ItemName)
            -- g_NotifyCtrl:FloatMsg(string.format("%s数量不足#R%d#n个，无法进阶%s", sName, self.m_NeedItemCnt, self.m_SummonInfo.name))
            g_QuickGetCtrl:CheckLackItemInfo({
                itemlist = {{sid = self.m_CostItemId, count = self.m_CurItemCnt, amount = self.m_NeedItemCnt or 1}},
                exchangeCb = function()
                    if Utils.IsNil(self) then return end
                    netsummon.C2GSSummonAdvance(self.m_CurSummonId, 1)
                end
            })
        end
        return bEnough
    else
        return false
    end
end

function CSummonAdvanceView.CheckSummonCondition(self)
    if not self.m_SummonInfo then
        return false
    end
    local bEnable = true
    local iLv = (self.m_SummonInfo.advance_level or 0) + 1
    local dLevel = SummonDataTool.GetAdvanceLvData(iLv, self.m_SummonInfo.type)
    if not dLevel then
        if iLv > 0 then
            g_NotifyCtrl:FloatMsg(string.format("%s已达到最高%d阶", self.m_SummonInfo.name, self.m_SummonInfo.advance_level))
        end
        bEnable = false
    elseif self.m_SummonInfo.grade < dLevel.mix_lv then
        g_NotifyCtrl:FloatMsg(string.format("%s需要达到#R%d#n级才能进阶", self.m_SummonInfo.name, dLevel.mix_lv))
        bEnable = false
    end
    return bEnable
end

function CSummonAdvanceView.OnClickTip(self)
    printc("on click tip ------------ ")
end

function CSummonAdvanceView.OnClickComfirm(self)
    if self:CheckSummonCondition() and self:CheckCostItemCnt() then
        netsummon.C2GSSummonAdvance(self.m_CurSummonId)
    end
end

function CSummonAdvanceView.OnClickCostItem(self)
    g_WindowTipCtrl:SetWindowGainItemTip(self.m_CostItemId)
end

function CSummonAdvanceView.OnSummonCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo then
        local dSummon = oCtrl.m_EventData
        if dSummon.id == self.m_CurSummonId then
            self:RefreshSelSummon(dSummon)
        end
        self:RefreshSummonList()
    elseif oCtrl.m_EventID == define.Summon.Event.ChangeSummonShow then
        if oCtrl.m_EventData then
            local dSummon = g_SummonCtrl:GetSummon(oCtrl.m_EventData)
            self:RefreshSelSummon(dSummon)
        end
    elseif oCtrl.m_EventID == define.Summon.Event.BagItemUpdate then
        self:RefreshCostItemCnt()
    end
end

return CSummonAdvanceView
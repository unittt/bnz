local CSummonStudyItemView = class("CSummonStudyItemView", CViewBase)

local Tab = {
    Bag = 1,
    Adv = 3,
    Low = 2,
}

local Guild = {
    Id = 2,
    AdvSub = 2,
    LowSub = 1,
}

function CSummonStudyItemView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Summon/SummonStudyItemView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "ClickOut"
end

function CSummonStudyItemView.OnCreateView(self)
    self:InitContent()

    self.m_OwnSkills = {}
    local dSummon = g_SummonCtrl:GetCurSummonInfo()
    if dSummon then
        for i, v in ipairs(dSummon.skill) do
            self.m_OwnSkills[v.sk] = true
        end
    end

    local iTab = g_SummonCtrl.m_StudyTab or Tab.Bag
    self:OnClickTab(iTab)
    local oBtn = self.m_TabDict[iTab]
    if oBtn then
        oBtn:SetSelected(true)
    end
end

function CSummonStudyItemView.InitContent(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_TabBtn1 = self:NewUI(2, CButton)
    self.m_TabBtn2 = self:NewUI(3, CButton)
    self.m_TabBtn3 = self:NewUI(4, CButton)
    self.m_ScrollView = self:NewUI(5, CScrollView)
    self.m_ItemGrid = self:NewUI(6, CGrid)
    self.m_StudyItem = self:NewUI(7, CSummonStudyItemBox)
    self.m_StudyItem:SetActive(false)
    self.m_TabDict = {
        [Tab.Bag] = self.m_TabBtn1,
        [Tab.Low] = self.m_TabBtn2,
        [Tab.Adv] = self.m_TabBtn3,
    }
    self:RegisterEvents()
end

function CSummonStudyItemView.RegisterEvents(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
    for i, v in pairs(self.m_TabDict) do
        v:AddUIEvent("click", callback(self, "OnClickTab", i))
    end
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSummonCtrlEvent"))
    -- g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CSummonStudyItemView.RefreshBagStudyItems(self)
    self.m_ItemGrid:HideAllChilds()
    local itemDatas = SummonDataTool.GetBagStudyItems()
    for i, dItem in ipairs(itemDatas) do
        local oBox = self:GetItemBox(i)
        oBox:SetActive(true)
        oBox.isBag = true
        dItem.isExist = self:IsHasSkill(dItem)
        oBox:SetInfo(dItem)
    end
    self.m_ScrollView:ResetPosition()
end

function CSummonStudyItemView.RefreshStoreInfo(self, dGuild)
    local iSubId = dGuild.subId
    if iSubId == self.m_SubGuildId then
        self.m_ItemGrid:HideAllChilds()
        for i, v in ipairs(dGuild.info) do
            local oBox = self:GetItemBox(i)
            oBox:SetActive(true)
            oBox.isBag = false
            v.isExist = self:IsHasSkill(v)
            oBox:SetInfo(v)
        end
        self.m_ScrollView:ResetPosition()
    end
end

function CSummonStudyItemView.GetItemBox(self, idx)
    local oBox = self.m_ItemGrid:GetChild(idx)
    if not oBox then
        oBox = self.m_StudyItem:Clone()
        oBox:AddUIEvent("click", callback(self, "OnClickItem", oBox))
        oBox.m_ItemSpr:AddUIEvent("click", callback(self, "OnClickIcon", oBox))
        self.m_ItemGrid:AddChild(oBox)
    end
    return oBox
end

function CSummonStudyItemView.AskForGuildInfo(self)
    if not self.m_SubGuildId then
        printc("not sub guild id")
        return
    end
    netguild.C2GSOpenGuild(Guild.Id, self.m_SubGuildId)
end

function CSummonStudyItemView.IsHasSkill(self, dInfo)
    -- 检测是否已学习
    local iSk = dInfo.skid
    return self.m_OwnSkills[iSk] or false
    -- local dSummon = g_SummonCtrl:GetCurSummonInfo()
    -- if dSummon then
    --     for i, dSk in ipairs(dSummon.skill) do
    --         if dSk.sk == iSk then
    --             return true
    --         end
    --     end
    -- end
    -- return false
end

function CSummonStudyItemView.OnBuyItem(self, dBuyInfo)
    -- local iGold = g_AttrCtrl.gold
    -- if iGold > dBuyInfo.price then
    dBuyInfo.isAdv = Tab.Adv == self.m_TabIdx
    g_SummonCtrl:SelSummonStudyItem(dBuyInfo)
    self:OnClose()
    -- else
    --     g_NotifyCtrl:FloatMsg("金币不足")
    -- end
end

function CSummonStudyItemView.OnClickTab(self, idx)
    if idx == self.m_TabIdx then
        return
    end
    self.m_TabIdx = idx
    if Tab.Bag == idx then
        self:RefreshBagStudyItems()
        self.m_SubGuildId = nil
    else
        if Tab.Adv == idx then
            self.m_SubGuildId = Guild.AdvSub
        elseif Tab.Low == idx then
            self.m_SubGuildId = Guild.LowSub
        end
        self:AskForGuildInfo()
    end
end

function CSummonStudyItemView.OnClickItem(self, oBox)
    local dInfo = oBox.m_Info
    if not dInfo then
        return
    end
    local dSummon = g_SummonCtrl:GetCurSummonInfo()
    local dItem = DataTools.GetItemData(dInfo.id)
    if dInfo.id == 30000 then
        if SummonDataTool.IsSummStudyAllInnateSk(dSummon) then
            local sMsg = SummonDataTool.GetText(1004)
            sMsg = string.gsub(sMsg, "#summon", dSummon.name)
            sMsg = string.gsub(sMsg, "#item", dItem.name)
            g_NotifyCtrl:FloatMsg(sMsg)
            return
        end
    elseif self:IsHasSkill(dInfo) then
        local dSkill = SummonDataTool.GetSummonSkillInfo(dInfo.skid)
        local sMsg = SummonDataTool.GetText(1005)
        sMsg = string.gsub(sMsg, "#summon", dSummon.name)
        sMsg = string.gsub(sMsg, "#skname", dSkill.name)
        sMsg = string.gsub(sMsg, "#item", dItem.name)
        g_NotifyCtrl:FloatMsg(sMsg)
        return
    end
    if oBox.isBag then
        g_SummonCtrl:SelSummonStudyItem(dInfo)
        self:CloseView()
    else
        self:OnBuyItem(dInfo)
    end
end

function CSummonStudyItemView.OnClickIcon(self, oBox)
    local dInfo = oBox.m_Info
    if not dInfo or dInfo.id == 30000 then return end
    dInfo.sk = dInfo.skid
    CSummonSkillItemTipsView:ShowView(function (oView)
        oView:SetData(dInfo, oBox:GetPos(), nil, nil)  
    end)
end

function CSummonStudyItemView.OnClickClose(self)
    self:OnClose()
end

function CSummonStudyItemView.OnSummonCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Summon.Event.ReceiveGuildInfo then
        local dGuild = oCtrl.m_EventData
        self:RefreshStoreInfo(dGuild)
    end
end

function CSummonStudyItemView.CloseView(self)
    self.m_TabDict = nil
    g_SummonCtrl.m_StudyTab = self.m_TabIdx
    CViewBase.CloseView(self)
end

return CSummonStudyItemView
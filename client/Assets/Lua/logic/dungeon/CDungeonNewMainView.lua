local CDungeonNewMainView = class("CDungeonNewMainView", CViewBase)

function CDungeonNewMainView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Dungeon/DungeonNewMainView.prefab", cb)
    --界面设置
    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "Black"

    self.m_CurTab = 0
    self.m_CurPassId = 0
    self.m_PassDict = {}
end

function CDungeonNewMainView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_TabGrid = self:NewUI(2, CGrid)
    self.m_NormalTab = self:NewUI(3, CButton)
    self.m_AdvTab = self:NewUI(4, CButton)
    self.m_ScrollView = self:NewUI(5, CScrollView)
    self.m_PassGrid = self:NewUI(6, CGrid)
    self.m_PassBox = self:NewUI(7, CDungeonPassBox)
    self.m_RewardBox = self:NewUI(8, CBox)
    self.m_TeamBtn = self:NewUI(9, CButton)
    self.m_EnterBtn = self:NewUI(10, CButton)
    self:InitContent()
end

function CDungeonNewMainView.InitContent(self)
    self.m_PassBox:SetActive(false)
    self:InitRewardBox()
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_NormalTab:AddUIEvent("click", callback(self, "OnClickTab", 1))
    self.m_AdvTab:AddUIEvent("click", callback(self, "OnClickTab", 2))
    self.m_TeamBtn:AddUIEvent("click", callback(self, "OnClickTeam"))
    self.m_EnterBtn:AddUIEvent("click", callback(self, "OnClickEnter"))
    self:OnClickTab(1)
    self.m_NormalTab:SetSelected(true)
end

function CDungeonNewMainView.InitRewardBox(self)
    local oRewardBox = self.m_RewardBox
    oRewardBox.grid = oRewardBox:NewUI(1, CGrid)
    oRewardBox.itemBox = oRewardBox:NewUI(2, CItemBaseBox)
    oRewardBox.scrollView = oRewardBox:NewUI(3, CScrollView)
    oRewardBox.itemBox:SetActive(false)
end

function CDungeonNewMainView.RefreshAll(self)
    self:RefreshPasses()
    self:RefreshReward()
end

function CDungeonNewMainView.RefreshPasses(self)
    local configList = self:GetConfigByRefreshType(self.m_CurTab)
    if not configList then return end
    self.m_PassGrid:HideAllChilds()
    self.m_PassDict = {}
    for i = 1, #configList + 1 do
        local dInfo = configList[i]
        local oBox = self.m_PassGrid:GetChild(i)
        if not oBox then
            oBox = self.m_PassBox:Clone()
            oBox:AddUIEvent("click", callback(self, "OnClickPass", oBox))
            self.m_PassGrid:AddChild(oBox)
        end
        oBox:SetActive(true)
        oBox:SetInfo(dInfo)
        if oBox.id then
            self.m_PassDict[oBox.id] = oBox
        end
        if i == 1 then
            self:OnClickPass(oBox)
        end
    end
    self.m_PassGrid:Reposition()
    self.m_ScrollView:ResetPosition()
end

function CDungeonNewMainView.RefreshReward(self)
    local oRewardBox = self.m_RewardBox
    oRewardBox.grid:HideAllChilds()
    local rewardList = self:GetRewardConfig()
    if not rewardList then return end
    for i, dItem in ipairs(rewardList) do
        local oBox = oRewardBox.grid:GetChild(i)
        if not oBox then
            oBox = oRewardBox.itemBox:Clone()
            oRewardBox.grid:AddChild(oBox)
        end
        oBox:SetBagItem(CItem.CreateDefault(dItem.sid))
        if type(dItem.amount) == "string" then
            dItem.amount = string.eval(dItem.amount, {math = math, lv = g_AttrCtrl.grade})
        end
        oBox:SetAmountText(dItem.amount)
        oBox:SetActive(true)
        oBox:AddUIEvent("click", callback(self, "OnClickRewardItem", oBox))
    end
    oRewardBox.grid:Reposition()
    oRewardBox.scrollView:ResetPosition()
end

function CDungeonNewMainView.GetRewardConfig(self)
    local oBox = self.m_PassDict[self.m_CurPassId or 0]
    if oBox then
        local dDungeon = oBox.m_Config
        if dDungeon then
            -- local dReward = DataTools.GetRewardItems(dDungeon.open_name, dDungeon.rewardId)
            local sReward = string.upper(dDungeon.fuben_name)
            local rewardList = DataTools.GetRewardItems(sReward, dDungeon.pre_reward)
            return rewardList
        end
    end
end

function CDungeonNewMainView.GetConfigByRefreshType(self, iType)
    local configList = {}
    for i, v in pairs(data.fubendata.DATA) do
        if v.refresh_type == iType then
            local dOpen = DataTools.GetViewOpenData(v.open_name)
            if dOpen then
                table.insert(configList, {config = v, open = dOpen})
            end
        end
    end
    table.sort(configList, function(a, b)
        return a.open.p_level <= b.open.p_level
    end)
    return configList
end

function CDungeonNewMainView.OnClickTab(self, iTab)
    if iTab == self.m_CurTab then
        return
    end
    self.m_CurTab = iTab
    self.m_CurPassId = 0
    self:RefreshAll()
end

function CDungeonNewMainView.OnClickTeam(self)
    CTeamHandyBuildView:ShowView()
    g_TeamCtrl:TeamAutoMatch(1200)
end

function CDungeonNewMainView.OnClickEnter(self)
    if not self.m_CurPassId or self.m_CurPassId == 0 then
        return
    end
    netopenui.C2GSOpenFBComfirm(self.m_CurPassId)
    self:CloseView()
end

function CDungeonNewMainView.OnClickPass(self, oBox)
    if not oBox.id or oBox.id == self.m_CurPassId then
        return
    end
    if self.m_CurPassId then
        local oBox = self.m_PassDict[self.m_CurPassId]
        if oBox then
            oBox:SetSelected(false)
        end
    end
    oBox:SetSelected(true)
    self.m_CurPassId = oBox.id
    self:RefreshReward()
end

function CDungeonNewMainView.OnClickRewardItem(self, oItem)
    local itemId = oItem.m_Item:GetSValueByKey("sid")
    if not itemId then return end
    local config = {widget = oItem}
    g_WindowTipCtrl:SetWindowItemTip(itemId, config)
end

return CDungeonNewMainView
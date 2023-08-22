local CWingTimeWingPage = class("CWingTimeWingPage", CPageBase)

function CWingTimeWingPage.ctor(self, obj)
    CPageBase.ctor(self, obj)
end

function CWingTimeWingPage.OnInitPage(self)
    self.m_LvBtn = self:NewUI(1, CButton)
    self.m_TimeWingBtn = self:NewUI(2, CButton)
    self.m_TimeWingPageBox = self:NewUI(3, CWingAspectPageBox)
    self.m_LvPageBox = self:NewUI(4, CWingAspectPageBox)
    self.m_TimeWingBox = self:NewUI(5, CTimeWingAspectBox)
    self.m_LvWingBox = self:NewUI(6, CLevelWingAspectBox)
    self.m_TipBtn = self:NewUI(7, CButton)
    self.m_BtnGrid = self:NewUI(8, CGrid)
    self:InitContent()
end

function CWingTimeWingPage.InitContent(self)
    self.m_Tabs = {
        [1] = self.m_LvBtn,
        [2] = self.m_TimeWingBtn,
    }
    self.m_InitTab = {}
    self.m_CurTabIdx = 0
    self.m_TimeWingPageBox:InitPageBox(self.m_TimeWingBox)
    self.m_LvPageBox:InitPageBox(self.m_LvWingBox)
    local bShowLv = g_WingCtrl:IsUnlockWingSys()
    self.m_LvBtn:SetActive(bShowLv)
    self.m_TimeWingBtn:SetActive(g_WingCtrl:HasActiveWing())
    self.m_BtnGrid:Reposition()

    self.m_TimeWingBtn:AddUIEvent("click", callback(self, "OnClickPageBtn", 2))
    self.m_LvBtn:AddUIEvent("click", callback(self, "OnClickPageBtn", 1))
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTipBtn"))
    g_WingCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWingEvent"))
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))
    self:OnClickPageBtn(bShowLv and 1 or 2)
end

function CWingTimeWingPage.ShowTimeWingByItemSid(self, iSid)
    local wingInfos = g_WingCtrl:GetTimeWingConfigs()
    local idx
    for i, v in ipairs(wingInfos) do
        for _, dCost in ipairs(v.active_cost) do
            if dCost.sid == iSid then
                idx = i
                break
            end
        end
        if idx then
            break
        end
    end
    if idx then
        self.m_TimeWingPageBox.m_CurPage = math.ceil(idx/3)
    end
    self:OnClickPageBtn(2)
end

function CWingTimeWingPage.RefreshTabPart(self, idx)
    if idx == 2 then
        self:RefreshTimeWingPart()
    elseif idx == 1 then
        self:RefreshLvWingPart()
    end
end

function CWingTimeWingPage.RefreshTimeWingPart(self)
    local wingInfos = g_WingCtrl:GetTimeWingConfigs()
    self.m_TimeWingPageBox:RefreshAll(wingInfos)
end

function CWingTimeWingPage.RefreshLvWingPart(self)
    local lvInfos = g_WingCtrl:GetLevelWingConfig()
    self.m_LvPageBox:RefreshAll(lvInfos)
end

function CWingTimeWingPage.OnClickPageBtn(self, idx)
    if idx == self.m_CurTabIdx then
        return
    end
    self.m_CurTabIdx = idx
    self.m_Tabs[idx]:SetSelected(true)
    self.m_LvPageBox:SetActive(idx == 1)
    self.m_TimeWingPageBox:SetActive(idx == 2)
    if not self.m_InitTab[idx] then
        self.m_InitTab[idx] = true
        self:RefreshTabPart(idx)
    end
end

function CWingTimeWingPage.OnClickTipBtn(self)
    local instructionConfig = data.instructiondata.DESC[10059]
    if instructionConfig then
        local zContent = {
            title = instructionConfig.title,
            desc = instructionConfig.desc,
        }
        g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
    end    
end

function CWingTimeWingPage.OnWingEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Wing.Event.RefreshWing then
        if self.m_InitTab[2] then
            self.m_TimeWingPageBox:RefreshAll()
        end
        if self.m_InitTab[1] then
            self.m_LvPageBox:RefreshAll()
        end
        if not self.m_TimeWingBtn:GetActive() and g_WingCtrl:HasActiveWing() then
            self.m_TimeWingBtn:SetActive(true)
        end
    elseif oCtrl.m_EventID == define.Wing.Event.RefreshTimeWing then
        if self.m_InitTab[2] then
            self.m_TimeWingPageBox:RefreshAll()
        end
    end
end

function CWingTimeWingPage.OnItemEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
        self:RefreshTimeWingPart()
    end
end

return CWingTimeWingPage
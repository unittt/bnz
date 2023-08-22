local CSummonAdjustPage = class("CSummonAdjustPage", CPageBase)

local Page = {
    Wash = 1,
    Compound = 2,
    Study = 3,
    Culture = 4,
}

function CSummonAdjustPage.ctor(self, obj)
    CPageBase.ctor(self, obj)

    self.m_LockGrade = SummonDataTool.GetUnlockCompoundGrade()
    self.m_SelPageIdx = nil
end

function CSummonAdjustPage.OnInitPage(self)
    self.m_WashBtn = self:NewUI(1, CButton)
    self.m_CompoundBtn = self:NewUI(2, CButton)
    self.m_SkillBtn = self:NewUI(3, CButton)
    self.m_CultureBtn = self:NewUI(4, CButton)

    self.m_ListBox = self:NewUI(5, CSummonListBox)
    self.m_WashPart = self:NewUI(6, CSummonWashPart)
    self.m_ViewPart = self:NewUI(7, CSummonAdjustViewPart)
    self.m_StudyPart = self:NewUI(8, CSummonStudyPart)
    self.m_CompoundPart = self:NewUI(9, CSummonCompoundPart)
    self.m_CulturePart = self:NewUI(10, CSummonCulturePart)

    self:InitContent()
end

function CSummonAdjustPage.InitContent(self)
    self.m_WashBtn:SetGroup(self:GetInstanceID())
    self.m_CompoundBtn:SetGroup(self:GetInstanceID())   
    self.m_SkillBtn:SetGroup(self:GetInstanceID())
    self.m_CultureBtn:SetGroup(self:GetInstanceID())
    self.m_TabDict = {
        [Page.Wash] = self.m_WashBtn,
        [Page.Compound] = self.m_CompoundBtn,
        [Page.Study] = self.m_SkillBtn,
        [Page.Culture] = self.m_CultureBtn,
    }

    self:RegisterEvents()
end

function CSummonAdjustPage.RegisterEvents(self)
    g_GuideCtrl:AddGuideUI("petview_compound_btn", self.m_CompoundBtn)
    g_GuideCtrl:AddGuideUI("petview_skill_btn", self.m_SkillBtn)

    self.m_WashBtn:AddUIEvent("click", callback(self, "OnClickPageBtn", Page.Wash))
    self.m_CompoundBtn:AddUIEvent("click", callback(self, "OnClickPageBtn", Page.Compound))
    self.m_SkillBtn:AddUIEvent("click", callback(self, "OnClickPageBtn", Page.Study))
    self.m_CultureBtn:AddUIEvent("click", callback(self, "OnClickPageBtn", Page.Culture))

    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSummonCtrlEvent"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))
end

function CSummonAdjustPage.OnShowPage(self)
    local iCurSummon = g_SummonCtrl:GetCurSelSummon()
    local dInfo = g_SummonCtrl:GetSummon(iCurSummon)
    self.m_WashBtn:SetSelected(true)
    self.m_ListBox:RefreshSummons()
    self.m_CurSummon = iCurSummon
    self.m_SelPageIdx = 0
    self:OnClickPageBtn(Page.Wash)
    self.m_ViewPart:SetInfo(dInfo)
end

function CSummonAdjustPage.OnHidePage(self)
    g_SummonCtrl:SetStudyGuildItem(nil)
end

function CSummonAdjustPage.RefreshSummon(self, iSummon)
    self.m_CurSummon = iSummon or 0
    local dInfo = g_SummonCtrl:GetSummon(iSummon)
    if not dInfo then
        printc("has not summon ------- ", iSummon)
    end
    self.m_ViewPart:SetInfo(dInfo)
    self:RefreshPage()
end

function CSummonAdjustPage.RefreshPage(self)
    local dInfo = g_SummonCtrl:GetSummon(self.m_CurSummon)
    if Page.Wash == self.m_SelPageIdx then
        self.m_WashPart:SetInfo(dInfo)
    elseif Page.Study == self.m_SelPageIdx then
        self.m_StudyPart:SetInfo(dInfo)
    elseif Page.Culture == self.m_SelPageIdx then
        self.m_CulturePart:SetInfo(dInfo)
    elseif Page.Compound == self.m_SelPageIdx then
        self.m_CompoundPart:CompoundHide()
    end
end

function CSummonAdjustPage.CompoundLockMsg(self)
    local msg = SummonDataTool.GetText(2009)
    msg = string.gsub(msg, "#grade", self.m_LockGrade)
    g_NotifyCtrl:FloatMsg(msg)
end

function CSummonAdjustPage.OnClickPageBtn(self, idx)
    if idx == self.m_SelPageIdx then return end
    -- 合成检测
    if idx == Page.Compound then
        local bOpen = self.m_LockGrade <= g_AttrCtrl.grade
        if not bOpen then
            self:CompoundLockMsg()
            local idx = self.m_SelPageIdx or 1
            self.m_TabDict[idx]:SetSelected(true)
            return
        end
    end
    self.m_SelPageIdx = idx
    self.m_ListBox:SetActive(idx~=Page.Compound)
    self.m_WashPart:SetActive(idx==Page.Wash)
    self.m_ViewPart:SetActive(idx~=Page.Compound)
    self.m_CulturePart:SetActive(idx==Page.Culture)
    self.m_CompoundPart:SetActive(idx==Page.Compound)
    self.m_StudyPart:SetActive(idx==Page.Study)
    self:RefreshPage()
end

function CSummonAdjustPage.OnSummonCtrlEvent(self, oCtrl)
    if self:GetActive() == false then
        return
    end
    if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo then
        local iUpdate = oCtrl.m_EventData.id
        if self.m_CurSummon == iUpdate then  
            self:RefreshSummon(iUpdate)
        end
        self.m_ListBox:SetSummonBoxInfo(oCtrl.m_EventData)
    elseif oCtrl.m_EventID == define.Summon.Event.WashSummonAdd then
        local dSummonInfo = oCtrl.m_EventData
        self:OnWashSummon(dSummonInfo)
    elseif oCtrl.m_EventID == define.Summon.Event.AddSummon then
        local iSummon = oCtrl.m_EventData.id
        self:RefreshSummon(iSummon)
        self.m_ListBox:RefreshSummons()
    elseif oCtrl.m_EventID == define.Summon.Event.DelSummon then  
        self:OnDelSummon()
    elseif oCtrl.m_EventID == define.Summon.Event.BagItemUpdate then
        local dSummon = g_SummonCtrl:GetSummon(self.m_CurSummon)
        if dSummon then
            self.m_WashPart:UpdateItemInfo()
            self.m_CulturePart:RefreshItemCnt()
            self.m_CompoundPart:RefreshCostItemCnt()
        end
    elseif oCtrl.m_EventID == define.Summon.Event.ChangeSummonShow then
        local iSummon = oCtrl.m_EventData
        self:RefreshSummon(iSummon)
    elseif oCtrl.m_EventID == define.Summon.Event.SelStudyItem then
        self.m_StudyPart:SetStudyItem(oCtrl.m_EventData)
    elseif oCtrl.m_EventID == define.Summon.Event.SetCompoundSummon then
        local dEventData = oCtrl.m_EventData
        self.m_CompoundPart:RefreshSummonMat(dEventData.dSummon, dEventData.bRight)
    elseif oCtrl.m_EventID == define.Summon.Event.CombineSummonShow then
        self.m_CompoundPart:ComposeSuccess(oCtrl.m_EventData)
    elseif oCtrl.m_EventID == define.Summon.Event.AddExtendSize then
        self.m_ListBox:RefreshExtSize(oCtrl.m_EventData) 
    elseif oCtrl.m_EventID == define.Summon.Event.SetFightId then
        if oCtrl.m_EventData == nil then    
            return
        end
        self.m_ViewPart.m_ViewBox:RefreshIsFight()
        self.m_ListBox:RefreshFight()
    end
end

function CSummonAdjustPage.OnAttrCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
        self.m_WashPart:UpdateItemInfo()
        self.m_CompoundPart:RefreshCostItemCnt()
    end
end

function CSummonAdjustPage.OnDelSummon(self)
    if next(g_SummonCtrl:GetSummons()) == nil then
        self.m_ParentView:OnClose()
        return
    elseif not g_SummonCtrl:GetSummon(self.m_CurSummonId) then
        self.m_CurSummonId = g_SummonCtrl:GetSummonIdByIndex(1)
        g_SummonCtrl:SetCurSelSummon(self.m_CurSummonId)
        self:RefreshSummon(self.m_CurSummonId)
    end
    self.m_ListBox:RefreshSummons()
end

function CSummonAdjustPage.OnWashSummon(self, dSummonInfo)
    if dSummonInfo then
        local id = dSummonInfo.id
        self:RefreshSummon(id)
        self.m_ListBox:RefreshSummons()
    end
end

-------------------------
function CSummonAdjustPage.OnStudySkill(self)
    self.m_SkillBtn:SetSelected(true)
    self:OnClickPageBtn(Page.Study)
end

function CSummonAdjustPage.OnCompoundShow(self)
    if self.m_CompoundBtn == nil then
        return
    end
    self.m_CompoundBtn:SetSelected(true)
    self:OnClickPageBtn(Page.Compound)
end

function CSummonAdjustPage.OnCulture(self)
    self.m_CultureBtn:SetSelected(true)
    self:OnClickPageBtn(Page.Culture)
end

function CSummonAdjustPage.Destroy(self)
    self.m_WashPart:Destroy()
    self.m_CompoundPart:Destroy()
    CPageBase.Destroy(self)
end

return CSummonAdjustPage
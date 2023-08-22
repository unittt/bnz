local CSummonPropertyPage = class("CSummonPropertyPage", CPageBase)

local Tab = {
    Attr = 1,
    Apti = 2,
    AddPt = 3,
}

function CSummonPropertyPage.ctor(self, obj)
    CPageBase.ctor(self, obj)
    self.m_CurSummonId = nil
    self.m_SelPageIdx = nil
end

function CSummonPropertyPage.OnInitPage(self)
    self.m_ListBox = self:NewUI(1, CSummonListBox)
    self.m_LInfoBox = self:NewUI(2, CSummonLAttrPart)
    self.m_RAttrBox = self:NewUI(3, CSummonRAttrPart)
    self.m_AptiBox = self:NewUI(4, CSummonAptiBox)
    self.m_SkillBox = self:NewUI(5, CSummonSkillBox)
    self.m_AddPtBox = self:NewUI(6, CSummonAddPointPart)
    self.m_AttPageBtn = self:NewUI(7, CButton)
    self.m_AptiBtn = self:NewUI(8, CButton)
    self.m_AddPtBtn = self:NewUI(9, CButton)

     self.m_TabDict = {
        [1] = self.m_AttPageBtn,
        [2] = self.m_AptiBtn,
        [3] = self.m_AddPtBtn,
    }

    self.m_AptiBox:InitSliderUI()
    self:InitContent()
end

function CSummonPropertyPage.InitContent(self)
    self.m_AttPageBtn:SetGroup(self:GetInstanceID())
    self.m_AptiBtn:SetGroup(self:GetInstanceID())
    self.m_AddPtBtn:SetGroup(self:GetInstanceID())

    self:RegisterEvents()
end

function CSummonPropertyPage.RegisterEvents(self)
    self.m_AttPageBtn:AddUIEvent("click", callback(self, "OnClickPageBtn", Tab.Attr))
    self.m_AptiBtn:AddUIEvent("click", callback(self, "OnClickPageBtn", Tab.Apti))
    self.m_AddPtBtn:AddUIEvent("click", callback(self, "OnClickPageBtn", Tab.AddPt))
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CSummonPropertyPage.OnShowPage(self)
    self.m_CurSummonId = g_SummonCtrl:GetCurSelSummon()
    self.m_AttPageBtn:SetSelected(true)
    self:OnClickPageBtn(Tab.Attr)
    self:SetSummonSel(self.m_CurSummonId)
    self.m_ListBox:RefreshSummons()
end

function CSummonPropertyPage.OnHidePage(self)
    self.m_RAttrBox:RemoveItemTip()
end

function CSummonPropertyPage.SetSummonSel(self, summonId)
    if g_SummonCtrl:GetSummon(summonId) == nil then
        printc("宠物不存在")
        return
    end
    g_SummonCtrl:SetCurSelSummon(summonId)
    self.m_CurSummonId = summonId
    local dInfo = g_SummonCtrl:GetSummon(summonId)
    self.m_LInfoBox:SetInfo(dInfo)
    self.m_RAttrBox:SetInfo(dInfo)
    self.m_AptiBox:SetInfo(dInfo)
    self:SetSkillInfo(dInfo)
    self.m_AddPtBox:SetInfo(dInfo)
end

function CSummonPropertyPage.SetSkillInfo(self, info)
    local skills = SummonDataTool.GetSkillInfo(info)
    self.m_SkillBox:SetInfo(skills, true)
end

------------------events -----------------
function CSummonPropertyPage.OnClickPageBtn(self, idx)
    if idx == self.m_SelPageIdx then
        return
    end
    self.m_RAttrBox:SetActive(idx == Tab.Attr)
    self.m_AptiBox:SetActive(idx == Tab.Apti)
    self.m_AddPtBox:SetActive(idx == Tab.AddPt)
    self.m_SkillBox:SetActive(idx ~= Tab.AddPt)
    self.m_SelPageIdx = idx
    -- if idx == Tab.Apti then
        -- self.m_ListBox:SetSummonBoxRedPoint(self.m_CurSummonId, false)
    if idx == Tab.AddPt then
        local dSummon = g_SummonCtrl:GetSummon(self.m_CurSummonId)
        self.m_AddPtBox:SetInfo(dSummon)
    end
end

function CSummonPropertyPage.OnCtrlEvent(self, oCtrl)
    if self:GetActive() == false then
        return
    end
    --更新宠物信息
    if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo then
        local iUpdate = oCtrl.m_EventData.id
        if iUpdate == self.m_CurSummonId then
            self:SetSummonSel(iUpdate)
        end
        self.m_ListBox:SetSummonBoxInfo(oCtrl.m_EventData)
    --删除宠物
    elseif oCtrl.m_EventID == define.Summon.Event.DelSummon then  
        self:OnDelSummon()
    --响应是否参战
    elseif oCtrl.m_EventID == define.Summon.Event.SetFightId then
        if oCtrl.m_EventData == nil then    
            return
        end
        self.m_LInfoBox:OnSetFight(oCtrl.m_EventData)
        self.m_ListBox:RefreshFight()
    --添加宠物
    elseif oCtrl.m_EventID == define.Summon.Event.AddSummon then
        self:OnAddSummon(oCtrl.m_EventData.id)
    --是否跟随
    elseif oCtrl.m_EventID == define.Summon.Event.SetFollow then
        self.m_LInfoBox:OnSetFollow(oCtrl.m_EventData)
    --切换宠物
    elseif oCtrl.m_EventID == define.Summon.Event.ChangeSummonShow then
        if oCtrl.m_EventData == nil then
            return
        end
        self:SetSummonSel(oCtrl.m_EventData)
    elseif oCtrl.m_EventID == define.Summon.Event.AddExtendSize then
        self.m_ListBox:RefreshExtSize(oCtrl.m_EventData)
    elseif oCtrl.m_EventID == define.Summon.Event.GetSummonSecProp then
        self:SetSummonSel(self.m_CurSummonId)
    end 
end

function CSummonPropertyPage.OnAddSummon(self, id)
    self:SetSummonSel(id)
    self.m_ListBox:RefreshSummons()
end

function CSummonPropertyPage.OnDelSummon(self)
    if next(g_SummonCtrl:GetSummons()) == nil then
        self.m_ParentView:OnClose()
        return
    elseif not g_SummonCtrl:GetSummon(self.m_CurSummonId) then
        self.m_CurSummonId = g_SummonCtrl:GetSummonIdByIndex(1)
        g_SummonCtrl:SetCurSelSummon(self.m_CurSummonId)
        self:SetSummonSel(self.m_CurSummonId)
    end
    self.m_ListBox:RefreshSummons()
end

function CSummonPropertyPage.HandleItemTip(self, iItemId)
    self.m_RAttrBox:HandleItemTip(iItemId)
end

---------------------------------
function CSummonPropertyPage.ShowAddPtView(self, bShowReset)
    self.m_AddPtBtn:SetSelected(true)
    self:OnClickPageBtn(Tab.AddPt)
    if bShowReset then
        self.m_AddPtBox:OnClickReset()
    end
end


return CSummonPropertyPage
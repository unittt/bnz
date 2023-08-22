local CSummonBookPage = class("CSummonBookPage", CPageBase)

function CSummonBookPage.ctor(self, obj)
    CPageBase.ctor(self, obj)
end

function CSummonBookPage.OnInitPage(self)
    self.m_DesBtn = self:NewUI(1, CButton)
    self.m_AptiBox = self:NewUI(2, CSummonBookAptiBox)
    self.m_InfoBox = self:NewUI(3, CSummonBookInfoBox)
    self.m_SkillBox = self:NewUI(4, CSummonSkillBox, nil, 7)
    self.m_GetWayBox = self:NewUI(5, CSummonGetWayBox)
    self.m_ListBox = self:NewUI(6, CSummonBookListBox)
    self.m_AdvAptiBox = self:NewUI(7, CSummonBookAdvAptiBox)
    self:InitContent()
end

function CSummonBookPage.OnShowPage(self)
    self.m_ListBox:InitInfo()
end

function CSummonBookPage.InitContent(self)
    self.m_ListBox.m_ParentView = self
    self.m_DesBtn:AddUIEvent("click", callback(self, "OnDes"))
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSummonCtrlEvent"))
end

function CSummonBookPage.SetSkillInfo(self, summonInfo)
    local skills = SummonDataTool.GetConfigSkillInfo(summonInfo)
    self.m_SkillBox:SetInfo(skills)
end

-- bSpc == true 选择特殊页面
function CSummonBookPage.SetSelSummon(self, info, bSpc)
    local iType = bSpc and 2 or 1
    local iSel = info.id
    self.m_ListBox:SetSelBtn(iType)
    self.m_ListBox.selId = iSel
    self.m_ListBox:OnSelType(iType)
end

function CSummonBookPage.IsCanAdvance(self, dInfo)
    return SummonDataTool.IsGodSummon(dInfo.type) or dInfo.type == 8
end

function CSummonBookPage.OnSelSummon(self, info)
    local bAdv = self:IsCanAdvance(info)
    self.m_AptiBox:SetActive(not bAdv)
    self.m_AdvAptiBox:SetActive(bAdv)
    if bAdv then
        self.m_AdvAptiBox:SetInfo(info)
    else
        self.m_AptiBox:SetAttr(info)
    end
    self.m_InfoBox:SetInfo(info)
    self:SetSkillInfo(info)
    self.m_GetWayBox:SetInfo(info)
    self.m_GetWayBox.m_ParentView = self
end

function CSummonBookPage.OnDes(self)
    local dInst = DataTools.GetInstructionInfo(10005)
   local zContent = {title = dInst.title, desc = dInst.desc}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CSummonBookPage.OnSummonCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Summon.Event.SelBookSummon then
        local dSummon = oCtrl.m_EventData
        if self.m_ListBox:GetSummonById(dSummon.id) then
            self.m_ListBox:OnClickSummon(dSummon)
        else
            self:SetSelSummon(dSummon)
        end
        g_NotifyCtrl:FloatMsg("跳转成功")
    end
end

return CSummonBookPage
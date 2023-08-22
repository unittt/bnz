local CSummonCompoundMatPart = class("CSummonCompoundMatPart", CBox)

function CSummonCompoundMatPart.ctor(self, obj, isRight)
    CBox.ctor(self, obj)
    self.m_IsRight = isRight
    self:InitContent()
end

function CSummonCompoundMatPart.InitContent(self)
    self.m_MatItem = self:NewUI(1, CSummonCompoundItemBox)
    self.m_AptiBox = self:NewUI(2, CSummonAptiBox)
    self.m_SkillBox = self:NewUI(3, CSummonSkillBox)
    self.m_EmptyWidget = self:NewUI(4, CWidget)
    self.m_AptiBox:InitTextUI(true)
    self.m_MatItem:AddUIEvent("click", callback(self, "OnClickSelSummon"))
end

function CSummonCompoundMatPart.SetInfo(self, dInfo)
    local bHasSummon = dInfo and true or false
    self.m_SummonInfo = dInfo
    self.m_MatItem:SetInfo(dInfo)
    self.m_AptiBox:SetActive(bHasSummon)
    self.m_SkillBox:SetActive(bHasSummon)
    self.m_EmptyWidget:SetActive(not bHasSummon)
    if bHasSummon then
        self.m_AptiBox:SetInfo(dInfo)
        self:SetSkillInfo(dInfo)
    end
end

function CSummonCompoundMatPart.SetSkillInfo(self, dInfo)
    local skills = SummonDataTool.GetSkillInfo(dInfo)
    self.m_SkillBox:SetInfo(skills)
end

function CSummonCompoundMatPart.OnClickSelSummon(self)
    CSummonCompoundSelView:ShowView(function(oView)
        oView.isRight = self.m_IsRight
        oView:RefreshSummons()
        UITools.NearTarget(self.m_MatItem, oView.m_NearWidget, enum.UIAnchor.Side.Bottom, Vector2.New(0, 0))
    end)
end

-------------- 神兽合成 ---------------
function CSummonCompoundMatPart.SetSelSummons(self, ids, bAddEvent)
    self.m_SummonIds = ids
    if bAddEvent then
        self.m_MatItem:AddUIEvent("click", callback(self, "OnSelSummonByIds"))
    end
end

function CSummonCompoundMatPart.OnSelSummonByIds(self)
    CSummonCompoundSelView:ShowView(function(oView)
        oView.isRight = self.m_IsRight
        oView:RefreshSummonByIds(self.m_SummonIds)
        UITools.NearTarget(self.m_MatItem, oView.m_NearWidget, enum.UIAnchor.Side.Bottom, Vector2.New(0, 0))
    end)
end

return CSummonCompoundMatPart
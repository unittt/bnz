local CSummonBookAdvAptiBox = class("CSummonBookAdvAptiBox", CBox)

function CSummonBookAdvAptiBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_AttrInfo = g_SummonCtrl:GetAptiConfig()
    self.m_TopLv = #data.summondata.ADVANCE
    self.m_CurLv = 0
    self:InitContent()
end

function CSummonBookAdvAptiBox.InitContent(self)
    self.m_AttrGrid = self:NewUI(1, CGrid)
    self.m_AttrItemBox = self:NewUI(2, CBox)
    self.m_AddBtn = self:NewUI(3, CButton)
    self.m_SubBtn = self:NewUI(4, CButton)
    self.m_LvL = self:NewUI(5, CLabel)
    self.m_GotoBtn = self:NewUI(6, CButton)
    self.m_AttrItemBox:SetActive(false)

    self.m_AddBtn:AddUIEvent("click", callback(self, "OnClickAddLv"))
    self.m_SubBtn:AddUIEvent("click", callback(self, "OnClickSubLv"))
    self.m_GotoBtn:AddUIEvent("click", callback(self, "OnClickGoto"))
end

function CSummonBookAdvAptiBox.SetInfo(self, summonInfo)
    self.m_CurLv = 0
    self.m_SummonInfo = summonInfo
    self:RefreshAttrs()
end

function CSummonBookAdvAptiBox.RefreshAttrs(self)
    local dInfo = self.m_SummonInfo
    for i, v in ipairs(self.m_AttrInfo) do
        local oItem = self:GetAttrItemBox(i)
        local iVal = dInfo.aptitude[v.key] or dInfo[v.key]
        for iLv = 1, self.m_CurLv do
            local dAdv = SummonDataTool.GetAdvanceLvData(iLv, dInfo.type)
            if dAdv then
                iVal = iVal + dAdv[v.key]
            end
        end
        if v.key == "grow" then
            iVal = iVal / 1000
        end
        oItem.valL:SetText(iVal)
    end
    if self.m_CurLv > 0 then
        self.m_LvL:SetText(string.print4Pos(self.m_CurLv).."阶")
    else
        self.m_LvL:SetText("未进阶")
    end
end

function CSummonBookAdvAptiBox.GetAttrItemBox(self, idx)
    local oItem = self.m_AttrGrid:GetChild(idx)
    if not oItem then
        oItem = self.m_AttrItemBox:Clone()
        oItem.valL = oItem:NewUI(1, CLabel)
        oItem.titleL = oItem:NewUI(2, CLabel)
        oItem.titleL:SetText(self.m_AttrInfo[idx].name)
        self.m_AttrGrid:AddChild(oItem)
        oItem:SetActive(true)
    end
    return oItem
end

function CSummonBookAdvAptiBox.OnClickAddLv(self)
    if self.m_CurLv >= self.m_TopLv then
        return
    end
    self.m_CurLv = self.m_CurLv + 1
    self:RefreshAttrs()
end

function CSummonBookAdvAptiBox.OnClickSubLv(self)
    if self.m_CurLv <= 0 then
        return
    end
    self.m_CurLv = self.m_CurLv - 1
    self:RefreshAttrs()
end

function CSummonBookAdvAptiBox.OnClickGoto(self)
    local iSummonId = self.m_SummonInfo and self.m_SummonInfo.id
    if not iSummonId then return end
    if g_WarCtrl:IsWar() then
        g_NotifyCtrl:FloatMsg("请脱离战斗后再进行操作")
       return
    end
    g_SummonCtrl:GotoExchangeNpc(iSummonId)
end

return CSummonBookAdvAptiBox
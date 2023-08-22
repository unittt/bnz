local CSummonAdvAptiBox = class("CSummonWashPart", CBox)

function CSummonAdvAptiBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_Attrs = g_SummonCtrl:GetAptiConfig()
    self:InitContent()
end

function CSummonAdvAptiBox.InitContent(self)
    self.m_AptiGrid = self:NewUI(1, CGrid)
    self.m_AptiBox = self:NewUI(2, CBox)
    self.m_CurStateL = self:NewUI(3, CLabel)
    self.m_NextStateL = self:NewUI(4, CLabel)
    self.m_MidStateL = self:NewUI(5, CLabel)
    self:InitAptiGrid()
end

function CSummonAdvAptiBox.InitAptiGrid(self)
    self.m_AptiBox:SetActive(false)
    for i, dAttr in ipairs(self.m_Attrs) do
        local oBox = self.m_AptiBox:Clone()
        oBox:SetActive(true)
        oBox.key = dAttr.key
        oBox.curValL = oBox:NewUI(1, CLabel)
        oBox.nextValL = oBox:NewUI(2, CLabel)
        oBox.titleL = oBox:NewUI(3, CLabel)
        oBox.midValL = oBox:NewUI(4, CLabel)
        oBox.curValL:SetActive(false)
        oBox.nextValL:SetActive(false)
        oBox.midValL:SetActive(false)
        oBox.titleL:SetText(dAttr.name)
        self.m_AptiGrid:AddChild(oBox)
    end
    self.m_AptiGrid:Reposition()
end

function CSummonAdvAptiBox.SetInfo(self, dSummon)
    local iCurLv = dSummon.advance_level or 0
    local iLv = iCurLv + 1
    local dLevel = SummonDataTool.GetAdvanceLvData(iLv, dSummon.type)
    local dApti = dSummon.curaptitude
    local bNext = dLevel ~= nil
    self.m_CurStateL:SetActive(bNext)
    self.m_NextStateL:SetActive(bNext)
    self.m_MidStateL:SetActive(not bNext)
    if bNext then
        local sLv
        if iCurLv <= 0 then
            sLv = "未进阶"
        else
            sLv = string.print4Pos(iCurLv).."阶"
        end
        self.m_CurStateL:SetText(sLv)
        self.m_NextStateL:SetText(string.print4Pos(iLv).."阶")
    else
        self.m_MidStateL:SetText(string.print4Pos(iCurLv).."阶")
    end
    for i, oBox in ipairs(self.m_AptiGrid:GetChildList()) do
        oBox.curValL:SetActive(bNext)
        oBox.nextValL:SetActive(bNext)
        oBox.midValL:SetActive(not bNext)
        local iVal = dApti[oBox.key]
        if bNext then
            local iAdd = dLevel[oBox.key]
            if oBox.key == "grow" then
                iAdd = iAdd / 1000
                iVal = dSummon.grow / 1000
            end
            oBox.curValL:SetText(iVal)
            oBox.nextValL:SetText(iVal + iAdd)
        else
            if oBox.key == "grow" then
                iVal = dSummon.grow / 1000
            end
            oBox.midValL:SetText(iVal)
        end
    end
end

return CSummonAdvAptiBox
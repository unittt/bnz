local CSummonAddPointPart = class("CSummonAddPointPart", CBox)

function CSummonAddPointPart.ctor(self, obj)
    CBox.ctor(self, obj)

    self.m_SummonId = nil
    self.m_AttrPtId = nil
    self.m_PtAttrAddStr = "[63432c]%d[1d8e00]+%d[-][-]"
    self.m_PtAttrStr = "[63432c]%d[-]"
    self.m_TempPtVal = 0

    self.m_SummonInfo = {}
    self.m_PtBoxDict = {}
    self.m_AttrBoxDict = {}

    self:InitContent()
end

function CSummonAddPointPart.InitContent(self)
    self.m_AttrGrid = self:NewUI(1, CGrid)
    self.m_PtGrid = self:NewUI(2, CGrid)
    self.m_ResetBtn = self:NewUI(3, CButton)
    self.m_ComfirmBtn = self:NewUI(4, CButton)
    self.m_PtItemBox = self:NewUI(5, CBox)
    self.m_PtAttrValL = self:NewUI(6, CLabel)

    self.m_PtItemBox:SetActive(false)
    self:InitAttrGrid()
    self:InitPtGrid()
    self.m_ResetBtn:AddUIEvent("click", callback(self, "OnClickReset"))
    self.m_ComfirmBtn:AddUIEvent("click", callback(self, "OnClickComfirm"))
end

function CSummonAddPointPart.InitAttrGrid(self)
    local lAttrs = {"max_hp", "max_mp", "phy_attack", "phy_defense", "mag_attack", "mag_defense", "speed", "point"}
    local function initFunc(obj, idx)
        local oBox = CBox.New(obj)
        oBox.nameL = oBox:NewUI(1, CLabel)
        oBox.valL = oBox:NewUI(2, CLabel)
        oBox.valL:SetColor(Color.white)
        oBox.idx = idx
        oBox.key = lAttrs[idx]
        if idx == 8 then
            oBox.resetBtn = oBox:NewUI(3, CButton)
            oBox.resetBtn:AddUIEvent("click", callback(self, "OnClickAddType"))
        end
        return oBox
    end
    self.m_AttrGrid:InitChild(initFunc)
    for i, key in ipairs(lAttrs) do
        self.m_AttrBoxDict[key] = self.m_AttrGrid:GetChild(i)
    end
end

function CSummonAddPointPart.InitPtGrid(self)
    local lPtKeys = {"physique", "magic", "strength", "endurance", "agility"}
    local dAttrConfig = data.rolepointdata.ROLEBASICSCORE
    for i, key in ipairs(lPtKeys) do
        local dAttr = dAttrConfig[key]
        if dAttr then
            local oBox = self.m_PtItemBox:Clone()
            oBox:SetActive(true)
            oBox.subBtn = oBox:NewUI(1, CSprite)
            oBox.valL = oBox:NewUI(2, CLabel)
            oBox.addBtn = oBox:NewUI(3, CSprite)
            oBox.nameL = oBox:NewUI(4, CLabel)
            self.m_PtGrid:AddChild(oBox)
            oBox.attrKey = key
            oBox.valL:SetColor(Color.white)
            oBox.nameL:SetText(dAttr.name)
            oBox.addVal = 0
            oBox.subBtn:AddUIEvent("repeatpress", callback(self, "OnClickSubBtn", oBox))
            oBox.addBtn:AddUIEvent("repeatpress", callback(self, "OnClickAddBtn", oBox))
            self.m_PtBoxDict[key] = oBox
        end
    end
end

function CSummonAddPointPart.SetInfo(self, info)
    self.m_SummonId = info.id
    self.m_SummonInfo = info
    self.m_TempPtVal = self.m_SummonInfo.point
    self.m_AttrVals = {}
    self:RefreshAll()
end

function CSummonAddPointPart.RefreshAll(self)
    self:RefreshPoints()
    self:SetPtBtnsEnable()
    self:RefreshAttr()
    self:SetConfirmBtnState()
end

function CSummonAddPointPart.RefreshPoints(self)
    local dSummon = self.m_AttrVals
    for k, v in pairs(self.m_SummonInfo) do
        if type(v) == "table" then
            for i, j in pairs(v) do
                dSummon[i] = j
            end
        else
            dSummon[k] = v
        end
    end
    dSummon.speed = self.m_SummonInfo.speed
    for k, oBox in pairs(self.m_PtBoxDict) do
        local iVal = dSummon[k]
        oBox.valL:SetText(string.format(self.m_PtAttrStr, iVal))
        oBox.attrVal = iVal
        oBox.addVal = 0
    end
    dSummon.point = dSummon.point or 0
    self.m_TempPtVal = dSummon.point
end

function CSummonAddPointPart.RefreshAttr(self)
    local dSummon = self.m_AttrVals
    for k, oBox in pairs(self.m_AttrBoxDict) do
        oBox.valL:SetText(string.format(self.m_PtAttrStr, dSummon[k]))
    end
end

function CSummonAddPointPart.RefreshAddAttr(self)
    local dInfo = self.m_SummonInfo
    local dCalc = SummonDataTool.GetSummonCalcInfo(dInfo)
    for k, oBox in pairs(self.m_PtBoxDict) do
        local addVal = oBox.addVal or 0
        if addVal > 0 then
            dCalc[k] = dCalc[k] + addVal
        end
    end
    for k, oBox in pairs(self.m_AttrBoxDict) do
        local iNew = SummonDataTool.CalcAttr(dCalc, k, dInfo)
        if iNew then
            local iOwn = self.m_AttrVals[k]
            local iChange = iNew - iOwn
            if iChange > 0 then
                oBox.valL:SetText(string.format(self.m_PtAttrAddStr, iOwn, iChange))
            else
                oBox.valL:SetText(string.format(self.m_PtAttrStr, iOwn))
            end
        end
    end
end

function CSummonAddPointPart.SetPtBtnsEnable(self)
    local normalCol = Color.New(1,1,1,1)
    local greyCol = Color.New(0,0,0,1)
    local addBtnCol = self.m_TempPtVal > 0 and normalCol or greyCol
    for k, v in pairs(self.m_PtBoxDict) do
        local bSubEnable = v.addVal > 0
        v.subBtn:SetColor(bSubEnable and normalCol or greyCol)
        v.addBtn:SetColor(addBtnCol)
    end
end

function CSummonAddPointPart.SetConfirmBtnState(self)
    local bEnable = not (self.m_TempPtVal == self.m_AttrVals.point)
    self.m_ComfirmBtn:SetEnabled(bEnable)
    self.m_ComfirmBtn:SetBtnGrey(not bEnable)
end

function CSummonAddPointPart.OnClickReset(self)
    if not self.m_SummonId then return end
    local dSummon = self.m_SummonInfo
    if dSummon.grade < 10 then
        g_NotifyCtrl:FloatSummonMsg(1037)
        return
    end
    if dSummon.type == 1 then
        g_NotifyCtrl:FloatSummonMsg(1038)
        return
    end 
    CSummonWashPointView:ShowView(function(oView)
        oView:SetData(self.m_SummonId)       
    end)
end

function CSummonAddPointPart.OnClickComfirm(self)
   if not self.m_SummonId then return end
   local dWash = {}
   for k, v in pairs(self.m_PtBoxDict) do
        dWash[k] = v.addVal
   end
   g_SummonCtrl:UpdatePoint(self.m_SummonId, dWash)
end

function CSummonAddPointPart.OnClickSubBtn(self, oBox, oBtn, bPress)
    local iCurAdd = oBox.addVal
    if iCurAdd < 1 or not bPress then
        return
    end
    iCurAdd = iCurAdd - 1
    oBox.addVal = iCurAdd
    self.m_TempPtVal = self.m_TempPtVal + 1
    self.m_PtAttrValL:SetText(string.format(self.m_PtAttrStr, self.m_TempPtVal))
    if iCurAdd > 0 then
        oBox.valL:SetText(string.format(self.m_PtAttrAddStr, oBox.attrVal, iCurAdd))
    else
        oBox.valL:SetText(string.format(self.m_PtAttrStr, oBox.attrVal))
    end
    self:SetConfirmBtnState()
    self:SetPtBtnsEnable()
    self:RefreshAddAttr()
end

function CSummonAddPointPart.OnClickAddBtn(self, oBox, oBtn, bPress)
    if not bPress then
        return
    end
    local dSummon = self.m_SummonInfo
    if dSummon.type == 1 then
        g_NotifyCtrl:FloatSummonMsg(1038)
        return
    end
    if dSummon.grade < 10 then
        g_NotifyCtrl:FloatSummonMsg(1037)
        return
    end
    if self.m_TempPtVal < 1 then 
        g_NotifyCtrl:FloatSummonMsg(1039)
        return
    end
    local iCurAdd = oBox.addVal
    iCurAdd = iCurAdd + 1
    oBox.addVal = iCurAdd
    self.m_TempPtVal = self.m_TempPtVal - 1
    self.m_PtAttrValL:SetText(string.format(self.m_PtAttrStr, self.m_TempPtVal))
    oBox.valL:SetText(string.format(self.m_PtAttrAddStr, oBox.attrVal, iCurAdd))
    self:SetConfirmBtnState()
    self:SetPtBtnsEnable()
    self:RefreshAddAttr()
end

function CSummonAddPointPart.OnClickAddType(self)
    g_SummonCtrl:C2GSSummonRequestAuto(self.m_SummonId)
end

return CSummonAddPointPart
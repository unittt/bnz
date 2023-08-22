local CSummonCultureAptiBox = class("CSummonCultureAptiBox", CBox)

function CSummonCultureAptiBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_AptiList = {
        [1] = {attr = "attack", name = "攻击"},
        [2] = {attr = "defense", name = "防御"},
        [3] = {attr = "health", name = "体力"},
        [4] = {attr = "mana", name = "法力"},
        [5] = {attr = "speed", name = "速度"},
        [6] = {attr = "grow", name = "成  长"},
    }
    self:InitContent()
end

function CSummonCultureAptiBox.InitContent(self)
    self.m_Grid = self:NewUI(1, CGrid)
    local function initFunc(obj, idx)
        local oBox = CBox.New(obj)
        if idx == 6 then
            oBox.valL = oBox:NewUI(1, CLabel)
        else
            oBox.slider = oBox:NewUI(1, CSlider)
        end
        oBox.nameL = oBox:NewUI(2, CLabel)
        return oBox
    end
    self.m_Grid:InitChild(initFunc)
end

function CSummonCultureAptiBox.SetInfo(self, dSummon)
    local dSlider = self:GetSliderData(dSummon)
    local iNotFull = nil
    for i, oChild in ipairs(self.m_Grid:GetChildList()) do
        local dApti = self.m_AptiList[i]
        if i == 6 then
            oChild.nameL:SetText(dApti.name)
            oChild.valL:SetText(dSummon[dApti.attr]/1000)
        else
            local data = dSlider[i]
            self:SetSlider(oChild.slider, data)
            oChild.nameL:SetText(dApti.name .. "资质")
            oChild.isFull = data.cur >= data.max
            oChild.attrKey = dApti.attr
            oChild.nameText = dApti.name
            if not iNotFull and not oChild.isFull then
                iNotFull = i
            end
        end
    end
    iNotFull = iNotFull or 1
    return iNotFull
end

function CSummonCultureAptiBox.GetSliderData(self, dSummon)
    local dSlider = {}
    local dCurApti = dSummon.curaptitude
    local dMaxApti = dSummon.maxaptitude
    local dMinApti = SummonDataTool.GetSummonInfo(dSummon.typeid).aptitude
    local bSpc = SummonDataTool.IsUnnormalSummon(dSummon.type)
    for i, k in ipairs(self.m_AptiList) do
        local sAttr = k.attr
        local iMax = dMaxApti[sAttr] or 0
        local iMin
        if bSpc then
            iMin = iMax*0.79
        else
            iMin = iMax*0.79
        end
        local data = {
            cur = dCurApti[sAttr],
            max = iMax,
            min = iMin,
        }
        table.insert(dSlider, data)
    end
    return dSlider
end

function CSummonCultureAptiBox.GetGridChildList(self)
    return self.m_Grid:GetChildList()
end

function CSummonCultureAptiBox.GetGridChild(self, idx)
    return self.m_Grid:GetChild(idx)
end

function CSummonCultureAptiBox.SetSlider(self, oSlider, data)
    local iMin, iCur, iMax = data.min, data.cur, data.max
    if iMin == iMax then
        oSlider:SetValue(1)
    else
        oSlider:SetValue((iCur-iMin)/(iMax-iMin))
    end
    oSlider:SetSliderText(iCur.."/"..iMax)
end

return CSummonCultureAptiBox
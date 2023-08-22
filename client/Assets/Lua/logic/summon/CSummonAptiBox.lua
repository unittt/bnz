local CSummonAptiBox = class("CSummonAptiBox", CBox)

function CSummonAptiBox.ctor(self, obj)
	CBox.ctor(self, obj)
    self.m_DefaultAttrs = {"attack", "defense", "health", "mana", "speed", "grow"}
end

function CSummonAptiBox.InitSliderUI(self)
    local keyList = self.m_DefaultAttrs
    local aptiInfo = {}
    for _, k in ipairs(keyList) do
        local dAttr = {}
        dAttr.attr = k
        if k == "grow" then
            dAttr.isText = true
        end
        table.insert(aptiInfo, dAttr)
    end
    self:InitUI(aptiInfo)
end

-- bTopAttr: 是否最大资质
function CSummonAptiBox.InitTextUI(self, bTopAttr)
    local keyList = self.m_DefaultAttrs
    local aptiInfo = {}
    for _, k in ipairs(keyList) do
        local dAttr = {}
        dAttr.attr = k
        dAttr.isTop = bTopAttr
        dAttr.isText = true
        table.insert(aptiInfo, dAttr)
    end
    self:InitUI(aptiInfo)
end

-- info: isText, attr
function CSummonAptiBox.InitUI(self, info)
    self.m_UIData = info
    local function InitSlider(obj, idx)
		local box = CBox.New(obj)
        local d = info[idx]
		if d.isText then 
			box.number = box:NewUI(2, CLabel)
		else
            box.slider = box:NewUI(2, CSlider)	
		end
        box.isText = d.isText
		return box
	end
	self.m_AptAttrList = self:NewUI(1, CGrid)
    self.m_AptAttrList:InitChild(InitSlider)
end

function CSummonAptiBox.SetInfo(self, summon)
    local list = self:GetData(summon)
	for i,v in ipairs(self.m_AptAttrList:GetChildList()) do
        local data = list[i]
        if v.isText then
            v.number:SetText(data)
        else
            self:SetSlider(v.slider, data)            
        end
	end
end

function CSummonAptiBox.GetData(self, summon)
    local dInfo = nil
    local dataList = {}
    if type(summon) == "number" then
        dInfo = g_SummonCtrl:GetSummon(summon)
    elseif type(summon) == "table" then
        dInfo = summon
    end
    if not dInfo then 
        return
    end
    local dCurApti = dInfo.curaptitude
    local dMaxApti = dInfo.maxaptitude
    local dMinApti = SummonDataTool.GetSummonInfo(summon.typeid).aptitude
    local bSpc = SummonDataTool.IsUnnormalSummon(summon.type)
    for i, dUI in ipairs(self.m_UIData) do
        local d
        local key = dUI.attr
        if dUI.isText then
            if key == "grow" then
                d = dInfo[key]/1000
            else
                if dUI.isTop then
                    d = dMaxApti[key]
                else
                    d = dCurApti[key]
                end
            end
        else
            local iMax = dMaxApti[key]
            local iMin
            if bSpc then
                iMin = iMax*0.79
            else
                iMin = iMax*0.79
            end
            d = {
                cur = dCurApti[key],
                max = iMax,
                min = iMin,
            }
        end
        table.insert(dataList, d)
    end
    return dataList
end

function CSummonAptiBox.SetSlider(self, slider, data)
    local iMin, iCur, iMax = data.min, data.cur, data.max
    if iMin == iMax then
        slider:SetValue(1)
	else
        slider:SetValue((iCur-iMin)/(iMax-iMin))
    end
	slider:SetSliderText(iCur.."/"..iMax)
end

return CSummonAptiBox
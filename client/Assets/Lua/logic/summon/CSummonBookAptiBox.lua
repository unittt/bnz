local CSummonBookAptiBox = class("CSummonBookAptiBox", CBox)

function CSummonBookAptiBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_AttrList = {"attack", "defense", "health", "mana", "speed"}
    self:InitContent()
end

function CSummonBookAptiBox.InitContent(self)
    self.m_AttrGrid = self:NewUI(1, CGrid)
    self:InitAttr()
end

function CSummonBookAptiBox.InitAttr(self)
    local function init(obj, idx)
        local oBox = CBox.New(obj)
        oBox.val = oBox:NewUI(1, CLabel)
        return oBox
    end
    self.m_AttrGrid:InitChild(init)
end

function CSummonBookAptiBox.SetAttr(self, summonInfo)
    local bAdv = false
    for k,v in ipairs(self.m_AttrList) do
        local item = self.m_AttrGrid:GetChild(k)
        local maxVal, val = 0, 0
        local iType = summonInfo.type
        local iApti = summonInfo.aptitude[v]
        bAdv = SummonDataTool.IsExpensiveSumm(iType)
        -- 神兽
        if bAdv then
            val = math.floor(iApti)
            item.val:SetText(val)
        else
            -- 其它稀有宠
            if summonInfo.type < 3 then
                maxVal = math.floor(iApti*125/100)
            else
                maxVal = math.floor(iApti*1.30)
            end
            val = math.floor(iApti)
            item.val:SetText(val.."-"..maxVal)
        end
    end
    self:SetGrow(summonInfo.grow, bAdv)
end

function CSummonBookAptiBox.SetGrow(self, iGrow, bAdv)
    if bAdv then
        self.m_AttrGrid:GetChild(6).val:SetText(iGrow/1000)
    else
        local maxtb = {}
        local mintb = {}
        local num = #data.summondata.GROW
        for i,v in ipairs(data.summondata.GROW) do 
            table.insert(maxtb,v.max)
            table.insert(mintb,v.min)
        end
        table.sort(maxtb)
        local GrowMax 
        for i,v in ipairs(maxtb) do
            if num == i then
                GrowMax= v
            end
        end
        local GrowMin
        GrowMin =mintb[1]
        local maxGrow = string.format("%0.4f", GrowMax * iGrow * 0.00001)
        local num2 = string.sub(tostring(maxGrow),0,-2)
        local minGrow = string.format("%0.4f", GrowMin * iGrow * 0.00001)
        local num1 = string.sub(tostring(minGrow),0,-2)
        self.m_AttrGrid:GetChild(6).val:SetText(num1.."～"..num2)
    end
end

return CSummonBookAptiBox
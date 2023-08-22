local CRanseCtrl = class("CRanseCtrl", CCtrlBase)

function CRanseCtrl.ctor(self)

	CCtrlBase.ctor(self)

end

function CRanseCtrl.GS2COpenRanSe(self, data)
    
    CRanseMainView:ShowView(function (oView)
        oView:ShowRanse()
    end)

end

--part 部位
--color 颜色索引
function CRanseCtrl.C2GSPlayerRanSe(self, clothesColor, hairColor, pantColor, flag)
    
    --printc("----------------------请求染色:" .. "头发：" .. tostring(hairColor) .. " 衣服：" .. tostring(clothesColor))

    netplayer.C2GSPlayerRanSe(clothesColor, hairColor, pantColor, flag)

end


--获取颜色值
function CRanseCtrl.GetColorValue(self, part, id, shape)
    
    local colorValue = nil

    local modelShape = shape

    local colorList = nil

    if part == define.Ranse.PartType.hair then 
        if data.ransedata.HAIR[modelShape] then 
            colorList =  data.ransedata.HAIR[modelShape].colorlist[id]
            if colorList then 
                colorValue = colorList.value
            end 
        end 
    elseif part == define.Ranse.PartType.clothes then 
        if data.ransedata.CLOTHES[modelShape] then 
            colorList =  data.ransedata.CLOTHES[modelShape].colorlist[id]
            if colorList then 
                colorValue = colorList.value1
            end
        end 
    elseif part ==  define.Ranse.PartType.other then
        if  data.ransedata.CLOTHES[modelShape] then 
            colorList =  data.ransedata.CLOTHES[modelShape].colorlist[id]
            if colorList then 
                colorValue = colorList.value2
            end 
        end 
    elseif part ==  define.Ranse.PartType.pant then
        if  data.ransedata.PANT[modelShape] then 
            colorList =  data.ransedata.PANT[modelShape].colorlist[id]
            if colorList then 
                colorValue = colorList.value
            end
        end
    end

    local color = self:ParseStrToColor(colorValue)

    return color

end

--获取宠物染色列表
function CRanseCtrl.GetSummonColorList(self, shape, colorIndex)
    
    local colorList = {}

    if colorIndex == 0 then 
        colorList[define.Ranse.PartType.hair] = Color.New(1,1,1,1)
        colorList[define.Ranse.PartType.clothes] = Color.New(1,1,1,1)
        colorList[ define.Ranse.PartType.other] = Color.New(1,1,1,1)
    else
        local config = data.ransedata.SUMMON[shape]
        if config then 
            if config.colorlist then 
                local list =  config.colorlist[colorIndex]
                colorList[define.Ranse.PartType.hair] = self:ParseStrToColor(list.value1)
                colorList[define.Ranse.PartType.clothes] = self:ParseStrToColor(list.value2)
                colorList[ define.Ranse.PartType.other] = self:ParseStrToColor(list.value3)
            end 
        end 
    end

    return colorList

end

function CRanseCtrl.GetSummonExColorList(self, shape, colorIndex)
    
    local colorList = {}
    if colorIndex == 0 then 
        colorList[define.Ranse.PartType.hair] = Color.New(1,1,1,1)
        colorList[define.Ranse.PartType.clothes] = Color.New(1,1,1,1)
        colorList[ define.Ranse.PartType.other] = Color.New(1,1,1,1)
    else
        local config = data.ransedata.SUMMON[shape]
        if config then 
            if next(config.colorlist_ex) then 
                local list =  config.colorlist_ex[colorIndex]
                colorList[define.Ranse.PartType.hair] = self:ParseStrToColor(list.value1)
                colorList[define.Ranse.PartType.clothes] = self:ParseStrToColor(list.value2)
                colorList[ define.Ranse.PartType.other] = self:ParseStrToColor(list.value3)
            end 
        end 
    end

    return colorList

end

--获取展示的颜色信息
function CRanseCtrl.GetShowColor(self, id)

    local colorInfo = {}

    if id == 0 then 
        colorInfo.name = "默认"
        colorInfo.id = 0 
        colorInfo.color = Color.New(1,1,1,1)
        colorInfo.color.a = 1
    else
        local config = data.ransedata.COLOR[id]
        if config then 
            colorInfo.name = config.name
            colorInfo.id = config.id 
            colorInfo.color = self:ParseStrToColor(config.color)
            colorInfo.color.a = 1
        end 
    end 

    return colorInfo

end

--解析颜色数据
function CRanseCtrl.ParseStrToColor(self, colorStr)
    
    if colorStr == nil then 
        return
    end 
    local colorTable = string.split(colorStr,"-")
    local color = Color.New(tonumber(colorTable[1]), tonumber(colorTable[2]), tonumber(colorTable[3]), tonumber(colorTable[4]) )
    return color

end


return CRanseCtrl
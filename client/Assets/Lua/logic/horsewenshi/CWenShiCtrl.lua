local CWenShiCtrl = class("CWenShiCtrl", CCtrlBase)

function CWenShiCtrl.ctor(self)
	CCtrlBase.ctor(self)

end

function CWenShiCtrl.GetCurRideId(self)
    
    return self.m_RideId 

end

function CWenShiCtrl.SetCurRideId(self, id)
    
    self.m_RideId = id 

end


--获取指定等级的纹饰道具 {id, lv, icon, colorType, name, attr, last, score, sid}
function CWenShiCtrl.GetBagWenShiDataByLv(self, lv)
    
    local wenshiInfoList = {}
    local wenshiDataList = g_ItemCtrl:GetBagWenShiData()
    for _, wenshiData in pairs(wenshiDataList) do
        local grade = wenshiData.m_SData.equip_info.grow_level
        if lv == grade then
            local info = {}
            local sid = wenshiData.m_SID 
            local id = wenshiData.m_ID
            info.id = id
            info.lv = grade
            local wenshiConfigItem = data.itemwenshidata.WENSHI[sid] 
            info.icon = wenshiConfigItem.icon
            info.colorType =  wenshiConfigItem.wenshi_type
            info.name = wenshiConfigItem.name
            info.attr = wenshiData.m_SData.equip_info.attach_attr
            info.last = wenshiData.m_SData.equip_info.last
            info.score = wenshiData.m_SData.equip_info.score
            info.quality = wenshiData.m_SData.itemlevel
            info.bandding = wenshiData.m_SData.key
            info.sid = sid
            info.des = wenshiConfigItem.description
            wenshiInfoList[id] = info
        end 
    end

    return wenshiInfoList

end

--获取小于指定等级的纹饰道具 id = {id, lv, icon, colorType, name, attr, last, score}
function CWenShiCtrl.GetBagWenShiDataLessthanLv(self, lv)
    
    local wenshiInfoList = {}
    local wenshiDataList = g_ItemCtrl:GetBagWenShiData()

    for _, wenshiData in pairs(wenshiDataList) do
        local grade = wenshiData.m_SData.equip_info.grow_level
        if lv > grade then
            local info = {}
            local sid = wenshiData.m_SID 
            local id = wenshiData.m_ID
            info.id = id
            info.lv = grade
            local wenshiConfigItem = data.itemwenshidata.WENSHI[sid] 
            info.icon = wenshiConfigItem.icon
            info.colorType =  wenshiConfigItem.wenshi_type
            info.name = wenshiConfigItem.name
            info.attr = wenshiData.m_SData.equip_info.attach_attr
            info.last = wenshiData.m_SData.equip_info.last
            info.score = wenshiData.m_SData.equip_info.score
            info.quality = wenshiData.m_SData.itemlevel
            info.bandding = wenshiData.m_SData.key
            info.sid = sid
            info.des = wenshiConfigItem.description
            wenshiInfoList[id] = info
        end 
    end

    return wenshiInfoList

end

function CWenShiCtrl.GetBagWenShiDataById(self, id)
    
    local wenshiDataList = g_ItemCtrl:GetBagWenShiData()
    for _, wenshiData in pairs(wenshiDataList) do
        if id == wenshiData.m_ID then 
            local info = {}
            local sid = wenshiData.m_SID 
            local id = wenshiData.m_ID
            local grade = wenshiData.m_SData.equip_info.grow_level
            info.id = id
            info.lv = grade
            local wenshiConfigItem = data.itemwenshidata.WENSHI[sid] 
            info.icon = wenshiConfigItem.icon
            info.colorType =  wenshiConfigItem.wenshi_type
            info.name = wenshiConfigItem.name
            info.attr = wenshiData.m_SData.equip_info.attach_attr
            info.last = wenshiData.m_SData.equip_info.last
            info.score = wenshiData.m_SData.equip_info.score
            info.quality = wenshiData.m_SData.itemlevel
            info.bandding = wenshiData.m_SData.key
            info.des = wenshiConfigItem.description
            info.sid = sid
            return info
        end 
    end

end


--获取背包中整理后的纹饰道具
function CWenShiCtrl.GetBagWenShiData(self)
    
    local wenshiList = {}
    local wenshiDataList = g_ItemCtrl:GetBagWenShiData()

   --获取纹饰分类
    local wenshiList = {}
    local wenshiConfig = data.itemwenshidata.WENSHI
    for k, v in pairs(wenshiConfig) do 
        local wenshiTypeTable = wenshiList[v.wenshi_type]
        if not wenshiTypeTable then 
            wenshiTypeTable = {}
            wenshiTypeTable.color = v.wenshi_type
            wenshiTypeTable.icon = v.icon
            wenshiTypeTable.name = v.name
            wenshiTypeTable.sub = {}
            wenshiList[v.wenshi_type] = wenshiTypeTable
        end
    end 

   --获取背包纹饰，添加到分类中
   for _, wenshiData in pairs(wenshiDataList) do
        local sid = wenshiData.m_SID 
        local id = wenshiData.m_ID
        local wenshiConfigItem = data.itemwenshidata.WENSHI[sid] 
        local wenshiType = wenshiConfigItem.wenshi_type
        local wenshiTypeTable = wenshiList[wenshiType]
        if wenshiTypeTable then 
            local sub = wenshiTypeTable.sub
            local subItem = {}
            subItem.id = id
            subItem.name = wenshiConfigItem.name
            subItem.grade = wenshiData.m_SData.equip_info.grow_level
            if wenshiConfigItem then 
                subItem.icon = wenshiConfigItem.icon
            end 
            table.insert(sub, subItem)
        end
   end 

   return wenshiList

end

--获取已装配的纹饰
--pos = { id, name, lv, icon, pos, attr, last, score, bindRide, quality, bandding, des}
function CWenShiCtrl.GetHorseWenShi(self, id)

    local wenshiList = {}
    local rideInfo = g_HorseCtrl.m_HorseDic[id]
    if rideInfo then 
        local wenshiConfig = data.itemwenshidata.WENSHI
        local wenshiData = rideInfo.wenshi
        for k, v in ipairs(wenshiData) do
            local info = {}
            info.pos = v.pos
            info.id = v.id
            info.name = v.name
            local wenshi = wenshiConfig[v.sid]  
            if wenshi then 
                info.icon = wenshi.icon
                info.des = wenshi.description
            end
            info.lv = v.equip_info.grow_level
            info.attr = v.equip_info.attach_attr
            info.last = v.equip_info.last
            info.sid = v.sid
            info.score = v.equip_info.score
            info.bindRide = id
            info.quality = v.itemlevel
            info.bandding = v.key
            wenshiList[v.pos] = info
        end 
    end 

    return wenshiList

end

function CWenShiCtrl.GetHorseWenShiCount(self, id)

    local rideInfo = g_HorseCtrl.m_HorseDic[id]
    local count = 0
    if rideInfo then 
        local wenshiData = rideInfo.wenshi      
        for k, v in pairs(wenshiData) do 
            count = count + 1
        end
    end
    return count
    
end

--获取纹饰洗练消耗
function CWenShiCtrl.GetWenShiWashConsume(self, wenshiType, lv)
   
    local config = data.itemwenshidata.COLOR_CONFIG
    local wenshiConfig = config[wenshiType]
    if wenshiConfig then
        local consume = {}
        local costList = wenshiConfig.wash_cost
        for k, v in ipairs(costList) do 
            if v.level == lv then 
                local data = DataTools.GetItemData(v.sid)
                if data then 
                    consume.cnt = v.cnt
                    consume.icon = data.icon
                    consume.name = data.name
                    consume.id = v.sid
                end 
            end 
        end
        return consume 
    end 

end

--纹饰技能
function CWenShiCtrl.GetWenShiSkill(self, rideId) 
 
    local rideInfo = g_HorseCtrl.m_HorseDic[rideId]
    if rideInfo then  
        local wenshiSkillId = rideInfo.skill
        local valid = rideInfo.skill_effect
        local wenshiSkillInfo = data.summondata.SKILL[wenshiSkillId]
        if wenshiSkillInfo then
            local wenshiSkill = {}
            local name = wenshiSkillInfo.name
            local icon = wenshiSkillInfo.iconlv[1].icon
            wenshiSkill.name = name
            wenshiSkill.icon = icon
            wenshiSkill.id = wenshiSkillId
            wenshiSkill.type = "纹饰技能"
            wenshiSkill.des = wenshiSkillInfo.des
            wenshiSkill.valid = valid == 1
            wenshiSkill.quality = wenshiSkillInfo.quality
            return wenshiSkill
        end    
    end 

end

--纹饰所有能够获得的属性{k, value}
function CWenShiCtrl.GetWenShiTotalAttr(self, id)
    
    local attrList = {}
    local wenshiType = self:GetWenShiType(id)
    local info = data.itemwenshidata.COLOR_CONFIG[wenshiType]
    local attrConfig =  data.itemwenshidata.ATTR_LIST
    local attrNameConfig = data.attrnamedata.DATA
    if info then 
        for k, v in pairs(info.attr_weight) do 
            local attrId = v.id
            if attrConfig[attrId] then 
                local key = attrConfig[attrId].attr_key
                local value =  attrConfig[attrId].attr_val
                local nameInfo = attrNameConfig[key]
                if g_AttrCtrl:IsRatioAttr(key) then 
                    value = value .. "%"
                end 
                table.insert(attrList, {name = nameInfo.name, value = value})
            end 
        end 
    end 

    return attrList

end

--获取纹饰类型
function CWenShiCtrl.GetWenShiType(self, id)
    
    local wenshiData = data.itemwenshidata.WENSHI[id]
    if wenshiData then 
        return wenshiData.wenshi_type
    end 

end

function CWenShiCtrl.GetWenShiIdByType(self, type)
    
    local wenshiConfig = data.itemwenshidata.WENSHI
    for k, v in pairs(wenshiConfig) do 
        if v.wenshi_type == type then 
            return v.id
        end 
    end 

end

--获取纹饰技能id
function CWenShiCtrl.GetWenShiSkillId(self, rideId)
    
    local rideInfo = g_HorseCtrl.m_HorseDic[rideId]
    if rideInfo then  
        local wenshiSkillId = rideInfo.skill
        local valid = rideInfo.skill_effect == 1
        return wenshiSkillId, valid
    end 

end

--获取纹饰icon
function CWenShiCtrl.GetWenShiIcon(self, wenshiType)
    
    local wenshiConfig = data.itemwenshidata.WENSHI
    for k, v in pairs(wenshiConfig) do 
        if v.wenshi_type == wenshiType then 
            return v.icon
        end 
    end

end

--获取纹饰技能的条件{typeid}
function CWenShiCtrl.GetWenShiSkillCondition(self, skillId)
  
    local wenshiSkillConfig = data.itemwenshidata.WENSHI_SKILL
    local typeIdList = {}
    for k, v in pairs(wenshiSkillConfig) do 
        if v.skill == skillId then 
            local condition = v.condition
            for j, i in pairs(condition) do
                if i.cnt == 2 then 
                    table.insert(typeIdList, i.sid)
                    table.insert(typeIdList, i.sid)
                elseif i.cnt == 1 then 
                    table.insert(typeIdList, i.sid)
                end 
            end
            return typeIdList
        end
    end 

    return typeIdList

end

--获取纹饰合成材料id
function CWenShiCtrl.GetWenShiComposItemId(self, id)
    
    local wenshiType = self:GetWenShiType(id)
    local config = data.itemwenshidata.COLOR_CONFIG[wenshiType]
    if config then 
        return config.decompose_got[1].sid
    end 

end

--纹饰精华合成
function CWenShiCtrl.C2GSWenShiMake(self, id)
    
    netitem.C2GSWenShiMake(id)

end

function CWenShiCtrl.C2GSWieldWenShi(self, rideId, itemId, pos)
    
    netride.C2GSWieldWenShi(rideId, itemId, pos)

end

function CWenShiCtrl.C2GSUnWieldWenShi(self, rideId, pos)
    
    netride.C2GSUnWieldWenShi(rideId, pos)

end

--纹饰合成
function CWenShiCtrl.C2GSWenShiCombine(self, mainId, subId)
    
    netitem.C2GSWenShiCombine(mainId, subId)

end

--纹饰洗练
function CWenShiCtrl.C2GSWenShiWash(self, itemId, lockIndexs, fast)
    
    netitem.C2GSWenShiWash(itemId, lockIndexs, fast)

end

function CWenShiCtrl.GS2CWenShiCombineResult(self, flag)
    
    self:OnEvent(define.WenShi.Event.Fusion, flag)

end

--统计纹饰合并属性
function CWenShiCtrl.GetWenShiMeshAttr(self, wenshiList)
    
    local meshAttr = {}
    for k, attrList in ipairs(wenshiList) do 
        for j, i in ipairs(attrList) do 
            local value = meshAttr[i.key]
            if not value then 
                meshAttr[i.key] = i.value / 100
            else
                meshAttr[i.key] = meshAttr[i.key] + i.value / 100
            end  
           
        end 
    end 

    return meshAttr

end

--是否百分比
function CWenShiCtrl.IsRatioAttr(self, k)
        
    if string.find(k, "ratio") then 
        return true
    elseif string.find(k, "power") then 
        return true
    else
        return false
    end 

end

function CWenShiCtrl.CheckOpenWenShiWashView(self)
    
    if g_OpenSysCtrl.m_SysOpenList[define.System.RideTongYu] then 

        CHorseWenShiMainView:ShowView(function ( oView )
            oView:OpenWashPart()
        end)

    else

        local openInfo = data.opendata.OPEN.RIDE_TY
        if openInfo then 
            local name = openInfo.name
            local lv = openInfo.p_level
            g_NotifyCtrl:FloatMsg(lv .. "级" .. name .. "系统开启后才能使用")
        end 

    end 

end

return CWenShiCtrl
module(..., package.seeall)

-- 旧的评分规则
function CalculateScore(summonInfo)
    local aptitudeScore = 0
    local maxAptitudeScore = 0
    for k,v in pairs(summonInfo.aptitude) do
        aptitudeScore = aptitudeScore + v  
        maxAptitudeScore = math.floor(v*125/100) + maxAptitudeScore
    end
    local skillScore = 0 --技能评分
    for k,v in pairs(summonInfo.skill1) do
        skillScore = data.summondata.SKILL[v].score +1*30 + skillScore
    end
    for k,v in pairs(summonInfo.skill2) do
        skillScore = data.summondata.SKILL[v].score +1*30 + skillScore
    end
    for k,v in pairs(summonInfo.talent) do
        skillScore = data.summondata.SKILL[v].score + skillScore
    end
    local grownScore = 0
    local maxGrownScore = 0
    if summonInfo.type == 1 then
        grownScore = summonInfo.grow * 95/100
        maxGrownScore = summonInfo.grow * 100/100
    else
        grownScore = summonInfo.grow * 95/100
        maxGrownScore = summonInfo.grow * 125/100
    end
    local sumScore = math.floor(aptitudeScore + grownScore + skillScore) 
    local sumMaxScore = math.floor(maxAptitudeScore + maxGrownScore + skillScore)
    return sumScore+3700,sumMaxScore+3700
end

function GetBookSummonList()
    local spcList, norList = {}, {}
    local iGrade = g_AttrCtrl.grade
    for k,v in pairs(data.summondata.INFO) do
        if v.carry <= iGrade + 10 then -- and v.carry < 90 then
            if IsUnnormalSummon(v.type) then
                local info = table.copy(v)
                table.insert(spcList, info)
            else
                local info = table.copy(v)
                table.insert(norList, info)
            end
        end
    end
    local function Rank(v1, v2)
        -- if v1.carry == v2.carry then
        --     local val1 = CalculateScore(v1)
        --     local val2 = CalculateScore(v2)
        --     return  val1 < val2
        -- else
        --     return v1.carry < v2.carry
        -- end 
        local iOrder1, iOrder2 = v1.show_order, v2.show_order
        if iOrder1 and iOrder2 and iOrder1 ~= iOrder2  then
            return iOrder1 < iOrder2
        else
            return v1.id < v2.id
        end
    end
    table.sort(spcList, Rank)
    table.sort(norList, Rank)
    local results = {
        spc = spcList,
        nor = norList,
    }
    return results
end

-- dSummon: 协议数据
function GetSkillInfo(dSummon)
    local skillList = {}
    for _, v in ipairs(dSummon.talent) do
        local skill = table.copy(v)
        skill.talent = true
        table.insert(skillList, skill)
    end
    for _, v in ipairs(dSummon.skill) do
        local skill = table.copy(v)
        -- local bSure = IsSureSkill(dSummon.typeid, v.sk)
        -- skill.sure = bSure
        table.insert(skillList, skill)
    end
    local equipSks = GetEquipSkills(dSummon.equipinfo)
    if equipSks then
        for _, skInfo in ipairs(equipSks) do
            local skill = {}
            skill.sk = skInfo.sk
            skill.equip = true
            table.insert(skillList, skill)
        end
    end
    local rideSk = GetRideSkill(dSummon)
    if rideSk then
        table.insert(skillList, rideSk)
    end
    for i, v in ipairs(skillList) do
        v.summonId = dSummon.id --tip用到
    end
    return skillList
end

-- dSummon: 导表数据
function GetConfigSkillInfo(dSummon)
    local skillList = {}
    local configs = {dSummon.talent, dSummon.skill1, dSummon.skill2}
    for i, v in ipairs(configs) do
        for _, sk in ipairs(v) do
            local skill = {}
            skill.sk = sk
            if i == 1 then
                skill.talent = true
            elseif i == 2 then
                skill.sure = true
            end
            table.insert(skillList, skill)
        end
    end
    return skillList
end

function GetMaxSkillCnt(dSummon)
    local iMax = 12
    -- 默认值+装备技能数量
    -- local equipSks = GetEquipSkills(dSummon.equipinfo)
    -- if equipSks then
    --     iMax = iMax + #equipSks
    -- end
    return iMax
end

function GetEquipSkills(itemDatas)
    if not itemDatas then
        return
    end
    local skillList = {}
    for i, info in ipairs(itemDatas) do
        local dEquip = info.equip_info
        if dEquip then
            local skills = dEquip.skills
            if skills then
                for _, sk in ipairs(skills) do
                    table.insert(skillList, sk)
                end
            end
        end
    end
    return skillList
end

function GetRideSkill(dSummon)
    local iRide = dSummon.bind_ride
    if iRide and iRide > 0 then
        local dSk = g_WenShiCtrl:GetWenShiSkill(iRide)
        if dSk and dSk.valid then
            return {
                sk = dSk.id,
                wenshi = true,
            }
        end
    end
end

-- 宠物装备中的物品信息
function GetEquipedData(dSummon)
    local itemList = dSummon.equipinfo
    if not itemList then return end
    local dEquiped = {}
    for i, dItem in ipairs(itemList) do
        local id = dItem.sid
        local dConfig = GetSummonEquip(id)
        if dConfig then
            local iPos = dConfig.equippos or 0
            local oItem = CItem.New(dItem)
            dEquiped[iPos] = oItem
        end
    end
    return dEquiped
end

function GetComposeScore(dSummon1, dSummon2)
    local iScore = 0
    local calcEqScore = function(itemList)
        if not itemList then return end
        for i, dItem in ipairs(itemList) do
            local dConfig = GetSummonEquip(dItem.sid)
            if dConfig then
                iScore = iScore + dConfig.point
            end
        end
    end
    local skRecord = {}
    local calcSkScore = function(skList)
        for i, dSk in ipairs(skList) do
            -- 不计入自带技能
            if 1~=dSk.innate and not skRecord[dSk.sk] then
                skRecord[dSk.sk] = true
                local dConfig = GetSummonSkillInfo(dSk.sk)
                if dConfig then
                    iScore = iScore + dConfig.point or 0
                end
            end
        end
    end
    calcEqScore(dSummon1.equipinfo)
    calcEqScore(dSummon2.equipinfo)
    calcSkScore(dSummon1.skill)
    calcSkScore(dSummon2.skill)
    return iScore
end

function GetTopEquipId(iPos)
    if not iPos then return end
    local dEquips = GetSummonEquip()
    local dTop
    for k, v in pairs(dEquips) do
        if v.equippos == iPos then
            if not dTop then
                dTop = v
            elseif v.quality > dTop.quality then
                dTop = v
            end
        end
    end
    if dTop then
        return dTop.id
    end
end

function IsSureSkill(sumID, skillID)
    local sum = GetSummonInfo(sumID)
    if sum and table.index(sum.skill1, skillID) then
        return true
    else
        return false
    end
end

function GetSummonBindSkill(dSummon)
    local skills = dSummon.skill
    for i, v in ipairs(skills) do
        if v.bind and v.bind == 1 then
            return v.sk
        end
    end
end

-- 珍品判断
function IsRare(summonInfo)
    local iRare = summonInfo.zhenpin
    return iRare and iRare > 0
end
--     local iType = summonInfo.type
--     -- 野生
--     if iType < 2 then
--         return false
--     -- 神兽 or 珍兽
--     elseif IsExpensiveSumm(iType) then
--         return true
--     end
--     local config = data.globaldata.SUMMONCK[1]
--     -- 技能数量
--     local iSkillCnt = #summonInfo.talent + #summonInfo.skill
--     if iSkillCnt >= config.zp_skill_cnt then
--         return true
--     end
--     -- 成长
--     local dConfig = GetSummonInfo(summonInfo.typeid)
--     local iBaseGrow = dConfig.grow
--     local iGrow = summonInfo.grow*100 / iBaseGrow
--     if iGrow < config.zp_grow then -- 10.1
--         return false
--     end
--     -- 天资比率
--     local iAptiP = 0
--     for i, v in ipairs(config.zp_aptitude_rate) do
--         if not iAptiP then
--             iAptiP = v.ratio
--         elseif dConfig.carry >= v.grade then
--             iAptiP = v.ratio
--         else
--             break
--         end
--     end
--     local iCurApti, iMaxApti = 0, 0
--     for k, v in pairs(summonInfo.curaptitude) do
--         iCurApti = iCurApti + v
--     end
--     for k, v in pairs(dConfig.aptitude) do
--         iMaxApti = iMaxApti + v
--     end
--     if iType >= 3 then
--         iMaxApti = iMaxApti * 1.3
--     else
--         iMaxApti = iMaxApti * 1.25
--     end
--     if iCurApti/iMaxApti >= iAptiP/100 then
--         return true
--     end
--     return false
-- end

-- 属性计算
function CalcAttr(dCalc, sAttr, dSummon)
    local dFormula = data.summondata.calformula[sAttr]
    if not dFormula then
        return
    end
    local sFormula = dFormula.formula
    local iResult = string.eval(sFormula, dCalc)
    iResult = CalcSkEqEffect(iResult, sAttr, dSummon)
    iResult = math.floor(iResult)
    return iResult
end

-- 计算装备/技能的属性加成
function CalcSkEqEffect(iVal, sAttr, dSummon)
    --改成用服务器数据
    local dExtra = dSummon[sAttr.."_unit"]
    if not dExtra then
        return iVal
    end
    iVal = (iVal + dExtra.extra)*(1+dExtra.ratio/100)
    return iVal
end
    -- local iRatios = {}
    -- -- 技能
    -- local calcSk = function(sks)
    --     if not sks then return end
    --     for i, v in ipairs(sks) do
    --         local dConfig = GetSummonSkillInfo(v.sk)
    --         if not dConfig then
    --             goto continue
    --         end
    --         dCalc.level = dConfig.level
    --         for _, ef in ipairs(dConfig.skill_effect) do
    --             local sps = string.split(ef, "=")
    --             if sps[1] and sps[1] == sAttr then
    --                 iVal = iVal + string.eval(sps[2], dCalc)
    --             end
    --         end
    --         for _, efr in ipairs(dConfig.skill_effect_ratio) do
    --             local sps = string.split(efr, "=")
    --             if sps[1] and sps[1] == sAttr then
    --                 table.insert(iRatios, string.eval(sps[2], dCalc))
    --             end
    --         end
    --         ::continue::
    --     end
    -- end
    -- calcSk(dSummon.skill)
    -- calcSk(dSummon.talent)
    -- -- 装备
    -- for i, v in ipairs(dSummon.equipinfo) do
    --     if not v.equip_info then
    --         goto continue
    --     end
    --     local dEq = v.equip_info
    --     for _, attr in ipairs(dEq.attach_attr or {}) do
    --         if attr.key == sAttr then
    --             iVal = iVal + attr.value
    --         end
    --     end
    --     calcSk(dEq.skills)
    --     ::continue::
    -- end
    -- for _, v in ipairs(iRatios) do
    --     iVal = iVal*(1 + v/100)
    -- end
--     return iVal
-- end

function GetSummonCalcInfo(dSummon)
    local dCalc = {}
    for k, v in pairs(dSummon) do
        if type(v) ~= "table" then
            dCalc[k] = v
        elseif k == "curaptitude" or k == "attribute" then
            for i, attr in pairs(v) do
                dCalc[i] = attr
            end
        end
    end
    dCalc.speed = dSummon.curaptitude.speed
    dCalc.grade = dCalc.grade or 0
    return dCalc
end

function CalcSummonAptitudeAdd(dSummon, sAttr)
    local dConfig = GetSummonInfo(dSummon.typeid)
    local iBaseAttr = dConfig.aptitude[sAttr]
    if not sAttr then
        return
    end
    local iVal = IsUnnormalSummon(dSummon.typeid) and 23 or 27
    local iMaxApti = dSummon.maxaptitude[sAttr]
    local iCurApti = dSummon.curaptitude[sAttr]
    local iScheme = math.floor((iVal-(iMaxApti-iCurApti)*100/iBaseAttr)/iVal*100)
    iScheme = math.max(0, iScheme)
    return GetAptitudePellect(iScheme)
end


function GetSummonGrowRange()
    local maxtb = {}
    local mintb = {}
    local num = #data.summondata.GROW
    for i,v in ipairs(data.summondata.GROW) do 
        table.insert(maxtb,v.max)
        table.insert(mintb,v.min)
    end
    table.sort(maxtb)
    table.sort(mintb)
    local maxGrow = maxtb[num]
    local minGrow = mintb[1]
    return minGrow,maxGrow
end
--------------------- Config --------------------
function GetSummonInfo(sumId)
    if data.summondata.INFO[sumId] then
        return data.summondata.INFO[sumId]
    end
end

function GetText(textId)
    local dText = data.summondata.TEXT[textId]
    if dText then
        return dText.content
    end
end

function GetUnlockCompoundGrade()
    return data.opendata.OPEN.SUMMON_HC.p_level
end

function GetWashCost(iGrade)
    return data.summondata.WASHDATA[iGrade]
end

function GetStudyItem(id)
    local dItems = data.itemsummskilldata.SUMMSKILL
    if id then
        return dItems[id]
    else
        return dItems
    end
end

function GetSummonEquip(id)
    local dEquips = data.itemsummonequipdata.SUMMONEQUIP
    if id then
        return dEquips[id]
    else
        return dEquips
    end
end

-- 商会技能书配置
function GetStudyGuildItems(bAdv)
    local idx = bAdv and 8 or 9
    local dCatInfo = data.guilddata.SUBCATALOG[idx]
    local iSubCat = dCatInfo.subcat_id
    local iCat = dCatInfo.cat_id
    local itemList = {}
    local dGuilds = data.guilddata.ITEMINFO
    for k, v in pairs(dGuilds) do
        if v.cat_id == iCat and v.sub_id == iSubCat then
            local dItem = DataTools.GetItemData(v.item_sid, "SUMMSKILL")
            if dItem.skid and GetSummonSkillInfo(dItem.skid) then
                table.insert(itemList, dItem)
            end
        end
    end
    return itemList
end

function GetSummonSkillInfo(skId)
    return data.summondata.SKILL[skId]
end

function GetUpgradeData(iGrade)
    local dUpgrade = data.upgradedata.DATA
    if iGrade then
        return dUpgrade[iGrade]
    else
        return dUpgrade
    end
end

function GetScoreInfoByRank(rank)
    local dScore = data.summondata.SCORE
    for k,v in pairs(dScore) do
        if v.rank == rank then
            return v
        end
    end
end

function GetTypeInfo(iType)
    return data.summondata.SUMMTYPE[iType]
end

function GetRaceInfo(iRace)
    return data.summondata.RACE[iRace]
end

function IsGodSummon(iType)
    return iType == 5 or iType == 7
end

function IsExpensiveSumm(iType)
    return iType >= 5
end

function IsUnnormalSummon(iType)
    return iType >= 3
end

function GetAptitudePellect(iPerc)
    for i, v in ipairs(data.summondata.APTITUFEPELLET) do
        if iPerc >= v.schedule[1] and iPerc <= v.schedule[2] then
            return v.add
        end
    end
end

function GetMaxFightCnt(iGrade)
    local config = data.globaldata.SUMMONCK[1].fight_count
    local iCnt = 0
    for i, v in ipairs(config) do
        if v.grade < iGrade then
            iCnt = v.num
        else
            break
        end
    end
    return iCnt
end

function GetSpcExchanges(iSummon)
    local exchanges = {}
    for i, v in pairs(data.summondata.SPCEXCHANGE) do
        if v.sid == iSummon then
            table.insert(exchanges, v)
        end
    end
    if #exchanges > 1 then
        table.sort(exchanges, function(a, b)
            return a.sort > b.sort
        end)
    end
    return exchanges
end

function IsSummStudyAllInnateSk(dSummon)
    local dConfig = GetSummonInfo(dSummon.typeid)
    if dConfig then
        local skills = table.copy(dConfig.skill2)
        for i, v in ipairs(dConfig.skill1) do
            table.insert(skills, v)
        end
        for i, skId in ipairs(skills) do
            local bCont = false
            for _, skInfo in ipairs(dSummon.skill) do
                if skInfo.sk == skId then
                    bCont = true
                    break
                end
            end
            if not bCont then
                return false
            end
        end
        return true
    end
end

function GetCombindAptiMax()
    local iMax = 0
    for i, v in ipairs(data.summondata.APTITCOMBINE) do
        if v.max > iMax then
            iMax = v.max
        end
    end
    return iMax/100
end

function GetCombindAptiMin()
    local iMin
    for i, v in ipairs(data.summondata.APTITCOMBINE) do
        if not iMin or iMin > v.min then
            iMin = v.min
        end
    end
    return iMin/100
end

function GetAdvanceLvData(iLv, iType)
    local dConfig
    if iType == 7 then
        dConfig = data.summondata.XY_ADVANCE
    elseif iType == 5 then
        dConfig = data.summondata.ADVANCE
    else
        dConfig = data.summondata.XY_ZS_ADVANCE
    end
    return dConfig[iLv]
end

function GetComposeXiyou(iSumm1, iSumm2)
    for i, v in ipairs(data.summondata.XIYOU) do
       if (v.sid1 == iSumm1 and v.sid2 == iSumm2) or (v.sid1 == iSumm2 and v.sid2 == iSumm1) then
            return v.sid3
       end
    end
    return nil
end

function GetCurStoreGrade()
    local iGrade = g_AttrCtrl.grade
    local iCur = 0
    for i, v in pairs(data.summondata.USEGRADE) do
        if iGrade >= i then
            if iCur < i then
                iCur = i
            end
        end
    end
    return iCur
end
---------------------------data----------------------------
function GetBagStudyItems()
    local dItems = GetStudyItem()
    local bagItems = {}
    for k, dItem in pairs(dItems) do
        for i, v in ipairs(g_ItemCtrl:GetBagItemListBySid(k)) do
            if k == 30000 or (dItem.skid and GetSummonSkillInfo(dItem.skid)) then
                local d = {}
                d.id = k
                d.objId = v:GetSValueByKey("id")
                d.skid = dItem.skid
                d.amount = v:GetSValueByKey("amount")
                table.insert(bagItems, d)
            end
        end
    end
    return bagItems
end

function GetBagSummonEquips(iPos, iGrade)
    local dEquips = GetSummonEquip()
    local bagEquips = {}
    local bMatch = false
    for k, v in pairs(dEquips) do
        bMatch = true
        if iPos and iPos ~= v.equippos then
            bMatch = false
        end
        if iGrade and v.minGrade > iGrade then
            bMatch = false
        end
        if bMatch then
            local iSkId = v.skid
            for i, v in ipairs(g_ItemCtrl:GetBagItemListBySid(k)) do
                table.insert(bagEquips, v)
            end
        end
    end
    table.sort(bagEquips, function(a, b) return a:GetSValueByKey("pos") < b:GetSValueByKey("pos") end)
    return bagEquips
end
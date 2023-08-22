local CHorseCtrl = class("CHorseCtrl", CCtrlBase)

function CHorseCtrl.ctor(self)
	CCtrlBase.ctor(self)
    self.m_HorseDic = {}
    self.m_HorseIdList = {}
    self.m_CurSelHorseId = nil
    self.m_SkillDic = {}
    self.m_CurUseHorseId = nil
    self:InitData()
    self.m_isUseRide = false
end

function CHorseCtrl.InitData(self)
    self.grade = 0
    self.exp = 0
    self.point = 0
    self.use_ride = 0
    self.score = 0
    self.choose_skills = {}
    self.skills = {}
    self.ride_infos = {}
    self.attrs = {}
end

function CHorseCtrl.Clear(self)
    self.m_HorseDic = {}
    self.m_HorseIdList = {}
    self.m_CurSelHorseId = nil
    self.m_SkillDic = {}
    self.m_CurUseHorseId = nil
    self:InitData()
    self.m_isUseRide = false
end

function CHorseCtrl.GS2CAddRide(self, info)

    self.m_HorseDic[info.ride_id] = info
    self.m_HorseIdList = {}
    for k,v in pairs(self.m_HorseDic) do
        table.insert(self.m_HorseIdList, k)
    end   
    self:OnEvent(define.Horse.Event.AddHorse, info)
    
    g_GuideCtrl:OnTriggerAll()
end

function CHorseCtrl.GS2CPlayerRideInfo(self, info)

    local dChange = {}
    for k , v in pairs(info) do
		if self[k] ~= v then
			self[k] = v
            dChange[k] = v
		end
	end
    
    if dChange["ride_infos"] then
        self.m_HorseDic = {}
        self.m_HorseIdList = {}
        for k,v in pairs(dChange["ride_infos"]) do
            self.m_HorseDic[v.ride_id] = v
            table.insert(self.m_HorseIdList, v.ride_id) 
        end
        self:OnEvent(define.Horse.Event.UpdateRideInfo, dChange)
    end
    
    if dChange["skills"] then
        self.m_SkillDic = {}
        for k,v in pairs(dChange["skills"]) do
            self.m_SkillDic[v.sk] = v
        end
        self:OnEvent(define.Horse.Event.UpdateRideSkill, dChange)
    end

    if dChange["use_ride"] then
        self.m_CurUseHorseId = dChange["use_ride"]
        self:OnEvent(define.Horse.Event.UseRide, dChange)
    end 

    if dChange["choose_skills"] then
        self:OnEvent(define.Horse.Event.ChooseSkills, dChange)
    end 

    if dChange["grade"] then 
        self:OnEvent(define.Horse.Event.Upgrade, dChange)
    end 

    if info.use_ride and info.use_ride ~= 0 then 
        self.m_isUseRide = true
        --重置跳舞检测时间
        g_DancingCtrl:ResetDancingAnimTime()
    else
        self.m_isUseRide = false
    end 

    if next(dChange) then 
        self:OnEvent(define.Horse.Event.HorseAttrChange, dChange)
    end 

end

function CHorseCtrl.GS2CResetSKillInfo(self, data)
    
    self:OnEvent(define.Horse.Event.ResetSkill, data)

end

function CHorseCtrl.GS2CShowRandomSkill(self, id)
    self.learn_sk = id
    self:OnEvent(define.Horse.Event.LearnSk) 
end

function CHorseCtrl.GS2CUpdateRide(self, info)
    self.m_HorseDic[info.ride_id] = info
    self:OnEvent(define.Horse.Event.UpdateRideInfo, info)      
end

function CHorseCtrl.C2GSUpGradeRide(self)
    netride.C2GSUpGradeRide()
end

function CHorseCtrl.C2GSRandomRideSkill(self)
    netride.C2GSRandomRideSkill()
end

function CHorseCtrl.C2GSLearnRideSkill(self, id)
    netride.C2GSLearnRideSkill(id)
end

function CHorseCtrl.C2GSActivateRide(self, id)
    netride.C2GSActivateRide(id)
end

function CHorseCtrl.C2GSUseRide(self, id, flag)
    if flag == 0 then
        local oCam = g_CameraCtrl:GetMapCamera()
        local oHero = g_MapCtrl:GetHero()
        if oHero and (not oCam.curMap:IsWalkable(oHero:GetPos().x, oHero:GetPos().y) or g_MapCtrl:CheckIsInWaterLine(oHero:GetPos()) ) then
            g_NotifyCtrl:FloatMsg("请在可行走区域下坐骑")
            return
        end
    end
    netride.C2GSUseRide(id, flag)
end

function CHorseCtrl.C2GSResetRideSkill(self)
    netride.C2GSResetRideSkill()
end

function CHorseCtrl.C2GSResetSkillInfo(self)
    netride.C2GSResetSkillInfo()
end

function CHorseCtrl.C2GSForgetRideSkill(self, skill_id, flag)
    
    netride.C2GSForgetRideSkill(skill_id, flag)

end

function CHorseCtrl.C2GSResetRideSkill(self)
    
    netride.C2GSResetRideSkill()

end

function CHorseCtrl.C2GSGetRideInfo(self)
    netride.C2GSGetRideInfo()
end

function CHorseCtrl.C2GSBuyRideUseTime(self, id)
     netride.C2GSBuyRideUseTime(id)
end

function CHorseCtrl.C2GSResetRideSkill(self, id, flag)
     netride.C2GSResetRideSkill(id, flag)
end

function CHorseCtrl.C2GSShowRandomSkill(self)
     netride.C2GSShowRandomSkill()
end

function CHorseCtrl.C2GSBreakRideGrade(self)
    
    netride.C2GSBreakRideGrade()

end

function CHorseCtrl.GetHorseSortId(self)
    return self.m_HorseIdList
end

function CHorseCtrl.GetHorseSortIdByIdx(self, idx)
    return self.m_HorseIdList[idx]
end

function CHorseCtrl.GetAllHorse(self)
    return self.m_HorseDic
end

function CHorseCtrl.IsHadHorse(self)
    
    return next(self.m_HorseDic)

end

function CHorseCtrl.GetHorseById(self, id)
    return self.m_HorseDic[id]
end

function CHorseCtrl.SetCurSelHorseId(self, id)
    self.m_CurSelHorseId = id
end

function CHorseCtrl.GetCurSelHorseId(self)
    return self.m_CurSelHorseId
end

function CHorseCtrl.SetCurSelHorseItem(self, item)
    self.m_CurSelHorseItem = item
end

function CHorseCtrl.GetCurSelHorseItem(self)
    return self.m_CurSelHorseItem
end

function CHorseCtrl.GetExpByGrade(self, grade)
	if data.ridedata.UPGRADE[grade] == nil then
		return nil
	end
	return data.ridedata.UPGRADE[grade].ride_exp
end

function CHorseCtrl.GetSocreById(self, id)
    local sum = 0

    local talentScore = 0
    if not id then 
        return
    end 

    for k,v in pairs(data.ridedata.RIDEINFO[id].talent) do
        local str = string.gsub(data.ridedata.SKILL[v].score, "lv", 1) 
        local val = loadstring("return "..str)
        talentScore = talentScore + val()
    end
    return sum + self.score + talentScore
end

function CHorseCtrl.GetRideName(self, rideId)
    
    local horseData = data.ridedata.RIDEINFO[rideId]
    if horseData then 
        return horseData.name
    end 

end

--是否已激活
function CHorseCtrl.IsHorseActive(self, horseId)

    if self.m_HorseIdList ~= nil then 
        for k, v in pairs(self.m_HorseIdList) do 
            if v == horseId then 
                return true
            end 
        end 
    end 
    return false
    
end

--是否永久激活
function CHorseCtrl.IsHorseActiveForever(self, horseId)

    if self.m_HorseIdList ~= nil then 
        for k, v in pairs(self.m_HorseIdList) do 
            if v == horseId then
                local horse = self:GetHorseById(v)
                if horse.left_time == -1 then 
                    return true
                else
                    return false
                end 
            end 
        end 
    end 
    return false
    
end


function CHorseCtrl.IsUsingFlyRide(self)
    
    if self.use_ride ~= nil and self.use_ride > 0 then 
        local config = data.ridedata.RIDEINFO[self.use_ride]
        if config then 
            if config.flymap > 0 then 
                return true
            end 
        end 
    end 

    return false

end


--是否可激活
function CHorseCtrl.IsCanHorseActive(self, horseId)
    
    local playerGrade = g_AttrCtrl.grade
    local isCanActive = false
    local horseData = data.ridedata.RIDEINFO[horseId]

    local condition1 = playerGrade >= horseData.player_level
    local condition2 = self.grade >= horseData.ride_level
    local condition3 = false

    if #horseData.activate_item ~= 0 then 
        for j, t in pairs(horseData.activate_item) do 
            local needCount = t.cnt
            local itemId = t.itemid
            local count = g_ItemCtrl:GetBagItemAmountBySid(itemId)
            if count >= needCount then 
                condition3 = true
            else 
                condition3 = false
            end 
        end 
    else 
        condition3 = true
    end  

    isCanActive = condition1 and condition2 and condition3
      
    return isCanActive

end

function CHorseCtrl.GetIsInFlyMap(self, curUseHorseId)
    if curUseHorseId then
        local config = data.ridedata.RIDEINFO[self.m_CurUseHorseId]
        if config and config.flymap == 1 then
            return true
        end
    end
    return false
end

--是否坐在飞行坐骑上
function CHorseCtrl.IsRideFly(self)
    
    if self.m_CurUseHorseId ~= nil then 
        return self:GetIsInFlyMap(self.m_CurUseHorseId)
    else
        return false
    end 

end

function CHorseCtrl.FindBaseSkill(self)

    local skillList = data.ridedata.SKILL
    local skill = {}
    for k,v in pairs(skillList) do
        if v.ride_type == 0 then
            table.insert(skill, v.id)
        end
    end
    table.sort( skill, function (a, b)
        return a < b
    end)

    return skill

end

--找出基本技能的所有进阶技能
function CHorseCtrl.FindAdvanceSkills(self, baseId)
    
    local skillList = data.ridedata.SKILL
    local skill = {}
    for k,v in pairs(skillList) do
        if v.con_skill[1] == baseId then
            table.insert(skill, v.id)
        end
    end
    table.sort( skill, function (a, b)
        return a < b
    end)

    return skill

end

--获取技能data
function CHorseCtrl.GetHorseSkill(self)
    
    local baseSkillList = self:FindBaseSkill()

    local horseSkill = {}

    for k, v in ipairs(baseSkillList) do
        local list = {}
        table.insert(list, v)
        local advList = self:FindAdvanceSkills(v)
        table.insert(list, advList)
        table.insert(horseSkill, list)
    end 

    return horseSkill

end

function CHorseCtrl.GetSkillLevel(self, id)
    
    local skillList = self.skills
    for k, v in pairs(skillList) do 
        if v.sk == id then 
            return v.level
        end 
    end

end

function CHorseCtrl.IsCanForgetSkill(self, id)

    local IsHadAdvSk = function ()

        local advList = self:FindAdvanceSkills(id)
        for k, v in pairs(advList) do 
            for j, i in pairs(self.skills) do 
                if v == i.sk then 
                    return true
                end 
            end 
        end

        return false

    end
    
    local skillList = self.skills
    for k, v in pairs(skillList) do 
        if v.sk == id then 
            local config = data.ridedata.SKILL[id]
            if config.ride_type == 1 then 
                return true
            else
                if IsHadAdvSk(id) then 
                    return false
                else
                    return true
                end     

            end 
        end 
    end

end

function CHorseCtrl.IsCanTupo(self)
    
    local config = data.ridedata.UPGRADE[self.grade + 1]   
    if config then 
        local nextExp = g_HorseCtrl:GetExpByGrade(self.grade + 1) 
        if  g_HorseCtrl.exp >= nextExp then
            return true
        else
            return false
        end
    else
        return false
    end 

end

function CHorseCtrl.GetTextTip(self, id)
    
    local config = data.ridedata.TEXT[id]
    if config then 
        return config.content
    end 

end

function CHorseCtrl.IsHadLearnSkill(self, id)

    if self.m_SkillDic then 
        return self.m_SkillDic[id]
    end 

end

function CHorseCtrl.IsFullGrade(self)
    
    local nextExp = self:GetExpByGrade(self.grade + 1)
    if nextExp then
        return false
    end 

    return true

end

--获取坐骑激活消耗列表
function CHorseCtrl.GetActiveConsumeListByType(self, id, consumeType)

    local buyinfo = data.ridedata.BUYINFO[id]
    local consumeList = {}

    for k, v in ipairs(buyinfo) do 
        local type = v.cost_money[1].type
        if type == consumeType then 
            table.insert(consumeList, v)
        end 
    end 

    return consumeList

end


------------坐骑统御协议--------------

function CHorseCtrl.C2GSControlSummon(self, rideid, petId, pos)
    
    netride.C2GSControlSummon(rideid, petId, pos)

end

function CHorseCtrl.C2GSUnControlSummon(self, rideid, pos)
    
    netride.C2GSUnControlSummon(rideid, pos)

end

--获取坐骑统御的宠物
function CHorseCtrl.GetRideTongYuPetList(self, id)
    
    local rideInfo = self.m_HorseDic[id]
    if rideInfo then 
        local sList = {}
        local summonIdList = rideInfo.summons
        local summonInfoList = g_SummonCtrl.m_SummonsSort
        for k, tongYuInfo in ipairs(summonIdList) do 
            for i, sInfo in pairs(summonInfoList) do 
                if tongYuInfo.summon == sInfo.id then 
                    local pos = tongYuInfo.pos
                    local info = {}
                    info.id = sInfo.id
                    info.name = sInfo.name
                    info.icon = sInfo.model_info.shape
                    info.pos = pos
                    info.lv = sInfo.grade
                    sList[info.pos] = info
                end 
            end 
        end 
        return sList
    end 

end

function CHorseCtrl.IsHideEffect(self, id)
    
    local config = data.ridedata.RIDEINFO[id]
    if config then 
        if config.hideEffect == 1 then
            return true
        end 
    end 

    return false

end

return CHorseCtrl
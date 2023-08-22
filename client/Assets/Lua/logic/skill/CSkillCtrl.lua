local CSkillCtrl = class("CSkillCtrl", CCtrlBase)

function CSkillCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_SchoolSkills = {}
	self.m_ActiveSkills = {}
	self.m_PassiveSkills = {}

	self.m_CultivateSkillId = nil
	self.m_CultivateSkills = {}
	self.m_CultivateUpperLv = -1
	self.m_CultivateLimitType = 0
	self.m_CultivateItemUseInfo = {} --道具可使用数量信息

	self.m_FuZhuanDataList = {}
	self.m_FuZhuanDataHashList = {}

	self.m_QingYuanSkills = {}

	self:SetFuZhuanItemSidToId()

	self.m_LastTab = nil
	self.m_ActiveSkillEffect = {}
end

function CSkillCtrl.Reset(self)
	self.m_LastTab = nil
	self.m_ActiveSkillEffect = {}
end

function CSkillCtrl.LoginSchoolSkill(self, pbdata)
	for k, skills in pairs(pbdata) do
		for k, v in pairs(skills) do
			if v.sk then
				if not self.m_SchoolSkills[v.sk] then
					self.m_SchoolSkills[v.sk] = {}
				end
				self.m_SchoolSkills[v.sk] = v
			end
		end
	end
	self.m_ActiveSkills = {}
	for k,v in ipairs(pbdata.active_skill) do
		table.insert(self.m_ActiveSkills, v)
	end
	self.m_PassiveSkills = {}
	for k,v in ipairs(pbdata.passive_skill) do
		table.insert(self.m_PassiveSkills, v)
	end
	self:OnEvent(define.Skill.Event.LoginSkill)
end

function CSkillCtrl.RefreshSchoolSkill(self, dSchoolSkill)
	self.m_SchoolSkills[dSchoolSkill.sk] = dSchoolSkill

	local bIsActiveExist = false
	for k,v in ipairs(self.m_ActiveSkills) do
		if v.sk == dSchoolSkill.sk then
			bIsActiveExist = true
			self.m_ActiveSkills[k] = dSchoolSkill
			break
		end
	end
	if not bIsActiveExist and data.skilldata.SCHOOL[dSchoolSkill.sk] then
		table.insert(self.m_ActiveSkills, dSchoolSkill)
	end

	local bIsPassiveExist = false
	local zIsRefresh = false
	for k,v in ipairs(self.m_PassiveSkills) do
		if v.sk == dSchoolSkill.sk then
			bIsPassiveExist = true
			self.m_PassiveSkills[k] = dSchoolSkill
			zIsRefresh = true
			break
		end
	end
	if not bIsPassiveExist and data.skilldata.PASSIVE[dSchoolSkill.sk] then
		table.insert(self.m_PassiveSkills, dSchoolSkill)
	end
	if zIsRefresh then
		self:OnEvent(define.Skill.Event.PassiveRefresh)
	end

	self:OnEvent(define.Skill.Event.SchoolRefresh, dSchoolSkill)

	if g_WarCtrl:IsWar() and not g_MapCtrl.m_In2DMap then
		g_NotifyCtrl:FloatMsg("战斗结束后生效")
	end

	printc("技能升级更新协议")
	table.print(dSchoolSkill,"技能升级更新协议返回:")
end

function CSkillCtrl.GetSchoolSkillData(self,iSkill)
	if self.m_SchoolSkills[iSkill] then
		return self.m_SchoolSkills[iSkill]
	end
	return {}
end

function CSkillCtrl.GetSchoolSkillCost(self, iSkill)
	if self.m_SchoolSkills[iSkill] then
		return self.m_SchoolSkills[iSkill].needmoney
	end
	return 0
end

function CSkillCtrl.GetSchoolSkillLevel(self, iSkill)
	if self.m_SchoolSkills[iSkill] then
		if self.m_SchoolSkills[iSkill].level then
			return self.m_SchoolSkills[iSkill].level
		else
			return 0
		end
	end
	return 0
end

function CSkillCtrl.GetSchoolDesc(self, oLevel, oSkillConfig)
	if not oSkillConfig or #oSkillConfig.desc <= 0 then
		return "无描述配置"
	end
	for i = #oSkillConfig.desc, 1, -1 do
		if oLevel >= oSkillConfig.desc[i].level then
			return oSkillConfig.desc[i].desc
		end
	end
	return "无描述配置"
end

function CSkillCtrl.GetSchoolSkillList(self, iSchool)
	local list = {}
	for i, dSchool in pairs(data.skilldata.SCHOOL) do
		if dSchool.school == iSchool then
			table.insert(list, dSchool)
		end
	end
	local function sortfunc(d1, d2)
		return (data.skilldata.SCHOOL[d1.id].sortOrder or 0) < (data.skilldata.SCHOOL[d2.id].sortOrder or 0)
	end
	table.sort(list, sortfunc)
	return list
end

function CSkillCtrl.GetPassiveSkillList(self, iSchool)
	local zList = {}
	for k,v in ipairs(self.m_PassiveSkills) do
		table.insert(zList, v)
	end
	return zList
end

function CSkillCtrl.IsSelectedCultivateSkill(self, iSkillId)
	return iSkillId == self.m_CultivateSkillId
end

function CSkillCtrl.SetSelectedCultivateSkill(self, iSkillId)
	--local tSkillData = data.skilldata.CULTIVATION[iSkillId]
	--printc("设置选中的技能",iSkillId)
	-- if tSkillData == nil then
	-- 	printerror("错误：技能信息空，检查技能ID")
	-- 	return
	-- end
	local preSkillId = -1
	preSkillId = self.m_CultivateSkillId
	self.m_CultivateSkillId = iSkillId
	-- if tSkillData.type == define.Skill.CultivateType.Role then
	-- 	preSkillId = self.m_CultivateSkillId.Role
	-- 	self.m_CultivateSkillId.Role = iSkillId
	-- else
	-- 	preSkillId = self.m_CultivateSkillId.Partner
	-- 	self.m_CultivateSkillId.Partner = iSkillId
	-- end
	self:OnEvent(define.Skill.Event.SetCultivate, {preSkill = preSkillId, curSkill = iSkillId})
end

function CSkillCtrl.SetCultivateUpperLevel(self, iLevel)
	self.m_CultivateUpperLv = iLevel
end

function CSkillCtrl.GetCultivateUpperLevel(self)
	return self.m_CultivateUpperLv
end

function CSkillCtrl.GetSelectedCultivateSkill(self)
	return self.m_CultivateSkillId
end

function CSkillCtrl.GetCultivateSkillList(self)
	local list = {}
	for i, tSkill in pairs(self.m_CultivateSkills) do                     
		table.insert(list, tSkill)
	end
	local function sortfunc(d1, d2)
		return d1.sk < d2.sk
	end
	table.sort(list, sortfunc)
	return list
end

--今日可使用次数(仙灵丹或炼体丹)
function CSkillCtrl.GetItemUseInfo(self, itemsid)
	return self.m_CultivateItemUseInfo[itemsid]
end

function CSkillCtrl.RefreshItemUseInfo(self, iteminfo)
	if iteminfo and next(iteminfo) then
		for i, v in ipairs(iteminfo) do
			local sid = v.itemsid
			local count = v.count_limit or 0
			self.m_CultivateItemUseInfo[sid] = v
		end
	else
		self.m_CultivateItemUseInfo = {}
	end
end

--[[刷新单个修炼技能]]
function CSkillCtrl.RefreshCultivateSkill(self, tSkillInfo, iUpperLv, limit)
	printc("刷新单个修炼技能iUpperLv:"..iUpperLv)
	if tSkillInfo and next(tSkillInfo) then
		table.print(tSkillInfo,"刷新单个修炼技能tSkillInfo:")
		self.m_CultivateSkills[tSkillInfo.sk] = tSkillInfo
	end
	self:SetCultivateUpperLevel(iUpperLv)
	self.m_CultivateLimitType = limit

	self:OnEvent(define.Skill.Event.RefreshCultivate, {Skill = tSkillInfo})

	if g_WarCtrl:IsWar() and not g_MapCtrl.m_In2DMap then
		g_NotifyCtrl:FloatMsg("战斗结束后生效")
	end
end

--[[刷新全部修炼技能]]
function CSkillCtrl.RefreshCultivateSkillList(self, pbdata)
	self:SetSelectedCultivateSkill(pbdata.role_sk)
	--self:SetSelectedCultivateSkill(pbdata.partner_sk)   --去掉伙伴选中
	self:SetCultivateUpperLevel(pbdata.upperlevel)
	self.m_CultivateLimitType = pbdata.limit

	for k,skill in pairs(pbdata.skill_info) do
		self.m_CultivateSkills[skill.sk] = skill
	end
	-- table.print(self.m_CultivateSkills)
	self:OnEvent(define.Skill.Event.RefreshAllCultivate)
end

--刷新修炼技能的等级上限
function CSkillCtrl.RefreshSkillMaxLevel(self, iUpperLv, limit)
	printc("刷新修炼技能的等级上限:"..iUpperLv)
	self:SetCultivateUpperLevel(iUpperLv)
	self.m_CultivateLimitType = limit
	self:OnEvent(define.Skill.Event.RefreshSkillMaxLevel)
end

-- [[返回修炼所需的每级经验]]
function CSkillCtrl.GetCultivateExp(self, lv, skillId)
	local tData = data.skilldata.CULTIVATION[skillId]
	if tData then
		local formula = string.gsub(tData.exp,"lv",lv)
		local func = loadstring("return "..formula) 
     	if func then 
    		return func()
    	end
	else
		return 0 
	end
end

function CSkillCtrl.GetIsActiveSkillCouldUp(self)
	local bIsCould = false
	for i, dSkill in pairs(self.m_ActiveSkills) do
		local Skill = DataTools.GetSchoolSkillData(dSkill.sk)
		local NumStr = string.gsub(Skill.top_limit, "grade", tostring(g_AttrCtrl.grade))
		local TopLimitLv = math.floor(tonumber(load(string.format([[return (%s)]], NumStr))()))
		

		local itemNum = g_ItemCtrl:GetBagItemAmountBySid(data.skilldata.CONFIG[1].active_itemid)
		local oNeedCount = 0
		local oCurLevel = dSkill.level
		local oConfig = data.skilldata.SCHOOL[dSkill.sk].skillpoint_learn
		local oNextLevel = oCurLevel+1 >= oConfig[#oConfig].lv and oConfig[#oConfig].lv or (oCurLevel+1)
		oNeedCount = math.ceil(tonumber(load(string.format([[return (%s)]], oConfig[oNextLevel].formula))()))
		local oLearnLevel = dSkill.level + 1
		local oNeedGrade = 0
		if not Skill.learn_limit[oLearnLevel] then
			oNeedGrade = Skill.learn_limit[#Skill.learn_limit].grade
		else
			oNeedGrade = Skill.learn_limit[oLearnLevel].grade
		end

		-- printc("333333333 ", dSkill.sk, oNeedCount, itemNum, dSkill.level, g_AttrCtrl.grade, oNeedGrade)

		if oNeedCount <= itemNum
			and dSkill.level < TopLimitLv and dSkill.level >= 0 and g_AttrCtrl.grade >= oNeedGrade then --and dSkill.needmoney <= g_AttrCtrl.silver 
			bIsCould = true
			break
		end
	end
	return bIsCould
end

function CSkillCtrl.GetIsPassiveSkillCouldUp(self)
	local bIsCould = false
	local passivelist = self:GetPassiveSkillList()
	for i = 1, 7 do
		if passivelist[i] and passivelist[i].needmoney <= g_AttrCtrl.silver and 
		g_AttrCtrl.grade >= data.skilldata.PASSIVE[passivelist[i].sk].open_level and passivelist[i].level > 0 and passivelist[i].level < g_AttrCtrl.grade then
			bIsCould = true
			break
		end
	end
	return bIsCould
end

--oType区分人物修炼技能，宠物和伙伴修炼技能， 不传则判断这两个
function CSkillCtrl.GetIsCultivateCouldUp(self, oType)
	local oSkills = g_SkillCtrl:GetCultivateSkillList()
	local oUpperLv = g_SkillCtrl:GetCultivateUpperLevel()
	local iCurLevel = g_AttrCtrl.m_BadgeInfo and g_AttrCtrl.m_BadgeInfo.tid or 0
  	local tTxData = data.touxiandata.DATA[iCurLevel]
  	
	for i, dSkill in ipairs(oSkills) do
		local txConfig = self:SplitAtt(tTxData, dSkill)		
		local oLevel = g_SkillCtrl.m_CultivateSkills[dSkill.sk].level --+txConfig
		--人物修炼技能
		if i <= 4 then			
			if (not oType or (oType and oType == 1)) and oLevel < oUpperLv and g_ItemCtrl:GetBagItemAmountBySid(define.Skill.CultivationNeedItem.Player) > 0 then
				return i
			end
		--宠物和伙伴修炼技能
		elseif i > 4 then
			if (not oType or (oType and oType == 2)) and oLevel < oUpperLv and g_ItemCtrl:GetBagItemAmountBySid(define.Skill.CultivationNeedItem.Partner) > 0 then
				return i
			end
		end
	end
	return false
end

--头衔系统增加修炼等级，拆分属性 （返回重新存储的属性表）
function CSkillCtrl.SplitAtt(self, tTxData, dSkill)
  	if not tTxData then
	   return 0
   	end
   	if g_AttrCtrl.grade < data.opendata.OPEN.BADGE.p_level then
		return 0 
	end
   local config = nil
   for i,v in pairs(tTxData.effect) do
   		if dSkill.sk == v.id  then
   			config = v.level
   			break
   		end
   end
   -- local function split(str , sign)
   -- 		local lst = {}
   -- 		local n = string.len(str) --长度
   -- 		local start = 1
   -- 		while start <=n do
   -- 			local i = string.find(str, sign, start)
   -- 			if i == nil then
   -- 				table.insert(lst ,string.sub(str, start ,n))
   -- 				break
   -- 			end
   -- 			table.insert(lst,string.sub(str,start, i-1))
   -- 			if i == n then
   -- 				table.insert(lst,"")
   -- 				break
   -- 			end
   -- 			start = i +1
   -- 		end
   -- 		return lst
   -- end

   -- printc("=============@@@1")
   -- local temp_string = 
   -- printc("=============@@@2")
   -- local attConfig = {}
   -- lv = lv or ""
   -- for i=1,#temp_string do
   --     local temp = split(temp_string[i],"=")

   --     local formula = string.gsub(temp[2], "level", lv)
   --     attConfig[tonumber(temp[1])] = formula
   -- end
   --
   if config then	
   		return config
   	else
   		return 0
   	end
end

function CSkillCtrl:GetFaBaoSkillLv(self, iMagicID)
	local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()
	for i, v in ipairs(fabaolist) do
		if v.skilllist then
			for i, v in ipairs(v.skilllist) do
				if v.sk == iMagicID then
					local lv = v.level or 0
					return lv
				end
			end
		end
	end
	return 0
end

function CSkillCtrl.GetMagicLv(self, iMagicID, bHero)
    local iLevel = 1
    if bHero then
		local iSkill = self:GetMagicSkillId(iMagicID)
   		local dSkill = g_SkillCtrl.m_SchoolSkills[iSkill]
    	if dSkill then
        	iLevel = tonumber(dSkill.level)
    	end
    else
    	if not g_WarCtrl.m_SummonWid then
    		return iLevel
    	end
        local dFightSummon = g_SummonCtrl:GetSummon(g_WarCtrl.m_SummonWid)
        if dFightSummon then
            local skillList = dFightSummon.skill
            for _, dSkill in ipairs(skillList) do
                if dSkill.sk == iMagicID then
                    iLevel = tonumber(dSkill.level)
                    break
                end
            end
        end
    end
    return iLevel
end

function CSkillCtrl.GetMagicCost(self, iMagicID)
	local dData = DataTools.GetMagicData(iMagicID)
	local bHero = dData.magic_type ~= "summon"
	local iLevel = self:GetMagicLv(iMagicID, bHero)
	local dSummon = g_WarCtrl:GetSummonState()
	local iSummonGrade = dSummon and dSummon.grade or 0
    local dParams = {
        grade = bHero and g_AttrCtrl.grade or iSummonGrade,
        level = iLevel,
    }
    local dCost = dData.cost
    local function calcFunc (sFormula)
        local iResult
        if sFormula and string.len(sFormula) > 0 then
            iResult = math.floor(string.eval(sFormula, dParams))
        end
        return iResult
    end
    local dResult = {
    	hp = calcFunc(dCost.hp),
    	mp = calcFunc(dCost.mp),
    	aura = tonumber(dCost.aura),
    	sp = tonumber(dCost.sp),
	}
    return dResult
end

function CSkillCtrl.GetMagicSkillId(self, iMagicID)
	local skillList = g_SkillCtrl:GetSchoolSkillList(g_AttrCtrl.school)
	for _, dSkill in ipairs(skillList) do
		if dSkill.magics[iMagicID] then
			return dSkill.id
		end
	end
end

function CSkillCtrl.GetMagicCd(self, iMagicID, bHero)
	local dCd = bHero and g_WarCtrl:GetHeroCdData() or g_WarCtrl:GetSummonCdData()
	if dCd and dCd[iMagicID] then
		local iBout = g_WarCtrl:GetBout()
		return dCd[iMagicID] + 1 - iBout
	end
end

function CSkillCtrl.IsFaBaoSkillOnWear(self, iMagicID)
	local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()
	for i, v in ipairs(fabaolist) do
		if v.skilllist then
			for i, v in ipairs(v.skilllist) do
				if v.sk == iMagicID then
					return true
				end
			end
		end
	end
	return false
end

function CSkillCtrl.GetCurZhenqi(self)
	local wid = g_WarCtrl.m_HeroWid
	local oWarrior = g_WarCtrl:GetWarrior(wid)
	local zhenqi = tonumber(oWarrior.m_Status.zhenqi) 
	return zhenqi
end

-- 是否可使用(消耗足够)
function CSkillCtrl.IsMagicCanUse(self, iMagicID)
	local dData = DataTools.GetMagicData(iMagicID)
	local bHero = dData.magic_type ~= "summon"
	local iMagicCd = self:GetMagicCd(iMagicID, bHero)
	if iMagicCd and iMagicCd > 0 then
		return false
	end

	if g_MarrySkillCtrl:IsMarryMagic(iMagicID) then
		if not g_MarrySkillCtrl:IsMagicCanUse(iMagicID) then
			return false
		end
 	--法宝根据真气判断是否使用
	elseif dData.magic_type == "fabao" then 
		local needZhengqi = string.eval(dData.zhengqi, {math = math})
		local curZhenqi = self:GetCurZhenqi()
		return curZhenqi >= needZhengqi
	end

	local dState = bHero and g_WarCtrl:GetHeroState() or g_WarCtrl:GetSummonState()
	-- 1104技能使用有hp限制
	if iMagicID == 1104 and dState.hp < dState.max_hp/2 then
		return false
	end
	local dCost = self:GetMagicCost(iMagicID)
	local dCur = {
		hp = dState.hp,
		mp = dState.mp,
	}
	if bHero then
		local oHero = g_WarCtrl:GetHero()
		if not oHero then
			return
		else
			dCur.aura = oHero.m_Status.aura
			dCur.sp = oHero.m_Status.sp
		end
	end

	local bResult = true
	for k, v in pairs(dCost) do
		if dCur[k] and v > dCur[k] then
			bResult = false
			break
		end
	end
	return bResult
end

----------------- 情缘技能 --------------------
function CSkillCtrl.GS2CMarrySkill(self, list)
	if #list == 0 then
		self.m_QingYuanSkills = {}
	else
		for i, v in ipairs(list) do
			table.insert(self.m_QingYuanSkills, v)
		end
	end
end

-----------------剧情技能相关------------------

function CSkillCtrl.GS2CAllFuZhuanSkill(self, pbdata)
	self.m_FuZhuanDataList = {}
	self.m_FuZhuanDataHashList = {}
	for k,v in ipairs(pbdata.skill_list) do
		table.insert(self.m_FuZhuanDataList, v)
		self.m_FuZhuanDataHashList[v.sk] = v
	end
	self:OnEvent(define.Skill.Event.RefreshFuZhuanSkill)
end

function CSkillCtrl.GS2CRefreshFuZhuanSkill(self, pbdata)
	local oData = self.m_FuZhuanDataHashList[pbdata.sk]
	if not oData then
		table.insert(self.m_FuZhuanDataList, {sk = pbdata.sk, level = pbdata.level})
		self.m_FuZhuanDataHashList[pbdata.sk] = {sk = pbdata.sk, level = pbdata.level}
	else
		for k,v in pairs(self.m_FuZhuanDataList) do
			if v.sk == pbdata.sk then
				v.level = pbdata.level
				break
			end
		end
		oData.level = pbdata.level
	end
	self:OnEvent(define.Skill.Event.RefreshFuZhuanSkill)
end

function CSkillCtrl.SetFuZhuanItemSidToId(self)
	self.m_FuZhuanItemSidToIdList = {}
	for k,v in pairs(data.skilldata.FUZHUAN) do
		self.m_FuZhuanItemSidToIdList[v.itemsid] = k
	end
end

function CSkillCtrl.GetFuZhuanDesc(self, oItemData)
	local oId = self.m_FuZhuanItemSidToIdList[oItemData:GetSValueByKey("sid")]
	if not oId then
		return
	end
	local oLevel = oItemData:GetFuZhuanLevel()
	local oConfig = data.skilldata.FUZHUAN[oId]
	if not oLevel or not oConfig then
		return {oItemData:GetCValueByKey("description")}
	end
	table.print(oItemData:GetSValueByKey("apply_info"), "1111111111")
	local oDescStr = data.attrnamedata.DATA[oConfig.attr].name
	local oNumStr1 = string.gsub(oConfig.attr_value_min, "lv", tostring(oLevel))
	local oMin = math.floor(tonumber(load(string.format([[return (%s)]], oNumStr1))()))
	local oNumStr2 = string.gsub(oConfig.attr_value_max, "lv", tostring(oLevel))
	local oMax = math.floor(tonumber(load(string.format([[return (%s)]], oNumStr2))()))
	oDescStr = "[0fff32]"..oLevel.."级 "..oDescStr.."[-]增加[0fff32]"..oMin.."~"..oMax.."[-]"
	return {oDescStr, oItemData:GetCValueByKey("description")}
end

function CSkillCtrl.GetOpenFuZhuanList(self)
	local oList = {}
	if g_OpenSysCtrl:GetOpenSysState(define.System.Talisman) then
		for k,v in ipairs(self.m_FuZhuanDataList) do
			if v.level > 0 then
				table.insert(oList, v)
			end
		end
	end
	return oList
end

function CSkillCtrl.RecordLastTab(self, iTab)
	self.m_LastTab = iTab
end

return CSkillCtrl
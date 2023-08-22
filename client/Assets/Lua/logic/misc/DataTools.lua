module(..., package.seeall)

oItemConfig = {}
oItemTypeHashConfig = {}

function Init()
	--暂时屏蔽
	-- CheckItemConfig()
end

--更新导表
function UpdateData(lDelFileNames, lFileResVersions)
	for i, sDeleteFile in ipairs(lDelFileNames) do
		local filepath = IOTools.GetPersistentDataPath("/data/"..sDeleteFile)
		IOTools.Delete(filepath)
		package.loaded["logic.data."..sDeleteFile] = nil
		data[sDeleteFile] = nil
		printc("DataTools.UpdateData, del:", sDeleteFile)
	end
	for i, dFileResVersion in ipairs(lFileResVersions) do
		local filepath = IOTools.GetPersistentDataPath("/data/"..dFileResVersion.file_name)
		IOTools.SaveByteFile(filepath, dFileResVersion.content)
		package.loaded["logic.data."..dFileResVersion.file_name] = nil
		data[dFileResVersion.file_name] = nil
		printc("DataTools.UpdateData, modify:", dFileResVersion.file_name)
	end
end

--获取数据
function GetAnimEventData(shape, state)
	local t =  datauser.animeventdata.Data[shape]
	if not t then
		t = datauser.animeventdata.Data[define.Model.Defalut_Shape]
	end
	return t[state]
end

function GetLineupPos(sType)
	local t = data.lineupdata.GRID_POS_MAP[sType]
	return Vector3.New(t.x, 0, t.z)
end

function GetBossLineupPos(iPos)
	if iPos > #data.lineupdata.BOSS_POS_MAP then
		printerror("错误：非法的Boss战位置", iPos)
		return
	end
	local t = data.lineupdata.BOSS_POS_MAP[iPos]
	return Vector3.New(t.x, 0, t.z)
end

function GetMagicTimeInfo(magicid, shape, index)
	local magicInfo = datauser.magictimedata.DATA[magicid]
	if magicInfo and magicInfo[shape] and magicInfo[shape][index] then
		return magicInfo[shape][index]
	end
end

function GetBuffData(id)
	local d = datauser.warbuffdata.DATA[id]
	if not d then
		-- d = datauser.warbuffdata.DATA[1]
		printc("使用默认buff特效,未找到资源Buff_ID: " .. id .. " 用buff编辑器添加")
		-- g_NotifyCtrl:FloatMsg("使用默认buff特效,未找到资源Buff_ID: " .. id)
	end
	return d
end

function GetWarConfigData(iTypeID)
	local d = data.warconfigdata.COMMON[iTypeID]
	if not d and iTypeID and iTypeID > 0 then
		printc("没有找到指定Key的战斗配置信息，Key->", iTypeID)
	end
	return d
end

function GetPayInfo(productKey)
	local t = data.paydata.PAY[productKey]
	if not t then
		printc("没有找到指定Key的支付信息，Key->", productKey)
	end
	return t
end

function GetAudioSound(sName)
	local t = datauser.audiodata.DATA[sName]
	if not t then
		printc("没有找到指定名字的音效，请查看音效名字是否填写错误，名字->", sName)
	end
	return t
end

function GetSchoolSkillData(iSkill)
	local t = data.skilldata.SCHOOL[iSkill]
	if not t then
		t = data.skilldata.SCHOOL[1100]
	end
	return t
end

function GetPassiveSkillData(iSkill)
	local t = data.skilldata.PASSIVE[iSkill]
	if not t then
		t = data.skilldata.PASSIVE[2101]
	end
	return t
end

function GetOrgSkillData(iSkill)
	local t = data.skilldata.ORGSKILL[iSkill]
	if not t then
		printc("不存在帮派技能，id ----- ", iSkill)
	end
	return t
end

function GetCultivationData(iSkill)
	local t = data.skilldata.CULTIVATION[iSkill]
	if not t then
		t = data.skilldata.CULTIVATION[4000]
	end
	return t
end

function GetSpecialEffcData(id)
	local t = data.skilldata.SPECIAL_EFFC
	if t then
		return t[id] 
	end
end

function GetMarrySkillData(id)
	local t = data.skilldata.MARRY
	if t then
		return t[id]
	end
end

function GetFaBaoSkillData(id)
	local t = data.skilldata.FABAO
	if t then
		return t[id]
	end
end

function GetOrgSkillByItem(iItemid)
	local t = data.skilldata.ORGSKILL
	for i,v in pairs(t) do
		if v.item then
			for _,item in ipairs(v.item) do
				table.print(item)
				if iItemid == item.id then
					return v
				end
			end
		end
	end
	return nil
end

function GetViewOpenData(iOpenId)
	local t = data.opendata.OPEN[iOpenId]
	return t
end

function GetMagicData(iMagicID)
	local t = data.magicdata.DATA[iMagicID]
	if not t then
		t = data.magicdata.DATA[1]
		t.name = "未导表"..tostring(iMagicID)
	end
	return t
end

function GetMaigcPassiveData(iPassiveID)
	local t = data.magicdata.PASSIVE[iPassiveID]
	-- if not t then
	-- 	t = {
	-- 		desc=[[]],
	-- 		effectTime={},
	-- 		effectType=0,
	-- 		extArgs=[[]],
	-- 		id=5101,
	-- 		name="未导表"..tostring(iPassiveID),
	-- 		passiveDelay=0,
	-- 		passiveIcon=[[51001]],
	-- 		skill_formula=[[0]],
	-- 		skill_icon=0,
	-- 	}
	-- end
	return t
end

-- [[提示性文字]]
function GetMiscText(id, sType)
	sType = sType or "TEXT"
	if data.textdata[sType] then
		return data.textdata[sType][id]
	end
end

-- [[地图数据]]
function GetSceneInfo(sceneID)
	if data.mapdata.SCENE[sceneID] then
		return data.mapdata.SCENE[sceneID]
	end
	return {map_id = 101000}
end

function GetMapInfo(mapid)
	if data.mapdata.MAP[mapid] then
		return data.mapdata.MAP[mapid]
	end
	return {resource_id = 1010}
end

function CheckItemConfig(self)
	oItemConfig = {}
	oItemTypeHashConfig = {}
	local names = {
		"itemotherdata",
		"itemvirtualdata",
		"itemgroupdata",
		"itemequipdata",
		"itemsummskilldata",
		"itemforgedata",
		"itemequipbookdata",
		"itemequipsouldata",
		"itempartnerdata",
		"itempartnerequipdata",
		"itemtotaskdata",
		"itemgiftpackdata",
		"itemboxdata",
		"itemsummondata",
		"itemsummonequipdata",
	}
	for _,n in ipairs(names) do
		local d = data[n]
		if d then
			for f,v in pairs(d) do
				if type(v) == "table" then
					oItemTypeHashConfig[f] = {}
					for n,m in pairs(v) do
						if m.id then
							oItemConfig[m.id] = m
							oItemTypeHashConfig[f][m.id] = m
						elseif m.equipid then
							oItemConfig[m.equipid] = m
							oItemTypeHashConfig[f][m.equipid] = m
						end
					end
				end
			end
		end
	end
end

-- [[道具数据]]
function GetItemData(itemID, itemType)
	local itemid = tonumber(itemID)
	if itemid == nil then
		printerror("错误：非法的道具ID， 点击该项查看报错来源")
		return
	end

	--暂时屏蔽
	-- local item = nil
	-- if itemType then
	-- 	if oItemTypeHashConfig[itemType] then
	-- 		item = oItemTypeHashConfig[itemType][itemid]
	-- 	end
	-- 	return item
	-- else
	-- 	item = oItemConfig[itemid]
	-- end

	local names = {
		"itemotherdata",
		"itemvirtualdata",
		"itemgroupdata",
		"itemequipdata",
		"itemsummskilldata",
		"itemforgedata",
		"itemequipbookdata",
		"itemequipsouldata",
		"itempartnerdata",
		"itempartnerequipdata",
		"itemtotaskdata",
		"itemgiftpackdata",
		"itemboxdata",
		"itemsummondata",
		"itemsummonequipdata",
		"itemwenshidata",
	}
	local item = nil
	if itemType then
		for _,v in ipairs(names) do
			local d = data[v]
			if d and d[itemType] then
				item = d[itemType][itemid]
			end
		end
		return item
	end	
	if not item then
		for _,n in ipairs(names) do
			local d = data[n]
			if d then
				for _,v in pairs(d) do
					item = v[itemid]
					if item then
						break
					end
				end
			end
			if item then
				break
			end
		end		
	end
	
	if item then
		return item
	else
		return {
			name='默认道具'..itemid,
			icon=itemid,
			id=itemid,
		}
	end
end

function GetItemGroup(groupid)
	return data.itemgroupdata.ITEMGROUP[groupid]
end

function GetItemGainWayList(itemid)
	local data = GetItemData(itemid)
	if data and #data.gainWayIdStr > 0 then
		return data.gainWayIdStr
	end
	return nil
end

function GetItemGiftList(itemid, roleType, sex)
	local giftList = {}
	local giftpackData = data.itemgiftpackdata.GIFTPACK[itemid]
	if not giftpackData then
		return giftList
	end
	for i,giftId in ipairs(giftpackData.gift_items) do
		local giftGroup = GetItemGiftGroup(giftId, roleType, sex)
		if #giftGroup > 0 then
			for i,item in ipairs(giftGroup) do
				table.insert(giftList, item)
			end
		end
	end
	return giftList
end

function GetItemGiftGroup(giftId, roleType, sex)
	local giftdata = data.giftpackrewarddata.DATA
	local groud = {}
	for i,reward in ipairs(giftdata) do
		if giftId == reward.idx then
			if reward.type == 0 then
				table.insert(groud, {sid = reward.sid, amount = reward.amount, groupidx = reward.groupidx})
			else
				local sid = GetItemFiterResult(reward.sid, roleType, sex)
				table.insert(groud, {sid = sid, amount = reward.amount, groupidx = reward.groupidx})
			end
		end
	end
	return groud
end

function GetUpgradeGiftList(giftId, roletype, sex)
	
	local giftList =  data.rewarddata.GRADEGIFT[giftId]
	local upgradeGiftList = {}
	if giftList then 
		local addFunc = function(id, amountStr)
			if amountStr then
				local amount = tonumber(amountStr)
				if amount and amount > 0 then
					table.insert(upgradeGiftList,{sid = id, count = amount})
				end
			end
		end
		addFunc(1001, giftList.gold)
		addFunc(1002, giftList.silver)
		addFunc(1003, giftList.goldcoin)
		if giftList.item then 
			for k , v in ipairs(giftList.item) do 
				local item = {}
				if v.type == 0 then 
					item.sid = v.sid
					item.count = v.amount
				else 
					local sid =  DataTools.GetItemFiterResult(v.sid, roletype, sex)

					if sid ~= -1 then 
						item.sid = sid
						item.count = v.amount
					end 
				end 
				table.insert(upgradeGiftList, item)
			end 
		end 
	end 
	return upgradeGiftList

end

function GetItemFiterResult(sdx, roleType, sex)
	

	local filterdata = data.itemfilterdata.DATA
	-- table.print(filterdata)
	local result = {}
	for i,item in pairs(filterdata) do
		local sid = item.sid
		if item.idx ~= sdx then
			sid = -1
		elseif item.roletype ~= 0 and item.roletype ~= roleType then
			sid = -1
		elseif item.sex ~= 0 and item.sex ~= sex then
			sid = -1
		end
		if sid ~= -1 then
			return sid
		end
	end
	return -1
end

function GetItemQuality(sid)
	local filterdata = data.itemfilterdata.DATA 

	for _, v in ipairs(filterdata) do
		if v.sid == sid then
			return v.quality
		end
	end
	
end

function GetPartnerItem(partnerItemID)
	local partnerItem = data.itempartnerdata.PARTNER
	local item = partnerItem[partnerItemID]
	if item then
		return item
	end
	printerror("错误：获取伙伴物品，检查伙伴物品ID是否错误", partnerItemID)
end

function GetSummonItem(summonID)
	for k,v in pairs(data.itemsummondata.SUMMON) do
        if summonID == v.summonid then
            return k
        end
    end
end

-- [[商店数据]]
function GetNpcStoreInfo(storeID)
	if data.shopdata.NPCSHOP[storeID] then
		return data.shopdata.NPCSHOP[storeID]
	end
	printerror("错误：获取Npc商店物品，检查商品ID是否错误")
end

-- [[NPC数据]]
function GetSchoolNpcID(schoolID, typeName)
	-- 默认取第一个门派，师傅
	schoolID = schoolID or 1
	typeName = typeName or "tutorid"
	local schoolInfo = data.npcdata.SCHOOL[schoolID]
	if schoolInfo and schoolInfo[typeName] then
		return schoolInfo[typeName]
	end
	printerror("没有找到门派Npc，查看导表是否有误。门派 -> | 类型 -> ", schoolID, typeName)
	return ""
end

function GetGlobalNpcList(mapID)
	if mapID and mapID > 0 then
		local npclist = {}
		local globalNpc = data.npcdata.NPC.GLOBAL_NPC
		for _,v in pairs(globalNpc) do
			if mapID == v.mapid then
				table.insert(npclist, v)
			end
		end
		return npclist
	end
	printerror("没有找到NpcList，查看mapID是否错误。mapID -> ", mapID or "nil")
	return {}
end

function GetGlobalNpc(globalNpcID)
	if globalNpcID and globalNpcID > 0 then
		local globalNpc = data.npcdata.NPC.GLOBAL_NPC
		local npc = globalNpc[globalNpcID]
		if npc then
			return npc
		end
	end
end

function GetNpctalkListTalk(self, funGroup, npcType)
	if data.npcdata.NPCTALKLIST[funGroup] then
		return data.npcdata.NPCTALKLIST[funGroup][npcType]
	end
end

function GetNpcPatrolInfo(patrolID)
	local patrolInfo = data.npcdata.NPCPATROL[patrolID]
	if patrolInfo then
		return patrolInfo
	end
	return data.npcdata.NPCPATROL[1]
end

function GetSealNpcMapInfo(playerLevel)
	playerLevel = math.floor(playerLevel * 0.1) * 10
	local level = 0
	local info = nil
	for _,v in pairs(data.npcdata.SEALNPCMAP) do
		if v.level == playerLevel then
			return v
		end
		if v.level > level then
			level = v.level
			info = v
		end
	end
	return info
end

function GetEngageData(type, id)
	local data = data.engagedata[type]
	if not data then
		printerror("错误：找不到类型数据")
		return 
	end
	local id = tonumber(id)
	local t = data[id]
	if not t then
		printerror("错误：获取订婚数据，检查ID是否错误：", id)
		return 
	end
	return t
end

-- 宠物数据
function GetSummonInfo(sumid)
	if data.summondata.INFO[sumid] then
		return data.summondata.INFO[sumid]
	end
end

function GetSummonStoreInfo(sumid)
	if data.summondata.STORE[sumid] then
		return data.summondata.STORE[sumid]
	end
end

-- [[伙伴数据]]
function GetPartnerType(typeID)
	local partnerType = data.partnerdata.TYPE
	local typeInfo = partnerType[typeID]
	if typeInfo then
		return typeInfo
	end
	printerror("错误：获取伙伴类型数据，检查伙伴类型ID是否错误：", typeID)
end

function GetPartnerInfo(partnerID)
	local partnerInfo = data.partnerdata.INFO
	local partner = partnerInfo[partnerID]
	if partner then
		return partner
	end
	printerror("错误：获取伙伴数据，检查伙伴ID是否错误：", partnerID)
end

function GetpartnerInfoByItemID(itemid)
	local partnerInfo = data.partnerdata.INFO
	for _,v in pairs(partnerInfo) do
		if itemid == v.cost.id then
			return v
		end
	end
end

function GetPartnerProp(partnerID)
	local partnerProp = data.partnerdata.PROP
	local propInfo = partnerProp[partnerID]
	if propInfo then
		return propInfo
	end
	printerror("错误：获取伙伴属性数据，检查伙伴ID是否错误：", partnerID)
end

function GetPartnerUpperInfo(upperID)
	return data.partnerdata.UPPER[upperID]
end

function GetHuodongData(nameinfo)
	return data.huodongdata[nameinfo]
end

function GetPartnerQualityInfo(qualityID)
	return data.partnerdata.QUALITY[qualityID]
end

function GetPartnerSpecialSkill(skillID)
	return data.partnerdata.SKILL[skillID]
end

function GetPartnerPoint(partnerID, quality)
	quality = quality or 1
	local partnerPoint = data.partnerdata.POINT
	local pointInfo = partnerPoint[partnerID]
	if pointInfo then
		return pointInfo[quality]
	end
	printerror("错误：获取伙伴一级属性，检查伙伴ID是否错误", partnerID)
end

function GetPartnerUpperLimit(partnerID, upperID)
	local partnerUpperLimit = data.partnerdata.UPPERLIMIT
	local upperLimitInfo = partnerUpperLimit[partnerID]
	if upperLimitInfo then
		return upperLimitInfo[upperID]
	end
	printerror("错误：获取伙伴突破数据，检查伙伴ID是否错误", partnerID)
end

function GetPartnerQualitycost(partnerID, qualityID)
	local partnerQualityCost = data.partnerdata.QUALITYCOST
	local qualityCostInfo = partnerQualityCost[partnerID]
	if qualityCostInfo then
		return qualityCostInfo[qualityID]
	end
	printerror("错误：获取伙伴进阶数据，检查伙伴ID是否错误", partnerID)
end

function GetPartnerSkillUnlock(partnerID)
	--TODO:准备修改，由partnerID+skillID返回解锁等级
	local partnerSkillUnlock = data.partnerdata.SKILLUNLOCK
	local skillUnlockInfo = partnerSkillUnlock[partnerID]
	if skillUnlockInfo then
		local list = {}
		for k,v in pairs(skillUnlockInfo) do
			table.insert(list, v)
		end
		local function sort(data1, data2)
			return data1.class < data2.class
		end 
		table.sort(list, sort)
		return list
	end
	printerror("错误：获取伙伴技能解锁数据，检查伙伴ID是否错误：", partnerID)
end

function GetPartnerSkillUnlockGrade(partnerID, skillID)
	local dSkillData = data.partnerdata.SKILL[skillID]
	if dSkillData and dSkillData.protect == 1 then
		printc("警告：护主技能无解锁等级，技能ID", skillID)
		return 
	end
	local dInfo = GetPartnerSkillUnlock(partnerID)
	if dInfo then
		for _,v in pairs(dInfo) do
			for _,sk in pairs(v.unlock_skill) do
			 	if skillID == sk then
			 		return v.class
			 	end
			end 
		end
	end
	printerror("错误：获取伙伴技能解锁等级数据，检查伙伴技能ID是否错误：", skillID)
end

function GetPartnerskillUpgrade(skillID)
	local partnerSkillUpgrade = data.partnerdata.SKILLUPGRADE
	local skillUpgradeInfo = partnerSkillUpgrade[skillID]
	if skillUpgradeInfo then
		return skillUpgradeInfo
	end
	printerror("错误：获取伙伴技能升级数据，检查技能ID是否错误：", skillID)
end

function GetPartnerEquipInfo(partnerID, pos)
	local partnerEquip = data.itempartnerequipdata.PARTNEREQUIP
	for _,v in pairs(partnerEquip) do
		if v.partnerid == partnerID and v.equippos == pos then
			return v
		end
	end
	printerror("错误：获取伙伴装备数据，检查伙伴ID是否错误：", partnerID)
end

function GetPartnerSuiltInfo(partnerID)
	return data.partnerdata.SUILT[partnerID]
end

function GetPartnerTextInfo(textID)
	return data.partnerdata.TEXT[textID]
end

function GetPartnerExpInfo(itemid)
	return data.partnerdata.EXP[itemid]
end

function GetPartnerProtectSKill(partnerID, school)
	local dData = data.partnerdata.PROTECTSKILL[partnerID]
	if dData then
		for k,skill in pairs(dData.protect_skill_list) do
			if skill.school == school then
				return skill.skill_id
			end
		end
	end
end

function GetPartnerProtectSKillList(partnerID)
	local dData = data.partnerdata.PROTECTSKILL[partnerID]
	if dData then
		return dData.protect_skill_list
	end
	printerror("错误：获取伙伴护主数据，检查伙伴ID是否错误：", partnerID)
end

function GetPartnerProtectSKillEff(skillId, lv)
	local dSkill = data.partnerdata.SKILL[skillId]
	if table.count(dSkill.skill_effect) == 0 or lv == 0 then
		printc("无效果")
		return nil
	end
	local list = string.split(dSkill.skill_effect[1], "=")
	local formula = string.gsub(list[2], "level", lv)
	local func = loadstring("return " .. formula)
	return {attr = list[1], value = func()}
end

function GetPartnerCellItem(iItemID)
	if iItemID >= 30600 and iItemID <= 30611 then
		return iItemID + 30
	end 
end

function GetPartnerEquipStrengthInfo(iStrengthLv, iEquipPos)
	if not iStrengthLv or iStrengthLv == 0 then
		return
	end
	local dEquip = GetPartnerEquipData(iEquipPos)
	local dStrengthData = {}
	
	local sFormula = string.gsub(dEquip.strength_formula, "lv", iStrengthLv)
	local func = loadstring("return "..sFormula) 
	return func()
end

function GetPartnerEquipUpgradeInfo(iUpgardeLv, iEquipPos)
	if not iUpgardeLv or iUpgardeLv == 0 then
		return
	end
	local dEquip = GetPartnerEquipData(iEquipPos)

	local sFormula = string.gsub(dEquip.attr_formula, "lv", iUpgardeLv)
	local func = loadstring("return "..sFormula) 
	return func()
end

function GetPartnerEquipData(iEquipPos)
	local iIndex = data.partnerdata.POS2EQUIP[iEquipPos]
	return data.partnerdata.PARTNEREQUIP[iIndex]
end

function GetPartnerEquipIcon(iEquipPos, iLevel)
	local dData = GetPartnerEquipData(iEquipPos)
	local iIconId = 0
	for i,v in ipairs(dData.icon) do
		if iLevel < v.lv then
			break
		end
		iIconId = v.icon
	end
	return iIconId
end

-- [[任务数据]]
function GetTaskType(tasktype)
	if tasktype then
		local typeInfo = data.taskdata.TASKTYPE[tasktype]
		if typeInfo then
			return typeInfo
		end
	end
	return {
		name = '未导表任务分类信息:' .. (tasktype or "nil"),
		id = tasktype,
	}
end

function GetTaskData(taskid)
	if taskid then
		local task = data.taskdata.TASK
		for _,v in pairs(task) do
			if v.TASK and v.TASK[taskid] then
				return v.TASK[taskid]
			end
		end
	end
	return {
		name = '未导表任务:' .. taskid,
		id = taskid,
	}
end

function GetTaskNpc(npctype)
	local taskData = data.taskdata.TASK
	for _,v in pairs(taskData) do
		if v and v.NPC and v.NPC[npctype] then
			return v.NPC[npctype]
		end
	end
	return {
		name = '未导表任务Npc:' .. npctype,
		id = npctype,
		notNpc = true,
	}
end

function GetTaskNpcByTaskType(npctype, tasktype)
	local taskData = data.taskdata.TASK[tasktype]
	if taskData and taskData.NPC and taskData.NPC[npctype] then
		return taskData.NPC[npctype]
	end
	return {
		name = '未导表任务Npc:' .. npctype,
		id = npctype,
		notNpc = true,
	}
end

function GetTaskPick(pickid)
	if data.taskdata.TASKPICK[pickid] then
		return data.taskdata.TASKPICK[pickid]
	end

	printerror("没有找到任务采集物品，使用默认配置，查看导表是否有误。ID -> ", pickid)
	return {
		id = pickid or 1001,
		name = '未导表任务Pick:' .. pickid,
		finishTip=[[采集完成]],
		useTime=3,
		usedTip=[[采集中]],
	}
end

function GetTaskItem(itemid)
	if data.taskdata.TASKITEM[itemid] then
		return data.taskdata.TASKITEM[itemid]
	end

	printerror("没有找到任务使用物品，使用默认配置，查看导表是否有误。ID -> ", itemid)
	return {
		description=[[未导表任务Item]],
		finishTip=[[使用完成]],
		icon=10001,
		id = itemid or 10001,
		name = '未导表任务Item:' .. (itemid or ""),
		useTime=3,
		usedTip=[[使用中]],
	}
end

-- [[奖励数据]]
function GetReward(rewardType, rewardID)
	local rewardData = data.rewarddata[rewardType]

	if rewardType == "FIGHTGIFTBAG" then  --战力礼包奖品数据
		for k, v in pairs(rewardData) do
			if v.idx == rewardID then
				return v
			end
		end
		printerror("没有找到奖励类型，查看导表是否有误。类型：", rewardType)
		return
	end


	if not rewardData then
		printerror("没有找到奖励类型，查看导表是否有误。类型：", rewardType)
		return
	end
	local id = tonumber(rewardID)
	if not id then
		printerror("错误：不合法的任务奖励ID：", rewardID)
		return
	end
	if rewardData[id] then
		return rewardData[id]
	end
	printerror("没有找到任务奖励，查看导表是否有误。类型 -> | ID -> ", rewardType, rewardID)
	return
end

-- [[日程数据]]
function GetScheduleData(scheduleid)
	local dataList = data.scheduledata.SCHEDULE
	if dataList[scheduleid] then
		return dataList[scheduleid]
	end

	printerror("没有找到对应下标日程ID，查看导表是否有误。scheduleid -> ", scheduleid)
end

--[[活动技能]] --目前只有画舫灯谜
function GetScheduleSkill(skilltype)
	if data.scheduledata[skilltype] then
		return data.scheduledata[skilltype]
	else
		printerror("活动技能导表不存在@策划填表")
	end
end

-- [[挂机]]
--@param level 角色等级
--@param isKF 跨服限制
function GetAutoteamData(level, isKF)
	local result = {}
	for k,v in pairs(data.teamdata.CATALOG) do
		if v.unlock_level <= level and (not isKF or (isKF and v.is_kf == 1) ) then
			table.insert(result, v)
		end
	end
	local sort = function(data1, data2)
		return data1.sort < data2.sort
	end
	table.sort(result, sort)
	return result
end

function GetSubAutoteamData(parentId, level)
	local result = {}
	local subList = data.teamdata.CATALOG[parentId].subcat
	for k,v in ipairs(subList) do
		local subdata = data.teamdata.AUTO_TEAM[v]
		if subdata.unlock_level <= level then
			table.insert(result, subdata)
		end
	end
	return result
end

function GetStoreData(storeid)
	if storeid == define.Currency.Type.GoldCoin then
		return data.storedata.GOLDCOINSTORE
	elseif storeid == define.Currency.Type.Gold then
		return data.storedata.GOLDSTORE
	elseif storeid == define.Currency.Type.Silver then
		return data.storedata.SILVERSTORE
	end	
end

function GetGlobalData(key)
	local info = data.globaldata.GLOBAL[key]
	if info then
		return info
	end
	return {
		name = '未导表全局配置信息:' .. key,
		id = key,
	}
end

function GetInstructionInfo(instructionID)
	return data.instructiondata.DESC[instructionID]
end

-- [[装备打造数据相关]]
function GetEquipData(iSid, iRoleType, iSchool, iSex, iLevel, iPos, iRace)
	local dEquip = data.itemequipdata.EQUIP[iSid]
	local dData = dEquip
	iSchool = iSchool or -1
	iSex = iSex or -1
	iLevel = iLevel or -1
	iPos = iPos or -1
	iRace = iRace or -1
	if iRoleType ~= -1 and dEquip.roletype ~= 0 and dEquip.roletype ~= iRoleType then
		dData = nil
	end 
	if iRace ~= -1 and dEquip.race ~= 0 and dEquip.race ~= iRace then
		dData = nil
	end 
	if iSex ~= -1 and dEquip.sex ~= 0 and dEquip.sex ~= iSex then
		dData = nil
	end 
	if iSchool ~= -1 and dEquip.school ~= 0 and dEquip.school ~= iSchool then
		dData = nil
	end
	if iPos ~= -1 and dEquip.equipPos ~= iPos then
		dData = nil
	end
	local equipLevel = tonumber(dEquip.equipLevel)
	if iLevel ~= -1 and 
		(equipLevel < iLevel or equipLevel >= iLevel + 10) then --该过滤条件不确定
		dData = nil
	end
	return dData
end

--获取指定门派、部位、等级的装备列表
--@param iRoleType 
--@param iSchool 门派,全部门派为-1
--@param iPos 装备部位，全部位为-1
--@param iLevel 装备等级，全等级为-1
function GetEquipListByLevel(iRoleType, iSchool, iSex, iLevel, iPos, iRace)
	iSchool = iSchool or -1
	iSex = iSex or -1
	iLevel = iLevel or -1
	iPos = iPos or -1
	iRace = iRace or -1
	local result = {}
	for k,v in pairs(data.itemequipdata.EQUIP) do
		local euqipData = GetEquipData(v.id, iRoleType, iSchool, iSex, iLevel, iPos, iRace)
		if euqipData then
			table.insert(result, euqipData)
		end
	end
	function sort(data1, data2)
		return data1.id < data2.id
	end
	table.sort(result, sort)
	return result
end

--获取装备洗炼的条件
--@param iPos 装备位置
--@param iLevel 装备等级 
function GetWashInfo(iPos, iLevel)
	for k,v in pairs(data.equipdata.WASH) do
		if v.level == iLevel and v.pos == iPos then
			return v 
		end
	end
	return nil
end

--获取装备洗炼最低等级
function GetEquipWashLvLimit()
	return data.equipdata.HELPER.WashLimit
end

--获取武器属性的波动范围
--return result table {min, max}
function GetEquipAttrRange()
	local result = {}
	local iMin = 100
	local iMax = 100
	for k,v in pairs(data.equipdata.EQUIP_LEVEL) do
		iMin = math.min(iMin, v.min)
		iMax = math.max(iMax, v.max)
	end
	result.min = iMin
	result.max = iMax
	return result
end

--获取物品的分解结果 装备or神魂可分解,分解数据不同
--return result table
function GetDecomposeList(citem)
	local result = {}

	local tData = nil
	local dSoulDecompose = {}
	for k,v in pairs(data.equipdecomposedata.EQUIP_DECOMPOSE) do
		if citem:GetCValueByKey("equipPos") == v.pos and 
			citem:GetCValueByKey("equipLevel") == v.level and
			citem:GetSValueByKey("itemlevel") == v.quality then
			tData = v
			if citem:HasAttachSoul() then
				for _,id in ipairs(tData.hunfenjie_list) do
					dSoulDecompose[id] = true
				end
			end
			break
		end
	end
	if tData then
		for k,v in pairs(data.equipdecomposedata.DECOMPOSE_DATA) do
			if v.fenjie_id == tData.fenjie_id then
				table.insert(result, {sid = v.sid, minAmount = v.minAmount, maxAmount = v.maxAmount, cost = 0})
			end
			if dSoulDecompose[v.fenjie_id] then
				table.insert(result, {sid = v.sid, minAmount = v.minAmount, maxAmount = v.maxAmount, cost = 0})
			end
		end
		return result
	end

	tData = GetItemData(citem.m_SID)
	if tData then
		for i,v in ipairs(tData.deCompose) do
			table.insert(result, {sid = v.sid, minAmount = v.amount, maxAmount = v.amount, cost = 0})
		end
	end

	return result
end

function GetGemStoneDecomposeByItemList(litem)
	local rewardDict = {}
	for i,dItem in ipairs(litem) do
		local result = GetGemStoneDecomposeList(dItem.item)
		for i,dReward in ipairs(result) do
			if rewardDict[dReward.gemStoneId] then
				local dInfo = rewardDict[dReward.gemStoneId]
				dInfo.minAmount = dInfo.minAmount + dReward.minAmount * dItem.amount
				dInfo.maxAmount = dInfo.maxAmount + dReward.maxAmount * dItem.amount
				dInfo.cost = dInfo.cost + dReward.cost * dItem.amount
			else
				dReward.minAmount = dReward.minAmount * dItem.amount
				dReward.maxAmount = dReward.maxAmount * dItem.amount
				dReward.cost = dReward.cost * dItem.amount
				rewardDict[dReward.gemStoneId] = dReward
			end
		end
	end
	local rewardList = {}
	for k,v in pairs(rewardDict) do
		table.insert(rewardList, v)
	end
	local function sort(d1, d2)
		return d1.gemStoneId < d2.gemStoneId
	end
	table.sort(rewardList, sort)
	return rewardList
end

function GetGemStoneDecomposeList(citem)
	local result = {}
	if citem:IsGemStone() then
		local iColor = data.hunshidata.ITEM2COLOR[citem.m_SID]
		local iGrade = citem:GetSValueByKey("hunshi_info").grade
		local dColor = data.hunshidata.COLOR[iColor]
		local lAttr = citem:GetSValueByKey("hunshi_info").addattr
		if iGrade > 1 or dColor.level == 2 then
			result = GetGemStoneDecomposeResult(iColor, iGrade, lAttr)
		end
	elseif citem:IsEquip() then
		--TODO:装备的魂石分解服务器暂时不做
		-- for i=1,3 do
		-- 	local dInfo = citem:GetInlayItemByPos(i)
		-- 	if dInfo then
		-- 		local list = GetGemStoneDecomposeResult(dInfo.color, dInfo.grade, dInfo.addattr)
		-- 		for i,v in ipairs(list) do
		-- 			table.insert(result, v)
		-- 		end
		-- 	end
		-- end
	end
	return result
end

function GetGemStoneDecomposeResult(iColor, iGrade, lAttr)
	local function GetAttrKey(iColor)
		local iAttrKey = 0
		for i,sAttr in ipairs(lAttr) do
			local dAttr = GetGemStoneAttrDataByColor(iColor, sAttr)
			if dAttr then
				iAttrKey = dAttr.attr_key + iAttrKey
			end
		end
		return iAttrKey
	end
	--TODO:后期补上属性显示
	local result = {}
	local dColor = data.hunshidata.COLOR[iColor]
	local formula = dColor.compose_money
	formula = string.gsub(formula, "lv", iGrade)
	local func = loadstring("return "..formula)
	local iCost = func()
	if dColor.level == 1 then
		local iAttrKey = GetAttrKey(iColor)
		local iGemStoneId = dColor.itemsid + (iGrade - 1)*define.Item.GemStoneId + iAttrKey*define.Item.GemStoneAttrId
		table.insert(result, {sid = dColor.itemsid, minAmount = 1, maxAmount = 3, grade = iGrade - 1, 
			cost = iCost, attrkey = iAttrKey, gemStoneId = iGemStoneId})
	else 
		for i,iColor in ipairs(dColor.son) do
			local iAttrKey = GetAttrKey(iColor)
			local iSid = data.hunshidata.COLOR[iColor].itemsid
			local iGemStoneId = iSid + iGrade*define.Item.GemStoneId + iAttrKey*define.Item.GemStoneAttrId
			table.insert(result, {sid = iSid, minAmount = 1, maxAmount = 1, grade = iGrade, cost = iCost, 
				attrkey = iAttrKey, gemStoneId = iGemStoneId})
		end
	end
	return result
end

--获取指定部位的强化效果
--@param iPos 装备部位
--@param iLevel 强化等级
--@return table
function GetEquipStrengthData(iPos, iLevel)
	for k,v in pairs(data.equipdata.STRENGTH) do
		if v.pos == iPos and v.strengthLevel == iLevel then
			local func = loadstring("return "..v.strength_effect) 
			return func()
		end
	end
	return nil
end

--获取指定部位的强化所需材料
--@param iPos 装备部位
--@param iLevel 强化等级
--@return table
function GetEquipStrengthMaterial(iPos, iLevel)
	for k,v in pairs(data.equipdata.STRENGTH_MATERIAL) do
		if v.pos == iPos and v.level == iLevel then
			return v
		end
	end
end

function GetEquipSpecialSkillList(iEquipLv)
	local list = {}
	for i,v in ipairs(data.equipdata.EQUIP_SK) do
		if iEquipLv == v.grade then
			table.insert(list, v.sk)
		end
	end
	return list
end

function GetEquipSpecialEffectList(iEquipLv, iEqupPos)
	local list = {}
	for i,v in ipairs(data.equipdata.EQUIP_SE) do
		if (v.pos == 99 or v.pos == iEqupPos) and v.grade == iEquipLv then
			table.insert(list, v.se)
		end
	end
	return list
end

--获取角色的门派信息
function GetRoleTypeInfo(iRoleType)
	return data.roletypedata.DATA[iRoleType]
end

function GetRaceBySchool(iSchool)
	local dData = data.schooldata.DATA[iSchool]
	if dData then
		return dData.race
	end
	return -1
end

function GetRoletype(iSex, iRace)
	for roletype,dRole in ipairs(data.roletypedata.DATA) do
		if dRole.sex == iSex and dRole.race == iRace then
			return roletype
		end
	end
	return -1
end

function GetSchoolInfo(schoolID)
	return data.schooldata.DATA[schoolID]
end

--获取装备附加属性计算公式相关
--@param iSchool 门派属性库编号
function GetEquipAttachAttrData(iSchool)
	local result = {}
	for i,dInfo in ipairs(data.equipdata.ATTACH_ATTR) do
		if dInfo.attachId == iSchool then
			local list = string.split(string.gsub(dInfo.attachAttr[1], "[{}]", ""), "=")
			local iMin = -1
			local iMax = -1
			for i,v in ipairs(dInfo.attr_ratio) do
				if iMin == -1 then
					iMin = v.min
				end
				if iMax == -1 then
					iMax = v.max
				end
				iMax = math.max(iMax, v.max)
				iMin = math.min(v.min, iMin)
			end
			result[list[1]] = {formula = list[2], minRatio = iMin, maxRatio = iMax}
		end
	end
	return result
end

function GetEquipStrengthRatioBySe(iSe)
	if iSe == 6010 then
		-- skill_effect={[1]=[[{strength_add_ratio=20}]],},
		local dData = data.skilldata.SPECIAL_EFFC[iSe]
		local list = string.split(string.gsub(dData.skill_effect[1], "[{}]", ""), "=")
		return 1 + list[2]/100
	end
	return 1
end

--获取装备强化突破数据
--@param iPos 部位
--@param iBreakLv 突破等级
function GetEquipStrengthBreak(iPos, iBreakLv)
	for i,dInfo in ipairs(data.equipdata.STRENGTH_BREAK) do
		if dInfo.pos == iPos and iBreakLv == dInfo.break_lv then
			return dInfo
		end
	end
	return nil
end

function GetDecomposeResultByItemList(tItemList)
	local rewardDict = {}
	for i,dItem in ipairs(tItemList) do
		local result = GetDecomposeList(dItem.item)
		for i,dReward in ipairs(result) do
			if rewardDict[dReward.sid] then
				local dInfo = rewardDict[dReward.sid]
				dInfo.minAmount = dInfo.minAmount + dReward.minAmount * dItem.amount
				dInfo.maxAmount = dInfo.maxAmount + dReward.maxAmount * dItem.amount
			else
				-- {sid = v.sid, minAmount = v.minAmount, maxAmount = v.maxAmount}
				dReward.minAmount = dReward.minAmount * dItem.amount
				dReward.maxAmount = dReward.maxAmount * dItem.amount
				rewardDict[dReward.sid] = dReward
			end
		end
	end
	local rewardList = {}
	for k,v in pairs(rewardDict) do
		table.insert(rewardList, v)
	end
	local function sort(d1, d2)
		return d1.sid < d2.sid
	end
	table.sort(rewardList, sort)
	return rewardList
end

--获取装备附魂积分数据
function GetEquipSoulPointData(iGrade)
	local iCurGrade = math.floor(iGrade/10)*10 
	local tData = data.equipdata.SOUL_POINT[iCurGrade]
	return tData
end

--获取指定门排的强化大师数据
function GetEquipStrengthMaster(iSchool, iMasterLv)
	for i,v in ipairs(data.equipdata.STRENGTH_MASTER) do
		if v.school == iSchool and iMasterLv == v.master_level then
			return v
		end
	end
end

function GetEquipStrengthMasterLv(iSchool, iStrengthLv)
	local iCurLv = 0
	for i,v in pairs(data.equipdata.STRENGTH_MASTER) do
		if v.school == iSchool and iStrengthLv >= v.all_strength_level then
			iCurLv = math.max(iCurLv, v.master_level)
		end
	end
	return iCurLv
end

function GetEquipSoulEffectRange(iEquipLv)
	if iEquipLv%10 ~= 0 then
		iEquipLv = math.floor(iEquipLv/10)*10
	end
	local dData = data.equipdata.SOUL_EFFECT[iEquipLv]
	if not dData then
		return 0,0
	end
	local iMin = 100
	local iMax = 0
	for i,v in ipairs(dData.attr_ratio) do
		iMax = math.max(iMax, v.max)
		iMin = math.min(iMin, v.min)
	end
	return iMin, iMax
end

-- [[帮派数据相关]]
--获取指定等级帮派的职位上限
--@param iOrgLv 帮派等级
--@param iPos 职位Id
function GetOrgAppointUpper(iOrgLv, iPos)
	local sKey = data.orgdata.POSITIONID[iPos].pinyin
	local tData = data.orgdata.POSITIONLIMIT[iOrgLv]
	if tData[sKey] then
		return tData[sKey]
	else
		return 1
	end
end

--获取对应mapid的场景名字
function GetSceneNameByMapId(mapid)
	for k,v in pairs(data.mapdata.SCENE) do
		if v.map_id == mapid then
			return v.scene_name
		end
	end
	return ""
end

--获取对应mapid的场景数据
function GetSceneDataByMapId(mapid)
	for k,v in pairs(data.mapdata.SCENE) do
		if v.map_id == mapid then
			return v
		end
	end
	return nil
end

function GetNextOrgActivity(week, time)
	local targetWeek = week == 0 and 7 or week
	local activitylist = data.orgdata.WEEKACTIVITY[targetWeek]
	if #activitylist > 0 then
		for i,v in ipairs(activitylist) do
			if time <= v.time or i == #activitylist then
				return v
			end
		end
	end
end

-- [[阵法数据相关]]
--获取阵型站位的属性信息
--@param iFtmId 阵法ID
function GetFormationAttrList(iFtmId)
	local list = data.formationdata.ATTRINFO
	local result = {}
	for k,attrInfo in pairs(list) do
		if attrInfo.fmt_id == iFtmId then
			result[attrInfo.pos] = attrInfo
		end
	end
	return result
end

--获取阵型站位的增益效果
--@param iFtmId 阵法ID
--@param iPos 布阵站位
--@param iFtmLv 阵法等级
function GetFormationEffect(iFtmId, iPos, iFtmLv)
	local list = GetFormationAttrList(iFtmId)
	if table.count(list) == 0 or iFtmLv <= 0 then
		return nil
	end
	local dData = list[iPos]
	local result = {}
	local iIndex = 1
	for _,dAttr in pairs(dData.base_attr) do
		local sName,bIsRatio = GetAttrName(dAttr.attr_name)
		if sName then
			local sFormula = string.replace(dAttr.formula, "lv", iFtmLv)
			local func = loadstring("return "..sFormula)
			local iValue = func()
			result[dAttr.attr_name] = {name = sName, value = iValue, isRatio = bIsRatio, index = iIndex}
			iIndex = iIndex + 1
		end
	end
	local dTempData = {}
	for _,dExtAttr in ipairs(dData.ext_attr) do
		if iFtmLv >= dExtAttr.level then
			local sName,bIsRatio = GetAttrName(dExtAttr.attr_name)
			if sName then
				dTempData = {key = dExtAttr.attr_name, name = sName, value = dExtAttr.ratio, isRatio = bIsRatio}
				if dTempData.key then
					local sKey = dTempData.key
					if result[sKey] then
						result[sKey].value = result[sKey].value + dTempData.value
					else
						result[sKey] = {name = dTempData.name, value = dTempData.value, isRatio = dTempData.isRatio, index = iIndex}
					end
				end
			end
		end
	end
	
	local lEffect = {}
	for k,v in pairs(result) do
		lEffect[v.index] = v
	end
	return lEffect
end

function GetAttrName(sKey)
	local bIsRatio = false
	local sName = ""
	local tData = data.attrnamedata.DATA[sKey]
	if tData then
		sName = tData.name
	end
	if string.find(sKey, "ratio") then
		bIsRatio = true
	end
	if not sName and bIsRatio then
		local result = string.split(sKey, "_ratio")
		if result[1] then
			sName = data.attrnamedata.DATA[result[1]]
		end
	end
	return sName, bIsRatio
end

--返回阵法升级道具信息
--@param iFtmId 阵法ID
function GetFormationItemExpData(iFtmId)
	local result = nil
	for k,v in pairs(data.formationdata.ITEMINFO) do
		if v.fmt_id == iFtmId then
			result = {itemid = k, data = v}  
			return result
		end
	end
	return nil
end

--计算阵法升级道具的总经验
--@param iFtmId 阵法ID
--@param tItemList 道具列表
function CalculateItemExpByFormationId(iFtmId, tItemList)
	local iSumExp = 0
	for _,dItem in pairs(tItemList) do
		local dInfo = data.formationdata.ITEMINFO[dItem.sid]
		if dInfo.fmt_id == iFtmId then
			iSumExp = iSumExp + dInfo.exp * dItem.amount
		else
			iSumExp = iSumExp + dInfo.other_exp * dItem.amount
		end
	end
	return iSumExp
end

--获取升级后的阵法等级
--@param iFtmId 阵法ID
--@param iCurExp 阵法当前经验
--@param iCurGrade 阵法当前等级
--@param iAddExp 阵法增加经验
function GetFormationGrade(iFtmId, iCurExp, iCurGrade, iAddExp)
	local dBaseInfo = data.formationdata.BASEINFO[iFtmId]
	local iUpgardeExp = dBaseInfo.exp[iCurGrade]
	if not iUpgardeExp or dBaseInfo.id == 1 then
		return iCurGrade, iCurExp
	end
	local iNewGrade = iCurGrade
	local iNewExp = iCurExp + iAddExp
	local iMaxGrade = #dBaseInfo.exp
	local iMaxExp = dBaseInfo.exp[iMaxGrade - 1]
	local remainExp = iNewExp
	for grade,needExp in ipairs(dBaseInfo.exp) do
		if grade >= iCurGrade then
			if grade ~= iMaxGrade then
				remainExp = iNewExp - needExp
			end
			if remainExp >= 0 and iNewGrade ~= iMaxGrade then
				iNewExp = remainExp
				iNewGrade = grade + 1
			end
		end
	end
	iNewExp = math.min(iNewExp, iMaxExp)
	local bIsMaxGrade = remainExp >= 0 and iMaxGrade == iNewGrade 
	if bIsMaxGrade then
		iNewExp = 0
	end
	return iNewGrade, iNewExp, bIsMaxGrade
end

--获取角色等级可解锁的阵法数量
--@param iGrade 玩家等级
function GetFormationUnlockSizeByGrade(iGrade)
	local iSize = 1
	for i,dInfo in ipairs(data.formationdata.USEINFO) do
		if iGrade < dInfo.grade then
			break
		end 
		iSize = dInfo.num
	end
	return iSize
end

function GetFormationIdByItem(iItemid)
	local dData = data.formationdata.ITEMINFO[iItemid]
	if not dData or dData.fmt_id == 10 then
		return 1
	end
	return dData.fmt_id
end

-- [[交易数据相关]]
--获取交易系统商品子目录
--@param iCatalogId 父目录ID
--@param iType 系统类型 1-摆摊目录 2-商会目录 3-拍卖目录
--@param iSlv 服务器开发等级
function GetEcononmySubCatalogListById(iCatalogId, iType, iSlv)
	local source = data.stalldata.SUBCATALOG
	if iType == define.Econonmy.Type.Guild then
		source = data.guilddata.SUBCATALOG
	elseif iType == define.Econonmy.Type.Auction then
		source = data.auctiondata.SUBCATALOG
	end
	local list = {}
	for i,dInfo in ipairs(source) do
		if dInfo.cat_id == iCatalogId and dInfo.slv <= iSlv then
			table.insert(list, dInfo)
		end
	end
	local function sort(dInfo1, dInfo2)
		return dInfo1.subcat_id < dInfo2.subcat_id
	end
	table.sort(list, sort)
	return list
end

function GetEcononmyStallCatalogList()
	local list = {}
	for i,dData in ipairs(data.stalldata.CATALOG) do
		if not list[dData.cat_id] then
			list[dData.cat_id] = {cat_id = dData.cat_id, cat_name = dData.cat_name}
		end
	end
	return list
end

function GetEcononmyGuildCatalogIndex(iCatalogId)
	local list = {}
	for i,dData in ipairs(data.guilddata.CATALOG) do
		if dData.cat_id == iCatalogId then
			return i
		end
	end
	return -1
end

--返回摆摊物品id PS:摆摊的id是由普通sid*1000+品质段组成
--@param iItemid 物品id
--@param iQuality 物品品质
--@return 
function ConvertItemIdToStallId(iItemid, iQuality)
	local iStallItemId = iItemid*1000 + math.floor((iQuality - 1)/10)
	local bExist = data.stalldata.ITEMINFO[iStallItemId] ~= nil
	if bExist then
		return iStallItemId
	else
		return iItemid*1000
	end
end

--获取拍卖物品的数据
--@param itemid 物品id
function GetAuctionItemData(iItemid)
	local list = data.auctiondata.MAP[iItemid]
	if not list then
		return
	end
	return data.auctiondata.ITEMINFO[list[1]]
end

--获取任务物品对应的摆摊or商会目录
--@param iType 系统类型 1-摆摊目录 2-商会目录 3-拍卖目录
--@param itemlist 任务物品列表
function GetEcononmyCatalogListByTaskItems(iType, tItemList)
	local dSource = data.stalldata.ITEMINFO
	if iType == define.Econonmy.Type.Guild then
		dSource = data.guilddata.ITEMINFO
	elseif iType == define.Econonmy.Type.Auction then
		dSource = data.auctiondata.ITEMINFO
	end
	local dExist = {} 
	local tCatalogList = {}
	for i,iItemId in ipairs(tItemList) do
		if iType == define.Econonmy.Type.Stall then
			iItemId = ConvertItemIdToStallId(iItemId, 1)
		elseif iType == define.Econonmy.Type.Guild then
			local dGoodData = data.guilddata.ITEM2GOOD[iItemId]
			iItemId = dGoodData and dGoodData[1] or -1
		end
		local dItemInfo = dSource[iItemId]
		if dItemInfo then
			
			local iTempCatalogId = dItemInfo.cat_id
			if iType == define.Econonmy.Type.Guil then
				iTempCatalogId = dItemInfo.cat_id*100 + dItemInfo.sub_id
			end
			if not dExist[iTempCatalogId] and dItemInfo.cat_id ~= 0 then
				table.insert(tCatalogList, {cat_id = dItemInfo.cat_id, sub_id = dItemInfo.sub_id})
				dExist[iTempCatalogId] = true
			end
		end
	end

	return tCatalogList
end

--获取物品对应摆摊的目录信息
function GetEcononmyStallCatalogByItem(iItemid)
	local iStallId = DataTools.ConvertItemIdToStallId(iItemid, 1)
	local dData = data.stalldata.ITEMINFO[iStallId]
	if dData then
		return dData.cat_id, 0
	end
end

--获取物品对应商会的目录信息
function GetEcononmyGuildCatalogByItem(iItemid)
	local dData = GetEcononmyGuildItem(iItemid)
	if dData then
		return dData.cat_id, dData.sub_id
	end
end

--获取物品对应拍卖的目录信息
function GetEcononmyAuctionCatalogByItem(iItemid)
	local dData = data.auctiondata.ITEMINFO[iItemid]
	if dData then
		return dData.cat_id, dData.sub_id
	end
end

--获取物品对应交易所的目录信息
--@param iItemid 物品sid
--@return 目录类型，父目录id，子目录id
function GetEcononmyCatalogByItem(iItemid)
	local iCatalogId, iSubCatalogId = GetEcononmyStallCatalogByItem(iItemid)
	if iCatalogId then
		return define.Econonmy.Type.Stall, iCatalogId, iSubCatalogId
	end
	iCatalogId, iSubCatalogId = GetEcononmyGuildCatalogByItem(iItemid)
	if iCatalogId then
		return define.Econonmy.Type.Guild, iCatalogId, iSubCatalogId
	end
	iCatalogId, iSubCatalogId = GetEcononmyAuctionCatalogByItem(iItemid)
	if iCatalogId then
		return define.Econonmy.Type.Auction, iCatalogId, iSubCatalogId
	end
end

function GetEcononmyGuildItem(iItemid)
	local lGoodId = data.guilddata.ITEM2GOOD[iItemid]
	if not lGoodId then
		return
	end
	return data.guilddata.ITEMINFO[lGoodId[1]]
end

function GetSysName(sType)
	local system = define.System
	for k, v in pairs(system) do
		if v == sType then
			return k
		end
	end
	return nil
end

-- [[View定义相关]]
--获取界面的详细定义
--@param sSysName 系统中文名（策划使用）
function GetViewDetailDefine(sSysName)
	local dData = data.viewdefinedata.DETAIL_DEFINE[sSysName]
	if dData then
		return dData
	end
	return nil
end

--通过获取界面的详细定义
--@param iSysId 系统唯一标识
function GetViewDetailDefineById(iSysId)
	local sSysName = data.viewdefinedata.MAP[iSysId]
	if not sSysName then
		return nil
	end
	return data.viewdefinedata.DETAIL_DEFINE[sSysName]
end

--获取系统定义
--@param sSysEName 系统英文名（程序使用）
function GetViewDefine(sSysEName)
	local dData = data.viewdefinedata.DEFINE[sSysEName]
	return dData
end

--获取指定系统的标签页ID
--@param sSysEName 系统英文名（程序使用）
--@param sTab 标签页英文名
function GetTabIdBySystem(sSysEName, sTab)
	local dData = GetViewDefine(sSysEName)
	if dData then
		return dData.tab[sTab]
	end
	return -1
end

--获取指定系统的标签页ID
--@param sClsName 系统类名（程序使用）
--@param sTab 标签页名
function GetTabIdByClsName(sClsName, sTab)
	local sSysEName = data.viewdefinedata.CLS2SYS[sClsName]
	if not sSysEName then
		return -1
	end
	local dData = data.viewdefinedata.DEFINE[sSysEName]
	if not dData then
		return -1
	end
	return dData.tab[sTab]
end

function GetOpenSystemByCls(sClsName)
	if not data.viewdefinedata.CLS2SYS[sClsName] then
		return nil
	end
	for k,dViewdefine in pairs(data.viewdefinedata.DETAIL_DEFINE) do
		if dViewdefine.cls_name == sClsName then
			--printc("GetOpenSystemByCls",sClsName,dViewdefine.open_sys)
			return dViewdefine.open_sys
		end
	end
end

-- [[武林盟主数据相关]]
--获取指定阶段的详细信息
--@param iStartTime 开始时间
--@param iStep 当前阶段
--@return iRemainTime 剩余时间
--@return iSetpTime 当前阶段时间
function GetWorldBossStepInfo(iStep, iStartTime)
	local iDiffTime = os.difftime(g_TimeCtrl:GetTimeS(), iStartTime)
	local tConfigList = data.worldbossdata.DATA[1].step_config
	local iStepTime = 0
	local iElapseTime = 0
	local iSumStepTime = 0
	for i,dStepInfo in ipairs(tConfigList) do
		-- if i < iStep then
		-- 	iSumStepTime = iSumStepTime + dStepInfo.time * 60
		-- elseif i == iStep then
		-- 	iStepTime = dStepInfo.time * 60
		-- 	break
		-- end
		--TODO:三段时间改成一段显示
		iStepTime = iStepTime + dStepInfo.time * 60
	end
	iRemainTime = iStepTime - (iDiffTime - iSumStepTime) 
	return iRemainTime, iStepTime
end

function GetWorldBossText(iTextId, lReplaceKey, lReplaceValue)
	local dText = data.worldbossdata.TEXT[iTextId]
	if dText then
		local sText = dText.content
		if not lReplaceKey or not lReplaceValue then
			return sText
		elseif type(lReplaceKey) ~= "table" then
			local sKey = lReplaceKey
			local sValue = lReplaceValue
			lReplaceKey = {[1] = sKey}
			lReplaceValue = {[1] = sValue}
		end
		for i,key in ipairs(lReplaceKey) do
			local sValue = lReplaceValue[i]
			sText = string.gsub(sText, key, sValue)
		end
		return sText
	end
	return ""
end


--编辑器下才刷新数据 Start
function RefreshData()
	GenDynamicAtlas()
	-- GenEditorData()
	-- GenLineupGridData()
end

function GenEditorData()
	local sOut = "module(...)\n"
	local lMagicFiles = {}
	local selList = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic/magic/magicfile"), "*.lua", true)
	for i, v in pairs(selList) do
		local p = IOTools.GetFileName(v, true)
		local _, ID1, Idx1 = unpack(string.split(p, "_"))
		table.insert(lMagicFiles, {ID1, Idx1})
	end
	local function sortfunc(t1, t2)
		if t1[1] == t2[1] then
			return tonumber(t1[2]) < tonumber(t2[2])
		else
			return tonumber(t1[1]) < tonumber(t2[1])
		end
	end
	table.sort(lMagicFiles, sortfunc)
	sOut = sOut.."--DataTools.GenEditorData生成数据\n%s"
	sOut = string.format(sOut, table.dump(lMagicFiles, "MAGIC_FILE"))
	local sOutPath = IOTools.GetAssetPath("/Lua/logic/datauser/editordata.lua")
	local fileobj = io.open(sOutPath, "w")
	fileobj:write(sOut)
	fileobj:close()
end

function SaveLineupData()
	local dSavedata = data.lineupdata
	local sOut = "module(...)\n"
	sOut = sOut.."--editorLineup生成数据\n"
	local lKeys = {"LINEUP_TYPE", "PRIOR_POS"}
	for i, v in ipairs(lKeys) do
		sOut = sOut..table.dump(dSavedata[v], v).."\n"
	end
	sOut = sOut.."--DataTools.GenLinupGridData(r, c)生成数据\n%s\n%s"
	sOut = string.format(sOut, table.dump(dSavedata.GRID_POS_MAP, "GRID_POS_MAP"), table.dump(dSavedata.GRID_POS_KEY, "GRID_POS_KEY"))
	
	local sOutPath = IOTools.GetAssetPath("/Lua/logic/data/lineupdata.lua")
	local fileobj = io.open(sOutPath, "w")
	
	fileobj:write(sOut)
	fileobj:close()
	g_NotifyCtrl:FloatMsg("站位保存成功!"..sOutPath)
end

function GenLineupGridData()
	local col = 10
	local row = 10
	local base = {}
	local minPos = Vector3.New(-3.88, 0, -5.0)
	local maxPos = Vector3.New(3.08, 0, 2.1)
	
	for r = 1, row do
		local z = Mathf.Lerp(minPos.z, maxPos.z, (r-1)/(row-1))
		local t = {}
		for c = 1, col do
			local x = Mathf.Lerp(minPos.x, maxPos.x, (c-1)/(col-1))
			t[c] = {x=x, z=z}
		end
		base[r] = t
	end
	-- tostring(r)..'-'..tostring(c)'
	--	行 | 列
	local rA, cA = 3, col-2
	local rB, cB = row-2, 3
	local rc = {
		A1 = {r=rA,		c=cA},
		A2 = {r=rA-1,	c=cA-1},
		A3 = {r=rA+1,	c=cA+1},
		A4 = {r=rA-2,	c=cA-2},
		A5 = {r=rA+2,	c=cA+2},

		A6 = {r=rA+1,	c=cA-1},
		A7 = {r=rA+1-1,	c=cA-1-1},
		A8 = {r=rA+1+1,	c=cA-1+1},
		A9 = {r=rA+1-2,	c=cA-1-2},
		A10 = {r=rA+1+2,c=cA-1+2},

		A11 = {r=rA-1,	c=cA+1},
		A12 = {r=rA-1-1,c=cA+1-1},
		A13 = {r=rA-1+1,c=cA+1+1},
		A14 = {r=rA-2,	c=cA+2},

		B1 = {r=rB,		c=cB},
		B2 = {r=rB+1,	c=cB+1},
		B3 = {r=rB-1,	c=cB-1},
		B4 = {r=rB+2,	c=cB+2},
		B5 = {r=rB-2,	c=cB-2},

		B6 = {r=rB-1,	c=cB+1},
		B7 = {r=rB-1+1,	c=cB+1+1},
		B8 = {r=rB-1-1,	c=cB+1-1},
		B9 = {r=rB-1+2,	c=cB+1+2},
		B10 = {r=rB-1-2,c=cB+1-2},

		B11 = {r=rB+1,	c=cB-1},
		B12 = {r=rB+1+1,c=cB-1+1},
		B13 = {r=rB+1-1,c=cB-1-1},
		B14 = {r=rB+2,	c=cB-2},
	}
	local map = {}
	for k, v in pairs(rc) do
		map[k] = base[v.r][v.c]
	end
	-- local single = {
	-- 	AA1 = {"A5", "A6"},
	-- 	AA2 = {"A1", "A3"},
	-- 	AA3 = {"A1", "A2"},
	-- 	AA4 = {"A2", "A4"},

	-- 	BB1 = {"B5", "B6"},
	-- 	BB2 = {"B1", "B3"},
	-- 	BB3 = {"B1", "B2"},
	-- 	BB4 = {"B2", "B4"},
	-- }
	-- for k, v in pairs(single) do
	-- 	local pos1, pos2 = map[v[1]], map[v[2]] 
	-- 	map[k] = {x = (pos1.x+pos2.x)/ 2, z=(pos1.z+pos2.z)/2}
	-- end

	-- local dTemp = {
	-- 	["single"] = {
	-- 		[1]	= {[1]="XX3"},
	-- 		[2] = {[1]="XX3", [5]="XX1"},
	-- 		[3] = {[1]="XX3", [5]="X5", [2]="X6"},
	-- 		[4] = {[1]="XX3", [5]="XX1", [2]="XX2", [3]="XX4"},
	-- 		[5] = {[1]="XX3", [5]="X5", [2]="X6", [3]="XX2", [4]="XX4"},
	-- 	},
	-- 	["team"] = {
	-- 		[2] = {[1]="X1", [2]="X2", [3]="X3", [4]="X4", [5]="X5", [6]="X6"},
	-- 		[3] = {[1]="XX3", [2]="XX2", [3]="XX4", [4]="X6", [5]="X5", [6]="X7", [7]="X8"},
	-- 		[4] = {[1]="X1", [2]="X2", [3]="X3", [4]="X4", [5]="X5", [6]="X6", [7]="X7", [8]="X8"},
	-- 	}
	-- }
	local dData = {}
	-- for k, v in pairs(dTemp) do
	-- 	local t = {}
	-- 	for k1, v1 in pairs(v) do
	-- 		local t1 = {[1] = {[9]="A9", [10]="A10"}, [2] = {[9]="B9", [10]="B10"}}
	-- 		for k2, v2 in pairs(v1) do
	-- 			t1[1][k2] = string.gsub(v2, "X", "A")
	-- 			t1[2][k2] = string.gsub(v2, "X", "B")
	-- 		end
	-- 		t[k1] = t1
	-- 	end
	-- 	dData[k] = t
	-- end
	-- local sOut = "module(...)\n--DataTools.GenLinupGridData(r, c)生成数据\n%s\n%s"
	-- sOut = string.format(sOut, table.dump(map, "GRID_POS_MAP"), table.dump(dData, "GRID_POS_KEY"))
	-- local sOutPath = IOTools.GetAssetPath("/Lua/logic/data/lineupdata.lua")
	-- local fileobj = io.open(sOutPath, "w")
	-- fileobj:write(sOut)
	-- fileobj:close()
	data.lineupdata.GRID_POS_MAP = map
	data.lineupdata.GRID_POS_KEY = dData
	SaveLineupData()
end



function GenDynamicAtlas()
	local dict = {}
	local sFormat = "Atlas/DynamicAtlas/%s/%s.prefab"
	local function walk(dir, filename)
		local typename, idx = string.match(filename, "(%a+)Atlas(%d+)%.prefab$")
		idx = tonumber(idx)
		if typename and idx then
			if not dict[typename] then
				dict[typename] = {}
			end
			local atlasname = string.format("%sAtlas%d", typename, idx)
			local respath = string.format(sFormat, atlasname, atlasname)
			local prefab = C_api.ResourceManager.Load(respath)
			if prefab then
				local oComponent = prefab:GetComponent(classtype.UIAtlas)
				local arr = oComponent:GetListOfSprites()
				if arr then
					for j = 0, arr.Length - 1 do
						local key = tonumber(arr[j]) or arr[j]
						if key then
							dict[typename][key] = {atlas=atlasname, sprite=arr[j]}
						else
							print("ResInit Error", typename, idx, key)
						end
					end
				end
			end
		end
	end

	local datapath = UnityEngine.Application.dataPath
	local sPath = IOTools.GetGameResPath("/Atlas/DynamicAtlas")
	IOTools.WalkDir(sPath, walk)

	local sOut = "module(...)\n--DataTools.GenDynamicAtlas 生成数据\n%s"
	sOut = string.format(sOut, table.dump(dict, "DATA"))
	local sOutPath = IOTools.GetAssetPath("/Lua/logic/datauser/dynamicatlasdata.lua")
	IOTools.SaveTextFile(sOutPath, sOut)
	datauser.dynamicatlasdata.DATA = dict
end
--编辑器下才刷新数据 End

-- [[副本相关]]
--获取副本的详细信息
--@param iDungeonId 副本id
--@return result 
function GetDungeonData(iDungeonId)
	-- 精英副本
	if iDungeonId < 10 then
		if iDungeonId == 0 then
			iDungeonId = 1
		end
		return data.fubendata.ELITE[iDungeonId]
	else
		for k,v in pairs(data.fubendata.DATA) do
			if v.fuben_id == iDungeonId then
				return v
			end
		end
	end
	return nil
end

function GetDungeonMaxGradePoint(iDungeonId)
	local dData = GetDungeonData(iDungeonId)
	if not dData then
		return -1
	end
	local iMaxIndex = #dData.point_reward
	local iMaxPoint = dData.point_reward[iMaxIndex].point
	local iMaxGrade = dData.point_reward[iMaxIndex].level
	return iMaxPoint,iMaxGrade
end

function GetDungeonNextGradePoint(iDungeonId, sCurGrade)
	local dData = GetDungeonData(iDungeonId)
	if not dData then
		return -1
	end
	for i,dReward in ipairs(dData.point_reward) do
		if dReward.level == sCurGrade then
			return dReward.point
		end
	end
	return -1 
end

function GetDungeonRewardInfoByPoint(iDungeonId, iPoint)
	local dData = GetDungeonData(iDungeonId)
	if not dData then
		return
	end
	local dMaxReward
	for i,dReward in ipairs(dData.point_reward) do
		if dReward.point <= iPoint then
			dMaxReward = dData.point_reward[i+1] or dReward
		elseif dReward.point > iPoint then
			dMaxReward = dReward
			break
		end
	end
	return dMaxReward
end

function GetItemComposeSubCatalog(iCatalogId)
	local result = {}
	for i,v in ipairs(data.itemcomposedata.SUBCATALOG) do
		if v.cat_id == iCatalogId then
			table.insert(result, v)
		end
	end
	return result
end

function GetItemComposeCompound(sid)
	-- body
	local itemlsit 
	for _,v in pairs(data.itemcomposedata.ITEMCOMPOUND) do
		if sid == v.sid then
			itemlsit = v.sid_item_list
		end
	end
	return itemlsit
end

function GetWelfareData(sPart, sKey)
	local dData = data.welfaredata[sPart]
	if dData then
		if sKey then
			return dData[sKey]
		else
			return dData
		end
	end
end

function GetChargeData(sPart, sKey)
	local dData = data.chargedata[sPart]
	if dData then
		if sKey then
			return dData[sKey]
		else
			return dData
		end
	end
end

function GetCollectData(sPart, sKey)
	local dData = data.collectdata[sPart]
	if dData then
		if sKey then
			return dData[sKey]
		else
			return dData
		end
	end
end

function GetEffectData(sType, iEffectId)
	local dData = data.effectdata[sType]
	if dData then
		return dData[iEffectId]
	end
end

function GetLotteryData(sType, iKey)
	local dData = data.lotterydata[sType]
	if dData then
		if iKey then
			return dData[iKey]
		else
			return dData
		end
	end
end

--获取npcs商店的商品数据
function GetNpcShopData(ShopId)
	local ShopId = ShopId or 0
	if ShopId == 0 then
		return data.shopdata.NPCSHOP --所有商品
	else
		local data = data.shopdata.NPCSHOP
		local t = {} --不同商店对应的商品
		for k, v in pairs(data) do
			if v.shop_id == ShopId then
				t[k] = v
			end
		end
		return t
	end
end

function GetNpcStoreItemByShopId(iShopId, iItemid)
	for k , v in pairs(data.shopdata.NPCSHOP) do 
		if v.shop_id ~= nil and v.shop_id == iShopId then
			if v.item_id == iItemid then
				return v
			end
		end 
	end
end

function GetOrgTaskText(iID)
	local dData = data.huodongdata.ORGTASKTEXT[iID]
	if not dData then
		printerror("帮派任务text未导表",iID)
		return ""
	end
	return dData.content
end

-- [[魂石相关]]
--获取魂石的属性信息
--@param iItemid 物品sid
--@param iGrade 魂石等级
function GetGemStoneAttrData(iItemId, iGrade, sAttrKey)
	local iColor = data.hunshidata.ITEM2COLOR[iItemId]
	for i,v in ipairs(data.hunshidata.ATTR) do
		if v.color == iColor and v.attr == sAttrKey then
			local formula = v.attr_skill
			formula = string.gsub(formula, "lv", iGrade)
			local func = loadstring("return "..formula)
			local iValue = func()
			if v.attr == "seal_ratio"  or v.attr == "res_seal_ratio" then
				iValue = iValue * 10
			end
			local result = {key = sAttrKey, value = iValue}
			return result
		end
	end
end

--获取指定颜色魂石可合成的混色或可分解的纯色魂石列表
function GetRelateGemStoneList(iColor)
	local dData = data.hunshidata.COLOR[iColor]
	local result = {[1] = iColor}
	if dData.level == 1 then
		for i,v in ipairs(dData.father) do
			table.insert(result, v)
		end
	else
		for i,v in ipairs(dData.son) do
			table.insert(result, v)
		end
	end
	return result
end

function GetGemStoneItemData(iColor)
	local dData = data.hunshidata.COLOR[iColor]
	return GetItemData(dData.itemsid)
end

function GetGemStoneAttrList(iAttrKey)
	local lAttr = {}
	for key,attr in pairs(data.hunshidata.KEY2ATTR) do
		if MathBit.andOp(iAttrKey, key) ~= 0 then
			table.insert(lAttr, attr)
		end
	end
	return lAttr
end

function GetGemStoneAttrDataByColor(iColor, sAttrKey)
	local dAttr = data.hunshidata.COLOR2ATTR[iColor]
	return dAttr[sAttrKey]
end

function GetGemStoneMaxComposeLv()
	return #data.hunshidata.COMPOSE
end

function GetGemStoneMixColor(iColor_1, iColor_2)
	local dColor = {[iColor_1] = true, [iColor_2] = true}
	for i,v in ipairs(data.hunshidata.COLOR) do
		if v.level == 2 and dColor[v.son[1]] and dColor[v.son[2]] then
			return v
		end
	end
end

function GetGemStoneColorData(iItemid)
	local iColor = data.hunshidata.ITEM2COLOR[iItemid]
	return data.hunshidata.COLOR[iColor]
end

function GetGemStoneMaxEquipLimit()
	local iMaxLv = 0
	for i,v in pairs(data.hunshidata.EQUIPLIMIT) do
		iMaxLv = math.max(iMaxLv, v.maxlv)
	end
	return iMaxLv
end

function GetGemStoneEquipGradeLimit(iGemStoneLv)
	local iMinGrade = 999
	for i,v in pairs(data.hunshidata.EQUIPLIMIT) do
		if iGemStoneLv <= v.maxlv then
			iMinGrade = math.min(v.grade, iMinGrade)
		end
	end
	return iMinGrade
end

function GetGrowLevelInfo(id)
	-- body

	local dGrow 
	for i,v in pairs( data.promotedata.GROW) do
		if id == v.id  then
			dGrow = v
		end
	end
	return dGrow
	
end

function GetItemExchData(iItemid)
	return data.itemexchangedata.ITEM[iItemid]
end

function GetItemExchCostData(iExchId)
	return data.itemexchangedata.EXCHANGE[iExchId]
end

function GetBonfireWineReward(iWineCnt)
	local formula = data.rewarddata.ORGCAMPFIRE[1004].org_offer
	local formula = string.gsub(formula, "cnt", iWineCnt)
	local func = loadstring("return " .. formula)
	return func()
end

function GetNameColor(iType)
	return data.namecolordata.DATA[iType].color
end

function GetOnlineGiftData(sKey)
	sKey = sKey or "RewardItem"
	return data.onlinegiftdata[sKey]
end

-- 获取奖励物品数据(整合货币等虚拟道具)
function GetRewardItems(sType, id)
	local dReward = GetReward(sType, id)
	if not dReward then return end
	local itemList = {}
	local trimFunc = function(sKey, itemId)
		local cnt = dReward[sKey]
		if cnt and string.len(cnt) > 0 then
			cnt = tonumber(cnt) or cnt
			if cnt == 0 then
				return
			end
			table.insert(itemList, {
				amount = cnt,
				sid = itemId,
			})
		end
	end
	local virtuals = {
		{key = "gold", item = 1001},
		{key = "exp", item = 1005},
		{key = "summexp", item = 1007},
		{key = "silver", item = 1002},
		{key = "goldcoin", item = 1003},
	}
	for i, v in ipairs(virtuals) do
		trimFunc(v.key, v.item)
	end
	for i, v in ipairs(dReward.item) do
		table.insert(itemList, v)
	end
	return itemList
end

function GetEveryDayChargeItemList(rewardKey, flag)
	local itemList = {}	
	
	local addFunc = function(id, strAmount)
		if strAmount then
			local amount = tonumber(strAmount)
			if amount and amount > 0 then
				table.insert(itemList,{sid = id, count = amount})
			end
		end
	end
	
	local everyDayChargeInfo = data.everydaychargedata.REWARD[flag]
	if everyDayChargeInfo == nil or table.count(everyDayChargeInfo) == 0 then
		return itemList
	end

	-- for k, v in pairs(everyDayChargeInfo) do
		-- if k == "rewardlist" then
			-- local id = v[day]
	local id = everyDayChargeInfo[rewardKey]
	if id ~= nil then
		local everyDayChargeRewardInfo = data.rewarddata.EVERYDAYCHARGE[id]
		--printc(everyDayChargeRewardInfo)
		--table.print(everyDayChargeRewardInfo, "everyDayChargeRewardInfo")
		for ssk, ssv in pairs(everyDayChargeRewardInfo) do
			if ssk == "item" then
				for sssk, sssv in ipairs(ssv) do
					local amount
					local itemarg = sssv.itemarg
					if itemarg and string.len(itemarg) > 0 then
						amount = string.match(itemarg, "%(Value=(%d+)%)")
					else
						amount = sssv.amount
					end
					table.insert(itemList, {sid = sssv.sid, count = amount})
				end
			elseif ssk == "exp" then
				addFunc(1005, ssv)
			elseif ssk == "gold" then
				addFunc(1001, ssv)
			elseif ssk == "goldcoin" then
				addFunc(1003, ssv)
			elseif ssk == "silver" then
				addFunc(1002, ssv)
			elseif ssk == "summexp" then
				addFunc(1007, ssv)
			else
				--table.print("ssk == elseother", "RRRRRRRRRRRRRRRRR")
			end
		end
	end
	return itemList
end

function GetEveryDayChargeFlagToNumber(flag)
	local everyDayChargeInfo = data.everydaychargedata.REWARD[flag]
	local number = tonumber(everyDayChargeInfo["dbkey"])
	return number
end

function GetCaishenData(id, sGroup)
	for i, v in ipairs(data.lotterydata.CAISHEN_COST) do
		if v.key == id and v.group_key == sGroup then
 			return v
		end
	end
end

function GetScoreShopByItem(iSid)
	for shopid,v in pairs(data.scoredata.SHOP) do
		for i,dItem in pairs(v) do
			if dItem.itemsid == iSid then
				return shopid
			end
		end
	end
	return 101
end

function GetQiFuRewardList(id)
	
	local rewardlist = data.rewarddata.QIFUREWARD[id]

	if not rewardlist then 
		return
	end 

	local list = {}
	for k, v in ipairs(rewardlist.item) do 
		local temp = {}
		local config = data.rewarddata.QIFUITEMREWARD[v]
		if config then 
			if  string.find(config.sid, "Value") then 
				local sid, amount = string.match(config.sid,"^(%d+)%(Value=(%d+)%)")
				temp.sid = sid
				temp.amount = amount
			else
				temp.sid = config.sid
				temp.amount = config.amount
			end 
			table.insert(list, temp)
		end 
	end 

	return list

end

function GetWarFailInfo(lv)
	local warfailshow = data.warfailconfigdata.WARFAILSHOW
	if lv >= warfailshow[#warfailshow].maxlv then
		return warfailshow[#warfailshow]
	end
	for _,v in ipairs(warfailshow) do
		if lv >= v.minlv and lv < v.maxlv then
			return v
		end
	end
end

function IsWenShiComposeMat(id)
	local config = data.itemwenshidata.COLOR_CONFIG
	for k, v in pairs(config) do 
	    local composeList = v.decompose_got
	    for j, i in pairs(composeList) do 
	        if i.sid == id then 
	            return true
	        end 
	    end 
	end
end
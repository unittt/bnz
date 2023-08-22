local CTask = class("CTask")

function CTask.ctor(self, taskData)
	self.m_SData = {}
	for k,v in pairs(taskData) do
		self.m_SData[k] = v
	end
	-- self.m_SData = taskData
	-- self.m_CData = DataTools.GetTaskData(taskData.taskid)
	local taskID = taskData.taskid
	self.m_CTaskDataGetter = function() return DataTools.GetTaskData(taskID) end
	self.m_TaskType = DataTools.GetTaskType(self:GetCValueByKey("type"))
	self.m_Finish = self:GetSValueByKey("isreach") == 1 and true or false
	self.m_ProgresID = nil
end

function CTask.GetSValueByKey(self, k)
	return self.m_SData[k]
end

function ConvertTblToStr(tbl)
    local str = "{"
    local Head = true
    if type(tbl) == "table" then
        for key,value in pairs(tbl) do
            if not Head then
                str = str .. ","
            else
                Head = false
            end
            if type(key) == "number" then
                    str = str .. "["..key .."]="
            else
                    str = str.. "['"..key .."']="
            end
            if  value == nil then
                str = str .."nil,"
            elseif type(value) == "boolean" then
                str = str ..tostring(value)
            elseif type(value) == "number" then
                str = str .. value
            elseif type(value) == "table" then
                str = str ..ConvertTblToStr(value)
            elseif type(value) == "string" then
                str = str .."\""..value.."\""
            else
                str = str .. type(value)
            end
        end
    else
        print("ConvertTblToStr failed,param is not a table,it is a "..type(tbl))
    end
    str = str.."}"
    return str
end

function CTask.GetCValueByKey(self, k)
	-- printc("========",ConvertTblToStr(self.m_CTaskDataGetter()))
	return self.m_CTaskDataGetter()[k]
end

function CTask.RefreshTask(self, dict)
	local t = {}
	for k , v in pairs(dict) do
		if self[k] ~= v then
			self[k] = v
			t[k] = v
		end
	end
	return t
end

--获取是否是可接任务
function CTask.GetIsAceTask(self)
	if self:GetSValueByKey("isacetask") then
		return true
	end
	return false
end

--是否可放弃
function CTask.IsAbandon(self)
	return self.m_TaskType.dropable > 0
end

function CTask.GetLegendTime(self)
	local oExtInfo = self:GetSValueByKey("ext_apply_info")
	if not oExtInfo then
		return
	end
	for k,v in pairs(oExtInfo) do
		if v.key == "legend_left_time" then
			return v.value
		end
	end
end

function CTask.GetLimitQuality(self)
	local oExtInfo = self:GetSValueByKey("ext_apply_info")
	if not oExtInfo then
		return
	end
	for k,v in pairs(oExtInfo) do
		if v.key == "equip_quality_max" then
			return v.value
		end
	end
end

function CTask.GetAllowBB(self)
	local oExtInfo = self:GetSValueByKey("ext_apply_info")
	if not oExtInfo then
		return
	end
	for k,v in pairs(oExtInfo) do
		if v.key == "summon_allow_bb" then
			return true
		end
	end
end

--是否指定任务行为种类
function CTask.IsTaskSpecityAction(self, actionType)
	if not actionType then
		printerror("无效的任务行为类型")
		return
	end
	local taskAction = self:GetCValueByKey("tasktype")
	return taskAction == actionType
end

--是否指定任务类别(主线、支线、师门、捉鬼等)
function CTask.IsTaskSpecityCategory(self, categoryType)
	if not categoryType then
		printerror("无效的任务类别类型")
		return
	end
	local taskCategory = self:GetCValueByKey("type")
	return taskCategory == categoryType.ID
end

function CTask.GetTaskItemPre(self)
	local extStrDic = self:GetTaskClientExtStrDic()
	if extStrDic and extStrDic.itempre then
		return extStrDic.itempre
	end
end

--分步骤的任务
function CTask.GetProgressThing(self)
	if self.m_Finish then
		return
	else
		local thingList = nil
		if self:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_PICK) then
			thingList = self:GetSValueByKey("pickitem")
		elseif self:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_USE) then
			thingList = self:GetSValueByKey("taskitem")
		end
		if thingList and #thingList > 0 then
			self.m_ProgresID = self.m_ProgresID or 1
			return thingList[self.m_ProgresID]
		else
			self.m_Finish = true
			return
		end
	end
end

function CTask.GetStep(self)
	if self.m_Finish then
		return
	else
		local thingList = nil
		if self:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_PICK) then
			thingList = self:GetSValueByKey("pickitem")
		elseif self:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_USE) then
			thingList = self:GetSValueByKey("taskitem")
		end
		if thingList and #thingList > 0 then
			self.m_ProgresID = self.m_ProgresID or 1
			return #thingList - self.m_ProgresID
		end
	end
end

function CTask.RaiseProgressIdx(self, idx)
	if idx and idx > 0 then
		self.m_ProgresID = idx
	else
		self.m_ProgresID = (self.m_ProgresID or 0) + 1
	end
end

----------------以下是返回true或false的判断---------------

--判断这个task是否与服务器发过来的npcid相关
function CTask.AssociatedNpc(self, npcid)
	if not self.m_SData or not npcid or npcid < 0 then
		return
	end
	local npc = g_MapCtrl:GetNpc(npcid)
	if not npc then
		npc = g_MapCtrl:GetDynamicNpc(npcid)
	end
	if not npc then
		return
	end

	--npctype是配置里面的npc的id，npcid是服务器发过来的npc的id
	--先判断所有人都能看到的npc
	if npc.classname == "CNpc" then
		local funcgroup = npc.m_NpcAoi.func_group
		local npctype = npc.m_NpcAoi.npctype
		if funcgroup == self:GetSValueByKey("func_group") then
			if npctype == self:GetSValueByKey("target") then
				return true
			elseif npctype == self:GetCValueByKey("submitNpcId") then
				return true
			else
				if self:IsTaskSpecityCategory(define.Task.TaskCategory.SHIMEN) then
					local extStrDic = self:GetTaskClientExtStrDic()
					if extStrDic and extStrDic.submitnpc and extStrDic.submitnpc == "School" then
						local schoolNpcID = CTaskHelp.GetSchoolNpcID()
						if npctype == schoolNpcID then
							return true
						end
					end
				end
			end
		end
	--然后判断自己才能看到的动态npc
	elseif npc.classname == "CDynamicNpc" then
		local clientnpc = self:GetSValueByKey("clientnpc")
		if clientnpc and #clientnpc > 0 then
			for _,v in ipairs(clientnpc) do
				if v.npcid == npcid then
					return true
				end
			end
		end
	end
end

--判断这个可接任务task是否与服务器发过来的npcid相关
--以后要根据需求修改
function CTask.AceTaskAssociatedNpc(self, npcid)
	if g_TaskCtrl:GetIsSpecialAceTask(self:GetSValueByKey("taskid")) then
		return
	end
	if not self.m_SData or not npcid or npcid < 0 then
		return
	end
	local npc = g_MapCtrl:GetNpc(npcid)
	if not npc then
		return
	end
	if npc.classname == "CNpc" then
		local npctype = npc.m_NpcAoi.npctype
		if npctype == self:GetSValueByKey("target") then
			return true
		end
	end
end

--判断这个任务的submitNpcId是否与服务器发过来的npcid相关
function CTask.AssociatedSubmit(self, npcid)
	if not self.m_SData or not npcid or npcid < 0 then
		return
	end
	local npc = g_MapCtrl:GetNpc(npcid)
	if not npc then
		return
	end
	-- 师门需要判断是否school
	if npc.classname == "CNpc" then
		local npctype = npc.m_NpcAoi.npctype
		if self:GetCValueByKey("submitNpcId") == npctype then
			return true
		else
			if self:IsTaskSpecityCategory(define.Task.TaskCategory.SHIMEN) then
				local extStrDic = self:GetTaskClientExtStrDic()
				if extStrDic and extStrDic.submitnpc and extStrDic.submitnpc == "School" then
					local schoolNpcID = CTaskHelp.GetSchoolNpcID()
					if npctype == schoolNpcID then
						return true
					end
				end
			end
		end
	end
end

--判断这个task是否是TASK_ITEM_PICK类型并且服务器发过来的数据等于这个pickid
function CTask.AssociatedPick(self, pickid)
	if not self.m_SData or not pickid or pickid < 0 then
		return
	end
	if not self:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_PICK) then
		return
	end
	local pickItem = g_MapCtrl:GetTaskPickItem(pickid)
	if not pickItem then
		return
	end

	if pickItem.classname == "CTaskPickItem" then
		local pickThing = self:GetProgressThing()
		if pickThing and pickThing.pickid == pickid then
			return true
		end
	end
end

--检查寻物任务是否Finish
function CTask.CheckFindItemFinish(self)
	if not self:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM) then
		return
	end

	local finish = true
	local needitem = self:GetSValueByKey("needitem")
	local needitemgroup = self:GetSValueByKey("needitemgroup")
	local oLimitQuality = self:GetLimitQuality()
	if needitem and #needitem > 0 then
		for _,v in ipairs(needitem) do
			local amount = g_ItemCtrl:GetBagItemAmountBySid(v.itemid, oLimitQuality)
			-- printc("当前拥有物品数量，任务需求数量：", amount, v.amount)
			if amount < v.amount then
				finish = false
				break
			end
		end
	elseif needitemgroup and #needitemgroup > 0 then
		for _,v in ipairs(needitemgroup) do
			local amount = g_ItemCtrl:GetBagItemAmountByGroupid(v.groupid, oLimitQuality)
			-- printc("当前拥有物品数量，任务需求数量：", amount, v.amount)
			if amount < v.amount then
				finish = false
				break
			end
		end
	end
	-- printc("当前m_Finish, 计算finish：", self.m_Finish, finish)
	if self.m_Finish ~= finish then
		self.m_Finish = finish
		return true
	end
end

--检查寻宠任务是否Finish
function CTask.CheckFindSummonFinish(self)
	if not self:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON) then
		return
	end

	local finish = true
	local needsum = self:GetSValueByKey("needsum")
	local summons = g_SummonCtrl:GetSummons()

	if needsum and #needsum > 0 and next(summons) then
		for _,v in ipairs(needsum) do
			local summonCount = 0
			for _,summonData in pairs(summons) do
				if self:GetAllowBB() then
					if summonData.typeid == v.sumid and summonData.key ~= 1 and (summonData.type == 1 or (summonData.type == 2 and summonData.zhenpin == 0)) and summonData.id ~= g_SummonCtrl.m_FightId then --or summonData.grade == 0
						summonCount = summonCount + 1
					end
				else
					if summonData.typeid == v.sumid and summonData.key ~= 1 and (summonData.type == 1) and summonData.id ~= g_SummonCtrl.m_FightId then --or summonData.grade == 0
						summonCount = summonCount + 1
					end
				end				
			end
			if summonCount < v.amount then
				finish = false
				break
			end
		end
	else
		finish = false
	end
	-- printc("当前m_Finish, 计算finish：", self.m_Finish, finish)
	if self.m_Finish ~= finish then
		self.m_Finish = finish
		return true
	end
end

--获取配置里面的任务扩展字段
function CTask.GetTaskClientExtStrDic(self)
	local extStrDic = {}
	local extStr = self:GetCValueByKey("clientExtStr")
	if not extStr or string.len(extStr) <= 0 then
		return
	end
	local extStrList = string.split(extStr, ",")
	for _,v in ipairs(extStrList) do
		local termList = string.split(v, ":")
		if #termList == 2 and not extStrDic[termList[1]] then
			extStrDic[termList[1]] = termList[2]
		else
			printerror("错误：任务扩展字段配置错误，没有匹配的Key，任务ID：", self:GetSValueByKey("taskid"))
		end
	end
	return extStrDic
end

return CTask
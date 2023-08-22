module(..., package.seeall)

-- 获取是寻物或寻宠任务的时候，打开商店界面时要选中的item数据
g_ClickTaskShopSelect = nil

-- 点击主界面或任务界面的任务按钮，寻路到npc时直接执行该任务
g_ClickTaskExecute = nil

----------------以下是点击事件-------------------

--客户端点击任务逻辑处理（寻路，提交等）
-- 18.05.25 添加一个参数：dothing，用于在请求服务器时如果有自定义的fun，就用自定义的，否者请求服务器
function ClickTaskLogic(oTask, dothing)
	if not oTask then
		printerror("无效的任务参数 Nil")
		return
	end
	if g_GuideHelpCtrl.m_GuideInfoInit then
		if not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("hasplay") and not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("notplay") then
			return
		end
	end
	if g_LimitCtrl:CheckIsCannotMove() then
		return
	end

	local isItemPick = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_PICK)
	local isItemUse = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_USE)
	local isItemFind = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM)
	local isSummonFind = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON)
	local taskid = oTask:GetSValueByKey("taskid")
	local recordTask = false

	if isItemFind or isSummonFind then
		local isNeedSelect = true
		if isItemFind then
			local tItemList = g_TaskCtrl:GetTaskNeedItemList(oTask, true)
			if not tItemList or not next(tItemList) then
				isNeedSelect = false
			end
		end
		if isSummonFind then
			local tSummonList = g_TaskCtrl:GetTaskNeedSumList(oTask, true)
			if not tSummonList or not next(tSummonList) then
				isNeedSelect = false
			end
		end
		if isNeedSelect then
			g_ClickTaskShopSelect = oTask
		else
			g_ClickTaskShopSelect = nil
		end
	else
		g_ClickTaskShopSelect = nil
	end
	-- table.print(GetClickTaskShopSelect(), "选择的任务数据")
	if isItemPick or isItemUse then
		if oTask.m_Finish then
			-- nettask.C2GSCommitTask(taskid)
			nettask.C2GSStepTask(taskid, 0)
		else
			local taskThing = oTask:GetProgressThing()
			if taskThing then
				if g_LimitCtrl:CheckIsLimit(true, true) then
			    	return
			    end
				if CTaskHelp.IsSpecityCurMap(taskThing.map_id) then
					local pathFindEndFunc = nil
					local progressFunc = function (thing)
						g_NotifyCtrl:ShowProgress(function ()
							if thing.qteid and thing.qteid ~= 0 then
								g_InteractionCtrl.m_InteractionResultType = define.Yibao.InteractionResultType.Shimen
								g_InteractionCtrl.m_InteractionTaskData = oTask
								g_InteractionCtrl.m_InteractionQteid = thing.qteid
								g_InteractionCtrl.m_InteractionTotalTime = nil
								for k,v in pairs(data.interactiondata.QTEDATA) do
									if v.id == g_InteractionCtrl.m_InteractionQteid then
										g_InteractionCtrl.m_InteractionQteConfig = v
										break
									end
								end
								CInteractionView:ShowView(function (oView)
									oView:SetContent()
								end)
							else
								local tipStr = ((thing.finishTip and string.len(thing.finishTip) > 0) and {thing.finishTip} or {"任务完成"})[1]
								g_NotifyCtrl:FloatMsg(thing.finishTip)
								if isItemPick then
									-- 清除PickModel
									g_TaskCtrl:DoCheckPickModel(oTask, false)
								end

								local step = oTask:GetStep()
								oTask:RaiseProgressIdx()
								nettask.C2GSStepTask(taskid, step)
								if step == 0 then
									oTask.m_Finish = true
								else
									-- 刷新面板\重新生成PickModel
									g_TaskCtrl:RefreshSpecityBoxUI({task = oTask})
									g_TaskCtrl:DoCheckPickModel(oTask, true)
									g_TaskCtrl:RefreshPickItem()
								end

								if isItemPick and not oTask.m_Finish then
									CTaskHelp.ClickTaskLogic(oTask)
								end
							end

							if isItemUse then
								if thing.effect and thing.effect ~= "" then
									g_NotifyCtrl:ShowScreenEffect(thing.effect)
								end
							end

							-- if thing.finishTip and string.len(thing.finishTip) > 0 then
							-- end
						end, thing.usedTip, thing.useTime)
					end

					if isItemPick then
						-- printc("TODO >>> 采集逻辑处理")
						pathFindEndFunc = function()
							g_MapCtrl:UpdateHeroPos()
							local itemPick = DataTools.GetTaskPick(taskThing.pickid)
							if itemPick then
								progressFunc(itemPick)
							else
								printerror("导表错误，无法找到任务采集物品 ID：", taskThing.pickid)
							end
						end
					elseif isItemUse then
						-- printc("TODO >>> 使用物品逻辑处理")
						pathFindEndFunc = function()
							g_MapCtrl:UpdateHeroPos()
							local itemUse = DataTools.GetTaskItem(taskThing.itemid)
							if itemUse then
								CTaskItemQuickUseView:ShowView(function(oView)
									if oView then
										local quickUseFunc = function ()
											progressFunc(itemUse)
										end
										oView:SetQuickUseTaskItem(taskThing, itemUse, quickUseFunc, itemUse.countTime)
									end
								end)
							else
								printerror("导表错误，无法找到任务使用物品 ID：", taskThing.itemid)
							end
						end
					else
						printc("TODO >>> 其他的逻辑啊。。。")
					end

					if taskThing.pos_x >= 100 then
						taskThing.pos_x = 25
						taskThing.pos_y = 21
					end

					local pos = Vector2.New(taskThing.pos_x, taskThing.pos_y)
					CTaskHelp.PathFindToPos(pos, pathFindEndFunc)
				else					
					recordTask = true
        			g_MapCtrl:C2GSClickWorldMap(taskThing.map_id)
				end
			end
		end
	else
		--抓鬼的不需要
		if not (oTask:GetCValueByKey("type") == define.Task.TaskCategory.GHOST.ID or (oTask:GetCValueByKey("type") == define.Task.TaskCategory.ORG.ID and not (isItemFind or isSummonFind))
		or oTask:GetSValueByKey("taskid") == g_TaskCtrl:GetYibaoMainTaskid().taskid) then
			g_ClickTaskExecute = oTask
		end
		if g_MapCtrl.m_IsMapLoadDone then
			if dothing then
				dothing()
			else
				nettask.C2GSClickTask(taskid)
			end
		end 
	end
	g_TaskCtrl:SetRecordLogic(recordTask and oTask or nil)
end

--日程打开任务逻辑
function ScheduleTaskLogic(taskCategoryType)
	--先处理特殊的任务,如异宝
	if taskCategoryType == define.Task.TaskCategory.YIBAO.ID then
		if g_TaskCtrl.m_TaskDataDic[g_TaskCtrl:GetYibaoMainTaskid().taskid] then
			CTaskHelp.ClickTaskLogic(g_TaskCtrl.m_TaskDataDic[g_TaskCtrl:GetYibaoMainTaskid().taskid])
		else
			nettask.C2GSYibaoAccept()
		end
		return
	end

	local taskTypeDic = g_TaskCtrl.m_TaskCategoryTypeDic[taskCategoryType]
	local _, oTask = next(taskTypeDic)
	if oTask then
		-- 存在任务，直接开始寻路
		CTaskHelp.ClickTaskLogic(oTask)
		return
	end

	CTaskHelp.WalkToGlobalNpc(taskCategoryType)
end

function WalkToGlobalNpc(taskCategoryType)
	local endFunc
	if taskCategoryType == define.Task.TaskCategory.XUANSHANG.ID then
		endFunc = function ()			
			nettask.C2GSOpenXuanShangView()
		end
	end

	-- 检查到没有任务，开始寻路到接取任务Npc处
	local taskTypeInfo = DataTools.GetTaskType(taskCategoryType)
	local npcid = taskTypeInfo.npcid
	if npcid > 0 then
		if npcid < 100 then
			-- 当npcid小于100，判定为虚拟npcid（门派npcid）
			npcid = DataTools.GetSchoolNpcID(g_AttrCtrl.school)
		end
		g_MapTouchCtrl:WalkToGlobalNpc(npcid, endFunc)
	end
end

--喊话逻辑处理 --PS:其实可以直接弄虚拟道具走itemuse的逻辑就行
function ExcuteSayTask(sessionidx, channel, msg)
	local taskThing = {
		map_id = g_MapCtrl.m_MapID,
		pos_x = g_MapCtrl.m_Hero:GetPos().x,
		pos_y = g_MapCtrl.m_Hero:GetPos().y,
		radius = 3,
	}
	local itemUse = {
		icon = 10030,
		name = "喊话",
		quality = 0,
	}
	CTaskItemQuickUseView:ShowView(function(oView)
		if oView then
			local quickUseFunc = function ()
				-- netchat.C2GSChat(msg, channel)
				g_NotifyCtrl:ShowProgress(function()
					netother.C2GSCallback(sessionidx)
				end, nil, 2)
			end
			oView:SetQuickUseTaskItem(taskThing, itemUse, quickUseFunc)
		end
	end)
end

---------------以下是获取配置相关------------------

function GetTaskTitleDesc(oTask)
	local hideTaskType = oTask:IsTaskSpecityCategory(define.Task.TaskCategory.GHOST) or oTask:IsTaskSpecityCategory(define.Task.TaskCategory.YIBAO) 
	or oTask:IsTaskSpecityCategory(define.Task.TaskCategory.LINGXI) or oTask:IsTaskSpecityCategory(define.Task.TaskCategory.FUBEN) 
	local prefix = hideTaskType and "" or (oTask.m_TaskType.name .. "-")
	local suffix = oTask:GetSValueByKey("name")
	if oTask:IsTaskSpecityCategory(define.Task.TaskCategory.STORY) then
		local chapterTitle = data.taskdata.TASKCHAPTER[oTask:GetCValueByKey("linkid")]
		if chapterTitle then
			return string.format("[FF9600]%s %s", chapterTitle.name, chapterTitle.title)
		end
		return string.format("[FF9600]%s%s", prefix, suffix)
	elseif oTask:IsTaskSpecityCategory(define.Task.TaskCategory.SCHOOLPASS) then	
		prefix = ""
	end
	return string.format("[FFDE00]%s%s", prefix, suffix)
end

function GetChapterData(oTask)
	local title
	for k,v in ipairs(data.taskdata.TASKCHAPTER) do
		if v.head == oTask:GetSValueByKey("taskid") then
			title =  v
		end
	end
	if title and title.id > 1 then
		return title
	end
	return
end

function GetTargetDesc(oTask)
	if oTask:GetSValueByKey("taskid") == g_LingxiCtrl:GetLingxiTaskId() then
		local lingxiDesc = string.format("[ccebdb]%s", "灵犀任务描述")
		if g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsLeader() then
			if g_LingxiCtrl.m_Phase == 1 then
				if g_MapCtrl:CheckInLingxiSeedArea(g_MapCtrl:GetHero()) then --[FF4128]
					lingxiDesc = string.format("[ccebdb]%s", "请耐心等待队员前来汇合")
				else
					local oItemData = oTask:GetSValueByKey("taskitem")[1]
					local oMapInfo = DataTools.GetSceneDataByMapId(oItemData.map_id)
					lingxiDesc = string.format("[ccebdb]%s", "请前往"..string.format(define.Task.AceTaskColor.Map, oMapInfo.scene_name.."("..
					math.floor(oItemData.pos_x)..","..math.floor(oItemData.pos_y)..")").."，#G情花#n种植点")
				end
			elseif g_LingxiCtrl.m_Phase == 2 then
				if g_MapCtrl:CheckInLingxiSeedArea(g_MapCtrl:GetHero()) then
					lingxiDesc = string.format("[ccebdb]%s", "请耐心等待队员前来汇合")
				else
					lingxiDesc = string.format("[ccebdb]%s", "请返回#G情花#n种植点，等待队员前来汇合")
				end
			elseif g_LingxiCtrl.m_Phase == 3 then
				if g_MapCtrl:CheckInLingxiSeedArea(g_MapCtrl:GetHero()) then
					lingxiDesc = string.format("[ccebdb]%s", "请种下#G情花苗#n")
				else
					lingxiDesc = string.format("[ccebdb]%s", "请返回#G情花#n种植点，种下#G情花苗#n")
				end
			elseif g_LingxiCtrl.m_Phase == 4 then
				lingxiDesc = string.format("[ccebdb]%s", "请留意各种突发事件，悉心照料#G情花#n成长（"..(g_LingxiCtrl.m_DoneCnt or 0).."/"..(g_LingxiCtrl.m_TotalCnt or 3).."）")
			elseif g_LingxiCtrl.m_Phase == 5 then
				lingxiDesc = string.format("[ccebdb]%s", "请采摘成熟的#G情花#n")
			else
				lingxiDesc = string.format("[ccebdb]%s", "队长灵犀任务状态不对")
			end
		elseif g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeader() then
			if g_LingxiCtrl.m_Phase == 1 then
				lingxiDesc = string.format("[ccebdb]%s", "等待队长寻找合适的#G情花#n种植点")
			elseif g_LingxiCtrl.m_Phase == 2 then
				if g_MapCtrl:CheckInLingxiSeedArea(g_MapCtrl:GetHero()) then
					lingxiDesc = string.format("[ccebdb]%s", "等待队长种下#G情花苗#n")
				else
					lingxiDesc = string.format("[ccebdb]%s", "前往#G情花#n种植点与队长汇合")
				end
			elseif g_LingxiCtrl.m_Phase == 3 then
				if g_MapCtrl:CheckInLingxiSeedArea(g_MapCtrl:GetHero()) then
					lingxiDesc = string.format("[ccebdb]%s", "等待队长种下#G情花苗#n")
				else
					lingxiDesc = string.format("[ccebdb]%s", "请返回#G情花#n种植点，等待队长种下#G情花苗#n")
				end				
			elseif g_LingxiCtrl.m_Phase == 4 then
				lingxiDesc = string.format("[ccebdb]%s", "请留意各种突发事件，悉心照料#G情花#n成长（"..(g_LingxiCtrl.m_DoneCnt or 0).."/"..(g_LingxiCtrl.m_TotalCnt or 3).."）")
			elseif g_LingxiCtrl.m_Phase == 5 then
				lingxiDesc = string.format("[ccebdb]%s", "等待队长采摘成熟的#G情花#n")
			else
				lingxiDesc = string.format("[ccebdb]%s", "队员灵犀任务状态不对")
			end
		end
		return lingxiDesc
	end

	local targetDesc = string.format("[ccebdb]%s", oTask:GetSValueByKey("targetdesc"))
	-- if oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_PICK) then
	-- 	-- 采集类型特殊处理（添加采集数）
	-- 	local pickitem = oTask:GetSValueByKey("pickitem")
	-- 	if pickitem and #pickitem > 1 then
	-- 		local curPick = oTask.m_ProgresID or 1
	-- 		local maxPick = #pickitem
	-- 		targetDes = string.format("%s#G(%s/%s)", targetDes, curPick, maxPick)
	-- 	end
	-- end
	if oTask:GetCValueByKey("tasktype") == define.Task.TaskType.TASK_UP_GRADE and not oTask.m_Finish then
		local text = string.gsub(oTask:GetSValueByKey("targetdesc"), "#%a", "")
		text = string.gsub(text, "%@(.-)%@", "")
		targetDesc = string.format("[FF4128]%s", text)
	end

	local isItemFind = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM)
	local isSummonFind = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON)
	local oNeedStr = ""
	if isItemFind then
		local oCurAmount = 0
		local oNeedAmount = g_TaskCtrl:GetTaskNeedItemAmount(oTask)
		local oLimitQuality = oTask:GetLimitQuality()
		local tItemList = g_TaskCtrl:GetTaskNeedItemList(oTask, false)
		if tItemList and next(tItemList) then			
			for k,v in pairs(tItemList) do
				oCurAmount = oCurAmount + g_ItemCtrl:GetBagItemAmountBySid(v, oLimitQuality)
			end
		end
		if oCurAmount > oNeedAmount then
			oNeedStr = oNeedAmount.."/"..oNeedAmount
		else
			oNeedStr = oCurAmount.."/"..oNeedAmount
		end
	elseif isSummonFind then
		local oCurAmount = 0
		local oNeedAmount = g_TaskCtrl:GetTaskNeedSumAmount(oTask)
		local tSumList = g_TaskCtrl:GetTaskNeedSumList(oTask, false)
		if tSumList and next(tSumList) then			
			for k,v in pairs(tSumList) do
				if oTask:GetAllowBB() then
					oCurAmount = oCurAmount + g_TaskCtrl:GetSumAmountByTypeId(v, true)
				else
					oCurAmount = oCurAmount + g_TaskCtrl:GetSumAmountByTypeId(v)
				end
			end
		end
		if oCurAmount > oNeedAmount then
			oNeedStr = oNeedAmount.."/"..oNeedAmount
		else
			oNeedStr = oCurAmount.."/"..oNeedAmount
		end
	end
	targetDesc = string.gsub(targetDesc, "{C.bag_counting}", oNeedStr)

	return targetDesc
end

--获取指定门派NpcID
function GetSchoolNpcID(typeName)
	if not typeName or typeName(typeName) ~= "string" then
		typeName = "tutorid"
	end
	return DataTools.GetSchoolNpcID(g_AttrCtrl.school, typeName)
end

-----------------以下是接口和处理CTask数据------------------

function GetClickTaskShopSelect()
	return g_ClickTaskShopSelect
end

function SetClickTaskShopSelect(oTask)
	g_ClickTaskShopSelect = oTask
end

function GetClickTaskExecute()
	return g_ClickTaskExecute
end

function SetClickTaskExecute(oTask)
	g_ClickTaskExecute = oTask
end

--客户端任务寻路
function PathfindByTaskId(taskID, delay)
	local oTask = g_TaskCtrl.m_TaskDataDic[taskID]
	if oTask then
		CTaskHelp.PathfindByTaskData(taskdata, delay)
	end
end

function PathfindByTaskData(taskData, delay)
	if not delay then
		CTaskHelp.PathfindTaskFinal(taskData)
		return
	end

	local delayTime = 1
	local function delay()
		CTaskHelp.PathfindTaskFinal(taskData)
		return false
	end
	Utils.AddTimer(delay, delayTime, delayTime)
end

function PathfindTaskFinal(taskData)
	print(string.format("<color=#00FF00> >>> .%s | %s | Table:%s </color>", "PathfindTaskFinal", "客户端寻路最终处理逻辑", "taskData"))
	table.print(taskData)
end

function PathFindToNpc(npcid)
	print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "PathFindToNpc", "客户端指定Npc寻路"), npcid)
end

function PathFindToPos(pos, func)
	-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "PathFindToPos", "客户端指定Pos寻路"))
	g_MapTouchCtrl:WalkToPos(pos, nil, define.Walker.Npc_Talk_Distance, func)
end

--获取任务分类名称
function GetTaskCategory(oTask)
	if not oTask then
		return
	end
	local taskType = oTask:GetCValueByKey("type")
	for _,v in pairs(define.Task.TaskCategory) do
		if taskType == v.ID then
			return v
		end
	end
end

--查找指定寻物任务所需物品，返回1:sidlist 2:itemTable
function GetTaskFindItemDic(oTask)
	if not oTask or not oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM) then
		return
	end

	local needitem = oTask:GetSValueByKey("needitem")
	local needitemgroup = oTask:GetSValueByKey("needitemgroup")
	if needitem and #needitem > 0 then
		local sidList = {}
		local itemTable = {}
		for _,v in ipairs(needitem) do
			table.insert(sidList, v.itemid)
			itemTable[v.itemid] = v
		end
		return sidList, itemTable, "normal"
	elseif needitemgroup and #needitemgroup > 0 then
		local groupidList = {}
		local groupTable = {}
		for _,v in ipairs(needitemgroup) do
			table.insert(groupidList, v.groupid)
			groupTable[v.groupid] = v
		end
		return groupidList, groupTable, "group"
	end
end

--查找指定寻宠任务所需宠物，返回1:sumidlist 2:itemTable
function GetTaskFindSummonDic(oTask)
	if not oTask or not oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON) then
		return
	end

	local needsum = oTask:GetSValueByKey("needsum")
	if needsum and #needsum > 0 then
		local sumidList = {}
		local sumTable = {}
		for _,v in ipairs(needsum) do
			table.insert(sumidList, v.sumid)
			sumTable[v.sumid] = v
		end
		return sumidList, sumTable
	end
end

function GetSummonDicBySidList(sumidList, isBaoBaoSubmit)
	local summons = g_SummonCtrl:GetSummons()
	local sumList = {}
	for _,sumid in ipairs(sumidList) do
		for _,sum in pairs(summons) do
			if sum.typeid == sumid and sum.key ~= 1 and (isBaoBaoSubmit and (sum.type == 1 or (sum.type == 2 and sum.zhenpin == 0)) or (sum.type == 1)) and sum.id ~= g_SummonCtrl.m_FightId then --or sum.grade == 0
				table.insert(sumList, sum)
			end
		end
	end
	table.sort(sumList, CTaskHelp.SummonSort)
	-- table.print(sumList, "GetSummonDicBySidList")
	return sumList
end

function SummonSort(sum1, sum2)
	if sum1.type ~= sum2.type then
		return sum1.type < sum2.type
	else
		local name1 = ((sum1.name ~= sum1.basename) and {1} or {0})[1]
		local name2 = ((sum2.name ~= sum2.basename) and {1} or {0})[1]
		if name1 ~= name2 then
			return name1 < name2
		else
			return sum1.got_time < sum2.got_time
		end
	end
end

--获取任务奖励，不只是道具(type 1)，还有伙伴(type 2)，坐骑(type 3)
function GetTaskRewardList(oTask)
	--特殊处理灵犀任务的显示奖励
	if oTask:GetCValueByKey("type") == define.Task.TaskCategory.LINGXI.ID then
		local itemList = {}
		for i,v in ipairs(data.scheduledata.SCHEDULE[1022].rewardlist) do
			local strs = string.split(v, ":")
			local itemID, itemAmount = strs[1], strs[2]
			local itemData = DataTools.GetItemData(itemID)
			if itemData then
				table.insert(itemList, itemData)
			end
		end
		return itemList
	end
	local itemList = {}
	local itemHashList = {}
	if oTask then
		local rewardIDList = oTask:GetCValueByKey("submitRewardStr")
		if rewardIDList then
			local category = CTaskHelp.GetTaskCategory(oTask)
			if category then
				local function InsertItemList(sid, typeName, type)
					if itemHashList[sid] then
						return
					end
					local item = DataTools.GetItemData(sid, typeName)
					if item then
						table.insert(itemList, {item = item, type = type})
						itemHashList[sid] = true
					end
				end
				local function InsertPartnerList(sid, type)
					local oPartner = data.partnerdata.INFO[tonumber(sid)]
					if oPartner then
						table.insert(itemList, {partner = oPartner, type = type})
					end
				end
				local function InsertRideList(sid, type)
					local oRide = data.ridedata.RIDEINFO[tonumber(sid)]
					if oRide then
						table.insert(itemList, {ride = oRide, type = type})
					end
				end
				local function AnalysisRewardInfo(RewardInfo)
					if RewardInfo.exp and tostring(RewardInfo.exp) ~= "0" and string.len(RewardInfo.exp) > 0 then InsertItemList(1005, "VIRTUAL", 1) end --and tonumber(RewardInfo.exp) and tonumber(RewardInfo.exp) > 0
					if RewardInfo.silver and tostring(RewardInfo.silver) ~= "0" and string.len(RewardInfo.silver) > 0 then InsertItemList(1002, "VIRTUAL", 1) end --and tonumber(RewardInfo.silver) and tonumber(RewardInfo.silver) > 0
					if RewardInfo.gold and tostring(RewardInfo.gold) ~= "0" and string.len(RewardInfo.gold) > 0 then InsertItemList(1001, "VIRTUAL", 1) end --and tonumber(RewardInfo.gold) and tonumber(RewardInfo.gold) > 0
					if RewardInfo.summexp and tostring(RewardInfo.summexp) ~= "0" and string.len(RewardInfo.summexp) > 0 then InsertItemList(1007, "VIRTUAL", 1) end --and tonumber(RewardInfo.summexp) and tonumber(RewardInfo.summexp) > 0
					if RewardInfo.goldcoin and tostring(RewardInfo.goldcoin) ~= "0" and string.len(RewardInfo.goldcoin) > 0 then InsertItemList(1003, "VIRTUAL", 1) end
					if RewardInfo.partner and RewardInfo.partner ~= "" then InsertPartnerList(RewardInfo.partner, 2) end
					if RewardInfo.ride and RewardInfo.ride ~= "" then InsertRideList(RewardInfo.ride, 3) end
					if RewardInfo.item and #RewardInfo.item > 0 then
						for _,v in ipairs(RewardInfo.item) do
							local oAmount = 0
							if v.itemarg then
								oAmount = tonumber(string.sub(v.itemarg, string.find(v.itemarg, "=")+1, string.find(v.itemarg, ")")-1)) or 0
							else
								oAmount = tonumber(v.amount) or 0
							end
							--暂时屏蔽小于1000的sid，以后要去掉
							if v.sid >= 1000 then
								if not v.type or v.type == 0 then
									if v.sid and oAmount > 0 then
										InsertItemList(v.sid, nil, 1)
									end
								else
									if v.sid and oAmount > 0 then
										local oSid =  DataTools.GetItemFiterResult(v.sid, g_AttrCtrl.roletype, g_AttrCtrl.sex)
										if oSid ~= -1 then
											InsertItemList(oSid, nil, 1)
										end
									end
								end
							end
						end
					end
				end
				for _,s in ipairs(rewardIDList) do
					local r = string.find(s, 'R')
					if r == 1 then
						local id = string.sub(s, 2)
						local rewardInfo = DataTools.GetReward(category.NAME, id)
						if rewardInfo then
							AnalysisRewardInfo(rewardInfo)
						end
					end
				end
			end
		end
	end
	return itemList
end

--是否当前地图
function IsSpecityCurMap(mapID)
	local curMapID = g_MapCtrl:GetMapID()
	return mapID == curMapID
end

function IsTwoPointInRadiusTask(oTask)
	if not oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_USE) then
		printerror("不是有效的到达某地使用物品任务类型")
		return
	end
	local taskThing = oTask:GetProgressThing()
	if taskThing then
		return CTaskHelp.IsTwoPointInRadiusThing(taskThing)
	end
end

function IsTwoPointInRadiusThing(taskThing)
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		local heroPos = oHero:GetPos()
		local centerPos = Vector3.New(taskThing.pos_x, taskThing.pos_y, heroPos.z)
		return CTaskHelp.IsTwoPointInRadiusPos(heroPos, centerPos, taskThing.radius)
	end
end

function IsTwoPointInRadiusPos(aPos, bPos, radius)
	local distance = Vector3.Distance(aPos, bPos)
	-- table.print(aPos, "heroPos")
	-- table.print(bPos, "centerPos")
	-- printc("IsTwoPointInRadiusPos", distance)
	return distance < radius
end

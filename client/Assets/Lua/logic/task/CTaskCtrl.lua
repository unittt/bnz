local CTaskCtrl = class("CTaskCtrl", CCtrlBase)

CTaskCtrl.g_NpcMarkSprName = {
	"task_npcaccept",--Ace
	"task_npcfinishnot",--Pro
	"task_npcfinish",--End
	"task_npcthread",--Main
	"task_npcbattle",--War
}

function CTaskCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_RefreshTimerUI = nil
	self.m_RefreshTimerMark = nil

	-- 08.26
	-- 标记结构(self.m_NpcMarkDic{npcType = {group1=xxx,group2=xxx}})
	self.m_NpcMarkDic = {}
	self.m_DynamicNpcList = {}
	self.m_PickItemList = {}
	self.m_TaskDataDic = {}
	self.m_TaskTypeDic = {}
	self.m_TaskCategoryTypeDic = {}

	self.m_AddTaskShineEffectList = {}

	self.m_CurLeftTimeList = {}
	self.m_TaskTimer = {}

	self.m_TaskBoxIsMoving = true
	self.m_TaskNotifyRecordData = {}

	self.m_EyeLeftTime = -0.1
	self.m_EyeCloseLeftTime = -0.1
	self.m_TaskChapterList = {}
	self.m_TaskCurChapter = 0
	self.m_AnimeQteTime = 0
	self.m_AnimeQteSetTime = 0
	self.m_AnimeQteTotalTime = nil
	self.m_AnimeQteFailTime = 0
	self.m_AnimeQteConfig = nil
	self.m_AnimeQteid = 0

	self.m_TaskBoxIsLoadDone = false

	self.m_ClickTaskAutoFindData = nil
	self.m_TaskSelectTime = 0

	--异宝的数据，从任务数据取出，与任务数据分离
	self.m_YiBaoDataDic = {}
	self:CheckYibaoConfig()

	for _,v in pairs(define.Task.TaskType) do
		self.m_TaskTypeDic[v] = {}
	end

	for k,v in pairs(define.Task.TaskCategory) do
		self.m_TaskCategoryTypeDic[v.ID] = {}
	end

	--是否允许交宝宝的任务列表
	self.m_BaoBaoTaskList = {define.Task.TaskCategory.RUNRING.ID}

	--主线章节配置
	self.m_ChapterConfigList = {}
	for i = 1, 7 do
		table.insert(self.m_ChapterConfigList, data.taskdata.STORYCHAPTER[i])
	end
	self.m_ChapterHasRewardPrizeList = {}
	self.m_ChapterDataList = {}
	self.m_ChapterNewDataList = {}
	self.m_ChapterAllUpdateDataList = {}
	self.m_IsShowingPieceView = false
	self.m_PieceShowingEndCb = {}
	self.m_IsUseChapterNew = true

	--跑环相关
	self.m_ExtendTaskData = nil
	self.m_ExtendTaskWidget = nil
	self.m_HelpOtherTaskData = {}
	self.m_LegendLeftTimeList = {}
	self.m_TaskLegendTimer = {}

	--悬赏相关
	self.m_XuanShangAceTaskData = {}
	self.m_XuanShangAceTaskHashData = {}
	self.m_XuanShangHasDoneTime = 0

	--引导任务相关
	self.m_GhostTaskGuide = {first = false, second = false}
	self.m_FubenTaskGuide = {first = false, second = false, three = false}

	self.m_OnlineDeleteTaskState = {}
	self.m_IsTaskNotifyClickShow = false
end

function CTaskCtrl.Clear(self)
	self.m_IsLoadNotifyData = false
	self.m_AceTaskNotify = {}
	self.m_AceTaskData = {}
	self.m_AceTaskidList = {}
	self.m_TaskLoginInit = false
	self.m_IsShimenDailyFull = 0
	self.m_IsShimenDelete = false
	self.m_IsGhostAceNotify = false
	self.m_IsShimenAceNotify = false
	self.m_IsBaotuAceNotify = false
	self.m_ExtendTaskData = nil
	self.m_ExtendTaskWidget = nil
	self.m_XuanShangAceTaskData = {}
	self.m_XuanShangAceTaskHashData = {}
	self.m_XuanShangHasDoneTime = 0
	self.m_IsShowingPieceView = false
	self.m_PieceShowingEndCb = {}
	self.m_TaskNotifyRecordData = {}
	self.m_GhostTaskGuide = {first = false, second = false}
	self.m_FubenTaskGuide = {first = false, second = false, three = false}
	--重登才会清，重连不会清
	self.m_OnlineDeleteTaskState = {}
	self.m_IsTaskNotifyClickShow = false
	self.m_LingxiQteTypeDoing = nil

	self.m_OnlineAddTaskRectEffectList = {}

	--ui也有改
	self.m_RecordTask = {
		partTab = 3,
		menu = {
			[1] = {name = "current"},
			[2] = {name = "accept"},
			[3] = {name = "story"},
		},
		effect = {},
	}
	for _,v in ipairs(self.m_RecordTask.menu) do
		v.mainMenu = 0
		v.subMenu = 0
	end
	-- DATA
	self.m_RecordLogic = {
		oTask = nil,
		shimenEff = nil,
	}
	--记录已预计使用的任务物品
	self.m_BagItemRecord = {}
end

function CTaskCtrl.AddPieceShowingCbList(self, cb)
	table.insert(self.m_PieceShowingEndCb, cb)
end

-------------------以下函数是协议返回----------------------
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

function CTaskCtrl.GS2CLoginTask(self, taskList)
	self:CheckShimenEff()

	for _,v in pairs(define.Task.TaskType) do
		self.m_TaskTypeDic[v] = {}
	end
	for k,v in pairs(define.Task.TaskCategory) do
		self.m_TaskCategoryTypeDic[v.ID] = {}
	end

	if taskList then
		local t = {}
		self.m_YiBaoDataDic = {}
		for _,v in ipairs(taskList) do
			local oTask = CTask.New(v)
			if oTask:GetSValueByKey("clientnpc") then
				for k,v in pairs(oTask:GetSValueByKey("clientnpc")) do
					v.taskbigtype = oTask:GetCValueByKey("type")
				end
			end

			t[v.taskid] = oTask
			printc("==============",ConvertTblToStr(oTask.m_CTaskDataGetter()),oTask:GetCValueByKey("type"))
			self.m_TaskCategoryTypeDic[oTask:GetCValueByKey("type")][v.taskid] = oTask

			if self:GetIsYibaoSubTask(oTask:GetCValueByKey("type"), oTask:GetSValueByKey("taskid")) then
				self.m_YiBaoDataDic[v.taskid] = oTask
			-- 进入火眼金睛
			elseif oTask:GetSValueByKey("taskid") == define.Task.SpcTask.GUESSGAME then
				g_MainMenuCtrl:HideTaskArea()
			end
			if v.tasktype > 0 and not self:GetIsYibaoSubTask(oTask:GetCValueByKey("type"), oTask:GetSValueByKey("taskid")) then
				self.m_TaskTypeDic[v.tasktype][v.taskid] = oTask
			end
		end
		self.m_TaskDataDic = t

		-- 刷新导航UI
		self:RefreshUI()
		self:CheckTaskFindThing()
		self:CheckTaskTargetThing()

		-- if g_MapCtrl.m_MapLoding == false then
			-- Npc标识放在最后检查
			self:CheckTaskThing()
		-- end
	end
	self.m_TaskLoginInit = true
	self:AddAceData(1)

	for k,v in pairs(self.m_CurLeftTimeList) do
		self:ResetTaskTimer(k)
	end
	self.m_CurLeftTimeList = {}
	for k, oTask in pairs(self.m_TaskDataDic) do
		self.m_CurLeftTimeList[oTask:GetSValueByKey("taskid")] = oTask:GetSValueByKey("time")
		self:SetTaskTime(oTask:GetSValueByKey("taskid"))
	end
	--传说剩余时间
	for k,v in pairs(self.m_LegendLeftTimeList) do
		self:ResetTaskLegendTimer(k)
	end
	self.m_LegendLeftTimeList = {}
	for k, oTask in pairs(self.m_TaskDataDic) do
		self.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")] = oTask:GetLegendTime()
		self:SetTaskLegendTime(oTask:GetSValueByKey("taskid"))
	end

	-- table.print(self.m_TaskDataDic,"登录返回的任务数据:")
	-- table.print(self.m_YiBaoDataDic, "登录返回的异宝数据:")
	g_GuideCtrl:OnTriggerAll()
end


--协议返回,每次添加的是一个任务
function CTaskCtrl.GS2CAddTask(self, task)
	local oTask = CTask.New(task)
	self.m_TaskDataDic[task.taskid] = oTask
	self.m_TaskCategoryTypeDic[oTask:GetCValueByKey("type")][oTask:GetSValueByKey("taskid")] = oTask
	if not self:GetIsYibaoSubTask(oTask:GetCValueByKey("type"), oTask:GetSValueByKey("taskid")) then			
		if task.tasktype > 0 then
			self.m_TaskTypeDic[task.tasktype][task.taskid] = oTask
		end
	else
		self.m_YiBaoDataDic[oTask:GetSValueByKey("taskid")] = oTask
	end
	if oTask:GetSValueByKey("clientnpc") then
		for k,v in pairs(oTask:GetSValueByKey("clientnpc")) do
			v.taskbigtype = oTask:GetCValueByKey("type")
		end
	end

	--特效提醒列表
	if oTask:GetCValueByKey("tips") and oTask:GetCValueByKey("tips") ~= 0 then
		self.m_OnlineAddTaskRectEffectList[oTask:GetSValueByKey("taskid")] = true
		self:OnEvent(define.Task.Event.TaskRectEffect)
	end

	--添加异宝总任务打开异宝界面
	if oTask:GetSValueByKey("taskid") == g_TaskCtrl:GetYibaoMainTaskid().taskid then
		if g_TaskCtrl.m_TaskDataDic[g_TaskCtrl:GetYibaoMainTaskid().taskid] then
			CTaskHelp.ClickTaskLogic(g_TaskCtrl.m_TaskDataDic[g_TaskCtrl:GetYibaoMainTaskid().taskid])
		end
	--进入火眼金睛
	elseif oTask:GetSValueByKey("taskid") == define.Task.SpcTask.GUESSGAME then
		g_MainMenuCtrl:HideTaskArea()
	end
	--灵犀任务接取后显示任务栏
	if oTask:GetSValueByKey("taskid") == g_LingxiCtrl:GetLingxiTaskId() then
		local oView = CMainMenuView:GetView()
		if oView then
			oView.m_RT.m_ExpandBox.m_TaskBtn:SetSelected(true)
			oView.m_RT.m_ExpandBox:ShowTaskPart()
		end
	end
	if oTask:GetCValueByKey("type") == define.Task.TaskCategory.BAOTU.ID then
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.BAOTU.ID)
	end
	if oTask:GetCValueByKey("type") == define.Task.TaskCategory.XUANSHANG.ID then
		COfferRewardView:CloseView()
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.XUANSHANG.ID)
	end
	if oTask:GetCValueByKey("type") == define.Task.TaskCategory.SHIMEN.ID then
		local oShimenCount = 0
		local shimenScheduleData = g_ScheduleCtrl:GetScheduleData(define.Task.AceSchedule.SHIMEN)
		if shimenScheduleData then
			oShimenCount = shimenScheduleData.times
		end
		if self.m_IsShimenDelete and oShimenCount > 0 then
			CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.SHIMEN.ID)
		end
	end
	if oTask:GetCValueByKey("type") == define.Task.TaskCategory.FUBEN.ID then
		g_DungeonTaskCtrl:ReceiveFubenTask(oTask)
	elseif oTask:GetCValueByKey("type") == define.Task.TaskCategory.JYFUBEN.ID then
		g_DungeonTaskCtrl:ReceiveJyFubenTask(oTask)
	end

	--任务特效相关
	self.m_AddTaskShineEffectList[oTask:GetSValueByKey("taskid")] = true
	--章节标题
	local oChapter = CTaskHelp.GetChapterData(oTask)
	if oChapter then
		g_NotifyCtrl:ShowChapterOpen(oChapter.id)
	end
		
	self:RefreshUI()
	self:CheckFindItemFinish(oTask)
	self:CheckFindSummonFinish(oTask)
	self:CheckTaskTargetFinish(oTask)
	-- self:CheckNpcMark()
	-- 检查动态Npc、PickModel
	-- self:DoCheckDynamicNpc(oTask:GetSValueByKey("clientnpc"), true)
	-- self:DoCheckPickModel(oTask, true)
	self:CheckTaskThing()

	-- 刷新可接任务数据
	self:RefreshAceData()
	self:AddAceData(2)

	-- 刷新任务时间列表
	self:ResetTaskTimer(oTask:GetSValueByKey("taskid"))
	self.m_CurLeftTimeList[oTask:GetSValueByKey("taskid")] = oTask:GetSValueByKey("time")
	self:SetTaskTime(oTask:GetSValueByKey("taskid"))
	-- 刷新传说剩余时间列表
	self:ResetTaskLegendTimer(oTask:GetSValueByKey("taskid"))
	self.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")] = oTask:GetLegendTime()
	self:SetTaskLegendTime(oTask:GetSValueByKey("taskid"))

	local function update()
		self:OnEvent(define.Task.Event.AddTask, oTask)
		return false
	end
	Utils.AddTimer(update, 0, 0.6)

	g_GuideCtrl:OnTriggerAll()
end

--协议返回,每次删除的是一个任务
function CTaskCtrl.GS2CDelTask(self, pbdata)
	self.m_YiBaoDataDic[pbdata.taskid] = nil

	local oTask = self.m_TaskDataDic[pbdata.taskid]
	if not oTask then
		-- printerror("任务删 >>> 不存在任务ID:", pbdata.taskid)
		return
	end

	self.m_OnlineDeleteTaskState[pbdata.taskid] = true

	if pbdata.is_done == 1 then
		if oTask:GetCValueByKey("type") ~= define.Task.TaskCategory.GHOST.ID then
			g_NotifyCtrl:ShowTaskDoneEffect()
		end

		--异宝还原
		-- if oTask:GetCValueByKey("type") == define.Task.TaskCategory.YIBAO.ID and oTask:GetCValueByKey("tasktype") == define.Task.TaskType.TASK_FIND_ITEM then
		-- 	if g_TaskCtrl.m_TaskDataDic[g_TaskCtrl:GetYibaoMainTaskid().taskid] then
		-- 		CTaskHelp.ClickTaskLogic(g_TaskCtrl.m_TaskDataDic[g_TaskCtrl:GetYibaoMainTaskid().taskid])
		-- 	end
		-- end
	end

	if oTask:GetCValueByKey("type") == define.Task.TaskCategory.RUNRING.ID then
		self:OnCloseTaskItemFindOpBox()
		g_TaskCtrl.m_DialogueFindOpCb = nil
		CDialogueMainView:CloseView()
	end
	if oTask:GetCValueByKey("tasktype") == define.Task.TaskType.TASK_FIND_NPC then
		CDialogueMainView:CloseView()
	end
	if oTask:GetCValueByKey("type") == define.Task.TaskCategory.SHIMEN.ID then
		self.m_IsShimenDelete = true
	end

	-- 退出火眼金睛
	if oTask:GetSValueByKey("taskid") == define.Task.SpcTask.GUESSGAME then
		g_MainMenuCtrl:ResetTaskArea()
	end
	if oTask:GetSValueByKey("taskid") == g_TaskCtrl:GetYibaoMainTaskid().taskid then
		CYibaoMainView:CloseView()
	end

	if oTask:GetCValueByKey("type") == define.Task.TaskCategory.FUBEN.ID then
		g_DungeonTaskCtrl:DelFunbenTask()
	elseif oTask:GetCValueByKey("type") == define.Task.TaskCategory.JYFUBEN.ID then
		g_DungeonTaskCtrl:DelJyFunbenTask()
	end

	-- 刷新任务时间列表	
	self:ResetTaskTimer(oTask:GetSValueByKey("taskid"))
	self.m_CurLeftTimeList[oTask:GetSValueByKey("taskid")] = 0
	self:SetTaskTime(oTask:GetSValueByKey("taskid"))
	-- 刷新传说剩余时间列表
	self:ResetTaskLegendTimer(oTask:GetSValueByKey("taskid"))
	self.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")] = 0
	self:SetTaskLegendTime(oTask:GetSValueByKey("taskid"))

	local sumGetTaskid = g_GuideHelpCtrl:GetSummonSelectTaskId()
	if sumGetTaskid and pbdata.is_done == 1 and sumGetTaskid == oTask:GetSValueByKey("taskid") then
		if not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("sumshow") then
			table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "sumshow")
			g_GuideHelpCtrl.m_GuideExtraInfoHashList["sumshow"] = true
			local list = {exdata = g_GuideHelpCtrl:TurnGuideExtraListToStr()}
			local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
			netnewbieguide.C2GSUpdateNewbieGuideInfo(encode.mask, encode.guide_links, encode.exdata)

			CGuideSelectSummonView:ShowView()
		end
	end

	-- 这些要保证在最后面
	-- 删除动态npc
	self:DoCheckDynamicNpc(oTask:GetSValueByKey("clientnpc"), false)
	self:DoCheckPickModel(oTask, false)

	if self.m_TaskCategoryTypeDic[oTask:GetCValueByKey("type")] then
		self.m_TaskCategoryTypeDic[oTask:GetCValueByKey("type")][oTask:GetSValueByKey("taskid")] = nil
	end
	self:DelTaskTypeTable(oTask)
	self.m_TaskDataDic[pbdata.taskid] = nil

	if oTask:GetCValueByKey("type") == define.Task.TaskCategory.XUANSHANG.ID then
		local xuanshangScheduleData = g_ScheduleCtrl:GetScheduleData(define.Task.AceSchedule.XUANSHANG)
		if not (xuanshangScheduleData and xuanshangScheduleData.times >= xuanshangScheduleData.maxtimes) then
			CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.XUANSHANG.ID)
		end
	end

	self:RefreshUI()
	self:CheckNpcMark()

	-- 刷新可接任务数据
	self:RefreshAceData()
	self:AddAceData(1)

	self:OnEvent(define.Task.Event.DelTask, pbdata.taskid)

	g_GuideCtrl:OnTriggerAll()
end

--协议返回,每次刷新的是一个任务
function CTaskCtrl.GS2CRefreshTask(self, taskid, target, name, targetdesc, detaildesc, isreach, ext_apply_info, time)
	local oYibaoTask = self.m_YiBaoDataDic[taskid]
	if oYibaoTask then
		oYibaoTask.m_SData.target = ((target) and {target} or {oYibaoTask.m_SData.target})[1] -- and target ~= 0
		oYibaoTask.m_SData.name = ((name) and {name} or {oYibaoTask.m_SData.name})[1] -- and name ~= ""
		oYibaoTask.m_SData.targetdesc = ((targetdesc) and {targetdesc} or {oYibaoTask.m_SData.targetdesc})[1] -- and targetdesc ~= ""
		oYibaoTask.m_SData.detaildesc = ((detaildesc) and {detaildesc} or {oYibaoTask.m_SData.detaildesc})[1] -- and detaildesc ~= ""
		-- oYibaoTask.m_SData.ext_apply_info = ((ext_apply_info) and {ext_apply_info} or {oYibaoTask.m_SData.ext_apply_info})[1]

		self.m_YiBaoDataDic[taskid] = oYibaoTask
	end

	local oTask = self.m_TaskDataDic[taskid]
	if not oTask then
		-- printerror("任务刷新 >>> 不存在任务ID:", taskid)
		return
	end

	if self.m_TaskCategoryTypeDic[oTask:GetCValueByKey("type")] and self.m_TaskCategoryTypeDic[oTask:GetCValueByKey("type")][oTask:GetSValueByKey("taskid")] then
		local oTaskBigTask = self.m_TaskCategoryTypeDic[oTask:GetCValueByKey("type")][oTask:GetSValueByKey("taskid")]
		oTaskBigTask.m_SData.target = ((target) and {target} or {oTaskBigTask.m_SData.target})[1] -- and target ~= 0
		oTaskBigTask.m_SData.name = ((name) and {name} or {oTaskBigTask.m_SData.name})[1] -- and name ~= ""
		oTaskBigTask.m_SData.targetdesc = ((targetdesc) and {targetdesc} or {oTaskBigTask.m_SData.targetdesc})[1] -- and targetdesc ~= ""
		oTaskBigTask.m_SData.detaildesc = ((detaildesc) and {detaildesc} or {oTaskBigTask.m_SData.detaildesc})[1] -- and detaildesc ~= ""
		-- oTaskBigTask.m_SData.ext_apply_info = ((ext_apply_info) and {ext_apply_info} or {oTaskBigTask.m_SData.ext_apply_info})[1]

		self.m_TaskCategoryTypeDic[oTask:GetCValueByKey("type")][oTask:GetSValueByKey("taskid")] = oTaskBigTask
	end

	local refreshTask = false
	if isreach then
		oTask.m_SData.isreach = isreach
		oTask.m_Finish = isreach == 1 and true or false
		if not refreshTask then
			refreshTask = true
		end
	end

	--寻人任务的完成状态在isreach之后再次判断
	if (target) then -- and target ~= 0
		oTask.m_SData.target = target
	end

	
	if (name) then -- and name ~= ""
		oTask.m_SData.name = name
		if not refreshTask then
			refreshTask = true
		end
	end

	if (targetdesc) then -- and targetdesc ~= ""
		oTask.m_SData.targetdesc = targetdesc
		if not refreshTask then
			refreshTask = true
		end
	end

	if (detaildesc) then -- and detaildesc ~= ""
		oTask.m_SData.detaildesc = detaildesc
		if not refreshTask then
			refreshTask = true
		end
	end

	if ext_apply_info then
		oTask.m_SData.ext_apply_info = ext_apply_info
		if not refreshTask then
			refreshTask = true
		end

		--特殊处理，更新灵犀情花模型的东西
		if oTask:GetSValueByKey("taskid") == g_LingxiCtrl:GetLingxiTaskId() then
			local oLingxiInfo = oTask.m_SData.ext_apply_info[1]
			-- local oDynamicNpc = g_MapCtrl:GetDynamicNpc(oTask.m_SData.clientnpc[1].npcid)
			-- if oDynamicNpc then
			-- 	oDynamicNpc:SetNpcSpecialHud(nil, nil)
			-- 	if oLingxiInfo and oLingxiInfo.key == "qte" then					
			-- 		--除虫
			-- 		if oLingxiInfo.value == 1 then
			-- 			oDynamicNpc:SetNpcSpecialHud(nil, "10095")
			-- 		--浇水
			-- 		elseif oLingxiInfo.value == 2 then
			-- 			oDynamicNpc:SetNpcSpecialHud(nil, "10094")
			-- 		end
			-- 	end
			-- end

			self.m_LingxiQteTypeDoing = nil
			if oLingxiInfo and oLingxiInfo.key == "qte" then					
				--除虫
				if oLingxiInfo.value == 1 and g_AttrCtrl.sex == 1 then
					self.m_LingxiQteTypeDoing = {type = 1, taskid = oTask:GetSValueByKey("taskid"), npcid = oTask.m_SData.clientnpc[1].npcid}
				--浇水
				elseif oLingxiInfo.value == 2 and g_AttrCtrl.sex == 2 then
					self.m_LingxiQteTypeDoing = {type = 2, taskid = oTask:GetSValueByKey("taskid"), npcid = oTask.m_SData.clientnpc[1].npcid}
				end
			end
			self:OnEvent(define.Task.Event.LingxiQte)
		end

		-- 刷新传说剩余时间列表
		self:ResetTaskLegendTimer(oTask:GetSValueByKey("taskid"))
		self.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")] = oTask:GetLegendTime()
		self:SetTaskLegendTime(oTask:GetSValueByKey("taskid"))
	end

	if time then
		oTask.m_SData.time = time
		if not refreshTask then
			refreshTask = true
		end
		-- 刷新任务时间列表	
		self:ResetTaskTimer(oTask:GetSValueByKey("taskid"))
		self.m_CurLeftTimeList[oTask:GetSValueByKey("taskid")] = oTask:GetSValueByKey("time")
		self:SetTaskTime(oTask:GetSValueByKey("taskid"))
	end

	if refreshTask then
		self:RefreshSpecityBoxUI({task = oTask})
	end

	self:CheckFindItemFinish(oTask)
	self:CheckFindSummonFinish(oTask)
	self:CheckTaskTargetFinish(oTask)

	-- 刷新可接任务数据
	self:RefreshAceData()
	self:AddAceData(1)

	self:RefreshUI()
	self:CheckNpcMark()

	self:OnEvent(define.Task.Event.RefreshTask)

	g_GuideCtrl:OnTriggerAll()
end

function CTaskCtrl.GS2CSubmitTaskFail(self, pbdata)
	local taskid = pbdata.taskid
	local npcid = pbdata.npcid

	local model_info
	local name
	local npc = g_MapCtrl:GetNpc(npcid)
	if npc then
		model_info = npc.m_NpcAoi.block.model_info
		name = npc.m_NpcAoi.block.name
	else
		npc = g_MapCtrl:GetDynamicNpc(npcid)
		model_info = npc.m_ClientNpc.model_info
		name = npc.m_ClientNpc.name
	end

	if not model_info or not name then
		return
	end

	local oMark = string.find(g_DialogueCtrl.m_NpcSayData.text, "%&Q")
	local sText = "你还没有完成任务呢，快去吧，我等着你。"
	-- if oMark then
	-- 	sText = "你还没有完成任务呢，快去吧，我等着你。"..string.sub(g_DialogueCtrl.m_NpcSayData.text, oMark, -1)
	-- else
	-- 	sText = "你还没有完成任务呢，快去吧，我等着你。"
	-- end
	local oNeedData = {sessionidx = g_DialogueCtrl.m_NpcSayData.sessionidx, npcid = npcid, model_info = model_info, 
	name = name, text = sText, type = g_DialogueCtrl.m_NpcSayData.type, lv2 = g_DialogueCtrl.m_NpcSayData.lv2, time = g_DialogueCtrl.m_NpcSayData.time}
	--这里不再执行任务
	CDialogueOptionView:ShowView(function (oView)
		oView.m_IsNotShowBtn = true
		g_DialogueCtrl:OnEvent(define.Dialogue.Event.InitOption, oNeedData)
	end)
	-- g_DialogueCtrl:GS2CNpcSay(oNeedData)
end

function CTaskCtrl.GS2CRemoveTaskNpc(self, npcid, taskid, target)
	g_MapCtrl:DelDynamicNpc(npcid)
	self:GS2CRefreshTask(taskid, target)
end

function CTaskCtrl.GS2CShimenInfo(self, pbdata)
	local done_daily = pbdata.done_daily --师门日完成次数
	local done_weekly = pbdata.done_weekly --师门周完成次数
	local daily_full = pbdata.daily_full --师门是否日满次数

	self.m_IsShimenDailyFull = daily_full

	-- 刷新可接任务数据
	self:RefreshAceData()
	if daily_full == 1 then
		self:AddAceData(2)
	else
		self:AddAceData(1)
	end

	table.print(pbdata, "CTaskCtrl.GS2CShimenInfo")
end

function CTaskCtrl.GS2CRefreshTaskClientNpc(self, pbdata)
	local taskid = pbdata.taskid
	local clientnpc = pbdata.clientnpc

	local oTask = self.m_TaskDataDic[taskid]
	if not oTask.m_SData.clientnpc then
		oTask.m_SData.clientnpc = {}
	end
	local isExist = false
	if oTask and oTask.m_SData.clientnpc and next(oTask.m_SData.clientnpc) then
		for k,v in pairs(oTask.m_SData.clientnpc) do
			if v.npcid == clientnpc.npcid then
				isExist = true
				table.remove(oTask.m_SData.clientnpc, k)
				table.insert(oTask.m_SData.clientnpc, k, clientnpc)
				break
			end
		end

		--暂时屏蔽
		-- self:DoCheckDynamicNpc(oTask:GetSValueByKey("clientnpc"), false)
		-- self:DoCheckDynamicNpc(oTask:GetSValueByKey("clientnpc"), true)
	end
	if not isExist then
		table.insert(oTask.m_SData.clientnpc, clientnpc)

		-- self:DoCheckDynamicNpc(oTask:GetSValueByKey("clientnpc"), true)
	end
	self:CheckTaskThing()
	-- self:CheckTaskModel()
end

function CTaskCtrl.GS2CGuideBehavior(self, pbdata)
	-- 去掉任务点击协议锁状态
	g_NetCtrl:DelLockSession("task", "C2GSClickTask")
	if pbdata.behavior == 1 then --"师门任务"（修改为：门派修行）
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.SHIMEN.ID)
	elseif pbdata.behavior == 2 then --"抓鬼任务"（金刚伏魔 （钟馗：判官））
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.GHOST.ID)
	elseif pbdata.behavior == 3 then --"封妖"
		local mapID = 101000
		local sealNpcMapInfo = DataTools.GetSealNpcMapInfo(g_AttrCtrl.grade)
		if sealNpcMapInfo then
			mapID = sealNpcMapInfo.mapid
		end	
		g_MapCtrl:C2GSClickWorldMap(mapID)
	elseif pbdata.behavior == 4 then --"雷峰塔副本（侠影）"
		g_MapTouchCtrl:WalkToGlobalNpc(5257)
	elseif pbdata.behavior == 5 then --"雷峰塔副本（仙途）"
		g_MapTouchCtrl:WalkToGlobalNpc(5257)
	elseif pbdata.behavior == 6 then --"金山寺副本（侠影）"
		--未处理
		g_MapTouchCtrl:WalkToGlobalNpc(5257)
	elseif pbdata.behavior == 7 then --"金山寺副本（仙途）"
		--未处理
		g_MapTouchCtrl:WalkToGlobalNpc(5257)
	elseif pbdata.behavior == 8 then --"竞技场"
		g_JjcCtrl:OpenJjcMainView()
	elseif pbdata.behavior == 9 then --"异宝收集"
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.YIBAO.ID)
	elseif pbdata.behavior == 10 then --"跳舞活动"
		nethuodong.C2GSDanceAuto()
	elseif pbdata.behavior == 11 then --"欢乐骰子"
		nethuodong.C2GSShootCrapOpen()
	elseif pbdata.behavior == 12 then --"天魔来袭"
		--未处理
		local mapID = 201000
		g_MapCtrl:C2GSClickWorldMap(mapID)
	elseif pbdata.behavior == 14 then --装备强化
		CForgeMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("Strengthen"))
		end)
	elseif pbdata.behavior == 15 then --装备洗练
		CForgeMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("Wash"))
		end)
	elseif pbdata.behavior == 16 then --装备打造
		CForgeMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("Forge"))
		end)
	elseif pbdata.behavior == 31 then --装备附魂
		CForgeMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("Attach"))
		end)
	elseif pbdata.behavior == 17 then --使用伙伴经验丹
		CPartnerMainView:ShowView(function(oView)
			oView:ResetCloseBtn()
			oView:ShowSubPageByIndex(oView:GetPageIndex("Recruit"))
		end)
	elseif pbdata.behavior == 18 then --升级伙伴技能
		CPartnerMainView:ShowView(function(oView)
			oView:ResetCloseBtn()
			oView:ShowSubPageByIndex(oView:GetPageIndex("Recruit"))
		end)
	elseif pbdata.behavior == 19 then --伙伴突破
		CPartnerMainView:ShowView(function(oView)
			oView:ResetCloseBtn()
			oView:ShowSubPageByIndex(oView:GetPageIndex("Recruit"))
		end)
	elseif pbdata.behavior == 20 then --伙伴进阶
		CPartnerMainView:ShowView(function(oView)
			oView:ResetCloseBtn()
			oView:ShowSubPageByIndex(oView:GetPageIndex("Recruit"))
		end)
	elseif pbdata.behavior == 21 then --使用宠物经验丹
		g_SummonCtrl:ShowPropertyView()
	elseif pbdata.behavior == 22 then --升级宠物技能
		g_SummonCtrl:ShowSutdySkillView()
	elseif pbdata.behavior == 23 then --学习宠物技能
		g_SummonCtrl:ShowSutdySkillView()
	elseif pbdata.behavior == 24 then --宠物合成
		g_SummonCtrl:ShowCompoundView()
	elseif pbdata.behavior == 25 then --宠物洗练
		g_SummonCtrl:ShowWashView()
	elseif pbdata.behavior == 26 then --宠物培养
		g_SummonCtrl:ShowCultureView()
	elseif pbdata.behavior == 27 then --升级主角招式技能
		CSkillMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("School"))
		end)
	elseif pbdata.behavior == 28 then --心法技能
		CSkillMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("Passive"))
		end)
	elseif pbdata.behavior == 29 then --修炼技能
		CSkillMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("Cultivation"))
		end)
	elseif pbdata.behavior == 30 then --帮派技能
		CSkillMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("Org"))
		end)
	elseif pbdata.behavior == 32 then --头衔
		g_AttrCtrl:OpenBadgeView()
	elseif pbdata.behavior == 33 then --英雄试炼
		nethuodong.C2GSTrialOpenUI()
	else
	end
end

---------------------以下是可接任务相关------------------------

--协议返回，返回可接任务的id列表
function CTaskCtrl.GS2CAcceptableTasks(self, taskids)
	--初始化获取可接任务红点数据
	self:GetAceTaskNotifySaveData()
	-- table.print(self.m_AceTaskNotify, "初始化获取可接任务红点数据")
	
	self.m_AceTaskidList = {}
	for k,v in pairs(taskids) do
		self.m_AceTaskidList[k] = v
	end
	-- 刷新可接任务数据，因为里面会根据当前的任务数据屏蔽掉一些可接任务，所以需要这个接口
	self:RefreshAceData()
	self:AddAceData(1)
end

--添加师门或抓鬼的可接任务的数据,iAddType是这个特殊可接任务的更新类型：添加，删除,iAddType主要是处理这个特殊可接任务红点
--以后要根据需求修改
function CTaskCtrl.AddAceData(self, iAddType)
	if g_KuafuCtrl:IsInKS() then
		self.m_AceTaskNotify = {}
		self.m_AceTaskData = {}
		self:OnEvent(define.Task.Event.AddAceTaskNotify)
		self:OnEvent(define.Task.Event.RedPointNotify)
		return
	end

	--初始化获取可接任务红点数据
	self:GetAceTaskNotifySaveData()

	--4师门, 5抓鬼，14跑环，15宝图
	local shiMenCategoryID = define.Task.TaskCategory.SHIMEN.ID
	local ghostCateGoryID = define.Task.TaskCategory.GHOST.ID
	local runringCateGoryId = define.Task.TaskCategory.RUNRING.ID
	local baotuCateGoryId = define.Task.TaskCategory.BAOTU.ID
	--m_IsShimenDailyFull 1 代表今天已完成的师门次数达到最大
	if not self:GetIsTypeExist(shiMenCategoryID) and g_OpenSysCtrl:GetOpenSysState(define.System.Shimen) and self.m_IsShimenDailyFull ~= 1 then
		local list = {}
		local npcid = DataTools.GetSchoolNpcID(g_AttrCtrl.school)
		local gobalnpcData = DataTools.GetGlobalNpc(npcid)
		local targetdesc
		if gobalnpcData then
			local sceneName = DataTools.GetSceneNameByMapId(gobalnpcData.mapid)
			if sceneName ~= "" then
				targetdesc = string.format(define.Task.AceTaskColor.Map, sceneName)
				 .. "#D的#n" .. string.format(define.Task.AceTaskColor.NpcName, gobalnpcData.name)
			else
				targetdesc = string.format(define.Task.AceTaskColor.NpcName, gobalnpcData.name)
			end
		else
			targetdesc = string.format(define.Task.AceTaskColor.NpcName, "无")
		end

		list.targetdesc = targetdesc
		list.detaildesc = data.taskdata.TASKTYPE[shiMenCategoryID].desc
		list.name = data.taskdata.TASKTYPE[shiMenCategoryID].name
		list.taskid = define.Task.AceTaskSpecial.SHIMEN
		list.target = npcid
		list.isacetask = 1

		local oTask = CTask.New(list)
		self.m_AceTaskData[list.taskid] = oTask

		if iAddType == 1 then --添加
			if not self.m_AceTaskNotify[list.taskid] and not self.m_IsShimenAceNotify then
				self.m_AceTaskNotify[list.taskid] = 0
				self.m_IsShimenAceNotify = true
			end
		elseif iAddType == 2 then --删除
			-- self.m_AceTaskNotify[list.taskid] = nil
		end
	end

	local ghostScheduleData = g_ScheduleCtrl:GetScheduleData(define.Task.AceSchedule.GHOST)
	local isGhostScheduleDone = ghostScheduleData and ghostScheduleData.times >= 60 --and ghostScheduleData.maxtimes > 0
	if not self:GetIsTypeExist(ghostCateGoryID) and g_OpenSysCtrl:GetOpenSysState(define.System.Ghost) and not isGhostScheduleDone then
		local list = {}
		local npcid = data.taskdata.TASKTYPE[ghostCateGoryID].npcid
		local gobalnpcData = DataTools.GetGlobalNpc(npcid)
		local targetdesc
		if gobalnpcData then
			local sceneName = DataTools.GetSceneNameByMapId(gobalnpcData.mapid)
			if sceneName ~= "" then
				targetdesc = string.format(define.Task.AceTaskColor.Map, sceneName) 
				.. "#D的#n" .. string.format(define.Task.AceTaskColor.NpcName, gobalnpcData.name)
			else
				targetdesc = string.format(define.Task.AceTaskColor.NpcName, gobalnpcData.name)
			end
		else
			targetdesc = string.format(define.Task.AceTaskColor.NpcName, "无")
		end

		list.targetdesc = targetdesc
		list.detaildesc = data.taskdata.TASKTYPE[ghostCateGoryID].desc
		list.name = data.taskdata.TASKTYPE[ghostCateGoryID].name
		list.taskid = define.Task.AceTaskSpecial.GHOST
		list.target = npcid
		list.isacetask = 1

		local oTask = CTask.New(list)
		self.m_AceTaskData[list.taskid] = oTask

		if iAddType == 1 then --添加
			if not self.m_AceTaskNotify[list.taskid] and not self.m_IsGhostAceNotify then
				self.m_AceTaskNotify[list.taskid] = 0
				self.m_IsGhostAceNotify = true
			end
		elseif iAddType == 2 then --删除
			-- self.m_AceTaskNotify[list.taskid] = nil
		end
	end

	local baotuScheduleData = g_ScheduleCtrl:GetScheduleData(define.Task.AceSchedule.BAOTU)
	local isBaotuScheduleDone = baotuScheduleData and baotuScheduleData.maxtimes > 0 and baotuScheduleData.times >= baotuScheduleData.maxtimes
	if not self:GetIsTypeExist(baotuCateGoryId) and g_OpenSysCtrl:GetOpenSysState(define.System.Baotu) and not isBaotuScheduleDone then
		local list = {}
		local npcid = data.taskdata.TASKTYPE[baotuCateGoryId].npcid
		local gobalnpcData = DataTools.GetGlobalNpc(npcid)
		local targetdesc
		if gobalnpcData then
			local sceneName = DataTools.GetSceneNameByMapId(gobalnpcData.mapid)
			if sceneName ~= "" then
				targetdesc = string.format(define.Task.AceTaskColor.Map, sceneName) 
				.. "#D的#n" .. string.format(define.Task.AceTaskColor.NpcName, gobalnpcData.name)
			else
				targetdesc = string.format(define.Task.AceTaskColor.NpcName, gobalnpcData.name)
			end
		else
			targetdesc = string.format(define.Task.AceTaskColor.NpcName, "无")
		end

		list.targetdesc = targetdesc
		list.detaildesc = data.taskdata.TASKTYPE[baotuCateGoryId].desc
		list.name = data.taskdata.TASKTYPE[baotuCateGoryId].name
		list.taskid = define.Task.AceTaskSpecial.BAOTU
		list.target = npcid
		list.isacetask = 1

		local oTask = CTask.New(list)
		self.m_AceTaskData[list.taskid] = oTask

		if iAddType == 1 then --添加
			if not self.m_AceTaskNotify[list.taskid] and not self.m_IsBaotuAceNotify then
				self.m_AceTaskNotify[list.taskid] = 0
				self.m_IsBaotuAceNotify = true
			end
		elseif iAddType == 2 then --删除
			-- self.m_AceTaskNotify[list.taskid] = nil
		end
	end

	-- local runringScheduleData = g_ScheduleCtrl:GetScheduleData(define.Task.AceSchedule.RUNRING)
	-- local isRunringScheduleDone = runringScheduleData and runringScheduleData.maxtimes > 0 and runringScheduleData.times >= runringScheduleData.maxtimes
	-- if not self:GetIsTypeExist(runringCateGoryId) and g_OpenSysCtrl:GetOpenSysState(define.System.Runring) and not isRunringScheduleDone then
	-- 	local list = {}
	-- 	local npcid = data.taskdata.TASKTYPE[runringCateGoryId].npcid
	-- 	local gobalnpcData = DataTools.GetGlobalNpc(npcid)
	-- 	local targetdesc
	-- 	if gobalnpcData then
	-- 		local sceneName = DataTools.GetSceneNameByMapId(gobalnpcData.mapid)
	-- 		if sceneName ~= "" then
	-- 			targetdesc = string.format(define.Task.AceTaskColor.Map, sceneName) 
	-- 			.. "#D的#n" .. string.format(define.Task.AceTaskColor.NpcName, gobalnpcData.name)
	-- 		else
	-- 			targetdesc = string.format(define.Task.AceTaskColor.NpcName, gobalnpcData.name)
	-- 		end
	-- 	else
	-- 		targetdesc = string.format(define.Task.AceTaskColor.NpcName, "无")
	-- 	end

	-- 	list.targetdesc = targetdesc
	-- 	list.detaildesc = data.taskdata.TASKTYPE[runringCateGoryId].desc
	-- 	list.name = data.taskdata.TASKTYPE[runringCateGoryId].name
	-- 	list.taskid = define.Task.AceTaskSpecial.RUNRING
	-- 	list.target = npcid
	-- 	list.isacetask = 1

	-- 	local oTask = CTask.New(list)
	-- 	self.m_AceTaskData[list.taskid] = oTask

	-- 	if iAddType == 1 then --添加
	-- 		if not self.m_AceTaskNotify[list.taskid] and not self.m_IsGhostAceNotify then
	-- 			self.m_AceTaskNotify[list.taskid] = 0
	-- 			self.m_IsGhostAceNotify = true
	-- 		end
	-- 	elseif iAddType == 2 then --删除
	-- 		self.m_AceTaskNotify[list.taskid] = nil
	-- 	end
	-- end

	if (self.m_TaskLoginInit and self:GetIsTypeExist(shiMenCategoryID)) or (g_OpenSysCtrl.m_SysOpenInit and not g_OpenSysCtrl:GetOpenSysState(define.System.Shimen)) or self.m_IsShimenDailyFull == 1 then
		self.m_AceTaskData[define.Task.AceTaskSpecial.SHIMEN] = nil
		self.m_AceTaskNotify[define.Task.AceTaskSpecial.SHIMEN] = nil
	end
	if (self.m_TaskLoginInit and self:GetIsTypeExist(ghostCateGoryID)) or (g_OpenSysCtrl.m_SysOpenInit and not g_OpenSysCtrl:GetOpenSysState(define.System.Ghost)) or isGhostScheduleDone then
		self.m_AceTaskData[define.Task.AceTaskSpecial.GHOST] = nil
		self.m_AceTaskNotify[define.Task.AceTaskSpecial.GHOST] = nil
	end
	if (self.m_TaskLoginInit and self:GetIsTypeExist(baotuCateGoryId)) or (g_OpenSysCtrl.m_SysOpenInit and not g_OpenSysCtrl:GetOpenSysState(define.System.Baotu)) or isBaotuScheduleDone then
		self.m_AceTaskData[define.Task.AceTaskSpecial.BAOTU] = nil
		self.m_AceTaskNotify[define.Task.AceTaskSpecial.BAOTU] = nil
	end
	-- if self:GetIsTypeExist(runringCateGoryId) or not g_OpenSysCtrl:GetOpenSysState(define.System.Runring) then
	-- 	self.m_AceTaskData[define.Task.AceTaskSpecial.RUNRING] = nil
	-- 	self.m_AceTaskNotify[define.Task.AceTaskSpecial.RUNRING] = nil
	-- end
	--保存可接任务红点数据
	self:SaveAceTaskNotifyData(self.m_AceTaskNotify)
	self:OnEvent(define.Task.Event.AddAceTaskNotify)
	self:OnEvent(define.Task.Event.RedPointNotify)
end

--刷新可接任务的数据
function CTaskCtrl.RefreshAceData(self)
	if g_KuafuCtrl:IsInKS() then
		self.m_AceTaskNotify = {}
		self.m_AceTaskData = {}
		self:OnEvent(define.Task.Event.AddAceTaskNotify)
		self:OnEvent(define.Task.Event.RedPointNotify)
		return
	end

	local aceList = {}
	local aceHelpList = {}
	for k,v in pairs(self.m_AceTaskidList) do
		local list = {}
		local config = DataTools.GetTaskData(v)

		-- 当前任务数据列表没有这个类型的数据或者这个可接任务数据是支线的
		if not self:GetIsTypeExist(config.type) or config.type == define.Task.TaskCategory.SIDE.ID or config.type == define.Task.TaskCategory.LEAD.ID then
			local gobalnpcData = DataTools.GetGlobalNpc(config.acceptNpcId)
			local npcid
			local targetdesc
			if gobalnpcData then
				local sceneName = DataTools.GetSceneNameByMapId(gobalnpcData.mapid)
				if sceneName ~= "" then
					targetdesc = string.format(define.Task.AceTaskColor.Map, sceneName)
					 .. "#D的#n" .. string.format(define.Task.AceTaskColor.NpcName, gobalnpcData.name)
				else
					targetdesc = string.format(define.Task.AceTaskColor.NpcName, gobalnpcData.name)
				end
			else
				targetdesc = string.format(define.Task.AceTaskColor.NpcName, "无")
			end
			npcid = config.acceptNpcId		

			list.targetdesc = targetdesc
			list.detaildesc = config.description
			list.name = string.gsub(config.name, "(.-)(%b())(.-)", "%1".."%2")
			list.taskid = v
			list.target = npcid
			list.isacetask = 1

			local oTask = CTask.New(list)
			aceList[list.taskid] = oTask	
			aceHelpList[list.taskid] = v	

			if not self.m_AceTaskNotify[v] then
				--可接任务未读是0
				self.m_AceTaskNotify[v] = 0
			end
		end
	end
	for k,v in pairs(self.m_AceTaskNotify) do
		if not table.index(aceHelpList, k) and not self:GetIsSpecialAceTask(k) then
			self.m_AceTaskNotify[k] = nil
		end
	end
	table.print(self.m_AceTaskNotify, "self.m_AceTaskNotify数据")
	--保存可接任务红点数据
	self:SaveAceTaskNotifyData(self.m_AceTaskNotify)
	self:OnEvent(define.Task.Event.AddAceTaskNotify)

	--保存可接任务数据
	local ShimenAceData = self.m_AceTaskData[define.Task.AceTaskSpecial.SHIMEN]
	local GhostAceData = self.m_AceTaskData[define.Task.AceTaskSpecial.GHOST]
	local BaotuAceData = self.m_AceTaskData[define.Task.AceTaskSpecial.BAOTU]
	self.m_AceTaskData = aceList
	self.m_AceTaskData[define.Task.AceTaskSpecial.SHIMEN] = ShimenAceData
	self.m_AceTaskData[define.Task.AceTaskSpecial.GHOST] = GhostAceData
	self.m_AceTaskData[define.Task.AceTaskSpecial.BAOTU] = BaotuAceData

	self:OnEvent(define.Task.Event.RedPointNotify)
end

------------------以下函数是任务的管理数据--------------------

--获取任务数据是否包含这个type的任务1.测试 2.主线 3.支线 4.师门等等
function CTaskCtrl.GetIsTypeExist(self, itype)
	for _,v in pairs(self.m_TaskDataDic) do
		if v:GetCValueByKey("type") == itype then
			return true
		end
	end
	return false
end

--获取是否还有可接任务未读取
function CTaskCtrl.GetIsAllAceTaskRead(self)
	local isRead = true
	for k,v in pairs(self.m_AceTaskNotify) do
		if v == 0 then
			isRead = false
			break
		end
	end
	return isRead
end

--以后要根据需求修改
--获取是否是师门或者抓鬼的特殊可接任务
function CTaskCtrl.GetIsSpecialAceTask(self, taskid)
	if taskid == define.Task.AceTaskSpecial.SHIMEN or taskid == define.Task.AceTaskSpecial.GHOST 
	or taskid == define.Task.AceTaskSpecial.BAOTU then --or taskid == define.Task.AceTaskSpecial.RUNRING
		return true
	end
	return false
end

--获取异宝的主任务的taskid
function CTaskCtrl.GetYibaoMainTaskid(self)
	return self.m_YibaoConfig[1]
end

function CTaskCtrl.CheckYibaoConfig(self)
	self.m_YibaoConfig = {}
	for k,v in pairs(data.taskdata.TASK.YIBAO.TASK) do
		local list = {taskid = k, taskdata = v}
		table.insert(self.m_YibaoConfig, list)
	end
	table.sort(self.m_YibaoConfig, function (a, b) return a.taskid < b.taskid end)
end

--获取是否是异宝的子任务
function CTaskCtrl.GetIsYibaoSubTask(self, type, taskid)
	if type and type == define.Task.TaskCategory.YIBAO.ID and self:GetYibaoMainTaskid().taskid ~= taskid then
		return true
	else
		return false
	end
end

function CTaskCtrl.GetZhenmoTask(self)
	for i, oTask in pairs(self.m_TaskDataDic) do
		local bZhenmoTask = self:GetZhenmoSubTask(oTask:GetCValueByKey("type"))
		if bZhenmoTask then
			return oTask
		end
	end
end

function CTaskCtrl.GetZhenmoSubTask(self, type)
	if type == 17 then
		return true
	else
		return false
	end
end

function CTaskCtrl.SavaTaskEffRecord(self, taskEffRecord)
	IOTools.SetRoleData("task_EffRecord", taskEffRecord)
end

function CTaskCtrl.SetRecordTask(self, oTask)
	if partTab > 0 then
		local mainMenu = oTask:GetCValueByKey("type") or 1
		local subMenu = oTask:GetSValueByKey("taskid")
		self.m_RecordTask.menu[partTab].mainMenu = self:GetTaskDiyType(mainMenu)
		self.m_RecordTask.menu[partTab].subMenu = subMenu
	end
end

function CTaskCtrl.SetRecordLogic(self, oTask)
	self.m_RecordLogic.oTask = oTask
end

function CTaskCtrl.CheckShimenEff(self)
	self.m_RecordLogic.shimenEff = false
	local date = g_TimeCtrl:GetTimeYMD()
	local nYMDs = string.split(string.split(date, "% ")[1], "%:")
	self.m_RecordTask.effect = IOTools.GetRoleData("task_EffRecord") or {}
	if self.m_RecordTask.effect.shimen and self.m_RecordTask.effect.shimen.date then
		local oYMDs = string.split(self.m_RecordTask.effect.shimen.date, "%:")
		for i,v in ipairs(nYMDs) do
			local o = oYMDs[i]
			if v > o then
				self.m_RecordLogic.shimenEff = true
			end
		end
	else
		self.m_RecordLogic.shimenEff = true
	end
	-- if self.m_RecordLogic.shimenEff then
	-- 	self.m_RecordTask.effect.shimen.date = nYMDs
	-- 	self:SavaTaskEffRecord(self.m_RecordTask.effect.shimen.date)
	-- end
end

--传的是clientnpcList,一个列表
function CTaskCtrl.DoCheckDynamicNpc(self, clientnpcList, addDyNpc)
	local curMapID = g_MapCtrl:GetMapID()
	if clientnpcList and #clientnpcList > 0 then
		for _,v in ipairs(clientnpcList) do
			if addDyNpc then
				if v.map_id == curMapID then
					local existInList = false
					for _,npc in ipairs(self.m_DynamicNpcList) do
						if v.npcid == npc.npcid then
							existInList = true
							break
						end
					end

					if not existInList then
						table.insert(self.m_DynamicNpcList, v)
					end
				end
			else
				for i,npc in ipairs(self.m_DynamicNpcList) do
					if v.npcid == npc.npcid then
						g_MapCtrl:DelDynamicNpc(v.npcid)
						v = nil
						table.remove(self.m_DynamicNpcList, i)
						break
					end
				end
			end
		end
	end
end

function CTaskCtrl.DoCheckPickModel(self, oTask, addPick)
	if oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_PICK) then
		-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "DoCheckPickModel", "检查采集类型任务Model"))
		if oTask.m_Finish then
			return
		end

		local pickThing = oTask:GetProgressThing()
		if pickThing then
			if addPick then
				if CTaskHelp.IsSpecityCurMap(pickThing.map_id) then
					local existInList = false
					for _,pick in ipairs(self.m_PickItemList) do
						if pickThing.pickid == pick.pickid then
							existInList = true
							break
						end
					end

					if not existInList then
						table.insert(self.m_PickItemList, pickThing)
					end
				end
			else
				for i,pick in ipairs(self.m_PickItemList) do
					if pickThing.pickid == pick.pickid then
						g_MapCtrl:DelTaskPickItem(pickThing.pickid)
						pickThing = nil
						table.remove(self.m_PickItemList, i)
						break
					end
				end
			end
		end
	end
end

function CTaskCtrl.DelTaskTypeTable(self, task)
	if task then
		local tasktype = task:GetSValueByKey("tasktype")
		local taskid = task:GetSValueByKey("taskid")
		local tTasks = self.m_TaskTypeDic[tasktype]
		if tTasks and tTasks[taskid] then
			tTasks[taskid] = nil
		end
	end
end

-- [[数据获取]]
function CTaskCtrl.GetTaskDataList(self)
	return self.m_TaskDataDic
end

--屏蔽掉一些不需要显示的任务
function CTaskCtrl.CheckIsNotNeedShowTask(self, oTask)
	local bYibaoTask = self:GetIsYibaoSubTask(oTask:GetCValueByKey("type"), oTask:GetSValueByKey("taskid"))
	local bZhenmoTask = self:GetZhenmoSubTask(oTask:GetCValueByKey("type"))
	local oType = oTask:GetCValueByKey("type") or define.Task.TaskCategory.TEST.ID
	if bYibaoTask or bZhenmoTask or ( g_KuafuCtrl:IsInKS() and not table.index(data.kuafudata.CONFIG[1].task_show, oType) ) then
		return true
	end
end

--这里对应主界面的任务导航框的排序后的任务数据
function CTaskCtrl.GetTaskDataListWithSort(self)
	local list = {}
	local tasklist = {}
	for k, oTask in pairs(self.m_TaskDataDic) do		
		if not self:CheckIsNotNeedShowTask(oTask) then
			tasklist[k] = oTask
		end
	end
	for _,v in pairs(tasklist) do
		table.insert(list, v)
	end
	
	table.sort(list, self.SortTaskData)
	return list
end

--按照 (火眼金睛最前面, 策划要求) 1)副本任务> 2)主线剧情 > 3)剩余其他的任务排序
--以后要根据需求修改
--任务主界面跟主界面的任务栏的排序不一样
function CTaskCtrl.SortTaskData(taskA, taskB)
	local type1 = g_TaskCtrl:GetMainMenuTaskType(taskA:GetCValueByKey("type"))
	local type2 = g_TaskCtrl:GetMainMenuTaskType(taskB:GetCValueByKey("type"))
	if type1 ~= type2 then
		return type1 < type2
	else
		local oTime1 = taskA:GetSValueByKey("create_time")
		local oTime2 = taskB:GetSValueByKey("create_time")
		if oTime1 ~= oTime2 then
			return oTime1 > oTime2
		else
			return taskA:GetSValueByKey("taskid") < taskB:GetSValueByKey("taskid")
		end
	end
end

function CTaskCtrl.GetMainMenuTaskType(self, oType)
	if oType == define.Task.TaskCategory.FUBEN.ID or oType == define.Task.TaskCategory.JYFUBEN.ID then
		return 1
	elseif oType == define.Task.TaskCategory.GUESSGAME.ID then
		return 1
	elseif oType == define.Task.TaskCategory.STORY.ID then
		return 2
	else
		return 3
	end
end

function CTaskCtrl.GetSpecityTask(self, taskid)
	local oTask = self.m_TaskDataDic[taskid]
	return oTask
end

-- [[MainMenuUI]]
--[[获取任务数据菜单，返回 Table:
	taskMenu = {
		[type1] = {sort = 1, taskList1 = {task1, task2, ...}}
		[type2] = {sort = 2, taskList2 = {task1, task2, ...}}
	}]]
--这里传的iType不是单个任务里面的type，而是自定义的type，参考下边罗列的
function CTaskCtrl.GetTaskMenu(self, partTab, iType)
	-- 默认取挂载的任务数据
	-- if exist == nil then
	-- 	exist = true
	-- end
	if partTab then
		if partTab == 1 then
			return self:GetTaskMenuHelp(iType, self.m_TaskDataDic)
		elseif partTab == 2 then
			table.print(self.m_AceTaskData, "可接任务的数据")
			return self:GetTaskMenuHelp(iType, self.m_AceTaskData)
		else
			return nil
		end
	else
		return nil
	end
end

--以后要根据需求修改
--任务主界面跟主界面的任务栏的排序不一样
function CTaskCtrl.GetTaskMenuHelp(self, iType, DataList)
	--自定义一个任务显示的type,1)副本任务> 2)主线剧情 > 3)虚拟的特殊任务 > 4)日常任务 > 5)活动任务 > 6)引导任务 > 7)支线任务 > 8)帮派任务 > 9)场景任务 > 10)测试任务
	local taskMenu = {}
	for i=1, 10, 1 do
		local list = {type = i, taskList = {}}
		table.insert(taskMenu, list)
	end
	for _,task in pairs(DataList) do
		local type = task:GetCValueByKey("type") or define.Task.TaskCategory.TEST.ID
		if not self:CheckIsNotNeedShowTask(task) then
			if type == define.Task.TaskCategory.TEST.ID then
				table.insert(taskMenu[10].taskList, task)
			elseif type == define.Task.TaskCategory.STORY.ID then
				table.insert(taskMenu[2].taskList, task)
			elseif type == define.Task.TaskCategory.GHOST.ID or type == define.Task.TaskCategory.SHIMEN.ID then
				table.insert(taskMenu[5].taskList, task)
			elseif type == define.Task.TaskCategory.SIDE.ID then
				table.insert(taskMenu[7].taskList, task)
			elseif type == define.Task.TaskCategory.YIBAO.ID then
				table.insert(taskMenu[3].taskList, task)
			elseif type == define.Task.TaskCategory.SCHOOLPASS.ID then 
				table.insert(taskMenu[9].taskList, task)
			elseif type == define.Task.TaskCategory.FUBEN.ID then
				table.insert(taskMenu[1].taskList, task)
			elseif type == define.Task.TaskCategory.ORG.ID then
				table.insert(taskMenu[5].taskList, task)
			elseif type == define.Task.TaskCategory.LINGXI.ID then
				table.insert(taskMenu[5].taskList, task)
			elseif type == define.Task.TaskCategory.LEAD.ID then
				table.insert(taskMenu[6].taskList, task)
			elseif type == define.Task.TaskCategory.GUESSGAME.ID then
				table.insert(taskMenu[1].taskList, task)
			elseif type == define.Task.TaskCategory.JYFUBEN.ID then
				table.insert(taskMenu[1].taskList, task)
			elseif type == define.Task.TaskCategory.BAOTU.ID then
				table.insert(taskMenu[5].taskList, task)
			elseif type == define.Task.TaskCategory.RUNRING.ID then
				table.insert(taskMenu[5].taskList, task)
			elseif type == define.Task.TaskCategory.XUANSHANG.ID then
				table.insert(taskMenu[5].taskList, task)
			elseif type == define.Task.TaskCategory.ZHENMO.ID then
				table.insert(taskMenu[5].taskList, task)
			elseif type == define.Task.TaskCategory.TREASURECONVOY.ID then 
				table.insert(taskMenu[5].taskList, task)
			elseif type == define.Task.TaskCategory.IMPERIALEXAM.ID then 
				table.insert(taskMenu[5].taskList, task)
			else
				table.insert(taskMenu[10].taskList, task)
			end
		end
	end

	for k,v in ipairs(taskMenu) do
		if next(v.taskList) then
			table.sort(v.taskList, self.SortTaskData)
		end
	end

	if not iType then
		local isEmpty = true
		for k,v in pairs(taskMenu) do
			if next(v.taskList) then
				isEmpty = false
				break
			end
		end
		if isEmpty then
			return nil
		else
			return taskMenu
		end
	else
		if taskMenu[iType] then
			return taskMenu[iType]
		else
			return nil
		end
	end
end

--获取任务类型对应的自定义的任务类型，传任务的GetCValueByKey("type")
--以后要根据需求修改
--任务主界面跟主界面的任务栏的排序不一样
function CTaskCtrl.GetTaskDiyType(self, type)
	if type == define.Task.TaskCategory.TEST.ID then
		return 10
	elseif type == define.Task.TaskCategory.STORY.ID then
		return 2
	elseif type == define.Task.TaskCategory.GHOST.ID or type == define.Task.TaskCategory.SHIMEN.ID then
		return 5
	elseif type == define.Task.TaskCategory.SIDE.ID then
		return 7
	elseif type == define.Task.TaskCategory.YIBAO.ID then
		return 3
	elseif type == define.Task.TaskCategory.SCHOOLPASS.ID then
		return 9
	elseif type == define.Task.TaskCategory.FUBEN.ID then
		return 1
	elseif type == define.Task.TaskCategory.ORG.ID then
		return 5
	elseif type == define.Task.TaskCategory.LINGXI.ID then
		return 5
	elseif type == define.Task.TaskCategory.LEAD.ID then
		return 6
	elseif type == define.Task.TaskCategory.GUESSGAME.ID then
		return 1
	elseif type == define.Task.TaskCategory.JYFUBEN.ID then
		return 1
	elseif type == define.Task.TaskCategory.BAOTU.ID then
		return 5
	elseif type == define.Task.TaskCategory.RUNRING.ID then
		return 5
	elseif type == define.Task.TaskCategory.XUANSHANG.ID then
		return 5
	elseif type == define.Task.TaskCategory.ZHENMO.ID then
		return 5
	elseif type == define.Task.TaskCategory.TREASURECONVOY.ID then 
		return 5
	elseif type == define.Task.TaskCategory.IMPERIALEXAM.ID then 
		return 5
	else
		return 10
	end
end

-- [[逻辑处理]]
-- 获取指定Npc相关任务
function CTaskCtrl.GetNpcAssociatedTaskList(self, npcid)
	local taskList = {}
	if npcid and npcid > 0 then
		
		for _,v in pairs(self.m_TaskDataDic) do
			local associated = v:AssociatedNpc(npcid)
			if associated then
				table.insert(taskList, v)
			end
		end
		--这里是未领取的可接任务
		for k,v in pairs(self.m_AceTaskData) do
			-- printc("获取指定Npc相关任务npcid", npcid, " clientnpc", v:GetSValueByKey("clientnpc")[1].npcid)
			local associated = v:AceTaskAssociatedNpc(npcid)
			if associated then
				table.insert(taskList, v)
			end
		end
	end

	table.sort(taskList, self.SortTaskData)
	-- print(string.format("<color=#00FF00> >>> %s.%s | 查看NpcID：%s 相关任务表数据 | %s </color>", self.classname, "GetNpcAssociatedTaskList", npcid, "taskList"))
	-- table.print(taskList)
	return taskList
end

-- 获取指定Pick相关任务
function CTaskCtrl.GetPickAssociatedTaskList(self, pickid)
	local taskList = {}
	if pickid and pickid > 0 then
		for _,v in pairs(self.m_TaskDataDic) do
			local associated = v:AssociatedPick(pickid)
			if associated then
				table.insert(taskList, v)
			end
		end
	end
	-- print(string.format("<color=#00FF00> >>> %s.%s | 查看PickID：%s 相关任务表数据 | %s </color>", self.classname, "GetNpcAssociatedTaskList", pickid, "taskList"))
	-- table.print(taskList)
	return taskList
end

------------------以下的函数是刷新任务导航框、NPC头顶标识、NPC和Pick模型等等------------------

function CTaskCtrl.CheckTaskThing(self)
	if g_MapCtrl.m_IsInPlot then
		return
	end
	if self.m_RecordLogic.oTask then
		-- 自动寻路
		CTaskHelp.ClickTaskLogic(self.m_RecordLogic.oTask)
	end
	self:CheckNpcMark()
	self:CheckTaskModel()
end

function CTaskCtrl.CheckTaskModel(self)
	g_MapCtrl:DelAllDynamicNpc()
	self.m_DynamicNpcList = {}
	self.m_PickItemList = {}
	for _,v in pairs(self.m_TaskDataDic) do
		self:DoCheckDynamicNpc(v:GetSValueByKey("clientnpc"), true)
		self:DoCheckPickModel(v, true)
	end
	self:RefreshTaskModel()
end

-- [[界面刷新]]
function CTaskCtrl.RefreshUI(self)
	if self.m_RefreshTimerUI then
		Utils.DelTimer(self.m_RefreshTimerUI)
	end
	local function update()
		self:OnEvent(define.Task.Event.RefreshAllTaskBox)
		return false
	end
	self.m_RefreshTimerUI = Utils.AddTimer(update, 0.2, 0.2)
end

function CTaskCtrl.RefreshMark(self)
	if self.m_RefreshTimerMark then
		Utils.DelTimer(self.m_RefreshTimerMark)
	end
	local function update()
		g_MapCtrl:RefreshTaskNpcMark()
		return false
	end
	self.m_RefreshTimerMark = Utils.AddTimer(update, 0.3, 0.3)
end

-- arg = {taskid = a, task = b}
function CTaskCtrl.RefreshSpecityBoxUI(self, arg)
	local taskid = arg.taskid
	if not taskid then
		if not arg.task then
			return
		end
		taskid = arg.task:GetSValueByKey("taskid")
	end

	-- 任务信息事件Fire
	self:OnEvent(define.Task.Event.RefreshSpecificTaskBox, taskid)
end

function CTaskCtrl.RefreshTaskModel(self)
	self:RefreshDynamicNpc()
	self:RefreshPickItem()
end

function CTaskCtrl.RefreshDynamicNpc(self)
	for _,v in ipairs(self.m_DynamicNpcList) do
		g_MapCtrl:AddDynamicNpc(v)
	end
end

function CTaskCtrl.RefreshPickItem(self)
	for _,v in ipairs(self.m_PickItemList) do
		g_MapCtrl:AddTaskPickItem(v)
	end
end

-- [[检查Npc头顶标识]]
function CTaskCtrl.CheckNpcMark(self)
	self.m_NpcMarkDic = {}
	-- 可接任务检查
	for _, oTask in pairs(self.m_AceTaskData) do
		self:RecheckAceTaskNpcMark(oTask)
	end

	-- 已存在的任务检查
	for _,oTask in pairs(self.m_TaskDataDic) do
		self:RecheckTaskNpcMark(oTask)
	end

	-- table.print(self.m_NpcMarkDic)
	
	-- 遍历Npc，刷新头顶标识

	self:RefreshMark()
end

function CTaskCtrl.RecheckAceTaskNpcMark(self, oTask)
	local targetNpcId = oTask:GetSValueByKey("target")
	if not targetNpcId then
		return
	end
	local npcMarkEnum = enum.Task.NpcMark
	local mark = npcMarkEnum.Ace

	if not self.m_NpcMarkDic[targetNpcId] then
		self.m_NpcMarkDic[targetNpcId] = {}
	end

	-- 判定是否Global Npc
	if data.npcdata.NPC.GLOBAL_NPC[targetNpcId] then
		self.m_NpcMarkDic[targetNpcId]["globalNpc"] = mark
		return
	end

	local typeID = oTask:GetCValueByKey("type")
	local category = nil
	for _,v in pairs(define.Task.TaskCategory) do
		if v.ID == typeID then
			category = v
			local func_group = "task." .. category.FUNCGROUP
			self.m_NpcMarkDic[targetNpcId][func_group] = mark
			break
		end
	end
end

function CTaskCtrl.RecheckTaskNpcMark(self, oTask, refRealTime)
	local isTaskFight = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_NPC_FIGHT)
	local isTaskAnlei = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_ANLEI)
	local isTaskFindMan = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_NPC)
	local isTaskStory = oTask:IsTaskSpecityCategory(define.Task.TaskCategory.STORY)
	local targetNpcId = oTask:GetSValueByKey("target")
	local submitNpcId = oTask:GetCValueByKey("submitNpcId")
	local npcMarkEnum = enum.Task.NpcMark
	local npcTypeList = {}
	if targetNpcId == submitNpcId then
		npcTypeList = {targetNpcId}
	else
		npcTypeList = {
			targetNpcId,
			submitNpcId,
		}
	end

	for _,npcType in ipairs(npcTypeList) do
		local mark = npcMarkEnum.Nothing

		if isTaskStory then
			mark = npcMarkEnum.Main
			if isTaskFight or isTaskAnlei then
				mark = npcMarkEnum.War
				if oTask.m_Finish then
					mark = npcMarkEnum.End
				end
			elseif isTaskFindMan then
			else
				if oTask.m_Finish then
					mark = npcMarkEnum.End
				else
					mark = npcMarkEnum.Pro
				end
			end
		else
			if isTaskFight or isTaskAnlei then
				mark = npcMarkEnum.War
				if oTask.m_Finish then
					mark = npcMarkEnum.End
				end
			else
				if oTask.m_Finish then
					mark = npcMarkEnum.End
				else
					mark = npcMarkEnum.Pro
				end
			end
		end
		
		local typeID = oTask:GetCValueByKey("type")
		local category = nil
		local isGlobalNpc = data.npcdata.NPC.GLOBAL_NPC[npcType] and true or false
		for _,v in pairs(define.Task.TaskCategory) do
			if v.ID == typeID then
				category = v
				local func_group = isGlobalNpc and "globalNpc" or "task." .. category.FUNCGROUP
				if not self.m_NpcMarkDic[npcType] then
					self.m_NpcMarkDic[npcType] = {}
				end
				local curMark = self.m_NpcMarkDic[npcType][func_group]
				if not curMark or curMark < mark then
					self.m_NpcMarkDic[npcType][func_group] = mark
				end

				if refRealTime then
					g_MapCtrl:RefreshSpecityTaskNpcMark(npcType, func_group, mark)
				end
				break
			end
		end
	end
end

-- 获取指定Npc头顶状态
function CTaskCtrl.GetNpcAssociatedTaskMark(self, npcid, func_group)
	-- printc("寻找Npc头顶标识：NpcID", npcid)

	if self.m_NpcMarkDic[npcid] then
		if data.npcdata.NPC.GLOBAL_NPC[npcid] or func_group == nil or func_group == "globalNpc" then
			func_group = "globalNpc"
		end
		if self.m_NpcMarkDic[npcid][func_group] then
			local markID = self.m_NpcMarkDic[npcid][func_group]
			return self:GetNpcMarkSprName(markID)
		end
	end
end

function CTaskCtrl.GetNpcMarkSprName(self, markID)
	if markID and markID > 0 then
		-- printc("标识名称", CTaskCtrl.g_NpcMarkSprName[markID])
		return CTaskCtrl.g_NpcMarkSprName[markID]
	end
end


-- [==[寻物、寻宠任务检查]==]
function CTaskCtrl.CheckTaskFindThing(self)
	self:CheckFindItem()
	self:CheckFindSummon()
end

-- [[检查寻找道具任务，是否变更状态]]
function CTaskCtrl.CheckFindItem(self)
	local tTasks = self.m_TaskTypeDic[define.Task.TaskType.TASK_FIND_ITEM]
	if tTasks then
		for _,oTask in pairs(tTasks) do
			self:CheckFindItemFinish(oTask)
		end
	end
end

function CTaskCtrl.CheckFindItemFinish(self, oTask)
	if not oTask or not oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM) then
		return
	end
	local refresh = oTask:CheckFindItemFinish()
	if refresh then
		self:RefreshSpecityBoxUI({task = oTask})
		self:RecheckTaskNpcMark(oTask, true)
	end
end

-- [[检查寻找宠物任务，是否变更状态]]
function CTaskCtrl.CheckFindSummon(self)
	-- print(string.format("<color=#00FFFF> >>> .%s | 程序执行到这里了 | %s </color>", "CheckFindSummon", "检查宠物任务，是否变更状态(参考:self:CheckFindItem)"))
	local tTasks = self.m_TaskTypeDic[define.Task.TaskType.TASK_FIND_SUMMON]
	if tTasks then
		for _,oTask in pairs(tTasks) do
			self:CheckFindSummonFinish(oTask)
		end
	end
end

function CTaskCtrl.CheckFindSummonFinish(self, oTask)
	if not oTask or not oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON) then
		return
	end
	local refresh = oTask:CheckFindSummonFinish()
	if refresh then
		self:RefreshSpecityBoxUI({task = oTask})
		self:RecheckTaskNpcMark(oTask, true)
	end
end



-- [==[对话、战斗任务检查]==]
function CTaskCtrl.CheckTaskTargetThing(self)
	self:CheckFindNpc()
	self:CheckFight()
end

-- [[检查Npc对话任务，是否变更状态]]
function CTaskCtrl.CheckFindNpc(self)
	local tTasks = self.m_TaskTypeDic[define.Task.TaskType.TASK_FIND_NPC]
	if tTasks then
		for _,v in pairs(tTasks) do
			self:CheckTaskTargetFinish(v)
		end
	end
end

-- [[检查战斗任务，是否变更状态]]
function CTaskCtrl.CheckFight(self)
	local tTasks = self.m_TaskTypeDic[define.Task.TaskType.TASK_NPC_FIGHT]
	if tTasks then
		for _,v in pairs(tTasks) do
			self:CheckTaskTargetFinish(v)
		end
	end
end

function CTaskCtrl.CheckTaskTargetFinish(self, oTask)
	if oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_NPC) then --or oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_NPC_FIGHT)
		local target = oTask:GetSValueByKey("target")
		local submitNpcId = oTask:GetCValueByKey("submitNpcId")
		local finish = target == submitNpcId
		oTask.m_Finish = finish
		self:RefreshSpecityBoxUI({task = oTask})
	end
end



-- [==[使用物品、采集任务检查]==]
function CTaskCtrl.CheckTaskItemThing(self)
	self:CheckItemUse()
	self:CheckItemPick()
end

-- [[检查使用物品任务]]
function CTaskCtrl.CheckItemUse(self)
	printc("检查使用物品任务")
end

-- [[检查采集任务]]
function CTaskCtrl.CheckItemPick(self)
	printc("检查采集任务")
end

-------------------其他的一些逻辑---------------------

--保存可接任务红点通知数据在本地
function CTaskCtrl.SaveAceTaskNotifyData(self, t)
	if g_AttrCtrl.pid == 0 then
		return
	end
	local path = IOTools.GetRoleFilePath("/acetasknotify")
	IOTools.SaveJsonFile(path, t)
end

--获取可接任务红点通知数据
--本地保存文件会把key变为字符串,{"12":1}
function CTaskCtrl.GetAceTaskNotifySaveData(self)
	if g_AttrCtrl.pid == 0 then
		return
	end
	if g_KuafuCtrl:IsInKS() then
		return
	end
	if not self.m_IsLoadNotifyData then
		self.m_AceTaskNotify = {}
		local path = IOTools.GetRoleFilePath("/acetasknotify")
		local t = IOTools.LoadJsonFile(path) or {}
		for k,v in pairs(t) do
			self.m_AceTaskNotify[tonumber(k)] = v
		end
		self.m_AceTaskNotify[define.Task.AceTaskSpecial.SHIMEN] = 0
		self.m_AceTaskNotify[define.Task.AceTaskSpecial.GHOST] = 0
		self.m_AceTaskNotify[define.Task.AceTaskSpecial.BAOTU] = 0
		self:OnEvent(define.Task.Event.RedPointNotify)
		self.m_IsLoadNotifyData = true
	end
end

function CTaskCtrl.SetTaskTime(self, taskid)	
	if self.m_CurLeftTimeList[taskid] and self.m_CurLeftTimeList[taskid] > 0 then
		self:ResetTaskTimer(taskid)
		local function progress()
			self.m_CurLeftTimeList[taskid] = self.m_CurLeftTimeList[taskid] - 1

			self:OnEvent(define.Task.Event.TaskCountTime, taskid)
			
			if self.m_CurLeftTimeList[taskid] <= 0 then
				self.m_CurLeftTimeList[taskid] = 0

				self:OnEvent(define.Task.Event.TaskCountTime, taskid)
				return false
			end
			return true
		end
		self.m_CurLeftTimeList[taskid] = self.m_CurLeftTimeList[taskid] + 1
		self.m_TaskTimer[taskid] = Utils.AddTimer(progress, 1, 0)
	else
		self:OnEvent(define.Task.Event.TaskCountTime, taskid)
	end
end

function CTaskCtrl.ResetTaskTimer(self, taskid)
	if self.m_TaskTimer[taskid] then
		Utils.DelTimer(self.m_TaskTimer[taskid])
		self.m_TaskTimer[taskid] = nil			
	end
end

function CTaskCtrl.SetTaskLegendTime(self, taskid)	
	if self.m_LegendLeftTimeList[taskid] and self.m_LegendLeftTimeList[taskid] > 0 then
		self:ResetTaskLegendTimer(taskid)
		local function progress()
			self.m_LegendLeftTimeList[taskid] = self.m_LegendLeftTimeList[taskid] - 1

			self:OnEvent(define.Task.Event.TaskLegendCountTime, taskid)
			
			if self.m_LegendLeftTimeList[taskid] <= 0 then
				self.m_LegendLeftTimeList[taskid] = 0

				self:OnEvent(define.Task.Event.TaskLegendCountTime, taskid)
				return false
			end
			return true
		end
		self.m_LegendLeftTimeList[taskid] = self.m_LegendLeftTimeList[taskid] + 1
		self.m_TaskLegendTimer[taskid] = Utils.AddTimer(progress, 1, 0)
	else
		self:OnEvent(define.Task.Event.TaskLegendCountTime, taskid)
	end
end

function CTaskCtrl.ResetTaskLegendTimer(self, taskid)
	if self.m_TaskLegendTimer[taskid] then
		Utils.DelTimer(self.m_TaskLegendTimer[taskid])
		self.m_TaskLegendTimer[taskid] = nil			
	end
end

function CTaskCtrl.SetTaskRectEffect(self)	
	self:ResetTaskRectEffectTimer()
	local function progress()
		self.m_TaskRectEffectTime = self.m_TaskRectEffectTime - 0.1
		self.m_TaskBoxIsMoving = true
		
		if self.m_TaskRectEffectTime <= 0 then
			self.m_TaskRectEffectTime = 0
			self.m_TaskBoxIsMoving = false

			self:OnEvent(define.Task.Event.TaskRectEffect)
			return false
		end
		return true
	end
	self.m_TaskRectEffectTime = 0.6 + 0.1
	self.m_TaskRectEffectTimer = Utils.AddTimer(progress, 0.1, 0)
end

function CTaskCtrl.ResetTaskRectEffectTimer(self)
	if self.m_TaskRectEffectTimer then
		Utils.DelTimer(self.m_TaskRectEffectTimer)
		self.m_TaskRectEffectTimer = nil			
	end
end

function CTaskCtrl.SetEyeCountTime(self)
	self:ResetEyeTimer()
	local function progress()
		self.m_EyeLeftTime = self.m_EyeLeftTime - 0.1
		self:OnEvent(define.Task.Event.EyeCountTime)
		
		if self.m_EyeLeftTime <= -0.1 then
			self.m_EyeLeftTime = -0.1
			self:OnEvent(define.Task.Event.EyeCountTime)

			return false
		end
		return true
	end
	self.m_EyeLeftTime = define.Task.Time.GhostEyeCircleDurationTime + 0.1
	self.m_EyeTimer = Utils.AddTimer(progress, 0.1, 0)
end

function CTaskCtrl.ResetEyeTimer(self)
	if self.m_EyeTimer then
		Utils.DelTimer(self.m_EyeTimer)
		self.m_EyeTimer = nil			
	end
end

function CTaskCtrl.SetEyeCloseCountTime(self)
	self:ResetEyeCloseTimer()
	local function progress()
		self.m_EyeCloseLeftTime = self.m_EyeCloseLeftTime - 0.1
		self:OnEvent(define.Task.Event.EyeCloseCountTime)
		
		if self.m_EyeCloseLeftTime <= -0.1 then
			self.m_EyeCloseLeftTime = -0.1
			self:OnEvent(define.Task.Event.EyeCloseCountTime)

			return false
		end
		return true
	end
	self.m_EyeCloseLeftTime = define.Task.Time.GhostEyeCircleDurationTime + 0.1
	self.m_EyeCloseTimer = Utils.AddTimer(progress, 0.1, 0)
end

function CTaskCtrl.ResetEyeCloseTimer(self)
	if self.m_EyeCloseTimer then
		Utils.DelTimer(self.m_EyeCloseTimer)
		self.m_EyeCloseTimer = nil			
	end
end

function CTaskCtrl.SetGhostEyeEffectForward(self)
	self:ResetGhostEyeEffectForwardTimer()
	local function progress()
		self:OnEvent(define.Task.Event.GhostEyeEffectForward)
		return true
	end
	self.m_ForwardTimer = Utils.AddTimer(progress, define.Task.Time.GhostEyeDurationTime*4, 0)
end

function CTaskCtrl.ResetGhostEyeEffectForwardTimer(self)
	if self.m_ForwardTimer then
		Utils.DelTimer(self.m_ForwardTimer)
		self.m_ForwardTimer = nil			
	end
end

function CTaskCtrl.SetGhostEyeEffectReverse(self)
	self:ResetGhostEyeEffectReverseTimer()
	local function progress()
		self:OnEvent(define.Task.Event.GhostEyeEffectReverse)
		return true
	end
	self.m_ReverseTimer = Utils.AddTimer(progress, define.Task.Time.GhostEyeDurationTime*4, define.Task.Time.GhostEyeDurationTime*2)
end

function CTaskCtrl.ResetGhostEyeEffectReverseTimer(self)
	if self.m_ReverseTimer then
		Utils.DelTimer(self.m_ReverseTimer)
		self.m_ReverseTimer = nil			
	end
end

-------------------新加的一些接口-----------------
--获取任务物品预计消耗记录，避免多任务同物品导致物品不足
function CTaskCtrl.GetBagItemAmountRecord(self, itemid, bRecord, oQualityMax)
	local iBagAmount = g_ItemCtrl:GetBagItemAmountBySid(itemid, oQualityMax) 
	if not bRecord then
		return iBagAmount
	end
	local iAmount = self.m_BagItemRecord[itemid]
	if not iAmount then
		self.m_BagItemRecord[itemid] = iBagAmount
		iAmount = iBagAmount
	end
	if self.m_BagItemRecord[itemid] > 0 then 
		self.m_BagItemRecord[itemid] = self.m_BagItemRecord[itemid] - 1
	end
	--table.print(self.m_BagItemRecord, "物品數量")
	return iAmount	
end

--获取只是寻物类型的任务的itemlist,considerAmount true会考虑到已拥有的道具的数量
function CTaskCtrl.GetTaskNeedItemList(self, oTask, considerAmount, bRecord)
	local list = {}
	if oTask and oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM) then
		local oLimitQuality = oTask:GetLimitQuality()
		if oTask:GetSValueByKey("needitem") then
			for k,v in pairs(oTask:GetSValueByKey("needitem")) do
				if considerAmount then
					if self:GetBagItemAmountRecord(v.itemid, bRecord, oLimitQuality) < v.amount then
						table.insert(list, v.itemid)
					end
				else
					table.insert(list, v.itemid)
				end
			end
		end
		if oTask:GetSValueByKey("needitemgroup") then
			for k,v in pairs(oTask:GetSValueByKey("needitemgroup")) do
				local tItemData = DataTools.GetItemData(v.groupid, "ITEMGROUP")
				if tItemData then
					if considerAmount then
						local count = 0
						for g,h in pairs(tItemData.itemgroup) do
							count = count + self:GetBagItemAmountRecord(h, bRecord, oLimitQuality)
						end

						if count < v.amount then
							for g,h in pairs(tItemData.itemgroup) do
								table.insert(list, h)
							end
						end
					else
						for g,h in pairs(tItemData.itemgroup) do
							table.insert(list, h)
						end
					end
				end
			end
		end
	end
	return list
end

function CTaskCtrl.GetTaskNeedItemAmount(self, oTask)
	local oAmount = 0
	if oTask and oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM) then
		if oTask:GetSValueByKey("needitem") then
			for k,v in pairs(oTask:GetSValueByKey("needitem")) do
				oAmount = oAmount + v.amount
			end
		end
		if oTask:GetSValueByKey("needitemgroup") then
			for k,v in pairs(oTask:GetSValueByKey("needitemgroup")) do
				oAmount = oAmount + v.amount
			end
		end
	end
	return oAmount
end

--获取所有任务里面的寻物类型任务的itemlist,considerAmount true会考虑到已拥有的道具的数量
function CTaskCtrl.GetAllTaskNeedItemList(self, considerAmount)
	self.m_BagItemRecord = {}
	local list = {}
	for k,v in pairs(self.m_HelpOtherTaskData) do
		for g,h in pairs(self:GetTaskNeedItemList(v, considerAmount)) do
			table.insert(list, h)
		end
	end
	for k,v in pairs(self.m_TaskDataDic) do
		for g,h in pairs(self:GetTaskNeedItemList(v, considerAmount)) do
			table.insert(list, h)
		end
	end	
	return list
end

function CTaskCtrl.GetAllTaskNeedItemDictionary(self, considerAmount, bRecord)
	--使用物品记录前需清理
	self.m_BagItemRecord = {}
	local dict = {}
	for k,v in pairs(self.m_HelpOtherTaskData) do
		dict[v:GetSValueByKey("taskid")] = self:GetTaskNeedItemList(v, considerAmount, bRecord)
	end
	for k,v in pairs(self.m_TaskDataDic) do
		if dict[v:GetSValueByKey("taskid")] then
			local oNeedList = self:GetTaskNeedItemList(v, considerAmount, bRecord)
			for g,h in ipairs(oNeedList) do
				table.insert(dict[v:GetSValueByKey("taskid")], h)
			end
		else
			dict[v:GetSValueByKey("taskid")] = self:GetTaskNeedItemList(v, considerAmount, bRecord)
		end
	end	
	return dict
end

function CTaskCtrl.GetIsTaskNeedItem(self, itemid)
	for k,v in pairs(self:GetAllTaskNeedItemList(true)) do
		if itemid == v then
			return true
		end
	end
end

--获取只是寻宠类型的任务的sumlist,considerAmount true会考虑到已拥有的道具的数量
function CTaskCtrl.GetTaskNeedSumList(self, oTask, considerAmount)
	local list = {}
	if oTask and oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON) then
		if oTask:GetSValueByKey("needsum") then
			for k,v in pairs(oTask:GetSValueByKey("needsum")) do
				if considerAmount then
					local oAmount
					if oTask:GetAllowBB() then
						oAmount = self:GetSumAmountByTypeId(v.sumid, true)
					else
						oAmount = self:GetSumAmountByTypeId(v.sumid)
					end
					if oAmount < v.amount then
						table.insert(list, v.sumid)
					end
				else
					table.insert(list, v.sumid)
				end
			end
		end
	end
	return list
end

function CTaskCtrl.GetTaskNeedSumAmount(self, oTask)
	local oAmount = 0
	if oTask and oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON) then
		if oTask:GetSValueByKey("needsum") then
			for k,v in pairs(oTask:GetSValueByKey("needsum")) do
				oAmount = oAmount + v.amount
			end
		end
	end
	return oAmount
end

function CTaskCtrl.GetSumAmountByTypeId(self, sumtypeid, isBaoBaoSubmit)
	local count = 0
	local summons = g_SummonCtrl:GetSummons()
	for _,sum in pairs(summons) do
		if isBaoBaoSubmit then
			if sum.typeid == sumtypeid and sum.key ~= 1 and (sum.type == 1 or (sum.type == 2 and sum.zhenpin == 0)) and sum.id ~= g_SummonCtrl.m_FightId then --or sum.grade == 0
				count = count + 1
			end
		else
			if sum.typeid == sumtypeid and sum.key ~= 1 and (sum.type == 1) and sum.id ~= g_SummonCtrl.m_FightId then --or sum.grade == 0
				count = count + 1
			end
		end
	end
	return count
end

--获取所有任务里面的寻宠类型任务的itemlist,considerAmount true会考虑到已拥有的道具的数量
function CTaskCtrl.GetAllTaskNeedSumList(self, considerAmount)
	local list = {}
	for k,v in pairs(self.m_HelpOtherTaskData) do
		for g,h in pairs(self:GetTaskNeedSumList(v, considerAmount)) do
			table.insert(list, h)
		end
	end
	for k,v in pairs(self.m_TaskDataDic) do
		for g,h in pairs(self:GetTaskNeedSumList(v, considerAmount)) do
			table.insert(list, h)
		end
	end
	return list
end

function CTaskCtrl.GetIsTaskNeedSum(self, sumid)
	for k,v in pairs(self:GetAllTaskNeedSumList(true)) do
		if sumid == v then
			return true
		end
	end
end

------------------主线章节相关--------------------

function CTaskCtrl.GS2CLoginStoryInfo(self, pbdata)
	-- local cur_chapter = pbdata.cur_chapter --当前章节（最新章节）
	-- local chapters = pbdata.chapters --章节信息

	--屏蔽章节的东西
	-- if true then
	-- 	return
	-- end

	self.m_ChapterHasRewardPrizeList = {}
	table.copy(pbdata.chapter_rewarded, self.m_ChapterHasRewardPrizeList)

	self:CheckChapterData(pbdata.chapter_section)

	--当前章节判断,当前进行的章节可能有也可能没有
	self.m_TaskCurChapter = 0
	for k,v in ipairs(g_TaskCtrl:GetChapterConfig()) do
		local oData = self.m_ChapterDataList[v.id] --self:GetTaskChapterLoginData(chapters, v.id)
		local oPieceCount = oData and table.count(oData.pieces) or 0
		if g_AttrCtrl.grade >= v.grade and oPieceCount < v.proceeds then
			self.m_TaskCurChapter = v.id
			break
		end
	end

	-- self.m_TaskCurChapter = cur_chapter
	self.m_TaskChapterList = {}

	if self.m_TaskCurChapter > 0 then
		for i = 1, self.m_TaskCurChapter do
			local list = {chapter = i, pieces = {}}
			table.insert(self.m_TaskChapterList, list)
		end
	else
		local doneChapter = 0
		for k,v in ipairs(g_TaskCtrl:GetChapterConfig()) do
			local oData = self.m_ChapterDataList[v.id] --self:GetTaskChapterLoginData(chapters, v.id)
			local oPieceCount = oData and table.count(oData.pieces) or 0
			if g_AttrCtrl.grade >= v.grade and oPieceCount >= v.proceeds then
				doneChapter = v.id
			end
		end
		if doneChapter > 0 then
			for i = 1, doneChapter do
				local list = {chapter = i, pieces = {}}
				table.insert(self.m_TaskChapterList, list)
			end
		end
	end

	for g,h in pairs(self.m_TaskChapterList) do		
		if self.m_ChapterDataList[h.chapter] then
			h.pieces = self.m_ChapterDataList[h.chapter].pieces
		end
	end
	table.sort(self.m_TaskChapterList, function(a, b) return a.chapter < b.chapter end)

	self:OnEvent(define.Task.Event.RefreshChapterInfo)
	self:OnEvent(define.Task.Event.RedPointNotify)
	table.print(pbdata, "CTaskCtrl.GS2CLoginStoryInfo")
end

function CTaskCtrl.CheckChapterData(self, oSection)
	self.m_ChapterDataList = {}
	if oSection.chapter > 0 then
		local oPreChapter = oSection.chapter - 1
		if oPreChapter > 0 then
			for i = 1, oPreChapter do
				self.m_ChapterDataList[i] = {chapter = i, pieces = {1, 2, 3, 4, 5, 6, 7, 8}}
			end
			local oPieceList = {}
			if oSection.section > 0 then
				for i=1, oSection.section do
					table.insert(oPieceList, i)
				end
			end
			self.m_ChapterDataList[oSection.chapter] = {chapter = oSection.chapter, pieces = oPieceList}
		else
			local oPieceList = {}
			if oSection.section > 0 then
				for i=1, oSection.section do
					table.insert(oPieceList, i)
				end
			end
			self.m_ChapterDataList[oSection.chapter] = {chapter = oSection.chapter, pieces = oPieceList}
		end
	end
end

function CTaskCtrl.CheckChapterAllUpdateData(self, oSection)
	self.m_ChapterAllUpdateDataList = {}
	if oSection.chapter > 0 then
		local oPreChapter = oSection.chapter - 1
		if oPreChapter > 0 then
			for i = 1, oPreChapter do
				self.m_ChapterAllUpdateDataList[i] = {chapter = i, pieces = {1, 2, 3, 4, 5, 6, 7, 8}}
			end
			local oPieceList = {}
			if oSection.section > 0 then
				for i=1, oSection.section do
					table.insert(oPieceList, i)
				end
			end
			self.m_ChapterAllUpdateDataList[oSection.chapter] = {chapter = oSection.chapter, pieces = oPieceList}
		else
			local oPieceList = {}
			if oSection.section > 0 then
				for i=1, oSection.section do
					table.insert(oPieceList, i)
				end
			end
			self.m_ChapterAllUpdateDataList[oSection.chapter] = {chapter = oSection.chapter, pieces = oPieceList}
		end
	end
end

--协议数据管理使用
function CTaskCtrl.GetTaskChapterLoginData(self, oChapters, oChapter)
	for k,v in pairs(oChapters) do
		if v.chapter == oChapter then
			return v
		end
	end
end

--协议数据管理使用
function CTaskCtrl.CheckTaskChapterList(self, oChapter)
	for k,v in pairs(self.m_TaskChapterList) do
		if v.chapter == oChapter then
			return v
		end
	end
end

function CTaskCtrl.GS2CStoryChapterInfo(self, pbdata)
	-- local chapterinfo = pbdata.chapterinfo --更新的章节信息（前端判断是否当前章节）

	--屏蔽章节的东西
	-- if true then
	-- 	return
	-- end
	self.m_ChapterNewDataList = {}
	self:CheckChapterAllUpdateData(pbdata.chapter_section)
	if not next(self.m_ChapterDataList) then
		table.copy(self.m_ChapterAllUpdateDataList, self.m_ChapterNewDataList)
	else
		local oOldMaxIndex = #self.m_ChapterDataList
		local oNewMaxIndex = #self.m_ChapterAllUpdateDataList
		if oOldMaxIndex > oNewMaxIndex then
			return
		end
		for i=oOldMaxIndex, oNewMaxIndex do
			if not self.m_ChapterDataList[i] or #self.m_ChapterDataList[i].pieces < #self.m_ChapterAllUpdateDataList[i].pieces then
				self.m_ChapterNewDataList[i] = {chapter = i, pieces = self.m_ChapterAllUpdateDataList[i].pieces}
			end
		end
	end

	for k,v in pairs(self.m_ChapterNewDataList) do
		self:ShowChapterEffect(v)
	end

	self.m_ChapterDataList = {}
	table.copy(self.m_ChapterAllUpdateDataList, self.m_ChapterDataList)

	table.print(pbdata, "CTaskCtrl.GS2CStoryChapterInfo")
end

function CTaskCtrl.ShowChapterEffect(self, chapterinfo)
	local isShowEffect = false

	local oldInfo
	for k,v in pairs(self.m_TaskChapterList) do
		if v.chapter == chapterinfo.chapter then
			oldInfo = v
			break
		end
	end
	if not oldInfo then
		printc("章节未开启")
		return
	end

	local newPieceList = {}
	for k,v in pairs(chapterinfo.pieces) do
		if not table.index(oldInfo.pieces, v) then
			table.insert(newPieceList, v)
		end
	end
	local newpiececount = table.count(chapterinfo.pieces) - table.count(oldInfo.pieces)

	for k,v in pairs(self.m_TaskChapterList) do
		if v.chapter == chapterinfo.chapter then
			v.pieces = chapterinfo.pieces
			break
		end
	end
	if newpiececount > 0 then
		--获得剧情碎片特效
		-- for i=1,newpiececount do
		-- 	g_NotifyCtrl:FloatPieceBox(10024)
		-- end
		for k,v in ipairs(newPieceList) do
			g_NotifyCtrl:FloatPieceBox(chapterinfo.chapter, v)
		end

		if self.m_TaskCurChapter == chapterinfo.chapter and table.count(chapterinfo.pieces) >= g_TaskCtrl:GetChapterConfig()[chapterinfo.chapter].proceeds then

			--剧情圆满特效
			-- g_NotifyCtrl:FloatChapterDoneEffect()
			isShowEffect = true

			--延迟2秒操作,自动打开对应的剧情页面
			if self.m_DelayTimer then
				Utils.DelTimer(self.m_DelayTimer)
				self.m_DelayTimer = nil			
			end
			if not g_TaskCtrl.m_IsUseChapterNew then
				local function delay()
					local function onShow()
						local function onPieceViewShow()
							self.m_IsShowingPieceView = true
							CTaskMainView:ShowView(function (oView)
								-- oView.m_StoryPart:SetShowChapterIndex(chapterinfo.chapter)
								oView.m_StoryPart.m_DefaultChapter = self:GetShowIndex(chapterinfo.chapter)
								oView:ShowSpecificPart(3)

								local oChapterData = chapterinfo
								if oChapterData then								
									CTaskStoryPieceView:ShowView(function (oView)
										oView:RefreshUI(oChapterData)
										oView:SetDelayClose(3)
									end)
								end
							end)
						end

						if g_PlotCtrl:IsPlaying() then
							g_PlotCtrl:AddPlotEndCbList(function ()
					 			onPieceViewShow()
					 		end)
						else
							onPieceViewShow()
						end				
					end
					if not g_GuideCtrl:IsGuideDone() then			
						g_GuideCtrl:AddEndCallbackList(function ()
							onShow()
						end)
					else
						onShow()
					end				
					return false
				end
				self.m_DelayTimer = Utils.AddTimer(delay, 0, 2)
			end
		end

		g_TaskCtrl:UpdateCurChapter(true)
	end
		
	self:OnEvent(define.Task.Event.RefreshChapterInfo, isShowEffect)
	self:OnEvent(define.Task.Event.RedPointNotify)
end

--协议数据管理使用
function CTaskCtrl.UpdateCurChapter(self, isNotSendEvent)
	--当前章节判断,当前进行的章节可能有也可能没有
	self.m_TaskCurChapter = 0
	for k,v in ipairs(g_TaskCtrl:GetChapterConfig()) do
		local oData = self:GetTaskChapterLoginData(self.m_TaskChapterList, v.id)
		local oPieceCount = oData and table.count(oData.pieces) or 0
		if g_AttrCtrl.grade >= v.grade and oPieceCount < v.proceeds then
			self.m_TaskCurChapter = v.id
			break
		end
	end
	if self.m_TaskCurChapter > 0 then
		for i = 1, self.m_TaskCurChapter do
			if not self:CheckTaskChapterList(i) then
				local list = {chapter = i, pieces = {}}
				table.insert(self.m_TaskChapterList, list)
			end
		end
		table.sort(self.m_TaskChapterList, function(a, b) return a.chapter < b.chapter end)
	end
	if not isNotSendEvent then
		self:OnEvent(define.Task.Event.RefreshChapterInfo)
		self:OnEvent(define.Task.Event.RedPointNotify)
	end
end

function CTaskCtrl.GS2CStoryChapterRewarded(self, pbdata)
	-- local chapter = pbdata.chapter

	--屏蔽章节的东西
	-- if true then
	-- 	return
	-- end

	table.insert(self.m_ChapterHasRewardPrizeList, pbdata.chapter)

	-- for k,v in pairs(self.m_TaskChapterList) do
	-- 	if v.chapter == chapter then
	-- 		v.rewarded = 1
	-- 		break
	-- 	end
	-- end
	
	self:OnEvent(define.Task.Event.RefreshChapterInfo)
	self:OnEvent(define.Task.Event.RedPointNotify)
	table.print(pbdata, "CTaskCtrl.GS2CStoryChapterRewarded")
end

--获取要选择的章节
function CTaskCtrl.GetShowIndex(self, oChapterId)
	local oMaxNum = #self:GetShowChapterList()
	if oChapterId then
		local oChapter = oChapterId
		if oChapter <= 1 then
			if not g_TaskCtrl.m_IsUseChapterNew then
				oChapter = 2
			else
				oChapter = 1
			end
		elseif oChapter >= oMaxNum then
			if not g_TaskCtrl.m_IsUseChapterNew then
				oChapter = oMaxNum - 1
			else
				oChapter = oMaxNum
			end
		end
		return oChapter
	end
	if next(self.m_TaskChapterList) then		
		local oChapter
		if not g_TaskCtrl.m_IsUseChapterNew then
			oChapter = self.m_TaskChapterList[#self.m_TaskChapterList].chapter
		else
			oChapter = self:GetChapterCouldGet()
		end
		if oChapter <= 1 then
			if not g_TaskCtrl.m_IsUseChapterNew then
				oChapter = 2
			else
				oChapter = 1
			end
		elseif oChapter >= oMaxNum then
			if not g_TaskCtrl.m_IsUseChapterNew then
				oChapter = oMaxNum - 1
			else
				oChapter = oMaxNum
			end
		end
		return oChapter
	else
		return 1
	end
end

function CTaskCtrl.GetShowChapterList(self)
	local list = {}
	for k,v in pairs(self.m_TaskChapterList) do
		list[k] = v
	end
	if next(list) then
		table.sort(list, function(a, b) return a.chapter < b.chapter end)
	end

	-- table.print(list, "CTaskCtrl.GetShowChapterList")

	local chapterlist = {}
	if next(list) then
		for k,v in ipairs(list) do
			-- if v.chapter <= self.m_TaskCurChapter then
			table.insert(chapterlist, v)
			-- end
		end
	end

	local showIndex = 0
	if next(self.m_TaskChapterList) then
		showIndex =  self.m_TaskChapterList[#self.m_TaskChapterList].chapter
	end

	--插入未开启的2个章节，如果有的话
	local oConfigCount = #g_TaskCtrl:GetChapterConfig()
	if showIndex < oConfigCount then
		if not g_TaskCtrl.m_IsUseChapterNew then
			local list = {chapter = showIndex + 1, pieces = {}}
			table.insert(chapterlist, list)

			if showIndex + 1 < #g_TaskCtrl:GetChapterConfig() then
				local list = {chapter = showIndex + 2, pieces = {}}
				table.insert(chapterlist, list)
			end
		else
			--新剧情界面修改
			for i=showIndex + 1, oConfigCount do
				local list = {chapter = i, pieces = {}}
				table.insert(chapterlist, list)
			end
		end
	end

	return chapterlist

	-- local list1 = {chapter = 1, pieces = {1, 1}}
	-- local list2 = {chapter = 2, pieces = {1}}
	-- local list3 = {chapter = 3, pieces = {}}
	-- table.insert(chapterlist, list1)
	-- table.insert(chapterlist, list2)
	-- table.insert(chapterlist, list3)
	-- return chapterlist
end

function CTaskCtrl.GetChapterInfoByIndex(self, chapter)
	for k,v in pairs(self:GetShowChapterList()) do
		if v.chapter == chapter then
			return v
		end
	end
end

function CTaskCtrl.GetIsAllChapterPrizeRewarded(self)
	local bIsRewarded = true
	for k,v in pairs(self.m_TaskChapterList) do
		local config = g_TaskCtrl:GetChapterConfig()[v.chapter]
		if table.count(v.pieces) >= config.proceeds and not table.index(self.m_ChapterHasRewardPrizeList, v.chapter) then
			bIsRewarded = false
			break
		end
	end
	return bIsRewarded
end

function CTaskCtrl.GetChapterCouldGet(self)
	for k,v in ipairs(self.m_TaskChapterList) do
		local config = g_TaskCtrl:GetChapterConfig()[v.chapter]
		if table.count(v.pieces) >= config.proceeds and not table.index(self.m_ChapterHasRewardPrizeList, v.chapter) then
			return v.chapter
		end
	end
	if next(self.m_TaskChapterList) then
		return self.m_TaskChapterList[#self.m_TaskChapterList].chapter
	else
		return 1
	end
end

function CTaskCtrl.GetChapterConfig(self)
	-- return data.taskdata.STORYCHAPTER
	--因为美术资源问题，不展示没有资源的章节
	return self.m_ChapterConfigList
end

function CTaskCtrl.GetChapterToTaskConfig(self, oChapter, oPiece)
	local oList = {}
	for k,v in pairs(data.taskdata.TASK.STORY.TASK) do
		if v.chapter_mark and next(v.chapter_mark) then
			if v.chapter_mark.chapter == oChapter and v.chapter_mark.section == oPiece then
				table.insert(oList, v)
			end
		end
	end
	return oList
end

function CTaskCtrl.GetChapterBgList(self)
	local list = {
	{"minimap_4010", "minimap_3050", "minimap_3060", "minimap_5010"},
	{"minimap_5010", "minimap_3060", "minimap_4010", "minimap_3050"},
	{"minimap_3050", "minimap_5010", "minimap_3060", "minimap_4010"},
	{"minimap_3050", "minimap_5010", "minimap_3060", "minimap_4010"},
	{"minimap_3050", "minimap_5010", "minimap_3060", "minimap_4010"},
	{"minimap_3050", "minimap_5010", "minimap_3060", "minimap_4010"},
	{"minimap_3050", "minimap_5010", "minimap_3060", "minimap_4010"},
	{"minimap_3050", "minimap_5010", "minimap_3060", "minimap_4010"},
	}
	return list
end

------------------任务剧情相关--------------------

function CTaskCtrl.GS2CPlayAnime(self, pbdata)
	local sessionidx = pbdata.sessionidx
	local anime_id = pbdata.anime_id
	g_PlotCtrl:PlayPlotById(anime_id)

	local function cb()
		netother.C2GSCallback(sessionidx, nil, nil, nil, 1)
	end
	g_PlotCtrl:SetFinishPlotCb(cb)

	table.print(pbdata, "CTaskCtrl.GS2CPlayAnime")
end

function CTaskCtrl.SetAnimeQteInfo(self, qteid, time)
	self:SetAnimeQteConfig(qteid)
	self.m_AnimeQteTotalTime = time
end

function CTaskCtrl.SetAnimeQteConfig(self, qteid)
	self.m_AnimeQteid = qteid
	for k,v in pairs(data.interactiondata.QTEDATA) do
		if v.id == qteid then
			self.m_AnimeQteConfig = v
			break
		end
	end
end

--剧情qte的总计时
function CTaskCtrl.SetAnimeQteTime(self)	
	self:ResetAnimeQteTimer()
	local function progress()
		self.m_AnimeQteTime = self.m_AnimeQteTime - 1

		self:OnEvent(define.Task.Event.AnimeQteTime)
		
		if self.m_AnimeQteTime <= 0 then
			self.m_AnimeQteTime = 0
			self:OnEvent(define.Task.Event.AnimeQteTime)

			self:SetAnimeQteFailCountTime()

			return false
		end
		return true
	end
	self.m_AnimeQteTime = self.m_AnimeQteSetTime + 1
	self.m_AnimeQteTimer = Utils.AddTimer(progress, 1, 0)
end

function CTaskCtrl.ResetAnimeQteTimer(self)
	if self.m_AnimeQteTimer then
		Utils.DelTimer(self.m_AnimeQteTimer)
		self.m_AnimeQteTimer = nil			
	end
end

--剧情qte失败后的自动播放特效计时
function CTaskCtrl.SetAnimeQteFailCountTime(self)	
	self:ResetAnimeQteFailTimer()
	local function progress()
		self.m_AnimeQteFailTime = self.m_AnimeQteFailTime - 1
		
		if self.m_AnimeQteFailTime <= 0 then
			self.m_AnimeQteFailTime = 0

			self:OnEvent(define.Task.Event.AnimeQteFailTime, 0)

			return false
		end
		return true
	end
	self.m_AnimeQteFailTime = 2
	self.m_AnimeQteFailTimer = Utils.AddTimer(progress, 1, 0)

	self:OnEvent(define.Task.Event.AnimeQteFailTime, self.m_AnimeQteFailTime)
end

function CTaskCtrl.ResetAnimeQteFailTimer(self)
	if self.m_AnimeQteFailTimer then
		Utils.DelTimer(self.m_AnimeQteFailTimer)
		self.m_AnimeQteFailTimer = nil			
	end
end

--任务分支选择的倒计时
function CTaskCtrl.SetTaskSelectCountTime(self, setTime)	
	self:ResetTaskSelectTimer()
	local function progress()
		self.m_TaskSelectTime = self.m_TaskSelectTime - 1

		self:OnEvent(define.Task.Event.TaskSelectCountTime)
		
		if self.m_TaskSelectTime <= 0 then
			self.m_TaskSelectTime = 0

			self:OnEvent(define.Task.Event.TaskSelectCountTime)

			return false
		end
		return true
	end
	self.m_TaskSelectTime = setTime + 1
	self.m_TaskSelectTimer = Utils.AddTimer(progress, 1, 0)
end

function CTaskCtrl.ResetTaskSelectTimer(self)
	if self.m_TaskSelectTimer then
		Utils.DelTimer(self.m_TaskSelectTimer)
		self.m_TaskSelectTimer = nil			
	end
end

--------------跑环任务新加协议--------------------

function CTaskCtrl.GS2CExtendTaskUI(self, pbdata)
	self.m_ExtendTaskData = pbdata
	if pbdata.refresh == 0 then
		self:OnShowTaskItemFindOpBox()
	else
		self:OnEvent(define.Task.Event.RefreshExtendTaskUI)
	end
end

function CTaskCtrl.GS2CExtendTaskUIClose(self, pbdata)
	self:OnCloseTaskItemFindOpBox()
end

function CTaskCtrl.OnShowTaskItemFindOpBox(self)
	if g_WarCtrl:IsWar() then
		return
	end
	--关闭对话界面，不会callback
	-- CDialogueMainView:CloseView()
	self.m_DialogueFindOpCb = function ()
		if self.m_ExtendTaskData and self.m_ExtendTaskData.refresh == 0 then
			self:OnShowTaskItemFindOpBox()
		end
	end
	--暂时屏蔽
	-- local oDialogueView = CDialogueMainView:GetView()
	-- if oDialogueView then
	-- 	oDialogueView:OnDelayClose(1)
	-- else
	-- 	local onLoad = function (oView)
	-- 		oView:OnDelayClose(1)
	-- 	end
	-- 	local oLodingView = g_ViewCtrl.m_LoadingViews["CDialogueMainView"]
	-- 	if oLodingView then
	-- 		oLodingView:SetLoadDoneCB(onLoad)
	-- 	end
	-- end
	g_MainMenuCtrl:ShowAllArea()

	local oView = CMainMenuView:GetView()
	if oView then 
		local oTaskPart = oView.m_RT.m_ExpandBox.m_TaskPart
		if not Utils.IsNil(oTaskPart.m_FindOpBox) then
			oTaskPart.m_FindOpBox:SetActive(true)
			oTaskPart.m_FindOpBox:RefreshUI()
		end
	end
	-- local oWarMainView = CWarMainView:GetView()
	-- if oWarMainView then
	-- 	local oTaskPart = oWarMainView.m_RT.m_ExpandBox.m_TaskPart
	-- 	if not Utils.IsNil(oTaskPart.m_FindOpBox) then
	-- 		oTaskPart.m_FindOpBox:SetActive(true)
	-- 		oTaskPart.m_FindOpBox:RefreshUI()
	-- 	end
	-- end
end

function CTaskCtrl.OnCloseTaskItemFindOpBox(self)
	local oView = CMainMenuView:GetView()
	if oView then 
		local oTaskPart = oView.m_RT.m_ExpandBox.m_TaskPart
		if not Utils.IsNil(oTaskPart.m_FindOpBox) then
			oTaskPart.m_FindOpBox:SetActive(false)
		end
	end
	-- local oWarMainView = CWarMainView:GetView()
	-- if oWarMainView then
	-- 	local oTaskPart = oWarMainView.m_RT.m_ExpandBox.m_TaskPart
	-- 	if not Utils.IsNil(oTaskPart.m_FindOpBox) then
	-- 		oTaskPart.m_FindOpBox:SetActive(false)
	-- 	end
	-- end
end

function CTaskCtrl.GS2CTargetTaskNeeds(self, pbdata)
	self.m_HelpOtherTaskData = {}
	local oTaskInfo = {taskid = pbdata.taskid, tasktype = pbdata.tasktype, needitem = pbdata.needitem, needsum = pbdata.needsum, needitemgroup = pbdata.needitemgroup, ext_apply_info = pbdata.ext_apply_info}
	local oTask = CTask.New(oTaskInfo)
	self.m_HelpOtherTaskData[pbdata.taskid] = oTask
end


function CTaskCtrl.GS2CHelpTaskGiveItem(self, pbdata)
	local oTask = self.m_HelpOtherTaskData[pbdata.taskid]
	if not oTask then
		return
	end
	if pbdata.owner == g_AttrCtrl.pid then
		return
	end
	if oTask:GetSValueByKey("tasktype") == define.Task.TaskType.TASK_FIND_ITEM then
		CTaskCommitItemView:ShowView(function (oView)			
			oView:SetContent(pbdata.sessionidx, oTask)
		end)
	elseif oTask:GetSValueByKey("tasktype") == define.Task.TaskType.TASK_FIND_SUMMON then
		CTaskCommitSummonView:ShowView(function (oView)
			oView:SetContent(pbdata.sessionidx, oTask)
		end)
	end
end

function CTaskCtrl.GS2COpenShopForTask(self, pbdata)
	if not pbdata.owner or pbdata.owner == 0 then
		CTaskHelp.SetClickTaskExecute(nil)
		local oTask = g_TaskCtrl.m_TaskDataDic[pbdata.taskid]
		if not oTask then
			return
		end
		local isOpenShop = g_DialogueCtrl:ExecuteOpenShop(oTask)
		if isOpenShop then
			--关闭对话界面，不会callback
			CDialogueMainView:CloseView()
			self.m_OpenShopForTaskSessionidx = pbdata.sessionidx
			CTaskHelp.SetClickTaskShopSelect(oTask)
		end
	else
		local oTask = self.m_HelpOtherTaskData[pbdata.taskid]
		if not oTask then
			return
		end
		local isOpenShop = g_DialogueCtrl:ExecuteOpenShop(oTask)
		if isOpenShop then
			--关闭对话界面，不会callback
			CDialogueMainView:CloseView()
			self.m_OpenShopForTaskSessionidx = pbdata.sessionidx
			CTaskHelp.SetClickTaskShopSelect(oTask)
		end
	end
end

function CTaskCtrl.SendOpenShopForTaskSessionidx(self)
	if self.m_OpenShopForTaskSessionidx ~= 0 then
		netother.C2GSCallback(self.m_OpenShopForTaskSessionidx, 1)
	end
end

function CTaskCtrl.GS2CRunringIntro(self, pbdata)
	local zId = define.Instruction.Config.Runring
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

-----------------悬赏任务新加协议------------------

function CTaskCtrl.GS2CRefreshXuanShang(self, pbdata)
	if pbdata.count then
		self.m_XuanShangHasDoneTime = pbdata.count
	end
	
	if pbdata.tasks then
		local oHasGet, oIndex = self:GetXuanShangHasGetTaskPos()

		self.m_XuanShangAceTaskData = {}
		table.copy(pbdata.tasks, self.m_XuanShangAceTaskData)
		table.sort(self.m_XuanShangAceTaskData, function (a, b)
			return a.taskid < b.taskid
		end)
		for k,v in pairs(self.m_XuanShangAceTaskData) do
			if oHasGet and oHasGet.taskid == v.taskid then
				local oData = v
				table.remove(self.m_XuanShangAceTaskData, k)
				table.insert(self.m_XuanShangAceTaskData, oIndex, oData)
				break
			end
		end
		self.m_XuanShangAceTaskHashData = {}
		for k,v in pairs(self.m_XuanShangAceTaskData) do
			self.m_XuanShangAceTaskHashData[v.taskid] = v
		end
	end
	self:OnEvent(define.Task.Event.RefreshXuanShang)
end

function CTaskCtrl.GetXuanShangHasGetTaskPos(self)
	for k,v in pairs(self.m_XuanShangAceTaskData) do
		if v.status == 2 then
			return v, k
		end
	end
end

function CTaskCtrl.GS2CRefreshXuanShangUnit(self, pbdata)
	if not self.m_XuanShangAceTaskHashData[pbdata.task.taskid] then
		return
	end

	for k,v in pairs(self.m_XuanShangAceTaskData) do
		if v.taskid == pbdata.task.taskid then
			v.npcid = pbdata.task.npcid
			v.star = pbdata.task.star
			v.status = pbdata.task.status
			break
		end
	end
	self.m_XuanShangAceTaskHashData[pbdata.task.taskid] = pbdata.task
	self:OnEvent(define.Task.Event.RefreshXuanShang)
end

function CTaskCtrl.GS2COpenXuanShangView(self, pbdata)
	COfferRewardView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

function CTaskCtrl.GS2CXuanShangStarTip(self, pbdata)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(g_OfferRewardCtrl.m_ItemSid)
	local iFastBuy = nil
	if iAmount <= 0 then
		iFastBuy = 1
	end
	local windowConfirmInfo = {
		msg = "现在悬赏榜上有奖励非常丰厚的四星和五星任务哦，你确定要刷新吗？",
		title = "提示",
		okCallback = function (oView)
			nettask.C2GSXuanShangStarTip(1, oView.m_NotNotifyBtn:GetSelected() == true and 1 or 0, iFastBuy)
		end,
		cancelCallback = function (oView)
			nettask.C2GSXuanShangStarTip(0, oView.m_NotNotifyBtn:GetSelected() == true and 1 or 0)
		end,
		okStr = "确定",
		cancelStr = "取消",
		notnotifytype = "XuanShang",
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

-----------------引导任务判读----------------

function CTaskCtrl.CheckGhostFirstStepFit(self)
	if not g_GuideHelpCtrl.m_GuideExtraInfoHashList["ghostguide"] and g_TaskCtrl.m_TaskDataDic[define.Task.SpcTask.GhostGuide] and not g_TaskCtrl.m_TaskDataDic[define.Task.SpcTask.GhostGuide].m_Finish
	and not self.m_GhostTaskGuide.first then
		return true
	end
end

function CTaskCtrl.CheckGhostSecondStepFit(self)
	if not g_GuideHelpCtrl.m_GuideExtraInfoHashList["ghostguide"] and g_TaskCtrl.m_TaskDataDic[define.Task.SpcTask.GhostGuide] and not g_TaskCtrl.m_TaskDataDic[define.Task.SpcTask.GhostGuide].m_Finish
	and self.m_GhostTaskGuide.first and not self.m_GhostTaskGuide.second then
		return true
	end
end

function CTaskCtrl.CheckFubenFirstStepFit(self)
	if not g_GuideHelpCtrl.m_GuideExtraInfoHashList["fubenguide"] and g_TaskCtrl.m_TaskDataDic[define.Task.SpcTask.FubenGuide] and not g_TaskCtrl.m_TaskDataDic[define.Task.SpcTask.FubenGuide].m_Finish
	and not self.m_FubenTaskGuide.first then
		return true
	end
end

function CTaskCtrl.CheckFubenSecondStepFit(self)
	if not g_GuideHelpCtrl.m_GuideExtraInfoHashList["fubenguide"] and g_TaskCtrl.m_TaskDataDic[define.Task.SpcTask.FubenGuide] and not g_TaskCtrl.m_TaskDataDic[define.Task.SpcTask.FubenGuide].m_Finish
	and self.m_FubenTaskGuide.first and not self.m_FubenTaskGuide.second then
		return true
	end
end

function CTaskCtrl.CheckFubenThreeStepFit(self)
	if not g_GuideHelpCtrl.m_GuideExtraInfoHashList["fubenguide"] and g_TaskCtrl.m_TaskDataDic[define.Task.SpcTask.FubenGuide] and not g_TaskCtrl.m_TaskDataDic[define.Task.SpcTask.FubenGuide].m_Finish
	and self.m_FubenTaskGuide.first and self.m_FubenTaskGuide.second and not self.m_FubenTaskGuide.three then
		return true
	end
end

function CTaskCtrl.SetTaskIntervalNotifyTime(self)
	self.m_IsTaskNotifyClickShow = false
	self:ResetTaskIntervalNotifyTimer()
	local function progress()
		self.m_IsTaskNotifyClickShow = true
		self:OnEvent(define.Task.Event.TaskIntervalNotify)
		return false
	end
	self.m_TaskIntervalNotifyTimer = Utils.AddTimer(progress, 0, 5)
	self:OnEvent(define.Task.Event.TaskIntervalNotify)
end

function CTaskCtrl.ResetTaskIntervalNotifyTimer(self)
	if self.m_TaskIntervalNotifyTimer then
		Utils.DelTimer(self.m_TaskIntervalNotifyTimer)
		self.m_TaskIntervalNotifyTimer = nil			
	end
end

return CTaskCtrl
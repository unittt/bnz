module(..., package.seeall)

--GS2C--

function GS2CLoginTask(pbdata)
	local taskdata = pbdata.taskdata
	--todo
	g_TaskCtrl:GS2CLoginTask(taskdata)
end

function GS2CAddTask(pbdata)
	local taskdata = pbdata.taskdata
	--todo
	g_TaskCtrl:GS2CAddTask(taskdata)
end

function GS2CDelTask(pbdata)
	local taskid = pbdata.taskid
	local is_done = pbdata.is_done
	--todo
	g_TaskCtrl:GS2CDelTask(pbdata)
end

function GS2CDialog(pbdata)
	local sessionidx = pbdata.sessionidx --回调id,0不需要回调
	local dialog = pbdata.dialog --剧情对白列表
	local npc_name = pbdata.npc_name --当前npc名字
	local model_info = pbdata.model_info --当前npc外形
	local taskid = pbdata.taskid --任务id
	local noanswer = pbdata.noanswer --1:不回复
	--todo
	g_DialogueCtrl:GS2CDialog(pbdata)
end

function GS2CRefreshTask(pbdata)
	local mask = pbdata.mask
	local taskid = pbdata.taskid
	local target = pbdata.target --任务当前目标
	local name = pbdata.name --刷新名字
	local targetdesc = pbdata.targetdesc
	local detaildesc = pbdata.detaildesc
	local isreach = pbdata.isreach --是否达成可交付
	local ext_apply_info = pbdata.ext_apply_info --额外信息
	local time = pbdata.time --倒计时
	--todo
	local data = g_NetCtrl:DecodeMaskData(pbdata, "TaskRefresh")
	g_TaskCtrl:GS2CRefreshTask(data.taskid, data.target, data.name, data.targetdesc, data.detaildesc, data.isreach, data.ext_apply_info, data.time)
end

function GS2CTargetTaskNeeds(pbdata)
	local taskid = pbdata.taskid
	local owner = pbdata.owner --任务属主pid
	local tasktype = pbdata.tasktype --任务类型：找人，寻物等
	local needitem = pbdata.needitem --需求道具
	local needsum = pbdata.needsum --需求宠物
	local needitemgroup = pbdata.needitemgroup --需求道具组
	local ext_apply_info = pbdata.ext_apply_info --额外信息
	--todo
	g_TaskCtrl:GS2CTargetTaskNeeds(pbdata)
end

function GS2CSubmitTaskFail(pbdata)
	local taskid = pbdata.taskid
	local npcid = pbdata.npcid
	--todo
	g_TaskCtrl:GS2CSubmitTaskFail(pbdata)
end

function GS2CRefreshTaskClientNpc(pbdata)
	local taskid = pbdata.taskid
	local clientnpc = pbdata.clientnpc
	--todo
	g_TaskCtrl:GS2CRefreshTaskClientNpc(pbdata)
end

function GS2CRemoveTaskNpc(pbdata)
	local taskid = pbdata.taskid
	local npcid = pbdata.npcid
	local target = pbdata.target --任务目标
	--todo
	g_TaskCtrl:GS2CRemoveTaskNpc(npcid, taskid, target)
end

function GS2CRemoveTaskFollowNpc(pbdata)
	local taskid = pbdata.taskid
	local npcid = pbdata.npcid
	--todo
end

function GS2CConfigTaskFollowNpc(pbdata)
	local shape = pbdata.shape --用npc的shape来区分
	local config = pbdata.config --前端定义跟随npc配置编号
	--todo
	g_MapCtrl:GS2CConfigTaskFollowNpc(pbdata)
end

function GS2CAcceptableTasks(pbdata)
	local taskids = pbdata.taskids
	--todo
	g_TaskCtrl:GS2CAcceptableTasks(taskids)
end

function GS2CLoginUnlockedTags(pbdata)
	local tags = pbdata.tags
	--todo
	-- g_OpenSysCtrl:GS2CLoginUnlockedTags(pbdata)
end

function GS2CUnlockTag(pbdata)
	local tag = pbdata.tag
	local unlock = pbdata.unlock --0/1: 加锁/解锁
	--todo
	-- g_OpenSysCtrl:GS2CUnlockTag(pbdata)
end

function GS2CLoginStoryInfo(pbdata)
	local chapter_section = pbdata.chapter_section --章节进度信息
	local chapter_rewarded = pbdata.chapter_rewarded --已领过奖励的章节
	--todo
	g_TaskCtrl:GS2CLoginStoryInfo(pbdata)
	g_GuideCtrl:OnTriggerAll()
end

function GS2CStoryChapterInfo(pbdata)
	local chapter_section = pbdata.chapter_section --章节进度信息
	--todo
	g_TaskCtrl:GS2CStoryChapterInfo(pbdata)
	g_GuideCtrl:OnTriggerAll()
end

function GS2CStoryChapterRewarded(pbdata)
	local chapter = pbdata.chapter
	--todo
	g_TaskCtrl:GS2CStoryChapterRewarded(pbdata)
	g_GuideCtrl:OnTriggerAll()
end

function GS2CShimenInfo(pbdata)
	local done_daily = pbdata.done_daily --师门日完成次数
	local done_weekly = pbdata.done_weekly --师门周完成次数
	local daily_full = pbdata.daily_full --师门是否日满次数
	--todo
	g_TaskCtrl:GS2CShimenInfo(pbdata)
end

function GS2CAllEverydayTaskInfo(pbdata)
	local all = pbdata.all
	--todo
	g_ScheduleCtrl:GS2CAllEverydayTaskInfo(pbdata)
end

function GS2CUpdateEverydayTasks(pbdata)
	local updates = pbdata.updates
	--todo
	g_ScheduleCtrl:GS2CUpdateEverydayTasks(pbdata)
end

function GS2COpenTaskSayUI(pbdata)
	local sessionidx = pbdata.sessionidx
	local text = pbdata.text
	local channel = pbdata.channel
	--todo
	CTaskHelp.ExcuteSayTask(sessionidx, channel, text)
end

function GS2CExtendTaskUI(pbdata)
	local taskid = pbdata.taskid
	local sessionidx = pbdata.sessionidx
	local options = pbdata.options
	local refresh = pbdata.refresh --1表示刷新现有开着的UI（没有就不开新的）
	--todo
	g_TaskCtrl:GS2CExtendTaskUI(pbdata)
end

function GS2CExtendTaskUIClose(pbdata)
	local taskid = pbdata.taskid
	--todo
	g_TaskCtrl:GS2CExtendTaskUIClose(pbdata)
end

function GS2CLingxiInfo(pbdata)
	local mask = pbdata.mask
	local taskid = pbdata.taskid
	local phase = pbdata.phase --默认0，需要结合具体任务功能(见lingxibase的PHASE定义)
	--todo
	local data = g_NetCtrl:DecodeMaskData(pbdata, "LingxiInfo")
	g_LingxiCtrl:GS2CLingxiInfo(data)
end

function GS2CLingxiUseSeed(pbdata)
	local taskid = pbdata.taskid
	local seed_item = pbdata.seed_item --情花种子
	--todo
	g_LingxiCtrl:GS2CLingxiUseSeed(pbdata)
end

function GS2CLingxiQteCnt(pbdata)
	local taskid = pbdata.taskid
	local total_cnt = pbdata.total_cnt
	local done_cnt = pbdata.done_cnt
	--todo
	g_LingxiCtrl:GS2CLingxiQteCnt(pbdata)
end

function GS2CLingxiQuestion(pbdata)
	local taskid = pbdata.taskid
	local round = pbdata.round --轮次
	local ques = pbdata.ques --题目ID
	local total_round = pbdata.total_round --总轮次(题量)
	local correct_cnt = pbdata.correct_cnt --正确题量
	local rest_sec = pbdata.rest_sec --剩余秒数
	local my_answer = pbdata.my_answer --自己的答案(0表示未答过)
	--todo
	g_LingxiCtrl:GS2CLingxiQuestion(pbdata)
end

function GS2CLingxiQuestionAnswered(pbdata)
	local taskid = pbdata.taskid
	local round = pbdata.round --轮次
	local ques = pbdata.ques --题目ID
	local my_answer = pbdata.my_answer --自己的答案(0表示未答过)
	--todo
	g_LingxiCtrl:GS2CLingxiQuestionAnswered(pbdata)
end

function GS2CLingxiQuestionClose(pbdata)
	local taskid = pbdata.taskid
	--todo
	g_LingxiCtrl:GS2CLingxiQuestionClose(pbdata)
end

function GS2CRunringIntro(pbdata)
	--todo
	g_TaskCtrl:GS2CRunringIntro(pbdata)
end

function GS2CRefreshXuanShang(pbdata)
	local mask = pbdata.mask
	local tasks = pbdata.tasks
	local count = pbdata.count
	--todo
	local data = g_NetCtrl:DecodeMaskData(pbdata, "XuanShangRefresh")
	g_TaskCtrl:GS2CRefreshXuanShang(data)
end

function GS2CRefreshXuanShangUnit(pbdata)
	local task = pbdata.task --刷新单个任务状态
	--todo
	g_TaskCtrl:GS2CRefreshXuanShangUnit(pbdata)
end

function GS2COpenXuanShangView(pbdata)
	--todo
	g_TaskCtrl:GS2COpenXuanShangView(pbdata)
end

function GS2CXuanShangStarTip(pbdata)
	--todo
	g_TaskCtrl:GS2CXuanShangStarTip(pbdata)
end

function GS2CZhenmoRefresh(pbdata)
	local layers = pbdata.layers
	local is_newday = pbdata.is_newday --是否每天第一次刷新, 1是 0不是
	--todo
	g_ZhenmoCtrl:GS2CZhenmoRefresh(layers, is_newday)
end

function GS2CZhenmoSpecialReward(pbdata)
	local mask = pbdata.mask
	local rewards = pbdata.rewards
	local is_open = pbdata.is_open --1 打开奖励界面，2 关闭奖励界面
	local war_time = pbdata.war_time --1战斗总花费时间
	--todo
	g_ZhenmoCtrl:GS2CZhenmoSpecialReward(rewards, is_open, war_time)

	local dColor = data.colorinfodata.OTHER.item.color
	local function func(args)
		local args = args or nil
		for i, v in ipairs(rewards) do

			local sid = v.id
			local amount = v.amount

			local config = DataTools.GetItemData(sid)
			local icon = config.icon
			local quality = config.quality or 0 
			local color = data.colorinfodata.ITEM[quality].color

			g_NotifyCtrl:FloatItemBox(icon)
			g_NotifyCtrl:FloatMsg("获得"..string.format(color, config.name).."×"..
			string.format(dColor, amount), {icon = config.icon, count = amount}, true)
			local dMsg = {
				channel = define.Channel.Message,
				text = "获得"..string.format(color, config.name).."×"..
						string.format(dColor, amount),
				}
			g_ChatCtrl:AddMsg(dMsg)
		end
	end

	local layer = g_ZhenmoCtrl.m_CurLayer
	if g_ZhenmoCtrl:IsLayerComplete(layer) then
		g_MapCtrl:AddLoadDoneCb(func) --已通关，没有剧情，道具在跳转场景后入袋
	else
		g_PlotCtrl:AddPlotEndCbList(func) --有剧情，在剧情后入袋
	end
end

function GS2CZhenmoOpenView(pbdata)
	--todo
	g_ZhenmoCtrl:OpenZhenmoView()
end


--C2GS--

function C2GSClickTask(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSClickTask", t)
end

function C2GSTaskEvent(taskid, npcid)
	local t = {
		taskid = taskid,
		npcid = npcid,
	}
	g_NetCtrl:Send("task", "C2GSTaskEvent", t)
end

function C2GSCommitTask(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSCommitTask", t)
end

function C2GSAbandonTask(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSAbandonTask", t)
end

function C2GSStepTask(taskid, rest_step)
	local t = {
		taskid = taskid,
		rest_step = rest_step,
	}
	g_NetCtrl:Send("task", "C2GSStepTask", t)
end

function C2GSAcceptTask(taskid, npcid)
	local t = {
		taskid = taskid,
		npcid = npcid,
	}
	g_NetCtrl:Send("task", "C2GSAcceptTask", t)
end

function C2GSExtendTaskUIClick(taskid, sessionidx, answer)
	local t = {
		taskid = taskid,
		sessionidx = sessionidx,
		answer = answer,
	}
	g_NetCtrl:Send("task", "C2GSExtendTaskUIClick", t)
end

function C2GSYibaoSeekHelp(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSYibaoSeekHelp", t)
end

function C2GSYibaoGiveHelp(target, taskid, create_day)
	local t = {
		target = target,
		taskid = taskid,
		create_day = create_day,
	}
	g_NetCtrl:Send("task", "C2GSYibaoGiveHelp", t)
end

function C2GSYibaoHelpSubmit(target, taskid, create_day)
	local t = {
		target = target,
		taskid = taskid,
		create_day = create_day,
	}
	g_NetCtrl:Send("task", "C2GSYibaoHelpSubmit", t)
end

function C2GSYibaoAccept()
	local t = {
	}
	g_NetCtrl:Send("task", "C2GSYibaoAccept", t)
end

function C2GSRewardStoryChapter(chapter)
	local t = {
		chapter = chapter,
	}
	g_NetCtrl:Send("task", "C2GSRewardStoryChapter", t)
end

function C2GSAnimeQteEnd(anime_id, qte_id, succ)
	local t = {
		anime_id = anime_id,
		qte_id = qte_id,
		succ = succ,
	}
	g_NetCtrl:Send("task", "C2GSAnimeQteEnd", t)
end

function C2GSRewardEverydayTask(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSRewardEverydayTask", t)
end

function C2GSLingxiUseSeed(taskid, put_x, put_y)
	local t = {
		taskid = taskid,
		put_x = put_x,
		put_y = put_y,
	}
	g_NetCtrl:Send("task", "C2GSLingxiUseSeed", t)
end

function C2GSLingxiCloseToGrowPos(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSLingxiCloseToGrowPos", t)
end

function C2GSLingxiCloseToFlower(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSLingxiCloseToFlower", t)
end

function C2GSLingxiAwayFromFlower(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSLingxiAwayFromFlower", t)
end

function C2GSLingxiQuestionAnswer(taskid, round, answer)
	local t = {
		taskid = taskid,
		round = round,
		answer = answer,
	}
	g_NetCtrl:Send("task", "C2GSLingxiQuestionAnswer", t)
end

function C2GSAcceptBaotuTask()
	local t = {
	}
	g_NetCtrl:Send("task", "C2GSAcceptBaotuTask", t)
end

function C2GSRunringGiveHelp(target, taskid, create_week, ring)
	local t = {
		target = target,
		taskid = taskid,
		create_week = create_week,
		ring = ring,
	}
	g_NetCtrl:Send("task", "C2GSRunringGiveHelp", t)
end

function C2GSOpenXuanShangView()
	local t = {
	}
	g_NetCtrl:Send("task", "C2GSOpenXuanShangView", t)
end

function C2GSAcceptXuanShangTask(taskid)
	local t = {
		taskid = taskid,
	}
	g_NetCtrl:Send("task", "C2GSAcceptXuanShangTask", t)
end

function C2GSRefreshXuanShang(fastbuy_flag)
	local t = {
		fastbuy_flag = fastbuy_flag,
	}
	g_NetCtrl:Send("task", "C2GSRefreshXuanShang", t)
end

function C2GSXuanShangStarTip(confirm, tip, fastbuy_flag)
	local t = {
		confirm = confirm,
		tip = tip,
		fastbuy_flag = fastbuy_flag,
	}
	g_NetCtrl:Send("task", "C2GSXuanShangStarTip", t)
end

function C2GSZhenmoEnterLayer(layer)
	local t = {
		layer = layer,
	}
	g_NetCtrl:Send("task", "C2GSZhenmoEnterLayer", t)
end

function C2GSZhenmoSpecialReward()
	local t = {
	}
	g_NetCtrl:Send("task", "C2GSZhenmoSpecialReward", t)
end

function C2GSZhenmoPlayAnim(anim)
	local t = {
		anim = anim,
	}
	g_NetCtrl:Send("task", "C2GSZhenmoPlayAnim", t)
end

function C2GSZhenmoOpenView()
	local t = {
	}
	g_NetCtrl:Send("task", "C2GSZhenmoOpenView", t)
end


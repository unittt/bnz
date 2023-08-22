module(..., package.seeall)

--GS2C--

function GS2CMentoringStartAnswer(pbdata)
	local type = pbdata.type --1:师傅,2:徒弟
	local option_list = pbdata.option_list --上次登记选项
	--todo
	g_MasterCtrl:GS2CMentoringStartAnswer(pbdata)
end

function GS2CMentoringRecommendMentor(pbdata)
	local mentor_list = pbdata.mentor_list --推荐导师列表
	--todo
	g_MasterCtrl:GS2CMentoringRecommendMentor(pbdata)
end

function GS2CMentoringTask(pbdata)
	local task_list = pbdata.task_list --任务列表
	local progress = pbdata.progress --进度
	local reward_list = pbdata.reward_list --已获得奖励
	local key = pbdata.key --key= 师傅id|徒弟id
	local step_list = pbdata.step_list
	local target_grade = pbdata.target_grade --等级-师傅打开显示徒弟，反之
	local target_score = pbdata.target_score --评分-师傅打开显示徒弟，反之
	local growup_num = pbdata.growup_num --成功出师人数
	--todo
	g_MasterCtrl:GS2CMentoringTask(pbdata)
end

function GS2CMentorEvalutaion(pbdata)
	local grade = pbdata.grade --等级
	local sessionidx = pbdata.sessionidx --会话id
	--todo
	g_MasterCtrl:GS2CMentorEvalutaion(pbdata)
end


--C2GS--

function C2GSToBeMentor(option_list)
	local t = {
		option_list = option_list,
	}
	g_NetCtrl:Send("mentoring", "C2GSToBeMentor", t)
end

function C2GSToBeApprentice(option_list)
	local t = {
		option_list = option_list,
	}
	g_NetCtrl:Send("mentoring", "C2GSToBeApprentice", t)
end

function C2GSDirectBuildReleationship(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("mentoring", "C2GSDirectBuildReleationship", t)
end

function C2GSMentoringTaskReward(type, target, idx)
	local t = {
		type = type,
		target = target,
		idx = idx,
	}
	g_NetCtrl:Send("mentoring", "C2GSMentoringTaskReward", t)
end

function C2GSMentoringStepResultReward(type, target, idx)
	local t = {
		type = type,
		target = target,
		idx = idx,
	}
	g_NetCtrl:Send("mentoring", "C2GSMentoringStepResultReward", t)
end


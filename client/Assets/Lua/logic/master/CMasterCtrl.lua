local CMasterCtrl = class("CMasterCtrl", CCtrlBase)

function CMasterCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self:Clear()
end

function CMasterCtrl.Clear(self)
	self.m_RecommendMentorList = {}
	self.m_MasterShifuList = {}
	self.m_MasterShifuHashList = {}
	self.m_MasterTudiList = {}
	self.m_MasterTudiHashList = {}

	-- self.m_CheckTaskList = {}
	-- self.m_CheckTaskHashList = {}
	-- self.m_CheckProgress = 0
	-- self.m_CheckRewardList = {}
	-- self.m_CheckRewardHashList = {}

	-- self.m_ResultTaskList = {}
	-- self.m_ResultTaskHashList = {}
	-- self.m_ResultGrade = 0

	self.m_ShowPidDataList = {}
	-- self.m_ShowMasterShifuPid = 0
	-- self.m_ShowMasterTudiPid = 0
	-- self.m_TargetGrade = 0
	-- self.m_TargetScore = 0

	self.m_JudgeGrade = 0
	self.m_JudgeSessionidx = 0

	self.m_QuesIndex = 1
	self.m_HasAnswerList = {}

	self.m_AnswerType = 1
	self.m_AnswerOptionList = {}
end

function CMasterCtrl.GS2CMentoringStartAnswer(self, pbdata)
	self.m_AnswerType = pbdata.type
	self.m_AnswerOptionList = pbdata.option_list
	if next(self.m_AnswerOptionList) then
		self.m_HasAnswerList = {}
		for k,v in pairs(self.m_AnswerOptionList) do
			self.m_HasAnswerList[v.question_id] = v.answer
		end
		CMasterRecordView:ShowView(function (oView)
			oView:RefreshUI()
		end)
	else
		self.m_QuesIndex = 1
		self.m_HasAnswerList = {}
		CMasterAnswerView:ShowView(function (oView)
			oView:RefreshUI()
		end)
	end
end

function CMasterCtrl.GS2CMentoringRecommendMentor(self, pbdata)
	self.m_RecommendMentorList = pbdata.mentor_list
	CMasterCommendView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

function CMasterCtrl.GS2CMentoringTask(self, pbdata)
	local oPidList = string.split(pbdata.key, "|")
	local oShifuPid = tonumber(oPidList[1])
	local oTudiPid = tonumber(oPidList[2])
	local oShowPid
	if g_AttrCtrl.pid ~= oShifuPid then
		oShowPid = oShifuPid
	elseif g_AttrCtrl.pid ~= oTudiPid then
		oShowPid = oTudiPid
	end
	self.m_ShowPidDataList[oShowPid] = {}
	
	self.m_ShowPidDataList[oShowPid].m_CheckTaskList = pbdata.task_list
	self.m_ShowPidDataList[oShowPid].m_CheckTaskHashList = {}
	for k,v in pairs(pbdata.task_list) do
		self.m_ShowPidDataList[oShowPid].m_CheckTaskHashList[v.task_id] = v
	end
	self.m_ShowPidDataList[oShowPid].m_CheckProgress = pbdata.progress
	self.m_ShowPidDataList[oShowPid].m_CheckRewardList = pbdata.reward_list
	self.m_ShowPidDataList[oShowPid].m_CheckRewardHashList = {}
	for k,v in pairs(pbdata.reward_list) do
		self.m_ShowPidDataList[oShowPid].m_CheckRewardHashList[v.reward_id] = v
	end
	self.m_ShowPidDataList[oShowPid].m_ResultTaskList = pbdata.step_list
	self.m_ShowPidDataList[oShowPid].m_ResultTaskHashList = {}
	for k,v in pairs(pbdata.step_list) do
		self.m_ShowPidDataList[oShowPid].m_ResultTaskHashList[v.step_id] = v
	end
	
	self.m_ShowPidDataList[oShowPid].m_TargetGrade = pbdata.target_grade
	self.m_ShowPidDataList[oShowPid].m_TargetScore = pbdata.target_score
	self.m_ShowPidDataList[oShowPid].m_GrowupNum = pbdata.growup_num
	self:OnEvent(define.Master.Event.MentoringTask)
end

-- function CMasterCtrl.GS2CMentoringStepResult(self, pbdata)
-- 	self.m_ResultTaskList = pbdata.step_list
-- 	self.m_ResultTaskHashList = {}
-- 	for k,v in pairs(pbdata.step_list) do
-- 		self.m_ResultTaskHashList[v.step_id] = v
-- 	end
-- 	self.m_ResultGrade = pbdata.grade
-- 	self:OnEvent(define.Master.Event.MentoringStepResult)
-- end

function CMasterCtrl.GS2CMentorEvalutaion(self, pbdata)
	self.m_JudgeGrade = pbdata.grade
	self.m_JudgeSessionidx = pbdata.sessionidx

	CMasterJudgeView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

function CMasterCtrl.CheckMasterRelation(self, frdobj)
	local oRelation = frdobj.relation
	if not oRelation then
		return
	end
	local oResultStr = math.NumToOther(oRelation, 2)
    local oRelationList = {}
    for i=1, string.len(oResultStr) do
        local value = string.sub(oResultStr, i, i)
        table.insert(oRelationList, value)
    end
    local oLen = 5 - #oRelationList
    if oLen >= 1 then
        for i = 1, oLen do
            table.insert(oRelationList, 1, "0")
        end
    end
    --3是师傅，5是徒弟
	if oRelationList[#oRelationList-3+1] == "1" then
		if not self.m_MasterShifuHashList[frdobj.pid] then
			self.m_MasterShifuHashList[frdobj.pid] = frdobj
			table.insert(self.m_MasterShifuList, frdobj)
			table.sort(self.m_MasterShifuList, function (a, b)
				return a.pid < b.pid
			end)
		else
			self.m_MasterShifuHashList[frdobj.pid] = frdobj
			local oKey
			for k,v in pairs(self.m_MasterShifuList) do
				if v.pid == frdobj.pid then
					oKey = k
					break
				end
			end
			if oKey then
				table.remove(self.m_MasterShifuList, oKey)
			end
			table.insert(self.m_MasterShifuList, frdobj)
			table.sort(self.m_MasterShifuList, function (a, b)
				return a.pid < b.pid
			end)
		end
	else
		self.m_MasterShifuHashList[frdobj.pid] = nil
		local oKey
		for k,v in pairs(self.m_MasterShifuList) do
			if v.pid == frdobj.pid then
				oKey = k				
				break
			end
		end
		if oKey then
			table.remove(self.m_MasterShifuList, oKey)
		end
	end
	if oRelationList[#oRelationList-5+1] == "1" then
		if not self.m_MasterTudiHashList[frdobj.pid] then
			self.m_MasterTudiHashList[frdobj.pid] = frdobj
			table.insert(self.m_MasterTudiList, frdobj)
			table.sort(self.m_MasterTudiList, function (a, b)
				return a.pid < b.pid
			end)
		else
			self.m_MasterTudiHashList[frdobj.pid] = frdobj
			local oKey
			for k,v in pairs(self.m_MasterTudiList) do
				if v.pid == frdobj.pid then
					oKey = k
					break
				end
			end
			if oKey then
				table.remove(self.m_MasterTudiList, oKey)
			end
			table.insert(self.m_MasterTudiList, frdobj)
			table.sort(self.m_MasterTudiList, function (a, b)
				return a.pid < b.pid
			end)
		end
	else
		self.m_MasterTudiHashList[frdobj.pid] = nil
		local oKey
		for k,v in pairs(self.m_MasterTudiList) do
			if v.pid == frdobj.pid then
				oKey = k
				break
			end
		end
		if oKey then
			table.remove(self.m_MasterTudiList, oKey)
		end
	end
	self:OnEvent(define.Master.Event.MasterList)
end

function CMasterCtrl.GetCheckPartPrize(self, oPid)
	local oShowData = g_MasterCtrl.m_ShowPidDataList[oPid]
	if not oShowData then
		return false
	end
	for k,v in pairs(data.masterdata.PROGRESS) do
		if (not oShowData.m_CheckRewardHashList[v.id] or oShowData.m_CheckRewardHashList[v.id].reward_cnt == 0) and oShowData.m_CheckProgress >= v.progress then
			return true
		end
	end
	return false
end

function CMasterCtrl.GetResultPartPrize(self, oPid, oMasterType)
	local oShowData = g_MasterCtrl.m_ShowPidDataList[oPid]
	if not oShowData then
		return false
	end
	for k,v in pairs(data.masterdata.STEPRESULT) do
		local oServerData = oShowData.m_ResultTaskHashList[v.id]
		if oServerData.status == 0 then
			if v.grade ~= 0 then
				local oGrade
				if oMasterType == 1 then
					oGrade = oShowData.m_TargetGrade
				else
					oGrade = g_AttrCtrl.grade
				end
				if oGrade >= v.grade then
					return true
				end
			else
				if oServerData.step_cnt >= v.cnt then
					return true
				end
			end
		end
	end
	return false
end

function CMasterCtrl.GetMasterCircuRecord(self, oPid)
	local oRecord = IOTools.GetRoleData("master_circu_record") or {}
	return oRecord[tostring(oPid)]
end

function CMasterCtrl.SetMasterCircuRecord(self, oPid)
	local oRecord = IOTools.GetRoleData("master_circu_record") or {}
	oRecord[tostring(oPid)] = true
	IOTools.SetRoleData("master_circu_record", oRecord)
end

return CMasterCtrl
local CExaminationCtrl = class("CExaminationCtrl", CCtrlBase)

function CExaminationCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_ActivityState = 0 --关闭 0 乡试 1  乡试结束--等待殿试 2 殿试 3
	self.m_CostTime = 0
	self.m_CurRound = 0
	self.m_MaxRound = 5
	self.m_RightAnswer = 0
	self.m_WrongTime = 0
	self.m_CurQuestionId = 0
	self.m_ShowResult = false
	self.m_IsLastRound = false
end

function CExaminationCtrl.clear(self)
	self.m_ActivityState = 0
	self.m_CostTime = 0
	self.m_CurRound = 0
	self.m_MaxRound = 0
	self.m_RightAnswer = 0
	self.m_WrongTime = 0
	self.m_CurQuestionId = 0
	self.m_ShowResult = false
	self.m_IsLastRound = false

	self:StopCostTimeTimer()
end

function CExaminationCtrl.GS2CImperialexamState(self, iState)
	self.m_ActivityState = iState
	if self.m_ActivityState == 1 then
		self.m_MaxRound = data.imperialexamdata.CONFIG[1].firststage_total
	else
		self.m_MaxRound = data.imperialexamdata.CONFIG[1].secondstage_total
	end
	if self.m_ActivityState == 2 then
		local oHero = g_MapCtrl:GetHero()
		if oHero then
			oHero:StopWalk()
		end
	end
	self:OnEvent(define.Examination.Event.RefreshState)
end

function CExaminationCtrl.GS2CImperialexamGiveQuestion(self, iQuestionId, iUseTime, iRound)
	self.m_CurQuestionId = iQuestionId
	self.m_CurRound = iRound
	self.m_CostTime = iUseTime
	self.m_RightAnswer = 0
	self.m_WrongTime = 0
	self:StartCostTimeTimer()
	CExaminationMainView:ShowView(function(oView)
		oView:InitQuestionInfo()
	end)
end

function CExaminationCtrl.GS2CImperialexamGiveAnswer(self, iQuestionId, iRightAnswer, iWrongTime)
	self.m_ShowResult = true
	self.m_RightAnswer = iRightAnswer
	self.m_WrongTime = iWrongTime
	self.m_CostTime = self.m_CostTime + iWrongTime
	self.m_IsLastRound = self.m_CurRound == self.m_MaxRound
	if self.m_IsLastRound then
		self:StopCostTimeTimer()
	end
	g_NetCtrl:SetCacheProto("examination", true)
	self:StartNetCacheTimer()
	self:OnEvent(define.Examination.Event.RefreshResult)
end

function CExaminationCtrl.GetQuestionData(self)
	local dQuestion = nil
	if self:IsFirstStage() then
		dQuestion = data.imperialexamdata.FRIST_QUESTIONS[self.m_CurQuestionId]
	elseif self:IsSecondStage() then
		dQuestion = data.imperialexamdata.SECOND_QUESTIONS[self.m_CurQuestionId]
	else
		return 
	end
	local dNewQuestion = {}
	dNewQuestion.question = dQuestion.question
	dNewQuestion.id = dQuestion.id
	local lQuestionId = {1,2,3,4}
	local sKey = "choose_text_"

	for i=4,1,-1 do
		local iRandom = math.floor(math.random(1, i))
		dNewQuestion[sKey..i] = dQuestion[sKey..lQuestionId[iRandom]]
		dNewQuestion["answerid_"..i] = lQuestionId[iRandom]
		table.remove(lQuestionId, iRandom)
	end

	return dNewQuestion
end

function CExaminationCtrl.StopCostTimeTimer(self)
	if self.m_CostTimeTimer then
		Utils.DelTimer(self.m_CostTimeTimer)
		self.m_CostTimeTimer = nil			
	end
end

function CExaminationCtrl.StartCostTimeTimer(self)
	self:StopCostTimeTimer()
	local function update()
		self.m_CostTime = self.m_CostTime + 1
		self:OnEvent(define.Examination.Event.RefreshCostTime)
		return self.m_ActivityState == 1 or self.m_ActivityState == 3		
	end
	self.m_CostTimeTimer = Utils.AddTimer(update, 1, 0)
end

function CExaminationCtrl.StopNetCacheTimer(self)
	if self.m_NetCacheTiemr then
		Utils.DelTimer(self.m_NetCacheTiemr)
		self.m_NetCacheTiemr = nil			
	end
end

function CExaminationCtrl.StartNetCacheTimer(self)
	self:StopNetCacheTimer()
	local function update( ... )
		self.m_ShowResult = false
		g_NetCtrl:SetCacheProto("examination", false)
		g_NetCtrl:ClearCacheProto("examination", true)
	end
	self.m_NetCacheTiemr = Utils.AddTimer(update, 0, 1)
end

function CExaminationCtrl.IsActivityEnd(self)
	return self.m_ActivityState == 0 or self.m_ActivityState == 2
end

function CExaminationCtrl.IsFirstStage(self)
	return self.m_ActivityState == 1
end

function CExaminationCtrl.IsSecondStage(self)
	return self.m_ActivityState == 3
end

function CExaminationCtrl.IsAnswered(self)
	local iRightAnswer = self.m_RightAnswer
	return iRightAnswer and iRightAnswer ~= 0
end
return CExaminationCtrl
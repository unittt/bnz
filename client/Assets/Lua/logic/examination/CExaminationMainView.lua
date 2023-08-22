local CExaminationMainView = class("CExaminationMainView", CViewBase)

function CExaminationMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Examination/ExaminationMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CExaminationMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_RoundL = self:NewUI(2, CLabel)
	self.m_CostTimeL = self:NewUI(3, CLabel)
	self.m_QuestionL = self:NewUI(4, CLabel)
	self.m_AnswerGrid = self:NewUI(5, CGrid)
	self.m_TitleTex = self:NewUI(6, CTexture)
	self.m_FloatStartObj = self:NewUI(7, CObject)
	self.m_FloatEndObj = self:NewUI(8, CObject)
	
	self.m_SelectAnswer = 0

	self:InitContent()
end

function CExaminationMainView.InitContent(self)
	self.m_AnswerGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_ResultSpr = oBox:NewUI(1, CSprite)
		oBox.m_AnswerL = oBox:NewUI(2, CLabel)
		oBox:AddUIEvent("click", callback(self, "OnClickAnswer", oBox))
		oBox:SetGroup(self.m_AnswerGrid:GetInstanceID())
		return oBox
	end)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	g_ExaminationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CExaminationMainView.CloseView(self)
	self.m_ShowResult = false
	g_NetCtrl:SetCacheProto("examination", false)
	g_NetCtrl:ClearCacheProto("examination", false)
	if not g_ExaminationCtrl.m_IsLastRound and 
		g_ExaminationCtrl:IsFirstStage() and 
		g_ExaminationCtrl:IsAnswered() then
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.IMPERIALEXAM.ID)
	end
	if self.m_AutoCloseTimer then
		Utils.DelTimer(self.m_AutoCloseTimer)
		self.m_AutoCloseTimer = nil
	end
	CViewBase.CloseView(self)
end

function CExaminationMainView.InitQuestionInfo(self)
	self.m_SelectAnswer = 0
	self.m_QuestionData = g_ExaminationCtrl:GetQuestionData()
	self:RefreshUI()
	self:RefreshTitleTex()
end

function CExaminationMainView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Examination.Event.RefreshResult then
		self:RefreshAnswerGrid()
		self:FloatWrongTime()
		self:CheckAutoClose()
	elseif oCtrl.m_EventID == define.Examination.Event.RefreshCostTime then
		self:RefreshCostTime()
	elseif oCtrl.m_EventID == define.Examination.Event.RefreshState then
	end
end

function CExaminationMainView.RefreshTitleTex(self)
	local sTextureName = "Texture/Examination/h7_kejudati_01.png"
	if g_ExaminationCtrl.m_ActivityState ~= 1 then
		sTextureName = "Texture/Examination/h7_kejudati_02.png"
	end
	local function SetTexture(prefab, errcode)
		if prefab then
			self.m_TitleTex:SetMainTexture(prefab)
		else
			print(errcode)
		end
	end
	g_ResCtrl:LoadAsync(sTextureName, SetTexture)
end

function CExaminationMainView.RefreshUI(self)
	self:RefreshQuestion()
	self:RefreshAnswerGrid()
	self:RefreshCostTime()
	self:RefreshRound()
end

function CExaminationMainView.RefreshQuestion(self)
	self.m_QuestionL:SetText(self.m_QuestionData.question)
end

function CExaminationMainView.RefreshCostTime(self)
	local sCostTime = g_TimeCtrl:GetLeftTime(g_ExaminationCtrl.m_CostTime)
	self.m_CostTimeL:SetText(sCostTime)
end

function CExaminationMainView.RefreshRound(self)
	self.m_RoundL:SetText(g_ExaminationCtrl.m_CurRound.."/"..g_ExaminationCtrl.m_MaxRound)
end

function CExaminationMainView.RefreshAnswerGrid(self)
	local sKey = "choose_text_"
	for i=1,4 do
		local oBox = self.m_AnswerGrid:GetChild(i)
		self:UpdateAnswerBox(oBox, self.m_QuestionData[sKey..i], self.m_QuestionData["answerid_"..i])
	end
end

function CExaminationMainView.UpdateAnswerBox(self, oBox, sAnswer, iAnswerId)
	local iRightAnswer = g_ExaminationCtrl.m_RightAnswer
	local bIsAnswered = g_ExaminationCtrl:IsAnswered()
	-- printc(bIsAnswered,(iRightAnswer == iAnswerId),(iRightAnswer == self.m_SelectAnswer), iRightAnswer, iAnswerId, self.m_SelectAnswer)
	oBox.m_ResultSpr:SetActive(bIsAnswered and (iRightAnswer == iAnswerId or iAnswerId == self.m_SelectAnswer))
	if bIsAnswered and iRightAnswer ~= self.m_SelectAnswer and self.m_SelectAnswer == iAnswerId then
		oBox.m_ResultSpr:SetSpriteName("h7_chacha_1")
	else
		oBox.m_ResultSpr:SetSpriteName("h7_gougou_1")
	end

	oBox.m_AnswerL:SetText(sAnswer)
	oBox.m_AnswerId = iAnswerId
end

function CExaminationMainView.FloatWrongTime(self)
	if g_ExaminationCtrl.m_WrongTime == 0 then
		return
	end
	local sText = "+"..g_ExaminationCtrl.m_WrongTime.."S"
	local vPos = self.m_FloatStartObj:GetPos()
	if not self.m_FloatHeight then
		self.m_FloatHeight = self.m_FloatEndObj:GetPos().y - vPos.y
	end

	g_NotifyCtrl:FloatSimpleMsg(sText, vPos, self.m_FloatHeight)
end

function CExaminationMainView.CheckAutoClose(self)
	if g_ExaminationCtrl:IsActivityEnd() or 
		(g_ExaminationCtrl:IsSecondStage() and not g_ExaminationCtrl.m_IsLastRound) then
		return
	end
	if self.m_AutoCloseTimer then
		Utils.DelTimer(self.m_AutoCloseTimer)
		self.m_AutoCloseTimer = nil
	end
	local function close()
		self:CloseView()
	end
	self.m_AutoCloseTimer = Utils.AddTimer(close, 0, 1)
end

function CExaminationMainView.OnClickAnswer(self, oBox)
	if self.m_SelectAnswer ~= 0 and not g_ExaminationCtrl:IsActivityEnd() then
		return
	end
	self.m_SelectAnswer = oBox.m_AnswerId
	nethuodong.C2GSImperialexamAnswerQuestion(self.m_QuestionData.id, oBox.m_AnswerId)
	if g_ExaminationCtrl:IsActivityEnd() then
		self:OnClose()
	end
end

return CExaminationMainView
local CBonfireAnswerTopicBox = class("CBonfireAnswerTopicBox", CBox)

function CBonfireAnswerTopicBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_CurAnswerInfo = {}
    self.m_NpcTexture = self:NewUI(1, CTexture)
    self.m_TopicNumber = self:NewUI(2, CLabel)
    self.m_TopicTime = self:NewUI(3, CLabel)
    self.m_TopicLabel = self:NewUI(4, CLabel)
    self.m_AnswerA = self:NewUI(5, CBonfireAnswerBox)
    self.m_AnswerB = self:NewUI(6, CBonfireAnswerBox)
    self.m_AnswerC = self:NewUI(7, CBonfireAnswerBox)
    self.m_AnswerD = self:NewUI(8, CBonfireAnswerBox)
    self.m_AnswerInput = self:NewUI(9, CInput)
    self.m_AnswerAudioBtn = self:NewUI(10, CButton)
    self.m_CloseBtn = self:NewUI(11, CButton)
	self.m_SendBtn = self:NewUI(12, CButton)
	self.m_CorrectCnt = self:NewUI(13, CLabel)
    self.m_AnswerAudioBtn:AddUIEvent("press", callback(self, "OnAudioRecord"))
    self.m_CloseBtn:AddUIEvent("click", function ()
        self:SetActive(false)
    end)
	self.m_SendBtn:AddUIEvent("click", callback(self, "OnAnswer", 0))
	self.m_AnswerA:AddUIEvent("click", callback(self, "OnAnswer", 1))
    self.m_AnswerB:AddUIEvent("click", callback(self, "OnAnswer", 2))
    self.m_AnswerC:AddUIEvent("click", callback(self, "OnAnswer", 3))
    self.m_AnswerD:AddUIEvent("click", callback(self, "OnAnswer", 4))
    g_BonfireCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))

end

function CBonfireAnswerTopicBox.OnEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Bonfire.Event.UpdateBonfireAnswer then
		self:UpdateAnswer(oCtrl.m_EventData)
	end
end

function CBonfireAnswerTopicBox.UpdateAnswer(self, info)
	self.m_CurAnswerInfo = info
	if info.correct_cnt then
		self.m_CorrectCnt:SetText(string.format("准确率%s/%s", info.correct_cnt, g_BonfireCtrl.m_CurTopicInfo.total_round))
	end
    if info.answer == nil or info.answer == 0 then
        return
    end
	local list = {"A","B","C","D"}
	if g_BonfireCtrl.m_CurTopicInfo.id == info.id then
		self["m_Answer"..list[info.answer]]:SetInfo(true)
		if info.answer ~= self.CurAnswerIdx then
			self["m_Answer"..list[self.CurAnswerIdx]]:SetInfo(false)
		end
	end
end

function CBonfireAnswerTopicBox.SetNoStart(self)
	self.m_TopicTime:SetText("-")
	self.m_TopicNumber:SetText("-")
	self.m_AnswerA:SetText("-")
	self.m_AnswerB:SetText("-")
	self.m_AnswerC:SetText("-")
	self.m_AnswerD:SetText("-")
	self.m_AnswerA:NoShowIcon()
	self.m_AnswerB:NoShowIcon()
	self.m_AnswerC:NoShowIcon()
	self.m_AnswerD:NoShowIcon()
	self.m_AnswerA:SetActive(true)
	self.m_AnswerB:SetActive(true)
	self.m_AnswerC:SetActive(true)
	self.m_AnswerD:SetActive(true)
	self.m_SendBtn:SetActive(false)
	self.m_AnswerInput:SetActive(false)
	self.m_AnswerAudioBtn:SetActive(false)
	local function update()
		if g_BonfireCtrl.m_CurRemainTime <= 0 then
			return false
		end
		self.m_TopicLabel:SetText("当前答题还未开始，请耐心等待。\n倒计时"..g_BonfireCtrl.m_CurRemainTime)
		return true
	end
	if self.m_RemainTimer then
		Utils.DelTimer(self.m_RemainTimer)
	end
	self.m_RemainTimer = Utils.AddTimer(update, 1, 0)
end

function CBonfireAnswerTopicBox.SetInfo(self, info)
	if info == nil or next(info) == nil then
		if next(g_BonfireCtrl.m_CurTopicInfo) == nil then
			self:SetNoStart()
			return
		end
	else
		g_BonfireCtrl.m_CurTopicInfo = info
		g_BonfireCtrl.m_CurQuestionState = 1
	end
	local info = g_BonfireCtrl.m_CurTopicInfo
	local correct_cnt = 0
	if next(self.m_CurAnswerInfo) then
		correct_cnt = self.m_CurAnswerInfo.correct_cnt
	elseif g_BonfireCtrl.m_CurQuestionInfo then
		correct_cnt = g_BonfireCtrl.m_CurQuestionInfo.correct_cnt
	end
	self.m_CorrectCnt:SetText(string.format("准确率%s/%s", correct_cnt, info.total_round))
	self.m_TopicNumber:SetText("第"..info.cur_round.."/"..info.total_round.."轮")
	self.m_TopicLabel:SetText(data.bonfiredata.TOPIC[info.id])
	if next(info.choices) then
		self.m_AnswerA:SetText(info.choices[1] and "A "..info.choices[1])
		self.m_AnswerB:SetText(info.choices[2] and "B "..info.choices[2])
		self.m_AnswerC:SetText(info.choices[3] and "C "..info.choices[3])
		self.m_AnswerD:SetText(info.choices[4] and "D "..info.choices[4])
		self.m_AnswerA:NoShowIcon()
		self.m_AnswerB:NoShowIcon()
		self.m_AnswerC:NoShowIcon()
		self.m_AnswerD:NoShowIcon()
		if next(self.m_CurAnswerInfo) and self.m_CurAnswerInfo.id == info.id then
			local list = {"A","B","C","D"}
			self["m_Answer"..list[self.m_CurAnswerInfo.answer]]:SetInfo(true)
		end 
	end
	local flag = false
	if info.type == 3 then
		flag = false
	else
		flag = true
	end
	self.m_AnswerA:SetActive(flag)
	self.m_AnswerB:SetActive(flag)
	self.m_AnswerC:SetActive(flag)
	self.m_AnswerD:SetActive(flag)
	self.m_SendBtn:SetActive(not flag)
	self.m_AnswerInput:SetActive(not flag)
	self.m_AnswerAudioBtn:SetActive(not flag)
	self.m_AnswerInput:SetText("")
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		
		if g_BonfireCtrl.m_CurTopicTime <= 0 then
			local view = CSpeechRecordView:GetView()
			if view then
				view:OnClose()
			end
			if info.cur_round >= info.total_round then
				self:SetActive(false)
			end
			return false
		end
		self.m_TopicTime:SetText("("..g_BonfireCtrl.m_CurTopicTime.."s)")
		return true
	end

	if self.m_DoneTimer then
		Utils.DelTimer(self.m_DoneTimer)
	end
	self.m_DoneTimer = Utils.AddTimer(update, 1, 0)
end

function CBonfireAnswerTopicBox.OnAudioRecord(self, oBtn, bPress)
    if bPress then
		printc("OnSpeech press true")
		g_ChatCtrl.m_IsChatRecording = true
		self:StartRecord(oBtn)	
	else
		printc("OnSpeech press false")
		g_ChatCtrl.m_IsChatRecording = false
		self:EndRecord()
	end
end

--开始录音
function CBonfireAnswerTopicBox.StartRecord(self, oBtn)
	-- 音量级减小
	g_AudioCtrl:SetSlience()
	CSpeechRecordView:CloseView()
	CSpeechRecordView:ShowView(function(oView)
		oView:SetRecordBtn(oBtn)
		oView:BeginRecord(define.Channel.Org, nil, nil, self, 18)
	end)
end

--结束录音
function CBonfireAnswerTopicBox.EndRecord(self)
	-- 音量恢复
	g_AudioCtrl:ExitSlience()
	local oView = CSpeechRecordView:GetView()
	if oView then
		printc("EndRecord, oView存在")
		oView:EndRecord(define.Channel.Org, nil, nil, function (translate)
			self.m_AnswerInput:SetText(translate)
		end,function (cb)
			self.m_SendSpeechFun = cb
		end)
	else
		printc("CChatScrollPage.EndRecord, oView不存在")
	end
end

function CBonfireAnswerTopicBox.OnAnswer(self, index)
	if g_BonfireCtrl.m_CurTopicInfo.id == self.m_CurAnswerInfo.id then
		g_NotifyCtrl:FloatMsg("题目已回答过！")
		return
	end
	local text = self.m_AnswerInput:GetText()
	if index == 0 then
		if text == "" then
			g_NotifyCtrl:FloatMsg("请输入答案！")
			return
		end
		if g_MaskWordCtrl:IsContainMaskWord(text) or string.isIllegal(text) == false then
			g_NotifyCtrl:FloatMsg("含有非法字符请重新输入!")
			return
		end
		if self.m_SendSpeechFun then
			self.m_SendSpeechFun()
		end
		g_ChatCtrl:SendMsg(text, define.Channel.Org)
	end
	self.CurAnswerIdx = index
	g_BonfireCtrl:C2GSCampfireAnswer(g_BonfireCtrl.m_CurTopicInfo.id, index, text)
	self.m_AnswerInput:SetText("")
end

function CBonfireAnswerTopicBox.Dispose(self)
	if self.m_RemainTimer then
		Utils.DelTimer(self.m_RemainTimer)
	end
	if self.m_DoneTimer then
		Utils.DelTimer(self.m_DoneTimer)
		self.m_DoneTimer = nil
	end
end

return CBonfireAnswerTopicBox
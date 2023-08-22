local CLingxiAnswerView = class("CLingxiAnswerView", CViewBase)

function CLingxiAnswerView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Lingxi/LingxiAnswerView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"
end

function CLingxiAnswerView.OnCreateView(self)
    self.m_NpcTexture = self:NewUI(1, CTexture)
    self.m_TopicNumber = self:NewUI(2, CLabel)
    self.m_TopicTime = self:NewUI(3, CLabel)
    self.m_TopicLabel = self:NewUI(4, CLabel)
    self.m_Answer1 = self:NewUI(5, CBox)
    self.m_Answer2 = self:NewUI(6, CBox)
    self.m_Answer3 = self:NewUI(7, CBox)
    self.m_Answer4 = self:NewUI(8, CBox)
    self.m_CloseBtn = self:NewUI(9, CButton)
    self.m_RateLbl = self:NewUI(10, CLabel)
    
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_Answer1:AddUIEvent("click", callback(self, "OnAnswer", 1))
    self.m_Answer2:AddUIEvent("click", callback(self, "OnAnswer", 2))
    self.m_Answer3:AddUIEvent("click", callback(self, "OnAnswer", 3))
    self.m_Answer4:AddUIEvent("click", callback(self, "OnAnswer", 4))
	g_LingxiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))

	self.m_AnswerList = {}

	self:InitContent()
end

function CLingxiAnswerView.OnEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Lingxi.Event.AnswerCount then
		if g_LingxiCtrl.m_AnswerCountTime <= 0 then
			self.m_TopicTime:SetActive(false)
		else
			self.m_TopicTime:SetActive(true)
			self.m_TopicTime:SetText("("..g_LingxiCtrl.m_AnswerCountTime.."S)")
		end
	end
end

function CLingxiAnswerView.InitContent(self)
	self.m_CloseBtn:SetActive(false)
end

function CLingxiAnswerView.RefreshUI(self, pbdata)
	self.m_AnswerData = pbdata

	g_LingxiCtrl:SetAnswerCountTime(pbdata.rest_sec)
	self.m_TopicNumber:SetText("第"..pbdata.round.."/"..pbdata.total_round.."轮")
	self.m_RateLbl:SetText("准确率"..pbdata.correct_cnt.."/"..pbdata.total_round)
	
	local answerConfig = data.lingxidata.QUESTION[pbdata.ques]
	if not answerConfig then
		self.m_TopicLabel:SetText("未配置的题目id:"..pbdata.ques)
		return
	end
	self.m_TopicLabel:SetText(answerConfig.title)

	self.m_AnswerList = {}
	for k,v in pairs(answerConfig.choices) do
		local list = {id = k, text = v}
		table.insert(self.m_AnswerList, list)
	end
	table.shuffle(self.m_AnswerList)

	local strList = {"A", "B", "C", "D"}
	for k,v in ipairs(self.m_AnswerList) do
		self["m_Answer"..k]:NewUI(1, CSprite):SetSpriteName("none")
		self["m_Answer"..k]:NewUI(2, CLabel):SetText(strList[k].."."..v.text)
	end
	if pbdata.my_answer ~= 0 then
		local oKey, oOptionData = self:GetAnswerOptionById(pbdata.my_answer)
		if oOptionData.id == 1 then
			self["m_Answer"..oKey]:NewUI(1, CSprite):SetSpriteName("h7_gougou_1")
		else
			self["m_Answer"..oKey]:NewUI(1, CSprite):SetSpriteName("h7_chacha_1")
		end
		
		local oRightKey, oRightOption = self:GetAnswerOptionById(1)
		self["m_Answer"..oRightKey]:NewUI(1, CSprite):SetSpriteName("h7_gougou_1")
	end
end

function CLingxiAnswerView.GetAnswerOptionById(self, oId)
	for k,v in pairs(self.m_AnswerList) do
		if v.id == oId then
			return k, v
		end
	end
end

function CLingxiAnswerView.OnAnswer(self, index)
	if not self.m_AnswerData then
		return
	end
	if g_LingxiCtrl.m_HasAnswerList[self.m_AnswerData.round] then
		g_NotifyCtrl:FloatMsg("您已经回答过了哦")
		return
	end
	for k,v in ipairs(self.m_AnswerList) do
		self["m_Answer"..k]:NewUI(1, CSprite):SetSpriteName("none")
	end
	local oKey, oOptionData = self:GetAnswerOptionById(self.m_AnswerList[index].id)
	if oOptionData.id == 1 then
		self["m_Answer"..oKey]:NewUI(1, CSprite):SetSpriteName("h7_gougou_1")
	else
		self["m_Answer"..oKey]:NewUI(1, CSprite):SetSpriteName("h7_chacha_1")
	end
	
	local oRightKey, oRightOption = self:GetAnswerOptionById(1)
	self["m_Answer"..oRightKey]:NewUI(1, CSprite):SetSpriteName("h7_gougou_1")

	nettask.C2GSLingxiQuestionAnswer(self.m_AnswerData.taskid, self.m_AnswerData.round, self.m_AnswerList[index].id)
end

return CLingxiAnswerView
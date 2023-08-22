local CGuessRiddleView = class("CGuessRiddleView", CViewBase)

function CGuessRiddleView.ctor(self, cb)
	-- body
	CViewBase.ctor(self, "UI/Guessriddle/GuessriddleView.prefab", cb)
	self.m_SendSign = false 
	self.m_SumbitTimer = nil
	self.m_WaitTimer = nil
end

function CGuessRiddleView.OnCreateView(self)
	-- body
	self.m_DesLabel = self:NewUI(1, CLabel)
	self.m_QusetionPart = self:NewUI(2, CBox)
	
	self.m_TimeLabel = self.m_QusetionPart:NewUI(1, CLabel) --时间
	self.m_RightNum = self.m_QusetionPart:NewUI(2, CLabel) --正确数计数
	self.m_RingNum = self.m_QusetionPart:NewUI(3, CLabel) --轮次计数

	self.m_RightBox = self:NewUI(3, CHfdmInfoBox)
	self.m_LeftBox = self:NewUI(4, CHfdmInfoBox)
	self.m_WinnerBox = self:NewUI(5, CBox)
	self.m_WinnerName = self:NewUI(6, CLabel)
	self.m_Bottom = self:NewUI(7, CGuessRiddleBottomBox)
	self.m_TopPart = self:NewUI(8, CBox)
	self.m_TipLabel = self:NewUI(9, CLabel)
	self:IninContent()
end

function CGuessRiddleView.IninContent(self)
	self.m_RightBox:SetActive(false)
	self.m_LeftBox:SetActive(false)
	self.m_WinnerBox:SetActive(false)
	-- self.m_TimeLabel:SetActive(false)
	self.m_RightNum:SetActive(false)
	self.m_RingNum:SetActive(false)
	self:RefreshQuesetion(g_GuessRiddleCtrl)
	self:RefreshState(g_GuessRiddleCtrl)
	self.m_Bottom:RefreshReward(g_GuessRiddleCtrl.m_NeedCorrectRewardInfo)
	g_GuessRiddleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CGuessRiddleView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.GuessRiddle.Event.RefreshQuesetion then
		self:RefreshQuesetion(oCtrl)
	elseif oCtrl.m_EventID == define.GuessRiddle.Event.RefreshState then
		self:RefreshState(oCtrl)	
	elseif oCtrl.m_EventID == define.GuessRiddle.Event.RefreshRankInfo then
		self.m_Bottom:RefreshRankUI(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.GuessRiddle.Event.RefreshMyInfo then
		self.m_Bottom:RefreshMyInfo(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.GuessRiddle.Event.AdmitSelect then

		self.m_LeftBox:RefreshSelectInfo(oCtrl.m_EventData)

		self.m_RightBox:RefreshSelectInfo(oCtrl.m_EventData)

	elseif oCtrl.m_EventID == define.GuessRiddle.Event.AnswerResult  then

		self.m_LeftBox:NotifyResult(oCtrl.m_EventData.correct_answer, oCtrl.m_EventData.my_answer)

		self.m_RightBox:NotifyResult(oCtrl.m_EventData.correct_answer, oCtrl.m_EventData.my_answer)


	elseif  oCtrl.m_EventID == define.GuessRiddle.Event.RefreshReward then
		self.m_Bottom:RefreshReward(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.GuessRiddle.Event.HadKickPlayer then
		
		self:AfterUseKick()
	
	end
end

function CGuessRiddleView.AfterUseKick(self)
	-- body
	self.m_TopPart:SetActive(true)
	self.m_Bottom.m_UnfoldRank:SetActive(true)
	self.m_Bottom.m_FoldRank:SetActive(true)
	self.m_Bottom.m_SkillBox:SetActive(true)
	self.m_Bottom.m_PopBtn:SetActive(true)
	self.m_Bottom.m_ReBtn:SetActive(false)
	self.m_Bottom.m_KickBox:DestroyKickEffect()
end

function CGuessRiddleView.RefreshQuesetion(self, oCtrl)
	if oCtrl.m_QuesChoices then
		self.m_LeftBox:IsAnswer(1, oCtrl.m_QuesChoices[1])
		self.m_RightBox:IsAnswer(2, oCtrl.m_QuesChoices[2])
	end
	if oCtrl.m_QuesText then
		self.m_DesLabel:SetLocalPos(Vector3.New(4, 188, 0))
		self.m_DesLabel:SetText(oCtrl.m_QuesText)
		self.m_TipLabel:SetActive(false)
	end
	if oCtrl.m_CurrentNum then
		self.m_RingNum:SetText("第"..oCtrl.m_CurrentNum.."/"..oCtrl.m_TotalNum.."题")
	end
end

function CGuessRiddleView.RefreshState(self, oCtrl)
	--显示倒计时
	printc("=========我现在的答题状态是========="..oCtrl.m_QuesState)
	if self.m_WaitTimer then
		Utils.DelTimer(self.m_WaitTimer)
		self.m_WaitTimer = nil
	end
	if oCtrl.m_QuesState == 1 or oCtrl.m_QuesState == 2 then
		self.m_RightNum:SetActive(true)
		self.m_RingNum:SetActive(true)
	end

	local function update()
		if  Utils.IsNil(self) then
			return
		end
		if oCtrl.m_WaitTime >= 0 then
			self.m_TimeLabel:SetText(self:GetNumberString(oCtrl.m_WaitTime)) --调制成 emoji
			return true
		else
			self.m_TimeLabel:SetText(self:GetNumberString(0))
			return false
		end
	end
	self.m_WaitTimer = Utils.AddTimer(update, 1, 0)

	self.m_RingNum:SetText("第"..oCtrl.m_CurrentNum.."/"..oCtrl.m_TotalNum.."题")

	self.m_RightNum:SetText("答对题:"..oCtrl.m_CorrectNum)

	if oCtrl.m_QuesState == 1 then --显示答案的5秒钟
		self.m_DesLabel:SetActive(false)
		self.m_TipLabel:SetActive(true )
		self.m_TipLabel:SetLocalPos(Vector3.New(4,202,0))
		self.m_TipLabel:SetText(data.hfdmdata.HFDMTEXT[9002].content)
		if oCtrl.m_RightAnswer then
			self.m_LeftBox:NotifyResult(oCtrl.m_RightAnswer)
			self.m_RightBox:NotifyResult(oCtrl.m_RightAnswer)
		end
		self.m_SendSign = false
	elseif oCtrl.m_QuesState == 2 then --25秒选择答案,判定玩家位置,发送信息
		self.m_DesLabel:SetActive(true)
		self.m_DesLabel:SetText(oCtrl.m_QuesText)
		self.m_TipLabel:SetActive(false)
		if self.m_SumbitTimer then
			Utils.DelTimer(self.m_SumbitTimer)
		end
	
		local function ChooseSide()
			if not oCtrl.m_IsInHfdmMap then
				return false
			end
			---------------------
			if oCtrl.m_QuesState == 2 then
				local oHero = g_MapCtrl:GetHero()
				--玩家上一次上行的答案和现在站立的位置区域的答案是否一致
				if oCtrl.m_MyChoose and oHero then
					if oCtrl.m_MyChoose == 1 and oHero:GetPos().x >= 12.24 then
						self.m_SendSign = false
					end
					if oCtrl.m_MyChoose == 2 and oHero:GetPos().x <= 15.80 then
						self.m_SendSign = false
					end
					if oCtrl.m_MyChoose == 0 then
						if oHero:GetPos().x <= 12.24 or oHero:GetPos().x >= 15.80 then
							self.m_SendSign = false
						end
					end
				end
				if self.m_SendSign == false and oHero then
					if oHero:GetPos().x <= 12.24 then --站在左边
						self:BufferC2GS(1)
					elseif  oHero:GetPos().x >=15.80 then --站在右边
						self:BufferC2GS(2)					
					else                       ----弃权
						self:BufferC2GS(0)
					end
				end
				return true
			else
				return false
			end
		end

	 	self.m_SumbitTimer = Utils.AddTimer(ChooseSide, 0.2, 0.8) 

	elseif oCtrl.m_QuesState == 3 then --结束
		if self.m_ScheduleEndTimer then
			Utils.DelTimer(self.m_ScheduleEndTimer)
		end
		local function delty()
			if Utils.IsExist(self) then
				self.m_RightBox:SetActive(false)
				self.m_LeftBox:SetActive(false)
				return false
			end
		end
		self.m_ScheduleEndTimer = Utils.AddTimer(delty, 0, 5)
		self.m_WinnerBox:SetActive(true)
		self.m_WinnerName:SetText(oCtrl.m_Winner[1])
		self.m_DesLabel:SetText(data.hfdmdata.HFDMTEXT[9003].content)
		self.m_DesLabel:SetLocalPos(Vector3.New(4,260,0))
		self.m_RightNum:SetActive(false)
		self.m_RingNum:SetActive(false)
		self.m_TimeLabel:SetActive(false)
	elseif oCtrl.m_QuesState == 4 then --等待活动开始
		self.m_TipLabel:SetText(data.hfdmdata.HFDMTEXT[9004].content)
		self.m_DesLabel:SetText(data.hfdmdata.HFDMTEXT[9005].content)
	end
end

function CGuessRiddleView.BufferC2GS(self, select)
	printc("AAAAAAAAAA==BufferC2GS我选择了"..select)
	g_GuessRiddleCtrl.m_MyChoose = select
	g_GuessRiddleCtrl:C2GSHfdmSelect(g_GuessRiddleCtrl.m_QuesID, select)
	self.m_SendSign = true
end

function CGuessRiddleView.GetEachNumList(self,targetnum)
  --列表是尾插入，越后面的是越高位
  local realPrizeNumList = {}
  local num = targetnum
  while num ~= 0 do
    table.insert(realPrizeNumList,num%10)
    num = math.modf(num/10)
  end
  return realPrizeNumList
end

function CGuessRiddleView.GetNumberString(self, markNum)
	if markNum == 0 then
	    return "#mark_0"
	end
	local rawNum = ""
	local realPrizeNumList = self:GetEachNumList(markNum) 
	local numStr = ""
	for k,v in ipairs(realPrizeNumList) do
        numStr = "#mark_"..v..numStr
        rawNum = v..rawNum
    end
    return numStr
end

function CGuessRiddleView.SetSkillBoxInfo(self, info)
	-- body
	self.m_Bottom.m_SkillInfoBox:SetActive(true)
	if info.id == 1001 then
		self.m_Bottom.m_infoBoxicon:SetSpriteName("h7_jinzhongzhao")
	else
		self.m_Bottom.m_infoBoxicon:SetSpriteName("h7_wuyingtui")
	end
	self.m_Bottom.m_infoboxname:SetText(info.name)
	self.m_Bottom.m_infoboxdes:SetText(info.des)
end

return CGuessRiddleView
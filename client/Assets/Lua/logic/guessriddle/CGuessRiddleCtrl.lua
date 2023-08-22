local CGuessRiddleCtrl = class("CGuessRiddleCtrl", CCtrlBase)

function CGuessRiddleCtrl.ctor(self)
	-- body
	CCtrlBase.ctor(self)
	self.m_Winner     = {}
	self.m_QuesState   = nil
	self:Clear()
end

function CGuessRiddleCtrl.Clear(self)
	self.m_IsInHfdmMap = false --处于活动场景中
	self.m_CountTimer = nil
	self.m_WaitTime = 0
	self.m_CurrentNum = 0
	self.m_TotalNum   = 30
	self.m_CorrectNum = 0
	self.m_QuesID  = nil
	self.m_MyGrade = nil
	self.m_QuesText = nil
	self.m_QuesChoices = nil
	self.m_NeedCorrectRewardInfo = { need_cnt= 5,  total_cnt = 5}
	self.m_KickTimer = nil --无影脚计时器
	self.m_KickTime = 0   -- 无影脚CD时间
	self.m_AnchorTimer =nil --金钟罩计时器
	self.m_AnchorTime = 0   --金钟罩CD时间
	self.m_MyChoose = nil  
	self.m_CanKickPlayer = false --点击无影脚之后才能踢人
end

function CGuessRiddleCtrl.InHFDMMapHideTopUI(self, clsname)
	-- body
	if self.m_IsInHfdmMap and table.index(define.GuessRiddle.HideTopArea, clsname) then
		local  oView = CMainMenuView:GetView()
		if oView then
			oView:InHFDMMapHideTopUI(false)
		end
	end
end

--CPlayer -- 点击了单个玩家 
function CGuessRiddleCtrl.TouchPlayer(self, pid, pos)
	-- body
	if self.m_IsInHfdmMap then
		local oHero = g_MapCtrl:GetHero()
		printc("你与被T的玩家距离是",Vector3.Distance(oHero:GetPos(), pos)) 
		if self.m_CanKickPlayer then
			if self.m_KickTime <= 0 then
				self:C2GSHfdmUseSkill(1002, pid)
				self.m_CanKickPlayer = false
				self:OnEvent(define.GuessRiddle.Event.HadKickPlayer)
			end
		end
	end
end

--CMapTouchCtrl
function CGuessRiddleCtrl.JudgeNpcInfoList(self, npsfloatlist, pos)
	if  self.m_IsInHfdmMap then --在活动场景中
		if self.m_CanKickPlayer then
			local random = math.random(1,#npsfloatlist)
			local pid = npsfloatlist[random].pid
			self:C2GSHfdmUseSkill(1002, pid)
			self.m_CanKickPlayer = false
			self:OnEvent(define.GuessRiddle.Event.HadKickPlayer)
		end
	end
end
--重新进入画舫灯谜
function CGuessRiddleCtrl.LoginAgain(self, mapid)
	if mapid == 507000 then
		self.m_IsInHfdmMap = true
		local function delay()
			-- body
			local  oView = CMainMenuView:GetView()
			if oView then
				oView:InHFDMMapHideTopUI(false)
			end
		end
		Utils.AddTimer(delay, 0, 0.3)
	end
end

------------C2GS---------------------
--入场
function CGuessRiddleCtrl.C2GSHfdmEnter(self)
	nethuodong.C2GSHfdmEnter()
end

--选择答案
function CGuessRiddleCtrl.C2GSHfdmSelect(self, ques_id, answer)
	nethuodong.C2GSHfdmSelect(ques_id, answer)
end
--使用技能
function CGuessRiddleCtrl.C2GSHfdmUseSkill(self, skillid, targetpid)
	nethuodong.C2GSHfdmUseSkill(skillid, targetpid)
end

------------GS2C---------------------
-- 判断是否在场景中
function CGuessRiddleCtrl.GS2CHfdmInScene(self, is_in)
	if is_in == 1 then
		CGuessRiddleView:ShowView()
		self.m_IsInHfdmMap = true
		local  oView = CMainMenuView:GetView()
		if oView then
			oView:InHFDMMapHideTopUI(false)
		end
	else
		self.m_IsInHfdmMap = false
		local oView = CMainMenuView:GetView()
		if oView then
			oView:InHFDMMapHideTopUI(true)
		end
		CGuessRiddleView:OnClose()
	end
	
end
--刷新题目
function CGuessRiddleCtrl.GS2CHfdmQuestion(self, round, ques_id, text, choices)
	self.m_CurrentNum = round 
	self.m_QuesID = ques_id 
	self.m_QuesText = text
	self.m_QuesChoices = choices
	self:OnEvent(define.GuessRiddle.Event.RefreshQuesetion)
end

--刷新题目状态
function CGuessRiddleCtrl.GS2CHfdmQuesState(self, pdata)
	self.m_TotalNum   = pdata.total_round or 30
	self.m_CorrectNum = pdata.correct_cnt or 0 
	self.m_WaitTime   = pdata.wait_sec	  or 0
	self.m_QuesState  = pdata.state
	if not  next(self.m_Winner) then
		self.m_Winner  = pdata.winners 
	end
	if self.m_CountTimer then
		Utils.DelTimer(self.m_CountTimer)
	end
	local function update()
	 	if self.m_WaitTime  <= 0 then
	 		return false
	 	end
	 	self.m_WaitTime = self.m_WaitTime - 1
	 	return true
	end
	self.m_CountTimer =  Utils.AddTimer(update, 1, 0.2)
	if self.m_QuesState == 3 then
		self:Clear()
		self.m_QuesState = 3
	end
	self:OnEvent(define.GuessRiddle.Event.RefreshState)
end

--答案结果  状态1 
function CGuessRiddleCtrl.GS2CHfdmAnswerResult(self, ques_id, correct_answer, my_answer, correct_cnt)
	-- if my_answer~=self.m_MyChoose then
	-- 	printc("服务器保存的答案和玩家选择的不一致")
	-- 	return
	-- end
	-- if  ques_id == self.m_QuesID then
	self:OnEvent(define.GuessRiddle.Event.AnswerResult, {correct_answer= correct_answer, my_answer= my_answer})
	-- else
	-- 	printc("客户端与服务器答题不同步,题目有差异")
	-- end
end

--服务器是否认可玩家的选择
function CGuessRiddleCtrl.GS2CHfdmSelectAnswer(self, ques_id, select)
	if ques_id ~= self.m_QuesID then
		--printc("当前展示的题目和服务器超时链接,同步出错")
		return
	end
	self:OnEvent(define.GuessRiddle.Event.AdmitSelect, select)
end

--再答对多少题目可以获得的奖励
function CGuessRiddleCtrl.GS2CHfdmNeedCorrectRewardInfo(self, pbdata)
	self.m_NeedCorrectRewardInfo = pbdata
	self:OnEvent(define.GuessRiddle.Event.RefreshReward, pbdata)
end


function CGuessRiddleCtrl.CDTimer(self, id)
	-- body
	if id == 1001 then
		if self.m_AnchorTimer then
			Utils.DelTimer(self.m_AnchorTimer)
		end
		local function update()
			if self.m_AnchorTime <= 0 then
				return false
			else
				self.m_AnchorTime = self.m_AnchorTime - 1
				self:OnEvent(define.GuessRiddle.Event.AnchorTimer, self.m_AnchorTime)
				return true
			end
		end
		self.m_AnchorTimer = Utils.AddTimer(update, 1, 0)
	elseif id ==1002 then
		if self.m_KickTimer then
			Utils.DelTimer(self.m_KickTimer)
		end
		local function update()
			if self.m_KickTime <= 0 then
				return false
			else
				self.m_KickTime = self.m_KickTime - 1
				self:OnEvent(define.GuessRiddle.Event.KickTimer, self.m_KickTime)
				return true
			end
		end
		self.m_KickTimer = Utils.AddTimer(update, 1, 0)
	end
end

--服务器告知技能状态
function CGuessRiddleCtrl.GS2CHfdmSkillStatus(self, skills)
	-- body
	for i,v in ipairs(skills) do
		if v.id == 1001 then --金钟罩
			if v.cd then
				self.m_AnchorTime = v.cd 
				self:CDTimer(1001)
			else
				self.m_AnchorTime = 0
			end
		elseif v.id == 1002 then --无影脚
			if v.cd then
				self.m_KickTime = v.cd
				self:CDTimer(1002)
			else
				self.m_KickTime = 0
			end
		end
	end
	self.m_Skills = skills
	self:OnEvent(define.GuessRiddle.Event.RefreshSkillState, skills)
end

function CGuessRiddleCtrl.GS2CHfdmRankInfo(self, rankinfo)
	self:OnEvent(define.GuessRiddle.Event.RefreshRankInfo, rankinfo)
end
-- 玩家排行信息
function CGuessRiddleCtrl.GS2CHfdmMyRank(self, rank, score)
	self.m_MyGrade = { rank = rank, score = score}
	self:OnEvent(define.GuessRiddle.Event.RefreshMyInfo, self.m_MyGrade)
end

function CGuessRiddleCtrl.SetSkillBoxInfo(self, info)
	-- body
	local oView = CGuessRiddleView:GetView()
	if oView then
		oView:SetSkillBoxInfo(info)
	end
end

function CGuessRiddleCtrl.GS2CHfdmIntro(self, pbdata)
	local Id = 10032
	if data.instructiondata.DESC[Id]~=nil then
		local Content = {
		 title = data.instructiondata.DESC[Id].title,
	 	 desc = data.instructiondata.DESC[Id].desc
		}
		g_WindowTipCtrl:SetWindowInstructionInfo(Content)		
	end

end

return CGuessRiddleCtrl
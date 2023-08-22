local CBaikeCtrl = class("CBaikeCtrl", CCtrlBase)

function CBaikeCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Clear(true)
end

function CBaikeCtrl.Clear(self, isReLoad)
	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
	end
	self.m_DelayTimer = nil
	self.m_FirstCloseView = true
	self.m_RequestNext = false
	self.m_Time = nil
	self.m_dataList = nil
	self.m_BaikeFinishSign = false
	if isReLoad then
		self.m_CurrRankData  = {}  -- 当前榜
		self.m_WeekRankUnit  = {}  --周榜
		self.m_WeekRank = nil  
		self.m_WeekScore = 0
	
		self.m_CurRank = nil --百名以内的排名
		self.m_CurScore = 0  --百名以内的成绩

		self.m_CurrRankPage =  1
	end
end

function CBaikeCtrl.SetTime(self, stime)
	-- body
	self.m_Time = stime or 0 
	
	local function func()
		if self.m_RequestNext then
			self.m_Time = 0
			return false
		else
			self.m_Time = self.m_Time + 1
			self:OnEvent(define.BaiKe.Event.RefreshBaikeTime)
			return true
		end
	end
	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
	end
	self.m_DelayTimer = Utils.AddTimer(func, 1, 0)
end

function CBaikeCtrl.SetRankPage(self ,index)
	self.m_CurrRankPage = index
end


function CBaikeCtrl.GetRankPage(self)
	return self.m_CurrRankPage
end

function CBaikeCtrl.ShowView(self)
	CBaikeView:ShowView()
end

function CBaikeCtrl.GS2CBaikeQuestion(self, pbdata)
	-- body
	self.m_dataList = pbdata
	self:SetTime(pbdata.answer_time)
	self:OnEvent(define.BaiKe.Event.RefreshBaike)
end

function CBaikeCtrl.GS2CBaikeChooseResult(self, info, data)
	-- body
	self.m_info = info 
	if self.m_info == 1 then
		self.m_data = nil
		g_NotifyCtrl:FloatMsg("答案正确")
	else
		g_NotifyCtrl:FloatMsg("答案错误")
		self.m_data = data
	end
	self:OnEvent(define.BaiKe.Event.RefreshBaikeAnswer)
end

function CBaikeCtrl.GS2CBaikeLinkResult(self, info, data)
	-- body
	self.m_info = info
	self.m_data = data
	if info == 1 then
		g_NotifyCtrl:FloatMsg("答案正确")
	else
		g_NotifyCtrl:FloatMsg("答案错误")
	end
	self:OnEvent(define.BaiKe.Event.RefreshBaikeAnswer)
end
-- 两种答题结束的方式，Finish正常答题结束，ScheduleState =  3 时非正常结束。
function CBaikeCtrl.GS2CBaikeFinish(self)
	self:Clear()
	self.m_BaikeFinishSign = true
	self:OnEvent(define.BaiKe.Event.RefreshBaikeEffect)
end

function CBaikeCtrl.GS2CRefreshHuodongState(self, hdlist)
	-- body

	if hdlist and hdlist.scheduleid ==1021 and hdlist.state == 3 then
		self:Clear(true)
		self.m_BaikeFinishSign = true
	elseif hdlist and hdlist.scheduleid ==1021 and hdlist.state == 2 then
		self.m_FirstCloseView = true
		self.m_BaikeFinishSign = false
	end
end

function CBaikeCtrl.C2GSBaikeGetNextQuestion(self)
	-- body
	nethuodong.C2GSBaikeGetNextQuestion()
end

function CBaikeCtrl.C2GSBaikeChooseAnswer(self, id, answer, cost_time)
	-- body
	nethuodong.C2GSBaikeChooseAnswer(id, answer, cost_time)
end

function CBaikeCtrl.C2GSBaikeLinkAnswer(self, id, answer, cost_time)
	nethuodong.C2GSBaikeLinkAnswer(id,answer,cost_time)
end

function CBaikeCtrl.GS2CBaikeCurRank(self, data)
	-- body
	self.m_CurrRankData = data
	for i,v in ipairs(self.m_CurrRankData) do
		if g_AttrCtrl.pid == v.pid then
			self.m_CurRank = i
			self.m_CurScore = v.score
		end
	end
	self:OnEvent(define.BaiKe.Event.RefreshBaikeCurrRank)
end

function CBaikeCtrl.GS2CBaikeCurRankScore(self,  score)
	-- body
	self.m_CurScore = score
end

function CBaikeCtrl.GS2CBaikeWeekRank(self , unit, score)
	self.m_WeekRankUnit = unit
	self.m_WeekScore = score
	for i,v in ipairs(self.m_WeekRankUnit) do
		if g_AttrCtrl.pid == v.pid then
			self.m_WeekRank = i
			self.m_WeekScore = v.score
		end
	end
	self:OnEvent(define.BaiKe.Event.RefreshBaikeWeekRank)
end

function CBaikeCtrl.C2GSBaikeWeekRank(self)
	nethuodong.C2GSBaikeWeekRank()
end

return CBaikeCtrl
local CSoccerWorldCupGuessHistoryTipCtrl = class("CSoccerWorldCupGuessHistoryTipCtrl", CCtrlBase)


function CSoccerWorldCupGuessHistoryTipCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_State = 2   			--1 活动开启阶段 2 活动结束
	self.m_History = nil		--WorldCupGuess
	self.m_MySuccessCount = 0 	--自己猜中次数
	self.m_MySuccessRate = 0 	--自己猜中胜率
	self.m_MyRankIn = false		--自己在榜内还是榜外
end

function CSoccerWorldCupGuessHistoryTipCtrl.ClearAll(self)
	self.m_State = 2
	self.m_History = nil
	self.m_MySuccessCount = 0
	self.m_MySuccessRate = 0
end

function CSoccerWorldCupGuessHistoryTipCtrl.IsOpening(self)
	if self.m_State == 1 then
		return true
	else
		return false
	end
end


function CSoccerWorldCupGuessHistoryTipCtrl.CheckRedPoint(self)
	return false
end

function CSoccerWorldCupGuessHistoryTipCtrl.IsGamePlaying(self, gameId)
	if self.m_History == nil then
		return false
	end

	for k ,v in pairs(self.m_History) do 
		if v.id == gameId then
			if v.win_team == nil then
				return false
			end
			
			if v.win_team == 1 then
				return true
			end
		end
	end

	return false
end

function CSoccerWorldCupGuessHistoryTipCtrl.GS2CWorldCupState(self, pbdata)
	self.m_State = pbdata.state
	printc("CSoccerWorldCupGuessHistoryTipCtrl:GS2CWorldCupState self.m_State:", self.m_State)
end

function CSoccerWorldCupGuessHistoryTipCtrl.GS2CWorldCupHistory(self, pbdata)
	self.m_History = pbdata.history

	self.m_MySuccessCount = pbdata.suc_count --自己猜中次数
	self.m_MySuccessRate = pbdata.suc_rate --自己猜中胜率
	printc("CSoccerWorldCupGuessHistoryTipCtrl:GS2CWorldCupHistory")
	table.print(self.m_History, "self.m_History")
end

function CSoccerWorldCupGuessHistoryTipCtrl.ShowTipView(self)
	CSoccerWorldCupGuessHistoryTipView:ShowView()
end


return CSoccerWorldCupGuessHistoryTipCtrl
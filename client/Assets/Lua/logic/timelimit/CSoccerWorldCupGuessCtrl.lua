local CSoccerWorldCupGuessCtrl = class("CSoccerWorldCupGuessCtrl", CCtrlBase)


function CSoccerWorldCupGuessCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_State = 2   			--1 活动开启阶段 2 活动结束
	self.m_Phase = 1			--阶段 1.小组赛 2.1/8决赛 3.1/4决赛 4.半决赛 5.季军赛 6决赛
	self.m_Games = nil			--赛程信息, 每场比赛信息
	self.m_GuessInfo = nil		--竞猜信息
	self.m_GuessInfoUnit = nil	--单场竞猜信息
end

function CSoccerWorldCupGuessCtrl.ClearAll(self)
	self.m_State = 2
	self.m_Games = nil
	self.m_GuessInfo = nil
	self.m_GuessInfoUnit = nil
end

function CSoccerWorldCupGuessCtrl.IsOpening(self)
	if self.m_State == 1 then
		return true
	else
		return false
	end
end


function CSoccerWorldCupGuessCtrl.CheckRedPoint(self)
	return false
end

function CSoccerWorldCupGuessCtrl.IsGameGuessed(self, gameId)
	if self.m_GuessInfo == nil then
		return false
	end

	for k ,v in pairs(self.m_GuessInfo) do 
		if v.id == gameId then
			return true
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGameGuessedHomeTeam(self, gameId)
	if self.m_GuessInfo == nil then
		return false
	end

	for k1, v1 in pairs(self.m_GuessInfo) do 
		if v1.id == gameId then
			for k2, v2 in pairs(self.m_Games) do
				if v2.id == gameId then
					if v2.home_team == v1.guess_team and 
						v1.guess_team ~= nil and 
						v1.guess_team ~= 0 then
						return true
					else
						return false
					end 
				end
			end
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGameGuessedHomeTeamForUnit(self, gameId)
	if self.m_GuessInfoUnit == nil then
		return false
	end

	if self.m_GuessInfoUnit.id ~= gameId then
		return false
	end

	for k2, v2 in pairs(self.m_Games) do
		if v2.id == gameId then
			if v2.home_team == self.m_GuessInfoUnit.guess_team and
				self.m_GuessInfoUnit.guess_team ~= nil and 
				self.m_GuessInfoUnit.guess_team ~= 0 then
				return true
			else
				return false
			end 
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGameGuessedAwayTeam(self, gameId)
	if self.m_GuessInfo == nil then
		return false
	end

	for k1, v1 in pairs(self.m_GuessInfo) do 
		if v1.id == gameId then
			for k2, v2 in pairs(self.m_Games) do
				if v2.id == gameId then
					if v2.away_team == v1.guess_team and 
						v1.guess_team ~= nil and
						v1.guess_team ~= 0 then
						return true
					else
						return false
					end 
				end
			end
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGameGuessedAwayTeamForUnit(self, gameId)
	if self.m_GuessInfoUnit == nil then
		return false
	end

	if self.m_GuessInfoUnit.id ~= gameId then
		return false
	end

	for k2, v2 in pairs(self.m_Games) do
		if v2.id == gameId then
			if v2.away_team == self.m_GuessInfoUnit.guess_team and
				self.m_GuessInfoUnit.guess_team ~= nil and
				self.m_GuessInfoUnit.guess_team ~= 0 then
				return true
			else
				return false
			end 
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGameGuessedDraw(self, gameId)
	if self.m_GuessInfo == nil then
		return false
	end

	for k1, v1 in pairs(self.m_GuessInfo) do 
		if v1.id == gameId then
			if v1.guess_team == nil then
				return true
			end

			if v1.guess_team == 0 then
				return true
			else
				return false
			end
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGameGuessedDrawForUnit(self, gameId)
	if self.m_GuessInfoUnit == nil then
		return false
	end

	if self.m_GuessInfoUnit.id ~= gameId then
		return false
	end

	for k2, v2 in pairs(self.m_Games) do
		if v2.id == gameId then
			if self.m_GuessInfoUnit.guess_team == nil then
				return true
			end

			if self.m_GuessInfoUnit.guess_team == 0 then
				return true
			else
				return false
			end 
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGameGuessedWin(self, gameId)
	if self.m_GuessInfo == nil then
		return false
	end

	for k1, v1 in pairs(self.m_GuessInfo) do 
		if v1.id == gameId then
			for k2, v2 in pairs(self.m_Games) do
				if v2.id == gameId then
					--先处理v1.guess_team == nil的情况
					if v1.guess_team == nil then
						if v2.win_team == nil then
							return true
						else
							return false
						end
					end
					--代码到这里v1.guess_team ~= nil
					--再处理v1.guess_team ~= nil的情况
					if v2.win_team ~= nil then
						if v2.win_team == v1.guess_team then
							return true
						else
							return false
						end
					else
						return false
					end 
				end
			end
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGameGuessedWinForUnit(self, gameId)
	if self.m_GuessInfoUnit == nil then
		return false
	end

	if self.m_GuessInfoUnit.id ~= gameId then
		return false
	end

	for k2, v2 in pairs(self.m_Games) do
		if v2.id == gameId then
			--先处理self.m_GuessInfoUnit.guess_team == nil的情况
			if self.m_GuessInfoUnit.guess_team == nil then
				if v2.win_team == nil then
					return true
				else
					return false
				end
			end
			--代码到这里self.m_GuessInfoUnit.guess_team ~= nil
			--再处理self.m_GuessInfoUnit.guess_team ~= nil的情况
			if v2.win_team ~= nil then
				if v2.win_team == self.m_GuessInfoUnit.guess_team then
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGameNoStartByServerTime(self, gameId)
	if self.m_Games == nil then
		return false
	end

	for k ,v in pairs(self.m_Games) do 
		if v.id == gameId then
			printc("g_TimeCtrl:GetTimeS():", g_TimeCtrl:GetTimeS(), " v.start_time:", v.start_time)
			local serverTime = os.date("%m.%d-%H:%M", g_TimeCtrl:GetTimeS())
			local startTime = os.date("%m.%d-%H:%M", v.start_time)
			printc("serverTime:", serverTime, " startTime:", startTime)
			if g_TimeCtrl:GetTimeS() < v.start_time then
				return true
			else
				return false
			end
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGameNoStart(self, gameId)
	if self.m_Games == nil then
		return false
	end

	for k ,v in pairs(self.m_Games) do 
		if v.id == gameId then
			if v.status == 1 then
				return true
			end
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGamePlaying(self, gameId)
	if self.m_Games == nil then
		return false
	end

	for k ,v in pairs(self.m_Games) do 
		if v.id == gameId then
			if v.status == 2 then
				return true
			end
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsGameFinish(self, gameId)
	if self.m_Games == nil then
		return false
	end

	for k ,v in pairs(self.m_Games) do 
		if v.id == gameId then
			if v.status == 3 then
				return true
			end
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.IsLoseTeam(self, gameId, teamId)
	if self.m_Games == nil then
		return false
	end

	for k ,v in pairs(self.m_Games) do 
		if v.id == gameId then
			if v.win_team == nil then
				return false
			end

			if v.win_team == -1 then
				return false
			end

			if v.win_team == 0 then
				return false
			end

			if v.win_team ~= teamId then
				return true
			else
				return false
			end
		end
	end

	return false
end

function CSoccerWorldCupGuessCtrl.GetGameStatus(self, gameId)
	if self.m_Games == nil then
		return -1
	end

	for k ,v in pairs(self.m_Games) do 
		if v.id == gameId then
			return v.status
		end
	end

	return -1
end

function CSoccerWorldCupGuessCtrl.ModifyGuessInfoByGuessInfoUnit(self)
	if self.m_GuessInfo == nil then
		printerror("CSoccerWorldCupGuessCtrl.ModifyGuessInfoByGuessInfoUnit self.m_GuessInfo == nil")
		return
	end

	if self.m_GuessInfoUnit == nil then
		printerror("CSoccerWorldCupGuessCtrl.ModifyGuessInfoByGuessInfoUnit self.m_GuessInfoUnit == nil")
		return
	end

	printc("CSoccerWorldCupGuessCtrl.ModifyGuessInfoByGuessInfoUnit self.m_GuessInfoUnit.id:", self.m_GuessInfoUnit.id)

	local isFind = false
	for k1, v1 in pairs(self.m_GuessInfo) do 
		if v1.id == self.m_GuessInfoUnit.id then
			isFind = true
			if self.m_GuessInfoUnit.guess_team == nil then
				v1.guess_team = nil
				printc("CSoccerWorldCupGuessCtrl.ModifyGuessInfoByGuessInfoUnit v1.guess_team = nil")
			else
				v1.guess_team = self.m_GuessInfoUnit.guess_team
				printc("CSoccerWorldCupGuessCtrl.ModifyGuessInfoByGuessInfoUnit v1.guess_team = self.m_GuessInfoUnit.guess_team v1.guess_team:", v1.guess_team)
			end
		end
	end

	table.print(self.m_GuessInfo, "1 self.m_GuessInfo")

	if isFind then
		return
	end

	local guessResult = {}
	guessResult.id = self.m_GuessInfoUnit.id
	guessResult.guess_team = self.m_GuessInfoUnit.guess_team
	table.insert(self.m_GuessInfo, guessResult)
	
	table.print(self.m_GuessInfo, "2 self.m_GuessInfo")
end

function CSoccerWorldCupGuessCtrl.GS2CWorldCupState(self, pbdata)
	self.m_State = pbdata.state
	printc("CSoccerWorldCupGuessCtrl:GS2CWorldCupState self.m_State:", self.m_State)

	--抛出事件
	if self.m_State == 1 then
		g_RankCtrl:C2GSGetRankInfo(225, 1)
		self:OnEvent(define.SoccerWorldCupGuess.Event.SoccerWorldCupGuessOpen, self)
	elseif self.m_State == 2 then
		self:OnEvent(define.SoccerWorldCupGuess.Event.SoccerWorldCupGuessClose, self)
	else
		printerror("CSoccerWorldCupGuessCtrl.GS2CWorldCupState self.m_State:", self.m_State)
	end
end

function CSoccerWorldCupGuessCtrl.GS2CWorldCupSingleInfo(self, pbdata)
	self.m_Phase = pbdata.phase 
	self.m_Games = pbdata.games
	printc("CSoccerWorldCupGuessCtrl:GS2CWorldCupSingleInfo self.m_Phase:", self.m_Phase)
	table.print(self.m_Games, "self.m_Games")

	--抛出事件
	self:OnEvent(define.SoccerWorldCupGuess.Event.SoccerWorldCupGuessInfoRefresh, self)
end

function CSoccerWorldCupGuessCtrl.GS2CWorldCupSingleGuessInfo(self, pbdata)
	self.m_GuessInfo = pbdata.guess_info
	printc("CSoccerWorldCupGuessCtrl:GS2CWorldCupSingleGuessInfo")
	table.print(self.m_GuessInfo, "self.m_GuessInfo")
	--抛出事件
	self:OnEvent(define.SoccerWorldCupGuess.Event.SoccerWorldCupGuessInfoRefresh, self)
end

function CSoccerWorldCupGuessCtrl.GS2CWorldCupSingleGuessInfoUnit(self, pbdata)
	self.m_GuessInfoUnit = pbdata.guess_info_unit
	printc("CSoccerWorldCupGuessCtrl:GS2CWorldCupSingleGuessInfoUnit")
	table.print(self.m_GuessInfoUnit, "self.m_GuessInfoUnit")

	self:ModifyGuessInfoByGuessInfoUnit()

	--抛出事件
	self:OnEvent(define.SoccerWorldCupGuess.Event.SoccerWorldCupGuessInfoUnitRefresh, self)
end



return CSoccerWorldCupGuessCtrl
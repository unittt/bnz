local CSoccerWorldCupGuessHistoryTipBox = class("CSoccerWorldCupGuessHistoryTipBox", CBox)

function CSoccerWorldCupGuessHistoryTipBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_GameTimeText = self:NewUI(1, CLabel)
	self.m_LeftNationalNameText = self:NewUI(2, CLabel)
	self.m_VSText = self:NewUI(3, CLabel)
	self.m_RightNationalNameText = self:NewUI(4, CLabel)
	self.m_ResultText = self:NewUI(5, CLabel)

	self.r = "[fb3636]%s[-]"
	self.g = "[0fff32]%s[-]"
	--具体数据 begin
	self.m_HistorySingle = nil 	--WorldCupGuess
	--具体数据 end
	self:InitContent()
end

function CSoccerWorldCupGuessHistoryTipBox.Destroy(self)
	self.m_HistorySingle = nil

	CBox.Destroy(self)
end

function CSoccerWorldCupGuessHistoryTipBox.InitContent(self)

end

function CSoccerWorldCupGuessHistoryTipBox.SetHitorySingle(self, historySingle)
	self.m_HistorySingle = historySingle

	self:RefreshUI()
end

function CSoccerWorldCupGuessHistoryTipBox.RefreshUI(self)
	if self.m_HistorySingle == nil then
		return
	end

	--比赛时间
	local gameTime = os.date("%Y-%m-%d %H:%M", self.m_HistorySingle.create_time)
	self.m_GameTimeText:SetText(gameTime)
	self.m_GameTimeText:SetActive(true)
	
	self.m_LeftNationalNameText:SetActive(true)
	self.m_RightNationalNameText:SetActive(true)
	self.m_ResultText:SetActive(true)

	local home_team_name = ""
	home_team_name = data.worldcupdata.CONFIG[self.m_HistorySingle.home_team].country
	local away_team_name = ""
	away_team_name = data.worldcupdata.CONFIG[self.m_HistorySingle.away_team].country
	printc("id:", self.m_HistorySingle.id, " home_team_name:", home_team_name, " away_team_name", away_team_name, " home_team_id:", self.m_HistorySingle.home_team, " away_team_id:", self.m_HistorySingle.away_team)
	printc("id:", self.m_HistorySingle.id, " win_team:", self.m_HistorySingle.win_team, " guess_team", self.m_HistorySingle.guess_team)

	if g_SoccerWorldCupGuessHistoryTipCtrl:IsGamePlaying(self.m_HistorySingle.id) then
		--比赛进行中
		--主场国家名
		local homeNationalName = data.worldcupdata.CONFIG[self.m_HistorySingle.home_team].country
		self.m_LeftNationalNameText:SetText(homeNationalName)

		--客场国家名
		local awayNationalName = data.worldcupdata.CONFIG[self.m_HistorySingle.away_team].country
		self.m_RightNationalNameText:SetText(awayNationalName)

		local redResultText = string.format("结果未公布")
		self.m_ResultText:SetText(redResultText)
	else
		--竞猜结果
		if self.m_HistorySingle.guess_team == self.m_HistorySingle.win_team then
			--猜对了
			if self.m_HistorySingle.win_team ~= 0 then
				--不是平局
				--主场国家名
				if self.m_HistorySingle.guess_team == self.m_HistorySingle.home_team then
					local redHomeNationalName = string.format(self.g, data.worldcupdata.CONFIG[self.m_HistorySingle.home_team].country)
					self.m_LeftNationalNameText:SetText(redHomeNationalName)
				else
					local homeNationalName = data.worldcupdata.CONFIG[self.m_HistorySingle.home_team].country
					self.m_LeftNationalNameText:SetText(homeNationalName)
				end	

				--客场国家名
				if self.m_HistorySingle.guess_team == self.m_HistorySingle.away_team then
					local redAwayNationalName = string.format(self.g, data.worldcupdata.CONFIG[self.m_HistorySingle.away_team].country)
					self.m_RightNationalNameText:SetText(redAwayNationalName)
				else
					local awayNationalName = data.worldcupdata.CONFIG[self.m_HistorySingle.away_team].country
					self.m_RightNationalNameText:SetText(awayNationalName)
				end	
			else
				--平局
				--主场国家名
				local homeNationalName = data.worldcupdata.CONFIG[self.m_HistorySingle.home_team].country
				self.m_LeftNationalNameText:SetText(homeNationalName)

				--客场国家名
				local awayNationalName = data.worldcupdata.CONFIG[self.m_HistorySingle.away_team].country
				self.m_RightNationalNameText:SetText(awayNationalName)
			end
			
			--结果
			local redResultText = string.format(self.g, "竞猜成功")
			self.m_ResultText:SetText(redResultText)

		else
			--猜错了
			if self.m_HistorySingle.win_team ~= 0 then
				--不是平局	
				--主场国家名
				if self.m_HistorySingle.guess_team == self.m_HistorySingle.home_team then
					local redHomeNationalName = string.format(self.r, data.worldcupdata.CONFIG[self.m_HistorySingle.home_team].country)
					self.m_LeftNationalNameText:SetText(redHomeNationalName)
				else
					local homeNationalName = data.worldcupdata.CONFIG[self.m_HistorySingle.home_team].country
					self.m_LeftNationalNameText:SetText(homeNationalName)
				end	

				--客场国家名
				if self.m_HistorySingle.guess_team == self.m_HistorySingle.away_team then
					local redAwayNationalName = string.format(self.r, data.worldcupdata.CONFIG[self.m_HistorySingle.away_team].country)
					self.m_RightNationalNameText:SetText(redAwayNationalName)
				else
					local awayNationalName = data.worldcupdata.CONFIG[self.m_HistorySingle.away_team].country
					self.m_RightNationalNameText:SetText(awayNationalName)
				end
			else
				--平局
				--主场国家名
				local homeNationalName = data.worldcupdata.CONFIG[self.m_HistorySingle.home_team].country
				self.m_LeftNationalNameText:SetText(homeNationalName)

				--客场国家名
				local awayNationalName = data.worldcupdata.CONFIG[self.m_HistorySingle.away_team].country
				self.m_RightNationalNameText:SetText(awayNationalName)
			end

			local redResultText = string.format(self.r, "竞猜失败")
			self.m_ResultText:SetText(redResultText)
		end
	end
end


return CSoccerWorldCupGuessHistoryTipBox
local CSoccerWorldCupGuessBox = class("CSoccerWorldCupGuessBox", CBox)

function CSoccerWorldCupGuessBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_GroupStageText = self:NewUI(1, CLabel)
	self.m_GroupRoundText = self:NewUI(2, CLabel)
	self.m_KnockoutStageText = self:NewUI(3, CLabel)
	self.m_GameTimeText = self:NewUI(4, CLabel)

	self.m_LeftNationalNameText = self:NewUI(5, CLabel)
	self.m_LeftNationalNameBgAtlas = self:NewUI(6, CSprite)
	self.m_LeftNationalFlagAtlas = self:NewUI(7, CSprite)
	self.m_LeftGuessBtn = self:NewUI(8, CButton)
	self.m_LeftGuessGrayBtn = self:NewUI(9, CButton)
	self.m_LeftHasGuessGrayBtn = self:NewUI(10, CButton)

	self.m_RightNationalNameText = self:NewUI(11, CLabel)
	self.m_RightNationalNameBgAtlas = self:NewUI(12, CSprite)
	self.m_RightNationalFlagAtlas = self:NewUI(13, CSprite)
	self.m_RightGuessBtn = self:NewUI(14, CButton)
	self.m_RightGuessGrayBtn = self:NewUI(15, CButton)
	self.m_RightHasGuessGrayBtn = self:NewUI(16, CButton)

	self.m_DrawGuessBtn = self:NewUI(17, CButton)
	self.m_DrawGuessGrayBtn = self:NewUI(18, CButton) 
	self.m_DrawHasGuessGrayBtn = self:NewUI(19, CButton)

	self.m_ResultAtlas = self:NewUI(20, CSprite) 

	--具体数据 begin
	self.m_GameData = nil 	--OneGameInfo
	--具体数据 end
	self:InitContent()
end

function CSoccerWorldCupGuessBox.Destroy(self)
	self.m_GameData = nil

	CBox.Destroy(self)
end

function CSoccerWorldCupGuessBox.InitContent(self)
	self.m_LeftGuessBtn:AddUIEvent("click", callback(self, "OnClickLeftGuessBtn"))
	self.m_LeftGuessGrayBtn:AddUIEvent("click", callback(self, "OnClickLeftGuessGrayBtn"))
	self.m_RightGuessBtn:AddUIEvent("click", callback(self, "OnClickRightGuessBtn"))
	self.m_RightGuessGrayBtn:AddUIEvent("click", callback(self, "OnClickRightGuessGrayBtn"))
	self.m_DrawGuessBtn:AddUIEvent("click", callback(self, "OnClickDrawGuessBtn"))
	self.m_DrawGuessGrayBtn:AddUIEvent("click", callback(self, "OnClickDrawGuessGrayBtn"))

	g_SoccerWorldCupGuessCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CSoccerWorldCupGuessBox.SetGameData(self, gameData)
	self.m_GameData = gameData

	self:RefreshGameDataUI()
end

function CSoccerWorldCupGuessBox.OnClickLeftGuessBtn(self)
	printc("CSoccerWorldCupGuessBox.OnClickLeftGuessBtn")

	local phase = self.m_GameData ~= nil and self.m_GameData.phase or 1
	local cost = data.worldcupdata.COST[phase] ~= nil and data.worldcupdata.COST[phase].single or 10000
	local windowConfirmInfo = {
		title = "提示",
		msg = string.format("本次竞猜将花费%d#cur_4, 是否确认?", cost),
		cancelCallback = function ()
		end,
		cancelStr = "取消",
		okCallback = function()
			self:GuessHome()
		end,
		okStr = "确定",
		closeType = 3,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSoccerWorldCupGuessBox.OnClickLeftGuessGrayBtn(self)
	printc("CSoccerWorldCupGuessBox.OnClickLeftGuessGrayBtn")
	if self.m_GameData ~= nil then
		nethuodong.C2GSWorldCupSingle(self.m_GameData.id, self.m_GameData.home_team)
	else
		
	end
end

function CSoccerWorldCupGuessBox.GuessHome(self)
	printc("CSoccerWorldCupGuessBox.GuessHome")
	if self.m_GameData ~= nil then
		nethuodong.C2GSWorldCupSingle(self.m_GameData.id, self.m_GameData.home_team)
	else
		
	end
end

function CSoccerWorldCupGuessBox.OnClickRightGuessBtn(self)
	printc("CSoccerWorldCupGuessBox.OnClickRightGuessBtn")
	local phase = self.m_GameData ~= nil and self.m_GameData.phase or 1
	local cost = data.worldcupdata.COST[phase] ~= nil and data.worldcupdata.COST[phase].single or 10000
	local windowConfirmInfo = {
		title = "提示",
		msg = string.format("本次竞猜将花费%d#cur_4, 是否确认?", cost),
		cancelCallback = function ()
		end,
		cancelStr = "取消",
		okCallback = function()
			self:GuessAway()
		end,
		okStr = "确定",
		closeType = 3,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSoccerWorldCupGuessBox.OnClickRightGuessGrayBtn(self)
	printc("CSoccerWorldCupGuessBox.OnClickRightGuessGrayBtn")
	if self.m_GameData ~= nil then
		nethuodong.C2GSWorldCupSingle(self.m_GameData.id, self.m_GameData.away_team)
	else
		
	end
end

function CSoccerWorldCupGuessBox.GuessAway(self)
	printc("CSoccerWorldCupGuessBox.GuessAway")
	if self.m_GameData ~= nil then
		nethuodong.C2GSWorldCupSingle(self.m_GameData.id, self.m_GameData.away_team)
	else
		
	end
end

function CSoccerWorldCupGuessBox.OnClickDrawGuessBtn(self)
	printc("CSoccerWorldCupGuessBox.OnClickDrawGuessBtn")
	local phase = self.m_GameData ~= nil and self.m_GameData.phase or 1
	local cost = data.worldcupdata.COST[phase] ~= nil and data.worldcupdata.COST[phase].single or 10000
	local windowConfirmInfo = {
		title = "提示",
		msg = string.format("本次竞猜将花费%d#cur_4, 是否确认?", cost),
		cancelCallback = function ()
		end,
		cancelStr = "取消",
		okCallback = function()
			self:GuessDraw()
		end,
		okStr = "确定",
		closeType = 3,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSoccerWorldCupGuessBox.OnClickDrawGuessGrayBtn(self)
	printc("CSoccerWorldCupGuessBox.OnClickDrawGuessGrayBtn")
	if self.m_GameData ~= nil then
		nethuodong.C2GSWorldCupSingle(self.m_GameData.id, 0)
	else
		
	end
end

function CSoccerWorldCupGuessBox.GuessDraw(self)
	printc("CSoccerWorldCupGuessBox.GuessDraw")
	if self.m_GameData ~= nil then
		nethuodong.C2GSWorldCupSingle(self.m_GameData.id, 0)
	else
		
	end
end

function CSoccerWorldCupGuessBox.RefreshUnit(self)
	printc("CSoccerWorldCupGuessBox.RefreshUnit self.m_GameData.id:", self.m_GameData.id, " g_SoccerWorldCupGuessCtrl.m_GuessInfoUnit.id:", g_SoccerWorldCupGuessCtrl.m_GuessInfoUnit.id)
	if g_SoccerWorldCupGuessCtrl.m_GuessInfoUnit.id ~= self.m_GameData.id then
		return
	end

	--[[
	--竞猜按钮
	printc("RefreshUnit g_SoccerWorldCupGuessCtrl:IsGameGuessed:", g_SoccerWorldCupGuessCtrl:IsGameGuessed(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
	if g_SoccerWorldCupGuessCtrl:IsGameGuessed(self.m_GameData.id) == false then
		--未竞猜
		printc("RefreshUnit g_SoccerWorldCupGuessCtrl:IsGameNoStart:", g_SoccerWorldCupGuessCtrl:IsGameGuessed(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
		printc("RefreshUnit g_SoccerWorldCupGuessCtrl:IsGamePlaying:", g_SoccerWorldCupGuessCtrl:IsGamePlaying(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
		if g_SoccerWorldCupGuessCtrl:IsGameNoStart(self.m_GameData.id) == true then 
			--比赛未开始且未竞猜，即可竞猜(按钮都是可按状态)
			self.m_LeftGuessBtn:SetActive(true)
			self.m_LeftGuessGrayBtn:SetActive(false)
			self.m_LeftHasGuessGrayBtn:SetActive(false)
			self.m_RightGuessBtn:SetActive(true)
			self.m_RightGuessGrayBtn:SetActive(false)
			self.m_RightHasGuessGrayBtn:SetActive(false)
			self.m_DrawGuessBtn:SetActive(self.m_GameData.has_match == 1 and true or false)
			self.m_DrawGuessGrayBtn:SetActive(false)
			self.m_DrawHasGuessGrayBtn:SetActive(false)

			--竞猜结果:无
			self.m_ResultAtlas:SetActive(false)
		elseif g_SoccerWorldCupGuessCtrl:IsGamePlaying(self.m_GameData.id) or g_SoccerWorldCupGuessCtrl:IsGameFinish(self.m_GameData.id) then
			--比赛已开始或以结束，但未竞猜，即已过期(按钮都是不可按状态)
			self.m_LeftGuessBtn:SetActive(false)
			self.m_LeftGuessGrayBtn:SetActive(true)
			self.m_LeftHasGuessGrayBtn:SetActive(false)
			self.m_RightGuessBtn:SetActive(false)
			self.m_RightGuessGrayBtn:SetActive(true)
			self.m_RightHasGuessGrayBtn:SetActive(false)
			self.m_DrawGuessBtn:SetActive(false)
			self.m_DrawGuessGrayBtn:SetActive(self.m_GameData.has_match == 1 and true or false)
			self.m_DrawHasGuessGrayBtn:SetActive(false)

			--竞猜结果:已过期
			self.m_ResultAtlas:SetSpriteName("h7_shijiebei_03")
			self.m_ResultAtlas:SetActive(true)
		else 
			printerror("RefreshUnit worldcup guess logic error 1")
		end
	else
	--]]

		printc("RefreshUnit g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime:", g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
		printc("RefreshUnit g_SoccerWorldCupGuessCtrl:IsGameNoStart:", g_SoccerWorldCupGuessCtrl:IsGameNoStart(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
		printc("RefreshUnit g_SoccerWorldCupGuessCtrl:IsGamePlaying:", g_SoccerWorldCupGuessCtrl:IsGamePlaying(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
		if g_SoccerWorldCupGuessCtrl:IsGameNoStart(self.m_GameData.id) == true and 
		    g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime(self.m_GameData.id) == true then
			--比赛未开始，但已竞猜(按钮都是不可按状态)
			self.m_LeftGuessBtn:SetActive(false)
			self.m_LeftGuessGrayBtn:SetActive(true)
			self.m_LeftHasGuessGrayBtn:SetActive(false)
			self.m_RightGuessBtn:SetActive(false)
			self.m_RightGuessGrayBtn:SetActive(true)
			self.m_RightHasGuessGrayBtn:SetActive(false)
			self.m_DrawGuessBtn:SetActive(false)
			self.m_DrawGuessGrayBtn:SetActive(self.m_GameData.has_match == 1 and true or false)
			self.m_DrawHasGuessGrayBtn:SetActive(false)

			--对应位置，按钮消失，显示已竞猜ICON
			if g_SoccerWorldCupGuessCtrl:IsGameGuessedHomeTeamForUnit(self.m_GameData.id) then
				--如果玩家竞猜的是主队
				self.m_LeftGuessGrayBtn:SetActive(false)
				self.m_LeftHasGuessGrayBtn:SetActive(true)
			elseif g_SoccerWorldCupGuessCtrl:IsGameGuessedAwayTeamForUnit(self.m_GameData.id) then
				--如果玩家竞猜的是客队
				self.m_RightGuessGrayBtn:SetActive(false)
				self.m_RightHasGuessGrayBtn:SetActive(true)
			elseif g_SoccerWorldCupGuessCtrl:IsGameGuessedDrawForUnit(self.m_GameData.id) then
				--如果玩家竞猜的是平局
				self.m_DrawGuessGrayBtn:SetActive(false)
				self.m_DrawHasGuessGrayBtn:SetActive(self.m_GameData.has_match == 1 and true or false)
			else
				printerror("RefreshUnit worldcup guess logic error unit 2")
			end

			--竞猜结果:无
			self.m_ResultAtlas:SetActive(false)
		elseif g_SoccerWorldCupGuessCtrl:IsGamePlaying(self.m_GameData.id) or 
		   g_SoccerWorldCupGuessCtrl:IsGameFinish(self.m_GameData.id) or 
		   g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime(self.m_GameData.id) == false then
			--比赛已开始或已结束，且已竞猜
			self.m_LeftGuessBtn:SetActive(false)
			self.m_LeftGuessGrayBtn:SetActive(true)
			self.m_LeftHasGuessGrayBtn:SetActive(false)
			self.m_RightGuessBtn:SetActive(false)
			self.m_RightGuessGrayBtn:SetActive(true)
			self.m_RightHasGuessGrayBtn:SetActive(false)
			self.m_DrawGuessBtn:SetActive(false)
			self.m_DrawGuessGrayBtn:SetActive(self.m_GameData.has_match == 1 and true or false)
			self.m_DrawHasGuessGrayBtn:SetActive(false)

			--对应位置，按钮消失，显示已竞猜ICON
			if g_SoccerWorldCupGuessCtrl:IsGameGuessedHomeTeamForUnit(self.m_GameData.id) then
				--如果玩家竞猜的是主队
				self.m_LeftGuessGrayBtn:SetActive(false)
				self.m_LeftHasGuessGrayBtn:SetActive(true)
			elseif g_SoccerWorldCupGuessCtrl:IsGameGuessedAwayTeamForUnit(self.m_GameData.id) then
				--如果玩家竞猜的是客队
				self.m_RightGuessGrayBtn:SetActive(false)
				self.m_RightHasGuessGrayBtn:SetActive(true)
			elseif g_SoccerWorldCupGuessCtrl:IsGameGuessedDrawForUnit(self.m_GameData.id) then
				--如果玩家竞猜的是平局
				self.m_DrawGuessGrayBtn:SetActive(false)
				self.m_DrawHasGuessGrayBtn:SetActive(self.m_GameData.has_match == 1 and true or false)
			else
				printerror("RefreshUnit worldcup guess logic error unit 3")
			end

			--竞猜结果
			if g_SoccerWorldCupGuessCtrl:IsGamePlaying(self.m_GameData.id) then
				--比赛还在进行中，竞猜结果还没出来
				self.m_ResultAtlas:SetActive(false)
			elseif g_SoccerWorldCupGuessCtrl:IsGameFinish(self.m_GameData.id) then
				--比赛已结束，竞猜结果已出来
				if g_SoccerWorldCupGuessCtrl:IsGameGuessedWinForUnit(self.m_GameData.id) then
					--竞猜成功
					self.m_ResultAtlas:SetSpriteName("h7_shijiebei_01") 
					self.m_ResultAtlas:SetActive(true)
				else
					--竞猜失败
					self.m_ResultAtlas:SetSpriteName("h7_shijiebei_02")
					self.m_ResultAtlas:SetActive(true)
				end
			else
				if g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime(self.m_GameData.id) == false then
				else
					printerror("RefreshUnit worldcup guess logic error unit 4")
				end
			end
		else
			printerror("RefreshUnit worldcup guess logic error unit 5")
		end
	--end
end

function CSoccerWorldCupGuessBox.IsTheSameGame(self, gameId)
	if self.m_GameData == nil then
		return false
	end

	if self.m_GameData.id == gameId then
		return true
	end

	return false
end

function CSoccerWorldCupGuessBox.RefreshGameDataUI(self)
	if self.m_GameData.phase == 1 then
		--小组赛
		local group = self.m_GameData.home_team ~= 0 and data.worldcupdata.CONFIG[self.m_GameData.home_team].group or "X" 
		local round = self.m_GameData.round
		self.m_GroupStageText:SetText(group.."组")
		self.m_GroupStageText:SetActive(true)
		self.m_GroupRoundText:SetText("第"..round.."轮")
		self.m_GroupRoundText:SetActive(true)
		self.m_KnockoutStageText:SetActive(false)
	else
		--淘汰赛
		local phase = ""
		if self.m_GameData.phase == 2 then
			phase = "1/8决赛"
		elseif self.m_GameData.phase == 3 then
			phase = "1/4决赛"
		elseif self.m_GameData.phase == 4 then
			phase = "半决赛"
		elseif self.m_GameData.phase == 5 then
			phase = "季军赛"
		elseif self.m_GameData.phase == 6 then
			phase = "决赛"
		else
			phase = "error"
		end
		self.m_GroupStageText:SetActive(false)
		self.m_GroupRoundText:SetActive(false)
		self.m_KnockoutStageText:SetText(phase)
		self.m_KnockoutStageText:SetActive(true)
	end

	--比赛时间
	local gameTime = os.date("%m.%d-%H:%M", self.m_GameData.start_time)
	self.m_GameTimeText:SetText(gameTime)
	self.m_GameTimeText:SetActive(true)
	
	--主场国家名 国旗
	local home_waiting = false
	local away_waiting = false
	if self.m_GameData.home_team == nil or self.m_GameData.home_team == 0 then
		printc("1 home:", 0)
		self.m_LeftNationalNameText:SetText("待定")
		self.m_LeftNationalNameText:SetActive(true)
		self.m_LeftNationalNameText:SetGrey(false)
		self.m_LeftNationalFlagAtlas:SetSpriteName("h7_shijiebei_guoqi_ww")
		self.m_LeftNationalFlagAtlas:SetActive(true)
		self.m_LeftNationalFlagAtlas:SetGrey(false)
		home_waiting = true
	else
		printc("2 home:", data.worldcupdata.CONFIG[self.m_GameData.home_team].country)
		self.m_LeftNationalNameText:SetText(data.worldcupdata.CONFIG[self.m_GameData.home_team].country)
		self.m_LeftNationalNameText:SetActive(true)
		self.m_LeftNationalNameText:SetGrey(false)
		self.m_LeftNationalFlagAtlas:SetSpriteName("h7_shijiebei_guoqi_"..data.worldcupdata.CONFIG[self.m_GameData.home_team].national_flag)
		self.m_LeftNationalFlagAtlas:SetActive(true)
		self.m_LeftNationalFlagAtlas:SetGrey(false)
	end


	--客场国家名 国旗
	if self.m_GameData.away_team == nil or self.m_GameData.away_team == 0 then
		printc("1 away:", 0)
		self.m_RightNationalNameText:SetText("待定")
		self.m_RightNationalNameText:SetActive(true)
		self.m_RightNationalNameText:SetGrey(false)
		self.m_RightNationalFlagAtlas:SetSpriteName("h7_shijiebei_guoqi_ww")
		self.m_RightNationalFlagAtlas:SetActive(true)
		self.m_RightNationalFlagAtlas:SetGrey(false)
		away_waiting = true
	else
		printc("2 away:", data.worldcupdata.CONFIG[self.m_GameData.away_team].country)
		self.m_RightNationalNameText:SetText(data.worldcupdata.CONFIG[self.m_GameData.away_team].country)
		self.m_RightNationalNameText:SetActive(true)
		self.m_RightNationalNameText:SetGrey(false)
		self.m_RightNationalFlagAtlas:SetSpriteName("h7_shijiebei_guoqi_"..data.worldcupdata.CONFIG[self.m_GameData.away_team].national_flag)
		self.m_RightNationalFlagAtlas:SetActive(true)
		self.m_RightNationalFlagAtlas:SetGrey(false)
	end

	--竞猜按钮
	printc("g_SoccerWorldCupGuessCtrl:GetGameStatus:", g_SoccerWorldCupGuessCtrl:GetGameStatus(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
	printc("g_SoccerWorldCupGuessCtrl:IsGameGuessed:", g_SoccerWorldCupGuessCtrl:IsGameGuessed(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
	if g_SoccerWorldCupGuessCtrl:IsGameGuessed(self.m_GameData.id) == false then
		--未竞猜
		printc("g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime:", g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
		printc("g_SoccerWorldCupGuessCtrl:IsGameNoStart:", g_SoccerWorldCupGuessCtrl:IsGameNoStart(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
		printc("g_SoccerWorldCupGuessCtrl:IsGamePlaying:", g_SoccerWorldCupGuessCtrl:IsGamePlaying(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
		if g_SoccerWorldCupGuessCtrl:IsGameNoStart(self.m_GameData.id) == true and 
			g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime(self.m_GameData.id) == true then 
			--比赛未开始且未竞猜，即可竞猜(按钮都是可按状态)
			local show_home = false
			if home_waiting == false and away_waiting == false then
				show_home = true
			end
			printc("1 show_home:", show_home, " home_waiting:", home_waiting)
			self.m_LeftGuessBtn:SetActive(show_home) --如果是待定的情况，也不显示
			self.m_LeftGuessGrayBtn:SetActive(false)
			self.m_LeftHasGuessGrayBtn:SetActive(false)
			
			local show_away = false
			if away_waiting == false and home_waiting == false then
				show_away = true
			end
			printc("1 show_away:", show_away, " away_waiting:", away_waiting)
			self.m_RightGuessBtn:SetActive(show_away) --如果是待定的情况，也不显示
			self.m_RightGuessGrayBtn:SetActive(false)
			self.m_RightHasGuessGrayBtn:SetActive(false)

			--是否显示平局竞猜按钮
			local show_draw = false
			if self.m_GameData.has_match == 1 then
				if home_waiting == false and away_waiting == false then
					show_draw = true
				end
			end
			printc("1 show_draw:", show_draw)
			self.m_DrawGuessBtn:SetActive(show_draw)
			self.m_DrawGuessGrayBtn:SetActive(false)
			self.m_DrawHasGuessGrayBtn:SetActive(false)

			--竞猜结果:无
			self.m_ResultAtlas:SetActive(false)
		elseif g_SoccerWorldCupGuessCtrl:IsGamePlaying(self.m_GameData.id) or 
			g_SoccerWorldCupGuessCtrl:IsGameFinish(self.m_GameData.id) or 
			g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime(self.m_GameData.id) == false then
			--比赛已开始或以结束，但未竞猜，即已过期(按钮都是不可按状态)
			self.m_LeftGuessBtn:SetActive(false)
			self.m_LeftGuessGrayBtn:SetActive(true)
			self.m_LeftHasGuessGrayBtn:SetActive(false)
			self.m_RightGuessBtn:SetActive(false)
			self.m_RightGuessGrayBtn:SetActive(true)
			self.m_RightHasGuessGrayBtn:SetActive(false)
			self.m_DrawGuessBtn:SetActive(false)
			self.m_DrawGuessGrayBtn:SetActive(self.m_GameData.has_match == 1 and true or false)
			self.m_DrawHasGuessGrayBtn:SetActive(false)

			--竞猜结果:已过期
			self.m_ResultAtlas:SetSpriteName("h7_shijiebei_03")
			self.m_ResultAtlas:SetActive(true)
		else 
			printerror("worldcup guess logic error 1")
		end
	else
		printc("g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime:", g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
		printc("g_SoccerWorldCupGuessCtrl:IsGameNoStart:", g_SoccerWorldCupGuessCtrl:IsGameNoStart(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
		printc("g_SoccerWorldCupGuessCtrl:IsGamePlaying:", g_SoccerWorldCupGuessCtrl:IsGamePlaying(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
		if g_SoccerWorldCupGuessCtrl:IsGameNoStart(self.m_GameData.id) == true and 
			g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime(self.m_GameData.id) == true then
			--比赛未开始，但已竞猜(按钮都是不可按状态)
			local show_home = false
			if home_waiting == false and away_waiting == false then
				show_home = true
			end
			printc("2 show_home:", show_home, " home_waiting:", home_waiting)
			self.m_LeftGuessBtn:SetActive(false)
			self.m_LeftGuessGrayBtn:SetActive(show_home) --如果是待定的情况，也不显示
			self.m_LeftHasGuessGrayBtn:SetActive(false)
			
			local show_away = false
			if away_waiting == false and home_waiting == false then
				show_away = true
			end
			printc("2 show_away:", show_away, " away_waiting:", away_waiting)
			self.m_RightGuessBtn:SetActive(false)
			self.m_RightGuessGrayBtn:SetActive(show_away) --如果是待定的情况，也不显示
			self.m_RightHasGuessGrayBtn:SetActive(false)

			--是否显示平局竞猜按钮
			local show_draw = false
			if self.m_GameData.has_match == 1 then
				if home_waiting == false and away_waiting == false then
					show_draw = true
				end
			end
			printc("2 show_draw:", show_draw)
			self.m_DrawGuessBtn:SetActive(false)
			self.m_DrawGuessGrayBtn:SetActive(show_draw)
			self.m_DrawHasGuessGrayBtn:SetActive(false)

			--对应位置，按钮消失，显示已竞猜ICON
			if g_SoccerWorldCupGuessCtrl:IsGameGuessedHomeTeam(self.m_GameData.id) then
				--如果玩家竞猜的是主队
				self.m_LeftGuessGrayBtn:SetActive(false)
				self.m_LeftHasGuessGrayBtn:SetActive(true)
			elseif g_SoccerWorldCupGuessCtrl:IsGameGuessedAwayTeam(self.m_GameData.id) then
				--如果玩家竞猜的是客队
				self.m_RightGuessGrayBtn:SetActive(false)
				self.m_RightHasGuessGrayBtn:SetActive(true)
			elseif g_SoccerWorldCupGuessCtrl:IsGameGuessedDraw(self.m_GameData.id) then
				--如果玩家竞猜的是平局
				self.m_DrawGuessGrayBtn:SetActive(false)
				self.m_DrawHasGuessGrayBtn:SetActive(show_draw)
			else
				printerror("worldcup guess logic error 2")
			end

			--竞猜结果:无
			self.m_ResultAtlas:SetActive(false)
		elseif g_SoccerWorldCupGuessCtrl:IsGamePlaying(self.m_GameData.id) or 
			g_SoccerWorldCupGuessCtrl:IsGameFinish(self.m_GameData.id) or 
			g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime(self.m_GameData.id) == false then
			--比赛已开始或已结束，且已竞猜
			self.m_LeftGuessBtn:SetActive(false)
			self.m_LeftGuessGrayBtn:SetActive(true)
			self.m_LeftHasGuessGrayBtn:SetActive(false)
			self.m_RightGuessBtn:SetActive(false)
			self.m_RightGuessGrayBtn:SetActive(true)
			self.m_RightHasGuessGrayBtn:SetActive(false)
			self.m_DrawGuessBtn:SetActive(false)
			self.m_DrawGuessGrayBtn:SetActive(self.m_GameData.has_match == 1 and true or false)
			self.m_DrawHasGuessGrayBtn:SetActive(false)

			--对应位置，按钮消失，显示已竞猜ICON
			if g_SoccerWorldCupGuessCtrl:IsGameGuessedHomeTeam(self.m_GameData.id) then
				--如果玩家竞猜的是主队
				self.m_LeftGuessGrayBtn:SetActive(false)
				self.m_LeftHasGuessGrayBtn:SetActive(true)
			elseif g_SoccerWorldCupGuessCtrl:IsGameGuessedAwayTeam(self.m_GameData.id) then
				--如果玩家竞猜的是客队
				self.m_RightGuessGrayBtn:SetActive(false)
				self.m_RightHasGuessGrayBtn:SetActive(true)
			elseif g_SoccerWorldCupGuessCtrl:IsGameGuessedDraw(self.m_GameData.id) then
				--如果玩家竞猜的是平局
				self.m_DrawGuessGrayBtn:SetActive(false)
				self.m_DrawHasGuessGrayBtn:SetActive(self.m_GameData.has_match == 1 and true or false)
			else
				printerror("worldcup guess logic error 3")
			end

			--竞猜结果
			self.m_ResultAtlas:SetActive(false)
			printc("g_SoccerWorldCupGuessCtrl:IsGamePlaying:", g_SoccerWorldCupGuessCtrl:IsGamePlaying(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
			printc("g_SoccerWorldCupGuessCtrl:IsGameFinish:", g_SoccerWorldCupGuessCtrl:IsGameFinish(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
			if g_SoccerWorldCupGuessCtrl:IsGamePlaying(self.m_GameData.id) then
				--比赛还在进行中，竞猜结果还没出来
				self.m_ResultAtlas:SetActive(false)
			elseif g_SoccerWorldCupGuessCtrl:IsGameFinish(self.m_GameData.id) then
				--比赛已结束，竞猜结果已出来
				printc("g_SoccerWorldCupGuessCtrl:IsGameGuessedWin:", g_SoccerWorldCupGuessCtrl:IsGameGuessedWin(self.m_GameData.id), " self.m_GameData.id:", self.m_GameData.id)
				if g_SoccerWorldCupGuessCtrl:IsGameGuessedWin(self.m_GameData.id) then
					--竞猜成功
					self.m_ResultAtlas:SetSpriteName("h7_shijiebei_01")
					self.m_ResultAtlas:SetActive(true)
				else
					--竞猜失败
					self.m_ResultAtlas:SetSpriteName("h7_shijiebei_02")
					self.m_ResultAtlas:SetActive(true)
				end
			else
				if g_SoccerWorldCupGuessCtrl:IsGameNoStartByServerTime(self.m_GameData.id) == false then
				else
					printerror("worldcup guess logic error 4")
				end
			end
		else
			printerror("worldcup guess logic error 5")
		end
	end

	--如果比赛结束，失败的一方，国旗和国旗名字灰化
	if g_SoccerWorldCupGuessCtrl:IsGameFinish(self.m_GameData.id) then
		if g_SoccerWorldCupGuessCtrl:IsLoseTeam(self.m_GameData.id, self.m_GameData.home_team) then
			self.m_LeftNationalNameText:SetGrey(true)
			self.m_LeftNationalFlagAtlas:SetGrey(true)
		elseif g_SoccerWorldCupGuessCtrl:IsLoseTeam(self.m_GameData.id, self.m_GameData.away_team) then
			self.m_RightNationalNameText:SetGrey(true)
			self.m_RightNationalFlagAtlas:SetGrey(true)
		end
	end
end


--事件
function CSoccerWorldCupGuessBox.OnCtrlEvent(self, oCtrl)
	--printc("CSoccerWorldCupGuessBox.OnCtrlEvent oCtrl.m_EventID:", oCtrl.m_EventID)
end

return CSoccerWorldCupGuessBox
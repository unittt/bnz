local CSoccerWorldCupGuessPart = class("CSoccerWorldCupGuessPart", CPageBase)

function CSoccerWorldCupGuessPart.ctor(self, cb)
	CPageBase.ctor(self, cb)

	self.m_SoccerWorldCupGuessBox = self:NewUI(1, CSoccerWorldCupGuessBox)
	self.m_BoxGrid = self:NewUI(2, CGrid)
	self.m_TitleText = self:NewUI(3, CLabel)
	--self.m_NoGameText = self:NewUI(4, CLabel)
	--self.m_SoccerWorldCupGuessBox:SetActive(false)
end

function CSoccerWorldCupGuessPart.Destroy(self)
	CPageBase.Destroy(self)
end

function CSoccerWorldCupGuessPart.OnInitPage(self)
	printc("CSoccerWorldCupGuessPart:OnInitPage")
	if g_SoccerWorldCupGuessCtrl:IsOpening() then
	else
		self:HideAllBoxs()
	end

	self:RefreshAll()
	g_SoccerWorldCupGuessCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end


--隐藏所有格子
function CSoccerWorldCupGuessPart.HideAllBoxs(self)
	local boxList = self.m_BoxGrid:GetChildList()
	if #boxList ~= 0 then 
		for k, v in pairs(boxList) do 
			v:SetActive(false)
		end 
	end 
end

function CSoccerWorldCupGuessPart.RefreshAllBoxs(self)
	printc("CSoccerWorldCupGuessPart:RefreshAllBoxs")
	self:HideAllBoxs()

	if g_SoccerWorldCupGuessCtrl:IsOpening() and g_SoccerWorldCupGuessCtrl.m_Games ~= nil and table.count(g_SoccerWorldCupGuessCtrl.m_Games) > 0 then
		local gameTable = g_SoccerWorldCupGuessCtrl.m_Games
		local gameList = table.dict2list(gameTable, "id", false)

		table.sort(gameList, 
			function(l, r) 
				if l.start_time == r.start_time then
					return l.id < r.id
				elseif l.start_time < r.start_time then
					return true
				else
					return false
				end
			end)
			
		for i, v in ipairs(gameList) do
			local box = self.m_BoxGrid:GetChild(i)
			if box == nil then 
				box = self.m_SoccerWorldCupGuessBox:Clone()
				self.m_BoxGrid:AddChild(box)
			end
			box:SetGameData(v)
			box:SetActive(true)
		end
	end
end

function CSoccerWorldCupGuessPart.RefreshTitleText(self)
	if data.instructiondata.DESC[13015] == nil then
		self.m_TitleText:SetText("data.instructiondata.DESC[13015] == nil")
		self.m_TitleText:SetActive(true)
	else
		self.m_TitleText:SetText(data.instructiondata.DESC[13015].desc)
		self.m_TitleText:SetActive(true)
	end
end

function CSoccerWorldCupGuessPart.RefreshNoGameText(self)
	--if g_SoccerWorldCupGuessCtrl.m_Games == nil or table.count(g_SoccerWorldCupGuessCtrl.m_Games) == 0 then
	--	self.m_NoGameText:SetText("")
	--	self.m_NoGameText:SetActive(false)
	--else
	--	self.m_NoGameText:SetText("暂无比赛信息!")
	--	self.m_NoGameText:SetActive(true)
	--end
end

function CSoccerWorldCupGuessPart.RefreshAll(self)
	printc("CSoccerWorldCupGuessPart:RefreshAll")
	self:RefreshAllBoxs()
	self:RefreshTitleText()
	self:RefreshNoGameText()
end

function CSoccerWorldCupGuessPart.RefreshUnit(self)
	printc("CSoccerWorldCupGuessPart:RefreshUnit")
	if g_SoccerWorldCupGuessCtrl.m_GuessInfoUnit == nil then
		printerror("CSoccerWorldCupGuessPart:RefreshUnit g_SoccerWorldCupGuessCtrl.m_GuessInfoUnit == nil")
		return
	end

	if g_SoccerWorldCupGuessCtrl.m_Games ~= nil and table.count(g_SoccerWorldCupGuessCtrl.m_Games) > 0 then
		local gameTable = g_SoccerWorldCupGuessCtrl.m_Games
		local gameList = table.dict2list(gameTable, "id", false)
			
		for i, v in ipairs(gameList) do
			local box = self.m_BoxGrid:GetChild(i)
			if box ~= nil then 
				if box:IsTheSameGame(g_SoccerWorldCupGuessCtrl.m_GuessInfoUnit.id) then
					box:RefreshUnit()
				end
			end
		end
	end
end


--事件
function CSoccerWorldCupGuessPart.OnCtrlEvent(self, oCtrl)
	--printc("CSoccerWorldCupGuessCtrl.OnCtrlEvent oCtrl.m_EventID:", oCtrl.m_EventID)

	if oCtrl.m_EventID == define.SoccerWorldCupGuess.Event.SoccerWorldCupGuessOpen then 
		self:RefreshEventOpen()
	elseif oCtrl.m_EventID == define.SoccerWorldCupGuess.Event.SoccerWorldCupGuessClose then
		self:RefreshEventClose()		
	elseif oCtrl.m_EventID == define.SoccerWorldCupGuess.Event.SoccerWorldCupGuessInfoRefresh then
		self:RefreshEventInfoRefresh()
	elseif oCtrl.m_EventID == define.SoccerWorldCupGuess.Event.SoccerWorldCupGuessInfoUnitRefresh then
		self:RefreshEventInfoUnitRefresh()
	end
end

function CSoccerWorldCupGuessPart.RefreshEventOpen(self)
	printc("CSoccerWorldCupGuessPart:RefreshEventOpen")
	self:RefreshAll()
end

function CSoccerWorldCupGuessPart.RefreshEventClose(self)
	printc("CSoccerWorldCupGuessPart:RefreshEventClose")
	self:RefreshAll()
end

function CSoccerWorldCupGuessPart.RefreshEventInfoRefresh(self)
	printc("CSoccerWorldCupGuessPart:RefreshEventInfoRefresh")
	self:RefreshAll()
end

function CSoccerWorldCupGuessPart.RefreshEventInfoUnitRefresh(self)
	printc("CSoccerWorldCupGuessPart:RefreshEventInfoUnitRefresh")
	self:RefreshUnit()
end

return CSoccerWorldCupGuessPart
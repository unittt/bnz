local CSoccerTeamSupportPart = class("CSoccerTeamSupportPart", CPageBase)

function CSoccerTeamSupportPart.ctor(self, cb)
	CPageBase.ctor(self, cb)

	self.m_SoccerTeamSupportBox = self:NewUI(1, CSoccerTeamSupportBox)
	self.m_BoxGrid = self:NewUI(2, CGrid)
	self.m_TitleText = self:NewUI(3, CLabel)
	--self.m_NoGameText = self:NewUI(4, CLabel)
	--self.m_SoccerTeamSupportBox:SetActive(false)

	self.m_ATeam = {1001, 1002, 1003, 1004}
	self.m_BTeam = {2001, 2002, 2003, 2004}
	self.m_CTeam = {3001, 3002, 3003, 3004}
	self.m_DTeam = {4001, 4002, 4003, 4004}
	self.m_ETeam = {5001, 5002, 5003, 5004}
	self.m_FTeam = {6001, 6002, 6003, 6004}
	self.m_GTeam = {7001, 7002, 7003, 7004}
	self.m_HTeam = {8001, 8002, 8003, 8004}

	self.m_AllGroup = {self.m_ATeam, self.m_BTeam, self.m_CTeam, self.m_DTeam, self.m_ETeam, self.m_FTeam, self.m_GTeam, self.m_HTeam}
end

function CSoccerTeamSupportPart.Destroy(self)
	CPageBase.Destroy(self)
end

function CSoccerTeamSupportPart.OnInitPage(self)
	printc("CSoccerTeamSupportPart:OnInitPage")
	if g_SoccerTeamSupportCtrl:IsOpening() then
	else
		self:HideAllBoxs()
	end

	self:RefreshAll()
	g_SoccerTeamSupportCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end


--隐藏所有格子
function CSoccerTeamSupportPart.HideAllBoxs(self)
	local boxList = self.m_BoxGrid:GetChildList()
	if #boxList ~= 0 then 
		for k, v in pairs(boxList) do 
			v:SetActive(false)
		end 
	end 
end

function CSoccerTeamSupportPart.RefreshAllBoxs(self)
	printc("CSoccerTeamSupportPart:RefreshAllBoxs")
	self:HideAllBoxs()

	if g_SoccerTeamSupportCtrl:IsOpening() then
		for i1, v1 in ipairs(self.m_AllGroup) do
			local box = self.m_BoxGrid:GetChild(i1)
			if box == nil then 
				box = self.m_SoccerTeamSupportBox:Clone()
				self.m_BoxGrid:AddChild(box)
			end
			box:SetGroupTeams(i1, v1)
			box:SetActive(true)
			for i2, v2 in ipairs(v1) do
			end
		end
	end
end

function CSoccerTeamSupportPart.RefreshTitleText(self)
	if data.instructiondata.DESC[13015] == nil then
		self.m_TitleText:SetText("data.instructiondata.DESC[13016] == nil")
		self.m_TitleText:SetActive(true)
	else
		self.m_TitleText:SetText(data.instructiondata.DESC[13016].desc)
		self.m_TitleText:SetActive(true)
	end
end

function CSoccerTeamSupportPart.RefreshNoGameText(self)
	--if g_SoccerTeamSupportCtrl.m_AllSupportInfo == nil or table.count(g_SoccerTeamSupportCtrl.m_AllSupportInfo) == 0 then
	--	self.m_NoGameText:SetText("")
	--	self.m_NoGameText:SetActive(false)
	--else
	--	self.m_NoGameText:SetText("暂无比赛信息!")
	--	self.m_NoGameText:SetActive(true)
	--end
end

function CSoccerTeamSupportPart.RefreshAll(self)
	printc("CSoccerTeamSupportPart:RefreshAll")
	self:RefreshAllBoxs()
	self:RefreshTitleText()
	self:RefreshNoGameText()
end

function CSoccerTeamSupportPart.RefreshUnit(self)
	printc("CSoccerTeamSupportPart:RefreshUnit")
	if g_SoccerTeamSupportCtrl.m_SupportInfoUnit ~= nil then
		for i1, v1 in ipairs(self.m_AllGroup) do
			local box = self.m_BoxGrid:GetChild(i1)
			if box ~= nil then
				if box:IsOneOfGroupTeam(g_SoccerTeamSupportCtrl.m_SupportInfoUnit.team_id) then
					box:RefreshUnit()
				end
			end	
		end
	end
end

--事件
function CSoccerTeamSupportPart.OnCtrlEvent(self, oCtrl)
	--printc("CSoccerTeamSupportPart.OnCtrlEvent oCtrl.m_EventID:", oCtrl.m_EventID)

	if oCtrl.m_EventID == define.SoccerTeamSupport.Event.SoccerTeamSupportOpen then 
		self:RefreshEventOpen()
	elseif oCtrl.m_EventID == define.SoccerTeamSupport.Event.SoccerTeamSupportClose then
		self:RefreshEventClose()		
	elseif oCtrl.m_EventID == define.SoccerTeamSupport.Event.SoccerTeamSupportInfoRefresh then
		self:RefreshEventInfoRefresh()	
	elseif oCtrl.m_EventID == define.SoccerTeamSupport.Event.SoccerTeamSupportInfoUnitRefresh then
		self:RefreshEventInfoUnitRefresh()	
	end
end

function CSoccerTeamSupportPart.RefreshEventOpen(self)
	printc("CSoccerTeamSupportPart:RefreshEventOpen")
	self:RefreshAll()
end

function CSoccerTeamSupportPart.RefreshEventClose(self)
	printc("CSoccerTeamSupportPart:RefreshEventClose")
	self:RefreshAll()
end

function CSoccerTeamSupportPart.RefreshEventInfoRefresh(self)
	printc("CSoccerTeamSupportPart:RefreshEventInfoRefresh")
	self:RefreshAll()
end

function CSoccerTeamSupportPart.RefreshEventInfoUnitRefresh(self)
	printc("CSoccerTeamSupportPart:RefreshEventInfoUnitRefresh")
	self:RefreshUnit()
end

return CSoccerTeamSupportPart
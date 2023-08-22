local CSoccerTeamSupportCtrl = class("CSoccerTeamSupportCtrl", CCtrlBase)


function CSoccerTeamSupportCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_State = 2   				--1 活动开启阶段 2 活动结束

	self.m_MySupportTeam = 0 		--支持队伍id 没有的时候为0
	self.m_AllKnockoutTeams = nil 	--淘汰的队伍
	self.m_AllSupportInfo = nil 	--所有队伍的支持数据
	self.m_SupportInfoUnit = nil	--单个队伍的支持数据
end

function CSoccerTeamSupportCtrl.ClearAll(self)
	self.m_State = 2
	self.m_MySupportTeam = 0
	self.m_AllKnockoutTeams = nil
	self.m_AllSupportInfo = nil
	self.m_SupportInfoUnit = nil
end

function CSoccerTeamSupportCtrl.IsOpening(self)
	if self.m_State == 1 then
		return true
	else
		return false
	end
end

function CSoccerTeamSupportCtrl.CheckRedPoint(self)
	return false
end


function CSoccerTeamSupportCtrl.IsSupport(self)
	printc("CSoccerTeamSupportCtrl.IsSupport self.m_MySupportTeam:", self.m_MySupportTeam)
	if self.m_MySupportTeam == 0 then
		return false
	else
		return true
	end
end

function CSoccerTeamSupportCtrl.IsSupportTeam(self, teamId)
	if self.m_MySupportTeam ~= 0 and self.m_MySupportTeam == teamId then
		return true
	else
		return false
	end
end

function CSoccerTeamSupportCtrl.GetTeamSupportCount(self, teamId)
	if self.m_AllSupportInfo == nil then
		return 0
	end

	for k, v in pairs(self.m_AllSupportInfo) do
		if v.team_id == teamId then
			return v.num
		end	
	end

	return 0
end

function CSoccerTeamSupportCtrl.IsKnockoutTeam(self, teamId)
	if self.m_AllKnockoutTeams == nil then
		return false
	end

	for k, v in pairs(self.m_AllKnockoutTeams) do
		if v == teamId then
			return true
		end	
	end

	return false
end

function CSoccerTeamSupportCtrl.ModifySupportInfoBySupportInfoUnit(self)
	if self.m_AllSupportInfo == nil then
		printerror("CSoccerTeamSupportCtrl.ModifySupportInfoBySupportInfoUnit self.m_AllSupportInfo == nil")
		return
	end

	if self.m_SupportInfoUnit == nil then
		printerror("CSoccerTeamSupportCtrl.ModifySupportInfoBySupportInfoUnit self.m_SupportInfoUnit == nil")
		return
	end

	printc("CSoccerTeamSupportCtrl.ModifySupportInfoBySupportInfoUnit self.m_SupportInfoUnit.id:", self.m_SupportInfoUnit.team_id)
	--self.m_MySupportTeam = self.m_SupportInfoUnit.team_id
	--printc("CSoccerTeamSupportCtrl.ModifySupportInfoBySupportInfoUnit self.m_MySupportTeam:", self.m_MySupportTeam)

	local isFind = false
	for k1, v1 in pairs(self.m_AllSupportInfo) do 
		if v1.team_id == self.m_SupportInfoUnit.team_id then
			isFind = true
			v1.num = self.m_SupportInfoUnit.num
			printc("CSoccerTeamSupportCtrl.ModifySupportInfoBySupportInfoUnit v1.num = self.m_SupportInfoUnit.num v1.num:", v1.num)
		end
	end

	table.print(self.m_AllSupportInfo, "1 self.m_AllSupportInfo")

	if isFind then
		return
	end

	local supportResult = {}
	supportResult.team_id = self.m_SupportInfoUnit.team_id
	supportResult.num = self.m_SupportInfoUnit.num
	table.insert(self.m_AllSupportInfo, supportResult)
	
	table.print(self.m_AllSupportInfo, "2 self.m_AllSupportInfo")
end

function CSoccerTeamSupportCtrl.GS2CWorldCupState(self, pbdata)
	self.m_State = pbdata.state
	printc("CSoccerTeamSupportCtrl:GS2CWorldCupState self.m_State:", self.m_State)

	--抛出事件
	if self.m_State == 1 then
		self:OnEvent(define.SoccerTeamSupport.Event.SoccerTeamSupportOpen, self)
	elseif self.m_State == 2 then
		self:OnEvent(define.SoccerTeamSupport.Event.SoccerTeamSupportClose, self)
	else
		printerror("CSoccerTeamSupportCtrl.GS2CWorldCupState self.m_State:", self.m_State)
	end
end

function CSoccerTeamSupportCtrl.GS2CWorldCupChampionInfo(self, pbdata)
	self.m_MySupportTeam = pbdata.support_team
	self.m_AllKnockoutTeams = pbdata.out_team
	self.m_AllSupportInfo = pbdata.support_info

	printc("CSoccerTeamSupportCtrl:GS2CWorldCupChampionInfo self.m_MySupportTeam:", self.m_MySupportTeam)
	table.print(self.m_AllKnockoutTeams, "self.m_AllKnockoutTeams")
	table.print(self.m_AllSupportInfo, "self.m_AllSupportInfo")

	--抛出事件
	self:OnEvent(define.SoccerTeamSupport.Event.SoccerTeamSupportInfoRefresh, self)
end

function CSoccerTeamSupportCtrl.GS2CWorldCupChampionInfoUnit(self, pbdata)
	self.m_SupportInfoUnit = pbdata.support_info_unit

	printc("CSoccerTeamSupportCtrl:GS2CWorldCupChampionInfoUnit")
	table.print(self.m_SupportInfoUnit, "self.m_SupportInfoUnit")

	self:ModifySupportInfoBySupportInfoUnit()

	--抛出事件
	self:OnEvent(define.SoccerTeamSupport.Event.SoccerTeamSupportInfoUnitRefresh, self)
end



return CSoccerTeamSupportCtrl
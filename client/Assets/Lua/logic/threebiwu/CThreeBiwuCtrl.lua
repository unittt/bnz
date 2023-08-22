local CThreeBiwuCtrl = class("CThreeBiwuCtrl", CCtrlBase)

function CThreeBiwuCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_RankIndex = 0
	self.m_Point = 0
	self.m_WinTime = 0
	self.m_LastWinTime = 0
	self.m_FightTime = 0
	self.m_StartTime = 0
	self.m_BiwuStartCountTime = 0
	self.m_EndRankList = {}
	self.m_MatchingState = 0
	self.m_OtherTeamList = {}
	self.m_RandomTeamList = {}

	self.m_ViewRankList = {}
	self.m_FirstWin = 0
	self.m_FiveWin = 0
	self.m_EndTime = 0
	self.m_BiwuEndCountTime = 0
	self.m_BiwuPrepareCountTime = 0
	self.m_MatchEndTime = 0
	self.m_MatchEndTimer = nil

	self.m_FightTotal = data.huodongdata.THREEBIWUCONFIG[1].fight_limit
end

function CThreeBiwuCtrl.Clear(self)
	self.m_RankIndex = 0
	self.m_Point = 0
	self.m_WinTime = 0
	self.m_LastWinTime = 0
	self.m_FightTime = 0
	self.m_StartTime = 0
	self.m_BiwuStartCountTime = 0
	self.m_EndRankList = {}
	self.m_MatchingState = 0
	self.m_OtherTeamList = {}
	self.m_RandomTeamList = {}

	self.m_ViewRankList = {}
	self.m_FirstWin = 0
	self.m_FiveWin = 0
	self.m_EndTime = 0
	self.m_BiwuEndCountTime = 0
	self.m_BiwuPrepareCountTime = 0
	self.m_MatchEndTime = 0
	self:StopMatchEndTimer()
end

function CThreeBiwuCtrl.GS2CThreeBWMyRank(self, pbdata)
	self.m_RankIndex = pbdata.rank
	self.m_Point = pbdata.point
	self.m_WinTime = pbdata.win
	self.m_LastWinTime = pbdata.lastwin
	self.m_FightTime = pbdata.fight
	self.m_StartTime = pbdata.starttime
	self.m_EndTime = pbdata.endtime
	self.m_MatchEndTime = pbdata.matchendtime
	local oLeftEndTime = self.m_EndTime - g_TimeCtrl:GetTimeS()
	if oLeftEndTime >= 0 then
		self:SetBiwuEndCountTime(oLeftEndTime)
	end

	if pbdata.match == 0 then
		self:ResetBiwuRandomPrepareTimer()
	end
	if self.m_MatchingState == 0 and pbdata.match == 1 then
		self:SetBiwuRandomPrepareCountTime()
		self.m_MatchingState = pbdata.match
		if not g_WarCtrl:IsWar() then
			CThreeBiwuPrepareView:ShowView(function (oView)
				oView:RefreshUI()
			end)
		end
	end
	if pbdata.match == 0 then
		CThreeBiwuPrepareView:CloseView()
	end
	self.m_MatchingState = pbdata.match
	local oLeftStartTime = g_ThreeBiwuCtrl.m_StartTime - g_TimeCtrl:GetTimeS()
	if oLeftStartTime > 0 then
		self:SetBiwuStartCountTime(oLeftStartTime)
	end

	if self.m_MatchEndTime > 0 then
		self:StartMatchEndTimer()
	end
	self:OnEvent(define.ThreeBiwu.Event.BiwuInfo)
end

function CThreeBiwuCtrl.GS2CThreeBWEndRank(self, pbdata)
	self.m_EndRankList = pbdata.rankdata
	-- table.copy(pbdata.rankdata, self.m_EndRankList)
	-- table.sort(self.m_EndRankList, function (a, b)
	-- 	return a.rank < b.rank
	-- end)
	self:ResetBiwuRandomPrepareTimer()
	CThreeBiwuInfoView:CloseView()
	CThreeBiwuPrepareView:CloseView()
	CThreeBiwuRankView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

function CThreeBiwuCtrl.GS2CThreeBWNomalRank(self, pbdata)
	self.m_ViewRankList = pbdata.rankdata
	-- table.copy(pbdata.rankdata, self.m_ViewRankList)
	-- table.sort(self.m_ViewRankList, function (a, b)
	-- 	return a.rank < b.rank
	-- end)
	self.m_FirstWin = pbdata.firstwin
	self.m_FiveWin = pbdata.fivewin
	
	CThreeBiwuInfoView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

function CThreeBiwuCtrl.GS2CThreeBWBattle(self, pbdata)
	self:ResetBiwuRandomPrepareTimer()
	if not self:CheckMatchData(pbdata.match1) then
		self.m_OtherTeamList = pbdata.match1
	else
		self.m_OtherTeamList = pbdata.match2
	end
	-- table.copy(pbdata.match1 , self.m_OtherTeamList)
	if not g_WarCtrl:IsWar() then
		CThreeBiwuPrepareView:ShowView(function (oView)
			oView:RefreshUI()
		end)
	end
	local function onCallback()
		CThreeBiwuPrepareView:CloseView()
	end
	self:SetBiwuPrepareCountTime(pbdata.time, onCallback)
	self:OnEvent(define.ThreeBiwu.Event.BiwuMatch)
end

function CThreeBiwuCtrl.CheckMatchData(self, oMatch)
	for k,v in pairs(oMatch) do
		if v.name == g_AttrCtrl.name then
			return true
		end
	end
end

function CThreeBiwuCtrl.ShowPrepareView()
	if self.m_MatchingState == 1 then
		self:SetBiwuRandomPrepareCountTime()
		if not g_WarCtrl:IsWar() then
			CThreeBiwuPrepareView:ShowView(function (oView)
				oView:RefreshUI()
			end)
		end
	end
end

--比武开始的倒计时
function CThreeBiwuCtrl.SetBiwuStartCountTime(self, setTime)	
	self:ResetBiwuStartTimer()
	local function progress()
		self.m_BiwuStartCountTime = self.m_BiwuStartCountTime - 1

		self:OnEvent(define.ThreeBiwu.Event.BiwuCountTime)
		
		if self.m_BiwuStartCountTime <= 0 then
			self.m_BiwuStartCountTime = 0

			self:OnEvent(define.ThreeBiwu.Event.BiwuCountTime)

			return false
		end
		return true
	end
	self.m_BiwuStartCountTime = setTime + 1
	self.m_BiwuStartTimer = Utils.AddTimer(progress, 1, 0)
end

function CThreeBiwuCtrl.ResetBiwuStartTimer(self)
	if self.m_BiwuStartTimer then
		Utils.DelTimer(self.m_BiwuStartTimer)
		self.m_BiwuStartTimer = nil			
	end
end

--比武剩余时间的倒计时
function CThreeBiwuCtrl.SetBiwuEndCountTime(self, setTime)	
	self:ResetBiwuEndTimer()
	local function progress()
		self.m_BiwuEndCountTime = self.m_BiwuEndCountTime - 1

		self:OnEvent(define.ThreeBiwu.Event.BiwuEndCountTime)
		
		if self.m_BiwuEndCountTime <= 0 then
			self.m_BiwuEndCountTime = 0
			self:ResetBiwuRandomPrepareTimer()

			self:OnEvent(define.ThreeBiwu.Event.BiwuEndCountTime)

			return false
		end
		return true
	end
	self.m_BiwuEndCountTime = setTime + 1
	self.m_BiwuEndTimer = Utils.AddTimer(progress, 1, 0)
end

function CThreeBiwuCtrl.ResetBiwuEndTimer(self)
	if self.m_BiwuEndTimer then
		Utils.DelTimer(self.m_BiwuEndTimer)
		self.m_BiwuEndTimer = nil			
	end
end

--比武匹配关闭的倒计时
function CThreeBiwuCtrl.SetBiwuPrepareCountTime(self, setTime, onCallback)	
	self:ResetBiwuPrepareTimer()
	local function progress()
		self.m_BiwuPrepareCountTime = self.m_BiwuPrepareCountTime - 1

		self:OnEvent(define.ThreeBiwu.Event.BiwuPrepareCount)
		
		if self.m_BiwuPrepareCountTime <= 0 then
			self.m_BiwuPrepareCountTime = 0
			if onCallback then onCallback() end

			self:OnEvent(define.ThreeBiwu.Event.BiwuPrepareCount)

			return false
		end
		return true		
	end
	self.m_BiwuPrepareCountTime = setTime + 1
	self.m_BiwuPrepareTimer = Utils.AddTimer(progress, 1, 0)
end

function CThreeBiwuCtrl.ResetBiwuPrepareTimer(self)
	if self.m_BiwuPrepareTimer then
		Utils.DelTimer(self.m_BiwuPrepareTimer)
		self.m_BiwuPrepareTimer = nil			
	end
end

function CThreeBiwuCtrl.GetMyTeamList(self)
	local oList = {}
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	if not bIsJoinTeam then
		oList[1] = {grade = g_AttrCtrl.grade, icon = g_AttrCtrl.icon, school = g_AttrCtrl.school, name = g_AttrCtrl.name, score = g_AttrCtrl.score}
	else
		for k,v in pairs(g_TeamCtrl:GetMemberList()) do
			if v.status ~= define.Team.MemberStatus.Leave and v.status ~= define.Team.MemberStatus.Offline then
				table.insert(oList, v)
			end
		end
	end
	return oList
end

--匹配对手的间隔显示
function CThreeBiwuCtrl.SetBiwuRandomPrepareCountTime(self)	
	self:ResetBiwuRandomPrepareTimer()
	local function progress()
		self:SetPrepareRandomTarget()
		return true
	end
	self.m_BiwuRandomPrepareTimer = Utils.AddTimer(progress, 1, 0)
end

function CThreeBiwuCtrl.ResetBiwuRandomPrepareTimer(self)
	if self.m_BiwuRandomPrepareTimer then
		Utils.DelTimer(self.m_BiwuRandomPrepareTimer)
		self.m_BiwuRandomPrepareTimer = nil			
	end
end

function CThreeBiwuCtrl.SetPrepareRandomTarget(self)
	local oMyTeamList = self:GetMyTeamList()
	local oCount = #oMyTeamList
	local oRoleConfig = data.roletypedata.DATA
	local oLevel = 0
	local oScore = 0
	for k,v in pairs(oMyTeamList) do
		oLevel = oLevel + v.grade
		oScore = oScore + (v.score or 0)
	end
	local oRandomLevel = math.floor(oLevel/oCount)
	local oRandomScore = math.floor(oScore/oCount)
	self.m_RandomTeamList = {}
	for i = 1, #oMyTeamList do
		table.insert(self.m_RandomTeamList, {grade = Utils.RandomInt(oRandomLevel-5 >= 0 and oRandomLevel-5 or 0, oRandomLevel+5), icon = table.randomvalue({oRoleConfig[1].shape,oRoleConfig[2].shape,oRoleConfig[3].shape,oRoleConfig[4].shape,oRoleConfig[5].shape,oRoleConfig[6].shape}), 
		school = table.randomvalue({1,2,3,4,5,6}), name = g_LoginPhoneCtrl:GetRandomName(), score =  Utils.RandomInt(oRandomScore-3000 >= 0 and oRandomScore-3000 or 0, oRandomScore+3000) })
	end
	self:OnEvent(define.ThreeBiwu.Event.BiwuRandomPrepare)
end

function CThreeBiwuCtrl.GetHuodongNpcInfo(self)

	local config = data.huodongdata.THREEBIWUNPC
	local infoList = {}
	for k, v in pairs(config) do 
		local info = {}
		info.id = v.id
		info.name = v.name
		info.x = v.x
		info.y = v.y
		info.z = v.z
		table.insert(infoList, info)
	end 
	return infoList

end 

function CThreeBiwuCtrl.StartMatchEndTimer(self)
    self:StopMatchEndTimer()
    local iEndTime = self.m_MatchEndTime
    local function update()
        if g_TimeCtrl:GetTimeS() >= iEndTime then
            self:OnEvent(define.ThreeBiwu.Event.EndMatch)
            return
        end
        return true
    end
    self.m_MatchEndTimer = Utils.AddTimer(update, 1, 0)
end

function CThreeBiwuCtrl.StopMatchEndTimer(self)
	if self.m_MatchEndTimer then
        Utils.DelTimer(self.m_MatchEndTimer)
        self.m_MatchEndTimer = nil
    end
end

function CThreeBiwuCtrl.IsEndMatch(self)
	return g_TimeCtrl:GetTimeS() >= self.m_MatchEndTime
end

return CThreeBiwuCtrl
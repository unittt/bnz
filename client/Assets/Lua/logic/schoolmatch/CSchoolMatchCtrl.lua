CSchoolMatchCtrl = class("CSchoolMatchCtrl", CCtrlBase)

function CSchoolMatchCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self:Reset()
end

function CSchoolMatchCtrl.Reset(self)
	self.m_IsFinal = false
	self.m_FightTime = -1
	self.m_BattleList = nil
	self.m_MyRankInfo = nil
	self.m_RankList = nil
	self.m_MyMatchStep = 32
	self.m_IsRise = false
	self.m_GameStep = define.SchoolMatch.Step.None
	self.m_ActivityMap = 503000
	self.m_ShowTip = true
	self.m_IsFighting = false
	self.m_IsJiJun = false
end

function CSchoolMatchCtrl.SetMyRankInfo(self, dMyRank)
	self.m_MyRankInfo = dMyRank
	self:OnEvent(define.SchoolMatch.Event.RefreshMyRank)
end

function CSchoolMatchCtrl.GetMyRankInfo(self)
	return self.m_MyRankInfo
end

function CSchoolMatchCtrl.SetGameStep(self, iStep)
	self.m_GameStep = iStep
	-- if iStep == define.SchoolMatch.Step.End then
	-- 	self:OnEvent(define.SchoolMatch.Event.FinishActivity)
	-- end
	self:OnEvent(define.SchoolMatch.Event.RefreshGameStep)
end

function CSchoolMatchCtrl.GetGameStep(self)
	return self.m_GameStep 
end

function CSchoolMatchCtrl.SetRankList(self, lRank)
	self.m_RankList = lRank
	self:OnEvent(define.SchoolMatch.Event.RefreshRankList)
end

function CSchoolMatchCtrl.GetRankList(self)
	return self.m_RankList or {}
end

function CSchoolMatchCtrl.SetBattleList(self, lBattle, iCurStep, iFightTime, bShowUI)
	self.m_BattleList = lBattle
	self.m_CurStep = iCurStep
	self.m_FightTime = iFightTime
	self:CheckFighting()
	if bShowUI then
		local bIsInWar = g_WarCtrl:IsWar()
		self:CheckRise()
		if self.m_IsRise then
			self.m_IsRise = false
			CSchoolMatchRiseNoticeView:ShowView(function(oView)
				oView:ShowAfterWar(bIsInWar)
			end)
		elseif not bIsInWar then
			CSchoolMatchBattleListView:ShowView(function(oView)
				oView:RefreshAll()
				oView:CheckAutoClose()
			end)
		end
	end
	if self.m_Timer then
        Utils.DelTimer(self.m_Timer)
        self.m_Timer = nil
    end
    local function update()
        if self.m_FightTime <= 0 then
        	return
        end
        self.m_FightTime = self.m_FightTime - 1
        return true
    end
    self.m_Timer = Utils.AddTimer(update, 1, 0)
    self:OnEvent(define.SchoolMatch.Event.RefreshBattleList)
end

function CSchoolMatchCtrl.CheckRise(self)
	self.m_IsRise = false
	local iCurStep = self:GetMatchStep()
	for i,dBattle in ipairs(self.m_BattleList) do
		if self.m_MyMatchStep > iCurStep then
			if g_TeamCtrl:IsInTeam(dBattle.win) then
				if dBattle.jijun then
					return
				end
				self.m_IsRise = g_TeamCtrl:IsInTeam() 
				self.m_MyMatchStep = iCurStep/2
				return 
			elseif dBattle.win == 1 and 
				(g_TeamCtrl:IsInTeam(dBattle.fighter1.pid) or g_TeamCtrl:IsInTeam(dBattle.fighter2.pid)) then
				self.m_IsRise = g_TeamCtrl:IsInTeam() 
				self.m_MyMatchStep = iCurStep
				return  
			end
		end
	end
end

-- 检测自己是否被淘汰
function CSchoolMatchCtrl.CheckFighting(self)
	local iCurStep = self:GetMatchStep()
	local iPid = g_AttrCtrl.pid
	self.m_IsFighting = false
	self.m_IsJiJun = false
	for i, dBattle in ipairs(self.m_BattleList) do
		if g_TeamCtrl:IsInTeam(dBattle.fighter1.pid) or g_TeamCtrl:IsInTeam(dBattle.fighter2.pid) then
			self.m_IsFighting = true
			if iCurStep == 2 then
				self.m_IsJiJun = 1 == dBattle.jijun
			end
			return
		end
	end
end

function CSchoolMatchCtrl.GetMatchStep(self)
	return self.m_CurStep or 0
end

function CSchoolMatchCtrl.GetBattleList(self)
	return self.m_BattleList
end

function CSchoolMatchCtrl.FinishActivity(self, lWinner)
	self.m_WinnerList = lWinner
	CSchoolMatchWinnerView:ShowView()
	self:OnEvent(define.SchoolMatch.Event.FinishActivity)
end

function CSchoolMatchCtrl.GetEnemyTeam(self)
	if not self.m_BattleList then
		return
	end
	for i, dBattle in ipairs(self.m_BattleList) do
		if g_TeamCtrl:IsInTeam(dBattle.fighter1.pid) then
			return dBattle.fighter2
		elseif g_TeamCtrl:IsInTeam(dBattle.fighter2.pid) then
			return dBattle.fighter1
		end
	end
end

function CSchoolMatchCtrl.GetHuodongNpcInfo(self)

	local config = data.huodongdata.LIUMAINPC
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

return CSchoolMatchCtrl

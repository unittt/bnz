local CSingleBiwuCtrl = class("CSingleBiwuCtrl", CCtrlBase)

function CSingleBiwuCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_MyRank = 0
	self.m_MyPoint = 0
	self.m_MyGroup = 0
	self.m_WinTime = 0
	self.m_LastWinTime = 0
	self.m_FightTime = 0
	self.m_StartTime = 0
	self.m_BiwuStartCountTime = 0
	self.m_EndRankList = {}
	self.m_MatchingState = 0

	self.m_ViewRankList = {}
	self.m_FirstWin = 0
	self.m_FiveWin = 0
	self.m_EndTime = 0
	self.m_BiwuEndCountTime = 0
	self.m_BiwuPrepareCountTime = 0
	self.m_MaxRankLimit = 30
	self.m_SingleWarInfo = {}
	self.m_FinalRankList = {}

	self.m_BiwuMapId = 509000 --战斗地图

	self.m_FightTotal = data.huodongdata.SINGLEWAR_CONFIG[1].max_war_cnt
end

function CSingleBiwuCtrl.Clear(self)
	self:ResetBiwuStartTimer()
	self:ResetBiwuEndTimer()
	self:ResetBiwuPrepareTimer()
	self:ResetBiwuRandomPrepareTimer()

	self.m_MyRank = 0
	self.m_MyPoint = 0
	self.m_MyGroup = 0
	self.m_WinTime = 0
	self.m_LastWinTime = 0
	self.m_FightTime = 0
	self.m_StartTime = 0
	self.m_BiwuStartCountTime = 0
	self.m_EndRankList = {}
	self.m_MatchingState = 0
	self.m_OtherTeamList = {}
	self.m_RandomTeamList = {}
	self.m_SingleWarInfo = {}
	self.m_FinalRankList = {}

	self.m_ViewRankList = {}
	self.m_FirstWin = 0
	self.m_FiveWin = 0
	self.m_EndTime = 0
	self.m_BiwuEndCountTime = 0
	self.m_BiwuPrepareCountTime = 0
end

function CSingleBiwuCtrl.GS2CSingleWarInfo(self, dInfo)
	self:UpdateSingleWarInfo(dInfo)
	self.m_MyRank = self.m_SingleWarInfo.rank
	self.m_MyPoint = self.m_SingleWarInfo.point
	self.m_WinTime = self.m_SingleWarInfo.win
	self.m_LastWinTime = self.m_SingleWarInfo.win_seri_curr
	self.m_FightTime = self.m_SingleWarInfo.war_cnt
	self.m_StartTime = self.m_SingleWarInfo.start_time
	self.m_EndTime = self.m_SingleWarInfo.end_time
	self.m_MyGroup = self.m_SingleWarInfo.group_id
	local oLeftEndTime = self.m_EndTime - g_TimeCtrl:GetTimeS()
		-- printc("当前时间",g_TimeCtrl:Convert( g_TimeCtrl:GetTimeS()))
	if oLeftEndTime >= 0 then
		-- printc("结束时间",g_TimeCtrl:Convert(self.m_EndTime))
		self:SetBiwuEndCountTime(oLeftEndTime)
	end

	if self.m_SingleWarInfo.is_match == 0 then
		self:ResetBiwuRandomPrepareTimer()
	end

	if self.m_MatchingState == 0 and self.m_SingleWarInfo.is_match == 1 then
		self:SetBiwuRandomPrepareCountTime()
		self.m_MatchingState = self.m_SingleWarInfo.match
		if not g_WarCtrl:IsWar() and self:IsActivityStart() then
			CSingleBiwuPrepareView:ShowView(function (oView)
				oView:RefreshUI()
			end)
		end
	end
	if self.m_SingleWarInfo.is_match == 0 then
		--TODO：可能要延迟处理关闭了，和下面的自动倒计时3秒冲突
		-- CSingleBiwuPrepareView:CloseView()
	end
	self.m_MatchingState = self.m_SingleWarInfo.is_match
	local oLeftStartTime = self.m_StartTime - g_TimeCtrl:GetTimeS()
	if oLeftStartTime > 0 then
		-- printc("开始时间",g_TimeCtrl:Convert(self.m_StartTime), oLeftStartTime)
		self:SetBiwuStartCountTime(oLeftStartTime)
	end

	self:OnEvent(define.SingleBiwu.Event.BiwuInfo)
end

function CSingleBiwuCtrl.UpdateSingleWarInfo(self, dInfo)
	local dTempInfo = {}
	if dInfo then
		local dDecode = g_NetCtrl:DecodeMaskData(dInfo, "singleBiwu")
		table.update(dTempInfo, dDecode)
		for k , v in pairs(dTempInfo) do
			if self.m_SingleWarInfo[k] ~= v then
				self.m_SingleWarInfo[k] = v
			end
		end
	end
end

function CSingleBiwuCtrl.GS2CSingleWarRank(self, pbdata)
	self:OnEvent(define.SingleBiwu.Event.RefreshRankList, pbdata.rank_info)
end

function CSingleBiwuCtrl.GS2CSingleWarMatchResult(self, role, score)
	self:ResetBiwuRandomPrepareTimer()
	local dInfo = {}
	table.copy(role, dInfo)
	dInfo.score = score
	if not g_WarCtrl:IsWar() then
		local oView = CSingleBiwuPrepareView:GetView()
		if not oView then
			CSingleBiwuPrepareView:ShowView(function(oView)
				oView:RefreshUI()
				oView:RefreshPlayerBox(oView.m_PlayerBoxR, dInfo)
			end)
		else
			oView:RefreshUI()
		end
	end
	local function onCallback()
		CSingleBiwuPrepareView:CloseView()
	end
	self:SetBiwuPrepareCountTime(3, onCallback)
	self:OnEvent(define.SingleBiwu.Event.BiwuMatch, dInfo)
end

function CSingleBiwuCtrl.GS2CSingleWarFinalRank(self, pbdata)
	self.m_FinalRankList = pbdata.rank_list
	self.m_FinalRank = pbdata.my_rank
	self.m_FinalPoint = pbdata.point

	CSingleBiwuInfoView:CloseView()
	CSingleBiwuPrepareView:CloseView()
	CSingleBiwuRankView:ShowView()
end

function CSingleBiwuCtrl.GetFinalRankListByGroup(self, iGroup)
	local list = {}
	for i,v in ipairs(self.m_FinalRankList) do
		if v.group_id == iGroup then
			return table.copy(list, v.rank_info)
		end
	end
	return list
end

--比武开始的倒计时
function CSingleBiwuCtrl.SetBiwuStartCountTime(self, setTime)	
	self:ResetBiwuStartTimer()
	local function progress()
		self.m_BiwuStartCountTime = self.m_BiwuStartCountTime - 1

		self:OnEvent(define.SingleBiwu.Event.BiwuCountTime)
		
		if self.m_BiwuStartCountTime < 0 then
			self.m_BiwuStartCountTime = 0

			self:OnEvent(define.SingleBiwu.Event.BiwuCountTime)

			return false
		end
		return true
	end
	self.m_BiwuStartCountTime = setTime + 1
	self.m_BiwuStartTimer = Utils.AddTimer(progress, 1, 0)
end

function CSingleBiwuCtrl.ResetBiwuStartTimer(self)
	if self.m_BiwuStartTimer then
		Utils.DelTimer(self.m_BiwuStartTimer)
		self.m_BiwuStartTimer = nil			
	end
end

--比武剩余时间的倒计时
function CSingleBiwuCtrl.SetBiwuEndCountTime(self, setTime)	
	self:ResetBiwuEndTimer()
	local function progress()
		self.m_BiwuEndCountTime = self.m_BiwuEndCountTime - 1

		self:OnEvent(define.SingleBiwu.Event.BiwuEndCountTime)
		
		if self.m_BiwuEndCountTime <= 0 then
			self.m_BiwuEndCountTime = 0
			self:ResetBiwuRandomPrepareTimer()

			self:OnEvent(define.SingleBiwu.Event.BiwuEndCountTime)

			return false
		end
		return true
	end
	self.m_BiwuEndCountTime = setTime + 1
	self.m_BiwuEndTimer = Utils.AddTimer(progress, 1, 0)
end

function CSingleBiwuCtrl.ResetBiwuEndTimer(self)
	if self.m_BiwuEndTimer then
		Utils.DelTimer(self.m_BiwuEndTimer)
		self.m_BiwuEndTimer = nil			
	end
end

--比武匹配关闭的倒计时
function CSingleBiwuCtrl.SetBiwuPrepareCountTime(self, setTime, onCallback)	
	self:ResetBiwuPrepareTimer()
	local function progress()
		self.m_BiwuPrepareCountTime = self.m_BiwuPrepareCountTime - 1

		self:OnEvent(define.SingleBiwu.Event.BiwuPrepareCount)
		if self.m_BiwuPrepareCountTime <= 0 then
			self.m_BiwuPrepareCountTime = 0
			if onCallback then onCallback() end

			self:OnEvent(define.SingleBiwu.Event.BiwuPrepareCount)

			return false
		end
		return true		
	end
	self.m_BiwuPrepareCountTime = setTime + 1
	self.m_BiwuPrepareTimer = Utils.AddTimer(progress, 1, 0)
end

function CSingleBiwuCtrl.ResetBiwuPrepareTimer(self)
	if self.m_BiwuPrepareTimer then
		Utils.DelTimer(self.m_BiwuPrepareTimer)
		self.m_BiwuPrepareTimer = nil			
	end
end

--匹配对手的间隔显示
function CSingleBiwuCtrl.SetBiwuRandomPrepareCountTime(self)	
	self:ResetBiwuRandomPrepareTimer()
	local function progress()
		local dPlayer = self:GetPrepareRandomTarget()
		self:OnEvent(define.SingleBiwu.Event.BiwuMatch, dPlayer)
		return true
	end
	self.m_BiwuRandomPrepareTimer = Utils.AddTimer(progress, 1, 0)
end

function CSingleBiwuCtrl.ResetBiwuRandomPrepareTimer(self)
	if self.m_BiwuRandomPrepareTimer then
		Utils.DelTimer(self.m_BiwuRandomPrepareTimer)
		self.m_BiwuRandomPrepareTimer = nil			
	end
end

function CSingleBiwuCtrl.GetPrepareRandomTarget(self)
	local tGroup = data.huodongdata.SINGLEWAR_GROUP[self.m_MyGroup]
	local tRoleConfig = data.roletypedata.DATA
	local dPlayer = {
    	name = g_LoginPhoneCtrl:GetRandomName();
    	grade = math.min(Utils.RandomInt(tGroup.min_grade, tGroup.max_grade), g_AttrCtrl.server_grade);
    	school = table.randomvalue({1,2,3,4,5,6});
    	icon = table.randomvalue({tRoleConfig[1].shape,tRoleConfig[2].shape,tRoleConfig[3].shape,tRoleConfig[4].shape,tRoleConfig[5].shape,tRoleConfig[6].shape}), 
		score = Utils.RandomInt(g_AttrCtrl.score - 1000, g_AttrCtrl.score + 1000),
	}
	return dPlayer
end

function CSingleBiwuCtrl.IsActivityStart(self)
	return self.m_StartTime ~= 0 and self.m_StartTime <= g_TimeCtrl:GetTimeS() and self.m_EndTime >= g_TimeCtrl:GetTimeS()
end

function CSingleBiwuCtrl.IsActivityEnd(self)
	return self.m_EndTime < g_TimeCtrl:GetTimeS()
end

function CSingleBiwuCtrl.IsOverFightCnt(self)
	return self.m_SingleWarInfo.war_cnt and self.m_SingleWarInfo.war_cnt == self.m_FightTotal
end

function CSingleBiwuCtrl.IsInMatch(self)
	return self.m_SingleWarInfo.is_match == 1
end

function CSingleBiwuCtrl.GetHuodongNpcInfo(self)

	local config = data.huodongdata.SINGLEWARNPC
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

return CSingleBiwuCtrl
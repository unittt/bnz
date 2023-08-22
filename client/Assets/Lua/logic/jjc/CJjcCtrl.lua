local CJjcCtrl = class("CJjcCtrl", CCtrlBase)

function CJjcCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_InitTime = 0

	self.m_Rank = 0
	self.m_LeftCount = 0
	self.m_LeftTime = 0
	self.m_JjcMainInfo = {rank = 0, fighttimes = 0, fightcd = 0, nextseason = 0}
	self.m_JjcOldMainInfo = {}
	self.m_JjcMainBuddyList = {}
	self.m_JjcMainBuddyClick = nil
	self.m_JjcMainSummonClick = nil
	self.m_JjcMainSummonid = 0
	self.m_JjcMainSummonicon = 0
	self.m_JjcMainSummonlv = 0
	self.m_JjcMainFmtid = 0
	self.m_JjcMainFmtlv = 0
	self.m_JjcMainHasBuy = 0
	self.m_JjcMainCountTime = 0
	self.m_JjcMainTopList = {}
	self.m_JjcMainNextSeason = 0
	self.m_JjcMainRefreshTime = 0
	self.m_JjcMainRefreshCountTime = 0

	self.m_JjcChallengeList = {}
	self.m_JjcChallengeRewardTime = 0

	self.m_JjcChallengeChooseDifficulty = 1
	self.m_JjcChallengeTargetList = {}
	self.m_JjcChallengeKillList = {}
	self.m_JjcChallengeResetTime = 0

	self.m_JjcChallengeBuddyList = {}
	self.m_JjcChallengeBuddyClick = nil
	self.m_JjcChallengeSummonClick = nil
	self.m_JjcChallengeSummonid = 0
	self.m_JjcChallengeSummonicon = 0
	self.m_JjcChallengeSummonlv = 0
	self.m_JjcChallengeFmtid = 0
	self.m_JjcChallengeFmtlv = 0

	self.m_JjcMessageRedPoint = nil

	self.m_GlobalLeftTimes = 0
	self.m_JjcMainFirstGiftData = 0
	self.m_JjcFightLogList = {}

	self.m_JjcOutSideRankStr = "未上榜"--"1000名以外"
	self.m_JjcOutSidePrizeRankStr = "5000名以外"
	self.m_JjcOutSideRank = 1000
end

function CJjcCtrl.GS2CJJCMainInfo(self, pbdata)
	local mask = pbdata.mask
	local rank = pbdata.rank
	local infos = pbdata.infos
	local lineup = pbdata.lineup
	local fighttimes = pbdata.fighttimes
	local fightcd = pbdata.fightcd
	local hasbuy = pbdata.hasbuy
	local top3 = pbdata.top3
	local nextseason = pbdata.nextseason

	g_JjcCtrl:GetJjcMainInfoSaveData()
	--没有rank这个数据时这里是为nil
	if rank then
		-- printc("CJjcCtrl.GS2CJJCMainInfo rank")
		self.m_Rank = rank
		self.m_JjcMainInfo.rank = rank

		self.m_InitTime = self.m_InitTime + 1
		printc("竞技场动画所需次数 ", self.m_InitTime)
		if self.m_InitTime <= 1 then
			g_JjcCtrl:SaveJjcMainInfoData(g_JjcCtrl.m_JjcMainInfo)
		end
	end
	if fighttimes then
		self.m_LeftCount = fighttimes
		self.m_JjcMainInfo.fighttimes = fighttimes
	end
	if fightcd then
		self.m_LeftTime = fightcd
		self.m_JjcMainInfo.fightcd = fightcd

		if self.m_LeftTime >= 0 then
			self:SetJjcMainCountTime()
		end
	end
	if infos then
		self.m_JjcMainInfo.infos = infos
		if self.m_InitTime <= 1 then
			g_JjcCtrl:SaveJjcMainInfoData(g_JjcCtrl.m_JjcMainInfo)
		end
	end

	--更新这个lineup时，必须把所有的lineup里面的东西发过来，不然不知道是没有这个数据更新还是某一个条目的更新(其他为nil)
	if lineup then
		--没有lineup.summid这个数据时这里不是为nil，为0
		self.m_JjcMainSummonid = lineup.summid
		self.m_JjcMainSummonicon = lineup.summicon
		self.m_JjcMainSummonlv = lineup.summlv
		self.m_JjcMainFmtid = lineup.fmtid
		self.m_JjcMainFmtlv = lineup.fmtlv

		printc("CJjcCtrl.GS2CJJCMainInfo lineup.fighters", #lineup.fighters)
		
		self.m_JjcMainBuddyList = {}
		for k,v in ipairs(lineup.fighters) do
			self.m_JjcMainBuddyList[k] = v
		end
	end
	if hasbuy then
		self.m_JjcMainHasBuy = hasbuy
	end

	if top3 then
		self.m_JjcMainTopList = {}
		for k,v in pairs(top3) do
			self.m_JjcMainTopList[k] = v
		end
		table.sort(self.m_JjcMainTopList, function (a, b) return a.rank < b.rank end)
	end

	if nextseason then
		self.m_JjcMainNextSeason = nextseason
		self.m_JjcMainInfo.nextseason = nextseason
		if self.m_InitTime <= 1 then
			g_JjcCtrl:SaveJjcMainInfoData(g_JjcCtrl.m_JjcMainInfo)
		end
	end

	if pbdata.first_gift_status then
		self.m_JjcMainFirstGiftData = pbdata.first_gift_status
	end

	if pbdata.refresh_time then
		self.m_JjcMainRefreshTime = pbdata.refresh_time
		self:SetJjcMainRefreshCountTime()
	end

	self:OnEvent(define.Jjc.Event.RefreshJJCMainUI, pbdata)
	table.print(pbdata, "CJjcCtrl.GS2CJJCMainInfo")
end

function CJjcCtrl.GS2CJJCTargetLineupInfo(self, pbdata)
	local target = pbdata.target
	local lineup = pbdata.lineup

	self:OnEvent(define.Jjc.Event.JJCTargetLineup, pbdata)
	table.print(pbdata, "CJjcCtrl.GS2CJJCTargetLineupInfo")
end

function CJjcCtrl.GS2CJJCFightLog(self, pbdata)
	local logs = pbdata.logs

	self.m_JjcFightLogList = pbdata.logs
	self.m_JjcMessageRedPoint = nil

	self:OnEvent(define.Jjc.Event.JJCFightLog, pbdata)
	table.print(pbdata, "CJjcCtrl.GS2CJJCTargetLineupInfo")
end

function CJjcCtrl.GS2CJJCFightEndInfo(self, pbdata)
	local oldrank = pbdata.oldrank
	local newrank = pbdata.newrank
	local result = pbdata.result
	local items = pbdata.items

	CJjcResultView:ShowView(function(oView)
		oView:SetContent(pbdata)
	end)

	table.print(pbdata, "CJjcCtrl.GS2CJJCFightEndInfo")
end

--竞技场挑战界面协议返回
function CJjcCtrl.GS2CChallengeChooseRank(self, pbdata)
	local reward = pbdata.reward

	-- self.m_JjcChallengeList = difficultys
	self.m_JjcChallengeRewardTime = reward

	self:OnEvent(define.Jjc.Event.JJCChallengeChooseRankUI, pbdata)
	table.print(pbdata, "CJjcCtrl.GS2CChallengeChooseRank")
end

--竞技场挑战详情界面协议返回
function CJjcCtrl.GS2CChallengeMainInfo(self, pbdata)
	local mask = pbdata.mask
	local difficulty = pbdata.difficulty
	local targets = pbdata.targets
	local lineup = pbdata.lineup
	local beats = pbdata.beats
	local times = pbdata.times

	if difficulty then
		self.m_JjcChallengeChooseDifficulty = difficulty
	end
	if targets then
		self.m_JjcChallengeTargetList = {}
		for k,v in pairs(targets) do
			self.m_JjcChallengeTargetList[k] = v
		end
		-- table.sort(self.m_JjcChallengeTargetList, function (a, b)
		-- 	return a.score < b.score
		-- end)
	end
	if lineup then
		self.m_JjcChallengeSummonid = lineup.summid
		self.m_JjcChallengeSummonicon = lineup.summicon
		self.m_JjcChallengeSummonlv = lineup.summlv
		self.m_JjcChallengeFmtid = lineup.fmtid
		self.m_JjcChallengeFmtlv = lineup.fmtlv

		printc("CJjcCtrl.GS2CChallengeMainInfo lineup.fighters", #lineup.fighters)
		
		self.m_JjcChallengeBuddyList = {}
		for k,v in ipairs(lineup.fighters) do
			self.m_JjcChallengeBuddyList[k] = v
		end
	end
	if beats then
		self.m_JjcChallengeKillList = beats
	end
	if times then
		self.m_JjcChallengeResetTime = times
	end

	local oView = CJjcMainView:GetView()
	if not oView then
		CJjcMainView:ShowView(function (oView)
			oView:ShowSubPageByIndex(2)
			oView.m_GroupPart:ShowDetailBox()
			oView.m_GroupPart.m_DetailBox:RefreshJJCChallengeMainInfoUI(pbdata)
		end)
	else
		self:OnEvent(define.Jjc.Event.JJCChallengeMainInfoUI, pbdata)
	end
	table.print(pbdata, "CJjcCtrl.GS2CChallengeMainInfo")
end

function CJjcCtrl.GS2CChallengeTargetLineup(self, pbdata)
	local target = pbdata.target
	local lineup = pbdata.lineup

	self:OnEvent(define.Jjc.Event.JJCChallengeTargetLineup, pbdata)
	table.print(pbdata, "CJjcCtrl.GS2CChallengeTargetLineup")
end

function CJjcCtrl.GS2CJJCNotifyLog(self, pbdata)
	self.m_JjcMessageRedPoint = 1
	self:OnEvent(define.Jjc.Event.JJCMessageRedPoint, pbdata)
end

function CJjcCtrl.GS2CJJCLeftTimes(self, pbdata)
	self.m_GlobalLeftTimes = pbdata.left_times
	g_ScheduleCtrl:CheckJjcExtraPt()
end

function CJjcCtrl.GetIsJjcMainBuddyIsInFight(self, buddyid)
	for k,v in ipairs(self.m_JjcMainBuddyList) do
		if v.id == buddyid then
			return true
		end
	end
	return false
end

function CJjcCtrl.GetIsJjcChallengeBuddyIsInFight(self, buddyid)
	for k,v in ipairs(self.m_JjcChallengeBuddyList) do
		if v.type == 2 and v.id == buddyid then
			return true
		end
	end
	return false
end

--type 1是玩家，2是机器人
--oData = {type = 1, id = ?}
function CJjcCtrl.GetIsJjcChallengeTargetKilled(self, oData)
	for k,v in pairs(self.m_JjcChallengeKillList) do
		if v.id == oData.id and v.type == oData.type then
			return true
		end
	end
	return false
end

--type 1是好友，2是伙伴
function CJjcCtrl.GetIsFriendInvite(self)
	for k,v in ipairs(self.m_JjcChallengeBuddyList) do
		if v.type == 1 then
			return true
		end
	end
	return false
end

--保存竞技界面的挑战数据在本地
function CJjcCtrl.SaveJjcMainInfoData(self, t)
	local path = IOTools.GetRoleFilePath("/jjcmaininfo")
	IOTools.SaveJsonFile(path, t)
end

--获取竞技界面的挑战数据
--本地保存文件会把key变为字符串,{"12":1}
function CJjcCtrl.GetJjcMainInfoSaveData(self)
	local path = IOTools.GetRoleFilePath("/jjcmaininfo")
	local t = IOTools.LoadJsonFile(path) or {}
	self.m_JjcOldMainInfo = {}
	for k,v in pairs(t) do
		self.m_JjcOldMainInfo[k] = v
	end
end

--挑战界面的挑战冷却倒计时
function CJjcCtrl.SetJjcMainCountTime(self)
	self:ResetJjcMainCountTimer()
	local function progress()
		self.m_JjcMainCountTime = self.m_JjcMainCountTime - 1
		self:OnEvent(define.Jjc.Event.JJCMainCountTime)
		
		if self.m_JjcMainCountTime <= 0 then
			self.m_JjcMainCountTime = 0

			self:OnEvent(define.Jjc.Event.JJCMainCountTime)

			return false
		end
		return true
	end
	self.m_JjcMainCountTime = self.m_LeftTime + 1
	self.m_JjcMainCountTimer = Utils.AddTimer(progress, 1, 0)
end

function CJjcCtrl.ResetJjcMainCountTimer(self)
	if self.m_JjcMainCountTimer then
		Utils.DelTimer(self.m_JjcMainCountTimer)
		self.m_JjcMainCountTimer = nil			
	end
end

--竞技场界面的刷新冷却倒计时
function CJjcCtrl.SetJjcMainRefreshCountTime(self)
	self:ResetJjcMainRefreshCountTimer()
	local function progress()
		self.m_JjcMainRefreshCountTime = self.m_JjcMainRefreshCountTime - 1
		self:OnEvent(define.Jjc.Event.JJCMainRefreshCountTime)
		
		if self.m_JjcMainRefreshCountTime <= 0 then
			self.m_JjcMainRefreshCountTime = 0

			self:OnEvent(define.Jjc.Event.JJCMainRefreshCountTime)

			return false
		end
		return true
	end
	self.m_JjcMainRefreshCountTime = self.m_JjcMainRefreshTime + 1
	self.m_JjcMainRefreshCountTimer = Utils.AddTimer(progress, 1, 0)
end

function CJjcCtrl.ResetJjcMainRefreshCountTimer(self)
	if self.m_JjcMainRefreshCountTimer then
		Utils.DelTimer(self.m_JjcMainRefreshCountTimer)
		self.m_JjcMainRefreshCountTimer = nil			
	end
end

function CJjcCtrl.GetDayConfigPrize(self, rank)
	local config = nil
	for k,v in ipairs(data.jjcdata.DAYREWARD) do
		if v.rank[1] <= rank and (v.rank[2] and v.rank[2] or v.rank[1]) >= rank then
			config = v
			break
		end
	end
	local list = {}
	if config then
		for k,v in pairs(config.item) do
			list[k] = v
		end
	end
	--暂时屏蔽竞技场积分
	-- local item = {amont = config.point, sid = 1009,}
	-- table.insert(list, item)
	return list, config
end

function CJjcCtrl.GetMonthConfigPrize(self, rank)
	local config = nil
	for k,v in ipairs(data.jjcdata.MONTHREWARD) do
		if v.rank[1] <= rank and (v.rank[2] and v.rank[2] or v.rank[1]) >= rank then
			config = v
			break
		end
	end
	local list = {}
	if config then
		for k,v in pairs(config.item) do
			list[k] = v
		end
	end
	--暂时屏蔽竞技场积分
	-- local item = {amont = config.point, sid = 1009,}
	-- table.insert(list, item)
	return list, config
end

function CJjcCtrl.GetJjcNewTargetList(self)
	local oList = {}
	for k,v in ipairs(self.m_JjcMainTopList) do
		table.insert(oList, {data = v, type = 1})
	end
	if self.m_JjcMainInfo.infos then
		for k,v in ipairs(self.m_JjcMainInfo.infos) do
			table.insert(oList, {data = v, type = 2})
		end
	end
	return oList
end

function CJjcCtrl.OpenJjcMainView(self)
	local jjcOpenSta = g_OpenSysCtrl:GetOpenSysState(define.System.JJC, true)
	if not jjcOpenSta then
		return
	end

	-- CJjcMainView:ShowView(function (oView)
	-- 	oView:ShowSubPageByIndex(oView:GetPageIndex("Single"))
	-- end)
    CJjcMainNewView:ShowView(function (oView)
        oView:RefreshUI()
    end)
end

return CJjcCtrl
module(..., package.seeall)

--GS2C--

function GS2CJJCMainInfo(pbdata)
	local mask = pbdata.mask
	local rank = pbdata.rank
	local infos = pbdata.infos
	local lineup = pbdata.lineup
	local fighttimes = pbdata.fighttimes
	local fightcd = pbdata.fightcd
	local hasbuy = pbdata.hasbuy
	local top3 = pbdata.top3
	local nextseason = pbdata.nextseason
	local first_gift_status = pbdata.first_gift_status --0:不能领 1:可领, 2:已领
	local refresh_time = pbdata.refresh_time --刷新时间
	--todo
	local data = g_NetCtrl:DecodeMaskData(pbdata, "jjcMain")
	g_JjcCtrl:GS2CJJCMainInfo(data)
end

function GS2CJJCTargetLineupInfo(pbdata)
	local target = pbdata.target
	local lineup = pbdata.lineup
	--todo
	g_JjcCtrl:GS2CJJCTargetLineupInfo(pbdata)
end

function GS2CJJCFightLog(pbdata)
	local logs = pbdata.logs
	--todo
	g_JjcCtrl:GS2CJJCFightLog(pbdata)
end

function GS2CJJCFightEndInfo(pbdata)
	local oldrank = pbdata.oldrank
	local newrank = pbdata.newrank
	local result = pbdata.result
	local items = pbdata.items
	--todo
	g_JjcCtrl:GS2CJJCFightEndInfo(pbdata)
end

function GS2CChallengeChooseRank(pbdata)
	local reward = pbdata.reward
	--todo
	g_JjcCtrl:GS2CChallengeChooseRank(pbdata)
end

function GS2CChallengeMainInfo(pbdata)
	local mask = pbdata.mask
	local difficulty = pbdata.difficulty
	local targets = pbdata.targets
	local lineup = pbdata.lineup
	local beats = pbdata.beats
	local times = pbdata.times
	--todo
	local data = g_NetCtrl:DecodeMaskData(pbdata, "jjcChallenge")
	g_JjcCtrl:GS2CChallengeMainInfo(data)
end

function GS2CChallengeTargetLineup(pbdata)
	local target = pbdata.target
	local lineup = pbdata.lineup
	--todo
	g_JjcCtrl:GS2CChallengeTargetLineup(pbdata)
end

function GS2CJJCNotifyLog(pbdata)
	--todo
	g_JjcCtrl:GS2CJJCNotifyLog(pbdata)
end

function GS2CJJCLeftTimes(pbdata)
	local left_times = pbdata.left_times
	--todo
	g_JjcCtrl:GS2CJJCLeftTimes(pbdata)
end


--C2GS--

function C2GSOpenJJCMainUI()
	local t = {
	}
	g_NetCtrl:Send("jjc", "C2GSOpenJJCMainUI", t)
end

function C2GSSetJJCFormation(formation)
	local t = {
		formation = formation,
	}
	g_NetCtrl:Send("jjc", "C2GSSetJJCFormation", t)
end

function C2GSSetJJCSummon(summonid)
	local t = {
		summonid = summonid,
	}
	g_NetCtrl:Send("jjc", "C2GSSetJJCSummon", t)
end

function C2GSSetJJCPartner(partnerids)
	local t = {
		partnerids = partnerids,
	}
	g_NetCtrl:Send("jjc", "C2GSSetJJCPartner", t)
end

function C2GSQueryJJCTargetLineup(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("jjc", "C2GSQueryJJCTargetLineup", t)
end

function C2GSJJCStartFight(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("jjc", "C2GSJJCStartFight", t)
end

function C2GSJJCGetFightLog()
	local t = {
	}
	g_NetCtrl:Send("jjc", "C2GSJJCGetFightLog", t)
end

function C2GSJJCBuyFightTimes()
	local t = {
	}
	g_NetCtrl:Send("jjc", "C2GSJJCBuyFightTimes", t)
end

function C2GSJJCClearCD()
	local t = {
	}
	g_NetCtrl:Send("jjc", "C2GSJJCClearCD", t)
end

function C2GSOpenChallengeUI()
	local t = {
	}
	g_NetCtrl:Send("jjc", "C2GSOpenChallengeUI", t)
end

function C2GSChooseChallenge(idx)
	local t = {
		idx = idx,
	}
	g_NetCtrl:Send("jjc", "C2GSChooseChallenge", t)
end

function C2GSSetChallengeFormation(formation)
	local t = {
		formation = formation,
	}
	g_NetCtrl:Send("jjc", "C2GSSetChallengeFormation", t)
end

function C2GSSetChallengeSummon(summonid)
	local t = {
		summonid = summonid,
	}
	g_NetCtrl:Send("jjc", "C2GSSetChallengeSummon", t)
end

function C2GSSetChallengeFighter(fighters)
	local t = {
		fighters = fighters,
	}
	g_NetCtrl:Send("jjc", "C2GSSetChallengeFighter", t)
end

function C2GSResetChallengeTarget()
	local t = {
	}
	g_NetCtrl:Send("jjc", "C2GSResetChallengeTarget", t)
end

function C2GSStartChallenge(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("jjc", "C2GSStartChallenge", t)
end

function C2GSGetChallengeReward()
	local t = {
	}
	g_NetCtrl:Send("jjc", "C2GSGetChallengeReward", t)
end

function C2GSChallengeTargetLineup(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("jjc", "C2GSChallengeTargetLineup", t)
end

function C2GSReceiveFirstGift()
	local t = {
	}
	g_NetCtrl:Send("jjc", "C2GSReceiveFirstGift", t)
end

function C2GSRefreshJJCTarget()
	local t = {
	}
	g_NetCtrl:Send("jjc", "C2GSRefreshJJCTarget", t)
end


module(..., package.seeall)

--GS2C--

function GS2CPlayerRideInfo(pbdata)
	local info = pbdata.info
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(info,"horse")
	g_HorseCtrl:GS2CPlayerRideInfo(dDecode)
end

function GS2CAddRide(pbdata)
	local ride_info = pbdata.ride_info
	--todo
	g_HorseCtrl:GS2CAddRide(ride_info)
end

function GS2CDeleteRide(pbdata)
	local ride_id = pbdata.ride_id
	--todo
end

function GS2CUpdateRide(pbdata)
	local ride_info = pbdata.ride_info
	--todo
	g_HorseCtrl:GS2CUpdateRide(ride_info)
end

function GS2CUpdateUseRide(pbdata)
	local ride_id = pbdata.ride_id
	--todo
end

function GS2CShowRandomSkill(pbdata)
	local skill = pbdata.skill
	--todo
	g_HorseCtrl:GS2CShowRandomSkill(skill)
end

function GS2CResetSKillInfo(pbdata)
	local cost_exp = pbdata.cost_exp
	local grade = pbdata.grade
	local point = pbdata.point
	--todo
	g_HorseCtrl:GS2CResetSKillInfo(pbdata)
end


--C2GS--

function C2GSActivateRide(ride_id)
	local t = {
		ride_id = ride_id,
	}
	g_NetCtrl:Send("ride", "C2GSActivateRide", t)
end

function C2GSUseRide(ride_id, flag)
	local t = {
		ride_id = ride_id,
		flag = flag,
	}
	g_NetCtrl:Send("ride", "C2GSUseRide", t)
end

function C2GSUpGradeRide(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("ride", "C2GSUpGradeRide", t)
end

function C2GSBuyRideUseTime(sell_id)
	local t = {
		sell_id = sell_id,
	}
	g_NetCtrl:Send("ride", "C2GSBuyRideUseTime", t)
end

function C2GSRandomRideSkill(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("ride", "C2GSRandomRideSkill", t)
end

function C2GSShowRandomSkill()
	local t = {
	}
	g_NetCtrl:Send("ride", "C2GSShowRandomSkill", t)
end

function C2GSLearnRideSkill(skill_id)
	local t = {
		skill_id = skill_id,
	}
	g_NetCtrl:Send("ride", "C2GSLearnRideSkill", t)
end

function C2GSForgetRideSkill(skill_id, flag)
	local t = {
		skill_id = skill_id,
		flag = flag,
	}
	g_NetCtrl:Send("ride", "C2GSForgetRideSkill", t)
end

function C2GSSetRideFly(ride_id, fly)
	local t = {
		ride_id = ride_id,
		fly = fly,
	}
	g_NetCtrl:Send("ride", "C2GSSetRideFly", t)
end

function C2GSGetRideInfo()
	local t = {
	}
	g_NetCtrl:Send("ride", "C2GSGetRideInfo", t)
end

function C2GSResetSkillInfo()
	local t = {
	}
	g_NetCtrl:Send("ride", "C2GSResetSkillInfo", t)
end

function C2GSResetRideSkill()
	local t = {
	}
	g_NetCtrl:Send("ride", "C2GSResetRideSkill", t)
end

function C2GSBreakRideGrade(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("ride", "C2GSBreakRideGrade", t)
end

function C2GSWieldWenShi(rideid, itemid, pos)
	local t = {
		rideid = rideid,
		itemid = itemid,
		pos = pos,
	}
	g_NetCtrl:Send("ride", "C2GSWieldWenShi", t)
end

function C2GSUnWieldWenShi(rideid, pos)
	local t = {
		rideid = rideid,
		pos = pos,
	}
	g_NetCtrl:Send("ride", "C2GSUnWieldWenShi", t)
end

function C2GSControlSummon(rideid, summonid, pos)
	local t = {
		rideid = rideid,
		summonid = summonid,
		pos = pos,
	}
	g_NetCtrl:Send("ride", "C2GSControlSummon", t)
end

function C2GSUnControlSummon(rideid, pos)
	local t = {
		rideid = rideid,
		pos = pos,
	}
	g_NetCtrl:Send("ride", "C2GSUnControlSummon", t)
end


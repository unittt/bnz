module(..., package.seeall)

--GS2C--

function GS2CTestNet(pbdata)
	local a = pbdata.a
	local b = pbdata.b
	local c = pbdata.c
	local d = pbdata.d
	local e = pbdata.e
	local f = pbdata.f
	local g = pbdata.g
	local h = pbdata.h
	--todo
end

function GS2CTestBigPacket(pbdata)
	local s = pbdata.s
	--todo
end

function GS2CTestOnlineUpdate(pbdata)
	local a = pbdata.a
	local b = pbdata.b
	local c = pbdata.c
	--todo
end

function GS2CTestOnlineAdd(pbdata)
	local a = pbdata.a
	--todo
end

function GS2CTestEncode(pbdata)
	local a = pbdata.a
	local b = pbdata.b
	--todo
end


--C2GS--

function C2GSTestWar(count, level, active_skills, phy_attack, mag_attack, phy_defense, mag_defense, speed, crit_rate, dodge_rate, hp, mp, monster_id, passive_skills, fmt_id, fmt_grade, weather, sky_war, bosswar_type, aitype, shape)
	local t = {
		count = count,
		level = level,
		active_skills = active_skills,
		phy_attack = phy_attack,
		mag_attack = mag_attack,
		phy_defense = phy_defense,
		mag_defense = mag_defense,
		speed = speed,
		crit_rate = crit_rate,
		dodge_rate = dodge_rate,
		hp = hp,
		mp = mp,
		monster_id = monster_id,
		passive_skills = passive_skills,
		fmt_id = fmt_id,
		fmt_grade = fmt_grade,
		weather = weather,
		sky_war = sky_war,
		bosswar_type = bosswar_type,
		aitype = aitype,
		shape = shape,
	}
	g_NetCtrl:Send("test", "C2GSTestWar", t)
end

function C2GSTestProto(mask, a, b, c)
	local t = {
		mask = mask,
		a = a,
		b = b,
		c = c,
	}
	g_NetCtrl:Send("test", "C2GSTestProto", t)
end

function C2GSTestBigPacket(s)
	local t = {
		s = s,
	}
	g_NetCtrl:Send("test", "C2GSTestBigPacket", t)
end

function C2GSTestCopy(a1, a2, a3)
	local t = {
		a1 = a1,
		a2 = a2,
		a3 = a3,
	}
	g_NetCtrl:Send("test", "C2GSTestCopy", t)
end

function C2GSTestOnlineUpdate(a, b)
	local t = {
		a = a,
		b = b,
	}
	g_NetCtrl:Send("test", "C2GSTestOnlineUpdate", t)
end


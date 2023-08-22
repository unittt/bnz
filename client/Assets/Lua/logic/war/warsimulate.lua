module(..., package.seeall)
local war_id=1
local war_pid=1
local meleeMagic = {1101,1102,1104,1105,1106,1107,1601,1602,1603,1604,1606,1607,7301,7302,7303,8301,8302,8303,8101,8102,8103,8104,8201,8202,8203,101}


-- [[
function FirstSpecityWar()
	-- 步骤重置
	g_WarCtrl.m_FirstSpecityWarStep = 0

	war_pid = g_AttrCtrl.pid
	-- 进入战斗
	netwar.GS2CShowWar({war_id=war_id, war_type="Guide1", is_bosswar = 1, sky_war=0, weather=2, map_id=g_MapCtrl.m_MapID, x=g_MapCtrl.m_MapInitPos.x, y=g_MapCtrl.m_MapInitPos.y})
	g_WarCtrl.m_IsFirstSpecityWar = true
	-- 阵法
	netwar.GS2CWarCampFmtInfo({war_id=war_id, fmt_id1=4, fmt_id2=8, fmt_grade1=5, fmt_grade2=5})
	-- 加人
	AddWarriors()

	-- 回合开始
	local boutStart = {
		war_id = war_id,
		bout_id = 1,
		left_time = 30,
	}
	netwar.GS2CWarBoutStart(boutStart)
	local function delay()
		Bout0()
		if g_GuideHelpCtrl:IsNoGuide() then
			Bout1()
			Bout2()
			Bout3()
		end
		return false
	end
	Utils.AddTimer(delay, 1, 1)
end

function AddWarriors()
	-- 己方========================================================================
	-- 主角
	-- 获得全技能
	local pflist = {{pf_id = 1101,}}--,{pf_id = 1102,},{pf_id = 1103,},{pf_id = 1104,},{pf_id = 1105,},{pf_id = 1106,},{pf_id = 1107,},}
	if g_AttrCtrl.school and g_AttrCtrl.school > 0 then
		pflist = {}
		local skillList = g_SkillCtrl:GetSchoolSkillList(g_AttrCtrl.school)
		for _,v in pairs(skillList) do
			for k,_ in pairs(v.magics) do
				table.insert(pflist, {pf_id = k})
				break
			end
			if next(pflist) then
				break
			end
		end
	end

	local hero = {
		camp_id = 1,
		type = 1,
		war_id = war_id,
		warrior = {
			wid = 1,
			pid = war_pid,
			pos = 1,
			appoint = 1,
			pflist = pflist,
			status = {
				mask = "7fff",
				auto_perform = pflist[1] and pflist[1].pf_id,
				name = g_AttrCtrl.name or "我",
				hp = 12000,
				max_hp = 12000,
				mp = 200,
				max_mp = 200,
				sp = 30,
				max_sp = 150,
				status = 1,
				model_info = {
					figure = g_AttrCtrl.model_info.figure or 1110,
					shape = g_AttrCtrl.model_info.shape or 1110,
					weapon = g_AttrCtrl.model_info.weapon or 21006,
				},
			},
		}
	}
	netwar.GS2CWarAddWarrior(hero)
	-- 进入战斗
	local warEnter = {war_id = war_id, wid = 1}
	netwar.GS2CPlayerWarriorEnter(warEnter)

	local allyInfo = {
		{name = "许仙三魂", figure = 21011},
		{name = "许仙七魄", figure = 21012},
	}

	for i,v in ipairs(allyInfo) do
		local color = ModelTools.GetModelConfig(v.figure).color
		local ally = {
			camp_id = 1,
			type = 4,
			war_id = war_id,
			partnerwarrior = {
				wid = i+1,
				pid = i+war_pid,
				pos = i+1,
				pflist = {
					[1] = {pf_id = 7501},
					[2] = {pf_id = 7502},
				},
				status = {
					mask = "17e",
					hp = 12000,
					max_hp = 12000,
					mp = 200,
					max_mp = 200,
					name = v.name,
					status = 1,
					model_info = {
						figure = v.figure,
						ranse_clothes = color and color[1] or 0,
						ranse_hair = color and color[2] or 0,
						ranse_pant = color and color[3] or 0,
					},
				},
			},
		}
		netwar.GS2CWarAddWarrior(ally)
	end


	-- 敌方========================================================================
	local boss = {
		camp_id = 2,
		type = 2,
		war_id = war_id,
		npcwarrior = {
			pid = 16+war_pid,
			pos = 1,
			status = {
				mask = "7fff",
				name = "九幽魔帝",
				hp = 14000,
				max_hp = 14000,
				mp = 500,
				max_mp = 500,
				status = 1,
				model_info = {
					figure = 6101,
					shape = 6101,
				},
			},
			wid = 16,
		},
	}
	netwar.GS2CWarAddWarrior(boss)

	-- local enemyInfo = {
	-- 	{name = "魔兵", figure = 5103},
	-- }
	-- for i,v in ipairs(enemyInfo) do
	-- 	local soldier = {
	-- 		camp_id = 2,
	-- 		type = 2,
	-- 		war_id = war_id,
	-- 		npcwarrior = {
	-- 			pid = 16+i+war_pid,
	-- 			pos = 1+i*2,
	-- 			status = {
	-- 				mask = "7fff",
	-- 				name = v.name,
	-- 				hp = 6000,
	-- 				max_hp = 6000,
	-- 				mp = 300,
	-- 				max_mp = 300,
	-- 				status = 1,
	-- 				model_info = {
	-- 					figure = v.figure,
	-- 					shape = v.figure,
	-- 					weapon = 1,
	-- 				},
	-- 			},
	-- 			wid = 16+i,
	-- 		},
	-- 	}
	-- 	netwar.GS2CWarAddWarrior(soldier)
	-- end
end

-- 回合1
function Bout0()
	-- 泡泡
	local paopao1 = {
		war_id=war_id,
		wid=16,
		content="七魄被打散，只会失去七情六欲，不会死。"
	}
	GS2CWarPaopao(paopao1)
	local paopao2 = {
		war_id=war_id,
		wid=2,
		content="那也不行啊，没有七情六欲岂不是跟木头人一样？"
	}
	GS2CWarPaopao(paopao2)
	local paopao3 = {
		war_id=war_id,
		wid=16,
		content="本座是在陈述事实，不是跟你讨价还价！"
	}
	GS2CWarPaopao(paopao3)


	-- 回合结束
	local boutEnd = {war_id=war_id}
	netwar.GS2CWarBoutEnd(boutEnd)
	-- 回合开始
	local boutStart = {
		war_id = war_id,
		bout_id = 1,
		left_time = 30,
	}
	netwar.GS2CWarBoutStart(boutStart)
end

function Bout1()
	-- boss
	-- 技能攻击
	local skillID = 101
	local bossMagic = {action_wlist={16}, select_wlist={1}, skill_id=skillID, magic_id=1, war_id=war_id}
	netwar.GS2CWarSkill(bossMagic)

	-- 受击
	local allyDamageList = {-4000}
	for i,v in ipairs(allyDamageList) do
		local damage = {war_id = war_id, wid=i, type=0, damage=v, iscrit=1}
		netwar.GS2CWarDamage(damage)
	end

	-- 状态
	local allyStatusList = {8000}
	for i,v in ipairs(allyStatusList) do
		local status = {war_id=war_id,type=2,wid=i,status={mask="1002",hp=v,sp=45}}
		netwar.GS2CWarWarriorStatus(status)
	end

	-- Goback
	if table.index(meleeMagic, skillID) then
		netwar.GS2CWarGoback({war_id = war_id, action_wid = 16})
	end

	-- 小怪技能
	-- 技能攻击
	-- local enemyMagic = {action_wlist={17}, select_wlist={2}, skill_id=101, magic_id=1, war_id=war_id}
	-- netwar.GS2CWarSkill(enemyMagic)

	-- -- 受击
	-- local damage = {war_id = war_id, wid=2, type=0, damage=-986, iscrit=1}
	-- netwar.GS2CWarDamage(damage)

	-- -- 状态
	-- local status = {war_id=war_id,type=2,wid=2,status={mask="1002",hp=11014,sp=45}}
	-- netwar.GS2CWarWarriorStatus(status)

	-- -- Goback
	-- if table.index(meleeMagic, skillID) then
	-- 	netwar.GS2CWarGoback({war_id = war_id, action_wid = 17})
	-- end


	-- 许仙三魂攻击
	skillID = 1301
	local partner1Magic = {war_id=war_id, action_wlist={2}, select_wlist={16}, skill_id=skillID, magic_id=1}
	netwar.GS2CWarSkill(partner1Magic)

	-- 受击
	local enemyDamageList = {-2233}--, -1056}
	for i,v in ipairs(enemyDamageList) do
		local damage = {war_id = war_id, wid=15+i, type=0, damage=v, iscrit=1}
		netwar.GS2CWarDamage(damage)
	end

	-- 状态
	local enemyStatusList = {11767}--, 7944}
	for i,v in ipairs(enemyStatusList) do
		local status = {war_id=war_id,type=2,wid=15+i,status={hp=v,mask="2"}}
		netwar.GS2CWarWarriorStatus(status)
	end

	-- Goback
	if table.index(meleeMagic, skillID) then
		netwar.GS2CWarGoback({war_id = war_id, action_wid = 1})
	end


	-- 许仙七魂攻击
	skillID = 1306
	local partner1Magic = {war_id=war_id, action_wlist={3}, select_wlist={16}, skill_id=skillID, magic_id=1}
	netwar.GS2CWarSkill(partner1Magic)

	-- 受击
	local enemyDamageList = {-3346}--, -1288}
	for i,v in ipairs(enemyDamageList) do
		local damage = {war_id = war_id, wid=15+i, type=0, damage=v, iscrit=1}
		netwar.GS2CWarDamage(damage)
	end

	-- 状态
	local enemyStatusList = {8421}--, 6656}
	for i,v in ipairs(enemyStatusList) do
		local status = {war_id=war_id,type=2,wid=15+i,status={hp=v,mask="2"}}
		netwar.GS2CWarWarriorStatus(status)
	end

	-- Goback
	if table.index(meleeMagic, skillID) then
		netwar.GS2CWarGoback({war_id = war_id, action_wid = 1})
	end


	-- 主角
	-- 技能攻击(选择第一个技能释放)
	skillID = g_WarCtrl:GetHeroMagicList()[1]
	local heroMagic = {war_id=war_id, action_wlist={1}, select_wlist={16}, skill_id=skillID, magic_id=1}
	netwar.GS2CWarSkill(heroMagic)

	-- 受击
	local enemyDamageList = {-348}--, -366}
	for i,v in ipairs(enemyDamageList) do
		local damage = {war_id = war_id, wid=15+i, type=0, damage=v, iscrit=1}
		netwar.GS2CWarDamage(damage)
	end

	-- 状态
	local enemyStatusList = {8073}--, 6290}
	for i,v in ipairs(enemyStatusList) do
		local status = {war_id=war_id,type=2,wid=15+i,status={hp=v,mask="2"}}
		netwar.GS2CWarWarriorStatus(status)
	end

	-- Goback
	if table.index(meleeMagic, skillID) then
		netwar.GS2CWarGoback({war_id = war_id, action_wid = 1})
	end



	-- 回合结束
	local boutEnd = {war_id=war_id}
	netwar.GS2CWarBoutEnd(boutEnd)

	-- 回合开始
	local boutStart = {
		war_id = war_id,
		bout_id = 2,
		left_time = 30,
	}
	netwar.GS2CWarBoutStart(boutStart)
end

-- 回合2
function Bout2()
	-- boss
	-- 技能攻击
	local skillID = 3015
	local bossMagic = {action_wlist={16}, select_wlist={1,2,3}, skill_id=skillID, magic_id=1, war_id=war_id}
	netwar.GS2CWarSkill(bossMagic)

	-- 受击
	local allyDamageList = {-2422, -5682, -8462}
	for i,v in ipairs(allyDamageList) do
		local damage = {war_id = war_id, wid=i, type=0, damage=v, iscrit=1}
		netwar.GS2CWarDamage(damage)
	end

	-- 状态
	local allyStatusList = {5578, 6318, 3538}
	for i,v in ipairs(allyStatusList) do
		local status = {war_id=war_id,type=2,wid=i,status={hp=v,mask="1002",sp=60}}
		netwar.GS2CWarWarriorStatus(status)
	end

	-- Goback
	if table.index(meleeMagic, skillID) then
		netwar.GS2CWarGoback({war_id = war_id, action_wid = 16})
	end

	-- 小怪技能
	-- 技能攻击
	-- skillID = 101
	-- local enemyMagic = {action_wlist={17}, select_wlist={3}, skill_id=101, magic_id=1, war_id=war_id}
	-- netwar.GS2CWarSkill(enemyMagic)

	-- -- 受击
	-- local damage = {war_id = war_id, wid=2, type=0, damage=-856, iscrit=1}
	-- netwar.GS2CWarDamage(damage)

	-- -- 状态
	-- local status = {war_id=war_id,type=2,wid=2,status={mask="1002",hp=9280,sp=45}}
	-- netwar.GS2CWarWarriorStatus(status)

	-- -- Goback
	-- if table.index(meleeMagic, skillID) then
	-- 	netwar.GS2CWarGoback({war_id = war_id, action_wid = 17})
	-- end




	-- 许仙三魂攻击
	skillID = 1303
	local partner1Magic = {war_id=war_id, action_wlist={2}, select_wlist={16}, skill_id=skillID, magic_id=1}
	netwar.GS2CWarSkill(partner1Magic)

	-- 受击
	local enemyDamageList = {-3482}--, -1415}
	for i,v in ipairs(enemyDamageList) do
		local damage = {war_id = war_id, wid=15+i, type=0, damage=v, iscrit=1}
		netwar.GS2CWarDamage(damage)
	end

	-- 状态
	local enemyStatusList = {4591}--, 4875}
	for i,v in ipairs(enemyStatusList) do
		local status = {war_id=war_id,type=2,wid=15+i,status={hp=v,mask="2"}}
		netwar.GS2CWarWarriorStatus(status)
	end

	-- Goback
	if table.index(meleeMagic, skillID) then
		netwar.GS2CWarGoback({war_id = war_id, action_wid = 1})
	end


	-- 许仙七魂攻击
	skillID = 1306
	local partner1Magic = {war_id=war_id, action_wlist={3}, select_wlist={16}, skill_id=skillID, magic_id=1}
	netwar.GS2CWarSkill(partner1Magic)

	-- 受击
	local enemyDamageList = {-3122}--, -1499}
	for i,v in ipairs(enemyDamageList) do
		local damage = {war_id = war_id, wid=15+i, type=0, damage=v, iscrit=1}
		netwar.GS2CWarDamage(damage)
	end

	-- 状态
	local enemyStatusList = {1406}--, 3376}
	for i,v in ipairs(enemyStatusList) do
		local status = {war_id=war_id,type=2,wid=15+i,status={hp=v,mask="2"}}
		netwar.GS2CWarWarriorStatus(status)
	end

	-- Goback
	if table.index(meleeMagic, skillID) then
		netwar.GS2CWarGoback({war_id = war_id, action_wid = 1})
	end


	-- 主角
	-- 技能攻击
	skillID = g_WarCtrl:GetHeroMagicList()[1]
	local heroMagic = {war_id=war_id, action_wlist={1}, select_wlist={16}, skill_id=skillID, magic_id=1}
	netwar.GS2CWarSkill(heroMagic)

	-- 受击
	local enemyDamageList = {-426}--, -433}
	for i,v in ipairs(enemyDamageList) do
		local damage = {war_id = war_id, wid=15+i, type=0, damage=v, iscrit=1}
		netwar.GS2CWarDamage(damage)
	end

	-- 状态
	local enemyStatusList = {1403}--, 2943}
	for i,v in ipairs(enemyStatusList) do
		local status = {war_id=war_id,type=2,wid=15+i,status={hp=v,mask="2"}}
		netwar.GS2CWarWarriorStatus(status)
	end

	-- Goback
	if table.index(meleeMagic, skillID) then
		netwar.GS2CWarGoback({war_id = war_id, action_wid = 1})
	end


	-- 回合结束
	local boutEnd = {war_id=war_id}
	netwar.GS2CWarBoutEnd(boutEnd)

	-- 回合开始
	local boutStart = {
		war_id = war_id,
		bout_id = 3,
		left_time = 30,
	}
	netwar.GS2CWarBoutStart(boutStart)
end

-- 回合3
function Bout3()

	-- 泡泡
	local paopao1 = {
		war_id=war_id,
		wid=16,
		content="九世好人魂魄力量如此之强，不过该结束了！"
	}
	GS2CWarPaopao(paopao1)

	-- boss
	-- 技能攻击
	skillID = 3016
	local bossMagic = {action_wlist={16}, select_wlist={1,2,3}, skill_id=skillID, magic_id=1, war_id=war_id}
	netwar.GS2CWarSkill(bossMagic)

	-- 受击
	local allyDamageList = {-5570, -6878, -7435}
	for i,v in ipairs(allyDamageList) do
		local damage = {war_id = war_id, wid=i, type=0, damage=v, iscrit=1}
		netwar.GS2CWarDamage(damage)
	end

	-- 状态
	local allyStatusList = {8, 0, 0}
	for i,v in ipairs(allyStatusList) do
		local status = {war_id=war_id,type=2,wid=i,status={hp=v,status=(v>0 and 1 or 2),mask="1FF",sp=75}}
		netwar.GS2CWarWarriorStatus(status)
	end

	-- Goback
	if table.index(meleeMagic, skillID) then
		netwar.GS2CWarGoback({war_id = war_id, action_wid = 1})
	end


	-- 回合结束
	local boutEnd = {war_id=war_id}
	netwar.GS2CWarBoutEnd(boutEnd)

	-- g_WarCtrl:ShowSceneEndWar()
	local oCmd = CWarCmd.New("ShowMaskView")
	g_WarCtrl:InsertCmd(oCmd)
	local oCmd = CWarCmd.New("ShowSceneEndWar")
	g_WarCtrl:InsertCmd(oCmd)
end


-- [=[
function GS2CWarPaopao(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local content = pbdata.content
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("WarPaopao")
	oCmd.wid = wid
	oCmd.content = content
	g_WarCtrl:SetVaryCmd(oCmd)
	g_WarCtrl:InsertCmd(oCmd)
end
-- ]=]

function Test()
	
	-- FloatTest()
	Start(1, 1110, 1)
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=1, buff_id = 106, bout=2, level=1})
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=1, buff_id = 106, bout=4, level=2})
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=1, buff_id = 106, bout=5, level=1})
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=1, buff_id = 106, bout=0, level=0})
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=1, buff_id = 108, bout=1, level=1})
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=1, buff_id = 104, bout=2, level=1})
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=1, buff_id = 107, bout=0, level=0})
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=1, buff_id = 108, bout=0, level=1})
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=1, buff_id = 107, bout=2, level=1})
	-- netwar.GS2CWarDelWarrior({war_id=war_id, wid= 15})
	-- NormalAttackSub(1, 15)
	-- netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 2, left_time=15})
	-- netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	-- AttackSub(1, 15)
	-- AddPartner()
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	-- NormalAttackSub(1, 15)
	-- local t = {war_id = war_id, wid=1, type=1, damage=-999} 
	-- netwar.GS2CWarDamage(t)
	
	-- Speed()
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	-- netwar.GS2CWarFailUI({war_id = war_id})
	-- netwar.GS2CWarWinUI({war_id = war_id, player_exp={}, partner_exp={}, player_item = {}})
	-- g_WarCtrl:ShowSceneEndWar()
	-- local atkid = 1
	-- local vicid = 15
	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701 ,magic_id = 1}
	-- netwar.GS2CWarSkill(t)
	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
	-- netwar.GS2CWarDamage(t)

	-- local atkid = 15
	-- local vicid = 1
	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
	-- netwar.GS2CWarSkill(t)
	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-9} 
	-- netwar.GS2CWarDamage(t)

	-- local atkid = 15
	-- local vicid = 1
	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
	-- netwar.GS2CWarSkill(t)
	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-9} 
	-- netwar.GS2CWarDamage(t)

	-- local t = {war_id = war_id, action_wlist={1}, select_wlist={1,2},skill_id=40102 ,magic_id = 1}
	-- netwar.GS2CWarSkill(t)
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=1, buff_id = 1001, bout=2, level=1})
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=2, buff_id = 1001, bout=2, level=1})
	-- netwar.GS2CWarBoutEnd({war_id = war_id})
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=1})
	local k = 1
	local function delay()
		local atkid = 1
		local vicid = 15
		local t = {action_wid = atkid, select_wid = vicid, war_id = war_id}
		netwar.GS2CWarNormalAttack(t)
		local t = {war_id = war_id, wid=vicid, type=0, damage=-81} 
		netwar.GS2CWarDamage(t)
		local t = {war_id = war_id, action_wid=atkid}
		netwar.GS2CWarGoback(t)

		local t = {action_wid = vicid, select_wid = atkid, war_id = war_id}
		netwar.GS2CWarNormalAttack(t)
		local t = {war_id = war_id, wid=atkid, type=0, damage=-17} 
		netwar.GS2CWarDamage(t)

		local t = {war_id = war_id, action_wid=vicid}
		netwar.GS2CWarGoback(t)

		--[==[
		local atkid = 1
		local vicid = 15
		local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1110 ,magic_id = 1}
		netwar.GS2CWarSkill(t)
		local t = {war_id = war_id, wid=vicid, type=1, damage=-1999} 
		netwar.GS2CWarDamage(t)
		local t = {war_id = war_id, wid=vicid, type=1, damage=-1988} 
		netwar.GS2CWarDamage(t)
		local t = {war_id = war_id, wid=vicid, type=1, damage=-1987} 
		netwar.GS2CWarDamage(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1997} 
		-- netwar.GS2CWarDamage(t)

		netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})

		local atkid = 15
		local vicid = 1
		local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1, magic_id = 1}
		netwar.GS2CWarSkill(t)
		local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
		netwar.GS2CWarDamage(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
		-- netwar.GS2CWarDamage(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
		-- netwar.GS2CWarDamage(t)
		netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		]==]--


		-- local atkid = 17
		-- local vicid = 1
		-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701, magic_id = 1}
		-- netwar.GS2CWarSkill(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
		-- netwar.GS2CWarDamage(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
		-- netwar.GS2CWarDamage(t)
		-- -- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
		-- -- netwar.GS2CWarDamage(t)
		-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})


		-- local atkid = 18
		-- local vicid = 1
		-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701, magic_id = 1}
		-- netwar.GS2CWarSkill(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
		-- netwar.GS2CWarDamage(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
		-- netwar.GS2CWarDamage(t)
		-- -- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
		-- -- netwar.GS2CWarDamage(t)
		-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})

		-- local atkid = 1
		-- local vicid = 15
		-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=3301 ,magic_id = 1}
		-- netwar.GS2CWarSkill(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1999} 
		-- netwar.GS2CWarDamage(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1988} 
		-- netwar.GS2CWarDamage(t)
		-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		
		
		-- local atkid = 2
		-- local vicid = 15
		-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
		-- netwar.GS2CWarSkill(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
		-- netwar.GS2CWarDamage(t)

		-- local atkid = 2
		-- local vicid = 15
		-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
		-- netwar.GS2CWarSkill(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
		-- netwar.GS2CWarDamage(t)

		-- local atkid = 2
		-- local vicid = 15
		-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
		-- netwar.GS2CWarSkill(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
		-- netwar.GS2CWarDamage(t)

		
		-- local atkid = 15
		-- local vicid = 2
		-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
		-- netwar.GS2CWarSkill(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-111} 
		-- netwar.GS2CWarDamage(t)

		-- netwar.GS2CWarGoback({war_id = war_id, action_wid=2})

		-- local atkid = 3
		-- local vicid = 16
		-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701 ,magic_id = 1}
		-- netwar.GS2CWarSkill(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-9}
		-- netwar.GS2CWarDamage(t)
		-- -- netwar.GS2CWarFloat({war_id=war_id,float_info={victim_id=vicid, attack_id=atkid}})
		-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		
		-- local atkid = 4
		-- local vicid = 15
		-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701 ,magic_id = 1}
		-- netwar.GS2CWarSkill(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-9} 
		-- netwar.GS2CWarDamage(t)
		-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		-- netwar.GS2CWarFloat({war_id=war_id,float_info={{victim_id=1, 
		-- 	attack_list={
		-- 	{attack_id=15, attack_cnt=2}, 
		-- 	{attack_id=16, attack_cnt=2}, 
		-- 	{attack_id=17, attack_cnt=2},
		-- 	{attack_id=18, attack_cnt=2},  
		-- 	}}}})

		
		netwar.GS2CWarBoutEnd({war_id = war_id})
		-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
		k = k + 1
		if k > 5 then
			return false
		end
		return true
	end
	Utils.AddTimer(delay, 1, 1)
end

function Speed()
	local t = {
		{wid = 2, speed =1000},
		{wid = 1, speed = 998},
		{wid = 3, speed = 999}
	}
	netwar.GS2CWarSpeed({war_id=war_id, speed_list=t})
end

function FloatTest(sk1, sk2)
	CWarBuff.ctor = function() end
	local function delay()
		local atkid = 1
		local vicid = 15
		local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=sk1 ,magic_id = 1}
		netwar.GS2CWarSkill(t)
		local t = {war_id = war_id, wid=vicid, type=1, damage=-1999} 
		netwar.GS2CWarDamage(t)
		netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})

		local atkid = 2
		local vicid = 15
		local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=sk2 ,magic_id = 1}
		netwar.GS2CWarSkill(t)
		local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
		netwar.GS2CWarDamage(t)
		netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})

		local atkid = 3
		local vicid = 15
		local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=sk2 ,magic_id = 1}
		netwar.GS2CWarSkill(t)
		local t = {war_id = war_id, wid=vicid, type=1, damage=-9}
		netwar.GS2CWarDamage(t)
		-- netwar.GS2CWarFloat({war_id=war_id,float_info={victim_id=vicid, attack_id=atkid}})
		netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		
		-- local atkid = 4
		-- local vicid = 15
		-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701 ,magic_id = 1}
		-- netwar.GS2CWarSkill(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-9} 
		-- netwar.GS2CWarDamage(t)
		-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		
		-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1, left_time=30})
		-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	end
	-- Utils.AddTimer(delay, 0, 0)
	delay()
end

function Start(cnt, palyershape, weapon, wartype)
	wartype = wartype or 1
	g_AttrCtrl:UpdateAttr({pid=1})
	netwar.GS2CShowWar({war_id = war_id, war_type=wartype, map_id=302000, x=5000, y=8000})
	cnt = tonumber(cnt) or 1
	for i=1, cnt do
		local t = {war_id = war_id, camp_id=1, type=1,warrior={pflist = {[1] = {pf_id = 3201},[2] = {pf_id = 3202}}, wid = i, pid=i, pos = i, status={mask="7fff",auto_skill=nil,name=tostring("A"..i), status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=palyershape, weapon= weapon}},}}
		netwar.GS2CWarAddWarrior(t)
		local t = {war_id = war_id, camp_id=2, type=1,warrior={pflist = {[1] = {pf_id = 3201},[2] = {pf_id = 3202}}, wid = 15+i, pid=15+i, pos = i, status={mask="7fff",auto_skill=3201, name=tostring("B"..i), status=1,mp=30, max_mp=30,hp=6000, max_hp=7000, model_info={shape=palyershape, weapon= weapon}},}}
		netwar.GS2CWarAddWarrior(t)
	end
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
end

function AddPartner()
	-- local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3001}, wid = 2, name="test", parid=9000, pos = 5, owner=1, status={auto_skill=50701,status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=301}}, }}
	-- netwar.GS2CWarAddWarrior(t)
	local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {[1] = {pf_id = 40402},[2] = {pf_id = 40402}}, wid = 4, name="test", parid=9001, pos = 2, owner=1, status={auto_skill=50702, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
	netwar.GS2CWarAddWarrior(t)
	local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {[1] = {pf_id = 3201},[2] = {pf_id = 3202}}, wid = 5, name="test", parid=9002, pos = 5, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
	netwar.GS2CWarAddWarrior(t)
end

function NormalAttack(atkid, vicid)
	netwar.GS2CWarAction({war_id=war_id, wid= atkid})
	local t = {war_id = war_id, action_wid=atkid, select_wid=vicid}
	netwar.GS2CWarNormalAttack(t)
	local t = {war_id = war_id, wid=vicid, type=0, damage=-1000 } 
	netwar.GS2CWarDamage(t)
	local t = {war_id = war_id, wid=vicid, type = 1, status={hp=5000, mp = 30}}
	netwar.GS2CWarWarriorStatus(t)

	local t = {war_id = war_id, action_wid=vicid, select_wid=atkid}
	netwar.GS2CWarNormalAttack(t)
	local t = {war_id = war_id, wid=atkid, type=0, damage=-1000 } 
	netwar.GS2CWarDamage(t)
	local t = {war_id = war_id, wid=atkid, type = 1, status={hp=1000,mp = 20}}
	netwar.GS2CWarWarriorStatus(t)
	netwar.GS2CWarGoback({war_id = war_id, action_wid=vicid})
	netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
	netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
end

function AttackSub(atkid, vicid)
	local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid}, skill_id=1,magic_id = 1}
	netwar.GS2CWarSkill(t)
	local t = {war_id = war_id, wid=vicid, type=1, status={hp=0}}
	netwar.GS2CWarWarriorStatus(t)
	local t = {war_id = war_id, wid=vicid, type=1, status={status=2}}
	netwar.GS2CWarWarriorStatus(t)
	local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
	netwar.GS2CWarDamage(t)

	-- netwar.GS2CWarSP({war_id=war_id, camp_id=1, sp =50})
	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
	-- netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
end

function Magic(magic_id, shape, magic_index, atk_list, vic_List, sSubType)
	if sSubType == "one" then
		for i, id in ipairs(vic_List) do
			local magic_index = magic_index
			local atk = atk_list
			local t = {war_id = war_id, action_wlist=atk, select_wlist={id},skill_id=magic_id ,magic_id = magic_index}
			netwar.GS2CWarSkill(t)
			local t = {war_id = war_id, wid=id, type=0, damage=-2000-i} 
			netwar.GS2CWarDamage(t)
			local t = {war_id = war_id, wid=id, status={hp=8000, max_hp=10000}}
			netwar.GS2CWarWarriorStatus(t)
		end
	elseif sSubType == "all" then
		local t = {war_id = war_id, action_wlist=atk_list, select_wlist=vic_List, skill_id=magic_id,magic_id = magic_index}
		netwar.GS2CWarSkill(t)
		for i, id in ipairs(vic_List) do
			local t = {war_id = war_id, wid=id, type=0, damage=-9999} 
			netwar.GS2CWarDamage(t)
			local t = {war_id = war_id, wid=id, status={hp=8000, max_hp=10000}}
			netwar.GS2CWarWarriorStatus(t)
		end
	elseif sSubType == "chain" then
		local pre_vic = nil
		for i, id in ipairs(vic_List) do
			local magic_index = (i ~= 1) and 2 or 1
			local atk
			if pre_vic then
				atk = {pre_vic}
			else
				atk = atk_list
			end
			local t = {war_id = war_id, action_wlist=atk, select_wlist={id},skill_id=magic_id ,magic_id = magic_index}
			netwar.GS2CWarSkill(t)
			local t = {war_id = war_id, wid=id, type=0, damage=-2000-i} 
			netwar.GS2CWarDamage(t)
			local t = {war_id = war_id, wid=id, status={hp=8000, max_hp=10000}}
			netwar.GS2CWarWarriorStatus(t)
			pre_vic = id
		end
	elseif sSubType == "sequence" then
		for i, id in ipairs(vic_List) do
			local magic_index = (i ~= 1) and 2 or 1
			local t = {war_id = war_id, action_wlist=atk_list, select_wlist={id},skill_id=magic_id ,magic_id = magic_index}
			netwar.GS2CWarSkill(t)
			local t = {war_id = war_id, wid=id, type=0, damage=-2000-i} 
			netwar.GS2CWarDamage(t)
			local t = {war_id = war_id, wid=id, status={hp=8000, max_hp=10000}}
			netwar.GS2CWarWarriorStatus(t)
		end
	end
	netwar.GS2CWarGoback({war_id = war_id, action_wid = atk_list[1]})
	netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1})
end

function Escape(action_wid)
	netwar.GS2CWarEscape({war_id = war_id, action_wid=action_wid})
	netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1})
end

module(..., package.seeall)

--GS2C--

function GS2CShowWar(pbdata)
	local war_id = pbdata.war_id
	local war_type = pbdata.war_type
	local sky_war = pbdata.sky_war
	local weather = pbdata.weather
	local is_bosswar = pbdata.is_bosswar
	local tollgate_group = pbdata.tollgate_group --关卡组
	local tollgate_id = pbdata.tollgate_id --关卡id
	local barrage_show = pbdata.barrage_show --弹幕显示 0-不显示 1-显示名字+弹幕 2-显示弹幕
	local barrage_send = pbdata.barrage_send --是否能发弹幕 0-不能 1-能
	local map_id = pbdata.map_id --战斗场景
	local x = pbdata.x --坐标x
	local y = pbdata.y --坐标y
	local sys_type = pbdata.sys_type --系统玩法类型
	--todo

	if g_NetCtrl:IsProtoRocord() then
		g_WarCtrl.m_ViewSide = g_NetCtrl:GetRecordValue("side") or 1
		g_WarCtrl.m_IsPlayRecord = true
		g_WarCtrl.m_IsClientRecord = true
	else
		g_WarCtrl.m_IsClientRecord = false
		if observer_view ~= 0 then
			g_WarCtrl.m_ViewSide = observer_view
		end
		g_WarCtrl.m_IsPlayRecord = war_flim == 1
	end
	if not g_WarCtrl.m_ViewSide and Utils.IsEditor() then
		g_NetCtrl:SetRecordType("war_record")
	end
	g_WarCtrl:Start(pbdata)
	g_MapCtrl:ShowWarScene(map_id, x, y)
	g_CameraCtrl:GetMainCamera():SetClearFlags(2)
end

function GS2CWarResult(pbdata)
	local war_id = pbdata.war_id
	local bout_id = pbdata.bout_id
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	if g_WarCtrl.m_ReciveResultProto then
		return
	end
	g_WarCtrl.m_ReciveResultProto = true
	if g_WarCtrl:IsPlayRecord() then
		return
	end
	-- local oCmd = CWarCmd.New("WarResult")
	--oCmd.win = win_side == g_WarCtrl.m_AllyCmap
	-- oCmd.war_id = war_id
	-- g_WarCtrl:InsertCmd(oCmd)
	-- g_WarCtrl:BoutEnd()
end

function GS2CWarBoutStart(pbdata)
	local war_id = pbdata.war_id
	local bout_id = pbdata.bout_id
	local left_time = pbdata.left_time
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	if g_WarCtrl.m_ReciveResultProto then
		printerror("GS2CWarResult后面不应该有GS2CWarBoutStart, 服务端查下")
		return
	end
	local oCmd = CWarCmd.New("BoutStart")
	oCmd.bout_id = bout_id
	oCmd.left_time = left_time
	g_WarCtrl:SetVaryCmd(nil)
	g_WarCtrl:InsertCmd(oCmd)
	g_WarCtrl.m_ProtoBout = bout_id	
end

function GS2CWarBoutEnd(pbdata)
	local war_id = pbdata.war_id
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	g_WarCtrl:SetVaryCmd(nil)
	-- g_WarCtrl:BoutEnd()
	local oCmd = CWarCmd.New("BoutEnd")
	g_WarCtrl:InsertBountEndCmd(oCmd)
	g_WarCtrl:FinishOrder()
end

function GS2CWarAddWarrior(pbdata)
	local war_id = pbdata.war_id
	local camp_id = pbdata.camp_id
	local type = pbdata.type --1 player,2 npc,3 summon,4 partner,5 roplayer,6 rosummon,7 ropartner
	local warrior = pbdata.warrior
	local npcwarrior = pbdata.npcwarrior
	local sumwarrior = pbdata.sumwarrior
	local partnerwarrior = pbdata.partnerwarrior
	local roplayerwarrior = pbdata.roplayerwarrior
	local ropartnerwarrior = pbdata.ropartnerwarrior
	local rosummonwarrior = pbdata.rosummonwarrior
	local add_type = pbdata.add_type --是否立即执行插入
	local is_summon = pbdata.is_summon --战斗中召唤入场
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end

	-- printc("############### 单位协议", g_TimeCtrl:GetTimeMS(), g_TimeCtrl:GetTimeS())
	local oCmd = CWarCmd.New("AddWarrior")
	oCmd.type = type
	local info = {}
	if type == 1 then
		info = warrior
		g_WarCtrl:SetAutoWar(info.status.is_auto, false)
	elseif type == 2 then
		if npcwarrior.pos > 14 then
			printerror("非法的战斗npc，位置错误 Pos：npcwarrior.pos:", npcwarrior.pos)
			do return end
		end
		info = npcwarrior
	elseif type == 3 then
		info = sumwarrior
	elseif type == 4 then
		info = partnerwarrior
	elseif type == 5 then
		info = roplayerwarrior
	elseif type == 6 then
		info = ropartnerwarrior
	elseif type == 7 then
		info = rosummonwarrior
	end
	if info.status then
		info.status = g_NetCtrl:DecodeMaskData(info.status, "WarriorStatus")
	end
	oCmd.info = table.copy(info)
	oCmd.camp_id = camp_id
	oCmd.is_summon = is_summon

	if type == define.Warrior.Type.Player then
		local iSide = g_WarCtrl:GetViewSide()
		if iSide and iSide == camp_id then
			g_WarCtrl.m_HeroPid = oCmd.info.pid
		end
		if oCmd.info.pid == g_WarCtrl:GetHeroPid() then
			g_WarCtrl.m_AllyCmap = camp_id
			g_WarCtrl.m_HeroWid = oCmd.info.wid
		end
		local bAlly = g_WarCtrl.m_AllyCmap == camp_id
		if bAlly then
			g_WarCtrl.m_AllyPlayerCnt = g_WarCtrl.m_AllyPlayerCnt + 1
		else
			g_WarCtrl.m_EnemyPlayerCnt = g_WarCtrl.m_EnemyPlayerCnt + 1
		end
	end

	-- if add_type == 1 then
	-- 	oCmd:Excute()
	-- 	return
	-- end
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		oVaryCmd:SetVary(oCmd.info.wid, "add_warriorcmd", oCmd)
	else
		g_WarCtrl:InsertCmd(oCmd)
	end
end

function GS2CWarDelWarrior(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local type = pbdata.type
	local war_end = pbdata.war_end
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	-- 结束之后的删除信息剔除
	if war_end == 1 then
		g_WarCtrl.m_ReciveResultProto = true
	end
	if g_WarCtrl.m_ReciveResultProto then
		return
	end
	local oCmd = CWarCmd.New("DelWarrior")
	oCmd.wid = wid
	oCmd.type = type
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		oVaryCmd:SetVary(wid, "del_cmd", oCmd)
	else
		g_WarCtrl:InsertCmd(oCmd)
	end
end

function GS2CWarNormalAttack(pbdata)
	local war_id = pbdata.war_id
	local action_wid = pbdata.action_wid
	local select_wid = pbdata.select_wid
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	g_WarCtrl.m_CurActionWid = action_wid
	local oCmd = CWarCmd.New("Magic")
	oCmd.atkid_list = {action_wid}
	oCmd.vicid_list = {select_wid}
	oCmd.magic_id = 101
	oCmd.magic_index = 1
	g_WarCtrl:AddBoutMagicInfo(action_wid, oCmd.vicid_list, 101, 1, oCmd.m_ID)
	g_WarCtrl:SetVaryCmd(oCmd)
	local oLastCmd = g_WarCtrl:GetLastCmd()
	if oLastCmd and oLastCmd.m_Func == oCmd.m_Func then
		if oLastCmd.atkid_list[1] == action_wid and oLastCmd.vicid_list[1] ~= select_wid then
			oCmd.isPursued = true
		end
	end
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarSkill(pbdata)
	local war_id = pbdata.war_id
	local action_wlist = pbdata.action_wlist
	local select_wlist = pbdata.select_wlist
	local skill_id = pbdata.skill_id
	local magic_id = pbdata.magic_id
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	g_WarCtrl.m_CurActionWid = action_wlist[1]
	local oCmd = CWarCmd.New("Magic")
	oCmd.atkid_list = action_wlist
	oCmd.vicid_list = select_wlist
	--无视服务端的变量名skill_id， magic_id
	--客户端法术只有magic_id， magic_index
	oCmd.magic_id = skill_id
	oCmd.magic_index = magic_id
	g_WarCtrl:AddBoutMagicInfo(action_wlist[1], select_wlist, skill_id, magic_id, oCmd.m_ID)
	g_WarCtrl:SetVaryCmd(oCmd)
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarProtect(pbdata)
	local war_id = pbdata.war_id
	local action_wid = pbdata.action_wid
	local select_wid = pbdata.select_wid
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		oVaryCmd:SetVary(select_wid, "protect_id", action_wid)
	end
end

function GS2CWarEscape(pbdata)
	local war_id = pbdata.war_id
	local action_wid = pbdata.action_wid
	local success = pbdata.success
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("Escape")
	oCmd.action_wid = action_wid
	oCmd.success = success
	g_WarCtrl:SetVaryCmd(nil)
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarDamage(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local type = pbdata.type --1 miss 2 defense
	local iscrit = pbdata.iscrit --1 crit
	local damage = pbdata.damage
	local hited_effect = pbdata.hited_effect --是否表现受击动作
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("WarDamage")
	oCmd.wid = wid
	oCmd.type = type
	oCmd.damage = damage
	oCmd.iscrit = iscrit == 1
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		local damage_list = oVaryCmd:GetVary(wid, "damage_list") or {}
		table.insert(damage_list, oCmd)
		oVaryCmd:SetVary(wid, "damage_list", damage_list)
		-- printc("GS2CWarDamage SetVary", oVaryCmd.m_Func)
		if hited_effect == 1 then
			oVaryCmd:UpdateVictimList(wid)
		end
	else
		g_WarCtrl:InsertCmd(oCmd)
		-- printc("GS2CWarDamage InsertCmd")
	end
end

function GS2CWarWarriorStatus(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local type = pbdata.type
	local status = pbdata.status
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end

	local status = g_NetCtrl:DecodeMaskData(status, "WarriorStatus")

	if g_WarCtrl.g_Print then
		table.print(status, "##### decode GS2CWarWarriorStatus #####")
	end
	if status.cmd and status.cmd == 1 then
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior then
			oWarrior:SetOrderDone(true)
		end
	end

	if type == define.Warrior.Type.Player and g_WarCtrl.m_HeroWid == wid and status.is_auto then
		g_WarCtrl:SetAutoWar(status.is_auto, false)
	end
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		if status.hp or status.max_hp then
			local hp_list = oVaryCmd:GetVary(wid, "hp_list") or {}
			table.insert(hp_list, {hp=status.hp, max_hp=status.max_hp})
			oVaryCmd:SetVary(wid, "hp_list", hp_list)
			status["hp"] = nil
			status["max_hp"] = nil
		end
		for k, v in pairs(status) do
			oVaryCmd:SetVary(wid, k, v)
		end
		-- printc("GS2CWarWarriorStatus SetVary", oVaryCmd.m_Func)
	else
		local oCmd = CWarCmd.New("WarriorStatus")
		oCmd.wid = wid
		oCmd.status = status
		g_WarCtrl:InsertCmd(oCmd)
		-- printc("GS2CWarWarriorStatus")
	end
end

function GS2CWarGoback(pbdata)
	local war_id = pbdata.war_id
	local action_wid = pbdata.action_wid
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("GoBack")
	oCmd.wid_list = {action_wid}
	oCmd.wait = true
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd and not oVaryCmd:IsUsed() and oVaryCmd.atkid_list and table.index(oVaryCmd.atkid_list, action_wid) then
		oVaryCmd:SetVary(action_wid, "go_back", oCmd)
		g_WarCtrl:SetVaryCmd(nil)
	else
		g_WarCtrl:InsertCmd(oCmd)
	end
end

function GS2CWarAddBuff(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local buff_id = pbdata.buff_id
	local bout = pbdata.bout
	local attrlist = pbdata.attrlist
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("Buff")
	oCmd.wid = wid
	oCmd.buff_id = buff_id
	oCmd.bout = bout
	oCmd.level = 1
	oCmd.attrlist = attrlist
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarDelBuff(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local buff_id = pbdata.buff_id
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("Buff")
	oCmd.wid = wid
	oCmd.buff_id = buff_id
	oCmd.bout = 0
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarBuffBout(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local buff_id = pbdata.buff_id
	local bout = pbdata.bout
	local stack = pbdata.stack
	local attrlist = pbdata.attrlist
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("Buff")
	oCmd.wid = wid
	oCmd.buff_id = buff_id
	oCmd.bout = bout
	oCmd.level = 1 -- level
	oCmd.attrlist = attrlist
	oCmd.need_tips = not g_WarCtrl:IsWarStart()
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		local buff_list = oVaryCmd:GetVary(wid, "buff_list") or {}
		table.insert(buff_list, oCmd)
		oVaryCmd:SetVary(wid, "buff_list", buff_list)
	else
		g_WarCtrl:InsertCmd(oCmd)
	end
end

function GS2CWarPasssiveSkill(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local skill_id = pbdata.skill_id
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		local list = oVaryCmd:GetVary(wid, "passive_skill_list") or {}
		table.insert(list, skill_id)
		oVaryCmd:SetVary(wid, "passive_skill_list", list)
	end
end

function GS2CPlayerWarriorEnter(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local sum_list = pbdata.sum_list
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	if wid == g_WarCtrl.m_HeroWid then
		g_WarCtrl:SetFightSummons(sum_list)
	end
end

function GS2CWarriorSpeek(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local content = pbdata.content
	local flag = pbdata.flag --0.perform开始(默认即时生效) 1.受击时 2.perform结束
	local show_type = pbdata.show_type --0 气泡. 1.窗口
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("WarriorSpeek")
	oCmd.wid = wid
	oCmd.content = content
	oCmd.flag = flag
	oCmd.showType = show_type
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		oVaryCmd:SetVary(wid, "speek_cmd", oCmd)
	else
		g_WarCtrl:InsertCmd(oCmd)
	end
end

function GS2CWarriorSeqSpeek(pbdata)
	local war_id = pbdata.war_id
	local speeks = pbdata.speeks
	local block_ms = pbdata.block_ms --阻塞后续喊话、动作等毫秒数
	local block_action = pbdata.block_action --是否(0/1)阻塞后面的行动逻辑（含读秒）
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("WarriorSeqSpeek")
	oCmd.speeks = speeks
	oCmd.block_ms = block_ms * 0.001
	g_WarCtrl:SetVaryCmd(oCmd)
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarCapture(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid --被捕捉的单位
	local succ = pbdata.succ --成功与否0/1
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
end

function GS2CStartObserver(pbdata)
	local pid = pbdata.pid --玩家ID
	local war_id = pbdata.war_id --战斗ID
	local camp_id = pbdata.camp_id --阵营，确定观看方向
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	g_WarCtrl.m_ViewSide = camp_id
end

function GS2CWarCommand(pbdata)
	local war_id = pbdata.war_id --战斗ID
	local op = pbdata.op --1.增加　0.清除
	local lcmd = pbdata.lcmd
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("RefreshAllTeamCmd")
	oCmd.lcmd = lcmd
	oCmd.op = op
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarCommandOP(pbdata)
	local war_id = pbdata.war_id --战斗ID
	local op = pbdata.op --0.清除 1.第一次增加　 2.覆盖增加
	local select_wid = pbdata.select_wid
	local cmd = pbdata.cmd
	--todo
	local oCmd = CWarCmd.New("ShowWarCommond")
	oCmd.wid = select_wid
	oCmd.content = cmd
	oCmd.op = op
	oCmd:Excute()
end

function GS2CUpdateWarCommand(pbdata)
	local war_id = pbdata.war_id --战斗ID
	local appoint = pbdata.appoint --指挥员
	local appointop = pbdata.appointop --1.每回合清除 0.每回合不清除
	--todo
	g_WarCtrl.m_ClearTeamCmd = appointop == 1
	g_WarCtrl.m_AppointId = appoint
end

function GS2CWarUseItem(pbdata)
	local war_id = pbdata.war_id --战斗ID
	local action_wid = pbdata.action_wid
	local select_wid = pbdata.select_wid
	local item_id = pbdata.item_id --物品效果id
	--todo
	-- itemid (1001 1002 1003 1004 1005) 对应描述
	-- 加血 加蓝 捕捉 加怒气 复活
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end

	if item_id == tostring(1007) then 
		g_WarCtrl.m_CurActionWid = action_wid
		local oCmd = CWarCmd.New("Magic")
		oCmd.atkid_list = {action_wid}
		oCmd.vicid_list = {select_wid}
		oCmd.magic_id = 4284
		oCmd.magic_index = 1
		g_WarCtrl:AddBoutMagicInfo(action_wid, oCmd.vicid_list, 101, 1, oCmd.m_ID)
		g_WarCtrl:SetVaryCmd(oCmd)
		g_WarCtrl:InsertCmd(oCmd)

	else
		g_WarCtrl.m_CurActionWid = action_wid
		local oCmd = CWarCmd.New("WarUseItem")
		oCmd.action_wid = action_wid
		oCmd.select_wid = select_wid
		oCmd.item_id = item_id
		g_WarCtrl:SetVaryCmd(oCmd)
		g_WarCtrl:InsertCmd(oCmd)
	end 

end

function GS2CWarStatus(pbdata)
	local war_id = pbdata.war_id --战斗ID
	local bout = pbdata.bout
	local left_time = pbdata.left_time
	--todo
	if g_WarCtrl.m_WarID ~= war_id or g_WarCtrl:IsPlayRecord()then
		return
	end
	g_WarCtrl:WarStatus(bout, left_time)
end

function GS2CWarCampFmtInfo(pbdata)
	local war_id = pbdata.war_id --战斗id
	local fmt_id1 = pbdata.fmt_id1 --阵营1 阵法id
	local fmt_grade1 = pbdata.fmt_grade1 --阵营1 阵法等级
	local fmt_id2 = pbdata.fmt_id2 --阵营2 阵法id
	local fmt_grade2 = pbdata.fmt_grade2 --阵营2 阵法等级
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	g_WarCtrl:RefreshFormation(pbdata)
end

function GS2CTriggerPassiveSkill(pbdata)
	local war_id = pbdata.war_id --战斗ID
	local pfid = pbdata.pfid --招式编号
	local key_list = pbdata.key_list --(magic_id:播放动作id,第一顺位),(select_id:选择目标)
	local wid = pbdata.wid --触发单位
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("TriggerPassiveSkill")
	oCmd.wid = wid
	oCmd.pfid = pfid
	oCmd.key_list = key_list
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		local trigger_passive = oVaryCmd:GetVary(wid, "trigger_passive") or {}
		table.insert(trigger_passive, oCmd)
		oVaryCmd:SetVary(wid, "trigger_passive", trigger_passive)
	else
		g_WarCtrl:InsertCmd(oCmd)
	end
end

function GS2CWarAddMp(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local add_mp = pbdata.add_mp --mp变化值， 可为负数
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("WarAddMp")
	oCmd.wid = wid
	oCmd.add_mp = add_mp
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		local addMp_list = oVaryCmd:GetVary(wid, "addMp_list") or {}
		table.insert(addMp_list, oCmd)
		oVaryCmd:SetVary(wid, "addMp_list", addMp_list)
		-- printc("GS2CWarAddMp SetVary", oVaryCmd.m_Func)
	else
		g_WarCtrl:InsertCmd(oCmd)
		-- printc("GS2CWarAddMp InsertCmd")
	end
end

function GS2CRefreshPerformCD(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local pflist = pbdata.pflist
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("RefreshPerformCD")
	oCmd.wid = wid
	oCmd.pflist = pflist
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarObCount(pbdata)
	local war_id = pbdata.war_id --战斗ID
	local ob_cnt = pbdata.ob_cnt --观战人数
	--todo
	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	g_WarCtrl:GS2CWarObCount(ob_cnt)
end

function GS2CWarFail(pbdata)
	local war_id = pbdata.war_id --战斗ID
	local gameplay = pbdata.gameplay --战斗主题
	--todo
	-- if g_WarCtrl.m_WarID ~= war_id then
	-- 	return
	-- end
	g_PromoteCtrl:GS2CWarFail(gameplay)
end

function GS2CWarDelStatus(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local status_id = pbdata.status_id
	--todo
end

function GS2CWarUpdateStatus(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local status = pbdata.status
	--todo
end


--C2GS--

function C2GSWarSkill(war_id, action_wlist, select_wlist, skill_id)
	local t = {
		war_id = war_id,
		action_wlist = action_wlist,
		select_wlist = select_wlist,
		skill_id = skill_id,
	}
	g_NetCtrl:Send("war", "C2GSWarSkill", t)
end

function C2GSWarNormalAttack(war_id, action_wid, select_wid)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
		select_wid = select_wid,
	}
	g_NetCtrl:Send("war", "C2GSWarNormalAttack", t)
end

function C2GSWarProtect(war_id, action_wid, select_wid)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
		select_wid = select_wid,
	}
	g_NetCtrl:Send("war", "C2GSWarProtect", t)
end

function C2GSWarEscape(war_id, action_wid)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
	}
	g_NetCtrl:Send("war", "C2GSWarEscape", t)
end

function C2GSWarDefense(war_id, action_wid)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
	}
	g_NetCtrl:Send("war", "C2GSWarDefense", t)
end

function C2GSWarSummon(war_id, action_wid, sum_id)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
		sum_id = sum_id,
	}
	g_NetCtrl:Send("war", "C2GSWarSummon", t)
end

function C2GSWarAutoFight(war_id, type, aitype)
	local t = {
		war_id = war_id,
		type = type,
		aitype = aitype,
	}
	g_NetCtrl:Send("war", "C2GSWarAutoFight", t)
end

function C2GSChangeAutoPerform(war_id, wid, auto_perform)
	local t = {
		war_id = war_id,
		wid = wid,
		auto_perform = auto_perform,
	}
	g_NetCtrl:Send("war", "C2GSChangeAutoPerform", t)
end

function C2GSWarUseItem(war_id, action_wid, select_wid, item_id)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
		select_wid = select_wid,
		item_id = item_id,
	}
	g_NetCtrl:Send("war", "C2GSWarUseItem", t)
end

function C2GSWarCommand(war_id, action_wid, select_wid, scmd)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
		select_wid = select_wid,
		scmd = scmd,
	}
	g_NetCtrl:Send("war", "C2GSWarCommand", t)
end

function C2GSWarCommandOP(war_id, action_wid, op)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
		op = op,
	}
	g_NetCtrl:Send("war", "C2GSWarCommandOP", t)
end

function C2GSWarAnimationEnd(war_id, bout_id)
	local t = {
		war_id = war_id,
		bout_id = bout_id,
	}
	g_NetCtrl:Send("war", "C2GSWarAnimationEnd", t)
end

function C2GSReEnterWar()
	local t = {
	}
	g_NetCtrl:Send("war", "C2GSReEnterWar", t)
end


module(..., package.seeall)

--Reserve Start--
function EncodePos(t)
	for k, v in pairs(t) do
		t[k] =  v * 1000
	end
	return t
end
function DecodePos(t)
	for k, v in pairs(t) do
		t[k] =  v / 1000
	end
	return t
end
--Reserve End--

--GS2C--

function GS2CShowScene(pbdata)
	local scene_id = pbdata.scene_id
	local map_id = pbdata.map_id
	local scene_name = pbdata.scene_name
	local x = pbdata.x
	local y = pbdata.y
	--todo
	g_MapCtrl:StopAoiWalker(false)
	g_WarCtrl:ShowSceneEndWar()
	-- if not g_WarCtrl:IsPlayRecord() then
	if not g_NetCtrl:IsProtoRocord() then
		g_MapCtrl:ShowScene(scene_id, map_id, scene_name, {x = x,y = y})
	end
	g_BonfireCtrl.m_IsInBonfireScene = false
	g_GuessRiddleCtrl:LoginAgain(map_id)
	--贴心管家相关
	g_ScheduleCtrl:SetStopNotifyTime()
	--任务间隔提示
	g_TaskCtrl:SetTaskIntervalNotifyTime()
	--挖宝相关
	g_TreasureCtrl:OnEvent(define.Treasure.Event.SliderBroken)
end

function GS2CEnterScene(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local pos_info = pbdata.pos_info
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	g_MapCtrl:EnterScene(eid, DecodePos(pos_info))
	g_HudCtrl:SceneChangeEvent(false)
end

function GS2CEnterAoi(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local type = pbdata.type --1 player,2 npc, 3 scene_effect
	local aoi_player = pbdata.aoi_player
	local aoi_npc = pbdata.aoi_npc
	local aoi_effect = pbdata.aoi_effect
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end

	if g_MapCtrl.m_StopAoiWalker then 
		return
	end 

	if type == 1 then		
		local aoiPlayer = table.copy(aoi_player)
		aoiPlayer.block = g_NetCtrl:DecodeMaskData(aoiPlayer.block, "PlayerAoiBlock")
		aoiPlayer.pos_info = DecodePos(aoiPlayer.pos_info)
		-- g_MapCtrl:AddPlayer(eid, aoiPlayer)
		g_MapWalkerLoadCtrl:AddWalker(eid, aoiPlayer, type)
		if aoiPlayer.pid == g_AttrCtrl.pid then
			g_AttrCtrl:UpdateAttr({model_info = aoiPlayer.block.model_info})
		end
	elseif type == 2 then
		local aoiNpc = table.copy(aoi_npc)
		aoiNpc.pos_info = DecodePos(aoiNpc.pos_info)
		aoiNpc.block = g_NetCtrl:DecodeMaskData(aoiNpc.block, "NpcAoiBlock")

		--设置自己可见的全局npc的造型信息
		for k,v in pairs(g_MapCtrl.m_GlobalNpcChangeInfo) do
			if v.npctype == aoiNpc.npctype then
				if v.figure and v.figure ~= 0 then
					aoiNpc.block.model_info.shape = data.modeldata.CONFIG[v.figure].model
				end
				if v.title and v.title ~= "" then
					aoiNpc.block.title = v.title
				end
			end
		end

		-- g_MapCtrl:AddNpc(eid, aoiNpc)
		g_MapWalkerLoadCtrl:AddWalker(eid, aoiNpc, type)
	elseif type == 3 then
		local aoi_effect = table.copy(aoi_effect)
		g_MapCtrl:AddEffect(eid, aoi_effect)
	end
end

function GS2CLeaveAoi(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end

	if g_MapCtrl.m_StopAoiWalker then 
		return
	end 
	g_MapCtrl:DelWalker(eid)
	g_MapCtrl:DelEffect(eid)
	g_MapWalkerLoadCtrl:DelWalker(eid)
end

function GS2CSyncAoi(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local type = pbdata.type --1 player,2 npc
	local aoi_player_block = pbdata.aoi_player_block
	local aoi_npc_block = pbdata.aoi_npc_block
	--todo
	if g_MapWalkerLoadCtrl:IsWaitingLoad(eid) then
		g_MapWalkerLoadCtrl:AddCacheProto(eid, "GS2CSyncAoi", scene_id, eid, type, aoi_player_block, aoi_npc_block)
	else
		g_MapCtrl:GS2CSyncAoi(scene_id, eid, type, aoi_player_block, aoi_npc_block)
	end
end

function GS2CSyncPos(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local pos_info = pbdata.pos_info
	--todo
	if g_MapWalkerLoadCtrl:IsWaitingLoad(eid) then
		g_MapWalkerLoadCtrl:AddCacheProto(eid, "GS2CSyncPos", scene_id, eid, pos_info)
	else
		g_MapCtrl:GS2CSyncPos(scene_id, eid, pos_info)
	end
end

function GS2CSyncPosQueue(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local poslist = pbdata.poslist
	--todo
	if g_MapWalkerLoadCtrl:IsWaitingLoad(eid) then
		g_MapWalkerLoadCtrl:AddCacheProto(eid, "GS2CSyncPosQueue", scene_id, eid, poslist)
	else
		g_MapCtrl:GS2CSyncPosQueue(scene_id, eid, poslist)
	end
end

function GS2CTrunBackPos(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local pos_info = pbdata.pos_info
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	local oWalker = g_MapCtrl:GetWalker(eid)
	if oWalker then
		g_MapCtrl:UpdateByPosInfo(oWalker, DecodePos(pos_info))
	end
end

function GS2CAutoFindPath(pbdata)
	local npcid = pbdata.npcid
	local map_id = pbdata.map_id
	local pos_x = pbdata.pos_x
	local pos_y = pbdata.pos_y
	local autotype = pbdata.autotype --自动寻路类型,1:先跳场景,再寻路,2:通过跳转点寻路
	local callback_sessionidx = pbdata.callback_sessionidx
	local functype = pbdata.functype --功能类型。1:宝图罗盘
	--todo
	if g_MapWalkerLoadCtrl:IsWaitingLoad(eid) then
		g_MapWalkerLoadCtrl:AddCacheProto(eid, "GS2CAutoFindPath", pbdata)
	else
		g_MapCtrl:GS2CAutoFindPath(pbdata)
	end
end

function GS2CSceneCreateTeam(pbdata)
	local scene_id = pbdata.scene_id
	local team_id = pbdata.team_id
	local pid_list = pbdata.pid_list
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end

	g_MapCtrl:UpdateTeam(team_id, pid_list)
	g_FlyRideAniCtrl:TeamHandle(team_id)
	g_MapPlayerNumberCtrl:HandleTeamEvent(pid_list)

end

function GS2CSceneRemoveTeam(pbdata)
	local scene_id = pbdata.scene_id
	local team_id = pbdata.team_id
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	g_MapCtrl:RemoveTeam(team_id)
	g_MapPlayerNumberCtrl:HandleTeamEvent()
end

function GS2CSceneUpdateTeam(pbdata)
	local scene_id = pbdata.scene_id
	local team_id = pbdata.team_id
	local pid_list = pbdata.pid_list
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end

	g_MapCtrl:UpdateTeam(team_id, pid_list)
	g_FlyRideAniCtrl:TeamHandle(team_id)
	g_MapPlayerNumberCtrl:HandleTeamEvent(pid_list)

end

function GS2CSceneEffect(pbdata)
	local effect = pbdata.effect
	--todo
	g_FriendCtrl:GS2CSceneEffect(pbdata)

end

function GS2CNpcBubbleTalk(pbdata)
	local npcid = pbdata.npcid
	local msg = pbdata.msg
	local timeout = pbdata.timeout ---1表示永久显示（直到npc移除），0表示默认时间，正数为显示秒数
	--todo
	g_MapCtrl:GS2CNpcBubbleTalk(pbdata)
end

function GS2CWaterWalkSuccess(pbdata)
	--todo
end


--C2GS--

function C2GSSyncPosQueue(scene_id, eid, poslist)
	local t = {
		scene_id = scene_id,
		eid = eid,
		poslist = poslist,
	}
	g_NetCtrl:Send("scene", "C2GSSyncPosQueue", t)
end

function C2GSTransfer(scene_id, eid, transfer_id)
	local t = {
		scene_id = scene_id,
		eid = eid,
		transfer_id = transfer_id,
	}
	g_NetCtrl:Send("scene", "C2GSTransfer", t)
end

function C2GSClickWorldMap(scene_id, eid, map_id)
	local t = {
		scene_id = scene_id,
		eid = eid,
		map_id = map_id,
	}
	g_NetCtrl:Send("scene", "C2GSClickWorldMap", t)
end

function C2GSClickTrapMineMap(scene_id, map_id)
	local t = {
		scene_id = scene_id,
		map_id = map_id,
	}
	g_NetCtrl:Send("scene", "C2GSClickTrapMineMap", t)
end

function C2GSStartWaterWalk(walkid)
	local t = {
		walkid = walkid,
	}
	g_NetCtrl:Send("scene", "C2GSStartWaterWalk", t)
end


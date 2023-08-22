local CMapCtrl = class("CMapCtrl", CCtrlBase)

CMapCtrl.SPECIALMAP = {}

function CMapCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_LoadDoneCbList = {}
	self.m_LoadingInfo = {map = nil, light = nil, res = nil}
	self.m_ResID = nil
	self.m_LightID = nil
	self.m_MapArenaData = {}
	self.m_MapDanceData = {}
	self.m_MapWaterPointData = {}
	self.m_MapWaterLineData = {}
	self.m_MarryAreaData = {}
	self.m_LastMapResId = nil
	self.m_NpcVisibilityList = {}
	self.m_SceEffectVisibilityList = {}
	self.m_IsGhostEyeOpen = 0
	self.m_SceneEffectGoList = {}
	self.m_SceneEffectDynamicMainGo = nil

	self.m_GlobalNpcChangeInfo = {}

	self.m_IsNpcCloseUp = false
	self.m_NpcShowEndCbList = {}

	self.m_IsInPlot = false
	self.m_MapInitPos = nil
	self.m_In2DMap = false

	--踩水动作的相关vector
	self.m_JumpPosList = {Vector3.New(0, 0, 0), Vector3.New(0, 0.7, 0), Vector3.New(0, 0, 0)}
	self.m_WaterPosCfg = { 
		[1030] = { { {Vector2.New(20, 17), Vector2.New(20, 17)}, {Vector2.New(22, 5), Vector2.New(23, 7)} }, 
				   { {Vector2.New(38, 10), Vector2.New(40, 11)}, {Vector2.New(45, 22), Vector2.New(46, 19)} } } 
	}
	self:InitValue()
	self.m_Map2DComponent = nil

	self:InitYanHuaEffectNode()

	--活动场景添加小地图npc显示
	self.m_ShowNpcInMiniMap = {[508000] = "OnThreeBiWu", [503000] = "OnLiuMai", [502000] = "OnPK", [504000] = "OnOrgMatchPrepare", [505000] = "OnOrgMatchBattle",[509000] = "OnSingleWar"}

end

function CMapCtrl.InitValue(self)
	self.m_SpecialFollowShow = false
	self.m_SpecialFollowHide = false

	self.m_IsFlyWaterProgress = false

	self.m_SceneID = nil
	self.m_MapID = nil
	self.m_Hero = nil
	self.m_Players = {}
	self.m_Npcs = {}
	self.m_Effects = {}
	self.m_DynamicNpcs = {}
	self.m_TaskPickItems = {}
	self.m_Walkers = {}
	self.m_IntanceID2Walker = {} -- setmetatable({}, {__mode="v"})
	self.m_LoadDoneCB = nil
	self.m_Teams = {}
	self.m_TeamMissPlayers = {}
	self.m_AutoPatrolLists = {}
	self.m_NianShouNpcs = {}

	self.m_EngagedHeartPlayers = {}

	self.m_EnterSceneFinish = nil
	self.m_AutoFindData = nil
	self.m_MapSwitchEffing = nil
	self.m_TransferAreas = nil
	self.m_IsEnterArena = false
	self.m_HideWalkerFlag = nil
	-- self.m_LoadDoneCbList = {}
end

function CMapCtrl.Is3DMap(self, resid)
	--return resid >= 6000
	return false
end

function CMapCtrl.IsWalkMap(self, resid)
	--return resid < 6000
	return true
end

function CMapCtrl.IsNavMap(self, resid)
	--return resid < 6100
	return true
end

function CMapCtrl.IsWalkable(self, x, y)
	return self.m_Map2DComponent and self.m_Map2DComponent:IsWalkable(x, y)
end

function CMapCtrl.ReleaseMap(self)
	if self.m_CurMapObj then
		self.m_CurMapObj.m_MapCompnent:Release()
		self.m_CurMapObj:Destroy()
		--g_ResCtrl:PutMapInCache(self.m_ResID, self.m_CurMapObj)
	end
	self.m_CurMapObj = nil
	self.m_ResID = nil
	self.m_LightID = nil
end

function CMapCtrl.Clear(self, bReleaseMap)
	if bReleaseMap then
		self:ReleaseMap()
	end
	if self.m_CurMapObj then
		self.m_CurMapObj.m_MapCompnent:SetMapEffectGoActive(false)
	end
	self:ClearMapDynamicEffect()
	self:DelAllNianShouNpc()
	g_EffectCtrl:SetRootActive(false)
	for i, oWalker in pairs(self.m_Walkers) do
		if oWalker.m_Followers then
			for j,c in pairs(oWalker.m_Followers) do
				self:SafeDelWalker(c)
			end
		end
		self:SafeDelWalker(oWalker)
		if oWalker.m_FolowOrderList then
			oWalker.m_FolowOrderList = {}
		end
	end
	--note:保险点做一次回收
	g_MapWalkerCacheCtrl:RecyleAllCache()
	self:InitValue()

	g_MapPlayerNumberCtrl:Clear()

	self:HideYanHuaEffects()
	g_MapWalkerLoadCtrl:Clear()
	--g_ResCtrl:GC(true)
	g_ResCtrl:CheckForceGc()
end

function CMapCtrl.GetCurMapObj(self)
	return self.m_CurMapObj
end

function CMapCtrl.ShowWarScene(self, mapid, x, y)
	g_ResCtrl:UpdateGcFlagCount()
	local pos_info = {
		x = x,
		y = y,
	}
	local function OnMapLoadDone()
		printc("战斗地图加载结束")
		self:ResetCameraFollow()
	end
	printc("加载战斗场景：", mapid)
	self:AddLoadDoneCb(OnMapLoadDone)
	self:ShowScene(0, mapid, "_", pos_info, true)
end

function CMapCtrl.ShowScene(self, sceneid, mapid, scenename, pPosInfo, bIsPlot)
	g_ResCtrl:UpdateGcFlagCount()
	g_ResCtrl:MoveToSecondary()

	self.m_IsMapLoadDone = false
	self.m_MapInitPos = pPosInfo
	self.m_IsInPlot = bIsPlot
	local showEffect = mapid ~= self.m_MapID and self.m_CurMapObj ~= nil--and (not g_TeamCtrl:IsJoinTeam() or g_TeamCtrl:IsLeader())
	-- 画舫灯谜 被玩家踢人时需要产生特效
	local bIsReload = self.m_SceneID == sceneid and self.m_MapID == mapid
	local mapData = DataTools.GetMapInfo(mapid)
	
	if self.m_ResID ~= mapData.resource_id then
		--非任意挂机 非暗雷场景停止巡逻
		if not self.m_IsAutoPatrolFree and not (datauser.patroldata.DATA[mapData.resource_id] ~= nil) then
			self:SetAutoPatrol(false, false, true)
		end
		--特殊需求，切换地图停止巡逻，m_IsAutoPatrolFree条件被忽略
		if not (datauser.patroldata.DATA[mapData.resource_id] ~= nil) then
			self:SetAutoPatrol(false, false, true)
		end
	end
	if showEffect then
		if not self.m_MapSwitchEffing then
			-- 非组队或有队伍但非队长下播放特效
			-- 清除场景信息（Clear）前播转场特效
			self.m_MapSwitchEffing = true
			local notWar = not g_WarCtrl:IsWar()
			if notWar then
				g_NetCtrl:SetCacheProto("mapswitch", true)
			end
			self:MapFadeEffect(self.m_Hero, self.m_Hero and self.m_Hero:GetPos(), function ()
				self.m_MapSwitchEffing = nil
				if not bIsReload then
					self:Load(mapData.resource_id, pPosInfo, nil, bIsPlot)
					self.m_ResID = mapData.resource_id
				end
				if notWar then
					g_NetCtrl:SetCacheProto("mapswitch", false)
					g_NetCtrl:ClearCacheProto("mapswitch", true)
				end
			end)
		end
	end
	
	self:Clear(false)
	self.m_SceneID = sceneid
	self.m_MapID = mapid
	self.m_SceneName = scenename

	--比武相关
	if g_PKCtrl.m_pkMapId ~= g_MapCtrl:GetMapID() then
		g_PKCtrl:SetPKMatchCountTime(0)
	end

	self:AddSceneEffect()
	self:CheckNianShouNpc()

	if self.m_CurMapObj then
		if not g_WarCtrl:IsWar() then
			-- CMapFadeView:ShowView(function (oView)
			-- 	oView:RefreshUI()
			-- end)
		end 
	end 

	if not showEffect then
		self:Load(mapData.resource_id, pPosInfo, nil, bIsPlot)
	end
	g_MapPlayerNumberCtrl:StartCheck()

	g_MarryCtrl:ShowScene(sceneid, mapid, bIsPlot)
	g_JieBaiCtrl:TryOpenYiShiView()
	g_MiBaoConvoyCtrl:SceneChange()
	self:OnEvent(define.Map.Event.ShowScene)
end

function CMapCtrl.EnterScene(self, eid, pPosInfo)

	-- if true then
	-- 	return
	-- end
	if self.m_MapSwitchEffing then
		return
	end
	if self.m_CurMapObj then
		self.m_CurMapObj.m_MapCompnent:SetMapEffectGoActive(true)
		--暂时屏蔽
		g_TaskCtrl:CheckTaskThing()
	end
	g_EffectCtrl:SetRootActive(true)
	self.m_EnterSceneFinish = true
	local mapData = DataTools.GetMapInfo(self.m_MapID)
	if self:IsWalkMap(mapData.resource_id) and not self.m_IsInPlot then
		self:AddHero(eid, pPosInfo)
		if self.m_AutoFindData then
			self:AutoFindPath(self.m_AutoFindData)
		end
	end
	g_ResCtrl:ResetCloneDynamicLevel()  --清除动态人物加载顺序
	if not self.m_IsInPlot then
		self:OnEvent(define.Map.Event.EnterScene)
	end
	g_NotifyCtrl:CancelProgress()
	g_ViewCtrl:SwitchScene()
	self:CheckNianShouNpc()
	g_MiBaoConvoyCtrl:SceneChange()

end

function CMapCtrl.GetWalkerRoot(self)
	if not self.m_WalkerRoot then
		self.m_WalkerRoot = CObject.New(UnityEngine.GameObject.New("WalkerRoot"))
	end
	return self.m_WalkerRoot
end

function CMapCtrl.GetMapSize(self)
	local map = self.m_CurMapObj.m_MapCompnent
	return map.width, map.height
end

function CMapCtrl.Load(self, resid, posInfo, lightid) 
	lightid = lightid or 1
	if (self.m_ResID == resid and self.m_IsInPlot) or
		(self.m_ResID == resid and self.m_LightID == lightid) or
		(self.m_LoadingInfo.res == resid and self.m_LoadingInfo.light == lightid) then
		--暂时屏蔽
		-- g_TaskCtrl:CheckTaskThing()
		--TODO:同场景加载仍处理加载成功反馈 by：喜城
		if next(self.m_LoadDoneCbList) then
			for i, cb in ipairs(self.m_LoadDoneCbList) do
				cb(g_ResCtrl:GetMapFromCache(resid))
			end
			self.m_LoadDoneCbList = {}
		end
		self.m_IsMapLoadDone = true
		self:PlayBgMusic()
		return
	end
	self.m_TransferAreas = nil
	self.m_LoadingInfo = {res = resid, light= lightid}
	self.m_LastMapResId = self.m_ResID
	self:ReleaseMap()
	self:ResetCameraFollow()
	local oCam = g_CameraCtrl:GetMapCamera()
	local oCache = g_ResCtrl:GetMapFromCache(resid)
	if oCache then
		if not self:Is3DMap(resid) then
			--立刻设置相机位置
			oCam:SetCurMap(oCache.m_MapCompnent)
			self.m_Map2DComponent = oCache.m_MapCompnent
		end
		oCache:SetParent(nil)
		self:MapLoadDone(resid, oCache)
		self.m_IsMapLoadDone = true
		return
	end
	local mapgo = CObject.New(UnityEngine.GameObject.New("map"..tostring(resid)))
	mapgo:SetLocalScale(Vector3.zero)
	mapgo:SetLayer(define.Layer.MapTerrain)
	self.m_LastLoadTime = g_TimeCtrl:GetTimeMS()
	if self:Is3DMap(resid) then
		local map3d = mapgo:AddComponent(classtype.Map3D)
		mapgo.m_MapCompnent = map3d
		local bLoadNav = self:IsNavMap(resid)
		map3d:LoadAsync(resid, lightid, bLoadNav, callback(self, "MapLoadDone", resid, mapgo))
	else
		mapgo:SetPos(Vector3.New(1.28, 1.28, 100))
		local map2d = mapgo:AddComponent(classtype.Map2D)
		mapgo.m_MapCompnent = map2d
		local function loadMap()
			map2d:LoadAsync(resid, posInfo, callback(self, "MapLoadDone", resid, mapgo))
			-- map2d:Load(resid, posInfo)
			-- self:MapLoadDone(resid, mapgo)
			--立刻设置相机位置
			oCam:SetCurMap(mapgo.m_MapCompnent)
			self.m_Map2DComponent = mapgo.m_MapCompnent
			
		end
		loadMap()
	end
end

function CMapCtrl.PlayBgMusic(self)
	if not g_WarCtrl:IsWar() and g_WarCtrl.m_ReciveResultProto ~= false and self.m_MapID then
		local mapData = DataTools.GetMapInfo(self.m_MapID)
		if not mapData or not mapData.bgm_name or string.len(mapData.bgm_name) <= 0 then
			printerror("错误，map表没有填bgm信息。@策划，地图ID：", self.m_MapID)
			return
		end
		g_AudioCtrl:PlayMusic(mapData.bgm_name .. ".mp3")
	end
end

function CMapCtrl.AutoFindPath(self, pbdata)

	local npcid = pbdata.npcid
	local map_id = pbdata.map_id
	local pos_x = pbdata.pos_x
	local pos_y = pbdata.pos_y
	local autotype = pbdata.autotype
	local callback_sessionidx = pbdata.callback_sessionidx
	local functype = pbdata.functype --功能类型。1:宝图罗盘

	if autotype == 1 then
		if map_id ~= self.m_MapID then
			return
		end

		if not self.m_EnterSceneFinish then
			self.m_AutoFindData = pbdata
			return
		end

		local function find()
			local pos = Vector3.New(pos_x, pos_y, 0)
			if callback_sessionidx and callback_sessionidx ~= 0 then
				--暂时放弃使用人物头顶显示这种做法
				-- self.m_Hero:ShowTreasureHud()
				if functype == 1 then
					CTreasurePointerView:ShowView(function (oView)
						local startPos = self.m_Hero:GetPos()
						local endPos = Vector3.New(math.floor(pos_x/1000), math.floor(pos_y/1000), 0)
						oView:SetPointerRotate(startPos, endPos, pos, callback_sessionidx)
					end)
				elseif functype == 2 then
					local function finished()
						netother.C2GSCallback(callback_sessionidx)
					end
					g_MapTouchCtrl:WalkToPos(netscene.DecodePos(pos), nil, define.Walker.Npc_Talk_Distance, finished)
				else
					local function finished()
						netother.C2GSCallback(callback_sessionidx)
					end
					g_MapTouchCtrl:WalkToPos(netscene.DecodePos(pos), nil, define.Walker.Npc_Talk_Distance, finished)
				end
				
			else
				if npcid then
					local oNpc = self:GetNpc(npcid)
					if not oNpc then
						oNpc = self:GetDynamicNpc(npcid)
					end
					if not oNpc then
						oNpc = self:GetTaskPickItem(npcid)
					end
					if oNpc and oNpc.Trigger then
						g_MapTouchCtrl.m_LastMapWalker = oNpc
						oNpc:ShowFootRing(true)
					end
				end
				g_MapTouchCtrl:WalkToPos(netscene.DecodePos(pos), (npcid ~= 0 and {npcid} or {nil})[1], define.Walker.Npc_Talk_Distance)
			end
		end
		if self.m_LoadingInfo.res ~= nil then
			self:AddLoadDoneCb(find)
		else
			find()
		end
	elseif autotype == 2 then
		printc("TODO >>> ===== 通过跳转点寻路,这部分的客户端逻辑未完成 =====")
	end
end

function CMapCtrl.GetMapID(self)
	return self.m_MapID
end

function CMapCtrl.GetSceneID(self)
	return self.m_SceneID
end

function CMapCtrl.GetResID(self)
	return self.m_ResID
end

function CMapCtrl.GetSceneName(self)
	return self.m_SceneName
end

function CMapCtrl.AddLoadDoneCb(self, func)
	table.insert(self.m_LoadDoneCbList, func)
end

function CMapCtrl.MapLoadDone(self, resid, mapobj)
	print('MapLoadDone,', resid, self.m_LoadingInfo.res, self.m_ResID)
	if self.m_FloatTime and self.m_LastLoadTime then
		g_NotifyCtrl:FloatMsg(string.format("load地图%d时间: %dms", resid, g_TimeCtrl:GetTimeMS()-self.m_LastLoadTime))
	end
	if self.m_LoadingInfo.res ~= resid then
		print("与最后load信息不符, 删除", self.m_LoadingInfo.res, resid)
		mapobj.m_MapCompnent:Release()
		mapobj:Destroy()
		return 
	end
	
	g_MapTouchCtrl:ClearState()
	mapobj:SetName("map_"..tostring(resid))
	mapobj:SetLocalScale(Vector3.one)
	self.m_ResID = self.m_LoadingInfo.res
	self.m_LightID = self.m_LoadingInfo.light
	self.m_LoadingInfo = {map = nil, light=nil}
	self.m_CurMapObj = mapobj
	self:SetMapEffectActive()
	if not self:Is3DMap(self.m_ResID) then
		local pos = self.m_CurMapObj:GetPos()
		self.m_CurMapObj:SetPos(Vector3.New(pos.x, pos.y, 100))
	end
	self.m_IsMapLoadDone = true
	self:OnEvent(define.Map.MapLoadDone, mapobj)

	if self:IsWalkMap(self.m_ResID) then
		--因队伍跟随距离， 暂时屏蔽
		--self:UpdateFollow()
		if next(self.m_LoadDoneCbList) then
			for i, cb in ipairs(self.m_LoadDoneCbList) do
				cb(mapobj)
			end
			self.m_LoadDoneCbList = {}
		end
		self:ResetMapCamera()
		g_TaskCtrl:CheckTaskThing()
		if self.m_IsAutoPatrol then
			if not self.m_IsAutoPatrolFree and not self:IsAutoPatrolMap() then
				g_NotifyCtrl:FloatMsg("该场景非暗雷场景，无法自动巡逻")
				self:SetAutoPatrol(false, false, true)
			end
		end
		self:CheckAutoPatrol()

		if self.m_ResetTransferTimer then
			Utils.DelTimer(self.m_ResetTransferTimer)
			self.m_ResetTransferTimer = nil
		end

		for eid, oWalker in pairs(self.m_Walkers) do
			-- 重新刷新场景ID
			if not oWalker.m_Actor.m_LoadingShape then
				oWalker:SetMapID(self:GetResID())
			end
		end

		local mapData = DataTools.GetMapInfo(self.m_MapID)
		g_MapTouchCtrl:EnterScene(mapData)
		self:InitArenaData(resid)
		self:InitDanceData(resid)
		self:InitWaterPointData(resid)
		self:InitWaterLineData(resid)
		self:InitMarryAreaData(resid)
	end
	
	self:PlayBgMusic()

	-- g_ResCtrl:GC()
end

function CMapCtrl.ResetMapCamera(self)
	if self.m_CurMapObj then
		local oCam = g_CameraCtrl:GetMapCamera()
		oCam:SetCurMap(self.m_CurMapObj.m_MapCompnent)
		self.m_Map2DComponent = self.m_CurMapObj.m_MapCompnent
		oCam:SyncTargetPos()
		--
		-- g_ResCtrl:GC()
	end
end

function CMapCtrl.GetWalkerDefaultSpeed(self, isPlayer)
	local defaultSpeed = isPlayer and define.Map.Speed.Hero or define.Map.Speed.Player
	return defaultSpeed
end

function CMapCtrl.GetHero(self)
	return self.m_Hero
end

function CMapCtrl.GetWalker(self, eid)
	return self.m_Walkers[eid]
end

function CMapCtrl.GetPlayer(self, pid)
	return self.m_Players[pid]
end

function CMapCtrl.GetNpc(self, npcid)
	return self.m_Npcs[npcid]
end

function CMapCtrl.GetNpcByType(self, npctype)
	for _,oNpc in pairs(self.m_Npcs) do
		if oNpc.m_NpcAoi.npctype == npctype then
			return oNpc
		end
	end
end

function CMapCtrl.GetDynamicNpc(self, npcid)
	return self.m_DynamicNpcs[npcid]
end

function CMapCtrl.GetTaskPickItem(self, pickid)
	return self.m_TaskPickItems[pickid]
end

function CMapCtrl.UpdateByPosInfo(self, oWalker, posInfo, rotateY)
	local posx, posy = posInfo.x, posInfo.y
	oWalker:SetLocalPos(Vector3.New(posx, posy, 0))
	if (oWalker.classtype == CPlayer or oWalker.classtype == CHero) then
		oWalker.m_Actor:SetLocalEulerAngles(Vector3.New(posInfo.face_x, posInfo.face_y, 0))
	end
end

--立即同步主角位置，慎用
function CMapCtrl.UpdateHeroPos(self)
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		oHero.m_LastRecordPos = nil
		oHero:SyncCurPos()
	end
end

function CMapCtrl.CheckPosArea(self, oWalker, posInfo)
	local posx, posy = 12, 12
	if posInfo and posInfo.x and posInfo.x > 0 and posInfo.x < 100 then
		posx, posy = posInfo.x, posInfo.y
	else
		printc("服务端设置的位置超出范围！", oWalker:GetName())
	end
	oWalker:SetLocalPos(Vector3.New(posx, posy, 0))
end

function CMapCtrl.CheckRotation(self, oWalker, posInfo)
	-- 旋转
	if posInfo and posInfo.face_x and posInfo.face_x ~= posInfo.face_y and posInfo.face_x ~= 0 then
		-- local newRotation = Quaternion.LookRotation(Vector3.New(posInfo.face_x, 0, posInfo.face_y))
		-- oWalker.m_Actor:SetLocalRotation(newRotation)
		oWalker.m_Actor:SetLocalEulerAngles(Vector3.New(posInfo.face_x, posInfo.face_y, 0))
		-- if oWalker.classtype == CPlayer or oWalker.classtype == CHero then
		-- 	oWalker.m_Actor:SetLocalEulerAngles(Vector3.New(posInfo.face_x, posInfo.face_y, 0))
		-- end
	else
		oWalker.m_Actor:SetLocalRotation(Quaternion.Euler(0, 150, 0))
	end
end

function CMapCtrl.CheckSummonPosArea(self, oWalker, posInfo)
	local posx, posy = 12, 12
	if posInfo and posInfo.x and posInfo.x > 0 and posInfo.x < 100 then
		posx, posy = posInfo.x, posInfo.y
	else
		printc("服务端设置的位置超出范围！", oWalker:GetName())
	end
	oWalker:SetLocalPos(Vector3.New(posx+0.5, posy, 0))
end

--更新当前角色
function CMapCtrl.UpdateHero(self)
	if self.m_Hero == nil then
		return
	end
	self.m_Hero.m_Name = g_AttrCtrl.name
	local badgeId = g_AttrCtrl.m_BadgeInfo and g_AttrCtrl.m_BadgeInfo.tid or 0
	self.m_Hero:SetTitleHud(badgeId)
	-- 更新名字
	self.m_Hero:SetName(g_AttrCtrl.name)
	self.m_Hero:SetWearingTitle()
	if self.m_Hero:IsAllModelLoadDone() then
		self:UpdateActor()
	end
	
end

function CMapCtrl.ChangeHeroShape(self)
	if self.m_Hero == nil then
		return
	end
	
	self.m_Hero:ChangeShape(g_AttrCtrl.model_info_changed, callback(self, "UpdateActor"))
	g_FlyRideAniCtrl:TryFly(self.m_Hero)

end

function CMapCtrl.UpdateActor(self)
	if self.m_Hero == nil then
		return
	end

    if self.m_Hero.m_IsPlayDance then
    	self.m_Hero.m_Actor:Play("dance")
    	if g_HorseCtrl.m_isUseRide then
	    	self.m_Hero:DelBindObj("dancer")
	    else
	    	self.m_Hero:AddBindObj("dancer")
	    end
    	self.m_Hero.m_IsPlayDance = nil
    else
    	self.m_Hero:DelBindObj("dancer")
    end

    self:UpdateMiBaoTag()

end

function CMapCtrl.ResetCameraFollow(self)
	local oCam = g_CameraCtrl:GetMapCamera()
	local oTarget = self:GetHero()
	if not oTarget then
		if g_WarCtrl:IsWar() then
			if not self.m_TempFollowOj then
				self.m_TempFollowOj = CObject.New(UnityEngine.GameObject.New("TempCameraFollowTarget"))
			end
			oTarget = self.m_TempFollowOj
			oTarget:SetLocalPos(Vector3.New(self.m_MapInitPos.x/1000, self.m_MapInitPos.y/1000, 0))
		end
	end
	if oTarget then
		oCam:Follow(oTarget.m_Transform)
	end
end

function CMapCtrl.AddHero(self, eid, pPosInfo)

	--printc("=============== 添加主角", g_TimeCtrl:GetTimeMS(), g_TimeCtrl:GetTimeS())

	local oHero = self.m_Hero
	if not oHero then
		oHero = CHero.New()
		self.m_Hero = oHero
	else
		self.m_Walkers[oHero.m_Eid] = nil
	end
	oHero.m_Eid = eid
	oHero.m_Name = g_AttrCtrl.name
	oHero.m_Pid = g_AttrCtrl.pid
	oHero.m_RealName = g_AttrCtrl.name
	oHero.m_FlyHeight = g_AttrCtrl.fly_height

	-- local badgeId = g_AttrCtrl.m_BadgeInfo and g_AttrCtrl.m_BadgeInfo.tid or 0
	-- oHero:SetName(g_AttrCtrl.name, badgeId)
	oHero:SetWearingTitle()
	CObject.SetName(oHero, string.format("e%d-p%d-%s",eid,g_AttrCtrl.pid, g_AttrCtrl.name))
	local badgeId = g_AttrCtrl.m_BadgeInfo and g_AttrCtrl.m_BadgeInfo.tid or 0
	oHero:SetTitleHud(badgeId)
	--确保清除跟随的宠物和npc
	self:DelAllSummonWalker(eid)

	self.m_Walkers[eid] = oHero
	self.m_Players[g_AttrCtrl.pid] = oHero
	self.m_IntanceID2Walker[oHero:GetInstanceID()] = weakref(oHero)

	self:CheckPosArea(oHero, pPosInfo)
	
	oHero:ChangeShape(g_AttrCtrl.model_info_changed, callback(self, "UpdateActor"))
	oHero:ShowWalker(true)
	g_FlyRideAniCtrl:TryFly(oHero)
--	oHero:CheckInScreen()

	self:CheckRotation(oHero, pPosInfo)
	self:ResetCameraFollow()
	self:CheckAutoPatrol()
	local v3 = oHero:GetLocalPos()
	for k,v in pairs(g_AttrCtrl.followers) do
		v3.x = v3.x + 0.5
		local objName = string.format("e%d-p%d-%s-%s", eid, g_AttrCtrl.pid, g_AttrCtrl.name,v.name)
		self:AddSummon(v,eid,objName,pPosInfo)
	end
	self:UpdateHeroState(g_AttrCtrl.orgmatch_state)
	-- local teamID = oHero.m_TeamID
	-- self:UpdatePlayerHeart(teamID)
	self:CheckWalkerHide(oHero)


end

function CMapCtrl.UpdateMiBaoTag(self)
	
	local isShow = g_MiBaoConvoyCtrl:IsShowConvoyTag()
	if isShow then
		g_MiBaoConvoyCtrl:AddConvoyTag()
	else
		g_MiBaoConvoyCtrl:DelConvoyTag()
	end  

end

--excel/buff/state 帮派竞赛状态刷新
function CMapCtrl.UpdateHeroState(self, state)
	local badgeId = g_AttrCtrl.m_BadgeInfo and g_AttrCtrl.m_BadgeInfo.tid or 0
	if not self.m_Hero then
		return
	end
	if state == define.OrgMatch.State.Protect then
		self.m_Hero:SetName(g_AttrCtrl.name, DataTools.GetNameColor(define.RoleColor.ORGProtect))
	elseif not state or state == 0 then
		self.m_Hero:SetName(g_AttrCtrl.name)
	end
end


function CMapCtrl.AddSummon(self, v, eid, objName, v3)

	if eid == nil then
		if not self.m_Hero then
			return 
		end
		eid = self.m_Hero.m_Eid
		objName =  string.format("e%d-p%d-%s-%s",eid,g_AttrCtrl.pid, g_AttrCtrl.name,v.name)
		v3 = self.m_Hero:GetLocalPos()
	end
	if not self.m_Walkers[eid] then
		return
	end

	local shape = nil
	if v.model_info.shape and v.model_info.shape > 0 then
		shape = v.model_info.shape
	elseif v.model_info.figure then
		local figureInfo = ModelTools.GetModelConfig(v.model_info.figure)
		shape = figureInfo.model
	end

	if not shape then
		printerror("CMapCtrl.AddSummon 错误：未找到有效的shape信息")
	end

	local oWalker = self:GetWalker(eid)
	local oSummon = oWalker.m_Followers[shape]
	if oSummon then
		if not oWalker.m_FolowOrderList then
			oWalker.m_FolowOrderList = {}
		end
		local list = {oSummon, shape}
		table.insert(oWalker.m_FolowOrderList, list)
		oSummon:SetName(v.name)
		if v.title and v.title ~= "" then
			oSummon:SetNpcNormalHUD(v.title)
		end
		oSummon:ChangeShape(v.model_info)
		return
	end

	for k,v in pairs(oWalker.m_Followers) do --现在默认只有一个跟随宠物
		self:DelSummonWalker(k, eid)
	end	
	if shape == 0  then
		return
	end

	local function setFollow()
		if not oWalker.m_FolowOrderList or not next(oWalker.m_FolowOrderList) then
			if g_HorseCtrl.m_isUseRide then 
				oSummon:Follow(oWalker, define.Walker.Summon_Ride_Distance)
			else
				oSummon:Follow(oWalker)
			end 
		else
			local walker = oWalker.m_FolowOrderList[#oWalker.m_FolowOrderList][1]
			if g_HorseCtrl.m_isUseRide then 
				oSummon:Follow(oWalker, define.Walker.Summon_Ride_Distance)
			else
				oSummon:Follow(oWalker)
			end 
		end

		oWalker.m_Followers[shape] = oSummon
		if not oWalker.m_FolowOrderList then
			oWalker.m_FolowOrderList = {}
		end
		local list = {oWalker.m_Followers[shape], shape}
		table.insert(oWalker.m_FolowOrderList, list)
	end

	--需要特殊表现的条件
	if shape == self.m_SpecialFollowShape and self.m_SpecialFollowShow then
		self.m_SpecialFollowShow = false
		local function followShow()
			oSummon = CMapSummon.New()
			oSummon:SetName(v.name)
			CObject.SetName(oSummon, objName)
			if v.title and v.title ~= "" then
				oSummon:SetNpcNormalHUD(v.title)
			end

			local function onLoadDone()
				local oHero = g_MapCtrl:GetHero()
				if oHero then
					local function onStop()
						oHero:ChatMsg("有劳，先跟着我，待会儿送你回去。")
						g_NotifyCtrl:ShowDisableWidget(false)
						oSummon:ShowCloudEffect(false)
						setFollow()
					end
					g_ViewCtrl:CloseAll(g_ViewCtrl.m_SumSpecialFollowCloseAllNeedList)
					g_NotifyCtrl:ShowDisableWidget(true, "坐骑正在赶来，请稍候~")
					oSummon:ShowCloudEffect(true)
					oSummon.m_StopCallback = onStop
					self:CheckSummonPosArea(oSummon, Vector2.New(oHero:GetPos().x+7, oHero:GetPos().y+3))			

					if self.m_WaitTimer then
						Utils.DelTimer(self.m_WaitTimer)
						self.m_WaitTimer = nil			
					end
					local function progress()
						oSummon.m_Walker:WalkTo3(oHero:GetPos().x+1, oHero:GetPos().y)
						return false
					end	
					self.m_WaitTimer = Utils.AddTimer(progress, 0, 0)
				end
			end
			oSummon:ChangeShape(v.model_info, onLoadDone)
		end

		g_InteractionCtrl.m_InteractionResultType = define.Yibao.InteractionResultType.GetBell
		g_InteractionCtrl.m_InteractionQteid = 10
		g_InteractionCtrl.m_InteractionResultFunc = followShow
		for k,v in pairs(data.interactiondata.QTEDATA) do
			if v.id == g_InteractionCtrl.m_InteractionQteid then
				g_InteractionCtrl.m_InteractionQteConfig = v
				break
			end
		end
		CInteractionView:ShowView(function (oView)
			oView:SetContent()
		end)				
	else
		oSummon = g_MapWalkerCacheCtrl:GetCacheSummon()
		oSummon:SetName(v.name)
		oSummon.m_Type = v.type
		oSummon.m_BelongTo = oWalker
		CObject.SetName(oSummon, objName)
		if v.title and v.title ~= "" then
			oSummon:SetNpcNormalHUD(v.title)
		end
		if v3 then
			self:CheckSummonPosArea(oSummon, v3)
		end
		setFollow()
		oSummon:ChangeShape(v.model_info)

		if not oWalker:IsShow() then
			oSummon:ShowWalker(false)
		end

	end	
	self:CheckWalkerHide(oSummon)
end

function CMapCtrl.UpdatePlayer(self, oPlayer)
    if oPlayer.m_IsPlayDance then
    	oPlayer.m_Actor:Play("dance")
    	if oPlayer.m_RideId ~= 0 then
	    	oPlayer:DelBindObj("dancer")
	    else
	    	oPlayer:AddBindObj("dancer")
	    end	
    	oPlayer.m_IsPlayDance = nil
    else
    	oPlayer:DelBindObj("dancer")
    end  

    if oPlayer:IsInConvoyTask() then 
    	oPlayer:SetConvoyTag()
    	local defaultSpeed = g_MapCtrl:GetWalkerDefaultSpeed(true)
    	local ratio = g_MiBaoConvoyCtrl:GetSpeedRatio()
    	local speed = defaultSpeed * ratio
    	oPlayer:SetMoveSpeed(speed)
    end 

end

--scene.proto playerAoi
function CMapCtrl.AddPlayer(self, eid, pPlayerAoi)
	 -- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "AddPlayer", "添加玩家"), pPlayerAoi.block.name)
	 -- table.print(pPlayerAoi)
	local oPlayer = self:GetWalker(eid) or self:GetPlayer(pPlayerAoi.pid)
	local bIsExist = true
	if not oPlayer then
		bIsExist = false
		oPlayer = g_MapWalkerCacheCtrl:GetCachePlayer()
	else
		self.m_Walkers[oPlayer.m_Eid] = nil
	end
		oPlayer.m_RideId = pPlayerAoi.block.model_info.horse
		oPlayer.m_Eid = eid
		oPlayer.m_Pid = pPlayerAoi.pid
		oPlayer.m_Icon = pPlayerAoi.block.icon
		oPlayer.m_Name = pPlayerAoi.block.name
		oPlayer.m_RealName = pPlayerAoi.block.name
		oPlayer.m_FlyHeight = pPlayerAoi.block.fly_height
		oPlayer.m_OrgId = pPlayerAoi.block.org_id
		oPlayer.m_Touxian = pPlayerAoi.block.touxian_tag
		oPlayer.m_EngagePid = pPlayerAoi.block.engage_pid
		oPlayer.treasureconvoy_tag = pPlayerAoi.block.treasureconvoy_tag
		oPlayer:SetSpecailState(pPlayerAoi.block.state)
		CObject.SetName(oPlayer, string.format("e%d-p%d-%s",eid,pPlayerAoi.pid, pPlayerAoi.block.name))

		oPlayer:SetTitleHud(pPlayerAoi.block.touxian_tag)

		self.m_Players[pPlayerAoi.pid] = oPlayer
		-- 确保清除跟随的宠物和npc
		self:DelAllSummonWalker(eid)
		self.m_IntanceID2Walker[oPlayer:GetInstanceID()] = weakref(oPlayer)
		self.m_Walkers[eid] = oPlayer
		self:UpdateFollow()

		oPlayer.m_CreateTime = g_TimeCtrl:GetTimeMS()

		local model_info = pPlayerAoi.block.model_info
		if model_info then
			self:CheckPosArea(oPlayer, pPlayerAoi.pos_info)

			oPlayer:ChangeShape(model_info, callback(self, "UpdatePlayer", oPlayer))
			oPlayer:ShowWalker(false)

			g_FlyRideAniCtrl:TryFly(oPlayer)

		end

		local iWarTag = pPlayerAoi.block.war_tag
		if iWarTag then
			oPlayer:SetWarTag(iWarTag)
		end
		
		if oPlayer:GetSpecailState(define.Player.State.OrgMatchProtect) then
			oPlayer:SetName(pPlayerAoi.block.name, DataTools.GetNameColor(define.RoleColor.ORGProtect))
		elseif self:IsInOrgMatchMap() and oPlayer.m_OrgId ~= g_AttrCtrl.org_id then
			oPlayer:SetName(pPlayerAoi.block.name, DataTools.GetNameColor(define.RoleColor.ORGEnemy))
		else
			oPlayer:SetName(pPlayerAoi.block.name or "")
		end
		oPlayer:SetWearingTitle(pPlayerAoi.pid, pPlayerAoi.block.title_info)
		if pPlayerAoi.block.dance_tag then
		   if pPlayerAoi.block.dance_tag == 1  then
		   	  oPlayer.m_IsInDanceState = true
		   	  g_DancingCtrl:AddDanceTip(oPlayer,model_info.shape)
		   else
		   	  oPlayer.m_IsInDanceState = false
		   	  g_DancingCtrl:DelDanceTip(oPlayer)
		   end
		end

		local horse = pPlayerAoi.block.ride_id
		if horse then
			self:UpdatePlayerHorse(oPlayer, horse)
		end
		local follows = pPlayerAoi.block.followers
		if follows then
			for k,v in pairs(follows) do
				local objName = string.format("e%d-p%d-%s-%s",oPlayer.m_Eid, oPlayer.m_Pid, pPlayerAoi.block.name,v.name)
				self:AddSummon(v, eid, objName, pPlayerAoi.pos_info)
			end
		end

		--踩水表现
		if pPlayerAoi.block.action and pPlayerAoi.block.action[1] and pPlayerAoi.block.action[1].type == 1 then
			local oStartPos = netscene.DecodePos(pPlayerAoi.block.action[1].water_walk.start_pos)
			self:CheckPosArea(oPlayer, oStartPos)
			local oEndPos = netscene.DecodePos(pPlayerAoi.block.action[1].water_walk.end_pos)
			oPlayer:WalkTo(oEndPos.x, oEndPos.y, nil, nil, false)
		else
			self:CheckPosArea(oPlayer, pPlayerAoi.pos_info)
		end
		--printc("AddPlayer-"..oPlayer:GetName().." posX:"..pPlayerAoi.pos_info.x.." posY:"..pPlayerAoi.pos_info.y)
		--订婚表现--
		if pPlayerAoi.block.engage_pid then
			local teamID = oPlayer.m_TeamID
			self:UpdatePlayerHeart(teamID)
		end

	-- end
	if bIsExist then
		self:CheckPosArea(oPlayer, pPlayerAoi.pos_info)
	end
	self:CheckRotation(oPlayer, pPlayerAoi.pos_info)
	self:CheckWalkerHide(oPlayer)
end

function CMapCtrl.UpdateWalker(self, walker, pPlayerAoi)

	if walker == nil then
		return
	end
	walker:SetWearingTitle(walker.m_Pid, pPlayerAoi.title_info)
    if pPlayerAoi.dance_tag then
       if pPlayerAoi.dance_tag == 1 then
       	  walker.m_IsInDanceState = true
	      g_DancingCtrl:AddDanceTip(walker, walker.m_Actor:GetShape()) -- pPlayerAoi.model_info.shape
	   else
	   	  walker.m_IsInDanceState = false
		  g_DancingCtrl:DelDanceTip(walker)
	   end
	end
	local name = pPlayerAoi.name or walker.m_RealName
	local touxian = pPlayerAoi.touxian_tag or walker.m_Touxian
	local bProtectState = walker:GetSpecailState(define.Player.State.OrgMatchProtect)
	local bNewProtectState = bProtectState
	if pPlayerAoi.state then
		walker:SetSpecailState(pPlayerAoi.state)
		bNewProtectState = walker:GetSpecailState(define.Player.State.OrgMatchProtect)
		if bNewProtectState then
			walker:SetName(name, DataTools.GetNameColor(define.RoleColor.ORGProtect))
		elseif not bNewProtectState and bProtectState then
			if self:IsInOrgMatchMap() and walker.m_OrgId ~= g_AttrCtrl.org_id then
				walker:SetName(name, DataTools.GetNameColor(define.RoleColor.ORGEnemy))
			else
				walker:SetName(name)
			end
		end
		bNewProtectState = walker:GetSpecailState(define.Player.State.HFDMJinZhongZhao)
		if bNewProtectState then
			walker:AddJinZhongZhaoEffect()
		else
			walker:DelJinZhongZhaoEffect()
		end
	end
	
	if pPlayerAoi.name ~= nil then
		if bNewProtectState then
			walker:SetName(name, DataTools.GetNameColor(define.RoleColor.ORGProtect))
		elseif self:IsInOrgMatchMap() and walker.m_OrgId ~= g_AttrCtrl.org_id then
			walker:SetName(name, DataTools.GetNameColor(define.RoleColor.ORGEnemy))
		else
			walker:SetName(name)
		end
		walker:SetTitleHud(touxian)
		CObject.SetName(walker, string.format("e%d-p%d-%s", walker.m_Eid, walker.m_Pid, pPlayerAoi.name))
	end


	if pPlayerAoi.followers then
		self:DelAllSummonWalker(walker.m_Eid)
		if next(pPlayerAoi.followers) ~= nil  then 
			for k,v in pairs(pPlayerAoi.followers) do
				local objName = string.format("e%d-p%d-%s-%s", walker.m_Eid, walker.m_Pid, walker.m_Name, v.name)
				self:AddSummon(v, walker.m_Eid, objName, walker:GetLocalPos())
			end
		end
		g_FlyRideAniCtrl:UpdateLeaderFollowerDis(walker.m_Pid)
	end

	if pPlayerAoi.engage_pid then
		walker.m_EngagePid = pPlayerAoi.engage_pid
		local teamID = walker.m_TeamID
		self:UpdatePlayerHeart(teamID)
	end

	if pPlayerAoi.treasureconvoy_tag then
		walker.treasureconvoy_tag = pPlayerAoi.treasureconvoy_tag
		if walker:IsInConvoyTask() then 
			walker:SetConvoyTag()
			local defaultSpeed = g_MapCtrl:GetWalkerDefaultSpeed(true)
			local ratio = g_MiBaoConvoyCtrl:GetSpeedRatio()
			local speed = defaultSpeed * ratio
			walker:SetMoveSpeed(speed)
		else
			walker:DelConvoyTag()
			walker:SetMoveSpeed()
		end 
	end 

end

function CMapCtrl.UpdateNpcWalker(self, oNpc, pNpcAoi)
	if not oNpc then
		return
	end
	local globalNpc = DataTools.GetGlobalNpc(pNpcAoi.npctype)
	if globalNpc then
		if globalNpc.shortName and string.len(globalNpc.shortName) > 0 then
			-- local normalName = "[ADE6D8]" .. globalNpc.shortName .. "[-]\n" .. name
			oNpc:SetNpcNormalHUD(globalNpc.shortName)
		end

		if pNpcAoi.block and pNpcAoi.block.title and string.len(pNpcAoi.block.title) > 0 then
			local titleStr = pNpcAoi.block.title
			local titleSpr = nil
			local titleName = nil
			local colonIndex = string.find(titleStr, "%:")
			local strs = string.split(titleStr, "%:")
			if colonIndex and colonIndex > 0 then
				if colonIndex == 1 then
					titleName = strs[1]
				else
					if strs[1] and string.len(strs[1]) > 0 then
						titleSpr = strs[1]
					end
					if strs[2] and string.len(strs[2]) > 0 then
						titleName = strs[2]
					end
				end
			else
				if tonumber(titleStr) then
					titleSpr = titleStr
				else
					titleName = titleStr
				end
			end
			oNpc:SetNpcSpecialHud(titleName, titleSpr)
		end
	elseif pNpcAoi.block and pNpcAoi.block.title and string.len(pNpcAoi.block.title) > 0 then
		oNpc:SetNpcNormalHUD(pNpcAoi.block.title)
	end
end

--scene.proto npcAoi
function CMapCtrl.AddNpc(self, eid, pNpcAoi)
	-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "AddNpc", "添加NPC"))
	-- table.print(pNpcAoi)
	local oNpc = self:GetWalker(eid)
	if not oNpc then
		oNpc = g_MapWalkerCacheCtrl:GetCacheNpc()
		oNpc.m_Eid = eid
		oNpc:SetData(pNpcAoi)

		local iWarTag = pNpcAoi.block.war_tag
		if iWarTag then
			oNpc:SetWarTag(iWarTag)
		end
		self:SetTaskMark(oNpc)
		self:SetWenHaoMark(oNpc)
		oNpc:SetName(pNpcAoi.block.name)
		self:UpdateNpcWalker(oNpc, pNpcAoi)
		oNpc:SetWearingTitle(eid, pNpcAoi.block.title_info)
		CObject.SetName(oNpc, string.format("e%d-%s", eid, pNpcAoi.block.name))
		self.m_Npcs[pNpcAoi.npcid] = oNpc
		self.m_IntanceID2Walker[oNpc:GetInstanceID()] = weakref(oNpc)
		self.m_Walkers[eid] = oNpc

		local model_info = pNpcAoi.block.model_info
		if model_info then
			self:CheckPosArea(oNpc, pNpcAoi.pos_info)
			oNpc:ChangeShape(model_info)
		end
	end
	
	self:CheckPosArea(oNpc, pNpcAoi.pos_info)

	if self:GetIsGlobalNpcHideByNpcType(pNpcAoi.npctype) then
		-- oNpc:SetActive(false)
		-- oNpc.m_HudNode:SetActive(false)
		oNpc:ShowWalker(false)
	else
		oNpc:ShowWalker(true)
		-- oNpc:SetActive(true)
		-- oNpc.m_HudNode:SetActive(true)
	end
	self:CheckWalkerHide(oNpc)
end

function CMapCtrl.IsFuyuanNpc(self, npc)

	if not npc then
		return false
	end 

	if npc.classname ~= "CNpc" then 
		return false
	end 
	
	if npc.m_NpcAoi then 
		if npc.m_NpcAoi.func_group == "huodong.fuyuanbox" then 
			return true
		end 
	end 

end

function CMapCtrl.IsLuanShiMoYingNpc(self, npc)
	if not npc then
		return false
	end 

	if npc.classname ~= "CNpc" then 
		return false
	end 
	
	if npc.m_NpcAoi then 
		if npc.m_NpcAoi.func_group == "huodong.luanshimoying" and npc.m_NpcAoi.npctype == 2001 then 
			return true
		end 
	end 
end

function CMapCtrl.InitYanHuaEffectNode(self)
	
	self.m_YanHuaEffectNode = CObject.New(UnityEngine.GameObject.New())
	self.m_YanHuaEffectNode:SetName("Effect_YanHua_Node")
	self.m_YanHuaEffectNode:SetLocalPos(Vector3.New(0,0,80))
	self.m_YanHuaEffList = {}
	self.m_CurYanHuaNum = 0
	self.m_LimitNum = 10

end

function CMapCtrl.HideYanHuaEffects(self)
	
	for k, v in pairs(self.m_YanHuaEffList) do 
		v:SetActive(false)
	end 

end

function CMapCtrl.AddYanHuaEffect(self, path, pos)

	if not self.m_YanHuaEffectNode then 
		return
	end 

	local hero = self:GetHero()

	if not hero then 
		return
	end 

	local effect = nil

	local position = Vector3.New(pos.x, pos.y, hero:GetPos().z - 0.5)

	for k, v in pairs(self.m_YanHuaEffList) do 
		if not v:GetActive() then 
			v:SetActive(true)
			v:SetPos(position)
			local timeEnd = function ()
				v:SetActive(false)
				return false
			end
			Utils.AddTimer(timeEnd, 0, 3)	
			return
		end 
	end 

	if not effect then 
		if self.m_CurYanHuaNum < self.m_LimitNum then 
			effect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("Default"), true)
			effect:SetParent(self.m_YanHuaEffectNode.m_Transform)
			effect:SetPos(position)
			effect:SetLocalRotation(Quaternion.Euler(-30, 0, 0)) 
			effect:SetActive(true)
			local timeEnd = function ()
				effect:SetActive(false)
				return false
			end
			Utils.AddTimer(timeEnd, 0, 3)
			self.m_CurYanHuaNum = self.m_CurYanHuaNum + 1
			table.insert(self.m_YanHuaEffList, effect)
		end
	end 

end

function CMapCtrl.AddEffect(self, eid, effectAoi)
	local oEffect = self.m_Effects[eid]
	if not oEffect then
		local iEffectId = effectAoi.effect_id
		local dEffectInfo = DataTools.GetEffectData("ENTERAOI", iEffectId)
		if not dEffectInfo then
			printc("CMapCtrl.AddEffect --------- 没配置特效 ------- ", iEffectId)
			return
		end
		local path = dEffectInfo.path
		oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("MapTerrain"), true)
		oEffect.m_Eid = eid
		self.m_Effects[eid] = oEffect
		oEffect:SetParent(self.m_SceneEffectDynamicMainGo.m_Transform, false)
		local pos, rot, scale = dEffectInfo.pos, dEffectInfo.rotation, dEffectInfo.scale
		if next(pos) then	--坐标配表
			oEffect:SetPos(Vector3.New(pos[1], pos[2], pos[3]))
		else
			local posInfo = netscene.DecodePos(effectAoi.pos_info)
			self:CheckPosArea(oEffect, posInfo)
		end
		if next(rot) then
			oEffect:SetRotation(Quaternion.Euler(rot[1], rot[2], rot[3]))
		end
		if next(scale) then
			oEffect:SetLocalScale(scale[1], scale[2], scale[3])
		end
	end
end

function CMapCtrl.DelEffect(self, eid)
	local effect = self.m_Effects[eid]
	if effect == nil then
		return
	end
	effect:Destroy()
	self.m_Effects[eid] = nil
end

function CMapCtrl.AddDynamicNpc(self, dynamicNnpc)
	 --print(string.format("<color=#00FF00> >>> .%s | %s | Table:%s </color>", "AddDynamicNpc", "实例一个动态Npc", "dynamicNnpc"))
	 --table.print(dynamicNnpc)
	if self.m_IsInPlot then
		return
	end
	if g_WarCtrl:IsWar() then
		return
	end
	local clientnpc = table.copy(dynamicNnpc)
	clientnpc.pos_info = netscene.DecodePos(clientnpc.pos_info)
	if clientnpc then
		local npcid = clientnpc.npcid
		local oDynamicNpc = self:GetDynamicNpc(npcid)
		if not oDynamicNpc then
			oDynamicNpc = g_MapWalkerCacheCtrl:GetCacheDynamicNpc()
			oDynamicNpc:SetData(clientnpc)
			self:SetTaskMark(oDynamicNpc)
			if clientnpc.title then
				oDynamicNpc:SetNpcNormalHUD(clientnpc.title)
			end
			oDynamicNpc:SetName(clientnpc.name)
			CObject.SetName(oDynamicNpc, string.format("n%d-%s", npcid, clientnpc.name))
			-- printc("添加AddDynamicNpc", npcid, clientnpc.name)
			self.m_DynamicNpcs[npcid] = oDynamicNpc
			self.m_Walkers[npcid] = oDynamicNpc
			self.m_IntanceID2Walker[oDynamicNpc:GetInstanceID()] = weakref(oDynamicNpc)

			local model_info = clientnpc.model_info
			if model_info then
				self:CheckPosArea(oDynamicNpc, clientnpc.pos_info)
				oDynamicNpc:ChangeShape(model_info)
			end
		end
		self:CheckPosArea(oDynamicNpc, clientnpc.pos_info)

		local hideStatus = self:GetIsClientNpcHide(npcid)
		-- oDynamicNpc:SetActive(not hideStatus)
		-- oDynamicNpc.m_HudNode:SetActive(not hideStatus)
		oDynamicNpc:ShowWalker(not hideStatus)
		self:CheckWalkerHide(oDynamicNpc)
	end
end

function CMapCtrl.CheckNianShouNpc(self)

	local nianShouNpcList = g_NianShouCtrl:GetNianShouNpcList()
	if nianShouNpcList and next(nianShouNpcList) then 
		for k, nianShouNpc in pairs(nianShouNpcList) do
			self:AddNianShouNpc(nianShouNpc)
		end 
	end 

end


function CMapCtrl.AddNianShouNpc(self, nianShouNpc)

	if g_WarCtrl:IsWar() then
		return
	end

	if not self.m_MapID or self.m_MapID ~= nianShouNpc.map_id then 
		return
	end 

	local npcid = nianShouNpc.npcid

	local oNianShouNpc = self.m_NianShouNpcs[npcid]
	if not oNianShouNpc then
		oNianShouNpc = g_MapWalkerCacheCtrl:GetCacheNianShouNpc()
		oNianShouNpc:SetData(nianShouNpc)
		if nianShouNpc.title then
			oNianShouNpc:SetNpcNormalHUD(nianShouNpc.title)
		end
		oNianShouNpc:SetName(nianShouNpc.name)
		CObject.SetName(oNianShouNpc, string.format("n%d-%s", npcid, nianShouNpc.name))
		self.m_NianShouNpcs[npcid] = oNianShouNpc
		self.m_Walkers[npcid] = oNianShouNpc
		self.m_IntanceID2Walker[oNianShouNpc:GetInstanceID()] = weakref(oNianShouNpc)

		local model_info = nianShouNpc.model_info
		if model_info then
			self:CheckPosArea(oNianShouNpc, nianShouNpc.pos_info)
			oNianShouNpc:ChangeShape(model_info)
		end

		self:CheckPosArea(oNianShouNpc, nianShouNpc.pos_info)
		self:CheckWalkerHide(oNianShouNpc)
	end
	
end

function CMapCtrl.DelNianShouNpc(self, npcId)

	local nianShouNpc = self.m_NianShouNpcs[npcId]
	if nianShouNpc then 
		self:SafeDelWalker(nianShouNpc)
		self.m_NianShouNpcs[npcId] = nil
		self.m_IntanceID2Walker[nianShouNpc:GetInstanceID()] = nil
	end 

end

function CMapCtrl.DelAllNianShouNpc(self)
	
	if self.m_NianShouNpcs and next(self.m_NianShouNpcs) then 
		for k, nianShouNpc in pairs(self.m_NianShouNpcs) do
			self:SafeDelWalker(nianShouNpc)
			self.m_IntanceID2Walker[nianShouNpc:GetInstanceID()] = nil
		end 
	end 

	self.m_NianShouNpcs = {}

end

function CMapCtrl.AddTaskPickItem(self, taskPickThing)
	-- print(string.format("<color=#00FF00> >>> .%s | %s | Table:%s </color>", "AddTaskPickItem", "实例一个任务采集Model", "taskPickThing"))
	-- table.print(taskPickThing)
	if self.m_IsInPlot then
		return
	end
	if g_WarCtrl:IsWar() then
		return
	end
	local pickThing = table.copy(taskPickThing)
	if pickThing then
		local pickInfo = {
			mapid = pickThing.map_id,
			pickid = pickThing.pickid,
			pos_info = {x = pickThing.pos_x, y = pickThing.pos_y},
		}

		local pickid = pickInfo.pickid
		local pickItem = DataTools.GetTaskPick(pickid)
		local modelid = pickItem.modelid
		local oTaskPickItem = self:GetTaskPickItem(pickid)
		if not oTaskPickItem then
			oTaskPickItem = g_MapWalkerCacheCtrl:GetCacheTaskPickItem()
			oTaskPickItem.m_PickInfo = pickInfo
			oTaskPickItem:SetName(pickItem.name)
			CObject.SetName(oTaskPickItem, string.format("n%s-%s", modelid, pickItem.name))
			self.m_TaskPickItems[pickid] = oTaskPickItem
			self.m_Walkers[pickid] = oTaskPickItem
			self.m_IntanceID2Walker[oTaskPickItem:GetInstanceID()] = weakref(oTaskPickItem)

			local model_info = {}
			model_info.shape = pickItem.modelid
			oTaskPickItem:ChangeShape(model_info)
		end
		self:CheckPosArea(oTaskPickItem, pickInfo.pos_info)
		self:CheckWalkerHide(oTaskPickItem)
	end
end

function CMapCtrl.StopSyncPos(self, stop)
	
	self.m_StopSyncPos = stop

end

function CMapCtrl.SyncPos(self, eid, pPosInfo)

	if self.m_StopSyncPos then 
		return
	end 

	local oWalker = self:GetWalker(eid)
	if not oWalker then
		return
	end

	if oWalker.m_IsFlyWaterProgress then
		return
	end
	if oWalker.classname == "CNpc" then
		oWalker:ResetPosInfo(pPosInfo)
	end
	oWalker:WalkTo(pPosInfo.x, pPosInfo.y)

	-- printc(oWalker:GetName().." posX:"..pPosInfo.x.." posY:"..pPosInfo.y)
end

function CMapCtrl.SetTaskMark(self, oWalker)
	if oWalker then
		local npcMark = nil
		if oWalker.classname == "CNpc" then
			npcMark = g_TaskCtrl:GetNpcAssociatedTaskMark(oWalker.m_NpcAoi.npctype, oWalker.m_NpcAoi.func_group)
		elseif oWalker.classname == "CDynamicNpc" then
			npcMark = g_TaskCtrl:GetNpcAssociatedTaskMark(oWalker.m_ClientNpc.npctype, oWalker.m_ClientNpc.func_group)
		end
		-- if npcMark then			
		-- end
		oWalker:SetTaskMark(npcMark)
	end
end

function CMapCtrl.RefreshTaskNpcMark(self)
	for _,v in pairs(self.m_Npcs) do
		self:SetTaskMark(v)
	end
	for _,v in pairs(self.m_DynamicNpcs) do
		self:SetTaskMark(v)
	end
end

function CMapCtrl.SetWenHaoMark(self, oWalker)
	
	if oWalker.classname == "CNpc" then 
		local jiebaiState = g_JieBaiCtrl:GetJieBaiState()
		if jiebaiState == define.JieBai.State.InYiShi then
			local aoi = oWalker.m_NpcAoi
			if aoi.func_group == "huodong.jiebai" then 
				local yishiState = g_JieBaiCtrl:GetCurYiShiState()
				if yishiState == define.JieBai.YiShiState.Open then 
					if aoi.npctype == 1001 then 
						oWalker:SetWenHaoMark(true)
					end 
				else
					if aoi.npctype == 1002 then 
						oWalker:SetWenHaoMark(true)
					end 
				end 
			end
		end 
	end 

end

function CMapCtrl.RefreshSpecityTaskNpcMark(self, npctype, func_group, markID)
	local npcMark = g_TaskCtrl:GetNpcMarkSprName(markID)
	--这里表示必定刷新标识，有标识则刷对应标识，没有则去掉标识
	-- if npcMark then
	-- end
	for _,oNpc in pairs(self.m_Npcs) do
		if npctype == oNpc.m_NpcAoi.npctype and (func_group == nil or func_group == "globalNpc" or func_group == oNpc.m_NpcAoi.func_group) then
			oNpc:SetTaskMark(npcMark)
			return
		end
	end
	for _,oNpc in pairs(self.m_DynamicNpcs) do
		if npctype == oNpc.m_ClientNpc.npctype and (func_group == nil or func_group == "globalNpc" or func_group == oNpc.m_ClientNpc.func_group) then
			oNpc:SetTaskMark(npcMark)
			return
		end
	end	
end

function CMapCtrl.DelAllDynamicNpc(self)
	if self.m_DynamicNpcs and next(self.m_DynamicNpcs) then
		for k,v in pairs(self.m_DynamicNpcs) do
			self:DelDynamicNpc(k)
		end
	end
end

function CMapCtrl.DelDynamicNpc(self, npcid)
	local oWalker = self:GetWalker(npcid)
	if oWalker then
		if oWalker.classname == "CDynamicNpc" then
			self.m_DynamicNpcs[npcid] = nil
			self.m_Walkers[npcid] = nil
			self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil
			self:SafeDelWalker(oWalker)
		else
			printerror("CMapCtrl.DelDynamicNpc 警告：不是动态Npc，请检查流程是否错误")
		end
	end
end

function CMapCtrl.DelTaskPickItem(self, pickid)
	local oWalker = self:GetWalker(pickid)
	if oWalker then
		if oWalker.classname == "CTaskPickItem" then
			self.m_TaskPickItems[pickid] = nil
			self.m_Walkers[pickid] = nil
			self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil
			self:SafeDelWalker(oWalker)
		else
			printerror("CMapCtrl.DelTaskPickItem 警告：不是动态采集物品，请检查流程是否错误")
		end
	end
end

function CMapCtrl.StopAoiWalker(self, state)
 	
	self.m_StopAoiWalker = state

 end 

function CMapCtrl.DelWalker(self, eid)
	local oWalker = self:GetWalker(eid)
	if oWalker then
		-- 这里注意下，顺序问题，由于下面的操作会删除npcGO，因此特效播放提前到上面
		-- 判断一下距离之外的不需要做特效
		local walkerPos = oWalker:GetPos()
		if self:GetHero() then
			local heroPos = self:GetHero():GetPos()
			if (heroPos.x - walkerPos.x)^2 + (heroPos.y - walkerPos.y)^2 < 25 then
				if oWalker:GetLayer() ~= UnityEngine.LayerMask.NameToLayer("Hide") then 
					self:MapFadeEffect(oWalker, walkerPos, function ()
						-- printc("===== 场景Npc过渡转场特效结束啊")
					end)
				end
			end
		end

		if oWalker.m_Pid then
			self.m_Players[oWalker.m_Pid] = nil 
			g_MapPlayerNumberCtrl:RemoveShowList(oWalker.m_Pid)
			local iTeam = oWalker.m_TeamID
			self.m_TeamMissPlayers[oWalker.m_Pid] = iTeam
		elseif oWalker.classname == "CNpc" then
			local npcid = oWalker.m_NpcAoi.npcid
			self.m_Npcs[npcid] = nil
		elseif oWalker.classname == "CDynamicNpc" then
			local npcid = oWalker.m_ClientNpc.npcid
			self.m_DynamicNpcs[npcid] = nil
		elseif oWalker.classname == "CTaskPickItem" then
			local pickid = oWalker.m_PickInfo.pickid
			self.m_TaskPickItems[pickid] = nil
		end
		if self.m_Walkers[eid] then
			self.m_Walkers[eid] = nil
		end
		self.m_IntanceID2Walker[oWalker:GetInstanceID()] = nil
		if oWalker.m_Followers ~= nil then 
			for k,v in pairs(oWalker.m_Followers) do
				self:SafeDelWalker(v)
			end
		end
		self:SafeDelWalker(oWalker)

		if oWalker.m_FolowOrderList then
			oWalker.m_FolowOrderList = {}
		end
		self:UpdateFollow()
	end
end

function CMapCtrl.DelSummonWalker(self, shape, eid)
	if eid == nil then 
		eid = self.m_Hero.m_Eid
	end
	local oMainWalker = self:GetWalker(eid)
	if not oMainWalker then
		return
	end
	if oMainWalker.m_Followers then
		local oWalker = oMainWalker.m_Followers[shape]
		if oWalker then
			if oWalker.m_Pid and self:GetPlayer(oWalker.m_Pid).m_Followers then
				self:GetPlayer(oWalker.m_Pid).m_Followers[shape] = nil	
			end
			if oMainWalker.m_Followers then 
				oMainWalker.m_Followers[shape] = nil
			end
			self:SafeDelWalker(oWalker)
		end
	end
	if oMainWalker.m_FolowOrderList then
		for k,v in pairs(oMainWalker.m_FolowOrderList) do
			if v[2] == shape then
				table.remove(oMainWalker.m_FolowOrderList, k)
				break
			end
		end
	end
end


function CMapCtrl.DelAllSummonWalker(self, eid)

	if eid == nil then 
		if self.m_Hero then
			eid = self.m_Hero.m_Eid	
		end
		if not eid then
			return
		end	
	end
	local oWalker = self:GetWalker(eid)
	if not oWalker then
		return
	end
	if oWalker.m_Followers then
		for k,v in pairs(oWalker.m_Followers) do
			if v.m_Pid and self:GetPlayer(v.m_Pid).m_Followers then
				self:GetPlayer(v.m_Pid).m_Followers = {}
			end
			--需要特殊表现的条件
			if k == self.m_SpecialFollowShape and self.m_SpecialFollowHide then
				self.m_SpecialFollowHide = false
				local function onStop()
					v:Destroy()
				end
				g_ViewCtrl:CloseAll(g_ViewCtrl.m_SumSpecialFollowCloseAllNeedList)
				g_NotifyCtrl:ShowDisableWidget(true, "目送坐骑离开，请稍候~")
				v:Follow(nil)
				v:ShowCloudEffect(true)
				local oHero = g_MapCtrl:GetHero()
				v.m_Walker:WalkTo3(oHero:GetPos().x+7, oHero:GetPos().y+3)
				v.m_StopCallback = onStop

				if self.m_EndTimer then
					Utils.DelTimer(self.m_EndTimer)
					self.m_EndTimer = nil			
				end
				local function progress()
					g_NotifyCtrl:ShowDisableWidget(false)
					return false
				end	
				self.m_EndTimer = Utils.AddTimer(progress, 1, 4)
			else			
				self:SafeDelWalker(v)
			end
		end
		oWalker.m_Followers = {}
	end
	if oWalker.m_FolowOrderList then
		oWalker.m_FolowOrderList = {}
	end
end

function CMapCtrl.SafeDelWalker(self, oWalker)
	if g_MapWalkerCacheCtrl:IsInCache(oWalker:GetInstanceID()) then
		g_MapWalkerCacheCtrl:RecyleCacheWalker(oWalker)
	else
		oWalker:Destroy()
	end
end

function CMapCtrl.CheckTranserArea(self, pos)
	if not self.m_TransferAreas then
		if self.m_CurMapObj then
			self.m_TransferAreas = self.m_CurMapObj.m_MapCompnent:GetTransfer()
		end
	end
	if self.m_TransferAreas then
		for k, v in pairs(self.m_TransferAreas) do
			if pos.x >= v[1] and pos.x <= v[2] and pos.y >= v[3] and pos.y <= v[4] then
				local function reset()
					if self.m_TransferAreas and #self.m_TransferAreas == 0 then
						self.m_TransferAreas = nil
					end
				end
				self.m_ResetTransferTimer = Utils.AddTimer(reset, 0, 5)
				self.m_TransferAreas = {}
				return k
			end
		end
	end
end

function CMapCtrl.UpdateTeam(self, iTeamID, lPid)
	local list = self.m_Teams[iTeamID]
	if list then
		-- self:RemoveTeam(iTeamID)
		--需要去掉离队的成员
		local tTemp = {}
		local bIsUpdateLeader = list[1] ~= lPid[1]
		if not bIsUpdateLeader then
			for k, pid in pairs(lPid) do
				tTemp[pid] = true
			end
			for index, pid in ipairs(list) do
				if not tTemp[pid] then
					self:DelTeamMember(pid)
				end
			end
		else
			self:RemoveTeam(iTeamID)
		end

	end
	self.m_Teams[iTeamID] = lPid
	for i, pid in ipairs(lPid) do
		self.m_TeamMissPlayers[pid] = iTeamID
	end
	self:UpdateFollow()
	self:UpdatePlayerHeart(iTeamID)
	if list then 
		local id = g_FlyRideAniCtrl:UpdateMissTeamMember(list, lPid)
		g_MapPlayerNumberCtrl:HandleTeamEvent(nil,id)
	end

end

function CMapCtrl.DelTeamMember(self, iPid)
	--printc("删除队员ID："..iPid)
	local oPlayer = self:GetPlayer(iPid)
	if oPlayer then
		oPlayer.m_TeamID = nil		
		oPlayer:DelBindObj("team_leader")
		oPlayer:Follow(nil)
	end
	self:HidePlayerHeart(iPid) --若有订婚标记，离队后需隐藏
	self.m_TeamMissPlayers[iPid] = nil
end

function CMapCtrl.RemoveTeam(self, iTeamID)
	--printc("队伍移除"..iTeamID)
	local list = self.m_Teams[iTeamID]
	if list then
		for i, pid in pairs(list) do
			self:DelTeamMember(pid)
		end
	end
	self.m_Teams[iTeamID] = nil
end

function CMapCtrl.GetTeamLeader(self, pid)
	
	local tId = self:GetWalkerTeamId(pid)
	if tId then
		local pList = self.m_Teams[tId]
		local leaderId = pList[1]
		local walker = self:GetPlayer(leaderId)
		return walker
	end 

end

function CMapCtrl.FindFrontMember(self, pid)
	
	local tId = self:GetWalkerTeamId(pid)
	if tId then
		local pList = self.m_Teams[tId]
		local index = nil
		for k, id in ipairs(pList) do 
			if id == pid then 
				index = k
			end 
		end 
		local id = pList[index-1]
		if id then 
			return self.m_Players[id]
		end
		
	end 

end

function CMapCtrl.GetTeamMemberList(self, pid)
	
	local tId = self:GetWalkerTeamId(pid)
	if tId then
		local member = {}
		local pList = self.m_Teams[tId]
		for k, id in ipairs(pList) do 
			local walker = self:GetPlayer(id)
			table.insert(member, walker)	
		end 
		return member
	end 

end

function CMapCtrl.FindNextFollower(self, pid)

	local tId = self:GetWalkerTeamId(pid)
	if tId then
		local pList = self.m_Teams[tId]
		local index = nil
		for k, id in ipairs(pList) do 
			if id == pid then 
				index = k
			end 
		end 
		local id = pList[index+1]
		local walker = self:GetPlayer(id)
		return walker
	end 

end

function CMapCtrl.FindLastMember(self, pid)

	local tId = self:GetWalkerTeamId(pid)
	if tId then
		local pList = self.m_Teams[tId]
		local index = #pList
		local lastId = pList[index]
		if lastId then 
			local walker = self:GetPlayer(lastId)
			return walker
		end 
	end

end

function CMapCtrl.GetTeamMemberListByTeamId(self, tId)
	
	if tId then
		local member = {}
		local pList = self.m_Teams[tId]
		for k, id in ipairs(pList) do 
			local walker = self:GetPlayer(id)
			table.insert(member, walker)	
		end 
		return member
	end 

end

function CMapCtrl.GetWalkerTeamId(self, pid)

	local player = self:GetPlayer(pid)
	if player then 
		return player.m_TeamID
	end  

end

function CMapCtrl.IsWalkerInTeam(self, pid)
	
	local player = self:GetPlayer(pid)
	if player then 
		return player.m_TeamID
	end 
	
end

function CMapCtrl.IsLeaderSelf(self, pid)
	
	local tId = self:GetWalkerTeamId(pid)
	if tId then
		local pList = self.m_Teams[tId]
		return pid == pList[1]
	end 

end

function CMapCtrl.IsHeroMember(self, walker)
	
	local hero = self:GetHero()
	if hero and hero.m_TeamID then 
		if hero.m_TeamID == walker.m_TeamID then 
			return true
		end 
	end 

end

function CMapCtrl.GetFollowWalker(self, pid)
	
	if self:IsLeaderSelf(pid) then 
		return
	end

	local tId = self:GetWalkerTeamId(pid)
	if tId then
		local pList = self.m_Teams[tId]
		local index = nil
		for k, id in ipairs(pList) do 
			if id == pid then 
				index = k
			end 
		end 
		local id = pList[index-1]
		local walker = self:GetPlayer(id)	
		return walker
	end 

end

function CMapCtrl.IsLeaderInFlyState(self, pid)
	
	local leader = self:GetTeamLeader(pid)
	if leader then 
		if leader.m_FlyHeight == define.FlyRide.FlyState.Fly then 
			return true
		end 
	end 

	return 

end

function CMapCtrl.GetNearWalkablePos(self, walker)
 	if self.m_Map2DComponent then
 		local wx = walker:GetPos().x
    	local wy = walker:GetPos().y
 		local vNearPos = self.m_Map2DComponent:GetNearWalkablePos(wx, wy)
 		if vNearPos.x >= 0 and vNearPos.y >= 0 then
 			return vNearPos
 		end
 	end
	local mapInfo = DataTools.GetMapInfo(self.m_MapID)
	return Vector2.New(mapInfo.fly_pos[1], mapInfo.fly_pos[2])
end

function CMapCtrl.UpdateFollow(self)

	--因队伍跟随距离， 暂时屏蔽
	-- if not self.m_CurMapObj then
	-- 	return
	-- end

	local dNeedUpdate = {}
	for pid, iTeamID in pairs(self.m_TeamMissPlayers) do
		if self.m_Players[pid] then
			dNeedUpdate[iTeamID] = true
			self.m_TeamMissPlayers[pid] = nil
		end
	end
	for iTeamID,_ in pairs(dNeedUpdate) do
		local followPlayer = nil
		local lPid = self.m_Teams[iTeamID]
		for i, pid in ipairs(lPid) do
			local oPlayer = self:GetPlayer(pid)
			if oPlayer then
				oPlayer.m_TeamID = iTeamID
				if followPlayer then
					oPlayer:ChangeFollow(followPlayer)
					followPlayer = oPlayer
				else
					followPlayer = oPlayer
					if (i == 1) then
						oPlayer:AddBindObj("team_leader")
					end
				end
			end
		end
	end
end

--更新队伍内订婚玩家表现
function CMapCtrl.UpdatePlayerHeart(self, teamID)
	
	local couplelist = {}
	local singlelist = {}
	local team = self.m_Teams[teamID]
	if not team then
		return
	end
	
	for i, pid in ipairs(team) do
		-- 已存在列表内则跳过
		if not table.index(couplelist, pid) then
			local oPlayer = self:GetPlayer(pid)
			if oPlayer then
				if oPlayer.m_EngagePid then --玩家存在且有订婚对象
					local engagePid = oPlayer.m_EngagePid
					local index = table.index(team, engagePid) --订婚对象也在队伍中
					if index then
						table.insert(couplelist, pid)
						table.insert(couplelist, engagePid)
					else
						table.insert(singlelist, pid)
					end
				else
					table.insert(singlelist, pid)
				end
			end
		end
	end

	for i, pid in ipairs(singlelist) do
		self:HidePlayerHeart(pid)
	end

	for i, pid in ipairs(couplelist) do
		self:ShowPlayerHeart(i, pid)
	end
end

function CMapCtrl.ShowPlayerHeart(self, idx, pid)
	for i, v in ipairs(self.m_EngagedHeartPlayers) do
		if v == pid then
			return
		end
	end

	local oPlayer = self:GetPlayer(pid)
	
	if idx < 3 then
		idx = 1
	else
		idx = 2
	end
	
	if oPlayer then
		oPlayer:SetHeart(idx, true)
		table.insert(self.m_EngagedHeartPlayers, pid)
	end
end

function CMapCtrl.HidePlayerHeart(self, pid)
	local idx = nil
	for i, v in ipairs(self.m_EngagedHeartPlayers) do
		if v == pid then
			local oPlayer = self:GetPlayer(pid)
			if oPlayer then
				oPlayer:SetHeart(1, false)
				oPlayer:SetHeart(2, false)
				idx = i
				break
			end
		end
	end
	if idx then
		table.remove(self.m_EngagedHeartPlayers, idx)
	end
end

function CMapCtrl.GetAutoPatrolPos(self)
	if not next(self.m_AutoPatrolLists) then
		local t = datauser.patroldata.DATA[self.m_ResID]
		if t then
			t = table.copy(t)
			self.m_AutoPatrolLists = table.shuffle(t)
		end
	end
	if self.m_AutoPatrolLists and next(self.m_AutoPatrolLists) then
		local pos = self.m_AutoPatrolLists[1]
		table.remove(self.m_AutoPatrolLists, 1)
		return pos
	end
	return g_MapCtrl:GetPatrolRandomPos()
end

function CMapCtrl.IsAutoPatrolMap(self)
	return datauser.patroldata.DATA[self.m_ResID] ~= nil
end

function CMapCtrl.SetAutoPatrol(self, bPatrol, bFree, bNotHeroMove)
	if self.m_IsAutoPatrol and not bPatrol then
		netopenui.C2GSXunLuo(0)
	end
	self.m_IsAutoPatrol = bPatrol
	--任意地图都可挂机，只是控制可以挂机的地图
	self.m_IsAutoPatrolFree = bFree
	if not bNotHeroMove then
		self:CheckAutoPatrol()
	end
end

function CMapCtrl.CheckAutoPatrol(self)
	local oHero = self:GetHero()
	if oHero then
		if oHero:IsAutoPatroling() ~= self.m_IsAutoPatrol then
			if self.m_IsAutoPatrol then
				oHero:StartAutoPatrol(self.m_IsAutoPatrolFree)
			else
				oHero:StopAutoPatrol()
			end
		end
	end
end

function CMapCtrl.GetRandomPos(self)
	local pos = {}
	pos.x = Mathf.Random(0, 50)
	pos.y = Mathf.Random(0, 50)
	return pos
end

function CMapCtrl.GetPatrolRandomPos(self)
	local pos = {}
	local mapData = DataTools.GetMapInfo(self.m_MapID)
	pos.x = Mathf.Random(mapData.fly_pos[1]-5, mapData.fly_pos[1]+5)
	pos.y = Mathf.Random(mapData.fly_pos[2]-5, mapData.fly_pos[2]+5)
	return pos
end

function CMapCtrl.ClearFootPoint(self)
	local hero = self:GetHero()
	if hero then
		hero:StopWalk()
		self:OnEvent(define.Map.Event.ClearFootPoint)
	end
end

function CMapCtrl.C2GSClickWorldMap(self, mapid)
	if g_LimitCtrl:CheckIsCannotMove() then
		return
	end
	-- 需要在当前地图也能飞
	-- if mapid == self.m_MapID then
	-- 	return
	-- end
	local oHero = self:GetHero()
	if oHero then
		netscene.C2GSClickWorldMap(self:GetSceneID(), oHero.m_Eid, mapid)
	end
end

-- 场景过渡特效
function CMapCtrl.MapFadeEffect(self, oWalker, vPos, cb)
	-- if oWalker then
	-- 	oWalker.m_HudNode:SetActive(false)
	-- 	oWalker:SetActive(false)
	-- 	local path = "Effect/Scene/scene_eff_0004/Prefabs/scene_eff_0004.prefab"
	-- 	local oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("MapTerrain"), true)
	-- 	oEffect:SetPos(vPos)
	-- 	oEffect:SetParent(nil)
	-- 	local function timeup()
	-- 		if cb then cb() end
	-- 		if Utils.IsNil(oEffect) then
	-- 			return false
	-- 		end
	-- 		oEffect:Destroy()
	-- 	end
	-- 	Utils.AddTimer(timeup, 0, 0.8)
	-- elseif cb then
	--延迟0.1s避免IO堵塞
	Utils.AddTimer(cb, 0, 0.1)
	-- end
end

function CMapCtrl.GetSpecialConfig(self, filename)
	local path = "Map2d/ConfigData/"..filename..".bytes"
	if Utils.IsEditor() and not IOTools.IsExist(IOTools.GetGameResPath("/"..path)) then
		printc("CMapCtrl.GetSpecialConfig==>警告：当前不存在的配置数据，请检查是否错误文件路径",IOTools.GetGameResPath("/"..path))
		return {}
	end
	local bytes = g_ResCtrl:Load(path)
	if not bytes then
		printc("警告：当前不存在的配置数据，请检查是否错误文件路径", path)
		return {}
	end

	local strs = tostring(bytes)
	local configData = {}
	local lowData = {}
	local col = 1
	local i = 0
	for i=1,string.len(strs) do
		local value = string.sub(strs, i, i)
		if value == "\n" then
			table.insert(configData, lowData)
			lowData = {}
			col = col+1
		else
			table.insert(lowData, string.sub(strs, i, i))
		end
	end
	return configData
end

function CMapCtrl.CheckInLingxiArea(self, oWalker)
	if not g_LingxiCtrl.m_Taskid or not oWalker or g_LingxiCtrl.m_Phase ~= 4
	or not g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid] or not g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid]:GetSValueByKey("clientnpc")[1] then
		return false
	end
	local bIsInArena = false
	local heroPos = oWalker:GetPos()
	local encodePos = netscene.EncodePos(heroPos)
	local oClientNpcData = g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid]:GetSValueByKey("clientnpc")[1]
	local radius = data.lingxidata.GLOBAL[1].trigger_flower_grow_radius
	local seedPos = oClientNpcData.pos_info
	if self.m_MapID == oClientNpcData.map_id and math.abs(encodePos.x - seedPos.x) <= radius*1000 and math.abs(encodePos.y - seedPos.y) <= radius*1000 then
		bIsInArena = true
	end
	return bIsInArena
end

function CMapCtrl.CheckInLingxiSeedArea(self, oWalker)
	if g_LingxiCtrl.m_Phase <= 0 then
		return false
	end
	if not g_LingxiCtrl.m_Taskid or not oWalker or g_LingxiCtrl.m_Phase > 3
	or not g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid] or not g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid]:GetSValueByKey("taskitem")[1] then
		return false
	end
	local bIsInArena = false
	local heroPos = oWalker:GetPos()
	local encodePos = netscene.EncodePos(heroPos)
	local oTaskItemData = g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid]:GetSValueByKey("taskitem")[1]
	if self.m_MapID == oTaskItemData.map_id and  math.abs(encodePos.x - oTaskItemData.pos_x*1000) <= oTaskItemData.radius*1000 and math.abs(encodePos.y - oTaskItemData.pos_y*1000) <= oTaskItemData.radius*1000 then
		bIsInArena = true
	end
	return bIsInArena
end

function CMapCtrl.CheckInDanceArea(self, oWalker)
	if not oWalker then
		return false
	end	
	if oWalker.m_IsDestroy then
		return false
	end
	local bIsInArena = false
	local mapData = DataTools.GetMapInfo(self:GetMapID())
	if mapData.id then
		local pos = oWalker:GetPos()
		local arenaData = self.m_MapDanceData[mapData.resource_id]
		if arenaData then
			local low = math.floor(pos.y*3.125) --pos.y/0.32
			low = #arenaData - low
			local row = math.floor(pos.x*3.125)

			if arenaData[low] and arenaData[low][row] == "1" then
				bIsInArena = true
			end
		end
	end
	if oWalker == self:GetHero() and oWalker.m_IsInDance ~= bIsInArena then
		-- g_MapCtrl:UpdateHeroPos()
		self:OnEvent(define.Map.Event.CheckHeroInDance, bIsInArena)
		if bIsInArena then
			g_NotifyCtrl:FloatMsg("你已经进入舞动全城活动区域")
			g_DancingCtrl:IsShowDanceIcon(bIsInArena, true)
		end
	end 
	return bIsInArena
end

function CMapCtrl.CheckInArenaArea(self, oWalker)
	if not oWalker then
		return false
	end
	local bIsInArena = false
	local mapData = DataTools.GetMapInfo(self:GetMapID())
	if mapData.id then
		local pos = oWalker:GetPos()
		local arenaData = self.m_MapArenaData[mapData.resource_id]
		if arenaData then
			local low = math.floor(pos.y*3.125) --pos.y/0.32
			low = #arenaData - low
			local row = math.floor(pos.x*3.125)

			if arenaData[low] and arenaData[low][row] == "1" then
				bIsInArena = true
			end
		end
	end
	if oWalker == self:GetHero() and oWalker.m_IsInArena ~= bIsInArena then
		self:OnEvent(define.Map.Event.CheckHeroInArena, bIsInArena)
		if bIsInArena then
			g_NotifyCtrl:FloatMsg("你已经进入擂台比武区域")
		end
	end 
	return bIsInArena
end

function CMapCtrl.InitArenaData(self, resid)
	if resid ~= 1010 then
		-- 非主城场景一律过滤擂台数据加载
		return
	end
	if self.m_MapArenaData[resid] then
		return
	end
	self.m_MapArenaData[resid] = self:GetSpecialConfig("arena_"..resid)
end

function CMapCtrl.CheckInWaterPointDataArea(self, oWalker)
	--暂时屏蔽
	if true then return false end

	if not oWalker then
		return false
	end
	local bIsInWaterPoint = false
	local mapData = DataTools.GetMapInfo(self:GetMapID())
	if mapData.id then
		local pos = oWalker:GetPos()
		local waterPointData = self.m_MapWaterPointData[mapData.resource_id]
		if waterPointData and next(waterPointData) then
			local low = math.floor(pos.y*3.125) --pos.y/0.32
			low = #waterPointData - low
			local row = math.floor(pos.x*3.125)

			if waterPointData[low] and waterPointData[low][row] == "1" then
				bIsInWaterPoint = true
			end
		end
	end
	return bIsInWaterPoint
end

function CMapCtrl.CheckInWaterPointArea(self, oWalker)
	--暂时屏蔽
	if true then return false end
	
	if not oWalker then
		return false
	end
	local bIsInWaterPoint = false
	local mapData = DataTools.GetMapInfo(self:GetMapID())
	if mapData.id then
		local pos = oWalker:GetPos()
		local waterPointData = self.m_MapWaterPointData[mapData.resource_id]
		if waterPointData and next(waterPointData) then
			local low = math.floor(pos.y*3.125) --pos.y/0.32
			low = #waterPointData - low
			local row = math.floor(pos.x*3.125)

			if waterPointData[low] and waterPointData[low][row] == "1" then
				bIsInWaterPoint = true
			end
		end
	end
	if not oWalker.m_IsInWaterPoint and oWalker.m_IsInWaterPoint ~= bIsInWaterPoint then
		-- self:OnEvent(define.Map.Event.CheckHeroInWaterPoint, bIsInWaterPoint)
		-- if bIsInWaterPoint then
		-- printc("你已经进入踩水传送点区域", oWalker.m_IsInWaterPoint, " ", bIsInWaterPoint)
		-- g_NotifyCtrl:FloatMsg("你已经进入踩水传送点区域")

		local wantPoint, dumpPoint, originIndex = self:GetRelativeWaterPoint(mapData.resource_id, oWalker:GetPos().x, oWalker:GetPos().y)
		if not wantPoint then
			printerror("踩水没有相应点坐标关系数据")
			return bIsInWaterPoint
		end
		if not (oWalker.m_OriginIndex and oWalker.m_OriginIndex == originIndex) then
			if not oWalker.m_IsFlyWaterProgress then
				local oWaterConfig = self:GetMapWaterConfig(mapData.resource_id, wantPoint)
				if not oWaterConfig then
					printerror("踩水没有water的配置数据")
					return bIsInWaterPoint
				end
				if oWalker then
					if oWalker.m_FollowTimer then
						Utils.DelTimer(oWalker.m_FollowTimer)
						oWalker.m_FollowTimer = nil
					end
					if oWalker.m_IsFollowing then
						oWalker.m_RecordFollowTarget = oWalker.m_FollowTarget
						oWalker.m_RecordFollowDis = oWalker:GetWalkerFollowDis()
						-- printc("1111111111111", oWalker.m_GameObject.name, oWalker.m_RecordFollowDis)
						oWalker:Follow(nil)
					end

					if oWalker.classname == "CHero" then
						netscene.C2GSStartWaterWalk(oWaterConfig.id)
					end
					
					oWalker.m_OriginIndex = originIndex
					oWalker.m_IsFlyWaterProgress = true

					if not oWalker.m_CurHeroSpeed then
						oWalker.m_CurHeroSpeed = oWalker.m_Walker.moveSpeed
					end
					oWalker.m_Walker.moveSpeed = (oWalker.m_CurHeroSpeed > 5 and 2.7 or 2.7) + 2  --oWalker.m_CurHeroSpeed

					if oWalker.m_Followers then
						for k,v in pairs(oWalker.m_Followers) do
							v.m_Walker.moveSpeed = oWalker.m_Walker.moveSpeed
							--暂时屏蔽
							-- v:ShowWaterEffect(true)
							if v.m_WaterCheckTimer then
								Utils.DelTimer(v.m_WaterCheckTimer)
								v.m_WaterCheckTimer = nil			
							end
							local function onCheck()
								if Utils.IsNil(v) then
									return false
								end
								if g_MapCtrl:CheckInWaterPointDataArea(v) then
									local tweenPath = DOTween.DOLocalPath(v.m_Actor.m_Transform, self.m_JumpPosList, 0.4, 0, 0, 10, nil)
									v:ShowWaterEffect(true)
									return false
								end
								return true
							end
							v.m_WaterCheckTimer = Utils.AddTimer(onCheck, 0, 0)
						end
					end

					if oWalker.classname == "CHero" then
						self.m_IsFlyWaterProgress = true
						-- g_NotifyCtrl:ShowDisableWidget(true)
						oWalker:SyncPosByPoint(wantPoint.x, wantPoint.y, true)						

						if not oWalker.m_RecordTargetPos and oWalker.m_TargetPos then
							-- printc("踩水开始前记录的点", oWalker.m_TargetPos.x, " ", oWalker.m_TargetPos.y)
							oWalker.m_RecordTargetPos = oWalker.m_TargetPos
						end				
					end

					oWalker:WalkTo(wantPoint.x, wantPoint.y, nil, nil, false)

					local function onEnd()
						oWalker:ShowWaterEffect(true)
					end
					
					local tweenPath = DOTween.DOLocalPath(oWalker.m_Actor.m_Transform, self.m_JumpPosList, 0.4, 0, 0, 10, nil)
					DOTween.OnComplete(tweenPath, onEnd)
					DOTween.SetDelay(tweenPath, 0)					
				end
			else
				oWalker.m_OriginIndex = nil
				-- if self.m_WaterTimer then
				-- 	Utils.DelTimer(self.m_WaterTimer)
				-- 	self.m_WaterTimer = nil			
				-- end
				-- local function progress()
				-- 	return false
				-- end
				-- self.m_WaterTimer = Utils.AddTimer(progress, 0, 1)

				if oWalker.classname == "CHero" then
					local function onStop()
						oWalker.m_IsFlyWaterProgress = false
						if oWalker.classname == "CHero" then
							self.m_IsFlyWaterProgress = false
							-- g_NotifyCtrl:ShowDisableWidget(false)
						end

						if oWalker.m_RecordFollowTarget then
							if g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeave() then
								-- printc("222222222222", oWalker.m_GameObject.name, oWalker.m_RecordFollowDis)
								oWalker:Follow(oWalker.m_RecordFollowTarget, oWalker.m_RecordFollowDis)
							end
							oWalker.m_RecordFollowTarget = nil
							oWalker.m_RecordFollowDis = nil
						end

						if oWalker.classname == "CHero" then
							if oWalker.m_RecordTargetPos then
								if self:CheckIsInWaterLine(oWalker.m_RecordTargetPos) then
									oWalker.m_RecordTargetPos = nil
								end
								if oWalker.m_RecordTargetPos then
									if oWalker.m_NotDelAutoFlag then
										oWalker:AddBindObj("auto_find")
									end
									-- printc("需要继续跑到的点", oWalker.m_RecordTargetPos.x, " ", oWalker.m_RecordTargetPos.y)
									oWalker:WalkTo(oWalker.m_RecordTargetPos.x, oWalker.m_RecordTargetPos.y, nil, nil, false)
								end
								oWalker.m_RecordTargetPos = nil
							end
						end

						-- self:UpdateFollow()
					end
					oWalker.m_NotDelAutoFlag = oWalker.m_Huds["auto_find"].obj ~= nil
					oWalker.m_StopCallback = onStop
				end

				if oWalker then
					oWalker:ShowWaterEffect(false)
					if oWalker.m_CurHeroSpeed then
						oWalker.m_Walker.moveSpeed = oWalker.m_CurHeroSpeed
						oWalker.m_CurHeroSpeed = nil
					end

					if oWalker.m_Followers then
						for k,v in pairs(oWalker.m_Followers) do
							v.m_Walker.moveSpeed = oWalker.m_Walker.moveSpeed--g_MapCtrl:GetWalkerDefaultSpeed(false)
							--暂时屏蔽
							-- v:ShowWaterEffect(false)
							if v.m_WaterCheckTimer1 then
								Utils.DelTimer(v.m_WaterCheckTimer1)
								v.m_WaterCheckTimer1 = nil			
							end
							local function onCheck()
								if Utils.IsNil(v) then
									return false
								end
								if g_MapCtrl:CheckInWaterPointDataArea(v) then
									local vet = {Vector3.New(0, 0, 0), Vector3.New(0, 0.7, 0), Vector3.New(0, 0, 0)}
									local tweenPath = DOTween.DOLocalPath(v.m_Actor.m_Transform, vet, 0.4, 0, 0, 10, nil)
									v:ShowWaterEffect(false)
									return false
								end
								return true
							end
							v.m_WaterCheckTimer1 = Utils.AddTimer(onCheck, 0, 0)
						end
					end
					
					if oWalker.classname ~= "CHero" then
						oWalker.m_IsFlyWaterProgress = false

						if oWalker.m_FollowTimer then
							Utils.DelTimer(oWalker.m_FollowTimer)
							oWalker.m_FollowTimer = nil			
						end
						local function progress()
							if Utils.IsNil(oWalker) then
								return false
							end
							if oWalker.m_IsFlyWaterProgress then
								return false
							end
							--暂时屏蔽
							-- local isInTeam
							-- if oWalker.classname == "CPlayer" then
							-- 	isInTeam = g_MapCtrl:IsWalkerInTeam(oWalker.m_Pid) --g_TeamCtrl:IsInTeam(oWalker.m_Pid)
							-- else
							-- 	isInTeam = true
							-- end
							if oWalker.m_RecordFollowTarget then
								-- if isInTeam then
									-- printc("222222222222", oWalker.m_GameObject.name, oWalker.m_RecordFollowDis)
									oWalker:Follow(oWalker.m_RecordFollowTarget, oWalker.m_RecordFollowDis)
								-- end
								oWalker.m_RecordFollowTarget = nil
								oWalker.m_RecordFollowDis = nil
							end
							-- self:UpdateFollow()
							return false
						end	
						oWalker.m_FollowTimer = Utils.AddTimer(progress, 0, 3)

						local function onStop()
							if oWalker.m_FollowTimer then
								Utils.DelTimer(oWalker.m_FollowTimer)
								oWalker.m_FollowTimer = nil			
							end
							--暂时屏蔽					
							-- local isInTeam
							-- if oWalker.classname == "CPlayer" then
							-- 	isInTeam = g_MapCtrl:IsWalkerInTeam(oWalker.m_Pid) --g_TeamCtrl:IsInTeam(oWalker.m_Pid)
							-- else
							-- 	isInTeam = true
							-- end
							if oWalker.m_RecordFollowTarget then								
								-- if isInTeam then
									-- printc("222222222222", oWalker.m_GameObject.name, oWalker.m_RecordFollowDis)
									oWalker:Follow(oWalker.m_RecordFollowTarget, oWalker.m_RecordFollowDis)
								-- end
								oWalker.m_RecordFollowTarget = nil
								oWalker.m_RecordFollowDis = nil
							end
							-- self:UpdateFollow()
						end
						oWalker.m_StopCallback = onStop
					end

					local vet = {Vector3.New(0, 0, 0), Vector3.New(0, 0.7, 0), Vector3.New(0, 0, 0)}
					local tweenPath = DOTween.DOLocalPath(oWalker.m_Actor.m_Transform, vet, 0.4, 0, 0, 10, nil)
				end				
			end
		end		
		-- end
	end 
	return bIsInWaterPoint
end

function CMapCtrl.InitWaterPointData(self, resid)
	-- if resid ~= 1003 then
	-- 	-- 非西湖场景一律过滤踩水数据加载
	-- 	return
	-- end
	if self.m_MapWaterPointData[resid] then
		return
	end
	self.m_MapWaterPointData[resid] = self:GetSpecialConfig("water_"..resid)
end

function CMapCtrl.GetRelativeWaterPoint(self, resid, oHeroX, oHeroY)
	
	local index = 1
	local pointTable = nil
	if not self.m_WaterPosCfg[resid] then
		return nil, nil
	end
	for k,v in pairs(self.m_WaterPosCfg[resid]) do
		for g,h in pairs(v) do
			if math.abs(oHeroX - h[1].x) < 5 and math.abs(oHeroY - h[1].y) < 5 then
				index = g
				pointTable = v
				break
			end
		end
	end
	if not pointTable then
		return nil, nil
	end
	if index == 1 then
		return pointTable[2][1], pointTable[1][2], index
	else
		return pointTable[1][1], pointTable[2][2], index
	end
end

function CMapCtrl.GetMapWaterConfig(self, resid, oPos)
	for k,v in pairs(data.mapdata.WATERWALK) do
		if resid*100 == v.map and v.dest_x == oPos.x and v.dest_y == oPos.y then
			return v
		end
	end
end

----------------踩水路线信息------------------
function CMapCtrl.InitWaterLineData(self, resid)
	-- if resid ~= 1003 then
	-- 	-- 非西湖场景一律过滤踩水路线数据加载
	-- 	return
	-- end
	if self.m_MapWaterLineData[resid] then
		return
	end
	self.m_MapWaterLineData[resid] = self:GetSpecialConfig("waterline_"..resid)
end

function CMapCtrl.CheckIsInWaterLine(self, oWalkerPos)
	--暂时屏蔽
	if true then return false end

	local bIsInWaterLine = false
	local mapData = DataTools.GetMapInfo(self:GetMapID())
	if mapData.id then
		local waterLineData = self.m_MapWaterLineData[mapData.resource_id]
		if waterLineData and next(waterLineData) then
			local low = math.floor(oWalkerPos.y*3.125) --oWalkerPos.y/0.32
			low = #waterLineData - low
			local row = math.floor(oWalkerPos.x*3.125)

			if waterLineData[low] and waterLineData[low][row] == "1" then
				bIsInWaterLine = true
			end
		end
	end
	return bIsInWaterLine
end

-- function CMapCtrl.CheckWaterPointBelongArea(self, resid, oHeroX, oHeroY)
-- 	local list = { [1030] = { {Vector2.New(15, 13), Vector2.New(20.5, 17)} } }
-- 	for k,v in pairs(list[resid]) do
-- 		if math.min(v[1].x, v[2].x) <= oHeroX and math.max(v[1].x, v[2].x) >= oHeroX 
-- 		and math.min(v[1].y, v[2].y) <= oHeroY and math.max(v[1].y, v[2].y) >= oHeroY then
-- 		return true
-- 		end
-- 	end
-- 	return false
-- end

function CMapCtrl.InitDanceData(self, resid)
	if resid ~= 1010 then
		-- 非主城场景一律过滤跳舞数据加载
		return
	end
	if self.m_MapDanceData[resid] then
		return
	end
	self.m_MapDanceData[resid] = self:GetSpecialConfig("dance_"..resid)
end

function CMapCtrl.GetArenaPlayerList(self)
	local list = {}
	for k,oPlayer in pairs(self.m_Players) do
		if not oPlayer.m_TeamID and self:CheckInArenaArea(oPlayer) and oPlayer.m_Pid ~= g_AttrCtrl.pid then
			table.insert(list, oPlayer.m_Pid)
		end
	end
	return list
end

function CMapCtrl.GetArenaTeamList(self)
	local list = {}
	for k,oPlayer in pairs(self.m_Players) do
		if oPlayer.m_TeamID and self.m_Teams[oPlayer.m_TeamID][1] == oPlayer.m_Pid 
			and oPlayer.m_TeamID ~= g_TeamCtrl.m_TeamID and self:CheckInArenaArea(oPlayer) then
			table.insert(list, oPlayer.m_Pid)
		end
	end
	return list
end

function CMapCtrl.GetTeamInfo(self, iTeamID)
	return self.m_Teams[iTeamID]
end


--------------以下是任务表现新加的---------------

function CMapCtrl.GS2CLoginVisibility(self, pbdata)
	local npcs = pbdata.npcs --额外的npc可见性
	local scene_effects = pbdata.scene_effects --额外的场景特效可见性
	local npc_appears = pbdata.npc_appears --常驻npc形象更变

	self.m_NpcVisibilityList = {}
	self.m_SceEffectVisibilityList = {}
	for k,v in pairs(npcs) do
		self.m_NpcVisibilityList[k] = v
	end
	for k,v in pairs(scene_effects) do
		self.m_SceEffectVisibilityList[k] = v
	end

	self.m_GlobalNpcChangeInfo = {}
	table.copy(npc_appears, self.m_GlobalNpcChangeInfo)

	self:SetSelfGlobalNpcChange()

	--只处理了全局npc
	self:SetGlobalNpcActive()
	self:SetSceneEffectActive()
	-- table.print(pbdata, "CMapCtrl.GS2CLoginVisibility")
end

--value为0表示不显示，为1表示显示
function CMapCtrl.GS2CChangeVisibility(self, pbdata)
	local npcs = pbdata.npcs --额外的npc可见性
	local scene_effects = pbdata.scene_effects --额外的场景特效可见性
	local npc_appears = pbdata.npc_appears --新增的常驻npc形象更变

	for k,v in pairs(npcs) do
		self:CheckNpcVisibilityList(v)
	end
	for k,v in pairs(scene_effects) do
		self:CheckSceEffectVisibilityList(v)
	end
	for k,v in pairs(npc_appears) do
		self:CheckGlobalNpcChangeInfo(v)
	end

	self:SetSelfGlobalNpcChange()

	--只处理了全局npc
	self:SetGlobalNpcActive()
	self:SetSceneEffectActive()
	-- table.print(pbdata, "CMapCtrl.GS2CChangeVisibility")
end

--open 0 是关闭, 1 是开启
function CMapCtrl.GS2CSetGhostEye(self, pbdata)
	local open = pbdata.open --是否开启
	self.m_IsGhostEyeOpen = open

	--处理了全局npc和临时npc
	if self.m_IsGhostEyeOpen == 1 then
		local oView = CGhostEyeView:GetView()
		if oView then
			self:OnEvent(define.Map.Event.SetGhostEye)
		else
			CGhostEyeView:ShowView(function (oView)
				oView:ShowGhostContent()
			end)
		end
	else
		local oView = CGhostEyeView:GetView()
		if oView then
			oView:SetCloseEffect()
		end
		-- CGhostEyeView:CloseView()
		self:SetGlobalNpcActive()
		self:SetClientNpcActive()
	end
	-- table.print(pbdata, "CMapCtrl.GS2CSetGhostEye")
end

function CMapCtrl.GS2CLoginGhostEye(self, pbdata)
	local open = pbdata.open --是否开启
	self.m_IsGhostEyeOpen = open

	--处理了全局npc和临时npc
	if self.m_IsGhostEyeOpen == 1 then
		local function delay()
			CGhostEyeView:ShowView(function (oView)
				oView:ShowGhostContent(true)
			end)
			return false
		end
		Utils.AddTimer(delay, 0, 1)
		
		self:SetGlobalNpcActive()
		self:SetClientNpcActive()
	else
		CGhostEyeView:CloseView()
		self:SetGlobalNpcActive()
		self:SetClientNpcActive()
	end
	-- table.print(pbdata, "CMapCtrl.GS2CLoginGhostEye")
end

--npc特写协议返回
function CMapCtrl.GS2CShowNpcCloseup(self, pbdata)
	if pbdata.npctype ~= 0 then
		--暂时屏蔽
		-- CNpcCloseUpView:ShowView(function (oView)
		-- 	oView:RefreshUI(pbdata)
		-- end)
		-- self.m_IsNpcCloseUp = true
		-- g_NotifyCtrl:SetFloatTableActive(false)
	elseif pbdata.parnter ~= 0 or pbdata.summon ~= 0 then	
		if not g_MapCtrl.m_IsNpcNeedShowInGuide and not g_GuideCtrl:IsGuideDone() then			
			g_GuideCtrl:AddEndCallbackList(function ()
				CNpcShowView:ShowView(function (oView)
					oView:RefreshUI(pbdata)
				end)
			end)
		else
			CNpcShowView:ShowView(function (oView)
				oView:RefreshUI(pbdata)
			end)
			self.m_IsNpcCloseUp = true
			g_NotifyCtrl:SetFloatTableActive(false)
			g_SummonCtrl:OnEvent(define.Summon.Event.ShowSummonCloseup, pbdata)
		end
		g_MapCtrl.m_IsNpcNeedShowInGuide = false
	end
end

-----------------以下是一些数据的管理-------------------

function CMapCtrl.AddNpcShowCbList(self, cb)
	table.insert(self.m_NpcShowEndCbList, cb)
end

function CMapCtrl.CheckNpcVisibilityList(self, oData)
	local isExist = false
	for k,v in pairs(self.m_NpcVisibilityList) do
		if v.id == oData.id then
			v.value = oData.value
			isExist = true
			break
		end
	end
	if not isExist then
		table.insert(self.m_NpcVisibilityList, oData)
	end
end

function CMapCtrl.CheckSceEffectVisibilityList(self, oData)
	local isExist = false
	for k,v in pairs(self.m_SceEffectVisibilityList) do
		if v.id == oData.id then
			v.value = oData.value
			isExist = true
			break
		end
	end
	if not isExist then
		table.insert(self.m_SceEffectVisibilityList, oData)
	end
end

--只针对全局npc,现在隐藏有两个地方:m_NpcVisibilityList, visible
function CMapCtrl.GetIsGlobalNpcHideByNpcType(self, npctype)

	-- if self:GetNpcByType(npctype).m_NpcAoi.ghost_eye == 1 then
	-- 	if self.m_IsGhostEyeOpen == 1 then
	-- 		return false
	-- 	else
	-- 		return true
	-- 	end
	-- end
	for k,v in pairs(self.m_NpcVisibilityList) do
		if npctype == v.id and v.value == 0 then
			return true
		elseif npctype == v.id and v.value == 1 then
			return false
		end
	end
	-- if self:GetNpcByType(npctype) and self:GetNpcByType(npctype).m_NpcAoi.visible == 0 then
	-- 	return true
	-- end
	if data.npcdata.NPC.GLOBAL_NPC[npctype] and data.npcdata.NPC.GLOBAL_NPC[npctype].visible == 0 then
		return true
	end
	return false
end

--只针对临时npc
function CMapCtrl.GetIsClientNpcHide(self, npcid)
	if self:GetDynamicNpc(npcid) and self:GetDynamicNpc(npcid).ghost_eye == 1 then
		if self.m_IsGhostEyeOpen == 1 then
			return false
		else
			return true
		end
	end
	return false
end

function CMapCtrl.GetIsSceEffectHide(self, sceEffectId)
	for k,v in pairs(self.m_SceEffectVisibilityList) do
		if sceEffectId == v.id and v.value == 0 then
			return true
		elseif sceEffectId == v.id and v.value == 1 then
			return false
		end
	end
	if data.mapdata.SCENEEFFECT[sceEffectId] and data.mapdata.SCENEEFFECT[sceEffectId].visible == 0 then
		return true
	end
	return false
end

function CMapCtrl.CheckGlobalNpcChangeInfo(self, oData)
	local otherdata = oData
	printc("CheckGlobalNpcChangeInfo otherdata.title:", otherdata.title)
	local isExist = false
	for k,v in pairs(self.m_GlobalNpcChangeInfo) do
		if v.npctype == otherdata.npctype then
			v.reset = otherdata.reset
			v.figure = otherdata.figure
			v.title = otherdata.title
			isExist = true
			break
		end
	end
	if not isExist then
		table.insert(self.m_GlobalNpcChangeInfo, otherdata)
	end
end

function CMapCtrl.ClearVisibilityAll(self)
	self.m_NpcVisibilityList = {}
	self.m_SceEffectVisibilityList = {}
	self.m_GlobalNpcChangeInfo = {}
	self.m_IsGhostEyeOpen = 0
	self.m_IsNpcCloseUp = false
	self.m_NpcShowEndCbList = {}
	self.m_IsNpcNeedShowInGuide = false
end

-----------------以下是处理npc和特效的显示和隐藏--------------------

function CMapCtrl.SetGlobalNpcActive(self)
	for k,oNpc in pairs(self.m_Npcs) do
		if self:GetIsGlobalNpcHideByNpcType(oNpc.m_NpcAoi.npctype) then
			-- oNpc:SetActive(false)
			-- oNpc.m_HudNode:SetActive(false)
			oNpc:ShowWalker(false)
		else
			oNpc:ShowWalker(true)
			-- oNpc:SetActive(true)
			-- oNpc.m_HudNode:SetActive(true)
		end
	end	
end

function CMapCtrl.SetClientNpcActive(self)
	for k,oNpc in pairs(self.m_DynamicNpcs) do
		if self:GetIsClientNpcHide(oNpc.m_ClientNpc.npcid) then
			-- oNpc:SetActive(false)
			-- oNpc.m_HudNode:SetActive(false)
			oNpc:ShowWalker(false)
		else
			oNpc:ShowWalker(true)
			-- oNpc:SetActive(true)
			-- oNpc.m_HudNode:SetActive(true)
		end
	end	
end

function CMapCtrl.ClearMapDynamicEffect(self)
	if self.m_SceneEffectDynamicMainGo then
		if not Utils.IsNil(self.m_SceneEffectDynamicMainGo) then
			self.m_SceneEffectDynamicMainGo:Destroy()
		end
		self.m_SceneEffectDynamicMainGo = nil
	end
end

--创建场景的动态特效，每个场景不一样
function CMapCtrl.AddSceneEffect(self)
	if self.m_SceneEffectDynamicMainGo then
		if not Utils.IsNil(self.m_SceneEffectDynamicMainGo) then
			self.m_SceneEffectDynamicMainGo:Destroy()
		end
		self.m_SceneEffectDynamicMainGo = nil
	end
	if next(self.m_SceneEffectGoList) then
		for k,v in pairs(self.m_SceneEffectGoList) do
			if not Utils.IsNil(v) then
				v:Destroy()
			end
		end
		self.m_SceneEffectGoList = {}
	end
	self.m_SceneEffectDynamicMainGo = CObject.New(UnityEngine.GameObject.New())
	self.m_SceneEffectDynamicMainGo:SetLocalPos(Vector3.New(0,0,90))
	self.m_SceneEffectDynamicMainGo.m_GameObject.name = "MapDynamicEffect"..self:GetMapID()
	-- printc("CMapCtrl.AddSceneEffect", self:GetMapID())
	for k,v in pairs(data.mapdata.SCENEEFFECT) do
		if self:GetMapID() == v.map and not self.m_SceneEffectGoList[v.id] then
			local path = string.format("Effect/"..v.directory.."/%s/Prefabs/%s.prefab", v.resid, v.resid)
			local oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("MapTerrain"), true, function(oEff)
				oEff.m_Eff:GetMissingComponent(classtype.ParticleAndAnimation):PlaySelfAndAllChildren(oEff.m_Eff.m_GameObject, true)
				oEff:SetParent(self.m_SceneEffectDynamicMainGo.m_Transform, false)
				oEff:SetPos(Vector3.New(v.x, v.y, 90))
			end)	

			self.m_SceneEffectGoList[v.id] = oEffect
		end
	end

	self:SetSceneEffectActive()
end

function CMapCtrl.SetSceneEffectActive(self)
	for k,v in pairs(self.m_SceneEffectGoList) do
		if not Utils.IsNil(v) then
			if self:GetIsSceEffectHide(k) then
				v:SetActive(false)
			else
				v:SetActive(true)
			end
		end
	end	
end

function CMapCtrl.SetAllMapEffectActive(self, bActive, isConsiderDynamic)
	local isEff = g_SystemSettingsCtrl:GetCurImage() or true
	-- 传送阵显示bug
	-- if self.m_CurMapObj then
	-- 	self.m_CurMapObj.m_MapCompnent:SetMapEffectGoActive(bActive and isEff)
	-- end
	--动态特效不能屏蔽，跟任务关联，但是也可设置isConsiderDynamic强行屏蔽
	if isConsiderDynamic then
		if self.m_SceneEffectDynamicMainGo then
			self.m_SceneEffectDynamicMainGo:SetActive(bActive and isEff)
		end
	end
end


---------------设置全局npc造型改变(个人可见)--------

function CMapCtrl.SetSelfGlobalNpcChange(self)
	for k,v in pairs(self.m_GlobalNpcChangeInfo) do
		local npc = self:GetNpcByType(v.npctype)
		if npc then
			-- table.print(v, "CMapCtrl.SetSelfGlobalNpcChange data")
			-- printc("CMapCtrl.SetSelfGlobalNpcChange npc存在"..v.npctype)
			if v.figure then
				local model_info = {}
				model_info.figure = v.figure
				npc:ChangeShape(model_info)
			end
			if v.title then
				local titleStr = v.title
				local titleSpr = nil
				local titleName = nil
				local colonIndex = string.find(titleStr, "%:")
				local strs = string.split(titleStr, "%:")
				if colonIndex and colonIndex > 0 then
					if colonIndex == 1 then
						titleName = strs[1]
					else
						if strs[1] and string.len(strs[1]) > 0 then
							titleSpr = strs[1]
						end
						if strs[2] and string.len(strs[2]) > 0 then
							titleName = strs[2]
						end
					end
				else
					if tonumber(titleStr) then
						titleSpr = titleStr
					else
						titleName = titleStr
					end
				end
				npc:SetNpcSpecialHud(titleName, titleSpr)
			end
		else
			printc("CMapCtrl.SetSelfGlobalNpcChange npc不存在"..v.npctype)
		end
	end
end

---------------新手特殊表现--------------

function CMapCtrl.GS2CConfigTaskFollowNpc(self, pbdata)
	self.m_SpecialFollowShape = pbdata.shape
	if pbdata.config == 1 then
		self.m_SpecialFollowShow = true
	elseif pbdata.config == 2 then
		self.m_SpecialFollowHide = true
	end
end

function CMapCtrl.GS2CNpcBubbleTalk(self, pbdata)
	local oNpc = g_MapCtrl:GetNpc(pbdata.npcid)
	if not oNpc then
		oNpc = g_MapCtrl:GetDynamicNpc(pbdata.npcid)
	end
	if oNpc then
		oNpc:ChatMsg(pbdata.msg, (pbdata.timeout ~= 0 and {pbdata.timeout} or {nil})[1])
	end
end

------------------------地图类型判断------------------------------
function CMapCtrl.IsInOrgMatchMap(self)
	return self.m_MapID == g_OrgMatchCtrl.m_PreMapId or self.m_MapID == g_OrgMatchCtrl.m_MatchMapId
end

--踩水地图
function CMapCtrl.IsInWaterMap(self)
	return self.m_MapID and self.m_MapID == 103000
end

function CMapCtrl.IsInSingleBiwuMap(self)
	return g_SingleBiwuCtrl.m_BiwuMapId == self.m_MapID
end

function CMapCtrl.IsInJieBaiMap(self)
	
	return self.m_MapID and self.m_MapID == 510000

end

--秘宝护送
function CMapCtrl.IsInMiBaoConvoyMap(self)

	return self.m_MapID and self.m_MapID == 800010

end

function CMapCtrl.IsInHuodongMap(self)

	return self.m_ShowNpcInMiniMap[self.m_MapID]

end 

function CMapCtrl.GetHuodongNpcInfo(self)

	local funKey = self.m_ShowNpcInMiniMap[self.m_MapID]
	if funKey then 
		return self[funKey]()
	end 

end 

function CMapCtrl.OnThreeBiWu(self)

	return g_ThreeBiwuCtrl:GetHuodongNpcInfo()

end 


function CMapCtrl.OnLiuMai(self)

	return g_SchoolMatchCtrl:GetHuodongNpcInfo()

end 

function CMapCtrl.OnPK(self)

	return g_PKCtrl:GetHuodongNpcInfo()

end 

function CMapCtrl.OnOrgMatchPrepare(self)

	return g_OrgMatchCtrl:GetHuodongNpcInfo(true)


end 

function CMapCtrl.OnOrgMatchBattle(self)

	return g_OrgMatchCtrl:GetHuodongNpcInfo(false)

end 

function CMapCtrl.OnSingleWar(self)

	return g_SingleBiwuCtrl:GetHuodongNpcInfo()

end 
----------------贴心管家相关-----------------

function CMapCtrl.CheckIsInActivityMap(self)
	if not self.m_MapID then
		return false
	end
	local oConfig = data.mapdata.MAP[self.m_MapID]
	if not oConfig then
		return false
	end
	if oConfig.virtual_game ~= "" and oConfig.virtual_game ~= "org" then
		return true
	elseif oConfig.virtual_game ~= "" and oConfig.virtual_game == "org" then
		--帮派的活动
		for k,v in pairs({1018, 1020}) do
			local limitScheduelData = g_ScheduleCtrl:GetPreviewScheduleData(v)
			if limitScheduelData and limitScheduelData.state == 2 then
				return true
			end
		end	
	end
	return false
end


--场景特效
function CMapCtrl.SetMapEffectActive(self, active)
	
	active = active or g_SystemSettingsCtrl:GetSceneEffectState()
	if self.m_CurMapObj then
		self.m_CurMapObj.m_MapCompnent:SetMapEffectNodeActive(active)
		--临时强制开启 
		--self.m_CurMapObj.m_MapCompnent:SetMapEffectNodeActive(true)
	end
	
end

--note:部分活动地图不允许组队
function CMapCtrl.IsTeamAllowed(self)
	return not self:IsInSingleBiwuMap()
end

----------------- 结婚相关 --------------
function CMapCtrl.InitMarryAreaData(self, resid)
	if resid ~= 1010 then
		return
	end
	if not self.m_MarryAreaData[resid] then
		self.m_MarryAreaData[resid] = self:GetSpecialConfig("marry_"..resid)
	end
end

function CMapCtrl.CheckInMarryArea(self, posInfo)
	if not posInfo then
		return false
	end
	local mapData = DataTools.GetMapInfo(self:GetMapID())
	if mapData.id then
		local marryArea = self.m_MarryAreaData[mapData.resource_id]
		if not marryArea then
			return false
		end
		local rank = math.floor(posInfo.y*3.125)
		rank = #marryArea - rank
		local row = math.floor(posInfo.x*3.125)
		if marryArea[rank] and marryArea[rank][row] == "1" then
			return true
		end
	end
	return false
end

function CMapCtrl.CheckWalkerHide(self, oWalker)
	if self.m_HideWalkerFlag then
		oWalker:ShowWalker(false)
		-- 设置隐藏标签，用于恢复
		oWalker[self.m_HideWalkerFlag] = true
	end
end

function CMapCtrl.SetMarryWalkersShow(self, bShow)
	self.m_HideWalkerFlag = not bShow and "hideByMarry" or nil
	for i, oWalker in pairs(self.m_Walkers) do
		self:ShowMerryWalker(oWalker, bShow, false)
		if oWalker.m_Followers then
			for i, v in pairs(oWalker.m_Followers) do
				self:ShowMerryWalker(v, bShow, true)
			end
		end
	end
end

function CMapCtrl.ShowMerryWalker(self, oWalker, bShow, bFollow)
	if bShow then
		if oWalker.hideByMarry then
			oWalker.hideByMarry = false
			if bFollow then
				g_FlyRideAniCtrl:ShowSummon(oWalker)
			 	g_FlyRideAniCtrl:ShowFollowNpc(oWalker)
			else
				oWalker:ShowWalker(true)
			end
		end
	else
		oWalker:ShowWalker(false)
		oWalker.hideByMarry = true
	end
end

function CMapCtrl.IsMarryArea(self, objPos)
	-- if g_MarryCtrl:IsInMyWedding() then
	return self:CheckInMarryArea(objPos)
	-- end
	-- return false
end

----------------------------地图玩家相关的GS2C--------------------------------------------------------
function CMapCtrl.GS2CSyncAoi(self, scene_id, eid, type, aoi_player_block, aoi_npc_block)
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	if g_MapCtrl.m_StopAoiWalker then 
		return
	end 
	local oWalker = g_MapCtrl:GetWalker(eid)
	if not oWalker then
		printc("服务器发来GS2CSyncAoi,客户端不存在oWalker")
		return
	end
	local block
	if type == 1 then
		block = g_NetCtrl:DecodeMaskData(aoi_player_block, "PlayerAoiBlock")
		if oWalker.m_Pid and oWalker.m_Pid == g_AttrCtrl.pid then
			g_AttrCtrl:UpdateAttr({model_info = block.model_info})
		end
		g_MapCtrl:UpdateWalker(oWalker, block)
	elseif type == 2 then
		block = g_NetCtrl:DecodeMaskData(aoi_npc_block, "NpcAoiBlock")

		--设置自己可见的全局npc的造型信息
		for k,v in pairs(g_MapCtrl.m_GlobalNpcChangeInfo) do
			if v.npctype == oWalker.m_NpcAoi.npctype then
				if v.figure and v.figure ~= 0 then
					block.model_info.shape = data.modeldata.CONFIG[v.figure].model
				end
				if v.title and v.title ~= "" then
					block.title = v.title
				end
			end
		end

		block.block = block
		g_MapCtrl:UpdateNpcWalker(oWalker, block)
	end

	if block.model_info and  block.fly_height then 
		--状态同时变化
		if oWalker then 
			oWalker.m_FlyHeight = block.fly_height
			oWalker:ChangeShape(block.model_info, function ()
				g_FlyRideAniCtrl:TryFly(oWalker, false)
			end)
		end 
	else
		if block.model_info then
			local model_info = table.copy(block.model_info)
			oWalker:ChangeShape(model_info)	
		end
		if block.fly_height then 
			oWalker.m_FlyHeight = block.fly_height
			g_FlyRideAniCtrl:TryFly(oWalker, true)
		end 
	end 

	if block.war_tag then
		oWalker:SetWarTag(block.war_tag)
	end
end

function CMapCtrl.GS2CSyncPos(self, scene_id, eid, pos_info)
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	g_MapCtrl:SyncPos(eid, netscene.DecodePos(pos_info))
end

function CMapCtrl.GS2CSyncPosQueue(self, scene_id, eid, poslist)
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	local iLen = #poslist
	if iLen > 0 then
		g_MapCtrl:SyncPos(eid, netscene.DecodePos(poslist[iLen].pos))
	end
end

function CMapCtrl.GS2CAutoFindPath(self, pbdata)
	if CTaskHelp.GetClickTaskExecute() then
		g_TaskCtrl.m_ClickTaskAutoFindData = pbdata
	end
	--延时1帧执行寻路操作
	local function warp()
		g_MapCtrl:AutoFindPath(pbdata)
	end
	Utils.AddTimer(warp, 0, 0)
end

return CMapCtrl
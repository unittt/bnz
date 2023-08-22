local CMapTouchCtrl = class("CMapTouchCtrl", CDelayCallBase)

function CMapTouchCtrl.ctor(self)
	CDelayCallBase.ctor(self)
	self.m_LayerMask = UnityEngine.LayerMask.GetMask("MapTerrain", "MapWalker")
	self.m_TouchEffects = {} --缓存几个
	for _,v in pairs(define.Map.TouchType) do
		self.m_TouchEffects[v.Name] = {}
	end
	-- 地图点击特效数据（每次地图检查一次）
	self.m_MapTouchEffData = {}
	self.m_CrossMapInfo = nil
	self.m_LastMapWalker = nil

	self.m_TouchEffectList = {}

	--时间间隔
	self.m_TimeInterval = 0.4
	self.m_PastTime = 0
	self.m_2FingerDis = 0

	self.m_FloatTimer = Utils.AddTimer(callback(self, "TimerCb"), 0, 0)

	self.m_IsOnLongTab = false

	self.m_TabTime = 0

	self.m_TabTimeInterval = 1
	
end

function CMapTouchCtrl.OnTouchDown2Fingers(self, touchPos_1, touchPos_2)
	-- printc("OnTouchDown2Fingers", touchPos_1, touchPos_2, Vector2.Distance(touchPos_1, touchPos_2))	
	self.m_2FingerDis = Vector2.Distance(touchPos_1, touchPos_2)
end

function CMapTouchCtrl.OnTouchUp2Fingers(self, touchPos_1, touchPos_2)
	-- printc("OnTouchUp2Fingers", touchPos_1, touchPos_2, Vector2.Distance(touchPos_1, touchPos_2))	
	if g_MainMenuCtrl:IsMaskHandle() or self.m_2FingerDis <= 0 then
		return
	end
	local dis = Vector2.Distance(touchPos_1, touchPos_2)
	if dis > self.m_2FingerDis + 100 then
		g_MainMenuCtrl:HideAreas(define.MainMenu.HideConfig.Default)
	elseif dis < self.m_2FingerDis - 100 then
		g_MainMenuCtrl:ShowAllArea()
	end
end

--清空点击状态
function CMapTouchCtrl.ClearState(self)
	self.m_LongTabState = false
	self.m_IsTouchDown = false
	self.m_TabTime = 0
end

function CMapTouchCtrl.TimerCb(self, t)

	local Mousepos = UnityEngine.Input.mousePosition
	if self.m_IsTouchDown then 
		self.m_TabTime = self.m_TabTime + t
		if self.m_TabTime > self.m_TabTimeInterval then 
			if not self.m_LongTabState then 
				self.m_LongTabState = true
			end 	
		end 
	end 

	if self.m_LongTabState then 
		self.m_PastTime = self.m_PastTime + t
		if self.m_PastTime > self.m_TimeInterval then 
			self:OnTouchHandle(Mousepos)
			self.m_PastTime = 0	
		end 
	end 

	return true

end


function CMapTouchCtrl.OnTouchDown(self, touchPos)

	self.m_IsTouchDown = true

end

function CMapTouchCtrl.OnTouchUp(self, touchPos)

	self.m_LongTabState = false
	self.m_IsTouchDown = false
	self.m_TabTime = 0
	self:OnTouchHandle(touchPos)

end

function CMapTouchCtrl.OnTouchHandle(self, touchPos)

	if g_GuideHelpCtrl.m_GuideInfoInit then
		if not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("hasplay") and not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("notplay") then
			return
		end
	end
	if g_GuideHelpCtrl:CheckTaskGuideState() then
		return
	end
	if g_LimitCtrl:CheckIsCannotMove() then
		return
	end

	if g_EngageCtrl:CheckIsCannotMove() then
		return
	end

	g_TeamCtrl:SetLeaderTouchUI(true)
	g_UITouchCtrl:NotTouchUI()
	g_SystemSettingsCtrl:StartCheckClick(true)
	g_ScheduleCtrl:SetStopNotifyTime()
	g_TaskCtrl:SetTaskIntervalNotifyTime()
	local oHero = g_MapCtrl:GetHero()
	if not Utils.IsExist(oHero) then-- or not oHero:IsCanWalk() then
		return
	end
	if oHero.m_IsFlyWaterProgress then
		return
	end
	local lTouch = C_api.EasyTouchHandler.SelectMultiple(g_CameraCtrl:GetMainCamera().m_Camera, touchPos.x, touchPos.y, self.m_LayerMask)
	if not lTouch or #lTouch == 0 then
		return
	end
	local iCnt = #lTouch / 2
	local mapWalker = nil
	local func = nil
	local iOffsetDis = nil
	local vTerrianPos = nil
	local oToucWalker = nil
	local iMinY = nil
	local oWalkList = {}
	local pop = true
	for i=1, iCnt do
		local go, point = lTouch[i*2-1], lTouch[i*2]
		-- oNpcList
		if go.layer == define.Layer.MapTerrain then
			vTerrianPos = point
			if pop then
				pop = false
			end
			break
		elseif go.layer == define.Layer.MapWalker and not self.m_LongTabState then
			local ref = g_MapCtrl.m_IntanceID2Walker[go:GetInstanceID()]
			local oWalker = getrefobj(ref)
			
			if oWalker then
				if oWalker.classname ~= "CHero" then
					table.insert(oWalkList, oWalker)
				end
				-- if oWalker.classname == "CPlayer" then
				-- 	local y = oWalker:GetPos().y
				-- 	if not iMinY then
				-- 		iMinY = y + 1
				-- 	end
				-- 	if y < iMinY then
				-- 		iMinY = y
				-- 		mapWalker = oWalker:GetPos()--point
				-- 		iOffsetDis = define.Walker.Npc_Talk_Distance
				-- 		oToucWalker = oWalker
				-- 	end
				-- elseif oWalker.classname == "CNpc" or oWalker.classname == "CDynamicNpc" or oWalker.classname == "CTaskPickItem" then
				-- 	mapWalker = oWalker:GetPos()
				-- 	func = function()
				-- 		if Utils.IsExist(oWalker) and oWalker.Trigger then
				-- 			oWalker:Trigger()
				-- 		end
				-- 	end
				-- 	iOffsetDis = define.Walker.Npc_Talk_Distance
				-- 	oToucWalker = oWalker
				-- 	break
				-- end
				if pop then
					pop = false
				end
			end
		end
	end

	if pop then
		return
	end

	local function commonExecute()
		if oToucWalker and oToucWalker.OnTouch  then
			if not oHero:IsCanWalk() then
				if oToucWalker.classname == "CPlayer" then
					oToucWalker:OnTouch()
				end
				return
			end
			oToucWalker:OnTouch()
		end

		if self.m_WalkTimer then
			Utils.DelTimer(self.m_WalkTimer)
			self.m_WalkTimer = nil			
		end
        
        if g_LimitCtrl:CheckTeam(false) then
	    	return
	    end
	    if g_LimitCtrl:CheckPlot() then
	    	return
	    end
	    -- if g_LimitCtrl:CheckDance(true) then
	    -- 	return
	    -- end

		if mapWalker then
			if self.m_LastMapWalker and Utils.IsExist(self.m_LastMapWalker) then
				self.m_LastMapWalker:ShowFootRing(false)
			end
			
			self.m_LastMapWalker = mapWalker
			mapWalker:ShowFootRing(true)
			-- self:ShowTouchEffect(mapWalker, define.Map.TouchType.Walker)
			self:WalkToPos(mapWalker:GetPos(), nil, iOffsetDis, func)
		else
			if self.m_LastMapWalker and Utils.IsExist(self.m_LastMapWalker) then
				if self.m_LastMapWalker:IsWalking() and self:CheckIsCanStop(self.m_LastMapWalker.m_NpcAoi)
				 then
				 	if self.m_LastMapWalker.classname ~= "CPlayer" then 
				 		self.m_LastMapWalker:StopWalk()
				 	end 
				end
				self.m_LastMapWalker:ShowFootRing(false)
			end
			g_MapCtrl:SetAutoPatrol(false, false)
			local oHero = g_MapCtrl:GetHero()
			if Utils.IsExist(oHero) then
				-- 任务相关
				CTaskHelp.SetClickTaskShopSelect(nil)
				CTaskHelp.SetClickTaskExecute(nil)
				oHero:DelBindObj("auto_find")
				-- g_MainMenuCtrl:ShowAllArea()
				if vTerrianPos then
					local terrianID = self:GetTouchEffDataPos(vTerrianPos)
					self:ShowTouchEffect(vTerrianPos, define.Map.TouchType["Terrian"..terrianID])
					oHero:WalkToAndSyncPos(vTerrianPos.x, vTerrianPos.y)
				end
			end
		end
	end

	local function walkerExecute(oWalker)
		if oWalker.classname == "CPlayer" then
			local y = oWalker:GetPos().y
			if not iMinY then
				iMinY = y + 1
			end
			if y < iMinY then
				iMinY = y
				mapWalker = oWalker--point
				iOffsetDis = define.Walker.Npc_Talk_Distance
				oToucWalker = oWalker
			end
		elseif oWalker.classname == "CNpc" or oWalker.classname == "CDynamicNpc" or oWalker.classname == "CTaskPickItem" or oWalker.classname == "CNianShouNpc" then
			mapWalker = oWalker
			func = function()
				if Utils.IsExist(oWalker) and oWalker.Trigger then
					oWalker:Trigger()
				end
			end
			iOffsetDis = define.Walker.Npc_Talk_Distance
			oToucWalker = oWalker
		end
		commonExecute()
	end

	if #oWalkList > 0 then
		if #oWalkList == 1 then
			walkerExecute(oWalkList[1])
		else
			local npcList = {}
			local names = {"CPlayer", "CNpc", "CDynamicNpc", "CTaskPickItem", "CNianShouNpc"}
			for ii,v in ipairs(oWalkList) do
				if table.index(names, v.classname) then
					local function cb()
						if Utils.IsNil(v) then
							return
						end
						printc("结束寻路到指定npc", v:GetName())
						walkerExecute(v)
					end
					
					local npcInfo = {}
					local obj = v.m_Huds.name.obj
					if v.classname == "CNpc" or v.classname == "CDynamicNpc" then
						obj = v.m_Huds.npcName.obj
					end
					if obj then
						if v.classname == "CPlayer" then
							npcInfo.isMember = v.m_TeamID and g_MapCtrl.m_Teams[v.m_TeamID][1] ~= v.m_Pid 
							npcInfo.isleader = v.m_TeamID and g_MapCtrl.m_Teams[v.m_TeamID][1] == v.m_Pid 
							npcInfo.orgid = v.m_OrgId
						end
						-- printc("===============", obj:GetName())
						local names = string.split(obj:GetName(), ']')
						local name = names[#names]
						name = string.split(name, '[')[1]
						npcInfo.name = name
						npcInfo.shape = v.m_Actor.m_Shape
						npcInfo.cb = cb
						npcInfo.type = v.classname
						npcInfo.id = ii
						npcInfo.pid  = v.m_Pid
						npcInfo.player = v
						table.insert(npcList, npcInfo)
					end
				end
			end
			if g_MapCtrl:IsInOrgMatchMap() then
				for i=#npcList,1,-1 do
					local dNpc = npcList[i]
					if dNpc.orgid and dNpc.orgid ~= g_AttrCtrl.org_id then
						dNpc.name = "[c]#R"..dNpc.name.."#n"
					end
					if npcList[i].isMember then
						table.remove(npcList, i)
					end
				end
				if #npcList == 1 then
					local cb = npcList[1].cb
					if cb then
						cb()
						return
					end
				end
				local sort = function(info_1, info_2)
					local bIsPlayer_1 = info_1.type == "CPlayer"
					local bIsPlayer_2 = info_2.type == "CPlayer"
					local bIsEnemy_1 = info_1.orgid and info_1.orgid ~= g_AttrCtrl.org_id 
					local bIsEnemy_2 = info_2.orgid and info_2.orgid ~= g_AttrCtrl.org_id 
					if bIsEnemy_1 and bIsEnemy_2 then
						return info_1.isleader and not info_2.isleader
					elseif bIsEnemy_1 then
						return true
					elseif bIsEnemy_2 then
						return false
					elseif not bIsPlayer_1 and bIsPlayer_2 then
						return true
					elseif bIsPlayer_1 and not bIsPlayer_2 then
						return false
					end
					return info_1.id < info_2.id
				end
				table.sort(npcList, sort)
			end
			g_GuessRiddleCtrl:JudgeNpcInfoList(npcList,  npcList[1].player:GetPos())
			g_NotifyCtrl:FloatNpcInfoList(npcList)
		end
		return
	end
	commonExecute()
	-- g_GuessRiddleCtrl:JudgeTerrianPos(vTerrianPos)
end

function CMapTouchCtrl.WalkToPos(self, pos, npcid, offset, func)
	if g_LimitCtrl:CheckIsCannotMove() then
		return
	end
    if g_LimitCtrl:CheckTeam(true) then
    	return
    end
    if g_LimitCtrl:CheckPlot() then
    	return
    end
    -- if g_LimitCtrl:CheckDance(true) then
    -- 	return
    -- end
	
    if self.m_FindHeroTimer then
		Utils.DelTimer(self.m_FindHeroTimer)
		self.m_FindHeroTimer = nil
	end
	local oHero = g_MapCtrl:GetHero()
	if Utils.IsNil(oHero) then
		local function onFind()
			oHero = g_MapCtrl:GetHero()
			if not Utils.IsNil(oHero) then
				self:ExecuteWalkToPos(oHero, pos, npcid, offset, func)
				return false
			end
			return true
		end
		self.m_FindHeroTimer = Utils.AddTimer(onFind, 0.1, 0.1)
	else
		self:ExecuteWalkToPos(oHero, pos, npcid, offset, func)
	end
end

function CMapTouchCtrl.ExecuteWalkToPos(self, oHero, pos, npcid, offset, func)
	if self.m_WalkTimer then
		Utils.DelTimer(self.m_WalkTimer)
		self.m_WalkTimer = nil
	end

	if offset or func then
		offset = offset or define.Walker.Npc_Talk_Distance
		local function check()
			if Utils.IsNil(oHero) then
				self.m_WalkTimer = nil
				return false
			end

			local walkFinish = ((oHero:GetPos().x-pos.x)^2+(oHero:GetPos().y - pos.y)^2) <= offset^2
			if walkFinish then
				if self.m_LastMapWalker and Utils.IsExist(self.m_LastMapWalker) then
					if self.m_LastMapWalker:IsWalking() and self:CheckIsCanStop(self.m_LastMapWalker.m_NpcAoi)
					 then
						self.m_LastMapWalker:StopWalk()
					end
					self.m_LastMapWalker:ShowFootRing(false)
					self.m_LastMapWalker:StopWalkerPatrol()
				end
				-- printc("使用这个接口进行寻路，寻路完成 walkFinish = true")
				oHero:StopWalk()
				if npcid and npcid ~= 0 then
					local oNpc = g_MapCtrl:GetNpc(npcid)
					if not oNpc then
						oNpc = g_MapCtrl:GetDynamicNpc(npcid)
					end
					if not oNpc then
						oNpc = g_MapCtrl:GetNpcByType(npcid)
					end
					if oNpc and oNpc.Trigger then
						oNpc:Trigger()
						if func then
							func()
						end
						self.m_WalkTimer = nil
						return false

					end
					print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "WalkToPos.check", "移动到指定点"), npcid)
					table.print(oNpc)
					return true
				else
					if func then
						func()
					end
					self.m_WalkTimer = nil
					return false
				end 

			else
				return true
			end

		end
		-- 行走前判断一下，修复滑步表现
		if not check() then
			return
		end
		self.m_WalkTimer = Utils.AddTimer(check, 0.1, 0.1)
	end
	g_MapCtrl:SetAutoPatrol(false, false)
	oHero:AddBindObj("auto_find")
	-- g_MainMenuCtrl:HideAreas(define.MainMenu.HideConfig.PathFind)
	oHero:WalkToAndSyncPos(pos.x, pos.y)
end

function CMapTouchCtrl.WalkToGlobalNpc(self, npcid, func)
	-- 队员且在队伍中直接跳过
	if g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeader(g_AttrCtrl.m_Pid) and g_TeamCtrl:IsInTeam(g_AttrCtrl.m_Pid) then
		-- 队伍中 && 非队长 && 跟随中
		g_NotifyCtrl:FloatMsg("您在队伍中，不能操作")
		return
	end

	-- 注意，这里方法寻路的只是global npc，其他的npc类型暂时不支持
	local globalNpc = DataTools.GetGlobalNpc(npcid)
	if not globalNpc then
		printerror("未找到指定id npc信息", npcid)
		return
	end
	local pos = Vector3.New(globalNpc.x, globalNpc.y, 0)
	if not func then
		func = function ()
			local oNpc = g_MapCtrl:GetNpcByType(npcid)
			if oNpc and oNpc.Trigger then
				oNpc:Trigger()
			end
		end
	end
	self:CrossMapPos(globalNpc.mapid, pos, nil, define.Walker.Npc_Talk_Distance, func)
end

function CMapTouchCtrl.CrossMapPos(self, mapID, pos, npcid, offset, func)
	local curMapID = g_MapCtrl:GetMapID()
	if curMapID == mapID then
		self:WalkToPos(pos, npcid, offset, func)
		return
	end

	if self.m_FindHeroTimer2 then
		Utils.DelTimer(self.m_FindHeroTimer2)
		self.m_FindHeroTimer2 = nil
	end
	local oHero = g_MapCtrl:GetHero()
	if Utils.IsNil(oHero) then
		local function onFind()
			oHero = g_MapCtrl:GetHero()
			if not Utils.IsNil(oHero) then
				g_MapCtrl:C2GSClickWorldMap(mapID)
				self.m_CrossMapInfo = {
					mapID = mapID,
					pos = pos,
					npcid = npcid,
					offset = offset,
					func = func,
				}
				return false
			end
			return true
		end
		self.m_FindHeroTimer2 = Utils.AddTimer(onFind, 0.1, 0.1)
	else
		g_MapCtrl:C2GSClickWorldMap(mapID)
		self.m_CrossMapInfo = {
			mapID = mapID,
			pos = pos,
			npcid = npcid,
			offset = offset,
			func = func,
		}
	end
end

function CMapTouchCtrl.CrossMapExecute(self, mapID)
	if self.m_CrossMapInfo and self.m_CrossMapInfo.mapID == mapID then
		self:WalkToPos(self.m_CrossMapInfo.pos, self.m_CrossMapInfo.npcid, self.m_CrossMapInfo.offset, self.m_CrossMapInfo.func)
		self.m_CrossMapInfo = nil
	end
end


function CMapTouchCtrl.ShowTouchEffect(self, worldPos, touchType)
	local path = string.format("Effect/Scene/scene_eff_%s/Prefabs/scene_eff_%s.prefab", touchType.ID, touchType.ID)
	-- local function cb(obj)
	-- 	local isTerrian = string.find(touchType.Name, "Terrian")
	-- 	if not isTerrian then
	-- 		obj.m_Eff:SetLocalRotation(Quaternion.Euler(-30, 0, 0)) 
	-- 	end
	-- end
	local oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("MapTerrain"), true)
	worldPos.z = 0
	oEffect:SetPos(worldPos)
	Utils.AddTimer(callback(g_EffectCtrl, "DelEffect", oEffect:GetInstanceID()), 0, 1.2)
	g_EffectCtrl:AddEffect(oEffect)

	-- local function DestroyEffect(oEffect)	
	-- 	local call = function ( ... )
	--  		oEffect:Destroy()
	--  	end
	--  	return call
	-- end
	-- --Utils.AddTimer(callback(oEffect, "Destroy"), 0, 1.2)
	-- Utils.AddTimer(DestroyEffect(oEffect), 0, 1.2)

end


function CMapTouchCtrl.EnterScene(self, mapData)
	self:CheckTouchEffData(mapData.resource_id)
	self:CrossMapExecute(mapData.id)
end

function CMapTouchCtrl.CheckTouchEffData(self, resid)
	-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "CheckTouchEffData", "检查场景点击特效"))
	if self.m_MapTouchEffData[resid] then
		return
	end

	self.m_MapTouchEffData[resid] = g_MapCtrl:GetSpecialConfig("touch_effect_"..resid)
	do return end

	local path = "Map2d/ConfigData/touch_effect_"..resid..".bytes"
	local bytes = g_ResCtrl:Load(path)
	if not bytes then
		printerror("警告：当前不存在的场景特效点击数据，地图资源ID", resid)
		self.m_MapTouchEffData[resid] = {}
		return
	end

	local strs = tostring(bytes)
	local touchData = {}
	local lowData = {}
	local col = 1
	local i = 0
	for i=1,string.len(strs) do
		local value = string.sub(strs, i, i)
		if value == "\n" then
			table.insert(touchData, lowData)
			lowData = {}
			col = col+1
		else
			table.insert(lowData, string.sub(strs, i, i))
		end
	end

	-- local path = IOTools.GetGameResPath("/Map2d/ConfigData/touch_effect_"..resid..".bytes")
	-- for line in io.lines(path) do
	-- 	local lowData = {}
	-- 	for i=1,#line do
	-- 		local value = string.sub(line, i, i)
	-- 		table.insert(lowData, value)
	-- 	end
	-- 	table.insert(touchData, lowData)
	-- end
	self.m_MapTouchEffData[resid] = touchData
end

function CMapTouchCtrl.GetTouchEffDataPos(self, pos)
	if pos == nil then
		printerror("地图点击错误，发现有这个报错，请通知程序。")
		return
	end
	local index = nil
	local mapData = DataTools.GetMapInfo(g_MapCtrl:GetMapID())
	if mapData.id then
		local touchEffData = self.m_MapTouchEffData[mapData.resource_id]
		if touchEffData then
			local low = Mathf.Floor(pos.y / 0.32)
			low = #touchEffData - low
			local row = Mathf.Floor(pos.x / 0.32)
			if touchEffData[low] and touchEffData[low][row] then
				index = touchEffData[low][row] and tonumber(touchEffData[low][row]) or 0
				if index > 5 then
					index = 5
				end
			end
		end
	end
	return index or 0
end

function CMapTouchCtrl.CheckIsCanStop(self, npcAoi)
	local bCan = true
	if not npcAoi then return bCan end
	-- 火眼金睛
	if npcAoi.func_group and npcAoi.func_group == "huodong.guessgame" then
		bCan = false
	end
	return bCan
end

return CMapTouchCtrl
local CHero = class("CHero", CMapWalker)

function CHero.ctor(self)
	CMapWalker.ctor(self)
	self.m_Pid = nil --角色ID
	self.m_Eid = nil --场景中唯一的ID

	-- 是否场景缓存
	self.m_IsUsing = true

	-- 传送点ID
	self.m_TransferID = nil

	-- Speed
	self.m_CurMoveSpeed = define.Map.Speed.Hero

	-- 是否自动巡逻
	self.m_IsAutoPatroling = false
	self.m_AutoPatrolIdleTime = 0

	-- 跟随
	self.m_Followers = {}
	-- 跳转地图位置
	self.m_LastCheckTransferPos = nil

	-- 位置标记
	self.m_IsInArena = false
	self.m_IsInDance = false
	-- self.m_IsInLingxi = false
	self.m_IsInWaterPoint = false
	-- self.m_IsInLingxiSeedArea = false
	-- self:AddInitHud("autopatrol")
	--秘宝护送npc区域判断
	self.m_InNpcArea = nil

	-- 记录A*转为Lua表的数据
	self.m_SyncPosList = {}
	self.m_NextSyncPosTime = nil
	self.m_CheckTimer = Utils.AddTimer(callback(self, "Check"), 0.1, 0.1)
	self.m_RecordUploadTime = nil
	self.m_RecordUploadQueue = nil
	self:ExpandPathSize(100)
	self:SetCheckInScreen(false)
end

-- Destory(错误的写法)
function CHero.Destroy(self)
	if self.m_CheckTimer then
		Utils.DelTimer(self.m_CheckTimer)
		self.m_CheckTimer = nil
	end
	CMapWalker.Destroy(self)
end

function CHero.OnTouch(self)
	-- printc("点到自己了")
end

function CHero.SetName(self, name, color)
	-- local colorinfo = data.namecolordata.DATA[0]
	-- local nameColor = color or ("["..colorinfo.color.."]")
	CMapWalker.SetName(self, name, color, define.RoleColor.Protagonist)
	-- self, nameColor .. name, colorinfo.style, Color.RGBAToColor(colorinfo.style_color), colorinfo.blod
end

function CHero.SetHeart(self, idx, bShow)
	CMapWalker.SetHeart(self, idx, bShow)
end

-- WalkTo后由C#层回调
function CHero.OnStartPath(self)
	--挖宝相关
	g_TreasureCtrl:OnEvent(define.Treasure.Event.SliderBroken)

	CWalker.OnStartPath(self)
end

function CHero.OnStopPath(self)
	self:DoOnStop()
	CMapWalker.OnStopPath(self)
end

function CHero.StopWalk(self)
	self:DoOnStop()
	CMapWalker.StopWalk(self)
end

function CHero.DoOnStop(self)
	self.m_AutoPatrolIdleTime = 0
	-- 停止寻路提交一次位置
	self:SyncCurPos()
	self.m_SyncPosList = {}
	self.m_NextSyncPosTime = nil
end

-- Update Check
function CHero.Check(self, dt)
	-- 以上检查各种区域
	self:CheckAutoPatrol(dt)
	self:CheckSummonDis()
	self:CheckInArenaArea()
	self:CheckInDanceArea()
	self:CheckInLingxiArea()
	self:CheckInLingxiSeedArea()
	self:CheckInMarryArea()
	if not(self:IsCanWalk() and self:IsAutoPatroling()) then
		self:CheckTransfer()
	end
	if self:IsTriggerWaterRun() then 
		self:CheckInWaterPointArea()
	end

	self:CheckSysPos()
	return true
end

-- 以下是同步位置逻辑
function CHero.CheckSysPos(self)
	if self.m_NextSyncPosTime then
		local curTimeMS = g_TimeCtrl:GetTimeMS()
		if curTimeMS >= self.m_NextSyncPosTime then
			self.m_NextSyncPosTime = nil
			self:SyncPosQueue()
		end
	end
	if self.m_RecordUploadQueue then
		self:C2GSSyncPosQueue(self.m_RecordUploadQueue)
	end
end

function CHero.C2GSSyncPosQueue(self, lPosQueue)
	-- 开始计时
	local curTimeMS = g_TimeCtrl:GetTimeMS()
	if self.m_RecordUploadTime then
		if curTimeMS >= self.m_RecordUploadTime then
			self.m_RecordUploadQueue = nil
			self.m_RecordUploadTime = nil
		else
			-- printerror("时间没到，无法上行玩家坐标")
			self.m_RecordUploadQueue = lPosQueue
			return
		end
	end

	self.m_RecordUploadQueue = nil
	-- 暂定500的时差
	self.m_RecordUploadTime = curTimeMS + 500
	netscene.C2GSSyncPosQueue(g_MapCtrl:GetSceneID(), self.m_Eid, lPosQueue)
end

-- 获取同步点信息
function CHero.GetPosQueueInfo(self, vPos, time)
	local vAngles = self.m_Actor:GetLocalEulerAngles()
	return	{
		pos = netscene.EncodePos({
			x = vPos.x,
			y = vPos.y,
			face_x = vAngles.x < 0 and (vAngles.x+360) or vAngles.x,
			face_y = vAngles.y < 0 and (vAngles.y+360) or vAngles.y,
		}),
		time = time or 0,
	}
end

-- 立即同步主角位置，慎用
function CHero.SyncCurPos(self)
	if self.m_IsFlyWaterProgress then
		return
	end
	local curPos = self:GetPos()
	self:SyncPosByPoint(curPos.x, curPos.y)
end

-- 立即同步坐标位置，慎用
function CHero.SyncPosByPoint(self, oHeroX, oHeroY, bNotCheckLastPos)
	local curPos = {x = oHeroX, y = oHeroY}
	local dPosQueueInfo = self:GetPosQueueInfo(curPos)
	local lPosQueue = {dPosQueueInfo}
	self:C2GSSyncPosQueue(lPosQueue)
end

-- 设置同步位置列表
function CHero.SetSyncPosList(self, list, size)
	if size <= 0 or not list then
		return
	end
	
	local pathlist = {}--table.copy(list)
	for i = 1, size do
		pathlist[i] = list[i]
	end
	self.m_SyncPosList = pathlist
	
	if not self.m_NextSyncPosTime then
		self.m_NextSyncPosTime = g_TimeCtrl:GetTimeMS()-- + 300
	end
end

-- 行走并同步位置坐标
function CHero.WalkToAndSyncPos(self, x, y)
	self:WalkTo(x, y, function(oHero)
		local list,size = oHero:GetAStartPath()
		oHero:SetSyncPosList(list, size)
	end)
end

-- 同步位置列表
function CHero.SyncPosQueue(self)
	if self.m_IsFlyWaterProgress then
		return
	end
	if not self.m_SyncPosList then
		return
	end
	local iLen = #self.m_SyncPosList
	if iLen <= 0 then
		return
	end

	local vLastPos = nil
	local vStartPos = nil
	local lPosQueue = {}
	local iTotalDis = 0
	local iNextTime = 0
	local iSafeFlag = 0
	local iRemoveCnt = 0
	local errorTime = 200   --误差时间
	
	local i = 1
	while i <= iLen do
		local vPos = self.m_SyncPosList[i]
		vPos.z = 0
		if vLastPos then
			local iPosDistance = Vector3.DistanceXY(vPos,vLastPos)
			if (iTotalDis + iPosDistance) > self.m_CurMoveSpeed then
				iNextTime = iNextTime + 1000
				local vLerpPos = Vector3.Lerp(vLastPos, vPos, (self.m_CurMoveSpeed-iTotalDis)/iPosDistance)
				table.insert(lPosQueue, self:GetPosQueueInfo(vStartPos, 1000))
				vStartPos, vLastPos = vLerpPos, vLerpPos
				table.insert(self.m_SyncPosList, i, vLerpPos)
				iLen = iLen + 1
				iTotalDis = 0
				iRemoveCnt = i - 1
			else
				iTotalDis = iTotalDis + iPosDistance
				vLastPos = vPos
				if i == iLen then
					local iTime = (iTotalDis/self.m_CurMoveSpeed * 1000)
					if iTime > 100 then
						table.insert(lPosQueue, self:GetPosQueueInfo(vStartPos, iTime))
					end
					if #lPosQueue > 0 then
						table.insert(lPosQueue, self:GetPosQueueInfo(vPos, 0))
					end
					iTotalDis = 0
					iNextTime = 0
				end
				iRemoveCnt = i
			end
		else
			vStartPos, vLastPos = vPos, vPos
			iRemoveCnt = i
		end
		i = i + 1
		if #lPosQueue >= 1 then
			if iNextTime ~= 0 then
				local dEndPos = lPosQueue[#lPosQueue].pos
				if Vector3.DistanceXY(Vector3.New(dEndPos.x, dEndPos.y, 0), vLastPos*1000) > 100 then
					table.insert(lPosQueue, self:GetPosQueueInfo(vLastPos, 0))
				end
			end
			break
		end
	end
	for j=1, iRemoveCnt do
		table.remove(self.m_SyncPosList, 1)
	end
	if iNextTime > 0 then
		self.m_NextSyncPosTime = g_TimeCtrl:GetTimeMS() + iNextTime - errorTime
	end

	if next(lPosQueue) then
		self:C2GSSyncPosQueue(lPosQueue)
	end
end

-- 检查是否跳转地图
function CHero.CheckTransfer(self)
	local curPos = self:GetPos()
	if self.m_LastCheckTransferPos == curPos then
		return
	end
	self.m_LastCheckTransferPos = curPos
	local id = g_MapCtrl:CheckTranserArea(curPos)
	if self.m_TransferID == id then
		return
	end
	self.m_TransferID = id
	if self.m_TransferID then
		if g_LimitCtrl:CheckIsCannotMove() then
			return
		end
		self.m_LastCheckTransferPos = nil
		self:SyncPosQueue()

		-- CMapFadeView:ShowView(function (oView)
		-- 	oView:RefreshUI()
		-- end)
		if g_MapCtrl.m_IsMapLoadDone then
	       netscene.C2GSTransfer(g_MapCtrl.m_SceneID, self.m_Eid, self.m_TransferID)
	    end 		
	end
end

-- 变更跟随
function CHero.ChangeFollow(self, oWalker, distance)
	CWalker.ChangeFollow(self, oWalker, distance)
	-- if oWalker then
	-- 	self.m_NextSyncCurPosTime = g_TimeCtrl:GetTimeMS() + 1000
	-- else
	-- 	self.m_NextSyncCurPosTime = nil
	-- end
	self.m_SyncPosList = {}
	self.m_NextSyncPosTime = nil
end

-- 检查擂台
function CHero.CheckInArenaArea(self)
	self.m_IsInArena = g_MapCtrl:CheckInArenaArea(self)
end

-- 检查跳舞
function CHero.CheckInDanceArea(self)
	self.m_IsInDance = g_MapCtrl:CheckInDanceArea(self)
end

-- 检查踩水
function CHero.CheckInWaterPointArea(self)
	--这里是设置脚底挂点的角度
	if self.m_IsFlyWaterProgress then
		-- self.m_FootTransObj:SetLocalRotation(Quaternion.Euler(0, self.m_Actor.m_Transform.localEulerAngles.y + 120, 0))
		g_MapCtrl:OnEvent(define.Map.Event.UpdateMiniPos)
	else
		-- self.m_FootTransObj:SetLocalRotation(Quaternion.Euler(0, 0, 0))
	end

	local isInWaterPoint = g_MapCtrl:CheckInWaterPointArea(self)
	if isInWaterPoint ~= self.m_IsInWaterPoint then
		-- printc("CHero.CheckInWaterPointArea owalker map", self.m_IsInWaterPoint, " ", isInWaterPoint)
		self.m_IsInWaterPoint = isInWaterPoint
	end
end

-- 检查灵犀
function CHero.CheckInLingxiArea(self)
	if not g_LingxiCtrl.m_Taskid or not g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid] or g_LingxiCtrl.m_Phase ~= 4 then
		return
	end

	local bIsInArena = g_MapCtrl:CheckInLingxiArea(self)
	if g_LingxiCtrl.m_IsInLingxi ~= bIsInArena and g_LingxiCtrl.m_Taskid then
		g_LingxiCtrl.m_IsFloatDesc = true
		g_TaskCtrl:RefreshSpecityBoxUI({task = g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid]})
	end

	if g_LingxiCtrl.m_IsInLingxi ~= bIsInArena or g_LingxiCtrl.m_IsCloseToFlowerSend then
		if bIsInArena then
			nettask.C2GSLingxiCloseToFlower(g_LingxiCtrl.m_Taskid)
		else
			nettask.C2GSLingxiAwayFromFlower(g_LingxiCtrl.m_Taskid)
		end
		if not g_LingxiCtrl.m_IsCloseToFlowerSend then
			--暂时屏蔽
			-- if not bIsInArena then
			-- 	g_NotifyCtrl:FloatMsg("超出情花成长区域，情花停止成长，请返回")
			-- else
			-- 	g_NotifyCtrl:FloatMsg("已进入情花成长区域")
			-- end
		end
		g_LingxiCtrl.m_IsCloseToFlowerSend = false
	end
	g_LingxiCtrl.m_IsInLingxi = bIsInArena
end

-- 检查灵犀种子
function CHero.CheckInLingxiSeedArea(self)
	if g_LingxiCtrl.m_Phase <= 0 then
		return
	end
	if not g_LingxiCtrl.m_Taskid or not g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid] or g_LingxiCtrl.m_Phase > 3 then
		return
	end
	local bIsInSeedArena = g_MapCtrl:CheckInLingxiSeedArea(self)
	if g_LingxiCtrl.m_IsInLingxiSeedArea ~= bIsInSeedArena and g_LingxiCtrl.m_Taskid then
		g_LingxiCtrl.m_IsFloatDesc = true
		g_TaskCtrl:RefreshSpecityBoxUI({task = g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid]})
	end
	if g_LingxiCtrl.m_IsInLingxiSeedArea ~= bIsInSeedArena or g_LingxiCtrl.m_IsLeaderReachSend then
		if bIsInSeedArena and g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsLeader() and g_LingxiCtrl.m_Phase == 1 then
			-- printerror("11111111111111111111")
			nettask.C2GSLingxiCloseToGrowPos(g_LingxiCtrl.m_Taskid)
		end
		g_LingxiCtrl.m_IsLeaderReachSend = false
		if bIsInSeedArena and g_TeamCtrl:IsJoinTeam() and g_LingxiCtrl.m_Phase == 2 then --and not g_TeamCtrl:IsLeader()
			local oMember = g_LingxiCtrl:GetMemberPlayer()
			local bIsMemberInArena = g_MapCtrl:CheckInLingxiSeedArea(oMember)
			if bIsMemberInArena then
				-- printerror("2222222222222222222")
				nettask.C2GSLingxiCloseToGrowPos(g_LingxiCtrl.m_Taskid)
			else
				-- printerror("33333333333333333333")
				g_LingxiCtrl.m_IsLeaderReachSend = true
			end
		end
		-- if not g_LingxiCtrl.m_IsLeaderReachSend then
		-- 	--暂时屏蔽
		-- 	-- if not bIsInSeedArena then
		-- 	-- 	g_NotifyCtrl:FloatMsg("已离开情花苗种植区域，无法种植情花苗，请返回")
		-- 	-- else
		-- 	-- 	g_NotifyCtrl:FloatMsg("已进入情花苗种植区域")
		-- 	-- end
		-- end
	end
	g_LingxiCtrl.m_IsInLingxiSeedArea = bIsInSeedArena
end

-- 检查宠物距离
function CHero.CheckSummonDis(self)
	if self.m_Followers and next(self.m_Followers) then 
		for k, v in pairs(self.m_Followers) do 
			local map2dWalker = v.m_Walker
			if Vector3.Distance(v:GetPos(), self:GetPos()) > 15 then 
				v:SetPos(self:GetPos())
			end 
		end 
	end 
end

function CHero.CheckInMarryArea(self)
	if not g_MarryPlotCtrl:IsCheckWedding() then
		return false
	end
	if self:IsInMarryArea() then
		g_MarryPlotCtrl:PlayWeddingCachePlot()
	end
end

function CHero.IsInMarryArea(self)
	return g_MapCtrl:IsMarryArea(self:GetPos())
end

-- Begin 自动巡逻
function CHero.IsAutoPatroling(self)
	return self.m_IsAutoPatroling
end

function CHero.StartAutoPatrol(self, isAutoPatrolFree)
	if self:IsCanWalk() and not self:IsAutoPatroling() then
		if isAutoPatrolFree or g_MapCtrl:IsAutoPatrolMap() then
			self:StopWalk()
			self.m_AutoPatrolIdleTime = nil
			self.m_IsAutoPatroling = true
			self:AddBindObj("autopatrol")
			g_MapCtrl:OnEvent(define.Map.Event.HeroPatrol, {bPatrol=true})
		end
	end
end

function CHero.StopAutoPatrol(self)
	if self:IsAutoPatroling() then
		self:StopWalk()
		self.m_IsAutoPatroling = false
		self:DelBindObj("autopatrol")
		g_MapCtrl:OnEvent(define.Map.Event.HeroPatrol, {bPatrol=false})
	end
end

function CHero.CheckAutoPatrol(self, dt)
	if not self.m_IsAutoPatroling then
		return
	end
	if not self:IsWalking() then 
		if self.m_AutoPatrolIdleTime then
			self.m_AutoPatrolIdleTime = self.m_AutoPatrolIdleTime + dt
			if self.m_AutoPatrolIdleTime >= define.MapWalker.AutoPatrol_Idle_Time then
				self:AutoPatrolNext()
			end
		else
			self:AutoPatrolNext()
		end
	end
end

function CHero.AutoPatrolNext(self)
	self.m_AutoPatrolIdleTime = nil
	local pos = g_MapCtrl:GetAutoPatrolPos()
	self:WalkToAndSyncPos(pos.x, pos.y)
end
-- End 自动巡逻

return CHero
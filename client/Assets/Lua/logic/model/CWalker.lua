local CWalker = class("CWalker", CObject)

define.Walker = {
	CrossFade_Time = 0.1,
	Follow_Distance = 0.7,
	Npc_Talk_Distance = 1,
	Summon_Ride_Distance = 1.4
}

function CWalker.ctor(self, obj)
	CObject.ctor(self, obj)
	self.m_Walker = nil
	self.m_Actor = CActor.New()
	self.m_Actor:SetParent(self.m_Transform)
	self.m_Actor:SetLayer(self:GetLayer(), true)
	self.m_IsWalking = false
	self.m_IsFollowing = false
	self.m_TargetPos = nil
	self.m_Is3D = false
	-- self.m_Shape = nil
	self.m_ModelInfo = nil
	self.m_CheckInScreen = false
	self.m_IsInScreen = true
	self.m_Timer = nil
	self.m_WalkerStartCb = nil
	self.m_WalkerCompleteCb = nil
	self.m_HasShowClip = false
	self.m_IdleActionName = "idleCity"
	self.m_WalkActionName = "run"
	self.m_FollowTarget = nil
	self.m_Layer = self:GetLayer()
	self.m_IsUsing = true
	self.m_Cb = nil

	self.m_Path = {}
	self.m_PathSize = 0
	self.m_ShowFlag = false 

	self.m_TeamFlyState = nil
	self.m_FlyHeight = nil
	self.m_TeamID = nil
	self.m_Leader = nil
	--跟随距离，相对于跟随者
	self.m_FollowDis = nil

	self.m_ShowState = nil
	self.hideByMarry = false
	self.m_IsCacheChangeScreenCb = false

end

function CWalker.ExpandPathSize(self, iExpandSize)
	local iCurSize = #self.m_Path
	local iStartIndex = iCurSize + 1
	local iEndIndex = iCurSize + iExpandSize
	for i= iStartIndex, iEndIndex do
		self.m_Path[i] = {x = 0, y = 0, z = 0}
	end
end

function CWalker.Reset(self)
	self:ChangeFollow(nil)
	self:LandAni(false)
	self.m_FlyHeight = 0
	self.m_PathSize = 0
	self.m_IsWalking = false
	self.m_IsFollowing = false
	self.m_TargetPos = nil
	self.m_Is3D = false
	-- self.m_Shape = nil
	self.m_CheckInScreen = false
	self.m_IsInScreen = true
	self:CrossFade(self.m_IdleActionName, define.Walker.CrossFade_Time)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	self.m_Actor:Clear()
	self.m_Walker:ClearAlphaMaterial()
	self.m_Timer = nil
	self.m_HasShowClip = false
	self.m_WalkActionName = "run"
	self.m_FollowTarget = nil
	self.m_TeamID = nil	
	self.m_LoadedShape = false
	self.m_IsFlyWaterProgress = false
	-- 内存问题
	self.m_Cb = nil

	self.m_IsInWaterPoint = false
	self.m_IsFlyWaterProgress = false
	self.m_RecordTargetPos = nil
	self.m_RecordFollowTarget = nil
	self.m_RecordFollowDis = nil
	self.m_OriginIndex = nil
	self.m_StopCallback = nil
	if self.m_FollowTimer then
		Utils.DelTimer(self.m_FollowTimer)
		self.m_FollowTimer = nil
	end
	if self.m_DanceTimer then
		Utils.DelTimer(self.m_DanceTimer)
		self.m_DanceTimer = nil
	end
	self:DelBindObj("dancer")
	self:DelBindObj("water")
	self.m_IsInDance = false
	self.m_IsInDanceState = false
	self.m_ShowFlag = false
	self.m_ModelInfo = nil
	self.m_Actor:SetLocalScale(Vector3.one)

	self:DelFootCloudEffect()

	if self.m_StopTimer then 
		Utils.DelTimer(self.m_StopTimer)
		self.m_StopTimer = nil
	end

	self.m_TeamFlyState = nil
	self.m_Leader = nil
	self.m_FollowDis = nil 

	self.m_ShowState = nil
	self.hideByMarry = false

	if self.m_Walker then 
		self.m_Walker:Reset()
	end 

	if self.m_QiLingTimer then 
		Utils.DelTimer(self.m_QiLingTimer)
	end

	self.m_ChangeShape = false 
	self.m_IsCacheChangeScreenCb = false

	self:ShowAllParticle(false)

end

function CWalker.SetCheckInScreen(self, b)

	self.m_CheckInScreen = b
	self.m_IsInScreen = not b
	if not self.m_Timer then
		self.m_Timer = Utils.AddTimer(callback(self, "CheckInScreen"), 0.5, 0)
	end
	self:ChangeInScreenCb(self.m_IsInScreen)
end

function CWalker.CheckInScreen(self)

	if not self.m_CheckInScreen then 
		return false
	end 

	if not self:IsInScreen()  then
		if self.m_IsInScreen then
			-- 这里会放入回收Cache内，没有问题的
			self.m_IsInScreen = false
			self.m_Actor:Clear()
			self.m_Walker:ClearAlphaMaterial()
			self:ChangeInScreenCb(false)
		end
	else
		if not self.m_IsInScreen or self.m_ChangeShape then
			self.m_ChangeShape = false
			self.m_IsInScreen = true
			if self.m_ModelInfo ~= self.m_Actor:GetModelInfo() then
				self:HandleChangeShape()
			end
			if self.m_ShowState then 
				self:ChangeInScreenCb(true)
			else
				self.m_IsCacheChangeScreenCb = true
			end 
		end
	end
	if not self.m_IsUsing then
		return false
	end
	return true
end

-- 进出屏幕内外会调用
function CWalker.ChangeInScreenCb(self, bInScreen)

end

function CWalker.Init3DWalker(self)
	self.m_Walker = self:GetMissingComponent(classtype.Map3DWalker)
	self.m_Is3D = true
	self.m_Walker.moveTransform = self.m_Transform
	self.m_Walker.rotateTransform = self.m_Actor.m_Transform
	self:InitWalkCB()
end

function CWalker.SetMoveSpeed(self, iSpeed)
	local isPlayer = self.classname == "CHero" or self.classname == "CPlayer"
	local defaultSpeed = g_MapCtrl:GetWalkerDefaultSpeed(isPlayer)

	if self.classname == "CHero" then
		self.m_CurMoveSpeed = iSpeed or defaultSpeed
	end
	self.m_Walker.moveSpeed = iSpeed or defaultSpeed
end

function CWalker.Init2DWalker(self)
 	self.m_Walker = self:GetComponent(classtype.Map2DWalker)
 	self.m_HideHelper = self:GetComponent(classtype.HideMapWalker)
	self.m_Is3D = false
	self.m_Walker.moveTransform = self.m_Transform
	self.m_Walker.rotateTransform = self.m_Actor.m_Transform
	self.m_Actor:MainModelCall("SetMaterialAddFunc", function(oMat)
		self.m_Walker:AddAlphaMaterial(oMat)
	end)

	self:InitWalkCB()
end

function CWalker.ResetHeight(self)
	local vPos = self:GetPos()
	if self.m_Is3D then
		if g_MapCtrl.m_CurMapObj then
			vPos.y = g_MapCtrl.m_CurMapObj.m_MapCompnent:GetHeight(vPos.x, vPos.z)
		end
	end
	self:SetPos(vPos)
end

function CWalker.SetMapID(self, mapid)

	self.m_Walker:SetMapID(mapid)

end

function CWalker.ShowRideEffect(self, lv)
	
	self.m_Actor:ShowRideEffect(lv)

end

function CWalker.ShowWingEffect(self, lv)

	self.m_Actor:ShowWingEffect(lv)

end

function CWalker.ShowWeaponEffect(self, lv)
	
	self.m_Actor:ShowWeaponEffect(lv)

end

function CWalker.SetQiLingWalkeState(self)

	self.m_Actor:SetQiLingWalkeState(self.m_IsWalking)

end

function CWalker.Destroy(self)
	self:Reset()
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	self.m_HideHelper:ActiveAllRender(true)
	self:IgnoreTransparentArea(false)
	self.m_Actor:Destroy()
	self.m_Actor = nil
	if self.m_SkyCloudEffect then 
        self.m_SkyCloudEffect:Destroy()
        self.m_SkyCloudEffect = nil
    end 
    self:DelFootCloudEffect()
    CObject.Destroy(self)

end

function CWalker.InitWalkCB(self)
	self.m_Walker:SetWalkStartCallback(callback(self, "OnStartPath"))
	self.m_Walker:SetWalkEndCallback(callback(self, "OnStopPath"))
end

-- c#的回调，不应该有lua调用
function CWalker.OnStartPath(self)
	self.m_IsWalking = true

	if self.m_Actor and self:GetState() ~= self.m_WalkActionName then
		self:CrossFade(self.m_WalkActionName, define.Walker.CrossFade_Time)
	end
	if self.m_WalkerStartCb then
		self.m_WalkerStartCb(self)
		self.m_WalkerStartCb = nil
	end
	if self.m_DanceTimer then 
       Utils.DelTimer(self.m_DanceTimer)
       self.m_DanceTimer = nil
    end
    self:DelBindObj("dancer")
    self:SetQiLingWalkeState()
end

-- c#的回调，不应该有lua调用
function CWalker.OnStopPath(self)
	-- self.m_Memory = collectgarbage("count")
	self.m_PathSize = 0
	self.m_IsWalking = false
	self.m_TargetPos = nil
	self:SetQiLingWalkeState()

	if self.m_WalkerCompleteCb then
		local oPos = self:GetPos()
		local targetPos = self.m_TargetPos
		if self.m_Is3D then
			oPos.y = 0
			if targetPos then
				targetPos.y = 0
			end
		end
		if UITools.CheckInDistanceXY(oPos, targetPos, 0.01) then
			self.m_WalkerCompleteCb(self)
		end
		self.m_WalkerCompleteCb = nil
	end

	if self.m_IsFollowing then
		local func = function()
			return self:OnStopFunc()
		end

		if self.m_StopTimer then 
			Utils.DelTimer(self.m_StopTimer)
		end 
		self.m_StopTimer = Utils.AddTimer(func, 0, 0.1, true)

	else
		self:OnStopFunc()
	end

	self:CrossFade(self.m_IdleActionName, define.Walker.CrossFade_Time)
end

function CWalker.ReleaseWalkCB(self)
	self.m_Walker:SetWalkEndCallback(function() end)
	self.m_Walker:SetWalkStartCallback(function() end)
end

function CWalker.WalkTo(self, x, yORz, startCb, completeCb, bUseLine)
	self.m_PathSize = 0
	local curPos = self:GetPos()
	local curVec2 = Vector2.New(curPos.x, curPos.y)
	local toVec2 = Vector2.New(x, yORz)
	if Vector2.Distance(curVec2, toVec2) < 0.01 then
		return
	end

	if g_MapCtrl:GetCurMapObj() then
		self:SetMapID(g_MapCtrl:GetResID())
		if self:IsCanWalk() then
			self.m_TargetPos = Vector2.New(x, yORz)
			self.m_WalkerCompleteCb = completeCb
			self.m_WalkerStartCb = startCb

			local isInTeam = g_MapCtrl:IsWalkerInTeam(self.m_Pid)
			if isInTeam then
				local leader = g_MapCtrl:GetTeamLeader(self.m_Pid)
				if leader and leader:IsInFlyState() then
					if self:IsShow() then 
						self.m_Walker:WalkTo2(x, yORz)
					else
						local toVec3 = Vector3.New(toVec2.x, toVec2.y, 0)
						self:SetLocalPos(toVec3)
					end 
					
				else
					if self:IsShow() then 
						self.m_Walker:WalkTo(x, yORz, (bUseLine ~= nil and {bUseLine} or {true})[1])
					else
						local toVec3 = Vector3.New(toVec2.x, toVec2.y, 0)
						self:SetLocalPos(toVec3)
					end 
					
				end 
			else
				if self:IsInFlyState() then 
					self.m_Walker:WalkTo2(x, yORz)
				else
					if self:IsShow() then
						self.m_Walker:WalkTo(x, yORz, (bUseLine ~= nil and {bUseLine} or {true})[1])
					else
						local toVec3 = Vector3.New(toVec2.x, toVec2.y, 0)
						self:SetLocalPos(toVec3)	
					end 
					
				end 
			end
		else
			if startCb then
				startCb(self)
			end
			if completeCb then
				completeCb()
			end
		end
	else
		print("没有地图，直接设置位置")
		if self.m_Is3D then
			self:SetLocalPos(Vector3.New(x, 0, yORz))
		else
			self:SetLocalPos(Vector3.New(x, yORz, 0))
		end
		if startCb then
			startCb(self)
		end
		if completeCb then
			completeCb(self)
		end
	end
end

function CWalker.WalkTo2(self, x, yORz)
	self.m_PathSize = 0
	if self:IsCanWalk() then
		self.m_TargetPos = Vector2.New(x, yORz)
		self.m_Walker:WalkTo2(x, yORz)
	end
end

function CWalker.IsCanWalk(self)
	return not self.m_IsFollowing
end

function CWalker.GetWayPointIndex(self)
	local index = self.m_Walker:GetWayPointIndex()
	return index
end

--当前寻路关键点
function CWalker.GetWayPoint(self)
	local x, y = self.m_Walker:GetWayPoint()
	return x, y
end

--当前路径（A*转为table后的数据）
function CWalker.GetAStartPath(self)
	if self.m_IsWalking then
		if self.m_PathSize == 0 then
			-- self.m_Memory = collectgarbage("count")
			local t = self.m_Walker:GetPath()
			-- local iMemory = collectgarbage("count")
			-- print("GetPath memory", iMemory - self.m_Memory, iMemory)

			local iPathSize = #t/2
			local iCurPathSize = #self.m_Path
			if iPathSize > iCurPathSize then
				self:ExpandPathSize(2*(iPathSize - iCurPathSize))
			end
			for i = 1, iPathSize do
				self.m_Path[i].x = t[i*2 - 1]
				self.m_Path[i].y = t[i*2]
			end
			self.m_PathSize = #t/2
			local vCurPos = self:GetPos()
			if #t/2 == 1 and not table.equal(self.m_Path[1], vCurPos) then
				local x,y = self.m_Path[1].x, self.m_Path[1].y
				self.m_Path[1].x = vCurPos.x
				self.m_Path[1].y = vCurPos.y
				self.m_Path[2].x = x
				self.m_Path[2].y = y
				self.m_PathSize = 2
			end
		end
		return self.m_Path, self.m_PathSize
	end
end

function CWalker.IsWalking(self)
	return self.m_IsWalking
end

function CWalker.StopWalk(self)
	if self.m_IsFlyWaterProgress then
		return
	end
	
	self.m_Walker:StopWalk()
	-- self:OnStopPath()
	self.m_PathSize = 0
	self.m_IsWalking = false
	self.m_TargetPos = nil
	self:DelBindObj("auto_find")
	self:CrossFade(self.m_IdleActionName, define.Walker.CrossFade_Time)
	self:SetQiLingWalkeState()
end

function CWalker.OnStopFunc(self)
	-- if Utils.IsNil(self) then
	-- 	return false
	-- end
	if not self.m_IsWalking and self:GetState() ~= self.m_IdleActionName then
		self:CrossFade(self.m_IdleActionName, define.Walker.CrossFade_Time)
	end

	if self.m_StopCallback then
		self.m_StopCallback()
		self.m_StopCallback = nil
	end

	if self.classname == "CHero" then
		if g_DancingCtrl.m_StateInfo and g_MapCtrl:CheckInDanceArea(self) then
			self:TurnInDanceState()
		else
			if self.m_DanceTimer then 
		       Utils.DelTimer(self.m_DanceTimer)
		       self.m_DanceTimer = nil
		    end
		    self:DelBindObj("dancer")
		end
	elseif self.classname == "CPlayer" then
		if self.m_IsInDanceState and g_MapCtrl:CheckInDanceArea(self) then
			self:TurnInDanceState()
		else
			if self.m_DanceTimer then 
		       Utils.DelTimer(self.m_DanceTimer)
		       self.m_DanceTimer = nil
		    end
		    self:DelBindObj("dancer")
		end
	end
	return false
end

function CWalker.TurnInDanceState(self)
	if not self.m_Actor.m_LoadDoneModelList["main"] then
		return
	end
	if self.m_DanceTimer then 
       Utils.DelTimer(self.m_DanceTimer)
       self.m_DanceTimer = nil
    end
    self:DelBindObj("dancer")
    --暂时屏蔽头顶图标
    -- self:AddBindObj("dancer")
    --角色跳舞
    local dClipInfo = ModelTools.GetAnimClipInfo(self.m_Actor.m_LoadDoneModelList["main"]:GetShape(), "dance")
    local iTime = dClipInfo.length
    if self.m_Actor.m_LoadDoneModelList["main"]:GetShape() == 1110 then
    	iTime = iTime - 1
    end
    -- if self.m_Actor then
    --    self:ChangeShadowPos(self.m_Actor.m_LoadDoneModelList["main"]:GetShape())
    -- end
    local play_dance = function()
    	if self.classname == "CHero" or self.classname == "CPlayer" then
    		if (not g_MapCtrl:IsWalkerInTeam(self.m_Pid)) or (g_MapCtrl:IsWalkerInTeam(self.m_Pid) and g_MapCtrl:IsLeaderSelf(self.m_Pid)) then
    			local oIsInDanceArea = g_MapCtrl:CheckInDanceArea(self)
		    	if self.classname == "CHero" then

		    		local oNeedCondition = g_OpenSysCtrl:GetOpenSysState(define.System.Horse) and self:IsOnRide() and oIsInDanceArea
		    		if self:IsInFlyState() and oNeedCondition then
		    			local finish = function ()
		    				if oNeedCondition then
								g_HorseCtrl:C2GSUseRide(g_HorseCtrl.use_ride, 0)
								g_MainMenuCtrl:HideFlyBtn()
							end
						end
			        	g_FlyRideAniCtrl:RequestFly(finish)
		    		else
		    			if oNeedCondition then
		    				g_HorseCtrl:C2GSUseRide(g_HorseCtrl.use_ride, 0)
		    				g_MainMenuCtrl:HideFlyBtn()
		    			end
		    		end 
				    
		        end
		        if self.m_Actor and not self.m_IsWalking and oIsInDanceArea then
		           self.m_IsPlayDance = true
		           self.m_Actor:CrossFade("dance")
		           self:AddBindObj("dancer")
		        end
		    end
	    end
        return true
    end
    local modelInfo = self:GetModelInfo()
    if modelInfo.horse and modelInfo.horse > 0 then
    	self.m_IsPlayDance = true
    	if self.m_DanceDelayTime then
    		self.m_DanceTimer = Utils.AddTimer(play_dance, iTime, self.m_DanceDelayTime)
    		self.m_DanceDelayTime = nil
    	else
    		self.m_DanceTimer = Utils.AddTimer(play_dance, iTime, data.dancedata.CONDITION[1].ridetime)
    	end
    else
    	if self.m_DanceDelayTime then
    		self.m_DanceTimer = Utils.AddTimer(play_dance, iTime, self.m_DanceDelayTime)
    		self.m_DanceDelayTime = nil
    	else
    		self.m_DanceTimer = Utils.AddTimer(play_dance, iTime, iTime)
    	end
    end
end



function CWalker.ChangeShape(self, modelInfo, func)

	self.m_ModelInfo = modelInfo
	self.m_Cb = func
	self.m_ChangeShape = true

	if not self.m_CheckInScreen then 
		self:HandleChangeShape()
	end  

end


function CWalker.HandleChangeShape(self)

	if not self.m_ModelInfo then 
		return
	end

	local modelInfo = nil
	if self.m_TeamFlyState then 
		if self:IsOnGroundRide() then 
		    modelInfo = table.copy(self.m_ModelInfo)
		    modelInfo.horse = nil
		    self:AddFootCloudEffect()
		elseif self:IsOnFlyRide() then 
			modelInfo = self.m_ModelInfo
			self:DelFootCloudEffect()
		else
			modelInfo = self.m_ModelInfo
			self:AddFootCloudEffect()
		end 
	else
		modelInfo = self.m_ModelInfo
		self:DelFootCloudEffect()
	end

	if modelInfo then
		local isPrior = self.classname == "CHero"
		local priorty = 81
		if self.classname == "CHero" then
			priorty = 100
		elseif self.classname == "CNpc" then
			priorty = 91
		end
		self.m_Actor:ChangeShape(modelInfo, callback(self, "OnChangeDone"), false, isPrior, priorty)
	end

	self:FlyHandle()

end

function CWalker.FlyHandle(self)

	if not self.m_ModelInfo then 
		return
	end
	
	if self.classname == "CMapSummon" then 
		g_FlyRideAniCtrl:HandleSummon(self)
		g_FlyRideAniCtrl:HandleFollowNpc(self)
	end 

end

function CWalker.IsInScreen(self)
	local vWorldPos = self:GetPos()
	local oCam = g_CameraCtrl:GetMainCamera()
	local vViewPos = oCam:WorldToViewportPoint(vWorldPos)
	if (oCam:GetEnabled() == true) and vViewPos.x < 1.3 and vViewPos.x > -0.3 and vViewPos.y < 1.3 and vViewPos.y > -0.3 then
		return true
	else
		return false
	end 
end

function CWalker.GetState(self)
	return self.m_Actor:GetState()
end

function CWalker.OnChangeDone(self)

	if self.classname == "CHero" then
		--self:SetMoveSpeed(g_GmCtrl.m_GMRecord.Logic.heroSpeed)
		if self.m_Actor:GetState() == self.m_WalkActionName then
			self:CrossFade(self.m_WalkActionName, define.Walker.CrossFade_Time)
		end
		self:ShowRideEffect(define.Performance.Level.high)
		self:ShowWingEffect(define.Performance.Level.high)
		self:ShowWeaponEffect(define.Performance.Level.high)
		g_DancingCtrl:AddTip()
	elseif self.classname == "CPlayer" then
		if self.m_Actor:GetState() == self.m_WalkActionName then
			self:CrossFade(self.m_WalkActionName, define.Walker.CrossFade_Time)
		end
		self:ShowAllParticle(self:IsShow())
		g_DancingCtrl:AddDanceTip(self, self.m_Actor:GetShape())
	elseif self.StartWalkerPatrol and self.classname ~= "CMapSummon" and self.classname ~= "CTaskPickItem" then
		local animaInfo = ModelTools.GetAnimClipData(self.m_Actor.m_Shape)
		if animaInfo and animaInfo.show then
			self.m_HasShowClip = true
		end
		self:StartWalkerPatrol()
	end
	if self.StartWalkerHeadTalk and self.classname ~= "CMapSummon" and self.classname ~= "CTaskPickItem" then
		self:StartWalkerHeadTalk()
	end

	if self.ResetHudNode and type(self.ResetHudNode) == "function" then
		--self:ResetHudNode()
	end
	
	if self.m_Cb then
		self.m_Cb()
		self.m_Cb = nil
	end

	g_FlyRideAniCtrl:UpdateFollowDis(self)

	self:SetMapID(g_MapCtrl:GetResID())
	self.m_Walker:ModelDoneFinish()

	if self:IsWalking() then 
		self:CrossFade(self.m_WalkActionName, define.Walker.CrossFade_Time)
	end 

end

function CWalker.ChangeFollow(self, oWalker, distance)
	distance = distance or define.Walker.Follow_Distance
	if oWalker == nil then
		self.m_IsFollowing = false
		self.m_FollowTarget = nil
		self.m_Walker:Follow(nil, distance)
	else
		self.m_IsFollowing = true
		self.m_FollowTarget = oWalker
		self.m_Walker:Follow(oWalker.m_Walker, distance)
	end
end

function CWalker.SetFollowDis(self, distance)
	
	distance = distance or define.Walker.Follow_Distance
	self.m_FollowDis = distance
	self.m_Walker:SetFollowDis(distance)
end

function CWalker.ShowWeapon(self, isShow)
	
	self.m_Actor:ShowWeapon(isShow)
end


function CWalker.Follow(self, oWalker, distance)
	--正在踩水的时候不能follow其他人
	if self.m_IsFlyWaterProgress then
		return
	end
	--self.m_StopCallback里面可能会有调用Follow方法，再次调用self:StopWalk()会置空self.m_StopCallback
	if not self.m_StopCallback then
		self:StopWalk()
	end
	self:ChangeFollow(oWalker, distance)
end

function CWalker.Play(self, state, normalizedTime)
	self.m_Actor:Play(state, normalizedTime)
end

function CWalker.CrossFade(self, state, duration, normalizedTime)
	if self.classname == "CMapSummon" then
		if self.m_FollowTarget then
			local followTarget = self.m_FollowTarget 
			local isInTeam = g_MapCtrl:IsWalkerInTeam(followTarget.m_Pid)
			if isInTeam then 
				local leader = g_MapCtrl:GetTeamLeader(followTarget.m_Pid)
				if leader and leader:IsInFlyState() then 
					self.m_Actor:CrossFade(self.m_IdleActionName, duration, normalizedTime)
				else
					self.m_Actor:CrossFade(state, duration, normalizedTime)
				end 
			else
				if followTarget:IsInFlyState() then 
					self.m_Actor:CrossFade(self.m_IdleActionName, duration, normalizedTime)
				else
					self.m_Actor:CrossFade(state, duration, normalizedTime)
				end 
			end  
		end
	else
		local isInTeam = g_MapCtrl:IsWalkerInTeam(self.m_Pid)
		if isInTeam then 
			local leader = g_MapCtrl:GetTeamLeader(self.m_Pid)
			if leader and leader:IsInFlyState() then 
				if self:IsOnFlyRide() then 
					self.m_Actor:CrossFade(state, duration, normalizedTime)
				else
					self.m_Actor:CrossFade(self.m_IdleActionName, duration, normalizedTime)
				end 
			else
				self.m_Actor:CrossFade(state, duration, normalizedTime)
			end 
		else
			self.m_Actor:CrossFade(state, duration, normalizedTime)
		end 
	end

end

function CWalker.CrossFadeByLoop(self, state, duration, normalizedTime, loopTimes, cb)
	local animaInfo = ModelTools.GetAnimClipData(self.m_Actor.m_Shape)
	if not animaInfo or loopTimes == 0 then
		return
	end
	local clipInfo = animaInfo[state]
	if not clipInfo then
		return
	end
	local function play()
		if Utils.IsNil(self) or loopTimes == 0 then
			if cb then
				cb()
			end
			return false
		end
		self:CrossFade(state, duration, normalizedTime, loopTimes)
		loopTimes = loopTimes - 1
		return true
	end
	Utils.AddTimer(play, tonumber(clipInfo.length), 0)
end

function CWalker.SetWalkAniName(self, sName)
	self.m_WalkActionName = sName
end

function CWalker.AddFootCloudEffect(self)
	
	local path = "Effect/Scene/scene_eff_0030/Prefabs/scene_eff_0030.prefab"

	if not self.m_FootCloudEffect then
		local function effectDone ()
			if self.m_FootCloudEffect then 
				self.m_FootCloudEffect:SetParent(self.m_Actor.m_Transform)
				self.m_FootCloudEffect:SetLocalEulerAngles(Vector3.New(0, 135, 0))
				local layer = self:GetLayer()
				self.m_FootCloudEffect:SetLayer(layer)
			end 
		end
		self.m_FootCloudEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer(self:GetLayer()), true, effectDone)
	end 

end

function CWalker.DelFootCloudEffect(self)
	
	if self.m_FootCloudEffect then 
		self.m_FootCloudEffect:Destroy()
		self.m_FootCloudEffect = nil
	end 

end

function CWalker.AddJinZhongZhaoEffect(self)
	-- body
	local path = "Effect/Buff/buff_eff_10003_foot/Prefabs/buff_eff_10003_foot.prefab"

	if not self.m_JinZhongZhaoEffect then
		local function effectDone ()
			self.m_JinZhongZhaoEffect:SetParent(self.m_Transform)	
		end
		self.m_JinZhongZhaoEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("Default"), true, effectDone)
	end
end

function CWalker.DelJinZhongZhaoEffect(self)
	-- body
	if self.m_JinZhongZhaoEffect then 
		self.m_JinZhongZhaoEffect:Destroy()
		self.m_JinZhongZhaoEffect = nil
	end
end


function CWalker.GetModelInfo(self)
	return self.m_ModelInfo
end


function CWalker.FlyAni(self, height, camSize, doAni, cb)


	if camSize > 5.5 then   
		printerror("---------camSize cannot larger then 5.5, Check Ridedata ")
		return
	end 

 	camSize = camSize or 5.5
    local scaleFactor = camSize / 3.5

    local flyTime = define.Fly.Data.FlyTime

    self.m_Walker:SetFlyOffset(70);
    self.m_Walker:SetStraightWalk(true)

	if doAni then
		local tweenFoot = DOTween.DOLocalMoveY(self.m_FootTrans, height, flyTime)
	    local tweenHeight = DOTween.DOLocalMoveY(self.m_Actor.m_Transform, height, flyTime)
	    local tween = DOTween.DOScale(self.m_Actor.m_Transform, Vector3.New(scaleFactor, scaleFactor, scaleFactor), flyTime)
	    DOTween.SetEase(tween, 2) 
	    DOTween.SetEase(tweenHeight, 2)
	    DOTween.SetEase(tweenFoot, 2)
	      
		if self.classname == "CHero" then
			g_HudCtrl:ScaleHudLayer(define.Fly.Data.HudScaleFactor, true)
		end
		
	    local onTweenUpdate = function ()
	    	if self.m_Actor then 
	    		self.m_Actor:AdjustHudPos()
	    	end 
	    end

	    local onFinish = function ()
	    	if self.m_Actor then 
		    	self.m_Actor:AdjustCollider()
				self:IgnoreTransparentArea(true)

		    	if cb then 
		    		cb(self)
		    	end 
	    	end
	    end

	    DOTween.OnUpdate(tween, onTweenUpdate)
	    DOTween.OnComplete(tween, onFinish)

	else
		self.m_FootTrans.localPosition = Vector3.New(0, height, 0)
		self.m_Actor:SetLocalPos(Vector3.New(0, height, 0))
        self.m_Actor:SetLocalScale(Vector3.New(scaleFactor,scaleFactor,scaleFactor))
        self.m_Actor:AdjustHudPos()
        self.m_Actor:AdjustCollider()
        self:IgnoreTransparentArea(true)

        if self.classname == "CHero" then  
	     	g_HudCtrl:ScaleHudLayer(define.Fly.Data.HudScaleFactor)
	    end

        if cb then 
	   		cb(self)
	   	end 

	end 

end


function CWalker.LandAni(self, doAni, cb)

	local oMainCam = g_CameraCtrl:GetMainCamera()

	local landTime = define.Fly.Data.FlyTime

	self.m_Walker:SetFlyOffset(0);

	local footNodeOffset = self:GetFootNodeOffset()
	self.m_Walker:SetStraightWalk(false)

	if doAni then 
		
		self:StopWalk()
		local tween = DOTween.DOScale(self.m_Actor.m_Transform, Vector3.one , landTime)
		local tweenHeight = DOTween.DOLocalMoveY(self.m_Actor.m_Transform, 0, landTime)

		if self.classname == "CHero" then  
	     	g_HudCtrl:ScaleHudLayer(nil, true)
	    end

		if footNodeOffset then 
			local tweenFoot = DOTween.DOLocalMoveY(self.m_FootTrans, footNodeOffset, landTime)
			DOTween.SetEase(tweenFoot, 2) 
		end 

		local onFinish = function ()
			if self.m_Actor then 
				self.m_Actor:AdjustCollider()
				self.m_Actor:AdjustHudPos()
				self:IgnoreTransparentArea(false)
				self:CorrectLandPos()
			    if cb then
			        cb(self)
			    end 
			end 
		end

		DOTween.SetEase(tween, 2) 
		DOTween.SetEase(tweenHeight, 2) 
		local onTweenUpdate = function ()
		   if self.m_Actor then 
		   		self.m_Actor:AdjustHudPos()
		   end
		end
		DOTween.OnUpdate(tween, onTweenUpdate)
		DOTween.OnComplete(tween, onFinish)

	else

		if footNodeOffset then 
			self.m_FootTrans.localPosition = Vector3.New(0, footNodeOffset, 0)
		end

	    self.m_Actor:SetLocalScale(Vector3.one)
		self.m_Actor:SetLocalPos(Vector3.zero)
	    self.m_Actor:AdjustHudPos()
	    self.m_Actor:AdjustCollider()
	   	self:IgnoreTransparentArea(false)

	   	if self.classname == "CHero" then  
	     	g_HudCtrl:ScaleHudLayer()
	    end

	   	self:CorrectLandPos()

	   	if cb then 
	   		cb(self)
	   	end 

	end 

end

function CWalker.GetRideSpeed(self, isInFlyRide)
	
	if self.m_ModelInfo and self.m_ModelInfo.horse and self.m_ModelInfo.horse > 0 then 
		local horseId = self.m_ModelInfo.horse
		local config = data.ridedata.RIDEINFO[horseId]
		if isInFlyRide then
			return config.flySpeed
		else
			return config.speed
		end 
	else
		return g_MapCtrl:GetWalkerDefaultSpeed(true)
	end 

end


--获取walker的跟随距离
function CWalker.GetWalkerFollowDis(self)

	return self.m_FollowDis 

end

function CWalker.GetFlyHeight(self)
	
	if self:IsOnRide() then 
		local horseId = self.m_ModelInfo.horse
		local config = data.ridedata.RIDEINFO[horseId]
		return config.height
	else
		return 0
	end 

end

--获取在陆地上的跟随距离
function CWalker.GetFollowDis(self)
	
	if self.m_ModelInfo and self.m_ModelInfo.horse and self.m_ModelInfo.horse > 0 then 
		local horseId = self.m_ModelInfo.horse
		local config = data.ridedata.RIDEINFO[horseId]
		return config.walkerDis
	else

		return define.Walker.Follow_Distance
	end

end

function CWalker.GetFlyCamSize(self)
	
	if self.m_ModelInfo and self.m_ModelInfo.horse and self.m_ModelInfo.horse > 0 then 
		local horseId = self.m_ModelInfo.horse
		local config = data.ridedata.RIDEINFO[horseId]
		return config.camSize
	else
		return 3.5
	end 

end

function CWalker.IsInFlyState(self)
	return self.m_FlyHeight == define.FlyRide.FlyState.Fly
end


function CWalker.IsOnFlyRide(self)
	
	if  self.m_ModelInfo and  self.m_ModelInfo.horse and self.m_ModelInfo.horse > 0 then 
		local horseId = self.m_ModelInfo.horse
		local config = data.ridedata.RIDEINFO[horseId]
		if config.flymap == 1 then		
			return true
		end 
	end 

	return false

end

function CWalker.IsOnGroundRide(self)

	if self.m_ModelInfo and self.m_ModelInfo.horse and self.m_ModelInfo.horse > 0 then 
		local horseId = self.m_ModelInfo.horse
		local config = data.ridedata.RIDEINFO[horseId]
		if config then 
			if config.flymap == 0 then		
				return true
			end
		end 
	end 

	return false
end

function CWalker.IsOnRide(self)

	if self.m_IsUsing and self.m_ModelInfo and self.m_ModelInfo.horse and self.m_ModelInfo.horse > 0 then 
		return true
	else
		return false
	end 

end

function CWalker.IsWearWing(self)
	
	if self.m_IsUsing and self.m_ModelInfo and self.m_ModelInfo.show_wing and self.m_ModelInfo.show_wing > 0 then 
		return true
	else
		return false
	end

end

function CWalker.ShowWalker(self, isShow)

	if self.m_ShowState == isShow then 
		return
	end

	self.m_ShowState = isShow
	if isShow then 
		if self.hideByMarry then
			return
		end
		-- 有可能hud未加载，只缓存数据
		if self.m_IsCacheChangeScreenCb then
			self:ChangeInScreenCb(true)
			self.m_IsCacheChangeScreenCb = false
		end
		self.m_HudNode:SetPosHide(false)
		self:SetLayer(self.m_Layer, true)
		self:ShowAllParticle(true)
	else
		self.m_HudNode:SetPosHide(true)
		self:SetLayer(UnityEngine.LayerMask.NameToLayer("Hide"), true)
		self:ShowAllParticle(false)
	end 

end

function CWalker.ShowAllParticle(self, isShow)
	
	if not self:IsAllModelLoadDone() then 
		return
	end 

	if isShow then 
		local lv = g_SystemSettingsCtrl:GetRideEffectLv()
		self:ShowRideEffect(lv)
		lv = g_SystemSettingsCtrl:GetWingEffectLv()
		self:ShowWingEffect(lv)
		lv = g_SystemSettingsCtrl:GetWeaponEffectLv()
		self:ShowWeaponEffect(lv)
	else
		self:ShowRideEffect(0)
		self:ShowWeaponEffect(0)
		self:ShowWingEffect(0)
	end 

end

function CWalker.ShowFollower(self, isShow)
	
	if self.m_Followers and next(self.m_Followers) then 
		for k, v in pairs( self.m_Followers ) do
			if isShow then 
				v:ShowWalker(true)
				g_FlyRideAniCtrl:ShowSummon(v)
			 	g_FlyRideAniCtrl:ShowFollowNpc(v)
			else
				v:ShowWalker(false)
			end 	
		end
	end

end

function CWalker.IsAllModelLoadDone(self)
	
	if self.m_Actor then 
		return self.m_Actor:IsAllModelLoadDone()
	end 

end

function CWalker.ShowAll(self, isShow)
	
	if not self:IsAllModelLoadDone()  then 
		return
	end 

	self:ShowWalker(isShow)
	self:ShowFollower(isShow)

end

function CWalker.IsShow(self)
	
	return self.m_ShowState

end

function CWalker.IgnoreTransparentArea(self, isIgnore)
	
	isIgnore = isIgnore and true
	self.m_Walker:IgnoreTransparent(isIgnore)

end


function CWalker.IsTriggerWaterRun(self)

	if self.classname == "CHero" or self.classname == "CPlayer" then
		local isInTeam = g_MapCtrl:IsWalkerInTeam(self.m_Pid)
		if isInTeam then 
			local leader = g_MapCtrl:GetTeamLeader(self.m_Pid)
			if leader then
				if not leader:IsInFlyState() then 
					return true
				else
					return false
				end
			else
				return true
			end 
		else
			if not self:IsInFlyState() then 
				return true
			else
				return false
			end 
		end 
	else
		return true
	end

end


function CWalker.CorrectLandPos(self)

	if not self.m_IsUsing then 
		return
	end 

	local oCam = g_CameraCtrl:GetMapCamera()

	if not oCam.curMap then 
		return
	end 
	
	local isInTeam = g_MapCtrl:IsWalkerInTeam(self.m_Pid)
	local isLeaderSelf = g_MapCtrl:IsLeaderSelf(self.m_Pid)
	local leader = g_MapCtrl:GetTeamLeader(self.m_Pid)

    local oCam = g_CameraCtrl:GetMapCamera()
    if  isInTeam then
    	if not leader then
    		return
    	end
    	if  not isLeaderSelf  then 
    		if not g_MapCtrl:IsWalkable(self:GetPos().x, self:GetPos().y) then 
				self.m_Walker:WalkTo2(leader:GetPos().x, leader:GetPos().y)
	    		self:CrossFade("run", define.Walker.CrossFade_Time)
    		end
    	else
    		if not g_MapCtrl:IsWalkable(self:GetPos().x, self:GetPos().y) then 
    			local pos = g_MapCtrl:GetNearWalkablePos(self)
		    	local p = self:GetPos()
		    	self:SetPos(Vector3.New(pos.x,pos.y,p.z))
    		end
    	end 
    else
    	local pos = g_MapCtrl:GetNearWalkablePos(self)
    	local p = self:GetPos()
    	self:SetPos(Vector3.New(pos.x,pos.y,p.z))
    end 

end


function CWalker.GetFollowNpc(self)
	
	if self.m_Followers and next(self.m_Followers) then 
		for k, v in pairs( self.m_Followers ) do
			if v then
				if v.m_Type == "n" then
					return v
				end
			end 	
		end
	end 

end

function CWalker.GetFollowSummon(self)
	
	if self.m_Followers and next(self.m_Followers) then 
		for k, v in pairs( self.m_Followers ) do
			if v then
				if v.m_Type == "s" then
					return v
				end
			end 	
		end
	end 
	
end

function CWalker.SetUsing(self, isUsing)
	self.m_IsUsing = isUsing
	-- self:SetActive(isUsing)
	self:SetPosHide(not isUsing)
	if not isUsing then
		self:Reset()
	end

end

return CWalker
local CCameraCtrl = class("CCameraCtrl")

function CCameraCtrl.ctor(self)
	self.m_UICamera = nil
	self.m_MainCamera = nil
	self.m_NGUICamera = nil
	self.m_MapCamera = nil
	self.m_WarCamera = nil
	self.m_HouseCamera = nil
	self.m_WarUICamera = nil

	self.mm_CameraPathRoot = nil
	self.m_CameraPath = nil
	self.m_CameraAnimator = nil
	self.m_IsInit = false
	self.m_ModelCamDict = {}
	self.m_CurActorCamIdx = 0
	self.m_CachedCams = {}
	self.m_CameraGroup = {}

	self.m_FlyTween = nil
	local function func()
		return self:CheckAll()	
	end 
	Utils.AddTimer(func, 0, 0.5)
end

function CCameraCtrl.InitCtrl(self)
	if self.m_IsInit == false then
		self.m_IsInit = true
		local obj = UnityEngine.GameObject.New()
		obj.name = "CameraPathRoot"
		self.m_CameraPathRoot = obj
		self.m_CameraPath = self.m_CameraPathRoot:GetMissingComponent(classtype.CameraPath)
		self.m_CameraAnimator = self.m_CameraPathRoot:GetMissingComponent(classtype.CameraPathAnimator)
		self.m_CameraAnimator.playOnStart = false
		self.m_CameraAnimator.animationObject = self:GetWarCamera().m_Transform
	end
end

function CCameraCtrl.SetMapCameraSize(self, iSize)
	local oCam = self:GetMainCamera()
	oCam:SetOrthographicSize(iSize)
	local oMapCam = self:GetMapCamera()
	oMapCam:UpdateCameraSize()
end

function CCameraCtrl.GetNGUICamera(self)
	if not self.m_NGUICamera then
		self.m_NGUICamera = UnityEngine.GameObject.Find("GameRoot/UICamera"):GetComponent(classtype.UICamera)
	end
	return self.m_NGUICamera
end

function CCameraCtrl.LoadPath(self, sType)
	local path = string.format("Config/%s.bytes", sType)
	self.m_CameraPath:FromXML(path)
end

function CCameraCtrl.GetAnimatorPercent(self)
	return self.m_AnimatorPercent or 0
end

function CCameraCtrl.SetAnimatorPercent(self, iVal)
	local iVal = math.max(math.min(1, iVal), 0)
	-- if bRestore and not self.m_RestorePercnt then
	-- 	self.m_RestorePercnt = self.m_AnimatorPercent
	-- end
	self.m_AnimatorPercent = iVal
	self.m_CameraAnimator:Seek(iVal)
end

function CCameraCtrl.RestorePercent(self)
	if self.m_RestorePercnt then
		self:SetAnimatorPercent(self.m_RestorePercnt)
		self.m_RestorePercnt = nil
	end
end

function CCameraCtrl.GetMapCamera(self)
	if not self.m_MapCamera then
		local maingo = UnityEngine.GameObject.Find("GameRoot/MainCamera")
		self.m_MapCamera = maingo:GetMissingComponent(classtype.Map2DCamera)
	end
	return self.m_MapCamera
end

function CCameraCtrl.GetUICamera(self)
	if not self.m_UICamera then
		self.m_UICamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/UICamera"))
	end
	return self.m_UICamera
end

function CCameraCtrl.GetWarCamera(self)
	if not self.m_WarCamera then
		self.m_WarCamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/WarCamera"))
		self:AddGroup(self.m_WarCamera, "main")
	end
	return self.m_WarCamera
end

function CCameraCtrl.GetMainCamera(self)
	if not self.m_MainCamera then
		self.m_MainCamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/MainCamera"))
		self:AddGroup(self.m_MainCamera, "main")
	end
	return self.m_MainCamera
end

function CCameraCtrl.GetWarUICamera(self)
	if not self.m_WarUICamera then
		self.m_WarUICamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/WarUICamera"))
	end
	return self.m_WarUICamera
end

function CCameraCtrl.AddGroup(self, oCam, sGroupName)
	local dGroup = self.m_CameraGroup[sGroupName] or {}
	oCam.m_CameraGroup = sGroupName
	dGroup[oCam:GetInstanceID()] = oCam
	self.m_CameraGroup[sGroupName] = dGroup
end

function CCameraCtrl.AutoActive(self)
	local isWar = g_WarCtrl:IsWar()
	local warUICameraFlags = 3
	local oCam = nil
	local sceneName = Utils.GetActiveSceneName()
	if g_WarCtrl:IsWarSky() then
		if isWar then
			if g_WarCtrl.m_WarWeather and g_WarCtrl.m_WarWeather == 2 then
				warUICameraFlags = 3
			end
			oCam = self:GetWarCamera()
		else
			oCam = self:GetMainCamera()
			self:GroupActive(oCam)
		end
		-- if sceneName ~= "editorMagic" then
		-- 	self:SetMapCameraSize(5)
		-- end
	else
		if isWar then
			if not g_MapCtrl:GetResID() then
				-- warUICameraFlags = 2
			end

			oCam = self:GetWarCamera()
			oCam.m_Camera.enabled = true
		else
			oCam = self:GetMainCamera()
			self:GroupActive(oCam)
		end
		-- self:GroupActive(oCam)
		-- if sceneName ~= "editorMagic" then
		-- 	self:SetMapCameraSize(3.5)
		-- end
	end
	local warUICamera = self:GetWarUICamera()
	warUICamera.m_Camera.clearFlags = warUICameraFlags
	warUICamera:SetEnabled(isWar)
	
	if isWar and oCam then
		local engineFactor = UnityEngine.Screen.width / UnityEngine.Screen.height
		if engineFactor < 1 then
			 -- 屏幕旋转导致的战斗相机异常
			engineFactor = 1 / engineFactor
		end
		-- 只取该区间的值
		engineFactor = math.min(engineFactor, 16/9)
		engineFactor = math.max(engineFactor, 4/3)

		local camSize = data.lineupdata.Others[1].cameraSize
		-- 以4:3为基准
		-- local scaleFactor = engineFactor / (1024 / 768) * 0.97;
		-- oCam:SetOrthographicSize(4.78533 / scaleFactor)

		-- 以16:9为基准
		local scaleFactor = engineFactor / (16 / 9)-- * 0.97
		oCam:SetOrthographicSize(camSize / scaleFactor)
	end
end

function CCameraCtrl.GroupActive(self, oCam)
	for id, oGroupCam in pairs(self.m_CameraGroup[oCam.m_CameraGroup]) do
		oGroupCam:SetEnabled((oGroupCam == oCam))
	end
end

function CCameraCtrl.GetActorCamra(self, iShape)
	local oCam = self:GetInRecycle("CActorCamera", function(oCam)
		return oCam:GetShape() == iShape
	end)
	if oCam then
		oCam:ResetActor()
	else
		oCam = CActorCamera.New()
		local pos = self:GetNewPos()
		oCam:SetPos(pos)
	end
	self.m_ModelCamDict[oCam:GetInstanceID()] = oCam
	return oCam
end

function CCameraCtrl.DoFlyCamAnimation(self, height, time, cb)
	
	local mainCam =  self:GetMainCamera()
	local mapCamComp =  self:GetMapCamera()
	local tween = nil

	tween = DOTween.DOOrthoSize(mainCam.m_Camera, height , time)

	DOTween.SetEase(tween, 2) 

	local onTweenUpdate = function (...)
		 mapCamComp:UpdateCameraSize()
	end

	local onTweenFinish = function ( ... )
		
		if cb then 
			cb()
		end 
		self.m_FlyTween = nil
	end

	DOTween.OnUpdate(tween, onTweenUpdate)
	DOTween.OnComplete(tween, onTweenFinish)

	self.m_FlyTween = tween
end

function CCameraCtrl.StopFlyTween(self)
	if self.m_FlyTween then
		self.m_FlyTween:Kill(true)
		self.m_FlyTween = nil
	end
end

function CCameraCtrl.GetInRecycle(self, classname, checkfunc)
	local list = self.m_CachedCams[classname] or {}
	local idx = nil
	if list and #list > 0 then
		for i, oCam in ipairs(list) do
			if not checkfunc or checkfunc(oCam) then
				idx = i
				break
			end
		end
		if not idx then
			idx = 1
		end
	end
	if idx then
		local recycle = list[idx]
		table.remove(list, idx)
		recycle:SetActive(true)
		return recycle
	end
end

function CCameraCtrl.Recycle(self, oCam)
	self.m_ModelCamDict[oCam:GetInstanceID()] = nil
	local list = self.m_CachedCams[oCam.classname] or {}
	if #list < 5 then
		if not table.index(list, oCam) then
			table.insert(list, oCam)
			self.m_CachedCams[oCam.classname] = list
		end
		oCam:ClearActor()
		oCam:ClearTexture()
		oCam:SetActive(false)
	else
		oCam:Destroy()
	end
end

function CCameraCtrl.GetNewPos(self)
	local i = self.m_CurActorCamIdx
	local pos = Vector3.New(i*50 + 1000, 0, 0)
	self.m_CurActorCamIdx = i + 1
	return pos
end

function CCameraCtrl.CheckCachedCam(self)
	for i, oCam in pairs(self.m_ModelCamDict) do
		local owner = oCam:GetOwner()
		if  Utils.IsNil(owner) then
			self:Recycle(oCam)
		end
	end
end


function CCameraCtrl.CheckAll(self)
	self:CheckCachedCam()
	return true
end

-- 移动相机
function CCameraCtrl.GetCameraInfo(self, type, key)
	local tInfo
	if type == "war" and key == "current" then
		local oCam = g_CameraCtrl:GetWarCamera()
		local p = oCam:GetLocalPos()
		local r = oCam:GetLocalEulerAngles()
		tInfo = {
			pos = oCam:GetLocalPos(),
			rotate = oCam:GetLocalEulerAngles(),
		}
	else
		local tData = data.cameradata.INFOS[type][key]
		if tData then
			tInfo = {
			pos= Vector3.New(tData.pos.x, tData.pos.y, tData.pos.z),
			rotate= Vector3.New(tData.rotate.x, tData.rotate.y, tData.rotate.z)}
		end
	end
	if not tInfo then
		tInfo = {pos=Vector3.zero, rotate=Vector3.zero}
	end
	return tInfo
end

function CCameraCtrl.PlayAction(self, sType)
	self:InitCtrl()
	local oCamera, info, vLookPos, vLookUp, iMoveTime
	if sType == "war_default" then
		local oRoot = g_WarCtrl:GetRoot()
		self.m_CameraAnimator.orientationTarget = oRoot:GetLookAtTarget()
		self:LoadPath("CameraPath_War")
		self:SetAnimatorPercent(0.534)
	elseif sType == "house" then
		self:LoadPath(sType)
	-- elseif sType == "war_replace" then
	-- 	oCamera = g_CameraCtrl:GetWarCamera()
	-- 	info = self:GetCameraInfo("war", "replace")
	-- elseif sType == "war_replace_end" then
	-- 	self:SetAnimatorPercent(0)
	elseif sType == "war_win" then
		oCamera = g_CameraCtrl:GetWarCamera()
		info = self:GetCameraInfo("war", "war_win")
		iMoveTime = 1
		vLookPos = MagicTools.GetCommonPos("ally_team_center")
		vLookPos.y = 1
		vLookUp = g_WarCtrl:GetRoot().m_Transform.up
	end
	if oCamera and info then
		local pos = Vector3.New(info.pos.x, info.pos.y, info.pos.z)
		if iMoveTime then
			local oAction1 = CCircleMove.New(oCamera, iMoveTime, oCamera:GetPos(), pos)
			g_ActionCtrl:AddAction(oAction1)
			if vLookPos then
				local oAction2 = CLookAt.New(oCamera, iMoveTime, vLookPos, vLookUp)
				g_ActionCtrl:AddAction(oAction2)
			end
		else
			oCamera:SetLocalPos(pos)
			oCamera:SetEulerAngles(info.rotate)
		end
	end
end

return CCameraCtrl

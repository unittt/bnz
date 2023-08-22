local CPlotCameraCtrl = class("CPlotCameraCtrl")

function CPlotCameraCtrl.ctor(self, dCamera, elapsedTime)
	self.m_CameraInfo = dCamera
	self.m_ElapsedTime = elapsedTime
	self.m_SizeTween = nil
	self:Init(dCamera)
end

function CPlotCameraCtrl.Init(self, dCamera)
	local oCam = g_CameraCtrl:GetMapCamera()
	local obj = CObject.New(UnityEngine.GameObject.New("PlotCameraTarget"))

	self.m_Go = obj
	self.m_Camera = oCam
	self.m_MainCamera = g_CameraCtrl:GetMainCamera()
	self.m_Transform = obj.m_Transform
	self.m_DefaultCamSize = nil

	g_CameraCtrl:StopFlyTween()
	oCam:SetCameraOffsetY(0, false, 0)

	self.m_DefaultCamSize = self.m_MainCamera:GetOrthographicSize()
	-- 重置相机
	self.m_MainCamera:SetOrthographicSize(3.5)
	self.m_Camera:UpdateCameraSize()
	
	obj:SetLocalPos(Vector3.New(dCamera.originPos.x, dCamera.originPos.y, 0))
	oCam:Follow(obj.m_Transform)
	oCam:SyncTargetPos()

	local oSequence = DOTween.Sequence()
	self.m_Sequence = oSequence
	--添加剧情结束回调
	self.m_StartTime = dCamera.startTime
	if self.m_ElapsedTime and self.m_ElapsedTime > self.m_StartTime then
		self.m_StartTime = self.m_ElapsedTime
	end
	oSequence:AppendInterval(dCamera.endTime - self.m_StartTime)
	DOTween.OnComplete(oSequence, callback(self, "Dispose"))

	self:ExcuteTransformActions(dCamera.tweenActionList)
	self:ExcuteShakeActions(dCamera.shakeActionList)
	self:ExcuteSizeActions(dCamera.sizeActionList)
end

function CPlotCameraCtrl.ExcuteTransformActions(self, tActionList)
	for i,oAction in ipairs(tActionList) do
		if oAction.active then
			local waitTime = self:GetActionWaitTime(oAction)
			if waitTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, waitTime, callback(self, "PlayTransformAction", oAction))
			else
				self:PlayTransformAction(oAction, waitTime)
			end
		end
	end
end

function CPlotCameraCtrl.ExcuteShakeActions(self, tActionList)
	for i,oAction in ipairs(tActionList) do
		if oAction.active then
			local waitTime = self:GetActionWaitTime(oAction)
			if waitTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, waitTime, callback(self, "PlayShakeAction", oAction))
			else
				self:PlayShakeAction(oAction, waitTime)
			end
		end
	end
end

function CPlotCameraCtrl.ExcuteSizeActions(self, tActionList)
	if not tActionList then return end
	for i,oAction in ipairs(tActionList) do
		if oAction.active then
			local waitTime = self:GetActionWaitTime(oAction)
			if waitTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, waitTime, callback(self, "PlaySizeAction", oAction))
			else
				self:PlaySizeAction(oAction, waitTime)
			end
		end
	end
end

function CPlotCameraCtrl.PlayShakeAction(self, oShakeAction, time)
	local function OnComplete()
		--TODO:dosomething maybe
	end
	local oStrength = Vector3.New(oShakeAction.strength.x, oShakeAction.strength.y, oShakeAction.strength.z)
	--self.m_Go.m_Transform
	local shakeTime = oShakeAction.duration
	if time and time < 0 then
		shakeTime = shakeTime + time
		if shakeTime <= 0 then
			return
		end
	end
	self.m_Camera.target:DOShakePosition(shakeTime, oStrength, oShakeAction.vibrato, oShakeAction.randomness, true, true)
end

function CPlotCameraCtrl.PlayTransformAction(self, oTransformAction, time)
	if oTransformAction.tweenType == define.Plot.TweenType.PosMove or oTransformAction.tweenType == define.Plot.TweenType.NavMove then
		local iSpeed = 1
		local oTarget = self.m_Transform
		if oTransformAction.speed and oTransformAction.speed > 0 then
			iSpeed = oTransformAction.speed
		end
		local iDuration = Vector3.Distance(oTarget.localPosition, oTransformAction.endValue)/iSpeed
		local oPos = Vector3.New(oTransformAction.endValue.x, oTransformAction.endValue.y, oTransformAction.endValue.z)
		if time and time < 0 then
			local leftTime = time + iDuration
			if leftTime > 0 then
				local midPos = Vector3.Slerp(oTarget.localPosition, oPos, -time/iDuration)
				oTarget.localPosition = midPos
				self.m_Camera:SyncTargetPos()
				DOTween.DOMove(oTarget, oPos, leftTime)
			else
				oTarget.localPosition = oPos
				self.m_Camera:SyncTargetPos()
			end
		else
	   		DOTween.DOMove(oTarget, oPos, iDuration)
		end
	elseif oTransformAction.tweenType == define.Plot.TweenType.Rotate3D then
		local oRotate = Quaternion.Euler(oTransformAction.endValue.x, oTransformAction.endValue.y, oTransformAction.endValue.z)
		local oCam = self.m_Camera.transform
		if time and time < 0 then
			local leftTime = time + oTransformAction.duration
			if leftTime > 0 then
				local midRot = Quaternion.Lerp(oCam.localRotation, oRotate, -time/oTransformAction.duration)
				self.m_Camera.transform.localRotation = midRot
				DOTween.DOLocalRotateQuaternion(oCam, oRotate, leftTime)
			else
				oCam.localRotation = oRotate
			end
		else
			DOTween.DOLocalRotateQuaternion(oCam, oRotate, oTransformAction.duration)
		end
	end
end

function CPlotCameraCtrl.PlaySizeAction(self, oSizeAction, time)
	local changeTime = oSizeAction.duration
	if time and time < 0 then
		changeTime = changeTime + time
	end
	if changeTime <= 0 then
		self.m_MainCamera:SetOrthographicSize(oSizeAction.size)
		self.m_Camera:UpdateCameraSize()
	else
		local tween = DOTween.DOOrthoSize(self.m_MainCamera.m_Camera, oSizeAction.size, changeTime)
		DOTween.OnUpdate(tween, callback(self.m_Camera, "UpdateCameraSize"))
		DOTween.OnComplete(tween, function()
			self.m_SizeTween = nil
		end)
		self.m_SizeTween = tween
	end
end

function CPlotCameraCtrl.GetActionWaitTime(self, dAction)
	return dAction.startTime - (self.m_ElapsedTime or 0)
end

function CPlotCameraCtrl.Pause(self)
	if self.m_Sequence then
		self.m_Sequence:Pause()
	end
end

function CPlotCameraCtrl.Resume(self)
	if self.m_Sequence then
		self.m_Sequence:Play()
	end
end

function CPlotCameraCtrl.Dispose(self)
	if self.m_Sequence then
		self.m_Sequence:Kill(true)	
		self.m_Sequence = nil
	end
	if self.m_Go then
		self.m_Go:Destroy()
		self.m_Go = nil
	end
	if self.m_SizeTween then
		self.m_SizeTween:Kill(false)
		self.m_SizeTween = nil
	end
	if self.m_DefaultCamSize then
		g_CameraCtrl:SetMapCameraSize(self.m_DefaultCamSize)
		self.m_DefaultCamSize = nil
	end
	g_FlyRideAniCtrl.m_IsFlying = false
end
return CPlotCameraCtrl
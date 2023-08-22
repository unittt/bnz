local CPlotCharacterCtrl = class("CPlotCharacterCtrl")

function CPlotCharacterCtrl.ctor(self, dCharInfo, oWalker, elapsedTime)
	self.m_CharInfo = dCharInfo
	self.m_Walker = oWalker
	self.m_IsModelActive = true 
	self.m_IsPersonActive = true
	self.m_ElapsedTime = elapsedTime

	self.m_IsStopAnim = false
	self.m_StopAnimTimer = nil

	self.m_CacheAnim = nil
	self.m_InitDone = false

	self:Init(dCharInfo)
end

function CPlotCharacterCtrl.Init(self, dCharInfo)
	self:FollowCamera(dCharInfo)
	self:ChangeShape(dCharInfo)
	self:ShowInfo(dCharInfo)
end

function CPlotCharacterCtrl.ChangeShape(self, dCharInfo)
	local dModelInfo = self:GetModelInfo(dCharInfo)
	if not dModelInfo then
		return
	end
	if dModelInfo.shizhuang then
		local config =  data.ransedata.SHIZHUANG[dModelInfo.shizhuang]
		if config then
			dModelInfo.figure = config.model
			dModelInfo.shape = config.model
		end
	end
	local figure = self:GetShapeId(dModelInfo)
	if figure and figure ~= 0 then
		local npcId = self.m_CharInfo.npcId
		if npcId == 1 or npcId == 2 then
			self.m_Walker.m_Actor.loadAnimType = 4
		end
		self.m_Walker:ChangeShape(dModelInfo, callback(self, "OnChangeShapeDone"))
	end
end

function CPlotCharacterCtrl.GetShapeId(self, dModelInfo)
	dModelInfo = dModelInfo or self:GetModelInfo(self.m_CharInfo)
	local figure = dModelInfo and dModelInfo.shape
	if not figure or figure == 0 then
		figure = dModelInfo.figure
	end
	return figure
end

function CPlotCharacterCtrl.GetModelInfo(self, dCharInfo)
	local dModelInfo
	dCharInfo = dCharInfo or self.m_CharInfo
	if dCharInfo.isHero and tonumber(g_AttrCtrl.model_info.shape) ~= 0 then
		dModelInfo = table.copy(g_AttrCtrl.model_info)
		dModelInfo.horse = nil
		local name = string.format("[96F6FF]%s", g_AttrCtrl.name)
		self.m_Walker:SetName(name)
	else
		local figure = dCharInfo.modelId
		if figure == 0 then
			printerror("-----------"..dCharInfo.name.." 模型id为0------------------------- ")
			return
		end
		dModelInfo = {figure = figure}
	end
	return dModelInfo
end

function CPlotCharacterCtrl.OnChangeShapeDone(self)
	self.m_InitDone = true
	local animAction = self.m_CacheAnim
	if animAction then
		local time = (animAction.time or 0)-os.clock()+animAction.clock
		self:PlayAnimationAction(animAction.action, time)
	else
		local dCharInfo = self.m_CharInfo
		local anim = dCharInfo.defaultAnim
		if type(anim) ~= "userdata" then
			if anim == "die" then
				local oWalker = self.m_Walker
				--不执行动画切换，直接播死亡动作
				local function callback()
					if Utils.IsNil(oWalker) then
						return
					end
					oWalker:SetLocalPos(Vector3.New(dCharInfo.originPos.x, dCharInfo.originPos.y, 0))
				end
				Utils.AddTimer(callback, 0, 0.5)
				local figure = self:GetShapeId()
				local dInfo = ModelTools.GetAnimClipInfo(figure , anim)
				oWalker.m_Actor:PlayInFrame(dCharInfo.defaultAnim, dInfo.frame, dInfo.frame)
			elseif anim then
				self.m_Walker:CrossFade(anim)
			end
		end
	end
end

function CPlotCharacterCtrl.ShowInfo(self, dCharInfo)
	local oSequence = DOTween.Sequence()
	self.m_Sequence = oSequence
	--添加剧情结束回调
	local startTime = dCharInfo.startTime
	if self.m_ElapsedTime then
		startTime = startTime + self.m_ElapsedTime
	end
	oSequence:AppendInterval(dCharInfo.endTime - startTime)
	DOTween.OnComplete(oSequence, callback(self, "HideWalker"))

	self:ExcuteTransformActions(dCharInfo.tweenActionList)
	self:ExcuteTalkActions(dCharInfo.talkActionList)
	self:ExcuteEffectActions(dCharInfo.followEffectList)
	self:ExcuteAnimationActions(dCharInfo.animationActionList)
end

function CPlotCharacterCtrl.ExcuteTransformActions(self, tActionList)
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

function CPlotCharacterCtrl.ExcuteTalkActions(self, tActionList)
	for i,oAction in ipairs(tActionList) do
		if oAction.active then
			local waitTime = self:GetActionWaitTime(oAction)
			if waitTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, waitTime, callback(self, "PlayTalkAction", oAction))
			else
				self:PlayTalkAction(oAction, waitTime)
			end
		end
	end
end

function CPlotCharacterCtrl.ExcuteEffectActions(self, tActionList)
	for i,oAction in ipairs(tActionList) do
		if oAction.active and oAction.effPath and oAction.effPath ~= "" then
			local waitTime = self:GetActionWaitTime(oAction)
			if waitTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, waitTime, callback(self, "PlayFollowEffectAction", oAction))
			else
				self:PlayFollowEffectAction(oAction, waitTime)
			end
		end
	end
end

function CPlotCharacterCtrl.ExcuteAnimationActions(self, tActionList)
	for i,oAction in ipairs(tActionList) do
		if oAction.active and oAction.clip and oAction.clip ~= "" then
			local waitTime = self:GetActionWaitTime(oAction)
			if waitTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, waitTime, callback(self, "PlayAnimationAction", oAction))
			else
				self:PlayAnimationAction(oAction, waitTime)
			end
		end
	end
end

function CPlotCharacterCtrl.PlayTransformAction(self, oTransformAction, time)
	self.m_CurAction = oTransformAction
	local iTweenType = oTransformAction.tweenType
	local oActor = self.m_Walker.m_Actor
	if iTweenType == define.Plot.TweenType.NavMove or iTweenType == define.Plot.TweenType.PosMove then

		local x = oTransformAction.endValue.x
		local y = oTransformAction.endValue.y
		if time and time < 0 then
			self.m_Walker:SetLocalPos(Vector3.New(x, y, 0))
		else
			local iSpeed = 1
			if oTransformAction.speed > 0 then
				iSpeed = oTransformAction.speed
			end
			if iSpeed < 0.1 then
				self.m_Walker:SetLocalPos(Vector3.New(x, y, 0))	
			else
				self.m_Walker:SetMoveSpeed(iSpeed)
				self.m_Walker:SetWalkAniName(oTransformAction.isWalk and "walk" or "run")
				self.m_Walker:WalkTo(x, y)
			end
		end
	elseif iTweenType == define.Plot.TweenType.Rotate2D or iTweenType == define.Plot.TweenType.Rotate3D then
		local b2D = iTweenType == define.Plot.TweenType.Rotate2D
		local endVal = b2D and CGamePlotPlayer.ModelOrient[oTransformAction.orient] or oTransformAction.endValue
		local targetRot = Quaternion.Euler(endVal.x, endVal.y, endVal.z)
		if time and time < 0 then
			local leftTime = time + oTransformAction.duration
			if leftTime > 0 then
				local midRot = Quaternion.Lerp(oActor:GetLocalRotation(), targetRot, -time/oTransformAction.duration)
				oActor:SetLocalRotation(midRot)
				DOTween.DOLocalRotateQuaternion(oActor.m_Transform, targetRot, leftTime)
			else
				oActor:SetLocalRotation(targetRot)				
			end
		else
			DOTween.DOLocalRotateQuaternion(oActor.m_Transform, targetRot, oTransformAction.duration)
		end
	elseif iTweenType == define.Plot.TweenType.Scale then
		local oScale = Vector3.New(oTransformAction.endValue.x, oTransformAction.endValue.y, oTransformAction.endValue.z)
		if time and time < 0 then
			local leftTime = time + oTransformAction.duration
			if leftTime > 0 then
				local midScale = Vector3.Slerp(oActor:GetLocalScale(), oScale, -time/oTransformAction.duration)
				oActor:SetLocalScale(midScale)
				DOTween.DOScale(oActor.m_Transform, oScale, leftTime)
			else
				oActor:SetLocalScale(oScale)
			end
		else
			DOTween.DOScale(oActor.m_Transform, oScale, oTransformAction.duration)
		end
	elseif iTweenType == define.Mount then
		--TODO:坐骑暂时不支持
	end
end

function CPlotCharacterCtrl.PlayTalkAction(self, oTalkAction, time)
	local duration = oTalkAction.duration
	if time and time < 0 then
		duration = duration + time
		if duration <= 0 then
			return
		end
	end
	--TODO:持续时间暂时不支持，视情况后期添加
	local sText = self:GetTalkContent(oTalkAction)
	--math.max(oTalkAction.duration-1, 0)
	self.m_Walker:ChatMsg(sText, duration)
	-- if oTalkAction.duration > 0 then	
	-- else
	-- end
end

function CPlotCharacterCtrl.PlayFollowEffectAction(self, oEffectAction, time)
	local duration = oEffectAction.duration
	if time and time < 0 then
		duration = duration + time
		if duration <= 0 then
			return
		end
	end
	local bIsDefaultEff = true
	local sEffName = oEffectAction.effPath
	if oEffectAction.folderName ~= "Default" then
		sEffName = oEffectAction.folderName..sEffName..".Prefab"
		bIsDefaultEff = false
	end
	-- self.m_Walker:AddBindObj(sEffName)
	local function RemoveEff()
		if Utils.IsNil(self.m_Walker) then
			return
		end
		if bIsDefaultEff then
			self.m_Walker:DelBindObj(sEffName)
		else
			self.m_Walker:DelEffect(sEffName)
		end
	end
	local function LoadDone(oEffect)
		oEffect:SetActive(false)
		if oEffectAction.loop then
			oEffect:SetLoop(true)
		end	
		local list = oEffect.m_GameObject:GetComponentsInChildren(classtype.MeshRenderer)
		if list.Length > 0 then
			for i=0,list.Length-1 do
				local oMesh = list[i]
				if oMesh then
					local oTransform = oMesh.transform
					oTransform.gameObject:Destroy()
				end
			end
		end
		oEffect:SetActive(true)
	end

	if bIsDefaultEff then
		self.m_Walker:AddBindObj(sEffName)
	else
		local oTrans = self.m_Walker:GetBindTrans("foot")
		self.m_Walker:AddEffect(sEffName, false, oTrans, Vector3.New(0, 0.3, 0), LoadDone)
	end
	Utils.AddTimer(RemoveEff, 0, duration)
end

function CPlotCharacterCtrl.PlayAnimationAction(self, oAniAction, time)
	-- self.m_Walker:Play(oAniAction.clip)
	if not self.m_InitDone then
		self.m_CacheAnim = {
			action = oAniAction,
			clock = os.clock(),
			time = time,
		}
		return
	end
	if self.m_IsStopAnim then
		self:SetAnimStop(false)
	else
		self:DelStopAnimTimer()
	end
	local iLoopTimes = 1
	local stopTime = oAniAction.stopTime
	local bStop = stopTime and stopTime > 0
	local sClip = oAniAction.clip
	if not bStop then
		if oAniAction.loop then
			iLoopTimes = math.max(1, oAniAction.loopTime)
		end
	end
	local f = callback(self, "ResumeAnim", bStop, oAniAction.isResume)
	local animTime
	if time and time < 0 then
		local dAnim = self:GetModelAnimInfo(oAniAction)
		animTime = dAnim.length
		iLoopTimes = iLoopTimes
		local leftTime = animTime * iLoopTimes + time
		if bStop then
			stopTime = stopTime + time
			leftTime = math.min(stopTime, leftTime)
		end
		if leftTime <= 0 then
			if bStop then
				local cb = callback(self, "SetAnimStop", true)
				local fixedTime = oAniAction.stopTime
				self.m_Walker.m_Actor:PlayInFixedTime(sClip, fixedTime, fixedTime, cb)
			end
			return
		else
			if bStop then
				self:StopAnimAtTime(stopTime)
				self.m_Walker.m_Actor:PlayInFixedTime(sClip, -time, -time, f)
			else
				local fixedTime = leftTime%animTime
				local cb
				iLoopTimes = iLoopTimes - 1
				if iLoopTimes > 0 then
					cb = callback(self.m_Walker, "CrossFadeByLoop", sClip, define.Walker.CrossFade_Time, nil, iLoopTimes, f)
				else
					cb = f
				end
				self.m_Walker.m_Actor:PlayInFixedTime(sClip, fixedTime, animTime, cb)
			end
			return
		end
	end
	if bStop then
		self:StopAnimAtTime(stopTime)
	end
	self.m_Walker:CrossFadeByLoop(sClip, define.Walker.CrossFade_Time, nil, iLoopTimes, f)	
end

function CPlotCharacterCtrl.ResumeAnim(self, bStop, bResume)
	if Utils.IsNil(self.m_Walker) then
		return
	end
	if not bStop and bResume then
		self.m_Walker.m_Actor:CrossFade("idleCity", 0.2)
	end
end

function CPlotCharacterCtrl.SetModelActive(self, bIsActive)
	--TODO:需考虑坐骑问题，暂无坐骑，后期添加
	self.m_IsModelActive = bIsActive
	self.m_Walker:SetActive(bIsActive)
end

function CPlotCharacterCtrl.SetPersonActive(self, bIsActive)
	self.m_IsModelActive = bIsActive 
	self.m_Walker:SetActive(bIsActive)
end

function CPlotCharacterCtrl.SetModelScale(self, oScale)
	self.m_Walker:SelLocalScale(oScale)
end

function CPlotCharacterCtrl.GetModelScale(self)
	return true
end

function CPlotCharacterCtrl.GetModelAnimInfo(self, oAniAction)
	local dClipInfo = ModelTools.GetAnimClipInfo(self.m_Walker.m_Shape, oAniAction.clip, self.m_Walker.m_Actor:GetAnimatorIdx())
	return dClipInfo
end

function CPlotCharacterCtrl.UpdateMode(self)
	if not self.m_Walker then
		return
	end 
	if not self.m_CurAction or self.m_CurAction.tweenType ~= define.Plot.TweenType.Mount then
		return
	end 
	--TODO:上下飞行坐骑，待实现
	if self.m_CurAction.mountState then
	else
	end
end

function CPlotCharacterCtrl.GetActionWaitTime(self, dAction)
	return dAction.startTime - (self.m_ElapsedTime or 0)
end

function CPlotCharacterCtrl.GetTalkContent(self, dAction)
	local sText = dAction.content
	sText = string.gsub(sText, "#N", string.format("#G%s#n", g_AttrCtrl.name))
	return sText
end

function CPlotCharacterCtrl.FollowCamera(self, dCharInfo)
	if dCharInfo.cameraFollow then
		local oCam = g_CameraCtrl:GetMapCamera()
		oCam:Follow(self.m_Walker.m_Transform)
		oCam:SyncTargetPos()
	end
end

function CPlotCharacterCtrl.StopAnimAtTime(self, time)
	self:DelStopAnimTimer()
	self.m_StopAnimTimer = Utils.AddTimer(callback(self, "SetAnimStop", true), 0, time)
end

function CPlotCharacterCtrl.SetAnimStop(self, bStop)
	if self.m_Walker then
		self.m_Walker.m_Actor:SetAllAnimSpeed(bStop and 0 or 1)
		self.m_IsStopAnim = bStop
		if not bStop then
			self:DelStopAnimTimer()
		end
	end
end

function CPlotCharacterCtrl.DelStopAnimTimer(self)
	if self.m_StopAnimTimer then
		Utils.DelTimer(self.m_StopAnimTimer)
		self.m_StopAnimTimer = nil
	end
end

function CPlotCharacterCtrl.Pause(self)
	if self.m_Sequence then 
		self.m_Sequence:Pause()
	end
end

function CPlotCharacterCtrl.Resume(self)
	if self.m_Sequence then
		self.m_Sequence:Play()
	end
end

function CPlotCharacterCtrl.HideWalker(self)
	if self.m_Walker then
		self.m_Walker:SetActive(false)
		self.m_Walker:SetName("")
	end
end

function CPlotCharacterCtrl.Dispose(self)
	if self.m_Sequence then
		self.m_Sequence:Kill(true)	
		self.m_Sequence = nil
	end
	if self.m_Walker then
		if self.m_IsStopAnim then
			self:SetAnimStop(false)
		end
		self.m_Walker:Destroy()
		self.m_Walker = nil
	end
	self.m_CacheAnim = nil
end
return CPlotCharacterCtrl
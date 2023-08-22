local CActorCamera = class("CActorCamera", CCamera, CGameObjContainer)

function CActorCamera.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/ActorCamera.prefab")
	CCamera.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self.m_PosObj = self:NewUI(1, CObject)
	self.m_Actor = nil
	self.m_RenderTexture = nil
	self.m_AnimTimer = nil
end

function CActorCamera.ChangeShape(self, modelInfo, cb)

	if not self.m_Actor then
		self.m_Actor = CActor.New()
		self.m_Actor:SetParent(self.m_PosObj.m_Transform)
		self.m_Actor:SetLayer(self:GetLayer(), true)
		self.m_Actor:SetActive(true)
	end

	if cb then 

		self.m_modelDoneCb = cb

	end 

	local position = nil
	if modelInfo.pos then 

		position = modelInfo.pos

	else 

		position = Vector3(0, -0.7, 3)

	end  

	self.m_Actor:ChangeShape(modelInfo,  callback(self, "OnChangeDone"), true)

	self.m_PosObj:SetLocalPos(position)
	self:StopAnimTimer()
	self.m_Actor:SetLocalRotation(Quaternion.identity)
end


function CActorCamera.Ranse(self, ranseInfo, cb)
	
	if self.m_Actor then  

		self.m_Actor:Ranse(ranseInfo, cb)

	end

end


function CActorCamera.SetBodyShader(self, rgb)
	if self.m_Actor then
		self.m_Actor:SetBodyShader(rgb)
	end
end

function CActorCamera.SetActorPos(self, vPos)
	self.m_PosObj:SetLocalPos(vPos)
end

function CActorCamera.SetActorEulerAngle(self, vAngle)
	self.m_PosObj:SetLocalEulerAngles(vAngle)
end

function CActorCamera.GetShape(self)
	if self.m_Actor then
		return self.m_Actor:GetShape()
	end
end

function CActorCamera.ResetActor(self)
	self:StopAnimTimer()
	if self.m_Actor then
		self.m_Actor:CrossFade("idleCity")
		self.m_Actor:SetLocalRotation(Quaternion.Euler(0,0,0))
	end
end

function CActorCamera.OnChangeDone(self)

	self.m_Actor:SetActive(true)
	local layer = self:GetLayer()
	self.m_Actor:SetLayer(layer, true)

	if self.m_modelDoneCb then 

		self.m_modelDoneCb()
		self.m_modelDoneCb = nil

	end 

end

function CActorCamera.SetRenderTexture(self, renderTexture)
	self.m_RenderTexture = renderTexture
	self:SetTargetTexture(renderTexture)
end

function CActorCamera.GetActor(self)
	return self.m_Actor
end

function CActorCamera.SetOwner(self, o)
	if o then
		self.m_OwnerRef = weakref(o)
	else
		self.m_OwnerRef = nil
	end
end

function CActorCamera.GetOwner(self)
	return getrefobj(self.m_OwnerRef)
end

function CActorCamera.ClearTexture(self)
	if self.m_RenderTexture then
		UnityEngine.RenderTexture.ReleaseTemporary(self.m_RenderTexture)
		self.m_RenderTexture = nil
		self:SetTargetTexture(nil)
	end
end

function CActorCamera.ClearActor(self)
	if self.m_Actor then
		self.m_Actor:Destroy()
		self.m_Actor = nil
	end
	self:ClearTexture()
end

function CActorCamera.Destroy(self)
	self:ClearActor()
	self:ClearTexture()
	CCamera.Destroy(self)
end

function CActorCamera.PlayerAnimator(self, sAnim)
	local oActor = self.m_Actor
	if not  oActor then
		return
	end
	if self.m_AnimTimer then
		return
	else
		sAnim = sAnim or "show"
		local function delay()
			local function f()
				oActor:CrossFade("idleCity", 0.2)
			end
			oActor:CrossFade(sAnim, 0.2, 0, 1, f)
			return true
		end
		local iTime = ModelTools.NormalizedToFixed(oActor:GetShape(), oActor:GetAnimatorIdx(), sAnim, 1) + 3
		self.m_AnimTimer = Utils.AddTimer(delay, iTime, 0)
	end
end

function CActorCamera.StopAnimTimer(self)
	if self.m_AnimTimer then
		Utils.DelTimer(self.m_AnimTimer)
		self.m_AnimTimer = nil
	end
end

function CActorCamera.SetActive(self, b)
	CCamera.SetActive(self, b)
end

function CActorCamera.ResumeLastAni(self, b)
	if not b then
		if self.m_Actor then
			self.m_AniClip = self.m_Actor:GetState()
		end
	else
		if self.m_AniClip and self.m_Actor then
			self.m_Actor:CrossFade(self.m_AniClip, 0.2)
		end
		self.m_AniClip = nil
	end
end

function CActorCamera.CrossFade(self, sState, duration, startNormalized, endNormalized, func)
	
	if self.m_Actor then 
		 self.m_Actor:CrossFade(sState, duration, startNormalized, endNormalized, func)
	end 

end

function CActorCamera.ShowAllParticle(self, lv)
	
	self.m_Actor:ShowRideEffect(lv)
	self.m_Actor:ShowWingEffect(lv)
	self.m_Actor:ShowWeaponEffect(lv)

end

return CActorCamera
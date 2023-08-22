local CCamera = class("CCamera", CObject)

function CCamera.ctor(self, obj)
	CObject.ctor(self, obj)
	self.m_Camera = self:GetComponent(classtype.Camera)
	self.m_AttachCameraHandler = nil --self:GetComponent(classtype.AttachCameraHandler)
	self.m_RenderCam = nil
end

function CCamera.SetRenderCam(self, oCam)
	self.m_RenderCam = oCam
end

function CCamera.GetRenderCam(self)
	return self.m_RenderCam or self
end

function CCamera.NewAttachCamera(self, eventmask, depth)
	if self.m_AttachCameraHandler then
		return self.m_AttachCameraHandler:NewAttachCamera(eventmask, depth)
	end
end

function CCamera.GetDepth(self)
	return self.m_Camera.depth
end

function CCamera.SetDepth(self, iDepth)
	self.m_Camera.depth = iDepth
end

function CCamera.SetRect(self, rect)
	self.m_Camera.rect = rect
	if self.m_AttachCameraHandler then
		self.m_AttachCameraHandler:SetRect(rect)
	end
end

function CCamera.SetEnabled(self, b)
	self.m_Camera.enabled = b
	if self.m_AttachCameraHandler then
		self.m_AttachCameraHandler:SetEnabled(b)
	end
end

function CCamera.GetEnabled(self)
	return self.m_Camera.enabled
end


function CCamera.SetFieldOfView(self, i)
	self.m_Camera.fieldOfView = i
	if self.m_AttachCameraHandler then
		self.m_AttachCameraHandler:SetFieldOfView(i)
	end
end

function CCamera.GetFieldOfView(self)
	return self.m_Camera.fieldOfView
end

function CCamera.SetBackgroudColor(self, color)
	if self.m_AttachCameraHandler then
		self.m_AttachCameraHandler:SetBackgroudColor(color)
	else
		self.m_Camera.backgroundColor = color
	end
end

function CCamera.GetBackgroundColor(self)
	if self.m_AttachCameraHandler then
		return  self.m_AttachCameraHandler:GetBackgroundColor()
	else
		return self.m_Camera.backgroundColor
	end
	
end

function CCamera.WorldToScreenPoint(self, v3)
	return self.m_Camera:WorldToScreenPoint(v3)
end

function CCamera.ViewportToWorldPoint(self, v3)
	return self.m_Camera:ViewportToWorldPoint(v3)
end

function CCamera.ScreenToWorldPoint(self, v3)
	return self.m_Camera:ScreenToWorldPoint(v3)
end

function CCamera.WorldToViewportPoint(self, v3)
	return self.m_Camera:WorldToViewportPoint(v3)
end

function CCamera.SetTargetTexture(self, rt)
	self.m_Camera.targetTexture = rt
end

function CCamera.CopyFrom(self, camreraobj)
	self.m_Camera:CopyFrom(camreraobj)
end

function CCamera.Render(self)
	self.m_Camera:Render()
end

function CCamera.SetOrthographicSize(self, vsize)
	self.m_Camera.orthographicSize = vsize
end

function CCamera.GetOrthographicSize(self)
	return self.m_Camera.orthographicSize
end

function CCamera.GetAspect(self)
	return self.m_Camera.aspect 
end

function CCamera.GetCullingMask(self)
	return self.m_Camera.cullingMask
end

function CCamera.SetCullingMask(self, x)
	self.m_Camera.cullingMask = x
end

function CCamera.OpenCullingMask(self, layer)
	local x = MathBit.orOp(self.m_Camera.cullingMask, MathBit.lShiftOp(1, layer)) 
	self.m_Camera.cullingMask = x
end

function CCamera.CloseCullingMask(self, layer)
	local x = MathBit.andOp(self.m_Camera.cullingMask, MathBit.notOp(MathBit.lShiftOp(1, layer)))
	self.m_Camera.cullingMask = x
end

function CCamera.Push(self, objPos, cb, iDistance, iSpeed)
	local dic = objPos - self:GetPos()
	local endDistance = iDistance or 2
	local speed = iSpeed
	if not speed then
		if dic:Magnitude() - endDistance > 0 then
			speed = (dic:Magnitude() - endDistance) / 1
			if speed > 2 then
				speed = 2
			end
		else
			speed = 0.8
		end
	end
	if not self.m_Timer then
		self.m_Timer = Utils.AddTimer(callback(self, "PushUpdate", objPos, cb, endDistance, speed), 0, 0)
	end
end

function CCamera.CancelPush(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
end

function CCamera.IsPushing(self)
	return self.m_Timer ~= nil
end

function CCamera.PushUpdate(self, objPos, cb, iDistance, iSpeed)
	local dic = objPos - self:GetPos()
	if (iSpeed > 0 and dic:Magnitude() > iDistance)
	or (iSpeed < 0 and dic:Magnitude() < iDistance) then
		self:SetPos(self:GetPos() + dic * Time.deltaTime * iSpeed)
		-- self:Translate(dic * Time.deltaTime * iSpeed)
	else
		self.m_Timer = nil
		if cb then
			cb()
		end
		return false
	end
	return true
end

function CCamera.SetClearFlags(self, flag)
	self.m_Camera.clearFlags = flag
end

return CCamera
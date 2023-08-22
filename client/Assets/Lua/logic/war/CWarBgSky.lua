local CWarBgSky = class("CWarBgSky", CViewBase)

function CWarBgSky.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarBgSky.prefab", cb)
	self.m_Callback = cb
end

function CWarBgSky.OnCreateView(self)
	if self.m_Callback then
		self.m_Callback(self)
	end
end

function CWarBgSky.OnBgLoad(self, obj, errorcode)
	if obj then
		local oInstance = obj:Instantiate()
		CObject.ctor(self, oInstance)
		self:ReszieBg()
		if self.m_Callback then
			self.m_Callback(self)
		end
	end
end

function CWarBgSky.ReszieBg(self)
	local oCam = g_CameraCtrl:GetWarCamera()
	local angle = oCam.m_Transform.localRotation.eulerAngles.x

	local iAspect = oCam.m_Camera.aspect
	local iSize = oCam.m_Camera.orthographicSize
	local ratio = 3048 / 768
	local scaleY = iSize*2
	local scaleX = scaleY*ratio

	self:SetLocalScale(Vector3.New(scaleX, scaleY, 0))
	WarTools.SetWarPos(self, 0, 0, -20)
	self:SetLocalRotation(Quaternion.Euler(angle, 0, 0))
	self:SetLocalPos(self:GetLocalPos() + Vector3.New(0, -0.1, 0))
end

return CWarBgSky
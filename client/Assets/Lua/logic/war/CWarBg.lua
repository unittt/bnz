local CWarBg = class("CWarBg", CViewBase)

function CWarBg.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarBg.prefab", cb)
	self.m_Callback = cb
end

function CWarBg.OnCreateView(self)
	self.m_bg = self:NewUI(1, CTexture)

	if self.m_Callback then
		self.m_Callback(self)
	end

	--预防底图未正确缩放
	local function checkResize()
		local w,h = self.m_bg:GetSize()
		if w < 10 then
			self.m_bg:ResetAndUpdateAnchors()
		end
	end

	Utils.AddTimer(checkResize, 3, 3)
end

function CWarBg.OnBgLoad(self, obj, errorcode)
	if obj then
		local oInstance = obj:Instantiate()
		CObject.ctor(self, oInstance)
		self:ReszieBg()
		if self.m_Callback then
			self.m_Callback(self)
		end
	end
end

function CWarBg.ReszieBg(self)
	local oCam = g_CameraCtrl:GetWarCamera()
	local angle = oCam.m_Transform.localRotation.eulerAngles.x

	local iAspect = oCam.m_Camera.aspect
	local iSize = oCam.m_Camera.orthographicSize
	local ratio = 1024 / 768
	local scaleY = iSize*2
	local scaleX = scaleY*ratio

	self:SetLocalScale(Vector3.New(scaleX, scaleY, 0))
	WarTools.SetWarPos(self, 0, 0, -10)
	self:SetLocalRotation(Quaternion.Euler(angle, 0, 0))
	self:SetLocalPos(self:GetLocalPos() + Vector3.New(0, -0.1, 0))
end

function CWarBg.Destroy(self)
	-- printc("== 删除战斗背景 WarBg ==")
	CViewBase.Destroy(self)
end

return CWarBg
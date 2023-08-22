local CHud = class("CHud", CObject)

function CHud.ctor(self, obj)
	CObject.ctor(self, obj)
	--self.m_HudHandler = self:AddComponent(classtype.HudHandler)
	if Utils.IsIOS() then
		self.m_HudHandler = self:GetMissingComponent(classtype.UIFollowTarget)
	else
		self.m_HudHandler = self:GetComponent(classtype.UIFollowTarget)
	end
	--self:SetUICamera(g_CameraCtrl:GetUICamera())
	self.m_OwnerRef = nil
end

function CHud.SetTarget(self, transform)
	--self.m_HudHandler.target = transform
	self.m_HudHandler:SetTarget(transform.gameObject)
end

function CHud.SetGameCamera(self, cCamera)
	--self.m_HudHandler.gameCamera = cCamera.m_Camera
end

function CHud.SetUICamera(self, cCamera)
	--self.m_HudHandler.uiCamera = cCamera.m_Camera
end

function CHud.SetAutoUpdate(self, b)
	self:SetActive(b)
	--self.m_HudHandler.isAutoUpdate = b
end

--回收
function CHud.Recycle(self)

end

--重复使用
function CHud.Reuse(self, oOwner)

end

function CHud.SetOwner(self, oOwner)
	if oOwner then
		self.m_OwnerRef = weakref(oOwner)
		self:Reuse(oOwner)
	else
		self.m_OwnerRef = nil
	end
end

function CHud.GetOwner(self)
	return getrefobj(self.m_OwnerRef)
end

return CHud
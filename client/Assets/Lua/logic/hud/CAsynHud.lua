local CAsynHud = class("CAsynHud", CObject, CGameObjContainer)

function CAsynHud.ctor(self, path, cb)
	g_ResCtrl:LoadCloneAsync(path, callback(self, "OnHudLoadDone"), false, true)
	self.m_Path = path
	self.m_Callback = cb
	self.m_OwnerRef = nil
end

function CAsynHud.OnHudLoadDone(self, oClone, errcode)
	if oClone then
		CObject.ctor(self, oClone)
		CGameObjContainer.ctor(self, oClone)
		local iLayer = self:GetLayer()
		-- 相同layer不设置(减少遍历childs)
		if iLayer ~= g_HudCtrl.g_Layer then
			CObject.SetLayer(self, g_HudCtrl.g_Layer, true)
		end
		self:OnCreateHud(self.m_Path)
		if self.m_Callback then
			self.m_Callback(self)
			self.m_Callback = nil
		end
	end
end

function CAsynHud.OnCreateHud(self)
	-- override
end

--回收
function CAsynHud.Recycle(self)
	self.m_Callback = nil
end

--重复使用
function CAsynHud.Reuse(self, oOwner)

end

function CAsynHud.SetOwner(self, oOwner)
	if oOwner then
		self.m_OwnerRef = weakref(oOwner)
		self:Reuse(oOwner)
	else
		self.m_OwnerRef = nil
	end
end

function CAsynHud.GetOwner(self)
	return getrefobj(self.m_OwnerRef)
end

function CAsynHud.Destroy(self)
	self:Recycle()
	self:SetOwner(nil)
	CObject.Destroy(self)
	CGameObjContainer.Destroy(self)
end

return CAsynHud
local CMagicEffect = class("CMagicObj", CEffect)

function CMagicEffect.ctor(self, path, layer, cached, cb)
	if not g_SystemSettingsCtrl:GetWarEffectState() then
		layer = UnityEngine.LayerMask.NameToLayer("Hide")
	end
	CEffect.ctor(self, path, layer, cached, cb)
end

function CMagicEffect.SetEnv(self, sEnv)
	-- local transform = MagicTools.GetParentByEnv(sEnv)
	-- if transform then
	-- 	self:SetParent(transform)
		-- self:SetLocalEulerAngles(Vector3.New(-45, -90, -90))
		-- self:SetLocalEulerAngles(Vector3.New(0, -45, 0))
	-- end
end

function CMagicEffect.GetParentTransform(self)
	return g_WarCtrl:GetRoot().m_Transform
end
return CMagicEffect
local CRoleCreateTouchCtrl = class("CRoleCreateTouchCtrl")

function CRoleCreateTouchCtrl.ctor(self)
	self.m_LayerMask = UnityEngine.LayerMask.GetMask("RoleCreate")
end

--{[1]=gameobj, [2]=point,...}
function CRoleCreateTouchCtrl.OnTouchUp(self, touchPos)
	-- printc("CRoleCreateTouchCtrl.OnTouchUp")
	g_UITouchCtrl:NotTouchUI()
	local oCamera
	if g_RoleCreateScene.m_IsShowingRoleCreateScene or g_RoleCreateScene.m_IsShowingActor or not g_RoleCreateScene.m_RoleCreateScene then
		return
	end
	oCamera = g_RoleCreateScene.m_Camera.m_Camera
	local lTouch = C_api.EasyTouchHandler.SelectMultiple(oCamera, touchPos.x, touchPos.y, self.m_LayerMask)
	if not lTouch or #lTouch == 0 then
		return
	end
	local iCnt = #lTouch / 2
	for i=1, iCnt do
		local go, point = lTouch[i*2-1], lTouch[i*2]
		-- printc("CRoleCreateTouchCtrl.OnTouchUp lTouch", go.name, " ", go.layer)
		if go.layer == define.Layer.RoleCreate then
			-- if g_RoleCreateScene.m_CurRoleCreatePlayer and go:GetInstanceID() == g_RoleCreateScene.m_CurRoleCreatePlayer:GetInstanceID() then
			-- 	g_RoleCreateScene.m_CurRoleCreatePlayer:OnTrigger()
			-- end
			-- printc("OnTouchUp "..go:GetInstanceID())
		end
	end
end

return CRoleCreateTouchCtrl
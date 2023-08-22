local CUIEffectTaskDoneMark = class("CUIEffectTaskDoneMark", CObject)

function CUIEffectTaskDoneMark.ctor(self, oAttach, size, pos)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {size=size, pos=pos}
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_0025/Prefabs/ui_eff_0025.prefab", callback(self, "OnEffLoad"), false)
end 

function CUIEffectTaskDoneMark.OnEffLoad(self, oClone, sPath)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform)
		self:SetLocalEulerAngles(Vector3.New(-30, 0, 0))
		self.m_Eff:SetLocalScale(self.m_Args.size)
		self.m_Eff:SetPos(oAttach:GetPos())
		local mPanel = self.m_Eff:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = self.m_Eff:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
	end
end

function CUIEffectTaskDoneMark.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end
end

return CUIEffectTaskDoneMark
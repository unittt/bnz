local CUIEffectFlower = class("CUIEffectFlower", CObject)
CUIEffectFlower.m_TypePath = {
	RoseSea = "Effect/UI/ui_eff_0042/Prefabs/ui_eff_0042.prefab",
	RoseRain = "Effect/UI/ui_eff_0043/Prefabs/ui_eff_0043.prefab",
	CarnationSea = "Effect/UI/ui_eff_0044/Prefabs/ui_eff_0044.prefab",
	CarnationRain = "Effect/UI/ui_eff_0045/Prefabs/ui_eff_0045.prefab",
}

function CUIEffectFlower.ctor(self, oAttach, type, size, pos, rotate)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {size=size, pos=pos, rotate = rotate}
	g_ResCtrl:LoadCloneAsync(CUIEffectFlower.m_TypePath[type], callback(self, "OnEffLoad"), false)
end 

function CUIEffectFlower.OnEffLoad(self, oClone, sPath)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform)
		local vPos = oAttach:GetPos()
		vPos = self:InverseTransformPoint(vPos)
		if self.m_Args.pos then
			vPos.x = vPos.x + self.m_Args.pos.x
			vPos.y = vPos.y + self.m_Args.pos.y
		end
		self.m_Eff:SetLocalPos(vPos)
		if self.m_Args.rotate then
			self.m_Eff:SetLocalEulerAngles(Vector3.New(self.m_Eff.m_Transform.localEulerAngles.x, self.m_Eff.m_Transform.localEulerAngles.y, self.m_Args.rotate))
		end
		local mPanel = self.m_Eff:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = self.m_Eff:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
	end
end

function CUIEffectFlower.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end
end

return CUIEffectFlower
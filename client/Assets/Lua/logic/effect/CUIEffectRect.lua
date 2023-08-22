local CUIEffectRect = class("CUIEffectRect", CWidget)
CUIEffectRect.m_TypePath = {
	Circu = "Effect/UI/ui_eff_0003/Prefabs/ui_eff_0003.prefab",
	Rect = "Effect/UI/ui_eff_0030/Prefabs/ui_eff_0030.prefab",
	Rect2 = "Effect/UI/ui_eff_0094/Prefabs/ui_eff_0094_1.prefab",
	Rect3 = "Effect/UI/ui_eff_0094/Prefabs/ui_eff_0094_2.prefab",
}
function CUIEffectRect.ctor(self, oAttach, type, pos, sortingOrder)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	-- local mWidget = obj:AddComponent(classtype.UIWidget)
	CWidget.ctor(self, obj)
	self.m_UIWidget.enabled = true
	self.m_RefAttach = weakref(oAttach)
	local needResize = type == "Rect" or type == "Circu"
	self.m_Args = {pos = pos, sortingOrder = sortingOrder, needResize = needResize}
	g_ResCtrl:LoadCloneAsync(CUIEffectRect.m_TypePath[type], callback(self, "OnEffLoad"), false)
end


function CUIEffectRect.OnEffLoad(self, oClone, errcode)
	local iDesignSize = 64
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform)
		if self.m_Args.pos then
			self.m_Eff:SetLocalPos(Vector3.New(self.m_Args.pos.x, self.m_Args.pos.y, 0))
		end
		if self.m_Args.sortingOrder then
			local sublist = self.m_Eff.m_GameObject:GetComponentsInChildren(classtype.ParticleSystem)
			for i = 0, sublist.Length-1 do
				sublist[i].gameObject:GetComponent(classtype.Renderer).sortingOrder = self.m_Args.sortingOrder
			end

			local sublist1 = self.m_Eff.m_GameObject:GetComponentsInChildren(classtype.MeshRenderer)
			for i = 0, sublist1.Length-1 do
				sublist1[i].sortingOrder = self.m_Args.sortingOrder
			end
		end
		
		if self.m_Args.needResize then
			local w, h = oAttach:GetSize()
			self:SetSize(w, h)
			local iScaleW = w / iDesignSize * 1.05
			local iScaleH = h /iDesignSize * 1.05
			self.m_Eff:SetLocalScale(Vector3.New(iScaleW, iScaleH, 1))
		end
		UITools.NearTarget(oAttach, self, enum.UIAnchor.Side.Center)

		local mPanel = self.m_Eff:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = self.m_Eff:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
		-- UI如果处于运动状态会导致坐标异常
		self:SetLocalPos(Vector2.zero)
	end
end

function CUIEffectRect.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end
end

return CUIEffectRect
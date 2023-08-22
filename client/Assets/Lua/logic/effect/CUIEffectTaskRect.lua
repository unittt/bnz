local CUIEffectTaskRect = class("CUIEffectTaskRect", CWidget)

function CUIEffectTaskRect.ctor(self, oAttach)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	-- local mWidget = obj:AddComponent(classtype.UIWidget)
	CWidget.ctor(self, obj)
	self.m_UIWidget.enabled = true
	self.m_RefAttach = weakref(oAttach)
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_0001/Prefabs/ui_eff_0001.prefab", callback(self, "OnEffLoad"), false)
end

function CUIEffectTaskRect.OnEffLoad(self, oClone, errcode)
	local iDesignSize = 64
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform)
		local w, h = oAttach:GetSize()
		self:SetSize(w, h)
		-- local iScaleW = w / iDesignSize * 1.05
		-- local iScaleH = h /iDesignSize * 1.05
		-- self.m_Eff:SetLocalScale(Vector3.New(iScaleW, iScaleH, 1))
		UITools.NearTarget(oAttach, self, enum.UIAnchor.Side.Center)
		
		local mPanel = self.m_Eff:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = self.m_Eff:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject

		local oView = CMainMenuView:GetView()
		if oView then
			CUIParticleSystemClipper.Progress(oView.m_RT.m_ExpandBox.m_TaskPart.m_ItemScrollView)
		end

		self:ResetMove()
	end
end

function CUIEffectTaskRect.ResetMove(self)
	local vet = self.m_UIWidget.localCorners
	table.insert(vet, vet[1])
	self.m_Eff:SetLocalPos(vet[1])
	local tweenPath = DOTween.DOLocalPath(self.m_Eff.m_Transform, vet, 3, 0, 0, 10, nil)
	DOTween.SetLoops(tweenPath, -1)
	DOTween.SetDelay(tweenPath, 0)
end

function CUIEffectTaskRect.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end	
end

return CUIEffectTaskRect
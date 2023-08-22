local CUIEffectTreasureSilverPrize = class("CUIEffectTreasureSilverPrize", CWidget)

function CUIEffectTreasureSilverPrize.ctor(self, oAttach)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	-- local mWidget = obj:AddComponent(classtype.UIWidget)
	CWidget.ctor(self, obj)
	self.m_UIWidget.enabled = true
	self.m_RefAttach = weakref(oAttach)
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_0020/Prefabs/ui_eff_0020.prefab", callback(self, "OnEffLoad"), false)
end


function CUIEffectTreasureSilverPrize.OnEffLoad(self, oClone, errcode)
	local iDesignSize = 64
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform)
		self.m_Eff:SetLocalPos(Vector3.zero)
		-- local w, h = oAttach:GetSize()
		-- self:SetSize(w, h)
		-- local iScaleW = w / iDesignSize * 1.05
		-- local iScaleH = h /iDesignSize * 1.05
		-- self.m_Eff:SetLocalScale(Vector3.New(iScaleW, iScaleH, 1))
		-- UITools.NearTarget(oAttach, self, enum.UIAnchor.Side.Center)
		
		local mPanel = self.m_Eff:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = self.m_Eff:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject

		local sublist = self.m_Eff.m_GameObject:GetComponentsInChildren(classtype.ParticleSystem)
		for i = 0, sublist.Length-1 do
			sublist[i].gameObject:GetComponent(classtype.Renderer).sortingOrder = i - 3
		end

		if self.m_DestroyTimer then
			Utils.DelTimer(self.m_DestroyTimer)
		end
		local function update()
			if Utils.IsNil(self) then
				return false
			end
			if not Utils.IsNil(self) then
				CObject.Destroy(self)
			end
			local oNotifyView = CNotifyView:GetView()
			if oNotifyView then
				oNotifyView.m_UIPanel.sortingOrder = 0
			end
			return false
		end
		self.m_DestroyTimer = Utils.AddTimer(update, 0.5, 2)
	end
end

function CUIEffectTreasureSilverPrize.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end
	
end

return CUIEffectTreasureSilverPrize
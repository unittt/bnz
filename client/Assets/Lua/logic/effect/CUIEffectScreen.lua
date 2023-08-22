local CUIEffectScreen = class("CUIEffectScreen", CObject)

function CUIEffectScreen.ctor(self, oAttach, type, size, pos, rotate, sortingOrder, notNeedPanel, specialType)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {size=size, pos=pos, rotate = rotate}
	self.m_Order = sortingOrder
	self.m_NotNeedPanel = notNeedPanel
	local effPath = "Effect/UI/"..(specialType and specialType or type).."/Prefabs/"..type..".prefab"
	g_ResCtrl:LoadCloneAsync(effPath, callback(self, "OnEffLoad"), false)
end 

function CUIEffectScreen.OnEffLoad(self, oClone, sPath)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform)
		local vPos = oAttach:GetPos()
		vPos = self:InverseTransformPoint(vPos)
		if self.m_Args.pos then
			self.m_Eff:SetLocalPos(self.m_Args.pos)
		else
			self.m_Eff:SetLocalPos(vPos)
		end	
		
		if self.m_Args.size then
			self.m_Eff:SetLocalScale(self.m_Args.size)
		end
		if self.m_Args.rotate then
			self.m_Eff:SetLocalEulerAngles(self.m_Args.rotate)
		end
		if self.m_Order then
			local sublist = self.m_Eff.m_GameObject:GetComponentsInChildren(classtype.ParticleSystem)
			for i = 0, sublist.Length-1 do
				sublist[i].gameObject:GetComponent(classtype.Renderer).sortingOrder = self.m_Order
			end
		end
		-- if not self.m_NotNeedPanel then
		local mPanel = self.m_Eff:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		-- end
		local mRenderQ = self.m_Eff:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
	end
end

function CUIEffectScreen.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end
end

return CUIEffectScreen
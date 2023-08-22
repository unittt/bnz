local CUIEffectSpecialItem = class("CUIEffectSpecialItem", CObject)

CUIEffectSpecialItem.m_TypePath = {
	S = "Effect/UI/ui_eff_0059/Prefabs/ui_eff_0059.prefab",
	partner = "Effect/UI/ui_eff_0060/Prefabs/ui_eff_0060.prefab",
	Seliver = "Effect/UI/ui_eff_0083/Prefabs/ui_eff_0083.prefab",
	Gold = "Effect/UI/ui_eff_0084/Prefabs/ui_eff_0084.prefab",
	Diamond = "Effect/UI/ui_eff_0085/Prefabs/ui_eff_0085.prefab",
	Lock = "Effect/UI/ui_eff_0095/Prefabs/ui_eff_0095.prefab",
}

function CUIEffectSpecialItem.ctor(self, oAttach, type, sortingOrder, level)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	if obj then
		CObject.ctor(self, obj)
	end
	self.m_RefAttach = weakref(oAttach)
	self.sortingOrder = sortingOrder
	self.level = level
	self.type = type
	g_ResCtrl:LoadCloneAsync(CUIEffectSpecialItem.m_TypePath[type], callback(self, "OnEffLoad"), false)
end

function CUIEffectSpecialItem.OnEffLoad(self, oClone, sPath)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform)
		if self.type ~= "Lock" then
			local vPos = oAttach:GetPos()
			vPos = self:InverseTransformPoint(vPos)	
			self.m_Eff:SetLocalPos(vPos)
		end

		if self.sortingOrder then
			local sublist = self.m_Eff.m_GameObject:GetComponentsInChildren(classtype.ParticleSystem)
			for i = 0, sublist.Length-1 do
				sublist[i].gameObject:GetComponent(classtype.Renderer).sortingOrder = self.sortingOrder
			end

			local sublist1 = self.m_Eff.m_GameObject:GetComponentsInChildren(classtype.MeshRenderer)
			for i = 0, sublist1.Length-1 do
				sublist1[i].sortingOrder = self.sortingOrder
			end
		end

		local mRenderQ = self.m_Eff:GetComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
	end

	if self.level then
		for i=1, self.level do
			local oLevel = self.m_Eff:GetChild(i)
			oLevel.gameObject:SetActive(true)
		end
	end

end

function CUIEffectSpecialItem.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end
end


return CUIEffectSpecialItem
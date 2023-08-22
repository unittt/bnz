local CUIEffectFingerInterval = class("CUIEffectFingerInterval", CObject)

function CUIEffectFingerInterval.ctor(self, oAttach, sortingOrder, size, pos, rotate)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {size=size, pos=pos, rotate = rotate}
	self.m_Order = sortingOrder
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_zhiyin_001/Prefabs/ui_eff_zhiyin_001.prefab", callback(self, "OnEffLoad"), false)
end 

function CUIEffectFingerInterval.OnEffLoad(self, oClone, sPath)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform)
		self.m_Eff:SetPos(oAttach:GetPos())
		if self.m_Args.pos then
			self.m_Eff:SetLocalPos(Vector3.New(self.m_Args.pos.x, self.m_Args.pos.y, 0))
		end
		if self.m_Args.rotate then
			self.m_Eff:SetLocalEulerAngles(Vector3.New(self.m_Eff.m_Transform.localEulerAngles.x, self.m_Eff.m_Transform.localEulerAngles.y, self.m_Args.rotate))
		end
		if self.m_Order then
			local sublist = self.m_Eff.m_GameObject:GetComponentsInChildren(classtype.ParticleSystem)
			for i = 0, sublist.Length-1 do
				sublist[i].gameObject:GetComponent(classtype.Renderer).sortingOrder = self.m_Order
			end
		end
		local mPanel = self.m_Eff:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = self.m_Eff:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject

		self:SetNotifyTime()
	end
end

function CUIEffectFingerInterval.SetNotifyTime(self)
	if not Utils.IsNil(self) then
		self.m_Eff:SetActive(false)
	end
	self:ResetNotifyTimer()
	self:ResetHideTimer()
	local function progress()
		if Utils.IsNil(self) then
			return false
		end
		self.m_Eff:SetActive(true)
		self:GetMissingComponent(classtype.ParticleAndAnimation):PlaySelfAndAllChildren(self.m_GameObject, false)
		local function delay()
			if Utils.IsNil(self) then
				return false
			end
			self.m_Eff:SetActive(false)
			return false
		end
		self.m_HideTimer = Utils.AddTimer(delay, 0, 2)

		return true
	end
	self.m_NotifyTimer = Utils.AddTimer(progress, 5, 0)
end

function CUIEffectFingerInterval.ResetNotifyTimer(self)
	if self.m_NotifyTimer then
		Utils.DelTimer(self.m_NotifyTimer)
		self.m_NotifyTimer = nil			
	end
end

function CUIEffectFingerInterval.ResetHideTimer(self)
	if self.m_HideTimer then
		Utils.DelTimer(self.m_HideTimer)
		self.m_HideTimer = nil			
	end
end

function CUIEffectFingerInterval.OnActive(self, bActive)
	if bActive then
		self:SetNotifyTime()
	end
end

function CUIEffectFingerInterval.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end
end

return CUIEffectFingerInterval
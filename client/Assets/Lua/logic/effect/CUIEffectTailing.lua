local CUIEffectTailing = class("CUIEffectTailing", CWidget)

function CUIEffectTailing.ctor(self, oAttach, sortingOrder)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	-- local mWidget = obj:AddComponent(classtype.UIWidget)
	CWidget.ctor(self, obj)
	self.m_UIWidget.enabled = true
	self.m_RefAttach = weakref(oAttach)
	self.m_Order = sortingOrder
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_0001/Prefabs/ui_eff_0001.prefab", callback(self, "OnEffLoad"))
end


function CUIEffectTailing.OnEffLoad(self, oClone, errcode)
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

		if self.m_Order then
			local sublist = self.m_Eff.m_GameObject:GetComponentsInChildren(classtype.ParticleSystem)
			for i = 0, sublist.Length-1 do
				sublist[i].gameObject:GetComponent(classtype.Renderer).sortingOrder = self.m_Order
			end
		end
		
		-- local mPanel = self.m_Eff:GetMissingComponent(classtype.UIPanel)
		-- mPanel.uiEffectDrawCallCount = 1
		-- local mRenderQ = self.m_Eff:GetMissingComponent(classtype.UIEffectRenderQueue)
		-- self.m_Eff.m_RenderQComponent = mRenderQ
		-- mRenderQ.needClip = true
		-- mRenderQ.attachGameObject = oAttach.m_GameObject

		-- self:ResetMove()
	end
end

-- function CUIEffectTailing.ResetMove(self)
-- 	-- local function onTailingEnd()
-- 	-- 	self.m_FloatPieceObj:DelEffect("Tailing")
-- 	-- end
-- 	local screenWidth = UnityEngine.Screen.width
-- 	local screenHeight = UnityEngine.Screen.height
-- 	local vet = {self:GetWorldPos(Vector2.New(screenWidth/2,screenHeight*0.5)), --self:GetWorldPos(Vector2.New(screenWidth*0.65,screenHeight*0.35)),
-- 	self:GetWorldPos(Vector2.New(screenWidth*0.85,screenHeight*0.7))}
-- 	self.m_Eff:SetPos(self:GetWorldPos(Vector2.New(screenWidth/2,screenHeight*0.5)))
-- 	local tweenPath = DOTween.DOPath(self.m_Eff.m_Transform, vet, 1.5, 0, 0, 10, nil)
-- 	DOTween.SetDelay(tweenPath, 0)
-- end

function CUIEffectTailing.GetWorldPos(self, screenPos)
	local oUICamera = g_CameraCtrl:GetUICamera()
	local WorldPos = oUICamera:ScreenToWorldPoint(screenPos)
	return WorldPos
end

function CUIEffectTailing.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end	
end

return CUIEffectTailing
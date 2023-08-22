local CEffectCtrl = class("CEffectCtrl")

function CEffectCtrl.ctor(self)
	self.m_Index = 0
	self.m_EffectRoot = nil
	self.m_EffectTrans = nil
	self.m_Effects = {}
end

CEffectCtrl.m_SpecialItem = {["S"] = 1, ["partner"] = 2, ["Seliver"] = 3, ["Gold"] = 4, ["Diamond"] = 5, ["Lock"] = 6}

function CEffectCtrl.CreateUIEffect(self, sType, oAttach, ...)
	local oEffect
	if sType == "RedDot" then
		oEffect = CUIEffectRedDot.New(oAttach, ...)
	elseif sType == "Rect" or sType == "Circu" or sType == "Rect2" or sType == "Rect3" then
		oEffect = CUIEffectRect.New(oAttach, sType, ...)
	elseif self.m_SpecialItem[sType] then
		oEffect = CUIEffectSpecialItem.New(oAttach, sType, ...)
	elseif sType == "Shine" then
		oEffect = CUIEffectShine.New(oAttach, ...)
	elseif sType == "TaskRect" then
		oEffect = CUIEffectTaskRect.New(oAttach, ...)
	elseif sType == "Tailing" then
		oEffect = CUIEffectTailing.New(oAttach, ...)
	elseif sType == "TaskDone" then
		oEffect = CUIEffectTaskDone.New(oAttach, ...)
	elseif sType == "TreasureGoldPrize" then
		oEffect = CUIEffectTreasureGoldPrize.New(oAttach, ...)
	elseif sType == "TreasureSilverPrize" then
		oEffect = CUIEffectTreasureSilverPrize.New(oAttach, ...)
	elseif sType == "Finger" then
		oEffect = CUIEffectFinger.New(oAttach, ...)
	elseif sType == "Finger1" then
		oEffect = CUIEffectFinger1.New(oAttach, ...)
	elseif sType == "Finger2" then
		oEffect = CUIEffectFinger2.New(oAttach, ...)
	elseif sType == "Guide" then
		oEffect = CUIEffectGuide.New(oAttach, ...)
	elseif sType == "Trail" then
		oEffect = CUIEffectTrail.New(oAttach, ...)
	elseif sType == "TaskAcceptMark" then
		oEffect = CUIEffectTaskAcceptMark.New(oAttach, ...)
	elseif sType == "TaskDoneMark" then
		oEffect = CUIEffectTaskDoneMark.New(oAttach, ...)
	elseif sType == "TaskNotDoneMark" then
		oEffect = CUIEffectTaskNotDoneMark.New(oAttach, ...)
	elseif sType == "FingerInterval" then
		oEffect = CUIEffectFingerInterval.New(oAttach, ...)
	elseif sType == "GhostEye" then
		oEffect = CUIEffectGhostEye.New(oAttach, ...)
	elseif sType == "RoseSea" or sType == "RoseRain" or sType == "CarnationSea" or sType == "CarnationRain" then
		oEffect = CUIEffectFlower.New(oAttach, sType, ...)
	elseif sType == "SysOpen" then
		oEffect = CUIEffectSysOpen.New(oAttach, ...)
	elseif sType == "Screen" then
		oEffect = CUIEffectScreen.New(oAttach, ...)
	elseif sType == "SummCompose" then
		oEffect = CUIEffectSummonCompose.New(oAttach, ...)
	elseif sType == "SummWash" then
		oEffect = CUIEffectSummonWash.New(oAttach, ...)
	elseif sType == "LianHua" then 
		oEffect = CUIEffectLianHua.New(oAttach, ...)
	elseif sType == "MultLianHua" then 
		oEffect = CUIEffectMultLianHua.New(oAttach, ...)
	elseif sType == "WenShiAttr" then 
		oEffect = CUIEffectWenShiAttr.New(oAttach, ...)
	elseif sType == "WenShiFusion" then 
		oEffect = CUIEffectWenShiFusion.New(oAttach, ...)
	end
	return oEffect
end

function CEffectCtrl.GetEffectRoot(self)
	if not self.m_EffectRoot then
		self.m_EffectRoot = CObject.New(UnityEngine.GameObject.New("EffectRoot"))
	end
	return self.m_EffectRoot
end

function CEffectCtrl.GetIndex(self)
	self.m_Index = self.m_Index + 1
	return self.m_Index
end

function CEffectCtrl.AddEffect(self, oEffect)
	self.m_Effects[oEffect:GetInstanceID()] = oEffect
end

function CEffectCtrl.DelEffect(self, id)
	local oEffect = self.m_Effects[id]
	if oEffect then
		oEffect:Destroy()
		self.m_Effects[id] = nil
	end
end

function CEffectCtrl.CreateEffectByPath(self, sPath, oAttach, ...)
	local oEffect = CUIEffectByPath.New(sPath, oAttach, ...)
	return oEffect
end

function CEffectCtrl.NewEffect(self, sPath, oNode, oAttach, v3LocalPos, v3Scale)
	local ref = weakref(oAttach)
	local function loadeffect(oClone, errcode)
		local obj = getrefobj(ref)
		if oClone and obj then
			local oEff = CObject.New(oClone)
			oEff:SetParent(oNode.m_Transform)
			local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
			mPanel.uiEffectDrawCallCount = 1
			local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
			oEff.m_RenderQComponent = mRenderQ
			mRenderQ.needClip = true
			mRenderQ.attachGameObject = obj.m_GameObject
			mRenderQ:RecaluatePanelDepth()
			if v3LocalPos then
				oEff:SetLocalPos(v3LocalPos)
			end
			if v3Scale then
				oEff:SetLocalScale(v3Scale)
			end
		end
	end
	g_ResCtrl:LoadCloneAsync(sPath, loadeffect)
end

function CEffectCtrl.SetRootActive(self, show)
	local effectRoot = self:GetEffectRoot()
	show = show and true or false
	effectRoot:SetActive(show)
end

return CEffectCtrl
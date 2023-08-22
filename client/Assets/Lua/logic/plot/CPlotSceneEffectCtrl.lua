local CPlotSceneEffectCtrl = class("CPlotSceneEffectCtrl")

function CPlotSceneEffectCtrl.ctor(self, dEffectInfo, oNode, elapsedTime)
	self.m_EffectInfo = dEffectInfo
	self.m_ParentNode = oNode
	self.m_ElapsedTime = elapsedTime
	self:Init(dEffectInfo)
end

function CPlotSceneEffectCtrl.Init(self, dEffectInfo)
	local oSequence = DOTween.Sequence()
	self.m_Sequence = oSequence
	--添加剧情结束回调
	self.m_StartTime = dEffectInfo.startTime
	if self.m_ElapsedTime then
		self.m_StartTime = self.m_ElapsedTime + self.m_StartTime
	end
	local iDuration = dEffectInfo.endTime - self.m_StartTime
	oSequence:AppendInterval(iDuration)
	DOTween.OnComplete(oSequence, callback(self, "Dispose"))
	self:PlaySceneEffectAction(dEffectInfo)
	DOTween.InsertCallback(self.m_Sequence, iDuration, callback(self, "RemoveEffect"))
end

function CPlotSceneEffectCtrl.PlaySceneEffectAction(self, dAction)
	local sEffName = dAction.folderName..dAction.effPath..".Prefab"
	local vPos = Vector3.New(dAction.originPos.x, dAction.originPos.y, 0)
	local vRotate = Vector3.New(dAction.rotateValue.x, dAction.rotateValue.y, 0)
	local iDuration = dAction.endTime - self.m_StartTime
	local vMovePos = Vector3.New(dAction.movePos.x, dAction.movePos.y, 0)

	local function LoadDone(oEffect)
		-- DOTween.DORotate(oEffect.m_Transform, vRotate, 1, 1)
		oEffect:SetLocalEulerAngles(vRotate)
		if dAction.loop then
			self.m_Effect:SetLoop(true)
		end
		if dAction.move then
			if self.m_ElapsedTime then
				if iDuration > 0 then
					local midVec = Vector3.Slerp(vPos, vMovePos, self.m_ElapsedTime/dAction.endTime)
					vPos = midVec
				else
					vPos = vMovePos
				end
			end
			if iDuration > 0 then
				DOTween.DOMove(oEffect.m_Transform, vMovePos, iDuration)
			end
		end
		self:ScaleSceneEffect(oEffect, dAction.scale)
		if dAction.showMask then
			local oMask = dAction.effMask
			if oMask then
				oMask:ShowMask(oEffect:GetInstanceID())
			end
		end
	end
	self.m_Effect = self:CreateEffect(sEffName, LoadDone, vPos)

end

function CPlotSceneEffectCtrl.ScaleSceneEffect(self, oEffect, scale)
	if not scale or scale == 0 or scale == 1 then return end
	oEffect:SetLocalScale(Vector3.one * scale)
end

function CPlotSceneEffectCtrl.CreateEffect(self, sEffName, cb, vPos)
	local oEffect = CEffect.New(sEffName, UnityEngine.LayerMask.NameToLayer("MapTerrain"), true, cb)
	oEffect:SetParent(self.m_ParentNode.m_Transform, false)
	local z = -20
	if not self.m_EffectInfo.showMask then
		-- 3开方 = 1.7320508075689
		z = vPos.y * 1.7320508075689
	end
	local oTargetPos = Vector3.New(vPos.x, vPos.y, z)
	oEffect:SetPos(oTargetPos)	
	return oEffect
end

function CPlotSceneEffectCtrl.RemoveEffect(self)
	if Utils.IsNil(self.m_Effect) then
		return
	end
	if self.m_EffectInfo.showMask then
		local oMask = self.m_EffectInfo.effMask
		if oMask then
			oMask:RemoveMask(self.m_Effect:GetInstanceID())
		end
	end
	self.m_Effect:Destroy()
	self.m_Effect = nil
end

function CPlotSceneEffectCtrl.Pause(self)
	if self.m_Sequence then 
		self.m_Sequence:Pause()
	end
end

function CPlotSceneEffectCtrl.Resume(self)
	if self.m_Sequence then
		self.m_Sequence:Play()
	end
end

function CPlotSceneEffectCtrl.Dispose(self)
	if self.m_Sequence then
		self.m_Sequence:Kill(true)	
		self.m_Sequence = nil
	end
	if self.m_Effect then
		self.m_Effect:Destroy()
		self.m_Effect = nil
	end
end
return CPlotSceneEffectCtrl
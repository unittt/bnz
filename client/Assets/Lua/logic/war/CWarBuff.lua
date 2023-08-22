local CWarBuff = class("CWarBuff")

function CWarBuff.ctor(self, id, oWarrior)
	-- 需调整旋转方向的buffid列表
	self.m_BuffIDList = {210}
	self.m_RotaBuffIDList = {5701}
	self.m_BuffID = id
	self.m_Data = DataTools.GetBuffData(id)
	if not self.m_Data then
		return
	end
	self.m_EffectList = {}
	self.m_Mat = nil
	self.m_WarroiorRef = weakref(oWarrior)
	self:CheckMat()
end

function CWarBuff.CheckMat(self)
	if not self.m_Data then
		printc("Warring! CWarBuff.CheckMat error buffid = ",self.m_BuffID)
		return
	end
	local path = self.m_Data.mat_path 
	if not path or path == "" then
		return
	end
	local oWarrior = self:GetWarrior()
	if oWarrior then
		self.m_MatPath = path
		oWarrior.m_Actor:LoadMaterial(path)
	end
end

function CWarBuff.SetLevel(self, level)
	if not self.m_Data then
		printc("Warring! CWarBuff.SetLevel error buffid = ",self.m_BuffID)
		return
	end
	if not self.m_Data.path or self.m_Data.path == "" then
		return
	end
	local iCnt = level - #self.m_EffectList
	if iCnt == 0 then
		return
	end
	if self.m_Data and self.m_Data.add_cnt then
		iCnt = math.min(self.m_Data.add_cnt, iCnt)
	else
		iCnt = math.min(1, iCnt)
	end
	local oWarrior = self:GetWarrior()
	if iCnt > 0 then
		local allcount = self.m_Data.add_cnt + #self.m_EffectList
		local angle = table.index(self.m_BuffIDList, self.m_BuffID) and -360 or 360
		-- 指定需要旋转的buff
		local needRota = table.index(self.m_RotaBuffIDList, self.m_BuffID)
		for i=1,allcount do
			local oEffect = nil
			if i <= #self.m_EffectList then
				oEffect = self.m_EffectList[i]
				DOTween.DOKill(oEffect.m_Transform, true)
			else
				oEffect = CEffect.New(self.m_Data.path, oWarrior:GetLayer(), true)
				oEffect:SetParent(oWarrior:GetBindTrans(self.m_Data.pos))
				oEffect:SetLocalPos(Vector3.New(0, self.m_Data.height, 0))
				table.insert(self.m_EffectList, oEffect)
			end

			if allcount > 1 or needRota then
				local iEffectRotate = (360/allcount) * (i-1)
				-- printerror("SetEulerAngles", iEffectRotate)
				-- if #self.m_EffectList > 0 then
					-- local oFirstEffect = self.m_EffectList[1]
					-- iEffectRotate = iEffectRotate + oFirstEffect:GetLocalEulerAngles().y
				-- end
				oEffect:SetLocalEulerAngles(Vector3.New(0, iEffectRotate, 0))

				local tween = DOTween.DOLocalRotate(oEffect.m_Transform, Vector3.New(0, angle, 0), 2.5, enum.DOTween.RotateMode.LocalAxisAdd)
				DOTween.SetEase(tween, enum.DOTween.Ease.Linear)
				DOTween.SetLoops(tween, -1)
			end
		end
	else
		for i=1, math.abs(iCnt) do
			local oEffect = self.m_EffectList[1]
			if oEffect then
				oEffect:Destroy()
				table.remove(self.m_EffectList, 1)
			else
				break
			end
		end
	end
end

function CWarBuff.GetWarrior(self)
	return getrefobj(self.m_WarroiorRef)
end

function CWarBuff.Clear(self)
	if self.m_EffectList then
		for i, oEffect in ipairs(self.m_EffectList) do
			DOTween.DOKill(oEffect.m_Transform, true)
			oEffect:Destroy()
		end
		self.m_EffectList = {}
	end
	if self.m_MatPath then
		local oWarrior = self:GetWarrior()
		if oWarrior then
			oWarrior.m_Actor:DelMaterial(self.m_MatPath)
		end
		self.m_MatPath = nil
	end
	
	if self.m_Effect then
		self.m_Effect:Destroy()
		self.m_Effect = nil
	end
end

return CWarBuff
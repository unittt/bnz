local CWarriorAttrBuffList = class("CWarriorAttrBuffList")

function CWarriorAttrBuffList.ctor(self, oWarrior)
	--攻、防、速
	self.m_PreBuffList = {}
	self.m_CellW = 0.32
	self.m_WarroiorRef = weakref(oWarrior)
end

function CWarriorAttrBuffList.UpdateAllAttr(self, iAttack, iDefense, iSpeed)
	local lBuff = self:GetBuffList(iAttack, iDefense, iSpeed)
	if table.equal(lBuff, self.m_PreBuffList) then
		return
	end
	local oWarrior = getrefobj(self.m_WarroiorRef)
	local iCnt = table.count(lBuff)
	local iPosX = (1 - iCnt) * self.m_CellW/2
	for i = 1,3 do
		local iBuffId = lBuff[i]
		-- local dEffInfo = oWarrior.m_BuffEffList[i]
		if iBuffId then
			self:RemoveBuff(i)
			local dBuffData = DataTools.GetBuffData(iBuffId)
			if dBuffData then
				local oEffect = CEffect.New(dBuffData.path, oWarrior:GetLayer(), true, callback(self, "EffectLoadDone", i, dBuffData.pos, iPosX, dBuffData.height))
				-- table.insert(oWarrior.m_BuffEffList, i, oEffect)
				oWarrior.m_BuffEffList[i] = oEffect
				iPosX = iPosX + self.m_CellW
			end
		else
			self:RemoveBuff(i)
		end
	end
	self.m_PreBuffList = table.copy(lBuff)
end

function CWarriorAttrBuffList.RemoveBuff(self, iIndex)
	local oWarrior = getrefobj(self.m_WarroiorRef)
	if not oWarrior then
		return
	end
	local oEffect = oWarrior.m_BuffEffList[iIndex]
	if not oEffect then
		return
	end
	DOTween.DOKill(oEffect.m_Transform, true)
	oEffect:Destroy()
	oWarrior.m_BuffEffList[iIndex] = nil
end

function CWarriorAttrBuffList.GetBuffList(self, iAttack, iDefense, iSpeed)
	local lBuff = {}
	lBuff[1] = iAttack > 0 and 141 or iAttack < 0 and 140 or nil
	lBuff[2] = iDefense > 0 and 143 or iDefense < 0 and 145 or nil
	lBuff[3] = iSpeed > 0 and 142 or iSpeed < 0 and 137 or nil

	return lBuff
end

function CWarriorAttrBuffList.EffectLoadDone(self, iIndex, vPos, iPosX, iPosY)
	local oWarrior = getrefobj(self.m_WarroiorRef)
	if not oWarrior then
		return
	end
	local oEffect = oWarrior.m_BuffEffList[iIndex]
	if not oEffect then
		return
	end
	oEffect:SetParent(oWarrior:GetBindTrans(vPos))
	local vPos = oEffect:GetPos()
	if not oEffect.m_OriginalPos then
		oEffect.m_OriginalPos = vPos
	end
	vPos.x = oEffect.m_OriginalPos.x + iPosX
	vPos.y = oEffect.m_OriginalPos.y + iPosY
	oEffect:SetPos(vPos)
end

return CWarriorAttrBuffList
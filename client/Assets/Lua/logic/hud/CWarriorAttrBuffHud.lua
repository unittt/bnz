local CWarriorAttrBuffHud = class("CWarriorAttrBuffHud", CAsynHud)

function CWarriorAttrBuffHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WarriorAttrBuffHud.prefab", cb)
end

function CWarriorAttrBuffHud.OnCreateHud(self)
	self.m_BuffEffList = {} --攻、防、速
	self.m_CellW = 32
end

function CWarriorAttrBuffHud.SetWarrior(self, oWarrior)
	self.m_WarroiorRef = weakref(oWarrior)
end

function CWarriorAttrBuffHud.UpdateAllAttr(self, iAttack, iDefense, iSpeed)
	local lBuff = self:GetBuffList(iAttack, iDefense, iSpeed)
	local oWarrior = getrefobj(self.m_WarroiorRef)
	local iCnt = table.count(lBuff)
	local iPosX = (1 - iCnt) * self.m_CellW/2
	for i = 1,3 do
		local iBuffId = lBuff[i]
		local dEffInfo = self.m_BuffEffList[i]
		if iBuffId then
			self:RemoveBuff(i)
			local dBuffData = DataTools.GetBuffData(iBuffId)
			if dBuffData then
				local oEffect = CEffect.New(dBuffData.path, oWarrior:GetLayer(), true)
				oEffect:SetParent(self.m_Transform)
				oEffect:SetLocalPos(Vector3.New(iPosX, -29, 0))
				iPosX = iPosX + self.m_CellW
				self.m_BuffEffList[i] = {id = iBuffId, eff = oEffect}
			end
		else
			self:RemoveBuff(i)
		end
	end

end

function CWarriorAttrBuffHud.RemoveBuff(self, iIndex)
	local dEffInfo = self.m_BuffEffList[iIndex]
	if not dEffInfo then
		return
	end
	--table.print(dEffInfo)
	dEffInfo.eff:Destroy()
	self.m_BuffEffList[iIndex] = nil
end

function CWarriorAttrBuffHud.GetBuffList(self, iAttack, iDefense, iSpeed)
	local lBuff = {}
	lBuff[1] = iAttack > 0 and 141 or iAttack < 0 and 140
	lBuff[2] = iDefense > 0 and 143 or iDefense < 0 and 145
	lBuff[3] = iSpeed > 0 and 142 or iSpeed < 0 and 137
	return lBuff
end

return CWarriorAttrBuffHud
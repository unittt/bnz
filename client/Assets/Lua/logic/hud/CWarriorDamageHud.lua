local CWarriorDamageHud = class("CWarriorDamageHud", CAsynHud)

function CWarriorDamageHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WarriorDamageHud.prefab", cb)
end

function CWarriorDamageHud.OnCreateHud(self)
	self.m_NumberBox = self:NewUI(1, CBox)
	self.m_NumberTable = self:NewUI(2, CTable)
	self.m_BaojiObj = self:NewUI(3, CObject)
	self.m_BgSp = self:NewUI(4, CSprite)

	self.m_NumberBox:SetActive(false)
	self.m_BaojiObj:SetActive(false)

	self.m_PosCache = {}
	self.m_PosIdx = 0
	self.m_Jump = 45
end

function CWarriorDamageHud.Recycle(self)

end

function CWarriorDamageHud.BuildNumber(self, iValue, bCrit, isDance)
	local oNumberBox = self.m_NumberBox:Clone()
	local oTable = oNumberBox:NewUI(1, CTable)
	local oNumbseSpr = oNumberBox:NewUI(2, CSprite)
	oNumbseSpr:SetActive(false)
	local sPrefix = ""
	if isDance then
		sPrefix = "8"
	else
		if iValue > 0  then
			sPrefix = "10"
		else
			sPrefix = bCrit and "8" or "8"
		end
	end
	local s = tostring(math.abs(iValue))
	local len = #s
	for i=1, len do
		local sNumber = string.sub(s, i, i)
		local oSpr = oNumbseSpr:Clone()
		oSpr:SetActive(true)
		oSpr:SetSpriteName("h7_"..sNumber .."_"..sPrefix)
		oSpr:MakePixelPerfect()
		-- local iScale = 1 - (len-i) * 0.035
		-- oSpr:SetLocalScale(Vector3.New(iScale, iScale, iScale))
		oTable:AddChild(oSpr)
	end
	oTable:Reposition()
	if bCrit then
		local oBg = self.m_BaojiObj:Clone()
		oBg:SetActive(true)
		oBg:SetParent(oNumberBox.m_Transform)
		if len > 3 then
			local pos = oBg:GetLocalPos()
			oBg:SetLocalPos(Vector3.New(pos.x + (len-3)*10, 0, 0))
		end
	end
	return oNumberBox
end

function CWarriorDamageHud.ShowDamage(self, iValue, bCrit, isDance)
	if isDance then
		self.m_BgSp:SetSpriteName("h7_huilv")
	else
		if iValue > 0 then
			self.m_BgSp:SetSpriteName("h7_huilv")
		else
			self.m_BgSp:SetSpriteName("h7_baoji")
		end
	end
	local oNumber = self:BuildNumber(iValue, bCrit, isDance)
	oNumber:SetParent(self.m_NumberTable.m_Transform)
	-- local pos = self:GetNextPos()
	-- pos.x = bCrit and 25 or 10
	-- oNumber:SetLocalPos(pos)
	oNumber:SetLocalScale(Vector3.New(1.2, 1.2, 1.2))
	oNumber:SetActive(true)
	self.m_NumberTable:Reposition()
	local iTime = bCrit and 1.5 or 1.5
	local iDelay = bCrit and 0.5 or 0.5
	--血条在下一帧的action里，故延后一帧时间
	g_ActionCtrl:AddAction(CActionFloat.New(oNumber, iTime-iDelay, "SetAlpha", 1, 0.35), iDelay + 0.03)
	-- local iScale = bCrit and 0.8 or 0.8
	-- local tween1 = DOTween.DOScale(oNumber.m_Transform, Vector3.New(iScale, iScale, iScale), 0.15)
	-- DOTween.SetEase(tween1, enum.DOTween.Ease.InElastic)
	Utils.AddTimer(function()
		if Utils.IsNil(self) then
			return
		end
		local pos = oNumber:GetLocalPos()
		for i, vCachePos in ipairs(self.m_PosCache) do
			if pos.y < vCachePos.y then
				table.insert(self.m_PosCache, i, pos)
				oNumber:Destroy()
				return
			end
		end
		table.insert(self.m_PosCache, pos)
		oNumber:Destroy() 
	end, iTime, iTime)
	return oNumber
end

function CWarriorDamageHud.GetNextPos(self)
	local pos
	if next(self.m_PosCache) then
		pos = self.m_PosCache[1]
		table.remove(self.m_PosCache, 1)
	else
		pos = Vector3.New(0, self.m_PosIdx*35, 0)
		self.m_PosIdx = self.m_PosIdx + 1
	end
	return pos
end

function CWarriorDamageHud.GetNextJump(self)
	self.m_Jump = self.m_Jump + 15
	self.m_Jump = self.m_Jump % 105
	if self.m_Jump == 0 then
		self.m_Jump = 60
	end
	return self.m_Jump 
end

return CWarriorDamageHud
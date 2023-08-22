local CWarriorMagicPointHud = class("CWarriorMagicPointHud", CAsynHud)

function CWarriorMagicPointHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WarriorMagicPointHud.prefab", cb)
end

function CWarriorMagicPointHud.OnCreateHud(self)
	self.m_NumberBox = self:NewUI(1, CBox)
	self.m_NumberTable = self:NewUI(2, CTable)

	self.m_NumberBox:SetActive(false)

	self.m_PosCache = {}
	self.m_PosIdx = 0
	self.m_Jump = 45
end

function CWarriorMagicPointHud.Recycle(self)

end

function CWarriorMagicPointHud.BuildNumber(self, iValue)
	local oNumberBox = self.m_NumberBox:Clone()
	local oTable = oNumberBox:NewUI(1, CTable)
	local oNumbseSpr = oNumberBox:NewUI(2, CSprite)
	oNumbseSpr:SetActive(false)
	local sPrefix = ""
	if iValue > 0  then
		sPrefix = "7"
	else
		sPrefix = "11"
	end
	local s = tostring(math.abs(iValue))
	local len = #s
	for i=1, len do
		local sNumber = string.sub(s, i, i)
		local oSpr = oNumbseSpr:Clone()
		oSpr:SetActive(true)
		oSpr:SetSpriteName("h7_"..sNumber .."_"..sPrefix)
		oSpr:MakePixelPerfect()
		oTable:AddChild(oSpr)
	end
	oTable:Reposition()
	return oNumberBox
end

function CWarriorMagicPointHud.ShowMagicPoint(self, iValue)
	local oNumber = self:BuildNumber(iValue)
	oNumber:SetParent(self.m_NumberTable.m_Transform)
	oNumber:SetLocalScale(Vector3.New(1.2, 1.2, 1.2))
	oNumber:SetActive(true)
	self.m_NumberTable:Reposition()
	local iTime = 1.5
	local iDelay = 0.5
	g_ActionCtrl:AddAction(CActionFloat.New(oNumber, iTime-iDelay, "SetAlpha", 1, 0.35), iDelay)
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

return CWarriorMagicPointHud
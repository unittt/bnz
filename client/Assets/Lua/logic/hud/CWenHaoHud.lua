local CWenHaoHud = class("CWenHaoHud", CAsynHud)

function CWenHaoHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WenHaoHud.prefab", cb)
	self.m_Effects = {}
end

function CWenHaoHud.OnCreateHud(self)

end

function CWenHaoHud.SetWenHaoMark(self)

	self:AddEffect("TaskDoneMark", Vector3.New(125, 125, 125))

end

function CWenHaoHud.AddEffect(self, sType, ...)
	if self.m_Effects[sType] then
		return self.m_Effects[sType]
	end
	local oEff = g_EffectCtrl:CreateUIEffect(sType, self,...)
	oEff:SetParent(self.m_Transform)
	self.m_Effects[sType] = oEff
	return oEff
end

function CWenHaoHud.DelEffect(self, sType)
	local oEff = self.m_Effects[sType]
	if oEff then
		oEff:Destroy()
		self.m_Effects[sType] = nil
	end
end

function CWenHaoHud.ClearEffect(self)
	for sType, oEffect in pairs(self.m_Effects) do
		self:DelEffect(sType)
	end
	self.m_Effects = {}
end

function CWenHaoHud.Destroy(self)
	self:ClearEffect()
	CAsynHud.Destroy(self)
end

return CWenHaoHud
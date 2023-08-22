local CAutoPatrolHud = class("CAutoPatrolHud", CAsynHud)

function CAutoPatrolHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/AutoPatrolHud.prefab", cb)
end

function CAutoPatrolHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CAutoPatrolHud
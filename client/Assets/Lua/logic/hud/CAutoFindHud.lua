local CAutoFindHud = class("CAutoFindHud", CAsynHud)

function CAutoFindHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/AutoFindHud.prefab", cb)
end

function CAutoFindHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CAutoFindHud
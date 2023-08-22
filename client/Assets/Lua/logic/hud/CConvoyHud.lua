local CConvoyHud = class("CConvoyHud", CAsynHud)

function CConvoyHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/ConvoyHud.prefab", cb)
end

function CConvoyHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CConvoyHud
local CFightHud = class("CFightHud", CAsynHud)

function CFightHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/FightHud.prefab", cb)
end

function CFightHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CFightHud
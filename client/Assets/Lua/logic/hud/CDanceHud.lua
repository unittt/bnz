local CDanceHud = class("CDanceHud", CAsynHud)

function CDanceHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/DanceHud.prefab", cb)
end

function CDanceHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CDanceHud
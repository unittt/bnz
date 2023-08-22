local CTreasureHud = class("CTreasureHud", CAsynHud)

function CTreasureHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/TreasureHud.prefab", cb)
end

function CTreasureHud.OnCreateHud(self)
	self.m_PointerSp = self:NewUI(1, CSprite)
end

return CTreasureHud
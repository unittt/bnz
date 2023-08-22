local CTeamHud = class("CTeamHud", CAsynHud)

function CTeamHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/TeamHud.prefab", cb)
end

function CTeamHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
end

return CTeamHud
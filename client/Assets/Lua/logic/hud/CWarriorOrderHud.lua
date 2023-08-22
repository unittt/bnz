local CWarriorOrderHud = class("CWarriorOrderHud", CAsynHud)

function CWarriorOrderHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WarriorOrderHud.prefab", cb)
end

function CWarriorOrderHud.OnCreateHud(self)
	self:SetLocalScale(Vector3.one*1.2)
end

return CWarriorOrderHud
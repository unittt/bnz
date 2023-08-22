local CWarriorReplaceHud = class("CWarriorReplaceHud", CAsynHud)

function CWarriorReplaceHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WarriorReplaceHud.prefab", cb)
end

return CWarriorReplaceHud
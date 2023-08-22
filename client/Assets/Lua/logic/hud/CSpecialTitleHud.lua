local CSpecialTitleHud = class("CSpecialTitleHud", CAsynHud)

function CSpecialTitleHud.ctor(self, cb)
    CAsynHud.ctor(self, "UI/Hud/SpecialTitleHud.prefab", cb)
end

function CSpecialTitleHud.OnCreateHud(self)
    self.m_Sprite = self:NewUI(1, CSprite)
end

function CSpecialTitleHud.SetSpriteName(self, tid)
    local iconid = data.titledata.INFO[tid].icon
    if iconid ~= nil then
        self.m_Sprite:SetSpriteName(tostring(iconid))
        self.m_Sprite:MakePixelPerfect()
    end
end

return CSpecialTitleHud
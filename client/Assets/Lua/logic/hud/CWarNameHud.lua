local CWarNameHud = class("CWarNameHud", CAsynHud)

function CWarNameHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WarNameHud.prefab", cb)
end

function CWarNameHud.OnCreateHud(self)
	self.m_NameLabel = self:NewUI(1, CLabel)
  self.m_BadgeIcon = self:NewUI(2, CSprite)
end

function CWarNameHud.SetName(self, s, blod)
 --  if blod ~= nil then
 --    blod = blod == 0 and "" or "[b]"
 --  else
 --    blod = g_WarCtrl:IsWar() and "" or "[b]"
 --  end
	-- self.m_NameLabel:SetText(blod .. s)
  self.m_NameLabel:SetText(s)
  self.m_BadgeIcon:SetActive(false)

  local scale = 1
  if g_WarCtrl:IsWar() then
    scale = 1.1
  end
  self:SetLocalScale(Vector3.one*scale)
end

function CWarNameHud.GetName(self)
	return self.m_NameLabel:GetText()
end

function CWarNameHud.SetBadgeIcon(self, id)
    if id and id > 0 then
        local info = data.touxiandata.DATA[id]
        if info then
           local name = info.tid.."wear"
           self.m_BadgeIcon:SetSpriteName(name)
           self.m_BadgeIcon:SetActive(true)
        end
    else 
        self.m_BadgeIcon:SetActive(false)
    end  
end

return CWarNameHud
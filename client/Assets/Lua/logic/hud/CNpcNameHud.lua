local CNpcNameHud = class("CNpcNameHud", CAsynHud)

function CNpcNameHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/NpcNameHud.prefab", cb)
end

function CNpcNameHud.OnCreateHud(self)
	self.m_NameLabel = self:NewUI(1, CHudLabel)
  self.m_BadgeIcon = self:NewUI(2, CSprite)
  self.m_StarIcon = self:NewUI(3, CSprite)
end

function CNpcNameHud.SetName(self, name, color, dColorData)
  -- local blod = dColorData.blod
  -- if blod ~= nil then
  --   blod = blod == 0 and "" or "[b]"
  -- else
  --   blod = g_WarCtrl:IsWar() and "" or "[b]"
  -- end
  color = color or dColorData.color
  -- self.m_NameLabel:SetEffectDistance(Vector2.New(dColorData.shadow_size, dColorData.shadow_size))
  self.m_NameLabel:SetFontSize(dColorData.size)
  -- self.m_NameLabel:SetText(blod .."["..color.."]"..name)
  self.m_NameLabel:SetText("["..color.."]"..name)
  self.m_BadgeIcon:SetActive(false)

  local scale = 1
  if g_WarCtrl:IsWar() then
    scale = 1.1
  end
  self:SetLocalScale(Vector3.one*scale)
end


function CNpcNameHud.GetName(self)
	return self.m_NameLabel:GetText()
end

function CNpcNameHud.SetBadgeIcon(self, id)
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

return CNpcNameHud
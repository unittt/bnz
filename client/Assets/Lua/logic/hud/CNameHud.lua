local CNameHud = class("CNameHud", CAsynHud)

function CNameHud.ctor(self, cb)
  CAsynHud.ctor(self, "UI/Hud/NameHud.prefab", cb)
end

function CNameHud.OnCreateHud(self)
	self.m_NameLabel = self:NewUI(1, CHudLabel)
  self.m_BadgeIcon = self:NewUI(2, CSprite)
  self.m_StarIcon = self:NewUI(3, CSprite)
  self.m_HeartIcon = self:NewUI(4, CSprite)
  self.m_HeartIcon2 = self:NewUI(5, CSprite)
end

function CNameHud.SetName(self, name, color, dColorData)
  -- local blod = dColorData.blod
  -- if blod ~= nil then
  --   blod = blod == 0 and "" or "[b]"
  -- else
  --   blod = g_WarCtrl:IsWar() and "" or "[b]"
  -- end
  color = color or dColorData.color
  --特殊处理星星图标显示
  local oName, oCount = string.gsub(name, "#w4", "   ")
	-- self.m_NameLabel:SetText(blod .. "["..color.. "]"..oName)
  self.m_NameLabel:SetText("["..color.. "]"..oName)

  if oCount > 0 then
      local leftOffset = string.find(name, '%(')
      local x = 0
      if leftOffset then
        x = leftOffset
      else
        x = string.len(oName)
      end
      x = (x-1) / 3
      local pos = Vector3.New(x*10 + 8, 0, 0)
      self.m_StarIcon:SetLocalPos(pos)
      self.m_StarIcon:SetActive(true)
  else
      self.m_StarIcon:SetActive(false)
  end
  self.m_BadgeIcon:SetActive(false)
  self.m_NameLabel:SetFontSize(dColorData.size)
  -- self.m_NameLabel:SetEffectStyle(dColorData.style)
  -- self.m_NameLabel:SetEffectDistance(Vector2.New(dColorData.shadow_size, dColorData.shadow_size))
  -- self.m_NameLabel:SetEffectColor(Color.RGBAToColor(dColorData.style_color))
  local scale = 1
  if g_WarCtrl:IsWar() then
    scale = 1.1
  end
  self:SetLocalScale(Vector3.one*scale)
end

function CNameHud.GetName(self)
	return self.m_NameLabel:GetText()
end

function CNameHud.ShowHeart(self, idx, bShow)
    if idx == 1 then
      self.m_HeartIcon:SetActive(bShow)
    else
      self.m_HeartIcon2:SetActive(bShow)
    end
end

function CNameHud.SetBadgeIcon(self, id)
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

function CNameHud.Recycle(self)
    self.m_HeartIcon:SetActive(false)
    self.m_HeartIcon2:SetActive(false)
    CAsynHud.Recycle(self)
end

return CNameHud
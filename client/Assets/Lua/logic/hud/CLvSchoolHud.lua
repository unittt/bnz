local CLvSchoolHud = class("CLvSchoolHud", CAsynHud)

function CLvSchoolHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/LvSchoolHud.prefab", cb)
end

function CLvSchoolHud.OnCreateHud(self)
	self.m_NameLabel = self:NewUI(1, CHudLabel)
  --self.m_BadgeIcon = self:NewUI(2, CSprite)
end

function CLvSchoolHud.SetName(self, s)
  -- local blod = g_WarCtrl:IsWar() and "" or "[b]"
	self.m_NameLabel:SetText(s)
  -- self.m_BadgeIcon:SetActive(false)

  local scale = 1.2
  -- if g_WarCtrl:IsWar() then
  --   scale = 1.2
  -- end
  self:SetLocalScale(Vector3.one*scale)
end

function CLvSchoolHud.GetName(self)
	return self.m_NameLabel:GetText()
end

-- function CLvSchoolHud.SetBadgeIcon(self, id)
--     if id and id > 0 then
--         local info = data.touxiandata.DATA[id]
--         if info then
--            local name = info.tid.."wear"
--            self.m_BadgeIcon:SetSpriteName(name)
--            self.m_BadgeIcon:SetActive(true)
--         end
--     else 
--         self.m_BadgeIcon:SetActive(false)
--     end  
-- end

return CLvSchoolHud
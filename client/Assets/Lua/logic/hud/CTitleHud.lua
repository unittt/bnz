local CTitleHud = class("CTitleHud", CAsynHud)

function CTitleHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/TitleHud.prefab", cb)
end

function CTitleHud.OnCreateHud(self)
  self.m_Icon = self:NewUI(1, CSprite)
  self.m_EffectNode = self:NewUI(2, CObject)
end

function CTitleHud.SetTitleIcon(self, id)
    if id and id > 0 then
        local info = data.touxiandata.DATA[id]
        if info then
           self.m_Icon:SetSpriteName(info.icon)
           self.m_Icon:MakePixelPerfect()
           local w, h = self.m_Icon:GetSize()
           self.m_Icon:SetSize(w*info.scale, h*info.scale)
           self.m_Icon:SetActive(true)

           if info.uiEffect ~= "" then
              local path = "Effect/UI/ui_eff_" .. info.uiEffect .."/Prefabs/" .. "ui_eff_" .. info.uiEffect .. ".prefab"
              if self.m_Effect then 
                self.m_Effect:Destroy()
                self.m_Effect = nil
              end 
              self.m_Effect = CEffect.New(path, self:GetLayer(), true)   
              self.m_Effect:SetParent(self.m_EffectNode.m_Transform)
              self.m_EffectNode:SetLocalScale(Vector3.New(info.scale, info.scale, info.scale))
           end
        end
    else 
        self.m_Icon:SetActive(false)
        if self.m_Effect then 
          self.m_Effect:Destroy()
          self.m_Effect = nil
        end 
    end
end

return CTitleHud
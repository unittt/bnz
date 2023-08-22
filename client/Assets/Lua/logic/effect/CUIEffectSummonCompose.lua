local CUIEffectSummonCompose = class("CUIEffectSummonCompose", CWidget)

function CUIEffectSummonCompose.ctor(self, oAttach, cb, pos)
    local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
    -- local mWidget = obj:AddComponent(classtype.UIWidget)
    CWidget.ctor(self, obj)
    self.m_UIWidget.enabled = true
    self.m_LoadDoneFunc = cb
    self.m_RefAttach = weakref(oAttach)
    self.m_EffPos = pos
    self:AddShelter()
    g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_0081/Prefabs/ui_eff_0081.prefab", callback(self, "OnEffLoad"), false)
end

function CUIEffectSummonCompose.AddShelter(self)
    self.m_Shelter = CBehindLayer.New()
    self.m_Shelter:SetTextrueShow(false)
    self.m_Shelter:SetShelter(true)
    self.m_Shelter:SetDepth(50000 * 9)
    self.m_Shelter:SetPos(Vector3.zero)
end

function CUIEffectSummonCompose.OnEffLoad(self, oClone)
    local oAttach = getrefobj(self.m_RefAttach)
    if oClone and oAttach then
        self.m_Eff = CObject.New(oClone)
        self.m_Eff:SetParent(self.m_Transform)
        self.m_Eff:SetLocalPos(self.m_EffPos or Vector3.zero)
    end
    if self.m_LoadDoneFunc then
        self.m_LoadDoneFunc(oClone)
        self.m_LoadDoneFunc = nil
    end
end

function CUIEffectSummonCompose.Destroy(self)
    if self.m_Shelter then
        self.m_Shelter:Destroy()
    end
    CWidget.Destroy(self)
end

return CUIEffectSummonCompose
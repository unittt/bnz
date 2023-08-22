local CUIEffectSummonWash = class("CUIEffectSummonWash", CWidget)

function CUIEffectSummonWash.ctor(self, oAttach, cb, pos)
    local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
    -- local mWidget = obj:AddComponent(classtype.UIWidget)
    CWidget.ctor(self, obj)
    self.m_UIWidget.enabled = true
    self.m_LoadDoneFunc = cb
    self.m_RefAttach = weakref(oAttach)
    self.m_EffPos = pos
    g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_0082/Prefabs/ui_eff_0082.prefab", callback(self, "OnEffLoad"), false)
end

function CUIEffectSummonWash.OnEffLoad(self, oClone)
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

return CUIEffectSummonWash
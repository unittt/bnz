local CUIEffectLianHua = class("CUIEffectLianHua", CWidget)

function CUIEffectLianHua.ctor(self, oAttach, cb, pos)
    local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
    -- local mWidget = obj:AddComponent(classtype.UIWidget)
    CWidget.ctor(self, obj)
    self.m_UIWidget.enabled = true
    self.m_LoadDoneFunc = cb
    self.m_RefAttach = weakref(oAttach)
    self.m_EffPos = pos
    g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_0088/Prefabs/ui_eff_0088.prefab", callback(self, "OnEffLoad"), false)
end

function CUIEffectLianHua.OnEffLoad(self, oClone)
    local oAttach = getrefobj(self.m_RefAttach)
    if oClone and oAttach then
        self.m_Eff = CObject.New(oClone)
        self.m_Eff:SetParent(self.m_Transform)
        self.m_Eff:SetLocalPos(self.m_EffPos or Vector3.zero)

        local mPanel = self.m_Eff:GetComponent(classtype.UIPanel)
        mPanel.uiEffectDrawCallCount = 1
        local mRenderQ = self.m_Eff:GetComponent(classtype.UIEffectRenderQueue)
        self.m_Eff.m_RenderQComponent = mRenderQ
        mRenderQ.needClip = true
        mRenderQ.attachGameObject = oAttach.m_GameObject

    end
    if self.m_LoadDoneFunc then
        self.m_LoadDoneFunc(oClone)
        self.m_LoadDoneFunc = nil
    end
end

return CUIEffectLianHua
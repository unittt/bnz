local CWarFailPromoteView = class("CWarFailPromoteView", CViewBase)

function CWarFailPromoteView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Promote/PromoteTipView.prefab", cb)
    self.m_ExtendClose = "Black"
end

function CWarFailPromoteView.OnCreateView(self)
    self.m_PromoteGrid = self:NewUI(1, CGrid)
    self.m_PromoteBtnClone = self:NewUI(2, CButton)
    self.m_PromoteBtnClone:SetActive(false)

    -- self:InitContent()
end

function CWarFailPromoteView.SetContent(self, configList)
    self.m_PromoteGrid:Clear()
    for _,config in ipairs(configList) do
        local oPromoteBtn = self.m_PromoteBtnClone:Clone()
        oPromoteBtn:SetActive(true)
        self.m_PromoteGrid:AddChild(oPromoteBtn)
        
        oPromoteBtn:SetSpriteName(config.iconname)
        oPromoteBtn:SetText(config.des)
        oPromoteBtn:AddUIEvent("click", callback(self, "OnPromote", config))
    end
    self.m_PromoteGrid:Reposition()
end

function CWarFailPromoteView.OnPromote(self, config)
    g_ViewCtrl:ShowViewBySysName(config.logic.sysname, config.logic.tabname)
    self:CloseView()
end

return CWarFailPromoteView
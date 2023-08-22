local CWingMainView = class("CWingMainView", CViewBase)

function CWingMainView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Wing/WingMainView.prefab", cb)
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CWingMainView.OnCreateView(self)
    self.m_TitleSprite = self:NewUI(1, CSprite)
    self.m_CloseBtn = self:NewUI(2, CButton)
    self.m_BtnGrid = self:NewUI(3, CTabGrid)
    self.m_PropertyPart = self:NewPage(4, CWingPropertyPage)
    self.m_TimeWingPart = self:NewPage(5, CWingTimeWingPage)
    self:InitContent()
end

function CWingMainView.InitContent(self)
    self.m_BtnGrid:InitChild(function(obj, idx)
        local oBtn = CButton.New(obj)
        oBtn:SetGroup(self:GetInstanceID())
        return oBtn
    end)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    for i, oTab in ipairs(self.m_BtnGrid:GetChildList()) do
        oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i, true))
    end
    g_GuideCtrl:AddGuideUI("wingview_close_btn", self.m_CloseBtn)
    self:ShowSubPageByIndex(1)
end

function CWingMainView.ShowSubPageByIndex(self, iIndex, bClk)
    local oTab = self.m_BtnGrid:GetChild(iIndex)
    if iIndex == 1 and not g_WingCtrl:IsUnlockWingSys() then
        if bClk then
            g_WingCtrl:WingFloatMsg(3005)
        end
        self:ShowSubPageByIndex(2)
        return
    end
    oTab:SetSelected(true)
    CGameObjContainer.ShowSubPageByIndex(self, iIndex)
end

function CWingMainView.Destroy(self)
    CViewBase.Destroy(self)
end

return CWingMainView
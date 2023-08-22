local CWingPropertyPage = class("CWingPropertyPage", CPageBase)

function CWingPropertyPage.ctor(self, obj)
    CPageBase.ctor(self, obj)
    self.m_AttrBox = self:NewUI(1, CWingAttrBox)
    self.m_ShapeBox = self:NewUI(2, CWingShapeBox)
    self.m_CultureBox = self:NewUI(3, CWingCultureBox)
    self.m_ActiveBtn = self:NewUI(4, CButton)
    self.m_TipBtn = self:NewUI(5, CButton)
    self.m_CanUnlock = false
end

function CWingPropertyPage.OnInitPage(self)
    self:RefreshAll()
    self.m_ActiveBtn.m_IgnoreCheckEffect = true
    self.m_ActiveBtn:AddUIEvent("click", callback(self, "OnClickActive"))
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTip"))
    g_WingCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWingEvent"))
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))
    g_GuideCtrl:AddGuideUI("wing_active_btn", self.m_ActiveBtn)
end

function CWingPropertyPage.RefreshAll(self)
    local attrs = {}
    self.m_AttrBox:RefreshAttr(g_WingCtrl:GetEffectAttrs())
    self.m_ShapeBox:RefreshInfo()
    self.m_CultureBox:RefreshInfo()
    self:RefreshBtn()
end

function CWingPropertyPage.RefreshBtn(self)
    local bLock = not g_WingCtrl:HasActiveWing()
    self.m_ActiveBtn:SetActive(bLock)
    if bLock then
        self.m_CanUnlock = g_ItemCtrl:GetBagItemAmountBySid(g_WingCtrl.activeCost) > 0
        if self.m_CanUnlock then
            self.m_ActiveBtn:AddEffect("RedDot", 22, Vector2(-15,-15))
        else
            self.m_ActiveBtn:DelEffect("RedDot")
        end
    end
end

function CWingPropertyPage.OnClickActive(self)
    if self.m_CanUnlock then
        netwing.C2GSWingWield()
    else
        g_WingCtrl:WingFloatMsg(6001)
        -- CNpcShopMainView:ShowView(function(oView)
        --     oView:JumpToTargetItem(g_WingCtrl.activeCost)
        -- end)
        CFuncNotifyMainView:ShowView(function (oView)
            oView:RefreshUI(g_GuideHelpCtrl.m_WingGuideIndex)
        end)
    end
end

function CWingPropertyPage.OnClickTip(self)
    local instructionConfig = data.instructiondata.DESC[10058]
    if instructionConfig then
        local zContent = {
            title = instructionConfig.title,
            desc = instructionConfig.desc,
        }
        g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
    end
end

function CWingPropertyPage.OnWingEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Wing.Event.RefreshWing then
        self:RefreshAll()
    end
end

function CWingPropertyPage.OnItemEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
        self.m_CultureBox:RefreshInfo()
        self:RefreshBtn()
    end
end

return CWingPropertyPage
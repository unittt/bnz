local CLockScreenBox = class("CLockScreenBox", CBox)

function CLockScreenBox.ctor(self, obj)
    CBox.ctor(self, obj)
    
    self.m_Slider = self:NewUI(1,CSlider)
    self.m_TipsSpr = self:NewUI(2, CSprite)
    self.m_Thumb = self:NewUI(3, CSprite)

    self.m_Eff = self.m_Slider:AddEffect("Lock")
    if not Utils.IsNil(self.m_Eff) and self.m_Eff.m_Transform then
        self.m_Eff:SetLocalPos(Vector3.New(49,0,0))
    end

    self.m_Thumb:AddUIEvent("dragstart", callback(self, "OnDragStart"))
    self.m_Thumb:AddUIEvent("dragend", callback(self, "OnDragEnd"))
    self.m_Slider:AddUIEvent("change", callback(self, "OnChange"))
    self.m_TipsSpr:SetFillAmount(1)

end

function CLockScreenBox.Reset(self)
    if Utils.IsNil(self) then
        return
    end
    local val = self.m_Slider:GetValue()
    if val == 0 then
        return
    end
    
    self.m_Slider:SetValue(0)
    self.m_TipsSpr:SetFillAmount(1)

    -- local oUICamera = g_CameraCtrl:GetNGUICamera()
    -- if oUICamera then
    --     printc(" oUICamera --  ----------")

    --     -- local oThumb = self.m_Thumb.gameObject
    --     -- local isPressed = oUICamera:IsPressed(oThumb)
    --     -- printc("isPressed -- "..tostring(isPressed))

    --     oUICamera:ProcessTouches()
    -- else
    --     printc("not oUICamera")
    -- end
end

function CLockScreenBox.RefreshLockState(self, bIsLock)

    if not bIsLock then
         local val = self.m_Slider:GetValue()
        if self:GetActive() and val > 0 then
            self:SetActive(bIsLock)
        end
    else
        self:SetActive(bIsLock)
    end

    if bIsLock then
        self.m_Slider:SetValue(0)
        self.m_TipsSpr:SetFillAmount(1)
    end
end

function CLockScreenBox.SetLabelEffect(self, bShow)
    local bShow = bShow or false
    if not self.m_LabelEff then
        self.m_LabelEff = self.m_Eff:Find("ui_eff_0095(Clone)/ui_eff_0095_biankuang2").gameObject
    end
    self.m_LabelEff:SetActive(bShow)
end

function CLockScreenBox.OnDragStart(self)
    self:SetLabelEffect(false)
end

function CLockScreenBox.OnDragEnd(self)
    self:SetLabelEffect(true)
    if self.m_Slider:GetValue() < 0.85 then
        self.m_Slider:SetValue(0)
        self.m_TipsSpr:SetFillAmount(1)
       return
    end
    self:RefreshLockState(false)
    self.m_Slider:SetValue(0)
    g_SystemSettingsCtrl:SaveLocalSettings("lock_screen", false)
end

function CLockScreenBox.OnChange(self, oSlider)
    local val = oSlider:GetValue()
    self.m_TipsSpr:SetFillAmount(1 - val)
end

return CLockScreenBox
local CWarTempGridBox = class("CWarTempGridBox", CBox)

function CWarTempGridBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_Grid = self:NewUI(1, CGrid)
    self.m_BottleBtn = self:NewUI(2, CButton)
    self.m_BottleL = self:NewUI(3, CLabel)

    self:InitContent()
end

function CWarTempGridBox.InitContent(self)
    self:InitBottle()
end

function CWarTempGridBox.InitBottle(self)
    self.m_BottleBtn.m_IgnoreCheckEffect = true
    self.m_BottleTimer = nil
    self:UpdateBottle()
    self.m_BottleBtn:AddUIEvent("click",callback(self,"OnClickBottle"))
    g_WishBottleCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self,"OnBottleEvent"))
end

function CWarTempGridBox.OnBottleEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WishBottle.Event.ReceiveBottle then
        self:UpdateBottle()
    elseif oCtrl.m_EventID == define.WishBottle.Event.UpdateBottleTime then
        self:UpdateBtnTime(oCtrl.m_EventData)
    end
end

function CWarTempGridBox.UpdateBottle(self)
    local iBottle = g_WishBottleCtrl:GetBottle()
    if iBottle > 0 then
        self.m_BottleBtn:SetActive(false)
        g_WishBottleCtrl:AskForBottleInfo()
    else
        self.m_BottleBtn:SetActive(iBottle ~= 0)
        self.m_BottleBtn:DelEffect("Rect")
    end
    self.m_Grid:Reposition()
end

function CWarTempGridBox.UpdateBtnTime(self, iTime)
    local bShow = self.m_BottleBtn:GetActive()
    if not bShow then
        self.m_BottleBtn:SetActive(true)
        self.m_Grid:Reposition()
    end
    self.m_BottleL:SetActive(true)
    self.m_BottleBtn:AddEffect("Rect")
    self:RemoveBottleTimer()
    local function update ()
        local iDiffTime = os.difftime(iTime, g_TimeCtrl:GetTimeS())
        if iDiffTime > 0 then
            self.m_BottleL:SetText(os.date("%M:%S",iDiffTime))
            return true
        else
            self.m_BottleL:SetText("00:00")
            g_WishBottleCtrl:UpdateBottleId(0)
            return false
        end
    end
    self.m_BottleTimer = Utils.AddTimer(update, 1, 0)
end

function CWarTempGridBox.RemoveBottleTimer(self)
    if self.m_BottleTimer then
        Utils.DelTimer(self.m_BottleTimer)
        self.m_BottleTimer = nil
    end
end

function CWarTempGridBox.OnClickBottle(self)
    g_WishBottleCtrl:ShowBottleView()
end

function CWarTempGridBox.Destroy(self)
    self:RemoveBottleTimer()
    CBox.Destroy(self)
end

return CWarTempGridBox
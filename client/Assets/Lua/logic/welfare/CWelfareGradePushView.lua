local CWelfareGradePushView = class("CWelfareGradePushView", CViewBase)

function CWelfareGradePushView.ctor(self,cb)
    CViewBase.ctor(self, "UI/Welfare/WelfareGradePushView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "Black"
end

function CWelfareGradePushView.OnCreateView(self)
    self.m_BuyBtn = self:NewUI(1, CButton)
    self.m_PriceSpr = self:NewUI(2, CSprite)
    self.m_MoneySpr = self:NewUI(3, CSprite)
    self.m_CloseBtn = self:NewUI(4, CButton)
    self.m_TimeL = self:NewUI(5, CLabel)
    self.m_RebateCntL = self:NewUI(6, CLabel)
    self:InitContent()
    self.m_BuyBtn:AddUIEvent("click", callback(self,"OnClickBtn"))
    self.m_CloseBtn:AddUIEvent("click", callback(self,"OnClose"))
end

function CWelfareGradePushView.InitContent(self)
    local iGradeLv = g_BigProfitCtrl:GetGradePnlLevel()
    local bLvOne = iGradeLv == 1
    self.m_MoneySpr:SetActive(not bLvOne)
    self.m_RebateCntL:SetActive(bLvOne)
    self.m_TimeL:SetText(8)
    if bLvOne then
        self.m_PriceSpr:SetSpriteName("h7_88")
        -- self.m_MoneySpr:SetSpriteName("h7_7040")
        self.m_RebateCntL:SetText(string.ConvertToArt(5456))
    else
        self.m_PriceSpr:SetSpriteName("h7_98")
        self.m_MoneySpr:SetSpriteName("h7_7840")
    end
end

function CWelfareGradePushView.OnClickBtn(self)
    local iPayid = g_BigProfitCtrl:GetBigProfitPayId()
    if iPayid and string.len(iPayid) > 0 then
        printc("一本万利充值回调数据信息 ----- ", iPayid)
	g_PayCtrl:Charge(iPayid)
    end
    self:OnClose()
end

return CWelfareGradePushView
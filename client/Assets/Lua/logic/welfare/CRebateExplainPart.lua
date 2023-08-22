local CRebateExplainPart = class("CRebateExplainPart", CPageBase)

function CRebateExplainPart.ctor(self, cb)
    CPageBase.ctor(self, cb)

    self.m_BuyBtn = self:NewUI(1,CButton)
    self.m_TipBtn = self:NewUI(10,CButton)
end

function CRebateExplainPart.OnInitPage(self)
    self.m_BuyBtn:AddUIEvent("click", callback(self,"OnClickBuy"))
    self.m_TipBtn:AddUIEvent("click", callback(self,"OnClickTipBtn"))
end

function CRebateExplainPart.OnClickBuy(self)
    CNpcShopMainView:ShowView(function(oView)
        oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
    end)
    CWelfareView:CloseView()
end

function CRebateExplainPart.OnClickTipBtn(self)
    local instructionConfig = data.instructiondata.DESC[10026]
    if instructionConfig then
        local zContent = {
            title = instructionConfig.title,
            desc = instructionConfig.desc,
        }
        g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
    end
end

return CRebateExplainPart
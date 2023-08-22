local CFirstPayPage = class("CWelfareFirstChargePart", CPageBase)

function CFirstPayPage.ctor(self, cb)
    CPageBase.ctor(self,cb)
    self.m_CurIdx = nil
    self.m_BoxDict = {}
end

function CFirstPayPage.OnInitPage(self)
    self.m_TabGrid = self:NewUI(1, CGrid)
    self.m_Box1 = self:NewUI(2, CFirstPayBox)
    self.m_Box2 = self:NewUI(3, CFirstPayBox)
    self.m_Box3 = self:NewUI(4, CFirstPayBox)
    self.m_GetBtn = self:NewUI(5, CButton)
    self.m_ChargeTipL = self:NewUI(6, CLabel)
    self.m_GotSpr = self:NewUI(7, CSprite)
    self:InitContent()
end

function CFirstPayPage.ShowPage(self)
    CPageBase.ShowPage(self)
    if g_FirstPayCtrl.selIdx and g_FirstPayCtrl.selIdx ~= self.m_CurIdx then
        self:SelectTab(g_FirstPayCtrl.selIdx)
    end
    g_FirstPayCtrl.selIdx = nil
end

function CFirstPayPage.InitContent(self)
    self.m_BoxDict = {
        [1] = self.m_Box1,
        [2] = self.m_Box2,
        [3] = self.m_Box3,
    }
    local iSel = math.min(g_FirstPayCtrl.selIdx or 1, 3)
    if iSel > 1 then
        self.m_Box1:SetActive(false)
    end
    self.m_TabGrid:InitChild(function(obj, idx)
        local oBtn = CButton.New(obj)
        oBtn:AddUIEvent("click", callback(self, "OnClickTab", idx))
        oBtn.m_IgnoreCheckEffect = true
        if iSel == idx then
            oBtn:SetSelected(true)
            self:OnClickTab(idx)
        end
        return oBtn
    end)
    self:RefreshTabs()
    self.m_GetBtn:AddUIEvent("click", callback(self, "OnClickBtn"))
end

function CFirstPayPage.Refresh(self)
    if self.m_IsInit then
        self:RefreshBtn()
        self:RefreshTabs()
    end
end

function CFirstPayPage.RefreshTabs(self)
    local tabList = self.m_TabGrid:GetChildList()
    for idx, oTab in ipairs(tabList) do
        local bRed = g_FirstPayCtrl:GetChargeStatus(idx) == 1
        if bRed then
            oTab:AddEffect("RedDot", 20, Vector2.New(-20, -18))
        else
            oTab:DelEffect("RedDot")
        end
    end
end

function CFirstPayPage.RefreshBtn(self)
    local iStatus = g_FirstPayCtrl:GetChargeStatus(self.m_CurIdx)
    if iStatus == 2 then
        self.m_GetBtn:SetActive(false)
        self.m_GotSpr:SetActive(true)
        self.m_ChargeTipL:SetActive(false)
        return
    end
    self.m_GetBtn:SetActive(true)
    self.m_GotSpr:SetActive(false)
    local bShowTip = iStatus == 0
    if bShowTip then
        self.m_GetBtn:SetText("前往充值")
    else
        self.m_GetBtn:SetText("立即领取")
    end
    if bShowTip then
        local iNeed = g_FirstPayCtrl:GetNeedCharge(self.m_CurIdx)
        bShowTip = iNeed > 0
        if bShowTip then
            self.m_ChargeTipL:SetText(string.format("(再充值%d元可领取)", iNeed))
        end
    end
    self.m_ChargeTipL:SetActive(bShowTip)
end

function CFirstPayPage.SelectTab(self, idx)
    local oBtn = self.m_TabGrid:GetChild(idx)
    if oBtn then
        oBtn:SetSelected(true)
        self:OnClickTab(idx)
    end
end

function CFirstPayPage.OnClickTab(self, idx)
    if self.m_CurIdx ~= idx then
        if self.m_CurIdx then
            local oCurBox = self.m_BoxDict[self.m_CurIdx]
            if oCurBox then
                oCurBox:SetActive(false)
            end
        end
        local oBox = self.m_BoxDict[idx]
        if oBox then
            oBox:SetActive(true)
            oBox:RefreshAll(idx)
            self.m_CurIdx = idx
        end
        self:RefreshBtn()
    end
end

function CFirstPayPage.OnClickBtn(self)
    local idx = self.m_CurIdx
    if idx then
        local iStatus = g_FirstPayCtrl:GetChargeStatus(idx)
        if iStatus == 0 then
            CNpcShopMainView:ShowView(function(oView)
                oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
            end)
        elseif iStatus == 1 then
            nethuodong.C2GSRewardFirstPayGift(idx)
        else
            local dDescCont = DataTools.GetWelfareData("TEXT", 1008)
            if dDescCont then 
                g_NotifyCtrl:FloatMsg(dDescCont.content)
            end
        end
    end
end

return CFirstPayPage
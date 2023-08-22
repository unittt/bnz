local CGaideMainView = class("CGaideMainView", CViewBase)

function CGaideMainView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Promote/PromoteView.prefab", cb)
    --界面设置
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CGaideMainView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_TitleSpr = self:NewUI(2, CSprite)
    self.m_BtnGrid = self:NewUI(3, CTabGrid)
    self.m_PromotePart = self:NewPage(4, CPromotePart)
    self.m_GrowPart = self:NewPage(5, CGrowPart)
    self.m_SourceBookPart = self:NewPage(6, CSourceBookPart)

    self:InitContent()
    self.m_IsNotCheckOnLoadShow = true
end

function CGaideMainView.InitContent(self)
    self.m_BtnGrid:InitChild(function(obj, idx)
            local oBtn = CButton.New(obj)
            oBtn:SetGroup(self:GetInstanceID())
            return oBtn
        end)
    self.m_PromoteBtn = self.m_BtnGrid:GetChild(1)

    --self:InitTab()
    g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "CheckBtnRedDot"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    for i, oTab in ipairs(self.m_BtnGrid:GetChildList()) do
        oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i))
    end
    if g_PromoteCtrl.m_GrowRedPoint then
        self:ShowSubPageByIndex(2)
        self.m_BtnGrid:GetChild(2):AddEffect("RedDot", 22)
    else
        self:ShowSubPageByIndex(1)
    end
    -- self:HideSourceBook()
    self:RegisterSysEffs()
end

function CGaideMainView.InitTab(self)
    local bIsOpen = g_OpenSysCtrl:GetOpenSysState(define.System.Cultivation)
    if bIsOpen then
        self.m_CultivateBtn:SetActive(true)
    else
        self.m_CultivateBtn:SetActive(false)
    end
    
    self.m_BtnGrid:Reposition()
end

function CGaideMainView.ShowSubPageByIndex(self, iIndex, ...)
    local oTab = self.m_BtnGrid:GetChild(iIndex)
    oTab:SetSelected(true)
    CGameObjContainer.ShowSubPageByIndex(self, iIndex, ...)
    if iIndex == 1 then
        self.m_TitleSpr:SetSpriteName("h7_tisheng_4")
    elseif iIndex == 2 then
        self.m_TitleSpr:SetSpriteName("h7_chengzhang_3")
    elseif iIndex == 3 then
        self.m_TitleSpr:SetSpriteName("h7_youxizhiyin")
    end
     self.m_TitleSpr:MakePixelPerfect()
end

function CGaideMainView.OnShowView(self)
    g_PromoteCtrl:C2GSGetPromote()
end

function CGaideMainView.CheckBtnRedDot(self, oCtrl)
    if oCtrl.m_EventID == define.Promote.Event.RefreshGrowRedPoint then
        self:RefreshGrowBtn()
    end
end

function CGaideMainView.HideSourceBook(slef)
    -- body
    local SourceBookList =  g_PromoteCtrl:GetSysOpenSourceBook()
    if not next(SourceBookList) then
        self.m_BtnGrid:GetChild(3):SetActive(false)
    end
end

function CGaideMainView.CloseView(self)
    CViewBase.CloseView(self)
end

function CGaideMainView.RefreshGrowBtn(self)
    local oBtn = self.m_BtnGrid:GetChild(2)
    if g_PromoteCtrl.m_GrowRedPoint then
        oBtn:AddEffect("RedDot")
        oBtn.m_IgnoreCheckEffect = true
    elseif g_SysUIEffCtrl:IsExistRecord("GROW") then
        oBtn:AddEffect("RedDot",20,Vector2(-13,-17))
        oBtn.m_IgnoreCheckEffect = false
    else
        oBtn:DelEffect("RedDot")
    end
end

function CGaideMainView.RegisterSysEffs(self)
    local oGrid = self.m_BtnGrid
    self:RefreshGrowBtn()
    g_SysUIEffCtrl:TryAddEff("GROW", oGrid:GetChild(3))
    g_SysUIEffCtrl:DelSysEff("ZHIYIN")
end

return CGaideMainView

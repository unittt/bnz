local COrgInfoView = class("COrgInfoView", CViewBase)

function COrgInfoView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/OrgInfoView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function COrgInfoView.OnCreateView(self)
    self.m_CloseBtn        = self:NewUI(1, CButton)
    self.m_TitleSprite     = self:NewUI(2, CSprite)
    self.m_InfoPart        = self:NewPage(3, COrgInfoPart)
    self.m_MemberPart      = self:NewPage(4, COrgMemberPart)
    self.m_BuildingPart    = self:NewPage(5, COrgBuildingPart)
    self.m_WelfarePart     = self:NewPage(6, COrgWelfarePart)
    self.m_InfoRedPoint    = self:NewUI(7, CSprite)
    self.m_MemberRedPoint  = self:NewUI(8, CSprite)
    self.m_BtnGrid         = self:NewUI(9, CTabGrid)
    
    self.m_TitleSprList = {
        [1] = "h7_org_info",
        [2] = "h7_org_member",
        [3] = "h7_bangpaijianzhu",
        [4] = "h7_bangpaifuli",
    }
    self:InitContent()
end

function COrgInfoView.InitContent(self)
    self.m_BtnGrid:InitChild(function(obj, idx)
        local oBtn = CButton.New(obj)
        oBtn:SetGroup(self:GetInstanceID())
        return oBtn
    end)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

    for i, oTab in ipairs(self.m_BtnGrid:GetChildList()) do
        if i == 1 then
            oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i, COrgCtrl.GET_ORG_MAIN_INFO_SIMPLE))
        else 
            oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i))
        end
    end
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
    self:ShowSubPageByIndex(1, COrgCtrl.GET_ORG_MAIN_INFO_COMPLETE)
    self.m_MemberPart:RefreshJoinApplyRedPoint()
    self:CheckOrgRedPoint()
end

function COrgInfoView.ShowSubPageByIndex(self, iIndex, ...)
    local oTab = self.m_BtnGrid:GetChild(iIndex)
    oTab:SetSelected(true)
    self.m_TitleSprite:SetSpriteName(self.m_TitleSprList[iIndex])
    CGameObjContainer.ShowSubPageByIndex(self, iIndex, ...)
    if iIndex == 1 then
        local flag = select(1, ...)
        self.m_InfoPart:GetMainInfo(flag)
    elseif iIndex == 2 then
        -- netorg.C2GSOrgApplyJoinList()
    elseif iIndex == 4 then
        g_OrgCtrl:C2GSGetBoonInfo() --获取福利信息
    end
end

function COrgInfoView.OnOrgEvent(self, callbackBase)
    local eventID = callbackBase.m_EventID
    if eventID == define.Org.Event.GetOrgMainInfo then
        self.m_InfoPart:RefreshSelfRecommendRedPoint()
    elseif eventID == define.Org.Event.UpdateOrgRedPoint then
        self.m_MemberPart:RefreshJoinApplyRedPoint()
        self:CheckOrgRedPoint()
    end
end

function COrgInfoView.ShowRPanel(self)
    self.m_BtnGrid:SetActive(true)
end

function COrgInfoView.CloseRPanel(self)
    self.m_BtnGrid:SetActive(false)
end

function COrgInfoView.CheckOrgRedPoint(self)
    local bIsNotSign = g_OrgCtrl.m_LoginOrgRedPontInfo.sign_status == 0
    local bIsNotBonus = g_OrgCtrl.m_LoginOrgRedPontInfo.bonus_status == 1
    local bIsNotPos = g_OrgCtrl.m_LoginOrgRedPontInfo.pos_status == 1
    local bIsShopNotify = g_OrgCtrl.m_LoginOrgRedPontInfo.shop_status == 1

    local showRedPoint = bIsNotSign or bIsNotPos or bIsNotBonus
    if g_RedPacketCtrl.m_ShowOrgRedPoint or showRedPoint then
        self.m_BtnGrid:GetChild(4).m_IgnoreCheckEffect = true
        self.m_BtnGrid:GetChild(4):AddEffect("RedDot", 20, Vector2(-13, -17))
    else
        self.m_BtnGrid:GetChild(4):DelEffect("RedDot")
    end

    if bIsShopNotify then
        self.m_BtnGrid:GetChild(3).m_IgnoreCheckEffect = true
        self.m_BtnGrid:GetChild(3):AddEffect("RedDot", 20, Vector2(-13, -17))
    else
        self.m_BtnGrid:GetChild(3):DelEffect("RedDot")
    end
end

return COrgInfoView
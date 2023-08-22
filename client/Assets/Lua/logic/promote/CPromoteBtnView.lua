local CPromoteBtnView = class("CPromoteBtnView", CViewBase)


function CPromoteBtnView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Promote/PromoteBtnView.prefab", cb)
    self.m_ExtendClose = "ClickOut"
    
    
end

function CPromoteBtnView.OnCreateView(self)
    self.m_BtnGrid = self:NewUI(1, CGrid)
    self.m_BtnPromote = self:NewUI(2, CBox)
    self.m_BgSp = self:NewUI(3, CSprite)

    self:InitContent()
    
    local oView = CMainMenuView:GetView()
    if oView then
        UITools.NearTarget(oView.m_LT.m_PromoteBtn, self.m_BgSp, enum.UIAnchor.Side.Bottom, Vector2.New(0, -20))
    end
end

function CPromoteBtnView.InitContent(self)
    self.m_BtnPromote:SetActive(false)

    self:SetPromoteList()

    g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPromoteEvent"))
end

function CPromoteBtnView.OnPromoteEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Promote.Event.UpdatePromoteData then
        if not next(g_PromoteCtrl.m_PromoteList) then
            self:CloseView()
        else
            self:SetPromoteList()
        end
    end
end

function CPromoteBtnView.SetPromoteList(self)
    local optionCount = #g_PromoteCtrl.m_PromoteList
    local GridList = self.m_BtnGrid:GetChildList() or {}
    local oPromoteBox
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oPromoteBox = self.m_BtnPromote:Clone(false)
                -- self.m_BtnGrid:AddChild(oOptionBtn)
            else
                oPromoteBox = GridList[i]
            end
            self:SetPromoteBox(oPromoteBox, g_PromoteCtrl.m_PromoteList[i])
        end

        if #GridList > optionCount then
            for i=optionCount+1,#GridList do
                GridList[i]:SetActive(false)
            end
        end
    else
        if GridList and #GridList > 0 then
            for _,v in ipairs(GridList) do
                v:SetActive(false)
            end
        end
    end

    self.m_BtnGrid:Reposition()

    self.m_BgSp:SetHeight(60*#g_PromoteCtrl.m_PromoteList + 23)
    -- self.m_ScrollView:ResetPosition()
end

function CPromoteBtnView.SetPromoteBox(self, oPromoteBox, oData)
    oPromoteBox:SetActive(true)

    oPromoteBox.m_NameLbl = oPromoteBox:NewUI(1, CLabel)
    oPromoteBox.m_CloseBtn = oPromoteBox:NewUI(2, CButton)
    oPromoteBox.m_PromoteBtn = oPromoteBox:NewUI(3, CButton)
    oPromoteBox.m_IconSp = oPromoteBox:NewUI(4, CSprite)
    oPromoteBox.m_NameLbl:SetText(oData.name)
    oPromoteBox.m_IconSp:SetSpriteName(oData.icon) 
    oPromoteBox.m_IconSp:MakePixelPerfect()
    oPromoteBox.m_PromoteBtn:AddUIEvent("click", callback(self, "OnPromote", oData))
    if oData.sysId == "SKILL_BD" then
        g_GuideCtrl:AddGuideUI("promote_skill_btn", oPromoteBox.m_PromoteBtn)
    elseif oData.sysId == "SKILL_ZD" then
        g_GuideCtrl:AddGuideUI("promote_skill_active_btn", oPromoteBox.m_PromoteBtn)
    end
    oPromoteBox.m_CloseBtn:AddUIEvent("click", callback(self, "OnCloseEvent", oPromoteBox, oData.sysId)) 

    self.m_BtnGrid:AddChild(oPromoteBox)
    self.m_BtnGrid:Reposition()
end

function CPromoteBtnView.OnCloseEvent(self, obj, sysId)
    g_PromoteCtrl:DelSys(sysId)
end

--跳转到对应升级
function CPromoteBtnView.OnPromote(self, tSys)
    tSys.isRedPoint = false
    --printc("-----跳转到升级---")
    if tSys.sysId == "SKILL_ZD" then
        CSkillMainView:ShowView(function (oView)
            oView.m_SchoolPart:SetCurSkillByCouldUp()
            oView:ShowSubPageByIndex(oView:GetPageIndex("School"))
            oView.m_SchoolPart:PreSelect()
        end)
    end
    if tSys.sysId == "SKILL_BD" then
        CSkillMainView:ShowView(function (oView)
            oView.m_PassivePart:SetCurSkillByCouldUp()
            oView:ShowSubPageByIndex(oView:GetPageIndex("Passive"))
            oView.m_PassivePart:SetCurIndexSelect()
        end)
    end
    if tSys.sysId == "ROLE_ADDPOINT" then
        CAttrMainView:ShowView(function (oView)
            oView:ShowSubPageByIndex(oView:GetPageIndex("Point"))
        end)
    end
    if tSys.sysId == "SUMMON_SYS" then
        local isSummon, summonId = g_PromoteCtrl:JudgeSummon()
        g_SummonCtrl.m_CurSelSummonId = summonId
        g_SummonCtrl:ShowWashPointView()
    end
    if tSys.sysId == "FMT_SYS" then
        CFormationMainView:ShowView(function (oView)
            oView:JumpToTargetFormation(g_PromoteCtrl.m_PromoteFmtid or 1)
        end)
    end
    if tSys.sysId == "FMT_LEARN" then
        CFormationMainView:ShowView(function (oView)
            oView:JumpToTargetFormation(g_PromoteCtrl.m_PromoteLearnFmtid or 1)
        end)
    end
    if tSys.sysId == "ENERGY" then
        CAttrSkillQuickMakeView:ShowView()
        g_PromoteCtrl:DelSys("ENERGY")
        g_PromoteCtrl:OnEvent(define.Promote.Event.UpdatePromoteData)
    end
    if tSys.sysId == "EQUIP_QH" then
        CForgeMainView:ShowView(function(oView)
            oView:ShowSubPageByIndex(oView:GetPageIndex("Strengthen"))
        end)
    end
    if tSys.sysId == "PARTNER_ZM" then
        CPartnerMainView:ShowView(function(oView)
            oView:ResetCloseBtn()
            oView:ShowSubPageByIndex(oView:GetPageIndex("Recruit"))
            local oFirst = g_PartnerCtrl:GetFirstCouldZMPartner()
            if oFirst then
                oView:SetSpecificPartnerIDNode(oFirst.id)
            end
        end)
    end
    if tSys.sysId == "PARTNER_JJ" then
        CPartnerMainView:ShowView(function(oView)
            oView:ResetCloseBtn()
            oView:ShowSubPageByIndex(oView:GetPageIndex("Recruit"))
            local oFirst = g_PartnerCtrl:GetFirstCouldUpgradePartner()
            if oFirst then
                oView:SetSpecificPartnerIDNode(oFirst.sid)
            end
        end)
    end
    if tSys.sysId == "SUMMON_NEW" then
        g_SummonCtrl:ShowPropertyView()
        g_PromoteCtrl:DelSys("SUMMON_NEW")
        g_PromoteCtrl:OnEvent(define.Promote.Event.UpdatePromoteData)
    end
    if tSys.sysId == "XIU_LIAN_SYS" then
        CSkillMainView:ShowView(function (oView)
            local part = oView:GetCultivatePart()
            part:SetDefaultIndex(g_SkillCtrl:GetIsCultivateCouldUp())
            oView:ShowSubPageByIndex(oView:GetPageIndex("Cultivation"))
        end)
    end
    if tSys.sysId == "BAOSHIDU" then
        CBaoshiduView:ShowView()
    end
    g_PromoteCtrl:OnEvent(define.Promote.Event.RedPoint)
    self:CloseView()
end

return CPromoteBtnView
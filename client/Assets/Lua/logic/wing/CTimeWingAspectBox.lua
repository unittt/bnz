local CTimeWingAspectBox = class("CTimeWingAspectBox", CBox)

function CTimeWingAspectBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_NameL = self:NewUI(1, CLabel)
    self.m_LeftTimeL = self:NewUI(2, CLabel)
    self.m_AddTimeBtn = self:NewUI(3, CButton)
    self.m_OperaBtn = self:NewUI(4, CButton)
    self.m_GetwayBtn = self:NewUI(5, CButton)
    self.m_EquipedSpr = self:NewUI(6, CSprite)
    self.m_AttrBgSpr = self:NewUI(7, CSprite)
    self.m_EffAttrBox = self:NewUI(8, CWingEffectAttrBox)
    self.m_TryBtn = self:NewUI(9, CButton)
    self.m_WingTex = self:NewUI(10, CActorTexture)
    self.m_UnActiveL = self:NewUI(11, CLabel)
    self.m_AttrScrollView = self:NewUI(12, CScrollView)
    self:InitContent()
end

function CTimeWingAspectBox.InitContent(self)
    self.m_Id = 0
    self.m_ActiveCost = nil
    self.m_EffectId = 0
    self.m_ExpireTime = nil
    self.m_AttrBgHeight = self.m_AttrBgSpr:GetHeight()
    self.m_OperaBtn.m_IgnoreCheckEffect = true

    self.m_AddTimeBtn:AddUIEvent("click", callback(self, "OnClickAddTime"))
    self.m_OperaBtn:AddUIEvent("click", callback(self, "OnClickOperaBtn"))
    self.m_GetwayBtn:AddUIEvent("click", callback(self, "OnClickGetway"))
    self.m_TryBtn:AddUIEvent("click", callback(self, "OnClickTry"))
end

function CTimeWingAspectBox.SetInfo(self, dInfo)
    self.m_Id = dInfo.wing_id
    self.m_ActiveCost = dInfo.active_cost[1]
    local dEff = dInfo.wing_effect[g_AttrCtrl.school]
    self.m_EffectId = dEff and dEff.effect_id or 0
    local iExpireTime = g_WingCtrl:GetTimeWingExpireTime(self.m_Id)
    self.m_ExpireTime = iExpireTime

    local bActive = iExpireTime and true or false
    self.m_LeftTimeL:SetActive(bActive)
    self.m_AddTimeBtn:SetActive(bActive)
    self.m_UnActiveL:SetActive(not bActive)
    self.m_TryBtn:SetActive(not bActive)

    local texSize = (dInfo.tex_size or 0.45) + 0.3
    self.m_WingTex:ChangeShape({
        -- figure = dInfo.figureid,
        show_wing = self.m_Id,
        rendertexSize = texSize,
        pos = Vector3(0,-0.3,3),
        ignoreClick = true,
    })
    local oCam = self.m_WingTex.m_ActorCamera
    if oCam and oCam.m_Actor then
        oCam.m_Actor:SetLocalRotation(Quaternion.identity)
    end

    self.m_NameL:SetText(dInfo.name)
    if iExpireTime then
        if iExpireTime < 0 then
            self.m_LeftTimeL:SetText("永久")
            self.m_AddTimeBtn:SetActive(false)
        else
            local iLeftTime = self:GetLeftTime()
            local iSec = iLeftTime%60
            if iSec <= 2 then
                iLeftTime = iLeftTime - iSec
            end
            if iLeftTime > 0 then
                local sTime = g_TimeCtrl:GetLeftTimeDHM(iLeftTime)
                sTime = string.replace(sTime,"小时","时")
                sTime = string.replace(sTime,"分钟","分")
                self.m_LeftTimeL:SetText(sTime)
            else
                self.m_LeftTimeL:SetText("已过期")
            end
        end
    end
    self:RefreshAttrs()
    self:RefreshWearState()
end

function CTimeWingAspectBox.RefreshAttrs(self)
    local dEff = g_WingCtrl:GetWingEffectInfo(self.m_EffectId)
    local dAttr = string.eval(dEff.wing_effect, {level = 0, star = 0})
    local attrList = g_WingCtrl:GetSortAttrList(dAttr)
    self.m_EffAttrBox:RefreshAttr(attrList)
    local _, iHeight = self.m_EffAttrBox:GetCellSize()
    local iAttrCnt = #attrList
    local iCnt = Mathf.Clamp(iAttrCnt-1,0,1.7)
    self.m_AttrBgSpr:SetHeight(iHeight * iCnt + self.m_AttrBgHeight)
    -- if iAttrCnt > 2 then
    self.m_AttrScrollView:ResetPosition()
    -- else
    --     self.m_AttrScrollView:SetLocalPos(Vector3.zero)
    -- end
end

function CTimeWingAspectBox.RefreshWearState(self)
    local iExpireTime = self.m_ExpireTime
    if iExpireTime then
        local bActive = iExpireTime<0 or self:GetLeftTime()>0
        local bEquiped = g_WingCtrl.m_ShowWing == self.m_Id
        self.m_OperaBtn:DelEffect("RedDot")
        self.m_EquipedSpr:SetActive(bEquiped)
        if bEquiped then
            self.m_OperaBtn:SetText("卸下")
        else
            self.m_OperaBtn:SetText("穿戴")
        end
        self.m_OperaBtn:SetBtnGrey(not bActive)
        self.m_GetwayBtn:SetActive(false)
        self.m_OperaBtn:SetActive(true)
    else
        local iCostCnt = g_ItemCtrl:GetBagItemAmountBySid(self.m_ActiveCost.sid)
        local bCanActive = iCostCnt >= self.m_ActiveCost.amount
        self.m_GetwayBtn:SetActive(not bCanActive)
        self.m_OperaBtn:SetActive(bCanActive)
        if bCanActive then
            self.m_OperaBtn:SetText("激活")
            self.m_OperaBtn:AddEffect("RedDot", 20, Vector2(-15,-15))
        end
        self.m_EquipedSpr:SetActive(false)
    end
end

function CTimeWingAspectBox.GetLeftTime(self)
    local iExpireTime = self.m_ExpireTime
    return iExpireTime and iExpireTime-g_TimeCtrl:GetTimeS() or 0
end

function CTimeWingAspectBox.OnClickAddTime(self)
    g_WingCtrl:ShowWingActiveView(self.m_Id)
end

function CTimeWingAspectBox.OnClickOperaBtn(self)
    if not self.m_ExpireTime then
        if not self.m_ActiveCost then return end
        local iCostCnt = g_ItemCtrl:GetBagItemAmountBySid(self.m_ActiveCost.sid)
        if iCostCnt >= self.m_ActiveCost.amount then
            netwing.C2GSActiveWing(self.m_Id)
        end
    elseif g_WingCtrl.m_ShowWing == self.m_Id then
        netwing.C2GSSetShowWing(0) 
    elseif self.m_ExpireTime < 0 or self:GetLeftTime() > 0 then
        netwing.C2GSSetShowWing(self.m_Id)
    else
        g_NotifyCtrl:FloatMsg("已过期")
    end
end

function CTimeWingAspectBox.OnClickGetway(self)
    if not self.m_ActiveCost then return end
    g_WindowTipCtrl:SetWindowGainItemTip(self.m_ActiveCost.sid)
end

function CTimeWingAspectBox.OnClickTry(self)
    g_WingCtrl:ShowWingTestView(self.m_Id)
end

return CTimeWingAspectBox
local CLevelWingAspectBox = class("CLevelWingAspectBox", CBox)

function CLevelWingAspectBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_NameL = self:NewUI(1, CLabel)
    self.m_OperaBtn = self:NewUI(2, CButton)
    self.m_EquipedSpr = self:NewUI(3, CSprite)
    self.m_AttrBgSpr = self:NewUI(4, CSprite)
    self.m_EffAttrBox = self:NewUI(5, CWingEffectAttrBox)
    self.m_TryBtn = self:NewUI(6, CButton)
    self.m_WingTex = self:NewUI(7, CActorTexture)
    self.m_UnActiveL = self:NewUI(8, CLabel)
    self.m_LevelL = self:NewUI(9, CLabel)
    self.m_AttrScrollView = self:NewUI(10, CScrollView)
    self:InitContent()
end

function CLevelWingAspectBox.InitContent(self)
    self.m_Lv = 0
    self.m_Id = 0
    self.m_AttrBgHeight = self.m_AttrBgSpr:GetHeight()

    self.m_OperaBtn:AddUIEvent("click", callback(self, "OnClickOperaBtn"))
    self.m_TryBtn:AddUIEvent("click", callback(self, "OnClickTry"))
end

function CLevelWingAspectBox.SetInfo(self, dInfo)
    self.m_Lv = dInfo.level
    self.m_Id = dInfo.wing
    local dConfig = g_WingCtrl:GetWingConfig(self.m_Id)
    if not dConfig then return end

    local sName = dConfig.name
    -- if self.m_Lv > 0 then
    --     sName = string.format("%s*%s阶", sName, string.printInChinese(self.m_Lv))
    -- end
    self.m_NameL:SetText(sName)

    local texSize = (dConfig.tex_size or 0.45) + 0.25
    self.m_WingTex:ChangeShape({
        -- figure = dConfig.figureid,
        show_wing = self.m_Id,
        rendertexSize = texSize,
        pos = Vector3(0,-0.2,3),
        ignoreClick = true,
    })
    local oCam = self.m_WingTex.m_ActorCamera
    if oCam and oCam.m_Actor then
        oCam.m_Actor:SetLocalRotation(Quaternion.identity)
    end

    self:RefreshAttrs()
    self:RefreshWearState()
end

function CLevelWingAspectBox.RefreshAttrs(self)
    local attrList = g_WingCtrl:GetStateEffectAttrs(self.m_Lv, 0)
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

function CLevelWingAspectBox.RefreshWearState(self)
    local bActive = self.m_Lv <= g_WingCtrl.level
    self.m_OperaBtn:SetActive(bActive)
    self.m_TryBtn:SetActive(not bActive)
    self.m_UnActiveL:SetActive(not bActive)
    self.m_LevelL:SetActive(not bActive)
    if bActive then
        local bEquiped = g_WingCtrl.m_ShowWing == self.m_Id
        self.m_EquipedSpr:SetActive(bEquiped)
        local sBtnStr = bEquiped and "卸下" or "穿戴"
        self.m_OperaBtn:SetText(sBtnStr)
    else
        self.m_LevelL:SetText(string.format("进阶至%d阶获得", self.m_Lv))
        self.m_EquipedSpr:SetActive(false)
    end
end

function CLevelWingAspectBox.OnClickOperaBtn(self)
    if not g_WingCtrl:HasActiveWing() then
        if g_WingCtrl:IsCanActive() then
            g_NotifyCtrl:FloatMsg("请先激活羽翼")
            local oView = CWingMainView:GetView()
            if oView then
                oView:ShowSubPageByIndex(1)
            end
        else
            g_WingCtrl:WingFloatMsg(6001)
            CFuncNotifyMainView:ShowView(function (oView)
                oView:RefreshUI(g_GuideHelpCtrl.m_WingGuideId)
            end)
        end
        return
    end
    if g_WingCtrl.m_ShowWing == self.m_Id then
        netwing.C2GSSetShowWing(0)
    else
        netwing.C2GSSetShowWing(self.m_Id)
    end
end

function CLevelWingAspectBox.OnClickTry(self)
    g_WingCtrl:ShowWingTestView(self.m_Id)
end

return CLevelWingAspectBox
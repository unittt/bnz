local CSummonViewEquipBox = class("CSummonViewEquipBox", CBox)

function CSummonViewEquipBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_BoxDict = {}
    self:InitContent()
end

function CSummonViewEquipBox.InitContent(self)
    self.m_LaceBox = self:NewUI(1, CBox)
    self.m_ArmBox = self:NewUI(3, CBox)
    self.m_SignBox = self:NewUI(2, CBox)
    self:InitBox(self.m_LaceBox, define.Summon.Equip.Lace)
    self:InitBox(self.m_SignBox, define.Summon.Equip.Sign)
    self:InitBox(self.m_ArmBox, define.Summon.Equip.Arm)
end

function CSummonViewEquipBox.InitBox(self, oBox, iType)
    oBox.iconSpr = oBox:NewUI(1, CSprite)
    oBox.qualitySpr = oBox:NewUI(2, CSprite)
    oBox.bgSpr = oBox:NewUI(3, CSprite)
    if iType == define.Summon.Equip.Lace then
        oBox.bgSpr:SetSpriteName("h7_shoushi")
    end
    oBox.iconSpr:SetActive(false)
    oBox.qualitySpr:SetActive(false)
    oBox.equipType = iType
    self.m_BoxDict[iType] = oBox
    oBox:AddUIEvent("click", callback(self, "OnClickEquip", oBox))
end

function CSummonViewEquipBox.SetInfo(self, dSummon, bOpera)
    local dEquiped = SummonDataTool.GetEquipedData(dSummon)
    self.m_SummonInfo = dSummon
    self.m_CanOpera = bOpera
    if dEquiped then
        for k, oBox in ipairs(self.m_BoxDict) do
            local oItem = dEquiped[k]
            self:RefreshBox(oBox, oItem)
        end
    end
end

function CSummonViewEquipBox.RefreshBox(self, oBox, oItem)
    local bNotEmpty = oItem and true or false
    oBox.iconSpr:SetActive(bNotEmpty)
    oBox.qualitySpr:SetActive(bNotEmpty)
    oBox.bgSpr:SetActive(not bNotEmpty)
    oBox.isInit = true
    oBox.info = oItem
    if oItem then
        oBox.iconSpr:SpriteItemShape(oItem:GetCValueByKey("icon"))
        oBox.qualitySpr:SetItemQuality(oItem:GetQuality())
    end
end

function CSummonViewEquipBox.ShowEquipSelView(self, iPos)
    local dSummon = self.m_SummonInfo
    if dSummon.grade < 20 then
        g_NotifyCtrl:FloatMsg("20级以上的宠物才能使用宠物装备")
        return
    end
    CSummonEquipSelView:ShowView(function(oView)
        oView:SetData(iPos)
    end)
end

function CSummonViewEquipBox.ShowEquipTip(self, oItem, oWidget)
    local bHideBtn = not self.m_CanOpera
    local iDist = bHideBtn and 10 or 40
    CItemTipsView:ShowView(function(oView)
        oView:OpenSummonEquipView(oItem, nil, nil, 1)
        if bHideBtn then
            oView:HideBtns()
        end
        UITools.NearTarget(oWidget, oView.m_SummonEquipBox.m_BgSpr, enum.UIAnchor.Side.Top, Vector3.New(0, iDist, 0))
    end)
end

function CSummonViewEquipBox.RefreshRedDot(self)
    local iGrade = self.m_SummonInfo and self.m_SummonInfo.grade
    local bRed = false
    for pos, oBox in ipairs(self.m_BoxDict) do
        bRed = false
        if not oBox.info and iGrade then
            local items = SummonDataTool.GetBagSummonEquips(pos, iGrade)
            if #items > 0 then
                bRed = true
            end
        end
        if bRed then
            oBox.m_IgnoreCheckEffect = true
            oBox:AddEffect("RedDot", 20, Vector2(-19, -17))
        else
            oBox:DelEffect("RedDot")
        end
    end
end

function CSummonViewEquipBox.OnClickEquip(self, oBox)
    if not oBox.isInit then
        return
    end
    local oItem = oBox.info
    if oItem then
        self:ShowEquipTip(oItem, oBox.iconSpr)
    elseif self.m_CanOpera then
        self:ShowEquipSelView(oBox.equipType)
    end
end

return CSummonViewEquipBox
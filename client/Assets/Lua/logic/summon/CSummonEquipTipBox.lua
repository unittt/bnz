local CSummonEquipTipBox = class("CSummonEquipTipBox", CBox)

function CSummonEquipTipBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_BgSpr = self:NewUI(1, CSprite)
    self.m_TopPart = self:NewUI(2, CBox)
    self.m_MidPart = self:NewUI(3, CBox)
    self.m_BtnPart = self:NewUI(4, CBox)

    self:InitTopPart()
    self:InitMidPart()
    self:InitBtnPart()
end

function CSummonEquipTipBox.InitTopPart(self)
    local oBox = self.m_TopPart
    oBox.nameL = oBox:NewUI(1, CLabel)
    oBox.iconSpr = oBox:NewUI(2, CSprite)
    oBox.lvL = oBox:NewUI(3, CLabel)
    oBox.typeL = oBox:NewUI(4, CLabel)
    oBox.qualitySpr = oBox:NewUI(5, CSprite)
    oBox.typeTitleL = oBox:NewUI(6, CLabel)
    oBox.bindSpr = oBox:NewUI(7, CSprite)
    -- oBox.typeTitleL:SetText("#G类型:")
end

function CSummonEquipTipBox.InitMidPart(self)
    local oBox = self.m_MidPart
    oBox.skGrid = oBox:NewUI(1, CGrid)
    oBox.descL = oBox:NewUI(2, CLabel)
    oBox.skBox = oBox:NewUI(3, CBox)
    oBox.attrGrid = oBox:NewUI(4, CGrid)
    oBox.attrBox = oBox:NewUI(5, CBox)
    
    oBox.attrBox:SetActive(false)
    oBox.skBox:SetActive(false)
end

function CSummonEquipTipBox.InitBtnPart(self)
    local oBox = self.m_BtnPart
    oBox.lBtn = oBox:NewUI(1, CButton)
    oBox.rBtn = oBox:NewUI(2, CButton)
    oBox.hideBtnGrid = oBox:NewUI(3, CGrid)
    oBox.washBtn = oBox:NewUI(4, CButton)
    oBox.mBtn = oBox:NewUI(5, CButton)
    oBox.moreSpr = oBox:NewUI(6, CSprite)
    oBox.resetBtn = oBox:NewUI(7, CButton)
    oBox.composeBtn = oBox:NewUI(8, CButton)
    oBox.lBtn:SetText("更多")
    oBox.washBtn:SetText("炼化")
    oBox.resetBtn:SetText("重置")
    oBox.composeBtn:SetText("合成")
    oBox.lBtn:AddUIEvent("click", callback(self, "OnClickLBtn"))
    oBox.rBtn:AddUIEvent("click", callback(self, "OnClickRBtn"))
    oBox.washBtn:AddUIEvent("click", callback(self, "OnClickWash"))
    oBox.resetBtn:AddUIEvent("click", callback(self, "OnClickReset"))
    oBox.composeBtn:AddUIEvent("click", callback(self, "OnClickCompose"))
end

-- btnType: 0 or nil:跳转  1:更换  2:装备
function CSummonEquipTipBox.SetInitBox(self, oItem, iBtnType)
    self.m_ClickedLBtn = false
    self.m_ItemObj = oItem
    self.m_SummonId = g_SummonCtrl:GetCurSelSummon()
    self.m_BtnType = self.m_BtnType or (iBtnType or 0)
    self:SetTopData(oItem)
    self:SetMidData(oItem)
    self:RefreshBtnPart()
    self:CalcWidgetPos(false)
    if not self.m_SetPos then
        self:SetLocalPos(Vector3.New(-235, 184, 0))
    else
        self.m_SetPos = false
    end
    self.m_InitBtn = false
end

function CSummonEquipTipBox.TempBag(self, oItem)
    self:ShowBtnModeSwitch(false, "取回物品")
    self.m_InitBtn = true
    self.m_BtnPart.mBtn:AddUIEvent("click", callback(self, "OnClickGetItem"))
    self:SetLocalPos(Vector3.New(217, 0, 0))
    self.m_SetPos = true
    self:SetInitBox(oItem)
end

function CSummonEquipTipBox.SetTopData(self)
    local oItem = self.m_ItemObj
    local oBox = self.m_TopPart
    oBox.nameL:SetText(oItem:GetItemName())
    oBox.iconSpr:SpriteItemShape(oItem:GetCValueByKey("icon"))
    local iLv = oItem:GetSValueByKey("itemlevel")
    -- oBox.lvL:SetText(iLv)
    local dName = {
        [1] = "项圈",
        [3] = "护符",
        [2] = "铠甲",
    }
    local sName = dName[oItem:GetCValueByKey("equippos")]
    oBox.typeL:SetText(sName)
    oBox.qualitySpr:SetItemQuality(oItem:GetQuality())
    oBox.bindSpr:SetActive(oItem:IsBinding())
end

function CSummonEquipTipBox.SetMidData(self)
    local oItem = self.m_ItemObj
    local oBox = self.m_MidPart
    local iPos = oItem:GetCValueByKey("equippos")
    if self:IsAttrEmpty() then
        oBox.skGrid:SetActive(false)
        oBox.attrGrid:SetActive(false)
    else
        local bSign = iPos == define.Summon.Equip.Sign
        oBox.skGrid:SetActive(bSign)
        oBox.attrGrid:SetActive(not bSign)
        self.m_ShowSkill = bSign
        local dEquip = oItem:GetSValueByKey("equip_info")
        if bSign then
            self:SetSkillInfo(dEquip.skills)
        else
            self:SetAttrInfo(dEquip.attach_attr)
        end
    end
    oBox.descL:SetRichText(oItem:GetCValueByKey("description"), nil, nil, true)
end

function CSummonEquipTipBox.SetSkillInfo(self, skills)
    if not skills then
        return
    end
    local oBox = self.m_MidPart
    local oGrid = oBox.skGrid
    local oSkBox = oBox.skBox
    oGrid:HideAllChilds()
    for i, v in ipairs(skills) do
        local dConfig = SummonDataTool.GetSummonSkillInfo(v.sk)
        if dConfig then
            local oSk = oGrid:GetChild(i)
            if not oSk then
                oSk = oSkBox:Clone()
                oSk.nameL = oSk:NewUI(1, CLabel)
                oSk.iconSpr = oSk:NewUI(2, CSprite)
                oSk:AddUIEvent("click", callback(self, "OnClickSkill"))
                oGrid:AddChild(oSk)
            end
            oSk:SetActive(true)
            oSk.skId = v.sk
            oSk.nameL:SetRichText(string.format("#G%s", dConfig.name), nil, nil, true)
            oSk.iconSpr:SpriteSkill(dConfig.iconlv[1].icon)
        end
    end
end

function CSummonEquipTipBox.SetAttrInfo(self, attrs)
    if not attrs then
        return
    end
    local oBox = self.m_MidPart
    local oGrid = oBox.attrGrid
    local oAttrBox = oBox.attrBox
    local dAttrName = data.attrnamedata.DATA
    oGrid:HideAllChilds()
    for i, v in ipairs(attrs) do
        local oAttr = oGrid:GetChild(i)
        if not oAttr then
            oAttr = oAttrBox:Clone()
            oAttr.nameL = oAttr:NewUI(1, CLabel)
            oAttr.valL = oAttr:NewUI(2, CLabel)
            oGrid:AddChild(oAttr)
        end
        oAttr:SetActive(true)
        oAttr.nameL:SetRichText("#G"..dAttrName[v.key].name, nil, nil, true)
        oAttr.valL:SetRichText("#G+"..v.value, nil, nil, true)
    end
end

---------------- btn ----------------
function CSummonEquipTipBox.RefreshBtnPart(self)
    self:ShowMoreBtnSwitch()
    self.m_BtnPart:SetActive(true)
    if self.m_InitBtn then return end
    local iBtnType = self.m_BtnType
    local bTwo = 1~=iBtnType
    local sText
    if bTwo then
        sText = "装备"
    else
        sText = "更换"
        self.m_BtnPart.mBtn:AddUIEvent("click", callback(self, "OnClickChange"))
    end
    self:ShowBtnModeSwitch(bTwo, sText)
end

function CSummonEquipTipBox.ShowBtnModeSwitch(self, bTwo, sText)
    local oBox = self.m_BtnPart
    oBox.lBtn:SetActive(bTwo)
    oBox.rBtn:SetActive(bTwo)
    oBox.mBtn:SetActive(not bTwo)
    if bTwo then
        oBox.rBtn:SetText(sText)
        oBox.resetBtn:SetActive(self.m_ShowSkill and true or false)
        oBox.hideBtnGrid:Reposition()
    else
        oBox.mBtn:SetText(sText)
    end
end

function CSummonEquipTipBox.ShowMoreBtnSwitch(self)
    local oBox = self.m_BtnPart
    local bShow = self.m_ClickedLBtn and true or false
    oBox.hideBtnGrid:SetActive(bShow)
    if bShow then
        oBox.moreSpr:SetFlip(enum.UIBasicSprite.Vertically)
    else
        oBox.moreSpr:SetFlip(enum.UIBasicSprite.Nothing)
    end
end

function CSummonEquipTipBox.HideButton(self)
    self.m_BtnPart:SetActive(false)
    self:CalcWidgetPos(true)
end

-- 背包存入仓库
function CSummonEquipTipBox.BagPutInStore(self ,oItem ,hitExtend)
    if hitExtend then
        self.m_InitBtn = true
        self:ShowBtnModeSwitch(false, "存入仓库")
        self.m_BtnPart.mBtn:AddUIEvent("click", callback(self, "OnClickPutInStore"))
    end
end
   
--仓库取回背包
function CSummonEquipTipBox.WHPutInBackBox(self ,oItem, hitExtend)
    if hitExtend then
        self.m_InitBtn = true
        self:ShowBtnModeSwitch(false, "取回包裹")
        self.m_BtnPart.mBtn:AddUIEvent("click", callback(self, "OnClickPutInBackBox"))
    end
end

function CSummonEquipTipBox.ShowGainWayBtn(self)
    self:ShowBtnModeSwitch(false, "获得途径")
    self.m_BtnPart.mBtn:AddUIEvent("click", callback(self, "OnGainWayBtnCB"))
end

--------------- 设置组件位置 ---------------------
function CSummonEquipTipBox.CalcWidgetPos(self, bHideBtn)
    local oBox = self.m_MidPart
    local desLPos = oBox.descL:GetLocalPos()
    local iPosY = oBox.skGrid:GetLocalPos().y
    if not self:IsAttrEmpty() then
        local oGrid = self.m_ShowSkill and oBox.skGrid or oBox.attrGrid
        local _, h = oGrid:GetCellSize()
        h = h * oGrid:GetCount()
        iPosY = iPosY - h
    end
    desLPos.y = iPosY
    oBox.descL:SetLocalPos(desLPos)
    iPosY = iPosY - oBox.descL.m_UIWidget.height
    self.m_BtnPart:SetLocalPos(Vector3.New(0, iPosY, 0))
    local iBgH = math.abs(iPosY) + 30
    if not bHideBtn then
        iBgH = iBgH + self.m_BtnPart.m_UIWidget.height
    end
    local iBgW = self.m_BgSpr:GetSize()
    self.m_BgSpr:SetSize(iBgW, iBgH)
end

function CSummonEquipTipBox.ShowEquipComfirm(self, dSummon)
    local sDesc
    if self.m_Equiped then
        local sItemName = self.m_ItemObj:GetItemName()
        sDesc = SummonDataTool.GetText(2024)
        sDesc = string.format(sDesc, dSummon.name, sItemName)
    else
        sDesc = SummonDataTool.GetText(2023)
    end
    local itemId = self.m_ItemObj.m_ID
    local iSummon = self.m_SummonId
    local windowConfirmInfo = {
        msg = sDesc,
        title = "提示",
        okCallback = function()
            netsummon.C2GSEquipSummon(iSummon, itemId, 0)
        end
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSummonEquipTipBox.IsAttrEmpty(self)
    local bEmpty = false
    if self.m_ItemObj then
        if self.m_ItemObj.m_ID == self.m_ItemObj.m_SID then
            bEmpty = true
        end
    else
        bEmpty = true
    end
    return bEmpty
end

function CSummonEquipTipBox.OnClickLBtn(self)
    self.m_ClickedLBtn = not self.m_ClickedLBtn
    self:ShowMoreBtnSwitch()
end

function CSummonEquipTipBox.OnClickRBtn(self)
    if 0 == self.m_BtnType then
        CSummonMainView:ShowView()
    elseif 2 == self.m_BtnType then
        local dSummon = g_SummonCtrl:GetSummon(self.m_SummonId)
        self:ShowEquipComfirm(dSummon)
    end
    CItemTipsView:CloseView()
end

function CSummonEquipTipBox.OnClickCompose(self)
    CSummonEquipEditView:ShowView()
    CItemTipsView:CloseView()
end

function CSummonEquipTipBox.OnClickReset(self)
    CSummonEquipEditView:ShowView(function(oView)
        oView:ShowResetPage(self.m_ItemObj.m_ID)
    end)
    CItemTipsView:CloseView()
end

function CSummonEquipTipBox.OnClickWash(self)
    CItemBatchRefineView:ShowView(function(oView)
        oView:SetSelectedItem(self.m_ItemObj.m_ID)
    end)
    CItemTipsView:CloseView()
end

------------------- mid btn ------------
function CSummonEquipTipBox.OnClickChange(self)
    local dSummon = g_SummonCtrl:GetSummon(self.m_SummonId)
    local iGrade = dSummon.grade
    local iPos = self.m_ItemObj:GetCValueByKey("equippos")
    CSummonEquipSelView:ShowView(function(oView)
        oView:SetData(iPos, true)
    end)
    CItemTipsView:CloseView()
end

function CSummonEquipTipBox.OnClickPutInStore(self)
    g_ItemCtrl.C2GSWareHouseWithStore(g_ItemCtrl.m_RecordWHIndex, self.m_ItemObj.m_ID)
    CItemTipsView:CloseView()
end

function CSummonEquipTipBox.OnClickPutInBackBox(self)
    local oItem = self.m_ItemObj
    g_ItemCtrl.C2GSWareHouseWithDraw(g_ItemCtrl.m_RecordWHIndex, oItem:GetSValueByKey("pos"))
    CItemTipsView:CloseView()
end

function CSummonEquipTipBox.OnGainWayBtnCB(self)
    local oView = CItemTipsView:GetView()
    if oView then
        oView:OpenGainWayView()
    end
end

function CSummonEquipTipBox.OnClickGetItem(self)
    g_ItemTempBagCtrl:C2GSTranToItemBag(self.m_ItemObj.m_ID)
    CItemTipsView:CloseView()
end

function CSummonEquipTipBox.OnClickSkill(self, oBox)
    if oBox and oBox.skId then
        g_WindowTipCtrl:SetSummonEquipSkillTipInfo(oBox.skId, {
            widget = oBox,
            side = enum.UIAnchor.Side.Right,
        })
    end
end

return CSummonEquipTipBox
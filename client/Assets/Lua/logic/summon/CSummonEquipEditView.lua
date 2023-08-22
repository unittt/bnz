local CSummonEquipEditView = class("CSummonEquipEditView", CViewBase)

function CSummonEquipEditView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Summon/SummonEquipEditView.prefab", cb)
    self.m_SelPage = nil
    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "Black"
end

function CSummonEquipEditView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_TipBtn = self:NewUI(2, CButton)
    self.m_ComfirmBtn = self:NewUI(3, CButton)
    self.m_ComposeBtn = self:NewUI(4, CButton)
    self.m_ResetBtn = self:NewUI(5, CButton)
    self.m_BagItemsPart = self:NewUI(6, CSummonEquipBagPart)
    self.m_ComposePart = self:NewUI(7, CSummonEquipComposeBox)
    self.m_TargetItemBox = self:NewUI(8, CBox)
    self.m_ResetPart = self:NewUI(9, CSummonEquipResetBox)
    self.m_TabGrid = self:NewUI(10, CGrid)
    self:InitContent()
    self.m_ComposeBtn:SetSelected(true)
    self:OnClickPage(1)
end

function CSummonEquipEditView.InitContent(self)
    self:InitBtns()
    self:InitTargetItemBox()
    self.m_BagItemsPart.parentView = self
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSummonCtrlEvent"))
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end

function CSummonEquipEditView.InitBtns(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTip"))
    self.m_ComfirmBtn:AddUIEvent("click", callback(self, "OnClickComfirm"))
    self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnClickPage", 1))
    self.m_ResetBtn:AddUIEvent("click", callback(self, "OnClickPage", 2))
    self.m_ComposeBtn:SetGroup(self.m_TabGrid:GetInstanceID())
    self.m_ResetBtn:SetGroup(self.m_TabGrid:GetInstanceID())
end

function CSummonEquipEditView.InitTargetItemBox(self)
    local oBox = self.m_TargetItemBox
    oBox.iconSpr = oBox:NewUI(1, CSprite)
    oBox.nameL = oBox:NewUI(2, CLabel)
    oBox.iconSpr:SetSpriteName("")
    oBox.nameL:SetText("")
end

function CSummonEquipEditView.RefreshTargetItem(self, oItem)
    local oBox = self.m_TargetItemBox
    local itemId = oItem and oItem.m_SID
    local bShow = oItem and true or false
    if oBox.itemId == itemId then
        return
    end
    oBox.itemId = itemId
    oBox.iconSpr:SetActive(bShow)
    oBox.nameL:SetActive(bShow)
    if oItem then
        oBox.iconSpr:SpriteItemShape(oItem:GetCValueByKey("icon"))
        oBox.nameL:SetText(oItem:GetCValueByKey("name"))
    end
end

function CSummonEquipEditView.SetComfirmBtnState(self)
    if self.m_SelPage == 1 then
        self.m_ComfirmBtn:SetSize(116, 46)
        self.m_ComfirmBtn:SetText("合成装备")
        self.m_ComfirmBtn.m_ClkDelta = 0
    else
        self.m_ComfirmBtn:SetSize(180, 46)
        self.m_ComfirmBtn:SetText("重置护符技能")
        self.m_ComfirmBtn.m_ClkDelta = 0.34
    end
end

function CSummonEquipEditView.OnClickPage(self, iPage)
    if iPage == self.m_SelPage then return end
    self.m_SelPage = iPage
    self:RefreshPage()
end

function CSummonEquipEditView.RefreshPage(self, itemId)
    local iPage = self.m_SelPage
    self:RefreshTargetItem(nil)
    self:SetComfirmBtnState()
    if iPage == 1 then
        self.m_ComposePart:SetInfo(nil)
    else
        self.m_ResetPart:SetInfo(nil)
    end
    self.m_BagItemsPart:RefreshItems(iPage==2 and define.Summon.Equip.Sign, itemId)
    self.m_ComposePart:SetActive(iPage==1)
    self.m_ResetPart:SetActive(iPage==2)
end

function CSummonEquipEditView.OnClickComfirm(self)
    if self.m_SelPage == 1 then
        local bCntCorrect = self.m_BagItemsPart:CheckIsCntCorrect()
        if not bCntCorrect then
            return
        end
        local items = self.m_ComposePart:GetEquipIds()
        netitem.C2GSSummonEquipCombine(items)
    else
        local bCanReset = self.m_ResetPart:CheckIsCanReset()
        if bCanReset then
            local itemId = self.m_ResetPart:GetEquipId()
            netitem.C2GSSummonEquipResetSkill(itemId)
        end
    end
end

function CSummonEquipEditView.ShowResetPage(self, itemId)
    self.m_SelPage = 2
    self:RefreshPage(itemId)
    self.m_ResetBtn:SetSelected(true)
end

function CSummonEquipEditView.OnClickTip(self)
    local id = self.m_SelPage == 1 and 10040 or 10041
    local info = data.instructiondata.DESC[id]
    local dContent = {title = info.title, desc = info.desc}
    g_WindowTipCtrl:SetWindowInstructionInfo(dContent)
end

function CSummonEquipEditView.OnSummonCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Summon.Event.EquipEditSelItem then
        self:OnChooseBagItem(oCtrl.m_EventData)
    elseif oCtrl.m_EventID == define.Summon.Event.SummonEquipCombine then
        self:OnComposeEquip(oCtrl.m_EventData)
    end
end

function CSummonEquipEditView.OnItemCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.UpdateItemInfo then
        self:OnUpdateBagItem(oCtrl.m_EventData)
    end
end

function CSummonEquipEditView.OnChooseBagItem(self, dInfo)
    local bChoosed = dInfo.choosed
    local oItem = dInfo.item
    if self.m_SelPage == 1 then
        self.m_ComposePart:SetInfo(oItem, bChoosed)
    else
        self.m_ResetPart:SetInfo(oItem, bChoosed)
    end
    local iCnt = self.m_BagItemsPart:GetChooseCnt()
    if bChoosed and iCnt == 1 then
        self:RefreshTargetItem(oItem)
    elseif not bChoosed and iCnt <= 0 then
        self:RefreshTargetItem(nil)
    end
end

function CSummonEquipEditView.OnUpdateBagItem(self, itemData)
    if 2 == self.m_SelPage then
        local itemId = self.m_ResetPart:GetEquipId()
        if itemData.id == itemId then
            self.m_BagItemsPart:RefreshItems(define.Summon.Equip.Sign, itemId)
            g_NotifyCtrl:FloatMsg("宠物护符的属性刷新成功")
        end
    end
end

function CSummonEquipEditView.OnComposeEquip(self, itemId)
    if 1 == self.m_SelPage then
        local oItem = g_ItemCtrl.m_BagItems[itemId]
        if oItem then
            local iPos = oItem:GetCValueByKey("equippos")
            if not iPos then
                return
            end
            local sName = oItem:GetCValueByKey("name")
            if iPos == define.Summon.Equip.Sign then
                local dEquip = oItem:GetSValueByKey("equip_info")
                local skills = dEquip.skills
                local iSkCnt = skills and #skills or 0
                if iSkCnt > 1 then
                    sName = "双技能"..sName
                end
            end
            g_NotifyCtrl:FloatMsg(string.format(SummonDataTool.GetText(2020), sName))
            self:RefreshPage()
            self:ShowItemTip(oItem)
            self:RefreshTargetItem(oItem)
        end
    end
end

function CSummonEquipEditView.ShowItemTip(self, oItem)
    CItemTipsView:ShowView(function(oView)
        oView:OpenSummonEquipView(oItem)
        oView:HideBtns()
        UITools.NearTarget(self.m_CloseBtn, oView.m_SummonEquipBox.m_BgSpr, enum.UIAnchor.Side.Right, Vector3.New(100, -200, 0))
    end)
end

return CSummonEquipEditView
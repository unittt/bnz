local CSummonEquipBagPart = class("CSummonEquipBagPart", CBox)

function CSummonEquipBagPart.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_ScrollView = self:NewUI(1, CScrollView)
    self.m_ItemGrid = self:NewUI(2, CGrid)
    self.m_ItemBox = self:NewUI(3, CBox)
    self.m_ItemBox:SetActive(false)
    self.m_CurSelIdx = nil
    self:ResetData()
end

function CSummonEquipBagPart.ResetData(self)
    self.m_ChooseCnt = 0
    self.m_FirstSelItem = nil
    self.m_NeedCnt = 0
end

function CSummonEquipBagPart.UnSelCurItem(self)
    local oBox = self:GetCurSelItemBox()
    if oBox then
        oBox:ForceSelected(false)
    end
end

function CSummonEquipBagPart.GetCurSelItemBox(self)
    if self.m_CurSelIdx then
        return self.m_ItemGrid:GetChild(self.m_CurSelIdx)
    end
end

function CSummonEquipBagPart.RefreshItems(self, iType, itemId)
    self:ResetData()
    self.m_Type = iType
    local itemList = SummonDataTool.GetBagSummonEquips(iType)
    self.m_ItemGrid:HideAllChilds()
    self:UnSelCurItem()
    for i, oItem in ipairs(itemList) do
        local oBox = self:GetItem(i)
        oBox.chooseSpr:SetActive(false)
        oBox.choosed = false
        oBox.idx = i
        oBox.itemObj = oItem
        oBox.iconSpr:SpriteItemShape(oItem:GetCValueByKey("icon"))
        oBox.qualitySpr:SetItemQuality(oItem:GetCValueByKey("quality"))
        if itemId and itemId == oItem.m_ID then
            oBox:ForceSelected(true)
            self:OnClickItem(oBox)
        end
    end
    self.m_ItemGrid:Reposition()
    self.m_ScrollView:ResetPosition()
end

function CSummonEquipBagPart.GetItem(self, idx)
    local oGrid = self.m_ItemGrid
    local oBox = oGrid:GetChild(idx)
    if not oBox then
        oBox = self.m_ItemBox:Clone()
        oBox.iconSpr = oBox:NewUI(1, CSprite)
        oBox.qualitySpr = oBox:NewUI(2, CSprite)
        oBox.chooseSpr = oBox:NewUI(3, CSprite)
        oBox:AddUIEvent("click", callback(self, "OnClickItem", oBox))
        oBox:SetGroup(oGrid:GetInstanceID())
        oGrid:AddChild(oBox)
    end
    oBox:SetActive(true)
    return oBox
end

function CSummonEquipBagPart.GetChooseCnt(self)
    return self.m_ChooseCnt
end

function CSummonEquipBagPart.CheckIsCanSel(self, oBox)
    if self.m_FirstSelItem then
        if not oBox.choosed and self.m_ChooseCnt >= self.m_NeedCnt then
            self:NotifyComposeMsg()
            return false
        end
        local iFirstPos = self.m_FirstSelItem:GetCValueByKey("equippos")
        local iFirstGrade = self.m_FirstSelItem:GetCValueByKey("quality")
        local oItem = oBox.itemObj
        local iPos = oItem:GetCValueByKey("equippos")
        local iGrade = oItem:GetCValueByKey("quality")
        local bSuit = iPos==iFirstPos and iGrade==iFirstGrade
        local bSignSpc = false
        if bSuit and iPos == define.Summon.Equip.Sign then
            -- 检测技能个数
            local dEquip = oItem:GetSValueByKey("equip_info")
            local skills = dEquip.skills
            local iSkCnt = skills and #skills or 0
            local iNeedSkCnt = self.m_NeedCnt == 2 and 1 or 2
            bSuit = iNeedSkCnt==iSkCnt
            bSignSpc = not bSuit and iNeedSkCnt == 1
        end
        if not bSuit then
            if bSignSpc then
                g_NotifyCtrl:FloatSummonMsg(2038)
            else
                self:NotifyComposeMsg()
            end
            return false
        end
    end
    return true
end

function CSummonEquipBagPart.GetNeedItemCnt(self)
    if self.m_FirstSelItem then
        local oItem = self.m_FirstSelItem
        local iPos = oItem:GetCValueByKey("equippos")
        local iCnt = 2
        if define.Summon.Equip.Sign == iPos then
            local dEquip = oItem:GetSValueByKey("equip_info")
            local skills = dEquip.skills
            local iSkCnt = skills and #skills or 0
            if iSkCnt == 2 then
                iCnt = 4
            end
        end
        return iCnt
    end
end

function CSummonEquipBagPart.NotifyComposeMsg(self)
    local iNeedCnt = self:GetNeedItemCnt()
    if iNeedCnt and iNeedCnt > 2 then
        g_NotifyCtrl:FloatSummonMsg(2021)
    else
        g_NotifyCtrl:FloatSummonMsg(2018)
    end
end

function CSummonEquipBagPart.CheckIsCntCorrect(self)
    if self.m_ChooseCnt == self.m_NeedCnt then
        return true
    else
        self:NotifyComposeMsg()
        return false
    end
end

function CSummonEquipBagPart.SingleChoose(self, oBox)
    if not oBox.choosed then
        local oSelBox = self:GetCurSelItemBox()
        if oSelBox and oBox ~= oSelBox then
            oSelBox.choosed = false
            oSelBox.chooseSpr:SetActive(false)
        end
        oBox.choosed = true
        self.m_FirstSelItem = oBox.itemObj
        self.m_NeedCnt = 1
        self.m_ChooseCnt = 1
    end
    self.m_CurSelIdx = oBox.idx
end

function CSummonEquipBagPart.MultiChoose(self, oBox)
    oBox.choosed = not oBox.choosed
    if oBox.choosed then
        self.m_ChooseCnt = self.m_ChooseCnt + 1
        if not self.m_FirstSelItem then
            self.m_FirstSelItem = oBox.itemObj
            self.m_NeedCnt = self:GetNeedItemCnt()
        end
    else
        self.m_ChooseCnt = self.m_ChooseCnt - 1
        if self.m_ChooseCnt <= 0 then
            self.m_FirstSelItem = nil
            self.m_NeedCnt = 0
        end
    end
    self.m_CurSelIdx = oBox.idx
end

function CSummonEquipBagPart.OnClickItem(self, oBox)
    self.parentView:ShowItemTip(oBox.itemObj)
    if self.m_Type then
        self:SingleChoose(oBox)
    else
        if not self:CheckIsCanSel(oBox) then
            return
        end
        self:MultiChoose(oBox)
    end
    local bChoosed = oBox.choosed and true or false
    oBox.chooseSpr:SetActive(bChoosed)
    local dEventData = {
        item = oBox.itemObj,
        choosed = bChoosed,
    }
    g_SummonCtrl:OnEvent(define.Summon.Event.EquipEditSelItem, dEventData)
end

return CSummonEquipBagPart
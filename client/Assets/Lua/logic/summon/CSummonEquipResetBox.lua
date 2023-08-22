local CSummonEquipResetBox = class("CSummonEquipResetBox", CBox)

function CSummonEquipResetBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_SkGrid = self:NewUI(1, CGrid)
    self.m_SkBox = self:NewUI(2, CBox)
    self.m_CostItemBox = self:NewUI(3, CBox)

    local oBox = self.m_CostItemBox
    oBox.iconSpr = oBox:NewUI(1, CSprite)
    oBox.qualitySpr = oBox:NewUI(2, CSprite)
    oBox.cntL = oBox:NewUI(3, CLabel)

    self.m_SkBox:SetActive(false)
    oBox:AddUIEvent("click", callback(self, "OnClickCostItem"))
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
    self.m_ResetItem = nil
end

function CSummonEquipResetBox.SetInfo(self, oItem, bChoosed)
    self.m_CostItemBox:SetActive(bChoosed)
    if bChoosed then
        self:SetSkillInfo(oItem)
        self.m_ResetItem = oItem
        self:SetItemInfo(oItem:GetCValueByKey("resetcost"))
    else
        self.m_ResetItem = nil
        self:SetSkillInfo(nil)
    end
end

function CSummonEquipResetBox.SetSkillInfo(self, oItem)
    self.m_SkGrid:HideAllChilds()
    if oItem then
        local dEquip = oItem:GetSValueByKey("equip_info")
        local skills = dEquip.skills
        if skills then
            for i, skill in ipairs(skills) do
                local dSk = SummonDataTool.GetSummonSkillInfo(skill.sk)
                if dSk then
                    local oBox = self:GetSkillBox(i)
                    oBox.iconSpr:SpriteSkill(dSk.iconlv[1].icon)
                    local iQuality = dSk.quality
                    if iQuality == 0 then
                        iQuality = 2
                    end
                    oBox.qualitySpr:SetItemQuality(iQuality)
                    oBox.sk = skill.sk
                end
            end
        end
    end
    self.m_SkGrid:Reposition()
end

function CSummonEquipResetBox.GetSkillBox(self, idx)
    local oBox = self.m_SkGrid:GetChild(idx)
    if not oBox then
        oBox = self.m_SkBox:Clone()
        oBox.iconSpr = oBox:NewUI(1, CSprite)
        oBox.qualitySpr = oBox:NewUI(2, CSprite)
        oBox:AddUIEvent("click", callback(self, "OnClickSkBox", oBox))
        self.m_SkGrid:AddChild(oBox)
    end
    oBox:SetActive(true)
    return oBox
end

function CSummonEquipResetBox.SetItemInfo(self, itemId)
    local oBox = self.m_CostItemBox
    if not itemId then
        itemId = oBox.itemId
        if not itemId then
            return
        end
    end
    local dItem = DataTools.GetItemData(itemId)
    oBox.iconSpr:SpriteItemShape(dItem.icon)
    oBox.qualitySpr:SetItemQuality(dItem.quality)
    local iCnt = g_ItemCtrl:GetBagItemAmountBySid(itemId)
    if iCnt > 0 then
        oBox.cntL:SetText("[1D8E00]"..iCnt)
    else
        oBox.cntL:SetText("[D71420]"..iCnt)
    end
    oBox.itemId = itemId
end

function CSummonEquipResetBox.GetEquipId(self)
    if self.m_ResetItem then
        return self.m_ResetItem.m_ID
    end
end

function CSummonEquipResetBox.CheckIsCanReset(self)
    local bCan = true
    if not self.m_ResetItem then
        g_NotifyCtrl:FloatMsg("请选择要重置的护符")
        bCan = false
    else
        local itemId = self.m_CostItemBox.itemId
        local iCnt = g_ItemCtrl:GetBagItemAmountBySid(itemId)
        if iCnt <= 0 then
            local dItem = DataTools.GetItemData(itemId)
            g_NotifyCtrl:FloatMsg(string.format("%s不足", dItem.name))
            bCan = false
        end
    end
    return bCan
end

function CSummonEquipResetBox.OnClickSkBox(self, oBox)
    if not oBox.sk then return end
    local dSk = {sk = oBox.sk, equip = true}
    CSummonSkillItemTipsView:ShowView(function (oView)
        oView:SetData(dSk, oBox:GetPos(), nil, nil)  
    end)
end

function CSummonEquipResetBox.OnClickCostItem(self)
    local itemId = self.m_CostItemBox.itemId
    if not itemId then return end
    g_WindowTipCtrl:SetWindowGainItemTip(itemId)
end

function CSummonEquipResetBox.OnCtrlItemEvent(self, oCtrl)
    if self:GetActive() == false then
        return
    end
    if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
    or oCtrl.m_EventID == define.Item.Event.ItemAmount then
        self:SetItemInfo()
    end
end

return CSummonEquipResetBox
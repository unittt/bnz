local CSelectRewardBox = class("CSelectRewardBox", CBox)

function CSelectRewardBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_IconSpr = self:NewUI(1, CSprite)
    self.m_CntL = self:NewUI(2, CLabel)
    self.m_QualitySpr = self:NewUI(3, CSprite)
    self.m_MultiSpr = self:NewUI(4, CSprite)
    self.m_SelCb = nil
    self.m_CntL:SetText("")
    self.m_MultiSpr:SetActive(false)
    self:AddUIEvent("click", callback(self, "OnClickReward"))
end

function CSelectRewardBox.SetInfo(self, idx, itemList, bCanSel)
    self.m_Idx = idx or 1
    self.m_ItemList = itemList or {}
    self.m_IsCanSel = bCanSel
    local dItem = itemList[idx]
    self.m_IsMulti = #itemList > 1
    self.m_MultiSpr:SetActive(self.m_IsMulti)
    if dItem then
        local dConfig = DataTools.GetItemData(dItem.sid)
        self.m_IconSpr:SpriteItemShape(dConfig.icon)
        self.m_QualitySpr:SetItemQuality(dConfig.quality)
        self.m_CntL:SetText(dItem.amount)
        self.m_SelId = dItem.sid
    else
        self.m_CntL:SetText("")
    end
end

function CSelectRewardBox.SetSelCallback(self, cb)
    self.m_SelCb = cb
end

function CSelectRewardBox.OnClickReward(self)
    if self.m_IsMulti then
        if self.m_IsCanSel then
            g_WindowTipCtrl:ShowWindowSelectItemView({
                surecb = function(idx, dItem)
                    if self.m_SelCb then
                        self.m_SelCb(idx, dItem, self.m_Idx)
                    end
                end,
                selectidx = self.m_Idx,
                title = "可选",
                des = "请选择一份心仪的奖励",
                itemlist = self.m_ItemList,
                comfirmText = "确定",
            })
        else
            g_WindowTipCtrl:ShowItemBoxView({
                title = "可选",
                hideBtn = true,
                desc = "达到领取条件时，可以选择任意一样物品作为奖励",
                items = self.m_ItemList,
                comfirmText = "确定",
            })
        end
    elseif self.m_SelId then
        g_WindowTipCtrl:SetWindowItemTip(self.m_SelId, {widget=self})
    end
end

return CSelectRewardBox
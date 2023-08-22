local CSummonEquipSelView = class("CSummonEquipSelView", CViewBase)

function CSummonEquipSelView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Summon/SummonEquipSelView.prefab", cb)
    self.m_DepthType = "Dialog"
end

function CSummonEquipSelView.OnCreateView(self)
    self.m_ItemGrid = self:NewUI(1, CGrid)
    self.m_ItemBox = self:NewUI(2, CBox)
    self.m_ScrollView = self:NewUI(3, CScrollView)
    self.m_CloseBtn = self:NewUI(4, CButton)
    self.m_BgWidget = self:NewUI(5, CWidget)
    self.m_AddSpr = self:NewUI(6, CSprite)
    self.m_ItemBox:SetActive(false)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_AddSpr:AddUIEvent("click", callback(self, "OnClickAdd"))
    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CSummonEquipSelView.SetData(self, iPos, bChange)
    self.m_SummonId = g_SummonCtrl:GetCurSelSummon()
    self.m_IsChange = bChange
    self.m_Pos = iPos
    local dSummon = g_SummonCtrl:GetSummon(self.m_SummonId)
    if not dSummon then return end
    local dItems = SummonDataTool.GetBagSummonEquips(iPos, dSummon.grade)
    for i, oItem in ipairs(dItems) do
        local dConfig = SummonDataTool.GetSummonEquip(oItem.m_SID)
        local oBox = self:GetItemBox(i)
        oBox.iconSpr:SpriteItemShape(dConfig.icon)
        oBox.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dConfig.id, dConfig.quality or 0 ))
        oBox.item = oItem
    end
    self.m_ItemGrid:AddChild(self.m_AddSpr)
end

function CSummonEquipSelView.GetItemBox(self, idx)
    local oBox = self.m_ItemGrid:GetChild(idx)
    if not oBox then
        oBox = self.m_ItemBox:Clone()
        oBox.iconSpr = oBox:NewUI(1, CSprite)
        oBox.cntL = oBox:NewUI(2, CLabel)
        oBox.qualitySpr = oBox:NewUI(3, CSprite)
        -- oBox.nameL = oBox:NewUI(4, CLabel)
        oBox.cntL:SetActive(false)
        oBox:SetActive(true)
        self.m_ItemGrid:AddChild(oBox)
        -- oBox:AddUIEvent("click", callback(self, "OnClickItem"))
        oBox:AddUIEvent("click", callback(self, "ShowEquipTip"))
        oBox:SetLongPressTime(0.2)
    end
    return oBox
end

function CSummonEquipSelView.ShowEquipTip(self, oBox, bPress)
    local oItem = oBox.item
    local bEquiped = self.m_IsChange
    CItemTipsView:ShowView(function(oView)
        oView:OpenSummonEquipView(oItem, nil, nil, 2)
        UITools.NearTarget(self.m_BgWidget, oView.m_SummonEquipBox.m_BgSpr, enum.UIAnchor.Side.Left, Vector3.New(-50, 0, 0))
    end)
end


function CSummonEquipSelView.ShowEquipComfirm(self, oBox)
    local iSummon = self.m_SummonId
    local dSummon = g_SummonCtrl:GetSummon(iSummon)
    if not dSummon then return end
    local oItem = oBox.item
    local sDesc
    if self.m_IsChange then
        sDesc = SummonDataTool.GetText(2024)
        local sItemName = oItem:GetItemName()
        sDesc = string.format(sDesc, dSummon.name, sItemName)
    else
        sDesc = SummonDataTool.GetText(2023)
    end
    local itemId = oItem.m_ID
    
    local windowConfirmInfo = {
        msg = sDesc,
        title = "提示",
        okCallback = function()
            netsummon.C2GSEquipSummon(iSummon, itemId, 0)
        end
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSummonEquipSelView.OnClickItem(self, oBox)
    local oItem = oBox.item
    if not oItem then
        return
    end
    local iEqId = oItem.m_ID
    self:ShowEquipComfirm(oBox)
    -- netsummon.C2GSEquipSummon(self.m_SummonId, iEqId)
    self:OnClose()
end

function CSummonEquipSelView.OnClickAdd(self)
    local itemId = SummonDataTool.GetTopEquipId(self.m_Pos)
    if itemId then
        -- CQuickGetTipView:ShowView(function(oView)
        --     oView:InitItemInfo(itemId)
        -- end)
        --TODO:临时替换旧的跳转
        g_WindowTipCtrl:SetWindowGainItemTip(itemId)
    end
end

function CSummonEquipSelView.OnClose(self)
    self:CloseView()
end

return CSummonEquipSelView
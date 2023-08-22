local CSummonCompoundPart = class("CSummonCompoundPart", CBox)

function CSummonCompoundPart.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_LeftMatInfo = nil
    self.m_RightMatInfo = nil

    self.m_CostItemId = define.Summon.ComposeCost
    self.m_ItemCnt = 0
    self.m_ItemName = ""
    self.m_NeedItemCnt = 1

    self.m_BanCost = false
    self:InitContent()
end

function CSummonCompoundPart.InitContent(self)
    self.m_CompoundBtn = self:NewUI(1, CButton)
    self.m_DesBtn = self:NewUI(2, CButton)
    self.m_PreviewBtn = self:NewUI(3, CButton)
    self.m_LeftMatPart = self:NewUI(4, CSummonCompoundMatPart)
    self.m_RightMatPart = self:NewUI(5, CSummonCompoundMatPart, nil, true)
    self.m_RebatePart = self:NewUI(6, CBox)
    self.m_CostItemBox = self:NewUI(7, CBox)
    self.m_QuickBuyBox = self:NewUI(8, CQuickBuyBox)
    self.m_CostPart = self:NewUI(9, CWidget)
    self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)
    self.m_QuickBuyBox:SetInfo({
        id = define.QuickBuy.SummonCompose,
        name = "便捷合宠",
        offset = Vector3(0,17,0),
    })
    self:InitRebatePart()
    self:InitCostItemPart()
    self:RegisterEvents()
    self.m_RebatePart.rebateL:SetColor(Color.white)
end

function CSummonCompoundPart.InitRebatePart(self)
    local oBox = self.m_RebatePart
    oBox.rebateL = oBox:NewUI(1, CLabel)
end

function CSummonCompoundPart.InitCostItemPart(self)
    if self.m_BanCost then
        self.m_CostPart:SetActive(false)
        self.m_CompoundBtn:SetLocalPos(Vector3.New(0,-261,0))
        return
    end
    local oItem = self.m_CostItemBox
    oItem.iconSpr = oItem:NewUI(1, CSprite)
    oItem.qualitySpr = oItem:NewUI(2, CSprite)
    oItem.cntL = oItem:NewUI(3, CLabel)
    oItem.nameL = oItem:NewUI(4, CLabel)
    local dItem = DataTools.GetItemData(self.m_CostItemId)
    oItem.iconSpr:SpriteItemShape(dItem.icon)
    oItem.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dItem.id, dItem.quality or 0))
    oItem.nameL:SetText(dItem.name)
    self:RefreshCostItemCnt()
    self.m_ItemName = dItem.name
    oItem:AddUIEvent("click", callback(self, "OnClickCostItem"))
end

function CSummonCompoundPart.RegisterEvents(self)
    self.m_CompoundBtn:AddUIEvent("click", callback(self, "OnClickCompound"))
    self.m_DesBtn:AddUIEvent("click", callback(self, "OnClickDes"))
    self.m_PreviewBtn:AddUIEvent("click", callback(self, "OnClickPreview"))
end

function CSummonCompoundPart.CompoundHide(self)
    self.m_LeftMatPart:SetInfo(nil)
    self.m_RightMatPart:SetInfo(nil)
    g_SummonCtrl.m_LeftCompoundId = nil
    g_SummonCtrl.m_RightCompoundId = nil
    self:RefreshRebate()
    self:RefreshCostItemCnt()
    g_SummonCtrl:ClearCompoundSelRecord()
end

function CSummonCompoundPart.RefreshSummonMat(self, info, bRight)
    if bRight then
        self.m_RightMatPart:SetInfo(info)
    else
        self.m_LeftMatPart:SetInfo(info)
    end
    self:RefreshRebate()
    self:RefreshCostItemCnt()
end

function CSummonCompoundPart.RefreshRebate(self)
    local oRateL = self.m_RebatePart.rebateL
    local iScore = g_SummonCtrl:GetSummonComposeScore()
    if iScore then
        oRateL:SetText(string.format("[244b4e]合成最多会返还[af302a]%d[-]积分[-]", iScore))
    else
        oRateL:SetText("[244b4e]合宠只能选择非野生宠物，神兽和珍兽请在图鉴寻路到NPC处合成")
    end
end

function CSummonCompoundPart.IsCompoundGuide(self)
    local bNeed = true
    if g_GuideCtrl.m_Flags["SummonCompose"] then
        bNeed = false
    elseif not g_GuideHelpCtrl:CheckNecessaryCondition("SummonCompose") then
        bNeed = false
    elseif not g_SummonCtrl:GetIsNeedSummonComposeGuide() then
        bNeed = false
    end
    return bNeed
end

---------------------------- 物品消耗 ----------------------------
function CSummonCompoundPart.RefreshCostItemCnt(self)
    if self.m_BanCost then return end
    local oLabel = self.m_CostItemBox.cntL
    local iCnt = g_ItemCtrl:GetBagItemAmountBySid(self.m_CostItemId)
    self.m_ItemCnt = iCnt
    local dSum1, dSum2 = self.m_LeftMatPart.m_SummonInfo, self.m_RightMatPart.m_SummonInfo
    if not dSum1 or not dSum2 then
        self.m_CostPart:SetActive(false)
        return
    end
    self.m_CostPart:SetActive(true)
    oLabel:SetActive(true)
    local iCarry = dSum1.carrygrade > dSum2.carrygrade and dSum1.carrygrade or dSum2.carrygrade
    local dConfig = SummonDataTool.GetWashCost(iCarry)
    if not dConfig then return end
    local bXiyou = self:IsXiyouCost(dSum1, dSum2)
    local iNeed = bXiyou and dConfig.xy_combine_cost or dConfig.combine_cost
    iNeed = iNeed or 0
    if iCnt < iNeed then
        oLabel:SetText(string.format("[af302a]%d[-][63432c]/%d[-]", iCnt, iNeed))
    else
        oLabel:SetText(string.format("[1D8E00]%d/%d", iCnt, iNeed))
    end
    self.m_NeedItemCnt = iNeed
    self.m_QuickBuyBox:SetItemsInfo({{id = self.m_CostItemId, cnt = iNeed}})
end

function CSummonCompoundPart.IsXiyouCost(self, dSumm1, dSumm2)
    if SummonDataTool.IsUnnormalSummon(dSumm1.type) or SummonDataTool.IsUnnormalSummon(dSumm2.type) then
        return true
    elseif SummonDataTool.GetComposeXiyou(dSumm1.typeid, dSumm2.typeid) then
        return true
    end
    return false
end

function CSummonCompoundPart.CheckItemEnough(self, bQuickSel)
    if self.m_BanCost then
        return true
    end
    if bQuickSel then
        return self.m_QuickBuyBox:CheckCostEnough()
    end
    if self.m_ItemCnt >= self.m_NeedItemCnt then
        return true
    else
        g_QuickGetCtrl:CheckLackItemInfo({
            itemlist = {{sid = self.m_CostItemId, count = self.m_ItemCnt, amount = self.m_NeedItemCnt}},
            exchangeCb = function()
                netsummon.C2GSCombineSummon(g_SummonCtrl.m_LeftCompoundId,g_SummonCtrl.m_RightCompoundId,1)
            end,
        })
        -- g_NotifyCtrl:FloatMsg(string.format("%s数量不足，无法合成！", self.m_ItemName))
        return false
    end
end

function CSummonCompoundPart.CheckCombineComfirm(self, bQuickSel)
    local dSumm1, dSumm2 = self.m_LeftMatPart.m_SummonInfo, self.m_RightMatPart.m_SummonInfo
    local bXiyou1 = SummonDataTool.IsUnnormalSummon(dSumm1.type)
    local bXiyou2 = SummonDataTool.IsUnnormalSummon(dSumm2.type)
    local bHasEquip = (dSumm1.equipinfo and #dSumm1.equipinfo>0) or (dSumm2.equipinfo and #dSumm2.equipinfo>0)
    if not bXiyou1 and not bXiyou2 and not bHasEquip then return false end
    local sLast = "是否继续宠物合成？"
    local sFirst, sSec = "", ""
    if bXiyou1 and bXiyou2 then
        sFirst = string.format("#R%s#n、#R%s#n为稀有宠物", dSumm1.name, dSumm2.name)
    elseif bXiyou1 or bXiyou2 then
        local dS = bXiyou1 and dSumm1 or dSumm2
        sFirst = string.format("#R%s#n为稀有宠物", dS.name)
    end
    if bHasEquip then
        sSec = "合成后，宠物装备将会消失，根据宠物装备返还一定一定#R积分#n，"
    end
    if string.len(sFirst) > 0 then
        if string.len(sSec) > 0 then
            sFirst = sFirst.."。"
        else
            sFirst = sFirst.."，"
        end
    end
    sLast = string.format("[63432C]%s%s%s[-]", sFirst, sSec, sLast)
    local iLeft, iRight = dSumm1.id, dSumm2.id
    local windowTipInfo = {
        msg = sLast,
        okCallback = function () 
            netsummon.C2GSCombineSummon(iLeft, iRight, bQuickSel and 1 or 0)
        end,
        title = "合成确认",
        color = Color.white,
    }
    g_WindowTipCtrl:SetWindowConfirm(windowTipInfo)
    return true
end

------------------------ 特效相关 ------------------------
function CSummonCompoundPart.ComposeSuccess(self, iSummonId)
    CSummonComposePreView:CloseView()
    if iSummonId then
        self.m_ComposeId = iSummonId
        self:ShowComposeEff()
    end
end

function CSummonCompoundPart.ShowComposeEff(self)
    CSummonComOutView:OnClose()
    self:CompoundHide()
    self:DelEffect("SummCompose")
    self:AddEffect("SummCompose", nil, Vector3.New(-407, 181, 0))
    self:AddEffTimer()
end

function CSummonCompoundPart.AddEffTimer(self)
    self:DelEffTimer()
    self.m_EffTimer = Utils.AddTimer(callback(self, "OnEffFinish"), 0, 1.1)
end

function CSummonCompoundPart.DelEffTimer(self)
    if self.m_EffTimer then
        Utils.DelTimer(self.m_EffTimer)
        self.m_EffTimer = nil
    end
end

function CSummonCompoundPart.OnEffFinish(self)
    if self.m_ComposeId and g_SummonCtrl:GetSummon(self.m_ComposeId) then
        CSummonComOutView:ShowView(function(oView)
            oView:SetData(self.m_ComposeId)
            self.m_ComposeId = nil
        end)
    end
    self:DelEffect("SummCompose")
end

------------------------- ui events --------------------------
function CSummonCompoundPart.OnClickCompound(self)
    local iLeft, iRight = g_SummonCtrl.m_LeftCompoundId, g_SummonCtrl.m_RightCompoundId
    if not iLeft or not iRight then
        g_NotifyCtrl:FloatSummonMsg(1032)
        return
    end
    if self:IsCompoundGuide() then
        netsummon.C2GSCombineSummonLead(iLeft, iRight)
    else
        local bQuickSel = self.m_QuickBuyBox:IsSelected()
        if not self:CheckItemEnough(bQuickSel) or self:CheckCombineComfirm(bQuickSel) then
            return
        end
        netsummon.C2GSCombineSummon(iLeft, iRight, bQuickSel and 1 or 0)
    end
end

function CSummonCompoundPart.OnClickPreview(self)
    local iLeft, iRight = g_SummonCtrl.m_LeftCompoundId, g_SummonCtrl.m_RightCompoundId
    if not iLeft or not iRight then 
        g_NotifyCtrl:FloatSummonMsg(1032)
        return
    end
    g_SummonCtrl:ShowComposePreView(iLeft, iRight)
end

function CSummonCompoundPart.OnClickDes(self)
    local dConfig = data.instructiondata.DESC[10042]
    if not dConfig then return end
    local dContent = {
        title = dConfig.title,
        desc = dConfig.desc,
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(dContent)
end

function CSummonCompoundPart.OnClickCostItem(self)
    g_WindowTipCtrl:SetWindowGainItemTip(self.m_CostItemId)
end

function CSummonCompoundPart.Destroy(self)
    self:DelEffTimer()
    self:DelEffect("SummCompose")
    CBox.Destroy(self)
end

return CSummonCompoundPart
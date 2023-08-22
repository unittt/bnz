local CSummonWashPart = class("CSummonWashPart", CBox)

function CSummonWashPart.ctor(self, obj)
    CBox.ctor(self, obj)

    self.m_ItemId = 10031 --洗练物品

    self.m_Info = nil
    self.m_CostCnt = 0
    self:InitContent()
end

function CSummonWashPart.InitContent(self)
    self.m_AptiBox = self:NewUI(1, CSummonAptiBox)
    self.m_SkillBox = self:NewUI(2, CSummonSkillBox)
    self.m_DescBtn = self:NewUI(3, CButton)
    self.m_WashBtn = self:NewUI(4, CButton)
    self.m_ItemBox = self:NewUI(5, CBox)
    self.m_QuickBuyBox = self:NewUI(6, CQuickBuyBox)
    self.m_AptiBox:InitSliderUI()
    self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)
    self.m_QuickBuyBox:SetInfo({
        id = define.QuickBuy.SummonWash,
        name = "便捷洗炼",
        offset = Vector3(-40,0,0),
    })
    self:InitItemBox()
    self.m_WashBtn:AddUIEvent("click", callback(self, "OnClickWash"))
    self.m_WashBtn.m_ClkDelta = 0.35
    self.m_DescBtn:AddUIEvent("click", callback(self, "OnClickDesc"))
    g_SummonCtrl.m_ShowWashEff = false
end

function CSummonWashPart.InitItemBox(self)
    local oBox = self.m_ItemBox
    oBox.iconSpr = oBox:NewUI(1, CSprite)
    oBox.nameL = oBox:NewUI(2, CLabel)
    oBox.cntL = oBox:NewUI(3, CLabel)
    oBox.qualitySpr = oBox:NewUI(4, CSprite)
    oBox:AddUIEvent("click", callback(self, "OnClickItem", oBox))
end

function CSummonWashPart.SetInfo(self, info)
    local bNotEmpty = info and true or false
    self.m_AptiBox:SetActive(bNotEmpty)
    if info then
        self.m_AptiBox:SetInfo(info)
        local skills = SummonDataTool.GetSkillInfo(info)
        self.m_SkillBox:SetInfo(skills, true)
        self.m_Info = info
        self:UpdateItemInfo()
    end
    if g_SummonCtrl.m_ShowWashEff then
        self:PlayWashEffect()
        g_SummonCtrl.m_ShowWashEff = false
    end
end

function CSummonWashPart.UpdateItemInfo(self)
    local oBox = self.m_ItemBox
    local dItem = DataTools.GetItemData(self.m_ItemId)
    oBox.iconSpr:SpriteItemShape(dItem.icon)
    oBox.nameL:SetText(dItem.name)
    oBox.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dItem.id, dItem.quality or 0 ))
    local iNeed, iOwn = self:GetItemCnt()
    if iNeed > iOwn then
        oBox.cntL:SetText(string.format("[af302a]%s[-][63432c]/%s[-]", iOwn, iNeed))
    else
        oBox.cntL:SetText(string.format("[1D8E00]%s/%s[-]", iOwn, iNeed))
    end
    self.m_QuickBuyBox:SetItemsInfo({{id = self.m_ItemId, cnt = iNeed}})
end

function CSummonWashPart.WashSummon(self, id, bQuickSel)
    g_SummonCtrl.m_ShowWashEff = true
    if bQuickSel == nil then
        bQuickSel = self.m_QuickBuyBox:IsSelected()
    end
    netsummon.C2GSWashSummon(id, bQuickSel and 1 or 0)
end

function CSummonWashPart.ShowWashComfirm(self, idx)
    local msg = ""
    if idx == 1 then
        msg = SummonDataTool.GetText(1027)
    elseif idx == 2 then
        msg = "该宠物是绑定宠物，确定要对其进行洗练吗？"
    end
    local windowConfirmInfo = {
        msg = msg,
        title = "洗练",
        okCallback = callback(self, "WashSummon", self.m_Info.id)
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSummonWashPart.ShowFightWashConfirm(self)
    local msg = "参战宠物不可进行洗练，是否让宠物休息？"
    local windowConfirmInfo = {
        msg = msg,
        okCallback = callback(g_SummonCtrl, "SetFight", self.m_Info.id, 0)
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSummonWashPart.GetItemCnt(self)
    local iGrade = self.m_Info.carrygrade
    local dCost = SummonDataTool.GetWashCost(iGrade)
    if not dCost then
        printc("没找到洗练配置 携带等级: ", iGrade)
    end
    local iNeed = dCost and dCost.cnt or 1
    self.m_CostCnt = iNeed
    local iOwn = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
    return iNeed, iOwn
end

function CSummonWashPart.CheckItemEnough(self, bQuickSel)
    if bQuickSel then
        return self.m_QuickBuyBox:CheckCostEnough()
    end
    local iNeed, iOwn = self:GetItemCnt()
    if iNeed > iOwn then
        local t = {
            sid = self.m_ItemId,
            count = iOwn,
            amount = iNeed,
        }
        g_QuickGetCtrl:CurrLackItemInfo({t},{}, nil, function()
            self:WashSummon(self.m_Info.id, true)
        end)
        return false
    end
    return true
end

function CSummonWashPart.OnClickDesc(self)
    local dConfig = data.instructiondata.DESC[10056]
    if not dConfig then return end
    local dContent = {
        title = dConfig.title,
        desc = dConfig.desc,
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(dContent)
end

function CSummonWashPart.OnClickItem(self)
    g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemId)
end

function CSummonWashPart.OnClickWash(self)
    local dSummon = self.m_Info
    if not dSummon then
        g_NotifyCtrl:FloatSummonMsg(1045)
        return
    elseif SummonDataTool.IsExpensiveSumm(dSummon.type) then
        g_NotifyCtrl:FloatSummonMsg(1002)
        return
    elseif dSummon.id == g_SummonCtrl.m_FightId then
        -- g_NotifyCtrl:FloatSummonMsg(1013)
        self:ShowFightWashConfirm()
        return
    end
    local bQuickSel = self.m_QuickBuyBox:IsSelected()
    if not self:CheckItemEnough(bQuickSel) then
        return
    end
    -- if SummonDataTool.IsRare(dSummon) then
    --     self:ShowWashComfirm(1)
    if 1 == dSummon.key then
        self:ShowWashComfirm(2)
    else
        self:WashSummon(dSummon.id, bQuickSel)
    end
end

function CSummonWashPart.PlayWashEffect(self)
    if not self:GetActive(true) then return end
    local objList = self.m_AptiBox.m_AptAttrList:GetChildList()
    self:DelEffTimer()
    for i, obj in ipairs(objList) do
        if i > 5 then break end
        obj:DelEffect("SummWash")
        obj:AddEffect("SummWash")
    end
    self.m_EffTimer = Utils.AddTimer(callback(self, "DelEffs"), 0, 0.9)
end

function CSummonWashPart.DelEffs(self)
    local objList = self.m_AptiBox.m_AptAttrList:GetChildList()
    for i, obj in ipairs(objList) do
        if i > 5 then break end
        obj:DelEffect("SummWash")
    end
end

function CSummonWashPart.DelEffTimer(self)
    if self.m_EffTimer then
        Utils.DelTimer(self.m_EffTimer)
        self.m_EffTimer = nil
    end
end

function CSummonWashPart.Destroy(self)
    self:DelEffTimer()
    CBox.Destroy(self)
end

return CSummonWashPart
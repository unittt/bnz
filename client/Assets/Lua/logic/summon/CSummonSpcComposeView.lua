local CSummonSpcComposeView = class("CSummonSpcComposeView", CViewBase)

function CSummonSpcComposeView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Summon/SummonSpcComposeView.prefab", cb)
    self.m_Type1 = nil
    self.m_Type2 = nil
    self.m_TargetType = nil
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
    self.m_ExcId = 0
end

function CSummonSpcComposeView.OnCreateView(self)
    self.m_CompoundBtn = self:NewUI(2, CButton)
    self.m_DesBtn = self:NewUI(3, CButton)
    self.m_PreviewBtn = self:NewUI(4, CButton)
    self.m_LeftMatPart = self:NewUI(5, CSummonCompoundMatPart)
    self.m_RightMatPart = self:NewUI(6, CSummonCompoundMatPart, nil, true)
    self.m_CloseBtn = self:NewUI(7, CButton)
    self.m_TitleL = self:NewUI(8, CLabel)
    self.m_CostItemBox = self:NewUI(9, CBox)
    self:InitContent()
end

function CSummonSpcComposeView.InitCostItem(self)
    local oBox = self.m_CostItemBox
    oBox.iconSpr = oBox:NewUI(1, CSprite)
    oBox.qualitySpr = oBox:NewUI(2, CSprite)
    oBox.needL = oBox:NewUI(3, CLabel)
    oBox.nameL = oBox:NewUI(4, CLabel)
    oBox.cntL = oBox:NewUI(5, CLabel)
    self.m_ShowSpcComposeEff = false
    oBox:AddUIEvent("click", callback(self, "OnClickCost"))
end

function CSummonSpcComposeView.InitContent(self)
    self:ComposeHide()
    self:InitCostItem()
    self.m_CompoundBtn:AddUIEvent("click", callback(self, "OnClickCompound"))
    self.m_DesBtn:AddUIEvent("click", callback(self, "OnClickDes"))
    self.m_PreviewBtn:AddUIEvent("click", callback(self, "OnClickPreview"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSummonCtrlEvent"))
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end

function CSummonSpcComposeView.SetData(self, iTarget)
    local dConfig = SummonDataTool.GetSpcExchanges(iTarget)[1]
    self.m_ExcId = dConfig.eid
    self.m_Type1 = dConfig.sid1
    self.m_Type2 = dConfig.sid2
    self.m_CostItemInfo = dConfig.cost[1]
    self.m_TargetType = iTarget
    self:SetComposeMatIds()
    self:RefreshCostItem()
    self:SetTitle()
end

function CSummonSpcComposeView.SetComposeMatIds(self)
    local ids = {self.m_Type1, self.m_Type2}
    self.m_LeftMatPart:SetSelSummons(ids, true)
    self.m_RightMatPart:SetSelSummons(ids, true)
end

function CSummonSpcComposeView.ComposeHide(self)
    self.m_LeftMatPart:SetInfo(nil)
    self.m_RightMatPart:SetInfo(nil)
    self:SetComposeMatIds()
    g_SummonCtrl:ClearCompoundSelRecord()
end

function CSummonSpcComposeView.RefreshSummonMat(self, info, bRight)
    local iSel = info.typeid
    local bSel1 = iSel == self.m_Type1
    local iAno = bSel1 and self.m_Type2 or self.m_Type1
    if bRight then
        if not g_SummonCtrl.m_LeftCompoundId then
            self.m_LeftMatPart:SetSelSummons({iAno})
        end
        self.m_RightMatPart:SetInfo(info)
        self.m_RightMatPart:SetSelSummons({iSel})
    else
        if not self.m_RightCompoundId then
            self.m_RightMatPart:SetSelSummons({iAno})
        end
        self.m_LeftMatPart:SetInfo(info)
        self.m_LeftMatPart:SetSelSummons({iSel})
    end
end

function CSummonSpcComposeView.RefreshCostItem(self)
    if self.m_CostItemInfo then
        local sid, num = self.m_CostItemInfo.sid, self.m_CostItemInfo.num
        if not self.m_CostItemBox.isInit then
            local dItem = DataTools.GetItemData(sid)
            self.m_CostItemBox:SetActive(true)
            self.m_CostItemBox.iconSpr:SpriteItemShape(dItem.icon)
            self.m_CostItemBox.qualitySpr:SetItemQuality(dItem.quality)
            self.m_CostItemBox.nameL:SetText("[b]"..dItem.name)
            self.m_CostItemBox.isInit = true
        end
        local iCnt = g_ItemCtrl:GetBagItemAmountBySid(sid)
        if num > iCnt then
            self.m_CostItemBox.cntL:SetText(string.format("[ffb398]%s", iCnt))
            self.m_CostItemBox.cntL:SetEffectColor(Color.RGBAToColor("cd0000"))
            self.m_CostItemBox.needL:SetText("/"..num)
        else
            self.m_CostItemBox.cntL:SetText(string.format("[0fff32]%s", iCnt))
            self.m_CostItemBox.cntL:SetEffectColor(Color.RGBAToColor("003C41"))
            self.m_CostItemBox.needL:SetText("/"..num)
        end
    else
        self.m_CostItemBox:SetActive(false)
    end
end

function CSummonSpcComposeView.SetTitle(self)
    local dSummon = SummonDataTool.GetSummonInfo(self.m_TargetType)
    if dSummon.type == 6 or dSummon.type == 8 then
        self.m_TitleL:SetText("珍兽合成")
        self.m_DesId = 10044
    elseif dSummon.type == 5 or dSummon.type == 7 then
        self.m_TitleL:SetText("神兽合成")
        self.m_DesId = 10043
    end
end

function CSummonSpcComposeView.OnClickCompound(self)
    local iLeft = g_SummonCtrl.m_LeftCompoundId
    local iRight = g_SummonCtrl.m_RightCompoundId
    if not iLeft or not iRight then
        g_NotifyCtrl:FloatSummonMsg(1032)
        return
    end
    if not g_SummonCtrl:CheckAllExchangeItem(self.m_TargetType, function()
        self.m_ShowSpcComposeEff = true
        netsummon.C2GSShenShouExchange(self.m_ExcId,iLeft,iRight,1)
    end) then
        return
    end
    self:OpenCombineComfirm()
end

function CSummonSpcComposeView.OnClickDes(self)
    if self.m_DesId then
        local info = data.instructiondata.DESC[self.m_DesId]
        local dContent = {title = info.title, desc = info.desc}
        g_WindowTipCtrl:SetWindowInstructionInfo(dContent)
    end
end

function CSummonSpcComposeView.OnClickCost(self)
    g_WindowTipCtrl:SetWindowGainItemTip(self.m_CostItemInfo.sid)
end

function CSummonSpcComposeView.OnClickPreview(self)
    local iLeft = g_SummonCtrl.m_LeftCompoundId
    local iRight = g_SummonCtrl.m_RightCompoundId
    if not iLeft or not iRight then
        g_NotifyCtrl:FloatSummonMsg(1032)
        return
    end
    g_SummonCtrl:ShowComposePreById(self.m_TargetType)
end

function CSummonSpcComposeView.ComposeSuccess(self, dPb)
    CSummonComposePreView:CloseView()
    self.m_ShowSpcComposeEff = false
    self.m_NewSummon = dPb
    CNpcShowView:CloseView()
    self:ShowComposeEff()
end

function CSummonSpcComposeView.ShowComposeEff(self)
    self.m_PreviewBtn:DelEffect("SummCompose")
    self.m_PreviewBtn:AddEffect("SummCompose", nil, Vector3.New(-390, 166, 0))
    self:AddEffTimer()
end

function CSummonSpcComposeView.AddEffTimer(self)
    self:DelEffTimer()
    self.m_EffTimer = Utils.AddTimer(callback(self, "OnEffFinish"), 0, 1.1)
end

function CSummonSpcComposeView.DelEffTimer(self)
    if self.m_EffTimer then
        Utils.DelTimer(self.m_EffTimer)
        self.m_EffTimer = nil
    end
end

function CSummonSpcComposeView.OnEffFinish(self)
    if self.m_NewSummon then
        CNpcShowView:ShowView(function(oView)
            oView:RefreshUI(self.m_NewSummon)
            self.m_NewSummon = nil
        end)
    end
    self.m_PreviewBtn:DelEffect("SummCompose")
end

function CSummonSpcComposeView.CloseView(self)
    self:DelEffTimer()
    self.m_PreviewBtn:DelEffect("SummCompose")
    g_SummonCtrl:ClearCompoundSelRecord()
    CViewBase.CloseView(self)
end

function CSummonSpcComposeView.OpenCombineComfirm(self)
    local dSumm1, dSumm2 = self.m_LeftMatPart.m_SummonInfo, self.m_RightMatPart.m_SummonInfo
    -- local bHasEquip = (dSumm1.equipinfo and #dSumm1.equipinfo>0) or (dSumm2.equipinfo and #dSumm2.equipinfo>0)
    local iTarget = self.m_TargetType
    local dTarget = SummonDataTool.GetSummonInfo(iTarget)
    local sLast = string.format("是否继续宠物合成%s？", dTarget.name)
    local sFirst = string.format("#R%s#n，#R%s#n合成后，将消失", dSumm1.name, dSumm2.name)
    if iTarget == 4002 then
        sFirst = sFirst..string.format("(清音仙子之灵只能兑换清音仙子#R1#n次)")
    end
    -- if bHasEquip then
        sFirst = string.format("%s。#R%s#n不会继承任何宠物技能和宠物装备，", sFirst, dTarget.name)
    -- else
    --     sFirst = sFirst.."，"
    -- end
    sLast = string.format("[63432C]%s%s[-]", sFirst, sLast)
    local sTitle = SummonDataTool.IsGodSummon(dTarget.type) and "合成神兽" or "合成珍兽"
    local iLeft, iRight = dSumm1.id, dSumm2.id
    if dSumm1.typeid ~= self.m_Type1 then
        local tmp = iLeft
        iLeft = iRight
        iRight = tmp
    end
    local windowTipInfo = {
        msg = sLast,
        okCallback = function () 
            self.m_ShowSpcComposeEff = true
            netsummon.C2GSShenShouExchange(self.m_ExcId, iLeft, iRight)
        end,
        title = sTitle,
        color = Color.white,
    }
    g_WindowTipCtrl:SetWindowConfirm(windowTipInfo)
end

function CSummonSpcComposeView.OnSummonCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Summon.Event.CombineSummonShow then
        -- self:ComposeSuccess(oCtrl.m_EventData)
    elseif oCtrl.m_EventID == define.Summon.Event.AddSummon or oCtrl.m_EventID == define.Summon.Event.WashSummonAdd then
        if oCtrl.m_EventData.typeid == self.m_TargetType then
            self:ComposeHide()
        end
    elseif oCtrl.m_EventID == define.Summon.Event.SetCompoundSummon then
        local dEventData = oCtrl.m_EventData
        self:RefreshSummonMat(dEventData.dSummon, dEventData.bRight)
    elseif oCtrl.m_EventID == define.Summon.Event.ShowSummonCloseup then
        local iSummon = oCtrl.m_EventData.summon
        if iSummon and iSummon == self.m_TargetType and self.m_ShowSpcComposeEff then
            self:ComposeSuccess(oCtrl.m_EventData)
        end
    end
end

function CSummonSpcComposeView.OnItemCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
    or oCtrl.m_EventID == define.Item.Event.ItemAmount then
        if self.m_CostItemInfo then
            self:RefreshCostItem()
        end
    end
end

return CSummonSpcComposeView
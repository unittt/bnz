local CSummonGetWayBox = class("CSummonGetWayBox", CBox)

function CSummonGetWayBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_ItemId = nil
    self.m_ItemCnt = nil
    self.m_CompoundType = 1

    self:InitContent(self)
end

function CSummonGetWayBox.InitContent(self)
    self.m_ScheduleBtn = self:NewUI(1, CButton)
    self.m_ShopBtn = self:NewUI(2, CButton)
    self.m_ItemWayBox = self:NewUI(3, CBox)
    self.m_CompoundBox = self:NewUI(4, CBox)
    self.m_PayBtn = self:NewUI(5, CButton)
    self.m_VertiL = self:NewUI(6, CLabel)
    self.m_SpcGetBox = self:NewUI(7, CSummonSpcGetWayBox)
    self.m_HorzonL = self:NewUI(8, CLabel)
    self:InitItemWayBox()
    self:InitCompoundBox()

    self:RegisterEvents()
end

function CSummonGetWayBox.RegisterEvents(self)
    self.m_ShopBtn:AddUIEvent("click", callback(self, "OnClickShopBtn"))
    self.m_PayBtn:AddUIEvent("click", callback(self, "OnClickPayBtn"))
    self.m_ScheduleBtn:AddUIEvent("click", callback(self, "OnClickScheduleBtn"))
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRefreshItem"))
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareCtrlEvent"))
end

------------------ Set Info -------------
-- iGet: 1 shop 2 compound 3 guild 4 pay 5 item 6 god summon 7 schedule
function CSummonGetWayBox.SetInfo(self, summonInfo)
    local iStore = summonInfo.store
    self.m_CurSummonId = summonInfo.id
    local iGet = iStore
    if summonInfo.id == 2028 then
        iGet = 4
        self:RefreshPayBtn()
    elseif summonInfo.id == 4001 then
        iGet = 7
    elseif SummonDataTool.IsGodSummon(summonInfo.type) or summonInfo.id == 4002 then
        iGet = 6
    elseif next(summonInfo.item) then
        iGet = 5
        self:SetItemWay(summonInfo.item)
    elseif iStore == 2 then
        local compoundConfig = g_SummonCtrl:GetCopoundData()
        self.m_CompoundInfo = compoundConfig[summonInfo.id]
        if self.m_CompoundInfo then
            self:SetCompound()
        end
    elseif iStore == 1 then
        self.m_ShopBtn:SetText("前往宠物商店购买")
    elseif iStore == 3 then
        self.m_ShopBtn:SetText("前往商会购买")
    end
    self.m_ShopBtn:SetActive(iGet == 1 or iGet == 3)
    self.m_CompoundBox:SetActive(iGet == 2)
    self.m_ItemWayBox:SetActive(iGet == 5)
    self.m_PayBtn:SetActive(iGet == 4)
    self.m_SpcGetBox:SetActive(iGet == 6)
    self.m_ScheduleBtn:SetActive(iGet == 7)
    --self.m_HorzonL:SetActive(iGet ~= 2 and iGet ~= 6)
    local bShowL = true
    if iGet ~= 5 then
        self.m_ItemId = nil
    end
    if summonInfo.id == 1003 then
        bShowL = false
    elseif iGet == 6 then
        self.m_SpcGetBox:SetData(self.m_CurSummonId)
        bShowL = not self.m_SpcGetBox.m_IsLen
    end
    self.m_VertiL:SetActive(bShowL)
end

function CSummonGetWayBox.RefreshPayBtn(self)
    -- iBtnState: 1: 系统未开放 2 可充值 3 已充值
    local iBtnState = 0
    if g_OpenSysCtrl:GetOpenSysState(define.System.FirstPay) then
        local iState = g_WelfareCtrl:GetChargeItemInfo("first_pay_reward")
        if iState == 2 then
            iBtnState = 3
            self.m_PayBtn:SetSize(150, 58)
            self.m_PayBtn:SetText("已 获 取")
        else
            self.m_PayBtn:SetSize(215, 58)
            self.m_PayBtn:SetText("前往首充获取")
            iBtnState = 2
        end
    else
        iBtnState = 1
        self.m_PayBtn:SetText("前往首充获取")
    end
    self.m_PayState = iBtnState
end

----------------- Item ------------------
function CSummonGetWayBox.InitItemWayBox(self)
    local oBox = self.m_ItemWayBox
    oBox.m_ConvertBtn = oBox:NewUI(1, CButton)
    oBox.m_GetItemName = oBox:NewUI(2, CLabel)
    oBox.m_GetItemCount = oBox:NewUI(3, CLabel)
    oBox.m_GetItem = oBox:NewUI(4, CSprite)
    oBox.m_GetItemIcon = oBox:NewUI(5, CSprite)
    oBox.m_QualitySpr = oBox:NewUI(6, CSprite)

    oBox.m_ConvertBtn:AddUIEvent("click", callback(self, "OnClickItemBtn"))
    oBox.m_GetItem:AddUIEvent("click", callback(self, "OnItemTips"))
end

function CSummonGetWayBox.SetItemWay(self, dItem)
    if next(dItem) then
        self.m_ItemId = dItem.id
        self.m_ItemCnt = dItem.cnt
        self:RefreshItemWay()
    else
        self.m_ItemWayBox:SetActive(false)
    end
end

function CSummonGetWayBox.RefreshItemWay(self)
    local oBox = self.m_ItemWayBox
    local itemCnt = self.m_ItemCnt
    local itemId = self.m_ItemId
    local itemInfo = DataTools.GetItemData(itemId)
    local count = g_ItemCtrl:GetBagItemAmountBySid(itemId)
    oBox.m_GetItemName:SetText(string.format("%s兑换", itemInfo.name))
    oBox.m_GetItemCount:SetText(string.format("%s/%s", count, itemCnt))
    if count < itemCnt then
        oBox.m_GetItemCount:SetText(string.format("[D71420]%s/%s[-]", count, itemCnt))
    else
        oBox.m_GetItemCount:SetText(string.format("[1D8E00]%s/%s[-]", count, itemCnt))
    end
    oBox.m_GetItemIcon:SetSpriteName(tostring(itemInfo.icon))
    oBox.m_QualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( itemInfo.id, itemInfo.quality or 0 ) )
end

---------------------- Compound ---------------------
function CSummonGetWayBox.InitCompoundBox(self)
    local oBox = self.m_CompoundBox
    oBox.m_SchemeBtn = oBox:NewUI(1, CButton)
    oBox.m_Summon1 = oBox:NewUI(2, CSprite)
    oBox.m_Summon2 = oBox:NewUI(3, CSprite)
    oBox.m_Summon3 = oBox:NewUI(4, CSprite)
    -- oBox.m_CompoundBtn = oBox:NewUI(5, CButton)
    oBox.m_QualitySpr1 = oBox:NewUI(5, CSprite)
    oBox.m_QualitySpr2 = oBox:NewUI(6, CSprite)
    oBox.m_QualitySpr3 = oBox:NewUI(7, CSprite)

    oBox.m_SchemeBtn:AddUIEvent("click", callback(self, "OnClickSchemeBtn"))
    oBox.m_Summon1:AddUIEvent("click", callback(self, "OnClickSummonIcon", oBox.m_Summon1))
    oBox.m_Summon2:AddUIEvent("click", callback(self, "OnClickSummonIcon", oBox.m_Summon2))
    oBox.m_Summon3:AddUIEvent("click", callback(self, "OnClickSummonIcon", oBox.m_Summon3))
    -- oBox.m_CompoundBtn:AddUIEvent("click", callback(self, "OnClickCompound"))
end

function CSummonGetWayBox.SetCompound(self)
    local oBox = self.m_CompoundBox
    local summonId = self.m_CurSummonId
    local dCompound = self.m_CompoundInfo
    if summonId == 1003 then
        oBox.m_SchemeBtn:SetActive(true)
        self.m_CompoundType = 1
        self:RefreshCompoundScheme()
    else
        oBox.m_SchemeBtn:SetActive(false)
    end
    local summonInfo1 = data.summondata.INFO[dCompound.sid1]
    local summonInfo2 = data.summondata.INFO[dCompound.sid2]
    local summonInfo3 = data.summondata.INFO[dCompound.sid3]
    oBox.m_Summon1.id = summonInfo1.id
    oBox.m_Summon1:SpriteAvatar(tostring(summonInfo1.shape))
    oBox.m_Summon2.id = summonInfo2.id
    oBox.m_Summon2:SpriteAvatar(tostring(summonInfo2.shape))
    oBox.m_Summon3.id = summonInfo3.id
    oBox.m_Summon3:SpriteAvatar(tostring(summonInfo3.shape))
end

function CSummonGetWayBox.RefreshCompoundScheme(self)
    local oBox = self.m_CompoundBox
    if self.m_CompoundType == 1 then
        oBox.m_SchemeBtn:SetText("合成方案一")
        oBox.m_Summon1:SpriteAvatar(5111)
        oBox.id = 1001
    elseif self.m_CompoundType == 2 then
        oBox.m_SchemeBtn:SetText("合成方案二")
        oBox.m_Summon1:SpriteAvatar(5101)
        oBox.id = 1000
    end
end

---------------- events --------------------
function CSummonGetWayBox.OnClickSchemeBtn(self)
    if not self.m_CurSummonId then return end
    local iNpc = g_SummonCtrl:GetExchangeNpcId(self.m_CurSummonId)
    if iNpc then
        g_MapTouchCtrl:WalkToGlobalNpc(iNpc)
        CSummonMainView:CloseView()        
    end
end

function CSummonGetWayBox.OnClickShopBtn(self)
    local info = data.summondata.INFO[self.m_CurSummonId]
    if info.store == 1 then
        if g_AttrCtrl.grade < info.carry then
            g_NotifyCtrl:FloatMsg("需要达到可携带等级才能购买")
            return
        end
        CSummonStoreView:ShowView(function (oView)
            oView:SetSelectSummon(self.m_CurSummonId, info.carry)
        end)
    elseif info.store == 3 then
        if g_AttrCtrl.grade < info.carry then
            g_NotifyCtrl:FloatMsg("需要达到可携带等级才能购买")
            return
        end
        local summonItemID = DataTools.GetSummonItem(info.id)
        g_ViewCtrl:ShowViewBySysName("交易所", "商会", function(oView)
            --TODO:写死第二页跳转 宠物-元灵或者指定一个物品跳转
            -- oView.m_GuildPart:JumpToTargetCatalog(2, 2)
            oView:JumpToTargetItem(summonItemID)
        end)
    end
end

function CSummonGetWayBox.OnClickItemBtn(self)
    local itemId = self.m_ItemId
    if not itemId then return end
    local itemInfo = DataTools.GetItemData(itemId)
    local count = g_ItemCtrl:GetBagItemAmountBySid(itemId)
    if count < self.m_ItemCnt then
        g_NotifyCtrl:FloatMsg(itemInfo.name.."不足！")
        return
    end
    --兑换协议
    g_SummonCtrl:C2GSExchangeSummon(self.m_CurSummonId)
end

function CSummonGetWayBox.OnItemTips(self)
    g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemId)
end

function CSummonGetWayBox.OnClickSchemeBtn(self)
    if not self.m_CompoundInfo then return end
    self.m_CompoundType = self.m_CompoundType == 1 and 2 or 1
    self:RefreshCompoundScheme()
end

function CSummonGetWayBox.OnClickSummonIcon(self, oIcon)
    if not oIcon.id then
        return
    end
    local dInfo = SummonDataTool.GetSummonInfo(oIcon.id)
    g_SummonCtrl:OnEvent(define.Summon.Event.SelBookSummon, dInfo)
end

function CSummonGetWayBox.OnClickPayBtn(self)
    if 2 == self.m_PayState then
        CWelfareView:ShowView(function (oView)
            oView:ForceSelPage(define.WelFare.Tab.FirstPay)
        end)
        CSummonMainView:CloseView()
    elseif 1 == self.m_PayState then
        g_NotifyCtrl:FloatMsg("系统未开放")
    elseif 3 == self.m_PayState then
        g_NotifyCtrl:FloatMsg("你已经领取过首充奖励")
    end
end

function CSummonGetWayBox.OnClickCompound(self)
    if g_AttrCtrl.grade < info.carry then
        g_NotifyCtrl:FloatMsg("需要达到可携带等级才能合成")
        return
    end
    local oView = CSummonMainView:GetView()
    if oView then
       oView:ShowSubPageByIndex(2)
       oView.m_AdjustPart:OnCompoundShow()
    end
end

function CSummonGetWayBox.OnClickScheduleBtn(self)
    CScheduleMainView:ShowView()
    CSummonMainView:CloseView()
end

function CSummonGetWayBox.OnRefreshItem(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.AddBagItem or 
    oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
        if self.m_ItemId then
            self:RefreshItemWay()
        end
        if self.m_SpcGetBox:GetActive() then
            self.m_SpcGetBox:SetData(self.m_CurSummonId)
        end
    end
end

function CSummonGetWayBox.OnWelfareCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateFirstPayRedDot then
        self:RefreshPayBtn()
    end
end

return CSummonGetWayBox
local CRebateBox = class("CRebateBox", CBox)

function CRebateBox.ctor(self, cb)
    CBox.ctor(self, cb)
    self.m_RebateGrid = self:NewUI(1, CGrid)
    self.m_RebateItem = self:NewUI(2, CBox)
    self.m_RebateScrollView = self:NewUI(3, CScrollView)
    self.m_TipBox = self:NewUI(4, CBox)
    self.m_WoldLab = self:NewUI(5, CLabel)
    self:InitContent()
end


function CRebateBox.InitContent(self)
    self.m_SummonLinkData = {}
    self.m_HasInited = false
    self.m_RebateInfo = {}
    self.m_CurIdx = 0
    self.m_WoldLab:SetText(data.welfaredata.TEXT[1007].content)
    self.m_RebateItem:SetActive(false)
    self.m_TipBox:SetActive(false)
end

function CRebateBox.InitInfo(self)
    if self.m_HasInited then
        return
    end
    self.m_HasInited = true
    local dRebateInfo = DataTools.GetWelfareData("REBATE")
    if not dRebateInfo then return end
    for _, v in pairs(dRebateInfo) do
        table.insert(self.m_RebateInfo, v)
    end
    table.sort(self.m_RebateInfo, function(a, b)
        return a.goldcoin < b.goldcoin
    end)
    local iPayCnt = g_WelfareCtrl:GetChargeItemInfo("rebate_gold_coin")
    for i, dRebate in ipairs(self.m_RebateInfo) do
        -- 检查是否符合显示条件
        -- if dRebate.goldcoin >= 5000 then
            -- local state = g_WelfareCtrl:GetChargeItemInfo(dRebate.key)
            -- if state == define.WelFare.Status.Unobtainable then
                -- local dLastRebate = self.m_RebateInfo[i-1]
                -- if dLastRebate then
                --     local lastItemState = g_WelfareCtrl:GetChargeItemInfo(dLastRebate.key)
                --     if lastItemState ~= define.WelFare.Status.Got then
                --         break
                --     end
                -- end
            -- end
        -- end
        if dRebate.show_num > iPayCnt then
            break
        end
        self:CreateRebateItem(dRebate)
    end
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareCtrlEvent"))
end

function CRebateBox.CreateRebateItem(self, dInfo)
    if not dInfo then return end
    local oItem = self.m_RebateItem:Clone()
    oItem.slider = oItem:NewUI(1, CSlider)
    oItem.payL = oItem:NewUI(2, CLabel)
    oItem.rewardGrid = oItem:NewUI(3, CGrid)
    oItem.rewardItem = oItem:NewUI(4, CBox)
    oItem.getBtn = oItem:NewUI(5, CButton)
    oItem.btnL = oItem:NewUI(6, CLabel)
    oItem.getMarker = oItem:NewUI(7, CSprite)
    oItem.effWidget = oItem:NewUI(8, CWidget)
    oItem.rateL = oItem:NewUI(9, CLabel)
    oItem.rewardScroll = oItem:NewUI(10, CScrollView)

    oItem.rewardItem:SetActive(false)
    oItem.getBtn:AddUIEvent("click", callback(self, "OnClickGetReward", dInfo.key))

    oItem:SetActive(true)
    self.m_RebateGrid:AddChild(oItem)
    self.m_CurIdx = self.m_CurIdx + 1
    self:SetRebateItemInfo(oItem, dInfo)
end

function CRebateBox.SetRebateItemInfo(self, oItem, dInfo)
    oItem.idx = self.m_CurIdx
    self:SetRebateItemSlider(oItem, dInfo)
    local state = g_WelfareCtrl:GetChargeItemInfo(dInfo.key)
    self:SetRebateBtnState(oItem, state)
    self:SetRebateRewardInfo(oItem, dInfo.gift)
    self:SetRebateTipBtn(oItem, dInfo)
end

function CRebateBox.SetRebateItemSlider(self, oItem, dInfo)
    local iPayCnt = g_WelfareCtrl:GetChargeItemInfo("rebate_gold_coin")
    iPayCnt = math.min(iPayCnt, dInfo.goldcoin)
    oItem.slider:SetValue(iPayCnt/dInfo.goldcoin)
    oItem.rateL:SetText(string.format("%d/%d", iPayCnt, dInfo.goldcoin))
    oItem.effWidget:SetActive(iPayCnt > 0 and iPayCnt < dInfo.goldcoin)
    oItem.payL:SetText(string.format("累计充值%d元宝",dInfo.goldcoin))
end

function CRebateBox.SetRebateBtnState(self, oItem, state)
    local bGot = state == define.WelFare.Status.Got
    oItem.getBtn:SetActive(not bGot)
    oItem.getMarker:SetActive(bGot)

    local showRedPoint = false
    if not bGot then
        local bEnable = state == define.WelFare.Status.Get
        showRedPoint = bEnable
        oItem.getBtn:SetEnabled(bEnable)
    end

    if showRedPoint then
        oItem.getBtn:AddEffect("RedDot", 20, Vector2.New(-20, -16))
    else
        oItem.getBtn:DelEffect("RedDot")
    end
end

function CRebateBox.SetRebateRewardInfo(self, oItem, iGift)
    local dGiftInfo = table.copy(DataTools.GetReward("WELFARE", iGift))
    if not dGiftInfo then return end
    if #dGiftInfo.item <= 3 then
        oItem.rewardGrid:SetParent(oItem.m_Transform, true)
        local dragCpn = oItem.rewardItem:GetComponent(classtype.UIDragScrollView)
        dragCpn.scrollView = self.m_RebateScrollView.m_UIScrollView
        oItem.rewardScroll:SetActive(false)
    end
    local itemsumList = {}
    for i,v in ipairs(dGiftInfo.item) do
        v.sidtype = "item"
        table.insert(itemsumList, v)
    end
    for i,v in ipairs(dGiftInfo.summon) do
        v.sidtype = "sum"
        table.insert(itemsumList, v)
    end
    if string.len(dGiftInfo.ride)>0 then
        local v = {}
        v.sid  = dGiftInfo.ride
        v.sidtype = "ride"
        table.insert(itemsumList, v)
    end
    --宠物和物品奖励集中
    for idx, info in ipairs(itemsumList) do
        local oReward = oItem.rewardItem:Clone()
        oReward:SetActive(true)
        oItem.rewardGrid:AddChild(oReward)
        self:InitRewardItem(oReward, info)
    end
end

function CRebateBox.SetRebateTipBtn(self, oItem, dInfo)
    if string.len(dInfo.tip_icon) == 0 then
        return
    end
    local oTip = self.m_TipBox:Clone()
    oTip:SetActive(true)
    oTip.icon = oTip:NewUI(1, CSprite)
    oItem.rewardGrid:AddChild(oTip)
    local iIcon = tonumber(dInfo.tip_icon)
    if iIcon then
        oTip.icon:SpriteItemShape(iIcon)
    else
        oTip.icon:SetSpriteName(dInfo.tip_icon)
    end
    local dTipInfo = {title = dInfo.tip_title or "", desc = dInfo.tip_text or ""}
    oTip:AddUIEvent("click", callback(self, "OnClickTip", dTipInfo))
end

function CRebateBox.InitRewardItem(self, oItem, info)
    if info.sidtype =="item" then --物品
        local dItemData = DataTools.GetItemData(info.sid)
        if dItemData then
            oItem.iconSpr = oItem:NewUI(1, CSprite)
            oItem.qualitySpr = oItem:NewUI(2, CSprite)
            oItem.cntL = oItem:NewUI(3, CLabel)
            oItem.itemId = info.sid

            oItem.iconSpr:SpriteItemShape(dItemData.icon)
            oItem.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dItemData.id, dItemData.quality or 0 ))
            oItem.cntL:SetText(info.amount)
            oItem:AddUIEvent("click", callback(self, "OnClickItem"))
        end
    elseif  info.sidtype =="sum"  then --宠物 
        local dsumData = data.summondata.INFO[info.sid]
        if  dsumData then
            oItem.iconSpr = oItem:NewUI(1, CSprite)
            oItem.qualitySpr = oItem:NewUI(2, CSprite)
            oItem.cntL = oItem:NewUI(3, CLabel)
            oItem.iconSpr:SpriteAvatar(dsumData.shape)
            oItem.cntL:SetActive(false)
            oItem.qualitySpr:SetActive(false)
            oItem:AddUIEvent("click", callback(self, "OnClickSum", dsumData.id))
        end

    elseif info.sidtype =="ride"   then
        local dridedata = data.ridedata.RIDEINFO[tonumber(info.sid)]
        if dridedata then
            oItem.iconSpr = oItem:NewUI(1, CSprite)
            oItem.qualitySpr = oItem:NewUI(2, CSprite)
            oItem.cntL = oItem:NewUI(3, CLabel)
            oItem.iconSpr:SpriteAvatar(dridedata.shape)
            oItem.cntL:SetActive(false)
            oItem.qualitySpr:SetActive(false)
            oItem:AddUIEvent("click", callback(self, "OnClickRide", dridedata.id))
        end
    end
end

function CRebateBox.OnClickItem(self, oItem)
    local config = {widget = oItem}
    g_WindowTipCtrl:SetWindowItemTip(oItem.itemId, config)
end

function CRebateBox.OnClickSum(self, sid)
    -- body
    local oView = CSummonMainView:ShowView(function( oView )
        -- body
        oView:ShowSubPageByIndex(3)
        local dSumInfo = data.summondata.INFO[sid]
        oView.m_DetailPart:OnSelSummon(dSumInfo)
    end)
end


function CRebateBox.OnClickRide(self, rideid)
    -- body
   if g_OpenSysCtrl:GetOpenSysState("RIDE_SYS") then
        local oView = CHorseMainView:ShowView(function (oView)
            -- body
            oView:ShowSpecificPart(3)
            oView:ChooseDetailPartHorse(rideid)
        end)
    else
        local str = data.welfaredata.TEXT[1006].content
        local sysop = data.opendata.OPEN["RIDE_SYS"].p_level
        local sys = data.opendata.OPEN["RIDE_SYS"].name
        str = string.gsub(str,"#grade",tostring(sysop))
        str = string.gsub(str,"#name",sys)
        g_NotifyCtrl:FloatMsg(str)
    end 
end

function CRebateBox.GetRebateItemByKey(self, sKey)
    for k, v in ipairs(self.m_RebateInfo) do
        if v.key == sKey then
            local oItem = self.m_RebateGrid:GetChild(k)
            return oItem, k
        end
    end
end

function CRebateBox.UpdateAllItemSlider(self)
    for i, oItem in ipairs(self.m_RebateGrid:GetChildList()) do
        local dInfo = self.m_RebateInfo[oItem.idx]
        if dInfo then
            self:SetRebateItemSlider(oItem, dInfo)
        end
    end
end

function CRebateBox.CheckRebateItems(self, iPayCnt)
    if not iPayCnt then
        iPayCnt = g_WelfareCtrl:GetChargeItemInfo("rebate_gold_coin")
    end
    for i = self.m_CurIdx+1, #self.m_RebateInfo do
        local info = self.m_RebateInfo[i]
        if info and info.show_num <= iPayCnt then
            self:CreateRebateItem(info)
        else
            break
        end
    end
end

function CRebateBox.OnClickGetReward(self, sKey)
    nethuodong.C2GSRewardWelfareGift("rebate", sKey)
end

function CRebateBox.OnClickTip(self, dInfo)
    g_WindowTipCtrl:SetWindowInstructionInfo(dInfo)
end

function CRebateBox.OnWelfareCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateRebatePnl then
        local iCurVal, sLastKey
        if self.m_RebateInfo[self.m_CurIdx] then
            sLastKey = self.m_RebateInfo[self.m_CurIdx].key
        end
        for _, dInfo in ipairs(oCtrl.m_EventData) do
            if dInfo.key == "rebate_gold_coin" then
                -- printc(dInfo.key)
                self:CheckRebateItems(dInfo.val)
            else
                local oItem, iCurIdx = self:GetRebateItemByKey(dInfo.key)
                if oItem then
                    self:SetRebateBtnState(oItem, dInfo.val)
                end
                if dInfo.key == sLastKey then
                    iCurVal = dInfo.val
                end
            end
        end
        -- if iCurVal and iCurVal == define.WelFare.Status.Got then
        --     self:CreateRebateItem(self.m_RebateInfo[self.m_CurIdx + 1])
        -- end
        self:UpdateAllItemSlider()
    end
end

return CRebateBox
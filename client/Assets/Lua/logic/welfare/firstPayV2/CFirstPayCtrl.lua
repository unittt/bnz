local CFirstPayCtrl = class("CFirstPayCtrl", CCtrlBase)

function CFirstPayCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self.m_KeyDict = {
        [1] = "first_gift",
        [2] = "first_gift_second",
        [3] = "first_gift_third",
    }
    self:Clear()
end

function CFirstPayCtrl.Clear(self)
    self.m_HasClickTab = false
    self.m_Info = {}
    self.selIdx = nil
end

function CFirstPayCtrl.HasRedPoint(self)
    if not self:IsShow() then
        return false
    end
    if self:HasReward() then
        return true
    else
        return not self.m_HasClickTab
    end
end

function CFirstPayCtrl.HasReward(self)
    for i = 1, 3 do
        local iStatus = self:GetChargeStatus(i)
        if iStatus == 1 then
            return true
        end
    end
    return false
end

function CFirstPayCtrl.HasRewardAll(self)
    for i = 1, 3 do
        local iStatus = self:GetChargeStatus(i)
        if iStatus ~= 2 then
            return false
        end
    end
    return true
end

function CFirstPayCtrl.HasPay(self)
    local iStatus = self:GetChargeStatus(1)
    return iStatus ~= 0
end

function CFirstPayCtrl.IsShow(self)
    if not g_OpenSysCtrl:GetOpenSysState(define.System.FirstPay) then
        return false
    elseif self:HasRewardAll() then
        return false
    end
    return true
end

function CFirstPayCtrl.GetRewardInfo(self, idx, sGift)
    idx = idx or 1
    sGift = sGift or "gift_1"
    local sKey = self.m_KeyDict[idx]
    local dConfig = sKey and DataTools.GetWelfareData("FIRSTPAY", sKey)
    if not dConfig then return end
    local iReward = dConfig[sGift]
    local dReward = iReward and DataTools.GetReward("WELFARE", iReward)
    return dReward and table.copy(dReward)
end

function CFirstPayCtrl.ConvertRewardInfo(self, dReward)
    local lRewards = {}
    local gold = tonumber(dReward.gold)
    local goldCoin = tonumber(dReward.goldcoin)
    local silver = tonumber(dReward.silver)
    if gold and gold > 0 then
        table.insert(lRewards, {id = 1001, cnt = gold})
    end
    if silver and silver > 0 then
        table.insert(lRewards, {id = 1002, cnt = silver})
    end
    if goldCoin and goldCoin > 0 then
        table.insert(lRewards, {id = 1004, cnt = goldCoin})
    end
    for _, itemR in ipairs(dReward.item) do
        local id = itemR.sid
        if itemR.type and itemR.type > 0 then
            id = DataTools.GetItemFiterResult(id, g_AttrCtrl.roletype, g_AttrCtrl.sex)
        end
        table.insert(lRewards, {id = id, cnt = itemR.amount})
    end
    return lRewards
end

function CFirstPayCtrl.ConvertExtraReward(self, dReward)
    local lRewards = {}
    local summons = dReward.summon
    if summons and next(summons) then
        local iSummon = tonumber(summons[1].idx)
        local dSummon = DataTools.GetSummonInfo(iSummon)
        if dSummon then
            table.insert(lRewards, {
                avatar = dSummon.shape,
                name = dSummon.name,
            })
        end
    end
    local sPartner = dReward.partner
    if sPartner and string.len(sPartner) > 0 then
        local dPartner = DataTools.GetPartnerInfo(tonumber(sPartner))
        if dPartner then
            table.insert(lRewards, {
                avatar = dPartner.shape,
                name = dPartner.name,
            })
        end
    end
    for _, reward in ipairs(dReward.item) do
        local itemId = reward.sid
        if reward.type and reward.type > 0 then
            itemId = DataTools.GetItemFiterResult(itemId, g_AttrCtrl.roletype, g_AttrCtrl.sex)
        end
        local itemInfo = DataTools.GetItemData(itemId)
        if itemInfo then
            table.insert(lRewards, {
                icon = itemInfo.icon,
                item = itemId,
                cnt = reward.amount,
                quality = itemInfo.quality,
            })
        end
    end
    return lRewards
end

function CFirstPayCtrl.HasExtraReward(self, idx)
    local iCreate, iEnd = self:GetExtraRewardTime(idx)
    if iCreate then
        local iCur = g_TimeCtrl:GetTimeS()
        return iCur < iEnd
    end
    return false
end

function CFirstPayCtrl.GetExtraRewardTime(self, idx)
    local iCreateTime = self:GetCreateTime(idx)
    if iCreateTime then
        local iDay = self:GetExtraGiftDay(idx) or 0
        local iEnd = iCreateTime + iDay * 24 * 3600
        return iCreateTime, iEnd
    end
end

function CFirstPayCtrl.GetExtraTimeText(self, idx)
    local iCreate, iEnd = self:GetExtraRewardTime(idx)
    if iCreate then
        -- local sBegin = os.date("%m.%d", iCreate)
        -- if string.sub(sBegin, 1, 1) == "0" then
        --     sBegin = string.sub(sBegin, 2, -1)
        -- end
        -- local sEnd = os.date("%m.%d", iEnd)
        -- if string.sub(sEnd, 1, 1) == "0" then
        --     sEnd = string.sub(sEnd, 2, -1)
        -- end
        -- return string.format("%s-%s", sBegin, sEnd)
        local iLeft = iEnd - g_TimeCtrl:GetTimeS()
        if iLeft <= 0 then
            return
        end
        local day = math.floor(iLeft / (3600 * 24), true) 
        local hour = math.floor((iLeft / 3600) % 24, true)
        local min = math.ceil((iLeft / 60) % 60, true)
        if min == 60 then
            min = 0
            hour = hour + 1
            if hour == 24 then
                hour = 0
                day = day + 1
            end
        end
        if day > 0 then
            if hour > 0 then
                return string.format("%d天%d小时内", day, hour)
            else
                return string.format("%d天内", day)
            end
        else
            if hour > 0 then
                if min == 0 then
                    return string.format("%d小时", hour)
                end
                return string.format("%d小时%d分钟内", hour, min)
            else
                min = math.max(min, 1)
                return string.format("%d分钟内", min)
            end
        end
    end
end

function CFirstPayCtrl.GetExtraGiftDay(self, idx)
    local sKey = self.m_KeyDict[idx]
    if not sKey then return end
    local dConfig = DataTools.GetWelfareData("FIRSTPAY", sKey)
    return dConfig and dConfig.gift_day
end

function CFirstPayCtrl.GetChargeStatus(self, idx)
    local dCharge = self:GetChargeInfo(idx)
    local iStatus = dCharge and dCharge.reward
    iStatus = iStatus or 0
    return iStatus
end

function CFirstPayCtrl.GetCreateTime(self, idx)
    local dCharge = self:GetChargeInfo(idx)
    return dCharge and dCharge.create_time
end

function CFirstPayCtrl.GetChargeInfo(self, idx)
    idx = idx or 1
    return self.m_Info[idx]
end

function CFirstPayCtrl.SetHasClickTab(self)
    self.m_HasClickTab = true
    g_WelfareCtrl:OnEvent(define.WelFare.Event.UpdateFirstPayRedDot)
end

function CFirstPayCtrl.GetNeedCharge(self, idx)
    local sKey = self.m_KeyDict[idx]
    local dConfig = sKey and DataTools.GetWelfareData("FIRSTPAY", sKey)
    if dConfig then
        local iNeed = math.max(dConfig.pay-(self.m_Info.store_charge_rmb or 0), 0)
        return iNeed
    end
    return 0
end

function CFirstPayCtrl.UpdateAllInfo(self, dAll)
    self:UpdateInfo(1, dAll.first_pay_gift)
    self:UpdateInfo(2, dAll.first_pay_gift_second)
    self:UpdateInfo(3, dAll.first_pay_gift_third)
    local iCharge = dAll.store_charge_rmb
    if iCharge then
        self.m_Info.store_charge_rmb = iCharge
    end
    g_WelfareCtrl:UpdateFirstPay()
end

function CFirstPayCtrl.UpdateInfo(self, key, infoList)
    if not infoList then
        return
    end
    local t = self.m_Info[key]
    if not t then
        t = {}
        self.m_Info[key] = t
    end
    for _, d in ipairs(infoList) do
        local k, v = d.key, d.val
        if string.find(k, "pay_reward") then
            k = "reward"
        elseif string.find(k, "pay_extra") then
            k = "extra"
        end
        t[k] = v
    end
end

return CFirstPayCtrl
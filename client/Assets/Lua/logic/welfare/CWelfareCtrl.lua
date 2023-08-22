local CWelfareCtrl = class("CWelfareCtrl", CCtrlBase)

function CWelfareCtrl.ctor(self)
	CCtrlBase.ctor(self)
    self:InitTabConfig()
    self:Clear()
    -- 关闭系统表
    self.m_BanSys = {
        -- "RebateExplain",
        -- "Exchange",
    }
end

function CWelfareCtrl.Clear(self)
    self.m_WelfareReturnGiftData = {}
    self.m_ColorfulData = {}
    self.m_ChargeInfo = {}
    self.m_ChargeDayDict = {}
    self.m_CollectGiftInfo = {giftList = {}}
    self.m_ColorfulLamp = {}
    self:InitChargeFuncDict()
    self.m_HasClickDailyTab = false
    self.m_HasClickFirstPayTab = false
    self.m_HasClickGoinGiftTab = false
    self.m_OpenCollectKey = nil
    self.m_YoukaLoginTimer = nil

    self.m_FightGiftBagDict = {}
end

function CWelfareCtrl.InitTabConfig(self)
    -- local list = data.sortdata.WELFARE
    -- for k, v in pairs(list) do
    --     local sys = DataTools.GetSysName(k)
    --     if sys then
    --         table.insert(self.m_huodongConfig, {key = sys, idx = v})
    --     end
    -- end
    self.m_huodongConfig = {}
    local tab = data.sortdata.WELFARE
    for k, v in pairs(tab) do
        local sname = DataTools.GetSysName(k)
        -- 根据表重置define的映射
        define.WelFare.Tab[sname] = v
        table.insert(self.m_huodongConfig, {key = sname, idx = v})
    end

    -- local tab = define.WelFare.Tab
    -- for k, v in pairs(tab) do
    --     table.insert(self.m_huodongConfig, {key = k, idx = v})
    -- end

    table.sort(self.m_huodongConfig, function(a, b)
        return a.idx < b.idx
    end)
end

function CWelfareCtrl.InitChargeFuncDict(self)
    local dGiftInfo =
    {
        DAILY = "UpdateDailyPnl",
        BIGPROFIT = "UpdateBigProfitPnl",
        YUANBAO = "UpdateYuanbaoPnl",
    }
    self.m_ChargeUpdateFuncDict = {}
    for sType in pairs(dGiftInfo) do
        local info = DataTools.GetChargeData(sType)
        if info then
            for key in pairs(info) do
                self.m_ChargeUpdateFuncDict[key] = dGiftInfo[sType]
            end
        end
    end
    -- self.m_ChargeUpdateFuncDict["first_pay_reward"] = "UpdateFirstPay"
    self.m_ChargeUpdateFuncDict["second_pay_reward"] = "UpdateSecondPay"
end

function CWelfareCtrl.ShowGiftGoldcoin(self)
    CWelfareView:ShowView(function(oView )
        -- body
        oView:ForceSelPage(define.WelFare.Tab.GiftGoldcoin)
    end)
end

 --是否有小红点(福利界面下的所有小红点)
 function CWelfareCtrl.IsHadRedPoint(self)
 	local isPackRedPointShow = g_UpgradePacksCtrl:IsHadRedPoint()
 	if isPackRedPointShow then
        return true
    elseif g_SignCtrl:IsHadRedPoint() then
        return true
    elseif self:IsHadDailyRedPoint() then
        return true
    elseif self:IsHadYuanbaoRedPoint() then
        return true
    elseif self:IsHadGradeRedPoint() then
        return true
    elseif self:IsHadFirstPayRedPoint() then
        return true
    -- elseif self:IsHadCollectRedPoint() then
    --     return true
    elseif self:IsHadReturnGiftRedPoint() then
        return true
    elseif self:IsHadReturnYoukaLoginRedPoint() then
        return true
    elseif g_OnlineGiftCtrl:IsHasRedPoint() then
        return true
    elseif self:IsHasFightGiftRedPoint() then
        return true
    elseif self:IsHadSecondPayRedPoint() then
        return true
    elseif self:IsHasExpRecycleRedDot() then
        return true
    end
    return false
 end

function CWelfareCtrl.IsHadDailyRedPoint(self)
    local bHas = false
    if not g_OpenSysCtrl:GetOpenSysState("GIFT_DAY") or self:IsGetAllDailyReward() then
        return bHas
    end
    if not self.m_HasClickDailyTab then
        for key in pairs(DataTools.GetChargeData("DAILY")) do
            local val = self.m_ChargeInfo[key]
            if val and val == define.WelFare.Status.Unobtainable then
                bHas = true
                break
            end
        end
    end
    return bHas
end

function CWelfareCtrl.IsHadYuanbaoRedPoint(self)
    if not g_OpenSysCtrl:GetOpenSysState("GIFT_GOLDCOIN") then
        return false
    elseif not self.m_HasClickGoinGiftTab then
        return true
    end
    local bHas = false
    for key in pairs(DataTools.GetChargeData("YUANBAO")) do
        local val = self.m_ChargeInfo[key]
        if val and val == define.WelFare.Status.Get then
            bHas = true
            break
        end
    end
    return bHas
end

function CWelfareCtrl.IsHadGradeRedPoint(self)
    return g_BigProfitCtrl:IsHadRedPoint()
end

function CWelfareCtrl.IsHadFirstPayRedPoint(self)
    return g_FirstPayCtrl:HasRedPoint()
end

function CWelfareCtrl.IsHadSecondPayRedPoint(self)
    if not g_OpenSysCtrl:GetOpenSysState(define.System.SecondPay) then
        return false
    end

    local state = self:GetChargeItemInfo("second_pay_reward")
    return state == 1
end

function CWelfareCtrl.IsHasExpRecycleRedDot(self)
    return g_ExpRecycleCtrl:HasRedDot()
end

function CWelfareCtrl.IsHadCollectRedPoint(self)
    if not g_OpenSysCtrl:GetOpenSysState(define.System.CollectGift) then
        return false
    end
    local status = self.m_CollectGiftInfo.status
    if status and status == 1 then
        local dTopInfo
        local iKey = self.m_CollectGiftInfo.key
        local dGiftConfig = DataTools.GetCollectData("GIFT")
        for key, info in pairs(dGiftConfig) do
            if info.collect_key == iKey and (not dTopInfo or #dTopInfo.cost_item < #info.cost_item) then
                dTopInfo = info
            end
        end
        -- 最高项满足兑换条件
        if dTopInfo and self:CheckCollectItemExchange(dTopInfo.key) then
            return true
        end
    end
    return false
end

function CWelfareCtrl.IsHadReturnGiftRedPoint(self)
    if not g_OpenSysCtrl:GetOpenSysState(define.System.ReturnGift) then
        return false
    end
    return self:CheckReturnGiftRedPoint()
end

function CWelfareCtrl.IsHadReturnYoukaLoginRedPoint(self)
    local oCanReward  = false --红点 
    if next(self.m_ColorfulData) then
        for i,v in ipairs(self.m_ColorfulData) do
            if v.val == 1 then
                oCanReward = true
                break
            end
        end
    end
    local info = data.opendata.OPEN.WELFARE_LOGIN
    if g_AttrCtrl.grade < info.p_level or info.open_sys~=1 then
        oCanReward = false
    end    
    return oCanReward
end
--是否有开启的活动
 function CWelfareCtrl.IsHadOpenHuodong(self)
 	
 	local huodong = self:GetOpenHuodong()

 	local isHad = false

 	if #huodong > 0 then 

 		isHad = true

 	end

 	return isHad

 end

function CWelfareCtrl.GetViewOpenData(self, sView)
    -- 屏蔽的系统
    if table.index(self.m_BanSys, sView) then
        return
    end
    local sSysKey = define.System[sView]
    if sSysKey then
        local dOpenData = DataTools.GetViewOpenData(sSysKey)
        if dOpenData then
            dOpenData = table.copy(dOpenData)
            if sView == "GiftGrade" and g_BigProfitCtrl:GetGradePnlLevel() == 2 then
                dOpenData.name = "一本万利贰"
            end
        end
        return dOpenData
    end
end

function CWelfareCtrl.GetUnLockViewData(self, sView)
    if sView == "CollectGift" then
        local status = self.m_CollectGiftInfo.status
        if status and status == 1 then
            return {name = "集字换礼",}
        end
    elseif sView == "GiftGrade2" then
        return {name = "一本万利贰"}
    end
end

--为方便支持导表排序，原本有的define.Welfare.Tab的数据不在使用，改有sortdata表
function CWelfareCtrl.GetTabInfo(self)
    local tabinfo = {}
    local tab = define.WelFare.Tab
    local sortConfig = data.sortdata.WELFARE
    local dSystem = define.System
    for k, v in pairs(tab) do
        local sSysKey = dSystem[k]
        local idx = sortConfig[sSysKey]
        tabinfo[k] = idx
    end
    return tabinfo
end

--获取已开启活动列表
 function CWelfareCtrl.GetOpenHuodong(self)
 	local openHuodongList = {}
 	for k , v in ipairs(self.m_huodongConfig) do
        local dOpenData = self:GetViewOpenData(v.key)
        if dOpenData then
            --if g_AttrCtrl.grade >= v.openLevel then 
            if g_OpenSysCtrl:GetOpenSysState(dOpenData.stype) then
                local bOpen = true
                -- if v.key == "GiftDay" and self:IsGetAllDailyReward() then
                --     bOpen = false
                -- else
                if v.key == "FirstPay" then
                    bOpen = g_FirstPayCtrl:IsShow()
                elseif v.key == "SecondPay" then
                    if not g_FirstPayCtrl:HasPay() or self.m_ChargeInfo.second_pay_reward == 2 then
                        bOpen = false
                    end
                -- elseif v.key == "CollectGift" then
                --     local status = self.m_CollectGiftInfo.status
                --     if not status or status == 0 then
                --         bOpen = false
                --     end
                elseif v.key == "CaiShen" then
                    bOpen = g_LotteryCtrl:IsCaishenOpen()
                elseif v.key =="YoukaLogin" then
                   if not next(self.m_ColorfulData) then
                        bOpen = false --领取完毕后取消显示
                   end
                elseif v.key == "ReturnGift" then
                    if next(g_WelfareCtrl.m_WelfareReturnGiftData) then
                        local oData = g_WelfareCtrl.m_WelfareReturnGiftData
                        if oData.cbtpay <= 0 then
                            bOpen = false
                        elseif oData.cbtpay > 0 and not g_WelfareCtrl:CheckReturnGradeIsNotGet() and oData.free_gift ~= 0 
                        and (oData.gift_1_buy ~= 0 or (g_TimeCtrl:GetTimeS() - oData.gift_1_time) > 0)
                        and (oData.gift_2_buy ~= 0 or (g_TimeCtrl:GetTimeS() - oData.gift_2_time) > 0) then
                            bOpen = false
                        end
                    else
                        bOpen = false
                    end
                elseif v.key == "OnlineGift" then
                    bOpen = g_OnlineGiftCtrl:IsOnlineGiftOpen()
                elseif v.key == "FightGift" then
                    bOpen = self:IsHasFightGiftOpen()  --test--
                elseif v.key == "UpgradePack" then
                    bOpen = self:IsHasUpgradePackOpen()
                elseif v.key == "ExpRecycle" then
                    bOpen = g_ExpRecycleCtrl:IsShow()
                end
                if bOpen then
                    local info = {idx = v.idx, key = v.key}
                    table.insert(openHuodongList, info)
                end
     		end
        else
            dOpenData = self:GetUnLockViewData(v.key)
            if dOpenData then
                local info = {idx = v.idx, key = v.key}
                table.insert(openHuodongList, info)
            end
        end
 	end 

 	return openHuodongList

 end

function CWelfareCtrl.UpdateYuanbaoPnl(self, lChargeInfo)
    if not self.m_HasClickGoinGiftTab then
        for _, v in ipairs(lChargeInfo) do
            if v.val ~= define.WelFare.Status.Unobtainable then
                self.m_HasClickGoinGiftTab = true
                break
            end
        end
    end
    self:OnEvent(define.WelFare.Event.UpdateYuanbaoPnl, lChargeInfo)
end

function CWelfareCtrl.UpdateDailyPnl(self, lChargeInfo)
    self:OnEvent(define.WelFare.Event.UpdateDailyPnl, lChargeInfo)
end

function CWelfareCtrl.IsGetAllDailyReward(self)
    local bGetAll = true
    for key in pairs(DataTools.GetChargeData("DAILY")) do
        if key == "gift_day_all" then
            if 1 ~= self.m_ChargeInfo[key] then
                bGetAll = false
                break
            end
        elseif self.m_ChargeInfo[key] ~= define.WelFare.Status.Got then
            bGetAll = false
            break
        end
    end
    return bGetAll
end

function CWelfareCtrl.IsCanBuyAllDaily(self)
    local bCan = true
    -- for key in pairs(DataTools.GetChargeData("DAILY")) do
    --     if self.m_ChargeInfo[key] ~= define.WelFare.Status.Unobtainable then
    --         bCan = false
    --         break
    --     end
    -- end
    bCan = 0==self:GetChargeItemInfo("gift_day_all")
    return bCan
end

function CWelfareCtrl.UpdateBigProfitPnl(self, lChargeInfo)
    g_BigProfitCtrl:UpdatePnl(lChargeInfo)
end

function CWelfareCtrl.UpdateFirstPay(self)
    self:OnEvent(define.WelFare.Event.UpdateFirstPayRedDot)
    self:OnEvent(define.WelFare.Event.UpdateFirstPayPnl)
end

function CWelfareCtrl.UpdateSecondPay(self)
    self:OnEvent(define.WelFare.Event.RefreshSecondPay)
end

function CWelfareCtrl.UpdateRebate(self, lRebateInfo)
    self:OnEvent(define.WelFare.Event.UpdateRebatePnl, lRebateInfo)
end

function CWelfareCtrl.UndateYoukaLogin(self, data)
    -- 登陆、领取 时，都会 刷新红点，图标状态
    self.m_ColorfulData = data
    self:IsHideYoukaIcon() -- 图标
    self:IsHadReturnYoukaLoginRedPoint() --红点
    self:OnEvent(define.WelFare.Event.UpdataColorLamp, data)
end

function CWelfareCtrl.GetChargeItemInfo(self, key)
    return self.m_ChargeInfo[key] or 0
end

function CWelfareCtrl.GetChargeItemDays(self, key)
    return self.m_ChargeDayDict[key] or 0
end

function CWelfareCtrl.SetHasClickDailyTab(self)
    self.m_HasClickDailyTab = true
    self:OnEvent(define.WelFare.Event.UpdateDailyRedDot)
end

function CWelfareCtrl.SetHasClickFirstPayTab(self)
    self.m_HasClickFirstPayTab = true
    self:OnEvent(define.WelFare.Event.UpdateFirstPayRedDot)
end

function CWelfareCtrl.SetHasClickGoldGiftTab(self)
    self.m_HasClickGoinGiftTab = true
    if not self:IsHadYuanbaoRedPoint() then
        self:OnEvent(define.WelFare.Event.UpdateYuanbaoPnl)
    end
end

function CWelfareCtrl.GetGoldCoinBanId(self)
    -- return "goldcoin_gift_2"
end

-- 更新单项充值信息
function CWelfareCtrl.GS2CChargeRefreshUnit(self, chargeUnit)
    local key, val = chargeUnit.key, chargeUnit.val
    self.m_ChargeInfo[key] = val
    self.m_ChargeDayDict[key] = chargeUnit.days
    local func = self.m_ChargeUpdateFuncDict[key]
    if func then
        local chargeInfo = {chargeUnit}
        self[func](self, chargeInfo)
    end
end

-- 更新全部充值信息
function CWelfareCtrl.UpdateAllGiftInfo(self, giftInfo)
    local lGiftInfo =
    {
        {func = "UpdateDailyPnl", info = giftInfo.gift_day_list},
        {func = "UpdateBigProfitPnl", info = giftInfo.gift_grade_list},
        {func = "UpdateYuanbaoPnl", info = giftInfo.gift_goldcoin_list},
        -- {func = "UpdateFirstPay", info = giftInfo.first_pay_gift},
        {func = "UpdateSecondPay", info = giftInfo.second_pay_gift},
        {func = "UpdateRebate", info = giftInfo.rebate_gift},
        {func = "UndateYoukaLogin", info = giftInfo.login_gift},
    }
    for _, dict in pairs(lGiftInfo) do
        if dict.info then
            for _, v in pairs(dict.info) do
                if not v.val then
                    v.val = 0
                end
                self.m_ChargeInfo[v.key] = v.val
                self.m_ChargeDayDict[v.key] = v.days
            end
            if dict.func then
                self[dict.func](self, dict.info)
            end
        end
    end
end

function CWelfareCtrl.GetCollectGiftInfo(self, iItemKey)
    local status = self.m_CollectGiftInfo.status
    if not status or status == 0 then return end
    local dInfo = self.m_CollectGiftInfo.giftList
    if iItemKey then
        return dInfo[iItemKey] or 0
    else
        return dInfo
    end
end

function CWelfareCtrl.GetCollectGiftStatus(self)
    return self.m_CollectGiftInfo.status
end

function CWelfareCtrl.CheckCollectItemExchange(self, key)
    local bState = false
    local dConfig = DataTools.GetCollectData("GIFT", key)
    if not dConfig then return bState end
    local iCnt = self.m_CollectGiftInfo.giftList[key] or 0
    if dConfig.redeem_num - iCnt > 0 then
        bState = true
        for i, v in ipairs(dConfig.cost_item) do
            local iAmount = g_ItemCtrl:GetBagItemAmountBySid(v.sid)
            if iAmount < v.num then
                bState = false
                break
            end
        end
    end
    return bState
end

function CWelfareCtrl.IsCollectOpen(self)
    local bOpen = false
    local status = self.m_CollectGiftInfo.status
    if status and status > 0 then
        bOpen = true
    end
    return bOpen
end

function CWelfareCtrl.GS2CCollectGiftInfo(self, collectInfo)
    for _, info in ipairs(collectInfo) do
        local key = info.collect_key
        self.m_CollectGiftInfo.key = key
        self.m_CollectKey = key
        if key then
            self.m_CollectGiftInfo.status = 1
            self.m_CollectGiftInfo.giftList = {}
            for i, v in ipairs(info.gift_list) do
                self.m_CollectGiftInfo.giftList[v.key] = v.val or 0
            end
            self.m_CollectGiftInfo.start_time = info.start_time
            self.m_CollectGiftInfo.end_time = info.end_time
            self:OnEvent(define.WelFare.Event.UpdateCollectPnl, info.gift_list)
        else
            self.m_CollectGiftInfo.status = 0
            self.m_CollectGiftInfo = {}
        end
    end
end

function CWelfareCtrl.GS2CUpdateCollectStatus(self, key, status, dCollect)
    self.m_CollectGiftInfo.key = key
    self.m_CollectKey = key
    self.m_CollectGiftInfo.status = status
    if dCollect then
        self.m_CollectGiftInfo.giftList = {}
        for i, v in ipairs(dCollect.gift_list) do
            self.m_CollectGiftInfo.giftList[v.key] = v.val or 0
        end
        self.m_CollectGiftInfo.start_time = dCollect.start_time
        self.m_CollectGiftInfo.end_time = dCollect.end_time
    end
    self:OnEvent(define.WelFare.Event.UpdateCollectPnl)
end

function CWelfareCtrl.GS2CChargeCheckBuy(self, checkData)
    if 1 == checkData.can_buy then
        local dPayInfo = DataTools.GetChargeData("DAILY", checkData.reward_key)
        if dPayInfo then
            table.print(dPayInfo, "每日充值(全购)回调数据信息")
            if dPayInfo.payid and string.len(dPayInfo.payid) > 0 then
                g_PayCtrl:Charge(dPayInfo.payid)
            end
        end
    end
end

-----------------回归豪礼----------------

function CWelfareCtrl.GS2CReturnGoldCoinRefresh(self, pbdata)
    self.m_WelfareReturnGiftData = pbdata
    self:TurnReturnGradeData()
    -- table.print(self.m_ReturnGradeData, "self.m_ReturnGradeData")
    self:OnEvent(define.WelFare.Event.ReturnGift)
    table.print(pbdata, "CWelfareCtrl.GS2CReturnGoldCoinRefresh")
end

function CWelfareCtrl.TurnReturnGradeData(self)
    local oReturnData = g_WelfareCtrl.m_WelfareReturnGiftData
    if not next(oReturnData) then
        return
    end
    local oResultStr = math.NumToOther(oReturnData.reward, 2)
    self.m_ReturnGradeData = {}
    for i=1, string.len(oResultStr) do
        local value = string.sub(oResultStr, i, i)
        table.insert(self.m_ReturnGradeData, value)
    end
    local oLen = 3 - #self.m_ReturnGradeData
    if oLen >= 1 then
        for i = 1, oLen do
            table.insert(self.m_ReturnGradeData, 1, "0")
        end
    end
end

function CWelfareCtrl.CheckReturnGradeIsNotGet(self)
    local oReturnData = g_WelfareCtrl.m_WelfareReturnGiftData
    if not next(oReturnData) then
        return false
    end
    local oGradeConfig = g_WelfareCtrl:GetGradeRewardConfig(oReturnData.cbtpay)
    if oGradeConfig.first_reward.grade ~= 0 and g_WelfareCtrl.m_ReturnGradeData[3] == "0" then
        return true
    end
    if oGradeConfig.second_reward.grade ~= 0 and g_WelfareCtrl.m_ReturnGradeData[2] == "0" then
        return true
    end
    if oGradeConfig.third_reward.grade ~= 0 and g_WelfareCtrl.m_ReturnGradeData[1] == "0" then
        return true
    end
    return false
end

function CWelfareCtrl.CheckReturnGiftRedPoint(self)
    local oReturnData = g_WelfareCtrl.m_WelfareReturnGiftData
    if not next(oReturnData) then
        return false
    end
    if oReturnData.free_gift == 0 then
        return true
    end
    local oGradeConfig = g_WelfareCtrl:GetGradeRewardConfig(oReturnData.cbtpay)
    if oGradeConfig.first_reward.grade ~= 0 and g_AttrCtrl.grade >= oGradeConfig.first_reward.grade and g_WelfareCtrl.m_ReturnGradeData[3] == "0" then
        return true
    end
    if oGradeConfig.second_reward.grade ~= 0 and g_AttrCtrl.grade >= oGradeConfig.second_reward.grade and g_WelfareCtrl.m_ReturnGradeData[2] == "0" then
        return true
    end
    if oGradeConfig.third_reward.grade ~= 0 and g_AttrCtrl.grade >= oGradeConfig.third_reward.grade and g_WelfareCtrl.m_ReturnGradeData[1] == "0" then
        return true
    end
    return false
end

function CWelfareCtrl.GetGradeRewardConfig(self, oMoney)
    if oMoney <= data.huodongdata.RETURNCONFIG[1].money_range.min then
        return data.huodongdata.RETURNCONFIG[1]
    else
        for k,v in ipairs(data.huodongdata.RETURNCONFIG) do
            if v.money_range.min < oMoney and v.money_range.max >= oMoney then
                return v
            end
        end
    end
end

function CWelfareCtrl.GetReturnGiftConfig(self)
    if not next(self.m_WelfareReturnGiftData) then
        return
    end
    local oMoney = self.m_WelfareReturnGiftData.cbtpay
    if oMoney <= 0 then
        return data.huodongdata.RETURNGIFTREWARD[1]
    else
        for k,v in ipairs(data.huodongdata.RETURNGIFTREWARD) do
            if v.money_range.min < oMoney and v.money_range.max >= oMoney then
                return v
            end
        end
    end
end

function CWelfareCtrl.IsHideYoukaIcon(self) --显示与否
    -- body
    local active = true
    if next(self.m_ColorfulData) then
        local  cnt = 0
        for i,v in pairs(self.m_ColorfulData) do
            if v.val == 2 then
                cnt = cnt + 1
            end
        end
        if cnt >= 3 then
            active = false
        end

    else
        active = false
    end
    -- 数据客户端都知道了，于是系统开放与否自行判断
    local info = data.opendata.OPEN.WELFARE_LOGIN
    if g_AttrCtrl.grade < info.p_level or info.open_sys~=1 then
        active = false
    end
    local idx,today =  self:CurrYoukaLoginIdx()
    if idx == 1 then 
        active = false
    end
    return active
end

function CWelfareCtrl.CurrYoukaLoginIdx(self) 
    -- body
    local minidx = 1000
    local today 
    if next(self.m_ColorfulData) then
        for i,v in pairs(self.m_ColorfulData) do
            if tonumber(string.sub(v.key, -1, -1)) < minidx  and v.val == 1 then
                minidx = tonumber(string.sub(v.key, -1, -1))
                today = 1
            end
        end
    end --可以领取的
    if minidx == 1000 then
        minidx = 0
        if next(self.m_ColorfulData) then
            for i,v in pairs(self.m_ColorfulData) do
                if minidx < tonumber(string.sub(v.key, -1, -1))  and v.val == 2 then
                    minidx = tonumber(string.sub(v.key, -1, -1)) 
                    today = 0 
                end
            end
            minidx = minidx + 1
        end
    end--计算下次可领取的下标和日期
    return minidx, today
end

function CWelfareCtrl.YoukaLoginTime(self, time) 
    -- body
    if not self:IsHideYoukaIcon() then
        return
    end
    time = time or 0 
    if self.m_YoukaLoginTimer then
       Utils.DelTimer(self.m_YoukaLoginTimer) 
       self.m_YoukaLoginTimer = nil
    end
    local function timer()
        local hours = math.modf(time/3600)
        local minutes = math.floor ((time%3600)/60)
        local seconds = time % 60
        time = time - 1
        if time >= 0 then
            self:OnEvent(define.WelFare.Event.UpdataYoukaLoginTime, {hours=hours,minutes=minutes,seconds=seconds})
            return true
        else
            return false
        end
    end
    Utils.AddTimer(timer, 1, 0.1)
 end 

--获取某一天的八日登录奖励是否可领取
 function CWelfareCtrl.GetIsEightLoginCouldGet(self, oIndex)
    if not self.m_ColorfulData or not next(self.m_ColorfulData) then
        return false
    end
    for k,v in ipairs(self.m_ColorfulData) do
        if "login_gift_"..oIndex == v.key then
            if v.val == 1 then
                return true
            else
                return false
            end
        end
    end
 end

-- 主界面光圈
function CWelfareCtrl.IsCircleShow(self)
    if self:IsHadGradeRedPoint() then
        return true
    elseif self:IsHadDailyRedPoint() then
        return true
    elseif self:IsHadYuanbaoRedPoint() then
        return true
    end
    return false
end

-- 已充值元宝数
function CWelfareCtrl.GetPayGoldCoin(self)
    return self:GetChargeItemInfo("rebate_gold_coin")
end

-- 战力礼包 --

function CWelfareCtrl.IsHasFightGiftOpen(self)
    return table.count(self.m_FightGiftBagDict) > 0
end

-- 升级礼包 --
function CWelfareCtrl.IsHasUpgradePackOpen(self)
    local upgradePacklist = g_UpgradePacksCtrl.m_upgradePackList or {}
    return table.count(upgradePacklist) > 0
end

function CWelfareCtrl.CheckFightGiftReward(self)
    for k,v in pairs(self.m_FightGiftBagDict) do
        if v.status ~= 2 then
            return
        end
    end
    self.m_FightGiftBagDict = {}
end

function CWelfareCtrl.GetFightGiftConfig(self, score)
   local config = DataTools.GetHuodongData("FIGHTGIFTBAG")
    if score then
        return config[score]
    else
        return config
    end
end

function CWelfareCtrl.GetFightGiftLeftTime(self)
    if self.m_EndTime == nil then
        return 0
    end
    local leftTime = self.m_EndTime - g_TimeCtrl:GetTimeS()
    if leftTime <= 0 then
        return 0
    end
    return leftTime
end

function CWelfareCtrl.GetFightGiftReward(self, score)
    if score then
        return self.m_FightGiftBagDict[score]
    else
        return self.m_FightGiftBagDict
    end
end

function CWelfareCtrl.GS2CFightGiftbagReward(self, rewardlist, endtime)
    self.m_EndTime = endtime
    local rewardlist = rewardlist
    for i, v in ipairs(rewardlist) do
        if v.rewarded == 1 then
            v.status = 2
        elseif v.reward == 1 then
            v.status = 1
        else
            v.status = 0
        end
        self.m_FightGiftBagDict[v.score] = v
    end

    self:OnEvent(define.WelFare.Event.RefreshFightGift)
    self:CheckFightGiftReward()
end

function CWelfareCtrl.FightGiftbagGetReward(self, score)
    nethuodong.C2GSFightGiftbagGetReward(score)
end

function CWelfareCtrl.FightGiftbagGetInfo(self)
    nethuodong.C2GSFightGiftbagGetInfo()
end

--红点检测--
function CWelfareCtrl.IsHasFightGiftRedPoint(self)
    local rewardlist = self:GetFightGiftReward()
    for k, v in pairs(rewardlist) do
        if v.status == 1 then
            return true
        end
    end
    return false
end

-- function CWelfareCtrl.FirstOpenYouKaLogin(self, changes)
--     -- body
--     for i,v in ipairs(changes) do
--         if v.sys == "WELFARE_LOGIN" and  v.open == 1 then

--             local dOpenData = data.opendata.OPEN.WELFARE_LOGIN
--             if g_AttrCtrl.grade == dOpenData.p_level - 1 then
--                 CYoukaLoginView:ShowView()
--                 break
--             end
--         end
--     end
-- end

function CWelfareCtrl.IsHadRebateRedPointByKey(self, key)
    local state = self:GetChargeItemInfo(key)
    if state == define.WelFare.Status.Get then
        return true
    end
end

function CWelfareCtrl.IsHadRebateRedPoint(self)
    local dRebateInfo = DataTools.GetWelfareData("REBATE")
    for _, dRebate in pairs(dRebateInfo) do
        if self:IsHadRebateRedPointByKey(dRebate.key) then
            return true
        end
    end
    return false
end

return CWelfareCtrl
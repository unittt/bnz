local CShopCtrl = class("CShopCtrl", CCtrlBase)

function CShopCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_ShopRecord = {
		View = {
			TabIndex = 1,
		},
		Logic = {
			
		}
	}

	self.m_oldGoodList = {}
	self:InitScoreShopSys()
	self:Reset()
	self.banCharge = false
end

function CShopCtrl.InitScoreShopSys(self)
	self.m_ScoreShopSys = {
        [1] = {id = 101, sysName = define.System.WuxunStore},
        [2] = {id = 102, sysName = define.System.JjcpointStore},
        [3] = {id = 103, sysName = define.System.LeaderPointStore},
        [4] = {id = 104, sysName = define.System.XiayiPointStore},
        [5] = {id = 105, sysName = define.System.SummonPointStore},
        [6] = {id = 106, sysName = define.System.ChumoPointStore},
	}
end

function CShopCtrl.Reset(self)
	-- 服务器数据
	self.m_ItemBuyCntDict = {}
	self.m_ChargeInfo = {}
	self.m_ScoreInfo = {}
	self.m_ShopPointList ={}
	self.m_ShopPointHashList = {}
	self.m_DiscountEndTime = 0
    self.m_HasLimitRedDot = false
    self.m_Recorded = false
end

function CShopCtrl.SetDiscountEndTime(self, time)
	local time = time or 0
	self.m_DiscountEndTime = time
	self:OnEvent(define.Shop.Event.NpcShopDiscount)
end

function CShopCtrl.GetDiscountEndTime(self)
	return self.m_DiscountEndTime
end

--计算折后价及折扣
function CShopCtrl.GetDiscountPrice(self, price, discount)
	local disc
	if not discount or discount <= 0 then
		disc = 10
	else
		disc = math.floor(discount)
	end
	--[[打折时间结束，折扣恢复10折]]--
	if self.m_DiscountEndTime == 0 then
		disc = 10
	end
	local dPrice = math.modf(price*disc/10)
	return dPrice, disc
end

--商品数据的记录，每次启动游戏都与商品数据表比较，判断是否有新商品上架
function CShopCtrl.GetShopDataRecord(self)
	if table.count(self.m_oldGoodList) == 0 then

		self.m_oldGoodList = IOTools.GetRoleData("shopdataRecord") or {}

		if table.count(self.m_oldGoodList) == 0 then
			local goodList = self:GetCurLevelShopData()
			
			for k, v in pairs(goodList) do
				if v.shop_id == 301 or v.shop_id == 302 then --只记录301和302商店商品
					local id = tostring(v.id)
					self.m_oldGoodList[id] = true
				end				
			end

			IOTools.SetRoleData("shopdataRecord", self.m_oldGoodList)
		end
	end

	return self.m_oldGoodList
end

------------------返回301和302商店的新商品的列表------------------
function CShopCtrl.GetNewGoodInShop(self)
	local goodList = self:GetCurLevelShopData()
    local oldGoodList = self:GetShopDataRecord()

    local list = {}

    for k, v in pairs(goodList) do
    	if v.shop_id == 301 or v.shop_id == 302 then
    		local id = tostring(v.id)
    		local amount = g_ShopCtrl:GetLeftAmount(v)
    		if not oldGoodList[id] and amount ~= 0 then
    			list[k] = v
    		end
    	end
    end

    return list
end

-------------获取满足当前等级限制的商品------------
function CShopCtrl.GetCurLevelShopData(self)
	local curLevel = g_AttrCtrl.grade
	local data = data.shopdata.NPCSHOP
	local list = {}

	for k, v in pairs(data) do
		if curLevel >= v.limit_level then
			list[k] = v
		end
	end

	return list
end

function CShopCtrl.GetNpcShopDic(self)
	return data.shopdata.NPCSHOP
end

function CShopCtrl.GetItemBuyInfo(self, itemId)
	return self.m_ItemBuyCntDict[itemId] or {}
end

--打开商店，传shopid，暂时没有宠物商店
--以后要根据需求增加，这里是处理每一个不同的商店
function CShopCtrl.OpenShop(self, shopid)
	if shopid == 101 then
		--商会
		CEcononmyMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(define.Econonmy.Type.Guild)
		end)
	elseif shopid == 102 then
		--摆摊
		CEcononmyMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(define.Econonmy.Type.Stall)
		end)
	elseif shopid == 201 then
		--防具店
		CNpcEquipShopView:ShowView()
	elseif shopid == 202 then
		--武器店
		CNpcWeaponShopView:ShowView()
	elseif shopid == 203 then
		--药店
		CNpcMedicineShopView:ShowView()
	elseif shopid == 204 then
		--杂货店
		CNpcGroceryShopView:ShowView()
	else
		CNpcGroceryShopView:ShowView()
	end
end

-- 更新商品购买信息
function CShopCtrl.UpdateStoreItemInfo(self, lItemInfo, bAll)
	if bAll then
		self.m_ItemBuyCntDict = {}
	end
	for _, dInfo in ipairs(lItemInfo) do
		self.m_ItemBuyCntDict[dInfo.item_id] = dInfo
	end
	self:OnEvent(define.Shop.Event.RefreshShopItem, lItemInfo)
end

function CShopCtrl.GetChargeInfo(self, key)
	return self.m_ChargeInfo[key] or 0
end

function CShopCtrl.GetScoreShopInfo(self, iShopId)
	return self.m_ScoreInfo[iShopId]
end

function CShopCtrl.GetScoreShopSys(self, iShopId)
	if not iShopId then
		return self.m_ScoreShopSys
	end
	for i, v in ipairs(self.m_ScoreShopSys) do
		if v.id == iShopId then
			return v
		end
	end 
end

function CShopCtrl.GetLeftAmount(self, dShopItem)
    if not dShopItem then
        return -1
    end
    local dBuyInfo = g_ShopCtrl:GetItemBuyInfo(dShopItem.id)
    local list = {
        {limit = dShopItem.day_limit, buy = dBuyInfo.day_buy_cnt},
        {limit = dShopItem.week_limit, buy = dBuyInfo.week_buy_cnt},
        {limit = dShopItem.forever_limit, buy = dBuyInfo.forever_buy_cnt},
    }
    local iLeft = -1
    for i, d in ipairs(list) do
        local b = d.buy or 0
        local l = d.limit or 0
        local c = l > 0 and l - b
        if c then
            if iLeft < 0 or c < iLeft then
                iLeft = math.max(c, 0)
            end
        end
    end
    return iLeft
end

function CShopCtrl.ShowScoreShop(self, iShopId)
    if g_KuafuCtrl:IsInKS() then return end
	if not iShopId then return end
	local dSys = self:GetScoreShopSys(iShopId)
	if not dSys then return end
	if g_OpenSysCtrl:GetOpenSysState(dSys.sysName, true) then
		CNpcShopMainView:ShowView(function (oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("Score"))
			oView.m_ScoreShopPart:SelectShopById(iShopId)
		end)
	end
end

-- return 是否打开
function CShopCtrl.ShowChargeView(self, ...)
    if g_KuafuCtrl:IsInKS() then
        return false
    end
    if self.banCharge then
		g_NotifyCtrl:FloatMsg("充值已关闭")
		return false
	end
	local args = {...}
	CNpcShopMainView:ShowView(function (oView)
		oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
		for _, cb in ipairs(args) do
	        if cb and type(cb) == 'function' then
	            cb(oView)
	            break
	        end
	    end
    end)
    return true
end

function CShopCtrl.ShowChargeComfirm(self, cancelCb)
    if g_KuafuCtrl:IsInKS() then
        return
    end
    local windowConfirmInfo = {
        msg = "你的元宝不够哦,是否充值",
        okCallback = callback(self, "ShowChargeView"),
        okStr = "去充值",
        cancelStr = "以后再说",
        pivot = enum.UIWidget.Pivot.Center,
        cancelCallback = cancelCb,
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CShopCtrl.ShowShopMainView(self, cb)
    if g_KuafuCtrl:IsInKS() then
        return
    end
    CNpcShopMainView:ShowView(cb)
end

function CShopCtrl.ShowAddMoney(self, moneyType)
    if g_KuafuCtrl:IsInKS() then
        return
    end
    if moneyType == define.Currency.Type.Gold then
        CCurrencyView:ShowView(function(oView)
            oView:SetCurrencyView(define.Currency.Type.Gold)
        end)
    elseif moneyType == define.Currency.Type.Silver then
        CCurrencyView:ShowView(function(oView)
            oView:SetCurrencyView(define.Currency.Type.Silver)
        end)
    elseif moneyType == define.Currency.Type.GoldCoin or moneyType == define.Currency.Type.AnyGoldCoin then
        -- CNpcShopMainView:ShowView(function(oView) 
        --     oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) 
        -- end) 
        self:ShowChargeView()
    else
        return
    end
end

--------------------- 限时购买红点相关 ---------------------
function CShopCtrl.HasLimitGoodsRedPoint(self)
    if self.m_HasLimitRedDot then
        return true
    end
    if self.m_Recorded then
        return false
    end
    local record = IOTools.GetRoleData("limitGoods")
    local bRecord = false
    if record then
        local curTime = os.time()
        if curTime - record < 3600 * 24 then
            local iDay = os.date("%d", record)
            local iCurDay = os.date("%d", curTime)
            if iDay == iCurDay then
                bRecord = true
            end
        end
    end
    if bRecord then
        self.m_Recorded = true
        return false
    else
        self.m_HasLimitRedDot = self:HasLimitGoods()
        if self.m_HasLimitRedDot then
            self:RecordLimitGoodsRedPoint()
        end
        return self.m_HasLimitRedDot
    end
end

function CShopCtrl.HasLimitGoods(self)
    local curLv = g_AttrCtrl.grade
    local data = data.shopdata.NPCSHOP
    for k, v in pairs(data) do
        if v.shop_id == 302 and curLv >= v.limit_level then
            return true
        end
    end
    return false
end

function CShopCtrl.RecordLimitGoodsRedPoint(self)
    self.m_Recorded = true
    IOTools.SetRoleData("limitGoods", os.time())
end

function CShopCtrl.RemoveLimitRedDot(self)
    self.m_HasLimitRedDot = false
    self:OnEvent(define.Shop.Event.RemoveLimitRedDot)
end

---------------------- proto -------------------------

-- 支付历史信息
function CShopCtrl.GS2CPayForGoldInfo(self, lChargeInfo)
    for _, info in ipairs(lChargeInfo) do
        self.m_ChargeInfo[info.key] = info.val
    end
end

-- 支付成功
function CShopCtrl.GS2CRefreshGoldCoinUnit(self, info)
    self.m_ChargeInfo[info.key] = info.val
    self:OnEvent(define.Shop.Event.RefreshChargeItem, info)
end

function CShopCtrl.GS2CRefreshGood(self, iShopId, goodInfo)
	local dShopInfo = self.m_ScoreInfo[iShopId]
	if not dShopInfo then
		dShopInfo = {}
		self.m_ScoreInfo[iShopId] = dShopInfo
	end
	dShopInfo[goodInfo.goodid] = goodInfo
	local updateInfo = {shop = iShopId, info = goodInfo}
	self:OnEvent(define.Shop.Event.RefreshScoreShopItem, updateInfo)
end

function CShopCtrl.GS2CEnterShop(self, shopInfo)
	local iShopId = shopInfo.shop
	local dShopInfo = self.m_ScoreInfo[iShopId]
	if not dShopInfo then
		dShopInfo = {}
		self.m_ScoreInfo[iShopId] = dShopInfo
	end
	for _, v in ipairs(shopInfo.goodlist) do
		dShopInfo[v.goodid] = v
	end
	self:OnEvent(define.Shop.Event.EnterScoreShop, iShopId)
end

function CShopCtrl.GS2CDailyRewardMoneyInfo(self, pbdata)
	self.m_ShopPointList = pbdata.rewardmoneylist or {}
	self.m_ShopPointHashList[pbdata.moneytype] = pbdata.rewardmoneylist
	self:OnEvent(define.Shop.Event.RefreshShopPoint,  pbdata)
end

return CShopCtrl
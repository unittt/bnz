module(..., package.seeall)

--GS2C--

function GS2CRefreshGood(pbdata)
	local shop = pbdata.shop
	local good = pbdata.good
	--todo
	g_ShopCtrl:GS2CRefreshGood(shop, good)
end

function GS2CEnterShop(pbdata)
	local shop = pbdata.shop
	local goodlist = pbdata.goodlist
	--todo
	g_ShopCtrl:GS2CEnterShop(pbdata)
end

function GS2CDailyRewardMoneyInfo(pbdata)
	local moneytype = pbdata.moneytype --1.金币 2.银币 3.元宝 4.代金 5.帮贡 6.武勋 7.竞技场积分
	local dailyrewardamount = pbdata.dailyrewardamount --今日获得的总数
	local rewardmoneylist = pbdata.rewardmoneylist --获得信息的一个列表
	--todo
	g_ShopCtrl:GS2CDailyRewardMoneyInfo(pbdata)
end


--C2GS--

function C2GSBuyGood(shop, goodid, moneytype, amount)
	local t = {
		shop = shop,
		goodid = goodid,
		moneytype = moneytype,
		amount = amount,
	}
	g_NetCtrl:Send("shop", "C2GSBuyGood", t)
end

function C2GSEnterShop(shop)
	local t = {
		shop = shop,
	}
	g_NetCtrl:Send("shop", "C2GSEnterShop", t)
end


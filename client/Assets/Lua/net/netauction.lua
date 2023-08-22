module(..., package.seeall)

--GS2C--

function GS2COpenAuction(pbdata)
	local cat_id = pbdata.cat_id --目录ID
	local sub_id = pbdata.sub_id --子目录ID
	local sell_list = pbdata.sell_list --拍品列表
	local total = pbdata.total --目录列表总数
	local page = pbdata.page --当前页数
	--todo
	g_EcononmyCtrl:SetAuctionItemList(sell_list)
end

function GS2CRefreshSellUnit(pbdata)
	local unit = pbdata.unit --拍品信息
	--todo
	g_EcononmyCtrl:UpdateAuctionItem(unit)
end

function GS2CShowLink(pbdata)
	local cat_id = pbdata.cat_id --目录ID
	local sub_id = pbdata.sub_id --子目录ID
	local sell_list = pbdata.sell_list --拍品列表
	local total = pbdata.total --目录列表总数
	local page = pbdata.page --当前页数
	local status = pbdata.status --公示阶段1, 购买阶段2
	local target = pbdata.target --目标拍品
	--todo
	-- g_EcononmyCtrl:SetAuctionCatalogInfo(page, total, sell_list)
	-- CEcononmyMainView:ShowView(function(oView)
	-- 	oView:ShowSubPageByIndex(define.Econonmy.Type.Auction)
	-- 	oView:GetCurrentTab():JumpToTargetItem(cat_id, sub_id, status, target)
	-- end)
end

function GS2CAuctionPriceChange(pbdata)
	local id = pbdata.id --拍品ID
	local price = pbdata.price --当前价格
	local price_time = pbdata.price_time --拍卖结束时间
	local bidder = pbdata.bidder --当前竞价人
	--todo
	g_EcononmyCtrl:UpdateAuctionPrice(id, price, price_time, bidder, proxy_bidder)
end

function GS2CAuctionDetail(pbdata)
	local id = pbdata.id --拍品ID
	local type = pbdata.type --拍品类型
	local itemdata = pbdata.itemdata
	local summondata = pbdata.summondata
	--todo
 	if type == define.Econonmy.AuctionType.Item then
 		g_LinkInfoCtrl:RefreshItemInfo(id, itemdata)
 	else
 		g_LinkInfoCtrl:ShowSummonInfo(summondata)
 	end
end


--C2GS--

function C2GSOpenAuction(cat_id, sub_id, page)
	local t = {
		cat_id = cat_id,
		sub_id = sub_id,
		page = page,
	}
	g_NetCtrl:Send("auction", "C2GSOpenAuction", t)
end

function C2GSAuctionBid(id, price)
	local t = {
		id = id,
		price = price,
	}
	g_NetCtrl:Send("auction", "C2GSAuctionBid", t)
end

function C2GSSetProxyPrice(id, price)
	local t = {
		id = id,
		price = price,
	}
	g_NetCtrl:Send("auction", "C2GSSetProxyPrice", t)
end

function C2GSToggleFollow(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("auction", "C2GSToggleFollow", t)
end

function C2GSCloseAuctionUI()
	local t = {
	}
	g_NetCtrl:Send("auction", "C2GSCloseAuctionUI", t)
end

function C2GSCancelProxyPrice(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("auction", "C2GSCancelProxyPrice", t)
end

function C2GSClickLink(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("auction", "C2GSClickLink", t)
end

function C2GSAuctionDetail(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("auction", "C2GSAuctionDetail", t)
end


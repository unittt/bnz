module(..., package.seeall)

--GS2C--

function GS2CItemUnit(pbdata)
	local sid = pbdata.sid
	local amount = pbdata.amount
	local price = pbdata.price
	local up_flag = pbdata.up_flag
	local good_id = pbdata.good_id
	local has_buy = pbdata.has_buy
	--todo
	g_SummonCtrl:CheckBuyGuildItem(pbdata)
	g_EcononmyCtrl:UpdateGuildItem(sid, amount, price, up_flag, good_id, has_buy)
end

function GS2COpenGuild(pbdata)
	local cat_id = pbdata.cat_id
	local sub_id = pbdata.sub_id
	local data = pbdata.data
	--todo
	-- 宠物打书
	g_SummonCtrl:CheckGuildItemList(cat_id, sub_id, data)
	g_EcononmyCtrl:SetGuildItemList(cat_id, sub_id, data)
end

function GS2CGuildItemPrice(pbdata)
	local good_id = pbdata.good_id
	local price = pbdata.price
	--todo
	local oView = CItemSaleView:GetView()
	if oView then
		oView:SetPrice(price)
	end
end


--C2GS--

function C2GSOpenGuild(cat_id, sub_id)
	local t = {
		cat_id = cat_id,
		sub_id = sub_id,
	}
	g_NetCtrl:Send("guild", "C2GSOpenGuild", t)
end

function C2GSBuyGuildItem(good_id, amount)
	local t = {
		good_id = good_id,
		amount = amount,
	}
	g_NetCtrl:Send("guild", "C2GSBuyGuildItem", t)
end

function C2GSSellGuildItem(item_id, amount)
	local t = {
		item_id = item_id,
		amount = amount,
	}
	g_NetCtrl:Send("guild", "C2GSSellGuildItem", t)
end

function C2GSGetGuildPrice(good_id)
	local t = {
		good_id = good_id,
	}
	g_NetCtrl:Send("guild", "C2GSGetGuildPrice", t)
end


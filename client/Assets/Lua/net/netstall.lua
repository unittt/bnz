module(..., package.seeall)

--GS2C--

function GS2CStallAllGrid(pbdata)
	local grid_all = pbdata.grid_all --所有位置信息
	local size_limit = pbdata.size_limit --最大格子数
	--todo
	g_EcononmyCtrl:SetStallAllGrid(size_limit, grid_all)
end

function GS2CStallOneGrid(pbdata)
	local grid_unit = pbdata.grid_unit --单个位置格子信息
	--todo
	g_EcononmyCtrl:UpdateStallSellItem(grid_unit)
end

function GS2CSendSizeLimit(pbdata)
	local size_limit = pbdata.size_limit --最大格子数
	--todo
	g_EcononmyCtrl:SetStallUnlockSize(size_limit)
end

function GS2CSendCatalog(pbdata)
	local cat_id = pbdata.cat_id --主目录ID
	local refresh = pbdata.refresh --上次刷新时间
	local catalog = pbdata.catalog --子目录信息
	local page = pbdata.page --页数
	local total = pbdata.total --商品总数
	--todo
	g_EcononmyCtrl:SetStallCatalogInfo(pbdata)
end

function GS2CSendCatalogUnit(pbdata)
	local cat_id = pbdata.cat_id --主目录ID
	local unit = pbdata.unit --目录单元信息
	--todo
	g_EcononmyCtrl:UpdateStallItem(cat_id, unit)
end

function GS2CWithdrawAllCash(pbdata)
	local cash_list = pbdata.cash_list --所有位置的现金信息
	--todo
	g_EcononmyCtrl:WithdrawAllCash(cash_list)
end

function GS2CSendItemDetail(pbdata)
	local itemdata = pbdata.itemdata --摆摊道具详细信息
	--todo
	local oItem = CItem.New(itemdata)
	oItem.m_IsCompareEquip = false
	CItemTipsView:ShowView(function(oView)
			oView:SetItem(oItem)
			oView:HideBtns()
		end)
end

function GS2CDefaultPrice(pbdata)
	local sid = pbdata.sid --道具sid
	local price = pbdata.price --道具行情价
	--todo
	local iRealSid = math.floor(sid/1000)
	local oView = CEcononmyBatchStallView:GetView()
	if oView then
		oView:SetPrice(iRealSid, price, sid)
	end
	oView = CEcononmyStallOparateView:GetView()
	if oView then
		oView:SetPrice(iRealSid, price, sid)
	end
end

function GS2CStallRedPoint(pbdata)
	--todo
	g_EcononmyCtrl:RefreshStallNotify(true)
end


--C2GS--

function C2GSAddSellItem(pos_id, item_id, amount, price)
	local t = {
		pos_id = pos_id,
		item_id = item_id,
		amount = amount,
		price = price,
	}
	g_NetCtrl:Send("stall", "C2GSAddSellItem", t)
end

function C2GSAddSellItemList(item_list)
	local t = {
		item_list = item_list,
	}
	g_NetCtrl:Send("stall", "C2GSAddSellItemList", t)
end

function C2GSAddOverTimeItem()
	local t = {
	}
	g_NetCtrl:Send("stall", "C2GSAddOverTimeItem", t)
end

function C2GSResetItemPrice(pos_id, price)
	local t = {
		pos_id = pos_id,
		price = price,
	}
	g_NetCtrl:Send("stall", "C2GSResetItemPrice", t)
end

function C2GSResetItemListPrice(item_list)
	local t = {
		item_list = item_list,
	}
	g_NetCtrl:Send("stall", "C2GSResetItemListPrice", t)
end

function C2GSRemoveSellItem(pos_id, amount)
	local t = {
		pos_id = pos_id,
		amount = amount,
	}
	g_NetCtrl:Send("stall", "C2GSRemoveSellItem", t)
end

function C2GSWithdrawAllCash()
	local t = {
	}
	g_NetCtrl:Send("stall", "C2GSWithdrawAllCash", t)
end

function C2GSWithdrawOneGrid(pos_id)
	local t = {
		pos_id = pos_id,
	}
	g_NetCtrl:Send("stall", "C2GSWithdrawOneGrid", t)
end

function C2GSUnlockGrid()
	local t = {
	}
	g_NetCtrl:Send("stall", "C2GSUnlockGrid", t)
end

function C2GSBuySellItem(cat_id, pos_id, amount)
	local t = {
		cat_id = cat_id,
		pos_id = pos_id,
		amount = amount,
	}
	g_NetCtrl:Send("stall", "C2GSBuySellItem", t)
end

function C2GSSellItemDetail(cat_id, pos_id)
	local t = {
		cat_id = cat_id,
		pos_id = pos_id,
	}
	g_NetCtrl:Send("stall", "C2GSSellItemDetail", t)
end

function C2GSOpenStall()
	local t = {
	}
	g_NetCtrl:Send("stall", "C2GSOpenStall", t)
end

function C2GSOpenCatalog(cat_id, page, first, item_sid)
	local t = {
		cat_id = cat_id,
		page = page,
		first = first,
		item_sid = item_sid,
	}
	g_NetCtrl:Send("stall", "C2GSOpenCatalog", t)
end

function C2GSRefreshCatalog(cat_id, gold)
	local t = {
		cat_id = cat_id,
		gold = gold,
	}
	g_NetCtrl:Send("stall", "C2GSRefreshCatalog", t)
end

function C2GSGetDefaultPrice(sid)
	local t = {
		sid = sid,
	}
	g_NetCtrl:Send("stall", "C2GSGetDefaultPrice", t)
end


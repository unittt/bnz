module(..., package.seeall)

--GS2C--

function GS2CLoginStoreInfo(pbdata)
	local item_info = pbdata.item_info
	--todo
	g_ShopCtrl:UpdateStoreItemInfo(item_info, true)
end

function GS2CUpdateStoreInfo(pbdata)
	local item_info = pbdata.item_info
	--todo
	g_ShopCtrl:UpdateStoreItemInfo(item_info)
end

function GS2CLimitTimeDiscountInfo(pbdata)
	local discount_end = pbdata.discount_end --自己打折结束时间戳
	local show_tip = pbdata.show_tip --1 提示
	--todo
	g_ShopCtrl:SetDiscountEndTime(discount_end)
	if show_tip == 1 then
		local lefttime = discount_end - g_TimeCtrl:GetTimeS()
		local timeL = g_TimeCtrl:GetLeftTime(lefttime)
		local text = data.textdata.ITEM[1054].content
		local msg = string.gsub(text, "#time", timeL)
		g_NotifyCtrl:FloatMsg(msg)
		g_ShopCtrl:ShowShopMainView(function(oView)
			oView.m_NpcShopPart.m_TabGrid:GetChild(1):SetSelected(true)
			oView.m_NpcShopPart:ShowSubShopById(301)
		end)
	end
end


--C2GS--

function C2GSExchangeGold(store_itemid)
	local t = {
		store_itemid = store_itemid,
	}
	g_NetCtrl:Send("store", "C2GSExchangeGold", t)
end

function C2GSExchangeSilver(store_itemid)
	local t = {
		store_itemid = store_itemid,
	}
	g_NetCtrl:Send("store", "C2GSExchangeSilver", t)
end

function C2GSNpcStoreBuy(buy_id, buy_count, all_money)
	local t = {
		buy_id = buy_id,
		buy_count = buy_count,
		all_money = all_money,
	}
	g_NetCtrl:Send("store", "C2GSNpcStoreBuy", t)
end

function C2GSFastBuyItem(item_id, cnt)
	local t = {
		item_id = item_id,
		cnt = cnt,
	}
	g_NetCtrl:Send("store", "C2GSFastBuyItem", t)
end

function C2GSExChangeDanceBook()
	local t = {
	}
	g_NetCtrl:Send("store", "C2GSExChangeDanceBook", t)
end


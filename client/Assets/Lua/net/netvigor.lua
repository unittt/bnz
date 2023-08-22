module(..., package.seeall)

--GS2C--

function GS2CVigorChangeInfo(pbdata)
	local vigor_value = pbdata.vigor_value --玩家精气值
	local list_info = pbdata.list_info --所有类型的炼化信息列表
	--todo
	g_ItemCtrl:SetRefineInfoList(list_info)
end

function GS2CVigorItemGetNewGrid(pbdata)
	local change_type = pbdata.change_type --炼化类型
	local grid_size = pbdata.grid_size --格子数
	--todo
	g_ItemCtrl:UpdateRefineGrid(change_type, grid_size)
end

function GS2CVigorItemGetProduct(pbdata)
	local item_info = pbdata.item_info --该类型条目的变动信息
	--todo
	g_ItemCtrl:UpdateRefineInfo(item_info.change_type, item_info)
end

function GS2CVigorItemHasProduct(pbdata)
	local products_info = pbdata.products_info --可以收取产出的信息列表
	--todo
end

function GS2CVigorRedPoint(pbdata)
	--todo
	g_ItemCtrl:RefreshRefineRedPoint(true)
end

function GS2CVigorChangeItemStatus(pbdata)
	local is_change_all = pbdata.is_change_all --是否勾选一键炼化
	local change_type = pbdata.change_type --炼化类型
	--todo
	g_ItemCtrl:UpdateRefineCheckBox(change_type, is_change_all)
end


--C2GS--

function C2GSOpenVigorChange()
	local t = {
	}
	g_NetCtrl:Send("vigor", "C2GSOpenVigorChange", t)
end

function C2GSVigorChangeStart(change_type)
	local t = {
		change_type = change_type,
	}
	g_NetCtrl:Send("vigor", "C2GSVigorChangeStart", t)
end

function C2GSVigorChangeItemStatus(is_change_all, change_type)
	local t = {
		is_change_all = is_change_all,
		change_type = change_type,
	}
	g_NetCtrl:Send("vigor", "C2GSVigorChangeItemStatus", t)
end

function C2GSVigorChangeList()
	local t = {
	}
	g_NetCtrl:Send("vigor", "C2GSVigorChangeList", t)
end

function C2GSChangeGoldcoinToVigor()
	local t = {
	}
	g_NetCtrl:Send("vigor", "C2GSChangeGoldcoinToVigor", t)
end

function C2GSBuyGrid(change_type)
	local t = {
		change_type = change_type,
	}
	g_NetCtrl:Send("vigor", "C2GSBuyGrid", t)
end

function C2GSVigorChangeProduct(change_type)
	local t = {
		change_type = change_type,
	}
	g_NetCtrl:Send("vigor", "C2GSVigorChangeProduct", t)
end

function C2GSVigorChangeALLProducts()
	local t = {
	}
	g_NetCtrl:Send("vigor", "C2GSVigorChangeALLProducts", t)
end

function C2GSChangeItemToVigor(changeItemList)
	local t = {
		changeItemList = changeItemList,
	}
	g_NetCtrl:Send("vigor", "C2GSChangeItemToVigor", t)
end


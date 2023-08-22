module(..., package.seeall)

--GS2C--

function GS2CLoginTempItem(pbdata)
	local itemdata = pbdata.itemdata
	--todo
	g_ItemTempBagCtrl:GS2CLoginTempItem(itemdata)
end

function GS2CAddTempItem(pbdata)
	local itemdata = pbdata.itemdata
	--todo
	g_ItemTempBagCtrl:GS2CAddTempItem(itemdata)
end

function GS2CRefreshTempItem(pbdata)
	local itemdata = pbdata.itemdata
	--todo
	g_ItemTempBagCtrl:GS2CRefreshTempItem(itemdata)
end

function GS2CDelTempItem(pbdata)
	local id = pbdata.id
	--todo
	g_ItemTempBagCtrl:GS2CDelTempItem(id)
end

function GS2CRefreshAllTemItem(pbdata)
	local itemdata = pbdata.itemdata
	--todo
	g_ItemTempBagCtrl:GS2CRefreshAllTemItem(itemdata)
end

function GS2COpenTempItemUI(pbdata)
	--todo
	g_ItemTempBagCtrl:ShowView()
end


--C2GS--

function C2GSTranToItemBag(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("tempitem", "C2GSTranToItemBag", t)
end

function C2GSOpenTempItemUI()
	local t = {
	}
	g_NetCtrl:Send("tempitem", "C2GSOpenTempItemUI", t)
end


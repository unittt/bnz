module(..., package.seeall)

--GS2C--

function GS2CLoginItem(pbdata)
	local itemdata = pbdata.itemdata --背包道具信息
	local extsize = pbdata.extsize --扩展格子数目
	--todo
	g_ItemCtrl:LoginItem(extsize, itemdata)
	g_PromoteCtrl:UpdatePromoteData(1)
	g_PromoteCtrl:UpdatePromoteData(5)
	g_PromoteCtrl:UpdatePromoteData(7)
	g_PromoteCtrl:UpdatePromoteData(8)
	g_PromoteCtrl:UpdatePromoteData(9)
	g_PromoteCtrl:UpdatePromoteData(11)
	g_PromoteCtrl:UpdatePromoteData(13)
end

function GS2CAddItem(pbdata)
	local itemdata = pbdata.itemdata
	local from_wh = pbdata.from_wh --是否来自仓库
	local refresh = pbdata.refresh --是否刷新而非落袋
	--todo
	g_ItemCtrl:GS2CAddItem(itemdata, from_wh, refresh)
	local oNeedData1 = g_PromoteCtrl:CheckNeedItemList(1)
	local oNeedData5 = g_PromoteCtrl:CheckNeedItemList(5)
	local oNeedData7 = g_PromoteCtrl:CheckNeedItemList(7)
	local oNeedData8 = g_PromoteCtrl:CheckNeedItemList(8)
	local oNeedData9 = g_PromoteCtrl:CheckNeedItemList(9)
	local oNeedData11 = g_PromoteCtrl:CheckNeedItemList(11)
	local oNeedData13 = g_PromoteCtrl:CheckNeedItemList(13)
	if table.index(oNeedData1, itemdata.sid) then
		g_PromoteCtrl:UpdatePromoteData(1)
	end
	if table.index(oNeedData5, itemdata.sid) then
		g_PromoteCtrl:UpdatePromoteData(5)
	end
	if table.index(oNeedData7, itemdata.sid) then
		g_PromoteCtrl:UpdatePromoteData(7)
	end
	if table.index(oNeedData8, itemdata.sid) then
		g_PromoteCtrl:UpdatePromoteData(8)
	end
	if table.index(oNeedData9, itemdata.sid) then
		g_PromoteCtrl:UpdatePromoteData(9)
	end
	if table.index(oNeedData11, itemdata.sid) then
		g_PromoteCtrl:UpdatePromoteData(11)
	end
	if table.index(oNeedData13, itemdata.sid) then
		g_PromoteCtrl:UpdatePromoteData(13)
	end
	g_ItemCtrl:CheckQuickUseContent()
end

function GS2CDelItem(pbdata)
	local id = pbdata.id --服务的道具id
	--todo
	local oItemSid = g_ItemCtrl.m_BagItems[id] and g_ItemCtrl.m_BagItems[id]:GetSValueByKey("sid") or 0
	g_ItemCtrl:GS2CDelItem(id)
	
	if oItemSid == 0 then
		return
	end
	local oNeedData1 = g_PromoteCtrl:CheckNeedItemList(1)
	local oNeedData5 = g_PromoteCtrl:CheckNeedItemList(5)
	local oNeedData7 = g_PromoteCtrl:CheckNeedItemList(7)
	local oNeedData8 = g_PromoteCtrl:CheckNeedItemList(8)
	local oNeedData9 = g_PromoteCtrl:CheckNeedItemList(9)
	local oNeedData11 = g_PromoteCtrl:CheckNeedItemList(11)
	local oNeedData13 = g_PromoteCtrl:CheckNeedItemList(13)
	if table.index(oNeedData1, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(1)
	end
	if table.index(oNeedData5, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(5)
	end
	if table.index(oNeedData7, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(7)
	end
	if table.index(oNeedData8, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(8)
	end
	if table.index(oNeedData9, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(9)
	end
	if table.index(oNeedData11, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(11)
	end
	if table.index(oNeedData13, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(13)
	end
	g_ItemCtrl:DelAllQuickUseDataById(id)
	g_ItemCtrl:CheckQuickUseContent()
end

function GS2CItemAmount(pbdata)
	local id = pbdata.id
	local amount = pbdata.amount
	local from_wh = pbdata.from_wh
	local refresh = pbdata.refresh --是否刷新而非落袋
	--todo
	local oItemSid = g_ItemCtrl.m_BagItems[id] and g_ItemCtrl.m_BagItems[id]:GetSValueByKey("sid") or 0
	g_ItemCtrl:GS2CItemAmount(id, amount, from_wh, refresh)

	if oItemSid == 0 then
		return
	end
	local oNeedData1 = g_PromoteCtrl:CheckNeedItemList(1)
	local oNeedData5 = g_PromoteCtrl:CheckNeedItemList(5)
	local oNeedData7 = g_PromoteCtrl:CheckNeedItemList(7)
	local oNeedData8 = g_PromoteCtrl:CheckNeedItemList(8)
	local oNeedData9 = g_PromoteCtrl:CheckNeedItemList(9)
	local oNeedData11 = g_PromoteCtrl:CheckNeedItemList(11)
	local oNeedData13 = g_PromoteCtrl:CheckNeedItemList(13)
	if table.index(oNeedData1, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(1)
	end
	if table.index(oNeedData5, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(5)
	end
	if table.index(oNeedData7, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(7)
	end
	if table.index(oNeedData8, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(8)
	end
	if table.index(oNeedData9, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(9)
	end
	if table.index(oNeedData11, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(11)
	end
	if table.index(oNeedData13, oItemSid) then
		g_PromoteCtrl:UpdatePromoteData(13)
	end
	g_ItemCtrl:CheckQuickUseContent()
end

function GS2CItemQuickUse(pbdata)
	local id = pbdata.id
	--todo
	g_ItemCtrl:ItemQuickUse(id)
end

function GS2CItemExtendSize(pbdata)
	local extsize = pbdata.extsize --扩展格子数目
	--todo
	g_ItemCtrl:ExtBagSize(extsize)
end

function GS2CItemArrange(pbdata)
	local pos_info = pbdata.pos_info --位置变动信息
	--todo
	g_ItemCtrl:GS2CItemArrange(pos_info)
end

function GS2CEquipLast(pbdata)
	local itemid = pbdata.itemid --装备ID
	local last = pbdata.last --耐久度
	--todo
	g_ItemCtrl:UpdateEquipLast(itemid, last)
end

function GS2CEquipMake(pbdata)
	local sid = pbdata.sid
	local make_info = pbdata.make_info --打造所需物品信息
	local goldcoin = pbdata.goldcoin --快捷打造消耗
	--todo
	g_ItemCtrl:AddForgeItemIfno(sid, make_info, goldcoin)
end

function GS2CWashEquipInfo(pbdata)
	local now_info = pbdata.now_info
	local wash_info = pbdata.wash_info
	--todo
	g_ItemCtrl:SetWashEquipInfo(now_info, wash_info)
end

function GS2CStrengthInfo(pbdata)
	local success_ratio_base = pbdata.success_ratio_base
	local success_ratio_add = pbdata.success_ratio_add
	--todo
	g_ItemCtrl:SetStrengthInfo(pbdata)
end

function GS2CLoadTreasureProgress(pbdata)
	local sessionidx = pbdata.sessionidx
	--todo
	g_TreasureCtrl:GS2CLoadTreasureProgress(sessionidx)
end

function GS2CStartShowRewardByType(pbdata)
	local reward_type = pbdata.reward_type
	local moneyreward_info = pbdata.moneyreward_info
	local itemreward_info = pbdata.itemreward_info
	local sessionidx = pbdata.sessionidx
	--todo
	g_TreasureCtrl:GS2CStartShowRewardByType(pbdata)
end

function GS2CContinueFindTreasure(pbdata)
	local sid = pbdata.sid
	--todo
	g_TreasureCtrl:GS2CContinueFindTreasure(pbdata)
end

function GS2CEquipNeedFix(pbdata)
	local silver = pbdata.silver
	--todo
end

function GS2CEquipLogin(pbdata)
	local fh_point = pbdata.fh_point
	--todo
	g_ItemCtrl:SetEquipSoulPoint(fh_point)
end

function GS2CUpdateFuHunPoint(pbdata)
	local fh_point = pbdata.fh_point
	--todo
	g_ItemCtrl:SetEquipSoulPoint(fh_point)
end

function GS2CFuHunCost(pbdata)
	local equip_id = pbdata.equip_id
	local cost_info = pbdata.cost_info --打造所需物品信息
	--todo
	g_ItemCtrl:SetAttachSoulInfo(equip_id, cost_info)
end

function GS2CUpdateItemInfo(pbdata)
	local itemdata = pbdata.itemdata --背包道具信息
	--todo
	g_ItemCtrl:UpdateItemInfo(itemdata)
end

function GS2CSummonEquipCombine(pbdata)
	local id = pbdata.id
	--todo
	g_SummonCtrl:SummonEquipCombine(id)
end

function GS2CItemGoldCoinPrice(pbdata)
	local sid = pbdata.sid
	local goldcoin = pbdata.goldcoin
	--todo
	g_ItemCtrl:GS2CItemGoldCoinPrice(pbdata)
end

function GS2CFastBuyItemPrice(pbdata)
	local sid = pbdata.sid
	local money_type = pbdata.money_type
	local price = pbdata.price
	--todo
	g_QuickGetCtrl:GS2CFastBuyItemPrice(pbdata)
end

function GS2CFastBuyItemListPrice(pbdata)
	local item_list = pbdata.item_list
	--todo
	g_QuickGetCtrl:GS2CFastBuyItemListPrice(pbdata)
end

function GS2CWenShiCombineResult(pbdata)
	local flag = pbdata.flag
	--todo
	g_WenShiCtrl:GS2CWenShiCombineResult(flag)
end


--C2GS--

function C2GSItemUse(itemid, target, exarg)
	local t = {
		itemid = itemid,
		target = target,
		exarg = exarg,
	}
	g_NetCtrl:Send("item", "C2GSItemUse", t)
end

function C2GSItemListUse(use_list, target, exarg)
	local t = {
		use_list = use_list,
		target = target,
		exarg = exarg,
	}
	g_NetCtrl:Send("item", "C2GSItemListUse", t)
end

function C2GSItemInfo(itemid)
	local t = {
		itemid = itemid,
	}
	g_NetCtrl:Send("item", "C2GSItemInfo", t)
end

function C2GSItemMove(itemid, pos)
	local t = {
		itemid = itemid,
		pos = pos,
	}
	g_NetCtrl:Send("item", "C2GSItemMove", t)
end

function C2GSItemArrage()
	local t = {
	}
	g_NetCtrl:Send("item", "C2GSItemArrage", t)
end

function C2GSAddItemExtendSize(size)
	local t = {
		size = size,
	}
	g_NetCtrl:Send("item", "C2GSAddItemExtendSize", t)
end

function C2GSDeComposeItem(id, amount)
	local t = {
		id = id,
		amount = amount,
	}
	g_NetCtrl:Send("item", "C2GSDeComposeItem", t)
end

function C2GSComposeItem(id, amount, compose_sid)
	local t = {
		id = id,
		amount = amount,
		compose_sid = compose_sid,
	}
	g_NetCtrl:Send("item", "C2GSComposeItem", t)
end

function C2GSItemsExchangeItem(exchangeid, amount)
	local t = {
		exchangeid = exchangeid,
		amount = amount,
	}
	g_NetCtrl:Send("item", "C2GSItemsExchangeItem", t)
end

function C2GSRecycleItem(itemid, amount)
	local t = {
		itemid = itemid,
		amount = amount,
	}
	g_NetCtrl:Send("item", "C2GSRecycleItem", t)
end

function C2GSFixEquip(pos)
	local t = {
		pos = pos,
	}
	g_NetCtrl:Send("item", "C2GSFixEquip", t)
end

function C2GSMakeEquipInfo(sid)
	local t = {
		sid = sid,
	}
	g_NetCtrl:Send("item", "C2GSMakeEquipInfo", t)
end

function C2GSMakeEquip(sid, flag)
	local t = {
		sid = sid,
		flag = flag,
	}
	g_NetCtrl:Send("item", "C2GSMakeEquip", t)
end

function C2GSEquipStrength(pos, flag, fast)
	local t = {
		pos = pos,
		flag = flag,
		fast = fast,
	}
	g_NetCtrl:Send("item", "C2GSEquipStrength", t)
end

function C2GSWashEquipInfo(itemid)
	local t = {
		itemid = itemid,
	}
	g_NetCtrl:Send("item", "C2GSWashEquipInfo", t)
end

function C2GSWashEquip(itemid, flag)
	local t = {
		itemid = itemid,
		flag = flag,
	}
	g_NetCtrl:Send("item", "C2GSWashEquip", t)
end

function C2GSUseWashEquip(itemid)
	local t = {
		itemid = itemid,
	}
	g_NetCtrl:Send("item", "C2GSUseWashEquip", t)
end

function C2GSMergeShenHun(sid)
	local t = {
		sid = sid,
	}
	g_NetCtrl:Send("item", "C2GSMergeShenHun", t)
end

function C2GSUseShenHun(equip_id, shenhun_id, flag)
	local t = {
		equip_id = equip_id,
		shenhun_id = shenhun_id,
		flag = flag,
	}
	g_NetCtrl:Send("item", "C2GSUseShenHun", t)
end

function C2GSStrengthInfo(pos)
	local t = {
		pos = pos,
	}
	g_NetCtrl:Send("item", "C2GSStrengthInfo", t)
end

function C2GSCompoundItem(targetid, compoundtype, moneytype)
	local t = {
		targetid = targetid,
		compoundtype = compoundtype,
		moneytype = moneytype,
	}
	g_NetCtrl:Send("item", "C2GSCompoundItem", t)
end

function C2GSFixAllEquips()
	local t = {
	}
	g_NetCtrl:Send("item", "C2GSFixAllEquips", t)
end

function C2GSEquipBreak(pos, flag)
	local t = {
		pos = pos,
		flag = flag,
	}
	g_NetCtrl:Send("item", "C2GSEquipBreak", t)
end

function C2GSDeComposeItemList(items)
	local t = {
		items = items,
	}
	g_NetCtrl:Send("item", "C2GSDeComposeItemList", t)
end

function C2GSRecFuHunPointReward(sid)
	local t = {
		sid = sid,
	}
	g_NetCtrl:Send("item", "C2GSRecFuHunPointReward", t)
end

function C2GSGetFuHunCost(equip_id)
	local t = {
		equip_id = equip_id,
	}
	g_NetCtrl:Send("item", "C2GSGetFuHunCost", t)
end

function C2GSSummonEquipResetSkill(equip_id)
	local t = {
		equip_id = equip_id,
	}
	g_NetCtrl:Send("item", "C2GSSummonEquipResetSkill", t)
end

function C2GSSummonEquipCombine(itemid)
	local t = {
		itemid = itemid,
	}
	g_NetCtrl:Send("item", "C2GSSummonEquipCombine", t)
end

function C2GSHSCompose1(itemid, addradio)
	local t = {
		itemid = itemid,
		addradio = addradio,
	}
	g_NetCtrl:Send("item", "C2GSHSCompose1", t)
end

function C2GSHSCompose2(itemid1, itemid2, addradio)
	local t = {
		itemid1 = itemid1,
		itemid2 = itemid2,
		addradio = addradio,
	}
	g_NetCtrl:Send("item", "C2GSHSCompose2", t)
end

function C2GSHSDeCompose(itemid)
	local t = {
		itemid = itemid,
	}
	g_NetCtrl:Send("item", "C2GSHSDeCompose", t)
end

function C2GSEquipAddHS(hunshiid, equipid, pos)
	local t = {
		hunshiid = hunshiid,
		equipid = equipid,
		pos = pos,
	}
	g_NetCtrl:Send("item", "C2GSEquipAddHS", t)
end

function C2GSEquipDelHS(equipid, pos)
	local t = {
		equipid = equipid,
		pos = pos,
	}
	g_NetCtrl:Send("item", "C2GSEquipDelHS", t)
end

function C2GSChangeHS(itemid, attr, color)
	local t = {
		itemid = itemid,
		attr = attr,
		color = color,
	}
	g_NetCtrl:Send("item", "C2GSChangeHS", t)
end

function C2GSItemGoldCoinPrice(sid)
	local t = {
		sid = sid,
	}
	g_NetCtrl:Send("item", "C2GSItemGoldCoinPrice", t)
end

function C2GSFastBuyItemPrice(sid, store_type)
	local t = {
		sid = sid,
		store_type = store_type,
	}
	g_NetCtrl:Send("item", "C2GSFastBuyItemPrice", t)
end

function C2GSFastBuyItemListPrice(item_list)
	local t = {
		item_list = item_list,
	}
	g_NetCtrl:Send("item", "C2GSFastBuyItemListPrice", t)
end

function C2GSWenShiMake(itemid)
	local t = {
		itemid = itemid,
	}
	g_NetCtrl:Send("item", "C2GSWenShiMake", t)
end

function C2GSWenShiCombine(itemid1, itemid2)
	local t = {
		itemid1 = itemid1,
		itemid2 = itemid2,
	}
	g_NetCtrl:Send("item", "C2GSWenShiCombine", t)
end

function C2GSWenShiWash(itemid, locks, flag)
	local t = {
		itemid = itemid,
		locks = locks,
		flag = flag,
	}
	g_NetCtrl:Send("item", "C2GSWenShiWash", t)
end


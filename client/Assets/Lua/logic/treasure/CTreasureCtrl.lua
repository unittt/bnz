local CTreasureCtrl = class("CTreasureCtrl", CCtrlBase)

function CTreasureCtrl.ctor(self)
    CCtrlBase.ctor(self)
end

--服务器通知挖宝进度条协议返回
function CTreasureCtrl.GS2CLoadTreasureProgress(self, sessionidx)
	printc("服务器通知挖宝进度条协议返回")
	CTreasureSliderView:ShowView(function (oView)
		oView:SetCallback_sessionidx(sessionidx)
	end)
end

--服务器挖宝成功后触发的奖励协议返回
function CTreasureCtrl.GS2CStartShowRewardByType(self, pbdata)
	printc("服务器挖宝成功后触发的奖励")
	table.print(pbdata,"服务器挖宝成功后触发的奖励")
	local reward_type = pbdata.reward_type
	local moneyreward_info = pbdata.moneyreward_info
	local itemreward_info = pbdata.itemreward_info
	local sessionidx = pbdata.sessionidx
	local bIsAuto = true
	local bIsMoney = false
	local bIsItem = false
	if reward_type == define.Treasure.PrizeType.GoldCoin then
		if moneyreward_info then
			bIsMoney = true
			CTreasurePrizeView:CloseView()
			if tonumber(moneyreward_info[1].amount) > 0 then
				self.m_IsTreasureMoney = true
				CTreasurePrizeView:ShowView(function (oView)
					oView:SetPrizeNum(tonumber(moneyreward_info[1].amount), "金币", sessionidx)
				end)
			end
		else
			printc("服务器挖宝成功后触发的奖励是金币,但金币信息为nil")
		end
	elseif reward_type == define.Treasure.PrizeType.Silver then
		if moneyreward_info then
			bIsMoney = true
			CTreasurePrizeView:CloseView()
			if tonumber(moneyreward_info[1].amount) > 0 then
				self.m_IsTreasureMoney = true
				CTreasurePrizeView:ShowView(function (oView)
					oView:SetPrizeNum(tonumber(moneyreward_info[1].amount), "银币", sessionidx)
				end)
			end
		else
			printc("服务器挖宝成功后触发的奖励是银币,但银币信息为nil")
		end
	elseif reward_type == define.Treasure.PrizeType.Item then
		if itemreward_info and next(itemreward_info) then
			bIsItem = true			
			self:AddItemGetEff(true, function ()
				if bIsAuto and sessionidx then
					netother.C2GSCallback(sessionidx)
				end
			end)		
		else
			printc("服务器挖宝成功后触发的奖励是道具,但道具信息为nil")
		end
	elseif reward_type == define.Treasure.PrizeType.LittleMonster then
		printc("服务器挖宝成功后触发的奖励是放妖")
	elseif reward_type == define.Treasure.PrizeType.KingMonster then
		printc("服务器挖宝成功后触发的奖励是放妖王")
	elseif reward_type == define.Treasure.PrizeType.Copy then
		printc("服务器挖宝成功后触发的奖励是副本")
		bIsAuto = false
	else
		printc("没有处理这种类型的宝图奖励Type:"..reward_type)
	end
	if bIsAuto and sessionidx and not bIsMoney and not bIsItem then
		netother.C2GSCallback(sessionidx)
	end
end

function CTreasureCtrl.AddItemGetEff(self, show, cb)
	if show then
		local path = "Effect/Scene/scene_eff_0004/Prefabs/scene_eff_0004.prefab"
		local oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("MapTerrain"), true)
		oEffect:SetPos(g_MapCtrl:GetHero():GetPos())
		local function timeup()
			if Utils.IsNil(oEffect) then
				return false
			end
			oEffect:Destroy()
			self.m_MapSwitchEffect = nil
			if cb then cb() end
		end
		Utils.AddTimer(timeup, 0, 1)
		self.m_MapSwitchEffect = oEffect
	elseif self.m_MapSwitchEffect and self.m_MapSwitchEffect:GetActive() then
		self.m_MapSwitchEffect:Destroy()
		self.m_MapSwitchEffect = nil
	end
end

--服务器告诉自动挖宝协议返回
function CTreasureCtrl.GS2CContinueFindTreasure(self, pbdata)
	printc("服务器告诉自动挖宝协议返回")
	local sid = pbdata.sid
	--t = {sid={oItem1, oItem2, ...}
	local itemList = g_ItemCtrl:GetBagItemTableBySidList({sid})
	local item
	if itemList[sid] and next(itemList[sid]) then
		item = itemList[sid][1]
	end
	if item then
		if g_TeamCtrl:IsJoinTeam() and (not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave()) then
			return
		end
		local treasureinfo = g_ItemViewCtrl:GetTreasureInfo(item)
		if treasureinfo then
			netitem.C2GSItemUse(item:GetSValueByKey("id"))
		else
			printc("使用宝图道具的treasureinfo为nil")
		end
	else
		printc("服务器告诉自动挖宝协议返回，找不到这个配置id对应的item数据,sid:"..sid)
	end
end

--服务器告诉打开充值界面协议返回
function CTreasureCtrl.GS2CShortWay(self, pbdata)
	printc("服务器告诉打开充值界面协议返回:"..pbdata.type)
	local itype = pbdata.type --1:元宝,2:金币,3:银币
	if itype == 1 then
		-- CNpcShopMainView:ShowView(function(oView) oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) end)
		g_ShopCtrl:ShowChargeView()
		CDialogueOptionView:CloseView()
	end
end

function CTreasureCtrl.GS2COpenAdvanceMap(self, pbdata)
	local oItem = g_ItemCtrl.m_BagItems[pbdata.itemid]
	if oItem and not oItem:IsEquiped() then
		g_ItemCtrl:AddQuickUseData(oItem, nil, true)
	end
end

--获取目标金钱数量的每一个数字存进一个列表
function CTreasureCtrl.GetEachNumList(self, targetnum, oTotalCount)
	--列表是尾插入，越后面的是越高位
	local realPrizeNumList = {}
	local PrizeNumList = {}
	local num = targetnum
	while num ~= 0 do
		table.insert(PrizeNumList,num%10)
		table.insert(realPrizeNumList,num%10)
		num = math.modf(num/10)
		if #PrizeNumList >= oTotalCount then
			break
		end
	end
	if #PrizeNumList < oTotalCount then
		for i=1,oTotalCount-#PrizeNumList,1 do
			table.insert(PrizeNumList,0)
		end
	end
	return PrizeNumList,realPrizeNumList
end

return CTreasureCtrl
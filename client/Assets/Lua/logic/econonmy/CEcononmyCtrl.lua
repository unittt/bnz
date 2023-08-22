CEcononmyCtrl = class("CEcononmyCtrl", CCtrlBase)
CEcononmyCtrl.StallItemLimit = 8
CEcononmyCtrl.AuctionItemLimit = 10
CEcononmyCtrl.AuctionSellLimit = 8
CEcononmyCtrl.GuildEquipCatalog = 1

function CEcononmyCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self:Reset()

	self.m_UnlockTab = {
		[1] = define.System.Guild,
		[2] = define.System.Stall,
		[3] = define.System.Auction,
	}
end

function CEcononmyCtrl.Reset(self)
	self.m_GuildItemList = {}
	self.m_GuildCatalog = -1 
	self.m_TargetGuildItem = nil

	self.m_StallCatalog = -1
	self.m_StallItemList = {}
	self.m_StallCatalogInfo = nil
	self.m_StallPageCount = 1
	self.m_LastRefreshTime = 0
	self.m_StallUnlockGrid = 0
	self.m_StallInfoDict = {}
	self.m_StallGridInfos = {}
	self.m_TargetStallItem = nil
	self.m_StallNotify = false
	self.m_StallFloatSilver = false
	self.m_StallLastCatalog = nil
	self.m_StallRecords = {}

	self.m_AuctionItemList = {}
	self.m_IsOpenAuctionUI = false
	self.m_AuctionNetCache = false
	self.m_AuctionTimer = nil
	self.m_AuctionProtoCache = nil

	self.m_TaskItems = {}
	self.m_TaskCatalogList = {}
	self.m_TargetTaskId = nil
	self.m_AuctionNotify = false
	self:RefreshStallNotify(false)
	self:RefreshAuctionNotify(false)
end

function CEcononmyCtrl.ShowView(self, cls, cb)
	local defaultIndex = self:GetDefaultTabIndex()
	if defaultIndex then
		CViewBase.ShowView(cls, cb)
	end
end

function CEcononmyCtrl.GetDefaultTabIndex(self)
	for i,v in ipairs(self.m_UnlockTab) do
		local open = g_OpenSysCtrl:GetOpenSysState(v)
		if open then
			return i
		end
	end
end

function CEcononmyCtrl.IsSpecityTabOpen(self, index)
	local openKey = self.m_UnlockTab[index]
	return g_OpenSysCtrl:GetOpenSysState(openKey)
end

function CEcononmyCtrl.ClearTargetItem(self)
	self.m_TargetGuildItem = nil
end

---------------------任务道具相关-----------------------------------
function CEcononmyCtrl.InitTaskItemList(self)
	local oTask = CTaskHelp.GetClickTaskShopSelect()
	local dTaskItem = g_TaskCtrl:GetAllTaskNeedItemDictionary(true, true)
	self:SetTargetTask(oTask and oTask:GetSValueByKey("taskid"))
	for taskid,taskItemList in pairs(dTaskItem) do
		local bIsStallItem = g_DialogueCtrl:GetIsStallItem(taskItemList)
		local bIsGuildItem = g_DialogueCtrl:GetIsGuildItem(taskItemList)
		local iType = define.Econonmy.Type.Stall
		if bIsGuildItem then
			iType = define.Econonmy.Type.Guild
		end
		if bIsStallItem or bIsGuildItem then
			self:AddTaskItemList(taskid, iType, taskItemList)
			if not self.m_TargetTaskId then
				self:SetTargetTask(taskid)
			end
			if self.m_TargetTaskId == taskid then
				-- printc("CEcononmyCtrl.InitTaskItemList")
				-- table.print(taskItemList)
				self.m_TargetStallItem = taskItemList[1]
			end
		end
	end
	-- table.print(self.m_TaskItems, "任务道具相关")
end

function CEcononmyCtrl.ClearTaskItemList(self)
	self.m_TaskItems = {}
	self.m_TaskCatalogList = {}
	self.m_TargetTaskId = nil
end

function CEcononmyCtrl.SetTargetTask(self, iTaskId)
	self.m_TargetTaskId = iTaskId	
end

function CEcononmyCtrl.AddTaskItemList(self, iTaskId, iType, tItemList)
	if not self.m_TaskItems[iType] then
		self.m_TaskItems[iType] = {}
	end
	if not self.m_TaskCatalogList[iType] then
		self.m_TaskCatalogList[iType] = {}
	end
	self.m_TaskItems[iType][iTaskId] = tItemList
	self.m_TaskCatalogList[iType][iTaskId] = DataTools.GetEcononmyCatalogListByTaskItems(iType, tItemList)
end

function CEcononmyCtrl.HasTaskItem(self, iType)
	return self.m_TaskItems[iType] ~= nil
end

function CEcononmyCtrl.IsTaskItem(self, iType, iItemId)
	if not self.m_TaskCatalogList[iType] then
		return false, false
	end
	for iTaskId,lItem in pairs(self.m_TaskItems[iType]) do
		for _,sid in ipairs(lItem) do
			if sid == iItemId then
				return true, iTaskId == self.m_TargetTaskId
			end
		end
	end
	return false, false
end

function CEcononmyCtrl.IsTaskCatalog(self, iType, iCatId)
	if not self.m_TaskCatalogList[iType] then
		return false
	end
	for iTaskId,lTaskCatalog in pairs(self.m_TaskCatalogList[iType]) do
		for _,dCatalogInfo in ipairs(lTaskCatalog) do
			if dCatalogInfo.cat_id == iCatId then
				return true
			end
		end
	end
	return false
end

function CEcononmyCtrl.IsTaskSubCatalog(self, iType, iCatId, iSubCatId)
	if not self.m_TaskCatalogList[iType] then
		return false
	end
	for _,lTaskCatalog in pairs(self.m_TaskCatalogList[iType]) do
		for _,dCatalogInfo in ipairs(lTaskCatalog) do
			if dCatalogInfo.cat_id == iCatId and dCatalogInfo.sub_id == iSubCatId then
				return true
			end
		end
	end
	return false
end

function CEcononmyCtrl.GetTargetTaskCatalog(self, iType)
	if not self.m_TargetTaskId or not self.m_TaskCatalogList[iType] or 
		not self.m_TaskCatalogList[iType][self.m_TargetTaskId] then
		return 1
	end
	local dCatalogInfo = self.m_TaskCatalogList[iType][self.m_TargetTaskId][1]
	return dCatalogInfo and dCatalogInfo.cat_id or 1
end

-------------------商会相关---------------------
function CEcononmyCtrl.SetGuildItemList(self, iCatId, iSubId, tData)
	self.m_GuildItemList[iCatId * 100 + iSubId] = tData
	self.m_GuildCatalog = iCatId
	self:OnEvent(define.Econonmy.Event.RefreshGuildItemList)
end

function CEcononmyCtrl.GetGuildItemList(self, iCatId, iSubId)
	local list = {}
	local lItem = self.m_GuildItemList[iCatId * 100 + iSubId]
	if not lItem then
		return list
	end
	for _,dItem in ipairs(lItem) do
		table.insert(list, dItem)
	end
	local function sort(dItem1, dItem2)
		if self.m_GuildCatalog == CEcononmyCtrl.GuildEquipCatalog then
			local dEquipData_1 = DataTools.GetItemData(dItem1.sid, "EQUIPBOOK")
			local dEquipData_2 = DataTools.GetItemData(dItem2.sid, "EQUIPBOOK")
			if dEquipData_1 and dEquipData_2 then
				local bIsMat_1 = dEquipData_1.sex == g_AttrCtrl.sex and dEquipData_1.school == g_AttrCtrl.school
				local bIsMat_2 = dEquipData_2.sex == g_AttrCtrl.sex and dEquipData_2.school == g_AttrCtrl.school
				if bIsMat_1 and not bIsMat_2 then
					return true
				elseif bIsMat_2 and not bIsMat_1 then
					return false
				end
			end
		end
		local dGuildData_1 = data.guilddata.ITEMINFO[dItem1.good_id]
		local dGuildData_2 = data.guilddata.ITEMINFO[dItem2.good_id]
		if dGuildData_1.sort == dGuildData_2.sort then
			return dItem1.good_id < dItem2.good_id	
		end
		return dGuildData_1.sort < dGuildData_2.sort
	end
	table.sort(list, sort)
	return list
end

function CEcononmyCtrl.UpdateGuildItem(self, sid, amount, price, up_flag, goodId, has_buy)
	local dItem = {
		sid = sid,
		amount = amount,
		price = price,
		up_flag = up_flag,
		good_id = goodId,
		has_buy = has_buy,
	}
	for i,lItemInfo in ipairs(self.m_GuildItemList) do
		for j,dItem in ipairs(lItemInfo) do
			if dInfo.good_id == goodId then
				self.m_GuildItemList[i][j] = dItem
				break
			end
		end
	end
	self:OnEvent(define.Econonmy.Event.RefreshGuildItem, dItem)
end

-------------------逛摊相关---------------------
function CEcononmyCtrl.SetStallCatalogInfo(self, pbdata)
	self.m_StallCatalogInfo = pbdata
	--点击刷新或者目标切换清空缓存
	if pbdata.cat_id ~= self.m_StallCatalog or pbdata.page == 1 then
		self.m_StallCatalog = pbdata.cat_id
		self.m_StallItemList = {}
	end
	self.m_StallItemList[pbdata.page] = pbdata.catalog
	self.m_StallPageCount = math.max(math.floor((pbdata.total - 1)/self.StallItemLimit) + 1, 1)
	self.m_LastRefreshTime = pbdata.refresh
	self:OnEvent(define.Econonmy.Event.RefreshStallItemList, {page = pbdata.page, catId = pbdata.cat_id})
end

function CEcononmyCtrl.GetStallItemListByPage(self, iPage)
	if not self.m_StallItemList[iPage] then
		return nil
	end
	local list = {}
	for _,dItem in ipairs(self.m_StallItemList[iPage]) do
		table.insert(list, dItem)
	end
	return list
end

function CEcononmyCtrl.GetStallPageCount(self)
	return self.m_StallPageCount 
end

function CEcononmyCtrl.GetLastRefreshTime(self)
	return self.m_LastRefreshTime or 0
end

function CEcononmyCtrl.UpdateStallItem(self, iCatId, dInfo)
	local iPos = dInfo.pos_id
	local iPage = math.floor((iPos - 1)/self.StallItemLimit) + 1
	local iIndex = (iPos - 1)%self.StallItemLimit + 1
	local list = self.m_StallItemList[iPage]
	list[iIndex] = dInfo
	self:OnEvent(define.Econonmy.Event.RefreshStallItem, iIndex)
end

-------------------摆摊相关---------------------
function CEcononmyCtrl.SetStallAllGrid(self, iSizeLimit, dGridInfo)
	self.m_StallUnlockGrid = iSizeLimit
	self.m_StallGridInfos = {}
	for i,v in ipairs(dGridInfo) do
		self.m_StallGridInfos[v.pos_id] = v
	end
	self:OnEvent(define.Econonmy.Event.RefreshStallSellGrid)
end

function CEcononmyCtrl.GetStallInfoByPos(self, iPos)
	return self.m_StallGridInfos[iPos]
end

function CEcononmyCtrl.SetStallUnlockSize(self, iSize)
	self.m_StallUnlockGrid = iSize
	self:OnEvent(define.Econonmy.Event.RefreshStallSellGrid)
end

function CEcononmyCtrl.GetStallUnlockSize(self)
	return self.m_StallUnlockGrid
end

function CEcononmyCtrl.UpdateStallSellItem(self, dInfo)
	local iFloatCnt = 0
	local dCurInfo = self.m_StallGridInfos[dInfo.pos_id]
	if dCurInfo and dCurInfo.cash > 0 and dInfo.cash == 0 then
		iFloatCnt = 1
	end
	if dInfo.amount == 0 and dInfo.cash == 0 then
		self.m_StallGridInfos[dInfo.pos_id] = nil
	else
		self.m_StallGridInfos[dInfo.pos_id] = dInfo
	end
	self:OnEvent(define.Econonmy.Event.RefreshStallSellGrid, iFloatCnt)
end

function CEcononmyCtrl.GetRemainingGridCount(self)
	return self.m_StallUnlockGrid - table.count(self.m_StallGridInfos)
end

function CEcononmyCtrl.WithdrawAllCash(self, cash_list)
	local iFloatCnt = 0
	for i,cashInfo in ipairs(cash_list) do
		local dGridInfo = self.m_StallGridInfos[cashInfo.pos_id]
		if dGridInfo then
			if dGridInfo.cash > 0 then
				iFloatCnt = iFloatCnt + 1
			end
			self.m_StallGridInfos[cashInfo.pos_id].cash = 0
			if cashInfo.cash == 0 and dGridInfo.amount == 0 then
				self.m_StallGridInfos[cashInfo.pos_id] = nil
			end
		end
	end
	self:OnEvent(define.Econonmy.Event.RefreshStallSellGrid, iFloatCnt)
end

function CEcononmyCtrl.RefreshStallNotify(self, bIsSell)
	self.m_StallNotify = bIsSell
	self:OnEvent(define.Econonmy.Event.RefreshStallNotify)
end

function CEcononmyCtrl.GetStallOverTimeItemList(self)
	local lItem = {}
	for i,dGridInfo in pairs(self.m_StallGridInfos) do
		if self:IsStallOverTime(dGridInfo.pos_id) then
			local SData = {
				amount = dGridInfo.amount,
				desc = "",
				id = - i - 10,
				itemlevel = dGridInfo.quality,
				name = "",
				pos = -1,
				sid = dGridInfo.sid,
				stallpos = dGridInfo.pos_id,
				stallprice = dGridInfo.price,
				stallId = dGridInfo.query_id,
			}
			local oItem = CItem.New(SData)
			table.insert(lItem, oItem)
		end
	end
	return lItem
end

function CEcononmyCtrl.IsStallOverTime(self, iPos)
	local dGridInfo = self:GetStallInfoByPos(iPos)
	local iOverTime = tonumber(DataTools.GetGlobalData(108).value)
	local iLeftTime = math.floor(os.difftime(g_TimeCtrl:GetTimeS(), dGridInfo.sell_time)/(60))
	return dGridInfo.cash == 0 and iLeftTime > iOverTime 
end

-------------------系统拍卖相关---------------------
function CEcononmyCtrl.SetAuctionItemList(self, lAuctionItem)
	self.m_AuctionItemList = lAuctionItem
	--Test
	-- if true then
	-- 	local t = {
	-- 	 id = 11,
 --         money_type = 3,
 --         price = 25001,
 --         price_time = g_TimeCtrl:GetTimeS() + 60,
 --         show_time = g_TimeCtrl:GetTimeS() + 20,
 --         view_time = g_TimeCtrl:GetTimeS(),
 --         sid = 5002,
 --         type = 2,
 --         quality = 1,
 --     	}
 --     	table.insert(self.m_AuctionItemList, t)
 --     	local t = {
	-- 	 id = 11,
 --         money_type = 3,
 --         price = 25001,
 --         price_time = g_TimeCtrl:GetTimeS() + 120,
 --         show_time = g_TimeCtrl:GetTimeS() + 100,
 --         view_time = g_TimeCtrl:GetTimeS() + 30,
 --         sid = 5002,
 --         type = 2,
 --         quality = 1
 --     	}
 --     	table.insert(self.m_AuctionItemList, t)
	-- end
	self:OnEvent(define.Econonmy.Event.RefreshAuctionItemList)
end

function CEcononmyCtrl.GetAuctionItemList(self)
	local list = {}
	if not self.m_AuctionItemList then
		return list
	end
	for _,dItem in ipairs(self.m_AuctionItemList) do
		table.insert(list, dItem)
	end
	local function sort(dItem1, dItem2)
		local bInAuctionTime_1 = self:IsInAuctionTime(dItem1)
		local bInAuctionTime_2 = self:IsInAuctionTime(dItem2)
		if bInAuctionTime_1 and bInAuctionTime_2 then
			if dItem1.money_type == dItem2.money_type then
				if dItem1.price_time == dItem2.price_time then
					return dItem1.sys_idx < dItem2.sys_idx
				end
				return dItem1.price_time < dItem2.price_time
			end
			return dItem1.money_type > dItem2.money_type
		elseif bInAuctionTime_1 and not bInAuctionTime_2 then
			return true
		elseif not bInAuctionTime_1 and not bInAuctionTime_2 then
			if dItem1.money_type == dItem2.money_type then
				if dItem1.show_time == dItem2.show_time then
					return dItem1.sys_idx < dItem2.sys_idx
				end
				return dItem1.show_time < dItem2.show_time
			end
			return dItem1.money_type > dItem2.money_type
		end
	end
	table.sort(list, sort)
	return list
end

function CEcononmyCtrl.GetIndexByAuctionId(self, iAuctionId)
	for i,dItem in pairs(self.m_AuctionItemList) do
		if dItem.id == iAuctionId then
			return i
		end 
	end
end

function CEcononmyCtrl.GetAuctionItemById(self, iAuctionId)
	local iIndex = self:GetIndexByAuctionId(iAuctionId)
	if iIndex then
		return self.m_AuctionItemList[iIndex]
	end
end

function CEcononmyCtrl.UpdateAuctionItem(self, dAuctionItem)
	local iIndex = self:GetIndexByAuctionId(dAuctionItem.id)
	if iIndex then
		self.m_AuctionItemList[iIndex] = dAuctionItem
	end
	self:OnEvent(define.Econonmy.Event.RefreshAuctionItem, dAuctionItem)
end

function CEcononmyCtrl.UpdateAuctionPrice(self, iAuctionId, iPrice, iPriceTime, iBidder)
	if g_EcononmyCtrl.m_AuctionNetCache then
		self.m_AuctionProtoCache = {id = iAuctionId, price = iPrice, time = iPriceTime, bidder = iBidder}
		return
	end

	local iIndex = self:GetIndexByAuctionId(iAuctionId)
	if iIndex then
		self.m_AuctionItemList[iIndex].price = iPrice
		self.m_AuctionItemList[iIndex].price_time = iPriceTime
		self.m_AuctionItemList[iIndex].bidder = iBidder

		local dAuctionItem = self.m_AuctionItemList[iIndex]
		if not self:IsUseProxy(dAuctionItem) and  self:IsHighestBidder(dAuctionItem) then
			if self.m_AuctionTimer then
				Utils.DelTimer(self.m_AuctionTimer)
				self.m_AuctionTimer = nil
			end
			g_EcononmyCtrl.m_AuctionNetCache = true
			local function resume()
				g_EcononmyCtrl.m_AuctionNetCache = false
				if g_EcononmyCtrl.m_AuctionProtoCache then
					local dProto = g_EcononmyCtrl.m_AuctionProtoCache
					g_EcononmyCtrl:UpdateAuctionPrice(dProto.id, dProto.price, dProto.time, dProto.bidder)
					g_EcononmyCtrl.m_AuctionProtoCache = nil
				end
			end
			self.m_AuctionTimer = Utils.AddTimer(resume, 0, 1)
		end
	end
	self:OnEvent(define.Econonmy.Event.RefreshAuctionPrice, self.m_AuctionItemList[iIndex])
	if not CEcononmyMainView:GetView() then
		self:RefreshAuctionNotify(true)
	end
end

function CEcononmyCtrl.IsInShowTime(self, dAuctionItem)
	local iCurTime = g_TimeCtrl:GetTimeS()
	return dAuctionItem.show_time >= iCurTime
end

function CEcononmyCtrl.IsInAuctionTime(self, dAuctionItem)
	local iCurTime = g_TimeCtrl:GetTimeS()
	return dAuctionItem.show_time < iCurTime and dAuctionItem.price_time >= iCurTime
end

function CEcononmyCtrl.IsOverTime(self, dAuctionItem)	
	return dAuctionItem.price_time < g_TimeCtrl:GetTimeS()
end

function CEcononmyCtrl.IsUseProxy(self, dAuctionItem)
	return dAuctionItem.proxy_bidder == g_AttrCtrl.pid
end

function CEcononmyCtrl.IsHighestBidder(self, dAuctionItem)
	return dAuctionItem.bidder == g_AttrCtrl.pid
end

function CEcononmyCtrl.C2GSCloseAuctionUI(self)
	if self.m_IsOpenAuctionUI then
		netauction.C2GSCloseAuctionUI()
	end
end

function CEcononmyCtrl.RefreshAuctionNotify(self, bIsPriceChange)
	self.m_AuctionNotify = bIsPriceChange
	self:OnEvent(define.Econonmy.Event.RefreshAuctionNotify)
end
return CEcononmyCtrl
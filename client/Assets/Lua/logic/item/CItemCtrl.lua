 local CItemCtrl = class("CItemCtrl", CCtrlBase)

-- 1-100 玩家已穿戴装备数据 | 101-&&道具数据
function CItemCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_BagTypeEnum = {all = "all", equip = "equip", consume = "consume"}
	self.m_ItemBoxTypeEnum = {equip = {1}, consume = {2}, war = {3}, wenshi = {4}}
	self.m_BagAllCount = tonumber(DataTools.GetGlobalData(101).value or 250)
	self.m_BagOpenCount = tonumber(DataTools.GetGlobalData(105).value or define.Item.Constant.BagFixCount)
	self.m_BagLockCount = define.Item.Constant.BagLockCount

	self:Reset()
end

function CItemCtrl.Reset(self)
	-- 重登需要清理的數據
	self.m_ItemEffRecord = {}
	self.m_ItemEffList = {}
	self.m_ItemRedList = {}
	self.m_ItemEquipRedList = {}
	self.m_RefreshTimer = nil
	self.m_RefreshWHTimer = nil
	self.m_CurrClickBox = nil
	self.m_CurrClickItem = nil
	self.m_LastClickBox = nil
	-- 分页记录
	self.m_RecordItemPartTab = 0
	-- 道具
	self.m_BagSclyRelative = nil
	-- self.m_BagItems = {}

	-- 仓库
	self.m_WHCellOpenCount = 3
	self.m_RecordWHIndex = 1
	self.m_WHNameList = {}
	self.m_WHItems = {}
	--玩家打造装备
	self.m_FloatItemList = nil
	self.m_BagItems = {}
	--装备
	self.m_EquipedItems = {}

	--装备打造
	self.m_ForgeItems = {}
	self.m_ForgeUIRecord = {}
	self.m_QuickForge = false

	--装备洗炼
	self.m_EquipWashInfo = {}

	--附魂
	self.m_AttachSoulItems = {}
	--强化
	self.m_StrengthenInfo = {}
	--炼化
	self.m_RefineList = {}
	self.m_ShowRefineRedPoint = false
	--魂石合成、混合保护设置
	self.m_ComposeProtect = false
	self.m_MixProtect = false

	self.m_UpgardePackConfigList = {}
	self.m_ItemQuickUseEndCbList = {}
	self.m_ItemPriceDict = {}

	self.m_ItemQuickUseWaitList = {}

	self:CheckJifenConfig()

	--重登会清，重连也会清
	if CItemMainView:GetView() then
		self.m_IsHasOpenItemBagView = true
	else
		self.m_IsHasOpenItemBagView = false
	end
end

function CItemCtrl.AddItemQuickUseEndCbList(self, cb)
	table.insert(self.m_ItemQuickUseEndCbList, cb)
end

-- 本地记录
function CItemCtrl.GetItemEffRecord(self)
	self.m_ItemEffRecord = IOTools.GetRoleData("item_EffRecord") or {}
	self:ResetItemUIEffList()
end

function CItemCtrl.ResetItemUIEffList(self)
	self.m_ItemEffList = {}
	self.m_ItemRedList = {}
	self:OnEvent(define.Item.Event.RefreshBagItem)
end

function CItemCtrl.SavaItemEffRecord(self, itemEffRecord)
	IOTools.SetRoleData("item_EffRecord", itemEffRecord)
end

function CItemCtrl.IsItemEff(self, id)
	return table.index(self.m_ItemEffList, id)
end

function CItemCtrl.RemoveItemEff(self, id)
	local index = self:IsItemEff(id)
	if index then   
		table.remove(self.m_ItemEffList, index)
	end
end

function CItemCtrl.IsItemRed(self, id)
	return table.index(self.m_ItemRedList, id)
end

function CItemCtrl.RemoveItemRed(self, id)
	local index = self:IsItemRed(id)
	if index then
		table.remove(self.m_ItemRedList, index)
	end
	
	-- local oItem = self.m_BagItems[id]
	-- if oItem then
	-- 	local bagItemList = self:GetBagItemListBySid(oItem:GetSValueByKey("sid"))
	-- 	for _,v in ipairs(bagItemList) do
	-- 		local index = self:IsItemRed(v:GetSValueByKey("id"))
	-- 		if index then
	-- 			table.remove(self.m_ItemRedList, index)
	-- 		end
	-- 		self:OnEvent(define.Item.Event.RefreshSpecificItem, v)
	-- 	end
	-- end
end

-- 移动到最近的红点道具位置(背包道具从101开始，返回位置需要减掉100)
function CItemCtrl.GetTopOfTheRedList(self)
	local itemPos = nil
	for _,v in ipairs(self.m_ItemEffList) do
		local oItem = self.m_BagItems[v]
		local pos = oItem:GetSValueByKey("pos")
		if itemPos then
			if itemPos > pos then
				itemPos = pos
			end
		else
			itemPos = pos
		end
	end
	for _,v in ipairs(self.m_ItemRedList) do
		local oItem = self.m_BagItems[v]
		local pos = oItem:GetSValueByKey("pos")
		if itemPos then
			if itemPos > pos then
				itemPos = pos
			end
		else
			itemPos = pos
		end
	end
	if itemPos then
		itemPos = itemPos - 100
	end
	return itemPos
end

-- [[服务器数据接收处理]]
-- 处理道具数据
function CItemCtrl.LoginItem(self, extsize, itemdata)
	-- printc(" -----。。。 登陆道具数据信息")
	if g_AttrCtrl.pid and g_AttrCtrl.pid > 0 then
		self:GetItemEffRecord()
	else
		local function check()
			if not g_AttrCtrl.pid or g_AttrCtrl.pid <= 0 then
				return true
			end
			self:GetItemEffRecord()
			return false
		end
		Utils.AddTimer(check, 0.1, 0.1)
	end

	self:InitItems(itemdata)
	self:ExtBagSize(extsize)

	g_ForgeCtrl:ResetAllInlayRedPointStatus()
end

function CItemCtrl.InitItems(self, itemdata)
	if itemdata then
		local isRefresh = false
		local itemDic = {}
		self.m_EquipedItems = {}
		for i, dItem in ipairs(itemdata) do
			local oItem = CItem.New(dItem, CItem.TypeEnum[2])
			itemDic[dItem.id] = oItem
			if not isRefresh and oItem:IsBagItemPos() then
				isRefresh = true
			end
			if oItem:IsEquiped() then
			-- self.m_EquipedItems[itemdata.pos] = oItem
				self:SetEquipedItem(dItem.pos, oItem)
			end
		end
		self.m_BagItems = itemDic
		if isRefresh then
			self:RefreshUI()
		end
		g_TaskCtrl:CheckFindItem()
	end
end

function CItemCtrl.ExtBagSize(self, extsize)
	local fixCount = tonumber(DataTools.GetGlobalData(105).value or define.Item.Constant.BagFixCount)
	self.m_BagOpenCount = fixCount + extsize
	self.m_BagLockCount = self.m_BagAllCount - self.m_BagOpenCount
	if self.m_BagLockCount > 0 and define.Item.Constant.BagLockCount > 0 then
		for i=define.Item.Constant.BagLockCount,1,-5 do
			if self.m_BagLockCount >= i then
				self.m_BagLockCount = i
				break
			end
		end
	else
		self.m_BagLockCount = 0
	end
	self:OnEvent(define.Item.Event.RefreshBagBox, extsize)
end

function CItemCtrl.GS2CAddItem(self, itemdata, fromWh, refresh)
	if itemdata then
		local id = itemdata.id
		if self.m_BagItems[id] then
			printc("道具更新 >>> 道具ID:", id)
			-- return
		end
		local oItem = CItem.New(itemdata, CItem.TypeEnum[2])
		self.m_BagItems[id] = oItem
		g_GuideHelpCtrl.m_GuideEquipList[id] = oItem
		g_GuideHelpCtrl.m_GuideEquipHashList[oItem:GetSValueByKey("sid")] = oItem
		--刷新状态下无需播放入袋动画，如强化，洗炼操作
		if (refresh == nil or refresh == 0) and fromWh ~= 1 then
			g_NotifyCtrl:FloatItemBox(oItem:GetCValueByKey("icon"))
		end
		if oItem:IsEquiped() then
			-- self.m_EquipedItems[itemdata.pos] = oItem
			self:SetEquipedItem(itemdata.pos, oItem)
		end

		-- if oItem:IsEngageRing() then
		-- 	local pos = oItem.m_SData.pos
		-- 	table.insert(self.m_ItemEquipRedList, pos)
		-- end
	
		if oItem:IsBagItemPos() then
			local sid = oItem:GetSValueByKey("sid")
			if fromWh == 0 then
				if table.index(self.m_ItemEffRecord, sid) then
					if not self:IsItemRed(id) then
						table.insert(self.m_ItemRedList, id)
					end
				else
					table.insert(self.m_ItemEffList, id)
					table.insert(self.m_ItemEffRecord, sid)
					self:SavaItemEffRecord(self.m_ItemEffRecord)
				end
			end
			self:RefreshUI()					
			g_TaskCtrl:CheckFindItem()
			if oItem:IsForgeMaterial() then
				self:ResetForgeItemInfo()
			end
			if DataTools.GetItemData(sid, "PARTNER") and sid <= 30660 then --玄元晶以内
				g_PartnerCtrl:ResetRedPointStatus()
				g_PromoteCtrl:UpdatePromoteData(8)
				g_PromoteCtrl:UpdatePromoteData(9)
			end
			g_PartnerCtrl:ResetAllEquipRedPointByItem(oItem.m_SID)
			if oItem:IsFormationItem() then
				g_FormationCtrl:CheckFormationGuide()
			end

			if oItem:IsGemStone() then
				g_ForgeCtrl:ResetAllInlayRedPointStatus()
			end

			self:OnEvent(define.Item.Event.AddBagItem, oItem)
		end
		self:OnEvent(define.Item.Event.AddItem, oItem)

		--引导相关
		local sid = oItem:GetSValueByKey("sid")
		local tItemData = DataTools.GetItemData(sid, "EQUIP")
		if table.index(g_GuideHelpCtrl:GetEquipNewQuickUseList(), sid) and tItemData.roletype == g_AttrCtrl.roletype then
			if not g_GuideCtrl.m_Flags["EquipGetNew"] then
				self:AddQuickUseData(oItem)
			end			
		end

		-- local oHasPlay = g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("hasplay")
		-- local oNotPlay = g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("notplay")
		if table.index(g_GuideHelpCtrl:GetEquip10QuickUseList(), sid) and tItemData.roletype == g_AttrCtrl.roletype then
			-- if (oNotPlay and g_GuideCtrl.m_Flags["UseItem10"] and not g_GuideCtrl.m_Flags["EquipGet10"]
			-- and not g_GuideCtrl.m_Flags["EquipGet20"] and not g_GuideCtrl.m_Flags["EquipGet30"] and not g_GuideCtrl.m_Flags["EquipGet40"]) or oHasPlay then
				if g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem10SelectItemSid()] then
					self:AddQuickUseData(oItem, g_GuideHelpCtrl:GetItem10SelectItemSid())
					g_ItemCtrl:AddItemQuickUseEndCbList(function ()
			 			 g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem10SelectItemSid()] = nil
			 		end)
				end
			-- end		
		end

		if table.index(g_GuideHelpCtrl:GetEquip20QuickUseList(), sid) and tItemData.roletype == g_AttrCtrl.roletype then
			if g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem20SelectItemSid()] then
				self:AddQuickUseData(oItem, g_GuideHelpCtrl:GetItem20SelectItemSid())
				g_ItemCtrl:AddItemQuickUseEndCbList(function ()
		 			 g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem20SelectItemSid()] = nil
		 		end)
			end			
		end

		if table.index(g_GuideHelpCtrl:GetEquip30QuickUseList(), sid) and tItemData.roletype == g_AttrCtrl.roletype then
			if g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem30SelectItemSid()] then
				self:AddQuickUseData(oItem, g_GuideHelpCtrl:GetItem30SelectItemSid())
				g_ItemCtrl:AddItemQuickUseEndCbList(function ()
		 			 g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem30SelectItemSid()] = nil
		 		end)
			end			
		end

		if table.index(g_GuideHelpCtrl:GetEquip40QuickUseList(), sid) and tItemData.roletype == g_AttrCtrl.roletype then
			if g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem40SelectItemSid()] then
				self:AddQuickUseData(oItem, g_GuideHelpCtrl:GetItem40SelectItemSid())
				g_ItemCtrl:AddItemQuickUseEndCbList(function ()
		 			 g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem40SelectItemSid()] = nil
		 		end)
			end		
		end

		if g_GuideHelpCtrl:GetItem1SelectItemSid() and g_GuideHelpCtrl:GetItem1SelectItemSid() == oItem:GetSValueByKey("sid") then
			if not g_GuideCtrl.m_Flags["UseItem"] then
				self:AddQuickUseData(oItem)
			end			
		end

		g_GuideCtrl:OnTriggerAll()
		g_GuideHelpCtrl:CheckAllNotifyGuide()
	end
end

function CItemCtrl.GS2CDelItem(self, id)
	if not self.m_BagItems[id] then
		printerror("道具删 >>> 不存在道具ID:", id)
		return
	end

	local redKey = self:IsItemRed(id)
	if redKey then
		table.remove(self.m_ItemRedList, redKey)
	end
	local effKey = self:IsItemEff(id)
	if effKey then
		table.remove(self.m_ItemEffList, effKey)
	end
	local oItem = self.m_BagItems[id]
	local sid = oItem:GetSValueByKey("sid")

	local redKey = table.index(self.m_ItemEffRecord, sid)
	if not redKey then
		table.insert(self.m_ItemEffRecord, sid)
	end
	self.m_BagItems[id] = nil
	self.m_EquipedItems[oItem.m_SData.pos] = nil
	g_GuideHelpCtrl.m_GuideEquipList[id] = nil
	g_GuideHelpCtrl.m_GuideEquipHashList[sid] = nil
	-- if oItem:IsEngageRing() then
	-- 	self:RefreshUI()
	-- 	self:OnEvent(define.Item.Event.RefreshEquip)
	-- end
	if oItem:IsBagItemPos() then
		self:RefreshUI()
		g_TaskCtrl:CheckFindItem()
		if oItem:IsForgeMaterial() then
			self:ResetForgeItemInfo()
		end
	end
	if DataTools.GetItemData(sid, "PARTNER") and sid <= 30660 then --玄元晶以内
		g_PartnerCtrl:ResetRedPointStatus()
		g_PromoteCtrl:UpdatePromoteData(8)
		g_PromoteCtrl:UpdatePromoteData(9)
	end
	if oItem:IsFormationItem() then
		g_FormationCtrl:CheckFormationGuide()
	end
	g_PartnerCtrl:ResetAllEquipRedPointByItem(oItem.m_SID)
	if oItem:IsGemStone() then
		g_ForgeCtrl:ResetAllInlayRedPointStatus()
	end
	self:OnEvent(define.Item.Event.DelItem, id)
	g_GuideCtrl:OnTriggerAll()
	g_GuideHelpCtrl:CheckAllNotifyGuide()
end


function CItemCtrl.GS2CItemAmount(self, id, amount, fromWh, refresh)
	local oItem = self.m_BagItems[id]
	if not oItem then
		printerror("道具改 >>> 不存在道具ID:", id)
		return
	end
	if oItem:IsBagItemPos() then
		if fromWh == 0 then
			if amount > oItem.m_SData.amount then
				---//物品飘落动画
				local sid = oItem:GetSValueByKey("sid")

				if (refresh == nil or refresh == 0) then
					g_NotifyCtrl:FloatItemBox(oItem:GetCValueByKey("icon"))
				end
				
				if table.index(self.m_ItemEffRecord, sid) then
					if not self:IsItemRed(id) then
						table.insert(self.m_ItemRedList, id)
					end
				else
					table.insert(self.m_ItemEffRecord, sid)
				end
			end
		end

		oItem.m_AmountChange = amount - oItem.m_SData.amount
		oItem.m_SData.amount = amount
		self:OnEvent(define.Item.Event.RefreshSpecificItem, oItem)
		g_SummonCtrl:OnEvent(define.Summon.Event.BagItemUpdate, oItem) --发送消息给宠物UI		
		g_TaskCtrl:CheckFindItem()
		if DataTools.GetItemData(oItem.m_SID, "PARTNER") and oItem.m_SID <= 30660 then --玄元晶以内
			g_PartnerCtrl:ResetRedPointStatus()
			g_PromoteCtrl:UpdatePromoteData(8)
			g_PromoteCtrl:UpdatePromoteData(9)
		end
		g_PartnerCtrl:ResetAllEquipRedPointByItem(oItem.m_SID)
	end
	local sid = oItem:GetSValueByKey("sid")
	self:OnEvent(define.Item.Event.ItemAmount, sid)

	g_GuideCtrl:OnTriggerAll()
	g_GuideHelpCtrl:CheckAllNotifyGuide()
end

function CItemCtrl.UpdateEquipLast(self, id, last)
	local oItem = self.m_BagItems[id]
	if oItem then
		oItem.m_SData.equip_info.last = last
		self.m_BagItems[id] = oItem
		self:OnEvent(define.Item.Event.RefreshEquipLast)
	end
end

function CItemCtrl.ItemQuickUse(self, id)
	local oItem = self.m_BagItems[id]
	if not oItem then
		printerror("道具快捷 >>> 不存在唯一道具ID:", id)
		return
	end

	self:AddQuickUseData(oItem)
	
	self:OnEvent(define.Item.Event.QuickUse)
end

function CItemCtrl.GS2CItemArrange(self, posInfo)
	if posInfo and #posInfo > 0 then
		for _,v in ipairs(posInfo) do
			local oItem = self.m_BagItems[v.itemid]
			if oItem then
				if oItem:IsEquiped() and self:GetEquipedByPos(oItem.m_SData.pos) == oItem then
					self:SetEquipedItem(oItem.m_SData.pos, nil)
					-- self.m_EquipedItems[oItem.m_SData.pos] = nil
				end
				oItem.m_SData.pos = v.pos
				if oItem:IsEquiped() then
					-- self.m_EquipedItems[oItem.m_SData.pos] = oItem
					self:SetEquipedItem(oItem.m_SData.pos, oItem)
				end
			else
				printerror("道具整理 >>> 不存在道具ID:", v.itemid)
			end
		end
		self:OnEvent(define.Item.Event.TabSwitch)
		self:RefreshUI()
		g_TaskCtrl:CheckFindItem()
	end
end

-- 处理仓库数据
function CItemCtrl.WareHouseLogin(self, size, namelist)
	self.m_WHCellOpenCount = size
	self.m_WHNameList = namelist
	self:OnEvent(define.Item.Event.RefreshWHCell)
end

function CItemCtrl.GS2CRefreshWareHouse(self, wid, name, whdata)
	if whdata then
		local list = {}
		for i, dItem in ipairs(whdata) do
			local oItem = CItem.New(dItem, CItem.TypeEnum[3])
			list[dItem.id] = oItem
		end
		self.m_WHItems[wid] = list
		self:RefreshWhUI()
	end
end

function CItemCtrl.GS2CWHItemAmount(self, wid, id, amount)
	if not self.m_WHItems[wid] then
		-- printerror("仓库道具数量变更 >>> 不存在仓库ID:", wid)
		return
	end
	local oItem = self.m_WHItems[wid][id]
	if not oItem then
		-- printerror("仓库道具数量变更 >>> 不存在道具ID:", itemid)
		return
	end
	oItem.m_SData.amount = amount
	self:RefreshWhUI()
end

function CItemCtrl.AddWareHouseItem(self, wid, itemdata)
	if itemdata then
		if not self.m_WHItems[wid] then
			self.m_WHItems[wid] = {}
		end
		if self.m_WHItems[wid][itemdata.id] then
			printerror("仓库增 >>> 已存在道具ID:", itemdata.id)
			return
		end
		local oItem = CItem.New(itemdata, CItem.TypeEnum[3])
		self.m_WHItems[wid][itemdata.id] = oItem
		self:RefreshWhUI()
	end
end

function CItemCtrl.GS2CUpdateWHItem(self, wid, itemdata)
	if itemdata then
		if not self.m_WHItems[wid] then
			printerror("仓库更 >>> 未存在道具ID:", itemdata.id)
			return
		end
		local oItem = CItem.New(itemdata, CItem.TypeEnum[3])
		self.m_WHItems[wid][itemdata.id] = oItem
		self:RefreshWhUI()
	end
end

function CItemCtrl.GS2CDelWareHouseItem(self, wid, itemid)
	if not self.m_WHItems[wid] then
		printerror("仓库删 >>> 不存在仓库ID:", wid)
		return
	end
	if not self.m_WHItems[wid][itemid] then
		printerror("仓库删 >>> 不存在道具ID:", itemid)
		return
	end
	self.m_WHItems[wid][itemid] = nil
	self:RefreshWhUI()
end

function CItemCtrl.GS2CWHItemArrange(self, wid, posInfo)
	if posInfo and #posInfo > 0 then
		local whitems = self.m_WHItems[wid]
		for _,v in ipairs(posInfo) do
			local oItem = whitems[v.itemid]
			if oItem then
				oItem.m_SData.pos = v.pos
			else
				printerror("仓库整理 >>> 不存在道具ID:", v.itemid)
			end
		end
		self:RefreshWhUI()
		self:OnEvent(define.Item.Event.TabSwitch)
	end
end

function CItemCtrl.GS2CWareHouseName(self, wid, name)
	if not self.m_WHItems[wid] then
		printerror("仓库改名 >>> 不存在仓库ID:", wid)
		return
	end
	self.m_WHNameList[wid] = name
	self:OnEvent(define.Item.Event.RefreshWHName, {wid = wid, name = name})
end

-- 废弃
function CItemCtrl.GS2CItemGoldCoinPrice(self, pbdata)
	self.m_ItemPriceDict[pbdata.sid] = pbdata.goldcoin
	self:OnEvent(define.Item.Event.ReceiveGoldCoinPrice, pbdata)
end

-- [[客户端数据发送处理]]
-- 道具
function CItemCtrl.ItemArrage(self)
	netitem.C2GSItemArrage()
	-- 需求：整理后红点全部消失
	-- 检查道具中红点道具
	self:OnEvent(define.Item.Event.CheckBagRedDot)
	self.m_ItemRedList = {}
end

function CItemCtrl.AddItemExtendSize(self, size)
	netitem.C2GSAddItemExtendSize(size)
end

function CItemCtrl.DeComposeItem(self, id, amount)
	netitem.C2GSDeComposeItem(id, amount)
end

function CItemCtrl.ComposeItem(self, id, amount)
	netitem.C2GSComposeItem(id, amount)
end

-- 存入仓库
function CItemCtrl.C2GSWareHouseWithStore(wid, itemid)
	netwarehouse.C2GSWareHouseWithStore(wid, itemid)
end

--从仓库取出
function CItemCtrl.C2GSWareHouseWithDraw(wid, pos)
	netwarehouse.C2GSWareHouseWithDraw(wid,pos)
end

-- [[数据逻辑处理]]
function CItemCtrl.GetBagItemListByType(self, sType)
	local list = {}
	local insert = false
	for _, oItem in pairs(self.m_BagItems) do
		if oItem:IsBagItemPos() then
			if sType == g_ItemCtrl.m_BagTypeEnum.equip then
				insert = oItem:IsUIEquip()
			elseif sType == g_ItemCtrl.m_BagTypeEnum.consume then
				insert = oItem:IsUIConsume()
			else
				insert = true
			end
			if insert then
				table.insert(list, oItem)
			end
		end
	end
	return list
end

--获取纹饰道具
function CItemCtrl.GetBagWenShiData(self)
	
	local dataList = {}
	local wenshiConfig = data.itemwenshidata.WENSHI
	for id, oItem in pairs(self.m_BagItems) do
		local sid = oItem.m_SID
		local wenshi = wenshiConfig[sid]
		if wenshi then 
			dataList[id] = oItem
		end 
	end

	return dataList

end

function CItemCtrl.IsWenShiItem(self, id)
	
	local wenshiConfig = data.itemwenshidata.WENSHI
	local wenshiItem = self.m_BagItems[id]
	if wenshiItem then 
		local sid = wenshiItem.m_SID
		local wenshi = wenshiConfig[sid]
		if wenshi then 
			return true
		end 
	end 

	return false

end


-- [[控制器获取数据]]
function CItemCtrl.GetBagOpenCount(self)
	return self.m_BagOpenCount
end

function CItemCtrl.GetBagLockCount(self)
	return self.m_BagLockCount
end

function CItemCtrl.GetWHCellOpenCount(self)
	return self.m_WHCellOpenCount
end

-- [[界面刷新]]
function CItemCtrl.RefreshUI(self)
	if self.m_RefreshTimer then
		Utils.DelTimer(self.m_RefreshTimer)
	end
	local function update()
		self:OnEvent(define.Item.Event.RefreshBagItem)
		g_SummonCtrl:OnEvent(define.Summon.Event.BagItemUpdate)	
		return false
	end
	self.m_RefreshTimer = Utils.AddTimer(update, 0.1, 0.2)
end

function CItemCtrl.RefreshWhUI(self)
	if self.m_RefreshWHTimer then
		Utils.DelTimer(self.m_RefreshWHTimer)
	end
	local function update()
		self:OnEvent(define.Item.Event.RefreshWHData)
		return false
	end
	self.m_RefreshWHTimer = Utils.AddTimer(update, 0.1, 0.2)
end

-- [[模块支持]]
-- 返回服务器id为key的table(t = {id=oItem, ...})
function CItemCtrl.GetBagItemTableByIdList(self, idList)
	if idList and #idList > 0 then
		local t = {}
		for _,v in ipairs(idList) do
			local oItem = self.m_BagItems[v]
			if oItem and not oItem:IsEquiped() then
				t[v] = oItem
			end
		end
		return t
	end
end

-- 返回道具id为key的table(t = {sid={oItem1, oItem2, ...}, ...})
function CItemCtrl.GetBagItemTableBySidList(self, sidList, oLimitQuality)
	if sidList and #sidList > 0 then
		if self.m_BagItems then
			local t = {}
			for _,v in pairs(self.m_BagItems) do
				local sid = v:GetSValueByKey("sid")
				if table.index(sidList, sid) and not v:IsEquiped() and (not oLimitQuality or (oLimitQuality and v:GetQuality() <= oLimitQuality )) then
						if not t[sid] then
						t[sid] = {}
					end
					table.insert(t[sid], v)
				end
			end
			return t
		end
	end
end

-- 返回指定sid的list(oItem1, oItem2)
function CItemCtrl.GetBagItemListBySid(self, sid, oLimitQuality)
	if sid or sid > 0 then
		local list = {}
		for _,v in pairs(self.m_BagItems) do
			if sid == v:GetSValueByKey("sid") and not v:IsEquiped() and (not oLimitQuality or (oLimitQuality and v:GetQuality() <= oLimitQuality) ) then
				table.insert(list, v)
			end
		end
		return list
	end
end

function CItemCtrl.GetGuideEquipItemListBySid(self, sid)
	if sid or sid > 0 then
		local list = {}
		-- for _,v in pairs(g_GuideHelpCtrl.m_GuideEquipList) do
		-- 	if sid == v:GetSValueByKey("sid") and not v:IsEquiped() then
		-- 		table.insert(list, v)
		-- 	end
		-- end
		local oItem = g_GuideHelpCtrl.m_GuideEquipHashList[sid]
		if oItem and not oItem:IsEquiped() then
			table.insert(list, oItem)
		end
		return list
	end
	return {}
end

-- 返回指定组id的list(oItem1, oItem2)
function CItemCtrl.GetBagItemListByGroupid(self, groupid, oLimitQuality)
	if groupid or groupid > 0 then
		local itemgroups = DataTools.GetItemGroup(groupid)
		local list = {}
		for _,sid in ipairs(itemgroups.itemgroup) do
			for _,oItem in pairs(self.m_BagItems) do
				--会屏蔽已经穿上的装备
				if sid == oItem:GetSValueByKey("sid") and not oItem:IsEquiped() and (not oLimitQuality or (oLimitQuality and oItem:GetQuality() <= oLimitQuality )) then
					table.insert(list, oItem)
				end
			end
		end
		return list
	end
end

-- 返回指定sid的所有数量
function CItemCtrl.GetBagItemAmountBySid(self, sid, oLimitQuality)
	local itemList = self:GetBagItemListBySid(sid, oLimitQuality)
	if itemList then
		local amount = 0
		for _,v in ipairs(itemList) do
			amount = amount + v:GetSValueByKey("amount")
		end
		return amount
	end
	return 0
end

-- 返回道具组id为key的table(t = {gid={oItem1, oItem2, ...}, ...})
function CItemCtrl.GetBagItemTableByGroupidList(self, groupidList, oLimitQuality)
	if groupidList and #groupidList > 0 then
		if self.m_BagItems then
			local t = {}
			for _,oItem in pairs(self.m_BagItems) do
				for _,groupid in ipairs(groupidList) do
					local itemgroups = DataTools.GetItemGroup(groupid)
					local sid = oItem:GetSValueByKey("sid")
					--会屏蔽已经穿上的装备
					if table.index(itemgroups.itemgroup, sid) and not oItem:IsEquiped() and (not oLimitQuality or (oLimitQuality and oItem:GetQuality() <= oLimitQuality )) then
						if not t[sid] then
							t[sid] = {}
						end
						table.insert(t[sid], oItem)
					end
				end
			end
			return t
		end
	end
end

-- 返回指定grouid的所有数量
function CItemCtrl.GetBagItemAmountByGroupid(self, groupid, oLimitQuality)
	local itemList = self:GetBagItemListByGroupid(groupid, oLimitQuality)
	if itemList then
		local amount = 0
		for _,v in ipairs(itemList) do
			amount = amount + v:GetSValueByKey("amount")
		end
		return amount
	end
	return 0
end

-- 获取绑定/非绑定物品数量
function CItemCtrl.GetBagItemAmountByBindingState(self, sid, bBinding)
	if sid or sid > 0 then
		local amount = 0
		bBinding = bBinding and true or false
		for _,v in pairs(self.m_BagItems) do
			if sid == v:GetSValueByKey("sid") and v:IsBinding() == bBinding then
				amount = amount + v:GetSValueByKey("amount")
			end
		end
		return amount
	end
	return 0
end

function CItemCtrl.SetEquipedItem(self, iPos, oItem)
	self.m_EquipedItems[iPos] = oItem
	self:OnEvent(define.Item.Event.RefreshEquip)
end

-- 获取到装备列表（获取到哪个Key装备为止,默认到“Eight”）
function CItemCtrl.GetEquipedList(self, sKey)
	local list = {}

	if sKey and define.Equip.Pos[sKey] then
		sKey = sKey
	else
		sKey = "Eight"
	end
	
	for i = 1, define.Equip.Pos[sKey] do
		local item = self.m_EquipedItems[i]
		if item then
			table.insert(list, item)
		end
	end
	return list
end

-- 获取指定pos的装备
function CItemCtrl.GetEquipedByPos(self, iPos)
	return self.m_EquipedItems[iPos]
end

function CItemCtrl.GetAllItem(self)
	local t = {}
	for _, v in pairs(self.m_BagItems) do
		--暂时屏蔽神器链接
		if not (v.m_Type == CItem.TypeEnum[2] and v:GetSValueByKey("pos") == define.Equip.Pos.Eight) then
			table.insert(t, v)
		end
	end
	table.sort(t, function(a, b) return a:GetSValueByKey("pos") < b:GetSValueByKey("pos") end)
	return t
end


--获取身上及背包所有装备
--@param iSchool 帮派 -1 or nil 代表选择全部类型
--@param iSex 性别
--@param iLevel 最小装备等级
--@param iPos 装备位置
--@param iQuality 装备品质
--@param bIsForge 是否打造
function CItemCtrl.GetEquipList(self, iSchool, iSex, iLevel, iPos, iQuality, iRace, iRoletype, bIsForge)
	iSchool = iSchool or -1
	iSex = iSex or -1
	iLevel = iLevel or -1
	iPos = iPos or -1
	iQuality = iQuality or -1
	iRace = iRace or -1
	iRoletype = iRoletype or -1

	local list = {}
	for _,v in pairs(self.m_BagItems) do
		local dEquipData = v
		if v:IsEquip() then
			if iSex ~= -1 and v:GetCValueByKey("sex") ~= 0 and 
				v:GetCValueByKey("sex") ~= iSex then
				dEquipData = nil
			end 
			if iQuality ~= -1 and v:GetSValueByKey("itemlevel") < iQuality then
				dEquipData = nil
			end
			if iSchool ~= -1 and v:GetCValueByKey("school") ~= 0 and 
				v:GetCValueByKey("school") ~= iSchool then
				dEquipData = nil
			end
			if iRace ~= -1 and v:GetCValueByKey("race") ~= 0 and 
				v:GetCValueByKey("race") ~= iRace then
				dEquipData = nil
			end
			if iRoletype ~= -1 and v:GetCValueByKey("roletype") ~= 0 and 
				v:GetCValueByKey("roletype") ~= iRoletype then
				dEquipData = nil
			end
			if iPos ~= -1 and v:GetCValueByKey("equipPos") ~= iPos then
				dEquipData = nil
			end
			local equipLevel = tonumber(v:GetItemEquipLevel())
			if iLevel ~= -1 and equipLevel < iLevel then 
				dEquipData = nil
			end
			if bIsForge and v:GetSValueByKey("equip_info").is_make == 0 then
				dEquipData = nil
			end
			if dEquipData then
				table.insert(list, dEquipData)
			end
		end
	end
	local function sort(equip1, equip2)
		local iPos_1 = equip1:GetSValueByKey("pos") 
		local iPos_2 = equip2:GetSValueByKey("pos") 
		local iEquipLv_1 = equip1:GetItemEquipLevel()
		local iEquipLv_2 = equip2:GetItemEquipLevel()
		local iQuality_1 = equip1:GetSValueByKey("itemlevel") 
		local iQuality_2 = equip2:GetSValueByKey("itemlevel") 
		if iPos_1 <= define.Equip.Pos.Eight or iPos_2 <= define.Equip.Pos.Eight then
			return iPos_1 < iPos_2
		end
		if iEquipLv_1 ~= iEquipLv_2 then
			return iEquipLv_1 > iEquipLv_2
		end
		if iQuality_1 ~= iQuality_2 then
			return iQuality_1 > iQuality_2
		end
		return equip1.m_ID < equip2.m_ID
	end 
	table.sort(list, sort)
	return list
end

--添加打造所需物品信息
--@param iId 装备表格内的Id
--@param dInfo 物品信息列表[1打造符 2武器图纸 3货币]
function CItemCtrl.AddForgeItemIfno(self, iItemId, dInfo, iGoldcoin)
	dInfo.itemid = iItemId 
	self.m_ForgeItems[iItemId] = {baseItems = dInfo, quickCost = iGoldcoin}
	self:OnEvent(define.Item.Event.RefreshForgeInfo, {Info = dInfo, quickCost = iGoldcoin})
end

--返回打造所需物品
function CItemCtrl.GetForgeItemInfo(self, iItemId)
	if not self.m_ForgeItems[iItemId] then
		return
	end
	return self.m_ForgeItems[iItemId].baseItems, self.m_ForgeItems[iItemId].quickCost
end

--重置打造所需物品的刷新
function CItemCtrl.ResetForgeItemInfo(self)
	self.m_ForgeItems = {}
end

--设置装备洗炼的属性数据
--@param dCurInfo 当前装备的属性数据
--@param dNewInfo 洗炼后的属性数据
function CItemCtrl.SetWashEquipInfo(self, dCurInfo, dNewInfo)
	self.m_EquipWashInfo = { cur = dCurInfo, new = dNewInfo}
	self:OnEvent(define.Item.Event.RefreshWashInfo)
end

--返回装备洗炼属性
function CItemCtrl.GetWashEquipInfo(self)
	return self.m_EquipWashInfo
end

--返回装备预览数据
--@param citem 物品数据
function CItemCtrl.GetEquipPreview(self, citem)
	local result = {}
	local dAttrData = data.equipdata.EQUIP_ATTR[citem:GetCValueByKey("equipPos")]
	if not dAttrData then
		return
	end
	local tRange = DataTools.GetEquipAttrRange()
	for k,v in pairs(dAttrData.attr) do
		local tAttr = {}
		local tStrArr = string.split(v, "=")

		local sAttrName = data.attrnamedata.DATA[tStrArr[1]].name
		local formula = string.gsub(tStrArr[2],"ilv",citem:GetItemEquipLevel())
		local func = loadstring("return "..formula) 
		local iValue = func()
		tAttr.attr = tStrArr[1]
		tAttr.name = sAttrName
		tAttr.min = math.floor(iValue * tRange.min/100)
		tAttr.max = math.floor(iValue * tRange.max/100)
		table.insert(result, tAttr)
	end
	return result
end

--返回附魂的效果列表
--@param citem 物品数据
--@return result table{{name,value}}
function CItemCtrl.GetSoulEffectList(self, citem)
	local result = {}
	local dAttrData = data.equipdata.EQUIP_ATTR[citem:GetCValueByKey("pos")]
	if not dAttrData then
		return
	end
	-- table.print(dAttrData)
	for k,v in ipairs(citem:GetSValueByKey("apply_info")) do
		local tAttr = {}

		local sAttrName = data.attrnamedata.DATA[v.key].name
		local iValue = v.value
		tAttr.name = sAttrName
		tAttr.value = iValue
		-- result[v.key] = tAttr
		table.insert(result, tAttr)
	end
	return result
end

function CItemCtrl.SetStrengthInfo(self, pbdata)
	self.m_StrengthInfo = pbdata
	self:OnEvent(define.Item.Event.RefreshStrength)
end

function CItemCtrl.GetStrengthInfo(self)
	return self.m_StrengthInfo
end

function CItemCtrl.UpdateStrengthenInfo(self, strengthenInfo, master_score) 
	if not strengthenInfo then
	   strengthenInfo = {}
	end
	for k,info in pairs(strengthenInfo) do
		self.m_StrengthenInfo[info.pos] = info
	end
	self:OnEvent(define.Item.Event.RefreshStrengthLv)
end

function CItemCtrl.GetStrengthenLv(self, iPos)
	if self.m_StrengthenInfo[iPos] then
	   	return self.m_StrengthenInfo[iPos].level or 0
	else
		return 0
	end
end

function CItemCtrl.GetStrengthenScore(self, iPos)
	return self.m_StrengthenInfo[iPos].score or 0
end

function CItemCtrl.GetStrengthenBreakLv(self, iPos)
	if self.m_StrengthenInfo[iPos] then
	   	return self.m_StrengthenInfo[iPos].break_level or 0
	else
		return 0
	end
end

function CItemCtrl.GetStrengthenSuccessRatio(self, iPos)
	local dInfo = self.m_StrengthenInfo[iPos]
	if dInfo then
		return dInfo.success_ratio_base, dInfo.success_ratio_add
	else
		return 100, 0
	end
end

function CItemCtrl.IsBagFull(self)
	local list = self:GetBagItemListByType(self.m_BagTypeEnum.all)
	local iCount = #list
	return self.m_BagOpenCount == iCount
end

--返回可摆摊物品列表
--@return list
function CItemCtrl.GetCanStallItemList(self)
	local list = {}
	for _,oItem in pairs(self.m_BagItems) do
		if oItem:IsStallEnable() and not oItem:IsInlayGemStone() and oItem:IsBagItemPos() then
			table.insert(list, oItem)
		end
	end
	return list
end

--返回可拍卖物品列表
function CItemCtrl.GetCanAuctionItemList(self)
	local list = {}
	local iMinEquipLv = tonumber(DataTools.GetGlobalData(110).value)
	for _,oItem in pairs(self.m_BagItems) do
		local sid = oItem:GetSValueByKey("sid")
		local lv = oItem:GetItemEquipLevel()
		local pos = oItem:GetSValueByKey("pos")
		if pos > define.Equip.Pos.Eight and DataTools.GetAuctionItemData(sid) ~= nil then
			if (oItem:IsEquip() and lv >= iMinEquipLv) or not oItem:IsEquip() then
				table.insert(list, oItem)
			end 
		end
	end
	return list
end

--返回可出售商会物品列表
function CItemCtrl.GetCanGuildItemList(self)
	local list = {}
	for _,oItem in pairs(self.m_BagItems) do
		local sid =  oItem:GetSValueByKey("sid")
		local dItem = DataTools.GetEcononmyGuildItem(sid)
		local pos = oItem:GetSValueByKey("pos")
		if pos > define.Equip.Pos.Eight and dItem and dItem.can_sell == 1 and not oItem:IsBinding() and oItem:IsBagItemPos() then
			table.insert(list, oItem)
		end
	end
	return list
end

-- 获取战斗中可使用物品
function CItemCtrl.GetWarItemList(self)
	local list = {}
	for _,oItem in pairs(self.m_BagItems) do
		if oItem:IsUIWarItem() then
			table.insert(list, oItem)
		end
	end
	table.sort(list, function(a, b) return a:GetSValueByKey("pos") < b:GetSValueByKey("pos") end)
	return list
end

--快捷购买
function CItemCtrl.GS2CQuickBuyItem(self, sid, sugAmount, msg)
    local dKeyData = {
        amount = g_ItemCtrl:GetBagItemAmountBySid(sid),
        sid = sid,
        sugAmount = sugAmount,
        msg = msg,
    }
    CTradeVolumSubView:ShowView(function(oView)
        oView:SetTradeVolumSubView(dKeyData)
    end)
end

--开宝箱结果
function CItemCtrl.GS2COpenBoxUI(self, boxsid, rewarddata)
	self:OnEvent(define.Item.Event.OpenTreasureBox, {box_sid = boxsid, reward_item = rewarddata})
end

function CItemCtrl.GS2CQuickBuyItemSucc(self, sid)
	self:OnEvent(define.Item.Event.QuickBuyItem, sid)
end
--翻切按钮
function CItemCtrl.NextLastEquip(self, oItem, dir)
	local item = nil
	local itemList ={}
	local CurPos = nil
	local index = nil
	if oItem.m_Type == "Bag" then
		itemList = self:GetBagItemListByType("equip") 
		local noSumumList = {}
		for i,oItem in ipairs(itemList) do
			if not oItem:IsSummonEquip() then
				table.insert(noSumumList, oItem)
			end
		end
		itemList = noSumumList
	elseif oItem.m_Type == "Re" then
		itemList = g_RecoveryCtrl:GetEquipList()
	elseif oItem.m_Type == "Temp" then
		itemList = g_ItemTempBagCtrl:GetEquipList()
	end
	table.sort(itemList,function (v1,v2)
							if v1~=nil and v2~=nil then
							return v1.m_SData.pos < v2.m_SData.pos
							end
						end)

	CurPos = oItem.m_SData.pos
	for i,v in ipairs(itemList) do
		if  CurPos==v.m_SData.pos then
			index = i
		end
	end
	if dir then
		if index ==#itemList then
			item=itemList[1]
		else
			item= itemList[index+1]
		end
	else
		if index == 1 then
			item =itemList[#itemList]
		else
			item =itemList[index-1]
		end
	end
	if not item.m_SData then
		item = CItem:New(Item.m_SData.sid,Item.m_Type)
	end
	return item
end


function CItemCtrl.WareEquipInfo(self, oItem ,dir)
	local  CurrIdx = oItem:GetCValueByKey("equipPos")
	local item = nil
	if  dir  then
		for i = CurrIdx+1,CurrIdx+7 do
			local info = self:GetEquipedByPos(i%7)
			if info then
				item  = info
				break
			end
	 	end
	else
	 	for i = CurrIdx+6,CurrIdx,-1 do
			local info = self:GetEquipedByPos(i%7)
			if info then
				item = info
				break
			end
	 	end
	end
	return item
end

function CItemCtrl.SetSelectSpr(self, oItem)
 	-- body
	local view = nil
	local box = nil
	
	if oItem.m_Type == "Bag" then
		view = CItemMainView:GetView()
		if not view then
			return
		end
		if oItem.m_SData.pos < 7 then
			if oItem.m_SData.pos ==  4 then
				box = view.m_ItemModelPart.m_EquipmentGrid:GetChild(3)
			elseif oItem.m_SData.pos ==  3 then
				box = view.m_ItemModelPart.m_EquipmentGrid:GetChild(4)
			else
				box = view.m_ItemModelPart.m_EquipmentGrid:GetChild(oItem.m_SData.pos)
			end	
		else
			box = view.m_ItemBagBox.m_ItemCellGrid:GetChild(oItem.m_SData.pos-100)
		end

	elseif oItem.m_Type =="Temp" then
		view = CItemTempBagView:GetView()
		box = view.m_ItemGrid:GetChild(oItem.m_SData.pos)

	elseif oItem.m_Type =="Re"  then

		view = CRecoveryItemView:GetView()
		box = view.m_ItemGrid:GetChild(oItem.m_SData.pos)

	end
	box:ForceSelected(true)
end

function CItemCtrl.GetDeComposeItemList(self)
	local list = {}
	for _, oItem in pairs(self.m_BagItems) do
		if oItem:IsDeComposeEnable() then
			table.insert(list, oItem)
		end
	end
	local function sort(oItem_1, oItem_2)
		return oItem_1:GetSValueByKey("pos") < oItem_2:GetSValueByKey("pos")
	end
	table.sort(list, sort)
	return list
end

function CItemCtrl.SetEquipSoulPoint(self, iPoint)
	self.m_EquipSoulPoint = iPoint
	self:OnEvent(define.Item.Event.RefreshEquipSoulPoint)
end

function CItemCtrl.GetEquipSoulPoint(self)
	return self.m_EquipSoulPoint or 0
end

function CItemCtrl.SetAttachSoulInfo(self, iItemId, dInfo)
	dInfo.itemid = iItemId 
	self.m_AttachSoulItems[iItemId] = dInfo
	self:OnEvent(define.Item.Event.RefreshAttachSoulInfo, {Info = dInfo})
end

function CItemCtrl.GetAttachSoulInfo(self, iItemId)
	return self.m_AttachSoulItems[iItemId]
end

function CItemCtrl.ResetAttachSoulInfo(self)
	self.m_AttachSoulItems = {}
end

function CItemCtrl.GetStrengthMasterInfo(self)
	local iCurMasterLv = -1
	for pos=1, define.Equip.Pos.Shoes do
		if not self.m_StrengthenInfo[pos] or not self:GetEquipedByPos(pos) then
			iCurMasterLv = 0
			break
		end
		local iStrengthLv = self:GetStrengthenLv(pos)
		local iMasterLv = DataTools.GetEquipStrengthMasterLv(g_AttrCtrl.school, iStrengthLv)
		if iCurMasterLv == -1 then
			iCurMasterLv = iMasterLv
		else
			iCurMasterLv = math.min(iMasterLv, iCurMasterLv)
		end
	end
	local dData = DataTools.GetEquipStrengthMaster(g_AttrCtrl.school, iCurMasterLv)
	local dNextData = DataTools.GetEquipStrengthMaster(g_AttrCtrl.school, iCurMasterLv + 1)
	local iUpgradeNeed = 0
	if dNextData then
		for pos=1, define.Equip.Pos.Shoes do
			local iStrengthLv = self:GetStrengthenLv(pos)
			if iStrengthLv >= dNextData.all_strength_level and self:GetEquipedByPos(pos) then
				iUpgradeNeed = iUpgradeNeed + 1
			end
		end
	end
	return {lv = iCurMasterLv, upgradeneed = iUpgradeNeed, data = dData, nextdata = dNextData}
end

function CItemCtrl.C2GSItemUseOrTransfer(self, id)
	self.m_CurrUseItemID = id 
	self:OnEvent(define.Item.Event.ItemTransfer)
end

--穿戴区装备红点（戒指）
function CItemCtrl.IsEquipdRed(self, pos)
	if pos > define.Equip.Pos.Eight then
		printerror("物品未穿戴或不是可穿戴装备", pos)
		return false
	end
	local idx = table.index(self.m_ItemEquipRedList, pos) or 0
	return idx > 0
end

function CItemCtrl.ISoulEquip(self)

	local item = self.m_EquipedItems[define.Equip.Pos.Weapon]
	if item then
		return item:HasAttachSoul()
	end 

end
-- 是否是集字道具
function CItemCtrl.IsStaleDatedWordItem(self, iItemID)
	if iItemID >= 10186 and iItemID <= 10189 then
		-- local iStatus = g_WelfareCtrl:GetCollectGiftStatus()
		-- if not iStatus or iStatus == 0 then
			return true
		-- end
	end
	return false
end

function CItemCtrl.SelectItemList(self, floatitemlist)
	self.m_FloatItemList = floatitemlist
end

function CItemCtrl.CalculateStrengthItemCnt(self, iItemID)
	local iMinId = 11092
	local iMaxId = 11096
	local iCurId = iItemID - 1
	local iFloor = 1
	local iComposeCnt = 0
	local function calculateComposeCnt()
		while true do
			if iCurId < iMinId or iCurId >= iMaxId then
				iComposeCnt = math.floor(iComposeCnt)
				return 
			end
			iComposeCnt = self:GetBagItemAmountBySid(iCurId)/math.pow(4, iFloor) + iComposeCnt
			iFloor = iFloor + 1
			iCurId = iCurId - 1
		end
	end
	calculateComposeCnt()
	return iComposeCnt
end

function CItemCtrl.UpdateItemInfo(self, itemdata)
	local oItem = self.m_BagItems[itemdata.id]
	if oItem then
		oItem.m_SData = itemdata
	else
		oItem = CItem.New(itemdata, CItem.TypeEnum[2])
		self.m_BagItems[itemdata.id] = oItem
	end
	self:OnEvent(define.Item.Event.UpdateItemInfo, itemdata)
end

--------------------------炼化相关-----------------------------
function CItemCtrl.SetRefineInfoList(self, lDefine)
	self.m_RefineList = table.copy(lDefine)
	for i,v in ipairs(self.m_RefineList) do
		self:FixRefineInfo(v)
	end
	self:OnEvent(define.Item.Event.RefreshAllRefineInfo)
end

function CItemCtrl.GetRefineInfo(self, iType)
	return self.m_RefineList[iType]
end

function CItemCtrl.UpdateRefineInfo(self, iType, dInfo)
	self.m_RefineList[iType] = table.copy(dInfo)
	self:FixRefineInfo(self.m_RefineList[iType])
	self:OnEvent(define.Item.Event.RefreshRefineInfo, iType)
end

function CItemCtrl.UpdateRefineGrid(self, iType, iGrid)
	self.m_RefineList[iType].grid_size = iGrid
	self:FixRefineInfo(self.m_RefineList[iType])
	self:OnEvent(define.Item.Event.RefreshRefineInfo, iType)
end

function CItemCtrl.GetRefineItemList(self)
	local list = {}
	for _, oItem in pairs(self.m_BagItems) do
		if oItem:IsBagItemPos() then
			local iValue = oItem:GetRefineValue()
			if iValue and iValue > 0 then
				table.insert(list, oItem)
			end
		end
	end
	local function sort(oItem_1, oItem_2)
		return oItem_1:GetSValueByKey("pos") < oItem_2:GetSValueByKey("pos")
	end
	table.sort(list, sort)
	return list
end

function CItemCtrl.FixRefineInfo(self, dInfo)
	for i=1,4 do
		if not dInfo.grid_info then
			dInfo.grid_info = {}
		end
		if not dInfo.grid_info[i] then
			dInfo.grid_info[i] = {timeout = 0, value = 0}
		end
	end
end

function CItemCtrl.RefreshRefineRedPoint(self, bIsShow)
	self.m_ShowRefineRedPoint = bIsShow
	self:OnEvent(define.Item.Event.RefreshRefineRedPoint)
end

function CItemCtrl.UpdateRefineCheckBox(self, iType, bIsChangeAll)
	self.m_RefineList[iType].is_change_all = bIsChangeAll
	self:OnEvent(define.Item.Event.RefreshRefineInfo, iType)
end

function CItemCtrl.HasEmptyRefineBox(self)
	for i,dRefine in ipairs(self.m_RefineList) do
		local dRefineData = data.vigodata.DATA[i]
		if dRefineData.grade_limit <= g_AttrCtrl.grade and dRefine.is_change_all == 1 then
			for i=1,dRefine.grid_size do
				local dGridInfo = dRefine.grid_info[i]
				if dGridInfo.timeout == 0 then
					return true
				end
			end
		end
	end
	return false
end

--获取魂石列表
--@param iColor 魂石颜色
--@param bFiliate 是否包含全部单色混色
--@param iGrade 魂石等级
--@param sAttr 魂石增益属性
--@param bSortGradeUp 是否按宝石等级从大到小排序
--@param bSortColorFirst 优先排颜色再排宝石等级
function CItemCtrl.GetGemStoneList(self, iColor, bFiliate, iMinGrade, iMaxGrade, sAttr1, sAttr2, bSortGradeUp, bSortColorFirst)
	local list = {}
	iColor = iColor or -1
	iMinGrade = iMinGrade or 1
	iMaxGrade = iMaxGrade or 1
	-- printerror(iColor, bFiliate, iMinGrade, iMaxGrade)
	local dFiliateColor = {[iColor] = true}
	if bFiliate then
		local lColor = DataTools.GetRelateGemStoneList(iColor)
		for i,color in ipairs(lColor) do
			dFiliateColor[color] = true
		end
	end

	for _,oItem in pairs(self.m_BagItems) do
		if oItem:IsGemStone() then
			local dGemStone = oItem
			local iItemGrade = oItem:GetSValueByKey("hunshi_info").grade
			local iItemColor = data.hunshidata.ITEM2COLOR[oItem.m_SID]

			--TODO:需要关联的父子颜色比较
			if iColor ~= -1 and ((not bFiliate and iItemColor ~= iColor) or 
				(bFiliate and not dFiliateColor[iItemColor])) then
				dGemStone = nil
			end

			if iItemGrade < iMinGrade or iItemGrade > iMaxGrade then
				dGemStone = nil
			end

			if sAttr1 ~= nil and not data.hunshidata.COLOR2ATTR[iItemColor][sAttr1] then
				dGemStone = nil
			end

			if sAttr2 ~= nil and not data.hunshidata.COLOR2ATTR[iItemColor][sAttr2] then
				dGemStone = nil
			end
			if dGemStone then
				table.insert(list, dGemStone)
			end
		end
	end

	local function sort(d1, d2)
		local iGrade_1 = d1:GetSValueByKey("hunshi_info").grade
		local iColor_1 = data.hunshidata.ITEM2COLOR[d1.m_SID]
		local iGrade_2 = d2:GetSValueByKey("hunshi_info").grade
		local iColor_2 = data.hunshidata.ITEM2COLOR[d2.m_SID]
		if bSortColorFirst then
			if iColor_1 ~= iColor_2 then
				return iColor_1 > iColor_2
			elseif iGrade_1 ~= iGrade_2 then
				if bSortGradeUp then
					return iGrade_1 > iGrade_2
				else
					return iGrade_1 < iGrade_2
				end
			end
		else
			if iGrade_1 ~= iGrade_2 then
				if bSortGradeUp then
					return iGrade_1 > iGrade_2
				else
					return iGrade_1 < iGrade_2
				end
			elseif iColor_1 ~= iColor_2 then
				return iColor_1 < iColor_2
			end
		end
		return d1.m_ID < d2.m_ID
	end 
	table.sort(list, sort)
	return list
end

function CItemCtrl.GetGemStoneAmount(self, iItemSid, iGrade, lAttr)
	local itemList = self:GetBagItemListBySid(iItemSid)
	if itemList then
		local amount = 0
		for _,v in ipairs(itemList) do
			local dInfo = v:GetGemStoneInfo()
			if dInfo.grade == iGrade and table.equal(dInfo.addattr, lAttr) then
				amount = amount + v:GetSValueByKey("amount")
			end
		end
		return amount
	end
	return 0
end

function CItemCtrl.GetGemStoneItemId(self, iItemSid, iGrade, lAttr)
	local itemList = self:GetBagItemListBySid(iItemSid)
	if itemList then
		for _,v in ipairs(itemList) do
			local dInfo = v:GetGemStoneInfo()
			if dInfo.grade == iGrade and table.equal(dInfo.addattr, lAttr) then
				return v.m_ID
			end
		end
	end
	return 0
end

--获取道具quality
function CItemCtrl.GetQualityVal(self, oItemSid, oItemQualityConfig)
	return DataTools.GetItemQuality(oItemSid) or oItemQualityConfig
end

-- 宝图兑换
function CItemCtrl.TreasureMapCompound(self)
	local dCompoundList = DataTools.GetItemComposeCompound(11077)
	local isLack = false
	local itemlist = {}
	local cost = 0
	table.print(dCompoundList)
	for i,v in pairs(dCompoundList) do
		if self:GetBagItemAmountBySid(v.sid) < v.amount then
			isLack = true
			local dItem = DataTools.GetItemData(v.sid)
			cost = cost + dItem.buyPrice
			table.insert(itemlist, {sid = v.sid , count = self:GetBagItemAmountBySid(v.sid) , amount = v.amount} )
			table.print(itemlist)
		end
	end
	if isLack then
		local cb = function()
			netitem.C2GSCompoundItem(11077, 2, 3)
		end
		local needChangeCb = function ()
			g_ItemCtrl:TreasureMapCompound()
		end
		local showCb = function ()
			local oOptionView = CDialogueOptionView:GetView()
			if oOptionView then oOptionView:SetActive(false) end
		end
		local hideCb = function ()
			local oOptionView = CDialogueOptionView:GetView()
			if oOptionView then oOptionView:SetActive(true) end
		end
		showCb()
		g_QuickGetCtrl:CurrLackItemInfo(itemlist,{}, cost, cb, nil, hideCb, needChangeCb)
	else
		netitem.C2GSCompoundItem(11077, 1)
	end
end

function CItemCtrl.CheckUpgardePackConfig(self, oIndex)
	if not self.m_UpgardePackConfigList[oIndex] then
		if g_AttrCtrl.pid == 0 then
			return
		end
		if oIndex == 10 then
			self.m_UpgardePackConfigList[oIndex] = DataTools.GetItemGiftList(g_GuideHelpCtrl:GetItem10SelectItemSid(), g_AttrCtrl.roletype, g_AttrCtrl.sex)
		elseif oIndex == 20 then
			self.m_UpgardePackConfigList[oIndex] = DataTools.GetItemGiftList(g_GuideHelpCtrl:GetItem20SelectItemSid(), g_AttrCtrl.roletype, g_AttrCtrl.sex)
		elseif oIndex == 30 then
			self.m_UpgardePackConfigList[oIndex] = DataTools.GetItemGiftList(g_GuideHelpCtrl:GetItem30SelectItemSid(), g_AttrCtrl.roletype, g_AttrCtrl.sex)
		elseif oIndex == 40 then
			self.m_UpgardePackConfigList[oIndex] = DataTools.GetItemGiftList(g_GuideHelpCtrl:GetItem40SelectItemSid(), g_AttrCtrl.roletype, g_AttrCtrl.sex)
		end
	end
end

function CItemCtrl.SetUpgardePackConfigByGuideType(self, oType)
	if oType == "UpgradePack_1" then
		self:CheckUpgardePackConfig(10)
	elseif oType == "UpgradePack20_1" then
		self:CheckUpgardePackConfig(20)
	elseif oType == "UpgradePack30_1" then
		self:CheckUpgardePackConfig(30)
	elseif oType == "UpgradePack40_1" then
		self:CheckUpgardePackConfig(40)
	end
end

function CItemCtrl.SetUpgradsPackConfigByGrade(self)
	if g_AttrCtrl.grade >= 10 and g_OpenSysCtrl:GetOpenSysState(define.System.UpgradePack) and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(10) then
		self:CheckUpgardePackConfig(10)
	end
	if g_AttrCtrl.grade >= 20 and g_OpenSysCtrl:GetOpenSysState(define.System.UpgradePack) and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(20) then
		self:CheckUpgardePackConfig(20)
	end
	if g_AttrCtrl.grade >= 30 and g_OpenSysCtrl:GetOpenSysState(define.System.UpgradePack) and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(30) then
		self:CheckUpgardePackConfig(30)
	end
	if g_AttrCtrl.grade >= 40 and g_OpenSysCtrl:GetOpenSysState(define.System.UpgradePack) and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(40) then
		self:CheckUpgardePackConfig(40)
	end
end

--检查积分列表的配置
function CItemCtrl.CheckJifenConfig(self)
	self.m_JifenList = {}
	for k,v in pairs(data.itemvirtualdata.VIRTUAL) do
		if tonumber(v.isShowInBag) == 1 then
			table.insert(self.m_JifenList, v)
		end
	end
	table.sort(self.m_JifenList, function (a, b)
		return a.id < b.id
	end)
end

-- 废弃!!! -- 获取物品元宝信息(一般是商会)
function CItemCtrl.GetItemGoingoinPrice(self, sid)
	local iPrice = self.m_ItemPriceDict[sid]
	if not iPrice then
		netitem.C2GSItemGoldCoinPrice(sid)
		return nil
	else
		return iPrice
	end
end

-- 请求兑换道具
function CItemCtrl.RequestExcItem(self, sid)
	-- 暂只考虑一种兑换方案
	local dExch = DataTools.GetItemExchData(sid).exchangelist[1]
	if not dExch then
		return
	end
	local iCnt = 1
	local dCost = DataTools.GetItemExchCostData(dExch.exchangeid).cost_item_list
	for _, v in ipairs(dCost) do
		if v.sid == sid then
			iCnt = v.amount
			break
		end
	end
	local iOwn = g_ItemCtrl:GetBagItemAmountBySid(sid)
	if iOwn >= iCnt then
		local dItem = DataTools.GetItemData(sid)
		local dExchItem = DataTools.GetItemData(dExch.sid)
		local sMsg = string.format("[63432cff]是否消耗#G%d#n个#G%s#n兑换#G1#n个#G%s#n[-]", iCnt, dItem.name, dExchItem.name)
        local windowConfirmInfo = {
            msg = sMsg,
            title = "提示",
            color = Color.white,
            okCallback = function()
            	netitem.C2GSItemsExchangeItem(dExch.exchangeid, 1)
            end,
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		g_NotifyCtrl:FloatMsg("道具不足")
	end
end

function CItemCtrl.RequestComposeItem(self, oItem, callback)
	if oItem:IsGemStone() then
		--满级材料不能合成，但可以混合
		if not oItem:IsComposeEnable() and oItem:IsMixEnable() then
			CItemComposeView:ShowView(function(oView)
				oView:JumpToGemStoneMix(oItem)
			end)
			if callback then callback() end
			return
		end
		CItemComposeView:ShowView(function(oView)
			oView:JumpToGemStoneCompose(oItem)
		end)
		if callback then
			callback()
		end
		return
	end

	if oItem:IsComposWenShi() then 
		g_WenShiCtrl:C2GSWenShiMake(oItem.m_ID)
		if callback then
			callback()
		end
		return
	end 

	local iComposeId = data.itemcomposedata.ITEM2COMPOSE[oItem.m_SID][1]
	if data.itemcomposedata.ITEM2CAT[iComposeId] then
		CItemComposeView:ShowView(function(oView)
			oView:JumpToCompose(iComposeId)
		end)
	else
		local dComposeInfo = data.itemcomposedata.ITEMCOMPOUND[iComposeId]
		local iComposeAmount = dComposeInfo.sid_item_list[1].amount
		if g_ItemCtrl:GetBagItemAmountBySid(oItem.m_SID) >= iComposeAmount then
			netitem.C2GSComposeItem(oItem.m_ID, 1, iComposeId)
		else
			g_NotifyCtrl:FloatMsg("合成材料不足")
		end
	end

	if callback then
		callback()
	end
end

------------------快捷使用相关----------------------

function CItemCtrl.CheckQuickUseContent(self)
	if not g_ItemCtrl.m_ItemQuickUseWaitList or not next(g_ItemCtrl.m_ItemQuickUseWaitList) then
		local oView = CItemQuickUseView:GetView()
		if oView then
			oView:OnClose()
		end
	else
		local oConfig = g_ItemCtrl.m_ItemQuickUseWaitList[1]
		if oConfig.isLingxi then
			CItemQuickUseView:ShowView(function(oView)
				oView:SetDataQuickUse(oConfig.item, oConfig.upgradepackitemid, oConfig.isTreasure, oConfig.isLingxi)
				g_GuideCtrl:OnTriggerAll()
			end)
		elseif oConfig.upgradepackitemid then
			CItemQuickUseView:ShowView(function(oView)
				oView:SetDataQuickUse(oConfig.item, oConfig.upgradepackitemid, oConfig.isTreasure, oConfig.isLingxi)
				g_GuideCtrl:OnTriggerAll()
			end)
		elseif oConfig.isTreasure then
			CItemQuickUseView:ShowView(function(oView)
				oView:SetDataQuickUse(oConfig.item, oConfig.upgradepackitemid, oConfig.isTreasure, oConfig.isLingxi)
				g_GuideCtrl:OnTriggerAll()
			end)
		else
			local oAmount = g_ItemCtrl:GetBagItemAmountBySid(oConfig.item:GetCValueByKey("id")) or 0
			-- printc("111111111111", oConfig.item:GetCValueByKey("id"), oAmount)
			if oAmount <= 0 then
				table.remove(g_ItemCtrl.m_ItemQuickUseWaitList, 1)
				self:CheckQuickUseContent()
			else
				CItemQuickUseView:ShowView(function(oView)
					oView:SetDataQuickUse(oConfig.item, oConfig.upgradepackitemid, oConfig.isTreasure, oConfig.isLingxi)
					g_GuideCtrl:OnTriggerAll()
				end)
			end
		end
	end
end

--type 1普通道具 , 2 upgradepackitemid, 3 isTreasure, 4 isLingxi
function CItemCtrl.AddQuickUseData(self, oItem, upgradepackitemid, isTreasure, isLingxi)
	local dItemCfg = {
		item = oItem,
		upgradepackitemid = upgradepackitemid,
		isTreasure = isTreasure,
		isLingxi = isLingxi,
	}
	-- table.insert(self.m_QuickUseList, dItemCfg)

	if isLingxi then
		table.insert(g_ItemCtrl.m_ItemQuickUseWaitList, 1, {item = oItem, isLingxi = isLingxi, type = 4})
	elseif upgradepackitemid then
		table.insert(g_ItemCtrl.m_ItemQuickUseWaitList, 1, {item = oItem, upgradepackitemid = upgradepackitemid, type = 2})
	elseif isTreasure then
		table.insert(g_ItemCtrl.m_ItemQuickUseWaitList, 1, {item = oItem, isTreasure = isTreasure, type = 3})
	else
		local oSid = oItem:GetSValueByKey("sid")
		g_ItemCtrl:DelAllQuickUseDataBySid(oSid)
		local oBagItemList = g_ItemCtrl:GetBagItemListBySid(oSid)
		if oBagItemList and next(oBagItemList) then
			for k,v in pairs(oBagItemList) do
				-- printc("CItemCtrl.AddQuickUseData", v:GetSValueByKey("sid"), v:GetSValueByKey("name"), v:GetSValueByKey("id"))
				table.insert(g_ItemCtrl.m_ItemQuickUseWaitList, 1, {item = v, type = 1})
			end
		end		
	end
	g_ItemCtrl:CheckQuickUseContent()
end

function CItemCtrl.DelAllQuickUseDataBySid(self, oSid)
	local oIndexList = {}
	for k,v in pairs(g_ItemCtrl.m_ItemQuickUseWaitList) do
		if v.type == 1 and v.item:GetCValueByKey("id") == oSid then
			table.insert(oIndexList, k)
		end
	end
	if next(oIndexList) then
		for k,v in pairs(oIndexList) do
			table.remove(g_ItemCtrl.m_ItemQuickUseWaitList, v)
		end			
	end
end

function CItemCtrl.DelAllQuickUseDataById(self, oId)
	local oIndex
	for k,v in pairs(g_ItemCtrl.m_ItemQuickUseWaitList) do
		if v.type == 1 and v.item:GetSValueByKey("id") == oId then
			oIndex = k
			break
		end
	end
	if oIndex then
		table.remove(g_ItemCtrl.m_ItemQuickUseWaitList, oIndex)		
	end
end

function CItemCtrl.DelAllQuickUseDataByType(self, oType)
	local oIndexList = {}
	for k,v in pairs(g_ItemCtrl.m_ItemQuickUseWaitList) do
		if v.type == oType then
			table.insert(oIndexList, k)
		end
	end
	if next(oIndexList) then
		for k,v in pairs(oIndexList) do
			table.remove(g_ItemCtrl.m_ItemQuickUseWaitList, v)
		end			
	end
end

function CItemCtrl.GetQuickUseItemID(self, itemlist)
	-- body
    local oQuickData = nil
    for i,v in ipairs(itemlist) do
    	if tonumber(v.id) then
	        local oItemData = DataTools.GetItemData(v.id)
	        if oItemData.quickable and oItemData.quickable == 1 then
	            oQuickData = oItemData
	            break
	        end
	    end
    end
    local oQuickID = nil

    if oQuickData then
        for _,v in pairs(self.m_BagItems) do
            if oQuickData.id ==  v.m_SID  then
                oQuickID = v.m_ID
                break
            end
        end
    end
    return oQuickID
end

function CItemCtrl.GetQuickUseItemIDList(self, itemlist)

    local quickList = {}
    local quickIdList = {}
    for i,v in ipairs(itemlist) do
    	if tonumber(v.id) then
	        local oItemData = DataTools.GetItemData(v.id)
	        if oItemData.quickable and oItemData.quickable == 1 then
	            table.insert(quickList, oItemData)
	        end
	    end
    end

    for k, v in ipairs(quickList) do 
    	for _, item in pairs(self.m_BagItems) do
    	    if v.id ==  item.m_SID  then
    	        table.insert(quickIdList, item.m_ID)
    	    end
    	end
    end 
   
    return quickIdList
end

function CItemCtrl.GetPartnerItemAmountBySid(self, iItemSid)
	local iAmount = self:GetBagItemAmountBySid(iItemSid)
	local list = DataTools.GetItemComposeCompound(iItemSid)
	if list and #list == 1 then
		local dItem = list[1]
		local iSubAmount = self:GetBagItemAmountBySid(dItem.sid)
		iAmount = math.floor(iSubAmount/dItem.amount) + iAmount
	end
	return iAmount
end

--获取物品描述
function CItemCtrl.GetItemDesc(self, iItemSid, oItem)
	local dItemData = DataTools.GetItemData(iItemSid)
	local sFormula = dItemData.item_formula
	local sDesc = dItemData.description
	if not sFormula or sFormula == "" or not string.findstr(sDesc, "#formula") then
		return sDesc
	end
	local iValue = self:ExcuteItemFormula(sFormula, oItem)

	sDesc = string.gsub(sDesc, "#formula", iValue)
	return sDesc
end

function CItemCtrl.ExcuteItemFormula(self, sFormula, oItem)
	local lReplaceArg = {
		[1] = {key = "SLV", value = g_AttrCtrl.server_grade},
		[2] = {key = "LV", value = g_AttrCtrl.grade},
		[3] = {key = "grade", value = g_AttrCtrl.grade},
		[4] = {key = "quality", value = oItem and oItem:GetSValueByKey("itemlevel") or 0},
	}
	for _,v in ipairs(lReplaceArg) do
		sFormula = string.gsub(sFormula, v.key, v.value)
	end
	local func = loadstring("return "..sFormula)
	return func()
end

function CItemCtrl.IsContainFormationItem(self)
	for _,v in pairs(self.m_BagItems) do
		if v:IsFormationItem() then
			return true, v
		end
	end
	return false
end
return CItemCtrl
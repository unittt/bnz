local CItem = class("CItem")

-- 道具枚举类型               背包 仓库 回收 临时背包
CItem.TypeEnum = {"Nothing", "Bag", "Wh","Re","Temp"}

function CItem.ctor(self, dItem, type)
	self.m_ID = dItem.id
	self.m_SID = dItem.sid
	self.m_SData = dItem
	self.m_Type = type or CItem.TypeEnum[1]
	local itemID = dItem.sid
	self.m_CItemInfoGetter = function() return DataTools.GetItemData(itemID) end
	-- self.m_CData = DataTools.GetItemData(dItem.sid)
end

function CItem.CreateDefault(itemId, dGemStoneInfo)
	local CData = DataTools.GetItemData(itemId)
	local SData = {
		amount = 0,
		desc = "",
		id = itemId,
		itemlevel = DataTools.GetItemQuality(itemId) or CData.quality,
		name = "",
		pos = -1,
		sid = itemId,
	}
	if dGemStoneInfo then
		SData.hunshi_info = dGemStoneInfo
	end
	return CItem.New(SData)
end

function CItem.GetSValueByKey(self, k)
	return self.m_SData[k]
end

function CItem.GetCValueByKey(self, k)
	if k == "description" then
		return g_ItemCtrl:GetItemDesc(self.m_SID, self)
	else
		return self.m_CItemInfoGetter()[k]
	end
end

-------------------通用属性获取 start----------------------------------------
function CItem.GetQuality(self)
	--Note:装备品质会改变，使用服务器的itemlevel，其他不使用。特别烹饪药品的itemlevel是物品的等级非品质
	return self:IsEquip() and self:GetSValueByKey("itemlevel") or g_ItemCtrl:GetQualityVal( self:GetSValueByKey("sid"), self:GetCValueByKey("quality") or 0 )
end

--获取物品炼化值
function CItem.GetRefineValue(self)
	local formula = self:GetCValueByKey("changeToVigorValue")
	if not formula then
		return 0
	end
	local bindNum = 1
	if self:IsBinding() then
		bindNum = data.vigodata.OTHER[1].bind_item
	end
	if tonumber(formula) then
		return math.ceil(tonumber(formula) * bindNum)
	end
	formula = string.gsub(formula, "quality", self:GetSValueByKey("itemlevel"))
	local func = loadstring("return " .. formula)
	local iValue = func()
	if iValue then
		return math.ceil(iValue * bindNum)
	end 
end

function CItem.GetItemName(self)
	local sLocalName = self:GetCValueByKey("name")
	local sServerName = self:GetSValueByKey("name")
	if self:IsGemStone() then
		return self:GetSValueByKey("hunshi_info").grade.."级"..sLocalName
	end
	if self:GetCValueByKey("id") == define.Item.HunChangeItem then
		return self:GetSValueByKey("itemlevel").."级"..sLocalName
	end
	if self:IsEquip() and sServerName ~= "" then --附魂装备会改名
		return sServerName 
	end
	return sLocalName
end
-------------------通用属性获取 end----------------------------------------

-------------------物品类型判断 start------------------------------
-- CItem.m_RingIDlist = {22901, 22902, 22903}
CItem.m_RingGiftList = {12929, 12930, 12931}

-- function CItem.IsEngageRing(self)
-- 	local sid = self.m_SID
-- 	for i, v in ipairs(self.m_RingIDlist) do
-- 		if sid == v then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

function CItem.IsEngageRingGift(self)
	local sid = self.m_SID
	if table.index(CItem.m_RingGiftList, sid) then
		return true
	end
	return false
end

function CItem.GetEquipInfo(self)
	local info = self.m_SData.equip_info
	if info then
		return info
	end
end

function CItem.IsWenShi(self)
	
	local sid = self:GetCValueByKey("id")
	local wenshiConfig = data.itemwenshidata.WENSHI
	local wenshi = wenshiConfig[sid]
	if wenshi then 
		return true
	end 
	return false

end

function CItem.IsWenShiJingHua(self)

	return self.m_SID == 10161 or self.m_SID == 10166 or self.m_SID == 10162

end

function CItem.IsEquip(self)
	-- local itemtype = g_ItemCtrl.m_ItemBoxTypeEnum.equip
	-- return self:IsSpecificItemType(itemtype)
	local sid = self:GetCValueByKey("id")
	local tItemData = DataTools.GetItemData(sid, "EQUIP")
	return tItemData ~= nil
end

function CItem.IsTimeEquip(self)
	return self:IsEquip() and self:GetTimeEquipLevel()
end

function CItem.IsSummonEquip(self)
	local sid = self:GetCValueByKey("id")
	local tItemData = DataTools.GetItemData(sid, "SUMMONEQUIP")
	return tItemData ~= nil
end

function CItem.IsUIEquip(self)
	local itemtype = g_ItemCtrl.m_ItemBoxTypeEnum.equip
	return self:IsSpecificItemType(itemtype)
end

function CItem.IsUIConsume(self)
	local itemtype = g_ItemCtrl.m_ItemBoxTypeEnum.consume
	return self:IsSpecificItemType(itemtype)
end

function CItem.IsUIWarItem(self)
	-- 10039 特殊道具伏魔袋暂时不需要显示到战斗物品
	if self.m_SID == 10039 then
		return false
	end
	local itemtype = g_ItemCtrl.m_ItemBoxTypeEnum.war
	return self:IsSpecificItemType(itemtype)
end

function CItem.IsSpecificItemType(self, itemtype)
	local itemTypeTable = self:GetCValueByKey("itemType")
	if itemTypeTable and #itemTypeTable then
		if itemtype and #itemtype > 0 then
			for _,k in ipairs(itemtype) do
				for _,v in ipairs(itemTypeTable) do
					if v == k then
						return true
					end
				end
			end
		end
	end
end

function CItem.IsBagItemPos(self)
	if self.m_SData then
		return self.m_SData.pos > define.Item.Constant.BagItemHand
	end
end

function CItem.IsEquiped(self)
	if self.m_Type == CItem.TypeEnum[2] then
		return self.m_SData.pos ~= 0 and self.m_SData.pos <= define.Equip.Pos.Eight
	end
	return false
end

function CItem.IsEquipSoul(self)
	--shenhun表掺杂了青龙石，只能做id段区分
	local sid = self:GetCValueByKey("id")
	local tItemData = DataTools.GetItemData(sid, "EQUIPSOUL")
	return tItemData ~= nil and sid >= 12100 and sid <= 12106 
end

function CItem.IsForgeMaterial(self)
	local sid = self:GetCValueByKey("id")
	local sid = sid or 0
	return sid >= 12000 and sid <= 12068
end

function CItem.IsGiftItem(self)
	local sid = self:GetCValueByKey("id")
	local tItemData = DataTools.GetItemData(sid, "GIFTPACK")
	return tItemData ~= nil
end

function CItem.IsFoodItem(self)
	return self.m_SID >= 10046 and self.m_SID <= 10050
end

function CItem.IsMedicineItem(self)
	return self.m_SID >= 10051 and self.m_SID <= 10064
end

function CItem.IsBinding(self)
	if not self.m_SData.key then
		return false
	end
	return MathBit.andOp(self.m_SData.key, 1) ~= 0
end

function CItem.IsGainByStall(self)
	return self:GetSValueByKey("stall_buy_price") and self:GetSValueByKey("stall_buy_price") > 0
end

function CItem.IsFuZhuanItem(self)
	local iLv = self:GetFuZhuanLevel()
	return iLv ~= nil
end

function CItem.GetFuZhuanLevel(self)
	local oExtInfo = self:GetSValueByKey("apply_info")
	if not oExtInfo then
		return
	end
	for k,v in pairs(oExtInfo) do
		if v.key == "skill_level" then
			return v.value
		end
	end
end

--珍稀物品判断
function CItem.IsTreasureItem(self)
	if self:GetQuality() >= define.Item.Quality.Purple or 
		data.treasureitemdata.TREASUREITEM[self.m_SID] ~= nil then
		return true
	end
end

function CItem.IsFormationItem(self)
	return self.m_SID >= 11082 and self.m_SID <= 11089
end

-------------------物品类型判断 end------------------------------

------------------------魂石相关--------------------------------------
function CItem.IsGemStone(self)
	local sid = self:GetCValueByKey("id")
	return sid >= 11169 and sid <= 11174
end

function CItem.IsMixGemStone(self)
	local sid = self:GetCValueByKey("id")
	local dColor = data.hunshidata.ITEM2COLOR[sid]
	return dColor.level == 2
end

function CItem.GetGemStoneInfo(self)
	return self:GetSValueByKey("hunshi_info") 
end

function CItem.InitGemStoneAttr(self)
	local dInfo = self:GetSValueByKey("hunshi_info")
	local lAttr = dInfo.addattr
	local iGrade = dInfo.grade	
	self.m_GemStoneAttrList = {}
	for i,sAttrKey in ipairs(lAttr) do
		local sAttrName = data.attrnamedata.DATA[sAttrKey].name
		local dAttrData = DataTools.GetGemStoneAttrData(self:GetCValueByKey("id"), iGrade, sAttrKey)
		dAttrData.attrname = sAttrName
		table.insert(self.m_GemStoneAttrList, dAttrData)
	end
end

--获取宝石属性{[1] = {attrname = "攻击“, value = 10, key = ”attack“}}
function CItem.GetGemStoneAttr(self)
	if not self:IsGemStone() then
		return
	end
	if not self.m_GemStoneAttrList then
		self:InitGemStoneAttr()
	end
	return self.m_GemStoneAttrList
end

--获取装备镶嵌位置的宝石
function CItem.GetInlayItemByPos(self, iPos)
	local lInlayInfo = self:GetSValueByKey("equip_info").hunshi
	for i,v in ipairs(lInlayInfo) do
		if v.pos == iPos then
			return v
		end
	end
end

--判断装备是否镶嵌宝石
function CItem.IsInlayGemStone(self)
	if not self:IsEquip() then
		return false
	end
	local lInlayInfo = self:GetSValueByKey("equip_info").hunshi
	return lInlayInfo ~= nil and table.count(lInlayInfo) > 0
end

----------------------Tips Button的相关状态判断 start--------------------------------------
function CItem.IsComposeEnable(self)
	if data.itemcomposedata.ITEM2COMPOSE[self.m_SID] then
		return true
	end
	if self:IsGemStone() then
		local dInfo = self:GetSValueByKey("hunshi_info")
		return dInfo.grade < DataTools.GetGemStoneMaxComposeLv()
	end
end

function CItem.IsDeComposeEnable(self)
	if self:IsBagItemPos() then
		local lDecompose = self:GetCValueByKey("deCompose")
		local bDeCompose = false
		if self:IsGemStone() then
			local dColor = data.hunshidata.COLOR[data.hunshidata.ITEM2COLOR[self.m_SID]]
			bDeCompose = not (self:GetGemStoneInfo().grade == 1 and dColor.level == 1)
		end
		if (lDecompose ~= nil and #lDecompose > 0) or 
			(self:IsEquip() and not self:IsTimeEquip() and self:GetCValueByKey("equipLevel") >= data.equipdecomposedata.CONFIG.minlv) or 
			bDeCompose then
			return true
		end
	end
end

function CItem.IsMixEnable(self)
	if self:IsGemStone() then
		local dColor = data.hunshidata.COLOR[data.hunshidata.ITEM2COLOR[self.m_SID]]
		return dColor.level == 1
	end
end

function CItem.IsComposWenShi(self)
	
	local sid = self.m_SID
	return DataTools.IsWenShiComposeMat(sid)

end

function CItem.IsSellEnable(self)
	if self:GetCValueByKey("salePrice") ~= nil and self:GetCValueByKey("salePrice") ~= 0 then
		return true
	end
	local dGuildItem = DataTools.GetEcononmyGuildItem(self.m_SID)
	if dGuildItem and dGuildItem.can_sell == 1 and self:GetSValueByKey("key") ~= 1 then
		return true
	end
	return false
end

function CItem.IsStallEnable(self)
	local iQuality = self:GetQuality()
	local iStallId = DataTools.ConvertItemIdToStallId(self.m_SID, iQuality)
	local iBuyPrice = self:GetSValueByKey("stall_buy_price")
	local dStallData = data.stalldata.ITEMINFO[iStallId]
	if self:IsEquip() and (self:IsEquiped() or iQuality >= define.Item.Quality.Purple or self:HasEquipEffect()) then
		return false
	end
	return (dStallData and dStallData.stallable == 1) and not self:IsBinding() and iBuyPrice == 0
end

function CItem.IsGemStoneChangeEnable(self)
	if not self:IsGemStone() then
		return false
	end
	local dColor = DataTools.GetGemStoneColorData(self.m_SID)
	return dColor.level == 1 and dColor.can_change_color == 1
end

function CItem.IsExchangeEnable(self)
	if DataTools.GetItemExchData(self.m_SID) then
		return true
	end
	return false
end
----------------------Button的相关状态判断 end--------------------------------------

----------------------装备的相关状态判断 start------------------------------------
function CItem.IsForge(self)
	return self:IsEquip() and self.m_SData.equip_info.is_make == 1
end

function CItem.HasAttachSoul(self)
	return self.m_SData.equip_info.fuhun_attr and #self.m_SData.equip_info.fuhun_attr > 0
end

function CItem.HasAttachAttr(self)
	return self.m_SData.equip_info.attach_attr and #self.m_SData.equip_info.attach_attr > 0
end

function CItem.HasEquipEffect(self)
	local dEquipInfo = self.m_SData.equip_info
	return (dEquipInfo and dEquipInfo.se ~= nil and table.count(dEquipInfo.se) > 0) or (dEquipInfo and dEquipInfo.sk ~= nil and table.count(dEquipInfo.sk) > 0)
end

function CItem.GetEquipLast(self)
	if not self:IsEquip() or not self.m_SData.equip_info then
		return 0
	end
	return self.m_SData.equip_info.last
end

function CItem.GetTimeEquipLevel(self)
	local dEquipInfo = self.m_SData.equip_info
	local iGrowLevel = dEquipInfo and dEquipInfo.grow_level or 0
	return iGrowLevel > 0 and iGrowLevel 
end

function CItem.GetItemEquipLevel(self)
	return self:GetTimeEquipLevel() or self:GetCValueByKey("equipLevel")
end

function CItem.GetItemWenShiLevel(self)
	return self:GetTimeEquipLevel() 
end
----------------------装备的相关状态判断 end--------------------------------------

return CItem
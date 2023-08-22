local CItemBatchRefineView = class("CItemBatchRefineView", CViewBase)

function CItemBatchRefineView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemBatchRefineView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "sub"
	self.m_ExtendClose = "Black"
end

function CItemBatchRefineView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ItemNameL = self:NewUI(2, CLabel)
	self.m_DescLabelClone = self:NewUI(3, CLabel)
	self.m_DescTable = self:NewUI(4, CTable)
	self.m_AmountBox = self:NewUI(5, CAmountSettingBox)
	self.m_SingleRewardL = self:NewUI(6, CLabel)
	self.m_TotalRewardL = self:NewUI(7, CLabel)
	self.m_RefineBtn = self:NewUI(8, CButton)
	self.m_GoldCoinRefineBtn = self:NewUI(9, CButton)
	self.m_RefineScrollView = self:NewUI(10, CScrollView)
	self.m_RefineItemGrid = self:NewUI(11, CGrid)
	self.m_ItemBoxClone = self:NewUI(12, CItemBaseBox)
	self.m_BagItemGrid = self:NewUI(13, CGrid)
	self.m_BagItemScroll = self:NewUI(14, CScrollView)

	self.m_SelectedItem = nil
	self.m_SelectedItemID = -1
	self.m_TotalReward = 0
	self.m_RefineItemList = {}
	self.m_RefineItemDict = {}
	self.m_BagItemBoxs = {}
	self.m_ResetScroll = false
	self.m_ScrollToTargetItem = false

	self:InitContent()
end

function CItemBatchRefineView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_RefineBtn:AddUIEvent("click", callback(self, "OnClickRefine"))
	self.m_GoldCoinRefineBtn:AddUIEvent("click", callback(self, "OnClickGoldCoinRefine"))
	self.m_GoldCoinRefineBtn:SetText("10#cur_2=588精气")

	self.m_AmountBox:SetCallback(callback(self, "OnAmountChange"))
	self.m_AmountBox:SetAmountRange(0, 0)
	self.m_AmountBox:SetValue(0)

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))

	self:RefreshBagItemGrid()
end

function CItemBatchRefineView.SetSelectedItem(self, iItemID)
	self.m_SelectedItemID = iItemID
	self.m_ScrollToTargetItem = true
	self:RefreshBagItemGrid()
end

function CItemBatchRefineView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.DelItem then
		self:DelRefineItem(oCtrl.m_EventData, true)
	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:DelRefineItem(oCtrl.m_EventData.m_ID, false)
	end
end

----------------------ui create or refresh--------------------
--物品信息面板
function CItemBatchRefineView.RefreshItemInfo(self)
	local bIsEmpty = self.m_SelectedItem == nil
	if bIsEmpty then
		self.m_ItemNameL:SetText("")
		self.m_SingleRewardL:SetText("0")
		self.m_DescTable:Clear()
		return
	end

	local iQuality = self.m_SelectedItem:GetQuality()
	local sTextName = string.format(data.colorinfodata.ITEM[iQuality].color, self.m_SelectedItem:GetItemName())
	self.m_ItemNameL:SetText(sTextName)
	self.m_SingleRewardL:SetText(self.m_SelectedItem:GetRefineValue())
	self:CreateItemDesc()
end

function CItemBatchRefineView.CreateItemDesc(self)
	local tableList = self.m_DescTable:GetChildList()

	local function createDes(index, des)
		local oLabel = nil
		if index > #tableList then
			oLabel = self.m_DescLabelClone:Clone()
			self.m_DescTable:AddChild(oLabel)
		else	
			oLabel = tableList[index]
		end
		--对一些description进行特殊处理，如根据宝图item数据设置地图坐标描述
		local function SetLabel(sText)
			local itemsid = self.m_SelectedItem:GetSValueByKey("sid")
			if itemsid == define.Treasure.Config.Item5 or itemsid == define.Treasure.Config.Item4 then
				local treasureInfo = g_ItemViewCtrl:GetTreasureInfo(self.m_SelectedItem)
				local sInfo = DataTools.GetSceneNameByMapId(treasureInfo.treasure_mapid)
				oLabel:SetText(string.format(sText,sInfo))
			else
				oLabel:SetText(sText)
			end
		end
		SetLabel(des)
		-- oLabel:SetText(des)
		oLabel:SetActive(true)
	end

	local description = self.m_SelectedItem:GetCValueByKey("description")
	if type(description) == "table" then
		for i,v in ipairs(description) do
			createDes(v)
		end
	elseif type(description) == "string" then
		createDes(1, description)
	end
end

function CItemBatchRefineView.RefreshTotalReward(self)
	local iTotalReward = self:CalculateReward()
	self.m_TotalRewardL:SetText(iTotalReward)
end

function CItemBatchRefineView.RefreshAmountBox(self)
	self.m_AmountBox:EnableTouch(self.m_SelectedItem ~= nil)
	if self.m_SelectedItem == nil then
		self.m_AmountBox:SetValue(0)
		return
	end
	local iAmount = self.m_SelectedItem:GetSValueByKey("amount")
	self.m_AmountBox:SetAmountRange(1, iAmount)

	local iIndex = self.m_RefineItemDict[self.m_SelectedItemID]
	if iIndex then
		self.m_AmountBox:SetValue(iAmount)
	else
		self.m_AmountBox:SetValue(1)
	end
end

--TODO:UI需求修改，不需要显示选中的物品列表，不想改逻辑，直接UI隐藏 以下
--待炼化物品
function CItemBatchRefineView.RefreshRefineItemGrid(self)
	if self.m_ResetScroll then
		self.m_RefineScrollView:ResetPosition()
		self.m_ResetScroll = false
	end
	self.m_RefineItemDict = {}
	local iCnt = math.max(self.m_RefineItemGrid:GetCount(), #self.m_RefineItemList)
	for i=1, iCnt do
		local dItem = self.m_RefineItemList[i]
		local oBox = self.m_RefineItemGrid:GetChild(i)
		if not oBox then
			oBox = self:CreateItemBox()
			self.m_RefineItemGrid:AddChild(oBox)
		end	
		local dItem = self.m_RefineItemList[i]
		if dItem then
			self.m_RefineItemDict[dItem.item_id] = i
		end
		self:UpdateRefineItemBox(oBox, dItem)
	end
	self.m_RefineItemGrid:Reposition()
end

function CItemBatchRefineView.UpdateRefineItemBox(self, oBox, dItem)	
	oBox:SetActive(dItem ~= nil)
	if not dItem then
		return
	end
	local oItem = dItem.bagItem
	oBox:SetBagItem(oItem)
	oBox:SetAmountText(dItem.amount)
	oBox:SetClickCallback(callback(self, "OnClickCancel"))
	oBox:SetActive(true)
	
end

--TODO:UI需求修改，不需要显示选中的物品列表 以上

function CItemBatchRefineView.CreateItemBox(self)
	local oBox = self.m_ItemBoxClone:Clone()
	oBox.m_DelSpr = oBox:NewUI(6, CSprite)
	return oBox
end

--背包物品
function CItemBatchRefineView.RefreshBagItemGrid(self)
	for i,oBox in ipairs(self.m_BagItemBoxs) do
		oBox:DelEffect("Rect")
		oBox:SetActive(false)
	end

	local lItem = g_ItemCtrl:GetRefineItemList()
	local iUnlockCount = g_ItemCtrl:GetBagOpenCount()
	local oSelBox = nil
	local iSelIndex = 1
	for i=1, iUnlockCount do
		local oItem = lItem[i]
		local oBox = self.m_BagItemBoxs[i]
		if not oBox then
			oBox = self:CreateItemBox() 
			self.m_BagItemGrid:AddChild(oBox)
			self.m_BagItemBoxs[i] = oBox
			oBox:SetClickCallback(callback(self, "OnClickBagItem"))
		end
		self:UpdateBagItemBox(oBox, oItem)
		if oItem and self.m_SelectedItemID == oItem.m_ID then
			self:OnClickBagItem(oBox)
			oSelBox = oBox
			iSelIndex = i
		end
	end
	self.m_BagItemGrid:Reposition()
	if oSelBox and self.m_ScrollToTargetItem and iSelIndex > 16 then
		UITools.MoveToTarget(self.m_BagItemScroll, oSelBox)
	end
	self.m_ScrollToTargetItem = false
end

function CItemBatchRefineView.UpdateBagItemBox(self, oBox, oItem)
	if not oItem then
		oBox:DelEffect("Rect")
	end
	oBox:ShowEquipLevel(true)
	oBox:ShowWenShiLevel(true)
	oBox:SetBagItem(oItem)
	oBox:SetActive(true)
	oBox:SetEnableTouch(true)
	self:UpdateBoxSelectStatus(oBox)
	
end

function CItemBatchRefineView.UpdateBagItemBoxByItem(self, iItemID)
	for i,oBox in ipairs(self.m_BagItemBoxs) do
		if oBox.m_Item and oBox.m_Item.m_ID == iItemID then
			self:UpdateBagItemBox(oBox, g_ItemCtrl.m_BagItems[iItemID])
			break
		end
	end
end

function CItemBatchRefineView.ShowTreasureItem(self)
	for i,oBox in ipairs(self.m_BagItemBoxs) do
		local oItem = oBox:GetBagItem()
		if oBox:GetActive() and oItem and oItem:IsTreasureItem() and
			self.m_RefineItemDict[oItem.m_ID] ~= nil then
			oBox:AddEffect("Rect")
		end
	end
end

function CItemBatchRefineView.UpdateBoxSelectStatus(self, oBagItem)
	local oItem = oBagItem.m_Item
	local iIndex = oItem and self.m_RefineItemDict[oItem.m_ID]
	local bIsShowDel = oItem ~= nil and iIndex ~= nil
	oBagItem.m_DelSpr:SetActive(bIsShowDel)
	if bIsShowDel then
		local iAmount = self.m_RefineItemList[iIndex].amount
		oBagItem.m_AmountLabel:SetText(iAmount.."/"..oItem:GetSValueByKey("amount"))
	else
		oBagItem.m_AmountLabel:SetText(oItem and oItem:GetSValueByKey("amount") or 0)
	end
end

----------------------click event or event listener-----------------------------
function CItemBatchRefineView.OnClickBagItem(self, oBox)
	if not oBox.m_Item then
		return
	end
	local bIsSelected = self.m_RefineItemDict[oBox.m_Item.m_ID] ~= nil
	if bIsSelected then
		self:DelRefineItem(oBox.m_Item.m_ID, true)
		bIsSelected = false
	else
		self.m_SelectedItem = oBox.m_Item
		self.m_SelectedItemID = oBox.m_Item.m_ID
		self:AddRefineItem(oBox.m_Item, 1)
		bIsSelected = true
	end
	oBox:SetSelected(true)
	self:RefreshItemInfo()
	self:RefreshAmountBox()
end

function CItemBatchRefineView.OnClickCancel(self, oBox)
	local iItemID = oBox.m_Item.m_ID
	self:DelRefineItem(iItemID, true)
end

function CItemBatchRefineView.OnClickRefine(self)
	-- g_NotifyCtrl:FloatMsg("炼化")
	if #self.m_RefineItemList == 0 then
		g_NotifyCtrl:FloatMsg("请先选择需要炼化的道具")
		return
	end

	local bContainTreasure = self:CheckContainTreasure()
	if not bContainTreasure then
		self:RequestChangeItemToVigor()
		return
	end

	local windowConfirmInfo = {
		msg = "你选中的炼化物品中包含珍稀物品，是否确认炼化",
		okCallback = function () 
			self:RequestChangeItemToVigor()
		end,	
		cancelCallback = function ()
			self:ShowTreasureItem()
		end,
		pivot = enum.UIWidget.Pivot.Center,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CItemBatchRefineView.RequestChangeItemToVigor(self)
	local list = {}
	for i,v in ipairs(self.m_RefineItemList) do
		table.insert(list, {item_id = v.item_id, change_amount = v.amount})
	end
	netvigor.C2GSChangeItemToVigor(list)
end

function CItemBatchRefineView.OnClickGoldCoinRefine(self)
	-- g_NotifyCtrl:FloatMsg("元宝炼化")
	if g_AttrCtrl:GetGoldCoin() >= 10 then
		local windowConfirmInfo = {
			msg = "是否消耗10元宝获取588精气",
			okCallback = function () 
				netvigor.C2GSChangeGoldcoinToVigor()
			end,
			pivot = enum.UIWidget.Pivot.Center,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		g_ShopCtrl:ShowChargeComfirm()
	end
end

function CItemBatchRefineView.OnAmountChange(self, iAmount)
	if not self.m_SelectedItem then
		return
	end
	self:AddRefineItem(self.m_SelectedItem, self.m_AmountBox:GetValue())
end

------------------------data op----------------------------------------
function CItemBatchRefineView.AddRefineItem(self, oBagItem, iAmount)
	local iIndex = self.m_RefineItemDict[oBagItem.m_ID]
	if iIndex then
		self.m_RefineItemList[iIndex].amount = iAmount
	else
		local dItem = {
			item_id = oBagItem.m_ID,
			amount = iAmount,
			reward = oBagItem:GetRefineValue(),
			bagItem = oBagItem
		}
		table.insert(self.m_RefineItemList, dItem)
	end
	self:RefreshRefineItemGrid()
	self:RefreshTotalReward()
	self:UpdateBagItemBoxByItem(self.m_SelectedItemID)
end

function CItemBatchRefineView.DelRefineItem(self, iItemID, bIsDel)
	local iIndex = self.m_RefineItemDict[iItemID]
	local dItem = self.m_RefineItemList[iIndex]
	local bIsUpdate = not bIsDel	

	if bIsUpdate and dItem ~= nil then
		local iAmountChange = g_ItemCtrl.m_BagItems[iItemID].m_AmountChange
		if -iAmountChange ~= dItem.amount then
			return
		end
	end

	table.remove(self.m_RefineItemList, iIndex)
	self.m_RefineItemDict[iItemID] = nil
	if self.m_SelectedItem and self.m_SelectedItem.m_ID == iItemID then
		self.m_SelectedItem = nil
		self.m_SelectedBox = nil
		self:RefreshItemInfo()
		self:RefreshAmountBox()
	end
	self:RefreshRefineItemGrid()
	self:RefreshTotalReward()
	self:UpdateBagItemBoxByItem(iItemID)
end

function CItemBatchRefineView.CalculateReward(self)
	local iReward = 0
	for i,v in ipairs(self.m_RefineItemList) do
		iReward = iReward + v.amount*v.reward
	end
	return iReward
end

function CItemBatchRefineView.CheckContainTreasure(self)
	for i,dItem in ipairs(self.m_RefineItemList) do
		if dItem.bagItem:IsTreasureItem() then
			return true
		end
	end
end
return CItemBatchRefineView 
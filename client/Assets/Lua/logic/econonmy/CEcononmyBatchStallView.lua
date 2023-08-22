local CEcononmyBatchStallView = class("CEcononmyBatchStallView", CViewBase)

function CEcononmyBatchStallView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Econonmy/EcononmyBatchStallView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CEcononmyBatchStallView.OnCreateView(self)
	self.m_BgSpr = self:NewUI(1, CSprite)
	self.m_ItemIconSpr = self:NewUI(2, CSprite)
	self.m_QualitySpr = self:NewUI(3, CSprite)
	self.m_NameL = self:NewUI(4, CLabel)
	self.m_SuggestedPriceL = self:NewUI(5, CLabel)
	self.m_CloseBtn = self:NewUI(6, CButton)
	self.m_ItemNode = self:NewUI(7, CObject)
	self.m_BatchStallBtn = self:NewUI(8, CButton)
	self.m_TaxL = self:NewUI(9, CLabel)
	self.m_AmountBox = self:NewUI(10, CAmountSettingBox)
	self.m_PriceBox = self:NewUI(11, CAmountSettingBox)
	self.m_TotalPriceL = self:NewUI(12, CLabel)
	self.m_Grid = self:NewUI(13, CGrid)
	self.m_ItemBoxClone = self:NewUI(14, CItemBaseBox)
	self.m_StallGridL = self:NewUI(15, CLabel)

	self.m_Price = 0
	self.m_Tax = 0
	self.m_TotalPrice = 0
	self.m_StallItemList = {}
	self.m_DefalutPrices = {}
	self.m_RemainingGrid = 0
	self.m_SelectedItem = -1
	self.m_StallId = nil

	self:InitContent()
end

function CEcononmyBatchStallView.InitContent(self)
	self.m_ItemBoxClone:SetActive(false)
	self.m_ItemIconSpr:SetActive(false)
	self.m_NameL:SetActive(false)
	self.m_AmountBox:EnableTouch(false)
	self.m_AmountBox:EnableGrey(true)
	self.m_PriceBox:EnableTouch(false)
	self.m_PriceBox:EnableGrey(true)

	self.m_RemainingGrid = g_EcononmyCtrl:GetRemainingGridCount()
	self.m_BatchStallBtn:AddUIEvent("click", callback(self, "RequestBatchStall"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	self.m_AmountBox:SetCallback(callback(self, "OnValueChange"))
	self.m_PriceBox:SetCallback(callback(self, "OnPriceChange"))
	self.m_PriceBox:EnableKeyBoard(false)
	self:RefreshItemGrid()
	self:RefreshItemInfo()
end

-------------------------数据设置和刷新-------------------------------------
function CEcononmyBatchStallView.SetItemInfo(self, oItem)
	self.m_Item = oItem
	local sid = oItem:GetCValueByKey("id")
	local iQuality = self.m_Item:GetQuality()
	if self.m_Item:IsFoodItem() or self.m_Item:IsMedicineItem() then
		iQuality = self.m_Item:GetSValueByKey("itemlevel")
	end

	if self.m_Item:IsFuZhuanItem() then
		iQuality = self.m_Item:GetFuZhuanLevel() * 10
	end

	local iServerStallId = self.m_Item:GetSValueByKey("stallId")
	self.m_StallId = iServerStallId and iServerStallId or DataTools.ConvertItemIdToStallId(sid, iQuality)
	if not self.m_DefalutPrices[self.m_StallId] then
		self:RefreshItemBasePanel()
		-- netstall.C2GSGetDefaultPrice(sid)
		netstall.C2GSGetDefaultPrice(self.m_StallId)
	else
		local iPrice = self:GetRecordPrice(self.m_StallId)
		if iPrice > 0 then
			self.m_Price = iPrice
		end
		self:RefreshItemInfo()
	end
end

function CEcononmyBatchStallView.SetPrice(self, iSid, iPrice, iStallId)
	self.m_DefalutPrices[iStallId] = iPrice
	if iSid ~= self.m_Item:GetCValueByKey("id") then
		return
	end

	self.m_Price = self:GetRecordPrice(iStallId)
	if self.m_Price == 0 then
		self.m_Price = iPrice
	end
	local iAmount = self.m_Item:GetSValueByKey("amount")
	self:AddStallItem(self.m_Item.m_ID, iAmount, self.m_Price, self.m_Item:GetSValueByKey("stallpos"))
	self:RefreshItemInfo()
end

function CEcononmyBatchStallView.SetSelectedItem(self, iItemId)
	self.m_SelectedItem = iItemId
end

function CEcononmyBatchStallView.GetRecordPrice(self, iStallId)
	local iPrice = 0
	if self.m_Item:GetSValueByKey("stallprice") then
		iPrice = self.m_Item:GetSValueByKey("stallprice")
	elseif g_EcononmyCtrl.m_StallRecords[iStallId] then
		printc("使用记录的价格")
		iPrice = g_EcononmyCtrl.m_StallRecords[iStallId]
	end 
	return iPrice
end

-------------------------UI刷新-------------------------------------
function CEcononmyBatchStallView.RefreshItemInfo(self)
	self:RefreshItemBasePanel()
	self:RefreshAmountBox()
	self:RefreshPriceBox()
	self:RefreshTotalPriceLabel()
	self:RefreshTaxLabel()
	self:RefreshStallGridLabel()
	self:RefreshSuggestedLabel()
end

function CEcononmyBatchStallView.RefreshItemGrid(self)
	self.m_Grid:Clear()
	local iUnlockCount = g_ItemCtrl:GetBagOpenCount() + 8
	local list = g_EcononmyCtrl:GetStallOverTimeItemList()
	for i,oItem in ipairs(list) do
		self:AddStallItem(oItem.m_ID, 0, oItem:GetSValueByKey("stallprice"), oItem:GetSValueByKey("stallpos"))
	end
	table.extend(list, g_ItemCtrl:GetCanStallItemList())
	-- local list = g_ItemCtrl:GetCanStallItemList()
	-- table.print(list)

	for i=1, iUnlockCount do
		local oItem = list[i]
		local oBox = self:CreateItemBox(oItem)
		self.m_Grid:AddChild(oBox)
		if oItem and oItem.m_ID == self.m_SelectedItem then
			oBox:SetSelected(true)
			self:OnClickItemBox(oBox)
		end
	end
end

function CEcononmyBatchStallView.CreateItemBox(self, oItem)
	local oBox = self.m_ItemBoxClone:Clone()
	oBox.m_DelBtn = oBox:NewUI(6, CButton)
	oBox.m_OverTimeSpr = oBox:NewUI(7, CSprite)

	oBox.m_OverTimeSpr:SetActive(oItem and oItem.m_ID < 0)
	oBox:SetBagItem(oItem)
	oBox:SetActive(true)
	oBox:SetClickCallback(callback(self, "OnClickItemBox", oBox))
	oBox.m_DelBtn:AddUIEvent("click", callback(self, "OnClickBoxDel", oBox))
	return oBox
end

function CEcononmyBatchStallView.RefreshItemBasePanel(self)
	local bIsEmpty = self.m_Item == nil
	self.m_StallGridL:SetActive(bIsEmpty)
	self.m_ItemNode:SetActive(not bIsEmpty)
	self.m_ItemIconSpr:SetActive(not bIsEmpty)
	self.m_NameL:SetActive(not bIsEmpty)
	if bIsEmpty then
		self.m_NameL:SetText("")
		self.m_QualitySpr:SetItemQuality(1)
		return
	end

	local icon = self.m_Item:GetCValueByKey("icon")
	self.m_ItemIconSpr:SpriteItemShape(icon)
	local quality = self.m_Item:GetQuality()
	local textName = string.format(data.colorinfodata.ITEM[quality].color, self.m_Item:GetItemName())
	self.m_NameL:SetText(textName)
	self.m_QualitySpr:SetItemQuality(quality)
end

function CEcononmyBatchStallView.RefreshAmountBox(self)
	self.m_AmountBox:EnableTouch(self.m_Item ~= nil)
	if self.m_Item == nil then
		self.m_AmountBox:SetValue(0)
		return
	end
	local iAmount = self.m_Item:GetSValueByKey("amount")
	if self.m_Item.m_ID > 0 then
		self.m_AmountBox:SetAmountRange(1, iAmount)
	else
		self.m_AmountBox:SetAmountRange(iAmount, iAmount)
	end

	local dItem = self.m_StallItemList[self.m_Item.m_ID]
	if dItem and dItem.amount > 0 then
		self.m_AmountBox:SetValue(dItem.amount)
	else
		self.m_AmountBox:SetValue(iAmount)
	end
end

function CEcononmyBatchStallView.RefreshPriceBox(self)
	self.m_PriceBox:EnableTouch(self.m_Item ~= nil)
	if self.m_Item == nil then
		self.m_PriceBox:SetMidValue(nil)
		self.m_PriceBox:SetValue(0)
		return
	end
	local iDefalutPrice = self.m_DefalutPrices[self.m_StallId]
	local dItem = self.m_StallItemList[self.m_Item.m_ID]
	if dItem and dItem.price > 0 then
		self.m_Price = dItem.price
	else
		self.m_Price = iDefalutPrice
	end

	-- 这里半价需向上取整数
	local dItemData = data.stalldata.ITEMINFO[self.m_StallId]
	local iMaxPrice = math.floor(dItemData.base_price*dItemData.max_price/100)
	local iMinPrice = math.floor(dItemData.base_price*dItemData.min_price/100)
	iMaxPrice = math.min(math.floor(iDefalutPrice*1.5), iMaxPrice)
	iMinPrice = math.max(math.ceil(iDefalutPrice*0.5), iMinPrice)

	self.m_PriceBox:SetAmountRange(iMinPrice, iMaxPrice)
	self.m_PriceBox:SetMidValue(iDefalutPrice)
	self.m_PriceBox:SetStepValue(math.floor(iDefalutPrice/10))

	self.m_Price = self.m_PriceBox:AdjustValue(self.m_Price)
	self.m_PriceBox:SetValue(self.m_Price)
end

function CEcononmyBatchStallView.RefreshTotalPriceLabel(self)
	if self.m_Item == nil then
		self.m_TotalPriceL:SetText(0)
		return
	end
	local iAmount = self.m_AmountBox:GetValue()
	local iIncome = math.floor(iAmount*self.m_Price)
	self.m_TotalPriceL:SetCommaNum(iIncome)
end

function CEcononmyBatchStallView.RefreshTaxLabel(self)
	if self.m_Item == nil then
		self.m_TaxL:SetText(0)
		return
	end
	local iTax = data.stalldata.ITEMINFO[self.m_StallId].tax
	local iAmount = self.m_AmountBox:GetValue()
	local iCost = math.floor(iAmount*iTax/100*self.m_Price)
	self.m_TaxL:SetCommaNum(iCost)
	self.m_Tax = iCost
end

function CEcononmyBatchStallView.RefreshStallGridLabel(self)
	self.m_StallGridL:SetText(self.m_RemainingGrid)
end

function CEcononmyBatchStallView.RefreshSuggestedLabel(self)
	self.m_SuggestedPriceL:SetActive(self.m_Item ~= nil)
	if self.m_Item == nil then
		return
	end
	local sid = self.m_Item:GetCValueByKey("id")
	local iRadio = math.floor(self.m_Price/self.m_DefalutPrices[self.m_StallId]*100 + 0.5)
	self.m_SuggestedPriceL:SetText(iRadio.."%")
end

-------------------------点击响应-------------------------------------
function CEcononmyBatchStallView.RequestBatchStall(self)
	if not next(self.m_StallItemList) then
		return
	end
	local lBagItem = {}
	local lOvertimeItem = {}
	local iPrice = 0
	for k,dItem in pairs(self.m_StallItemList) do
		if k > 0 then
			iPrice = dItem.price + iPrice
			table.insert(lBagItem, dItem)
		elseif k < 0 and dItem.amount > 0 then
			local t = {
				pos_id = dItem.item_id,
				price = dItem.price,
			}
			table.insert(lOvertimeItem, t)
		end
	end
	if #lOvertimeItem > 0 then
		netstall.C2GSResetItemListPrice(lOvertimeItem) 
	end
	if #lBagItem > 0 then
		if self.m_Tax > g_AttrCtrl.silver then
		    g_QuickGetCtrl:CheckLackItemInfo({
		        coinlist = {{sid = 1002, amount = self.m_Tax, count = g_AttrCtrl.silver}},
		        exchangeCb = function()
		            netstall.C2GSAddSellItemList(lBagItem)
		            self:CloseView()
		        end
		    })
		    return
		else
			netstall.C2GSAddSellItemList(lBagItem)
		end
	end

	self:CloseView()
end

function CEcononmyBatchStallView.OnClickItemBox(self, oBox)
	if self.m_RemainingGrid == 0 and oBox.m_Item.m_ID > 0 then
		g_NotifyCtrl:FloatMsg("已达到最大出售商品种类")
		return
	end
	oBox.m_DelBtn:SetActive(true)
	self:SetItemInfo(oBox.m_Item)
	self:SetSelectedItem(oBox.m_Item.m_ID)
end

function CEcononmyBatchStallView.OnClickBoxDel(self, oBox)
	oBox.m_DelBtn:SetActive(false)
	oBox:ForceSelected(false)
	self:DelStallItem(oBox.m_ID)
end

function CEcononmyBatchStallView.OnValueChange(self, iValue)
	if not self.m_Item then
		return
	end
	self:AddStallItem(self.m_Item.m_ID, iValue, self.m_Price, self.m_Item:GetSValueByKey("stallpos"))
	self:RefreshTotalPriceLabel()
	self:RefreshTaxLabel()
end

function CEcononmyBatchStallView.OnPriceChange(self, iValue)
	if not self.m_Item then
		return
	end
	self.m_Price = iValue
	self:AddStallItem(self.m_Item.m_ID, self.m_AmountBox:GetValue(), self.m_Price, self.m_Item:GetSValueByKey("stallpos"))
	self:RefreshTotalPriceLabel()
	self:RefreshTaxLabel()
	self:RefreshSuggestedLabel()
	local sid = self.m_Item:GetCValueByKey("id")
end

----------------------------------------------------------------
function CEcononmyBatchStallView.AddStallItem(self, iID, iAmount, iPrice, iStallpos)
	-- printerror(iPrice, "====== CEcononmyBatchStallView.AddStallItem")
	if not self.m_StallItemList[iID] then
		if iID > 0 then
			self.m_RemainingGrid  = self.m_RemainingGrid - 1
			self:RefreshStallGridLabel()
		end
	end
	self.m_StallItemList[iID] = {
		item_id = iStallpos or iID,
		amount = iAmount,
		price = iPrice
	}
	if self.m_StallId then
		g_EcononmyCtrl.m_StallRecords[self.m_StallId] = iPrice
	end
end

function CEcononmyBatchStallView.DelStallItem(self, iID)
	self.m_StallItemList[iID] = nil
	if iID > 0 then
		self.m_RemainingGrid  = self.m_RemainingGrid + 1
		self:RefreshStallGridLabel()
	end
	-- if self.m_Item and self.m_Item.m_ID == iID then
		self.m_Item = nil
		self:RefreshItemInfo()
	-- end
end

return CEcononmyBatchStallView
local CEcononmyStallOparateView = class("CEcononmyStallOparateView", CViewBase)

function CEcononmyStallOparateView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Econonmy/EcononmyStallOparateView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CEcononmyStallOparateView.OnCreateView(self)
	self.m_BgSpr = self:NewUI(1, CSprite)
	self.m_ItemBox = self:NewUI(2, CItemBaseBox)
	self.m_NameL = self:NewUI(4, CLabel)
	self.m_IntroductionL = self:NewUI(5, CLabel)
	self.m_CashL = self:NewUI(6, CLabel)
	self.m_TaxL = self:NewUI(7, CLabel)
	self.m_StallBtn = self:NewUI(8, CButton)
	self.m_AmountBox = self:NewUI(9, CAmountSettingBox)
	self.m_PriceBox = self:NewUI(10, CAmountSettingBox)
	self.m_TotalPriceL = self:NewUI(11, CLabel)
	self.m_CancelBtn = self:NewUI(12, CButton)
	self.m_CashTitleL = self:NewUI(13, CLabel)

	self.m_Tax = 0
	self.m_Price = 0
	self:InitContent()
end

function CEcononmyStallOparateView.InitContent(self)
	self.m_StallBtn:AddUIEvent("click", callback(self, "OnClickStallOparate"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancel"))
	self.m_AmountBox:SetCallback(callback(self, "OnValueChange"))
	self.m_PriceBox:SetCallback(callback(self, "OnPriceChange"))
	self.m_PriceBox:EnableKeyBoard(false)
end

function CEcononmyStallOparateView.SetItemInfo(self, oItem, iStatus, dStallInfo)
	self.m_Item = oItem
	self.m_Status = iStatus
	self.m_StallInfo = dStallInfo
	-- local sid = oItem:GetCValueByKey("id")
	-- local iQuality = self.m_Item:GetQuality()
	-- if self.m_Item:IsFoodItem() or self.m_Item:IsMedicineItem() then
	-- 	iQuality = self.m_Item:GetSValueByKey("itemlevel")
	-- end
	-- if self.m_Item:IsFuZhuanItem() then
	-- 	iQuality = self.m_Item:GetFuZhuanLevel() * 10
	-- end
	-- self.m_StallId = DataTools.ConvertItemIdToStallId(sid, iQuality)
	self.m_StallId = dStallInfo.query_id
	if not self.m_DefalutPrice and iStatus ~= define.Econonmy.StallStatus.SellOut then
		self:RefreshItemBasePanel()
		netstall.C2GSGetDefaultPrice(self.m_StallId)
	else
		self:RefreshAll()
	end
end

function CEcononmyStallOparateView.SetPrice(self, iSid, iPrice)
	self.m_DefalutPrice = iPrice
	if self.m_Status == define.Econonmy.StallStatus.None then
		self.m_StallInfo.price = iPrice
	end
	self:RefreshAll()
end

function CEcononmyStallOparateView.RefreshAll(self)
	self:RefreshItemBasePanel()
	self:RefreshPriceBox()
	self:RefreshAmountBox()
	self:RefreshTotalPriceLabel()
	self:RefreshTaxLabel()
	self:RefreshCashLabel()
	self:RefreshButton()
end

function CEcononmyStallOparateView.RefreshButton(self)
	if not self.m_Status then
		return
	end
	if self.m_Status == define.Econonmy.StallStatus.SellOut then
		self.m_StallBtn:SetText("提取")
	elseif self.m_Status == define.Econonmy.StallStatus.OverTime or 
		self.m_Status == define.Econonmy.StallStatus.OnSell then
		self.m_StallBtn:SetText("重新上架")
		self.m_CancelBtn:SetText("免费下架")
		self.m_StallBtn:SetLabelSpacingX(0)
		self.m_CancelBtn:SetLabelSpacingX(0)
	elseif self.m_Status == define.Econonmy.StallStatus.None then
		self.m_StallBtn:SetText("上架")
	end
end

function CEcononmyStallOparateView.RefreshItemBasePanel(self)
	self.m_ItemBox:SetBagItem(self.m_Item)
	self.m_ItemBox:SetEnableTouch(false)
	self.m_ItemBox:SetAmountText(0)
	local quality = self.m_Item:GetQuality()
	local textName = string.format(data.colorinfodata.ITEM[quality].color, self.m_Item:GetItemName())
	self.m_NameL:SetText(textName)
	self.m_IntroductionL:SetText(self.m_Item:GetCValueByKey("introduction"))
end

function CEcononmyStallOparateView.RefreshAmountBox(self)
	local iAmount = self.m_StallInfo.amount
	self.m_AmountBox:SetValue(iAmount)
	if self.m_Status == define.Econonmy.StallStatus.OverTime or 
		self.m_Status == define.Econonmy.StallStatus.None then
		self.m_AmountBox:SetAmountRange(1, iAmount)	
	else
		self.m_AmountBox:SetAmountRange(iAmount, iAmount)	
	end
end

function CEcononmyStallOparateView.RefreshPriceBox(self)
	local iCurPrice = self.m_StallInfo.price	
	self.m_PriceBox:SetValue(iCurPrice)
	if self.m_Status == self.m_Status == define.Econonmy.StallStatus.SellOut then
		self.m_PriceBox:SetAmountRange(iCurPrice, iCurPrice)	
	else
		local dItemData = data.stalldata.ITEMINFO[self.m_StallId]
		local iMaxPrice = math.floor(dItemData.base_price*dItemData.max_price/100)
		local iMinPrice = math.floor(dItemData.base_price*dItemData.min_price/100)
		iMaxPrice = math.min(math.floor(self.m_DefalutPrice*1.5), iMaxPrice)
		iMinPrice = math.max(math.ceil(self.m_DefalutPrice*0.5), iMinPrice)

		self.m_PriceBox:SetAmountRange(iMinPrice, iMaxPrice)
		self.m_PriceBox:SetStepValue(math.floor(self.m_DefalutPrice/10))
		self.m_PriceBox:SetMidValue(self.m_DefalutPrice)
		iCurPrice = self.m_PriceBox:AdjustValue(iCurPrice)
		self.m_PriceBox:SetValue(iCurPrice)
	end
end

function CEcononmyStallOparateView.RefreshTotalPriceLabel(self)
	local iAmount = self.m_AmountBox:GetValue()
	local iIncome = math.floor(iAmount*self.m_Price)
	self.m_TotalPriceL:SetText(iIncome)
end

function CEcononmyStallOparateView.RefreshTaxLabel(self)
	local iTax = data.stalldata.ITEMINFO[self.m_StallId].tax
	local iAmount = self.m_AmountBox:GetValue()
	local iCost = math.floor(iAmount*iTax/100*self.m_Price)
	self.m_Tax = iCost
	self.m_TaxL:SetText(iCost)
end

function CEcononmyStallOparateView.RefreshCashLabel(self)
	self.m_CashTitleL:SetActive(self.m_Status ~= define.Econonmy.StallStatus.None)
	if self.m_StallInfo then
		self.m_CashL:SetText(self.m_StallInfo.cash)
	end
end

function CEcononmyStallOparateView.OnClickStallOparate(self)
	if self.m_Status == define.Econonmy.StallStatus.SellOut then
		netstall.C2GSWithdrawOneGrid(self.m_StallInfo.pos_id)
	elseif self.m_Status == define.Econonmy.StallStatus.OverTime or
		self.m_Status == define.Econonmy.StallStatus.OnSell then
		local t = {
			pos_id = self.m_StallInfo.pos_id,
			price = self.m_Price,
		}
		if self.m_Status == define.Econonmy.StallStatus.OverTime then
			if self.m_Tax > g_AttrCtrl.silver then
			    g_QuickGetCtrl:CheckLackItemInfo({
			        coinlist = {{sid = 1002, amount = self.m_Tax, count = g_AttrCtrl.silver}},
			        exchangeCb = function()
			            netstall.C2GSResetItemListPrice({[1] = t})
			            self:CloseView()
			        end
			    })
				return
			end
		end
		netstall.C2GSResetItemListPrice({[1] = t})
		g_EcononmyCtrl.m_StallRecords[self.m_StallId] = self.m_Price
	elseif self.m_Status == define.Econonmy.StallStatus.None then
		local iId = self.m_Item.m_ID
		local iAmount = self.m_AmountBox:GetValue()
		local iPrice = self.m_Price
		local iTax = self.m_Tax
		if iTax > g_AttrCtrl.silver then
		    g_QuickGetCtrl:CheckLackItemInfo({
		        coinlist = {{sid = 1002, amount = iTax, count = g_AttrCtrl.silver}},
		        exchangeCb = function()
		            netstall.C2GSAddSellItemList({{item_id = iId, amount = iAmount, price = iPrice}})
		            self:CloseView()
		        end
		    })
		    return
		else
			netstall.C2GSAddSellItemList({{item_id = iId, amount = iAmount, price = iPrice}})
		end
	end
	self:CloseView()
end

function CEcononmyStallOparateView.OnClickCancel(self)
	if self.m_Status == define.Econonmy.StallStatus.OverTime or
		self.m_Status == define.Econonmy.StallStatus.OnSell then
		netstall.C2GSRemoveSellItem(self.m_StallInfo.pos_id, self.m_AmountBox:GetValue())
	end
	self:CloseView()
end

function CEcononmyStallOparateView.OnValueChange(self, iValue)
	self:RefreshTotalPriceLabel()
	self:RefreshTaxLabel()
end

function CEcononmyStallOparateView.OnPriceChange(self, iValue)
	self.m_Price = iValue
	self:RefreshTotalPriceLabel()
	self:RefreshTaxLabel()
end

return CEcononmyStallOparateView
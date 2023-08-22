-- local CEcononmyAuctionOparateView = class("CEcononmyAuctionOparateView", CViewBase)

-- function CEcononmyAuctionOparateView.ctor(self, cb)
-- 	CViewBase.ctor(self, "UI/Econonmy/EcononmyAuctionOparateView.prefab", cb)
-- 	--界面设置
-- 	self.m_DepthType = "Dialog"
-- 	self.m_ExtendClose = "Black"
-- end

-- function CEcononmyAuctionOparateView.OnCreateView(self)
-- 	self.m_AuctionBtn = self:NewUI(1, CButton)
-- 	self.m_CancelBtn = self:NewUI(2, CButton)
-- 	self.m_CycleL = self:NewUI(3, CLabel)
-- 	self.m_PriceBox = self:NewUI(4, CAmountSettingBox)
-- 	self.m_IconSpr = self:NewUI(5, CSprite)
-- 	self.m_QualitySpr = self:NewUI(6, CSprite)
-- 	self.m_NameL = self:NewUI(7, CLabel)
-- 	-- self.m_IntroductionL = self:NewUI(8, CLabel)
-- 	self.m_AmountBox = self:NewUI(9, CAmountSettingBox)

-- 	self.m_Price = 0
-- 	self.m_IsWithdraw = false
-- 	self:InitContent()
-- end

-- function CEcononmyAuctionOparateView.InitContent(self)
-- 	self.m_AuctionBtn:AddUIEvent("click", callback(self, "RequestAution"))
-- 	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancel"))
-- 	self.m_PriceBox:SetCallback(callback(self, "OnPriceChange"))
-- 	self.m_PriceBox:EnableKeyBoard(false)
-- end

-- function CEcononmyAuctionOparateView.SetAuctionInfo(self, dAuction, bIsWithdraw)
-- 	self.m_AuctionItem = dAuction
-- 	self.m_IsWithdraw = bIsWithdraw
-- 	self.m_AuctionData = DataTools.GetAuctionItemData(dAuction.sid)
-- 	self:RefreshAll()
-- end

-- function CEcononmyAuctionOparateView.RefreshAll(self)
-- 	self:RefreshPriceBox()
-- 	self:RefreshAmountBox()
-- 	self:RefreshAuctionItem()
-- 	self:RefreshAuctionButton()
-- end

-- function CEcononmyAuctionOparateView.RefreshAuctionButton(self)
-- 	if self.m_IsWithdraw then
-- 		self.m_AuctionBtn:SetText("下架")
-- 	end
-- end

-- function CEcononmyAuctionOparateView.RefreshAuctionItem(self)
-- 	local dData = nil
-- 	if self.m_AuctionItem.type == define.Econonmy.AuctionType.Item then
-- 		dData = DataTools.GetItemData(self.m_AuctionItem.sid)
-- 		self.m_NameL:SetText(dData.name)
-- 		self.m_IconSpr:SpriteItemShape(dData.icon)
-- 	else
-- 		dData = DataTools.GetSummonInfo(self.m_AuctionItem.sid)
-- 		self.m_NameL:SetText(dData.name)
-- 		self.m_IconSpr:SpriteAvatar(dData.shape)
-- 	end
-- end

-- function CEcononmyAuctionOparateView.RefreshPriceBox(self)
-- 	local iCurPrice = self.m_AuctionItem.price or self.m_AuctionData.price
-- 	self.m_PriceBox:SetValue(iCurPrice)
-- 	self.m_PriceBox:EnableTouch(not self.m_IsWithdraw)
-- 	local iHalfPrice = math.floor(iCurPrice/2)
-- 	self.m_PriceBox:SetAmountRange(iHalfPrice, iHalfPrice*3)
-- 	self.m_PriceBox:SetStepValue(math.floor(iCurPrice/10))
-- end

-- function CEcononmyAuctionOparateView.RefreshAmountBox(self)
-- 	--TODO:应策划需求，可拍卖的物品都是数量不可叠加的
-- 	local iAmount = 1--self.m_Item:GetSValueByKey("amount")
-- 	self.m_AmountBox:SetValue(1)
-- 	self.m_AmountBox:EnableTouch(false)--not self.m_IsWithdraw)
-- 	-- self.m_AmountBox:SetAmountRange(1, iAmount)
-- end

-- function CEcononmyAuctionOparateView.RefreshCycleLabel(self)
-- 	local iPrice = self.m_PriceBox:GetValue()

-- 	local sFormula = string.replace(self.m_AuctionData.auction_time, "price", iPrice)
-- 	local func = loadstring("return "..sFormula)
-- 	local iCycle = math.floor(func())
-- 	self.m_CycleL:SetText(iCycle)
-- end

-- function CEcononmyAuctionOparateView.RequestAution(self)
-- 	--TODO:请求拍卖上架或下架
-- 	local iAmount = self.m_AmountBox:GetValue()
-- 	local iPrice = self.m_PriceBox:GetValue()
-- 	if not self.m_IsWithdraw then
-- 		if self.m_AuctionItem.type == define.Econonmy.AuctionType.Item then
-- 			netauction.C2GSAuctionUpItem(self.m_AuctionItem.id, iAmount, iPrice)
-- 		else
-- 			netauction.C2GSAuctionUpSummon(self.m_AuctionItem.id, iPrice)
-- 		end
-- 	else
-- 		netauction.C2GSAuctionDownItem(self.m_AuctionItem.id)
-- 	end
-- 	self:CloseView()
-- end

-- function CEcononmyAuctionOparateView.OnClickCancel(self)
-- 	self:CloseView()
-- end

-- function CEcononmyAuctionOparateView.OnPriceChange(self, iValue)
-- 	self.m_Price = iValue
-- 	self:RefreshCycleLabel()
-- end

-- return CEcononmyAuctionOparateView
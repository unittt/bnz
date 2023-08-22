-- local CEcononmyAuctionBidView = class("CEcononmyAuctionBidView", CViewBase)

-- function CEcononmyAuctionBidView.ctor(self, cb)
-- 	CViewBase.ctor(self, "UI/Econonmy/EcononmyAuctionBidView.prefab", cb)
-- 	--界面设置
-- 	self.m_DepthType = "Dialog"
-- 	self.m_ExtendClose = "Black"
-- end

-- function CEcononmyAuctionBidView.OnCreateView(self)
-- 	self.m_AuctionBtn = self:NewUI(1, CButton)
-- 	self.m_CancelBtn = self:NewUI(2, CButton)
-- 	self.m_CurPriceL = self:NewUI(3, CLabel)
-- 	self.m_PriceBox = self:NewUI(4, CAmountSettingBox)
-- 	self.m_IconSpr = self:NewUI(5, CSprite)
-- 	self.m_QualitySpr = self:NewUI(6, CSprite)
-- 	self.m_NameL = self:NewUI(7, CLabel)
-- 	-- self.m_IntroductionL = self:NewUI(8, CLabel)

-- 	self.m_Price = 0
-- 	self.m_IsAgent = false
-- 	self:InitContent()
-- end

-- function CEcononmyAuctionBidView.InitContent(self)
-- 	self.m_AuctionBtn:AddUIEvent("click", callback(self, "RequestAution"))
-- 	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancel"))
-- 	self.m_PriceBox:SetCallback(callback(self, "OnPriceChange"))
-- 	self.m_PriceBox:EnableKeyBoard(false)
-- end

-- function CEcononmyAuctionBidView.SetAuctionInfo(self, dAuction, bIsAgent)
-- 	self.m_AuctionItem = dAuction
-- 	self.m_IsAgent = bIsAgent
-- 	self:SetPrice(self.m_AuctionItem.price)
-- 	self:RefreshAll()
-- end

-- function CEcononmyAuctionBidView.SetPrice(self, iPrice)
-- 	self.m_DefalutPrice = iPrice
-- end

-- function CEcononmyAuctionBidView.RefreshAll(self)
-- 	-- self:RefreshItemBasePanel()
-- 	self:RefreshPriceBox()
-- 	self:RefreshCurPriceLabel()
-- 	self:RefreshAuctionItem()
-- end

-- function CEcononmyAuctionBidView.RefreshAuctionItem(self)
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

-- -- function CEcononmyAuctionBidView.RefreshItemBasePanel(self)
-- -- 	local icon = self.m_Item:GetCValueByKey("icon")
-- -- 	self.m_ItemIconSpr:SpriteItemShape(icon)
-- -- 	local quality = self.m_Item:GetCValueByKey("quality") or 0
-- -- 	local textName = string.format(data.colorinfodata.ITEM[quality].color, self.m_Item:GetCValueByKey("name"))
-- -- 	self.m_NameL:SetText(textName)
-- -- 	self.m_IntroductionL:SetText(self.m_Item:GetCValueByKey("introduction"))
-- -- 	self.m_QualitySpr:SetItemQuality(quality)
-- -- end

-- function CEcononmyAuctionBidView.RefreshPriceBox(self)
-- 	local iCurPrice = self.m_DefalutPrice
-- 	self.m_PriceBox:SetValue(iCurPrice)
-- 	self.m_PriceBox:SetAmountRange(iCurPrice, iCurPrice*10)
-- 	self.m_PriceBox:SetStepValue(math.floor(iCurPrice/5))
-- end

-- function CEcononmyAuctionBidView.RefreshCurPriceLabel(self)
-- 	self.m_CurPriceL:SetText(self.m_DefalutPrice)
-- end

-- function CEcononmyAuctionBidView.RequestAution(self)
-- 	local iPrice = self.m_PriceBox:GetValue()
-- 	if iPrice > g_AttrCtrl:GetGoldCoin() then
-- 		g_NotifyCtrl:FloatMsg("元宝不足，请购买")
-- 		return
-- 	end
-- 	if self.m_IsAgent and iPrice < self.m_DefalutPrice*1.1 then
-- 		g_NotifyCtrl:FloatMsg("代理价格过低，请重新输入")
-- 		return
-- 	end
-- 	--TODO:请求拍卖价格或申请代理
-- 	local iAutionId = self.m_AuctionItem.id
-- 	if self.m_IsAgent then
-- 		netauction.C2GSSetProxyPrice(iAutionId, iPrice)
-- 	else
-- 		netauction.C2GSAuctionBid(iAutionId, iPrice)
-- 	end
-- 	self:CloseView()
-- end

-- function CEcononmyAuctionBidView.OnClickCancel(self)
-- 	self:CloseView()
-- end

-- function CEcononmyAuctionBidView.OnPriceChange(self, iValue)
-- 	self.m_Price = iValue
-- 	self:RefreshCurPriceLabel()
-- end

-- return CEcononmyAuctionBidView
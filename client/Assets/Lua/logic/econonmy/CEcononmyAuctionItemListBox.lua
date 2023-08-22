local CEcononmyAuctionItemListBox = class("CEcononmyAuctionItemListBox", CBox)

function CEcononmyAuctionItemListBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_CallBack = cb

	self.m_ItemScroll = self:NewUI(1, CScrollView)
	self.m_ScrollAreaW = self:NewUI(2, CWidget)
	self.m_ItemGrid = self:NewUI(3, CGrid)
	self.m_AuctionItemClone = self:NewUI(4, CBox)

	self.m_ItemBoxs = {}
	self:InitContent()
end

function CEcononmyAuctionItemListBox.InitContent(self)
	self.m_AuctionItemClone:SetActive(false)
end

function CEcononmyAuctionItemListBox.SetClickCallback(self, cb)
	self.m_CallBack = cb
end

function CEcononmyAuctionItemListBox.RefreshAll(self)
	self:RefreshItemGrid()
end

function CEcononmyAuctionItemListBox.RefreshItemGrid(self)
	self.m_ItemList = g_EcononmyCtrl:GetAuctionItemList() or {}
	for i = 1, #self.m_ItemBoxs do
		local oBox = self.m_ItemBoxs[i]
		oBox:SetActive(false)
		if oBox.m_AuctionTimer then
			Utils.DelTimer(oBox.m_AuctionTimer)
			oBox.m_AuctionTimer = nil
		end
	end
	local bHasTaskItem = g_EcononmyCtrl:HasTaskItem(define.Econonmy.Type.Auction)
	local bIsInit = true
	local oSelectedBox = nil
	for i,dInfo in ipairs(self.m_ItemList) do
		local oBox = self.m_ItemBoxs[i]
		if not oBox then
			oBox = self:CreateAuctionItem()
			self.m_ItemBoxs[i] = oBox
			self.m_ItemGrid:AddChild(oBox)
		end
		self:UpdateAuctionItem(oBox, dInfo)
		if i == 1 then
			oSelectedBox = oBox
		end
	end
	if oSelectedBox then
		self:OnClickAuctionItemBox(oSelectedBox)
	else
		self:OnClickAuctionItemBox(nil)
	end

	self.m_ItemGrid:Reposition()
end

function CEcononmyAuctionItemListBox.CreateAuctionItem(self)
	local oBox = self.m_AuctionItemClone:Clone()
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_ItemBtn = oBox:NewUI(2, CWidget)
	oBox.m_ItemSpr = oBox:NewUI(3, CSprite)
	oBox.m_CurrencySpr = oBox:NewUI(4, CSprite)
	oBox.m_PriceL = oBox:NewUI(5, CLabel)
	oBox.m_AmountL = oBox:NewUI(6, CLabel)
	oBox.m_TimeL = oBox:NewUI(7, CLabel)
	oBox.m_BidFlagSpr = oBox:NewUI(8, CLabel)
	oBox.m_FollowSpr = oBox:NewUI(9, CSprite)
	oBox.m_QualitySpr = oBox:NewUI(10, CSprite)

	oBox.m_ItemSpr:AddUIEvent("click", callback(self, "OnClickItemLink", oBox))
	oBox:AddUIEvent("click", callback(self, "OnClickAuctionItemBox"))
	oBox.m_FollowSpr:AddUIEvent("click", callback(self, "OnClickFollow", oBox))
	return oBox
end

function CEcononmyAuctionItemListBox.UpdateAuctionItem(self, oBox, dInfo)
	local dItemData = nil
	if dInfo.type == define.Econonmy.AuctionType.Item then
		 dItemData = DataTools.GetItemData(dInfo.sid)
		 oBox.m_QualitySpr:SetItemQuality(dInfo.quality)
	else
		 dItemData = DataTools.GetSummonInfo(dInfo.sid)
		 oBox.m_QualitySpr:SetItemQuality(define.Item.Quality.Orange)
	end
	if not dItemData then
		oBox:SetActive(false)
		return
	end
	oBox:SetActive(true)

	oBox.m_MarkupPrice = math.ceil(dInfo.base_price*0.1)
	oBox.m_AuctionId = dInfo.id
	oBox.m_Sid = dInfo.sid
	oBox.m_AuctionInfo = dInfo
	oBox.m_Price = dInfo.price
	oBox.m_Name = dItemData.name

	oBox.m_NameL:SetText(dItemData.name)
	oBox.m_CurrencySpr:SpriteCurrency(dInfo.money_type)
	oBox.m_PriceL:SetText(dInfo.price)
	oBox.m_BidFlagSpr:SetActive(dInfo.bidder == g_AttrCtrl.pid)
	oBox.m_FollowSpr:SetSelected(dInfo.is_follow == 1)
	if dInfo.type == define.Econonmy.AuctionType.Item then
		oBox.m_ItemSpr:SpriteItemShape(dItemData.icon)
	else
		oBox.m_ItemSpr:SpriteAvatar(dItemData.shape)
	end
	self:RefreshAuctionTime(oBox)
end

function CEcononmyAuctionItemListBox.RefreshAuctionTime(self, oBox)
	if oBox.m_AuctionTimer then
		Utils.DelTimer(oBox.m_AuctionTimer)
		oBox.m_AuctionTimer = nil
	end
	local function update()
		if Utils.IsNil(self) then
			return
		end
		if g_EcononmyCtrl:IsOverTime(oBox.m_AuctionInfo) then
			oBox:SetActive(false)
			self.m_ItemGrid:Reposition()
			if oBox == self.m_SelectedBox then
				self:OnClickAuctionItemBox(nil)
			end
			return
		end
		if g_EcononmyCtrl:IsInShowTime(oBox.m_AuctionInfo) then
			local sTime = g_TimeCtrl:GetTimeMDHM(oBox.m_AuctionInfo.show_time)
			oBox.m_TimeL:SetText("[a64e00]"..sTime)
		elseif g_EcononmyCtrl:IsInAuctionTime(oBox.m_AuctionInfo) then
			local iLeftTime = math.floor(os.difftime(oBox.m_AuctionInfo.price_time, g_TimeCtrl:GetTimeS()))
			local sTime = g_TimeCtrl:GetLeftTimeDHMAlone(iLeftTime, true)
			if not sTime then
				sTime = iLeftTime
			end
			oBox.m_TimeL:SetText("[af302a]距结束[244B4E]"..sTime)
		end
		return true
	end
	oBox.m_AuctionTimer = Utils.AddTimer(update, 0.5, 0)
end

function CEcononmyAuctionItemListBox.GetAuctionItemBoxById(self, iAuctionId)
	local list = self.m_ItemGrid:GetChildList()
	for _,oBox in ipairs(self.m_ItemBoxs) do
		if oBox.m_AuctionId and oBox.m_AuctionId == iAuctionId then
			return oBox
		end
	end
end

function CEcononmyAuctionItemListBox.UpdateAuctionItemById(self, iAuctionId, dInfo, bRefreshPrice)
	local oBox = self:GetAuctionItemBoxById(iAuctionId)
	if oBox then
		if g_EcononmyCtrl:IsOverTime(dInfo) then
			oBox:SetActive(false)
			if oBox == self.m_SelectedBox then
				self:OnClickAuctionItemBox(nil)
			end
		else
			self:UpdateAuctionItem(oBox, dInfo)
			if oBox == self.m_SelectedBox then
				self:OnClickAuctionItemBox(oBox, bRefreshPrice)
			end 
		end
		self.m_ItemGrid:Reposition()
	end
end

function CEcononmyAuctionItemListBox.UpdateAuctionPriceById(self, iAuctionId, iPrice)
	local oBox = self:GetAuctionItemBoxById(iAuctionId)
	if oBox then
		oBox.m_Price = iPrice
		oBox.m_PriceL:SetText(iPrice)
	end
end

function CEcononmyAuctionItemListBox.OnClickAuctionItemBox(self, oBox, bRefreshPrice)
	self.m_SelectedBox = oBox
	if oBox then
		oBox:SetSelected(true)
	end
	if self.m_CallBack then
		self.m_CallBack(oBox, bRefreshPrice)
	end
end

function CEcononmyAuctionItemListBox.OnClickFollow(self, oBox)
	netauction.C2GSToggleFollow(oBox.m_AuctionId)
end

function CEcononmyAuctionItemListBox.OnClickItemLink(self, oBox)
	netauction.C2GSAuctionDetail(oBox.m_AuctionId)
end

return CEcononmyAuctionItemListBox
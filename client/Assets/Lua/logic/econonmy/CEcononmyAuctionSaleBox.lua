-- local CEcononmyAuctionSaleBox = class("CEcononmyAuctionSaleBox", CBox)

-- function CEcononmyAuctionSaleBox.ctor(self, obj, cb)
-- 	CBox.ctor(self, obj)
-- 	self.m_CallBack = cb

-- 	self.m_SellItemGrid = self:NewUI(1, CGrid)
-- 	self.m_SellItemBoxClone = self:NewUI(2, CBox)
-- 	self.m_ItemTab = self:NewUI(3, CButton)
-- 	self.m_SummonTab = self:NewUI(4, CButton)
-- 	self.m_ScrollView = self:NewUI(5, CScrollView)
-- 	self.m_BagItemGrid = self:NewUI(6, CGrid)  
-- 	self.m_BagItemBoxClone = self:NewUI(7, CBox)
-- 	self.m_CashL = self:NewUI(8, CLabel)
-- 	self.m_WithdrawCashBtn = self:NewUI(9, CButton)
-- 	self.m_StallCountL = self:NewUI(10, CLabel)
-- 	self.m_RecordBtn = self:NewUI(11, CButton)
-- 	self.m_TipsBtn = self:NewUI(12, CButton)
-- 	self.m_EmptyTipL = self:NewUI(13, CLabel)

-- 	self.m_SellItemBoxs = {}
-- 	self.m_BagItemBoxs = {}
-- 	self.m_Tabs = {
-- 		[1] = self.m_ItemTab,
-- 		[2] = self.m_SummonTab
-- 	}
-- 	self.m_CurTab = -1
-- 	self:InitContent()
-- end

-- function CEcononmyAuctionSaleBox.InitContent(self)
-- 	self.m_SellItemBoxClone:SetActive(false)
-- 	self.m_BagItemBoxClone:SetActive(false)
-- 	self.m_ItemTab:AddUIEvent("click", callback(self, "ChangeTab", 1))
-- 	self.m_SummonTab:AddUIEvent("click", callback(self, "ChangeTab", 2))
-- 	self.m_WithdrawCashBtn:AddUIEvent("click", callback(self, "RequestWithdrawCash"))
-- 	self.m_RecordBtn:AddUIEvent("click", callback(self, "RequestAuctionRecord"))
-- 	self.m_TipsBtn:AddUIEvent("click", callback(self, "ShowTipView"))
-- 	g_EcononmyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

-- 	self:InitSellItemBoxs()
-- 	self:ChangeTab(1)
-- end

-- -------------------------Ctrl事件监听------------------------
-- function CEcononmyAuctionSaleBox.OnCtrlEvent(self, oCtrl)
-- 	if oCtrl.m_EventID == define.Econonmy.Event.RefreshMyAuctionList then
-- 		self:SetSellItemList(g_EcononmyCtrl:GetMyAuctionList())
-- 		self:RefreshAll()
-- 	end
-- end

-- -------------------------数据初始化------------------------
-- function CEcononmyAuctionSaleBox.SetSellItemList(self, list)
-- 	self.m_SellItemList = list
-- end

-- function CEcononmyAuctionSaleBox.InitBagItemList(self, iType)
-- 	if iType == define.Econonmy.AuctionType.Item then
-- 		self.m_BagItemList = g_ItemCtrl:GetCanAuctionItemList()
-- 	else
-- 		self.m_BagItemList = g_SummonCtrl:GetAuctionSummonList()
-- 	end
-- end

-- -------------------------UI创建和刷新------------------------
-- function CEcononmyAuctionSaleBox.InitSellItemBoxs(self)
-- 	for i = 1, CEcononmyCtrl.AuctionSellLimit do
-- 		local oBox = self.m_SellItemBoxs[i]
-- 		if not oBox then
-- 			oBox = self:CreateSellItemBox()
-- 			self.m_SellItemBoxs[i] = oBox
-- 			self.m_SellItemGrid:AddChild(oBox)
-- 		end
-- 	end
-- end

-- function CEcononmyAuctionSaleBox.RefreshAll(self)
-- 	self:RefreshCashLabel()
-- 	self:RefreshStallCountLabel()
-- 	self:RefreshSellItemGrid()
-- 	self:InitBagItemList(self.m_CurTab)
-- 	self:RefreshBagItemGrid()
-- end

-- function CEcononmyAuctionSaleBox.RefreshCashLabel(self)
-- 	local iIncome = g_EcononmyCtrl:GetAuctionIncome()
-- 	self.m_CashL:SetText(iIncome)
-- end

-- function CEcononmyAuctionSaleBox.RefreshStallCountLabel(self)
-- 	local iCount = #self.m_SellItemList
-- 	self.m_StallCountL:SetText(string.format("我的摊位%d/%d", iCount, CEcononmyCtrl.AuctionSellLimit))
-- end

-- function CEcononmyAuctionSaleBox.RefreshSellItemGrid(self)
-- 	for i = 1, CEcononmyCtrl.AuctionSellLimit do
-- 		local oBox = self.m_SellItemBoxs[i]
-- 		local dInfo = self.m_SellItemList[i]
-- 		self:UpdateSellItemBox(oBox, dInfo)
-- 	end
-- end

-- function CEcononmyAuctionSaleBox.CreateSellItemBox(self)
-- 	local oBox = self.m_SellItemBoxClone:Clone()
-- 	oBox.m_NameL = oBox:NewUI(1, CLabel)
-- 	oBox.m_StatusL = oBox:NewUI(2, CLabel)
-- 	oBox.m_CurrencySpr = oBox:NewUI(3, CSprite)
-- 	oBox.m_PriceL = oBox:NewUI(4, CLabel)
-- 	oBox.m_IconSpr = oBox:NewUI(5, CSprite)
-- 	oBox.m_NodeObj = oBox:NewUI(6, CObject)
-- 	oBox:SetActive(true)
-- 	oBox:AddUIEvent("click", callback(self, "OnClickSellItemBox", oBox))
-- 	return oBox
-- end

-- function CEcononmyAuctionSaleBox.UpdateSellItemBox(self, oBox, dInfo)
-- 	oBox.m_AuctionInfo = dInfo
-- 	oBox.m_NodeObj:SetActive(dInfo ~= nil)
-- 	if not dInfo then
-- 		return
-- 	end
-- 	local dData = nil
-- 	if dInfo.type == define.Econonmy.AuctionType.Item then
-- 		dData = DataTools.GetItemData(dInfo.sid)
-- 		oBox.m_IconSpr:SpriteItemShape(dData.icon)
-- 	else
-- 		dData = DataTools.GetSummonInfo(dInfo.sid)
-- 		oBox.m_IconSpr:SpriteAvatar(dData.shape)
-- 	end
-- 	oBox.m_NameL:SetText(dData.name)
-- 	oBox.m_PriceL:SetText(dInfo.price)
-- 	if dInfo.status == 1 then
-- 		oBox.m_StatusL:SetText("公示中")
-- 	elseif dInfo.status == 2 then
-- 		oBox.m_StatusL:SetText("竞拍中")
-- 	elseif dInfo.status == 3 then 
-- 		oBox.m_StatusL:SetText("已下架")
-- 	elseif dInfo.status == 4 then
-- 		oBox.m_StatusL:SetText("可提现")
-- 	end
-- end

-- function CEcononmyAuctionSaleBox.RefreshBagItemGrid(self)
-- 	-- self.m_BagItemGrid:Clear()
-- 	self.m_EmptyTipL:SetActive(not self.m_BagItemList or #self.m_BagItemList == 0)

-- 	for i,oBox in ipairs(self.m_BagItemBoxs) do
-- 		if oBox:GetActive() then
-- 			oBox:SetActive(false)
-- 		end
-- 	end
-- 	if not self.m_BagItemList then
-- 		return
-- 	end
-- 	for i,dInfo in ipairs(self.m_BagItemList) do
-- 		local oBox = self.m_BagItemBoxs[i]
-- 		if not oBox then
-- 			oBox = self:CreateBagItemBox()
-- 			self.m_BagItemBoxs[i] = oBox
-- 			self.m_BagItemGrid:AddChild(oBox)
-- 		end
-- 		self:UpdateBagItemBox(oBox, dInfo, self.m_CurTab)
-- 	end
-- 	self.m_BagItemGrid:Reposition()
-- end

-- function CEcononmyAuctionSaleBox.CreateBagItemBox(self)
-- 	local oBox = self.m_BagItemBoxClone:Clone()
-- 	oBox.m_NameL = oBox:NewUI(1, CLabel)
-- 	oBox.m_IconSpr = oBox:NewUI(2, CSprite)
-- 	oBox:AddUIEvent("click", callback(self, "OnClickBagItemBox"))
-- 	return oBox
-- end

-- function CEcononmyAuctionSaleBox.UpdateBagItemBox(self, oBox, dInfo, iType)
-- 	oBox:SetActive(true)
-- 	oBox.m_Type = iType
-- 	oBox.m_ItemInfo = dInfo
-- 	if iType == define.Econonmy.AuctionType.Item then
-- 		oBox.m_ID = dInfo.m_ID
-- 		oBox.m_SID = dInfo:GetCValueByKey("id")
-- 		oBox.m_NameL:SetText(dInfo:GetItemName())
-- 		oBox.m_IconSpr:SpriteItemShape(dInfo:GetCValueByKey("icon"))
-- 	else
-- 		oBox.m_ID = dInfo.id
-- 		oBox.m_SID = dInfo.typeid
-- 		oBox.m_NameL:SetText(dInfo.name)
-- 		oBox.m_IconSpr:SpriteAvatar(dInfo.model_info.shape)
-- 	end
-- end

-- -------------------------点击事件监听------------------------
-- function CEcononmyAuctionSaleBox.RequestWithdrawCash(self)
-- 	netauction.C2GSAuctionGetAllCash()
-- end

-- function CEcononmyAuctionSaleBox.RequestAuctionRecord(self)
-- 	netauction.C2GSAuctionLog()
-- 	CEcononmyAuctionRecordView:ShowView()
-- end

-- function CEcononmyAuctionSaleBox.OnClickSellItemBox(self, oBox)
-- 	if not oBox.m_AuctionInfo then
-- 		return
-- 	end
-- 	if oBox.m_AuctionInfo.status == 4 then
-- 		netauction.C2GSAuctionGetCash(oBox.m_AuctionInfo.id)
-- 		return
-- 	end
-- 	CEcononmyAuctionOparateView:ShowView(function(oView)
-- 		oView:SetAuctionInfo(oBox.m_AuctionInfo, true)
-- 	end)
-- end

-- function CEcononmyAuctionSaleBox.OnClickBagItemBox(self, oBox)
-- 	local dAuction = {id = oBox.m_ID, sid = oBox.m_SID, type = oBox.m_Type}
-- 	CEcononmyAuctionOparateView:ShowView(function(oView)
-- 		oView:SetAuctionInfo(dAuction, false)
-- 	end)
-- end

-- function CEcononmyAuctionSaleBox.ShowTipView(self)
-- 	local id = define.Instruction.Config.Auction
--     local content = {
--         title = data.instructiondata.DESC[id].title,
--         desc  = data.instructiondata.DESC[id].desc
--     }
--     g_WindowTipCtrl:SetWindowInstructionInfo(content)
-- end

-- function CEcononmyAuctionSaleBox.ChangeTab(self, iTab)
-- 	if iTab ~= self.m_CurTab then
-- 		self.m_ScrollView:ResetPosition()
-- 	end
-- 	self.m_CurTab = iTab
-- 	self.m_SelectedBagItem = nil
-- 	self.m_Tabs[iTab]:SetSelected(true)
-- 	self:InitBagItemList(iTab)
-- 	self:RefreshBagItemGrid()
-- end

-- return CEcononmyAuctionSaleBox
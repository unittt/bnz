-- local CEcononmyAuctionBuyBox = class("CEcononmyAuctionBuyBox", CBox)

-- function CEcononmyAuctionBuyBox.ctor(self, obj, cb)
-- 	CBox.ctor(self, obj)
-- 	self.m_CallBack = cb

-- 	self.m_MyFollowBtn = self:NewUI(1, CButton)
-- 	self.m_MyAuctionBtn = self:NewUI(2, CButton)
-- 	self.m_CatalogListBox = self:NewUI(3, CEcononmyCatalogListBox)
-- 	self.m_SubCatalogListBox = self:NewUI(4, CEcononmySubCatalogListBox)
-- 	self.m_AuctionItemListBox = self:NewUI(5, CEcononmyAuctionItemListBox)
-- 	self.m_EquipLvMenu = self:NewUI(6, CPopupBox)
-- 	self.m_SortBtn = self:NewUI(7, CButton)
-- 	self.m_AgentAuctionBtn = self:NewUI(8, CButton)
-- 	self.m_AuctionBtn = self:NewUI(9, CButton)
-- 	self.m_MoreBtn = self:NewUI(10, CButton)
-- 	self.m_ScrollView = self:NewUI(11, CScrollView)
-- 	self.m_ScrollArea = self:NewUI(12, CWidget)
-- 	self.m_SendWorldBtn = self:NewUI(13, CButton)
-- 	self.m_SendOrgBtn = self:NewUI(14, CButton)
-- 	self.m_PopupTable = self:NewUI(15, CTable)
-- 	self.m_ExtendWidget = self:NewUI(16, CWidget)
-- 	self.m_EmptyTipObj = self:NewUI(17, CObject)

-- 	self.m_IsInAuction = true
-- 	self.m_IsPriceSort = true
-- 	self:InitContent()
-- end

-- function CEcononmyAuctionBuyBox.InitContent(self)
-- 	self.m_CatalogListBox:SetCallback(callback(self, "OnCatalogChange"))
-- 	self.m_SubCatalogListBox:SetClickCallback(callback(self, "OnSubCatalogChange"))
-- 	self.m_SubCatalogListBox:SetDragCallback(callback(self, "OnScrollPageStart"), 
-- 		callback(self, "OnScrollPage"), callback(self, "OnScrollPageEnd"))
-- 	self.m_AuctionItemListBox:SetPageCallback(callback(self, "OnPageChange"))
-- 	self.m_AuctionItemListBox:SetClickCallback(callback(self, "OnItemChange"))
-- 	self.m_AuctionItemListBox:SetDragCallback(callback(self, "OnScrollPageStart"), 
-- 		callback(self, "OnScrollPage"), callback(self, "OnScrollPageEnd"))

-- 	self.m_ScrollArea:AddUIEvent("dragstart", callback(self, "OnScrollPageStart"))
-- 	self.m_ScrollArea:AddUIEvent("drag", callback(self, "OnScrollPage"))
-- 	self.m_ScrollArea:AddUIEvent("dragend", callback(self, "OnScrollPageEnd"))

-- 	self.m_MyFollowBtn:AddUIEvent("click", callback(self, "RequestMyFollow"))
-- 	self.m_MyAuctionBtn:AddUIEvent("click", callback(self, "RequestMyAuction"))
-- 	self.m_SortBtn:AddUIEvent("click", callback(self, "OnClickPriceSort"))
-- 	self.m_AgentAuctionBtn:AddUIEvent("click", callback(self, "OnClickAuction", true))
-- 	self.m_AuctionBtn:AddUIEvent("click", callback(self, "OnClickAuction", false))
-- 	self.m_SendOrgBtn:AddUIEvent("click", callback(self, "OnClickShare", define.Channel.Org))
-- 	self.m_SendWorldBtn:AddUIEvent("click", callback(self, "OnClickShare", define.Channel.World))
-- 	self.m_MoreBtn:AddUIEvent("click", callback(self, "OnClickExpandMenu"))

-- 	g_UITouchCtrl:TouchOutDetect(self.m_ExtendWidget, callback(self, "OnTouchOutDetect"))
--  --    g_UITouchCtrl:TouchOutDetect(self.m_SendWorldBtn, callback(self.m_PopupTable, "SetActive", false))

-- 	self.m_CatalogListBox:SetCatalogData(data.auctiondata.CATALOG, define.Econonmy.Type.Auction)
-- 	g_EcononmyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

-- 	--TODO:策划不明，该功能与子目录相同
-- 	self.m_EquipLvMenu:SetActive(false)
-- end

-- function CEcononmyAuctionBuyBox.OnTouchOutDetect(self, gameObj)
--     self.m_ExtendWidget:SetActive(false)
--     self.m_PopupTable:SetActive(false)
-- end

-- -------------------------Ctrl事件监听------------------------
-- function CEcononmyAuctionBuyBox.OnCtrlEvent(self, oCtrl)
-- 	if oCtrl.m_EventID == define.Econonmy.Event.RefreshAuctionItemList then
-- 		self:ShowAuctionItemList(true)
-- 		self:RefreshAuctionItemListBox()
-- 		self:RefreshAgentButton()
-- 	elseif oCtrl.m_EventID == define.Econonmy.Event.RefreshAuctionItem then
-- 		local dInfo = oCtrl.m_EventData
-- 		self.m_AuctionItemListBox:UpdateAuctionItemById(dInfo.id, dInfo)
-- 		self.m_AuctionInfo = dInfo
-- 		self:RefreshAgentButton()
-- 	end
-- end

-- --TODO:策划不明，该功能与子目录相同
-- -- function CEcononmyAuctionBuyBox.InitLevelPopupBox(self)
-- -- 	self.m_EquipLvMenu:Clear()
-- -- 	self.m_EquipLvMenu:SetCallback(callback(self, "OnLevelChange"))
-- -- 	local iMinLv = DataTools.GetGlobalData(110).value
-- -- 	local iMaxLv = math.max(math.floor(g_AttrCtrl.server_grade/10)*10, iMinLv)
-- -- 	for i = iMaxLv, iMinLv, -10 do
-- -- 		self.m_EquipLvMenu:AddSubMenu(i.."级", i)
-- -- 	end
-- -- end

-- -------------------------UI状态切换------------------------
-- function CEcononmyAuctionBuyBox.ShowAuctionItemList(self, bIsShow)
-- 	self.m_SubCatalogListBox:SetActive(not bIsShow)
-- 	self.m_AuctionItemListBox:SetActive(bIsShow)
-- 	self.m_EmptyTipObj:SetActive(g_EcononmyCtrl:GetAuctionItemCount() == 0 and self.m_AuctionItemListBox:GetActive())
-- end

-- --设置UI状态为购买or公示
-- function CEcononmyAuctionBuyBox.SetAuctionStatus(self, bIsInAuction)
-- 	self.m_IsInAuction = bIsInAuction
-- 	if g_EcononmyCtrl:HasTaskItem(define.Econonmy.Type.Auction) then 
-- 		self.m_CatalogListBox:JumpToCatalog(g_EcononmyCtrl:GetFristTaskCatalog(define.Econonmy.Type.Auction))
-- 	else
-- 		self.m_CatalogListBox:JumpToCatalog(1)
-- 	end
-- end

-- function CEcononmyAuctionBuyBox.JumpToTargetItem(self, iCatId, iSubCatId, iStatus, iTarget)
-- 	self.m_IsJump = true
-- 	self.m_CatalogId = iCatId
-- 	self.m_SubCatalogId = iSubCatId
-- 	self.m_CatalogListBox:JumpToCatalog(iCatId)
-- 	self:ShowAuctionItemList(true)
-- 	self.m_AuctionItemListBox:SetSelectedItem(iTarget)
-- 	self:RefreshAuctionItemListBox()
-- 	self:RefreshAgentButton()
-- 	self.m_IsJump = false
-- end

-- -------------------------UI刷新------------------------
-- function CEcononmyAuctionBuyBox.RefreshAuctionItemListBox(self)
-- 	self.m_SelectedBox = nil
-- 	self.m_AuctionInfo = nil
-- 	self.m_AuctionItemListBox:RefreshAll()
-- 	self.m_EmptyTipObj:SetActive(g_EcononmyCtrl:GetAuctionItemCount() == 0 and self.m_AuctionItemListBox:GetActive())
-- end

-- function CEcononmyAuctionBuyBox.RefreshSubCatalogListBox(self, list)
-- 	self.m_SubCatalogListBox:SetCatalogInfo(self.m_CatalogId, list, define.Econonmy.Type.Auction)
-- 	self.m_SubCatalogListBox:RefreshAll()
-- end

-- function CEcononmyAuctionBuyBox.RefreshAgentButton(self)
-- 	if self.m_AuctionInfo and 
-- 		(self.m_AuctionInfo.proxy_bidder == g_AttrCtrl.pid or self.m_AuctionInfo.is_proxy_bidder == 1)  then 
-- 		self.m_AgentAuctionBtn:SetText("取消代理")
-- 	else
-- 		self.m_AgentAuctionBtn:SetText("代理竞价")
-- 	end
-- end

-- -------------------------按键响应或UI状态监听------------------------
-- function CEcononmyAuctionBuyBox.RequestMyFollow(self)
-- 	netauction.C2GSOpenMyFollows(1)
-- 	self.m_AuctionItemListBox:ShowStatus(false)
-- end

-- function CEcononmyAuctionBuyBox.RequestMyAuction(self)
-- 	netauction.C2GSOpenMyBidItems(1)
-- 	self.m_AuctionItemListBox:ShowStatus(true)
-- end

-- function CEcononmyAuctionBuyBox.OnClickShare(self, iChannel)
-- 	if not self.m_SelectedBox then
-- 		g_NotifyCtrl:FloatMsg("未选中物品")
-- 		return
-- 	end
-- 	local dData = nil
-- 	if self.m_AuctionInfo.type == define.Econonmy.AuctionType.Item then
-- 		 dData = DataTools.GetItemData(self.m_AuctionInfo.sid)
-- 	else
-- 		 dData = DataTools.GetSummonInfo(self.m_AuctionInfo.sid)
-- 	end
-- 	local iID = self.m_AuctionInfo.id
-- 	local iPrice = self.m_AuctionInfo.price
-- 	local sName = dData.name
-- 	local sLink = LinkTools.GenerateAuctionLink(iID, iPrice, sName)
-- 	g_ChatCtrl:SendMsg(sLink, iChannel)
-- 	self.m_PopupTable:SetActive(false)
-- 	self.m_ExtendWidget:SetActive(false)
-- end

-- function CEcononmyAuctionBuyBox.OnClickExpandMenu(self)
-- 	local bActive = self.m_PopupTable:GetActive()
-- 	self.m_PopupTable:SetActive(not bActive)
-- 	self.m_ExtendWidget:SetActive(not bActive)
-- end

-- function CEcononmyAuctionBuyBox.OnClickPriceSort(self)
-- 	self.m_IsPriceSort = not self.m_IsPriceSort
-- 	self.m_AuctionItemListBox:SetPriceSort(self.m_IsPriceSort)
-- 	self.m_AuctionItemListBox:RefreshAll()
-- end

-- function CEcononmyAuctionBuyBox.OnClickAuction(self, bIsAgent)
-- 	if not self.m_SelectedBox then
-- 		g_NotifyCtrl:FloatMsg("请先挑选好竞争物品")
-- 		return
-- 	end
-- 	if (self.m_AuctionInfo.proxy_bidder == g_AttrCtrl.pid or self.m_AuctionInfo.is_proxy_bidder == 1) and 
-- 		bIsAgent then 
-- 		netauction.C2GSCancelProxyPrice(self.m_AuctionInfo.id)
-- 		return
-- 	end
-- 	if self.m_AuctionInfo.price_time < g_TimeCtrl:GetTimeS() then
-- 		g_NotifyCtrl:FloatMsg("拍卖已结束")
-- 		return
-- 	end
-- 	CEcononmyAuctionBidView:ShowView(function(oView)
-- 		oView:SetAuctionInfo(self.m_AuctionInfo, bIsAgent)
-- 	end)
-- end

-- function CEcononmyAuctionBuyBox.OnItemChange(self, oBox)
-- 	self.m_SelectedBox = oBox
-- 	self.m_AuctionInfo = oBox.m_AuctionInfo
-- 	if self.m_MyAuctionBtn:GetSelected() then
-- 		local iStatus = self.m_AuctionInfo.status
-- 		local iID = self.m_AuctionInfo.id
-- 		if iStatus == 6 then
-- 			netauction.C2GSAuctionReward(iID)			
-- 		elseif iStatus == 3 or iStatus == 7 then
-- 			netauction.C2GSGetReturnMoney(iID)
-- 		end
-- 	end
-- 	self:RefreshAgentButton()
-- end

-- function CEcononmyAuctionBuyBox.OnLevelChange(self, oBox)
-- 	if not self.m_EquipLvMenu:GetActive() then 
-- 		return
-- 	end
-- 	local subMenu = oBox:GetSelectedSubMenu()
-- 	self.m_SelectedLv = subMenu.m_ExtraData
-- 	-- self:RefreshGrid()
-- 	oBox:SetMainMenu("装备等级"..subMenu.m_ExtraData)
-- end

-- function CEcononmyAuctionBuyBox.OnCatalogChange(self, oBox)
-- 	if self.m_IsJump then
-- 		return
-- 	end
-- 	self.m_AuctionItemListBox:ShowStatus(false)
-- 	self.m_CatalogId = oBox.m_CatalogId
-- 	local list = DataTools.GetEcononmySubCatalogListById(self.m_CatalogId, 
-- 		define.Econonmy.Type.Auction, g_AttrCtrl.server_grade)
-- 	if #list == 0 then
-- 		if self.m_IsInAuction then
-- 			netauction.C2GSOpenAuction(self.m_CatalogId, 0, 1)
-- 		else
-- 			netauction.C2GSShowAuction(self.m_CatalogId, 0, 1)
-- 		end
-- 		self.m_SubCatalogId = 0
-- 	else
-- 		self:ShowAuctionItemList(false)
-- 		self:RefreshSubCatalogListBox(list)	
-- 	end
-- end

-- function CEcononmyAuctionBuyBox.OnSubCatalogChange(self, oBox)
-- 	self.m_SubCatalogId = oBox.m_Id
-- 	-- TODO:向服务器请求商品信息
-- 	if self.m_IsInAuction then
-- 		netauction.C2GSOpenAuction(self.m_CatalogId, self.m_SubCatalogId, 1)
-- 	else
-- 		netauction.C2GSShowAuction(self.m_CatalogId, self.m_SubCatalogId, 1)
-- 	end
-- end

-- function CEcononmyAuctionBuyBox.OnScrollPageStart(self, obj)
-- 	self.m_MoveY = 0
-- end

-- function CEcononmyAuctionBuyBox.OnScrollPage(self, obj, moveDelta)
-- 	local adjust = UITools.GetPixelSizeAdjustment()
-- 	self.m_MoveY = self.m_MoveY + moveDelta.y*adjust
-- end

-- function CEcononmyAuctionBuyBox.OnScrollPageEnd(self, obj)
-- 	self.m_ScrollDir = 0
-- 	if self.m_MoveY > 50 then
-- 		self.m_ScrollDir = 1
-- 	elseif self.m_MoveY < -50 then
-- 		self.m_ScrollDir = -1
-- 	end
-- 	if self.m_ScrollDir == 0 then
-- 		self.m_ScrollView:ResetPosition()
-- 		return
-- 	end
-- 	if self.m_SubCatalogListBox:GetActive() then
-- 		self.m_SubCatalogListBox:OnPageChange(self.m_ScrollDir)
-- 	else
-- 		self.m_AuctionItemListBox:OnPageChange(self.m_ScrollDir)
-- 	end
-- end

-- function CEcononmyAuctionBuyBox.OnPageChange(self, iPage)
-- 	if self.m_IsInAuction then
-- 		netauction.C2GSOpenAuction(self.m_CatalogId, self.m_SubCatalogId, iPage)
-- 	else
-- 		netauction.C2GSShowAuction(self.m_CatalogId, self.m_SubCatalogId, iPage)
-- 	end
-- end

-- return CEcononmyAuctionBuyBox
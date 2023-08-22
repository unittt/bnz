local CEcononmyStallShoppingBox = class("CEcononmyStallShoppingBox", CBox)

function CEcononmyStallShoppingBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_CallBack = cb

	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_CatalogGrid = self:NewUI(2, CGrid)
	self.m_CatalogBoxClone = self:NewUI(3, CBox)
	self.m_StallItemGrid = self:NewUI(4, CGrid) 
	self.m_RefreshBtn = self:NewUI(5, CButton)
	self.m_RefreshTimeL = self:NewUI(6, CLabel)
	self.m_BuyBtn = self:NewUI(7, CButton)
	self.m_AmountBox = self:NewUI(8, CAmountSettingBox)
	self.m_StallItemBoxClone = self:NewUI(9, CBox)
	self.m_WarningL = self:NewUI(10, CLabel)
	self.m_NextPageBtn = self:NewUI(11, CButton)
	self.m_PrePageBtn = self:NewUI(12, CButton)
	self.m_ItemScrollView = self:NewUI(13, CScrollView)
	self.m_ScrollArea = self:NewUI(14, CWidget)
	self.m_SilverBox = self:NewUI(15, CCurrencyBox)
	self.m_PageL = self:NewUI(16, CLabel)

	self.m_SelectedBox = nil
	self.m_CatalogId = -1
	self.m_CurPage = 1
	self.m_PageCount = 1
	self.m_ItemLimit = 8
	self.m_StallItemId = -1
	self.m_Amount = 0
	self.m_PosId = -1
	self.m_StallItemBoxs = {}
	self.m_RefreshTimer = nil
	self.m_IsFreeRefresh = true
	self.m_IsEmpty = true
	self.m_IsInit = true
	self.m_TargetCatalogId = -1
	self:InitContent()
end

function CEcononmyStallShoppingBox.InitContent(self)
	self.m_SilverBox:SetCurrencyType(define.Currency.Type.Silver)
	self.m_StallItemBoxClone:SetActive(false)
	self.m_CatalogBoxClone:SetActive(false)
	-- self.m_NextPageBtn:SetActive(false)
	-- self.m_PrePageBtn:SetActive(false)
	self:InitCatalogGrid()
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnClickBuy"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnClickRefresh"))
	self.m_PrePageBtn:AddUIEvent("click", callback(self, "OnPageChange", -1))
	self.m_NextPageBtn:AddUIEvent("click", callback(self, "OnPageChange", 1))
	self.m_ScrollArea:AddUIEvent("dragstart", callback(self, "OnScrollPageStart"))
	self.m_ScrollArea:AddUIEvent("drag", callback(self, "OnScrollPage"))
	self.m_ScrollArea:AddUIEvent("dragend", callback(self, "OnScrollPageEnd"))
	g_EcononmyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEcononmyEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

-------------------------Ctrl事件监听------------------------
function CEcononmyStallShoppingBox.OnCtrlEcononmyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Econonmy.Event.RefreshStallItemList then
		local iPage = oCtrl.m_EventData.page
		local iCatId = oCtrl.m_EventData.catId
		if self.m_TargetCatalogId and self.m_TargetCatalogId == self.m_CatalogId and 
			self.m_TargetCatalogId == iCatId then
			self.m_CurPage = iPage
			self.m_TargetCatalogId = nil
		end
		self:RefreshAll()
		self.m_IsInit = false
	elseif oCtrl.m_EventID == define.Econonmy.Event.RefreshStallItem then
		local oBox = self.m_StallItemBoxs[oCtrl.m_EventData]
		if oBox then
			local list = g_EcononmyCtrl:GetStallItemListByPage(self.m_CurPage)
			local dInfo = list[oCtrl.m_EventData]
			self:UpdateStallItemBox(oBox, dInfo)
			self:OnClickStallItem(oBox)
		end
		--//入袋动画
		-- local oView =  CEcononmyMainView:GetView()
		if not g_EcononmyCtrl.m_FloatItemList then
			return
		end
		for i=#g_EcononmyCtrl.m_FloatItemList,1,-1 do
			local v = g_EcononmyCtrl.m_FloatItemList[i]
			local oItemData = DataTools.GetItemData(v.itemid)
				--if oView then
					local sPos = g_CameraCtrl:GetUICamera():WorldToScreenPoint(v.pos)
					if sPos.y >= 250 then
						g_NotifyCtrl:FloatItemBox(oItemData.icon, nil, v.pos)
					else --低于一定高度不进行优化  还有高于一定高度呢 o(╯□╰)o
						g_NotifyCtrl:FloatItemBox(oItemData.icon)
					end
				-- else
				  -- 	g_NotifyCtrl:FloatItemBox(oItemData.icon)
				--end
			table.remove(g_EcononmyCtrl.m_FloatItemList, i)
		end
	end
end

function CEcononmyStallShoppingBox.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount then
		local iCurPos = self.m_PosId
		g_EcononmyCtrl:ClearTaskItemList()
		g_EcononmyCtrl:InitTaskItemList()
		self:RefreshTaskStatus()
		if iCurPos ~= -1 then
			local iAmount = self.m_SelectedBox.m_Amount
			if iAmount > 0 then
				self.m_SelectedBox:SetSelected(true)
				self:OnClickStallItem(self.m_SelectedBox)
			end
		end
	end
end
-------------------------UI刷新------------------------
function CEcononmyStallShoppingBox.InitCatalogGrid(self)
	self.m_ScrollView:ResetPosition()
	self.m_CatalogGrid:Clear()
	local list = DataTools.GetEcononmyStallCatalogList()
	local bHasTaskItem = g_EcononmyCtrl:HasTaskItem(define.Econonmy.Type.Stall)
	local oSelectedBox = nil
	for i,dInfo in ipairs(list) do
		local oBox = self:CreateCatalogBox(dInfo)
		self.m_CatalogGrid:AddChild(oBox)
		if bHasTaskItem and self.m_IsInit then 
			if dInfo.cat_id == g_EcononmyCtrl:GetTargetTaskCatalog(define.Econonmy.Type.Stall) then
				oSelectedBox = oBox
			end
		elseif g_EcononmyCtrl.m_StallLastCatalog and self.m_IsInit then
			if dInfo.cat_id == g_EcononmyCtrl.m_StallLastCatalog then
				oSelectedBox = oBox
			end
		elseif i == 1 then
			oSelectedBox = oBox
		end
	end
	if oSelectedBox then
		oSelectedBox:SetSelected(true)
		self:OnClickCatalog(oSelectedBox)
	end
end

function CEcononmyStallShoppingBox.CreateCatalogBox(self, dInfo)
	local oBox = self.m_CatalogBoxClone:Clone()
	oBox.m_CatalogId = dInfo.cat_id
	oBox.m_CatalogInfo = dInfo
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_TypeSpr = oBox:NewUI(2, CSprite)
	oBox.m_TaskSpr = oBox:NewUI(3, CSprite)
	oBox.m_SelNameL = oBox:NewUI(4, CLabel)

	oBox.m_NameL:SetText(dInfo.cat_name)
	oBox.m_SelNameL:SetText(dInfo.cat_name)
	-- oBox.m_TypeSpr:SetSpriteName("")
	oBox.m_TaskSpr:SetActive(g_EcononmyCtrl:IsTaskCatalog(define.Econonmy.Type.Stall, dInfo.cat_id))
	
	oBox:SetActive(true)
	oBox:AddUIEvent("click", callback(self, "OnClickCatalog", oBox))
	return oBox
end

function CEcononmyStallShoppingBox.RefreshTaskStatus(self)
	for i,oBox in ipairs(self.m_CatalogGrid:GetChildList()) do
		oBox.m_TaskSpr:SetActive(g_EcononmyCtrl:IsTaskCatalog(define.Econonmy.Type.Stall, oBox.m_CatalogId))
	end
	self:RefreshAll()
end

function CEcononmyStallShoppingBox.RefreshTime(self)
	if self.m_RefreshTimer then
		Utils.DelTimer(self.m_RefreshTimer)
		self.m_RefreshTimer = nil
	end
	local iLastTime = g_EcononmyCtrl:GetLastRefreshTime()
	if not iLastTime or iLastTime == 0 then
		self.m_RefreshTimeL:SetText("00:00")
		self.m_RefreshBtn:SetText("免费刷新")
		self.m_IsFreeRefresh = true
		return
	end
	local iNextRefreshTime = iLastTime + 300
	self.m_RefreshBtn:SetText(DataTools.GetGlobalData(107).value.."#cur_3 刷新")
	self.m_IsFreeRefresh = false
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		local iDiffTime = os.difftime(iNextRefreshTime, g_TimeCtrl:GetTimeS())
		if iDiffTime > 0 then
			iDiffTime = math.min(300, iDiffTime)
			self.m_RefreshTimeL:SetText(os.date("%M:%S", iDiffTime))
		else
			self.m_RefreshTimeL:SetText("00:00")
			self.m_RefreshBtn:SetText("免费刷新")
			self.m_IsFreeRefresh = true
			return false
		end
		return true
	end
	self.m_RefreshTimer = Utils.AddTimer(update, 1, 0)
end

function CEcononmyStallShoppingBox.RefreshStallItemGrid(self)
	self.m_ItemScrollView:ResetPosition()
	for i = 1, self.m_ItemLimit do
		local oBox = self.m_StallItemBoxs[i]
		if not oBox then
			oBox = self:CreateStallItemBox()
			self.m_StallItemGrid:AddChild(oBox)
			self.m_StallItemBoxs[i] = oBox
		end
		oBox:ForceSelected(false)
		oBox:SetActive(false)
	end
	local list = g_EcononmyCtrl:GetStallItemListByPage(self.m_CurPage)
	local bIsEmpty = list == nil or #list == 0
	self.m_WarningL:SetActive(bIsEmpty)
	if bIsEmpty then
		return
	end
	local bHasTaskItem = g_EcononmyCtrl:HasTaskItem(define.Econonmy.Type.Stall)
	local bIsInit = true
	for i,dInfo in ipairs(list) do
		local oBox = self.m_StallItemBoxs[i]
		self:UpdateStallItemBox(oBox, dInfo)
		self.m_StallItemGrid:AddChild(oBox)
		if bIsInit and oBox:GetActive() then
			if (bHasTaskItem and oBox.m_IsTargetTaskItem) or (self.m_TargetStallItem == dInfo.sid) then
				oBox:SetSelected(true)
				self:OnClickStallItem(oBox)
				bIsInit = false
			end
		end
	end
	self.m_StallItemGrid:Reposition()
end

function CEcononmyStallShoppingBox.CreateStallItemBox(self)
	local oBox = self.m_StallItemBoxClone:Clone()
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_PriceL = oBox:NewUI(2, CLabel)
	oBox.m_ItemIcon = oBox:NewUI(3, CButton)
	oBox.m_AmountL = oBox:NewUI(4, CLabel)
	oBox.m_StatusL = oBox:NewUI(5, CLabel)
	oBox.m_TreasureSpr = oBox:NewUI(6, CObject)
	oBox.m_TaskSpr = oBox:NewUI(7, CSprite)
	oBox.m_SelNameL = oBox:NewUI(8, CLabel)
	oBox.m_QualitySpr = oBox:NewUI(9, CSprite)

	oBox.m_ItemIcon:AddUIEvent("click", callback(self, "RequestItemDetail", oBox))
	oBox:AddUIEvent("click", callback(self, "OnClickStallItem", oBox))
	oBox:AddUIEvent("dragstart", callback(self, "OnScrollPageStart"))
	oBox:AddUIEvent("drag", callback(self, "OnScrollPage"))
	oBox:AddUIEvent("dragend", callback(self, "OnScrollPageEnd"))
	return oBox
end

function CEcononmyStallShoppingBox.UpdateStallItemBox(self, oBox, dInfo)
	if not next(dInfo) then
		return
	end
	local dItemInfo = DataTools.GetItemData(dInfo.sid)
	local iQuality = (self.m_CatalogId >= 3 and self.m_CatalogId <= 5) and 0 or dInfo.quality
	oBox:SetActive(dInfo.amount ~= 0)
	oBox.m_PosId = dInfo.pos_id
	oBox.dInfo = dInfo
	oBox.m_Amount = dInfo.amount
	oBox.m_IsTaskItem, oBox.m_IsTargetTaskItem = g_EcononmyCtrl:IsTaskItem(define.Econonmy.Type.Stall, dInfo.sid)
	oBox.m_NameL:SetText(dItemInfo.name)
	oBox.m_SelNameL:SetText(dItemInfo.name)
	oBox.m_PriceL:SetCommaNum(dInfo.price)
	oBox.m_ItemIcon:SpriteItemShape(dItemInfo.icon)
	oBox.m_AmountL:SetText(dInfo.amount)
	oBox.m_StatusL:SetActive(dInfo.amount == 0)
	oBox.m_TaskSpr:SetActive(oBox.m_IsTaskItem)
	oBox.m_QualitySpr:SetItemQuality(iQuality)
	--是否是珍品显示
	oBox.m_TreasureSpr:SetActive(false)
	-- oBox.m_TreasureSpr:SetActive(iQuality >= define.Item.Quality.Purple)
end

function CEcononmyStallShoppingBox.RefreshPage(self)
	local iPageCount = g_EcononmyCtrl:GetStallPageCount()
	local sPage = string.format("%d/%d页", self.m_CurPage, iPageCount)
	self.m_PageL:SetText(sPage)
end

function CEcononmyStallShoppingBox.RefreshAll(self)
	self.m_PosId = -1
	self.m_AmountBox:SetAmountRange(1, 1)
	self:RefreshTime()
	self:RefreshStallItemGrid()
	self:OnPageChange(0)
	self:RefreshPage()
end

--------------------点击事件监听或UI状态监听---------------
function CEcononmyStallShoppingBox.OnClickCatalog(self, oBox)
	self.m_PosId = -1

	local iCatalogId = oBox.m_CatalogId
	if iCatalogId == self.m_CatalogId and not g_EcononmyCtrl.m_TargetStallItem then
		return
	end
	self.m_CatalogId = iCatalogId
	self.m_CurPage = 1
	--TODO:向服务器请求商品信息
	local bIsFirst = self.m_IsInit and 1 or 0
	netstall.C2GSOpenCatalog(self.m_CatalogId, 1, bIsFirst, g_EcononmyCtrl.m_TargetStallItem)
	-- 避免每次请求都带物品id，置空处理
	if g_EcononmyCtrl.m_TargetStallItem then
		self.m_TargetCatalogId = self.m_CatalogId
		--选中效果使用		
		self.m_TargetStallItem = g_EcononmyCtrl.m_TargetStallItem
		g_EcononmyCtrl.m_TargetStallItem = nil
	end

	--记录最后一次操作的目录
	g_EcononmyCtrl.m_StallLastCatalog = iCatalogId
end

function CEcononmyStallShoppingBox.OnClickStallItem(self, oBox)
	if not oBox:GetActive() then
		return
	end
	self.m_SelectedBox = oBox
	self.m_PosId = oBox.m_PosId
	self.m_IsEmpty = not oBox.m_Amount or oBox.m_Amount == 0
	self.m_AmountBox:SetAmountRange(1, math.max(1, oBox.m_Amount))
	self.m_AmountBox:SetValue(1)
end

function CEcononmyStallShoppingBox.RequestItemDetail(self, oBox)
	local iPos = oBox.m_PosId
	netstall.C2GSSellItemDetail(self.m_CatalogId, iPos)
end

function CEcononmyStallShoppingBox.OnClickBuy(self)
	if self.m_PosId == -1 then
		g_NotifyCtrl:FloatMsg("请先选中你要购买的商品")
		return
	end
	if self.m_IsEmpty then
		g_NotifyCtrl:FloatMsg("物品已售罄")
		return
	end
	local iAmount = self.m_AmountBox:GetValue()
	if iAmount <= 0 then
		g_NotifyCtrl:FloatMsg("请调整购买数量")
		return
	end 
	self:JudgeLackList()
	if g_QuickGetCtrl.m_IsLackItem then
		return
	end
	netstall.C2GSBuySellItem(self.m_CatalogId, self.m_PosId, iAmount)
end

function CEcononmyStallShoppingBox.OnClickRefresh(self)
	local bIsGold = 0
	if not self.m_IsFreeRefresh then
		bIsGold = 1
		-- self:JudgeLackListRefresh()
		-- if g_QuickGetCtrl.m_IsLackItem then
		-- 	return
		-- end
	end
	netstall.C2GSRefreshCatalog(self.m_CatalogId, bIsGold)
	self.m_CurPage = 1
end

function CEcononmyStallShoppingBox.OnPageChange(self, iChangeValue)
	local iPageCount = g_EcononmyCtrl:GetStallPageCount()
	self.m_CurPage = (self.m_CurPage + iChangeValue)%(iPageCount + 1)
	self.m_CurPage = (self.m_CurPage == 0 and iChangeValue < 0 ) and iPageCount or math.max(1, self.m_CurPage)
	-- self.m_CurPage = math.min(self.m_CurPage, iPageCount)
	-- self.m_NextPageBtn:SetActive(self.m_CurPage < iPageCount)
	-- self.m_PrePageBtn:SetActive(self.m_CurPage > 1)

	if iChangeValue == 0 then
		return
	end
	local list = g_EcononmyCtrl:GetStallItemListByPage(self.m_CurPage)
	if not list then
		netstall.C2GSOpenCatalog(self.m_CatalogId, self.m_CurPage)
	else
		self:RefreshAll()
	end
end

function CEcononmyStallShoppingBox.OnScrollPageStart(self, obj)
	self.m_MoveY = 0
end

function CEcononmyStallShoppingBox.OnScrollPage(self, obj, moveDelta)
	local adjust = UITools.GetPixelSizeAdjustment()
	self.m_MoveY = self.m_MoveY + moveDelta.y*adjust
end

function CEcononmyStallShoppingBox.OnScrollPageEnd(self, obj)
	self.m_ScrollDir = 0
	if self.m_MoveY > 50 then
		self.m_ScrollDir = 1
	elseif self.m_MoveY < -50 then
		self.m_ScrollDir = -1
	end
	if self.m_ScrollDir == 0 then
		self.m_ScrollView:ResetPosition()
		return
	end
	self:OnPageChange(self.m_ScrollDir)
end

function CEcononmyStallShoppingBox.JumpToTargetCatalog(self, iCatalogId)
	for i,oBox in ipairs(self.m_CatalogGrid:GetChildList()) do
		if oBox.m_CatalogId == iCatalogId then
			oBox:SetSelected(true)
			self:OnClickCatalog(oBox)
		end
	end
end

function CEcononmyStallShoppingBox.JudgeLackList(self)
	if self.m_SelectedBox then
		local coinlist = {}
		if g_AttrCtrl.silver < self.m_SelectedBox.dInfo.price then
			local t = {sid = 1002, count =g_AttrCtrl.silver, amount =   self.m_SelectedBox.dInfo.price}
			table.insert(coinlist, t)
		end
		local iAmount = self.m_AmountBox:GetValue()

		g_QuickGetCtrl:CurrLackItemInfo({}, coinlist, nil, function ()
			-- body
			netstall.C2GSBuySellItem(self.m_CatalogId, self.m_PosId, iAmount)
		end)
	end
end

return CEcononmyStallShoppingBox
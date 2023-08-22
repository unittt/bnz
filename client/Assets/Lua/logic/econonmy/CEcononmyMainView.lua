local CEcononmyMainView = class("CEcononmyMainView", CViewBase)

function CEcononmyMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Econonmy/EcononmyMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CEcononmyMainView.ShowView(cls, cb)
	g_EcononmyCtrl:ShowView(cls, cb)
end

function CEcononmyMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CTabGrid)
	self.m_GuildPart = self:NewPage(3, CEcononmyGuildPart)
	self.m_StallPart = self:NewPage(4, CEcononmyStallPart)
	self.m_AuctionPart = self:NewPage(5, CEcononmyAuctionPart)
	self.m_StallRedPoint = self:NewUI(6, CSprite)
	self.m_AuctionRedPoint = self:NewUI(7, CSprite)

	self.m_BtnGrid:SetHideinactive(true)

	self.m_IsInit = true
	self.m_CurTabIndex = 0

	-- 注释的 self.m_PartList 等同 self.m_PageList（CGameObjContainer）
	-- self.m_PartList = {
	-- 	[1] = self.m_GuildPart,
	-- 	[2] = self.m_StallPart,
	-- 	[3] = self.m_AuctionPart,
	-- }
	self:InitContent()
end

function CEcononmyMainView.InitContent(self)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_EcononmyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEcononmyEvent"))

	g_EcononmyCtrl:InitTaskItemList()
	self.m_BtnGrid:InitChild(function(obj, idx)
		local oTab = CButton.New(obj)
		oTab:SetGroup(self:GetInstanceID())
		return oTab
	end)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	
	local list = self.m_BtnGrid:GetChildList()
	for i,oTab in ipairs(list) do
		if i == 1 then
			oTab:SetSelected(true)
		end
		oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i))

		local openState = g_EcononmyCtrl:IsSpecityTabOpen(i)
		oTab:SetActive(openState)
	end

	-- local defaultIndex = g_EcononmyCtrl:GetDefaultTabIndex()
	-- if defaultIndex then
	-- 	self:ShowSubPageByIndex(defaultIndex)
	-- end
	self:RefreshStallRedPoint()
	self:RefreshAuctionRedPoint()
end

function CEcononmyMainView.LoadDone(self)
	if self.m_IsInit then
		--因为协议锁限制无法连续发送同一类型协议，改成如果loadcb有触发UI初始化，则放弃默认UI初始化
		local openState = g_EcononmyCtrl:IsSpecityTabOpen(define.Econonmy.Type.Guild)
		if openState then
			self:ShowSubPageByIndex(define.Econonmy.Type.Guild)
			self.m_GuildPart:LoadDone()
		else
			local defaultIndex = g_EcononmyCtrl:GetDefaultTabIndex()
			if defaultIndex then
				self:ShowSubPageByIndex(defaultIndex)
			end
		end
	end
	CViewBase.LoadDone(self)
end

function CEcononmyMainView.OnCtrlItemEvent(self, oCtrl)
	if not g_EcononmyCtrl.m_TargetTaskId then
		return
	end
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount then
		local oTask = CTaskHelp.GetClickTaskShopSelect()
		if not oTask then
			return
		end
		local taskNeedList = g_TaskCtrl:GetTaskNeedItemList(oTask, true)
		if (not taskNeedList or not next(taskNeedList)) then
			if g_TaskCtrl.m_OpenShopForTaskSessionidx then
				g_TaskCtrl:SendOpenShopForTaskSessionidx()
			elseif g_YibaoCtrl.m_OpenShopForHelpOtherYibaoCb then
				g_YibaoCtrl.m_OpenShopForHelpOtherYibaoCb()
			else
				CTaskHelp.ClickTaskLogic(CTaskHelp.GetClickTaskShopSelect())
			end
			self:OnClose()
		end
	end
end

function CEcononmyMainView.OnCtrlEcononmyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Econonmy.Event.RefreshStallNotify then
		self:RefreshStallRedPoint()
	elseif oCtrl.m_EventID == define.Econonmy.Event.RefreshAuctionNotify then
		self:RefreshAuctionRedPoint()
	end
end

function CEcononmyMainView.RefreshStallRedPoint(self)
	self.m_StallRedPoint:SetActive(g_EcononmyCtrl.m_StallNotify)
	self.m_StallPart:RefreshRedPoint(g_EcononmyCtrl.m_StallNotify)
end

function CEcononmyMainView.RefreshAuctionRedPoint(self)
	local bActive = g_SysUIEffCtrl:IsExistRecord("AUCTION") or g_EcononmyCtrl.m_AuctionNotify
	self.m_AuctionRedPoint:SetActive(bActive)
end

function CEcononmyMainView.JumpToTargetItem(self, iItemid)
	iItemid = DataTools.GetPartnerCellItem(iItemid) or iItemid
	local iType, iCatalogId, iSubCatalogId = DataTools.GetEcononmyCatalogByItem(iItemid)
	if iType == define.Econonmy.Type.Stall then
		g_EcononmyCtrl.m_TargetStallItem = iItemid
		self.m_StallPart.m_ShoppingBox:JumpToTargetCatalog(iCatalogId)
	elseif iType == define.Econonmy.Type.Guild then
		local iCurCatId, iCurSubCatId = self.m_GuildPart:GetCurrentCatalog()
		if iCurCatId ~= iCatalogId or iCurSubCatId ~= iSubCatalogId then
			self.m_GuildPart:JumpToTargetCatalog(iCatalogId, iSubCatalogId)
		end
		g_EcononmyCtrl.m_TargetGuildItem = iItemid
	elseif iType == define.Econonmy.Type.Auction then

	end
end

function CEcononmyMainView.ShowSubPageByIndex(self, iTab)
	if self.m_CurTabIndex == iTab then
		return
	end
	if not g_EcononmyCtrl:IsSpecityTabOpen(iTab) then
		return
	end

	self.m_IsInit = false
	if iTab == define.Econonmy.Type.Guild and not g_OpenSysCtrl:GetOpenSysState(define.System.Guild, true) then
		self.m_BtnGrid:GetChild(define.Econonmy.Type.Stall):SetSelected(true)
		return
	end
	if iTab == define.Econonmy.Type.Auction then
		if not g_OpenSysCtrl:GetOpenSysState(define.System.Auction, true) then
			self.m_BtnGrid:GetChild(define.Econonmy.Type.Stall):SetSelected(true)
			return
		else
			g_SysUIEffCtrl:DelSysEff("TRADE_S")
			self.m_AuctionRedPoint:SetActive(false)
		end
	end
	self.m_BtnGrid:GetChild(iTab):SetSelected(true)
	CGameObjContainer.ShowSubPageByIndex(self, iTab)
	if iTab == 1 and self.m_CurTabIndex > 1 and not self.m_GuildPart.m_IsLoadDone then
		self.m_GuildPart:LoadDone()
	end
	self.m_CurTabIndex = iTab
end

function CEcononmyMainView.GetCurrentTab(self)
	return self.m_CurPage
end

function CEcononmyMainView.CloseView(self)
	g_EcononmyCtrl:ClearTaskItemList()
	g_EcononmyCtrl:ClearTargetItem()
	g_EcononmyCtrl:C2GSCloseAuctionUI()
	CViewBase.CloseView(self)
end

function CEcononmyMainView.OnHideView(self)
    g_TaskCtrl.m_HelpOtherTaskData = {}
end

function CEcononmyMainView.OnClose(self)
	CTaskHelp.SetClickTaskShopSelect(nil)
	g_TaskCtrl.m_HelpOtherTaskData = {}
    g_TaskCtrl.m_OpenShopForTaskSessionidx = nil
    g_YibaoCtrl.m_OpenShopForHelpOtherYibaoCb = nil
    g_EcononmyCtrl:ClearTaskItemList()
	self:CloseView()
end

return CEcononmyMainView
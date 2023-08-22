local CItemBagBox = class("CItemBagBox", CBox)

function CItemBagBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_BagItemBoxScly = self:NewUI(1, CScrollView)
	self.m_TabBtnGrid = self:NewUI(2, CTabGrid)
	self.m_ItemCellGrid = self:NewUI(3, CGrid)
	self.m_ItemBoxClone = self:NewUI(4, CItemBox)
	self.m_MarketStallBtn = self:NewUI(5, CButton)
	self.m_BagArrangeBtn = self:NewUI(6, CButton)
	
	self.m_DefaultBagBoxTab = 1
	self.m_CurTabType = nil
	self.m_CurrClickItem = nil
	self.m_CurrClickBox = nil
	self:InitContent()
	self:ShowSpecificType()
end

function CItemBagBox.InitContent(self)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	self.m_MarketStallBtn:AddUIEvent("click", callback(self, "OnMarketStallBtn"))
	self.m_BagArrangeBtn:AddUIEvent("click", callback(self, "OnBagArrangeBtn"))
	self.m_BagArrangeBtn:SetClickSounPath(define.Audio.SoundPath.Tab)

	self.m_ItemBoxClone:SetActive(false)
	self:InitGridBox()

	-- 分页按钮
	local tableTypeList = {g_ItemCtrl.m_BagTypeEnum.all, g_ItemCtrl.m_BagTypeEnum.equip, g_ItemCtrl.m_BagTypeEnum.consume}
	self.m_PartInfoTable = {}
	local groupid = self.m_TabBtnGrid:GetInstanceID()
	local function init(obj, idx)
		local oBtn = CButton.New(obj, false, false)
		oBtn:SetGroup(groupid)
		oBtn:SetClickSounPath(define.Audio.SoundPath.Tab)
		if idx == 1 then
			g_AudioCtrl:SetRecordInfo(groupid, oBtn:GetInstanceID())
		end

		local info = {tabType = tableTypeList[idx], tabBtn = oBtn}
		table.insert(self.m_PartInfoTable, info)
		oBtn:AddUIEvent("click", callback(self, "OnTabBtn", idx))
		return oBtn
	end
	self.m_TabBtnGrid:InitChild(init)
end

function CItemBagBox.InitGridBox(self)
	local iOpenCnt = g_ItemCtrl:GetBagOpenCount()
	local iLockCnt = g_ItemCtrl:GetBagLockCount()
	local gridChildList = self.m_ItemCellGrid:GetChildList()

	for i = 1, iOpenCnt+iLockCnt do
		local oItemBox = nil
		if i > #gridChildList then
			oItemBox = self.m_ItemBoxClone:Clone(define.Item.CellType.BagCell)
			self.m_ItemCellGrid:AddChild(oItemBox)
			oItemBox:SetGroup(99999)
		else
			oItemBox = gridChildList[i]
		end

		oItemBox:SetActive(true)
		local isLock = i > iOpenCnt
		oItemBox:SetLock(isLock, i)
		oItemBox:ShowEquipLevel(true)
		oItemBox:ShowWenShiLevel(true)
		
		if isLock then
			oItemBox:SetBagItem(nil)
		else
			if not oItemBox.m_Item then
				oItemBox:SetEnableTouch(false)
			end
		end
	end
end

function CItemBagBox.ShowSpecificType(self, tabIndex)
	tabIndex = tabIndex or self.m_DefaultBagBoxTab
	self.m_DefaultBagBoxTab = tabIndex
	self:OnTabBtn(tabIndex)

	local itemPos = g_ItemCtrl:GetTopOfTheRedList()
	if itemPos then
		if itemPos <= 10 then
			itemPos = 1
		elseif itemPos > g_ItemCtrl.m_BagAllCount - 20 then
			itemPos = g_ItemCtrl.m_BagAllCount - 20
		else
			itemPos = itemPos - 10
		end

		Utils.AddTimer(function ()
			local oItemBox = self.m_ItemCellGrid:GetChild(itemPos)
			self.m_BagItemBoxScly:Move2Obj(oItemBox)
		end, 0, 0)
	end
end

function CItemBagBox.OnTabBtn(self, idx)
	local args = self.m_PartInfoTable[idx]
	if self.m_CurTabType == args.tabType then
		return
	end
	if self.m_CurTabType == g_ItemCtrl.m_BagTypeEnum.all then
		if args.tabType ~= g_ItemCtrl.m_BagTypeEnum.all then
			g_ItemCtrl.m_BagSclyRelative = self.m_BagItemBoxScly:GetLocalPos()-- + Vector3.New(0, 5, 0)
		end
	end
	args.tabBtn:SetSelected(true)  --修改点击label颜色
	self.m_CurTabType = args.tabType
	self.m_BagItemBoxScly:ResetPosition()
	if args.tabType == g_ItemCtrl.m_BagTypeEnum.all then
		--self:SetBagSclyRelative()
	end
	self.m_BagItemBoxScly:ResetPosition()
	self:RefreshGrid(function (oBox, oItem)
		oBox:SetBagItem(oItem)
	end)
	g_ItemCtrl:OnEvent(define.Item.Event.TabSwitch)
end

function CItemBagBox.SetBagSclyRelative(self)
	if g_ItemCtrl.m_BagSclyRelative then
		self.m_BagItemBoxScly:MoveRelative(g_ItemCtrl.m_BagSclyRelative)
	end
end

function CItemBagBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		local oItem = oCtrl.m_EventData
		local itemPos  

		if self.m_CurTabType == g_ItemCtrl.m_BagTypeEnum.all then
			itemPos  = oItem:GetSValueByKey("pos")

		elseif self.m_CurTabType == g_ItemCtrl.m_BagTypeEnum.consume then
			local list = self.m_ItemCellGrid:GetChildList()
			local itemlist ={}
			for i=1,#list do
				local box = list[i]
				local item = box:GetBagItem()
				if item and oItem.m_ID == item.m_ID then
					itemPos = 100 + i
					itemlist[i] = item
				end
			end
		end
		if not itemPos then
			printerror("error: 无效位置",oItem.m_ID)
			return
		end
		local bagBoxIdx = itemPos
		if bagBoxIdx > 100 then
			bagBoxIdx = bagBoxIdx - define.Item.Constant.BagItemHand
		end
		local oBox = self.m_ItemCellGrid:GetChild(bagBoxIdx)
		if oBox then
			oBox:SetBagItem(oItem)
		end
	elseif oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		self:RefreshGrid(function (oBox, oItem)
			oBox:SetBagItem(oItem)
		end)
	elseif oCtrl.m_EventID == define.Item.Event.RefreshBagBox then
		self:InitGridBox()
	elseif oCtrl.m_EventID == define.Item.Event.CheckBagRedDot then
		self:RefreshGrid(function (oBox)
			oBox:SetRed(false)
		end)
	end
end

function CItemBagBox.RefreshGrid(self, func)
	local itemList = g_ItemCtrl:GetBagItemListByType(self.m_CurTabType)
	local gridChildList = self.m_ItemCellGrid:GetChildList()	

	local DeleteItemSign = true 
	if self.m_CurTabType == g_ItemCtrl.m_BagTypeEnum.all then
		local lIgnoreList = {}
		for i,v in pairs(itemList) do
			local oItem = itemList[i]
			local itemPos = oItem:GetSValueByKey("pos")
			local bagBoxIdx = itemPos
			if bagBoxIdx > 100 then
				bagBoxIdx = bagBoxIdx - define.Item.Constant.BagItemHand
			end
			local oBox = gridChildList[bagBoxIdx]
			if func then
				func(oBox, oItem)
			end
			if g_ItemCtrl.m_CurrClickItem then
				if g_ItemCtrl.m_CurrClickItem:GetSValueByKey("id") == oItem:GetSValueByKey("id") then
					DeleteItemSign = false
					g_ItemCtrl.m_CurrClickItem = oItem
					g_ItemCtrl.m_CurrClickBox = oBox
					g_ItemCtrl.m_CurrClickBox:ForceSelected(true)
				end
			end
			table.insert(lIgnoreList, bagBoxIdx)
		end
		
		for i, oBox in ipairs(gridChildList) do
			local ignore = false
			for _,v in ipairs(lIgnoreList) do
				if i == v then
					ignore = true
					break
				end
			end

			if not ignore then
				if func then
					func(oBox)
				end
			end
		end
	else
		-- 排序
		table.sort(itemList, function (a, b)
			local aPos = a:GetSValueByKey("pos")
			local bPos = b:GetSValueByKey("pos")
			return aPos < bPos
		end)
		local sign = false
		for i, oBox in ipairs(gridChildList) do
			local oItem = itemList[i]
			if func then
				func(oBox, oItem)
			end
			if g_ItemCtrl.m_CurrClickItem then
				if oItem and g_ItemCtrl.m_CurrClickItem:GetSValueByKey("id") == oItem:GetSValueByKey("id") then
					DeleteItemSign = false
					oBox:ForceSelected(true)
				end
			end
		end
	end
	if DeleteItemSign and g_ItemCtrl.m_CurrClickBox and g_ItemCtrl.m_CurrClickItem then
		g_ItemCtrl.m_CurrClickBox:ForceSelected(false)
		g_ItemCtrl.m_CurrClickBox = nil
		g_ItemCtrl.m_CurrClickItem = nil
	end
end

function CItemBagBox.OnBagArrangeBtn(self)
    if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.BagItemArrange, self:GetInstanceID()) then
        local ss = self.m_OnBagArragreTime - g_TimeCtrl:GetTimeS()
        if ss <= 1 then
        	ss = 1
        end
        g_NotifyCtrl:FloatMsg(string.gsub(DataTools.GetMiscText(2003).content, "#SS", ss))
        return
    end
    g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.BagItemArrange, self:GetInstanceID(), define.Item.Constant.ArrangeCD)
    self.m_OnBagArragreTime = g_TimeCtrl:GetTimeS() + define.Item.Constant.ArrangeCD

	g_ItemCtrl:ItemArrage()
end

function CItemBagBox.OnMarketStallBtn(self)
	-- 未选中物品||不可摆摊的物品时不显示该按钮
	--printc("TODO >>> 打开摆摊界面")
	local econonmyDefaultTabIndex = g_EcononmyCtrl:GetDefaultTabIndex()
	if not econonmyDefaultTabIndex then
		return
	end

	local stallOpen = g_EcononmyCtrl:IsSpecityTabOpen(define.Econonmy.Type.Stall)
	if not stallOpen then
		g_NotifyCtrl:FloatMsg("摆摊系统暂时关闭,敬请期待")
		return
	end
	CEcononmyMainView:ShowView(function(view) 
		view:ShowSubPageByIndex(define.Econonmy.Type.Stall)
		view.m_StallPart:ChangeTab(2)
	end)
end

return CItemBagBox
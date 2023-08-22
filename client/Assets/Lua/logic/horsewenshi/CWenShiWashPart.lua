local CWenShiWashPart = class("CWenShiWashPart", CPageBase)

function CWenShiWashPart.ctor(self, obj)

	CPageBase.ctor(self, obj)
	self.m_SelId = nil
	self.m_LockIndexList = {}


end

function CWenShiWashPart.OnInitPage(self)

	self.m_WenShiItemGrid = self:NewUI(1, CGrid)
	self.m_WenShiItem = self:NewUI(2, CBox)
	self.m_Icon = self:NewUI(3, CSprite)
	self.m_Name = self:NewUI(4, CLabel)
	self.m_ConsumeIcon = self:NewUI(5, CSprite)
	self.m_ConsumeAmount = self:NewUI(6, CLabel)
	--self.m_AutoBuy = self:NewUI(7, CSprite)
	self.m_AttrGrid = self:NewUI(8, CGrid)
	self.m_AttrItem = self:NewUI(9, CWenShiAttrItem)
	self.m_WashBtn = self:NewUI(10, CSprite)
	self.m_TipBtn = self:NewUI(11, CSprite)
	self.m_QuickBuyBox = self:NewUI(12, CQuickBuyBox)
	self.m_Tip = self:NewUI(13, CLabel)
	self.m_ScrollView = self:NewUI(14, CScrollView)
	self.m_ScrollViewAttr = self:NewUI(15, CScrollView)
	self.m_ConsumeCount = self:NewUI(16, CLabel)

	 self:InitContent()

end

function CWenShiWashPart.InitContent(self)

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRefreshItem"))
	self.m_ConsumeIcon:AddUIEvent("click", callback(self, "OnClickConsume"))
	self.m_WashBtn:AddUIEvent("click", callback(self, "OnClickWashBtn"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTipBtn"))
	self:RefreshWenShiItemList()
	self:ForceSelectFirstWenShi()
	self:RefreshTip()

end

function CWenShiWashPart.OnShowPage(self)
	
	self:RefreshWenShiItemList()
	self:ForceSelectFirstWenShi()

end

function CWenShiWashPart.ForceSelectFirstWenShi(self)
	
	local firstItem =  self.m_WenShiItemGrid:GetChild(1)
	if firstItem then 
		firstItem.box:ForceSelected(true)
		self:OnClickWenShiItem(firstItem)
	end 

end

function CWenShiWashPart.RefreshQuickBuy(self)
	
	local lv = self.m_CurIWenShiInfo.lv
	local config = self.m_CurIWenShiInfo.config
	local wenshiType = config.wenshi_type
	local consume = g_WenShiCtrl:GetWenShiWashConsume(wenshiType, lv)
	local hadCount = g_ItemCtrl:GetBagItemAmountBySid(consume.id)
	local needCount = consume.cnt

	self.m_QuickBuyBox:SetInfo({
	    id = define.QuickBuy.WenShiWash,
	    name = "便捷购买",
	   -- offset = Vector3(-30,0,0),
	    items = {{id = consume.id, cnt = needCount}},
	})


end

function CWenShiWashPart.OnRefreshItem(self, oCtrl)
	
	if oCtrl.m_EventID == define.Item.Event.AddItem then
		if self:GetActive() then 		 
			local oItem = oCtrl.m_EventData
			local isWenShiItem = g_ItemCtrl:IsWenShiItem(oItem.m_ID)
			if isWenShiItem then 
				self.m_CurIWenShiInfo.attrList = oItem.m_SData.equip_info.attach_attr
				self:RefreshAll()
			end 
		end 
	end

end

function CWenShiWashPart.RefreshTip(self)
	
	local wenshiDataList = g_ItemCtrl:GetBagWenShiData()
	self.m_Tip:SetActive(not next(wenshiDataList))

end

--刷新纹饰列表
function CWenShiWashPart.RefreshWenShiItemList(self)
	
	--获取背包中的纹饰数据
	local wenshiDataList = g_ItemCtrl:GetBagWenShiData()

	local sortList = {}
	for k, v in pairs(wenshiDataList) do 
		table.insert(sortList, v)
	end

	table.sort(sortList, function (a, b)
		local lvA = a.m_SData.equip_info.grow_level
		local lvB = b.m_SData.equip_info.grow_level
		local configA = data.itemwenshidata.WENSHI[a.m_SID]
		local configB = data.itemwenshidata.WENSHI[b.m_SID]
		if not configA or not configB then 
			return
		end 

		if configA.wenshi_type < configB.wenshi_type then 
			return true	
		elseif  configA.wenshi_type == configB.wenshi_type  then 
			if lvA > lvB then 
				return true
			else
				return false
			end 
		else
			return false
		end 

	end)

	local index = 1
	for _, wenshiData in pairs(sortList) do
		local item = self.m_WenShiItemGrid:GetChild(index)
		index = index + 1
		if not item then 
			item = self.m_WenShiItem:Clone()
			item:SetActive(true)
			self.m_WenShiItemGrid:AddChild(item)
		end

		item:SetActive(true)
		item.icon = item:NewUI(1, CSprite)
		item.lv = item:NewUI(2, CLabel)
		item.box = item:NewUI(3, CWidget)
		item.box:AddUIEvent("click", callback(self, "OnClickWenShiItem", item))

		local sid = wenshiData.m_SID 
		local id = wenshiData.m_ID
		local wenshiConfigItem = data.itemwenshidata.WENSHI[sid] 
	    local name = wenshiConfigItem.name
	    local lv = wenshiData.m_SData.equip_info.grow_level
	    if wenshiConfigItem then 
	        item.icon:SpriteItemShape(wenshiConfigItem.icon)
	    end 
	    item.lv:SetText(lv .. "级")
	    local attrList = wenshiData.m_SData.equip_info.attach_attr
	    item.info = {id = id, lv = lv, attrList = attrList, config = wenshiConfigItem}

	end

end

function CWenShiWashPart.ForceSelectWenShiItem(self, id)
		
	if not id then 
		return
	end 

	local itemList = self.m_WenShiItemGrid:GetChildList()
	if itemList then 
		for k, item in pairs(itemList) do 
			if item.info.id == id then 
				self.m_CurSelItem = item
				self:OnClickWenShiItem(item)
				item.box:ForceSelected(true)
				self:AdjustWenShiItemPos()
				break
			end 
		end 
	end 

end

function CWenShiWashPart.AdjustWenShiItemPos(self)
	
	local fun = function ()
		if self.m_CurSelItem then
			UITools.MoveToTarget(self.m_ScrollView, self.m_CurSelItem)
			self.m_ScrollView:RestrictWithinBounds(true)
		end 
	end

	Utils.AddTimer(fun, 0, 0)

end

function CWenShiWashPart.OnClickWenShiItem(self, item)

	self.m_CurSelItem = item
	self.m_CurIWenShiInfo = item.info
	self.m_LockIndexList = {}
	self:ClearAttrState()
	self:RefreshAll()

end

function CWenShiWashPart.RefreshAll(self)
	
	self:RefreshWenShiItemList()
	self:RefreshWenShiItem()
	self:RefreshConsume()
	self:RefreshAttr()
	self:RefreshQuickBuy()
	self:RefreshTip()

end

--刷新纹饰
function CWenShiWashPart.RefreshWenShiItem(self)
	
	local config = self.m_CurIWenShiInfo.config
	self.m_Icon:SpriteItemShape(config.icon)
	self.m_Icon:SetActive(true)
	self.m_Name:SetText("[1D8E00FF]" .. tostring(self.m_CurIWenShiInfo.lv) .. "级[-] [244B4EFF]" .. config.name .. "[-]")
	self.m_Name:SetActive(true)

end

--刷新消耗
function CWenShiWashPart.RefreshConsume(self)
	
	local lv = self.m_CurIWenShiInfo.lv
	local config = self.m_CurIWenShiInfo.config
	local wenshiType = config.wenshi_type
	local consume = g_WenShiCtrl:GetWenShiWashConsume(wenshiType, lv)
	local hadCount = g_ItemCtrl:GetBagItemAmountBySid(consume.id)
	consume.hadCount = hadCount
	self.m_Consume = consume
	if consume and next(consume) then 
		self.m_ConsumeIcon:SpriteItemShape(consume.icon)
		self.m_ConsumeIcon:SetActive(true)
		if hadCount < consume.cnt then 
			self.m_ConsumeCount:SetText("[ffb398]".. hadCount)
			self.m_ConsumeCount:SetEffectColor(Color.RGBAToColor("cd0000"))
		else
			self.m_ConsumeCount:SetText("[0fff32]".. hadCount)
			self.m_ConsumeCount:SetEffectColor(Color.RGBAToColor("003C41"))
		end
		self.m_ConsumeAmount:SetText("/"..consume.cnt)
		self.m_ConsumeCount:SetActive(true) 
	end 

end

function CWenShiWashPart.ClearAttrState(self)
	
	local childList = self.m_AttrGrid:GetChildList()
	for k, attrItem in ipairs(childList) do 
		attrItem:ClearState()
	end 

end

--刷新attr
function CWenShiWashPart.RefreshAttr(self)

	self.m_AttrGrid:HideAllChilds()

	local lv = self.m_CurIWenShiInfo.lv
	local attrList = self.m_CurIWenShiInfo.attrList
	for k, v in ipairs(attrList) do 
		local attrItem = self.m_AttrGrid:GetChild(k)
		if not attrItem then
			attrItem = self.m_AttrItem:Clone()
			attrItem:SetActive(true)
			self.m_AttrGrid:AddChild(attrItem)
		end 
		attrItem:SetActive(true)
		local id = v.key
		local attrNameConfig = data.attrnamedata.DATA
		local gradeConfig = data.itemwenshidata.GRADE_CONFIG
		local gradeInfo = gradeConfig[lv]
		local info = attrNameConfig[id]
		if info and gradeInfo then 
			local data = {}
			data.attrName = info.name
			data.attrValue = v.value / 100
			if g_AttrCtrl:IsRatioAttr(k) then 
				data.attrValue = data.attrValue .. "%"
			end 
			data.index = k
			data.count = gradeInfo.wash_lock_cost
			attrItem:SetData(data, callback(self, "OnClickAttr"))
		end 
	end

	self.m_ScrollViewAttr:ResetPosition()

end

function CWenShiWashPart.OnClickAttr(self, data)
	
	local index = data.index

	if not self.m_LockIndexList[index] then 
		self.m_LockIndexList[index] = true
	else
		self.m_LockIndexList[index] = nil
	end 

end

function CWenShiWashPart.CheckCostEnough(self)
	
	if self.m_QuickBuyBox:IsSelected() then
        return self.m_QuickBuyBox:CheckCostEnough()
    end 

end

function CWenShiWashPart.GetLockAttrCost(self)
	
	local totalCount = 0
	local childList = self.m_AttrGrid:GetChildList()

	if (not childList) or (not next(childList)) then 
		return totalCount
	end

	for k, attrItem in ipairs(childList) do 
		local data = attrItem:GetData()
		local index = data.index
		if self.m_LockIndexList[index] then
			totalCount = totalCount + data.count
		end 
	end 

	return totalCount

end

function CWenShiWashPart.IsLockArrtCostEnough(self)
	
	local totalCount = self:GetLockAttrCost()
	local hadCount = g_AttrCtrl:GetGoldCoin()
	if totalCount > hadCount then 
		g_NotifyCtrl:FloatMsg("元宝不足")
		g_ShopCtrl:ShowChargeView()		
		-- CNpcShopMainView:ShowView(function(oView) oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) end) 
		return 
	else
		return true
	end 

end

function CWenShiWashPart.WashWenShi(self, fast)

	fast = fast or 0
	local id = self.m_CurIWenShiInfo.id
	local indexList = {}
	for k, v in pairs(self.m_LockIndexList) do 
		table.insert(indexList, k)
	end 

	if id then 
		g_WenShiCtrl:C2GSWenShiWash(id, indexList, fast)
	end 

end

function CWenShiWashPart.OnClickWashBtn(self)

	local wenshiDataList = g_ItemCtrl:GetBagWenShiData()
	if not next(wenshiDataList) then 
		g_NotifyCtrl:FloatMsg("没有可洗炼的纹饰")
		return
	end 

	local isQuickBuy = self.m_QuickBuyBox:IsSelected()
	if isQuickBuy then 
		local lockCostCount = self:GetLockAttrCost()
		local fastCount = self.m_QuickBuyBox:GetTotalGoldCoinCost()
		local hadGoldCoin = g_AttrCtrl:GetGoldCoin()
		if fastCount then 
			if (lockCostCount + fastCount) <= hadGoldCoin  then 
				self:WashWenShi(1)
			else
				g_NotifyCtrl:FloatMsg("元宝不足")
			end  
		end 
	else
		if self.m_Consume then 
			local hadCount = self.m_Consume.hadCount
			local needCount = self.m_Consume.cnt
			local name = self.m_Consume.name
			if hadCount < needCount then 
				g_NotifyCtrl:FloatMsg(name .. "不足")
			else
				if self:IsLockArrtCostEnough() then 
					self:WashWenShi()
				end 	
			end 
		end 
	end 

end

function CWenShiWashPart.OnClickTipBtn(self)
	
	local desInfo = data.instructiondata.DESC[10063]
	if desInfo then 
		local zContent = {title = desInfo.title, desc = desInfo.desc}
		g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	end 

end

function CWenShiWashPart.OnClickConsume(self)
	
	local id = self.m_Consume.id
	local config = DataTools.GetItemData(id, "OTHER")
	g_WindowTipCtrl:SetWindowGainItemTip(id)

end


return CWenShiWashPart
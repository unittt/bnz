local CItemDecomposeResultBox = class("CItemDecomposeResultBox", CBox)

function CItemDecomposeResultBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_DecomposeGrid = self:NewUI(1, CGrid)
	self.m_DecomposeClone = self:NewUI(2, CItemBaseBox)
	self.m_RewardItemGrid = self:NewUI(3, CGrid)
	self.m_RewardItemClone = self:NewUI(4, CItemBaseBox) 
	self.m_SilverL = self:NewUI(5, CLabel)
	self.m_DecomposeBtn = self:NewUI(6, CButton)
	self.m_EquipCntL = self:NewUI(7, CLabel)
	self.m_CostBox = self:NewUI(8, CCurrencyBox)
	self.m_ScrollView = self:NewUI(9, CScrollView)

	self.m_RewardItemBoxs = {}
	self.m_DecomposeDict = {}
	self.m_DecomposeList = {}
	self.m_DecomposeBoxs = {}
	self.m_MaxDecompose = 5
	self:InitContent()
end

function CItemDecomposeResultBox.InitContent(self)
	self.m_CostBox:SetCurrencyType(define.Currency.Type.Silver, true)
	self.m_DecomposeClone:SetActive(false)
	self.m_RewardItemClone:SetActive(false)
	self.m_SilverL:SetActive(false)
	self.m_DecomposeBtn:AddUIEvent("click", callback(self, "OnClickDecompose"))
end

function CItemDecomposeResultBox.AddDecomposeItem(self, cItem)
	if #self.m_DecomposeList >= self.m_MaxDecompose then
		return false
	end
	table.insert(self.m_DecomposeList, {item = cItem, amount = 1, maxOverlay = cItem:GetCValueByKey("maxOverlay")})
	self:RefreshAll()
	return true
end

function CItemDecomposeResultBox.DelDecomposeItem(self, iItemId, bIsDel)
	local iIndex = self.m_DecomposeDict[iItemId]
	local dItem = self.m_DecomposeList[iIndex]
	local bIsUpdate = not bIsDel	

	if bIsUpdate and dItem ~= nil then
		local iAmountChange = g_ItemCtrl.m_BagItems[iItemId].m_AmountChange
		if -iAmountChange ~= dItem.amount then
			return
		end
	end
	if not iIndex then
		return
	end

	table.remove(self.m_DecomposeList, iIndex)
	self.m_DecomposeDict[iItemId] = nil
	self:UpdateBagItemBoxByItem(iItemId)
	self:RefreshAll()
end

function CItemDecomposeResultBox.UpdateDecomposeItem(self, iItemId, iAmount)
	for i,dItem in ipairs(self.m_DecomposeList) do
		if dItem.item.m_ID == iItemId then
			dItem.amount = iAmount
			self:RefreshAll()
			break
		end
	end
end

-- function CItemDecomposeResultBox.ShowTipView(self)
-- 	local id = define.Instruction.Config.DeCompose
--     local content = {
--         title = data.instructiondata.DESC[id].title,
--         desc  = data.instructiondata.DESC[id].desc
--     }
--     g_WindowTipCtrl:SetWindowInstructionInfo(content)
-- end

function CItemDecomposeResultBox.RefreshAll(self)
	self:RefreshDecomposeItemGrid()
	self:RefreshRewardItemGrid()
	self:RefreshEquipCount()
end

function CItemDecomposeResultBox.RefreshEquipCount(self)
	self.m_EquipCntL:SetText(#self.m_DecomposeList.."/5")
end

function CItemDecomposeResultBox.RefreshDecomposeItemGrid(self)
	for i,oBox in ipairs(self.m_DecomposeBoxs) do
		if oBox then
			oBox:SetActive(false)
			oBox:DelEffect("Rect")
		end
	end
	for i,dItem in ipairs(self.m_DecomposeList) do
		local oBox = self.m_DecomposeBoxs[i]
		if not oBox then
			oBox = self:CreateDecomposeBox(dItem)
			self.m_DecomposeBoxs[i] = oBox
		else
			oBox:SetBagItem(dItem.item)
			oBox:SetAmountText(dItem.amount, dItem.maxOverlay)
		end
		oBox:SetActive(true)
		self.m_DecomposeDict[dItem.item.m_ID] = i
	end
	self.m_DecomposeGrid:Reposition()
end

function CItemDecomposeResultBox.CreateDecomposeBox(self, dItem)
	local oBox = self.m_DecomposeClone:Clone()
	oBox.m_DelBtn = oBox:NewUI(6, CSprite)
	oBox:ShowEquipLevel(true)
	oBox:SetBagItem(dItem.item)
	oBox:SetAmountText(dItem.amount, dItem.maxOverlay)
	oBox:SetClickCallback(callback(self, "OnClickCancel"))
	self.m_DecomposeGrid:AddChild(oBox)
	return oBox
end

function CItemDecomposeResultBox.ShowTreasureItem(self)
	for i,oBox in ipairs(self.m_DecomposeBoxs) do
		if oBox and oBox:GetActive() and oBox:GetBagItem():IsTreasureItem() then
			oBox:AddEffect("Rect")
		end
	end
end

function CItemDecomposeResultBox.RefreshSilverReward(self, dItem)
	self.m_SilverL:SetActive(true)
	self.m_SilverL:SetText(string.format("%d～%d", dItem.minAmount, dItem.maxAmount))
end

function CItemDecomposeResultBox.RefreshRewardItemGrid(self)
	local tRewardList = DataTools.GetDecomposeResultByItemList(self.m_DecomposeList)
	table.extend(tRewardList, DataTools.GetGemStoneDecomposeByItemList(self.m_DecomposeList))
	-- printc("RefreshRewardItemGrid")
	-- table.print(tRewardList)
	for i,oBox in ipairs(self.m_RewardItemBoxs) do
		if oBox then
			oBox:SetActive(false)
		end
	end
	self.m_SilverL:SetActive(false)
	local iIndex = 1
	local iCost = 0
	for i,dItem in ipairs(tRewardList) do
		if dItem.sid == 1002 then --银币不使用itembox
			self:RefreshSilverReward(dItem)
		else
			local oBox = self.m_RewardItemBoxs[iIndex]
			if not oBox then
				oBox = self:CreateRewardItemBox(dItem)
			end
			self.m_RewardItemBoxs[iIndex] = oBox
			self:UpdateRewardItemBox(oBox, dItem)	
			iIndex = iIndex + 1
		end
		iCost = dItem.cost + iCost
	end
	self:RefreshSilverCost(iCost)
	self.m_RewardItemGrid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CItemDecomposeResultBox.CreateRewardItemBox(self, dItem)
	local oBox = self.m_RewardItemClone:Clone()
	self.m_RewardItemGrid:AddChild(oBox)
	return oBox
end

function CItemDecomposeResultBox.UpdateRewardItemBox(self, oBox, dItem)
	local dGemStoneInfo
	if dItem.gemStoneId then
		local lAttr = DataTools.GetGemStoneAttrList(dItem.attrkey)
		dGemStoneInfo = {grade = dItem.grade, addattr = lAttr}
	end
	local oItem = CItem.CreateDefault(dItem.sid, dGemStoneInfo)

	oBox:SetBagItem(oItem)
	oBox.m_AmountLabel:SetActive(true)
	oBox.m_AmountLabel:SetText(string.format("%d～%d", dItem.minAmount, dItem.maxAmount))
	oBox:SetActive(true)
end

function CItemDecomposeResultBox.UpdateBagItemBoxByItem(self, iItemId)
	local oView = CItemComposeView:GetView()
	if oView then
		oView.m_DecomposeBox:UpdateBagItemBoxByItem(iItemId)
	end
end

function CItemDecomposeResultBox.RefreshSilverCost(self, iCost)
	self.m_Cost = iCost
	self.m_CostBox:SetCurrencyCount(iCost)
end

function CItemDecomposeResultBox.OnClickCancel(self, oBox)
	local iItemId = oBox.m_Item.m_ID
	self:DelDecomposeItem(iItemId, true)
end

function CItemDecomposeResultBox.OnClickDecompose(self)
	if #self.m_DecomposeList == 0 then
		g_NotifyCtrl:FloatMsg("请先选择分解的物品")
		return
	end
	if g_AttrCtrl.silver < self.m_Cost then
		g_NotifyCtrl:FloatMsg("分解所需银币不足")
		return
	end
	
	local bContainTreasure = self:CheckContainTreasure()
	if not bContainTreasure then
		self:RequestDeCompose()
		return
	end

	local windowConfirmInfo = {
		msg = "你选中的分解物品中包含珍稀物品，是否确认分解",
		okCallback = function () 
			self:RequestDeCompose()
		end,	
		cancelCallback = function ()
			self:ShowTreasureItem()
		end,
		pivot = enum.UIWidget.Pivot.Center,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CItemDecomposeResultBox.RequestDeCompose(self)
	
	local list = {}
	for i,dItem in ipairs(self.m_DecomposeList) do
		table.insert(list, {id = dItem.item.m_ID, amount = dItem.amount})
	end
	netitem.C2GSDeComposeItemList(list)
end

function CItemDecomposeResultBox.CheckContainTreasure(self)
	for i,dItem in ipairs(self.m_DecomposeList) do
		if dItem.item:IsTreasureItem() then
			return true
		end
	end
end

function CItemDecomposeResultBox.IsSelected(self, iItemId)
	return self.m_DecomposeDict[iItemId] ~= nil
end

return CItemDecomposeResultBox
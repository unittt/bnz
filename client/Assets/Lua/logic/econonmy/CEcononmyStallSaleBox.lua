local CEcononmyStallSaleBox = class("CEcononmyStallSaleBox", CBox)

function CEcononmyStallSaleBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_CallBack = cb

	self.m_WithdrawCashBtn = self:NewUI(1, CButton)
	self.m_OnKeyAddBtn = self:NewUI(2, CButton)
	self.m_TipsBtn = self:NewUI(3, CButton)
	self.m_ItemGrid = self:NewUI(4, CGrid)
	self.m_ItemBoxClone = self:NewUI(5, CBox) 
	self.m_StallGridBox = self:NewUI(6, CBox)
	self.m_BagItemListBox = self:NewUI(7, CEcononmyBagItemListBox)
	self.m_SilverBox = self:NewUI(8, CCurrencyBox)

	self.m_ItemBoxs = {}
	self.m_StatuSprs = {
		[define.Econonmy.StallStatus.SellOut] = "h7_ketixian",
		[define.Econonmy.StallStatus.OverTime] = "h7_yichaoshi",
		[define.Econonmy.StallStatus.OnSell] = "0",
	}
	self:InitContent()
end

function CEcononmyStallSaleBox.InitContent(self)
	self:InitStallGridBox()
	self.m_BagItemListBox:SetEcononmyType(define.Econonmy.Type.Stall)
	self.m_SilverBox:SetCurrencyType(define.Currency.Type.Silver)
	self.m_ItemBoxClone:SetActive(false)
	self.m_WithdrawCashBtn:AddUIEvent("click", callback(self, "OnClickWithdrawCash"))
	self.m_OnKeyAddBtn:AddUIEvent("click", callback(self, "OnClickOnKeyAdd"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTips"))
	g_EcononmyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CEcononmyStallSaleBox.InitStallGridBox(self)
	self.m_StallGridBox.m_CountL = self.m_StallGridBox:NewUI(1, CLabel)
	self.m_StallGridBox.m_UnlockBtn = self.m_StallGridBox:NewUI(2, CButton)
	self.m_StallGridBox.m_UnlockBtn:AddUIEvent("click", callback(self, "RequestUnlock"))
end

function CEcononmyStallSaleBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Econonmy.Event.RefreshStallSellGrid then
		self:RefreshItemGrid()
		self:RefershStallGridBox()
		local iFloatCnt = oCtrl.m_EventData
		if iFloatCnt and iFloatCnt > 0 then
			g_EcononmyCtrl.m_StallFloatSilver = true
			Utils.AddTimer(function()
				g_EcononmyCtrl.m_StallFloatSilver = false
			end, 1, 1)
		end
		if g_EcononmyCtrl.m_JumpStallItem then
			local iRemainingGrid = g_EcononmyCtrl:GetRemainingGridCount()
			if iRemainingGrid > 0 then
				CEcononmyBatchStallView:ShowView(function(oView)
					oView:SetSelectedItem(g_EcononmyCtrl.m_JumpStallItem)
					oView:RefreshItemGrid()
					g_EcononmyCtrl.m_JumpStallItem = nil
				end)
			else
				g_EcononmyCtrl.m_JumpStallItem = nil
			end
		end
	end
end

function CEcononmyStallSaleBox.RefershStallGridBox(self)
	local iUnlockCount = g_EcononmyCtrl:GetStallUnlockSize()
	local iUseGrid = iUnlockCount - g_EcononmyCtrl:GetRemainingGridCount()
	self.m_StallGridBox.m_CountL:SetText(string.format("%d/%d", iUseGrid, iUnlockCount))
	self.m_StallGridBox.m_UnlockBtn:SetActive(iUnlockCount ~= iUseGrid)
end

function CEcononmyStallSaleBox.RefreshItemGrid(self)
	for i = 1, 10 do
		local oBox = self.m_ItemBoxs[i]
		if not oBox then
			oBox = self:CreateItemBox()
			self.m_ItemBoxs[i] = oBox
			self.m_ItemGrid:AddChild(oBox)
		end
		oBox:SetActive(false)
	end
	local iUnlockCount = g_EcononmyCtrl:GetStallUnlockSize()
	for i = 1, 10 do
		local oBox = self.m_ItemBoxs[i]
		local dInfo = g_EcononmyCtrl:GetStallInfoByPos(i)
		local bIsUnlock = i <= iUnlockCount
		local iLastStatus = oBox.m_Status
		if dInfo and dInfo.pos_id == i then
			self:UpdateItemBox(oBox, dInfo, bIsUnlock)
		else
			self:UpdateItemBox(oBox, nil, bIsUnlock)
		end
		if oBox.m_Status ~= define.Econonmy.StallStatus.SellOut and 
			iLastStatus == define.Econonmy.StallStatus.SellOut then
			local item = DataTools.GetItemData(1002, "VIRTUAL")
			g_NotifyCtrl:QuickFloatItemBox(item.icon, oBox.m_ItemIconSpr:GetPos())
		end
		if not bIsUnlock then
			break
		end
	end
	self.m_ItemGrid:Reposition()
end

function CEcononmyStallSaleBox.CreateItemBox(self)
	local oBox = self.m_ItemBoxClone:Clone()
	oBox.m_AddBtn = oBox:NewUI(1, CButton)
	oBox.m_UnlockBtn = oBox:NewUI(2, CWidget)
	oBox.m_ItemObj = oBox:NewUI(3, CObject)
	oBox.m_NameL = oBox:NewUI(4, CLabel)
	oBox.m_ItemIconSpr = oBox:NewUI(5, CSprite)
	oBox.m_AmountL = oBox:NewUI(6, CLabel)
	oBox.m_PriceL = oBox:NewUI(7, CLabel)
	oBox.m_UnlockCostL = oBox:NewUI(8, CLabel)
	oBox.m_StatusSpr = oBox:NewUI(9, CSprite)
	oBox.m_QualitySpr = oBox:NewUI(10, CSprite)

	oBox:AddUIEvent("click", callback(self, "OnClickItemBox", oBox))
	oBox.m_AddBtn:AddUIEvent("click", callback(self, "OnClickAddSellItem"))
	oBox.m_UnlockBtn:AddUIEvent("click", callback(self, "RequestUnlock"))
	return oBox
end

function CEcononmyStallSaleBox.UpdateItemBox(self, oBox, dInfo, bIsUnlock)
	oBox:SetActive(true)
	oBox.m_AddBtn:SetActive(not dInfo and bIsUnlock)
	oBox.m_ItemObj:SetActive(dInfo ~= nil)
	oBox.m_UnlockBtn:SetActive(not dInfo and not bIsUnlock)
	if not dInfo then
		oBox.m_Status = define.Econonmy.StallStatus.None
		return
	end
	local dItemData = DataTools.GetItemData(dInfo.sid)
	oBox.m_Pos = dInfo.pos_id
	oBox.m_StallInfo = dInfo
	oBox.m_ItemIconSpr:SpriteItemShape(dItemData.icon)
	oBox.m_PriceL:SetCommaNum(dInfo.price)
	oBox.m_NameL:SetText(dItemData.name)
	oBox.m_UnlockCostL:SetText(DataTools.GetGlobalData(109).value)
	oBox.m_AmountL:SetCommaNum(dInfo.amount)
	oBox.m_QualitySpr:SetItemQuality(dInfo.quality)

	local diffTime = math.floor(os.difftime(g_TimeCtrl:GetTimeS(), dInfo.sell_time)/(60))
	-- oBox.m_OverTimeL:SetActive(false)
	local iOverTime = tonumber(DataTools.GetGlobalData(108).value)
	if dInfo.cash > 0 then
		oBox.m_Status = define.Econonmy.StallStatus.SellOut
	elseif diffTime > iOverTime then
		oBox.m_Status = define.Econonmy.StallStatus.OverTime
	else
		oBox.m_Status = define.Econonmy.StallStatus.OnSell
	end
	oBox.m_StatusSpr:SetSpriteName(self.m_StatuSprs[oBox.m_Status])
end

function CEcononmyStallSaleBox.OnClickWithdrawCash(self)
	netstall.C2GSWithdrawAllCash()
end

function CEcononmyStallSaleBox.OnClickOnKeyAdd(self)
	-- netstall.C2GSAddOverTimeItem()
	CEcononmyBatchStallView:ShowView()
end

function CEcononmyStallSaleBox.OnClickTips(self)
	local id = define.Instruction.Config.Stall
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CEcononmyStallSaleBox.OnClickItemBox(self, oBox)
	if oBox.m_Status == define.Econonmy.StallStatus.SellOut then
		netstall.C2GSWithdrawOneGrid(oBox.m_StallInfo.pos_id)
		return
	end
	CEcononmyStallOparateView:ShowView(
		function(oView)
			local sid = oBox.m_StallInfo.sid
			local oItem = CItem.CreateDefault(sid)
			oItem.m_SData.itemlevel = oBox.m_StallInfo.quality
			oView:SetItemInfo(oItem, oBox.m_Status, oBox.m_StallInfo)		
		end
	)
end

function CEcononmyStallSaleBox.OnClickAddSellItem(self)
	CEcononmyBatchStallView:ShowView()
end

function CEcononmyStallSaleBox.RequestUnlock(self)
	local windowConfirmInfo = {
		msg = string.format("确定消耗%d元宝解锁", DataTools.GetGlobalData(109).value),
		okCallback = function() netstall.C2GSUnlockGrid() end,	
		pivot = enum.UIWidget.Pivot.Center,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

return CEcononmyStallSaleBox
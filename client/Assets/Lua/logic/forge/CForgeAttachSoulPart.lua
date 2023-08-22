local CForgeAttachSoulPart = class("CForgeAttachSoulPart", CPageBase)

function CForgeAttachSoulPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

--------Init UI or data--------
function CForgeAttachSoulPart.OnInitPage(self)
	self.m_EquipGrid = self:NewUI(1, CGrid)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_EquipScrollView = self:NewUI(3, CScrollView)
	self.m_WarningL = self:NewUI(4, CLabel)
	self.m_GiftBtn = self:NewUI(5, CButton)
	self.m_UseItemBoxs = {
		self:NewUI(6, CBox),
		self:NewUI(7, CBox),
		self:NewUI(8, CBox),
	}
	self.m_EquipBox = self:NewUI(9, CBox)
	self.m_AttachBtn = self:NewUI(10, CButton)
	self.m_CostBox = self:NewUI(11, CCurrencyBox)
	self.m_SilverBox = self:NewUI(12, CCurrencyBox)
	self.m_TipBtn = self:NewUI(13, CButton)
	self.m_AttrBox = self:NewUI(14, CForgeSoulAttrBox)
	self.m_GiftSlider = self:NewUI(15, CSlider)
	self.m_GiftFlagSpr = self:NewUI(16, CSprite)
	self.m_GiftTipsSpr = self:NewUI(17, CSprite)
	self.m_QuickBuyBox = self:NewUI(18, CQuickBuyBox)
	self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)

	self.m_SelectedId = -1	--选定的装备id
	self.m_IsAutoSave = false
	self.m_FuHunInfo = nil
	self:InitContent()
end

function CForgeAttachSoulPart.InitContent(self)
	self.m_SilverBox:SetCurrencyType(define.Currency.Type.Silver)
	self.m_CostBox:SetCurrencyType(define.Currency.Type.Silver, true)

	self.m_BoxClone:SetActive(false)
	self.m_AttachBtn:AddUIEvent("click", callback(self, "RequestAttach"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "ShowTipView"))
	self.m_GiftBtn:AddUIEvent("click", callback(self, "OpenGiftView"))
	g_UITouchCtrl:TouchOutDetect(self, callback(self.m_GiftTipsSpr, "SetActive", false))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))

	self.m_QuickBuyBox:SetInfo({
		id = define.QuickBuy.ForgeAttachSoul,
		name = "便捷附魂",
		offset = Vector3(-30,0,0),
	})

	self:LoadSelectedId()
	self:InitUseItemBoxs()
	self:RefreshGiftSlider()
end

function CForgeAttachSoulPart.OnCtrlItemEvent(self, oCtrl)
	if not self:GetActive() then
		return
	end
	if oCtrl.m_EventID == define.Item.Event.RefreshAttachSoulInfo then
		self.m_FuHunInfo = oCtrl.m_EventData.Info
		self:SetAttachItemInfo(self.m_FuHunInfo)
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Item.Event.AddItem then
		local oItem = oCtrl.m_EventData
		if oItem:IsForgeMaterial() and self.m_SelectedId ~= -1 then
			netitem.C2GSGetFuHunCost(self.m_SelectedId)
		end
		if not oItem:IsEquiped() then
			return
		end
		self.m_AttachItem = oItem
		self.m_IsAttachSucceeded = self.m_AttachItemInfo and self.m_AttachItemInfo.itemid == oItem.m_ID
		-- 成功音效
		g_AudioCtrl:PlaySound(define.Audio.SoundPath.StrengSucc)
		self:RefreshEquip(self.m_SelectedBox, g_ItemCtrl.m_BagItems[self.m_SelectedId])
	elseif oCtrl.m_EventID == define.Item.Event.RefreshEquipSoulPoint then
		self:RefreshGiftSlider()
	elseif oCtrl.m_EventID == define.Item.Event.ShowUIEffect then
		local dInfo = oCtrl.m_EventData
		if dInfo.effect == define.UIEffect.ForgeSoul then
			self:ShowSuccessEffect(dInfo.cmds)
		end
	end
end

function CForgeAttachSoulPart.SetAttachItemInfo(self, dInfo)
	self.m_AttachItemInfo = dInfo
end

function CForgeAttachSoulPart.InitUseItemBoxs(self)
	for k,oBox in pairs(self.m_UseItemBoxs) do
		oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
		oBox.m_NameLabel = oBox:NewUI(2, CLabel)
		oBox.m_AmountLabel = oBox:NewUI(3, CLabel)
		oBox.m_CountLabel = oBox:NewUI(4, CLabel)
		local function OpenItemTip()
			local iGainItem = oBox.m_Id
			local tItemData = DataTools.GetItemData(oBox.m_Id, "FORGE")
			if tItemData then
				local iEquipLv = self.m_SelectedItem:GetItemEquipLevel()
				local iOffset = math.floor((oBox.m_Lv - iEquipLv)/10)
				iGainItem = oBox.m_Id - iOffset
			end
			g_WindowTipCtrl:SetWindowGainItemTip(iGainItem)
		end
		oBox.m_ItemSpr:AddUIEvent("click", OpenItemTip)
	end

	self.m_EquipBox.m_EquipSpr = self.m_EquipBox:NewUI(1, CSprite)
	self.m_EquipBox.m_NameLabel = self.m_EquipBox:NewUI(2, CLabel)
	self.m_EquipBox.m_LevelLabel = self.m_EquipBox:NewUI(3, CLabel)
	self.m_EquipBox.m_DefColor = self.m_EquipBox.m_EquipSpr:GetColor()
	self.m_EquipBox.m_EquipSpr:AddUIEvent("click", callback(self, "OpenItemInfoWindow"))
end

function CForgeAttachSoulPart.OnShowPage(self)
	g_ItemCtrl:ResetAttachSoulInfo()
	self:RefreshEquipGrid()
end

function CForgeAttachSoulPart.ChangeSelectId(self, iItemId)
	if not iItemId then
		return
	end
	self.m_SelectedId = iItemId
	self:RefreshEquipGrid()
end

function CForgeAttachSoulPart.ScrollToBox(self, iIndex)
	local oPanel = self.m_EquipScrollView:GetComponent(classtype.UIPanel)
	local iScrollViewH = oPanel:GetViewSize().y
	local _,iCellH = self.m_EquipGrid:GetCellSize()
	local iDiffH = iCellH * (self.m_EquipGrid:GetCount()) - iScrollViewH
	local vPos = Vector3.New(0, iIndex * iCellH, 0)
	vPos.y = math.min(iDiffH, vPos.y)
	vPos.y = math.max(0, vPos.y)
	self.m_EquipScrollView:MoveRelative(vPos)
end

-------------------------UI refresh-------------------------------------
function CForgeAttachSoulPart.RefreshUI(self)
	if self.m_AttachItemInfo then
		local iIndex = 1
		local itemsInfo = {}
		local currencys = {}
		for i=1,4 do
			local dInfo = self.m_AttachItemInfo[i]
			if dInfo.sid == 1002 then
				self:RefreshCost(dInfo.amount)
				table.insert(currencys, table.copy(dInfo))
			else
				self:RefreshUseItem(dInfo, self.m_UseItemBoxs[iIndex])
				iIndex = iIndex + 1
				table.insert(itemsInfo, table.copy(dInfo))
			end
		end
		self:RefreshEquipBox(g_ItemCtrl.m_BagItems[self.m_AttachItemInfo.itemid])
		self.m_QuickBuyBox:SetItemsAndCurrencys(itemsInfo, currencys)
	end
	self:RefreshGiftSlider()
end

function CForgeAttachSoulPart.RefreshGiftSlider(self)
	local tData = DataTools.GetEquipSoulPointData(g_AttrCtrl.grade)
	self.m_GiftSlider:SetValue(g_ItemCtrl:GetEquipSoulPoint()/tData.point_limit)
	self.m_GiftFlagSpr:SetActive(g_ItemCtrl:GetEquipSoulPoint() >= tData.point_limit)
end

function CForgeAttachSoulPart.RefreshCost(self, iAmount)
	self.m_CostBox:SetCurrencyCount(iAmount)
	self.m_SilverBox:SetWarningValue(iAmount)
end

function CForgeAttachSoulPart.RefreshEquipGrid(self)
	self.m_EquipScrollView:ResetPosition()
	self.m_EquipGrid:Clear()

	local list =  g_ItemCtrl.m_EquipedItems
	local iCount = 1
	local oSelectedBox = nil

	for k, oItem in pairs(list) do
		if oItem:GetSValueByKey("itemlevel") >= define.Item.Quality.Purple and 
			oItem:GetItemEquipLevel() >= g_ForgeCtrl.m_AttachSoulLimitLv then
			local oBox = self:CreateEquip(oItem)
			self.m_EquipGrid:AddChild(oBox)
			if (self.m_SelectedId == -1 and iCount == 1) or
				self.m_SelectedId == oItem.m_ID then
				oSelectedBox = oBox
				-- self:ScrollToBox(iCount - 1)
			end
			iCount = iCount + 1
		end 
	end

	local bIsEmpty = self.m_EquipGrid:GetCount() == 0
	self:HideUseItems(bIsEmpty)
	self.m_WarningL:SetActive(bIsEmpty)
	if bIsEmpty then
		self.m_SelectedId = -1
		return
	end

	if not oSelectedBox then
		oSelectedBox = self.m_EquipGrid:GetChild(1)
	end
	if oSelectedBox then
		oSelectedBox:SetSelected(true)
		self:OnEquipSelect(oSelectedBox)
	end
end

function CForgeAttachSoulPart.HideUseItems(self, bIsEmpty)
	self.m_EquipBox:SetActive(not bIsEmpty)
	self.m_UseItemBoxs[1]:SetActive(not bIsEmpty)
	self.m_UseItemBoxs[2]:SetActive(not bIsEmpty)
	self.m_UseItemBoxs[3]:SetActive(not bIsEmpty)
end

function CForgeAttachSoulPart.CreateEquip(self, oItem)
	local oBox = self.m_BoxClone:Clone()
	oBox.m_ItemBox = oBox:NewUI(1, CItemBaseBox)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_DefaultLabel = oBox:NewUI(3, CLabel)
	oBox.m_RemindLabel = oBox:NewUI(4, CLabel)
	oBox.m_SoulSpr = oBox:NewUI(5, CSprite)
	oBox.m_LevelLabel = oBox:NewUI(6, CLabel)

	oBox:SetActive(true)
	self:RefreshEquip(oBox, oItem)
	oBox.m_ItemBox:SetEnableTouch(false)

	oBox:SetGroup(self.m_EquipGrid:GetInstanceID())
	oBox:AddUIEvent("click", callback(self, "OnEquipSelect", oBox))
	return oBox
end

function CForgeAttachSoulPart.RefreshEquip(self, oBox, oItem)
	if not oBox then
		return
	end
	oBox.m_CItem = oItem
	oBox.m_ItemBox:SetBagItem(oItem)
	oBox.m_NameLabel:SetText(oItem:GetItemName())
	oBox.m_LevelLabel:SetText(oItem:GetItemEquipLevel().."级")
	
	local bHasAttachSoul = oItem:HasAttachSoul()

	oBox.m_SoulSpr:SetActive(bHasAttachSoul)
	oBox.m_RemindLabel:SetActive(false)
	oBox.m_DefaultLabel:SetActive(not bHasAttachSoul)

	local func = function()
		-- CItemTipsView:ShowView(function(oView)
		-- 	oView:SetItem(oItem)
		-- 	oView:HideBtns()
		-- end)
	end
	oBox.m_ItemBox:SetClickCallback(func)
end

function CForgeAttachSoulPart.RefreshEquipBox(self, oItem)
	if not oItem then
		return
	end
	local oBox = self.m_EquipBox
	oBox.m_EquipSpr:SpriteItemShape(oItem:GetCValueByKey("icon"))
	oBox.m_LevelLabel:SetText(oItem:GetItemEquipLevel().."级")
	oBox.m_NameLabel:SetText(oItem:GetItemName())
	oBox.m_EquipSpr:AddUIEvent("click", function()
		CItemTipsView:ShowView(function(oView)
			oView:SetItem(oItem)
			oView:HideBtns()
		end)
	end)
	if self.m_IsAttachSucceeded then
		-- oBox.m_EquipSpr:SetColor(Color.white)
		self.m_AttrBox:SetItem(oItem)
	else
		-- oBox.m_EquipSpr:SetColor(oBox.m_DefColor)
	end
	self:RefreshAttachButton(oItem)
end

function CForgeAttachSoulPart.RefreshUseItem(self, data, oBox)
	oBox:SetActive(data ~= nil)
	if not data then
		return
	end
	local tData = DataTools.GetItemData(data.sid)
	oBox.m_Id = data.sid
	oBox.m_Amount = data.amount 
	oBox.m_Lv = tData.minGrade

	oBox.m_ItemSpr:SpriteItemShape(tData.icon)
	oBox.m_NameLabel:SetText(tData.name)
	self:RefreshUseItemAmount(oBox, data.sid)
end

function CForgeAttachSoulPart.RefreshUseItemAmount(self, oBox, iItemId)
	oBox.m_CountLabel:SetText("/" .. oBox.m_Amount)
	local iSum = g_ItemCtrl:GetBagItemAmountBySid(iItemId)
	if iSum == 0 or iSum < oBox.m_Amount then
        oBox.m_AmountLabel:SetText("[ffb398]"..iSum)
        oBox.m_AmountLabel:SetEffectColor(Color.RGBAToColor("cd0000"))
    else
        oBox.m_AmountLabel:SetText("[0fff32]"..iSum)
        oBox.m_AmountLabel:SetEffectColor(Color.RGBAToColor("003C41"))
    end
    oBox.m_AmountLabel:ResetAndUpdateAnchors()
end

function CForgeAttachSoulPart.RefreshAttachButton(self, oItem)
	if not oItem then
		return
	end
	self.m_AttachBtn:SetText(oItem:HasAttachSoul() and "重新附魂" or "附魂")
	self.m_AttachBtn:SetLabelSpacingX(oItem:HasAttachSoul() and 0 or 14)
end

function CForgeAttachSoulPart.ShowSuccessEffect(self, lCmd)
	local oBox = self.m_EquipBox
	if oBox.m_DelTimer then
		Utils.DelTimer(oBox.m_DelTimer)
		oBox.m_DelTimer = nil
	end
	local function del()
		if not Utils.IsNil(self) then
			oBox.m_EquipSpr:DelEffect("Screen")
		end
		for i, sCmd in ipairs(lCmd) do
			g_NotifyCtrl:FloatMsg(sCmd)
		end
	end 
	oBox.m_DelTimer = Utils.AddTimer(del, 0, 3)
	oBox.m_EquipSpr:DelEffect("Screen")
	oBox.m_EquipSpr:AddEffect("Screen", "ui_eff_0064")
end

--------------------------UI click or Event Listener-------------------------------------------------------
function CForgeAttachSoulPart.OnEquipSelect(self, oBox)
	self.m_SelectedBox = oBox
	self.m_SelectedId = oBox.m_CItem.m_ID
	self.m_SelectedItem = oBox.m_CItem
	self.m_IsAttachSucceeded = false
	self.m_AttrBox:SetItem(oBox.m_CItem)
	local dInfo = g_ItemCtrl:GetAttachSoulInfo(self.m_SelectedId)
	if dInfo then
		self:SetAttachItemInfo(dInfo)
		self:RefreshUI()
	else
		netitem.C2GSGetFuHunCost(oBox.m_CItem.m_ID)
	end
end

function CForgeAttachSoulPart.RequestAttach(self)
	if self.m_SelectedId <= 0 then
		g_NotifyCtrl:FloatMsg("请先选择装备")
		return
	end

	local bQuickSel = self.m_QuickBuyBox:IsSelected()
	if bQuickSel then
		if not self.m_QuickBuyBox:CheckCostEnough() then
			return
		end
	else
		self:JudgeLackList()
		if g_QuickGetCtrl.m_IsLackItem then
			return
		end
	end

	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.Forge, 4) then
		-- g_NotifyCtrl:FloatMsg("点击太频繁，请稍后再试")
		return
	end
	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.Forge, 4, 0.33) 
	netitem.C2GSUseShenHun(self.m_SelectedId, nil, bQuickSel and 1 or 0)
	netitem.C2GSGetFuHunCost(self.m_SelectedId)
	self:SaveSelectedId()
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗结束后生效")
	end
	-- 强化音效(暂时去掉)
	-- g_AudioCtrl:PlaySound(define.Audio.SoundPath.StrengPros)
end

function CForgeAttachSoulPart.ShowTipView(self)
	local id = define.Instruction.Config.ForgeSoul
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CForgeAttachSoulPart.OpenItemInfoWindow(self)
	if not self.m_IsAttachSucceeded or not self.m_AttachItem then
		return
	end
	CItemTipsView:ShowView(function(oView)
		oView:SetItem(self.m_AttachItem)
		oView:HideBtns()
	end)
end

function CForgeAttachSoulPart.OpenGiftView(self)
	local tData = DataTools.GetEquipSoulPointData(g_AttrCtrl.grade)
	if g_ItemCtrl:GetEquipSoulPoint() < tData.point_limit then
		-- g_NotifyCtrl:FloatMsg("积分不足")
		self.m_GiftTipsSpr:SetActive(true)
		return
	end
	CForgeGiftView:ShowView()
end

function CForgeAttachSoulPart.SaveSelectedId(self)
	if not self.m_IsAutoSave then
		return
	end
	IOTools.SetClientData(string.format("forge_baptize_%d", g_AttrCtrl.pid), self.m_SelectedId)
end

function CForgeAttachSoulPart.LoadSelectedId(self)
	self.m_IsAutoSave = true
	self.m_SelectedId = IOTools.GetClientData(string.format("forge_baptize_%d", g_AttrCtrl.pid)) or -1
	if not g_ItemCtrl.m_BagItems[self.m_SelectedId] then
		self.m_SelectedId = -1
	end
end

function CForgeAttachSoulPart.JudgeLackList(self)
	if self.m_AttachItemInfo  then
		local itemlist = {}
		local coinlist = {}
		for i,v in ipairs(self.m_AttachItemInfo) do
			if v.sid ~= 1002 then
				local iSum =g_ItemCtrl:GetBagItemAmountBySid(v.sid)
				if iSum < v.amount then
					local t = {sid = v.sid, count = iSum, amount = v.amount}
					table.insert(itemlist, t)
				end
			else
				-- if g_AttrCtrl.silver < v.amount then
					local t = {sid = 1002, count = g_AttrCtrl.silver, amount = v.amount}
					table.insert(coinlist, t)
				-- end
			end
		end

		g_QuickGetCtrl:CurrLackItemInfo(itemlist, coinlist, nil, function()
			netitem.C2GSUseShenHun(self.m_SelectedId, nil, 1)
			netitem.C2GSGetFuHunCost(self.m_SelectedId)
			self:SaveSelectedId()
			if g_WarCtrl:IsWar() then
				g_NotifyCtrl:FloatMsg("战斗结束后生效")
			end
		end)
	end

end

return CForgeAttachSoulPart
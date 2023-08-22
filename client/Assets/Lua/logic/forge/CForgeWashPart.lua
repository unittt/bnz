local CForgeWashPart = class("CForgeWashPart", CPageBase)

CForgeWashPart.AttrColor = {
	[1] = "63432c", --灰
	[2] = "1d8e00", --绿
	[3] = "0081ab", --蓝
	[4] = "c50adb", --紫
	[5] = "a64e00",	--橙
	[6] = "ff0000"
}

function CForgeWashPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CForgeWashPart.OnInitPage(self)
	self.m_EquipGrid = self:NewUI(1, CGrid)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_EquipBox = self:NewUI(3, CBox)
	self.m_UseItemBox = self:NewUI(4, CBox)
	self.m_CostBox = self:NewUI(5, CCurrencyBox)
	self.m_SilverBox = self:NewUI(6, CCurrencyBox)
	self.m_WashBtn = self:NewUI(7, CButton)
	self.m_TipLabel = self:NewUI(8, CLabel)
	self.m_NewAttrTable = self:NewUI(9, CTable)
	self.m_CurAttrTable = self:NewUI(10, CTable)
	self.m_NewAttrBox = self:NewUI(11, CBox)
	self.m_CurAttrBox = self:NewUI(12, CBox)
	self.m_ReplaceBtn = self:NewUI(13, CButton)
	self.m_WarningLabel = self:NewUI(14, CLabel)
	self.m_ScrollView = self:NewUI(15, CScrollView)
	self.m_NewAttrObj = self:NewUI(16, CObject)
	self.m_OldAttrObj = self:NewUI(17, CObject)
	self.m_TipBtn = self:NewUI(18, CButton)
	self.m_NotWashL = self:NewUI(19, CLabel)
	self.m_EffectW = self:NewUI(20, CWidget)
	self.m_QuickBuyBox = self:NewUI(21, CQuickBuyBox)
	self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)

	g_GuideCtrl:AddGuideUI("equip_xl_btn", self.m_WashBtn)

	self.m_SelectedId = -1
	self.m_LimitLv = DataTools.GetEquipWashLvLimit()
	self.m_ItemId = 11097 --洗炼石ID
	self.m_IsAutoSave = false
	self.m_WashClick = false


	self:InitContent()
end

function CForgeWashPart.InitContent(self)
	self.m_SilverBox:SetCurrencyType(define.Currency.Type.Silver)
	self.m_CostBox:SetCurrencyType(define.Currency.Type.Silver, true)

	self.m_CurAttrBox:SetActive(false)
	self.m_NewAttrBox:SetActive(false)
	self.m_BoxClone:SetActive(false)
	self.m_WashBtn:AddUIEvent("click", callback(self, "RequestWash"))
	self.m_ReplaceBtn:AddUIEvent("click", callback(self, "RequestReplaceAttr"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "ShowTipView"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))

	self:InitItemBoxs()
	self:LoadSelectedId()
	self:InitQuickBuyBox()
end

function CForgeWashPart.OnShowPage(self)
	self:RefreshEquipGrid()
end

function CForgeWashPart.ChangeSelectId(self, iItemId)
	if not iItemId then
		return
	end
	self.m_SelectedId = iItemId
	self:RefreshEquipGrid()
end

function CForgeWashPart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshWashInfo then
		self:RefreshAttrPanel()
		if self.m_WashClick then
			self.m_WashClick = false
			-- 洗练成功
			g_AudioCtrl:PlaySound(define.Audio.SoundPath.StrengSucc)
		end
	elseif oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:RefreshUseItem()
	elseif oCtrl.m_EventID == define.Item.Event.ShowUIEffect then
		local dInfo = oCtrl.m_EventData
		if dInfo.effect == define.UIEffect.ForgeWash then
			self:ShowSuccessEffect(dInfo.cmds)
		end
	end
end

function CForgeWashPart.SetWashData(self, tData)
	self.m_WashData = tData
end

function CForgeWashPart.InitItemBoxs(self)
	self.m_UseItemBox.m_NameLabel = self.m_UseItemBox:NewUI(1, CLabel)
	self.m_UseItemBox.m_AmountLabel = self.m_UseItemBox:NewUI(2, CLabel)
	self.m_UseItemBox.m_ItemBox = self.m_UseItemBox:NewUI(3, CItemBaseBox)
	self.m_UseItemBox.m_CountLabel = self.m_UseItemBox:NewUI(4, CLabel)

	self.m_EquipBox.m_IconSpr = self.m_EquipBox:NewUI(1, CSprite)
	local function OpenItemTip()
		if not self.m_EquipBox.m_Item then
			return
		end
		CItemTipsView:ShowView(function(oView)
			local cItem = g_ItemCtrl.m_BagItems[self.m_EquipBox.m_Item.m_ID]
			oView:SetItem(cItem)
			oView:HideBtns()
		end)
	end
	self.m_EquipBox.m_IconSpr:AddUIEvent("click", OpenItemTip)
end

function CForgeWashPart.InitQuickBuyBox(self)
	self.m_QuickBuyBox:SetInfo({
		id = define.QuickBuy.ForgeWash,
		name = "便捷洗炼",
		offset = Vector3(-45,0,0),
	})
end

-------------------UI init or refresh-------------------------------
function CForgeWashPart.RefreshCost(self)
	self.m_CostBox:SetCurrencyCount(self.m_WashData.silver)
	self.m_SilverBox:SetWarningValue(self.m_WashData.silver)
	self.m_QuickBuyBox:SetCurrencys({[1]={money_type = define.Currency.Type.Silver, price = self.m_WashData.silver},})
end

function CForgeWashPart.ScrollToBox(self, iIndex)
	local oPanel = self.m_ScrollView:GetComponent(classtype.UIPanel)
	local iScrollViewH = oPanel:GetViewSize().y
	local _,iCellH = self.m_EquipGrid:GetCellSize()
	local iDiffH = iCellH * self.m_EquipGrid:GetCount() - iScrollViewH
	local vPos = Vector3.New(0, iIndex * iCellH, 0)
	vPos.y = math.min(iDiffH, vPos.y)
	vPos.y = math.max(0, vPos.y)
	self.m_ScrollView:MoveRelative(vPos)
end

function CForgeWashPart.RefreshEquipGrid(self)
	local list = g_ItemCtrl.m_EquipedItems
	--g_ItemCtrl:GetEquipList(g_AttrCtrl.school, g_AttrCtrl.sex, 
	--	self.m_LimitLv, nil, nil, g_AttrCtrl.race, g_AttrCtrl.roletype, true)
	self.m_EquipGrid:Clear()
	self.m_ScrollView:ResetPosition()

	local iCount = 1
	local oSelectedBox = nil
	for k, oItem in pairs(list) do
		if oItem:GetSValueByKey("pos") <= define.Equip.Pos.Shoes and oItem:GetItemEquipLevel() >= self.m_LimitLv then
			local oBox = self:CreateEquip(oItem)
			self.m_EquipGrid:AddChild(oBox)
			if (self.m_SelectedId == -1 and iCount == 1) or
				self.m_SelectedId == oItem.m_ID then
				oSelectedBox = oBox
			elseif not oSelectedBox then
				iCount = iCount + 1 
			end
		end
	end
	if oSelectedBox then
		oSelectedBox:SetSelected(true)
		self:OnEquipSelect(oSelectedBox)
		--TODO：策划需求修改，不需洗炼未装备的装备，故无需滚动
		-- self:ScrollToBox(iCount - 1)
	end

	local bHasEquip = self.m_EquipGrid:GetCount() > 0
	self.m_WarningLabel:SetActive(not bHasEquip)
	self.m_UseItemBox:SetActive(bHasEquip)
	self.m_EquipBox:SetActive(bHasEquip)
	self.m_ReplaceBtn:SetActive(bHasEquip)
	self.m_NewAttrObj:SetActive(bHasEquip)
	self.m_OldAttrObj:SetActive(bHasEquip)
	if not bHasEquip then
		self.m_QuickBuyBox:SetItemsInfo(nil)
	end
end

function CForgeWashPart.CreateEquip(self, oItem)
	local oBox = self.m_BoxClone:Clone()
	oBox.m_ItemBox = oBox:NewUI(1, CItemBaseBox)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_LvLabel = oBox:NewUI(3, CLabel)
	oBox.m_TypeLabel = oBox:NewUI(4, CLabel)
	oBox.m_EquipSpr =oBox:NewUI(5, CSprite)

	oBox.m_ItemBox:SetBagItem(oItem)
	oBox.m_ItemBox:SetAmountText(0)
	oBox.m_ItemBox:SetEnableTouch(false)
	oBox:SetGroup(self.m_EquipGrid:GetInstanceID())
	oBox.m_CItem = oItem

	oBox.m_NameLabel:SetText(oItem:GetItemName())
	oBox.m_LvLabel:SetText(oItem:GetItemEquipLevel().."级")
	oBox.m_TypeLabel:SetText(oItem:GetCValueByKey("partName")) --TODO:等改都表
	oBox.m_EquipSpr:SetActive(oItem:IsEquiped())
	oBox:SetActive(true)

	local func = function()
		-- CItemTipsView:ShowView(function(oView)
		-- 	oView:SetItem(oBox.m_CItem)
		-- 	oView:HideBtns()
		-- end)
	end
	oBox.m_ItemBox:SetClickCallback(func)

	oBox:AddUIEvent("click", callback(self, "OnEquipSelect", oBox))
	return oBox
end
function CForgeWashPart.RefreshEquipBox(self, oItem)
	-- self.m_EquipBox.m_ItemBox:SetBagItem(oItem)
	-- self.m_EquipBox.m_ItemBox:SetAmountText(0)
	-- self.m_EquipBox.m_LevelLabel:SetText(oItem:GetCValueByKey("equipLevel"))
	-- self.m_EquipBox.m_NameLabel:SetText(oItem:GetSValueByKey("name"))
	-- self.m_EquipBox.m_ItemBox:SetEnableTouch(false)
	self.m_EquipBox.m_IconSpr:SpriteItemShape(oItem:GetCValueByKey("icon"))
	self.m_EquipBox.m_Item = oItem
end

function CForgeWashPart.RefreshUseItem(self)
	local oItem = self.m_UseItemBox.m_ItemBox:GetBagItem()
	if not oItem then
		oItem = CItem.CreateDefault(self.m_ItemId)
	end
	if not self.m_WashData then
		return
	end

	self.m_UseItemBox.m_CountLabel:SetText("/" .. self.m_WashData.amount)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
	self.m_UseItemBox.m_ItemBox:SetBagItem(oItem)
	self.m_UseItemBox.m_NameLabel:SetText(oItem:GetItemName())
	if iAmount == 0 or iAmount < self.m_WashData.amount then
        self.m_UseItemBox.m_AmountLabel:SetText("[ffb398]"..iAmount)
        self.m_UseItemBox.m_AmountLabel:SetEffectColor(Color.RGBAToColor("cd0000"))
    else
        self.m_UseItemBox.m_AmountLabel:SetText("[0fff32]"..iAmount)
        self.m_UseItemBox.m_AmountLabel:SetEffectColor(Color.RGBAToColor("003C41"))
    end
    self.m_UseItemBox.m_AmountLabel:ResetAndUpdateAnchors()
	self.m_QuickBuyBox:SetItemsInfo({
		{id = self.m_ItemId, cnt = self.m_WashData.amount},
	})
end

function CForgeWashPart.RefreshAttrPanel(self)
	local dAttrList = g_ItemCtrl:GetWashEquipInfo()
	self.m_CurAttrTable:Clear()
	self.m_NewAttrTable:Clear()	
	-- self.m_TipLabel:SetActive(dAttrList.new == nil or (table.count(dAttrList.new.apply_info) == 0 
	-- 	and table.count(dAttrList.new.apply_info) == 0 and dAttrList.new.se_list == nil))
	--附加属性
	dAttrList.cur.apply_info = self:InitAttrColor(dAttrList.cur.apply_info)
	dAttrList.new.apply_info = self:InitAttrColor(dAttrList.new.apply_info)

	local function addAttr(dInfo, oCloneBox, oTable, bIsEffect)
		for k,v in pairs(dInfo) do
			local oBox = nil
			if bIsEffect then 
				oBox = self:CreateEffectBox(oCloneBox, v)
			else
				oBox = self:CreateAttrBox(oCloneBox, v)
			end
			oTable:AddChild(oBox)	
		end
	end 
	addAttr(dAttrList.cur.apply_info, self.m_CurAttrBox, self.m_CurAttrTable)
	addAttr(dAttrList.new.apply_info, self.m_NewAttrBox, self.m_NewAttrTable)
	--特效
	-- addAttr(dAttrList.cur.se_list, self.m_CurAttrBox, self.m_CurAttrTable, true)
	-- addAttr(dAttrList.new.se_list, self.m_NewAttrBox, self.m_NewAttrTable, true)

	local bHasNewAttr = self.m_NewAttrTable:GetCount() > 0
	self.m_TipLabel:SetActive(not bHasNewAttr)
	self.m_ReplaceBtn:SetActive(bHasNewAttr)

	local bHasCurAttr = self.m_CurAttrTable:GetCount() > 0
	if bHasNewAttr and (not bHasCurAttr) then
		self.m_ReplaceBtn:AddEffect("Rect")
	else
		self.m_ReplaceBtn:DelEffect("Rect")
	end
	self.m_NotWashL:SetActive(not bHasCurAttr and self.m_SelectedId ~= -1)
end

function CForgeWashPart.CreateEffectBox(self, oCloneBox, iEffectId)
	local oBox = oCloneBox:Clone()
	oBox:SetActive(true)
	oBox.m_AttrNameL = oBox:NewUI(1, CLabel)
	oBox.m_AttrValueL = oBox:NewUI(2, CLabel)
	oBox.m_Silder = oBox:NewUI(3, CSlider) 	

	oBox.m_AttrValueL:SetActive(false)
	oBox.m_Silder:SetActive(false)
	local sEffName = LinkTools.GenerateEquipSpecialEffLink(iEffectId)
	sEffName = string.format("[%s]%s[-]",CForgeWashPart.AttrColor[6], sEffName)
	oBox.m_AttrNameL:SetRichText(sEffName)
	return oBox
end

function CForgeWashPart.CreateAttrBox(self, oCloneBox, tData)
	local oBox = oCloneBox:Clone()
	oBox:SetActive(true)
	oBox.m_AttrNameL = oBox:NewUI(1, CLabel)
	oBox.m_AttrValueL = oBox:NewUI(2, CLabel)
	oBox.m_Silder = oBox:NewUI(3, CSlider)

	local sAttrName = data.attrnamedata.DATA[tData.key].name
	sAttrName = string.format("[%s]%s[-]",CForgeWashPart.AttrColor[tData.colortype], sAttrName)
	local sValue = string.format("[%s]%d[-]",CForgeWashPart.AttrColor[tData.colortype], tData.value)

	oBox.m_Silder:SetValue(tData.rate)
	oBox.m_AttrNameL:SetText(sAttrName)
	oBox.m_AttrValueL:SetText(sValue)
	return oBox
end

function CForgeWashPart.ShowSuccessEffect(self, lCmd)
	if self.m_EffectW.m_DelTimer then
		Utils.DelTimer(self.m_EffectW.m_DelTimer)
		self.m_EffectW.m_DelTimer = nil
	end
	local function del()
		if not Utils.IsNil(self) then
			self.m_EffectW:DelEffect("Screen")
		end
	end 
	self.m_EffectW:DelEffect("Screen")
	self.m_EffectW.m_DelTimer = Utils.AddTimer(del, 0, 2)
	self.m_EffectW:AddEffect("Screen", "ui_eff_0063")
end

------------------------UI Click Event-------------------------------
function CForgeWashPart.OnEquipSelect(self, oBox)
	self.m_SelectedId = oBox.m_CItem.m_ID
	self.m_EquipLv = oBox.m_CItem:GetItemEquipLevel()
	if self.m_EquipLv%10 ~= 0 then
		self.m_EquipLv = math.floor(self.m_EquipLv/10)*10
	end
	-- printc("选中："..self.m_SelectedId)

	local iEquipPos = oBox.m_CItem:GetCValueByKey("equipPos")
	local tWashData = DataTools.GetWashInfo(iEquipPos, self.m_EquipLv)

	netitem.C2GSWashEquipInfo(oBox.m_CItem.m_ID)
	self:SetWashData(tWashData)
	self:RefreshEquipBox(oBox.m_CItem)
	self:RefreshUseItem()
	self:RefreshCost()
end

function CForgeWashPart.RequestWash(self)
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.Forge, 3) then
		-- g_NotifyCtrl:FloatMsg("点击太频繁，请稍后再试")
		return
	end
	if self.m_SelectedId == -1 then
		g_NotifyCtrl:FloatMsg("请先获得装备")
		return
	end 
	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.Forge, 3, 0.33) 
	local bQuickBuy = self.m_QuickBuyBox:IsSelected()
	if not bQuickBuy then
		self:JudgeLackList()
		if g_QuickGetCtrl.m_IsLackItem then
			return
		end
	elseif not self.m_QuickBuyBox:CheckCostEnough() then
		return
	end

	netitem.C2GSWashEquip(self.m_SelectedId, bQuickBuy and 1 or 0)
	self:SaveSelectedId()
	self.m_WashClick = true
	-- 强化音效（暂时去掉）
	-- g_AudioCtrl:PlaySound(define.Audio.SoundPath.StrengPros)
end

function CForgeWashPart.RequestReplaceAttr(self)
	if self.m_TipLabel:GetActive() then
		return
	end
	if self.m_NewAttrTable:GetCount() <= 0 then
		g_NotifyCtrl:FloatMsg("请先获得装备")
		return
	end
	local windowConfirmInfo = {
		msg = "是否确定保留新属性？",
		okCallback = function () netitem.C2GSUseWashEquip(self.m_SelectedId) end,	
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CForgeWashPart.ShowTipView(self)
	local id = define.Instruction.Config.ForgeWash
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

---------------------other------------------------------------------
function CForgeWashPart.InitAttrColor(self, dList)
	if not dList then
		return
	end
	local dAttachInfo = DataTools.GetEquipAttachAttrData(g_AttrCtrl.school)
	local function GetAttrArea(sFormula, minRatio, maxRatio)
		sFormula = string.replace(sFormula, "lv", self.m_EquipLv)
		local sNewFormula = string.replace(sFormula, "k", minRatio)
		local func = loadstring("return "..sNewFormula)
		local iMinValue = math.floor(func()/100)
		sNewFormula = string.replace(sFormula, "k", maxRatio)
		local func = loadstring("return "..sNewFormula)
		local iMaxValue = math.floor(func()/100)
		return iMinValue, iMaxValue
	end
	for k,v in pairs(dList) do
		local color = 1
		local dInfo = dAttachInfo[v.key]
		local iMinValue,iMaxValue = GetAttrArea(dInfo.formula, dInfo.minRatio, dInfo.maxRatio)
		local iRate = (v.value - iMinValue)/(iMaxValue - iMinValue)

		if iRate > 0.2 and iRate <= 0.4 then
			color = 2
		elseif iRate > 0.4 and iRate <= 0.6 then
			color = 3
		elseif iRate > 0.6 and iRate <= 0.8 then
			color = 4
		elseif iRate > 0.8 and iRate <= 1 then
			color = 5
		end
		dList[k] = {key = v.key, value = v.value, colortype = 1, rate = iRate}
	end
	return dList
end

function CForgeWashPart.SaveSelectedId(self)
	if not self.m_IsAutoSave then
		return
	end
	IOTools.SetClientData(string.format("forge_wash_%d", g_AttrCtrl.pid), self.m_SelectedId)
end

function CForgeWashPart.LoadSelectedId(self)
	self.m_IsAutoSave = true
	self.m_SelectedId = IOTools.GetClientData(string.format("forge_wash_%d", g_AttrCtrl.pid)) or -1
	if not g_ItemCtrl.m_BagItems[self.m_SelectedId] then
		self.m_SelectedId = -1
	end
	-- printc("最后一次打开："..self.m_SelectedId)
end


function CForgeWashPart.JudgeLackList(self)
	if self.m_WashData then
		local itemlist = {}
		local coinlist = {}
		local iSum = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
		if iSum < self.m_WashData.amount then
			local t = {sid = self.m_ItemId, count = iSum, amount = self.m_WashData.amount}
			table.insert(itemlist, t)
		end
		-- if g_AttrCtrl.silver < self.m_WashData.silver then
			local t = {sid = 1002, count = g_AttrCtrl.silver, amount =  self.m_WashData.silver}
			table.insert(coinlist, t)
		-- end
		g_QuickGetCtrl:CurrLackItemInfo(itemlist, coinlist, nil, function()
			netitem.C2GSWashEquip(self.m_SelectedId, 1)
		end)
	end
end

return CForgeWashPart
local CForgeMainPart = class("CForgeMainPart", CPageBase)

function CForgeMainPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

--------Init UI or data--------
function CForgeMainPart.OnInitPage(self)
	self.m_EquipGrid = self:NewUI(1, CGrid)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_TipBtn = self:NewUI(3, CButton)
	self.m_PopupBox = self:NewUI(4, CPopupBox)
	self.m_EquipBox = self:NewUI(5, CBox)
	self.m_UseItemBoxs = {
		self:NewUI(6, CBox),
		self:NewUI(7, CBox)
	}	
	
	self.m_CostBox = self:NewUI(8, CCurrencyBox)
	self.m_SilverBox = self:NewUI(9, CCurrencyBox)
	self.m_ForgeBtn = self:NewUI(10, CButton)
	self.m_CommonContent = self:NewUI(11, CObject)
	self.m_PreviewBtn = self:NewUI(12, CButton)
	self.m_ScrollView = self:NewUI(13, CScrollView)
	self.m_EquipAttrBox = self:NewUI(14, CForgeEquipAttrBox)
	self.m_AttrPreviewBox = self:NewUI(15, CForgeAttrPreviewBox)
	self.m_QuickBuyBox = self:NewUI(16, CQuickBuyBox)
	self.m_EffectListBtn = self:NewUI(17, CButton)

	self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)

	self.m_SelectedLv = -1  --选择的装备等级
	self.m_SelectedId = -1	--选定的装备id
	self.m_SelectedPopupIdx = -1 --选定的下拉框选项
	self.m_LastPopupIdx = -1 --上一次的下拉框选项,下拉列表改成倒序，故记录的是倒序的index

	self.m_IsInitUI = true
	self.m_IsAutoSave = false
	self.m_UnlockLv = 40
	self.m_ForgeItemInfo = nil  --打造所需物品
	-- self.m_QuickCost = 0 --便捷打造消耗
	self.m_IsForgeSucceeded = false
	self.m_SelectedBox = nil
	self:InitContent()
end

function CForgeMainPart.InitContent(self)
	self.m_QuickBuyBox:SetInfo({
		id = define.QuickBuy.ForgeMain,
		name = "便捷打造",
		offset = Vector3(-40,0,0),
	})

	self.m_SilverBox:SetCurrencyType(define.Currency.Type.Silver)
	self.m_CostBox:SetCurrencyType(define.Currency.Type.Silver, true)

	self.m_BoxClone:SetActive(false)
	self.m_ForgeBtn:AddUIEvent("click", callback(self, "RequestForge"))
	self.m_PreviewBtn:AddUIEvent("click", callback(self, "OpenPreview"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "ShowTipView"))
	self.m_EffectListBtn:AddUIEvent("click", callback(self, "ShowEffectListView"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))

	self:LoadSelectedId()
	self:InitUseItemBoxs()
	self:InitLevelList()
end

function CForgeMainPart.OnCtrlItemEvent(self, oCtrl)
	if not self:GetActive() then
		return
	end

	if oCtrl.m_EventID == define.Item.Event.RefreshForgeInfo then
		local dInfo = oCtrl.m_EventData.Info
		local iQuickCost = oCtrl.m_EventData.quickCost
		self:SetForgeItemInfo(dInfo, iQuickCost)
		self:RefreshUI(dInfo)
	elseif oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Item.Event.AddBagItem then
		local oItem = oCtrl.m_EventData
		self.m_ForgeItem = oItem
		self.m_IsForgeSucceeded = self.m_ForgeItemInfo and self.m_ForgeItemInfo.itemid == oItem:GetCValueByKey("id")
		g_AudioCtrl:PlaySound(define.Audio.SoundPath.StrengSucc)
		if oItem:IsForgeMaterial() and self.m_SelectedId ~= -1 then
			netitem.C2GSMakeEquipInfo(self.m_SelectedId)
		end
	elseif oCtrl.m_EventID == define.Item.Event.ShowUIEffect then
		local dInfo = oCtrl.m_EventData
		if dInfo.effect == define.UIEffect.ForgeEquip then
			self:ShowSuccessEffect(dInfo.cmds)
		end
	end
end

function CForgeMainPart.FloatItemBox(self, dInfo)
	if dInfo then
		local oView = CForgeMainView:GetView()
		local oItemData = DataTools.GetItemData(dInfo.itemid)
		if g_ItemCtrl.m_FloatItemList then
			for i=#g_ItemCtrl.m_FloatItemList,1,-1 do
				local v = g_ItemCtrl.m_FloatItemList[i] 
				if  dInfo.itemid ==  v.itemid then
					if oView then
						local sPos = g_CameraCtrl:GetUICamera():WorldToScreenPoint(v.pos)
						if sPos.y >250 then
							g_NotifyCtrl:FloatItemBox(oItemData.icon,nil,v.pos)
						else
							g_NotifyCtrl:FloatItemBox(oItemData.icon)
						end
					else
						g_NotifyCtrl:FloatItemBox(oItemData.icon)
					end
				end
				table.remove(g_ItemCtrl.m_FloatItemList, i)
			end
		end
	end
end

function CForgeMainPart.SetForgeItemInfo(self, dInfo, iQuickCost)
	self.m_ForgeItemInfo = dInfo
	-- self.m_QuickCost = iQuickCost
end

function CForgeMainPart.InitUseItemBoxs(self)
	for k,oBox in pairs(self.m_UseItemBoxs) do
		oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
		oBox.m_NameLabel = oBox:NewUI(2, CLabel)
		oBox.m_LvLabel = oBox:NewUI(3, CLabel)
		oBox.m_AmountLabel = oBox:NewUI(4, CLabel)
		oBox.m_CountLabel = oBox:NewUI(5, CLabel)
		local function OpenItemTip()
			local iOffset = math.floor((oBox.m_Lv - self.m_SelectedLv)/10)
			local iGainItem = oBox.m_Id - iOffset
			g_WindowTipCtrl:SetWindowGainItemTip(iGainItem)
		end
		oBox.m_ItemSpr:AddUIEvent("click", OpenItemTip)
	end
	self.m_EquipBox.m_NameLabel = self.m_EquipBox:NewUI(1, CLabel)
	self.m_EquipBox.m_LevelLabel = self.m_EquipBox:NewUI(2, CLabel)
	self.m_EquipBox.m_EquipSpr = self.m_EquipBox:NewUI(3, CSprite)
	self.m_EquipBox.m_DefColor = self.m_EquipBox.m_EquipSpr:GetColor()
	self.m_EquipBox.m_EquipSpr:AddUIEvent("click", callback(self, "OpenItemInfoWindow"))
end

function CForgeMainPart.InitLevelList(self)
	self.m_PopupBox:Clear()
	self.m_PopupBox:SetCallback(callback(self, "OnLevelChange"))
	local iCurIndex = 1
	local iMaxGrade = math.floor(g_AttrCtrl.grade/10 + 1)*10--math.floor(g_AttrCtrl.server_grade/10)*10
	local iCurGrade = math.floor(g_AttrCtrl.grade/10)*10 --获取角色和服务器最近的可打造等级
	iCurGrade = math.max(self.m_UnlockLv, iCurGrade)
	for i = iMaxGrade, self.m_UnlockLv, -10 do
		self.m_PopupBox:AddSubMenu(i.."级", i)
		if iCurGrade == i then
			iCurIndex = (iMaxGrade - i)/10 + 1
		end
	end
	if self.m_LastPopupIdx ~= -1 and self.m_LastPopupIdx ~= 1 then
		self.m_PopupBox:SetSelectedIndex(self.m_PopupBox:GetMenuCount() - self.m_LastPopupIdx)
	elseif iCurIndex ~= 1 then
		self.m_PopupBox:SetSelectedIndex(iCurIndex)
	end
end

function CForgeMainPart.ScrollToBox(self, iIndex)
	local oPanel = self.m_ScrollView:GetComponent(classtype.UIPanel)
	local iScrollViewH = oPanel:GetViewSize().y
	local _,iCellH = self.m_EquipGrid:GetCellSize()
	local iDiffH = iCellH * (self.m_EquipGrid:GetCount()) - iScrollViewH
	local vPos = Vector3.New(0, iIndex * iCellH, 0)
	vPos.y = math.min(iDiffH, vPos.y)
	vPos.y = math.max(0, vPos.y)
	self.m_ScrollView:MoveRelative(vPos)
end

function CForgeMainPart.SaveSelectedId(self)
	-- g_ItemCtrl.m_QuickForge = self.m_QuickForgeBox:GetSelected()
	-- if not self.m_IsAutoSave then
	-- 	return
	-- end
	g_ItemCtrl.m_ForgeUIRecord[string.format("forge_level_%d", g_AttrCtrl.pid)] = self.m_LastPopupIdx
	g_ItemCtrl.m_ForgeUIRecord[string.format("forge_equip_%d", g_AttrCtrl.pid)] = self.m_SelectedId
end

function CForgeMainPart.LoadSelectedId(self)
	self.m_IsAutoSave = true
	self.m_LastPopupIdx = g_ItemCtrl.m_ForgeUIRecord[string.format("forge_level_%d", g_AttrCtrl.pid)] or 1
	self.m_SelectedId = g_ItemCtrl.m_ForgeUIRecord[string.format("forge_equip_%d", g_AttrCtrl.pid)] or -1

end

--------Refresh or Create UI--------
function CForgeMainPart.OnShowPage(self)
	g_ItemCtrl:ResetForgeItemInfo()
	self.m_IsInitUI = true
	self:RefreshEquipGrid()
end

function CForgeMainPart.RefreshUI(self)
	if self.m_ForgeItemInfo then
		local itemInfos = self.m_ForgeItemInfo
		self:RefreshUseItem(self.m_ForgeItemInfo[1], self.m_UseItemBoxs[1])
		self:RefreshUseItem(self.m_ForgeItemInfo[2], self.m_UseItemBoxs[2])
		self:RefreshEquipBox(CItem.CreateDefault(self.m_ForgeItemInfo.itemid))
		self:RefreshSilverCost(self.m_ForgeItemInfo[3].amount)
		self.m_QuickBuyBox:SetItemsInfo({itemInfos[1], itemInfos[2],})
		local currencys = g_QuickGetCtrl:ConvertItem2Currency({itemInfos[3]})
		self.m_QuickBuyBox:SetCurrencys(currencys)
	end
end

function CForgeMainPart.RefreshSilverCost(self, iAmount)
	self.m_CostBox:SetCurrencyCount(iAmount)
	self.m_SilverBox:SetWarningValue(iAmount)
end

function CForgeMainPart.RefreshEquipGrid(self)
	self.m_ScrollView:ResetPosition()
	self.m_EquipGrid:Clear()

	local oSelectedLv = (self.m_SelectedLv < self.m_UnlockLv and {self.m_UnlockLv} or {self.m_SelectedLv})[1]
	local list = DataTools.GetEquipListByLevel(g_AttrCtrl.roletype, g_AttrCtrl.school, g_AttrCtrl.sex, oSelectedLv, nil, g_AttrCtrl.race)
	self.m_IsEmpty = #list == 0
	self:HideUseItems(self.m_IsEmpty)
	if self.m_IsEmpty then
		self.m_IsInitUI = false
		self.m_SelectedId = -1
		return
	end

	local iIndex = -1
	local oSelectedBox = nil
	for k, equipData in pairs(list) do
		local oBox = self:CreateEquip(equipData)
		self.m_EquipGrid:AddChild(oBox)
		if self.m_IsInitUI and ((self.m_SelectedId == -1 and k == 1) or 
			equipData.id == self.m_SelectedId) then
			iIndex = k
			oSelectedBox = oBox
			self.m_IsInitUI = false
		end
	end

	if self.m_IsInitUI then
		return
	end
	if not oSelectedBox then
		oSelectedBox = self.m_EquipGrid:GetChild(1)
		iIndex = 1
	end
	if oSelectedBox then
		oSelectedBox:SetSelected(true)
		self:OnEquipSelect(oSelectedBox)
		self:ScrollToBox(iIndex - 1)
	end
end

function CForgeMainPart.HideUseItems(self, bIsEmpty)
	self.m_EquipBox:SetActive(not bIsEmpty)
	self.m_UseItemBoxs[1]:SetActive(not bIsEmpty)
	self.m_UseItemBoxs[2]:SetActive(not bIsEmpty)
end

function CForgeMainPart.CreateEquip(self, tEquip)
	local oBox = self.m_BoxClone:Clone()
	oBox.m_ItemBox = oBox:NewUI(1, CItemBaseBox)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_LvLabel = oBox:NewUI(3, CLabel)
	oBox.m_TypeLabel = oBox:NewUI(4, CLabel)
	oBox.m_SelectName = oBox:NewUI(5, CLabel)

	local cItem = CItem.CreateDefault(tEquip.id)
	oBox.m_CItem = cItem
	oBox.m_ItemBox:SetBagItem(cItem)
	oBox.m_ItemBox:SetBaseItemQuality(false, 1)
	oBox.m_ItemBox:SetEnableTouch(false)
	oBox.m_NameLabel:SetText(tEquip.name)
	oBox.m_SelectName:SetText(tEquip.name)
	oBox.m_LvLabel:SetText(tEquip.equipLevel.."级")
	oBox.m_TypeLabel:SetText(tEquip.partName) 
	oBox:SetActive(true)

	oBox:SetGroup(self.m_EquipGrid:GetInstanceID())
	oBox:AddUIEvent("click", callback(self, "OnEquipSelect", oBox))
	return oBox
end

function CForgeMainPart.RefreshEquipBox(self, cItem)
	local oBox = self.m_EquipBox
	oBox.m_EquipSpr:SpriteItemShape(cItem:GetCValueByKey("icon"))
	oBox.m_LevelLabel:SetText("等级"..cItem:GetItemEquipLevel())
	oBox.m_NameLabel:SetText(cItem:GetItemName())
	if self.m_IsForgeSucceeded then
		oBox.m_EquipSpr:SetColor(Color.white)
		self.m_EquipAttrBox:SetItem(self.m_ForgeItem)
	else
		oBox.m_EquipSpr:SetColor(oBox.m_DefColor)
	end
end

function CForgeMainPart.RefreshUseItem(self, data, oBox)
	oBox:SetActive(data ~= nil)
	if not data then
		return
	end

	local tData = DataTools.GetItemData(data.sid)
	oBox.m_Id = data.sid
	oBox.m_Amount = data.amount 
	oBox.m_Lv = tData.level or tData.minGrade

	oBox.m_ItemSpr:SpriteItemShape(tData.icon)
	oBox.m_NameLabel:SetText(tData.name)
	oBox.m_LvLabel:SetText("等级"..tData.minGrade)
	self:RefreshUseItemAmount(data.sid)
end

function CForgeMainPart.RefreshUseItemAmount(self, iItemId)
	for k,oBox in pairs(self.m_UseItemBoxs) do
		if oBox.m_Id == iItemId then
			oBox.m_CountLabel:SetText("/" .. oBox.m_Amount)
			local iSum = g_ItemCtrl:GetBagItemAmountBySid(iItemId)
			if iSum == 0 or iSum < oBox.m_Amount then
		        oBox.m_AmountLabel:SetText("[ffb398]"..iSum)
		        oBox.m_AmountLabel:SetEffectColor(Color.RGBAToColor("cd0000"))
		    else
		        oBox.m_AmountLabel:SetText("[0fff32]"..iSum)
		        oBox.m_AmountLabel:SetEffectColor(Color.RGBAToColor("003C41"))
		    end
			break
		end
	end
end

function CForgeMainPart.ShowSuccessEffect(self, lCmd)
	local function NotifyCmds()
		for i, sCmd in ipairs(self.m_NofityCmds) do
			g_NotifyCtrl:FloatMsg(sCmd)
		end
		self.m_NofityCmds = nil
	end
	local oBox = self.m_EquipBox
	oBox.m_EquipSpr:DelEffect("Screen")
	oBox.m_EquipSpr:AddEffect("Screen", "ui_eff_0061")
	if oBox.m_DelTimer then
		if self.m_NofityCmds then
			NotifyCmds()
		end
		Utils.DelTimer(oBox.m_DelTimer)
		oBox.m_DelTimer = nil
	end
	self.m_NofityCmds = lCmd
	local function del()
		if not Utils.IsNil(self) then
			oBox.m_EquipSpr:DelEffect("Screen")
		end
		NotifyCmds()
	end 
	oBox.m_DelTimer = Utils.AddTimer(del, 0, 1.8)
end

--------Click Event or Event Listener--------
function CForgeMainPart.OnLevelChange(self, oBox)
	self.m_SelectedPopupIdx = oBox:GetSelectedIndex()
	local subMenu = oBox:GetSelectedSubMenu()
	self.m_SelectedLv = subMenu.m_ExtraData
	if not self.m_IsInitUI then
		self.m_LastPopupIdx =  self.m_PopupBox:GetMenuCount() - oBox:GetSelectedIndex()
	end
	self:RefreshEquipGrid()
	oBox:SetMainMenu("装备等级"..subMenu.m_ExtraData)
end

function CForgeMainPart.OnEquipSelect(self, oBox)
	self.m_SelectedId = oBox.m_CItem.m_ID
	self.m_SelectedItem = oBox.m_CItem
	self.m_SelectedBox = oBox
	self.m_IsForgeSucceeded = false
	self.m_EquipAttrBox:SetItem(nil)
	local dInfo, iQuickCost = g_ItemCtrl:GetForgeItemInfo(self.m_SelectedId)
	if dInfo then
		self:SetForgeItemInfo(dInfo, iQuickCost)
		self:RefreshUI()
	else
		netitem.C2GSMakeEquipInfo(oBox.m_CItem.m_ID)
	end
end

function CForgeMainPart.RequestForge(self)
	if g_ItemCtrl:IsBagFull() then
		g_NotifyCtrl:FloatMsg("背包已满")
		return
	end
	local index = self.m_PopupBox:GetSelectedIndex()
	if self.m_IsEmpty then
		g_NotifyCtrl:FloatMsg("无可打造的装备")
		return
	end

	local bIsQuick = self.m_QuickBuyBox:IsSelected()
	if bIsQuick then
		if not self.m_QuickBuyBox:CheckCostEnough() then
			return
		end
	--判断是否缺少打造的资源
	else
		self:JudgeLackList()
		if g_QuickGetCtrl.m_IsLackItem then
			return
		end
	end
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.Forge, 1) then
		-- g_NotifyCtrl:FloatMsg("点击太频繁，请稍后再试")
		return
	end
	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.Forge, 1, 0.33) 

	self.m_LastPopupIdx =  self.m_PopupBox:GetMenuCount() - index
	netitem.C2GSMakeEquip(self.m_SelectedId, bIsQuick and 1 or 0)
	netitem.C2GSMakeEquipInfo(self.m_SelectedId)
	-- 打造音效（暂时去掉）
	-- g_AudioCtrl:PlaySound(define.Audio.SoundPath.StrengPros)
	self:SaveSelectedId()
end

function CForgeMainPart.OpenPreview(self)
	if not self.m_SelectedItem then
		return
	end
	self.m_AttrPreviewBox:SetItem(self.m_SelectedItem)
end

function CForgeMainPart.OpenItemInfoWindow(self)
	-- if not self.m_IsForgeSucceeded or not self.m_ForgeItem then
	-- 	return
	-- end
	-- CItemTipsView:ShowView(function(oView)
	-- 		oView:SetItem(self.m_ForgeItem)
	-- 		oView:HideBtns()
	-- end)
end

function CForgeMainPart.ShowTipView(self)
	local id = define.Instruction.Config.ForgeEquip
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CForgeMainPart.ShowEffectListView(self)
	if not self.m_SelectedItem then
		return
	end
	CForgeSpEffectListView:ShowView(function (oView)
		local iEquipPos = self.m_SelectedItem:GetCValueByKey("equipPos")
		local iEquipLv = self.m_SelectedItem:GetCValueByKey("equipLevel")
		oView:SetEquipInfo(iEquipPos, iEquipLv)
	end)
end

function CForgeMainPart.JudgeLackList(self)
	local itemlist = {}
	local coinlist = {}
	if self.m_ForgeItemInfo and next(self.m_ForgeItemInfo) then
		for i,v in ipairs(self.m_ForgeItemInfo) do
			local v = self.m_ForgeItemInfo[i]
			if v.sid ~= 1002 then
				local iSum = g_ItemCtrl:GetBagItemAmountBySid(v.sid)
				if iSum <  v.amount then	--已有的数量  -- 需要的数量
					local t = {sid = v.sid, count = iSum, amount = v.amount}
					table.insert(itemlist, t)
				end
			else
				-- if g_AttrCtrl.silver < v.amount then
					local t = {sid = v.sid, count = g_AttrCtrl.silver, amount = v.amount}
					table.insert(coinlist, t)
				-- end
			end
		end
	end
	local cb = function()
		netitem.C2GSMakeEquip(self.m_SelectedId, 1)
		netitem.C2GSMakeEquipInfo(self.m_SelectedId)
	end
	g_QuickGetCtrl:CurrLackItemInfo(itemlist, coinlist, self.m_QuickCost, cb)
end

return CForgeMainPart
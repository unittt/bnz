local CForgeStrengthenPart = class("CForgeStrengthenPart", CPageBase)

function CForgeStrengthenPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CForgeStrengthenPart.OnInitPage(self)
	self.m_EquipGrid = self:NewUI(1, CGrid)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_EquipBox = self:NewUI(3, CBox)
	self.m_UseItemBox = self:NewUI(4, CBox)
	self.m_CostBox = self:NewUI(5, CCurrencyBox)
	self.m_SilverBox = self:NewUI(6, CCurrencyBox)
	self.m_StrengthenBtn = self:NewUI(7, CButton)
	self.m_WarningL = self:NewUI(8, CLabel)
	self.m_SuccessTipL = self:NewUI(9, CLabel)
	self.m_SuccessRateL = self:NewUI(10, CLabel)
	self.m_CurAttrBox = self:NewUI(11, CBox)
	self.m_NextAttrBox = self:NewUI(12, CBox)
	self.m_TipL = self:NewUI(13, CLabel)
	self.m_BottomContentObj = self:NewUI(14, CObject)
	self.m_FailTipL = self:NewUI(15, CLabel)
	self.m_BgSpr = self:NewUI(16, CSprite)
	self.m_TipBtn = self:NewUI(17, CButton)
	self.m_EffectW = self:NewUI(18, CWidget)
	self.m_QuickBuyBox = self:NewUI(19, CQuickBuyBox)
	self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)
	self.m_OneKeyBtn = self:NewUI(20, CButton)
	self.m_PreviewBtn = self:NewUI(21, CButton)

	g_GuideCtrl:AddGuideUI("equip_qh_btn", self.m_StrengthenBtn)

	self.m_MaxType = {
		None = 0,
		PlayerLimit = 1,
		TableLimit = 2,
		BreakLimit = 3,
	}
	self.m_SelectedPos = -1
	self.m_StrengthLv = 0
	self.m_IsAutoSave = false
	self.m_BreakData = nil
	self.m_IsMaxLv = false
	self.m_LimitType = self.m_MaxType.None

	self:InitContent()
end

function CForgeStrengthenPart.InitContent(self)
	self.m_SilverBox:SetCurrencyType(define.Currency.Type.Silver)
	self.m_CostBox:SetCurrencyType(define.Currency.Type.Silver, true)

	self.m_BoxClone:SetActive(false)
	self.m_StrengthenBtn:AddUIEvent("click", callback(self, "RequestStrengthen"))
	self.m_OneKeyBtn:AddUIEvent("click", callback(self, "OneKeyStrengthen"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "ShowTipView"))
	self.m_PreviewBtn:AddUIEvent("click", callback(self, "OnShowEquipMaster"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))

	self:LoadSelectedId()
	self:InitItemBoxs()
	self:InitAttrBoxs(self.m_CurAttrBox)
	self:InitAttrBoxs(self.m_NextAttrBox)	
	self.m_BgSpr.m_OriginalW = self.m_BgSpr:GetWidth()
	self:InitQuickBuyBox()
end

function CForgeStrengthenPart.OnShowPage(self)
	self:RefreshEquipGrid()
end

function CForgeStrengthenPart.ChangeSelectId(self, iEquipPos)
	if not iEquipPos then
		return
	end
	self.m_SelectedPos = iEquipPos
	self:RefreshEquipGrid()
end

----------------------Otrl Event-----------------------------------------
function CForgeStrengthenPart.OnCtrlItemEvent(self, oCtrl)
	if not self:GetActive() then
		return
	end
	if oCtrl.m_EventID == define.Item.Event.RefreshStrength then
		self:RefreshSuccessRate()
	elseif oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshStrengthLv then
		local iCurLv = self.m_StrengthLv
		local dEquip = self.m_EquipList[self.m_SelectedPos]
		if dEquip then
			self:RefreshEquip(self.m_SelectedBox, dEquip)
			self:OnEquipSelect(self.m_SelectedBox)
		end
		self:RefreshItemsRedDot()
		-- 强化成功音效
		if oCtrl.m_EventID == define.Item.Event.RefreshStrengthLv then
			local iNewLv = g_ItemCtrl:GetStrengthenLv(self.m_SelectedPos)
			if iNewLv <= iCurLv then
				return
			end
			g_AudioCtrl:PlaySound(define.Audio.SoundPath.StrengSucc)
			if g_WarCtrl:IsWar() then
				g_NotifyCtrl:FloatMsg("战斗结束后生效")
			end
		end
	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		local oItem = oCtrl.m_EventData
		if self.m_UseItemBox.m_ItemSid and self.m_UseItemBox.m_ItemSid == oItem.m_SID then
			self:RefreshUseItem()
		end
	elseif oCtrl.m_EventID == define.Item.Event.ShowUIEffect then
		local dInfo = oCtrl.m_EventData
		if dInfo.effect == define.UIEffect.ForgeStrength then
			self:ShowSuccessEffect(dInfo.cmds)
		end
	end
end

---------------------UI init or refresh-----------------------------------
function CForgeStrengthenPart.InitItemBoxs(self)
	self.m_UseItemBox.m_ItemBox = self.m_UseItemBox:NewUI(1, CItemBaseBox)
	self.m_UseItemBox.m_AmountLabel = self.m_UseItemBox:NewUI(2, CLabel)
	self.m_UseItemBox.m_NameLabel = self.m_UseItemBox:NewUI(3, CLabel)
	self.m_UseItemBox.m_CountLabel = self.m_UseItemBox:NewUI(4, CLabel)


	self.m_EquipBox.m_IconSpr = self.m_EquipBox:NewUI(1, CSprite)
	local function OpenItemTip()
		if not self.m_EquipBox.m_Item then
			return
		end
		local oItem = g_ItemCtrl:GetEquipedByPos(self.m_SelectedPos)
		if oItem then
			CItemTipsView:ShowView(function(oView)
				oView:SetItem(oItem)
				oView:HideBtns()
			end)
		end
	end
	self.m_EquipBox.m_IconSpr:AddUIEvent("click", OpenItemTip)
end

function CForgeStrengthenPart.InitAttrBoxs(self, oBox)
	oBox.m_LvLabel = oBox:NewUI(1, CLabel)
	oBox.m_AttrTable = oBox:NewUI(2, CTable)
	oBox.m_EffcBoxCLone = oBox:NewUI(3, CBox) 
	oBox.m_EffcBoxCLone:SetActive(false)
	oBox.m_OriginalPos = oBox:GetLocalPos()
end

function CForgeStrengthenPart.InitQuickBuyBox(self)
	self.m_QuickBuyBox:SetInfo({
		id = define.QuickBuy.ForgeStrengthen,
		name = "便捷强化",
		offset = Vector3(-30,0,0),
	})
end

function CForgeStrengthenPart.RefreshCost(self)
	local iCost = self.m_StrengthLv * 500 + 100
	self.m_CostBox:SetCurrencyCount(iCost)
	self.m_SilverBox:SetWarningValue(iCost)
	self.m_QuickBuyBox:SetCurrencys({[1]={money_type = define.Currency.Type.Silver, price = iCost},})
end

function CForgeStrengthenPart.RefreshSuccessRate(self)
	local dInfo = g_ItemCtrl:GetStrengthInfo(self.m_SelectedPos)
	local sSuccessRatio = ""
	local iBaseRatio, iAddRatio = g_ItemCtrl:GetStrengthenSuccessRatio(self.m_SelectedPos)
	if iBaseRatio and iAddRatio > 0 then
		sSuccessRatio = string.format("%d%%+[c]#I%d%%#n", iBaseRatio, iAddRatio)
	else
		sSuccessRatio = string.format("%d%%", iBaseRatio)
	end
	self.m_SuccessRateL:SetText(sSuccessRatio)
end

function CForgeStrengthenPart.RefreshEquipGrid(self)
	if not self.m_EquipList then
		local iEquipLv = math.floor(g_AttrCtrl.grade/10)*10
		self.m_EquipList = DataTools.GetEquipListByLevel(g_AttrCtrl.roletype, g_AttrCtrl.school, g_AttrCtrl.sex, iEquipLv, nil, g_AttrCtrl.race)
		local function sort(d1, d2)
			return d1.equipPos < d2.equipPos
		end
		table.sort(self.m_EquipList, sort)
	end

	self.m_EquipGrid:Clear()
	local oSelectBox = nil
	for i, dEquip in ipairs(self.m_EquipList) do
		if dEquip.equipPos and dEquip.equipPos <= define.Equip.Pos.Shoes then
			local oBox = self:CreateEquip(dEquip)
			self.m_EquipGrid:AddChild(oBox)
			if (self.m_SelectedPos == -1 and i == 1) or 
				self.m_SelectedPos == dEquip.equipPos then
				oSelectBox = oBox
			end
		end
	end

	local bHasEquip = self.m_EquipGrid:GetCount() > 0
	self:ShowSpecialUI(bHasEquip)
	self:RefreshUseItem()
	self.m_EquipBox:SetActive(bHasEquip)
	if not oSelectBox then
		oSelectBox = self.m_EquipGrid:GetChild(1)
	end
	if oSelectBox then
		oSelectBox:SetSelected(true)
		self:OnEquipSelect(oSelectBox)
	else
		self.m_SelectedPos = -1
	end
	self:RefreshItemsRedDot()
end

function CForgeStrengthenPart.ShowSpecialUI(self, bHasEquip)
	self.m_WarningL:SetActive(not bHasEquip)
	self.m_BottomContentObj:SetActive(bHasEquip)
	self.m_CurAttrBox:SetActive(bHasEquip)
	self.m_NextAttrBox:SetActive(bHasEquip)
	self.m_SuccessTipL:SetActive(bHasEquip and self.m_LimitType == self.m_MaxType.None)
	self.m_FailTipL:SetActive(bHasEquip and self.m_LimitType == self.m_MaxType.None)
end

function CForgeStrengthenPart.CreateEquip(self, dEquip)
	local oBox = self.m_BoxClone:Clone()
	oBox.m_ItemBox = oBox:NewUI(1, CItemBaseBox)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_LvLabel = oBox:NewUI(3, CLabel)
	oBox.m_TypeLabel = oBox:NewUI(4, CLabel)
	oBox.m_StrengthLabel = oBox:NewUI(5, CLabel)
	oBox.m_SelectName = oBox:NewUI(6, CLabel)

	oBox:SetActive(true)
	self:RefreshEquip(oBox, dEquip)
	oBox:SetGroup(self.m_EquipGrid:GetInstanceID())
	oBox:AddUIEvent("click", callback(self, "OnEquipSelect", oBox))
	oBox.m_ItemBox:SetEnableTouch(false)
	oBox.m_IgnoreCheckEffect = true
	return oBox
end

function CForgeStrengthenPart.RefreshEquip(self, oBox, dEquip)
	if not oBox then
		return
	end
	-- printc("刷新装备")
	-- table.print(oItem)
	local bEquiped = g_ItemCtrl:GetEquipedByPos(dEquip.equipPos) ~= nil

	local oItem = CItem.CreateDefault(dEquip.id)
	oBox.m_ItemBox:SetBagItem(oItem)
	oBox.m_ItemBox:SetAmountText(0)
	oBox.m_ItemBox.m_IconSprite:SetGrey(not bEquiped)
	oBox.m_ItemBox.m_BorderSprite:SetActive(false)
	oBox.m_LvLabel:SetActive(false)

	oBox.m_CItem = oItem
	oBox.m_Pos = dEquip.equipPos
	oBox.m_StrengthLv = g_ItemCtrl:GetStrengthenLv(oBox.m_Pos)--oItem:GetStrengthLevel()
	local bIsStrength = oBox.m_StrengthLv ~= nil and oBox.m_StrengthLv > 0

	oBox.m_NameLabel:SetText(oItem:GetCValueByKey("partName"))
	oBox.m_SelectName:SetText(oItem:GetCValueByKey("partName"))
	-- oBox.m_LvLabel:SetText(oItem:GetItemEquipLevel().."级")
	-- oBox.m_TypeLabel:SetText(oItem:GetCValueByKey("partName")) --TODO:等改都表
	if bIsStrength then
		oBox.m_StrengthLabel:SetText(string.format("强化+%d", oBox.m_StrengthLv))
	end
	local func = function()
		-- CItemTipsView:ShowView(function(oView)
		-- 	oView:SetItem(oItem)
		-- 	oView:HideBtns()
		-- end)
	end
	oBox.m_ItemBox:SetClickCallback(func)
	oBox.m_StrengthLabel:SetActive(bIsStrength)
end

function CForgeStrengthenPart.RefreshEquipBox(self, cItem)
	self.m_EquipBox.m_IconSpr:SpriteItemShape(cItem:GetCValueByKey("icon"))
	self.m_EquipBox.m_Item = cItem
end

function CForgeStrengthenPart.RefreshUseItem(self)
	local tMaterialData = nil
	if self.m_LimitType == self.m_MaxType.BreakLimit then
		tMaterialData = self.m_BreakData
	else
		tMaterialData = DataTools.GetEquipStrengthMaterial(self.m_SelectedPos, self.m_StrengthLv + 1) 
	end
	self.m_UseItemBox:SetActive(true)
	if self.m_LimitType == self.m_MaxType.PlayerLimit or tMaterialData == nil then
		self.m_UseItemBox:SetActive(false)
		self.m_QuickBuyBox:SetItemsInfo(nil)
		return
	end

	self.m_UseItemBox.m_ItemSid = tMaterialData.sid
	local cItem = CItem.CreateDefault(tMaterialData.sid)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(tMaterialData.sid)

	self.m_UseItemBox.m_CountLabel:SetText("/" .. tMaterialData.amount)

	iAmount = iAmount + g_ItemCtrl:CalculateStrengthItemCnt(tMaterialData.sid)
	self.m_UseItemBox.m_ItemBox:SetBagItem(cItem)
	if iAmount == 0 or iAmount < tMaterialData.amount then
        self.m_UseItemBox.m_AmountLabel:SetText("[ffb398]"..iAmount)
        self.m_UseItemBox.m_AmountLabel:SetEffectColor(Color.RGBAToColor("cd0000"))
    else
        self.m_UseItemBox.m_AmountLabel:SetText("[0fff32]"..iAmount)
        self.m_UseItemBox.m_AmountLabel:SetEffectColor(Color.RGBAToColor("003C41"))
    end
	self.m_QuickBuyBox:SetItemsInfo({
		{id = tMaterialData.sid, cnt = tMaterialData.amount},
	})
	-- self.m_UseItemBox.m_AmountLabel:SetText(string.format("%s%d#n#I/%d\n可合成%d#n", sColor, iAmount, tMaterialData.amount,iComposeAmount))
	self.m_UseItemBox.m_NameLabel:SetText(cItem:GetItemName())
end

function CForgeStrengthenPart.RefreshUIByMaxType(self, iType)
	self.m_LimitType = iType
	local bIsTableLimit = iType == self.m_MaxType.TableLimit
	local bIsPlayerLimit = iType == self.m_MaxType.PlayerLimit
	local bIsBreakLimit = iType == self.m_MaxType.BreakLimit
	local bIsCommon = iType == self.m_MaxType.None

	self.m_SuccessTipL:SetActive(bIsCommon)
	self.m_FailTipL:SetActive(bIsCommon)
	self.m_TipL:SetActive(not bIsCommon)
	self.m_BottomContentObj:SetActive(not bIsTableLimit)
	self.m_NextAttrBox:SetActive(not bIsTableLimit and not bIsBreakLimit and not bIsPlayerLimit)

	local vPos = self.m_CurAttrBox.m_OriginalPos
	self.m_CurAttrBox:SetLocalPos(vPos)
	self.m_StrengthenBtn:SetText("强化")
	local iWidth = (not bIsCommon) and 430 or self.m_BgSpr.m_OriginalW
	self.m_BgSpr:SetWidth(iWidth)

	self.m_QuickBuyBox:SetName(bIsBreakLimit and "便捷突破" or "便捷强化")

	if bIsBreakLimit then
		self.m_CurAttrBox:SetLocalPos(Vector3.New(170, vPos.y, 0))
		self.m_TipL:SetText("已达强化瓶颈，突破后才可继续强化")
		self.m_StrengthenBtn:SetText("突破")
		self.m_StrengthenBtn:SetLocalPos(Vector3(258, -272, 0))
		self.m_OneKeyBtn:SetActive(false)
	else
		self.m_StrengthenBtn:SetText("强化")
		self.m_StrengthenBtn:SetLocalPos(Vector3(184, -272, 0))
		self.m_OneKeyBtn:SetActive(true)	
		if bIsTableLimit then
			self.m_CurAttrBox:SetLocalPos(Vector3.New(170, vPos.y, 0))
			self.m_TipL:SetText("已强化至满级")
		elseif bIsPlayerLimit then
			self.m_CurAttrBox:SetLocalPos(Vector3.New(170, vPos.y, 0))
			self.m_TipL:SetText("[c]#I已达当前最高级，请先提升玩家等级#n")
		end
	end

	self.m_OneKeyBtn:SetGrey(not self.m_IsEquiped)
	self.m_StrengthenBtn:SetGrey(not self.m_IsEquiped)
end

function CForgeStrengthenPart.RefreshAttrPanel(self)
	if self.m_SelectedPos <= 0 then
		return
	end
	local tAttrList = data.equipdata.EQUIP_ATTR[self.m_SelectedPos].attrList
	local tEffData = DataTools.GetEquipStrengthData(self.m_SelectedPos, self.m_StrengthLv) 
	local tNextEffData = DataTools.GetEquipStrengthData(self.m_SelectedPos, self.m_StrengthLv + 1) 

	if self.m_BreakData and self.m_BreakData.max_lv == self.m_StrengthLv then
		self:RefreshUIByMaxType(self.m_MaxType.BreakLimit)
	elseif self.m_StrengthLv == g_AttrCtrl.grade and tNextEffData ~= nil then
		self:RefreshUIByMaxType(self.m_MaxType.PlayerLimit)
	elseif tNextEffData == nil then
		self:RefreshUIByMaxType(self.m_MaxType.TableLimit)
	else
		self:RefreshUIByMaxType(self.m_MaxType.None)
	end

	self:RefreshAttrBox(self.m_CurAttrBox, tAttrList, tEffData, self.m_StrengthLv)
	self:RefreshAttrBox(self.m_NextAttrBox, tAttrList, tNextEffData, self.m_StrengthLv + 1)
end

function CForgeStrengthenPart.RefreshAttrBox(self, oBox, tAttrList, tEffData, iStengthLv)
	oBox.m_AttrTable:Clear()
	oBox.m_LvLabel:SetText("+"..tostring(iStengthLv))
	for k,v in pairs(tAttrList) do
		if tEffData and tEffData[v] then
		   local oEffcBox = self:CreateEffectBox(oBox.m_EffcBoxCLone, v, tEffData)
		   oBox.m_AttrTable:AddChild(oEffcBox)
		end
	end
end

function CForgeStrengthenPart.CreateEffectBox(self, oCloneBox, sAttr, tEffData)
	local oBox = oCloneBox:Clone()
	oBox:SetActive(true)
	oBox.m_AttrNameL = oBox:NewUI(1, CLabel)
	oBox.m_CurEffL = oBox:NewUI(2, CLabel)

	local sAttrName = data.attrnamedata.DATA[sAttr].name

	oBox.m_AttrNameL:SetText(sAttrName)

	if tEffData then
		oBox.m_CurEffL:SetText(tostring(tEffData[sAttr]))
	else
		oBox.m_CurEffL:SetText("0")
	end
	return oBox
end

function CForgeStrengthenPart.ShowSuccessEffect(self, lCmd)
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
	self.m_EffectW:AddEffect("Screen", "ui_eff_0062")
end

function CForgeStrengthenPart.RefreshItemsRedDot(self)
	local childList = self.m_EquipGrid:GetChildList()
	for i, oBox in ipairs(childList) do
		local oItem = oBox.m_CItem
		if self:JudgeStrengthen(oItem) then
			oBox:AddEffect("RedDot", 20, Vector2(-15,-25))
		else
			oBox:DelEffect("RedDot")
		end
	end
end

-----------------------UI click event--------------------------------
function CForgeStrengthenPart.OnEquipSelect(self, oBox)
	if not oBox then
		return
	end
	self.m_SelectedPos = oBox.m_Pos
	self.m_SelectedBox = oBox
	self.m_StrengthLv = g_ItemCtrl:GetStrengthenLv(oBox.m_Pos)--oBox.m_CItem:GetStrengthLevel()
	self.m_BreakData = DataTools.GetEquipStrengthBreak(oBox.m_Pos, g_ItemCtrl:GetStrengthenBreakLv(oBox.m_Pos))
	self.m_IsEquiped = g_ItemCtrl:GetEquipedByPos(self.m_SelectedPos) ~= nil
	-- printc("OnEquipSelect")
	-- table.print(self.m_BreakData)
	-- printc("选中强化等级："..self.m_StrengthLv)
	-- local iEquipPos = oBox.m_CItem:GetCValueByKey("equipPos")
	-- netitem.C2GSStrengthInfo(iEquipPos)

	self:RefreshEquipBox(oBox.m_CItem)
	self:RefreshAttrPanel()
	self:RefreshUseItem()
	self:RefreshCost()
	self:RefreshSuccessRate()
end

function CForgeStrengthenPart.RequestStrengthen(self)
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.Forge, 2) then
		-- g_NotifyCtrl:FloatMsg("点击太频繁，请稍后再试")
		return
	end
	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.Forge, 2, 0.33)

	if not self.m_IsEquiped then
		g_NotifyCtrl:FloatMsg("请先穿戴装备")
		return
	end

	if self.m_SelectedPos <= 0 or self.m_SelectedPos > define.Equip.Pos.Shoes then
		g_NotifyCtrl:FloatMsg("请先选择装备")
		return
	end
	local bQuick = self.m_QuickBuyBox:IsSelected()
	if bQuick then
		if not self.m_QuickBuyBox:CheckCostEnough() then
			return
		end
	else
		self:JudgeLackList()
		if g_QuickGetCtrl.m_IsLackItem then
			return
		end
	end
	if self.m_LimitType == self.m_MaxType.BreakLimit then
		netitem.C2GSEquipBreak(self.m_SelectedPos, bQuick and 1 or 0)
	else
		netitem.C2GSEquipStrength(self.m_SelectedPos, bQuick and 1 or 0)
	end
	self:SaveSelectedId()
	-- 强化音效（暂时去掉）
	-- g_AudioCtrl:PlaySound(define.Audio.SoundPath.StrengPros)
end

function CForgeStrengthenPart.OneKeyStrengthen(self)
	if self.m_LimitType == self.m_MaxType.BreakLimit then
		return
	end
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.Forge, 2) then
		return
	end
	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.Forge, 2, 0.33)

	if not self.m_IsEquiped then
		g_NotifyCtrl:FloatMsg("请先穿戴装备")
		return
	end
	
	if self.m_SelectedPos <= 0 or self.m_SelectedPos > define.Equip.Pos.Shoes then
		g_NotifyCtrl:FloatMsg("请先选择装备")
		return
	end
	local bQuick = self.m_QuickBuyBox:IsSelected()
	if not bQuick then
		self:JudgeLackList(true)
		if g_QuickGetCtrl.m_IsLackItem then
			return
		end
	end
	netitem.C2GSEquipStrength(self.m_SelectedPos, bQuick and 1 or 0, 1)
	self:SaveSelectedId()
end

function CForgeStrengthenPart.ShowTipView(self)
	local id = define.Instruction.Config.ForgeStrength
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CForgeStrengthenPart.OnShowEquipMaster(self)
	CItemSetAttrView:ShowView(function(oView)
		oView:HideButton()
	end)
end

-----------------------other help-------------------------------
function CForgeStrengthenPart.SaveSelectedId(self)
	if not self.m_IsAutoSave then
		return
	end
	IOTools.SetClientData(string.format("forge_strength_%d", g_AttrCtrl.pid), self.m_SelectedPos)
end

function CForgeStrengthenPart.LoadSelectedId(self)
	self.m_IsAutoSave = true
	self.m_SelectedPos = IOTools.GetClientData(string.format("forge_strength_%d", g_AttrCtrl.pid)) or -1
end

function CForgeStrengthenPart.JudgeLackList(self, bOneKey)
	local data = nil
	if self.m_LimitType == self.m_MaxType.BreakLimit then
		data = self.m_BreakData
	else
		data = DataTools.GetEquipStrengthMaterial(self.m_SelectedPos, self.m_StrengthLv + 1) 
	end
	local iSum = g_ItemCtrl:GetBagItemAmountBySid(data.sid)
	iSum = iSum + g_ItemCtrl:CalculateStrengthItemCnt(data.sid)
	local itemlist = {}
	if iSum < data.amount then
		local t  = {sid = data.sid, count = iSum, amount = data.amount}
		table.insert(itemlist, t)
	end
	local coinlist = {}
	local iCost = self.m_StrengthLv * 500 + 100
	-- if g_AttrCtrl.silver < iCost then
		local t = {sid = 1002, count = g_AttrCtrl.silver, amount = iCost}
		table.insert(coinlist, t)
	-- end
	g_QuickGetCtrl:CurrLackItemInfo(itemlist, coinlist, nil, function()
		if self.m_LimitType == self.m_MaxType.BreakLimit then
			netitem.C2GSEquipBreak(self.m_SelectedPos, 1)
		else
			netitem.C2GSEquipStrength(self.m_SelectedPos, 1, bOneKey and 1 or 0)
		end
	end)
end

function CForgeStrengthenPart.JudgeStrengthen(self, oItem)
	if not oItem then
		return false
	end
	local pos = oItem:GetCValueByKey("equipPos")
    local iStrengthLv = g_ItemCtrl:GetStrengthenLv(pos)
    local iSilverCost = iStrengthLv * 500 + 100
    if iStrengthLv < g_AttrCtrl.grade and iSilverCost <= g_AttrCtrl.silver then
        local dBreakData = DataTools.GetEquipStrengthBreak(pos, g_ItemCtrl:GetStrengthenBreakLv(pos))
        local dNextEffData = DataTools.GetEquipStrengthData(pos, iStrengthLv + 1)
        local bIsMax = dBreakData.max_lv == iStrengthLv or not dNextEffData
        if not bIsMax then
            local dMaterialData = DataTools.GetEquipStrengthMaterial(pos, iStrengthLv + 1)
            if dMaterialData then
                local iAmount = g_ItemCtrl:GetBagItemAmountBySid(dMaterialData.sid)
                iAmount = iAmount + g_ItemCtrl:CalculateStrengthItemCnt(dMaterialData.sid)
                if iAmount >= dMaterialData.amount then
                    return true
                end
            end
        end
    end
    return false
end

return CForgeStrengthenPart
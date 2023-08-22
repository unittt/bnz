local CPartnerEquipUpgradeView = class("CPartnerEquipUpgradeView", CViewBase)

function CPartnerEquipUpgradeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerEquipUpgradeView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	-- printerror("item tips view --------------------- ")
end

function CPartnerEquipUpgradeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TitleL = self:NewUI(2, CLabel)
	self.m_EquipAttrBoxL = self:NewUI(3, CBox)
	self.m_EquipAttrBoxR = self:NewUI(4, CBox)
	self.m_UpgradeBtn = self:NewUI(5, CButton)
	self.m_CostCurrencyBox = self:NewUI(6, CCurrencyBox)
	self.m_OwnCurrencyBox = self:NewUI(7, CCurrencyBox)
	self.m_CostItemBox = self:NewUI(8, CBox)
	self.m_LimitTipsL = self:NewUI(9, CLabel)
	self.m_OneKeyUpgradeBtn = self:NewUI(10, CButton)
    self.m_QuickBuyBox = self:NewUI(11, CQuickBuyBox)
    self.m_QuickBuyObj = self:NewUI(12, CObject)
    self.m_NextEquipBtn = self:NewUI(13, CButton)
    self.m_PreEquipBtn = self:NewUI(14, CButton) 

	self.m_SilverCost = 0
	self.m_ItemCost = 0
	self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)
	self.m_QuickBuyBox:SetInfo({
		id = define.QuickBuy.PartnerEquipUpgrade,
		name = "便捷购买",
		offset = Vector3(-40,0,0),
	})
	self:InitContent()
end

function CPartnerEquipUpgradeView.InitContent(self)
	self:InitAttrBox(self.m_EquipAttrBoxL)
	self:InitAttrBox(self.m_EquipAttrBoxR)
	self:InitCostBox()

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnClickUpgrade"))
	self.m_OneKeyUpgradeBtn:AddUIEvent("click", callback(self, "OnClickOnekeyUpgrade"))
	self.m_NextEquipBtn:AddUIEvent("click", callback(self, "ChangeEquip", 1))
	self.m_PreEquipBtn:AddUIEvent("click", callback(self, "ChangeEquip", -1))

	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end

function CPartnerEquipUpgradeView.InitAttrBox(self, oBox)
	oBox.m_ItemIconSpr = oBox:NewUI(1, CSprite)
	oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
	oBox.m_NameL = oBox:NewUI(3, CLabel)
	oBox.m_EquipPosL = oBox:NewUI(4, CLabel)
	oBox.m_AttrTable = oBox:NewUI(5, CTable)
	oBox.m_AttrBoxClone = oBox:NewUI(6, CBox)
	oBox.m_EquipLvL = oBox:NewUI(7, CLabel)
end

function CPartnerEquipUpgradeView.InitCostBox(self)
	self.m_CostCurrencyBox:SetCurrencyType(define.Currency.Type.Silver, true)
	self.m_OwnCurrencyBox:SetCurrencyType(define.Currency.Type.Silver)

	local oBox = self.m_CostItemBox
	oBox.m_ItemBox = oBox:NewUI(1, CItemBaseBox)
	oBox.m_AmountL = oBox:NewUI(2, CLabel)
	oBox.m_NameL = oBox:NewUI(3, CLabel)
end

function CPartnerEquipUpgradeView.SetEquipInfo(self, dPartnerInfo, bIsStrength, iEquipPos)
	self.m_PartnerInfo = dPartnerInfo
	self.m_CurEquipPos = iEquipPos
	self.m_PartnerId = dPartnerInfo.id
	self.m_EquipInfo = self.m_PartnerInfo.equipsid[self.m_CurEquipPos]
	self.m_EquipData = DataTools.GetPartnerEquipData(self.m_EquipInfo.equip_sid)
	self.m_IsStrengthMode = bIsStrength

	local iBuyId = bIsStrength and define.QuickBuy.PartnerEquipStrength or define.QuickBuy.PartnerEquipUpgrade
	self.m_QuickBuyBox:SetInfo({
		id = iBuyId,
		name = "便捷购买",
		offset = Vector3(-40,0,0),
	})
	self:RefreshAll()
end

function CPartnerEquipUpgradeView.OnPartnerCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.PropChange then
		local dInfo = g_PartnerCtrl:GetRecruitPartnerDataByID(self.m_PartnerInfo.sid)
		self:SetEquipInfo(dInfo, self.m_IsStrengthMode, self.m_CurEquipPos)
	end
end

function CPartnerEquipUpgradeView.OnItemCtrlEvent(self ,oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		if not self.m_IsStrengthMode then
			self:RefreshCost()
		end
	end
end
------------------------------UI refresh---------------------------------------
function CPartnerEquipUpgradeView.RefreshAll(self)
	local iNextLevel = self.m_IsStrengthMode and self.m_EquipInfo.level or self.m_EquipInfo.level + 10
	local iNextStrength = self.m_IsStrengthMode and self.m_EquipInfo.strength + 1 or self.m_EquipInfo.strength
	self:RefreshEquipAttrBox(self.m_EquipAttrBoxR, iNextLevel, iNextStrength)
	self:RefreshEquipAttrBox(self.m_EquipAttrBoxL, self.m_EquipInfo.level, self.m_EquipInfo.strength)
	self:RefreshCost()
	self:RefreshTitle()
	self:RefreshBtnStatus()
end

function CPartnerEquipUpgradeView.RefreshTitle(self)
	local sTitle = self.m_IsStrengthMode and "装备强化" or "装备升级"
	self.m_TitleL:SetText(sTitle)

	local sBtnText = self.m_IsStrengthMode and "强化" or "升级"
	self.m_UpgradeBtn:SetText(sBtnText)
end

function CPartnerEquipUpgradeView.RefreshEquipAttrBox(self, oAttrBox, iLevel, iStrengthen)
	self:RefreshEquipBaseInfo(oAttrBox, iLevel, iStrengthen)
	self:RefreshEquipAttr(oAttrBox, iLevel, iStrengthen)
end

function CPartnerEquipUpgradeView.RefreshEquipBaseInfo(self, oAttrBox, iLevel, iStrengthen)
	--TODO:等正式图标
	local iItemIcon = DataTools.GetPartnerEquipIcon(self.m_EquipInfo.equip_sid, iLevel)
	local iPos = self.m_EquipInfo.equip_sid%100
	local sName = self.m_EquipData.equip_name
	if iStrengthen and iStrengthen > 0 then
		sName = sName.." [c]#I+"..iStrengthen
	end

	oAttrBox.m_NameL:SetText(sName)
	oAttrBox.m_ItemIconSpr:SpriteItemShape(iItemIcon)
	oAttrBox.m_QualitySpr:SetItemQuality(0)
	oAttrBox.m_EquipPosL:SetText(define.Equip.PosName[iPos])
	oAttrBox.m_EquipLvL:SetText(iLevel.."级")
end

function CPartnerEquipUpgradeView.RefreshEquipAttr(self, oAttrBox, iLevel, iStrengthen)
	oAttrBox.m_AttrTable:Clear()
	self:CreateEquipGradeAttr(oAttrBox, iLevel)
	self:CreateEquipStrenthenAttr(oAttrBox, iStrengthen)
end

function CPartnerEquipUpgradeView.CreateEquipGradeAttr(self, oAttrBox, iLevel)
	if self.m_IsStrengthMode then
		return
	end
	local dUpgradeData = DataTools.GetPartnerEquipUpgradeInfo(iLevel, self.m_EquipInfo.equip_sid)
	if not dUpgradeData then
		return
	end

	local sDesc = "[a64300]基本属性[-]"
	local oBox = self:CreateAttr(oAttrBox.m_AttrBoxClone, sDesc)
	oAttrBox.m_AttrTable:AddChild(oBox)
	for k,v in pairs(dUpgradeData) do
		local sAttr = data.attrnamedata.DATA[k].name
		local iAttrValue = math.floor(v)
		oBox = self:CreateAttr(oAttrBox.m_AttrBoxClone, "  [244B4E]"..sAttr, "[244B4E]+"..iAttrValue)
		oAttrBox.m_AttrTable:AddChild(oBox)
	end
end

function CPartnerEquipUpgradeView.CreateEquipStrenthenAttr(self, oAttrBox, iStrengthen)
	if not self.m_IsStrengthMode then
		return
	end
	local dStrengthData = DataTools.GetPartnerEquipStrengthInfo(iStrengthen, self.m_EquipInfo.equip_sid)
	if not dStrengthData then
		return
	end

	local sDesc = "[1d8e00]附加属性[-]"
	local oBox = self:CreateAttr(oAttrBox.m_AttrBoxClone, sDesc)
	oAttrBox.m_AttrTable:AddChild(oBox)
	for k,v in pairs(dStrengthData) do
		local sAttr = data.attrnamedata.DATA[k].name
		local iAttrValue = math.floor(v)
		oBox = self:CreateAttr(oAttrBox.m_AttrBoxClone,"  [244B4E]"..sAttr, "[244B4E]+"..iAttrValue)
		oAttrBox.m_AttrTable:AddChild(oBox)
	end
end

function CPartnerEquipUpgradeView.CreateAttr(self, oCloneBox, sAttrName, sAttrValue)
	local oBox = oCloneBox:Clone()
	oBox.m_AttrL = oBox:NewUI(1, CLabel)
	oBox.m_ValueL = oBox:NewUI(2, CLabel)
	oBox:SetActive(true)

	oBox.m_AttrL:SetActive(sAttrName ~= nil)
	oBox.m_ValueL:SetActive(sAttrValue ~= nil)

	oBox.m_AttrL:SetText(sAttrName)
	oBox.m_ValueL:SetText(sAttrValue)

	return oBox
end

function CPartnerEquipUpgradeView.RefreshCost(self)
	self.m_CostItemBox:SetActive(not self.m_IsStrengthMode)
	self.m_CostCurrencyBox:SetActive(self.m_IsStrengthMode)
	self.m_OwnCurrencyBox:SetActive(self.m_IsStrengthMode)

	if self.m_IsStrengthMode then
		local dStrengthCost = data.partnerdata.STRENGTH_COST[self.m_EquipInfo.strength + 1]
		self.m_SilverCost = dStrengthCost and dStrengthCost.strength_silver or 0

		self.m_CostCurrencyBox:SetCurrencyCount(self.m_SilverCost)
		self.m_OwnCurrencyBox:SetWarningValue(self.m_SilverCost)
	else
		local dUpgradeCost = data.partnerdata.UPGRADE_COST[self.m_EquipInfo.level + 10]
		self.m_ItemCost = dUpgradeCost and dUpgradeCost.upgrade_cost_amount or 0

		local iItemId = self.m_EquipData.upgrade_cost_sid
		local oItem = CItem.CreateDefault(iItemId)
		local iSum = g_ItemCtrl:GetBagItemAmountBySid(iItemId)

		self.m_CostItemName = oItem:GetCValueByKey("name")
		self.m_CostItemBox.m_ItemBox:SetBagItem(oItem)
		self.m_CostItemBox.m_NameL:SetText(self.m_CostItemName)
		self.m_IsEnoughItem = iSum >= self.m_ItemCost
		if iSum == 0 or iSum < self.m_ItemCost then
			self.m_CostItemBox.m_AmountL:SetText(string.format("[c]#R%d#n[/c]/%d", iSum, self.m_ItemCost))
		else
			self.m_CostItemBox.m_AmountL:SetText(string.format("%d/%d", iSum, self.m_ItemCost))
		end
		self.m_QuickBuyBox:SetItemsInfo({{id = iItemId, cnt = self.m_ItemCost},})
	end
end

function CPartnerEquipUpgradeView.RefreshBtnStatus(self)
	local dText = data.partnerdata.TEXT
	if self.m_IsStrengthMode then
		self.m_TableLimit = not data.partnerdata.STRENGTH_COST[self.m_EquipInfo.strength + 1]
		self.m_GradeLimit =	self.m_PartnerInfo.grade <= self.m_EquipInfo.strength
		if self.m_GradeLimit then
			self.m_LimitTipsL:SetText(dText[2014].content)
		else
			self.m_LimitTipsL:SetText(dText[2013].content)
		end
	else
		self.m_TableLimit = not data.partnerdata.UPGRADE_COST[self.m_EquipInfo.level + 10]
		self.m_GradeLimit =	self.m_PartnerInfo.grade < self.m_EquipInfo.level + 10
		if self.m_GradeLimit then
			self.m_LimitTipsL:SetText(dText[2014].content)
		else
			self.m_LimitTipsL:SetText(dText[2012].content)
		end
	end
	local bShow = not self.m_TableLimit and not self.m_GradeLimit
	self.m_UpgradeBtn:SetActive(bShow)
	self.m_OneKeyUpgradeBtn:SetActive(bShow and self.m_IsStrengthMode)
	self.m_EquipAttrBoxR:SetActive(bShow)
	self.m_LimitTipsL:SetActive(not bShow)
	self.m_QuickBuyObj:SetActive(bShow and not self.m_IsStrengthMode)
end

function CPartnerEquipUpgradeView.ChangeEquip(self, iChangeValue)
	self.m_CurEquipPos = (self.m_CurEquipPos + iChangeValue)%7
	self.m_CurEquipPos = self.m_CurEquipPos == 0 and iChangeValue < 0 and 6 or math.max(1, self.m_CurEquipPos)
	self:SetEquipInfo(self.m_PartnerInfo, self.m_IsStrengthMode, self.m_CurEquipPos)
end

function CPartnerEquipUpgradeView.OnClickUpgrade(self)
	if self.m_IsStrengthMode then
		self:OnClickStrengthen()
		return
	end
	if self.m_PartnerInfo.grade < self.m_EquipInfo.level + 10 then
		g_NotifyCtrl:FloatMsg("装备等级不能大于伙伴等级")
		return
	end
	local bQuickBuy = self.m_QuickBuyBox:IsSelected()
	if not bQuickBuy then
		self:JudgeLackList()
		if g_QuickGetCtrl.m_IsLackItem then
			return
		end
	elseif not self.m_QuickBuyBox:CheckCostEnough() then
		return
	end

	-- if not self.m_IsEnoughItem then
	-- 	g_NotifyCtrl:FloatMsg(self.m_CostItemName.."不足")
	-- 	return
	-- end
	netpartner.C2GSUpgradePartnerEquip(self.m_PartnerId, self.m_EquipInfo.equip_sid, bQuickBuy and 1 or 0)
end

function CPartnerEquipUpgradeView.OnClickOnekeyUpgrade(self)
	if self.m_IsStrengthMode then
		self:OnClickOneKeyStrengthen()
		return
	end
end

function CPartnerEquipUpgradeView.OnClickStrengthen(self)
	if self.m_PartnerInfo.grade <= self.m_EquipInfo.strength then
		g_NotifyCtrl:FloatMsg("装备强化等级不能大于伙伴等级")
		return
	end
	if self.m_SilverCost > g_AttrCtrl.silver then
		-- g_NotifyCtrl:FloatMsg("银币不足")
        g_QuickGetCtrl:CheckLackItemInfo({
            coinlist = {{sid = 1002, amount = self.m_SilverCost, count = g_AttrCtrl.silver}},
            exchangeCb = function()
                netpartner.C2GSStrengthPartnerEquip(self.m_PartnerId, self.m_EquipInfo.equip_sid)
            end
        })
		return
	end
	netpartner.C2GSStrengthPartnerEquip(self.m_PartnerId, self.m_EquipInfo.equip_sid)
end

function CPartnerEquipUpgradeView.OnClickOneKeyStrengthen(self)
	if self.m_PartnerInfo.grade <= self.m_EquipInfo.strength then
		g_NotifyCtrl:FloatMsg("装备强化等级不能大于伙伴等级")
		return
	end
	if self.m_SilverCost > g_AttrCtrl.silver then
		-- g_NotifyCtrl:FloatMsg("银币不足")
        g_QuickGetCtrl:CheckLackItemInfo({
            coinlist = {{sid = 1002, amount = self.m_SilverCost, count = g_AttrCtrl.silver}},
            exchangeCb = function()
                netpartner.C2GSStrengthPartnerEquip(self.m_PartnerId, self.m_EquipInfo.equip_sid, 1)
            end
        })
        return
	end
	netpartner.C2GSStrengthPartnerEquip(self.m_PartnerId, self.m_EquipInfo.equip_sid, 1)
end

function CPartnerEquipUpgradeView.JudgeLackList(self)
	local itemlist = {}
	local coinlist = {}
	local iSum = g_ItemCtrl:GetBagItemAmountBySid(self.m_EquipData.upgrade_cost_sid)
	if iSum < self.m_ItemCost then
		local t = {sid = self.m_EquipData.upgrade_cost_sid, count = iSum, amount = self.m_ItemCost}
		table.insert(itemlist, t)
	end
	g_QuickGetCtrl:CurrLackItemInfo(itemlist, coinlist, nil, function()
		netpartner.C2GSUpgradePartnerEquip(self.m_PartnerId, self.m_EquipInfo.equip_sid,1)
	end)
end

return CPartnerEquipUpgradeView
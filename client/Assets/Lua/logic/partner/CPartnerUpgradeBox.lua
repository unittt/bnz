local CPartnerUpgradeBox = class("CPartnerUpgradeBox", CBox)

function CPartnerUpgradeBox.ctor(self, obj, oView)
	CBox.ctor(self, obj)

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CostItemGrid = self:NewUI(2, CGrid)
	self.m_CostItemBoxClone = self:NewUI(3, CBox)
	self.m_CurPartnerBox = self:NewUI(4, CBox)
	self.m_NextPartnerBox = self:NewUI(5, CBox)
	self.m_ProtectSkillSpr = self:NewUI(6, CSprite)
	self.m_UpgradeBtn = self:NewUI(7, CButton)
	self.m_UpgradeNode = self:NewUI(8, CObject)
	self.m_MaxL = self:NewUI(9, CLabel)
	self.m_GradeLimitL = self:NewUI(10, CLabel)
	self.m_QuickBuyBox = self:NewUI(11, CQuickBuyBox)
	self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)

	self.m_CostItemBoxClone:SetActive(false)

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "SetActive", false), oView)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "SetActive", false))
	self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnClickUpgrade"))

	self:InitPartnerBox(self.m_CurPartnerBox)
	self:InitPartnerBox(self.m_NextPartnerBox)
	self.m_QuickBuyBox:SetInfo({
		id = define.QuickBuy.PartnerUpgrade,
		name = "便捷购买",
		offset = Vector3(-40,0,0),
	})
end

function CPartnerUpgradeBox.InitPartnerBox(self, oBox)
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_GradeL = oBox:NewUI(2, CLabel)
	oBox.m_StarGrid = oBox:NewUI(3, CGrid)
	oBox.m_StarSprClone = oBox:NewUI(4, CSprite)
	oBox.m_OriginalPos = oBox:GetLocalPos()
end

function CPartnerUpgradeBox.RefreshAll(self)
	self.m_PartnerInfo = CPartnerMainView:GetView():GetPartnerBoxNodeInfo()
	self.m_PartnerSData = g_PartnerCtrl:GetRecruitPartnerDataByID(self.m_PartnerInfo.id)

	local dInfo = DataTools.GetPartnerQualityInfo(self.m_PartnerSData.quality + 1)	
 	self.m_IsMaxStar = dInfo == nil

 	self:RefreshMaxStatus()
	self:RefreshCostItemGrid()
	self:RefreshProtectSkill()
	self:RefreshGradeLimitLabel()
	self:RefreshPartnerBox(self.m_CurPartnerBox, self.m_PartnerSData.quality)
	self:RefreshPartnerBox(self.m_NextPartnerBox, self.m_PartnerSData.quality + 1)
end

function CPartnerUpgradeBox.RefreshGradeLimitLabel(self)
	local qualityInfo = DataTools.GetPartnerQualityInfo(self.m_PartnerSData.quality)	
	if qualityInfo then
		self.m_GradeLimitL:SetText("进阶等级："..qualityInfo.level)
	end
end

function CPartnerUpgradeBox.RefreshMaxStatus(self)
	self.m_MaxL:SetActive(self.m_IsMaxStar)
	self.m_UpgradeNode:SetActive(not self.m_IsMaxStar)
end

function CPartnerUpgradeBox.RefreshCostItemGrid(self)
	if self.m_IsMaxStar then
		self.m_QuickBuyBox:SetItemsInfo(nil)
		return
	end
	local cultureItemInfo = g_PartnerCtrl:GetPartnerCultureItemInfo(self.m_PartnerInfo.id, 3)
	self.m_ItemList = cultureItemInfo.itemList	
	local itemBoxList = self.m_CostItemGrid:GetChildList()
	local items = {}
	for i,v in ipairs(self.m_ItemList) do
		local oCostItemBox = nil
		if i > #itemBoxList then
			oCostItemBox = self:AddCostItemBox()
		else
			oCostItemBox = itemBoxList[i]
		end
		self:UpdateCostItemBox(oCostItemBox, v)
		table.insert(items, {id = v.info.id, cnt = v.cost})
	end
	self.m_QuickBuyBox:SetItemsInfo(items, true)
end

function CPartnerUpgradeBox.AddCostItemBox(self)
	local oBox = self.m_CostItemBoxClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_AmountL = oBox:NewUI(2, CLabel)
	oBox.m_QualitySpr = oBox:NewUI(3, CSprite)

	self.m_CostItemGrid:AddChild(oBox)
	return oBox
end

function CPartnerUpgradeBox.UpdateCostItemBox(self, oBox, dInfo)
	oBox:SetActive(true)
	oBox.m_IconSpr:SpriteItemShape(dInfo.info.icon)
	oBox.m_QualitySpr:SetItemQuality(dInfo.info.quality)
	if dInfo.amount < dInfo.cost then
		oBox.m_AmountL:SetText(string.format("[c]#R%d#n[/c]/%d", dInfo.amount, dInfo.cost))
	else
		oBox.m_AmountL:SetText(dInfo.amount.."/"..dInfo.cost)
	end
	oBox.m_IconSpr:AddUIEvent("click", function ()
		g_WindowTipCtrl:SetWindowGainItemTip(dInfo.info.id)
	end)
end

function CPartnerUpgradeBox.RefreshProtectSkill(self)
	local dSkill = g_PartnerCtrl:GetPartnerProtectSkill(self.m_PartnerInfo.id)
	local skillInfo = DataTools.GetPartnerSpecialSkill(dSkill.sk)
	self.m_ProtectSkillSpr:SpriteSkill(skillInfo.icon)
	self.m_ProtectSkillSpr:AddUIEvent("click", function ()
		local dConfig = table.copy(skillInfo)
		dConfig.widget = self.m_ProtectSkillSpr
		g_WindowTipCtrl:SetWindowSkillTip(dConfig)
	end)
end

function CPartnerUpgradeBox.RefreshPartnerBox(self, oBox, iStar)
	if self.m_IsMaxStar then
		local dInfo = DataTools.GetPartnerQualityInfo(iStar)
		if dInfo then
			local vPos = oBox.m_OriginalPos 
			oBox:SetLocalPos(Vector3.New(-10.5, vPos.y, 0)) 
		else
			return
		end
	else
		oBox:SetLocalPos(oBox.m_OriginalPos)
	end
	local shape = self.m_PartnerInfo.shape
	oBox.m_IconSpr:SpriteAvatar(shape)
	oBox.m_GradeL:SetText(self.m_PartnerSData.grade)

	local iStarCnt = math.min(iStar, 5)
	local starBoxList = oBox.m_StarGrid:GetChildList()
	local oStarSpr = nil
	for i=1,5 do
		if i > #starBoxList then
			oStarSpr = oBox.m_StarSprClone:Clone()
			oBox.m_StarGrid:AddChild(oStarSpr)
			oStarSpr:SetActive(true)
		else
			oStarSpr = starBoxList[i]
		end
		oStarSpr:SetGrey(i > iStarCnt)
	end
end

function CPartnerUpgradeBox.OnClickUpgrade(self)
	local qualityInfo = DataTools.GetPartnerQualityInfo(self.m_PartnerSData.quality)	
	if self.m_PartnerSData.grade < qualityInfo.level then
		local tipStr = string.gsub(DataTools.GetPartnerTextInfo(1014).content, "#level", qualityInfo.level)
		g_NotifyCtrl:FloatMsg(tipStr)
		return
	end
	local bQuickSel = self.m_QuickBuyBox:IsSelected()
	if bQuickSel then
		if not self.m_QuickBuyBox:CheckCostEnough() then
			return
		end
	else
		self:JudgeLackInfo()
		if g_QuickGetCtrl.m_IsLackItem then
			return
		end
	end
	-- for _,v in ipairs(self.m_ItemList) do
	-- 	if v.cost > v.amount then
	-- 		local tipStr = string.gsub(DataTools.GetPartnerTextInfo(1006).content, "#item", v.info.name)
	-- 		g_NotifyCtrl:FloatMsg(tipStr)
	-- 		return
	-- 	end
	-- end

	netpartner.C2GSUpgradeQuality(self.m_PartnerSData.id, bQuickSel and 1 or 0)
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗结束后生效")
	end
end

function CPartnerUpgradeBox.JudgeLackInfo(self)
	local itemlist = {}
	for i,v in ipairs(self.m_ItemList) do
	 	if v.amount < v.cost then
	 		local t  = {sid = v.info.id, count = v.amount, amount = v.cost }
	 		table.insert(itemlist, t)
	 	end
	end
	g_QuickGetCtrl:CurrLackItemInfo(itemlist,{}, nil, function()
		netpartner.C2GSUpgradeQuality(self.m_PartnerSData.id, 1)
		if g_WarCtrl:IsWar() then
			g_NotifyCtrl:FloatMsg("战斗结束后生效")
		end
	end)
end

return CPartnerUpgradeBox
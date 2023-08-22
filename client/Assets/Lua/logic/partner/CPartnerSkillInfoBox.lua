local CPartnerSkillInfoBox = class("CPartnerSkillInfoBox", CBox)

function CPartnerSkillInfoBox.ctor(self, obj, oView)
	CBox.ctor(self, obj)

	-- self.m_Content = self:NewUI(1, CSprite)
	self.m_SkillIcon = self:NewUI(2, CSprite)
	self.m_SkillName = self:NewUI(3, CLabel)
	self.m_SkillLv = self:NewUI(4, CLabel)
	self.m_CurDesc = self:NewUI(5, CLabel)
	self.m_NextDesc = self:NewUI(6, CLabel)
	self.m_Grade = self:NewUI(7, CLabel)
	self.m_ItemBox = self:NewUI(8, CBox)
	self.m_ItemIcon = self:NewUI(9, CSprite)
	self.m_ItemName = self:NewUI(10, CLabel)
	self.m_ItemQuality = self:NewUI(11, CSprite)
	self.m_AdvancedBtn = self:NewUI(12, CSprite)
	self.m_ExtendObj = self:NewUI(13, CObject)
	self.m_ItemAmountL = self:NewUI(14, CLabel)
	self.m_TipLabel = self:NewUI(15, CLabel)
	self.m_CloseBtn = self:NewUI(16, CButton)
	self.m_QuickBuyBox = self:NewUI(17, CQuickBuyBox)
	self.m_QuickBuyBox.m_CostBox:SetCurrencyType(define.Currency.Type.AnyGoldCoin, true)
	self.m_QuickBuyBox:SetInfo({
		id = define.QuickBuy.PartnerSkillUpgrade,
		name = "便捷购买",
		offset = Vector3.zero,
	})
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "SetActive", false), oView)
	self.m_AdvancedBtn:AddUIEvent("click", callback(self, "OnAdvanced"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "SetActive", false))
	self.m_SkillInfo = nil
end

function CPartnerSkillInfoBox.SetPartnerSkillInfoBoxInfo(self, skillInfo, oSkillBox)
	self:SetActive(skillInfo ~= nil)
	if skillInfo then
		if skillInfo.data == nil then
			self.m_IsMaxLv = false
			self.m_IsLock = true
		else
			local skillUpgradeInfo = DataTools.GetPartnerskillUpgrade(skillInfo.data.sk)
			self.m_IsMaxLv = skillUpgradeInfo == nil or skillInfo.data.level >= #skillUpgradeInfo
			self.m_IsLock = false
		end
		self:ResetSkillInfo(skillInfo)
	end
end

function CPartnerSkillInfoBox.ResetSkillInfo(self, skillInfo)
	self.m_SkillInfo = skillInfo
	local skill = skillInfo.info
	self.m_SkillIcon:SpriteSkill(skill.icon)
	self.m_SkillName:SetText(skill.name)
	local skillLv = skillInfo.data and skillInfo.data.level or 0
	self.m_SkillLv:SetText(skillLv)
	local skillDescCur = g_PartnerCtrl:GetPartnerSkillDesc(skill.id, skillLv)
	self.m_CurDesc:SetText(skillDescCur)
	--TODO:暂无下级技能属性变化
	-- local skillDescNext = g_PartnerCtrl:GetPartnerSkillDesc(skill.id, skillLv + 1)
	-- self.m_NextDesc:SetText(skillDescNext)

	local partnerData = g_PartnerCtrl:GetRecruitPartnerDataByID(skillInfo.partnerid)
	local iPartnerGrade = partnerData and partnerData.grade or 0
	local iUnlockGrade = DataTools.GetPartnerSkillUnlockGrade(skillInfo.partnerid, skill.id) or 0
	local bSkilllock = iUnlockGrade > iPartnerGrade
	
	local showTip = bSkilllock or self.m_IsMaxLv or self.m_IsLock
	self.m_TipLabel:SetActive(showTip)

	local tipStr = ""
	if bSkilllock then
		local name = partnerData and partnerData.name or DataTools.GetPartnerInfo(skillInfo.partnerid).name
		tipStr = "[c][244B4E]#G" .. name .. "[-]升级至#G" .. iUnlockGrade .. "级[-]自动解锁"
	elseif self.m_IsMaxLv then
		tipStr = "技能已升至满级"
	elseif self.m_IsLock then
		tipStr = "[c][244B4E]#G" .. name .. "[-]升级至#G" .. skillInfo.unlockLv .. "级[-]自动解锁"
		self.m_QuickBuyBox:SetItemsInfo(nil)
	end
	self.m_TipLabel:SetText(tipStr)

	local showExtend = skillInfo.data ~= nil and not self.m_IsMaxLv and not self.m_IsLock and not bSkilllock
	self.m_ExtendObj:SetActive(showExtend)
	if showExtend then
		local skillUpgradeList = DataTools.GetPartnerskillUpgrade(skillInfo.data.sk)
		local skillUpgradeInfo = skillUpgradeList[skillInfo.data.level]
		local skillUpgradeCost = skillUpgradeInfo.cost
		local itemInfo = DataTools.GetItemData(skillUpgradeCost.itemid)
		local amount = g_ItemCtrl:GetBagItemAmountBySid(skillUpgradeCost.itemid)
		self.m_ItemBox:AddUIEvent("click", function ()
			g_WindowTipCtrl:SetWindowGainItemTip(skillUpgradeCost.itemid)
		end)
		self.m_Grade:SetText(string.format("伙伴等级%s级", skillUpgradeInfo.partner_level or 1))
		self.m_ItemIcon:SpriteItemShape(itemInfo.icon)
		-- self.m_ItemName:SetText(string.format("#G%s[-]\n#O%s/%s", itemInfo.name, amount, skillUpgradeCost.amount))
		self.m_ItemName:SetText(itemInfo.name)
		self.m_AdvancedBtn:DelEffect("RedDot")
		if amount < skillUpgradeCost.amount then
			self.m_ItemAmountL:SetText(string.format("[c]#R%d[-][/c]/%d", amount, skillUpgradeCost.amount))
		else
			self.m_ItemAmountL:SetText(amount.."/"..skillUpgradeCost.amount)
			if skillUpgradeInfo.partner_level <= iPartnerGrade then
				self.m_AdvancedBtn:AddEffect("RedDot", 20, Vector2(-17, -17))
			end
		end
		self.m_ItemQuality:SetItemQuality(itemInfo.quality)
		self.m_QuickBuyBox:SetItemsInfo({
			{id = skillUpgradeCost.itemid, cnt = skillUpgradeCost.amount},
		})
	end
end

function CPartnerSkillInfoBox.OnAdvanced(self)

	if not self.m_SkillInfo then
		return
	end
	local skillUpgradeInfo = DataTools.GetPartnerskillUpgrade(self.m_SkillInfo.data.sk)
	local skillUpgradeCost = skillUpgradeInfo[self.m_SkillInfo.data.level].cost
	local itemInfo = DataTools.GetItemData(skillUpgradeCost.itemid)
	local amount = g_ItemCtrl:GetBagItemAmountBySid(skillUpgradeCost.itemid)
	-- if skillUpgradeCost.amount > amount then
	-- 	-- local tipStr = string.format("#G%s[-]数量不足#G%s[-]，无法升级技能#G%s", itemInfo.name, skillUpgradeCost.amount, self.m_SkillInfo.info.name)
	-- 	local tipStr = string.gsub(DataTools.GetPartnerTextInfo(1016).content, "#item", itemInfo.name)
	-- 	g_NotifyCtrl:FloatMsg(tipStr)
	-- 	return
	-- end
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
	netpartner.C2GSUpgradeSkill(self.m_SkillInfo.partnerid, self.m_SkillInfo.data.sk, bQuickSel and 1 or 0)
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗结束后生效")
	end
end

function CPartnerSkillInfoBox.JudgeLackList(self)
	-- body
	local skillUpgradeInfo = DataTools.GetPartnerskillUpgrade(self.m_SkillInfo.data.sk)
	local skillUpgradeCost = skillUpgradeInfo[self.m_SkillInfo.data.level].cost
	local itemInfo = DataTools.GetItemData(skillUpgradeCost.itemid)
	local amount = g_ItemCtrl:GetBagItemAmountBySid(skillUpgradeCost.itemid)
	local itemlist = {}
	if skillUpgradeCost.amount > amount then
		local t = {sid = skillUpgradeCost.itemid, count =amount, amount = skillUpgradeCost.amount}
		table.insert(itemlist, t)
	end
	g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, function()
		netpartner.C2GSUpgradeSkill(self.m_SkillInfo.partnerid, self.m_SkillInfo.data.sk, 1)
		if g_WarCtrl:IsWar() then
			g_NotifyCtrl:FloatMsg("战斗结束后生效")
		end
	end)
end

return CPartnerSkillInfoBox
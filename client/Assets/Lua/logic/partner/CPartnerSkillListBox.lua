local CPartnerSkillListBox = class("CPartnerSkillListBox", CBox)

function CPartnerSkillListBox.ctor(self, obj, boxType)
	CBox.ctor(self, obj)

	self.m_ProtectSkillL = self:NewUI(1, CLabel)
	self.m_ProtectSkillSpr = self:NewUI(2, CSprite)
	self.m_ProtectSkillLvL = self:NewUI(3, CLabel)
	self.m_CommonSkillGrid = self:NewUI(4, CGrid)
	self.m_CommonSkillBoxClone = self:NewUI(5, CBox)
	self.m_SwitchBtn = self:NewUI(6, CSprite)

	self:InitContent()
end

function CPartnerSkillListBox.InitContent(self)
	self.m_CommonSkillBoxClone:SetActive(false)
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnClickSwitchSkill"))
	self.m_ProtectSkillSpr:AddUIEvent("click", callback(self, "OnClickSwitchSkill"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end

function CPartnerSkillListBox.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or oCtrl.m_EventID == define.Item.Event.AddItem then
		local oItem = oCtrl.m_EventData
		if oItem.m_SID == 30666 then
			self:RefreshAll()
		end
	end
end

-- 当有外部数据传入，优先使用外部数据的
function CPartnerSkillListBox.SetPartnerId(self, iPartnerId, bIsLink, tPartnerData)
	self.m_PartnerId = iPartnerId
	self.m_IsLinkMode = bIsLink
	self.m_PartnerData = tPartnerData
	
	self:RefreshAll()
end

function CPartnerSkillListBox.RefreshAll(self)
	self:RefreshProtectSkill()
	self:RefreshAllCommonSkill()
end

function CPartnerSkillListBox.RefreshProtectSkill(self)
	if self.m_IsLinkMode then
		return
	end

	local dSkill = nil
	if self.m_IsLinkMode and self.m_PartnerData then
		dSkill = g_PartnerCtrl:GetLinkPartnerProtoctSkill(self.m_PartnerData.skill)
	else
		dSkill = g_PartnerCtrl:GetPartnerProtectSkill(self.m_PartnerId)
	end

	self.m_IsUnlockProtect = true
	if not dSkill then
		local skillId = DataTools.GetPartnerProtectSKill(self.m_PartnerId, g_AttrCtrl.school)
		printc("未招募，获取默认护主技能", self.m_PartnerId, skillId)
		dSkill = {sk = skillId, level = 0}
		self.m_IsUnlockProtect = false
	end

	local dSkillInfo = DataTools.GetPartnerSpecialSkill(dSkill.sk)
	local dEff = DataTools.GetPartnerProtectSKillEff(dSkill.sk, dSkill.level)
	local iVal = not dEff and "" or dEff.value
	if dEff and (dEff.attr == "seal_ratio" or dEff.attr == "res_seal_ratio") then
		iVal = iVal * 10
	end
	self.m_ProtectSkillSpr:SpriteSkill(dSkillInfo.icon)
	self.m_ProtectSkillLvL:SetText(dSkill.level > 0 and dSkill.level.."级" or "")
	self.m_ProtectSkillL:SetText(dSkillInfo.desc..iVal)
	self.m_SwitchBtn:SetActive(dSkill.level ~= 0)
	self.m_ProtectSkillSpr:AddUIEvent("click", function()
		if self.m_IsUnlockProtect then
			self:OnClickSwitchSkill()
		else
			local dConfig = table.copy(dSkillInfo)
			dConfig.widget = self.m_ProtectSkillSpr
			g_WindowTipCtrl:SetWindowSkillTip(dConfig)
		end
	end)
end

function CPartnerSkillListBox.RefreshAllCommonSkill(self)
	local skillBoxList = self.m_CommonSkillGrid:GetChildList()

	local lSkillInfoList = nil
	if self.m_PartnerData then
		lSkillInfoList = g_PartnerCtrl:GetLinkPartnerSkillList(self.m_PartnerData.skill)
	else
		lSkillInfoList = g_PartnerCtrl:GetPartnerSkillInfoList(self.m_PartnerId)
		if self.m_IsLinkMode then
			local dProtectSkill = g_PartnerCtrl:GetPartnerProtectSkill(self.m_PartnerId)
			if not dProtectSkill then
				local skillId = DataTools.GetPartnerProtectSKill(self.m_PartnerId, g_AttrCtrl.school)
				printc("未招募，获取默认护主技能", self.m_PartnerId, skillId)
				dProtectSkill = {sk = skillId, level = 0}
			end
			table.insert(lSkillInfoList, 1, dProtectSkill)
		end
	end

	for i,dSkill in ipairs(lSkillInfoList) do
		local oSkillBox = nil
		local skillInfo = DataTools.GetPartnerSpecialSkill(dSkill.sk)
		local cloneObj = nil
		if i > #skillBoxList then
			oSkillBox = self:AddCommonSkillBox()
		else
			oSkillBox = skillBoxList[i]
		end

		self:UpdateCommonSkill(oSkillBox, dSkill)
	end
	for i = #lSkillInfoList+1, #skillBoxList do
		skillBoxList[i]:SetActive(false)
	end
	self.m_CommonSkillGrid:Reposition()
end

function CPartnerSkillListBox.AddCommonSkillBox(self)
	local oBox = self.m_CommonSkillBoxClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_LvL = oBox:NewUI(2, CLabel)
	oBox.m_TipSpr = oBox:NewUI(3, CSprite)
	oBox.m_BgSpr = oBox:NewUI(4, CSprite)
	oBox.m_UnlockL = oBox:NewUI(5, CLabel)

	oBox:SetActive(true)
	self.m_CommonSkillGrid:AddChild(oBox)
	return oBox
end

function CPartnerSkillListBox.UpdateCommonSkill(self, oBox, dSkill)
	local dSkillInfo = DataTools.GetPartnerSpecialSkill(dSkill.sk)
	local iUnlockGrade = DataTools.GetPartnerSkillUnlockGrade(self.m_PartnerId, dSkill.sk) or 0
	local dPartner = g_PartnerCtrl:GetRecruitPartnerDataByID(self.m_PartnerId)
	local iPartnerGrade = dPartner and dPartner.grade or 0
	local bIsUnlock = iPartnerGrade >= iUnlockGrade

	oBox.m_IconSpr:SpriteSkill(dSkillInfo.icon)
	if not self.m_IsLinkMode then
		oBox.m_IconSpr:SetGrey(not bIsUnlock)
	end
	oBox.m_LvL:SetText(dSkill and dSkill.level.."级" or "")
	oBox.m_TipSpr:SetActive(false)
	oBox.m_UnlockL:SetText(not bIsUnlock and iUnlockGrade.."级开启" or "")
	-- self:RefreshUpgradeRedPoint(oBox, dSkill, iPartnerGrade, bIsUnlock)

	if self.m_IsLinkMode then
		oBox:AddUIEvent("click", function ()
			local dConfig = table.copy(dSkillInfo)
			dConfig.widget = oBox
			g_WindowTipCtrl:SetWindowSkillTip(dConfig)
		end)
		return
	end
	oBox:AddUIEvent("click", function ()
		local t = {info = dSkillInfo, partnerid = self.m_PartnerId, data = dSkill, unlockLv = iUnlockGrade}
		CPartnerMainView:GetView():ShowPartnerSkillInfoBox(t, oBox)
	end)
end

function CPartnerSkillListBox.RefreshUpgradeRedPoint(self, oBox, dSkill, iPartnerGrade, bIsUnlock)
	oBox:DelEffect("RedDot")
	if not bIsUnlock or self.m_IsLinkMode then
		return
	end
	local skillUpgradeList = DataTools.GetPartnerskillUpgrade(dSkill.sk)
	local skillUpgradeInfo = skillUpgradeList[dSkill.level]
	if not skillUpgradeInfo then
		return
	end
	local skillUpgradeCost = skillUpgradeInfo.cost
	local itemInfo = DataTools.GetItemData(skillUpgradeCost.itemid)
	local amount = g_ItemCtrl:GetBagItemAmountBySid(skillUpgradeCost.itemid)
	if amount >= skillUpgradeCost.amount and skillUpgradeInfo.partner_level <= iPartnerGrade then
		oBox:AddEffect("RedDot", 20, Vector2(-17, -17))
	end
end

function CPartnerSkillListBox.OnClickSwitchSkill(self)
	-- TODO:Switch project skill
	local oView = CPartnerMainView:GetView()
	oView:ShowPartnerProtectSkillBox()
end

return CPartnerSkillListBox
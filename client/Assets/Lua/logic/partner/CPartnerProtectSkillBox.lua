local CPartnerProtectSkillBox = class("CPartnerProtectSkillBox", CBox)

function CPartnerProtectSkillBox.ctor(self, obj, boxType)
	CBox.ctor(self, obj)

	self.m_SkillGrid = self:NewUI(1, CGrid)
	self.m_SkillBoxClone = self:NewUI(2, CBox)
	self.m_CurSkillSpr = self:NewUI(3, CSprite)
	self.m_CurSkillNameL = self:NewUI(4, CLabel)
	self.m_CurSkillLvL = self:NewUI(5, CLabel)
	self.m_CurSkillDescL = self:NewUI(6, CLabel)
	self.m_SwitchBtn = self:NewUI(7, CButton)
	self.m_ConsumeBox = self:NewUI(8, CCurrencyBox)
	self.m_GlodBox = self:NewUI(9, CCurrencyBox)
	self.m_CloseBtn = self:NewUI(10, CButton)
	self.m_ScrollView = self:NewUI(11, CScrollView)

	self.m_SelectedId = -1

	self.m_SkillBoxClone:SetActive(false)
	self.m_ConsumeBox:SetCurrencyType(define.Currency.Type.Gold, true)
	self.m_GlodBox:SetCurrencyType(define.Currency.Type.Gold)

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "SetActive", false))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "SetActive", false))
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnClickSwitchProtect"))
end

function CPartnerProtectSkillBox.RefreshAll(self)
	self.m_PartnerInfo = CPartnerMainView:GetView():GetPartnerBoxNodeInfo()
	self.m_PartnerSData = g_PartnerCtrl:GetRecruitPartnerDataByID(self.m_PartnerInfo.id)
	self.m_ProtectSkill = g_PartnerCtrl:GetPartnerProtectSkill(self.m_PartnerInfo.id)

	self:RefreshCost()
	self:RefreshSkillGrid()
end

function CPartnerProtectSkillBox.RefreshCost(self)
	local iCost = 0
	local tPartner = data.partnerdata.INFO[self.m_PartnerInfo.id]
	if tPartner then
		iCost = tPartner.swap_cost
	end
	self.m_ConsumeBox:SetCurrencyCount(iCost)
end

function CPartnerProtectSkillBox.RefreshSkillGrid(self)
	local skillBoxList = self.m_SkillGrid:GetChildList()
	local lSkill = data.partnerdata.PROTECTSKILLLLIST
	
	for i,iSkillId in ipairs(lSkill) do
		local oSkillBox = nil
		if i > #skillBoxList then
			oSkillBox = self:AddSkillBox()
		else
			oSkillBox = skillBoxList[i]
		end
		self:UpdateSkillBox(oSkillBox, iSkillId)
		if (self.m_SelectedId == -1 and i == 1) or self.m_ProtectSkill.sk == iSkillId then
			self:OnClickSkill(oSkillBox)
		end
	end
	for i = #lSkill+1, #skillBoxList do
		skillBoxList[i]:SetActive(false)
	end
	self.m_SkillGrid:Reposition()
end

function CPartnerProtectSkillBox.AddSkillBox(self)
	local oBox = self.m_SkillBoxClone:Clone()
	oBox.m_SkillSpr = oBox:NewUI(1, CSprite)
	oBox.m_LvL = oBox:NewUI(2, CLabel)
	oBox.m_FlagSpr = oBox:NewUI(3, CSprite)

	oBox.m_LvL:SetActive(false)
	oBox:SetActive(true)
	oBox:AddUIEvent("click", callback(self, "OnClickSkill", oBox))
	self.m_SkillGrid:AddChild(oBox)
	return oBox
end	

function CPartnerProtectSkillBox.UpdateSkillBox(self, oBox, iSkillId)
	local dInfo = DataTools.GetPartnerSpecialSkill(iSkillId)
	local bIsUsing = iSkillId == self.m_ProtectSkill.sk
	oBox.m_SkillId = iSkillId
	oBox.m_SkillInfo = dInfo

	oBox.m_SkillSpr:SpriteSkill(dInfo.icon)
	-- oBox.m_LvL:SetText(bIsUsing and self.m_ProtectSkill.level or "")
	oBox.m_FlagSpr:SetActive(bIsUsing)
end

function CPartnerProtectSkillBox.RefreshSelectedSkill(self, dInfo)
	local dEff = DataTools.GetPartnerProtectSKillEff(dInfo.id, self.m_ProtectSkill.level)
	local iVal = dEff and dEff.value
	if dEff and (dEff.attr == "seal_ratio" or dEff.attr == "res_seal_ratio") then
		iVal = iVal * 10
	end
	self.m_CurSkillSpr:SpriteSkill(dInfo.icon)
	self.m_CurSkillDescL:SetText(dInfo.desc..(iVal or ""))
	self.m_CurSkillNameL:SetText(dInfo.name)
	self.m_CurSkillLvL:SetText(self.m_ProtectSkill.level)
end

function CPartnerProtectSkillBox.OnClickSkill(self, oBox)
	oBox:SetSelected(true)
	self:RefreshSelectedSkill(oBox.m_SkillInfo)
	self.m_SelectedId = oBox.m_SkillId
end

function CPartnerProtectSkillBox.OnClickSwitchProtect(self)
	if self.m_SelectedId == self.m_ProtectSkill.sk then
		g_NotifyCtrl:FloatMsg("不能更换同一个技能")
		return
	end
	local iCost = self.m_ConsumeBox:GetCurrencyCount()
	if iCost > g_AttrCtrl.gold then
        g_QuickGetCtrl:CheckLackItemInfo({
            coinlist = {{sid = 1001, amount = iCost, count = g_AttrCtrl.gold}},
            exchangeCb = callback(self, "SwapProtectSkill", self.m_SelectedId)
        })
	else
		self:SwapProtectSkill(self.m_SelectedId)
	end
end

function CPartnerProtectSkillBox.SwapProtectSkill(self, iSel)
	netpartner.C2GSSwapProtectSkill(self.m_PartnerSData.id, self.m_ProtectSkill.sk, iSel)
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗结束后生效")
	end	
end

function CPartnerProtectSkillBox.SetActive(self, b)
	CObject.SetActive(self, b)
	if not b then
		self.m_SelectedId = -1
	end
end

return CPartnerProtectSkillBox
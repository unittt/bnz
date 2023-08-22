local CForgeSpEffectListView = class("CForgeSpEffectListView", CViewBase)

function CForgeSpEffectListView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgeSpEffectListView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
end

function CForgeSpEffectListView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SkillTable = self:NewUI(2, CTable)
	self.m_SkillListBoxClone = self:NewUI(3, CBox)

	self.m_BgOriginalW = 0
	self.m_BgOriginalH = 0

	self:InitContent()
end

function CForgeSpEffectListView.InitContent(self)
	self.m_SkillListBoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CForgeSpEffectListView.SetEquipInfo(self, iEquipPos, iEquipLv)
	self.m_EquipLv = iEquipLv
	self.m_EquipPos = iEquipPos
	self:RefreshAll()
end

function CForgeSpEffectListView.RefreshAll(self)
	self:RefreshSpecialEffect()
	self:RefreshSpecialSkill()
	self.m_SkillTable:Reposition()
end

function CForgeSpEffectListView.RefreshSpecialSkill(self)
	local lSkill = DataTools.GetEquipSpecialSkillList(self.m_EquipLv)
	table.print(lSkill, "特技预览")
	self:CreateSkillListBox("特技预览", lSkill, true)
end

function CForgeSpEffectListView.RefreshSpecialEffect(self)
	local lSkill = DataTools.GetEquipSpecialEffectList(self.m_EquipLv, self.m_EquipPos)
		table.print(lSkill, "特效预览")

	self:CreateSkillListBox("特效预览", lSkill, false)
end

function CForgeSpEffectListView.CreateSkillListBox(self, sTitle, lSkill, bIsSK)
	local oBox = self.m_SkillListBoxClone:Clone()
	oBox.m_TitleL = oBox:NewUI(1, CLabel)
	oBox.m_BgSpr = oBox:NewUI(2, CSprite)
	oBox.m_SkillGrid = oBox:NewUI(3, CGrid)
	oBox.m_SkillBoxClone = oBox:NewUI(4, CBox)

	if self.m_BgOriginalH == 0 then
		self.m_BgOriginalW, self.m_BgOriginalH = oBox.m_BgSpr:GetSize()
	end

	oBox:SetActive(true)
	oBox.m_SkillBoxClone:SetActive(false)
	self:RefreshSkillListBox(oBox, sTitle, lSkill, bIsSK)
	self.m_SkillTable:AddChild(oBox)
	return oBox
end

function CForgeSpEffectListView.RefreshSkillListBox(self, oBox, sTitle, lSkill, bIsSK)
	oBox.m_TitleL:SetText(sTitle)
	for i, iSkillId in ipairs(lSkill) do
		local oSkillBox = self:CreateSkillBox(oBox, iSkillId, bIsSK)
		oBox.m_SkillGrid:AddChild(oSkillBox)
	end
	oBox.m_SkillGrid:Reposition()

	local _,iCellH = oBox.m_SkillGrid:GetCellSize()

	local iBgH = iCellH*(math.floor((#lSkill - 1)/5)) + self.m_BgOriginalH 
	oBox.m_BgSpr:SetSize(self.m_BgOriginalW, iBgH)
end

function CForgeSpEffectListView.CreateSkillBox(self, oBox, iSkillId, bIsSK)
	local oSkillBox = oBox.m_SkillBoxClone:Clone()
	oSkillBox.m_IconSpr = oSkillBox:NewUI(1, CSprite)
	oSkillBox.m_SkillNameL = oSkillBox:NewUI(2, CLabel)

	local dSkill = data.skilldata.SPECIAL_EFFC[iSkillId]
	oSkillBox.m_SkillNameL:SetText(dSkill.name)
	oSkillBox.m_IconSpr:SpriteMagic(dSkill.icon)
	oSkillBox:AddUIEvent("click", callback(self, "ShowDetailTips", oSkillBox, iSkillId, bIsSK))

	oSkillBox:SetActive(true)
	return oSkillBox
end

function CForgeSpEffectListView.ShowDetailTips(self, oBox, iSkillId, bIsSK)
	local args = {widget =  oBox, side = enum.UIAnchor.Side.Right,offset = Vector2.New(-140, 50)}
	g_WindowTipCtrl:SetWindowEquipEffectTipInfo(iSkillId, args, bIsSK) 
end

return CForgeSpEffectListView
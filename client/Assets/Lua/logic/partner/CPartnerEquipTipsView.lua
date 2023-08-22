local CPartnerEquipTipsView = class("CPartnerEquipTipsView", CViewBase)

function CPartnerEquipTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerEquipTipsView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	-- printerror("item tips view --------------------- ")
end

function CPartnerEquipTipsView.OnCreateView(self)
	self.m_ItemIconSpr = self:NewUI(1, CSprite)
	self.m_QualitySpr = self:NewUI(2, CSprite)
	self.m_NameL = self:NewUI(3, CLabel)
	self.m_EquipLvL = self:NewUI(4, CLabel)
	self.m_EquipPosL = self:NewUI(5, CLabel)
	self.m_AttrTable = self:NewUI(6, CTable)
	self.m_AttrBoxClone = self:NewUI(7, CBox)
	self.m_StrengthenBtn = self:NewUI(8, CButton)
	self.m_UpgradeBtn = self:NewUI(9, CButton)
	self.m_BgSpr = self:NewUI(10, CSprite)
	self.m_ButtonW = self:NewUI(11, CWidget) 

	self:InitContent()
end

function CPartnerEquipTipsView.InitContent(self)
	self.m_AttrBoxClone:SetActive(false)

	self.m_StrengthenBtn:AddUIEvent("click", callback(self, "OnClickStrengthen"))
	self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnClickUpgrade"))
end

function CPartnerEquipTipsView.SetEquipInfo(self, dPartnerInfo, dEquip, bIsLink, iEquipPos)
	self.m_PartnerInfo = dPartnerInfo
	self.m_EquipInfo = dEquip
	self.m_EquipPos = iEquipPos
	self.m_EquipData = DataTools.GetPartnerEquipData(dEquip.equip_sid)
	self:RefreshAll()
	if bIsLink then
		self:HideButton()
	end
end

function CPartnerEquipTipsView.HideButton(self)
	self.m_ButtonW:SetAnchor("bottomAnchor",0, 0)
	self.m_ButtonW:SetActive(false)
	local w,h = self.m_BgSpr:GetSize()
	h = h - 60 
	self.m_BgSpr:SetSize(w, h)
end

function CPartnerEquipTipsView.RefreshAll(self)
	self:RefreshRedPoint()
	self:RefreshEquipBaseInfo()
	self:RefreshEquipAttr()
	self:ResetBg()
end

function CPartnerEquipTipsView.RefreshRedPoint(self)
	local dRedPoint = g_PartnerCtrl:GetEquipRedPoint(self.m_EquipInfo.equip_sid)
	if not dRedPoint then
		return
	end
	if dRedPoint.strength then
		self.m_StrengthenBtn:AddEffect("RedDot", 20, Vector2(-13, -17))
	end
	if dRedPoint.upgrade then
		self.m_UpgradeBtn:AddEffect("RedDot", 20, Vector2(-13, -17))
	end
end

function CPartnerEquipTipsView.RefreshEquipBaseInfo(self)
	--TODO:等正式图标
	local iItemIcon = DataTools.GetPartnerEquipIcon(self.m_EquipInfo.equip_sid, self.m_EquipInfo.level)
	local iPos = self.m_EquipInfo.equip_sid%100
	local sName = self.m_EquipData.equip_name
	if self.m_EquipInfo.strength and self.m_EquipInfo.strength > 0 then
		sName = sName.."[c][0fff32]+"..self.m_EquipInfo.strength
	end

	self.m_NameL:SetText(sName)
	self.m_ItemIconSpr:SpriteItemShape(iItemIcon)
	self.m_QualitySpr:SetItemQuality(0)
	self.m_EquipPosL:SetText(define.Equip.PosName[iPos])
	self.m_EquipLvL:SetText(self.m_EquipInfo.level)
end

function CPartnerEquipTipsView.RefreshEquipAttr(self)
	self.m_AttrTable:Clear()
	self:CreateEquipGradeAttr()
	self:CreateEquipStrenthenAttr()
end

function CPartnerEquipTipsView.CreateEquipGradeAttr(self)
	local dUpgradeData = DataTools.GetPartnerEquipUpgradeInfo(self.m_EquipInfo.level, self.m_EquipInfo.equip_sid)
	if not dUpgradeData then
		return
	end

	local sDesc = "[8FF2E2]基本属性[-]"
	local oBox = self:CreateAttr(sDesc)
	self.m_AttrTable:AddChild(oBox)
	for k,v in pairs(dUpgradeData) do
		local sAttr = data.attrnamedata.DATA[k].name
		local iAttrValue = math.floor(v)
		oBox = self:CreateAttr("  [c8fff1]"..sAttr, "[c8fff1]+"..iAttrValue)
		self.m_AttrTable:AddChild(oBox)
	end
end

function CPartnerEquipTipsView.CreateEquipStrenthenAttr(self)
	local dStrengthData = DataTools.GetPartnerEquipStrengthInfo(self.m_EquipInfo.strength, self.m_EquipInfo.equip_sid)
	if not dStrengthData then
		return
	end

	local sDesc = "[8FF2E2]附加属性[-]"
	local oBox = self:CreateAttr(sDesc)
	self.m_AttrTable:AddChild(oBox)
	for k,v in pairs(dStrengthData) do
		local sAttr = data.attrnamedata.DATA[k].name
		local iAttrValue = math.floor(v)
		oBox = self:CreateAttr("  [c8fff1]"..sAttr, "[c8fff1]+"..iAttrValue)
		self.m_AttrTable:AddChild(oBox)
	end
end

function CPartnerEquipTipsView.CreateAttr(self, sAttrName, sAttrValue)
	local oBox = self.m_AttrBoxClone:Clone()
	oBox.m_AttrL = oBox:NewUI(1, CLabel)
	oBox.m_ValueL = oBox:NewUI(2, CLabel)
	oBox:SetActive(true)

	oBox.m_AttrL:SetActive(sAttrName ~= nil)
	oBox.m_ValueL:SetActive(sAttrValue ~= nil)

	oBox.m_AttrL:SetText(sAttrName)
	oBox.m_ValueL:SetText(sAttrValue)

	return oBox
end

function CPartnerEquipTipsView.ResetBg(self)
	local w,h = self.m_BgSpr:GetSize()
	local tableH = self.m_AttrTable:GetCount()*25

	h = math.max(h + tableH - 20, h)
	self.m_BgSpr:SetSize(w,h)
end

function CPartnerEquipTipsView.OnClickUpgrade(self)
	CPartnerEquipUpgradeView:ShowView(function(oView)
		oView:SetEquipInfo(self.m_PartnerInfo, false, self.m_EquipPos)
	end)
	-- netpartner.C2GSUpgradePartnerEquip(self.m_PartnerId, self.m_EquipInfo.equip_sid)
	self:CloseView()
end

function CPartnerEquipTipsView.OnClickStrengthen(self)
	CPartnerEquipUpgradeView:ShowView(function(oView)
		oView:SetEquipInfo(self.m_PartnerInfo, true, self.m_EquipPos)
	end)
	-- netpartner.C2GSStrengthPartnerEquip(self.m_PartnerId, self.m_EquipInfo.equip_sid)
	self:CloseView()
end

return CPartnerEquipTipsView
local CPartnerAttrBox = class("CPartnerAttrBox", CBox)

function CPartnerAttrBox.ctor(self, obj, boxType)
	CBox.ctor(self, obj)

	self.m_AttrGrid = self:NewUI(1, CGrid)
	self.m_AttrBoxClone = self:NewUI(2, CBox)
	self.m_HPSlider = self:NewUI(3, CSlider)
	self.m_MPSlider = self:NewUI(4, CSlider)
	self.m_HpL = self:NewUI(5, CLabel)
	self.m_MpL = self:NewUI(6, CLabel)
	-- self.m_ExpSlider = self:NewUI(7, CSlider) --TODO:取消掉伙伴经验概念，相关显示屏蔽
	-- self.m_ExpL = self:NewUI(8, CLabel)
	-- self.m_AddExpBtn = self:NewUI(9, CWidget)

	self.m_AttrList = {
		{"物攻", "phy_attack"}, {"物防", "phy_defense"},
		{"法攻", "mag_attack"}, {"法防", "mag_defense"},
		{"封印", "seal_ratio"}, {"抗封", "res_seal_ratio"},
		{"治疗", "cure_power"}, {"速度", "speed"},
	}

	self.m_AttrBoxClone:SetActive(false)
	-- self.m_AddExpBtn:AddUIEvent("click", callback(self, "OnClickAddExp"))
end

-- 当有外部数据传入，优先使用外部数据的
function CPartnerAttrBox.SetPartnerId(self, iPartnerId, tPartnerData)
	self.m_PartnerId = iPartnerId
	self.m_SPartner = tPartnerData and tPartnerData or g_PartnerCtrl:GetRecruitPartnerDataByID(iPartnerId)
	self.m_PartnerPropDict = g_PartnerCtrl:GetCalculusPartnerProp(self.m_PartnerId)
	if self.m_SPartner then
		self.m_PartnerPropDict = self.m_SPartner
	else
		self.m_PartnerPropDict = g_PartnerCtrl:GetCalculusPartnerProp(self.m_PartnerId)
	end

	self:RefreshAll()
end

function CPartnerAttrBox.RefreshAll(self)
	self:RefreshButton()
	self:RefreshAttr()
	self:RefreshAllSlider()
end

function CPartnerAttrBox.RefreshButton(self)
	-- self.m_AddExpBtn:SetActive(self.m_SPartner ~= nil)
end

function CPartnerAttrBox.RefreshAttr(self)
	self.m_AttrGrid:Clear()
	for i,key in ipairs(self.m_AttrList) do
		local oBox = self:CreateAttrBox(key)
		self.m_AttrGrid:AddChild(oBox)
	end

	self.m_AttrGrid:Reposition()
end

function CPartnerAttrBox.CreateAttrBox(self, tAttr)
	local oBox = self.m_AttrBoxClone:Clone()
	oBox.m_AttrNameL = oBox:NewUI(1, CLabel)
	oBox.m_ValueL = oBox:NewUI(2, CLabel)
	
	local sAttrName = tAttr[1]
	local iValue = self.m_PartnerPropDict[tAttr[2]]

	if not iValue then
		printerror("伙伴属性获取错误", tAttr[2])
		return
	elseif tAttr[2] == "seal_ratio" or tAttr[2] == "res_seal_ratio" then
		iValue = iValue * 10
	end

	oBox.m_AttrNameL:SetText(sAttrName)
	oBox.m_ValueL:SetText(iValue)
	oBox:SetActive(true)
	return oBox
end

function CPartnerAttrBox.RefreshAllSlider(self)
	local iMaxHp = self.m_PartnerPropDict["max_hp"]
	local iMaxMp = self.m_PartnerPropDict["max_mp"]
	local iCurHp = self.m_SPartner and self.m_SPartner.hp or iMaxHp
	local iCurMp = self.m_SPartner and self.m_SPartner.mp or iMaxMp

	self.m_HpL:SetText(iCurHp.."/"..iMaxHp)
	self.m_MpL:SetText(iCurMp.."/"..iMaxMp)
	self.m_HPSlider:SetValue(iCurHp/iMaxHp)
	self.m_MPSlider:SetValue(iCurMp/iMaxMp)

	-- local iGrade = self.m_SPartner and self.m_SPartner.grade or 0
	-- local dExpInfo = data.upgradedata.DATA[iGrade + 1]
	-- local iCurExp = iGrade == 0 and 0 or g_PartnerCtrl:GetPartnerCurExp(self.m_SPartner.sid)
	-- self.m_ExpSlider:SetValue(iCurExp/dExpInfo.partner_exp)
	-- self.m_ExpL:SetText(iCurExp .. "/" .. dExpInfo.partner_exp)
end

-- function CPartnerAttrBox.OnClickAddExp(self)
-- 	local oView = CPartnerMainView:GetView()
-- 	if oView then
-- 		oView:ShowPartnerAddExpBox()
-- 	end
-- end

return CPartnerAttrBox
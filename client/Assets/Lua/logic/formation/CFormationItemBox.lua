local CFormationItemBox = class("CFormationItemBox", CItemBaseBox)

function CFormationItemBox.ctor(self, obj, boxType)
	CItemBaseBox.ctor(self, obj, boxType)
	self.m_DelBtn = self:NewUI(6, CButton)
	self.m_CostLabel = self:NewUI(7, CLabel)
	self.m_NameLabel = self:NewUI(8, CLabel)
	self.m_SelNameLabel = self:NewUI(9, CLabel)

	self.m_CostAmount = 0
	self.m_DelBtn:SetActive(false)
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnClickDelete"))
	self:AddUIEvent("click", callback(self, "OnItemBoxClick"))
end

function CFormationItemBox.SetListener(self, callback)
	self.m_Callback = callback
end

function CFormationItemBox.RefreshBox(self)
	CItemBaseBox.RefreshBox(self)
	local showItem = self.m_Item ~= nil
	if not showItem then
		return
	end
	-- local iQuality = self.m_Item:GetSValueByKey("itemlevel") or self.m_Item:GetCValueByKey("quality")
	local sName = self.m_Item:GetItemName()--string.format(data.colorinfodata.ITEM[iQuality].color, self.m_Item:GetSValueByKey("name"))
	self.m_NameLabel:SetText(sName)
	self.m_SelNameLabel:SetText(sName)
end

function CFormationItemBox.OnItemBoxClick(self)
	if self.m_CostAmount < self.m_Amount then
		self.m_CostAmount = self.m_Amount
		if self.m_Callback then
			self.m_Callback(self.m_ID, self.m_CostAmount)
		end
	end
	self:RefreshCostText()
end

function CFormationItemBox.OnClickDelete(self)
	if self.m_CostAmount > 0 then
		self.m_CostAmount = self.m_CostAmount - 1
		if self.m_Callback then
			self.m_Callback(self.m_ID, self.m_CostAmount)
		end
	end
	self:RefreshCostText()
end

function CFormationItemBox.RefreshCostText(self)
	self.m_DelBtn:SetActive(self.m_CostAmount > 0)
	self.m_CostLabel:SetActive(self.m_CostAmount > 0)
	self.m_AmountLabel:SetActive(self.m_CostAmount == 0)
	self.m_CostLabel:SetText(self.m_CostAmount .. "/" .. self.m_Amount)
end

function CFormationItemBox.GetItemAmount(self)
	return self.m_Amount
end

function CFormationItemBox.GetCostAmount(self)
	return self.m_CostAmount
end

return CFormationItemBox
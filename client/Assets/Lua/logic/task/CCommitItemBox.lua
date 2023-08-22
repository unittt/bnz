local CCommitItemBox = class("CCommitItemBox", CBox)

function CCommitItemBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_Callback = cb
	self.m_Item = nil
	
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Quality = self:NewUI(2, CSprite)
	self.m_Amount = self:NewUI(3, CLabel)
	self.m_DescLbl = self:NewUI(4, CLabel)
	self.m_SelectLbl = self:NewUI(5, CLabel)

	self:AddUIEvent("click", callback(self, "OnClickCommitBox"))
	self:RefreshBox()
end

function CCommitItemBox.OnClickCommitBox(self)
	if self.m_Item then
		if self.m_Callback then
			local exist = self.m_Callback(self)
			if not exist then
				-- local config = {widget = self}
				-- g_WindowTipCtrl:SetWindowItemTip(self.m_Item:GetSValueByKey("sid"), config)
				CItemTipsView:ShowView(function(oView)
					oView:SetItem(self.m_Item)
					oView:HideBtns()
					oView.m_EquipBox.m_RightBtn:SetActive(false)
					oView.m_EquipBox.m_LeftBtn:SetActive(false)
				end)
			end
		end
	end
end

function CCommitItemBox.SetCommitItemInfo(self, oItem)
	self.m_Item = oItem
	self:RefreshBox()
end

function CCommitItemBox.RefreshBox(self)
	local showItem = self.m_Item ~= nil
	self.m_Icon:SetActive(showItem)
	local quality = 0
	if showItem then
		local shape = self.m_Item:GetCValueByKey("icon") or 0
		self.m_Icon:SpriteItemShape(shape)
		local amount = self.m_Item:GetSValueByKey("amount") or 0
		self:SetAmountText(amount)
		quality = self.m_Item:GetQuality()

		if self.m_Item:IsEquip() then
			self.m_DescLbl:SetText(self.m_Item:GetItemName().."\n评分:"..math.floor(self.m_Item:GetSValueByKey("equip_info").score/1000))
			self.m_SelectLbl:SetText(self.m_Item:GetItemName().."\n评分:"..math.floor(self.m_Item:GetSValueByKey("equip_info").score/1000))
		else
			self.m_DescLbl:SetText(self.m_Item:GetItemName())
			self.m_SelectLbl:SetText(self.m_Item:GetItemName())
			
		end
	end
	self.m_Quality:SetItemQuality(quality)
end

function CCommitItemBox.SetAmountText(self, count)
	local showAmount = count > 1
	self.m_Amount:SetActive(showAmount)
	if showAmount then self.m_Amount:SetText(count) end
end

return CCommitItemBox
local CLotteryBox = class("CLotteryBox", CBox)

function CLotteryBox.ctor(self, obj)

	CBox.ctor(self, obj)

	self.m_IconSprite = self:NewUI(1, CSprite)
	self.m_CountLabel = self:NewUI(2, CLabel)
	self.m_QualityBorder = self:NewUI(3, CSprite)

	self:AddUIEvent("click", callback(self, "OnClickRewardItem"))


end

function CLotteryBox.SetData(self, itemId, count)
	
	self.data = {}
	self.data.itemId = itemId
	self.data.count = count

	self:SetIcon(self.data.itemId)

	self:SetLabel(self.data.count)

	self:SetQualityBorder(self.data.itemId)

end

function CLotteryBox.OnClickRewardItem(self)
	
	if self.data ~= nil then 

		local config = {widget = self}
		g_WindowTipCtrl:SetWindowItemTip(self.data.itemId, config)

	end 


end

function CLotteryBox.SetIcon(self,itemId)
	

	local iconData = DataTools.GetItemData(itemId)

	if iconData ~= nil then 
	
		self.m_IconSprite:SpriteItemShape(iconData.icon)

	end

end

function CLotteryBox.SetLabel(self, count)

	if count == 1 then 
		self.m_CountLabel:SetActive(false)
	else  
		self.m_CountLabel:SetActive(true)
		self.m_CountLabel:SetText(count)
	end 

end

function CLotteryBox.SetQualityBorder(self, itemId)
	
	local iconData = DataTools.GetItemData(itemId)

	if iconData ~= nil then 

		if iconData.quality ~= nil then 

			self.m_QualityBorder:SetItemQuality(g_ItemCtrl:GetQualityVal( iconData.id, iconData.quality or 0 ))

		end 

	end 

end

return CLotteryBox
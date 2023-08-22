local CRanseConsumeBox = class("CRanseConsumeBox", CBox)

function CRanseConsumeBox.ctor(self, obj)

	CBox.ctor(self, obj)

	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Count = self:NewUI(2, CLabel)

	self.m_Icon:AddUIEvent("click", callback(self, "OnClickTipsBtn"))
	
end

function CRanseConsumeBox.SetInfo(self, consumeInfo)

	self.m_consumeInfo = consumeInfo

    local iconId = consumeInfo.iconId
    local needCount = consumeInfo.needCount
    local hadCount = consumeInfo.hadCount

    self.m_Icon:SetSpriteName(iconId)
	self.m_Count:SetText(string.format("%d/%d", hadCount, needCount))

	if hadCount < needCount then 
		self.m_Count:SetText(string.format("[ff0000]%d[-][63432CFF]/%d[-]", hadCount, needCount))
	else
		self.m_Count:SetText(string.format("[63432CFF]%d/%d[-]", hadCount, needCount))
	end  

	self.m_Icon:SetActive(true)
	self.m_Count:SetActive(true)

end

function CRanseConsumeBox.IsEnought(self)
	
	if self.m_consumeInfo.needCount > self.m_consumeInfo.hadCount then 
		return false
	else
		return true
	end 

end

function CRanseConsumeBox.GetConsumeId(self)
	
	return self.m_consumeInfo.id

end

function CRanseConsumeBox.OnClickTipsBtn(self)

	if not self.m_consumeInfo then 
		return
	end 

	if not self.m_consumeInfo.id then 
		return
	end 

	local config = DataTools.GetItemData(self.m_consumeInfo.id, "OTHER")

	g_WindowTipCtrl:SetWindowGainItemTip(self.m_consumeInfo.id)

end

return CRanseConsumeBox
local CFuyuanTreasureTipBox = class("CFuyuanTreasureTipBox", CBox)

function CFuyuanTreasureTipBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_Close = self:NewUI(1, CSprite)
	self.m_Text = self:NewUI(2, CLabel)
	self.m_ConfirmBtn = self:NewUI(3, CSprite)
	self.m_CancelBtn = self:NewUI(4, CSprite)

	self.m_Close:AddUIEvent("click", callback(self, "OnClickClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirm"))

end

function CFuyuanTreasureTipBox.OnClickClose(self)
	
	self:SetActive(false)

end

function CFuyuanTreasureTipBox.OnClickConfirm(self)
	
	if self.m_Cb then 
		self.m_Cb()
	end 
	self:SetActive(false)

end

function CFuyuanTreasureTipBox.SetData(self, text, cb)

	self.m_Cb = cb
	self.m_Text:SetText(text)
	self:SetActive(true)

end

return CFuyuanTreasureTipBox
local CColorBox = class("CColorBox", CBox)

function CColorBox.ctor(self, obj)

	CBox.ctor(self, obj)

	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Label = self:NewUI(2, CLabel)
	self.m_Lock = self:NewUI(3, CSprite)
	
end

function CColorBox.SetInfo(self, info)

	if info.isDefault then 
		self.m_Icon:SetSpriteName("h7_bu_mo")
	else
		self.m_Icon:SetSpriteName("h7_bu_6")
		info.showColor.a = 1
		self.m_Icon:SetColor(info.showColor)
	end 

    self.m_Label:SetActive(info.id == nil)

    self.m_Lock:SetActive(not info.isUnLock)

    
end

return CColorBox
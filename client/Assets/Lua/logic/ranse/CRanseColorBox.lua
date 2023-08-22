local CRanseColorBox = class("CRanseColorBox", CBox)

function CRanseColorBox.ctor(self, obj)

	CBox.ctor(self, obj)

	self.m_ColorPanel = self:NewUI(1, CSprite)
	self.m_Name = self:NewUI(2, CLabel)
	self.m_Select = self:NewUI(3,CSprite)

	self.m_ColorIndex = nil

	self.m_IsDefault = false

end


function CRanseColorBox.SetInfo(self, info)
	
	self.m_ColorIndex = info.id
	self.m_ColorPanel:SetColor(info.color)

end

function CRanseColorBox.SetDefaultState(self)
	
	self.m_ColorIndex = 0
	self.m_ColorPanel:SetSpriteName("h7_bu_mo")
	self.m_Name:SetActive(true)
	self.m_IsDefault = true

end

function CRanseColorBox.IsDefault(self)
	return self.m_IsDefault
end



return CRanseColorBox
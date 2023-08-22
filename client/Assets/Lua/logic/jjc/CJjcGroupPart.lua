local CJjcGroupPart = class("CJjcGroupPart", CPageBase)

function CJjcGroupPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_DetailBox = self:NewUI(1, CJjcGroupDetailBox)
	self.m_ChooseBox = self:NewUI(2, CJjcGroupChooseBox)	

	self:InitContent()
end

function CJjcGroupPart.InitContent(self)
	
end

function CJjcGroupPart.ShowDetailBox(self)
	self.m_DetailBox:SetActive(true)
	self.m_ChooseBox:SetActive(false)
end

function CJjcGroupPart.ShowChooseBox(self)
	self.m_DetailBox:SetActive(false)
	self.m_ChooseBox:SetActive(true)
end

return CJjcGroupPart
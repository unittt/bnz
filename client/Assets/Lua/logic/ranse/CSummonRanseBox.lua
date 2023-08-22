local CSummonRanseBox = class("CSummonRanseBox", CBox)

function CSummonRanseBox.ctor(self, obj)

	CBox.ctor(self, obj)

	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Name = self:NewUI(2, CLabel)
	self.m_Grade = self:NewUI(3,CLabel)
	self.m_SelectName = self:NewUI(4, CLabel)
	self.m_Info = nil
	
end

function CSummonRanseBox.SetInfo(self, info)

	self.m_Info = info
	self.m_Name:SetText(info.basename)
	self.m_SelectName:SetText(info.basename)
	self.m_Grade:SetText("等级：" .. info.grade)
	self.m_Icon:SpriteAvatar(info.model_info.shape)

end



return CSummonRanseBox
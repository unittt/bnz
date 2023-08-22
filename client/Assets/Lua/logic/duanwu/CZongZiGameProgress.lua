local CZongZiGameProgress = class("CZongZiGameProgress", CBox)

function CZongZiGameProgress.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_CurPoint = self:NewUI(1, CLabel)
	self.m_Slider = self:NewUI(2, CSlider)
	self.m_Icon = self:NewUI(3, CSprite)
	self.m_Name = self:NewUI(4, CLabel)

end

function CZongZiGameProgress.RefreshInfo(self, info)

	self.m_CurPoint:SetText(info.point)
	self.m_Icon:SetSpriteName(info.icon)
	self.m_Name:SetText(info.name)
	local v = 1
	if info.point <= info.max then 
		v = info.point / info.max 
	end
	self.m_Slider:SetValue(v)

end 

return CZongZiGameProgress
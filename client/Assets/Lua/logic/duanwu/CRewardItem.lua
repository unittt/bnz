local CRewardItem = class("CRewardItem", CBox)

function CRewardItem.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Point = self:NewUI(2, CLabel)
	self.m_Slider = self:NewUI(3, CSlider)
	self.m_EffectIcon = self:NewUI(4, CSprite)
	self.m_Cnt = self:NewUI(5, CLabel)
	self:AddUIEvent("click", callback(self, "OnClickItem"))

end

function CRewardItem.RefreshInfo(self, stepInfo, cb)

	self.m_StepInfo = stepInfo
	self.m_Point:SetText(stepInfo.target)
	self.m_Icon:SpriteItemShape(stepInfo.icon)
	local v = stepInfo.curV / stepInfo.maxV 
	self.m_Slider:SetValue(v)
	self.m_Icon:SetGrey(stepInfo.hadReward)
	self.m_EffectIcon:SetActive(stepInfo.canReward)
	self.m_Cnt:SetText(stepInfo.cnt)
	self.m_Cb = cb

end 

function CRewardItem.OnClickItem(self)

	if self.m_Cb then 
		self.m_Cb(self)
	end 

end 

return CRewardItem
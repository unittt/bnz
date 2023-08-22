local CHorseLearnSkillItem = class("CHorseLearnSkillItem", CBox)

function CHorseLearnSkillItem.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Level = self:NewUI(2, CLabel)
	self.m_NoneIcon = self:NewUI(3, CSprite)

end

function CHorseLearnSkillItem.SetInfo(self, id)

	local dataItem = data.ridedata.SKILL[id]
	self.m_Data = dataItem
	self.m_Icon:SpriteSkill(tostring(dataItem.icon))
	self.m_Icon:SetActive(true)
	self:AddUIEvent("click", callback(self, "OnShowTips", id))
	local level = g_HorseCtrl:GetSkillLevel(id)
	self.m_Level:SetText(level)
	self.m_Level:SetActive(true)

	self.m_NoneIcon:SetActive(false)

end

function CHorseLearnSkillItem.ResetItem(self)
	
	self.m_Icon:SetActive(false)
	self.m_Level:SetActive(false)
	self.m_NoneIcon:SetActive(true)
	self.m_Cb = nil
	self:DelUIEvent("click")

end

function CHorseLearnSkillItem.OnShowTips(self, id)
	
 	if self.m_Cb then 
 		self.m_Cb(id)
 	end 

end

function  CHorseLearnSkillItem.AddCb(self, cb)
	
	self.m_Cb = cb

end

return CHorseLearnSkillItem
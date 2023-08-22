local CHorsePreviewSkillRowBox = class("CHorsePreviewSkillRowBox", CBox)

function CHorsePreviewSkillRowBox.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_ItemBox_0 = self:NewUI(1, CHorsePreviewItem)
	self.m_ItemBox_1 = self:NewUI(2, CHorsePreviewItem)
	self.m_ItemBox_2 = self:NewUI(3, CHorsePreviewItem)
	self.m_ItemBox_3 = self:NewUI(4, CHorsePreviewItem)
	self.m_ItemBox_4 = self:NewUI(5, CHorsePreviewItem)

end

function CHorsePreviewSkillRowBox.SetInfo(self, skillList)

	self.m_ItemBox_0:SetInfo(skillList[1])

	local advList = skillList[2]

	for k, v in ipairs(advList) do 
		local name = "m_ItemBox_" .. tostring(k)
		self[name]:SetInfo(v)
	end 

end


return CHorsePreviewSkillRowBox
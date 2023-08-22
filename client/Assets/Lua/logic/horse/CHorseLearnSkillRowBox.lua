local CHorseLearnSkillRowBox = class("CHorseLearnSkillRowBox", CBox)

function CHorseLearnSkillRowBox.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_ItemBox_1 = self:NewUI(1, CHorseLearnSkillItem)
	self.m_ItemBox_2 = self:NewUI(2, CHorseLearnSkillItem)
	self.m_ItemBox_3 = self:NewUI(3, CHorseLearnSkillItem)

end

function CHorseLearnSkillRowBox.SetInfo(self, index, id)

	local s = "m_ItemBox_" .. tostring(index)
	if self[s] then 
		self[s]:SetInfo(id)
	end

end

function CHorseLearnSkillRowBox.ResetRowItem(self)
	
	for i = 1, 3 do 
		local s = "m_ItemBox_" .. tostring(i)
		if self[s] then 
			self[s]:ResetItem()
		end
	end 

end

function CHorseLearnSkillRowBox.AddCb(self, cb)
	
	for i = 1, 3 do 
		local s = "m_ItemBox_" .. tostring(i)
		if self[s] then 
			self[s]:AddCb(cb)
		end
	end 

end

return CHorseLearnSkillRowBox
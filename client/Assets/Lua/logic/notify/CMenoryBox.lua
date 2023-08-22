local CMenoryBox = class("CMenoryBox", CBox)

function CMenoryBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_LabelClone = self:NewUI(2, CLabel)
	self.m_LabelClone:SetActive(false)
end

function CMenoryBox.SetMenoryInfo(self, monery)
	if monery and monery > 0 then
		local oLabel = self.m_LabelClone:Clone()
		oLabel:SetActive(true)
		oLabel:SetText("Lua使用内存：" .. string.format("%0.2f", monery/1024) .. "MB")
		self.m_Grid:AddChild(oLabel)
	end
end

return CMenoryBox


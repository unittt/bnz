local CHorseMapItem = class("CHorseMapItem", CBox)

function CHorseMapItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Name = self:NewUI(2, CLabel)
	self.m_Tex = self:NewUI(3, CTexture)
	--self.m_Flag = self:NewUI(4, CSprite)
	--self.m_NotActive = self:NewUI(5, CSprite)

	self.m_Tex:SetActive(false)
	--self.m_Flag:SetActive(false)

end

function CHorseMapItem.SetData(self, data, cb)

	self.m_Id = data.id
	self.m_ClickCb = cb

	self.m_Name:SetText(data.name)
	self.m_Tex:LoadTexture("Horse", data.mapIcon)
	self.m_Tex:SetActive(true)

	self:AddUIEvent("click", callback(self, "OnClickItem", self.m_Id))

	self:RefreshState()
 

end

function CHorseMapItem.RefreshState(self)
	
	if self.m_Id then 
		if  g_HorseCtrl:IsHorseActive(self.m_Id) then 
		--已激活
			self.m_Tex:SetGray(false)
		else 
		--不能激活，变灰
			self.m_Tex:SetGray(true)
		end 
	end 
	
end

function CHorseMapItem.OnClickItem(self, horseId)
	

	if self.m_ClickCb then 

		self.m_ClickCb(horseId)

	end 

end

return CHorseMapItem
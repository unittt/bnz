local CHorseWenShiSubItemBox = class("CHorseWenShiSubItemBox", CBox)

local namePos = Vector3.New(16, 23.5, 0)
local buyPos = Vector3.New(16, 0, 0)

function CHorseWenShiSubItemBox.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_Name = self:NewUI(1, CLabel)
	self.m_Icon = self:NewUI(2, CSprite)
	self.m_Grade = self:NewUI(3, CLabel)
    self.m_Toggle = self:NewUI(4, CWidget)
    self.m_AddIcon = self:NewUI(5, CWidget)
    self.m_CName = self:NewUI(6, CLabel)
   
    self.m_Toggle:AddUIEvent("click", callback(self, "OnClickBtn"))  

end

function CHorseWenShiSubItemBox.SetInfo(self, info, cb)

	if info.colorType then 
		self.m_ColorType = info.colorType
		self.m_Icon:SetActive(false)
		self.m_Name:SetText("购买")
		self.m_CName:SetText("购买")
		self.m_Name:SetLocalPos(buyPos)
		self.m_CName:SetLocalPos(buyPos)
		self.m_Grade:SetActive(false)
		self.m_AddIcon:SetActive(true)
	else
		self.m_Id = info.id
		self.m_Name:SetText(info.name)
		self.m_CName:SetText(info.name)
		self.m_Icon:SpriteItemShape(info.icon)
		self.m_Grade:SetText(info.grade .. "级")
		self.m_Icon:SetActive(true)
		self.m_Grade:SetActive(true)
		self.m_AddIcon:SetActive(false)
		self.m_Name:SetLocalPos(namePos)
		self.m_CName:SetLocalPos(namePos)
	end 

	self.m_Cb = cb

end

function CHorseWenShiSubItemBox.OnClickBtn(self)
	
	if self.m_Cb then 
		self.m_Cb()
	end 

end

function CHorseWenShiSubItemBox.GetItemHeight(self)
	
	return self.m_Toggle:GetHeight()

end

function CHorseWenShiSubItemBox.Clear(self)
	
	self.m_ColorType = nil
	self.m_Toggle:ForceSelected(false)

end

return CHorseWenShiSubItemBox
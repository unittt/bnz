local CHorseActiveConditionBox = class("CHorseActiveConditionBox", CBox)

function CHorseActiveConditionBox.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Name = self:NewUI(2, CLabel)
	self.m_Count = self:NewUI(3, CLabel)
	self.m_Box = self:NewUI(4, CWidget)
	self.m_ItemNode = self:NewUI(5, CObject)
	self.m_Label = self:NewUI(6, CLabel)

	self.m_Box:AddUIEvent("click", callback(self, "OnClickItem"))

end


function CHorseActiveConditionBox.SetInfo(self, info)

	if info.type == "item" then
		self.m_ItemId = info.id
		self.m_ItemNode:SetActive(true)
		self.m_Label:SetActive(false)
		local itemData = DataTools.GetItemData(self.m_ItemId)
		self.m_Icon:SetSpriteName(tostring(itemData.icon))
		self.m_Name :SetText(itemData.name)
		local itemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
		self.m_Count:SetText("数量:" .. tostring(itemCount) .. "/" .. tostring(info.count))

	else
		self.m_ItemNode:SetActive(false)
		self.m_Label:SetActive(true)
		self.m_Label:SetText("[284B4D]" .. info.name .. "[-][8E6643]" .. info.condition .. "[-]")

	end 

end


function CHorseActiveConditionBox.OnClickItem(self)
	
	if not self.m_ItemId then 
		return
	end 

	g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemId)

end


return CHorseActiveConditionBox
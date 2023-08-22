local CWenShiAttrItem = class("CWenShiAttrItem", CBox)

function CWenShiAttrItem.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_Attr = self:NewUI(1, CBox)
	self.m_LockBtn = self:NewUI(2, CWidget)
	self.m_Icon = self:NewUI(3, CSprite)
	self.m_Count = self:NewUI(4, CLabel)

	self.m_LockBtn:AddUIEvent("click", callback(self, "OnClickLockBtn"))

end

function CWenShiAttrItem.GetData(self)
	
	return self.m_Data 

end

--{attrName, attrValue, icon, count, index}
function CWenShiAttrItem.SetData(self, data, cb)

	self.m_Data = data
	local name = data.attrName
	local value = data.attrValue
	local icon = data.icon
	local count = data.count
	self.m_Count:SetText(count)
	self.m_Attr.name = self.m_Attr:NewUI(1, CLabel)
	self.m_Attr.attr = self.m_Attr:NewUI(2, CLabel)
	local strlen = string.utfStrlen(name)
	if strlen <= 2 then 
	     self.m_Attr.name:SetSpacingX(34)
	elseif strlen == 3 then 
	    self.m_Attr.name:SetSpacingX(8)
	else
	    self.m_Attr.name:SetSpacingX(0)
	end 

	self.m_Attr.name:SetText(name)
	self.m_Attr.attr:SetText(":" .. value)
	self.m_Icon:SetActive(true)
	self.m_Cb = cb
	
end

function CWenShiAttrItem.ClearState(self)
	
	self.m_Cb = nil
	if self.m_LockBtn:GetSelected() then 
		self.m_LockBtn:ForceSelected(false)
	end 

end

function CWenShiAttrItem.OnClickLockBtn(self)
	
	if self.m_Cb then 
		self.m_Cb(self.m_Data)
	end 

end

return CWenShiAttrItem
local CItemGainWayItemBox = class("CItemGainWayItemBox", CBox)

function CItemGainWayItemBox.ctor(self, ...)
	local tDateTb = {...}
	CBox.ctor(self, tDateTb[1])
	self.m_GameObejct = tDateTb[1]
	self.m_ItemIndex = tDateTb[2]

	self:InitBox()
	self:SetItemInfo()
end

function CItemGainWayItemBox.InitBox(self)
	self.Item = self:NewUI(1, CObject)
	self.Icon = self:NewUI(2, CSprite)
	self.Button = self:NewUI(3, CButton)
	self.NameLabel = self:NewUI(4, CLabel)

	self.Button:AddUIEvent("click", callback(self, "OnClickBox"))
end

function CItemGainWayItemBox.SetItemInfo(self)
	self.Icon:SetSpriteName("10001")
	self.NameLabel:SetText(tostring(self.m_ItemIndex))
end

function CItemGainWayItemBox.OnClickBox(self)
	printc("TODO >>> 点击获取途径物品图标 | 下标：", self.m_ItemIndex)
end

return CItemGainWayItemBox
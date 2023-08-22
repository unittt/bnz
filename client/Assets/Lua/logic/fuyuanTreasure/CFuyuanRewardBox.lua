local CFuyuanRewardBox = class("CFuyuanRewardBox", CBox)

function CFuyuanRewardBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSprite = self:NewUI(1, CSprite)
	self.m_Quality = self:NewUI(2, CSprite)

	self.m_IconSprite:AddUIEvent("click", callback(self, "OnClickRewardItem"))

end

function CFuyuanRewardBox.SetData(self, data)

	self.m_ItemData = DataTools.GetItemData(data)
	self.m_IconSprite:SpriteItemShape(self.m_ItemData.icon)
	local quality = g_ItemCtrl:GetQualityVal(self.m_ItemData.id, self.m_ItemData.quality or 0 )
	self.m_Quality:SetItemQuality(quality)

end

function CFuyuanRewardBox.OnClickRewardItem(self)

	local config = {widget = self}
	g_WindowTipCtrl:SetWindowItemTip(self.m_ItemData.id, config)

end

return CFuyuanRewardBox
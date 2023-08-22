local CWindowGemStoneTipView = class("CWindowGemStoneTipView", CViewBase)

function CWindowGemStoneTipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/WindowGemStoneTipView.prefab", cb)
	self.m_DepthType = "Dialog"
	-- self.m_ExtendClose = "ClickOut"
end

function CWindowGemStoneTipView.OnCreateView(self)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_DescLabel = self:NewUI(2, CLabel)
	self.m_TipWidget = self:NewUI(3, CWidget)
	self.m_ItemSpr = self:NewUI(4, CSprite)

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CWindowGemStoneTipView.SetInfo(self, iItemId, lAttr, iGrade)
	local dItemData = DataTools.GetItemData(iItemId)

	self.m_NameLabel:SetText(iGrade.."级"..dItemData.name)
	self.m_ItemSpr:SpriteItemShape(dItemData.icon)

	local sAttr = ""
	for i,sAttrKey in ipairs(lAttr) do
		local sAttrName = data.attrnamedata.DATA[sAttrKey].name
		local dAttrData = DataTools.GetGemStoneAttrData(iItemId, iGrade, sAttrKey)
		sAttr = string.format("%s%s +%d\n", sAttr, sAttrName, dAttrData.value)
	end
	self.m_DescLabel:SetText(sAttr)
end

return CWindowGemStoneTipView
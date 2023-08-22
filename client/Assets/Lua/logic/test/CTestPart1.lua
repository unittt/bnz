local CTestPart1 = class("CTestPart1", CPageBase)

function CTestPart1.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTestPart1.OnInitPage(self)
	self.m_Label = self:NewUI(1, CLabel)
	self.m_Sprite = self:NewUI(2, CSprite)
	self.m_ActorTexture = self:NewUI(3, CActorTexture)
	self.m_ActorTexture:ChangeShape(101)
	self.m_Label:SetText("已初始化1")

	self.m_TipsBtn = self:NewUI(4, CButton)
	self.m_TipBox = self:NewUI(5, CSprite)
	-- UITools.NearTarget(self.m_TipsBtn, self.m_TipBox, enum.UIAnchor.Side.BottomRight)
	
	self.m_TipsBtn:SetHint("?????????????????????XXXXXXXXXXXXXXXXXXXXXXX\n\ncc")
	-- g_UITouchCtrl:AddClickHideObj(self.m_TipBox, function() self.m_TipBox:SetActive(false) end)
	--初始化各个子控件
	-- self.m_Sprite:SpriteItemShape(12002)
end

return CTestPart1
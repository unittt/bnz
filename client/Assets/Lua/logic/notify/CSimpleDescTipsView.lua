local CSimpleDescTipsView = class("CSimpleDescTipsView", CViewBase)

function CSimpleDescTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/SimpleDescTipsView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CSimpleDescTipsView.OnCreateView(self)
	self.m_BgSp = self:NewUI(1, CSprite)
	self.m_DescLbl = self:NewUI(2, CLabel)
	
	self:InitContent()
end

function CSimpleDescTipsView.InitContent(self)
	
end

function CSimpleDescTipsView.RefreshUI(self, oText)
	self.m_DescLbl:SetText(oText)
end

return CSimpleDescTipsView
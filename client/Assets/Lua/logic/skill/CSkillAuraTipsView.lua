local CSkillAuraTipsView = class("CSkillAuraTipsView", CViewBase)

function CSkillAuraTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Skill/SkillAuraTipsView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CSkillAuraTipsView.OnCreateView(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_TitleLbl = self:NewUI(2, CLabel)
	self.m_DescLbl = self:NewUI(3, CLabel)
	self.m_BgSp = self:NewUI(4, CSprite)
	
	self:InitContent()
end

function CSkillAuraTipsView.InitContent(self)
	
end

function CSkillAuraTipsView.RefreshUI(self, oDesc)
	self.m_DescLbl:SetText(oDesc)
	self.m_BgSp:SetAnchorTarget(self.m_DescLbl.m_GameObject, 0, 0, 0, 0)
	self.m_BgSp:SetAnchor("leftAnchor", -10, 0)
	self.m_BgSp:SetAnchor("topAnchor", 85, 1)
    self.m_BgSp:SetAnchor("bottomAnchor", -16, 0)
    self.m_BgSp:SetAnchor("rightAnchor", 11, 1)
	self.m_BgSp:ResetAndUpdateAnchors()
end

return CSkillAuraTipsView
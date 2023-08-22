local COrgSkillLinkView = class("COrgSkillLinkView", CViewBase)

function COrgSkillLinkView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Skill/OrgSkillLinkView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_GroupName = "main"
end

function COrgSkillLinkView.OnCreateView(self)
	-- self.m_ShortGrid = self:NewUI(1, CGrid)
	self.m_ShortLabel = self:NewUI(2, CLabel)
	-- self.m_LongGrid = self:NewUI(3, CGrid)
	self.m_LongLabel = self:NewUI(4, CLabel)
	self.m_TitleLabel = self:NewUI(5, CLabel)
end

function COrgSkillLinkView.SetSkillData(self, skillid, title, level, desc)
	self.m_ID = skillid
	self.m_TitleLabel:SetText(title)
	self.m_ShortLabel:SetText("当前等级:"..level.."级")
	self.m_LongLabel:SetText(desc)
end

return COrgSkillLinkView
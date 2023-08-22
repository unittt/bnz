local COrgMatchRankBox = class("COrgMatchRankBox", CBox)

function COrgMatchRankBox.ctor(self, obj)
	CBox.ctor(self, obj)
	--界面设置
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
	self.m_DetailInfoBoxL = self:NewUI(1, CBox)
	self.m_DetailInfoBoxR = self:NewUI(2, CBox)
	self.m_MyScoreL = self:NewUI(3, CLabel)
	self.m_MyRankL = self:NewUI(4, CLabel)
	self.m_BgTexture = self:NewUI(5, CTexture)

	self.m_ExpandH = 304
	self.m_HideH = 110

	self:InitContent()
end

function COrgMatchRankBox.InitContent(self)
	self:InitOrgRankBox(self.m_DetailInfoBoxL)
	self:InitOrgRankBox(self.m_DetailInfoBoxR)

	self:RefreshAll()
end

function COrgMatchRankBox.InitOrgRankBox(self, oBox)
	oBox.m_ScoreL = oBox:NewUI(1, CLabel)
	oBox.m_OrgNameL = oBox:NewUI(2, CLabel)
	oBox.m_ScrollView = oBox:NewUI(3, CScrollView)
	oBox.m_OrgMemberGrid = oBox:NewUI(4, CGrid)
	oBox.m_OrgMemberBox = oBox:NewUI(5, CBox)
	oBox.m_ScrollAreaW = oBox:NewUI(6, CWidget)
	oBox.m_OrgMemberBox:SetActive(false)
	oBox.m_ScrollAreaW:SetActive(false)
	oBox.m_OrgMemberBoxs = {}
end

function COrgMatchRankBox.RefreshAll(self)
	local lOrgInfo = g_OrgMatchCtrl:GetOrgDetailInfo()
	self:RefreshDetailInfo(self.m_DetailInfoBoxL, lOrgInfo[1])
	self:RefreshDetailInfo(self.m_DetailInfoBoxR, lOrgInfo[2])
end

function COrgMatchRankBox.RefreshDetailInfo(self, oBox, dInfo)
	if not dInfo then
		return
	end

	oBox.m_ScoreL:SetText(dInfo.org_score)
	oBox.m_OrgNameL:SetText(dInfo.org_name)

	local lOrgMember = table.copy(dInfo.score_list)
	for i,v in ipairs(lOrgMember) do
		if not v.score then
			v.score = 0
		end
	end
	local function sort(d1, d2)
		return d1.score > d2.score
	end
	table.sort(lOrgMember, sort)

	for i,oBox in ipairs(oBox.m_OrgMemberBoxs) do
		oBox:SetActive(false)
	end

	for iRank,dOrgMember in ipairs(lOrgMember) do
		local oMemberBox = oBox.m_OrgMemberBoxs[iRank]
		if not oMemberBox then
			oMemberBox = self:CreateOrgMemberBox(oBox.m_OrgMemberBox)
			oBox.m_OrgMemberGrid:AddChild(oMemberBox)
			oBox.m_OrgMemberBoxs[iRank] = oMemberBox
		end
		self:UpdateOrgMemberBox(oMemberBox, dOrgMember, iRank)
	end

	oBox.m_OrgMemberGrid:Reposition()
end

function COrgMatchRankBox.CreateOrgMemberBox(self, oCloneBox, dInfo, iRank)
	local oBox = oCloneBox:Clone()
	oBox.m_RankL = oBox:NewUI(1, CLabel)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_ScoreL = oBox:NewUI(3, CLabel)
	return oBox
end

function COrgMatchRankBox.UpdateOrgMemberBox(self, oBox, dInfo, iRank)
	oBox:SetActive(true)
	oBox.m_RankL:SetText(iRank)
	oBox.m_NameL:SetText(dInfo.name)
	oBox.m_ScoreL:SetText(dInfo.score)

	if dInfo.pid == g_AttrCtrl.pid then
		self:RefreshMyInfo(iRank, dInfo.score)
	end
end

function COrgMatchRankBox.RefreshMyInfo(self, iRank, iScore)
	self.m_MyScoreL:SetText(iScore)
	self.m_MyRankL:SetText(iRank)
end

function COrgMatchRankBox.ExpandBox(self, bIsExpand)
	local iHeight = bIsExpand and self.m_ExpandH or self.m_HideH
	self.m_BgTexture:SetHeight(iHeight)
	self.m_DetailInfoBoxL.m_ScrollView:SetActive(bIsExpand)
	self.m_DetailInfoBoxR.m_ScrollView:SetActive(bIsExpand)
	self.m_DetailInfoBoxL.m_ScrollAreaW:SetActive(bIsExpand)
	self.m_DetailInfoBoxR.m_ScrollAreaW:SetActive(bIsExpand)
end

return COrgMatchRankBox
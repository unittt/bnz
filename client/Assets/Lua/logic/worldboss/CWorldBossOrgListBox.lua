local CWorldBossOrgListBox = class("CWorldBossOrgListBox", CBox)

function CWorldBossOrgListBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_OrgBoxClone = self:NewUI(3, CBox)
	self.m_RankL = self:NewUI(4, CLabel)
	self.m_ScoreL = self:NewUI(5, CLabel)
	self.m_AmountL = self:NewUI(6, CLabel)
	self.m_OrgLeaderL = self:NewUI(7, CLabel)

	self:InitContent()
end

function CWorldBossOrgListBox.InitContent(self)
	self.m_OrgBoxClone:SetActive(false)
end

function CWorldBossOrgListBox.RefreshAll(self)
	self:RefreshOrgGrid()
	self:RefreshMyOrgInfo()
end

function CWorldBossOrgListBox.RefreshOrgGrid(self)
	self.m_Grid:Clear()
	local tOrgList = g_WorldBossCtrl:GetOrgList()
	for i,dOrg in ipairs(tOrgList) do
		local oBox = self:CreateOrgBox()
		self.m_Grid:AddChild(oBox)
		self:UpdateOrgBox(oBox, dOrg, i)
	end
	self.m_Grid:Reposition()
end

function CWorldBossOrgListBox.CreateOrgBox(self)
	local oBox = self.m_OrgBoxClone:Clone()
	oBox.m_RankL = oBox:NewUI(1, CLabel)
	oBox.m_OrgNameL = oBox:NewUI(2, CLabel)
	oBox.m_AmountL = oBox:NewUI(3, CLabel)
	oBox.m_OrgLeaderL = oBox:NewUI(4, CLabel)
	oBox.m_ScoreL = oBox:NewUI(5, CLabel)
	oBox.m_RankSpr = oBox:NewUI(6, CSprite)
	return oBox
end

function CWorldBossOrgListBox.UpdateOrgBox(self, oBox, dOrg, iRank)
	oBox.m_RankL:SetActive(iRank > 3)
	oBox.m_RankSpr:SetActive(iRank <= 3)
	oBox.m_RankSpr:SetSpriteName("h7_no"..iRank)
	oBox.m_RankL:SetText(iRank)
	oBox.m_OrgNameL:SetText(dOrg.org_name)
	oBox.m_AmountL:SetText(dOrg.total)
	oBox.m_ScoreL:SetText(dOrg.point)
	oBox.m_OrgLeaderL:SetText(dOrg.chairman)
	if dOrg.org_id == g_AttrCtrl.org_id then
		local color = Color.RGBAToColor("a64e00")
		oBox.m_RankL:SetColor(color)
		oBox.m_OrgNameL:SetColor(color)
		oBox.m_AmountL:SetColor(color)
		oBox.m_ScoreL:SetColor(color)
		oBox.m_OrgLeaderL:SetColor(color)
	end
	oBox:SetActive(true)
end

function CWorldBossOrgListBox.RefreshMyOrgInfo(self)
	local dInfo = g_WorldBossCtrl:GetMyOrgInfo()
	self.m_RankL:SetText(dInfo.rank)
	self.m_ScoreL:SetText(dInfo.point)
	self.m_AmountL:SetText(dInfo.total)
	self.m_OrgLeaderL:SetText(dInfo.chairman)
end
return CWorldBossOrgListBox
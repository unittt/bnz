local CPartnerFormationPart = class("CPartnerFormationPart", CPageBase)

function CPartnerFormationPart.ctor(self, obj)
	CPageBase.ctor(self, obj)

	self.m_Grid = self:NewUI(1, CGrid)
	self.m_FormationBoxClone = self:NewUI(2, CPartnerFormationBox)
	self:OnInitPage()
end

function CPartnerFormationPart.OnShowPage(self)
	self.m_ParentView.m_CloseBtn:SetLocalScale(Vector3.New(1, 1, 1))
	self.m_ParentView.m_CloseBtn:MakePixelPerfect()
	self.m_ParentView.m_CloseBtn:SetLocalPos(Vector3.New(442, 296, 0))
end

function CPartnerFormationPart.OnInitPage(self)
	self.m_FormationBoxClone:SetActive(false)
	self:InitFormationBoxs()
end

function CPartnerFormationPart.InitFormationBoxs(self)
	self.m_Grid:Clear()
	for i = 1,3 do
		local oBox = self:CreateBox()
		self.m_Grid:AddChild(oBox)
	end
end

function CPartnerFormationPart.RefreshAll(self)
	for i = 1,3 do
		local oBox = self.m_Grid:GetChild(i)
		if i == g_PartnerCtrl:GetLocalLineup() then
			oBox:SetSelected(true)
		end 
		self:UpdateFormationBox(oBox, i)
	end
end

function CPartnerFormationPart.CreateBox(self)
	local oBox = self.m_FormationBoxClone:Clone()
	oBox:SetGroup(self.m_Grid:GetInstanceID())
	oBox:SetActive(true)
	oBox:AddUIEvent("click", callback(self, "OnClickFormationBox", oBox))
	return oBox
end

function CPartnerFormationPart.UpdateFormationBox(self, oBox, iIndex)
	if not oBox then
		return
	end
	oBox:SetLineupIndex(iIndex)
end

function CPartnerFormationPart.UpdateLineup(self, iIndex)
	local oBox = self.m_Grid:GetChild(iIndex)
	self:UpdateFormationBox(oBox, iIndex)
end

function CPartnerFormationPart.OnClickFormationBox(self, oBox)
	g_PartnerCtrl:SetLocalLineup(oBox.m_LineupIndex)
end

function CPartnerFormationPart.SetSelectedLineup(self, ilineupIndex)
	local oBox = self.m_Grid:GetChild(ilineupIndex)
	oBox:SetSelected(true)
	g_PartnerCtrl:SetLocalLineup(oBox.m_LineupIndex)
end

function CPartnerFormationPart.SetSelectedPartner(self, iLineupIndex, iPid)
	local oBox = self.m_Grid:GetChild(iLineupIndex)
	oBox:SetSelectedPartner(iPid)
end
return CPartnerFormationPart
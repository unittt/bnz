local CWarCT = class("CWarCT", CBox)

function CWarCT.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_BoutLabel = self:NewUI(1, CLabel)
	self.m_LeftFormaSpr = self:NewUI(2, CSprite)
	self.m_RightFormaSpr = self:NewUI(3, CSprite)
	self.m_LeftFormaSpr:AddUIEvent("click", callback(self, "OnLeftFormation"))
	self.m_RightFormaSpr:AddUIEvent("click", callback(self, "OnRightFormation"))
	self:Bout()
end

function CWarCT.OnLeftFormation(self)
	CWarFormationInfoView:ShowView(function(oView)
		oView:SetFormationInfo(g_WarCtrl.m_Fmt_id2, g_WarCtrl.m_Fmt_grade2, false, g_WarCtrl.m_Fmt_id1, g_WarCtrl.m_Fmt_grade1)
		UITools.NearTarget(self.m_LeftFormaSpr, oView.m_BgSpr, enum.UIAnchor.Side.Left)
	end)
end

function CWarCT.OnRightFormation(self)
	CWarFormationInfoView:ShowView(function(oView)
		oView:SetFormationInfo(g_WarCtrl.m_Fmt_id1, g_WarCtrl.m_Fmt_grade1, true, g_WarCtrl.m_Fmt_id2, g_WarCtrl.m_Fmt_grade2)
		UITools.NearTarget(self.m_RightFormaSpr, oView.m_BgSpr, enum.UIAnchor.Side.Right)
	end)
end

function CWarCT.Bout(self)
	local s = string.format("第%d回合", g_WarCtrl:GetBout())
	self.m_BoutLabel:SetText(s)
end

function CWarCT.RefreshFormation(self)
	local showfmt2 = g_WarCtrl.m_Fmt_id2 and g_WarCtrl.m_Fmt_id2 ~= 1
	self.m_LeftFormaSpr:SetActive(showfmt2)
	if showfmt2 then
		local dDataRight = data.formationdata.BASEINFO[g_WarCtrl.m_Fmt_id2]
		self.m_LeftFormaSpr:SetSpriteName(dDataRight.icon)
	end
	local showfmt1 = g_WarCtrl.m_Fmt_id1 and g_WarCtrl.m_Fmt_id1 ~= 1
	self.m_RightFormaSpr:SetActive(showfmt1)
	if showfmt1 then
		local dDataLeft = data.formationdata.BASEINFO[g_WarCtrl.m_Fmt_id1]
		self.m_RightFormaSpr:SetSpriteName(dDataLeft.icon)
	end
end

return CWarCT
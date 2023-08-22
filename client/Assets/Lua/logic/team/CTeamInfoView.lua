local CTeamInfoView = class("CTeamInfoView", CViewBase)

function CTeamInfoView.ctor(self, obj)
	CViewBase.ctor(self, "UI/Team/TeamInfoView.prefab", obj)

end

function CTeamInfoView.OnCreateView(self)
	self.m_ApplyBox = self:NewUI(1, CTeamHandyApplyBox)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_CloseBtn = self:NewUI(3, CButton)

	self:InitContent()
end

function CTeamInfoView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ApplyBox:SetCallback(callback(self, "OnClose"))
end

function CTeamInfoView.SetTeamInfo(self, dTeamInfo)
	self.m_TeamInfo = dTeamInfo
	self:InitTeamName()
	self:InitHandyApplyBox(dTeamInfo)
end

function CTeamInfoView.InitHandyApplyBox(self, dTeam)
	self.m_ApplyBox:SetHandyApply(dTeam)
end

function CTeamInfoView.InitTeamName(self)
	for k,member in pairs(self.m_TeamInfo.member) do
		if member.pid == self.m_TeamInfo.leader then
			local sName = member.status_info.name
			self.m_NameLabel:SetText(sName)
			break
		end
	end
end

return CTeamInfoView
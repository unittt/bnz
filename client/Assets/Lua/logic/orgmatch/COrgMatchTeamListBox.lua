local COrgMatchTeamListBox = class("COrgMatchTeamListBox", CBox)

function COrgMatchTeamListBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_TeamTable = self:NewUI(2, CTable)
	self.m_TeamBoxClone = self:NewUI(3, COrgMatchTeamBox)

	self.m_TeamBoxs = {}
	self:InitContent()
end

function COrgMatchTeamListBox.InitContent(self)
	self.m_TeamBoxClone:SetActive(false)
end

function COrgMatchTeamListBox.SetTeamList(self, tData)
	self.m_TeamList = tData
	self:RefreshTeamTable()
end

-- 设置监听器
function COrgMatchTeamListBox.SetCallback(self, leaderCB, memberCb)
	self.m_LeaderCb = leaderCB
	self.m_MemberCb = memberCb
end

function COrgMatchTeamListBox.RefreshTeamTable(self)
	-- self.m_TeamTable:Clear()
	if not self.m_TeamList then
		return
	end

	local iMax = math.max(#self.m_TeamBoxs, #self.m_TeamList)

	for i=1,iMax do
		local oBox = self.m_TeamBoxs[i]
		local dTeam = self.m_TeamList[i]
		if not oBox then
			oBox = self.m_TeamBoxClone:Clone()
			oBox:SetCallback(self.m_LeaderCb, self.m_MemberCb)
			self.m_TeamBoxs[i] = oBox
			self.m_TeamTable:AddChild(oBox)
		end
		if dTeam then
			oBox:SetActive(true)
			oBox:SetTeamData(dTeam)
		else
			oBox:SetActive(false)
		end
	end

	for i,dTeam in ipairs(self.m_TeamList) do
		
	end
	self.m_ScrollView:ResetPosition()
	self.m_TeamTable:RepositionLater()
end

function COrgMatchTeamListBox.HideOther(self, oTarget)
	for i,oBox in ipairs(self.m_TeamTable:GetChildList()) do
		if oBox ~= oTarget then
			oBox:ExpandSubMenu(false)
		end
	end
	self.m_TeamTable:Reposition()
end

return COrgMatchTeamListBox
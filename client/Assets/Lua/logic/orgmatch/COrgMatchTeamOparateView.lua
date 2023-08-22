local COrgMatchTeamOparateView = class("COrgMatchTeamOparateView", CViewBase)

function COrgMatchTeamOparateView.ctor(self, cb)
	CViewBase.ctor(self, "UI/OrgMatch/OrgMatchTeamOparateView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function COrgMatchTeamOparateView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_RefreshBtn = self:NewUI(2, CButton)
	self.m_InviteBtn = self:NewUI(3, CButton)
	self.m_TeamCntL = self:NewUI(4 ,CLabel)
	self.m_SingleCntL = self:NewUI(5, CLabel)
	self.m_SingleScroll = self:NewUI(6, CScrollView)
	self.m_SingleGrid = self:NewUI(7, CGrid)
	self.m_SingleBoxClone = self:NewUI(8, CBox)
	self.m_TeamListBox = self:NewUI(9, COrgMatchTeamListBox)

	self.m_SelectedPid = -1

	self:InitContent()
end

function COrgMatchTeamOparateView.InitContent(self)
	self.m_SingleBoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnClickRefresh"))
	self.m_InviteBtn:AddUIEvent("click", callback(self, "OnClickInvite"))
	self.m_TeamListBox:SetCallback(callback(self, "OnClickLeader"), callback(self, "OnClickMember"))

	g_OrgMatchCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlOrgMatchEvent"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTeamEvent"))

	self:RefreshAll()
end

function COrgMatchTeamOparateView.OnCtrlOrgMatchEvent(self, oCtrl)
	if oCtrl.m_EventID == define.OrgMatch.Event.RefreshTeamInfo then
		self:RefreshAll()
	end
end

function COrgMatchTeamOparateView.OnCtrlTeamEvent(self, oCtrl)
	-- TODO:可能需要監聽組隊的狀態刷新列表
	if oCtrl.m_EventID == define.Team.Event.AddTeam or 
		oCtrl.m_EventID == define.Team.Event.DelTeam then
		nethuodong.C2GSOrgWarOpenTeamUI()
	end
end

function COrgMatchTeamOparateView.Reset(self)
	self.m_SelectedPid = -1
end

---------------------------UI Refresh--------------------------------------
function COrgMatchTeamOparateView.RefreshAll(self)
	self:Reset()
	self:RefreshBaseStatus()
	self:RefreshSingleGrid()
	self:RefreshTeamListBox()
end

function COrgMatchTeamOparateView.RefreshBaseStatus(self)
	self.m_TeamCntL:SetText(g_OrgMatchCtrl:GetTeamCount())
	self.m_SingleCntL:SetText(g_OrgMatchCtrl:GetSingleCount())
end   

function COrgMatchTeamOparateView.RefreshSingleGrid(self)
	self.m_SingleScroll:ResetPosition()
	self.m_SingleGrid:Clear()

	local lSingle = g_OrgMatchCtrl:GetSingleList()
	for i,dPlayer in ipairs(lSingle) do
		local oBox = self:CreateSingleBox()
		self.m_SingleGrid:AddChild(oBox)
		self:UpdateSingleBox(oBox, dPlayer)
	end

	self.m_SingleGrid:Reposition()
end

function COrgMatchTeamOparateView.CreateSingleBox(self)
	local oBox = self.m_SingleBoxClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_SchoolSpr = oBox:NewUI(3, CSprite)
	oBox.m_SchoolL = oBox:NewUI(4, CLabel)
	oBox.m_GradeL = oBox:NewUI(5, CLabel)

	oBox:SetActive(true)
	oBox:SetGroup(self.m_SingleGrid:GetInstanceID())
	oBox:AddUIEvent("click", callback(self, "OnClickSingleBox"))
	return oBox
end

function COrgMatchTeamOparateView.UpdateSingleBox(self, oBox, dInfo)
	oBox.m_IconSpr:SpriteAvatar(dInfo.icon)
	oBox.m_NameL:SetText(dInfo.name)
	oBox.m_SchoolSpr:SpriteSchool(dInfo.school)
	oBox.m_GradeL:SetText(dInfo.grade)
	local tSchool = data.schooldata.DATA[dInfo.school]
	oBox.m_SchoolL:SetText(tSchool.name)
	oBox.m_Pid = dInfo.pid
end

function COrgMatchTeamOparateView.RefreshTeamListBox(self)
	self.m_TeamListBox:SetTeamList(g_OrgMatchCtrl:GetTeamList())
end
-----------------------------UI Click-------------------------------------------
function COrgMatchTeamOparateView.OnClickSingleBox(self, oBox)
	self.m_SelectedPid = oBox.m_Pid
end

function COrgMatchTeamOparateView.OnClickLeader(self, oBox)
	self.m_TeamListBox:HideOther(oBox)
end

function COrgMatchTeamOparateView.OnClickMember(self, oBox)
	-- body
end

function COrgMatchTeamOparateView.OnClickRefresh(self)
	nethuodong.C2GSOrgWarOpenTeamUI()
end

function COrgMatchTeamOparateView.OnClickInvite(self)
	if self.m_SelectedPid == -1 then
		g_NotifyCtrl:FloatMsg("请选择邀请目标")
		return
	end
	netteam.C2GSInviteTeam(self.m_SelectedPid)
end

return COrgMatchTeamOparateView
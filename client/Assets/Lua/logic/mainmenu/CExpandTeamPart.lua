local CExpandTeamPart = class("CExpandTeamPart", CPageBase)

function CExpandTeamPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandTeamPart.OnInitPage(self)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_SingleWidget = self:NewUI(3, CWidget)
	self.m_CreateBtn = self:NewUI(4, CButton)
	self.m_SearchBtn = self:NewUI(5, CButton)
	self.m_AutoMatchWidget = self:NewUI(6, CObject)
	self.m_TargetLabel = self:NewUI(7, CLabel)
	self.m_CancelButton = self:NewUI(8, CButton)
	self.m_MatchStautsL = self:NewUI(9, CLabel)
	self.m_BgSpr = self:NewUI(10, CSprite)
	self.m_InviteBoxClone = self:NewUI(11, CBox)

	self.m_MemberBoxs = {}
	self.m_Timer = nil
	self:InitContent()
end

function CExpandTeamPart.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_InviteBoxClone:SetActive(false)

	self.m_CreateBtn:AddUIEvent("click", callback(self, "OnCreate"))
	self.m_SearchBtn:AddUIEvent("click", callback(self, "OnSearch"))
	self.m_CancelButton:AddUIEvent("click", callback(self, "OnCancelAutoMatch"))
	self.m_TargetLabel:AddUIEvent("click", callback(self, "OnSearch"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_LingxiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLingxiEvent"))
	self:RefreshAll()
end

function CExpandTeamPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTeam or
		oCtrl.m_EventID == define.Team.Event.DelTeam or 
		oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch or 
		oCtrl.m_EventID == define.Team.Event.Reset or 
		oCtrl.m_EventID == define.Team.Event.RefreshFormationPos then
		self:RefreshAll()
	elseif oCtrl.m_EventID == define.Team.Event.MemberUpdate then
		for i=1,5 do
			local oBox = self.m_MemberBoxs[i]
			if oBox.m_Member and oBox.m_Member.pid == oCtrl.m_EventData.pid then
				self:UpdateMemberBox(oBox, oCtrl.m_EventData)
				break
			end
		end
	end
end

function CExpandTeamPart.OnLingxiEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Lingxi.Event.Match then
		self:RefreshAll()
	end
end

function CExpandTeamPart.ResetBg(self)
	-- local w,h = self.m_BgSpr:GetSize()
	-- if not g_TeamCtrl:IsJoinTeam() then
	-- 	h = 195
	-- else
	-- 	h = 390
	-- end
	-- self.m_BgSpr:SetSize(w, h)
end

function CExpandTeamPart.RefreshAll(self)
	self.m_SingleWidget:SetActive(not g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsPlayerAutoMatch() and not g_LingxiCtrl.m_IsLingxiMatching)
	self:HideTeamMemberOpView()
	self:RefreshGrid()
	self:RefreshTargetPanel()
	self:ResetBg()
end

function CExpandTeamPart.HideTeamMemberOpView(self)
	if self.m_SingleWidget:GetActive() then
		local oOpenView = CTeamMemberOpView:GetView()
		if oOpenView then
			oOpenView:CloseView()
		end
	end
end

function CExpandTeamPart.RefreshTargetPanel(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	self.m_AutoMatchWidget:SetActive(g_TeamCtrl:IsPlayerAutoMatch() or g_LingxiCtrl.m_IsLingxiMatching)
	if not g_TeamCtrl:IsPlayerAutoMatch() and not g_LingxiCtrl.m_IsLingxiMatching then
		return
	end
	local oName
	if g_TeamCtrl:IsPlayerAutoMatch() then
		local iTargetId = g_TeamCtrl:GetPlayerAutoTarget()
		local tData = data.teamdata.AUTO_TEAM[iTargetId]
		oName = tData.name
		self.m_IsInMatchingIndex = 1
	elseif g_LingxiCtrl.m_IsLingxiMatching then
		oName = "灵犀任务"
		self.m_IsInMatchingIndex = 2
	end

	self.m_TargetLabel:SetText("[u]"..oName.."[/u]")
	local sMatch = "正在匹配"
	local tPoint = {"...", "..", "."} 
	local iIndex = 1
	local update = function()
		self.m_MatchStautsL:SetText(sMatch..tPoint[iIndex])
		iIndex = (iIndex + 1)%3 + 1
		return self.m_AutoMatchWidget:GetActive()
	end
	self.m_Timer = Utils.AddTimer(update, 0.5, 0)
end

function CExpandTeamPart.ResetMemeberGrid(self)
	for i = 1, 6 do
		local oBox = self.m_MemberBoxs[i]
		if not oBox then
			if i == 6 then
				oBox = self:CreateInviteBox()
			else
				oBox = self:CreateMemberBox()
			end
			self.m_Grid:AddChild(oBox)
			self.m_MemberBoxs[i] = oBox
		end
		if oBox:GetActive() then
			oBox:SetActive(false)
		end
	end
end

function CExpandTeamPart.RefreshGrid(self)
	-- self.m_Grid:Clear()
	self:ResetMemeberGrid()
	local iCount = 5
	local lMemberList = g_TeamCtrl:GetMemberList()
	local bIsAutoMatch = g_TeamCtrl:IsTeamAutoMatch()
	local tTarget = g_TeamCtrl:GetTargetInfo()
	local tData = nil
	if #lMemberList == 0 then
		return
	end

	if bIsAutoMatch then
		tData = data.teamdata.AUTO_TEAM[tTarget.auto_target]
		iCount = tData.max_count
	end

	for i = 1, iCount do
		local dMember = lMemberList[i]
		local oBox = nil
		if dMember then
			oBox = self.m_MemberBoxs[i]
			self:UpdateMemberBox(oBox, dMember)
		else
			oBox = self.m_MemberBoxs[6]
			self:UpdateInviteBox(oBox, bIsAutoMatch)
			break
		end
	end
	self.m_Grid:Reposition()
end

function CExpandTeamPart.CreateInviteBox(self, bIsAutoMatch)
	local oBox = self.m_InviteBoxClone:Clone()
	oBox.m_TargetLabel = oBox:NewUI(1, CLabel)
	oBox.m_InviteBtn = oBox:NewUI(2, CButton)
	oBox.m_TipLabel = oBox:NewUI(3, CLabel)

	oBox.m_InviteBtn:AddUIEvent("click", callback(self, "OnInvite"))
	oBox:AddUIEvent("click", callback(self, "OpenTeamFiterView"))
	return oBox
end

function CExpandTeamPart.UpdateInviteBox(self, oBox, bIsAutoMatch)
	oBox:SetActive(true)
	if bIsAutoMatch then
		local tTarget = g_TeamCtrl:GetTargetInfo()
		local tData = data.teamdata.AUTO_TEAM[tTarget.auto_target]
		oBox.m_TargetLabel:SetText(tData.name)
	end
	oBox.m_TargetLabel:SetActive(bIsAutoMatch)
	oBox.m_TipLabel:SetActive(not bIsAutoMatch)
end

function CExpandTeamPart.CreateMemberBox(self)
	local oBox = self.m_BoxClone:Clone()
	oBox.m_IconSprite = oBox:NewUI(1, CSprite)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_GradeLabel = oBox:NewUI(3, CLabel)
	oBox.m_StautsLabel = oBox:NewUI(4, CLabel)
	oBox.m_HpSlider = oBox:NewUI(5, CSlider)
	oBox.m_MpSlider = oBox:NewUI(6, CSlider)
	oBox.m_SignSprite = oBox:NewUI(7, CSprite)
	oBox.m_SchoolSprite = oBox:NewUI(8, CSprite)
	oBox:AddUIEvent("click", callback(self, "OnMemberBox"))
	return oBox
end

function CExpandTeamPart.UpdateMemberBox(self, oBox, dMember)
	oBox:SetActive(true)
	oBox.m_Member = dMember
	if g_TeamCtrl:IsOffline(dMember.pid) then
		oBox.m_StautsLabel:SetActive(true)
		oBox.m_StautsLabel:SetColor(Color.RGBAToColor("fb3636"))
		oBox.m_StautsLabel:SetText("离线")
		oBox.m_IconSprite:SetGrey(true)
	elseif g_TeamCtrl:IsLeave(dMember.pid) then
		oBox.m_StautsLabel:SetActive(true)
		oBox.m_StautsLabel:SetColor(Color.RGBAToColor("808080"))
		oBox.m_StautsLabel:SetText("暂离")
		oBox.m_IconSprite:SetGrey(false)
	else
		oBox.m_StautsLabel:SetActive(false)
		oBox.m_IconSprite:SetGrey(false)
	end
	if dMember.pid == g_AttrCtrl.pid then
		oBox.m_NameLabel:SetColor(Color.RGBAToColor("2dffe9"))
		oBox.m_GradeLabel:SetColor(Color.RGBAToColor("2dffe9"))
	else
		oBox.m_NameLabel:SetColor(Color.RGBAToColor("ccebdb"))
		oBox.m_GradeLabel:SetColor(Color.RGBAToColor("ccebdb"))
	end
	oBox.m_NameLabel:SetText(dMember.name)
	oBox.m_GradeLabel:SetText(tostring(dMember.grade))

	local dPlayer = g_MapCtrl:GetPlayer(dMember.pid)
	local iHpRate = dMember.hp/dMember.max_hp
	local iMpRate = dMember.mp/dMember.max_mp
	oBox.m_HpSlider:SetValue(iHpRate)
	oBox.m_MpSlider:SetValue(iMpRate)

	oBox.m_IconSprite:SpriteAvatar(dMember.icon)
	oBox.m_SignSprite:SetActive(dMember.pid == g_AttrCtrl.pid)
	oBox.m_SchoolSprite:SpriteSchool(dMember.school)
end

function CExpandTeamPart.OnMemberBox(self, oBox)
	local oOpenView = CTeamMemberOpView:GetView()
	local function process(view)
		view:ShowExpandViewOp(oBox.m_Member.pid)
		view:ShowArrow()
		UITools.NearTarget(oBox, view.m_Bg, enum.UIAnchor.Side.Left, Vector2.New(-36, -10))
	end
	if oOpenView then
		if oOpenView.m_Pid ~= oBox.m_Member.pid then
			oOpenView:SetStrikeResult(true)
			process(oOpenView)
		end
	else
		CTeamMemberOpView:ShowView(function(oView)
				process(oView)
			end)
	end
end

function CExpandTeamPart.OnCreate(self)
	if not g_MapCtrl:IsTeamAllowed() then
		g_NotifyCtrl:FloatMsg("当前场景禁止组队")
		return
	end
	netteam.C2GSCreateTeam()
end

function CExpandTeamPart.OnSearch(self)
	-- g_NotifyCtrl:FloatMsg("加入队伍")
	if self.m_IsInMatchingIndex == 2 then
		return
	end
	if not g_MapCtrl:IsTeamAllowed() then
		g_NotifyCtrl:FloatMsg("当前场景禁止组队")
		return
	end
	CTeamHandyBuildView:ShowView()
end

function CExpandTeamPart.OnCancelAutoMatch(self)
	if self.m_IsInMatchingIndex == 1 then
		netteam.C2GSPlayerCancelAutoMatch()
	elseif self.m_IsInMatchingIndex == 2 then
		nethuodong.C2GSLingxiStopMatch()
	end
end

function CExpandTeamPart.OnInvite(self)
	-- g_NotifyCtrl:FloatMsg("邀请")
	CTeamFriendInviteView:ShowView()
end

function CExpandTeamPart.OpenTeamFiterView(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsLeader = g_TeamCtrl:IsLeader(g_AttrCtrl.pid)

	if bIsJoinTeam and not bIsLeader then
		g_NotifyCtrl:FloatMsg("只有队长才可以设置哦")
		return
	end
	CTeamFilterView:ShowView()
end

return CExpandTeamPart
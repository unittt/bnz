local CTeamMainPart = class("CTeamMainPart", CPageBase)

function CTeamMainPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTeamMainPart.OnInitPage(self)
	self.m_MemberGrid = self:NewUI(1, CGrid)
	self.m_MemberBox = self:NewUI(2, CTeamMemberBox)
	self.m_CreateOrQuitBtn = self:NewUI(3, CButton)
	self.m_HandyBuildOrChatBtn = self:NewUI(4, CButton)
	self.m_WarDictateBtn = self:NewUI(5, CButton)
	self.m_PartnerBtn = self:NewUI(6, CButton)
	self.m_InviteMemberBox = self:NewUI(7, CBox)
	self.m_TipsLabel = self:NewUI(8, CLabel)
	self.m_TargetBox = self:NewUI(9, CTeamTargetBox)
	self.m_ChannelBox = self:NewUI(10, CBox)
	self.m_ExtendWidget = self:NewUI(11, CWidget)
	-- self.m_BtnTable = self:NewUI(12, CTable)
	-- self.m_AppointBtn = self:NewUI(13, CButton)
	-- self.m_WarCmdBtn = self:NewUI(14, CButton)
	self.m_FormBtn = self:NewUI(15, CButton)
	self.m_PartnerBox = self:NewUI(16, CTeamPartnerBox)
	self.m_FormationL = self:NewUI(17, CLabel)
	self.m_FormationSpr = self:NewUI(18, CSprite)

	self.m_MemberBoxs = {}
	self.m_FmtInfo = {}
	self.m_partnerList = {}
	self.m_RfreshEvent = {
		[define.Team.Event.AddTeam] = true,
		[define.Team.Event.DelTeam] = true,
		[define.Team.Event.Reset] = true,
		[define.Team.Event.MemberUpdate] = true,
		[define.Team.Event.RefreshFormationPos] = true,
		[define.Team.Event.RefreshCacheCmd] = true,
	}
	self:InitContent()
end

--------------数据orUI初始化--------------------
function CTeamMainPart.InitContent(self)
	-- TODO:临时屏蔽
	self:InitChannelBox()
	-- self.m_WarDictateBtn:SetActive(false)
	self.m_MemberBox:SetActive(false)
	self.m_PartnerBox:SetActive(false)
	self.m_InviteMemberBox:SetActive(false)
	self.m_ExtendWidget:SetActive(false)
	self.m_ChannelBox:SetActive(false)

	self.m_CreateOrQuitBtn:AddUIEvent("click", callback(self, "CreateOrQuit"))
	self.m_HandyBuildOrChatBtn:AddUIEvent("click", callback(self, "OnClickHandyBuildOrChat"))
	self.m_WarDictateBtn:AddUIEvent("click", callback(self, "OnWarDictate"))
	self.m_ExtendWidget:AddUIEvent("click", callback(self, "CancelAppointOrSwitch"))
	-- self.m_AppointBtn:AddUIEvent("click", callback(self, "OnClickAppoint"))
	-- self.m_WarCmdBtn:AddUIEvent("click", callback(self, "OnClickWarCmd"))
	self.m_FormBtn:AddUIEvent("click", callback(self, "OnClickFormation"))
	self.m_PartnerBtn:AddUIEvent("click", callback(self, "OnClickPartner"))

	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamCtrlEvent"))
	g_FormationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFormationCtrlEvent"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))

	g_UITouchCtrl:TouchOutDetect(self.m_ChannelBox, callback(self, "OnTouchOutDetect"))
	self:InitFormationInfo()
	self:RefreshAll()
end

function CTeamMainPart.InitChannelBox(self)
	local lChannel = {
		[1] = define.Channel.Team,
		[2] = define.Channel.World,
		[3] = define.Channel.Current,
		[4] = define.Channel.Org,
	}
	
	self.m_ChannelBox.m_ChannelTable = self.m_ChannelBox:NewUI(1, CTable)
	self.m_ChannelBox.m_ChannelTable:InitChild(function(obj, idx)
		local oBtn = CWidget.New(obj)
		oBtn:SetGroup(self:GetInstanceID())
		oBtn:AddUIEvent("click", callback(self, "OnClickRecruit", lChannel[idx]))
		return oBtn
	end)
end

function CTeamMainPart.OnTouchOutDetect(self, gameObj)
	if gameObj ~= self.m_ChannelBox.m_GameObject then
		self.m_ChannelBox:SetActive(false)
	end
end
function CTeamMainPart.InitFormationInfo(self)
	if not g_TeamCtrl:IsJoinTeam() then
		--判断是否拥有当前阵法，没有直接请求
		if g_FormationCtrl:GetCurrentFmt() == 0 then
			netformation.C2GSAllFormationInfo()
		else
			local iFmtId = g_FormationCtrl:GetCurrentFmt()
			local dFmtInfo = g_FormationCtrl:GetFormationInfoByFmtID(iFmtId)
			local partnerList = g_FormationCtrl:GetCurrentPartnerList()
			self:SetPartnerInfo(dFmtInfo, partnerList)	
		end
	else
		local dFmtInfo = g_TeamCtrl:GetFormationInfo()
		local partnerList = g_TeamCtrl:GetPartnerPosList()
		self:SetPartnerInfo(dFmtInfo, partnerList)
	end
end

function CTeamMainPart.SetPartnerInfo(self, dFmtInfo, partnerList)
	self.m_FmtInfo = dFmtInfo or {}
	self.m_partnerList = partnerList or {}
end

--------------Ctrl事件监听--------------------
function CTeamMainPart.OnTeamCtrlEvent(self, oCtrl)
	if self.m_RfreshEvent[oCtrl.m_EventID] then
		self:InitFormationInfo()
		self:RefreshAll()
	elseif oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch then
		self:RefreshButtonStatus()
		if g_TeamCtrl.m_AutoRecruit then
			self:OnClickRecruit(g_TeamCtrl.m_RecruitChannel)
			g_TeamCtrl.m_AutoRecruit = false
		end
	end
end

function CTeamMainPart.OnFormationCtrlEvent(self, oCtrl)
	if g_TeamCtrl:IsJoinTeam()then
		return
	end
	local iFmtId = g_FormationCtrl:GetCurrentFmt()
	local dFmtInfo = g_FormationCtrl:GetFormationInfoByFmtID(iFmtId)
	local partnerList = g_FormationCtrl:GetCurrentPartnerList()
	self:SetPartnerInfo(dFmtInfo, partnerList)	
	self:RefreshAll()
end

function CTeamMainPart.OnPartnerCtrlEvent(self, oCtrl)
	if g_TeamCtrl:IsJoinTeam() then
		return
	end
	local iFmtId = g_FormationCtrl:GetCurrentFmt()
	local dFmtInfo = g_FormationCtrl:GetFormationInfoByFmtID(iFmtId)
	local partnerList = g_FormationCtrl:GetCurrentPartnerList()
	self:SetPartnerInfo(dFmtInfo, partnerList)	
	self:RefreshAll()
end
 
--------------界面刷新--------------------
function CTeamMainPart.ResetMemberBox(self)
	for i=1, 5 do
		local oBox = self.m_MemberBoxs[i]
		if oBox == nil then
			oBox = self.m_MemberBox:Clone()
			self.m_MemberBoxs[i] = oBox
			self.m_MemberGrid:AddChild(oBox)
		end
		oBox:SetActive(false)
	end
	for i = 6, 9 do
		local oBox = self.m_MemberBoxs[i]
		if oBox == nil then
			oBox = self.m_PartnerBox:Clone()
			self.m_MemberBoxs[i] = oBox
			self.m_MemberGrid:AddChild(oBox)
		end
		oBox:SetActive(false)
	end
	for i=10, 13 do
		local oBox = self.m_MemberBoxs[i]
		if oBox == nil then
			oBox = self.m_InviteMemberBox:Clone()
			self.m_MemberBoxs[i] = oBox
			self.m_MemberGrid:AddChild(oBox)
		end
		oBox:SetActive(false)
	end
end

function CTeamMainPart.RefreshMemberGrid(self)
	local lMixed = g_TeamCtrl:GetMixedList()
	self.m_MemberCount = #lMixed
	local iPosIndex = 1
	local iDelay = 0.04
	self:ResetMemberBox()
	for i=1, 5 do
		local dMember = lMixed[i]
		local iPartnerId = self.m_partnerList[i - self.m_MemberCount]
		local dPartner = g_TeamCtrl:GetTeamPartnerById(iPartnerId) or 
			g_PartnerCtrl:GetRecruitPartnerDataBySID(iPartnerId)
		local dEffectInfo = DataTools.GetFormationEffect(self.m_FmtInfo.fmt_id, 
			iPosIndex, self.m_FmtInfo.grade)

		if dMember then
			if g_TeamCtrl:IsInTeam(dMember.pid) or not g_TeamCtrl:IsJoinTeam() then
				iPosIndex = iPosIndex + 1
			end
			local oBox = self.m_MemberBoxs[i]
			oBox:SetActive(true)
			oBox:SetMember(dMember, iDelay*(i-1))
			oBox:SetFormationEffect(dEffectInfo)
			oBox.m_ActorTexture:AddUIEvent("click", callback(self, "OnClickMemberBox", oBox))
			oBox:AddUIEvent("click", callback(self, "OnClickMemberBox"))
		elseif dPartner then
			iPosIndex = iPosIndex + 1
			local oBox = self.m_MemberBoxs[i + 5 - self.m_MemberCount] 
			oBox:SetActive(true)
			oBox:SetPartner(dPartner, iDelay*(i-1))
			oBox:SetFormationEffect(dEffectInfo)
			oBox.m_ActorTexture:AddUIEvent("click", callback(self, "OnClickPartnerBox", oBox))
			oBox:AddUIEvent("click", callback(self, "OnClickPartnerBox"))
		else
			local oBox = self.m_MemberBoxs[i + 9 - self.m_MemberCount] 
			oBox:SetActive(true)
			oBox:AddUIEvent("click", callback(self, "OnClickInviteBox"))
		end
	end
	self.m_MemberGrid:Reposition()
end

function CTeamMainPart.RefreshAll(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsLeader = g_TeamCtrl:IsLeader()
	local bIsLeave = g_TeamCtrl:IsLeave()
	--取消战斗中协议缓存
	local bIsWar = g_WarCtrl:IsWar()
	local bIsCacheLeave = g_TeamCtrl:IsCacheLeave(g_AttrCtrl.pid)
	local bIsCacheShortLeave = g_TeamCtrl:IsCacheShortLeave(g_AttrCtrl.pid)
	local bIsCacheBackTeam = g_TeamCtrl:IsCacheBackTeam(g_AttrCtrl.pid)

	if bIsJoinTeam then
		if bIsWar and bIsCacheLeave then
			self.m_CreateOrQuitBtn:SetText("取消退队")
		else
			self.m_CreateOrQuitBtn:SetText("退出队伍")
		end
		self.m_HandyBuildOrChatBtn:SetText("一键喊话")
	else
		self.m_CreateOrQuitBtn:SetText("创建队伍")
		self.m_HandyBuildOrChatBtn:SetText("便捷组队")
	end
	-- self.m_AppointBtn:SetActive(bIsJoinTeam)
	-- self.m_BtnTable:Reposition()
	self:RefreshMemberGrid()
	-- self:RefrehNotifyTip()
	self:RefreshButtonStatus()
	self:RefreshFormationName()
	if g_TeamCtrl:IsPlayerAutoMatch() then
		local tTargetInfo = {
			auto_target = g_TeamCtrl:GetPlayerAutoTarget(),
			min_grade = -1,
			max_grade = -1}
		self.m_TargetBox:RefreshTargetBtton(tTargetInfo)
	else
		self.m_TargetBox:RefreshTargetBtton(g_TeamCtrl:GetTargetInfo())
	end
	
	self:CancelAppointOrSwitch()
end

function CTeamMainPart.RefreshButtonStatus(self)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsPlayerAutoMatch = g_TeamCtrl:IsPlayerAutoMatch()
	if not bIsJoinTeam and not bIsPlayerAutoMatch then
		self.m_TipsLabel:SetActive(true)
		self.m_TargetBox:SetActive(false)
		return
	end
	self.m_TipsLabel:SetActive(false)
	self.m_TargetBox:SetActive(true)
	self.m_TargetBox:RefreshButtonStatus()
end

function CTeamMainPart.RefreshFormationName(self)
	if table.count(self.m_FmtInfo) == 0 then
		return
	end
	local dData = data.formationdata.BASEINFO[self.m_FmtInfo.fmt_id] 
	local sText = nil
	if self.m_FmtInfo.fmt_id == 1 then
		sText = "未设置"
	else
		sText = string.format("%d级 %s", self.m_FmtInfo.grade, dData.name)
	end
	self.m_FormationL:SetText(sText)
	-- self.m_FormationL:SetActive(self.m_FmtInfo.fmt_id ~= 1)
	self.m_FormationSpr:SetSpriteName(dData.icon)
	if not g_FormationCtrl.m_NeedGuideLearn then
		self.m_FormBtn:DelEffect("FingerInterval")
	else
		self.m_FormBtn:AddEffect("FingerInterval")
	end
end

function CTeamMainPart.ShowAppointPanel(self)
	for i=1, 5 do
		local oBox = self.m_MemberBoxs[i]
		if oBox:GetActive() then
			oBox:ShowAppointPanel()
		end
	end
end

function CTeamMainPart.HideAppointPanel(self)
	for i=1, 5 do
		local oBox = self.m_MemberBoxs[i]
		oBox:HideAppointPanel()
	end
end

function CTeamMainPart.ShowSwitchPanel(self, iPid, bIsPartner)
	local bIsShow = false
	g_TeamCtrl.m_SelectedPid = iPid
	if bIsPartner then
		for i = 6, 9 do
			local oBox = self.m_MemberBoxs[i]
			if oBox:GetActive() then
				bIsShow = oBox:ShowSwitchPanel() or bIsShow
			end
		end
	else
		for i = 2, 5 do
			local oBox = self.m_MemberBoxs[i]
			if oBox:GetActive() then
				bIsShow = oBox:ShowSwitchPanel() or bIsShow
			end
		end
	end
	if not bIsShow then
		g_TeamCtrl.m_SelectedPid = -1
		if g_TeamCtrl:IsLeader() or not g_TeamCtrl:IsJoinTeam() then
			g_NotifyCtrl:FloatMsg("没有可以交换的位置")
		else
			g_NotifyCtrl:FloatMsg("只有队长才能交换的位置") 
		end
		return
	end
	self.m_ExtendWidget:SetActive(true)
end

function CTeamMainPart.HideSwitchPanel(self)
	for i = 2, 5 do
		local oBox = self.m_MemberBoxs[i]
		if oBox:GetActive() then
			oBox:HideSwitchPanel()
		end
		oBox = self.m_MemberBoxs[i + 4]
		if oBox:GetActive() then
			oBox:HideSwitchPanel()
		end
	end
end
--------------点击事件--------------------
function CTeamMainPart.OnClickRecruit(self, iChannel)
	local dTextData = data.teamdata.TEXT
	if iChannel == define.Channel.Org and g_AttrCtrl.org_id == 0 then
		g_NotifyCtrl:FloatMsg(dTextData[1129].content)
		return
	end
	local iLeftTime = g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.TeamMatchChat, iChannel)
	if iLeftTime then
		local sText = dTextData[1127].content
		sText = string.gsub(sText, "#time", iLeftTime)
		g_NotifyCtrl:FloatMsg(sText)
		return
	end

	self.m_ChannelBox:SetActive(false)
	local tTargetInfo = g_TeamCtrl:GetTargetInfo()

	if not g_TeamCtrl:IsJoinTeam() then
		g_NotifyCtrl:FloatMsg("请先创建队伍并调整目标")
		return
	end
	if tTargetInfo.auto_target == g_TeamCtrl.TARGET_NONE then
		if g_TeamCtrl:IsLeader(g_AttrCtrl.pid) then
			g_NotifyCtrl:FloatMsg("请先调整目标")
			g_TeamCtrl.m_AutoRecruit = true
			g_TeamCtrl.m_RecruitChannel = iChannel
			CTeamFilterView:ShowView(function(oView)
				oView:SetListener(callback(self.m_TargetBox, "OnTargetChange"))
			end)
		else
			g_NotifyCtrl:FloatMsg("队长选择了匹配目标后才能喊话")
		end
		return
	end

	local tData = data.teamdata.AUTO_TEAM[tTargetInfo.auto_target]
	local iMatchCount = tData.max_count
	local sTeamCount  = string.format("（%d/%d）", self.m_MemberCount, iMatchCount)
	local sTarget = string.format("[%s%s%d-%d级]进组啦", tData.name, sTeamCount, tTargetInfo.min_grade, tTargetInfo.max_grade)
	local targetLink = LinkTools.GenerateGetTeamInfoLink(g_TeamCtrl.m_TeamID, sTarget)
	local applyLink = LinkTools.GenerateApplyTeamLink(g_TeamCtrl.m_TeamID)
	local msg = targetLink..applyLink
	netchat.C2GSMatchTeamChat(msg, tonumber(tTargetInfo.min_grade), tonumber(tTargetInfo.max_grade), 0, iChannel)
	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.TeamMatchChat, iChannel, 10)
end

function CTeamMainPart.OnClickAppoint(self)
	if not g_TeamCtrl:IsLeader(g_AttrCtrl.pid) then
		g_NotifyCtrl:FloatMsg("只有队长才能委任指挥")
		return
	end
	if g_TeamCtrl:GetMemberSize() == 1 then
		g_NotifyCtrl:FloatMsg("队伍内无其他成员，无法委任")
		return
	end
	-- self.m_BtnTable:SetActive(false)
	self.m_ExtendWidget:SetActive(true)
	self:ShowAppointPanel()
end

function CTeamMainPart.OnClickWarCmd(self)
	-- self.m_BtnTable:SetActive(false)
	self.m_ExtendWidget:SetActive(false)
	CTeamWarCmdView:ShowView()
end

function CTeamMainPart.OnClickFormation(self)
	if not g_OpenSysCtrl:GetOpenSysState(define.System.Formation, true) then
		return
	end
	CFormationMainView:ShowView(function(oView)
		if g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeader() then
			oView:SetUIMode(oView.UIMode.TeamMember)
		end
	end)
end

function CTeamMainPart.OnClickPartner(self)
	CPartnerMainView:ShowView(function (oView)
		oView:ResetCloseBtn()
	end)
end

function CTeamMainPart.OnClickInviteBox(self)
	if not g_MapCtrl:IsTeamAllowed() then
		g_NotifyCtrl:FloatMsg("当前场景禁止组队")
		return
	end
	-- g_NotifyCtrl:FloatMsg("邀请好友")
	CTeamFriendInviteView:ShowView()
end

function CTeamMainPart.OnClickMemberBox(self, oMemberBox)
	if oMemberBox.m_Member.pid == g_AttrCtrl.pid then
		return
	end
	local oView = CTeamMemberOpView:GetView()
	if oView then
		if oView.m_Pid == oMemberBox.m_Member.pid then
			oView:SetStrikeResult(false)
		else 
			oView:SetStrikeResult(true)
			oView:ShowTeamViewOp(oMemberBox.m_Member.pid)
			UITools.NearTarget(oMemberBox.m_LocWidget, oView.m_Bg, enum.UIAnchor.Side.Right)
		end
	else
		CTeamMemberOpView:ShowView(function(oView)
			oView:ShowTeamViewOp(oMemberBox.m_Member.pid)
			UITools.NearTarget(oMemberBox.m_LocWidget, oView.m_Bg, enum.UIAnchor.Side.Right)
		end)
	end
end

function CTeamMainPart.OnClickPartnerBox(self, oPartnerBox)
	self:ShowSwitchPanel(oPartnerBox.m_Pid, true)
end

function CTeamMainPart.CancelAppointOrSwitch(self)
	self.m_ExtendWidget:SetActive(false)
	self:HideAppointPanel()
	self:HideSwitchPanel()
	-- self.m_BtnTable:SetActive(false)
end

function CTeamMainPart.OnWarDictate(self)
	-- g_NotifyCtrl:FloatMsg("战斗指挥")
	CTeamWarCmdView:ShowView()
	-- self.m_ExtendWidget:SetActive(true)
	-- self.m_BtnTable:SetActive(true)
end

function CTeamMainPart.OnHandyBuild(self)
	if not g_MapCtrl:IsTeamAllowed() then
		g_NotifyCtrl:FloatMsg("当前场景禁止组队")
		return
	end
	CTeamHandyBuildView:ShowView()
end

function CTeamMainPart.CreateOrQuit(self)
	if g_TeamCtrl:IsJoinTeam() then
		--取消战斗中协议缓存
		local bIsWar = g_WarCtrl:IsWar()
		local bIsCacheLeave = g_TeamCtrl:IsCacheLeave(g_AttrCtrl.pid)
		local func = function() 
			netteam.C2GSLeaveTeam() 
			local oHero = g_MapCtrl:GetHero()
			if oHero then
				oHero:StopWalk()
			end
			if not bIsWar then
				g_NotifyCtrl:FloatMsg("你已退出队伍")
			end
		end
		local iSize = g_TeamCtrl:GetMemberSize()
		if iSize < 2 then
			func()
		else
			if bIsCacheLeave then
				func()
				return
			end
			local sMsg = "是否确定离开队伍？"
			if next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.LINGXI.ID]) then
				sMsg = "强行退出队伍会导致任务失败，是否继续？"
			end
			local windowConfirmInfo = {
				msg = sMsg,
				okCallback = func,	
				countdown = 30,
				default = 0,
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		end
	else
		if not g_MapCtrl:IsTeamAllowed() then
			g_NotifyCtrl:FloatMsg("当前场景禁止组队")
			return
		end
		netteam.C2GSCreateTeam()
	end
end

function CTeamMainPart.OnClickHandyBuildOrChat(self)
	if g_TeamCtrl:IsJoinTeam() then
		self.m_ChannelBox:SetActive(true)
	else
		self:OnHandyBuild()
	end
end
return CTeamMainPart
local CDungeonRewardView = class("CDungeonRewardView", CViewBase)

function CDungeonRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Dungeon/DungeonRewardView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CDungeonRewardView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_GradeBox = self:NewUI(2, CBox)
	self.m_RewardBox = self:NewUI(3, CBox)
	self.m_MemberGrid = self:NewUI(4, CGrid)
	self.m_PlayerBoxClone = self:NewUI(5, CBox)
	self.m_TitleL = self:NewUI(6, CLabel)

	self.m_MemberBoxDict = {}
	self.m_GradeBoxList = {}
	self:InitContent()
end

function CDungeonRewardView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_PlayerBoxClone:SetActive(false)
	self:InitGradeBox()
	self:InitRewardBox()

	g_DungeonCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self, "OnDungeonCtrlEvent"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self, "OnFriendCtrlEvent"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgCtrlEvent"))
end

function CDungeonRewardView.InitGradeBox(self)
	self.m_GradeBox.m_ScoreL = self.m_GradeBox:NewUI(1, CLabel)
	-- self.m_GradeBox.m_LvSpr = self.m_GradeBox:NewUI(2, CSprite)
	self.m_GradeBox.m_Slider = self.m_GradeBox:NewUI(3, CSlider)
	self.m_GradeBox.m_GradeL = self.m_GradeBox:NewUI(4, CLabel)
	self.m_GradeBox.m_GradeWidget = self.m_GradeBox:NewUI(5, CWidget)
	self.m_GradeBox.m_GradeLabelClone = self.m_GradeBox:NewUI(6, CLabel)
	self.m_GradeBox.m_UnknockSpr = self.m_GradeBox:NewUI(7, CWidget)
end

function CDungeonRewardView.InitRewardBox(self)
	self.m_RewardBox.m_ExpL = self.m_RewardBox:NewUI(1, CLabel)
	self.m_RewardBox.m_SilverL = self.m_RewardBox:NewUI(2, CLabel)
	self.m_RewardBox.m_ItemGrid = self.m_RewardBox:NewUI(3, CGrid)
	self.m_RewardBox.m_ItemBoxClone = self.m_RewardBox:NewUI(4, CItemBaseBox)
	self.m_RewardBox.m_TipWidget = self.m_RewardBox:NewUI(5, CWidget)
	self.m_RewardBox.m_ItemBoxClone:SetActive(false)
	self.m_RewardBox.m_TipWidget:SetActive(false)
	self.m_RewardBox.m_ExpL:SetText("")
	self.m_RewardBox.m_SilverL:SetText("")
end

function CDungeonRewardView.SetRewardInfo(self, dInfo)
	self.m_RewardInfo = dInfo
	self:RefreshAll()
end

-- 精英副本
function CDungeonRewardView.SetEliteDungeonInfo(self, dInfo)
	self:SetEliteDungeonData(dInfo)
	self:RefreshTitle()
	self:RefreshMemberGrid()
	self:RefreshGradeBox()
	self:RefreshRewardBox()
	-- self.m_GradeBox.m_GradeL:SetText("?")
	self.m_GradeBox.m_GradeL:SetActive(false)
	self.m_GradeBox.m_UnknockSpr:SetActive(true)
	self.m_RewardBox.m_TipWidget:SetActive(true)
end

function CDungeonRewardView.SetEliteDungeonData(self, dInfo)
	local dEliteInfo = self.m_RewardInfo
	if not dEliteInfo then
		dEliteInfo = {fuben = 1}
		self.m_RewardInfo = dEliteInfo
	end
	for k, v in pairs(dInfo) do
		dEliteInfo[k] = v
	end
	if not dEliteInfo.itemlist then
		dEliteInfo.itemlist = {}
	end
	local dReward = DataTools.GetDungeonRewardInfoByPoint(1, dEliteInfo.point)
	if dReward then
		dEliteInfo.expradio = dReward.exp_radio
		dEliteInfo.silverradio = dReward.silver_radio
		dEliteInfo.level = dReward.level
	end
end

function CDungeonRewardView.RefreshAll(self)
	self:RefreshTitle()
	self:RefreshMemberGrid()
	self:RefreshGradeBox()
	self:RefreshRewardBox()
end

function CDungeonRewardView.RefreshTitle(self)
	local iDungeonId = self.m_RewardInfo.fuben
	local tData = DataTools.GetDungeonData(iDungeonId)
	if tData then
		self.m_TitleL:SetText(tData.name)
	end
end

function CDungeonRewardView.RefreshGradeBox(self)
	local iMaxPoint, sMaxGrade = DataTools.GetDungeonMaxGradePoint(self.m_RewardInfo.fuben)
	local iNextPoint = DataTools.GetDungeonNextGradePoint(self.m_RewardInfo.fuben, self.m_RewardInfo.level)
	local sPointDesc =  "[244B4E]副本得分[BD5733]"..self.m_RewardInfo.point.."[-]"
	if sMaxGrade == self.m_RewardInfo.level then
		sPointDesc = "[244B4E]恭喜你获得最高评级:#OSSS"
	elseif iNextPoint > 0 then
		sPointDesc = string.format("%s，还差[BD5733]%d[-]分可以提升评分等级", sPointDesc, (iNextPoint - self.m_RewardInfo.point))
	end
	local sGrade = ""
	for i=1,#self.m_RewardInfo.level do
		sGrade = string.format("%s#mark_%s", sGrade, string.sub(self.m_RewardInfo.level,i,i))
	end
	self.m_GradeBox.m_GradeL:SetText(sGrade)
	self.m_GradeBox.m_ScoreL:SetText(sPointDesc)
	self.m_GradeBox.m_GradeL:SetActive(true)
	self.m_GradeBox.m_UnknockSpr:SetActive(false)
	self:RefreshGradeTitle()
end

function CDungeonRewardView.RefreshGradeTitle(self)
	local sGradeArr = {
		[1] = "D",
		[2] = "C",
		[3] = "B",
		[4] = "A",
		[5] = "S",
		[6] = "SS",
		[7] = "SSS"
	}
	local oNode = self.m_GradeBox.m_GradeWidget
	local oCloneL = self.m_GradeBox.m_GradeLabelClone
	local iWidth = oNode:GetSize() - 10
	local vStartPos = oCloneL:GetLocalPos()
	local rewardList = DataTools.GetDungeonData(self.m_RewardInfo.fuben).point_reward
	oNode:SetActive(true)
	oCloneL:SetActive(true)
	local iMinPt = rewardList[1].point
	local iMaxPt = rewardList[6].point
	for i=1, #sGradeArr - 1 do
		local sGrade = sGradeArr[i]
		local iPoint = rewardList[i].point
		local oLabel = self.m_GradeBoxList[i]
		if not oLabel then
			oLabel = oCloneL:Clone()
			table.insert(self.m_GradeBoxList, oLabel)
		end
		oLabel:SetText(sGradeArr[i + 1])
		oLabel:SetParent(oNode.m_Transform)
		oLabel:SetLocalPos(Vector2.New(vStartPos.x + (iPoint/iMaxPt)*iWidth, vStartPos.y))
	end
	self.m_GradeBox.m_Slider:SetValue(
		self.m_RewardInfo.point/iMaxPt)
	-- oCloneL:SetActive(false)
end

function CDungeonRewardView.RefreshRewardBox(self)
	local sExp = self.m_RewardInfo.exp
	if not sExp then return end
	local expradio = self.m_RewardInfo.expradio
	if expradio and expradio > 0 then
		sExp = string.format("%d[c]#I(+%d%%)#n", sExp, expradio)
	end
	local sSilver = self.m_RewardInfo.silver
	local silverradio = self.m_RewardInfo.silverradio
	if silverradio and silverradio > 0 then
		sSilver = string.format("%d[c]#I(+%d%%)#n", sSilver, silverradio)
	end
	self.m_RewardBox.m_ExpL:SetText(sExp)
	self.m_RewardBox.m_SilverL:SetText(sSilver)
	self:RefreshRewardItemGrid()
end

function CDungeonRewardView.RefreshRewardItemGrid(self)
	self.m_RewardBox.m_ItemGrid:Clear()
	for i,dItem in ipairs(self.m_RewardInfo.itemlist) do
		local oBox = self.m_RewardBox.m_ItemBoxClone:Clone()
		oBox:SetBagItem(CItem.CreateDefault(dItem.itemsid))
		oBox:SetAmountText(dItem.amount)
		oBox:SetActive(true)
		self.m_RewardBox.m_ItemGrid:AddChild(oBox)
	end
	self.m_RewardBox.m_ItemGrid:Reposition()
end

function CDungeonRewardView.RefreshMemberGrid(self)
	self.m_MemberGrid:HideAllChilds()
	local lMember = g_TeamCtrl:GetMemberList()
	local idx = 0
	for i,dMember in ipairs(lMember) do
		if dMember.pid ~= g_AttrCtrl.pid then
			idx = idx + 1
			local oBox = self:GetPlayerBox(idx)
			self.m_MemberBoxDict[dMember.pid] = oBox
			self:UpdatePlayerBox(oBox, dMember)
		end
	end
	self.m_MemberGrid:Reposition()
end

function CDungeonRewardView.GetPlayerBox(self, idx)
	local oBox = self.m_MemberGrid:GetChild(idx)
	if not oBox then
		oBox = self.m_PlayerBoxClone:Clone()
		oBox.m_SchoolSpr = oBox:NewUI(1, CSprite)
		oBox.m_AvatarSpr = oBox:NewUI(2, CSprite)
		oBox.m_GradeL = oBox:NewUI(3, CLabel)
		oBox.m_NameL = oBox:NewUI(4, CLabel)
		oBox.m_AddFriendBtn = oBox:NewUI(5, CButton)
		oBox.m_OrgBtn = oBox:NewUI(6, CButton)
		oBox.m_PraiseBtn = oBox:NewUI(7, CButton)
		oBox.m_FriendBuffL = oBox:NewUI(8, CLabel)
		oBox.m_OrgBuffL = oBox:NewUI(9, CLabel)
		oBox.m_OrgBuffSpr = oBox:NewUI(10, CSprite)
		oBox.m_FriendBuffSpr = oBox:NewUI(11, CSprite)
		self.m_MemberGrid:AddChild(oBox)
	end
	return oBox
end

function CDungeonRewardView.UpdatePlayerBox(self, oBox, dInfo)
	oBox.pid = dInfo.pid
	oBox.m_PlayerInfo = dInfo
	oBox.m_AvatarSpr:SpriteAvatar(dInfo.icon)
	oBox.m_SchoolSpr:SpriteSchool(dInfo.school)
	oBox.m_GradeL:SetText(tostring(dInfo.grade).."级")
	oBox.m_NameL:SetText(dInfo.name)
	oBox:SetActive(true)
	self:UpdatePlayerFriendInfo(oBox, dInfo.pid)
	self:UpdatePlayerOrgInfo(oBox, dInfo.orgid)
end

function CDungeonRewardView.UpdatePlayerFriendInfo(self, oBox, iPid)
	local bFriend = g_FriendCtrl:IsMyFriend(iPid) and true or false
	oBox.m_AddFriendBtn:SetActive(not bFriend)
	oBox.m_FriendBuffL:SetActive(bFriend)
	local bBoth = false
	if bFriend then
		local dFriend = g_FriendCtrl:GetFriend(iPid)
		if dFriend and 1 == dFriend.both then
			bBoth = true
		end
		oBox.m_FriendBuffSpr:SetGrey(not bBoth)
	end
	if not bBoth then
		if g_FriendCtrl.m_DungeonAddFriendConfirmHashList[iPid] then
			oBox.m_AddFriendBtn:SetText("接受申请")
			oBox.m_AddFriendBtn:SetActive(true)
			oBox.m_FriendBuffL:SetActive(false)
		else
			oBox.m_AddFriendBtn:SetText("加为好友")
		end
	end
	oBox.m_AddFriendBtn:AddUIEvent("click", callback(self, "OnClickAddFriend", oBox))
	oBox.m_PraiseBtn:AddUIEvent("click", callback(self, "OnClickPraise", oBox))
end

function CDungeonRewardView.UpdatePlayerOrgInfo(self, oBox, iOrg)
	local bAllInOrg = g_AttrCtrl.org_id ~= 0 and iOrg ~= 0
	oBox.m_OrgBtn:SetActive(not bAllInOrg)
	oBox.m_OrgBuffL:SetActive(bAllInOrg)
	if g_AttrCtrl.org_id ~= 0 then
		oBox.invite = nil
	elseif not oBox.invite then
		local dInvite = g_OrgCtrl.m_InviteOrgInfo
		if dInvite and dInvite.pid and dInvite.pid == oBox.pid then
			oBox.invite = true
		end
	end
	if oBox.invite then
		oBox.m_OrgBtn:SetText("接受邀请")
		oBox.m_OrgBtn:AddUIEvent("click", callback(self, "OnClickAcceptOrgInvite", oBox))
		return
	end
	if bAllInOrg and g_AttrCtrl.org_id == iOrg then
		oBox.m_OrgBuffSpr:SetGrey(false)
	else
		oBox.m_OrgBuffSpr:SetGrey(true)
	end
	if iOrg == 0 and g_AttrCtrl.org_id ~= 0 then
		oBox.m_OrgBtn:SetText("邀请入帮")
		oBox.m_OrgBtn:AddUIEvent("click", callback(self, "OnClickOrgInvite", oBox))
	elseif iOrg ~= 0 and g_AttrCtrl.org_id == 0 then
		oBox.m_OrgBtn:SetText("申请入帮")
		oBox.m_OrgBtn:AddUIEvent("click", callback(self, "OnClickOrgApply", oBox))
	elseif iOrg == 0 and g_AttrCtrl.org_id == 0 then
		oBox.m_OrgBtn:SetText("暂无帮派")
		oBox.m_OrgBtn:SetGrey(true)
		-- oBox.m_OrgBtn:AddUIEvent("click", callback(self, "OnClickOrgCreate", oBox))
	end
end

function CDungeonRewardView.ShowEliteResult(self, dInfo)
	self:SetEliteDungeonData(dInfo)
	self:RefreshRewardBox()
	self:RefreshGradeBox()
	self.m_RewardBox.m_TipWidget:SetActive(false)
end

function CDungeonRewardView.HideOrgInviteBtn(self)
    local oView = CMainMenuView:GetView()
    if oView then
        oView.m_RB.m_QuickMsgBox:RefreshOrgInviteBtn(false)
    end
    g_OrgCtrl.m_InviteOrgInfo = {}
end

function CDungeonRewardView.ClearOrgInviteInfo(self)
	g_OrgCtrl.m_IsInDungeonView = false
	local dInvite = g_OrgCtrl.m_InviteOrgInfo
	if dInvite and dInvite.pid then
		-- netorg.C2GSDealInvited2Org(dInvite.pid, 0)
		g_OrgCtrl.m_InviteOrgInfo = {}
	end
end

function CDungeonRewardView.OnClickAddFriend(self, oBox)
	local oPid = oBox.m_PlayerInfo.pid
	if g_FriendCtrl.m_DungeonAddFriendConfirmHashList[oPid] then
		netfriend.C2GSVerifyFriendComfirm(oPid, 1)
		g_FriendCtrl.m_DungeonAddFriendConfirmHashList[oPid] = nil
	else
		netfriend.C2GSApplyAddFriend(oPid)
	end
end

function CDungeonRewardView.OnClickOrgInvite(self, oBox)
	netorg.C2GSInvited2Org(oBox.m_PlayerInfo.pid)
end

function CDungeonRewardView.OnClickOrgApply(self, oBox)
	g_OrgCtrl:ApplyJoinOrg(oBox.m_PlayerInfo.orgid)
end

function CDungeonRewardView.OnClickOrgCreate(self, oBox)
	g_NotifyCtrl:FloatMsg("双方暂无帮派，可创建帮派后再邀请")
end

function CDungeonRewardView.OnClickAcceptOrgInvite(self, oBox)
	netorg.C2GSDealInvited2Org(oBox.pid, 1)
	oBox.invite = false
	g_OrgCtrl.m_InviteOrgInfo = {}
end

function CDungeonRewardView.OnClickPraise(self, oBox)
	if g_AttrCtrl.grade < 30 then 
		g_NotifyCtrl:FloatMsg("点赞需要等级达到30级!")
		return
	end 
	if oBox.m_PlayerInfo.m_Isupvote == 1 then 
		g_NotifyCtrl:FloatMsg("同一个好友只能点赞一次哦!")
		return
	end 
	if self.m_PlayerInfo.m_CardPid then 	
		netplayer.C2GSUpvotePlayer(self.m_PlayerInfo.m_CardPid)
	end
end

function CDungeonRewardView.OnDungeonCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Dungeon.Event.RefreshRewardView then
		self:ShowEliteResult(oCtrl.m_EventData)
	end
end

function CDungeonRewardView.OnFriendCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.Add or oCtrl.m_EventID == define.Friend.Event.Del or oCtrl.m_EventID == define.Friend.Event.UpdateFriendConfirm or oCtrl.m_EventID == define.Friend.Event.UpdateTeamer then
		for i, oBox in pairs(self.m_MemberBoxDict) do
			self:UpdatePlayerBox(oBox, oBox.m_PlayerInfo)
		end
	elseif oCtrl.m_EventID == define.Friend.Event.RefreshFriendProfileBoth then
		local iPid = oCtrl.m_EventData.pid
		local oBox = self.m_MemberBoxDict[iPid]
		if oBox then
			self:UpdatePlayerBox(oBox, oBox.m_PlayerInfo)
		end
	end
end

function CDungeonRewardView.OnOrgCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.ReceiveInvite then
		for i, oBox in pairs(self.m_MemberBoxDict) do
			self:UpdatePlayerBox(oBox, oBox.m_PlayerInfo)
		end
	end
end

function CDungeonRewardView.OnShowView(self)
	g_FriendCtrl.m_IsInDungeonView = true
	g_FriendCtrl.m_DungeonPidList = {}
	g_OrgCtrl.m_IsInDungeonView = true
	local lMember = g_TeamCtrl:GetMemberList()
	for i,dMember in ipairs(lMember) do
		if dMember.pid ~= g_AttrCtrl.pid then
			table.insert(g_FriendCtrl.m_DungeonPidList, dMember.pid)
		end
	end
	self:HideOrgInviteBtn()
end

function CDungeonRewardView.OnHideView(self)
	g_FriendCtrl.m_IsInDungeonView = false
	for k,v in pairs(g_FriendCtrl.m_DungeonAddFriendConfirmHashList) do
		netfriend.C2GSVerifyFriendComfirm(v.pid, 0)
	end
	g_FriendCtrl.m_DungeonAddFriendConfirmHashList = {}
	g_FriendCtrl.m_DungeonPidList = {}
end

function CDungeonRewardView.Destroy(self)
	self:ClearOrgInviteInfo()
	CViewBase.Destroy(self)
end

return CDungeonRewardView
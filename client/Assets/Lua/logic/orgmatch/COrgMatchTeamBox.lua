local COrgMatchTeamBox = class("COrgMatchTeamBox", CBox)

function COrgMatchTeamBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SubMenuBg = self:NewUI(1, CWidget)
	self.m_LeaderBtn = self:NewUI(2, CButton, true ,false)
	self.m_MemberGrid = self:NewUI(3, CGrid)
	self.m_MemberBoxClone = self:NewUI(4, CBox)
	self.m_ArrowSpr = self:NewUI(5, CSprite)
	self.m_SelArrowSpr = self:NewUI(6, CSprite)
	self.m_ApplyBtn = self:NewUI(7, CSprite)
	self.m_LeaderIconSpr = self:NewUI(8, CSprite)
	self.m_LeaderNameL = self:NewUI(9, CLabel)
	self.m_TeamSchoolGrid = self:NewUI(10, CGrid)
	self.m_TeamSchoolSpr = self:NewUI(11, CSprite)
	self.m_LeaderGradeL = self:NewUI(12, CLabel)

	self.m_TeamSchool = {}
	self.m_MemberBoxs = {}

	self.m_TweenHeight = self.m_SubMenuBg:GetComponent(classtype.TweenHeight)
	self.m_TweenRotation_1 = self.m_ArrowSpr:GetComponent(classtype.TweenRotation)
	self.m_TweenRotation_2 = self.m_SelArrowSpr:GetComponent(classtype.TweenRotation)

	self:BindButtonEvent()
	self.m_MemberBoxClone:SetActive(false)
	self.m_ApplyBtn:SetActive(false)
	self.m_TeamSchoolSpr:SetActive(false)
end

function COrgMatchTeamBox.BindButtonEvent(self)
	self.m_LeaderBtn:AddUIEvent("click", callback(self, "OnClickLeader"))
end

-- 初始化数据
function COrgMatchTeamBox.SetTeamData(self, dInfo)
	self.m_TeamData = dInfo.mem_list
	self.m_TeamId = dInfo.team_id
	-- self.m_TeamSchool = {}
	-- for i,dMember in ipairs(self.m_TeamData) do
	-- 	self.m_TeamSchool[dMember.status_info.school] = true
	-- end
	self:RefreshUI()
end

-- 设置监听器
function COrgMatchTeamBox.SetCallback(self, leaderCb, memberCb)
	self.m_LeaderCb = leaderCb
	self.m_MemberCb = memberCb
end

-- 执行UI刷新
function COrgMatchTeamBox.RefreshUI(self)
	-- self:SetSelected(false)
	self:RefreshLeader()
end

function COrgMatchTeamBox.RefreshLeader(self)
	self:RefreshMemberGrid()
	local dLeader = self.m_TeamData[1].status_info
	self.m_LeaderIconSpr:SpriteAvatar(dLeader.icon)
	self.m_LeaderNameL:SetText(dLeader.name)
	self.m_LeaderGradeL:SetText(dLeader.grade)
	self.m_TeamSchoolGrid:Clear()
	for i,dMember in pairs(self.m_TeamData) do
		local oSpr = self.m_TeamSchoolSpr:Clone()
		oSpr:SetActive(true)
		oSpr:SpriteSchool(dMember.status_info.school)
		self.m_TeamSchoolGrid:AddChild(oSpr)
	end
	self.m_TeamSchoolGrid:Reposition()
end

function COrgMatchTeamBox.RefreshMemberGrid(self)
	local iCount = 0
	-- self.m_MemberGrid:Clear()
	for i = 2, 6 do
		local oBox = self.m_MemberBoxs[i]
		if not oBox then
			if i == 6 then
				oBox = self:CreateApplyButton()
			else
				oBox = self:CreateMemberBox()
			end
			self.m_MemberGrid:AddChild(oBox)
			self.m_MemberBoxs[i] = oBox
		end
		if oBox:GetActive() then
			oBox:SetActive(false)
		end
	end

	for i = 2, 5 do
		iCount = iCount + 1
		local dMember = self.m_TeamData[i]
		if dMember then
			self:UpdateMemberBox(self.m_MemberBoxs[i], dMember.status_info)
		else
			self.m_MemberBoxs[6]:SetActive(true)
			break
		end
	end
	self.m_MemberGrid:Reposition()
	local _, h = self.m_MemberGrid:GetCellSize()
	self.m_TweenHeight.to = h*iCount + 10
	if self.m_SubMenuBg:GetActive() then
		self.m_SubMenuBg:SetHeight(self.m_TweenHeight.to)
		-- self:ExpandSubMenu(false)
		-- self:ExpandSubMenu(true)
	end
end

function COrgMatchTeamBox.CreateMemberBox(self)
	local oBox = self.m_MemberBoxClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_SchoolSpr = oBox:NewUI(3, CSprite)
	oBox.m_SchoolL = oBox:NewUI(4, CLabel)
	oBox.m_GradeL = oBox:NewUI(5, CLabel)

	oBox:AddUIEvent("click", function()
		oBox:ForceSelected(true)
		if self.m_MemberCb then
			self.m_MemberCb(oBox)
		end
	end)
	return oBox
end

function COrgMatchTeamBox.UpdateMemberBox(self, oBox, dMember)
	oBox.m_IconSpr:SpriteAvatar(dMember.icon)
	oBox.m_NameL:SetText(dMember.name)
	oBox.m_GradeL:SetText(dMember.grade)
	oBox.m_SchoolSpr:SpriteSchool(dMember.school)
	local tSchool = data.schooldata.DATA[dMember.school]
	oBox.m_SchoolL:SetText(tSchool.name)
	oBox:SetActive(true)
end

function COrgMatchTeamBox.CreateApplyButton(self)
	local oBtn = self.m_ApplyBtn:Clone()
	oBtn:AddUIEvent("click", callback(self, "OnClickApply"))
	oBtn:SetActive(true)
	return oBtn
end

function COrgMatchTeamBox.ExpandSubMenu(self, bIsExpand)
	if self.m_SubMenuBg:GetActive() == bIsExpand then
		return
	end
	self.m_SubMenuBg:SetActive(bIsExpand)
	self.m_TweenHeight:Play(bIsExpand)
	self.m_TweenRotation_1:Play(bIsExpand)
	self.m_TweenRotation_2:Play(bIsExpand)
end

function COrgMatchTeamBox.ForceSelected(self, b)
	self.m_LeaderBtn:ForceSelected(b)
end

function COrgMatchTeamBox.OnClickLeader(self)
	self:ForceSelected(true)
	if self.m_LeaderCb then
		self.m_LeaderCb(self)
	end
end

function COrgMatchTeamBox.OnClickApply(self)
	if g_TeamCtrl:IsJoinTeam() then
		g_NotifyCtrl.FloatMsg("队伍中，无法申请")
		return
	end
	netteam.C2GSApplyTeam(self.m_TeamId)
end

return COrgMatchTeamBox
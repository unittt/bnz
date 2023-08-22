   local CTeamHandyBuildView = class("CTeamHandyBuildView", CViewBase)

function CTeamHandyBuildView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamHandyBuildView.prefab", cb)

	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CTeamHandyBuildView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CreateBtn = self:NewUI(2, CButton)
	self.m_AutoBtn = self:NewUI(3, CButton)
	self.m_Refresh = self:NewUI(4, CButton)
	self.m_ApplyBox = self:NewUI(5, CTeamHandyApplyBox)
	self.m_ApplyGrid = self:NewUI(6, CGrid)
	self.m_CntLabel = self:NewUI(7, CLabel)
	self.m_TaskTable = self:NewUI(8, CTable)
	self.m_TaskBtnClone = self:NewUI(9,    CTeamHandyTaskBox, true, false)
	self.m_TotalTaskBtn = self:NewUI(10, CButton, true, false)
	self.m_ScrollView = self:NewUI(11, CScrollView)
	self.m_TaskScroll = self:NewUI(12, CScrollView)
	self.m_EmptyTex = self:NewUI(13, CTexture)

	self.m_SelectedTaskId = 0
	self.m_SelectedTaskBtn = nil
	self.m_AutoTargetBtn = nil
	self.m_ApplyBoxs = {}
	self.m_RefApplyBoxs = {}
	self.m_TaskPanel = self.m_TaskScroll:GetComponent(classtype.UIPanel)
	self:InitContent()
end

function CTeamHandyBuildView.InitContent(self)
	self.m_ApplyBox:SetActive(false)
	self.m_EmptyTex:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CreateBtn:AddUIEvent("click", callback(self, "RequestBuildTeam"))
	self.m_AutoBtn:AddUIEvent("click", callback(self, "RequestAutoApply"))
	self.m_Refresh:AddUIEvent("click", callback(self, "RequestRefresh"))
	self.m_TotalTaskBtn:AddUIEvent("click", callback(self, "OnClickTotalTask"))

	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:SetSelectedAutoTeam()
end

function CTeamHandyBuildView.SetSelectedAutoTeam(self, iTaskId)
	--TODO:+30只是测试，请删除
	self.m_AutoTeamData = DataTools.GetAutoteamData(g_AttrCtrl.grade, g_KuafuCtrl:IsInKS())
	self.m_SelectedTaskId = iTaskId or g_TeamCtrl:GetPlayerAutoTarget()

	if self.m_SelectedTaskId == 0 then
		self.m_TotalTaskBtn:SetSelected(true)
		self:OnClickTotalTask()
	end

	if not self.m_AutoTeamData then
		return
	end
	self:RefreshTaskTable()
	self:RefreshAutoButton()
	self:RefreshCountLabel()
end

function CTeamHandyBuildView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTargetTeam then
		self:RefreshHandyApply()
	elseif oCtrl.m_EventID == define.Team.Event.AddTeam then
		-- TODO:加入队伍后自动关闭UI或执行操作
		self:CloseView()
		CTeamMainView:ShowView()
	elseif oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch then
		self:RefreshAutoButton()
		-- self.m_AutoTargetBtn:RefreshAutoStatus()
	elseif oCtrl.m_EventID == define.Team.Event.NotifyCountAutoMatch then
		self:RefreshCountLabel()
	elseif oCtrl.m_EventID == define.Team.Event.RefreshApply then
		local tData = oCtrl.m_EventData
		-- printc("update teamid"..tData.teamid)
		self:UpdateApplyStatus(tData.teamid, tData.status)
	end
end

function CTeamHandyBuildView.RefreshAutoButton(self)
	self.m_AutoBtn:DelEffect("FingerInterval")
	self.m_GuideStr = ""
	if g_TeamCtrl:IsPlayerAutoMatch() and 
		g_TeamCtrl:GetPlayerAutoTarget() == self.m_SelectedTaskId then
		self.m_AutoBtn:SetText("取消匹配")
	else
		self.m_AutoBtn:SetText("自动匹配")
		if g_TaskCtrl:CheckGhostSecondStepFit() then
			self.m_GuideStr = "ghostguide"
			self.m_AutoBtn:AddEffect("FingerInterval", 1)
		elseif g_TaskCtrl:CheckFubenThreeStepFit() then
			self.m_GuideStr = "fubenguide"
			self.m_AutoBtn:AddEffect("FingerInterval", 1)
		end
	end
end

function CTeamHandyBuildView.RefreshCountLabel(self)
	local iTeamCount = 0
	local iMemberCount = 0

	local dCountInfo = g_TeamCtrl:GetCountAutoMatch(self.m_SelectedTaskId)
	if dCountInfo then
		iTeamCount = dCountInfo.team_count
		iMemberCount = dCountInfo.member_count
	end

	local str = string.format("队长%d人，队员%d人", iTeamCount, iMemberCount)
	self.m_CntLabel:SetText(str)
end

function CTeamHandyBuildView.RefreshTaskTable(self)
	self.m_TaskTable:Clear()
	local iSelIndex = 0
	for k,v in pairs(self.m_AutoTeamData) do
		if v.id ~= 0 then
			local taskBtn = self.m_TaskBtnClone:Clone(false)
			taskBtn:SetActive(true)
			taskBtn:SetAutoTeamData(v)
			taskBtn:SetListener(callback(self, "OnStatusChange"))
			local bIsSelected = taskBtn:InitSelected(self.m_SelectedTaskId, g_TeamCtrl:IsPlayerAutoMatch())
			self.m_TaskTable:AddChild(taskBtn)
			if bIsSelected then
				iSelIndex = self.m_TaskTable:GetCount()
			end
		end 
	end
	if iSelIndex > 7 then
		self:ScrollToBox(iSelIndex)
	end
	self.m_TaskBtnClone:SetActive(false)
end

function CTeamHandyBuildView.ScrollToBox(self, iIndex)
	local iScrollViewH = self.m_TaskPanel:GetViewSize().y
	local iCellH = 73
	local iDiffH = iCellH * (self.m_TaskTable:GetCount()) - iScrollViewH
	local vPos = Vector3.New(0, iIndex * iCellH, 0)
	vPos.y = math.min(iDiffH, vPos.y)
	vPos.y = math.max(0, vPos.y)
	self.m_TaskScroll:MoveRelative(vPos)
end

function CTeamHandyBuildView.RefreshHandyApply(self)
	local lTeam = g_TeamCtrl:GetTargetTeamList(self.m_SelectedTaskId)
	self.m_EmptyTex:SetActive(#lTeam == 0)
	if self.m_AutoRefresh then
		for i, dTeam in ipairs(lTeam) do
			local index = self.m_RefApplyBoxs[dTeam.teamid]
			local oBox = self.m_ApplyBoxs[index]
			if oBox then
				self:UpdateTeamMem(oBox, dTeam)
			end
		end
		self.m_AutoRefresh = false
		return
	else
		self.m_ScrollView:ResetPosition()
	end
	-- self.m_ApplyGrid:Clear()
	for k,oBox in pairs(self.m_ApplyBoxs) do
		if oBox then
			oBox:SetActive(false)
		end
	end
	self.m_RefApplyBoxs = {}
	for i, dTeam in ipairs(lTeam) do
		local oBox = self.m_ApplyBoxs[i]
		if oBox then
			oBox:SetActive(true)
			self:UpdateTeamMem(oBox, dTeam)
			oBox:SetTargetID(self.m_SelectedTaskId)
		else
			oBox = self:CreateHandyApplyBox(dTeam)
			self.m_ApplyBoxs[i] = oBox
		end
		self.m_RefApplyBoxs[dTeam.teamid] = i
	end
	self.m_ApplyGrid:Reposition()
end

function CTeamHandyBuildView.CreateHandyApplyBox(self, dTeam)
	local oBox = self.m_ApplyBox:Clone()
	oBox:SetActive(true)
	self:UpdateTeamMem(oBox, dTeam)
	self.m_ApplyGrid:AddChild(oBox)
	return oBox
end

function CTeamHandyBuildView.UpdateTeamMem(self, oBox, dTeam)
	oBox:SetHandyApply(dTeam)
end

function CTeamHandyBuildView.UpdateApplyStatus(self, iTeamId, iStatus)
	local index = self.m_RefApplyBoxs[iTeamId]
	local oBox = self.m_ApplyBoxs[index]
	if oBox then
		-- printc("refresh team "..iStatus)
		oBox:RefreshButtonStatus(iStatus)
		if iStatus == 2 then
			self.m_ApplyGrid:RemoveChild(oBox)
			self.m_ApplyGrid:Reposition()
			self.m_ApplyBoxs[index] = nil
		end
	end
end

function CTeamHandyBuildView.HideOther(self, oTarget)
	for i,oBox in ipairs(self.m_TaskTable:GetChildList()) do
		if oBox ~= oTarget then
			oBox:ExpandSubMenu(false)
		end
	end
	self.m_TaskTable:Reposition()
end

function CTeamHandyBuildView.AdjustTablePos(self, oBox)
	self.m_TaskScroll:ResetPosition()
	local iCnt = oBox.m_BtnGrid:GetCount()
	local _, iGridH = oBox.m_BtnGrid:GetCellSize()
	iGridH = iGridH * iCnt + 10
	local iScrollH = self.m_TaskPanel:GetViewSize().y
	local iIndex = self.m_TaskTable:GetChildIdx(oBox.m_Transform) - 1
	local iCellH = oBox.m_TaskBtn:GetHeight() + 4
	local iTableCnt = self.m_TaskTable:GetCount() - 1
	local iDiffH = iCellH * iTableCnt + iGridH - iScrollH + 38
	local vPos = Vector3.New(0, iIndex * iCellH, 0)
	vPos.y = math.min(iDiffH, vPos.y)
	vPos.y = math.max(0, vPos.y)
	self.m_TaskScroll:MoveRelative(vPos)
end

---------------------------------------------------
function CTeamHandyBuildView.OnStatusChange(self, oBox)
	self.m_SelectedTaskId = oBox:GetSelectedId()
	-- printc(self.m_SelectedTaskId)
	if self.m_SelectedTaskBtn and self.m_SelectedTaskBtn ~= oBox then
		self.m_SelectedTaskBtn:SetSelected(false)
	end

	self.m_SelectedTaskBtn = oBox
	-- self.m_SelectedTaskBtn:RefreshAutoStatus()
	local tData = data.teamdata.CATALOG[self.m_SelectedTaskId]
	self.m_AutoBtn:SetActive(tData == nil or tData.is_single == 1)

	self:RefreshAutoButton()
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.TeamTargetRefresh, self.m_SelectedTaskId) == nil then
		netteam.C2GSGetTargetTeamInfo(self.m_SelectedTaskId)
		self:AutoRefresh()
		-- g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.TeamTargetRefresh, self.m_SelectedTaskId, 5)
	else
		self:RefreshHandyApply()
	end
end

function CTeamHandyBuildView.RequestBuildTeam(self )
	-- g_NotifyCtrl:FloatMsg("创建队伍")
	if self.m_AutoBtn:GetActive() then
		netteam.C2GSCreateTeam(self.m_SelectedTaskId)
	else
		netteam.C2GSCreateTeam()
	end
end

function CTeamHandyBuildView.RequestRefresh(self )
	g_NotifyCtrl:FloatMsg("刷新中")
	-- TODO:如果倒計時未結束則只執行本地刷新，避免頻繁請求服務器
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.TeamTargetRefresh, self.m_SelectedTaskId) == nil then
		netteam.C2GSGetTargetTeamInfo(self.m_SelectedTaskId)
		self:AutoRefresh()
		g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.TeamTargetRefresh, self.m_SelectedTaskId, 0.1)
	else
		-- g_NotifyCtrl:FloatMsg("刷新频繁，请稍候再试")
	end
end

function CTeamHandyBuildView.RequestAutoApply(self )
	-- g_NotifyCtrl:FloatMsg("自动匹配")
	if not g_MapCtrl:IsTeamAllowed() then
		g_NotifyCtrl:FloatMsg("当前场景禁止组队")
		return
	end
	if g_TeamCtrl:IsPlayerAutoMatch() and 
		g_TeamCtrl:GetPlayerAutoTarget() == self.m_SelectedTaskId then
		netteam.C2GSPlayerCancelAutoMatch()
	else
		g_NotifyCtrl:FloatMsg("已开始自动匹配，请稍后")
		netteam.C2GSPlayerAutoMatch(self.m_SelectedTaskId)
		g_TeamCtrl:SetPlayerAutoTarget(self.m_SelectedTaskId)
		self.m_AutoTargetBtn = self.m_SelectedTaskBtn

		if self.m_GuideStr == "ghostguide" then
			g_TaskCtrl.m_GhostTaskGuide.second = true
			table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "ghostguide")
			g_GuideHelpCtrl.m_GuideExtraInfoHashList["ghostguide"] = true
			local list = {exdata = g_GuideHelpCtrl:TurnGuideExtraListToStr()}
			local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
			netnewbieguide.C2GSUpdateNewbieGuideInfo(encode.mask, encode.guide_links, encode.exdata)
		elseif self.m_GuideStr == "fubenguide" then
			g_TaskCtrl.m_FubenTaskGuide.three = true
			table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "fubenguide")
			g_GuideHelpCtrl.m_GuideExtraInfoHashList["fubenguide"] = true
			local list = {exdata = g_GuideHelpCtrl:TurnGuideExtraListToStr()}
			local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
			netnewbieguide.C2GSUpdateNewbieGuideInfo(encode.mask, encode.guide_links, encode.exdata)
		end
	end
end

function CTeamHandyBuildView.OnClickTotalTask(self)
	self.m_AutoBtn:SetActive(false)
	self.m_SelectedTaskId = 0
	self.m_SelectedTaskBtn = nil	
	-- g_TeamCtrl:SetPlayerAutoTarget(self.m_SelectedTaskId)
	netteam.C2GSGetTargetTeamInfo(self.m_SelectedTaskId)
	self:AutoRefresh()
end

function CTeamHandyBuildView.AutoRefresh(self)
	if self.m_RefreshTimer then
		Utils.DelTimer(self.m_RefreshTimer)
		self.m_RefreshTimer = nil
		self.m_AutoRefresh = false
	end
	local function refresh()
		if Utils.IsNil(self) then
			return
		end
		netteam.C2GSGetTargetTeamInfo(self.m_SelectedTaskId)
		self.m_AutoRefresh = true
		return true
	end
	self.m_RefreshTimer = Utils.AddTimer(refresh, 5, 5)
end

function CTeamHandyBuildView.OnShowView(self)
	g_TaskCtrl.m_GhostTaskGuide.second = false
	g_TaskCtrl.m_FubenTaskGuide.second = false
	g_TaskCtrl.m_FubenTaskGuide.three = false
end

return CTeamHandyBuildView
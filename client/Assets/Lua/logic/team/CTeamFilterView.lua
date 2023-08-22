local CTeamFilterView = class("CTeamFilterView", CViewBase)


function CTeamFilterView.ctor(self, cb)
	CViewBase.ctor(self, "UI/team/TeamFilterView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CTeamFilterView.OnCreateView(self)
	self.m_TaskBtnClone = self:NewUI(1, CTeamFilterBox, true, false)
	self.m_TaskScrollView = self:NewUI(2, CScrollView)
	self.m_TaskTable = self:NewUI(3, CTable)

	self.m_LvLimitScrollView = {}
	self.m_LvLimitScrollView["min"] = self:NewUI(4, CScrollView)
	self.m_LvLimitScrollView["max"] = self:NewUI(5, CScrollView)
	self.m_LvLimitScrollView["min"]["grid"] = self:NewUI(6, CGrid)
	self.m_LvLimitScrollView["max"]["grid"] = self:NewUI(7, CGrid)
	self.m_LvLimitScrollView["min"]["gradeLabel"] = self:NewUI(8, CLabel)
	self.m_LvLimitScrollView["max"]["gradeLabel"] = self:NewUI(9, CLabel)

	self.m_OkBtn = self:NewUI(10, CButton)
	self.m_AgreeCheckBox = self:NewUI(11, CWidget)
	self.m_CloseBtn = self:NewUI(12, CButton)
	self.m_DesLabel = self:NewUI(13, CLabel)

	self.m_MinGrade = 0
	self.m_MaxGrade = 0
	self.m_SelectedTaskId = 0
	self.m_Callback = nil
	self.m_AgreeStatuses = {}
	self.m_Targets = {}
	self.m_GradeLabels = {}
	self.m_ScrollTimer = {}
	self.m_TaskPanel = self.m_TaskScrollView:GetComponent(classtype.UIPanel)

	self:BindButtonEvent()
	self:SetAutoTeamData()
	self:LoadTeamFilterInfo()
	self:RefreshUI()
end

function CTeamFilterView.BindButtonEvent(self)
	self.m_OkBtn:AddUIEvent("click", callback(self,"RequestTeamFilter"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AgreeCheckBox:AddUIEvent("click", callback(self, "OnClickCheckBox"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CTeamFilterView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.Reset then
		self:CloseView()
	end
end

function CTeamFilterView.SetListener(self, cb)
	self.m_Callback = cb
end

function CTeamFilterView.SetAutoTeamData(self, data)
	--TODO:+30只是测试，请删除
	self.m_AutoTeamData = DataTools.GetAutoteamData(g_AttrCtrl.grade, g_KuafuCtrl:IsInKS())
end

function CTeamFilterView.GetTeamFilterInfo(self)
	local tTargetInfo = self.m_Targets[self.m_SelectedTaskId]
	return self.m_SelectedTaskId, tTargetInfo.min_grade, tTargetInfo.max_grade
end

function CTeamFilterView.SetSelectedTarget(self, iTaskId)
	self:RefreshSelectedBox(iTaskId)
end

-------------------------UI刷新---------------------------------
function CTeamFilterView.InitLvScrollView(self, scrollview, iMinGrade, iMaxGrade, cb)
	scrollview:ResetPosition()
	local grid = scrollview["grid"]	
	for _, label in pairs(grid:GetChildList()) do
		label:SetActive(false)
	end
	-- grid:Clear()
	local gradeLabelClone = scrollview["gradeLabel"]
	for iGrade = iMinGrade, iMaxGrade do
		local gradeLabel = grid:GetChild(iGrade - (iMinGrade - 1))
		if not gradeLabel then
			gradeLabel = gradeLabelClone:Clone(false)
			grid:AddChild(gradeLabel)
		end
		gradeLabel:SetText(iGrade)
		gradeLabel:SetActive(true)
		gradeLabel:SetName("Label_"..iGrade)
	end
	grid:Reposition()
	scrollview:InitCenterOnCompnent(grid, cb)
end

function CTeamFilterView.ScrollToTargetLevel(self, scrollview, iMinGrade, iMaxGrade, iTargetGrade)
	local grid = scrollview["grid"]
	local _,h = grid:GetCellSize()

	iTargetGrade = math.min(iMaxGrade, iTargetGrade)
	local scrollPos = Vector3.New(0, h*(iTargetGrade - iMinGrade - 2) - 34, 0)
	-- printc(string.format("%d:%d:%d",iMinGrade, iTargetGrade,grid:GetCount()))
	scrollview:MoveRelative(scrollPos)
	if self.m_ScrollTimer[scrollview:GetInstanceID()] then
		Utils.DelTimer(self.m_ScrollTimer[scrollview:GetInstanceID()])
		self.m_ScrollTimer[scrollview:GetInstanceID()] = nil
	end
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		local obj = grid:GetChild(iTargetGrade - iMinGrade + 1)
		if obj then
			scrollview:CenterOn(obj.m_Transform)
		end
		return false
	end
	self.m_ScrollTimer[scrollview:GetInstanceID()] = Utils.AddTimer(update, 0.1, 0.2)
end

function CTeamFilterView.ScrollToTaskBox(self, iIndex)
	local iScrollViewH = self.m_TaskPanel:GetViewSize().y
	local iCellH = 69
	local iDiffH = iCellH * (self.m_TaskTable:GetCount()) - iScrollViewH
	local vPos = Vector3.New(0, iIndex * iCellH, 0)
	vPos.y = math.min(iDiffH, vPos.y)
	vPos.y = math.max(0, vPos.y)
	self.m_TaskScrollView:MoveRelative(vPos)
end

function CTeamFilterView.RefreshUI(self)
	if not self.m_AutoTeamData then
		return
	end
	self:RefreshTaskTable()
	-- self:RefreshLvLimitPanel()
	-- self:RefreshTaskDesc()
end

function CTeamFilterView.RefreshTaskTable(self)
	local iSelIndex = 0
	for k,v in pairs(self.m_AutoTeamData) do
		local oBtn = self.m_TaskBtnClone:Clone(false)
		oBtn:SetActive(true)
		oBtn:SetAutoTeamData(v)
		oBtn:SetListener(callback(self, "OnStatusChange"))
		local bIsSelected = oBtn:InitSelected(self.m_SelectedTaskId)
		self.m_TaskTable:AddChild(oBtn)
		if bIsSelected then
			iSelIndex = self.m_TaskTable:GetCount()
		end
	end
	self:RefreshAllTaskBoxStatus(self.m_SelectedTaskId)
	self.m_TaskBtnClone:SetActive(false)
	if iSelIndex > 6 then
		self:ScrollToTaskBox(iSelIndex)
	end
end

function CTeamFilterView.RefreshLvLimitPanel(self, iMinGrade, iMaxGrade)
	self:InitLvScrollView(self.m_LvLimitScrollView["min"], iMinGrade, iMaxGrade, callback(self, "OnMinGradeCenter"))
	self:InitLvScrollView(self.m_LvLimitScrollView["max"], iMinGrade, iMaxGrade, callback(self, "OnMaxGradeCenter"))

	local targetInfo = self.m_Targets[self.m_SelectedTaskId]
	self:ScrollToTargetLevel(self.m_LvLimitScrollView["min"], iMinGrade, iMaxGrade, targetInfo.min_grade)
	self:ScrollToTargetLevel(self.m_LvLimitScrollView["max"], iMinGrade, iMaxGrade, targetInfo.max_grade)
end

function CTeamFilterView.RefreshTaskDesc(self, sDec)
	self.m_DesLabel:SetText(sDec)
end

function CTeamFilterView.RefreshCheckBox(self)
		-- 无目标状态下隐藏复选框
	local tData = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]
	local bIsShow = tData.is_parent == 0 and self.m_SelectedTaskId ~= g_TeamCtrl.TARGET_NONE
	self.m_AgreeCheckBox:SetActive(bIsShow)
	local status = self.m_Targets[self.m_SelectedTaskId].team_match == 1
	self.m_AgreeCheckBox:SetSelected(status)
end

function CTeamFilterView.RefreshTarget(self)
	local sDesc = "限制：无"
	local iMinLv = 0
	local iMaxLv = g_AttrCtrl.server_grade + 5
	local tData = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]
	local tTargetInfo = self.m_Targets[self.m_SelectedTaskId]

	if tData then
		sDesc = tData.desc
		iMinLv = tData.unlock_level

		if tTargetInfo.min_grade == -1 then
			if tData.target_type == 0 then --0：活动类型 1：挂机类型
				tTargetInfo.min_grade = math.max(tData.unlock_level, g_AttrCtrl.grade - 5)
				tTargetInfo.max_grade = math.min(g_AttrCtrl.grade + 5, g_AttrCtrl.server_grade + 5)
			else
				tTargetInfo.min_grade = tData.unlock_level
				tTargetInfo.max_grade = iMaxLv
			end
			self.m_Targets[self.m_SelectedTaskId] = tTargetInfo
		end
	end
	-- printc("类型："..tData.target_type.." 最小等级："..self.m_MinGrade.." 最大等级："..self.m_MaxGrade.." 范围："..iMinLv.." - "..iMaxLv)
	self:RefreshLvLimitPanel(iMinLv, iMaxLv)
	self:RefreshTaskDesc(sDesc)
end

function CTeamFilterView.RefreshAllTaskBoxStatus(self, iSelTaskId)
	for _,oBox in ipairs(self.m_TaskTable:GetChildList()) do
		oBox:RefreshSelectStatus(iSelTaskId)
	end
end

function CTeamFilterView.RefreshSelectedBox(self, iTaskId)
	for _,oBox in ipairs(self.m_TaskTable:GetChildList()) do
		oBox:InitSelected(iTaskId)
	end
end

function CTeamFilterView.HideOther(self, oTarget)
	for i,oBox in ipairs(self.m_TaskTable:GetChildList()) do
		if oBox ~= oTarget then
			oBox:ExpandSubMenu(false)
		end
	end
	self.m_TaskTable:Reposition()
end

function CTeamFilterView.AdjustTablePos(self, oBox)
	self.m_TaskScrollView:ResetPosition()
	local iCnt = oBox.m_BtnGrid:GetCount()
	local _, iGridH = oBox.m_BtnGrid:GetCellSize()
	iGridH = iGridH * iCnt + 10
	local iScrollH = self.m_TaskPanel:GetViewSize().y
	local iIndex = self.m_TaskTable:GetChildIdx(oBox.m_Transform) - 2
	local iCellH = oBox.m_TaskBtn:GetHeight() + 4
	local iTableCnt = self.m_TaskTable:GetCount() - 1
	local iDiffH = iCellH * iTableCnt + iGridH - iScrollH + 38
	local vPos = Vector3.New(0, iIndex * iCellH, 0)
	vPos.y = math.min(iDiffH, vPos.y)
	vPos.y = math.max(0, vPos.y)
	self.m_TaskScrollView:MoveRelative(vPos)
end

-------------------------点击响应或UI事件监听---------------------------------
function CTeamFilterView.OnMinGradeCenter(self, oGridCenter, gameObject)
	local grid = self.m_LvLimitScrollView["min"]["grid"]
	local idx = grid:GetChildIdx(gameObject.transform)
	local label = grid:GetChild(idx)
	local lastLabel = self.m_GradeLabels.min
	if label then
		if self.m_SelectedTaskId ~= g_TeamCtrl.TARGET_NONE then
			self.m_Targets[self.m_SelectedTaskId].min_grade =  tonumber(label:GetText())
		end
		if lastLabel then
			lastLabel:SetColor(Color.New(0x89/0xff, 0x60/0xff, 0x55/0xff, 1))
		end
		label:SetColor(Color.New(1, 0x76/0xff, 0x33/0xff, 1))
		self.m_GradeLabels.min = label
	end
end

function CTeamFilterView.OnMaxGradeCenter(self, oGridCenter, gameObject)
	local grid = self.m_LvLimitScrollView["max"]["grid"]
	local idx = grid:GetChildIdx(gameObject.transform)
	local label = grid:GetChild(idx)
	local lastLabel = self.m_GradeLabels.max

	if label then
		if self.m_SelectedTaskId ~= g_TeamCtrl.TARGET_NONE then
			self.m_Targets[self.m_SelectedTaskId].max_grade = tonumber(label:GetText())
		end
		if lastLabel then
			lastLabel:SetColor(Color.New(0x89/0xff, 0x60/0xff, 0x55/0xff, 1))
		end
		label:SetColor(Color.New(1, 0x76/0xff, 0x33/0xff, 1))
		self.m_GradeLabels.max = label
	end
end

function CTeamFilterView.OnStatusChange(self, oBox)
	if self.m_SelectedTaskBtn and self.m_SelectedTaskBtn ~= oBox then
		self.m_SelectedTaskBtn:SetSelected(false)
	end

	self.m_SelectedTaskBtn = oBox
	self.m_SelectedTaskId = oBox:GetSelectedId()

	self:RefreshCheckBox()
	self:RefreshTarget()
	self:RefreshAllTaskBoxStatus(self.m_SelectedTaskId)
end

function CTeamFilterView.RequestTeamFilter(self)
	local tData = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]

	if tData.is_parent == 1 then
		g_NotifyCtrl:FloatMsg("选择具体的匹配目标才能开始匹配哦")
		return
	end
	local tTargetInfo = self.m_Targets[self.m_SelectedTaskId]
	
	if g_TeamCtrl:GetMemberSize() >= tData.max_count then
		g_NotifyCtrl:FloatMsg("队伍人数已满,无法自动匹配")
		return
	end

	local bIsAuto = tTargetInfo.team_match
	if self.m_SelectedTaskId == g_TeamCtrl.TARGET_NONE then
		bIsAuto = 0
	end
	local iMinGrade = math.min(tTargetInfo.min_grade, tTargetInfo.max_grade)
	local iMaxGrade = math.max(tTargetInfo.min_grade, tTargetInfo.max_grade)

	netteam.C2GSTeamAutoMatch(self.m_SelectedTaskId, iMinGrade, iMaxGrade, bIsAuto)

	if self.m_Callback then
		self.m_Callback(self)
	end
	g_TeamCtrl:SetLocalTargetInfo(self.m_SelectedTaskId, tTargetInfo.min_grade, tTargetInfo.max_grade)
	self:SaveTeamFilterInfo()

	self:CloseView()
end

function CTeamFilterView.OnClickCheckBox(self)
	local bIsAuto = 0
	if self.m_AgreeCheckBox:GetSelected() then
		bIsAuto = 1
	end
	self.m_Targets[self.m_SelectedTaskId].team_match = bIsAuto
end

function CTeamFilterView.OnClose(self)
	CViewBase.OnClose(self)
	g_TeamCtrl.m_AutoRecruit = false
end

--------------------------Record-----------------------------------------
function CTeamFilterView.LoadTeamFilterInfo(self)
	for k,v in pairs(data.teamdata.AUTO_TEAM) do
		local sKey = string.format("team_min_lv_%d_%d", v.id, g_AttrCtrl.pid)
		local sKey1 = string.format("team_max_lv_%d_%d", v.id, g_AttrCtrl.pid)
		local sKey2 = string.format("team_auto_%d_%d", v.id, g_AttrCtrl.pid)

		self.m_Targets[v.id] = {
			min_grade = IOTools.GetClientData(sKey) or -1,
			max_grade = IOTools.GetClientData(sKey1) or -1,
			team_match = IOTools.GetClientData(sKey2) or 1
		}
	end

	local targetInfo = g_TeamCtrl:GetTargetInfo()
	if targetInfo then
		self.m_SelectedTaskId = targetInfo.auto_target
		self.m_Targets[self.m_SelectedTaskId].min_grade = targetInfo.min_grade
		self.m_Targets[self.m_SelectedTaskId].max_grade = targetInfo.max_grade
	else
		self.m_SelectedTaskId = IOTools.GetClientData("team_task_"..g_AttrCtrl.pid)
	end

	local isAuto = self.m_Targets[self.m_SelectedTaskId].team_match or 1
	self.m_AgreeCheckBox:SetSelected(isAuto == 1)
end

function CTeamFilterView.SaveTeamFilterInfo(self)
	IOTools.SetClientData("team_task_"..g_AttrCtrl.pid, self.m_SelectedTaskId)

	for targetId, targetInfo in pairs(self.m_Targets) do
		IOTools.SetClientData(string.format("team_min_lv_%d_%d",targetId, g_AttrCtrl.pid), targetInfo.min_grade)
		IOTools.SetClientData(string.format("team_max_lv_%d_%d",targetId, g_AttrCtrl.pid), targetInfo.max_grade)
		IOTools.SetClientData(string.format("team_auto_%d_%d",targetId, g_AttrCtrl.pid), targetInfo.team_match)
	end
end

return CTeamFilterView
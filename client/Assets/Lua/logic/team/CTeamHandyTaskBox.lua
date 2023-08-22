local CTeamHandyTaskBox = class("CTeamHandyTaskBox", CBox)

function CTeamHandyTaskBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SubMenuBg = self:NewUI(1, CSprite)
	self.m_TaskBtn = self:NewUI(2, CButton, true ,false)
	self.m_BtnGrid = self:NewUI(3, CGrid)
	self.m_CloneBtn = self:NewUI(4, CBox)
	self.m_ArrowSpr = self:NewUI(5, CSprite)
	self.m_SelectedSpr = self:NewUI(6, CSprite)
	self.m_TaskNameL = self:NewUI(7, CLabel)
	self.m_StatusSpr = self:NewUI(8, CSprite)
	self.m_SubNameLabel = self:NewUI(9, CLabel)
	self.m_SelTaskNameL = self:NewUI(10, CLabel)
	self.m_SelArrowSpr = self:NewUI(11, CSprite)

	self.m_IsInit = true
	self.m_IsSingle = false
	self.m_SelectedId = -1
	self.m_Callback = nil
	self.m_AutoteamData = nil
	self.m_IsExpand = false
	self.m_SubStatusSpr = nil
	self.m_SubMenus = {}
	self.m_FubenFirstId = 1201
	self:BindButtonEvent()
	self.m_TweenHeight = self.m_SubMenuBg:GetComponent(classtype.TweenHeight)
	self.m_TweenRotation_1 = self.m_ArrowSpr:GetComponent(classtype.TweenRotation)
	self.m_TweenRotation_2 = self.m_SelArrowSpr:GetComponent(classtype.TweenRotation)
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CTeamHandyTaskBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.NotifyCountAutoMatch or
		oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch then
		if self.m_IsInit then
			return
		end
		self:RefreshAutoStatus()
		self:RefreshTaskName()
	end
end

function CTeamHandyTaskBox.BindButtonEvent(self)
	self.m_TaskBtn:AddUIEvent("click", callback(self, "OnClickTask"))
end

-- 初始化数据
function CTeamHandyTaskBox.SetAutoTeamData(self, data)
	self.m_CatalogId = data.id
	self.m_AutoteamData = data
	local dSubData = DataTools.GetSubAutoteamData(data.id, g_AttrCtrl.grade)
	self.m_IsSingle = data.is_single == 1
	if self.m_IsSingle then
		self.m_AutoteamData = dSubData[1]
	else
		self.m_SubAutoteamData = dSubData
	end
	self:RefreshUI()
	self.m_IsInit = false
end

-- 设置监听器
function CTeamHandyTaskBox.SetListener(self, cb)
	self.m_Callback = cb
end

-- 初始化选定状态
function CTeamHandyTaskBox.InitSelected(self, taskId)
	local isSelected = false
	local selectedId = -1
	if self.m_AutoteamData.id == taskId then
		isSelected = true
		selectedId = taskId
		if not self.m_IsSingle then
			self:ExpandSubMenu(true)
		end
	else
		local oBtn = self:InitSubSelected(taskId)
		if oBtn then
			isSelected = true
			selectedId = taskId
		end
	end
	self:SetSelected(isSelected)
	if selectedId ~= -1 then
		self:SetSelectedId(selectedId)
	end
	self:RefreshTaskName()
	return isSelected
end

function CTeamHandyTaskBox.InitSubSelected(self, taskId)
	local oBtn = self.m_SubMenus[taskId]
	if oBtn then
		self:SetSelected(false)
		oBtn:SetSelected(true)
	end
	return oBtn
end

function CTeamHandyTaskBox.InitSubSelectedDelay(self)
	local function func()
		self:InitSubSelected(self.m_SelectedId)
		Utils.DelTimer(self.m_Timer)
	end
	self.m_Timer = Utils.AddTimer(func, 0, 0.1)
end

-- 执行UI刷新
function CTeamHandyTaskBox.RefreshUI(self)
	-- self:SetSelected(false)
	self:RefreshTaskButton()
	self:RefreshAutoStatus()
end

function CTeamHandyTaskBox.RefreshTaskName(self)
	self.m_TaskNameL:SetText(self.m_AutoteamData.name)
	self.m_SelTaskNameL:SetText(self.m_AutoteamData.name)
	self.m_SubNameLabel:SetActive(false)
	local vPos = nil
	local iTaskId = g_TeamCtrl:GetPlayerAutoTarget()
	local bIsAutoMatch = self.m_AutoteamData.id == iTaskId or self.m_SubMenus[iTaskId]

	if self.m_SelectedId ~= -1 and self.m_AutoteamData.id ~= self.m_SelectedId and
	   not self.m_IsExpand then--and bIsAutoMatch then
		local taskData = data.teamdata.AUTO_TEAM[self.m_SelectedId]
		self.m_SubNameLabel:SetText(taskData.name)
		self.m_SubNameLabel:SetActive(true)
		vPos = self.m_SubNameLabel:GetLocalPos()
		vPos.y = -15
		self.m_SubNameLabel:SetLocalPos(vPos)
		vPos = self.m_TaskNameL:GetLocalPos()
		vPos.y = 15
		self.m_TaskNameL:SetLocalPos(vPos)
		self.m_SelTaskNameL:SetLocalPos(vPos)
		if self.m_TaskBtn:GetSelected() then
			self.m_SubNameLabel:SetColor(Color.RGBAToColor("BD5733"))
		else
			self.m_SubNameLabel:SetColor(Color.RGBAToColor("244B4E"))
		end
	else
		vPos = self.m_TaskNameL:GetLocalPos()
		vPos.y = 0
		if self.m_IsSingle then
			vPos.x = 0 
		end
		self.m_TaskNameL:SetLocalPos(vPos)
		self.m_SelTaskNameL:SetLocalPos(vPos)
	end
end

function CTeamHandyTaskBox.RefreshTaskButton(self)
	if self.m_IsSingle then
		self.m_ArrowSpr:SetActive(false)
		self.m_SelArrowSpr:SetActive(false)
		self.m_SubMenuBg:SetParent(nil)
		self.m_SubMenuBg:Destroy()
	else
		self:CreateSubTaskButton()
		self.m_ArrowSpr:SetActive(true)
		self.m_SelArrowSpr:SetActive(true)
	end
	self.m_TaskNameL:SetText(self.m_AutoteamData.name)
	self.m_SelTaskNameL:SetText(self.m_AutoteamData.name)
end


function CTeamHandyTaskBox.RefreshAutoStatus(self)
	self.m_StatusSpr:SetActive(false)
	if self.m_SubStatusSpr then
		self.m_SubStatusSpr:SetActive(false)
	end

	local iTaskId = g_TeamCtrl:GetPlayerAutoTarget()

	if (self.m_AutoteamData.id == iTaskId or self.m_SubMenus[iTaskId])
		 and g_TeamCtrl:IsPlayerAutoMatch() then
		if self.m_IsExpand then
			local oBtn = self.m_SubMenus[iTaskId]
			oBtn.m_StatusSpr:SetActive(true)
			self.m_SubStatusSpr = oBtn.m_StatusSpr
		else
			self.m_StatusSpr:SetActive(true)
		end
	end
end

function CTeamHandyTaskBox.CreateSubTaskButton(self)
	local count = 0

	for k,data in pairs(self.m_SubAutoteamData) do
		local oBtn = self.m_CloneBtn:Clone(false)
		oBtn.m_StatusSpr = oBtn:NewUI(1, CSprite)
		oBtn.m_BtnLabel = oBtn:NewUI(2, CLabel)
		oBtn.m_SelBtnLable = oBtn:NewUI(3, CLabel)

		oBtn:SetName(tostring(data.id))
		oBtn.m_BtnLabel:SetText(data.name)
		oBtn.m_SelBtnLable:SetText(data.name)
		local callback = function()
			self:SetSelectedId(data.id)
			oBtn:SetSelected(true)
			if oBtn.m_GuideStr == "fubenguide" then
				g_TaskCtrl.m_FubenTaskGuide.second = true
				g_TeamCtrl:OnEvent(define.Team.Event.NotifyAutoMatch)
			end
		end
		oBtn:AddUIEvent("click", callback)
		self.m_BtnGrid:AddChild(oBtn)
		self.m_SubMenus[data.id] = oBtn
		oBtn:DelEffect("FingerInterval")
		if g_TaskCtrl:CheckFubenSecondStepFit() and data.id == self.m_FubenFirstId then
			oBtn.m_GuideStr = "fubenguide"
			oBtn:AddEffect("FingerInterval", 1)
		end
		count = count + 1
	end

	local _, h = self.m_BtnGrid:GetCellSize()
	self.m_TweenHeight.to = count * h + 15
	self.m_BtnGrid:RemoveChild(self.m_CloneBtn)
end

function CTeamHandyTaskBox.SetSelected(self, isSelected)
	self.m_TaskBtn:SetSelected(isSelected)
	local iTaskId = g_TeamCtrl:GetPlayerAutoTarget()
	local bIsAutoMatch = self.m_AutoteamData.id == iTaskId or self.m_SubMenus[iTaskId]

	if not isSelected and not bIsAutoMatch then
		local oSubMenu = self.m_SubMenus[self.m_SelectedId]
		if oSubMenu then
			oSubMenu:SetSelected(false)
		end
		self.m_SelectedId = self.m_AutoteamData.id
	end
end

function CTeamHandyTaskBox.SetSelectedId(self, taskId)
	self.m_SelectedId = taskId
	if self.m_Callback then
		self.m_Callback(self)
	end
end

function CTeamHandyTaskBox.GetSelectedId(self)
	return self.m_SelectedId
end

function CTeamHandyTaskBox.OnClickTask(self)
	if self.m_IsSingle then
		self:SetSelected(true)
		self:SetSelectedId(self.m_AutoteamData.id)
	else
		local function finish()
			self:AdjustPos()
		end
		self.m_TweenHeight.onFinished = finish
		self.m_IsExpand = not self.m_IsExpand
		self:RefreshTaskName()
		if self.m_IsExpand then
			self:InitSubSelectedDelay()
			if self.m_SelectedId ~= -1 then
				self:SetSelectedId(self.m_SelectedId)
			end
		end
		self:RefreshAutoStatus()
		local oBtn = self.m_SubMenus[self.m_SelectedId]
		if not oBtn then
			self:SetSelectedId(self.m_AutoteamData.id)
		end
	end
	local oView = CTeamHandyBuildView:GetView()
	oView:HideOther(self)
end

function CTeamHandyTaskBox.ExpandSubMenu(self, bIsExpande)
	if not self.m_SubAutoteamData or self.m_SubMenuBg:GetActive() == bIsExpande then
		return
	end
	self.m_IsExpand = not self.m_IsExpand
	self.m_SubMenuBg:SetActive(self.m_IsExpand)
	self.m_TweenHeight:Toggle()
	self.m_TweenRotation_1:Toggle()
	self.m_TweenRotation_2:Toggle()
	self:RefreshTaskName()
	self:RefreshAutoStatus()
end

function CTeamHandyTaskBox.AdjustPos(self)
	if not self.m_IsExpand then
		return
	end
	local oView = CTeamHandyBuildView:GetView()
	oView:AdjustTablePos(self)
end
return CTeamHandyTaskBox
local CTeamFilterBox = class("CTeamFilterBox", CBox)

function CTeamFilterBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SubMenuBg = self:NewUI(1, CSprite)
	self.m_TaskBtn = self:NewUI(2, CButton, true ,false)
	self.m_BtnGrid = self:NewUI(3, CGrid)
	self.m_CloneBtn = self:NewUI(4, CBox)
	self.m_ArrowSpr = self:NewUI(5, CSprite)
	self.m_TaskNameL = self:NewUI(6, CLabel)
	self.m_SubNameL = self:NewUI(7, CLabel)
	self.m_SelTaskNameL = self:NewUI(8, CLabel)
	self.m_SelArrowSpr = self:NewUI(9, CSprite)
	self.m_SelSubNameL = self:NewUI(10, CLabel)
	self.m_MatchFlagSpr = self:NewUI(11, CSprite)

	self.m_IsSingle = false
	self.m_SelectedId = -1
	self.m_Callback = nil
	self.m_AutoteamData = nil
	self.m_IsExpand = false
	self.m_SubMenus = {}
	self.m_SubAutoteamData = {}
	self.m_TweenHeight = self.m_SubMenuBg:GetComponent(classtype.TweenHeight)
	self.m_TweenRotation_1 = self.m_ArrowSpr:GetComponent(classtype.TweenRotation)
	self.m_TweenRotation_2 = self.m_SelArrowSpr:GetComponent(classtype.TweenRotation)
	self:BindButtonEvent()
end

function CTeamFilterBox.BindButtonEvent(self)
	self.m_TaskBtn:AddUIEvent("click", callback(self, "OnClickTask"))
end

function CTeamFilterBox.SetAutoTeamData(self, data)
	self.m_AutoteamData = data
	local dSubData = DataTools.GetSubAutoteamData(data.id, g_AttrCtrl.grade)
	self.m_IsSingle = data.is_single == 1
	if self.m_IsSingle then
		self.m_AutoteamData = dSubData[1]
	else
		self.m_SubAutoteamData = dSubData
	end
	self:RefreshUI()
end

function CTeamFilterBox.SetListener(self, cb)
	self.m_Callback = cb
end

function CTeamFilterBox.SetSelected(self, isSelected)
	self.m_TaskBtn:ForceSelected(isSelected)
	local iTaskId = g_TeamCtrl:GetTargetInfo().auto_target
	local bIsAutoMatch = self.m_AutoteamData.id == iTaskId or self.m_SubMenus[iTaskId]

	if not isSelected and not bIsAutoMatch then
		local oSubMenu = self.m_SubMenus[self.m_SelectedId]
		if oSubMenu then
			oSubMenu:ForceSelected(false)
		end
		self.m_SelectedId = self.m_AutoteamData.id
	end
end

function CTeamFilterBox.SetSelectedId(self, taskId)
	self.m_SelectedId = taskId
	if self.m_Callback then
		self.m_Callback(self)
	end
end

function CTeamFilterBox.GetSelectedId(self)
	return self.m_SelectedId
end

function CTeamFilterBox.InitSelected(self, taskId)
	local isSelected = false
	local selectedId = -1
	if self.m_AutoteamData.id == taskId then
		if not self.m_IsSingle then
			self:ExpandSubMenu(true)
			local iTaskId = g_TeamCtrl:GetTargetInfo().auto_target
			isSelected = self.m_SubMenus[iTaskId] == nil
		else
			isSelected = true
			selectedId = taskId
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

function CTeamFilterBox.InitSubSelected(self, taskId)
	local oBtn = self.m_SubMenus[taskId]
	if oBtn then
		self:SetSelected(false)
		oBtn:SetSelected(true)
	end
	return oBtn
end

function CTeamFilterBox.InitSubSelectedDelay(self)
	local function func()
		self:InitSubSelected(self.m_SelectedId)
		Utils.DelTimer(self.m_Timer)
	end
	self.m_Timer = Utils.AddTimer(func, 0, 0.1)
end

function CTeamFilterBox.RefreshUI(self)
	self:RefreshTaskButton()
end

function CTeamFilterBox.RefreshTaskName(self)
	self.m_TaskNameL:SetText(self.m_AutoteamData.name)
	self.m_SelTaskNameL:SetText(self.m_AutoteamData.name)
	self.m_SubNameL:SetActive(false)
	self.m_SelSubNameL:SetActive(false)
	local vPos = self.m_TaskNameL:GetLocalPos()

	local iTaskId = g_TeamCtrl:GetTargetInfo().auto_target
	local bIsAutoMatch = self.m_AutoteamData.id == iTaskId or self.m_SubMenus[iTaskId]
	local iFontSize = 24
	if self.m_SelectedId ~= -1 and self.m_AutoteamData.id ~= self.m_SelectedId and
	   not self.m_IsExpand then
		local taskData = data.teamdata.AUTO_TEAM[self.m_SelectedId]
		self.m_SubNameL:SetText(taskData.name)
		self.m_SubNameL:SetActive(true)
		self.m_SelSubNameL:SetText(taskData.name)
		self.m_SelSubNameL:SetActive(true)
		vPos.y = 11
		self.m_TaskNameL:SetLocalPos(vPos)
		local iy = vPos.y 
		vPos = self.m_SelTaskNameL:GetLocalPos()
		vPos.y = iy
		self.m_SelTaskNameL:SetLocalPos(vPos)
		iFontSize = 22
	else
		vPos.y = 0
		self.m_TaskNameL:SetLocalPos(vPos)
		vPos = self.m_SelTaskNameL:GetLocalPos()
		vPos.y = -4
		self.m_SelTaskNameL:SetLocalPos(vPos)
	end
	self.m_TaskNameL:SetFontSize(iFontSize)
	self.m_SelTaskNameL:SetFontSize(iFontSize)
end

function CTeamFilterBox.RefreshTaskButton(self)
	if self.m_IsSingle then
		self.m_ArrowSpr:SetActive(false)
		self.m_SelArrowSpr:SetActive(false)
		-- self.m_SelArrowSpr:SetParent(nil)
		-- self.m_SelArrowSpr:Destroy()
		self.m_SubMenuBg:SetParent(nil)
		self.m_SubMenuBg:Destroy()
	else
		self:CreateSubTaskButton()
		self.m_ArrowSpr:SetActive(true)
		self.m_SelArrowSpr:SetActive(true)
	end
	self.m_TaskNameL:SetText(self.m_AutoteamData.name)
end

function CTeamFilterBox.RefreshSelectStatus(self, taskId)
	self.m_MatchFlagSpr:SetActive(false)
	if (self.m_AutoteamData.id == taskId and self.m_IsSingle) or self.m_SubMenus[taskId] then
		self.m_MatchFlagSpr:SetActive(true)
	end
end

function CTeamFilterBox.CreateSubTaskButton(self)
	local count = 0

	for k,data in pairs(self.m_SubAutoteamData) do
		local oBtn = self.m_CloneBtn:Clone(false)
		oBtn.m_BtnLabel = oBtn:NewUI(1, CLabel)
		oBtn.m_SelBtnLable = oBtn:NewUI(2, CLabel)
		oBtn:SetName(tostring(data.id))
		oBtn.m_BtnLabel:SetText(data.name)
		oBtn.m_SelBtnLable:SetText(data.name)
		local callback = function()
			self:SetSelectedId(data.id)
			self:SetSelected(true)
			self:ExpandSubMenu(false)
			local oView = CTeamFilterView:GetView()
			oView.m_TaskTable:Reposition()
			self:RefreshTaskName()
		end
		oBtn:AddUIEvent("click", callback)
		self.m_BtnGrid:AddChild(oBtn)
		self.m_SubMenus[data.id] = oBtn
		count = count + 1
	end

	local _, h = self.m_BtnGrid:GetCellSize()
	self.m_TweenHeight.to = count * h + 15

	self.m_BtnGrid:RemoveChild(self.m_CloneBtn)
end

function CTeamFilterBox.OnClickTask(self)
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
		if not self.m_SubMenuBg:GetActive() then
			self:InitSubSelectedDelay()
		end
	end
	local oView = CTeamFilterView:GetView()
	oView:HideOther(self)
end

function CTeamFilterBox.ExpandSubMenu(self, bIsExpande)
	if not next(self.m_SubAutoteamData) or self.m_SubMenuBg:GetActive() == bIsExpande then
		return
	end
	self.m_IsExpand = not self.m_IsExpand
	self.m_SubMenuBg:SetActive(bIsExpande)
	self.m_TweenHeight:Play(bIsExpande)
	self.m_TweenRotation_1:Play(bIsExpande)
	self.m_TweenRotation_2:Play(bIsExpande)
end

function CTeamFilterBox.AdjustPos(self)
	if not self.m_IsExpand then
		return
	end
	local oView = CTeamFilterView:GetView()
	oView:AdjustTablePos(self)
end

return CTeamFilterBox
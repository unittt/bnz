local CTaskTypeMenuBox = class("CTaskTypeMenuBox", CBox)

function CTaskTypeMenuBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_ClickCallback = cb
	self.m_TaskMainMenu = nil

	self.m_MainMenuBtn = self:NewUI(1, CButton, true, false)
	self.m_ArrowSpr = self:NewUI(2, CSprite)
	self.m_SubMenuBgSpr = self:NewUI(3, CWidget)
	self.m_SubMenuPanel = self:NewUI(4, CPanel)
	self.m_SubMenuGrid = self:NewUI(5, CGrid)
	self.m_SubMenuBtnClone = self:NewUI(6, CBox)
	self.m_MainMenuSelectLbl = self:NewUI(7, CLabel)
	self.m_SelArrowSpr = self:NewUI(8, CSprite)
	self.m_TweenRotation = self.m_ArrowSpr:GetComponent(classtype.TweenRotation)
	self.m_SelTweenRotation = self.m_SelArrowSpr:GetComponent(classtype.TweenRotation)

	self.m_TweenHeight = self.m_SubMenuBgSpr:GetComponent(classtype.TweenHeight)
	self.m_IgnoreCheckEffect = false

	self.m_SubMenuBtnClone:SetActive(false)
end

--设置任务界面二级菜单的数据接口
function CTaskTypeMenuBox.SetTypeMenu(self, mainMenu, groupID)
	if mainMenu then
		self.m_TaskMainMenu = mainMenu
		self:RefMenuBox(mainMenu, groupID)
	else
		print("CTaskTypeMenuBox.SetTypeMenu mainMenu没有数据")
	end
end

--获取自定义任务的名字,1)副本任务> 2)主线剧情 > 3)虚拟的特殊任务 > 4)日常任务 > 5)活动任务 > 6)引导任务 > 7)支线任务 > 8)帮派任务 > 9)场景任务 > 10)测试任务
--以后要根据需求修改
function CTaskTypeMenuBox.GetDiyTaskTypeName(self, iType)
	if iType == 1 then
		return "副本任务"
	elseif iType == 2 then
		return "主线任务"
	elseif iType == 3 then
		return "特殊任务"
	elseif iType == 4 then
		return "日常任务"
	elseif iType == 5 then
		return "活动"
	elseif iType == 6 then
		return "引导"
	elseif iType == 7 then
		return "支线任务"
	elseif iType == 8 then
		return "帮派任务"
	elseif iType == 9 then
		return "场景任务"
	elseif iType == 10 then
		return "测试任务"
	else
		return "未配置任务"
	end
end

--这里是刷新任务界面二级菜单，如主线任务/神秘声音
function CTaskTypeMenuBox.RefMenuBox(self, mainMenu, groupID)
	local mainMenuName = self:GetDiyTaskTypeName(mainMenu.type) --DataTools.GetTaskType(mainMenu.type).name .. "任务"
	--这里是设置任务一级菜单tab的名字
	self.m_MainMenuBtn:SetText(mainMenuName)
	self.m_MainMenuSelectLbl:SetText(mainMenuName)
	local taskCount = #mainMenu.taskList
	local subMenuBoxList = self.m_SubMenuGrid:GetChildList() or {}
	local bHasRedDot = false
	if taskCount > 0 then
		for i,v in ipairs(mainMenu.taskList) do
			local oSubMenu = nil
			if i > #subMenuBoxList then
				oSubMenu = self.m_SubMenuBtnClone:Clone()
				oSubMenu:SetGroup(groupID)
				self.m_SubMenuGrid:AddChild(oSubMenu)
				oSubMenu:AddUIEvent("click", callback(self, "OnClickSubMenu", v, oSubMenu))
			else
				oSubMenu = subMenuBoxList[i]
			end
			if v:GetCValueByKey("type") == define.Task.TaskCategory.RUNRING.ID then
				local oStrIndex = string.find(v:GetSValueByKey("name"), "%b()")
				local oNameStr = v.m_TaskType.name..string.sub(v:GetSValueByKey("name"), oStrIndex, -1)
				oSubMenu:NewUI(2, CLabel):SetText(oNameStr)
				oSubMenu:NewUI(3, CLabel):SetText(oNameStr)
			else
				oSubMenu:NewUI(2, CLabel):SetText(v:GetSValueByKey("name"))
				oSubMenu:NewUI(3, CLabel):SetText(v:GetSValueByKey("name"))
			end
			oSubMenu:SetActive(true)
			if g_TaskCtrl.m_AceTaskNotify[v:GetSValueByKey("taskid")] then
				local bNew = g_TaskCtrl.m_AceTaskNotify[v:GetSValueByKey("taskid")] == 0
				oSubMenu:NewUI(1, CObject):SetActive(bNew)
				bHasRedDot = bHasRedDot or bNew
				oSubMenu.hasRedDot = bNew
			else
				oSubMenu:NewUI(1, CObject):SetActive(false)
				oSubMenu.hasRedDot = false
			end
		end

		local _, h = self.m_SubMenuBtnClone:GetSize()

		self.m_TweenHeight.to = (taskCount + 0.2) * (h+5)-- + 26(用0.5加了)

		-- for i=#mainMenu.taskList+1,#subMenuBoxList do
		-- 	subMenuBoxList[i]:SetActive(false)
		-- end
		self:ShowRedDot(bHasRedDot)
	elseif subMenuBoxList and #subMenuBoxList > 0 then
		for _,v in ipairs(subMenuBoxList) do
			v:SetActive(false)
		end
	end
end

--外界调用选中任务界面二级菜单中的一个item
function CTaskTypeMenuBox.SelectSubMenu(self, index)
	local gridList = self.m_SubMenuGrid:GetChildList()
	if gridList and #gridList > 0 then
		index = index or 1
		local oSub = gridList[index]
		if oSub then
			oSub:SetSelected(true)
			oSub:NewUI(1, CObject):SetActive(false)
			if oSub.hasRedDot then
				oSub.hasRedDot = false
				self:RefreshRedDot()
			end
		end
	end
end

--重置二级菜单的的选中状态
function CTaskTypeMenuBox.ResetSubMenu(self)
	local gridList = self.m_SubMenuGrid:GetChildList()
	for k,v in pairs(gridList) do
		v:ForceSelected(false)
	end
end

--点击任务界面二级菜单
function CTaskTypeMenuBox.OnClickSubMenu(self, oTask, oBox)
	-- print(string.format("<color=#00FF00> >>> .%s | %s | Table:%s </color>", "OnClickSubMenu", "点击二级任务菜单", "oTask"))
	-- table.print(oTask)
	if self.m_ClickCallback and self.m_TaskMainMenu then
		self.m_ClickCallback(oTask)
	end
	oBox:NewUI(1, CObject):SetActive(false)
	if oBox.hasRedDot then
		oBox.hasRedDot = false
		self:RefreshRedDot()
	end
end

function CTaskTypeMenuBox.RefreshRedDot(self)
	local bShow = false
	for i,oBox in ipairs(self.m_SubMenuGrid:GetChildList()) do
		if oBox.hasRedDot then
			bShow = true
			break
		end
	end
	self:ShowRedDot(bShow)
end

function CTaskTypeMenuBox.ShowRedDot(self, bShow)
	if bShow then
		self:AddEffect("RedDot", 22, Vector2(-20,-20))
	else
		self:DelEffect("RedDot")
	end
end

return CTaskTypeMenuBox

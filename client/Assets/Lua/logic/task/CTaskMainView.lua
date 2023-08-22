local CTaskMainView = class("CTaskMainView", CViewBase)

function CTaskMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/TaskMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CTaskMainView.OnCreateView(self)
	self.m_PartInfoList = {}
	self.m_TaskMenuBoxTable = {}
	self.m_ShowPart = false
	self.m_Timer = {}
	self.m_TimeCount = 0

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TitleLabel = self:NewUI(2, CLabel)
	self.m_TabBtnGrid = self:NewUI(3, CTabGrid)
	self.m_NilTipObj = self:NewUI(4, CObject)
	self.m_NilTipMsg = self:NewUI(5, CLabel)
	self.m_Container = self:NewUI(6, CObject)
	self.m_TypeContent = self:NewUI(7, CObject)
	self.m_TypeScly = self:NewUI(8, CScrollView)
	self.m_TypeTable = self:NewUI(9, CTable)
	self.m_TypeMenuBoxClone = self:NewUI(10, CTaskTypeMenuBox)
	self.m_CurPart = self:NewPage(11, CTaskMainCurPart)
	self.m_AcePart = self:NewPage(12, CTaskMainAcePart)
	self.m_StoryPart = self:NewPage(13, CTaskMainStoryPart)
	self.m_AceTaskRedPoint = self:NewUI(14, CObject)
	self.m_CurPartBgBox = self:NewUI(15, CBox)
	self.m_WinBg = self:NewUI(16, CSprite)
	self.m_StoryTaskRedPoint = self:NewUI(17, CObject)
	self.m_TaskGuideWidget = self:NewUI(18, CWidget)

	g_GuideCtrl:AddGuideUI("task_guide_widget", self.m_TaskGuideWidget)

	self:InitContent()
	if not g_TaskCtrl:GetIsAllChapterPrizeRewarded() then
		self:ShowSpecificPart(self:GetPageIndex("Story"))
	elseif not g_TaskCtrl:GetIsAllAceTaskRead() then
		self:ShowSpecificPart(self:GetPageIndex("Accept"))
	else
		self:ShowSpecificPart(g_TaskCtrl.m_RecordTask.partTab)
	end
end

--初始化执行
function CTaskMainView.InitContent(self)
	self.m_TypeMenuBoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	-- 分页按钮
	local function initTab(obj, idx)
		local oBtn = CButton.New(obj, false)
		oBtn:SetGroup(self.m_TabBtnGrid:GetInstanceID())
		return oBtn
	end
	self.m_TabBtnGrid:InitChild(initTab)
	self.m_PartInfoList = {
		{title = "当前任务", part = self.m_CurPart},
		{title = "可接任务", part = self.m_AcePart},
		{title = "剧情任务", part = self.m_StoryPart},
	}
	for i,v in ipairs(self.m_PartInfoList) do
		if self.m_TabBtnGrid:GetChild(i) then
			v.btn = self.m_TabBtnGrid:GetChild(i)
			v.btn:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i, true))
		end
	end

	self:SetAceTabRedPoint(not g_TaskCtrl:GetIsAllAceTaskRead())
	self:SetStoryTabRedPoint(not g_TaskCtrl:GetIsAllChapterPrizeRewarded())
end

--任务协议返回
function CTaskMainView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshAllTaskBox then
		-- local partInfo = self.m_PartInfoList[g_TaskCtrl.m_RecordTask.partTab]
		self:ShowSubPageByIndex(g_TaskCtrl.m_RecordTask.partTab)
	elseif oCtrl.m_EventID == define.Task.Event.RefreshSpecificTaskBox then
		print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "OnCtrlEvent", "第二种：指定的任务回调"))
	elseif oCtrl.m_EventID == define.Task.Event.AddAceTaskNotify then
		self:SetAceTabRedPoint(not g_TaskCtrl:GetIsAllAceTaskRead())
		self:RefreshTaskContent(g_TaskCtrl.m_RecordTask.partTab, self.m_PartInfoList[g_TaskCtrl.m_RecordTask.partTab])
	elseif oCtrl.m_EventID == define.Task.Event.RedPointNotify then
		self:SetStoryTabRedPoint(not g_TaskCtrl:GetIsAllChapterPrizeRewarded())
	end
end

--显示当前tab、可接tab、剧情tab中的一个的接口
function CTaskMainView.ShowSpecificPart(self, tabIndex)
	if not tabIndex or tabIndex <= 0 then
		g_TaskCtrl.m_RecordTask.partTab = 1
		tabIndex = 1
	end
	self:ShowSubPageByIndex(tabIndex)
end

--点击tab
function CTaskMainView.ShowSubPageByIndex(self, tabIndex, checkTab)
	if checkTab and g_TaskCtrl.m_RecordTask.partTab == tabIndex then
		return
	end

	local args = self.m_PartInfoList[tabIndex]
	g_TaskCtrl.m_RecordTask.partTab = tabIndex
	self.m_TitleLabel:SetText(args.title)
	self.m_TabBtnGrid:SetTabSelect(args.btn)

	self:RefreshTaskContent(tabIndex, args)
end

--刷新任务界面的内容,菜单和右边的内容
function CTaskMainView.RefreshTaskContent(self, tabIndex, args)
	if tabIndex == 3 then
		self.m_Container:SetActive(true)
		self.m_NilTipObj:SetActive(false)
		self.m_TypeContent:SetActive(false)
		self.m_CurPartBgBox:SetActive(false)
		-- self.m_WinBg:GetComponent(classtype.BoxCollider).enabled = false
		self:ShowSubPage(args.part)
		-- self.m_StoryPart:RefreshUI()
	else
		-- self.m_WinBg:GetComponent(classtype.BoxCollider).enabled = true
		self.m_TypeContent:SetActive(true)
		self.m_CurPartBgBox:SetActive(true)

		-- 判断一下，是否显示NilTip
		local taskMenu = g_TaskCtrl:GetTaskMenu(tabIndex)
		table.print(taskMenu, "任务界面的taskMenu数据")
		self.m_ShowPart = taskMenu and table.count(taskMenu) > 0 or false

		if self.m_ShowPart then
			self:ShowSubPage(args.part)
			self:RefTypeMenuBox(taskMenu)
		else
			self.m_NilTipMsg:SetText(string.format("已经没有%s了哦！", args.title))
		end
		self.m_Container:SetActive(self.m_ShowPart)
		self.m_NilTipObj:SetActive(not self.m_ShowPart)

		self.m_AcePart.m_ContentScrollView:ResetPosition()
	end
end

--创建任务界面一级菜单Obj以及调用二级菜单创建Obj接口
function CTaskMainView.RefTypeMenuBox(self, taskMenu)
	-- table.sort(taskMenu, function (a, b)
	-- 	return a.sort < b.sort
	-- end)

	local igonerList = {}
	local oSpareInfo = nil
	local oSelectTask = nil
	local groupID = self.m_TypeTable:GetInstanceID()
	self.m_TypeTable:Clear()
	--显示任务界面一级菜单，如主线任务
	for k,v in ipairs(taskMenu) do
		--判断这个自定义的任务type有没有任务
		if next(v.taskList) then			
			-- table.insert(igonerList, k)

			local oTaskMenuBox-- = self.m_TaskMenuBoxTable[1]
			if oTaskMenuBox then				
			else
				oTaskMenuBox = self.m_TypeMenuBoxClone:Clone(function (oTask)
					self:OnSubTaskMenuBox(oTask)
				end)				

				local name = oTaskMenuBox.m_GameObject.name .. "_" .. k
				oTaskMenuBox:SetName(name)

				self.m_TypeTable:AddChild(oTaskMenuBox)
				oTaskMenuBox.m_MainMenuBtn:SetGroup(groupID+1)
				-- table.insert(self.m_TaskMenuBoxTable, oTaskMenuBox)
				-- self.m_TaskMenuBoxTable[k] = oTaskMenuBox
			end
			oTaskMenuBox:SetActive(true)
			-- 设置任务界面二级菜单的内容,如主线任务/神秘声音
			oTaskMenuBox:SetTypeMenu(v, groupID)

			oTaskMenuBox.m_MainMenuBtn:AddUIEvent("click", callback(self, "OnClickTaskMenuBox", v, oTaskMenuBox))

			for i,oTask in ipairs(v.taskList) do
				if not oSpareInfo then
					oSpareInfo = {}
					oSpareInfo.task = oTask
					oSpareInfo.box = oTaskMenuBox
				end
			end

			if not oSelectTask then
				-- printc("没有oSelectTask数据")
				local recordMainMenu = g_TaskCtrl.m_RecordTask.menu[g_TaskCtrl.m_RecordTask.partTab]
				table.print(recordMainMenu, "recordMainMenu")
				local mainMenu = recordMainMenu.mainMenu
				local subMenu = recordMainMenu.subMenu
				if (mainMenu and (mainMenu == 0 or mainMenu == v.type)) or not mainMenu then
					-- oTaskMenuBox.m_MainMenuBtn:Notify(enum.UIEvent["click"])
					oTaskMenuBox.m_MainMenuBtn:SetSelected(true)
					oTaskMenuBox.m_SubMenuBgSpr:SetActive(true)
					oTaskMenuBox.m_TweenRotation:Play(true)
					oTaskMenuBox.m_SelTweenRotation:Play(true)
					oTaskMenuBox.m_TweenHeight:Play(true)
					for i,oTask in ipairs(v.taskList) do
						if not oSpareInfo then
							oSpareInfo = {}
							oSpareInfo.task = oTask
							oSpareInfo.box = oTaskMenuBox
						end
						if (subMenu and (subMenu == 0 or subMenu == oTask:GetSValueByKey("taskid"))) or not subMenu then
							-- printc("没有oSelectTask数据，默认选中subMenu", i)
							oSelectTask = oTask
							oTaskMenuBox:SelectSubMenu(i)
							self:OnSubTaskMenuBox(oTask, true)
							break
						end
					end
				end
			end
		end
	end

	-- for k,v in ipairs(self.m_TaskMenuBoxTable) do
	-- 	if not table.index(igonerList, k) then
	-- 		v:SetActive(false)
	-- 		v:SetTypeMenu()
	-- 	end
	-- end

	if not oSelectTask then
		if oSpareInfo then
			-- printc("没有oSelectTask数据，默认选中第一个")
			oSpareInfo.box.m_TweenRotation:Play(true)
			oSpareInfo.box.m_SelTweenRotation:Play(true)
			oSpareInfo.box.m_TweenHeight:Play(true)
			oSpareInfo.box:SelectSubMenu(1)
			self:OnSubTaskMenuBox(oSpareInfo.task, true)
		end
	end

	self.m_TypeTable:Reposition()
	self.m_TypeScly:ResetPosition()
end

--这里是点击二级任务菜单或代码调用后显示任务界面右边内容的接口
function CTaskMainView.OnSubTaskMenuBox(self, oTask, ignore)
	local partTab = g_TaskCtrl.m_RecordTask.partTab
	local mainMenu = g_TaskCtrl.m_RecordTask.menu[partTab].mainMenu
	local subMenu = g_TaskCtrl.m_RecordTask.menu[partTab].subMenu
	local mainid = g_TaskCtrl:GetTaskDiyType(oTask:GetCValueByKey("type") or 1)
	local taskid = oTask:GetSValueByKey("taskid")

	if not ignore and mainMenu == mainid and subMenu == taskid then
		return
	end

	g_TaskCtrl.m_RecordTask.menu[partTab].mainMenu = mainid
	g_TaskCtrl.m_RecordTask.menu[partTab].subMenu = taskid
	if oTask and self.m_ShowPart then
		local part = self.m_PageList[g_TaskCtrl.m_RecordTask.partTab]
		if part.SetTaskInfo then
			part:SetTaskInfo(oTask)
		end
	end
end

--点击一级菜单
function CTaskMainView.OnClickTaskMenuBox(self, taskMenuData, oTaskMenuBox)
	local tableList = self.m_TypeTable:GetChildList()
	for k,v in pairs(tableList) do
		local bPlay = (v ~= oTaskMenuBox) or (v == oTaskMenuBox and self.m_LastTaskMenuBox == oTaskMenuBox and oTaskMenuBox.m_ClickState)
		v.m_TweenRotation:Play(bPlay)
		v.m_SelTweenRotation:Play(not bPlay)
		if bPlay then
			v.m_TweenHeight:Play(false)
			self:SetOnTweenHeightFinished(v)
		end
		v:ResetSubMenu()
	end
	if self.m_LastTaskMenuBox ~= oTaskMenuBox then
		oTaskMenuBox:SelectSubMenu(1)
		self:OnSubTaskMenuBox(taskMenuData.taskList[1], true)
		oTaskMenuBox.m_ClickState = true
	else
		if not oTaskMenuBox.m_ClickState then
			oTaskMenuBox:SelectSubMenu(1)
			self:OnSubTaskMenuBox(taskMenuData.taskList[1], true)
		end
		oTaskMenuBox.m_ClickState = not oTaskMenuBox.m_ClickState
	end
	self.m_LastTaskMenuBox = oTaskMenuBox
end

--当一级菜单收回的时候m_SubMenuBgSpr设置为false
function CTaskMainView.SetOnTweenHeightFinished(self, oTaskMenuBox)
	self.m_TimeCount = self.m_TimeCount + 1
	local function progress()
		-- printc("CTaskMainView.SetOnTweenHeightFinished")
		oTaskMenuBox.m_SubMenuBgSpr:SetActive(false)
		return false
	end
	self.m_Timer[self.m_TimeCount] = Utils.AddTimer(progress, 0, 0.3)
end

--设置可接任务tab红点ui
function CTaskMainView.SetAceTabRedPoint(self, bIsShow)
	self.m_AceTaskRedPoint:SetActive(bIsShow)
end

--设置剧情tab红点ui
function CTaskMainView.SetStoryTabRedPoint(self, bIsShow)
	self.m_StoryTaskRedPoint:SetActive(bIsShow)
end

function CTaskMainView.OnShowPieceView(self)
	--暂时屏蔽
	-- if g_TaskCtrl.m_RecordTask.partTab == 3 then
	-- 	if g_TaskCtrl.m_TaskCurChapter >=1 and g_TaskCtrl.m_TaskCurChapter <= #g_TaskCtrl:GetShowChapterList() then
	-- 		CTaskStoryPieceView:ShowView(function (oView)
	-- 			oView:RefreshUI(g_TaskCtrl:CheckTaskChapterList(g_TaskCtrl.m_TaskCurChapter))
	-- 		end)
	-- 	end
	-- end
end

return CTaskMainView
local CExpandTaskPart = class("CExpandTaskPart", CPageBase)

function CExpandTaskPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_ItemScrollView = self:NewUI(1, CScrollView)
	self.m_ItemTable = self:NewUI(2, CTable)
	self.m_CloneTaskBox = self:NewUI(3, CTaskBox)
	self.m_StoryTaskBox = self:NewUI(4, CBox)
	self.m_StoryTaskBox.m_NameLbl = self.m_StoryTaskBox:NewUI(1, CLabel)
	self.m_StoryTaskBox.m_IconSp = self.m_StoryTaskBox:NewUI(3, CSprite)
	self.m_StoryTaskBox.m_TaskBtn = self.m_StoryTaskBox:NewUI(4, CWidget)
	self.m_StoryTaskBox.m_Slider = self.m_StoryTaskBox:NewUI(6, CSlider)
	self.m_StoryTaskBox.m_PercentLbl = self.m_StoryTaskBox:NewUI(7, CLabel)
	self.m_StoryTaskBox.m_NameSp = self.m_StoryTaskBox:NewUI(8, CSprite)
	self.m_ItemContainer = self:NewUI(5, CWidget)
	self.m_FindOpBox = self:NewUI(6, CTaskItemFindOpBox)

	CUIParticleSystemClipper.Progress(self.m_ItemScrollView)
end

function CExpandTaskPart.OnInitPage(self)
	self.m_ItemContainer:SetActive(false)

	--暂时屏蔽
	self.m_ItemScrollView:SetCullContent(self.m_ItemTable, nil, nil, true, false)

	self.m_CloneTaskBox:SetActive(false)
	self.m_StoryTaskBox:SetParent(self.m_ItemScrollView.m_Transform)
	self.m_StoryTaskBox:SetActive(false)

	self.m_ItemScrollView.m_UIPanel.sortingOrder = -2
	self.m_BeforeIndex = 900000

	self.m_NotShowTaskNotifyEffectList = {10039}
	--想强制开启提示的taskid
	self.m_NotCheckTaskNotifyEffectList = {10001, 10002, 10003, 10004, 10005, 10006, 10007, 10008, 10009, 10010, 10011, 10037, 10012, 10013, 10014, 10015, 10016,
	10017, 10018, 10038, 10019, 10020, 10021, 10022, 10023, 10024, 10025, 10026, 10027, 10028, 10029, 10030, 10031, 10032, 10033, 10034, 10035, 10036, 10101,
	10102, 10103, 10104, 10105, 10106, 10107, 10108, 10109, 10110, 10111, 10112, 10113, 10114, 10115, 10116}
	self.m_TaskNotifyLimitGrade = 30

	self.m_AllowTaskDrag = true

	--暂时屏蔽
	local function init(obj, idx)
		local oBox = CTaskBox.New(obj)
		oBox:SetActiveLock(true)
		return oBox
	end
	self.m_ItemTable:InitChild(init)

	self.m_ItemScrollView:AddUIEvent("scrolldragstarted", callback(self, "OnDragScrollStart"))
	self.m_ItemScrollView:AddUIEvent("scrolldragfinished", callback(self, "OnDragScrollFinish"))
	self.m_StoryTaskBox.m_TaskBtn:AddUIEvent("click", callback(self, "OnClickStoryBox"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_GuideCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlGuideEvent"))

	self:RefreshGrid()
	self:OnDelayRepositionTable(1.5)
end

function CExpandTaskPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshAllTaskBox then
		-- 是否隐藏状态下
		-- 是否剧情中
		-- 是否特殊状态下
		-- return
		self:RefreshGrid()
	elseif oCtrl.m_EventID == define.Task.Event.RefreshChapterInfo then
		local function show()
			self:ShowStoryBox()
			if not self:CheckShineEffect() then
				self:OnRepositionTable()
			end
		end
		if oCtrl.m_EventData then
			self.m_StoryTaskBox:AddEffect("Shine", self.m_StoryTaskBox)

			if self.m_StoryBoxTimer then
				Utils.DelTimer(self.m_StoryBoxTimer)
				self.m_StoryBoxTimer = nil			
			end
			local function progress()
				if Utils.IsNil(self) then
					return false
				end
				show()
				return false
			end	
			self.m_StoryBoxTimer = Utils.AddTimer(progress, 0, 1)	
		else
			show()
		end	
	elseif oCtrl.m_EventID == define.Task.Event.RefreshSpecificTaskBox then --or oCtrl.m_EventID == define.Task.Event.TaskCountTime
		-- if not self:CheckShineEffect() then
		-- 	self:OnRepositionTable()
		-- end
	elseif oCtrl.m_EventID == define.Task.Event.AddTask then--or oCtrl.m_EventID == define.Task.Event.RefreshTask then
		
	elseif oCtrl.m_EventID == define.Task.Event.DelTask then
	elseif oCtrl.m_EventID == define.Task.Event.DescRefresh then
		if not self:CheckShineEffect() then
			self:OnRepositionTable()
		end
	elseif oCtrl.m_EventID == define.Task.Event.TaskRectEffect then
		local taskBoxList = self.m_ItemTable:GetChildList() or {}
		for k,v in ipairs(taskBoxList) do
			local oTaskBox = self.m_ItemTable:GetChild(k)
			if oTaskBox.m_TaskData and not g_TaskCtrl.m_TaskBoxIsMoving
			and g_TaskCtrl.m_OnlineAddTaskRectEffectList[oTaskBox.m_TaskData:GetSValueByKey("taskid")] then
				oTaskBox.m_TaskBgBtn.m_IgnoreCheckEffect = true
				oTaskBox.m_TaskBgBtn:AddEffect("TaskRect")
			else
				oTaskBox.m_TaskBgBtn:DelEffect("TaskRect")
			end
		end
	elseif oCtrl.m_EventID == define.Task.Event.TaskIntervalNotify then
		self:RefreshMainTaskNotify(g_GuideCtrl:IsGuideDone() and g_TaskCtrl.m_IsTaskNotifyClickShow)
	end
end

function CExpandTaskPart.OnCtrlGuideEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Guide.Event.State then
		self:CheckMainTaskNotifyEffect()
		self:RefreshMainTaskNotify(g_GuideCtrl:IsGuideDone() and g_TaskCtrl.m_IsTaskNotifyClickShow)
	end
end

function CExpandTaskPart.OnShowPage(self)
	--这个必须按照这个顺序执行
	self:ShowStoryBox()
	self:RefreshGrid()
end

function CExpandTaskPart.ShowStoryBox(self)
	--屏蔽章节的东西
	-- if true then
	-- 	return
	-- end

	if g_TaskCtrl.m_TaskCurChapter <= 0 then
		self.m_StoryTaskBox:SetParent(self.m_ItemScrollView.m_Transform)
		self.m_StoryTaskBox:SetActive(false)
		return
	end
	local bIsShowStoryBox = true
	local oChapterData = g_TaskCtrl:GetChapterInfoByIndex(#g_TaskCtrl:GetChapterConfig())
	if oChapterData then
		local config = g_TaskCtrl:GetChapterConfig()[#g_TaskCtrl:GetChapterConfig()]
		if table.count(oChapterData.pieces) >= config.proceeds then
			bIsShowStoryBox = false
		end
	end
	if g_TaskCtrl:GetChapterConfig()[g_TaskCtrl.m_TaskCurChapter].isshowpanel == 0 then
		bIsShowStoryBox = false
	end
	
	if bIsShowStoryBox then
		self.m_StoryTaskBox:SetParent(self.m_ItemTable.m_Transform)
		self.m_StoryTaskBox:SetActive(true)
		local oCurChapterData = g_TaskCtrl:GetChapterInfoByIndex(g_TaskCtrl.m_TaskCurChapter)
		local curConfig = g_TaskCtrl:GetChapterConfig()[g_TaskCtrl.m_TaskCurChapter]
		self.m_StoryTaskBox.m_NameLbl:SetText("[FF9600]"..curConfig.name)
		self.m_StoryTaskBox.m_Slider:SetValue(0 + table.count(oCurChapterData.pieces)/curConfig.proceeds*(1-0))
		self.m_StoryTaskBox.m_PercentLbl:SetText(math.floor(table.count(oCurChapterData.pieces)/curConfig.proceeds*100).."%")
		self.m_StoryTaskBox.m_IconSp:SetSpriteName("h7_tou_"..g_TaskCtrl.m_TaskCurChapter)
		self.m_StoryTaskBox.m_NameSp:SetSpriteName("h7_zjbiaoti_"..g_TaskCtrl.m_TaskCurChapter)
	else
		self.m_StoryTaskBox:SetParent(self.m_ItemScrollView.m_Transform)
		self.m_StoryTaskBox:SetActive(false)
	end
end

function CExpandTaskPart.RepositionTable(self)
	if not self:CheckShineEffect() then
		self:OnRepositionTable()
	end
end

function CExpandTaskPart.RefreshGrid(self)
	self.m_MainTaskBox = nil
	local taskDataList = g_TaskCtrl:GetTaskDataListWithSort() or {}
	local optionCount = #taskDataList
	local taskBoxList = self.m_ItemTable:GetChildList() or {}

	if optionCount <= 3 then
		self.m_AllowTaskDrag = false
		self.m_ItemScrollView:SetDisableDragIfFits(true)
		self.m_ItemContainer:SetActive(false)

		if optionCount == 3 then
			local oMainTask = g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.STORY.ID]
			if oMainTask and next(oMainTask) then
				local _, oMainTaskData = next(oMainTask)
				if oMainTaskData then
					local oTaskDesc = string.gettitle(CTaskHelp.GetTargetDesc(oMainTaskData), 56, "…")
					local _, oCount = string.gsub(oTaskDesc, "…", "")
					if oCount > 0 then
						self.m_AllowTaskDrag = true
						self.m_ItemScrollView:SetDisableDragIfFits(false)
						self.m_ItemContainer:SetActive(true)
					end
				end
			end
		end
	else
		self.m_AllowTaskDrag = true
		self.m_ItemScrollView:SetDisableDragIfFits(false)
		self.m_ItemContainer:SetActive(true)
	end

	local oTaskBox = nil
	self.m_BeforeIndex = 900000
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #taskBoxList then

				oTaskBox = self.m_CloneTaskBox:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				taskBoxList[i].m_TaskBgBtn:DelEffect("TaskRect")
				taskBoxList[i].m_TaskBgBtn:DelEffect("Shine")
				if not table.index(self.m_NotCheckTaskNotifyEffectList, taskDataList[i]:GetSValueByKey("taskid")) then
					taskBoxList[i].m_TaskBgBtn:DelEffect("FingerInterval")
				end
				oTaskBox = taskBoxList[i]
			end
			oTaskBox:SetActiveLock(false)
			self:SetMainTaskBox(oTaskBox, taskDataList[i], self.m_AllowTaskDrag)
		end

		if #taskBoxList > optionCount then
			for i=optionCount+1, #taskBoxList do
				taskBoxList[i].m_TargetDesc = nil
				taskBoxList[i]:SetActiveLock(true)
				taskBoxList[i]:SetActive(false)				
				-- oTaskBox.m_CullCallBack = nil
			end
		end
	else
		if taskBoxList and #taskBoxList > 0 then
			for _,v in ipairs(taskBoxList) do
				v.m_TargetDesc = nil
				v:SetActiveLock(true)
				v:SetActive(false)				
			end
		end
	end

	self:CheckMainTaskNotifyEffect()

	-- local function delay()
	-- 	if Utils.IsNil(self) then
	-- 		return false
	-- 	end
		
	-- 	return false
	-- end
	-- Utils.AddTimer(delay, 0, 1)

	if not self:CheckShineEffect() then
		self:OnRepositionTable()
	end
	
	g_GuideCtrl:OnTriggerAll()
	self.m_ItemScrollView:CullContentLater()
end

function CExpandTaskPart.SetMainTaskBox(self, oTaskBox, oTaskData, bAllowDrag)
	oTaskBox:SetActive(true)
	local oDragCom = oTaskBox.m_TaskBgBtn:GetComponent(classtype.UIDragScrollView)
	if bAllowDrag then
		oDragCom.enabled = true
	else
		oDragCom.enabled = false
	end
	--副本第一位
	-- if table.index({define.Task.TaskCategory.FUBEN.ID, define.Task.TaskCategory.JYFUBEN.ID, define.Task.TaskCategory.GUESSGAME.ID}, oTaskData:GetCValueByKey("type")) then
	-- 	oTaskBox:SetName(tostring(0))
	-- else
	oTaskBox:SetName(tostring(self.m_BeforeIndex))
	self.m_BeforeIndex = self.m_BeforeIndex + 1
	-- end
	oTaskBox:SetTaskBox(oTaskData)
	oTaskBox.m_Transform.localPosition = Vector3.New(0, oTaskBox.m_Transform.localPosition.y, oTaskBox.m_Transform.localPosition.z)
	-- g_GuideCtrl:AddGuideUI("task_btn_"..oTaskData:GetSValueByKey("taskid"), oTaskBox.m_TaskBgBtn)
	if oTaskData:GetCValueByKey("type") == define.Task.TaskCategory.SHIMEN.ID then
		g_GuideCtrl:AddGuideUI("task_shimen_btn", oTaskBox.m_TaskBgBtn)
	end
	if oTaskData:GetCValueByKey("type") == define.Task.TaskCategory.STORY.ID then
		self.m_MainTaskBox = oTaskBox
		self.m_MainTaskBox.m_TaskBgBtn.m_IgnoreCheckEffect = true
	end

	self.m_ItemTable:AddChild(oTaskBox)
end

function CExpandTaskPart.CheckMainTaskNotifyEffect(self)
	if not self.m_MainTaskBox or not self.m_MainTaskBox.m_TaskData then
		return
	end	
	if g_AttrCtrl.grade > self.m_TaskNotifyLimitGrade then
		return
	end
	local oTaskId = self.m_MainTaskBox.m_TaskData:GetSValueByKey("taskid")
	if table.index(self.m_NotShowTaskNotifyEffectList, oTaskId) then
		return
	end
	if not table.index(self.m_NotCheckTaskNotifyEffectList, oTaskId) and not g_GuideCtrl.m_TaskNotifyExecute then
		return
	end
	if not g_TaskCtrl.m_TaskNotifyRecordData[oTaskId] then
		self.m_MainTaskBox.m_TaskBgBtn.m_IgnoreCheckEffect = true
		self.m_MainTaskBox.m_TaskBgBtn:DelEffect("FingerInterval")
		self.m_MainTaskBox.m_TaskBgBtn:AddEffect("FingerInterval", nil, Vector3.New(3, -7, 0))
		g_TaskCtrl.m_TaskNotifyRecordData[oTaskId] = true
	end
	g_GuideCtrl.m_TaskNotifyExecute = false
end

function CExpandTaskPart.RefreshMainTaskNotify(self, bActive)
	if not self.m_MainTaskBox or not self.m_MainTaskBox.m_TaskData then
		return
	end
	if self.m_MainTaskBox.m_TaskBgBtn.m_Effects["FingerInterval"] then
		self.m_MainTaskBox.m_TaskBgBtn.m_Effects["FingerInterval"]:SetActive(bActive)
	end
end

function CExpandTaskPart.CheckShineEffect(self)
	local taskBoxList = self.m_ItemTable:GetChildList() or {}
	for k,v in pairs(taskBoxList) do
		if v.m_TaskBgBtn.m_Effects["Shine"] then
			return true
		end
	end
	return false
end

function CExpandTaskPart.OnClickStoryBox(self)
	CTaskMainView:ShowView(function (oView)
		-- oView.m_StoryPart:SetShowChapterIndex(chapterinfo.chapter)
		oView.m_StoryPart.m_DefaultChapter = g_TaskCtrl:GetShowIndex()
		oView:ShowSpecificPart(3)
		oView:OnShowPieceView()
	end)
end

function CExpandTaskPart.OnDragScrollStart(self)
	local taskBoxList = self.m_ItemTable:GetChildList() or {}
	for k,v in pairs(taskBoxList) do
		if v.m_TaskBgBtn.m_Effects["TaskRect"] then
			v.m_TaskBgBtn.m_Effects["TaskRect"]:SetActive(false)			
		end
	end
end

function CExpandTaskPart.OnDragScrollFinish(self)
	local taskBoxList = self.m_ItemTable:GetChildList() or {}
	for k,v in pairs(taskBoxList) do
		if v.m_TaskBgBtn.m_Effects["TaskRect"] then
			v.m_TaskBgBtn.m_Effects["TaskRect"]:SetActive(true)
			-- v.m_TaskBgBtn.m_Effects["TaskRect"]:ResetMove()
		end
	end
end

--重置table位置
function CExpandTaskPart.OnRepositionTable(self)
	self.m_ItemTable:Reposition()
	--暂时屏蔽
	-- for i,oBox in ipairs(self.m_ItemTable:GetChildList()) do
	-- 	oBox.m_Transform.localPosition = Vector3.New(0, oBox.m_Transform.localPosition.y, oBox.m_Transform.localPosition.z)
	-- end
	--暂时屏蔽
	self.m_ItemScrollView:CullContentLater()
	if table.count(g_TaskCtrl:GetTaskDataListWithSort() or {}) <= 3 then
		self.m_ItemScrollView:ResetPosition()
	end
end

function CExpandTaskPart.OnDelayRepositionTable(self, oTime)
	-- if self.m_RepositionTimer then
	-- 	Utils.DelTimer(self.m_RepositionTimer)
	-- 	self.m_RepositionTimer = nil			
	-- end
	local function progress()
		if Utils.IsNil(self) then
			return false
		end
		if not self:CheckShineEffect() then
			self:OnRepositionTable()
		end
		return false
	end	
	-- self.m_RepositionTimer = Utils.AddTimer(progress, 0, oTime)
	Utils.AddTimer(progress, 0, oTime)
end

function CExpandTaskPart.SetActive(self, b)
	CObject.SetActive(self, b)
	self:CullContent()
end

function CExpandTaskPart.CullContent(self)
	if self.m_ItemScrollView and self:GetActive() then
		self.m_ItemScrollView:CullContentLater()
	end
end

return CExpandTaskPart
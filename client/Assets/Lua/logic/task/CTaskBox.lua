local CTaskBox = class("CTaskBox", CBox)

function CTaskBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_TypeLabel = self:NewUI(1, CLabel)
	self.m_DesLabel = self:NewUI(2, CLabel)
	self.m_MarkSprite = self:NewUI(3, CSprite)
	self.m_TaskBgBtn = self:NewUI(4, CWidget)
	self.m_TaskReward = self:NewUI(5, CSprite)
	self.m_BgSp = self:NewUI(6, CSprite)

	self.m_Callback = cb
	self:ResetStatus()

	-- -253 -30 0   -180 -30 0
	self.m_TaskReward:SetActive(false)
	self.m_TaskReward:SetLocalPos(Vector3.New(-180, -30, 0))
	self.m_TimeColor = "#R"

	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	-- self.m_BgSprite:AddUIEvent("repeatpress", callback(self, "OnPressTaskBox"))
	self.m_TaskBgBtn:AddUIEvent("click", callback(self, "OnTaskBox"))
	self.m_TaskReward:AddUIEvent("click", callback(self, "OnRewardBtn"))
end

--初始化执行
function CTaskBox.ResetStatus(self)
	self.m_TaskData = nil

	self.m_TypeText = ""
	self.m_TargetText = ""
	self.m_MarkFinish = false
	self.m_Effect = nil
	self.m_ItemPre = nil

	self:RefreshTaskBox()
end

--任务协议返回通知
function CTaskBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshSpecificTaskBox then
		if self.m_TaskData and oCtrl.m_EventData then
			local localTaskID = self.m_TaskData:GetSValueByKey("taskid")
			if localTaskID == oCtrl.m_EventData then
				local oTask = g_TaskCtrl:GetSpecityTask(oCtrl.m_EventData)
				if oTask then
					self:SetTaskBox(oTask)
				end
			end
		end
	elseif oCtrl.m_EventID == define.Task.Event.TaskCountTime then
		if self.m_TaskData and self.m_TaskData:GetSValueByKey("taskid") == oCtrl.m_EventData then
			if g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] > 0 then			
				local targetDes = CTaskHelp.GetTargetDesc(self.m_TaskData)
				if g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] > 0 then
					targetDes = targetDes.."\n剩余传说时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData])
				end
				targetDes = targetDes.."\n剩余时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData])
				self.m_DesLabel:SetRichText(targetDes, nil, nil, true)
			else
				local targetDes = CTaskHelp.GetTargetDesc(self.m_TaskData)
				if g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] > 0 then
					targetDes = targetDes.."\n剩余传说时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData])
				end
				if self.m_TaskData:GetSValueByKey("time") and self.m_TaskData:GetSValueByKey("time") > 0 then
					targetDes = targetDes.."\n剩余时间:#R00:01#n"
				end
				self.m_DesLabel:SetRichText(targetDes, nil, nil, true)
			end
			local oEmoji = self.m_DesLabel:Find("[emoticon]")
			local oEmojiWidget
			if oEmoji then
				oEmojiWidget = CWidget.New(oEmoji)
				oEmojiWidget:ResetAndUpdateAnchors()
			end
			self.m_BgSp:ResetAndUpdateAnchors()
			self.m_TaskBgBtn:ResetAndUpdateAnchors()
			-- g_TaskCtrl:OnEvent(define.Task.Event.DescRefresh)
		end
	elseif oCtrl.m_EventID == define.Task.Event.TaskLegendCountTime then
		if self.m_TaskData and self.m_TaskData:GetSValueByKey("taskid") == oCtrl.m_EventData then
			if g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] > 0 then			
				local targetDes = CTaskHelp.GetTargetDesc(self.m_TaskData)
				targetDes = targetDes.."\n剩余传说时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData])
				if g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] > 0 then
					targetDes = targetDes.."\n剩余时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData])
				end
				self.m_DesLabel:SetRichText(targetDes, nil, nil, true)
			else
				local oLeftTime = self.m_TaskData:GetLegendTime()
				local targetDes = CTaskHelp.GetTargetDesc(self.m_TaskData)
				if oLeftTime and oLeftTime > 0 then
					targetDes = targetDes.."\n剩余传说时间:#R00:01#n"
				end
				if g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] > 0 then
					targetDes = targetDes.."\n剩余时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData])
				end
				self.m_DesLabel:SetRichText(targetDes, nil, nil, true)
			end
			local oEmoji = self.m_DesLabel:Find("[emoticon]")
			local oEmojiWidget
			if oEmoji then
				oEmojiWidget = CWidget.New(oEmoji)
				oEmojiWidget:ResetAndUpdateAnchors()
			end
			self.m_BgSp:ResetAndUpdateAnchors()
			self.m_TaskBgBtn:ResetAndUpdateAnchors()
			-- g_TaskCtrl:OnEvent(define.Task.Event.DescRefresh)
		end
	-- elseif oCtrl.m_EventID == define.Task.Event.AddTask then
	-- 	if self.m_TaskData and self.m_TaskData:GetSValueByKey("taskid") == oCtrl.m_EventData:GetSValueByKey("taskid") and self.m_TaskData:IsTaskSpecityCategory(define.Task.TaskCategory.STORY) 
	-- 	and g_TaskCtrl.m_AddTaskShineEffectList[self.m_TaskData:GetSValueByKey("taskid")] then
	-- 		self.m_TaskBgBtn:AddEffect("Shine")
	-- 		g_TaskCtrl.m_AddTaskShineEffectList[self.m_TaskData:GetSValueByKey("taskid")] = nil
	-- 	end
	end
end

------------以下是ui相关--------------

function CTaskBox.SetTaskBox(self, oTask)
	self.m_TaskData = oTask
	if oTask then
		self.m_TypeText = CTaskHelp.GetTaskTitleDesc(oTask)
		self.m_MarkFinish = oTask.m_Finish
		self.m_ItemPre = oTask:GetTaskItemPre()
	end
	self:RefreshTaskBox()
end

function CTaskBox.RefreshTaskBox(self)
	if self.m_TaskData and self.m_TaskData:GetCValueByKey("type") == define.Task.TaskCategory.STORY.ID then
		if self.m_EffectDelayTimer then
			Utils.DelTimer(self.m_EffectDelayTimer)
			self.m_EffectDelayTimer = nil			
		end
		local function effectdelay()
			if Utils.IsNil(self) then
				return false
			end
			if g_TaskCtrl.m_AddTaskShineEffectList[self.m_TaskData:GetSValueByKey("taskid")] then
				self.m_TaskBgBtn.m_IgnoreCheckEffect = true
				self.m_TaskBgBtn:AddEffect("Shine", self.m_TaskBgBtn)
				g_TaskCtrl.m_AddTaskShineEffectList[self.m_TaskData:GetSValueByKey("taskid")] = nil
			end
			return false
		end
		self.m_EffectDelayTimer = Utils.AddTimer(effectdelay, 0, 0.3)

		if self.m_DelayTimer then
			Utils.DelTimer(self.m_DelayTimer)
			self.m_DelayTimer = nil			
		end
		local function delay()
			if Utils.IsNil(self) then
				return false
			end
			self:SetTaskBoxUIContent()
			
			return false
		end
		self.m_DelayTimer = Utils.AddTimer(delay, 0, 0.5)
	elseif self.m_TaskData then
		self:SetTaskBoxUIContent()
	end
	self:SetHeight(self.m_BgSp:GetHeight())
end

function CTaskBox.SetTaskBoxUIContent(self)
	self.m_TypeLabel:SetRichText(self.m_TypeText, nil, nil, true)
	
	local targetDes = CTaskHelp.GetTargetDesc(self.m_TaskData)
	--灵犀飘字提示
	if g_LingxiCtrl.m_IsFloatDesc and self.m_TaskData:GetSValueByKey("taskid") == g_LingxiCtrl:GetLingxiTaskId() then
		if not self.m_TargetDesc then
			self.m_TargetDesc = targetDes
		else
			if self.m_TargetDesc ~= targetDes then
				if self.m_TaskData:GetSValueByKey("taskid") == g_LingxiCtrl:GetLingxiTaskId() then
					if not (g_LingxiCtrl.m_Phase == 4 and not g_LingxiCtrl.m_TotalCnt) then
						g_NotifyCtrl:FloatMsg(targetDes)
					end
				end
				self.m_TargetDesc = targetDes
			end
		end
		g_LingxiCtrl.m_IsFloatDesc = false
	end
	if g_TaskCtrl.m_LegendLeftTimeList[self.m_TaskData:GetSValueByKey("taskid")] and g_TaskCtrl.m_LegendLeftTimeList[self.m_TaskData:GetSValueByKey("taskid")] > 0 then
		targetDes = targetDes.."\n剩余传说时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_LegendLeftTimeList[self.m_TaskData:GetSValueByKey("taskid")]).."#n"--os.date("#R%M:%S#n", g_TaskCtrl.m_LegendLeftTimeList[self.m_TaskData:GetSValueByKey("taskid")])
	end
	if g_TaskCtrl.m_CurLeftTimeList[self.m_TaskData:GetSValueByKey("taskid")] and g_TaskCtrl.m_CurLeftTimeList[self.m_TaskData:GetSValueByKey("taskid")] > 0 then
		targetDes = targetDes.."\n剩余时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_CurLeftTimeList[self.m_TaskData:GetSValueByKey("taskid")]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_CurLeftTimeList[self.m_TaskData:GetSValueByKey("taskid")])
	end
	self.m_DesLabel:SetRichText(targetDes, nil, nil, true)
	local oEmoji = self.m_DesLabel:Find("[emoticon]")
	local oEmojiWidget
	if oEmoji then
		oEmojiWidget = CWidget.New(oEmoji)
		oEmojiWidget:ResetAndUpdateAnchors()
	end
	self.m_BgSp:ResetAndUpdateAnchors()
	self.m_TaskBgBtn:ResetAndUpdateAnchors()

	self:SetHeight(self.m_BgSp:GetHeight())
	
	if self.m_TaskData:GetSValueByKey("taskid") == g_LingxiCtrl:GetLingxiTaskId() or self.m_TaskData:GetCValueByKey("type") == define.Task.TaskCategory.STORY.ID then
		g_TaskCtrl:OnEvent(define.Task.Event.DescRefresh)
	end

	local markName, localpos = self:GetMarkSprName()
	local showMark = markName ~= ""
	self.m_MarkSprite:SetActive(showMark)
	if showMark then
		self.m_MarkSprite:SetSpriteName(markName)
		-- self.m_MarkSprite:MakePixelPerfect()
		-- self.m_MarkSprite:SetLocalPos(localpos)
	end
	local showItemPre = self.m_ItemPre ~= nil
	self.m_TaskReward:SetActive(showItemPre)
	if showItemPre then
		local itemInfo = DataTools.GetItemData(tonumber(self.m_ItemPre))
		self.m_TaskReward:SpriteItemShape(itemInfo.icon)
		self.m_TaskReward:SetLocalPos(Vector3.New(-253, -30, 0))
	else
		self.m_TaskReward:SetLocalPos(Vector3.New(-180, -30, 0))
	end

	self:SetEffect()
end

function CTaskBox.GetMarkSprName(self, done)
	if self.m_TaskData then
		local name = ""
		local localpos
		local sprNames = {"h7_zhanlitubiao", "h7_wanchengtubiao"}
		local posVet = {Vector3.New(92, 28, 0), Vector3.New(92, 28, 0)}
		local taskType = self.m_TaskData:GetSValueByKey("tasktype")
		done = done or self.m_MarkFinish

		if done then
			if taskType ~= define.Task.TaskType.TASK_FIND_NPC then
				name = sprNames[2]
				localpos = posVet[2]
			end
		else
			if taskType == define.Task.TaskType.TASK_NPC_FIGHT then
				name = sprNames[1]
				localpos = posVet[1]
			end
		end

		return name, localpos
	end
end

function CTaskBox.SetEffect(self)
	--根据配置表来是否显示环绕特效
	-- printc("CTaskBox.SetEffect", g_WarCtrl:IsWar(), ",", g_TaskCtrl.m_TaskBoxIsMoving)
	if self.m_TaskData and not g_TaskCtrl.m_TaskBoxIsMoving
	and g_TaskCtrl.m_OnlineAddTaskRectEffectList[self.m_TaskData:GetSValueByKey("taskid")] then
		self.m_TaskBgBtn.m_IgnoreCheckEffect = true
		self.m_TaskBgBtn:AddEffect("TaskRect")
	else
		self.m_TaskBgBtn:DelEffect("TaskRect")
	end

	do return end
	local shimen = g_TaskCtrl.m_RecordLogic.shimenEff and self.m_TaskData and self.m_TaskData:IsTaskSpecityCategory(define.Task.TaskCategory.SHIMEN)
	if shimen then
		g_TaskCtrl.m_RecordLogic.shimenEff = false
	end
	local show = shimen
	if show then
		if not self.m_Effect then
			self.m_Effect = true
			self.m_TaskBgBtn.m_IgnoreCheckEffect = false
			self.m_TaskBgBtn:AddEffect("TaskRect")
		end
	elseif self.m_Effect then
		self.m_Effect = false
		-- printc("CTaskBox.SetEffect DelEffect Rect")
		self.m_TaskBgBtn:DelEffect("TaskRect")
	end
end

-- function CTaskBox.OnPressTaskBox(self, oObj, bPress)
-- 	if bPress then

-- 	end
-- end

--------------以下是点击事件--------------

function CTaskBox.OnTaskBox(self, oBtn)
	print(string.format("<color=#00FF00> >>> .%s | 表数据查看 | %s </color>", "OnTaskBox", "任务导航TaskBox数据输出", "self.m_TaskData"))
	table.print(self.m_TaskData)

	g_TaskCtrl.m_ExtendTaskWidget = self.m_TaskBgBtn
	g_TaskCtrl.m_OnlineAddTaskRectEffectList[self.m_TaskData:GetSValueByKey("taskid")] = false
	self.m_TaskBgBtn:DelEffect("TaskRect")

	CTaskHelp.ClickTaskLogic(self.m_TaskData)
	if self.m_Callback then
		self.m_Callback()
	end
end

function CTaskBox.OnRewardBtn(self)
	if self.m_ItemPre then
		g_WindowTipCtrl:SetWindowItemTip(tonumber(self.m_ItemPre), {widget = self.m_TaskReward})
	end
end

return CTaskBox
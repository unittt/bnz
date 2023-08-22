local CTaskMainCurPart = class("CTaskMainCurPart", CPageBase)

function CTaskMainCurPart.ctor(self, obj)
	CPageBase.ctor(self, obj)

	self.m_TimeColor = "#R"
end

function CTaskMainCurPart.OnInitPage(self)
	self.m_TaskData = nil
	self.m_RewardList = nil
	self:SetActive(false)

	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_TargetLabel = self:NewUI(2, CLabel)
	self.m_DesLabel = self:NewUI(3, CLabel)
	self.m_RewardContent = self:NewUI(4, CObject)
	self.m_RewardGrid = self:NewUI(5, CGrid)
	self.m_RewardItemClone = self:NewUI(6, CBox)
	self.m_AbandonBtn = self:NewUI(7, CButton)
	self.m_ConveyBtn = self:NewUI(8, CButton)

	self.m_RewardItemClone:SetActive(false)
	self.m_AbandonBtn:AddUIEvent("click", callback(self, "OnClickAbandon"))
	self.m_ConveyBtn:AddUIEvent("click", callback(self, "OnClickConvey"))

	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CTaskMainCurPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.TaskCountTime then
		if self.m_TaskData and self.m_TaskData:GetSValueByKey("taskid") == oCtrl.m_EventData then
			if g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] > 0 then			
				local target = string.gsub(CTaskHelp.GetTargetDesc(self.m_TaskData), "ccebdb", "63432c") --string.format("[63432c]%s", self.m_TaskData:GetSValueByKey("targetdesc"))
				if g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] > 0 then
					target = target.."\n剩余传说时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData])
				end
				target = target.."\n剩余时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData])
				self.m_TargetLabel:SetText(target)
			else
				local target = string.gsub(CTaskHelp.GetTargetDesc(self.m_TaskData), "ccebdb", "63432c")--string.format("[63432c]%s", self.m_TaskData:GetSValueByKey("targetdesc"))		
				if g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] > 0 then
					target = target.."\n剩余传说时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData])
				end
				if self.m_TaskData:GetSValueByKey("time") and self.m_TaskData:GetSValueByKey("time") > 0 then
					target = target.."\n剩余时间:#R00:01#n"
				end
				self.m_TargetLabel:SetText(target)
			end
		end
	elseif oCtrl.m_EventID == define.Task.Event.TaskLegendCountTime then
		if self.m_TaskData and self.m_TaskData:GetSValueByKey("taskid") == oCtrl.m_EventData then
			if g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData] > 0 then
				local target = string.gsub(CTaskHelp.GetTargetDesc(self.m_TaskData), "ccebdb", "63432c") --string.format("[63432c]%s", self.m_TaskData:GetSValueByKey("targetdesc"))
				target = target.."\n剩余传说时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_LegendLeftTimeList[oCtrl.m_EventData])
				if g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] > 0 then
					target = target.."\n剩余时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData])
				end
				self.m_TargetLabel:SetText(target)
			else
				local oLeftTime = self.m_TaskData:GetLegendTime()
				local target = string.gsub(CTaskHelp.GetTargetDesc(self.m_TaskData), "ccebdb", "63432c")--string.format("[63432c]%s", self.m_TaskData:GetSValueByKey("targetdesc"))		
				if oLeftTime and oLeftTime > 0 then
					target = target.."\n剩余传说时间:#R00:01#n"
				end
				if g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] and g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData] > 0 then
					target = target.."\n剩余时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_CurLeftTimeList[oCtrl.m_EventData])
				end
				self.m_TargetLabel:SetText(target)
			end
		end
	end
end

function CTaskMainCurPart.OnClickAbandon(self)
	if self.m_TaskData:IsAbandon() then
		-- 特殊，抓鬼队员无法放弃
		if self.m_TaskData:IsTaskSpecityCategory(define.Task.TaskCategory.GHOST) then
			if g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeader(g_AttrCtrl.m_Pid) and g_TeamCtrl:IsInTeam(g_AttrCtrl.m_Pid) then
				g_NotifyCtrl:FloatMsg("金刚伏魔任务只有队长才能放弃")
				return
			end
		end

		local windowConfirmInfo = {
			msg				= "您真的要放弃任务吗？",
			title			= "提示",
			okCallback = function ()
				local taskid = self.m_TaskData:GetSValueByKey("taskid")
				nettask.C2GSAbandonTask(taskid)
			end,
			pivot = enum.UIWidget.Pivot.Center,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
			self.m_WinTipViwe = oView
		end)
	else
		local oTaskStr = string.gsub("无法放弃" .. self.m_TaskData.m_TaskType.name .. "任务", "任务", "", 1)
		g_NotifyCtrl:FloatMsg(oTaskStr)
	end
end

function CTaskMainCurPart.OnClickConvey(self, oCtrl)
	CTaskHelp.ClickTaskLogic(self.m_TaskData)
	self.m_ParentView:CloseView()
end

function CTaskMainCurPart.SetTaskInfo(self, oTask)
	self.m_TaskData = oTask
	self:SetActive(true)

	-- local title = string.format("[5E2E10]%s-%s", oTask.m_TaskType.name, oTask:GetSValueByKey("name"))
	local title = string.format("%s-%s", oTask.m_TaskType.name, oTask:GetSValueByKey("name"))
	self.m_TitleLabel:SetText(title)
	local target = string.gsub(CTaskHelp.GetTargetDesc(self.m_TaskData), "ccebdb", "63432c")--string.format("[63432c]%s", oTask:GetSValueByKey("targetdesc"))
	self.m_TargetLabel:SetText(target)
	local describe = string.format("[63432c]%s", oTask:GetSValueByKey("detaildesc"))
	self.m_DesLabel:SetText(describe)

	self:RefreshTaskTarget(oTask)

	local rewardList = CTaskHelp.GetTaskRewardList(oTask)
	self.m_RewardList = rewardList
	local showReward = rewardList and #rewardList > 0
	self.m_RewardGrid:SetActive(showReward)
	-- print(string.format("<color=#00FF00> >>> .%s | %s | Table:%s </color>", "SetTaskInfo", "奖励列表", "rewardList"))
	-- table.print(rewardList)
	local rewardGridList = self.m_RewardGrid:GetChildList()
	local groupID = self.m_RewardGrid:GetInstanceID()
	for i,v in ipairs(rewardList) do
		if v.type == 1 then
			local oRewardBox = nil
			if i > #rewardGridList then
				oRewardBox = self.m_RewardItemClone:Clone()
				oRewardBox.m_Icon = oRewardBox:NewUI(1, CSprite)
				oRewardBox.m_Quality = oRewardBox:NewUI(2, CSprite)
				oRewardBox:SetGroup(groupID)
				self.m_RewardGrid:AddChild(oRewardBox)				
			else
				oRewardBox = rewardGridList[i]
			end
			oRewardBox:AddUIEvent("click", callback(self, "OnClickPrizeBox", v.item, oRewardBox))
			oRewardBox.m_Icon:SpriteItemShape(v.item.icon)
			oRewardBox.m_Quality:SetItemQuality(g_ItemCtrl:GetQualityVal( v.item.id, v.item.quality or 0 ))
			oRewardBox:SetActive(true)
		end
	end

	for i=#rewardList+1,#rewardGridList do
		rewardGridList[i]:SetActive(false)
	end
end

function CTaskMainCurPart.RefreshTaskTarget(self, oTask)
	if g_TaskCtrl.m_CurLeftTimeList[oTask:GetSValueByKey("taskid")] and g_TaskCtrl.m_CurLeftTimeList[oTask:GetSValueByKey("taskid")] > 0 then
		local target = string.gsub(CTaskHelp.GetTargetDesc(oTask), "ccebdb", "63432c")--string.format("[63432c]%s", oTask:GetSValueByKey("targetdesc"))
		if g_TaskCtrl.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")] and g_TaskCtrl.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")] > 0 then
			target = target.."\n剩余传说时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")])
		end
		target = target.."\n剩余时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_CurLeftTimeList[oTask:GetSValueByKey("taskid")]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_CurLeftTimeList[oTask:GetSValueByKey("taskid")])
		self.m_TargetLabel:SetText(target)
	else
		local target = string.gsub(CTaskHelp.GetTargetDesc(oTask), "ccebdb", "63432c")--string.format("[63432c]%s", oTask:GetSValueByKey("targetdesc"))
		if g_TaskCtrl.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")] and g_TaskCtrl.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")] > 0 then
			target = target.."\n剩余传说时间:"..self.m_TimeColor..g_TimeCtrl:GetLeftTime(g_TaskCtrl.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")]).."#n" --os.date("#R%M:%S#n", g_TaskCtrl.m_LegendLeftTimeList[oTask:GetSValueByKey("taskid")])
		end
		self.m_TargetLabel:SetText(target)
	end
end

function CTaskMainCurPart.OnClickPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

return CTaskMainCurPart
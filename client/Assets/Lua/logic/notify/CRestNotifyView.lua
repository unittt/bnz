local CRestNotifyView = class("CRestNotifyView", CViewBase)

function CRestNotifyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/RestNotifyView.prefab", cb)
	--界面设置
	self.m_DepthType = "Story"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"
end

function CRestNotifyView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_BoxClone = self:NewUI(4, CScheduleBox)
	self.m_SysBtn = self:NewUI(5, CButton)
	
	self:InitContent()
end

function CRestNotifyView.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_SysBtn:AddUIEvent("click", callback(self, "OnClickSys"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	-- g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	self:SetActivityList()
end

function CRestNotifyView.SetActivityList(self)
	local optionCount = #g_ScheduleCtrl.m_StopNotifyActualList
	local GridList = self.m_Grid:GetChildList() or {}
	local oActivityBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oActivityBox = self.m_BoxClone:Clone(function(scheduleInfo, showDetail)
					if scheduleInfo then
						if showDetail then
							CScheduleInfoView:ShowView(function(oView)
								oView.m_IsCouldClickClose = true
								oView:SetScheduleInfo(scheduleInfo)
								oView.m_DepthType = "BeyondGuide"
								g_ViewCtrl:TopView(oView)
							end)
						end
						g_ScheduleCtrl:CheckScheduleRecordEff(scheduleInfo)
					end
				end, function () self:CloseView() end)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oActivityBox = GridList[i]
			end
			self:SetActivityBox(oActivityBox, g_ScheduleCtrl.m_StopNotifyActualList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CRestNotifyView.SetActivityBox(self, oActivityBox, oData)	
	local oActualData
	local scheduleType = define.Schedule.Type.Every
	if g_ScheduleCtrl.m_StopNotifyEveryDataList[oData] then
		oActualData = g_ScheduleCtrl.m_StopNotifyEveryDataList[oData]
		scheduleType = define.Schedule.Type.Every
	elseif g_ScheduleCtrl.m_StopNotifyLimitDataList[oData] then
		oActualData = g_ScheduleCtrl.m_StopNotifyLimitDataList[oData]
		scheduleType = define.Schedule.Type.Limit
	end
	if not oActualData then
		printerror("贴心管家的数据发生错误")
		return
	end
	oActivityBox:SetActive(true)
	oActivityBox:SetScheduleBox(oActualData, scheduleType)
	oActivityBox.m_RedPoint:SetActive(false)
	oActivityBox.m_BoxBtn:DelEffect("Rect")

	self.m_Grid:AddChild(oActivityBox)
	self.m_Grid:Reposition()
end

function CRestNotifyView.OnClickSys(self)
	CSystemSettingsMainView:ShowView()
end

return CRestNotifyView
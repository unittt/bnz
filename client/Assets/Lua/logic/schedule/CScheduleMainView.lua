local CScheduleMainView = class("CScheduleMainView", CViewBase)

function CScheduleMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Schedule/ScheduleMainView.prefab", cb)
	self.m_GroupName = "main"
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CScheduleMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScheduleTabGrid = self:NewUI(2, CGrid)
	self.m_ScheduleScrollView = self:NewUI(3, CScrollView)
	self.m_ScheduleGrid = self:NewUI(4, CGrid)
	self.m_ScheduleBoxClone = self:NewUI(5, CScheduleBox)
	self.m_LimitGrid = self:NewUI(6, CGrid)
	self.m_LimitBoxClone = self:NewUI(7, CSchedulePreviewBox)
	self.m_RewardBoxGrid = self:NewUI(8, CGrid)
	self.m_RewardBoxClone = self:NewUI(9, CScheduleRewardBox)
	self.m_ActiveSlider = self:NewUI(10, CSlider)
	self.m_ActivePoint = self:NewUI(11, CLabel)
	self.m_CalendarBtn = self:NewUI(12, CButton)
	self.m_HintInfoBtn = self:NewUI(13, CButton)
	self.m_ScheduleWeekBox = self:NewUI(14, CScheduleWeekBox)
	self.m_ScheduleTipBox = self:NewUI(15, CScheduleHintTipBox)
	self.m_NilSchduleNode = self:NewUI(16, CObject)
	self.m_DoublePointBox = self:NewUI(17, CBox)
	self.m_DoublePointBox.m_Current = self.m_DoublePointBox:NewUI(1, CLabel)
	self.m_DoublePointBox.m_Remainder = self.m_DoublePointBox:NewUI(2, CLabel)
	self.m_DoublePointBox.m_DoublePointBtn = self.m_DoublePointBox:NewUI(3, CButton)

	self.m_DayTaskScrollView = self:NewUI(18, CScrollView)
	self.m_DayTaskGrid = self:NewUI(19, CGrid)
	self.m_DayTaskClone = self:NewUI(20, CBox)
	self.m_PushSettingsBtn = self:NewUI(21, CButton)
	self.m_CoverSpr = self:NewUI(22, CSprite)
	self.m_BaseContent = self:NewUI(23, CBox)
	self.m_RarityPetDebris = self:NewUI(24, CBox)
	self.m_RarityPetTipBox = self:NewUI(25, CBox)
	self.m_PushObj = self:NewUI(26, CObject)

	self.m_MainContent = self:NewUI(27, CObject)

	self.m_RarityPetDebris.icon = self.m_RarityPetDebris:NewUI(1, CSprite)
	self.m_DayTaskClone:SetActive(false)
	
	self:SetUIAndEvent()
	self:InitContent()
end

function CScheduleMainView.InitContent(self)
	self:InitLimitGrid()
	self:InitMainViewTabGrid()
	self:ShowMainViewTabBtn()
	self:InitRewardGrid()
	self:RefreshActiveSlider()
	--self:SetUnopenTabBtnActive()
	self:RefreshDoubleInfo()
	self:SetEachDayTaskList()
end

-- 设置UI、事件
function CScheduleMainView.SetUIAndEvent(self)
	if Utils.IsIOS() then
        self.m_PushObj:SetActive(false)
    end
	self.m_ScheduleBoxClone:SetActive(false)
	self.m_LimitBoxClone:SetActive(false)
	self.m_RewardBoxClone:SetActive(false)
	self.m_ScheduleWeekBox:SetActive(false)
	self.m_ScheduleTipBox:SetActive(false)
	self.m_NilSchduleNode:SetActive(false)
	self.m_PushSettingsBtn:SetActive(false)

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self, "OnCAttrCtrlEvent"))
	g_ScheduleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnScheduleCtrlEvent"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CalendarBtn:AddUIEvent("click", callback(self, "OnWeekSchedule"))
	self.m_PushSettingsBtn:AddUIEvent("click", callback(self, "OnPushSetting"))
	self.m_HintInfoBtn:AddUIEvent("click", callback(self, "OnSetHintInfo"))
	self.m_DoublePointBox.m_DoublePointBtn:AddUIEvent("click", callback(self, "OnDoublePoint"))
end

function CScheduleMainView.OnCAttrCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change and oCtrl.m_EventData then
		if oCtrl.m_EventData.dAttr.activepoint then
			self:RefreshActiveSlider()
		elseif oCtrl.m_EventData.dAttr.grade ~= oCtrl.m_EventData.dPreAttr.grade then
			self:ShowMainViewTabBtn()
			self:InitLimitGrid()
			self:RefreshScheduleBoxList()
		end
	end
end

function CScheduleMainView.OnScheduleCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Schedule.Event.RefreshMainUI then
		self:InitContent()
	elseif oCtrl.m_EventID == define.Schedule.Event.RefreshSchedule then
		self:RefreshSpecityScheduleBox(oCtrl.m_EventData)
		self:RefreshActiveSlider()
	elseif oCtrl.m_EventID == define.Schedule.Event.RefreshWeek then
		self.m_ScheduleWeekBox:SetScheduleWeekBox()
	elseif oCtrl.m_EventID == define.Schedule.Event.RefreshReward then
		self:RefreshRewardGrid()
	elseif oCtrl.m_EventID == define.Schedule.Event.RefreshDouble then
		self:RefreshDoubleInfo()
	elseif oCtrl.m_EventID == define.Schedule.Event.RefreshHuodong then
		self:InitLimitGrid()
		self:RefreshScheduleBoxList()
	elseif oCtrl.m_EventID == define.Schedule.Event.RefreshDayTask then
		self:SetEachDayTaskList()
	elseif oCtrl.m_EventID == define.Schedule.Event.ClearEffect then
		self:LimitBoxClearEffect(oCtrl.m_EventData)
	end
end

function CScheduleMainView.OnWeekSchedule(self)
	netopenui.C2GSWeekSchedule()
end

function CScheduleMainView.OnPushSetting(self)
	-- self:OnClose()
	g_SystemSettingsCtrl:ShowPushSettingView()
end

function CScheduleMainView.OnSetHintInfo(self)
	-- self.m_ScheduleTipBox:ShowScheduleTipBox(true)
	local Id = define.Instruction.Config.DoublePoint
	if data.instructiondata.DESC[Id]~=nil then

		local Content = {
			title = data.instructiondata.DESC[Id].title,
			desc = data.instructiondata.DESC[Id].desc
		}
		g_WindowTipCtrl:SetWindowInstructionInfo(Content)
	end
end

function CScheduleMainView.OnDoublePoint(self)
	g_ScheduleCtrl:C2GSRewardDoublePoint(function ()
		netopenui.C2GSRewardDoublePoint()
	end, function ()
		self:CloseView()
	end)
end

-- [[初始化界面信息]]
-- 界面Tab
function CScheduleMainView.InitMainViewTabGrid(self)
	
	local gridInstanceID = self.m_ScheduleTabGrid:GetInstanceID()
	local function InitTabBtnGrid(obj, idx)
		local oTabBtn = CButton.New(obj, false, false)
		oTabBtn:SetGroup(gridInstanceID)
		-- if next(g_ScheduleCtrl:GetScheduleByType(define.Schedule.Type.Unopen)) then
		-- 	oTabBtn:SetWidth(110)
		-- 	--self.m_ScheduleTabGrid.m_UIGrid.cellWidth = 105
		-- 	--self.m_ScheduleTabGrid:SetLocalPos(Vector3.New(-335, 205, 0))
		-- else
		-- 	--oTabBtn:SetWidth(125)
		-- 	self.m_ScheduleTabGrid.m_UIGrid.cellWidth = 135
		-- 	self.m_ScheduleTabGrid:SetLocalPos(Vector3.New(-325, 205, 0))
		-- end
		if idx == 5 then
			oTabBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.EachDayTask))
			if g_ScheduleCtrl:GetIsShowDayTaskRedPoint() then
				oTabBtn:AddEffect("RedDot", 25, Vector2(-24, -24))
			else
				oTabBtn:DelEffect("RedDot")
			end
		end
		oTabBtn:AddUIEvent("click", callback(self, "ShowMainViewTabBtn", idx))
		return oTabBtn
	end
	self.m_ScheduleTabGrid:InitChild(InitTabBtnGrid)
	local scheduleType = g_ScheduleCtrl:GetScheduleTabInfo(3)
	local scheduleDataList = g_ScheduleCtrl:GetScheduleByType(scheduleType)
	if #scheduleDataList == 0 then
		self.m_ScheduleTabGrid:GetChild(3):SetActive(false)
	end
	--暂时屏蔽每日必做任务
	self.m_ScheduleTabGrid:GetChild(4):SetActive(false)
	self.m_ScheduleTabGrid:Reposition()
end

function CScheduleMainView.ShowMainViewTabBtn(self, index)
	local index = index or 1
	self.m_ScheduleGrid:Clear()
	local oTabBtn = self.m_ScheduleTabGrid:GetChild(index)
	oTabBtn:SetSelected(true)
	--1 日常，2 限时，3 即将开启 4 每日必做
	--index 4是每日任务内容
	self.m_ScheduleTabGrid:Reposition()
	if index == 4 then
		g_ScheduleCtrl.m_IsRedPointRead = true
		self.m_ScheduleScrollView:SetActive(false)
		self.m_DayTaskScrollView:SetActive(true)
		self.m_NilSchduleNode:SetActive(false)
	else
		self.m_ScheduleScrollView:SetActive(true)
		self.m_DayTaskScrollView:SetActive(false)
		self:InitScheduleGrid(index)
		self:RefreshScheduleBoxList()
	end
end

-- 初始化日程Cell
function CScheduleMainView.InitScheduleGrid(self, index)

	local scheduleType = g_ScheduleCtrl:GetScheduleTabInfo(index)
	local scheduleDataList = g_ScheduleCtrl:GetScheduleByType(scheduleType)
	--1 日常，2 限时，3 即将开启 4 每日必做
	local scheduleBoxList = self.m_ScheduleGrid:GetChildList()
	local oScheduleBox = nil

	for i,v in ipairs(scheduleDataList) do
		if i > #scheduleBoxList then
			oScheduleBox = self.m_ScheduleBoxClone:Clone(function(scheduleInfo, showDetail)
				if scheduleInfo then
					if showDetail then
						CScheduleInfoView:ShowView(function(oView)
							oView:SetScheduleInfo(scheduleInfo)
						end)
					end
					g_ScheduleCtrl:CheckScheduleRecordEff(scheduleInfo)
				end
			end, function ()
				self:CloseView()
			end)
			self.m_ScheduleGrid:AddChild(oScheduleBox)
		else
			oScheduleBox = scheduleBoxList[i]
		end
		oScheduleBox:SetScheduleBox(v, scheduleType)
		if v.id == g_ScheduleCtrl.m_JjcScheduleId then
			g_GuideCtrl:AddGuideUI("schedule_jjc_join_btn", oScheduleBox.m_JoinBtn)
		elseif v.id == g_ScheduleCtrl.m_ShimenScheduleId then
			g_GuideCtrl:AddGuideUI("schedule_shimen_join_btn", oScheduleBox.m_JoinBtn)
		end
		oScheduleBox:SetActive(true)
	end

	for i=#scheduleDataList+1,#scheduleBoxList do
		oScheduleBox = scheduleBoxList[i]
		if not oScheduleBox then
			break
		end
		oScheduleBox:SetActive(false)
	end
	self.m_ScheduleGrid:Reposition()
	self.m_ScheduleScrollView:ResetPosition()

	self.m_NilSchduleNode:SetActive(#scheduleDataList == 0)
end

function CScheduleMainView.RefreshScheduleBoxList(self)
	local scheduleDataList = table.copy( g_ScheduleCtrl.m_SvrScheduleList or {} ) 
	for i,v in ipairs(g_ScheduleCtrl.m_SvrHuodongList) do
		scheduleDataList[v.scheduleid] = {scheduleid = v.scheduleid }
	end

	for _,v in pairs(scheduleDataList) do
		self:RefreshSpecityScheduleBox(v)
	end
end

-- 初始化限时日程Cell
function CScheduleMainView.InitLimitGrid(self)
	self.m_LimitGrid:Clear()
	local limitDataList = g_ScheduleCtrl:GetLimitScheduleInfoList()
	local limitBoxList = self.m_LimitGrid:GetChildList()
	local oLimitBox = nil
	for i,v in ipairs(limitDataList) do
		if not g_ScheduleCtrl:IsHideNoticePage(v.id) then 
			if i > #limitBoxList then
				oLimitBox = self.m_LimitBoxClone:Clone(function(scheduleInfo, showDetail)
					if scheduleInfo then
						if showDetail then
							CScheduleInfoView:ShowView(function(oView)
								oView:SetScheduleInfo(scheduleInfo)
							end)
						end
						g_ScheduleCtrl:CheckScheduleRecordEff(scheduleInfo)
					end
				end, function ()
					self:CloseView()
				end)
				self.m_LimitGrid:AddChild(oLimitBox)
			else
				oLimitBox = limitBoxList[i]
			end
			oLimitBox:SetScheduleBox(v, define.Schedule.Type.Limit)
			oLimitBox:SetActive(true)
		end
	end

	for i=#limitDataList+1,#limitBoxList do
		oLimitBox = limitBoxList[i]
		if not oLimitBox then
			break
		end
		oLimitBox:SetActive(false)
	end
	self.m_LimitGrid:Reposition()
	self.m_LimitGrid:RepositionLater()
end

function CScheduleMainView.RefreshSpecityScheduleBox(self, scheduleData)
	printc("日程更新0"..scheduleData.scheduleid)
	local checkLimitBox = self:RefreshSpecityCommonBox(scheduleData)
	if checkLimitBox then
		self:RefreshSpecityLimitBox(scheduleData)
	end
end

-- 刷新指定日程CellBox
function CScheduleMainView.RefreshSpecityCommonBox(self, scheduleData)
	local scheduleBoxList = self.m_ScheduleGrid:GetChildList()
	for _,oBox in ipairs(scheduleBoxList) do
		if scheduleData.scheduleid == oBox:GetScheduleBoxScheduleID() then
			oBox:RefreshTimesAndActive()
			self.m_ScheduleGrid:Reposition()
			return
		end
	end
	return true
end

-- 刷新指定限时日程CellBox
function CScheduleMainView.RefreshSpecityLimitBox(self, scheduleData)
	local limtBoxList = self.m_LimitGrid:GetChildList()	
	for _,oBox in ipairs(limtBoxList) do
		if scheduleData.scheduleid == oBox:LimitScheduleID() then		
			oBox:RefreshTimesAndActive()
			self.m_LimitGrid:Reposition()
			return
		end
	end
end

-- 初始化日程奖励CellBox
function CScheduleMainView.InitRewardGrid(self)
	local rewardBoxList = self.m_RewardBoxGrid:GetChildList()
	if #rewardBoxList > 0 then
		return
	end
	local rewardList = data.scheduledata.ACTIVEREWARD
	if rewardList and #rewardList > 0 then
		for i,v in ipairs(rewardList) do
			if i >5 then
				break
			end
			local item = v.item[1]
			local oScheduleRewardBox = self.m_RewardBoxClone:Clone(function ()
				if g_ScheduleCtrl.m_SvrActivePoint < v.point then
					-- g_NotifyCtrl:FloatMsg(string.format("活跃度不足[00ff00]%d[-],不能领取该奖励", v.point))
				else
					netopenui.C2GSScheduleReward(i)
				end
			end)
			self.m_RewardBoxGrid:AddChild(oScheduleRewardBox)
			local data = {
				sid = item.sid,
				point = v.point,
				amount = item.amount
			}
			if g_ScheduleCtrl.m_SvrActivePoint/20 >=i then
				oScheduleRewardBox.m_BoxBg:SetSpriteName("h7_yuan_1")
				oScheduleRewardBox.m_BoxBg:SetSize(92,92)
			end
			oScheduleRewardBox:SetScheduleRewardInfo(data)
			oScheduleRewardBox:SetActive(true)
		end
	end
	--第六个珍兽碎片特殊处理  这里的内容都是写死的,@宝平
	local info = rewardList[6]
	if info then
		-- self.m_RarityPetDebris.icon = self.m_RarityPetDebris:NewUI(1, CSprite)
		-- local quaSpr = self.m_RarityPetDebris:NewUI(2, CSprite)
		-- local bg  = self.m_RarityPetDebris:NewUI(3, CSprite)
		-- local amount = self.m_RarityPetDebris:NewUI(4, CLabel)
		-- local active = self.m_RarityPetDebris:NewUI(5, CLabel)
		-- local itemdata =  DataTools.GetItemData(info.item[1].sid)
		-- icon:SetSpriteName(5147)
		self.m_RarityPetDebris.icon:AddUIEvent("click", callback(self, "RarityPetDebrisCB", self.m_RarityPetDebris.icon))
		-- bg:SetSpriteName("h7_weupinkuang")
		-- amount:SetText(info.item[1].amount)
		-- active:SetText(info.point)
		self.m_RarityPetDebris.icon:AddEffect("Rect")
		self.m_RarityPetDebris.icon:EnableTouch(true)
		self.m_RarityPetDebris.icon.m_IgnoreCheckEffect = true
	end
	-- local tipspr = self.m_RarityPetTipBox:NewUI(1, CSprite)
	local tiplab = self.m_RarityPetTipBox:NewUI(2, CLabel)
	tiplab:SetRichText(data.scheduledata.TEXT[1001].content, nil, nil, true)
end

function CScheduleMainView.RarityPetDebrisCB(self, icon)
	local oView = CSummonMainView:ShowView( function (oView)
		oView:ShowSubPageByIndex(3)
		oView.m_DetailPart:SetSelSummon(data.summondata.INFO[4001], true)
		end)
end
-- 刷新日程奖励CellBox
function CScheduleMainView.RefreshRewardGrid(self)
	local rewardStateList = g_ScheduleCtrl:GetRewardStateList()
	local rewardDataList = data.scheduledata.ACTIVEREWARD
	local rewardBoxList = self.m_RewardBoxGrid:GetChildList()
	for i,v in ipairs(rewardBoxList) do
		if g_ScheduleCtrl.m_SvrActivePoint and g_ScheduleCtrl.m_SvrActivePoint >= rewardDataList[i].point then
			local showRewardEff = i > #rewardStateList or rewardStateList[i] == 0 or false
			v:SetScheduleRewardEffect(showRewardEff)
		else
			v:ResetScheduleReward()
		end
	end
end

-- 刷新日程活跃度条
function CScheduleMainView.RefreshActiveSlider(self)
	local percentage
	if g_ScheduleCtrl.m_SvrActivePoint < 100 then
		percentage = g_ScheduleCtrl.m_SvrActivePoint*0.0091
	else
		percentage = 1  
	end
	self.m_ActiveSlider:SetValue(percentage)
	self.m_ActivePoint:SetText(g_ScheduleCtrl.m_SvrActivePoint)
	self:RefreshRewardGrid()
end
 
--隐藏未开启Tab按钮
function CScheduleMainView.SetUnopenTabBtnActive(self)
	local oUnopenBtn = self.m_ScheduleTabGrid:GetChild(4)
	local unopenList = g_ScheduleCtrl:GetScheduleByType(define.Schedule.Type.Unopen)
	local unopenTabBtnSta = next(unopenList) ~= nil
	oUnopenBtn:SetActive(unopenTabBtnSta)
	self.m_ScheduleTabGrid:Reposition()
end

function CScheduleMainView.RefreshDoubleInfo(self)

	local current = g_ScheduleCtrl.m_SvrDoublePoint.current
	local limit = g_ScheduleCtrl.m_SvrDoublePoint.limit

	self.m_DoublePointBox.m_Current:SetText(current.."/")
	self.m_DoublePointBox.m_Remainder:SetText(limit)

	if current < 120 and limit > 0 then
		self.m_DoublePointBox.m_DoublePointBtn:AddEffect("Rect", Vector3.New(1, -2, 0))
	else
		self.m_DoublePointBox.m_DoublePointBtn:DelEffect("Rect")
	end
end

function CScheduleMainView.JumpToSchedule(self, iScheduleId)
	local dSchedule = data.scheduledata.SCHEDULE[iScheduleId]
	if dSchedule.type ~= 1 then
		self:ShowMainViewTabBtn(2)
	end
	
	for i,oBox in ipairs(self.m_ScheduleGrid:GetChildList()) do
		if oBox.m_ScheduleInfo.id == iScheduleId then
			-- oBox:SetSelected(true)
			UITools.MoveToTarget(self.m_ScheduleScrollView, oBox)
		end
	end
end

---------------------以下是每日任务相关------------------------

function CScheduleMainView.SetEachDayTaskList(self)
	local optionCount = #g_ScheduleCtrl.m_DayTaskData
	local GridList = self.m_DayTaskGrid:GetChildList() or {}
	local oEachDayBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oEachDayBox = self.m_DayTaskClone:Clone(false)
				-- self.m_DayTaskGrid:AddChild(oOptionBtn)
			else
				oEachDayBox = GridList[i]
				oEachDayBox.m_Grid:Clear()
			end
			self:SetEachDayTaskBox(oEachDayBox, g_ScheduleCtrl.m_DayTaskData[i])
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
	self.m_DayTaskGrid:Reposition()
	self.m_DayTaskScrollView:ResetPosition()
end


function CScheduleMainView.SetEachDayTaskBox(self, oEachDayBox, oData)
	oEachDayBox:SetActive(true)

	oEachDayBox.m_NameLbl = oEachDayBox:NewUI(1, CLabel)
	oEachDayBox.m_DescLbl = oEachDayBox:NewUI(2, CLabel)
	oEachDayBox.m_Slider = oEachDayBox:NewUI(3, CSlider)
	oEachDayBox.m_ProcessLbl = oEachDayBox:NewUI(4, CLabel)
	oEachDayBox.m_FinishBtn = oEachDayBox:NewUI(5, CButton)
	oEachDayBox.m_FinishMark = oEachDayBox:NewUI(6, CSprite)
	oEachDayBox.m_ScrollView = oEachDayBox:NewUI(7, CScrollView)
	oEachDayBox.m_Grid = oEachDayBox:NewUI(8, CGrid)
	oEachDayBox.m_BoxClone = oEachDayBox:NewUI(9, CBox)
	oEachDayBox.m_DoBtn = oEachDayBox:NewUI(10, CButton)
	oEachDayBox.m_BoxClone:SetActive(false)

	local config = data.taskdata.EVERYDAYTASK[oData.taskid]
	oEachDayBox.m_NameLbl:SetText(config.title)
	oEachDayBox.m_Slider:SetValue(0 + oData.cur_cnt/oData.max_cnt*(1-0))
	oEachDayBox.m_ProcessLbl:SetText(oData.cur_cnt.."/"..oData.max_cnt)

	self:SetPrizeList(g_GuideHelpCtrl:GetRewardList("EVERYDAYTASK", config.rewardid), oEachDayBox)
	if oData.cur_cnt >= oData.max_cnt and oData.rewarded == 0 then
		oEachDayBox.m_FinishBtn:SetActive(true)
		oEachDayBox.m_FinishMark:SetActive(false)
		oEachDayBox.m_DoBtn:SetActive(false)
	elseif oData.cur_cnt < oData.max_cnt then
		oEachDayBox.m_FinishBtn:SetActive(false)
		oEachDayBox.m_FinishMark:SetActive(false)
		if oData.taskid ~= 1 then
			oEachDayBox.m_DoBtn:SetActive(true)
		else
			oEachDayBox.m_DoBtn:SetActive(false)
		end
	elseif oData.cur_cnt >= oData.max_cnt and oData.rewarded ~= 0 then
		oEachDayBox.m_FinishBtn:SetActive(false)
		oEachDayBox.m_FinishMark:SetActive(true)
		oEachDayBox.m_DoBtn:SetActive(false)
	end
	oEachDayBox:AddUIEvent("click", callback(self, "OnClickEachDayBox", config))
	oEachDayBox.m_FinishBtn:AddUIEvent("click", callback(self, "OnClickGetPrize", oData, oEachDayBox.m_Grid))
	oEachDayBox.m_DoBtn:AddUIEvent("click", callback(self, "OnClickDayTaskDo", oData))

	self.m_DayTaskGrid:AddChild(oEachDayBox)
	self.m_DayTaskGrid:Reposition()
end

function CScheduleMainView.SetPrizeList(self, list, oBox)
	oBox.m_Grid:Clear()
	local optionCount = #list
	local GridList = oBox.m_Grid:GetChildList() or {}
	local oPrizeBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPrizeBox = oBox.m_BoxClone:Clone(false)
				-- oBox.m_Grid:AddChild(oOptionBtn)
			else
				oPrizeBox = GridList[i]
			end
			self:SetPrizeBox(oPrizeBox, list[i], oBox)
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

	oBox.m_Grid:Reposition()
	oBox.m_ScrollView:ResetPosition()
end

function CScheduleMainView.SetPrizeBox(self, oPrizeBox, oData, oBox)
	oPrizeBox:SetActive(true)
	oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
	-- oPrizeBox.m_QualitySp = oPrizeBox:NewUI(3, CSprite)
    -- oPrizeBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oData.item.id, oData.item.quality or 0 ) )
	oPrizeBox.m_IconSp:SpriteItemShape(oData.item.icon)
	oPrizeBox.m_Data = oData
	if oData.amount > 0 then
		oPrizeBox.m_CountLbl:SetActive(true)
		oPrizeBox.m_CountLbl:SetText(oData.amount)
	else
		oPrizeBox.m_CountLbl:SetActive(false)
	end
	
	oPrizeBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", oData.item, oPrizeBox, oData))

	oBox.m_Grid:AddChild(oPrizeBox)
	oBox.m_Grid:Reposition()
end

function CScheduleMainView.OnClickPrizeBox(self, oPrize, oPrizeBox, oData)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

function CScheduleMainView.OnClickEachDayBox(self, config)
	CDayTaskInfoView:ShowView(function (oView)
		oView:RefreshUI(config)
	end)
end

function CScheduleMainView.OnClickGetPrize(self, oData, grid)
	--普通物品 ItemCtrl
	--金币银币元宝 AttrCtrl
	nettask.C2GSRewardEverydayTask(oData.taskid)
end

function CScheduleMainView.LimitBoxClearEffect(self, scheudleid)
 	--清除左侧限时活动的特效
 	if self.m_ScheduleTabGrid:GetChild(2):GetSelected() then
 		local ScheduleList = self.m_ScheduleGrid:GetChildList()
 		for _,box in pairs(ScheduleList) do
 			if box:LimitScheduleID()== scheudleid then
 				box:SetEffect(false, false)
 				box:HideRedPoint()
 				break
 			end
 		end
 	end
 	--清除右侧限时活动预告特效
 	local LimitBoxLit = self.m_LimitGrid:GetChildList()
 	for _,box in pairs(LimitBoxLit) do
 		if box:LimitScheduleID() == scheudleid then
 			box:SetEffect(false, false)
 			box:HideRedPoint()
 			break
 		end 
 	end
end

function CScheduleMainView.OnClickDayTaskDo(self, oData)
	if g_LimitCtrl:CheckIsLimit(true, true) then
    	return
    end
	if g_BonfireCtrl.m_IsBonfireScene and (g_BonfireCtrl.m_CurActiveState == 2 or g_BonfireCtrl.m_CurActiveState == 1) then
        g_NotifyCtrl:FloatMsg("你正在帮派篝火活动中，不可挑战")
        return
    end
    if g_WarCtrl:IsWar() and not table.index(self.m_CouldDoInWarList, ScheduleInfo.id) then
        g_NotifyCtrl:FloatMsg("请脱离战斗后再进行操作")
       return
    end
    
    local isCloseView = false
	local config = data.taskdata.EVERYDAYTASK[oData.taskid]
	
	if config.id == 2 then --"师门任务"（修改为：门派修行）
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.SHIMEN.ID)
		isCloseView = true
	elseif config.id == 3 then --"抓鬼任务"（修改为：金刚伏魔 （钟馗：判官））
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.GHOST.ID)
		isCloseView = true
	elseif config.id == 4 then --"封妖"
		local mapID = 101000
		local sealNpcMapInfo = DataTools.GetSealNpcMapInfo(g_AttrCtrl.grade)
		if sealNpcMapInfo then
			mapID = sealNpcMapInfo.mapid
		end	
		g_MapCtrl:C2GSClickWorldMap(mapID)
		isCloseView = true
	elseif config.id == 5 then --"雷峰塔副本（侠影）"
		g_MapTouchCtrl:WalkToGlobalNpc(5257)
		isCloseView = true
	elseif config.id == 6 then --"雷峰塔副本（仙途）"
		g_MapTouchCtrl:WalkToGlobalNpc(5257)
		isCloseView = true
	elseif config.id == 7 then --"金山寺副本（侠影）"
		--未处理
		g_MapTouchCtrl:WalkToGlobalNpc(5257)
		isCloseView = true
	elseif config.id == 8 then --"金山寺副本（仙途）"
		--未处理
		g_MapTouchCtrl:WalkToGlobalNpc(5257)
		isCloseView = true
	elseif config.id == 9 then --"竞技场"
		g_JjcCtrl:OpenJjcMainView()
        isCloseView = true
	elseif config.id == 10 then --"异宝收集"
		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.YIBAO.ID)
		isCloseView = true
	elseif config.id == 11 then --"跳舞活动"
		nethuodong.C2GSDanceAuto()
		isCloseView = true
	elseif config.id == 12 then --"欢乐骰子"
		nethuodong.C2GSShootCrapOpen()
		isCloseView = true
	elseif config.id == 13 then --"天魔来袭"
		--未处理
		local mapID = 201000
		g_MapCtrl:C2GSClickWorldMap(mapID)
		isCloseView = true
	elseif config.id == 14 then --"装备提升" 装备强化、洗练、打造
		CForgeMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("Forge"))
		end)
	elseif config.id == 15 then --"伙伴提升" 使用伙伴经验丹、升级伙伴技能、伙伴突破、伙伴进阶
		CPartnerMainView:ShowView(function(oView)
			oView:ResetCloseBtn()
			oView:ShowSubPageByIndex(oView:GetPageIndex("Recruit"))
		end)
	elseif config.id == 16 then --"宠物提升" 使用宠物经验丹、升级宠物技能、学习宠物技能
		g_SummonCtrl:ShowPropertyView()
	elseif config.id == 17 then --"宠物炼妖" 宠物合成、宠物洗练、宠物培养
		g_SummonCtrl:ShowWashView()
	elseif config.id == 18 then --"提升主角技能" 升级主角招式技能、心法技能、修炼技能、帮派技能
		CSkillMainView:ShowView(function(oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("School"))
		end)
	else
	end
	
	if isCloseView then
		self:CloseView()
	end
end

function CScheduleMainView.OnShowScheduleTips(self, id)
	local scheduleInfo = g_ScheduleCtrl:GetScheduleInfo(id)
	if not scheduleInfo then
		return
	end

	-- tips显示
	CScheduleInfoView:ShowView(function(oView)
		oView:SetScheduleInfo(scheduleInfo)
	end)
	g_ScheduleCtrl:CheckScheduleRecordEff(scheduleInfo)

	-- 未开启活动飘字提示
	local scheduleBoxList = self.m_ScheduleGrid:GetChildList()
	local oScheduleBox
	for i, v in ipairs(scheduleBoxList) do
		if v.m_ScheduleInfo.id == id then
			oScheduleBox = v
			break
		end
	end
	if oScheduleBox then
		return
	end
	if id == 1038 then --乱世魔影飘字处理
		g_NotifyCtrl:FloatMsg("#G乱世魔影#n当前未刷新，请留意系统传闻和活动日程")
	else
		local msg = string.format("#G%s#n开启时间为#G%s#n", scheduleInfo.name, scheduleInfo.activetime)
		g_NotifyCtrl:FloatMsg(msg)
	end
end

return CScheduleMainView
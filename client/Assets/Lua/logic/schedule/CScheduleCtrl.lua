CScheduleCtrl = class("CScheduleCtrl", CCtrlBase)

function CScheduleCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_ActivePointMax = 110
	self.m_RecordSchedule = {
		View = {
			TabIndex = 1
		},
		Logic = {
			-- 奖励领取状态{0:可领 | ~0:可领}
			MaskIndex = 0,
			HuoDongTips = {},
			LocalRedPoint = false,
		}
	}
	self.m_MainUIRedPointSta = false
	--这个是记录红点的
	self.m_ScheduleEffRecord = {}
	self.m_SvrHuodongList = {}
	self.m_SvrScheduleList = {}
	self.m_SvrActivePoint = nil
	self.m_SvrWeekDataList = nil

	self.m_SvrDoublePoint = {current = 0, limit = 0}
	self.m_MaskList = {1022}
	-- 这个是记录环绕特效的 -- 字典
	-- [scheduleid] = bool
	self.m_RectEffRecord = {}
	self.m_DayTaskData = {}
	self.m_IsRedPointRead = false
	self.m_CurrCrapsPoint = nil
	self.m_Hdlist = nil

	self.m_JjcScheduleId = 1007
	self.m_ShimenScheduleId = 1001

	self.m_StopNotifyEveryDataList = {}
	self.m_StopNotifyLimitDataList = {}
	self.m_StopNotifyActualList = {}
	self.m_RectEffIds = {}
	self:GetStopNotifyActivity()

	self.m_IsJjcNotifyLogin = false

	--可以在战斗中参加的活动
	self.m_CouldDoInWarList = {1007, 1015, 1017, 1021, 1041, 1042}
	--不可以在战斗中参加的限时活动
	self.m_WarLimitList = {1012, 1013, 1018, 1019, 1020, 1023, 1025, 1034, 1036, 1038, 1039, 1041, 1042, 1043}
	-- 特殊的限時活動
	self.m_IntPointSchedule = {[1]= 1009, [2] = 1029, [3] = 1035}
	--队员限制活动
	self.m_MemberLimitList = {1023, 1025, 1041, 1042, 1034, 1039}
	--地图操作限制
	self.m_MapLimitList = {1012, 1013, 1018, 1020, 1023, 1025, 1034, 1039}
end

function CScheduleCtrl.Clear(self)
	self.m_IsJjcNotifyLogin = false
	self.m_RectEffRecord = {}
	self.m_CurrCrapsPoint = nil
end

function CScheduleCtrl.InitData(self)
	self.m_ScheduleEffRecord = IOTools.GetRoleData("schedule_EffRecord") or {}
	self.m_RectEffIds = IOTools.GetRoleData("schedule_RectEff") or {}
	netopenui.C2GSOpenScheduleUI()
end

function CScheduleCtrl.SaveScheduleEffRecord(self, scheduleEffRecord)
	IOTools.SetRoleData("schedule_EffRecord", scheduleEffRecord)
end

function CScheduleCtrl.IsUnExistEffRecordID(self, scheduleID)
	if not self:IsKfShow(scheduleID) then
		return false
	end
	return not table.index(self.m_ScheduleEffRecord, scheduleID)
end

function CScheduleCtrl.IsInEffRecordList(self, dataList)
	if not dataList then return end
	for _,v in ipairs(dataList) do
		if  self:IsUnExistEffRecordID(v.id) then 
			return true
		end
	end
	return false
end

function CScheduleCtrl.GetScheduleTabInfo(self, index)
	local typeMap = {
		--define.Schedule.Type.Every, --全部活动
		define.Schedule.Type.Normal,  --日常活动
		--define.Schedule.Type.Fuben, -- 副本
		--define.Schedule.Type.Unopen --未开启
		define.Schedule.Type.Limit, --限时活动 
		define.Schedule.Type.Unopen --即将开启
	}
	if not index or index <= 0 or index > 3 then
		index = 1
	end
	self.m_RecordSchedule.View.TabIndex = index
	return typeMap[index]
end

function CScheduleCtrl.GetRewardStateList(self)
	local stateList = {}
	local mask = self.m_RecordSchedule.Logic.MaskIndex
	while mask >= 2 do
		local i = MathBit.andOp(mask, 2) 
		mask = mask / 2
		table.insert(stateList, i)
	end
	return stateList
end

function CScheduleCtrl.IsUnExistRecordEff(self)
	local normalList = self:GetScheduleByType(define.Schedule.Type.Normal)
	local limitList = self:GetScheduleByType(define.Schedule.Type.Limit)
	-- local limitList = self:GetLimitScheduleInfoList()

	return self:IsInEffRecordList(normalList) or self:IsInEffRecordList(limitList)
end

function CScheduleCtrl.IsExistUnReceiveReward(self)
	local rewardStateList = self:GetRewardStateList()
	local rewardDataList = data.scheduledata.ACTIVEREWARD
	for i,v in ipairs(rewardDataList) do
		if self.m_SvrActivePoint and self.m_SvrActivePoint >= v.point then
			-- 自动领取，不检测
			if i ~= 6 then
				if i > #rewardStateList or next(rewardStateList) == nil or rewardStateList[i] == 0 then
					return true
				end
			end
		end
	end
	return false
end

function CScheduleCtrl.ResetLocalRedPoint(self)
	local unExistRecord = self:IsUnExistRecordEff()
	self.m_RecordSchedule.Logic.LocalRedPoint = unExistRecord 
	self:ResetMainUIBtnEffect()
end

function CScheduleCtrl.CheckScheduleRecordEff(self, scheduleInfo)
	if scheduleInfo then
		local scheduleID = scheduleInfo.id
		if self:IsUnExistEffRecordID(scheduleID) then-- and scheduleInfo.level < g_AttrCtrl.grade then
			table.insert(self.m_ScheduleEffRecord, scheduleID)
			self:SaveScheduleEffRecord(self.m_ScheduleEffRecord)
		end
		self:ResetLocalRedPoint()
	end
end

--	设置主界面日程按钮红点
function CScheduleCtrl.ResetMainUIBtnEffect(self)
	local redpointSta = self.m_RecordSchedule.Logic.LocalRedPoint or self:IsExistUnReceiveReward() or g_HeroTrialCtrl:HasReward()
	printc("===============redpointSta======",redpointSta)
	if self.m_MainUIRedPointSta ~= redpointSta then
		self.m_MainUIRedPointSta = redpointSta
		self:OnEvent(define.Schedule.Event.RefreshUITip)
	end
end

function CScheduleCtrl.GetScheduleInfo(self, scheduleID)
	return DataTools.GetScheduleData(scheduleID)
end

function CScheduleCtrl.GetScheduleData(self, scheduleID)
	return self.m_SvrScheduleList[scheduleID]
end

function CScheduleCtrl.GetPreviewScheduleData(self, scheduleID)
	if self.m_SvrHuodongList then
		for _,v in ipairs(self.m_SvrHuodongList) do
			if scheduleID == v.scheduleid then
				return v
			end
		end
	end
end

function CScheduleCtrl.GetScheduleByType(self, scheduleType, isInActive)
	local scheduleList = {}
	-- if not next(self.m_SvrHuodongList) then return scheduleList end
	
	local scheduleConfigDic = data.scheduledata.SCHEDULE
	if scheduleType == define.Schedule.Type.Limit then  --限时活动
		for _,v in pairs(scheduleConfigDic) do
			for _,k in ipairs(self.m_SvrHuodongList) do
				local limitScheduelData = nil
				if self:IsIntPointSchedule(v.id) then   
					limitScheduelData = self:GetScheduleInfo(v.id)
					v.schedulestate = {scheduleid = v.id, state = 1}
				else
					limitScheduelData = self:GetPreviewScheduleData(v.id)
					v.schedulestate = limitScheduelData
				end
				local state = limitScheduelData and limitScheduelData.state or -1
				if v.open == 1 and v.id == k.scheduleid and v.level <= g_AttrCtrl.grade and (not isInActive and state ~= 4 or (isInActive and state == 2)) and self:IsKfShow(v.id) then
					table.insert(scheduleList,v)
				end
			end
		end
		--刷星活动不会在贴心管家里面
		for i,v in ipairs(self.m_IntPointSchedule) do
			if scheduleConfigDic[v].level <= g_AttrCtrl.grade and not isInActive and self:IsKfShow(v) then
				table.insert(scheduleList, scheduleConfigDic[v])
			end
		end
		if next(self.m_SvrHuodongList) then
			table.sort(scheduleList, function (a,b)  --状态排序,时间排序，sort 排序
				-- body
				if a.schedulestate.state ~= b.schedulestate.state then
					return a.schedulestate.state < b.schedulestate.state
				elseif a.sort ~= b.sort then
					return a.sort < b.sort
				elseif  a.schedulestate.time ~=  b.schedulestate.time then
					return a.schedulestate.time > b.schedulestate.time
				end
			end)
		end
		return scheduleList
	end
	--=========================================================
	local Level = g_AttrCtrl.grade  --即将开启
	if  scheduleType == define.Schedule.Type.Unopen then
		for _,v in pairs(scheduleConfigDic) do
			if  Level < v.level and v.level <= Level+10  and v.open == 1 and self:IsKfShow(v.id) then
				table.insert(scheduleList,v)
			end
		end
		table.sort(scheduleList, function(a,b)
			if a.level ~= b.level then
				return a.level < b.level
			else
				return a.sort < b.sort
			end
		end)
		return scheduleList
	end
	--=========================================================
	if scheduleType == define.Schedule.Type.Normal then
		for _,v in pairs(scheduleConfigDic) do
			local matchLevel = g_AttrCtrl.grade >= v.level
			if v.type == 1 and matchLevel  and v.open == 1 and self:IsKfShow(v.id) then
				if not isInActive then
					table.insert(scheduleList, v)
				else
					local scheduleData = g_ScheduleCtrl:GetScheduleData(v.id)
					if not (scheduleData and scheduleData.maxtimes > 0 and scheduleData.times >= scheduleData.maxtimes) then
						table.insert(scheduleList, v)
					end
				end	
			end
		end

		local function scheduleSort(scheduleList) --日常活动排序
			-- body
			table.sort(scheduleList, function(a,b)        --第一次排序按照策划填表进行
				return  a.sort < b.sort
			end)                   	--第二次排序按照活跃排序
			for _,v in pairs(self.m_SvrScheduleList) do
				for i,j in ipairs(scheduleList)	do 
					if v.scheduleid == j.id and v.maxtimes~=0 and v.maxtimes == v.times then
						table.remove(scheduleList, i)
						table.insert(scheduleList, j)
					end
				end     
			end                          
		end
		scheduleSort(scheduleList)
	end
	if scheduleType == define.Schedule.Type.Every then
		for _,v in pairs(scheduleConfigDic) do
			local matchLevel = g_AttrCtrl.grade >= v.level
			if v.type == 1 and matchLevel  and v.open == 1 and self:IsKfShow(v.id) then
				if not isInActive then
					table.insert(scheduleList, v)
				else
					local scheduleData = g_ScheduleCtrl:GetScheduleData(v.id)
					if not (scheduleData and scheduleData.maxtimes > 0 and scheduleData.times >= scheduleData.maxtimes) then
						table.insert(scheduleList, v)
					end
				end
			end
		end
	end
	return scheduleList
end

function CScheduleCtrl.GetLimitScheduleInfoList(self)
	local limitScheduleInfoList = {}
	if self.m_SvrHuodongList then
		for _,v in ipairs(self.m_SvrHuodongList) do
			-- 节日仙子不显示预告
			if v.scheduleid ~= 1037 then
				local scheduleInfo = self:GetScheduleInfo(v.scheduleid)
				if scheduleInfo and g_AttrCtrl.grade >= scheduleInfo.level and v.state ~= 4 and self:IsKfShow(v.scheduleid) then
					if v.state == 1 then
					 	scheduleInfo.statesort = 2
					elseif v.state == 2 then
					 	scheduleInfo.statesort = 1
					elseif v.state == 3 then
					 	scheduleInfo.statesort = 3
					end
					scheduleInfo.schedulestate = v
					table.insert(limitScheduleInfoList, scheduleInfo)
				end
			end
		end
	end

	table.sort(limitScheduleInfoList, function (a,b)
		if a.statesort ~= b.statesort then
			return a.statesort < b.statesort
		else
			return a.schedulestate.time < b.schedulestate.time
		end
	end)

	return limitScheduleInfoList
end

function CScheduleCtrl.GetHintInfoDes(self)
	local desctibeStr = nil
	local activePoint = 0
	local scheduleConfigDic = data.scheduledata.SCHEDULE
	local deslabelList = {}
	for _,v in pairs(scheduleConfigDic) do
		if v.type == 1 then

			local count = 0
			if next(self.m_SvrScheduleList) ~= nil then
				if self.m_SvrScheduleList[v.id] then
					count = self.m_SvrScheduleList[v.id].activepoint
					activePoint = activePoint + self.m_SvrScheduleList[v.id].activepoint
				end
			end
			if v.maxpoint> 0 then
				local nextStr = string.format("%s:%s/%s", v.name, count, v.maxpoint)
				--desctibeStr = desctibeStr and desctibeStr .. "\n" .. nextStr or nextStr
				table.insert(deslabelList, nextStr)
			end
		end
	end
	return deslabelList, activePoint
end

-- weekDataList = {[1] = {time = time, weekInfoList = {[weekday] = {scheduleID, ... }, ...}}}
function CScheduleCtrl.GetWeekDataInfoList(self)
	local weekTimeList = self:GetWeekTimeList()
	local weekDataList = {}
	for _,time in ipairs(weekTimeList) do
		local infoDetail = {time = time, weekInfoList = {}}
		for _,weekper in pairs(self.m_SvrWeekDataList) do
			local scheduleIDList = {}
			for _,schedule in ipairs(weekper.daychedules) do
				if time == schedule.time then
					if #schedule.scheduleid > 1 then
						printerror("表格错误：同一时间发现两个活动")
						table.print(weekper)
					end
					for _,v in ipairs(schedule.scheduleid) do
						table.insert(scheduleIDList, v)
					end
				end
			end
			if #scheduleIDList > 0 then
				infoDetail.weekInfoList[weekper.weekday] = scheduleIDList
			end
		end
		table.insert(weekDataList, infoDetail)
	end
	return weekDataList
end

function CScheduleCtrl.GetWeekTimeList(self)
	local weekTimeList = {}
	if self.m_SvrWeekDataList then
		table.sort(self.m_SvrWeekDataList, function (a, b)
			return a.weekday < b.weekday
		end)
		for _,weekper in pairs(self.m_SvrWeekDataList) do
			for _,schedule in ipairs(weekper.daychedules) do
				if not table.index(weekTimeList, schedule.time) then
					table.insert(weekTimeList, schedule.time)
				end
			end
		end

		if #weekTimeList > 0 then
			table.sort(weekTimeList)
		end
	end
	return weekTimeList
end

function CScheduleCtrl.GetWeekDataInfoTagTip(self, time, weekID)
	local weekList = data.scheduledata.WEEK
	for _,v in ipairs(weekList) do
		if time == v.time then
			return v.tag[weekID]
		end
	end
end

function CScheduleCtrl.ScheduleDataLimitType(self, scheduleInfo)
	if scheduleInfo and scheduleInfo.type == define.Schedule.Type.Limit and g_AttrCtrl.grade >= scheduleInfo.level then
		if string.len(scheduleInfo.tipsdesc) <= 0 then
			local timeHM = g_TimeCtrl:GetTimeHM()
			local activetimes = string.split(scheduleInfo.activetime, "-")
			if #activetimes == 2 then
				if timeHM < activetimes[1] then
					return 3
				elseif timeHM > activetimes[2] then
					return 4
				else
					return 1
				end
			end
		end
	end
	return 2
end

-- [[服务器下发数据]]
function CScheduleCtrl.GS2CSchedule(self, pbdata)
	self.m_SvrHuodongList = pbdata.hdlist
	self.m_SvrActivePoint = pbdata.activepoint
	self.m_RecordSchedule.Logic.MaskIndex = pbdata.rewardidx
	self.m_SvrScheduleList = {}
	for k,v in pairs(pbdata.schedules) do
		self.m_SvrScheduleList[v.scheduleid] = v
	end
	self:CheckCompleteHdSchedules()
	self:JudgeExtraPoint()
	self:ResetLocalRedPoint()
	self:GS2CRefreshDoublePoint(pbdata.db_point, pbdata.db_point_limit)
	self:OnEvent(define.Schedule.Event.RefreshMainUI, pbdata.schedules)
end

---------------- 竞技场 欢乐骰子等特殊活动 -----------------
function CScheduleCtrl.JudgeExtraPoint(self)
	self:CheckCrapExtraPt()
	self:CheckJjcExtraPt()
	g_HeroTrialCtrl:CheckTrialInfo()
end

function CScheduleCtrl.CheckJjcExtraPt(self)
	--竞技场只要有次数剩余显示红点 --> 改成次数增加
	-- if not self.m_IsJjcNotifyLogin then
	-- 	local oJjcScheduleData = self.m_SvrScheduleList[self.m_JjcScheduleId]
	-- 	if oJjcScheduleData and g_JjcCtrl.m_GlobalLeftTimes > 0 then
	-- 		self:DelEffRecord(self.m_JjcScheduleId)
	-- 	end
	-- 	self.m_IsJjcNotifyLogin = true
	-- end
	local iScheduleId = self.m_JjcScheduleId
	local dJjc = self.m_SvrScheduleList[iScheduleId]
	if not dJjc then
		return
	end
	local dRecord = IOTools.GetRoleData("Jjc_LeftTime")
	if dRecord then
		local iRefreshTime = self:GetRefreshDayTime(dRecord.time, 5)
		if g_TimeCtrl:GetTimeS()>iRefreshTime or dRecord.val>g_JjcCtrl.m_GlobalLeftTimes then
			self:SaveJicLeftTime()
			self:CheckScheduleRecordEff({id = iScheduleId})
		elseif dRecord.val<g_JjcCtrl.m_GlobalLeftTimes and g_JjcCtrl.m_GlobalLeftTimes>0 then
			self:SaveJicLeftTime()
			self:AddRedPtEff(iScheduleId)
		end
	else
		self:SaveJicLeftTime()
		if g_JjcCtrl.m_GlobalLeftTimes > 0 then
			self:AddRedPtEff(iScheduleId)
		else
			self:CheckScheduleRecordEff({id = iScheduleId})
		end
	end
end

-- 根据给定时间获取下次刷天时间 iHour: 第几小时刷天
function CScheduleCtrl.GetRefreshDayTime(self, iTime, iHour)
    local s = tonumber(os.date("%S", iTime))
    local m = tonumber(os.date("%M", iTime))
    local h = tonumber(os.date("%H", iTime))
    local iLeft = 0
    if h >= iHour then
        iLeft = (iHour+24-h)*3600-m*60-s
    else
        iLeft = (iHour-h)*3600-m*60-s
    end
    return iTime + iLeft
end

function CScheduleCtrl.CheckCrapExtraPt(self)
	--欢乐骰子 额外的点数增加红点显示
	local scheduleID = 1017
	-- 第一次登陆时记录最大点数
	if not self.m_CurrCrapsPoint then
		local iCrapTime = IOTools.GetRoleData("schedule_CrapTime")
		if not iCrapTime then
			iCrapTime = data.scheduledata.SCHEDULE[scheduleID].maxtimes 
		end
		self.m_CurrCrapsPoint = iCrapTime
	end
	-- 再次打开日程界面判断此次点数和上次记录的点数
	local oCrapsScheduleData = self.m_SvrScheduleList[scheduleID]
	if oCrapsScheduleData then
		local bRefresh = self.m_CurrCrapsPoint < oCrapsScheduleData.maxtimes
		if self.m_CurrCrapsPoint ~= oCrapsScheduleData.maxtimes then
			self.m_CurrCrapsPoint = oCrapsScheduleData.maxtimes
			self:SaveCrapMaxTime()
			if bRefresh then
				self:AddRedPtEff(scheduleID)
			end
		end
	end
end

-- 清除id对应的红点记录，抛红点事件
function CScheduleCtrl.AddRedPtEff(self, scheduleId)
	if self.m_ScheduleEffRecord then
		for j,k in ipairs(self.m_ScheduleEffRecord) do
			if k == scheduleId then
				table.remove(self.m_ScheduleEffRecord, j)
				self:SaveScheduleEffRecord(self.m_ScheduleEffRecord)
				self:OnEvent(define.Schedule.Event.RefreshHuodong)
				break
			end
		end
	end
end

function CScheduleCtrl.SaveCrapMaxTime(self)
	IOTools.SetRoleData("schedule_CrapTime", self.m_CurrCrapsPoint)
end

function CScheduleCtrl.SaveJicLeftTime(self)
	IOTools.SetRoleData("Jjc_LeftTime", {
		time = g_TimeCtrl:GetTimeS(),
		val = g_JjcCtrl.m_GlobalLeftTimes,
	})
end

--------------------------------------------------------------

function CScheduleCtrl.GS2CRefreshSchedule(self, pbdata)
	-- if not table.index(self.m_MaskList, pbdata.schedule.scheduleid) then
	-- 	return
	-- end
	local scheduleData = self:GetScheduleData(pbdata.schedule.scheduleid)
	-- if self.m_SvrActivePoint == pbdata.activepoint and scheduleData then
	-- 	 if scheduleData.times == pbdata.schedule.times and scheduleData.activepoint == pbdata.schedule.activepoint then
	-- 		return
	-- 	end
	-- end
	self.m_SvrActivePoint = pbdata.activepoint
	-- if scheduleData then
	-- 	scheduleData.times = pbdata.schedule.times
	-- 	scheduleData.activepoint = pbdata.schedule.activepoint
	-- 	scheduleData.maxt0imes = pbdata.schedule.maxtimes
	-- else
	-- 	self.m_SvrScheduleList[pbdata.schedule.scheduleid] = pbdata.schedule
	-- end
	self:ResetLocalRedPoint()
	local scheduleId = pbdata.schedule.scheduleid
	self.m_SvrScheduleList[scheduleId] = pbdata.schedule
	self:CheckCompleteHdSchedules(scheduleId)
	if scheduleId == 1017 then --欢乐骰子
		self:CheckCrapExtraPt()
	end
	self:OnEvent(define.Schedule.Event.RefreshSchedule, pbdata.schedule)
end


function CScheduleCtrl.GS2CWeekSchedule(self, pbdata)
	--self.m_SvrWeekDataList = pbdata.weekschedule
	self.m_SvrWeekDataList = data.scheduledata.WEEK
	local allList= {}
	local signlist = {}
	local dayList = {}
	for i=1,#self.m_SvrWeekDataList[1].ActiveID do --活动段
		for j=1,#self.m_SvrWeekDataList do --活动表
			local id = self.m_SvrWeekDataList[j].ActiveID[i]
			local time = self.m_SvrWeekDataList[j].time
			local signschedule = {} --某个活动
			local signscheduleID ={}
			table.insert(signscheduleID,id)
			signschedule.scheduleid = signscheduleID
			signschedule.time = time
			if id ~= 0 then
				table.insert(dayList,signschedule)
			end
			signschedule = {}
			signscheduleID ={}
		end
		signlist.daychedules = dayList
		signlist.weekday =i
		table.insert(allList,signlist)
		signlist ={}
		dayList = {}
	end
	self.m_SvrWeekDataList = allList
	self:OnEvent(define.Schedule.Event.RefreshWeek)
end

function CScheduleCtrl.GS2CGetScheduleReward(self, maskIndex)
	self.m_RecordSchedule.Logic.MaskIndex = maskIndex
	self:ResetLocalRedPoint()
	self:OnEvent(define.Schedule.Event.RefreshReward, maskIndex)
end

-- 双倍点
function CScheduleCtrl.GS2CRefreshDoublePoint(self, db_point, db_point_limit)
	self.m_SvrDoublePoint.current = db_point
	self.m_SvrDoublePoint.limit = db_point_limit
	self:OnEvent(define.Schedule.Event.RefreshDouble)
end

function CScheduleCtrl.C2GSRewardDoublePoint(self, netcb, cb)
	-- 双倍丹道具ID
	local itemID = 10012
	if self.m_SvrDoublePoint.limit > 0 then
		if netcb then
			netcb()
		end
	else
		local itemAmount = g_ItemCtrl:GetBagItemAmountBySid(itemID)
		if itemAmount > 0 then
			-- 弹出快捷使用
			local itemList = g_ItemCtrl:GetBagItemListBySid(itemID)
			g_ItemCtrl:ItemQuickUse(itemList[1].m_ID)
			if cb then
				cb()
			end
		elseif g_WelfareCtrl:GetChargeItemInfo("gift_day_3") == 0 then
			-- 是否购买了6元礼包(跳转到礼包购买界面)
			local itemlist = {{sid = itemID, count = 0, amount = 1}}
		    g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, "购买6元礼包", function ()
				CWelfareView:ShowView(function (oView)
					oView:ForceSelPage(define.WelFare.Tab.GiftDay)
				end)
		    end)
		else
			g_NotifyCtrl:FloatMsg("当前无双倍点数可领取")
		end
	end
end

function CScheduleCtrl.GS2CRefreshHuodongState(self, hdlist)
	self.m_Hdlist = hdlist
	local index = 0
	for i,v in pairs(self.m_SvrHuodongList) do
		if v.scheduleid == hdlist.scheduleid then
			index = i
			break
		end
	end
	if index > 0 then
		self.m_SvrHuodongList[index] = hdlist
	else
		table.insert(self.m_SvrHuodongList, hdlist)
	end
	self:RefreshRectEffect( {[1]= hdlist} )
	self:OpenScheduleNotify(hdlist)
	self:OnEvent(define.Schedule.Event.RefreshHuodong)
end

function CScheduleCtrl.OpenScheduleNotify(self, hdlist)
	--两种状态下刷新活动通知 单个的GS2CRefreshHuodongState 全部的GS2CRefreshAllHuodongState
	if hdlist.state == 2 then -- 开启弹窗
		local scheduleInfo = data.scheduledata.SCHEDULE[hdlist.scheduleid]
		if not scheduleInfo then
			printerror("不存在的活动ID，检查活动表错误ID: ", hdlist.scheduleid)
			return
		end
		--等级不足，不开启弹窗
		if scheduleInfo.level > g_AttrCtrl.grade then
			return
		end
		-- -- 帮派竞赛,玩家没有帮派不开启弹窗
		-- if hdlist.scheduleid == 1025 and g_AttrCtrl.org_id == 0 then
		-- 	return
		-- end

		--帮派篝火 CBonfireCtrl.GS2CCampfirePreOpen
		if hdlist.scheduleid == 1018 then
			return
		end
		-- 画舫灯谜在场景内不弹出活动通知
		if hdlist.scheduleid == 1026 and g_MapCtrl:GetMapID()== 507000  then
			return
		end

		--年兽活动不开启弹窗
		if hdlist.scheduleid == 1036 then
			return
		end

		--节日仙子不开启弹窗
		if hdlist.scheduleid == 1037 then
			return
		end

		local args = {
			namespr = scheduleInfo.title,
			id = hdlist.scheduleid, 
			joinbtncb = callback(self,"JoinBtnCB", scheduleInfo),
		}
		self:SetNotifyViewInfo(args)

	end
end

function CScheduleCtrl.JoinBtnCB(self, ScheduleInfo)
	-- body
	--点击了参加按钮,清除限时活动的红点和环绕特效
	self:LimitClearrEffect(ScheduleInfo.id)
	self:ExcuteSchedule(ScheduleInfo)
end

function CScheduleCtrl.ExcuteSchedule(self, ScheduleInfo)
	if g_WarCtrl:IsWar() and not table.index(self.m_CouldDoInWarList, ScheduleInfo.id) then
		if not gameconfig.Issue.Releases then
			if table.index(self.m_WarLimitList, ScheduleInfo.id) then
				self:GS2COpenScheduleUI(ScheduleInfo.id)
			end
		end
        g_NotifyCtrl:FloatMsg("请脱离战斗后再进行操作")
        return
    end
	if g_AttrCtrl.grade < ScheduleInfo.level then
		g_NotifyCtrl:FloatMsg(string.format("等级不足#G%s[-],无法参加#G%s[-]", ScheduleInfo.level, ScheduleInfo.name))
		return
	end

	local iScheduleId = ScheduleInfo.id
	local bIsTeamLimit = self:CheckTeamLimit(iScheduleId)
	local bIsMapLimit = self:CheckMapLimit(iScheduleId)
	local oView = CScheduleMainView:GetView()

	if bIsMapLimit then
		g_NotifyCtrl:FloatMsg("您已在活动场景中")
		return
	end

	if bIsTeamLimit  then
		g_NotifyCtrl:FloatMsg("您在队伍中,不能操作")
		if not oView then
			self:GS2COpenScheduleUI(ScheduleInfo.id)
		end
		return
	end

	if ScheduleInfo.id == 1008 then
		local taskTypeDic = g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.ORG.ID]
		local _, oTask = next(taskTypeDic)
		if oTask then
			CTaskHelp.ClickTaskLogic(oTask)
		else
			nethuodong.C2GSOrgTaskFindNPC()
		end	
		return
	end

	-- 请求协议参加活动 RequestServer（1、寻人 2、跳转 3、任务 4、UI 5、帮派场景）
	if ScheduleInfo.opentype == 1 then
		if ScheduleInfo.id == 1036 then
			g_NianShouCtrl:WalkToNianShouNpc()
		elseif ScheduleInfo.id == 1038 then
			nethuodong.C2GSLuanShiMoYing()
		elseif ScheduleInfo.id == 1043 then  
			if g_TeamCtrl:IsInTeam() then 
				g_NotifyCtrl:FloatMsg("组队中无法前往")
				return
			else
				netopenui.C2GSFindHDNpc()
			end 
		else
			if ScheduleInfo.id == 1025 and g_AttrCtrl.org_id == 0 then
				if not oView then
					self:GS2COpenScheduleUI(ScheduleInfo.id)
				else
					g_OrgCtrl:OpenOrgView()
				end
				return
			end
			g_MapTouchCtrl:WalkToGlobalNpc(ScheduleInfo.openid)
		end 
	elseif ScheduleInfo.opentype == 2 then
		local mapID = ScheduleInfo.openid
		if ScheduleInfo.id == 1003 then
			nethuodong.C2GSFengYaoAutoFindNPC() --野外镇妖自动寻路
		elseif ScheduleInfo.id == 1014 then
			local sealNpcMapInfo = DataTools.GetSealNpcMapInfo(g_AttrCtrl.grade)
			if not sealNpcMapInfo then
				return
			end
			mapID = sealNpcMapInfo.mapid
			g_MapCtrl:C2GSClickWorldMap(mapID)
		end
	elseif ScheduleInfo.opentype == 3 then
		CTaskHelp.ScheduleTaskLogic(ScheduleInfo.openid)
	elseif ScheduleInfo.opentype == 4 then
		-- UI(打开UI界面，具体做法待定（1、传入功能ID，通过if判断|维护一个View表，id对应view名称，直接showview）)
		printc(" >>> TODO 打开相应UI界面，具体逻辑@相关模块客户端")
		if ScheduleInfo.id == 1007 then
			--跳舞允许操作
			-- if g_DancingCtrl.m_StateInfo then
			--    g_NotifyCtrl:FloatMsg("你正在舞会中，不可挑战")
			--    return
			-- end
			if g_BonfireCtrl.m_IsBonfireScene and (g_BonfireCtrl.m_CurActiveState == 2 or g_BonfireCtrl.m_CurActiveState == 1) then
			   g_NotifyCtrl:FloatMsg("你正在帮派篝火活动中，不可挑战")
			   return
			end
			g_JjcCtrl:OpenJjcMainView()
		elseif ScheduleInfo.id == 1017 then -- 摇骰子
			nethuodong.C2GSShootCrapOpen()
		elseif ScheduleInfo.id == 1019 then
			nethuodong.C2GSMengzhuMainUI()
		elseif ScheduleInfo.id == 1012 or ScheduleInfo.id == 1023 then
			netopenui.C2GSFindHDNpc()  --三界斗法or六脉会武寻路
		elseif ScheduleInfo.id == 1016 then --跳舞寻路
			nethuodong.C2GSDanceAuto()
			--战斗依然可以答题
		elseif 	ScheduleInfo.id == 1021 then

			g_BaikeCtrl:ShowView()
			if not g_BaikeCtrl.m_dataList then
				nethuodong.C2GSBaikeOpenUI()
			end
			--netopenui.C2GSOpenInterface(2)
		elseif ScheduleInfo.id == 1022 then --灵犀任务
			nethuodong.C2GSLingxiPaticipate()
		elseif ScheduleInfo.id == 1026 then
			g_GuessRiddleCtrl:C2GSHfdmEnter()
		elseif ScheduleInfo.id == 1027 then
			g_HeroTrialCtrl:C2GSTrialOpenUI()
		end

	elseif ScheduleInfo.opentype == 5 then
		if g_AttrCtrl.org_id == 0 then
			g_NotifyCtrl:FloatMsg("您当前没有帮派，快去加入一个帮派吧！")
			g_OrgCtrl:OpenOrgView()
			return
		end
		nethuodong.C2GSEnterOrgHuodong(ScheduleInfo.flag)
	elseif ScheduleInfo.opentype == 0 then 
		nethuodong.C2GSSchoolPassClickNpc()
	end
end

function CScheduleCtrl.CheckTeamLimit(self, scheduleid)
	return table.index(self.m_MemberLimitList, scheduleid) and g_TeamCtrl:IsInTeam() and not g_TeamCtrl:IsLeader()

	-- g_NotifyCtrl:FloatMsg("您在队伍中,不能操作")
	-- self:GS2COpenScheduleUI(ScheduleInfo.id)
end

function CScheduleCtrl.CheckMapLimit(self, scheduleid)
		-- g_NotifyCtrl:FloatMsg("您已在活动场景中")
	return table.index(self.m_MapLimitList, scheduleid) and g_MapCtrl:IsInHuodongMap()
end

function CScheduleCtrl.SetNotifyViewInfo(self, args)

	if g_EngageCtrl.m_EngageStatus or g_MarryPlotCtrl:IsPlayingWeddingPlot() then return end

	local notifyinfo = {
		namespr     = args.namespr or nil,
		scheduleid 	= args.id or 1001,
		joinbtncb 	= args.joinbtncb ,
		time 		= args.time or 60,
	}

	CScheduleNotifyView:ShowView(function (oView)
		oView:SetNotifyViewInfo(notifyinfo)
	end)
end

-- 登陆时下发所有数据
function CScheduleCtrl.GS2CRefreshAllHuodongState(self, hdlist)
	-- body
	self.m_SvrHuodongList = hdlist
	self:RefreshRectEffect(hdlist)
	self:OnEvent(define.Schedule.Event.RefreshHuodong)
end

function CScheduleCtrl.GS2COpenScheduleUI(self, scheduleid)
	CScheduleMainView:ShowView(function (oView)
		if scheduleid and scheduleid ~= 0 then
			oView:JumpToSchedule(scheduleid)
		end
	end)
end

--------------每日任务相关-------------

function CScheduleCtrl.GS2CAllEverydayTaskInfo(self, pbdata)
	self.m_DayTaskData = {}
	for k,v in pairs(pbdata.all) do
		table.insert(self.m_DayTaskData, v)
	end
	self:SortDayTaskData()
	self:OnEvent(define.Schedule.Event.RefreshDayTask)
	--table.print(pbdata, "CScheduleCtrl.GS2CAllEverydayTaskInfo")
end

function CScheduleCtrl.GS2CUpdateEverydayTasks(self, pbdata)
	for k,v in pairs(pbdata.updates) do
		self:CheckDayTaskData(v)
	end
	self:SortDayTaskData()
	self:OnEvent(define.Schedule.Event.RefreshDayTask)
	--table.print(pbdata, "CScheduleCtrl.GS2CUpdateEverydayTasks")
end

function CScheduleCtrl.SortDayTaskData(self)
	table.sort(self.m_DayTaskData, function (a, b)
		local state1 = 3
		local state2 = 3
		if a.cur_cnt >= a.max_cnt and a.rewarded == 0 then
			state1 = 1
		elseif a.cur_cnt < a.max_cnt then
			state1 = 2
		elseif a.cur_cnt >= a.max_cnt and a.rewarded == 1 then
			state1 = 3
		end
		if b.cur_cnt >= b.max_cnt and b.rewarded == 0 then
			state2 = 1
		elseif b.cur_cnt < b.max_cnt then
			state2 = 2
		elseif b.cur_cnt >= b.max_cnt and b.rewarded == 1 then
			state2 = 3
		end
		if state1 ~= state2 then
			return state1 < state2
		else
			return a.taskid < b.taskid
		end
	end)
end

function CScheduleCtrl.CheckDayTaskData(self, dayTaskData)
	local isExist = false
	for k,v in pairs(self.m_DayTaskData) do
		if v.taskid == dayTaskData.taskid then
			isExist = true
			table.remove(self.m_DayTaskData, k)
			table.insert(self.m_DayTaskData, k, dayTaskData)
			break
		end
	end
	if not isExist then
		table.insert(self.m_DayTaskData, dayTaskData)
	end
end

function CScheduleCtrl.GetIsShowDayTaskRedPoint(self)
	for k,v in pairs(self.m_DayTaskData) do
		if v.cur_cnt < v.max_cnt or (v.cur_cnt >= v.max_cnt and v.rewarded == 0) then
			if not self.m_IsRedPointRead then
				return true
			end
		end
	end
	return false
end

function CScheduleCtrl.LimitClearrEffect(self, scheduleid)
	--通过 活动通知 进入活动清除环绕特效 清除红点
	if self:IsUnExistEffRecordID(scheduleid) then
		table.insert(self.m_ScheduleEffRecord, scheduleid)
		self:SaveScheduleEffRecord(self.m_ScheduleEffRecord)
		self:OnEvent(define.Schedule.Event.RefreshUITip, scheduleid)
	end
	if self.m_RectEffRecord[scheduleid] then
		self.m_RectEffRecord[scheduleid] = false
		table.insert(self.m_RectEffIds, scheduleid)
		self:SaveRectEffRecord()
		self:OnEvent(define.Schedule.Event.ClearEffect, scheduleid)
	end
end

------------------贴心管家相关-------------------

function CScheduleCtrl.GetStopNotifyActivity(self)
	self.m_StopNotifyActivityList = {}
	for k,v in pairs(data.scheduledata.SCHEDULE) do
		if v.stopnotify ~= 0 then
			table.insert(self.m_StopNotifyActivityList, v.id)
		end
	end
	table.sort(self.m_StopNotifyActivityList, function (a, b)
		return data.scheduledata.SCHEDULE[a].stopnotify < data.scheduledata.SCHEDULE[b].stopnotify
	end)
end

--贴心管家显示的倒计时
function CScheduleCtrl.SetStopNotifyTime(self, setTime)
	-- if not g_OpenSysCtrl:GetOpenSysState(define.System.Tiexin) then
	-- 	return
	-- end
	-- if g_AttrCtrl.grade >= data.scheduledata.STOPNOTIFY[1].grade then
	-- 	return
	-- end
	-- if g_WarCtrl:IsWar() then
	-- 	return
	-- end
	-- if g_MapCtrl:CheckIsInActivityMap() then
	-- 	return
	-- end
	-- if not g_GuideCtrl:IsGuideDone() then
	-- 	return
	-- end
	
	self:ResetStopNotifyTimer()
	local function progress()
		if g_AttrCtrl.pid == 0 then
			g_ScheduleCtrl:SetStopNotifyTime()
			return false
		end
		if not g_SystemSettingsCtrl.m_OnOff[6] then
			g_ScheduleCtrl:SetStopNotifyTime()
			return false
		end
		if not g_OpenSysCtrl:GetOpenSysState(define.System.Tiexin) then
			return false
		end
		if g_AttrCtrl.grade >= data.scheduledata.STOPNOTIFY[1].grade then
			return false
		end
		if g_WarCtrl:IsWar() then
			return false
		end
		if not g_GuideCtrl:IsGuideDone() then
			return false
		end
		if g_TeamCtrl:IsJoinTeam() and (not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave()) then
			return false
		end
		if g_MapCtrl:CheckIsInActivityMap() then
			return false
		end
		if UnityEngine.Input.anyKey then
			g_ScheduleCtrl:SetStopNotifyTime()
			return false
		end
		g_ScheduleCtrl:GetStopNotityDataList()
		if not next(g_ScheduleCtrl.m_StopNotifyActualList) then
			printc("当前没有活动可参加，不弹出贴心管家界面")
			return false
		end		
		CRestNotifyView:ShowView()
		return false
	end
	self.m_StopNotifyTimer = Utils.AddTimer(progress, 0, data.scheduledata.STOPNOTIFY[1].waittime)
end

function CScheduleCtrl.ResetStopNotifyTimer(self)
	if self.m_StopNotifyTimer then
		Utils.DelTimer(self.m_StopNotifyTimer)
		self.m_StopNotifyTimer = nil			
	end
end

function CScheduleCtrl.GetStopNotityDataList(self)
	self.m_StopNotifyEveryDataList = {}
	self.m_StopNotifyLimitDataList = {}
	local scheduleDataList1 = g_ScheduleCtrl:GetScheduleByType(define.Schedule.Type.Every, true)
	local scheduleDataList2 = g_ScheduleCtrl:GetScheduleByType(define.Schedule.Type.Limit, true)
	for k,v in pairs(scheduleDataList1) do
		self.m_StopNotifyEveryDataList[v.id] = v
	end
	for k,v in pairs(scheduleDataList2) do
		self.m_StopNotifyLimitDataList[v.id] = v
	end
	self.m_StopNotifyActualList = {}
	for k,v in ipairs(self.m_StopNotifyActivityList) do
		if self.m_StopNotifyEveryDataList[v] or self.m_StopNotifyLimitDataList[v] then
			if #self.m_StopNotifyActualList < 4 then
				table.insert(self.m_StopNotifyActualList, v)
			else
				break
			end
		end
	end
	return self.m_StopNotifyActualList
end

function CScheduleCtrl.RefreshRectEffect(self, hdlist)
	-- body
	for i,v in ipairs(hdlist) do
		if v.state == 2 and not table.index(self.m_RectEffIds, v.scheduleid) then
			self.m_RectEffRecord[v.scheduleid] = true 
		else
			self.m_RectEffRecord[v.scheduleid] = false 
		end
	end
end

function CScheduleCtrl.IsExistRectEffect(self)

	local IsExistRectEff = false
	for i,v in pairs(self.m_RectEffRecord) do
		if v then
			local oSchedule = data.scheduledata.SCHEDULE[i]
			if g_AttrCtrl.grade >= oSchedule.level and self:IsKfShow(i) then
				IsExistRectEff = true
				break
			end
		end
	end

	return IsExistRectEff
end

function CScheduleCtrl.TodayExistIDScheudle(self, id) --判断今天是否有ID活动
	-- body
	local Exist = false
	for _,v in ipairs(self.m_SvrHuodongList) do
		if v.scheduleid == id then
			Exist = true
			break
		end
	end
	local normallist = self:GetScheduleByType(define.Schedule.Type.Normal)
	for i,v in ipairs(normallist) do
		if id == v.id then
			Exist = true
 			break
		end
	end
	return Exist
end

function CScheduleCtrl.IsIntPointSchedule(self, scheduleid)
	-- body
	local isIntPoint = false
	for i,v in ipairs(self.m_IntPointSchedule) do
		if scheduleid ==  v then
			isIntPoint = true
		end
	end
	return isIntPoint
end

-- 检测活动完成状态，去除红点
function CScheduleCtrl.CheckCompleteHdSchedules(self, scheduleId)
	local checkFunc = function(id)
		local d = self.m_SvrScheduleList[id]
		if d and d.maxtimes and d.maxtimes > 0 then
			if d.times and d.times >= d.maxtimes and self:IsUnExistEffRecordID(id) then
				table.insert(self.m_ScheduleEffRecord, id)
				return true
			end
		end
		return false
	end
	local bRefresh = false
	if scheduleId then
		bRefresh = checkFunc(scheduleId)
	else -- 检测全部
		for k, d in pairs(self.m_SvrScheduleList) do
			local b = checkFunc(k)
			if not bRefresh and b then
				bRefresh = b
			end
		end
	end
	if bRefresh then
		self:SaveScheduleEffRecord(self.m_ScheduleEffRecord)
	end
end

function CScheduleCtrl.SaveRectEffRecord(self)
	IOTools.SetRoleData("schedule_RectEff", self.m_RectEffIds)
end

function CScheduleCtrl.DelRectEff(self, id)
	if self.m_RectEffRecord[id] then
		self.m_RectEffRecord[id] = false
		if not table.index(self.m_RectEffIds, id) then
			table.insert(self.m_RectEffIds, id)
			self:SaveRectEffRecord()
		end
	end
end

--是否在预告面板中隐藏
function CScheduleCtrl.IsHideNoticePage(self, id)
	
	local oSchedule = self:GetScheduleInfo(id)
	if oSchedule then 
		return  oSchedule.isHideNoticePage == 1
	end 

end

function CScheduleCtrl.GetNotifySchedule(self)
	local dFilterSchedule = {[1037] = true}

	local lOpenHuodong = {}
	for i,v in ipairs(self.m_SvrHuodongList) do
		local dScheduleInfo = data.scheduledata.SCHEDULE[v.scheduleid]
		if v.state == 2 and g_AttrCtrl.grade >= dScheduleInfo.level and 
			self:IsKfShow(v.scheduleid) and not dFilterSchedule[v.scheduleid] then
			table.insert(lOpenHuodong, v)
		end
	end
	local function sort(hd_1, hd_2)
		local dSchedule_1 = data.scheduledata.SCHEDULE[hd_1.scheduleid]
		local dSchedule_2 = data.scheduledata.SCHEDULE[hd_2.scheduleid]
		if hd_1.time == hd_2.time then
			return dSchedule_1.sort < dSchedule_2.sort
		end
		return hd_1.time > hd_2.time
	end
	table.sort(lOpenHuodong, sort)
	return lOpenHuodong[1]
end

-- 是否显示(跨服)
function CScheduleCtrl.IsKfShow(self, iScheduleId)
	local bKuafu = g_KuafuCtrl:IsInKS()
	if not bKuafu then
		return true
	end
	local dSchedule = data.scheduledata.SCHEDULE[iScheduleId] or {}
	return dSchedule.show_ks == 1
end

return CScheduleCtrl


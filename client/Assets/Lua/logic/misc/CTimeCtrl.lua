local CTimeCtrl = class("CTimeCtrl", CDelayCallBase)

function CTimeCtrl.ctor(self)
	CDelayCallBase.ctor(self)
	self.m_LocalTimeSinceStartup = UnityEngine.Time.realtimeSinceStartup
	self.m_BeatDelta = 10
	self.m_ServerTime = os.time()
	self.m_BeatTimer = nil
	self.m_LastStartTickMS = C_api.Timer.GetTickMS()
	self.m_Watchs = {}
end

function CTimeCtrl.StartWatch(self)
	local i = #self.m_Watchs
	local oWatch
	if i > 0 then
		oWatch = self.m_Watchs[i]
		table.remove(self.m_Watchs, i)
	else
		oWatch = CWatch.New()
	end
	oWatch:Start()
	return oWatch
end

function CTimeCtrl.StopWatch(self, oWatch)
	table.insert(self.m_Watchs, oWatch)
	return oWatch:Stop()
end

function CTimeCtrl.ServerHelloTime(self, iTimeS)
	self:SyncServerTime(iTimeS)
	-- g_ScheduleCtrl:AutoCheckSchedule()
end

function CTimeCtrl.ReciveServerBeat(self)
	self:StopDelayCall("HeartTimeOut")
	print("HeartBeat->心跳包检测正常")
end

function CTimeCtrl.HeartBeat(self)
	if g_NetCtrl:GetNetObj() == nil then
		self:StopBeat()
		return false
	end
	netother.C2GSHeartBeat()
	self.m_ReciveBeatTime = nil
	self:DelayCallNotReplace(70, "HeartTimeOut")
	return true
end

function CTimeCtrl.HeartTimeOut(self)
	print("HeartBeat-->心跳包检测超时")
	self:StopBeat()
	g_NetCtrl:AutoReconnect()
end

function CTimeCtrl.IsBeating(self)
	return self.m_BeatTimer ~= nil
end

function CTimeCtrl.StartBeat(self)
	self:StopBeat()
	print("HeartBeat-->开启心跳包检测")
	self.m_BeatTimer = Utils.AddTimer(callback(self, "HeartBeat"), self.m_BeatDelta, 0)
end

function CTimeCtrl.StopBeat(self)
	if self.m_BeatTimer then
		Utils.DelTimer(self.m_BeatTimer)
		self.m_BeatTimer = nil
	end
	self.m_ReciveBeatTime = nil
	self:StopDelayCall("HeartTimeOut")
end

function CTimeCtrl.SyncServerTime(self, iTimeS)
	self.m_LocalTimeSinceStartup = UnityEngine.Time.realtimeSinceStartup
	self.m_ServerTime = iTimeS
	print("同步服务器时间", self:Convert(self.m_ServerTime))
end

-- 检查是否刷天
function CTimeCtrl.CheckNextDay(self)
	if not self.m_ServerTime then
		return
	end
	local oH = os.date("%H", self.m_ServerTime)
	local seconds = self:GetTimeS()
	local nH = os.date("%H",seconds)
	if oH == 4 and nH == 5 then
		printc("--->>> 刷天啦")
		-- 抛出刷天事件，参数（事件ID，当前服务器时间），相应模块各自处理
		-- netopenui.C2GSOpenScheduleUI()
		self:OnEvent(define.Time.Event.NextDay, self.m_ServerTime)
	end
end

function CTimeCtrl.GetTimeS(self)
	local iSpanS = UnityEngine.Time.realtimeSinceStartup - self.m_LocalTimeSinceStartup
	return math.floor(iSpanS) + self.m_ServerTime
end

function CTimeCtrl.GetTimeMS(self)
	local iSpanMS = UnityEngine.Time.realtimeSinceStartup - self.m_LocalTimeSinceStartup
	return math.floor((iSpanMS + self.m_ServerTime) * 1000)
end

function CTimeCtrl.GetTimeYMD(self)
	local seconds = self:GetTimeS()
	return self:Convert(seconds)
end

function CTimeCtrl.Convert(self, seconds)
	return os.date("%Y/%m/%d %H:%M:%S", seconds)
end

function CTimeCtrl.GetTimeMDHM(self, iSec)
	local date = os.date("*t", iSec)
	local m, d, h, min = date.month, date.day, date.hour, date.min
	if min == 0 then
		min = "00"
	end
	local text = m.."月"..d.."日"..h..":"..min
	return text
end

function CTimeCtrl.GetTimeHM(self)
	local seconds = self:GetTimeS()
	return os.date("%H:%M",seconds)
end

function CTimeCtrl.GetTimeHMS(self)
	local seconds = self:GetTimeS()
	return os.date("%H:%M:%S",seconds)
end

function CTimeCtrl.GetTimeWeek(self)
	local seconds = self:GetTimeS()
	return os.date("%w", seconds)
end

function CTimeCtrl.GetTimeInfo(self, iSec)
	iSec = math.floor(iSec)
	return {
		hour = math.floor(iSec / 3600),
		min = math.floor((iSec % 3600) / 60),
		sec = iSec % 60,
	}
end

function CTimeCtrl.GetLeftTime(self, iSec, bShowHour)
	iSec = math.floor(iSec)
	
	local hour = math.modf(iSec / 3600)
	local min = math.floor((iSec % 3600) / 60)
	local sec = iSec % 60
	if hour > 0 then
		return string.format("%d:%02d:%02d", hour, min, sec)
	elseif bShowHour then
		return string.format("00:%02d:%02d", min, sec)
	else
		return string.format("%02d:%02d", min, sec)
	end
end

function CTimeCtrl.GetLeftTimeString(self, iSec)
	iSec = math.floor(iSec)
	
	local hour = math.modf(iSec / 3600)
	local min = math.floor((iSec % 3600) / 60)
	local sec = iSec % 60
	if hour > 0 then
		return string.format("%d小时%02d分钟%02d秒", hour, min, sec)
	elseif min > 0 then
		return string.format("%02d分钟%02d秒", min, sec)
	else
		return string.format("%02d秒", sec)
	end
end

-- 不显示秒数情况下需特殊判断处理
function CTimeCtrl.GetLeftTimeDHM(self, iSec)
	local day = math.floor(iSec / (3600 * 24), true) 
	local hour = math.floor((iSec / 3600) % 24, true)
	local min = math.ceil((iSec / 60) % 60, true)

	if min == 60 then
		min = 0
		hour = hour + 1
		if hour == 24 then
			hour = 0
			day = day + 1
		end
	end

	if day > 0 then
		if hour == 0 and min == 0 then
			return string.format("%d天", day)
		elseif min == 0 then
			return string.format("%d天%d小时", day, hour)
		end
		return string.format("%d天%d小时%d分钟", day, hour, min)
	elseif hour > 0 then
		if min == 0 then
			return string.format("%d小时", hour)
		end
		return string.format("%d小时%d分钟", hour, min)
	elseif min then
		return string.format("%d分钟", min)
	end 
end

-- 不显示秒数情况下需特殊判断处理
function CTimeCtrl.GetLeftTimeHM(self, iSec)
	local hour = math.floor((iSec / 3600) % 24, true)
	local min = math.ceil((iSec / 60) % 60, true)  --分时向下取整, 避免23小时60分这样的情况(处理)

	if min == 60 then
		min = 0
		hour = hour + 1
	end

	if hour > 0 then
		if hour == 0 and min == 0 then
			return string.format("%d天", day)
		elseif min == 0 then
			return string.format("%d小时", hour)
		end
		return string.format("%d小时%d分钟", hour, min)
	elseif min >= 1 then
		return string.format("%d分钟", min)
	end 
end

-- 不显示秒数情况下需特殊判断处理
function CTimeCtrl.GetLeftTimeDHMAlone(self, iSec, bShowSec)
	local day = math.floor(iSec / (3600 * 24), true) 
	local hour = math.floor((iSec / 3600) % 24, true)
	local min = math.ceil((iSec / 60) % 60, true)

	if not bShowSec then
		if min == 60 then
			min = 0
			hour = hour + 1
			if hour == 24 then
				hour = 0
				day = day + 1
			end
		end
	end

	if day > 0 then 
		return string.format("%d天", day)
	elseif hour > 0 then 
		return string.format("%d小时", hour)
	elseif min >= 1 then 
		if min == 1 and bShowSec then
			return string.format("%d秒", iSec)
		end
		return string.format("%d分钟", min)
	end 
end

--开始倒计时 type 1 DHM  2, HM , 3, DHMALONE, 4,00:00:00
function CTimeCtrl.StartCountDown(self, own, leftTime, timeType, cb)

	if own.m_Timer_ then 
	    Utils.DelTimer(own.m_Timer_)
        own.m_Timer_ = nil
	end 
	
	local refreshTime = function ()

		if Utils.IsNil(own) then 
			own.m_Timer_ = nil
			return false
		end 

		if not leftTime or leftTime <= 0 then 
			if cb then 
				cb()
			end 
			return false
		end 
		
		leftTime = leftTime - 1

		if leftTime > 0 then 

			local timeText = nil

			if timeType == 1 then 
				timeText = self:GetLeftTimeDHM(leftTime)
			elseif timeType == 2 then 
				timeText = self:GetLeftTimeHM(leftTime)
			elseif timeType == 3 then 
				timeText = self:GetLeftTimeDHMAlone(leftTime)
			elseif timeType == 4 then
				timeText = self:GetLeftTime(leftTime)
			end  

			if cb then 
				cb(timeText, leftTime)
			end 
			return true

		else
			own.m_Timer_ = nil
			if cb then 
				cb()
			end 
			return false
		end

	end 

	if not own.m_Timer_ then 
		own.m_Timer_ = Utils.AddTimer(refreshTime, 1, 0)
	end 

end

function CTimeCtrl.DelTimer(self, own)
	
	if own.m_Timer_ then 
	    Utils.DelTimer(own.m_Timer_)
        own.m_Timer_ = nil
	end 

end


function CTimeCtrl.IsToday(self, iSec)
	local t = os.date("*t", iSec)
	local curt = os.date("*t", self:GetTimeS())
	if t["day"] ~= curt["day"] then
		return false
	elseif t["month"] ~= curt["month"] then
		return false
	elseif t["year"] ~= curt["year"] then
		return false
	end
	return true
end

function CTimeCtrl.StartCheckClientStatus(self)
	self:StopCheckClientStatus()
	local function SendRequest()
		if g_TeamCtrl:IsLeader() then
			if g_TeamCtrl:IsLeaderTouchUI() or g_WarCtrl:IsWar() then
				netother.C2GSSetActive(1)
				g_TeamCtrl:SetLeaderTouchUI(false)
			end
		end
		return true
	end
	self.m_StatusTimer = Utils.AddTimer(SendRequest, 60, 10)
end

function CTimeCtrl.StopCheckClientStatus(self)
	if self.m_StatusTimer then
		Utils.DelTimer(self.m_StatusTimer)
		self.m_StatusTimer = nil
	end
end
return CTimeCtrl
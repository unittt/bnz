local CStatsBox = class("CStatsBox", CBox)


function CStatsBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_LabelClone = self:NewUI(2, CLabel)
	self.m_FpsLabel = self:NewUI(3, CLabel)
	self.m_SysLabel = self:NewUI(4, CLabel)
	self.m_LabelClone:SetActive(false)
	self.m_StatsMemoryTimer = nil
	self.m_FPSTimer = nil
	self.m_CntTimer = nil

	self.m_Accum = 0
	self.m_Frames = 0
	g_NotifyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	self:RefreshSystemInfo()

end

function CStatsBox.RefreshSystemInfo(self)
	
	local infoList = {
		{name = "CPU_Speed: ", value = tostring(UnityEngine.SystemInfo.processorFrequency)},
		{name = "CPU_Count: ", value = tostring(UnityEngine.SystemInfo.processorCount)},
		{name = "CPU_Name: ", value = tostring(UnityEngine.SystemInfo.processorType)},
		{name = "GPU_Name: ", value = tostring(UnityEngine.SystemInfo.graphicsDeviceName)},
		{name = "GPU_Type: ", value = tostring(UnityEngine.SystemInfo.graphicsDeviceType)},
		{name = "GPU_MemorySize: ", value = tostring(UnityEngine.SystemInfo.graphicsMemorySize)},
		{name = "SYS_MemorySize: ", value = tostring(C_api.PlatformAPI.getTotalMemory()/1024)},
		{name = "机器型号: ", value = tostring(UnityEngine.SystemInfo.deviceModel)},
		{name = "特效等级: ", value = tostring(g_SystemSettingsCtrl:GetRenderLv())},
	}

	local infoStr = nil
	for k, v in ipairs(infoList) do
		local str = "[00ff00]" .. v.name .. "[-]" .. v.value
		if not infoStr then 
			infoStr = str
		else
			infoStr = infoStr .. "\n" ..str 
		end
	end 

	self.m_SysLabel:SetText(infoStr)

end

function CStatsBox.SetStatsInfo(self, open)
	self:SetActive(open)
	if open then
		if self.m_StatsMemoryTimer then
			Utils.DelTimer(self.m_StatsMemoryTimer)
		end
		self.m_StatsMemoryTimer = Utils.AddTimer(callback(self, "RefreshMoneyInfo"), 5, 0)

		if self.m_FPSTimer then
			Utils.DelTimer(self.m_FPSTimer)
		end
		self.m_FPSTimer = Utils.AddTimer(callback(self, "RefreshFPSInfo"), 0.5, 0)

		if self.m_CntTimer then
			Utils.DelTimer(self.m_CntTimer)
		end 
		self.m_CntTimer =  Utils.AddTimer(callback(self, "RefreshCntInfo"), 0.5, 0)
	end
end

function CStatsBox.RefreshMoneyInfo(self, dt)
	local infoList = {
		{name = "LuaUsedSize: ", value = string.format("%0.2f", collectgarbage("count")/1024)},
		{name = "空闲内存: ", value = tostring(C_api.PlatformAPI.getFreeMemory()/1024)},
		{name = "总内存: ", value = tostring(C_api.PlatformAPI.getTotalMemory()/1024)},
	}
	if Utils.IsEditor() then
	local t = {
			{name = "UseHeapSize: ", value = string.format("%0.2f", UnityEngine.Profiler.usedHeapSize)},
			{name = "MonoUsedSize: ", value = string.format("%0.2f", UnityEngine.Profiler.GetMonoUsedSize())},
			{name = "MonoHeapSize: ", value = string.format("%0.2f", UnityEngine.Profiler.GetMonoHeapSize())},
		}
		for _,v in ipairs(t) do
			table.insert(infoList, v)
		end
	end

	self._InfoLlist = infoList
	local gridList = self.m_Grid:GetChildList()
	for i,v in ipairs(infoList) do
		local oLabel = nil
		if i > #gridList then
			oLabel = self.m_LabelClone:Clone()
			self.m_Grid:AddChild(oLabel)
			oLabel:SetActive(true)
		else
			oLabel = gridList[i]
		end
		oLabel:SetText(v.name .. v.value .. " MB")
	end
	return true
end

function CStatsBox.RefreshFPSInfo(self, dt)
	local fps = self.m_Accum / self.m_Frames
	local fpsColor = fps >= 30 and "[00ff00]" or fps >= 10 and "[ffff00]" or "[ff0000]"
	self.m_Accum = 0
	self.m_Frames = 0
	self.m_FpsLabel:SetText(fpsColor .."FPS: " .. string.format("%0.2f", fps))
	return true
end

function CStatsBox.RefreshCntInfo(self)
	
	if not self._InfoLlist then 
		return true
	end 

	local cntInfoList = {
		{name = "人数: ", value = string.format("%d/%d", g_MapPlayerNumberCtrl:GetSameScrPalyerCnt(), g_MapPlayerNumberCtrl:GetAllPlayCnt())},
		{name = "坐骑: ", value = string.format("%d/%d", g_MapPlayerNumberCtrl:GetSameScrRideCnt(), g_MapPlayerNumberCtrl:GetAllRideCnt())},
		{name = "宠物: ", value = string.format("%d/%d", g_MapPlayerNumberCtrl:GetSameScrSummonCnt(), g_MapPlayerNumberCtrl:GetAllSummonCnt())},
		{name = "翅膀: ", value = string.format("%d/%d", g_MapPlayerNumberCtrl:GetSameScrWingCnt(), g_MapPlayerNumberCtrl:GetAllWingCnt())},
		{name = "npc: ", value = string.format("%d", g_MapPlayerNumberCtrl:GetInScrNpc())},
	}

	local offset = #self._InfoLlist
	local gridList = self.m_Grid:GetChildList()
	for i,v in ipairs(cntInfoList) do
		local oLabel = nil
		if (i + offset) > #gridList then
			oLabel = self.m_LabelClone:Clone()
			self.m_Grid:AddChild(oLabel)
			oLabel:SetActive(true)
		else
			oLabel = gridList[i + offset]
		end
		oLabel:SetText(v.name .. v.value)
	end
	return true

end

function CStatsBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Notify.Event.Update then
		self.m_Accum = self.m_Accum + UnityEngine.Time.timeScale / UnityEngine.Time.deltaTime
		self.m_Frames = self.m_Frames + 1
	end
end

return CStatsBox


local CMapWalkerLoadCtrl = class("CMapWalkerLoadCtrl")

CMapWalkerLoadCtrl.LoadState = {
	Waiting = 1,
	Done = 2,
	Delete = 3,
}

CMapWalkerLoadCtrl.walkerType = {
	Player = 1,
	Npc = 2,
}

function CMapWalkerLoadCtrl.ctor(self)
	self.m_LoadTimer = nil
	self.m_LoadList = {}
	self.m_LoadStateDict = {}
	self.m_CacheProtoDict = {}
	self.m_LoadLimitCnt = 5
end

function CMapWalkerLoadCtrl.IsWaitingLoad(self, eid)
	return self.m_LoadStateDict[eid] and self.m_LoadStateDict[eid] == CMapWalkerLoadCtrl.LoadState.Waiting
end

function CMapWalkerLoadCtrl.StartLoadTimer(self)
	self:StopLoadTimer()
	self.m_LoadTimer = Utils.AddTimer(callback(self, "LoadWalker"), 0.1, 0.01)
end

function CMapWalkerLoadCtrl.StopLoadTimer(self)
	if self.m_LoadTimer then
		Utils.DelTimer(self.m_LoadTimer)
		self.m_LoadTimer = nil
	end
end

function CMapWalkerLoadCtrl.AddWalker(self, eid, aoiInfo, walkerType)
	if self:IsWaitingLoad(eid) then
		return
	end
	local dWalkerInfo = {eid = eid, aoiInfo = aoiInfo, walkerType = walkerType}
	if walkerType == CMapWalkerLoadCtrl.walkerType.Npc then
		table.insert(self.m_LoadList, 1, dWalkerInfo)
	else
		table.insert(self.m_LoadList, dWalkerInfo)
	end
	self.m_LoadStateDict[eid] = CMapWalkerLoadCtrl.LoadState.Waiting
	if not self.m_LoadTimer then
		self:StartLoadTimer()
	end
end

function CMapWalkerLoadCtrl.DelWalker(self, eid)
	self.m_LoadStateDict[eid] = CMapWalkerLoadCtrl.LoadState.Delete
end

function CMapWalkerLoadCtrl.AddCacheProto(self, eid, protoName, ...)
	local dProtoInfo = {}
	dProtoInfo.proto = protoName
	dProtoInfo.args = {...}
	if not self.m_CacheProtoDict[eid] then
		self.m_CacheProtoDict[eid] = {}
	end
	table.insert(self.m_CacheProtoDict[eid], dProtoInfo)
end

function CMapWalkerLoadCtrl.DelCacheProto(self, eid)
	self.m_CacheProtoDict[eid] = nil
end

function CMapWalkerLoadCtrl.LoadWalker(self)
	if #self.m_LoadList == 0 then
		return true
	end
	local iLoadCnt = 0
	while true do
		local dWalkerInfo = self.m_LoadList[1]
		if not dWalkerInfo then
			-- self:StopLoadTimer()
			return true
		end
		local eid = dWalkerInfo.eid
		if self:IsWaitingLoad(eid) then
			local aoiInfo = dWalkerInfo.aoiInfo
			if dWalkerInfo.walkerType == CMapWalkerLoadCtrl.walkerType.Npc then
				g_MapCtrl:AddNpc(eid, aoiInfo)
			else
				g_MapCtrl:AddPlayer(eid, aoiInfo)
			end
			self.m_LoadStateDict[dWalkerInfo.eid] = CMapWalkerLoadCtrl.LoadState.Done
			table.remove(self.m_LoadList, 1)
			iLoadCnt = iLoadCnt + 1
			self:ExcuteProto(eid)
		else
			table.remove(self.m_LoadList, 1)
			self.m_LoadStateDict[eid] = CMapWalkerLoadCtrl.LoadState.Done
			self:DelCacheProto(eid)
		end
		if iLoadCnt == self.m_LoadLimitCnt then
			return true
		end	
	end
end

function CMapWalkerLoadCtrl.ExcuteProto(self, eid)
	local lProto = self.m_CacheProtoDict[eid]
	if not lProto then
		return
	end
	for i,dProtoInfo in ipairs(lProto) do
		local sFuncName = dProtoInfo.proto
		g_MapCtrl[sFuncName](g_MapCtrl, unpack(dProtoInfo.args))
	end
	self:DelCacheProto(eid)
end

function CMapWalkerLoadCtrl.Clear(self)
	self:StopLoadTimer()
	self.m_LoadList = {}
	self.m_LoadStateDict = {}
	self.m_CacheProtoDict = {}
end

return CMapWalkerLoadCtrl
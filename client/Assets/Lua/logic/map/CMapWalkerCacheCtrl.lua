--Note:地图角色缓存管理器，因CMapCtrl会清理掉对象，故使用强引用
local CMapWalkerCacheCtrl = class("CMapWalkerCacheCtrl")

function CMapWalkerCacheCtrl.ctor(self)
	self:Reset()
	self.m_EnableCache = true
	self:InitCacheLimit()
end

function CMapWalkerCacheCtrl.Reset(self)
	self.m_CachePlayerDict = {}
	self.m_CacheSummonDict = {}
	self.m_CacheNpcDict = {}
	self.m_CacheDynamicNpcDict = {}
	self.m_CacheTaskPickItemDict = {}
	self.m_CacheNianShouNpcDict = {}

	self.m_UnUsedPlayerDict = {}
	self.m_UnUsedSummonDict = {}
	self.m_UnUsedNpcDict = {}
	self.m_UnUsedDynamicNpcDict = {}
	self.m_UnUsedTaskPickItemDict = {}
	self.m_UnUsedNianShouNpcDict = {}

	self.m_PlayerCacheLimit = 0
	self.m_SummonCacheLimit = 0
	self.m_NpcCacheLimit = 0
	self.m_DynamicNpcCacheLimit = 0
	self.m_TaskPickItemCacheLimit = 0
	self.m_NianShouNpcCacheLimit = 0

	self.m_CurPlayerSize = 0
	self.m_CurSummonSize = 0
	self.m_CurNpcSize = 0
	self.m_CurDynamicNpcSize = 0
	self.m_CurTaskPickItemSize = 0
	self.m_CurNianShouNpcSize = 0

	self:InitCacheLimit()
end

function CMapWalkerCacheCtrl.InitCacheLimit(self)
	--Note:初始化缓存池上限，以最大可视量处理
	self.m_PlayerCacheLimit = 999--define.MapWalkerNum.Num[3]+10
	self.m_SummonCacheLimit = 999--define.MapWalkerNum.Num[3]+10
	self.m_NpcCacheLimit = 999
	self.m_DynamicNpcCacheLimit = 999
	self.m_TaskPickItemCacheLimit = 999
	self.m_NianShouNpcCacheLimit = 999
end

function CMapWalkerCacheCtrl.CreatePrePlayer(self)
	--Note:以最小可视量预加载模型
	if self.m_CurPlayerSize == 0 then
		local iPreCnt = g_MapPlayerNumberCtrl:GetMaxSameScreenCnt(3)
		for i=1, 60 do
			local oPlayer = CPlayer.New()
			self:AddCachePlayer(oPlayer)
			self:RecyleCachePlayer(oPlayer)
			local oSummon = CMapSummon.New()
			self:AddCacheSummon(oSummon)
			self:RecyleCacheSummon(oSummon)
		end
	end
	if self.m_CurNpcSize == 0 then
		for i=1, 60 do
			local oNpc = CNpc.New()
			self:AddCacheNpc(oNpc)
			self:RecyleCacheNpc(oNpc)
		end
	end
end

---------------------------CPlayer------------------------------
function CMapWalkerCacheCtrl.AddCachePlayer(self, oPlayer)
	oPlayer:SetUsing(true)
	self.m_CachePlayerDict[oPlayer:GetInstanceID()] =  oPlayer
	self.m_CurPlayerSize = self.m_CurPlayerSize + 1
end

function CMapWalkerCacheCtrl.RecyleCachePlayer(self, oPlayer)
	if not oPlayer.m_IsUsing then
		return
	end
	oPlayer:SetUsing(false)
	self.m_UnUsedPlayerDict[oPlayer:GetInstanceID()] = true
	if Utils.IsEditor() then
		CObject.SetName(oPlayer, "CachePlayer"..oPlayer:GetInstanceID())
	end
end

function CMapWalkerCacheCtrl.RecyleAllCachePlayer(self)
	for k,oPlayer in pairs(self.m_CachePlayerDict) do
		if self.m_CurPlayerSize > self.m_PlayerCacheLimit then
			local iUId = oPlayer:GetInstanceID()
			self.m_CachePlayerDict[iUId] = nil
			self.m_UnUsedPlayerDict[iUId] = nil
			self.m_CurPlayerSize = self.m_CurPlayerSize - 1
			oPlayer:Destroy()
		else
			self:RecyleCachePlayer(oPlayer)
		end
	end
	printc("剩余缓存player：", table.count(self.m_CachePlayerDict), self.m_CurPlayerSize)
end

function CMapWalkerCacheCtrl.GetCachePlayer(self)
	local iID = next(self.m_UnUsedPlayerDict)
	if iID then
		local oPlayer = self.m_CachePlayerDict[iID]
		self.m_UnUsedPlayerDict[iID] = nil
		if oPlayer then
			oPlayer:SetUsing(true)
		end
		return oPlayer
	else
		local oPlayer = CPlayer.New()
		self:AddCachePlayer(oPlayer)
		return oPlayer
	end
end

---------------------------CSummon------------------------------
function CMapWalkerCacheCtrl.AddCacheSummon(self, oSummon)
	oSummon:SetUsing(true)
	self.m_CacheSummonDict[oSummon:GetInstanceID()] =  oSummon
	self.m_CurSummonSize = self.m_CurSummonSize + 1
end

function CMapWalkerCacheCtrl.RecyleCacheSummon(self, oSummon)
	if not oSummon.m_IsUsing then
		return
	end
	oSummon:SetUsing(false)
	self.m_UnUsedSummonDict[oSummon:GetInstanceID()] = true
	if Utils.IsEditor() then
		CObject.SetName(oSummon, "CacheSummon"..oSummon:GetInstanceID())
	end
end

function CMapWalkerCacheCtrl.RecyleAllCacheSummon(self)
	for k,oSummon in pairs(self.m_CacheSummonDict) do
		if self.m_CurSummonSize > self.m_SummonCacheLimit then
			local iUId = oSummon:GetInstanceID()
			self.m_CacheSummonDict[iUId] = nil
			self.m_UnUsedSummonDict[iUId] = nil
			self.m_CurSummonSize = self.m_CurSummonSize - 1
			oSummon:Destroy()
		else
			self:RecyleCacheSummon(oSummon)
		end
	end
	-- printe("剩余缓存summmon：", table.count(self.m_CacheSummonDict), self.m_CurSummonSize)
end

function CMapWalkerCacheCtrl.GetCacheSummon(self)
	local iID = next(self.m_UnUsedSummonDict)
	if iID then
		local oSummon = self.m_CacheSummonDict[iID]
		self.m_UnUsedSummonDict[iID] = nil
		if oSummon then
			oSummon:SetUsing(true)
		end
		return oSummon
	else
		local oSummon = CMapSummon.New()
		self:AddCacheSummon(oSummon)
		return oSummon
	end
end

---------------------------CNpc------------------------------
function CMapWalkerCacheCtrl.AddCacheNpc(self, oNpc)
	oNpc:SetUsing(true)
	self.m_CacheNpcDict[oNpc:GetInstanceID()] =  oNpc
	self.m_CurNpcSize = self.m_CurNpcSize + 1
end

function CMapWalkerCacheCtrl.RecyleCacheNpc(self, oNpc)
	if not oNpc.m_IsUsing then
		return
	end
	oNpc:SetUsing(false)
	self.m_UnUsedNpcDict[oNpc:GetInstanceID()] = true
	if Utils.IsEditor() then
		CObject.SetName(oNpc, "CacheNpc"..oNpc:GetInstanceID())
	end
end

function CMapWalkerCacheCtrl.RecyleAllCacheNpc(self)
	for k,oNpc in pairs(self.m_CacheNpcDict) do
		if self.m_CurNpcSize > self.m_NpcCacheLimit then
			local iUId = oNpc:GetInstanceID()
			self.m_CacheNpcDict[iUId] = nil
			self.m_UnUsedNpcDict[iUId] = nil
			self.m_CurNpcSize = self.m_CurNpcSize - 1
			oNpc:Destroy()
		else
			self:RecyleCacheNpc(oNpc)
		end
	end
	printc("剩余缓存npc：", table.count(self.m_CacheNpcDict), self.m_CurNpcSize)
end

function CMapWalkerCacheCtrl.GetCacheNpc(self)
	local iID = next(self.m_UnUsedNpcDict)
	if iID then
		local oNpc = self.m_CacheNpcDict[iID]
		self.m_UnUsedNpcDict[iID] = nil
		if oNpc then
			oNpc:SetUsing(true)
		end
		return oNpc
	else
		local oNpc = CNpc.New()
		self:AddCacheNpc(oNpc)
		return oNpc
	end
end

---------------------------CDynamicNpc------------------------------
function CMapWalkerCacheCtrl.AddCacheDynamicNpc(self, oNpc)
	oNpc:SetUsing(true)
	self.m_CacheDynamicNpcDict[oNpc:GetInstanceID()] =  oNpc
	self.m_CurDynamicNpcSize = self.m_CurDynamicNpcSize + 1
end

function CMapWalkerCacheCtrl.RecyleCacheDynamicNpc(self, oNpc)
	if not oNpc.m_IsUsing then
		return
	end
	oNpc:SetUsing(false)
	self.m_UnUsedDynamicNpcDict[oNpc:GetInstanceID()] = true
	if Utils.IsEditor() then
		CObject.SetName(oNpc, "CacheDynamicNpc"..oNpc:GetInstanceID())
	end
end

function CMapWalkerCacheCtrl.RecyleAllCacheDynamicNpc(self)
	for k,oNpc in pairs(self.m_CacheDynamicNpcDict) do
		if self.m_CurDynamicNpcSize > self.m_DynamicNpcCacheLimit then
			local iUId = oNpc:GetInstanceID()
			self.m_CacheDynamicNpcDict[iUId] = nil
			self.m_UnUsedDynamicNpcDict[iUId] = nil
			self.m_CurDynamicNpcSize = self.m_CurDynamicNpcSize - 1
			oNpc:Destroy()
		else
			self:RecyleCacheDynamicNpc(oNpc)
		end
	end
	printc("剩余缓存npc：", table.count(self.m_CacheDynamicNpcDict), self.m_CurDynamicNpcSize)
end

function CMapWalkerCacheCtrl.GetCacheDynamicNpc(self)
	local iID = next(self.m_UnUsedDynamicNpcDict)
	if iID then
		local oNpc = self.m_CacheDynamicNpcDict[iID]
		self.m_UnUsedDynamicNpcDict[iID] = nil
		if oNpc then
			oNpc:SetUsing(true)
		end
		return oNpc
	else
		local oNpc = CDynamicNpc.New()
		self:AddCacheDynamicNpc(oNpc)
		return oNpc
	end
end

------------------------CNianShouNpc-------------------------------------------

function CMapWalkerCacheCtrl.AddCacheNianShouNpc(self, oNpc)
	oNpc:SetUsing(true)
	self.m_CacheNianShouNpcDict[oNpc:GetInstanceID()] =  oNpc
	self.m_CurNianShouNpcSize = self.m_CurNianShouNpcSize + 1
end

function CMapWalkerCacheCtrl.RecyleCacheNianShouNpc(self, oNpc)
	if not oNpc.m_IsUsing then
		return
	end
	oNpc:SetUsing(false)
	self.m_UnUsedNianShouNpcDict[oNpc:GetInstanceID()] = true
	if Utils.IsEditor() then
		CObject.SetName(oNpc, "CacheNianShouNpc"..oNpc:GetInstanceID())
	end
end

function CMapWalkerCacheCtrl.RecyleAllCacheNianShouNpc(self)
	for k,oNpc in pairs(self.m_CacheNianShouNpcDict) do
		if self.m_CurNianShouNpcSize > self.m_NianShouNpcCacheLimit then
			local iUId = oNpc:GetInstanceID()
			self.m_CacheNianShouNpcDict[iUId] = nil
			self.m_UnUsedNianShouNpcDict[iUId] = nil
			self.m_CurNianShouNpcSize = self.m_CurNianShouNpcSize - 1
			oNpc:Destroy()
		else
			self:RecyleCacheNianShouNpc(oNpc)
		end
	end
	printc("剩余缓存npc：", table.count(self.m_UnUsedNianShouNpcDict), self.m_CurNianShouNpcSize)
end

function CMapWalkerCacheCtrl.GetCacheNianShouNpc(self)
	local iID = next(self.m_UnUsedNianShouNpcDict)
	if iID then
		local oNpc = self.m_CacheNianShouNpcDict[iID]
		self.m_UnUsedNianShouNpcDict[iID] = nil
		if oNpc then
			oNpc:SetUsing(true)
		end
		return oNpc
	else
		local oNpc = CNianShouNpc.New()
		self:AddCacheNianShouNpc(oNpc)
		return oNpc
	end
end

---------------------------CTaskPickItem------------------------------
function CMapWalkerCacheCtrl.AddCacheTaskPickItem(self, oTaskPickItem)
	oTaskPickItem:SetUsing(true)
	self.m_CacheTaskPickItemDict[oTaskPickItem:GetInstanceID()] =  oTaskPickItem
	self.m_CurTaskPickItemSize = self.m_CurTaskPickItemSize + 1
end

function CMapWalkerCacheCtrl.RecyleCacheTaskPickItem(self, oTaskPickItem)
	if not oTaskPickItem.m_IsUsing then
		return
	end
	oTaskPickItem:SetUsing(false)
	self.m_UnUsedTaskPickItemDict[oTaskPickItem:GetInstanceID()] = true
	if Utils.IsEditor() then
		CObject.SetName(oTaskPickItem, "CacheTaskPickItem"..oTaskPickItem:GetInstanceID())
	end
end

function CMapWalkerCacheCtrl.RecyleAllCacheTaskPickItem(self)
	for k,oTaskPickItem in pairs(self.m_CacheTaskPickItemDict) do
		if self.m_CurTaskPickItemSize > self.m_TaskPickItemCacheLimit then
			local iUId = oTaskPickItem:GetInstanceID()
			self.m_CacheTaskPickItemDict[iUId] = nil
			self.m_UnUsedTaskPickItemDict[iUId] = nil
			self.m_CurTaskPickItemSize = self.m_CurTaskPickItemSize - 1
			oTaskPickItem:Destroy()
		else
			self:RecyleCacheTaskPickItem(oTaskPickItem)
		end
	end
	printc("剩余缓存TaskPickItem：", table.count(self.m_CacheTaskPickItemDict), self.m_CurTaskPickItemSize)
end

function CMapWalkerCacheCtrl.GetCacheTaskPickItem(self)
	local iID = next(self.m_UnUsedTaskPickItemDict)
	if iID then
		local oTaskPickItem = self.m_CacheTaskPickItemDict[iID]
		self.m_UnUsedTaskPickItemDict[iID] = nil
		if oTaskPickItem then
			oTaskPickItem:SetUsing(true)
		end
		return oTaskPickItem
	else
		local oTaskPickItem = CTaskPickItem.New()
		self:AddCacheTaskPickItem(oTaskPickItem)
		return oTaskPickItem
	end
end
--------------------------Helper------------------------------
function CMapWalkerCacheCtrl.IsInCache(self, iUId)
	local bPlayer = self.m_CachePlayerDict[iUId] ~= nil
	local bNpc = self.m_CacheNpcDict[iUId] ~= nil
	local bSummon = self.m_CacheSummonDict[iUId] ~= nil
	local bDynamicNpc = self.m_CacheDynamicNpcDict[iUId] ~= nil
	local bItem = self.m_CacheTaskPickItemDict[iUId] ~= nil
	local bNianShou = self.m_CacheNianShouNpcDict[iUId] ~= nil
	return bPlayer or bNpc or bSummon or bDynamicNpc or bItem or bNianShou
end

function CMapWalkerCacheCtrl.RecyleAllCache(self)
	self:RecyleAllCachePlayer()
	self:RecyleAllCacheSummon()
	self:RecyleAllCacheNpc()
	self:RecyleAllCacheDynamicNpc()
	self:RecyleAllCacheTaskPickItem()
	self:RecyleAllCacheNianShouNpc()
end

function CMapWalkerCacheCtrl.RecyleCacheWalker(self, oWalker)
	local sClassName = oWalker.classname
	if sClassName == "CPlayer" then
		self:RecyleCachePlayer(oWalker)
	elseif sClassName == "CNpc" then
		self:RecyleCacheNpc(oWalker)
	elseif sClassName == "CMapSummon" then
		self:RecyleCacheSummon(oWalker)
	elseif sClassName == "CDynamicNpc" then
		self:RecyleCacheDynamicNpc(oWalker)
	elseif sClassName == "CTaskPickItem" then
		self:RecyleCacheTaskPickItem(oWalker)
	elseif sClassName == "CNianShouNpc" then 
		self:RecyleCacheNianShouNpc(oWalker)
	end
end

function CMapWalkerCacheCtrl.ClearAllCache(self)
	--TODO:Test
	for k,oPlayer in pairs(self.m_CachePlayerDict) do
		if not oPlayer.m_IsUsing then
			oPlayer:Destroy()			
		end
	end

	for k,oNpc in pairs(self.m_CacheNpcDict) do
		if not oNpc.m_IsUsing then
			oNpc:Destroy()			
		end
	end

	for k,oSummon in pairs(self.m_CacheSummonDict) do
		if not oSummon.m_IsUsing then
			oSummon:Destroy()			
		end
	end

	self:Reset()
end

function CMapWalkerCacheCtrl.EnableCache(self, b)
	self.m_EnableCache = b
	if b then
		self:InitCacheSize()
	else
		self:ClearAllCache()
	end
end

return CMapWalkerCacheCtrl
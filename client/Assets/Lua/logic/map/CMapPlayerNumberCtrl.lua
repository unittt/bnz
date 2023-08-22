local CMapPlayerNumberCtrl = class("CMapPlayerNumberCtrl")

function CMapPlayerNumberCtrl.ctor(self)

	--同屏人数(其他玩家数目)
	self.m_MaxCount = 5

	self.m_ShowCount = 0

	--已显示列表
	self.m_ShowList = {}

end

function CMapPlayerNumberCtrl.StartCheck(self)
	
	--start check
	if not self.m_Timer then 
		local fun = function ( ... )
			self:CheckShowPlayer()
			return true
		end
		self.m_Timer = Utils.AddTimer(fun, 1, 1)
	end 

end


function CMapPlayerNumberCtrl.IsFull(self)
	
	if self:GetSameScrPalyerCnt() >= self.m_MaxCount then 
		return true
	end 

end

function CMapPlayerNumberCtrl.RemoveShowList(self, pid)
	
	if self.m_ShowList[pid] then 
		self.m_ShowList[pid] = nil
	end 

end

function CMapPlayerNumberCtrl.HandleTeamEvent(self, pList, missId)

	if missId then 
		self:RemoveShowList(missId)
	end 

	if pList then 
		for k, pid in ipairs(pList) do 
			self:RemoveShowList(pid)
		end 
	end 

end


function CMapPlayerNumberCtrl.CheckShowPlayer(self)

	local hero = g_MapCtrl:GetHero()

	if not hero then 
		return
	end 

	--sort 
	local pidList = {}
	for pid, player in pairs(g_MapCtrl.m_Players) do
		if player ~= hero then 
			table.insert(pidList, player)
		end 
	end

	table.sort(pidList, function (a,b)
		if a.m_CreateTime and b.m_CreateTime then 
			if a.m_CreateTime < b.m_CreateTime then 
				return true
			end 

		else
			return false
		end 
	end)

	--find hero member
	local heroMemberList = g_TeamCtrl:GetMemberList()
	if heroMemberList then 
		for k, v in pairs(heroMemberList) do 
			local pid = v.pid
			local player = g_MapCtrl:GetPlayer(pid)
			if player and player ~= hero then 
				self.m_ShowList[pid] = true
			end 
		end 
	end 

	--find leader
	for k, player in ipairs(pidList) do
		if player ~= hero then 
			local pid = player.m_Pid
			local leaderSelf = g_MapCtrl:IsLeaderSelf(pid)
			if leaderSelf then
				--ignore hero
				if player.m_TeamID ~= hero.m_TeamID then
					if player:IsInScreen() then 
						if not self:IsFull() then 
							--find all member
							local pList = g_MapCtrl.m_Teams[player.m_TeamID]
							for k, id in ipairs(pList) do 
								local walker = g_MapCtrl:GetPlayer(id)
								if walker then 
									self.m_ShowList[walker.m_Pid] = true
								end                                                            
							end
						end 
					else
						self:RemoveShowList(pid)
						local pList = g_MapCtrl.m_Teams[player.m_TeamID]
						for k, id in ipairs(pList) do 
							local walker = g_MapCtrl:GetPlayer(id)
							if walker then 
								self:RemoveShowList(walker.m_Pid)
							end                                                            
						end
					end  
				end 
			end
		end
	end

	--single
	for k, player in ipairs(pidList) do
		if player ~= hero then 
			local pid = player.m_Pid
			if not player.m_TeamID then 
				if player:IsInScreen() then
					if not self.m_ShowList[pid] then 
						if not self:IsFull() then
							self.m_ShowList[pid] = true
						end 
					end
				else
					self:RemoveShowList(pid)
				end   
			end 
		end 
	end

	for k, player in ipairs(pidList) do
		if player ~= hero then 
			local pid = player.m_Pid
			if self.m_ShowList[pid] then 
				if not player.hideByMarry then
					player:ShowAll(true)
				end
			else
				player:ShowAll(false)
			end 
		end
	end

	--printc("------------count",  table.count(self.m_ShowList))

end

function CMapPlayerNumberCtrl.GetMaxSameScreenCnt(self, quality)
	
	local lv = g_SystemSettingsCtrl:GetCpuLv()
	local info = data.performancedata.SAMESCREEN[quality]
	if info then 
		if lv == 3 then 
			return info.high
		elseif lv == 2 then 
			return info.mid
		else
			return info.low
		end 
	else
		return 0
	end  

end

function CMapPlayerNumberCtrl.SetMapPlayerNumber(self, quality)
	--printc("CMapPlayerNumberCtrl.SetMapPlayerNumber", quality)
	local numList = nil
	
	self.m_MaxCount =self:GetMaxSameScreenCnt(quality)

	self.m_Quality = quality

	self.m_ShowList = {}

end

function CMapPlayerNumberCtrl.SetSameScreenCnt(self, cnt)

	if type(cnt) == "string" then 
		cnt = tonumber(cnt)
	end 
	printerror(cnt)
	local numList = nil

	self.m_MaxCount = cnt

	self.m_ShowList = {}

end


function CMapPlayerNumberCtrl.Clear(self)
	
	self.m_ShowList = {}
	if self.m_Timer then 
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end 

end


function CMapPlayerNumberCtrl.GetQuality(self)
	
	return self.m_Quality

end


function CMapPlayerNumberCtrl.GetSameScrPalyerCnt(self)
	
	return table.count(self.m_ShowList)

end

function CMapPlayerNumberCtrl.GetAllPlayCnt(self)
	
	local cnt = 0
	for pid, v in pairs(g_MapCtrl.m_Players) do
		if pid ~= g_AttrCtrl.pid then 
			if v.m_IsInScreen then 
				cnt = cnt + 1
			end 
		end  
	end 
	return cnt

end


function CMapPlayerNumberCtrl.GetSameScrRideCnt(self)
	
	local cnt = 0
	for pid, v in pairs(self.m_ShowList) do 
		local player = g_MapCtrl:GetPlayer(pid)
		if player then 
			if player:IsOnRide() then 
				cnt = cnt + 1
			end 
		end
	end 
	return cnt

end

function CMapPlayerNumberCtrl.GetAllRideCnt(self)
	
	local cnt = 0
	for pid, v in pairs(g_MapCtrl.m_Players) do
		if pid ~= g_AttrCtrl.pid then 
			if v.m_IsInScreen and v:IsOnRide() then 
				cnt = cnt + 1
			end 
		end  
	end 
	return cnt

end

function CMapPlayerNumberCtrl.GetSameScrSummonCnt(self)
	
	local cnt = 0
	for pid, v in pairs(self.m_ShowList) do 
		local player = g_MapCtrl:GetPlayer(pid)
		if player then 
			if player:GetFollowSummon() then 
				cnt = cnt + 1
			end 
		end
	end 
	return cnt

end


function CMapPlayerNumberCtrl.GetAllSummonCnt(self)
	
	local cnt = 0
	for pid, v in pairs(g_MapCtrl.m_Players) do 
		if pid ~= g_AttrCtrl.pid then
			local summon = v:GetFollowSummon()
			if summon and summon.m_IsInScreen then 
				cnt = cnt + 1
			end 
		end
	end 
	return cnt

end


function CMapPlayerNumberCtrl.GetSameScrWingCnt(self)
	
	local cnt = 0
	for pid, v in pairs(self.m_ShowList) do
		local player = g_MapCtrl:GetPlayer(pid)
		if player then 
			if player.m_IsInScreen and player:IsWearWing() then 
				cnt = cnt + 1
			end 
		end
	end 
	return cnt

end

function CMapPlayerNumberCtrl.GetAllWingCnt(self)
	
	local cnt = 0
	for pid, v in pairs(g_MapCtrl.m_Players) do 
		if pid ~= g_AttrCtrl.pid then
			if v.m_IsInScreen and v:IsWearWing() then 
				cnt = cnt + 1
			end 
		end
	end 
	return cnt

end

function CMapPlayerNumberCtrl.GetInScrNpc(self)
	
	local cnt = 0
	for pid, v in pairs(g_MapCtrl.m_Npcs) do 
		if v.m_IsInScreen then 
			cnt = cnt + 1
		end 
	end 
	return cnt

end


return CMapPlayerNumberCtrl
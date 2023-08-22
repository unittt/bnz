local CMapSummon = class("CMapSummon", CMapWalker)

function CMapSummon.ctor(self)
	CMapWalker.ctor(self)
	self.m_BelongTo = nil
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, 150, 0))
	self.m_CheckTimer = nil
	self.m_IsInWaterPoint = false
	if g_MapCtrl:IsInWaterMap() then
		self.m_CheckTimer = Utils.AddTimer(callback(self, "Check"), 0.1, 0)
	end
end

function CMapSummon.Reset(self)
	CMapWalker.Reset(self)
	self.m_BelongTo = nil
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, 150, 0))
	self.m_IsInWaterPoint = false
	if self.m_CheckTimer then
		Utils.DelTimer(self.m_CheckTimer)
	end
	self.m_CheckTimer = nil
end

function CMapSummon.CheckInWaterPointArea(self)
	local isInWaterPoint = g_MapCtrl:CheckInWaterPointArea(self)
	if isInWaterPoint ~= self.m_IsInWaterPoint then
		self.m_IsInWaterPoint = isInWaterPoint
	end
end

function CMapSummon.Check(self, dt)
	if not g_MapCtrl:IsInWaterMap() then
		return
	end
	if self:IsTriggerWaterRun() then 
		self:CheckInWaterPointArea()
	end 
	return true
end

function CMapSummon.SetName(self, name, color) 
	-- local colorinfo = data.namecolordata.DATA[2]
	-- local nameColor = color or ("["..colorinfo.color.."]")
	-- CMapWalker.SetName(self, nameColor .. name, colorinfo.style, Color.RGBAToColor(colorinfo.style_color), colorinfo.blod)
	CMapWalker.SetName(self, name, color , define.RoleColor.SceneNPC)
end

function CMapSummon.WalkerPatrolNext(self)
	self.m_WalkerPatrolTime = 0
	local x = 0
	local y = 0
	self:WalkTo(x, y)
end

return CMapSummon
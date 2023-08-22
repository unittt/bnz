local CCountdownTimerCtrl = class("CCountdownTimerCtrl")

CCountdownTimerCtrl.Type = {
	None = 0,
    TeamApply = 1,
    TeamInvite = 2,
    TeamTargetRefresh = 3,
    NetActionCheck = 4,
    TeamApplyLeader = 5,
    OrgApply = 6,
    OrgInvite = 7,
    OrgRefreshApply = 8,
    OrgRespondJoin = 9,
    OrgOneClickRespondJoin = 10,
    BagItemArrange = 11,
    WHItemArrange = 12,
    TeamUpdateInvite = 13,
    Speench = 14,
    OrgBuildAccelerate = 15,
    FloatSameMsg = 16,
    Forge = 17,
    TeamMatchChat = 18, 
    OnClickLoginGame = 19,
    OnClickSelectServer = 20,
}

function CCountdownTimerCtrl.ctor(self)
	self.m_Records = {}
	self.m_Callbacks = {}
	self.m_Timer = nil
end

function CCountdownTimerCtrl.AddRecord(self, type, target, countdown, cb)
	if self.m_Records[type] == nil then
		self.m_Records[type] = {}
		self.m_Callbacks[type] = {}
	end
	self.m_Records[type][target] = countdown
	self.m_Callbacks[type][target] = cb
	if self.m_Timer == nil then
		self:StartTimer()
	end
end

function CCountdownTimerCtrl.DelRecord(self, type, target)
	if self.m_Records[type] then
		self.m_Records[type][target] = nil
		self.m_Callbacks[type][target] = nil
	end
end

function CCountdownTimerCtrl.GetRecord(self , type, target)
	if self.m_Records[type] and self.m_Records[type][target]
		and self.m_Records[type][target] > 0 then
		return self.m_Records[type][target]
	end
	return nil
end

function CCountdownTimerCtrl.Excute(self, type, target)
	local callback = self.m_Callbacks[type][target]
	if callback then
		callback()
		self.m_Callbacks[type][target] = nil
	end
end

function CCountdownTimerCtrl.StartTimer(self)
	local update = function()
		local isUpdate = false
		for type,record in pairs(self.m_Records) do
			for target, countdown in pairs(record) do
				if countdown > 0 then
					countdown = countdown - 1
					self.m_Records[type][target] = countdown
					isUpdate = true
				else
					self:Excute(type, target)
				end
			end
		end
		
		if not isUpdate then
			Utils.DelTimer(self.m_Timer)
			self.m_Timer = nil
		end
		return isUpdate
	end
	self.m_Timer = Utils.AddTimer(update, 1, 0)
end

return CCountdownTimerCtrl
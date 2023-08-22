local CTalkCtrl = class("CTalkCtrl", CCtrlBase)

function CTalkCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_Notify = {}
	self.m_TotalNotify = 0
	--msgdata={pid={聊天记录}, pid={聊天记录}}  
	--recordindex={pid=index, pid2=index2}   index为msgdata里已保存和未保存聊天记录分界的下标
	--lastrecord={pid=filename} 读取聊天记录文件，读取到数据块
	--lasttime 两条消息间是否需要时间串
	--messageid 消息ID
	self.m_MsgData = {}
	--暂时没有用
	self.m_RecordIndex = {}
	self.m_LastRecord = {}
	self.m_LastTime = {}
	self.m_MessageID = {}
	self.m_IsLoadNotifyData = false

	self.m_LimitLocalMsgCount = 100000000
	--最多保存在本地的聊天记录数量
	self.m_ActualLocalMsgCount = 100
end

function CTalkCtrl.Clear(self)
	self.m_Notify = {}
	self.m_TotalNotify = 0
	self.m_MsgData = {}
	--暂时没有用
	self.m_RecordIndex = {}
	self.m_LastRecord = {}
	self.m_LastTime = {}
	self.m_MessageID = {}
	self.m_IsLoadNotifyData = false
end

--别人的聊天离线消息协议返回
function CTalkCtrl.InitOfflineMsg(self, data)
	for k, friendmsg in pairs(data) do
		local pid = friendmsg.pid
		local msgid = nil
		for k, singlemsg in pairs(friendmsg.chat_list) do
			msgid = singlemsg.message_id
			local msg = singlemsg.msg
			self:AddMsg(pid, msg, msgid)
		end
		--收到了服务器发给你的聊天消息，回一个确认消息
		netfriend.C2GSAckChatFrom(pid, msgid)
	end
end

--别人发给我的聊天消息添加,每次加一条聊天信息，存进m_MsgData，key为pid
function CTalkCtrl.AddMsg(self, pid, msg, msgid)
	if g_FriendCtrl:IsBlackFriend(pid) then
		return
	end
	
	self:InitMsg(pid)
	local oMsg = CTalkMsg.New(pid, msg)
	local lasttime = self.m_LastTime[pid]
	local iAmount = 1
	if not lasttime then
		lasttime = 0
	end
	
	if g_TimeCtrl:GetTimeS() - lasttime > 300 then
		iAmount = 2
		local timemsg = CTalkMsg.New(nil, g_TimeCtrl:GetTimeHMS())
		table.insert(self.m_MsgData[pid], 1, timemsg)
		self.m_RecordIndex[pid] = self.m_RecordIndex[pid] + 1
		self.m_LastTime[pid] = g_TimeCtrl:GetTimeS()
	end
	
	table.insert(self.m_MsgData[pid], 1, oMsg)
	self.m_RecordIndex[pid] = self.m_RecordIndex[pid] + 1

	--保存聊天记录
	if pid then
		g_TalkCtrl:SaveMsgRecord(pid)
	end

	--添加pid进入最近联系人数据
	g_FriendCtrl:RefreshRecent(pid)
	self:AddNotify(pid)
	self:OnEvent(define.Talk.Event.AddMsg, {pid=pid, amount=iAmount})
	self:OnEvent(define.Talk.Event.AddFriendMsg,pid)
end

--自己发送给pid的自己的聊天信息，每次加一条，本地添加
function CTalkCtrl.AddSelfMsg(self, pid, msg)
	self:InitMsg(pid)
	local oMsg = CTalkMsg.New(g_AttrCtrl.pid, msg)
	local lasttime = self.m_LastTime[pid]
	local iAmount = 1
	if not lasttime then
		lasttime = 0
	end
	if g_TimeCtrl:GetTimeS() - lasttime > 300 then
		iAmount = 2
		local timemsg = CTalkMsg.New(nil, g_TimeCtrl:GetTimeHMS())
		table.insert(self.m_MsgData[pid], 1, timemsg)
		self.m_RecordIndex[pid] = self.m_RecordIndex[pid] + 1
		self.m_LastTime[pid] = g_TimeCtrl:GetTimeS()
	end
	
	table.insert(self.m_MsgData[pid], 1, oMsg)
	self.m_RecordIndex[pid] = self.m_RecordIndex[pid] + 1

	--保存聊天记录
	if pid then
		g_TalkCtrl:SaveMsgRecord(pid)
	end

	--添加pid进入最近联系人数据
	g_FriendCtrl:RefreshRecent(pid)
	self:OnEvent(define.Talk.Event.AddMsg, {pid=pid, amount=iAmount})
end

--初始化聊天数据，即对m_MsgData和m_RecordIndex数据判断是否为nil
function CTalkCtrl.InitMsg(self, pid)
	if not self.m_MsgData[pid] then
		self.m_MsgData[pid] = {}
	end

	if not self.m_RecordIndex[pid] then
		self.m_RecordIndex[pid] = 0
	end
end

--返回的是总共的聊天数据，pid为key
function CTalkCtrl.GetMsg(self, pid)
	self:InitMsg(pid)
	self:UpdateNotifyData(pid)
	-- if #self.m_MsgData[pid] == 0 then
	-- 	self:LoadMsgRecord(pid)
	-- end
	self:LoadMsgRecord(pid)
	return self.m_MsgData[pid]
end

--传一个pid，获取这个pid的一条最新的聊天
function CTalkCtrl.GetLastMsg(self, pid)
	local list = self.m_MsgData[pid]
	if list and #list > 0 then
		return list[1]
	end
end

--发送协议
function CTalkCtrl.SendChat(self, pid, msg)
	--禁言判断
	local bIsContain, oId = g_JinYanCtrl:IsContainMaskWordTwo(msg)
	if bIsContain then
		netfriend.C2GSChatTo(pid, msg, tostring(self:GetMsgID(pid)), oId)
	else
		netfriend.C2GSChatTo(pid, msg, tostring(self:GetMsgID(pid)))
	end
end

--设置聊天box的复制文字按钮只能出现一个
function CTalkCtrl.SetCopyBtnEvent(self, msgBox)
	self:OnEvent(define.Talk.Event.CopyMsg, msgBox)
end

--暂时没有用
function CTalkCtrl.GetMsgID(self, pid)
	if not self.m_MessageID[pid] then
		self.m_MessageID[pid] = 0
	end
	self.m_MessageID[pid] = self.m_MessageID[pid] + 1
	return g_TimeCtrl:GetTimeS() * 100 + self.m_MessageID[pid]%100
end

----------------没阅读消息的红点通知-------------------

--添加对话的每个pid的没阅读消息的数据
function CTalkCtrl.AddNotify(self, pid)
	-- printc("添加对话的每个pid的没阅读消息的数据",pid)
	self:GetRecentNotifySaveData()
	if g_FriendCtrl:IsMyFriend(tonumber(pid)) or g_FriendCtrl:IsRecentFriend(tonumber(pid)) then
		if not self.m_Notify[tonumber(pid)] then
			self.m_Notify[tonumber(pid)] = 0
		end
		self.m_Notify[tonumber(pid)] = self.m_Notify[tonumber(pid)] + 1
		self.m_TotalNotify = self.m_TotalNotify + 1
		self:SaveRecentNotifyData(self.m_Notify)
		self:OnEvent(define.Talk.Event.AddNotify, pid)
	end
end

--获取对话的每个pid的没阅读消息的数据
function CTalkCtrl.GetNotify(self, pid)
	self:GetRecentNotifySaveData()
	if not self.m_Notify[tonumber(pid)] then
		return 0
	end
	return self.m_Notify[tonumber(pid)]
end

--获取总共的没阅读消息的数量
function CTalkCtrl.GetTotalNotify(self)
	self:GetRecentNotifySaveData()
	return self.m_TotalNotify
end

--阅读对应pid的消息，删除notify数据
function CTalkCtrl.UpdateNotifyData(self,pid)
	-- printc("阅读对应pid的消息，删除notify数据",pid)
	self:GetRecentNotifySaveData()
	self.m_TotalNotify = self.m_TotalNotify - self:GetNotify(pid)
	self.m_TotalNotify = math.max(self.m_TotalNotify, 0)
	self.m_Notify[tonumber(pid)] = nil
	self:SaveRecentNotifyData(self.m_Notify)
	self:OnEvent(define.Talk.Event.DelNotify, pid)

	-- printc("阅读对应pid的消息，删除notify数据",pid)
end

--返回的是没阅读消息的pid,即返回发来聊天消息的别人中的一个
function CTalkCtrl.GetRecentTalk(self)
	self:GetRecentNotifySaveData()
	--这里是最近联系人数据
	local list = g_FriendCtrl:GetRecentFriend()
	for k, pid in pairs(list) do
		if self.m_Notify[tonumber(pid)] and self.m_Notify[tonumber(pid)] > 0 then
			return pid
		end
	end
end

--获取发来消息的最近联系人的数量
function CTalkCtrl.GetRecentTalkRoleCount(self)
	self:GetRecentNotifySaveData()
	local count = table.count(self.m_Notify)
	return count
end

--根据好友和最近联系人的列表来检查
function CTalkCtrl.CheckNotifyData(self, pid)
	self:GetRecentNotifySaveData()
	if not ( g_FriendCtrl:IsMyFriend(tonumber(pid)) or g_FriendCtrl:IsRecentFriend(tonumber(pid)) ) then
		self.m_TotalNotify = self.m_TotalNotify - self:GetNotify(pid)
		self.m_TotalNotify = math.max(self.m_TotalNotify, 0)
		self.m_Notify[tonumber(pid)] = nil
		self:SaveRecentNotifyData(self.m_Notify)
	end
end

function CTalkCtrl.CheckRecentNotifyMsg(self)
	--暂时屏蔽
	-- local oNotRecentList = table.slice(g_FriendCtrl.m_Friend["recent"], g_FriendCtrl.m_RecentLimit + 1, #g_FriendCtrl.m_Friend["recent"])
	-- for k,v in pairs(oNotRecentList) do
	-- 	self:UpdateNotifyData(v)
	-- end
end

----------------下边的函数是存储聊天记录到本地-------------------

--加载本地聊天记录
function CTalkCtrl.LoadMsgRecord(self, pid)
	if not self.m_MsgData[pid] or not next(self.m_MsgData[pid]) then
		local path = string.format("/role/%d/msgrecord/%d/", g_AttrCtrl.pid, pid)
		if not IOTools.IsExist(IOTools.GetPersistentDataPath(path)) then
			return
		end
		
		local pathList = IOTools.GetFiles(IOTools.GetPersistentDataPath(path), "*.txt", false)
		table.sort(pathList)
		local lastname = self.m_LastRecord[pid]
		local resultpath = nil
		
		if #pathList > 0 then
			if pathList[1] == lastname then
				return
			end
			if not lastname then
				resultpath = pathList[#pathList]
			end
		end
		
		for i = 2, #pathList do
			if pathList[i] == lastname then
				resultpath = pathList[i-1]
				break
			end
		end
		
		local recordList = nil
		if resultpath then
			recordList = IOTools.LoadJsonFile(resultpath)
		else
			return
		end
		
		if not recordList or type(recordList) ~= type({}) then
			recordList = {}
		end
		
		self.m_LastRecord[pid] = resultpath
		
		self.m_MsgData[pid] = {}
		for k, oRecord in ipairs(recordList) do
			table.insert(self.m_MsgData[pid], CTalkMsg.New(oRecord[1], oRecord[2]))
		end
		return true
	end
end

--保存聊天记录到本地
function CTalkCtrl.SaveMsgRecord(self, pid)
	self:InitMsg(pid)
	local filename = self:GetSaveFile(pid)
	local recordList = {}--IOTools.LoadJsonFile(filename)
	if not recordList or type(recordList) ~= type({}) then
		recordList = {}
	end
	
	local msgList = self.m_MsgData[pid]
	--self.m_RecordIndex[pid]
	--设置保存的聊天记录上限
	local oMsgCount = table.count(msgList)
	local oActualCount = oMsgCount <= self.m_ActualLocalMsgCount and oMsgCount or self.m_ActualLocalMsgCount
	for i = oActualCount, 1, -1 do
		--存储的是pid，text
		table.insert(recordList, 1, {msgList[i]:GetID(), msgList[i]:GetText()})
	end

	IOTools.SaveJsonFile(filename, recordList)
	self.m_RecordIndex[pid] = 0
end

--获取聊天记录文件路径
function CTalkCtrl.GetSaveFile(self, pid)
	local path = string.format("/role/%d/msgrecord/%d/", g_AttrCtrl.pid, pid)
	local filename = "1"
	if IOTools.IsExist(IOTools.GetPersistentDataPath(path)) then
		local pathList = IOTools.GetFiles(IOTools.GetPersistentDataPath(path), "*.txt", false)
		if #pathList > 0 then
			local path = pathList[#pathList]
			local oldData = IOTools.LoadJsonFile(path) or {}
			if #oldData > self.m_LimitLocalMsgCount then
				local oGetFileName = IOTools.GetFileName(path, true)
				filename = tostring(tonumber(oGetFileName)+1)
			else
				filename = IOTools.GetFileName(path, true)
			end
		end
	end
	return IOTools.GetPersistentDataPath(string.format("%s%s.txt", path, filename))
end

--保存聊天红点通知数据在本地
function CTalkCtrl.SaveRecentNotifyData(self, t)
	local path = IOTools.GetRoleFilePath("/recentnotify")
	IOTools.SaveJsonFile(path, t)
end

--获取本地聊天红点通知数据
--本地保存文件会把key变为字符串,{"12":1}
function CTalkCtrl.GetRecentNotifySaveData(self)
	if not next(self.m_Notify) and not self.m_IsLoadNotifyData then
		self.m_TotalNotify = 0
		local path = IOTools.GetRoleFilePath("/recentnotify")
		local t = IOTools.LoadJsonFile(path) or {}
		for k,v in pairs(t) do
			--暂时屏蔽
			-- if (g_FriendCtrl.m_IsInitFriendData and g_FriendCtrl:IsMyFriend(tonumber(k)) ) or ( g_FriendCtrl.m_IsInitRecentData and g_FriendCtrl:IsRecentFriend(tonumber(k)) ) then
				self.m_TotalNotify = self.m_TotalNotify + v
				self.m_Notify[tonumber(k)] = v
			-- end
		end
		-- if g_FriendCtrl.m_IsInitFriendData and g_FriendCtrl.m_IsInitRecentData then
			self:SaveRecentNotifyData(self.m_Notify)
			self.m_IsLoadNotifyData = true
		-- end
	end
end

return CTalkCtrl
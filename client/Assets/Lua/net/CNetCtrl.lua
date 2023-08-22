local CNetCtrl = class("CNetCtrl", CCtrlBase)
local string = string
local ipairs = ipairs
local unpack = unpack
local table = table

function CNetCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_ProtoHanlder = CNetProtoHandler.New()

	self.m_MaxPacketSize = 10 * 1024
	self.m_TestNetList = {}
	self.m_MainNetObj = nil
	self.m_TestConnectTimer = nil
	self.m_ProtoCache = {}
	self.m_IsNeedCache = {}
	self.m_LastIPAndPort= {}
	self.m_WaitConnect = {}
	self.m_HasAutoReconnect = false
	self.m_IsClientActive = true
	self.m_BigPackets = {}

	self.m_MaxReconnectCnt = 3
	self.m_ReconnectCnt = 0
	self.m_ReconnectTimer = nil

	self.m_ConnectOuttime = 10
	self.m_CurOuttime = self.m_ConnectOuttime

	self.m_CurProtoData = nil
	--协议记录相关(实现战斗录像等功能)
	self.m_Records = {}
	self.m_RecordType = nil
	self:ResetReceiveRecord()

	-- 协议Tick数据
	self.m_LockNetTimer = nil
	-- 保存格式 id：main sub cd
	-- self.m_LockSessionDic = {id = {main = "", sub = "", cdtimer = nil}}
	self.m_LockSessionDic = {}

	-- 转圈界面
	self.m_NetConfirmView = nil

	-- 邀请码回调
	self.m_InviteCodeCb = nil

	self:InitCtrl()
end

function CNetCtrl.InitCtrl(self)
	Utils.SetTcpParerXorKey(gameconfig.Net.SecreKey)
end

function CNetCtrl.GS2COpSessionResponse(self, iSession)
	-- do return end
	-- 判定解锁
	for k,v in pairs(self.m_LockSessionDic) do
		if k == tonumber(iSession) then
			if v.cdtimer then
				Utils.DelTimer(v.cdtimer)
				v.cdtimer = nil
			end
			self.m_LockSessionDic[k] = nil
			break
		end
	end

	if not next(self.m_LockSessionDic) then
		g_NotifyCtrl:ShowNetCircle(false)
		if self.m_LockNetTimer then
			Utils.DelTimer(self.m_LockNetTimer)
			self.m_LockNetTimer = nil
		end
	end
end

function CNetCtrl.DelLockSession(self, main, sub)
	for k,v in pairs(self.m_LockSessionDic) do
		if v.main == main and v.sub == sub then
			self:GS2COpSessionResponse(k)
			break
		end
	end
end

function CNetCtrl.IsConnecting(self)
	-- return next(self.m_WaitConnect) ~= nil
	
	for ip, ports in pairs(self.m_WaitConnect) do
		if ports and next(ports) then
			return true
		end
	end
	return false
end

function CNetCtrl.ConnectServer(self, ip, ports)
	if not ip then
		g_NotifyCtrl:FloatMsg("请求ip为空")
		return
	end
	if not ports then
		g_NotifyCtrl:FloatMsg("请求ports为空")
		return
	end

	--处理跨服服务器重连
	if g_KuafuCtrl:IsInKS() and not next(g_KuafuCtrl.m_BackGsData) and not next(g_KuafuCtrl.m_EnterKsData) then
		g_KuafuCtrl:SetUpEnterKsData()
	end

	self.m_LastIPAndPort = {ip=ip, port=ports[1]}

	if not self.m_WaitConnect[ip] then
		self.m_WaitConnect[ip] = {}
	end
	self.m_WaitConnect[ip] = table.copy(ports)
	self.m_CurOuttime = self.m_ConnectOuttime / math.clamp(#ports, 1, 4)
	self:ConnectNext()
end

function CNetCtrl.Disconnect(self)
	if self.m_MainNetObj then
		--self.m_ProtoHanlder:ProcessSendList(self.m_MainNetObj)
		self.m_MainNetObj:Release()
		self.m_MainNetObj = nil
	end
	self.m_WaitConnect = {}
end

function CNetCtrl.ConnectNext(self)
	g_LoginPhoneCtrl.m_Logined = false
	for ip, ports in pairs(self.m_WaitConnect) do
		local port = table.randomvalue(ports)
		if port then
			local oTcpClient = CTcpClient.New()
			oTcpClient:SetCallback(callback(self, "OnSocketEvent", oTcpClient))
			print("尝试连接",ip, port)
			oTcpClient:Connect(ip, port, self.m_ConnectOuttime)
			return true
		end
	end
	return false
end

function CNetCtrl.GetNetObj(self)
	return self.m_MainNetObj
end

function CNetCtrl.OnSocketEvent(self, obj, iEventType, sData)
	local ip = obj:GetIP()
	local port = obj:GetPort()
	if not (ip and port) then
		printc("CNetCtrl.OnSocketEvent -> iEventType | ip, port 不存在 请调整您当前使用的网络")
		self:ShowReloginConfirm()
		return 
	end
	if iEventType == enum.TcpEvent.ConnnectSuccess then
		-- 先清理
		self:Disconnect()

		self.m_HasAutoReconnect = false
		self.m_MainNetObj = obj
		self.m_LastIPAndPort = {ip=ip, port=port}
		self.m_ReconnectCnt = 0
		self:DelReconnectTimer()

		-- 链接确认窗口
		if self.m_NetConfirmView then
			self.m_NetConfirmView:CloseView()
		end
		if self.m_InviteCodeCb then
			self.m_InviteCodeCb()
			self.m_InviteCodeCb = nil
		end
	elseif iEventType == enum.TcpEvent.ConnnectFail then
		--处理连接不上跨服
		if g_KuafuCtrl.m_IsEnterKsConnect then
			g_KuafuCtrl:ConnectKsFailBackToGsTwo()
			g_KuafuCtrl.m_IsEnterKsConnect = false
		else
			local ports = self.m_WaitConnect[ip]
			obj:Release()
			g_LoginPhoneCtrl.m_Logined = false
			local bNext = false
			if ports then
				local index = table.index(ports, port)
				table.remove(ports, index)
				bNext = self:ConnectNext()
			end
			if not bNext then
				self:ShowReloginConfirm()
				-- self:AutoReconnect()
			end
		end
	elseif iEventType == enum.TcpEvent.ReceiveMessage then
		if obj == self.m_MainNetObj then
			self:Receive(sData)
		end
	elseif iEventType == enum.TcpEvent.Exception then
		--处理连接不上跨服
		if g_KuafuCtrl.m_IsEnterKsConnect then
			g_KuafuCtrl:ConnectKsFailBackToGsTwo()
			g_KuafuCtrl.m_IsEnterKsConnect = false
		else
			self:OnSocketException()
		end
	end
	self:OnEvent(define.Net.Event_Sockect)
end

function CNetCtrl.ShowNetWindow(self)
	
end

function CNetCtrl.AutoReconnect(self, cb)
	self.m_ProtoHanlder:Clear()
	local dLast = g_NetCtrl.m_LastIPAndPort
	--重要，标识是重连的连接
	g_LoginPhoneCtrl.m_IsReconnect = true
	g_LoginPhoneCtrl:ConnnectPhoneServer(dLast.ip, {dLast.port})
	self.m_HasAutoReconnect = true
	self.m_InviteCodeCb = cb
end

--大包协议
function CNetCtrl.ReceiveBigPacket(self, type, total, index, data)
	local dPacket = self.m_BigPackets[type] 
	if not dPacket then
		dPacket = {}
	end
	dPacket[index] = data
	
	local bComplete = true
	for i=1, total do
		if not dPacket[i] then
			bComplete = false
			break
		end
	end
	if bComplete then
		local sMergeData = table.concat(dPacket, "")
		self:ProtoHandlerCheck(type, sMergeData)
		self.m_BigPackets[type] = nil
	else
		self.m_BigPackets[type] = dPacket
	end
end

function CNetCtrl.ProtoHandlerCheck(self, iPbType, sData)
	if self.m_ProtoHanlder:IsPriorType(iPbType) or (self.m_ProtoHanlder:IsCanProcess() and self.m_ProtoHanlder:IsEmpty()) then
		self:ProcessProto(iPbType, sData)
	else
		self.m_ProtoHanlder:PushProto(iPbType, sData)
	end
end

function CNetCtrl.Receive(self, sData)
	local function cb()
		self:DoReceive(sData)
		return false
	end
	if g_GmCtrl.m_GMRecord.Logic.protoDelay then
		Utils.AddTimer(cb, 3, 3)
	else
		cb()
	end
end

function CNetCtrl.DoReceive(self, sData)
	self.m_CurProtoData = sData
	local iPbType = IOTools.ReadNumber(sData, 2) 
	self:ProcessRecord(iPbType, sData)
	sData = string.sub(sData, 3)
	self:ProtoHandlerCheck(iPbType, sData)
end

function CNetCtrl.ProcessRecord(self, iPbType, sData)
	if not self.m_RecordType then
		return
	end
	local dRecordInfo = datauser.netdata.RECORD[self.m_RecordType]
	local typeInfo = netdefines.GS2C[iPbType]
	if typeInfo then
		local sMainType, sSubType = unpack(typeInfo)
		local dSubInfo = dRecordInfo[sMainType]
		if dSubInfo then
			if dSubInfo.all_flag or dSubInfo[sSubType] then
				table.insert(self.m_Records, sData)
				return
			end
		end
	end
end

function CNetCtrl.ProcessProto(self, iPbType, sData)
	local typeInfo = netdefines.GS2C[iPbType]
	if typeInfo then
		local sMainType, sSubType = unpack(typeInfo)
		local pbdata, errormsg = protobuf.decode(sSubType, sData)
		if pbdata then
			if sMainType == "war" and sSubType == "GS2CShowWar" then
				g_MapCtrl.m_In2DMap = false
				-- 清空加载队列
				g_ResCtrl:CleanLoadQueue()
			elseif sMainType == "scene" and sSubType == "GS2CShowScene" then
				g_MapCtrl.m_In2DMap = true
				-- 清空加载队列
				g_ResCtrl:CleanLoadQueue()
			end

			if self:IsBanProto(sMainType, sSubType) then
				-- print("屏蔽协议", sMainType, sSubType)
				return
			end
			if self:CheckCacheProto(sMainType, sSubType, pbdata) then
				return
			end
			if not self:IsBanPrint(sMainType, sSubType) then
				if g_GmCtrl.m_GMRecord.Logic.printNetTime then
					local curMS = g_TimeCtrl:GetTimeMS()
					local invalMS = curMS - g_GmCtrl.m_GMRecord.Logic.recordNetTime
					print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "Receive", " 协议接收 MS | 间隔"), curMS, invalMS)
				end
				table.print(pbdata, "--> Net Receive: "..sMainType.."."..sSubType)
			end
			local oWatch = g_TimeCtrl:StartWatch()
			self:ProtoCall(sMainType, sSubType, pbdata)
			local iElapsedMS = g_TimeCtrl:StopWatch(oWatch)
			self.m_ProtoHanlder:CostTime(iElapsedMS)
		else
			printerror("协议错误", string.format("pbtype:%s, maintype:%s, errmsg:%s", iPbType, sMainType, errormsg))
		end
	else
		printerror("netdefines GS2C undefined", iPbType)
	end
end

function CNetCtrl.ProtoCall(self, sMainType, sSubType, pbdata)
	if sMainType == "scene" then
		if not g_MapCtrl.m_In2DMap then
			return
		end
	elseif sMainType == "war" and sSubType ~= "GS2CWarFail" then
		-- GS2CWarFail 特殊处理
		if g_MapCtrl.m_In2DMap then
			return
		end
	end

	local s = "net"..sMainType
	local m = getgloalvar(s)
	if m then
		local func = m[sSubType]
		if func then
			xxpcall(func, pbdata)
		else
			printerror("CNetCtrl.ProtoCall func err:", sSubType)
		end
	else
		printerror("CNetCtrl.ProtoCall module err:", s)
	end
end

--缓存协议
function CNetCtrl.SetCacheProto(self, sBanType, bCached)
	local dBan = datauser.netdata.BAN.proto[sBanType]
	for sMainType, v in pairs(dBan) do
		if type(v) == "table" then
			if not self.m_IsNeedCache[sMainType] then
				self.m_IsNeedCache[sMainType] = {}
			end
			for sSubType, _ in pairs(v) do
				local list = self.m_IsNeedCache[sMainType][sSubType] or {}
				local idx = table.index(list, sBanType)
				if bCached then
					if not idx then
						table.insert(list, sBanType)
					end
				else
					if idx then
						table.remove(list, idx)
					end
				end
				self.m_IsNeedCache[sMainType][sSubType] = list
			end
		end
	end
end

function CNetCtrl.ClearCacheProto(self, sBanType, bCall)
	local list = self.m_ProtoCache[sBanType]
	if not list then
		return
	end
	table.print(list, string.format("%s 执行缓存协议:%d %s", sBanType, #list, tostring(bCall)))
	if bCall then
		for i, one in ipairs(list) do
			local sMainType, sSubType, pbdata = unpack(one, 1, 3)
			local callfun = self:CheckCacheProto(sMainType, sSubType, pbdata)
			if not callfun then
				-- if not self:IsBanPrint(sMainType, sSubType) then
				-- 	table.print(pbdata, "===>>>> Cache Net Receive: "..sMainType.."."..sSubType)
				-- end

				--避免npc对象还未生成的时候，就触发了寻路到该npc的问题
				if sMainType == "scene" and sSubType == "GS2CAutoFindPath" then 
					self.m_Parameter = {}
					self.m_Parameter[1] = sMainType
					self.m_Parameter[2] = sSubType
					self.m_Parameter[3] = pbdata
				else
					self:ProtoCall(sMainType, sSubType, pbdata)
				end 

			end
		end
		if self.m_Parameter then 
			self:ProtoCall(self.m_Parameter[1], self.m_Parameter[2], self.m_Parameter[3])
			self.m_Parameter = nil
		end 
	end
	self.m_ProtoCache[sBanType] = nil
end

function CNetCtrl.ClearCacheLastProto(self, sBanType, bCall)
	local list = self.m_ProtoCache[sBanType]
	if not list then
		return
	end
	local dLastProto = list[#list]
	self.m_ProtoCache[sBanType] = {}
	table.insert(self.m_ProtoCache, dLastProto)
	self:ClearCacheProto(sBanType, bCall)
end

function CNetCtrl.CheckCacheProto(self, sMainType, sSubType, pbdata)
	if self.m_IsNeedCache[sMainType] then
		local list = self.m_IsNeedCache[sMainType][sSubType]

		if list and #list > 0 then
			-- print("缓存协议", sMainType, sSubType)
			for _, sBanType in pairs(list) do
				local caches = self.m_ProtoCache[sBanType] or {}
				table.insert(caches, {sMainType, sSubType, pbdata})
				self.m_ProtoCache[sBanType] = caches
			end
			return true
		end
	end

	return false
end


function CNetCtrl.Send(self, sMainType, sSubType, t)
	if not self.m_MainNetObj then
		printc("===== CNetCtrl.Send ----> Net已经不存在了， Not self.m_MainNetObj")
		return
	end
	local iPbType = netdefines.C2GS_BY_NAME[sSubType]
	if not iPbType then
		printerror("netdefines没有找到"..sSubType)
		return
	end
	if not g_LoginPhoneCtrl.m_Logined and sMainType ~= "login" and sMainType ~= "other" and sSubType ~= "C2GSOpSession" then
		printc("===== CNetCtrl.Send 已登出 ----> not g_LoginPhoneCtrl.m_Logined", g_LoginPhoneCtrl.m_Logined, sMainType, sSubType)
		return
	end

	-- 协议锁
	local sendSessionID = nil
	if netlockproto.LockProtoList[sMainType] and netlockproto.LockProtoList[sMainType][sSubType] then
		local lockInfo = netlockproto.LockProtoList[sMainType][sSubType]
		-- 是否需要锁
		if lockInfo.Lock then
			for k,v in pairs(self.m_LockSessionDic) do
				if v.main == sMainType and v.sub == sSubType then
					printerror("触发协议锁,详细信息参考下一条内容", sMainType, sSubType)
					table.print(t)
					return
				end
			end

			-- 协议锁加倒计时，计时结束依然解锁
			sendSessionID = Utils.GetUniqueID()

			if not next(self.m_LockSessionDic) then
				-- 网络请求
				if self.m_LockNetTimer then
					Utils.DelTimer(self.m_LockNetTimer)
					self.m_LockNetTimer = nil
				end
				self.m_LockNetTimer = Utils.AddTimer(function ()
					if self.m_LockSessionDic[sendSessionID] then
						g_NotifyCtrl:ShowNetCircle(true, lockInfo.Tip, lockInfo.Style == 1)
					end
					return false
				end, 5, lockInfo.Delay or 5)
			end

			-- 锁 5秒后移除
			local timer = Utils.AddTimer(function ()
				local lockSessionInfo = self.m_LockSessionDic[sendSessionID]
				if lockSessionInfo then
					if lockSessionInfo.cdtimer then
						Utils.DelTimer(lockSessionInfo)
						lockSessionInfo.cdtimer = nil
					end
					self.m_LockSessionDic[sendSessionID] = nil
					if not next(self.m_LockSessionDic) then
						g_NotifyCtrl:ShowNetCircle(false)
					end
				end
				return false
			end, 5, lockInfo.ResumeDelay or 5)
			self.m_LockSessionDic[sendSessionID] = {main = sMainType, sub = sSubType, cdtimer = timer}
		end
	end

	if not self:IsBanPrint(sMainType, sSubType) then
		if g_GmCtrl.m_GMRecord.Logic.printNetTime then
			local curMS = g_TimeCtrl:GetTimeMS()
			g_GmCtrl.m_GMRecord.Logic.recordNetTime = curMS
			print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "Send", " 协议发送 MS"), g_GmCtrl.m_GMRecord.Logic.recordNetTime)
		end
		table.print(t, "<-- Net Send: "..sMainType.."."..sSubType)
	end
	-- self:CheckClientStatus(sSubType)

	local sPbType = string.char(math.floor(iPbType/256))..string.char((iPbType%256))
	local sEncode = protobuf.encode(sSubType, t)
	
	if #sEncode > self.m_MaxPacketSize then
		self:SendBigPacket(iPbType, sEncode)
	else
		local sData = sPbType..sEncode
		self.m_MainNetObj:Send(sData)
		--self.m_ProtoHanlder:PushSendData(sData)
	end

	-- 锁最后发（服务器要求）
	if sendSessionID then
		netother.C2GSOpSession(sendSessionID)
	end
end

function CNetCtrl.SendBigPacket(self, iType, sEncode)
	local iMax = self.m_MaxPacketSize
	local iPbType = netdefines.C2GS_BY_NAME["C2GSBigPacket"]
	local sPbType = string.char(math.floor(iPbType/256))..string.char((iPbType%256))
	local iLen = math.ceil(#sEncode / iMax)
	for i=1, iLen do
		local sSubData = string.sub(sEncode, (i-1)*iMax+1, i*iMax)
		local t = {type=iType,total=iLen,index=i,data=sSubData}
		local sEncode = protobuf.encode("C2GSBigPacket", t)
		local sData = sPbType..sEncode
		self.m_MainNetObj:Send(sData)
	end
end

function CNetCtrl.IsBanProto(self, sMainType, sSubType)
	local dBan = datauser.netdata.BAN.proto[sMainType]
	if dBan and dBan.func() and dBan[sSubType] then
		return true
	end
	return false
end

function CNetCtrl.IsBanPrint(self, sMainType, sSubType)
	local dBan = datauser.netdata.BAN.print[sMainType]
	if dBan and dBan[sSubType] then
		return true
	end
	return false
end

-- 原来的mask解析
-- function CNetCtrl.DecodeMaskData(self, dOri, sType)
-- 	local d = {}
-- 	local lKey = datauser.netdata.PBKEYS[sType]
-- 	if lKey then
-- 		local iMask = dOri.mask
-- 		if iMask then
-- 			local right = 1
-- 			for i=1, #lKey do
-- 				right = right * 2
-- 				if MathBit.andOp(iMask, right) ~= 0 then
-- 					local key = lKey[i]
-- 					d[key] = dOri[key]
-- 				end
-- 			end
-- 			-- table.print(d, "CNetCtrl解析mask: "..sType)
-- 			return d
-- 		end
-- 	end
-- 	return dOri
-- end

function CNetCtrl.DecodeMaskData(self, dOri, sType)
	local lKey = datauser.netdata.PBKEYS[sType]
	local m = table.copy(lKey)
	table.insert(m, 1, "mask")
	return self:UnMask(dOri, m)
end

function CNetCtrl.UnMask(self, mData, m)
    if not mData.mask then
        mData.mask = ""
    end
    assert(m[1] == "mask", "Mask fail mask field should be id 1")
    local sMask = mData.mask
    local iLen = #sMask
    local mRet = {}
    for i = 1, iLen do
        local iByte = tonumber(string.char(sMask:byte(i)), 16)
        for j = 1, 4 do
            local k = (iLen - i) * 4 + j
            if k == 0 then
            	break
            end
            if k ~= 1 then
	            -- local b = (2^(j-1)) & iByte
	            local b = MathBit.andOp((2^(j-1)), iByte)
	            if b~=0 then
	            	if Utils.IsEditor() then
	            		local sKey = assert(m[k], string.format("UnMask fail %s error, %s, %s", k, i, j))
			            mRet[sKey] = mData[sKey]
	            	else
		            	local sKey = m[k]
		            	if sKey then
			                -- local sKey = assert(m[k], string.format("UnMask fail %s error", k))
			                mRet[sKey] = mData[sKey]
			            end
			        end
	            end
            end
        end
    end
    return mRet
end

function CNetCtrl.EncodeMaskData(self, mData, sType)
	assert(not mData.mask, "Mask fail should has no mask field")
	local m = datauser.netdata.ENKEYS[sType]
    local iMask = 0
    local mRet = {}
    for k, v in pairs(mData) do
        local iNo = assert(m[k], string.format("Mask fail %s error", k))
        mRet[k] = v
        iMask = MathBit.orOp(iMask, (2^iNo))--iMask | (2^(iNo-1))
    end
    mRet.mask = string.format("%x", iMask)
    return mRet
end

function CNetCtrl.Update(self)
	local oHandler = self.m_ProtoHanlder
	--self.m_ProtoHanlder:ProcessSendList(self.m_MainNetObj)
	if not oHandler:IsEmpty() then
		while oHandler:IsCanProcess() do
			local iPbType, sData = oHandler:PopProto()
			if iPbType and sData then
				self:ProcessProto(iPbType, sData)
			else
				return
			end
		end
	end
end

function CNetCtrl.ResetReceiveRecord(self)
	self.m_RecordList = nil
	self.m_CurRecordIdx = 1
	self.m_RecordData = nil
	self.m_ReceiveRecordInitCnt = nil
end


--协议录像 start
function CNetCtrl.SetRecordType(self, sType)
	if self.m_RecordType == sType then
		return
	end
	if sType then
		self.m_Records = {self.m_CurProtoData}
	else
		self.m_Records = {}
	end
	self.m_RecordType = sType
end

function CNetCtrl.IsRecord(self)
	return self.m_RecordType ~= nil
end

function CNetCtrl.GetRecordFilePath(self, sKey)
	return IOTools.GetPersistentDataPath("/netrecord/"..sKey)
end

function CNetCtrl.SaveRecordsToLocal(self, sKey, dData)
	print("保存"..sKey, #self.m_Records)
	local path = self:GetRecordFilePath(sKey)
	dData.record_pid = g_AttrCtrl.pid
	local dSave = {records=self.m_Records, data=dData}
	IOTools.SaveJsonFile(path, dSave)
	return path
end

function CNetCtrl.LoadRecordsFromLocal(self, sKey)
	local path
	if string.find(sKey, "/") then
		path = sKey
	else
		path = self:GetRecordFilePath(sKey)
	end
	local lRecords = IOTools.LoadJsonFile(path)
	return lRecords
end

function CNetCtrl.PlayRecord(self, sKey)
	local dData = self:LoadRecordsFromLocal(sKey)
	if dData and #dData.records > 0 then
		print("播放录像:", sKey,"长度:",#dData.records, "录像者id:",dData.pid)
		self.m_RecordData = dData.data or {}
		for i, v in ipairs(dData.records) do
			self:Receive(v)
		end
	else
		print("录像为空:", sKey)
	end
end

function CNetCtrl.GetRecordValue(self, sKey)
	if self.m_RecordData then
		return self.m_RecordData[sKey]
	end
end

function CNetCtrl.GetRecordData(self)
	return self.m_RecordData
end

function CNetCtrl.IsProtoRocord(self)
	return self.m_RecordData ~= nil
end

function CNetCtrl.SaveRecordsToServer(self, sKey, dData)
	local path = self:SaveRecordsToLocal(sKey, dData)
	g_QiniuCtrl:UploadFile(sKey, path, enum.QiniuType.None, callback(self, "OnUploadResult", path))
end

function CNetCtrl.OnUploadResult(self, path, key, sucess)
	if sucess then
		g_NotifyCtrl:FloatMsg("上传成功")
	else
		g_NotifyCtrl:FloatMsg("上传失败")
	end
	IOTools.Delete(path)
end

function CNetCtrl.GetRecordsFromServer(self, sKey)

end
--协议录像 end


--队长状态下，检测客户端是否处于长时间无操作
function CNetCtrl.CheckClientStatus(self, sSubType)
	--  if sSubType ~= "C2GSHeartBeat" and sSubType ~= "C2GSSetActive" 
	-- 	and g_TeamCtrl:IsLeader() and not g_WarCtrl:IsWar() then
	-- 	self:SetClientStatus(true)
	-- 	if not g_TeamCtrl:IsLeaderActive() then
	-- 		self:SetClientStatus(false)
	-- 		-- netother.C2GSSetActive(1)
	-- 	end
	-- end

	-- if sSubType ~= "C2GSHeartBeat" and sSubType ~= "C2GSSetActive" 
	-- 	and g_TeamCtrl:IsLeader() and not g_WarCtrl:IsWar() then
	-- 	g_CountdownTimerCtrl:DelRecord(g_CountdownTimerCtrl.Type.NetActionCheck, 0)
	-- 	if not self.m_IsClientActive then
	-- 		self.m_IsClientActive = true
	-- 		netother.C2GSSetActive(1)
	-- 	end
	-- 	local function SendRequest()
	-- 		if not g_TeamCtrl:IsLeader() then
	-- 			return
	-- 		end
	-- 		netother.C2GSSetActive(0)
	-- 		self.m_IsClientActive = false
	-- 	end
	-- 	local iTime = DataTools.GetGlobalData(106).value or 12
	-- 	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.NetActionCheck, 0, iTime*60, SendRequest)
	-- end
end

function CNetCtrl.SetClientStatus(self, bIsActive)
	self.m_IsClientActive = bIsActive
end

function CNetCtrl.GetClientStatus(self)
	return self.m_IsClientActive
end

function CNetCtrl.ShowReloginConfirm(self)
	local args ={
		title = "网络断开",
		msg = "网络异常，连接服务器失败",
		okStr = "重连",
		okCallback = function()
			self:AutoReconnect()
		end,
		cancelStr = "返回登录",
		cancelCallback = function()
			self.m_ReconnectCnt = 0
			self:DelReconnectTimer()
			g_LoginPhoneCtrl:ResetAllData()
		    CLoginPhoneView:ShowView(function (oView)
				oView:RefreshUI()
				--这里是在有中心服的数据情况下
				if g_LoginPhoneCtrl.m_IsQrPC then
					g_ServerPhoneCtrl:OnEvent(define.Login.Event.ServerListSuccess)
				end
			end)
		end,
		closeType = 3,
		isOkNotClose = true,
		hideClose = true,
		pivot = enum.UIWidget.Pivot.Center,
	}
	g_WindowTipCtrl:SetWindowNetConfirm(args, function (oView)
		self.m_NetConfirmView = oView
	end)
	g_MapCtrl:ClearFootPoint()
	g_TimeCtrl:StopBeat()
	g_TimeCtrl:StopCheckClientStatus()
	g_NotifyCtrl:ShowNetCircle(false)
	g_LoginPhoneCtrl.m_Logined = false
end

function CNetCtrl.OnSocketException(self)
	printc("CNetCtrl.OnSocketEvent 销毁m_MainNetObj")
	if self.m_MainNetObj then
		self.m_MainNetObj:Release()
		self.m_MainNetObj = nil
	end
	if self.m_ReconnectCnt >= self.m_MaxReconnectCnt then
		self:ShowReloginConfirm()
	else
		self:DelReconnectTimer()
		self.m_ReconnectTimer = Utils.AddTimer(function()
			self:AutoReconnect()
			g_LoginPhoneCtrl.m_Logined = false
		end, 0, 1)
		self.m_ReconnectCnt = self.m_ReconnectCnt + 1
	end
end

function CNetCtrl.DelReconnectTimer(self)
	if self.m_ReconnectTimer then
		Utils.DelTimer(self.m_ReconnectTimer)
		self.m_ReconnectTimer = nil
	end
end

return CNetCtrl
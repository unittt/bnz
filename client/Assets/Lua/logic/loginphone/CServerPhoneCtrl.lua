local CServerPhoneCtrl = class("CServerPhoneCtrl", CCtrlBase)

CServerPhoneCtrl.g_DevServer = {
	servers = {
		-- 配置的两种方式
		-- [2001]={id = 2001, name="服务器名称1", ip="192.168.8.112", new=0, port = {6011,6012,26011,26012,26013}, serverindex = 89},
		-- [2002]={id = 2002, name="服务器名称2", ip="120.132.20.98",	new=0, serverindex = 16},

		-- devh7d.demigame.com
		-- [1001]={id=1001, name="商务服(外)", ip="47.100.195.150", new=1, serverindex=9999-1001},

		-- 机器人外网测试
		-- [1001]={id=1001, name="压测服(外机器人)", ip="testh7d.demigame.com", new=1, serverindex=9999-1001},

		-- 内服
		[1001]={id=1001, name="zc内服开发服", ip="47.92.37.250", new=1, serverindex=9999-1001},

	},
	common_port = {7011,7012,27011,27012,27013},
}
CServerPhoneCtrl.g_ReleaseServer = {
	servers ={
		[2001]={id=2001,name="zc开发服",ip="47.92.37.250",new=1,serverindex=100}
	},
	common_port = {7011,7012,27011,27012,27013},
}
CServerPhoneCtrl.g_YunceServer = {
	servers ={
		[3001]={id = 3001, name="zc云测服", ip="47.92.37.250",new=0, serverindex = 100}
	},
	common_port = {7011,7012,27011,27012,27013},
}

function CServerPhoneCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_PostServerData = {}

	self.m_ServerRoleData = {}
	self.m_ServerRolePidList = {}
	self.m_ServerOrderRoleData = {}
	self.m_ServerData = {}
	if g_LoginPhoneCtrl.m_IsPC then
		if gameconfig.Model.YunceModel then
			table.copy(CServerPhoneCtrl.g_YunceServer, self.m_ServerData)
		else
			table.copy(CServerPhoneCtrl.g_DevServer, self.m_ServerData)
		end
		self:CheckServerOrderData()
		self.m_ServerListCount = #self.m_ServerSortData.servers
	else
		--注意g_LoginPhoneCtrl初始化在g_ServerPhoneCtrl之前
		if not g_LoginPhoneCtrl.m_IsUseBack then
			table.copy(CServerPhoneCtrl.g_ReleaseServer, self.m_ServerData)
			self:CheckServerOrderData()
			self.m_ServerListCount = #self.m_ServerSortData.servers
		end
		--另外一种情况SetUpServerData
	end	
end

function CServerPhoneCtrl.IsNewArea(self)
	if next(self.m_PostServerData) and self.m_PostServerData.info.server_info.AreaName then
		return true
	end
	return false
end

--servers和allservers的serverindex不关联，serverindex的数据分别独立的
function CServerPhoneCtrl.SetUpServerData(self)
	if g_LoginPhoneCtrl.m_IsUseBack then
		local list = {}
		list.servers = {}
		list.allservers = {}
		list.common_port = {}

		if self:IsNewArea() then
			table.copy(self.m_PostServerData.info.server_info.serverInfoList, list.servers)
		else
			for k,v in pairs(self.m_PostServerData.info.server_info.serverInfoList) do
				--先锋体验区不在正式区里面
				if self:IsNewArea() then
					if v.area then
						if type(v.area) == "table" then
							-- if not table.index(v.area, 1) then
								table.insert(list.servers, v)
							-- end
						elseif not v.area == 1 then
							table.insert(list.servers, v)
						end
					else
						table.insert(list.servers, v)
					end
				else
					if not (v.area and v.area == 1) then
						table.insert(list.servers, v)
					end
				end
			end
		end
		table.copy(self.m_PostServerData.info.server_info.serverInfoList, list.allservers)
		table.copy(self.m_PostServerData.info.server_info.ports, list.common_port)
		table.copy(list, self.m_ServerData)
	
		table.sort(self.m_ServerData.servers, function (a, b) return a.index < b.index end)
		table.sort(self.m_ServerData.allservers, function (a, b) return a.index < b.index end)
		for k,v in ipairs(self.m_ServerData.servers) do
			v.serverindex = k
		end
		for k,v in ipairs(self.m_ServerData.allservers) do
			v.serverindex = k
		end

		self:CheckServerOrderData()
		self.m_ServerListCount = #self.m_ServerSortData.servers
	end
end

function CServerPhoneCtrl.GetCommonPort(self, serverInfo)
	if serverInfo and serverInfo.port then
		return serverInfo.port
	end
	return self.m_ServerData.common_port
end

--获取当前链接的服务器名字
function CServerPhoneCtrl.GetCurServerName(self)
	local oServerData 
	if self.m_ServerSortData.allservers then
		oServerData = self.m_ServerSortData.allservers
	else
		oServerData = self.m_ServerSortData.servers
	end
	local ip = g_NetCtrl:GetNetObj():GetIP()
	local port = g_NetCtrl:GetNetObj():GetPort()
	if oServerData then
		for _, ser in pairs(oServerData) do
			if ser.ip == ip then
				local portList = ser.port and ser.port or self.m_ServerSortData.common_port
				if table.index(portList, port) then
					return ser.name
					-- if not ser.linkserver or (ser.linkserver and ser.id == ser.linkserver) then
					-- 	return ser.name
					-- else
					-- 	return g_ServerPhoneCtrl:GetServerOrderDataById(ser.linkserver).name
					-- end
				end
			end
		end
	end
	return "未知服务器"
end

--获取当前链接的服务器数据
function CServerPhoneCtrl.GetCurServerData(self)	
	if g_NetCtrl:GetNetObj() then
		local oServerData 
		if self.m_ServerSortData.allservers then
			oServerData = self.m_ServerSortData.allservers
		else
			oServerData = self.m_ServerSortData.servers
		end
		local ip = g_NetCtrl:GetNetObj():GetIP()
		local port = g_NetCtrl:GetNetObj():GetPort()
		if oServerData then
			for _, ser in pairs(oServerData) do
				if ser.ip == ip then
					local portList = ser.port and ser.port or self.m_ServerSortData.common_port
					if table.index(portList, port) then
						return ser
						-- if not ser.linkserver or (ser.linkserver and ser.id == ser.linkserver) then
						-- 	return ser
						-- else
						-- 	return g_ServerPhoneCtrl:GetServerOrderDataById(ser.linkserver)
						-- end
					end
				end
			end
		end
	end
end

--获取某个ip的服务器数据
function CServerPhoneCtrl.GetServerDataByIp(self, ip)
	local oServerData 
	if self.m_ServerSortData.allservers then
		oServerData = self.m_ServerSortData.allservers
	else
		oServerData = self.m_ServerSortData.servers
	end
	for _, ser in pairs(oServerData) do
		if ser.ip == ip then
			return ser
			-- if not ser.linkserver or (ser.linkserver and ser.id == ser.linkserver) then
			-- 	return ser
			-- else
			-- 	return g_ServerPhoneCtrl:GetServerOrderDataById(ser.linkserver)
			-- end
		end
	end
end

function CServerPhoneCtrl.GetServerByName(self, sServerName)
	local oServerData 
	if self.m_ServerSortData.allservers then
		oServerData = self.m_ServerSortData.allservers
	else
		oServerData = self.m_ServerSortData.servers
	end
	for _, ser in pairs(oServerData) do
		if ser.name == sServerName then		
			return ser
		end
	end
end

------------------请求服务器列表------------------

function CServerPhoneCtrl.PostServerList(self, data)

	local url = g_UrlRootCtrl.m_CSRootUrl.."loginverify/verify_account"

	printc("CServerPhoneCtrl.PostServerList data account", data.account)
	table.print(data, "CServerPhoneCtrl.PostServerList data")
	printc("CServerPhoneCtrl.PostServerList url:", url)

	local path = IOTools.GetPersistentDataPath("/serverlistData")
	IOTools.SaveJsonFile(path, data)
	local saveData = IOTools.LoadJsonFile(path)
	
	printc("CServerPhoneCtrl.PostServerList saveData account", saveData.account)
	table.print(saveData, "CServerPhoneCtrl.PostServerList saveData")

	local handler = C_api.FileHandler.OpenByte(path)
	if not handler then
		printc("CServerPhoneCtrl.PostServerList no handler")
		return
	end
	local bytes = handler:ReadByte()
	handler:Close()

	-- local bytes = IOTools.LoadByteFile(path)
	-- local bytes = string.byte(cjson.encode(data))
	local headers = {
		["Content-Type"]="application/json;charset=utf-8",
	}
	g_HttpCtrl:Post(url, callback(self, "OnServerListResult"), headers, bytes, {json_result=true})

	-- 请求服务器转圈圈
	g_NotifyCtrl:ShowNetCircle(true, "加载中...")
end



function CServerPhoneCtrl.OnServerListResult(self, success, tResult)
	g_NotifyCtrl:ShowNetCircle(false)
	if success then
		print("get serverlist success")
		table.print(tResult, "CServerPhoneCtrl.OnServerListResult")

		--只是测试使用，android模拟器上看到的信息不完整
		local path = IOTools.GetPersistentDataPath("/serverRoleData")
		IOTools.SaveJsonFile(path, tResult)
		local roleData = IOTools.LoadJsonFile(path)

		--返回两个数据errcode(0:成功 1:失败) info 是table,结构见下边,
		--注意server是string字符串
		--info一个子元素也是table{server = true, pid = true,icon = true, name = true, school = true, grade = true,}

		if tResult.errcode == 0 then
			for k,v in pairs(tResult.info) do
				table.print(v, "CServerPhoneCtrl.OnServerListResult tResult.info:"..k)
			end
			self.m_PostServerData = {}
			table.copy(tResult, self.m_PostServerData)
			g_ServerPhoneCtrl:SetUpServerData()

			self.m_ServerRoleData = {}
			table.copy(tResult.info.role_list, self.m_ServerRoleData)
			self:CheckServerRoleData()
			--服务器的refreshtime的计时
			self:SetServerRefreshTime()
			self:OnEvent(define.Login.Event.ServerListSuccess)


			if g_GameDataCtrl:GetChannel() == "demi" then	
				-- 德米热云、广告相关 Beging
				tResult.info.first_register = (tResult.info.first_register ~= nil and tResult.info.first_register ~= "") and tResult.info.first_register or "0"
				tResult.info.first_register_for_phone = (tResult.info.first_register_for_phone ~= nil and tResult.info.first_register_for_phone ~= "") and tResult.info.first_register_for_phone or "0"
				printc("tResult.info.first_register:", tResult.info.first_register, " tResult.info.uid:", tResult.info.uid, " ", tonumber(tResult.info.first_register) == 1)
				local str_ad_app_id = "1001"
				local str_ad_activity_id = "10000"
				local str_ad_system_id = 1
				local str_idfa = ""
				local str_imei = ""

				if Utils.IsIOS() then
					str_ad_app_id = C_api.SPSdkManager.Instance:GetAdAppIdForIOS()
					str_ad_activity_id = C_api.SPSdkManager.Instance:GetAdActivityIdForIOS()
					str_ad_system_id = 2
					str_idfa = C_api.PlatformAPI.GetDeviceId()
				else
					str_ad_app_id = Utils.GetAndroidMeta("demi_ad_appId")
					str_ad_activity_id = Utils.GetAndroidMeta("demi_ad_activity_id")
					str_ad_system_id = 1
					str_imei = C_api.PlatformAPI.GetDeviceId()
				end

				local ad_url = define.DemiAD.Url_dev
				local csroot = g_GameDataCtrl:GetCSRoot()
				if string.find(csroot, "csh7d") then
					ad_url = define.DemiAD.Url_release
				else
					ad_url = define.DemiAD.Url_dev
				end

				printc("ad_app_id:", str_ad_app_id, " ad_activity_id:", str_ad_activity_id, " ad_system_id:", str_ad_system_id, " idfa:", str_idfa, " imei:", str_imei)

				if tonumber(tResult.info.first_register) == 1 then
					--广告埋点 2:注册
					local advContent = string.format("do=%s&app_id=%s&activity_id=%s&system_id=%d&mac=%s&idfa=%s&imei=%s&user_name=%s", "reg", str_ad_app_id, str_ad_activity_id, str_ad_system_id, Utils.GetMac(), str_idfa, str_imei, tResult.info.uid)
					printc("advContent:", advContent)
					local advContent = IOTools.EncodeString(advContent)
					local advSign = Utils.MD5HashString(advContent.."&"..define.DemiAD.Key)
					local advData = "data="..advContent.."&sign="..advSign
					g_HttpCtrl:PostHttp(ad_url, "data", advContent, "sign", advSign)
				end

				--广告埋点 3:登陆
				local advContent = string.format("do=%s&app_id=%s&activity_id=%s&system_id=%d&mac=%s&idfa=%s&imei=%s&user_name=%s", "login", str_ad_app_id, str_ad_activity_id, str_ad_system_id, Utils.GetMac(), str_idfa, str_imei, tResult.info.uid)
				printc("advContent:", advContent)
				local advContent = IOTools.EncodeString(advContent)
				local advSign = Utils.MD5HashString(advContent.."&"..define.DemiAD.Key)
				local advData = "data="..advContent.."&sign="..advSign
				g_HttpCtrl:PostHttp(ad_url, "data", advContent, "sign", advSign)
				

				--热云埋点
				if tonumber(tResult.info.first_register_for_phone) == 1 then
					C_api.SPSdkManager.Instance:TrackingioRegister(tResult.info.uid) --既注册也登陆		
				else 
					C_api.SPSdkManager.Instance:TrackingioLogin(tResult.info.uid) --仅登陆
				end
				-- 德米热云、广告相关 End
			end	
		end
	else
		print("get serverlist err")
	end
end

function CServerPhoneCtrl.OnAdvertisingRegisterCB(self, data)
	printc("CSdkCtrl.OnAdvertisingRegisterCB data:", data)
	table.print(data, "CSdkCtrl.OnAdvertisingRegisterCB")
	local ret = decodejson(data)
	if ret.code ~= nil and ret.code == 0 then
		printc("埋点广告注册 code:", ret.code, " message:", ret.message)
	else
		if ret.code ~= nil then
			printc("埋点广告注册 code:", ret.code, " message:", ret.message)
		else
			printc("埋点广告注册 result:error")
		end
	end 
end

function CServerPhoneCtrl.OnAdvertisingLoginCB(self, data)
	printc("CSdkCtrl.OnAdvertisingLoginCB data:", data)
	table.print(data, "CSdkCtrl.OnAdvertisingLoginCB")
	local ret = decodejson(data)
	if ret.code ~= nil and ret.code == 0 then
		printc("埋点广告登录 code:", ret.code, " message:", ret.message)
	else
		if ret.code ~= nil then
			printc("埋点广告登录 code:", ret.code, " message:", ret.message)
		else
			printc("埋点广告登录 result:error")
		end
	end 
end

--更新中心服角色信息使用
function CServerPhoneCtrl.PostServerRoleList(self, data)

	local url = g_UrlRootCtrl.m_CSRootUrl.."loginverify/query_role_list"

	local path = IOTools.GetPersistentDataPath("/serverrolelistData")
	IOTools.SaveJsonFile(path, data)

	local handler = C_api.FileHandler.OpenByte(path)
	if not handler then
		return
	end
	local bytes = handler:ReadByte()
	handler:Close()

	local headers = {
		["Content-Type"]="application/json;charset=utf-8",
	}
	g_HttpCtrl:Post(url, callback(self, "OnServerRoleListResult"), headers, bytes, {json_result=true})
end

function CServerPhoneCtrl.OnServerRoleListResult(self, success, tResult)
	if success then
		print("get OnServerRoleListResult success")
		table.print(tResult, "CServerPhoneCtrl.OnServerRoleListResult")

		if tResult.errcode == 0 then
			self.m_ServerRoleData = {}
			table.copy(tResult.role_list, self.m_ServerRoleData)
			self:CheckServerRoleData()
		end
	else
		print("get OnServerRoleListResult err")
	end
end

--删除中心服角色信息使用
function CServerPhoneCtrl.PostDeleteRoleList(self, data)
	local url = g_UrlRootCtrl.m_CSRootUrl.."loginverify/delete_role"
	local path = IOTools.GetPersistentDataPath("/serverroledeleteData")
	IOTools.SaveJsonFile(path, data)

	local handler = C_api.FileHandler.OpenByte(path)
	if not handler then
		return
	end
	local bytes = handler:ReadByte()
	handler:Close()

	local headers = {
		["Content-Type"]="application/json;charset=utf-8",
	}
	g_HttpCtrl:Post(url, callback(self, "OnServerRoleDeleteResult", data.pid), headers, bytes, {json_result=true})
end

function CServerPhoneCtrl.OnServerRoleDeleteResult(self, oPid, success, tResult)
	if success then
		print("get OnServerRoleDeleteResult success")
		print("选择要删除的角色Pid:"..oPid)
		table.print(tResult, "CServerPhoneCtrl.OnServerRoleDeleteResult")

		if tResult.errcode == 0 then
			g_NotifyCtrl:FloatMsg("角色删除成功")
			for k,v in pairs(self.m_ServerRoleData) do
				if v.pid == oPid then
					table.remove(self.m_ServerRoleData, k)
					break
				end
			end
			self:CheckServerRoleData()
			self:OnEvent(define.Login.Event.ServerListSuccess)
		elseif tResult.errcode == 1 then
			g_NotifyCtrl:FloatMsg("ID错误无法删除")
		elseif tResult.errcode == 2 then
			g_NotifyCtrl:FloatMsg("不能删除等级最高的角色")
		elseif tResult.errcode == 3 then
			g_NotifyCtrl:FloatMsg("10级以上角色不允许删除！")
		elseif tResult.errcode == 4 then
			g_NotifyCtrl:FloatMsg("该角色有进行充值不能删除")
		end
	else
		print("get OnServerRoleDeleteResult err")
	end
end

---------------以下是管理数据--------------

--注意，一般是使用self.m_ServerSortData(里面serverindex字段值有可能不同并且m_ServerSortData才会有角色数据)来获取服务器列表数据，不用self.m_ServerData
--self.m_ServerSortData里面的serverindex必定连续，而self.m_ServerData的serverindex未必
function CServerPhoneCtrl.GetServerData(self)
	return self.m_ServerData
end

--注意，self.m_ServerSortData.servers并不是完整的服务器列表数据，不包括先锋体验区的数据
function CServerPhoneCtrl.CheckServerOrderData(self)
	self.m_ServerSortData = {}
	self.m_ServerSortData.servers = {}
	self.m_ServerSortData.common_port = {}
	table.copy(self.m_ServerData.common_port, self.m_ServerSortData.common_port)
	for k,v in pairs(self.m_ServerData.servers) do
		table.insert(self.m_ServerSortData.servers, v)
	end
	table.sort(self.m_ServerSortData.servers, function(a, b) return a.serverindex < b.serverindex end)
	for k,v in ipairs(self.m_ServerSortData.servers) do
		v["serverindex"] = k
		if g_LoginPhoneCtrl.m_IsPC then
			v.role = {}
			table.insert(v.role, {server = v.id, pid = -1, login_time = 0})
		end
	end

	if self.m_ServerData.allservers then
		self.m_ServerSortData.allservers = {}
		table.copy(self.m_ServerData.allservers, self.m_ServerSortData.allservers)
		table.sort(self.m_ServerSortData.allservers, function(a, b) return a.serverindex < b.serverindex end)
		for k,v in ipairs(self.m_ServerSortData.allservers) do
			v["serverindex"] = k
			if g_LoginPhoneCtrl.m_IsPC then
				v.role = {}
				table.insert(v.role, {server = v.id, pid = -1, login_time = 0})
			end
		end
	end
end

function CServerPhoneCtrl.CheckServerRoleData(self)
	for k,v in pairs(self.m_ServerSortData.servers) do
		if v.role then
			v.role = nil
		end
	end
	if self.m_ServerSortData.allservers then
		for k,v in pairs(self.m_ServerSortData.allservers) do
			if v.role then
				v.role = nil
			end
		end
	end
	for k,v in pairs(self.m_ServerRoleData) do
		for g,h in pairs(self.m_ServerSortData.servers) do
			if v.server == h.id then --or v.now_server == h.id
				if not h.role then
					h.role = {}
				end
				table.insert(h.role, v)
			end
		end

		if self.m_ServerSortData.allservers then
			for g,h in pairs(self.m_ServerSortData.allservers) do
				if v.server == h.id then --or v.now_server == h.id
					if not h.role then
						h.role = {}
					end
					table.insert(h.role, v)
				end
			end
		end
	end
	for k,v in pairs(self.m_ServerSortData.servers) do		
		-- if v.id ~= v.linkserver then
		-- 	v.role = g_ServerPhoneCtrl:GetServerOrderDataById(v.linkserver).role
		-- end
		if not v.role then
			v.role = {}
		end
		if table.count(v.role) < 3 and not self:CheckRoleAddExist(v.role) then
			table.insert(v.role, {server = v.id, pid = -1, login_time = 0})
		end
		table.sort(v.role, function(a, b)
			if a.login_time ~= b.login_time then
				return a.login_time > b.login_time
			else
				return a.pid > b.pid end
			end
		)
	end
	if self.m_ServerSortData.allservers then
		for k,v in pairs(self.m_ServerSortData.allservers) do			
			-- if v.id ~= v.linkserver then
			-- 	v.role = g_ServerPhoneCtrl:GetServerOrderDataById(v.linkserver).role
			-- end
			if not v.role then
				v.role = {}
			end
			if table.count(v.role) < 3 and not self:CheckRoleAddExist(v.role) then
				table.insert(v.role, {server = v.id, pid = -1, login_time = 0})
			end
			table.sort(v.role, function(a, b)
				if a.login_time ~= b.login_time then
					return a.login_time > b.login_time
				else
					return a.pid > b.pid end
				end
			)
		end
	end

	self.m_ServerRolePidList = {}
	self.m_ServerOrderRoleData = {}
	table.copy(self.m_ServerRoleData, self.m_ServerOrderRoleData)
	for k,v in pairs(self.m_ServerOrderRoleData) do
		local serverData = self:GetServerOrderDataById(v.server)
		--合服相关
		-- if v.now_server and v.now_server ~= "" then
		-- 	serverData = self:GetServerOrderDataById(v.now_server)
		-- else
		-- 	serverData = self:GetServerOrderDataById(v.server)
		-- end
		if serverData then
			v.serverindex = serverData.serverindex
			v.servername = serverData.name
			v.state = serverData.state or 0
		end

		table.insert(self.m_ServerRolePidList, v.pid)
	end
end

function CServerPhoneCtrl.CheckRoleAddExist(self, oRoleData)
	if not oRoleData or not next(oRoleData) then
		return false
	end
	for k,v in pairs(oRoleData) do
		if v.pid == -1 then
			return true
		end
	end
	return false
end

function CServerPhoneCtrl.GetServerOrderDataById(self, id)
	local oServerData 
	if self.m_ServerSortData.allservers then
		oServerData = self.m_ServerSortData.allservers
	else
		oServerData = self.m_ServerSortData.servers
	end
	for k,v in pairs(oServerData) do
		if v.id == id then
			return v
		end
	end
end

function CServerPhoneCtrl.CheckServerRoleExist(self, serverid, pid)
	local server = self:GetServerOrderDataById(serverid)
	if server then
		for k,v in pairs(server.role) do
			if v.pid == pid then
				return v
			end
		end
	end
end

function CServerPhoneCtrl.GetServerRoleCount(self, serverid)
	local server = self:GetServerOrderDataById(serverid)
	local oCount = 0
	if server then
		for k,v in pairs(server.role) do
			if v.pid ~= -1 then
				oCount = oCount + 1
			end
		end
	end
	return oCount
end

function CServerPhoneCtrl.GetRoleList(self)
	--最近登录的排在最前面（只需记录一个就好了）
	--剩余的按服务器序号排序
	local list = {}
	if g_LoginPhoneCtrl.m_IsPC then
		return list
	end
	table.copy(self.m_ServerOrderRoleData, list)
	table.sort(list, function(a, b) return a.serverindex > b.serverindex end)
	local _, dRole = g_LoginPhoneCtrl:GetLocalServerAndRoleData() --(g_LoginPhoneCtrl:GetLoginPhoneServerData() and {g_LoginPhoneCtrl:GetLoginPhoneServerData().role} or {nil} )[1]
	local key
	local val
	if dRole and dRole.server and dRole.pid then
		for k,v in pairs(list) do
			if v.server == dRole.server and v.pid == dRole.pid then
				key = k
				val = v
				break
			end
		end
	end
	if key and val then
		table.remove(list, key)
		table.insert(list, 1, val)
	end
	return list
end

function CServerPhoneCtrl.GetTuijianServerList(self)
	local list = {}

	if g_LoginPhoneCtrl.m_IsPC then
		local serverList = self:GetServerList()
		local beforeServerList = self:GetBeforeServerList()
		if next(serverList) then
			table.insert(list, serverList[#serverList])
		else
			table.insert(list, beforeServerList[#beforeServerList])
		end
	else
		if g_LoginPhoneCtrl.m_IsUseBack then
			if self.m_PostServerData and self.m_PostServerData.info and self.m_PostServerData.info.server_info.RecommendServerList and next(self.m_PostServerData.info.server_info.RecommendServerList) then
				local isHasList = false
				for k,v in pairs(self.m_PostServerData.info.server_info.RecommendServerList) do
					local server = self:GetServerOrderDataById(v)
					if server then
						table.insert(list, server)
						isHasList = true
					end
				end
				if not isHasList then
					local serverList = self:GetServerList()
					local beforeServerList = self:GetBeforeServerList()
					if next(serverList) then
						table.insert(list, serverList[#serverList])
					else
						table.insert(list, beforeServerList[#beforeServerList])
					end
				end
			else
				local serverList = self:GetServerList()
				local beforeServerList = self:GetBeforeServerList()
				if next(serverList) then
					table.insert(list, serverList[#serverList])
				else
					table.insert(list, beforeServerList[#beforeServerList])
				end
			end
		else
			local serverList = self:GetServerList()
			local beforeServerList = self:GetBeforeServerList()
			if next(serverList) then
				table.insert(list, serverList[#serverList])
			else
				table.insert(list, beforeServerList[#beforeServerList])
			end
		end
	end

	table.sort(list, function(a, b) return a.serverindex > b.serverindex end)
	return list
end

--先锋体验区列表
function CServerPhoneCtrl.GetBeforeServerList(self)
	local list = {}
	--[[
	-- 没有先锋体验区的概念了
	if self.m_ServerSortData and self.m_ServerSortData.allservers then
		for k,v in pairs(self.m_ServerSortData.allservers) do
			if self:IsNewArea() then
				if v.area then
					-- 兼容table
					if type(v.area) == "table" then
						if table.index(v.area, 1) then
							table.insert(list, v)
						end
					elseif v.area == 1 then
						table.insert(list, v)
					end
				end
			else
				if v.area and v.area == 1 then
					table.insert(list, v)
				end
			end
		end
		if next(list) then
			table.sort(list, function(a, b) return a.serverindex > b.serverindex end)
		end
	end
	]]--
	return list
end

--在本地没有记录服务器文件的情况下，获取最近登录的服务器
function CServerPhoneCtrl.GetRecentServer(self)
	if not g_LoginPhoneCtrl.m_IsPC then
		local list = {}
		table.copy(self.m_ServerRoleData, list)
		table.sort(list, function (a, b)
			return a.login_time > b.login_time
		end)
		if list[1] and list[1].login_time ~= 0 then
			return g_ServerPhoneCtrl:GetServerOrderDataById(list[1].server) --(list[1].now_server or list[1].server)			
		else
			return g_ServerPhoneCtrl:GetTuijianServerList()[1]
		end
	end
	return g_ServerPhoneCtrl:GetTuijianServerList()[1]
end

function CServerPhoneCtrl.GetServerTypeName(self, typeIndex)
	local name = typeIndex .. "区"
	if self.m_PostServerData and self.m_PostServerData.info.server_info.AreaName then
		local typeName = self.m_PostServerData.info.server_info.AreaName[typeIndex]
		if typeName then
			name = typeName
		end
	end
	return name
end

function CServerPhoneCtrl.GetServerTypeList(self)
	self.m_ServerListCount = #self:GetServerList()
	if self.m_ServerListCount <= 0 then
		return {}
	end
	local list = {}
	if self:IsNewArea() then
		for _,v in ipairs(self.m_ServerSortData.servers) do
			if type(v.area) == "table" then
				for _,area in ipairs(v.area) do
					if table.index(g_SdkCtrl.m_DemiChannelAreaList, area) then
						if not table.index(list, area) then
							table.insert(list, area)
						end
					end
				end
			elseif table.index(g_SdkCtrl.m_DemiChannelAreaList, v.area) then
				if not table.index(list, v.area) then
					table.insert(list, v.area)
				end
			end
		end
	else
		local index = 0
		repeat
			index = index + 1
			if index == 1 then
				table.insert(list, 1, {1, 20})
			else
				table.insert(list, 1, {20*(index-1)+1, 20*index})
			end
		until index*20 > self.m_ServerListCount
	end
	return list
end

function CServerPhoneCtrl.GetServerList(self)
	if not self.m_ServerSortData then
		return {}
	else
		return self.m_ServerSortData.servers
	end
end

function CServerPhoneCtrl.GetServerListByIndex(self, oData)
	local list = {}
	local serverList = self:GetServerList()
	if self:IsNewArea() then
		for _,v in ipairs(serverList) do
			if table.index(v.area, oData) then
				table.insert(list, v)
			end
		end
	else
		for i= oData[1], oData[2] do
			if serverList[i] then
				table.insert(list, serverList[i])
			end
		end
	end
	table.sort(list, function(a, b) return a.serverindex > b.serverindex end)
	return list
end

--主要是更新角色信息
function CServerPhoneCtrl.UpdateGSData(self)
	if not g_LoginPhoneCtrl.m_IsPC then
		if not next(g_ServerPhoneCtrl.m_PostServerData) or not g_ServerPhoneCtrl.m_PostServerData.info.token then
			return
		end
        local needData = {token = g_ServerPhoneCtrl.m_PostServerData.info.token}
        g_ServerPhoneCtrl:PostServerRoleList(needData)
    end
end

--主要是删除角色
function CServerPhoneCtrl.UpdateDeleteRoleData(self, oPid)
	if not g_LoginPhoneCtrl.m_IsPC then
		if not next(g_ServerPhoneCtrl.m_PostServerData) or not g_ServerPhoneCtrl.m_PostServerData.info.token then
			return
		end
        local needData = {account_token = g_ServerPhoneCtrl.m_PostServerData.info.token, pid = tonumber(oPid)}
        g_ServerPhoneCtrl:PostDeleteRoleList(needData)
    end
end

--------------服务器状态相关-------------

--0 流畅 1 火爆 2 繁忙  3 维护
function CServerPhoneCtrl.GetServerStateSpriteName(self, state)
	if state == 0 then
		return "h7_lv_2"
	elseif state == 1 then
		return "h7_hong"
	elseif state == 2 then
		return "h7_huang_1"
	elseif state == 3 then
		return "h7_hui"
	else
		return "h7_lv_2"
	end
end

--每隔5min请求gs信息的计时
function CServerPhoneCtrl.SetServerRequestGSTime(self, delayTime)
	if g_AttrCtrl.pid ~= 0 then
		return
	end
	if g_LoginPhoneCtrl.m_IsPC then
		return
	end
	self:ResetServerRequestGSTimer()
	local function progress()
		--更新中心服数据
		g_ServerPhoneCtrl:UpdateGSData()
		return true
	end
	self.m_ServerRequestGSTimer = Utils.AddTimer(progress, 300, delayTime or 0)
end

function CServerPhoneCtrl.ResetServerRequestGSTimer(self)
	if self.m_ServerRequestGSTimer then
		Utils.DelTimer(self.m_ServerRequestGSTimer)
		self.m_ServerRequestGSTimer = nil			
	end
end

function CServerPhoneCtrl.GetServerRefreshTime(self)
	local oServerData 
	if self.m_ServerSortData.allservers then
		oServerData = self.m_ServerSortData.allservers
	else
		oServerData = self.m_ServerSortData.servers
	end
	local refreshTime = 0
	local markServerTime = -1
	for k,v in pairs(oServerData) do
		if v.refreshtime and markServerTime == -1 then
			markServerTime = v.refreshtime
		elseif v.refreshtime and markServerTime ~= -1 then
			if markServerTime > v.refreshtime then
				markServerTime = v.refreshtime
			end
		end
	end
	if markServerTime ~= -1 then
		refreshTime = markServerTime
	end
	return refreshTime
end

--服务器的refreshtime的计时
function CServerPhoneCtrl.SetServerRefreshTime(self)
	if g_AttrCtrl.pid ~= 0 then
		return
	end
	if g_LoginPhoneCtrl.m_IsPC then
		return
	end
	local refreshTime = self:GetServerRefreshTime()
	if refreshTime > 0 then
		self:ResetServerRefreshTimer()
		local function progress()
			--更新中心服数据
			g_ServerPhoneCtrl:UpdateGSData()			
			return false
		end
		self.m_ServerRefreshTimer = Utils.AddTimer(progress, 0, refreshTime)
	end
end

function CServerPhoneCtrl.ResetServerRefreshTimer(self)
	if self.m_ServerRefreshTimer then
		Utils.DelTimer(self.m_ServerRefreshTimer)
		self.m_ServerRefreshTimer = nil			
	end
end

return CServerPhoneCtrl
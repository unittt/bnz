local CKuafuCtrl = class("CKuafuCtrl", CCtrlBase)

function CKuafuCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_Test = true
	self.m_EnterKsPid = 0
	self.m_EnterKsData = {}
	self.m_BackGsData = {}
	self:Clear()
end

function CKuafuCtrl.Clear(self)
	
end

-- 是否跨服中
function CKuafuCtrl.IsInKS(self, bIsTip)
	if bIsTip and g_AttrCtrl.server_type == "ks" then
		g_NotifyCtrl:FloatMsg(data.textdata.TEXT[1109].content)
	end
	return g_AttrCtrl.server_type == "ks"
end

function CKuafuCtrl.GS2CTryEnterKS(self, pbdata)
	if pbdata.errcode == 0 then
		self.m_EnterKsPid = pbdata.pid
		self.m_EnterKsProtoData = pbdata
		--如果是在原服调这个，成功失败都没问题，如果是在跨服中调这个成功没问题，失败了还是会连这个跨服的ip
		self:ConnectEnterKs()
	else
		printc("开始连接跨服服务器，errcode不为0，连接不了跨服服务器")
		self:ConnectKsFailBackToGs()
	end
end

function CKuafuCtrl.ConnectEnterKs(self)
	if not self.m_EnterKsPid or self.m_EnterKsPid == 0 then
		printc("进入跨服服务器，self.m_EnterKsPid为0")
		self:ConnectKsFailBackToGs()
		return
	end
	--测试时暂时屏蔽
	if not self.m_Test then
		if not next(g_ServerPhoneCtrl.m_PostServerData) or not g_ServerPhoneCtrl.m_PostServerData.info.token then
			printc("进入跨服服务器，CLoginPhoneCtrl.OnServerHello 没有中心服数据 用户信息发生错误")
			self:ConnectKsFailBackToGs()
			return
		end
	end
	self:SetUpEnterKsData()
	printc("开始连接跨服服务器，ip和port", self.m_EnterKsProtoData.host, self.m_EnterKsProtoData.port)		
	--重要，标识是重连的连接
	g_LoginPhoneCtrl.m_IsReconnect = false
	--重要，处理连接不上跨服
	self.m_IsEnterKsConnect = true
	g_NetCtrl:ConnectServer(self.m_EnterKsProtoData.host, {self.m_EnterKsProtoData.port})
end

function CKuafuCtrl.ConnectKsFailBackToGs(self)
	local args ={
		title = "提示",
		msg = "进入跨服服务器失败",
		okStr = "返回原服",
		okCallback = function()
			self.m_ConnectKsFail = true
			local dLast = g_NetCtrl.m_LastIPAndPort
			--重要，标识是重连的连接
			g_LoginPhoneCtrl.m_IsReconnect = false
			g_LoginPhoneCtrl:ConnnectPhoneServer(dLast.ip, {dLast.port})
		end,
		cancelStr = "退出游戏",
		cancelCallback = function()
			Utils.QuitGame()
		end,
		closeType = 3,
		isOkNotClose = false,
		hideClose = true,
	}
	g_WindowTipCtrl:SetWindowNetConfirm(args)
end

function CKuafuCtrl.ConnectKsFailBackToGsTwo(self)
	local args ={
		title = "提示",
		msg = "进入跨服服务器失败",
		okStr = "返回原服",
		okCallback = function()
			self.m_ConnectKsFail = true
			local dLast = g_NetCtrl.m_LastIPAndPort
			--重要，标识是重连的连接
			g_LoginPhoneCtrl.m_IsReconnect = false
			g_LoginPhoneCtrl:ConnnectPhoneServer(dLast.ip, {dLast.port})
		end,
		cancelStr = "重新连接",
		cancelCallback = function()
			self:ConnectEnterKs()
		end,
		closeType = 3,
		isOkNotClose = false,
		hideClose = true,
	}
	g_WindowTipCtrl:SetWindowNetConfirm(args)
end

function CKuafuCtrl.ReConnectKs(self)
	local args ={
		title = "提示",
		msg = "重连跨服服务器失败",
		okStr = "重新连接",
		okCallback = function()
			self:ConnectEnterKs()
		end,
		cancelStr = "退出游戏",
		cancelCallback = function()
			Utils.QuitGame()
		end,
		closeType = 3,
		isOkNotClose = false,
		hideClose = true,
	}
	g_WindowTipCtrl:SetWindowNetConfirm(args)
end

function CKuafuCtrl.GS2CTryBackGS(self, pbdata)
	if g_AttrCtrl.pid == 0 then
		printc("从跨服服务器返回原本服务器，g_AttrCtrl.pid为0")
		return
	end
	--测试时暂时屏蔽
	if not self.m_Test then
		if not next(g_ServerPhoneCtrl.m_PostServerData) or not g_ServerPhoneCtrl.m_PostServerData.info.token then
			printc("从跨服服务器返回原本服务器，CLoginPhoneCtrl.OnServerHello 没有中心服数据 用户信息发生错误")
			return
		end
	end
	self:SetUpBackGsData()
	local oPort
	local oCurServerData = g_ServerPhoneCtrl:GetCurServerData()
	if oCurServerData then
		oPort = g_ServerPhoneCtrl:GetCommonPort(oCurServerData)
	else
		oPort = g_ServerPhoneCtrl:GetCommonPort()
	end 
	printc("从跨服返回，开始连接原本服务器，ip和port", pbdata.host)
	table.print(oPort, "原本服务器port列表")
	--重要，标识是重连的连接
	g_LoginPhoneCtrl.m_IsReconnect = false
	g_NetCtrl:ConnectServer(pbdata.host, oPort)
end

--主动请求
--调用此接口进入跨服服务器
function CKuafuCtrl.EnterKs(self, oKs, oHdname)
	netkuafu.C2GSTryEnterKS(oKs, oHdname)
end

--主动请求
--调用此接口返回原服务器
function CKuafuCtrl.BackGs(self)
	netkuafu.C2GSTryBackGS()
end

function CKuafuCtrl.SetUpEnterKsData(self)
	local _, v1, v2, v3 = C_api.Utils.GetResVersion()
	local version = string.format("%s.%s.%s",v1, v2, v3)
	local oServerKey = nil
	if g_LoginPhoneCtrl.m_PhoneChooseInfo.server then
		oServerKey = g_LoginPhoneCtrl.m_PhoneChooseInfo.server.id
		if g_ServerPhoneCtrl:IsNewArea() then
			oServerKey = g_LoginPhoneCtrl.m_PhoneChooseInfo.server.linkserver
		end
	end
	self.m_EnterKsData = {}
	self.m_EnterKsData.pid = self.m_EnterKsPid
	if not self.m_Test then
		self.m_EnterKsData.token = g_ServerPhoneCtrl.m_PostServerData.info.token
	end
	self.m_EnterKsData.serverkey = oServerKey
	self.m_EnterKsData.device = Utils.GetDeviceModel()
	self.m_EnterKsData.platform = g_LoginPhoneCtrl:GetPlatform()
	self.m_EnterKsData.mac = Utils.GetMac()
	self.m_EnterKsData.app_ver = gameconfig.Version.AppVer
	self.m_EnterKsData.imei = ""
	self.m_EnterKsData.os = UnityEngine.SystemInfo.operatingSystem
	self.m_EnterKsData.client_ver = version
	self.m_EnterKsData.udid = Utils.GetDeviceUID()
end

function CKuafuCtrl.SetUpBackGsData(self)
	local _, v1, v2, v3 = C_api.Utils.GetResVersion()
	local version = string.format("%s.%s.%s",v1, v2, v3)
	self.m_BackGsData = {}
	self.m_BackGsData.pid = g_AttrCtrl.pid
	if not self.m_Test then
		self.m_BackGsData.token = g_ServerPhoneCtrl.m_PostServerData.info.token
	end
	self.m_BackGsData.device = Utils.GetDeviceModel()
	self.m_BackGsData.platform = g_LoginPhoneCtrl:GetPlatform()
	self.m_BackGsData.mac = Utils.GetMac()
	self.m_BackGsData.app_ver = gameconfig.Version.AppVer
	self.m_BackGsData.imei = ""
	self.m_BackGsData.os = UnityEngine.SystemInfo.operatingSystem
	self.m_BackGsData.client_ver = version
	self.m_BackGsData.udid = Utils.GetDeviceUID()
end

return CKuafuCtrl
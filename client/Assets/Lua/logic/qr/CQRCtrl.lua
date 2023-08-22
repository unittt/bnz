local CQRCtrl = class("CQRCtrl", CCtrlBase)

function CQRCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_PCConnectPort = {10004, 10005, 10006, 10007, 10008, 10009}

	self.m_QrLeftTime = 0
	self.m_QrTransferData = {}
	self.m_QrCodeSid = ""
	self.m_DemiNotQrPlatform = 1    --1 android, 2 rootios, 3 ios, 4 pc
	self.m_DemiIsQr = true			--true 扫码，false 不扫码
end

function CQRCtrl.LateUpdate(self)
	local oView = CQRCodeScanView:GetView()
	if oView then
		oView:CheckQRUpdate()
	end
end

-------------PC上二维码服务器协议返回-------------

function CQRCtrl.GS2CQRCToken(self, pbdata)
	self.m_QrCodeSid = pbdata.token
	self:OnEvent(define.QR.Event.QRSid, pbdata)
	self:SetQrLeftTime(pbdata.validity)
end

function CQRCtrl.GS2CQRCScanSuccess(self, pbdata)
	self:OnEvent(define.QR.Event.QRCScanSuccess, pbdata)
end

function CQRCtrl.GS2CQRCAccountInfo(self, pbdata)
	local path = IOTools.GetPersistentDataPath("/qrAccountData")
	IOTools.SaveByteFile(path, pbdata.account_info)
	local accountData = IOTools.LoadJsonFile(path)
	table.print(accountData, "pc可以登录了，返回的信息accountData")

	local transferPath = IOTools.GetPersistentDataPath("/qrTransferData")
	IOTools.SaveByteFile(transferPath, pbdata.transfer_info)
	local transferData = IOTools.LoadJsonFile(transferPath)
	table.print(transferData, "pc可以登录了，返回的信息transferData")

	if accountData.errcode == 0 then
		g_ServerPhoneCtrl.m_PostServerData = {}
		table.copy(accountData, g_ServerPhoneCtrl.m_PostServerData)
		g_ServerPhoneCtrl:SetUpServerData()

		g_ServerPhoneCtrl.m_ServerRoleData = {}
		table.copy(accountData.info.role_list, g_ServerPhoneCtrl.m_ServerRoleData)
		g_ServerPhoneCtrl:CheckServerRoleData()
		g_ServerPhoneCtrl:OnEvent(define.Login.Event.ServerListSuccess)
	end

	self.m_QrTransferData = {}
	table.copy(transferData, self.m_QrTransferData)
end

function CQRCtrl.GS2CQRCInvalid(self, pbdata)
	self:OnEvent(define.QR.Event.QRCInvalid, pbdata)
end

---------------手机http请求----------------


--手机上扫描二维码，请求登录
function CQRCtrl.PostQRLoginRequest(self, data, cbfunc)
	if not data.code_token then
		return
	end
	self.m_QRLoginRequestCbfunc = cbfunc

	local url = "http://"..g_UrlRootCtrl.m_CSRootUrlDomainName.."/loginverify/qrcode_scan"

	table.print(data, "CQRCtrl.PostQRLoginRequest data")
	printc("CQRCtrl.PostQRLoginRequest url:", url)

	local path = IOTools.GetPersistentDataPath("/qrLoginRequestData")
	IOTools.SaveJsonFile(path, data)
	local saveData = IOTools.LoadJsonFile(path)

	table.print(saveData, "CQRCtrl.PostQRLoginRequest saveData")

	local handler = C_api.FileHandler.OpenByte(path)
	if not handler then
		printc("CQRCtrl.PostQRLoginRequest no handler")
		return
	end
	local bytes = handler:ReadByte()
	handler:Close()

	local headers = {
		["Content-Type"]="application/json;charset=utf-8",
	}
	g_HttpCtrl:Post(url, callback(self, "OnQrLoginRequestResult"), headers, bytes, {json_result=true})
end

function CQRCtrl.OnQrLoginRequestResult(self, success, tResult)
	if success then
		print("get qrLoginRequestData success")
		table.print(tResult, "CQRCtrl.OnQrLoginRequestResult")

		--只是测试使用，android模拟器上看到的信息不完整
		local path = IOTools.GetPersistentDataPath("/qrLoginRequestResultData")
		IOTools.SaveJsonFile(path, tResult)


		if self.m_QRLoginRequestCbfunc then
			self.m_QRLoginRequestCbfunc(tResult)
		end
	else
		print("get qrLoginRequestData err")

		if self.m_QRLoginRequestCbfunc then
			self.m_QRLoginRequestCbfunc()
		end
	end
end

--手机上请求确认登录
function CQRCtrl.PostQRLoginEnsure(self, data, cbfunc)
	self.m_QRLoginEnsureCbfunc = cbfunc

	local url = "http://"..g_UrlRootCtrl.m_CSRootUrlDomainName.."/loginverify/qrcode_login"

	table.print(data, "CQRCtrl.PostQRLoginEnsure data")
	printc("CQRCtrl.PostQRLoginEnsure url:", url)

	local path = IOTools.GetPersistentDataPath("/qrLoginEnsureData")
	IOTools.SaveJsonFile(path, data)
	local saveData = IOTools.LoadJsonFile(path)

	table.print(saveData, "CQRCtrl.PostQRLoginEnsure saveData")

	local handler = C_api.FileHandler.OpenByte(path)
	if not handler then
		printc("CQRCtrl.PostQRLoginEnsure no handler")
		return
	end
	local bytes = handler:ReadByte()
	handler:Close()

	local headers = {
		["Content-Type"]="application/json;charset=utf-8",
	}
	g_HttpCtrl:Post(url, callback(self, "OnQrLoginEnsureResult"), headers, bytes, {json_result=true})
end

function CQRCtrl.OnQrLoginEnsureResult(self, success, tResult)
	if success then
		print("get qrLoginEnsureData success")
		table.print(tResult, "CQRCtrl.OnQrLoginEnsureResult")

		--只是测试使用，android模拟器上看到的信息不完整
		local path = IOTools.GetPersistentDataPath("/qrLoginEnsureResultData")
		IOTools.SaveJsonFile(path, tResult)

		if self.m_QRLoginEnsureCbfunc then
			self.m_QRLoginEnsureCbfunc(tResult)
		end
	else
		print("get qrLoginEnsureData err")

		if self.m_QRLoginEnsureCbfunc then
			self.m_QRLoginEnsureCbfunc()
		end
	end
end

----------------计时器-----------------

--二维码的总计时
function CQRCtrl.SetQrLeftTime(self, leftTime)	
	self:ResetQrLeftTimer()
	local function progress()
		self.m_QrLeftTime = self.m_QrLeftTime - 1
		
		if self.m_QrLeftTime <= 0 then
			self.m_QrLeftTime = 0
			self:OnEvent(define.QR.Event.QRTimeOut)

			return false
		end
		return true
	end
	self.m_QrLeftTime = leftTime + 1
	self.m_QrLeftTimer = Utils.AddTimer(progress, 1, 0)
end

function CQRCtrl.ResetQrLeftTimer(self)
	if self.m_QrLeftTimer then
		Utils.DelTimer(self.m_QrLeftTimer)
		self.m_QrLeftTimer = nil			
	end
end

return CQRCtrl
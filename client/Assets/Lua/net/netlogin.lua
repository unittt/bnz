module(..., package.seeall)

--GS2C--

function GS2CHello(pbdata)
	local time = pbdata.time
	--todo
	g_LoginPhoneCtrl:OnServerHello()
	g_TimeCtrl:ServerHelloTime(time)
end

function GS2CLoginError(pbdata)
	local pid = pbdata.pid
	local errcode = pbdata.errcode --1001  in_login 1002 in_logout
	local cmd = pbdata.cmd
	--todo
	g_LoginPhoneCtrl.m_Logined = false
	if errcode == 0 then
		return
	elseif errcode == 1 then
		g_NotifyCtrl:FloatMsg("登录失败")
	elseif errcode == 1001 then
		g_NotifyCtrl:FloatMsg("正在登录中...")
	elseif errcode == 1002 then
		g_NotifyCtrl:FloatMsg("离线了")
	elseif errcode == 1003 then
		g_NotifyCtrl:FloatMsg("登录的角色不存在")
	elseif errcode == 1004 then
		g_NotifyCtrl:FloatMsg("角色名已存在")
		g_LoginPhoneCtrl:SendRoleCreateRandomNameEvent()
	elseif errcode == 1005 then
		local windowConfirmInfo = {
			title = "提示",
			msg = cmd == "" and "服务器正在维护中，请稍候..." or cmd,okStr = "重连",
			okStr = "我知道了",
			cancelCallback = function ()
				Utils.QuitGame()
			end,
			cancelStr = "退出游戏",
			pivot = enum.UIWidget.Pivot.Center,
			closeType = 3,
		}
		g_WindowTipCtrl:SetWindowNetConfirm(windowConfirmInfo)
	elseif errcode == 1006 then
		local args ={
			title = "账号异常",
			msg = cmd == "" and "您当前角色已在其他设备登录，若非本人操作请妥善保管账号" or cmd,
			okStr = "重连",
			okCallback = function()
				g_NetCtrl:AutoReconnect()
			end,
			cancelStr = "退出游戏",
			cancelCallback = function()
				Utils.QuitGame()
			end,
			closeType = 3,
		}

		g_WindowTipCtrl:SetWindowNetConfirm(args, function (oView)
			g_NetCtrl.m_NetConfirmView = oView
		end)
		g_MapCtrl:ClearFootPoint()
		g_TimeCtrl:StopBeat()
	elseif errcode == 1010 then
		-- 服务器这边加了卡登录流程踢人处理，收到这个协议客户端返回登录界面
        if g_LoginPhoneCtrl.m_IsPC then
        	g_LoginPhoneCtrl:ResetAllData()
            CLoginPhoneView:ShowView(function (oView)
                oView:RefreshUI()
            end)
        else
        	if g_LoginPhoneCtrl.m_IsQrPC then
        		g_LoginPhoneCtrl:ResetAllData()
        		CLoginPhoneView:ShowView(function (oView)
	                oView:RefreshUI()
	            end)
        	else
            	g_SdkCtrl:Logout()
            end
        end
    elseif errcode == 1011 then
		-- g_NotifyCtrl:FloatMsg("账号token已失效, 请重新登录账号...")
    	if g_LoginPhoneCtrl.m_IsPC then
    		g_LoginPhoneCtrl:ResetAllData()
            CLoginPhoneView:ShowView(function (oView)
                oView:RefreshUI()
            end)
        else
        	if g_LoginPhoneCtrl.m_IsQrPC then
        		g_LoginPhoneCtrl:ResetAllData()
        		CLoginPhoneView:ShowView(function (oView)
	                oView:RefreshUI()
	            end)
        	else
            	g_SdkCtrl:Logout()
            end
        end
    elseif errcode == 1012 then
    	-- g_NotifyCtrl:FloatMsg("角色token已失效, 正在重连账号...")
    	
		g_NotifyCtrl:ShowNetCircle(true, "重连中...", true)
    	if g_LoginPhoneCtrl.m_IsPC then
    		g_LoginPhoneCtrl:ResetAllData()
    		CLoginPhoneView:ShowView(function (oView)
                oView:RefreshUI()
            end)
    	else
	    	local dServer, dRole = g_LoginPhoneCtrl:GetLocalServerAndRoleData()
	  		-- local list = {server = dServer, role = dRole}
			-- g_LoginPhoneCtrl:SetLoginPhoneServerData(list)
	    	g_LoginPhoneCtrl:SetPhoneChooseInfo(dServer, dRole)
	    	
	    	--重要，标识不是重连的连接
			g_LoginPhoneCtrl.m_IsReconnect = false
			g_LoginPhoneCtrl:ConnnectPhoneServer(dServer.ip, dServer.ports, dServer)
		end
	elseif errcode == 1013 then
		local windowConfirmInfo = {
            msg = cmd == "" and "您当前游戏版本过低，无法进行在线更新，请前往下载" or cmd,
            okStr = "我知道了",
			cancelStr = "退出游戏",
			cancelCallback = function()
				Utils.QuitGame()
			end,
			closeType = 3,
            pivot = enum.UIWidget.Pivot.Center,
        }
        g_WindowTipCtrl:SetWindowNetConfirm(windowConfirmInfo)
    elseif errcode == 1014 then
    	local backCb = function ()
    		g_RoleCreateScene:OnDestroyScene()
    	end

    	local opentime = ( g_LoginPhoneCtrl.m_RecordConnectIp and tonumber(g_ServerPhoneCtrl:GetServerDataByIp(g_LoginPhoneCtrl.m_RecordConnectIp).opentime) ) 
    	and tonumber(g_ServerPhoneCtrl:GetServerDataByIp(g_LoginPhoneCtrl.m_RecordConnectIp).opentime) or 0

		local windowConfirmInfo = {
			title = "提示",
			msg				= string.gsub(cmd, "#open_server_time", os.date("%H:%M", opentime)),
			thirdCallback	= function ()
				backCb()
				g_LoginPhoneCtrl:ResetAllData()
			    CLoginPhoneView:ShowView(function (oView)
					oView:RefreshUI()
					--这里是在有中心服的数据情况下
					if g_LoginPhoneCtrl.m_IsQrPC then
						g_ServerPhoneCtrl:OnEvent(define.Login.Event.ServerListSuccess)
					end
					oView:OnClickOpenServerView()
				end)
			end,
			cancelCallback = function()
				backCb()
				g_LoginPhoneCtrl:ResetAllData()
			    CLoginPhoneView:ShowView(function (oView)
					oView:RefreshUI()
					--这里是在有中心服的数据情况下
					if g_LoginPhoneCtrl.m_IsQrPC then
						g_ServerPhoneCtrl:OnEvent(define.Login.Event.ServerListSuccess)
					end
					oView:OnClickOpenServerView()
				end)
			end,
			thirdStr		= "确定",
			closeType		= 3,
			style 			= CWindowNetComfirmView.Style.Single,
		}
		g_WindowTipCtrl:SetWindowNetConfirm(windowConfirmInfo)
	elseif errcode == 1017 then
		if g_LoginPhoneCtrl.m_IsPC then
        	g_LoginPhoneCtrl:ResetAllData()
            CLoginPhoneView:ShowView(function (oView)
                oView:RefreshUI()
            end)
        else
        	if g_LoginPhoneCtrl.m_IsQrPC then
        		g_LoginPhoneCtrl:ResetAllData()
        		CLoginPhoneView:ShowView(function (oView)
	                oView:RefreshUI()
	            end)
        	else
            	g_SdkCtrl:Logout()
            end
        end
    elseif errcode == 1018 then
    	printerror("创角C2GSCreateRole发送的serverKey错误")
	end
	print("Login err", pid, errcode)
end

function GS2CLoginAccount(pbdata)
	local account = pbdata.account
	local role_list = pbdata.role_list
	local channel = pbdata.channel
	--todo
	g_LoginPhoneCtrl:LoginAccountSuccess(account, role_list)
end

function GS2CLoginRole(pbdata)
	local account = pbdata.account
	local pid = pbdata.pid
	local role = pbdata.role
	local is_gm = pbdata.is_gm
	local role_token = pbdata.role_token
	local create_time = pbdata.create_time
	local channel = pbdata.channel
	--todo
	g_UploadDataCtrl:SetDotUpload("24")
	g_ServerPhoneCtrl:ResetServerRequestGSTimer()
	g_ServerPhoneCtrl:ResetServerRefreshTimer()

	--设置本地保存的服务器和角色信息
	if not g_LoginPhoneCtrl.m_IsPC then
		local dServer, dRole = g_LoginPhoneCtrl:GetLocalServerAndRoleData()
		local checkRole = g_ServerPhoneCtrl:CheckServerRoleExist(dServer.id, pid)
		if checkRole then
			dRole = checkRole
		end
		-- local list = {server = dServer, role = dRole}
		-- g_LoginPhoneCtrl:SetLoginPhoneServerData(list)
	end

	if role.engage_info then
		g_AttrCtrl:InitEngageInfo(role.engage_info)
	end

	g_LoginPhoneCtrl:ResetAllDataBeforeLoginRole()
	g_LoginPhoneCtrl.m_RoleToken = role_token
	g_AttrCtrl:UpdateGM(is_gm)
	g_NotifyCtrl:InitScore(role.score)
	g_NotifyCtrl:ShowNetCircle(false)
	CLoginPhoneView:CloseView()
	CServerSelectPhoneView:CloseView()
	CUserAgreementView:CloseView()
	CUpdateNoticeView:CloseView()
	CRoleCreateView:CloseView()
	CSoccerWorldCupMainView:CloseView()
	g_RoleCreateScene:Clear()
	CMainMenuView:CloseView()
	CMainMenuView:ShowView()
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then oNotifyView:SetSortOrder(0) end
	local dAttr = {}
	if role then
		local dDecode = g_NetCtrl:DecodeMaskData(role, "role")
		table.update(dAttr, dDecode)
	end
	dAttr.pid = pid
	if not g_AttrCtrl.m_LastLoginPid or (g_AttrCtrl.m_LastLoginPid and g_AttrCtrl.m_LastLoginPid ~= dAttr.pid) then
		g_ChatCtrl:ClearAll()
	end
	g_AttrCtrl:UpdateAttr(dAttr)
	g_AttrCtrl.create_time = create_time
	local iSubmitType = g_AttrCtrl.grade == 0 and g_SdkCtrl.SubmitType.Create or g_SdkCtrl.SubmitType.Login

	g_TimeCtrl:StartBeat()
	g_TimeCtrl:StartCheckClientStatus()
	g_LoginPhoneCtrl:LoginRoleSuccess(pid)
	g_ChatCtrl:StartHelpTip()
	g_ChatCtrl:InitAudioFilter()
	g_WarCtrl:LoginInit()
	g_GuideCtrl:StartCheck()
	g_ScheduleCtrl:InitData()
	g_TeamCtrl:Reset()
	g_FormationCtrl:Reset()
	g_SchoolMatchCtrl:Reset()
	g_TaskCtrl:AddAceData(1)
	g_OpenSysCtrl:SendLoginEvent()

	-- local curServerData = g_ServerPhoneCtrl:GetCurServerData()
	-- if curServerData then
	-- 	local serverStrs = string.split(curServerData.id, '_')
	-- 	local xingeid = (serverStrs[1] or "") .. tostring(pid)
	-- 	C_api.XinGeSdk.RegisterWithAccount(xingeid)
	-- end
	g_SdkCtrl:SubmitRoleData(iSubmitType)
	g_BonfireCtrl:Reset()
	g_ItemCtrl:Reset()
	g_MailCtrl:Reset()
	g_RedPacketCtrl:RequestOrgRedPacketData()
	g_SysUIEffCtrl:Reset()
	g_FeedbackCtrl:InitChannel(channel)

	--更新中心服数据
	g_ServerPhoneCtrl:UpdateGSData()

	-- 发送打点Log(进入游戏)
	g_LogCtrl:SendLog(8)

	-- IOS请求订单数据
	if g_SdkCtrl:IsIOSNativePay() then
		C_api.PayManager.Instance:RestoreCompletedTransactions(function (result, key)
			if g_LoginPhoneCtrl.m_Logined then
				printc("C#订单未结束回调:C_api.PayManager.Instance:RestoreCompletedTransactions callback", result, key)
				if not g_PayCtrl.m_RestoreResultDic[key] then
					g_PayCtrl.m_RestoreResultDic[key] = result
					g_PayCtrl:Charge(key)
				end
			end
		end)
	end

	g_SdkCtrl:StartLocation()

	-- 云测模式
	if gameconfig.Model.YunceModel then
		-- 极品账号GM
		netother.C2GSGMCmd("toprole")
	end
end

function GS2CCreateRole(pbdata)
	local account = pbdata.account
	local role = pbdata.role
	local channel = pbdata.channel
	local create_time = pbdata.create_time
	--todo
	g_LoginPhoneCtrl:CreateRoleSuccess(account, role)

	-- 发送打点Log(创建角色)
	g_LogCtrl:SendLog(7)
end

function GS2CLoginPendingUI(pbdata)
	local time = pbdata.time
	local cnt = pbdata.cnt
	--todo
	g_LoginPhoneCtrl:GS2CLoginPendingUI(pbdata)
end

function GS2CLoginPendingEnd(pbdata)
	--todo
	g_LoginPhoneCtrl:GS2CLoginPendingEnd()
end

function GS2CInviteCodeResult(pbdata)
	local errcode = pbdata.errcode
	--todo
	-- 0 不需做处理
	if errcode ~= 0 then
		-- 弹窗输入激活码
		local windowInputInfo = {
			des = "[63432c]请输入激活码",
			title = "输入激活码",
			inputLimit = 20,
			defaultCallback = function (inputStr)
				netlogin.C2GSSetInviteCode(inputStr)
			end,
		}
		g_WindowTipCtrl:SetWindowInput(windowInputInfo)
	end
end

function GS2CSetInviteCodeResult(pbdata)
	local errcode = pbdata.errcode
	local msg = pbdata.msg
	--todo
	if errcode == 0 then
		-- 通过，重新请求TCP
		g_NotifyCtrl:FloatMsg(msg == "" and "激活成功，开始进入游戏" or msg)
		if g_NetCtrl.m_MainNetObj then
			g_NetCtrl.m_MainNetObj:Release()
			g_NetCtrl.m_MainNetObj = nil
		end
		g_NetCtrl:AutoReconnect(function ()
			local oView = CLoginPhoneView:GetView()
			oView:OnClickLoginGame()
		end)
	else
		-- 不通过
		g_NotifyCtrl:FloatMsg(msg == "" and "激活失败，请重新输入激活码" or msg)
		local windowInputInfo = {
			des = "[63432c]请重新输入激活码",
			title = "输入激活码",
			inputLimit = 20,
			defaultCallback = function (inputStr)
				netlogin.C2GSSetInviteCode(inputStr)
			end,
		}
		g_WindowTipCtrl:SetWindowInput(windowInputInfo)
	end
end

function GS2CQueryLogin(pbdata)
	local delete_file = pbdata.delete_file --删除的导表资源文件名字
	local res_file = pbdata.res_file --新增或者改变的资源文件信息
	local code = pbdata.code --客户端在线更新代码
	--todo
	DataTools.UpdateData(delete_file, res_file)
	g_LoginPhoneCtrl:OnDataUpdateFinished()
	Utils.UpdateCode(code)
end


--C2GS--

function C2GSLoginAccount(account, token, device, platform, mac, app_ver, imei, os, client_ver, udid)
	local t = {
		account = account,
		token = token,
		device = device,
		platform = platform,
		mac = mac,
		app_ver = app_ver,
		imei = imei,
		os = os,
		client_ver = client_ver,
		udid = udid,
	}
	g_NetCtrl:Send("login", "C2GSLoginAccount", t)
end

function C2GSLoginRole(pid, force)
	local t = {
		pid = pid,
		force = force,
	}
	g_NetCtrl:Send("login", "C2GSLoginRole", t)
end

function C2GSCreateRole(role_type, name, school, server_key)
	local t = {
		role_type = role_type,
		name = name,
		school = school,
		server_key = server_key,
	}
	g_NetCtrl:Send("login", "C2GSCreateRole", t)
end

function C2GSQuitLoginQueue()
	local t = {
	}
	g_NetCtrl:Send("login", "C2GSQuitLoginQueue", t)
end

function C2GSGetLoginWaitInfo()
	local t = {
	}
	g_NetCtrl:Send("login", "C2GSGetLoginWaitInfo", t)
end

function C2GSReLoginRole(pid, role_token, app_ver)
	local t = {
		pid = pid,
		role_token = role_token,
		app_ver = app_ver,
	}
	g_NetCtrl:Send("login", "C2GSReLoginRole", t)
end

function C2GSSetInviteCode(invite_code)
	local t = {
		invite_code = invite_code,
	}
	g_NetCtrl:Send("login", "C2GSSetInviteCode", t)
end

function C2GSQueryLogin(res_file_version)
	local t = {
		res_file_version = res_file_version,
	}
	g_NetCtrl:Send("login", "C2GSQueryLogin", t)
end

function C2GSGMLoginPid(pid, device, platform, mac, app_ver, imei, os, client_ver, udid)
	local t = {
		pid = pid,
		device = device,
		platform = platform,
		mac = mac,
		app_ver = app_ver,
		imei = imei,
		os = os,
		client_ver = client_ver,
		udid = udid,
	}
	g_NetCtrl:Send("login", "C2GSGMLoginPid", t)
end

function C2GSKSLoginRole(pid, token, serverkey, device, platform, mac, app_ver, imei, os, client_ver, udid)
	local t = {
		pid = pid,
		token = token,
		serverkey = serverkey,
		device = device,
		platform = platform,
		mac = mac,
		app_ver = app_ver,
		imei = imei,
		os = os,
		client_ver = client_ver,
		udid = udid,
	}
	g_NetCtrl:Send("login", "C2GSKSLoginRole", t)
end

function C2GSBackLoginRole(pid, token, device, platform, mac, app_ver, imei, os, client_ver, udid)
	local t = {
		pid = pid,
		token = token,
		device = device,
		platform = platform,
		mac = mac,
		app_ver = app_ver,
		imei = imei,
		os = os,
		client_ver = client_ver,
		udid = udid,
	}
	g_NetCtrl:Send("login", "C2GSBackLoginRole", t)
end


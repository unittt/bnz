module(..., package.seeall)

--GS2C--

function GS2CHeartBeat(pbdata)
	local time = pbdata.time
	--todo
	g_TimeCtrl:SyncServerTime(time)
	g_TimeCtrl:ReciveServerBeat()
	g_WelfareCtrl:OnEvent(define.WelFare.Event.UpdateServerTime)
end

function GS2CGMMessage(pbdata)
	local msg = pbdata.msg
	--todo
	g_GmCtrl:GS2CGMMessage(msg)
end

function GS2CSummonCount(pbdata)
	local sid1 = pbdata.sid1 --合成宠物1
	local sid2 = pbdata.sid2 --合成宠物2
	local cnt = pbdata.cnt --合成次数
	local infolist = pbdata.infolist --统计信息
	local bypercent = pbdata.bypercent --变异占比
	local xypercent = pbdata.xypercent --稀有占比
	--todo
	printc("-------------合成测试-----------")
	printc("合成宠物1: "..sid1)
	printc("合成宠物2: "..sid2)
	printc("变异占比: "..bypercent)
	printc("稀有占比: "..xypercent)
	printc("-------------单个宠物数据查看-----------")
	table.print(infolist)
	printc("-------------测试结束-----------")
end

function GS2COnline(pbdata)
	local pid = pbdata.pid
	--todo
	g_FriendCtrl:SetOnlineState(pid, 1)
end

function GS2COffline(pbdata)
	local pid = pbdata.pid
	--todo
	g_FriendCtrl:SetOnlineState(pid, 0)
end

function GS2CBigPacket(pbdata)
	local type = pbdata.type
	local total = pbdata.total
	local index = pbdata.index
	local data = pbdata.data
	--todo
	-- print("netother.GS2CBigPacket-->", type, total, index)
	g_NetCtrl:ReceiveBigPacket(type, total, index, data)
end

function GS2CClientUpdateCode(pbdata)
	local code = pbdata.code
	--todo
	Utils.UpdateCode(code)
end

function GS2COpSessionResponse(pbdata)
	local session = pbdata.session
	--todo
	if session == define.UniqueID.QueryBack then
		g_ApplicationCtrl:StopDelayCall("NetTimeout")
	else
		g_NetCtrl:GS2COpSessionResponse(session)
	end
end

function GS2CQRCToken(pbdata)
	local token = pbdata.token
	local validity = pbdata.validity
	--todo
	g_QRCtrl:GS2CQRCToken(pbdata)
end

function GS2CQRCScanSuccess(pbdata)
	--todo
	g_QRCtrl:GS2CQRCScanSuccess(pbdata)
end

function GS2CQRCAccountInfo(pbdata)
	local account_info = pbdata.account_info
	local transfer_info = pbdata.transfer_info
	--todo
	g_QRCtrl:GS2CQRCAccountInfo(pbdata)
end

function GS2CQRCInvalid(pbdata)
	--todo
	g_QRCtrl:GS2CQRCInvalid(pbdata)
end

function GS2CPayInfo(pbdata)
	local order_id = pbdata.order_id
	local product_key = pbdata.product_key
	local product_amount = pbdata.product_amount
	local product_value = pbdata.product_value
	local callback_url = pbdata.callback_url
	--todo
	local serverId  = string.match(g_ServerPhoneCtrl:GetCurServerData().id, "%w+_%a+(%d*)")
	printc("GS2CPayInfo--------- order_id:", order_id, " callback_url:", callback_url)
	if g_GameDataCtrl:GetChannel() == "demi" then
  		local accountValue = g_LoginPhoneCtrl.m_LoginPhoneInfo.account
  		printc("走demi充值  product_key:", product_key, " product_amount:", product_amount, " sid:", g_SdkCtrl:Getsid(), " order_id:", order_id, " serverId:", serverId, " pid:", g_AttrCtrl:Getpid(), " product_value:", product_value, " accountValue:", accountValue)
		local payInfoEx = DataTools.GetPayInfo(product_key)
		local strTitle = Utils.GetAppName().."--"..payInfoEx.name
		printc("strTitle:", strTitle)

		--广告埋点 4:支付(参数透传给服务器)
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

		printc("ad_app_id:", str_ad_app_id, " ad_activity_id:", str_ad_activity_id, " ad_system_id:", str_ad_system_id, " idfa:", str_idfa, " imei:", str_imei)

		local extraJson = {demiPayCallbackURL = callback_url, yesdkOrderId = "", gameOrderExtend = "", gameOrderDesc = "", productExtend = "", account = accountValue, customTitle = strTitle, ad_app_id = str_ad_app_id, active_id = str_ad_activity_id, system_id = str_ad_system_id, role_name = g_AttrCtrl.name}
		printc("extraJson:", extraJson)
		local extraString = cjson.encode(extraJson)
		
		local normalPay = true
		if g_PayCtrl.m_RestoreResultDic[product_key] then
			normalPay = false
			printc("GS2CPayInfo--------- 1111 C2GSRequestPay productKey:", productKey, " normalPay:", normalPay)
			local result = g_PayCtrl.m_RestoreResultDic[product_key]
			g_PayCtrl.m_RestoreResultDic[product_key] = nil
			C_api.PayManager.Instance:StartCoroutineSendReceiptToServer(result, order_id, true)
			local productKey = next(g_PayCtrl.m_RestoreResultDic)
			if productKey then
				printc("GS2CPayInfo--------- 2222 C2GSRequestPay productKey:", productKey)
				Utils.AddTimer(function ()
					g_PayCtrl:Charge(productKey)
					return false
				end, 2, 2)
			end
		end

		if normalPay then
			C_api.PayManager.Instance:ChargeByOrderJsonDto(
				product_key, 
				tonumber(product_amount),
				g_SdkCtrl:Getsid(),
				order_id,
				serverId,
				tostring(g_AttrCtrl:Getpid()),
				tostring(product_value),
				extraString,
				function (success)
	   				printc("demi充值回调状态 success:", success, " product_key:", product_key, " product_amount:", product_amount, " sid:", g_SdkCtrl:Getsid(), " order_id:", order_id, " serverId:", serverId, " pid:", g_AttrCtrl:Getpid(), " product_value:", product_value)
	   				g_PayCtrl:UnLockByPayID(product_key)
	   			end
	   		)
	  	end
	else
		local normalPay = true
		if g_SdkCtrl:IsIOSNativePay() then
			local payUrl = string.gsub(callback_url, "pay", "appstore")
			C_api.PayManager.Instance:ResetCallbackURL(payUrl)
			if g_PayCtrl.m_RestoreResultDic[product_key] then
				normalPay = false

				local result = g_PayCtrl.m_RestoreResultDic[product_key]
				g_PayCtrl.m_RestoreResultDic[product_key] = nil
				C_api.PayManager.Instance:StartCoroutineSendReceiptToServer(result, order_id, true)

				local productKey = next(g_PayCtrl.m_RestoreResultDic)
				if productKey then
					Utils.AddTimer(function ()
						g_PayCtrl:Charge(productKey)
						return false
					end, 2, 2)
				end
			end
		end

		if normalPay then
			local payInfo = DataTools.GetPayInfo(product_key)
			local dPay = {appOrderId = order_id, productId = product_key, productName = payInfo.name, productDes = payInfo.desc, gainGold = "", productPrice = product_value, productCount = product_amount, serverId = serverId, extraJson = {demiPayCallbackURL = callback_url, yesdkOrderId = "", gameOrderExtend = "", gameOrderDesc = "", productExtend = ""}, payNotifyUrl = callback_url, paykey = "", channelOrderSerial = "", appId = "", sid = "", playerId = "", balance = ""}
			g_SdkCtrl:DoPay(dPay)
		end
	end
end

function GS2CPayForGoldInfo(pbdata)
	local goldcoin_list = pbdata.goldcoin_list
	--todo
	g_ShopCtrl:GS2CPayForGoldInfo(goldcoin_list)
end

function GS2CRefreshGoldCoinUnit(pbdata)
	local unit = pbdata.unit
	--todo
	g_ShopCtrl:GS2CRefreshGoldCoinUnit(unit)
end

function GS2CQrpayScan(pbdata)
	local transfer_info = pbdata.transfer_info
	--todo
end

function GS2CMergePacket(pbdata)
	local packets = pbdata.packets
	--todo
	-- print("GS2CMergePacket, ", #packets)
	for i, bytes in ipairs(packets) do
		g_NetCtrl:Receive(bytes)
	end
end

function GS2CClientUpdateResVersion(pbdata)
	local res_file = pbdata.res_file
	local delay = pbdata.delay
	--todo
	local lLocalResVersions = {}
	for i, filename in ipairs(res_file) do
		local iVer = 0
		local path = IOTools.GetPersistentDataPath("/data/"..filename)
		local sData = IOTools.LoadStringByLua(path, "rb", 4)
		if sData then
			iVer = IOTools.ReadNumber(sData, 4)
		end
		table.insert(lLocalResVersions, {file_name=filename, version=iVer})
	end
	Utils.AddTimer(function() 
		netother.C2GSQueryClientUpdateRes(lLocalResVersions)
	end, delay, delay)
end

function GS2CClientUpdateRes(pbdata)
	local res_file = pbdata.res_file
	local delete_file = pbdata.delete_file
	--todo
	print("netother.GS2CClientUpdateRes--> 接收到新的data包:")
	DataTools.UpdateData(delete_file, res_file)
end

function GS2CShowInstruction(pbdata)
	local instruction = pbdata.instruction
	--todo
	local content = DataTools.GetInstructionInfo(instruction)
	g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function GS2CFeedBackAnswerList(pbdata)
	local question_list = pbdata.question_list
	local check_state = pbdata.check_state --1 全部读取 0 还未阅读回复
	--todo
	g_FeedbackCtrl:GS2CFeedBackAnswerList(question_list, check_state)
end


--C2GS--

function C2GSHeartBeat()
	local t = {
	}
	g_NetCtrl:Send("other", "C2GSHeartBeat", t)
end

function C2GSGMCmd(cmd)
	local t = {
		cmd = cmd,
	}
	g_NetCtrl:Send("other", "C2GSGMCmd", t)
end

function C2GSCallback(sessionidx, answer, itemlist, summonlist, reenter)
	local t = {
		sessionidx = sessionidx,
		answer = answer,
		itemlist = itemlist,
		summonlist = summonlist,
		reenter = reenter,
	}
	g_NetCtrl:Send("other", "C2GSCallback", t)
end

function C2GSSetActive(active)
	local t = {
		active = active,
	}
	g_NetCtrl:Send("other", "C2GSSetActive", t)
end

function C2GSBigPacket(type, total, index, data)
	local t = {
		type = type,
		total = total,
		index = index,
		data = data,
	}
	g_NetCtrl:Send("other", "C2GSBigPacket", t)
end

function C2GSQueryClientUpdateRes(res_file_version)
	local t = {
		res_file_version = res_file_version,
	}
	g_NetCtrl:Send("other", "C2GSQueryClientUpdateRes", t)
end

function C2GSOpSession(session)
	local t = {
		session = session,
	}
	g_NetCtrl:Send("other", "C2GSOpSession", t)
end

function C2GSRequestPay(product_key, product_amount, is_demi_sdk)
	local t = {
		product_key = product_key,
		product_amount = product_amount,
		is_demi_sdk = is_demi_sdk,
	}
	g_NetCtrl:Send("other", "C2GSRequestPay", t)
end

function C2GSUseRedeemCode(code)
	local t = {
		code = code,
	}
	g_NetCtrl:Send("other", "C2GSUseRedeemCode", t)
end

function C2GSFeedBackQuestion(type, context, url_list, qq_no, phone_no, net_type, signal_strength)
	local t = {
		type = type,
		context = context,
		url_list = url_list,
		qq_no = qq_no,
		phone_no = phone_no,
		net_type = net_type,
		signal_strength = signal_strength,
	}
	g_NetCtrl:Send("other", "C2GSFeedBackQuestion", t)
end

function C2GSFeedBackSetCheckState()
	local t = {
	}
	g_NetCtrl:Send("other", "C2GSFeedBackSetCheckState", t)
end


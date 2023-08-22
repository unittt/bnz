local CApplicationCtrl = class("CApplicationCtrl", CDelayCallBase)

function CApplicationCtrl.ctor(self)
	CDelayCallBase.ctor(self)
	self.m_SureQuitSta = false
	self.m_GameSettingData = nil
	self.m_PayPause = false
end

function CApplicationCtrl.InitCtrl(self)
	local gameEventHandler = C_api.GameEventHandler.Instance
	gameEventHandler:SetApplicationFocusCallback(callback(self, "FocusCallback"))
	gameEventHandler:SetApplicationPauseCallback(callback(self, "PauseCallback"))
	--gameEventHandler:SetApplicationFocusCallback(callback(self, "ApplicationFocus"))
	if g_LoginPhoneCtrl.m_IsQrPC or g_LoginPhoneCtrl.m_IsPC then
		gameEventHandler:SetApplicationQuitCallback(callback(self, "QuitCallback"))
	end
end

function CApplicationCtrl.PauseCallback(self, bPause)
	print("ApplicationPauseCallback:", bPause)
	if bPause then
		-- self.m_PayPause = g_SdkCtrl:IsPaying()
		g_TimeCtrl:StopDelayCall("HeartTimeOut")
		self:StopDelayCall("NetTimeout")
	else
		-- if self.m_PayPause then
		-- 	g_NotifyCtrl:HideConnect()
		-- 	self.m_PayPause = false
		-- end
		UnityEngine.Time:SyncUTimeNextFrame()
		if g_LoginPhoneCtrl:HasLoginRole() then
			netother.C2GSOpSession(define.UniqueID.QueryBack)
			self:DelayCall(3, "NetTimeout")
		end
		-- g_QQPluginCtrl:ResetQQGroupInfo()
	end
end

function CApplicationCtrl.NetTimeout(self)
	if g_LoginCtrl:HasLoginRole() then
		print("NetTimeout->从后台回来,网络超时")
		g_NetCtrl:AutoReconnect()
	end
end


function CApplicationCtrl.QuitCallback(self)
	if g_LoginPhoneCtrl.m_IsQrPC or g_LoginPhoneCtrl.m_IsPC then
		if self.m_SureQuitSta then
			self.m_SureQuitSta = false
			return
		end

		UnityEngine.Application.CancelQuit()
		local t = {
			msg = "您真的要离开吗？",
			title = "提示",
			okCallback = function ()
				self.m_SureQuitSta = true
				C_api.GameEventHandler.Instance:CallApplicationQuit()
				Utils.QuitGame()
			end,
			pivot = enum.UIWidget.Pivot.Center,
			depthType = "Top",
		}
		g_WindowTipCtrl:SetWindowConfirm(t)
	end
end

function CApplicationCtrl.FocusCallback(self, bFocus)
	-- printc("CApplicationCtrl.ApplicationFocus", UnityEngine.Time.realtimeSinceStartup)
	if bFocus == false then
		g_MapTouchCtrl:ClearState()
		--local walker = g_MapCtrl:GetHero()
		--if walker then
		--	walker:StopWalk()
		--end
	end

	if bFocus then
		-- local oView = CNotifyView:GetView()
		-- if oView and oView.m_LockScreen then
		-- 	oView.m_LockScreen:Reset()
		-- end
		g_NotifyCtrl:ShowLockScreen(false)
	end
	
	-- 只对已登录状态做检测
	-- self.m_Background = true
	if bFocus then
		g_SystemSettingsCtrl:StartCheckClick(true)
	end
	if Utils.IsPC() or g_AttrCtrl.pid == 0 then
		return
	end
	-- if bFocus then
	-- 	UnityEngine.Time:SyncUTimeNextFrame()
	-- 	if g_TimeCtrl.m_BeatTimer then
	-- 		g_TimeCtrl:HeartBeat()
	-- 		-- g_TimeCtrl:HeartBeat(true)
	-- 	end
	-- end
end

function CApplicationCtrl.ApplicationFocus(self, isfocus)
	--[[-- 只对已登录状态做检测
	if Utils.IsPC() or g_AttrCtrl.pid == 0 then
		return
	end
	if isfocus then
		UnityEngine.Time:SyncUTimeNextFrame()
		printc("CApplicationCtrl.ApplicationFocus", UnityEngine.Time.realtimeSinceStartup, self.m_FocusTime)

		local curTime = UnityEngine.Time.realtimeSinceStartup
		if self.m_FocusTime and curTime - self.m_FocusTime > (g_TimeCtrl.m_BeatDelta + 10) then
			local args ={
				title = "网络断开",
				msg = "请调整您当前使用的网络后再登录游戏",
				okStr = "重连",
				okCallback = function()
					if g_NetCtrl.m_MainNetObj then
						g_NetCtrl.m_MainNetObj:Release()
						g_NetCtrl.m_MainNetObj = nil
					end
					g_NetCtrl:AutoReconnect()
				end,
				cancelStr = "返回登录",
				cancelCallback = function()
					if g_LoginPhoneCtrl.m_IsPC then
						g_LoginPhoneCtrl:ResetAllData()
		            	CLoginPhoneView:ShowView(function (oView) oView:RefreshUI() end)
			        else
			        	if g_LoginPhoneCtrl.m_IsQrPC then
			        		g_LoginPhoneCtrl:ResetAllData()
			        		CLoginPhoneView:ShowView(function (oView)
				                oView:RefreshUI()
				                --这里是在有中心服的数据情况下
				                g_ServerPhoneCtrl:OnEvent(define.Login.Event.ServerListSuccess)
				            end)
			        	else
			            	g_SdkCtrl:Logout()
			            end
			        end
				end,
				closeType = 3,
				isOkNotClose = false,
				hideClose = true,
			}
			g_WindowTipCtrl:SetWindowNetConfirm(args, function (oView)
				g_NetCtrl.m_NetConfirmView = oView
			end)
			g_LoginPhoneCtrl.m_Logined = false
		elseif g_TimeCtrl.m_BeatTimer then
			g_TimeCtrl:HeartBeat()
		end
		return
	end
	
	printc("CApplicationCtrl.ApplicationFocus", UnityEngine.Time.realtimeSinceStartup, self.m_FocusTime, isfocus)
	self.m_FocusTime = UnityEngine.Time.realtimeSinceStartup--]]
end

return CApplicationCtrl
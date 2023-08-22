main = {}
main.g_GameType = "dev" --dev, banshu, release, bussiness
main.g_TestType = 0 --1.战斗测试
main.g_IsInitDone = false

--C#回调 
function main.start()
	main.InitEnv()
	local function check()
		if g_ResCtrl:IsInitDone() and CNotifyView:GetView() then
			main.StartGame()
		else
			return true
		end
	end
	Utils.AddTimer(check, 0, 0)
end

function main.update(dt)
	local iUnScaleTime = (dt / UnityEngine.Time.timeScale)
	UnityEngine.Time:SetDeltaTime(dt, iUnScaleTime)
	g_TimerCtrl:Update()
	if main.g_IsInitDone then
		g_NetCtrl:Update()
		g_ActionCtrl:Update(dt)
		g_MagicCtrl:Update(dt)
		g_ResCtrl:Update(iUnScaleTime)
		g_WarCtrl:Update(iUnScaleTime)
		g_NotifyCtrl:Update(dt)
	end
	UnityEngine.Time:SetFrameCount()
end

function main.lateupdate(dt)
	g_TimerCtrl:LateUpdate()
	if main.g_IsInitDone then
		g_ActionCtrl:LateUpdate(dt)
		g_QRCtrl.LateUpdate(dt)
	end
end

function main.pause(bPaused, iPausetime)
	-- printerror("game pause", bPaused, iPausetime)
	if not bPaused then
		if not g_LoginPhoneCtrl.m_Logined or not g_WarCtrl:IsWar() then
			return	
		end
		--简化规则，以每人2秒估算动画时间，超出即重连，跳过因切入后台导致的多余回合
		local iCount = table.count(g_WarCtrl:GetWarriors())
		if iPausetime > iCount * 2 then 
			g_NetCtrl:AutoReconnect()
		end
	end
end

function main.RequireModule()
	require "logic.logic"
	require "net.net"
	if Utils.IsEditor() then
		require "logic.editor.editor"
	end
end

function main.InitEnv()
	main.RequireModule()
	if gameconfig.Debug.ClientDebug then
		print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "main.InitEnv", "注意：客户端UI调试开关已打开"))
	end

	-- 游戏Resource数据初始化
	g_GameDataCtrl:InitCtrl()

	if Utils.IsDevUser() then
		CGmFunc.LocalUpdate()
	end
	UnityEngine.Time.maximumDeltaTime = 60
	-- 随机数种子
	local revtime = tostring(os.time()):reverse():sub(1,3)
	math.randomseed(revtime)

	local imei = UnityEngine.SystemInfo.deviceUniqueIdentifier:sub(1,3)
	imei = tostring(tonumber(string.gsub(imei, "-", ""), 16))
	local seed = tonumber(revtime .. imei)

	printc("随机数种子", seed)
	UnityEngine.Random.InitState(seed)

	C_api.Utils.SetGlobalEventHanlder(main.call)
	Utils.UpdateLogLevel()
	protobuf.registerProto("proto/proto.pb")
	main.AdjustFrameRate()

	g_ResCtrl:InitLoad() --预加载资源

	g_EasyTouchCtrl:InitCtrl()
	g_UITouchCtrl:InitCtrl()
	g_SpeechCtrl:InitCtrl()
	g_ApplicationCtrl:InitCtrl()
	g_ScreenResizeCtrl:InitCtrl()

	g_UrlRootCtrl:ResetCSRootUrl()
	g_LoginPhoneCtrl:InitCtrl()

	g_HotKeyCtrl:InitCtrl()

	CNotifyView:ShowView()

	main.g_IsInitDone = true
end

function main.ProcessScene()
	local sScveneName = Utils.GetActiveSceneName()
	if sScveneName == "editorMagic" then
		CEditorMagicView:ShowView()
		return true
	elseif sScveneName == "editorBuff" then
		CEditorBuffView:ShowView()
		return true
	elseif sScveneName == "editorAnim" then
		CEditorAnimView:ShowView()
		return true
	elseif sScveneName == "editorCamera" then
		CEditorCameraView:ShowView()
		return true
	elseif sScveneName == "editorLineup" then
		CEditorLineupView:ShowView()
		return true
	elseif sScveneName == "editorTable" then
		CEditorTableView:ShowView()
		return true
	end
	return false
end

function main.AdjustFrameRate()
	if Utils.IsWin() then
		UnityEngine.Application.targetFrameRate = 30
	else
		UnityEngine.Application.targetFrameRate = 30
	end
	Utils.g_FrameTime = 1 / UnityEngine.Application.targetFrameRate
end

function main.ChangeFrameRate(iRate)
	UnityEngine.Application.targetFrameRate = iRate
	Utils.g_FrameTime = 1 / UnityEngine.Application.targetFrameRate
end

function main.StartGame()
	if Utils.IsEditor() then
		DataTools.RefreshData()
		if gameconfig.Debug.ClientDebug then
			g_NotifyCtrl:FloatMsg("注意：客户端UI调试开关已打开")
		end
	end

	if Utils.IsPC() then
		Utils.SetWindowTitle(g_GameDataCtrl:GetGameName())
		main.DoStartGame()
		return
	elseif g_LoginPhoneCtrl.m_IsPC then
		main.DoStartGame()
		return
	end
	main.DoStartGame()
	-- local url = g_UrlRootCtrl.m_CSRootUrl.."loginverify/check_sdk_open"
	-- local headers = {
	-- 	["Content-Type"]="application/json;charset=utf-8",
	-- }
	-- local bytes = cjson.encode({})
	-- local function result(success, tResult)
	-- 	if success then
	-- 		if tResult.open_state == 1 then
	-- 			main.DoStartGame()
	-- 		else
	-- 			local windowConfirmInfo = {
	-- 	            msg = "服务器暂未开放，敬请等待...",
	-- 	            thirdStr = "我知道了",
	-- 	            closeType = 3,
	-- 	            pivot = enum.UIWidget.Pivot.Center,
	-- 	            thirdCallback = function() Utils.QuitGame() end,
	-- 				style = CWindowNetComfirmView.Style.Single,
	--             }
	--             g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	-- 		end
	-- 	else
	-- 		table.print(tResult, "检查sdk是否开放 check_sdk_open result err")
	-- 	end
	-- end
	-- g_HttpCtrl:Post(url, result, headers, bytes, {json_result=true})
end

function main.DoStartGame()
	UnityEngine.QualitySettings.antiAliasing = 2
	g_HudCtrl:InitRoot()
	g_GuideCtrl:StartCheck()
	g_ResCtrl:LoadOnStart()
	if main.ProcessScene() then
		C_api.Utils.HideGameLoading()
		g_CameraCtrl:InitCtrl()
		return
	elseif main.g_TestType ~= 0 then
		C_api.Utils.HideGameLoading()
		g_CameraCtrl:InitCtrl()
		main.ProcessTest(main.g_TestType)
		return
	end

	g_SystemSettingsCtrl:ReadLocalSettings()
	g_AudioCtrl:PlayMusic(define.Audio.MusicPath.login)
	g_LoginPhoneCtrl:ResetAllData()
	CLoginPhoneView:ShowView(function (oView)
		oView:RefreshUI()
		g_SdkCtrl:BeforInit()
	end)
end

function main.ProcessTest(iType)
	if iType == 1 then
		warsimulate.Test()
	elseif iType == 2 then
		warsimulate.FirstSpecityWar()
		-- g_AttrCtrl:UpdateAttr({school=1})
		-- CSkillMainView:ShowView()
	elseif iType == 3 then
		warsimulate.Start(15, 1110, 1)
		-- CNpcShopView:ShowView()
	elseif iType == 4 then
		CSystemSettingsMainView:ShowView()
	elseif iType == 5 then
		CFriendInfoView:ShowView()
	end
end




function main.Test()
	local mri = require("memory/MemoryReferenceInfo")
	mri.m_cConfig.m_bAllMemoryRefFileAddTime = false
	collectgarbage("collect")
	mri.m_cMethods.DumpMemorySnapshot("./", "1-Before", -1)
end


function main.Test2()
	local mri = require("memory/MemoryReferenceInfo")
	mri.m_cConfig.m_bAllMemoryRefFileAddTime = false
	
	collectgarbage("collect")
	mri.m_cMethods.DumpMemorySnapshot("./", "2-After", -1)

	mri.m_cMethods.DumpMemorySnapshotComparedFile("./", "Compared", -1, "./LuaMemRefInfo-All-[1-Before].txt", "./LuaMemRefInfo-All-[2-After].txt")
end

function main.Test3()
	collectgarbage("collect")
end

function main.call(id, ...)
	return g_DelegateCtrl:CallDelegate(id, ...)
end

function main.tip(str)
	-- 实现逻辑
	g_NotifyCtrl:FloatMsg("测试用" .. str)
end

return main

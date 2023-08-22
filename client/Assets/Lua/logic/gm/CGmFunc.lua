module(..., package.seeall)
function testjson(...)
	str = table.concat({...}, " ")
	printc(str)
	table.print(decodejson(str), "json解析:")
end

function testpay()
	if Utils.IsAndroid() then
		CAndroidShopView:ShowView()
	else
		CIOSShopView:ShowView()
	end
	
end

function DumpLuaDataFile()
	C_api.Utils.DumpLuaDataFile()
end

function test111()
	main.ResetGame()
end

function server()
	-- local path = IOTools.GetPersistentDataPath("/server_list.json")
	-- IOTools.SaveJsonFile(path, g_ServerCtrl.g_DevServer)
end

function forcesaverecord()
	g_NetCtrl:SaveRecordsToLocal("war"..os.date("%y_%m_%d(%H_%M_%S)", g_TimeCtrl:GetTimeS()), {side=g_WarCtrl:GetAllyCamp()})
end

function reconnect()
	-- g_MapCtrl:Load(1010, Vector3.New(10, 10, 10))
	-- Utils.AddTimer(function() g_MapCtrl:Load(2080, Vector3.New(12, 12, 12)) end, 0, 0)
	-- Utils.AddTimer(function() g_MapCtrl:Load(1010, Vector3.New(12, 12, 12)) end, 0, 0)
	-- Utils.AddTimer(function() g_MapCtrl:Load(2080, Vector3.New(12, 12, 12)) end, 0, 0)
	-- Utils.AddTimer(function() g_MapCtrl:Load(1010, Vector3.New(12, 12, 12)) end, 0, 0)
	-- Utils.AddTimer(function() g_MapCtrl:Load(2080, Vector3.New(12, 12, 12)) end, 0, 0)
end

function banguide()
	-- CGuideCtrl.LoginInit = function() end
	g_NotifyCtrl:FloatMsg("停止新手引导")
	IOTools.SetClientData("banguide", true)
end

function openlog()
	IOTools.SetClientData("logflag", 1)
	Utils.UpdateLogLevel()
	g_NotifyCtrl:FloatMsg("开启log")
end

function closelog()
	IOTools.SetClientData("logflag", 0)
	Utils.UpdateLogLevel()
	g_NotifyCtrl:FloatMsg("关闭log")
end

function showitem(sid, virtual)
	sid = sid or 405
	virtual = virtual or 0
	local item_list = {
			[1] = {
				amount = 1,
				sid = tonumber(sid),
				virtual = tonumber(virtual),
			}
		}
	g_WindowTipCtrl:SetWindowAllItemRewardList(item_list)
end

function openguide()
	-- CGuideCtrl.LoginInit = function() end
	g_NotifyCtrl:FloatMsg("开启新手引导")
	IOTools.SetClientData("banguide", false)
end

function testguide1()
	CGuideView:ShowView(function(oView)
		oView.m_EventWidget:SetActive(false)
		oView.m_FocusBox.m_Collider:SetActive(false)
			-- oView.m_FocusBox.m_Mat:SetVector("_SkipRange", Vector4.New(0.5, 0.5, 0.2, 0.2))
		end)
end

function code(content)
	local  f = loadstring(content)
end

function testguide2()
	CGuideView:ShowView(function(oView)
		-- oView.m_EventWidget:SetActive(false)
		-- oView.m_FocusBox.m_Collider:SetActive(false)normalupdate
			oView.m_FocusBox.m_Mat:SetVector("_SkipRange", Vector4.New(0.5, 0.5, 0.1, 0.1))
			oView.m_FocusBox:SimulateOnEnable()
		end)
end


function testupdate()
	g_NotifyCtrl:FloatMsg("测试更新模式, 请重启")
	IOTools.SaveTextFile(IOTools.GetPersistentDataPath("/testupdate"), "")
end

function normalupdate()
	g_NotifyCtrl:FloatMsg("正常更新模式, 请重启")
	IOTools.Delete(IOTools.GetPersistentDataPath("/testupdate"))
end

function pfmeditor()
	require "logic.editor.editor"
	CLoginView:CloseView()
	CEditorMagicView:ShowView()
end

function MapCameraSize(i)
	local i = tonumber(i)
	if i then
		g_CameraCtrl:SetMapCameraSize(i)
	end
end

function testview()
	--g_ResCtrl:LoadCloneAsync("Model/Character/130/Prefabs/model130.prefab", function(oClone, path)  printc(">>>>>>>>", oClone, path)end)
	CTestView:ShowView()
end

function record()
	-- g_NetCtrl:PlayRecord("war17_05_05-14-27-41")
	local list = IOTools.GetFilterFiles(IOTools.GetAssetPath("/Other/warbug/"), function(s) return string.find(s, "%.meta$") == nil end, true)
	local list1 = IOTools.GetFilterFiles(g_NetCtrl:GetRecordFilePath(""), function(s) return string.find(s, "%.meta$") == nil end, true)
	table.extend(list, list1)
	local function wrapFunc(v)
		return IOTools.GetFileName(v, false)
	end
	local function selFunc(v)
		g_NetCtrl:PlayRecord(v)
	end

	CMiscSelectView:ShowView(function(oView)
			oView:SetData(list, selFunc, wrapFunc)
		end)
end

function console()
	CGmConsoleView:ShowView()
end

function testgc1()
	main.cnt = 0
	collectgarbage("collect")
	collectgarbage("collect")
	collectgarbage("collect")
	collectgarbage("collect")
	local i1= main.Test2()
	local function t()
		local cls = CItemBagMainView
		if cls:GetView() then
			cls:CloseView()
			collectgarbage("collect")
		else
			cls:ShowView()
		end
		main.cnt = main.cnt +1
		if main.cnt < 400 then
			return true
		else
			g_ItemCtrl:Clear()
			g_AttrCtrl:Clear()
			g_UITouchCtrl:Clear()
			g_DelegateCtrl:Clear()
			g_ViewCtrl:Clear()
			-- table.print(g_ViewCtrl)
			local i2 = main.Test2()
			printerror("-->Add", i2-i1)
			return false
		end
	end

	Utils.AddTimer(t, 0.03, 0.1)
end

function testgc2()
	collectgarbage("collect")
	collectgarbage("collect")
	local i = collectgarbage("count")
	printc('内存为' .. i, table.count(g_DelegateCtrl.m_Delgates))
	return i
end

function gc()
	CGmView:CloseView()
	local count1 = collectgarbage("count")
	local time1 = g_TimeCtrl:GetTimeMS()
	g_ResCtrl:GC()
	local count2 = collectgarbage("count")
	g_NotifyCtrl:FloatMsg(string.format("时间: %d, 回收前%d, 回收后%d", g_TimeCtrl:GetTimeMS()-time1, count1, count2))
end

function gcarg(mul, pause)
	mul = tonumber(mul)
	pause = tonumber(pause)
	printerror("设置", mul, pause)
	if mul then
		collectgarbage("setstepmul", mul)
	end
	if pause then
		collectgarbage("setpause", pause)
	end
end

function luamem()
	print(collectgarbage("count"))
end

function testgc()
	-- local time = g_TimeCtrl:GetTimeMS()
	-- print("回收前:" , collectgarbage("count"))
	-- local i = 3000
	-- while collectgarbage("step", i) == false do
	-- 	i = i+1
	-- 	print("回收后:" , collectgarbage("count"), collectgarbage("step", 0)collectgarbage("count"), i)
		
	-- end
	-- print("回收后:" , collectgarbage("count"), i)
end

function testhouse()
	local t = {type=1, lock_status=1, level=2, secs = 0}
	nethouse.GS2CFurnitureInfo({furniture_info=t})
end

function maptime()
	g_MapCtrl.m_FloatTime = true
end

function parresult()
	netpartner.GS2CDrawCardResult({type=1, partner_list={1000,1001,1002}})
end

function sendbig()
	nettest.C2GSTestBigPacket(string.rep("A", 1024*1024))
end

function teamfollow(cnt)
	local oHero = g_MapCtrl:GetHero()
	local pos = oHero:GetPos()
	local list = {g_AttrCtrl.pid}
	cnt = cnt and tonumber(cnt) or 1
	for i=1, cnt do
		local dPlayer = {
			eid = 10000+i,
			pid = 10000+i,
			pos_info = {x=pos.x+i, y = pos.y+i},
			block = {
				mask = 3,
				name = "Player"..tostring(i),
				model_info = {shape=1110, weapon=1},
			}
		}
		g_MapCtrl:AddPlayer(dPlayer.pid, dPlayer)
		table.insert(list, dPlayer.pid)
	end
	netscene.GS2CSceneCreateTeam({scene_id=g_MapCtrl:GetSceneID(), team_id=1, pid_list=list})
	netscene.GS2CSceneCreateTeam({scene_id=g_MapCtrl:GetSceneID(), team_id=1, pid_list=list})
	-- g_MapCtrl:DelWalker(10000+1)
	-- local i = 2
	-- local dPlayer = {
	-- 	eid = 10000+i,
	-- 	pid = 10000+1,
	-- 	pos_info = {x=pos.x+i, y = pos.y+i},
	-- 	block = {
	-- 		mask = 3,
	-- 		name = "Player"..tostring(1),
	-- 		model_info = {},
	-- 	}
	-- }
	-- g_MapCtrl:AddPlayer(dPlayer.pid, dPlayer)
end

function testspeech()
	CSpeechCtrl.g_TestSpeech = true
end

function playerspeech(iMax)
	iMax = tonumber(iMax) or 1
		for i =1, iMax do
		local dMsg = {
			channel = 1,
			text = LinkTools.GenerateSpeechLink("testplayerspeech"..tostring(i), "别人发的语音", 10),
			role_info = {
				pid = 999888,
				grade = 50,
				name = "deep",
				shape = 1110,
			},
		}
		g_ChatCtrl:AddMsg(dMsg)
	end
end

function testprofiler(cnt)
	local oHero = g_MapCtrl:GetHero()
	local pos = oHero:GetPos()
	local list = {g_AttrCtrl.pid}
	cnt = cnt and tonumber(cnt) or 20
	for i=1, cnt do
		local dPlayer = {
			eid = 10000+i,
			pid = 10000+i,
			pos_info = {x=pos.x, y = pos.y},
			block = {
				mask = 3,
				name = "Player"..tostring(i),
				model_info = {shape = 3120+i%23},
			}
		}
		g_MapCtrl:AddPlayer(dPlayer.pid, dPlayer)
		table.insert(list, dPlayer.pid)
	end
end

function testchat(sText)
	local dMsg = {
		channel = 1,
		text = sText,
		role_info = {
			pid = g_AttrCtrl.pid,
			grade = 50,
			name = "deep",
			shape = 1110,
		},
	}
	g_ChatCtrl:AddMsg(dMsg)
end

function shape(sShape)
	local oHero = g_MapCtrl.m_Hero
	local model_info = {}
	model_info.shape = tonumber(sShape)
	oHero:ChangeShape(model_info)
end

function weapon(i)
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		i = tonumber(i) or nil
		local model_info = table.copy(oHero.m_Actor.m_CurDesc)
		model_info.weapon = i
		oHero:ChangeShape(model_info.shape, model_info)
	end
end

function horse(i)
	i = tonumber(i) or nil
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		local model_info = table.copy(oHero.m_Actor.m_CurDesc)
		model_info.horse=i
		oHero:ChangeShape(model_info.shape, model_info)
	end
end

function clientrelogin()
	g_NetCtrl:AutoReconnect()
end

function clientlogin()
	g_AttrCtrl:UpdateAttr({pid = 10000, name="一个人", model_info ={shape=1110, weapon=nil, horse=nil}})
	g_MapCtrl:ShowScene(1, 101000, "单机")
	g_MapCtrl:EnterScene(1, {x=10, y = 10})

	CLoginView:CloseView()
	CMainMenuView:ShowView()
	CGmMainView:CloseView()
end

function printsyncpos()
	datauser.netdata.BAN["print"]["scene"] = {}
end

function xunluo()
	local oHero = g_MapCtrl:GetHero()
	oHero:StartAutoPatrol()
end

function recteffect()
	local oView = CLoginView:GetView()
	if oView then
		oView.m_AccountPart.m_LoginBtn:AddEffect("Rect")
	end
end

function ShowWalkerView()
	CModelActionView:ShowView()
end

function Beat(i)
	g_TimeCtrl.m_BeatDelta = tonumber(i) or 5
end

function LocalUpdate()
	local path = IOTools.GetPersistentDataPath("/localcode.lua")
	if IOTools.IsExist(path) then
		local s = IOTools.LoadTextFile(path)
		if s then
			loadstring(s)()
			g_NotifyCtrl:FloatMsg("本地更新完成")
		else
			g_NotifyCtrl:FloatMsg("本地更新失败")
		end
	end
end

function LocalUpdate2()
	local s = require "logic.updatecode"
	loadstring(s)()
	g_NotifyCtrl:FloatMsg("测试更新完成")
end

function WarLogConsole(lv)
	g_WarCtrl.g_Print = lv == "1"
end

function ShowServerTime()
	local oView = CNotifyView:GetView()
	if oView then
		oView:SwitchServerTime(true)
	end
end

function LuaReplace()
	local filelist = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic"), "*.lua", true)
	for i, fielname in ipairs(filelist) do
		local newname = string.gsub(fielname, "Page", "TEMP000")
		if newname ~= fielname then
			IOTools.Move(fielname, newname)
		end
	end
	local filelist = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic"), "*.lua", true)
	for i, fielname in ipairs(filelist) do
		local newname = string.gsub(fielname, "Partner", "TEMP001")
		newname = string.gsub(newname, "Part", "Page")
		if newname ~= fielname then
			IOTools.Move(fielname, newname)
		end
	end
	local filelist = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic"), "*.lua", true)
	for i, fielname in ipairs(filelist) do
		local newname = string.gsub(fielname, "TEMP000", "Part")
		newname = string.gsub(newname, "TEMP001", "Partner")
		if newname ~= fielname then
			IOTools.Move(fielname, newname)
		end
	end

	local filelist = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic"), "*.lua", true)
	for i, fielname in ipairs(filelist) do
		local s = IOTools.LoadTextFile(fielname)
		s = string.gsub(s, "Page","TEMP000")
		s = string.gsub(s, "Partner","TEMP001")
		s = string.gsub(s, "Part","Page")
		s = string.gsub(s, "TEMP000","Part")
		s = string.gsub(s, "TEMP001","Partner")
		IOTools.SaveTextFile(fielname, s)
	end
end

function UpdateMagicFile()
	local patlist = {}
	local idx = 0
	CEditorMagicView:ShowView()
	CEditorMagicBuildCmdView:ShowView()
	local nilfunc = function()end
	CEditorMagicView.RefreshWar = nilfunc
	CEditorComplexArgBox.GetChangeFunc = nilfunc
	CEditorNormalArgBox.SetValueChangeFunc = nilfunc
	CEditorMagicBuildCmdView.OnConfirm= function(o)
		local dCmd = o:GetCmdData()
		if o.m_ConfirmCallback then
			o.m_ConfirmCallback(o.m_Idx, dCmd)
		end
	end
	local function update()
		local oView = CEditorMagicView:GetView()
		local oBuildCmdView = CEditorMagicBuildCmdView:GetView()
		if oView and oBuildCmdView then
			local paths = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic/magic/magicfile"), "*.lua", false)
			oBuildCmdView:SetConfirmCB(callback(oView.m_CmdListBox, "OnCmdViewConfirm"))
			-- paths = {"D:/Workspace/H7/client/trunk/Assets/Lua/logic/magic/magicfile/magic_0_1.lua"}
			for i, path in ipairs(paths) do
				if not table.index(patlist, path) then			
					oView:LoadMagicFile(path)
					local list = oView.m_LoadData.cmds
					--单独插入一条指令
					--table.insert(list,{args={alive_time=0.5,},func_name=[[Name]],start_time=0,})
					if list then
						for idx, dData in ipairs(list) do
							oBuildCmdView.m_AllData = {}
							oBuildCmdView.m_OldStartTime = 0
							oBuildCmdView.m_CurCmdName = nil
							oBuildCmdView.m_ArgsTable:Clear()
							oBuildCmdView:SetCmdIdxAndData(idx, dData)
							oBuildCmdView:OnConfirm()
						end
						oView:OnSaveFile()
					end
					table.insert(patlist, path)
					idx = idx + 1
					print(idx)
					return true
				end
			end
			printc("Done")
			return false
		else
			return true
		end
	end
	Utils.AddTimer(update, 0, 0)
end

function FloatTimeFile()
	local paths = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic/magic/magicfile"), "*.lua", false)
	local dMap = {}
	for _, path in ipairs(paths) do
		local _, magic, index = unpack(string.split(path, "_"))
		index = unpack(string.split(index, "."))
		local s = string.format("magic_%s_%s", magic, index)
		local d = require("logic.magic.magicfile."..s)
		-- printc(d.magic_anim_start_time)
		if d.DATA.magic_anim_end_time then
			dMap[tonumber(magic)] = {}
			for k, path in ipairs(paths) do
				local _, magic2, index2 = unpack(string.split(path, "_"))
				index2 = unpack(string.split(index2, "."))
				local s2 = string.format("magic_%s_%s", magic2, index2)
				local d2 = require("logic.magic.magicfile."..s)
				if d2.DATA.magic_anim_start_time then
					local iVal = -d2.DATA.magic_anim_start_time
					if iVal < 0 then
						dMap[tonumber(magic)][tonumber(magic2)] = iVal
					end
				end
			end
		end
	end
	local path = IOTools.GetAssetPath("/floattime.lua")
	local s = "module(...)\n--magic editor build\n"..table.dump(dMap, "DATA")
	IOTools.SaveTextFile(path, s)
	g_NotifyCtrl:FloatMsg("保存成功  "..path)
	printc("保存成功  "..path)
end

function changeAttrMainLayer()
	if g_AttrCtrl.m_AttrMainLayer == nil then
		g_AttrCtrl.m_AttrMainLayer = 1
	else
		g_AttrCtrl.m_AttrMainLayer = nil
	end
	printc(" changeAttrMainLayer  >>>>>>>>>>> ", g_AttrCtrl.m_AttrMainLayer )
end

function SetGMBtnActive()
	if g_AttrCtrl.m_IsGM == 1 then
		g_NotifyCtrl:FloatMsg("GM号貌似无法关闭GM哦")
		return
	end
	local oView = CNotifyView:GetView()
	if oView:GetActive() then
		local active = oView.m_OrderBtn:GetActive()
		oView.m_OrderBtn:SetActive(not active)
		oView.m_GMShopBtn:SetActive(not active)
		oView.m_MainMenuBtn:SetActive(not active)
	end
end

function opensysmessage()
	g_ChatCtrl.m_IsMessageRecord = true
end

function closesysmessage()
	g_ChatCtrl.m_IsMessageRecord = false
end

function OpenNetTimeMS()
	g_GmCtrl.m_GMRecord.Logic.printNetTime = true
end

function CloseNetTimeMS()
	g_GmCtrl.m_GMRecord.Logic.recordNetTime = 0
	g_GmCtrl.m_GMRecord.Logic.printNetTime = false
end

function openLogConsole()
	gameconfig.Debug.DebugConsole = true
	Utils.UpdateLogLevel()
	g_NotifyCtrl:FloatMsg("开启日志打印")
end

function closeLogConsole()
	gameconfig.Debug.DebugConsole = false
	Utils.UpdateLogLevel()
	g_NotifyCtrl:FloatMsg("关闭日志打印")
end

function consoleMemoryBefore()
	g_NotifyCtrl:FloatMsg("输出Before内存到文件 ../trunk/LuaMemRefInfo-All-[1-Before].txt")
	main.Test()
end

function consoleMemoryAfter()
	main.Test2()
	g_NotifyCtrl:FloatMsg("输出After内存到文件，并比对 ../trunk/LuaMemRefInfo-All-[2-After].txt | xxx-[Compared].txt")
end

function openLuaMemory()
	g_NotifyCtrl:FloatMsg("查看当前Lua内存")
	g_NotifyCtrl:SetMoneryInfo(true)
end

function closeLuaMemory()
	g_NotifyCtrl:FloatMsg("关闭当前Lua内存")
	g_NotifyCtrl:SetMoneryInfo(false)
end

function openStats()
	g_NotifyCtrl:FloatMsg("打开Stats查看器")
	g_NotifyCtrl:SetStatsInfo(true)
end
function closeStats()
	g_NotifyCtrl:FloatMsg("关闭Stats查看器")
	g_NotifyCtrl:SetStatsInfo(false)
end

function setSameScreenCnt(cnt)
 	
 	g_MapPlayerNumberCtrl:SetSameScreenCnt(cnt)

 end 

 function startSyncPos()
 	
 	g_MapCtrl:StopSyncPos(false)

 end

 function stopSyncPos()
 	
 	g_MapCtrl:StopSyncPos(true)

 end

 function stopAoiWalker()
  	
  	g_MapCtrl:StopAoiWalker(true)

  end 

function clearsysmessage()
	g_ChatCtrl:GetSysMessageSaveData()
	g_ChatCtrl.m_MessageList = {}
	g_ChatCtrl:SaveSysMessageData("")
end

function closeProtoDelay()
	g_GmCtrl.m_GMRecord.Logic.protoDelay = false
end

function openProtoDelay()
	g_GmCtrl.m_GMRecord.Logic.protoDelay = true
end

function getbadgeinfo()
	-- body
	net.nettouxian:C2GSUpgradeTouxian()
end

function OpenPlot(i)
	CGmMainView:CloseView()
	local function cb()
		netother.C2GSGMCmd("repos")
		-- netscene.C2GSReenterScene()
	end
	g_PlotCtrl:SetFinishPlotCb(cb)
	local iPlotId = tonumber(i)
	g_PlotCtrl:PlayPlotById(iPlotId or 1)
end

function TestWedding(iShape1, iShape2, bMy, iType)
	-- MarryDebug = reimport "logic.gm.MarryDebug"
	MarryDebug:SimulateWedding(iShape1, iShape2, bMy, iType)
end

function findItemIdByName(name)
	if name == nil then
	   g_NotifyCtrl:FloatMsg("请输入你要查找道具的名字")
	   return
	end
	local names = {
		"itemotherdata",
		"itemvirtualdata",
		"itemgroupdata",
		"itemequipdata",
		"itemsummondata",
		"itemsummskilldata",
		"itemsummonequipdata",
		"itemforgedata",
		"itemequipbookdata",
		"itemequipsouldata",
		"itempartnerdata",
		"itempartnerequipdata",
		"itemtotaskdata",
		"itemgiftpackdata",
		"itemboxdata",
		"itemwenshidata"
	}
	local nameTable = {}
	for _,n in ipairs(names) do
		local itemData = data[n]
		for k,v in pairs(itemData) do
			if type(v) == "table" then
				for key,value in pairs(v) do
					if value.name then
					   if string.find(value.name,name) then
					      nameTable[#nameTable + 1] = value
					   end
					end
				end
			end
		end
	end
	--table.print(nameTable,"筛选后：")
	if next(nameTable) == nil then
	   g_NotifyCtrl:FloatMsg("未找到该名字的道具")
	   return
	end
	table.sort(nameTable, function(a,b) return a.id < b.id end )
	local sortTable = {}
	local str = ""
	for i,item in ipairs(nameTable) do
		if i <= 5 then
			printc("道具名字：",item.name,"    道具Id:",item.id)
			if str == "" then
			   str = str.."名字："..item.name.." Id:"..item.id
			else
				str = str.."\n".."名字："..item.name.." Id:"..item.id
			end
		end
	end
	local windowConfirmInfo = {
        msg = str,
		depthType = "Top",
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    CGmMainView:CloseView()
end

function SDKLogin()
	g_SdkCtrl:Login()
end

function SDKLogout()
	g_SdkCtrl:Logout()
end

function SDKSwitchAccount()
	g_SdkCtrl:SwitchAccount()
end

function SDKOnExiter()
	g_SdkCtrl:DoExiter()
end

function HideRide()
	g_GmCtrl.m_HideRide = true
end

function ShowRide()
	g_GmCtrl.m_HideRide = true
end

function HideSwing()
	g_GmCtrl.m_HideSwing = true
end

function ShowSwing()
	g_GmCtrl.m_HideSwing = false
end

function enterKs()
	g_KuafuCtrl:EnterKs("ks101", nil)
end

function backGs()
	g_KuafuCtrl:BackGs()
end

function preload()
	if g_GmCtrl.m_TestLoad == nil then
		g_GmCtrl.m_TestLoad = false
	end
	g_GmCtrl.m_TestLoad = not g_GmCtrl.m_TestLoad
	if g_GmCtrl.m_TestLoad then
		g_NotifyCtrl:FloatMsg("更改加载模式 预加载模式")
	else
		g_NotifyCtrl:FloatMsg("更改加载模式 原始模式")
	end
end
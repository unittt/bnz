CGmMainView = class("CGmMainView", CViewBase)

function CGmMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/GM/GMMainView.prefab", cb)

	--界面设置
	self.m_DepthType = "Guide"
	self.m_GroupName = "notify"
	-- self.m_ExtendClose = "Black"

	self.m_TabType = nil
	self.m_Config = nil
end

function CGmMainView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)

	self.m_GmTabGrid = self:NewUI(3, CGrid)
	self.m_CloneTabBtn = self:NewUI(4, CButton, true, false)

	self.m_CommandInput = self:NewUI(5, CInput)
	self.m_CommandExecuteBtn = self:NewUI(6, CButton, true, false)
	self.m_SyncTimeLabel = self:NewUI(7, CLabel)

	self.m_BtnInfoGroup = self:NewUI(8, CObject)
	self.m_BtnInfoListGrid = self:NewUI(9, CGrid)
	self.m_CloneBtnInfoListBtn = self:NewUI(10, CButton, true, false)
	
	self.m_RecordGroup = self:NewUI(11, CObject)
	self.m_RecordGrid = self:NewUI(12, CGrid)
	self.m_CloneRecordBtn = self:NewUI(13, CButton)
	self.m_RecordCleanBtn = self:NewUI(14, CButton)

	self.m_NilTipObj = self:NewUI(15, CObject)

	self.m_TestGroup = self:NewUI(16, CObject)
	self.m_TestGrid = self:NewUI(17, CGrid)
	self.m_CloneTestBtn = self:NewUI(18, CButton)

	self.m_GmHelpGroup = self:NewUI(19, CObject)
	self.m_GmHelpTabGroup = self:NewUI(20, CGrid)
	self.m_GmHelpGrid = self:NewUI(21, CGrid)
	self.m_CloneGmHelpeBtn = self:NewUI(22, CButton)

	self.m_ConsoleTipGroup = self:NewUI(23, CObject)
	self.m_ConsoleTipLabel = self:NewUI(24, CLabel)
	self.m_ConsoleCleanBtn = self:NewUI(25, CButton)

	self.m_RecordSameBtn = self:NewUI(26, CButton)
	self.m_RecordSameCloseBtn = self:NewUI(27, CButton)

	self:SetLastInstruct()
	self:InitContent()
	self:InitTabListGrid()
	self:InitRecordListBtnGrid()
	self:InitTestListBtnGrid()
	self:InitGmHelpListBtnGrid()
	self:InitConsoleTip()

	self:ShowSpecificPart()
	self:ShowSpecificTab()

	self.m_IsShowItemID = false
end

function CGmMainView.ShowSpecificPart(self, shwoNormal)
	shwoNormal = shwoNormal or true
	self.m_BtnInfoGroup:SetActive(shwoNormal)
	self.m_GmHelpGroup:SetActive(not shwoNormal)
end

function CGmMainView.ShowSpecificTab(self, tabIndex)
	tabIndex = tabIndex or self.m_TabType or g_GmCtrl:GetRecordTab()

	local btnInfo = nil
	if self.m_Config and #self.m_Config > 0 then
		btnInfo = self.m_Config[tabIndex]
		if not btnInfo then
			for i,v in ipairs(self.m_Config) do
				if v and #v then
					tabIndex = i
					btnInfo = v
					break
				end
			end
		end
	end

	if btnInfo then
		local obtn = self.m_GmTabGrid:GetChild(tabIndex)
		obtn:SetSelected(true)

		-- obtn:Notify(enum.UIEvent["click"])
		self:OnGMTabEvent(tabIndex, btnInfo)

		self.m_NilTipObj:SetActive(false)
	else
		self.m_NilTipObj:SetActive(true)
	end
end

function CGmMainView.SetLastInstruct(self)
	if g_GmCtrl.m_RecordInput then
		self:SetCommandInput(g_GmCtrl.m_RecordInput)
	end
end

function CGmMainView.SetCommandInput(self, str)
	g_GmCtrl.m_RecordInput = str
	self.m_CommandInput:SetText(str)
end

function CGmMainView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Gm.Event.RefreshLastInfo then
		self:InitRecordListBtnGrid()
	elseif oCtrl.m_EventID == define.Gm.Event.RefreshGmHelpMsg then
		self:InitConsoleTip()
	end
end

function CGmMainView.OnClose(self)
	g_GmCtrl:DelCtrlEvent(self:GetInstanceID())
	CViewBase.OnClose(self)
end

function CGmMainView.InitContent(self)
	g_GmCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CommandInput:AddUIEvent("submit", callback(self, "OnCommandExecute"))
	self.m_CommandExecuteBtn:AddUIEvent("click", callback(self, "OnCommandExecute"))

	local function update()
		if Utils.IsNil(self) then
			return false
		end

		local time = g_TimeCtrl:GetTimeYMD()
		if time then
			self.m_SyncTimeLabel:SetText("当前服务器时间:" .. time)
		end
		return true
	end
	self.m_Timer = Utils.AddTimer(update, 1, 0)

	self.m_RecordCleanBtn:SetText("清除记录")
	self.m_RecordCleanBtn:AddUIEvent("click", callback(self, "OnRecordClean"))

	self.m_ConsoleCleanBtn:SetText("清除GM帮助")
	self.m_ConsoleCleanBtn:AddUIEvent("click", callback(self, "OnConsoleClean"))

	self.m_RecordSameBtn:AddUIEvent("click", callback(self, "OnRecordSame"))
	self.m_RecordSameCloseBtn:AddUIEvent("click", callback(self, "OnRecordSameClose"))

	self.m_CloneTabBtn:SetActive(false)
	self.m_CloneBtnInfoListBtn:SetActive(false)
	self.m_CloneRecordBtn:SetActive(false)
	self.m_CloneTestBtn:SetActive(false)
end

function CGmMainView.OnCommandExecute(self)
	local sParam = self.m_CommandInput:GetText()
	local sFloatMsg = "请输入GM指令"
	if sParam == "" then
		return
	end
	local bClient = string.find(sParam, '#') ~= nil
	if bClient then
		-- #loadstring code 执行lua代码
		if string.match(sParam, "^#loadstring") then
			local sCode = string.gsub(sParam, "^#loadstring", "")
			loadstring(sCode)()
			sFloatMsg = "执行lua代码"
		else
			sParam = string.sub(sParam, 2)
			local arglist = string.split(sParam, " ")
			if arglist then
				local func = rawget(CGmFunc, arglist[1])
				if func then
					func(unpack(arglist, 2))
					g_GmCtrl:SetRecord("#"..sParam)
				end
			end
			sFloatMsg = "客户端GM指令: " .. sParam
		end
	else
		local startIdx = string.find(sParam, '%$') or 0
		sParam = string.sub(sParam, startIdx+1)
		sFloatMsg = "服务端GM指令: " .. sParam
		self:SetCommandInput(sParam)
		g_GmCtrl:C2GSGMCmd(sParam)
	end
	g_NotifyCtrl:FloatMsg(sFloatMsg)

end

function CGmMainView.OnRecordClean(self)
	g_GmCtrl:CleanRecordInstructDic()
end

function CGmMainView.OnConsoleClean(self)
	g_GmCtrl:CleanConsoleTip()
end

function CGmMainView.OnRecordSame(self)
	g_GmCtrl.m_GMRecord.Logic.recordSame = true
end

function CGmMainView.OnRecordSameClose(self)
	g_GmCtrl.m_GMRecord.Logic.recordSame = false
end

function CGmMainView.InitTabListGrid(self)
	self.m_Config = self.m_Config or CGmConfig.gmConfig
	if self.m_Config and #self.m_Config > 0 then
		for i, v in ipairs(self.m_Config) do
			local oTabBtn = self.m_CloneTabBtn:Clone(false)
			oTabBtn:SetActive(true)
			oTabBtn:SetSize(150, 40)
			oTabBtn:SetText(v.name)

			oTabBtn:AddUIEvent("click", callback(self, "OnGMTabEvent", i, v))
			self.m_GmTabGrid:AddChild(oTabBtn)
		end
	else
		g_NotifyCtrl:FloatMsg("没有GM配置")
	end
end

function CGmMainView.OnGMTabEvent(self, index, arg)
	if (self.m_TabType or 0) ~= index then
		self.m_TabType = index
		if arg then
			self:InitGmListBtnGrid(arg.btnInfo)
			-- Sava
			g_GmCtrl:SetRecordTab(index)
		end
	end
end

function CGmMainView.InitGmListBtnGrid(self, dataInfo)
	local gmConfig = dataInfo or CGmConfig.gmConfig[self.m_TabType].btnInfo
	local showGmList = gmConfig and #gmConfig > 0
	self.m_NilTipObj:SetActive(not showGmList)

	local btnGridList = self.m_BtnInfoListGrid:GetChildList() or {}

	if showGmList then
		for i, v in ipairs(gmConfig) do
			local oGMBtn = nil
			if i > #btnGridList then
				oGMBtn = self.m_CloneBtnInfoListBtn:Clone(false)
				oGMBtn:SetSize(118, 48)
				
				self.m_BtnInfoListGrid:AddChild(oGMBtn)
			else
				oGMBtn = btnGridList[i]
			end
			oGMBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
			oGMBtn:SetActive(true)
			oGMBtn:SetText(v.name)
		end
		if #btnGridList > #gmConfig then
			for i=#gmConfig+1,#btnGridList do
				btnGridList[i]:SetActive(false)
			end
		end
	else
		if btnGridList and #btnGridList > 0 then
			for _,v in ipairs(btnGridList) do
				v:SetActive(false)
			end
		end
	end
end

function CGmMainView.InitRecordListBtnGrid(self)
	local recordInstruct = g_GmCtrl:GetRecordInstruct()
	local showRecordGroup = recordInstruct and #recordInstruct > 0
	self.m_RecordGroup:SetActive(showRecordGroup)
	self:ReSetConsoleTipPos()
	
	if showRecordGroup then
		self.m_RecordInstructBtns = self.m_RecordInstructBtns or {}
		for i=#recordInstruct,1,-1 do
			local v = recordInstruct[i]
			local oRecordBtn = nil
			if #recordInstruct-i >= #self.m_RecordInstructBtns then
				oRecordBtn = self.m_CloneRecordBtn:Clone(false)
				oRecordBtn:SetSize(200, 48)

				self.m_RecordGrid:AddChild(oRecordBtn)
				table.insert(self.m_RecordInstructBtns, oRecordBtn)
			else
				oRecordBtn = self.m_RecordInstructBtns[#recordInstruct-i+1]
			end
			oRecordBtn:SetActive(true)
			oRecordBtn:SetText(v.name)
			oRecordBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
		end

		-- for i, v in ipairs(recordInstruct) do
		-- 	self.m_RecordInstructBtns = self.m_RecordInstructBtns or {}
		-- 	local oRecordBtn = nil
		-- 	if i > #self.m_RecordInstructBtns then
		-- 		oRecordBtn = self.m_CloneRecordBtn:Clone(false)
		-- 		oRecordBtn:SetActive(true)
		-- 		oRecordBtn:SetSize(200, 48)
		-- 		oRecordBtn:SetText(v.name)

		-- 		oRecordBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
		-- 		self.m_RecordGrid:AddChild(oRecordBtn)
		-- 		table.insert(self.m_RecordInstructBtns, oRecordBtn)
		-- 	else
		-- 		oRecordBtn = self.m_RecordInstructBtns[i]
		-- 		oRecordBtn:SetText(v.name)
		-- 		oRecordBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
		-- 	end
		-- end
	else
		if self.m_RecordInstructBtns then
			for _,v in ipairs(self.m_RecordInstructBtns) do
				v:SetActive(false)
			end
		end
	end
end

function CGmMainView.InitTestListBtnGrid(self)
	local tConfig = CGmConfig.testConfig
	local showTestGroup = tConfig and #tConfig > 0
	self.m_TestGroup:SetActive(showTestGroup)

	if showTestGroup then
		for _, v in ipairs(tConfig) do
			local oTestBtn = self.m_CloneTestBtn:Clone(false)
			oTestBtn:SetActive(true)
			oTestBtn:SetSize(100, 36)
			oTestBtn:SetText(v.name)

			oTestBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
			self.m_TestGrid:AddChild(oTestBtn)
		end
	end
end

function CGmMainView.InitGmHelpListBtnGrid(self, dataInfo)
	local tConfig = dataInfo or {}
	if tConfig and #tConfig >  0 then
		for _,v in ipairs(tConfig) do
			local oGmHelpBtn = self.m_CloneGmHelpeBtn:Clone(false)
			oGmHelpBtn:SetActive(true)
			oGmHelpBtn:SetSize(118, 48)
			oGmHelpBtn:SetText(v.name)

			oGmHelpBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
			self.m_GmHelpGrid:AddChild(oGmHelpBtn)
		end
	end
end

function CGmMainView.InitConsoleTip(self)
	local tMsg = g_GmCtrl.m_HelpMsg or ""

	self.m_ConsoleTipGroup:SetActive(string.len(tMsg) > 0)
	if string.len(tMsg) > 0 then
		self:ReSetConsoleTipPos()
		self.m_ConsoleTipLabel:SetText(tMsg)
	end
end

function CGmMainView.ReSetConsoleTipPos(self)
	if self.m_ConsoleTipGroup:GetActive() then
		local tPosX = 168
		if self.m_RecordGroup:GetActive() then
			tPosX = 394
		end
		self.m_ConsoleTipGroup:SetLocalPos(Vector3.New(tPosX, -70, 0))
	end
end

function CGmMainView.OnGMBtnEvent(self, ...)
	local args = {...}
	local arg = args[1]
	local param = arg.param

	if arg.fun then
		local wfobj = weakref(self)
		local funcname = arg.fun
		local real = getrefobj(wfobj)
		if not real then
			return false
		end
		if string.find(funcname, '#') then
			local arglist = string.split(funcname, " ")
			local func = rawget(CGmFunc, arglist[1])
			if func then
				func(unpack(arglist, 2))
			end
			self.m_CommandInput:SetText(funcname)
			return
		end
		local f = real[funcname]
		if f then
			-- self:SetCommandInput(arg.name .. ":" .. arg.param)
			f(real, arg)
		else
			-- 默认调用：C2GSGMCmd
			-- self:SetCommandInput(param)
			g_GmCtrl:C2GSGMCmd(param)
		end
	else
		self:SetCommandInput(param)
	end
end

-- [[本地数据GM指令]]
function CGmMainView.HeroSpeed(self, arg)
	self.m_Config = self.m_Config or CGmConfig.gmConfig
	arg = arg or self.m_Config[self.m_TabType].btnInfo[1]
	local hero = g_MapCtrl:GetHero()
	if hero then
		if hero.m_Walker.moveSpeed < 6 then
			arg.param = "20"
		else
			arg.param = "3"
		end
		local oldSp = hero.m_Walker.moveSpeed
		local speed = tonumber(arg.param)
		hero.m_Walker.moveSpeed = speed
		arg.param = tonumber(oldSp)
		if speed > 6 then
			arg.name = "玩家移速正常"
		else
			arg.name = "玩家移速快"
		end
	else
		printc("没有找到玩家，关闭GM界面")
	end

	self:CloseView()
end

-- function CGmMainView.OpenMapViwe(self, arg)

-- end

-- function CGmMainView.Experience(self, arg)
-- 	self:SetCommandInput(arg.name)
-- end

-- function CGmMainView.OpenBagLock(self, arg)
-- 	self:SetCommandInput(arg[1])
-- 	g_ItemCtrl:ExtBagSize(10)
-- end


function CGmMainView.Test1(self, arg)
	-- self:SetCommandInput(arg.name)
	g_TeamCtrl:TestApply()
end

function CGmMainView.Test2(self, arg)
	-- self:SetCommandInput(arg.name)
	g_TeamCtrl:TestInvite()
end

-- function CGmMainView.Test3(self, arg)
-- 	self:SetCommandInput(arg.name)
-- end

-- [[测试按钮执行]]
function CGmMainView.OnTest1(self, arg)
	g_NotifyCtrl:FloatMsg("程序用：执行测试按钮1")
	self:CloseView()

	g_GmCtrl.m_GMRecord.Logic.debugconsole = not g_GmCtrl.m_GMRecord.Logic.debugconsole
	if g_GmCtrl.m_GMRecord.Logic.debugconsole then
		C_api.GameDebugConsole.Setup()
	else
		C_api.GameDebugConsole.Dispose()
	end
	do return end

	local tick = 3036192745
	local month = os.date("%m", tick)
    local day = os.date("%d", tick)
    local hour = os.date("%H", tick)
    local minute = os.date("%M", tick)
    local second = os.date("%S", tick)

    printerror("月 日 时 分 秒", month, day, hour, minute, second)

	do return end

	warsimulate.FirstSpecityWar()
	self:CloseView()
	do return end

	self.m_CloseBtn:SetStaticSprite("WarAtlas", "h7_di_32")
	do return end

	local pbdata = {
		text = "123456789&Q选项1&Q选项2&Q选项3",
		name = "测试名称"
	}
	g_DialogueCtrl:GS2CNpcSay(pbdata)
end


function CGmMainView.OnTest2(self, arg)
	CGmFunc.LocalUpdate2()
	-- g_ResCtrl:SetReplaceRes("RefReplaceAtlas", "ReplaceTex")
	g_ResourceReplaceCtrl:SetReplaceRes("RefReplaceAtlas", "ReplaceTex")
	-- g_NotifyCtrl:FloatMsg("OnTest2 未添加指令")
end

function CGmMainView.OnTest3(self, arg)
	g_NotifyCtrl:FloatMsg("OnTest3 未添加指令")
end

function CGmMainView.OnWarSimulate(self,arg)
	self:OnClose()
	CGmWarSimulateView:ShowView()
end

function CGmMainView.TestMaskWord()
	CGmCheckView:ShowView()
end

function CGmMainView.OnShowItemID(self)
	self.m_IsShowItemID = not self.m_IsShowItemID
	g_GmCtrl:ShowItemID(self.m_IsShowItemID)
end

return CGmMainView
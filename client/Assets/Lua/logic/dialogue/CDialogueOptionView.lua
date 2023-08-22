local CDialogueOptionView = class("CDialogueOptionView", CViewBase)

function CDialogueOptionView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Dialogue/DialogueOptionView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"

	self.m_NpcSayData = nil
	self.m_TaskList = {}
	self.m_StrList = {}
	self.m_GlobalMenuOptionList = {}
	self.m_GlobalMenuOptionBackList = {}
	self.m_IsTaskHide = false
	self.m_Test = false

	self.m_GlobalNpcTipsId = nil
end

function CDialogueOptionView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_OptionGroup = self:NewUI(2, CObject)
	self.m_OptionGrid = self:NewUI(3, CGrid)
	self.m_CloneOptionBtn = self:NewUI(4, CButton)
	self.m_NpcTexture = self:NewUI(5, CActorTexture)
	self.m_NpcNameLabel = self:NewUI(6, CLabel)
	self.m_NpcContentLabel = self:NewUI(7, CLabel)
	self.m_OptionScrollView = self:NewUI(8, CScrollView)
	self.m_ContentScrollView = self:NewUI(9, CScrollView)
	self.m_NameSp = self:NewUI(10, CSprite)
	self.m_TipsBtn = self:NewUI(11, CButton)
	self:InitContent()
end

function CDialogueOptionView.InitContent(self)
	self.m_TipsBtn:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTips"))
	g_DialogueCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CDialogueOptionView.OnClose(self)
	CViewBase.OnClose(self)

	local oWlker = g_MapTouchCtrl.m_LastMapWalker
	if oWlker and Utils.IsExist(oWlker) then
		oWlker:StartWalkerPatrol()
		oWlker:StartWalkerHeadTalk()
	end
end

function CDialogueOptionView.OnShowView(self)
	g_TaskCtrl.m_GhostTaskGuide.first = false
	g_TaskCtrl.m_FubenTaskGuide.first = false
end

function CDialogueOptionView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Dialogue.Event.InitOption then
		self.m_NpcSayData = oCtrl.m_EventData

		self:InitModelShape()
		self:InitOptionGrid()

		-- printc("NPC对话的内容", self.m_NpcSayData.sessionidx)
		-- table.print(oCtrl.m_EventData,"NPC对话的内容:")
	end
end

--显示npc对话界面的内容
function CDialogueOptionView.InitModelShape(self)
	self.m_CloneOptionBtn:SetActive(false)
	local function loadFinish()
		if Utils.IsExist(self.m_NpcTexture) then
			local oCam = self.m_NpcTexture:GetCamera()
			if oCam then
				-- oCam:PlayerAnimator()
				local oActor = oCam:GetActor()
				if oActor then
					oActor:SetLocalRotation(Quaternion.Euler(15, 0, 0))
				end
			end
		end
	end

	local modelCofig = ModelTools.GetModelConfig(self.m_NpcSayData.model_info.figure)
	local position = Vector3.New(0, modelCofig.posy, 3)
	local model_info = table.copy(self.m_NpcSayData.model_info)
	model_info.pos = position--Vector3.New(0, -0.9, 3)
	model_info.talkState = true
	model_info.horse = nil
	self.m_NpcTexture:ChangeShape(model_info)
	local name = self.m_NpcSayData.name
	if not name or string.len(name) <= 0 then
		name = "这是默认Npc名称"
	end
	self.m_NpcNameLabel:SetText("[0081ab]" .. name)
	local labelWidth = UITools.CalculateRelativeWidgetBounds(self.m_NpcNameLabel.m_Transform).size.x
	local offset = labelWidth - 170
	if offset > 0 then
		self.m_NameSp:SetWidth(300 + offset)
	end

	local mapNpcData = g_MapCtrl:GetNpc(self.m_NpcSayData.npcid)
	if mapNpcData then
		local globalNpc = DataTools.GetGlobalNpc(mapNpcData.m_NpcAoi.npctype)
		if globalNpc and globalNpc.instruction ~= 0 then
			self.m_TipsBtn:SetActive(true)
			self.m_GlobalNpcTipsId = globalNpc.instruction
		end
	end
end

function CDialogueOptionView.InitOptionGrid(self)
	local tMsgStr = self.m_NpcSayData.text
	if tMsgStr and type(tMsgStr) == "string" and string.len(tMsgStr) > 0 then
		local strList = string.split(tMsgStr, "%&Q")
		local showContent = #strList > 0
		self.m_NpcContentLabel:SetActive(showContent)
		if showContent then
			if self.m_Test then
				self.m_NpcContentLabel:SetRichText("[63432c]" .. "#1哈哈哈哈哈")
			else
				if string.find(strList[1],"#time") then 
					--倒数
					local sClone = string.rep(strList[1], 1)
					local function update()
						self.m_NpcSayData.time = self.m_NpcSayData.time - 1
						if not Utils.IsNil(self) then 
							if self.m_NpcSayData.time > 0 then 
								local s = string.gsub(sClone, "#time", tostring(os.date("%M:%S", self.m_NpcSayData.time)))
								self.m_NpcContentLabel:SetRichText("[63432c]" .. s)
								return true
							else 
								netnpc.C2GSClickNpc(self.m_NpcSayData.npcid)
								return false
							end 
						end 	
					end
					self.m_RefreshTimer = Utils.AddTimer(update, 1, 0)

				else 
					self.m_NpcContentLabel:SetRichText("[63432c]" .. strList[1])
				end
			end
			table.remove(strList, 1)
		end
		self.m_StrList = strList

		local btnGridList = self.m_OptionGrid:GetChildList() or {}

		local taskList = {}
		local npcid = self.m_NpcSayData.npcid
		local isDynamicNpc = g_MapCtrl:GetDynamicNpc(npcid)
		if not isDynamicNpc then
			taskList = g_TaskCtrl:GetNpcAssociatedTaskList(npcid)
			-- 过滤不显示的任务
			for i=#taskList,1,-1 do
				local oTask = taskList[i]
				if (oTask:AssociatedSubmit(npcid) and oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM) and not oTask.m_Finish)
				or (oTask:AssociatedSubmit(npcid) and oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON) and not oTask.m_Finish)
				or (oTask:AssociatedSubmit(npcid) and oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_PICK) and not oTask.m_Finish)
				or oTask:IsTaskSpecityCategory(define.Task.TaskCategory.SCHOOLPASS) 
				or (oTask:IsTaskSpecityCategory(define.Task.TaskCategory.LEAD) and (oTask:GetSValueByKey("taskid") == define.Task.SpcTask.GhostGuide or oTask:GetSValueByKey("taskid") == define.Task.SpcTask.FubenGuide)) then
					table.remove(taskList, i)
				end
			end
			self.m_TaskList = taskList
		end
		-- table.print(g_TaskCtrl:GetNpcAssociatedTaskList(npcid), "GetNpcAssociatedTaskList对话框的任务列表")
		-- table.print(taskList, "CDialogueOptionView.InitOptionGrid taskList")
		--table.print(strList, "CDialogueOptionView.InitOptionGrid strList")
		--有二级菜单字段，隐藏有关任务的按钮
		if self.m_NpcSayData.lv2 and self.m_NpcSayData.lv2 ~= 0 then
			self.m_TaskList = {}
			taskList = {}
			self.m_IsTaskHide = true
		else
			self.m_IsTaskHide = false
		end

		--对话框的按钮的数量，任务的加上服务端控制显示的再加上本地客户端读取全局npc配置显示的
		local globalNpcConfigMenu = {}
		local globalNpcConfigMenuBack = {}
		local findnpc = g_MapCtrl:GetNpc(self.m_NpcSayData.npcid)
		if findnpc and data.npcdata.NPC.GLOBAL_NPC[findnpc.m_NpcAoi.npctype] then
			for k,v in ipairs(data.npcdata.NPC.GLOBAL_NPC[findnpc.m_NpcAoi.npctype].menu_options) do
				if data.npcdata.MENUOPTION[v].pos ~= 0 then
					table.insert(globalNpcConfigMenuBack, v)
				else
					table.insert(globalNpcConfigMenu, v)
				end
			end
		end
		self.m_GlobalMenuOptionList = globalNpcConfigMenu
		self.m_GlobalMenuOptionBackList = globalNpcConfigMenuBack
		if self.m_IsTaskHide then
			globalNpcConfigMenu = {}
			globalNpcConfigMenuBack = {}
			self.m_GlobalMenuOptionList = {}
			--只是处理顺序问题
			self.m_GlobalMenuOptionBackList = {}
		end

		if not self.m_IsNotShowBtn then
			local optionCount = #taskList + #strList + (not next(globalNpcConfigMenu) and {0} or {#globalNpcConfigMenu})[1] 
			+ (not next(globalNpcConfigMenuBack) and {0} or {#globalNpcConfigMenuBack})[1]
			if optionCount > 0 then
				for i=1,optionCount do
					local oOptionBtn = nil
					if i > #btnGridList then
						oOptionBtn = self.m_CloneOptionBtn:Clone(false)
						self.m_OptionGrid:AddChild(oOptionBtn)
					else
						oOptionBtn = btnGridList[i]
					end					
					local optionName = ""
					if i >=1 and i <= #taskList then
						local oTask = taskList[i]
						local taskName = oTask:GetSValueByKey("name")
						if oTask:GetCValueByKey("type") == 4 then
							local splitSta = string.find(taskName, "%(")
							local splitstrList = string.split(taskName, splitSta and '%(' or '%（')
							optionName = oTask.m_TaskType.name .. "-" .. splitstrList[1]
						else
							optionName = oTask.m_TaskType.name .. "-" .. taskName
						end
					elseif i > #taskList and i <= #taskList + #globalNpcConfigMenu then					
						local MenuConfig = data.npcdata.MENUOPTION[globalNpcConfigMenu[i - (#taskList)]]
						optionName = (MenuConfig and {MenuConfig.text} or {""})[1]
					elseif i > #taskList + #globalNpcConfigMenu and i <= #taskList + #globalNpcConfigMenu + #strList then
						optionName = strList[i - (#taskList + #globalNpcConfigMenu)]
					elseif i > #taskList + #globalNpcConfigMenu + #strList then
						local MenuConfig = data.npcdata.MENUOPTION[globalNpcConfigMenuBack[i - (#taskList + #globalNpcConfigMenu + #strList)]]
						optionName = (MenuConfig and {MenuConfig.text} or {""})[1]
					end
					if string.find(optionName, "#grey") then
						-- oOptionBtn:SetEnabled(false)
						oOptionBtn:SetBtnGrey(true)
						optionName = string.gsub(optionName, "#grey", "")
					else
						oOptionBtn:SetEnabled(true)
						oOptionBtn:SetBtnGrey(false)
					end
					oOptionBtn:SetText(optionName)
					oOptionBtn:SetActive(true)

					--处理引导任务
					self.m_GuideStr = ""
					oOptionBtn:DelEffect("FingerInterval")
					if findnpc and findnpc.m_NpcAoi.npctype == define.Npc.Type.ZhongKui and optionName == "便捷组队" then
						if g_TaskCtrl:CheckGhostFirstStepFit() then
							self.m_GuideStr = "ghostguide"
							oOptionBtn:AddEffect("FingerInterval", 1)
						end
					elseif findnpc and findnpc.m_NpcAoi.npctype == define.Npc.Type.YanNanGui and optionName == "便捷组队" then
						if g_TaskCtrl:CheckFubenFirstStepFit() then
							self.m_GuideStr = "fubenguide"
							oOptionBtn:AddEffect("FingerInterval", 1)
						end
					end
					oOptionBtn:AddUIEvent("click", callback(self, "OnOptionBtn", i, self.m_GuideStr))
				end

				if #btnGridList > optionCount then
					for i=optionCount+1,#btnGridList do
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
	end
	self.m_ContentScrollView:ResetPosition()
end

--设置可接任务的确定领取的界面
function CDialogueOptionView.SetAceSubMenuUI(self, taskid, npcid)	
	local btnGridList = self.m_OptionGrid:GetChildList() or {}

	local btnOptionList = {"确定", "取消"}
	for i,v in ipairs(btnOptionList) do
		local oBtn = nil
		if i > #btnGridList then
			oBtn = self.m_CloneOptionBtn:Clone()
			self.m_OptionGrid:AddChild(oBtn)
		else
			oBtn = btnGridList[i]
		end

		if i == 1 then
			oBtn:AddUIEvent("click", callback(self, "OnClickAceGetConfirm", taskid, npcid))
		elseif i == 2 then
			oBtn:AddUIEvent("click", callback(self, "OnClickAceGetCancel"))
		end
		oBtn:SetText(v)
		oBtn:SetActive(true)
	end

	for i=#btnOptionList+1,#btnGridList do
		btnGridList[i]:SetActive(false)
	end
	self.m_OptionGrid:Reposition()
	self.m_OptionScrollView:ResetPosition()
end

-------------倒计时自动执行---------------

function CDialogueOptionView.AutoClick(self, pbdata)
	if pbdata.time ~= 0 then
		self:SetClickCountTime(pbdata)
	end
end

function CDialogueOptionView.SetClickCountTime(self, pbdata)	
	self:ResetClickCountTimer()
	local function progress()
		if Utils.IsNil(self) then
			return false
		end
		if pbdata.default ~= 0 then
			self:OnOptionBtn(pbdata.default)
		end
		return false
	end
	self.m_ClickCountTimer = Utils.AddTimer(progress, 0, pbdata.time)
end

function CDialogueOptionView.ResetClickCountTimer(self)
	if self.m_ClickCountTimer then
		Utils.DelTimer(self.m_ClickCountTimer)
		self.m_ClickCountTimer = nil			
	end
end

---------------点击事件---------------------

--点击确认领取可接任务
function CDialogueOptionView.OnClickAceGetConfirm(self, taskid, npcid)
	nettask.C2GSAcceptTask(taskid, npcid)
	self:CloseView()
end

--点击取消领取可接任务
function CDialogueOptionView.OnClickAceGetCancel(self)
	self:InitOptionGrid()
end

--点击npc对话框里面的按钮
function CDialogueOptionView.OnOptionBtn(self, answer, oGuideStr)
	g_DialogueCtrl.m_IsClickOptionBtn = true
	local bClose = true
	if answer >= 1 and answer <= #self.m_TaskList then
		local task = self.m_TaskList[answer]
		if task and not task:GetIsAceTask() then
			local taskid = task:GetSValueByKey("taskid")
			nettask.C2GSTaskEvent(taskid, self.m_NpcSayData.npcid)
		elseif task and task:GetIsAceTask() then
			local npcid = g_MapCtrl:GetNpcByType(task:GetSValueByKey("target")).m_NpcAoi.npcid
			-- nettask.C2GSAcceptTask(task:GetSValueByKey("taskid"), npcid)
			self:SetAceSubMenuUI(task:GetSValueByKey("taskid"), npcid)
			bClose = false
		end
	elseif answer > #self.m_TaskList and answer <= #self.m_TaskList + #self.m_GlobalMenuOptionList then
		local idx = answer - (#self.m_TaskList)
		bClose = self:OnClickGlobalNpcMenuConfigOption(data.npcdata.MENUOPTION[self.m_GlobalMenuOptionList[idx]])
	elseif answer > #self.m_TaskList + #self.m_GlobalMenuOptionList and answer <= #self.m_TaskList + #self.m_GlobalMenuOptionList + #self.m_StrList then		
		local idx = answer - (#self.m_TaskList + #self.m_GlobalMenuOptionList)
		local npc = g_MapCtrl:GetNpc(self.m_NpcSayData.npcid)
		if npc and npc.m_NpcAoi.npctype == define.Npc.Type.Mojin then
			-- printc("CDialogueOptionView.OnOptionBtn define.Npc.Type.Mojin")
			if idx == 1 and self.m_IsTaskHide then
				netother.C2GSCallback(self.m_NpcSayData.sessionidx, idx)
				bClose = true
			elseif idx == 1 and not self.m_IsTaskHide then
				netother.C2GSCallback(self.m_NpcSayData.sessionidx, idx)
				bClose = false
			elseif idx == 2 then
				netother.C2GSCallback(self.m_NpcSayData.sessionidx, idx)
				bClose = true
			else
				netother.C2GSCallback(self.m_NpcSayData.sessionidx, idx)
				bClose = true
			end
		else
			netother.C2GSCallback(self.m_NpcSayData.sessionidx, idx)
		end
	elseif answer > #self.m_TaskList + #self.m_GlobalMenuOptionList + #self.m_StrList then
		local idx = answer - (#self.m_TaskList + #self.m_GlobalMenuOptionList + #self.m_StrList)
		bClose = self:OnClickGlobalNpcMenuConfigOption(data.npcdata.MENUOPTION[self.m_GlobalMenuOptionBackList[idx]])
	end

	if oGuideStr == "ghostguide" then
		g_TaskCtrl.m_GhostTaskGuide.first = true
	elseif oGuideStr == "fubenguide" then
		g_TaskCtrl.m_FubenTaskGuide.first = true
	end

	if bClose then
		self:CloseView()
	end
end

--点击全局npc里面的配置表的菜单按钮，序号请找npcdata的MENUOPTION查看
--以后要根据需求修改
function CDialogueOptionView.OnClickGlobalNpcMenuConfigOption(self, MenuConfig)
	local bClose = true
	if MenuConfig then
		--以后要根据配置添加修改
		--装备商店
		if MenuConfig.func_id == 1 then
			CNpcEquipShopView:ShowView()
		--打造
		elseif MenuConfig.func_id == 2 then
			CForgeMainView:ShowView(
				function(oView)
					oView:ShowSubPageByIndex(1)
				end
			)
		--摆摊
		elseif MenuConfig.func_id == 3 then
			CEcononmyMainView:ShowView(function (oView)
				oView:ShowSubPageByIndex(define.Econonmy.Type.Stall)
			end)
		--拍卖
		elseif MenuConfig.func_id == 4 then
			CEcononmyMainView:ShowView(function (oView)
				oView:ShowSubPageByIndex(define.Econonmy.Type.Auction)
			end)
		--擂台比武
		elseif MenuConfig.func_id == 5 then
			CArenaMainView:ShowView()
		--宝图任务（修改为:摸金寻龙）
		elseif MenuConfig.func_id == 6 then
			if g_OpenSysCtrl:GetOpenSysState(define.System.Baotu, true) then
				local taskTypeDic = g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.BAOTU.ID]
				local _, oTask = next(taskTypeDic)
				if oTask then
					-- CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.BAOTU.ID)
					g_NotifyCtrl:FloatMsg(data.textdata.TASK[1015].content)
				else
					nettask.C2GSAcceptBaotuTask()
				end
			end
		--系统杂货店
		elseif MenuConfig.func_id == 7 then
			--CNpcShopMainView:ShowView()
			CNpcGroceryShopView:ShowView()

		--擂主玩法说明
		elseif MenuConfig.func_id == 8 then
			-- local btnGridList = self.m_OptionGrid:GetChildList() or {}
			-- for i=1, #btnGridList do
			-- 	btnGridList[i]:SetActive(false)
			-- end
			-- self.m_NpcContentLabel:SetActive(true)
			-- self.m_NpcContentLabel:SetText("[63432c]" .. data.arenadata.TEXT[1014].content)
			local zId = define.Instruction.Config.Cultivation
			local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
			g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
			bClose = false
		--抓鬼说明
		elseif MenuConfig.func_id == 9 then
			local zId = define.Instruction.Config.Cultivation--Ghost
			local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
			g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
			bClose = false
		elseif MenuConfig.func_id == 10 then
			CNpcWeaponShopView:ShowView()
		--药店
		elseif MenuConfig.func_id == 11 then
			CNpcMedicineShopView:ShowView()
		elseif MenuConfig.func_id == 12 then
			--宠物商店
			CSummonStoreView:ShowView()
		elseif MenuConfig.func_id == 13 then
			CRecoveryItemView:ShowView()
			printc("装备回收")
			--装备回收
		elseif MenuConfig.func_id == 14 then
		  CRecoverySumView:ShowView()
		  printc("宠物回收")
		 -- 宠物回收
		elseif MenuConfig.func_id == 15 then
			local zId = define.Instruction.Config.Lingxi
			local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
			g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
			bClose = false
		elseif MenuConfig.func_id == 16 then
			nethuodong.C2GSLingxiClickAcceptTask()
		elseif MenuConfig.func_id == 17 then
			nethuodong.C2GSLingxiClickMatch()
		elseif MenuConfig.func_id == 18 then -- 玩家登陆的时候就会发送消息，这里只是打开界面
			--netsummon.C2GS ~~
			g_SummonCtrl:ShowCKView()
		-- 19 -22 神兽兑换相关
		elseif MenuConfig.func_id == 19 then
			g_SummonCtrl:ExchangeSpcSummon(5002)
		elseif MenuConfig.func_id == 20 then
			g_SummonCtrl:ExchangeSpcSummon(5001)
		elseif MenuConfig.func_id == 21 then
			g_SummonCtrl:ExchangeSpcSummon(5003)
		elseif MenuConfig.func_id == 22 then
			g_SummonCtrl:ExchangeSpcSummon(4002)
		elseif MenuConfig.func_id == 23 then
			g_ItemCtrl:TreasureMapCompound()
			bClose = false
		elseif MenuConfig.func_id == 24 then
			local instructionData = data.instructiondata.DESC[10047]
			if instructionData then
				local zContent = {title = instructionData.title,desc = instructionData.desc}
				g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
			else
				printc("未配置宝物兑换说明")
			end
			bClose = false
		elseif MenuConfig.func_id == 25 then
			if g_OpenSysCtrl:GetOpenSysState(define.System.Runring, true) then
				local taskTypeDic = g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.RUNRING.ID]
				local _, oTask = next(taskTypeDic)
				if oTask then
					CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.RUNRING.ID)
				else
					nettask.C2GSAcceptBaotuTask()
				end
			end
		elseif MenuConfig.func_id == 26 then
			if g_OpenSysCtrl:GetOpenSysState(define.System.XuanShang, true) then
				-- local taskTypeDic = g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.XUANSHANG.ID]
				-- local _, oTask = next(taskTypeDic)
				-- if oTask then
				-- 	CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.XUANSHANG.ID)
				-- else
				-- 	-- nettask.C2GSAcceptBaotuTask()
				-- end
				-- COfferRewardView:ShowView(function (oView)
				-- 	oView:RefreshUI()
				-- end)
				nettask.C2GSOpenXuanShangView()
			end
		elseif MenuConfig.func_id == 27 then
			local zId = define.Instruction.Config.Runring
			local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
			g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
			bClose = false
		elseif MenuConfig.func_id == 28 then
			g_SummonCtrl:ShowSummonAdvView(5002)
		elseif MenuConfig.func_id == 29 then
			g_SummonCtrl:ShowSummonAdvView(5001)
		elseif MenuConfig.func_id == 30 then
			g_SummonCtrl:ShowSummonAdvView(5003)
		elseif MenuConfig.func_id == 31 then
			g_TeamCtrl:TeamAutoMatch(2800)
		elseif MenuConfig.func_id == 32 then
			g_TeamCtrl:TeamAutoMatch(1200)
		elseif MenuConfig.func_id == 33 then
			g_SummonCtrl:ShowSummonAdvView(5004)
		elseif MenuConfig.func_id == 34 then
			g_SummonCtrl:ShowSummonAdvView(5005)
		elseif MenuConfig.func_id == 35 then
			g_SummonCtrl:ShowSummonAdvView(5006)
		elseif MenuConfig.func_id == 36 then
			g_SummonCtrl:ExchangeSpcSummon(5004)
		elseif MenuConfig.func_id == 37 then
			g_SummonCtrl:ExchangeSpcSummon(5005)
		elseif MenuConfig.func_id == 38 then
			g_SummonCtrl:ExchangeSpcSummon(5006)
		elseif MenuConfig.func_id == 42 then
			nettask.C2GSZhenmoOpenView()
		elseif MenuConfig.func_id == 43 then
			g_SummonCtrl:ShowSummonAdvView(4002)
		end
	end
	return bClose
end

function CDialogueOptionView.OnClickTips(self)
	if not self.m_GlobalNpcTipsId then
		return
	end
	local info = data.instructiondata.DESC[self.m_GlobalNpcTipsId]
    local zContent = {title = info.title,desc = info.desc}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

return CDialogueOptionView
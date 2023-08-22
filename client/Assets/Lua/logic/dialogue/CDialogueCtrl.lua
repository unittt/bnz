local CDialogueCtrl = class("CDialogueCtrl", CCtrlBase)

function CDialogueCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_NpcSayData = nil

	self.m_NpcDialogInfo = nil

	self.m_IsShopNpc = {
		[define.Npc.Type.XingJiaoShang] = true,
		[define.Npc.Type.XingJiaoShang2] = true,
		[define.Npc.Type.ChongWuXianZi] = true,
		[define.Npc.Type.SuXiaoXiao] = true,
		[define.Npc.Type.WangLaoShi] = true,
		[define.Npc.Type.YaoTuWeng] = true,
		[define.Npc.Type.JinWanCheng] = true,
		[define.Npc.Type.shuxiaoer] = true,
	}
end

function CDialogueCtrl.GS2CNpcSay(self, pbdata)
	if pbdata then
		self.m_NpcSayData = pbdata

		--显示任务分支界面
		if pbdata.type and pbdata.type == 2 then
			CTaskStorySelectView:ShowView(function (oView)
				oView:RefreshUI(pbdata)
			end)
			return
		end

		--处理点击主界面的任务框或者是任务界面的执行任务按钮时直接执行该任务
		if CTaskHelp.GetClickTaskExecute() and g_TaskCtrl.m_ClickTaskAutoFindData 
		and g_TaskCtrl.m_ClickTaskAutoFindData.npcid == self.m_NpcSayData.npcid then
			-- table.print(CTaskHelp.GetClickTaskExecute(), "CTaskHelp.GetClickTaskExecute")
			local task = CTaskHelp.GetClickTaskExecute()
			CTaskHelp.SetClickTaskExecute(nil)
			
			--如果是杂货店、宠物商店、装备商店、武器商店、药店对应的npc如行脚商或宠物仙子有特殊逻辑
			--以后要根据需求增加，这里是处理每一个不同的商店对应的npc
			local npc = g_MapCtrl:GetNpc(self.m_NpcSayData.npcid)
			if npc and self.m_IsShopNpc[npc.m_NpcAoi.npctype] then
				if task:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM) then
					local oIsOpenShop = self:ExecuteOpenShop(task)
					if not oIsOpenShop then
						self:ExecuteDoTask(task)
					end
				elseif task:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON) then
					local oIsOpenShop = self:ExecuteOpenShop(task)
					if not oIsOpenShop then
						self:ExecuteDoTask(task)
					end
				else
					self:ExecuteDoTask(task)
				end
				return
			else
				self:ExecuteDoTask(task)
			end
			return
		else
			CTaskHelp.SetClickTaskExecute(nil)
			-- printc("CDialogueCtrl.GS2CNpcSay 没有CTaskHelp.GetClickTaskExecute")
		end
		
		self:ShowDialogueOptionView(pbdata)
	end
end

function CDialogueCtrl.ExecuteDoTask(self, oTask)
	if not self.m_NpcSayData then
		return
	end
	if self.m_NpcSayData.npcid and self.m_NpcSayData.npcid ~= 0 then
		if oTask and not oTask:GetIsAceTask() then					
			local taskid = oTask:GetSValueByKey("taskid")
			nettask.C2GSTaskEvent(taskid, self.m_NpcSayData.npcid)
			return
		elseif oTask and oTask:GetIsAceTask() then
			local npcid = g_MapCtrl:GetNpcByType(oTask:GetSValueByKey("target")).m_NpcAoi.npcid
			nettask.C2GSAcceptTask(oTask:GetSValueByKey("taskid"), npcid)
			return
		end
	end
end

function CDialogueCtrl.ShowDialogueOptionView(self, pbdata)
	--处理npc身上只有一个任务(且没有选项)时，有可能该任务在这个npc对话菜单里面不显示，直接执行该任务
	local taskList = {}
	local npcid = self.m_NpcSayData.npcid

	local isDynamicNpc = g_MapCtrl:GetDynamicNpc(npcid)
	if not isDynamicNpc then
		taskList = g_TaskCtrl:GetNpcAssociatedTaskList(npcid)
		--过滤不显示的任务
		--这个npc有寻物任务且未完成，或者是门派闯关不显示任务按钮，但是这个npc实际有这个任务
		for i=#taskList,1,-1 do
			local oTask = taskList[i]
			if --(oTask:AssociatedSubmit(npcid) and oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM) and not oTask.m_Finish) or
			   --(oTask:AssociatedSubmit(npcid) and oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON) and not oTask.m_Finish) or
			   --(oTask:AssociatedSubmit(npcid) and oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_PICK) and not oTask.m_Finish) or
			   oTask:IsTaskSpecityCategory(define.Task.TaskCategory.SCHOOLPASS) then
				table.remove(taskList, i)
			end
		end
	end

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

	-- 当有选项时，不直接请求，等待玩家自己操作
	if #taskList == 1 and not string.find(self.m_NpcSayData.text, "%&Q") and (#globalNpcConfigMenuBack + #globalNpcConfigMenu) <= 0 and npcid and npcid ~= 0 then
		local task = taskList[1]
		if task and not task:GetIsAceTask() then
			local taskid = task:GetSValueByKey("taskid")
			nettask.C2GSTaskEvent(taskid, self.m_NpcSayData.npcid)
			return
		elseif task and task:GetIsAceTask() then
			local npcid = g_MapCtrl:GetNpcByType(task:GetSValueByKey("target")).m_NpcAoi.npcid
			nettask.C2GSAcceptTask(task:GetSValueByKey("taskid"), npcid)
			return
		end
	end
	--火眼金睛特殊处理
	if self.m_NpcSayData.name == "火眼金睛使者" then
		g_MainMenuCtrl.m_NotShowTaskArea = true
	end
	CDialogueOptionView:ShowView(function (oView)
		self:OnEvent(define.Dialogue.Event.InitOption, pbdata)
		oView:AutoClick(pbdata)
	end)
end

function CDialogueCtrl.GS2CDialog(self, pbdata)
	if pbdata then
		self.m_NpcDialogInfo = pbdata
		CDialogueMainView:ShowView(function (oView)
			g_ViewCtrl:HideNotGroupOther(oView, {"CMainMenuView", "CNotifyView", "CMapFadeView"})
			--宝图任务自动执行
			local oTask = g_TaskCtrl.m_TaskDataDic[pbdata.taskid]
			if oTask and oTask:GetCValueByKey("type") == define.Task.TaskCategory.BAOTU.ID then
				oView:OnAutoClick(3)
			end
			if oTask and oTask:GetCValueByKey("type") == define.Task.TaskCategory.RUNRING.ID then
				g_MainMenuCtrl:ShowAllArea()
			end
			self:OnEvent(define.Dialogue.Event.Dialogue, pbdata)
		end)
	end
end

function CDialogueCtrl.GS2COpenBuySummon(self)
	if CTaskHelp.GetClickTaskExecute() then
		local oTask = CTaskHelp.GetClickTaskExecute()
		CTaskHelp.SetClickTaskExecute(nil)
		if oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON) then
			CSummonStoreView:ShowView()
		end
	end
end

function CDialogueCtrl.GetIsNpcShopItem(self, itemlist)
	for k,v in pairs(itemlist) do
		for g,h in pairs(data.shopdata.NPCSHOP) do
			if h.item_id == v then
				return h.shop_id
			end
		end
	end
end

function CDialogueCtrl.GetIsGuildItem(self, itemlist)
	for k,v in pairs(itemlist) do
		if data.guilddata.ITEM2GOOD[v] then
			return true
		end
	end
end

function CDialogueCtrl.GetIsStallItem(self, itemlist)
	for i,iItemId in ipairs(itemlist) do
		local iStallId = DataTools.ConvertItemIdToStallId(iItemId, 1)
		if data.stalldata.ITEMINFO[iStallId] then
			return true
		end
	end
end

function CDialogueCtrl.ExecuteOpenShop(self, task)
	if task:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM) then
		local tItemList = g_TaskCtrl:GetTaskNeedItemList(task, true)
		
		if tItemList and next(tItemList) then
			--默认跳转摆摊，如任务是商会物品则跳转商会
			local bIsStallItem = self:GetIsStallItem(tItemList)
			local bIsGuildItem = self:GetIsGuildItem(tItemList)
			local iTab = define.Econonmy.Type.Stall
			if bIsGuildItem then
				iTab = define.Econonmy.Type.Guild
			end
			if not bIsStallItem and not bIsGuildItem then
				local shopId = self:GetIsNpcShopItem(tItemList)
				if shopId then
					g_ShopCtrl:OpenShop(shopId)
				else 
					CNpcGroceryShopView:ShowView()
				end						
				return true
			else
				-- g_EcononmyCtrl:SetTaskItemList(task:GetSValueByKey("taskid"), iTab, tItemList)
				local oView = CEcononmyMainView:ShowView(function(oView)
					if iTab ~= 1 then
						oView:ShowSubPageByIndex(iTab)
					end
				end)
			end
			return true
		end
	elseif task:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_SUMMON) then		
		local tSumList = g_TaskCtrl:GetTaskNeedSumList(task, true)
		if tSumList and next(tSumList) then		
			CSummonStoreView:ShowView()
			return true
		end
	end
	return false
end

return CDialogueCtrl
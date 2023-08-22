local CYibaoCtrl = class("CYibaoCtrl", CCtrlBase)

function CYibaoCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_ClickSelfTask = nil
	self.m_ClickSelfBoxIdx = nil
	self.m_ClickOtherTask = nil
	self.m_ClickOtherBoxIdx = nil

	self.m_YibaoMyselfDoneInfo = {}
	self.m_YibaoMyselfDoingInfo = {}
	self.m_YibaoMyselfMainInfo = {}
	self.m_YibaoMyselfGatherTasks = {}
	self.m_YibaoMyselfGatherMax = 0
	self.m_YibaoStarHelpTime = {}
	self.m_YibaoItemHelpTime = {}
	self.m_StarTimer = {}
	self.m_ItemTimer = {}

	self.m_YibaoOtherOwner = nil
	self.m_YibaoOtherCreateDay = nil
	self.m_YibaoOtherDoneInfo = {}
	self.m_YibaoOtherDoingInfo = {}
	self.m_YibaoOtherMainInfo = {}
	self.m_YibaoOtherGatherTasks = {}

	self.m_YibaoOtherGiveHelpTaskid = nil
end

function CYibaoCtrl.Clear(self)
	self.m_OpenShopForHelpOtherYibaoCb = nil
end

function CYibaoCtrl.GS2COpenYibaoUI(self, pbdata)
	local mask = pbdata.mask
	local owner = pbdata.owner --面板属于哪个玩家(pid)
	local create_day = pbdata.create_day --异宝创建日期（上行时使用）
	local seek_gather_tasks = pbdata.seek_gather_tasks --异宝寻物的已用求助的任务id
	local seek_gather_max = pbdata.seek_gather_max --异宝寻物的最大求助次数
	local done_yibao_info = pbdata.done_yibao_info --已经完成的异宝任务信息(因为此任务已经删除，但要显示在UI)
	local doing_yibao_info = pbdata.doing_yibao_info --正在进行的异宝任务信息(因为这个面板可以显示其他玩家的任务状况，自己看自己则不需要此数据)
	local main_yibao_info = pbdata.main_yibao_info --主任务信息，主要是预览奖励

	if owner then
		if owner == g_AttrCtrl.pid then
			if done_yibao_info then
				self.m_YibaoMyselfDoneInfo = {}
				for k,v in pairs(done_yibao_info) do
					self.m_YibaoMyselfDoneInfo[k] = v
				end
			end
			if doing_yibao_info then
				self.m_YibaoMyselfDoingInfo = {}
				for k,v in pairs(doing_yibao_info) do
					self.m_YibaoMyselfDoingInfo[k] = v
				end
			end
			if main_yibao_info then
				self.m_YibaoMyselfMainInfo = {}
				for k,v in pairs(main_yibao_info) do
					self.m_YibaoMyselfMainInfo[k] = v
				end
			end
			if seek_gather_tasks then
				self.m_YibaoMyselfGatherTasks = {}
				for k,v in pairs(seek_gather_tasks) do
					self.m_YibaoMyselfGatherTasks[k] = v
				end
			end
			-- self.m_YibaoMyselfDoneInfo = (done_yibao_info and {done_yibao_info} or {self.m_YibaoMyselfDoneInfo})[1]
			-- self.m_YibaoMyselfDoingInfo = (doing_yibao_info and {doing_yibao_info} or {self.m_YibaoMyselfDoingInfo})[1]
			-- self.m_YibaoMyselfMainInfo = (main_yibao_info and {main_yibao_info} or {self.m_YibaoMyselfMainInfo})[1]
			-- self.m_YibaoMyselfGatherTasks = (seek_gather_tasks and {seek_gather_tasks} or {self.m_YibaoMyselfGatherTasks})[1]
			self.m_YibaoMyselfGatherMax = (seek_gather_max and {seek_gather_max} or {self.m_YibaoMyselfGatherMax})[1]
		else
			self.m_YibaoOtherOwner = owner
			if done_yibao_info then
				self.m_YibaoOtherDoneInfo = {}
				for k,v in pairs(done_yibao_info) do
					self.m_YibaoOtherDoneInfo[k] = v
				end
			end
			if doing_yibao_info then
				self.m_YibaoOtherDoingInfo = {}
				for k,v in pairs(doing_yibao_info) do
					self.m_YibaoOtherDoingInfo[k] = v
				end
			end
			if main_yibao_info then
				self.m_YibaoOtherMainInfo = {}
				for k,v in pairs(main_yibao_info) do
					self.m_YibaoOtherMainInfo[k] = v
				end
			end
			if seek_gather_tasks then
				self.m_YibaoOtherGatherTasks = {}
				for k,v in pairs(seek_gather_tasks) do
					self.m_YibaoOtherGatherTasks[k] = v
				end
			end
			-- self.m_YibaoOtherDoneInfo = (done_yibao_info and {done_yibao_info} or {self.m_YibaoOtherDoneInfo})[1]
			-- self.m_YibaoOtherDoingInfo = (doing_yibao_info and {doing_yibao_info} or {self.m_YibaoOtherDoingInfo})[1]
			-- self.m_YibaoOtherMainInfo = (main_yibao_info and {main_yibao_info} or {self.m_YibaoOtherMainInfo})[1]
			-- self.m_YibaoOtherGatherTasks = (seek_gather_tasks and {seek_gather_tasks} or {self.m_YibaoOtherGatherTasks})[1]
			self.m_YibaoOtherCreateDay = (create_day and {create_day} or {self.m_YibaoOtherCreateDay})[1]
		end

		local oView = CYibaoMainView:GetView()
		if oView then
			self:OnEvent(define.Yibao.Event.RefreshUI, pbdata)
		else
			CYibaoMainView:ShowView(function (oView)
				oView:SetContent(pbdata)
			end)
		end
	else
		printerror("CYibaoCtrl.GS2COpenYibaoUI 不存在owner")
	end
	table.print(pbdata, "CYibaoCtrl.GS2COpenYibaoUI")
end

function CYibaoCtrl.GS2CYibaoTaskDone(self, pbdata)
	local taskid = pbdata.taskid

	local yibaoInfo
	for k,v in pairs(self.m_YibaoMyselfDoingInfo) do
		if v.taskid == taskid then
			yibaoInfo = v
			table.remove(self.m_YibaoMyselfDoingInfo, k)
			break
		end
	end
	if yibaoInfo then
		for k,v in pairs(self.m_YibaoMyselfDoneInfo) do
			if v.taskid == taskid then
				table.remove(self.m_YibaoMyselfDoneInfo, k)
				break
			end
		end
		table.insert(self.m_YibaoMyselfDoneInfo, yibaoInfo)
	end
	--异宝还原
	if pbdata.is_gather_help == 0 then
		if g_TaskCtrl.m_TaskDataDic[g_TaskCtrl:GetYibaoMainTaskid().taskid] then
			CTaskHelp.ClickTaskLogic(g_TaskCtrl.m_TaskDataDic[g_TaskCtrl:GetYibaoMainTaskid().taskid])
		end
	end
	self:OnEvent(define.Yibao.Event.UpdateMyselfDoneYibao, pbdata)
	table.print(pbdata, "CYibaoCtrl.GS2CYibaoTaskDone")
end

function CYibaoCtrl.GS2CYibaoTaskRefresh(self, pbdata)
	local yibao_info = pbdata.yibao_info
	local doneindex = nil
	for k,v in pairs(self.m_YibaoMyselfDoneInfo) do
		if v.taskid == yibao_info.taskid then
			doneindex = k
			break
		end
	end
	if doneindex then
		table.remove(self.m_YibaoMyselfDoneInfo, doneindex)
		table.insert(self.m_YibaoMyselfDoneInfo, doneindex, yibao_info)
	end

	local doingindex = nil
	for k,v in pairs(self.m_YibaoMyselfDoingInfo) do
		if v.taskid == yibao_info.taskid then
			doingindex = k
			break
		end
	end
	if doingindex then
		table.remove(self.m_YibaoMyselfDoingInfo, doingindex)
		table.insert(self.m_YibaoMyselfDoingInfo, doingindex, yibao_info)
	end
	self:OnEvent(define.Yibao.Event.UpdateMyselfYibaoInfo, pbdata)
	table.print(pbdata, "CYibaoCtrl.GS2CYibaoTaskRefresh")
end

function CYibaoCtrl.GS2CYibaoSeekHelpSucc(self, pbdata)
	local taskid = pbdata.taskid

	local type = 4
	if g_YibaoCtrl:GetMyselfDoingInfoByTaskid(taskid) then
		type = g_YibaoCtrl:GetMyselfDoingInfoByTaskid(taskid).yibao_kind
	else
		type = g_YibaoCtrl:GetMyselfDoneInfoByTaskid(taskid).yibao_kind
	end

	-- local taskconfig = DataTools.GetTaskData(taskid)
	--2是刷星，3是寻物
	if type == 2 then
		g_YibaoCtrl.m_YibaoStarHelpTime[taskid] = define.Yibao.Time.StarHelp
		g_YibaoCtrl:SetStarHelpCountTime(taskid)
	elseif type == 3 then
		g_YibaoCtrl.m_YibaoItemHelpTime[taskid] = define.Yibao.Time.ItemHelp
		g_YibaoCtrl:SetItemHelpCountTime(taskid)

		if not table.index(self.m_YibaoMyselfGatherTasks, taskid) then
			table.insert(self.m_YibaoMyselfGatherTasks, taskid)
		end
	end
	self:OnEvent(define.Yibao.Event.UpdateMyselfYibaoInfo)
	table.print(pbdata, "CYibaoCtrl.GS2CYibaoSeekHelpSucc")
end

function CYibaoCtrl.GS2CPlayQte(self, pbdata)
	printc("开启qte互动CYibaoCtrl.GS2CPlayQte")
	local sessionidx = pbdata.sessionidx
	local qteid = pbdata.qteid
	local lasts = pbdata.lasts --区别与QTE表中的时间，为另外规定

	local function onPlayQte()
		g_NetCtrl:SetCacheProto("interaction", true)

		g_InteractionCtrl.m_InteractionResultType = define.Yibao.InteractionResultType.Yibao
		g_InteractionCtrl.m_InteractionSessionidx = sessionidx
		g_InteractionCtrl.m_InteractionQteid = qteid
		if pbdata.forthdone == 1 then
			g_InteractionCtrl.m_ForthDone = true
		end
		g_InteractionCtrl.m_InteractionTotalTime = ((lasts and lasts ~= 0) and {lasts} or {nil})[1]
		for k,v in pairs(data.interactiondata.QTEDATA) do
			if v.id == g_InteractionCtrl.m_InteractionQteid then
				g_InteractionCtrl.m_InteractionQteConfig = v
				break
			end
		end
		if not g_GuideCtrl:IsGuideDone() then
			g_GuideCtrl:AddEndCallbackList(function ()
				g_ViewCtrl:CloseAll(g_GuideCtrl.m_NotCloseViewList)
				CInteractionView:ShowView(function (oView)
					oView:SetContent()
				end)
			end)
		else
			g_InteractionCtrl.IsShowing = true
			g_ViewCtrl:CloseAll(g_GuideCtrl.m_NotCloseViewList)
			CInteractionView:ShowView(function (oView)
				oView:SetContent()
			end)
		end
	end

	if g_OpenSysCtrl.m_IsSysOpenShowing then		
		g_OpenSysCtrl:AddSysOpenShowCbList(function ()
			onPlayQte()
		end)
	else
		onPlayQte()
	end

	table.print(pbdata, "CYibaoCtrl.GS2CPlayQte")
end

function CYibaoCtrl.GetMyselfYibaoTaskData(self)
	local myselfData = {}
	for k,v in pairs(g_TaskCtrl.m_YiBaoDataDic) do
		if not self:GetMyselfDoneInfoByTaskid(v:GetSValueByKey("taskid")) then
			local list = {taskid = v:GetSValueByKey("taskid"), state = "notdone", data = v}
			table.insert(myselfData, list)
		end
	end
	for k,v in pairs(self.m_YibaoMyselfDoneInfo) do
		local list = {taskid = v.taskid, state = "done", data = v}
		table.insert(myselfData, list)
	end
	table.sort(myselfData, function (a, b)
		if a.state ~= b.state then
			local state1 = (a.state == "notdone" and 0 or 1)
			local state2 = (b.state == "notdone" and 0 or 1)
			return state1 < state2
		else
			if a.state == "notdone" then
				local itemEnough1 = 0
				local itemEnough2 = 0
				local oDoingData1 = g_YibaoCtrl:GetMyselfDoingInfoByTaskid(a.taskid)
				local oDoingData2 = g_YibaoCtrl:GetMyselfDoingInfoByTaskid(b.taskid)
				local type1 = oDoingData1 and oDoingData1.yibao_kind or 0
				local type2 = oDoingData2 and oDoingData2.yibao_kind or 0
				if type1 == 3 then
					if a.data then
						local needitem = a.data:GetSValueByKey("needitem")
						if g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid) >= needitem[1].amount then
							itemEnough1 = 1
						end
					end
				end
				if type2 == 3 then
					if b.data then
						local needitem = b.data:GetSValueByKey("needitem")
						if g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid) >= needitem[1].amount then
							itemEnough2 = 1
						end
					end
				end
				if itemEnough1 ~= itemEnough2 then
					return itemEnough1 > itemEnough2
				else
					return a.taskid < b.taskid
				end
			else
				return a.taskid < b.taskid
			end
		end
	end
	)
	return myselfData
end

function CYibaoCtrl.GetOtherYibaoTaskData(self)
	local otherData = {}
	for k,v in pairs(self.m_YibaoOtherDoneInfo) do
		local list = {taskid = v.taskid, state = "done", data = v}
		table.insert(otherData, list)
	end
	for k,v in pairs(self.m_YibaoOtherDoingInfo) do
		local list = {taskid = v.taskid, state = "notdone", data = v}
		table.insert(otherData, list)
	end
	table.sort(otherData, function (a, b) 
		if a.state ~= b.state then
			local state1 = (a.state == "notdone" and 0 or 1)
			local state2 = (b.state == "notdone" and 0 or 1)
			return state1 < state2
		else
			if a.state == "notdone" then
				local itemEnough1 = 0
				local itemEnough2 = 0
				local type1 = a.data.yibao_kind
				local type2 = b.data.yibao_kind
				if type1 == 3 then
					local needitem = a.data.needitem
					if g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid) >= needitem[1].amount then
						itemEnough1 = 1
					end
				end
				if type2 == 3 then
					local needitem = b.data.needitem
					if g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid) >= needitem[1].amount then
						itemEnough2 = 1
					end
				end
				if itemEnough1 ~= itemEnough2 then
					return itemEnough1 > itemEnough2
				else
					return a.taskid < b.taskid
				end
			else
				return a.taskid < b.taskid
			end
		end
	end
	)
	return otherData
end

function CYibaoCtrl.GetOtherYibaoTaskDataByTaskid(self, taskid)
	for k,v in ipairs(self:GetOtherYibaoTaskData()) do
		if v.taskid == taskid then
			return v
		end
	end
	return
end

function CYibaoCtrl.GetMyselfDoingInfoByTaskid(self, taskid)
	for k,v in pairs(self.m_YibaoMyselfDoingInfo) do
		if v.taskid == taskid then
			return v
		end
	end
end

function CYibaoCtrl.GetMyselfDoneInfoByTaskid(self, taskid)
	for k,v in pairs(self.m_YibaoMyselfDoneInfo) do
		if v.taskid == taskid then
			return v
		end
	end
end

function CYibaoCtrl.GetSubYibaoTaskPrizeConfig(self, prizeid)
	for k,v in pairs(define.Yibao.Prize) do
		if prizeid == v[1] then
			return v
		end
	end
end

function CYibaoCtrl.SetStarHelpCountTime(self, taskid)
	if g_YibaoCtrl.m_YibaoStarHelpTime[taskid] and g_YibaoCtrl.m_YibaoStarHelpTime[taskid] > 0 then
		self:ResetStarTimer(taskid)
		local function progress()
			g_YibaoCtrl.m_YibaoStarHelpTime[taskid] = g_YibaoCtrl.m_YibaoStarHelpTime[taskid] - 1
			
			self:OnEvent(define.Yibao.Event.StarTime, taskid)
			
			if g_YibaoCtrl.m_YibaoStarHelpTime[taskid] <= 0 then
				g_YibaoCtrl.m_YibaoStarHelpTime[taskid] = 0
				self:OnEvent(define.Yibao.Event.StarTime, taskid)
				return false
			end
			return true
		end
		g_YibaoCtrl.m_YibaoStarHelpTime[taskid] = g_YibaoCtrl.m_YibaoStarHelpTime[taskid] + 1
		self.m_StarTimer[taskid] = Utils.AddTimer(progress, 1, 0)
	else
		self:OnEvent(define.Yibao.Event.StarTime, taskid)
	end
end

function CYibaoCtrl.ResetStarTimer(self, taskid)
	if self.m_StarTimer[taskid] then
		Utils.DelTimer(self.m_StarTimer[taskid])
		self.m_StarTimer[taskid] = nil			
	end
end

function CYibaoCtrl.SetItemHelpCountTime(self, taskid)	
	if g_YibaoCtrl.m_YibaoItemHelpTime[taskid] and g_YibaoCtrl.m_YibaoItemHelpTime[taskid] > 0 then
		self:ResetItemTimer(taskid)
		local function progress()
			g_YibaoCtrl.m_YibaoItemHelpTime[taskid] = g_YibaoCtrl.m_YibaoItemHelpTime[taskid] - 1

			self:OnEvent(define.Yibao.Event.ItemTime, taskid)
			
			if g_YibaoCtrl.m_YibaoItemHelpTime[taskid] <= 0 then
				g_YibaoCtrl.m_YibaoItemHelpTime[taskid] = 0

				self:OnEvent(define.Yibao.Event.ItemTime, taskid)
				return false
			end
			return true
		end
		g_YibaoCtrl.m_YibaoItemHelpTime[taskid] = g_YibaoCtrl.m_YibaoItemHelpTime[taskid] + 1
		self.m_ItemTimer[taskid] = Utils.AddTimer(progress, 1, 0)
	else
		self:OnEvent(define.Yibao.Event.ItemTime, taskid)
	end
end

function CYibaoCtrl.ResetItemTimer(self, taskid)
	if self.m_ItemTimer[taskid] then
		Utils.DelTimer(self.m_ItemTimer[taskid])
		self.m_ItemTimer[taskid] = nil			
	end
end

return CYibaoCtrl
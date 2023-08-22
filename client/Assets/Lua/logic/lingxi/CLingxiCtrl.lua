local CLingxiCtrl = class("CLingxiCtrl", CCtrlBase)

function CLingxiCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_Taskid = nil
	self.m_Phase = 0
	self.m_TaskItemData = nil
	self.m_IsCloseToFlowerSend = false
	self.m_AnswerCountTime = 0
	self.m_HasAnswerList = {}
	self.m_IsLeaderReachSend = false
	self.m_IsInLingxi = false
	self.m_IsInLingxiSeedArea = false
	self.m_IsInLingxiPoetry = false
	self.m_PoetryEndCbList = {}
end

function CLingxiCtrl.Clear(self)
	self.m_HasAnswerList = {}
	self.m_IsLingxiMatching = false
	self.m_IsLeaderReachSend = false
	self.m_IsCloseToFlowerSend = false
	self.m_IsInLingxi = false
	self.m_IsInLingxiSeedArea = false
	self.m_TotalCnt = nil
	self.m_DoneCnt = nil
	self.m_IsInLingxiPoetry = false
	self.m_PoetryEndCbList = {}
end

function CLingxiCtrl.AddPoetryCbList(self, cb)
	table.insert(self.m_PoetryEndCbList, cb)
end

function CLingxiCtrl.GS2CLingxiMatching(self, pbdata)
	self.m_IsLingxiMatching = true	
	if g_TeamCtrl:IsPlayerAutoMatch() then
		netteam.C2GSPlayerCancelAutoMatch()
	end
	--显示主界面组队栏
	if g_DialogueCtrl.m_IsClickOptionBtn then
		local oView = CMainMenuView:GetView()
		if oView then
			oView.m_RT.m_ExpandBox:ShowTeamPart()
		end
		g_DialogueCtrl.m_IsClickOptionBtn = false
	end
	self:OnEvent(define.Lingxi.Event.Match)
	table.print(pbdata, "CLingxiCtrl.GS2CLingxiMatching")
end

function CLingxiCtrl.GS2CLingxiMatchEnd(self, pbdata)
	self.m_IsLingxiMatching = false
	self:OnEvent(define.Lingxi.Event.Match)
	table.print(pbdata, "CLingxiCtrl.GS2CLingxiMatchEnd")
end

--phase阶段1.队长前往 2.队员前往集合 3.种植(使用种子) 4.成长(qte) 5.采摘
function CLingxiCtrl.GS2CLingxiInfo(self, pbdata)
	if pbdata.taskid then
		self.m_Taskid = pbdata.taskid
	end
	if pbdata.phase then
		self.m_Phase = pbdata.phase
		if self.m_Phase == 1 then
			self.m_TotalCnt = nil
			self.m_DoneCnt = nil
			self.m_IsLeaderReachSend = true
			if g_TeamCtrl:IsLeader() then
				local oTask = g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid]
				local oItemData = oTask:GetSValueByKey("taskitem")[1]
				local oMapInfo = DataTools.GetSceneDataByMapId(oItemData.map_id)
				local windowConfirmInfo = {
					msg				= "[63432C]请点击任务栏前往"..string.format(define.Task.AceTaskColor.Map, oMapInfo.scene_name.."("..
					math.floor(oItemData.pos_x)..","..math.floor(oItemData.pos_y)..")").."，情花种植点",
					thirdStr		= "确定",
					closeType		= 1,
					style 			= CWindowComfirmView.Style.Single,
					color 			= Color.white,
				}
				g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
			else
				local windowConfirmInfo = {
					msg				= "等待队长寻找合适的情花种植点",
					thirdStr		= "确定",
					closeType		= 1,
					style 			= CWindowComfirmView.Style.Single,
				}
				g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
			end
		end
		if self.m_Phase == 2 then
			self.m_IsLeaderReachSend = true
		end
		if self.m_Phase == 4 then
			self.m_IsCloseToFlowerSend = true
		end
		g_LingxiCtrl.m_IsFloatDesc = true
		if self.m_Phase == 4 then
			g_LingxiCtrl.m_IsFloatDesc = false
		end
		g_TaskCtrl:RefreshSpecityBoxUI({task = g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid]})
	end
	table.print(pbdata, "CLingxiCtrl.GS2CLingxiInfo")
end

function CLingxiCtrl.GS2CLingxiUseSeed(self, pbdata)
	self.m_Taskid = pbdata.taskid
	self.m_TaskItemData = pbdata.seed_item

	g_ItemCtrl:AddQuickUseData(self.m_TaskItemData, nil, nil, true)
	table.print(pbdata, "CLingxiCtrl.GS2CLingxiUseSeed")
end

function CLingxiCtrl.GS2CCloseProgressBar(self, pbdata)
	g_NotifyCtrl:CancelProgress()
end

function CLingxiCtrl.GS2CShowProgressBar(self, pbdata)
	local cancelFunc = nil

	if pbdata.modal == 1 then
		cancelFunc = nil
		local oView = CNotifyView:GetView()
		if oView then
			oView.m_ProgressBar.m_BoxCollider:SetActive(true)
		end
	else
		if pbdata.uninterruptable == 1 then
			local oView = CNotifyView:GetView()
			if oView then
				oView.m_ProgressBar.m_BoxCollider:SetActive(false)
			end
		else
			cancelFunc = function ()
				netother.C2GSCallback(pbdata.sessionidx, 0)
				g_NotifyCtrl:CancelProgress()
			end
			local oView = CNotifyView:GetView()
			if oView then
				oView.m_ProgressBar.m_BoxCollider:SetActive(true)
			end
		end
	end
	g_NotifyCtrl:ShowProgress(function ()
		netother.C2GSCallback(pbdata.sessionidx, 1)
	end, pbdata.msg, pbdata.sec, pbdata.start_sec, cancelFunc, pbdata.pos)
end

function CLingxiCtrl.GS2CLingxiShowFlowerUsePos(self, pbdata)
	local windowConfirmInfo = {
		msg = "此地点无法使用",
		title = "提示",
		okCallback = function () CLingxiPointView:ShowView() end,	
		okStr = "查看使用地",
		cancelStr = "确定",
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CLingxiCtrl.GS2CLingxiShowFlowerPoem(self, pbdata)
	CLingxiPoetryView:CloseView()
	CLingxiPoetryView:ShowView(function (oView)
		oView:RefreshUI(pbdata)
	end)
	g_LingxiCtrl.m_IsInLingxiPoetry = true
end

function CLingxiCtrl.GS2CLingxiQuestion(self, pbdata)
	self.m_HasAnswerList = {}
	if pbdata.my_answer ~= 0 then
		self.m_HasAnswerList[pbdata.round] = true
	end
	CLingxiAnswerView:ShowView(function (oView)
		oView:RefreshUI(pbdata)
	end)
end

function CLingxiCtrl.GS2CLingxiQuestionClose(self, pbdata)
	CLingxiAnswerView:CloseView()
end

function CLingxiCtrl.GS2CLingxiQuestionAnswered(self, pbdata)
	if pbdata.my_answer ~= 0 then
		self.m_HasAnswerList[pbdata.round] = true
	end
end

function CLingxiCtrl.GS2CLingxiQteCnt(self, pbdata)
	g_LingxiCtrl.m_TotalCnt = pbdata.total_cnt
	g_LingxiCtrl.m_DoneCnt = pbdata.done_cnt
	g_LingxiCtrl.m_IsFloatDesc = true
	g_TaskCtrl:RefreshSpecityBoxUI({task = g_TaskCtrl.m_TaskDataDic[g_LingxiCtrl.m_Taskid]})
	table.print(pbdata, "CLingxiCtrl.GS2CLingxiQteCnt")
end

----------------以下是管理数据-----------------

--获取灵犀任务配置
function CLingxiCtrl.GetLingxiTaskConfig(self)
	return next(data.taskdata.TASK.LINGXI.TASK)
end

function CLingxiCtrl.GetLingxiTaskId(self)
	return 62031
end

function CLingxiCtrl.GetPutSeedPos(self, posX, posY)
	if not self.m_TaskItemData then
		return posX, posY
	else
		local setPosX = posX + 1000
		local setPosY = posY + 1000
		--self.m_TaskItemData.radius
		local rangeX = {(self.m_TaskItemData.pos_x - 1)*1000, (self.m_TaskItemData.pos_x + 1)*1000}
		local rangeY = {(self.m_TaskItemData.pos_y - 1)*1000, (self.m_TaskItemData.pos_y + 1)*1000}
		if setPosX > rangeX[2] then
			setPosX = rangeX[2]
		elseif setPosX < rangeX[1] then
			setPosX = rangeX[1]
		end
		if setPosY > rangeY[2] then
			setPosY = rangeY[2]
		elseif setPosY < rangeY[1] then
			setPosY = rangeY[1]
		end
		return setPosX, setPosY
	end
end

--答题的倒计时
function CLingxiCtrl.SetAnswerCountTime(self, oTime)
	if oTime <= 0 then
		return
	end
	self:ResetAnswerCountTimer()
	local function progress()
		g_LingxiCtrl.m_AnswerCountTime = g_LingxiCtrl.m_AnswerCountTime - 1
		self:OnEvent(define.Lingxi.Event.AnswerCount)
		if g_LingxiCtrl.m_AnswerCountTime <= 0 then
			g_LingxiCtrl.m_AnswerCountTime = 0
			self:OnEvent(define.Lingxi.Event.AnswerCount)
			return false
		end
		return true
	end
	g_LingxiCtrl.m_AnswerCountTime = oTime + 1
	self.m_AnswerCountTimer = Utils.AddTimer(progress, 1, 0)
end

function CLingxiCtrl.ResetAnswerCountTimer(self)
	if self.m_AnswerCountTimer then
		Utils.DelTimer(self.m_AnswerCountTimer)
		self.m_AnswerCountTimer = nil			
	end
end

function CLingxiCtrl.GetMemberPlayer(self)
	--队员数据		
	local oMemberData
	for k,v in pairs(g_TeamCtrl:GetMemberList()) do
		if v.pid ~= g_AttrCtrl.pid then
			oMemberData = v
			break
		end
	end
	local oMember = g_MapCtrl:GetPlayer(oMemberData.pid)
	return oMember
end

return CLingxiCtrl
local CInteractionCtrl = class("CInteractionCtrl", CCtrlBase)

function CInteractionCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_YibaoInteractionTime = 0
	self.m_YibaoInteractionSetTime = 0
	self.m_YibaoInteractionTouchTime = 0
	self.m_YibaoInteractionLightTime = 0
	self.m_YibaoInteractionFailTime = 0
	self.m_YibaoInteractionResult = 2
	self.m_YibaoInteractionFailReserveTime = 0
	self.m_YibaoInteractionFlowerFailTime = 0
	self.m_YibaoInteractionCrystalOreFailTime = 0

	self.m_YibaoInteractionLightSetTime = nil

	self.m_InteractionSessionidx = 0
	self.m_InteractionTaskData = {}
	self.m_InteractionQteid = 0
	self.m_InteractionTotalTime = nil
	self.m_InteractionQteConfig = nil
	self.m_InteractionResultType = 1

	self.m_InteractionEndCbList = {}
end

function CInteractionCtrl.Clear(self)
	self.IsShowing = false	
	self.m_InteractionEndCbList = {}
end

function CInteractionCtrl.AddInteractionCbList(self, cb)
	table.insert(self.m_InteractionEndCbList, cb)
end

--互动任务拖动的计时
function CInteractionCtrl.SetInteractionTouchTime(self)	
	self:ResetInteractionTouchTimer()
	local function progress()
		g_InteractionCtrl.m_YibaoInteractionTouchTime = g_InteractionCtrl.m_YibaoInteractionTouchTime + 0.1
		
		return true
	end
	g_InteractionCtrl.m_YibaoInteractionTouchTime = -0.1
	self.m_InteractionTouchTimer = Utils.AddTimer(progress, 0.1, 0)
end

function CInteractionCtrl.ResetInteractionTouchTimer(self)
	if self.m_InteractionTouchTimer then
		Utils.DelTimer(self.m_InteractionTouchTimer)
		self.m_InteractionTouchTimer = nil			
	end
end

--互动任务的总计时
function CInteractionCtrl.SetInteractionCountTime(self)	
	self:ResetInteractionTimer()
	local function progress()
		g_InteractionCtrl.m_YibaoInteractionTime = g_InteractionCtrl.m_YibaoInteractionTime - 0.05

		self:OnEvent(define.Yibao.Event.InteractionTime)
		
		if g_InteractionCtrl.m_YibaoInteractionTime <= 0 then
			g_InteractionCtrl.m_YibaoInteractionTime = 0

			self:OnEvent(define.Yibao.Event.InteractionTime)

			--互动任务拖动的计时停止
			g_InteractionCtrl:ResetInteractionTouchTimer()
			g_InteractionCtrl.m_YibaoInteractionTouchTime = 0

			local oFloatMsg = ""

			if g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPoint then
				oFloatMsg = "连线失败了哦"
				--连线类型的互动任务失败后的自动播放特效计时
				self:SetInteractionFailCountTime(3)
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkFlower then
				oFloatMsg = "收割鲜花失败了哦"
				--鲜花类型的互动任务失败后的自动播放特效计时
				self:SetInteractionFailCountTime(3)
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkCrystalOre then
				oFloatMsg = "收集晶石失败了哦"
				self:SetInteractionCrystalOreFailCountTime()
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkAnyPattern then
				oFloatMsg = "绘制咒文失败了哦"
				self:SetInteractionFailCountTime(3)
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkLove then
				oFloatMsg = "绘制爱心失败了哦"
				self:SetInteractionFailCountTime(3)
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkPicture then
				oFloatMsg = "污渍擦除失败了哦"
				self:SetInteractionFailCountTime(3)
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkDog then
				oFloatMsg = "救狗失败了哦"
				self:SetInteractionFailCountTime(3)
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkBall then
				oFloatMsg = "灵魂球收集失败了哦"
				self:SetInteractionFailCountTime(3)
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkBell then
				oFloatMsg = "摇铃失败了哦"
				self:SetInteractionFailCountTime(3)
			elseif g_InteractionCtrl.m_InteractionQteConfig.type == define.Yibao.InteractionType.LinkHerb then
				oFloatMsg = "采集失败了哦"
				self:SetInteractionFailCountTime(3)
			end
			if not g_InteractionCtrl.m_ForthDone then
				g_NotifyCtrl:FloatMsg(oFloatMsg)
			end

			return false
		end
		return true
	end
	g_InteractionCtrl.m_YibaoInteractionTime = self.m_YibaoInteractionSetTime + 0.05
	self.m_InteractionTimer = Utils.AddTimer(progress, 0.05, 0)
end

function CInteractionCtrl.ResetInteractionTimer(self)
	if self.m_InteractionTimer then
		Utils.DelTimer(self.m_InteractionTimer)
		self.m_InteractionTimer = nil			
	end
end

--互动任务成功后的亮光特效计时
function CInteractionCtrl.SetInteractionLightCountTime(self)	
	self:ResetInteractionLightTimer()
	local function progress()
		g_InteractionCtrl.m_YibaoInteractionLightTime = g_InteractionCtrl.m_YibaoInteractionLightTime - 1

		self:OnEvent(define.Yibao.Event.InteractionLightTime)
		
		if g_InteractionCtrl.m_YibaoInteractionLightTime <= 0 then
			g_InteractionCtrl.m_YibaoInteractionLightTime = 0

			self:OnEvent(define.Yibao.Event.InteractionLightTime)

			--互动成功 m_YibaoInteractionResult 2是失败 1是成功
			-- if self.m_InteractionResultType == define.Yibao.InteractionResultType.Yibao then
				
			if self.m_InteractionResultType == define.Yibao.InteractionResultType.Shimen then
				if self.m_YibaoInteractionResult == 1 then
					local isItemPick = self.m_InteractionTaskData:IsTaskSpecityAction(define.Task.TaskType.TASK_ITEM_PICK)
					if isItemPick then
						-- 清除PickModel
						g_TaskCtrl:DoCheckPickModel(self.m_InteractionTaskData, false)
					end

					local step = self.m_InteractionTaskData:GetStep()
					local taskid = self.m_InteractionTaskData:GetSValueByKey("taskid")
					self.m_InteractionTaskData:RaiseProgressIdx()
					nettask.C2GSStepTask(taskid, step)
					if step == 0 then
						self.m_InteractionTaskData.m_Finish = true
					else
						-- 刷新面板\重新生成PickModel
						g_TaskCtrl:RefreshSpecityBoxUI({task = self.m_InteractionTaskData})
						g_TaskCtrl:DoCheckPickModel(self.m_InteractionTaskData, true)
						g_TaskCtrl:RefreshPickItem()
					end
				end
			elseif self.m_InteractionResultType == define.Yibao.InteractionResultType.GetBell then
				if g_InteractionCtrl.m_InteractionResultFunc then
					g_InteractionCtrl.m_InteractionResultFunc()
					g_InteractionCtrl.m_InteractionResultFunc = nil
				end
			else
				if self.m_YibaoInteractionResult == 1 then
					--发送互动成功协议
					netother.C2GSCallback(self.m_InteractionSessionidx, 1)
				end
			end

			return false
		end
		return true
	end
	g_InteractionCtrl.m_YibaoInteractionLightTime = self.m_YibaoInteractionLightSetTime and self.m_YibaoInteractionLightSetTime or 3
	self.m_InteractionLightTimer = Utils.AddTimer(progress, 1, 0)
end

function CInteractionCtrl.ResetInteractionLightTimer(self)
	if self.m_InteractionLightTimer then
		Utils.DelTimer(self.m_InteractionLightTimer)
		self.m_InteractionLightTimer = nil			
	end
end

--连线类型的互动任务失败后的自动播放特效计时
function CInteractionCtrl.SetInteractionFailCountTime(self, setTime)	
	self:ResetInteractionFailTimer()
	local function progress()
		g_InteractionCtrl.m_YibaoInteractionFailTime = g_InteractionCtrl.m_YibaoInteractionFailTime - 0.1
		g_InteractionCtrl.m_YibaoInteractionFailReserveTime = g_InteractionCtrl.m_YibaoInteractionFailReserveTime + 0.1

		self:OnEvent(define.Yibao.Event.InteractionFailTime, g_InteractionCtrl.m_YibaoInteractionFailReserveTime)
		
		if g_InteractionCtrl.m_YibaoInteractionFailTime <= 0 then
			g_InteractionCtrl.m_YibaoInteractionFailTime = 0

			self:OnEvent(define.Yibao.Event.InteractionFailTime, 0)

			--互动失败 m_YibaoInteractionResult 2是失败 1是成功
			if self.m_InteractionResultType == define.Yibao.InteractionResultType.GetBell then
				if g_InteractionCtrl.m_InteractionResultFunc then
					g_InteractionCtrl.m_InteractionResultFunc()
					g_InteractionCtrl.m_InteractionResultFunc = nil
				end
			else
				if self.m_YibaoInteractionResult == 2 then
					--发送互动失败协议
					netother.C2GSCallback(self.m_InteractionSessionidx, 2)
				end
			end

			return false
		end
		return true
	end
	g_InteractionCtrl.m_YibaoInteractionFailTime = setTime
	g_InteractionCtrl.m_YibaoInteractionFailReserveTime = -0.1
	self.m_InteractionFailTimer = Utils.AddTimer(progress, 0.1, 0)
end

function CInteractionCtrl.ResetInteractionFailTimer(self)
	if self.m_InteractionFailTimer then
		Utils.DelTimer(self.m_InteractionFailTimer)
		self.m_InteractionFailTimer = nil			
	end
end

--晶矿类型的互动任务失败后的自动播放特效计时
function CInteractionCtrl.SetInteractionCrystalOreFailCountTime(self)	
	self:ResetInteractionCrystalOreFailTimer()
	local function progress()
		g_InteractionCtrl.m_YibaoInteractionCrystalOreFailTime = g_InteractionCtrl.m_YibaoInteractionCrystalOreFailTime - 1
		
		if g_InteractionCtrl.m_YibaoInteractionCrystalOreFailTime <= 0 then
			g_InteractionCtrl.m_YibaoInteractionCrystalOreFailTime = 0

			self:OnEvent(define.Yibao.Event.InteractionCrystalOreFailTime, 0)

			--互动失败 m_YibaoInteractionResult 2是失败 1是成功
			-- if self.m_InteractionResultType == define.Yibao.InteractionResultType.Yibao then
			if self.m_YibaoInteractionResult == 2 then
				--发送互动失败协议
				netother.C2GSCallback(self.m_InteractionSessionidx, 2)
			end

			return false
		end
		return true
	end
	g_InteractionCtrl.m_YibaoInteractionCrystalOreFailTime = 4
	self.m_InteractionCrystalOreFailTimer = Utils.AddTimer(progress, 1, 0)

	self:OnEvent(define.Yibao.Event.InteractionCrystalOreFailTime, g_InteractionCtrl.m_YibaoInteractionCrystalOreFailTime)
end

function CInteractionCtrl.ResetInteractionCrystalOreFailTimer(self)
	if self.m_InteractionCrystalOreFailTimer then
		Utils.DelTimer(self.m_InteractionCrystalOreFailTimer)
		self.m_InteractionCrystalOreFailTimer = nil			
	end
end

return CInteractionCtrl
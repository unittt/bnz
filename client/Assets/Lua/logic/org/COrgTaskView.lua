local COrgTaskView = class("COrgTaskView", CViewBase)

function COrgTaskView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgTaskView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function COrgTaskView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_StarSprs = {}
	self.m_SmallStarSpr = {}
	for i=1,7 do
		self.m_StarSprs[i] = self:NewUI(i + 1, CSprite)
		self.m_SmallStarSpr[i] = self:NewUI(i + 8, CSprite)
	end
	self.m_RefreshBtn = self:NewUI(16, CSprite)
	self.m_CostItemBox = self:NewUI(17, CBox)
	self.m_CycleL = self:NewUI(18, CLabel)
	self.m_TaskNameL = self:NewUI(19, CLabel)
	self.m_PointerNode = self:NewUI(20, CWidget)
	self.m_DrawBtn = self:NewUI(21, CButton)
	self.m_RewardScrollView = self:NewUI(22, CScrollView)
	self.m_TaskRewardGrid = self:NewUI(23, CGrid)
	self.m_RewardItemBoxClone = self:NewUI(24, CBox)
	self.m_StarRewardGrid = self:NewUI(25, CGrid)
	self.m_StarRewardItemBoxClone = self:NewUI(26, CBox)
	self.m_WeekCycleL = self:NewUI(27, CLabel)
	self.m_TipBtn = self:NewUI(28, CButton)
	self.m_TaskRewardL = self:NewUI(29, CLabel)
	self.m_ReceiveBtn = self:NewUI(30, CButton)
	self.m_RefreshSpr = self:NewUI(31, CSprite)
	self.m_HitObj = self:NewUI(32, CObject)
	self.m_HitLbl = self:NewUI(33, CLabel)
	self.m_TaskDetailObj = self:NewUI(34, CObject)
	self.m_StarSp = self:NewUI(35, CSprite)
	self.m_StarLbl = self:NewUI(36, CLabel)
	self.m_StarDescLbl = self:NewUI(37, CLabel)

	-- self.m_RewardScrollView:SetActive(false)
	-- self.m_TaskRewardGrid:SetActive(false)

	self.m_CurTaskInfo = {}
	self.m_CostItemId = 10077	--寻珠令
	self.m_TouchEnabled = true
	self.m_IsCanReceive = false
	self.m_RingTotal = 35
	self:InitContent()
end

function COrgTaskView.InitContent(self)
	self:InitCostItem()
	self.m_RewardItemBoxClone:SetActive(false)
	self.m_StarRewardItemBoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnRefresh"))
	self.m_DrawBtn:AddUIEvent("click", callback(self, "OnDrawTask"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnShowTip"))
	self.m_ReceiveBtn:AddUIEvent("click", callback(self, "OnReceiveStarReward"))

	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlOrgEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTaskEvent"))
	g_ScheduleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnScheduleCtrlEvent"))
end

function COrgTaskView.InitCostItem(self)
	local oBox = self.m_CostItemBox
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
	oBox.m_AmountL = oBox:NewUI(3, CLabel)

	oBox:AddUIEvent("click", function()
		g_WindowTipCtrl:SetWindowGainItemTip(self.m_CostItemId)
	end)
end

---------------------init data--------------------------------------------
function COrgTaskView.InitTaskInfo(self, iTaskId, lUnlockStar, iCycleCnt, iStar, iBout, iPretaskinfo)
	table.print(self.m_CurTaskInfo)
	self.m_CurTaskInfo.task = iTaskId
	self.m_CurTaskInfo.star = iStar
	self.m_CurTaskInfo.pretaskinfo = iPretaskinfo
	self.m_CurTask = g_TaskCtrl.m_TaskDataDic[iTaskId]
	self.m_UnlockStarDict = {}
	for i,star in ipairs(lUnlockStar) do
		self.m_UnlockStarDict[star] = true
	end
	self.m_IsCanReceive = #lUnlockStar == 7
	self.m_CycleCnt = iCycleCnt
	self.m_WeekCycleCnt = iBout
	self:RefreshAllUI()
end

----------------------ctrl event-----------------------------------------
function COrgTaskView.OnCtrlOrgEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.UpdateOrgTask then
		-- self.m_FriendPid = oCtrl.m_EventData
		self.m_CurTaskInfo.task = oCtrl.m_EventData.task
		self.m_CurTaskInfo.star = oCtrl.m_EventData.star
		if oCtrl.m_EventData.pretaskinfo then
			self.m_CurTaskInfo.pretaskinfo = oCtrl.m_EventData.pretaskinfo
		end
		if oCtrl.m_EventData.ringcnt then
			self.m_CycleCnt = oCtrl.m_EventData.ringcnt
			self:RefreshCycle()
		end
		self.m_CurTask = g_TaskCtrl.m_TaskDataDic[self.m_CurTaskInfo.task]
		self:ShowStarAni()
	elseif oCtrl.m_EventID == define.Org.Event.CleanTaskStar then
		self.m_UnlockStarDict = {}
		self.m_IsCanReceive = false
		self:RefreshAllStar()
    end
end

function COrgTaskView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		define.Item.Event.RefreshSpecificItem then
		--刷新下物品数量
		self:RefreshCostItem()
	end
end

function COrgTaskView.OnCtrlTaskEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.AddTask then
		CTaskHelp.ClickTaskLogic(oCtrl.m_EventData)
		self:CloseView()
	end
end

function COrgTaskView.OnScheduleCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Schedule.Event.RefreshMainUI or oCtrl.m_EventID == define.Schedule.Event.RefreshSchedule then
        self:CheckCircle()
    end
end

----------------------refresh ui--------------------------------
function COrgTaskView.RefreshAllUI(self)
	self:RefreshCostItem()
	self:InitPointer()	
	self:ResetAllSmallStar()
	self:RefreshTask()
	self:RefreshRward()
	self:RefreshStarReward()
	self:RefreshDrawButton()
	self:RefreshTargetStar(self.m_CurTaskInfo.star)
	self:RefreshCycle()
	self:RefreshRefreshBtn()
	self:RefreshAllStar()
	self:CheckCircle()
end

function COrgTaskView.CheckCircle(self)
	local orgScheduleData = g_ScheduleCtrl:GetScheduleData(define.Task.AceSchedule.ORGTASK)
	if orgScheduleData then
		self.m_CycleL:SetText("[244B4E]本周第[1d8e00]"..(orgScheduleData.times+1).."/"..orgScheduleData.maxtimes.."[-]环任务")
	else
		self.m_CycleL:SetText("[244B4E]本周第[1d8e00]1/"..self.m_RingTotal.."[-]环任务")
	end
end

function COrgTaskView.CheckTargetUI(self)
	if self.m_CurTaskInfo.star and self.m_CurTaskInfo.star ~= 0 then
		self.m_HitObj:SetActive(false)
		self.m_TaskDetailObj:SetActive(true)
		self.m_StarSp:SetSpriteName(self:GetStarName(self.m_CurTaskInfo.star))
		self.m_StarLbl:SetText(string.printInChinese(self.m_CurTaskInfo.star).."星灵珠")
		if self.m_UnlockStarDict[self.m_CurTaskInfo.star] then
			self.m_StarDescLbl:SetText("已经点亮该灵珠")
		else
			self.m_StarDescLbl:SetText("完成任务后点亮")
		end
	else
		self.m_HitObj:SetActive(true)
		self.m_HitLbl:SetText("请点击左侧寻珠领取任务")
		self.m_TaskDetailObj:SetActive(false)
	end
end

function COrgTaskView.GetStarName(self, oStar)
	if oStar == 1 then
		return "h7_yixing_1"
	elseif oStar == 2 then
		return "h7_liangxing_1"
	elseif oStar == 3 then
		return "h7_sanxing_1"
	elseif oStar == 4 then
		return "h7_sixing_1"
	elseif oStar == 5 then
		return "h7_wuxing_1"
	elseif oStar == 6 then
		return "h7_liuxing_1"
	elseif oStar == 7 then
		return "h7_qixing_1"
	else
		return "h7_yixing_1"
	end
end

function COrgTaskView.RefreshCostItem(self)
	local oBox = self.m_CostItemBox
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_CostItemId)
	local tItemData = DataTools.GetItemData(self.m_CostItemId)

	self.m_IsCanReset = iAmount > 0 and not self.m_CurTask

	oBox.m_AmountL:SetText(iAmount)
	oBox.m_IconSpr:SpriteItemShape(tItemData.icon)
	oBox.m_QualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( tItemData.id, tItemData.quality or 0 ))
end

function COrgTaskView.InitPointer(self)
	if not self.m_CurTaskInfo.star or self.m_CurTaskInfo.star == 0 then
		return
	end
	local iDegress = self:GetDegress(self.m_PointerNode:GetLocalPos(), self.m_SmallStarSpr[self.m_CurTaskInfo.star]:GetLocalPos())
	local tween = DOTween.DORotate(self.m_PointerNode.m_Transform, Vector3.New(0, 0, iDegress - 360), 0.5, 0.5)
end

function COrgTaskView.RefreshAllStar(self)
	for i,oStarSpr in ipairs(self.m_SmallStarSpr) do
		local bIsUnlock = self.m_UnlockStarDict[i]
		local bIsLight = self.m_CurTaskInfo.star == i
		oStarSpr:DelEffect("Circu")
		if bIsUnlock then
			oStarSpr:AddEffect("Circu")
		end
		if bIsUnlock or bIsLight then
			oStarSpr:SetGrey(false)
		else
			oStarSpr:SetGrey(true)
		end
	end

	self:CheckTargetUI()
	self.m_ReceiveBtn:SetActive(self.m_IsCanReceive)
end

function COrgTaskView.ResetAllSmallStar(self)
	-- for i,oStarSpr in ipairs(self.m_SmallStarSpr) do
	-- 	oStarSpr:SetGrey(true)
	-- end

	for i,oStarSpr in ipairs(self.m_SmallStarSpr) do
		local bIsUnlock = self.m_UnlockStarDict[i]
		oStarSpr:DelEffect("Circu")
		if bIsUnlock then
			oStarSpr:AddEffect("Circu")
		end
		if bIsUnlock then
			oStarSpr:SetGrey(false)
		else
			oStarSpr:SetGrey(true)
		end
	end
end

function COrgTaskView.RefreshTargetStar(self, iStar)
	if iStar <= 0 then
		return
	end
	self.m_SmallStarSpr[iStar]:SetGrey(false)
end

function COrgTaskView.RefreshTask(self)
	local dData = DataTools.GetTaskData(self.m_CurTaskInfo.task)
	self.m_TaskNameL:SetActive(dData ~= nil and self.m_CurTaskInfo.task > 0)
	if not dData or self.m_CurTaskInfo.task == 0 then
		return
	end
	local oNeedData = self.m_CurTaskInfo.pretaskinfo
	local oDescStr = dData.goalDesc
	if oNeedData then
		local oNpcName
		local oMapId
		if oNeedData.npctype ~= 0 then
			local oGlobalNpc = DataTools.GetGlobalNpc(oNeedData.npctype)
			if oGlobalNpc then
				oNpcName = oGlobalNpc.name
				oMapId = oGlobalNpc.mapid
			else
				local oDynamicNpc = DataTools.GetTaskNpcByTaskType(oNeedData.npctype, define.Task.TaskCategory.ORG.NAME)
				if oDynamicNpc then
					local oFindMark = string.find(oDynamicNpc.name, "#npc")
					if oFindMark then
						oNpcName = string.gsub(oDynamicNpc.name, "#npc", oNeedData.npcname)
					else
						oNpcName = oDynamicNpc.name
					end

					if data.mapdata.MAP[oDynamicNpc.mapid] then
						oMapId = oDynamicNpc.mapid
					else
						if oNeedData.mapid ~= 0 then
							oMapId = oNeedData.mapid
						end
					end
				end
			end
			if oNpcName then
				oDescStr = string.gsub(oDescStr, "{submitnpc}", "#G"..oNpcName.."#n")
			end
		else
			if oNeedData.mapid ~= 0 then
				oMapId = oNeedData.mapid
			end
		end
		if oNeedData.itemsid ~= 0 then
			local oItem = DataTools.GetItemData(oNeedData.itemsid)
			oDescStr = string.gsub(oDescStr, "{item}", "#G"..oItem.name.."#n")
		end
		if oMapId then
			local oName = DataTools.GetSceneNameByMapId(oMapId)
			oDescStr = string.gsub(oDescStr, "{map}", "#O"..oName.."#n")
		end
	end
	self.m_TaskNameL:SetText("[63432C]"..oDescStr) --"任务："..
end

function COrgTaskView.RefreshCycle(self)
	--暂时屏蔽
	-- self.m_CycleL:SetText("第"..self.m_CycleCnt.."/7环")
	self.m_WeekCycleL:SetText(self.m_WeekCycleCnt.."/5")
end

function COrgTaskView.RefreshRward(self)
	if self.m_CurTaskInfo.task == 0 then
		self.m_TaskRewardL:SetText("")
		return
	end
	local dStarReward = g_OrgCtrl:GetOrgTaskReward()
	if not dStarReward then
		return
	end
	local expStr = (dStarReward.exp and dStarReward.exp > 0) and "#cur_6"..dStarReward.exp.." " or ""
	local orgStr = (dStarReward.orgoffer and dStarReward.orgoffer > 0) and "#cur_7"..dStarReward.orgoffer or ""
	self.m_TaskRewardL:SetText(string.format("奖励：" .. expStr .. orgStr))
	-- do return end
	-- 下面是旧的（ItemBox实现方式）

	self.m_RewardScrollView:ResetPosition()
	self.m_TaskRewardGrid:Clear()
	local dTaskReward = g_OrgCtrl:GetOrgTaskReward()
	if not dTaskReward then
		return
	end
	local function AddTaskReward(dReward, iAmount)
		local oBox = self:CreateRewardItem(dReward, iAmount)
		self.m_TaskRewardGrid:AddChild(oBox)
	end 
	
	if dTaskReward.exp and dTaskReward.exp > 0 then
		local dData = DataTools.GetItemData(1005, "VIRTUAL")
		AddTaskReward(dData, dTaskReward.exp)
	end
	if dTaskReward.orgoffer and dTaskReward.orgoffer > 0 then
		local dData = DataTools.GetItemData(1008, "VIRTUAL")
		AddTaskReward(dData, dTaskReward.orgoffer)
	end
	for i,dItem in ipairs(dTaskReward.itemlist) do
		local dData = DataTools.GetItemData(dItem.itemsid)
		AddTaskReward(dData, dItem.amount)
	end
	self.m_TaskRewardGrid:Reposition()
end

function COrgTaskView.CreateRewardItem(self, dReward, iAmount)
	local oBox = self.m_RewardItemBoxClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
	oBox.m_AmountL = oBox:NewUI(3, CLabel)

	oBox.m_IconSpr:SpriteItemShape(dReward.icon)
	oBox.m_QualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal( dReward.id, dReward.quality or 0 ))
	oBox.m_QualitySpr:SetSize(72,72)
	oBox.m_AmountL:SetText(iAmount)
	oBox:AddUIEvent("click", function()
		local config = {widget = oBox}
		g_WindowTipCtrl:SetWindowItemTip(dReward.id, config)
	end)
	oBox:SetActive(true)
	return oBox
end

function COrgTaskView.RefreshDrawButton(self)
	self.m_DrawBtn:SetEnabled(self.m_CurTaskInfo.task ~= 0)
	-- self.m_DrawBtn:SetActive(not self.m_CurTask)
	if not self.m_CurTask and self.m_CurTaskInfo.task and self.m_CurTaskInfo.task ~= 0 then
		self.m_DrawBtn:SetActive(true)
	else
		self.m_DrawBtn:SetActive(false)
	end
end

function COrgTaskView.RefreshStarReward(self)
	self.m_StarRewardGrid:Clear()
	local dStarReward = g_OrgCtrl:GetOrgStarReward()
	if not dStarReward then
		return
	end
	local function AddStarReward(dReward, iAmount)
		local oBox = self:CreateRewardItem(dReward, iAmount)
		self.m_StarRewardGrid:AddChild(oBox)
	end 
	
	if dStarReward.exp and dStarReward.exp > 0 then
		local dData = DataTools.GetItemData(1005, "VIRTUAL")
		AddStarReward(dData, dStarReward.exp)
	end
	if dStarReward.orgoffer and dStarReward.orgoffer > 0 then
		local dData = DataTools.GetItemData(1008, "VIRTUAL")
		AddStarReward(dData, dStarReward.orgoffer)
	end
	for i,dItem in ipairs(dStarReward.itemlist) do
		local dData = DataTools.GetItemData(dItem.itemsid)
		AddStarReward(dData, dItem.amount)
	end
	self.m_StarRewardGrid:Reposition()
end

function COrgTaskView.RefreshRefreshBtn(self)
	self.m_RefreshBtn:DelEffect("Circu")
	if not self.m_CurTask and not self.m_IsCanReceive then
		self.m_RefreshBtn:AddEffect("Circu")
	end
	if self.m_IsCanReset and self.m_CurTaskInfo.task > 0 then
		self.m_RefreshSpr:SetSpriteName("h7_shuaxin2")
	else
		self.m_RefreshSpr:SetSpriteName("h7_shuaxin1")
	end
end

function COrgTaskView.ShowStarAni(self)
	local iDegress = self:GetDegress(self.m_PointerNode:GetLocalPos(), self.m_SmallStarSpr[self.m_CurTaskInfo.star]:GetLocalPos())
	local tween = DOTween.DORotate(self.m_PointerNode.m_Transform, Vector3.New(0, 0, iDegress-360*2), 1, 1)
	local function onEnd()
		self.m_TouchEnabled = true
		self.m_DrawBtn:SetEnabled(true)
		self:RefreshDrawButton()
		self:RefreshRefreshBtn()
		self:RefreshTask()
		self:RefreshRward()
		self:RefreshTargetStar(self.m_CurTaskInfo.star)
		self:RefreshAllStar()
	end
	DOTween.OnComplete(tween, onEnd)
	self:ResetAllSmallStar()
end

--获取指针旋转的角度
function COrgTaskView.GetDegress(self, startPos, endPos)
	local xDelta = endPos.x - startPos.x
	local yDelta = endPos.y - startPos.y
	local iDegress
	if xDelta > 0 and yDelta > 0 then
		iDegress = -(90 - math.deg(math.atan(math.abs(yDelta/xDelta))))
	elseif xDelta > 0 and yDelta == 0 then
		iDegress = -90
	elseif xDelta > 0 and yDelta < 0 then
		iDegress = -(90 + math.deg(math.atan(math.abs(yDelta/xDelta))))
	elseif xDelta == 0 and yDelta > 0 then
		iDegress = 0
	elseif xDelta == 0 and yDelta == 0 then
		iDegress = 0
	elseif xDelta == 0 and yDelta < 0 then
		iDegress = 180
	elseif xDelta < 0 and yDelta > 0 then
		iDegress = 90 - math.deg(math.atan(math.abs(yDelta/xDelta)))
	elseif xDelta < 0 and yDelta == 0 then
		iDegress = 90
	elseif xDelta < 0 and yDelta < 0 then
		iDegress = 90 + math.deg(math.atan(math.abs(yDelta/xDelta)))
	end
	return iDegress
end

-----------------------click event---------------------------------
function COrgTaskView.OnRefresh(self)
	if not self.m_TouchEnabled then
		return
	end
	if self.m_IsCanReceive then
		g_NotifyCtrl:FloatMsg(DataTools.GetOrgTaskText(1011))
		return
	end
	self.m_TouchEnabled = false
	self.m_DrawBtn:SetEnabled(false)
	if self.m_CurTaskInfo.task == 0 then
		nethuodong.C2GSOrgTaskRandTask()
	elseif self.m_IsCanReset then	
		nethuodong.C2GSOrgTaskResetStar()
	else
		self.m_TouchEnabled = true
		self.m_DrawBtn:SetEnabled(true)
		g_NotifyCtrl:FloatMsg(not self.m_CurTask and DataTools.GetOrgTaskText(1012) or DataTools.GetOrgTaskText(1013))
		if not self.m_CurTask then
			g_WindowTipCtrl:SetWindowGainItemTip(self.m_CostItemId)
		end
	end
end

function COrgTaskView.OnDrawTask(self)
	g_NotifyCtrl:FloatMsg(DataTools.GetOrgTaskText(1014))--接受任务
	nethuodong.C2GSOrgTaskReceiveTask()
end

function COrgTaskView.OnShowTip(self)
	local id = define.Instruction.Config.OrgTask
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function COrgTaskView.OnReceiveStarReward(self)
	if not self.m_IsCanReceive then
		g_NotifyCtrl:FloatMsg(DataTools.GetOrgTaskText(1010))--"集齐七颗灵珠才可以领取")
		return
	end
	nethuodong.C2GSOrgTaskStarReward()
end

return COrgTaskView
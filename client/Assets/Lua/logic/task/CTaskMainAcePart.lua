local CTaskMainAcePart = class("CTaskMainAcePart", CPageBase)

function CTaskMainAcePart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_AceTitleLabel = self:NewUI(1, CLabel)
	self.m_AceTargetLabel = self:NewUI(2, CLabel)	
	self.m_AceNeedLabel = self:NewUI(5, CLabel)
	self.m_AceDescLabel = self:NewUI(6, CLabel)
	self.m_PrizeGrid = self:NewUI(8, CGrid)
	self.m_PrizeBoxClone = self:NewUI(9, CBox)
	self.m_AceBtn = self:NewUI(10, CButton)
	self.m_PrizeScrollView = self:NewUI(11, CScrollView)
	self.m_ContentScrollView = self:NewUI(12, CScrollView)

	self.m_TaskData = nil
	self.m_RewardList = nil

	self.m_PrizeBoxClone:SetActive(false)
	self.m_AceBtn:AddUIEvent("click", callback(self, "OnClickAcceptTask"))
end

function CTaskMainAcePart.OnInitPage(self)
	print(string.format("<color=#00FFFF> >>> .%s | 程序执行到这里了 | %s </color>", "OnInitPage", "接取任务Part，什么都没有"))
end

--设置可接任务part里面的每个任务二级菜单对应的内容
function CTaskMainAcePart.SetTaskInfo(self, oTask)
	self.m_TaskData = oTask
	self:SetActive(true)

	g_TaskCtrl.m_AceTaskNotify[oTask:GetSValueByKey("taskid")] = 1
	--保存可接任务红点数据
	g_TaskCtrl:SaveAceTaskNotifyData(g_TaskCtrl.m_AceTaskNotify)
	g_TaskCtrl:OnEvent(define.Task.Event.RedPointNotify)
	self.m_ParentView:SetAceTabRedPoint(not g_TaskCtrl:GetIsAllAceTaskRead())

	-- local title = string.format("[5E2E10]%s-%s", oTask.m_TaskType.name, oTask:GetSValueByKey("name"))
	local title = string.format("[386D6F]%s-%s", oTask.m_TaskType.name, oTask:GetSValueByKey("name"))
	--以后要根据需求修改
	if g_TaskCtrl:GetIsSpecialAceTask(oTask:GetSValueByKey("taskid")) then
		title = string.format("[386D6F]%s", oTask.m_TaskType.name)
	end
	self.m_AceTitleLabel:SetText(title)
	local target = string.format("%s", oTask:GetSValueByKey("targetdesc"))
	self.m_AceTargetLabel:SetText(target)
	local describe = string.format("[63432c]%s", oTask:GetSValueByKey("detaildesc"))
	self.m_AceDescLabel:SetText(describe)
	local needstr = DataTools.GetTaskType(oTask:GetCValueByKey("type")).appenddes
	local need = string.format("[63432c]%s", needstr)
	self.m_AceNeedLabel:SetText(need)

	local rewardList = CTaskHelp.GetTaskRewardList(oTask)
	self.m_RewardList = rewardList
	local showReward = rewardList and #rewardList > 0
	self.m_PrizeGrid:SetActive(showReward)
	-- print(string.format("<color=#00FF00> >>> .%s | %s | Table:%s </color>", "SetTaskInfo", "奖励列表", "rewardList"))
	-- table.print(rewardList)
	local rewardGridList = self.m_PrizeGrid:GetChildList()
	local groupID = self.m_PrizeGrid:GetInstanceID()
	for i,v in ipairs(rewardList) do
		if v.type == 1 then
			local oRewardBox = nil
			if i > #rewardGridList then
				oRewardBox = self.m_PrizeBoxClone:Clone()
				oRewardBox.m_Icon = oRewardBox:NewUI(1, CButton)
				oRewardBox.m_Quality = oRewardBox:NewUI(2, CSprite)
				oRewardBox:SetGroup(groupID)
				self.m_PrizeGrid:AddChild(oRewardBox)
			else
				oRewardBox = rewardGridList[i]
			end
			oRewardBox:AddUIEvent("click", callback(self, "OnClickPrizeBox", v.item, oRewardBox))
			oRewardBox.m_Icon.m_UIButton.normalSprite = tostring(v.item.icon)
			oRewardBox.m_Icon:SpriteItemShape(v.item.icon)
			oRewardBox.m_Quality:SetItemQuality(g_ItemCtrl:GetQualityVal( v.item.id, v.item.quality or 0 ) )
			oRewardBox:SetActive(true)
		end
	end

	for i=#rewardList+1,#rewardGridList do
		rewardGridList[i]:SetActive(false)
	end

	self.m_ContentScrollView:ResetPosition()
end

--点击接取任务按钮
function CTaskMainAcePart.OnClickAcceptTask(self)
	self.m_ParentView:CloseView()
	if not self.m_TaskData then
		return
	end
	local taskid = self.m_TaskData:GetSValueByKey("taskid")
	local npcid = self.m_TaskData:GetSValueByKey("target")
	if not taskid then
		printc("没有任务id")
		return
	end
	if not npcid or npcid == 0 then
		printc("没有Npcid")
		nettask.C2GSAcceptTask(taskid, nil)
	else
		if self.m_TaskData then
			--以后要根据需求修改
			if g_TaskCtrl:GetIsSpecialAceTask(self.m_TaskData:GetSValueByKey("taskid")) then
				CTaskHelp.SetClickTaskExecute(nil)
			else
				CTaskHelp.SetClickTaskExecute(self.m_TaskData)
			end
			local globalNpc = DataTools.GetGlobalNpc(npcid)
			if globalNpc and not DataTools.GetSceneDataByMapId(globalNpc.mapid) then
				netnpc.C2GSFindPathToNpc(npcid)
			else
				g_MapTouchCtrl:WalkToGlobalNpc(npcid)
			end			
		end		
	end	
end

function CTaskMainAcePart.OnClickPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

return CTaskMainAcePart
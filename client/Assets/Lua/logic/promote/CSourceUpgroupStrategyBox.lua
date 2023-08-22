local CSourceUpgroupStrategyBox = class("CSourceUpgroupStrategyBox", CBox)

function CSourceUpgroupStrategyBox.ctor(self, obj)
	-- body
	CBox.ctor(self, obj)
	-- self.m_RowScrollView = self:NewUI(1, CScrollView)
	-- self.m_RowGird = self:NewUI(2, CGrid)
	-- self.m_RowBoxClone = self:NewUI(3, CBox)
	self.m_ColScrollView = self:NewUI(4, CScrollView)
	self.m_ColGrid = self:NewUI(5, CGrid)
	self.m_ColBoxClone = self:NewUI(6, CBox)
	self.m_DesPart = self:NewUI(7, CBox)
	self.m_ScheduleDesBox = self:NewUI(8, CBox)

	self.m_ScheduleDesIcon = self.m_ScheduleDesBox:NewUI(1, CSprite)
	self.m_ScheduleDesName = self.m_ScheduleDesBox:NewUI(2, CLabel)
	self.m_ScheduleDesTime = self.m_ScheduleDesBox:NewUI(3, CLabel)
	self.m_ScheduleDesLevel = self.m_ScheduleDesBox:NewUI(4, CLabel)
	self.m_ScheduleDesMan = self.m_ScheduleDesBox:NewUI(5, CLabel)
	self.m_ScheduleDesMethod = self.m_ScheduleDesBox:NewUI(6, CLabel)
	self.m_ScheduleDesLab   = self.m_ScheduleDesBox:NewUI(7, CLabel)
	self.m_ScheudleTable   = self.m_ScheduleDesBox:NewUI(8, CTable)

	self.m_RewardGrid = self:NewUI(9, CGrid)
	self.m_ItemBox =  self:NewUI(10, CBox)
	self.m_ExplainSV = self:NewUI(11, CScrollView)
	self.m_CurrRowBtnIdx = nil
	self.m_CurrColBtnIdx = nil
	--self:InitContent()

	g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPromoteEvent"))
end

-- function CSourceUpgroupStrategyBox.InitContent(self)
-- 	-- body
-- 	local levellist = data.sourcebookdata.UPGRADE 
-- 	self.m_RowGird:Clear()
-- 	local rowlist = self.m_RowGird:GetChildList()
-- 	for i,v in ipairs(levellist) do
-- 		local rowBox = nil
-- 		if i>#rowlist then
-- 			rowBox = self.m_RowBoxClone:Clone()
-- 			rowBox:SetActive(true)
-- 			self.m_RowGird:AddChild(rowBox)
-- 			rowBox.btn = rowBox:NewUI(1, CButton)
-- 			rowBox.btn:SetGroup(self.m_RowGird:GetInstanceID())
-- 			rowBox.norlab = rowBox:NewUI(2, CLabel)
-- 			rowBox.sellab = rowBox:NewUI(3, CLabel)
-- 		else
-- 			rowBox = rowlist[i]
-- 		end
-- 		rowBox.norlab:SetText(v.name)
-- 		rowBox.sellab:SetText(v.name)
-- 		rowBox.btn:AddUIEvent("click", callback(self, "OnRowBtnClick", i))
-- 	end
-- 	self.m_RowGird:GetChild(1).btn:SetSelected(true)
-- 	self:OnRowBtnClick(1)
-- end

function CSourceUpgroupStrategyBox.RefreshUI(self, rowidx)
	-- body	
	if self.m_CurrRowBtn and self.m_CurrRowBtn == rowidx then
		return
	end
	self.m_ColGrid:Reposition()
	self.m_ColScrollView:ResetPosition()
	self.m_CurrRowBtnIdx = rowidx

	local levellist = data.sourcebookdata.UPGRADE
	local grade = levellist[rowidx].levelid

	local upinfo = data.sourcebookdata.UPGRADESECONDARY
	local scheduleinfo = data.scheduledata.SCHEDULE
	local templist = {}
	for i,v in ipairs(upinfo) do
		if grade == v.levelid then
			table.insert(templist, v)
		end
	end

	for i,v in ipairs(templist) do
		local dSchedule = scheduleinfo[v.scheduleid]
		v.level = dSchedule.level
	end
	table.sort(templist, function (a,b)
		-- body
		return a.level< b.level
	end)

	self.m_ColGrid:Clear()
	local collist = self.m_ColGrid:GetChildList()
	for i,v in ipairs(templist) do
		local colbox = nil
		if i>#collist then
			colbox = self.m_ColBoxClone:Clone()
			self.m_ColGrid:AddChild(colbox)
			colbox:SetActive(true)
			colbox.btn = colbox:NewUI(1, CSprite)
			colbox.btn:SetGroup(self.m_ColGrid:GetInstanceID())
			colbox.norlab = colbox:NewUI(2, CLabel)
			colbox.sellab = colbox:NewUI(3, CLabel)
			colbox.icon = colbox:NewUI(4, CSprite)
		else
			colbox = collist[i]
		end

		local dSchedule = scheduleinfo[v.scheduleid]
		colbox.norlab:SetText(dSchedule.name)
		colbox.sellab:SetText(dSchedule.name)
		colbox.icon:SpriteItemShape(dSchedule.icon)
		colbox.btn:AddUIEvent("click", callback(self, "OnRefreshSchedule", dSchedule, v.des, i))
	end
	self.m_ColGrid:GetChild(1).btn:SetSelected(true)
	self:OnRefreshSchedule(scheduleinfo[templist[1].scheduleid], templist[1].des)
end


function CSourceUpgroupStrategyBox.OnRefreshSchedule(self, schedule, text, colidx)
	-- body
	if self.m_CurrColBtnIdx and self.m_CurrColBtnIdx == colidx then 
		return
	end

	self.m_CurrColBtnIdx = colidx

	self.m_ScheduleDesIcon:SpriteItemShape(schedule.icon)
	self.m_ScheduleDesName:SetText(schedule.name)
	self.m_ScheduleDesTime:SetText("活动时间："..schedule.activetime)
	self.m_ScheduleDesLevel:SetText("等级要求："..schedule.level)
	self.m_ScheduleDesMan:SetText("活动人数："..schedule.peoplelimit)
	self.m_ScheduleDesLab:SetText("活动描述："..schedule.desc)
	self.m_ScheudleTable:Reposition()
	
	self.m_ScheduleDesMethod:SetText(text)
	self.m_RewardGrid:Clear()
	local rawardlist = self.m_RewardGrid:GetChildList()
	for i,v in ipairs(schedule.rewardlist) do
		local rewardbox = nil
		if i>#rawardlist then
			rewardbox = self.m_ItemBox:Clone()
			rewardbox:SetActive(true)

			rewardbox:SetGroup(self.m_RewardGrid:GetInstanceID())
			self.m_RewardGrid:AddChild(rewardbox)

			rewardbox.icon = rewardbox:NewUI(1, CSprite)
			rewardbox.frame = rewardbox:NewUI(2, CSprite)
		else
			rewardbox = rawardlist[i]
		end
		local reward = string.split(v, ":")
		local dItem = DataTools.GetItemData(reward[1])
		rewardbox.icon:SpriteItemShape(dItem.icon)
		rewardbox.frame:SetItemQuality(dItem.quality)
		rewardbox.icon:AddUIEvent("click", callback(self, "OnIconClick", {widget = rewardbox.icon, sid = dItem.id}))
	end
	self.m_ExplainSV:ResetPosition()
end

function CSourceUpgroupStrategyBox.OnIconClick(self, args)
	local config = {widget = args.widget}
	-- if self.m_IsCouldClickClose then
	-- 	g_WindowTipCtrl:SetWindowItemTip(args.sid, config, nil, "BeyondGuide")
	-- else
		g_WindowTipCtrl:SetWindowItemTip(args.sid, config)
	-- end
end

function CSourceUpgroupStrategyBox.OnPromoteEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Promote.Event.RefreshSourceUpgroupInfo then
		self:RefreshUI(oCtrl.m_EventData)
	end
end

return CSourceUpgroupStrategyBox
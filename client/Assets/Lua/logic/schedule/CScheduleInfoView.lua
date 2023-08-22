local CScheduleInfoView = class("CScheduleInfoView", CViewBase)

function CScheduleInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Schedule/ScheduleInfoView.prefab", cb)
	self.m_DepthType = "Dialog"
	--self.m_ExtendClose = "Black"
end

function CScheduleInfoView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_DescLabel = self:NewUI(2, CLabel)
	self.m_TypeLabel = self:NewUI(3, CLabel)
	self.m_LimitLabel = self:NewUI(4, CLabel)
	self.m_TimesLabel = self:NewUI(5, CLabel)
	self.m_RewardInfo = self:NewUI(6, CObject)
	self.m_RewardGrid = self:NewUI(7, CGrid)
	self.m_RewardBoxClone = self:NewUI(8, CBox)
	self.m_ViewBg = self:NewUI(9, CSprite)
	
	self.m_RewardBoxClone:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
	self.m_ViewBg:AddUIEvent("click", callback(self, "OnClose"))
end

function CScheduleInfoView.OnClose(self)
	-- if not self.m_IsCouldClickClose then
	-- 	return
	-- end
	self:CloseView()
end

function CScheduleInfoView.SetScheduleID(self, sid)
	local scheduleInfo = g_ScheduleCtrl:GetScheduleInfo(sid)
	self:SetScheduleInfo(scheduleInfo)
end

function CScheduleInfoView.SetScheduleInfo(self, scheduleData)
	self.m_TitleLabel:SetText(scheduleData.name)
	self.m_DescLabel:SetText(scheduleData.desc)
	self.m_TypeLabel:SetText("人数要求: " .. scheduleData.peoplelimit)--[ADE6D8]
	self.m_TimesLabel:SetText("活动时间: " .. scheduleData.activetime)--[ADE6D8]
	self.m_LimitLabel:SetText("等级要求: " .. scheduleData.level)--[ADE6D8]
	local showReward = scheduleData.rewardlist and #scheduleData.rewardlist > 0
	self.m_RewardInfo:SetActive(showReward)
	if showReward then
		self:SetRewardItem(scheduleData.rewardlist)	
	end
end

function CScheduleInfoView.SetRewardItem(self, rewardList)
	local rewardBoxList = self.m_RewardGrid:GetChildList()
	local oRewardBox = nil
	for i,v in ipairs(rewardList) do
		local strs = string.split(v, ":")
		local itemID, itemAmount = strs[1], strs[2]
		local itemData = DataTools.GetItemData(itemID)
		if i > #rewardBoxList then
			if itemData then
				oRewardBox = self.m_RewardBoxClone:Clone()
				oRewardBox.m_Icon = oRewardBox:NewUI(1, CSprite)
				oRewardBox.m_Quality = oRewardBox:NewUI(2, CSprite)
				oRewardBox.m_Amount = oRewardBox:NewUI(3, CLabel)
				oRewardBox:SetName("ScheduleInfoRewardBox_" .. i)
				self.m_RewardGrid:AddChild(oRewardBox)
			end
		else
			oRewardBox = rewardBoxList[i]
		end
		if itemData then
			oRewardBox.m_Icon:SpriteItemShape(itemData.icon)
			oRewardBox.m_Quality:SetItemQuality(g_ItemCtrl:GetQualityVal( itemData.id, itemData.quality or 0 ))
			local showAmount = tonumber(itemAmount) > 0
			oRewardBox.m_Amount:SetActive(showAmount)
			if showAmount then
				oRewardBox.m_Amount:SetText(itemAmount)
			end
			oRewardBox:AddUIEvent("click", callback(self, "ShowWindowItemTip", {widget = oRewardBox, sid = itemID}))
			oRewardBox:SetActive(true)
		else
			oRewardBox:SetActive(false)
		end
	end

	for i=#rewardList+1,#rewardBoxList do
		oRewardBox = rewardBoxList[i]
		if not oRewardBox then
			break
		end
		oRewardBox:SetActive(false)
	end
end

function CScheduleInfoView.ShowWindowItemTip(self, args)
	local config = {widget = args.widget}
	if self.m_IsCouldClickClose then
		g_WindowTipCtrl:SetWindowItemTip(args.sid, config, nil, "BeyondGuide")
	else
		g_WindowTipCtrl:SetWindowItemTip(args.sid, config)
	end
end

return CScheduleInfoView
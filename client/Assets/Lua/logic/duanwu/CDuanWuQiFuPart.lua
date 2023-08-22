local CDuanWuQiFuPart = class("CDuanWuQiFuPart", CPageBase)

function CDuanWuQiFuPart.ctor(self, cb)
	
	CPageBase.ctor(self, cb)

	 self.m_Time = self:NewUI(1, CLabel)
	 self.m_Des = self:NewUI(2, CLabel)
	 self.m_ProgressReward = self:NewUI(3, CProgressReward)
	 self.m_SubmitBtn = self:NewUI(4, CSprite)
	 self.m_JiPinIcon = self:NewUI(5, CSprite)
	 self.m_JiPinName = self:NewUI(6, CLabel)
	 self.m_JiPinCnt = self:NewUI(7, CLabel)
	 self.m_JiPinQuality = self:NewUI(8, CSprite)

end

function CDuanWuQiFuPart.OnInitPage(self)

	g_DuanWuHuodongCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit"))
	g_DuanWuHuodongCtrl:C2GSDuanwuQifuOpenUI()

end

function CDuanWuQiFuPart.InitContent(self)

	self:RefreshProgressReward()
	self:RefreshDes()
	self:RefreshBtnState()
	self:RefreshJiPin()
	self:RefreshTime()

end 

function CDuanWuQiFuPart.RefreshBtnState(self)

	local isHadJiPin = g_DuanWuHuodongCtrl:IsHadJiPin()
	self.m_SubmitBtn:SetGrey(not isHadJiPin)

end 

function CDuanWuQiFuPart.RefreshJiPin(self)

	local jiPinInfo = g_DuanWuHuodongCtrl:GetQiFuJiPinInfo()
	self.m_JiPinIcon:SpriteItemShape(jiPinInfo.icon)
	self.m_JiPinName:SetText(jiPinInfo.name)
	self.m_JiPinCnt:SetText(jiPinInfo.cnt)
	self.m_JiPinQuality:SetItemQuality(jiPinInfo.quality)
	self.m_JiPinIcon:AddUIEvent("click", callback(self, "OnClickJiPin", self.m_JiPinIcon, jiPinInfo))

end 

function CDuanWuQiFuPart.RefreshDes(self)

	local des = g_DuanWuHuodongCtrl:GetHuodongDes(10071)
	self.m_Des:SetText(des)

end 

function CDuanWuQiFuPart.RefreshProgressReward(self)

	local info = g_DuanWuHuodongCtrl:GetQiFuInfoList()

	self.m_ProgressReward:RefreshInfo(info, callback(self, "OnRewardCb"))

end 

function CDuanWuQiFuPart.OnRewardCb(self, item)

	local info = item.m_StepInfo
	if not info.hadReward then 
		if info.canReward then 
			g_DuanWuHuodongCtrl:C2GSDuanwuQifuReward(info.id)
		else
			local rewardInfo = g_DuanWuHuodongCtrl:GetQiFuRewardInfo(info.rewardId)
			if rewardInfo then 
				local sid = rewardInfo.sid
				local config = {widget = item}
				g_WindowTipCtrl:SetWindowItemTip(sid, config)
			end
		end 
		
	end 

end 

function CDuanWuQiFuPart.RefreshTime(self)

	local cb = function (time)
        if not time then 
            self.m_Time:SetText("活动结束")
        else
            self.m_Time:SetText(time)
        end 
    end
	
	local endTime = g_DuanWuHuodongCtrl:GetQiFuEndTime()
	if endTime and endTime > 0 then 
		local leftTime = endTime - g_TimeCtrl:GetTimeS()
		g_TimeCtrl:StartCountDown(self, leftTime, 1, cb)
	end 

end

function CDuanWuQiFuPart.OnEvent(self, oCtrl)

	if oCtrl.m_EventID == define.DuanWuHuodong.Event.QiFuDataChange then
		self:InitContent()
	end 

end

function CDuanWuQiFuPart.OnCtrlItemEvent(self, oCtrl)

	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
		self:RefreshJiPin()
		self:RefreshBtnState()
	end

end 

function CDuanWuQiFuPart.OnSubmit(self)

	local isHadJiPin = g_DuanWuHuodongCtrl:IsHadJiPin()
	if isHadJiPin then 
		g_DuanWuHuodongCtrl:C2GSDuanwuQifuSubmit()
	else
		g_NotifyCtrl:FloatMsg("暂无祭品可提交")
	end 

end 

function CDuanWuQiFuPart.OnClickInfoBtn(self)
	
	local id = define.Instruction.Config.QiFu
	if data.instructiondata.DESC[id] ~= nil then 

	    local content = {
	        title = data.instructiondata.DESC[id].title,
	        desc  = data.instructiondata.DESC[id].desc
	    }
	    g_WindowTipCtrl:SetWindowInstructionInfo(content)

	end 

end

function CDuanWuQiFuPart.OnClickJiPin(self, item, info)
	
	local sid = info.sid
	local config = {widget = item}
	g_WindowTipCtrl:SetWindowItemTip(sid, config)

end

return CDuanWuQiFuPart
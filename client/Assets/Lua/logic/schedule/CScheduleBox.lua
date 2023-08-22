local CScheduleBox = class("CScheduleBox", CBox)
-- 一个函数写了活动页签，活动预告  有点乱
function CScheduleBox.ctor(self, obj, cb, closecb)
	CBox.ctor(self, obj)
	self.m_CallBack = cb
	self.m_CloseCallBack = closecb
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_ItemName = self:NewUI(2, CLabel)
	self.m_JoinBtn = self:NewUI(3, CButton)
	self.m_TipsSprite = self:NewUI(4, CSprite)
	self.m_TipsLabel = self:NewUI(5, CLabel)
	self.m_Count = self:NewUI(6, CLabel)
	self.m_Active = self:NewUI(7, CLabel)
	self.m_Sign = self:NewUI(8, CSprite)
	self.m_BoxBtn = self:NewUI(9, CButton, true, false)
	self.m_BoxBtn.m_IgnoreCheckEffect = true
	self.m_RedPoint = self:NewUI(10, CSprite)
	self.m_SignLbl = self:NewUI(11, CLabel)

	self.m_Icon:AddUIEvent("click", callback(self, "OnClickBoxBtn"))
	self.m_JoinBtn:AddUIEvent("click", callback(self, "OnClickJoinBtn"))
	self.m_ScheduleInfo = nil
	self.m_scheduleType = nil

	self.m_SignColorDic = {
		red = {sprite = "h7_jiaobiao_hong", shadow = "7c1526"},
		green = {sprite = "h7_jiaobiao_lv", shadow = "116957"},
		purple = {sprite = "h7_jiaobiao_zi", shadow = "6e1585"},
		blue = {sprite = "h7_jiaobiao_lan", shadow = "094f69"}, 
	}
end

function CScheduleBox.OnClickBoxBtn(self)
	self:HideRedPoint()
	self:SetEffect(false, true)
	if self.m_CallBack then
		self.m_CallBack(self.m_ScheduleInfo, true)
	end
end

function CScheduleBox.OnClickJoinBtn(self)
	self:HideRedPoint()

	self:SetEffect(false, true)
	printc("TODO >>> 点击按钮参加活动,跳到具体活动逻辑（寻路，打开界面，xxx ...）")
	g_ScheduleCtrl:JoinBtnCB(self.m_ScheduleInfo)
	if self.m_CloseCallBack then
		self.m_CloseCallBack()
	end
end
function CScheduleBox.HideRedPoint(self )
	-- body
	if g_ScheduleCtrl:IsUnExistEffRecordID(self.m_ScheduleInfo.id) then
		table.insert(g_ScheduleCtrl.m_ScheduleEffRecord, self.m_ScheduleInfo.id)
		g_ScheduleCtrl:SaveScheduleEffRecord(g_ScheduleCtrl.m_ScheduleEffRecord)
	end
	local showRedPoint =  g_ScheduleCtrl:IsUnExistEffRecordID(self.m_ScheduleInfo.id)
	self.m_RedPoint:SetActive(showRedPoint)
end

function CScheduleBox.SetScheduleBox(self, scheduleInfo, scheduleType)
	self.m_ScheduleInfo = scheduleInfo
	self.m_scheduleType = scheduleType
	
	self.m_Icon:SpriteItemShape(tonumber(scheduleInfo.icon))
	self.m_ItemName:SetText(scheduleInfo.name)

	if define.Schedule.Sign.ShowNewSign then
		local dColor = scheduleInfo.color
		local signInfo = self.m_SignColorDic[dColor]
		if signInfo then
			self.m_Sign:SetSpriteName(signInfo.sprite)
			self.m_SignLbl:SetText(scheduleInfo.label)

			self.m_SignLbl:SetEffectColor(Color.RGBAToColor(signInfo.shadow)) 
		else
			self.m_Sign:SetSpriteName("")
			self.m_SignLbl:SetText("")
		end
	else
		self.m_Sign:SetSpriteName(scheduleInfo.jiaobiao)
		self.m_Sign:MakePixelPerfect()
	end
	
	self:RefreshTimesAndActive()
end

function CScheduleBox.RefreshTimesAndActive(self, isLimitSign)
	local countStr = "次数:不限"
	local maxtimes = self.m_ScheduleInfo.maxtimes
	local scheduleData = g_ScheduleCtrl:GetScheduleData(self.m_ScheduleInfo.id)
	if scheduleData then
		maxtimes = scheduleData.maxtimes
	end

	if maxtimes > 0 then
		countStr = string.format("次数:%d/%d", scheduleData and scheduleData.times or 0, maxtimes)
	end
	self.m_Count:SetText(countStr)
	local maxpointStr = "活跃:无"
	if self.m_ScheduleInfo.maxpoint > 0 then
		maxpointStr = string.format("活跃:%d/%d", scheduleData and scheduleData.activepoint or 0, self.m_ScheduleInfo.maxpoint)
	end
	self.m_Active:SetText(maxpointStr)
	local objNameType = 1
	local limitState = 0
	local showJoinBtn = false
	local activeFinish = false
	local activeTime = false
	local showEffect = false
	local isUnopen = self.m_scheduleType == define.Schedule.Type.Unopen

	local isLimit = self.m_scheduleType == define.Schedule.Type.Limit
	local checkHeroTrial = self:IsHeroTrial()--false
	local isIntPtScheudle = g_ScheduleCtrl:IsIntPointSchedule(self.m_ScheduleInfo.id)

	if isUnopen then 
		objNameType = "即将开启"
		self.m_TipsLabel:SetText(self.m_ScheduleInfo.level .. "级开启")
	else   
		if scheduleData and scheduleData.maxtimes > 0 and scheduleData.times >= scheduleData.maxtimes then
			activeFinish = true
			-- -- 英雄试炼需检测奖励领取
			-- if scheduleData.scheduleid == 1027 then
			-- 	checkHeroTrial = true
			-- end
		else
			if isLimit then 
				objNameType = "限时活动"
				local limitScheduelData = nil
				if isIntPtScheudle then
					limitScheduelData = g_ScheduleCtrl:GetScheduleInfo(self.m_ScheduleInfo.id)
					limitScheduelData.state = 1
				else
					limitScheduelData = g_ScheduleCtrl:GetPreviewScheduleData(self.m_ScheduleInfo.id)
				end
				if not limitScheduelData then
					printerror("错误：未找到活动数据，活动ID:", self.m_ScheduleInfo.id)
					return
				end
				limitState = limitScheduelData.state
				if limitState == 1 then
					-- 准备
					activeTime = true
					local tipStr = isIntPtScheudle and "整点刷新" or "时间:" .. limitScheduelData.time
					self.m_TipsLabel:SetText(tipStr)

				elseif limitState == 2 then
					-- 正在进行中的活动（进行中标识，特效环绕）
					showJoinBtn = true
					showEffect = true
					self.m_Sign:SetSpriteName("h7_jinxingzhong")
					self.m_SignLbl:SetText("")
					self.m_Sign:MakePixelPerfect()
				elseif limitState == 3 then
					-- 结束
					self.m_TipsLabel:SetText("已结束");
				elseif limitState == 4 then
					--删除
					self:SetActive(false)
					return
				end
			else
				objNameType = "日常活动"
				showJoinBtn = true
			end
		end
	end

	self.m_JoinBtn:SetActive(showJoinBtn)

	self.m_TipsLabel:SetActive(not showJoinBtn and not activeFinish)
	if isIntPtScheudle  then
		self.m_TipsSprite:SetActive(true)
	else
		self.m_TipsSprite:SetActive(not showJoinBtn and not activeTime)
	end
	self.m_TipsSprite:SetSpriteName((not showJoinBtn and activeFinish) and "h7_yiwancheng" or "h7_100jikaiqi")
	self.m_TipsSprite:MakePixelPerfect()

	self:SetEffect(showEffect, false)

	local objName = string.format("ScheduleBox_%s_%s_%s_%s", objNameType, limitState, self.m_ScheduleInfo.id, self.m_ScheduleInfo.name)
	self:SetName(objName)

	local showRedPoint = self:HasRedPoint()

	self.m_RedPoint:SetActive(showRedPoint)

	if checkHeroTrial then
		self:HandleHeroTrial()
	end
end

function CScheduleBox.HasRedPoint(self)
	local isUnopen = self.m_scheduleType == define.Schedule.Type.Unopen
	local bRedPt = not isUnopen and g_ScheduleCtrl:IsUnExistEffRecordID(self.m_ScheduleInfo.id)
	if self:IsHeroTrial() then
		bRedPt = bRedPt or g_HeroTrialCtrl:HasReward()
	end
	return bRedPt or false
end

function CScheduleBox.SetEffect(self, RectPoint, bThrowEvent)
	-- body
	-- RectPoint = false时， 红点保存，环绕保存
	if  RectPoint == false then
		g_ScheduleCtrl:DelRectEff(self.m_ScheduleInfo.id)
	end
	if not g_ScheduleCtrl.m_RectEffRecord[self.m_ScheduleInfo.id] then
		self.m_BoxBtn:DelEffect("Rect2")
	end
	if RectPoint == true and g_ScheduleCtrl.m_RectEffRecord[self.m_ScheduleInfo.id] then
		self.m_BoxBtn:AddEffect("Rect2")
	end
	-- 点击时才抛出事件
	if bThrowEvent then
		g_ScheduleCtrl:OnEvent(define.Schedule.Event.ClearEffect, self.m_ScheduleInfo.id)
	end
	
end

function CScheduleBox.GetScheduleBoxScheduleID(self)
	if self.m_ScheduleInfo and self:GetActive() then
		return self.m_ScheduleInfo.id
	end
end

function CScheduleBox.SetSelected(self, b)
	self.m_SelectedSpr:SetActive(b)
end

function CScheduleBox.LimitScheduleID(self)
	return self.m_ScheduleInfo.id
end

function CScheduleBox.RedPointInfo(self, isShow)
	--非日常活动的红点全部隐藏
	-- if isShow then
	-- 	if self.m_ScheduleInfo.type~= 1 and self.m_ScheduleInfo.id~=1009 then
	-- 		self.m_RedPoint:SetActive(false)
	-- 		if g_ScheduleCtrl:IsUnExistEffRecordID(self.m_ScheduleInfo.id) then
	-- 			table.insert(g_ScheduleCtrl.m_ScheduleEffRecord, self.m_ScheduleInfo.id)
	-- 			g_ScheduleCtrl:SaveScheduleEffRecord(g_ScheduleCtrl.m_ScheduleEffRecord)
	-- 		end
	-- 	end
	-- end
end

function CScheduleBox.IsHeroTrial(self)
	return self.m_ScheduleInfo.id == 1027
end

function CScheduleBox.RefreshHeroTrial(self)
	self.m_JoinBtn:SetActive(true)
	self.m_TipsSprite:SetActive(false)
	local bRedPt = self:HasRedPoint()
	self.m_RedPoint:SetActive(bRedPt)
end

function CScheduleBox.HandleHeroTrial(self)
	if g_HeroTrialCtrl.m_IsFinish == nil and not self.m_HasCheckTrial then
		g_HeroTrialCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHeroTrialCtrlEvent"))
		g_HeroTrialCtrl:CheckTrialInfo()
		self.m_HasCheckTrial = true
	elseif g_HeroTrialCtrl.m_IsFinish == false then
		self:RefreshHeroTrial()
	end
end

function  CScheduleBox.OnHeroTrialCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.HeroTrial.Event.CheckIsFinish then
		if false == oCtrl.m_EventData then
			self:RefreshHeroTrial()
		end
	end
end

return CScheduleBox
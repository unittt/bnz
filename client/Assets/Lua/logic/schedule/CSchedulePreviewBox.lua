local CSchedulePreviewBox = class("CSchedulePreviewBox", CBox)

function CSchedulePreviewBox.ctor(self, obj, cb, closecb)
	-- body
	CBox.ctor(self, obj)
	self.m_Name = self:NewUI(1, CLabel)
	self.m_JoinBtn  = self:NewUI(2, CButton)
	self.m_TipSprite = self:NewUI(3, CSprite)
	self.m_TipLabel  = self:NewUI(4, CLabel)
	self.m_BoxBtn = self:NewUI(5, CSprite)
	self.m_RedPoint = self:NewUI(6, CSprite)
	self.m_Texture = self:NewUI(7, CTexture)
	self.m_CallBack = cb
	self.m_CloseCallBack = closecb
	self.m_ScheduleInfo = nil
	self.m_scheduleType = nil
end

function CSchedulePreviewBox.SetScheduleBox(self, scheduleInfo, scheduleType)
	-- body
	self.m_ScheduleInfo = scheduleInfo
	self.m_scheduleType = scheduleType
	if scheduleInfo.texture ~= "" then
		local sTextureName = "Texture/Schedule/"..scheduleInfo.texture..".png"
		g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetTexture"))
	else
		printerror("警告:请策划配置活动：" .. scheduleInfo.name .. "的美术图片，未配置情况下使用默认图片！配置表：https://nsvn.cilugame.com/H7/doc/trunk/daobiao/excel/schedule/schedule.xlsx")
	end

	self.m_BoxBtn:AddUIEvent("click", callback(self, "OnClickBoxBtn"))
	self.m_JoinBtn:AddUIEvent("click", callback(self, "OnClickJoinBtn"))

	self.m_Name:SetText(scheduleInfo.name)

	self:RefreshTimesAndActive()
end

function CSchedulePreviewBox.SetTexture(self,  prefab, errcode)
	-- body
	if prefab then
		self.m_Texture:SetMainTexture(prefab)
	else
		print(errcode)
	end
end

function CSchedulePreviewBox.OnClickBoxBtn(self)
	-- body
	self:HideRedPoint()
	self:SetEffect(false, true)
	if self.m_CallBack then
		self.m_CallBack(self.m_ScheduleInfo, true)
	end
end

function CSchedulePreviewBox.OnClickJoinBtn(self)
	-- body
	self:HideRedPoint()
	self:SetEffect(false, true)
	g_ScheduleCtrl:JoinBtnCB(self.m_ScheduleInfo)
	self.m_CloseCallBack()
end
function CSchedulePreviewBox.HideRedPoint(self )
	-- body
	if g_ScheduleCtrl:IsUnExistEffRecordID(self.m_ScheduleInfo.id) then
		table.insert(g_ScheduleCtrl.m_ScheduleEffRecord, self.m_ScheduleInfo.id)
		g_ScheduleCtrl:SaveScheduleEffRecord(g_ScheduleCtrl.m_ScheduleEffRecord)
	end
	local showRedPoint =  g_ScheduleCtrl:IsUnExistEffRecordID(self.m_ScheduleInfo.id)
	self.m_RedPoint:SetActive(showRedPoint)
end
function CSchedulePreviewBox.RefreshTimesAndActive(self)
	-- body
	local showJoinBtn = false  -- 進行中  
	-- local activeFinish = false -- 已結束  
	-- local activeTime = false -- 未開啟  tiplabel,tipsprite
	local showEffect = false  -- 環繞特效 

	local limitScheduelData = g_ScheduleCtrl:GetPreviewScheduleData(self.m_ScheduleInfo.id)

	if not limitScheduelData then
		printerror("错误：未找到活动数据，活动ID:", self.m_ScheduleInfo.id)
		return
	end
	local limitState = limitScheduelData.state
	if limitState == 1 then
		-- 准备
		-- activeTime = true
		local tipStr = "时间:" .. limitScheduelData.time
		self.m_TipLabel:SetText(tipStr)
	elseif limitState == 2 then
		-- 正在进行中的活动（进行中标识，特效环绕）
		showJoinBtn = true
		showEffect = true
	elseif limitState == 3 then
		-- 结束
		-- activeFinish = true
		self.m_TipLabel:SetText("已结束") 
	elseif limitState == 4 then
		--删除
		self:SetActive(false)
		return
	end

	self.m_RedPoint:SetActive(g_ScheduleCtrl:IsUnExistEffRecordID(self.m_ScheduleInfo.id))
	
	self.m_JoinBtn:SetActive(showJoinBtn)
	
	self.m_TipLabel:SetActive(not showJoinBtn)
	self.m_TipSprite:SetActive(not showJoinBtn)

	self:SetEffect(showEffect , false)
end

function CSchedulePreviewBox.SetEffect(self, RectPoint, bThrowEvent)
	-- body
	-- RectPoint = false时， 红点保存，环绕保存
	if not RectPoint then
		g_ScheduleCtrl:DelRectEff(self.m_ScheduleInfo.id)
	end
	if not g_ScheduleCtrl.m_RectEffRecord[self.m_ScheduleInfo.id] then
		self.m_BoxBtn:DelEffect("Rect3")
	end
	if RectPoint and g_ScheduleCtrl.m_RectEffRecord[self.m_ScheduleInfo.id] then
		self.m_BoxBtn:AddEffect("Rect3")
	end
	-- 点击时才抛出事件
	if bThrowEvent then
		g_ScheduleCtrl:OnEvent(define.Schedule.Event.ClearEffect, self.m_ScheduleInfo.id)
	end
	local showRedPoint =  g_ScheduleCtrl:IsUnExistEffRecordID(self.m_ScheduleInfo.id)

	self.m_RedPoint:SetActive(showRedPoint)
end

function CSchedulePreviewBox.LimitScheduleID(self)
	return self.m_ScheduleInfo.id
end


return CSchedulePreviewBox
local CSpeechRecordView = class("CSpeechRecordView", CViewBase)

function CSpeechRecordView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Audio/SpecchRecordView.prefab",cb)
end

--创建界面完毕回调
function CSpeechRecordView.OnCreateView(self)
	self.m_RecordWidget = self:NewUI(1, CWidget)
	self.m_CacelWidget = self:NewUI(2, CWidget)
	self.m_VolumeSpr = self:NewUI(3, CSprite)
	self.m_RecordBtnRef = nil
	self.m_Channel = nil
	self.m_Pid = nil
	self.m_Barrage = nil
	self.m_Bottle = nil
	self.m_RecordView = nil
end

--开始语音录制接口
function CSpeechRecordView.BeginRecord(self, iChannel, iPid, iBarrage ,oView, timeoutTime)
	printc("CSpeechRecordView.BeginRecord")
	self.m_Channel = iChannel
	self.m_Pid = iPid
	self.m_Barrage = iBarrage
	local args = {channel = iChannel, pid = iBarrage, barrage = iBarrage}
	self:BeginRecordWithArgs(args, oView, timeoutTime)
end

function CSpeechRecordView.BeginRecordWithArgs(self, args, oView, timeoutTime)
	local function delay()
		if Utils.IsNil(self) then
			return false
		end
		self.m_Channel = args.channel
		self.m_Pid = args.pid
		self.m_Barrage = args.barrage
		self.m_Bottle = args.bottle
		self.m_RecordView = oView
		self:ShowRecord()
		g_SpeechCtrl:StartRecord()
		if self.m_CheckTimer then
			Utils.DelTimer(self.m_CheckTimer)
			self.m_CheckTimer = nil			
		end
		self.m_CheckTimer = Utils.AddTimer(callback(self, "CheckRecord"), 0, 0)
		self:RecordTimeOut(timeoutTime)
		return false
	end

	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
		self.m_DelayTimer = nil			
	end
	self.m_DelayTimer = Utils.AddTimer(delay, 0, 0.5)
end

function CSpeechRecordView.RecordTimeOut(self, timeoutTime)
	--超过录音30s自动结束录制
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil			
	end
	local timeCount = 0
	local totalCount = (timeoutTime)/define.Treasure.Time.Delta
	local function progress()
		if g_ChatCtrl.m_IsChatRecording then
			-- printc("CSpeechRecordView RecordTimeOut")
			timeCount = timeCount + 1
			if timeCount >= totalCount then
				-- if self.m_Channel and not self.m_Pid then
				-- 	if self:EndRecord(self.m_Channel, nil, nil) then
				-- 		--发送语音后解除锁屏状态
				-- 		if self.m_RecordView then
				-- 			self.m_RecordView:ShowNewMsg()
				-- 		end
				-- 	end
				-- elseif not self.m_Channel and self.m_Pid then
				-- 	if self:EndRecord(nil, self.m_Pid, nil) then
				-- 		--发送语音后解除锁屏状态
				-- 		if self.m_RecordView then
				-- 			self.m_RecordView:ReadAll()
				-- 		end
				-- 	end
				-- end
				g_ChatCtrl.m_IsChatRecording = false
				if self.m_Timer then
					Utils.DelTimer(self.m_Timer)
					self.m_Timer = nil			
				end
			end
		else
			if self.m_Timer then
				Utils.DelTimer(self.m_Timer)
				self.m_Timer = nil			
			end
		end
		return true
	end
	self.m_Timer = Utils.AddTimer(progress, 0.02, 0.02)
end

--结束语音录制接口，注意如果是给聊天频道使用则iChannel设值，iPid为nil，如果是给好友聊天使用则iChannel设nil，iPid设值
function CSpeechRecordView.EndRecord(self, iChannel, iPid, iBarrage , cb, sendCb)
	printc("CSpeechRecordView.EndRecord")	
	local args = {channel = iChannel, pid = iPid, barrage = iBarrage}
	local bIsSuccess = self:EndRecordWithArgs(args, cb, sendCb)
	return bIsSuccess
end

function CSpeechRecordView.EndRecordWithArgs(self, args, cb, sendCb)
	local bIsSuccess = false
	local key = g_SpeechCtrl:EndRecord()
	if key and self.m_RecordWidget:GetActive() then
		local path = g_SpeechCtrl:SaveToAmr(key)
		if path then
			g_SpeechCtrl:UploadToServer(key, path, args, sendCb)
			g_SpeechCtrl:TranslateFromServer(key, path, cb)
			bIsSuccess = true
		end
	end
	self:CloseView()
	g_NotifyCtrl:ShowDisableWidget(false)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil			
	end
	if self.m_CheckTimer then
		Utils.DelTimer(self.m_CheckTimer)
		self.m_CheckTimer = nil			
	end
	return bIsSuccess
end

----------------以下是这个界面ui相关-----------------

function CSpeechRecordView.ShowRecord(self)
	self.m_RecordWidget:SetActive(true)
	self.m_CacelWidget:SetActive(false)
end

function CSpeechRecordView.ShowCancel(self)
	self.m_RecordWidget:SetActive(false)
	self.m_CacelWidget:SetActive(true)
end

function CSpeechRecordView.SetRecordBtn(self, oBtn)
	self.m_RecordBtnRef = weakref(oBtn)
end

function CSpeechRecordView.GetRecordBtn(self)
	return getrefobj(self.m_RecordBtnRef)
end

function CSpeechRecordView.CheckRecord(self)
	if g_ChatCtrl.m_IsChatRecording then
		-- printc("CheckRecord")
		local oBtn = self:GetRecordBtn()
		--显示录制或取消录制界面
		if oBtn then
			local worldPos = g_CameraCtrl:GetNGUICamera().lastWorldPosition
			if oBtn:IsInRect(worldPos) then
				self:ShowRecord()
			else
				self:ShowCancel()
			end
		end
		--根据语音的音量大小通过一个计时器持续的改变m_VolumeSpr图片
		local iVolume = g_SpeechCtrl:GetRecordVolume()
		self.m_VolumeSpr:SetFillAmount(iVolume)		
	else
		if self.m_Channel and not self.m_Pid then
			if self:EndRecord(self.m_Channel, nil, nil) then
				--发送语音后解除锁屏状态
				if self.m_RecordView then
					self.m_RecordView:ShowNewMsg()
				end
			end
		elseif not self.m_Channel and self.m_Pid then
			if self:EndRecord(nil, self.m_Pid, nil) then
				--发送语音后解除锁屏状态
				if self.m_RecordView then
					self.m_RecordView:ReadAll()
				end
			end
		elseif self.m_Barrage then
			self:EndRecord(nil, nil, self.m_Barrage)
		elseif self.m_Bottle then
			printc("CheckRecord self.m_Bottle")
			if self:EndRecordWithArgs({bottle = self.m_Bottle}) then
				-- g_WishBottleCtrl:UpdateBottleId(-1)
			end
		end
	end
	return true
end


return CSpeechRecordView
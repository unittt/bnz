local CMysticalBoxCtrl = class("CMysticalBoxCtrl", CCtrlBase)

function CMysticalBoxCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Clear()
end

function CMysticalBoxCtrl.Clear(self)
	self.m_open_time = 0
	self.m_open_state = 0
	self.m_time = ""
	self.m_leftTime = 1
	self.m_curLeftTime = 1
end


function CMysticalBoxCtrl.OnShowMysticalBoxView(self)
	CMysticalBoxView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

function CMysticalBoxCtrl.GS2CMysticalboxGetState(self, data)
	--printc("111111111 CMysticalBoxCtrl.GS2CMysticalboxGetState  data.state:", data.state, "  data.open_time:", data.open_time)
	if data.state == 1 then
		self.m_open_state = 1
		self.m_open_time = 0
		self.m_leftTime = 1
		self.m_curLeftTime = 1

		--抛出事件
		--printc("22222222 OnEvent", define.MysticalBox.Event.MysticalBoxStart)
		self:OnEvent(define.MysticalBox.Event.MysticalBoxStart, self)

		g_GuideCtrl:OnTriggerAll()
	elseif data.state == 2 then
		self.m_open_state = 2
		self.m_open_time = data.open_time
		local leftTime = data.open_time - g_TimeCtrl:GetTimeS()
		self.m_leftTime = leftTime
		self.m_curLeftTime = leftTime

		if leftTime <= 0 then
            self.m_time = g_TimeCtrl:GetLeftTime(0)
            self.m_curLeftTime = 0
            g_TimeCtrl:DelTimer(self)

            --printc("3333333 leftTime:", self.m_time, " OnEvent:MysticalBoxTimeOut")

            --抛出事件
			self:OnEvent(define.MysticalBox.Event.MysticalBoxRefreshTime, self)
			self:OnEvent(define.MysticalBox.Event.MysticalBoxTimeOut, self)
			self:OnEvent(define.MysticalBox.Event.MysticalBoxRefreshRedPoint, self)
		else
			--printc("4444444 leftTime:", leftTime, " OnEvent:MysticalBoxRefreshTime")
		    g_TimeCtrl:StartCountDown(self, leftTime, 4, callback(self, "MysticalBoxRefreshTime"))
		end
		
		--抛出事件
		self:OnEvent(define.MysticalBox.Event.MysticalBoxRefreshMainBtn, self)
	elseif data.state == 3 then
		self.m_open_state = data.state
		self.m_open_time = 0
		self.m_leftTime = 1
		self.m_curLeftTime = 1

		--printc("555555 m_open_state:", self.m_open_state)

		--抛出事件
		self:OnEvent(define.MysticalBox.Event.MysticalBoxRefreshMainBtn)
		self:OnEvent(define.MysticalBox.Event.MysticalBoxRefreshRedPoint, self)
		self:OnEvent(define.MysticalBox.Event.MysticalBoxRefreshEnd, self)
	end
end 


function CMysticalBoxCtrl.MysticalBoxRefreshTime(self, time)
	--printc("-----------------MysticalBoxRefreshTime:", time)
	self.m_curLeftTime = self.m_curLeftTime - 1

	if time == nil then
		self.m_time = "00:00"
		self.m_leftTime = 0

		--抛出事件
		self:OnEvent(define.MysticalBox.Event.MysticalBoxRefreshTime, self)
		self:OnEvent(define.MysticalBox.Event.MysticalBoxTimeOut, self)
		self:OnEvent(define.MysticalBox.Event.MysticalBoxRefreshRedPoint, self)
	else
		self.m_time = time
		--抛出事件
		self:OnEvent(define.MysticalBox.Event.MysticalBoxRefreshTime, self)
	end
end


function CMysticalBoxCtrl.CheckIsMysticalBoxOpen(self)
	return g_OpenSysCtrl:GetOpenSysState(define.System.MysticalBox) and (self.m_open_state == 1 or self.m_open_state == 2)
	--return self.m_open_state == 1 or self.m_open_state == 2
end

function CMysticalBoxCtrl.CheckIsMysticalBoxGuideOpen(self)
	return g_OpenSysCtrl:GetOpenSysState(define.System.MysticalBox) and (self.m_open_state == 1)
	--return self.m_open_state == 1 or self.m_open_state == 2
end


function CMysticalBoxCtrl.CheckIsMysticalBoxRedPoint(self)
	--printc("CheckIsMysticalBoxRedPoint m_leftTime:", self.m_leftTime, " m_open_state:", self.m_open_state)
	if self.m_open_state ~= nil and self.m_open_state == 2 and self.m_leftTime <= 0 then
		return true
	else
		return false
	end
end

function CMysticalBoxCtrl.CheckIsMysticalBoxTime(self)
	--printc("CheckIsMysticalBoxTime m_leftTime:", self.m_leftTime, " m_open_state:", self.m_open_state)
	if self.m_open_state ~= nil and self.m_open_state == 2 and self.m_leftTime > 0 then
		return true
	else
		return false
	end
end

function CMysticalBoxCtrl.CheckIsMysticalBoxLingQu(self)
	--printc("CheckIsMysticalBoxLingQu m_leftTime:", self.m_leftTime, " m_open_state:", self.m_open_state)
	if self.m_open_state ~= nil and self.m_open_state == 2 and self.m_leftTime <= 0 then
		return true
	else
		return false
	end
end


return CMysticalBoxCtrl
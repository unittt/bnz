local CTreasureSliderView = class("CTreasureSliderView", CViewBase)

function CTreasureSliderView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Treasure/TreasureSliderView.prefab", cb)
	self.m_DepthType = "Dialog"
	-- self.m_ExtendClose = "ClickOut"
	self.m_TimeCount = 0
end

function CTreasureSliderView.OnCreateView(self)
	self.m_TipWidget = self:NewUI(1, CWidget)
	self.m_Slider= self:NewUI(2, CSlider)
	self:OnShowProgress()

	g_TreasureCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTreasureEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvent"))

	-- self.m_TipWidget:AddUIEvent("click", callback(self, "OnFailClose"))
end

function CTreasureSliderView.OnCtrlTreasureEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Treasure.Event.SliderBroken then
		self:OnFailClose()
	end
end

function CTreasureSliderView.OnWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.WarStart or oCtrl.m_EventID == define.War.Event.WarEnd then
		if g_WarCtrl:IsWar() then
			self:OnFailClose()
		end
	end
end

--设置挖宝的id，数据在CMapCtrl.AutoFindPath的callbackinfo
function CTreasureSliderView.SetCallback_sessionidx(self,Callback_sessionidx)
	self.m_Callback_sessionidx = Callback_sessionidx
end

--进行读条表现
function CTreasureSliderView.OnShowProgress(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil			
	end
	self.m_TimeCount = 0
	
	local totalCount = define.Treasure.Time.Total/define.Treasure.Time.Delta
	local isUpdate = false
	local function progress()
		isUpdate = true
		self.m_TimeCount = self.m_TimeCount + 1
		self.m_Slider:SetValue(self.m_TimeCount/totalCount)
		if self.m_TimeCount >= totalCount then
			self:OnFinish()
			isUpdate = false
		end
		return isUpdate
	end
	self.m_Timer = Utils.AddTimer(progress, 0.02, 0.02)
end

--挖宝读条结束
function CTreasureSliderView.OnFinish(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil			
	end
	self.m_TimeCount = 0
	self:OnSuccessClose()
end

--挖宝成功
function CTreasureSliderView.OnSuccessClose(self)
	printc("挖宝成功了")
	if self.m_Callback_sessionidx then
		netother.C2GSCallback(self.m_Callback_sessionidx)
	end
	self:OnClose()
end

--挖宝不成功
function CTreasureSliderView.OnFailClose(self)
	printc("挖宝不成功")
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil			
	end
	self.m_TimeCount = 0
	self:OnClose()
end

return CTreasureSliderView
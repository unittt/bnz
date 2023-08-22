local CDancingActivityView = class("CDancingActivityView", CViewBase)

function CDancingActivityView.ctor(self,cb)
	CViewBase.ctor(self, "UI/Activity/DancingAction.prefab",cb)
	--self.m_ExtendClose = "Shelter"
	self.activityId = 1016  --舞会活动id
end

function CDancingActivityView.OnCreateView(self)
	self.m_Dancingtime = self:NewUI(1, CLabel) --舞会时间
	self.m_DancingSlider = self:NewUI(2, CSlider) --
	self.m_AttendNum = self:NewUI(3, CLabel)
	self.m_ExitButton = self:NewUI(4, CButton)

	self.m_HappySlider = self:NewUI(5, CSlider)
	self.m_HappyValueLabel = self:NewUI(6, CLabel)
	self.m_HappyButton = self:NewUI(7, CTexture)
	self.m_DancingUI = self:NewUI(8, CObject)
	self.m_HappyUI = self:NewUI(9, CObject)

	self.m_HappyUI:SetActive(false)
	
	self:InitContent()
end 

function CDancingActivityView.InitContent(self)
	self.m_ExitButton:AddUIEvent("click", callback(self, "OnExit")) 
	self.m_HappyButton:AddUIEvent("click", callback(self, "OnHappy"))
	self.tActivity = data.scheduledata.SCHEDULE[self.activityId]
	self.tDancing = data.dancedata.CONDITION[1]

	self.tHappyValue = 30
	self.tDancingTime = self.tDancing.len
	self.click_num = 0

	g_DancingCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	if g_DancingCtrl.m_DanceLeftTime <= 0 then
		self:CloseView()
	else
		self.m_Dancingtime:SetText("当前剩余时间："..g_DancingCtrl.m_DanceLeftTime.."s")
		self.m_DancingSlider:SetValue((self.tDancingTime - g_DancingCtrl.m_DanceLeftTime)/self.tDancingTime)
	end
end

function CDancingActivityView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Dancing.Event.DanceCount then
		self.m_Dancingtime:SetText("当前剩余时间："..g_DancingCtrl.m_DanceLeftTime.."s")
		self.m_DancingSlider:SetValue((self.tDancingTime - g_DancingCtrl.m_DanceLeftTime)/self.tDancingTime)
	end
end

function CDancingActivityView.OnHideView(self)
	if g_DancingCtrl.m_DanceLeftTime > 0 then
		CDancingActivityView:ShowView()
	end
end

------------------下边暂时没用-----------------

--刷新舞会ui
function CDancingActivityView.RefreshDancing(self, num, dancing_time)
	self:ShowUI(true)
	g_DancingCtrl:AddTip()
	self.m_AttendNum:SetText("今日可参与次数："..num.."/"..self.tActivity.maxtimes)
	local totalTime = dancing_time
	if self.dancingTimer then
		Utils.DelTimer(self.dancingTimer)
		self.dancingTimer = nil
	end
	local Refresh = function()
	if totalTime <= 0 then
		g_DancingCtrl:DelTip()
		g_DancingCtrl.m_StateInfo = nil
		 -- g_DancingCtrl:OnEvent(define.Dancing.Event.dancingEnd)
		 self:CloseView()
		 return false
		end
		if not Utils.IsNil(self) then
			self.m_Dancingtime:SetText("当前剩余时间："..totalTime.."s")
			self.m_DancingSlider:SetValue((self.tDancingTime-totalTime)/self.tDancingTime)
		end
		totalTime = totalTime - 1
		return true
	end
	self.dancingTimer = Utils.AddTimer(Refresh, 1, 0)
end

--刷新动感时刻
function CDancingActivityView.RefreshHappyUI(self,happy_value)
	local happy_value = happy_value or self.happyValue
	self.m_HappyValueLabel:SetText("动感值："..happy_value.."/"..self.tHappyValue)
	self.m_HappySlider:SetValue((self.tHappyValue - happy_value)/self.tHappyValue)
end

--点击退出舞会
function CDancingActivityView.OnExit(self)
	--printc("点击退出---")
	local closeUI = function () 
		g_DancingCtrl:DelTip()
		self:CloseView()  --关闭ui
		nethuodong.C2GSDanceEnd()  --通知服务器退出舞会
		if self.dancingTimer then
			Utils.DelTimer(self.dancingTimer)
			self.dancingTimer = nil
		end
	end
	local windowConfirmInfo = {
		msg = "当前舞会尚未结束，退出会消耗参与\n机会和邀请函，确定要离开么",
		okCallback = closeUI,
		pivot = enum.UIWidget.Pivot.Center  
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CDancingActivityView.OnHappy(self)
	--printc("将点击发给服务器")
	if self.click_num > 30 then
		return
	end
	self.click_num = self.click_num + 1
	nethuodong.C2GSDanceInspired()
	g_NotifyCtrl:FloatMsg("+"..self.tDancing.happyValue)
end

function CDancingActivityView.ShowUI(self, bShow)
	self.m_DancingUI:SetActive(bShow)
	self.m_HappyUI:SetActive(not bShow)
end

return CDancingActivityView
local CProgressBox = class("CProgressBox", CBox)

function CProgressBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_FillSprite = self:NewUI(1, CSprite)
	self.m_TipLabel = self:NewUI(2, CLabel)
	self.m_BoxCollider = self:NewUI(3, CWidget)
	self.m_Slider = self:NewUI(4, CSlider)

	self.m_PastTime = 0
	self.m_WaitTime = 0
	self.m_HideFun  = nil
	self.m_CancelFunc = nil

	self.m_BoxCollider:AddUIEvent("click", callback(self, "OnClickTrigger"))
end

function CProgressBox.SetProgress(self, sTip, waitTime, hideFun, pastTime, cancelFunc)
	self.m_PastTime = pastTime or 0
	self.m_WaitTime = waitTime or 3
	self.m_HideFun = hideFun
	self.m_CancelFunc = cancelFunc

	self.m_TipLabel:SetText(sTip or "进行中...")
	-- self.m_FillSprite:SetFillAmount(0.1)
	self.m_Slider:SetValue(0.1)

	if self.m_ProgressTimer then
		Utils.DelTimer(self.m_ProgressTimer)
		self.m_ProgressTimer = nil
	end
	self.m_ProgressTimer = Utils.AddTimer(callback(self, "UpdateProgress"), 0.03, 0)
end

function CProgressBox.UpdateProgress(self, t)
	self.m_PastTime = self.m_PastTime + t
	if self.m_PastTime > self.m_WaitTime then
		-- self.m_FillSprite:SetFillAmount(1)
		self.m_Slider:SetValue(1)
		if self.m_HideFun then
			self.m_HideFun()
		end
		return false
	else
		-- self.m_FillSprite:SetFillAmount(self.m_PastTime/self.m_WaitTime)
		self.m_Slider:SetValue(self.m_PastTime/self.m_WaitTime)
		return true
	end
end

function CProgressBox.ResetTimer(self)
	if self.m_ProgressTimer then
		Utils.DelTimer(self.m_ProgressTimer)
		self.m_ProgressTimer = nil
	end
end

function CProgressBox.OnClickTrigger(self)
	if self.m_CancelFunc then
		self.m_CancelFunc()
	end
end

return CProgressBox


local CWarBoutTimeBox = class("CWarBoutTimeBox", CBox)

function CWarBoutTimeBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_CountTimeLabel = self:NewUI(1, CLabel)
	self.m_WaitSpr = self:NewUI(2, CSprite)
	if g_WarCtrl.m_IsFirstSpecityWar and g_GuideHelpCtrl:IsNoGuide() then
		self:SetActive(false)
		return
	end
	self.m_CountTimeLabel:SetText("")
	self.m_CountDownTimer = nil
	self.m_BeginTime = 0
	self:StartCountDown()
end

function CWarBoutTimeBox.StartCountDown(self)
	self:ShowWait(false)
	self.m_BeginTime = os.clock()
	if g_WarCtrl:IsPlayRecord() then
		return
	end
	if g_WarCtrl:IsChallengeType() then
		g_WarOrderCtrl:TimeUp()
		return
	end
	if not self.m_CountDownTimer then
		self:CountDown()
		self.m_CountDownTimer = Utils.AddTimer(callback(self, "CountDown"), 0.05, 0)
	end
end

function CWarBoutTimeBox.CountDown(self)
	if not Utils.IsNil(self) then
		local iRemain = g_WarOrderCtrl:GetRemainTime()
		if iRemain then
			if g_WarCtrl:IsAutoWar() then
				local passTime = os.clock()-self.m_BeginTime
				if passTime < g_WarOrderCtrl:GetAutoOrderTime() then
					local sTime = tostring(math.ceil(g_WarOrderCtrl.g_OrderTime - passTime))
					self.m_CountTimeLabel:SetText(sTime)
					return true
				end
			else
				if g_WarOrderCtrl:IsCanOrder() then
					if iRemain > 0 then
						self.m_CountTimeLabel:SetText(tostring(math.ceil(iRemain)))
						return true
					end
				end
			end
			g_WarOrderCtrl:TimeUp()
		end
	end
	self.m_CountTimeLabel:SetText("")
	self:CheckShowWait()
	self.m_CountDownTimer = nil
	return false
end

function CWarBoutTimeBox.CheckShowWait(self)
	if g_WarCtrl:IsInAction() or not g_WarOrderCtrl.m_OrderDone.summon then
		self:ShowWait(false)
	else
		self:ShowWait(true)
	end
end

function CWarBoutTimeBox.ShowWait(self, bShow)
	if g_WarCtrl:IsChallengeType() then
		bShow = false
	end
	self.m_WaitSpr:SetActive(bShow)
end

return CWarBoutTimeBox
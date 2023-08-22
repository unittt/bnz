local CExpandThreeBiwuPart = class("CExpandThreeBiwuPart", CPageBase)

function CExpandThreeBiwuPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandThreeBiwuPart.OnInitPage(self)
	self.m_RankLbl = self:NewUI(1, CLabel)
	self.m_JifenLbl = self:NewUI(2, CLabel)
	self.m_WinLbl = self:NewUI(3, CLabel)
	self.m_WinLinkLbl = self:NewUI(4, CLabel)
	self.m_PrepareLbl = self:NewUI(5, CLabel)
	self.m_TipLbl = self:NewUI(6, CLabel)
	self.m_PrepareDescLbl = self:NewUI(7, CLabel)
	self.m_LineSp = self:NewUI(8, CSprite)
	self.m_TimeLbl = self:NewUI(9, CLabel)
	self.m_EndMathL = self:NewUI(10, CLabel)

	self.m_RankTotal = 30

	self:InitContent()
end

function CExpandThreeBiwuPart.InitContent(self)
	self:RefreshUI()
	g_ThreeBiwuCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlThreeBiwuEvent"))
end

function CExpandThreeBiwuPart.OnCtrlThreeBiwuEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ThreeBiwu.Event.BiwuInfo then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.ThreeBiwu.Event.BiwuCountTime then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.ThreeBiwu.Event.BiwuEndCountTime then
		self:CheckLeftTime()
	elseif oCtrl.m_EventID == define.ThreeBiwu.Event.EndMatch then
		self:RefreshEndMatch()
	end
end

function CExpandThreeBiwuPart.RefreshUI(self)
	-- if g_ThreeBiwuCtrl.m_StartTime == 0 then
	-- 	return
	-- end

	if g_ThreeBiwuCtrl.m_StartTime == 0 then
		self.m_PrepareLbl:SetActive(false)
		self.m_PrepareDescLbl:SetActive(false)
		self.m_TipLbl:SetText("争霸次数："..g_ThreeBiwuCtrl.m_FightTime.."/"..g_ThreeBiwuCtrl.m_FightTotal)
		if g_ThreeBiwuCtrl.m_RankIndex > self.m_RankTotal then
			self.m_RankLbl:SetText("排名：榜外")
		else
			self.m_RankLbl:SetText("排名："..g_ThreeBiwuCtrl.m_RankIndex)
		end
		self.m_JifenLbl:SetText("积分："..g_ThreeBiwuCtrl.m_Point)
		self.m_WinLbl:SetText("胜利："..g_ThreeBiwuCtrl.m_WinTime)
		self.m_WinLinkLbl:SetText("连胜："..g_ThreeBiwuCtrl.m_LastWinTime)
		self:CheckLeftTime()
		self:RefreshEndMatch()
	else
		self.m_PrepareLbl:SetActive(true)
		self.m_PrepareDescLbl:SetActive(true)
		self.m_TipLbl:SetText("")
		self.m_RankLbl:SetText("")
		self.m_JifenLbl:SetText("")
		self.m_WinLbl:SetText("")
		self.m_WinLinkLbl:SetText("")
		self:SetStartCountTime()
		self.m_TimeLbl:SetText("")
		self.m_EndMathL:SetActive(false)
	end	
end

function CExpandThreeBiwuPart.CheckLeftTime(self)
	if g_ThreeBiwuCtrl.m_BiwuEndCountTime > 0 then
		local oTimeStr = string.gsub(g_TimeCtrl:GetLeftTimeString(g_ThreeBiwuCtrl.m_BiwuEndCountTime), "00分钟00秒", "")
		self.m_TimeLbl:SetText("活动结束："..oTimeStr)
	else
		self.m_TimeLbl:SetText("")
	end
end

function CExpandThreeBiwuPart.SetStartCountTime(self)
	if g_ThreeBiwuCtrl.m_BiwuStartCountTime > 0 then
		self.m_PrepareLbl:SetText(g_TimeCtrl:GetLeftTimeString(g_ThreeBiwuCtrl.m_BiwuStartCountTime))
	else
		self.m_PrepareLbl:SetText("")
	end
end

function CExpandThreeBiwuPart.RefreshEndMatch(self)
	self.m_EndMathL:SetActive(g_ThreeBiwuCtrl:IsEndMatch())
end

return CExpandThreeBiwuPart
local CExpandSingleBiwuPart = class("CExpandSingleBiwuPart", CPageBase)

function CExpandSingleBiwuPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandSingleBiwuPart.OnInitPage(self)
	self.m_RankLbl = self:NewUI(1, CLabel)
	self.m_JifenLbl = self:NewUI(2, CLabel)
	self.m_WinLbl = self:NewUI(3, CLabel)
	self.m_WinLinkLbl = self:NewUI(4, CLabel)
	self.m_PrepareLbl = self:NewUI(5, CLabel)
	self.m_TipLbl = self:NewUI(6, CLabel)
	self.m_PrepareDescLbl = self:NewUI(7, CLabel)
	self.m_LineSp = self:NewUI(8, CSprite)
	self.m_TimeLbl = self:NewUI(9, CLabel)

	self:InitContent()
end

function CExpandSingleBiwuPart.InitContent(self)
	self:RefreshUI()
	g_SingleBiwuCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlSingleBiwuEvent"))
end

function CExpandSingleBiwuPart.OnCtrlSingleBiwuEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SingleBiwu.Event.BiwuInfo then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.SingleBiwu.Event.BiwuCountTime then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.SingleBiwu.Event.BiwuEndCountTime then
		self:CheckLeftTime()
	end
end

function CExpandSingleBiwuPart.RefreshUI(self)
	-- if g_SingleBiwuCtrl.m_StartTime == 0 then
	-- 	return
	-- end
	if g_SingleBiwuCtrl:IsActivityStart() then
		self.m_PrepareLbl:SetActive(false)
		self.m_PrepareDescLbl:SetActive(false)
		self.m_TipLbl:SetText("论道次数："..g_SingleBiwuCtrl.m_FightTime.."/"..g_SingleBiwuCtrl.m_FightTotal)
		if g_SingleBiwuCtrl.m_MyRank == nil or g_SingleBiwuCtrl.m_MyRank > g_SingleBiwuCtrl.m_MaxRankLimit then
			self.m_RankLbl:SetText("排名：榜外")
		else
			self.m_RankLbl:SetText("排名："..g_SingleBiwuCtrl.m_MyRank)
		end
		self.m_JifenLbl:SetText("积分："..g_SingleBiwuCtrl.m_MyPoint)
		self.m_WinLbl:SetText("胜利："..g_SingleBiwuCtrl.m_WinTime)
		self.m_WinLinkLbl:SetText("连胜："..g_SingleBiwuCtrl.m_LastWinTime)
		self:CheckLeftTime()
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
	end	
end

function CExpandSingleBiwuPart.CheckLeftTime(self)
	if g_SingleBiwuCtrl.m_BiwuEndCountTime > 0 and g_SingleBiwuCtrl:IsActivityStart() then
		local oTimeStr = string.gsub(g_TimeCtrl:GetLeftTimeString(g_SingleBiwuCtrl.m_BiwuEndCountTime), "00分钟00秒", "")
		self.m_TimeLbl:SetText("活动结束："..oTimeStr)
	else
		self.m_TimeLbl:SetText("")
	end
end

function CExpandSingleBiwuPart.SetStartCountTime(self)
	if g_SingleBiwuCtrl.m_BiwuStartCountTime > 0 then
		self.m_PrepareLbl:SetText(g_TimeCtrl:GetLeftTimeString(g_SingleBiwuCtrl.m_BiwuStartCountTime))
	else
		self.m_PrepareLbl:SetText("")
	end
end

return CExpandSingleBiwuPart
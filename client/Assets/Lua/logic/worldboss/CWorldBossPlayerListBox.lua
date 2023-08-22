local CWorldBossPlayerListBox = class("CWorldBossPlayerListBox", CBox)

function CWorldBossPlayerListBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_PlayerBoxClone = self:NewUI(3, CBox)
	self.m_MyRankL = self:NewUI(4, CLabel)
	self.m_MyScoreL = self:NewUI(5, CLabel)
	self.m_ChallengeBtn = self:NewUI(6, CButton)
	self.m_PlunderBtn = self:NewUI(7, CButton)
	self:InitContent()
end

function CWorldBossPlayerListBox.InitContent(self)
	self.m_PlayerBoxClone:SetActive(false)
	self.m_ChallengeBtn:AddUIEvent("click", callback(self, "RequestBossChallenge"))
	self.m_PlunderBtn:AddUIEvent("click", callback(self, "OpenPlunderView"))
end

function CWorldBossPlayerListBox.RefreshAll(self)
	self:RefreshPlayerGrid()
	self:RefreshMyRankInfo()
end

function CWorldBossPlayerListBox.RefreshPlayerGrid(self)
	self.m_Grid:Clear()
	local tPlayerList = g_WorldBossCtrl:GetPlayerList()
	for i,dPlayer in ipairs(tPlayerList) do
		local oBox = self:CreatePlayerBox()
		self.m_Grid:AddChild(oBox)
		self:UpdatePlayerBox(oBox, dPlayer, i)
	end
	self.m_Grid:Reposition()
end

function CWorldBossPlayerListBox.CreatePlayerBox(self)
	local oBox = self.m_PlayerBoxClone:Clone()
	oBox.m_RankL = oBox:NewUI(1, CLabel)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_SchoolSpr = oBox:NewUI(3, CSprite)
	oBox.m_OrgL = oBox:NewUI(4, CLabel)
	oBox.m_ScoreL = oBox:NewUI(5, CLabel)
	oBox.m_GradeL = oBox:NewUI(6, CLabel)
	oBox.m_RankSpr = oBox:NewUI(7, CSprite)
	return oBox
end

function CWorldBossPlayerListBox.UpdatePlayerBox(self, oBox, dPlayer, iRank)
	oBox.m_RankL:SetActive(iRank > 3)
	oBox.m_RankSpr:SetActive(iRank <= 3)
	oBox.m_RankSpr:SetSpriteName("h7_no"..iRank)
	oBox.m_RankL:SetText(iRank)
	oBox.m_NameL:SetText(dPlayer.name)
	oBox.m_SchoolSpr:SpriteSchool(dPlayer.school)
	oBox.m_GradeL:SetText(dPlayer.grade)
	oBox.m_ScoreL:SetText(dPlayer.point)
	oBox.m_OrgL:SetText(dPlayer.org_name)
	if dPlayer.pid == g_AttrCtrl.pid then
		local color = Color.RGBAToColor("a64e00")
		oBox.m_RankL:SetColor(color)
		oBox.m_NameL:SetColor(color)
		oBox.m_GradeL:SetColor(color)
		oBox.m_ScoreL:SetColor(color)
		oBox.m_OrgL:SetColor(color)
	end
	oBox:SetActive(true)
end

function CWorldBossPlayerListBox.RefreshMyRankInfo(self)
	local dInfo = g_WorldBossCtrl:GetMyRankInfo()
	self.m_MyRankL:SetText(dInfo.rank == 0 and "未上榜" or dInfo.rank)
	self.m_MyScoreL:SetText(dInfo.point)
end

function CWorldBossPlayerListBox.RefreshPlunderButton(self)
	self.m_IsPlunderStart = false
	local iPlunderTime = g_WorldBossCtrl:GetPlunderCDTime()
	if self.m_PlunderTimer then
		Utils.DelTimer(self.m_PlunderTimer)
		self.m_PlunderTimer = nil
	end
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		local iDiffTime = os.difftime(iPlunderTime, g_TimeCtrl:GetTimeS())
		self.m_PlunderBtn:SetGrey(iDiffTime > 0)
		if iDiffTime > 0 then
			self.m_PlunderBtn:SetText(os.date("前去抢分\n(%M:%S)", iDiffTime))
		else
			self.m_PlunderBtn:SetText("前去抢分")
			self.m_IsPlunderStart = true
			return false
		end
		return true
	end
	self.m_PlunderTimer = Utils.AddTimer(update, 1, 0)
end

function CWorldBossPlayerListBox.RefreshChallengeButton(self)
	local iBossTime = g_WorldBossCtrl:GetBossCDTime()
	if self.m_ChallengeTimer then
		Utils.DelTimer(self.m_ChallengeTimer)
		self.m_ChallengeTimer = nil
	end
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		local iDiffTime = os.difftime(iBossTime, g_TimeCtrl:GetTimeS())
		self.m_ChallengeBtn:SetGrey(iDiffTime > 0)
		if iDiffTime > 0 then
			self.m_ChallengeBtn:SetText(os.date("挑战混沌\n(%M:%S)", iDiffTime))
		else
			self.m_ChallengeBtn:SetText("挑战混沌")
			self.m_IsChallengeStart = true
			return false
		end
		return true
	end
	self.m_ChallengeTimer = Utils.AddTimer(update, 1, 0)
end

function CWorldBossPlayerListBox.RequestBossChallenge(self)
	-- if not self.m_IsChallengeStart then
	-- 	g_NotifyCtrl:FloatMsg("未开始")
	-- end
	if g_WorldBossCtrl:IsEnd() then
		g_NotifyCtrl:FloatMsg(DataTools.GetWorldBossText(1013))
	elseif not g_WorldBossCtrl:IsStart() then
		local iBossTime = g_WorldBossCtrl:GetBossCDTime()
		local iDiffTime = os.difftime(iBossTime, g_TimeCtrl:GetTimeS())
		g_NotifyCtrl:FloatMsg(DataTools.GetWorldBossText(1012, "#time", iDiffTime))--string.format("距离活动开启还有%d秒，请于活动开启后参与", iDiffTime))
	else
		nethuodong.C2GSMengzhuStartFightBoss() 
	end
end

function CWorldBossPlayerListBox.OpenPlunderView(self)
	if g_WorldBossCtrl:IsEnd() then
		g_NotifyCtrl:FloatMsg(DataTools.GetWorldBossText(1013))
	elseif not g_WorldBossCtrl:IsStart() then
		local iPlunderTime = g_WorldBossCtrl:GetPlunderCDTime()
		local iDiffTime = os.difftime(iPlunderTime, g_TimeCtrl:GetTimeS())
		g_NotifyCtrl:FloatMsg(DataTools.GetWorldBossText(1012, "#time", iDiffTime))
	elseif not self.m_IsPlunderStart then
		g_NotifyCtrl:FloatMsg(DataTools.GetWorldBossText(1006))
	else
		CWorldBossPlunderView:ShowView()
	end
end
return CWorldBossPlayerListBox
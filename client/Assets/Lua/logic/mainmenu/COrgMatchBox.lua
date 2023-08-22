local COrgMatchBox = class("COrgMatchBox", CBox)

function COrgMatchBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_TeamBtn = self:NewUI(1, CButton)
	self.m_RankBtn = self:NewUI(2, CButton)
	self.m_TipBtn = self:NewUI(3, CButton)
	self.m_ActionPointL = self:NewUI(4, CLabel)
	self.m_PreTimeL = self:NewUI(5, CLabel)
	self.m_RankBox = self:NewUI(6, COrgMatchRankBox)

	self.m_IsExpand = false

	self:InitContent()
end

function COrgMatchBox.InitContent(self)
	self.m_RankBox:SetActive(false)

	self.m_TeamBtn:AddUIEvent("click", callback(self, "OnClickTeam"))
	self.m_RankBtn:AddUIEvent("click", callback(self, "OnClickRank"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTip"))

	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))
	g_OrgMatchCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlOrgMatchEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlWarEvent"))

	self:CheckShow()
	self:RefreshAll()
end

function COrgMatchBox.OnCtrlOrgMatchEvent(self, oCtrl)
    if oCtrl.m_EventID == define.OrgMatch.Event.RefreshActionPoint then
        self:RefreshActionPoint()
    elseif oCtrl.m_EventID == define.OrgMatch.Event.RefreshPreTime then
    	self:RefreshPreTime()
    elseif oCtrl.m_EventID == define.OrgMatch.Event.RefreshOrgDetailInfo then
    	self.m_RankBox:RefreshAll()
    end
end

function COrgMatchBox.OnCtrlMapEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.EnterScene then
		self:RefreshAll()
		self:CheckShow()
	end
end

function COrgMatchBox.OnCtrlWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.WarStart then
		self:CheckShow()
	end
end

function COrgMatchBox.CheckShow(self)
	local bIsShow = not g_WarCtrl:IsWar() and g_MapCtrl:IsInOrgMatchMap()
	if bIsShow then
		if g_MapCtrl.m_MapID == g_OrgMatchCtrl.m_MatchMapId then
			nethuodong.C2GSOrgWarOpenWarScoreUI()
		else
			self.m_RankBox:ExpandBox(false)
			self.m_IsExpand = false
		end
	end
	self.m_RankBox:SetActive(bIsShow and g_MapCtrl.m_MapID == g_OrgMatchCtrl.m_MatchMapId)
	self:SetActive(bIsShow)
	if bIsShow then
		for i,area in ipairs(define.MainMenu.HideConfig.OrgMatch) do
			g_MainMenuCtrl:HideArea(area)
		end
	else
		--强制恢复被隐藏的UI
		for i,area in ipairs(define.MainMenu.HideConfig.OrgMatch) do
			if g_MainMenuCtrl:IsExpand() then
				g_MainMenuCtrl:ShowArea(area)
			end
		end
	end
end

function COrgMatchBox.RefreshAll(self)
	self:RefreshActionPoint()
	self:RefreshPreTime()
end

function COrgMatchBox.RefreshActionPoint(self)
	self.m_ActionPointL:SetText(g_OrgMatchCtrl:GetActionPoint())
end

function COrgMatchBox.RefreshPreTime(self)
	self.m_IsMatchStart = false
	local iMatchTime = g_OrgMatchCtrl:GetMatchStartTime()
	if self.m_PreTimer then
		Utils.DelTimer(self.m_PreTimer)
		self.m_PreTimer = nil
	end
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		local iDiffTime = os.difftime(iMatchTime, g_TimeCtrl:GetTimeS())
		self.m_PreTimeL:SetActive(iDiffTime > 0)
		if iDiffTime <= 0 then
			self.m_IsMatchStart = true
			return false
		else
			self.m_PreTimeL:SetText("剩余准备时间："..g_TimeCtrl:GetLeftTimeString(iDiffTime))
		end
		return true
	end
	self.m_PreTimer = Utils.AddTimer(update, 0.5, 0)
end

function COrgMatchBox.OnClickTeam(self)
	nethuodong.C2GSOrgWarOpenTeamUI()
	COrgMatchTeamOparateView:ShowView()
end

function COrgMatchBox.OnClickRank(self)
	local dText = data.orgdata.TEXT
	if not self.m_IsMatchStart and g_MapCtrl.m_MapID == g_OrgMatchCtrl.m_PreMapId then
		g_NotifyCtrl:FloatMsg(dText[3001].content)
		return
	end
	if g_MapCtrl.m_MapID ~= g_OrgMatchCtrl.m_MatchMapId then
		g_NotifyCtrl:FloatMsg(dText[3002].content)
		return
	end
	-- nethuodong.C2GSOrgWarOpenWarScoreUI()
	self.m_IsExpand = not self.m_IsExpand	
	self.m_RankBox:ExpandBox(self.m_IsExpand)
end

function COrgMatchBox.OnClickTip(self)
	local id = define.Instruction.Config.OrgMatch
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

return COrgMatchBox
local CExpandSchoolMatchPart = class("CExpandSchoolMatchPart", CPageBase)

function CExpandSchoolMatchPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandSchoolMatchPart.OnInitPage(self)
	self.m_MatchNameL = self:NewUI(1, CLabel)
	self.m_RankL = self:NewUI(2, CLabel)
	self.m_ScoreL = self:NewUI(3, CLabel)
	self.m_WinCountL = self:NewUI(4, CLabel)
	self.m_LoseCountL = self:NewUI(5, CLabel)
	self.m_MainBtn = self:NewUI(6, CButton)
	self.m_TipBtn = self:NewUI(7, CButton)
	self.m_PrepareL = self:NewUI(8, CLabel)
	self.m_MatchTimeL = self:NewUI(9, CLabel)
	self.m_DesTipBtn = self:NewUI(10, CButton)
    self.m_TipL = self:NewUI(11, CLabel)

	self.m_TitleText = {
		[16] = "晋级八强",
		[8] = "晋级四强",
		[4] = "半决赛",
		[2] = "决赛",
        [0] = "",
	}
    self:InitKnockOutText()
	self:InitContent()
end

-- text id: 1战败 2倒计时 3对战中(step=2时要区分冠军/季军) 
function CExpandSchoolMatchPart.InitKnockOutText(self)
    self.m_KnockOutText = {
        [16] = {1036, 1032, 1040},
        [8] = {1037, 1033, 1041},
        [4] = {1038, 1034, 1042},
        [2] = {1039, 1035, {1044, 1043}},
        [0] = {},
    }
end

function CExpandSchoolMatchPart.InitContent(self)
	self.m_MatchTimeL:SetActive(false)
    self.m_WinCountL:SetActive(false)
    self.m_TipBtn:SetActive(false)
    self:SetLabels()
	self.m_MainBtn:AddUIEvent("click", callback(self, "OnClickButton"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "ShowTipView"))
	self.m_DesTipBtn:AddUIEvent("click", callback(self, "ShowDesTipBtn"))

	g_SchoolMatchCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:RefreshMatchInfo()
	self:RefreshGameStep()
end

function CExpandSchoolMatchPart.SetLabels(self)
    local col = Color.RGBAToColor("79BEC1")
    self.m_RankL:SetColor(col)
    self.m_ScoreL:SetColor(col)
    self.m_MatchNameL:SetColor(Color.RGBAToColor("FFCC00"))
    local oParent = self.m_RankL:GetParent()
    if oParent then
        oParent.localPosition = Vector3.New(-225, -50, 0)
    end
    self.m_MatchTimeL:SetAlignment(2)
    self.m_TipL:SetAlignment(2)
    self.m_TipL:SetText(self:GetTextCont(1030))
end

function CExpandSchoolMatchPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SchoolMatch.Event.RefreshMyRank then
		self:RefreshMatchInfo()
	elseif oCtrl.m_EventID == define.SchoolMatch.Event.RefreshGameStep or 
		oCtrl.m_EventID == define.SchoolMatch.Event.RefreshBattleList then
		self:RefreshGameStep()
	end
end

function CExpandSchoolMatchPart.RefreshMatchInfo(self)
	local dInfo = g_SchoolMatchCtrl:GetMyRankInfo()
	local iStep = g_SchoolMatchCtrl:GetGameStep()
	local bIsShow = iStep == define.SchoolMatch.Step.PointRace
	self.m_RankL:SetActive(bIsShow)
	self.m_ScoreL:SetActive(bIsShow)
	-- self.m_WinCountL:SetActive(bIsShow)
	self.m_LoseCountL:SetActive(bIsShow)
	self.m_MatchTimeL:SetActive(bIsShow)
    self.m_TipL:SetActive(false)
	self.m_PrepareL:SetActive(not bIsShow)
	if dInfo and iStep == define.SchoolMatch.Step.None then
		self:RefreshCountdownTime(dInfo.starttime)
	end
	if not bIsShow then
        self:DelMatchTimer()
		return
	end
	self.m_RankL:SetText("当前排名："..dInfo.rank)
	self.m_ScoreL:SetText("首席积分："..dInfo.point)
	-- self.m_WinCountL:SetText("胜利："..dInfo.win)
	self.m_LoseCountL:SetText("战败次数："..dInfo.fail)
	self:RefreshMatchTime(dInfo.matchtime, dInfo.fail)
end

function CExpandSchoolMatchPart.RefreshGameStep(self)
	local iStep = g_SchoolMatchCtrl:GetGameStep()
	printc("刷新比赛状态", iStep)
	self:RefreshMatchInfo()
	self:RefreshButton()
    self:RefreshLabels(iStep)
	if iStep == define.SchoolMatch.Step.None then
		self.m_MatchNameL:SetText("活动准备")
		if g_SchoolMatchCtrl.m_ShowTip then
			self:ShowTipView()
			g_SchoolMatchCtrl.m_ShowTip = true
		end
	elseif iStep == define.SchoolMatch.Step.PointRace then
		self.m_MatchNameL:SetText("积分赛")
	elseif iStep == define.SchoolMatch.Step.Knockout then
		local sTitle = self.m_TitleText[g_SchoolMatchCtrl:GetMatchStep()]
		self.m_MatchNameL:SetText(sTitle)
		self:RefreshBattleTime()
	elseif iStep == define.SchoolMatch.Step.End then
        self:DelTimer()
		self.m_MatchNameL:SetText("结束")
		self.m_PrepareL:SetText("比赛已经结束了\n即将自动离场")
	end
end

function CExpandSchoolMatchPart.RefreshLabels(self, iStep)
    if iStep == define.SchoolMatch.Step.End then
        self.m_PrepareL:SetLocalPos(Vector3.New(-258, -109, 0))
        self.m_PrepareL:SetAlignment(2)
    else
        self.m_PrepareL:SetLocalPos(Vector3.New(-258, -59, 0))
        self.m_PrepareL:SetAlignment(1)
    end
end

function CExpandSchoolMatchPart.RefreshButton(self)
	local iStep = g_SchoolMatchCtrl:GetGameStep()
	if iStep == define.SchoolMatch.Step.Knockout then
		self.m_MainBtn:SetText("对战表")
	elseif iStep == define.SchoolMatch.Step.End then
		self.m_MainBtn:SetText("首席名单")
	elseif iStep == define.SchoolMatch.Step.None then
		self.m_MainBtn:SetText("赛程说明")
	else
		self.m_MainBtn:SetText("查看排名")
	end
end

function CExpandSchoolMatchPart.RefreshCountdownTime(self, iCountdownTime)
    self:DelTimer()
    local iLeftTime = iCountdownTime
    local function update()
        if Utils.IsNil(self) then
            return
        end
        if iLeftTime <= 0 then
            self:RefreshMatchInfo()
            if self.m_IsAutoTip then
            	CSchoolMatchTipView:CloseView()
            end
            return
        end
        local sTime = g_TimeCtrl:GetLeftTimeString(iLeftTime)
        local sText = self:GetTextCont(1028, {amount = sTime})
        self.m_PrepareL:SetText(sText)
        iLeftTime = iLeftTime - 1
        return true
    end
    self.m_Timer = Utils.AddTimer(update, 1, 0)
end

function CExpandSchoolMatchPart.RefreshMatchTime(self, iCountdownTime, iFail)
    self:DelMatchTimer()
	local iLeftTime = iCountdownTime
    if iFail >= 3 then
        self.m_MatchTimeL:SetActive(true)
        self.m_MatchTimeL:SetText(self:GetTextCont(1031))
        return
    end
    local function update()
        if Utils.IsNil(self) then
            return
        end
        if iLeftTime <= 0 then
        	self.m_MatchTimeL:SetActive(false)
            self.m_TipL:SetActive(false)
        	return
        end
        local iStep = g_SchoolMatchCtrl:GetGameStep()
        local bShow = not g_WarCtrl:IsWar() and iStep == define.SchoolMatch.Step.PointRace
        self.m_MatchTimeL:SetActive(bShow)
        self.m_TipL:SetActive(true)
        local sText = self:GetTextCont(1029, {amount = iLeftTime})
        self.m_MatchTimeL:SetText(sText)
        iLeftTime = iLeftTime - 1
        return true
    end
    self.m_MatchTimer = Utils.AddTimer(update, 1, 0)
end

function CExpandSchoolMatchPart.RefreshBattleTime(self)
    self:DelTimer()
	local function update()
        if Utils.IsNil(self) then
			return
		end
        self:RefreshKnockOutTimeL()
		return true
	end
	self.m_Timer = Utils.AddTimer(update, 1, 0)	
end

function CExpandSchoolMatchPart.RefreshKnockOutTimeL(self)
    local iStep = g_SchoolMatchCtrl:GetMatchStep()
    local dTextId = self.m_KnockOutText[iStep]
    local iFightTime = g_SchoolMatchCtrl.m_FightTime
    if not dTextId then
        self.m_PrepareL:SetText("")
    elseif iFightTime <= 0 then
        if g_SchoolMatchCtrl.m_IsFighting then
            local iTextId = 0
            if iStep == 2 then
                local dFT = dTextId[3]
                iTextId = g_SchoolMatchCtrl.m_IsJiJun and dFT[1] or dFT[2]
            else
                iTextId = dTextId[3]
            end
            self.m_PrepareL:SetText(self:GetTextCont(iTextId))
        else
            self.m_PrepareL:SetText(self:GetTextCont(dTextId[1]))
        end
    else
        self.m_PrepareL:SetText(self:GetTextCont(dTextId[2], {amount = iFightTime}))
    end
end

function CExpandSchoolMatchPart.OnClickButton(self)
	local iStep = g_SchoolMatchCtrl:GetGameStep()
	if iStep == define.SchoolMatch.Step.PointRace then
		nethuodong.C2GSLMLookInfo(0)
		CSchoolMatchRankView:ShowView()
	elseif iStep == define.SchoolMatch.Step.Knockout then
		nethuodong.C2GSLMLookInfo(0)
		CSchoolMatchBattleListView:ShowView()
	elseif iStep == define.SchoolMatch.Step.End then
		CSchoolMatchWinnerView:ShowView()
	else
		-- g_NotifyCtrl:FloatMsg("活动未开始")
		self:ShowTipView()
	end
end

function CExpandSchoolMatchPart.ShowTipView(self)
    CSchoolMatchTipView:ShowView()
    g_SchoolMatchCtrl.m_ShowTip = false
end

function CExpandSchoolMatchPart.ShowDesTipBtn(self)
	-- body
	if data.instructiondata.DESC[10016]~=nil then
		local Content = {
		 title = data.instructiondata.DESC[10016].title,
	 	 desc = data.instructiondata.DESC[10016].desc
		}
		g_WindowTipCtrl:SetWindowInstructionInfo(Content)
	end
end

function CExpandSchoolMatchPart.GetTextCont(self, id, args)
    local dText = DataTools.GetMiscText(id, "SCHOOLMATCH")
    if dText then
        return string.FormatString(dText.content, args, true)
    end
    return ""
end

function CExpandSchoolMatchPart.DelTimer(self)
    if self.m_Timer then
        Utils.DelTimer(self.m_Timer)
        self.m_Timer = nil
    end
end

function CExpandSchoolMatchPart.DelMatchTimer(self)
    if self.m_MatchTimer then
        Utils.DelTimer(self.m_MatchTimer)
        self.m_MatchTimer = nil
    end
end

return CExpandSchoolMatchPart
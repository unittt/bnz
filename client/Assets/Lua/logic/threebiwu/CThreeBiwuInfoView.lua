local CThreeBiwuInfoView = class("CThreeBiwuInfoView", CViewBase)

function CThreeBiwuInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/ThreeBiwu/ThreeBiwuInfoView.prefab", cb)
	--界面设置
	-- self.m_DepthType = "Fourth"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CThreeBiwuInfoView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_LeftTimeLbl = self:NewUI(2, CLabel)
	self.m_TipBtn = self:NewUI(3, CButton)
	self.m_FirstBtn = self:NewUI(4, CButton)
	self.m_FirstGetSp = self:NewUI(5, CSprite)
	self.m_WuBtn = self:NewUI(6, CButton)
	self.m_WuGetSp = self:NewUI(7, CSprite)
	self.m_TeamBoxList = {}
	for i=8, 10 do
		local oBox = self:NewUI(i, CBox)
		oBox.m_IconSp = oBox:NewUI(1, CSprite)
		oBox.m_NameLbl = oBox:NewUI(2, CLabel)
		oBox.m_LevelLbl = oBox:NewUI(3, CLabel)	
		oBox.m_SchoolSp = oBox:NewUI(4, CSprite)
		oBox.m_AddBtn = oBox:NewUI(5, CButton)
		oBox.m_NoLbl = oBox:NewUI(6, CLabel)
		table.insert(self.m_TeamBoxList, oBox)
	end
	self.m_RankLbl = self:NewUI(11, CLabel)
	self.m_JifenLbl = self:NewUI(12, CLabel)
	self.m_WinLbl = self:NewUI(13, CLabel)
	self.m_WinLinkLbl = self:NewUI(14, CLabel)
	self.m_FindBtn = self:NewUI(15, CButton)
	self.m_ScrollView = self:NewUI(16, CScrollView)
	self.m_Grid = self:NewUI(17, CGrid)
	self.m_BoxClone = self:NewUI(18, CBox)
	self.m_FightTimeLbl = self:NewUI(19, CLabel)

	self.m_RankTotal = 30
	
	self:InitContent()
end

function CThreeBiwuInfoView.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTipBtn"))
	self.m_FirstBtn:AddUIEvent("click", callback(self, "OnClickFirstBtn"))
	self.m_WuBtn:AddUIEvent("click", callback(self, "OnClickWuBtn"))
	self.m_FindBtn:AddUIEvent("click", callback(self, "OnClickFindBtn"))
	g_ThreeBiwuCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlThreeBiwuEvent"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTeamEvent"))
end

function CThreeBiwuInfoView.OnCtrlThreeBiwuEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ThreeBiwu.Event.BiwuInfo then
		self:SetRankInfo()
	elseif oCtrl.m_EventID == define.ThreeBiwu.Event.BiwuCountTime then
		self:CheckLeftTime()
	elseif oCtrl.m_EventID == define.ThreeBiwu.Event.BiwuEndCountTime then
		self:CheckLeftTime()
	end
end

function CThreeBiwuInfoView.OnCtrlTeamEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTeam or
		oCtrl.m_EventID == define.Team.Event.DelTeam or 
		oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch or 
		oCtrl.m_EventID == define.Team.Event.Reset or 
		oCtrl.m_EventID == define.Team.Event.MemberUpdate or 
		oCtrl.m_EventID == define.Team.Event.RefreshFormationPos then
		self:SetTeamBox()
	end
end

function CThreeBiwuInfoView.RefreshUI(self)
	self:SetRankList()
	self:CheckFirstWin()
	self:CheckFiveWin()
	self:SetTeamBox()
	self:SetRankInfo()
	self:CheckLeftTime()
end

function CThreeBiwuInfoView.SetRankInfo(self)
	if g_ThreeBiwuCtrl.m_RankIndex > self.m_RankTotal then
		self.m_RankLbl:SetText("我的排名：榜外")
	else
		self.m_RankLbl:SetText("我的排名："..g_ThreeBiwuCtrl.m_RankIndex)
	end
	self.m_JifenLbl:SetText("积分："..g_ThreeBiwuCtrl.m_Point)
	self.m_WinLbl:SetText("胜利："..g_ThreeBiwuCtrl.m_WinTime)
	self.m_WinLinkLbl:SetText("最高连胜："..g_ThreeBiwuCtrl.m_LastWinTime)
	if g_ThreeBiwuCtrl.m_MatchingState == 1 then
		self.m_FindBtn:SetText("匹配中...")
	else
		self.m_FindBtn:SetText("开始匹配")
	end
	self.m_FightTimeLbl:SetText("争霸次数："..g_ThreeBiwuCtrl.m_FightTime.."/"..g_ThreeBiwuCtrl.m_FightTotal)
end

function CThreeBiwuInfoView.CheckLeftTime(self)
	if (g_TimeCtrl:GetTimeS() - g_ThreeBiwuCtrl.m_StartTime) > 0 then
		if g_ThreeBiwuCtrl.m_BiwuEndCountTime >= 0 then
			self.m_LeftTimeLbl:SetText("活动剩余时间：[FF3636]"..g_TimeCtrl:GetLeftTimeString(g_ThreeBiwuCtrl.m_BiwuEndCountTime).."[-]")
		end
	else
		if g_ThreeBiwuCtrl.m_BiwuStartCountTime >= 0 then
			self.m_LeftTimeLbl:SetText("活动开始剩余时间：[FF3636]"..g_TimeCtrl:GetLeftTimeString(g_ThreeBiwuCtrl.m_BiwuStartCountTime).."[-]")
		end
		if g_ThreeBiwuCtrl.m_BiwuStartCountTime > 0 then
			self.m_FindBtn:SetActive(false)
		else
			self.m_FindBtn:SetActive(true)
		end
	end
end

function CThreeBiwuInfoView.CheckFirstWin(self)
	self.m_FirstBtn.m_UIButton.tweenTarget = nil
	self.m_FirstBtn:DelEffect("Circu")
	self.m_FirstBtn:SetSpriteName("h7_xiang_2")
	CSprite.MakePixelPerfect(self.m_FirstBtn)
	self.m_FirstGetSp:SetActive(false)
	-- self.m_FirstBtn:SetColor(Color.RGBAToColor("FFFFFFFF"))
	if g_ThreeBiwuCtrl.m_FirstWin == 0 then
	elseif g_ThreeBiwuCtrl.m_FirstWin == 1 then
		self.m_FirstBtn:AddEffect("Circu")
	elseif g_ThreeBiwuCtrl.m_FirstWin == 2 then
		self.m_FirstBtn:SetSpriteName("h7_xiang_4")
		CSprite.MakePixelPerfect(self.m_FirstBtn)
		-- self.m_FirstGetSp:SetActive(true)
		-- self.m_FirstBtn:SetColor(Color.RGBAToColor("000000FF"))
	end
end

function CThreeBiwuInfoView.CheckFiveWin(self)
	self.m_WuBtn.m_UIButton.tweenTarget = nil
	self.m_WuBtn:DelEffect("Circu")
	self.m_WuBtn:SetSpriteName("h7_xiang_1")
	CSprite.MakePixelPerfect(self.m_WuBtn)
	self.m_WuGetSp:SetActive(false)
	-- self.m_WuBtn:SetColor(Color.RGBAToColor("FFFFFFFF"))
	if g_ThreeBiwuCtrl.m_FiveWin == 0 then
	elseif g_ThreeBiwuCtrl.m_FiveWin == 1 then
		self.m_WuBtn:AddEffect("Circu")
	elseif g_ThreeBiwuCtrl.m_FiveWin == 2 then
		self.m_WuBtn:SetSpriteName("h7_xiang_3")
		CSprite.MakePixelPerfect(self.m_WuBtn)
		-- self.m_WuGetSp:SetActive(true)
		-- self.m_WuBtn:SetColor(Color.RGBAToColor("000000FF"))
	end
end

function CThreeBiwuInfoView.SetTeamBox(self)
	local oTeamList = g_ThreeBiwuCtrl:GetMyTeamList()
	for i=1, 3 do
		self:SetSingleTeamBox(self.m_TeamBoxList[i], oTeamList[i])
	end
end

function CThreeBiwuInfoView.SetSingleTeamBox(self, oTeamBox, oData)
	if oData then
		oTeamBox.m_NoLbl:SetActive(false)
		oTeamBox.m_IconSp:SetActive(true)
		oTeamBox.m_SchoolSp:SetActive(true)
		oTeamBox.m_AddBtn:SetActive(false)
		oTeamBox.m_IconSp:SpriteAvatar(oData.icon)
		oTeamBox.m_LevelLbl:SetText("等级："..oData.grade)
		oTeamBox.m_NameLbl:SetText(oData.name)
		oTeamBox.m_SchoolSp:SpriteSchool(oData.school)
	else
		oTeamBox.m_NoLbl:SetActive(true)
		oTeamBox.m_IconSp:SetActive(false)
		oTeamBox.m_SchoolSp:SetActive(false)
		oTeamBox.m_AddBtn:SetActive(true)
		oTeamBox.m_LevelLbl:SetText("")
		oTeamBox.m_NameLbl:SetText("")
	end
	oTeamBox.m_AddBtn:AddUIEvent("click", callback(self, "OnClickTeamAdd"))
end

function CThreeBiwuInfoView.SetRankList(self)
	local optionCount = #g_ThreeBiwuCtrl.m_ViewRankList
	local GridList = self.m_Grid:GetChildList() or {}
	local oRankBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oRankBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oRankBox = GridList[i]
			end
			self:SetRankBox(oRankBox, g_ThreeBiwuCtrl.m_ViewRankList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CThreeBiwuInfoView.SetRankBox(self, oRankBox, oData)
	oRankBox:SetActive(true)
	oRankBox.m_TopSp = oRankBox:NewUI(1, CSprite)
	oRankBox.m_RankLbl = oRankBox:NewUI(2, CLabel)
	oRankBox.m_NameLbl = oRankBox:NewUI(3, CLabel)
	oRankBox.m_JifenLbl = oRankBox:NewUI(4, CLabel)
	oRankBox.m_WinLinkLbl = oRankBox:NewUI(5, CLabel)	

	if oData.rank <= 3 then
		oRankBox.m_RankLbl:SetActive(false)
		oRankBox.m_TopSp:SetActive(true)
		oRankBox.m_TopSp:SetSpriteName("h7_no"..oData.rank)
	else
		oRankBox.m_RankLbl:SetActive(true)
		oRankBox.m_TopSp:SetActive(false)
		oRankBox.m_RankLbl:SetText(oData.rank)
	end
	oRankBox.m_NameLbl:SetText(oData.name)
	oRankBox.m_JifenLbl:SetText(oData.point)
	oRankBox.m_WinLinkLbl:SetText(oData.maxwin)

	self.m_Grid:AddChild(oRankBox)
	self.m_Grid:Reposition()
end

---------------以下是点击事件-----------------

function CThreeBiwuInfoView.OnClickTipBtn(self)
	local zContent = {title = data.instructiondata.DESC[10057].title,desc = data.instructiondata.DESC[10057].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CThreeBiwuInfoView.OnClickFirstBtn(self)
	nethuodong.C2GSThreeBWGetFirstReward()
end

function CThreeBiwuInfoView.OnClickWuBtn(self)
	nethuodong.C2GSThreeBWGetFiveReward()
end

function CThreeBiwuInfoView.OnClickFindBtn(self)	
	if g_ThreeBiwuCtrl.m_MatchingState == 1 then
		if not g_WarCtrl:IsWar() then
			CThreeBiwuPrepareView:ShowView(function (oView)
				oView:RefreshUI()
			end)
		end
	elseif g_ThreeBiwuCtrl:IsEndMatch() then
		g_NotifyCtrl:FloatMsg("活动即将结束，停止匹配")
	else
		nethuodong.C2GSThreeSetMatch(1)
	end
end

function CThreeBiwuInfoView.OnClickTeamAdd(self)
	if not g_TeamCtrl:IsJoinTeam() then
		netteam.C2GSCreateTeam()
	end
	CTeamMainView:ShowView()
end

return CThreeBiwuInfoView
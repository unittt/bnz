local CSchoolMatchBattleListView = class("CSchoolMatchBattleListView", CViewBase)

function CSchoolMatchBattleListView.ctor(self, cb)
	CViewBase.ctor(self, "UI/SchoolMatch/SchoolMatchBattleListView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CSchoolMatchBattleListView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TimeL = self:NewUI(2, CLabel)
	self.m_MatchL = self:NewUI(3, CLabel)
	self.m_Content = {
		[16] = self:NewUI(4, CObject),
		[8] = self:NewUI(5, CObject),
		[4] = self:NewUI(6, CObject),
		[2] = self:NewUI(7, CObject),
	}
	self.m_MatchGrid = {
		[16] = self:NewUI(8, CGrid),
		[8] = self:NewUI(10, CGrid),
		[4] = self:NewUI(11, CGrid),
	}
	self.m_SimpleBattleBox = self:NewUI(9, CBox)
	self.m_FirstBattleBox = self:NewUI(12, CSchoolMatchBattleBox)
	self.m_ThirdBattleBox = self:NewUI(13, CSchoolMatchBattleBox)
	self.m_BattleBoxClone = self:NewUI(14, CSchoolMatchBattleBox)
	self.m_TipL = self:NewUI(15, CLabel)

	self.m_TitleText = {
		[16] = "16晋8晋赛名单",
		[8] = "8晋4晋赛名单",
		[4] = "半决赛",
		[2] = "三甲争夺战",
	}

	self:InitContent()
end

function CSchoolMatchBattleListView.InitContent(self)
	self.m_SimpleBattleBox:SetActive(false)
	self.m_BattleBoxClone:SetActive(false)
	self.m_TipL:SetText(DataTools.GetMiscText(1025, "SCHOOLMATCH").content)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_SchoolMatchCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:RefreshAll()
end

function CSchoolMatchBattleListView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SchoolMatch.Event.RefreshBattleList then
		self:RefreshAll()
	end
end

function CSchoolMatchBattleListView.RefreshAll(self)
	self:RefreshTitle()
	self:RefreshBattleGrid()
	self:RefreshStartTime()
end

function CSchoolMatchBattleListView.RefreshTitle(self)
	local sTitle = self.m_TitleText[g_SchoolMatchCtrl:GetMatchStep()]
	self.m_MatchL:SetText(sTitle)
end

function CSchoolMatchBattleListView.CheckAutoClose(self)
	self.m_IsAutoClose = true
	self:RefreshStartTime()
end

function CSchoolMatchBattleListView.RefreshStartTime(self)
	if self.m_RefreshTimer then
		Utils.DelTimer(self.m_RefreshTimer)
		self.m_RefreshTimer = nil
	end
	local function update()
		if Utils.IsNil(self) then
			return
		end
		local iFightTime = g_SchoolMatchCtrl.m_FightTime
		if iFightTime <= 0 then
			if self.m_IsAutoClose then
				self:OnClose()
			end
			self.m_TimeL:SetText("进行中")
			return
		else
			self.m_TimeL:SetText(string.format("比赛[c][ff9600]%d[-][/c]秒开始", iFightTime))
		end
		return true
	end
	self.m_RefreshTimer = Utils.AddTimer(update, 1, 0)	
end

function CSchoolMatchBattleListView.RefreshBattleGrid(self)
	local iCurStep = g_SchoolMatchCtrl:GetMatchStep()
	for k,content in pairs(self.m_Content) do
		content:SetActive(k == iCurStep)
	end
	if iCurStep == 16 then
		self:RefreshSixteenBattleGrid()
	elseif iCurStep == 2 then
		self:RefreshFinalBox()
	else
		local oGrid = self.m_MatchGrid[iCurStep]
		self:RefreshOtherBattleGrid(oGrid)
	end
end

function CSchoolMatchBattleListView.RefreshSixteenBattleGrid(self)
	local oGrid = self.m_MatchGrid[16]
	oGrid:Clear()

	local lBattleInfo = g_SchoolMatchCtrl:GetBattleList()
	for i,dInfo in ipairs(lBattleInfo) do
		local oBox = self:AddSimpleBattleBox(dInfo, oGrid)
	end
	oGrid:Reposition()
end

function CSchoolMatchBattleListView.AddSimpleBattleBox(self, dInfo, oGrid)
	local oBox = self.m_SimpleBattleBox:Clone()
	oBox.m_LNameL = oBox:NewUI(1, CLabel)
	oBox.m_RNameL = oBox:NewUI(2, CLabel)
	oBox.m_StepL = oBox:NewUI(3, CLabel)
	oBox.m_LineSpr = oBox:NewUI(4, CLabel)
	oBox.m_LBgSpr = oBox:NewUI(5, CSprite)
	oBox.m_RBgSpr = oBox:NewUI(6, CSprite)

	oBox.m_LNameL:SetText(dInfo.fighter1.name)
	oBox.m_RNameL:SetText(dInfo.fighter2.name)
	local bIsLose = dInfo.win > 1 and dInfo.win ~= dInfo.fighter1.pid
	oBox.m_LBgSpr:SetGrey(bIsLose)
	bIsLose = dInfo.win > 1 and dInfo.win ~= dInfo.fighter2.pid
	oBox.m_RBgSpr:SetGrey(bIsLose)
	oBox:SetActive(true)
	oBox.m_LBgSpr:AddUIEvent("click", callback(self, "OnClickBattler", dInfo.fighter1, dInfo.win))
	oBox.m_RBgSpr:AddUIEvent("click", callback(self, "OnClickBattler", dInfo.fighter2, dInfo.win))
	oGrid:AddChild(oBox)
	return oBox 
end

function CSchoolMatchBattleListView.RefreshFinalBox(self)
	local lBattleInfo = g_SchoolMatchCtrl:GetBattleList()
	self.m_FirstBattleBox:SetBatteData(lBattleInfo[1])
	self.m_ThirdBattleBox:SetActive(lBattleInfo[2] ~= nil)
	if lBattleInfo[2] then
		self.m_ThirdBattleBox:SetBatteData(lBattleInfo[2])
	end
end

function CSchoolMatchBattleListView.RefreshOtherBattleGrid(self, oGrid)
	oGrid:Clear()
	local lBattleInfo = g_SchoolMatchCtrl:GetBattleList()
	for i,dInfo in ipairs(lBattleInfo) do
		local oBox = self.m_BattleBoxClone:Clone()
		oBox:SetActive(true)
		oBox:SetBatteData(dInfo)
		oGrid:AddChild(oBox)
	end
	oGrid:Reposition()
end

function CSchoolMatchBattleListView.CloseView(self)
	CViewBase.CloseView(self)
	if self.m_RefreshTimer then
		Utils.DelTimer(self.m_RefreshTimer)
		self.m_RefreshTimer = nil
	end 
end

function CSchoolMatchBattleListView.OnClickBattler(self, dInfo, iWin)
	local iFightTime = g_SchoolMatchCtrl.m_FightTime
	local iTextId = 0
	if iWin and iWin > 1 then
		iTextId = 1027
	elseif iFightTime > 0 then
		iTextId = 1026
	else
		netplayer.C2GSObserverWar(1, 0, dInfo.pid)
		self:OnClose()
		return
	end
	g_NotifyCtrl:FloatMsg(DataTools.GetMiscText(iTextId, "SCHOOLMATCH").content)
end

return CSchoolMatchBattleListView
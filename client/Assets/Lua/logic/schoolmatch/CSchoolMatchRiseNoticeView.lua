local CSchoolMatchRiseNoticeView = class("CSchoolMatchRiseNoticeView", CViewBase)

function CSchoolMatchRiseNoticeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/SchoolMatch/SchoolMatchRiseNoticeView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CSchoolMatchRiseNoticeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_OkBtn = self:NewUI(2, CSprite)
	self.m_NoticeL = self:NewUI(3, CLabel)

	self:InitContent()
end

function CSchoolMatchRiseNoticeView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnClose"))

	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlWarEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))

	self:RefreshNotice()
end

function CSchoolMatchRiseNoticeView.OnCtrlWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.WarStart then
		if g_WarCtrl:IsWar() then
			self:CloseView()
		end
	end
end

function CSchoolMatchRiseNoticeView.OnCtrlMapEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.EnterScene then
		if self.m_IsShowLater then
			self:SetActive(true)
			self.m_IsShowLater = false
		end
	end
end

function CSchoolMatchRiseNoticeView.RefreshNotice(self)
	local dEnemy = g_SchoolMatchCtrl:GetEnemyTeam()
	local sStep = ""
	if g_SchoolMatchCtrl.m_MyMatchStep == 2 then
		-- self:SetNotice("恭喜晋级决赛")
		sStep = "获得[00ffff]冠军"
	elseif g_SchoolMatchCtrl.m_MyMatchStep == 4 then
		-- self:SetNotice("恭喜晋级半决赛")
		sStep = "进入[00ffff]决赛"
	else
		-- self:SetNotice("恭喜晋级"..g_SchoolMatchCtrl.m_MyMatchStep.."强")
		sStep = "进入[00ffff]"..(g_SchoolMatchCtrl.m_MyMatchStep/2).."强"
	end
	if dEnemy and dEnemy.name then
		self:SetNotice(string.format("稍后和#I%s#n的队伍进行对战，胜利者%s", dEnemy.name, sStep))
	else
		self:SetNotice(string.format("本轮轮空，稍后%s", sStep))
	end
end

function CSchoolMatchRiseNoticeView.SetNotice(self, sText)
	self.m_NoticeL:SetText(sText)
end

function CSchoolMatchRiseNoticeView.ShowAfterWar(self, bIsShowLater)
	self.m_IsShowLater = bIsShowLater
	if bIsShowLater then
		self:SetActive(false)
	end
end

return CSchoolMatchRiseNoticeView
local CWorldBossMainView = class("CWorldBossMainView", CViewBase)

function CWorldBossMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/WorldBoss/WorldBossMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CWorldBossMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	-- self.m_ChallengeBtn = self:NewUI(2, CButton)
	-- self.m_PlunderBtn = self:NewUI(3, CButton)
	self.m_BossInfoBox = self:NewUI(4, CBox)
	self.m_TabGrid = self:NewUI(5, CGrid)
	self.m_EventTable = self:NewUI(6, CTable)
	self.m_PlayerListBox = self:NewUI(7, CWorldBossPlayerListBox)
	self.m_OrgListBox = self:NewUI(8, CWorldBossOrgListBox)
	self.m_RuleBtn = self:NewUI(9, CButton)

	self.m_StepSprs = {
		[1] = "h7_yijieduan",
		[2] = "h7_erjieduan",
		[3] = "h7_sanjieduan",
		[4] = ""
	}
	self.m_TimesSprs = {
		[1] = "h7_yibei",
		[2] = "h7_erbei",
		[3] = "h7_sanbei"
	}
	self.m_Tab = {
		Sigle = 1,
		Org = 2,
	}
	self.m_ListBoxs = {
		[1] = self.m_PlayerListBox,
		[2] = self.m_OrgListBox,
	}
	self.m_SliderConfig = {
		Fore = {
			[1] = "h7_lv", --深绿-浅绿-黄-红
			[2] = "h7_huanglv", 
			[3] = "h7_cheng", 
			[4] = "h7_hong", 
		},
		Ratio = {
			[1] = 0.7,
			[2] = 0.4,
			[3] = 0.1,
			[4] = 0,
		}
	}
	self.m_CurTab = 0
	self.m_IsChallengeStart = false
	self.m_IsPlunderStart = false
	self:InitContent()
end

function CWorldBossMainView.InitContent(self)
	self:InitBossInfoBox()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	-- self.m_ChallengeBtn:AddUIEvent("click", callback(self, "RequestBossChallenge"))
	-- self.m_PlunderBtn:AddUIEvent("click", callback(self, "OpenPlunderView"))
	self.m_RuleBtn:AddUIEvent("click", callback(self, "OnClicRule"))
	self.m_EventTable:InitChild(function(obj, idx)
		local oLabel = CLabel.New(obj)
		oLabel:SetGroup(self.m_EventTable:GetInstanceID())
		return oLabel
	end)
	self.m_TabGrid:InitChild(function(obj, idx)
			local oBtn = CButton.New(obj)
			oBtn:SetGroup(self:GetInstanceID())
			return oBtn
		end)
	for i,oTab in ipairs(self.m_TabGrid:GetChildList()) do
		oTab:AddUIEvent("click", callback(self, "ChangeTab", i))
	end
	g_WorldBossCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_WorldBossCtrl:StartRefreshTimer(g_WorldBossCtrl.m_RefreshInterval, g_WorldBossCtrl.m_RefreshInterval, true)
	self:ChangeTab(self.m_Tab.Sigle)
end

function CWorldBossMainView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WorldBoss.Event.RefreshPlayerList then
		self.m_PlayerListBox:RefreshAll()
	elseif oCtrl.m_EventID == define.WorldBoss.Event.RefreshOrgList then
		self.m_OrgListBox:RefreshAll()
	elseif oCtrl.m_EventID == define.WorldBoss.Event.RefreshEventList then
		self:RefreshEventList()
	elseif oCtrl.m_EventID == define.WorldBoss.Event.RefreshStepStatus then
		self:RefreshBossInfo()		
		self:RefreshStepSlider()
	end
	self.m_PlayerListBox:RefreshChallengeButton()
	self.m_PlayerListBox:RefreshPlunderButton()
end

--------------------------UI刷新or初始化---------------------------------
function CWorldBossMainView.InitBossInfoBox(self)
	self.m_BossInfoBox.m_TimesSpr = self.m_BossInfoBox:NewUI(1, CSprite)
	self.m_BossInfoBox.m_StepSpr = self.m_BossInfoBox:NewUI(2, CSprite)
	self.m_BossInfoBox.m_ActorTex  = self.m_BossInfoBox:NewUI(3, CActorTexture)
	self.m_BossInfoBox.m_StepSlider = self.m_BossInfoBox:NewUI(4, CSlider)
	self.m_BossInfoBox.m_SliderSpr = self.m_BossInfoBox:NewUI(5, CSprite)
	self.m_BossInfoBox.m_ThumbSpr = self.m_BossInfoBox:NewUI(6, CSprite)
end

function CWorldBossMainView.RefreshBossInfo(self)
	local iModelId = tonumber(DataTools.GetGlobalData(113).value)
	local iStep = g_WorldBossCtrl:GetCurrentStep()
	local iTimes = g_WorldBossCtrl:GetCurrentTimes()

	local oBox = self.m_BossInfoBox
	if not oBox.m_ActorTex:GetCamera() then
		oBox.m_ActorTex:ChangeShape({figure = iModelId})
	end
	oBox.m_TimesSpr:SetSpriteName(self.m_TimesSprs[iTimes] or "")
	oBox.m_StepSpr:SetSpriteName(self.m_StepSprs[iStep] or "")
end

function CWorldBossMainView.RefreshEventList(self)
	local tEventList = g_WorldBossCtrl:GetEventList()

	for i,oLabel in ipairs(self.m_EventTable:GetChildList()) do
		local sEvent = tEventList[i] or ""
		oLabel:SetText(sEvent)
	end
	self.m_EventTable:Reposition()
end

function CWorldBossMainView.RefreshStepSlider(self)
	local iStep = g_WorldBossCtrl:GetCurrentStep()
	local oBox = self.m_BossInfoBox
	if iStep == 0 then
		oBox.m_StepSlider:SetValue(0)
		oBox.m_ThumbSpr:SetActive(false)
		if self.m_StepSlider then
			Utils.DelTimer(self.m_StepTimer)
			self.m_StepTimer = nil
		end
		return
	end
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		local iStep = g_WorldBossCtrl:GetCurrentStep()
		local iBossTime = g_WorldBossCtrl:GetBossStartTime()
		local iElapseTime, iStepTime = DataTools.GetWorldBossStepInfo(iStep, iBossTime)
		local iRatio = iElapseTime/iStepTime
		oBox.m_StepSlider:SetValue(iRatio)
		oBox.m_ThumbSpr:SetActive(iRatio > 0)
		local sFore = self:GetSliderFore(iRatio)
		oBox.m_SliderSpr:SetSpriteName(sFore)
		oBox.m_ThumbSpr:SetSpriteName(sFore.."_1")
		return true
	end
	self.m_StepTimer = Utils.AddTimer(update, 10, 0)
end

function CWorldBossMainView.GetSliderFore(self, iRatio)
	for i, ratio in ipairs(self.m_SliderConfig.Ratio) do
		if iRatio >= ratio then
			return self.m_SliderConfig.Fore[i]
		end
	end
	return self.m_SliderConfig.Fore[1]
end

-----------------------点击事件响应orUI事件监听--------------------------------
function CWorldBossMainView.OnClicRule(self)
	local id = define.Instruction.Config.WorldBoss
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CWorldBossMainView.ChangeTab(self, iTab)
	if iTab == self.m_CurTab then
		return
	end
	-- local oTab = self.m_TabGrid:GetChild(iTab)
	-- oTab:SetSelected(true)
	self.m_CurTab = iTab
	if iTab == self.m_Tab.Sigle then
		nethuodong.C2GSMengzhuOpenPlayerRank()
	else
		nethuodong.C2GSMengzhuOpenOrgRank()
	end
	for i,oBox in ipairs(self.m_ListBoxs) do
		oBox:SetActive(i == iTab)
	end
end
return CWorldBossMainView
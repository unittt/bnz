CMainMenuCtrl = class("CMainMenuCtrl", CCtrlBase)

--notice： MainMenuView的UI操作协助，非数据管理，易混淆
function CMainMenuCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Reset()
	--屏蔽状态禁止操作主界面
	self.m_MaskHandle = {
		InWar = function () return g_WarCtrl:IsWar() end,
		IsSysUI = function () return self.m_CurHideCfg == define.MainMenu.HideConfig.SystemUI end,
		IsPlot = function () return g_PlotCtrl:IsPlaying() or g_MarryPlotCtrl:IsPlayingWeddingPlot() end,
		IsTaskGuide = function () return g_GuideHelpCtrl:CheckTaskGuideState() end,
	} 
	self.m_CurrScore = nil
end

function CMainMenuCtrl.Reset(self)
	self.m_Areas = {}
	self.m_AreaStatus = {}	--记录各区域的展开状态
	self.m_GuideStatus = {}
	self.m_CallBacks = {}
	self.m_FinishCbs = {}
	self.m_AreaPlaying = {}
	self.m_MainViewRef = nil
	-- 当前展开列表
	self.m_CurFunctionAreaList = {define.MainMenu.AREA.Function_1, define.MainMenu.AREA.Temp}
	self.m_CurHideCfg = nil
	self.m_IsExpand = true
	self.m_IsActive = true
	self.m_IsPlaying = false
	self.m_HasInited = false 
	self.m_IsHideTask = false
end

function CMainMenuCtrl.Clear(self)
	self:ShowAllArea()
	self.m_CurFunctionAreaList = {define.MainMenu.AREA.Function_1, define.MainMenu.AREA.Temp}
	self.m_HasInited = false
	self.m_IsExpand = true
	self.m_IsActive = true
	self.m_IsPlaying = false
	self.m_IsHideTask = false
	self.m_NotShowTaskArea = false
end

function CMainMenuCtrl.SetMainMenu(self, oView)
	self.m_MainViewRef = weakref(oView)
end

function CMainMenuCtrl.SetCurrentFunctionArea(self, iAreaList)
	self.m_CurFunctionAreaList = iAreaList
end

function CMainMenuCtrl.AddPopArea(self, iArea, UI, callback, bIsExpand, finishCb)
	self.m_Areas[iArea] = UI
	if bIsExpand ~= nil then
		self.m_AreaStatus[iArea] = bIsExpand

		if bIsExpand then
			local function delay()
				self.m_GuideStatus[iArea] = true
				g_GuideCtrl:OnTriggerAll()
				return false
			end
			Utils.AddTimer(delay, 1, 0)		
		else
			self.m_GuideStatus[iArea] = bIsExpand
			if iArea == define.MainMenu.AREA.Task and self.m_HideTask then
				self.m_AreaStatus[iArea] = true
				self:HideArea(iArea)
			end
		end
	else
		self.m_AreaStatus[iArea] = true

		local function delay()
			self.m_GuideStatus[iArea] = true
			g_GuideCtrl:OnTriggerAll()
			return false
		end
		Utils.AddTimer(delay, 1, 0)	
	end
	self.m_CallBacks[iArea] = callback
	self.m_FinishCbs[iArea] = finishCb
end

function CMainMenuCtrl.ShowArea(self, iArea)
	if not self.m_Areas[iArea] then
		return
	end
	if self:IsMaskShow(iArea) then
		return
	end
	if not self.m_AreaStatus[iArea] then 
		local function finish()
			self.m_AreaPlaying[iArea] = false
			if table.index(self.m_CurFunctionAreaList, iArea) then
				self.m_IsPlaying = false
			end
			if self.m_FinishCbs[iArea] then
				self.m_FinishCbs[iArea]()
			end
		end 
		self.m_Areas[iArea].onFinished = finish
		self.m_Areas[iArea]:Play(false)
		self.m_AreaPlaying[iArea] = true
		self.m_AreaStatus[iArea] = true
		if self.m_CallBacks[iArea] then
			self.m_CallBacks[iArea]()
		end
		local function delay()
			self.m_GuideStatus[iArea] = true
			g_GuideCtrl:OnTriggerAll()
			return false
		end
		Utils.AddTimer(delay, 1, 0.5)	
		if iArea == define.MainMenu.AREA.Task and self.m_HideTask then
			self.m_HideTask = false
		end
	end
end

function CMainMenuCtrl.HideArea(self, iArea)
	--暂时屏蔽
	if iArea == define.MainMenu.AREA.Task and not g_GuideCtrl:IsGuideDone() then
		return
	end
	if not self.m_Areas[iArea] then
		return
	end
	if self.m_AreaStatus[iArea] then 
		local function finish()
			self.m_AreaPlaying[iArea] = false
			if table.index(self.m_CurFunctionAreaList, iArea) then
				self.m_IsPlaying = false
			end
			if self.m_FinishCbs[iArea] then
				self.m_FinishCbs[iArea]()
			end
		end 
		self.m_Areas[iArea].onFinished = finish
		self.m_Areas[iArea]:Play(true)
		self.m_AreaPlaying[iArea] = true
		self.m_AreaStatus[iArea] = false
		self.m_GuideStatus[iArea] = false
		if self.m_CallBacks[iArea] then
			self.m_CallBacks[iArea]()
		end
	end
end

function CMainMenuCtrl.ShowAllArea(self)
	if not self.m_IsActive or self.m_MaskHandle.InWar() or self.m_MaskHandle.IsPlot() then
		-- printc("ShowAllArea return")
		return
	end
	-- printc("ShowAllArea")
	self.m_IsPlaying = true
	self.m_IsExpand = true
	g_ViewCtrl:RemoveGroupHide(CMainMenuView:GetView())
	self.m_CurHideCfg = nil
	for iArea, ui in pairs(self.m_Areas) do
		if iArea == define.MainMenu.AREA.Function_1 or iArea == define.MainMenu.AREA.Temp or iArea == define.MainMenu.AREA.Function_2 then
			if table.index(self.m_CurFunctionAreaList, iArea) then
				self:ShowArea(iArea)
			end
		elseif iArea == define.MainMenu.AREA.Task then
			if not self.m_HideTask then
				self:ShowArea(iArea)
			end
		else
			self:ShowArea(iArea)	
		end
	end
	self:SetHideBtnEffShow(true)
end

function CMainMenuCtrl.HideAreas(self, tHideConfig)
	if not g_GuideCtrl:IsGuideDone() then
		printc("HideAreas return 1")
		return
	end
	if g_GuideHelpCtrl:CheckTaskGuideState() then
		printc("HideAreas return 2")
		return
	end
	if not self.m_IsActive or self.m_MaskHandle.InWar() then
		printc("HideAreas return 3")
		return
	end
	-- printc("HideAreas")
	self.m_IsExpand = false
	self.m_IsPlaying = true
	self.m_CurHideCfg = tHideConfig
	for k,iArea in pairs(tHideConfig) do
		self:HideArea(iArea)
	end
	self:SetHideBtnEffShow(false)
end

function CMainMenuCtrl.ShowMainMenu(self, bIsShow)
	local oView = getrefobj(self.m_MainViewRef)
	if oView then
		oView:ShowAllArea(bIsShow)
	end
	self.m_IsActive = bIsShow
end

function CMainMenuCtrl.ShowMainFunctionArea(self)
	self:HideArea(define.MainMenu.AREA.Function_2)
	self:ShowArea(define.MainMenu.AREA.Function_1)
	self:ShowArea(define.MainMenu.AREA.Temp)
	self:SetCurrentFunctionArea({define.MainMenu.AREA.Function_1, define.MainMenu.AREA.Temp})
end

function CMainMenuCtrl.ShowMainFunctionAreaInverse(self)
	--暂时屏蔽
	-- if not g_GuideCtrl:IsGuideDone() then return end
	self:HideArea(define.MainMenu.AREA.Function_1)
	self:HideArea(define.MainMenu.AREA.Temp)
	self:ShowArea(define.MainMenu.AREA.Function_2)
	self:SetCurrentFunctionArea({define.MainMenu.AREA.Function_2})
end

--登录时处理按钮显示
function CMainMenuCtrl.SetRBFunctionAreaShow(self)
	if self.m_HasInited or not self.m_IsActive or self.m_MaskHandle.InWar() then
		return
	end
	local iShowId1 = define.MainMenu.AREA.Function_1
	local iShowId2 = define.MainMenu.AREA.Temp
	local iHideId = define.MainMenu.AREA.Function_2
	local oTween = self.m_Areas[iHideId]
	local duration = oTween.duration
	self:ShowArea(iShowId1)
	self:ShowArea(iShowId2)
	self:SetCurrentFunctionArea({iShowId1, iShowId2})
	self.m_AreaStatus[iHideId] = false
	oTween.duration = 0.01
	oTween:PlayForward()
	oTween.duration = duration
	self.m_HasInited = true
end

function CMainMenuCtrl.GetAreaStatus(self, iArea)
	return self.m_AreaStatus[iArea]
end

function CMainMenuCtrl.IsAreaPlaying(self, iArea)
	return self.m_AreaPlaying[iArea]
end

function CMainMenuCtrl.ShowScore(self, score)
	-- body
	self.m_CurrScore = score
	self:OnEvent(define.Rank.Event.UpdataScore)
end

function CMainMenuCtrl.IsMaskHandle(self)
	for i,func in pairs(self.m_MaskHandle) do
		if func() then
			printc(i)
			return true
		end
	end
	return false
end

function CMainMenuCtrl.HideTaskArea(self)
	self:HideArea(define.MainMenu.AREA.Task)
	self.m_HideTask = true
end

function CMainMenuCtrl.ResetTaskArea(self)
	if self.m_HideTask then
		self:ShowArea(define.MainMenu.AREA.Task)
	end
end

function CMainMenuCtrl.IsExpand(self)
	return self.m_IsExpand
end

function CMainMenuCtrl.RefreshDoublePoint(self, data)
	--self:OnEvent(define.Rank.Event.DoubleP, data)
	local oView = CMainMenuView:GetView()
	if oView then
		oView.m_LT:RealTimeDoublePoint(data)
	end
end

function CMainMenuCtrl.IsMaskShow(self, iArea)
	if g_MapCtrl:IsInOrgMatchMap() then
		for i, area in ipairs(define.MainMenu.HideConfig.OrgMatch) do
			if iArea == area then
				return true
			end
		end
	end
	if iArea == define.MainMenu.AREA.Task and self.m_NotShowTaskArea then
		self.m_NotShowTaskArea = false
		return true
	end
	return false
end

function CMainMenuCtrl.HideFlyBtn(self)
	
	local oView = CMainMenuView:GetView()
	if oView then
		oView.m_RB:HideFlyBtn()
	end

end

function CMainMenuCtrl.SetHideBtnEffShow(self, bShow)
	local oView = CMainMenuView:GetView()
	if oView and oView.m_RB then
		oView.m_RB:SetHideBtnEffShow(bShow)
	end
end

return CMainMenuCtrl
local CMainMenuExpandBox = class("CMainMenuExpandBox", CBox)

function CMainMenuExpandBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Content = self:NewUI(1, CObject)
	self.m_PopRedSpr = self:NewUI(2, CSprite)
	self.m_PopBtn = self:NewUI(3, CSprite)
	self.m_TeamBtn = self:NewUI(4, CSprite)
	self.m_TaskBtn = self:NewUI(5, CSprite)
	self.m_TaskPart = self:NewPage(6, CExpandTaskPart)
	self.m_TeamPart = self:NewPage(7, CExpandTeamPart)
	self.m_BonfireBtn = self:NewUI(8, CButton)
	self.m_BonfirePart = self:NewPage(9, CExpandBonfirePart)
	self.m_BiwuBtn = self:NewUI(10, CButton)
	self.m_BiwuPart = self:NewPage(11, CPkInfoPart)
	self.m_SchoolMatchBtn = self:NewUI(12, CButton)
	self.m_SchoolMatchPart = self:NewPage(13, CExpandSchoolMatchPart)
	self.m_TaskRedPoint = self:NewUI(14, CSprite)
	self.m_ThreeBiwuBtn = self:NewUI(15, CButton)
	self.m_ThreeBiwuPart = self:NewPage(16, CExpandThreeBiwuPart)
	self.m_FubenBtn = self:NewUI(17, CButton)
	self.m_FubenPart = self:NewPage(18, CExpandDungeonPart)
	self.m_JyFubenBtn = self:NewUI(19, CButton)
	self.m_JyFubenPart = self:NewPage(20, CExpandJyDungeonPart)
	self.m_ZhenmoBtn = self:NewUI(21, CButton)
	self.m_ZhenmoPart = self:NewPage(22, CZhenmoPart)
	self.m_SingleBiwuBtn = self:NewUI(23, CButton)
	self.m_SingleBiwuPart = self:NewPage(24, CExpandSingleBiwuPart)

	self.m_ActivityPart = {
		["bonfire"] = { btn = self.m_BonfireBtn, part = self.m_BonfirePart},
		["biwu"] = {btn = self.m_BiwuBtn, part = self.m_BiwuPart},
		["schoolmatch"] = {btn = self.m_SchoolMatchBtn, part = self.m_SchoolMatchPart},
		["threebiwu"] = {btn = self.m_ThreeBiwuBtn, part = self.m_ThreeBiwuPart},
		["fuben"] = {btn = self.m_FubenBtn, part = self.m_FubenPart},
		["jyFuben"] = {btn = self.m_JyFubenBtn, part = self.m_JyFubenPart},
		["singlebiwu"] = {btn = self.m_SingleBiwuBtn, part = self.m_SingleBiwuPart},
		["zhenmo"] = {btn = self.m_ZhenmoBtn, part = self.m_ZhenmoPart},
	}

	self.m_NeedRefreshDict = {
		[define.Team.Event.NotifyApply] = true,
		[define.Team.Event.NotifyInvite] = true, 
		[define.Team.Event.ClearApply] = true,
		[define.Team.Event.AddTeam] = true,
		[define.Team.Event.ClearInvite] = true, 
	}

	self.m_IsArrowPop = false
	self.m_IsWar = false
	self.m_CurActivity = nil

	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskEvent"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamEvent"))
	g_BonfireCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnBonfireEvent"))
	g_PKCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPkEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
	g_SchoolMatchCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSchoolMatchEvent"))
	g_DungeonTaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnDungeonTaskEvent"))
	g_FormationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFormationEvent"))

	self.m_PopBtn:AddUIEvent("click", callback(self, "OnPopBtn"))
	self.m_TeamBtn:AddUIEvent("click", callback(self, "OnTeamBtn"))
	self.m_TaskBtn:AddUIEvent("click", callback(self, "OnTaskBtn"))

	self.m_TeamBtn:SetGroup(self:GetInstanceID())
	self.m_TaskBtn:SetGroup(self:GetInstanceID())
	for k,dActivity in pairs(self.m_ActivityPart) do
		dActivity.btn:SetGroup(self:GetInstanceID())
		dActivity.btn:SetActive(false)
		dActivity.btn:AddUIEvent("click", callback(self, "OnActivity", k))
	end
end

function CMainMenuExpandBox.Destroy(self)
	self.m_BonfirePart:Destroy()
	CBox.Destroy(self)
end

function CMainMenuExpandBox.InitContent(self)
	self:RefreshUI()

	self:RefreshPop()
end

function CMainMenuExpandBox.RefreshPop(self)
	local function delay()
		if not self.m_IsWar and not g_MainMenuCtrl.m_HideTask and not g_WarCtrl:IsWar() then --and g_MainMenuCtrl:IsExpand()
			g_MainMenuCtrl:ShowArea(define.MainMenu.AREA.Task)
		end
		return false
	end
	Utils.AddTimer(delay, 1, 0.5)
end

function CMainMenuExpandBox.RefreshUI(self)
	if g_BonfireCtrl.m_IsBonfireScene then
		self:ShowActivityBtn("bonfire")
	else
		self:HideActivityBtn()
	end

	if g_PKCtrl.m_MyRankInfo then
	   self:ShowActivityBtn("biwu")
	end

	if g_SchoolMatchCtrl.m_ActivityMap == g_MapCtrl.m_MapID and g_SchoolMatchCtrl:GetMyRankInfo() then
		self:ShowActivityBtn("schoolmatch")
	end

	if data.biwutextdata.THREEBIWUSCENE[1001].map_id == g_MapCtrl.m_MapID then
		self:ShowActivityBtn("threebiwu")
	end

    if g_DungeonTaskCtrl:IsInCommonFuben() then
   		self:ShowActivityBtn("fuben")
   	elseif g_DungeonTaskCtrl:IsInJyFuben() then
   		self:ShowActivityBtn("jyFuben")
   	end

   	if g_MapCtrl:IsInSingleBiwuMap() then
   		self:ShowActivityBtn("singlebiwu")
   	end

   	if g_ZhenmoCtrl:IsInZhenmoTask() then
   		--self:ShowActivityBtn("zhenmo")
   		Utils.AddTimer(function()
   			self:ShowActivityBtn("zhenmo")
   		end, 0, 0.2)
   	end

	self:BindMenuArea()
	self:RefrehNotifyTip()

	self.m_TaskRedPoint:SetActive(not g_TaskCtrl:GetIsAllChapterPrizeRewarded()) --not g_TaskCtrl:GetIsAllAceTaskRead()
end

function CMainMenuExpandBox.SetWarModel(self, bIsWar)
	self.m_IsWar = bIsWar
	self:RefreshUI()
end

function CMainMenuExpandBox.BindMenuArea(self)
	-- if self.m_IsWar then
	-- 	return
	-- end
	local tweenTaskPos = self.m_Content:GetComponent(classtype.TweenPosition)
	local tweenRotation = self.m_PopBtn:GetComponent(classtype.TweenRotation)
	local tweenAlpha = self.m_PopBtn:GetComponent(classtype.TweenAlpha)
	local callback = function()
		if g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Task) then
			self.m_TaskPart:CullContent()

			if self.m_FindMainBoxTimer then
				Utils.DelTimer(self.m_FindMainBoxTimer)
				self.m_FindMainBoxTimer = nil
			end
			if self.m_TaskPart.m_MainTaskBox then
				self.m_TaskPart:OnDelayRepositionTable(1)
				g_GuideCtrl:AddGuideUI("task_btn_story", self.m_TaskPart.m_MainTaskBox.m_TaskBgBtn)
			else
				local function onFind()					
					if not Utils.IsNil(self.m_TaskPart.m_MainTaskBox) then
						self.m_TaskPart:OnDelayRepositionTable(1)
						g_GuideCtrl:AddGuideUI("task_btn_story", self.m_TaskPart.m_MainTaskBox.m_TaskBgBtn)
						return false
					end
					return true
				end
				self.m_FindMainBoxTimer = Utils.AddTimer(onFind, 0.1, 0.1)
			end
		end
		tweenRotation:Play(g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Task))
	end
	local aniDone = function()
		if self.m_TaskPart:IsInit() and not self.m_TaskPart:CheckShineEffect() then
			self.m_TaskPart:OnRepositionTable()
		end
	end
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Task, tweenTaskPos, callback, false, aniDone)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.PopBtn, tweenAlpha, callback)
end

--------------------Ctrl Event------------------------------------
function CMainMenuExpandBox.OnTaskEvent(self, oCtrl)
	--以后要根据需求修改，目前只有可接任务有红点
	if oCtrl.m_EventID == define.Task.Event.RedPointNotify then
		self.m_TaskRedPoint:SetActive(not g_TaskCtrl:GetIsAllChapterPrizeRewarded()) --not g_TaskCtrl:GetIsAllAceTaskRead()
	elseif oCtrl.m_EventID == define.Task.Event.AddTask then
		if not self.m_CurActivity then
			self:ShowTaskPart()
		end
	end
end

function CMainMenuExpandBox.OnTeamEvent(self, oCtrl)
	if self.m_NeedRefreshDict[oCtrl.m_EventID] then
		self:RefrehNotifyTip()
	end
	if oCtrl.m_EventID == define.Team.Event.AddTeam then
		if (oCtrl.m_EventData and oCtrl.m_EventData.isCreate) or g_TeamCtrl:IsInTeam() then
			self:ShowTeamPart()
		end
	end
end

function CMainMenuExpandBox.OnBonfireEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Bonfire.Event.EndBonfireActive then
		self:HideActivityBtn("bonfire")
    end

    if oCtrl.m_EventID == define.Bonfire.Event.UpdateBonfireExp then
        self.m_BonfirePart:SetInfo(oCtrl.m_EventData)
    end
    if oCtrl.m_EventID == define.Bonfire.Event.SwitchScene then

    end
end

function CMainMenuExpandBox.OnPkEvent(self, oCtrl)
	if oCtrl.m_EventID == define.PkAction.Event.updateInfo then
       self:ShowActivityBtn("biwu")
    end
end

function CMainMenuExpandBox.OnMapEvent(self, oCtrl)
   	if oCtrl.m_EventID == define.Map.Event.EnterScene then
   		-- temp
   		if g_SchoolMatchCtrl.m_ActivityMap == oCtrl.m_MapID and not g_SchoolMatchCtrl:GetMyRankInfo() then
       	  	printc("----------- match ctrl  not get rank info ------------")
       	end
       	-----
       	if g_PKCtrl.m_pkMapId == oCtrl.m_MapID  then
       	  	if g_WarCtrl:IsWar() then
       	  	 	self:HideActivityBtn()
       	     	return
       	  	end
          	self:ShowActivityBtn("biwu")
       	elseif g_SchoolMatchCtrl.m_ActivityMap == oCtrl.m_MapID and g_SchoolMatchCtrl:GetMyRankInfo() then
       	  	self:ShowActivityBtn("schoolmatch")
       	elseif data.biwutextdata.THREEBIWUSCENE[1001].map_id == oCtrl.m_MapID then
       	  	self:ShowActivityBtn("threebiwu")
       	elseif g_BonfireCtrl.m_IsBonfireScene and not g_WarCtrl:IsWar() then
       	  	self:ShowActivityBtn("bonfire")
       	elseif g_DungeonTaskCtrl:IsInCommonFuben() then
       		self:ShowActivityBtn("fuben")
       	elseif g_DungeonTaskCtrl:IsInJyFuben() then
       		self:ShowActivityBtn("jyFuben")
       	elseif g_MapCtrl:IsInSingleBiwuMap() then
       		self:ShowActivityBtn("singlebiwu")
       	elseif g_ZhenmoCtrl:IsInZhenmoTask() then
       		Utils.AddTimer(function()
       			local oTask = g_TaskCtrl:GetZhenmoTask()
       			if oTask then
       				self:ShowActivityBtn("zhenmo")
       			else
       				self:HideActivityBtn()
       			end
       		end, 0, 0.1)
       		
       		 -- todo --
       	else
       		if g_SchoolMatchCtrl:GetGameStep() == define.SchoolMatch.Step.End then
       			printc(" --------- sch match end ----------- ")
       			g_SchoolMatchCtrl:Reset()
       		end
          	self:HideActivityBtn()
	   	end
   	end
end

function CMainMenuExpandBox.OnSchoolMatchEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SchoolMatch.Event.RefreshMyRank then
		self:ShowActivityBtn("schoolmatch")
	end
end

function CMainMenuExpandBox.OnDungeonTaskEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Dungeon.Event.ReceiveFubenTask then
		self:ShowActivityBtn("fuben")
	elseif oCtrl.m_EventID == define.Dungeon.Event.ReceiveJyFubenTask then
		self:ShowActivityBtn("jyFuben")
	elseif oCtrl.m_EventID == define.Dungeon.Event.DelFubenTask then
		if self.m_CurActivity == "fuben" or self.m_CurActivity == "jyFuben" then
			self:HideActivityBtn()
		end
	end
end

function CMainMenuExpandBox.OnFormationEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Formation.Event.RefreshGuildStatus then
		self:RefreshTeamBtnGuide()
	end
end

--------------------UI refresh-------------------------------
function CMainMenuExpandBox.RefrehNotifyTip(self)
	local bTip = false
	if g_TeamCtrl:IsJoinTeam() then 
		bTip = table.count(g_TeamCtrl.m_Applys) > 0 and g_TeamCtrl:IsLeader()
	else
		bTip = false--table.count(g_TeamCtrl.m_Invites) > 0 and not g_TeamCtrl.m_IsClickInvite
	end
	if bTip then
		self.m_PopRedSpr:SetActive(true)
	else
		self.m_PopRedSpr:SetActive(false)
	end
end

function CMainMenuExpandBox.ShowTaskPart(self)
	self.m_TaskBtn:SetSelected(true)
	self.m_TeamBtn:SetSelected(false)
	self:ShowSubPage(self.m_TaskPart)
end

function CMainMenuExpandBox.ShowTeamPart(self)
	self.m_TeamBtn:SetSelected(true)
	self:ShowSubPage(self.m_TeamPart)
end

function CMainMenuExpandBox.ShowActivityBtn(self, sActivity)
	if sActivity == "biwu" and g_PKCtrl.m_pkMapId ~= g_MapCtrl:GetMapID() then
	   return
	end
	self.m_TaskBtn:SetActive(false)
	self.m_TeamBtn:ForceSelected(false)
	for k,dActivity in pairs(self.m_ActivityPart) do
		dActivity.btn:SetActive(k == sActivity)
	end
	self:ShowActivityPart(sActivity)
	self.m_CurActivity = sActivity
end

function CMainMenuExpandBox.HideActivityBtn(self, sActivity)
	if sActivity and self.m_CurActivity ~= sActivity then
		return
	end
	self.m_TaskBtn:SetActive(true)
	self.m_TaskBtn:ForceSelected(false)
	if self.m_TeamBtn:GetSelected() then
		self:ShowTeamPart()
	else
		self:ShowTaskPart()
	end
	for k,dActivity in pairs(self.m_ActivityPart) do
		dActivity.btn:SetActive(false)
	end
	self.m_CurActivity = nil
end

function CMainMenuExpandBox.ShowActivityPart(self, sActivity)
	self.m_TaskBtn:SetSelected(false)
	local dActivity = self.m_ActivityPart[sActivity]
	if dActivity then
		dActivity.btn:SetActive(true)
		dActivity.btn:SetSelected(true)
		self:ShowSubPage(dActivity.part)  
	end
end

function CMainMenuExpandBox.RefreshTeamBtnGuide(self)
	if g_FormationCtrl.m_NeedGuideLearn then
		self.m_TeamBtn.m_IgnoreCheckEffect = true
		self.m_TeamBtn:AddEffect("Rect")
	else
		self.m_TeamBtn:DelEffect("Rect")
	end
end

-----------------------UI click event---------------------------------
function CMainMenuExpandBox.OnActivity(self, sActivity)
	local dActivity = self.m_ActivityPart[sActivity]
	if dActivity then
		if sActivity == "zhenmo" and self.m_ZhenmoBtn:GetSelected() then
			self:OnTaskBtn()
		end
		dActivity.btn:SetActive(true)
		self.m_TaskBtn:SetActive(false)
		self:ShowActivityPart(sActivity)
	end

end

function CMainMenuExpandBox.OnPopBtn(self)
	-- 点击主界面扩展弹出缩进按钮
	-- self:Pop()
	g_TaskCtrl:SetTaskRectEffect()
	
	-- if self.m_IsWar then
	-- 	printc("战斗中")
	-- 	local tweenPos = self.m_Content:GetComponent(classtype.TweenPosition)
	-- 	local tweenRotation = self.m_PopBtn:GetComponent(classtype.TweenRotation)
	-- 	tweenPos:Toggle()
	-- 	tweenRotation:Toggle()
	-- 	return
	-- end
	if g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Task) then
		if g_GuideHelpCtrl:CheckTaskGuideState() then
			return
		end
		g_MainMenuCtrl:HideArea(define.MainMenu.AREA.Task)
	else
		g_MainMenuCtrl:ShowArea(define.MainMenu.AREA.Task)
	end
end

function CMainMenuExpandBox.OnTeamBtn(self, oBtn)
	--跳舞允许操作
	-- if g_DancingCtrl.m_StateInfo then
	--    g_NotifyCtrl:FloatMsg("你正在舞会中，不可组队")
	--    return
	-- end
	if self.m_TeamBtn:GetSelected() then
		CTeamMainView:ShowView()
	else
		self:ShowTeamPart()
	end
end

function CMainMenuExpandBox.OnTaskBtn(self, oBtn)
	--引导有做一些特殊处理
	if self.m_TaskBtn:GetSelected() then -- or not g_GuideCtrl:IsGuideDone()
		CTaskMainView:ShowView(function (oView)
			oView:OnShowPieceView()
		end)
	else
		self:ShowTaskPart()
	end
end

return CMainMenuExpandBox
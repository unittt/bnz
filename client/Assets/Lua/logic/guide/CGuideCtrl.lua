local CGuideCtrl = class("CGuideCtrl", CCtrlBase)

function CGuideCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_UIRefs = {}
	self.m_Flags = {}
	self.m_SwipeCancel = {}
	self.m_CheckTypes = {}
	self.m_UpdateInfo = {}
	self.m_IsInit = false
	self.m_Test = false
	self.m_IsOpenTips = false
	self.m_FloatItemList = nil
	self.m_EndCbList = {}
	if self.m_Test then
		self:LoginInit({})
	end
	self:ResetUpdateInfo()
	self.m_TaskNotifyExecute = false

	self.m_WarType = "Guide1"
	self.m_WarGuide = "War3"
	self.m_OrgChatGuideType = "OrgChat"
	--不强制显示主界面的引导列表
	self.m_NotCheckMainMenuGuideList = {"War3"} --"TouXian"
	self.m_MainMenuRbBackList = {} --"TouXian"
	self.m_NotCheckWarGuideList = {"War3"}
	self.m_NotCloseViewList = {"CScoreShowView", "CNpcShowView", "CItemQuickUseView", "CGuideSelectView", "CGuideSelectSummonView", "CGuideView", "CNotifyView", "CMainMenuView", "CWarMainView", "CWarBg", "CWarBgSky",
	"CMapFadeView", "CGhostEyeView", "CWarFloatView", "CWarItemView", "CWarMagicView", "CWindowNetComfirmView", "CDancingActivityView", "CNpcCloseUpView", "CInteractionView", "CGuideNotifyView", "CMasterJudgeView", 
	"CWindowComfirmView", "CWindowJieBaiConfirmView"}
end

function CGuideCtrl.Clear(self)
	self.m_IsInit = false
	self.m_EndCbList = {}
	self.m_TaskNotifyExecute = false
	self:ResetCurGuide()
end

function CGuideCtrl.ResetUpdateInfo(self)
	self:SetGuideKey(nil)
	self.m_UpdateInfo = {
		guide_type = nil,
		guide_key = nil,
		cur_idx = 1,
		continue_condition = nil,
		complete_type = 0,
		after_process = nil
	}
	self.m_DelayTimer = nil
end

function CGuideCtrl.OnTriggerAll(self)
	g_GuideCtrl:TriggerCheck("war")
	g_GuideCtrl:TriggerCheck("task")
	g_GuideCtrl:TriggerCheck("view")
	g_GuideCtrl:TriggerCheck("grade")	
end

function CGuideCtrl.IsGuideDone(self)
	return not next(self.m_CheckTypes) and not self.m_UpdateInfo.guide_type
end

--触发式检测，非Update
function CGuideCtrl.TriggerCheck(self, sTrigger)
	if not self.m_IsInit then
		if self.m_IsOpenTips then
			printc("CGuideCtrl.TriggerCheck not init")
		end
		return
	end
	--暂时屏蔽
	-- if self.m_IsOpenTips then
	-- 	printc("CGuideCtrl.TriggerCheck-->", sTrigger)
	-- 	table.print(self.m_Flags, "self.m_Flags")
	-- end
	local lGuideTypes = {}
	if g_GuideHelpCtrl:CheckHasSelect() and not self:CheckGuideOtherCondition() then
		if g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("notplay") then
			lGuideTypes = CGuideData.Trigger_Check_NotPlay[sTrigger] or {}
		elseif g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("hasplay") then
			lGuideTypes = CGuideData.Trigger_Check_HasPlay[sTrigger] or {}
		end
	end
	local lTypes = {}
	for i, sGuideType in ipairs(lGuideTypes) do
		if self:IsNeedGuide(sGuideType) then
			local sCondition = CGuideData[sGuideType].necessary_condition
			if not sCondition or self:CallGuideFunc(sCondition) then
				table.insert(lTypes, sGuideType)
			end
		end
	end
	if next(lTypes) then
		self.m_CheckTypes[sTrigger] = lTypes
		self:StartCheck()
	else
		self.m_CheckTypes[sTrigger] = nil
	end
	self:OnEvent(define.Guide.Event.State)
end

--重置当前引导
function CGuideCtrl.ResetCurGuide(self)
	local bNeedClose = false
	if g_GuideCtrl.m_UpdateInfo.guide_type then
		bNeedClose = true
		g_GuideCtrl:RestartGuide(g_GuideCtrl.m_UpdateInfo.guide_type)
	end		
	g_GuideCtrl.m_CheckTypes = {}
	g_GuideCtrl:ResetUpdateInfo()
	g_GuideCtrl:OnEvent(define.Guide.Event.State)
	local oGuideView = CGuideView:GetView()
	if oGuideView then
		oGuideView:ResetGuideUI()
	end
	if bNeedClose then
	end
	CGuideView:CloseView()
	CGuideView:ShowView()
end

function CGuideCtrl.CheckTeamGuide(self)
	if g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeader() then
		self:ResetCurGuide()
	end
	g_GuideCtrl:OnTriggerAll()
end

function CGuideCtrl.RestartGuide(self, sGuideType)
	for k, _ in pairs(self.m_Flags) do
		if string.find(k, sGuideType) then
			self.m_Flags[k] = nil
		end
	end
end

function CGuideCtrl.CheckCurGuide(self)
	if not self.m_UpdateInfo.guide_type then
		return false
	end
	local sGuideType = self.m_UpdateInfo.guide_type
	local sGuideData = CGuideData[sGuideType]
	local sCondition = sGuideData.necessary_condition
	if not sCondition or self:CallGuideFunc(sCondition) then
		local oHero = g_MapCtrl:GetHero()
		if oHero and oHero.m_IsWalking then oHero:StopWalk() end
		if self.m_UpdateInfo.guide_key then
			if self.m_UpdateInfo.continue_condition then--检查继续条件
				if self:CallGuideFunc(self.m_UpdateInfo.continue_condition) then
					self:Continue()
				end
			end
			return true 
		end
		local iStart = self.m_UpdateInfo.cur_idx or 1
		local lGuides = sGuideData.guide_list
		for i = iStart, #lGuides do
			local v = lGuides[i]
			v["guide_key"] = sGuideType.."_"..tostring(i)
			if self:IsNeedGuide(v.guide_key) then
				if not v.start_condition or self:CallGuideFunc(v.start_condition) then
					if self.m_IsOpenTips then
						printc("开始引导了", v["guide_key"])
					end
					
					self.m_DelayTimer = nil
					self:StartGuide(v)--有一个满足条件, 则后面都不检查
					-- self.m_UpdateInfo.cur_idx = i
					break
				end
				
			end
		end
		return true
	else
		--这里可使引导重复执行
		-- if self.m_UpdateInfo.complete_type == 1 then
		-- 	self:RestartGuide(sGuideType)
		-- end
		self:ResetUpdateInfo() --没满足必备条件，重置引导
		self:OnEvent(define.Guide.Event.State)
		return false
	end
end

function CGuideCtrl.Update(self)
	-- if self.m_IsOpenTips then
	-- 	printc("CGuideCtrl.Update")
	-- end
	if g_GuideHelpCtrl:CheckHasSelect() and not self:CheckGuideOtherCondition() then
		if self:CheckCurGuide() then --一次只执行一个引导
			return true
		end
		for k, list in pairs(self.m_CheckTypes) do
			local lNewList = {}
			for i, sGuideType in ipairs(list) do
				if self:IsNeedGuide(sGuideType) then
					local sGuideData = CGuideData[sGuideType]
					local sCondition = sGuideData.necessary_condition
					if not sCondition or self:CallGuideFunc(sCondition) then --找到新引导
						-- g_NetCtrl:SetCacheProto("guide", true)
						printc("找到新的引导类型", sGuideType)
						self.m_UpdateInfo.guide_type = sGuideType
						self.m_UpdateInfo.complete_type = sGuideData.complete_type
						self.m_UpdateInfo.cur_idx = 1
						self.m_DelayTimer = nil
						self:OnEvent(define.Guide.Event.State)
						return true
					end
					table.insert(lNewList, sGuideType)
				end
			end
			if #lNewList > 0 then
				self.m_CheckTypes[k] = lNewList
			else
				self.m_CheckTypes[k] = nil
			end
			self:OnEvent(define.Guide.Event.State)
		end
	end
	if next(self.m_CheckTypes) then
		return true
	else
		self.m_Timer = nil
		-- g_NetCtrl:SetCacheProto("guide", false)
		-- g_NetCtrl:ClearCacheProto("guide", true)
		self:ExecuteEndCallback()
		self:OnEvent(define.Guide.Event.State)
		printc("停止引导检查")
		return false
	end
end

--检查引导需要其他外在的条件
function CGuideCtrl.CheckGuideOtherCondition(self)
	if g_OpenSysCtrl.m_IsSysOpenShowing or g_InteractionCtrl.IsShowing or g_MapCtrl.m_IsNpcCloseUp or g_MapCtrl:CheckIsInActivityMap() then
		return true
	end
	if g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeader() then
		return true
	end
	local sCondition = CGuideData[self.m_WarGuide].necessary_condition
	if g_WarCtrl:IsWar() and self:IsNeedGuide(self.m_WarGuide) and self:CallGuideFunc(sCondition) then
		return false
	end
	if g_WarCtrl:IsWar() then
		return true
	end
	return false
end

function CGuideCtrl.ExecuteEndCallback(self)
	if self:IsGuideDone() then
		--特殊处理
		for k,v in pairs({10, 20, 30, 40}) do
			if g_GuideHelpCtrl.m_IsOnlineClickGradeGift[v] then
				return
			end
		end
		
		for k,v in pairs(self.m_EndCbList) do
			if v then
				v()
			end
		end
		self.m_EndCbList = {}
	end
end

function CGuideCtrl.AddEndCallbackList(self, cb)
	table.insert(self.m_EndCbList, cb)
end

function CGuideCtrl.StartCheck(self)
	printc("开始引导检查")
	table.print(self.m_CheckTypes)
	if not self.m_Timer then
		self.m_Timer = Utils.AddTimer(callback(self, "Update"), 0, 0)
	end
end

function CGuideCtrl.AddGuideUI(self, sUIKey, oUI)
	if oUI then
		oUI.m_GuideKey = sUIKey
	end
	self.m_UIRefs[sUIKey] = weakref(oUI)
end

function CGuideCtrl.GetGuideUI(self, sUIKey)
	if not sUIKey then
		return
	end
	local oRef = self.m_UIRefs[sUIKey]
	if oRef then
		return getrefobj(oRef)
	end
end

function CGuideCtrl.DelGuideUI(self, sUIKey)
	if not sUIKey then
		return
	end
	self.m_UIRefs[sUIKey] = nil
end

function CGuideCtrl.LoginInit(self, list)
	-- self.m_Flags = {}
	for i, guideinfo in ipairs(list) do
		self.m_Flags[guideinfo.key] = true
	end
	self.m_IsInit = true
end

function CGuideCtrl.Continue(self)
	if self.m_UpdateInfo.guide_type and self.m_UpdateInfo.guide_key then
		printc("引导结束", self.m_UpdateInfo.guide_type, self.m_UpdateInfo.guide_key, self.m_UpdateInfo.cur_idx)
		g_UploadDataCtrl:SetDotByGuideType(self.m_UpdateInfo.guide_key, 1)
		local dGuideType = CGuideData[self.m_UpdateInfo.guide_type]
		-- self:CallGuideFunc(dGuideType.after_guide)
		local key = self.m_UpdateInfo.guide_key
		if self.m_UpdateInfo.complete_type == 0 then
			--没有协议，暂时屏蔽，以后要加
			--netteach.C2GSFinishGuidance(key)
			local list = {guide_links = {{linkid = self.m_UpdateInfo.guide_type, step = self.m_UpdateInfo.cur_idx, exdata = ""}}}
			local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
			netnewbieguide.C2GSUpdateNewbieGuideInfo(encode.mask, encode.guide_links, encode.exdata)

			for i = 1, self.m_UpdateInfo.cur_idx do
				local sKey = self.m_UpdateInfo.guide_type.."_"..i
				if not g_GuideHelpCtrl:CheckGuideActualLink(sKey) then
					table.insert(g_GuideHelpCtrl.m_GuideLinkActualList, {key = sKey})
				end
			end
			if Utils.GetActiveSceneName() ~= "editorTable" then
				g_GuideCtrl:LoginInit(g_GuideHelpCtrl.m_GuideLinkActualList)
			end
		end
		self.m_Flags[key] = true
		self.m_UpdateInfo.continue_condition = nil
		
		self:SetGuideKey(nil) --清空正在指引键

		local oView = CGuideView:GetView()
		if oView then
			oView:DelayClose()
		end
		local iMax = #CGuideData[self.m_UpdateInfo.guide_type].guide_list
		if self.m_UpdateInfo.cur_idx >= iMax then
			self:CallGuideFunc(dGuideType.after_guide)
			print("已完成引导"..self.m_UpdateInfo.guide_type)
			self.m_Flags[self.m_UpdateInfo.guide_type] = true
			--没有协议，暂时屏蔽，以后要加
			-- netteach.C2GSFinishGuidance(self.m_UpdateInfo.guide_type)
			local list = {guide_links = {{linkid = self.m_UpdateInfo.guide_type, step = iMax, exdata = ""}}}
			local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
			netnewbieguide.C2GSUpdateNewbieGuideInfo(encode.mask, encode.guide_links, encode.exdata)

			--任务间隔提示手指指引显示
			if table.index(CGuideData.TaskNotifyEvent, self.m_UpdateInfo.guide_type) then
				self.m_TaskNotifyExecute = true
			end

			for i = 1, iMax do
				local sKey = self.m_UpdateInfo.guide_type.."_"..i
				if not g_GuideHelpCtrl:CheckGuideActualLink(sKey) then
					table.insert(g_GuideHelpCtrl.m_GuideLinkActualList, {key = sKey})
				end
			end
			if Utils.GetActiveSceneName() ~= "editorTable" then
				g_GuideCtrl:LoginInit(g_GuideHelpCtrl.m_GuideLinkActualList)
			end

			self.m_UpdateInfo.guide_type = nil
			self.m_UpdateInfo.cur_idx = 1
			self.m_DelayTimer = nil

			g_GuideCtrl:OnTriggerAll()
			self:ExecuteEndCallback()
			self:OnEvent(define.Guide.Event.State)
		else
			self.m_UpdateInfo.cur_idx = self.m_UpdateInfo.cur_idx + 1
		end
	end
end

function CGuideCtrl.View2WorldPos(self, x, y)
	local oCam = g_CameraCtrl:GetUICamera()
	return oCam:ViewportToWorldPoint(Vector3.New(x, y, 0))
end

function CGuideCtrl.SetGuideKey(self, key)
	if self.m_UpdateInfo.after_process then
		self:CallGuideFunc(self.m_UpdateInfo.after_process.func_name, unpack(self.m_UpdateInfo.after_process.args))
		self.m_UpdateInfo.after_process = nil
	end
	self.m_UpdateInfo.guide_key = key
end

function CGuideCtrl.GetGuidePos(self, dGuideEffect)
	local vPos
	if dGuideEffect.fixed_pos then
		local v3= Vector3.New(dGuideEffect.fixed_pos.x+0.5,  dGuideEffect.fixed_pos.y+0.5, 0)
		vPos = g_CameraCtrl:GetUICamera():ViewportToWorldPoint(v3)
	elseif dGuideEffect.ui_key then
		local oUI = self:GetGuideUI(dGuideEffect.ui_key)
		vPos = oUI:GetPos()
		if dGuideEffect.near_pos then
			local v3= Vector3.New(dGuideEffect.near_pos.x+0.5,  dGuideEffect.near_pos.y+0.5, 0)
			vPos = g_CameraCtrl:GetUICamera():ViewportToWorldPoint(v3) + vPos
		end
	end
	return vPos
end

function CGuideCtrl.ProcessText(self, dGuideEffect)
	if not dGuideEffect.text_list then
		return
	end
	local function process(match)
		local s = string.gsub(match, "[<>]", "")
		if s == "name" then
			return g_AttrCtrl.name
		else
			return s
		end
	end
	for i, text in ipairs(dGuideEffect.text_list) do
		dGuideEffect.text_list[i] = string.gsub(text, "%b<>", process)
	end
end

function CGuideCtrl.IsNeedGuide(self, key)
	return self.m_Flags[key] == nil
end

function CGuideCtrl.ShowWrongTips(self)
	local list = {
		[[请道友按照新手指引操作]],
	}
	g_NotifyCtrl:FloatMsg(table.randomvalue(list))
end

function CGuideCtrl.CallGuideFunc(self, sFuncName, ...)
	if sFuncName then
		local f = CGuideData.FuncMap[sFuncName]
		if f then
			return f(...)
		end
	end
end

function CGuideCtrl.OnSwipe(self, vSwipePos)
	for key, func in pairs(self.m_SwipeCancel) do
		if func(vSwipePos) == true then
			self.m_SwipeCancel[key] = nil
		end
	end
end

function CGuideCtrl.StartGuide(self, dGuideInfo)
	if not table.index(self.m_NotCheckMainMenuGuideList, self.m_UpdateInfo.guide_type) then
		if not ( g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Active) and not g_MainMenuCtrl:IsAreaPlaying(define.MainMenu.AREA.Active) ) then
			if self.m_IsOpenTips then
				printc("define.MainMenu.AREA.Active")
			end
		end
		if not ( g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Function_1) and not g_MainMenuCtrl:IsAreaPlaying(define.MainMenu.AREA.Function_1) ) then
			if self.m_IsOpenTips then
				printc("define.MainMenu.AREA.Function_1 state moving", g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Function_1), " , ", not g_MainMenuCtrl:IsAreaPlaying(define.MainMenu.AREA.Function_1))
			end
		end
		if not ( g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Active) and not g_MainMenuCtrl:IsAreaPlaying(define.MainMenu.AREA.Active) )
		or not ( g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Function_1) and not g_MainMenuCtrl:IsAreaPlaying(define.MainMenu.AREA.Function_1) )
		or not ( g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Task) and not g_MainMenuCtrl:IsAreaPlaying(define.MainMenu.AREA.Task) ) then
			g_MainMenuCtrl:ShowMainFunctionArea()
			g_MainMenuCtrl:ShowAllArea()
			return
		end
	end
	if table.index(self.m_MainMenuRbBackList, self.m_UpdateInfo.guide_type) then
		if not ( g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Function_2) and not g_MainMenuCtrl:IsAreaPlaying(define.MainMenu.AREA.Function_2) ) then
			g_MainMenuCtrl:ShowMainFunctionAreaInverse()
			return
		end
	end

	--暂时屏蔽
	-- if not table.index(self.m_NotCheckWarGuideList, self.m_UpdateInfo.guide_type) then
	-- 	if g_WarCtrl:IsWar() then
	-- 		return
	-- 	end
	-- end

	if self.m_UpdateInfo.cur_idx == 1 then
		self:CallGuideFunc(CGuideData[self.m_UpdateInfo.guide_type].before_guide)
	end

	--必须存在的ui
	if dGuideInfo.necessary_ui_list then
		for i, key in ipairs(dGuideInfo.necessary_ui_list) do
			local oUI = self:GetGuideUI(key)
			--暂时屏蔽
			--or not oUI:GetActive(true)
			if Utils.IsNil(oUI) then 
				return
			else
				oUI:SetActive(true)
			end
		end
	end
	-- if g_OpenSysCtrl.m_IsSysOpenShowing or g_InteractionCtrl.IsShowing or g_MapCtrl.m_IsNpcCloseUp or g_MapCtrl:CheckIsInActivityMap() then
	-- 	return
	-- end
	local oView = CGuideView:GetView()
	if dGuideInfo.need_guide_view == false then
		if oView then
			CGuideView:CloseView()
		end
	else
		if oView then
			oView:StopDelayClose()
			oView:SetActive(true)
			oView:ResetView()
			--暂时屏蔽掉点击继续闪烁的文本
			-- oView.m_ContinueLabel:SetActive(dGuideInfo.click_continue)
		else
			CGuideView:ShowView()
			return
		end

	end
	if not table.index(self.m_NotCheckMainMenuGuideList, self.m_UpdateInfo.guide_type) then
		g_MainMenuCtrl:ShowMainFunctionArea()
		g_MainMenuCtrl:ShowAllArea()
	end
	if table.index(self.m_MainMenuRbBackList, self.m_UpdateInfo.guide_type) then
		g_MainMenuCtrl:ShowMainFunctionAreaInverse()
	end
	local oHero = g_MapCtrl:GetHero()
	if oHero and oHero.m_IsWalking then oHero:StopWalk() end
	g_MapCtrl:SetAutoPatrol(false, false)

	local oView = CGuideView:GetView()
	self:SetGuideKey(dGuideInfo.guide_key)
	g_UploadDataCtrl:SetDotByGuideType(dGuideInfo.guide_key, 0)
	-- g_ItemCtrl:SetUpgardePackConfigByGuideType(dGuideInfo.guide_key)
	printc("执行指引",dGuideInfo.guide_key, self.m_UpdateInfo.cur_idx)
	
	if dGuideInfo.before_process then
		self:CallGuideFunc(dGuideInfo.before_process.func_name, unpack(dGuideInfo.before_process.args))
	end
	self.m_UpdateInfo.after_process = dGuideInfo.after_process
	
	local dGuideType = CGuideData[self.m_UpdateInfo.guide_type]

	if self.m_UpdateInfo.cur_idx == 1 then
		-- self:CallGuideFunc(dGuideType.before_guide)

		--除去一些界面，关闭所有界面
		local viewList = {"CScoreShowView", "CNpcShowView", "CItemQuickUseView", "CGuideSelectView", "CGuideSelectSummonView", "CGuideView", "CNotifyView", "CMainMenuView", "CWarMainView", "CWarBg", "CWarBgSky",
		"CMapFadeView", "CGhostEyeView", "CWarFloatView", "CWarItemView", "CWarMagicView", "CWindowNetComfirmView", "CDancingActivityView", "CNpcCloseUpView", "CInteractionView", "CGuideNotifyView", "CMasterJudgeView",
		"CWindowComfirmView","CWindowJieBaiConfirmView"}
		if dGuideType.exceptview then
			for k,v in pairs(dGuideType.exceptview) do
				table.insert(viewList, v)
			end
		end
		g_ViewCtrl:CloseAll(viewList)

		C_api.UnityEditDialog.Hide()
	end

	if oView then
		oView.m_RightArrowSp:SetActive(false)
		oView.m_LeftArrowSp:SetActive(true)
		oView.m_RedNotifySp:SetActive(false)
	end	
	local oIsTexRihgt = false

	for i, dGuideEffect in ipairs(dGuideInfo.effect_list) do
		self:ProcessText(dGuideEffect)
		if dGuideEffect.effect_type == "func" then
			local func = CGuideCtrl[dGuideEffect.funcname]
			func(self)
		elseif dGuideEffect.effect_type == "click_ui" then
			
			-- if dGuideEffect.near_pos then
			-- 	local rootw, rooth = UITools.GetRootSize()
			-- 	local x = dGuideEffect.near_pos.x * rootw
			-- 	local y = dGuideEffect.near_pos.y * rooth					
			-- else
			-- 	oUI:AddEffect(dGuideEffect.ui_effect)
			-- end

			local oUI = self:GetGuideUI(dGuideEffect.ui_key)
			if not oUI.m_IsHasColliderResize then
				local oBoxCollider = oUI:GetComponent(classtype.BoxCollider)
				if oBoxCollider then
					oBoxCollider.enabled = true
					oBoxCollider.size = oBoxCollider.size * define.Guide.Args.BoxColliderArgs
				end
				oUI.m_IsHasColliderResize = true
			end
			if dGuideEffect.ui_effect then
				oUI:AddEffect(dGuideEffect.ui_effect, nil, (dGuideEffect.offset_pos and {Vector2.New(dGuideEffect.offset_pos.x, dGuideEffect.offset_pos.y)} or {nil})[1], dGuideEffect.offset_rotate or 0, true)
			end
			if oView then
				oView:ClickGuide(oUI)
			end
		elseif dGuideEffect.effect_type == "focus_ui" then
			local oUI = self:GetGuideUI(dGuideEffect.ui_key)
			if not oUI.m_IsHasColliderResize then
				local oBoxCollider = oUI:GetComponent(classtype.BoxCollider)
				if oBoxCollider then
					oBoxCollider.size = oBoxCollider.size * define.Guide.Args.BoxColliderArgs
				end
				oUI.m_IsHasColliderResize = true
			end
			local oUIRoot = UITools.GetUIRoot()
			local rootw, rooth = UITools.GetRootSize()
			local vLocalPos = oUIRoot.transform:InverseTransformPoint(oUI:GetCenterPos())
			local x = vLocalPos.x / rootw + 0.5
			local y = vLocalPos.y / rooth + 0.5
			if dGuideEffect.near_pos then
				x = x + dGuideEffect.near_pos.x
				y = y + dGuideEffect.near_pos.y
			end
			local w = dGuideEffect.w or (oUI:GetWidth()*0.5/rootw)
			local h = dGuideEffect.h or (oUI:GetHeight()*0.5/rooth)
			local isParticle = false
			if dGuideEffect.ui_effect == [[Finger]] then
				isParticle = true
			end
			if oView then
				oView:SetFocus(x, y, w, h, dGuideEffect.ui_effect, dGuideInfo.click_continue, isParticle, 
				(dGuideEffect.offset_pos and {Vector2.New(dGuideEffect.offset_pos.x, dGuideEffect.offset_pos.y)} or {nil})[1], dGuideEffect.offset_rotate or 0)
			end
		elseif dGuideEffect.effect_type == "focus_common" then
			if oView then
				oView:SetFocus(dGuideEffect.x, dGuideEffect.y, dGuideEffect.w, dGuideEffect.h, dGuideEffect.ui_effect, dGuideInfo.click_continue)
			end
		elseif dGuideEffect.effect_type == "focus_pos" then
			local vPos = self:CallGuideFunc(dGuideEffect.pos_func)
			local isParticle = false
			if dGuideEffect.ui_effect == [[Finger]] then
				isParticle = true
			end
			if oView then
				oView:SetFocus(vPos.x, vPos.y, dGuideEffect.pixel and dGuideEffect.pixel.x or 0, dGuideEffect.pixel and dGuideEffect.pixel.y or 0, 
				dGuideEffect.ui_effect, dGuideInfo.click_continue, isParticle, 
				(dGuideEffect.offset_pos and {Vector2.New(dGuideEffect.offset_pos.x, dGuideEffect.offset_pos.y)} or {nil})[1], dGuideEffect.offset_rotate or 0)
			end
		elseif dGuideEffect.effect_type == "dlg" then
			local vPos = self:GetGuidePos(dGuideEffect)
			if oView then
				oView:DlgGuide(dGuideEffect.text_list, dGuideEffect.play_tween, dGuideEffect.dlg_sprite, vPos, dGuideEffect.audio_list)
			end
		elseif dGuideEffect.effect_type == "texture" then
			local vPos = self:GetGuidePos(dGuideEffect)
			if oView then
				oView:TextureGuide(dGuideEffect.texture_name, dGuideEffect.play_tween, dGuideEffect.flip_y, vPos)
			end
		elseif dGuideEffect.effect_type == "open" then
			local oUI = self:GetGuideUI(dGuideEffect.ui_key)
			if not oUI.m_IsHasColliderResize then
				local oBoxCollider = oUI:GetComponent(classtype.BoxCollider)
				oBoxCollider.size = oBoxCollider.size * define.Guide.Args.BoxColliderArgs
				oUI.m_IsHasColliderResize = true
			end
			if oView then
				oView:OpenEffect(dGuideEffect.sprite_name, dGuideEffect.open_text, oUI)
			end
		elseif dGuideEffect.effect_type == "notify_ui" then
			local oUI = self:GetGuideUI(dGuideEffect.ui_key)
			if not oUI.m_IsHasColliderResize then
				local oBoxCollider = oUI:GetComponent(classtype.BoxCollider)
				oBoxCollider.size = oBoxCollider.size * define.Guide.Args.BoxColliderArgs
				oUI.m_IsHasColliderResize = true
			end
			oUI:DelEffect(dGuideEffect.ui_effect)
			oUI:AddEffect(dGuideEffect.ui_effect)
			if oView then
				oView:NotifyGuide()
			end
		elseif dGuideEffect.effect_type == "notify_effect_ui" then
			local oUI = self:GetGuideUI(dGuideEffect.ui_key)
			if not oUI.m_IsHasColliderResize then
				local oBoxCollider = oUI:GetComponent(classtype.BoxCollider)
				oBoxCollider.size = oBoxCollider.size * define.Guide.Args.BoxColliderArgs
				oUI.m_IsHasColliderResize = true
			end
			oUI:DelEffect(dGuideEffect.notify_ui_effect)
			oUI:AddEffect(dGuideEffect.notify_ui_effect, dGuideEffect.offset_pos)
			if oView then
				oView:NotifyGuide()
			end
		elseif dGuideEffect.effect_type == "circlebefore_click_ui" then
			local oUI = self:GetGuideUI(dGuideEffect.ui_key)
			if not oUI.m_IsHasColliderResize then
				local oBoxCollider = oUI:GetComponent(classtype.BoxCollider)
				oBoxCollider.size = oBoxCollider.size * define.Guide.Args.BoxColliderArgs
				oUI.m_IsHasColliderResize = true
			end
			local function finish()					
				oUI:AddEffect(dGuideEffect.ui_effect, nil, (dGuideEffect.offset_pos and {Vector2.New(dGuideEffect.offset_pos.x, dGuideEffect.offset_pos.y)} or {nil})[1], dGuideEffect.offset_rotate or 0)
				if oView then
					oView:ClickGuide(oUI)
				end
			end
			local oUIPos = oUI:GetPos()
			local oScreenPos = g_NotifyCtrl:GetScreenPos(oUIPos)
			local oWorldPos = g_NotifyCtrl:GetWorldPos(Vector3.New(oScreenPos.x+(dGuideEffect.target_offset_pos and dGuideEffect.target_offset_pos.x or 0)
			, oScreenPos.y+(dGuideEffect.target_offset_pos and dGuideEffect.target_offset_pos.y or 0), oScreenPos.z))
			if oView then
				oView:CircleBeforeClickGuide(finish, oWorldPos)
			end
		elseif dGuideEffect.effect_type == "arrowright" then
			if oView then
				oView.m_RightArrowSp:SetActive(true)
				oView.m_LeftArrowSp:SetActive(false)
				oView:SetTextureRight(dGuideEffect.offsetx, dGuideEffect.offsety)
				oIsTexRihgt = true
			end
		elseif dGuideEffect.effect_type == "red_ui" then
			local oUI = self:GetGuideUI(dGuideEffect.ui_key)
			if oView then					
				oView.m_RedNotifySp:SetPos(oUI:GetPos())
				oView.m_RedNotifySp:SetSize(oUI:GetWidth()+20, oUI:GetHeight()+20)
				oView.m_RedNotifySp:SetActive(true)
			end
		end
	end
	if oView then
		if not oIsTexRihgt then
			oView:SetTextureLeft()
		end
	end
	if dGuideInfo.continue_condition then
		self.m_UpdateInfo.continue_condition = dGuideInfo.continue_condition
	else
		if oView then
			oView.m_ClickContinue = dGuideInfo.click_continue
		end
	end

	if dGuideInfo.pass then --只要执行到了这个指引，就不再执行
		self:Continue()
	end
end

function CGuideCtrl.SelectItemList(self, floatitemlist)
	self.m_FloatItemList = floatitemlist
end

return CGuideCtrl
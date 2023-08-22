local COpenSysCtrl = class("COpenSysCtrl", CCtrlBase)

function COpenSysCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_CheckSys = {}
	self.m_CheckSysHashData = {}
	self.m_ShowSys = {}
	self.m_ShowSysHashData = {}
	self.m_ShowingSys = {}
	self.m_HasShowSys = {}

	self.m_LoginShowSys = {}

	self.m_HasServerNotifyData = false

	self.m_ShowingBox = nil
	self.m_ShowingData = nil
	self.m_IsSysOpenShowing = false
	self.m_SysOpenShowEndCbList = {}
	self.m_SysSended = {}

	self.m_SysOpenHasShowList = {}
	self.m_SysOpenHasShowHashData = {}

	--如果是true的话代表这个系统开启
	self.m_SysTagList = {}

	self.m_SysOpenList = {}
end

function COpenSysCtrl.ClearAll(self)
	self.m_SysOpenInit = false
	self:CancelShow()
	if self.m_ShowTimer then
		Utils.DelTimer(self.m_ShowTimer)
		self.m_ShowTimer = nil
	end
	self.m_CheckSys = {}
	self.m_CheckSysHashData = {}
	self.m_ShowSys = {}
	self.m_ShowSysHashData = {}
	self.m_ShowingSys = {}
	self.m_HasShowSys = {}
	self.m_LoginShowSys = {}
	self.m_ShowingData = nil
	self.m_IsSysOpenShowing = false
	self.m_SysOpenShowEndCbList = {}
	self.m_SysSended = {}

	self.m_SysOpenHasShowList = {}
	self.m_SysOpenHasShowHashData = {}
end

--获取系统开放的状态，true是系统开放，false是系统关闭,第一个参数是open配置表里面的系统id，第二个参数是是否开启飘字，可不填
--登录时的ui显示和隐藏，有可能需要监听一下GS2CLoginUnlockedTags协议
function COpenSysCtrl.GetOpenSysState(self, iSysKey, bFloatMsg)
	if iSysKey == "" then
		return true
	end
	
	-- 发行要求的对特殊服务器进行判断开关（充值、首充）
	local specitySta = g_LoginPhoneCtrl:IsShenhePack()
	if specitySta then
		local list = {"SHOP", "FIRST_PAY", "GIFT_DAY", "GIFT_GOLDCOIN", "GIFT_GRADE"}
		if table.index(list, iSysKey) then
			return true
		end
	end

	local openInfo = DataTools.GetViewOpenData(iSysKey)
	if not openInfo then
	   printc("open表未添加该系统！")
	   return false
    end
	-- printerror("=== COpenSysCtrl.GetOpenSysState ===", iSysKey)
	-- table.print(openInfo, "Info")
	if openInfo then
		if openInfo.open_sys == 0 then
			if bFloatMsg then
				g_NotifyCtrl:FloatMsg(openInfo.name .. "系统暂时关闭,敬请期待")
			end
			return false
		else
			if self.m_SysOpenList[iSysKey] then
				return true
			else
				if bFloatMsg then
					self:FloatTipUnOpenMsg(iSysKey)
				end
				return false
			end
		end
	else
		return true
	end
end

function COpenSysCtrl.FloatTipUnOpenMsg(self, iSysKey)
	local openInfo = DataTools.GetViewOpenData(iSysKey)
	local tipMsg = "系统尚未开放哦"
	if openInfo then
		local oName = string.gsub(openInfo.name, "系统", "")
		if openInfo.task_lock ~= 0 then
			tipMsg = oName.."系统尚未开放哦"
		else
			if g_AttrCtrl.grade < openInfo.p_level then
				tipMsg = string.gsub(data.textdata.TEXT[3006].content, "#name", oName)
				tipMsg = string.gsub(tipMsg, "#grade", openInfo.p_level)
			else
				tipMsg = openInfo.name .. "系统暂时关闭,敬请期待"
			end
		end
	end
	g_NotifyCtrl:FloatMsg(tipMsg)
end

--现在系统开放检查，先检查 open配置表open_sys字段，然后检查 task_lock，如果在self.m_SysTagList检查有值
--代表强行开放即跳过检查等级到那个条件， 最后检查 等级(有可能会被跳过)

-------------------以下是协议返回----------------------

--记录是否进行过系统开放表现的协议返回
function COpenSysCtrl.GS2CSysOpenNotified(self, pbdata)
	self:ClearAll()
	
	local sys_ids = pbdata.sys_ids
	self.m_SysOpenHasShowList = {}
	table.copy(sys_ids, self.m_SysOpenHasShowList)
	self:CheckSysOpenHasShowHashData()

	self.m_HasServerNotifyData = true
	g_OpenSysCtrl:SendLoginEvent()
end

function COpenSysCtrl.CheckSysOpenHasShowHashData(self)
	self.m_SysOpenHasShowHashData = {}
	for k,v in pairs(self.m_SysOpenHasShowList) do
		self.m_SysOpenHasShowHashData[v] = true
	end
end

function COpenSysCtrl.GS2CLoginOpenSys(self, pbdata)
	local open_sys = pbdata.open_sys

	self.m_SysOpenList = {}
	for k,v in pairs(open_sys) do
		self.m_SysOpenList[v] = true
	end
	g_OpenSysCtrl:SendLoginEvent()
	self.m_SysOpenInit = true

	--请求帮派数量
	if self.m_SysOpenList[define.System.Org] then
		netnewbieguide.C2GSGetNewbieGuildInfo()
	end
	self:CheckPromoteData()

	g_TaskCtrl:AddAceData(1)
	g_ItemCtrl:SetUpgradsPackConfigByGrade()
	g_GuideCtrl:OnTriggerAll()
	g_GuideHelpCtrl:CheckAllNotifyGuide()
end

function COpenSysCtrl.GS2COpenSysChange(self, pbdata)
	local changes = pbdata.changes
	self.m_SysNewList = {}
	for k,v in pairs(changes) do
		if v.open == 1 then
			if not self.m_SysOpenList[v.sys] then
				table.insert(self.m_SysNewList, v.sys)
			end
			self.m_SysOpenList[v.sys] = true

			g_OpenSysCtrl:CheckIsShowOpenEffect()
		else
			table.insert(self.m_SysNewList, v.sys)
			self.m_SysOpenList[v.sys] = nil
		end
	end
	g_OpenSysCtrl:SendLoginEvent()
	self:OnEvent(define.SysOpen.Event.Change)

	--请求帮派数量
	if self.m_SysOpenList[define.System.Org] then
		netnewbieguide.C2GSGetNewbieGuildInfo()
	end
	self:CheckPromoteData(self.m_SysNewList)

	g_ItemCtrl:SetUpgradsPackConfigByGrade()
	g_GuideCtrl:OnTriggerAll()
	g_GuideHelpCtrl:CheckAllNotifyGuide()
	--g_WelfareCtrl:FirstOpenYouKaLogin(changes)
	g_SysUIEffCtrl:OpenSystems(self.m_SysNewList)
end

function COpenSysCtrl.CheckPromoteData(self, changeData)
	--提升相关
	if changeData then
		local list = changeData

		if table.index(list, define.System.SkillZD) then
			g_PromoteCtrl:UpdatePromoteData(1)
		end
		if table.index(list, define.System.SkillBD) then
			g_PromoteCtrl:UpdatePromoteData(2)
		end
		if table.index(list, define.System.RoleAddPoint) then
			g_PromoteCtrl:UpdatePromoteData(3)
		end
		if table.index(list, define.System.Summon) then
			g_PromoteCtrl:UpdatePromoteData(4)
		end
		if table.index(list, define.System.Formation) then
			g_PromoteCtrl:UpdatePromoteData(5)
			g_PromoteCtrl:UpdatePromoteData(13)
		end
		if table.index(list, define.System.EquipStrengthen) then
			g_PromoteCtrl:UpdatePromoteData(7)
		end
		if table.index(list, define.System.Partner) then
			g_PromoteCtrl:UpdatePromoteData(8)
		end
		if table.index(list, define.System.Partner) then
			g_PromoteCtrl:UpdatePromoteData(9)
		end
		if table.index(list, define.System.Summon) then
			g_PromoteCtrl:UpdatePromoteData(10)
		end
		if table.index(list, define.System.Cultivation) then
			g_PromoteCtrl:UpdatePromoteData(11)
		end
	else
		g_PromoteCtrl:UpdatePromoteData(1)
		g_PromoteCtrl:UpdatePromoteData(2)
		g_PromoteCtrl:UpdatePromoteData(3)
		g_PromoteCtrl:UpdatePromoteData(4)
		g_PromoteCtrl:UpdatePromoteData(5)
		g_PromoteCtrl:UpdatePromoteData(7)
		g_PromoteCtrl:UpdatePromoteData(8)
		g_PromoteCtrl:UpdatePromoteData(9)
		g_PromoteCtrl:UpdatePromoteData(10)
		g_PromoteCtrl:UpdatePromoteData(11)
		g_PromoteCtrl:UpdatePromoteData(13)
	end
end

function COpenSysCtrl.CheckSysHasShow(self, iSysId)
	return self.m_SysOpenHasShowHashData[tostring(iSysId)]
end

function COpenSysCtrl.GetIsNeedLoginShow(self, iSysId)
	--检查必要条件
	if not self.m_HasServerNotifyData or g_AttrCtrl.pid == 0 then
		return
	end
	if self:CheckSysHasShow(iSysId) then
		return
	end
	local openInfo = DataTools.GetViewOpenData(iSysId)
	if not openInfo or openInfo.open_sys == 0 or openInfo.new_guide == 0 then
		return
	end
	--没有showeffect过，并且满足条件
	if not self:CheckSysHasShow(iSysId) then
		if self.m_SysOpenList[iSysId] then
			return true
		end
	end
end

function COpenSysCtrl.GetIsNeedLoginOpen(self)
	for k,v in pairs(data.opendata.OPEN) do
		if self:GetIsNeedLoginShow(v.stype) then
			printc("GetIsNeedLoginShow sysid ", v.stype)
			return true
		end
	end
end

------------------以下是开启表现----------------

function COpenSysCtrl.GetUIFuncBySysId(self, iSysId)
	local uiClone
	local uiRepositionFunc
	if iSysId == define.System.Skill then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_RB.m_SkillBtn
		end
		uiRepositionFunc = function ()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_RB.m_SkillBtn:SetActive(true)
				oView.m_RB.m_HBtnFirstGrid:Reposition()
			end
			-- self:OnEvent(define.SysOpen.Event.Reposition)
		end
	elseif iSysId == define.System.Forge then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_RB.m_ForgeBtn
		end
		uiRepositionFunc = function ()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_RB.m_ForgeBtn:SetActive(true)
				oView.m_RB.m_HBtnFirstGrid:Reposition()
			end
		end
	elseif iSysId == define.System.Org then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_RB.m_OrgBtn
		end
		uiRepositionFunc = function ()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_RB.m_OrgBtn:SetActive(true)
				oView.m_RB.m_HBtnFirstGrid:Reposition()
			end
		end
	elseif iSysId == define.System.Partner then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_RB.m_PartnerBtn
		end
		uiRepositionFunc = function ()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_RB.m_PartnerBtn:SetActive(true)
				oView.m_RB.m_HBtnFirstGrid:Reposition()
			end
		end
	elseif iSysId == define.System.Horse then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_RB.m_HorseBtn
		end
		uiRepositionFunc = function ()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_RB.m_HorseBtn:SetActive(true)
				oView.m_RB.m_TempGrid:Reposition()
			end
		end
	elseif iSysId == define.System.Rank then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_LT.m_RankBtn
		end
		uiRepositionFunc = function ()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_LT.m_RankBtn:SetActive(true)
				oView.m_LT.m_TopGrid:Reposition()
			end
		end
	elseif iSysId == define.System.Schedule then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_LT.m_ScheduleBtn
		end
		uiRepositionFunc = function ()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_LT.m_ScheduleBtn:SetActive(true)
				oView.m_LT.m_TopGrid:Reposition()
			end
		end
	elseif iSysId == define.System.Shop then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_LT.m_ShopBtn
		end
		uiRepositionFunc = function ()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_LT.m_ShopBtn:SetActive(true)
				oView.m_LT.m_GuideGrid:Reposition()
			end
		end
	elseif iSysId == define.System.Stall then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_LT.m_EcononmyBtn
		end
		uiRepositionFunc = function ()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_LT.m_EcononmyBtn:SetActive(true)
				oView.m_LT.m_LeftGrid:Reposition()
			end
		end
	elseif iSysId == define.System.Badge then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_RB.m_BadgeBtn
		end
		uiRepositionFunc = function()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_RB.m_BadgeBtn:SetActive(true)
				oView.m_RB.m_HBtnSecondGrid:Reposition()
			end
		end
	elseif iSysId == define.System.Artifact then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_RB.m_ArtifactBtn
		end
		uiRepositionFunc = function()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_RB.m_ArtifactBtn:SetActive(true)
				oView.m_RB.m_TempGrid:Reposition()
			end
		end
	elseif iSysId == define.System.Wing then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_RB.m_WingBtn
		end
		uiRepositionFunc = function()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_RB.m_WingBtn:SetActive(true)
				oView.m_RB.m_TempGrid:Reposition()
			end
		end
	elseif iSysId == define.System.FaBao then
		local oView = CMainMenuView:GetView()
		if oView then
			uiClone = oView.m_RB.m_FabaoBtn
		end
		uiRepositionFunc = function()
			local oView = CMainMenuView:GetView()
			if oView then
				oView.m_RB.m_FabaoBtn:SetActive(true)
				oView.m_RB.m_TempGrid:Reposition()
			end
		end
	end
	return uiClone, uiRepositionFunc
end

function COpenSysCtrl.AddUIInfo(self, iSysId, oUI, cb)
	--检查必要条件
	if not self.m_HasServerNotifyData or g_AttrCtrl.pid == 0 then --Utils.IsNil(oUI)
		return
	end
	if self:CheckSysHasShow(iSysId) then
		return
	end
	local openInfo = DataTools.GetViewOpenData(iSysId)
	if not openInfo or openInfo.open_sys == 0 or openInfo.new_guide == 0 then
		return
	end

	-- local ui = oUI:Clone()
	--没有showeffect过，并且满足条件
	if not self:CheckSysHasShow(iSysId) then
		if self.m_SysOpenList[iSysId] then
			table.insert(self.m_LoginShowSys, {sysid = iSysId, ui = oUI, cb = cb})
			self:CheckIsHasLoginShowOpenEffect()
			return
		end
	end

	if not self:CheckSysHasShow(iSysId) and not self:IsCheckSysExist(iSysId) then --not oUI:GetActive() and 
		table.insert(self.m_CheckSys, {sysid = iSysId, ui = oUI, cb = cb})
		self.m_CheckSysHashData[iSysId] = true
	end
end

function COpenSysCtrl.IsCheckSysExist(self, iSysId)
	return self.m_CheckSysHashData[iSysId]
end

function COpenSysCtrl.IsShowSysExist(self, iSysId)
	return self.m_ShowSysHashData[iSysId]
end

function COpenSysCtrl.CheckIsHasLoginShowOpenEffect(self)
	for k,v in pairs(self.m_LoginShowSys) do
		if not self.m_HasShowSys[v.sysid] and not self:IsShowSysExist(v.sysid) and not self:CheckSysHasShow(v.sysid) then
			table.insert(self.m_ShowSys, v)
			self.m_ShowSysHashData[v.sysid] = true
		end
		-- table.remove(self.m_LoginShowSys, k)
	end
	self.m_LoginShowSys = {}
	table.sort(self.m_ShowSys, function(a, b)
		local openInfoA = DataTools.GetViewOpenData(a.sysid)
		local openInfoB = DataTools.GetViewOpenData(b.sysid)
		return openInfoA.p_level < openInfoB.p_level
	end)

	self:StartShow()
end

function COpenSysCtrl.CheckIsShowOpenEffect(self)
	for k,v in pairs(self.m_CheckSys) do
		if self.m_SysOpenList[v.sysid] then
			if not self.m_HasShowSys[v.sysid] and not self:IsShowSysExist(v.sysid) and not self:CheckSysHasShow(v.sysid) then
				table.insert(self.m_ShowSys, v)
				self.m_ShowSysHashData[v.sysid] = true
			end
		end
	end
	table.sort(self.m_ShowSys, function(a, b)
		local openInfoA = DataTools.GetViewOpenData(a.sysid)
		local openInfoB = DataTools.GetViewOpenData(b.sysid)
		return openInfoA.p_level < openInfoB.p_level
	end)

	self:StartShow()
end

function COpenSysCtrl.StartShow(self)
	if g_InteractionCtrl.IsShowing and next(self.m_ShowSys) and not self.m_IsSysOpenShowing then
		if self.m_ShowTimer then
			Utils.DelTimer(self.m_ShowTimer)
			self.m_ShowTimer = nil
		end
		g_InteractionCtrl:AddInteractionCbList(function ()
			g_OpenSysCtrl:StartShow()
		end)
		return
	end
	if g_MarryPlotCtrl:IsPlayingWeddingPlot() then
		if self.m_ShowTimer then
			Utils.DelTimer(self.m_ShowTimer)
			self.m_ShowTimer = nil
		end
		return
	end
	if not self.m_ShowTimer then
		local function progress()
			if g_AttrCtrl.pid == 0 then
				return false
			end
			if not next(self.m_ShowSys) then
				self.m_ShowTimer = nil
				-- self.m_ShowingData = nil
				-- g_NetCtrl:SetCacheProto("sysnotify", false)
				-- g_NetCtrl:ClearCacheProto("sysnotify", true)
				-- g_GuideCtrl:OnTriggerAll()
				return false
			end			
			self.m_HasShowSys[self.m_ShowSys[1].sysid] = true
			self.m_ShowingSys[self.m_ShowSys[1].sysid] = true
			self.m_ShowSysHashData[self.m_ShowSys[1].sysid] = nil
			self:SetOpenEffect(self.m_ShowSys[1])
			table.remove(self.m_ShowSys, 1)
			return true
		end
		self.m_ShowTimer = Utils.AddTimer(progress, 3.5, 0)	
	end
end

function COpenSysCtrl.SetOpenEffect(self, oData)
	if g_AttrCtrl.pid == 0 then
		return
	end
	if not self.m_SysSended[oData.sysid] then
		netnewbieguide.C2GSNewSysOpenNotified({oData.sysid})
		self.m_SysSended[oData.sysid] = true
		if not self.m_SysOpenHasShowHashData[oData.sysid] then
			table.insert(self.m_SysOpenHasShowList, oData.sysid)
			self.m_SysOpenHasShowHashData[oData.sysid] = true
		end
	end
	self.m_ShowingData = oData
	self.m_IsSysOpenShowing = true
	g_NetCtrl:SetCacheProto("sysnotify", true)

	local oView = CNotifyView:GetView()
	local function delay()
		-- if not oData or not oData.ui or not oData.ui.m_GameObject then
		-- 	printerror("### 没有找到功能开启的UI GameObject ###")
		-- end
		local uiClone, uiRepositionFunc = self:GetUIFuncBySysId(oData.sysid)
		oData.ui = uiClone
		local oBox = oData.ui:Clone()
		
		local btn1 = oBox:GetComponent(classtype.UIButtonScale)
		if btn1 then
			btn1.enabled = false
		end
		local btn2 = oBox:GetComponent(classtype.UIButtonColor)
		if btn2 then
			btn2.disabledColor = Color.New(1, 1, 1, 1)
		end
		local collider = oBox:GetComponent(classtype.BoxCollider)
		if collider then
			collider.enabled = false
		end	
		
		oBox:SetPivot(enum.UIWidget.Pivot.Center)
		--暂时屏蔽
		-- oBox:AddEffect("Rect")
		oBox:SetActive(true)	
		oBox:SetParent(oView.m_SysOpenBox.m_Transform)
		self.m_ShowingBox = oBox
		local screenWidth = UnityEngine.Screen.width
		local screenHeight = UnityEngine.Screen.height

		-- oData.ui:SetActive(true)
		-- if oData.cb then
		-- 	oData.cb()
		-- end
		uiRepositionFunc()
		oData.ui:SetActive(false)
		local recordUIPivot = oData.ui:GetPivot()
		oData.ui:SetPivot(enum.UIWidget.Pivot.Center)
		oBox:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.5, screenHeight*0.6)))

		local function onEnd()
			self.m_ShowingSys[oData.sysid] = nil

			if not Utils.IsNil(oBox) then
				oBox:Destroy()
			end
			local uiClone, uiRepositionFunc = self:GetUIFuncBySysId(oData.sysid)
			uiRepositionFunc()
			g_AudioCtrl:PlaySound(define.Audio.SoundPath.Unlock)

			if not next(self.m_ShowSys) then
				if self.m_ShowTimer then
					Utils.DelTimer(self.m_ShowTimer)
					self.m_ShowTimer = nil
				end
			end
			if not next(self.m_ShowingSys) and not next(self.m_ShowSys) then
				oView:SetSysOpenBoxActive(false)
				self.m_ShowingData = nil
				self.m_IsSysOpenShowing = false
				for k,v in pairs(self.m_SysOpenShowEndCbList) do
					if v then v() end
				end
				self.m_SysOpenShowEndCbList = {}
				g_NetCtrl:SetCacheProto("sysnotify", false)
				g_NetCtrl:ClearCacheProto("sysnotify", true)
				g_GuideCtrl:OnTriggerAll()
			end
		end
		
		oData.ui:SetPivot(recordUIPivot)
		-- 等菜单tween播完再获取路径，不然recordPos可能是旧的
		local function delayTween()
			local recordPos = oData.ui:GetPos()
			local vet = {self:GetWorldPos(Vector2.New(screenWidth*0.5, screenHeight*0.6)), recordPos}
			oData.ui:SetPivot(recordUIPivot)
			local tweenPath = DOTween.DOPath(oBox.m_Transform, vet, 1, 0, 0, 10, nil)
			DOTween.SetDelay(tweenPath, 1.4)
			DOTween.OnComplete(tweenPath, onEnd)
			local function onStart()
				oView.m_SysTotalBg:SetActive(false)
			end
			DOTween.OnPlay(tweenPath, onStart)
			return false
		end
		Utils.AddTimer(delayTween, 1, 0.6)
	end
	-- if oData.sysid == define.System.Badge then
	-- 	g_MainMenuCtrl:ShowMainFunctionAreaInverse()
	-- else
	g_MainMenuCtrl:ShowMainFunctionArea()
	-- end
	g_MainMenuCtrl:ShowAllArea()

	-- oView.m_FloatTable:Clear()
	oView:ClearFloatMsg()
	oView:SetSysOpenBoxActive(true)
	delay()
end

function COpenSysCtrl.GetWorldPos(self, screenPos)
	local oUICamera = g_CameraCtrl:GetUICamera()
	local WorldPos = oUICamera:ScreenToWorldPoint(screenPos)
	return WorldPos
end

function COpenSysCtrl.CancelShow(self)
	if self.m_ShowingData and not self.m_SysSended[self.m_ShowingData.sysid] then
		netnewbieguide.C2GSNewSysOpenNotified({self.m_ShowingData.sysid})
		self.m_SysSended[self.m_ShowingData.sysid] = true
		if not self.m_SysOpenHasShowHashData[self.m_ShowingData.sysid] then
			table.insert(self.m_SysOpenHasShowList, self.m_ShowingData.sysid)
			self.m_SysOpenHasShowHashData[self.m_ShowingData.sysid] = true
		end
	end

	if self.m_ShowingData then
		self.m_ShowingSys[self.m_ShowingData.sysid] = nil
	end
	local oView = CNotifyView:GetView()
	if oView then
		oView.m_SysTotalBg:SetActive(false)
	end
	
	if not Utils.IsNil(self.m_ShowingBox) then
		self.m_ShowingBox:SetActive(false)
	end
	if self.m_ShowingData then
		local uiClone, uiRepositionFunc = self:GetUIFuncBySysId(self.m_ShowingData.sysid)
		uiRepositionFunc()

		if not next(self.m_ShowSys) then
			if self.m_ShowTimer then
				Utils.DelTimer(self.m_ShowTimer)
				self.m_ShowTimer = nil
			end
		end
		if not next(self.m_ShowingSys) and not next(self.m_ShowSys) then
			if oView then
				oView:SetSysOpenBoxActive(false)
			end
			self.m_ShowingData = nil
			self.m_IsSysOpenShowing = false
			for k,v in pairs(self.m_SysOpenShowEndCbList) do
				if v then v() end
			end
			self.m_SysOpenShowEndCbList = {}
			g_NetCtrl:SetCacheProto("sysnotify", false)
			g_NetCtrl:ClearCacheProto("sysnotify", true)
			g_GuideCtrl:OnTriggerAll()
		end
	end
end

function COpenSysCtrl.SendLoginEvent(self)
	self:OnEvent(define.SysOpen.Event.Login)
end

function COpenSysCtrl.AddSysOpenShowCbList(self, cb)
	table.insert(self.m_SysOpenShowEndCbList, cb)
end

function COpenSysCtrl.PauseShowSysOpen(self)
	if self.m_ShowTimer then
		Utils.DelTimer(self.m_ShowTimer)
		self.m_ShowTimer = nil
	end
	-- Todo hide showing
end

return COpenSysCtrl
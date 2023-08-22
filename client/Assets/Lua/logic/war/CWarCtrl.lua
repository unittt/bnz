local CWarCtrl = class("CWarCtrl", CCtrlBase)

define.War = {
	Event = {
		AutoWar = 1,
		AutoMagic = 2,
		HeroState = 3,
		SummonState = 4,
		HeroBuff = 5,
		SummonBuff = 6,
		CommandDone = 7,
		RefreshQuickHero = 8,
		RefreshQuickSummon = 9,
		RefreshSpecialSkill = 10,
		BoutStart = 11,
		Formation = 12,
        WarStart = 13,
        WarEnd = 14,
        MatchCount = 15,
        UpdateZhenQi = 16,
	},
	Atk_Distance = 1.5,

	Status = {
		Alive = 1,
		Died = 2,
	},

	War_Type = {
		PVE_TYPE = 1,
		PVP_TYPE = 2,
	},

	Buff_Sub = {
		BoutEnd = 1,
		Attack = 2,
	},

	WeatherPath = {
		{
			-- 晴天
			"Effect/Scene/scene_eff_0014/Prefabs/scene_eff_0014.prefab",
			"Effect/Scene/scene_eff_0014/Prefabs/scene_eff_0014.prefab",
		},
		{
			-- 雷雨
			"Effect/Scene/scene_eff_0015/Prefabs/scene_eff_0015.prefab",
			"Effect/Scene/scene_eff_0016/Prefabs/scene_eff_0016.prefab",
		},
		{
			-- 下雪
			"Effect/Scene/scene_eff_0018/Prefabs/scene_eff_0018.prefab",
			"Effect/Scene/scene_eff_0019/Prefabs/scene_eff_0019.prefab",
		},
	},
	WeatherWetPath = {
		-- 阳光（没有）
		"",
		-- 雨淋湿
		"Effect/Scene/scene_eff_0017/Prefabs/scene_eff_0017.prefab",
		-- 雪淋湿
		"Effect/Scene/scene_eff_0020/Prefabs/scene_eff_0020.prefab",
	}
}

CWarCtrl.g_Print = false

function CWarCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_Root = nil
	self.m_ViewSide = nil --以哪一边的视角观看战斗
	self.m_IsPlayRecord = false -- 是否是录像
	self.m_IsClientRecord = false -- 是否是客户端录像

	-- 玩家快捷技能
	self.m_QuickMagicIDHero = nil
	-- 宠物快捷技能
	self.m_QuickMagicIDSummon = {}

	-- 首任务引导
	self.m_IsFirstSpecityWar = false
	self.m_FirstSpecityWarStep = 0
	self.m_WarSessionidx = nil
	self.m_WarPid = nil

	 -- 是否gc过
	self.m_GCed = false

	self:InitValue()
end

function CWarCtrl.ClearData(self)
	self:End()

	self.m_QuickMagicIDHero = nil
	self.m_QuickMagicIDSummon = {}

	-- 玩家快捷技能
	self.m_QuickMagicIDHero = nil
	-- 宠物快捷技能
	self.m_QuickMagicIDSummon = {}

	-- 首任务引导
	self.m_IsFirstSpecityWar = false
	self.m_FirstSpecityWarStep = 0
	self.m_WarSessionidx = nil
	-- self.m_WarPid = nil
end

function CWarCtrl.InitValue(self)
	self.m_WarID = nil
	self.m_WarType = nil
	self.m_WarSysType = nil
	self.m_IsInResult = false --是否在战斗结算界面

	self.m_WarBg = nil
	self.m_WarBgSky = nil
	
	self.m_WarSky = nil
	self.m_WarWeather = nil
	self.m_WarWeatherWetTimer = nil
	self.m_WarBossWar = nil
	self.m_ChatMsgCnt = 0
	self.m_AutoMagic = {}
	self.m_Warriors = {} --所有战士
	self.m_InstanceID2Warrior = {}
	self.m_CmdList = {}
	self.m_MainActionList = {} --存入单个action
	self.m_SubActionsDict = {} --存入actionlist，多个战士同时执行动作时使用
	self.m_SubActionListIdx = 0
	self.m_CmdIdx = 0 --递增计数器
	self.m_ActionFlag = 0 --执行Action标记
	self.m_Bout = 1 -- 回合数
	self.m_IsWarStart = true --是否刚刚开始战斗
	self.m_VaryCmd = nil
	self.m_IsAutoWar = 0 --是否自动战斗
	self.m_WaitTime = false

	self.m_AllyCmap = nil
	self.m_HeroPid = nil
	self.m_HeroWid = nil
	self.m_HeroState = nil
	self.m_SummonWid = nil
	self.m_SummonState = nil

	--站位
	self.m_AllyPlayerCnt = 0
	self.m_EnemyPlayerCnt = 0

	--当前协议属于哪一Bout(回合)
	self.m_ProtoBout = 0
	--当前协议属于哪一Wave(波数)
	self.m_ProtoWave = 0
	self.m_SumWave = 0
	self.m_CurWave = 0

	self.m_ReciveResultProto = nil
	self.m_BoutMagicInfo = {}
	self.m_BoutFloatInfo = {}
	self.m_BoutEnd = {}
	self.m_ResultInfo = {wid=nil, exp_list={}, item_list={},desc="", resultspr=nil}
	self.m_ShowSceneEndWar = false
	self.m_FightSummonIDList = {}
	self.m_BoutMagicInfo = {info_list= {}}
	self.m_WarBoutTips = false
	self.m_CurActionWid = nil

	-- 阵法
	self.m_Fmt_id1 = nil
	self.m_Fmt_id2 = nil
	self.m_Fmt_grade1 = nil
	self.m_Fmt_grade2 = nil

	--战斗指挥相关
	self.m_MaskTeamCmd = false
	self.m_ClearTeamCmd = false
	self.m_AppointId = nil

	-- 观战人数
	self.m_WarObCount = 0
end

function CWarCtrl.SetBoutFloatInfo(self, dFloatInfo)
	table.safeset(self.m_BoutFloatInfo, dFloatInfo, self.m_ProtoWave, self.m_ProtoBout)
end

function CWarCtrl.IsGuideWar(self)
	if self.m_WarType then
		return self.m_WarType > 10000
	else
		return false
	end
end

function CWarCtrl.SetResultValue(self, k, v)
	self.m_ResultInfo[k] = v
end

function CWarCtrl.IsPlayRecord(self)
	return self.m_IsPlayRecord
end

function CWarCtrl.GetViewSide(self)
	return self.m_ViewSide
end

function CWarCtrl.GetWarType(self)
	return self.m_WarType
end

function CWarCtrl.IsFirstWarrior(self)
	local oWarrior = self:GetWarrior(self.m_HeroWid)
	if oWarrior and oWarrior.m_CampPos == 1 then
		return true
	else
		return false
	end
end

function CWarCtrl.AddBoutMagicInfo(self, atkid, vicids, magic, idx, cmdid)
	local dWaveInfo = self.m_BoutMagicInfo[self.m_ProtoWave]
	if not dWaveInfo then
		dWaveInfo = {}
		self.m_BoutMagicInfo[self.m_ProtoWave] = dWaveInfo
	end
	local dBoutInfo = dWaveInfo[self.m_ProtoBout]
	if not dBoutInfo then
		dBoutInfo = {info_list= {}}
	end
	local tInfo = {magic=magic, idx=idx, cmd_id = cmdid, atkid = atkid, vicids = vicids, is_end_idx = true}
	local dLastInfo = dBoutInfo.info_list[#dBoutInfo.info_list]
	if dLastInfo and dLastInfo.magic == magic and idx ~= 1 then
		dLastInfo.is_end_idx = false
	end
	table.insert(dBoutInfo.info_list, tInfo)
	local iCurIndex = #dBoutInfo.info_list
	for k, vicid in ipairs(vicids) do
		local list = dBoutInfo[vicid] or {}
		table.insert(list, {cmd_id=cmdid, info_index=iCurIndex})
		dBoutInfo[vicid] = list
	end
	self.m_BoutMagicInfo[self.m_ProtoWave][self.m_ProtoBout] = dBoutInfo
end

function CWarCtrl.GetBoutMagicInfo(self, iCmd, iOffSet)
	local dBoutInfo = table.safeget(self.m_BoutMagicInfo, self.m_CurWave, self.m_Bout)
	if dBoutInfo then
		for i, v in ipairs(dBoutInfo.info_list) do
			if v.cmd_id == iCmd then
				local idx = i + iOffSet
				local dInfo = dBoutInfo.info_list[idx]
				return dInfo
			end
		end
	end
end

--下一次施放法术的受击者
function CWarCtrl.GetNextCmdVics(self, iCmd)
	local dBoutInfo = table.safeget(self.m_BoutMagicInfo, self.m_CurWave, self.m_Bout)
	local bFindNext = false
	local vics = {}
	if dBoutInfo then
		for i, v in ipairs(dBoutInfo.info_list) do
			if bFindNext then
				if v.vicids then
					vics = v.vicids
					break
				end
			elseif v.cmd_id == iCmd then
				bFindNext = true
			end
		end
	end
	if g_WarCtrl.g_Print then
		-- printc(">>>>>>>GetNextCmdVics", bFindNext, self.m_CurWave, self.m_Bout, iCmd)
		-- table.print(self.m_BoutMagicInfo)
	end
	return vics
end

function CWarCtrl.GetNexCmdRunTime(self, vic, cmdid)
	local dBoutInfo = table.safeget(self.m_BoutMagicInfo, self.m_CurWave, self.m_Bout)
	if not dBoutInfo then
		return
	end
	local list = dBoutInfo[vic]
	if not list then
		return
	end
	local dCurInfo, dNexInfo
	for i, dInfo in ipairs(list) do
		if dInfo.cmd_id == cmdid then
			local idx = dInfo.info_index
			dCurInfo = dBoutInfo.info_list[idx]
			dNexInfo = dBoutInfo.info_list[idx+1]
			break
		end
	end
	if not (dCurInfo and dNexInfo) then
		return
	end
	if dCurInfo.atkid == dNexInfo.atkid then
		return
	end
	local oWarrior = self:GetWarrior(dNexInfo.atkid)
	local shape = oWarrior.m_Actor.m_Shape
	local time1 = g_MagicCtrl:GetMagcAnimEndTime(dCurInfo.magic, shape, dCurInfo.idx)
	if time1 then
		local time2 = g_MagicCtrl:GetMagcAnimStartTime(dNexInfo.magic, shape, dNexInfo.idx)
		if time2 then
			local time = math.max(0, time1 - time2)
			if g_WarCtrl.g_Print then
				printc("当前技能", dCurInfo.magic, "下一技能", dNexInfo.magic)
			end
			return time
		end
	end
end

function CWarCtrl.SetInResult(self, bResult)
	self.m_IsInResult = bResult
end

function CWarCtrl.ShowSceneEndWar(self)
	if self:IsWar() then
		local oCmd = CWarCmd.New("End")
		self:InsertCmd(oCmd)
		self.m_ShowSceneEndWar = true
		self:BoutEnd()
		self:FinishOrder()
		g_NetCtrl:SetCacheProto("warend", true)
		-- 记录战斗内容，暂时没用的
		-- if g_NetCtrl:IsRecord() and Utils.IsEditor() then
		-- 	g_NetCtrl:SaveRecordsToLocal("war"..os.date("%y_%m_%d(%H_%M_%S)", g_TimeCtrl:GetTimeS()), {side=self:GetAllyCamp()})
		-- 	g_NetCtrl:SetRecordType(nil)
		-- end
		-- 队伍判断一下
		g_TeamCtrl:ExcuteCacheCmd()
	end
end

function CWarCtrl.LoginInit(self)
end

function CWarCtrl.SetVaryCmd(self, oCmd)
	self.m_VaryCmd = oCmd
end

function CWarCtrl.GetVaryCmd(self)
	return self.m_VaryCmd
end

function CWarCtrl.Clear(self)
	self:WarriorRootActive(false)
	for k, oWarrior in pairs(self.m_Warriors) do
		if oWarrior then
			self:DelWarrior(k)
		end
	end
	if self.m_LoadingBg then
		self.m_LoadingBg:Destroy()
	end
	self:InitValue()
end

function CWarCtrl.WarriorRootActive(self, show)
	local oRoot = self:GetRoot()
	if oRoot then
		oRoot:SetActive(show)
	end
end

function CWarCtrl.IsWar(self)
	return self.m_WarID ~= nil
end

function CWarCtrl.GetWarID(self)
	return self.m_WarID
end

function CWarCtrl.IsChallengeType(self)
	return self.m_WarSysType == data.warconfigdata.COMMON[5].id
end

function CWarCtrl.IsNeedShowAnim(self)
	local d = DataTools.GetWarConfigData(self.m_WarSysType)
	if d then
		return d.show == 1
	end
end

function CWarCtrl.IsWarSky(self)
	-- WarSky == 1 (标识空战)
	return self.m_WarSky == 1
end

function CWarCtrl.IsWarWeather(self)
	return self.m_WarWeather and self.m_WarWeather > 0
end

function CWarCtrl.IsBossWarType(self)
	-- WarBossWar == 1 (标识boss战)
	return self.m_WarBossWar == 1
end

function CWarCtrl.InitWarBg(self)
	local function initAlphaBg()
		if not self.m_WarBg then
			CWarBg:ShowView(function (oView)
				self.m_WarBg = oView
			end)
		end
	end

	if self.m_WarSky and self.m_WarSky > 0 and not self.m_WarBgSky then
		-- CWarBgSky:ShowView(function (oView)
		-- 	self.m_WarBgSky = oView
		-- end)

		local isSpecityWeather = self.m_WarWeather == 2

		local function skyEffectDone(effect)
			if self:IsWar() then
				local oRoot = self:GetRoot()
				effect:SetParent(oRoot.m_Transform, false)
				effect:SetLocalPos(Vector3.New(0, 2, 10))
			else
				effect:Destroy()
			end
		end
		-- if not isSpecityWeather then
			-- 云层
			local coludPath = "Effect/Scene/scene_eff_0021/Prefabs/scene_eff_0021.prefab"
			self.m_SkyCloudEffect = CEffect.New(coludPath, UnityEngine.LayerMask.NameToLayer("War"), false, skyEffectDone)
		-- end

		-- 大雁
		local wildPath = "Effect/Scene/scene_eff_0022/Prefabs/scene_eff_0022.prefab"
		self.m_SkyWildEffect = CEffect.New(wildPath, UnityEngine.LayerMask.NameToLayer("War"), false, skyEffectDone)

		local function skyBgDone(effect)
			if self:IsWar() then
				local oRoot = UITools.GetWarUIRoot()
				effect:SetParent(oRoot.transform, false)
				effect:SetLocalScale(Vector3.one)
			else
				effect:Destroy()
			end
		end
		-- (不要了)
		-- if isSpecityWeather then
		-- 	-- 变色
		-- 	local coludPath = "Effect/Scene/scene_eff_0025/Prefabs/scene_eff_0025.prefab"
		-- 	self.m_SkyColorEffect = CEffect.New(coludPath, UnityEngine.LayerMask.NameToLayer("WarUI"), false, skyBgDone)
		-- else
			-- 背景底图
			-- local wildPath = "Effect/Scene/scene_eff_0024/Prefabs/scene_eff_0024.prefab"
			-- self.m_SkyBgEffect = CEffect.New(wildPath, UnityEngine.LayerMask.NameToLayer("WarUI"), false, skyBgDone)
		-- end
	else
		initAlphaBg()
	end
end

function CWarCtrl.InitWarFormation(self)
	local fmt1Show = self.m_Fmt_id1 and self.m_Fmt_id1 > 1
	local fmt1Info = {fmtID = self.m_Fmt_id1, name = "FormationAlly", show = fmt1Show}
	local fmt2Show = self.m_Fmt_id2 and self.m_Fmt_id2 > 1
	local fmt2Info = {fmtID = self.m_Fmt_id2, name = "FormationEnemy", show = fmt2Show}

	local nameList = {fmt1Info, fmt2Info}

	-- 加载结束后的操作
	local onFmtLoadDone = function (oFormation, key, fmtid)
		self[key] = oFormation
		if self:IsWar() then
			local oRoot = self:GetRoot()
			oFormation:SetParent(oRoot.m_Transform, false)

			-- load Texture
			local func = function (texture, path)
				if Utils.IsNil(self[key]) then
					return
				end
				local meshRender = Utils.GetGameObjComponent(oFormation, classtype.MeshRenderer)
				if meshRender then
					meshRender.material.mainTexture = texture
					g_ResCtrl:AddManageAsset(meshRender.material.mainTexture, oFormation.m_GameObject, path)
				end
			end
			local fmtInfo = data.formationdata.BASEINFO[fmtid]
			if fmtInfo.formationbg ~= "" then
				local sPath = string.format("Texture/Misc/fmt%s.png", fmtInfo.formationbg)
				g_ResCtrl:LoadAsync(sPath, func)
			end
		else
			g_ResCtrl:PutCloneInCache(oFormation:GetCacheKey(), oFormation.m_GameObject)
			self[key] = nil
		end
	end

	for _,v in ipairs(nameList) do
		local key = "m_" .. v.name
		local oFormation = self[key]
		if v.show then
			local path = string.format("UI/War/%s.prefab", v.name)
			if oFormation then
				onFmtLoadDone(oFormation, key, v.fmtID)
			else
				g_ResCtrl:LoadCloneAsync(path, function (oClone)
					local oFormation = CObject.New(oClone)
					if self[key] then
						self[key]:Destroy()
						self[key] = nil
					end
					onFmtLoadDone(oFormation, key, v.fmtID)
				end, false)
			end
		else
			if oFormation then
				g_ResCtrl:PutCloneInCache(oFormation:GetCacheKey(), oFormation.m_GameObject)
				self[key] = nil
			end
		end
	end
end

function CWarCtrl.InitWarWeather(self)
	if self.m_WarWeather and self.m_WarWeather > 0 and not self.m_WeatherEffect then
		local path = define.War.WeatherPath[self.m_WarWeather][self.m_WarSky == 1 and 2 or 1]
		local function cb(oWeather)
			if self:IsWar() then
				local oRoot = self:GetRoot()
				oWeather:SetParent(oRoot.m_Transform, false)
			else
				oWeather:Destroy()
			end
		end
		self.m_WeatherEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("War"), false, cb)
	end
end

function CWarCtrl.StopCachedProto()
	g_NetCtrl:SetCacheProto("warend", false)
	g_NetCtrl:ClearCacheProto("warend", true)
end

function CWarCtrl.WarStatus(self, bout, downtime)
	self.m_Bout = bout
	g_WarOrderCtrl:Bout(downtime)
	local oView = CWarFloatView:GetView()
	self.m_WarBoutTips = true
	if oView then
		oView:ResetBoutTimeTip()
	end
end

function CWarCtrl.Start(self, pbdata)
	if g_AttrCtrl.pid == 0 then
		printerror("pid为0，标识客户端已进入重登流程")
		return
	end

	self:Clear()
	g_ResCtrl:MoveToSecondary()
	g_WarTouchCtrl:SetLock(false)
	
	self:WarriorRootActive(true)
	self.m_WarID = pbdata.war_id
	self.m_WarType = pbdata.war_type
	self.m_WarSky = pbdata.sky_war
	self.m_WarWeather = pbdata.weather
	self.m_WarBossWar = pbdata.is_bosswar
	self.m_bullet_show = pbdata.barrage_show
	self.m_bullet_send = pbdata.barrage_send     --0:关闭战斗弹幕所有 1:开启观战弹幕 2：开启战斗和观战 
	self.m_WarSysType = pbdata.sys_type
	self:StopCachedProto()
	g_MapCtrl:Clear(false)
	g_ResCtrl:ClearLoadAssetQueue()
	g_ResCtrl:CheckForceGc()
	g_MagicCtrl:Clear("war")
	g_HudCtrl:SceneChangeEvent(true)
	g_SummonCtrl:CheckQuickOrder()
	self:SwitchEnv(true)
	self.m_Bout = 1
	self.m_ActionFlag = 1
	self.m_IsWarStart = true
	self.m_ChatMsgCnt = 0
	self:InitWar()
	g_GuideCtrl:OnTriggerAll()
	g_FlyRideAniCtrl:ResetAll()

	self:OnEvent(define.War.Event.WarStart, pbdata)

	local musicPath = define.Audio.MusicPath.warnormal
	if self.m_WarBossWar == 1 then
		-- Boss
		musicPath = define.Audio.MusicPath.warboss
	elseif self.m_WarType == define.War.War_Type.PVP_TYPE then
		-- PVP
		musicPath = define.Audio.MusicPath.warpvp
	end
	g_AudioCtrl:PlayMusic(musicPath)

	if g_WarCtrl:IsChallengeType() then
		local oFloatView = CWarFloatView:GetView()
		if oFloatView then
			oFloatView:SetAutoFightSp(true)
		end
	end
end

function CWarCtrl.InitWar(self)
	self:InitWarBg()
	self:InitWarWeather()
end

function CWarCtrl.End(self)
	if not self:IsWar() then
		return
	end

	if self.m_ViewSide then
		-- 退出观战
		netplayer.C2GSLeaveObserverWar(self.m_WarID)
		-- if self.m_IsClientRecord then
		-- 	g_NetCtrl:ResetReceiveRecord()
		-- 	netscene.C2GSReenterScene()
		-- end
	end
	g_MagicCtrl:Clear("war")
	-- g_HudCtrl:SetRootActive("CNameHud", true)
	self:Clear()
	self:SwitchEnv(false)
	self:StopCachedProto()
	if self:IsPlayRecord() then
		self.m_IsPlayRecord = false
		g_NetCtrl:ResetReceiveRecord()
	end
	self.m_ViewSide = nil
	if self.m_WarBg then
		self.m_WarBg:Destroy()
		self.m_WarBg = nil
	end
	if self.m_WarBgSky then
		self.m_WarBgSky:Destroy()
		self.m_WarBgSky = nil
	end
	if self.m_FormationAlly then
		g_ResCtrl:PutCloneInCache(self.m_FormationAlly:GetCacheKey(), self.m_FormationAlly.m_GameObject)
		-- self.m_FormationAlly:Destroy()
		self.m_FormationAlly = nil
	end
	if self.m_FormationEnemy then
		g_ResCtrl:PutCloneInCache(self.m_FormationEnemy:GetCacheKey(), self.m_FormationEnemy.m_GameObject)
		-- self.m_FormationEnemy:Destroy()
		self.m_FormationEnemy = nil
	end
	if self.m_SkyColorEffect then
		self.m_SkyColorEffect:Destroy()
		self.m_SkyColorEffect = nil
	end
	if self.m_SkyCloudEffect then
		self.m_SkyCloudEffect:Destroy()
		self.m_SkyCloudEffect = nil
	end
	if self.m_SkyWildEffect then
		self.m_SkyWildEffect:Destroy()
		self.m_SkyWildEffect = nil
	end
	if self.m_SkyBgEffect then
		self.m_SkyBgEffect:Destroy()
		self.m_SkyBgEffect = nil
	end
	if self.m_WeatherEffect then
		self.m_WeatherEffect:Destroy()
		self.m_WeatherEffect = nil
	end
	CPlotMaskView:CloseView()
	g_GuideCtrl:OnTriggerAll()
	g_ScheduleCtrl:SetStopNotifyTime()
	g_TaskCtrl:SetTaskIntervalNotifyTime()

	g_MapCtrl:PlayBgMusic()
	self:OnEvent(define.War.Event.WarEnd)
end

function CWarCtrl.SwitchEnv(self, bWar)
	--像机
	g_CameraCtrl:AutoActive()
	--界面
	local oView = CMainMenuView:GetView()
	if oView then
		oView:SwitchEnv(bWar)
	end

	if bWar then
		CWarFloatView:ShowView(function (oView)
			if g_WarCtrl:IsChallengeType() then
				oView:SetAutoFightSp(true)
			end
		end)
		CWarMainView:ShowView()
		CJjcMainView:CloseView()
		CArenaMainView:CloseView()
		CPKPrepareView:CloseView()
		CWorldBossMainView:CloseView()
		CGmMainView:CloseView()
		CGmWarSimulateView:CloseView()
		CDialogueOptionView:CloseView()
		CTeamMemberOpView:CloseView()
		CPromoteBtnView:CloseView()
		CFightOutsideBuffView:CloseView()
		CDialogueMainView:CloseView()
		CThreeBiwuInfoView:CloseView()
		CJjcMainNewView:CloseView()
		CJieBaiInvitedMainView:CloseView()
		CJieBaiMainView:CloseView()
	else
		CWarFloatView:CloseView()
		CWarMainView:CloseView()
		CWarItemView:CloseView()
		CWarCmdSelView:CloseView()
		CWarMagicView:CloseView()
		CMagicDescView:CloseView()
		CWarSelAutoView:CloseView()
		CWarSummonView:CloseView()
		CWarTargetDetailView:CloseView()
		CWarFormationInfoView:CloseView()
		g_BarrageCtrl:CloseBarrageView()
	end
end

function CWarCtrl.GetRoot(self)
	if Utils.IsNil(self.m_Root) then
		self.m_Root = CWarRoot.New()
		self.m_Root:SetOriginPos(Vector3.zero)
	end
	return self.m_Root
end

function CWarCtrl.AddWarrior(self, wid, oWarrior)
	if self.m_Warriors[wid] then
		self.m_Warriors[wid]:Destroy()
	end
	local oRoot = self:GetRoot()
	oWarrior:SetParent(oRoot.m_Transform, false)
	self.m_Warriors[wid] = oWarrior
	self.m_InstanceID2Warrior[oWarrior:GetInstanceID()] = oWarrior

	if oWarrior.m_Pid == self.m_WarPid then
		self.m_HeroWid = wid
		self.m_AllyCmap = oWarrior.m_CampID
		self:UpdateHeroState()
	elseif oWarrior.m_OwnerWid == self.m_HeroWid then
		self.m_SummonWid = wid
		local summonid = oWarrior.m_SummonID
		self:OnEvent(define.War.Event.RefreshQuickSummon)

		if not self:IsSummonFighted(summonid) then
			table.insert(self.m_FightSummonIDList, summonid)
		end
		self:UpdateSummonState()
	end
	oWarrior:UpdateOriginPos()
end

function CWarCtrl.GetHero(self)
	if self.m_HeroWid then
		return self.m_Warriors[self.m_HeroWid]
	end
end

function CWarCtrl.GetHeroPid(self)
	if self.m_HeroPid then
		return self.m_HeroPid
	elseif not self:GetViewSide() then
		return self.m_WarPid
	else
		return 0
	end
end

function CWarCtrl.GetSummon(self)
	if self.m_SummonWid then
		return self.m_Warriors[self.m_SummonWid]
	end
end

function CWarCtrl.GetAllyCamp(self)
	return self.m_AllyCmap
end

function CWarCtrl.DelWarrior(self, wid)
	if wid == self.m_HeroWid then
		self.m_HeroWid = nil
		self:UpdateHeroState()
	elseif wid == self.m_SummonWid then
		self.m_SummonWid = nil
		self:UpdateSummonState()
	end
	local oWarrior = self.m_Warriors[wid]
	if oWarrior then
		self.m_InstanceID2Warrior[oWarrior:GetInstanceID()] = nil
		self.m_Warriors[wid] = nil
		oWarrior:Destroy()
	end
end

function CWarCtrl.GetWarriors(self)
	return self.m_Warriors
end

function CWarCtrl.GetWarrior(self, wid)
	return self.m_Warriors[wid]
end

function CWarCtrl.GetWarriorByID(self, pid)
	for i, oWarrior in ipairs(self.m_Warriors) do
		if oWarrior.m_Pid == pid then
			return oWarrior
		end
	end
end

--是否正在播放回合动画
function CWarCtrl.IsInAction(self)
	if g_WarCtrl.g_Print then
		-- printc("============= CWarCtrl.IsInAction", self.m_ActionFlag, self.m_ShowSceneEndWar)
	end
	return self.m_ActionFlag > 0 or self.m_ShowSceneEndWar
end

function CWarCtrl.GetWarriorByPos(self, camp, pos)
	for i, oWarrior in ipairs(self.m_Warriors) do
		if camp == oWarrior.m_CampID and oWarrior.m_CampPos == pos then
			return oWarrior
		end
	end
end

--是否刚刚开始战斗
function CWarCtrl.IsWarStart(self)
	return self.m_IsWarStart
end

function CWarCtrl.RefreshAllPos(self)
	--刷新全部站位
	for wid, oWarrior in pairs(self.m_Warriors) do
		oWarrior:UpdateOriginPos()
	end
	if g_WarCtrl.g_Print then
		printc("刷新全部站位: ", self.m_WarType)
		-- table.print(self.m_AllyPartnerWids, "ally_player:"..tostring(self.m_AllyPlayerCnt))
		-- table.print(self.m_EnemyPartnerWids, "enemy_player:"..tostring(self.m_EnemyPlayerCnt))
	end
end

-- function CWarCtrl.CheckActivityView(self)
-- 	if self.m_WarType == define.War.Type.Boss then
-- 		CWarWorldBossView:ShowView()
-- 	elseif self.m_WarType == define.War.Type.OrgBoss then
-- 		CWarOrgBossView:ShowView()
-- 	end
-- end

function CWarCtrl.BoutStart(self, iBout, iOrderTime)
	-- self.m_Index = 0
	if self.m_IsWarStart then
		self.m_ActionFlag = 1
		-- self.m_IsWarStart = false
		self:RefreshAllPos()
		-- self:CheckActivityView()
	else
		self.m_ActionFlag = self.m_ActionFlag - 1
	end
	-- g_HudCtrl:SetRootActive("CNameHud", true)
	self.m_Bout = iBout
	printc("CWarCtrl.BoutStart -->> ActionFlag | iBout:", self.m_ActionFlag, self.m_Bout)
	for wid, oWarrior in pairs(self.m_Warriors) do
		oWarrior:SetOrderDone(true)
		if self:IsChallengeType() or self:GetViewSide() then
			oWarrior:SetOrderDone(true)
		elseif oWarrior:IsAlly() then
			oWarrior:SetOrderDone(false)
		end
		if not self:IsChallengeType() and (self:GetViewSide() or not oWarrior:IsAlly()) then
			oWarrior:ShowLvSchHudSwitch(true)
		end
		oWarrior:Bout()
	end

	-- 引导相关
	if self.m_IsFirstSpecityWar then
		if self.m_FirstSpecityWarStep < 2 then
			self.m_FirstSpecityWarStep = self.m_FirstSpecityWarStep + 1
			if self.m_FirstSpecityWarStep == 2 and self:GetBout() == 1 then
				-- 战斗引导相关
				g_GuideCtrl:OnTriggerAll()
			end
		end
		if self:GetBout() == 3 or self:GetBout() == 4 then
			self:FinishOrder()
		end
	end

	-- if not self:IsInAction() then
		g_WarOrderCtrl:Bout(iOrderTime)
	-- end
	self:DelayEvent(define.War.Event.BoutStart, iBout)
	local endfunc = table.safeget(self.m_BoutEnd, self.m_ProtoWave, self.m_Bout)
	if endfunc then
		endfunc()
	end
	
	self.m_WarBoutTips = false
	local oView = CWarFloatView:GetView()
	if oView then
		oView:ResetBoutTimeTip()
	end
	self.m_IsBoutEnd = false
end

function CWarCtrl.BoutEnd(self)
	if self.m_IsWarStart then
		self.m_ActionFlag = 1
		self.m_IsWarStart = false
	else
		self.m_ActionFlag = self.m_ActionFlag + 1
	end
	-- printerror("BoutEnd",self.m_ActionFlag)

	-- g_HudCtrl:SetRootActive("CNameHud", false)
	self.m_IsBoutEnd = true
end

function CWarCtrl.FinishOrder(self)
	for wid, oWarrior in pairs(self.m_Warriors) do
		if oWarrior:IsAlly() then
			oWarrior:SetOrderDone(true)
		elseif not self:GetViewSide() then
			oWarrior:ShowLvSchHudSwitch(false)
		end
	end
	g_WarOrderCtrl:FinishOrder()
end

function CWarCtrl.RefreshFormation(self, pbdata)
	if self:GetAllyCamp() == 1 then
		self.m_Fmt_id1 = pbdata.fmt_id1
		self.m_Fmt_id2 = pbdata.fmt_id2
		self.m_Fmt_grade1 = pbdata.fmt_grade1
		self.m_Fmt_grade2 = pbdata.fmt_grade2
	else
		self.m_Fmt_id1 = pbdata.fmt_id2
		self.m_Fmt_id2 = pbdata.fmt_id1
		self.m_Fmt_grade1 = pbdata.fmt_grade2
		self.m_Fmt_grade2 = pbdata.fmt_grade1
	end

	self:InitWarFormation()
	self:OnEvent(define.War.Event.Formation)
end

function CWarCtrl.GS2CWarObCount(self, count)
	self.m_WarObCount = count
	self:OnEvent(define.War.Event.MatchCount, count)
end

function CWarCtrl.GetBout(self)
	return self.m_Bout
end

function CWarCtrl.SetWave(self, curWave, sumWave)
	printc(string.format("SetWave:%s/%s", curWave, sumWave))
	self.m_SumWave = sumWave
	self.m_CurWave = curWave
end

function CWarCtrl.GetWaveText(self)
	if self.m_SumWave == 0 and self.m_CurWave == 0 then
		return nil
	elseif self.m_SumWave == 0 then
		return string.format("第%s波", self.m_CurWave)
	else
		return string.format("第%s/%s波", self.m_CurWave, self.m_SumWave)
	end
end

function CWarCtrl.GetPriorPos(self, root, ...)
	-- 占位
	local args = {...}
	local v= root
	for i, key in ipairs(args) do
		if v[key] then
			v = v[key]
		else
			return
		end
	end
	return v
end

function CWarCtrl.GetBossLinupPos(self, iPos)
	local pointer = tostring(iPos)
	local pos = DataTools.GetBossLineupPos(iPos)
	if not pos then
		pos = DataTools.GetBossLineupPos(1)
	end
	return pos
end

function CWarCtrl.GetLinupPos(self, isAlly, iPos)
	local pointer = isAlly and "A" or "B"
	pointer = pointer..tostring(iPos)
	local pos = DataTools.GetLineupPos(pointer)
	if pos then
		return pos
	end
	local pointer = isAlly and "A" or "B"
	pointer = pointer.."1"
	local pos = DataTools.GetLineupPos(pointer)
	if pos then
		pos.y = 0
		return pos
	end
	return Vector3.zero

	-- N1
	--[[
	local iAlly = isAlly and 1 or 2
	local iMemberCnt
	if isAlly then
		iMemberCnt = math.min(self.m_AllyPlayerCnt, 4)
	else
		if self.m_WarType == define.War.Type.PVP then
			iMemberCnt = self.m_EnemyPlayerCnt
		else
			iMemberCnt = 4
		end
	end
	local sKey, xzpos
	local iParCnt = 4 --方便打印
	if iMemberCnt > 1 then
		xzpos = table.safeget(data.lineupdata.PRIOR_POS, "team", iMemberCnt, iAlly, iPos)
		if not xzpos then
			sKey = data.lineupdata.GRID_POS_KEY["team"][iMemberCnt][iAlly][iPos]
		end
	else
		if not self.m_FillFullPos then
			if isAlly then
				iParCnt = table.count(self.m_AllyPartnerWids)
			else
				iParCnt = table.count(self.m_EnemyPartnerWids)
			end
		end
		print(data.lineupdata.PRIOR_POS["single"][iParCnt+1][iAlly][iPos])
		xzpos = table.safeget(data.lineupdata.PRIOR_POS, "single", iParCnt+1, iAlly, iPos)
		if not xzpos then
			sKey = data.lineupdata.GRID_POS_KEY["single"][iParCnt+1][iAlly][iPos]
		end
	end
	
	if xzpos then
		print("自定义站位", iPos,  xzpos.x, xzpos.z)
		return Vector3.New(xzpos.x, 0,xzpos.z)
	elseif sKey then
		print("格子站位, isAlly:",isAlly,"iPos:",iPos,"pos_key:",sKey)
		xzpos = data.lineupdata.GRID_POS_MAP[sKey]
		return Vector3.New(xzpos.x, 0,xzpos.z)
	else
		print(string.format("linup pos err: iAlly: %d, iMemberCnt:%d, iParCnt:%d, self.m_EnemyPlayerCnt:%d, self.m_AllyPlayerCnt:%d", iAlly, iMemberCnt, iParCnt, self.m_EnemyPlayerCnt, self.m_AllyPlayerCnt))
		table.print(self.m_AllyPartnerWids, "m_AllyPartnerWids")
		table.print(self.m_EnemyPartnerWids, "m_EnemyPartnerWids")
		return Vector3.zero
	end
	]]--
end

function CWarCtrl.IsAllExcuteFinish(self)
	local bFinish = not g_MagicCtrl:IsExcuteMagic()

	if bFinish then
		for i, oWarrior in pairs(self.m_Warriors) do
			if oWarrior:IsBusy() then
				bFinish = false
				break
			end
		end
	end

	return bFinish
end

function CWarCtrl.GetCmds(self)
	return self.m_CmdList
end

function CWarCtrl.InsertCmd(self, oCmd)
	table.insert(self.m_CmdList, oCmd)
	-- local names = ""
	-- for k,v in pairs(self.m_CmdList) do
	-- 	if names == "" then
	-- 		names = v.m_Func
	-- 	else
	-- 		names = names .. " | " .. v.m_Func
	-- 	end
	-- end
	-- printc("=============== 执行名称", names)
end

function CWarCtrl.GetLastCmd(self)
	local iCmdCnt = #self.m_CmdList
	if iCmdCnt > 0 then
		return self.m_CmdList[iCmdCnt]
	end
end

function CWarCtrl.InsertBountEndCmd(self, oCmd)
	for i,cmd in ipairs(self.m_CmdList) do
		if cmd.m_Func == "BoutStart" then
			-- printc("InsertBountEndCmd")
			table.insert(self.m_CmdList, i + 1, oCmd)
			return
		end
	end
	oCmd:Excute()
end

function CWarCtrl.CreateAction(self, func, ...)
	if g_WarCtrl.g_Print then
		-- self.m_Index = (self.m_Index or 0) + 1
		-- printerror("====== CWarCtrl.CreateAction", self.m_Index)
	end
	return {func, {...}, select("#", ...)}
end

function CWarCtrl.InsertAction(self, func, ...)
	local action = self:CreateAction(func, ...)
	table.insert(self.m_MainActionList, action)
end

function CWarCtrl.InsertActionFirst(self, func, ...)
	local action = self:CreateAction(func, ...)
	table.insert(self.m_MainActionList, 1, action)
end

function CWarCtrl.GetSubActionListID(self)
	self.m_SubActionListIdx = self.m_SubActionListIdx + 1
	return self.m_SubActionListIdx
end

function CWarCtrl.GetCmdID(self)
	self.m_CmdIdx = self.m_CmdIdx + 1
	return self.m_CmdIdx
end

function CWarCtrl.AddSubActionList(self, list, id)
	id = id or self:GetSubActionListID()
	self.m_SubActionsDict[id] = list
	return id
end

function CWarCtrl.MoveActionListMainToSub(self)
	local id = self:GetSubActionListID()
	self.m_SubActionsDict[id] = self.m_MainActionList
	self.m_MainActionList = {}
end

function CWarCtrl.SkipActionProcess(self)
	self.m_SkipAction = true
end

function CWarCtrl.WaitBoutStart(self, iBoutID, iBoutTime)
	for i, oWarrior in ipairs(self:GetWarriors()) do
		if oWarrior:IsBusy() or oWarrior.m_PlayMagicID ~= nil then
			self.m_WaitBoutStart = true
			return false
		end
	end
	self.m_WaitBoutStart = false
	self:BoutStart(iBoutID, iBoutTime)
	return true
end

function CWarCtrl.Update(self, dt)
	if self.m_WarID then
		-- 暂停时需要计时，H7中不需要
		-- if g_WarOrderCtrl.m_TimeInfo then
		-- 	g_WarOrderCtrl.m_TimeInfo.start_time = g_WarOrderCtrl.m_TimeInfo.start_time + dt
		-- end
		self:UpdateActions()
		self:UpdateCmds()
		self:UpdateWeather()
	end
end

function CWarCtrl.UpdateCmds(self)
	if g_WarCtrl.g_Print then
		-- printc("CWarCtrl.UpdateCmds",self:IsInAction(), table.count(self.m_CmdList))
		--local action = self:IsInAction()
		--local list = next(self.m_MainActionList)
		-- printc("========== CWarCtrl.UpdateCmds ============", action, list)
	end
	if --[=[self:IsInAction() and]=] not self.m_WaitTime and next(self.m_MainActionList) == nil then
		while next(self.m_CmdList) ~= nil do
			local oCmd = self.m_CmdList[1]
			--printc("UpdateCmds", oCmd.m_Func)

			-- table.print(oCmd)
			if oCmd:IsUsed() then
				table.remove(self.m_CmdList, 1)
			else
				local sucess, ret = xxpcall(oCmd.Excute, oCmd)
				if not sucess then
					table.remove(self.m_CmdList, 1)
				end
				if next(self.m_MainActionList) ~= nil then
					break
				end
			end
		end
	end
end

function CWarCtrl.ProcessActionList(self, list)
	local iCur = 1
	local iLen = #list
	for i = 1, iLen do
		local action = list[i]
		local func, args, arglen = unpack(action, 1, 3)
		local sucess, ret = xxpcall(func, unpack(args, 1, arglen))
		if sucess and ret == false then
			break
		end
		iCur = iCur + 1
		if self.m_SkipAction then
			self.m_SkipAction = false
			printc("CWarCtrl.ProcessActionList --> Skip action")
			break
		end
	end
	local newlist = {}
	local iNewLen = #list
	for i=iCur, iNewLen do
		table.insert(newlist, list[i])
	end
	return newlist
end

function CWarCtrl.UpdateActions(self)
	if g_WarCtrl.g_Print then
		local count1 = table.count(self.m_MainActionList)
	end
	self.m_MainActionList = self:ProcessActionList(self.m_MainActionList)
	local count2 = table.count(self.m_MainActionList)

	if not Utils.IsInEditorMode() and not self.m_IsFirstSpecityWar then
		local function sendAniEnd()
			if not self:IsWar() then
				return
			end
			print("客户端发送动作结束 SendToServer AniEnd",self.m_WarID,self.m_Bout)
			netwar.C2GSWarAnimationEnd(self.m_WarID, self.m_Bout)
		end 
		if self.m_IsBoutEnd and count2 == 0 and not self.m_CmdList[1] then
			self.m_IsBoutEnd = false
			Utils.AddTimer(sendAniEnd, 0, 0.5)
		end
	end

	if g_WarCtrl.g_Print then
		-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "UpdateActions", "前后运行主线数"), count1, count2)
	end

	for k, actionlist in pairs(self.m_SubActionsDict) do
		local list = self:ProcessActionList(actionlist)
		list = #list > 0 and list or nil
		self.m_SubActionsDict[k] = list
	end
end

function CWarCtrl.UpdateWeather(self)
	if self.m_WarWeather and self.m_WarWeather > 1 then
		if not self.m_WarWeatherWetTimer then
			local random = math.random(0, 10)
			if random < 3 then
				-- 添加一个特效
				local function cb(effect)
					if self:IsWar() then
						local oRoot = UITools.GetUIRoot()
						effect:SetParent(oRoot.transform, false)
						effect:SetLocalScale(Vector3.one)

						-- if self.m_WarWeather == 3 then
						-- 	local cont = CGameObjContainer.ctor(effect, effect.m_GameObject)
						-- 	table.print(cont)
						-- 	local bg1 = cont:NewUI(1, CObject)
						-- 	local bg2 = cont:NewUI(2, CObject)
						-- 	bg1:SetLocalScale(Vector3.New(900, 768, 0))
						-- end
					else
						effect:Destroy()
					end
				end

				local path = define.War.WeatherWetPath[self.m_WarWeather]
				local wetEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("UI"), false, cb)
				local time = math.random(18, 30)
				self.m_WarWeatherWetTimer = Utils.AddTimer(function ()
					self.m_WarWeatherWetTimer = nil
					wetEffect:Destroy()
					wetEffect = nil
					return false
				end, 3, time)
			end
		end
	end
end

--自动战斗
function CWarCtrl.SetAutoWar(self, iAutoWar, send2gs)
	if self.m_IsFirstSpecityWar then
		if self:GetBout() == 2 and self.m_FirstSpecityWarStep == 3 then
			self.m_FirstSpecityWarStep = 4
			self.m_IsAutoWar = 1
			warsimulate.Bout2()
			return
		end
	end
	if send2gs then
		netwar.C2GSWarAutoFight(self:GetWarID(), iAutoWar)
		return
	end
	if self.m_IsAutoWar == iAutoWar then
		return
	end
	self.m_IsAutoWar = iAutoWar
	self:OnEvent(define.War.Event.AutoWar)
end

function CWarCtrl.IsAutoWar(self)
	return self.m_IsAutoWar == 1
end

function CWarCtrl.GetHeroAutoMagic(self)
	return self.m_AutoMagic.hero or 101
end

function CWarCtrl.GetSummonAutoMagic(self)
	return self.m_AutoMagic.summon or 101
end

function CWarCtrl.SetAutoMagic(self, iMagicID, bHero)
	if bHero then
		self.m_AutoMagic.hero = iMagicID
	else
		self.m_AutoMagic.summon = iMagicID
	end
	-- IOTools.SetRoleData("war_auto_magic", self.m_AutoMagic)
	self:OnEvent(define.War.Event.AutoMagic)
end

--状态改变以及通知
function CWarCtrl.WarriorStatusChange(self, wid)
	if wid == self.m_HeroWid then
		--printc("WarriorStatusChange",wid)
		self:UpdateHeroState()
	elseif wid == self.m_SummonWid then
		self:UpdateSummonState()
	end
end

-- 战斗状态改变以及通知
function CWarCtrl.WarriorStatusBuffChange(self, wid)
	if wid == self.m_HeroWid then
		self:UpdateHeroStateBuff()
	elseif wid == self.m_SummonWid then
		self:UpdateSummonStateBuff()
	end
end

function CWarCtrl.GetDefalutState(self, dSrc, bIsPlayer)
	dSrc = dSrc or {}
	return {
		hp = dSrc.hp or 0,
		mp = dSrc.mp or 0,
		sp = bIsPlayer and dSrc.sp or 0,
		max_hp = dSrc.hp or 0,
		max_mp = dSrc.mp or 0,
		max_sp = bIsPlayer and dSrc.max_sp or 0,
		grade = dSrc.grade or 0,
		shape = dSrc.model_info and dSrc.model_info.shape or 0,
	}
end

function CWarCtrl.InitHeroState(self)
	if not self.m_HeroState then
		self.m_HeroState = self:GetDefalutState(g_AttrCtrl, true)
	end
end

function CWarCtrl.InitSummonState(self)
	if not self.m_SummonState then
		local dSummon = g_SummonCtrl:GetCurFightSummonInfo()
		self.m_SummonState = self:GetDefalutState(dSummon)
	end
end

function CWarCtrl.GetHeroState(self)
	if self:GetViewSide() then
		return self:GetDefalutState(g_AttrCtrl, true)
	end
	self:InitHeroState()
	return self.m_HeroState
end

function CWarCtrl.GetSummonState(self)
	if self:GetViewSide() then
		local dSummon = g_SummonCtrl:GetCurFightSummonInfo()
		return self:GetDefalutState(dSummon)
	end
	self:InitSummonState()
	return self.m_SummonState
end

function CWarCtrl.UpdateHeroState(self)
	if self.m_HeroWid then
		self:InitHeroState()
		local oWarrior = self:GetWarrior(self.m_HeroWid)
		if oWarrior then
			self:RefreshState(oWarrior, self.m_HeroState, define.War.Event.HeroState)
		end
	end
end

function CWarCtrl.UpdateSummonState(self)
	if self.m_SummonWid then
		self:InitSummonState()
		local oWarrior = self:GetWarrior(self.m_SummonWid)
		if oWarrior then
			local dSummon = g_SummonCtrl:GetSummon(oWarrior.m_SummonID)
			if dSummon then
				self.m_SummonState.shape = dSummon.model_info.shape
				self.m_SummonState.grade = dSummon.grade
			end
			self:RefreshState(oWarrior, self.m_SummonState, define.War.Event.SummonState)
		end
	end
end

function CWarCtrl.UpdateHeroStateBuff(self)
	-- printerror("人物 刷新战斗状态")
	do return end
	if self.m_HeroWid then
		local oWarrior = self:GetWarrior(self.m_HeroWid)
		if oWarrior then
			self:RefreshStateBuff(oWarrior, self.m_HeroState, define.War.Event.HeroState)
		end
	end
end

function CWarCtrl.UpdateSummonStateBuff(self)
	-- printerror("宠物 刷新战斗状态")
	do return end
	if self.m_SummonWid then
		local oWarrior = self:GetWarrior(self.m_SummonWid)
		if oWarrior then
			local dSummon = g_SummonCtrl:GetSummon(oWarrior.m_SummonID)
			if dSummon then
				self.m_SummonState.shape = dSummon.model_info.shape
				self.m_SummonState.grade = dSummon.grade
			end
			self:RefreshStateBuff(oWarrior, self.m_SummonState, define.War.Event.SummonState)
		end
	end
end

function CWarCtrl.RefreshState(self, oWarrior, dState, iEventID)
	if oWarrior and oWarrior.m_Status then
		for k, _ in pairs(dState) do
			local v = oWarrior.m_Status[k]
			if v and dState[k] ~= v then
				dState[k] = v
			end
		end
		if g_WarCtrl.g_Print then
			--printc("RefreshState", oWarrior:GetName(), oWarrior:IsAlive())
			-- table.print(dState)
		end
	end
	self:OnEvent(iEventID)
end

function CWarCtrl.RefreshStateBuff(self, oWarrior, dState, iEventID)
	-- body
end

--buff改变
function CWarCtrl.WarriorBuffChange(self, wid, buffid)
	if wid == self.m_HeroWid then
		self:DelayEvent(define.War.Event.HeroBuff)
	elseif wid == self.m_SummonWid then
		self:DelayEvent(define.War.Event.SummonBuff)
	end
end

--技能按钮cd
function CWarCtrl.RefreshMagicBtnCd(self, bHero)
	if bHero then
		self:OnEvent(define.War.Event.HeroState)
	else
		self:OnEvent(define.War.Event.SummonState)
	end
end

function CWarCtrl.GetFaBaoMagicList(self)
	local list = {}
	local oWarrior = self:GetWarrior(self.m_HeroWid)
	if oWarrior and oWarrior.m_MagicList then
		list = oWarrior:GetFaBaoMagicList()--table.copy(oWarrior.m_MagicList)
	end
	return list
end

--技能
function CWarCtrl.GetHeroMagicList(self)
	local list = {}
	local oWarrior = self:GetWarrior(self.m_HeroWid)
	if oWarrior and oWarrior.m_MagicList then
		list = oWarrior:GetHeroMagicList()--table.copy(oWarrior.m_MagicList)
	end
	-- list = table.extend(list, {1, 2})
	
	-- 根据技能表sortOrder排序
    local schSkillList = g_SkillCtrl:GetSchoolSkillList(g_AttrCtrl.school)
    local sortDict = {}
    for i, v in ipairs(schSkillList) do
        for k in pairs(v.magics) do
            sortDict[k] = v.sortOrder
        end
    end
    table.sort(list, function(a, b)
    	local bA = g_MarrySkillCtrl:IsMarryMagic(a)
    	local bB = g_MarrySkillCtrl:IsMarryMagic(b)
    	if bA ~= bB then
    		return bB
    	elseif bA then
    		return a < b
    	end
        return (sortDict[a] or 0) < (sortDict[b] or 0)
    end)

	return list
end

function CWarCtrl.GetHeroSpecialSkillList(self)
	local list = {}
	local oWarrior = self:GetWarrior(self.m_HeroWid)
	if oWarrior and oWarrior.m_MagicList then
		list = oWarrior:GetSpecialSkillList()--table.copy(oWarrior.m_SpecialSkill)
	end
	-- list = table.extend(list, {1, 2})
	table.sort(list)
	return list
end

function CWarCtrl.GetSummonMagicList(self)
	local list = {}
	local oWarrior = self:GetWarrior(self.m_SummonWid)
	if oWarrior and oWarrior.m_MagicList then
		list = oWarrior:GetSummonMagicList()--table.copy(oWarrior.m_MagicList)
	end
	-- list = table.extend(list, {1, 2})
	table.sort(list)
	return list
end

function CWarCtrl.GetSummonQuickSkill(self)
	local summon = self:GetSummon()
	if summon and summon.m_SummonID then
		return self.m_QuickMagicIDSummon[summon.m_SummonID]
	end
end

function CWarCtrl.GetHeroCdData(self)
	local oWarrior = self:GetWarrior(self.m_HeroWid)
	if oWarrior then
		return oWarrior.m_PfCd
	end
end

function CWarCtrl.GetSummonCdData(self)
	local oWarrior = self:GetWarrior(self.m_SummonWid)
	if oWarrior then
		return oWarrior.m_PfCd
	end
end

function CWarCtrl.SetFightSummons(self, fightlist)
	self.m_FightSummonIDList = fightlist
end

function CWarCtrl.IsSummonFighted(self, summonid)
	return table.index(self.m_FightSummonIDList, summonid) ~= nil
end

function CWarCtrl.FightSummonChange(self)
	if self:IsWar() then
		self:UpdateSummonState()
	end
end

function CWarCtrl.RefreshAllTeamCommand(self, op, lcmd)
	if op == 1 then
		for i,dCmd in ipairs(lcmd) do
			local oPlayer = self:GetWarrior(dCmd.select_wid)
			if oPlayer then
				oPlayer:SetTeamCmd(dCmd.cmd)
			end
		end
	else
		for i, oWarrior in pairs(self:GetWarriors()) do
			if oWarrior:HasTeamCmd() then
				oWarrior:SetTeamCmd(nil)
			end
		end
	end
end

--是否逃跑中
function CWarCtrl.SetIsEscape(self, bEscape)
	self.m_IsEscape = bEscape
end

function CWarCtrl.GetIsEscape(self)
	return self.m_IsEscape
end

function CWarCtrl.IsShowMaskView(self)
	printc("IsShowMaskView",  self.m_IsShowMaskView)
	return self.m_IsShowMaskView
end

function CWarCtrl.SetShowMaskView(self, b)
	self.m_IsShowMaskView = b
end

function CWarCtrl.HasChatMsg(self)
	return self.m_ChatMsgCnt > 0
end

function CWarCtrl.OnShowChatMsg(self)
	self.m_ChatMsgCnt = self.m_ChatMsgCnt + 1
	local oFloatView = CWarFloatView:GetView()
	if oFloatView and not oFloatView.m_ShowOrderTip then
		oFloatView.m_OrderTipBox:SetActive(false)
	end
end

function CWarCtrl.EndChatMsg(self)
	self.m_ChatMsgCnt = math.max(self.m_ChatMsgCnt - 1, 0)
	if self.m_ChatMsgCnt > 0 then return end
	if g_WarOrderCtrl.m_IsCanOrder then
		local oFloatView = CWarFloatView:GetView()
		if oFloatView and not oFloatView.m_ShowOrderTip	then
			oFloatView:ShowTipBeforeOrder()
		end
	end
end

return CWarCtrl
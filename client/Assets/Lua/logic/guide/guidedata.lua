module(..., package.seeall)

--由顺序决定优先级
Guide_Type = {"DrawCard", "War1", "War2", }
Trigger_Check_NotPlay = {	
	war = {"War3"},
	task = {"Task1", "MysticalBox", "ShimenNew", "TouXian", "PreOpen", "GetPartner"}, -- "Task2" "Task1Dialogue" "Shimen",
	view = {"SummonGet" , "EquipGetNew", "Ride", "RideTwo"},
	grade = {"JjcHasPlay", "XiuLianHasPlay", "equipxlHasPlay", "Zhiyin", "Skill", "Improve", "ImproveActiveSkill", "Org", "OrgExist",
	 "Schedule", "EightLogin", "equipqh", "ItemBagView", "SummonXilian", "SummonSkill", "SummonCompose", "PartnerImprove", "ForgeQh", 
	 "ForgeXl", "OrgSkill", "StoryChapter", "Artifact", "PlotSkill", "WingReward", "WingActive"
	}, 
	--"PartnerLevelUp", "PartnerUpgradeHasPlay",
	--"Jjc", "equipxl" "XiuLian" "PartnerUpgrade" "TaskFindItem1", "TaskFindItem2" "UseItem" "SummonGet2" --"SummonCompose"
	--备注：在其他地方有固定写的引导："PreOpen" "Task1" "Task2" "EquipGetNew" "UseItem10-40" "EquipGet10-40" "UseItem" "PartnerUpgrade" "SummonCompose"
	--"UpgradePack40", "UseItem40", "EquipGet40" "Welfare" , "UpgradePack20", "UseItem20", "EquipGet20", "UpgradePack30", "UseItem30", "EquipGet30" "UpgradePack", "UseItem10", "EquipGet10"
	--"OrgChat",
}
Trigger_Check_HasPlay = {	
	war = {"War3"},
	task = {"Task1", "MysticalBox", "ShimenNew", "TouXian", "PreOpen", "GetPartner"}, --"Task1Dialogue" "Shimen",
	view = {"SummonGet", "EquipGetNew", "Ride", "RideTwo"},
	grade = {"Zhiyin", "Skill", "ImproveHasPlay", "ImproveActiveSkill", "Org", "OrgExist", "Schedule", 
	"EightLogin", "equipqhHasPlay", "XiuLianHasPlay", "JjcHasPlay", "equipxlHasPlay", "ItemBagView", "SummonXilian", "SummonSkill", "SummonCompose",
	"PartnerImprove", "ForgeQh", "ForgeXl", "OrgSkill", "StoryChapter", "Artifact", "PlotSkill", "WingReward", "WingActive"
	}, 
	--"PartnerLevelUp", "PartnerUpgradeHasPlay",
	--"TaskFindItem1", "TaskFindItem2" "UseItem" "UpgradePackHasPlay" "SummonGet2HasPlay" "GetPartnerHasPlay" "SummonCompose"
	--"UpgradePack40", "UseItem40", "EquipGet40" "UpgradePack", "UseItem10", "EquipGet10", "UpgradePack20", "UseItem20", "EquipGet20", "UpgradePack30", "UseItem30", "EquipGet30"
	--"SkillHasPlay" "OrgChat",
}

TaskNotifyEvent = {
	"War3", "Task1", "TouXian", "SummonGet", "EquipGetNew", "Skill", "Improve", "GetPartner",
	"Org", "OrgExist", "PreOpen", "EightLogin", "equipqh", --"ImproveActiveSkill" "OrgChat", "Task1Dialogue"
}

FuncMap = {
	test = function()
		return true 
	end,
	default_pos = function ()
		return Vector2.New(0.5, 0.5)
	end,
	pata_open = function()
		return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.pata.open_grade
	end,

	war_necessary3 = function()
		return g_WarCtrl:IsWar() and (g_WarCtrl:GetWarType() == g_GuideCtrl.m_WarType) --define.War.Type.Guide1
	end,
	war_necessary4 = function()
		return g_WarCtrl:IsWar() and (g_WarCtrl:GetWarType() == "Guide2") --define.War.Type.Guide2
	end,
	war3_start_condition = function ()
		return g_WarCtrl.m_IsFirstSpecityWar and g_WarCtrl.m_FirstSpecityWarStep == 2 and g_WarCtrl:GetBout() == 1
	end,
	war3_start_auto = function ()
		return g_WarCtrl.m_IsFirstSpecityWar and g_WarCtrl.m_FirstSpecityWarStep == 3 and g_WarCtrl:GetBout() == 2
	end,
	war3_continue_condition1 = function()
		return g_WarCtrl.m_IsFirstSpecityWar and g_WarCtrl.m_FirstSpecityWarStep == 3 and g_WarCtrl:GetBout() == 1
	end,
	war3_continue_condition2 = function()
		return  g_WarCtrl.m_IsFirstSpecityWar and g_WarCtrl.m_FirstSpecityWarStep == 4 and g_WarCtrl:GetBout() == 2
	end,

	war3_skill = function()
		if g_WarCtrl:IsWar() then
			return true
		end
	end,

	--必要条件
	task1_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("Task1")
	end,
	task1_dialogue_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("Task1") and CDialogueMainView:GetView() ~= nil
	end,
	task2_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("Task2")
	end,
	touxian_open = function ()
		--return g_GuideHelpCtrl:CheckNecessaryCondition("TouXian") and g_OpenSysCtrl:GetOpenSysState(define.System.Badge)
		return g_OpenSysCtrl:GetOpenSysState(define.System.Badge) and g_TaskCtrl.m_OnlineDeleteTaskState[30016]
	end,
	skill_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.SkillBD)
	end,
	summonget_open = function ()
		return g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("sumselect") and g_OpenSysCtrl:GetOpenSysState(define.System.Summon)
	end,
	summonget2_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("SummonGet2") and g_SummonCtrl:GetIsSummonExistByTypeId(g_GuideHelpCtrl:GetSummon2()) and g_OpenSysCtrl:GetOpenSysState(define.System.Summon)
	end,
	summoncompose_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("SummonCompose") and g_OpenSysCtrl:GetOpenSysState(define.System.Summon) and g_OpenSysCtrl:GetOpenSysState(define.System.SummonHc) and g_SummonCtrl:GetIsNeedSummonComposeGuide()
	end,
	zhiyin_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("Zhiyin")
	end,
	welfare_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("Welfare")
	end,
	taskfinditem1_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("TaskFindItem1") and CNpcGroceryShopView:GetView() ~= nil
	end,
	taskfinditem2_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("TaskFindItem2") and CNpcGroceryShopView:GetView() ~= nil
	end,
	useitem_open = function ()
		local oView = CItemQuickUseView:GetView()
		return g_GuideHelpCtrl:CheckNecessaryCondition("UseItem") and oView ~= nil and oView.m_Item and oView.m_Item:GetSValueByKey("sid") == g_GuideHelpCtrl:GetItem1SelectItemSid()
	end,
	upgradepack_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("UpgradePack") and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(10)
	end,
	upgradepack20_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("UpgradePack") and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(20) and not g_GuideHelpCtrl.m_IsOnlineClickGradeGift[10]
	end,
	upgradepack30_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("UpgradePack") and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(30) and not g_GuideHelpCtrl.m_IsOnlineClickGradeGift[20] and not g_GuideHelpCtrl.m_IsOnlineClickGradeGift[10]
	end,
	upgradepack40_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("UpgradePack") and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(40) and not g_GuideHelpCtrl.m_IsOnlineClickGradeGift[30] and not g_GuideHelpCtrl.m_IsOnlineClickGradeGift[20] and not g_GuideHelpCtrl.m_IsOnlineClickGradeGift[10]
	end,
	after_upgradepack_guide = function ()
		CWelfareView:CloseView()
	end,
	useitem10_open = function ()
		local oView = CItemQuickUseView:GetView()
		local oCondition = g_GuideHelpCtrl:CheckNecessaryCondition("UseItem10") 
		-- and oView ~= nil and oView.m_Item and oView.m_Item:GetSValueByKey("sid") == g_GuideHelpCtrl:GetItem10SelectItemSid()
		and g_GuideHelpCtrl.m_IsOnlineRewareGradeGift[10]
		if oCondition then
			g_GuideHelpCtrl.m_GuideEquipList = {}
			g_GuideHelpCtrl.m_GuideEquipHashList = {}
		end
		return oCondition
	end,
	useitem20_open = function ()
		local oView = CItemQuickUseView:GetView()
		local oCondition = g_GuideHelpCtrl:CheckNecessaryCondition("UseItem20") 
		-- and oView ~= nil and oView.m_Item and oView.m_Item:GetSValueByKey("sid") == g_GuideHelpCtrl:GetItem20SelectItemSid()
		and g_GuideHelpCtrl.m_IsOnlineRewareGradeGift[20]
		if oCondition then
			g_GuideHelpCtrl.m_GuideEquipList = {}
			g_GuideHelpCtrl.m_GuideEquipHashList = {}
		end
		return oCondition
	end,
	useitem30_open = function ()
		local oView = CItemQuickUseView:GetView()
		local oCondition = g_GuideHelpCtrl:CheckNecessaryCondition("UseItem30") 
		-- and oView ~= nil and oView.m_Item and oView.m_Item:GetSValueByKey("sid") == g_GuideHelpCtrl:GetItem30SelectItemSid()
		and g_GuideHelpCtrl.m_IsOnlineRewareGradeGift[30]
		if oCondition then
			g_GuideHelpCtrl.m_GuideEquipList = {}
			g_GuideHelpCtrl.m_GuideEquipHashList = {}
		end
		return oCondition
	end,
	useitem40_open = function ()
		local oView = CItemQuickUseView:GetView()
		local oCondition = g_GuideHelpCtrl:CheckNecessaryCondition("UseItem40") 
		-- and oView ~= nil and oView.m_Item and oView.m_Item:GetSValueByKey("sid") == g_GuideHelpCtrl:GetItem40SelectItemSid()
		and g_GuideHelpCtrl.m_IsOnlineRewareGradeGift[40]
		if oCondition then
			g_GuideHelpCtrl.m_GuideEquipList = {}
			g_GuideHelpCtrl.m_GuideEquipHashList = {}
		end
		return oCondition
	end,
	equipgetnew_open = function ()
		local oView = CItemQuickUseView:GetView()
		return g_GuideHelpCtrl:CheckNecessaryCondition("EquipGetNew") 
		and oView ~= nil and oView.m_Item and table.index(g_GuideHelpCtrl:GetEquipNewQuickUseList(), oView.m_Item:GetSValueByKey("sid"))
	end,
	equipget10_open = function ()
		--这个view的判断不能去掉
		local oView = CItemQuickUseView:GetView()
		return g_GuideHelpCtrl:CheckNecessaryCondition("EquipGet10") and g_GuideCtrl.m_Flags["UseItem10"] 
		-- and oView ~= nil and oView.m_Item and table.index(g_GuideHelpCtrl:GetEquip10QuickUseList(), oView.m_Item:GetSValueByKey("sid")) 
		and g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem10SelectItemSid()]
		and not g_GuideCtrl.m_Flags["EquipGet20"] and not g_GuideCtrl.m_Flags["EquipGet30"] and not g_GuideCtrl.m_Flags["EquipGet40"]
	end,
	equipget20_open = function ()
		local oView = CItemQuickUseView:GetView()
		return g_GuideHelpCtrl:CheckNecessaryCondition("EquipGet20") and g_GuideCtrl.m_Flags["UseItem20"] 
		-- and oView ~= nil and oView.m_Item and table.index(g_GuideHelpCtrl:GetEquip20QuickUseList(), oView.m_Item:GetSValueByKey("sid")) 
		and g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem20SelectItemSid()]
		and not g_GuideCtrl.m_Flags["EquipGet30"] and not g_GuideCtrl.m_Flags["EquipGet40"]
	end,
	equipget30_open = function ()
		local oView = CItemQuickUseView:GetView()
		return g_GuideHelpCtrl:CheckNecessaryCondition("EquipGet30") and g_GuideCtrl.m_Flags["UseItem30"] 
		-- and oView ~= nil and oView.m_Item and table.index(g_GuideHelpCtrl:GetEquip30QuickUseList(), oView.m_Item:GetSValueByKey("sid")) 
		and g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem30SelectItemSid()]
		and not g_GuideCtrl.m_Flags["EquipGet40"]
	end,
	equipget40_open = function ()
		local oView = CItemQuickUseView:GetView()
		return g_GuideHelpCtrl:CheckNecessaryCondition("EquipGet40") and g_GuideCtrl.m_Flags["UseItem40"] 
		-- and oView ~= nil and oView.m_Item and table.index(g_GuideHelpCtrl:GetEquip40QuickUseList(), oView.m_Item:GetSValueByKey("sid")) 
		and g_GuideHelpCtrl.m_IsOnlineUseUpgradePack[g_GuideHelpCtrl:GetItem40SelectItemSid()]
	end,
	improve_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("Improve") and g_SkillCtrl:GetIsPassiveSkillCouldUp() and g_OpenSysCtrl:GetOpenSysState(define.System.Skill) and not g_GuideHelpCtrl.m_IsOnlineClickGradeGift[10]
	end,
	after_improve_guide = function ()
		CSkillMainView:CloseView()
	end,
	improveactiveskill_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.Improve) and g_SkillCtrl:GetIsActiveSkillCouldUp() and g_OpenSysCtrl:GetOpenSysState(define.System.SkillZD)
	end,
	org_open = function ()
		return not g_GuideCtrl.m_Flags["OrgExist"] and g_GuideHelpCtrl:CheckNecessaryCondition("Org") and not (g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0) and g_GuideHelpCtrl.m_IsAskOrgCountInit and g_GuideHelpCtrl.m_OrgCount <= 0
	end,
	orgexist_open = function ()
		return not g_GuideCtrl.m_Flags["Org"] and g_GuideHelpCtrl:CheckNecessaryCondition("Org") and not (g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0) and g_GuideHelpCtrl.m_IsAskOrgCountInit and g_GuideHelpCtrl.m_OrgCount > 0
	end,
	after_OrgExist_guide = function ()
		local oMainView = CMainMenuView:GetView()
		if oMainView then
			oMainView.m_RB.m_HBtnFirstGrid:Reposition()
		end
	end,
	org_apply_start_condition = function ()
		local oView = COrgJoinOrRespondView:GetView()
		return next(g_OrgCtrl.m_OrgList)
	end,
	org_apply_continue_condition = function ()
		local oView = COrgJoinOrRespondView:GetView()
		return oView and oView.m_EmptyContainer:GetActive() == true
	end,
	orgchat_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("Org") and (g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0)
	end,
	preopen_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.PreOpen) and g_OpenSysCtrl:GetOpenSysState(define.System.Partner) and g_GuideHelpCtrl:GetIsPreOpenGuideFit() --g_GuideHelpCtrl:CheckNecessaryCondition("PreOpen")
	end,
	after_PreOpen_guide = function ()
		CFuncNotifyMainView:CloseView()
	end,
	eightlogin_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.YoukaLogin) and (g_WelfareCtrl:GetIsEightLoginCouldGet(1) or g_GuideHelpCtrl.m_IsEightLoginGetClick)
	end,
	after_EightLogin_guide = function ()
		local oView = CWelfareView:GetView()
		if oView then
			oView.m_EightLoginPart.m_EightGrid:Clear()
			oView.m_EightLoginPart:RefreshUI()
		end
	end,
	MysticalBox_open = function ()
		return g_MysticalBoxCtrl:CheckIsMysticalBoxGuideOpen()
	end,
	getpartner_open = function ()
		return ( g_GuideHelpCtrl:CheckNecessaryCondition("GetPartner") and not g_PartnerCtrl:GetRecruitPartnerDataByID(g_GuideHelpCtrl:GetPartner1()) or g_GuideHelpCtrl.m_IsGetPartnerClick ) and g_OpenSysCtrl:GetOpenSysState(define.System.Partner)
	end,
	after_getpartner_guide = function ()
		CPartnerMainView:CloseView()
	end,
	partnerlevelup_open = function ()
		return g_PartnerCtrl:GetRecruitPartnerDataByID(g_GuideHelpCtrl:GetPartner1()) and g_GuideCtrl.m_Flags["GetPartner"] and CPartnerMainView:GetView() ~= nil
	end,
	partnerupgrade_open = function ()
		return g_GuideHelpCtrl:CheckPartner2UpgradeCondition() and g_GuideCtrl.m_Flags["EquipGet30"]
	end,
	after_partnerupgrade_guide = function ()
		CPartnerMainView:CloseView()
	end,
	schedule_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("Schedule")
	end,
	equipqh_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("equipqh") and next(g_ItemCtrl:GetEquipedList())
	end,
	jjc_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("Jjc")
	end,
	xiulian_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("XiuLian") and g_OpenSysCtrl:GetOpenSysState(define.System.Skill)
	end,
	ride_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.PreOpen) and g_OpenSysCtrl:GetOpenSysState(define.System.Horse) and g_GuideHelpCtrl:GetIsRideGuideFit() --g_GuideHelpCtrl:CheckNecessaryCondition("Ride") g_GuideHelpCtrl.m_IsOnlineShowLeadRideGet
	end,
	before_Ride_guide = function ()
		g_GuideHelpCtrl:ShowNotify(define.GuideNotify.Type.Ride)
	end,
	after_Ride_guide = function ()
		CFuncNotifyMainView:CloseView()
	end,
	RideTwo_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.Horse) and g_GuideHelpCtrl.m_IsRidePrizeGet --g_GuideHelpCtrl.m_IsOnlineShowLeadRideGet
	end,
	equipxl_open = function ()
		local list = g_ItemCtrl:GetEquipList(g_AttrCtrl.school, g_AttrCtrl.sex, 
		40, nil, nil, g_AttrCtrl.race, g_AttrCtrl.roletype)
		return g_GuideHelpCtrl:CheckNecessaryCondition("equipxl") and next(list)
	end,
	shimen_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("Shimen") and next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.SHIMEN.ID])
	end,
	shimennew_open = function ()
		local shimenScheduleData = g_ScheduleCtrl:GetScheduleData(define.Task.AceSchedule.SHIMEN)
		local isShimenScheduleDone = shimenScheduleData and shimenScheduleData.maxtimes > 0 and shimenScheduleData.times >= shimenScheduleData.maxtimes
		return g_OpenSysCtrl:GetOpenSysState(define.System.Shimen) and next(g_TaskCtrl.m_TaskCategoryTypeDic[define.Task.TaskCategory.SHIMEN.ID]) and not isShimenScheduleDone
	end,
	summonget2hasplay_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("SummonGet2HasPlay") and g_SummonCtrl:GetIsSummonExistByTypeId(g_GuideHelpCtrl:GetSummon2()) and g_OpenSysCtrl:GetOpenSysState(define.System.Summon)
	end,
	skillhasplay_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("SkillHasPlay")
	end,
	upgradepackhasplay_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("UpgradePackHasPlay") and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(10)
	end,
	improvehasplay_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("ImproveHasPlay") and g_SkillCtrl:GetIsPassiveSkillCouldUp() and g_OpenSysCtrl:GetOpenSysState(define.System.Skill)
	end,
	getpartnerhasplay_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("GetPartnerHasPlay") and not g_PartnerCtrl:GetRecruitPartnerDataByID(g_GuideHelpCtrl:GetPartner1()) and g_OpenSysCtrl:GetOpenSysState(define.System.Partner)
	end,
	partnerupgradehasplay_open = function ()
		return g_GuideHelpCtrl:CheckPartner2UpgradeCondition()
	end,
	equipqhhasplay_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("equipqhHasPlay") and next(g_ItemCtrl:GetEquipedList())
	end,
	jjchasplay_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("JjcHasPlay")
	end,
	xiulianhasplay_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("XiuLianHasPlay") and g_OpenSysCtrl:GetOpenSysState(define.System.Skill)
	end,
	equipxlhasplay_open = function ()
		return g_GuideHelpCtrl:CheckNecessaryCondition("equipxlHasPlay")
	end,
	before_ItemBagView_guide = function ()
		CItemMainView:ShowView(function(oView)
			if g_ItemCtrl.m_ItemEffList and #g_ItemCtrl.m_ItemEffList > 0 then
				-- oView:ShowSubPageByIndex(oView:GetPageIndex("Bag"))
			elseif g_ItemCtrl.m_ShowRefineRedPoint then
				oView:ShowSubPageByIndex(oView:GetPageIndex("Refine"))
			end
		end)
	end,
	ItemBagView_open = function ()
		return g_ItemCtrl.m_IsHasOpenItemBagView
	end,
	SummonXilian_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.Summon) and g_OpenSysCtrl:GetOpenSysState(define.System.SummonXc) and next(g_SummonCtrl.m_SummonsDic) and g_TaskCtrl.m_OnlineDeleteTaskState[30026]
	end,
	SummonSkill_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.Summon) and g_OpenSysCtrl:GetOpenSysState(define.System.SummonJn) and next(g_SummonCtrl.m_SummonsDic) and g_TaskCtrl.m_OnlineDeleteTaskState[30019]
	end,
	SummonCompose_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.Summon) and g_OpenSysCtrl:GetOpenSysState(define.System.SummonHc) and next(g_SummonCtrl.m_SummonsDic) and g_TaskCtrl.m_OnlineDeleteTaskState[30028]
	end,
	PartnerImprove_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.Partner) and g_TaskCtrl.m_OnlineDeleteTaskState[30020]
	end,
	ForgeQh_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.EquipStrengthen) and g_TaskCtrl.m_OnlineDeleteTaskState[30010]
	end,
	ForgeXl_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.EquipWash) and g_TaskCtrl.m_OnlineDeleteTaskState[30022]
	end,
	OrgSkill_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.OrgSkill) and g_TaskCtrl.m_OnlineDeleteTaskState[30021]
	end,
	before_OrgSkill_guide = function ()
		g_SkillCtrl.m_LastTab = nil
	end,
	StoryChapter_open = function ()
		local oChapterData = g_TaskCtrl.m_ChapterDataList[1]
		if oChapterData then
			local config = g_TaskCtrl:GetChapterConfig()[oChapterData.chapter]
			local oHasReward = table.index(g_TaskCtrl.m_ChapterHasRewardPrizeList, oChapterData.chapter) ~= nil
			return table.count(oChapterData.pieces) >= config.proceeds and not oHasReward
		else
			return false
		end
	end,
	before_StoryChapter_guide = function ()
		local oView = CMainMenuView:GetView()
		if oView then
			oView.m_RT.m_ExpandBox:ShowTaskPart()
		end
	end,
	PlotSkill_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.Talisman) and g_TaskCtrl.m_OnlineDeleteTaskState[30023]
	end,
	before_PlotSkill_guide = function ()
		g_SkillCtrl.m_IsPlotSkillGuide = true
		g_SkillCtrl.m_LastTab = nil
	end,
	Artifact_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.Artifact) and g_TaskCtrl.m_OnlineDeleteTaskState[30024]
	end,
	wing_open = function ()
		return g_OpenSysCtrl:GetOpenSysState(define.System.PreOpen) and g_OpenSysCtrl:GetOpenSysState(define.System.Wing) and g_GuideHelpCtrl:GetIsWingGuideFit() --or g_WingCtrl:GetGuideFlag("wing_reward")
	end,
	wing_activatable = function ()
		return (g_GuideHelpCtrl:GetIsPreOpenHasRewarded(g_GuideHelpCtrl.m_WingGuideId) and g_WingCtrl:IsActivatable()) or g_WingCtrl:GetGuideFlag("wing_active")
	end,
	before_wingReward_guide = function ()
		local oComfirm = CWindowComfirmView:GetView()
		if oComfirm then
			oComfirm:SetActive(false)
		end
		g_WingCtrl:SetGuideFlag("wing_reward", true)
	end,
	after_wingReward_guide = function ()
		local oComfirm = CWindowComfirmView:GetView()
		if oComfirm then
			oComfirm:SetActive(true)
		end
		g_WingCtrl:SetGuideFlag("wing_reward", false)
		CFuncNotifyMainView:CloseView()
	end,
	before_wingActive_guide = function ()
		local oView = CGuideNotifyView:GetView()
		if oView then
			oView:SetActive(false)
		end
		local oComfirm = CWindowComfirmView:GetView()
		if oComfirm then
			oComfirm:SetActive(false)
		end
		g_WingCtrl:SetGuideFlag("wing_active", true)

		local oWingItem = g_ItemCtrl:GetBagItemListBySid(10159)[1]
		if oWingItem then
			g_ItemCtrl:ItemQuickUse(oWingItem:GetSValueByKey("id"))
		end
	end,
	after_wingActive_guide = function ()
		local oView = CGuideNotifyView:GetView()
		if oView then
			oView:SetActive(true)
		end
		local oComfirm = CWindowComfirmView:GetView()
		if oComfirm then
			oComfirm:SetActive(true)
		end
		g_WingCtrl:SetGuideFlag("wing_active", false)
	end,

	--战斗
	war_speed_show = function()
		if g_WarOrderCtrl:IsCanOrder() then
			local oView = CWarMainView:GetView()
			if oView then
				return oView.m_RT.m_WarSpeedBox:GetActive(true)
			end
		end
	end,
	war_skill = function()
		if g_WarCtrl:IsWar() then
			return true
		end
	end,
	war_seltarget = function()
		return g_WarOrderCtrl:IsInSelTarget()
	end,
	war_not_seltarget = function()
		return not g_WarOrderCtrl:IsInSelTarget()
	end,
	war_can_order = function()
		return g_WarOrderCtrl:IsCanOrder()
	end,
	before_war_guide = function()
		g_WarTouchCtrl:SetLock(true)
		netwar.C2GSWarStop(g_WarCtrl:GetWarID())
	end,
	after_war_guide = function()
		g_WarTouchCtrl:SetLock(false)
		netwar.C2GSWarStart(g_WarCtrl:GetWarID())
	end,
	war_necessary1 = function()
		return g_WarCtrl:IsWar() and (g_WarCtrl:GetWarType() == define.War.Type.Guide1)
	end,
	war_necessary2 = function()
		return g_WarCtrl:IsWar() and (g_WarCtrl:GetWarType() == define.War.Type.Guide2)
	end,
	war_pos_ally1 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 1)
		return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
	end,
	war_pos_enemy1 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(false, 1)
		local pos = WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
		pos.y = pos.y + 0.05
		return pos
	end,
	war_orderdone_ally1 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 1)
		return not g_WarOrderCtrl:IsWaitOrder(oWarrior.m_ID)
	end,
	war_orderdone_ally2 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 2)
		return not g_WarOrderCtrl:IsWaitOrder(oWarrior.m_ID)
	end,
	war_orderdone_ally5 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 5)
		return not g_WarOrderCtrl:IsWaitOrder(oWarrior.m_ID)
	end,

	war_pos_ally2 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 2)
		return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
	end,
	war_pos_ally5 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 5)
		return WarTools.WarToViewportPos(oWarrior.m_WaistTrans.position)
	end,
	war_order_ally2 = function()
		if g_WarOrderCtrl.m_CurOrderWid then
			local oWarrior = WarTools.GetWarriorByCampPos(true, 2)
			return oWarrior.m_ID == g_WarOrderCtrl.m_CurOrderWid
		end
	end,
	war_target_ally2 = function()
		local oWarrior = WarTools.GetWarriorByCampPos(true, 2)
		return oWarrior:IsOrderTarget()
	end,
	war_order_ally5 = function()
		if g_WarOrderCtrl.m_CurOrderWid then
			local oWarrior = WarTools.GetWarriorByCampPos(true, 5)
			return oWarrior.m_ID == g_WarOrderCtrl.m_CurOrderWid
		end
	end,
	war_lock_touch = function(bAlly, iPos)
		for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
			local bTouch = (oWarrior:IsAlly() == bAlly) and (oWarrior.m_CampPos == iPos)
			oWarrior:SetTouchEnabled(bTouch)
		end
	end,
	war_unlock_touch = function()
		for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
			oWarrior:SetTouchEnabled(true)
		end
	end,
}

Test = {
	{
		sub_key="test", 
		start_condition = "test1",
		-- continue_condition = "not g_WarOrderCtrl:IsInSelTarget()",
		click_continue = false,
		necessary_ui_list = {"click_ui_test", },
		guide_list={ 
			-- {effect_type="func", funcname="WarPrepareGuide"},
			-- {effect_type="click_ui", ui_key="click_ui_test", ui_effect = "Finger"},
			-- {effect_type="focus_common", x=0.3, y=0.6, w=0.3, h=0.3},
			-- {effect_type="focus_ui", w=300 ,h=148, ui_key="click_ui_test"},
			-- {effect_type="focus_pos", w=0.2,h=0.1, pos_func=war_pos1 ,ui_effect="Finger"}
			-- {effect_type="dlg", text_list= {"测试教学描述1", "测试教学描述2"}},
			-- {effect_type="texture", text="点这里", texture_name="guide_1.png", near_pos = {x=-1, y=0},
			-- 	ui_key="click_ui_test"}
		},
	}
}

War1={
	complete_type = 0,
	after_guide=[[after_war_guide]],
	before_guide=[[before_war_guide]],
	guide_list={
		[1]={
			click_continue=true,
			effect_list={
				[1]={
					fixed_pos={x=-0.32,y=-0.38,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
					effect_type=[[texture]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					fixed_pos={x=-0.2,y=-0.12,},
					play_tween=false,
					text_list={
						[1]=[[欢迎来到《月见异闻录》，
我是这次负责教导你的喵小萌。好激动~\(≧▽≦)/~本喵终于有教导人的一天了。]],
					},
					effect_type=[[dlg]],
				},
			},
			guide_key=[[war1_1]],
		},
		[2]={
			click_continue=true,
			effect_list={
				[1]={near_pos={x=-0.03, y=0,},effect_type=[[focus_ui]],ui_key=[[war_speed_box]],},
				[2]={
					fixed_pos={x=0.11,y=0.23,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_2.png]],
					effect_type=[[texture]],
					ui_key=[[war_speed_box]],
				},
				[3]={
					dlg_sprite=[[h7_zhiyinkuang]],
					fixed_pos={x=-0.15,y=0.23,},
					play_tween=false,
					text_list={
						[1]=[[ 这是行动条，
 会显示我方单位本回
 合的行动顺序。
 你在重华前面，你先
 行动~喵~]],
					},
					effect_type=[[dlg]],
					ui_key=[[war_speed_box]],
				},
			},
			guide_key=[[war1_2]],
			necessary_ui_list={[1]=[[war_speed_box]],},
			start_condition=[[war_speed_show]],
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={effect_type=[[focus_ui]],ui_key=[[war_skill_box1]],},
				[2]={
					fixed_pos={x=-0.03,y=-0.225,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
					effect_type=[[texture]],
					ui_key=[[war_skill_box1]],
				},
				[3]={
					dlg_sprite=[[pic_zhiying_ditu_2]],
					fixed_pos={x=0.075,y=-0.274,},
					play_tween=false,
					text_list={[1]=[[  点击选择要释放的技能。]],},
					effect_type=[[dlg]],
					ui_key=[[war_skill_box1]],
				},
				[4]={effect_type=[[click_ui]],ui_effect=[[Finger]],ui_key=[[war_skill_box1]],},
			},
			guide_key=[[war1_3]],
			necessary_ui_list={[1]=[[war_skill_box1]],},
			start_condition=[[war_skill]],
		},
		[4]={
			click_continue=false,
			continue_condition=[[war_orderdone_ally1]],
			effect_list={
				[1]={h=0.12,pos_func=[[war_pos_enemy1]],effect_type=[[focus_pos]],ui_effect=[[Finger]],w=0.07,},
				[2]={
					fixed_pos={x=-0.01,y=0.225,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
					effect_type=[[texture]],
					ui_key=[[guide_focus_spr]],
				},
				[3]={
					dlg_sprite=[[pic_zhiying_ditu_2]],
					fixed_pos={x=0.09,y=0.175,},
					play_tween=false,
					text_list={[1]=[[  选择技能释放的目标~喵~]],},
					effect_type=[[dlg]],
					ui_key=[[guide_focus_spr]],
				},
			},
			guide_key=[[war1_4]],
			start_condition=[[war_seltarget]],
		},
		[5]={
			click_continue=false,
			continue_condition=[[war_orderdone_ally5]],
			effect_list={
				[1]={h=0.1,pos_func=[[war_pos_enemy1]],effect_type=[[focus_pos]],ui_effect=[[Finger]],w=0.07,},
				[2]={
					fixed_pos={x=-0.36,y=0.06,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
					effect_type=[[texture]],
					ui_key=[[guide_focus_spr]],
				},
				[3]={
					dlg_sprite=[[pic_zhiying_ditu_2]],
					fixed_pos={x=-0.26,y=0,},
					play_tween=false,
					text_list={
						[1]=[[  到重华行动了。
  直接选择攻击对象，
  会发动默认技能攻击敌人
  ~喵~]],
					},
					effect_type=[[dlg]],
					ui_key=[[guide_focus_spr]],
				},
			},
			guide_key=[[war1_5]],
			start_condition=[[war_seltarget]],
		},
	},
	necessary_condition=[[war_necessary1]],
}



War2={
	after_guide=[[after_war_guide]],
	before_guide=[[before_war_guide]],
	complete_type=0,
	guide_list={
		[1]={
			click_continue=true,
			effect_list={
				[1]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.22,y=-0.12,},
					play_tween=false,
					text_list={
						[1]=[[空你七哇#G<name>#n。
战斗中可以只对部分单位进行操作，未操作的单位会使用默认技能进行战斗~喵~]],
					},
				},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.34,y=-0.38,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
			},
			guide_key=[[war2_1]],
			necessary_ui_list={},
		},
		[2]={
			after_process={args={},func_name=[[war_unlock_touch]],},
			before_process={args={[1]=true,[2]=2,},func_name=[[war_lock_touch]],},
			click_continue=false,
			continue_condition=[[war_order_ally2]],
			effect_list={
				[1]={
					effect_type=[[focus_pos]],
					h=0.1,
					pos_func=[[war_pos_ally2]],
					ui_effect=[[Finger]],
					w=0.07,
				},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.34,y=-0.38,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[3]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.22,y=-0.22,},
					play_tween=false,
					text_list={[1]=[[点击需要操作的单位~喵~]],},
				},
			},
			guide_key=[[war2_2]],
			necessary_ui_list={},
			start_condition=[[war_can_order]],
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={effect_type=[[focus_ui]],ui_key=[[war_skill_box2]],},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.34,y=-0.38,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[3]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.22,y=-0.189,},
					play_tween=false,
					text_list={
						[1]=[[绿狸这技能可以提升队伍的怒气\(≧▽≦)/。而且，重点是]],
					},
				},
				[4]={effect_type=[[click_ui]],ui_effect=[[Finger]],ui_key=[[war_skill_box2]],},
			},
			guide_key=[[war2_3]],
			necessary_ui_list={[1]=[[war_skill_box2]],},
			start_condition=[[war_skill]],
		},
		[4]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.16,y=0.23,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_2.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.1,y=0.185,},
					play_tween=false,
					text_list={
						[1]=[[绿狸会比重华先行动，
这样重华妹子就能够释
放怒气技能了~喵]],
					},
				},
				[3]={effect_type=[[focus_ui]],near_pos={x=-0.03,y=0,},ui_key=[[war_speed_box]],},
			},
			guide_key=[[war2_4]],
			necessary_ui_list={[1]=[[war_speed_box]],},
			start_condition=[[war_seltarget]],
		},
		[5]={
			after_process={args={},func_name=[[war_unlock_touch]],},
			before_process={args={[1]=true,[2]=2,},func_name=[[war_lock_touch]],},
			click_continue=false,
			continue_condition=[[war_orderdone_ally2]],
			effect_list={
				[1]={
					effect_type=[[focus_pos]],
					h=0.1,
					pos_func=[[war_pos_ally2]],
					ui_effect=[[Finger]],
					w=0.07,
				},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.195,y=0.07,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
				},
				[3]={
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.1,y=0.01,},
					play_tween=false,
					text_list={[1]=[[    不过，绿狸这个技能只能    对自己使用~哈哈~喵~]],},
				},
			},
			guide_key=[[war2_5]],
			necessary_ui_list={},
			start_condition=[[war_target_ally2]],
		},
		[6]={
			after_process={args={},func_name=[[war_unlock_touch]],},
			before_process={args={[1]=true,[2]=5,},func_name=[[war_lock_touch]],},
			click_continue=false,
			continue_condition=[[war_order_ally5]],
			effect_list={
				[1]={
					effect_type=[[focus_pos]],
					h=0.1,
					pos_func=[[war_pos_ally5]],
					ui_effect=[[Finger]],
					w=0.07,
				},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.195,y=0.141,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
				},
				[3]={
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.1,y=0.09,},
					play_tween=false,
					text_list={[1]=[[    接着操作重华。]],},
				},
			},
			guide_key=[[war2_6]],
			necessary_ui_list={},
			start_condition=[[war_can_order]],
		},
		[7]={
			click_continue=false,
			effect_list={
				[1]={effect_type=[[focus_ui]],ui_key=[[war_skill_box2]],},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.028,y=-0.225,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
				},
				[3]={
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=0.075,y=-0.28,},
					play_tween=false,
					text_list={
						[1]=[[   经本喵的计算，绿狸将怒
   气提升后，正好可以使用
   重华的“石破天惊”~喵~]],
					},
				},
				[4]={effect_type=[[click_ui]],ui_effect=[[Finger]],ui_key=[[war_skill_box2]],},
			},
			guide_key=[[war2_7]],
			necessary_ui_list={[1]=[[war_skill_box2]],},
			start_condition=[[war_skill]],
		},
		[8]={
			click_continue=false,
			continue_condition=[[war_orderdone_ally5]],
			effect_list={
				[1]={effect_type=[[focus_common]],h=0.25,w=0.3,x=0.3,y=0.6,},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.34,y=-0.09,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
				},
				[3]={
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.24,y=-0.14,},
					play_tween=false,
					text_list={[1]=[[   记得选择释放目标哦~喵]],},
				},
			},
			guide_key=[[war2_8]],
			necessary_ui_list={},
			start_condition=[[war_seltarget]],
		},
		[9]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.12,y=-0.38,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.24,y=-0.12,},
					play_tween=false,
					text_list={
						[1]=[[对了。点击“指令完成”按钮，未操作单位将直接使用上次的技能作为默认技能发动攻击。~喵~]],
					},
				},
				[3]={effect_type=[[click_ui]],ui_effect=[[Finger]],ui_key=[[war_order_all]],},
				[4]={effect_type=[[focus_ui]],ui_key=[[war_order_all]],},
			},
			guide_key=[[war2_9]],
			necessary_ui_list={[1]=[[war_order_all]],},
			start_condition=[[war_can_order]],
		},
		[10]={
			click_continue=true,
			effect_list={
				[1]={effect_type=[[focus_common]],h=1,w=1,x=0.5,y=0.5,},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.34,y=-0.38,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[3]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.19,y=-0.24,},
					play_tween=false,
					text_list={
						[1]=[[     根据实际战况，
     灵活地操作战斗单位，
     可以事半功倍哦~喵~]],
					},
				},
			},
			guide_key=[[war2_10]],
			necessary_ui_list={},
		},
	},
	necessary_condition=[[war_necessary2]],
}

DrawCard={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.31,y=-0.38,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.2,y=-0.12,},
					play_tween=false,
					text_list={
						[1]=[[喵~竟然来到这里，看来是感受到他们的呼唤了。
世间生灵各有其性，或喜，或怒。]],
						[2]=[[军统部为保证人类的安全，提供两种缔结契约的方式，让人、妖、鬼各族能相互建立牵绊，成为真正的伙伴。]],
					},
				},
			},
			guide_key=[[drawcard_1]],
			necessary_ui_list={},
		},
		[2]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.06,y=0.05,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.03,y=-0.01,},
					play_tween=false,
					text_list={
						[1]=[[    勇者契约通过消耗勇者契
    约卷，召唤出“N-R”的
    伙伴并进行缔结契约。]],
					},
				},
				[3]={effect_type=[[focus_ui]],ui_key=[[draw_wl_card]],},
			},
			guide_key=[[drawcard_2]],
			necessary_ui_list={[1]=[[draw_wl_card]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={effect_type=[[focus_ui]],ui_key=[[drawcard_wl_gain_btn]],},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.14,y=-0.173,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
				},
				[3]={
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.04,y=-0.222,},
					play_tween=false,
					text_list={[1]=[[   点击抽取。]],},
				},
				[4]={effect_type=[[click_ui]],ui_effect=[[Finger1]],ui_key=[[drawcard_wl_gain_btn]],},
			},
			guide_key=[[drawcard_3]],
			necessary_ui_list={[1]=[[drawcard_wl_gain_btn]],},
		},
		[4]={
			continue_condition=[[drawcard_main_show]],
			effect_list={
				[1]={effect_type=[[focus_common]],h=1,w=1,x=0.5,y=0.5,},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0.293,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
				},
				[3]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1,y=0.2465,},
					play_tween=false,
					text_list={[1]=[[   点击关闭界面。]],},
				},
				[4]={
					effect_type=[[click_ui]],
					near_pos={x=-0.01,y=0,},
					ui_effect=[[Finger1]],
					ui_key=[[close_wl_result]],
				},
			},
			guide_key=[[drawcard_41]],
			necessary_ui_list={[1]=[[close_wl_result]],},
			start_condition=[[drawcard_result_show]],
		},
		[5]={
			click_continue=true,
			effect_list={
				[1]={effect_type=[[focus_ui]],ui_key=[[draw_wh_card]],},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.21,y=0.03,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
				},
				[3]={
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.12,y=-0.025,},
					play_tween=false,
					text_list={
						[1]=[[    王者契约通过消耗王者契
    约卷，召唤出“N-R”的
    伙伴并进行缔结契约。]],
					},
				},
			},
			guide_key=[[drawcard_42]],
			necessary_ui_list={[1]=[[draw_wh_card]],},
		},
		[6]={
			click_continue=false,
			effect_list={
				[1]={effect_type=[[focus_ui]],ui_key=[[drawcard_wh_gain_btn]],},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.14,y=-0.173,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_3.png]],
				},
				[3]={
					dlg_sprite=[[pic_zhiying_ditu_2]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.04,y=-0.223,},
					play_tween=false,
					text_list={[1]=[[   点击抽取。]],},
				},
				[4]={effect_type=[[click_ui]],ui_effect=[[Finger1]],ui_key=[[drawcard_wh_gain_btn]],},
			},
			guide_key=[[drawcard_51]],
			necessary_ui_list={[1]=[[drawcard_wh_gain_btn]],},
		},
	},
	necessary_condition=[[drawcard_show]],
}

Open_Arena = {
	complete_type = 0,
	necessary_condition=[[arena_open]],
	guide_list = {
		[1] = {
			necessary_ui_list = {"mainmenu_operate_btn", },
			effect_list={ 
				{
					effect_type="open", 
					ui_key="mainmenu_operate_btn", 
					sprite_name = "btn_bwcrk2017",
					open_text='竞技场',
				}
			},
		}
	},
}

War3={
	complete_type=1,
	guide_list={
		[1]={
			click_continue=false,
			start_condition=[[war3_start_condition]],
			continue_condition=[[war3_continue_condition1]],
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.15,},
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.15,},
					play_tween=false,
					text_list={[1]=[[主人，我们是回合制游戏，每回合要进行攻击操作哦]],},
					audio_list={[1]=[[Model/xsydy10.mp3]],},
				},
				[3]={
					effect_type=[[circlebefore_click_ui]],
					offset_pos={x=0,y=40,},
					target_offset_pos={x=0,y=30,},
					offset_rotate=160,
					ui_effect=[[Finger]],
					ui_key=[[war_magic_btn]],
				},
			},
			necessary_ui_list={[1]=[[war_magic_btn]],},
		},
		[2]={
			click_continue=false,
			start_condition=[[war3_start_condition]],
			continue_condition=[[war3_continue_condition1]],
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.1,y=0.1,},
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=0.1,},
					play_tween=false,
					text_list={[1]=[[接下来选择技能，这是一个可以攻击多个目标的技能]],},
					audio_list={[1]=[[Model/xsydy11.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=12,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[war_magic_box1_btn]],
				},
			},
			necessary_ui_list={[1]=[[war_magic_box1_btn]],},
		},
		[3]={
			click_continue=false,
			continue_condition=[[war3_continue_condition1]],
			effect_list={
				[1]={
					effect_type=[[focus_pos]],
					pos_func=[[war_pos_enemy1]],
					ui_effect=[[Finger]],
					pixel={x=0.07,y=0.17,},
					offset_pos={x=0,y=0,},
					offset_rotate=0,
				},
				[2]={
					effect_type=[[texture]],
					fixed_pos={x=-0.3,y=0,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
					-- ui_key=[[guide_focus_spr]],
				},
				[3]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.3+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[还需要选择攻击的目标才能发动攻击哦]],},
					audio_list={[1]=[[Model/xsydy12.mp3]],},
					-- ui_key=[[guide_focus_spr]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
				},
			},
			-- necessary_ui_list={[1]=[[guide_focus_spr]],},
			start_condition=[[war3_start_condition]],
		},
		[4]={
			click_continue=false,
			start_condition=[[war3_start_auto]],
			continue_condition=[[war3_continue_condition2]],
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.15,y=-0.25,},
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.15+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[自动战斗，轻松愉快~]],},
					audio_list={[1]=[[Model/xsydy13.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[war_auto_btn]],
				},
			},
			necessary_ui_list={[1]=[[war_auto_btn]],},
		},
	},
	necessary_condition=[[war_necessary3]],
}

Task1={
	complete_type=0,
	guide_list={
		-- [1]={
		-- 	click_continue=true,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=-0.15,y=0,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=-0.15+0.12,y=0,},
		-- 			play_tween=false,
		-- 			text_list={
		-- 				[1]=[[欢迎来到大话许仙，接下来我会帮助您熟悉游戏世界。]],
		-- 			},
		-- 			audio_list={[1]=[[Model/xsydy1.mp3]],},
		-- 		},
		-- 	},
		-- 	necessary_ui_list={},
		-- },
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.14,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.14,y=0,},
					play_tween=false,
					text_list={[1]=[[掌门急召，一定是有重要的事情，快去吧！]],},
					audio_list={[1]=[[Model/xsydy2.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[task_btn_story]],
				},
			},
			necessary_ui_list={[1]=[[task_btn_story]],},
		},
	},
	necessary_condition=[[task1_open]],
}

Task1Dialogue={
	complete_type=0,
	exceptview = {"CDialogueMainView"},
	guide_list={		
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.15,y=-0.15,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.15+0.12,y=-0.15,},
					play_tween=false,
					text_list={[1]=[[点击对话界面]],},
					audio_list={[1]=[[Model/xsydy3.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=-293,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[dialogue_nextmsg_btn]],
				},
			},
			necessary_ui_list={[1]=[[dialogue_nextmsg_btn]],},
		},
	},
	necessary_condition=[[task1_dialogue_open]],
}

Task2={
	complete_type=0,
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[迷茫时就点这里哦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[task_btn_10001]],
				},
			},
			necessary_ui_list={[1]=[[task_btn_10001]],},
		},
	},
	necessary_condition=[[task2_open]],
}

Task10100={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			pass=true,
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[notify_ui]],
					ui_effect=[[FingerInterval]],
					ui_key=[[task_btn_10002]],
				},
			},
			necessary_ui_list={[1]=[[task_btn_10002]],},
		},
	},
	necessary_condition=[[task10100_open]],
}

Task10101={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			pass=true,
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[notify_ui]],
					ui_effect=[[FingerInterval]],
					ui_key=[[task_btn_10001]],
				},
			},
			necessary_ui_list={[1]=[[task_btn_10001]],},
		},
	},
	necessary_condition=[[task10101_open]],
}

Task10102={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			pass=true,
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[notify_ui]],
					ui_effect=[[FingerInterval]],
					ui_key=[[task_btn_10004]],
				},
			},
			necessary_ui_list={[1]=[[task_btn_10004]],},
		},
	},
	necessary_condition=[[task10102_open]],
}

Task10103={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			pass=true,
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[notify_ui]],
					ui_effect=[[FingerInterval]],
					ui_key=[[task_btn_10005]],
				},
			},
			necessary_ui_list={[1]=[[task_btn_10005]],},
		},
	},
	necessary_condition=[[task10103_open]],
}

EquipGetNew={
	complete_type=0,
	exceptview = {"CItemQuickUseView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[你获得了更强的装备，快穿上吧。]],},
					audio_list={[1]=[[Model/xsydy4.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[item_quickuse_btn]],
				},
			},
			necessary_ui_list={[1]=[[item_quickuse_btn]],},
		},
	},
	necessary_condition=[[equipgetnew_open]],
}

EquipGet10={
	complete_type=0,
	exceptview = {"CItemQuickUseView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[你获得了更强的装备，快穿上吧。]],},
					audio_list={[1]=[[Model/xsydy4.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[item_quickuse_btn]],
				},
			},
			necessary_ui_list={[1]=[[item_quickuse_btn]],},
		},
	},
	necessary_condition=[[equipget10_open]],
}

EquipGet20={
	complete_type=0,
	exceptview = {"CItemQuickUseView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[你获得了更强的装备，快穿上吧。]],},
					audio_list={[1]=[[Model/xsydy4.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[item_quickuse_btn]],
				},
			},
			necessary_ui_list={[1]=[[item_quickuse_btn]],},
		},
	},
	necessary_condition=[[equipget20_open]],
}

EquipGet30={
	complete_type=0,
	exceptview = {"CItemQuickUseView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[你获得了更强的装备，快穿上吧。]],},
					audio_list={[1]=[[Model/xsydy4.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[item_quickuse_btn]],
				},
			},
			necessary_ui_list={[1]=[[item_quickuse_btn]],},
		},
	},
	necessary_condition=[[equipget30_open]],
}

EquipGet40={
	complete_type=0,
	exceptview = {"CItemQuickUseView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[你获得了更强的装备，快穿上吧。]],},
					audio_list={[1]=[[Model/xsydy4.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[item_quickuse_btn]],
				},
			},
			necessary_ui_list={[1]=[[item_quickuse_btn]],},
		},
	},
	necessary_condition=[[equipget40_open]],
}

SummonGet={
	complete_type=0,
	exceptview = {}, --"CSummonMainView"
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[你的宠物在这里哦~]],},
					audio_list={[1]=[[Model/xsydy8.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=-35,y=-35,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_open_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_open_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=-0.125,},
					play_tween=false,
					text_list={[1]=[[宠物可以在战斗中帮助你，点击参战吧。]],},
					audio_list={[1]=[[Model/xsydy9.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[pet_fight_btn]],
				},
			},
			necessary_ui_list={[1]=[[pet_fight_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[关闭界面吧]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_close_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_close_btn]],},
		},
	},
	necessary_condition=[[summonget_open]],
}

SummonGet2={
	complete_type=0,
	exceptview = {}, --"CSummonMainView"
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[你的宠物在这里哦]],},
					audio_list={[1]=[[Model/xsydy8.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=-125,y=-35,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_open_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_open_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.3,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.3+0.12,y=-0.125,},
					play_tween=false,
					text_list={[1]=[[点击这里哦]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=45,y=-40,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[summon_1002_box_btn]],
				},
			},
			necessary_ui_list={[1]=[[summon_1002_box_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.125,},
					play_tween=false,
					text_list={[1]=[[宠物可以在战斗中帮助你，点击参战吧。]],},
					audio_list={[1]=[[Model/xsydy9.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[pet_fight_btn]],
				},
			},
			necessary_ui_list={[1]=[[pet_fight_btn]],},
		},
		[4]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[关闭界面吧]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_close_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_close_btn]],},
		},
	},
	necessary_condition=[[summonget2_open]],
}

-- SummonCompose={
-- 	complete_type=0,
-- 	exceptview = {}, --"CSummonMainView", "CSummonCompoundSelView"
-- 	guide_list={
-- 		[1]={
-- 			click_continue=false,
-- 			effect_list={
-- 				[1]={
-- 					effect_type=[[texture]],
-- 					fixed_pos={x=0.125,y=0.25,},
-- 					flip_y=false,
-- 					play_tween=false,
-- 					texture_name=[[guide_1.png]],
-- 				},
-- 				[2]={
-- 					dlg_sprite=[[h7_zhiyinkuang]],
-- 					effect_type=[[dlg]],
-- 					fixed_pos={x=0.125+0.12,y=0.25,},
-- 					play_tween=false,
-- 					text_list={[1]=[[你可以合成新宠物了哦]],},
-- 				},
-- 				[3]={
-- 					effect_type=[[click_ui]],
-- 					offset_pos={x=-125,y=-35,},
-- 					offset_rotate=0,
-- 					ui_effect=[[Finger]],
-- 					ui_key=[[petview_open_btn]],
-- 				},
-- 			},
-- 			necessary_ui_list={[1]=[[petview_open_btn]],},
-- 		},
-- 		[2]={
-- 			click_continue=false,
-- 			effect_list={
-- 				[1]={
-- 					effect_type=[[texture]],
-- 					fixed_pos={x=0.125,y=-0.125,},
-- 					flip_y=false,
-- 					play_tween=false,
-- 					texture_name=[[guide_1.png]],
-- 				},
-- 				[2]={
-- 					dlg_sprite=[[h7_zhiyinkuang]],
-- 					effect_type=[[dlg]],
-- 					fixed_pos={x=0.1+0.12,y=-0.125,},
-- 					play_tween=false,
-- 					text_list={[1]=[[请点击炼妖标签]],},
-- 					audio_list={[1]=[[Model/xsydy19.mp3]],},
-- 				},
-- 				[3]={
-- 					effect_type=[[click_ui]],
-- 					offset_pos={x=0,y=0,},
-- 					offset_rotate=0,
-- 					ui_effect=[[Finger]],
-- 					ui_key=[[petview_adjust_btn]],
-- 				},
-- 			},
-- 			necessary_ui_list={[1]=[[petview_adjust_btn]],},
-- 		},
-- 		[3]={
-- 			click_continue=false,
-- 			effect_list={
-- 				[1]={
-- 					effect_type=[[texture]],
-- 					fixed_pos={x=-0.125,y=0,},
-- 					flip_y=false,
-- 					play_tween=false,
-- 					texture_name=[[guide_1.png]],
-- 				},
-- 				[2]={
-- 					dlg_sprite=[[h7_zhiyinkuang]],
-- 					effect_type=[[dlg]],
-- 					fixed_pos={x=-0.125+0.12,y=0,},
-- 					play_tween=false,
-- 					text_list={[1]=[[点击合成标签]],},
-- 					audio_list={[1]=[[Model/xsydy19.mp3]],},
-- 				},
-- 				[3]={
-- 					effect_type=[[click_ui]],
-- 					offset_pos={x=0,y=0,},
-- 					offset_rotate=0,
-- 					ui_effect=[[Finger]],
-- 					ui_key=[[petview_compound_btn]],
-- 				},
-- 			},
-- 			necessary_ui_list={[1]=[[petview_compound_btn]],},
-- 		},
-- 		[4]={
-- 			click_continue=false,
-- 			effect_list={
-- 				[1]={
-- 					effect_type=[[texture]],
-- 					fixed_pos={x=-0.3,y=-0.125,},
-- 					flip_y=false,
-- 					play_tween=false,
-- 					texture_name=[[guide_1.png]],
-- 				},
-- 				[2]={
-- 					dlg_sprite=[[h7_zhiyinkuang]],
-- 					effect_type=[[dlg]],
-- 					fixed_pos={x=-0.3+0.12,y=-0.125,},
-- 					play_tween=false,
-- 					text_list={[1]=[[选这里]],},
-- 					audio_list={[1]=[[Model/xsydy19.mp3]],},
-- 				},
-- 				[3]={
-- 					effect_type=[[click_ui]],
-- 					offset_pos={x=0,y=0,},
-- 					offset_rotate=0,
-- 					ui_effect=[[Finger]],
-- 					ui_key=[[petview_compoundselectleft_btn]],
-- 				},
-- 			},
-- 			necessary_ui_list={[1]=[[petview_compoundselectleft_btn]],},
-- 		},
-- 		[5]={
-- 			click_continue=false,
-- 			effect_list={
-- 				[1]={
-- 					effect_type=[[texture]],
-- 					fixed_pos={x=0.1,y=0.25,},
-- 					flip_y=false,
-- 					play_tween=false,
-- 					texture_name=[[guide_1.png]],
-- 				},
-- 				[2]={
-- 					dlg_sprite=[[h7_zhiyinkuang]],
-- 					effect_type=[[dlg]],
-- 					fixed_pos={x=0.1+0.12,y=0.25,},
-- 					play_tween=false,
-- 					text_list={[1]=[[快选择它]],},
-- 					audio_list={[1]=[[Model/xsydy19.mp3]],},
-- 				},
-- 				[3]={
-- 					effect_type=[[click_ui]],
-- 					offset_pos={x=0,y=0,},
-- 					offset_rotate=0,
-- 					ui_effect=[[Finger]],
-- 					ui_key=[[petview_compoundleftsummon_btn]],
-- 				},
-- 			},
-- 			necessary_ui_list={[1]=[[petview_compoundleftsummon_btn]],},
-- 		},
-- 		[6]={
-- 			click_continue=false,
-- 			effect_list={
-- 				[1]={
-- 					effect_type=[[texture]],
-- 					fixed_pos={x=0,y=-0.125,},
-- 					flip_y=false,
-- 					play_tween=false,
-- 					texture_name=[[guide_1.png]],
-- 				},
-- 				[2]={
-- 					dlg_sprite=[[h7_zhiyinkuang]],
-- 					effect_type=[[dlg]],
-- 					fixed_pos={x=0+0.12,y=-0.125,},
-- 					play_tween=false,
-- 					text_list={[1]=[[点击确定哦]],},
-- 				},
-- 				[3]={
-- 					effect_type=[[click_ui]],
-- 					offset_pos={x=0,y=0,},
-- 					offset_rotate=0,
-- 					ui_effect=[[Finger]],
-- 					ui_key=[[petview_compoundokselect_btn]],
-- 				},
-- 			},
-- 			necessary_ui_list={[1]=[[petview_compoundokselect_btn]],},
-- 		},
-- 		[7]={
-- 			click_continue=false,
-- 			effect_list={
-- 				[1]={
-- 					effect_type=[[texture]],
-- 					fixed_pos={x=-0.125,y=-0.125,},
-- 					flip_y=false,
-- 					play_tween=false,
-- 					texture_name=[[guide_1.png]],
-- 				},
-- 				[2]={
-- 					dlg_sprite=[[h7_zhiyinkuang]],
-- 					effect_type=[[dlg]],
-- 					fixed_pos={x=-0.125+0.12,y=-0.125,},
-- 					play_tween=false,
-- 					text_list={[1]=[[选这里]],},
-- 					audio_list={[1]=[[Model/xsydy19.mp3]],},
-- 				},
-- 				[3]={
-- 					effect_type=[[click_ui]],
-- 					offset_pos={x=0,y=0,},
-- 					offset_rotate=0,
-- 					ui_effect=[[Finger]],
-- 					ui_key=[[petview_compoundselectright_btn]],
-- 				},
-- 			},
-- 			necessary_ui_list={[1]=[[petview_compoundselectright_btn]],},
-- 		},
-- 		[8]={
-- 			click_continue=false,
-- 			effect_list={
-- 				[1]={
-- 					effect_type=[[texture]],
-- 					fixed_pos={x=0.1,y=0.25,},
-- 					flip_y=false,
-- 					play_tween=false,
-- 					texture_name=[[guide_1.png]],
-- 				},
-- 				[2]={
-- 					dlg_sprite=[[h7_zhiyinkuang]],
-- 					effect_type=[[dlg]],
-- 					fixed_pos={x=0.1+0.12,y=0.25,},
-- 					play_tween=false,
-- 					text_list={[1]=[[快选择它]],},
-- 					audio_list={[1]=[[Model/xsydy19.mp3]],},
-- 				},
-- 				[3]={
-- 					effect_type=[[click_ui]],
-- 					offset_pos={x=0,y=0,},
-- 					offset_rotate=0,
-- 					ui_effect=[[Finger]],
-- 					ui_key=[[petview_compoundrightsummon_btn]],
-- 				},
-- 			},
-- 			necessary_ui_list={[1]=[[petview_compoundrightsummon_btn]],},
-- 		},
-- 		[9]={
-- 			click_continue=false,
-- 			effect_list={
-- 				[1]={
-- 					effect_type=[[texture]],
-- 					fixed_pos={x=0,y=-0.125,},
-- 					flip_y=false,
-- 					play_tween=false,
-- 					texture_name=[[guide_1.png]],
-- 				},
-- 				[2]={
-- 					dlg_sprite=[[h7_zhiyinkuang]],
-- 					effect_type=[[dlg]],
-- 					fixed_pos={x=0+0.12,y=-0.125,},
-- 					play_tween=false,
-- 					text_list={[1]=[[点击确定哦]],},
-- 				},
-- 				[3]={
-- 					effect_type=[[click_ui]],
-- 					offset_pos={x=0,y=0,},
-- 					offset_rotate=0,
-- 					ui_effect=[[Finger]],
-- 					ui_key=[[petview_compoundokselect_btn]],
-- 				},
-- 			},
-- 			necessary_ui_list={[1]=[[petview_compoundokselect_btn]],},
-- 		},
-- 		[10]={
-- 			click_continue=false,
-- 			effect_list={
-- 				[1]={
-- 					effect_type=[[texture]],
-- 					fixed_pos={x=0.125,y=-0.125,},
-- 					flip_y=false,
-- 					play_tween=false,
-- 					texture_name=[[guide_1.png]],
-- 				},
-- 				[2]={
-- 					dlg_sprite=[[h7_zhiyinkuang]],
-- 					effect_type=[[dlg]],
-- 					fixed_pos={x=0.125+0.12,y=-0.125,},
-- 					play_tween=false,
-- 					text_list={[1]=[[终于可以合成了]],},
-- 				},
-- 				[3]={
-- 					effect_type=[[click_ui]],
-- 					offset_pos={x=0,y=0,},
-- 					offset_rotate=0,
-- 					ui_effect=[[Finger]],
-- 					ui_key=[[petview_compoundfinalcomfirm_btn]],
-- 				},
-- 			},
-- 			necessary_ui_list={[1]=[[petview_compoundfinalcomfirm_btn]],},
-- 		},
-- 		-- [11]={
-- 		-- 	click_continue=false,
-- 		-- 	effect_list={
-- 		-- 		[1]={
-- 		-- 			effect_type=[[texture]],
-- 		-- 			fixed_pos={x=0.125,y=0.25,},
-- 		-- 			flip_y=false,
-- 		-- 			play_tween=false,
-- 		-- 			texture_name=[[guide_1.png]],
-- 		-- 		},
-- 		-- 		[2]={
-- 		-- 			dlg_sprite=[[h7_zhiyinkuang]],
-- 		-- 			effect_type=[[dlg]],
-- 		-- 			fixed_pos={x=0.125+0.12,y=0.25,},
-- 		-- 			play_tween=false,
-- 		-- 			text_list={[1]=[[关闭界面吧]],},
-- 		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
-- 		-- 		},
-- 		-- 		[3]={
-- 		-- 			effect_type=[[click_ui]],
-- 		-- 			offset_pos={x=0,y=0,},
-- 		-- 			offset_rotate=0,
-- 		-- 			ui_effect=[[Finger]],
-- 		-- 			ui_key=[[petview_close_btn]],
-- 		-- 		},
-- 		-- 	},
-- 		-- 	necessary_ui_list={[1]=[[petview_close_btn]],},
-- 		-- },
-- 	},
-- 	necessary_condition=[[summoncompose_open]],
-- }

Zhiyin={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Circu]],
					ui_key=[[mainmenu_zhiyin_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_zhiyin_btn]],},
		},
	},
	necessary_condition=[[zhiyin_open]],
}

Welfare={
	complete_type=0,
	exceptview = {}, --"CWelfareView"
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25+0.24,y=0.125,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=0.125,},
					play_tween=false,
					text_list={[1]=[[哇，大波福利来啦！]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_welfare_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 286,
				},
			},
			necessary_ui_list={[1]=[[mainmenu_welfare_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.07,y=0.2,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.07+0.12,y=0.2,},
					play_tween=false,
					text_list={[1]=[[点击签到标签]],},
					audio_list={[1]=[[Model/xsydy6.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[sign_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[sign_tab_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[点击签到]],},
					audio_list={[1]=[[Model/xsydy6.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[sign_item1_btn]],
				},
			},
			necessary_ui_list={[1]=[[sign_item1_btn]],},
		},
		[4]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[关闭界面吧]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[welfareview_close_btn]],
				},
			},
			necessary_ui_list={[1]=[[welfareview_close_btn]],},
		},
	},
	necessary_condition=[[welfare_open]],
}

TaskFindItem1={
	complete_type=0,
	exceptview = {"CNpcGroceryShopView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[点击购买任务物品吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[npcshop_buy_btn]],
				},
			},
			necessary_ui_list={[1]=[[npcshop_buy_btn]],},
		},
		-- [2]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=-0.15,y=0,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=-0.15+0.12,y=0,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[关闭界面吧]],},
		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[npcshop_close_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[npcshop_close_btn]],},
		-- },
	},
	necessary_condition=[[taskfinditem1_open]],
}

TaskFindItem2={
	complete_type=0,
	exceptview = {"CNpcGroceryShopView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.125,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[点击购买任务物品吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[npcshop_buy_btn]],
				},
			},
			necessary_ui_list={[1]=[[npcshop_buy_btn]],},
		},
		-- [2]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=-0.15,y=0,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=-0.15+0.12,y=0,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[关闭界面吧]],},
		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[npcshop_close_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[npcshop_close_btn]],},
		-- },
	},
	necessary_condition=[[taskfinditem2_open]],
}

UseItem={
	complete_type=0,
	exceptview = {"CItemQuickUseView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[点击获得坐骑哦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[item_quickuse_btn]],
				},
			},
			necessary_ui_list={[1]=[[item_quickuse_btn]],},
		},
	},
	necessary_condition=[[useitem_open]],
}

UseItem10={
	complete_type=0,
	exceptview = {"CItemQuickUseView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[恭喜你获得一份大礼包，打开看看吧]],},
					audio_list={[1]=[[Model/xsydy16.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[item_quickuse_btn]],
				},
			},
			necessary_ui_list={[1]=[[item_quickuse_btn]],},
		},
	},
	necessary_condition=[[useitem10_open]],
}

UseItem20={
	complete_type=0,
	exceptview = {"CItemQuickUseView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[恭喜你获得一份大礼包，打开看看吧]],},
					audio_list={[1]=[[Model/xsydy16.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[item_quickuse_btn]],
				},
			},
			necessary_ui_list={[1]=[[item_quickuse_btn]],},
		},
	},
	necessary_condition=[[useitem20_open]],
}

UseItem30={
	complete_type=0,
	exceptview = {"CItemQuickUseView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[恭喜你获得一份大礼包，打开看看吧]],},
					audio_list={[1]=[[Model/xsydy16.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[item_quickuse_btn]],
				},
			},
			necessary_ui_list={[1]=[[item_quickuse_btn]],},
		},
	},
	necessary_condition=[[useitem30_open]],
}

UseItem40={
	complete_type=0,
	exceptview = {"CItemQuickUseView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[恭喜你获得一份大礼包，打开看看吧]],},
					audio_list={[1]=[[Model/xsydy16.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[item_quickuse_btn]],
				},
			},
			necessary_ui_list={[1]=[[item_quickuse_btn]],},
		},
	},
	necessary_condition=[[useitem40_open]],
}

Skill={
	complete_type=0,
	exceptview = {}, --"CSkillMainView"
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.25,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.25+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[技能功能开启啦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_skillbtn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_skillbtn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.15,y=0.2,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=0.1,},
					play_tween=false,
					text_list={[1]=[[请点击心法标签]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[skill_passive_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_passive_tab_btn]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.2,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.15,},
					play_tween=false,
					text_list={[1]=[[升级技能可以提升角色实力，点击升级吧。]],},
					audio_list={[1]=[[Model/xsydy14.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[skill_passive_allup_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_passive_allup_btn]],},
		},
		[4]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1,y=0,},
					play_tween=false,
					text_list={[1]=[[心法技能可增强角色各项属性，每次升级后记得来升技能哦！]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[skill_guide_widget3]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
				},
				[5]={effect_type=[[focus_ui]],ui_key=[[skill_guide_widget3]],},
			},
			necessary_ui_list={[1]=[[skill_guide_widget3]],},
		},
	},
	necessary_condition=[[skill_open]],
}

UpgradePack={
	complete_type=0,
	exceptview = {}, --"CWelfareView"
	after_guide=[[after_upgradepack_guide]],
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=0.18,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=0.18,},
					play_tween=false,
					text_list={[1]=[[有等级礼包可领取，内含整套装备。]],},
					audio_list={[1]=[[Model/xsydy15.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_welfare_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_welfare_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.125,y=0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.125+0.12,y=0.125,},
					play_tween=false,
					text_list={[1]=[[点击这里]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[upgradepack_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[upgradepack_tab_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.15,y=0.35,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.15+0.12,y=0.35,},
					play_tween=false,
					text_list={[1]=[[赶快领取吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[upgradepack_item1_reward_btn]],
				},
			},
			necessary_ui_list={[1]=[[upgradepack_item1_reward_btn]],},
		},
		-- [4]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=-0.15,y=0,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=-0.15+0.12,y=0,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[关闭界面吧]],},
		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[welfareview_close_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[welfareview_close_btn]],},
		-- },
	},
	necessary_condition=[[upgradepack_open]],
}

UpgradePack20={
	complete_type=0,
	exceptview = {}, --"CWelfareView"
	after_guide=[[after_upgradepack_guide]],
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=0.18,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=0.18,},
					play_tween=false,
					text_list={[1]=[[有等级礼包可领取，内含整套装备。]],},
					audio_list={[1]=[[Model/xsydy15.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_welfare_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_welfare_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.125,y=0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.125+0.12,y=0.125,},
					play_tween=false,
					text_list={[1]=[[点击这里]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[upgradepack_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[upgradepack_tab_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.15,y=0.35,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.15+0.12,y=0.35,},
					play_tween=false,
					text_list={[1]=[[赶快领取吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[upgradepack_item2_reward_btn]],
				},
			},
			necessary_ui_list={[1]=[[upgradepack_item2_reward_btn]],},
		},
	},
	necessary_condition=[[upgradepack20_open]],
}

UpgradePack30={
	complete_type=0,
	exceptview = {}, --"CWelfareView"
	after_guide=[[after_upgradepack_guide]],
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=0.18,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=0.18,},
					play_tween=false,
					text_list={[1]=[[有等级礼包可领取，内含整套装备。]],},
					audio_list={[1]=[[Model/xsydy15.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_welfare_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_welfare_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.125,y=0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.125+0.12,y=0.125,},
					play_tween=false,
					text_list={[1]=[[点击这里]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[upgradepack_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[upgradepack_tab_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.15,y=0.35,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.15+0.12,y=0.35,},
					play_tween=false,
					text_list={[1]=[[赶快领取吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[upgradepack_item3_reward_btn]],
				},
			},
			necessary_ui_list={[1]=[[upgradepack_item3_reward_btn]],},
		},
	},
	necessary_condition=[[upgradepack30_open]],
}

UpgradePack40={
	complete_type=0,
	exceptview = {}, --"CWelfareView"
	after_guide=[[after_upgradepack_guide]],
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=0.18,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=0.18,},
					play_tween=false,
					text_list={[1]=[[有等级礼包可领取，内含整套装备。]],},
					audio_list={[1]=[[Model/xsydy15.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_welfare_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_welfare_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.125,y=0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.125+0.12,y=0.125,},
					play_tween=false,
					text_list={[1]=[[点击这里]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[upgradepack_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[upgradepack_tab_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.15,y=0.35,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.15+0.12,y=0.35,},
					play_tween=false,
					text_list={[1]=[[赶快领取吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[upgradepack_item4_reward_btn]],
				},
			},
			necessary_ui_list={[1]=[[upgradepack_item4_reward_btn]],},
		},
	},
	necessary_condition=[[upgradepack40_open]],
}

Improve={
	complete_type=0,
	exceptview = {}, --"CPromoteBtnView", "CSkillMainView"
	after_guide=[[after_improve_guide]],
	guide_list={
		[1]={
			-- start_condition=[[improve_passiveskill_open]],
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.1,y=0.18,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.1+0.12,y=0.18,},
					play_tween=false,
					text_list={[1]=[[提升按钮出现代表你可以提升实力了。]],},
					audio_list={[1]=[[Model/xsydy18.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_promote_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_promote_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=0.125,},
					play_tween=false,
					text_list={[1]=[[点击提升技能]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[promote_skill_btn]],
				},
			},
			necessary_ui_list={[1]=[[promote_skill_btn]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.2,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.2,},
					play_tween=false,
					text_list={[1]=[[升级技能可以提升人物实力，点击升级吧。]],},
					audio_list={[1]=[[Model/xsydy14.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[skill_passive_allup_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_passive_allup_btn]],},
		},
		-- [4]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=0.125,y=0.25,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=0.125+0.12,y=0.25,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[关闭界面吧]],},
		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[skill_close_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[skill_close_btn]],},
		-- },
	},
	necessary_condition=[[improve_open]],
}

ImproveActiveSkill={
	complete_type=0,
	exceptview = {}, --"CPromoteBtnView", "CSkillMainView"
	after_guide=[[after_improve_guide]],
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.1,y=0.18,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.1+0.12,y=0.18,},
					play_tween=false,
					text_list={[1]=[[提升按钮出现代表你可以提升实力了。]],},
					audio_list={[1]=[[Model/xsydy18.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_promote_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_promote_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=0.125,},
					play_tween=false,
					text_list={[1]=[[点击提升技能]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[promote_skill_active_btn]],
				},
			},
			necessary_ui_list={[1]=[[promote_skill_active_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.125,},
					play_tween=false,
					text_list={[1]=[[升级技能可以提升人物实力，点击升级吧。]],},
					audio_list={[1]=[[Model/xsydy14.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[skill_eachup_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_eachup_btn]],},
		},
	},
	necessary_condition=[[improveactiveskill_open]],
}

Org={
	complete_type=0,
	after_guide=[[after_OrgExist_guide]],
	exceptview = {"COrgJoinOrRespondView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.25,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.25+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[帮派开启啦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_org_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_org_btn]],},
		},
		[2]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.05,y=-0.04,},
					play_tween=false,
					text_list={[1]=[[目前暂时没有可加入的帮派，您可以等会再来帮派界面瞧瞧，或是到#G20级#n后花费元宝创建帮派。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[org_guide_widget]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
				},
				[5]={effect_type=[[focus_ui]],ui_key=[[org_guide_widget]],},
			},
			necessary_ui_list={[1]=[[org_guide_widget]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[关闭界面吧]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[joinorgview_close_btn]],
				},
			},
			necessary_ui_list={[1]=[[joinorgview_close_btn]],},
		},
	},
	necessary_condition=[[org_open]],
}

OrgExist={
	complete_type=0,
	after_guide=[[after_OrgExist_guide]],
	exceptview = {"COrgJoinOrRespondView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.25,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.25+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[帮派开启啦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_org_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_org_btn]],},
		},
		[2]={
			click_continue=true,
			-- start_condition=[[org_apply_start_condition]],
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.1,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[赶快申请吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[org_oneclickapply_btn]],
				},
			},
			necessary_ui_list={[1]=[[org_oneclickapply_btn]],},
		},
		-- [3]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=0.125,y=0.25,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=0.125+0.12,y=0.25,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[关闭界面吧]],},
		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[joinorgview_close_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[joinorgview_close_btn]],},
		-- },
	},
	necessary_condition=[[orgexist_open]],
}

OrgChat={
	complete_type=0,
	exceptview = {"CChatMainView", "CEmojiLinkView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.18,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.18+0.12,y=-0.125,},
					play_tween=false,
					text_list={[1]=[[加入帮派可以聊天啦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_chat_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_chat_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.28,y=0.1,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.28+0.12,y=0.1,},
					play_tween=false,
					text_list={[1]=[[点击帮派标签哦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[chatview_org_btn]],
				},
			},
			necessary_ui_list={[1]=[[chatview_org_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=0.2,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=0.2,},
					play_tween=false,
					text_list={[1]=[[点击打开表情界面]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=20,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[chatview_emoji_btn]],
				},
			},
			necessary_ui_list={[1]=[[chatview_emoji_btn]],},
		},
		[4]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.125,y=0.1,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.125+0.12,y=0.1,},
					play_tween=false,
					text_list={[1]=[[选择一个表情]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=25,y=-25,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[chatview_emoji_icon]],
				},
			},
			necessary_ui_list={[1]=[[chatview_emoji_icon]],},
		},
		[5]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=0.2,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=0.2,},
					play_tween=false,
					text_list={[1]=[[可以发送了]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[chatview_send_btn]],
				},
			},
			necessary_ui_list={[1]=[[chatview_send_btn]],},
		},
	},
	necessary_condition=[[orgchat_open]],
}

GetPartner={
	complete_type=0,
	exceptview = {}, --"CPartnerMainView"
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[有新的伙伴可以招募啦！]],},
					audio_list={[1]=[[Model/xsydy17.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.07+0.14,y=0.05,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.07,y=0.05,},
					play_tween=false,
					text_list={[1]=[[快选择它]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[partnerview_tab_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 161,
				},
			},
			necessary_ui_list={[1]=[[partnerview_tab_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.12,y=-0.15,},
					play_tween=false,
					text_list={[1]=[[赶紧招募吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[partner_recruit_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_recruit_btn]],},
		},
		-- [4]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=0.125,y=0.25,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=0.125+0.12,y=0.25,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[关闭界面吧]],},
		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[partnerview_close_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[partnerview_close_btn]],},
		-- },
	},
	necessary_condition=[[getpartner_open]],
}

PartnerLevelUp={
	complete_type=0,
	exceptview = {"CPartnerMainView"},
	-- after_guide=[[after_getpartner_guide]],
	guide_list={
		-- [1]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=0.125,y=-0.25,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=0.125+0.12,y=-0.25,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[伙伴升级会更强力哦]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[partner_useitem_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[partner_useitem_btn]],},
		-- },
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[关闭界面吧]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[partnerview_close_btn]],
				},
			},
			necessary_ui_list={[1]=[[partnerview_close_btn]],},
		},
		-- [2]={
		-- 	click_continue=false,
		-- 	pass=true,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[notify_effect_ui]],
		-- 			notify_ui_effect=[[Circu]],
		-- 			ui_key=[[mainmenu_partner_btn]],
		-- 			offset_pos={x=0,y=0,},
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
		-- },
	},
	necessary_condition=[[partnerlevelup_open]],
}

PartnerUpgrade={
	complete_type=0,
	exceptview = {}, --"CPartnerMainView"
	after_guide=[[after_partnerupgrade_guide]],
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[有伙伴可以升阶啦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.125,},
					play_tween=false,
					text_list={[1]=[[伙伴升阶后属性将大幅提升哦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[partnerview_upgrade_tab]],
				},
			},
			necessary_ui_list={[1]=[[partnerview_upgrade_tab]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.12,y=-0.125,},
					play_tween=false,
					text_list={[1]=[[点击升阶吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[partner_advance_btn]],
				},
			},
			necessary_ui_list={[1]=[[partner_advance_btn]],},
		},
	},
	necessary_condition=[[partnerupgrade_open]],
}

Schedule={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Circu]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},
	},
	necessary_condition=[[schedule_open]],
}

PreOpen={
	complete_type=0,
	exceptview = {}, --"CGuideFuncNotifyView"
	after_guide=[[after_PreOpen_guide]],
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.3+0.27,y=0.14,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.3,y=0.14,},
					play_tween=false,
					text_list={[1]=[[来领取伙伴元神吧！]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[preopen_box_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 311,
				},
			},
			necessary_ui_list={[1]=[[preopen_box_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[赶紧领取吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[preopen_get_btn]],
				},
			},
			necessary_ui_list={[1]=[[preopen_get_btn]],},
		},
		-- [3]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=0.125,y=0.3,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=0.1+0.12,y=0.3,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[关闭界面吧]],},
		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[preopen_close_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[preopen_close_btn]],},
		-- },
	},
	necessary_condition=[[preopen_open]],
}

EightLogin={
	complete_type=0,
	exceptview = {}, --"CWelfareView", "CYoukaLoginView"
	after_guide=[[after_EightLogin_guide]],
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25+0.24,y=0.125,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=0.125,},
					play_tween=false,
					text_list={[1]=[[哇，大波福利来啦！]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_welfare_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 286,
				},
			},
			necessary_ui_list={[1]=[[mainmenu_welfare_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.07,y=0.2,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.07+0.12,y=0.2,},
					play_tween=false,
					text_list={[1]=[[点击八日登录标签]],},
					audio_list={[1]=[[Model/xsydy6.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[eightlogin_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[eightlogin_tab_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0+0.28,y=-0.2,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0,y=-0.1,},
					play_tween=false,
					text_list={[1]=[[有一份礼物可以领取哦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[eightlogin_get_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 311,
				},
			},
			necessary_ui_list={[1]=[[eightlogin_get_btn]],},
		},
		[4]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1,y=0.25,},
					play_tween=false,
					text_list={[1]=[[来看看第二天的奖励]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[eightlogin_second_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 259,
				},
			},
			necessary_ui_list={[1]=[[eightlogin_second_btn]],},
		},
		[5]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.05,y=0.2,},
					play_tween=false,
					text_list={[1]=[[第二天的奖励是群攻宠物机关兽，明天记得来领哦！]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[welfare_guide_widget]],
				},
				[4]={effect_type=[[focus_ui]],ui_key=[[welfare_guide_widget]],},
			},
			necessary_ui_list={[1]=[[welfare_guide_widget]],},
		},
	},
	necessary_condition=[[eightlogin_open]],
}

MysticalBox={
	complete_type=0,
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.23,y=0,},
					play_tween=false,
					text_list={[1]=[[恭喜您获得一个神秘的宝箱，时间到了即可打开]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_mysticalBox_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
				},
			},
			necessary_ui_list={[1]=[[mainmenu_mysticalBox_btn]],},
		},		
	},
	necessary_condition=[[MysticalBox_open]],
}

equipqh={
	complete_type=0,
	exceptview = {}, --"CForgeMainView"
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[可以强化装备啦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_forge_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_forge_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[请点击强化标签]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[equip_qh_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[equip_qh_tab_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[赶紧强化吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[equip_qh_btn]],
				},
			},
			necessary_ui_list={[1]=[[equip_qh_btn]],},
		},
		[4]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[关闭界面吧]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[forgeview_close_btn]],
				},
			},
			necessary_ui_list={[1]=[[forgeview_close_btn]],},
		},
	},
	necessary_condition=[[equipqh_open]],
}


Jjc={
	complete_type=0,
	exceptview = {}, --"CScheduleMainView", "CJjcMainView"
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=0.2,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=0.2,},
					play_tween=false,
					text_list={[1]=[[参加竞技吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=0.125,},
					play_tween=false,
					text_list={[1]=[[点击参加吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[schedule_jjc_join_btn]],
				},
			},
			necessary_ui_list={[1]=[[schedule_jjc_join_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.125+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[去挑战您的对手哦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[jjc_item1_challenge_btn]],
				},
			},
			necessary_ui_list={[1]=[[jjc_item1_challenge_btn]],},
		},
	},
	necessary_condition=[[jjc_open]],
}

XiuLian={
	complete_type=0,
	exceptview={}, --"CSkillMainView"
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.25,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.25+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[修炼可以大幅提升实力哦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_skillbtn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_skillbtn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[请点击修炼标签]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[skill_cultivate_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_cultivate_tab_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.25,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25+0.12,y=-0.125,},
					play_tween=false,
					text_list={[1]=[[开始修炼看看]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[skill_cultivate_learn_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_cultivate_learn_btn]],},
		},
		[4]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[关闭界面吧]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[skill_close_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_close_btn]],},
		},
	},
	necessary_condition=[[xiulian_open]],
}

Ride={
	complete_type=0,
	before_guide=[[before_Ride_guide]],
	after_guide=[[after_Ride_guide]],
	exceptview={}, --"CHorseMainView"
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.3,y=0.14,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=-0.08,},
					play_tween=false,
					text_list={[1]=[[坐骑系统开启了，让我带你去领取拉风的坐骑吧！]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[lead_getride_btn]],
				},
			},
			necessary_ui_list={[1]=[[lead_getride_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[请点击领取按钮]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[preopen_ride_get_btn]],
				},
			},
			necessary_ui_list={[1]=[[preopen_ride_get_btn]],},
		},
		-- [3]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=0.125,y=0.3,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=0.125+0.12,y=0.3,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[请点击关闭按钮]],},
		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[preopen_close_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[preopen_close_btn]],},
		-- },
	},
	necessary_condition=[[ride_open]],
}

RideTwo={
	complete_type=0,
	exceptview={}, --"CHorseMainView"
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=-0.2,},
					play_tween=false,
					text_list={[1]=[[点击坐骑按钮，去看看刚刚获得的坐骑吧。]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_horse_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_horse_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0.25,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.15+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[在这里]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[ride_selecttab_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 127,
				},
			},
			necessary_ui_list={[1]=[[ride_selecttab_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=-0.15,},
					play_tween=false,
					text_list={[1]=[[坐骑可为角色增加属性，点击骑乘遨游三界吧。]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[horse_ride_btn]],
				},
			},
			necessary_ui_list={[1]=[[horse_ride_btn]],},
		},
		-- [4]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=0.125,y=0.25,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=0.125+0.12,y=0.25,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[关闭界面吧]],},
		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[horseview_close_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[horseview_close_btn]],},
		-- },
	},
	necessary_condition=[[RideTwo_open]],
}

equipxl={
	complete_type=0,
	exceptview={}, --"CForgeMainView"
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[可以洗炼装备啦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_forge_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_forge_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[请点击洗炼标签]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[equip_xl_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[equip_xl_tab_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[赶紧洗炼吧]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[equip_xl_btn]],
				},
			},
			necessary_ui_list={[1]=[[equip_xl_btn]],},
		},
		[4]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[关闭界面吧]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[forgeview_close_btn]],
				},
			},
			necessary_ui_list={[1]=[[forgeview_close_btn]],},
		},
	},
	necessary_condition=[[equipxl_open]],
}

Shimen={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[TaskRect]],
					ui_key=[[task_shimen_btn]],
				},
			},
			necessary_ui_list={[1]=[[task_shimen_btn]],},
		},
	},
	necessary_condition=[[shimen_open]],
}

ShimenNew={
	complete_type=0,
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.2+0.2,y=0.2,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.2,y=0.2,},
					play_tween=false,
					text_list={[1]=[[门派修行开启啦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_schedule_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 236,
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},
		[2]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.15+0.28,y=-0.05,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.15,y=-0.05,},
					play_tween=false,
					text_list={[1]=[[参加门派修行奖励多多哦]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[schedule_shimen_join_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 336,
				},
			},
			necessary_ui_list={[1]=[[schedule_shimen_join_btn]],},
		},
	},
	necessary_condition=[[shimennew_open]],
}

SummonGet2HasPlay={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Rect]],
					ui_key=[[petview_open_btn]],
					offset_pos={x=-86,y=-31,},
				},
			},
			necessary_ui_list={[1]=[[petview_open_btn]],},
		},
	},
	necessary_condition=[[summonget2hasplay_open]],
}

SkillHasPlay={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Circu]],
					ui_key=[[mainmenu_skillbtn]],
					offset_pos={x=0,y=0,},
				},
			},
			necessary_ui_list={[1]=[[mainmenu_skillbtn]],},
		},
	},
	necessary_condition=[[skillhasplay_open]],
}

UpgradePackHasPlay={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Circu]],
					ui_key=[[mainmenu_welfare_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_welfare_btn]],},
		},
	},
	necessary_condition=[[upgradepackhasplay_open]],
}

ImproveHasPlay={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Circu]],
					ui_key=[[mainmenu_promote_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_promote_btn]],},
		},
	},
	necessary_condition=[[improvehasplay_open]],
}

GetPartnerHasPlay={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Circu]],
					ui_key=[[mainmenu_partner_btn]],
					offset_pos={x=0,y=0,},
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
		},
	},
	necessary_condition=[[getpartnerhasplay_open]],
}

PartnerUpgradeHasPlay={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Circu]],
					ui_key=[[mainmenu_partner_btn]],
					offset_pos={x=0,y=0,},
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
		},
	},
	necessary_condition=[[partnerupgradehasplay_open]],
}

equipqhHasPlay={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Circu]],
					ui_key=[[mainmenu_forge_btn]],
					offset_pos={x=0,y=0,},
				},
			},
			necessary_ui_list={[1]=[[mainmenu_forge_btn]],},
		},
	},
	necessary_condition=[[equipqhhasplay_open]],
}

JjcHasPlay={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Circu]],
					ui_key=[[mainmenu_schedule_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_schedule_btn]],},
		},
	},
	necessary_condition=[[jjchasplay_open]],
}

XiuLianHasPlay={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Circu]],
					ui_key=[[mainmenu_skillbtn]],
					offset_pos={x=0,y=0,},
				},
			},
			necessary_ui_list={[1]=[[mainmenu_skillbtn]],},
		},
	},
	necessary_condition=[[xiulianhasplay_open]],
}

equipxlHasPlay={
	complete_type=0,
	guide_list={
		[1]={
			need_guide_view=false,
			click_continue=false,
			pass=true,
			effect_list={
				[1]={
					effect_type=[[notify_effect_ui]],
					notify_ui_effect=[[Circu]],
					ui_key=[[mainmenu_forge_btn]],
					offset_pos={x=0,y=0,},
				},
			},
			necessary_ui_list={[1]=[[mainmenu_forge_btn]],},
		},
	},
	necessary_condition=[[equipxlhasplay_open]],
}

TouXian={
	complete_type=0,
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.005,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.16,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[头衔代表道友的修仙阶段，可为角色增加属性。]],},
					audio_list={[1]=[[Model/xsydy17.mp3]],},  --todo
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=130,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_badge_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_badge_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=-0.125,},
					play_tween=false,
					text_list={[1]=[[头衔等级越高加的属性也越多，晋升头衔需消耗风云令。]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[badge_promote_btn]],
				},
			},
			necessary_ui_list={[1]=[[badge_promote_btn]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.10,y=0,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[想要晋升头衔就去收集更多的风云令吧！]],},
					audio_list={[1]=[[Model/xsydy7.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[badge_guide_widget]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
				},
				[5]={effect_type=[[focus_ui]],ui_key=[[badge_guide_widget]],},
			},
			necessary_ui_list={[1]=[[badge_guide_widget]],},
		},
	},
	necessary_condition=[[touxian_open]],
}

ItemBagView={
	complete_type=0,
	before_guide=[[before_ItemBagView_guide]],
	exceptview = {"CItemMainView"},
	guide_list={
		[1]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.1,y=0.3,},
					play_tween=false,
					text_list={[1]=[[在包裹可以查看已获得的物品，还可以查看您的全部资产。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[item_guide_widget1]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
					offsety = -40,
				},
				[5]={effect_type=[[focus_ui]],ui_key=[[item_guide_widget1]],},
			},
			necessary_ui_list={[1]=[[item_guide_widget1]],},
		},
		[2]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1,y=-0.1,},
					play_tween=false,
					text_list={[1]=[[左侧是装备区域，只有穿戴装备后您才会变得更强。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[item_guide_widget2]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
				},
				[5]={effect_type=[[focus_ui]],ui_key=[[item_guide_widget2]],},
			},
			necessary_ui_list={[1]=[[item_guide_widget2]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.25,y=0,},
					play_tween=false,
					text_list={[1]=[[已获得的道具都在这里了，点击可以查看用途属性。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[item_guide_widget3]],
				},
				[4]={effect_type=[[focus_ui]],ui_key=[[item_guide_widget3]],},
			},
			necessary_ui_list={[1]=[[item_guide_widget3]],},
		},
	},
	necessary_condition=[[ItemBagView_open]],
}

SummonXilian={
	complete_type=0,
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[来看看怎么洗炼宠物吧。]],},
					audio_list={[1]=[[Model/xsydy8.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=-35,y=-35,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_open_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_open_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.15+0.12,y=-0.125,},
					play_tween=false,
					text_list={[1]=[[点击炼妖]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_adjust_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_adjust_btn]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.1,y=-0.05,},
					play_tween=false,
					text_list={[1]=[[可使用还童丹洗炼宠物的属性资质、成长和技能数量，但会将宠物等级重置为0级。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[summon_guide_widget1]],
				},
				[4]={effect_type=[[focus_ui]],ui_key=[[summon_guide_widget1]],},
			},
			necessary_ui_list={[1]=[[summon_guide_widget1]],},
		},
	},
	necessary_condition=[[SummonXilian_open]],
}

SummonSkill={
	complete_type=0,
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[来看看宠物技能学习。]],},
					audio_list={[1]=[[Model/xsydy8.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=-35,y=-35,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_open_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_open_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.15+0.12,y=-0.125,},
					play_tween=false,
					text_list={[1]=[[点击炼妖]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_adjust_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_adjust_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.125+0.12,y=0.1,},
					play_tween=false,
					text_list={[1]=[[请点击学技能]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_skill_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_skill_btn]],},
		},
		[4]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0,y=0.05,},
					play_tween=false,
					text_list={[1]=[[使用技能书可学习对应技能，要注意会有几率顶替原技能。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[summon_guide_widget2]],
				},
				[4]={effect_type=[[focus_ui]],ui_key=[[summon_guide_widget2]],},
			},
			necessary_ui_list={[1]=[[summon_guide_widget2]],},
		},
	},
	necessary_condition=[[SummonSkill_open]],
}

SummonCompose={
	complete_type=0,
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0.25,},
					play_tween=false,
					text_list={[1]=[[来看看宠物怎么合成的。]],},
					audio_list={[1]=[[Model/xsydy8.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=-35,y=-35,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_open_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_open_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.125,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.15+0.12,y=-0.125,},
					play_tween=false,
					text_list={[1]=[[请点击炼妖]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_adjust_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_adjust_btn]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.125+0.12,y=0.1,},
					play_tween=false,
					text_list={[1]=[[请点击合宠]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[petview_compound_btn]],
				},
			},
			necessary_ui_list={[1]=[[petview_compound_btn]],},
		},
		[4]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0,y=0,},
					play_tween=false,
					text_list={[1]=[[选择两只宠物并消耗造化丹会生成新的宠物，可根据图鉴合宠公式合成稀有宠物哦。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[summon_guide_widget3]],
				},
				[4]={effect_type=[[focus_ui]],ui_key=[[summon_guide_widget3]],},
			},
			necessary_ui_list={[1]=[[summon_guide_widget3]],},
		},
	},
	necessary_condition=[[SummonCompose_open]],
}

PartnerImprove={
	complete_type=0,
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[来看看怎么提升伙伴。]],},
					audio_list={[1]=[[Model/xsydy17.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_partner_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_partner_btn]],},
		},
		[2]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0,y=-0.3,},
					play_tween=false,
					text_list={[1]=[[伙伴装备可提升伙伴属性，可对装备进行强化和升级。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[partner_guide_widget1]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
				},
				[5]={effect_type=[[focus_ui]],ui_key=[[partner_guide_widget1]],},
			},
			necessary_ui_list={[1]=[[partner_guide_widget1]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.13,y=0,},
					play_tween=false,
					text_list={[1]=[[护主技能可为你的角色属性增幅，佩戴多个同种护主技能只会生效一个。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[partner_guide_widget2]],
				},
				[4]={effect_type=[[focus_ui]],ui_key=[[partner_guide_widget2]],},
			},
			necessary_ui_list={[1]=[[partner_guide_widget2]],},
		},
		[4]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0,y=-0.1,},
					play_tween=false,
					text_list={[1]=[[消耗婆娑丹可升级伙伴技能，提升技能属性。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[partner_guide_widget3]],
				},
				[4]={effect_type=[[focus_ui]],ui_key=[[partner_guide_widget3]],},
			},
			necessary_ui_list={[1]=[[partner_guide_widget3]],},
		},
	},
	necessary_condition=[[PartnerImprove_open]],
}

ForgeQh={
	complete_type=0,
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[强化是提升装备最有效的途径，点击锻造。]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_forge_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_forge_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[选择强化标签]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[equip_qh_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[equip_qh_tab_btn]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1,y=0,},
					play_tween=false,
					text_list={[1]=[[装备强化会提升该部位装备的各项属性，不受装备更换影响，需消耗银币和指定材料。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[forge_guide_widget]],
				},
				[4]={effect_type=[[focus_ui]],ui_key=[[forge_guide_widget]],},
			},
			necessary_ui_list={[1]=[[forge_guide_widget]],},
		},
	},
	necessary_condition=[[ForgeQh_open]],
}

ForgeXl={
	complete_type=0,
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[来看看装备洗炼]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_forge_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_forge_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.15+0.12,y=0.05,},
					play_tween=false,
					text_list={[1]=[[点击洗炼]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[equip_xl_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[equip_xl_tab_btn]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1,y=0,},
					play_tween=false,
					text_list={[1]=[[洗炼可以刷新装备的附加属性，需消耗银币和洗炼石。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[forge_guide_widget]],
				},
				[4]={effect_type=[[focus_ui]],ui_key=[[forge_guide_widget]],},
			},
			necessary_ui_list={[1]=[[forge_guide_widget]],},
		},
	},
	necessary_condition=[[ForgeXl_open]],
}

OrgSkill={
	complete_type=0,
	before_guide=[[before_OrgSkill_guide]],
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.25,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.25+0.12,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[一起来看看帮派技能]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=90,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_skillbtn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_skillbtn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.15,y=0.2,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.13,y=-0.18,},
					play_tween=false,
					text_list={[1]=[[点击辅助进入，查看帮派技能]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[skill_org_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_org_tab_btn]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.05,y=0.05,},
					play_tween=false,
					text_list={[1]=[[强身、冥想可提升角色气血和法力上限，其余生活技能可消耗活力制作道具；消耗帮贡和银币可升级帮派技能。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[skill_guide_widget]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
				},
				[5]={effect_type=[[focus_ui]],ui_key=[[skill_guide_widget]],},
			},
			necessary_ui_list={[1]=[[skill_guide_widget]],},
		},
	},
	necessary_condition=[[OrgSkill_open]],
}

StoryChapter={
	complete_type=0,
	before_guide=[[before_StoryChapter_guide]],
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.25,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.12,y=0.15,},
					play_tween=false,
					text_list={[1]=[[已经通关一个剧情章节，可以领取剧情奖励了。]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_task_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_task_btn]],},
		},
		[2]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.05,y=0.05,},
					play_tween=false,
					text_list={[1]=[[每个章节有8个剧情碎片，收集满就可以领取该章节的剧情奖励。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[task_guide_widget]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
				},
				[5]={effect_type=[[focus_ui]],ui_key=[[task_guide_widget]],},
			},
			necessary_ui_list={[1]=[[task_guide_widget]],},
		},
		[3]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.15,y=0.2,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.1+0.12,y=-0.18,},
					play_tween=false,
					text_list={[1]=[[来领取这章节的剧情奖励吧。]],},
					audio_list={[1]=[[Model/xsydy19.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[task_story_getbtn]],
				},
			},
			necessary_ui_list={[1]=[[task_story_getbtn]],},
		},
	},
	necessary_condition=[[StoryChapter_open]],
}

Artifact={
	complete_type=0,
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.25,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.2+0.12,y=-0.18,},
					play_tween=false,
					text_list={[1]=[[神器系统开启了，一起来看看吧。]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_artifact_btn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_artifact_btn]],},
		},
		[2]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.23+0.34,y=0,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.05,y=0.05,},
					play_tween=false,
					text_list={[1]=[[神器可为角色增加属性，消耗神器精华可升级神器等级，当神器达到30级时更有器灵随你出战哦。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[artifact_guide_widget]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
				},
				[5]={effect_type=[[focus_ui]],ui_key=[[artifact_guide_widget]],},
			},
			necessary_ui_list={[1]=[[artifact_guide_widget]],},
		},
	},
	necessary_condition=[[Artifact_open]],
}

WingReward={
	complete_type=0,
	before_guide=[[before_wingReward_guide]],
	after_guide=[[after_wingReward_guide]],
	exceptview={},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=-0.3,y=0.14,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=-0.4+0.12,y=0.14,},
					play_tween=false,
					text_list={[1]=[[羽翼系统开启了，让我带你去领取酷炫的羽翼吧！]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[preopen_box_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 411,
				},
			},
			necessary_ui_list={[1]=[[preopen_box_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[点击领取]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[preopen_wing_get_btn]],
				},
			},
			necessary_ui_list={[1]=[[preopen_wing_get_btn]],},
		},
		-- [3]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=0.125,y=0.3,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=0.125+0.12,y=0.3,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[点击关闭]],},
		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[preopen_close_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[preopen_close_btn]],},
		-- },
	},
	necessary_condition=[[wing_open]],
}

WingActive={
	complete_type=0,
	before_guide=[[before_wingActive_guide]],
	after_guide=[[after_wingActive_guide]],
	exceptview={"CWingMainView"},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.125+0.12,y=0,},
					play_tween=false,
					text_list={[1]=[[你已经获得了一件羽翼，点击使用穿上吧。]],},
					audio_list={[1]=[[Model/xsydy4.mp3]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[item_quickuse_btn]],
				},
			},
			necessary_ui_list={[1]=[[item_quickuse_btn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.125+0.12,y=-0.25,},
					flip_y=true,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0,y=-0.25,},
					play_tween=false,
					text_list={[1]=[[激活后可获得羽翼得增益属性。]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[wing_active_btn]],
				},
				[4]={
					effect_type=[[arrowright]],
					offsetx = 369,
				},
			},
			necessary_ui_list={[1]=[[wing_active_btn]],},
		},
		-- [3]={
		-- 	click_continue=false,
		-- 	effect_list={
		-- 		[1]={
		-- 			effect_type=[[texture]],
		-- 			fixed_pos={x=0.125,y=0.25,},
		-- 			flip_y=false,
		-- 			play_tween=false,
		-- 			texture_name=[[guide_1.png]],
		-- 		},
		-- 		[2]={
		-- 			dlg_sprite=[[h7_zhiyinkuang]],
		-- 			effect_type=[[dlg]],
		-- 			fixed_pos={x=0.125+0.12,y=0.25,},
		-- 			play_tween=false,
		-- 			text_list={[1]=[[关闭界面吧]],},
		-- 			audio_list={[1]=[[Model/xsydy7.mp3]],},
		-- 		},
		-- 		[3]={
		-- 			effect_type=[[click_ui]],
		-- 			offset_pos={x=0,y=0,},
		-- 			offset_rotate=0,
		-- 			ui_effect=[[Finger]],
		-- 			ui_key=[[wingview_close_btn]],
		-- 		},
		-- 	},
		-- 	necessary_ui_list={[1]=[[wingview_close_btn]],},
		-- },
	},
	necessary_condition=[[wing_activatable]],
}

PlotSkill={
	complete_type=0,
	before_guide=[[before_PlotSkill_guide]],
	exceptview = {},
	guide_list={
		[1]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.25,y=-0.25,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.12,y=-0.2,},
					play_tween=false,
					text_list={[1]=[[你在主线任务获得的剧情技能点，可用来学习和升级剧情技能。]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[mainmenu_skillbtn]],
				},
			},
			necessary_ui_list={[1]=[[mainmenu_skillbtn]],},
		},
		[2]={
			click_continue=false,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0.15,y=0.2,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.08,y=-0.1,},
					play_tween=false,
					text_list={[1]=[[剧情技能可以制作各种属性的符篆，可为装备增加临时属性。]],},
				},
				[3]={
					effect_type=[[click_ui]],
					offset_pos={x=0,y=0,},
					offset_rotate=0,
					ui_effect=[[Finger]],
					ui_key=[[skill_org_tab_btn]],
				},
			},
			necessary_ui_list={[1]=[[skill_org_tab_btn]],},
		},
		[3]={
			click_continue=true,
			effect_list={
				[1]={
					effect_type=[[texture]],
					fixed_pos={x=0,y=0,},
					flip_y=false,
					play_tween=false,
					texture_name=[[guide_1.png]],
				},
				[2]={
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
					fixed_pos={x=0.07,y=-0.15,},
					play_tween=false,
					text_list={[1]=[[制作符篆要消耗活力，以后不要再浪费活力啦。]],},
					audio_list={[1]=[[Model/xsydy5.mp3]],},
				},
				[3]={
					effect_type=[[red_ui]],
					ui_key=[[skill_guide_widget2]],
				},
				[4]={effect_type=[[focus_ui]],ui_key=[[skill_guide_widget2]],},
			},
			necessary_ui_list={[1]=[[skill_guide_widget2]],},
		},
	},
	necessary_condition=[[PlotSkill_open]],
}
--游戏定义的常量
module(...)
UniqueID = {
	QueryBack = 1,
}

Net = {
	Event_Sockect = 1,
}

Gm = {
	Event = {
		RefreshTime = 1,
		RefreshLastInfo = 2,
		RefreshGmHelpMsg = 3,
		ShowItemId = 4,
	},
}

Time = {
	Event = {
		NextDay = 0,
	}
}

Layer = {
	MapTerrain = 8,
	MapWalker = 9,
	War = 10,
	ModelTexture = 11,
	Hide = 12,
	RoleCreate = 14,
	HudLayer = 15,
	Magic = 16,
}

RoleColor = {
	Protagonist = 0, --主角
	Player = 1, -- 场景玩家
	SceneNPC = 2, -- 场景NPC
	DynamicNPC = 3, -- 动态NPC
	WarFriend = 4, --战斗友方
	WarEnemy = 5, -- 战斗地方
	ORGMember = 6, --帮派竞赛己方
	ORGEnemy = 7, --帮派竞赛敌方
	ORGProtect = 8, --帮派竞赛保护
}

RoleTitle = {
	RoleNomTitle = 0, --玩家普通称谓
	RoleSpeTitle = 1, --玩家特殊称谓
	NPCSpeTitle= 2, --NPC 特殊称号
	NPCNomTitle  = 3, --NPC 普通称号
}
--频道
Channel = {
	World = 1,
	Team = 2,
	Org = 3,
	Current = 4,
	Message = 6,
	Sys = 100,
	Bulletin = 101, --公告
	Help = 102,
	Rumour = 103,

	Ch2Text = {
		[1] = "世界",
		[2] = "队伍",
		[3] = "帮派",
		[4] = "当前",
		[6] = "消息",
		[100] = "系统",
		[101] = "公告",
		[102] = "帮助",
		[103] = "传闻",
	}
}

--保证字典里所有只唯一
CacheKey = {
	War = {
		SpeedControlBox = 1,
		OrderMenuMagicBox = 2,
		AutoMenuMagicBox = 3,
	}
}

Sex = {
	Male = 1,
	Female = 2,
	Desc = {
	[1] = "男",
	[2] = "女"
	}
}

School = {
	Shushan = 1,
	Xingxiuhai = 3,
}


Attr = {
	Event = {
		Change = 1,
		AddPoint = 2,
		GetSecondProp = 3,
		UpdateReward = 4,
		UpdateRankInfo = 5,
		UpdateOrgSkills = 6,
		GetUseOrgSkill = 7,
		UpgradeTouxianInfo = 8,
		UpDateScore = 9,
		Gm = 10,
		AutoMakeDrag = 11,
		RefreshAssistExp = 12,
	},
}

Map = {
	Event = {
		ShowScene = 1,
		EnterScene = 2,
		HeroPartol = 3,
		ClearFootPoint = 4,
		CheckHeroInArena = 5,
		CheckHeroInDance = 6,
		SetGhostEye = 7,
		CheckHeroInWaterPoint = 8,
		UpdateMiniPos = 9,
	},
	AdaptationView = {
		Width = 860,
		Height = 640,
		PointSpac = 2,
	},
	TouchType = {
		Walker = {
			Name = "Walker",
			ID = "0003",
		},
		Terrian0 = {
			Name = "Terrian0",
			ID = "0010",
		},
		Terrian1 = {
			Name = "Terrian1",
			ID = "0005",
		},
		Terrian2 = {
			Name = "Terrian2",
			ID = "0006",
		},
		Terrian3 = {
			Name = "Terrian3",
			ID = "0007",
		},
		Terrian4 = {
			Name = "Terrian4",
			ID = "0008",
		},
		Terrian5 = {
			Name = "Terrian5",
			ID = "0009",
		},
	},
	Speed = {
		Hero = 2.7,
		Player = 2,
		Yunce = 2.7,
	}
}

Skill = {
	Type ={
		SchoolSkill="active",
		PassiveSkill = "passive",
	},
	Event ={
		LoginSkill = 1,
		SchoolRefresh = 2,
		RefreshCultivate = 3,
		RefreshAllCultivate = 4,
		SetCultivate = 5,
		PassiveRefresh = 6,
		RefreshSkillMaxLevel = 7,
		RefreshFuZhuanSkill = 8,
	},
	CultivateType ={
		Role = 1,
		Partner = 2,
	},
	Element = {
		["土"] = 1,
		["水"] = 2,
		["火"] = 3,
		["风"] = 4,
	},
	CultivationNeedItem = {
		Player = 10007,
		Partner = 10008,
	},
	OrgCostType = {
		OrgOffer = 1,
		Silver = 2,
		StoryPoint = 3,
	},
	AuraTips = {
		[1] = 10049,
		[2] = 10050,
		[3] = 10051,
		[4] = 10052,
		[5] = 10053,
		[6] = 10054,
	},
	Text = {
		NotOpenSkill = 3013,
	},
}
--回收系统
Recovery = {
	Event = {
	RecoveryItem = 1,
	RecoverySum = 2,
	}
}


--画舫灯谜
GuessRiddle = {
	HideTopArea = {
		"CForgeMainView",
		"CHorseMainView",
		"CPartnerMainView",
		"CSkillMainView",
		"COrgInfoView",
		"CSystemSettingsMainView",
		"CBadgeView",
		"CItemMainView",
		"CDialogueOptionView",
		"CItemTipsView",
		"CPartnerLinkView",
		"CSummonLinkView",
		"CTaskLinkView",
	},
	Event = {
		RefreshQuesetion = 1,
		ScheduleFinish = 2,
		RefreshState = 3,
		SceneChange = 4,
		RefreshRankInfo = 5,
		RefreshMyInfo = 6,
		AnswerResult = 7,
		RefreshSkillState = 8,
		AdmitSelect = 9,
		RefreshReward = 10,
		HadKickPlayer = 11,
		KickTimer = 12,
		AnchorTimer = 13,
	}
}


Item = {
	Event = { 
		RefreshSpecificItem = 1,
		RefreshBagItem = 2,
		RefreshBagBox = 3,
		RefreshWHData = 4,
		RefreshWHCell  = 5,
		RefreshWHName = 6,
		CheckBagRedDot = 7,
		RefreshEquip = 8,
		RefreshForgeInfo = 9,
		RefreshWashInfo = 10,
		RefreshEquipLast = 11,
		RefreshStrength = 12,
		RefreshStrengthLv = 13,
		AddBagItem = 14,
		AddItem = 15, 
		DelItem = 16,
		ItemAmount = 17,
		QuickUse = 18,
		--临时背包事件
		RefreshTempBagItem = 19,
		LoginTempBag = 20,
		RefreshTempBagAmount = 21,
		RefreshTempBag =22,
		AddItemToTempBag = 220,
		OpenTreasureBox = 23, --宝箱
		QuickBuyItem = 24,	--快捷购买
		RefreshEquipSoulPoint = 25,
		RefreshAttachSoulInfo = 26,
		CurrClickBoxEvent = 27,
		TabSwitch = 28,
		ItemTranfer = 29,
		RefreshAllRefineInfo = 30,
		RefreshRefineInfo = 31,
		RefreshRefineRedPoint = 32,
		UpdateItemInfo = 33,
		ReceiveGoldCoinPrice = 34,
		ShowUIEffect = 35,
		ReceiveQuickBuyPrice = 36,
		ReceiveQuickBuyPriceList = 37,
	},
	Constant = {
		BagFixCount = 25,
		BagLockCount = 10,
		BagItemHand = 100,
		WHFixCount = 25,
		ArrangeCD = 3,
	},
	CellType = {
		BagCell = 1,
		WHCell = 2,
		ModelEquip = 3,
	},
	Quality = {
		White = 0,
		Green = 1,
		Blue = 2,
		Purple = 3,
		Orange = 4
	},
	GainType = {
		NPC = 1,
		MAP = 2,
		TASK = 3,
		UI = 4,
		SCHEDULE = 5,
	},
	GiftType = {
		Random = 1,
		Optional = 2,
	},
	
	GemStoneId = 100000,
	GemStoneAttrId = 1000000,
	HunChangeItem = 11182, --魂石转化
}

Equip = {
	Pos = {
		Weapon = 1,
		Casque = 2,
		Necklace = 3,
		Clothes = 4,
		Belt = 5,
		Shoes = 6,
		Seven = 7,
		Eight = 8,
	},
	PosName = {
		"武器",
		"头盔",
		"项链",
		"衣服",
		"腰带",
		"鞋子",
		"神器",
		"翅膀",
	}
}

Chat = {
	MsgType = {
		Self = 1,
		Others = 2,
		NoSender = 3,
	}, 
	Event = {
		AddMsg = 1,
		PlayAudio = 2,
		EndPlayAudio = 3,
		OrgCall = 4,
		CopyMsg = 5,
		Chuanyin = 6,
		SetChuanyinPos = 7,
	},
	ChatInputArgs = {
		Posx = -122,
		Length = 235,
	},
	FriendInputArgs = {
		Posx = -80,
		Length = 160,
	},
	WishBottleInputArgs = {
		Posx = -202,
		Length = 320,
	},
	AudioTips = {
		VolumeSmall = 1011,
		TimeShort = 1012,
		CouldNotSave = 1013,
		FailRecord = 1014,
	},
}

Talk = {
	Event = {
		AddNotify = 1,
		DelNotify = 2,
		AddMsg = 3,
		AddFriendMsg = 4,
		CopyMsg = 5,
	},
}

Friend = {
	Event = {
		Add = 1,
		Del = 2,
		Update = 3,
		UpdateTeam = 4,
		AddBlack = 5,
		DelBlack = 6,
		DelRecent = 7,
		AddRecent = 8,
		UpdateFriendConfirm = 9,
		NotifyRefuseStrangerMsg = 10,
		RefreshFriendProfileBoth = 11,
	},
	Text = {
		AddBlack1 = 1013,
		AddBlack2 = 1011,
		RemoveBlack = 1016,
		RemoveFriend = 1022,
		TalkIns = 1023,
		FriendIns = 1024,
		TeamIns = 1025,
		BlackIns = 1026,
		AddFriendHello = 1027,
		RelationTips = 1002,
		RecentIns = 1023,
		ChatToBlackTips = 1014,
		SearchFriendNull = 1005,
		AddFriendMaskWord = 1046,
		VerifyFriend = 1044,
		AddVerifyFriendEmpty = 1047,
	},
}

Dialogue = {
	Event = {
		InitOption = 1,
		Dialogue = 2,
	},
	SpecialShape = {
		[3120] = true,
		[6105] = true,
		[2401] = true,
	}
}

Task = {
	Event = {
		RefreshAllTaskBox = 1,
		RefreshSpecificTaskBox = 2,
		AddAceTaskNotify = 3,
		AddTask = 4,
		DelTask = 5,
		RefreshTask = 6,
		TaskCountTime = 7,
		TaskRectEffect = 8,
		EyeCountTime = 9,
		GhostEyeEffectForward = 10,
		GhostEyeEffectReverse = 11,
		RefreshChapterInfo = 12,
		AnimeQteTime = 13,
		AnimeQteFailTime = 14,
		EyeCloseCountTime = 15,
		RedPointNotify = 16,
		TaskSelectCountTime = 17,
		DescRefresh = 18,
		TaskLegendCountTime = 19,
		RefreshExtendTaskUI = 20,
		RefreshXuanShang = 21,
		TaskIntervalNotify = 22,
		LingxiQte = 23,
	},
	-- 任务行为
	TaskType = {
		TASK_INTERACTION = 0,   --互动任务
		TASK_FIND_NPC = 1,		--找人
		TASK_FIND_ITEM = 2,		--找物
		TASK_FIND_SUMMON = 3,	--找宠
		TASK_NPC_FIGHT = 4,		--战斗
		TASK_ANLEI = 5,			--暗雷
		TASK_ITEM_PICK = 6,		--采集
		TASK_ITEM_USE = 7,		--用物
		TASK_UP_GRADE = 8,		--升级
		TASK_CAPTURE = 9,		--捕捉
		TASK_QTE = 10, 			--qte
		TASK_ORG_BROADCAST = 11,--帮派广播
		TASK_LEAD = 12, 		--游戏行为,引导任务相关
	},
	-- 任务大类
	TaskCategory = {
		TEST	= {ID = 1, NAME = "TEST", 			FUNCGROUP = "test"},
		STORY	= {ID = 2, NAME = "STORY",			FUNCGROUP = "story"},
		SIDE	= {ID = 3, NAME = "SIDE",			FUNCGROUP = "side"},
		SHIMEN	= {ID = 4, NAME = "SHIMEN",			FUNCGROUP = "shimen"},
		GHOST	= {ID = 5, NAME = "GHOST",			FUNCGROUP = "ghost"},
		YIBAO	= {ID = 6, NAME = "YIBAO",			FUNCGROUP = "yibao"},
		FUBEN	= {ID = 7, NAME = "FUBEN",			FUNCGROUP = "fuben"},
		SCHOOLPASS = {ID = 8, NAME = "SCHOOLPASS",	FUNCGROUP = "schoolpass"},
		ORG     = {ID = 9, NAME = "ORGTASK",		FUNCGROUP = "orgtask"},
		LINGXI  = {ID = 10,NAME = "LINGXI",			FUNCGROUP = "lingxi"},
		GUESSGAME = {ID = 11,NAME = "GUESSGAME",    FUNCGROUP = "guessgame"},
		JYFUBEN = {ID = 12,NAME = "JYFUBEN",        FUNCGROUP = "jyfuben"},
		LEAD  	= {ID = 13,NAME = "LEAD",			FUNCGROUP = "lead"},
		RUNRING = {ID = 14,NAME = "RUNRING",		FUNCGROUP = "runring"},
		BAOTU  	= {ID = 15,NAME = "BAOTU",			FUNCGROUP = "baotu"},
		XUANSHANG  = {ID = 16,NAME = "XUANSHANG",	FUNCGROUP = "xuanshang"},
		ZHENMO = {ID = 17,NAME = "ZHENMO",	        FUNCGROUP = "zhenmo"},
		IMPERIALEXAM = {ID = 18,NAME = "IMPERIALEXAM",	        FUNCGROUP = "imperialexam"},
		TREASURECONVOY = {ID = 19,NAME = "TREASURECONVOY", 		FUNCGROUP = "treasureconvoy"},
	},
	AceTaskSpecial = {
		SHIMEN = 61001,
		GHOST = 62000,
		BAOTU = 80001,
		RUNRING = 63001,
	},
	AceSchedule = {
		SHIMEN = 1001,
		GHOST = 1004,
		BAOTU = 1028,
		RUNRING = 1030,
		XUANSHANG = 1031,
		ORGTASK = 1008,
	},
	AceTaskColor = {
		Map = "#O%s#n",
		NpcName = "[0081ab]%s[-]",
	},
	SpcTask = {
		GUESSGAME = 622402,	--火眼金睛战斗
		GhostGuide = 30094,
		FubenGuide = 30032,
	},
	Time = {
		MoveDown = 1,
		MoveUp = 1,
		ChapterMaskHideTime = 2,
		ChapterBgStartDelayTime = 4,
		ChapterBgIntervalTime = 2,
		ChapterEndCloseViewDelayTime = 4,
		ChapterBgHideDurationTime = 2,
		ChapterBgHideTime = 1,
		ChapterEndEffectShowDelayTime = 1,

		StoryPartBgHideDurationTime = 1,
		StoryPartBgShowDurationTime = 1,
		StoryPartChapterBoxEffectDurationTime = 1,

		NpcCloseUpBgMoveTime = 1,
		NpcCloseUpShowNameBgDelayTime = 1,
		NpcCloseUpShowDescAndNameDelayTime = 1,
		NpcCloseUpDescDurationTime = 2,
		NpcCloseUpCloseViewDelayTime = 3,

		GhostEyeBoxNum = 0,
		GhostEyeDurationTime = 1,
		GhostEyeCircleDurationTime = 3,
	},
	Pos = {
		ChapterNamePosYFrom = 580,
		ChapterNamePosYTo = 257,
		ChapterDescPosYFrom = -300,
		ChapterDescPosYTo = 175,
	}
}

Team = {
	Event = {
		AddTeam = 1,
		MemberUpdate = 2,
		DelTeam = 3,
		AddApply = 4,
		DelApply = 5,
		ClearApply = 7,
		AddInvite = 8,
		DelInvite = 9,
		ClearInvite = 10,
		NotifyInvite = 11,
		NotifyApply = 12,
		AddTargetTeam = 13,
		NotifyAutoMatch = 14,
		NotifyCountAutoMatch = 15,
		RefreshApply = 16,
		RefreshWarCmd = 17,
		RefreshAppoint = 18,
		RefreshInviteeStatus = 19,
		RefreshFormationPos = 20,
		RefreshCacheCmd = 21,
		RefreshAllInvite = 22,
		RefreshAllApply = 23,
		Reset = 24,
	},
	MemberStatus = {
		Normal = 1,
		Leave = 2,
		Offline = 3,
	},
	NetCmd = {
		Normal = 1,
		Leave = 2,
		ShortLeave = 3,
		SKickOut = 4,
		BackTeam = 5,
		SetLeader = 6,
	},
	WarCmdTarget = {
		Member = 1,
		Enemy = 2,
	}
}


Summon = {
	Event = {
		UpdateSummonInfo = 1,
		DelSummon = 2,
		SetFightId = 3,
		WashSummonAdd = 4,
		AddSummon = 5,
		CombineSummonShow = 6,
		BagItemUpdate = 7,
		GetSummonSecProp = 8,
		SetFollow = 9,
		ChangeSummonShow = 10,
		WashDelSummon = 11,
		UpdateRedPoint = 12,
		--找回丢失的宠物
		RecoverySum = 13,
		SelStudyItem = 14,
		SetCompoundSummon = 15,
		ReceiveGuildInfo = 16,
		AddCkExtendSize = 17,
		AddCKSummon = 18,
		DelCKSummon = 19,
	 	AddExtendSize = 20, --增加携带宠物上限
	 	EquipEditSelItem = 21,
	 	SummonEquipCombine = 22, --装备合成结果
	 	SelBookSummon = 23, --选择图鉴宠物
	 	ShowSummonCloseup = 24,
	},
	Equip = {
		Lace = 1, --项圈
		Arm = 2, --装甲
		Sign = 3, --护符
	},
	Grid = {
		SummonBox = 1, 
		EmptyBox = 2, 
		LockBox = 3, 
	},
	ComposeCost = 11189,
}

Guidance = {
		Event = {
		BagItemUpdate = 1,
		Dialogue = 2,
		TaskUpdate,
	}
}


Currency = {
	Type = {
		Gold = 1,				--金币
		Silver = 2,				--银币
		GoldCoin = 3,			--元宝
		ReGoldCoin = 4,         --绑定元宝
		AnyGoldCoin = 5,        --任意元宝类型
	},
	OtherVirtual = {  --与上面衔接
		BangGong = 4,
		HuoLi = 5, 
		JuQingDian = 6,
	},
}

Schedule = {
	Event = {
		RefreshMainUI = 1,
		RefreshSchedule = 2,
		RefreshWeek = 3,
		RefreshReward = 4,
		RefreshUITip = 5,
		RefreshDouble = 6,
		RefreshHuodong = 7,
		RefreshDayTask = 8,

		ClearEffect = 14,
	},   
	Type = {
		Every = 1,
		Fuben = 2,
		Limit = 3,
		Normal = 4,
		Unopen = 5,
		Forthcoming = 6,
		WeekSchedule = 7,
	},
	
	Sign = {
		ShowNewSign = true,
	}
}

BaiKe = {
	Event = {
			RefreshBaike = 1,
			RefreshBaikeAnswer = 2,
			RefreshBaikeCurrRank = 3,
			RefreshBaikeWeekRank = 4,
			RefreshBaikeEffect= 5,
			RefreshBaikeTime = 6,
		}
	}

Model = {
	Defalut_Figure = 1110,
	Defalut_Shape = 1110,

	COMMON_STATE = {
		[[attack1]],
		[[attack2]],
		[[attack3]],
		[[attack4]],
		[[attack5]],
		[[attack6]],
		[[attack7]],
		[[attack8]],
		[[attack9]],
		[[defend]],
		[[die]],
		[[hit1]],
		[[hit2]],
		[[hitCrit]],
		[[idleCity]],
		[[idleRide]],
		[[idleWar]],
		[[magic]],
		[[run]],
		[[runBack]],
		[[runWar]],
		[[show]],
		[[show2]],
		[[walk]],
		[[dance]],
	},

	WEAPON = {
		[1110] = {mounts = {[1] = [[right_hand]],},},
		[1120] = {mounts = {[1] = [[right_hand]],},},
		[1210] = {mounts = {[1] = [[right_hand]],},},
		[1220] = {mounts = {[1] = [[right_hand]],},},
		[1310] = {mounts = {[1] = [[right_hand]],},},
		[1320] = {mounts = {[1] = [[right_hand]],},},
	}
}

MainMenu = {
	AREA = {
		MinMap = 1,
		Active = 2,
		Buff = 3,
		HeroIcon = 4,
		Task = 5,
		Bag = 6,
		Function_1 = 7,
		Notify= 8,
		Chat = 9,
		Other = 10,
		Bonfire = 11,
		Function_2 = 12,
		Friend = 13,
		Sevice = 14,
		HeroIcon = 15,
		PetIcon = 16,
		QuickMsg = 17,
		ExpandBtn = 18,
		PopBtn = 19,
		HideMenuBtn = 20,
		Guide = 21,
		TempBag =22 ,
		WishBottle = 23,
		OrgMatchBox = 24,
		Temp = 25,
		GuideAlpha = 26,
	},
	HideConfig = {
		SystemUI = {1,2,5,6,7,8,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26},
		Default = {1,2,5,6,7,8,9,10,12,13,14,15,16,17,18,21,22,23,24,25,26},
		OrgMatch = {2,10,21},
	},
	Event = {
		BagIconEffect = 1,
	},
}

Mail = {
	Event = {
		GetDetail = 1,
		OpenMails = 2,
		Sort = 3,
		Opened = 4,
	}
}

Instruction = {
	Config = {
		AttrMainIns = 1000,
		Cultivation = 1001,
		DoublePoint = 1006,--双倍点说明
		AttrSkillQuickMakeIns = 1007, --活力使用说明
		TempBag = 10011, --临时背包说明
		RecoverEqu = 10012,--装备寻回说明
		RecoverPet = 10013,--宠物寻回说明
		Baike = 10015,
		ForgeSoul = 2000,
		ForgeEquip = 2001,
		ForgeStrength = 2002,
		ForgeWash = 2003,
		OrgXuetu = 3001,
		QuitOrg = 3002,
		OrgBuildingUpgrade = 3003,
		Formation = 6001,
		Ghost = 7001,
		JjcMain = 9001,
		JjcGroup = 9002,
		WorldBoss = 10001,
		Sign = 10003,
		Baoshidu = 1003,
		Auction = 10006,
		Yibao = 1004,
		Stall = 10007,
		SkillPoint = 10009,
		OrgBoom = 3005,
		Biwu = 10017,
		SchoolMatch = 10016,
		RedPacket = 10018,
		OrgTask = 10023,
		RoleRanse = 10019,
		Compose = 10025,
		SummonRanse = 10020,
		Lingxi = 10014,
		WaiGuan = 10028,
		OrgMatch = 10029,
		OrgOffer = 10030,
		QuickExChange = 10033,
		ItemRefine =10038, 
		ForgeInlay = 10039,
		Runring = 12001,
		QiFu = 13004,
		Engage = 13005,
		SingleBiwu = 10069,
		DiscountSale = 13014,
		GemStoneCompose = 12003,
		GemStoneMix = 12004,
	},
	View = {
		MaxHeight = 630,
		MinHeight = 130,
		Pixel = 470,
		YLength = 210,
		MinPixel = 160,
	}	
}

Org = {
	Event = {
		GetOrgList = 1,
		GetOrgAim = 2,
		GetAppliedOrg = 3,
		GetRespondOrgList = 4,
		GetRespondOrgInfo = 5,
		GetOrgMainInfo = 6,
		CancelAllOrgApply = 7,
		GetRespondedOrg = 8,
		GetMemberList = 9,
		GetApplyList = 10,
		GetOrgJoinStatus = 11,
		DelApply = 12,
		DelMember = 13,
		ChangePosition = 14,
		DelRespondOrgList = 15,
		CancelAllOrgRespond = 16,
		GetSearchResultList = 17,
		UpdateOneClickApplyCoolDown = 18,
		UpdateRespondOrgCD = 19,
		UpdateOrgRespondNum = 20,
		UpdateOrgRedPoint = 21,
		GetOnlineMemberList = 22,
		UpdateOrgBuildingInfos = 23,
		BuyItemResult = 24,
		UpdateAchieveInfo = 25,
		AddHistoryLog     = 26,
		NextPageLog       = 27,
		UpdateChatBan     = 28,
		OneClickTime = 29,
		UpdateOrgTask = 30,
		GetActivityInfo = 31,
		CleanTaskStar = 32,
		SetAutoAccept = 33,
		UpdatePrestige = 34,
		ReceiveInvite = 35,
	},
	PosUpper = {
		[1] = 1,
		[2] = 1,
		[3] = 4,
		[4] = 10,
		[5] = 4,
		[6] = 1,
	}
}

Partner = {
	Event = {
		AddPartner = 1,
		PropChange = 2,
		UpgradeSkill = 3,
		UpdateAllLineup = 4,
		UpdateLineup = 5,
		RefreshRedPoint = 6,
		RefreshEquipRedPoint = 7,
	},
	Type = {
		"",
	},
	RedPoint = {
		None = 1,
		Upgrade = 2,
		Recruit = 3,
	}
}

Treasure = {
	Event = {
		SliderBroken = 1,
	},
	Time = {
		Total = 2,
		Delta = 0.02,
		PrizeTotal = 4,
		LabelTotal = 2.8,
	},
	Config = {
		Item1 = 11078,
		Item2 = 11079,
		Item3 = 11080,
		Item4 = 11077,
		Item5 = 11076,
	},
	PrizeType = {
		GoldCoin = "金币",
		Silver = "银币",
		Item = "物品道具",
		LittleMonster = "放妖",
		KingMonster = "放妖王",
		Copy = "副本",
	},
	MoneyEffect = {
		Total = 5,
	},
}

Autofind = {
	Type = {
		Treasure = "StartTreasure",
	},
}

Title = {
	Event = {
		UpdateTwoLists = 1,
		UpdateWearingTitle = 2,
		AddTitles = 3,
		DelTitles = 4,
		UpdateTitleInfo = 5,
	},
}

	
Rank = {
	Event = {
		UpdateRankInfo = 1,
		UpdateMeinInfo = 2,
		UpdateMeinUpvote = 3,
		ShowSummonInfo = 4,
		UpdataScore = 5,
		OnUpdateScoreEvent = 6,
	},
	InfoKey = {
		[101]= "grade_rank",
        [106] = "player_score_rank",
        [107] = "role_score_rank",
        [108] = "summon_score_rank",
        [109] = "friend_degree_rank",
        [115] = "biwu_rank",
        [116] = "prestige_rank",
        [117] = "threebiwu_rank",
        [201] = "kaifu_grade_rank",
        [202] = "kaifu_score_rank",
        [203] = "kaifu_summon_rank",
        [204] = "kaifu_org_rank",
        [205] = "score_school_rank",
        [206] = "score_school_rank",
        [207] = "score_school_rank",
        [208] = "score_school_rank",
        [209] = "score_school_rank",
        [210] = "score_school_rank",
        [212] = "resume_goldcoin",
        [213] = "treasure_find",
        [214] = "fuyuan_box",
        [215] = "wash_summon",
        [216] = "make_equip",
        [217] = "send_flower",
        [218] = "kill_monster",
        [219] = "kill_ghost",
        [220] = "strength_equip",
        [221] = "luanshimoying_score_rank",
        [222] = "imperialexam_firststage",
        [223] = "imperialexam_secondstage",
        [225] = "worldcup_rank",
	},
}

Npc = {
	Type = {
		Mojin = 5227,
		JinWanCheng = 5002,
		ZhongKui = 5234,
		YanNanGui = 5257,
		shuxiaoer = 5206,--鼠小二
		XingJiaoShang = 5266, --杂货店
		XingJiaoShang2 = 5273, --杂货店
		ChongWuXianZi = 5274, --宠物商店
		SuXiaoXiao = 5249, --装备商店
		WangLaoShi = 5228, --武器商店
		YaoTuWeng = 5244, --药店
	},

	FunGroup = {
		"task.test",
		"task.story",
		"task.side",
		"task.shimen",
		"task.ghost",
		"task.yibao",
		"task.fuben",
		"task.schoolpass",
		"task.orgtask",
		"task.lingxi",
		"task.guessgame",
		"task.jyfuben",
		"task.lead",

        "huodong.fengyao",
        "huodong.trapmine",
        "huodong.normal",
        "huodong.excellent",
        "huodong.treasure",
        "huodong.devil",
        "huodong.arena",
        "huodong.shootcraps",
        "huodong.dance",
        "huodong.signin",
        "huodong.orgcampfire",
        "huodong.mengzhu",
        "huodong.biwu",
        "huodong.schoolpass",
        "huodong.moneytree",
        "huodong.orgtask",
        "huodong.charge",
        "huodong.bottle",
        "huodong.baike",
        "huodong.liumai",
        "huodong.lingxi",
        "huodong.guessgame",
        "huodong.jyfuben",
	}
}

Formation = {
	Event = {
		UpdateAllFormation = 1,
		UpdateFormationInfo = 2,
		UpdatePosList = 3,
		SetCurrentFormation = 4,
		RefreshGuildStatus = 5,
	},
	Status = {
		None = 1,
		InUse = 2,
		UpgradeAllow = 3,
		LearnAllow = 4,
		NotLearn = 5,
		UnableLearn = 6,
	}
}

Econonmy = {
	Event = {
		RefreshGuildItemList = 1,
		RefreshGuildItem = 2,
		RefreshStallItemList = 3,
		RefreshStallItem = 4,
		RefreshStallSellGrid = 5,
		RefreshAuctionItemList = 6,
		RefreshAuctionItem = 7,
		RefreshAuctionPrice = 8,
		RefreshStallNotify = 9,
		RefreshAuctionNotify = 10,
	},
	Type = {
		Guild = 1,
		Stall = 2,
		Auction = 3,
	},
	StallStatus = {
		None = 0,
		OverTime = 1,
		OnSell = 2,
		SellOut = 3,
	},
	AuctionType = {
		Item = 1,
		Summon = 2,
	},
	AuctionStatus = {
		InPublicity = 1,
		InAuction = 2,
		Unsold = 3,
		WithdrawCash = 4,
		Delete = 5,
		Success = 6
	},
	AuctionBid = {
		Auto = 1,
		NonAuto = 2,
	}
}

Jjc = {
	Event = {
		RefreshJJCMainUI = 1,
		JJCTargetLineup = 2,
		JJCFightLog = 3,
		JJCChallengeChooseRankUI = 4,
		JJCChallengeMainInfoUI = 5,
		JJCChallengeTargetLineup = 6,
		JJCMessageRedPoint = 7,
		JJCMainCountTime = 8,
		JJCMainRefreshCountTime = 9,
	},
	Text = {
		AddCount = 1007,
		AddCountBtn = 1008,
		SpeedTime = 1011,
		SpeedTimeBtn = 1012,
		ChallengeReset = 1002,
		ChallengeResetNoTime = 1003,
		OnlyOneFriend = 1004,
		FullHelp = 1005,
		PrizeNoTime = 1001,
		MainMaxTime = 1018,
		NoMessage = 1019,
		NoBuddy = 1020,
		NoSummon = 1021,
		NoFriend = 1022,
		NoZhenfa = 1024,
		FirstNotGet = 1029,
		FirstHasGet = 1030,
	},
	Time = {
		JJCMainTime = 5,
		MoveIn = 0.55,
		MoveOut = 0.55,
		MoveDown = 0.55,
		MoveUp = 0.55,
	},
	Pos = {
		OutPosX = -650,
		InPosX = 510,
		DownY = 350,	
	},
	PrizeType = {
		Day = 1,
		Month = 2,
		First = 3,
	},
}

Yibao = {
	Event = {
		RefreshUI = 1,
		StarTime = 2,
		ItemTime = 3,
		UpdateMyselfYibaoInfo = 4,
		UpdateMyselfDoneYibao = 5,
		InteractionTime = 6,
		InteractionLightTime = 7,
		InteractionFailTime = 8,
		InteractionFlowerFailTime = 9,
		InteractionCrystalOreFailTime = 10,
	},
	Time = {
		StarHelp = 60,
		ItemHelp = 60,
	},
	Prize = {
		Gold = {1001, "#cur_3"}, --金币
		Silver = {1002, "#cur_4"}, --银币
		GoldCoin = {1003, "#cur_1"}, --元宝
		BindGoldCoin = {1004, "#cur_2"}, --绑定元宝
		PlayerExp = {1005, "#cur_6"}, --人物经验
		ReserveExp = {1006, "#cur_6"}, --储备经验
		SummonExp = {1007, "#cur_6"}, --宠物经验
		BuddyExp = {1008, "#cur_6"}, --伙伴经验
		JjcPoint = {1009, "积分"}, --竞技场积分
		ChallengePoint = {1010, "积分"}, --竞技场挑战积分
		CultivationExp = {1011, "#xiulian"}, --人物修炼经验
		PartnerCultivationExp = {1012, "#xiulian"}, --伙伴修炼经验
		SkillPoint = {1020, "技能点"}, --技能点
	},
	InteractionText = {
		Instruction = 1001,
		Fail = 1002,
		Again = 1003,
	},
	InteractionType = {
		LinkPoint = 1,
		LinkFlower = 2,
		LinkCrystalOre = 3,
		LinkAnyPattern = 4,
		LinkLove = 5,
		LinkPicture = 6,
		LinkDog = 7,
		LinkBall = 8,
		LinkBell = 9,
		LinkHerb = 10,
	},
	InteractionResultType = {
		Yibao = 1,
		Shimen = 2,
		GetBell = 3,
	},
}

System = {
	Cultivation = "XIU_LIAN_SYS",
	Summon = "SUMMON_SYS",
	SummonLy = "SUMMON_LY",
	SummonHc = "SUMMON_HC",
	SummonXc = "SUMMON_XC",
	SummonJn = "SUMMON_JN",
	Forge = "EQUIP_SYS",
	Partner = "PARTNER_SYS",
	PartnerZM = "PARTNER_ZM",
	Skill = "SKILL_SYS",
	Formation = "FMT_SYS",
	Shimen = "SHIMEN",
	Ghost = "ZHUAGUI",
	YaoWang = "YAOWANG",
	FengYao = "FENGYAO",
	Yibao = "YIBAO",
	TianMo = "TIANMO",
	Arena = "LEITAI",
	Stall = "BAITAN",
	Guild = "SHANGHUI",
	Auction = "AUCTION",
	Rank = "RANK_SYS",
	Org = "ORG_SYS",
	CreateOrg = "ORG_CJ",
	JJC = "JJC_SYS",
	OrgSkill = "ORG_SKILL",
	Horse    = "RIDE_SYS",
	Schedule = "SCHEDULE",
	Shop = "SHOP",
	Zhiyin = "ZHIYIN",
	Welfare = "WELFARE",
	Sign = "SIGN",
	UpgradePack = "UPGRADEPACK",
	Improve = "IMPROVE",
	PartnerJJ = "PARTNER_JJ",
	EquipForge = "EQUIP_DZ",
	EquipStrengthen = "EQUIP_QH",
	EquipWash = "EQUIP_XL",
	EquipSoul = "EQUIP_FH",
	EachDayTask = "EACHDAYTASK",
	RedPacket = "REDPACKET",
	GiftGrade = "GIFT_GRADE",
	GiftGrade2 = "GIFT_GRADE2",
	GiftGoldcoin = "GIFT_GOLDCOIN",
	GiftDay = "GIFT_DAY",
	StoreSys301 = "STORE_SYS_301",
	StoreSys302 = "STORE_SYS_302",
	StoreSys303 = "STORE_SYS_303",
	StoreSys304 = "STORE_SYS_304",
	Exchange = "REDEEM_CODE",
	FirstPay = "FIRST_PAY",
	SecondPay = "SECOND_PAY",
	RebateExplain = "REBATE_EXPLAIN",
	JyFuben = "JYFUBEN",
	CollectGift = "WELFARE_COLLECT",
	YoukaLogin = "WELFARE_LOGIN",
	Badge = "BADGE",
	CaiShen = "CAISHEN",
	SkillZD = "SKILL_ZD",
	SkillBD = "SKILL_BD",
	RoleAddPoint = "ROLE_ADDPOINT",
	Vigor = "VIGOR",
	Tiexin = "TIEXIN",
	WuxunStore = "WUXUN_STORE",
	JjcpointStore = "JJCPOINT_STORE",
	ReturnGift = "RETURNGOLDCOIN",
	LeaderPointStore = "LEADER_POINT_STORE",
	XiayiPointStore = "XIAYI_POINT_STORE",
	SummonPointStore = "SUMMON_POINT_STROE",
	ChumoPointStore = "CHUMO_POINT_STORE",
	GradeRank = "GRADE_RANK",
	StrengthRank = "STRENGTH_RANK",
	TitleRank = "TITLE_RANK",
	SummonRank = "SUMMON_RANK",
	OrgRank = "ORG_RANK",
	PayGetReward  = "WELFARE_REBATE",
	PreOpen = "PREOPEN",
	Kaifu = "KAIFUDIANLI",
	ScoreShow = "SCORESHOW",
	EquipInlay = "EQUIP_XQ",
	RideUpgrade = "RIDE_UPGRADE",
	Baotu = "BAOTU",
	Runring = "RUNRING",
	Timelimit = "TIMELIMIT",
	SevenDay = "SEVENDAY",
	OnlineGift = "ONLINE_GIFT",
	XuanShang = "XUANSHANG",
	AccConsume = "DAY_EXPENSE",
	AccCharge = "TOTAL_CHARGE",
	EveryDayCharge = "EVERYDAYCHARGE",
	FightGift = "FIGHT_GIFT",
	ActiveGiftBag = "ACTIVEPOINT_GIFT",
	Talisman = "FUZHUAN",
	Flop = "DRAWCARD",
	Engage = "ENGAGE_SYS",
	HeShenQiFu = "HESHENQIFU",
	EverydayRank = "EVERYDAY_RANK",
	Artifact = "ARTIFACT",
	ContCharge = "CONTINUOUS_CHARGE",
	ContConsume = "CONTINUOUS_EXPENSE",
	YuanBaoJoy = "YUANBAOJOY",
	Wing = "WING",
	MysticalBox = "MYSTICALBOX",
	QingYuan = "QINGYUAN",
	FaBao = "FABAO",
	RebateJoy = "REBATEJOY",
	RideTongYu = "RIDE_TY",
	Zhenmo = "ZHENMO",
	JieBai = "JIEBAI",
	ItemInvest = "ITEMINVEST",
	SpiritGuide = "SPIRITGUIDE",
	Feedback = "FEEDBACK",
	FeedbackInfo = "FEEDBACKINFO",
	ShiZhuang =  "SHIZHUANG",
	DiscountSale = "DISCOUNT_SALE",
	ZeroBuy = "ZEROYUAN",
	Recommend = "RECOMMEND",
	Advance = "ADVANCE",
	ExpRecycle = "RETRIEVE_EXP",
	SoccerWorldCupGuess = "WORLDCUP_SINGLE",
	SoccerTeamSupport = "WORLDCUP_CHAMPION",
	DuanWuQiFu = "DUANWUQIFU",
	ZongZiGame = "ZONGZIGAME",
	ShootCraps = "SHOOTCRAPS",
	SuperRebate = "SUPERREBATE",
	JuBaoPen = "JUBAOPEN",
}

RedPacket = {
	Event = {
		RefreshOrgRedPacket = 1,
		RefreshWorldRedPacket = 2,
		GetRedPacketSuccess = 3,
		GetRedPacketPlayer = 4,
		GetRedPacketSelfRecord = 5,
		RefreshMainUI = 6,
		DeleteRedPacket = 7,
		SysMoneyAdd = 8,
		UpdateSysRedPacket = 9,
	},
	Channel = {
		World = 102,
		Org = 101,
	},
	Text = {
		DefaultName = 1001,
		LimitTip = 1004,
		NoRedPacket = 1009,
		NoWorldRedPacket = 1010,
		NoOrgRedPacket = 1011,
		NoSelfRecord = 1012,
	},
	Convert = {
		GoldCoinToGold = 100,
	}
}

Bonfire = {
	Event = {
		UpdateBonfireExp = 1,
		EndBonfireActive = 2,
		BonfireGetGift	 = 3,
		ShowGiftables    = 4,
		UpdateBonfireAnswer = 5,
		SwitchScene = 6,
		UpdateQuestion = 7,
		GetTanks = 8,
		GiftTimes = 9,
		UpdateLeftTime = 10,
	},
}

Plot = {
	Event = {
		SkipBg = 1,
	},
	Orientation = {
		North = 0,
        NorthEast = 1,
        East = 2,
        SouthEast = 3,
        South = 4,
        SouthWest = 5,
        West = 6,
        NorthWest = 7,
	},
	TweenType = {
		NavMove = 0,
		PosMove = 1,
		Rotate3D = 2,
		Rotate2D = 3,
		Scale = 4,
		Mount = 5
	},
	AudioType = {
		Music = 0,
		Sound = 1,
	}
}

Promote = {
   Event = {
		DelSys = 1,
		UpdateFomation = 2,
		Refresh = 3,
		UpdatePromoteData = 4,
		RedPoint = 5, --提升
		UpdateGrowInfo = 6,
		RefreshGrow = 7,
		RefreshGrowRedPoint = 8,   -- 成长红点

		RefreshSourceUpgroupInfo = 9,
		RefreshSourceSummonInfo = 10,
		RefreshHelpSkillInfo = 11,
		RefreshGameTechInfo = 12,
		RefreshSourceEquipInfo = 13,
		RefreshCamBatSkillInfo = 14,
	},
	Type = {
		Reward = 1,
		Finish = 2,
		ToDoTask = 3,
		}

}

Barrage = {
	OrgItem = 11098,
	Event = {
		BattleBarrage = 1,
		OrgBarrage = 3,
	},
	Text = {
		MaxChar = 1001,
		MaxEmoji = 1002,
		HasMaskWord = 1003,
		ItemTips = 1004,
		NoInput = 1005,
	},
	State = {
		WatchWarOrWar = 1,
		Plot = 2,

	},
}

Horse = {
	Event = {
		AddHorse = 1,
		UpdateRideInfo = 2,
		UseRide = 3,
		UpdateRideSkill = 4,
		HorseAttrChange = 5,
		LearnSk = 6,
		ChooseSkills = 7,
		ResetSkill = 8,
		Upgrade = 9,
	},
}

WorldBoss = {
	Event = {
		RefreshPlayerList = 1,
		RefreshOrgList = 2,
		RefreshEventList = 3,
		RefreshPlunderList = 4,
		RefreshStepStatus = 5,
		RefreshPlunderStatus = 6,
	},
	Status = {
		NotStart = 1,
		Start = 2,
		End = 3
	}
}

SuperRebate = {
	Event = {
		SuperRebateStart = 1,
		SuperRebateEnd = 2,
		RefreshSuperRebateMul = 3,
		RecordList = 4,
		RereshSuperRebateValue = 5,
	}	
}

WelFare = {
	Event = {
	    AddSignInfo = 1,
	    UpdateYuanbaoPnl = 2,
	    UpdateBigProfitPnl = 3,
	    UpdateDailyPnl = 4,
	    UpdateDailyRedDot = 5,
	    UpdateBigProfitTab = 6,
	    UpdateFirstPayRedDot = 7,
	    UpdateRebatePnl = 8,
	    UpdateFirstPayPnl = 9,
	    UpdateCollectPnl = 10,
	    UpdataColorLamp = 11,
	    UpdateCaishenPnl = 12,
	    StartLottery = 13,
	    ReturnGift = 14,
	    UpdateServerTime = 15,
	    UpdataYoukaLoginTime = 17,
	    ReceiveCaishenRecords = 18,
	    UpdateCaishenRedPoint = 19,
	    RefreshFightGift = 20,
	    RefreshSecondPay = 21,
	},
	Status = {
		Unobtainable = 0,
		Get = 1,
		Got = 2,
	},
	Tab = {
	    FightGift = 0, --战力礼包
		YoukaLogin = 1, --八日登陆,原七彩神灯
		FirstPay = 2, --首次充值
		SecondPay = 3, 
		GiftGoldcoin = 4,--元宝大礼
		GiftDay = 5,--每日礼包
		GiftGrade = 6, --一本万利
		Sign = 7, --每日签到
		ReturnGift = 8, --回归豪礼
		UpgradePack = 9, --升级礼包
		OnlineGift = 10, --在线豪礼 
		--FightGift = 11, --兑换码
		Exchange = 12,
		--RebateExplain = 10,  --封测返利
		GiftGrade2 = 13,
		ExpRecycle = 14,
	},
}

Crap = {
	Event = {
			Timer = 1,
			TimerEnd = 2,
		},
	}

Celebration = {
	Event = {
		UpdateTouXianRank = 1,
		UpdateRankReward = 2,
	},
	Tab = {
		GradeRank = 1, --冲级榜
		StrengthRank = 2, --实力榜
		SummonRank = 3, --神宠榜
		TitleRank = 4, --头衔榜		
		OrgRank = 5, --十大帮派
		PayGetReward = 6, --充值返利
	},
	Text = {
		GradeReward = 1001,
		StrengthReward = 1002,
		OrgCntReward = 1003,
		OrgLevelReward = 1004,
		GradeIns = 1005,
		StrengthIns = 1006,
		SummonIns = 1007,
		TitleIns = 1008,
		OrgIns = 1009,
	},
}

FightOutsideBuff = {

	Event = {
	    StateChange = 1
	},
	

}


UpgradePacks = {

	Event = {
	    GetReward = 1,
	    UpgradePacksDataChange = 2
	},

}

EveryDayCharge = {
	Event = {
		EveryDayChargeStart = 1,
		EveryDayChargeChanged = 2,
		EveryDayChargeEnd = 3,
		EveryDayChargeTimeOut = 4,
		EveryDayChargeNotifyRefreshRedPoint = 5,
		EveryDayChargeNotifyChangeDay = 6,
	},
}

MysticalBox = {
	Event = {
		MysticalBoxStart = 1,
		MysticalBoxRefreshMainBtn = 2,
		MysticalBoxRefreshTime = 3,
		MysticalBoxRefreshRedPoint = 4,
		MysticalBoxTimeOut = 5,
		MysticalBoxRefreshEnd = 6,
	},
}

SoccerWorldCupGuess = {
	Event = {
		SoccerWorldCupGuessOpen = 1,
		SoccerWorldCupGuessClose = 2,
		SoccerWorldCupGuessInfoRefresh = 3,
		SoccerWorldCupGuessInfoUnitRefresh = 4,
	},
}

SoccerTeamSupport = {
	Event = {
		SoccerTeamSupportOpen = 1,
		SoccerTeamSupportClose = 2,
		SoccerTeamSupportInfoRefresh = 3,
		SoccerTeamSupportInfoUnitRefresh = 4,
	},
}

ActiveGiftBag = {
	Event = {
		ActiveGiftBagStart = 1,
		ActiveGiftBagInfoChanged = 2,
		ActiveGiftBagSlotChanged = 3,
		ActiveGiftBagEnd = 4,
		ActiveGiftBagTimeOut = 5,
		ActiveGiftBagRefreshRedPoint = 6,
		ActiveGiftBagTotalPointChanged = 7,
	},
}

Login = {
	Event = {
		ShowActor = 1,
		SelectActor = 2,
		ClickRoleCreateModel = 3,
		RoleCreateRandomName = 4,
		ServerListSuccess = 5,
		LineOver = 6,
		UpdateWaitTime = 7,
		UpdateGSRole = 8,
		ShowRoleCreateName = 9,
	},
	Text = {
		UserAgree = 1001,
		SelectSchool = 1002,
		NoName = 1003,
		ShortName = 1004,
		MaskName = 1005,
		SpecialName = 1006,
		NoRole = 1008,
		NoCommendServer = 1009,
	},
	NoticeView = {
		MaxHeight = 630,
		MinHeight = 130,
		Pixel = 470,
		YLength = 210,
		MinPixel = 160,
	},
	RoleCreateAnim = {
		OffsetIdle = "rolecreate1",
		Move = "rolecreate2",
		OriginIdle = "rolecreate3",
		Dance = "rolecreate4",
		Back = "rolecreate5",
	},
}

Dancing = {
	Event = {
	  	DanceStateUpdate = 1,
	  	DanceCount = 2,
    }
}

Sdk = {
	IsDebug = true,

	Event = {
		Init = 1,
		LoginSuccess = 2,
		LoginFail = 3,
		LoginCancel = 4,
		Logout = 5,
		NoExiterProvide = 6,
		Exit = 7,
		Pay = 8,
	},
}

Dungeon = {
	Event = {
		RefreshComfirm = 1,
		RefreshPlayerComfirm = 2,
		FinishComfirm = 3,
		RefreshRewardView = 4,
		ReceiveFubenTask = 5,
		FubenOver = 6,
		ReceiveJyFubenTask = 7,
		JyFubenOver = 8,
		DelFubenTask = 9,
	}
}

SysOpen = {
	Event = {
		Login = 1,
		Change = 2,
		Reposition = 3,
	}
}

Guide = {
	Event = {
		PreOpen = 1,
		State = 2,
	},
	Args = {
		BoxColliderArgs = 1.5,
	},
}

PkAction = {
	Event = {
        updateMatchtime = 1,
        updateInfo = 2,
        MatchEnd = 3,
        PKMatchCountTime = 4,
    }
}

QR = {
	Event = {
        QRSid = 1,
        QRCScanSuccess = 2,
        QRCInvalid = 3,
        QRTimeOut = 4,
    }
}

Flower = {
	Type = {
		Same = 10076,
		NotSame = 10075,
	},
	Text = {
		NoBless = 1031,
		MaskBless = 1032,
	}
}

WishBottle = {
	Event = {
		ReceiveBottle = 1,
		UpdateBottleTime = 2,
	},
}

SchoolMatch = {
	Event = {
		RefreshRankList = 1,
		RefreshMyRank = 2,
		RefreshBattleList = 3,
		RefreshGameStep = 4,
		FinishActivity = 5,
	},
	Step = {
		None = 0,
		PointRace = 1,
		Knockout = 2,
		End = 3,
	}
}

Shop = {
	Event = {
		RefreshShopItem = 1,
		RefreshChargeItem = 2,
		EnterScoreShop = 3,
		RefreshScoreShopItem = 4,
		RefreshShopPoint = 5,
		RefreshNpcShop = 6,
		NpcShopDiscount = 7,
		RemoveLimitRedDot = 8,
	},
}

Ranse = {	
	PartType = {
		hair = 1,
		clothes = 2,
		other = 3,
		pant = 4,
			},
}

Notify = {
	Event = {
		FloatItem = 1,
		Update = 2,
	}
}

WaiGuan = {

	Event = {
	    AllClothesInfo = 1,
	    RefreshClothesInfo = 2,

	},

}

Lingxi = {
	Event = {
		AnswerCount = 1,
		Match = 2,
	}
}

Money = {
	Icon = {
		GoldCoin = "#cur_1",
		Gold = "#cur_3",
		Silver = "#cur_4",
		Exp = "#cur_6",
		BindGoldCoin = "#cur_2",
	}

}

FlyRide = {
	FlyState = {
		Ground = 0,
		Fly = 1,
	},

}

OrgMatch = {
	Event = {
		RefreshOrgMatchList = 1,
		RefreshTeamInfo = 2,
		RefreshPreTime = 3,
		RefreshActionPoint = 4,
		RefreshOrgDetailInfo = 5
	},
	State = {
		Protect = 1005
	}
}

Player = {
--自觉减1
	State = {
		OrgMatchProtect = 0,
		HFDMJinZhongZhao = 1,
	}
}

HeroTrial = {
	Event = {
		UpdateTrialUnit = 1,
		CheckIsFinish = 2,
	}
}

MapWalkerNum = {
	Num = {
		[1] = 5,
		[2] = 10,
		[3] = 20,
	}
}

Performance = {
	Level = {
		default = 0,
		low = 1,
		mid = 2,
		high = 3,
	}
}

Timelimit = {
	-- 标签，val决定顺序
	Tab = {
		EveryDayCharge = 1,
		SevenDay = 2,
		AccConsume = 3,
		AccCharge = 4,
		--CaiShen = 5,
		ActiveGiftBag = 6,
		Flop = 7,
		HeShenQiFu = 8,
		ContCharge = 9,
		ContConsume = 10,
		ItemInvest = 11,
		CollectGift = 12,--限时集字，排最后
	},
	Event = {
		RefreshSevenLogin = 1,
		RefreshRedPoint = 2,
		RefreshAccCharge = 3,
		SevenDayEnd = 4,
		RefreshDayExpense = 5,
		UpdateFlopOpenState = 6,
		UpdateFlopCardTimes = 7,
		UpdateFlopCardList = 8,
		UpdateEverydayRank = 9,
		UpdateFlopShowCardEffect = 10,
		UpdateContCharge = 11,
		EndContCharge = 12,
		UpdateContConsume = 13,
		EndContConsume = 14,
		RefreshDiscountSale = 15,
	},
}

ItemInvest = {
	Event = {
		RefreshItemInvestState = 1,
		RefreshItemInvestUnit = 2,
		RefreshRedPtSpr = 3,
	},
}

OnlineGift = {
	Event = {
		UpdateStatus = 1,
		UpdateAllStatus = 2,
		UpdateRedPoint = 3,
	},
}

GuideNotify = {
	Type = {
		GradeGift10 = "GradeGift10",
		GradeGift20 = "GradeGift20",
		GradeGift30 = "GradeGift30",
		GradeGift40 = "GradeGift40",
		XiuLian = "XiuLian",
		--暂时屏蔽
		-- GetPartner = "GetPartner",
		OrgSkill = "OrgSkill",
		Ride = "Ride",
	},
	Order = {
		"GradeGift10",
		"GradeGift20",
		"GradeGift30",
		"GradeGift40",
		"XiuLian",
		"OrgSkill",
		"Ride",
	},
}

Fly = {
	Event = {
		RequestFly = 1,
	},
	Data = {
		FlyScaleFactor = 1.2,
		HudScaleFactor = 200,
		FlyTime = 0.6,
	}
}

Engage = {
	Event = {
		EngageSuccess = 1,
		EngageFail = 2,
		DissolveEngage = 3,
	    EngageStart = 4,
	    SelectXTPresentPlayer = 5,
	    CancelMarry = 6,
	},
	State = {
		None = 0,
		Engage = 1,
		Marry = 2,
	}
}

ThreeBiwu = {
	Event = {
		BiwuInfo = 1,
		BiwuCountTime = 2,
		BiwuMatch = 3,
		BiwuEndCountTime = 4,
		BiwuRandomPrepare = 5,
		BiwuPrepareCount = 6,
		EndMatch = 7,
	},
}

UIEffect = {
	ForgeEquip = 1,
	ForgeStrength = 2,
	ForgeWash = 3,
	ForgeSoul = 4,
}

AssembleTreasure = {
	Event = {
	RefreshState = 1,
	PlayEffect = 2,
	RefreshSeconds = 3,
	RefreshRank = 4,
	RefreshExtraAndScore = 5,
	TenTimeJuBao = 6,
	}
}

HeShenQiFu = {
	Event = {
		QiFuLottery = 1,
		End = 2,
		QiFuReward = 3,
		Start = 4,
	}
}

OpenUI = {
	Type = {
		Jjc = 3,
		YuanBaoJoy = 4,
	}
}

Artifact = {
	Event = {
		UpdateArtifactInfo = 1,
		UpdateSpiritInfo = 2,
	}
}

QuickBuy = {
	ForgeStrengthen = 1,
	ForgeWash = 2,
	PartnerSkillUpgrade = 3,
	PartnerUpgrade = 4,
	SummonSkillBuy = 5,
	SummonCulture = 6,
	FormationUpgrade = 7,
	WingStar = 8,
	WingLevel = 9,
	ForgeMain = 10,
	SummonWash = 11,
	SummonCompose = 12,
	ForgeAttachSoul = 13,
	WenShiWash = 14,
	PartnerEquipUpgrade = 15,
}

Wing = {
	Event = {
		RefreshWing = 1,
		RefreshTimeWing = 2,
		RefreshWingBtn = 3,
	},
}

YuanBaoJoy = {
	Event = {
		RefreshOpenState = 1,
		RefreshInfo = 2,
		RefreshPrizeEffect = 3,
	},
}

FaBao = {
	Event = {
		RefreshFaBaoInfo = 1,
		RefreshFaBaolist = 2,
		RefrershFaBaoPatch = 3,
	},
	Type = {
		WearFabao = 1,
		Fabao = 2,
		FaBaoPatch = 3,
	},
}
WenShi = {
	Type = {
		red = 1,
		blue = 2,
		yellow = 3,
	},
	Event = {
		Fusion = 1,
	},
}

Master = {
	Event = {
		MentoringTask = 1,
		MentoringStepResult = 2,
		MasterList = 3,
	},
}

RebateJoy = {
	Event = {
		JoyExpenseState = 1,
		JoyExpenseRewardState = 2,
		JoyExpenseGoldCoin = 3,	
		JoyExpenseRedPoint = 4,
		RelGoldCoinGift = 5,
	},
}

SingleBiwu = {
	Event = {
		RefreshBiwuInfo = 1,
		RefreshRankList = 2,
		RefreshMatchResult = 3,
		BiwuCountTime = 4,
		BiwuEndCountTime = 5,
		BiwuInfo = 6,
		BiwuPrepareCount = 7,
	},
	Group = {
		[1] = "风初境",
		[2] = "腾云境",
		[3] = "乾元境",
		[4] = "无相境",
	}
}

JieBai = {
	Event = {
		InviteChange = 1,
		JieBaiInfoChange = 2,
		JieBaiCreate = 3,
		JieBaiRemove = 4,
		JieBaiLogin = 5,
		ViewOnClose = 6,
		ProtoRedPointChange = 7,
	},
	State = {
		BeforeYiShi = 1,
		InYiShi = 2,
		AfterYiShi = 3,
	},
	YiShiState = {
		Open = 0,
		Select = 1,
		SetTitle = 2,
		SetName = 3,
		Drink = 4,
	},	
	RedPoint = {
		KickMember = 1,
	},
}

Examination = {
	Event = {
		RefreshState = 1,
		RefreshResult = 2,
		RefreshCostTime = 3,
	}
}

Spirit = {
	Event = {
		Question = 1,
	}
}

MiBaoConvoy = {
	Event = {
		ConvoyInfo = 1,
		StateChange = 2,
	},
	Type = {
		normal = 1,
		advance = 2,
	},
	State = {
		Prepare = 1,
		Process = 2,
		Finish = 3,
	}
}

DuanWuHuodong = {
	Event = {
		QiFuDataChange = 1,
		MatchDataChange = 2,
		QiFuState = 3,
		MatchState = 4,
	},
	ZongZiType = {
		Sweet = 1,
		Salty = 2,
	}
}

Feedback = {
	Event = {
		RefreshFeedbackInfo = 1,
		RefreshFeedbackRedPt = 2,
		RefreshFeedbackServInfo = 3,
	},
}

ZeroBuy = {
	Event = {
		UpdateInfo = 1,
	},
}

DemiAD = {
	Key = "a23340f482af65fd16b1a5b84148e5a7",
	Url_dev = "https://devapiad.cilugame.com/log",
	Url_release = "https://apiad.demigame.com/log",
}

Res = {
	GC = {
		Auto = 3,
		Force = 10,
	},
	CallGcViews = {
		["CGaideMainView"] = true,
		["CRankListView"] = true,
		["CWelfareView"] = true,
		["CScheduleMainView"] = true,
		["CNpcShopMainView"] = true,
		["CWelfareView"] = true,
		["CCaishenGiftView"] = true,
		["CYuanBaoJoyView"] = true,
		["CEverydayRankView"] = true,
		["CRebateJoyMainView"] = true,
		["CEcononmyMainView"] = true,
		["CTaskMainView"] = true,
		["CTeamMainView"] = false,
		["CSummonMainView"] = true,
		["CAttrMainView"] = true,
		["CBadgeView"] = true,
		["CFaBaoView"] = true,
		["CWingMainView"] = true,
		["CArtifactMainView"] = true,
		["COrgInfoView"] = true,
		["CSkillMainView"] = true,
		["CPartnerMainView"] = true,
		["CHorseMainView"] = true,
		["CForgeMainView"] = true,
		["CJjcMainNewView"] = true,
		["CSystemSettingsMainView"] = true,
		["CJieBaiMainView"] = true,
		["CJieBaiInvitedMainView"] = true,
		["CExaminationMainView"] = true,
		["CFeedbackMainView"] = true,
		["CLingxiAnswerView"] = true,
		["CLingxiPoetryView"] = true,
		["CSummonStoreView"] = true,
		["COrgTaskView"] = true,
		["CPartnerLinkView"] = true,
		["CSchoolMatchBattleListView"] = true,
		["CSchoolMatchRankView"] = true,
		["CSingleBiwuRankView"] = true,
		["CThreeBiwuRankView"] = true,
	},
}

Forge = {
	Event = {
		RefreshInlayRedPoint = 1,
	}
}
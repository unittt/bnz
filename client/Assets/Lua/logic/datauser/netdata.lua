module(..., package.seeall)

BAN = {
	["print"] = {
		["scene"] = {
			["GS2CSyncPos"] = true,
			["GS2CSyncPosQueue"] = true,
			["C2GSSyncPosQueue"] = true,
			["C2GSSyncPos"] = true,
			["GS2CSyncAoi"] = true,
			["GS2CEnterAoi"] = true,
			["GS2CLeaveAoi"] = true,
		},
		["other"] = {
			["GS2CHeartBeat"] = true,
			["C2GSHeartBeat"] = true,
			["GS2CBigPacket"] = true,
			["C2GSBigPacket"] = true,
			["GS2CMergePacket"] = true,
			["GS2CClientUpdateRes"] = true,
		},
		["login"] = {
			["GS2CQueryLogin"] = true,
		},
		["chat"] = {
			["GS2CSysChat"] = true,
		},
		["huodong"] = 
		{
			["GS2CHfdmMyRank"] = true,
			["GS2CHfdmRankInfo"] = true,
		},
	},
	["proto"] = {
		["warend"] = {
			func = function() return g_WarCtrl:IsWar() and not g_WarCtrl:IsPlayRecord() end,
			["scene"] = {
				["GS2CShowScene"] = true,
				["GS2CEnterScene"] = true,
				["GS2CEnterAoi"] = true,
				["GS2CLeaveAoi"] = true,
				["GS2CSyncAoi"] = true,
				["GS2CSyncPos"] = true,
				["GS2CAutoFindPath"] = true,
				["GS2CSceneCreateTeam"] = true,
				["GS2CSceneRemoveTeam"] = true,
				["GS2CSceneUpdateTeam"] = true,
			},
			["notify"] = {
				["GS2CNotify"] = true,
				["GS2CItemNotify"] = true,
			},
			["chat"] = {
				["GS2CConsumeMsg"] = true,
			},
			["item"] = {
				["GS2CItemQuickUse"] = true,
				["GS2CAddItem"] = true,
				["GS2CItemAmount"] = true,
			},
			["jjc"] = {
				["GS2CJJCFightEndInfo"] = true,
				["GS2CChallengeMainInfo"] = true,
			},
			["task"] = {
				["GS2CAddTask"] = true,
				["GS2CDelTask"] = true,
				["GS2CRemoveTaskNpc"] = true,
				["GS2CRemoveTaskFollowNpc"] = true,
				["GS2CRefreshTask"] = true,	
				["GS2CStoryChapterInfo"] = true,
				["GS2CDialog"] = true,
				["GS2CExtendTaskUI"] = true,
				["GS2CExtendTaskUIClose"] = true,
				["GS2COpenShopForTask"] = true,
			},
			["player"] = {
				["GS2CPromote"] = true,
				["GS2CPropChange"] = true,
				["GS2CShowNpcCloseup"] = true,
				["GS2CSetGhostEye"] = true,
			},
			["huodong"] = {
				["GS2CMengzhuPlunderResult"] = true,
				["GS2CMengzhuBossResult"] = true,
				["GS2CBWMyRank"] = true,
				["GS2CBWReward"] = true,
				["GS2CGuessGameDone"] = true,
				["GS2CTrialOpenUI"] = true,
				["GS2CThreeBWEndRank"] = true,
				["GS2CThreeBWMyRank"] = true,
				["GS2COpenOrgTaskUI"] = true,
				["GS2CSingleWarInfo"] = true,
				["GS2CSingleWarFinalRank"] = true,
			},
			["openui"] = {
				["GS2CPlayAnime"] = true,
				["GS2CConfirmUI"] = true,
				["GS2CPlayQte"] = true,
			},
			["state"] = {
				["GS2CAddBaoShi"] = true,
			},
			["sysopen"] = {
				["GS2COpenSysChange"] = true,
			},
			["war"] = {
				["GS2CWarFail"] = true,
			},
		},
		["mapswitch"] = {
			func = function() return g_MapCtrl.m_MapSwitchEffing end,
			["scene"] = {
				["GS2CEnterScene"] = true,
				["GS2CEnterAoi"] = true,
				["GS2CLeaveAoi"] = true,
				["GS2CSyncAoi"] = true,
				["GS2CSyncPos"] = true,
				["GS2CAutoFindPath"] = true,
				["GS2CSceneCreateTeam"] = true,
				["GS2CSceneRemoveTeam"] = true,
				["GS2CSceneUpdateTeam"] = true,
			},
			["notify"] = {
				["GS2CNotify"] = true,
			},
			["chat"] = {
				["GS2CConsumeMsg"] = true,
			},
			["item"] = {
				["GS2CItemQuickUse"] = true,
			},
			["huodong"] = {
			    ["GS2CBWMyRank"] = true,
			    ["GS2CLMMyPoint"] = true,
			},
			["newbieguide"] = {
				["C2GSUpdateNewbieGuideInfo"] = true,
				["C2GSSelectNewbieSummon"] = true,
			}
		},
		["interaction"] = {
			-- ["sysopen"] = {
			-- 	["GS2COpenSysChange"] = true,
			-- },
		},
		["sysnotify"] = {
			-- ["openui"] = {
			-- 	["GS2CPlayQte"] = true,
			-- },
		},
		["auction"] = {
			func = function() return g_EcononmyCtrl.m_AuctionNetCache end,
			["auction"] = {
				["GS2CAuctionPriceChange"] = true,
			}
		},
		["examination"] = {
			func = function() return g_ExaminationCtrl.m_ShowResult end,
			["huodong"] = {
				["GS2CImperialexamGiveQuestion"] = true,
			}	
		}
	}
}

RECORD = {
	war_record = {
		war = {all_flag = true},
		scene = {GS2CShowScene=true},
	}
}

PBKEYS = {
	role = {"grade", "name", "title_list", "goldcoin", "gold", "silver", "exp", "chubeiexp", "max_hp", "max_mp", "hp", "mp", "energy", "physique", "strength", "magic", "endurance", "agility", "phy_attack", "phy_defense", "mag_attack", "mag_defense", "cure_power", "speed", "seal_ratio", "res_seal_ratio", "phy_critical_ratio", "res_phy_critical_ratio", "mag_critical_ratio", "res_mag_critical_ratio", "model_info", "school", "point", "critical_multiple", "gold_over", "silver_over", "followers", "sex", "title_info", "upvote_amount", "achieve", "score", "position", "position_hide", "rename", "org_id", "org_status", "org_offer", "skill_point", "orgname", "icon", "show_id","org_pos","sp", "max_sp", "model_info_changed", "rplgoldcoin", "fly_height", "wuxun", "jjcpoint", "vigor", "leaderpoint", "xiayipoint", "summonpoint", "storypoint", "title_info_changed", "prop_info", "engage_info", "gold_owe", "silver_owe", "goldcoin_owe", "truegoldcoin_owe", "chumopoint"},
	summon = {"id", "typeid", "type", "key", "name", "carrygrade", "grade", "exp", "attribute", "point", "maxaptitude", "curaptitude", "life", "race", "element", "score", "rank", "talent", "skill", "max_hp", "max_mp", "hp", "mp", "basename", "phy_attack", "phy_defense", "mag_attack", "mag_defense", "speed", "grow", "model_info", "traceno", "autoswitch", "freepoint","got_time","summon_score","cycreate_time", "equipinfo", "zhenpin", "speed_unit", "mag_defense_unit", "phy_defense_unit", "mag_attack_unit", "phy_attack_unit", "max_hp_unit", "max_mp_unit","advance_level","bind_ride","use_grow_cnt"},
	NpcAoiBlock = {"name", "model_info", "war_tag", "xunluoid", "title","action"},
	PlayerAoiBlock = {"name", "model_info", "war_tag", "followers", "title_info", "icon", "show_id","dance_tag","touxian_tag","action", "org_id", "state", "fly_height", "engage_pid", "treasureconvoy_tag"},
	WarriorStatus = {"hp", "mp", "max_hp", "max_mp", "model_info", "name", "aura", "status", "auto_perform", "is_auto", "max_sp", "sp", "item_use_cnt1", "item_use_cnt2", "cmd", "school", "grade", "title", "zhenqi"},
	partner = {"id", "sid", "quality", "grade", "name", "exp", "max_hp", "max_mp", "hp", "mp", "physique", "strength", "magic", "endurance", "agility", "phy_attack", "phy_defense", "mag_attack", "mag_defense", "cure_power", "speed", "seal_ratio", "res_seal_ratio", "phy_critical_ratio", "res_phy_critical_ratio", "mag_critical_ratio", "res_mag_critical_ratio", "school", "upper", "type", "race", "model_info", "skill", "equipsid", "score"},
	team = {"name", "model_info", "school", "grade", "status", "hp", "max_hp", "mp", "max_mp", "orgid", "icon", "score"},
	org = {"orgid", "name", "aim", "level", "leaderid", "leadername", "membercnt", "maxmembercnt", "onlinemem", "xuetucnt", "maxxuetucnt", "onlinexuetu", "cash", "boom", "historys", "info", "applyname", "applyschool", "applylefttime", "applypid", "canapplyleader", "leaderschool", "showid", "left_mail_cnt", "left_mail_cd", "left_aim_cd"},
	friend = {"pid", "name", "icon", "grade", "school", "orgid", "orgname", "friend_degree", "relation", "both"},
	OrgFlag = {"has_apply", "apply_leader_pid", "sign_status", "bonus_status", "pos_status", "shop_status"},
	jjcMain = {"rank", "infos", "lineup", "fighttimes", "fightcd", "hasbuy", "top3", "nextseason", "first_gift_status", "refresh_time"},
	jjcChallenge = {"difficulty", "targets", "lineup", "beats", "times"},
	YibaoUI = {"owner", "create_day", "seek_gather_tasks", "seek_gather_max", "done_yibao_info", "doing_yibao_info", "main_yibao_info"},
	horse = {"grade", "exp", "point", "use_ride", "choose_skills", "learn_sk", "skills", "ride_infos", "attrs","score"},
	bonfire = {"state", "drink_buff_adds", "lefttime"},
	equipStength = {"strengthen_info", "master_score"},
	TaskRefresh = {"taskid", "target", "name", "targetdesc", "detaildesc", "isreach", "ext_apply_info", "time"},
	chargeGift = {"gift_day_list","gift_goldcoin_list","gift_grade_list"},
	LingxiInfo = {"taskid", "phase"},
	welfareGift = {"first_pay_gift","rebate_gift","login_gift","new_day_time", "second_pay_gift", "first_pay_gift_second", "first_pay_gift_third", "store_charge_rmb"},
	Artifact = {"id", "exp", "grade", "strength_lv", "strength_exp", "phy_attack", "phy_defense", "mag_attack", "mag_defense", "cure_power", "speed", "seal_ratio", "res_seal_ratio", "phy_critical_ratio", "res_phy_critical_ratio", "mag_critical_ratio", "res_mag_critical_ratio", "score", "fight_spirit", "follow_spirit", "spirit_list", "phy_damage_add", "mag_damage_add", "max_hp", "max_mp"},
	Wing = {"id", "exp", "star", "level", "score", "phy_attack", "phy_defense", "mag_attack", "mag_defense", "cure_power", "speed", "seal_ratio", "res_seal_ratio", "phy_critical_ratio", "res_phy_critical_ratio", "mag_critical_ratio", "res_mag_critical_ratio", "time_wing_list", "show_wing","max_hp","max_mp"},
	XuanShangRefresh = {"tasks", "count"},
	singleBiwu = {"pid", "prepare_time", "start_time", "end_time", "win", "win_seri_max", "war_cnt", "rank", "point", "reward_first", "reward_five", "win_seri_curr", "group_id", "is_match",},
	duanwuQifu = {"starttime", "endtime", "total", "reward_step"},
}

ENKEYS = {
	UpdateNewbieGuide = {guide_links = 1, exdata = 2},
}


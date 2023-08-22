module(..., package.seeall)

select =
{
	bool_type = {
		{true, "是"},
		{false, "否"}
	},
	effect_type = {
		{"texture", "图片"},
		{"dlg", "对话框"},	
		{"focus_ui", "高光按钮"},
		{"focus_pos", "高光位置"},
		{"click_ui", "提示点击按钮"},
		{"notify_ui", "间隔提示(非强制)"},
		{"notify_effect_ui", "环绕特效"}
	},
	ui_key = {
		{"", "不设置"},
		{"default_ui", "默认ui(无效)"},
		{"mainmenu_skillbtn", "主界面技能按钮"},
		{"mainmenu_taskbtn", "主界面任务按钮"},
		{"mainmenu_zhiyin_btn", "主界面指引按钮"},
		{"mainmenu_welfare_btn", "主界面福利按钮"},
		{"mainmenu_schedule_btn", "主界面日程按钮"},
		{"mainmenu_org_btn", "主界面帮派按钮"},
		{"mainmenu_promote_btn", "主界面提升按钮"},
		{"mainmenu_forge_btn", "主界面锻造按钮"},
		{"mainmenu_horse_btn", "主界面坐骑按钮"},
		{"mainmenu_partner_btn", "主界面伙伴按钮"},
		{"skill_eachup_btn", "技能界面主动技能标签页升级按钮"},
		{"skill_close_btn", "技能界面关闭按钮"},
		{"task_btn_10039", "任务引导1点击ui"},
		{"task_btn_10001", "任务引导2点击ui"},
		{"task_btn_10002", "任务引导3点击ui1"},
		{"task_btn_10003", "任务引导3点击ui2"},
		{"task_btn_10004", "任务引导3点击ui3"},
		{"task_btn_10005", "任务引导3点击ui4"},
		{"item_quickuse_btn", "快速使用按钮"},
		{"petview_open_btn", "打开宠物界面按钮"},
		{"petview_close_btn", "宠物界面关闭按钮"},
		{"pet_fight_btn", "宠物出战按钮"},
		{"sign_item1_btn", "签到界面的第一个"},
		{"welfareview_close_btn", "福利界面关闭按钮"},
		{"npcshop_buy_btn", "npc商店购买按钮"},
		{"npcshop_close_btn", "npc商店关闭按钮"},
		{"upgradepack_tab_btn", "福利界面的升级礼包tab"},
		{"upgradepack_item1_reward_btn", "10级升级礼包的领取按钮"},
		{"upgradepack_item2_reward_btn", "20级升级礼包的领取按钮"},
		{"upgradepack_item3_reward_btn", "30级升级礼包的领取按钮"},
		{"upgradepack_item4_reward_btn", "40级升级礼包的领取按钮"},
		{"org_oneclickapply_btn", "帮派一键申请按钮"},
		{"promote_skill_btn", "提升的主动技能按钮"},
		{"equip_qh_tab_btn", "强化tab按钮"},
		{"equip_qh_btn", "点击强化按钮"},
		{"skill_cultivate_tab_btn", "技能修炼tab"},
		{"skill_cultivate_learn_btn", "技能修炼按钮"},
		{"schedule_jjc_join_btn", "日程竞技场参加按钮"},
		{"jjc_item1_challenge_btn", "竞技场挑战按钮1"},
		{"horse_ride_btn", "坐骑骑乘按钮"},
		{"equip_xl_tab_btn", "洗炼tab按钮"},
		{"equip_xl_btn", "点击洗炼按钮"},
		{"preopen_box_btn", "主界面功能预告Box"},
		{"preopen_get_btn", "功能预告界面领取按钮"},
		{"preopen_close_btn", "预告界面关闭按钮"},
		{"partner_recruit_btn", "伙伴界面的招募按钮"},
		{"task_shimen_btn", "师门任务box"},
		{"skill_passive_tab_btn", "技能界面被动技能标签页tab"},
		{"skill_passive_allup_btn", "技能界面被动技能标签页一键升级按钮"},
		{"summon_1002_box_btn", "宠物1002的box"},
		{"forgeview_close_btn", "打造主界面关闭按钮"},
		{"horseview_close_btn", "坐骑主界面关闭按钮"},
		{"jjcview_close_btn", "竞技场界面关闭按钮"},
		{"partnerview_close_btn", "伙伴界面关闭按钮"},
		{"joinorgview_close_btn", "加入帮派界面关闭按钮"},
		{"war_auto_btn", "战斗界面的自动战斗按钮"},
		{"war_magic_btn", "战斗界面的选择技能按钮"},
		{"war_magic_box1_btn", "战斗界面的第一个技能框按钮"},
		{"partner_useitem_btn", "伙伴界面升级和突破按钮"},
		{"partner_advance_btn", "伙伴进阶按钮"},
		{"partnerview_tab_btn", "招募第一个伙伴的标签页"},
		{"partnerview_upgrade_tab", "伙伴进阶的标签页"},
		{"dialogue_nextmsg_btn", "对话的触发按钮"},
		{"joinorgview_emptyrespond_btn", "加入帮派响应按钮"},
		{"ride_selecttab_btn", "要选择坐骑的标签页"},

		{"petview_adjust_btn", "点击炼妖页签"},
		{"petview_compound_btn", "点击合宠功能"},
		{"petview_compoundselectleft_btn", "点击选择第一个加号选择要合成宠物"},
		{"petview_compoundselectright_btn", "点击选择第二个加号选择要合成宠物"},
		{"petview_compoundleftsummon_btn", "点击选择第一个宠物"},
		{"petview_compoundrightsummon_btn", "点击选择第二个宠物"},
		{"petview_compoundokselect_btn", "点击选择宠物界面的确定按钮"},
		{"petview_compoundfinalcomfirm_btn", "点击最终的合成按钮"},

		-- {"draw_wl_card", "武灵卡牌"},
		-- {"draw_wh_card", "武魂卡牌"},
		-- {"drawcard_wl_gain_btn", "武灵抽取按钮"},
		-- {"drawcard_wh_gain_btn", "武魂抽取按钮"},
		-- {"war_order_all",  "指令完成按钮"},
		-- {"close_wl_result", "关闭抽取结果"},
		-- {"yuejian_help_btn", "月见帮助按钮"},
		-- {"pata_monster_texture", "地牢怪物模型"},
		-- {"arena_help_btn", "竞技场帮助按钮"},
	},
	pos_func = {
		{"default_pos", "主界面居中"},
	},
	condition = {
		{"", "不设置"},
		-- {"drawcard_main_show", "抽卡主界面"},
		-- {"drawcard_result_show", "抽卡结果界面"},
	},
}

select_func = 
{
	texture_name = function() 
		local list = IOTools.GetFiles(IOTools.GetGameResPath("/Texture/Guide"), "*.png", true)
		local newList = {}
		for i, sPath in ipairs(list) do
			table.insert(newList, IOTools.GetFileName(sPath, false))
		end
		table.sort(newList)
		return newList
	end,
	ui_effect = function()
		return {"Finger"}
		-- return {"Finger","Finger1","Finger2"}
	end,
	dlg_sprite = function()
		return {"h7_zhiyinkuang"}
		-- return {"h7_zhiyinkuang", "pic_zhiying_ditu_2"}
	end,
	notify_ui_effect = function()
		return {"Rect", "Circu"}
		-- return {"Finger","Finger1","Finger2"}
	end,
}

arg = {}
arg.template = {
	sel_type = {
		key = "sel_type",
		name = "主类型",
		select_update = function ()
			local list = {}
			for k, v in pairs(data_config) do
				table.insert(list, k)
			end
			table.sort(list)
			return list
		end,
		wrap  = function (s)
			return data_config[s].name
		end,
		default = "magic",
		change_refresh = true,
	},
	sel_key = {
		key = "sel_key",
		name = "子类型",
		select_update = function ()
			local oView = CEditorTableView:GetView()
			local list = {}
			for k, v in pairs(data_config[oView.m_UserCache.sel_type].modify_table) do
				table.insert(list, k)
			end
			table.sort(list)
			return list
		end,
		wrap = function(sOri)
			local oView = CEditorTableView:GetView()
			local sNew = data_config[oView.m_UserCache.sel_type].modify_table[sOri].name
			if sNew then
				return sNew
			else
				return sOri
			end
		end,
		change_refresh = true,
	},
}

dict_open = function(sKey, sName, sFunc, sTrigger)
	local d = {
			key = sKey,
			name = sName,
			preview_func = function(dNew)
				CGuideData[sKey] = dNew
				CGuideData.FuncMap[sFunc] = function()
					return true
				end
				g_GuideCtrl:LoginInit({})
				g_GuideCtrl:TriggerCheck(sTrigger)
			end,
	}
	return d
end

dict_view = function (sKey, sName, cls)
	local d = {
				key = sKey,
				name = sName,
				preview_func = function(dNew)
					CGuideData[sKey] = dNew
					cls:CloseView()
					g_GuideCtrl:LoginInit({})
					cls:ShowView()
				end,
			}
	return d
end


data_config = {
	guide ={
		name="新手引导",
		path="/Lua/logic/data/guidedata.lua",
		modify_table = {
			-- War1 = {
			-- 	key = "War1",
			-- 	name = "战斗1",
			-- 	preview_func = function(dNew)
			-- 		g_GuideCtrl:LoginInit({})
			-- 		war_id = warsimulate.war_id
			-- 		CGuideData.War1 = dNew
			-- 		warsimulate.Start(1, 302, 2100, 10001)
			-- 		local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 4, name="test", parid=9001, pos = 2, owner=1, status={auto_skill=50702, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
			-- 		netwar.GS2CWarAddWarrior(t)
			-- 		local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 5, name="test", parid=9002, pos = 5, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
			-- 		netwar.GS2CWarAddWarrior(t)
			-- 		netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
			-- 	end,
			-- },
			-- War2 = {
			-- 	key = "War2",
			-- 	name = "战斗2",
			-- 	preview_func = function(dNew)
			-- 		g_GuideCtrl:LoginInit({})
			-- 		war_id = warsimulate.war_id
			-- 		CGuideData.War2 = dNew
			-- 		warsimulate.Start(1, 302, 2100, 10004)
			-- 		local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {40402, 40402}, wid = 4, name="test", parid=9001, pos = 2, owner=1, status={auto_skill=50702, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
			-- 		netwar.GS2CWarAddWarrior(t)
			-- 		local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 5, name="test", parid=9002, pos = 5, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
			-- 		netwar.GS2CWarAddWarrior(t)
			-- 		local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 6, name="test", parid=9002, pos = 3, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
			-- 		netwar.GS2CWarAddWarrior(t)
			-- 		netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
			-- 	end,
			-- },
			
			-- DrawCard = dict_view("DrawCard", "抽卡", CLuckyDrawView),
			-- YueJian = dict_view("YueJian", "月见幻境", CEndlessPVEView),
			-- Pata = dict_view("Pata", "地牢", CPaTaView),
			-- Arena = dict_view("Arena", "竞技场", CArenaView),
			-- Open_Org = dict_open("Open_Org", "工会开启", "org_open", "grade"),
			-- Open_Pata = dict_open("Open_Pata", "爬塔开启", "pata_open", "grade"),
			-- Open_Arena = dict_open("Open_Arena", "竞技场开启", "arena_open", "grade"),
			-- Open_ZhaoMu = dict_open("Open_ZhaoMu", "招募开启", "luckdraw_open", "grade"),

			Task1 = {
				key = "Task1",
				name = "任务引导1点击",
				preview_func = function(dNew)
					CGuideData["Task1"] = dNew
					CMainMenuView:CloseView()
					CMainMenuView:ShowView()
					-- CGuideData.FuncMap["task1_open"] = function()
					-- 	return true
					-- end
					local taskdata = {detaildesc = "向首席弟子交待师父的命令", name = "交待师命", target = 10201, targetdesc = "和#G金山寺首席#n对话", taskid = 10098, tasktype = 1}
					g_TaskCtrl:GS2CAddTask(taskdata)
					-- CSkillMainView:CloseView()
					if not g_GuideHelpCtrl:CheckHasSelect() then
						table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "notplay")
					end
					g_GuideCtrl:LoginInit({})
					-- CSkillMainView:ShowView()
			end,},
			Task2 = {
				key = "Task2",
				name = "任务引导2点击",
				preview_func = function(dNew)
					CGuideData["Task2"] = dNew
					CMainMenuView:CloseView()
					CMainMenuView:ShowView()
					local taskdata = {detaildesc = "向首席弟子交待师父的命令", name = "交待师命", target = 10201, targetdesc = "和#G金山寺首席#n对话", taskid = 10099, tasktype = 1}
					g_TaskCtrl:GS2CAddTask(taskdata)
					-- CSkillMainView:CloseView()
					if not g_GuideHelpCtrl:CheckHasSelect() then
						table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "notplay")
					end
					g_GuideCtrl:LoginInit({})
					-- CSkillMainView:ShowView()
			end,},		
			EquipGet10 = {
				key = "EquipGet10",
				name = "获得装备",
				preview_func = function(dNew)
					CGuideData["EquipGet10"] = dNew
					CItemQuickUseView:CloseView()
					CGuideData.FuncMap["equipget10_open"] = function()
						return true
					end
					if not g_GuideHelpCtrl:CheckHasSelect() then
						table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "notplay")
					end
					g_GuideCtrl:LoginInit({})
					CItemQuickUseView:ShowView()
			end,},
			SummonGet = {
				key = "SummonGet",
				name = "指引宠物出战",
				preview_func = function(dNew)
					CGuideData["SummonGet"] = dNew
					CMainMenuView:CloseView()
					CGuideData.FuncMap["summonget_open"] = function()
						return true
					end
					g_OpenSysCtrl.m_SysTagList[define.System.Summon] = true
					if not g_GuideHelpCtrl:CheckHasSelect() then
						table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "notplay")
					end
					g_GuideCtrl:LoginInit({})
					CMainMenuView:ShowView()
			end,},
			Zhiyin = {
				key = "Zhiyin",
				name = "主界面指引按钮提示",
				preview_func = function(dNew)
					CGuideData["Zhiyin"] = dNew
					CMainMenuView:CloseView()
					CGuideData.FuncMap["zhiyin_open"] = function()
						return true
					end
					-- g_OpenSysCtrl.m_SysTagList[define.System.Summon] = true
					if not g_GuideHelpCtrl:CheckHasSelect() then
						table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "notplay")
					end
					g_GuideCtrl:LoginInit({})
					g_GuideCtrl:TriggerCheck("grade")
					CMainMenuView:ShowView()
			end,},
			Welfare = {
				key = "Welfare",
				name = "指引点击签到",
				preview_func = function(dNew)
					CGuideData["Welfare"] = dNew
					CMainMenuView:CloseView()
					CGuideData.FuncMap["welfare_open"] = function()
						return true
					end
					-- g_OpenSysCtrl.m_SysTagList[define.System.Summon] = true
					if not g_GuideHelpCtrl:CheckHasSelect() then
						table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "notplay")
					end
					g_GuideCtrl:LoginInit({})
					g_GuideCtrl:TriggerCheck("grade")
					CMainMenuView:ShowView()
			end,},
			TaskFindItem1 = {
				key = "TaskFindItem1",
				name = "指引购买任务物品1",
				},
			TaskFindItem2 = {
				key = "TaskFindItem2",
				name = "指引购买任务物品2",
				},
			UseItem = {
				key = "UseItem",
				name = "使用物品10047",
				},
			UseItem10 = {
				key = "UseItem10",
				name = "使用10级大礼包",
				},
			Skill = {
				key = "Skill",
				name = "技能",
				preview_func = function(dNew)
					CGuideData["Skill"] = dNew
					CMainMenuView:CloseView()
					CGuideData.FuncMap["skill_open"] = function()
						return true
					end
					g_OpenSysCtrl.m_SysTagList[define.System.Skill] = true
					if not g_GuideHelpCtrl:CheckHasSelect() then
						table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "notplay")
					end
					g_GuideCtrl:LoginInit({})
					g_GuideCtrl:TriggerCheck("grade")
					CMainMenuView:ShowView()
			end,},
			UpgradePack = {
				key = "UseItem",
				name = "领取升级礼包",
				},
			Improve = {
				key = "Improve",
				name = "引导提升",
				},
			Org = {
				key = "Org",
				name = "引导帮派",
				},
			GetPartner = {
				key = "GetPartner",
				name = "引导法海伙伴",
				},
			Schedule = {
				key = "Schedule",
				name = "引导日程",
				},
			PreOpen = {
				key = "PreOpen",
				name = "引导功能预告",
				},
			equipqh = {
				key = "equipqh",
				name = "引导强化",
				},
			Jjc = {
				key = "Jjc",
				name = "引导竞技场",
				},
			XiuLian = {
				key = "XiuLian",
				name = "引导修炼",
				},
			Ride = {
				key = "Ride",
				name = "引导坐骑",
				},
			equipxl = {
				key = "equipxl",
				name = "引导洗炼",
				},
			Shimen = {
				key = "Shimen",
				name = "引导师门任务框",
				},
			SummonGet2 = {
				key = "SummonGet2",
				name = "引导笋精1002",
				},
			SummonGet2HasPlay = {
				key = "SummonGet2",
				name = "引导笋精1002(玩过游戏)",
				},
			SkillHasPlay = {
				key = "SummonGet2",
				name = "引导技能升级(玩过游戏)",
				},
			UpgradePackHasPlay = {
				key = "SummonGet2",
				name = "引导升级礼包(玩过游戏)",
				},
			ImproveHasPlay = {
				key = "SummonGet2",
				name = "引导提升(玩过游戏)",
				},
			GetPartnerHasPlay = {
				key = "SummonGet2",
				name = "引导法海(玩过游戏)",
				},
			equipqhHasPlay = {
				key = "SummonGet2",
				name = "引导装备强化(玩过游戏)",
				},
			JjcHasPlay = {
				key = "SummonGet2",
				name = "引导竞技场(玩过游戏)",
				},
			XiuLianHasPlay = {
				key = "SummonGet2",
				name = "引导修炼(玩过游戏)",
				},
			equipxlHasPlay = {
				key = "SummonGet2",
				name = "引导装备洗练(玩过游戏)",
				},
		},
		modify_key = {
			start_condition = {name="触发条件(程序添加)", select_type="condition"},
			continue_condition = {name="继续条件(程序添加)", select_type="condition"},
			ui_key = {name="ui名(程序添加)"},
			pos_func = {name="位置(程序添加)"},
			-- texture_name ={name="图片名(忽略)"},
			guide_list = 
			{
				name="指引列表",
				list_type = true, 
				default_value={
					click_continue=false,
					continue_condition="",
					effect_list={},
					start_condition="",
				},
			},
			click_continue = {name="点击继续(可修改)"},
			effect_list = {
				name="指引效果",
				list_type = true,
				type_arginfo = {
					key = "value_type",
					name = "指引类型",
					select_type = "effect_type",
					default = "???",
				},
			},
			-- near_pos = {name="距离指引位置(可修改)"},
			x = {},
			y = {},
			-- w = {name="宽度"},
			-- h = {name="高度"},
			text_list = {
						name="文字列表(可修改)", 
						list_type = true,
						default_value=" "},
			fixed_pos = {name="固定位置(可修改)"},
			-- ui_effect = {name="指引特效(忽略)"},
			notify_ui_effect = {name="环绕特效(可修改)"},
			play_tween = {name="显示动画(可修改)"},
			-- dlg_sprite = {name="对话框图(忽略)"},
			-- flip_y = {name="y轴翻转(忽略)"},
			-- guide_key = {},
			effect_type = {name="类型(不可修改)", wrap="effect_type"},
			offset_pos = {name = "特效偏移距离(可修改)"},
			offset_rotate = {name = "特效旋转(可修改)"},
			pixel = {name = "显示宽高(可修改)"},
		},
		value_default = {
			["texture"] = {
					fixed_pos={x=0, y=0,},					
					play_tween=true,
					flip_y=false,
					texture_name=[[guide_1.png]],
					effect_type=[[texture]],
				},
			["dlg"]={					
					fixed_pos={x=0, y=0,},
					play_tween=true,
					text_list={
					},
					dlg_sprite=[[h7_zhiyinkuang]],
					effect_type=[[dlg]],
				},
			["focus_ui"]={offset_pos={x=0,y=0}, offset_rotate = 0, ui_key=[[default_ui]], ui_effect=[[Finger]], effect_type=[[focus_ui]]},
			["focus_pos"]={pixel = {x=0.07, y=0.12}, offset_pos={x=0,y=0}, offset_rotate = 0, pos_func=[[default_pos]], ui_effect=[[Finger]], effect_type=[[focus_pos]]},
			["click_ui"]={offset_pos={x=0,y=0}, offset_rotate = 0, ui_key=[[default_ui]], ui_effect=[[Finger]], effect_type=[[click_ui]]},
			["notify_ui"]={ui_key=[[default_ui]], ui_effect=[[FingerInterval]], effect_type=[[notify_ui]]},
			["notify_effect_ui"]={offset_pos={x=0,y=0}, ui_key=[[default_ui]], notify_ui_effect=[[Rect]], effect_type=[[notify_effect_ui]]}
		},
		before_dump = function(t)
			for _, dGuide in ipairs(t.guide_list) do
				local list = {}
				for _, dEffect in ipairs(dGuide.effect_list) do
					for k, v in pairs(dEffect) do
						if k == "ui_key" then
							if not table.index(list, v) then
								table.insert(list, v)
							end
						end
					end
					dEffect.guide_key = nil
				end
				dGuide.necessary_ui_list = list
			end
		end
	}
}
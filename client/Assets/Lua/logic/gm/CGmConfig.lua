
local CGmConfig = {}

--[==[
@{
	name = Tab名称
	btnInfo = {
		Btn名称, 自定义参数(空格分隔), 调用方法(xxx)
	}
}
]==]

CGmConfig.gmConfig = {
	

	   {
	    name = "常用指令",
		btnInfo = {
		    {name = "添加物品",param = "$clone 10001 1"},
			{name = "查找道具ID", param = "name",fun = "#findItemIdByName"},
			{name = "设置等级", param = "$playerop 101 {grade = 60}"},
			{name = "增加队伍人数", param = "teamop 101 {size = 5}"},
			
			{name = "增加经验", param = "$rewardexp 10000"},
			{name = "增加银币", param = "$addsilver 99999999"},
			{name = "增加金币", param = "$addgold 99999999"},
			{name = "增加元宝", param = "$addgoldcoin 99999999"},

			{name = "清空背包", param = "$clearall"},
			{name = "清空银币", param = "$cleansilver"},
			{name = "清空金币", param = "$cleangold"},
			{name = "清空元宝", param = "$cleangoldcoin"},

			{name = "开启所有背包", param = "$AddExtend2MaxSize"},
			{name = "银币负债", param = "resumesilver 10000 0"},
			{name = "金币负债", param = "resumegold 10000 0"},
			{name = "通用元宝负债", param = "resumegoldcoin 10000 0"},

			{name = "增加技能经验", param = "$clone 1020 999999"},
			{name = "增加剧情技能点", param = "$addstorypoint 999999"},
			{name = "增加活力值", param = "$setenergy 1000"},
			{name = "非绑元宝负债", param = "resumetruegoldcoin 10000 0"},

			{name = "系统全开+永无引导", param = "tester 3"},
			{name = "恢复引导", param = "tester 0"},
			{name = "清空临时背包", param = "playerop 501"},
			{name = "", param = ""},

			{name = "永久在线", param = "setofflinetime 1"},
			{name = "立刻下线", param = "setofflinetime 4"},
			{name = "极品账号", param = "toprole"},

			
			-- {name = "永无引导", param = "tester 1"},
			-- {name = "系统全开", param = "tester 2"},
			-- {name = "查看引导设置", param = "tester -1"},
			
		}
	
	},
	   {
	    name = "战斗指令",
		btnInfo = {
		    {name = "战斗模拟", param = "$warsimulate",fun = "OnWarSimulate"},
			{name = "战斗结束", param = "$warend"},
			{name = "打开战斗打印", param = "$openwardebug"},
			{name = "关闭战斗信息", param = "$closewardebug"},
			
			{name = "增加怒气", param = "$setwarattr sp 150"},
			{name = "增加灵气", param = "$addaura"},
			{name = "记录消息频道", param="", fun = "#opensysmessage"},
			{name = "关闭记录消息", param="", fun = "#closesysmessage"},
			
			{name = "设置生命", param = "setwarattr max_hp 999999"},
			{name = "设置法力", param = "setwarattr max_mp 999999"},
			{name = "设置物攻", param = "setwarattr phy_attack 999999"},
			{name = "设置法攻", param = "setwarattr mag_attack 999999"},
			
			{name = "设置物防", param = "setwarattr phy_defense 999999"},
			{name = "设置法防", param = "setwarattr mag_defense 999999"},
			{name = "获得技能", param = "setperform 9009 5"},
			{name = "遗忘技能", param = "setperform 9009"},
			
			{name = "主线战斗", param = "fight story 11001"},
			{name = "支线战斗", param = "fight side 10011"},
			{name = "加buff", param = "addbuff 101 5"},
			{name = "挑战玩家", param = "huodongop trial 106 {玩家id}"},
		}
	},

	   {
	    name = "总指令集",
		btnInfo = {
		    {name = "角色相关",param = "playerop 100"},
		    {name = "充值",param = "huodongop charge 100"},
		    {name = "签到系统",param = "huodongop signin 100"},
		    {name = "开服庆典",param = "huodongop kaifudianli 100"},

		    {name = "红包系统",param = "redpacket 100"},
		    {name = "擂台系统",param = "huodongop arena 100"},
			{name = "欢乐骰子",param = "huodongop shootcraps 100"},
			{name = "全民答题",param = "huodongop baike 100"},

			{name = "帮派封魔",param = "huodongop mengzhu 100"},
		    {name = "帮派竞赛",param = "huodongop orgwar 100"},
			{name = "门派试练",param = "huodongop schoolpass 100"},
			{name = "三界斗法",param = "huodongop biwu 100"},
			{name = "金玉满堂", param = "huodongop moneytree 100"},
			{name = "六脉比武",param = "huodongop liumai 100"},
		    {name = "封妖",param = "huodongop fengyao 100"},
			{name = "地煞星",param = "huodongop devil 100"},
			{name = "精英副本",param = "huodongop jyfuben 100"},

			{name = "祝福瓶",param = "huodongop bottle 100"},
			{name = "英雄试炼",param = "huodongop trial 100"},
			{name = "七星好礼",param = "huodongop sevenlogin 100"},
			{name = "开服典礼",param = "huodongop kaifudianli 100"},

			{name = "每日充值",param = "huodongop everydaycharge 100"},
			{name = "热门活动公告", param = "hottopicop 100 "},
			{name = "师徒系统", param = "mentoring 100 "},
			{name = "乱世魔影", param = "huodongop luanshimoying 100"},
			
			{name = "蜀山论道", param = "huodongop singlewar 100"},
			{name = "科举答题", param = "huodongop imperialexam 100"},
			{name = "道具投资", param = "huodongop iteminvest 100"},
			{name = "结拜系统", param = "huodongop jiebai 100"},
			
		}
	
	},
		{
	    name = "拍卖系统",
		btnInfo = {
			{name = "取消所有拍卖",param = "auction_over_all"},
			{name = "结束某拍品",param = "auction_over id"},
			{name = "立即上架某个道具",param = "auction_item id"},
		
		}
	},
	
	   {
		name = "任务指令",
		btnInfo = {
		    
			--{name = "[ff0000]任务基础：", param = ""},
			{name = "添加任务", param = "$addtask 0 113"},
			{name = "清空任务", param = "$cleartask"},
			--{name = "添加可接任务", param = "$newacceptable 40001"},
			{name = "完成任务", param = "doneatask 0 "},
			{name = "查看当前任务", param = "listalltask"},

			--{name = "删除可接任务", param = "$delacceptable 40001"},
			--{name = "完成主线章节", param = "$chapterop full 1"},
			--{name = "重置章节数据", param = "$chapterop reset"},
			--{name = "[ff0000]师门任务：", param = ""},
			{name = "完成师门", param = "doneashimen"},
			{name = "完成主线", param = "doneatask"},
			{name = "设置师门环数", param = "$shimenday 1"},
			{name = "设置师门周次", param = "$shimenweek 1"},
			{name = "开启所有系统", param = "skipopenchecktask 1"},
			-- {name = "清除当前指引", param = "$cleargotsrec newbie"},
			-- {name = "开启新手引导", param = "$opennewbieguide 1"},

			{name = "恢复引导", param = "tester 0"},
			{name = "永无引导", param = "tester 1"},
            {name = "系统全开", param = "tester 2"},
			{name = "系统全开+永无引导", param = "tester 3"},

			{name = "查看引导设置", param = "tester -1"},
			{name = "清空镇魔塔数据", param = "zhenmo 0 103"},
			{name = "清除开放系统", param = "$cleargotsrec sysopened"},
			{name = "刷新升级礼包", param = "$cleargotsrec gradegift"},

			{name = "设置跑环环数", param = "runring 0 set_ring {ring=100}"},
			{name = "跑环参数查看", param = "runring 0 set_times"},

		}
	},
	   {
	    name = "宠伙伴骑",
		btnInfo = {
		    {name = "[ff0000]宠物指令：", param = ""},
			{name = "获得宠物", param = "$givesummon 1000 0"},
			{name = "增加经验", param = "$addsummonexp 1000"},
			{name = "清空宠物", param = "$dropallsummon"},
			
			{name = "一键珍品", param = "washsepsummon 1003"},
			{name = "参战宠加技能", param = "$addsumskill 5101"},
			{name = "参战宠清技能", param = "$clearsumskill"},
			{name = "设置气血", param = "setsumhp 100"},
			
			{name = "[ff0000]伙伴指令：", param = ""},
			{name = "获得伙伴", param = "$addpartner 10001"},
			{name = "增加经验", param = "$addpartnerexp 10001 100"},
			{name = "", param = ""},
			
			{name = "[ff0000]坐骑指令：", param = ""},
			{name = "获得坐骑", param = "$addride 1003"},
			{name = "清空坐骑", param = "clearride"},
			{name = "设置时限", param = "$setrideexpire 1001 30"},
			
			{name = "增加经验", param = "rideexp 10000"},
			{name = "获得技能", param = "addrideskill 5900 1"},
			{name = "清空技能", param = "clearrideskill"},
			{name = "设置纹饰耐久", param = "setwenshilast 1001 1 30"},

			{name = "背包纹饰耐久", param = "itemop 102 {pos=,last=}"},

		
		}
	},
	   {
	    name = "帮派指令",
		btnInfo = {
		    {name = "创建帮派", param = "$orgcreate"},
			{name = "响应帮派", param = "$orgresponse"},
			{name = "建筑加速", param = "$quickorgbuild  101 36000"},
			{name = "帮派刷天", param = "$orgnewhour 5"},
			{name = "帮派刷周", param = "$orgnewhour 5 1"},
			
			{name = "增加帮贡", param = "$addorgoffer 1000"},
			{name = "增加活跃", param = "$addorghuoyue 值(不加自己的相关活跃)"},
			{name = "增加威望", param = "$addorgprestige 1000"},
			{name = "增加成员", param = "$orgsettest membercnt 10"},
			{name = "增加学徒", param = "$orgsettest xuetucnt 10"},
			{name = "帮派资金", param = "$addorgcash 99999999"},
			{name = "帮派繁荣", param = "$addorgboom 值"},
			
			{name = "成员离线时间", param = "$setorgmemberlogouttime pid 天"},
			{name = "设置荒芜天数", param = "$setboomhwdays 20"},
			{name = "成员马上自荐", param = "$setorgleaderlogouttime 1"},
			{name = "成员自荐成功", param = "$orgapplyleadersuccess"},
			
		}
	
	
	},
		{
	    name = "帮派竞赛",
		btnInfo = {
		    {name = "查看指令11", param = "huodongop orgwar 100"},
			{name = "刷新时间", param = "huodongop orgwar 107"},
			{name = "周一20点", param = "huodongop orgwar 106 {month=12,day=25,hour=20,min=0,sec=0}"},
			{name = "周二20:29", param = "huodongop orgwar 106 {month=12,day=26,hour=20,min=29,sec=50}"},
			{name = "周二20:59", param = "huodongop orgwar 106 {month=12,day=26,hour=20,min=59,sec=40}"},
			{name = "周二21:09", param = "huodongop orgwar 106 {month=12,day=26,hour=21,min=9,sec=40}"},
			{name = "周二22:29", param = "huodongop orgwar 106 {month=12,day=26,hour=22,min=29,sec=50}"},
			{name = "周四20:29", param = "huodongop orgwar 106 {month=12,day=28,hour=20,min=29,sec=50}"},
			{name = "周四21:00", param = "huodongop orgwar 106 {month=12,day=28,hour=21,min=0,sec=0}"},
			{name = "周四21:09", param = "huodongop orgwar 106 {month=12,day=28,hour=21,min=10,sec=0}"},
			{name = "周四23", param = "huodongop orgwar 106 {month=12,day=28,hour=23,min=0,sec=0}"},
			{name = "查看时间", param = "huodongop orgwar 110"},
			{name = "清离帮时间", param = "huodongop orgwar 112"},
			{name = "帮战结束", param = "huodongop orgwar 108"},

		}
	},

	{
	    name = "道具装备",
		btnInfo = {
		    {name = "获得特技装备", param = "clone 装备ID 数量 {sk_ratio=100, equip_make=1}"},
			{name = "获得特效装备", param = "clone 装备ID 数量 {se_ratio=100, equip_make=1}"},
			{name = "耐久度修改", param = "modifyitemlast 物品id -10"},
			{name = "查看装备评分", param = "playerop 202 {pos=位置}"},
			
			{name = "绑定道具", param = "itemop 101 {pos = 1}"},
			{name = "清空道具回收", param = "playerop 502"},
			{name = "清空宠物回收", param = "playerop 503"},
			{name = "获得魂石", param = "$clone 11169 1 {grade = 1}"},

			{name = "[082e54]神器系统：", param = ""},
			{name = "升级经验", param = "playerop 701 {exp=1000}"},
			{name = "强化经验", param = "playerop 702 {exp=1000}"},
			{name = "加技能", param = "playerop 703 {sk=9501,level=0}"},

			{name = "清空技能", param = "playerop 703 {}"},
		
		}
	
	},

	   {
	    name = "角色面板",
		btnInfo = {
		    {name = "[082e54]徽章指令：", param = "playerop 100"},
			{name = "设置玩家评分", param = "playerop 102 {score=100000}"},
			{name = "重置玩家评分", param = "playerop 102"},
			{name = "加境界丹", param = "$clone 11143 100"},
			
			{name = "[082e54]称谓指令：", param = ""},
			{name = "获得称谓", param = "$addtitle 1001"},
			{name = "删除称谓", param = "$deltitle 1000"},
			{name = "", param = ""},
			
			{name = "[082e54]评分指令：", param = "playerop 100"},
			{name = "查看角色评分", param = "playerop 201"},
			{name = "查看宠物评分", param = "summonop 101"},
			{name = "查看伙伴评分", param = "partnerop 101"},
			
			{name = "查看坐骑评分", param = "rideop 101"},
			{name = "查看装备评分", param = "playerop 202 {pos=位置}"},
			{name = "背包装备评分", param = "playerop 202 {bag=格子ID}"},
			{name = "查看指引评分", param = "playerop 203"},
			
			{name = "设置名字", param = "$setname '名字'"},
			{name = "打印属性", param = "printfirstattr"},
		
		}
	},

	   {
	    name = "结婚系统",
		btnInfo = {
		    {name = "临时配置", param = "setmarryconfig can_divorce_time 0"},
			{name = "清空临时配置", param = "clearmarryconfig"},
			{name = "查看临时配置", param = "getmarryconfig"},			
		}
	},
	
		
	   {
	    name = "日常活动",
		btnInfo = {
		    {name = "[ff0000]日常封妖：", param = "huodongop fengyao 100"},
			{name = "刷新小妖", param = "huodongop fengyao 101"},
			{name = "刷新妖王", param = "huodongop fengyao 102"},
			{name = "刷妖王数量限制", param = "huodongop fengyao 103 {limit = 数量}"},
			
			{name = "", param = ""},
			{name = "清除奖励限制", param = "huodongop fengyao 104"},
			{name = "查看封妖分布", param = "huodongop fengyao 105"},
			{name = "", param = ""},
			
			{name = "[ff0000]百战天魔：", param = "huodongop devil 100"},
			{name = "刷新天魔", param = "huodongop devil 102"},
			{name = "天魔刷天", param = "huodongop devil 101"},
			{name = "清除奖励限制", param = "huodongop devil 103"},
			
			{name = "", param = ""},
			{name = "额外奖励随机范围", param = "huodongop devil 104 {rand = 1000}"},
			{name = "查看天魔分布", param = "huodongop devil 105"},
			{name = "", param = ""},			
			
			{name = "[ff0000]竞技场：", param = ""},
			{name = "挑战排名X", param = "$jjcfightrank 1"},
			{name = "重置机器人", param = "$jjcrestart"},
			{name = "重置购买次数", param = "clearjjcbuytimes"},
			
			{name = "每日奖励", param = "jjcdayreward"},
			{name = "重置赛季", param = "newjjcseason"},
			{name = "无限抓鬼", param = "ghostrun 1"},
		}
	},

		   {
	    name = "日常二",
		btnInfo = {
		    {name = "[ff0000]六道百科：", param = "huodongop baike 100"},
			{name = "开启活动", param = "huodongop baike 101"},
			{name = "结束活动", param = "huodongop baike 102"},
			{name = "重置答题次数", param = "huodongop baike 103"},
			
			{name = "[ff0000]日程操作：", param = ""},
			{name = "日程刷天", param = "clearsche 0 'd'"},
			{name = "日程刷周", param = "clearsche 0 'w'"},
			{name = "完成某个id每日任务", param = "everydaytask done {id=15}"},
			
			{name = "重置异宝收集", param = "$yibaonew 1"},
			{name = "28星宿", param = "huodongop xingxiu 100"},
			
		}
	},
	
	   {
	    name = "周常活动",
		btnInfo = {
		    {name = "[082e54]三界斗法：", param = "huodongop biwu 100"},
		    {name = "开始进场", param = "huodongop biwu 101"},
			{name = "活动开始", param = "huodongop biwu 102"},
			{name = "活动结束", param = "huodongop biwu 103"},
			
			{name = "活动结束：专用1", param = "huodongop biwu 104"},
			{name = "活动结束：专用2", param = "huodongop biwu 105"},
			{name = "设置积分", param = "huodongop biwu 106 {point = 1000}"},
			{name = "机器人", param = "huodongop biwu 201"},
			
			{name = "设置连胜次数", param = "huodongop biwu 108 {maxwin = 5}"},	
			{name = "清除连胜次数", param = "huodongop biwu 107"},
			{name = "设置失败次数", param = "huodongop biwu 110 {fail = 5}"},
			{name = "清除失败次数", param = "huodongop biwu 109"},
			
			
			{name = "[082e54]门派试练：", param = "huodongop schoolpass 100"},
			{name = "活动准备", param = "$huodongop schoolpass 201"},
			{name = "活动开启", param = "$huodongop schoolpass 202"},
			{name = "活动结束", param = "$huodongop schoolpass 203"},
			
			{name = "", param = ""},
			{name = "NPC退场", param = "$huodongop schoolpass 204"},
			{name = "成绩公告", param = "$huodongop schoolpass 301"},
			{name = "打印排名", param = "$huodongop schoolpass 305"},
			
			{name = "", param = ""},
			{name = "模拟奖励发放", param = "$huodongop schoolpass 302"},
			{name = "设置奖励次数", param = "$huodongop schoolpass 306 {time = 次数}"},
			{name = "查询奖励次数", param = "$huodongop schoolpass 304"},
			
		}
	},
	
	   {
	    name = "周常二",
		btnInfo = {
		    {name = "[082e54]六脉比武：", param = "huodongop liumai 100"},
			{name = "活动准备", param = "$huodongop liumai 101"},
			{name = "积分赛开始", param = "$huodongop liumai 102"},
			{name = "淘汰赛开始", param = "$huodongop liumai 103"},
			
			{name = "淘汰赛结束", param = "$huodongop liumai 104"},
			{name = "活动结束", param = "$huodongop liumai 105"},
			{name = "清空失败次数", param = "$huodongop liumai 106"},
			{name = "清空胜利次数", param = "$huodongop liumai 107"},
			
			{name = "设置积分", param = "$huodongop liumai 108 {score = 100}"},
			{name = "门派造型：自身", param = "$huodongop liumai 109"},
			{name = "门派造型：还原", param = "$huodongop liumai 110"},
			{name = "机器人", param = "huodongop liumai 201"},
			
		    
		}
	},	
	
	
	   {
	    name = "帮派活动",
		btnInfo = {
		    {name = "[082e54]帮派篝火：", param = ""},
			{name = "开启活动", param = "$campfiresetup 10 10 300"},
			{name = "关闭活动", param = "$campfirestop"},
			{name = "", param = ""},
			
			{name = "[082e54]帮派封魔：", param = "huodongop mengzhu 100"},
			{name = "开启活动", param = "huodongop mengzhu 101"},
			{name = "关闭活动", param = "huodongop mengzhu 109"},
			{name = "设置积分", param = "huodongop mengzhu 104 {1000}"},
			
			{name = "", param = ""},
			{name = "重置积分", param = "huodongop mengzhu 301"},
			{name = "波询战斗", param = "huodongop mengzhu 102"},
			{name = "设置个人排名", param = "huodongop mengzhu 112 {1}"},
			
			{name = "", param = ""},
			{name = "设置帮派排名", param = "huodongop mengzhu 111 {1}"},
			{name = "设置参与人数", param = "huodongop mengzhu 113 {1}"}, 
			{name = "", param = ""},
			
		}
	},

	   {
	    name = "灵犀任务",
		btnInfo = {
		    {name = "寻路到红娘", param = "$huodongop lingxi pate"},
			{name = "灵犀周常完成次数+1", param = "$huodongop lingxi sche {add=1}"},
			{name = "显示当前灵犀周常完成次数", param = "$huodongop lingxi sche {get=1}"},
			{name = "显示当前灵犀周常是否满次数", param = "$huodongop lingxi sche {full=1}"},
			
			{name = "随机事件锁定为指定qte类型", param = "$huodongop lingxi qte {type='worm'}"},
		}
	},

	   {
	    name = "福利充值",
		btnInfo = {
		    {name = "[082e54]每日签到：", param = "huodongop signin 100"},
			{name = "补签次数", param = "$huodongop signin 102"},
			{name = "重置签到", param = "$huodongop signin 101"},
			{name = "清除当日补签", param = "$huodongop signin 103"},
			{name = "增加抽奖次数", param = "$huodongop signin 104"},
			{name = "随机运势", param = "$huodongop signin 105"},
			{name = "清除所有签到进度", param = "$huodongop signin 106"},
			{name = "", param = ""},
			{name = "经验+5%", param = "$huodongop signin 105 {1002}"},
			{name = "银币+10%", param = "$huodongop signin 105 {1003}"},
			{name = "师门经验+10%", param = "$huodongop signin 105 {1004}"},
			{name = "抓鬼经验+10%", param = "$huodongop signin 105 {1003}"},

			{name = "[082e54]充值指令：", param = "huodongop charge 100"},
			{name = "模拟充值", param = "huodongop charge 401 {类型id}"},
			{name = "每日礼包1", param = "huodongop charge 101"},
			{name = "每日礼包3", param = "huodongop charge 102"},
			
			{name = "每日礼包6", param = "huodongop charge 103"},
			{name = "每日礼包60", param = "huodongop charge 104"},
			{name = "8元宝大礼", param = "huodongop charge 201"},
			{name = "25元宝大礼", param = "huodongop charge 202"},
			
			{name = "领取元宝大礼", param = "huodongop charge 203"},
			{name = "离线发放元宝大礼", param = "huodongop charge 204"},
			{name = "刷天", param = "huodongop charge 205"},
			{name = "68一本万利", param = "huodongop charge 301"},
			
			{name = "98一本万利", param = "huodongop charge 302"},
			{name = "领取等级元宝", param = "huodongop charge 303 {类型，等级}"},
			
			
		
		}
	},

	{
	    name = "开服庆典",
		btnInfo = {
		    {name = "刷新开服排行榜", param = "huodongop kaifudianli 101"},
			{name = "清空头衔榜单", param = "huodongop kaifudianli 102"},
			{name = "清空帮派信息", param = "huodongop kaifudianli 103"},
			{name = "清空帮派分奖励标志", param = "huodongop kaifudianli 104"},	
		}
	
	},

	{
	    name = "积分商店",
		btnInfo = {
		    {name = "奖励武勋", param = "rewardwuxun 999999"},
			{name = "奖励竞技场积分", param = "rewardjjcpoint 999999"},
		}
	},
	
	{
	    name = "九州争霸",
		btnInfo = {
		    {name = "开始进场", param = "huodongop threebiwu 101"},
			{name = "活动开始", param = "huodongop threebiwu 102"},
			{name = "活动结束", param = "huodongop threebiwu 103"},
		}
	},			
	
	{
	    name = "红包系统",
		btnInfo = {
		    {name = "总指令", param = "redpacket 100"},
			{name = "生成红包", param = "redpacket 201{count=10,goldcoin = 100,channel = 102}"},
			{name = "发放系统红包", param = "redpacket 202{id = 1003}"},
			{name = "删除所有红包", param = "redpacket 205"},
			
			{name = "查看所有红包", param = "redpacket 101"},
			{name = "世界频道红包", param = "redpacket 102"},
			{name = "帮派系统红包", param = "redpacket 301 {index = 1003}"},
		}
	},
	
	   {
	    name = "擂台指令",
		btnInfo = {
		    {name = "总指令", param = "huodongop arena 100"},
			{name = "刷天", param = "huodongop arena 102"},
			{name = "清除对战信息", param = "huodongop arena 101"},
			{name = "查看积分", param = "huodongop arena 103"},
			
			{name = "设置刷榜积分", param = "huodongop arena 106"},
			{name = "当前boss信息", param = "huodongop arena 104"},
			{name = "昨日boss信息", param = "huodongop arena 105"},
			
		}
	},
	
		{
		name = "运营活动",
		btnInfo = {
			{name = "每日累消帮助", param = "huodongop dayexpense 100"},
			{name = "开启活动", param = "huodongop dayexpense 104"},
			{name = "关闭活动", param = "huodongop dayexpense 105"},
			{name = "查询日消", param = "huodongop dayexpense 101"},
			{name = "增加日消", param = "huodongop dayexpense 102 {value = 500}"},
			{name = "选择奖励物品", param = "huodongop dayexpense 108 {reward_key = 1,grid = 3,option = 2}"},
			{name = "领取奖励", param = "huodongop dayexpense 106 {reward_key = 1}"},
			{name = "邮件发送奖励",param = "huodongop dayexpense 107"},
			{name = "查询活动ID", param = "huodongop dayexpense 109"},
			
			{name = "财神送礼帮助", param = "huodongop caishen 100"},
			{name = "模拟领取", param = "huodongop caishen 101"},
			{name = "清空玩家数据", param = "huodongop caishen 102"},
			{name = "玩家重新登录", param = "huodongop caishen 103"},
			{name = "运营开启活动", param = "huodongop caishen 104"},
			{name = "运营关闭活动", param = "huodongop caishen 105"},
			{name = "活动id", param = "huodongop caishen 106"},
			
			{name = "活跃礼包帮助", param = "huodongop activepoint 100"},
			{name = "开启活动", param = "huodongop activepoint 104"},
			{name = "关闭活动", param = "huodongop activepoint 105"},
			{name = "增加玩家活跃", param = "huodongop activepoint 101"},
			{name = "清空玩家活跃", param = "huodongop activepoint 102"},
			{name = "查看玩家活跃", param = "huodongop activepoint 103"},
			{name = "设置格子选项", param = "huodongop activepoint 109 {point_key = 1, grid = 3, option = 2}"},
			{name = "领取奖励", param = "huodongop activepoint 106 {point_key = 1}"},
			{name = "元宝领取", param = "huodongop activepoint 108 {point_key = 1}"},
			{name = "状态可领取", param = "huodongop activepoint 111 {point_key = 1}"},
			{name = "活动id",param = "huodongop activepoint 110"},
			{name = "", param = ""},
			{name = "超级返利", param = "huodongop superrebate 100"},
			{name = "累计充值", param = "huodongop totalcharge 100"},
			{name = "单次充值", param = "huodongop everydaycharge 100"},
			{name = "聚宝盆", param = "huodongop jubaopen 100"},
			{name = "疯狂翻牌", param = "huodongop drawcard 100"},
			{name = "河神祈福", param = "huodongop qifu 100"},
			{name = "每日冲榜", param = "huodongop everydayrank 100"},
			{name = "连环充值", param = "huodongop continuouscharge 100"},
			{name = "连环消费", param = "huodongop continuousexpense 100"},
			{name = "元宝狂欢", param = "huodongop goldcoinparty 100"},
			{name = "元宝狂欢开始", param = "huodongop goldcoinparty 101 {day=7}"},
			{name = "元宝狂欢结束", param = "huodongop goldcoinparty 102"},
			

		}
	},
		
	   {
	    name = "战外BUFF",
		btnInfo = {
		    {name = "设置饱食场数", param = "setstate 1003 count 10"},
            {name = "设置装备耐久", param = "modifyitemlast 1 -99"},
            {name = "设置双倍点数", param = "playerop 301 {point = 120}"},
		
		}
	},
	
	   {
	    name = "排行邮箱",
		btnInfo = {

		    {name = "[082e54]排行榜：", param = ""},
		    {name = "刷天", param = "playerop 402"},
            {name = "推送总评分", param = "playerop 401"},
			{name = "推送角色评分", param = "playerop 404"},

			{name = "推送宠物评分", param = "playerop 405"},
			{name = "清除排行榜", param = "playerop 406 {idx = 101}"},
			{name = "刷周", param = "ranknewweek"},
			{name = "魅力刷周", param = "clearweekctrl"},

			{name = "[082e54]邮箱测试：", param = ""},
			{name = "添加邮件", param = "$sendmail 2 1 {{sid=10001,cnt=1}} {} 1"},
			{name = "清空（需重登）", param = "$clearmail"},
		}
	 
	
	},
	
	   {
	    name = "造型相关",
		btnInfo = {
		    {name = "更换造型", param = "$setshape 1"},
			{name = "造型动作测试", param = "", fun = "#ShowWalkerView"},
			{name = "变蜀山", param = "$setschool 1"},
			{name = "变金山寺", param = "$setschool 2"},
			
			{name = "变太初", param = "$setschool 3"},
			{name = "变瑶池", param = "$setschool 4"},
			{name = "变青城山", param = "$setschool 5"},
			{name = "变妖神宫", param = "$setschool 6"},
			
			{name = "清空玩家染色时装", param = "playerop 510"},
			{name = "清空宠物染色", param = "playerop 511"},
		
		}
	},	
	
	   {
	    name = "SDK指令",
		btnInfo = {
		    {name = "登录", param = "", fun = "#SDKLogin"},
            {name = "登出", param = "", fun = "#SDKLogout"},
            {name = "切换", param = "", fun = "#SDKSwitchAccount"},
            {name = "退出", param = "", fun = "#SDKOnExiter"},
		
		}
	
	},
	
	
	   {
	    name = "系统设置",
		btnInfo = {
		    {name = "获取在线人数", param = "$getonlinecnt"},
			{name = "设置排队人数", param = "$setonlinelimit 1000"},
			{name = "触发存盘", param = "$savedb"},
			{name = "添加开服天数", param = "$addopenday"},

			{name = "设置开服天数", param = "$setopenday"},
			{name = "刷天5点", param = "$cleardaymorning"},
			{name = "刷天0点", param = "$cleardayctrl"},
			{name = "刷周5点", param = "$clearweekmorning"},

			{name = "刷周0点", param = "$clearweekctrl"},
			{name = "调时间重启", param = "date_reboot \"2018-04-18 4:57\""},
		}
	},
	
	   {
	    name = "本地修改",
		btnInfo = {
		    {name = "GM开关", param = "", fun = "#SetGMBtnActive"},
			{name = "加速移动", param = "10", fun = "HeroSpeed"},
			{name = "队伍跟随", param = "", fun = "#teamfollow"},
			{name = "心跳", param = "", fun = "#Beat 5"},
			
			{name = "敏感字测试", param = "", fun = "TestMaskWord"},
			{name = "剧情测试", param = "", fun = "#OpenPlot 1"},
			{name = "婚礼测试", param = "", fun = "#TestWedding"},
			{name = "输出日志", param = "name",fun = "#openLogConsole"},
			{name = "关闭日志", param = "name",fun = "#closeLogConsole"},
			
			{name = "记录消息频道", param="", fun = "#opensysmessage"},
			{name = "关闭记录消息", param="", fun = "#closesysmessage"},
			{name = "清空本地记录", param="", fun = "#clearsysmessage"},
		
			{name = "关闭延迟", param="", fun = "#closeProtoDelay"},
			{name = "开启延迟", param="", fun = "#openProtoDelay"},
			{name = "跳到固定地图", param = "$map 101000 20 20"},
			{name = "奖励测试", param = "checkrewardformula"},
			{name = "显示坐骑", param="", fun = "#ShowRide"},
			{name = "隐藏坐骑", param="", fun = "#HideRide"},
			{name = "显示翅膀", param="", fun = "#ShowSwing"},
			{name = "隐藏翅膀", param="", fun = "#HideSwing"},
			{name = "动作预加载", param="", fun = "#preload"},
		}
	},
	{
		name = "程序指令",
		btnInfo = {
			{name = "解压data包", param = "", fun = "#DumpLuaDataFile"},
			{name = "更新法术文件", param = "", fun = "#UpdateMagicFile"},
			{name = "本地更新", param = "", fun = "#LocalUpdate"},
			{name = "战斗Log", param = "", fun = "#WarLogConsole"},
			{name = "模拟客户端登录", param = "", fun = "#clientlogin"},
			{name = "请求客户端重登", param = "", fun = "#clientrelogin"},
			{name = "玩家移速快", param = "10", fun = "HeroSpeed"},
			{name = "模型测试", param = "", fun = "#shape 3143"},
			{name = "跟随", param = "", fun = "#teamfollow"},

			{name = "敏感字测试", param = "", fun = "TestMaskWord"},
			{name = "syncpos", param = "", fun = "#printsyncpos"},
			{name = "巡逻", param = "", fun = "#xunluo"},
			{name = "心跳", param = "", fun = "#Beat 5"},
			{name = "坐骑|1N 2F 3D", param = "", fun = "#horse 1"},
			{name = "语音测试", param="", fun = "#testspeech"},
			{name = "模拟收到语音", param="", fun = "#playerspeech 1"},
			{name = "开启记录消息频道", param="", fun = "#opensysmessage"},
			{name = "关闭记录消息频道", param="", fun = "#closesysmessage"},
			{name = "OpenNetTimeMS", param="", fun = "#OpenNetTimeMS"},
			{name = "CloseNetTimeMS", param="", fun = "#CloseNetTimeMS"},
			{name = "清空本地消息频道记录", param="", fun = "#clearsysmessage"},
			{name = "获取徽章信息", param="", fun = "#getbadgeinfo"},

			{name = "内存Before", param="", fun = "#consoleMemoryBefore"},
			{name = "内存After", param="", fun = "#consoleMemoryAfter"},
			{name = "Lua内存", param="", fun = "#openLuaMemory"},
			{name = "Lua内存关闭", param="", fun = "#closeLuaMemory"},
			{name = "打开Stats", param="", fun = "#openStats"},
			{name = "关闭Stats", param="", fun = "#closeStats"},
			{name = "开启位置同步", param="", fun = "#startSyncPos"},
			{name = "停止位置同步", param="", fun = "#stopSyncPos"},
			{name = "停止加删人", param="", fun = "#stopAoiWalker"},
			{name = "设置同屏数量", param="", fun = "#setSameScreenCnt"},
			{name = "进入跨服服务器", param="", fun = "#enterKs"},
			{name = "从跨服返回", param="", fun = "#backGs"},
		}
	},

	{
		name = "做号专用",
		btnInfo = {
			{name = "克隆账号", param = "clonerole 10001"},
			{name = "克隆道具", param = "copyotheritem 10001"},
			{name = "完成任务", param = "donekindtask 1"},
			{name = "活动奖励", param = "hdreward singlewar 1001"},
		}
	},
	
}
-- [[测试测按]]
CGmConfig.testConfig = {
	{name = "测试测按1", param = "参数1", fun = "OnTest1"},
	{name = "测试测按2", param = "参数1", fun = "OnTest2"},
	{name = "测试测按3", param = "参数1", fun = "OnTest3"},
}
return CGmConfig



module(..., package.seeall)

--GS2C--

function GS2CArenaFighterList(pbdata)
	local team = pbdata.team --1.队伍 2.单人(无队伍的个人 和 暂离)
	local singlelist = pbdata.singlelist
	local teamlist = pbdata.teamlist
	--todo
	local oView = CArenaMainView:GetView()
	if oView then
		oView:SetPlayerInfos(singlelist, teamlist, team == 1)
	end
end

function GS2CArenaNameList(pbdata)
	local lst = pbdata.lst
	--todo
	local oView = CArenaMainView:GetView()
	if oView then
		oView:SetWitnessList(lst)
	end
end

function GS2CArenaFightEnd(pbdata)
	local pid = pbdata.pid
	--todo
	local oView = CArenaMainView:GetView()
	if oView then
		oView:DeletePlayer(pid)
	end
end

function GS2CShootCrapOpen(pbdata)
	local maxcount = pbdata.maxcount
	local count = pbdata.count
	local goldcoincnt = pbdata.goldcoincnt
	local sixcnt = pbdata.sixcnt
	--todo
	g_CrapsCtrl:GS2CShootCrapOpen(pbdata)
end

function GS2CShootCrapUpdate(pbdata)
	local maxcount = pbdata.maxcount
	local count = pbdata.count
	local goldcoincnt = pbdata.goldcoincnt
	local sixcnt = pbdata.sixcnt
	local sixlitemlist = pbdata.sixlitemlist
	--todo
	g_CrapsCtrl:GS2CShootCrapUpdate(pbdata)
	
end

function GS2CShootCrapEnd(pbdata)
	local point_lst = pbdata.point_lst
	local flowerid = pbdata.flowerid
	local sixcnt = pbdata.sixcnt
	--todo
	g_CrapsCtrl:GS2CShootCrapEnd(pbdata)
end

function GS2CDanceStart(pbdata)
	local lefttime = pbdata.lefttime
	--todo
	--printc("舞会开始---剩余时间",lefttime)
	g_DancingCtrl:GS2CDanceStart(lefttime)
end

function GS2CDanceEnd(pbdata)
	--todo
	--printc("舞会结束")
	g_DancingCtrl:DancingOver()
end

function GS2CDanceActiveStart(pbdata)
	local active = pbdata.active
	--todo
	--printc("动感时刻开始",active) 
	local oView = CDancingActivityView:GetView()
	if oView then
	   oView:ShowUI(false)
	   oView:RefreshHappyUI(active)
	end
end

function GS2CDanceActiveEnd(pbdata)
	--todo
	--printc("动感时刻结束") 
	local oView = CDancingActivityView:GetView()
	if oView then
	   oView:ShowUI(true)
	end
end

function GS2CDanceLeftCnt(pbdata)
	local leftcnt = pbdata.leftcnt
	--todo
	g_DancingCtrl:GS2CDanceLeftCnt(leftcnt)
end

function GS2CDanceActive(pbdata)
	local active = pbdata.active
	--todo
	--printc("动感值",active) 
	local oView = CDancingActivityView:GetView()
	if oView then
	   oView:RefreshHappyUI(active)
	end
end

function GS2CDanceDoubleReward(pbdata)
	local exp = pbdata.exp
	local double = pbdata.double --1.暴击 0.非暴击
	--todo
	g_DancingCtrl:GS2CDanceDoubleReward(pbdata)
end

function GS2CCampfireQuestion(pbdata)
	local id = pbdata.id --题目id（暂时用于answer校验）
	local type = pbdata.type --类型（1、2=选择(1=定选项,2=变动选项)，3=填空）
	local choices = pbdata.choices --选项
	local time = pbdata.time --剩余秒数
	local cur_round = pbdata.cur_round --当前轮次
	local total_round = pbdata.total_round --总轮次
	--todo
	g_BonfireCtrl:GS2CCampfireQuestion(pbdata)
end

function GS2CCampfireQuestionState(pbdata)
	local cur_round = pbdata.cur_round --当前轮次（0=未开始，正整数=当前轮次）
	local total_round = pbdata.total_round --总轮次
	local answered = pbdata.answered --是否答过
	local state = pbdata.state --状态（1=就绪、2=开启、3=关闭）
	local correct_cnt = pbdata.correct_cnt --答对过数量
	--todo
	g_BonfireCtrl:GS2CCampfireQuestionState(pbdata)
end

function GS2CCampfireCorrectAnswer(pbdata)
	local id = pbdata.id --题目id（暂时用于answer校验）
	local answer = pbdata.answer --答案序号
	local iscorrect = pbdata.iscorrect --是否正确
	local correct_cnt = pbdata.correct_cnt --答对过数量
	--todo
	g_BonfireCtrl:GS2CCampfireCorrectAnswer(pbdata)
end

function GS2CCampfireInfo(pbdata)
	local mask = pbdata.mask
	local state = pbdata.state --状态(1=准备就绪,2=开启,3=关闭)，服务端有个活动准备阶段，客户端是看不到的
	local drink_buff_adds = pbdata.drink_buff_adds --喝酒收益加成百分比
	local lefttime = pbdata.lefttime --剩余时间(负数表示没有)
	--todo
	g_BonfireCtrl:GS2CCampfireInfo(pbdata)
end

function GS2CCampfirePreOpen(pbdata)
	local time = pbdata.time --等待秒数
	--todo
	g_BonfireCtrl:GS2CCampfirePreOpen(time)
end

function GS2CCampfireGotGift(pbdata)
	local fromer = pbdata.fromer --来自角色pid
	local fromer_name = pbdata.fromer_name --来自角色名字
	local exp = pbdata.exp --获得的经验
	--todo
	g_BonfireCtrl:GS2CCampfireGotGift(pbdata)
end

function GS2CCampfireShowGiftables(pbdata)
	local players = pbdata.players
	--todo
	g_BonfireCtrl:GS2CCampfireShowGiftables(pbdata)
end

function GS2CCampfireGiftTimes(pbdata)
	local given_times = pbdata.given_times
	local give_times_limit = pbdata.give_times_limit
	local received_times = pbdata.received_times
	local receive_times_limit = pbdata.receive_times_limit
	--todo
	g_BonfireCtrl:GS2CCampfireGiftTimes(pbdata)
end

function GS2CCampfireInHuodongScene(pbdata)
	local is_in = pbdata.is_in --是否在活动场景:活动state与此标记执行bool'&'操作表示UI需要出现，state为关闭时也会收到is_in为true(活动结束后此协议毋须收到，理解为当前场景变为非活动场景)
	--todo
	g_BonfireCtrl:GS2CCampfireInHuodongScene(is_in)
end

function GS2CCampfireThankGift(pbdata)
	local thanker = pbdata.thanker --答谢者（收礼方）pid
	local thanker_name = pbdata.thanker_name --答谢者（收礼方）名字
	--todo
	g_BonfireCtrl:GS2CCampfireThankGift(thanker, thanker_name)
end

function GS2CSignInOpenUI(pbdata)
	--todo
	-- if g_GuideCtrl:IsGuideDone() and not (g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("sumshow") and not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("sumselect")) then
	-- 	g_SignCtrl:ShowSignView()
	-- end
	g_HotTopicCtrl.m_SignCallback = g_SignCtrl.ShowSignView
	Utils.AddTimer(function ()
		if not g_HotTopicCtrl:IsHotTopicOpen() and not g_RecommendCtrl:IsRecommendOpen() then
		--if #g_HotTopicCtrl.m_HuodongList == 0 then
			if g_EngageCtrl.m_EngageStatus then
				return
			end
			g_HotTopicCtrl:m_SignCallback()
			g_HotTopicCtrl.m_SignCallback = nil
		elseif not g_EngageCtrl.m_EngageStatus then
			if #g_HotTopicCtrl.m_HuodongList > 0 then
				return 
			end
			g_HotTopicCtrl:m_SignCallback()
			g_HotTopicCtrl.m_SignCallback = nil
		end
	end, 0, 0.5)

end

function GS2CSignInMainInfo(pbdata)
	local extrasignincnt = pbdata.extrasignincnt --可补签次数
	local rewardset = pbdata.rewardset --签到奖励集合
	local fortune = pbdata.fortune --没有默认为0
	local lottery = pbdata.lottery --抽奖次数
	local today = pbdata.today --当天签到情况
	local signincnt = pbdata.signincnt --已签到个数
	local firstmonth = pbdata.firstmonth --签到的首月 首月 1
	--todo

	g_SignCtrl:GS2CSetSignInfo(pbdata)
	g_LotteryCtrl:GS2CLotteryCount(lottery)

end

function GS2CMengzhuOpenPlayerRank(pbdata)
	local player_list = pbdata.player_list --个人积分
	local my_rank = pbdata.my_rank --我的排名
	local my_point = pbdata.my_point --我的积分
	local boss_time = pbdata.boss_time --挑战波旬时间
	local plunder_time = pbdata.plunder_time --掠夺积分时间
	local game_start_time = pbdata.game_start_time --活动开启时间
	--todo
	g_WorldBossCtrl:SetCDTime(boss_time, plunder_time)
	g_WorldBossCtrl:SetBossStartTime(game_start_time)
	g_WorldBossCtrl:SetPlayerRankList(player_list, my_rank, my_point)
end

function GS2CMengzhuOpenOrgRank(pbdata)
	local org_list = pbdata.org_list --帮派积分
	local my_rank = pbdata.my_rank --当前帮派排名
	local my_point = pbdata.my_point --当前帮派积分
	local total = pbdata.total --参与人数
	local chairman = pbdata.chairman --帮主名
	local boss_time = pbdata.boss_time --挑战波旬时间
	local plunder_time = pbdata.plunder_time --掠夺积分时间
	--todo
	if g_WorldBossCtrl.m_BossStartTime <= g_TimeCtrl:GetTimeS() then
		g_WorldBossCtrl:SetCDTime(boss_time, plunder_time)
	end
	g_WorldBossCtrl:SetOrgRankList(org_list, my_rank, my_point, total, chairman)
end

function GS2CMengzhuOpenPlunder(pbdata)
	local player_list = pbdata.player_list --掠夺列表
	--todo
	g_WorldBossCtrl:SetPlunderList(player_list)
end

function GS2CMengzhuEventList(pbdata)
	local event_list = pbdata.event_list --战况事件
	--todo
	g_WorldBossCtrl:SetEventList(event_list)
end

function GS2CMengzhuGameStart(pbdata)
	local ret_time = pbdata.ret_time --剩余时间(单位秒)
	--todo
	-- local info ={
	-- 	namespr = g_ScheduleCtrl.m_NameSprMap[1019],
	-- 	id = 1019,
	-- 	joinbtncb = function ()
	-- 		CWorldBossMainView:ShowView()
	-- 		if g_LimitCtrl:CheckIsLimit(true) then
	-- 			return
	-- 		end
	-- 		if g_LimitCtrl:CheckIsCannotMove() then
	-- 			return
	-- 		end
	-- 		C2GSMengzhuMainUI()
	-- 	end,
	-- 	time = pbdata.ret_time
	-- }
	-- if g_AttrCtrl.grade> data.scheduledata.SCHEDULE[1019].level then
	-- 	g_ScheduleCtrl:SetNotifyViewInfo(info)
	-- end
	
end

function GS2CMengzhuPlunderResult(pbdata)
	local win_side = pbdata.win_side --1-success, 2-fail
	local name = pbdata.name --玩家名字
	local score = pbdata.score --玩家评分
	local grade = pbdata.grade --玩家等级
	local school = pbdata.school --门派
	local partner = pbdata.partner --伙伴信息
	local player = pbdata.player --玩家信息
	local point = pbdata.point --获得积分
	--todo
	CWorldBossPlunderResultView:ShowView(function(oView)
		oView:SetPlunderResult(pbdata)
	end)
end

function GS2CMengzhuPlunderNotify(pbdata)
	local target = pbdata.target --目标玩家
	local timeout = pbdata.timeout --玩家受保护时间戳
	--todo
	g_WorldBossCtrl:UpdatePlunderStatus(target, timeout)
end

function GS2CMengzhuBossResult(pbdata)
	local point = pbdata.point --获得积分
	local bout = pbdata.bout --回合数
	local damage = pbdata.damage --总伤害
	--todo
	g_WorldBossCtrl:GS2CMengzhuBossResult(pbdata)
end

function GS2CMengzhuMainUI(pbdata)
	local state = pbdata.state --状态，对应text表
	--todo
	g_WorldBossCtrl:OpenWorldBossView(state)
end

function GS2CBWMyRank(pbdata)
	local rank = pbdata.rank
	local point = pbdata.point
	local maxwin = pbdata.maxwin
	local fail = pbdata.fail
	local starttime = pbdata.starttime
	local matchtime = pbdata.matchtime -->0倒数时间 , ==0 不显示
	local matchendtime = pbdata.matchendtime
	--todo
	g_PKCtrl:GS2CBWMyRank(pbdata)
end

function GS2CBWRank(pbdata)
	local ranklist = pbdata.ranklist
	local maketeam = pbdata.maketeam --1.自动组队 0.不组队
	--todo
	g_PKCtrl:GS2CBWRank(ranklist)
	g_PKCtrl:SetAutoBuildTeam(maketeam)
end

function GS2CBWMakeTeam(pbdata)
	local op = pbdata.op --1.自动组队 0.不组队
	--todo
	g_PKCtrl:SetAutoBuildTeam(op)
end

function GS2CBWBattle(pbdata)
	local match1 = pbdata.match1
	local match2 = pbdata.match2
	local time = pbdata.time
	--todo
	g_PKCtrl:GS2CBWBattle(match1,match2, time)
end

function GS2CBWReward(pbdata)
	local itemlist = pbdata.itemlist
	local wincount = pbdata.wincount
	local exp = pbdata.exp
	local silver = pbdata.silver
	local sumexp = pbdata.sumexp
	local point = pbdata.point
	local prewincount = pbdata.prewincount
	--todo
	g_PKCtrl:GS2CBWReward(pbdata)
end

function GS2COpenOrgTaskUI(pbdata)
	local task = pbdata.task --0.没有任务,否则是任务编号
	local starlist = pbdata.starlist --已经开通星级
	local ringcnt = pbdata.ringcnt --完成环数
	local star = pbdata.star --当前task的星级
	local starexp = pbdata.starexp
	local starorgoffer = pbdata.starorgoffer
	local staritem = pbdata.staritem
	local taskexp = pbdata.taskexp
	local taskorgoffer = pbdata.taskorgoffer
	local taskitem = pbdata.taskitem
	local bout = pbdata.bout --完成轮数
	local pretaskinfo = pbdata.pretaskinfo --任务预览
	--todo
	g_OrgCtrl:SetOrgStarReward(starexp, starorgoffer, staritem)
	g_OrgCtrl:SetOrgTaskReward(taskexp, taskorgoffer, taskitem)
	g_OrgCtrl:GS2COpenOrgTaskUI(task, starlist, ringcnt, star, bout, pretaskinfo)
end

function GS2COrgTaskRandTask(pbdata)
	local task = pbdata.task
	local star = pbdata.star
	local ringcnt = pbdata.ringcnt --完成环数
	local taskexp = pbdata.taskexp
	local taskorgoffer = pbdata.taskorgoffer
	local taskitem = pbdata.taskitem
	local bout = pbdata.bout --完成轮数
	local pretaskinfo = pbdata.pretaskinfo --任务预览
	--todo
	g_OrgCtrl:SetOrgTaskReward(taskexp, taskorgoffer, taskitem)
	g_OrgCtrl:GS2CUpdateOrgTask(task, star, ringcnt, pretaskinfo)
end

function GS2COrgTaskResetStar(pbdata)
	local task = pbdata.task
	local star = pbdata.star
	--todo
	g_OrgCtrl:GS2CUpdateOrgTask(task, star)
end

function GS2COrgTaskCleanStarlist(pbdata)
	--todo
	g_OrgCtrl:GS2COrgTaskCleanStarlist()
end

function GS2CBaikeQuestion(pbdata)
	local id = pbdata.id
	local type = pbdata.type
	local content = pbdata.content
	local choices = pbdata.choices
	local ring = pbdata.ring --第几题
	local answer_cnt = pbdata.answer_cnt
	local answer_time = pbdata.answer_time
	--todo
	g_BaikeCtrl:GS2CBaikeQuestion(pbdata)
end

function GS2CBaikeChooseResult(pbdata)
	local result = pbdata.result --1-正确
	local right_answer = pbdata.right_answer --当result为0时才有数据
	--todo
	if result == 1 then
		g_BaikeCtrl:GS2CBaikeChooseResult(1)
	else
		g_BaikeCtrl:GS2CBaikeChooseResult(0,right_answer)
	end
end

function GS2CBaikeLinkResult(pbdata)
	local result = pbdata.result --1-正确
	local right_answer = pbdata.right_answer
	--todo
	g_BaikeCtrl:GS2CBaikeLinkResult(result,right_answer)
end

function GS2CBaikeFinish(pbdata)
	--todo
	g_BaikeCtrl:GS2CBaikeFinish(self)
end

function GS2CBaikeCurRank(pbdata)
	local unit = pbdata.unit
	--todo
	g_BaikeCtrl:GS2CBaikeCurRank(unit)
end

function GS2CBaikeCurRankScore(pbdata)
	local score = pbdata.score
	--todo
	g_BaikeCtrl:GS2CBaikeCurRankScore(score)
end

function GS2CBaikeWeekRank(pbdata)
	local unit = pbdata.unit
	local score = pbdata.score
	--todo
	g_BaikeCtrl:GS2CBaikeWeekRank(unit,score)
end

function GS2CChargeGiftInfo(pbdata)
	local mask = pbdata.mask
	local gift_day_list = pbdata.gift_day_list --每日礼包
	local gift_goldcoin_list = pbdata.gift_goldcoin_list --元宝大礼
	local gift_grade_list = pbdata.gift_grade_list --一本万利
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(pbdata, "chargeGift")
	g_WelfareCtrl:UpdateAllGiftInfo(dDecode)
end

function GS2CChargeRefreshUnit(pbdata)
	local unit = pbdata.unit
	--todo
	g_WelfareCtrl:GS2CChargeRefreshUnit(unit)
end

function GS2CChargeCheckBuy(pbdata)
	local reward_key = pbdata.reward_key --购买项key值
	local can_buy = pbdata.can_buy --0-不可购买,1-可购买
	--todo
	g_WelfareCtrl:GS2CChargeCheckBuy(pbdata)
end

function GS2CBottleRecv(pbdata)
	local bottle = pbdata.bottle --瓶子id
	--todo
	g_WishBottleCtrl:UpdateBottleId(bottle)
end

function GS2CBottleDetail(pbdata)
	local bottle = pbdata.bottle --瓶子id
	local send_id = pbdata.send_id --发送人,0表示系统
	local name = pbdata.name --发送人名字
	local content = pbdata.content --祝福语,系统发送的为空
	local send_time = pbdata.send_time --发送时间
	local model_info = pbdata.model_info --model_info信息
	--todo
	g_WishBottleCtrl:GS2CBottleDetail(pbdata)
end

function GS2CLingxiMatching(pbdata)
	local rest_sec = pbdata.rest_sec --剩余持续秒数
	--todo
	g_LingxiCtrl:GS2CLingxiMatching(pbdata)
end

function GS2CLingxiMatchEnd(pbdata)
	local succ = pbdata.succ --1/0是否匹配成功
	--todo
	g_LingxiCtrl:GS2CLingxiMatchEnd(pbdata)
end

function GS2CLingxiShowFlowerUsePos(pbdata)
	--todo
	g_LingxiCtrl:GS2CLingxiShowFlowerUsePos(pbdata)
end

function GS2CLingxiShowFlowerPoem(pbdata)
	local sec = pbdata.sec --用时
	--todo
	g_LingxiCtrl:GS2CLingxiShowFlowerPoem(pbdata)
end

function GS2CLMMyPoint(pbdata)
	local point = pbdata.point
	local win = pbdata.win
	local fail = pbdata.fail
	local gamestate = pbdata.gamestate --1.积分 2.淘汰
	local rank = pbdata.rank
	local starttime = pbdata.starttime
	local matchtime = pbdata.matchtime -->0倒数时间 , ==0 不显示
	--todo
	g_SchoolMatchCtrl:SetMyRankInfo(pbdata)
end

function GS2CLMPointRank(pbdata)
	local ranklist = pbdata.ranklist
	--todo
	g_SchoolMatchCtrl:SetRankList(ranklist)
end

function GS2CLMBatte(pbdata)
	local battlelist = pbdata.battlelist
	local step = pbdata.step --16-16强.. 2.冠军和季军
	local time = pbdata.time --开始时间
	local open = pbdata.open --1.强行打开UI
	--todo
	g_SchoolMatchCtrl:SetBattleList(battlelist, step, time, open == 1)
end

function GS2CLMShouXi(pbdata)
	local sxlist = pbdata.sxlist
	--todo
	g_SchoolMatchCtrl:FinishActivity(sxlist)
end

function GS2CLMGameState(pbdata)
	local state = pbdata.state --0.未开始 1.积分赛 2.淘汰 3.结束
	--todo
	g_SchoolMatchCtrl:SetGameStep(state)
end

function GS2CShootCrapReward(pbdata)
	local exp = pbdata.exp
	local silver = pbdata.silver
	--todo
	g_CrapsCtrl:GS2CShootCrapReward(exp, silver)
end

function GS2CCloseJYFBComfirm(pbdata)
	local sessionidx = pbdata.sessionidx
	--todo
	local oView = CDungeonConfirmView:GetView() 
	if oView then
		oView:CloseView()
	end
	g_DungeonCtrl:OnEvent(define.Dungeon.Event.FinishComfirm)
end

function GS2CJYFBComfirmEnter(pbdata)
	local sessionidx = pbdata.sessionidx
	local pid = pbdata.pid
	--todo
	g_DungeonCtrl:SetPlayerConfirmStatus(pid)
end

function GS2CJYFBComfirm(pbdata)
	local time = pbdata.time
	local plist = pbdata.plist --成员状态
	local sessionidx = pbdata.sessionidx
	--todo
	CDungeonConfirmView:ShowView(function(oView)
		g_DungeonCtrl:UpdateConfirmState(1, time, plist, sessionidx)
	end)
end

function GS2CRefreshJYFBComfirm(pbdata)
	local time = pbdata.time
	local plist = pbdata.plist --成员状态
	local sessionidx = pbdata.sessionidx
	--todo
	local fuben = 1
	g_DungeonCtrl:UpdateConfirmState(fuben, time, plist, sessionidx)
end

function GS2CJYFBGameOver(pbdata)
	local exp = pbdata.exp
	local silver = pbdata.silver
	local point = pbdata.point
	local itemlist = pbdata.itemlist
	local open = pbdata.open
	local expradio = pbdata.expradio
	local silverradio = pbdata.silverradio
	--todo
	g_DungeonCtrl:GS2CJYFBGameOver(pbdata)
end

function GS2CJYFubenFloorName(pbdata)
	local floor = pbdata.floor
	local name = pbdata.name
	--todo
	g_DungeonCtrl:GS2CJYFubenFloorName(floor, name)
end

function GS2CWelfareGiftInfo(pbdata)
	local mask = pbdata.mask
	local first_pay_gift = pbdata.first_pay_gift --首冲 第一重
	local rebate_gift = pbdata.rebate_gift --充值返利
	local login_gift = pbdata.login_gift --七彩神灯
	local new_day_time = pbdata.new_day_time --七彩神灯下一天
	local second_pay_gift = pbdata.second_pay_gift --次充奖励
	local first_pay_gift_second = pbdata.first_pay_gift_second --首冲 第二重
	local first_pay_gift_third = pbdata.first_pay_gift_third --首冲 第三重
	local store_charge_rmb = pbdata.store_charge_rmb --当前从商城充值的人民币总数(单位:元)
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(pbdata, "welfareGift")
	g_WelfareCtrl:UpdateAllGiftInfo(dDecode)
	g_FirstPayCtrl:UpdateAllInfo(dDecode)
	g_WelfareCtrl:YoukaLoginTime(new_day_time)
end

function GS2CCollectGiftInfo(pbdata)
	local collect_gift = pbdata.collect_gift
	--todo
	g_WelfareCtrl:GS2CCollectGiftInfo(collect_gift)
end

function GS2CUpdateCollectStatus(pbdata)
	local collect_key = pbdata.collect_key
	local status = pbdata.status --0 close 1 open
	local collect = pbdata.collect
	--todo
	g_WelfareCtrl:GS2CUpdateCollectStatus(collect_key, status, collect)
end

function GS2CGuessGameDone(pbdata)
	local silver = pbdata.silver --最终获得银币
	--todo
	local oView = CWindowComfirmView:GetView()
	if oView then
		oView:OnClose()
	end
	local windowConfirmInfo = {
		msg = string.format("[63432C]你在本次银币幻境中一共获得银币: [-][1d8e00]%d[-]", silver),
		title = "副本结束",
		closeType = extend_close,
		style = CWindowComfirmView.Style.Multiple,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function(oView)
		oView.m_CancelBtn:SetActive(false)
		oView.m_InfoLabel:SetColor(Color.white)
	end)
end

function GS2CHuodongIntroduce(pbdata)
	local id = pbdata.id --活动名称
	--todo
	local instructionData = data.instructiondata.DESC[tonumber(id)]
	if instructionData then
		local zContent = {title = instructionData.title,desc = instructionData.desc}
		g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	else
		printc("未配置说明",id)
	end
end

function GS2CGuessGameIntroduce(pbdata)
	--todo
	local instructionData = data.instructiondata.DESC[10022]
	if instructionData then
		local zContent = {title = instructionData.title,desc = instructionData.desc}
		g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	else
		printc("未配置火眼金睛说明")
	end
end

function GS2CCaishenRefreshRewardKey(pbdata)
	local group_key = pbdata.group_key --当前活动对应的抽奖key
	local reward_key = pbdata.reward_key --已经领取过的奖励编号
	local start_time = pbdata.start_time --开始时间
	local end_time = pbdata.end_time --结束时间
	local reward_surplus = pbdata.reward_surplus --剩余次数
	local status = pbdata.status --活动的开启状态
	--todo
	g_LotteryCtrl:GS2CCaishenRefreshRewardKey(pbdata)
end

function GS2CCaishenRefreshRewardRecord(pbdata)
	local record_list = pbdata.record_list --记录列表
	local last_time = pbdata.last_time --最新一条记录的时间戳
	--todo
	g_LotteryCtrl:GS2CCaishenRefreshRewardRecord(pbdata)
end

function GS2COrgWarOpenMatchList(pbdata)
	local match_list = pbdata.match_list --帮派列表
	--todo
	g_OrgMatchCtrl:SetOrgMatchList(match_list)
end

function GS2COrgWarEnterPrepareRoom(pbdata)
	local action_point = pbdata.action_point --玩家行动力
	local fight_time = pbdata.fight_time --战斗开启时间
	--todo
	g_OrgMatchCtrl:SetStartTime(fight_time)
	g_OrgMatchCtrl:SetActionPoint(action_point)
end

function GS2COrgWarOpenTeamUI(pbdata)
	local single_list = pbdata.single_list --场景未组队玩家
	local team_list = pbdata.team_list --场景队伍信息
	--todo
	g_OrgMatchCtrl:SetMapTeamInfo(single_list, team_list)
end

function GS2COrgWarEnterFightScene(pbdata)
	local action_point = pbdata.action_point --玩家行动力
	--todo
	g_OrgMatchCtrl:SetActionPoint(action_point)
end

function GS2COrgWarRefreshActionPoint(pbdata)
	local action_point = pbdata.action_point --玩家行动力
	--todo
	g_OrgMatchCtrl:SetActionPoint(action_point)
end

function GS2COrgWarOpenWarScoreUI(pbdata)
	local org_list = pbdata.org_list --对战帮派战绩信息
	--todo
	g_OrgMatchCtrl:SetOrgDetailInfo(org_list)
end

function GS2CTrialOpenUI(pbdata)
	local trial_list = pbdata.trial_list
	local ret_time = pbdata.ret_time --剩余次数
	local total = pbdata.total --总个数
	--todo
	g_HeroTrialCtrl:GS2CTrialOpenUI(pbdata)
end

function GS2CTrialRefreshUnit(pbdata)
	local trial_unit = pbdata.trial_unit --单个试炼信息
	local pos = pbdata.pos --位置信息
	--todo
	g_HeroTrialCtrl:GS2CTrialRefreshUnit(trial_unit, pos)
end

function GS2CHfdmQuesState(pbdata)
	local total_round = pbdata.total_round --总轮次
	local correct_cnt = pbdata.correct_cnt --正确数
	local wait_sec = pbdata.wait_sec --等待时间 (-1表示没有等到时间)
	local state = pbdata.state --1:等待下一题出题, 2:答题倒计时, 3:答题结束, 4:等待活动开始
	local winners = pbdata.winners --获胜玩家名字，这个出现时，state为3，其他计数无
	--todo
	g_GuessRiddleCtrl:GS2CHfdmQuesState(pbdata)
end

function GS2CHfdmQuestion(pbdata)
	local round = pbdata.round --当前轮次
	local ques_id = pbdata.ques_id
	local title = pbdata.title --题干
	local choices = pbdata.choices --答案
	--todo
	g_GuessRiddleCtrl:GS2CHfdmQuestion(round, ques_id, title, choices)
end

function GS2CHfdmAnswerResult(pbdata)
	local ques_id = pbdata.ques_id --校验用
	local iscorrect = pbdata.iscorrect --是否正确
	local correct_cnt = pbdata.correct_cnt --正确数
	local correct_answer = pbdata.correct_answer --正确答案
	local my_answer = pbdata.my_answer --自己的已选答案（可能在后端因校验而修改，从而与前端不一致）
	--todo
	g_GuessRiddleCtrl:GS2CHfdmAnswerResult(ques_id, correct_answer, my_answer, correct_cnt)
end

function GS2CHfdmSelectAnswer(pbdata)
	local ques_id = pbdata.ques_id --校验用
	local select = pbdata.select --选择的选项(0为未成功选择选项)
	--todo
	if not select then
		select = 0
	end
	g_GuessRiddleCtrl:GS2CHfdmSelectAnswer(ques_id, select)
end

function GS2CHfdmNeedCorrectRewardInfo(pbdata)
	local total_cnt = pbdata.total_cnt --累积正确数 (0表示不出现额外累积奖励)
	local need_cnt = pbdata.need_cnt --需要正确数
	local rewardid = pbdata.rewardid --奖励id
	--todo
	g_GuessRiddleCtrl:GS2CHfdmNeedCorrectRewardInfo(pbdata)
end

function GS2CHfdmInScene(pbdata)
	local is_in = pbdata.is_in --0/1是否在场景
	--todo
	g_GuessRiddleCtrl:GS2CHfdmInScene(is_in)
end

function GS2CHfdmSkillStatus(pbdata)
	local skills = pbdata.skills
	--todo
	g_GuessRiddleCtrl:GS2CHfdmSkillStatus(skills)
end

function GS2CHfdmRankInfo(pbdata)
	local ranks = pbdata.ranks
	--todo
	g_GuessRiddleCtrl:GS2CHfdmRankInfo(ranks)
end

function GS2CHfdmMyRank(pbdata)
	local rank = pbdata.rank
	local score = pbdata.score
	--todo
	g_GuessRiddleCtrl:GS2CHfdmMyRank(rank, score)
end

function GS2CHfdmIntro(pbdata)
	--todo
	g_GuessRiddleCtrl:GS2CHfdmIntro(pbdata)
end

function GS2CRefreshGrow(pbdata)
	local index = pbdata.index
	local reward = pbdata.reward --0.未完成 1.可领取 2.已经领取
	local finish = pbdata.finish --0.未完成 1.完成
	--todo
	g_PromoteCtrl:GS2CRefreshGrow(pbdata)
end

function GS2CAllGrowInfo(pbdata)
	local growinfo = pbdata.growinfo
	--todo
	g_PromoteCtrl:GS2CAllGrowInfo(growinfo)
end

function GS2CReturnGoldCoinRefresh(pbdata)
	local cbtpay = pbdata.cbtpay --封测充值金额
	local reward = pbdata.reward --是否领取过返还奖励，位标识, 0x1<<(次数-1)
	local free_gift = pbdata.free_gift --是否领取过免费神秘大礼
	local gift_1_time = pbdata.gift_1_time --神秘礼包1过期时间
	local gift_1_buy = pbdata.gift_1_buy --是否已经购买
	local gift_2_time = pbdata.gift_2_time --神秘礼包2过期时间
	local gift_2_buy = pbdata.gift_2_buy --是否已经购买
	--todo
	g_WelfareCtrl:GS2CReturnGoldCoinRefresh(pbdata)
end

function GS2CKFTouxianRank(pbdata)
	local touxianrank = pbdata.touxianrank
	--todo
	g_CelebrationCtrl:GS2CKFTouxianRank(pbdata)
end

function GS2CKaiFuRankReward(pbdata)
	local orgcnt = pbdata.orgcnt
	local orglevel = pbdata.orglevel
	local playerscore = pbdata.playerscore
	local playergrade = pbdata.playergrade
	local txendtime = pbdata.txendtime
	local sumendtime = pbdata.sumendtime
	local createtime = pbdata.createtime
	--todo
	g_CelebrationCtrl:GS2CKaiFuRankReward(pbdata)
end

function GS2CShowGradeGiftUI(pbdata)
	--todo
	-- 已充值不显示推送
	if g_BigProfitCtrl.m_IsShowBoth or g_BigProfitCtrl:IsBigProfitPay() then
		return
	end
	CWelfareGradePushView:ShowView()
end

function GS2CSevenDayStart(pbdata)
	local endtime = pbdata.endtime
	local starttime = pbdata.starttime
	--todo
	g_TimelimitCtrl:GS2CSevenDayDuration(starttime, endtime)
end

function GS2CSevenDayEnd(pbdata)
	--todo
	g_TimelimitCtrl:GS2CSevenDayEnd()
end

function GS2CSevenDayReward(pbdata)
	local rewardlist = pbdata.rewardlist --1.可领取 2已领取 ； 下标是第几天
	--todo
	local rewardlist = pbdata.rewardlist --1.可领取 2已领取 ； 下标是第几天
	g_TimelimitCtrl:GS2CSevenDayReward(rewardlist)
end

function GS2CEveryDayChargeStart(pbdata)
	local endtime = pbdata.endtime
	local reward_key = pbdata.reward_key
	--todo
	local endtime = pbdata.endtime
	g_EveryDayChargeCtrl:GS2CEveryDayChargeStart(pbdata)
end

function GS2CEveryDayChargeEnd(pbdata)
	--todo
	g_EveryDayChargeCtrl:GS2CEveryDayChargeEnd()
end

function GS2CEveryDayChargeReward(pbdata)
	local rewardlist = pbdata.rewardlist
	local curday = pbdata.curday
	--todo
	g_EveryDayChargeCtrl:GS2CEveryDayChargeReward(pbdata)
end

function GS2COnlineGift(pbdata)
	local statuslist = pbdata.statuslist
	local start_time = pbdata.start_time
	local end_time = pbdata.end_time
	local login_time = pbdata.login_time
	--todo
	g_OnlineGiftCtrl:GS2COnlineGift(pbdata)
end

function GS2COnlineGiftUnit(pbdata)
	local unit = pbdata.unit
	--todo
	g_OnlineGiftCtrl:GS2COnlineGiftUnit(unit)
end

function GS2CSuperRebateStart(pbdata)
	local endtime = pbdata.endtime
	--todo
	g_SuperRebateCtrl:SuperRebateStart(endtime)
end

function GS2CSuperRebateEnd(pbdata)
	--todo
	g_SuperRebateCtrl:GS2CSuperRebateEnd()
end

function GS2CSuperRebateReward(pbdata)
	local lotterycnt = pbdata.lotterycnt --已经抽奖次数
	local value = pbdata.value --value>0表示可以领取返利
	local rebate = pbdata.rebate --获得返利的加成索引
	--todo
	g_SuperRebateCtrl:GS2CSuperRebateReward(pbdata)
end

function GS2CSuperRebateRecord(pbdata)
	local recordlist = pbdata.recordlist
	--todo
	g_SuperRebateCtrl:GS2CSuperRebateRecord(recordlist)
end

function GS2CTotalChargeStart(pbdata)
	local endtime = pbdata.endtime
	local mode = pbdata.mode --1.new 2.old 3.third
	--todo
	g_AccumChargeCtrl:GS2CTotalChargeStart(pbdata)
end

function GS2CTotalChargeEnd(pbdata)
	--todo
	g_AccumChargeCtrl:GS2CTotalChargeEnd()
end

function GS2CTotalChargeReward(pbdata)
	local rewardlist = pbdata.rewardlist
	local todaygoldcoin = pbdata.todaygoldcoin
	--todo
	local rewardlist = pbdata.rewardlist
	local todaygoldcoin = pbdata.todaygoldcoin
	g_AccumChargeCtrl:GS2CTotalChargeReward(rewardlist, todaygoldcoin)
end

function GS2CFightGiftbagReward(pbdata)
	local rewardlist = pbdata.rewardlist
	local endtime = pbdata.endtime
	--todo
	g_WelfareCtrl:GS2CFightGiftbagReward(rewardlist, endtime)
end

function GS2CDayExpenseReward(pbdata)
	local group_key = pbdata.group_key --奖励组id（来源于运营后台）
	local reward_list = pbdata.reward_list --奖励列表
	local goldcoin = pbdata.goldcoin --今日花费的元宝数
	local end_time = pbdata.end_time --活动结束时间
	local state = pbdata.state --活动状态 0  关闭  1 开启   2 准备开启（运营设置开启，但是开启时间未到）
	--todo
	g_TimelimitCtrl:GS2CDayExpenseReward(pbdata)
end

function GS2COpenFuYuanBoxView(pbdata)
	local box_idx = pbdata.box_idx --宝箱编号
	local reward_ids = pbdata.reward_ids --随机奖励物品的id列表
	--todo
	g_FuyuanTreasureCtrl:GS2COpenFuYuanBoxView(box_idx, reward_ids)
end

function GS2CCloseFuYuanBoxView(pbdata)
	--todo
	g_FuyuanTreasureCtrl:GS2CCloseFuYuanBoxView()
end

function GS2CFuYuanBoxReward(pbdata)
	local times = pbdata.times --1 1次的奖励 10 10次的奖励
	local rewards = pbdata.rewards
	--todo
	g_FuyuanTreasureCtrl:GS2CFuYuanBoxReward(times, rewards)
end

function GS2CFuYuanLottery(pbdata)
	local sessionidx = pbdata.sessionidx
	local id = pbdata.id
	--todo
	g_FuyuanTreasureCtrl:GS2CFuYuanLottery(sessionidx, id)
end

function GS2CThreeBWMyRank(pbdata)
	local rank = pbdata.rank
	local point = pbdata.point
	local lastwin = pbdata.lastwin --连胜
	local win = pbdata.win --胜利
	local fight = pbdata.fight --战斗场次
	local starttime = pbdata.starttime --活动正式开始时间戳
	local match = pbdata.match --1.参与匹配 0.没有参与匹配
	local endtime = pbdata.endtime
	local matchendtime = pbdata.matchendtime
	--todo
	g_ThreeBiwuCtrl:GS2CThreeBWMyRank(pbdata)
end

function GS2CThreeBWEndRank(pbdata)
	local rankdata = pbdata.rankdata
	--todo
	g_ThreeBiwuCtrl:GS2CThreeBWEndRank(pbdata)
end

function GS2CThreeBWNomalRank(pbdata)
	local rankdata = pbdata.rankdata
	local point = pbdata.point
	local rank = pbdata.rank
	local win = pbdata.win --胜利
	local lastwin = pbdata.lastwin --连胜
	local firstwin = pbdata.firstwin --首胜 0.未达到 1.可以领取 2.已经领取
	local fivewin = pbdata.fivewin --5胜 0.未达到 1.可以领取 2.已经领取
	local endtime = pbdata.endtime
	--todo
	g_ThreeBiwuCtrl:GS2CThreeBWNomalRank(pbdata)
end

function GS2CThreeBWBattle(pbdata)
	local match1 = pbdata.match1
	local match2 = pbdata.match2
	local time = pbdata.time
	--todo
	g_ThreeBiwuCtrl:GS2CThreeBWBattle(pbdata)
end

function GS2CQiFuStart(pbdata)
	local endtime = pbdata.endtime
	--todo
	g_HeShenQiFuCtrl:GS2CQiFuStart(endtime)
end

function GS2CQiFuEnd(pbdata)
	--todo
	g_HeShenQiFuCtrl:GS2CQiFuEnd()
end

function GS2CQiFuReward(pbdata)
	local point = pbdata.point
	local rewardlist = pbdata.rewardlist --0.未达到 1.可以领取 2.已经领取
	--todo
	g_HeShenQiFuCtrl:GS2CQiFuReward(point, rewardlist)
end

function GS2CQiFuLottery(pbdata)
	local rewardlist = pbdata.rewardlist
	--todo
	g_HeShenQiFuCtrl:GS2CQiFuLottery(rewardlist)
end

function GS2COpenActivePointGiftView(pbdata)
	local gift_list = pbdata.gift_list --所有可领取或已经领取礼包的状态
	--todo
	g_ActiveGiftBagCtrl:GS2COpenActivePointGiftView(gift_list)
end

function GS2CActivePointGiftTotalPoint(pbdata)
	local total_point = pbdata.total_point
	--todo
	g_ActiveGiftBagCtrl:GS2CActivePointGiftTotalPoint(total_point)
end

function GS2CActivePointGiftState(pbdata)
	local state = pbdata.state --活动的开启状态   关闭 0    开启 1 等待开启（开启时间还未到） 2
	local end_time = pbdata.end_time
	--todo
	g_ActiveGiftBagCtrl:GS2CActivePointGiftState(pbdata)
end

function GS2CActivePointSetGridOptionResult(pbdata)
	local point_key = pbdata.point_key --礼包id
	local grid_id = pbdata.grid_id --所在格子
	local option = pbdata.option --格子内部选项
	--todo
	g_ActiveGiftBagCtrl:GS2CActivePointSetGridOptionResult(point_key, grid_id, option)
end

function GS2CJuBaoPenInfo(pbdata)
	local free_count = pbdata.free_count --免费次数
	local free_endtime = pbdata.free_endtime --免费的CD结束时间戳
	local ten_ext_times = pbdata.ten_ext_times --距离10次的额外奖励还要抽多少次
	local score_reward = pbdata.score_reward --积分奖励状态
	local score = pbdata.score --自己积分
	--todo
	g_AssembleTreasureCtrl:GS2CJuBaoPenInfo(pbdata)
end

function GS2CJuBaoPenRecord(pbdata)
	local records = pbdata.records --聚宝盆记录
	--todo
	g_AssembleTreasureCtrl:GS2CJuBaoPenRecord(records)
end

function GS2CJuBaoPen(pbdata)
	local times = pbdata.times --1 1次的奖励 10 10次的奖励
	local rewards = pbdata.rewards
	local extrewards = pbdata.extrewards --额外奖励
	--todo
	g_AssembleTreasureCtrl:GS2CJuBaoPen(pbdata)
end

function GS2CJuBaoPenStart(pbdata)
	local showrank = pbdata.showrank --是否是显示结束排行榜 1 显示 2 不显示
	local endtime = pbdata.endtime --聚宝盆活动结束时间戳
	--todo
	g_AssembleTreasureCtrl:GS2CJuBaoPenStart(endtime, showrank)
end

function GS2CJuBaoPenEnd(pbdata)
	local showrank = pbdata.showrank --是否是显示结束排行榜 1 显示 2 不显示
	--todo
	g_AssembleTreasureCtrl:GS2CJuBaoPenEnd(showrank)
end

function GS2CDrawCardState(pbdata)
	local state = pbdata.state --活动开启状态 关闭 0 开启 1 等待开启 2
	local end_time = pbdata.end_time
	--todo
	g_TimelimitCtrl:GS2CDrawCardState(pbdata)
end

function GS2CDrawCardTimes(pbdata)
	local times = pbdata.times --翻牌的可重置次数
	local purchased_times = pbdata.purchased_times --已经购买的次数
	--todo
	g_TimelimitCtrl:GS2CDrawCardTimes(pbdata)
end

function GS2CDrawCardGetList(pbdata)
	local card_list = pbdata.card_list --一组牌面 重置 则为空
	local card_count = pbdata.card_count --未翻开的牌数
	--todo
	g_TimelimitCtrl:GS2CDrawCardGetList(pbdata)
end

function GS2CDrawCardDrawResult(pbdata)
	local success = pbdata.success --翻牌是否成功 失败 0， 成功 1
	local card_count = pbdata.card_count --当前未翻牌的个数
	local card_list = pbdata.card_list --状态改变的牌的列表
	--todo
	g_TimelimitCtrl:GS2CDrawCardDrawResult(pbdata)
end

function GS2CContinuousChargeStart(pbdata)
	local starttime = pbdata.starttime
	local endtime = pbdata.endtime
	local mode = pbdata.mode --1.new 2.old
	--todo
	g_ContActivityCtrl:GS2CContinuousChargeStart(pbdata)
end

function GS2CContinuousChargeEnd(pbdata)
	--todo
	g_ContActivityCtrl:GS2CContinuousChargeEnd()
end

function GS2CContinuousChargeReward(pbdata)
	local states = pbdata.states
	local totalstates = pbdata.totalstates
	local curday = pbdata.curday --当前是活动第几天
	local curgoldcoin = pbdata.curgoldcoin --当天的充值元宝
	local totalcoldcoin = pbdata.totalcoldcoin --活动开始到当前的累计充值元宝
	local choice = pbdata.choice --可选奖励
	local totalchoice = pbdata.totalchoice --累计的可选奖励
	--todo
	g_ContActivityCtrl:GS2CContinuousChargeReward(pbdata)
end

function GS2CContinuousExpenseStart(pbdata)
	local starttime = pbdata.starttime
	local endtime = pbdata.endtime
	local mode = pbdata.mode --1.new 2.old
	--todo
	g_ContActivityCtrl:GS2CContinuousExpenseStart(pbdata)
end

function GS2CContinuousExpenseEnd(pbdata)
	--todo
	g_ContActivityCtrl:GS2CContinuousExpenseEnd()
end

function GS2CContinuousExpenseReward(pbdata)
	local states = pbdata.states
	local totalstates = pbdata.totalstates
	local curday = pbdata.curday --当前是活动第几天
	local curgoldcoin = pbdata.curgoldcoin --当天的消费元宝
	local totalcoldcoin = pbdata.totalcoldcoin --活动开始到当前的累计消费元宝
	local choice = pbdata.choice --可选奖励
	local totalchoice = pbdata.totalchoice --累计的可选奖励
	--todo
	g_ContActivityCtrl:GS2CContinuousExpenseReward(pbdata)
end

function GS2CEveryDayRankStart(pbdata)
	local rank_idx = pbdata.rank_idx --排行榜索引
	local start_time = pbdata.start_time --开始时间
	local end_time = pbdata.end_time --结束时间
	--todo
	g_TimelimitCtrl:GS2CEveryDayRankStart(pbdata)
end

function GS2CEveryDayRankEnd(pbdata)
	--todo
	g_TimelimitCtrl:GS2CEveryDayRankEnd()
end

function GS2CNSGetPlayerNPC(pbdata)
	local npclist = pbdata.npclist
	--todo
	g_NianShouCtrl:GS2CNSGetPlayerNPC(npclist)

end

function GS2CNSRemovePlayerNPC(pbdata)
	local npcid = pbdata.npcid
	--todo
	g_NianShouCtrl:GS2CNSRemovePlayerNPC(npcid)
end

function GS2CNSYanHua(pbdata)
	local x = pbdata.x
	local y = pbdata.y
	--todo
	g_NianShouCtrl:GS2CNSYanHua(x, y)
end

function GS2CGoldCoinPartyStart(pbdata)
	--todo
	g_YuanBaoJoyCtrl:GS2CGoldCoinPartyStart(pbdata)
end

function GS2CGoldCoinPartyEnd(pbdata)
	--todo
	g_YuanBaoJoyCtrl:GS2CGoldCoinPartyEnd(pbdata)
end

function GS2CGoldCoinPartyReward(pbdata)
	local point = pbdata.point --进度点数
	local rewardlist = pbdata.rewardlist --0.未达到 1.可以领取 2.已经领取
	local recordlist = pbdata.recordlist --历史记录
	local allgoldcoin = pbdata.allgoldcoin --奖金池
	local endtime = pbdata.endtime
	--todo
	g_YuanBaoJoyCtrl:GS2CGoldCoinPartyReward(pbdata)
end

function GS2CGoldCoinPartyLottery(pbdata)
	local rewardlist = pbdata.rewardlist
	--todo
	g_YuanBaoJoyCtrl:GS2CGoldCoinPartyLottery(pbdata)
end

function GS2CGoldCoinPartyUpdateInfo(pbdata)
	local allgoldcoin = pbdata.allgoldcoin --奖金池
	local recordlist = pbdata.recordlist --历史记录
	--todo
	g_YuanBaoJoyCtrl:GS2CGoldCoinPartyUpdateInfo(pbdata)
end

function GS2CMysticalboxGetState(pbdata)
	local state = pbdata.state --可领取箱子（无时间戳） 1  已经领取箱子（有时间戳） 2  已经打开箱子获取道具 3
	local open_time = pbdata.open_time --解锁的时间戳
	--todo
	g_MysticalBoxCtrl:GS2CMysticalboxGetState(pbdata)
end

function GS2CHotTopicList(pbdata)
	local hd_list = pbdata.hd_list
	--todo
	g_HotTopicCtrl:GS2CHotTopicList(hd_list)
end

function GS2CJiaBaiClickNpc(pbdata)
	local flag = pbdata.flag --1 了解结拜 2 结拜流程说明
	--todo
	g_JieBaiCtrl:GS2CJiaBaiClickNpc(flag)
end

function GS2CJiaBaiCreate(pbdata)
	local jiebai_info = pbdata.jiebai_info
	--todo
	g_JieBaiCtrl:GS2CJiaBaiCreate(jiebai_info)

end

function GS2CJBAddInviter(pbdata)
	local invite_info = pbdata.invite_info
	--todo
	g_JieBaiCtrl:GS2CJBAddInviter(invite_info)
end

function GS2CJBBecomeInviter(pbdata)
	local fullinvite_info = pbdata.fullinvite_info
	--todo
	g_JieBaiCtrl:GS2CJBBecomeInviter(fullinvite_info)
end

function GS2CJBInviterOnLogin(pbdata)
	local fullinvite_info = pbdata.fullinvite_info
	--todo
	g_JieBaiCtrl:GS2CJBInviterOnLogin(fullinvite_info)
end

function GS2CJBInvitedOnLogin(pbdata)
	local jiebai_info = pbdata.jiebai_info
	--todo
	g_JieBaiCtrl:GS2CJBInvitedOnLogin(jiebai_info)
end

function GS2CJBRemoveInviter(pbdata)
	local pid = pbdata.pid
	--todo
	g_JieBaiCtrl:GS2CJBRemoveInviter(pid)
end

function GS2CJBRefreshInviter(pbdata)
	local invite_info = pbdata.invite_info
	--todo
	g_JieBaiCtrl:GS2CJBRefreshInviter(invite_info)
end

function GS2CJBMemberOnLogin(pbdata)
	local jiebai_info = pbdata.jiebai_info
	--todo
	g_JieBaiCtrl:GS2CJBMemberOnLogin(jiebai_info)
end

function GS2CJBAddMember(pbdata)
	local mem_info = pbdata.mem_info
	--todo
	g_JieBaiCtrl:GS2CJBAddMember(mem_info)
end

function GS2CJBBecomeMember(pbdata)
	local jiebai_info = pbdata.jiebai_info
	--todo
	g_JieBaiCtrl:GS2CJBBecomeMember(jiebai_info)
end

function GS2CJBRemoveMember(pbdata)
	local pid = pbdata.pid
	--todo
	g_JieBaiCtrl:GS2CJBRemoveMember(pid)
end

function GS2CJBRefreshMember(pbdata)
	local mem_info = pbdata.mem_info
	--todo
end

function GS2CJBRemoveJieBai(pbdata)
	--todo
	g_JieBaiCtrl:GS2CJBRemoveJieBai()
end

function GS2CJBRefresh(pbdata)
	local jiebai_info = pbdata.jiebai_info
	--todo
	g_JieBaiCtrl:GS2CJBRefresh(jiebai_info)
end

function GS2CJBHejiu(pbdata)
	--todo
	g_JieBaiCtrl:GS2CJBHejiu()
end

function GS2CJBYiShiChuiCu(pbdata)
	--todo
	g_JieBaiCtrl:GS2CJBYiShiChuiCu()
end

function GS2CJBValidInviter(pbdata)
	local plist = pbdata.plist
	--todo
	g_JieBaiCtrl:GS2CJBValidInviter(plist)
end

function GS2CJBRedPoint(pbdata)
	local red_point = pbdata.red_point
	--todo
	g_JieBaiCtrl:GS2CJBRedPoint(red_point)
end

function GS2CJoyExpenseState(pbdata)
	local state = pbdata.state --活动开启状态 关闭0 开启 1 准备开启
	local end_time = pbdata.end_time --结束的时间戳
	local mode_id = pbdata.mode_id --奖励模式（老服 1001 新服 1002）通过其获得对应的奖励表和商店id
	--todo
	g_RebateJoyCtrl:GS2CJoyExpenseState(pbdata)
end

function GS2CJoyExpenseRewardState(pbdata)
	local reward_list = pbdata.reward_list --可领取奖励列表
	--todo
	g_RebateJoyCtrl:GS2CJoyExpenseRewardState(pbdata)
end

function GS2CJoyExpenseGoldCoin(pbdata)
	local goldcoin = pbdata.goldcoin --在欢乐返利商城消费的元宝数
	--todo
	g_RebateJoyCtrl:GS2CJoyExpenseGoldCoin(pbdata)
end

function GS2CRplGoldCoinGift(pbdata)
	local multiple = pbdata.multiple --返利的列表 倍数 × 100
	local flag = pbdata.flag --是否显示
	--todo
	g_RebateJoyCtrl:GS2CRplGoldCoinGift(pbdata)
end

function GS2CSingleWarInfo(pbdata)
	local info = pbdata.info --刷新内容
	--todo
	g_SingleBiwuCtrl:GS2CSingleWarInfo(info)
end

function GS2CSingleWarMatchResult(pbdata)
	local role = pbdata.role --角色信息
	local score = pbdata.score --评分
	--todo
	g_SingleBiwuCtrl:GS2CSingleWarMatchResult(role, score)
end

function GS2CSingleWarStartMatch(pbdata)
	--todo
end

function GS2CSingleWarFinalRank(pbdata)
	local group_id = pbdata.group_id --分组
	local my_rank = pbdata.my_rank --排名
	local point = pbdata.point --积分
	local rank_list = pbdata.rank_list --排行
	--todo
	g_SingleBiwuCtrl:GS2CSingleWarFinalRank(pbdata)
end

function GS2CSingleWarRank(pbdata)
	local rank = pbdata.rank --排行榜信息
	--todo
	g_SingleBiwuCtrl:GS2CSingleWarRank(rank)
end

function GS2CItemInvestState(pbdata)
	local state = pbdata.state --状态 1 投资阶段 2 投资结束可领取阶段 3 结束
	local invest_endtime = pbdata.invest_endtime --投资的结束时间
	local reward_endtime = pbdata.reward_endtime --奖励可领取的时间戳
	local mode = pbdata.mode --模式
	--todo
	g_ItemInvestCtrl:GS2CItemInvestState(state, invest_endtime, reward_endtime, mode)
end

function GS2CItemInvest(pbdata)
	local info = pbdata.info --投资道具的信息
	--todo
	g_ItemInvestCtrl:GS2CItemInvest(info)
end

function GS2CItemInvestUnit(pbdata)
	local invest_id = pbdata.invest_id --道具投资编号
	local day_info = pbdata.day_info --道具的领取状态
	--todo
	g_ItemInvestCtrl:GS2CItemInvestUnit(invest_id, day_info)
end

function GS2CImperialexamState(pbdata)
	local state = pbdata.state --活动开启状态 关闭 0 乡试 1  乡试结束--等待殿试 2 殿试 3
	--todo
	g_ExaminationCtrl:GS2CImperialexamState(state)
end

function GS2CImperialexamGiveQuestion(pbdata)
	local question_id = pbdata.question_id --题目的索引id
	local use_time = pbdata.use_time --到目前位置花费总时间
	local cur_round = pbdata.cur_round --当前问题轮数
	--todo
	g_ExaminationCtrl:GS2CImperialexamGiveQuestion(question_id, use_time, cur_round)
end

function GS2CImperialexamGiveAnswer(pbdata)
	local question_id = pbdata.question_id --题目的所以id
	local right_answer = pbdata.right_answer --正确答案
	local wrong_time = pbdata.wrong_time --错误罚时时长
	--todo
	g_ExaminationCtrl:GS2CImperialexamGiveAnswer(question_id, right_answer, wrong_time)
end

function GS2CTreasureConvoyState(pbdata)
	local state = pbdata.state --活动状态 1准备阶段 2开始阶段 3结束
	local end_time = pbdata.end_time --阶段的结束时间
	--todo
	g_MiBaoConvoyCtrl:GS2CTreasureConvoyState(state, end_time)
end

function GS2CTreasureConvoyInfo(pbdata)
	local convoy_count = pbdata.convoy_count --护送次数
	local rob_count = pbdata.rob_count --打劫次数
	local robbed_count = pbdata.robbed_count --被打劫次数
	local convoy_pregress = pbdata.convoy_pregress --当次护送进度
	local convoy_endtime = pbdata.convoy_endtime --当次护送结束时间戳
	--todo
	table.print(pbdata)
	printerror("------------GS2CTreasureConvoyInfo")
	g_MiBaoConvoyCtrl:GS2CTreasureConvoyInfo(pbdata)
end

function GS2CTreasureConvoyOpenView(pbdata)
	--todo
	g_MiBaoConvoyCtrl:GS2CTreasureConvoyOpenView(pbdata)
	
end

function GS2CTreasureConvoyFlag(pbdata)
	local flag = pbdata.flag --护送标记 1 有 0 没有
	--todo
	g_MiBaoConvoyCtrl:GS2CTreasureConvoyFlag(flag)
end

function GS2CDiscountSale(pbdata)
	local start_time = pbdata.start_time --开始时间
	local buy_info = pbdata.buy_info
	--todo
	g_TimelimitCtrl:GS2CDiscountSale(start_time, buy_info)
end

function GS2CForeShowInfo(pbdata)
	local info_list = pbdata.info_list --今日的展示列表
	--todo
	g_RecommendCtrl:GS2CForeShowInfo(info_list)
end

function GS2CZeroYuanInfo(pbdata)
	local activity_endtime = pbdata.activity_endtime --活动结束时间
	local info = pbdata.info --内容信息
	--todo
	g_ZeroBuyCtrl:GS2CZeroYuanInfo(pbdata)
end

function GS2CZeroYuanInfoUnit(pbdata)
	local unit_info = pbdata.unit_info --内容信息
	--todo
	g_ZeroBuyCtrl:GS2CZeroYuanInfoUnit(pbdata)
end

function GS2CRetrieveExp(pbdata)
	local retrieves = pbdata.retrieves --找回列表
	--todo
	g_ExpRecycleCtrl:GS2CRetrieveExp(pbdata)
end

function GS2CWorldCupState(pbdata)
	local state = pbdata.state --1 活动开启阶段 2 活动结束
	--todo
	g_SoccerWorldCupCtrl:GS2CWorldCupState(pbdata)
	g_SoccerWorldCupGuessCtrl:GS2CWorldCupState(pbdata)
	g_SoccerTeamSupportCtrl:GS2CWorldCupState(pbdata)
	g_SoccerWorldCupGuessHistoryTipCtrl:GS2CWorldCupState(pbdata)
end

function GS2CWorldCupSingleInfo(pbdata)
	local phase = pbdata.phase --阶段 1.小组赛 2.1/8决赛 3.1/4决赛 4.半决赛 5.季军赛 6决赛
	local games = pbdata.games --赛程信息
	--todo
	g_SoccerWorldCupGuessCtrl:GS2CWorldCupSingleInfo(pbdata)
end

function GS2CWorldCupSingleGuessInfo(pbdata)
	local guess_info = pbdata.guess_info
	--todo
	g_SoccerWorldCupGuessCtrl:GS2CWorldCupSingleGuessInfo(pbdata)
end

function GS2CWorldCupSingleGuessInfoUnit(pbdata)
	local guess_info_unit = pbdata.guess_info_unit
	--todo
	g_SoccerWorldCupGuessCtrl:GS2CWorldCupSingleGuessInfoUnit(pbdata)
end

function GS2CWorldCupHistory(pbdata)
	local history = pbdata.history
	local suc_count = pbdata.suc_count --自己猜中次数
	local suc_rate = pbdata.suc_rate --自己猜中胜率
	--todo
	g_SoccerWorldCupGuessHistoryTipCtrl:GS2CWorldCupHistory(pbdata)
end

function GS2CWorldCupChampionInfo(pbdata)
	local support_team = pbdata.support_team --支持队伍 没有的时候为0
	local out_team = pbdata.out_team --淘汰的队伍
	local support_info = pbdata.support_info --所有队伍的支持数据
	--todo
	g_SoccerTeamSupportCtrl:GS2CWorldCupChampionInfo(pbdata)
end

function GS2CWorldCupChampionInfoUnit(pbdata)
	local support_info_unit = pbdata.support_info_unit --单个队伍的支持数据
	--todo
	g_SoccerTeamSupportCtrl:GS2CWorldCupChampionInfoUnit(pbdata)
end

function GS2CZongziGameState(pbdata)
	local open = pbdata.open --1表示开启
	--todo
	g_DuanWuHuodongCtrl:GS2CZongziGameState(open)
end

function GS2CRefreshZongziGame(pbdata)
	local zongzi1 = pbdata.zongzi1 --甜粽子兑换数目
	local zongzi2 = pbdata.zongzi2 --咸粽子兑换数目
	local starttime = pbdata.starttime --活动开启时间
	local endtime = pbdata.endtime --活动结束时间
	local vote_num = pbdata.vote_num --当前拥有的票数
	local vote_buy = pbdata.vote_buy --元宝已购买的次数
	--todo
	g_DuanWuHuodongCtrl:GS2CRefreshZongziGame(pbdata)
end

function GS2CDuanwuQifuState(pbdata)
	local open = pbdata.open --1表示已开启
	--todo
	g_DuanWuHuodongCtrl:GS2CDuanwuQifuState(open)
end

function GS2CRefreshDuanwuQifu(pbdata)
	local mask = pbdata.mask
	local starttime = pbdata.starttime --开启时间
	local endtime = pbdata.endtime --结束时间
	local total = pbdata.total --已上交的祭品
	local reward_step = pbdata.reward_step --是否已领取奖励
	--todo
	g_DuanWuHuodongCtrl:GS2CRefreshDuanwuQifu(pbdata)
end


--C2GS--

function C2GSArenaFight(fight, enemy)
	local t = {
		fight = fight,
		enemy = enemy,
	}
	g_NetCtrl:Send("huodong", "C2GSArenaFight", t)
end

function C2GSArenaViewList()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSArenaViewList", t)
end

function C2GSArenaFightList(pidlst, team)
	local t = {
		pidlst = pidlst,
		team = team,
	}
	g_NetCtrl:Send("huodong", "C2GSArenaFightList", t)
end

function C2GSShootCrapOpen()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSShootCrapOpen", t)
end

function C2GSShootCrapStart()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSShootCrapStart", t)
end

function C2GSShootCrapEnd()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSShootCrapEnd", t)
end

function C2GSDanceStart(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("huodong", "C2GSDanceStart", t)
end

function C2GSDanceEnd()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSDanceEnd", t)
end

function C2GSDanceInspired()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSDanceInspired", t)
end

function C2GSDanceAuto()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSDanceAuto", t)
end

function C2GSCampfireAnswer(id, answer, fill_answer)
	local t = {
		id = id,
		answer = answer,
		fill_answer = fill_answer,
	}
	g_NetCtrl:Send("huodong", "C2GSCampfireAnswer", t)
end

function C2GSCampfireDesireQuestion()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSCampfireDesireQuestion", t)
end

function C2GSCampfireDrink(amount)
	local t = {
		amount = amount,
	}
	g_NetCtrl:Send("huodong", "C2GSCampfireDrink", t)
end

function C2GSCampfireQueryGiftables()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSCampfireQueryGiftables", t)
end

function C2GSCampfireGiftOut(target, quick)
	local t = {
		target = target,
		quick = quick,
	}
	g_NetCtrl:Send("huodong", "C2GSCampfireGiftOut", t)
end

function C2GSCampfireThankGift(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("huodong", "C2GSCampfireThankGift", t)
end

function C2GSSignInDone()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSignInDone", t)
end

function C2GSSignInReplenish()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSignInReplenish", t)
end

function C2GSSignInLottery()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSignInLottery", t)
end

function C2GSSignInMainInfo()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSignInMainInfo", t)
end

function C2GSMengzhuOpenPlayerRank()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSMengzhuOpenPlayerRank", t)
end

function C2GSMengzhuOpenOrgRank()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSMengzhuOpenOrgRank", t)
end

function C2GSMengzhuOpenPlunder()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSMengzhuOpenPlunder", t)
end

function C2GSMengzhuStartFightBoss()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSMengzhuStartFightBoss", t)
end

function C2GSMengzhuStartPlunder(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("huodong", "C2GSMengzhuStartPlunder", t)
end

function C2GSMengzhuMainUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSMengzhuMainUI", t)
end

function C2GSBWRank()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSBWRank", t)
end

function C2GSBWMakeTeam(op)
	local t = {
		op = op,
	}
	g_NetCtrl:Send("huodong", "C2GSBWMakeTeam", t)
end

function C2GSSchoolPassClickNpc()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSchoolPassClickNpc", t)
end

function C2GSOrgTaskRandTask()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOrgTaskRandTask", t)
end

function C2GSOrgTaskResetStar()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOrgTaskResetStar", t)
end

function C2GSOrgTaskReceiveTask()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOrgTaskReceiveTask", t)
end

function C2GSOrgTaskFindNPC()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOrgTaskFindNPC", t)
end

function C2GSBaikeOpenUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSBaikeOpenUI", t)
end

function C2GSBaikeChooseAnswer(id, answer, cost_time)
	local t = {
		id = id,
		answer = answer,
		cost_time = cost_time,
	}
	g_NetCtrl:Send("huodong", "C2GSBaikeChooseAnswer", t)
end

function C2GSBaikeLinkAnswer(id, answer, cost_time)
	local t = {
		id = id,
		answer = answer,
		cost_time = cost_time,
	}
	g_NetCtrl:Send("huodong", "C2GSBaikeLinkAnswer", t)
end

function C2GSBaikeGetNextQuestion()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSBaikeGetNextQuestion", t)
end

function C2GSBaikeWeekRank()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSBaikeWeekRank", t)
end

function C2GSChargeRewardGradeGift(type, grade)
	local t = {
		type = type,
		grade = grade,
	}
	g_NetCtrl:Send("huodong", "C2GSChargeRewardGradeGift", t)
end

function C2GSChargeRewardGoldCoinGift(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSChargeRewardGoldCoinGift", t)
end

function C2GSChargeCheckBuy(reward_key)
	local t = {
		reward_key = reward_key,
	}
	g_NetCtrl:Send("huodong", "C2GSChargeCheckBuy", t)
end

function C2GSChargeGetDayReward(reward_key)
	local t = {
		reward_key = reward_key,
	}
	g_NetCtrl:Send("huodong", "C2GSChargeGetDayReward", t)
end

function C2GSBottleDetail(bottle)
	local t = {
		bottle = bottle,
	}
	g_NetCtrl:Send("huodong", "C2GSBottleDetail", t)
end

function C2GSBottleSend(bottle, content)
	local t = {
		bottle = bottle,
		content = content,
	}
	g_NetCtrl:Send("huodong", "C2GSBottleSend", t)
end

function C2GSLMLookInfo(school)
	local t = {
		school = school,
	}
	g_NetCtrl:Send("huodong", "C2GSLMLookInfo", t)
end

function C2GSLingxiPaticipate()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSLingxiPaticipate", t)
end

function C2GSLingxiClickAcceptTask()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSLingxiClickAcceptTask", t)
end

function C2GSLingxiClickMatch()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSLingxiClickMatch", t)
end

function C2GSLingxiStopMatch()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSLingxiStopMatch", t)
end

function C2GSRewardFirstPayGift(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSRewardFirstPayGift", t)
end

function C2GSRewardWelfareGift(type, gift_key)
	local t = {
		type = type,
		gift_key = gift_key,
	}
	g_NetCtrl:Send("huodong", "C2GSRewardWelfareGift", t)
end

function C2GSJoinJYFuben()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSJoinJYFuben", t)
end

function C2GSRedeemCollectGift(gift_key)
	local t = {
		gift_key = gift_key,
	}
	g_NetCtrl:Send("huodong", "C2GSRedeemCollectGift", t)
end

function C2GSCaishenStartChoose(reward_key)
	local t = {
		reward_key = reward_key,
	}
	g_NetCtrl:Send("huodong", "C2GSCaishenStartChoose", t)
end

function C2GSCaishenOpenUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSCaishenOpenUI", t)
end

function C2GSCaishenRefreshRecordList(time)
	local t = {
		time = time,
	}
	g_NetCtrl:Send("huodong", "C2GSCaishenRefreshRecordList", t)
end

function C2GSOrgWarOpenMatchList(week_day)
	local t = {
		week_day = week_day,
	}
	g_NetCtrl:Send("huodong", "C2GSOrgWarOpenMatchList", t)
end

function C2GSOrgWarTryGotoNpc()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOrgWarTryGotoNpc", t)
end

function C2GSOrgWarOpenTeamUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOrgWarOpenTeamUI", t)
end

function C2GSOrgWarOpenWarScoreUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOrgWarOpenWarScoreUI", t)
end

function C2GSOrgWarStartFight(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("huodong", "C2GSOrgWarStartFight", t)
end

function C2GSOrgTaskStarReward()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOrgTaskStarReward", t)
end

function C2GSTrialOpenUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSTrialOpenUI", t)
end

function C2GSTiralStartFight()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSTiralStartFight", t)
end

function C2GSTrialGetReward(pos)
	local t = {
		pos = pos,
	}
	g_NetCtrl:Send("huodong", "C2GSTrialGetReward", t)
end

function C2GSHfdmEnter()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSHfdmEnter", t)
end

function C2GSHfdmSelect(ques_id, answer)
	local t = {
		ques_id = ques_id,
		answer = answer,
	}
	g_NetCtrl:Send("huodong", "C2GSHfdmSelect", t)
end

function C2GSHfdmUseSkill(id, target, my_answer)
	local t = {
		id = id,
		target = target,
		my_answer = my_answer,
	}
	g_NetCtrl:Send("huodong", "C2GSHfdmUseSkill", t)
end

function C2GSGrowReward(index)
	local t = {
		index = index,
	}
	g_NetCtrl:Send("huodong", "C2GSGrowReward", t)
end

function C2GSReturnGoldCoinGetReturn(key)
	local t = {
		key = key,
	}
	g_NetCtrl:Send("huodong", "C2GSReturnGoldCoinGetReturn", t)
end

function C2GSReturnGoldCoinGetFreeGift()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSReturnGoldCoinGetFreeGift", t)
end

function C2GSReturnGoldCoinBuyGift(key)
	local t = {
		key = key,
	}
	g_NetCtrl:Send("huodong", "C2GSReturnGoldCoinBuyGift", t)
end

function C2GSKFGetTXRank()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSKFGetTXRank", t)
end

function C2GSKFGetOrgLevelReward(level)
	local t = {
		level = level,
	}
	g_NetCtrl:Send("huodong", "C2GSKFGetOrgLevelReward", t)
end

function C2GSKFGetOrgCntReward(cnt)
	local t = {
		cnt = cnt,
	}
	g_NetCtrl:Send("huodong", "C2GSKFGetOrgCntReward", t)
end

function C2GSKFGetScoreReward(score)
	local t = {
		score = score,
	}
	g_NetCtrl:Send("huodong", "C2GSKFGetScoreReward", t)
end

function C2GSKFGetGradeReward(grade)
	local t = {
		grade = grade,
	}
	g_NetCtrl:Send("huodong", "C2GSKFGetGradeReward", t)
end

function C2GSKFGetRankReward()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSKFGetRankReward", t)
end

function C2GSSevenDayGetReward(day)
	local t = {
		day = day,
	}
	g_NetCtrl:Send("huodong", "C2GSSevenDayGetReward", t)
end

function C2GSEveryDayChargeGetReward(day, flag)
	local t = {
		day = day,
		flag = flag,
	}
	g_NetCtrl:Send("huodong", "C2GSEveryDayChargeGetReward", t)
end

function C2GSOnlineGift(key)
	local t = {
		key = key,
	}
	g_NetCtrl:Send("huodong", "C2GSOnlineGift", t)
end

function C2GSSuperRebateGetReward()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSuperRebateGetReward", t)
end

function C2GSSuperRebateGetRecord()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSuperRebateGetRecord", t)
end

function C2GSSuperRebateLottery()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSuperRebateLottery", t)
end

function C2GSTotalChargeGetReward(level)
	local t = {
		level = level,
	}
	g_NetCtrl:Send("huodong", "C2GSTotalChargeGetReward", t)
end

function C2GSTotalChargeSetChoice(level, slot, index)
	local t = {
		level = level,
		slot = slot,
		index = index,
	}
	g_NetCtrl:Send("huodong", "C2GSTotalChargeSetChoice", t)
end

function C2GSFightGiftbagGetReward(score)
	local t = {
		score = score,
	}
	g_NetCtrl:Send("huodong", "C2GSFightGiftbagGetReward", t)
end

function C2GSFightGiftbagGetInfo()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSFightGiftbagGetInfo", t)
end

function C2GSFightGiftbagSetChoice(score, slot, index)
	local t = {
		score = score,
		slot = slot,
		index = index,
	}
	g_NetCtrl:Send("huodong", "C2GSFightGiftbagSetChoice", t)
end

function C2GSDayExpenseGetReward(group_key, reward_key)
	local t = {
		group_key = group_key,
		reward_key = reward_key,
	}
	g_NetCtrl:Send("huodong", "C2GSDayExpenseGetReward", t)
end

function C2GSDayExpenseSetRewardOption(group_key, reward_key, grid, option)
	local t = {
		group_key = group_key,
		reward_key = reward_key,
		grid = grid,
		option = option,
	}
	g_NetCtrl:Send("huodong", "C2GSDayExpenseSetRewardOption", t)
end

function C2GSDayExpenseOpenRewardUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSDayExpenseOpenRewardUI", t)
end

function C2GSOpenFuYuanBox(box_idx, times, use_goldcoin)
	local t = {
		box_idx = box_idx,
		times = times,
		use_goldcoin = use_goldcoin,
	}
	g_NetCtrl:Send("huodong", "C2GSOpenFuYuanBox", t)
end

function C2GSThreeBWGetFirstReward()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSThreeBWGetFirstReward", t)
end

function C2GSThreeBWGetFiveReward()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSThreeBWGetFiveReward", t)
end

function C2GSThreeBWGetRankInfo()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSThreeBWGetRankInfo", t)
end

function C2GSThreeSetMatch(match)
	local t = {
		match = match,
	}
	g_NetCtrl:Send("huodong", "C2GSThreeSetMatch", t)
end

function C2GSRewardSecondPayGift()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSRewardSecondPayGift", t)
end

function C2GSOpenActivePointGiftView()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOpenActivePointGiftView", t)
end

function C2GSSetActivePointGiftGridOption(point_key, grid_id, option)
	local t = {
		point_key = point_key,
		grid_id = grid_id,
		option = option,
	}
	g_NetCtrl:Send("huodong", "C2GSSetActivePointGiftGridOption", t)
end

function C2GSGetActivePointGift(point_key)
	local t = {
		point_key = point_key,
	}
	g_NetCtrl:Send("huodong", "C2GSGetActivePointGift", t)
end

function C2GSGetActivePointGiftByGoldCoin(point_key)
	local t = {
		point_key = point_key,
	}
	g_NetCtrl:Send("huodong", "C2GSGetActivePointGiftByGoldCoin", t)
end

function C2GSJuBaoPen(times)
	local t = {
		times = times,
	}
	g_NetCtrl:Send("huodong", "C2GSJuBaoPen", t)
end

function C2GSJuBaoPenScoreReward(score)
	local t = {
		score = score,
	}
	g_NetCtrl:Send("huodong", "C2GSJuBaoPenScoreReward", t)
end

function C2GSOpenJuBaoPenView()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOpenJuBaoPenView", t)
end

function C2GSQiFuGetDegreeReward(degree)
	local t = {
		degree = degree,
	}
	g_NetCtrl:Send("huodong", "C2GSQiFuGetDegreeReward", t)
end

function C2GSQiFuGetLotteryReward(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("huodong", "C2GSQiFuGetLotteryReward", t)
end

function C2GSDrawCardOpenView()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSDrawCardOpenView", t)
end

function C2GSDrawCardBuyTimes()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSDrawCardBuyTimes", t)
end

function C2GSDrawCardOpenOne(card_id)
	local t = {
		card_id = card_id,
	}
	g_NetCtrl:Send("huodong", "C2GSDrawCardOpenOne", t)
end

function C2GSDrawCardOpenList()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSDrawCardOpenList", t)
end

function C2GSDrawCardReset()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSDrawCardReset", t)
end

function C2GSDrawCardStart()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSDrawCardStart", t)
end

function C2GSDrawCardSetPopupState(popup_state)
	local t = {
		popup_state = popup_state,
	}
	g_NetCtrl:Send("huodong", "C2GSDrawCardSetPopupState", t)
end

function C2GSContinuousChargeSetChoice(type, day, slot, index)
	local t = {
		type = type,
		day = day,
		slot = slot,
		index = index,
	}
	g_NetCtrl:Send("huodong", "C2GSContinuousChargeSetChoice", t)
end

function C2GSContinuousChargeReward(day)
	local t = {
		day = day,
	}
	g_NetCtrl:Send("huodong", "C2GSContinuousChargeReward", t)
end

function C2GSContinuousChargeTotalReward(day)
	local t = {
		day = day,
	}
	g_NetCtrl:Send("huodong", "C2GSContinuousChargeTotalReward", t)
end

function C2GSContinuousExpenseSetChoice(type, day, slot, index)
	local t = {
		type = type,
		day = day,
		slot = slot,
		index = index,
	}
	g_NetCtrl:Send("huodong", "C2GSContinuousExpenseSetChoice", t)
end

function C2GSContinuousExpenseReward(day)
	local t = {
		day = day,
	}
	g_NetCtrl:Send("huodong", "C2GSContinuousExpenseReward", t)
end

function C2GSContinuousExpenseTotalReward(day)
	local t = {
		day = day,
	}
	g_NetCtrl:Send("huodong", "C2GSContinuousExpenseTotalReward", t)
end

function C2GSFengYaoAutoFindNPC()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSFengYaoAutoFindNPC", t)
end

function C2GSShootCrapsExchangeCnt()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSShootCrapsExchangeCnt", t)
end

function C2GSNianShouFindNPC()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSNianShouFindNPC", t)
end

function C2GSGoldCoinPartyGetDegreeReward(degree)
	local t = {
		degree = degree,
	}
	g_NetCtrl:Send("huodong", "C2GSGoldCoinPartyGetDegreeReward", t)
end

function C2GSGoldCoinPartyGetLotteryReward(lottery, flag)
	local t = {
		lottery = lottery,
		flag = flag,
	}
	g_NetCtrl:Send("huodong", "C2GSGoldCoinPartyGetLotteryReward", t)
end

function C2GSGoldCoinPartyGetRewardInfo()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSGoldCoinPartyGetRewardInfo", t)
end

function C2GSMysticalboxOperateBox(operator)
	local t = {
		operator = operator,
	}
	g_NetCtrl:Send("huodong", "C2GSMysticalboxOperateBox", t)
end

function C2GSJieBaiCreate()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSJieBaiCreate", t)
end

function C2GSJBInvite(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("huodong", "C2GSJBInvite", t)
end

function C2GSJBArgeeInvite()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSJBArgeeInvite", t)
end

function C2GSJBDisgrgeeInvite()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSJBDisgrgeeInvite", t)
end

function C2GSJBKickInvite(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("huodong", "C2GSJBKickInvite", t)
end

function C2GSQuitJieBai()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSQuitJieBai", t)
end

function C2GSReleaseJieBai()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSReleaseJieBai", t)
end

function C2GSJBPreStart()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSJBPreStart", t)
end

function C2GSJBJoinYiShi()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSJBJoinYiShi", t)
end

function C2GSJBSetTitle(title)
	local t = {
		title = title,
	}
	g_NetCtrl:Send("huodong", "C2GSJBSetTitle", t)
end

function C2GSJBSetMingHao(minghao)
	local t = {
		minghao = minghao,
	}
	g_NetCtrl:Send("huodong", "C2GSJBSetMingHao", t)
end

function C2GSJBJingJiu()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSJBJingJiu", t)
end

function C2GSJBEnounce(enounce)
	local t = {
		enounce = enounce,
	}
	g_NetCtrl:Send("huodong", "C2GSJBEnounce", t)
end

function C2GSJBKickMember(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("huodong", "C2GSJBKickMember", t)
end

function C2GSJBVoteKickMember(op)
	local t = {
		op = op,
	}
	g_NetCtrl:Send("huodong", "C2GSJBVoteKickMember", t)
end

function C2GSJBGetValidInviter()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSJBGetValidInviter", t)
end

function C2GSJBClickRedPoint(type_list)
	local t = {
		type_list = type_list,
	}
	g_NetCtrl:Send("huodong", "C2GSJBClickRedPoint", t)
end

function C2GSLuanShiMoYing()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSLuanShiMoYing", t)
end

function C2GSJoyExpenseBuyGood(shop, goodid, moneytype, amount)
	local t = {
		shop = shop,
		goodid = goodid,
		moneytype = moneytype,
		amount = amount,
	}
	g_NetCtrl:Send("huodong", "C2GSJoyExpenseBuyGood", t)
end

function C2GSJoyExpenseGetReward(expense_id)
	local t = {
		expense_id = expense_id,
	}
	g_NetCtrl:Send("huodong", "C2GSJoyExpenseGetReward", t)
end

function C2GSSingleWarStartMatch()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSingleWarStartMatch", t)
end

function C2GSSingleWarStopMatch()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSingleWarStopMatch", t)
end

function C2GSSingleWarGetRewardFirst()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSingleWarGetRewardFirst", t)
end

function C2GSSingleWarGetRewardFive()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSingleWarGetRewardFive", t)
end

function C2GSSingleWarRank(group_id)
	local t = {
		group_id = group_id,
	}
	g_NetCtrl:Send("huodong", "C2GSSingleWarRank", t)
end

function C2GSItemInvest(invest_id)
	local t = {
		invest_id = invest_id,
	}
	g_NetCtrl:Send("huodong", "C2GSItemInvest", t)
end

function C2GSItemInvestReward(invest_id)
	local t = {
		invest_id = invest_id,
	}
	g_NetCtrl:Send("huodong", "C2GSItemInvestReward", t)
end

function C2GSItemInvestDayReward(invest_id, day)
	local t = {
		invest_id = invest_id,
		day = day,
	}
	g_NetCtrl:Send("huodong", "C2GSItemInvestDayReward", t)
end

function C2GSImperialexamAnswerQuestion(question_id, answer)
	local t = {
		question_id = question_id,
		answer = answer,
	}
	g_NetCtrl:Send("huodong", "C2GSImperialexamAnswerQuestion", t)
end

function C2GSTreasureConvoySelectTask(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSTreasureConvoySelectTask", t)
end

function C2GSTreasureConvoyRob(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("huodong", "C2GSTreasureConvoyRob", t)
end

function C2GSTreasureConvoyMatchRob()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSTreasureConvoyMatchRob", t)
end

function C2GSTreasureConvoyEnterNpcArea(npcid)
	local t = {
		npcid = npcid,
	}
	g_NetCtrl:Send("huodong", "C2GSTreasureConvoyEnterNpcArea", t)
end

function C2GSTreasureConvoyExitNpcArea(npcid)
	local t = {
		npcid = npcid,
	}
	g_NetCtrl:Send("huodong", "C2GSTreasureConvoyExitNpcArea", t)
end

function C2GSBuyDiscountSale(day)
	local t = {
		day = day,
	}
	g_NetCtrl:Send("huodong", "C2GSBuyDiscountSale", t)
end

function C2GSZeroYuanBuy(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSZeroYuanBuy", t)
end

function C2GSZeroYuanReward(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSZeroYuanReward", t)
end

function C2GSRetrieveExp(scheduleids, nowtime, type)
	local t = {
		scheduleids = scheduleids,
		nowtime = nowtime,
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSRetrieveExp", t)
end

function C2GSWorldCupSingle(game_id, team_id)
	local t = {
		game_id = game_id,
		team_id = team_id,
	}
	g_NetCtrl:Send("huodong", "C2GSWorldCupSingle", t)
end

function C2GSWorldCupChampion(type, team_id)
	local t = {
		type = type,
		team_id = team_id,
	}
	g_NetCtrl:Send("huodong", "C2GSWorldCupChampion", t)
end

function C2GSWorldCupHistory()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSWorldCupHistory", t)
end

function C2GSZongziOpenUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSZongziOpenUI", t)
end

function C2GSZongziExchange(type, goldcoin)
	local t = {
		type = type,
		goldcoin = goldcoin,
	}
	g_NetCtrl:Send("huodong", "C2GSZongziExchange", t)
end

function C2GSDuanwuQifuOpenUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSDuanwuQifuOpenUI", t)
end

function C2GSDuanwuQifuSubmit()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSDuanwuQifuSubmit", t)
end

function C2GSDuanwuQifuReward(step)
	local t = {
		step = step,
	}
	g_NetCtrl:Send("huodong", "C2GSDuanwuQifuReward", t)
end

function C2GSEnterOrgHuodong(name)
	local t = {
		name = name,
	}
	g_NetCtrl:Send("huodong", "C2GSEnterOrgHuodong", t)
end


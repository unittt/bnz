module(..., package.seeall)

--GS2C--

function GS2CLoadUI(pbdata)
	local sessionidx = pbdata.sessionidx --回调id
	local type = pbdata.type --类型
	local tip = pbdata.tip --提示
	local time = pbdata.time --时间
	--todo
end

function GS2CPopTaskItem(pbdata)
	local sessionidx = pbdata.sessionidx --回调id
	local taskid = pbdata.taskid --任务id
	local owner = pbdata.owner --任务属主pid
	--todo
	CTaskHelp.SetClickTaskExecute(nil)
	g_WindowTipCtrl:SetWindowCommitItem(sessionidx, taskid, owner)
end

function GS2CPopTaskSummon(pbdata)
	local sessionidx = pbdata.sessionidx --回调id
	local taskid = pbdata.taskid --任务id
	local owner = pbdata.owner --任务属主pid
	--todo
	CTaskHelp.SetClickTaskExecute(nil)
	g_WindowTipCtrl:SetWindowCommitSummon(sessionidx, taskid, owner)
end

function GS2COpenShopForTask(pbdata)
	local sessionidx = pbdata.sessionidx --回调id
	local taskid = pbdata.taskid
	local owner = pbdata.owner --任务属主pid
	--todo
	g_TaskCtrl:GS2COpenShopForTask(pbdata)
end

function GS2CHelpTaskGiveItem(pbdata)
	local sessionidx = pbdata.sessionidx --回调id
	local taskid = pbdata.taskid --任务id
	local owner = pbdata.owner --任务属主pid
	--todo
	g_TaskCtrl:GS2CHelpTaskGiveItem(pbdata)
end

function GS2CShortWay(pbdata)
	local type = pbdata.type --1:金币,2:银币,3:铜币
	--todo
	g_TreasureCtrl:GS2CShortWay(pbdata)
end

function GS2CConfirmUI(pbdata)
	local sessionidx = pbdata.sessionidx --回调id
	local sContent = pbdata.sContent --弹框内容
	local sConfirm = pbdata.sConfirm --确认按钮内容
	local sCancle = pbdata.sCancle --取消按钮内容
	local time = pbdata.time --默认按钮时间,单位为秒
	local default = pbdata.default --默认按钮内容, 1-sConfirm 0-sCancle
	local extend_close = pbdata.extend_close --框外点击关闭 1-close
	local replace = pbdata.replace --0-顶掉(默认是0)　 1-不顶
	local close_btn = pbdata.close_btn --0表示X按钮不发协议
	--todo
	local windowConfirmInfo = {
		msg				= "#D"..sContent,
		okCallback		= function ()
			netother.C2GSCallback(sessionidx, 1)		--1代表同意
		end,
		cancelCallback  = function()
			netother.C2GSCallback(sessionidx, 0)
		end,
		thirdCallback	= function ()
			netother.C2GSCallback(sessionidx, 1)		--1代表同意
		end,
		okStr			= sConfirm,
		cancelStr		= sCancle,
		thirdStr		= (sCancle == "" and {sConfirm} or {nil})[1],
		countdown       = time,
		default         = default,
		closeType		= extend_close == 0 and 1 or extend_close,
		style           = sCancle == "" and 1 or 2,
		color           = Color.white,
		close_btn		= close_btn,
	}

	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function GS2CSchedule(pbdata)
	local hdlist = pbdata.hdlist
	local schedules = pbdata.schedules
	local activepoint = pbdata.activepoint
	local rewardidx = pbdata.rewardidx
	local curtime = pbdata.curtime
	local db_point = pbdata.db_point
	local db_point_limit = pbdata.db_point_limit
	--todo
	g_ScheduleCtrl:GS2CSchedule(pbdata)
end

function GS2CWeekSchedule(pbdata)
	local weekschedule = pbdata.weekschedule
	--todo
	g_ScheduleCtrl:GS2CWeekSchedule(pbdata)
end

function GS2CGetScheduleReward(pbdata)
	local rewardidx = pbdata.rewardidx
	--todo
	g_ScheduleCtrl:GS2CGetScheduleReward(rewardidx)
end

function GS2COpenShop(pbdata)
	local shop_id = pbdata.shop_id --商城id
	--todo
	--以后要根据需求增加，这里是处理每一个不同的商店
	g_ShopCtrl:OpenShop(shop_id)
end

function GS2CRefreshSchedule(pbdata)
	local schedule = pbdata.schedule
	local activepoint = pbdata.activepoint
	--todo
	g_AttrCtrl:UpdateAttr({activepoint = activepoint})
	g_ScheduleCtrl:GS2CRefreshSchedule(pbdata)
end

function GS2CXunLuo(pbdata)
	local type = pbdata.type --1:开始,0:结束
	--todo
	g_MapCtrl:SetAutoPatrol(type == 1, type == 1)
end

function GS2COpenCultivateUI(pbdata)
	--todo
	CSkillMainView:ShowView(function(oView)
		oView:ShowSubPageByIndex(oView:GetPageIndex("Cultivation"))
	end)
end

function GS2CCloseConfirmUI(pbdata)
	local sessionidx = pbdata.sessionidx
	--todo
	local oView = CWindowComfirmView:GetView()
	if oView then
		oView:OnClose()
	end
end

function GS2CRefreshDoublePoint(pbdata)
	local db_point = pbdata.db_point
	local db_point_limit = pbdata.db_point_limit
	--todo
	g_ScheduleCtrl:GS2CRefreshDoublePoint(db_point, db_point_limit)
	g_MainMenuCtrl:RefreshDoublePoint(db_point)
end

function GS2CRefreshHuodongState(pbdata)
	local hdlist = pbdata.hdlist
	--todo
	g_ScheduleCtrl:GS2CRefreshHuodongState(hdlist)
	g_BaikeCtrl:GS2CRefreshHuodongState(hdlist)
end

function GS2CRefreshAllHuodongState(pbdata)
	local hdlist = pbdata.hdlist
	--todo
	g_ScheduleCtrl:GS2CRefreshAllHuodongState(hdlist)
end

function GS2COpenScheduleUI(pbdata)
	local schedule_id = pbdata.schedule_id
	--todo
	g_ScheduleCtrl:GS2COpenScheduleUI(schedule_id)
end

function GS2COpenTeamAutoMatchUI(pbdata)
	local auto_target = pbdata.auto_target
	--todo
	g_TeamCtrl:TeamAutoMatch(auto_target)
end

function GS2COpenYibaoUI(pbdata)
	local mask = pbdata.mask
	local owner = pbdata.owner --面板属于哪个玩家(pid)
	local create_day = pbdata.create_day --异宝创建日期（上行时使用）
	local seek_gather_tasks = pbdata.seek_gather_tasks --异宝寻物的已用求助的任务id
	local seek_gather_max = pbdata.seek_gather_max --异宝寻物的最大求助次数
	local done_yibao_info = pbdata.done_yibao_info --已经完成的异宝任务信息(因为此任务已经删除，但要显示在UI)
	local doing_yibao_info = pbdata.doing_yibao_info --正在进行的异宝任务信息(因为这个面板可以显示其他玩家的任务状况，自己看自己则不需要此数据)
	local main_yibao_info = pbdata.main_yibao_info --主任务信息，主要是预览奖励
	--todo
	local data = g_NetCtrl:DecodeMaskData(pbdata, "YibaoUI")
	g_YibaoCtrl:GS2COpenYibaoUI(data)
end

function GS2CYibaoTaskDone(pbdata)
	local taskid = pbdata.taskid
	local is_gather_help = pbdata.is_gather_help --是不是找物协助完成的 1是 0不是
	--todo
	g_YibaoCtrl:GS2CYibaoTaskDone(pbdata)
end

function GS2CYibaoTaskRefresh(pbdata)
	local yibao_info = pbdata.yibao_info
	--todo
	g_YibaoCtrl:GS2CYibaoTaskRefresh(pbdata)
end

function GS2CYibaoSeekHelpSucc(pbdata)
	local taskid = pbdata.taskid
	--todo
	g_YibaoCtrl:GS2CYibaoSeekHelpSucc(pbdata)
end

function GS2COpenArenaUI(pbdata)
	--todo
	CArenaMainView:ShowView()
end

function GS2COpenOrgUI(pbdata)
	--todo
	g_OrgCtrl:OpenOrgView()
end

function GS2COpenOrgBuild(pbdata)
	local bid = pbdata.bid --建筑id
	--todo
	COrgInfoView:ShowView(function(oView)
		oView:ShowSubPageByIndex(oView:GetPageIndex("Building"))
		local oPage = oView.m_CurPage
		oPage:JumpToTargetBuilding(bid)
	end)
end

function GS2CPlayQte(pbdata)
	local sessionidx = pbdata.sessionidx
	local qteid = pbdata.qteid
	local lasts = pbdata.lasts --区别与QTE表中的时间，为另外规定
	local forthdone = pbdata.forthdone --1是/0否强制完成
	--todo
	g_YibaoCtrl:GS2CPlayQte(pbdata)
end

function GS2CPlayAnime(pbdata)
	local sessionidx = pbdata.sessionidx
	local anime_id = pbdata.anime_id
	--todo
	if anime_id >= 999 then
		g_WarCtrl.m_WarSessionidx = sessionidx
		warsimulate.FirstSpecityWar()
		return
	end
	g_TaskCtrl:GS2CPlayAnime(pbdata)
end

function GS2COpenEquipMake(pbdata)
	--todo
	CForgeMainView:ShowView()
end

function GS2CPlayLottery(pbdata)
	local sessionidx = pbdata.sessionidx
	local type = pbdata.type --类型 1001:签到抽奖
	local idx = pbdata.idx --奖励项idx
	--todo

	g_LotteryCtrl:GS2CPlayLottery(pbdata)

end

function GS2COpenFBChoice(pbdata)
	local flag = pbdata.flag --1.普通副本 2.精英副本
	--todo
	if 2 == flag then
		CDungeonMainView:ShowView(function(oView)
			oView:RefreshDungeonGrid(pbdata.flag)
		end)
	else
		CDungeonNewMainView:ShowView()
	end
end

function GS2CCloseFBComfirm(pbdata)
	local sessionidx = pbdata.sessionidx
	--todo
	local oView = CDungeonConfirmView:GetView() 
	if oView then
		oView:CloseView()
	end
	g_DungeonCtrl:OnEvent(define.Dungeon.Event.FinishComfirm)
end

function GS2CFBComfirmEnter(pbdata)
	local sessionidx = pbdata.sessionidx
	local pid = pbdata.pid
	--todo
	g_DungeonCtrl:SetPlayerConfirmStatus(pid)
end

function GS2CFBComfirm(pbdata)
	local fuben = pbdata.fuben
	local time = pbdata.time
	local plist = pbdata.plist --成员状态
	local sessionidx = pbdata.sessionidx
	--todo
	CDungeonConfirmView:ShowView(function(oView)
		g_DungeonCtrl:UpdateConfirmState(fuben, time, plist, sessionidx)
	end)
end

function GS2CRefreshFBComfirm(pbdata)
	local fuben = pbdata.fuben
	local time = pbdata.time
	local plist = pbdata.plist --成员状态
	local sessionidx = pbdata.sessionidx
	--todo
	g_DungeonCtrl:UpdateConfirmState(fuben, time, plist, sessionidx)
end

function GS2CFBOver(pbdata)
	local fuben = pbdata.fuben
	local exp = pbdata.exp
	local expradio = pbdata.expradio
	local silver = pbdata.silver
	local silverradio = pbdata.silverradio
	local level = pbdata.level
	local point = pbdata.point
	local itemlist = pbdata.itemlist
	--todo
	-- 播放胜利音效
	g_AudioCtrl:NpcPath(define.Audio.MusicPath.warwin, 0.1)

	g_DungeonTaskCtrl:FubenOver()
	CDungeonRewardView:ShowView(function(oView)
		oView:SetRewardInfo(pbdata)
	end)
end

function GS2CMaintainUI(pbdata)
	--todo
	local windowConfirmInfo = {
		msg = "服务器正在维护中",
		thirdStr = "确定",
		thirdCallback = function ()
			-- 返回登录界面
			if g_LoginPhoneCtrl.m_IsPC then
				g_LoginPhoneCtrl:ResetAllData()
            	CLoginPhoneView:ShowView(function (oView) oView:RefreshUI() end)
	        else
	        	if g_LoginPhoneCtrl.m_IsQrPC then
	        		g_LoginPhoneCtrl:ResetAllData()
	        		CLoginPhoneView:ShowView(function (oView)
		                oView:RefreshUI()
		                --这里是在有中心服的数据情况下
		                g_ServerPhoneCtrl:OnEvent(define.Login.Event.ServerListSuccess)
		            end)
	        	else
	            	g_SdkCtrl:Logout()
	            end
	        end
		end,
		style = CWindowComfirmView.Style.Single,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function GS2COpenAdvanceMap(pbdata)
	local itemid = pbdata.itemid
	--todo
	CTreasureCtrl:GS2COpenAdvanceMap(pbdata)
end

function GS2COpenBoxUI(pbdata)
	local box_sid = pbdata.box_sid
	local reward_item = pbdata.reward_item --此项存在则表示宝箱是开箱展示奖品
	--todo
	g_ItemCtrl:GS2COpenBoxUI(box_sid, reward_item)
end

function GS2CQuickBuyItemUI(pbdata)
	local sid = pbdata.sid
	local amount = pbdata.amount --欲购买数量(默认填缺额)
	local msg = pbdata.msg --提示消息
	--todo
end

function GS2CQuickBuyItemSucc(pbdata)
	local sid = pbdata.sid
	--todo
	g_ItemCtrl:GS2CQuickBuyItemSucc(sid)
end

function GS2CCustomShowItem(pbdata)
	local flag = pbdata.flag --1.骰子幸运奖励
	local itemlist = pbdata.itemlist
	--todo
	g_NotifyCtrl:OnEvent(define.Notify.Event.FloatItem, {flag = flag, itemlist = itemlist})
end

function GS2CCloseProgressBar(pbdata)
	local sessionidx = pbdata.sessionidx
	--todo
	g_LingxiCtrl:GS2CCloseProgressBar(pbdata)
end

function GS2CShowProgressBar(pbdata)
	local sessionidx = pbdata.sessionidx
	local msg = pbdata.msg --信息
	local sec = pbdata.sec --持续秒数
	local start_sec = pbdata.start_sec --从x秒开始
	local uninterruptable = pbdata.uninterruptable --是1否0不可中断
	local modal = pbdata.modal --是1否0模态
	local pos = pbdata.pos --坐标区域(按电话机数字分布)
	--todo
	g_LingxiCtrl:GS2CShowProgressBar(pbdata)
end

function GS2CRemoveConfirmUI(pbdata)
	local msg = pbdata.msg
	local session = pbdata.session --回调的ID
	--todo
end

function GS2CGuideBehavior(pbdata)
	local behavior = pbdata.behavior --行为id（见文档）
	--todo
	g_TaskCtrl:GS2CGuideBehavior(pbdata)
end

function GS2CExchangeMoney(pbdata)
	local moneytype = pbdata.moneytype --1.金币 2.银币
	local goldcoin = pbdata.goldcoin --消耗元宝数量
	local value = pbdata.value --需要货币具体数值
	--todo
	g_QuickGetCtrl:GS2CExchangeMoney(moneytype, goldcoin, value)
end

function GS2CExecAfterExchange(pbdata)
	local moneytype = pbdata.moneytype --1.金币 2.银币
	local goldcoin = pbdata.goldcoin --消耗元宝数量 (货币和道具)
	local moneyvalue = pbdata.moneyvalue --需要货币具体数值
	local itemlist = pbdata.itemlist
	local sessionidx = pbdata.sessionidx
	local exchangemoneyvalue = pbdata.exchangemoneyvalue --兑换货币数值
	local flag = pbdata.flag --1.法宝
	--todo
end

function GS2CRefreshFubenRewardCnt(pbdata)
	local reward_list = pbdata.reward_list
	--todo
	g_DungeonCtrl:GS2CRefreshFubenRewardCnt(reward_list)
end

function GS2CShowIntruction(pbdata)
	local id = pbdata.id
	--todo
	g_NianShouCtrl:GS2CShowIntruction(id)
end


--C2GS--

function C2GSOpenScheduleUI()
	local t = {
	}
	g_NetCtrl:Send("openui", "C2GSOpenScheduleUI", t)
end

function C2GSWeekSchedule()
	local t = {
	}
	g_NetCtrl:Send("openui", "C2GSWeekSchedule", t)
end

function C2GSScheduleReward(rewardidx)
	local t = {
		rewardidx = rewardidx,
	}
	g_NetCtrl:Send("openui", "C2GSScheduleReward", t)
end

function C2GSRewardDoublePoint()
	local t = {
	}
	g_NetCtrl:Send("openui", "C2GSRewardDoublePoint", t)
end

function C2GSOpenInterface(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("openui", "C2GSOpenInterface", t)
end

function C2GSCloseInterface(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("openui", "C2GSCloseInterface", t)
end

function C2GSOpenFBComfirm(fuben)
	local t = {
		fuben = fuben,
	}
	g_NetCtrl:Send("openui", "C2GSOpenFBComfirm", t)
end

function C2GSUseAdvanceMap(itemid)
	local t = {
		itemid = itemid,
	}
	g_NetCtrl:Send("openui", "C2GSUseAdvanceMap", t)
end

function C2GSOpenBox(box_sid)
	local t = {
		box_sid = box_sid,
	}
	g_NetCtrl:Send("openui", "C2GSOpenBox", t)
end

function C2GSQuickBuyItem(sid, amount)
	local t = {
		sid = sid,
		amount = amount,
	}
	g_NetCtrl:Send("openui", "C2GSQuickBuyItem", t)
end

function C2GSFindHDNpc()
	local t = {
	}
	g_NetCtrl:Send("openui", "C2GSFindHDNpc", t)
end

function C2GSFindGlobalNpc(npctype)
	local t = {
		npctype = npctype,
	}
	g_NetCtrl:Send("openui", "C2GSFindGlobalNpc", t)
end

function C2GSExchangeCash(moneytype, goldcoin)
	local t = {
		moneytype = moneytype,
		goldcoin = goldcoin,
	}
	g_NetCtrl:Send("openui", "C2GSExchangeCash", t)
end

function C2GSXunLuo(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("openui", "C2GSXunLuo", t)
end


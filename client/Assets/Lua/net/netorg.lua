module(..., package.seeall)

--GS2C--

function GS2COrgList(pbdata)
	local infos = pbdata.infos
	local left_time = pbdata.left_time
	local version = pbdata.version
	local update = pbdata.update --1 更新
	--todo
	g_OrgCtrl:UpdateOrgList(infos, version, update == 1)
	g_OrgCtrl:UpdateOneClickApplyCoolDown(left_time)
end

function GS2COrgResultList(pbdata)
	local infos = pbdata.infos
	--todo
	g_OrgCtrl:UpdateSearchResultList(infos)
end

function GS2CReadyOrgList(pbdata)
	local infos = pbdata.infos
	--todo
	g_OrgCtrl:UpdateRespondOrgList(infos)
end

function GS2CReadyOrgInfo(pbdata)
	local orgid = pbdata.orgid
	local aim = pbdata.aim
	local left_time = pbdata.left_time --响应剩余时间
	local spread_cd = pbdata.spread_cd --世界宣传cd
	--todo
	g_OrgCtrl:UpdateRespondOrgInfo(pbdata)
end

function GS2COrgMainInfo(pbdata)
	local mask = pbdata.mask
	local orgid = pbdata.orgid
	local name = pbdata.name
	local aim = pbdata.aim
	local level = pbdata.level
	local leaderid = pbdata.leaderid
	local leadername = pbdata.leadername
	local membercnt = pbdata.membercnt
	local maxmembercnt = pbdata.maxmembercnt
	local onlinemem = pbdata.onlinemem
	local xuetucnt = pbdata.xuetucnt
	local maxxuetucnt = pbdata.maxxuetucnt
	local onlinexuetu = pbdata.onlinexuetu
	local cash = pbdata.cash --帮派资金
	local boom = pbdata.boom --繁荣度
	local historys = pbdata.historys
	local info = pbdata.info
	local applyname = pbdata.applyname --自荐人名字
	local applyschool = pbdata.applyschool --自荐人门派
	local applylefttime = pbdata.applylefttime --自荐剩余时间
	local applypid = pbdata.applypid --自荐
	local canapplyleader = pbdata.canapplyleader --是否可以自荐
	local leaderschool = pbdata.leaderschool
	local showid = pbdata.showid
	local left_mail_cnt = pbdata.left_mail_cnt --剩余邮件次数
	local left_mail_cd = pbdata.left_mail_cd --发送帮派邮件cd
	local left_aim_cd = pbdata.left_aim_cd --设置宗旨cd
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(pbdata, "org")
	g_OrgCtrl:UpdateOrgMainInfo(dDecode)
end

function GS2COrgMemberInfo(pbdata)
	local infos = pbdata.infos
	local update = pbdata.update --0 表示全部 1 update
	--todo
	g_OrgCtrl:UpdateMemberList(infos, update == 1)
end

function GS2COrgApplyJoinInfo(pbdata)
	local infos = pbdata.infos
	local auto_join = pbdata.auto_join --1 为选中
	--todo
	g_OrgCtrl:UpdateApplyList(infos)
	g_OrgCtrl:GS2CSetAutoJoin(auto_join == 1)
end

function GS2COrgAim(pbdata)
	local orgid = pbdata.orgid
	local aim = pbdata.aim
	--todo
	g_OrgCtrl:UpdateOrgAim(pbdata)
end

function GS2CCreateOrg(pbdata)
	--todo
	g_OrgCtrl:CreateRespondOrgSuccess()
end

function GS2CApplyJoinOrg(pbdata)
	local flag = pbdata.flag
	local orgid = pbdata.orgid
	--todo
	g_OrgCtrl:UpdateAppliedOrg(pbdata)
end

function GS2CRespondOrg(pbdata)
	local flag = pbdata.flag
	local orgid = pbdata.orgid
	local respondcnt = pbdata.respondcnt
	--todo
	g_OrgCtrl:UpdateRespondedOrg(pbdata)
end

function GS2CUpdateAimResult(pbdata)
	--todo
	g_OrgCtrl.m_Org.aim = g_OrgCtrl.m_CreateOrgTempAim
	g_OrgCtrl:ClearCreateOrgTempInfo()
    netorg.C2GSOrgMainInfo(g_OrgCtrl.GET_ORG_MAIN_INFO_SIMPLE)
    CEditOrgAimView:OnClose()
end

function GS2CDelMember(pbdata)
	local pid = pbdata.pid
	--todo
	g_OrgCtrl:DelMember(pid)
end

function GS2CAddMember(pbdata)
	local info = pbdata.info
	--todo
end

function GS2CInvited2Org(pbdata)
	local pid = pbdata.pid --邀请者id
	local pname = pbdata.pname --邀请者名字
	local org_name = pbdata.org_name --帮派名字
	local org_level = pbdata.org_level --帮派lv
	--todo
	g_OrgCtrl:UpdateInviteInfo(pbdata)
end

function GS2CJoinOrgResult(pbdata)
	local orgid = pbdata.orgid
	local flag = pbdata.flag
	--todo
	g_OrgCtrl:UpdateOrgJoinStatus(pb)
end

function GS2CDelApplyOrg(pbdata)
	local pids = pbdata.pids
	--todo
	g_OrgCtrl:DelApply(pids)
end

function GS2CDelResponseList(pbdata)
	local orgids = pbdata.orgids
	--todo
	g_OrgCtrl:DelRespondOrgList(orgids)
end

function GS2CSetPositionResult(pbdata)
	local pid = pbdata.pid
	local position = pbdata.position
	--todo
	g_OrgCtrl:SetMemberPosition(pid, position)
end

function GS2CApplyJoinOrgResult(pbdata)
	local orgids = pbdata.orgids
	local left_time = pbdata.left_time
	--todo
	g_OrgCtrl:UpdateOneClickAppliedOrgs(pbdata)
end

function GS2CDelOrgList(pbdata)
	local orgids = pbdata.orgids
	--todo
	g_OrgCtrl:DelOrgList(orgids)
end

function GS2CApplyLeaderResult(pbdata)
	local applyname = pbdata.applyname --自荐人名字
	local applyschool = pbdata.applyschool --自荐人门派
	local applylefttime = pbdata.applylefttime --自荐剩余时间
	local applypid = pbdata.applypid --自荐
	local canapplyleader = pbdata.canapplyleader --是否可以自荐
	--todo
	g_OrgCtrl:UpdateSelfApplyResult(pbdata)
end

function GS2CSpreadOrgResult(pbdata)
	local orgid = pbdata.orgid
	local spread_cd = pbdata.spread_cd --世界宣传cd
	--todo
	g_OrgCtrl:UpdateRespondOrgCD(pbdata)
end

function GS2CRefreshRespond(pbdata)
	local infos = pbdata.infos
	--todo
	g_OrgCtrl:UpdateOrgRespondNum(infos)
end

function GS2COrgFlag(pbdata)
	local info = pbdata.info
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(info, "OrgFlag")
	-- 更新数据
	for k, v in pairs(dDecode) do
		g_OrgCtrl.m_LoginOrgRedPontInfo[k] = v
	end
	g_OrgCtrl:UpdateOrgRedPoint()
end

function GS2CGetOnlineMember(pbdata)
	local infos = pbdata.infos
	--todo
	g_OrgCtrl:SetOnlineMemeberList(infos)
end

function GS2CGetBuildInfo(pbdata)
	local infos = pbdata.infos
	--todo
	g_OrgCtrl:UpdateBuildingInfos(infos)
end

function GS2CGetShopInfo(pbdata)
	local items = pbdata.items --物品
	--todo
	g_OrgCtrl:ShowBuildingTreasureShop(items)
end

function GS2COrgRefreshShopUnit(pbdata)
	local item_id = pbdata.item_id --物品id
	local buy_cnt = pbdata.buy_cnt --购买次数（经验宝箱为剩余次数）
	--todo
	g_OrgCtrl:GS2COrgRefreshShopUnit(item_id, buy_cnt)
end

function GS2CBuyItemResult(pbdata)
	--todo
	g_OrgCtrl:GS2CBuyItemResult()
end

function GS2CGetBoonInfo(pbdata)
	local sign_status = pbdata.sign_status --签到状态 0 表示未签到　1　表示已签到
	local bonus_status = pbdata.bonus_status --分红状态 0 表示不能领取 1 可以领取 2 已领
	local bonus_reward = pbdata.bonus_reward --{元宝，绑定元宝，金币，银币，帮贡}
	local pos_status = pbdata.pos_status --职位奖励状态 0没有 1可以领取　2已领
	local position = pbdata.position --管理职位
	local pos_reward = pbdata.pos_reward --管理奖金
	--todo
	g_OrgCtrl:GS2CGetBoonInfo(pbdata)
end

function GS2CGetAchieveInfo(pbdata)
	local achieves = pbdata.achieves --未给信息都是未达成
	--todo
	g_OrgCtrl:GS2CGetAchieveInfo(achieves)
end

function GS2COrgInfoChange(pbdata)
	local info = pbdata.info
	--todo
	g_OrgCtrl:UpdateOrgMainInfo(info)
end

function GS2CUpdateAchieveInfo(pbdata)
	local achieve = pbdata.achieve
	--todo
	g_OrgCtrl:GS2CUpdateAchieveInfo(achieve)
end

function GS2CAddHistoryLog(pbdata)
	local info = pbdata.info
	--todo
	g_OrgCtrl:GS2CAddHistoryLog(info)
end

function GS2CNextPageLog(pbdata)
	local infos = pbdata.infos
	--todo
	g_OrgCtrl:GS2CNextPageLog(infos)
end

function GS2CChatBan(pbdata)
	local binid = pbdata.binid
	local flag = pbdata.flag
	--todo
	
end

function GS2COrgFaneActiveInfo(pbdata)
	local info_list = pbdata.info_list --活动简明信息
	--todo
	g_OrgCtrl:GS2COrgFaneActiveInfo(info_list)
end

function GS2CSetAutoJoin(pbdata)
	local auto_join = pbdata.auto_join --0 , 1
	--todo
	g_OrgCtrl:GS2CSetAutoJoin(auto_join == 1)
end

function GS2COrgPrestigeInfo(pbdata)
	local my_rank = pbdata.my_rank
	local my_prestige = pbdata.my_prestige
	--todo
	g_OrgCtrl:GS2COrgPrestigeInfo(my_rank, my_prestige)
end


--C2GS--

function C2GSOrgList(version)
	local t = {
		version = version,
	}
	g_NetCtrl:Send("org", "C2GSOrgList", t)
end

function C2GSSearchOrg(text)
	local t = {
		text = text,
	}
	g_NetCtrl:Send("org", "C2GSSearchOrg", t)
end

function C2GSCreateOrg(name, aim)
	local t = {
		name = name,
		aim = aim,
	}
	g_NetCtrl:Send("org", "C2GSCreateOrg", t)
end

function C2GSApplyJoinOrg(orgid, flag)
	local t = {
		orgid = orgid,
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSApplyJoinOrg", t)
end

function C2GSMultiApplyJoinOrg()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSMultiApplyJoinOrg", t)
end

function C2GSReadyOrgList()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSReadyOrgList", t)
end

function C2GSReadyOrgInfo(orgid)
	local t = {
		orgid = orgid,
	}
	g_NetCtrl:Send("org", "C2GSReadyOrgInfo", t)
end

function C2GSRespondOrg(orgid, flag)
	local t = {
		orgid = orgid,
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSRespondOrg", t)
end

function C2GSMultiRespondOrg()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSMultiRespondOrg", t)
end

function C2GSOrgMainInfo(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSOrgMainInfo", t)
end

function C2GSOrgMemberList(version)
	local t = {
		version = version,
	}
	g_NetCtrl:Send("org", "C2GSOrgMemberList", t)
end

function C2GSOrgApplyJoinList(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSOrgApplyJoinList", t)
end

function C2GSOrgDealApply(pid, deal)
	local t = {
		pid = pid,
		deal = deal,
	}
	g_NetCtrl:Send("org", "C2GSOrgDealApply", t)
end

function C2GSAgreeAllApply()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSAgreeAllApply", t)
end

function C2GSOrgSetPosition(pid, position)
	local t = {
		pid = pid,
		position = position,
	}
	g_NetCtrl:Send("org", "C2GSOrgSetPosition", t)
end

function C2GSLeaveOrg()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSLeaveOrg", t)
end

function C2GSRequestOrgAim(orgid)
	local t = {
		orgid = orgid,
	}
	g_NetCtrl:Send("org", "C2GSRequestOrgAim", t)
end

function C2GSSpreadOrg()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSSpreadOrg", t)
end

function C2GSUpdateAim(aim)
	local t = {
		aim = aim,
	}
	g_NetCtrl:Send("org", "C2GSUpdateAim", t)
end

function C2GSKickMember(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("org", "C2GSKickMember", t)
end

function C2GSApplyOrgLeader()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSApplyOrgLeader", t)
end

function C2GSVoteOrgLeader(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSVoteOrgLeader", t)
end

function C2GSInvited2Org(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("org", "C2GSInvited2Org", t)
end

function C2GSDealInvited2Org(pid, flag)
	local t = {
		pid = pid,
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSDealInvited2Org", t)
end

function C2GSClearApplyAndRespond()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSClearApplyAndRespond", t)
end

function C2GSGetOnlineMember(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSGetOnlineMember", t)
end

function C2GSGetBuildInfo()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSGetBuildInfo", t)
end

function C2GSUpGradeBuild(bid)
	local t = {
		bid = bid,
	}
	g_NetCtrl:Send("org", "C2GSUpGradeBuild", t)
end

function C2GSQuickBuild(bid, quickid)
	local t = {
		bid = bid,
		quickid = quickid,
	}
	g_NetCtrl:Send("org", "C2GSQuickBuild", t)
end

function C2GSGetShopInfo()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSGetShopInfo", t)
end

function C2GSBuyItem(itemid, cnt)
	local t = {
		itemid = itemid,
		cnt = cnt,
	}
	g_NetCtrl:Send("org", "C2GSBuyItem", t)
end

function C2GSGetBoonInfo()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSGetBoonInfo", t)
end

function C2GSOrgSign(msg)
	local t = {
		msg = msg,
	}
	g_NetCtrl:Send("org", "C2GSOrgSign", t)
end

function C2GSReceiveBonus()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSReceiveBonus", t)
end

function C2GSReceivePosBonus()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSReceivePosBonus", t)
end

function C2GSGetAchieveInfo()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSGetAchieveInfo", t)
end

function C2GSReceiveAchieve(achid)
	local t = {
		achid = achid,
	}
	g_NetCtrl:Send("org", "C2GSReceiveAchieve", t)
end

function C2GSEnterOrgScene()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSEnterOrgScene", t)
end

function C2GSNextPageLog(lastid)
	local t = {
		lastid = lastid,
	}
	g_NetCtrl:Send("org", "C2GSNextPageLog", t)
end

function C2GSChatBan(banid, flag)
	local t = {
		banid = banid,
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSChatBan", t)
end

function C2GSClickOrgBuild(build_id)
	local t = {
		build_id = build_id,
	}
	g_NetCtrl:Send("org", "C2GSClickOrgBuild", t)
end

function C2GSSetAutoJoin(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSSetAutoJoin", t)
end

function C2GSClearApplyList()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSClearApplyList", t)
end

function C2GSOrgPrestigeInfo()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSOrgPrestigeInfo", t)
end

function C2GSSendOrgMail(context)
	local t = {
		context = context,
	}
	g_NetCtrl:Send("org", "C2GSSendOrgMail", t)
end

function C2GSRenameNormalOrg(name)
	local t = {
		name = name,
	}
	g_NetCtrl:Send("org", "C2GSRenameNormalOrg", t)
end


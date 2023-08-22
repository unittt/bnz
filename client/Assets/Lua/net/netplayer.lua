module(..., package.seeall)

--GS2C--

function GS2CPropChange(pbdata)
	local role = pbdata.role
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(role, "role")
	if dDecode.score then
		g_NotifyCtrl:ShowScore(dDecode.score, g_AttrCtrl.score)
	end
	g_AttrCtrl:UpdateAttr(dDecode)
	g_UpgradePacksCtrl:UpdatePacks()
	g_MainMenuCtrl:ShowScore(role.score)
	-- C2GSGetSecondProp()
end

function GS2CServerGradeInfo(pbdata)
	local server_grade = pbdata.server_grade
	local days = pbdata.days
	local server_type = pbdata.server_type
	--todo
	local dAttr = table.copy(pbdata)
	g_AttrCtrl:UpdateAttr(dAttr)
end

function GS2CUpdateStrengthenInfo(pbdata)
	local mask = pbdata.mask
	local strengthen_info = pbdata.strengthen_info
	local master_score = pbdata.master_score --强化大师评分*1000倍取整
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(pbdata, "equipStength")
	g_ItemCtrl:UpdateStrengthenInfo(dDecode.strengthen_info,master_score)
end

function GS2CGetPlayerInfo(pbdata)
	local grade = pbdata.grade
	local name = pbdata.name
	local model_info = pbdata.model_info
	local school = pbdata.school
	local team_id = pbdata.team_id
	local team_size = pbdata.team_size --队伍成员数量
	local pid = pbdata.pid
	local org_id = pbdata.org_id
	local org_name = pbdata.org_name
	local org_level = pbdata.org_level
	local org_pos = pbdata.org_pos
	local position = pbdata.position
	local position_hide = pbdata.position_hide --0-隐藏地理位置，1-显示位置
	local icon = pbdata.icon
	local org_chat = pbdata.org_chat --0-没有禁言，1-禁言
	--todo
	CPlayerInfoView:ShowView(function(oView)
		oView:SetPlayerInfo(pbdata)
	end)
	g_FriendCtrl:CheckPlayerInfo(pbdata)
end

function GS2CLoginPointPlanInfoList(pbdata)
	local selected_plan = pbdata.selected_plan
	local wash_info_list = pbdata.wash_info_list
	--todo
	g_AttrCtrl:UpdateAddpoint(wash_info_list, selected_plan)
	-- C2GSGetSecondProp()
	g_PromoteCtrl:UpdatePromoteData(3)
end

function GS2CPointPlanInfo(pbdata)
	local wash_info = pbdata.wash_info
	--todo
	g_AttrCtrl:RefreshAttrPoint(wash_info)
	g_PromoteCtrl:UpdatePromoteData(3)
end

function GS2CWashPoint(pbdata)
	local remain_wash_point = pbdata.remain_wash_point --剩余可洗点
	local prop_name = pbdata.prop_name
	local remain_point = pbdata.remain_point --剩下潜力点
	--todo
	g_AttrCtrl:RefreshWashPoint(pbdata)
	g_PromoteCtrl:UpdatePromoteData(3)
end

function GS2CGetSecondProp(pbdata)
	local prop_info = pbdata.prop_info
	--todo
	g_AttrCtrl:GS2CGetSecondProp(prop_info)	
end

function GS2CPlayerItemInfo(pbdata)
	local pid = pbdata.pid
	local itemdata = pbdata.itemdata
	--todo
	printc("GS2CPlayerItemInfo")
	g_LinkInfoCtrl:RefreshItemInfo(pid, itemdata)
end

function GS2CPlayerSummonInfo(pbdata)
	local pid = pbdata.pid
	local summondata = pbdata.summondata
	--todo
	g_LinkInfoCtrl:RefreshSummonInfo(pid, summondata)
end

function GS2CPlayerPartnerInfo(pbdata)
	local pid = pbdata.pid --目标玩家ID
	local partnerdata = pbdata.partnerdata --目标伙伴信息
	--todo
	g_LinkInfoCtrl:GS2CPlayerPartnerInfo(pbdata)
end

function GS2CNameCardInfo(pbdata)
	local pid = pbdata.pid
	local name = pbdata.name
	local title_info = pbdata.title_info --称谓
	local grade = pbdata.grade
	local upvote_amount = pbdata.upvote_amount --点赞人数
	local isupvote = pbdata.isupvote --1-已点赞，0-未点赞
	local orgname = pbdata.orgname --玩家帮派名
	local partner = pbdata.partner --伴侣
	local achieve = pbdata.achieve --成就
	local score = pbdata.score --评分
	local position = pbdata.position --位置
	local position_hide = pbdata.position_hide --位置隐藏 0-隐藏 1-不隐藏
	local school = pbdata.school --门派
	local rank = pbdata.rank --点赞榜排名
	local show_id = pbdata.show_id --靓号ID
	local model_info = pbdata.model_info --模型
	--todo
	g_LinkInfoCtrl:RefreshAttrCardInfo(pbdata)
end

function GS2CPlayerUpvoteInfo(pbdata)
	local info = pbdata.info
	--todo
	CCardLikeListView:ShowView(function(oView) 
		oView:SetData(info)
    end)
end

function GS2CUpvotePlayer(pbdata)
	local succuss = pbdata.succuss --0-失败，1-成功
	--todo
	if succuss == 1 then 
		g_LinkInfoCtrl:UpvotePlayerAdd()
	end 
end

function GS2CAllUpvoteReward(pbdata)
	local info = pbdata.info
	--todo
	g_AttrCtrl:GS2CUpvoteReward(info,true)
end

function GS2CUpvoteReward(pbdata)
	local info = pbdata.info
	--todo
	g_AttrCtrl:GS2CUpvoteReward(info,false)
end

function GS2CLoginVisibility(pbdata)
	local npcs = pbdata.npcs --额外的npc可见性
	local scene_effects = pbdata.scene_effects --额外的场景特效可见性
	local npc_appears = pbdata.npc_appears --常驻npc形象更变
	--todo
	g_MapCtrl:GS2CLoginVisibility(pbdata)
end

function GS2CChangeVisibility(pbdata)
	local npcs = pbdata.npcs --新增的npc可见性
	local scene_effects = pbdata.scene_effects --新增的场景特效可见性
	local npc_appears = pbdata.npc_appears --新增的常驻npc形象更变
	--todo
	g_MapCtrl:GS2CChangeVisibility(pbdata)
end

function GS2CSetGhostEye(pbdata)
	local open = pbdata.open --是否开启
	--todo
	g_MapCtrl:GS2CSetGhostEye(pbdata)
end

function GS2CLoginGhostEye(pbdata)
	local open = pbdata.open --是否开启
	--todo
	g_MapCtrl:GS2CLoginGhostEye(pbdata)
end

function GS2CShowNpcCloseup(pbdata)
	local npctype = pbdata.npctype --常驻npctype
	local parnter = pbdata.parnter --伙伴sid
	local summon = pbdata.summon --宠物ID
	--todo
	g_MapCtrl:GS2CShowNpcCloseup(pbdata)
end

function GS2CPromote(pbdata)
	local radio = pbdata.radio
	local score = pbdata.score
	local sumscore = pbdata.sumscore
	local result = pbdata.result
	local open = pbdata.open
	local reference_score = pbdata.reference_score
	--todo
	g_PromoteCtrl:GS2CPromote(pbdata)
end

function GS2CSysConfig(pbdata)
	local on_off = pbdata.on_off --二进制开关，前端使用位操作
	local values = pbdata.values --值设置
	--todo
	g_SystemSettingsCtrl:GS2CSysConfig(pbdata)
end

function GS2CLoginGradeGiftInfo(pbdata)
	local rewarded = pbdata.rewarded --已领取的等级数
	--todo
	g_UpgradePacksCtrl:GS2CLoginGradeGiftInfo(rewarded)
end

function GS2CRewardGradeGift(pbdata)
	local grade = pbdata.grade --领取礼包等级
	--todo
	g_UpgradePacksCtrl:GS2CRewareGradeGift(grade)
end

function GS2CLoginPreopenGiftInfo(pbdata)
	local rewarded = pbdata.rewarded --已领取的系统id
	--todo
	g_GuideHelpCtrl:GS2CLoginPreopenGiftInfo(pbdata)
end

function GS2CRewardPreopenGift(pbdata)
	local sys_id = pbdata.sys_id --领取功能预告礼包
	--todo
	g_GuideHelpCtrl:GS2CRewardPreopenGift(pbdata)
end

function GS2CGetScore(pbdata)
	local op = pbdata.op --1.玩家
	local score = pbdata.score
	--todo
	g_AttrCtrl:GS2CGetScore(op, score)
end

function GS2COpenRanSe(pbdata)
	local type = pbdata.type --1.头发 2.外观
	local color = pbdata.color --开启的颜色
	--todo

	if type == 2 then 
		g_RanseCtrl:GS2COpenRanSe(pbdata)
	elseif type == 3 then 
		g_SummonRanseCtrl:GS2COpenRanSe(pbdata)
	elseif type == 4 then 
		g_WaiGuanCtrl:OpenWaiGuanView()
	end 

end

function GS2CSyncTesterKeys(pbdata)
	local keys = pbdata.keys
	--todo
	g_CTesterCtrl:ResetTester(keys)
end

function GS2CGamePushConfig(pbdata)
	local values = pbdata.values --值设置
	--todo
	g_SystemSettingsCtrl:GS2CGamePushConfig(values)
end

function GS2CRefreshShiZhuang(pbdata)
	local szobj = pbdata.szobj
	--todo
	g_WaiGuanCtrl:GS2CRefreshShiZhuang(pbdata)
end

function GS2CAllShiZhuang(pbdata)
	local szlist = pbdata.szlist
	--todo
	g_WaiGuanCtrl:GS2CAllShiZhuang(szlist)
end

function GS2CAssistExp(pbdata)
	local assist_exp = pbdata.assist_exp
	local max_assist_exp = pbdata.max_assist_exp
	--todo
	g_AttrCtrl:GS2CAssistExp(assist_exp, max_assist_exp)
end

function GS2CLoginShiZhuang(pbdata)
	local szlist = pbdata.szlist
	--todo
end


--C2GS--

function C2GSGetPlayerInfo(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("player", "C2GSGetPlayerInfo", t)
end

function C2GSSelectPointPlan(plan_id)
	local t = {
		plan_id = plan_id,
	}
	g_NetCtrl:Send("player", "C2GSSelectPointPlan", t)
end

function C2GSAddPoint(point_info)
	local t = {
		point_info = point_info,
	}
	g_NetCtrl:Send("player", "C2GSAddPoint", t)
end

function C2GSWashPoint(prop_name, flag)
	local t = {
		prop_name = prop_name,
		flag = flag,
	}
	g_NetCtrl:Send("player", "C2GSWashPoint", t)
end

function C2GSWashAllPoint()
	local t = {
	}
	g_NetCtrl:Send("player", "C2GSWashAllPoint", t)
end

function C2GSGetSecondProp()
	local t = {
	}
	g_NetCtrl:Send("player", "C2GSGetSecondProp", t)
end

function C2GSPlayerItemInfo(pid, itemid)
	local t = {
		pid = pid,
		itemid = itemid,
	}
	g_NetCtrl:Send("player", "C2GSPlayerItemInfo", t)
end

function C2GSPlayerSummonInfo(pid, summonid)
	local t = {
		pid = pid,
		summonid = summonid,
	}
	g_NetCtrl:Send("player", "C2GSPlayerSummonInfo", t)
end

function C2GSPlayerPartnerInfo(pid, partner)
	local t = {
		pid = pid,
		partner = partner,
	}
	g_NetCtrl:Send("player", "C2GSPlayerPartnerInfo", t)
end

function C2GSNameCardInfo(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("player", "C2GSNameCardInfo", t)
end

function C2GSUpvotePlayer(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("player", "C2GSUpvotePlayer", t)
end

function C2GSPlayerUpvoteInfo(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("player", "C2GSPlayerUpvoteInfo", t)
end

function C2GSUpvoteReward(idx)
	local t = {
		idx = idx,
	}
	g_NetCtrl:Send("player", "C2GSUpvoteReward", t)
end

function C2GSRename(rename)
	local t = {
		rename = rename,
	}
	g_NetCtrl:Send("player", "C2GSRename", t)
end

function C2GSHidePosition(hide)
	local t = {
		hide = hide,
	}
	g_NetCtrl:Send("player", "C2GSHidePosition", t)
end

function C2GSObserverWar(camp_id, npc_id, target)
	local t = {
		camp_id = camp_id,
		npc_id = npc_id,
		target = target,
	}
	g_NetCtrl:Send("player", "C2GSObserverWar", t)
end

function C2GSLeaveObserverWar(war_id)
	local t = {
		war_id = war_id,
	}
	g_NetCtrl:Send("player", "C2GSLeaveObserverWar", t)
end

function C2GSSysConfig(on_off, values)
	local t = {
		on_off = on_off,
		values = values,
	}
	g_NetCtrl:Send("player", "C2GSSysConfig", t)
end

function C2GSRewardGradeGift(grade)
	local t = {
		grade = grade,
	}
	g_NetCtrl:Send("player", "C2GSRewardGradeGift", t)
end

function C2GSRewardPreopenGift(sys_id)
	local t = {
		sys_id = sys_id,
	}
	g_NetCtrl:Send("player", "C2GSRewardPreopenGift", t)
end

function C2GSGetScore(op)
	local t = {
		op = op,
	}
	g_NetCtrl:Send("player", "C2GSGetScore", t)
end

function C2GSGetPromote()
	local t = {
	}
	g_NetCtrl:Send("player", "C2GSGetPromote", t)
end

function C2GSPlayerRanSe(clothcolor, haircolor, pantcolor, flag)
	local t = {
		clothcolor = clothcolor,
		haircolor = haircolor,
		pantcolor = pantcolor,
		flag = flag,
	}
	g_NetCtrl:Send("player", "C2GSPlayerRanSe", t)
end

function C2GSOpenShiZhuang(type, sz)
	local t = {
		type = type,
		sz = sz,
	}
	g_NetCtrl:Send("player", "C2GSOpenShiZhuang", t)
end

function C2GSSetSZ(sz)
	local t = {
		sz = sz,
	}
	g_NetCtrl:Send("player", "C2GSSetSZ", t)
end

function C2GSSZRanse(sz, clothcolor, haircolor, pantcolor, flag)
	local t = {
		sz = sz,
		clothcolor = clothcolor,
		haircolor = haircolor,
		pantcolor = pantcolor,
		flag = flag,
	}
	g_NetCtrl:Send("player", "C2GSSZRanse", t)
end

function C2GSSetSZColor(sz, color)
	local t = {
		sz = sz,
		color = color,
	}
	g_NetCtrl:Send("player", "C2GSSetSZColor", t)
end

function C2GSGamePushConfig(values)
	local t = {
		values = values,
	}
	g_NetCtrl:Send("player", "C2GSGamePushConfig", t)
end

function C2GSGetAllSZInfo()
	local t = {
	}
	g_NetCtrl:Send("player", "C2GSGetAllSZInfo", t)
end

function C2GSSyncPosition(position)
	local t = {
		position = position,
	}
	g_NetCtrl:Send("player", "C2GSSyncPosition", t)
end


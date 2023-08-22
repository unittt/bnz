module(..., package.seeall)

--GS2C--

function GS2CGetRankInfo(pbdata)
	local idx = pbdata.idx --排行榜索引
	local page = pbdata.page --排行榜页数
	local first_stub = pbdata.first_stub --第一次生成的排行榜, 1表示第一次
	local my_rank = pbdata.my_rank --玩家自己的排名
	local upvote_rank = pbdata.upvote_rank --点赞榜单
	local grade_rank = pbdata.grade_rank --等级排行榜
	local player_score_rank = pbdata.player_score_rank
	local role_score_rank = pbdata.role_score_rank
	local summon_score_rank = pbdata.summon_score_rank
	local friend_degree_rank = pbdata.friend_degree_rank
	local biwu_rank = pbdata.biwu_rank
	local my_rank_value = pbdata.my_rank_value --我的排行榜数据
	local prestige_rank = pbdata.prestige_rank --帮派威望榜
	local kaifu_grade_rank = pbdata.kaifu_grade_rank --开服等级
	local kaifu_score_rank = pbdata.kaifu_score_rank --开服玩家评分
	local kaifu_summon_rank = pbdata.kaifu_summon_rank --开服宠物
	local kaifu_org_rank = pbdata.kaifu_org_rank --开服宠物
	local score_school_rank = pbdata.score_school_rank --门派排行
	local jubaopen_score_rank = pbdata.jubaopen_score_rank --聚宝盆积分排行
	local resume_goldcoin = pbdata.resume_goldcoin --每日消费榜
	local treasure_find = pbdata.treasure_find --宝藏发掘榜
	local fuyuan_box = pbdata.fuyuan_box --福缘宝箱开启数
	local wash_summon = pbdata.wash_summon --每日冲榜-洗宠
	local make_equip = pbdata.make_equip --每日冲榜-打造
	local send_flower = pbdata.send_flower --每日冲榜-送花
	local kill_ghost = pbdata.kill_ghost --每日冲榜-抓鬼
	local kill_monster = pbdata.kill_monster --每日冲榜-杀怪
	local strength_equip = pbdata.strength_equip --每日冲榜-强化
	local threebiwu_rank = pbdata.threebiwu_rank
	local luanshimoying_score_rank = pbdata.luanshimoying_score_rank --乱世魔影-积分排行
	local imperialexam_firststage = pbdata.imperialexam_firststage --科举乡试
	local imperialexam_secondstage = pbdata.imperialexam_secondstage --科举殿试
	local worldcup_rank = pbdata.worldcup_rank --世界杯排行
	--todo
	if idx == 211 then
		g_AssembleTreasureCtrl:GS2CGetRankInfo(pbdata)
		return 
	end	
	if idx ~= 102 then 
		g_RankCtrl:GS2CGetRankInfo(pbdata)
	else
		g_AttrCtrl:GS2CGetRankInfo(pbdata)
	end
		
end

function GS2CGetRankTop3(pbdata)
	local idx = pbdata.idx --排行榜索引
	local my_rank = pbdata.my_rank
	local role_info = pbdata.role_info --玩家基本信息
	local summon_info = pbdata.summon_info --宠物基本信息
	--todo
	local info = next(role_info) ~= nil and role_info or summon_info
	g_RankCtrl:GS2CGetRankTop3(idx,info)
end

function GS2CGetUpvoteAmount(pbdata)
	local pid = pbdata.pid
	local upvote = pbdata.upvote
	--todo
	g_RankCtrl:GS2CGetUpvoteAmount(pid,upvote)
end

function GS2CSumBasciInfo(pbdata)
	local summondata = pbdata.summondata
	--todo
	g_RankCtrl:GS2CSumBasciInfo(summondata)
end


--C2GS--

function C2GSGetRankInfo(idx, page)
	local t = {
		idx = idx,
		page = page,
	}
	g_NetCtrl:Send("rank", "C2GSGetRankInfo", t)
end

function C2GSGetRankTop3(idx)
	local t = {
		idx = idx,
	}
	g_NetCtrl:Send("rank", "C2GSGetRankTop3", t)
end

function C2GSGetUpvoteAmount(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("rank", "C2GSGetUpvoteAmount", t)
end

function C2GSGetRankSumInfo(idx, rank)
	local t = {
		idx = idx,
		rank = rank,
	}
	g_NetCtrl:Send("rank", "C2GSGetRankSumInfo", t)
end


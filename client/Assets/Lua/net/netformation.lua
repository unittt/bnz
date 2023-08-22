module(..., package.seeall)

--GS2C--

function GS2CAllFormationInfo(pbdata)
	local fmt_curr = pbdata.fmt_curr --当前选中的阵法
	local player_list = pbdata.player_list --阵型站位信息
	local partner_list = pbdata.partner_list --伙伴阵型站位
	local fmt_list = pbdata.fmt_list
	local fmt_learn_limit = pbdata.fmt_learn_limit --还可以学习的个数限制
	--todo
	g_FormationCtrl:SetAllFormationInfo(fmt_curr, player_list, partner_list, fmt_list)
	g_FormationCtrl.m_LeftCouldLearnNum = pbdata.fmt_learn_limit
	-- CFormationMainView:ShowView(function(oView)
	-- 	oView:InitFormationInfo(fmt_curr)
	-- end)
    --table.print(fmt_curr,"当前选中的阵法")
    --table.print(fmt_list,"所有阵法：")
    g_PromoteCtrl:UpdatePromoteData(5)
    g_PromoteCtrl:UpdatePromoteData(13)
end

function GS2CSingleFormationInfo(pbdata)
	local fmt_info = pbdata.fmt_info
	local fmt_learn_limit = pbdata.fmt_learn_limit --还可以学习的个数限制
	--todo
	g_FormationCtrl.m_LeftCouldLearnNum = pbdata.fmt_learn_limit
	g_FormationCtrl:UpdateFormationInfo(fmt_info)
	g_PromoteCtrl:UpdatePromoteData(5)
	g_PromoteCtrl:UpdatePromoteData(13)
end

function GS2CFmtPosInfo(pbdata)
	local fmt_curr = pbdata.fmt_curr --当前选中的阵法
	local player_list = pbdata.player_list --阵型站位信息
	local partner_list = pbdata.partner_list --伙伴站位信息
	--todo
	g_FormationCtrl:UpdatePosList(fmt_curr, player_list, partner_list)
end


--C2GS--

function C2GSAllFormationInfo()
	local t = {
	}
	g_NetCtrl:Send("formation", "C2GSAllFormationInfo", t)
end

function C2GSSingleFormationInfo(fmt_id)
	local t = {
		fmt_id = fmt_id,
	}
	g_NetCtrl:Send("formation", "C2GSSingleFormationInfo", t)
end

function C2GSSetPlayerPosInfo(fmt_id, player_list, partner_list)
	local t = {
		fmt_id = fmt_id,
		player_list = player_list,
		partner_list = partner_list,
	}
	g_NetCtrl:Send("formation", "C2GSSetPlayerPosInfo", t)
end

function C2GSUpgradeFormation(fmt_id, book_list)
	local t = {
		fmt_id = fmt_id,
		book_list = book_list,
	}
	g_NetCtrl:Send("formation", "C2GSUpgradeFormation", t)
end


module(..., package.seeall)

--GS2C--

function GS2CLoginState(pbdata)
	local state_info = pbdata.state_info
	--todo
	--table.print(state_info,"-----------登录状态-")
	g_DancingCtrl:LoginDancingState(state_info)
	g_FightOutsideBuffCtrl:GS2CLoginState(state_info)
	g_PromoteCtrl:UpdatePromoteData(12)
end

function GS2CAddState(pbdata)
	local state_info = pbdata.state_info
	--todo
	--table.print(state_info,"---------------增加状态----")
	if state_info.state_id == define.OrgMatch.State.Protect then
		g_AttrCtrl:SetOrgMatchState(state_info.state_id)
		g_MapCtrl:UpdateHeroState(state_info.state_id)
	else
		g_DancingCtrl:AddDancingState(state_info)
		g_FightOutsideBuffCtrl:GS2CAddState(state_info)
	end
	g_PromoteCtrl:UpdatePromoteData(12)
end

function GS2CRemoveState(pbdata)
	local state_id = pbdata.state_id
	--todo
	--printc("删除状态ID",state_id)
	if state_id == define.OrgMatch.State.Protect then
		g_AttrCtrl:SetOrgMatchState(0)
		g_MapCtrl:UpdateHeroState(0)
	else
		g_DancingCtrl:RemoveDancingState(state_id)
		g_FightOutsideBuffCtrl:GS2CRemoveState(state_id)
	end
	g_PromoteCtrl:UpdatePromoteData(12)
end

function GS2CRefreshState(pbdata)
	local state_info = pbdata.state_info
	--todo
	--table.print(state_info,"----------刷新状态----")
	g_FightOutsideBuffCtrl:GS2CRefreshState(state_info)
	g_PromoteCtrl:UpdatePromoteData(12)
end

function GS2CAddBaoShi(pbdata)
	local count = pbdata.count
	local sliver = pbdata.sliver
	--todo
	g_FightOutsideBuffCtrl:GS2CAddBaoShi(count, sliver)
end

function GS2CBaoShiSilver(pbdata)
	--todo
	-- CCurrencyView:ShowView(function(oView)
	-- 	oView:SetCurrencyView(define.Currency.Type.Silver)
	-- end)
	g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
end


--C2GS--

function C2GSClickState(state_id)
	local t = {
		state_id = state_id,
	}
	g_NetCtrl:Send("state", "C2GSClickState", t)
end

function C2GSAddBaoShi()
	local t = {
	}
	g_NetCtrl:Send("state", "C2GSAddBaoShi", t)
end


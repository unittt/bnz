module(..., package.seeall)

--GS2C--

function GS2CSysOpenNotified(pbdata)
	local sys_ids = pbdata.sys_ids
	--todo
	g_OpenSysCtrl:GS2CSysOpenNotified(pbdata)
end

function GS2CNewbieGuideInfo(pbdata)
	local guide_links = pbdata.guide_links
	local exdata = pbdata.exdata --可以存储玩家选择是否玩过回合制等信息
	local no_guide = pbdata.no_guide --0:正常引导, 1:不要引导
	--todo
	g_GuideHelpCtrl:GS2CNewbieGuideInfo(pbdata)
end

function GS2CNewibeSummonGot(pbdata)
	local succ = pbdata.succ --0/1 是否成功
	local had_selection = pbdata.had_selection --曾经选择过的选项（不为0表示曾经执行过该流程）
	--todo
end

function GS2CGetNewbieGuildInfo(pbdata)
	local org_cnt = pbdata.org_cnt --帮派数量
	--todo
	g_GuideHelpCtrl:GS2CGetNewbieGuildInfo(pbdata)
end


--C2GS--

function C2GSNewSysOpenNotified(sys_ids)
	local t = {
		sys_ids = sys_ids,
	}
	g_NetCtrl:Send("newbieguide", "C2GSNewSysOpenNotified", t)
end

function C2GSUpdateNewbieGuideInfo(mask, guide_links, exdata)
	local t = {
		mask = mask,
		guide_links = guide_links,
		exdata = exdata,
	}
	g_NetCtrl:Send("newbieguide", "C2GSUpdateNewbieGuideInfo", t)
end

function C2GSSelectNewbieSummon(selection)
	local t = {
		selection = selection,
	}
	g_NetCtrl:Send("newbieguide", "C2GSSelectNewbieSummon", t)
end

function C2GSGetNewbieGuildInfo()
	local t = {
	}
	g_NetCtrl:Send("newbieguide", "C2GSGetNewbieGuildInfo", t)
end


module(..., package.seeall)

--GS2C--

function GS2CTitleInfoList(pbdata)
	local infos = pbdata.infos
	--todo
	g_TitleCtrl:UpdateTwoLists(infos)
end

function GS2CAddTitleInfo(pbdata)
	local infos = pbdata.infos
	--todo
	g_TitleCtrl:AddTitles(infos)
end

function GS2CDelTitleInfo(pbdata)
	local tids = pbdata.tids
	--todo
	g_TitleCtrl:DelTitles(tids)
end

function GS2CUpdateUseTitle(pbdata)
	local tid = pbdata.tid
	--todo
	g_TitleCtrl:UpdateWearingTitle(tid)
	
	g_MapCtrl:UpdateHero()  -- 实时刷新角色的称谓
end

function GS2CUpdateTitleInfo(pbdata)
	local info = pbdata.info
	--todo
	g_TitleCtrl:UpdateTitleInfo(info)
end


--C2GS--

function C2GSUseTitle(tid, flag)
	local t = {
		tid = tid,
		flag = flag,
	}
	g_NetCtrl:Send("title", "C2GSUseTitle", t)
end


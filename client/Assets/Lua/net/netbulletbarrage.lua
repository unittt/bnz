module(..., package.seeall)

--GS2C--

function GS2CWarBulletBarrage(pbdata)
	local war_id = pbdata.war_id --战斗ID
	local bout = pbdata.bout --回合
	local secs = pbdata.secs --距离回合开始的时间戳
	local name = pbdata.name --发弹幕的人
	local msg = pbdata.msg --弹幕信息
	--todo
	g_BarrageCtrl:GS2CWarBulletBarrage(pbdata)
end

function GS2COrgBulletBarrage(pbdata)
	local orgid = pbdata.orgid
	local name = pbdata.name
	local msg = pbdata.msg
	--todo
	g_BarrageCtrl:GS2COrgBulletBarrage(pbdata)
end

function GS2CWarBulletBarrageData(pbdata)
	local war_id = pbdata.war_id
	local type = pbdata.type
	local barrage = pbdata.barrage
	--todo
end

function GS2CStoryBulletBarrageData(pbdata)
	local story_id = pbdata.story_id
	local lst = pbdata.lst
	--todo
	g_BarrageCtrl:GS2CStoryBulletBarrageData(pbdata)
end

function GS2CWarInfoBulletBarrage(pbdata)
	local war_id = pbdata.war_id
	local msg = pbdata.msg
	--todo
	--g_BarrageCtrl:GS2CWarInfoBulletBarrage(pbdata)



	if g_WarCtrl.m_WarID ~= war_id then
		return
	end
	local oCmd = CWarCmd.New("WarInfoBulletBarrage")
	oCmd.wid = g_WarCtrl.m_CurActionWid
	oCmd.content = msg
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		oVaryCmd:SetVary(oCmd.wid, "infoBulletBarrage_cmd", oCmd)
	else
		g_WarCtrl:InsertCmd(oCmd)
	end
end


--C2GS--

function C2GSWarBulletBarrage(cmd)
	local t = {
		cmd = cmd,
	}
	g_NetCtrl:Send("bulletbarrage", "C2GSWarBulletBarrage", t)
end

function C2GSVideoBulletBarrage(video_id, type, bout, secs, msg)
	local t = {
		video_id = video_id,
		type = type,
		bout = bout,
		secs = secs,
		msg = msg,
	}
	g_NetCtrl:Send("bulletbarrage", "C2GSVideoBulletBarrage", t)
end

function C2GSOrgBulletBarrage(cmd)
	local t = {
		cmd = cmd,
	}
	g_NetCtrl:Send("bulletbarrage", "C2GSOrgBulletBarrage", t)
end

function C2GSStoryBulletBarrage(story_id, secs, msg)
	local t = {
		story_id = story_id,
		secs = secs,
		msg = msg,
	}
	g_NetCtrl:Send("bulletbarrage", "C2GSStoryBulletBarrage", t)
end

function C2GSGetStoryBulletBarrage(story_id)
	local t = {
		story_id = story_id,
	}
	g_NetCtrl:Send("bulletbarrage", "C2GSGetStoryBulletBarrage", t)
end


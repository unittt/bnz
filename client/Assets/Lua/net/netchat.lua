module(..., package.seeall)

--GS2C--

function GS2CChat(pbdata)
	local cmd = pbdata.cmd
	local type = pbdata.type --1-world
	local role_info = pbdata.role_info --pid=0, 表示系统发
	--todo
	local dMsg = {
		channel = type,
		text = cmd,
	}
	if role_info.pid ~= 0 then
		dMsg.role_info = role_info
	end
	g_ChatCtrl:AddMsg(dMsg)
end

function GS2CChatHistory(pbdata)
	local world_chat = pbdata.world_chat --世界聊天记录
	local org_chat = pbdata.org_chat --帮派聊天记录
	local team_chat = pbdata.team_chat --队伍聊天记录
	--todo
	g_ChatCtrl:GS2CChatHistory(pbdata)
end

function GS2CSysChat(pbdata)
	local tag_type = pbdata.tag_type --0-公告，1-传闻，2-帮助
	local content = pbdata.content
	local horse_race = pbdata.horse_race --1-跑马，0-不跑
	--todo
	local type2channel = {
		[0] = define.Channel.Bulletin,
		[1] = define.Channel.Rumour,
		[2] = define.Channel.Help,
	}
	local dMsg = {
		channel = type2channel[tag_type],
		text = content,
		horse_race = horse_race,
	}
	g_ChatCtrl:AddMsg(dMsg)
end

function GS2CConsumeMsg(pbdata)
	local type = pbdata.type --消息-6
	local content = pbdata.content
	--todo
	local dMsg = {
		channel = define.Channel.Message,
		text = content,
	}
	g_ChatCtrl:AddMsg(dMsg)
end

function GS2CChuanYin(pbdata)
	local type = pbdata.type
	local cmd = pbdata.cmd
	local role_info = pbdata.role_info
	--todo
	local dMsg = {
		channel = 1,
		bubble = type,
		text = cmd,
	}
	if role_info.pid ~= 0 then
		dMsg.role_info = role_info
	end
	g_ChatCtrl:AddMsg(dMsg)
	g_ChatCtrl:AddMilesMsg(dMsg)
end

function GS2CAllForbinInfo(pbdata)
	local forbids = pbdata.forbids
	--todo
	g_ChatCtrl:GS2CAllForbinInfo(pbdata)
end

function GS2CAddForbinInfo(pbdata)
	local forbids = pbdata.forbids
	--todo
	g_ChatCtrl:GS2CAddForbinInfo(pbdata)
end

function GS2CRemoveForbinInfo(pbdata)
	local forbids = pbdata.forbids
	--todo
	g_ChatCtrl:GS2CRemoveForbinInfo(pbdata)
end


--C2GS--

function C2GSChat(cmd, type, forbid)
	local t = {
		cmd = cmd,
		type = type,
		forbid = forbid,
	}
	g_NetCtrl:Send("chat", "C2GSChat", t)
end

function C2GSChuanYin(cmd, type)
	local t = {
		cmd = cmd,
		type = type,
	}
	g_NetCtrl:Send("chat", "C2GSChuanYin", t)
end

function C2GSMatchTeamChat(cmd, mingrade, maxgrade, ismatch, type)
	local t = {
		cmd = cmd,
		mingrade = mingrade,
		maxgrade = maxgrade,
		ismatch = ismatch,
		type = type,
	}
	g_NetCtrl:Send("chat", "C2GSMatchTeamChat", t)
end


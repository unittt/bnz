module(..., package.seeall)

--GS2C--

function GS2CNpcSay(pbdata)
	local sessionidx = pbdata.sessionidx
	local npcid = pbdata.npcid
	local model_info = pbdata.model_info
	local name = pbdata.name
	local text = pbdata.text
	local type = pbdata.type --菜单类型 (预先定义)
	local lv2 = pbdata.lv2 --2级菜单标识
	local time = pbdata.time --对话中倒数时间
	local default = pbdata.default --默认自动选中选项
	--todo
	g_DialogueCtrl:GS2CNpcSay(pbdata)
end


--C2GS--

function C2GSClickNpc(npcid)
	local t = {
		npcid = npcid,
	}
	g_NetCtrl:Send("npc", "C2GSClickNpc", t)
end

function C2GSNpcRespond(npcid, answer)
	local t = {
		npcid = npcid,
		answer = answer,
	}
	g_NetCtrl:Send("npc", "C2GSNpcRespond", t)
end

function C2GSFindPathToNpc(npctype)
	local t = {
		npctype = npctype,
	}
	g_NetCtrl:Send("npc", "C2GSFindPathToNpc", t)
end


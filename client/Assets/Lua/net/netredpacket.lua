module(..., package.seeall)

--GS2C--

function GS2CNewRB(pbdata)
	local newrb = pbdata.newrb --新红包
	--todo
	g_RedPacketCtrl:GS2CNewRB(pbdata)
end

function GS2CBasic(pbdata)
	local rpbasicinfo = pbdata.rpbasicinfo --指定红包基本信息
	--todo
	g_RedPacketCtrl:GS2CBasic(pbdata)
end

function GS2CAll(pbdata)
	local channel = pbdata.channel --101=帮派 102=世界
	local allrp = pbdata.allrp --channel频道所有红包信息
	local activerplist = pbdata.activerplist --主动红包列表
	--todo
	g_RedPacketCtrl:GS2CAll(pbdata)
end

function GS2CDelActiveRP(pbdata)
	local index = pbdata.index --主动红包列表下标
	--todo
	g_RedPacketCtrl:GS2CDelActiveRP(pbdata)
end

function GS2CAddActiveRP(pbdata)
	local index = pbdata.index --主动红包列表下标
	local rp = pbdata.rp
	--todo
	g_RedPacketCtrl:GS2CAddActiveRP(pbdata)
end

function GS2CRobSuccess(pbdata)
	local id = pbdata.id --红包id
	local name = pbdata.name --红包名字
	local ownername = pbdata.ownername --红包拥有者名字
	local robcash = pbdata.robcash --抢到额度
	--todo
	g_RedPacketCtrl:GS2CRobSuccess(pbdata)
end

function GS2CRefresh(pbdata)
	local id = pbdata.id --红包id
	local valid = pbdata.valid --1-可领取　2-不能领取
	local finish = pbdata.finish --1-未抢光　2-已抢光
	--todo
	g_RedPacketCtrl:GS2CRefresh(pbdata)
end

function GS2CRemove(pbdata)
	local id = pbdata.id
	--todo
	g_RedPacketCtrl:GS2CRemove(pbdata)
end

function GS2CHistory(pbdata)
	local rob_org_cnt = pbdata.rob_org_cnt --抢帮派红包数量
	local rob_world_cnt = pbdata.rob_world_cnt --抢世界红包数量
	local rob_gold = pbdata.rob_gold --抢金币总数量
	local sent_org_cnt = pbdata.sent_org_cnt --发放帮派红包数量
	local sent_world_cnt = pbdata.sent_world_cnt --发放世界红包数量
	local send_org_gold = pbdata.send_org_gold
	local send_org_goldcoin = pbdata.send_org_goldcoin
	local send_world_gold = pbdata.send_world_gold
	local send_world_goldcoin = pbdata.send_world_goldcoin
	--todo
	g_RedPacketCtrl:GS2CHistory(pbdata)
end

function GS2CRPItem(pbdata)
	local name = pbdata.name
	local count = pbdata.count
	local goldcoin = pbdata.goldcoin
	local id = pbdata.id
	--todo
	g_RedPacketCtrl:GS2CRPItem(pbdata)
end


--C2GS--

function C2GSSendRP(bless, goldcoin, count, channel)
	local t = {
		bless = bless,
		goldcoin = goldcoin,
		count = count,
		channel = channel,
	}
	g_NetCtrl:Send("redpacket", "C2GSSendRP", t)
end

function C2GSRobRP(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("redpacket", "C2GSRobRP", t)
end

function C2GSQueryAll(channel)
	local t = {
		channel = channel,
	}
	g_NetCtrl:Send("redpacket", "C2GSQueryAll", t)
end

function C2GSQueryBasic(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("redpacket", "C2GSQueryBasic", t)
end

function C2GSQueryHistory()
	local t = {
	}
	g_NetCtrl:Send("redpacket", "C2GSQueryHistory", t)
end

function C2GSUseRPItem(itemid, channel)
	local t = {
		itemid = itemid,
		channel = channel,
	}
	g_NetCtrl:Send("redpacket", "C2GSUseRPItem", t)
end

function C2GSActiveSendSYS(index, goldcoin, bless, amount)
	local t = {
		index = index,
		goldcoin = goldcoin,
		bless = bless,
		amount = amount,
	}
	g_NetCtrl:Send("redpacket", "C2GSActiveSendSYS", t)
end


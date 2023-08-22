module(..., package.seeall)

--GS2C--

function GS2CNotify(pbdata)
	local cmd = pbdata.cmd
	--todo
	g_NotifyCtrl:FloatMsg(cmd, nil, true)
end

function GS2CWarNotify(pbdata)
	local cmd = pbdata.cmd
	local type = pbdata.type --提示类型0x0001 表示弹窗,0x0010表示聊天提示,0x00100 不跟随技能，独立提示
	local flag = pbdata.flag --0.perform开始(默认即时生效) 1.受击时 2.perform结束
	--todo
	local oCmd = CWarCmd.New("WarNotify")
	oCmd.wid = g_WarCtrl.m_CurActionWid
	oCmd.type = type
	oCmd.content = cmd
	oCmd.flag = flag
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd and not oVaryCmd:IsUsed() then
		-- 可能同时触发多个，改成list
		local cmdList = oVaryCmd:GetVary(oCmd.wid, "notify_cmds")
		if not cmdList then
			cmdList = {}
			oVaryCmd:SetVary(oCmd.wid, "notify_cmds", cmdList)
		end
		table.insert(cmdList, oCmd)
	else
		g_WarCtrl:InsertCmd(oCmd)
	end
end

function GS2CItemNotify(pbdata)
	local sid = pbdata.sid --道具sid
	local amount = pbdata.amount --道具数量
	local type = pbdata.type --消息类型 0-获得,1-购买
	--todo
	local config = DataTools.GetItemData(sid)
	local quality = config.quality or 0 
	local color = data.colorinfodata.ITEM[quality].color
	if amount > 0 then
		if type == 0 then
			g_NotifyCtrl:FloatMsg("获得"..string.format(color, config.name).."×"..
			string.format(data.colorinfodata.OTHER.item.color, amount), {icon = config.icon, count = amount}, true)
		else
			g_NotifyCtrl:FloatMsg("购买了"..string.format(data.colorinfodata.OTHER.item.color, amount).."个"..
			string.format(color, config.name), {icon = config.icon, count = amount}, true)
		end
	elseif amount < 0 then
		g_NotifyCtrl:FloatMsg("消耗"..string.format(data.colorinfodata.OTHER.item.color, math.abs(amount))
		.."个"..string.format(color, config.name), {icon = config.icon, count = amount}, true)
	end
end

function GS2CSummonNotify(pbdata)
	local sid = pbdata.sid --召唤兽id
	local amount = pbdata.amount --道具数量
	local type = pbdata.type --消息类型 0-获得,1-购买
	--todo
	local config = DataTools.GetSummonInfo(sid)
	if amount > 0 then
		if type == 0 then
			g_NotifyCtrl:FloatMsg("获得"..string.format(data.colorinfodata.OTHER.item.color, config.name).."×"..
			string.format(data.colorinfodata.OTHER.item.color, amount), {shape = config.shape, count = amount}, true)
		else
			g_NotifyCtrl:FloatMsg("购买了"..string.format(data.colorinfodata.OTHER.item.color, amount).."个"..
			string.format(data.colorinfodata.OTHER.item.color, config.name), {shape = config.shape, count = amount}, true)
		end
	elseif amount < 0 then
		g_NotifyCtrl:FloatMsg("消耗"..string.format(data.colorinfodata.OTHER.item.color, math.abs(amount))
		.."个"..string.format(data.colorinfodata.OTHER.item.color, config.name), {shape = config.shape, count = amount}, true)
	end
end

function GS2CUIEffectNotify(pbdata)
	local effect = pbdata.effect --客户端表现类型 1、打造 2、强化 3、洗炼 4、附魂
	local cmds = pbdata.cmds --提示信息
	--todo
	g_ItemCtrl:OnEvent(define.Item.Event.ShowUIEffect, pbdata)
end


--C2GS--


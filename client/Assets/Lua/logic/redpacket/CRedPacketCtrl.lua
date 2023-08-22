local CRedPacketCtrl = class("CRedPacketCtrl", CCtrlBase)

function CRedPacketCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_SelectSendChannel = define.RedPacket.Channel.Org

	self.m_MainViewRedPacketList = {}

	self.m_RedPacketViewList = {}
	self.m_RedPacketGetPlayerTotal = 0
	self.m_RedPacketGetPlayerList = {}

	self.m_RedPacketOrgSysList = {}
	self.m_SysAddMoney = 0

	self.m_DeleteTimer = {}

	self.m_IsCheckOrgRedPacket = false
end

function CRedPacketCtrl.Clear(self)
	self.m_IsCheckOrgRedPacket = false
	self.m_ShowOrgRedPoint = false
end

function CRedPacketCtrl.RequestOrgRedPacketData(self)
	--请求帮派红包信息
	if not g_RedPacketCtrl.m_IsCheckOrgRedPacket then
		g_RedPacketCtrl.m_IsNotOpenView = true
		netredpacket.C2GSQueryAll(define.RedPacket.Channel.Org)
		g_RedPacketCtrl.m_IsCheckOrgRedPacket = true
	end
end

function CRedPacketCtrl.GS2CNewRB(self, pbdata)
	local newrb = pbdata.newrb --新红包

	if newrb.se == 102 then
		g_NotifyCtrl:ShowRedPacketEffect()
	end

	table.insert(self.m_MainViewRedPacketList, 1, newrb)
	g_NotifyCtrl:ShowRedPacket()
	if self.m_DeleteTimer[newrb.id] then
		Utils.DelTimer(self.m_DeleteTimer[newrb.id])
		self.m_DeleteTimer[newrb.id] = nil			
	end
	local function progress()
		local bIsExist = false
		local oKey
		for k,v in pairs(self.m_MainViewRedPacketList) do
			if v.id == newrb.id then
				bIsExist = true
				oKey = k
				break
			end
		end
		if not bIsExist then
			return false
		end		
		table.remove(self.m_MainViewRedPacketList, oKey)
		g_NotifyCtrl:ShowRedPacket()
		return false
	end
	self.m_DeleteTimer[newrb.id] = Utils.AddTimer(progress, 0, 2)
	table.print(pbdata, "CRedPacketCtrl.GS2CNewRB")
end

function CRedPacketCtrl.GS2CBasic(self, pbdata)
	local rpbasicinfo = pbdata.rpbasicinfo --指定红包基本信息

	self.m_RedPacketGetPlayerTotal = rpbasicinfo.count
	self.m_RedPacketGetPlayerList = {}
	for k,v in pairs(rpbasicinfo.receiveinfo) do
		self.m_RedPacketGetPlayerList[k] = v
	end
	self:CheckGetPlayerList()

	local oView = CRedPacketGetPlayerView:GetView()
	if oView then
		self:OnEvent(define.RedPacket.Event.GetRedPacketPlayer, pbdata)
	else
		CRedPacketGetPlayerView:ShowView(function (oView)
				oView:RefreshUI(pbdata)
			end)
	end
	table.print(pbdata, "CRedPacketCtrl.GS2CBasic")
end

function CRedPacketCtrl.GS2CAll(self, pbdata)
	local channel = pbdata.channel --101=帮派 102=世界
	local allrp = pbdata.allrp --channel频道所有红包信息
	local activerplist = pbdata.activerplist --主动红包列表

	if channel == define.RedPacket.Channel.Org then
		self.m_RedPacketOrgSysList = {}
		table.copy(activerplist, self.m_RedPacketOrgSysList)
	end

	self.m_RedPacketViewList = {}
	for k,v in pairs(allrp) do
		self.m_RedPacketViewList[k] = v
	end
	table.sort(self.m_RedPacketViewList, function (a, b) return a.createtime > b.createtime end)

	if not g_RedPacketCtrl.m_IsNotOpenView then
		if channel == define.RedPacket.Channel.World then
			local oView = CRedPacketMainView:GetView()
			if oView then
				self:OnEvent(define.RedPacket.Event.RefreshWorldRedPacket, pbdata)
			else
				CRedPacketMainView:ShowView(function (oView)
						oView:SetWorldUI()
						oView.m_WorldPart:RefreshUI(pbdata)
					end)
			end
		else
			local oView = CRedPacketMainView:GetView()
			if oView then
				self:OnEvent(define.RedPacket.Event.RefreshOrgRedPacket, pbdata)
			else
				CRedPacketMainView:ShowView(function (oView)
						oView:SetOrgUI()
						oView.m_OrgPart:RefreshUI(pbdata)
					end)
			end
		end
	else
		local isFinish = true
		for k,v in pairs(allrp) do
			if v.valid == 1 then
				isFinish = false
				break
			end
		end
		if channel == define.RedPacket.Channel.Org and (next(activerplist)  or not isFinish ) and g_AttrCtrl.org_id > 0 then
			self.m_ShowOrgRedPoint = true
		end
		g_OrgCtrl:OnEvent(define.Org.Event.UpdateOrgRedPoint)
	end
	g_RedPacketCtrl.m_IsNotOpenView = false

	table.print(pbdata, "CRedPacketCtrl.GS2CAll")
end

function CRedPacketCtrl.GS2CRobSuccess(self, pbdata)
	local id = pbdata.id --红包id
	local name = pbdata.name --红包名字
	local ownername = pbdata.ownername --红包拥有者名字
	local robcash = pbdata.robcash --抢到额度

	-- local oView = CRedPacketGetView:GetView()
	-- if oView then
	-- 	self:OnEvent(define.RedPacket.Event.GetRedPacketSuccess, pbdata)
	-- else
	-- 	CRedPacketGetView:ShowView(function (oView)
	-- 			oView:RefreshUI(pbdata)
	-- 		end)
	-- end
	netredpacket.C2GSQueryBasic(id)
	
	table.print(pbdata, "CRedPacketCtrl.GS2CRobSuccess")
end

function CRedPacketCtrl.GS2CRefresh(self, pbdata)
	local id = pbdata.id --红包id
	local valid = pbdata.valid --1-可领取　2-不能领取
	local finish = pbdata.finish --1-未抢光　2-已抢光

	for k,v in pairs(self.m_RedPacketViewList) do
		if v.id == id then
			v.valid = valid
			v.finish = finish
			break
		end
	end
	for k,v in pairs(self.m_MainViewRedPacketList) do
		if v.id == id then
			v.valid = valid
			v.finish = finish
			break
		end
	end
	self:OnEvent(define.RedPacket.Event.RefreshMainUI)
	
	table.print(pbdata, "CRedPacketCtrl.GS2CRefresh")
end

function CRedPacketCtrl.GS2CRemove(self, pbdata)
	local id = pbdata.id
	for k,v in pairs(self.m_RedPacketViewList) do
		if v.id == id then
			table.remove(self.m_RedPacketViewList, k)
			break
		end
	end
	for k,v in pairs(self.m_MainViewRedPacketList) do
		if v.id == id then
			table.remove(self.m_MainViewRedPacketList, k)
			break
		end
	end
	self:OnEvent(define.RedPacket.Event.DeleteRedPacket)

	table.print(pbdata, "CRedPacketCtrl.GS2CRemove")
end

function CRedPacketCtrl.GS2CHistory(self, pbdata)
	local oView = CRedPacketSelfRecordView:GetView()
	if oView then
		self:OnEvent(define.RedPacket.Event.GetRedPacketSelfRecord, pbdata)
	else
		CRedPacketSelfRecordView:ShowView(function (oView)
				oView:RefreshUI(pbdata)
			end)
	end
	
	table.print(pbdata, "CRedPacketCtrl.GS2CHistory")
end

function CRedPacketCtrl.GS2CRPItem(self, pbdata)
	local name = pbdata.name
	local count = pbdata.count
	local goldcoin = pbdata.goldcoin
	local id = pbdata.id

	CRedPacketItemSendView:ShowView(function (oView)
			oView:RefreshUI(pbdata)
		end)
	table.print(pbdata, "CRedPacketCtrl.GS2CRPItem")
end

function CRedPacketCtrl.GS2CDelActiveRP(self, pbdata)
	table.remove(self.m_RedPacketOrgSysList, pbdata.index)
	CRedPacketOrgSysSendView:CloseView()
	self:OnEvent(define.RedPacket.Event.UpdateSysRedPacket)
	table.print(pbdata, "CRedPacketCtrl.GS2CDelActiveRP")
end

function CRedPacketCtrl.GS2CAddActiveRP(self, pbdata)
	table.insert(self.m_RedPacketOrgSysList, pbdata.index, pbdata.rp)
	CRedPacketOrgSysSendView:ShowView(function (oView)
		oView:RefreshUI(pbdata.rp, pbdata.index)
	end)
	self:OnEvent(define.RedPacket.Event.UpdateSysRedPacket)
	table.print(pbdata, "CRedPacketCtrl.GS2CAddActiveRP")
end

function CRedPacketCtrl.CheckGetPlayerList(self)
	if next(self.m_RedPacketGetPlayerList) then
		if #self.m_RedPacketGetPlayerList >= self.m_RedPacketGetPlayerTotal then
			table.sort(self.m_RedPacketGetPlayerList, function (a, b)
				return a.cash < b.cash
			end)
			local best = {self.m_RedPacketGetPlayerList[1]}
			local index = {1}
			for k,v in ipairs(self.m_RedPacketGetPlayerList) do
				if k > 1 then
					if v.cash > best[1].cash then
						best = {v}
						index = {k}
					elseif v.cash == best[1].cash then
						table.insert(best, v)
						table.insert(index, k)
					end
				end
			end

			table.sort(index, function (a, b)
				return self.m_RedPacketGetPlayerList[a].cash < self.m_RedPacketGetPlayerList[b].cash
			end)
			local list = self.m_RedPacketGetPlayerList[index[1]]
			table.remove(self.m_RedPacketGetPlayerList, index[1])
			table.insert(self.m_RedPacketGetPlayerList, 1, list)
		else
			table.sort(self.m_RedPacketGetPlayerList, function (a, b)
				return a.cash < b.cash
			end)
		end
	end
end

function CRedPacketCtrl.GetPlayerGetMoney(self)
	local money = 0
	for k,v in pairs(self.m_RedPacketGetPlayerList) do
		money = money + v.cash
	end
	return money
end

--获取元宝转银币的基础数值
function CRedPacketCtrl.GetGoldIconToSilverBase(self)
	return (g_AttrCtrl.server_grade*25+4000)
end

--获取是金币还是银币, 1金币 2银币
function CRedPacketCtrl.GetConvertType(self, type)
	if type == 101 then
		return 1
	elseif type == 102 then
		return 2
	end
	return 1
end

--1元宝 2绑定元宝 3金币 4银币
function CRedPacketCtrl.GetCommonAtlasMoneyIcon(self, oMoneyIndex)
	if oMoneyIndex == 1 then
		return "10001"
	elseif oMoneyIndex == 2 then
		return "10221"
	elseif oMoneyIndex == 3 then
		return "10002"
	elseif oMoneyIndex == 4 then
		return "10003"
	else
		return "10003"
	end
end

return CRedPacketCtrl
module(..., package.seeall)

--GS2C--

function GS2COpenRecoveryItem(pbdata)
	local itemdata = pbdata.itemdata
	--todo
   g_RecoveryCtrl:GS2COpenRecoveryItem(itemdata)
end

function GS2CDelRecoveryItem(pbdata)
	local id = pbdata.id
	--todo
	g_RecoveryCtrl:GS2CDelRecoveryItem(id)
end

function GS2COpenRecoverySum(pbdata)
	local sumdata = pbdata.sumdata
	--todo
	g_RecoveryCtrl:GS2COpenRecoverySum(sumdata)
end

function GS2CDelRecoverSum(pbdata)
	local id = pbdata.id
	--todo
	g_RecoveryCtrl:GS2CDelRecoverSum(id)
end


--C2GS--

function C2GSRecoveryItem(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("recovery", "C2GSRecoveryItem", t)
end

function C2GSRecoverySum(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("recovery", "C2GSRecoverySum", t)
end


module(..., package.seeall)

--GS2C--

function GS2CUpgradeTouxianInfo(pbdata)
	local infos = pbdata.infos
	--todo
    g_AttrCtrl:GS2CUpgradeTouxianInfo(infos)
end


--C2GS--

function C2GSUpgradeTouxian()
	local t = {
	}
	g_NetCtrl:Send("touxian", "C2GSUpgradeTouxian", t)
end


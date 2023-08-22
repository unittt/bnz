module(..., package.seeall)

--GS2C--

function GS2CLoginOpenSys(pbdata)
	local open_sys = pbdata.open_sys
	--todo
	g_OpenSysCtrl:GS2CLoginOpenSys(pbdata)
end

function GS2COpenSysChange(pbdata)
	local changes = pbdata.changes
	--todo
	g_OpenSysCtrl:GS2COpenSysChange(pbdata)
end

function GS2CSysSwitch(pbdata)
	local syslist = pbdata.syslist
	--todo
	g_FeedbackCtrl:GS2CSysSwitch(syslist)
	g_OpenSysCtrl:OnEvent(define.SysOpen.Event.Change)
end


--C2GS--


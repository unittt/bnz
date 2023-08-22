local CSpiritCtrl = class("CSpiritCtrl", CCtrlBase)

function CSpiritCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self:Clear()
end

function CSpiritCtrl.Clear(self)
	self.m_MsgList = {}
end

function CSpiritCtrl.GetRandomItemConfig(self, oExceptId)
	local oList = {}
	local allConfigList = {}
	table.copy(data.spiritdata.SPIRITITEM, allConfigList)
	if oExceptId then
		table.remove(allConfigList, oExceptId)
	end
	local oFirstKey = table.randomkey(allConfigList)
	local oFirstConfig = allConfigList[oFirstKey]
	table.insert(oList, oFirstConfig)
	table.remove(allConfigList, oFirstKey)

	local oSecondConfig = table.randomvalue(allConfigList)
	table.insert(oList, oSecondConfig)

	return oList
end

function CSpiritCtrl.GetOpenState(self)
	-- return false
	return g_OpenSysCtrl:GetOpenSysState(define.System.SpiritGuide)
end

function CSpiritCtrl.GetUrl(self)
	return Utils.GetUrl("http://dhbs-qa.demigame.com",
			{openid = g_SdkCtrl.m_VerifyPhoneUid or "",
			roleid = g_AttrCtrl.pid,
			nick = string.gsub(UnityEngine.WWW.EscapeURL(g_AttrCtrl.name), "+", "%20"),
			birdate = g_AttrCtrl.create_time or 0,
			lev = g_AttrCtrl.grade,
			gameserver = g_ServerPhoneCtrl:GetCurServerData() and g_ServerPhoneCtrl:GetCurServerData().id or "",
			schools = string.gsub(UnityEngine.WWW.EscapeURL(data.schooldata.DATA[g_AttrCtrl.school].name), "+", "%20"),
			charactorId = g_AttrCtrl.roletype,
			})
end

return CSpiritCtrl
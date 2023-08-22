local CLogCtrl = class("LogCLogCtrlCtrl")


--参数  operate 玩家操作类型    tableData：该操作需要上传的相关数据，类型为table , tableData可空,但非空时必须为table类型
function CLogCtrl.SendLog(self, operate, tableData)

	local logBaseInfo = tableData or {}
	--插入log信息的必须数据
	logBaseInfo.account = g_SdkCtrl.m_VerifyPhoneUid or ""
	logBaseInfo.channel = g_SdkCtrl.m_ChannelId or ""
	logBaseInfo.pid = g_AttrCtrl.pid and g_AttrCtrl.pid or 0
	logBaseInfo.operate = operate
	logBaseInfo.time = string.gsub(g_TimeCtrl:GetTimeYMD(), "/", "-")
	logBaseInfo.device = Utils.GetDeviceModel()
	logBaseInfo.net = C_api.Utils.GetNetworkType()
	logBaseInfo.error = "null"
	logBaseInfo.platform = UnityEngine.Application.platform
	logBaseInfo.mac = Utils.GetDeviceUID()

	local jsonData = cjson.encode(logBaseInfo)
	
	C_api.LogMgr.SendLog(jsonData)

end

return CLogCtrl

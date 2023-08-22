local CUploadDataCtrl = class("CUploadDataCtrl")

function CUploadDataCtrl.ctor(self)

end

-- 数据格式: logtype: analylog(数据中心log), analytype: 见需求excel(具体的类型)　data: 具体数据(如果没有值可不传)
-- {'logtype': 'analylog', 'analytype': 'test', 'data':{'account':'xxxx','ip':'192.168.0.0'}}
--参数  operate 玩家操作类型    tData：该操作需要上传的相关数据，类型为table , tData可空,但非空时必须为table类型
-- 记录创建角色界面按钮点击的日志
function CUploadDataCtrl.CreateRoleUpload(self, tData)
	if Utils.IsPC() then
		return
	end

	local platid = 3
	if Utils.IsIOS() then
		platid =  2
	elseif Utils.IsAndroid() then
		platid = 1
	end

	if platid == 3 then
		-- PC 不可提交
		return
	end

	local _, v1, v2, v3 = C_api.Utils.GetResVersion()
	local version = string.format("%s.%s.%s",v1, v2, v3)
	local oCurServer = g_ServerPhoneCtrl:GetCurServerData()
	local t = {
		logtype = "RoleUi",
		analytype = "",
		data = {
			time = "",
			account_id = g_SdkCtrl.m_VerifyPhoneUid or "",
			click = "",
			ip = C_api.NetworkHelper.GetLocalIP(),
			device_model = Utils.GetDeviceModel(),
			udid = Utils.GetDeviceUID(),
			os = UnityEngine.SystemInfo.operatingSystem,
			version = version,
			app_channel = g_SdkCtrl.m_DemiChannelID or "",
			sub_channel = g_SdkCtrl:GetSubChannelId() or "",
			server = oCurServer and oCurServer.id or "",
			plat = platid,
		}
	}
	table.update(t, tData)
	local headers = {
		-- ["Content-Type"] = "application/x-www-form-urlencoded",
		["Content-Type"] = "application/json;charset=utf-8",
	}

	local url = g_UrlRootCtrl.m_BSRootUrl.."clientlog"
	table.print(t, "########### UploadData Data #########")
	g_HttpCtrl:Post(url, nil, headers, cjson.encode(t))
end

--打点信息使用
function CUploadDataCtrl.PostServerDotList(self, data)

	local url = g_UrlRootCtrl.m_BSRootUrl.."clientlog"

	local path = IOTools.GetPersistentDataPath("/serverdotlistData")
	IOTools.SaveJsonFile(path, data)

	local handler = C_api.FileHandler.OpenByte(path)
	if not handler then
		return
	end
	local bytes = handler:ReadByte()
	handler:Close()

	local headers = {
		["Content-Type"]="application/json;charset=utf-8",
	}
	g_HttpCtrl:Post(url, callback(self, "OnServerDotListResult"), headers, bytes, {json_result=true})
end

function CUploadDataCtrl.OnServerDotListResult(self, success, tResult)
	
end

--这里的id是原始的打点id，不是配置表的对应的关系id
function CUploadDataCtrl.GetDotNameById(self, oId)
	if oId == "2" then
		return "点击渠道的下载图标"
	elseif oId == "3" then
		return "下载游戏资源包"
	elseif oId == "3" then
		return "开始安装"
	elseif oId == "4" then
		return "解压资源"
	elseif oId == "5" then
		return "安装游戏"
	elseif oId == "6" then
		return "更新游戏"
	elseif oId == "7" then
		return "下载更新游戏资源包"
	elseif oId == "8" then
		return "解压资源安装更新"
	elseif oId == "9" then
		return "安装更新包"
	elseif oId == "10" then
		return "注册账号"
	elseif oId == "11" then
		return "完成注册"

-----------登录相关------------
	elseif oId == "12" then
		return "登陆账号"
	elseif oId == "13" then
		return "游戏开始界面"
	elseif oId == "14" then
		return "出现公告"
	elseif oId == "15" then
		return "关闭公告"
	elseif oId == "16" then
		return "选择服务器"
	elseif oId == "17" then
		return "选择历史角色"
	elseif oId == "18" then
		return "关闭选择服务器界面"

---------创建角色相关------------
	elseif oId == "19" then
		return "加载选择角色界面"
	elseif oId == "20" then
		return "选择角色"
	elseif oId == "21" then
		return "输入名字"
	elseif oId == "22" then
		return "选择门派"
	elseif oId == "23" then
		return "开始游戏"
	elseif oId == "24" then
		return "加载游戏资源"

----------引导相关--------------
	elseif oId == "25" then
		return "询问是否玩过回合游戏的界面引导"
	elseif oId == "26" then
		return "引导第一场战斗选择技能"
	elseif oId == "27" then
		return "引导第一场战斗选择目标"
	elseif oId == "28" then
		return "引导第一场战斗选择自动战斗"
	elseif oId == "29" then
		return "引导点击第一个任务"
	elseif oId == "30" then
		return "引导点击第一个任务对话界面"
	elseif oId == "31" then
		return "引导选择第一个宠物"
	elseif oId == "32" then
		return "引导选择第一个宠物出战"
	elseif oId == "33" then
		return "引导关闭宠物界面"
	elseif oId == "34" then
		return "引导宠物合成"
	elseif oId == "35" then
		return "引导宠物合成选择宠物炼妖标签"
	elseif oId == "36" then
		return "引导宠物合成选择宠物合成标签"
	elseif oId == "37" then
		return "引导宠物合成点击第一个加号"
	elseif oId == "38" then
		return "引导宠物合成选择第一个要合成的宠物"
	elseif oId == "39" then
		return "引导宠物合成选择第一个要合成的宠物点击确定"
	elseif oId == "40" then
		return "引导宠物合成点击第二个加号"
	elseif oId == "41" then
		return "引导宠物合成选择第二个要合成的宠物"
	elseif oId == "42" then
		return "引导宠物合成选择第二个要合成的宠物点击确定"
	elseif oId == "43" then
		return "引导宠物合成点击最终合成按钮"
	elseif oId == "44" then
		return "引导穿戴第一件武器"
	elseif oId == "45" then
		return "引导使用10级装备礼包"
	elseif oId == "46" then
		return "引导一键穿戴10级装备"
	elseif oId == "47" then
		return "引导使用20级装备礼包"
	elseif oId == "48" then
		return "引导一键穿戴20级装备"
	elseif oId == "49" then
		return "引导使用30级装备礼包"
	elseif oId == "50" then
		return "引导一键穿戴30级装备"
	elseif oId == "51" then
		return "引导使用40级装备礼包"
	elseif oId == "52" then
		return "引导一键穿戴40级装备"
	elseif oId == "53" then
		return "引导签到"
	elseif oId == "54" then
		return "引导签到点击第一天奖励"
	elseif oId == "55" then
		return "引导签到点击关闭福利界面"
	elseif oId == "56" then
		return "引导点击升级心法"
	elseif oId == "57" then
		return "引导点击升级心法选择界面心法标签"
	elseif oId == "58" then
		return "引导点击升级心法点击一键升级"
	elseif oId == "59" then
		return "引导点击升级心法关闭技能界面"
	elseif oId == "60" then
		return "引导查看10级礼包"
	elseif oId == "61" then
		return "引导查看10级礼包点击福利界面礼包标签"
	elseif oId == "62" then
		return "引导查看10级礼包点击领取按钮"
	elseif oId == "63" then
		return "引导查看20级礼包"
	elseif oId == "64" then
		return "引导查看20级礼包点击福利界面礼包标签"
	elseif oId == "65" then
		return "引导查看20级礼包点击领取按钮"
	elseif oId == "66" then
		return "引导查看30级礼包"
	elseif oId == "67" then
		return "引导查看30级礼包点击福利界面礼包标签"
	elseif oId == "68" then
		return "引导查看30级礼包点击领取按钮"
	elseif oId == "69" then
		return "引导查看40级礼包"
	elseif oId == "70" then
		return "引导查看40级礼包点击福利界面礼包标签"
	elseif oId == "71" then
		return "引导查看40级礼包点击领取按钮"
	elseif oId == "72" then
		return "引导提升技能"
	elseif oId == "73" then
		return "引导提升技能点击升级心法选项"
	elseif oId == "74" then
		return "引导提升技能点击一键升级心法"
	elseif oId == "75" then
		return "引导帮派一键申请"
	elseif oId == "76" then
		return "引导帮派一键申请点击关闭界面"
	elseif oId == "77" then
		return "引导帮派一键申请"
	elseif oId == "78" then
		return "引导帮派一键申请点击一键申请按钮"
	-- elseif oId == "79" then
	-- 	return "引导帮派一键申请点击关闭界面"
	elseif oId == "80" then
		return "引导伙伴招募"
	elseif oId == "81" then
		return "引导伙伴招募点击伙伴的标签页"
	elseif oId == "82" then
		return "引导领取系统预告礼包"
	elseif oId == "83" then
		return "引导领取系统预告礼包点击领取按钮"
	elseif oId == "84" then
		return "引导装备强化"
	elseif oId == "85" then
		return "引导装备强化点击界面强化标签"
	elseif oId == "86" then
		return "引导装备强化点击强化按钮"
	elseif oId == "87" then
		return "引导装备强化点击关闭界面"
	elseif oId == "88" then
		return "引导坐骑点击主界面坐骑按钮"
	elseif oId == "89" then
		return "引导坐骑点击要选择的坐骑标签"
	elseif oId == "90" then
		return "引导坐骑点击骑乘按钮"
	elseif oId == "91" then
		return "引导坐骑点击关闭界面"
	elseif oId == "92" then
		return "引导领取系统预告礼包点击关闭界面"
	elseif oId == "93" then
		return "引导伙伴招募点击招募按钮"
	elseif oId == "94" then
		return "引导头衔晋升点击主界面头衔按钮"
	elseif oId == "95" then
		return "引导头衔晋升点击头衔界面晋升按钮"
	elseif oId == "96" then
		return "引导头衔晋升点击头衔界面关闭按钮"
	elseif oId == "97" then
		return "引导八日登录奖励的主界面福利按钮"
	elseif oId == "98" then
		return "引导八日登录奖励的福利界面的八日登录标签页"
	elseif oId == "99" then
		return "引导八日登录奖励的八日登录界面的领取奖励按钮"
	elseif oId == "100" then
		return "引导八日登录奖励的八日登录界面的关闭按钮"
	else
		return "未定义的名字"
	end
end

--修改引导步骤这里也要变动
--这里的id是原始的打点id，不是配置表的对应的关系id
function CUploadDataCtrl.SetDotByGuideType(self, oType, oGuideStatus)
	local oIdStr
	if oType == "War3_2" then
		oIdStr = "26"
	elseif oType == "War3_3" then
		oIdStr = "27"
	elseif oType == "War3_4" then
		oIdStr = "28"
	elseif oType == "Task1_1" then
		oIdStr = "29"
	elseif oType == "Task1Dialogue_1" then
		oIdStr = "30"
	elseif oType == "SummonGet_1" then
		oIdStr = "31"
	elseif oType == "SummonGet_2" then
		oIdStr = "32"
	elseif oType == "SummonGet_3" then
		oIdStr = "33"
	--宠物合成暂时屏蔽
	-- elseif oType == "SummonCompose_1" then
	-- 	oIdStr = "34"
	-- elseif oType == "SummonCompose_2" then
	-- 	oIdStr = "35"
	-- elseif oType == "SummonCompose_3" then
	-- 	oIdStr = "36"
	-- elseif oType == "SummonCompose_4" then
	-- 	oIdStr = "37"
	-- elseif oType == "SummonCompose_5" then
	-- 	oIdStr = "38"
	-- elseif oType == "SummonCompose_6" then
	-- 	oIdStr = "39"
	-- elseif oType == "SummonCompose_7" then
	-- 	oIdStr = "40"
	-- elseif oType == "SummonCompose_8" then
	-- 	oIdStr = "41"
	-- elseif oType == "SummonCompose_9" then
	-- 	oIdStr = "42"
	-- elseif oType == "SummonCompose_10" then
	-- 	oIdStr = "43"

	elseif oType == "EquipGetNew_1" then
		oIdStr = "44"
	elseif oType == "UseItem10_1" then
		oIdStr = "45"
	elseif oType == "EquipGet10_1" then
		oIdStr = "46"
	--暂时屏蔽
	-- elseif oType == "UseItem20_1" then
	-- 	oIdStr = "47"
	-- elseif oType == "EquipGet20_1" then
	-- 	oIdStr = "48"
	-- elseif oType == "UseItem30_1" then
	-- 	oIdStr = "49"
	-- elseif oType == "EquipGet30_1" then
	-- 	oIdStr = "50"
	-- elseif oType == "UseItem40_1" then
	-- 	oIdStr = "51"
	-- elseif oType == "EquipGet40_1" then
	-- 	oIdStr = "52"

	elseif oType == "Welfare_1" then
		oIdStr = "53"
	elseif oType == "Welfare_2" then
		oIdStr = "54"
	elseif oType == "Welfare_3" then
		oIdStr = "55"
	elseif oType == "Skill_1" then
		oIdStr = "56"
	elseif oType == "Skill_2" then
		oIdStr = "57"
	elseif oType == "Skill_3" then
		oIdStr = "58"
	elseif oType == "Skill_4" then
		oIdStr = "59"
	elseif oType == "UpgradePack_1" then
		oIdStr = "60"
	elseif oType == "UpgradePack_2" then
		oIdStr = "61"
	elseif oType == "UpgradePack_3" then
		oIdStr = "62"
	--暂时屏蔽
	-- elseif oType == "UpgradePack20_1" then
	-- 	oIdStr = "63"
	-- elseif oType == "UpgradePack20_2" then
	-- 	oIdStr = "64"
	-- elseif oType == "UpgradePack20_3" then
	-- 	oIdStr = "65"
	-- elseif oType == "UpgradePack30_1" then
	-- 	oIdStr = "66"
	-- elseif oType == "UpgradePack30_2" then
	-- 	oIdStr = "67"
	-- elseif oType == "UpgradePack30_3" then
	-- 	oIdStr = "68"
	-- elseif oType == "UpgradePack40_1" then
	-- 	oIdStr = "69"
	-- elseif oType == "UpgradePack40_2" then
	-- 	oIdStr = "70"
	-- elseif oType == "UpgradePack40_3" then
	-- 	oIdStr = "71"
	elseif oType == "Improve_1" then
		oIdStr = "72"
	elseif oType == "Improve_2" then
		oIdStr = "73"
	elseif oType == "Improve_3" then
		oIdStr = "74"
	elseif oType == "Org_1" then
		oIdStr = "75"
	elseif oType == "Org_2" then
		oIdStr = "76"
	elseif oType == "OrgExist_1" then
		oIdStr = "77"
	elseif oType == "OrgExist_2" then
		oIdStr = "78"
	-- elseif oType == "OrgExist_3" then
	-- 	oIdStr = "79"
	elseif oType == "GetPartner_1" then
		oIdStr = "80"
	elseif oType == "GetPartner_2" then
		oIdStr = "81"
	elseif oType == "PreOpen_1" then
		oIdStr = "82"
	elseif oType == "PreOpen_2" then
		oIdStr = "83"
	elseif oType == "equipqh_1" then
		oIdStr = "84"
	elseif oType == "equipqh_2" then
		oIdStr = "85"
	elseif oType == "equipqh_3" then
		oIdStr = "86"
	elseif oType == "equipqh_4" then
		oIdStr = "87"
	elseif oType == "Ride_1" then
		oIdStr = "97"
	elseif oType == "Ride_2" then
		oIdStr = "98"
	elseif oType == "Ride_3" then
		oIdStr = "99"
	elseif oType == "Ride_4" then
		oIdStr = "88"
	elseif oType == "Ride_5" then
		oIdStr = "89"
	elseif oType == "Ride_6" then
		oIdStr = "90"
	elseif oType == "Ride_7" then
		oIdStr = "91"
	elseif oType == "PreOpen_3" then
		oIdStr = "92"
	elseif oType == "GetPartner_3" then
		oIdStr = "93"
	elseif oType == "TouXian_1" then
		oIdStr = "94"
	elseif oType == "TouXian_2" then
		oIdStr = "95"
	elseif oType == "TouXian_3" then
		oIdStr = "96"
	elseif oType == "EightLogin_1" then
		oIdStr = "97"
	elseif oType == "EightLogin_2" then
		oIdStr = "98"
	elseif oType == "EightLogin_3" then
		oIdStr = "99"
	elseif oType == "EightLogin_4" then
		oIdStr = "100"
	end
	if oIdStr then
		g_UploadDataCtrl:SetDotUpload(oIdStr, oGuideStatus)
	end
end

--通用接口，需要能够链接gs地址时才能调用，传一个打点id(字符串)进行打点
function CUploadDataCtrl.SetDotUpload(self, oId, oGuideStatus)
	if g_LoginPhoneCtrl.m_IsPC then
		return
	end
	local _, framever2, gamever2, resver2 = C_api.Utils.GetResVersion()
	local oCurServer = g_ServerPhoneCtrl:GetCurServerData()
	local oHasPlay = g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("hasplay")
	local oNotPlay = g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("notplay")
	local oSelect = 0
	if not oHasPlay and not oNotPlay then
		oSelect = 0
	elseif oHasPlay and not oNotPlay then
		oSelect = 1
	elseif not oHasPlay and oNotPlay then
		oSelect = 2
	end
	local needData = {
		logtype = "analylog",
		analytype = "behavior",
		data = {
			behavior_type = data.dotdata.DOT[oId].sortid, --这里要取的是游戏逻辑顺序的id，所以是取打点配置表里面的东西
			behavior_name = g_UploadDataCtrl:GetDotNameById(oId),
			behavior_status = oGuideStatus,
			account_id = g_SdkCtrl.m_VerifyPhoneUid or "",
			role_id = g_AttrCtrl.pid,
			udid = Utils.GetDeviceUID(),
			server = oCurServer and oCurServer.id or "",
			version = string.format("%s.%s.%s", framever2, gamever2, resver2),
			app_channel = g_SdkCtrl.m_DemiChannelID or "",
			sub_channel = g_SdkCtrl:GetSubChannelId() or "",
			platform = g_LoginPhoneCtrl:GetPlatform(),
			device_model = Utils.GetDeviceModel(),
			os = UnityEngine.SystemInfo.operatingSystem,
			is_mmo_player = oSelect,
			-- ip = ,
		}
	}
	g_UploadDataCtrl:PostServerDotList(needData)
end

return CUploadDataCtrl
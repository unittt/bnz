module(..., package.seeall)

--GS2C--

function GS2CRefreshWingInfo(pbdata)
	local info = pbdata.info --羽翼相关信息
	--todo
	info = g_NetCtrl:DecodeMaskData(info, "Wing")
	g_WingCtrl:GS2CRefreshWingInfo(info)
end

function GS2CLoginWing(pbdata)
	local info = pbdata.info --羽翼相关信息
	local has_open = pbdata.has_open --曾经打开过界面(1.表示打开过)
	--todo
	info = g_NetCtrl:DecodeMaskData(info, "Wing")
	g_WingCtrl:GS2CLoginWing(info)
	g_WingCtrl:SetShowMainBtn(has_open)
end

function GS2CRefreshOneTimeWing(pbdata)
	local info = pbdata.info
	--todo
	g_WingCtrl:GS2CRefreshOneTimeWing(info)
end


--C2GS--

function C2GSWingWield()
	local t = {
	}
	g_NetCtrl:Send("wing", "C2GSWingWield", t)
end

function C2GSWingUpStar(goldcoin)
	local t = {
		goldcoin = goldcoin,
	}
	g_NetCtrl:Send("wing", "C2GSWingUpStar", t)
end

function C2GSWingUpLevel(goldcoin)
	local t = {
		goldcoin = goldcoin,
	}
	g_NetCtrl:Send("wing", "C2GSWingUpLevel", t)
end

function C2GSActiveWing(wing_id)
	local t = {
		wing_id = wing_id,
	}
	g_NetCtrl:Send("wing", "C2GSActiveWing", t)
end

function C2GSAddWingTime(wing_id, time)
	local t = {
		wing_id = wing_id,
		time = time,
	}
	g_NetCtrl:Send("wing", "C2GSAddWingTime", t)
end

function C2GSSetShowWing(wing_id)
	local t = {
		wing_id = wing_id,
	}
	g_NetCtrl:Send("wing", "C2GSSetShowWing", t)
end

function C2GSOpenWingUI()
	local t = {
	}
	g_NetCtrl:Send("wing", "C2GSOpenWingUI", t)
end


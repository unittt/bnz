module(..., package.seeall)

--GS2C--

function GS2CMarryPayUI(pbdata)
	local seconds = pbdata.seconds
	local status = pbdata.status --0 未付费状态 1 付一半费 2 付全部费
	--todo
	g_MarryCtrl:GS2CMarryPayUI(pbdata)
end

function GS2CMarryCancel(pbdata)
	--todo
	g_MarryCtrl:GS2CMarryCancel(pbdata)
end

function GS2CSuccessDivorce(pbdata)
	--todo
	g_MarryCtrl:GS2CSuccessDivorce(pbdata)
end

function GS2CPickItemXT(pbdata)
	--todo
	g_MarryCtrl:GS2CPickItemXT(pbdata)
end

function GS2CMarryWedding(pbdata)
	local marry_no = pbdata.marry_no --结婚编号
	local player1 = pbdata.player1
	local player2 = pbdata.player2
	local marry_type = pbdata.marry_type --结婚类型
	local wedding_time = pbdata.wedding_time --婚礼开始时间
	local wedding_sec = pbdata.wedding_sec --婚礼持续时间
	--todo
	g_MarryCtrl:GS2CMarryWedding(pbdata)
end

function GS2CMarryWeddingEnd(pbdata)
	local marry_no = pbdata.marry_no --结婚编号
	--todo
	g_MarryCtrl:GS2CMarryWeddingEnd(pbdata)
end

function GS2CTeamShowWedding(pbdata)
	--todo
	g_MarryCtrl:GS2CTeamShowWedding()
end

function GS2CMarryConfirmUI(pbdata)
	local seconds = pbdata.seconds
	local status = pbdata.status --1 付一半费 2 付全部费
	--todo
	g_MarryCtrl:GS2CMarryConfirmUI(pbdata)
end


--C2GS--

function C2GSMarryPay(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("marry", "C2GSMarryPay", t)
end

function C2GSCancelMarry()
	local t = {
	}
	g_NetCtrl:Send("marry", "C2GSCancelMarry", t)
end

function C2GSSetMarryPic(url)
	local t = {
		url = url,
	}
	g_NetCtrl:Send("marry", "C2GSSetMarryPic", t)
end

function C2GSPresentXT(targetpid, amount, content)
	local t = {
		targetpid = targetpid,
		amount = amount,
		content = content,
	}
	g_NetCtrl:Send("marry", "C2GSPresentXT", t)
end

function C2GSMarryWeddingEnd()
	local t = {
	}
	g_NetCtrl:Send("marry", "C2GSMarryWeddingEnd", t)
end

function C2GSTeamShowWedding()
	local t = {
	}
	g_NetCtrl:Send("marry", "C2GSTeamShowWedding", t)
end

function C2GSMarryConfirm(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("marry", "C2GSMarryConfirm", t)
end

function C2GSMarryReScene()
	local t = {
	}
	g_NetCtrl:Send("marry", "C2GSMarryReScene", t)
end


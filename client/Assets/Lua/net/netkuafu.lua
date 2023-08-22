module(..., package.seeall)

--GS2C--

function GS2CTryEnterKS(pbdata)
	local host = pbdata.host --跨服服务器IP
	local port = pbdata.port --port
	local errcode = pbdata.errcode --出现的问题错误码 1:KS不能连通
	local pid = pbdata.pid
	local gs_host = pbdata.gs_host
	--todo
	g_KuafuCtrl:GS2CTryEnterKS(pbdata)
end

function GS2CTryBackGS(pbdata)
	local host = pbdata.host --原服务器IP
	--todo
	g_KuafuCtrl:GS2CTryBackGS(pbdata)
end


--C2GS--

function C2GSTryEnterKS(ks, hdname)
	local t = {
		ks = ks,
		hdname = hdname,
	}
	g_NetCtrl:Send("kuafu", "C2GSTryEnterKS", t)
end

function C2GSTryBackGS()
	local t = {
	}
	g_NetCtrl:Send("kuafu", "C2GSTryBackGS", t)
end


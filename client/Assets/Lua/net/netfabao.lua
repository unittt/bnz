module(..., package.seeall)

--GS2C--

function GS2CAddFaBao(pbdata)
	local fabao = pbdata.fabao
	--todo
	g_FaBaoCtrl:GS2CAddFaBao(fabao)
end

function GS2CRemoveFaBao(pbdata)
	local id = pbdata.id
	--todo
	g_FaBaoCtrl:GS2CRemoveFaBao(id)
end

function GS2CRefreshFaBao(pbdata)
	local fabao = pbdata.fabao
	--todo
	g_FaBaoCtrl:GS2CRefreshFaBao(fabao)
end

function GS2CAllFaBao(pbdata)
	local fabaolist = pbdata.fabaolist
	--todo
	g_FaBaoCtrl:GS2CAllFaBao(fabaolist)
end

function GS2CWieldFaBao(pbdata)
	local wield_id = pbdata.wield_id
	local unwield_id = pbdata.unwield_id
	local equippos = pbdata.equippos
	--todo
	g_FaBaoCtrl:GS2CWieldFaBao(pbdata)
end

function GS2CUnWieldFaBao(pbdata)
	local unwield_id = pbdata.unwield_id
	--todo
	g_FaBaoCtrl:GS2CUnWieldFaBao(unwield_id)
end


--C2GS--

function C2GSCombineFaBao(op, fabao)
	local t = {
		op = op,
		fabao = fabao,
	}
	g_NetCtrl:Send("fabao", "C2GSCombineFaBao", t)
end

function C2GSWieldFaBao(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("fabao", "C2GSWieldFaBao", t)
end

function C2GSUnWieldFaBao(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("fabao", "C2GSUnWieldFaBao", t)
end

function C2GSDeComposeFaBao(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("fabao", "C2GSDeComposeFaBao", t)
end

function C2GSUpGradeFaBao(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("fabao", "C2GSUpGradeFaBao", t)
end

function C2GSXianLingFaBao(id, op, attr)
	local t = {
		id = id,
		op = op,
		attr = attr,
	}
	g_NetCtrl:Send("fabao", "C2GSXianLingFaBao", t)
end

function C2GSJueXingFaBao(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("fabao", "C2GSJueXingFaBao", t)
end

function C2GSJueXingUpGradeFaBao(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("fabao", "C2GSJueXingUpGradeFaBao", t)
end

function C2GSJueXingHunFaBao(id, hun)
	local t = {
		id = id,
		hun = hun,
	}
	g_NetCtrl:Send("fabao", "C2GSJueXingHunFaBao", t)
end


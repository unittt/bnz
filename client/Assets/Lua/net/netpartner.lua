module(..., package.seeall)

--GS2C--

function GS2CLoginPartner(pbdata)
	local partners = pbdata.partners
	local lineup = pbdata.lineup --阵容ID
	local pos_list = pbdata.pos_list --阵容站位顺序
	--todo
	local dInfo = {lineup = lineup, pos_list = pos_list, fmt_id = 1}
	g_PartnerCtrl:GS2CLoginPartner(partners)
	g_PartnerCtrl:SetCurLineup(lineup)
	g_PartnerCtrl:SetLineupInfo(dInfo)
end

function GS2CPartnerPropChange(pbdata)
	local partnerid = pbdata.partnerid
	local partner = pbdata.partner
	--todo
	local partnerProp = {}
	if partner then
		local dDecode = g_NetCtrl:DecodeMaskData(partner, "partner")
		table.update(partnerProp, dDecode)
	end
	g_PartnerCtrl:GS2CPartnerPropChange(partnerid, partnerProp)
end

function GS2CAddPartner(pbdata)
	local partner = pbdata.partner
	--todo
	g_PartnerCtrl:GS2CAddPartner(partner)
	g_PromoteCtrl:UpdatePromoteData(8)
end

function GS2CAllLineupInfo(pbdata)
	local curr_lineup = pbdata.curr_lineup --当前出战的阵容
	local info = pbdata.info
	--todo
	g_PartnerCtrl:GS2CAllLineupInfo(curr_lineup, info)
end

function GS2CSingleLineupInfo(pbdata)
	local curr_lineup = pbdata.curr_lineup
	local info = pbdata.info
	--todo
	g_PartnerCtrl:GS2CSingleLineupInfo(info)
end

function GS2CSetCurrLineup(pbdata)
	local lineup = pbdata.lineup
	--todo
	g_PartnerCtrl:SetCurLineup(lineup)
end


--C2GS--

function C2GSRecruit(sid, flag)
	local t = {
		sid = sid,
		flag = flag,
	}
	g_NetCtrl:Send("partner", "C2GSRecruit", t)
end

function C2GSUpgradeQuality(partnerid, flag)
	local t = {
		partnerid = partnerid,
		flag = flag,
	}
	g_NetCtrl:Send("partner", "C2GSUpgradeQuality", t)
end

function C2GSUpperGradeLimit(partnerid)
	local t = {
		partnerid = partnerid,
	}
	g_NetCtrl:Send("partner", "C2GSUpperGradeLimit", t)
end

function C2GSUseUpgradeProp(partnerid, itemid)
	local t = {
		partnerid = partnerid,
		itemid = itemid,
	}
	g_NetCtrl:Send("partner", "C2GSUseUpgradeProp", t)
end

function C2GSUpgradeSkill(partnerid, skid, flag)
	local t = {
		partnerid = partnerid,
		skid = skid,
		flag = flag,
	}
	g_NetCtrl:Send("partner", "C2GSUpgradeSkill", t)
end

function C2GSWieldEquip(partnerid, itemid)
	local t = {
		partnerid = partnerid,
		itemid = itemid,
	}
	g_NetCtrl:Send("partner", "C2GSWieldEquip", t)
end

function C2GSSetPartnerPosInfo(lineup, fmt_id, pos_list)
	local t = {
		lineup = lineup,
		fmt_id = fmt_id,
		pos_list = pos_list,
	}
	g_NetCtrl:Send("partner", "C2GSSetPartnerPosInfo", t)
end

function C2GSGetAllLineupInfo()
	local t = {
	}
	g_NetCtrl:Send("partner", "C2GSGetAllLineupInfo", t)
end

function C2GSSetCurrLineup(lineup)
	local t = {
		lineup = lineup,
	}
	g_NetCtrl:Send("partner", "C2GSSetCurrLineup", t)
end

function C2GSSwapProtectSkill(partner_id, skill_old, skill_new)
	local t = {
		partner_id = partner_id,
		skill_old = skill_old,
		skill_new = skill_new,
	}
	g_NetCtrl:Send("partner", "C2GSSwapProtectSkill", t)
end

function C2GSUpgradePartnerEquip(partner_id, equip_sid, goldcoin)
	local t = {
		partner_id = partner_id,
		equip_sid = equip_sid,
		goldcoin = goldcoin,
	}
	g_NetCtrl:Send("partner", "C2GSUpgradePartnerEquip", t)
end

function C2GSStrengthPartnerEquip(partner_id, equip_sid, quick)
	local t = {
		partner_id = partner_id,
		equip_sid = equip_sid,
		quick = quick,
	}
	g_NetCtrl:Send("partner", "C2GSStrengthPartnerEquip", t)
end


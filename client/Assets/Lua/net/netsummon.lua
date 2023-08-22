module(..., package.seeall)

--GS2C--

function GS2CLoginSummon(pbdata)
	local summondata = pbdata.summondata
	local extsize = pbdata.extsize --拓展格子数量
	local fightid = pbdata.fightid --参战宠物id
	local wash_cnt = pbdata.wash_cnt --洗练次数
	--todo
	g_SummonCtrl:SetInitPropertyInfo(summondata,fightid,extsize)
	g_WarCtrl:FightSummonChange()
	g_TaskCtrl:CheckFindSummon()
	g_PromoteCtrl:UpdatePromoteData(4)
	g_GuideCtrl:OnTriggerAll()
end

function GS2CAddSummon(pbdata)
	local summondata = pbdata.summondata
	--todo
	g_SummonCtrl:AddSummon(summondata)
	g_TaskCtrl:CheckFindSummon()
	g_PromoteCtrl:UpdatePromoteData(4)

	if summondata.type ~= 1 then
		g_SummonCtrl.m_IsHasNewSummon = true
		g_PromoteCtrl:UpdatePromoteData(10)
	end
	g_GuideCtrl:OnTriggerAll()
end

function GS2CDelSummon(pbdata)
	local id = pbdata.id
	local newid = pbdata.newid --洗宠时这个发新宠id，正常删除为0
	--todo
	g_SummonCtrl:GS2CDelSummon(id,newid)
	g_TaskCtrl:CheckFindSummon()
	g_PromoteCtrl:UpdatePromoteData(4)
	g_GuideCtrl:OnTriggerAll()
end

function GS2CSummonPropChange(pbdata)
	local id = pbdata.id
	local summondata = pbdata.summondata
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(summondata,"summon")
	g_SummonCtrl:UpdateMaskInfo(dDecode,id)
	g_TaskCtrl:CheckFindSummon()
	g_PromoteCtrl:UpdatePromoteData(4)
end

function GS2CSummonSetFight(pbdata)
	local id = pbdata.id --参战id，无参战发0
	--todo
	g_SummonCtrl:SetFightid(id)
	g_TaskCtrl:CheckFindSummon()
	g_WarCtrl:FightSummonChange()
	g_PromoteCtrl:UpdatePromoteData(4)
end

function GS2CSummonAutoAssignScheme(pbdata)
	local id = pbdata.id
	local switch = pbdata.switch --1.开，0.关
	local scheme = pbdata.scheme --自动加点方案
	--todo
	g_SummonCtrl:GS2CSummonAutoAssignScheme(id,switch,scheme)
	g_PromoteCtrl:UpdatePromoteData(4)
end

function GS2CWashSummonUI(pbdata)
	--todo
end

function GS2CSummonCombineResult(pbdata)
	local id1 = pbdata.id1
	local id2 = pbdata.id2
	local resultid = pbdata.resultid
	--todo
	g_SummonCtrl:ReceiveCombineSummon(id1,id2,resultid)
end

function GS2CSummonFollow(pbdata)
	local id = pbdata.id --跟随宠物的id，没有跟随发0
	--todo
	g_SummonCtrl:ReceiveFollowId(id)
	g_TaskCtrl:CheckFindSummon()
end

function GS2CSummonInitAttrInfo(pbdata)
	local id = pbdata.id
	local initaddattr = pbdata.initaddattr --初始分配属性点
	--todo
	g_SummonCtrl:GS2CSummonInitAttrInfo(id,initaddattr)	
	g_PromoteCtrl:UpdatePromoteData(4)
end

function GS2CSummonRanse(pbdata)
	local summid = pbdata.summid
	local color = pbdata.color
	--todo
end

function GS2CSummonExtendSize(pbdata)
	local extsize = pbdata.extsize
	--todo
	g_SummonCtrl:GS2CSummonExtendSize(extsize)
end

function GS2CSummonCkExtendSize(pbdata)
	local extcksize = pbdata.extcksize
	--todo
	g_SummonCtrl:GS2CSummonCkExtendSize(extcksize)
end

function GS2CLoginCkSummon(pbdata)
	local summondata = pbdata.summondata
	local extsize = pbdata.extsize --拓展格子数量
	--todo
	g_SummonCtrl:GS2CLoginCkSummon(summondata, extsize)
end

function GS2CAddCkSummon(pbdata)
	local summondata = pbdata.summondata
	--todo
	g_SummonCtrl:GS2CAddCkSummon(summondata)
end

function GS2CDelCkSummon(pbdata)
	local id = pbdata.id
	--todo
	g_SummonCtrl:GS2CDelCkSummon(id)
end

function GS2CSummonWashTips(pbdata)
	local summid = pbdata.summid
	--todo
	g_SummonCtrl:GS2CSummonWashTips(summid)
end


--C2GS--

function C2GSWashSummon(summid, flag)
	local t = {
		summid = summid,
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSWashSummon", t)
end

function C2GSStickSkill(summid, itemid)
	local t = {
		summid = summid,
		itemid = itemid,
	}
	g_NetCtrl:Send("summon", "C2GSStickSkill", t)
end

function C2GSFastStickSkill(summid, booksid)
	local t = {
		summid = summid,
		booksid = booksid,
	}
	g_NetCtrl:Send("summon", "C2GSFastStickSkill", t)
end

function C2GSSummonSkillLevelUp(summid, skid)
	local t = {
		summid = summid,
		skid = skid,
	}
	g_NetCtrl:Send("summon", "C2GSSummonSkillLevelUp", t)
end

function C2GSSummonChangeName(summid, name)
	local t = {
		summid = summid,
		name = name,
	}
	g_NetCtrl:Send("summon", "C2GSSummonChangeName", t)
end

function C2GSSummonSetFight(summid, fight)
	local t = {
		summid = summid,
		fight = fight,
	}
	g_NetCtrl:Send("summon", "C2GSSummonSetFight", t)
end

function C2GSReleaseSummon(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSReleaseSummon", t)
end

function C2GSSummonAssignPoint(summid, scheme)
	local t = {
		summid = summid,
		scheme = scheme,
	}
	g_NetCtrl:Send("summon", "C2GSSummonAssignPoint", t)
end

function C2GSSummonAutoAssignScheme(summid, scheme)
	local t = {
		summid = summid,
		scheme = scheme,
	}
	g_NetCtrl:Send("summon", "C2GSSummonAutoAssignScheme", t)
end

function C2GSSummonOpenAutoAssign(summid, flag)
	local t = {
		summid = summid,
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSSummonOpenAutoAssign", t)
end

function C2GSSummonRequestAuto(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSSummonRequestAuto", t)
end

function C2GSBuySummon(typeid)
	local t = {
		typeid = typeid,
	}
	g_NetCtrl:Send("summon", "C2GSBuySummon", t)
end

function C2GSCombineSummon(summid1, summid2, flag)
	local t = {
		summid1 = summid1,
		summid2 = summid2,
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSCombineSummon", t)
end

function C2GSSummonFollow(summid, flag)
	local t = {
		summid = summid,
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSSummonFollow", t)
end

function C2GSUseSummonExpBook(summid, cnt, sid)
	local t = {
		summid = summid,
		cnt = cnt,
		sid = sid,
	}
	g_NetCtrl:Send("summon", "C2GSUseSummonExpBook", t)
end

function C2GSUseAptitudePellet(summid, aptitude, flag)
	local t = {
		summid = summid,
		aptitude = aptitude,
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSUseAptitudePellet", t)
end

function C2GSUseGrowPellet(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSUseGrowPellet", t)
end

function C2GSUsePointPellet(summid, attr)
	local t = {
		summid = summid,
		attr = attr,
	}
	g_NetCtrl:Send("summon", "C2GSUsePointPellet", t)
end

function C2GSUseLifePellet(summid, cnt, itemid)
	local t = {
		summid = summid,
		cnt = cnt,
		itemid = itemid,
	}
	g_NetCtrl:Send("summon", "C2GSUseLifePellet", t)
end

function C2GSSummonRestPointUI(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSSummonRestPointUI", t)
end

function C2GSExchangeSummon(sid)
	local t = {
		sid = sid,
	}
	g_NetCtrl:Send("summon", "C2GSExchangeSummon", t)
end

function C2GSGetSummonRanse(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSGetSummonRanse", t)
end

function C2GSSummonRanse(summid, color, flag)
	local t = {
		summid = summid,
		color = color,
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSSummonRanse", t)
end

function C2GSCombineSummonLead(summid1, summid2)
	local t = {
		summid1 = summid1,
		summid2 = summid2,
	}
	g_NetCtrl:Send("summon", "C2GSCombineSummonLead", t)
end

function C2GSSummonBindSKill(summid, skid, flag)
	local t = {
		summid = summid,
		skid = skid,
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSSummonBindSKill", t)
end

function C2GSExtendSummonSize(flag)
	local t = {
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSExtendSummonSize", t)
end

function C2GSExtendSummonCkSize()
	local t = {
	}
	g_NetCtrl:Send("summon", "C2GSExtendSummonCkSize", t)
end

function C2GSShenShouExchange(targetsid, summid1, summid2, flag)
	local t = {
		targetsid = targetsid,
		summid1 = summid1,
		summid2 = summid2,
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSShenShouExchange", t)
end

function C2GSEquipSummon(summid, equipid)
	local t = {
		summid = summid,
		equipid = equipid,
	}
	g_NetCtrl:Send("summon", "C2GSEquipSummon", t)
end

function C2GSAddCkSummon(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSAddCkSummon", t)
end

function C2GSChangeCkSummon(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSChangeCkSummon", t)
end

function C2GSSummonAdvance(summid, flag)
	local t = {
		summid = summid,
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSSummonAdvance", t)
end


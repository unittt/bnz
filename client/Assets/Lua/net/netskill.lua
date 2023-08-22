module(..., package.seeall)

--GS2C--

function GS2CLoginSkill(pbdata)
	local active_skill = pbdata.active_skill --门派主动技能
	local passive_skill = pbdata.passive_skill --门派被动技能
	--todo
	g_SkillCtrl:LoginSchoolSkill(pbdata)
	g_PromoteCtrl:UpdatePromoteData(1)
	g_PromoteCtrl:UpdatePromoteData(2)

end

function GS2CRefreshSkill(pbdata)
	local skill_info = pbdata.skill_info
	--todo
	g_SkillCtrl:RefreshSchoolSkill(skill_info)
	g_PromoteCtrl:UpdatePromoteData(1)
	g_PromoteCtrl:UpdatePromoteData(2)
end

function GS2CAllCultivateSkill(pbdata)
	local role_sk = pbdata.role_sk --已选玩家技能编号
	local partner_sk = pbdata.partner_sk --已选伙伴技能编号
	local skill_info = pbdata.skill_info --修炼技能信息
	local upperlevel = pbdata.upperlevel --可修炼等级上限
	local limit = pbdata.limit --修炼等级限制条件 0 等级 1 帮贡
	local item_useinfo = pbdata.item_useinfo --物品还可使用个数
	--todo
	g_SkillCtrl:RefreshCultivateSkillList(pbdata)
	g_PromoteCtrl:UpdatePromoteData(11)
	g_SkillCtrl:RefreshItemUseInfo(item_useinfo)
end

function GS2CRefreshCultivateSkill(pbdata)
	local skill_info = pbdata.skill_info
	local upperlevel = pbdata.upperlevel --可修炼等级上限
	local limit = pbdata.limit --修炼等级限制条件 0 等级 1 帮贡
	local item_useinfo = pbdata.item_useinfo --刷新仙灵丹或炼体丹的继续可用个数
	--todo
	g_SkillCtrl:RefreshItemUseInfo(item_useinfo)
	g_SkillCtrl:RefreshCultivateSkill(skill_info, upperlevel, limit)
	g_PromoteCtrl:UpdatePromoteData(11)
end

function GS2CSetCultivateSkill(pbdata)
	local sk = pbdata.sk
	--todo
	g_SkillCtrl:SetSelectedCultivateSkill(sk)
	g_PromoteCtrl:UpdatePromoteData(11)
end

function GS2CRefreshSkillMaxLevel(pbdata)
	local upperlevel = pbdata.upperlevel --可修炼等级上限
	local limit = pbdata.limit --修炼等级限制条件 0 等级 1 帮贡
	--todo
	g_SkillCtrl:RefreshSkillMaxLevel(upperlevel, limit)
	g_PromoteCtrl:UpdatePromoteData(11)
end

function GS2COrgSkills(pbdata)
	local org_skill = pbdata.org_skill
	--todo
	printc("更新技能")
	g_AttrCtrl:GS2COrgSkills(org_skill)
end

function GS2CUseOrgSkill(pbdata)
	local infos = pbdata.infos
	--todo
	g_AttrCtrl:GS2CUseOrgSkill(infos)
end

function GS2CAllFuZhuanSkill(pbdata)
	local skill_list = pbdata.skill_list
	--todo
	g_SkillCtrl:GS2CAllFuZhuanSkill(pbdata)
end

function GS2CRefreshFuZhuanSkill(pbdata)
	local sk = pbdata.sk
	local level = pbdata.level
	--todo
	g_SkillCtrl:GS2CRefreshFuZhuanSkill(pbdata)
end

function GS2CMarrySkill(pbdata)
	local skill_list = pbdata.skill_list
	--todo
	g_SkillCtrl:GS2CMarrySkill(skill_list)
end


--C2GS--

function C2GSLearnSkill(type, sk, flag)
	local t = {
		type = type,
		sk = sk,
		flag = flag,
	}
	g_NetCtrl:Send("skill", "C2GSLearnSkill", t)
end

function C2GSFastLearnSkill(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("skill", "C2GSFastLearnSkill", t)
end

function C2GSResetActiveSchool(sk)
	local t = {
		sk = sk,
	}
	g_NetCtrl:Send("skill", "C2GSResetActiveSchool", t)
end

function C2GSLearnCultivateSkill(type, sk)
	local t = {
		type = type,
		sk = sk,
	}
	g_NetCtrl:Send("skill", "C2GSLearnCultivateSkill", t)
end

function C2GSSetCultivateSkill(sk)
	local t = {
		sk = sk,
	}
	g_NetCtrl:Send("skill", "C2GSSetCultivateSkill", t)
end

function C2GSLearnOrgSkill(sk)
	local t = {
		sk = sk,
	}
	g_NetCtrl:Send("skill", "C2GSLearnOrgSkill", t)
end

function C2GSUseOrgSkill(sk, args)
	local t = {
		sk = sk,
		args = args,
	}
	g_NetCtrl:Send("skill", "C2GSUseOrgSkill", t)
end

function C2GSLearnFuZhuanSkill(sk)
	local t = {
		sk = sk,
	}
	g_NetCtrl:Send("skill", "C2GSLearnFuZhuanSkill", t)
end

function C2GSResetFuZhuanSkill(sk)
	local t = {
		sk = sk,
	}
	g_NetCtrl:Send("skill", "C2GSResetFuZhuanSkill", t)
end

function C2GSProductFuZhuanSkill(sk)
	local t = {
		sk = sk,
	}
	g_NetCtrl:Send("skill", "C2GSProductFuZhuanSkill", t)
end

function C2GSEnergyExchangeSilver()
	local t = {
	}
	g_NetCtrl:Send("skill", "C2GSEnergyExchangeSilver", t)
end


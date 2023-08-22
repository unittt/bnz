local CArtifactCtrl = class("CArtifactCtrl", CCtrlBase)

function CArtifactCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:CheckStrengthLimitConfig()
	self:CheckShenqiModelConfig()
	self:GetAllQiLingSkillList()
	self:Clear()
end

function CArtifactCtrl.Clear(self)
	self.m_ArtifactId = 0
	self.m_ArtifactExp = 0
	self.m_ArtifactGrade = 0
	self.m_ArtifactStrengthLv = 0
	self.m_ArtifactStrengthExp = 0
	self.m_ArtifactAttrList = {max_hp = 0, max_mp = 0, phy_attack = 0, phy_defense = 0, mag_attack = 0, mag_defense = 0, cure_power = 0,
	speed = 0, seal_ratio = 0, res_seal_ratio = 0, phy_critical_ratio = 0, res_phy_critical_ratio = 0, mag_critical_ratio = 0, res_mag_critical_ratio = 0, phy_damage_add = 0, mag_damage_add = 0}
	self.m_ArtifactAttrOrderList = {"max_hp", "max_mp", "phy_attack", "phy_defense", "mag_attack", "mag_defense", "cure_power",
	"speed", "seal_ratio", "res_seal_ratio", "phy_damage_add", "mag_damage_add"}--"phy_critical_ratio", "res_phy_critical_ratio", "mag_critical_ratio", "res_mag_critical_ratio"}
	self.m_ArtifactScore = 0
	self.m_ArtifactFightSpiritId = 0
	self.m_ArtifactFollowSpiritId = 0
	self.m_ArtifactSpiritList = {}
	self.m_ArtifactSpiritHashList = {}
	self.m_HasAwakeList = {}
	self.m_HasAwakeHashList = {}
	self.m_NotAwakeList = {}
	self.m_NotAwakeHashList = {}
end

function CArtifactCtrl.GS2COpenArtifactUI(self, pbdata)
	self:CheckArtifactData(pbdata)
	self:OnEvent(define.Artifact.Event.UpdateArtifactInfo)
end

function CArtifactCtrl.GS2CRefreshArtifactInfo(self, pbdata)
	self:CheckArtifactData(pbdata)
	self:OnEvent(define.Artifact.Event.UpdateArtifactInfo)
end

function CArtifactCtrl.CheckArtifactData(self, pbdata)
	if pbdata.id then
		self.m_ArtifactId = pbdata.id
	end
	if pbdata.exp then
		self.m_ArtifactExp = pbdata.exp
	end
	if pbdata.grade then
		self.m_ArtifactGrade = pbdata.grade
	end
	if pbdata.strength_lv then
		self.m_ArtifactStrengthLv = pbdata.strength_lv
	end
	if pbdata.strength_exp then
		self.m_ArtifactStrengthExp = pbdata.strength_exp
	end
	if pbdata.phy_attack then
		self.m_ArtifactAttrList.phy_attack = pbdata.phy_attack
	end
	if pbdata.phy_defense then
		self.m_ArtifactAttrList.phy_defense = pbdata.phy_defense
	end
	if pbdata.mag_attack then
		self.m_ArtifactAttrList.mag_attack = pbdata.mag_attack
	end
	if pbdata.mag_defense then
		self.m_ArtifactAttrList.mag_defense = pbdata.mag_defense
	end
	if pbdata.cure_power then
		self.m_ArtifactAttrList.cure_power = pbdata.cure_power
	end
	if pbdata.speed then
		self.m_ArtifactAttrList.speed = pbdata.speed
	end
	if pbdata.seal_ratio then
		self.m_ArtifactAttrList.seal_ratio = pbdata.seal_ratio
	end
	if pbdata.res_seal_ratio then
		self.m_ArtifactAttrList.res_seal_ratio = pbdata.res_seal_ratio
	end
	if pbdata.phy_critical_ratio then
		self.m_ArtifactAttrList.phy_critical_ratio = pbdata.phy_critical_ratio
	end
	if pbdata.res_phy_critical_ratio then
		self.m_ArtifactAttrList.res_phy_critical_ratio = pbdata.res_phy_critical_ratio
	end
	if pbdata.mag_critical_ratio then
		self.m_ArtifactAttrList.mag_critical_ratio = pbdata.mag_critical_ratio
	end
	if pbdata.res_mag_critical_ratio then
		self.m_ArtifactAttrList.res_mag_critical_ratio = pbdata.res_mag_critical_ratio
	end
	if pbdata.max_hp then
		self.m_ArtifactAttrList.max_hp = pbdata.max_hp
	end
	if pbdata.max_mp then
		self.m_ArtifactAttrList.max_mp = pbdata.max_mp
	end
	if pbdata.score then
		self.m_ArtifactScore = pbdata.score
	end
	if pbdata.fight_spirit then
		self.m_ArtifactFightSpiritId = pbdata.fight_spirit
	end
	if pbdata.follow_spirit then
		self.m_ArtifactFollowSpiritId = pbdata.follow_spirit
	end
	if pbdata.spirit_list then
		self.m_ArtifactSpiritList = {}
		self.m_ArtifactSpiritHashList = {}
		for k,v in pairs(pbdata.spirit_list) do
			self.m_ArtifactSpiritList[k] = v
			self.m_ArtifactSpiritHashList[v.spirit_id] = v
		end
		table.sort(self.m_ArtifactSpiritList, function (a, b)
			return a.spirit_id < b.spirit_id
		end)
		self:GetHasAndNotAwakeList()
	end
	if pbdata.phy_damage_add then
		self.m_ArtifactAttrList.phy_damage_add = pbdata.phy_damage_add
	end
	if pbdata.mag_damage_add then
		self.m_ArtifactAttrList.mag_damage_add = pbdata.mag_damage_add
	end
end

function CArtifactCtrl.GS2CRefreshOneSpiritInfo(self, pbdata)
	if self.m_ArtifactSpiritHashList[pbdata.spirit.spirit_id] then
		self.m_ArtifactSpiritHashList[pbdata.spirit.spirit_id] = pbdata.spirit
		for k,v in pairs(self.m_ArtifactSpiritList) do
			if v.spirit_id == pbdata.spirit.spirit_id then
				v.skill_list = pbdata.spirit.skill_list
				v.bak_skill_list = pbdata.spirit.bak_skill_list
				v.attr_list = pbdata.spirit.attr_list
				break
			end
		end
	else
		self.m_ArtifactSpiritHashList[pbdata.spirit.spirit_id] = pbdata.spirit
		table.insert(self.m_ArtifactSpiritList, pbdata.spirit)
		table.sort(self.m_ArtifactSpiritList, function (a, b)
			return a.spirit_id < b.spirit_id
		end)
	end
	self:GetHasAndNotAwakeList()
	self:OnEvent(define.Artifact.Event.UpdateSpiritInfo)
end

function CArtifactCtrl.GetStrengthEffectConfigById(self)
	if self.m_ArtifactId == 0 then
		return
	end
	for k,v in pairs(data.artifactdata.STRENGTHEFFECT) do
		if v.equip_sid == self.m_ArtifactId then
			return v
		end
	end
end

function CArtifactCtrl.CheckStrengthLimitConfig(self)
	self.m_StrengthLimitConfig = {}
	for k,v in pairs(data.artifactdata.STRENGTHLIMIT) do
		table.insert(self.m_StrengthLimitConfig, v)
	end
	table.sort(self.m_StrengthLimitConfig, function (a, b)
		return a.equip_grade < b.equip_grade
	end)
end

function CArtifactCtrl.GetHasAndNotAwakeList(self)
	self.m_HasAwakeList = {}
	self.m_HasAwakeHashList = {}
	self.m_NotAwakeList = {}
	self.m_NotAwakeHashList = {}
	for k,v in ipairs(data.artifactdata.SPIRITINFO) do
		if g_ArtifactCtrl.m_ArtifactSpiritHashList[v.spirit_id] then
			table.insert(self.m_HasAwakeList, v.spirit_id)
			self.m_HasAwakeHashList[v.spirit_id] = true
		else
			table.insert(self.m_NotAwakeList, v.spirit_id)
			self.m_NotAwakeHashList[v.spirit_id] = true
		end
	end
end

function CArtifactCtrl.GetAllQiLingSkillList(self)
	self.m_QiLingSkillConfigList = {}
	for k,v in pairs(data.artifactdata.SKILL) do
		table.insert(self.m_QiLingSkillConfigList, v)
	end
	table.sort(self.m_QiLingSkillConfigList, function (a, b)
		return a.id < b.id
	end)
end

function CArtifactCtrl.GetQiLingAttrConfig(self, oSpiritId)
	local oList = {}
	local oConfig = data.artifactdata.SPIRITATTR[g_AttrCtrl.school]["spirit_"..oSpiritId]
	oConfig = string.gsub(oConfig, "{", "")
	oConfig = string.gsub(oConfig, "}", "")
	local strList = string.split(oConfig, "=,")
	for i=1, #strList, 2 do
		if strList[i] and strList[i+1] then
			table.insert(oList, {attr = strList[i], val = tonumber(strList[i+1])})
		end
	end
	return oList
end

function CArtifactCtrl.GetIsShowRatio(self, oKey)
	return string.find(oKey, "ratio") or oKey == "phy_damage_add" or oKey == "mag_damage_add"
end

function CArtifactCtrl.OnShowArtifactQHView(self)
	if not g_OpenSysCtrl:GetOpenSysState(define.System.Artifact, true) then
		return
	end
	if g_ArtifactCtrl.m_ArtifactGrade < data.artifactdata.CONFIG[1].strength_open_level then
		local oStr = string.gsub(data.artifactdata.TEXT[2001].content, "#level", "#G"..data.artifactdata.CONFIG[1].strength_open_level.."#n")
		g_NotifyCtrl:FloatMsg(oStr)
		return
	end
	CArtifactMainView:ShowView(function (oView)		
		oView:ShowSubPageByIndex(oView:GetPageIndex("qh"))
	end)
end

function CArtifactCtrl.OnShowArtifactQiLingView(self)
	if not g_OpenSysCtrl:GetOpenSysState(define.System.Artifact, true) then
		return
	end
	if g_ArtifactCtrl.m_ArtifactGrade < data.artifactdata.CONFIG[1].spirit_open_level then
		local oStr = string.gsub(data.artifactdata.TEXT[4001].content, "#level", "#G"..data.artifactdata.CONFIG[1].spirit_open_level.."#n")
		g_NotifyCtrl:FloatMsg(oStr)
		return
	end
	CArtifactMainView:ShowView(function (oView)		
		oView:ShowSubPageByIndex(oView:GetPageIndex("Qiling"))
	end)
end

function CArtifactCtrl.CheckShenqiModelConfig(self)
	self.m_ShenqiModelList = {}
	for k,v in pairs(data.artifactdata.EQUIPSCORE) do
		self.m_ShenqiModelList[v.figureid] = true
	end
end

return CArtifactCtrl
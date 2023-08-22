module(..., package.seeall)

--GS2C--

function GS2COpenArtifactUI(pbdata)
	local info = pbdata.info --神器相关信息
	--todo
	local data = g_NetCtrl:DecodeMaskData(pbdata.info, "Artifact")
	g_ArtifactCtrl:GS2COpenArtifactUI(data)
end

function GS2CRefreshArtifactInfo(pbdata)
	local info = pbdata.info --神器相关信息
	--todo
	local data = g_NetCtrl:DecodeMaskData(pbdata.info, "Artifact")
	g_ArtifactCtrl:GS2CRefreshArtifactInfo(data)
end

function GS2CRefreshOneSpiritInfo(pbdata)
	local spirit = pbdata.spirit --器灵信息
	--todo
	g_ArtifactCtrl:GS2CRefreshOneSpiritInfo(pbdata)
end


--C2GS--

function C2GSArtifactOpenUI()
	local t = {
	}
	g_NetCtrl:Send("artifact", "C2GSArtifactOpenUI", t)
end

function C2GSArtifactUpgradeUse(goldcoin)
	local t = {
		goldcoin = goldcoin,
	}
	g_NetCtrl:Send("artifact", "C2GSArtifactUpgradeUse", t)
end

function C2GSArtifactStrength(goldcoin)
	local t = {
		goldcoin = goldcoin,
	}
	g_NetCtrl:Send("artifact", "C2GSArtifactStrength", t)
end

function C2GSArtifactSpiritWakeup(spirit_id, goldcoin)
	local t = {
		spirit_id = spirit_id,
		goldcoin = goldcoin,
	}
	g_NetCtrl:Send("artifact", "C2GSArtifactSpiritWakeup", t)
end

function C2GSArtifactSpiritResetSkill(spirit_id, goldcoin)
	local t = {
		spirit_id = spirit_id,
		goldcoin = goldcoin,
	}
	g_NetCtrl:Send("artifact", "C2GSArtifactSpiritResetSkill", t)
end

function C2GSArtifactSpiritSaveSkill(spirit_id)
	local t = {
		spirit_id = spirit_id,
	}
	g_NetCtrl:Send("artifact", "C2GSArtifactSpiritSaveSkill", t)
end

function C2GSArtifactSetFollowSpirit(spirit_id)
	local t = {
		spirit_id = spirit_id,
	}
	g_NetCtrl:Send("artifact", "C2GSArtifactSetFollowSpirit", t)
end

function C2GSArtifactSetFightSpirit(spirit_id)
	local t = {
		spirit_id = spirit_id,
	}
	g_NetCtrl:Send("artifact", "C2GSArtifactSetFightSpirit", t)
end


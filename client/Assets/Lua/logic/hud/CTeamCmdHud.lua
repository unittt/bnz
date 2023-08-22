local CTeamCmdHud = class("CTeamCmdHud", CAsynHud)

function CTeamCmdHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/TeamCmdHud.prefab", cb)
end

function CTeamCmdHud.OnCreateHud(self)
	self.m_CmdLabel = self:NewUI(1, CLabel)
end

function CTeamCmdHud.SetCmd(self, s)
	self.m_CmdLabel:SetText(s)
end

return CTeamCmdHud
local CNianShouNpc = class("CNianShouNpc", CMapWalker)

function CNianShouNpc.ctor(self)

	CMapWalker.ctor(self)
	self.m_ClientNpc = nil

end

function CNianShouNpc.SetData(self, clientNpc)
	self.m_ClientNpc = clientNpc
end

function CNianShouNpc.Reset(self)
	CMapWalker.Reset(self)
	self.m_ClientNpc = nil
	self.m_WalkerPatrolRadius = nil
end

function CNianShouNpc.OnTouch(self)
	-- TODO >>> 点到DynamicNpc
end

function CNianShouNpc.Trigger(self)
	
	CMapWalker.Trigger(self)
	local npcid = self.m_ClientNpc.npcid

	netnpc.C2GSClickNpc(npcid)
	
	local globalNpc = DataTools.GetGlobalNpc(self.m_ClientNpc.npctype)
	if globalNpc and globalNpc.soundId and string.len(globalNpc.soundId) > 0 then
		local path = DataTools.GetAudioSound(globalNpc.soundId)
		g_AudioCtrl:NpcPath(path)
	end

end

function CNianShouNpc.SetName(self, name, color)

	CMapWalker.SetNpcName(self, name, color, define.RoleColor.DynamicNPC)

end

return CNianShouNpc
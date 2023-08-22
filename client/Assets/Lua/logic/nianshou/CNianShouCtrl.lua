local CNianShouCtrl = class("CNianShouCtrl", CCtrlBase)

function CNianShouCtrl.ctor(self)

	CCtrlBase.ctor(self)

    self.m_NpcList = {}

end

function CNianShouCtrl.GS2CNSGetPlayerNPC(self, npcList)

	for k, v in pairs(npcList) do 
		self.m_NpcList[v.npcid] = v
	end 

    g_MapCtrl:CheckNianShouNpc()
    
end

function CNianShouCtrl.GS2CNSRemovePlayerNPC(self, npcId)

    g_MapCtrl:DelNianShouNpc(npcId)
    self.m_NpcList[npcId] = nil

end

function CNianShouCtrl.GS2CNSYanHua(self, x, y)

    self:AddYanHuaEffect(x, y)

end

function CNianShouCtrl.GetNianShouNpcList(self)
    
    return self.m_NpcList

end

function CNianShouCtrl.WalkToNianShouNpc(self)
	
	nethuodong.C2GSNianShouFindNPC()

end

function CNianShouCtrl.GS2CShowIntruction(self, id)
	
	if data.instructiondata.DESC[id] ~= nil then 
	    local content = {
	        title = data.instructiondata.DESC[id].title,
	        desc  = data.instructiondata.DESC[id].desc
	    }
	    g_WindowTipCtrl:SetWindowInstructionInfo(content)
	end 

end

function CNianShouCtrl.AddYanHuaEffect(self, x, y)
	
	local path = "Effect/Scene/scene_eff_0046/Prefabs/scene_eff_0046.prefab"

	g_MapCtrl:AddYanHuaEffect(path, Vector3.New(x, y, 0))

end

return CNianShouCtrl
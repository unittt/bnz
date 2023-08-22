local CNpc = class("CNpc", CMapWalker)

function CNpc.ctor(self)
	CMapWalker.ctor(self)

	self.m_Eid = nil --场景中唯一的ID
	self.m_NpcAoi = nil
end

function CNpc.Reset(self)
	CMapWalker.Reset(self)
	self.m_Eid = nil
	self.m_NpcAoi = nil
end

function CNpc.ResetPosInfo(self, posInfo)
	self.m_NpcAoi.pos_info = posInfo
end

function CNpc.SetData(self, npcaoi)
	self.m_NpcAoi = npcaoi
	-- self.m_WalkerPatrolRadius = npcaoi.block.patrol_radius
	self.m_WalkerPatrolRadius = npcaoi.block.xunluoid
	local globalNpc = DataTools.GetGlobalNpc(npcaoi.npctype)
	local rotateY = globalNpc and globalNpc.rotateY or 150
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, rotateY, 0))

	self.m_WalkerHeadTalk = ( globalNpc and globalNpc.dialogStrList and next(globalNpc.dialogStrList) ) and true or false
	self.m_WalkerHeadTalkTime = ( globalNpc and globalNpc.dialogtime and globalNpc.dialogtime > 0 ) and globalNpc.dialogtime or 10
end

function CNpc.OnTouch(self)
	-- TODO >>> 点到Npc
end

function CNpc.Trigger(self)
	-- g_TaskCtrl:CheckNpcMark()
	-- local npcMark = g_TaskCtrl:GetNpcAssociatedTaskMark(self.m_NpcAoi.npctype)
	-- printc("CNpc.Trigger", npcMark, " /CTaskCtrl.g_NpcMarkSprName 2:", CTaskCtrl.g_NpcMarkSprName[2])
	-- if npcMark == CTaskCtrl.g_NpcMarkSprName[2] then
	-- 	local pbdata = {model_info = self.m_NpcAoi.block.model_info, name = self.m_NpcAoi.block.name, text = "你还没有完成任务呢，快去吧，我等着你。"}
	-- 	-- g_DialogueCtrl:GS2CNpcSay(pbdata)
	-- 	CDialogueOptionView:ShowView(function ()
	-- 		g_DialogueCtrl:OnEvent(define.Dialogue.Event.InitOption, pbdata)
	-- 	end)
	-- 	return
	-- end
	if not self.m_NpcAoi then
		return
	end
	if g_GuideHelpCtrl.m_GuideInfoInit then
		if not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("hasplay") and not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("notplay") then
			return
		end
	end
	CMapWalker.Trigger(self)
	netnpc.C2GSClickNpc(self.m_NpcAoi.npcid)

	local globalNpc = DataTools.GetGlobalNpc(self.m_NpcAoi.npctype)
	if globalNpc and globalNpc.soundId and string.len(globalNpc.soundId) > 0 then
		local path = DataTools.GetAudioSound(globalNpc.soundId)
		g_AudioCtrl:NpcPath(path)
	end
end

function CNpc.SetName(self, name, color)
	-- local colorinfo = data.namecolordata.DATA[2]
	-- local nameColor = color or ("["..colorinfo.color.."]")
	CMapWalker.SetNpcName(self, name, color, define.RoleColor.SceneNPC)
	-- self, nameColor .. name, colorinfo.style, Color.RGBAToColor(colorinfo.style_color), colorinfo.blod
end

function CNpc.WalkerPatrolNext(self)

	if g_MapCtrl:IsFuyuanNpc(self) or g_MapCtrl:IsLuanShiMoYingNpc(self) then 
		return
	end 

	self.m_WalkerPatrolTime = 8
	local npcTalkConfig = DataTools.GetNpctalkListTalk(self.m_NpcAoi.func_group, self.m_NpcAoi.npctype)
	local isConfig = npcTalkConfig ~= nil
	local ratio = isConfig and npcTalkConfig.showratio*10 or 4

	local function walk()
		local x = self.m_NpcAoi.pos_info.x + self:GetRandomPatrolRadius()
		local y = self.m_NpcAoi.pos_info.y + self:GetRandomPatrolRadius()
		if x ~= self.m_NpcAoi.pos_info.x or y ~= self.m_NpcAoi.pos_info.y then
			self:WalkTo(x, y)
		end
	end
	local function show()
		local showName = isConfig and npcTalkConfig.animname or "show"
		local showTime = ModelTools.GetAnimClipInfo(self.m_Actor:GetShape(), showName).length
		self.m_WalkerPatrolTime = self.m_WalkerPatrolTime - showTime
		local function f()
			-- printc("============ f", g_TimeCtrl:GetTimeS())
			-- self.m_Actor:CrossFade("idleCity", 0.2)
			-- self.m_WalkerPatrolTime = Mathf.Random(5, 8)
		end
		-- printc("============ b", g_TimeCtrl:GetTimeS())
		self.m_Actor:CrossFade(showName, 0.2, 0, 1, f)
		if isConfig and Mathf.Random(0, 10) < ratio then
			local dialogueindex = npcTalkConfig.dialogStrList[Mathf.Random(1, #npcTalkConfig.dialogStrList)]
			self:ChatMsg(data.npcdata.DIALOGUELIST[dialogueindex].desc)
		end
	end

	local isShow = self.m_HasShowClip and Mathf.Random(0, 10) < ratio and not self:IsOnRide()
	if isShow then
		show()
	else
		walk()
	end
end

function CNpc.WalkerHeadTalkNext(self)
	local globalNpc = DataTools.GetGlobalNpc(self.m_NpcAoi.npctype)
	local dialogueStr = globalNpc.dialogStrList[Mathf.Random(1, #globalNpc.dialogStrList)]
	self:ChatMsg(dialogueStr)
end

return CNpc
local CDynamicNpc = class("CDynamicNpc", CMapWalker)

function CDynamicNpc.ctor(self)
	CMapWalker.ctor(self)

	self.m_ClientNpc = nil
end

function CDynamicNpc.SetData(self, clientNpc)
	self.m_ClientNpc = clientNpc
	-- self.m_WalkerPatrolRadius = clientNpc.patrol_radius
	self.m_WalkerPatrolRadius = clientNpc.xunluoid
	local taskNpc = DataTools.GetTaskNpc(clientNpc.npctype)
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, taskNpc.rotateY or 150, 0))

	local tasktype = define.Task.TaskCategory.STORY.NAME
	for k,v in pairs(define.Task.TaskCategory) do
		if v.ID == self.m_ClientNpc.taskbigtype then
			tasktype = v.NAME
			break
		end
	end
	local taskNpcByType = DataTools.GetTaskNpcByTaskType(self.m_ClientNpc.npctype, tasktype)
	self.m_WalkerHeadTalk = ( taskNpcByType and taskNpcByType.dialogStrList and next(taskNpcByType.dialogStrList) ) and true or false
	self.m_WalkerHeadTalkTime = ( taskNpcByType and taskNpcByType.dialogtime and taskNpcByType.dialogtime > 0 ) and taskNpcByType.dialogtime or 10
end

function CDynamicNpc.Reset(self)
	CMapWalker.Reset(self)
	self.m_ClientNpc = nil
	self.m_WalkerPatrolRadius = nil
end

function CDynamicNpc.OnTouch(self)
	-- TODO >>> 点到DynamicNpc
end

function CDynamicNpc.Trigger(self)
	-- g_TaskCtrl:CheckNpcMark()
	-- local npcMark = g_TaskCtrl:GetNpcAssociatedTaskMark(self.m_ClientNpc.npctype)
	-- printc("CDynamicNpc.Trigger", npcMark, " /CTaskCtrl.g_NpcMarkSprName 2:", CTaskCtrl.g_NpcMarkSprName[2])
	-- if npcMark == CTaskCtrl.g_NpcMarkSprName[2] then
	-- 	local pbdata = {model_info = self.m_ClientNpc.model_info, name = self.m_ClientNpc.name, text = "你还没有完成任务呢，快去吧，我等着你。"}
	-- 	-- g_DialogueCtrl:GS2CNpcSay(pbdata)
	-- 	CDialogueOptionView:ShowView(function ()
	-- 		g_DialogueCtrl:OnEvent(define.Dialogue.Event.InitOption, pbdata)
	-- 	end)
	-- 	return
	-- end
	if g_GuideHelpCtrl.m_GuideInfoInit then
		if not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("hasplay") and not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("notplay") then
			return
		end
	end
	
	CMapWalker.Trigger(self)
	local npcid = self.m_ClientNpc.npcid
	local taskList = g_TaskCtrl:GetNpcAssociatedTaskList(npcid)
	if taskList and #taskList > 0 then
		-- 默认直接给他第一个任务的id
		local taskid = taskList[1]:GetSValueByKey("taskid")
		nettask.C2GSTaskEvent(taskid, npcid)
	end
end

function CDynamicNpc.SetName(self, name, color)
	-- local colorinfo = data.namecolordata.DATA[3]
	-- local nameColor = color or ("["..colorinfo.color.."]")
	CMapWalker.SetNpcName(self, name, color, define.RoleColor.DynamicNPC)
end

function CDynamicNpc.WalkerPatrolNext(self)
	self.m_WalkerPatrolTime = 8

	local function walk()
		local x = self.m_ClientNpc.pos_info.x + self:GetRandomPatrolRadius()
		local y = self.m_ClientNpc.pos_info.y + self:GetRandomPatrolRadius()
		self:WalkTo(x, y)
	end
	local function show()
		local showTime = ModelTools.NormalizedToFixed(self.m_Actor:GetShape(), self.m_Actor:GetAnimatorIdx(), "show", 1)
		self.m_WalkerPatrolTime = self.m_WalkerPatrolTime - showTime
		local function f()
			self.m_Actor:CrossFade("idleCity", 0.2)
			self.m_WalkerPatrolTime = self.m_WalkerPatrolTime - Mathf.Random(1, 2)
		end
		self.m_Actor:CrossFade("show", 0.2, 0, 1, f)
	end

	local isShow = self.m_HasShowClip and Mathf.Random(0, 10) < 4
	if isShow then
		show()
	else
		walk()
	end
end

function CDynamicNpc.WalkerHeadTalkNext(self)
	local tasktype = define.Task.TaskCategory.STORY.NAME
	for k,v in pairs(define.Task.TaskCategory) do
		if v.ID == self.m_ClientNpc.taskbigtype then
			tasktype = v.NAME
			break
		end
	end
	local taskNpc = DataTools.GetTaskNpcByTaskType(self.m_ClientNpc.npctype, tasktype)
	local dialogueStr = taskNpc.dialogStrList[Mathf.Random(1, #taskNpc.dialogStrList)]
	self:ChatMsg(dialogueStr)
end

return CDynamicNpc
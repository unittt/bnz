local CDialogueNormalPart = class("CDialogueNormalPart", CPageBase)

function CDialogueNormalPart.ctor(self, obj)
	CPageBase.ctor(self, obj)

	self.m_closeCB = nil
	self.m_DialogData = nil
	self.m_DialogIdx = 1
	self.m_LastShapeID = 0
end

function CDialogueNormalPart.OnInitPage(self)
	self.m_BottomSpr = self:NewUI(1, CTexture)
	self.m_NpcNameSpr = self:NewUI(2, CSprite)
	self.m_NpcNameLabel = self:NewUI(3, CLabel)
	self.m_LeftDialogueMsg = self:NewUI(5, CLabel)
	self.m_RightDialogueMsg = self:NewUI(6, CLabel)
	self.m_ActorTexture = self:NewUI(7, CActorTexture)
	self.m_LeftDialogueMark = self:NewUI(8, CSprite)
	self.m_RightDialogueMark = self:NewUI(9, CSprite)
end

function CDialogueNormalPart.SetContent(self, dialogData, cb)
	self.m_DialogData = dialogData
	self.m_closeCB = cb
	self:SetNextContent()
end

function CDialogueNormalPart.SetNextContent(self)
	local curDialogueInfo = self:GetCurDialogueInfo()
	if curDialogueInfo then
		-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "SetNextContent", "设置对话数据"))
		-- table.print(curDialogueInfo)

		local npcName, shapeID, figureID = self:GetNpcInfoByType(curDialogueInfo)
		local bIsSpecial = define.Dialogue.SpecialShape[shapeID]

		if not self.m_LastShapeID or self.m_LastShapeID ~= shapeID then
			self.m_LastShapeID = shapeID

			local dialogueType = curDialogueInfo.type or 1
			local rotalY = dialogueType == 1 and -30 or 30
			local function loadFinish()
				if Utils.IsNil(self) then
					return
				end
				self.m_BottomSpr:SetActive(true)
				self.m_ActorTexture:SetActive(true)
				self.m_NpcNameSpr:SetActive(true)
				local oActor = self.m_ActorTexture.m_ActorCamera and self.m_ActorTexture.m_ActorCamera:GetActor()
				local oEulerAngle = oActor:GetLocalEulerAngles()
				oActor:SetLocalEulerAngles(Vector3.New(oEulerAngle.x, oEulerAngle.y, oEulerAngle.z-5))
				self.m_MsgLabel = self:SetViewStyle(curDialogueInfo.type, bIsSpecial)
				if self.m_MsgLabel then
					self.m_MsgLabel:SetActive(true)
					self.m_MsgLabel:SetRichText(curDialogueInfo.content or "???未配置数据", nil, nil, true)
					if self.m_MsgLabel:Find("[emoticon]") then
						self.m_MsgLabel:Find("[emoticon]").localPosition = Vector3.New(0, 0, 0)
					end
					if self.m_LeftDialogueMsg:GetInstanceID() == self.m_MsgLabel:GetInstanceID() then
						self.m_LeftDialogueMark:SetActive(true)
						self.m_RightDialogueMark:SetActive(false)
					else
						self.m_LeftDialogueMark:SetActive(false)
						self.m_RightDialogueMark:SetActive(true)
					end
				end
				-- if Utils.IsExist(self.m_ActorTexture) then
				-- 	local oCam = self.m_ActorTexture:GetCamera()
				-- 	if oCam then
				-- 		oCam:PlayerAnimator()
				-- 		end
				-- 	end
				-- end
				if bIsSpecial then
					self.m_ActorTexture.m_ActorCamera:SetOrthographicSize(1.2)
				else
					self.m_ActorTexture.m_ActorCamera:SetOrthographicSize(0.8)
				end
			end
			local modelCofig = ModelTools.GetModelConfig(figureID)
			local iPosY = modelCofig.posy
			if bIsSpecial then
				iPosY = -1.14
			end
				local model_info = {}
				-- if shapeID == g_AttrCtrl.model_info.shape then 
				-- 	model_info = table.copy(g_AttrCtrl.model_info)
				-- 	model_info.horse = nil
				-- 	model_info.shape = shapeID
				-- else
				-- 	model_info.shape = shapeID
				-- end

				if dialogueType == 1 then 
					model_info = table.copy(g_AttrCtrl.model_info)
					model_info.horse = nil
				else
					model_info.figure = figureID
				end 

				model_info.talkState = true
				model_info.horse = nil
				model_info.rendertexSize = 1.2
	    		model_info.pos = Vector3.New(0,iPosY,3)
	    		model_info.rotate = Vector3.New(0, rotalY, 4)
				self.m_ActorTexture:ChangeShape(model_info, loadFinish)
				self.m_ActorTexture:SetActive(false)
				self.m_NpcNameSpr:SetActive(false)
				self.m_BottomSpr:SetActive(false)

		else
			self.m_NpcNameSpr:SetActive(true)
			self.m_BottomSpr:SetActive(true)
			if self.m_MsgLabel then
				self.m_MsgLabel:SetActive(true)
				self.m_MsgLabel:SetRichText(curDialogueInfo.content or "???未配置数据", nil, nil, true)
				if self.m_MsgLabel:Find("[emoticon]") then
					self.m_MsgLabel:Find("[emoticon]").localPosition = Vector3.New(0, 0, 0)
				end
				if self.m_LeftDialogueMsg:GetInstanceID() == self.m_MsgLabel:GetInstanceID() then
					self.m_LeftDialogueMark:SetActive(true)
					self.m_RightDialogueMark:SetActive(false)
				else
					self.m_LeftDialogueMark:SetActive(false)
					self.m_RightDialogueMark:SetActive(true)
				end
			end
		end
		if npcName then
			self.m_NpcNameLabel:SetText(npcName)
		end

		--毫秒单位，要转换为秒
		if curDialogueInfo.timeout > 0 then
			if self.m_NextTimer then
				Utils.DelTimer(self.m_NextTimer)
				self.m_NextTimer = nil
			end
			local function progress()
				if Utils.IsNil(self) then
					return false
				end
				self.m_ParentView:OnClickNext()
				return false
			end
			self.m_NextTimer = Utils.AddTimer(progress, 0, curDialogueInfo.timeout/1000)
		end
	elseif self.m_DialogData.sessionidx then
		if self.m_DialogData.noanswer ~= 1 and self.m_DialogData.sessionidx ~= 0 then
			netother.C2GSCallback(self.m_DialogData.sessionidx)
		end
		if self.m_closeCB then
			self.m_closeCB()
		end
	end
end

function CDialogueNormalPart.GetCurDialogueInfo(self)
	if self.m_DialogData and self.m_DialogData.dialog and #self.m_DialogData.dialog > 0 then
		if self.m_DialogIdx <= #self.m_DialogData.dialog then
			local tCurInfo = self.m_DialogData.dialog[self.m_DialogIdx]
			self.m_DialogIdx = self.m_DialogIdx + 1
			return tCurInfo
		end
	end
end

function CDialogueNormalPart.GetNpcInfoByType(self, curDialogueInfo)
	local dialogueType = curDialogueInfo.type or 1
	local npcName = ""
	local npcShape = 0
	local npcFigure = 0
	--1是自己的对话，2是npc普通对话，3是npc绑定任务的对话
	if dialogueType == 1 then
		npcName = g_AttrCtrl.name or ""
		npcShape = g_AttrCtrl.model_info.shape
		npcFigure = g_AttrCtrl.model_info.figure
	elseif dialogueType == 2 then
		npcName = self.m_DialogData.npc_name or ""
		npcShape = ModelTools.GetModelConfig(self.m_DialogData.model_info.figure).model or 0
		npcFigure = self.m_DialogData.model_info.figure
	elseif dialogueType == 3 then
		local taskNpc = DataTools.GetTaskNpc(curDialogueInfo.preId)
		
		if self.m_DialogData.taskid and self.m_DialogData.taskid ~= 0 and g_TaskCtrl.m_TaskDataDic[self.m_DialogData.taskid] then
			local tasktype
			for k,v in pairs(define.Task.TaskCategory) do
				if v.ID == g_TaskCtrl.m_TaskDataDic[self.m_DialogData.taskid]:GetCValueByKey("type") then
					tasktype = v.NAME
					break
				end
			end
			taskNpc = DataTools.GetTaskNpcByTaskType(curDialogueInfo.preId, tasktype)
		end
		if taskNpc.notNpc then
			taskNpc = DataTools.GetGlobalNpc(curDialogueInfo.preId)
		end
		npcName = taskNpc.name or ""
		local modelInfo = ModelTools.GetModelConfig(taskNpc.figureid)
		npcShape = modelInfo.model
		npcFigure = taskNpc.figureid
	else
		printerror("获取Npc名称错误,没有对应类型的Npc", dialogueType)
	end
	return npcName, npcShape, npcFigure
end

function CDialogueNormalPart.SetViewStyle(self, dialogueType, bIsSpecial)
	-- 设置排版，头像左右放置
	-- 说话类型npc:1,玩家:2,第三人:3
	dialogueType = dialogueType or 1
	if bIsSpecial then
		self.m_ActorTexture:SetLocalScale(Vector3.New(1.5, 1.5, 1))
	else
		self.m_ActorTexture:SetLocalScale(Vector3.New(1, 1, 1))
	end
	if dialogueType == 1 then
		-- self.m_NpcNameLabel:SetLocalPos(Vector3.New(186, 27, 0))
		self.m_BottomSpr:SetFlip(enum.UISprite.Flip.Nothing)
		self.m_NpcNameSpr:SetFlip(enum.UISprite.Flip.Nothing)
		-- self.m_NpcNameSpr:SetPivot(enum.UIWidget.Pivot.BottomLeft)
		UITools.NearTarget(self.m_ParentView.m_Container, self.m_NpcNameSpr, enum.UIAnchor.Side.BottomLeft, Vector2.New(350, 0))

		self.m_ActorTexture:SetPivot(enum.UIWidget.Pivot.BottomLeft)
		UITools.NearTarget(self.m_ParentView.m_Container, self.m_ActorTexture, enum.UIAnchor.Side.BottomLeft)
		if bIsSpecial then
			local width = self.m_ActorTexture:GetWidth()*0.75 - 200
			self.m_ActorTexture:SetLocalPos(self.m_ActorTexture:GetLocalPos() + Vector3.New(-width, 0, 0))
		else
			local width = self.m_ActorTexture:GetWidth()*0.5 - 200
			self.m_ActorTexture:SetLocalPos(self.m_ActorTexture:GetLocalPos() + Vector3.New(-width, 35, 0))
		end
		self.m_LeftDialogueMsg:SetActive(false)
		self.m_RightDialogueMsg:SetActive(false)
		self.m_LeftDialogueMark:SetActive(false)
		self.m_RightDialogueMark:SetActive(false)
		return self.m_RightDialogueMsg
	elseif dialogueType == 2 or dialogueType == 3 then
		-- self.m_NpcNameLabel:SetLocalPos(Vector3.New(-186, 27, 0))
		self.m_BottomSpr:SetFlip(enum.UISprite.Flip.Horizontally)
		self.m_NpcNameSpr:SetFlip(enum.UISprite.Flip.Nothing)
		-- self.m_NpcNameSpr:SetPivot(enum.UIWidget.Pivot.BottomRight)
		UITools.NearTarget(self.m_ParentView.m_Container, self.m_NpcNameSpr, enum.UIAnchor.Side.BottomRight, Vector2.New(-300, 0))

		self.m_ActorTexture:SetPivot(enum.UIWidget.Pivot.BottomRight)
		UITools.NearTarget(self.m_ParentView.m_Container, self.m_ActorTexture, enum.UIAnchor.Side.BottomRight)
		if bIsSpecial then
			local width = self.m_ActorTexture:GetWidth()*0.75 - 200
			self.m_ActorTexture:SetLocalPos(self.m_ActorTexture:GetLocalPos() + Vector3.New(width, 0, 0))
		else
			local width = self.m_ActorTexture:GetWidth()*0.5 - 200
			self.m_ActorTexture:SetLocalPos(self.m_ActorTexture:GetLocalPos() + Vector3.New(width, 35, 0))
		end
		self.m_LeftDialogueMsg:SetActive(false)
		self.m_RightDialogueMsg:SetActive(false)
		self.m_LeftDialogueMark:SetActive(false)
		self.m_RightDialogueMark:SetActive(false)
		return self.m_LeftDialogueMsg
	else
		printerror("获取Npc名称错误,没有对应类型的Npc")
	end
end

return CDialogueNormalPart
local CDialogueMainView = class("CDialogueMainView", CViewBase)

function CDialogueMainView.ctor(self, cb, pPartIndex)
	CViewBase.ctor(self, "UI/Dialogue/DialogueMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CDialogueMainView.OnCreateView(self)
	self.m_CurPart = nil

	self.m_NextMsgBtn = self:NewUI(1, CWidget)
	self.m_NormalPart = self:NewPage(2, CDialogueNormalPart)
	self.m_StoryPart = self:NewPage(3, CDialogueStoryPart)
	self.m_Container = self:NewUI(4, CWidget)
	self.m_MaskSp = self:NewUI(5, CSprite)
	UITools.ResizeToRootSize(self.m_Container)
	UITools.ResizeToRootSize(self.m_NextMsgBtn)
	UITools.ResizeToRootSize(self.m_MaskSp)
	local rootw, rooth = UITools.GetRootSize()
	self.m_NextMsgBtn:GetComponent(classtype.BoxCollider).size = Vector3.New(rootw + 2, rooth + 2, 0)

	g_GuideCtrl:AddGuideUI("dialogue_nextmsg_btn", self.m_NextMsgBtn)

	local oView = CMainMenuView:GetView()
	if oView then
		oView.m_LB:SetActive(false)
	end

	self:InitContent()
	self:ShowSpecificPart()
end

function CDialogueMainView.InitContent(self)
	g_DialogueCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_NextMsgBtn:AddUIEvent("click", callback(self, "OnClickNext"))
end

function CDialogueMainView.LoadDone(self)
	if self.m_OnLoadDoneFunc then
		self.m_OnLoadDoneFunc()
		self.m_OnLoadDoneFunc = nil
	end
end

function CDialogueMainView.ShowSpecificPart(self, partIndex)
	partIndex = partIndex or 1
	self.m_CurPart = self.m_PageList[partIndex]
	self:ShowSubPage(self.m_CurPart)
end

function CDialogueMainView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Dialogue.Event.Dialogue then
		if self.m_CurPart and self.m_CurPart.SetContent then
			self.m_CurPart:SetContent(oCtrl.m_EventData, function ()
				self:CloseView()
			end)
		end
	end
end

function CDialogueMainView.OnClickNext(self)
	if self.m_CurPart and self.m_CurPart.SetNextContent then
		self.m_CurPart:SetNextContent()
	end
end

function CDialogueMainView.OnAutoClick(self, oTime)
	if self.m_AutoClickTimer then
		Utils.DelTimer(self.m_AutoClickTimer)
		self.m_AutoClickTimer = nil			
	end
	
	local function progress()
		if Utils.IsNil(self) then
			return false
		end
		local curDialogueInfo = self.m_CurPart:GetCurDialogueInfo()
		if curDialogueInfo then
			self:OnClickNext()
		else
			self:OnClickNext()
			return false
		end
		return true
	end
	self.m_AutoClickTimer = Utils.AddTimer(progress, 1, oTime)
end

function CDialogueMainView.OnDelayClose(self, oTime)
	if self.m_CloseTimer then
		Utils.DelTimer(self.m_CloseTimer)
		self.m_CloseTimer = nil			
	end
	
	local function progress()
		if Utils.IsNil(self) then
			return false
		end
		self:CloseView()
		return false
	end
	self.m_CloseTimer = Utils.AddTimer(progress, 0, oTime)
end

function CDialogueMainView.CloseView(self)
	self.m_LoadDoneFunc = nil
	local oView = CMainMenuView:GetView()
	if oView then
		oView.m_LB:SetActive(true)
	end
	CViewBase.CloseView(self)
	
	local oWalker = g_MapTouchCtrl.m_LastMapWalker
	if oWalker and Utils.IsExist(oWalker) then
   		oWalker:StartWalkerPatrol()
   		oWalker:StartWalkerHeadTalk()
	end

	if g_TaskCtrl.m_DialogueFindOpCb then
		g_TaskCtrl.m_DialogueFindOpCb()
		g_TaskCtrl.m_DialogueFindOpCb = nil
	end

	g_ViewCtrl:ShowNotGroupOther()
end

function CDialogueMainView.OnHideView(self)
	if Utils.IsNil(self) then
		return
	end
	if self.m_CurPart and self.m_CurPart.m_DialogData and self.m_CurPart.m_DialogData.taskid then
		local oTask = g_TaskCtrl.m_TaskDataDic[self.m_CurPart.m_DialogData.taskid]
		if oTask and oTask:GetCValueByKey("type") == define.Task.TaskCategory.RUNRING.ID then
			local oView = CDialogueMainView:GetView()
			if oView then
				self:CloseView()
			end
		end
	end
end

return CDialogueMainView
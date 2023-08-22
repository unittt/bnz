local CZhenmoPart = class("CZhenmoPart", CPageBase)

function CZhenmoPart.ctor(self, obj)
    CPageBase.ctor(self, obj)
end

function CZhenmoPart.OnInitPage(self)
	self.m_TypeLabel = self:NewUI(1, CLabel)
	self.m_DesLabel = self:NewUI(2, CLabel)
	self.m_MarkSprite = self:NewUI(3, CSprite)
	self.m_TaskBgBtn = self:NewUI(4, CWidget)
	self.m_TaskReward = self:NewUI(5, CSprite)
	self.m_BgSp = self:NewUI(6, CSprite)

	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_TaskBgBtn:AddUIEvent("click", callback(self, "OnTaskBtn"))

	self:ResetStatus()
end

--初始化执行
function CZhenmoPart.ResetStatus(self)
	self.m_TaskData = nil

	self.m_TypeText = ""
	self.m_TargetText = ""
	self.m_MarkFinish = false
	self.m_Effect = nil
	self.m_ItemPre = nil

	self:RefreshTaskBox()
end

function CZhenmoPart.RefreshTaskBox(self)
	local oTask = g_TaskCtrl:GetZhenmoTask()
	if not oTask then
		return
	end

	self.m_TaskData = oTask
	if oTask then
		self.m_TypeText = CTaskHelp.GetTaskTitleDesc(oTask)
		self.m_TargetText = CTaskHelp.GetTargetDesc(oTask)
		self.m_MarkFinish = oTask.m_Finish
		self.m_ItemPre = oTask:GetTaskItemPre()
	end

	self:RefreshTaskUI()
end

function CZhenmoPart.RefreshTaskUI(self)
	self.m_TypeLabel:SetRichText(self.m_TypeText, nil, nil, true)
	self.m_DesLabel:SetRichText(self.m_TargetText, nil, nil, true)

	self.m_MarkSprite:SetActive(self.m_MarkFinish)
	self.m_BgSp:ResetAndUpdateAnchors()
end

function CZhenmoPart.OnTaskBtn(self)
	g_TaskCtrl.m_ExtendTaskWidget = self.m_TaskBgBtn
	if not self.m_TaskData then
		return
	end

	CTaskHelp.ClickTaskLogic(self.m_TaskData)
end

function CZhenmoPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.AddTask then
		self:RefreshTaskBox()
	end
end

return CZhenmoPart
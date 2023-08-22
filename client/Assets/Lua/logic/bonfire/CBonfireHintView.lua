local CBonfireHintView = class("CBonfireHintView", CViewBase)

function CBonfireHintView.ctor(self, cb)
	CViewBase.ctor(self, "UI/bonfire/BonfireHintView.prefab", cb)
	-- self.m_GroupName = "expand"
	-- self.m_ExtendClose = "Black"
    self.m_CurTopicInfo = nil
end

function CBonfireHintView.OnCreateView(self)
	self.m_CancelBtn = self:NewUI(1, CButton)
	self.m_SureBtn = self:NewUI(2, CButton)
    self.m_HintBox = self:NewUI(3, CBox)
    self.m_AnswerTopicBox = self:NewUI(4, CBonfireAnswerTopicBox)
    self:InitContent()
end

function CBonfireHintView.InitContent(self)
    self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_SureBtn:AddUIEvent("click", callback(self, "OnSure"))
    g_BonfireCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))
    self.m_AnswerTopicBox:SetActive(false)
    self.m_HintBox:SetActive(false)
    if g_BonfireCtrl:IsShowAnswerView() then
        self:ShowAnswerTopic()
    end
    if g_BonfireCtrl.m_CurRemainTime == -1 then
        return
    end
    local function update()
		if g_BonfireCtrl.m_CurRemainTime <= 0 then
            self:OnClose()
            self.m_HintBox:SetActive(false)
		    return false
	    end
		self.m_SureBtn:SetText(string.format("前往(%ds)", g_BonfireCtrl.m_CurRemainTime))
		return true
	end
	if self.m_DoneTimer then
		Utils.DelTimer(self.m_DoneTimer)
	end
	self.m_DoneTimer = Utils.AddTimer(update, 1, 0)
end

function CBonfireHintView.OnEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Bonfire.Event.EndBonfireActive then
        self:OnClose()
    end
    if oCtrl.m_EventID == define.Bonfire.Event.UpdateBonfireExp then
       
    end
    if oCtrl.m_EventID == define.Bonfire.Event.SwitchScene then
        if oCtrl.m_EventData == 0 then     
            self.m_AnswerTopicBox:SetActive(false)
        end
    end
    if oCtrl.m_EventID == define.Bonfire.Event.UpdateQuestion then
        self.m_AnswerTopicBox:SetActive(true)
        self.m_CurTopicInfo = oCtrl.m_EventData
        self.m_AnswerTopicBox:SetInfo(oCtrl.m_EventData)
    end
end

function CBonfireHintView.OnSure(self)
    printc("参加")
    if g_AttrCtrl.org_id == 0 then
        g_NotifyCtrl:FloatMsg("您当前没有帮派，快去加入一个帮派吧！")
        self:OnClose()
        g_OrgCtrl:OpenOrgView()
        return
    end
    if g_LimitCtrl:CheckIsLimit(true) then
        self:OnClose()
        return
    end
    if g_LimitCtrl:CheckIsCannotMove() then
        self:OnClose()
        return
    end
    g_OrgCtrl:C2GSEnterOrgScene()
    if self.m_DoneTimer then
		Utils.DelTimer(self.m_DoneTimer)
	end
    local view = CMainMenuView:GetView()
    if view then
        view:JoinBonfire()
    end
    self.m_HintBox:SetActive(false)
end

function CBonfireHintView.ShowAnswerTopic(self)
    if self.m_AnswerTopicBox:GetActive() then
        return
    end
    self.m_AnswerTopicBox:SetActive(true)
    self.m_AnswerTopicBox:SetInfo(g_BonfireCtrl.m_CurTopicInfo)
    self.m_HintBox:SetActive(false)
end

function CBonfireHintView.SetInfo(self, time)
    if g_BonfireCtrl.m_IsBonfireScene == false then
        self.m_HintBox:SetActive(true)
    end
end

function CBonfireHintView.OnClose(self)
    if self.m_DoneTimer then
		Utils.DelTimer(self.m_DoneTimer)
	end
    self.m_AnswerTopicBox:Dispose()
    self:CloseView()
end

return CBonfireHintView

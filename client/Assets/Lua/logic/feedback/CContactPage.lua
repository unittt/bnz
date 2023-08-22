local CContactPage = class("CContactPage", CPageBase)

function CContactPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CContactPage.OnInitPage(self)
	self.EmptySpr = self:NewUI(1, CObject)
	self.m_ContactBtn = self:NewUI(2, CButton)

	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_MsgTable = self:NewUI(4, CTable)
	self.m_MsgBoxLeft = self:NewUI(5, CBox)
	self.m_MsgBoxRight = self:NewUI(6, CBox)
	self.m_WaitBox = self:NewUI(7, CWidget)

	self:InitContent()
end

function CContactPage.InitContent(self)
	self.m_ContactBtn:AddUIEvent("click", callback(self, "OnContact"))
	g_FeedbackCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFeedbackEvent"))

	self:RefreshContactView()
end

function CContactPage.RefreshContactView(self)
	local dInfo = g_FeedbackCtrl:GetFeedbackInfoList()
	local bMsgShow = #dInfo > 0

	self.EmptySpr:SetActive(not bMsgShow)
	if not bMsgShow then
		return
	end

	local height = 0 --记录UITable下元素的总高度按，判断是否需要划动scrollview
	self.m_MsgTable:Clear()
	for i, v in ipairs(dInfo) do
		local oMsgBox = self.m_MsgTable:GetChild(i)
		if oMsgBox == nil then
			oMsgBox = self:CreateMsgBox(v)
			self.m_MsgTable:AddChild(oMsgBox)
		end

		local h = oMsgBox:GetHeight()
		height = height + h 
	end

	local bAnswered = g_FeedbackCtrl:IsAnswered()
	if not bAnswered then
		local oWaitBox = self.m_WaitBox:Clone()
		oWaitBox:SetActive(true)
		self.m_MsgTable:AddChild(oWaitBox)

		local h = oWaitBox:GetHeight()
		height = height + h 
	end
	
	self.m_MsgTable:Reposition()

	if height >= 360 then
		self.m_ScrollView:SetDragAmount(0, 1)
	end

	self.m_ContactBtn:SetGrey(not bAnswered)
end

function CContactPage.CreateMsgBox(self, info)
	local oBox
	if info.tag == 1 then --玩家
		oBox = self.m_MsgBoxLeft:Clone()
	else                  --客服
		oBox = self.m_MsgBoxRight:Clone()
	end

	oBox.m_Icon = oBox:NewUI(1, CSprite)
	oBox.m_MsgContent = oBox:NewUI(2, CLabel)
	oBox.m_TimeL = oBox:NewUI(3, CLabel)
	
	local msg = info.msg
	local icon = g_AttrCtrl.icon
	local timeL = g_FeedbackCtrl:ConvertTimeL(info.time)

	if info.tag == 1 then
		oBox.m_Icon:SpriteAvatar(icon)
		oBox.m_TimeL:SetText(timeL.." 我的反馈")
	else
		oBox.m_TimeL:SetText(timeL.." 客服回复")
	end

	local text = g_MaskWordCtrl:ReplaceMaskWord(msg, true)
	oBox.m_MsgContent:SetText(text)

	oBox:SetActive(true)

	return oBox
end

function CContactPage.OnContact(self)
	local bAnswered = g_FeedbackCtrl:IsAnswered()
	if not bAnswered then
		g_NotifyCtrl:FloatMsg("请等待之前的反馈被回复后再来继续交流吧!")
		return
	end

	CFeedbackCommitView:ShowView()
end

function CContactPage.OnFeedbackEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Feedback.Event.RefreshFeedbackInfo then
		self:RefreshContactView()
	end
end

return CContactPage
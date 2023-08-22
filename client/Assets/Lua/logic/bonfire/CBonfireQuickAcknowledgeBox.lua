local CBonfireQuickAcknowledgeBox = class("CBonfireQuickAcknowledgeBox", CBox)

function CBonfireQuickAcknowledgeBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
    for i=1, 4 do
        self["m_Item"..i] = self:NewUI(i, CButton)
        self["m_Item"..i]:AddUIEvent("click", callback(self, "OnSend", i))
    end
	self.AudioBtn = self:NewUI(5, CButton)
	self.m_CloseBtn = self:NewUI(6, CButton)
    self.AudioBtn:AddUIEvent("press", callback(self, "OnAudioRecord"))
	self.m_CloseBtn:AddUIEvent("click", function ()
		self:SetActive(false)
	end)
    self:InitContent()
end

function CBonfireQuickAcknowledgeBox.InitContent(self)
    
end

function CBonfireQuickAcknowledgeBox.OnSend(self, index)
	g_NotifyCtrl:FloatMsg("发送成功！")
	g_ChatCtrl:SendMsg("对"..self.m_PlayerInfo.fromer_name.."高声喊道："..self["m_Item"..index]:GetText(), define.Channel.Org)
	self:SetActive(false)
	local view = CBonfireGetItemView:GetView()
	if view then
		 view:OnClose()
	end
	self:AddFriend(self.m_PlayerInfo)
	g_BonfireCtrl:C2GSCampfireThankGift(self.m_PlayerInfo.fromer)
end

function CBonfireQuickAcknowledgeBox.SetInfo(self, info, cb)
	self.m_PlayerInfo = info
	self.m_CallBack = cb
end

function CBonfireQuickAcknowledgeBox.OnAudioRecord(self, oBtn, bPress)
    if bPress then
		printc("OnSpeech press true")
		g_ChatCtrl.m_IsChatRecording = true
		self:StartRecord(oBtn)	
	else
		printc("OnSpeech press false")
		g_ChatCtrl.m_IsChatRecording = false
		self:EndRecord()
	end
end

--开始录音
function CBonfireQuickAcknowledgeBox.StartRecord(self, oBtn)
	-- 音量级减小
	g_AudioCtrl:SetSlience()
	CSpeechRecordView:CloseView()
	CSpeechRecordView:ShowView(function(oView)
		oView:SetRecordBtn(oBtn)
		oView:BeginRecord(define.Channel.Org, nil, nil, self, 18)
	end)
end

--结束录音
function CBonfireQuickAcknowledgeBox.EndRecord(self)
	-- 音量恢复
	g_AudioCtrl:ExitSlience()
	local oView = CSpeechRecordView:GetView()
	if oView then
		printc("EndRecord, oView存在")
		if oView:EndRecord(define.Channel.Org, nil, nil) then
			--发送语音后解除锁屏状态
			--self:ShowNewMsg()
		end
	else
		printc("CChatScrollPage.EndRecord, oView不存在")
	end
	self:AddFriend(self.m_PlayerInfo)
	g_BonfireCtrl:C2GSCampfireThankGift(self.m_PlayerInfo.fromer)
	local view = CBonfireGetItemView:GetView()
	if view then
		 view:OnClose()
	end
end

function CBonfireQuickAcknowledgeBox.AddFriend(self, dInfo)
    if not g_FriendCtrl:IsMyFriend(dInfo.fromer) then
        local view = CBonfireAddFriendView:GetView()
        local info = {pid = dInfo.fromer, name = dInfo.fromer_name}
        if view then
            table.insert(g_BonfireCtrl.m_AddFriendList, info)
        else
            CBonfireAddFriendView:ShowView(function (oView)
                oView:SetInfo(info)
            end)
        end
     end
end

return CBonfireQuickAcknowledgeBox
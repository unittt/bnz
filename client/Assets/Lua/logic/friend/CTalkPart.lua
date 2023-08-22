local CTalkPart = class("CTalkPart", CPageBase)

function CTalkPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Input = self:NewUI(1, CChatInput,true,define.Chat.FriendInputArgs)
	self.m_MsgTable = self:NewUI(2, CTable)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_MsgBoxRight = self:NewUI(4, CFriendMsgBox)
	self.m_MsgBoxLeft = self:NewUI(5, CFriendMsgBox)
	self.m_SubmitBtn = self:NewUI(6, CButton)
	self.m_EmojiBtn = self:NewUI(7, CButton)
	self.m_UnReadBox = self:NewUI(8, CBox)
	self.m_AudioBtn = self:NewUI(9, CButton)
	self.m_AddFrdBtn = self:NewUI(10, CButton)
	self.m_DelFrdBtn = self:NewUI(11, CButton)
	self.m_MsgBoxSys = self:NewUI(12, CFriendSysMsgBox)
	self.m_SchoolSpr = self:NewUI(13, CSprite)
	self.m_NameLabel = self:NewUI(14, CLabel)
	self.m_RelationBtn = self:NewUI(15, CButton)
	
	self.m_AudioBoxLeft = self:NewUI(16, CFriendAudioBox)
	self.m_AudioBoxRight = self:NewUI(17, CFriendAudioBox)
	self.m_RelationLabel = self:NewUI(18, CLabel)
	self.m_EmptyGo = self:NewUI(19, CObject)
	self.m_EmptyLbl = self:NewUI(20, CLabel)
	self.m_RelationNameLbl = self:NewUI(21, CLabel)
	self.m_RejectMsgObj = self:NewUI(22, CObject)

	self.m_CurChannel = nil
	self.m_IsLock = false
	self.m_IsTalkEventReceive = false
	self.m_LastReadIndex = 0
	self.m_UnReadCnt = 0
	self.m_AddCnt = 20
	self.m_CurAppendIdx = 0
	self.m_ExtraReceives = {}
	self.m_MsgList = {}
	self.m_DelTalkToTab = 0 --点击删除后切换到哪一个tab，这里是保存状态,0是recent，1是friend
	self.m_Input:SetForbidChars({"{", "}"})
	self:InitContent()
end

--初始化执行
function CTalkPart.InitContent(self)
	self.m_UnReadBox:SetActive(false)
	self.m_MsgBoxLeft:SetActive(false)
	self.m_MsgBoxRight:SetActive(false)
	self.m_MsgBoxSys:SetActive(false)
	self.m_AudioBoxLeft:SetActive(false)
	self.m_AudioBoxRight:SetActive(false)
	
	self.m_Input:AddUIEvent("submit", callback(self, "OnSubmit"))
	self.m_Input:AddUIEvent("select", callback(self, "OnFocusInput"))
	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit"))
	self.m_EmojiBtn:AddUIEvent("click", callback(self, "OnEmoji"))
	self.m_AddFrdBtn:AddUIEvent("click", callback(self, "OnAddFrd"))
	self.m_DelFrdBtn:AddUIEvent("click", callback(self, "OnDelFrd"))
	self.m_AudioBtn:AddUIEvent("press", callback(self, "OnSpeech"))
	self.m_RelationBtn:AddUIEvent("click", callback(self, "OnRelationTips"))
	self.m_ScrollView:SetCullContent(self.m_MsgTable)
	self.m_ScrollView:AddMoveCheck("up", self.m_MsgTable, callback(self, "ShowOldMsg"))
	self.m_ScrollView:AddUIEvent("scrolldragfinished", callback(self, "SetLock"))
	
	self.m_UnReadBox:AddUIEvent("click", callback(self, "ReadAll"))
	self.m_UnReadBox.m_Label = self.m_UnReadBox:NewUI(1, CLabel)
	self.m_UnReadBox.m_ArrowSpr = self.m_UnReadBox:NewUI(2, CSprite)
	g_TalkCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTalkEvent"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
end

--其他地方调用ShowSubPage("talk")的时候每次都会执行 ShowPage 函数，否则就是执行HidePage的函数
function CTalkPart.OnHidePage(self)
	if self.m_ID then
		g_TalkCtrl:SaveMsgRecord(self.m_ID)
	end
	self.m_ID = nil
end

--聊天协议通知返回
function CTalkPart.OnTalkEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Talk.Event.AddMsg then
		local pid = oCtrl.m_EventData["pid"]
		local iAmount = oCtrl.m_EventData["amount"]
		if self:IsShow() and self.m_ID == pid then
			self:AddMsg(pid, iAmount)
			--刷新未读消息状态
			if self.m_IsLock then
				self.m_IsTalkEventReceive = true
				self.m_UnReadCnt = self.m_UnReadCnt + 1
				self:RefreshUnRead()

				if self.m_UnReadCnt >= 10 then
					self:ReadAll()
				end
			end
		end
	end
end

--好友协议通知返回
function CTalkPart.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.Update then
		self:UpdateFriend(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.Friend.Event.Add then
		-- printc("CTalkPart添加好友协议返回")
		-- local sText = data.frienddata.FRIENDTEXT[define.Friend.Text.AddFriendHello].content
		-- for k,v in pairs(oCtrl.m_EventData) do
		-- 	g_TalkCtrl:AddSelfMsg(v, sText)
		-- 	g_TalkCtrl:SendChat(v, sText)
		-- end	
	elseif oCtrl.m_EventID == define.Friend.Event.NotifyRefuseStrangerMsg then
		if not self.m_ID then return end
		self.m_RejectMsgObj:SetActive(g_FriendCtrl.m_NotifyRefuseStrangerData[self.m_ID])
	end
end

--刷新私聊part的empty介绍界面
function CTalkPart.RefreshEmpty(self,list)
	if next(list) then
		self.m_EmptyGo:SetActive(false)
	else
		self.m_EmptyGo:SetActive(true)
		local InsStr = data.frienddata.FRIENDTEXT[define.Friend.Text.TalkIns].content
		self.m_EmptyLbl:SetText(InsStr)
	end
end

--传一个pid参数设置talkpart界面信息以及刷新这个pid的聊天记录
function CTalkPart.SetPlayer(self, pid)
	-- printc("CTalkPart.SetPlayer:",pid)
	self.m_ID = pid
	self:RefreshUI()
	self:ReadAll(self.m_ID)
	-- self:AddAllMsg(pid)
	netfriend.C2GSQueryFriendProfile({self.m_ID})
end

--获取当前talkpart对话的pid
function CTalkPart.GetPlayer(self)
	return self.m_ID
end

--根据好友协议数据更新当前对话pid的talkpart界面信息
function CTalkPart.UpdateFriend(self, frdList)
	if table.index(frdList, self.m_ID) then
		self:RefreshUI()
	end
end

--刷新talkpart界面的ui
function CTalkPart.RefreshUI(self)
	local frdobj = g_FriendCtrl:GetFriend(self.m_ID)
	if frdobj then
		self.m_SchoolSpr:SetActive(true)
		self.m_SchoolSpr:SpriteSchool(frdobj.school)
		self.m_NameLabel:SetText(frdobj.name)
		self:SetRelation(frdobj.friend_degree, frdobj.relation)
	else
		self.m_SchoolSpr:SetActive(false)
		self.m_NameLabel:SetText(string.format("玩家%d", self.m_ID))
		self:SetRelation()
	end
	self.m_RejectMsgObj:SetActive(g_FriendCtrl.m_NotifyRefuseStrangerData[self.m_ID])
	if g_FriendCtrl:IsMyFriend(self.m_ID) then
		self.m_AddFrdBtn:SetActive(false)
	else
		self.m_AddFrdBtn:SetActive(true)
	end
end

function CTalkPart.SetRelation(self, iDegree, relation)
	local name = nil
	if g_FriendCtrl:IsMyFriend(self.m_ID) and iDegree then
		name = g_FriendCtrl:GetRelationIcon(iDegree, relation)
		self.m_RelationNameLbl:SetActive(false)
		self.m_RelationLabel:SetActive(true)
		self.m_RelationLabel:SetText(iDegree)
		self.m_RelationBtn:SetActive(true)
		self.m_RelationBtn:SetSpriteName(name)
	
	else
		self.m_RelationBtn:SetActive(false)
		self.m_RelationLabel:SetActive(false)
		self.m_RelationNameLbl:SetActive(true)
		self.m_RelationNameLbl:SetText("陌生人")
	end
end

--添加自己发送给pid的信息，不通过协议，本地添加
function CTalkPart.AddSelfMsg(self, sText)
	g_TalkCtrl:AddSelfMsg(self.m_ID, sText)
end

--------------下边的函数是对聊天item进行管理------------------

--下边的函数是增加或删除聊天信息item

function CTalkPart.AddAllMsg(self, pid)
	self.m_MsgTable:Clear()
	self.m_MsgData = g_TalkCtrl:GetMsg(pid)
	self.m_CurAppendIdx = 0
	self.m_IsLock = false
	self.m_LoadEnd = false
	self.m_IsTalkEventReceive = false
	self.m_UnReadCnt = 0
	self:RefreshUnRead()
	--聊天记录显示上限
	local iAmount = math.min(50, #self.m_MsgData)
	for i = 1, iAmount do
		self:AddMsgBox(self.m_MsgData[i], true)
	end
	self.m_MsgTable:Reposition()
	self.m_ScrollView:ResetPosition()
	self:RefreshEmpty(self.m_MsgData)
end

function CTalkPart.AddMsg(self, pid, iAmount)
	self.m_MsgData = g_TalkCtrl:GetMsg(pid)
	for i = iAmount, 1, -1 do
		local oMsg = self.m_MsgData[i]
		self:AddMsgBox(oMsg)
	end
	self:RefreshEmpty(self.m_MsgData)
end

function CTalkPart.ShowOldMsg(self)
	local iCount = self.m_MsgTable:GetCount()
	self.m_MsgData = g_TalkCtrl:GetMsg(self.m_ID)
	-- if iCount < #self.m_MsgData and not self.m_LoadEnd then
		-- if g_TalkCtrl:LoadMsgRecord(self.m_ID) then
		-- 	self.m_MsgData = g_TalkCtrl:GetMsg(self.m_ID)
		-- else
		-- 	self.m_LoadEnd = true
		-- end
		-- return
	-- end

	-- local oOldMsg = self.m_MsgData[self.m_CurAppendIdx + 1]
	-- if oOldMsg then
	-- 	self:AddMsgBox(oOldMsg, true)
	-- end
	-- printc("msgTable数量",iCount,"msgData数量",#self.m_MsgData)
	-- table.print(self.m_MsgData,"msgdata")
	if self.m_IsLock and self.m_IsTalkEventReceive then
		self:ReadAll()
		self:RefreshEmpty(self.m_MsgData)
	end
end

function CTalkPart.AddMsgBox(self, oMsg, bAppend)
	local iType = oMsg:GetType()
	local oMsgBox = nil
	local audioLink = oMsg:GetAudioLink()
	
	if not self.m_IsLock then
		if iType == define.Chat.MsgType.NoSender then
			oMsgBox = self.m_MsgBoxSys:Clone()
		
		elseif iType == define.Chat.MsgType.Self then
			if audioLink then
				oMsgBox = self.m_AudioBoxRight:Clone()
			else
				oMsgBox = self.m_MsgBoxRight:Clone()
			end
		
		elseif iType == define.Chat.MsgType.Others then
			if audioLink then
				oMsgBox = self.m_AudioBoxLeft:Clone()
			else
				oMsgBox = self.m_MsgBoxLeft:Clone()
			end
		end
		
		oMsgBox:SetActive(true)
		oMsgBox:SetMsg(oMsg)
		self.m_MsgTable:AddChild(oMsgBox)
		if not bAppend then
			oMsgBox:SetAsFirstSibling()
		end
		self.m_MsgTable:Reposition()
		self.m_ScrollView:CullContentLater()
	else
		-- if iType ~= define.Chat.MsgType.NoSender then
		-- 	self.m_UnReadCnt = self.m_UnReadCnt + 1
		-- 	self:RefreshUnRead()

		-- 	if self.m_UnReadCnt >= 10 then
		-- 		self:ReadAll()
		-- 	end
		-- end
	end

	self.m_CurAppendIdx = self.m_CurAppendIdx + 1
end

--------------下边是点击事件----------------

--点击发送消息按钮
function CTalkPart.OnSubmit(self)
	local sText = self.m_Input:GetText()
	if self:CheckGM(sText) then
		return
	end
	if sText == "" then
		return
	end
	
	--这里是会替换链接内容，主要是不被屏蔽字屏蔽
	local linkStr = {}
	for sLink in string.gmatch(sText, "%b{}") do
		table.insert(linkStr, sLink)
	end	
	sText = g_MaskWordCtrl:ReplaceMaskWord(sText)

	local iEmojiCnt = 0
	local function emoji(s)
		iEmojiCnt = iEmojiCnt + 1
		if iEmojiCnt > 5 then
			return string.sub(s, 5)
		else
			return s
		end
	end
	sText = string.gsub(sText, "#%d+", emoji)
	sText = string.gsub(sText, "#%u", "")
	sText = string.gsub(sText, "#n", "")
	sText = g_ChatCtrl:BlockColorInput(sText)
	sText = g_MaskWordCtrl:ReplaceMaskWord(sText)
	local index = 1
	for sLink in string.gmatch(sText, "%b{}") do
		if linkStr[index] then
			sText = string.replace(sText, sLink, linkStr[index])
		end
		index = index + 1
	end
	self:AddSelfMsg(sText)
	g_TalkCtrl:SendChat(self.m_ID, sText)
	
	self.m_Input:SetText("")
	self.m_Input.m_RealText = ""
	--发送消息后解除锁屏状态
	self:ReadAll()

	CEmojiLinkView:CloseView()
end

function CTalkPart.OnFocusInput(self)
	if self.m_Input.m_UIInput.isSelected then
		CEmojiLinkView:CloseView()
	end
end

--检查gm
function CTalkPart.CheckGM(self, sText)
end

--点击语音按钮
function CTalkPart.OnSpeech(self, oBtn, bPress)
	if bPress then
		g_ChatCtrl.m_IsChatRecording = true
		self:StartRecord(oBtn)
		-- self:RecordTimeOut()
	else
		g_ChatCtrl.m_IsChatRecording = false
		self:EndRecord()
	end
end

--开始录音
function CTalkPart.StartRecord(self, oBtn)
	-- 音量级减小
	g_AudioCtrl:SetSlience()
	g_NotifyCtrl:ShowDisableWidget(true, nil, 70)
	CSpeechRecordView:ShowView(function(oView) 
		oView:SetRecordBtn(oBtn)
		oView:BeginRecord(nil, self.m_ID, nil, self, 18)
	end)
end

--结束录音
function CTalkPart.EndRecord(self)
	-- 音量恢复
	g_AudioCtrl:ExitSlience()
	local oView = CSpeechRecordView:GetView()
	if oView then
		if oView:EndRecord(nil, self.m_ID, nil) then
			--发送语音后解除锁屏状态
			self:ReadAll()
		end
	end
end

--录音超时
function CTalkPart.RecordTimeOut(self)
	--超过录音30s自动结束录制
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil			
	end
	local timeCount = 0
	local totalCount = (30)/define.Treasure.Time.Delta
	local isUpdate = false
	local function progress()
		isUpdate = true
		timeCount = timeCount + 1
		if timeCount >= totalCount then
			self:EndRecord()
			if self.m_Timer then
				Utils.DelTimer(self.m_Timer)
				self.m_Timer = nil			
			end
			isUpdate = false
		end
		return isUpdate
	end
	self.m_Timer = Utils.AddTimer(progress, 0.02, 0.02)
end

--点击查看好友度提示按钮
function CTalkPart.OnRelationTips(self)
	local zId = define.Friend.Text.RelationTips
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

--点击上方还有聊天记录未读时出现的未读消息框
function CTalkPart.ReadAll(self)
	self.m_IsLock = false
	self.m_IsTalkEventReceive = false
	self.m_UnReadCnt = 0
	self:RefreshUnRead()
	self:AddAllMsg(self.m_ID)
end

--设置未读消息框的界面
function CTalkPart.RefreshUnRead(self, iCnt)
	local iCnt = self.m_UnReadCnt
	if iCnt > 0 then
		self.m_UnReadBox:SetActive(true)
	else
		self.m_UnReadBox:SetActive(false)
	end
	local s = string.format("未读信息%d条", iCnt)
	self.m_UnReadBox.m_Label:SetText(s)
	self.m_UnReadBox.m_ArrowSpr:ResetAndUpdateAnchors()
end

--设置添加聊天item的scrollview拖动结束后进入锁屏状态，即有新消息出现未读消息框
function CTalkPart.SetLock(self)
	local index = self.m_MsgTable:GetCount()
	local topItem = self.m_MsgTable:GetChild(1)
	if topItem and not topItem:GetActive() then
		self.m_IsLock = true
	end
end

--点击表情按钮，出现表情、道具链接界面
function CTalkPart.OnEmoji(self)
	self.m_Input.m_UIInput:RemoveFocus()
	CEmojiLinkView:ShowView(
		function(oView)
			oView:SetSendFunc(callback(self, "AppendText"))
		end
	)
end

--点击了表情、道具链接界面某个东西后设置，先清掉先前的链接，后设置新加的链接，即只有一个链接
function CTalkPart.AppendText(self, s, isClearInput)
	if string.match(s, "%b{}") then
		self.m_Input:ClearLink()
	end
	if isClearInput then
		self.m_Input:SetText(s)
	else
		--GetText()这里读的是自己设置的一个字段而不是input的value
		local sOri = self.m_Input:GetText()
		self.m_Input:SetText(sOri..s)
	end
end

--点击添加好友按钮
function CTalkPart.OnAddFrd(self)
	g_FriendCtrl:ApplyAddFriend(self.m_ID)
end

--点击删除好友按钮
function CTalkPart.OnDelFrd(self)
	local pid = self.m_ID
	local frdobj = g_FriendCtrl:GetFriend(pid)
	local sMsg = "你确定要将此好友删除？"
	if frdobj and frdobj.name then
		sMsg = string.gsub(data.frienddata.FRIENDTEXT[define.Friend.Text.RemoveFriend].content,"#role",frdobj.name)
	end
	local windowConfirmInfo = {
		msg = sMsg,
		title = "删除好友",
		okCallback = function () 
			netfriend.C2GSApplyDelFriend(pid)
			self:DelTalk()
			if self.m_DelTalkToTab == 0 then
				self:SwitchToRecent()
			else
				self:SwitchToFriend()
			end
		end,
		okStr = "确定",
		cancelStr = "取消",
		color = Color.white,
	}
	if g_FriendCtrl:IsMyFriend(pid) then
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self:DelTalk()
		self:SwitchToRecent()
	end
end

function CTalkPart.DelTalk(self)
	g_FriendCtrl:RemoveRecent(self.m_ID)
end

--在talkpart界面删除好友后切换到好友界面
function CTalkPart.SwitchToFriend(self)	
	self.m_ParentView:ShowFriend()
end

--在talkpart界面删除好友后切换到最近联系人界面
function CTalkPart.SwitchToRecent(self)
	--暂时屏蔽一条消息打开聊天界面
	-- if g_TalkCtrl:GetRecentTalkRoleCount() == 1 then
 --        local pid = g_TalkCtrl:GetRecentTalk()
 --        if g_TalkCtrl:GetTotalNotify() and pid then
 --            CFriendInfoView:ShowView(function (oView)
 --            oView:ShowTalk(pid)
 --            end)
 --        end
 --    else 
 --        self.m_ParentView:ShowRecent()
 --    end
    self.m_ParentView:ShowRecent()
end

return CTalkPart

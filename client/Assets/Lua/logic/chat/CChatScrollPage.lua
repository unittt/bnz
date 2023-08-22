local CChatScrollPage = class("CChatScrollPage", CBox)

function CChatScrollPage.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Input = self:NewUI(1, CChatInput,true,define.Chat.ChatInputArgs)
	self.m_MsgTable = self:NewUI(2, CTable)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_MsgBoxRight = self:NewUI(4, CChatMsgBox)
	self.m_MsgBoxLeft = self:NewUI(5, CChatMsgBox)
	self.m_SubmitBtn = self:NewUI(6, CButton)
	self.m_EmojiBtn = self:NewUI(7, CButton)
	self.m_UnReadBox = self:NewUI(8, CBox)
	self.m_LockBg = self:NewUI(9, CSprite)
	self.m_UnLockSpr = self:NewUI(10, CSprite)
	self.m_LockSpr = self:NewUI(11, CSprite)
	self.m_MsgBoxSys = self:NewUI(12, CChatSysMsgBox)
	self.m_ChanelTip = self:NewUI(13, CLabel)
	self.m_SpeechBtn = self:NewUI(14, CButton)
	self.m_AudioSetBox = self:NewUI(15, CBox)
	self.m_AudioBoxLeft = self:NewUI(16, CChatAudioBox)
	self.m_AudioBoxRight = self:NewUI(17, CChatAudioBox)
	self.m_OrgGo = self:NewUI(18, CObject)
	self.m_OrgJoinLbl = self:NewUI(19, CLabel)
	self.m_TeamGo = self:NewUI(20, CObject)
	self.m_TeamJoinLbl = self:NewUI(21, CLabel)
	self.m_ShieldWidget = self:NewUI(22, CWidget)
	self.m_OrgCallBox = self:NewUI(23, CBox)
	self.m_OrgCallTipsObj = self:NewUI(24, CObject)
	self.m_OrgCallTipsCloseBtn = self:NewUI(25, CButton)
	self.m_DownBtn = self:NewUI(26, CButton)
	self.m_DownBox = self:NewUI(27, CBox)
	self.m_DownBox.m_Bg = self.m_DownBox:NewUI(1, CSprite)
	self.m_DownBox.m_Grid = self.m_DownBox:NewUI(2, CGrid)
	self.m_DownBox.m_LongChatBtn = self.m_DownBox:NewUI(3, CButton)
	self.m_DownBox.m_OrgBarrageBtn = self.m_DownBox:NewUI(4, CButton)
	self.m_DownBox.m_OrgBarrageBtn:SetActive(false)
	self.m_DownBox.m_RedPacketBtn = self.m_DownBox:NewUI(5, CButton)
	self.m_DownBox.m_RedPacketBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.RedPacket))
	local function init(obj, idx)
		local oBtn = CButton.New(obj)
		if oBtn:GetActive() then
			return oBtn
		end
	end
	self.m_DownBox.m_Grid:InitChild(init)

	self.m_CurChannel = nil
	self.m_IsLockRead = false
	self.m_LastReadIndex = 0
	self.m_UnReadCnt = 0
	self.m_AddCnt = 20
	self.m_MsgCnt = 100
	self.m_CurAppendIdx = 0
	self.m_ExtraReceives = {}
	self.m_MsgList = {}
	self.m_OrgCallText = ""
	self.m_OrgCallItemIndex = 1
	self.m_IsOrgCallSet = false
	self.m_IsRecording = false
	self.m_Input:SetForbidChars({"{", "}"})
	self:InitContent()

	g_GuideCtrl:AddGuideUI("chatview_emoji_btn", self.m_EmojiBtn)
	g_GuideCtrl:AddGuideUI("chatview_send_btn", self.m_SubmitBtn)
end

function CChatScrollPage.InitContent(self)
	self.m_UnReadBox:SetActive(false)
	self.m_MsgBoxLeft:SetActive(false)
	self.m_MsgBoxRight:SetActive(false)
	self.m_MsgBoxSys:SetActive(false)
	self.m_AudioBoxRight:SetActive(false)
	self.m_AudioBoxLeft:SetActive(false)
	self.m_ShieldWidget:SetActive(false)
	self.m_OrgCallBox:SetActive(false)
	self.m_OrgCallTipsObj:SetActive(false)
	self.m_DownBox:SetActive(false)

	self:CheckDownUI()
	
	self.m_Input:AddUIEvent("submit", callback(self, "OnSubmit"))
	self.m_Input:AddUIEvent("select", callback(self, "OnFocusInput"))
	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit"))
	self.m_EmojiBtn:AddUIEvent("click", callback(self, "OnEmoji"))
	self.m_SpeechBtn:AddUIEvent("press", callback(self, "OnSpeech"))
	self.m_DownBtn:AddUIEvent("click", callback(self,"OnClickShowDown"))
	self.m_DownBox.m_LongChatBtn:AddUIEvent("click", callback(self,"OnLongChat"))
	self.m_DownBox.m_OrgBarrageBtn:AddUIEvent("click", callback(self,"OnOrgBarrageBtn"))
	self.m_DownBox.m_RedPacketBtn:AddUIEvent("click", callback(self,"OnRedPacketBtn"))
	-- g_UITouchCtrl:AddDragObject(self.m_SpeechBtn, {start_delta={x=100,y=0},})
	self.m_LockBg:AddUIEvent("click", callback(self, "SwitchLock"))
	self.m_OrgJoinLbl:AddUIEvent("click", callback(self, "OnJoinOrg"))
	self.m_TeamJoinLbl:AddUIEvent("click", callback(self, "OnJoinTeam"))
	self.m_OrgCallTipsCloseBtn:AddUIEvent("click", callback(self, "OnCloseOrgCallTips"))
	self.m_ScrollView:SetCullContent(self.m_MsgTable)
	self.m_ScrollView:AddMoveCheck("down", self.m_MsgTable, callback(self, "ShowOldMsg"))
	self.m_ScrollView:AddMoveCheck("up", self.m_MsgTable, callback(self, "ShowNewMsg"))
	self.m_ScrollView:AddUIEvent("scrolldragfinished", callback(self, "SetLock"))
	
	self.m_UnReadBox:AddUIEvent("click", callback(self, "ReadAll"))
	self.m_UnReadBox.m_Label = self.m_UnReadBox:NewUI(1, CLabel)
	self.m_UnReadBox.m_ArrowSpr = self.m_UnReadBox:NewUI(2, CSprite)

	self.m_OrgCallBox:AddUIEvent("click", callback(self, "ReadOrgCall"))
	self.m_OrgCallBox.m_Label = self.m_OrgCallBox:NewUI(1, CLabel)
	self.m_OrgCallBox.m_ArrowSpr = self.m_OrgCallBox:NewUI(2, CSprite)
	
	self.m_AudioSetBox.m_Label = self.m_AudioSetBox:NewUI(1, CLabel)
	self.m_AudioSetBox.m_Btn = self.m_AudioSetBox:NewUI(2, CSprite)
	self.m_AudioSetBox.m_Btn:AddUIEvent("click", callback(self, "SetAutoAudio"))
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTeamEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttEvent"))
	g_OpenSysCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOpenSysEvent"))
	
	self:RefreshLock()
end

--聊天协议返回
function CChatScrollPage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.AddMsg then
		local oMsg = oCtrl.m_EventData
		--table.print(oMsg,"聊天协议数据返回OnCtrlEvent")
		local iChannel = oMsg:GetValue("channel")
		local lReceives = self:GetReceiveChannels()
		if oMsg:GetType() == define.Chat.MsgType.Self then
			self:SetChannelTip(self.m_CurChannel)
		end
		if not table.index(lReceives, iChannel) then
			return
		end
		
		table.insert(self.m_MsgList, oMsg)

		--只有是在帮派频道才会检测被别人@的消息
		if iChannel == define.Channel.Org then
			--查询这条消息有没有被别人@的链接
			local callLink = oMsg:GetOrgCallLink()
			if callLink and tonumber(callLink.pid) == tonumber(g_AttrCtrl.pid) then
				-- printc("查询这条消息有被别人@的链接",callLink.pid)
				--有自己的链接，先解锁消息
				self:ShowNewMsg()

				self.m_OrgCallText = LinkTools.GetPrintedText(oMsg:GetText())
				self:ShowOrgCallBox()
			end
		end

		if self.m_IsLockRead then
			self:SetUnReadCnt(self.m_LockCnt + 1)
		else
			self:AddMsg(oMsg)
		end

		if oMsg:GetType() == define.Chat.MsgType.Self and not oMsg:GetAudioLink() then
			self.m_Input:SetText("")
			self.m_Input.m_RealText = ""
		end
	end
end

--组队协议返回
function CChatScrollPage.OnCtrlTeamEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTeam then
		if g_TeamCtrl:IsJoinTeam() then
			self.m_ShieldWidget:SetActive(false)
			self.m_TeamGo:SetActive(false)
		end
	elseif oCtrl.m_EventID == define.Team.Event.DelTeam then
		if not g_TeamCtrl:IsJoinTeam() then
			-- self.m_ShieldWidget:SetActive(true)
			-- self.m_Input:SetText("")
			self.m_TeamGo:SetActive(true)
		end
	end
end

function CChatScrollPage.OnAttEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
       self:SetAudioBox()
	end
end

function CChatScrollPage.OnOpenSysEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SysOpen.Event.Change then
		self.m_DownBox.m_RedPacketBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.RedPacket))
		self:CheckDownUI()
	end
end

---------------------下边是聊天item的添加或删除-------------------

function CChatScrollPage.RefreshAllMsg(self)
	self.m_MsgTable:Clear()
	self.m_IsOrgCallSet = false
	self.m_CurAppendIdx = 0
	self.m_MsgList = {}
	for i, iChannel in ipairs(self:GetReceiveChannels()) do
		local list = g_ChatCtrl:GetMsgList(iChannel)
		for i, oMsg in ipairs(list) do
			table.insert(self.m_MsgList, oMsg)
		end
	end
	
	table.sort(self.m_MsgList, function(a, b) return a["pos"] < b["pos"] end)
	local len = #self.m_MsgList
	local lastIndex = nil
	for i=len, len-self.m_AddCnt, -1 do
		local oMsg = self.m_MsgList[i]
		if oMsg then
			if not lastIndex then
				lastIndex = oMsg.m_ID
			end
			self:AddMsg(oMsg, true)
			self.m_CurAppendIdx = i
		else
			break
		end
	end
	self.m_MsgTable:Reposition()
	self.m_ScrollView:ResetPosition()

	if g_ChatCtrl:GetIsOrgCall() and self.m_CurChannel and self.m_CurChannel == define.Channel.Org then
		self:ReadOrgCall()
	else
		self.m_OrgCallBox:SetActive(false)
	end
end

function CChatScrollPage.AddMsg(self, oMsg, bAppend)
	local iType = oMsg:GetType()
	local oMsgBox = nil
	local audioLink = oMsg:GetAudioLink()
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
	
	if not bAppend then --bAppend true 最后面添加，false添加到第一位
		oMsgBox:SetAsFirstSibling()

		--最新的覆盖
		local callLink = oMsg:GetOrgCallLink()
		if callLink and tonumber(callLink.pid) == tonumber(g_AttrCtrl.pid) then
			local idx = self.m_MsgTable:GetCount()
			self.m_OrgCallItemIndex = 1	
		else
			self.m_OrgCallItemIndex = self.m_OrgCallItemIndex + 1
		end
		-- printc("最新的覆盖,self.m_OrgCallItemIndex改变了",self.m_OrgCallItemIndex)
	else
		--只要最新的
		if not self.m_IsOrgCallSet then
			local callLink = oMsg:GetOrgCallLink()
			if callLink and tonumber(callLink.pid) == tonumber(g_AttrCtrl.pid) then
				local idx = self.m_MsgTable:GetChildIdx(oMsgBox.m_Transform)
				-- printc("只要最新的,self.m_OrgCallItemIndex改变了",idx)
				self.m_OrgCallItemIndex = idx
				self.m_IsOrgCallSet = true
			end
		end
	end
	
	local iCount = self.m_MsgTable:GetCount()
	if not bAppend and iCount>self.m_MsgCnt then
		local oChild = self.m_MsgTable:GetChild(iCount)
		self.m_MsgTable:RemoveChild(oChild)
	end
	self.m_ScrollView:CullContentLater()
	self.m_MsgTable:Reposition()
end

function CChatScrollPage.ShowOldMsg(self)
	local iCount = self.m_MsgTable:GetCount()
	if iCount > self.m_MsgCnt-1 then
		return
	end
	local oOldMsg = self.m_MsgList[self.m_CurAppendIdx - 1]
	if oOldMsg then
		self:AddMsg(oOldMsg, true)
		self.m_CurAppendIdx = self.m_CurAppendIdx - 1
	end
end

----------------以下是聊天ui设置和聊天限制设置--------------------

function CChatScrollPage.SetChannel(self, iChannel)
	local lForbid = self:ForbidChatChannels()
	local bCanChat = table.index(lForbid, iChannel) == nil
	if bCanChat then
		self.m_IsLockRead = false
		self:RefreshLock()
		--组队频道的特殊消息，暂时屏蔽
		-- g_ChatCtrl:SendLimitMsg(iChannel)
	end
	self:SetChannelTip(iChannel)
	self.m_CurChannel = iChannel
	self.m_ChanelTip:SetActive(not bCanChat)
	self.m_Input:SetActive(bCanChat)
	self.m_EmojiBtn:SetActive(bCanChat)
	self.m_SubmitBtn:SetActive(bCanChat)
	self:SetAudioBox()
	self:RefreshAllMsg()

	self.m_ShieldWidget:SetActive(false)
	self.m_OrgGo:SetActive(false)
	self.m_OrgCallTipsObj:SetActive(false)
	self.m_TeamGo:SetActive(false)
	if iChannel == define.Channel.Org then
		if not(g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0) then
			self.m_ShieldWidget:SetActive(true)
			self.m_Input:SetText("")
			self.m_Input.m_RealText = ""
			self.m_OrgGo:SetActive(true)
		else
			if not g_ChatCtrl.m_IsOrgCallTips then
				self.m_OrgCallTipsObj:SetActive(true)
			end
		end
	elseif iChannel == define.Channel.Team then
		if not g_TeamCtrl:IsJoinTeam() then
			-- self.m_ShieldWidget:SetActive(true)
			-- self.m_Input:SetText("")
			self.m_TeamGo:SetActive(true)
		end
	end
end


function CChatScrollPage.SetChannelTip(self, iChannel)
	self:ReleaseTipTimer()
	self.m_Input:EnableTouch(true)
	local lForbid = self:ForbidChatChannels()
	local bCanChat = table.index(lForbid, iChannel) == nil
	self.m_ChanelTip:SetActive(not bCanChat)
	
	-- if self.m_Input:GetText() ~= "" then
	-- 	printc("CChatScrollPage.SetChannelTip self.m_Input not null")
	-- 	return
	-- end	
	
	if iChannel == define.Channel.World then
		local configTime = data.chatdata.CHATCONFIG[define.Channel.World].talk_gap
		local repTime = string.gsub(configTime, "lv", g_AttrCtrl.grade)
		local iLimitTime = tonumber(load(string.format([[return (%s)]], repTime))())
		-- local iLimitTime = math.max(120, 300 - g_AttrCtrl.grade * 2)
		local iLastTime = 0
		if g_ChatCtrl.m_LastWorldChatTime then
			iLastTime = g_ChatCtrl.m_LastWorldChatTime
		end
		--暂时屏蔽世界频道倒计时显示
		-- local iRemain = iLimitTime - (g_TimeCtrl:GetTimeS() - iLastTime)
		-- if iRemain > 0 then
		-- 	self:CreateTipTimer(iRemain)
		-- end
	else
		self.m_ChanelTip:SetLocalPos(Vector3.New(-239, 356, 0))
		self.m_ChanelTip:SetText("此频道不能发言，请切换到其他频道发言")

		if self.m_Input:GetText() == "" then
			self.m_Input:SetText("")
			self.m_Input.m_RealText = ""
		end
	end
end

function CChatScrollPage.SetAudioBox(self)
	local t = {define.Channel.Team, define.Channel.Org, define.Channel.World, define.Channel.Current}
	if table.index(t, self.m_CurChannel) then
		self.m_SpeechBtn:SetActive(true)
		self.m_AudioSetBox:SetActive(true)
		self.m_DownBtn:SetActive(self:SetChuanyin(true))
		local sName = define.Channel.Ch2Text[self.m_CurChannel]
		self.m_AudioSetBox.m_Label:SetText(string.format("自动播放%s频道语音", sName))
		self.m_AudioSetBox.m_Btn:SetSelected(not g_ChatCtrl:IsAudioFilter(self.m_CurChannel))
	else
		self.m_SpeechBtn:SetActive(false)
		self.m_AudioSetBox:SetActive(false)
		self.m_DownBtn:SetActive(self:SetChuanyin(false))
	end
end

function CChatScrollPage.SetAutoAudio(self)
	g_ChatCtrl:SetAudioChannel(self.m_CurChannel, not self.m_AudioSetBox.m_Btn:GetSelected())
end

function CChatScrollPage.CreateTipTimer(self, iTime)
	local function update()
		iTime = iTime - 1
		if Utils.IsNil(self) then
			return false
		end
		if iTime>0 then
			self.m_ChanelTip:SetActive(true)
			self.m_Input.m_ChildLabel:SetText("")
			self.m_ChanelTip:SetLocalPos(Vector3.New(-215, -325, 0))
			self.m_ChanelTip:SetText(string.format("需要等待%d秒才能发言", iTime))
			return true
		else
			self.m_ChanelTip:SetActive(false)
			--暂时屏蔽
			-- self.m_Input.m_ChildLabel:SetText("#J点击输入文字")
			self.m_Input.m_ChildLabel:SetText("点击输入文字")
			self.m_Input:EnableTouch(true)
			self.m_TipTimer = nil
			return false
		end
	end
	self.m_ChanelTip:SetActive(true)
	self.m_Input:EnableTouch(false)
	self.m_TipTimer = Utils.AddTimer(update, 1, 0) 
end

function CChatScrollPage.ReleaseTipTimer(self)
	if self.m_TipTimer then
		Utils.DelTimer(self.m_TipTimer)
		self.m_TipTimer = nil
	end
end

function CChatScrollPage.ForbidChatChannels(self)
	return {define.Channel.Message, define.Channel.Sys}
end

function CChatScrollPage.CloseTimer(self)
	if self.m_FocusTimer then
		Utils.DelTimer(self.m_FocusTimer)
		self.m_FocusTimer = nil
	end
end

function CChatScrollPage.RefreshFocus(self)
	if not self.m_Input:IsFocus() then
		self.m_Input:SetFocus()
	end
	return true
end

function CChatScrollPage.GetReceiveChannels(self)
	return table.extend({self.m_CurChannel}, self.m_ExtraReceives)
end

function CChatScrollPage.SetExtraReceives(self, channels)
	self.m_ExtraReceives = channels
end

function CChatScrollPage.SetChuanyin(self,bIshow)
	local level = data.opendata.OPEN["CHUAN_YIN"].p_level
	local isShow = false
	if g_AttrCtrl.grade >= level then
       isShow = true
    else
    	isShow = false
    end
    return isShow and bIshow
end

function CChatScrollPage.CheckDownUI(self)
	self.m_DownBox.m_Grid:Reposition()
	local _, celheight = self.m_DownBox.m_Grid:GetCellSize()
	self.m_DownBox.m_Bg:SetHeight(15 + self.m_DownBox.m_Grid:GetCount() * celheight)
end
------------------以下是被别人@相关------------------

--读取帮派频道里面的被别人@的消息
function CChatScrollPage.ReadOrgCall(self)
	if g_ChatCtrl:GetIsOrgCall() then
		g_ChatCtrl:SetIsOrgCall(false)
		self.m_OrgCallText = ""
		-- printc("读取帮派频道里面的被别人@的消息,锁屏")
		--锁屏
		if not self.m_IsLockRead then
			self:SwitchLock()
		end
		-- printc("读取帮派频道里面的被别人@的消息,移动到指定item",self.m_OrgCallItemIndex)
		--移动到指定item
		UITools.MoveToTarget(self.m_ScrollView, self.m_MsgTable:GetChild(self.m_OrgCallItemIndex))
	end
	self:ShowOrgCallBox()
end

function CChatScrollPage.ShowOrgCallBox(self)
	if g_ChatCtrl:GetIsOrgCall() then
		self.m_OrgCallBox:SetActive(true)
		local sText = string.gettitle(self.m_OrgCallText, 30)
		self.m_OrgCallBox.m_Label:SetRichText(sText)
		-- local label = self.m_OrgCallBox.m_Label.m_GameObject:GetComponent(classtype.UILabel)
		-- local bIsWrap, text = label:Wrap(label, "吼吼吼吼吼吼吼吼吼", nil, 10)
		-- self.m_OrgCallBox.m_Label:SetRichText(text)
	else
		self.m_OrgCallBox:SetActive(false)
	end
end

-------------------以下是未读消息框相关-------------------------

function CChatScrollPage.SwitchLock(self)
	self.m_IsLockRead = not self.m_IsLockRead
	self:RefreshLock()
end

--读取所有的未读消息
function CChatScrollPage.ReadAll(self)
	self:SwitchLock()
end

--在锁屏的状态切换到未锁屏的状态
function CChatScrollPage.ShowNewMsg(self)
	if self.m_IsLockRead then
		self:SwitchLock()
	end
end

--在未锁屏的状态下切换到锁屏
function CChatScrollPage.SetLock(self)
	if not self.m_IsLockRead then
		local oItem = self.m_MsgTable:GetChild(1)
		if oItem and not oItem:GetActive() then
			self:SwitchLock()
		end
	end
end

--未读消息框的界面ui相关
function CChatScrollPage.SetUnReadCnt(self, iCnt)
	self.m_LockCnt = iCnt
	if iCnt > 0 then
		self.m_UnReadBox:SetActive(true)
	else
		self.m_UnReadBox:SetActive(false)
	end
	local s = string.format("未读信息%d条", self.m_LockCnt)
	self.m_UnReadBox.m_Label:SetText(s)
	self.m_UnReadBox.m_ArrowSpr:ResetAndUpdateAnchors()
end

--未读消息框的界面ui相关
function CChatScrollPage.RefreshLock(self)
	self.m_UnReadBox:SetActive(self.m_IsLockRead)
	self.m_LockSpr:SetActive(self.m_IsLockRead)
	self.m_UnLockSpr:SetActive(not self.m_IsLockRead)
	
	if not self.m_IsLockRead and self.m_LockCnt then
		local tail = #self.m_MsgList
		local head = math.max(1, tail - self.m_LockCnt +1)
		for i = head, tail do
			local oMsg = self.m_MsgList[i]
			if oMsg then
				self:AddMsg(oMsg)
			end
		end
		self.m_MsgTable:Reposition()
		self.m_ScrollView:ResetPosition()
	end
	self:SetUnReadCnt(0)
end

-----------------以下是点击事件--------------------

--点击发送按钮
function CChatScrollPage.OnSubmit(self)
	local sText = self.m_Input:GetText()
	--printc("点击发送input加工前的内容:"..sText)
	if self:CheckGM(sText) then
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
	--printc("点击发送input加工后的内容:",sText)
	if g_ChatCtrl:SendMsg(sText, self.m_CurChannel) then
		-- self.m_Input:SetText("")
		self:SetChannelTip(self.m_CurChannel)
	end
	--发送消息后解除锁屏状态
	self:ShowNewMsg()
	CEmojiLinkView:CloseView()
end

function CChatScrollPage.OnFocusInput(self)
	if self.m_Input.m_UIInput.isSelected then
		CEmojiLinkView:CloseView()
	end
end

--检查GM
function CChatScrollPage.CheckGM(self, sText)
	local oView = CNotifyView:GetView()
	if oView and oView.m_OrderBtn:GetActive() == false and g_MapCtrl:GetMapID() == 203000 then
		if self.m_CurChannel == define.Channel.Team and g_ChatCtrl:IsFilterChannel(self.m_CurChannel) then
			if sText == "#clgm" then
				oView.m_OrderBtn:SetActive(false)
				return true
			elseif sText == "opgm" then
				oView.m_OrderBtn:SetActive(true)
				return true
			end
		end
	end
end

--点击语音按钮
function CChatScrollPage.OnSpeech(self, oBtn, bPress)
	if bPress then
		printc("CChatScrollPage.OnSpeech press true")
		g_ChatCtrl.m_IsChatRecording = true
		self:StartRecord(oBtn)
		-- self:RecordTimeOut()		
	else
		printc("CChatScrollPage.OnSpeech press false")
		g_ChatCtrl.m_IsChatRecording = false
		self:EndRecord()
	end
end

--开始录音
function CChatScrollPage.StartRecord(self, oBtn)
	if not self:CheckSendLimit(self.m_CurChannel) then
		return
	end
	-- 音量级减小
	g_AudioCtrl:SetSlience()
	g_NotifyCtrl:ShowDisableWidget(true, nil, 70)
	CSpeechRecordView:CloseView()
	CSpeechRecordView:ShowView(function(oView)
		oView:SetRecordBtn(oBtn)
		oView:BeginRecord(self.m_CurChannel, nil, nil, self, 18)
	end)
end

--结束录音
function CChatScrollPage.EndRecord(self)
	-- 音量恢复
	g_AudioCtrl:ExitSlience()
	local oView = CSpeechRecordView:GetView()
	if oView then
		printc("CChatScrollPage.EndRecord, oView存在")
		if oView:EndRecord(self.m_CurChannel, nil, nil) then
			--发送语音后解除锁屏状态
			self:ShowNewMsg()
		end
	else
		printc("CChatScrollPage.EndRecord, oView不存在")
	end
end

--录音超时
function CChatScrollPage.RecordTimeOut(self)
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

--检查语音发送限制
function CChatScrollPage.CheckSendLimit(self, iChannel)
	if iChannel == define.Channel.World then
		local configTime = data.chatdata.CHATCONFIG[define.Channel.World].talk_gap
		local repTime = string.gsub(configTime, "lv", g_AttrCtrl.grade)
		local iLimitTime = tonumber(load(string.format([[return (%s)]], repTime))())
		-- local iLimitTime = math.max(120, 300 - g_AttrCtrl.grade * 2)
		local iLastTime = 0
		if g_ChatCtrl.m_LastWorldChatTime then
			iLastTime = g_ChatCtrl.m_LastWorldChatTime
		end
		local iRemain = iLimitTime - (g_TimeCtrl:GetTimeS() - iLastTime)
		if iRemain > 0 then
			g_NotifyCtrl:FloatMsg(string.format("录音失败，%d秒以后才能发言", iRemain))
			return false
		end
	end
	return true
end

--点击表情按钮
function CChatScrollPage.OnEmoji(self)
	self.m_Input.m_UIInput:RemoveFocus()
	CEmojiLinkView:ShowView(
		function(oView)
			oView:SetSendFunc(callback(self, "AppendText"))
		end
	)
end

function CChatScrollPage.OnClickShowDown(self)
	if self.m_DownBox.m_Grid:GetCount() <= 0 then
		return
	end
	self.m_DownBox:SetActive(true)
	g_UITouchCtrl:TouchOutDetect(self.m_DownBox, callback(self.m_DownBox, "SetActive", false))
end

function CChatScrollPage.OnLongChat(self)
	CLongChatView:ShowView()
end

function CChatScrollPage.OnOrgBarrageBtn(self)
	COrgBarrageSendView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

function CChatScrollPage.OnRedPacketBtn(self)
	CChatMainView:CloseView()
	CRedPacketSendSelectView:ShowView()
end

--添加链接，只能有一个链接
function CChatScrollPage.AppendText(self, s, isClearInput)
	if self.m_TipTimer then
		return
	end
	if string.match(s, "%b{}") then
		self.m_Input:ClearLink()
	end
	if isClearInput then
		self.m_Input:SetText(s)
	else
		local sOri = self.m_Input:GetText()
		self.m_Input:SetText(sOri..s)
	end
end

--帮派频道点击加入帮派
function CChatScrollPage.OnJoinOrg(self)
	g_OrgCtrl:OpenOrgView()
end

--组队频道点击组建队伍
function CChatScrollPage.OnJoinTeam(self)
	netteam.C2GSCreateTeam()
end

--点击关闭@玩家的说明tips
function CChatScrollPage.OnCloseOrgCallTips(self)
	g_ChatCtrl.m_IsOrgCallTips = true
	self.m_OrgCallTipsObj:SetActive(false)
end

return CChatScrollPage

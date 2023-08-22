local CMainMenuChatBox = class("CMainMenuChatBox", CBox)

function CMainMenuChatBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_MsgTable = self:NewUI(1, CTable)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_SizeBtn = self:NewUI(4, CButton)
	self.m_FilterBtn = self:NewUI(5, CButton)
	self.m_BgSprite = self:NewUI(7, CWidget)
	self.m_BubbleBox = self:NewUI(8, CFloatBox)
	self.m_AudioGrid = self:NewUI(9, CGrid)
	self.m_OrgAudioBtn = self:NewUI(10, CButton)
	self.m_TeamAudioBtn = self:NewUI(11, CButton)
	self.m_FriendBtn = self:NewUI(12, CButton)
	self.m_MsgAmountBtn = self:NewUI(13, CButton)
	self.m_MailUnopen = self:NewUI(14, CSprite)
	self.m_QuickAppointSpr = self:NewUI(15, CSprite)
	self.m_MasterBoxList = {}
	self.m_MasterBox1 = self:NewUI(16, CBox)
	self.m_MasterBox2 = self:NewUI(17, CBox)
	self.m_JieBaiBtn = self:NewUI(18, CSprite)
	self.m_JieBaiRedPoint = self:NewUI(19, CSprite)
	self.m_MasterBox1.m_IconSp = self.m_MasterBox1:NewUI(1, CSprite)
	self.m_MasterBox1.m_MarkSp = self.m_MasterBox1:NewUI(2, CSprite)
	self.m_MasterBox1.m_RedPointSp = self.m_MasterBox1:NewUI(3, CSprite)
	self.m_MasterBox2.m_IconSp = self.m_MasterBox2:NewUI(1, CSprite)
	self.m_MasterBox2.m_MarkSp = self.m_MasterBox2:NewUI(2, CSprite)
	self.m_MasterBox2.m_RedPointSp = self.m_MasterBox2:NewUI(3, CSprite)
	self.m_MasterBox1.m_IconSp.m_IgnoreCheckEffect = true
	self.m_MasterBox2.m_IconSp.m_IgnoreCheckEffect = true
	self.m_MasterBoxList[1] = self.m_MasterBox1
	self.m_MasterBoxList[2] = self.m_MasterBox2

	g_GuideCtrl:AddGuideUI("mainmenu_chat_btn", self.m_BgSprite)

	self.m_MsgList = {}
	self.m_AddCnt = 5
	self.m_CurAppendIdx = 0
	-- self.m_IsExpand = IOTools.GetClientData("mainmenu_chat_box_expand") or false
	self.m_IsExpand = false
	self.m_TabMaxCount = 20
	self.m_TableIndex = self.m_TabMaxCount 
	self:InitContent()
end

--初始化执行
function CMainMenuChatBox.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_BubbleBox:SetActive(false)
	--下边两个方法都会监听ClipMove的方法
	self.m_ScrollView:SetCullContent(self.m_MsgTable, nil, nil, false, true, false)
	self.m_ScrollView:AddMoveCheck("down", self.m_MsgTable, callback(self, "ShowOldMsg"))
	self.m_SizeBtn:AddUIEvent("click", callback(self, "OnResize"))
	self.m_FilterBtn:AddUIEvent("click", callback(self, "OnFilter"))
	self.m_BgSprite:AddUIEvent("click", callback(self, "OnDragWidget"))
	self.m_OrgAudioBtn:AddUIEvent("press", callback(self, "OnSpeech", define.Channel.Org))
	self.m_TeamAudioBtn:AddUIEvent("press", callback(self, "OnSpeech", define.Channel.Team))
	self.m_FriendBtn:AddUIEvent("click", callback(self, "OpenFriendInfoView"))
	self.m_QuickAppointSpr:AddUIEvent("click", callback(self, "OnQuickAppoint"))
	self.m_MasterBox1.m_IconSp:AddUIEvent("click", callback(self, "OnClickMasterIconSp1"))
	self.m_MasterBox2.m_IconSp:AddUIEvent("click", callback(self, "OnClickMasterIconSp2"))
	self.m_JieBaiBtn:AddUIEvent("click", callback(self, "OnJieBaiBtn"))

	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_SpeechCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTeamEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_TalkCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTalkEvent"))
	g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMailEvent"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlFriendEvent"))
	g_MasterCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMasterEvent"))
	g_JieBaiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnJieBaiEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))

	self:RefreshAllMsg()
	self:RefreshSize()

	self:CheckMasterBox()
	self:CheckMasterBoxRedPoint()

	self.m_OrgAudioBtn:SetActive((g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0))
	self.m_TeamAudioBtn:SetActive(g_TeamCtrl:IsJoinTeam())
	self:RefreshMsgAmount()
	self:RefreshMailUnopen()
	self.m_AudioGrid:Reposition()
	self:RefreshQuickAppoint()
	self:CheckJieBaiBtn()
	self:CheckJieBaiRedPoint()
	g_JieBaiCtrl:AddJieBaiBtnEffect(self.m_JieBaiBtn)
end

--聊天协议和语音协议返回
function CMainMenuChatBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.AddMsg then
		local oMsg = oCtrl.m_EventData
		local list = self:GetDisplayChannel()
		if table.index(list, oMsg:GetValue("channel")) then
			table.insert(self.m_MsgList, oMsg)
			self:AddMsg(oMsg)
		end
	
	elseif oCtrl.m_EventID == define.Chat.Event.PlayAudio then
		self:RefreshText()
	
	elseif oCtrl.m_EventID == define.Chat.Event.EndPlayAudio then
		self:RefreshText()
	end
end

--组队协议返回
function CMainMenuChatBox.OnCtrlTeamEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTeam then
		self:RefreshQuickAppoint()
		self.m_TeamAudioBtn:SetActive(true)
		self.m_AudioGrid:Reposition()
	elseif oCtrl.m_EventID == define.Team.Event.DelTeam then
		self:RefreshQuickAppoint()
		self.m_TeamAudioBtn:SetActive(false)
		self.m_AudioGrid:Reposition()
		CSpeechRecordView:CloseView()
	end
end

function CMainMenuChatBox.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self.m_OrgAudioBtn:SetActive((g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0))
		self.m_AudioGrid:Reposition()
		if not self.m_OrgAudioBtn:GetActive() then
			CSpeechRecordView:CloseView()
		end

		--师徒相关
		self:CheckMasterBoxRedPoint()
	end
end

function CMainMenuChatBox.OnTalkEvent(self, oCtrl)
	self:RefreshMsgAmount()
end

function CMainMenuChatBox.OnMailEvent(self, callbackBase)
	local eventID = callbackBase.m_EventID
    if eventID == define.Mail.Event.Sort or eventID == define.Mail.Event.OpenMails or eventID == define.Mail.Event.GetDetail then
    	self:RefreshMailUnopen()
    end
end

function CMainMenuChatBox.OnCtrlFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.Update then
		self:CheckMasterBox()
	end
end

function CMainMenuChatBox.OnCtrlMasterEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Master.Event.MentoringTask then
		self:CheckMasterBoxRedPoint()
	elseif oCtrl.m_EventID == define.Master.Event.MasterList then
		self:CheckMasterBoxRedPoint()
		self:CheckMasterBox()
	end
end

function CMainMenuChatBox.OnJieBaiEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.JieBai.Event.JieBaiCreate or oCtrl.m_EventID == define.JieBai.Event.JieBaiRemove 
		or define.JieBai.Event.JieBaiInfoChange or define.JieBai.Event.JieBaiLogin
	 then
		self:CheckJieBaiBtn()
	end 

	if  oCtrl.m_EventID == define.JieBai.Event.InviteChange or oCtrl.m_EventID == define.JieBai.Event.ProtoRedPointChange then 
		self:CheckJieBaiRedPoint()
	end 

	if oCtrl.m_EventID == define.JieBai.Event.JieBaiCreate or define.JieBai.Event.JieBaiInfoChange or define.JieBai.Event.JieBaiLogin then
		g_JieBaiCtrl:AddJieBaiBtnEffect(self.m_JieBaiBtn)
	end 

	if  oCtrl.m_EventID == define.JieBai.Event.JieBaiRemove then
		g_JieBaiCtrl:DelJieBaiBtnEffect(self.m_JieBaiBtn)
	end 

end

function CMainMenuChatBox.CheckJieBaiBtn(self)
	
	self.m_JieBaiBtn:SetActive(g_JieBaiCtrl:IsJieBaiCreate() and not g_MapCtrl:IsInJieBaiMap() and not g_JieBaiCtrl:IsInForbitMap() and not self.m_IsExpand)

end

function CMainMenuChatBox.CheckJieBaiRedPoint(self)
	
	self.m_JieBaiRedPoint:SetActive(g_JieBaiCtrl:IsShowRedPoint())

end

function CMainMenuChatBox.OnMapEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.EnterScene or oCtrl.m_EventID == define.Map.Event.ShowScene then
		self:CheckJieBaiBtn()
		self:CheckJieBaiRedPoint()
	end
end

--------------以下是主界面左下角聊天框的item添加或删除-----------------
--语音协议返回更新聊天item
function CMainMenuChatBox.RefreshText(self)
	for o, oBox in ipairs(self.m_MsgTable:GetChildList()) do
		local sText = oBox.m_Label:GetRawText()
		LinkTools.ClearLinkCache(sText)
		local oSpeechLink = LinkTools.FindLink(sText, "SpeechLink")
		if oSpeechLink then
			oBox.m_Label:SetRichText(sText, oBox.m_Channel, nil, true)
		else
			oBox.m_Label:SetRichText(sText, oBox.m_Channel, nil, true)
		end
		local size = UITools.CalculateRelativeWidgetBounds(oBox.m_Label.m_Transform).size
		oBox:SetSize(size.x, size.y)
	end
end

function CMainMenuChatBox.AddMsg(self, oMsg, bAppend)
	local iTableCnt = self.m_MsgTable:GetCount()
	--TODO:避免无限增长，可以修改添加方案
	local oMsgBox = nil
	local bNeedReset = false
	if iTableCnt >= self.m_TabMaxCount then
		oMsgBox = self.m_MsgTable:GetChild(self.m_TableIndex)
		self.m_TableIndex = self.m_TableIndex - 1
		if self.m_TableIndex == 0 then
			self.m_TableIndex = self.m_TabMaxCount
		end
		oMsgBox:SetSiblingIndex(0)
		bNeedReset = true
	else
		oMsgBox = self:NewMsgBox(oMsg)
		self.m_MsgTable:AddChild(oMsgBox)
	end 
	self:RefreshMsgBox(oMsgBox, oMsg)
	local iChannel = oMsg:GetValue("channel")
	if not bAppend then
		oMsgBox:SetAsFirstSibling()
	end
	--延迟0.5s后cull
	-- if bNeedReset then
		
	-- end
	self:OnReposition()
	self.m_ScrollView:CullContentLater()
end

function CMainMenuChatBox.RefreshAllMsg(self)
	self.m_MsgTable:Clear()
	self.m_TableIndex = self.m_TabMaxCount
	self.m_CurAppendIdx = 0
	self.m_MsgList = {}
	for i, ch in ipairs(self:GetDisplayChannel()) do
		local subList = g_ChatCtrl:GetMsgList(ch)
		for i, oMsg in ipairs(subList) do
			table.insert(self.m_MsgList, oMsg)
		end
	end
	table.sort(self.m_MsgList, function(a, b) return a["pos"] < b["pos"] end)
	local len = #self.m_MsgList
	for i=len, len-self.m_AddCnt, -1 do
		local oMsg = self.m_MsgList[i]
		if oMsg then
			self:AddMsg(oMsg, true)
			self.m_CurAppendIdx = i
		else
			break
		end
	end
	self:OnReposition()
	self.m_ScrollView:ResetPosition()
end

function CMainMenuChatBox.OnReposition(self)
	self.m_MsgTable:Reposition()
	-- local function doReposition()
	-- 	if Utils.IsNil(self) then
	-- 		return
	-- 	end
	-- 	self.m_MsgTable:Reposition()
	-- end
	-- if self.m_ChatBoxRepositionTimer then
	-- 	Utils.DelTimer(self.m_ChatBoxRepositionTimer)
	-- 	self.m_ChatBoxRepositionTimer = nil
	-- end
	-- self.m_ChatBoxRepositionTimer = Utils.AddTimer(doReposition, 0.1, 0.1)
end

function CMainMenuChatBox.ShowOldMsg(self)
	local oOldMsg = self.m_MsgList[self.m_CurAppendIdx - 1]
	if oOldMsg then
		self:AddMsg(oOldMsg, true)
		self.m_CurAppendIdx = self.m_CurAppendIdx - 1
	end
end

function CMainMenuChatBox.NewMsgBox(self, oMsg)
	local oBox = self.m_BoxClone:Clone()
	oBox:SetActive(true)
	oBox.m_IsUsing = true
	oBox:AddUIEvent("click", callback(self, "OnMsgBoxSelect"))
	-- printc("主界面聊天框加入一条信息,信息所属频道:"..oBox.m_Channel)
	oBox.m_Label = oBox:NewUI(1, CLabel)
	oBox.m_ChannelLbl = oBox:NewUI(2, CLabel)
	-- oBox.m_Label:AddUIEvent("click", callback(self, "OnMsgBoxSelect"))
	return oBox
end

function CMainMenuChatBox.RefreshMsgBox(self, oBox, oMsg)
	local ichannel = oMsg:GetValue("channel")
	if ichannel == define.Channel.Bulletin or ichannel == define.Channel.Help or 
		ichannel == define.Channel.Rumour then
		ichannel = define.Channel.Sys
	end
	oBox.m_Channel = ichannel
	local oSpeechLink = LinkTools.FindLink(oMsg:GetMainMenuText(), "SpeechLink")
	if oSpeechLink then
		local oMsgStr, oChannelTag = oMsg:GetMainMenuText(true)
		oBox.m_Label:SetRichText(oMsgStr, ichannel, nil, true)
		oBox.m_ChannelLbl:SetRichText(oChannelTag)
	else
		local oMsgStr, oChannelTag = oMsg:GetMainMenuText(true)
		oBox.m_Label:SetRichText(oMsgStr, ichannel, nil, true)
		oBox.m_ChannelLbl:SetRichText(oChannelTag)
	end
	oBox.m_Label:AddUIEvent("click", callback(self, "OnMsgBoxLabelClick", oMsg, ichannel))
	local size = UITools.CalculateRelativeWidgetBounds(oBox.m_Label.m_Transform).size
	oBox:SetSize(size.x,size.y)
end

--刷新主界面好友图标上的红点通知ui
function CMainMenuChatBox.RefreshMsgAmount(self)
	g_TalkCtrl:GetRecentNotifySaveData()
	local iAmount = g_TalkCtrl:GetTotalNotify()
	if iAmount > 0 then
		self.m_MailUnopen:SetActive(false)
		self.m_MsgAmountBtn:SetActive(true)
		self.m_MsgAmountBtn:SetText(iAmount)
	else
		self.m_MsgAmountBtn:SetActive(false)
	end
end

function CMainMenuChatBox.RefreshMailUnopen(self)
	local nUnopenMail = g_MailCtrl:GetIsHasUnOpenedMails()
	if nUnopenMail then
		self.m_MsgAmountBtn:SetActive(false)
		self.m_MailUnopen:SetActive(true)
	else
		self.m_MailUnopen:SetActive(false)
	end
end

function CMainMenuChatBox.RefreshQuickAppoint(self)
	self.m_QuickAppointSpr:SetActive(g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsInTeam() and g_WarCtrl:IsWar())
end

----------------师徒相关------------

function CMainMenuChatBox.CheckMasterBox(self)
	for i = 1, 2 do
		self.m_MasterBoxList[i]:SetActive(false)
	end
	local oShifuList = g_MasterCtrl.m_MasterShifuList
	local oTudiList = g_MasterCtrl.m_MasterTudiList
	if next(oShifuList) then
		for i = 1, 2 do
			self.m_MasterBoxList[i]:SetActive(false)
			local oData = oShifuList[i]
			if oData then
				self.m_MasterBoxList[i]:SetActive(true)
				self.m_MasterBoxList[i].m_IconSp:SpriteAvatar(oData.icon)
				self.m_MasterBoxList[i].m_MarkSp:SetSpriteName("h7_shi")
				local oState = g_FriendCtrl:GetOnlineState(oData.pid)
				if oState == 0 then
					self.m_MasterBoxList[i].m_IconSp:SetGrey(true)
				else
					self.m_MasterBoxList[i].m_IconSp:SetGrey(false)
				end
				local oRecord = g_MasterCtrl:GetMasterCircuRecord(oData.pid)
				if oRecord then
					self.m_MasterBoxList[i].m_IconSp:DelEffect("Rect")
				else
					self.m_MasterBoxList[i].m_IconSp:AddEffect("Rect")
				end
			end
		end
	elseif next(oTudiList) then
		for i = 1, 2 do
			self.m_MasterBoxList[i]:SetActive(false)
			local oData = oTudiList[i]
			if oData then
				self.m_MasterBoxList[i]:SetActive(true)
				self.m_MasterBoxList[i].m_IconSp:SpriteAvatar(oData.icon)
				self.m_MasterBoxList[i].m_MarkSp:SetSpriteName("h7_tu")
				local oState = g_FriendCtrl:GetOnlineState(oData.pid)
				if oState == 0 then
					self.m_MasterBoxList[i].m_IconSp:SetGrey(true)
				else
					self.m_MasterBoxList[i].m_IconSp:SetGrey(false)
				end
				local oRecord = g_MasterCtrl:GetMasterCircuRecord(oData.pid)
				if oRecord then
					self.m_MasterBoxList[i].m_IconSp:DelEffect("Rect")
				else
					self.m_MasterBoxList[i].m_IconSp:AddEffect("Rect")
				end
			end
		end
	end
	self.m_AudioGrid:Reposition()
end

function CMainMenuChatBox.CheckMasterBoxRedPoint(self)
	for i = 1, 2 do
		self.m_MasterBoxList[i].m_RedPointSp:SetActive(false)
	end
	for k,v in pairs(g_MasterCtrl.m_MasterShifuList) do
		local oBox = self.m_MasterBoxList[k]
		if oBox then
			oBox.m_RedPointSp:SetActive(g_MasterCtrl:GetCheckPartPrize(v.pid) or g_MasterCtrl:GetResultPartPrize(v.pid, 2))
		end
	end
	for k,v in pairs(g_MasterCtrl.m_MasterTudiList) do
		local oBox = self.m_MasterBoxList[k]
		if oBox then
			oBox.m_RedPointSp:SetActive(g_MasterCtrl:GetCheckPartPrize(v.pid) or g_MasterCtrl:GetResultPartPrize(v.pid, 1))
		end
	end
end

----------------以下是点击事件------------------
function CMainMenuChatBox.OnQuickAppoint(self)
	CWarCmdSelView:ShowView()
end

function CMainMenuChatBox.OnClickMasterIconSp1(self)
	local oType = 2
	local oData = g_MasterCtrl.m_MasterShifuList[1]
	if not oData then
		oData = g_MasterCtrl.m_MasterTudiList[1]
		oType = 1
	end
	-- netmentoring.C2GSOpenMentoringTask(oType, oData.pid)
	-- netmentoring.C2GSMentoringStepResult(oType, oData.pid)
	CMasterTeachView:ShowView(function (oView)
		g_MasterCtrl:SetMasterCircuRecord(oData.pid)
		g_MasterCtrl:OnEvent(define.Master.Event.MasterList)
		oView:ShowSubPageByIndex(1)
		oView.m_CheckPart:RefreshRoleInfo(oType, oData)
		oView.m_ResultPart:RefreshRoleInfo(oType, oData)
	end)
end

function CMainMenuChatBox.OnClickMasterIconSp2(self)
	local oType = 2
	local oData = g_MasterCtrl.m_MasterShifuList[2]
	if not oData then
		oData = g_MasterCtrl.m_MasterTudiList[2]
		oType = 1
	end
	-- netmentoring.C2GSOpenMentoringTask(oType, oData.pid)
	-- netmentoring.C2GSMentoringStepResult(oType, oData.pid)
	CMasterTeachView:ShowView(function (oView)
		g_MasterCtrl:SetMasterCircuRecord(oData.pid)
		g_MasterCtrl:OnEvent(define.Master.Event.MasterList)
		oView:ShowSubPageByIndex(1)
		oView.m_CheckPart:RefreshRoleInfo(oType, oData)
		oView.m_ResultPart:RefreshRoleInfo(oType, oData)
	end)
end

function CMainMenuChatBox.OnJieBaiBtn(self)
	
	g_JieBaiCtrl:SetJieBaiBtnClickState(true)
	g_JieBaiCtrl:DelJieBaiBtnEffect(self.m_JieBaiBtn)
	g_JieBaiCtrl:ShowJieBaiView()

end

function CMainMenuChatBox.OpenFriendInfoView(self)
	local msgActive = self.m_MsgAmountBtn:GetActive()
	local mailActive = self.m_MailUnopen:GetActive()

	if msgActive and not mailActive then
		--暂时屏蔽一条消息打开聊天界面
		-- if g_TalkCtrl:GetRecentTalkRoleCount() == 1 then
		-- 	local pid = g_TalkCtrl:GetRecentTalk()
		-- 	if g_TalkCtrl:GetTotalNotify() and pid then
		-- 		CFriendInfoView:ShowView(function (oView)
		-- 		oView:ShowTalk(pid)
		-- 		end)
		-- 	end
		-- else
		-- 	CFriendInfoView:ShowView(function (oView)
		-- 		oView:ShowRecent()
		-- 	end)
		-- end
		CFriendInfoView:ShowView(function (oView)
			oView:ShowRecent()
		end)
	elseif not msgActive and mailActive then
		CFriendInfoView:ShowView(function (oView)	
			oView:ShowMail()
			local oMainView = CMainMenuView:GetView()
			oMainView.m_RB.m_QuickMsgBox.m_MailBtn:SetActive(false)
		end)

	else
		CFriendInfoView:ShowView(function (oView)
			oView:ShowRecent()
		end)
	end
end

--点击箭头按钮调整聊天框大小
function CMainMenuChatBox.OnResize(self)
	self.m_IsExpand = not self.m_IsExpand
	-- IOTools.SetClientData("mainmenu_chat_box_expand",self.m_IsExpand)
	self:RefreshSize()
	self:CheckJieBaiBtn()
end

function CMainMenuChatBox.RefreshSize(self)
	local w, _ = self:GetSize()
	local height = self.m_IsExpand and 275 or 140
	self:SetHeight(height)
	local clipH = height - 5
	--设置裁剪区域,panel的center和size
	self.m_ScrollView:SetBaseClipRegion(Vector4.New(w/2, clipH/2, w, clipH))
	--设置箭头的方向
	local flip = self.m_IsExpand and enum.UISprite.Flip.Vertically or enum.UISprite.Flip.Nothing
	self.m_SizeBtn:SetFlip(flip)
	self:SimulateOnEnable()
	--这个方法是检测移动和cull item
	self.m_ScrollView:ClipMove()
	--g_ChatCtrl:ResetBubblePos()
end

--点击打开聊天设置界面
function CMainMenuChatBox.OnFilter(self)
	CChatFilterView:ShowView()
end

--点击一个空白的区域
function CMainMenuChatBox.OnDragWidget(self)
	CChatMainView:ShowView()
end

--点击聊天框里面的item
function CMainMenuChatBox.OnMsgBoxSelect(self,oBox)
	-- printc("我点击主界面聊天框里面的信息了,频道:"..oBox.m_Channel)
	local ichannel = oBox.m_Channel
	CChatMainView:ShowView(function (oView)
		oView:SwitchChannel(ichannel)
	end)
end

function CMainMenuChatBox.OnMsgBoxLabelClick(self, oMsg, iChannel)
	if not string.match(oMsg:GetMainMenuText(), "%b{}") then
		CChatMainView:ShowView(function (oView)
			oView:SwitchChannel(iChannel)
		end)
	end
end

--获取显示的聊天频道list
function CMainMenuChatBox.GetDisplayChannel(self)
	local list = {
		define.Channel.World,
		define.Channel.Team,
		define.Channel.Org,
		define.Channel.Current,
		define.Channel.Bulletin,
		define.Channel.Help,
		-- define.Channel.Rumour,
		define.Channel.Message,
	}
	return list
end

function CMainMenuChatBox.FloatBubbleMsg(self, sMsg, targetWid)
	local oBox = self.m_BubbleBox
	local bubbleType = { [101] = "h7_talkpaopao_1",
                         [102] = "h7_talkpaopao_2",
                         [103] = "h7_talkpaopao_3",
                        }
    local sMsgWithName = string.format("#trumpet[ff9600][%s]:[2d2d2d]%s", sMsg.role_info.name,sMsg.text)
	oBox:SetActive(true)
	oBox.m_FloatLabel:SetRichText(sMsgWithName)
	oBox.m_FloatLabel:SetColor(Color.white)
	oBox.m_BgSprite:SetSpriteName(bubbleType[sMsg.bubble])
	local i = 0 
	self.m_SmsgTimer = Utils.AddTimer(function() 
		if i == 6 and self.m_SmsgTimer then
           oBox:SetActive(false)
           Utils.DelTimer(self.m_SmsgTimer)
	       self.m_SmsgTimer = nil
		end
		i = i + 1
		return true 
		end,1,0)
end

--点击语音按钮
function CMainMenuChatBox.OnSpeech(self, channel, oBtn, bPress)
	self.m_CurChannel = channel
	if bPress then
		printc("CMainMenuChatBox.OnSpeech press true")
		g_ChatCtrl.m_IsChatRecording = true
		self:StartRecord(oBtn)
		-- self:RecordTimeOut()		
	else
		printc("CMainMenuChatBox.OnSpeech press false")
		g_ChatCtrl.m_IsChatRecording = false
		self:EndRecord()
	end
end

--开始录音
function CMainMenuChatBox.StartRecord(self, oBtn)
	if not self:CheckSendLimit(self.m_CurChannel) then
		return
	end
	-- 音量级减小
	g_AudioCtrl:SetSlience()
	CSpeechRecordView:CloseView()
	CSpeechRecordView:ShowView(function(oView)
			oView:SetRecordBtn(oBtn)
			local oChatPage
			local oChatView = CChatMainView:GetView()
			if oChatView then
				oChatPage = oChatView.m_ChatPage
			end
			oView:BeginRecord(self.m_CurChannel, nil, nil, oChatPage, 18)
		end)
end

--结束录音
function CMainMenuChatBox.EndRecord(self)
	-- 音量恢复
	g_AudioCtrl:ExitSlience()
	local oView = CSpeechRecordView:GetView()
	if oView then
		printc("CMainMenuChatBox.EndRecord, oView存在")
		if oView:EndRecord(self.m_CurChannel, nil, nil) then
			--发送语音后解除锁屏状态
			local oChatView = CChatMainView:GetView()
			if oChatView then
				oChatView.m_ChatPage:ShowNewMsg()
			end
		end
	else
		printc("CMainMenuChatBox.EndRecord, oView不存在")
	end
end

--检查语音发送限制
function CMainMenuChatBox.CheckSendLimit(self, iChannel)
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

return CMainMenuChatBox

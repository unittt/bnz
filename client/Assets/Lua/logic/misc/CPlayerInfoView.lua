local CPlayerInfoView = class("CPlayerInfoView", CViewBase)

function CPlayerInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/PlayerInfoView.prefab", cb)
	-- self.m_ExtendClose = "ClickOut"
end

function CPlayerInfoView.OnCreateView(self)
	self.m_Label_03 = self:NewUI(1, CLabel)
	self.m_BtnGrid = self:NewUI(2, CGrid)
	self.m_BtnClone = self:NewUI(3, CButton)
	self.m_AvatarSpr = self:NewUI(4, CSprite)
	self.m_GradeLabel = self:NewUI(5, CLabel)
	self.m_NameLabel = self:NewUI(6, CLabel)
	self.m_SchoolSpr = self:NewUI(7, CSprite)
	self.m_IDLabel = self:NewUI(8, CLabel)
	self.m_Label_01 = self:NewUI(9, CLabel)
	self.m_Bg = self:NewUI(10, CSprite)
	self.m_Label_02 = self:NewUI(11, CLabel)
	self.m_TextEmojiBox = self:NewUI(12, CBox)
	self.m_TextEmojiBox.m_ScrollView = self.m_TextEmojiBox:NewUI(1, CScrollView)
	self.m_TextEmojiBox.m_Grid = self.m_TextEmojiBox:NewUI(2, CGrid)
	self.m_TextEmojiBox.m_BoxClone = self.m_TextEmojiBox:NewUI(3, CBox)
	self.m_TextEmojiBox.m_Bg = self.m_TextEmojiBox:NewUI(4, CSprite)
	self.m_TextEmojiBox.m_BoxClone:SetActive(false)

	self.m_Pid = nil
	self.m_OriginalW,self.m_OriginalH = self.m_Bg:GetSize()

	self.m_BtnClone:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
end

function CPlayerInfoView.OnOrgEvent(self, dCtrl)
	-- if dCtrl.m_EventID == define.Org.Event.UpdateChatBan then
	-- 	if dCtrl.m_EventData.pid == self.m_Pid then
	-- 		if dCtrl.m_EventData.flag == 1 then
	-- 			self:UpdateByIndexBtnInfo(self.m_BtnGrid:GetCount(), "取消禁言", function ()
	-- 				self:OnCancelOrgNotChat()
	-- 				CPlayerInfoView:CloseView()	
	-- 			end)
	-- 		else
	-- 			self:UpdateByIndexBtnInfo(self.m_BtnGrid:GetCount(), "禁言", function ()
	-- 				self:OnOrgNotChat()
	-- 				CPlayerInfoView:CloseView()
	-- 			end)
	-- 		end
	-- 	end
	-- end
end

function CPlayerInfoView.SetPlayerInfo(self, dInfo)
	self.m_BtnGrid:Clear()
	self.m_Pid = dInfo.pid
	self.m_Name = dInfo.name
	self.m_TeamId = dInfo.team_id
	self.m_AvatarSpr:SpriteAvatar(dInfo.icon)

	self.m_GradeLabel:SetText(tostring(dInfo.grade).."级")
	self.m_NameLabel:SetText(dInfo.name)
	self.m_SchoolSpr:SpriteSchool(dInfo.school)
	-- 靓号 暂时是隐藏的
	-- local showID = (dInfo.show_id and dInfo.show_id > 0) and dInfo.show_id or dInfo.pid
	local showID = dInfo.pid
	self.m_IDLabel:SetText(string.format("编号:%d", showID))
	if dInfo.team_id == 0 then
		self.m_Label_01:SetText("单人")
	else
		self.m_Label_01:SetText(string.format("队伍:%d/5", dInfo.team_size))
	end

	-- local data =  data.schooldata.DATA[dInfo.school]
	-- self.m_Label_02:SetText("门派:"..data.name)
	if dInfo.org_name and dInfo.org_name ~= "" then
		self.m_Label_02:SetText(dInfo.org_name)
	else
		self.m_Label_02:SetText("无")
	end
	if dInfo.position_hide == 1 then
		self.m_Label_03:SetText(dInfo.position)
	else
		self.m_Label_03:SetText("无")
	end
	self.m_BtnGrid:SetActive(self.m_Pid ~= g_AttrCtrl.pid)

	self.m_TextEmojiBox:SetActive(false)

	self:BulidBtns(dInfo)
end

function CPlayerInfoView.BulidBtns(self, dInfo)
	-- self:AddButton("PK", callback(self, "PK"))
	self:AddButton("查看名片", function() g_LinkInfoCtrl:GetAttrCardInfo(self.m_Pid) end)
	self:CreateTalkBtn()
	self:CreateFriendBtn()
	self:CreateTeamBtn(dInfo)
	
	self:CreateTextEmojiBtn()
	self:CreateFlowerBtn(dInfo)
	
	self:CreateOrgInfoBtn(dInfo)
	self:CreateOrgManagerBtn(dInfo)	
	self:CreateOrgNotChatBtn(dInfo)
	self:CreateArenaBtn()
	self:CreateMaskBtn()
	self:ResizeBg()

	-- Utils.AddTimer(callback(self, "ResizeBg"), 0.1, 0.1)
end

function CPlayerInfoView.ResizeBg(self)
	local _, cellH = self.m_BtnGrid:GetCellSize()
	local w = self.m_OriginalW
	local h = self.m_OriginalH
	if not self.m_BtnGrid:GetActive() then
		h = h - cellH*3
		self.m_Bg:SetSize(w, h+15)
		return
	end
	if self.m_BtnGrid:GetCount() > 6 then
		local row = math.ceil((self.m_BtnGrid:GetCount() - 6)/2)
		h = h + cellH*row
		self.m_Bg:SetSize(w, h+15)
	end
end

function CPlayerInfoView.AddButton(self, sText, func, bIsAutoClose, bIsSpecail)
	if bIsAutoClose == nil then
		bIsAutoClose = true
	end
	local oBtn = self.m_BtnClone:Clone(false)
	oBtn:SetActive(true)
	local function wrapclose()
		func(oBtn)
		if Utils.IsExist(self) and bIsAutoClose then
			CPlayerInfoView:CloseView()
		end
	end
	oBtn:AddUIEvent("click", wrapclose)
	-- if bIsSpecail then
	-- 	oBtn:SetSpriteName("anniu7")
	-- 	oBtn:SetText(string.format("[c][c76758]%s[-]", sText))
	-- else
	-- 	oBtn:SetText(sText)
	-- end
	oBtn:SetText(sText)
	self.m_BtnGrid:AddChild(oBtn)
end

function CPlayerInfoView.PK(self)
	netother.C2GSGMCmd(string.format("testwar {%d}", self.m_Pid))
end

--文字表情
function CPlayerInfoView.CreateTextEmojiBtn(self)
	self:AddButton("文字表情", function()
		self.m_TextEmojiBox:SetActive(not self.m_TextEmojiBox:GetActive())
		self:SetTextEmojiList() 
	end, false)
end

--赠送鲜花
function CPlayerInfoView.CreateFlowerBtn(self, dInfo)
	if g_FriendCtrl:IsMyFriend(dInfo.pid) then
		self:AddButton("赠送鲜花", function() netfriend.C2GSOpenSendFlowerUI(dInfo.pid) end)
	end
end

function CPlayerInfoView.CreateTeamBtn(self, dInfo)
	if dInfo.team_id == 0 then
		self:AddButton("邀请组队", function()
			if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.TeamInvite, self.m_Pid) then
				g_NotifyCtrl:FloatMsg("邀请太频繁，请稍后再试")
				return
			end
		 	netteam.C2GSInviteTeam(self.m_Pid, g_AttrCtrl.pid) 
		 	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.TeamInvite, self.m_Pid, 10) 
		 end)
	else
		self:AddButton("申请入队", function() netteam.C2GSApplyTeam(dInfo.team_id, 0, 0) end)
	end
end

function CPlayerInfoView.CreateTalkBtn(self)
	self:AddButton("开始聊天", function() 
		if g_FriendCtrl:IsBlackFriend(self.m_Pid) then
			g_NotifyCtrl:FloatMsg(data.frienddata.FRIENDTEXT[define.Friend.Text.ChatToBlackTips].content)
		else
			CFriendInfoView:ShowView(function (oView) oView:ShowTalk(self.m_Pid) end)
		end
		CChatMainView:CloseView()
		end)
end

function CPlayerInfoView.CreateFriendBtn(self)
	local pid = self.m_Pid
	if g_FriendCtrl:IsMyFriend(pid) then
		self:AddButton("删除好友", function() g_FriendCtrl:ApplyDelFriend(pid) end, true, true)
	else
		self:AddButton("加为好友", function() netfriend.C2GSApplyAddFriend(pid) end)
	end
end

function CPlayerInfoView.CreateMaskBtn(self)
	if g_FriendCtrl:IsBlackFriend(self.m_Pid) then
		self:AddButton("解除屏蔽", function() g_FriendCtrl:ApplyDelBlackFriend(self.m_Pid, self.m_Name) end)
	else
		self:AddButton("屏  蔽", function() g_FriendCtrl:ApplyAddBlackFriend(self.m_Pid, self.m_Name) end, true, true)		
	end
end

--创建申请入帮按钮和邀请入帮按钮
function CPlayerInfoView.CreateOrgInfoBtn(self, dInfo)
	local isOtherHasOrg = (dInfo.org_id and dInfo.org_id ~= 0)
	local isSelfHasOrg = (g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0)
	if isOtherHasOrg and not isSelfHasOrg then
		self:AddButton("申请入帮", function() g_OrgCtrl:ApplyJoinOrg(dInfo.org_id) end)
	elseif not isOtherHasOrg and isSelfHasOrg then
		self:AddButton("邀请入帮", callback(self,"InviteOrg"))
	end
end

--创建帮派禁言按钮
function CPlayerInfoView.CreateOrgNotChatBtn(self, dInfo)
	if g_AttrCtrl.org_id == 0 or dInfo.org_id ~= g_AttrCtrl.org_id then
		return
	end
	if g_AttrCtrl.org_pos >= dInfo.org_pos then
		return
	end
	local posinfo = data.orgdata.POSITIONAUTHORITY
	if posinfo[g_AttrCtrl.org_pos] then
		if next(posinfo[g_AttrCtrl.org_pos].ban_talk) == nil or posinfo[g_AttrCtrl.org_pos].ban_talk[1] == 0 then
			return
		end
	end
	if dInfo.org_chat == 0 then
		self:AddButton("禁  言", callback(self, "OnOrgNotChat"))
	else
		self:AddButton("取消禁言", callback(self,"OnCancelOrgNotChat"))
	end
end

--点击邀请入帮按钮返回
function CPlayerInfoView.InviteOrg(self)
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.OrgInvite, self.m_Pid) then
		g_NotifyCtrl:FloatMsg("道友您操作过快")
		return
	end
	netorg.C2GSInvited2Org(self.m_Pid)  	
 	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.OrgInvite, self.m_Pid, 5)
end

function CPlayerInfoView.CreateOrgManagerBtn(self, dInfo)
	--table.print(dInfo)
	if dInfo.org_id == 0 or dInfo.org_id ~= g_AttrCtrl.org_id or 
	dInfo.org_pos <= g_AttrCtrl.org_pos or g_AttrCtrl.org_pos > 3 then
		return
	end
	local iCount = self.m_BtnGrid:GetCount()
	if iCount%2 == 0 then		--确保任命在右边
		self:AddButton("踢出帮派", function() self:KickOrgMember(self.m_Pid) end, true, true)
	end
	self:AddButton("职位任命", function(oBtn) 
		COrgAppointOpView:ShowView(function(oView)
			oView:ShowExpandViewOp(dInfo)
			UITools.NearTarget(oBtn, oView.m_Bg, enum.UIAnchor.Side.Right, Vector2.New(40, 0))
			oView:SetCallback(callback(self, "OnClose"))
		end)
	end, false, true)
	if iCount%2 == 1 then
		self:AddButton("踢出帮派", function() self:KickOrgMember(self.m_Pid) end, true, true)
	end
end

function CPlayerInfoView.KickOrgMember(self, pid)
	local windowConfirmInfo = {
        title = "提示",
        msg = string.gsub(data.orgdata.TEXT[1047].content, "#role", self.m_Name),
        okStr = "确定",
        cancelStr = "取消",
        okCallback = function()
            netorg.C2GSKickMember(self.m_Pid)
        end
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo,
        function (oView)
            self.m_WinTipViwe = oView
        end
    )
end

function CPlayerInfoView.CreateArenaBtn(self)
	-- local oPlayer = g_MapCtrl:GetPlayer(self.m_Pid)
	-- if not oPlayer or not g_MapCtrl:CheckInArenaArea(oPlayer) then
	-- 	return
	-- end
	local oPlayer = g_MapCtrl:GetPlayer(self.m_Pid)
	if oPlayer and oPlayer.m_IsFight then
		self:AddButton("观  战", function ()
			netplayer.C2GSObserverWar(1, 0, self.m_Pid)
		end)
		return
	end
	self:AddButton("切  磋", function()
		local oHero = g_MapCtrl:GetHero()
		if not g_MapCtrl:CheckInArenaArea(oHero) then
			g_NotifyCtrl:FloatMsg(data.arenadata.TEXT[1005].content)
			return
		end
		local tTeam = g_MapCtrl:GetTeamInfo(self.m_TeamId)
		local function InTeam()
			if not tTeam then
				return false
			end
			for i,pid in ipairs(tTeam) do
				if pid == self.m_Pid then
					return true
				end
			end
			return false
		end
		if not InTeam() then
			nethuodong.C2GSArenaFight(g_AttrCtrl.pid, self.m_Pid)
		else
			nethuodong.C2GSArenaFight(g_AttrCtrl.pid, tTeam[1])
		end
	end)
end

function CPlayerInfoView.OnOrgNotChat(self)
	local time = data.orgdata.OTHERS[1].ban_time/3600
	local windowConfirmInfo = {
		msg				= string.format("你确定要把%s禁言%d小时吗？",self.m_Name, time),
		title			= "禁  言",
		okCallback = function ()
			netorg.C2GSChatBan(self.m_Pid, 1)
		end,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
		self.m_WinTipViwe = oView
	end)
end

function CPlayerInfoView.OnCancelOrgNotChat(self)
	netorg.C2GSChatBan(self.m_Pid, 0)
end

function CPlayerInfoView.UpdateByIndexBtnInfo(self, index, name, cb)
	local btn = self.m_BtnGrid:GetChild(index)
	btn:SetText(name)
	btn:AddUIEvent("click", cb)
end

function CPlayerInfoView.OnClose(self)
	local view = COrgAppointOpView:GetView()
	if view then
		view:OnClose()
	end
	self:CloseView()
end

------------------文字表情相关---------------------

function CPlayerInfoView.SetTextEmojiList(self)
	UITools.NearTarget(self.m_Bg, self.m_TextEmojiBox, enum.UIAnchor.Side.Right)

	local optionCount = #data.chatdata.TEXTEMOJI
	local GridList = self.m_TextEmojiBox.m_Grid:GetChildList() or {}
	local oTextEmojiBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oTextEmojiBox = self.m_TextEmojiBox.m_BoxClone:Clone(false)
				-- self.m_TextEmojiBox.m_Grid:AddChild(oOptionBtn)
			else
				oTextEmojiBox = GridList[i]
			end
			self:SetTextEmojiBox(oTextEmojiBox, data.chatdata.TEXTEMOJI[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_TextEmojiBox.m_Grid:Reposition()
	self.m_TextEmojiBox.m_ScrollView:ResetPosition()
end

function CPlayerInfoView.SetTextEmojiBox(self, oTextEmojiBox, oData)
	oTextEmojiBox:SetActive(true)
	oTextEmojiBox.m_ContentBox = oTextEmojiBox:NewUI(1, CBox)
	oTextEmojiBox.m_ContentBox.m_NameLbl = oTextEmojiBox.m_ContentBox:NewUI(1, CLabel)

	oTextEmojiBox.m_ContentBox.m_NameLbl:SetText(oData.text)
	oTextEmojiBox.m_ContentBox:AddUIEvent("click", callback(self, "OnClickTextEmoji", oData))

	self.m_TextEmojiBox.m_Grid:AddChild(oTextEmojiBox)
	self.m_TextEmojiBox.m_Grid:Reposition()
end

function CPlayerInfoView.OnClickTextEmoji(self, oData)
	local sText = string.gsub(oData.content1, "#role", "#G"..g_AttrCtrl.name.."#n")
	sText = string.gsub(sText, "#other", "#G"..self.m_Name.."#n")

	local oFriendView = CFriendInfoView:GetView()
	if oFriendView and oFriendView.m_Brief.m_TalkPart:GetActive() then
		if oFriendView.m_Brief.m_TalkPart.m_ID then
			g_TalkCtrl:AddSelfMsg(oFriendView.m_Brief.m_TalkPart.m_ID, sText)
			g_TalkCtrl:SendChat(oFriendView.m_Brief.m_TalkPart.m_ID, sText)
			self:CloseView()
			return
		end
	end

	local oView = CChatMainView:GetView()
	if g_ChatCtrl:SendMsg(sText, g_ChatCtrl:GetTextEmojiChannel()) then
		if oView then
			oView.m_ChatPage:SetChannelTip(g_ChatCtrl:GetTextEmojiChannel())
		end
	end
	--发送消息后解除锁屏状态
	if oView then
		oView.m_ChatPage:ShowNewMsg()
	end

	self:CloseView()
end

return CPlayerInfoView
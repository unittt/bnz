local CFriendMsgBox = class("CFriendMsgBox", CBox)

function CFriendMsgBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSpr = self:NewUI(1, CSprite)
	self.m_MsgLabel = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_CopyBtn = self:NewUI(4,CButton)
	self.m_MsgKuangSp = self:NewUI(5, CSprite)
	self.m_Msg = nil
	self.m_MsgText = ""

	self.m_CopyBtn:SetActive(false)
	local function hide()
		self.m_CopyBtn:SetActive(false)
	end
	self.m_MsgLabel:AddUIEvent("press", callback(self, "OnLongPressMsg"))
	self.m_CopyBtn:AddUIEvent("click", callback(self, "OnTextCopy"))

	g_TalkCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

--有复制文字按钮出现了通知返回
function CFriendMsgBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Talk.Event.CopyMsg then
		if oCtrl.m_EventData ~= self then
			self.m_CopyBtn:SetActive(false)
		end
	end
end

--设置这个聊天框的ui
function CFriendMsgBox.SetMsg(self, oMsg)
	local sText = oMsg:GetText()
	local iType = oMsg:GetType()
	local prefixText = oMsg:GetChannelPrefixText()
	self.m_MsgLabel:SetRichText(prefixText)

	local sCountText = string.gettitle(sText, 24)
	local oStr, oCount = string.gsub(sCountText, "#%d+", "")
	if oCount > 0 then
		self.m_MsgKuangSp:SetAnchorTarget(self.m_MsgLabel.m_GameObject, 0, 0, 0, 0)		
		self.m_MsgKuangSp:SetAnchor("topAnchor", 12, 1)
        self.m_MsgKuangSp:SetAnchor("bottomAnchor", -8, 0)
        if iType == define.Chat.MsgType.Self then
        	self.m_MsgKuangSp:SetAnchor("leftAnchor", -10, 0)
        	self.m_MsgKuangSp:SetAnchor("rightAnchor", 21, 1)
        else
        	self.m_MsgKuangSp:SetAnchor("leftAnchor", -16, 0)
        	self.m_MsgKuangSp:SetAnchor("rightAnchor", 10, 1)
        end       
		self.m_MsgKuangSp:ResetAndUpdateAnchors()
	else
		self.m_MsgKuangSp:SetAnchorTarget(self.m_MsgLabel.m_GameObject, 0, 0, 0, 0)
		self.m_MsgKuangSp:SetAnchor("topAnchor", 8, 1)
        self.m_MsgKuangSp:SetAnchor("bottomAnchor", -8, 0)
        if iType == define.Chat.MsgType.Self then
        	self.m_MsgKuangSp:SetAnchor("leftAnchor", -10, 0)
        	self.m_MsgKuangSp:SetAnchor("rightAnchor", 21, 1)
        else
        	self.m_MsgKuangSp:SetAnchor("leftAnchor", -16, 0)
        	self.m_MsgKuangSp:SetAnchor("rightAnchor", 10, 1)
        end
		self.m_MsgKuangSp:ResetAndUpdateAnchors()
	end

	local oStr2, oCount2 = string.gsub(sText, "#%d+", "")
	if oCount2 > 0 then
		self.m_MsgLabel:SetSpacingY(5)
		self.m_MsgKuangSp:SetAnchor("bottomAnchor", -8, 0)
		self.m_MsgKuangSp:ResetAndUpdateAnchors()
	else
		self.m_MsgLabel:SetSpacingY(1)
		self.m_MsgKuangSp:SetAnchor("bottomAnchor", -8, 0)
		self.m_MsgKuangSp:ResetAndUpdateAnchors()
	end

	UITools.NearTarget(self.m_MsgLabel, self.m_CopyBtn, enum.UIAnchor.Side.Center)

	self.m_MsgText = LinkTools.GetPrintedText(sText)

	self.m_ID = oMsg.m_ID
	local frdobj = g_FriendCtrl:GetFriend(self.m_ID)
	local icon = g_AttrCtrl.icon
	if frdobj and frdobj.icon then
		icon = frdobj.icon
	end
	local sNameDesc = self:GetPlayerName(oMsg)
	self.m_NameLabel:SetText(sNameDesc)
	self.m_IconSpr:SpriteAvatar(icon)
	self.m_IconSpr:AddUIEvent("click", callback(self, "OnAvatar"))
	local _, h = self.m_MsgLabel:GetSize()
	local cw, ch = self:GetSize()
	self:SetSize(cw, ch+math.max(h-26, 0))
	self.m_Msg = oMsg
end

--获取玩家的名字和称谓，格式：玩家名-称谓
function CFriendMsgBox.GetPlayerName(self, oMsg)
	local tTitleInfo = nil
	local sName = "【"..g_AttrCtrl.name.."】"
	local iType = oMsg:GetType()

	if iType ~= define.Chat.MsgType.Self then
		local frdobj = g_FriendCtrl:GetFriend(oMsg.m_ID)
		if frdobj and frdobj.name then
			sName = "【"..frdobj.name.."】"
		else
			sName = ""
		end
	end

	local titleConfig = data.titledata.INFO
	local channelMark = ""
	-- table.print(tTitleInfo,"聊天，我的title_info:")
	local sNameDesc = string.format("#F%s#n", sName)
	if iType == define.Chat.MsgType.Self then
		sNameDesc = string.format("#F%s#n", sName)..channelMark
	else
		sNameDesc = channelMark..string.format("#F%s#n", sName)
	end
	if tTitleInfo and next(tTitleInfo) then
		if tTitleInfo.tid and tTitleInfo.tid ~= 0 then
			if iType == define.Chat.MsgType.Self then
				sNameDesc = string.format(titleConfig[tTitleInfo.tid].text_color, titleConfig[tTitleInfo.tid].name) .. " " .. string.format("#F%s#n", sName)..channelMark
			else
				sNameDesc = channelMark..string.format("#F%s#n", sName) .. " " .. string.format(titleConfig[tTitleInfo.tid].text_color, titleConfig[tTitleInfo.tid].name)
			end
		end
		if tTitleInfo.name and tTitleInfo.name ~= "" then
			if iType == define.Chat.MsgType.Self then
				sNameDesc = string.format("#R%s#n", tTitleInfo.name) .. " " .. string.format("#F%s#n", sName)..channelMark
			else
				sNameDesc = channelMark..string.format("#F%s#n", sName) .. " " .. string.format("#R%s#n", tTitleInfo.name)
			end
		end
	end
	return sNameDesc
end

--点击这个聊天框的头像按钮
function CFriendMsgBox.OnAvatar(self)
	if self.m_ID ~= g_AttrCtrl.pid then
		netplayer.C2GSGetPlayerInfo(self.m_ID)
	end
end

--长按出现复制按钮
function CFriendMsgBox.OnLongPressMsg(self, oBtn, bPress)
	--暂时屏蔽复制按钮
	if true then
		return
	end
	
	if bPress then
		if self.m_LongPressMsgTimer then
			Utils.DelTimer(self.m_LongPressMsgTimer)
			self.m_LongPressMsgTimer = nil
		end
		local function count()
			if Utils.IsNil(self) then
				return false
			end
			self.m_CopyBtn:SetActive(true)
			g_TalkCtrl:SetCopyBtnEvent(self)
			UITools.NearTarget(self.m_MsgLabel, self.m_CopyBtn, enum.UIAnchor.Side.Center)
			return false
		end
		self.m_LongPressMsgTimer = Utils.AddTimer(count, 0, 1)
	else
		if self.m_LongPressMsgTimer then
			Utils.DelTimer(self.m_LongPressMsgTimer)
			self.m_LongPressMsgTimer = nil
		end
	end
end

--点击复制按钮
function CFriendMsgBox.OnTextCopy(self)
	-- NGUI.NGUITools.clipboard = self.m_MsgText
	C_api.Utils.SetClipBoardText(self.m_MsgText)
	self.m_CopyBtn:SetActive(false)
end
return CFriendMsgBox
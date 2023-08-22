local CFriendAudioBox = class("CFriendAudioBox", CBox)

function CFriendAudioBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSpr = self:NewUI(1, CSprite)
	self.m_MsgLabel = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_AudioSpr = self:NewUI(4, CSprite)
	self.m_ClickBox = self:NewUI(5, CSprite)
	self.m_TimeLable = self:NewUI(6, CLabel)
	self.m_AudioSpr:SetSpriteName("#500_02")
	self.m_AudioSpr:PauseSpriteAnimation()
	self.m_Msg = nil
	
	g_SpeechCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

end

--语音协议返回，改变m_AudioSpr图片的状态
function CFriendAudioBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventData ~= self.m_AudioKey then
		self.m_AudioSpr:SetSpriteName("#500_02")
		self.m_AudioSpr:PauseSpriteAnimation()
		return
	end
	
	if oCtrl.m_EventID == define.Chat.Event.PlayAudio then
		self.m_AudioSpr:SetSpriteName("#500_00")
		self.m_AudioSpr:StartSpriteAnimation()
	
	elseif oCtrl.m_EventID == define.Chat.Event.EndPlayAudio then
		self.m_AudioSpr:SetSpriteName("#500_02")
		self.m_AudioSpr:PauseSpriteAnimation()
	end
end

--根据消息来设置这条语音消息框的ui
function CFriendAudioBox.SetMsg(self, oMsg)
	local dLink = oMsg:GetAudioLink()

	local sText = oMsg:GetText()
	self.m_MsgLabel:SetRichText(dLink["sTranslate"])
	
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

	self.m_AudioKey = dLink["sKey"]

	local iTime = 1
	if dLink["iTime"] then
		iTime = tonumber(dLink["iTime"])
		if iTime > 30 then
			iTime = 30
		end
	end
	self.m_TimeLable:SetText(string.format("%d″", iTime))
	if iTime >= 30 then
		self.m_ClickBox:SetWidth(250)
	else
		if 250*(iTime/30) >= 45 then
			self.m_ClickBox:SetWidth(250*(iTime/30))
		else
			self.m_ClickBox:SetWidth(45)
		end
	end
	self.m_ClickBox:AddUIEvent("click", callback(self, "PlayAudio", dLink["sKey"]))
	self.m_MsgLabel:AddUIEvent("click", callback(self, "PlayAudio", dLink["sKey"]))

	local _, h = self.m_MsgLabel:GetSize()
	local cw, ch = self:GetSize()
	self:SetSize(cw, ch+math.max(h-26, 0))
	self.m_Msg = oMsg
end

--获取玩家的名字和称谓，格式：玩家名-称谓
function CFriendAudioBox.GetPlayerName(self, oMsg)
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

--点击这个语音消息框的语音条,播放语音,以一个key值播放
function CFriendAudioBox.PlayAudio(self, sKey)
	g_SpeechCtrl:PlayWithKey(sKey)
end

--点击这个语音消息框的头像
function CFriendAudioBox.OnAvatar(self)
	if self.m_ID ~= g_AttrCtrl.pid then
		netplayer.C2GSGetPlayerInfo(self.m_ID)
	end
end

return CFriendAudioBox
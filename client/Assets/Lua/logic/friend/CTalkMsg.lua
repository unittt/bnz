local CTalkMsg = class("CTalkMsg")

function CTalkMsg.ctor(self, id, sMsg)
	self.m_ID = id
	self.m_Msg = sMsg
end

--一条聊天记录的内容
function CTalkMsg.GetText(self)
	return self.m_Msg
end

--获取这条聊天记录的语音链接
function CTalkMsg.GetAudioLink(self)
	local dLink = LinkTools.FindLink(self:GetText(), "SpeechLink")
	return dLink
end

--一条聊天记录的内容
function CTalkMsg.GetChannelPrefixText(self)
	local text = self.m_Msg
	local color = {text = "63432c", name = "25C8FD"}
	text = string.format("[%s]%s[-]", color.text, text)
	return text
end

--这条聊天记录对应的人物pid，有自己的，也有别人的
function CTalkMsg.GetID(self)
	return self.m_ID
end

--一条聊天记录的类型,有自己的，别人的，时间的，时间的显示一个时间label
function CTalkMsg.GetType(self)
	local sender = self.m_ID
	if sender and type(sender) == type(1) then
		if sender == g_AttrCtrl.pid then
			return define.Chat.MsgType.Self
		else
			return define.Chat.MsgType.Others
		end
	else
		return define.Chat.MsgType.NoSender
	end
end

return CTalkMsg
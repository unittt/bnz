local CChatMsg = class("CChatMsg")

function CChatMsg.ctor(self, id, dMsg)
	self.m_Data = dMsg
	self.m_ID = id
end

--获取这条消息的文字
function CChatMsg.GetText(self)
	return self:GetValue("text")
end

--获取这条消息是否是跑马灯,1-跑马，0-不跑
function CChatMsg.IsHorseRace(self)
	return self:GetValue("horse_race") == 1
end

--获取这条消息的类型，自己的，别人的，时间标签和系统的
function CChatMsg.GetType(self)
	local sender = self:GetRoleInfo("pid")
	if sender then
		if sender == g_AttrCtrl.pid then
			return define.Chat.MsgType.Self
		else
			return define.Chat.MsgType.Others
		end
	else
		return define.Chat.MsgType.NoSender
	end
end

--获取这条消息的语音链接
function CChatMsg.GetAudioLink(self)
	local dLink = LinkTools.FindLink(self:GetValue("text"), "SpeechLink")
	return dLink
end

--获取这条消息的被别人@的链接
function CChatMsg.GetOrgCallLink(self)
	local dLink = LinkTools.FindLink(self:GetValue("text"), "OrgPlayerCallLink")
	return dLink
end

--获取这条消息是否是自己的或别人的消息类型
function CChatMsg.IsPalyerChat(self)
	local pid = self:GetRoleInfo("pid")
	return pid and pid~=0
end

--获取这条消息的数据，传一个key
function CChatMsg.GetValue(self, k)
	return self.m_Data[k]
end

--获取这条消息的角色的信息
function CChatMsg.GetRoleInfo(self, k)
	local dInfo = self.m_Data["role_info"]
	if dInfo then
		return dInfo[k]
	end
end

--获取这条消息的文本，加工后的，有颜色等等
function CChatMsg.GetChannelPrefixText(self, bNotNeedChannelTag)
	local text = self:GetValue("text")
	local channel = self:GetValue("channel")
	local color = {text = "63432c", name = "25C8FD"}
	if data.colorinfodata.CHAT[channel] then
		color = data.colorinfodata.CHAT[channel]["chatview"]
	end

	local sTextColor = color
	--千里传音消息在聊天界面世界频道显示时，文字颜色为绿色
	if self:GetValue("bubble") then
		sTextColor = "1e8b00"
	end

	text = string.format("[%s]%s[-]", sTextColor, text)
	--替换为聊天的专用颜色
	text = g_ChatCtrl:ReplaceColor(text)

	if table.index({define.Channel.World}, channel) and self:GetType() == define.Chat.MsgType.NoSender then
		if bNotNeedChannelTag then
			return text, channel, string.format("#chd<%d>", 101)
		else
			return string.format("#chd<%d> %s", 101, text), channel
		end
	end
	if table.index({define.Channel.World, define.Channel.Current}, channel) then
		if bNotNeedChannelTag then
			return text, channel, string.format("#chd<%d>", channel)
		else
			return text, channel
		end
	end
	if self:GetRoleInfo("pid") and self:GetRoleInfo("pid") == 0 then
		if bNotNeedChannelTag then
			return text, channel, string.format("#chd<%d>", channel)
		else
			return string.format("#chd<%d> %s", channel, text), channel
		end
	elseif self:GetRoleInfo("pid") and self:GetRoleInfo("pid") ~= 0 then
		if bNotNeedChannelTag then
			return text, channel, string.format("#chd<%d>", channel)
		else
			return text, channel
		end
	end
	if bNotNeedChannelTag then
		return text, channel, string.format("#chd<%d>", channel)
	else
		return string.format("#chd<%d> %s", channel, text), channel
	end
end

--获取这条消息的文本，加工后的，给主界面的左下聊天框使用
function CChatMsg.GetMainMenuText(self, bNotNeedChannelTag)
	local name = self:GetRoleInfo("name")
	local text = self:GetValue("text")
	local channel = self:GetValue("channel")
	if data.colorinfodata.CHAT[channel] then
		local color = data.colorinfodata.CHAT[channel]["mainmenu"]
		if color then
			if name then
				--玩家名字设置固定颜色
				name = string.format("[%s][%s\t][-]", "2dffe9", name)
			end
			text = string.format("[%s]%s[-]", color, text)
		end
	end
	--替换为主界面左下角的专用颜色
	text = g_ChatCtrl:ReplaceColor(text, true)
	local str = ""
	if name then
		if bNotNeedChannelTag then
			str = string.format("%s%s", name, text)
		else
			--暂时屏蔽单个文字的#ch
			str = string.format("#ch<%d> %s%s", channel, name, text)
		end
	else
		if bNotNeedChannelTag then
			str = string.format("%s", text)
		else
			str = string.format("#ch<%d> %s", channel, text)
		end
	end

	local colortable = {
		["#Q"] = "[e6fffe]",
		["#G"] = "[0FFF32]",
		["#O"] = "[FF7633]",
		["#K"] = "#M",
		["#L"] = "#N"
	}
	for k, v in pairs(colortable) do
		str = string.gsub(str, k, v)
	end
	if bNotNeedChannelTag then
		return str, string.format("#ch<%d>", channel)
	else
		return str
	end
end

return CChatMsg
local CChatSysMsgBox = class("CChatSysMsgBox", CBox)

function CChatSysMsgBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_MsgLabel = self:NewUI(1, CLabel)
	self.m_ChannelLbl = self:NewUI(2, CLabel)
	self.m_Msg = nil
end

function CChatSysMsgBox.SetMsg(self, oMsg)
	local sText = oMsg:GetText()
	local oMsgStr, oChannel, oChannelTag = oMsg:GetChannelPrefixText(true)
	self.m_MsgLabel:SetRichText(oMsgStr)
	if oChannelTag then
		self.m_ChannelLbl:SetRichText(oChannelTag)
	else
		self.m_ChannelLbl:SetRichText("")
	end
	local _, h = self.m_MsgLabel:GetSize()
	local cw, ch = self:GetSize()
	self:SetSize(cw, h)
	self.m_Msg = oMsg
end

return CChatSysMsgBox
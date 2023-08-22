local CFriendSysMsgBox = class("CFriendSysMsgBox", CBox)

function CFriendSysMsgBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_MsgLabel = self:NewUI(1, CLabel)
	self.m_Msg = nil
end

function CFriendSysMsgBox.SetMsg(self, oMsg)
	local sText = oMsg:GetText()
	self.m_MsgLabel:SetRichText(oMsg:GetChannelPrefixText())
	local _, h = self.m_MsgLabel:GetSize()
	local cw, ch = self:GetSize()
	self:SetSize(cw, h)
	self.m_Msg = oMsg
end

return CFriendSysMsgBox
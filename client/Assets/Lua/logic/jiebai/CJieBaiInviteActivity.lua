local CJieBaiInviteActivity = class("CJieBaiInviteActivity", CBox)

function CJieBaiInviteActivity.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Post = self:NewUI(1, CLabel)
    self.m_ChatBtn = self:NewUI(2, CSprite)
    self.m_State = self:NewUI(3, CSprite)
    --self.m_Time = self:NewUI(4, CLabel)

    self:InitContent()

end

function CJieBaiInviteActivity.InitContent(self)
    
	self.m_ChatBtn:AddUIEvent("click", callback(self, "OnClickChat"))

end

function CJieBaiInviteActivity.SetInfo(self, info)
	
	self.m_AvtivityInfo = info

	if info.state == 1 then 
		local tip = g_JieBaiCtrl:GetTextTip(1081)
		tip = string.gsub(tip, "#role",  info.inviterName)
		tip = string.gsub(tip, "#target",  info.beInviterName)
		self.m_Post:SetText(tip)
		self.m_State:SetActive(true)
		self.m_ChatBtn:SetActive(false)
	else
		local tip = g_JieBaiCtrl:GetTextTip(1082)
		tip = string.gsub(tip, "#role",  info.beInviterName)
		self.m_Post:SetText(tip)
		self.m_State:SetActive(false)
		self.m_ChatBtn:SetActive(true)
	end 

end

function CJieBaiInviteActivity.OnClickChat(self)
	


end

return CJieBaiInviteActivity
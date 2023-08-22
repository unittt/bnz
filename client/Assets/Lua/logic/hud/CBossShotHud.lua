local CBossShotHud = class("CBossShotHud", CAsynHud)

function CBossShotHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/BossWarShotHud.prefab", cb)
end

function CBossShotHud.OnCreateHud(self)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Content = self:NewUI(2, CLabel)
end

function CBossShotHud.AddMsg(self, sIcon, sMsg, time)
	self:SetActive(true)
	self.m_Icon:SpriteAvatar(sIcon)
	self.m_Content:SetText(sMsg)

	local scale = 1
	if g_WarCtrl:IsWar() then
		scale = 1.5
		g_WarCtrl:OnShowChatMsg()
	end
	self:SetLocalScale(Vector3.one*scale)

	self.m_ContentTimer = Utils.AddTimer(callback(self, "OnTimerUp"), 0, time)
end

function CBossShotHud.OnTimerUp(self, oBox)
	if self.m_ContentTimer then
		Utils.DelTimer(self.m_ContentTimer)
		self.m_ContentTimer = nil
	end

	if g_WarCtrl:IsWar() then
		g_WarCtrl:EndChatMsg()
	end
	self:SetActive(false)
	return false
end

return CBossShotHud
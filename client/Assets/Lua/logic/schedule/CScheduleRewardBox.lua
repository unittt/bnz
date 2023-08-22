local CScheduleRewardBox = class("CScheduleRewardBox", CBox)

function CScheduleRewardBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_CallBack = cb
	self.m_ItemId = 0

	self.m_Icon = self:NewUI(1, CSprite)
	self.m_BoxBg = self:NewUI(2, CSprite)
	self.m_Anount = self:NewUI(3, CLabel)
	self.m_Active = self:NewUI(4, CLabel)
	self:AddUIEvent("click", callback(self, "OnBoxClick"))
end

function CScheduleRewardBox.OnBoxClick(self)
	if self.m_ItemId then
		local config = {widget = self}
		g_WindowTipCtrl:SetWindowItemTip(self.m_ItemId, config)
	end

	if self.m_CallBack then
		self.m_CallBack()
	end
end

function CScheduleRewardBox.SetScheduleRewardInfo(self, data)
	self.m_ItemId = data.sid
	local item = DataTools.GetItemData(data.sid)
	self.m_Icon:SpriteItemShape(item.icon)
	local showAmount = data.amount > 1
	self.m_Anount:SetActive(showAmount)
	if showAmount then
		self.m_Anount:SetText(data.amount)
	end
	self.m_Active:SetText(data.point)
end

function CScheduleRewardBox.ResetScheduleReward(self)
	self.m_BoxBg:DelEffect("Rect")
	self.m_Icon:SetGrey(false)
	self:EnableTouch(true)
end

function CScheduleRewardBox.SetScheduleRewardEffect(self, showEff)
	if showEff then
		self.m_BoxBg:AddEffect("Rect")
	else
		self.m_BoxBg:DelEffect("Rect")
	end
	self.m_Icon:SetGrey(not showEff)
	self:EnableTouch(showEff)
end

return CScheduleRewardBox
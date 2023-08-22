local CCommitSummonBox = class("CCommitSummonBox", CBox)

function CCommitSummonBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_Callback = cb
	self.m_Sum = nil
	
	self.m_Icon = self:NewUI(1, CSprite)
	self.Quality = self:NewUI(2, CSprite)
	self.m_Amount = self:NewUI(3, CLabel)
	self.m_DescLbl = self:NewUI(4, CLabel)
	self.m_SelectLbl = self:NewUI(5, CLabel)
	self.m_TagSp = self:NewUI(6, CSprite)
	self.m_Amount:SetActive(false)
	self:AddUIEvent("click", callback(self, "OnClickCommitBox"))
end

function CCommitSummonBox.OnClickCommitBox(self)
	if self.m_Callback then
		self.m_Callback()
	end
	-- local config = {widget = self}
	-- g_WindowTipCtrl:SetWindowSumTip(self.m_Sum.typeid, config)
	g_LinkInfoCtrl:GetSummonInfo(g_AttrCtrl.pid, self.m_Sum.id, true)
end

function CCommitSummonBox.SetCommitSumInfo(self, sum)
	self.m_Sum = sum
	local sumInfo = DataTools.GetSummonInfo(sum.typeid)
	self.m_Icon:SpriteAvatar(sumInfo.shape)
	self.Quality:SetItemQuality(0)
	self.m_DescLbl:SetText(self.m_Sum.name.."\n评分:"..self.m_Sum.summon_score)
	self.m_SelectLbl:SetText(self.m_Sum.name.."\n评分:"..self.m_Sum.summon_score)
	self.m_TagSp:SetActive(self.m_Sum.type == 2)
end

return CCommitSummonBox
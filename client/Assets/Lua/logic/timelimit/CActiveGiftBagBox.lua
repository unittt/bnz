local CActiveGiftBagBox = class("CActiveGiftBagBox", CBox)

function CActiveGiftBagBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_BgSprite = self:NewUI(1, CSprite)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_BrightSprite = self:NewUI(3, CSprite)
	self.m_ArrowSprite = self:NewUI(4, CSprite)
	self.m_PointLabel = self:NewUI(5, CLabel)

	self.m_ExtendArrow = nil

	self:InitContent()
end

function CActiveGiftBagBox.Destroy(self)
	CBox.Destroy(self)
end

function CActiveGiftBagBox.InitContent(self)
	self.m_ArrowSprite:SetSpriteName("h7_libaojt")
end

function CActiveGiftBagBox.SetSelected(self, b)
	self.m_BgSprite:SetSelected(b)
end

function CActiveGiftBagBox.SetActiveGiftBagBoxInfo(self, index, bEnd)
	if bEnd then
		self.m_ExtendArrow = self:NewUI(6, CSprite)
		self.m_ExtendArrow:SetSpriteName("h7_libaojt")
	end

	local giftBagConfig = g_ActiveGiftBagCtrl:GetGiftBagConfig(index)
	self.m_PointLabel:SetText(giftBagConfig.point)

	local giftBagInfo = g_ActiveGiftBagCtrl:GetGiftBagInfo(index)
	local showeffect = false
	if giftBagInfo then
		if giftBagInfo.reward_state == 0 then
			self.m_ArrowSprite:SetSpriteName("h7_libaojt")
			self.m_ArrowSprite:MakePixelPerfect()
			if bEnd then
				self.m_ExtendArrow:SetSpriteName("h7_libaojt")
				self.m_ExtendArrow:MakePixelPerfect()
			end
			self.m_IconSprite:SetGrey(false)
		elseif giftBagInfo.reward_state == 1 then
			self.m_ArrowSprite:SetSpriteName("h7_libaojt_1")
			self.m_ArrowSprite:MakePixelPerfect()
			if bEnd then
				self.m_ExtendArrow:SetSpriteName("h7_libaojt_1")
				self.m_ExtendArrow:MakePixelPerfect()
			end
			self.m_IconSprite:SetGrey(false)
			showeffect = true
		elseif giftBagInfo.reward_state == 2 then
			self.m_ArrowSprite:SetSpriteName("h7_libaojt")
			self.m_ArrowSprite:MakePixelPerfect()
			if bEnd then
				self.m_ExtendArrow:SetSpriteName("h7_libaojt")
				self.m_ExtendArrow:MakePixelPerfect()
			end
			self.m_IconSprite:SetGrey(true)
		end
	else
		self.m_ArrowSprite:SetSpriteName("h7_libaojt")
			self.m_ArrowSprite:MakePixelPerfect()
		if bEnd then
			self.m_ExtendArrow:SetSpriteName("h7_libaojt")
			self.m_ExtendArrow:MakePixelPerfect()
		end
		self.m_IconSprite:SetGrey(false)
	end
	self:SetRewardEffect(showeffect)
end

function CActiveGiftBagBox.SetRewardEffect(self, b)
	if b then
		self.m_BgSprite:AddEffect("Rect")
	else
		self.m_BgSprite:DelEffect("Rect")
	end
	-- self.m_IconSprite:SetGrey(not b)
	-- self:EnableTouch(b)
end

return CActiveGiftBagBox
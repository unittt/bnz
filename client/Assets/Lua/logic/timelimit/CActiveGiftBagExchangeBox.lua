local CActiveGiftBagExchangeBox = class("CActiveGiftBagExchangeBox", CBox)

function CActiveGiftBagExchangeBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_NeedLabel = self:NewUI(1, CLabel)
	self.m_ItemBox = self:NewUI(2, CBox)
	self.m_ItemBox.m_Icon = self.m_ItemBox:NewUI(1, CSprite)
	self.m_ItemBox.m_Qulity = self.m_ItemBox:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_ExchangeBtn = self:NewUI(4, CButton)
	self.m_CloseBtn = self:NewUI(5, CSprite)
	self:InitContent()

	self.m_OnClickCallback = nil
end

function CActiveGiftBagExchangeBox.Destroy(self)
	CBox.Destroy(self)
end

function CActiveGiftBagExchangeBox.InitContent(self)
	self.m_ExchangeBtn:AddUIEvent("click", callback(self, "OnClickExchangeBtn"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	-- self.m_ItemBox:AddUIEvent("click", callback(self, "OnClickItemBox"))
end

function CActiveGiftBagExchangeBox.OnClickExchangeBtn(self)
	if self.m_OnClickCallback then
		self.m_OnClickCallback()
	end
	-- self:OnClickClose()	
end

function CActiveGiftBagExchangeBox.OnClickClose(self)
	self:SetActive(false)
end

function CActiveGiftBagExchangeBox.OnClickItemBox(self)
	local config = {widget = self}
	local reward = DataTools.GetReward("ACTIVEPOINT", self.m_SlotList[1])
	g_WindowTipCtrl:SetWindowItemTip(reward.sid, config)
end

function CActiveGiftBagExchangeBox.SetExchangeBox(self, giftIdx, callback)
	self.m_OnClickCallback = callback

	local endGiftBox = giftIdx == #data.activegiftbagdata.REWARD
	if endGiftBox then
		self.m_ItemBox.m_Qulity:SetItemQuality(4)
		self.m_ItemBox.m_Icon:SpriteItemShape(10007)
	else
		self.m_ItemBox.m_Icon:SpriteItemShape(10008)
		self.m_ItemBox.m_Qulity:SetItemQuality(1)
	end

	local curPoint = g_ActiveGiftBagCtrl.m_GiftTotalPoint
	local giftBagConfig = g_ActiveGiftBagCtrl:GetGiftBagConfig(giftIdx)
	local targetPoint = giftBagConfig.point
	local value = targetPoint - curPoint
	local tStr = string.format("当前活跃度%s\n还需%s活跃度免费领取", curPoint, value)
	self.m_NeedLabel:SetText(tStr)
	self.m_NameLabel:SetText(targetPoint .. "活跃礼包")

	local consume = value
	self.m_ExchangeBtn:SetText(consume .. "#cur_1兑换")
end

return CActiveGiftBagExchangeBox
local CActiveGiftRewardBox = class("CActiveGiftRewardBox", CBox)

function CActiveGiftRewardBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSprite = self:NewUI(1, CSprite)
	self.m_CountLabel = self:NewUI(2, CLabel)
	self.m_BorderSprite = self:NewUI(3, CSprite)
	self.m_SelSprite = self:NewUI(4, CSprite)
	self:InitContent()

	self.m_SlotList = nil
end

function CActiveGiftRewardBox.InitContent(self)
	self:AddUIEvent("click", callback(self, "OnClickRewardItem"))
end

function CActiveGiftRewardBox.OnClickRewardItem(self)
	if self.m_SlotList then
		if #self.m_SlotList > 1 then
			local rewardList = {}
			for i,v in ipairs(self.m_SlotList) do
				local reward = DataTools.GetReward("ACTIVEPOINT", v)
				table.insert(rewardList, reward)
			end

			local giftBagInfo = g_ActiveGiftBagCtrl:GetGiftBagInfo(self.m_GiftIndex)
			if giftBagInfo and giftBagInfo.reward_state == 2 then
				local args = {
					title = "可选",
	                hideBtn = true,
	                desc = "达到领取条件时，可以选择任意一样物品作为奖励",
	                items = rewardList,
	                comfirmText = "确定",
				}
				g_WindowTipCtrl:ShowItemBoxView(args)
			else
				local curIdx = g_ActiveGiftBagCtrl:GetGiftSlotRewardIndex(self.m_GiftIndex, self.m_SlotIndex)
				g_WindowTipCtrl:ShowSelectRewardItemView(rewardList, curIdx, function (idx, dItem)
                    if curIdx ~= idx then
                        nethuodong.C2GSSetActivePointGiftGridOption(self.m_GiftIndex, self.m_SlotIndex, idx)
                    end
				end)
			end
		else
			local config = {widget = self}
			local reward = DataTools.GetReward("ACTIVEPOINT", self.m_SlotList[1])
			g_WindowTipCtrl:SetWindowItemTip(reward.sid, config)
		end
	end
end

function CActiveGiftRewardBox.Destroy(self)
	CBox.Destroy(self)
end

function CActiveGiftRewardBox.SetGiftRewardBox(self, giftIdx, slotIdx, slotList)
	self.m_GiftIndex = giftIdx
	self.m_SlotIndex = slotIdx
	self.m_SlotList = slotList

	local rewardID = slotList[1]
	if #slotList > 1 then
		rewardID = g_ActiveGiftBagCtrl:GetGiftSlotRewardInifo(giftIdx, slotIdx)
	end

	local reward = DataTools.GetReward("ACTIVEPOINT", rewardID)
	local itemData = DataTools.GetItemData(reward.sid)
	self.m_IconSprite:SpriteItemShape(itemData.icon)
	self.m_BorderSprite:SetItemQuality(itemData.quality)

	local showCount = reward.amount > 1
	self.m_CountLabel:SetActive(showCount)
	if showCount then
		self.m_CountLabel:SetText(reward.amount)
	end

	self.m_SelSprite:SetActive(#slotList > 1)
end

return CActiveGiftRewardBox
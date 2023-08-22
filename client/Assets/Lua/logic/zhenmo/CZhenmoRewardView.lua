local CZhenmoRewardView = class("CZhenmoRewardView", CViewBase)

function CZhenmoRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Zhenmo/ZhenmoRewardView.prefab", cb)

	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"
end

function CZhenmoRewardView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)

	self.m_Title = self:NewUI(2, CLabel)
	self.m_Tip = self:NewUI(3, CLabel)

	self.m_RewardScroll = self:NewUI(4, CScrollView)
	self.m_RewardGrid = self:NewUI(5, CGrid)
	self.m_RewardBoxClone = self:NewUI(6, CBox)

	self.m_Btn = self:NewUI(7, CButton)

	self:InitContent()
end

function CZhenmoRewardView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_Btn:AddUIEvent("click", callback(self, "OnBtnClick"))
end

function CZhenmoRewardView.SetRewardInfo(self, rewardlist, warTime)
	local time = warTime or 0
	local timeL = g_TimeCtrl:GetLeftTimeString(time)
	local tip = string.format("通关耗时%s, 获得通关奖励", timeL)

	self.m_Tip:SetText(tip)
	self:CreateRewards(rewardlist)
end

function CZhenmoRewardView.CreateRewards(self, rewardlist)
	for i, v in ipairs(rewardlist) do
		local amount = v.amount
		local sid = v.id

		local oItem = self.m_RewardGrid:GetChild(i)
		if oItem == nil then
			oItem = self.m_RewardBoxClone:Clone()
			oItem.m_Icon = oItem:NewUI(1, CSprite)
			oItem.m_Quality = oItem:NewUI(2, CSprite)
			oItem.m_Amount = oItem:NewUI(3, CLabel)

			oItem:AddUIEvent("click", callback(self, "OnItemClick", i, sid))

			oItem:SetActive(true)
			self.m_RewardGrid:AddChild(oItem)
		end

		local itemdata = DataTools.GetItemData(sid)
		oItem.m_Icon:SpriteItemShape(itemdata.icon)
		oItem.m_Quality:SetItemQuality(itemdata.quality)
		oItem.m_Amount:SetText(amount)
	end

	self.m_RewardGrid:Reposition()
	self.m_RewardScroll:ResetPosition()
end

function CZhenmoRewardView.OnBtnClick(self)
	nettask.C2GSZhenmoSpecialReward()
	self:OnClose()
end

function CZhenmoRewardView.OnItemClick(self, idx, sid)
	local oItem = self.m_RewardGrid:GetChild(idx)

	local args = {
		widget = oItem,
	}

	g_WindowTipCtrl:SetWindowItemTip(sid, args)
end

return CZhenmoRewardView
local CItemInvestRewardView = class("CItemInvestRewardView", CViewBase)

function CItemInvestRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/TimeLimit/ItemInvestRewardView.prefab", cb)

	self.m_ExtendClose = "Black"
	self.m_InvestID = nil
end

function CItemInvestRewardView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ItemScroll = self:NewUI(2, CScrollView)
	self.m_ItemGrid = self:NewUI(3, CGrid)
	self.m_ItemBoxClone = self:NewUI(4, CBox)
	self.m_Btn = self:NewUI(5, CButton)
	self.m_TipL = self:NewUI(6, CLabel)

	self:InitContent()
end

function CItemInvestRewardView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_Btn:AddUIEvent("click", callback(self, "OnBtn"))
	g_ItemInvestCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemInvestCtrl"))
end

function CItemInvestRewardView.SetInfo(self, invest_id)
	if invest_id then
		self.m_InvestID = invest_id
	end
	local dReward = g_ItemInvestCtrl:GetItemRewardInfo(self.m_InvestID)
	local sid = dReward.sid
	local itemdata = DataTools.GetItemData(sid)

	local dPrice = dReward.price
	local bInvested = g_ItemInvestCtrl:IsItemInvested(self.m_InvestID)
	local bAllGet = true --标记是否已全部领取

	local totalAmount = 0
	for i, v in ipairs(dReward.amount) do
		totalAmount = totalAmount + v
		local oItem = self.m_ItemGrid:GetChild(i)
		if oItem == nil then
			oItem = self.m_ItemBoxClone:Clone()

			oItem.m_Icon = oItem:NewUI(1, CSprite)
			oItem.m_CountL = oItem:NewUI(2, CLabel)
			oItem.m_HookSp = oItem:NewUI(3, CSprite)
			oItem.m_DateL = oItem:NewUI(4, CLabel)
			oItem.m_Quality = oItem:NewUI(5, CSprite)

			oItem.m_HookSp:SetSpriteName("h7_yilinqu")

			oItem:AddUIEvent("click", callback(self, "OnItemClick", i, sid))
			oItem:SetActive(true)
			self.m_ItemGrid:AddChild(oItem)
		end

		oItem.m_Icon:SpriteItemShape(itemdata.icon)
		oItem.m_Quality:SetItemQuality(itemdata.quality)
		oItem.m_DateL:SetText(string.format("第%s天", i))
		oItem.m_CountL:SetText(v)

		if bInvested then
			local bGet, bDate = self:IsItemGetInDay(i)
			oItem.m_HookSp:SetActive(bGet)
			if bGet then --已领取
				oItem.m_Icon:DelEffect("Rect")
			elseif bDate then --领取日期已到, 但未领取
				oItem.m_Icon:AddEffect("Rect")
				bAllGet = false
			end
		end 
	end

	self.m_ItemGrid:Reposition()
	self.m_ItemScroll:ResetPosition()

	if bInvested then  --已投资
		self.m_Btn:SetText("一键领取") 
		self.m_TipL:SetText(string.format("你已成功投资%s，每天都可来这里领取奖励哦！", itemdata.name))
	else
		self.m_Btn:SetText(dPrice.."#cur_1")
		self.m_TipL:SetText("花费元宝投资即可在后续十天内共获得道具*"..totalAmount)
	end
	self.m_Btn:SetGrey(bInvested and bAllGet) --全部领取后按钮变灰
end

-- 返回两个参数，第一个为已领取，第二个true为领取日期已到
function CItemInvestRewardView.IsItemGetInDay(self, day)
	local sInfo = g_ItemInvestCtrl:GetItemInvestInfo(self.m_InvestID)

	local bGet, bDate = false, false
	if sInfo and sInfo[day] then
		bGet = sInfo[day].status == 2
		bDate = true
	end

	return bGet, bDate
end

function CItemInvestRewardView.OnBtn(self)
	if not self.m_InvestID or self.m_Btn:IsGrey() then
		return
	end

	local bInvested = g_ItemInvestCtrl:IsItemInvested(self.m_InvestID)
	if bInvested then
		nethuodong.C2GSItemInvestReward(self.m_InvestID) --已投资，则一键领取
	else
		nethuodong.C2GSItemInvest(self.m_InvestID) --为投资，则投资
	end

	self:CloseView()
end

-- 点击图标时，若未领取则领取之，其他情况显示道具tips
function CItemInvestRewardView.OnItemClick(self, idx, sid)
	local bGet, bDate = self:IsItemGetInDay(idx)
	if not bGet and bDate then
		nethuodong.C2GSItemInvestDayReward(self.m_InvestID, idx)
		return
	end

	local oItem = self.m_ItemGrid:GetChild(idx)
	local args = {
		widget = oItem,
	}
	g_WindowTipCtrl:SetWindowItemTip(sid, args)
end

function CItemInvestRewardView.OnItemInvestCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.ItemInvest.Event.RefreshItemInvestUnit then
		self:SetInfo()
	end
end

return CItemInvestRewardView
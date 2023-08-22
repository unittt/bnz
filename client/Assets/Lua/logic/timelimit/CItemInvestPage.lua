local CItemInvestPage = class("CItemInvestPage", CPageBase)

function CItemInvestPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CItemInvestPage.OnInitPage(self)
	self.m_ItemScroll = self:NewUI(1, CScrollView)
	self.m_ItemGrid = self:NewUI(2, CGrid)
	self.m_ItemBoxClone = self:NewUI(3, CBox)
	self.m_LeftTimeL = self:NewUI(4, CLabel)
	self.m_TimeResetL = self:NewUI(5, CLabel)
	self.m_LeftTimeTip = self:NewUI(6, CLabel)
	self.m_RuleL = self:NewUI(7, CLabel)

	self:InitContent()
end

function CItemInvestPage.OnShowPage(self)
	g_ItemInvestCtrl:SaveFirstRecord()
	g_ItemInvestCtrl:OnEvent(define.ItemInvest.Event.RefreshRedPtSpr)
end

function CItemInvestPage.InitContent(self)
	g_ItemInvestCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemInvestCtrl"))

	self:RefreshItemBox(true)
	self:UpdateHuoDongTime()

	local dText = data.instructiondata.DESC[18000]
	if dText then
		self.m_RuleL:SetText(dText.desc)
	end
	self.m_TimeResetL:SetText("[63432C]每日凌晨[1D8E00]5[-]点重置[-]")
end


function CItemInvestPage.RefreshItemBox(self, bSort)

	local dInfo
	local bSort = bSort or false
	if bSort then
		dInfo = g_ItemInvestCtrl:GetItemConfigBySort()
	else
		dInfo = g_ItemInvestCtrl:GetItemConfigNoSort()
	end

	--self.m_ItemGrid:Clear()
	for i, v in ipairs(dInfo) do
		local oItem = self.m_ItemGrid:GetChild(i)
		if oItem == nil then
			oItem = self.m_ItemBoxClone:Clone()

			oItem.m_Icon = oItem:NewUI(1, CSprite)
			oItem.m_InvestL = oItem:NewUI(2, CLabel)
			oItem.m_RewardL = oItem:NewUI(3, CLabel)
			oItem.m_GetBtn = oItem:NewUI(4, CButton)
			oItem.m_LingQuSpr = oItem:NewUI(5, CSprite)
			oItem.m_GuoQiSpr = oItem:NewUI(6, CSprite)
			oItem.m_Bg = oItem:NewUI(7, CButton, false, false)

			oItem:SetActive(true)
			oItem.m_GetBtn:AddUIEvent("click", callback(self, "OnItemClick", i, v.invest_id))
			oItem.m_Bg:AddUIEvent("click", callback(self, "OnItemClick", i, v.invest_id))
			self.m_ItemGrid:AddChild(oItem)
		end
		self:SetItemInfo(oItem, v)
	end

	self.m_ItemGrid:Reposition()
	--self.m_ItemScroll:ResetPosition()
end

function CItemInvestPage.SetItemInfo(self, oItem, info)
	local id = info.invest_id
	local itemdata = DataTools.GetItemData(info.sid)
	local totalAmount = g_ItemInvestCtrl:GetRewardTotalAmount(id)
	oItem.m_Icon:SpriteItemShape(itemdata.icon)

	local bItemInvested = g_ItemInvestCtrl:IsItemInvested(id) --是否投资
	local bRewardAllGet = g_ItemInvestCtrl:IsRewardAllGet(id) --是否全部领取
	local bInvestTimeEnd = g_ItemInvestCtrl:IsInvestTimeEnd() --投资时间是否结束

	if bItemInvested then --已投资
		if g_ItemInvestCtrl:IsRewardGet(id) and not bRewardAllGet then ----当天之前的奖励是否已领取
			local amount = g_ItemInvestCtrl:GetNextDayRewardAmount(id)
			oItem.m_InvestL:SetText("[63432C]明天可领取[-]")
			oItem.m_RewardL:SetText("[63432C]"..itemdata.name.."*[b]"..amount.."[-]")
		else --有未领的
			oItem.m_InvestL:SetText("")
			oItem.m_RewardL:SetText("")
		end
	else --未投资
		oItem.m_InvestL:SetText(string.format("[63432C]投资[b]%s[-]#cur_1", info.price))
		oItem.m_RewardL:SetText(string.format("[63432C]获%s*[b]%s[-]", itemdata.name, totalAmount))
		if bInvestTimeEnd then
			oItem.m_InvestL:SetText("")
			oItem.m_RewardL:SetText("")
		end
		oItem.m_Icon:SetGrey(bInvestTimeEnd)
		oItem.m_Bg:SetGrey(bInvestTimeEnd)
	end

	oItem.m_LingQuSpr:SetActive(bItemInvested and bRewardAllGet)
	oItem.m_GuoQiSpr:SetActive(not bItemInvested and bInvestTimeEnd)
	oItem.m_GetBtn:SetActive(bItemInvested and not g_ItemInvestCtrl:IsRewardGet(id))
end

function CItemInvestPage.UpdateHuoDongTime(self)
	local timeS, lefttime = g_TimeCtrl:GetTimeS()
	if g_ItemInvestCtrl.m_InvestTime - timeS > 0 then
		lefttime = g_ItemInvestCtrl.m_InvestTime - timeS
	elseif g_ItemInvestCtrl.m_RewardTime - timeS > 0 then
		lefttime = g_ItemInvestCtrl.m_RewardTime - timeS
	else
	 	lefttime = 0
	end

	local cb = function(time)
	    if time then 
	        self.m_LeftTimeL:SetText(time)
	    end 
	end

	g_TimeCtrl:StartCountDown(self, lefttime, 1, cb)
	
	if g_ItemInvestCtrl.m_State == 1 then
		self.m_LeftTimeTip:SetText("[63432C]投资剩余时间:[-]")
	elseif g_ItemInvestCtrl.m_State == 2 then
		self.m_LeftTimeTip:SetText("[63432C]领取剩余时间:[-]")
	end
end

function CItemInvestPage.OnItemClick(self, idx, invest_id)
	if not invest_id then
		return
	end

	local oItem = self.m_ItemGrid:GetChild(idx)
	if oItem.m_Icon:IsGrey() then
		return
	end

	CItemInvestRewardView:ShowView(function(oView)
		oView:SetInfo(invest_id)
	end)
end

function CItemInvestPage.OnItemInvestCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.ItemInvest.Event.RefreshItemInvestUnit then
		self:RefreshItemBox()
	elseif oCtrl.m_EventID == define.ItemInvest.Event.RefreshItemInvestState then
		if g_ItemInvestCtrl.m_State == 2 then
			self.m_LeftTimeTip:SetText("[63432C]领取剩余时间:[-]")
		end
		self:RefreshItemBox()
	end
end

function CItemInvestPage.Destroy(self)
	if self.m_Timer then
		 Utils.DelTimer(self.m_Timer)
	end
end

return CItemInvestPage
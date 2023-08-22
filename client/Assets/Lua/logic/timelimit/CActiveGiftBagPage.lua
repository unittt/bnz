local CActiveGiftBagPage = class("CActiveGiftBagPage", CPageBase)

function CActiveGiftBagPage.ctor(self, cb)
	CPageBase.ctor(self, cb)

	self.m_CumulativeLabel = self:NewUI(1, CLabel)
	self.m_CDTimeLabel = self:NewUI(2, CLabel)
	self.m_TotalLabel = self:NewUI(3, CLabel)
	self.m_ActivePointSlider = self:NewUI(4, CSlider)
	self.m_RewardGroup = self:NewUI(5, CObject)
	self.m_RewardBoxList = {}
	self.m_RewardGroup:InitChild(function (obj, index)
		local oBox = CActiveGiftBagBox.New(obj)
		oBox:AddUIEvent("click", callback(self, "OnClickGiftBagBox", index))
		self.m_RewardBoxList[index] = oBox
	end)
	self.m_RewardBtn = self:NewUI(6, CButton, true, false)
	self.m_RewardBoxGrid = self:NewUI(7, CGrid)
	self.m_RewardBoxClone = self:NewUI(8, CActiveGiftRewardBox)
	self.m_RewardBoxClone:SetActive(false)
	self.m_GiftBagExchangeBox = self:NewUI(9, CActiveGiftBagExchangeBox)
	self.m_GiftBagExchangeBox:SetActive(false)

	self.m_SelectedGiftIdx = 0
	self.m_MultiItemList = {}
end

function CActiveGiftBagPage.OnInitPage(self)
	nethuodong.C2GSOpenActivePointGiftView()
	self:RefreshEventStart()

	local stallIndex = g_ActiveGiftBagCtrl:GetShowGiftBagSelectIndex()
	table.print(stallIndex)
	self.m_RewardBoxList[stallIndex]:SetSelected(true)
	self:OnClickGiftBagBox(stallIndex)
	self:RefreshEventGiftsInfoChanged()

	self.m_RewardBtn:AddUIEvent("click", callback(self, "OnClickRewardBtn"))
	g_ActiveGiftBagCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CActiveGiftBagPage.Destroy(self)
	g_TimeCtrl:DelTimer(self)
	CPageBase.Destroy(self)
end

function CActiveGiftBagPage.OnClickGiftBagBox(self, index)
	if self.m_SelectedGiftIdx == index then
		return
	end
	self.m_SelectedGiftIdx = index
	self:RefreshCumulative(index)
	self:RefreshGiftRewardGrid(index)
	self:RefreshGiftRewardBtn(index)
end

function CActiveGiftBagPage.RefreshCumulative(self, index)
	local giftRewardInfo = data.activegiftbagdata.REWARD[index]
	self.m_CumulativeLabel:SetText("活跃度累计达：" .. giftRewardInfo.point)
end

function CActiveGiftBagPage.RefreshGiftRewardGrid(self, index)
	self.m_MultiItemList = {}
	local giftBagSlotList = g_ActiveGiftBagCtrl:GetGiftSlotList(index)
	local giftBagBoxList = self.m_RewardBoxGrid:GetChildList()
	local oBox = nil
	for i,v in ipairs(giftBagSlotList) do
		-- 检查可选
		self:CheckGiftMultiItem(v, i)

		if i > #giftBagBoxList then
			oBox = self.m_RewardBoxClone:Clone()
			self.m_RewardBoxGrid:AddChild(oBox)
		else
			oBox = giftBagBoxList[i]
		end
		oBox:SetGiftRewardBox(index, i, v)
		oBox:SetActive(true)
	end
	for i=#giftBagSlotList+1,#giftBagBoxList do
		giftBagBoxList[i]:SetActive(false)
	end
	self.m_RewardBoxGrid:Reposition()
end

function CActiveGiftBagPage.CheckGiftMultiItem(self, slot, idx)
	if #slot > 1 then
		local slotInfo = {slot = slot, index = idx}
		table.insert(self.m_MultiItemList, slotInfo)
	end
end

function CActiveGiftBagPage.RefreshGiftRewardBtn(self, index)
	local spriteName = "h7_an_2"
	local btnName = "我要兑换"

	local opening = g_ActiveGiftBagCtrl:GetCDTime() > 0
	if opening then
		local giftBagInfo = g_ActiveGiftBagCtrl:GetGiftBagInfo(index)
		if giftBagInfo then
			if giftBagInfo.reward_state == 0 then
				spriteName = "h7_an_2"
				btnName = "我要兑换"
			elseif giftBagInfo.reward_state == 1 then
				spriteName = "h7_an_2"
				btnName = "免费领取"
			elseif giftBagInfo.reward_state == 2 then
				spriteName = "h7_an_5"
				btnName = "已领取"
			end
		end
	end
	
	self.m_RewardBtn:SetSpriteName(spriteName)
	self.m_RewardBtn:SetText(btnName)

	local giftBagInfo = g_ActiveGiftBagCtrl:GetGiftBagInfo(index)
	if giftBagInfo and giftBagInfo.reward_state == 1 then
		self.m_RewardBtn:AddEffect("RedDot", 20, Vector2(-15, -15))
	else
		self.m_RewardBtn:DelEffect("RedDot")
	end
end

-- 领取、兑换前需选择可选的物品
function CActiveGiftBagPage.OnSureRewardLogic(self, callback)
	if not callback then
		printerror("程序参数错误,务必传callback")
		return
	end

	local iTotal = #self.m_MultiItemList
	if iTotal > 0 then
	    local iRc = 1
	    local slotInfo = self.m_MultiItemList[iRc]
	    local slot = slotInfo.slot
	    local index = slotInfo.index
		local iCurIdx = g_ActiveGiftBagCtrl:GetGiftSlotRewardIndex(self.m_SelectedGiftIdx, index)

	    local items = {}
		for i,v in ipairs(slot) do
			local reward = DataTools.GetReward("ACTIVEPOINT", v)
			table.insert(items, reward)
		end

	    local function cb(idx)
	        if idx ~= iCurIdx then
	            nethuodong.C2GSSetActivePointGiftGridOption(self.m_SelectedGiftIdx, index, idx)
	        end
	        if iRc >= iTotal then
	        	callback()
	        else
	            iRc = iRc + 1
	            slotInfo = self.m_MultiItemList[iRc]
	            slot = slotInfo.slot
	            iCurIdx = slotInfo.index or 1
	            Utils.AddTimer(function()
	                if Utils.IsNil(self) then return end
	                for i,v in ipairs(slot) do
						local reward = DataTools.GetReward("ACTIVEPOINT", v)
						table.insert(items, reward)
					end
	                g_WindowTipCtrl:ShowSelectRewardItemView(items, iCurIdx, cb)
	            end, 0, 0)
	        end
	    end
	    g_WindowTipCtrl:ShowSelectRewardItemView(items, iCurIdx, cb)
	else
	    callback()
	end
end

--事件
function CActiveGiftBagPage.OnClickRewardBtn(self)
	local opening = g_ActiveGiftBagCtrl:GetCDTime() > 0
	if opening then
		local giftBagInfo = g_ActiveGiftBagCtrl:GetGiftBagInfo(self.m_SelectedGiftIdx)
		if giftBagInfo then
			if giftBagInfo.reward_state == 0 then
				self.m_GiftBagExchangeBox:SetActive(true)
				self.m_GiftBagExchangeBox:SetExchangeBox(self.m_SelectedGiftIdx, function ()
					self:OnSureRewardLogic(function ()
						nethuodong.C2GSGetActivePointGiftByGoldCoin(self.m_SelectedGiftIdx)
						self.m_GiftBagExchangeBox:SetActive(false)
					end)
				end)
			elseif giftBagInfo.reward_state == 1 then
				self:OnSureRewardLogic(function ()
					nethuodong.C2GSGetActivePointGift(self.m_SelectedGiftIdx)
				end)
			elseif giftBagInfo.reward_state == 2 then
				g_NotifyCtrl:FloatMsg("已领取该奖励")
			end
		else
			self.m_GiftBagExchangeBox:SetActive(true)
			self.m_GiftBagExchangeBox:SetExchangeBox(self.m_SelectedGiftIdx, function ()
				self:OnSureRewardLogic(function ()
					nethuodong.C2GSGetActivePointGiftByGoldCoin(self.m_SelectedGiftIdx)
					self.m_GiftBagExchangeBox:SetActive(false)
				end)
			end)
		end
	else
		g_NotifyCtrl:FloatMsg("活动已结束")
	end
end

function CActiveGiftBagPage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ActiveGiftBag.Event.ActiveGiftBagStart then
		self:RefreshEventStart()
	elseif oCtrl.m_EventID == define.ActiveGiftBag.Event.ActiveGiftBagInfoChanged then
		self:RefreshEventGiftsInfoChanged()
		self:RefreshGiftRewardBtn(self.m_SelectedGiftIdx)
	elseif oCtrl.m_EventID == define.ActiveGiftBag.Event.ActiveGiftBagSlotChanged then
		self:RefreshGiftRewardGrid(self.m_SelectedGiftIdx)
	elseif oCtrl.m_EventID == define.ActiveGiftBag.Event.ActiveGiftBagTotalPointChanged then
		self:RefreshEventActivePointChanged()
	elseif oCtrl.m_EventID == define.ActiveGiftBag.Event.ActiveGiftBagEnd then
		self:RefreshEventEnd()	
	end
end

function CActiveGiftBagPage.RefreshEventStart(self)
	local timeSpan = g_ActiveGiftBagCtrl:GetCDTime()
	if timeSpan <= 0 then
		local config = data.activegiftbagdata.CONFIG
		timeSpan = 3 * 86400
	end
	
	g_TimeCtrl:StartCountDown(self, timeSpan, 1, function (sTime, iTime)
		if iTime <= 0 then
			g_ActiveGiftBagCtrl:OnEvent(define.ActiveGiftBag.Event.ActiveGiftBagTimeOut)
            return false
        end
        self.m_CDTimeLabel:SetText("[63432C]活动剩余时间:[-][1D8E00]" .. sTime)
	end)
end

function CActiveGiftBagPage.GetIntPart(self, f)
	if f <= 0 then
		return math.ceil(f)
	end
	if math.ceil(f) == f then
		f = math.ceil(f)
	else
		f = math.ceil(f) - 1
	end
	return f
end

-- 信息变更刷新UI
function CActiveGiftBagPage.RefreshEventGiftsInfoChanged(self)
	for i,v in ipairs(self.m_RewardBoxList) do
		v:SetActiveGiftBagBoxInfo(i, i == #self.m_RewardBoxList)
	end
end

function CActiveGiftBagPage.RefreshEventActivePointChanged(self)
	self.m_TotalLabel:SetText(g_ActiveGiftBagCtrl.m_GiftTotalPoint)
	local progress = g_ActiveGiftBagCtrl.m_GiftTotalPoint*0.001
	self.m_ActivePointSlider:SetValue(progress)
end

function CActiveGiftBagPage.RefreshEventEnd(self)
	-- 活动结束，刷新
	printc("活动结束，刷新UI")
end

return CActiveGiftBagPage
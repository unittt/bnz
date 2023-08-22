local CEveryDayChargeBox = class("CEveryDayChargeBox", CBox)

function CEveryDayChargeBox.ctor(self, obj)

	CBox.ctor(self, obj)

	self.m_Label1 = self:NewUI(1, CLabel)
	self.m_Label2 = self:NewUI(2, CLabel)
	self.m_RewardBtn = self:NewUI(3, CButton)
	self.m_ChargeBtn = self:NewUI(4, CButton)
	self.m_CannotRewardBtn = self:NewUI(5, CSprite)
	self.m_HadrewardSpr = self:NewUI(6, CSprite)
	self.m_ItemGrid = self:NewUI(7,CGrid)
	self.m_ItemBox = self:NewUI(8, CBox)

	self.m_LocalRewardData = nil
	self.m_LocalMaxRewardCount = nil

	self:InitContent()

	self.m_ItemBox:SetActive(false)
end

function CEveryDayChargeBox.Destroy(self)
	self:RewardBtnShowRedPoint(false)
	self.m_LocalRewardData = nil
	self.m_LocalMaxRewardCount = nil

	CBox.Destroy(self)
end


function CEveryDayChargeBox.InitContent(self)
	self.m_RewardBtn:AddUIEvent("click", callback(self, "OnClickRewardBtn"))
	self.m_ChargeBtn:AddUIEvent("click", callback(self, "OnClickChargeBtn"))
	
	g_EveryDayChargeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CEveryDayChargeBox.SetLocalRewardData(self, data)
	self.m_LocalRewardData = data
	self:RefreshRewardUI()
	self:SetText1(self.m_LocalRewardData.payflag)
end

function CEveryDayChargeBox.RefreshRewardUI(self)
	-- local curDay = self:GetCurDay()
	local rewardKey = g_EveryDayChargeCtrl.m_RewardKey
	if self.m_LocalRewardData ~= nil and rewardKey then
		self:SetRewardList(rewardKey, self.m_LocalRewardData.payflag)
	end
end

function CEveryDayChargeBox.SetLocalMaxRewardCount(self, maxCount)
	self.m_LocalMaxRewardCount = maxCount
	local payFlagNumber = DataTools.GetEveryDayChargeFlagToNumber(self.m_LocalRewardData.payflag)
	if self:IsThereRewardForSamePayFlag(self.m_LocalRewardData.payflag) then
		local index = self:GetCurDayRewardIndex()
		if index == -1 or 
		   g_EveryDayChargeCtrl.m_ServerRewardList == nil or
		   g_EveryDayChargeCtrl.m_ServerRewardList[index] == nil or 
		   g_EveryDayChargeCtrl.m_ServerRewardList[index].reward == nil then
			self:RefreshText2(0, 0, self.m_LocalMaxRewardCount)
			self:RefreshButton(0, 0, self.m_LocalMaxRewardCount)
		else
			if g_EveryDayChargeCtrl.m_ServerRewardList[index].rewarded == nil then
				self:RefreshButton(g_EveryDayChargeCtrl.m_ServerRewardList[index].reward, 0, self.m_LocalMaxRewardCount)
				self:RefreshText2(g_EveryDayChargeCtrl.m_ServerRewardList[index].reward, 0, self.m_LocalMaxRewardCount)
			else
				self:RefreshButton(g_EveryDayChargeCtrl.m_ServerRewardList[index].reward, g_EveryDayChargeCtrl.m_ServerRewardList[index].rewarded, self.m_LocalMaxRewardCount)
				self:RefreshText2(g_EveryDayChargeCtrl.m_ServerRewardList[index].reward, g_EveryDayChargeCtrl.m_ServerRewardList[index].rewarded, self.m_LocalMaxRewardCount)
			end
		end
	else
		self:RefreshText2(0, 0, self.m_LocalMaxRewardCount)
		self:RefreshButton(0, 0, self.m_LocalMaxRewardCount)
	end
end

function CEveryDayChargeBox.IsThereRewardForSamePayFlag(self, payFlag)
	local flagNumber = DataTools.GetEveryDayChargeFlagToNumber(payFlag)

	if g_EveryDayChargeCtrl.m_ServerRewardList == nil or table.count(g_EveryDayChargeCtrl.m_ServerRewardList) == 0 then
		return false
	end
	
	for i, v in ipairs(g_EveryDayChargeCtrl.m_ServerRewardList) do
		if tonumber(v.flag) == flagNumber then
			return true
		end
	end
	
	return false
end

function CEveryDayChargeBox.GetCurDayRewardIndex(self)
	local currDay = self:GetCurDay()
	if currDay == -1 then
		return -1
	end
	
	local flagNumber = DataTools.GetEveryDayChargeFlagToNumber(self.m_LocalRewardData.payflag)
	for i, v in ipairs(g_EveryDayChargeCtrl.m_ServerRewardList) do
		if v.day == currDay and tonumber(v.flag) == flagNumber then
			return i
		end
	end
	
	return -1
end

function CEveryDayChargeBox.GetCurDay(self)
	-- local s = g_EveryDayChargeCtrl.m_ServerEndtime - g_TimeCtrl:GetTimeS()
	-- if s <= 0 then
	-- 	return -1
	-- end
	
	-- local configTable = data.everydaychargedata.CONFIG
	-- local d = s / 86400
	-- if d > configTable[1].gameday then
	-- 	d = configTable[1].gameday
	-- end

	-- local currDay = configTable[1].gameday - self:GetIntPart(d)
	-- if currDay == 0 then
	-- 	currDay = 1
	-- end
	-- return currDay
	return g_EveryDayChargeCtrl:GetCurDay()
end

function CEveryDayChargeBox.GetIntPart(self, f)
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

function CEveryDayChargeBox.RefreshText2(self, canGetCount, hasGetCount, maxGetCount)
	if canGetCount > maxGetCount then
		canGetCount = maxGetCount
	end
			
	if hasGetCount > maxGetCount then
		hasGetCount = maxGetCount
	end	
		
	self.m_Label2:SetText("今日已领取" .. hasGetCount .. "/" .. maxGetCount .. "次")
end

function CEveryDayChargeBox.RefreshButton(self, canGetCount, hasGetCount, maxGetCount)
	if hasGetCount >= maxGetCount then
		self.m_RewardBtn:SetActive(false)
		self:RewardBtnShowRedPoint(false)
		self.m_ChargeBtn:SetActive(false)
		self.m_HadrewardSpr:SetActive(true)
	else
		if canGetCount - hasGetCount > 0 then
			self.m_RewardBtn:SetActive(true)
			self:RewardBtnShowRedPoint(true)
			self.m_ChargeBtn:SetActive(false)
			self.m_HadrewardSpr:SetActive(false)
		else
			self.m_RewardBtn:SetActive(false)
			self:RewardBtnShowRedPoint(false)
			self.m_ChargeBtn:SetActive(true)
			self.m_HadrewardSpr:SetActive(false)
		end
	end
end

function CEveryDayChargeBox.OnClickRewardItem(self, itemId, item)
	local config = {widget = item}
	g_WindowTipCtrl:SetWindowItemTip(itemId, config)
end

function CEveryDayChargeBox.OnClickRewardBtn(self)
	if self.m_LocalRewardData ~= nil then
		local curDay = self:GetCurDay()
		local flagNumber = DataTools.GetEveryDayChargeFlagToNumber(self.m_LocalRewardData.payflag)
		nethuodong.C2GSEveryDayChargeGetReward(curDay, tostring(flagNumber))
	end
end

function CEveryDayChargeBox.OnClickChargeBtn(self)
	CNpcShopMainView:ShowView(function(oView)
		oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
	end)
end


function CEveryDayChargeBox.SetRewardList(self, rewardKey, flag)
	self:HideAllRewardItems()
	
	local totalRewardItemList = DataTools.GetEveryDayChargeItemList(rewardKey, flag)
	local tempTable = {}
	for k ,v in pairs(totalRewardItemList) do 
		table.insert(tempTable, k)
	end
	table.sort(tempTable)
	
	for k, v in pairs(tempTable) do 
		local item = self.m_ItemGrid:GetChild(k)
		if item == nil then
			item = self.m_ItemBox:Clone()
			self.m_ItemGrid:AddChild(item)
		end 

		item:SetActive(true)

		item.m_icon= item:NewUI(1, CSprite)
		item.m_count = item:NewUI(2, CLabel)
		item.m_QualityBorder= item:NewUI(3, CSprite)

		local key = tempTable[k]
		local data = totalRewardItemList[key]
		if data and next(data) then
			item.m_data = data

			item.m_count:SetText( "[b]" .. data.count)	

			local iconData = DataTools.GetItemData(data.sid)
			local quality = g_ItemCtrl:GetQualityVal(iconData.id, iconData.quality or 0)

			if iconData ~= nil then 
				item.m_icon:SpriteItemShape(iconData.icon)
				if iconData.quality ~= nil then 
					item.m_QualityBorder:SetItemQuality(quality)
				end
			end

			item:AddUIEvent("click", callback(self, "OnClickRewardItem",data.sid, item))
		end
	end

	self.m_ItemGrid:Reposition()

end

function CEveryDayChargeBox.HideAllRewardItems(self)
	for k, v in pairs(self.m_ItemGrid:GetChildList()) do 
		v:SetActive(false)
	end 
end

function CEveryDayChargeBox.SetText1(self, flag)
	local number = DataTools.GetEveryDayChargeFlagToNumber(flag) * 10
	--self.m_Label1:SetText("今日单笔充值" .. number .. "元宝")
	self.m_Label1:SetText(number)
end

function CEveryDayChargeBox.RewardBtnShowRedPoint(self, b)
	-- 红点设置
	if b then
		self.m_RewardBtn:AddEffect("RedDot", 22, Vector2(-15, -17))
	else
		self.m_RewardBtn:DelEffect("RedDot")
	end
end

--事件
function CEveryDayChargeBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EveryDayCharge.Event.EveryDayChargeNotifyChangeDay then 
		self:RefreshRewardUI()
	end
end

return CEveryDayChargeBox
local CSignCtrl = class("CSignCtrl", CCtrlBase)

function CSignCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_SelectItemList = nil
	self:Clear()
end

function CSignCtrl.Clear(self)
	self.m_OpenSign = false
	self.m_extrasignincnt = nil
	self.m_rewardset = nil
	self.m_fortune = nil
	self.m_lottery = nil
	self.m_today = nil
	self.m_signincnt = nil
	self.m_signDataList = nil
end

function CSignCtrl.GS2CSetSignInfo(self, data)
	
	 self.m_extrasignincnt = data.extrasignincnt --可补签次数
	 self.m_rewardset = data.rewardset --签到奖励集id
	 self.m_fortune = data.fortune --没有默认为0
	 self.m_lottery = data.lottery --抽奖次数
	 self.m_today = data.today             --当天签到情况,  1表示当天已签  0 当天还未签
	 self.m_signincnt = data.signincnt     --已签到个数
	 self.m_Firstmonth = data.firstmonth
	 self.m_signDataList = self:HandleSignData()
	 self.m_preView = data.preView

	 -- if self.m_fortune ~= 0 then 

	 -- 	if self.isRequireSign then 

	 -- 		self.isRequireSign = false
	 -- 		--暂时屏蔽
	 -- 	--	CFortuneView:ShowView() 

	 -- 	end
	 	
	 -- end

	 self:OnEvent(define.WelFare.Event.AddSignInfo, self) 
end

--处理签到数据
function CSignCtrl.HandleSignData(self)

	local getItemReward = function (id)
		
		for k, v in ipairs(data.rewarddata.signin_item_reward) do 
			if v.idx == id then 
				return v
			end 
		end 

	end

	local config =  data.rewarddata.signin_reward_set[self.m_rewardset]
	if not config then 
		return
	end

	local signRewardList = {}

	local lReward = table.copy(config.reward)
	-- 首月签到特殊处理
	if self.m_Firstmonth == 1 then
		local lSpc = data.rewarddata.signin_firstmonth_special[1].reward
		for i, id in ipairs(lSpc) do
			lReward[i*5] = id
		end
	end

	for k, v in ipairs(lReward) do  
		local id = v
		local itemReward = getItemReward(id)
		local signItem = {}
		local sid, amount = tonumber(itemReward.sid), itemReward.amount
		if not sid then
			sid,amount = itemReward.sid:match("^(%d+)%（Value=(%d+)%）")
		end
		signItem.id = sid
		signItem.count = amount
		local iconData = DataTools.GetItemData(signItem.id)
		if iconData ~= nil then
			signItem.icon = iconData.icon
			signItem.quality = iconData.quality
		end
		signItem.isHadSign = self:IsHadSign(k)
		signItem.isCanSign = self:IsCanSign(k)
		signItem.isReSign = self:IsResign(k)
		signItem.day = k

		table.insert(signRewardList, signItem)
	end

	return signRewardList

end

function CSignCtrl.IsResign(self, k)
	
	local reSignCnt = self.m_extrasignincnt
	if not reSignCnt or reSignCnt == 0 then 
		return false
	end 

	local today = self.m_today
	local hadSignCnt = self.m_signincnt
	if today == 1 then 
		if (hadSignCnt  < k ) and ((hadSignCnt + reSignCnt) >= k) then 
			return true
		else
			return false
		end  
	elseif today == 0 then 
		if ((hadSignCnt + 1) < k ) and ((hadSignCnt + reSignCnt + 1) >= k) then 
			return true
		else
			return false
		end
	end 

end

--是否已签过
function CSignCtrl.IsHadSign(self, index)

	local hadSignCnt = self.m_signincnt
	if index <= hadSignCnt then 
		return true
	else
		return false
	end 	

end

function CSignCtrl.GetSignCount(self)
	
	return self.m_signincnt
	
end

function CSignCtrl.IsCanSign(self, index)
	
	local today = self.m_today
	if today == 1 then 
		return false
	elseif today == 0 then 
		if index == (self.m_signincnt + 1) then 
			return true
		else
			return false
		end 	
	end 

end


function CSignCtrl.GetItemId(self, index)

	local signRewardData = self.m_signRewardData
	local item = signRewardData[index]
	local itemId = 0
	if item ~= nil then 
		itemId = item.itemsid
	end
	return itemId

end

function CSignCtrl.GetItemCount(self, index)
	
	local signRewardData = self.m_signRewardData
	local  count = 0
	if signRewardData[index] ~= nil then 
		count = signRewardData[index].amount
	end
	return count

end


function CSignCtrl.IsHadRedPoint(self)
	
	local ishad = false
	if self.m_extrasignincnt ~= nil and self.m_lottery ~= nil then 

		ishad = self.m_extrasignincnt > 0 or self.m_lottery > 0

	end 

	return ishad
	
end

function CSignCtrl.ShowSignView(self)
	if g_MarryPlotCtrl:IsPlayingWeddingPlot() then
		return
	end
	
	self.m_OpenSign = true
	CWelfareView:ShowView(function(oView)
		
		-- oView:SetActive(false)
		-- Utils.AddTimer(function ()
		-- 	if Utils.IsNil(oView) then
		-- 		return
		-- 	end
		-- 	oView:SetActive(true)
			oView:ForceSelPage(define.WelFare.Tab.Sign)
		-- end, 0, 1)


	end)

end

function CSignCtrl.JudgeCanGetReward(self, id)
--背包没有该签到奖励物品并且背包满了
	-- local iOpenCnt = g_ItemCtrl:GetBagOpenCount()
	-- local itemCnt = table.count(g_ItemCtrl.m_BagItems)
	local isFull = g_ItemCtrl:IsBagFull()
	-- local itemAmount = g_ItemCtrl:GetBagItemAmountBySid(id)
--去掉六个装备
	if isFull then --and itemAmount == 0 
		return true
	else
		return false
	end
end

return CSignCtrl




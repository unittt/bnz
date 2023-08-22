local CHeShenQiFuPage = class("CHeShenQiFuPage", CPageBase)

function CHeShenQiFuPage.ctor(self, cb)
	
	CPageBase.ctor(self, cb)

	 self.m_InfoBtn = self:NewUI(1, CSprite)
	 self.m_Time = self:NewUI(2, CLabel)
	 self.m_RewardNode = self:NewUI(3, CWidget)
	 self.m_ItemBox = self:NewUI(4, CBox)
	 self.m_QifuRewardGrid = self:NewUI(6, CGrid)
	 self.m_QifuPoint = self:NewUI(7, CLabel)
	 self.m_QifuRewardItem = self:NewUI(8, CHeShenQiFuRewardBox)
	 self.m_QifuTen = self:NewUI(9, CSprite)
	 self.m_QifuOne = self:NewUI(10, CSprite) 
	 self.m_ConsumeTen = self:NewUI(11, CLabel)
	 self.m_ConsumeOne = self:NewUI(12, CLabel)
	 self.m_EffectA = self:NewUI(13, CSprite)
	 self.m_EffectB = self:NewUI(14, CSprite)

	 self.m_ItemBox:SetActive(false)
	 self.m_Time:GetParent().localPosition = Vector3.New(192,252,0)

end

function CHeShenQiFuPage.OnInitPage(self)
	self.m_HeShenTimer = nil

	self.m_CurQifuPoint = 0

	self.m_MiBaoDataList = {}

	self.m_RewardList = {}

	self.m_MiBaoConfig = data.huodongdata.HESHENQIFU_REWARD

	self:InitPoint()

	self:RefreshMiBaoData()

	self:InitMiBaoCol()

	self:RefreshMiBaoCol()

	self:InitRewardList()

	self:InitTime()

	self:InitConsume()

	self:RefreshQifuPoint()

	self:InitEffect()

	g_HeShenQiFuCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))
	self.m_QifuTen:AddUIEvent("click", callback(self, "OnQifuTen"))
	self.m_QifuOne:AddUIEvent("click", callback(self, "OnQifuOne"))
	self.m_InfoBtn:AddUIEvent("click", callback(self, "OnClickInfoBtn"))

end

function CHeShenQiFuPage.InitEffect(self)

	self.m_EffectA:AddEffect("LianHua")
	self.m_EffectA:SetActive(false)

	self.m_EffectB:AddEffect("MultLianHua")
	self.m_EffectB:SetActive(false)
	
end

function CHeShenQiFuPage.HidePage(self)
	
	CPageBase.HidePage(self)
	self.m_EffectA:SetActive(false)
	self.m_EffectB:SetActive(false) 

end

function CHeShenQiFuPage.InitPoint(self)
	
	self.m_CurQifuPoint = g_HeShenQiFuCtrl:GetPoint()

end

function CHeShenQiFuPage.InitConsume(self)
	
	local consumeConfig = data.huodongdata.HESHENQIFU_CONFIG[1]
	self.m_ConsumeOne:SetText(consumeConfig.cost1)
	self.m_ConsumeTen:SetText(consumeConfig.cost10)

end

function CHeShenQiFuPage.InitTime(self)

	local cb = function (time)
        if not time then 
            self.m_Time:SetText("活动结束")
        else
            self.m_Time:SetText(time)
        end 
    end
	
	local endTime = g_HeShenQiFuCtrl:GetEndTime()

	if endTime and endTime > 0 then 
		local leftTime = endTime - g_TimeCtrl:GetTimeS()
		g_TimeCtrl:StartCountDown(self, leftTime, 1, cb)
	end 

end

function CHeShenQiFuPage.OnEvent(self, oCtrl)

	if oCtrl.m_EventID == define.HeShenQiFu.Event.QiFuLottery then 
		local data = oCtrl.m_EventData
		local cb = function ()
			CFuyuanTreasureRewardView:ShowView(function (oView)
				local list = {}
				for k, v in ipairs(data) do 
					local  temp = {}
					temp.id = v.itemsid
					temp.amount = v.amount
					temp.baoji = v.baoji
					table.insert(list, temp)
				end 
			    oView:SetData(list)

			end)
		end
		self:RefreshEffectB(cb)
		self:QiFuEffectTimer(5)
	end 
	if oCtrl.m_EventID == define.HeShenQiFu.Event.QiFuReward then 
		self:QiFuEffectTimer(3)
		local info = oCtrl.m_EventData
		if info.point > 0 and self.m_CurQifuPoint ~= info.point then 
			self:RefreshEffectA()
		end 
		self.m_CurQifuPoint = info.point
		self:RefreshMiBaoState()
		self:RefreshMiBaoCol()
		self:RefreshQifuPoint()
	end 

end


function CHeShenQiFuPage.RefreshMiBaoData(self)
	
	for k, v in ipairs(self.m_MiBaoConfig) do 
		local infoList = {}
		infoList.Lv = k
		if self.m_MiBaoConfig[k-1] then 
			infoList.Cur = (self.m_CurQifuPoint - self.m_MiBaoConfig[k-1].degree) <= 0 and 0 or (self.m_CurQifuPoint - self.m_MiBaoConfig[k-1].degree)
			infoList.Max = v.degree - self.m_MiBaoConfig[k-1].degree
		else
			infoList.Cur = self.m_CurQifuPoint
			infoList.Max = v.degree
		end  

		self.m_MiBaoDataList[k] = infoList
	end 

end

function CHeShenQiFuPage.InitMiBaoCol(self)

	for k, v in ipairs(self.m_MiBaoConfig) do 
		local item =  self.m_QifuRewardGrid:GetChild(k)
		if not item then 
			item = self.m_QifuRewardItem:Clone()
			item:SetActive(true)
			self.m_QifuRewardGrid:AddChild(item)
		end 

		local stateList = g_HeShenQiFuCtrl:GetRewardStateList()
		local state = nil
		if stateList then 
			state = stateList[k]
		end 
		item:SetData(k, v.degree, v.reward, state)
	end 

end 

function CHeShenQiFuPage.RefreshMiBaoCol(self)

	self:RefreshMiBaoData()

	for k, v in ipairs(self.m_MiBaoDataList) do 
		local item =  self.m_QifuRewardGrid:GetChild(k)
		if not item then 
			item = self.m_QifuRewardItem:Clone()
			item:SetActive(true)
			self.m_QifuRewardGrid:AddChild(item)
		end 
		item:RefreshSlider(v)
	end 

end

function CHeShenQiFuPage.RefreshMiBaoState(self)
	
	for k, item in ipairs(self.m_QifuRewardGrid:GetChildList()) do 
		local stateList = g_HeShenQiFuCtrl:GetRewardStateList()
		local state = nil
		if stateList then 
			state = stateList[k]
		end 
		item:RefreshState(state)
	end 

end

function CHeShenQiFuPage.InitRewardList(self)

	local config = data.huodongdata.HESHENQIFU_LOTTERY
	table.sort(config, function (a, b)
		if a.rare > b.rare then 
			return true
		elseif a.rare == b.rare then 
			if a.ratio < b.ratio then 
				return true
			else
				return false
			end 
		else
			return false
		end 
	end)

	for k, v in ipairs(config) do 
		if k <= 7 then 
			local trans = self.m_RewardNode:GetChild(k)
			local item = self.m_ItemBox:Clone()
			table.insert(self.m_RewardList, item)
			item:SetActive(true)
			self:InitItemData(item, v)
			item:SetParent(trans)
			item:SetLocalPos(Vector3.one)
		end
	end 

end

function CHeShenQiFuPage.RefreshQifuPoint(self)
	
	self.m_QifuPoint:SetText(self.m_CurQifuPoint)

end

function CHeShenQiFuPage.InitItemData(self, item, info)
	
	item.m_Icon = item:NewUI(1, CSprite)
	item.m_Quality = item:NewUI(2, CSprite)

	local id = info.itemsid
	local count = info.amount

	local data = DataTools.GetItemData(id)
	if data then 
		item.m_Icon:SpriteItemShape(data.icon)
		local quality = g_ItemCtrl:GetQualityVal(id, data.quality or 0 )
		item.m_Quality:SetItemQuality(quality)

		item.m_Icon:AddUIEvent("click", function ()	
			local config = {widget = item.m_Icon}
			g_WindowTipCtrl:SetWindowItemTip(id, config)
		end)
	end 

end

function CHeShenQiFuPage.RefreshEffectB(self, cb)
	
	if self.m_EffectB:GetActive() then 
		self.m_EffectB:SetActive(false)
	end 
	self.m_EffectB:SetActive(true)
	local delay = function ()		
		if Utils.IsNil(self) then 
			return
		end 
		self.m_EffectB:SetActive(false)
		if cb then 
			cb()
		end 
	end
	if self.m_Timer then 
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end 
	self.m_Timer = Utils.AddTimer(delay, 0, 3)

end

function CHeShenQiFuPage.RefreshEffectA(self)
	
	if self.m_EffectA:GetActive() then 
		self.m_EffectA:SetActive(false)
	end 
	self.m_EffectA:SetActive(true)
	local delay = function ()
		if Utils.IsNil(self) then 
			return
		end 
		self.m_EffectA:SetActive(false)
	end
	if self.m_TimerEf then 
		Utils.DelTimer(self.m_TimerEf)
		self.m_TimerEf = nil
	end 
	self.m_TimerEf = Utils.AddTimer(delay, 0, 3)

end

function CHeShenQiFuPage.RefreshBtnState(self, b)
	self.m_QifuTen:SetGrey(b)
	self.m_QifuTen:EnableTouch(not b)
	self.m_QifuOne:SetGrey(b)
	self.m_QifuOne:EnableTouch(not b)
end

function CHeShenQiFuPage.QiFuEffectTimer(self, timeCD)
	if self.m_HeShenTimer then
		return
	end
	self:RefreshBtnState(true)
	self.m_HeShenTimer = Utils.AddTimer(function ()
		self:RefreshBtnState(false)
		self.m_HeShenTimer = nil
		return false
	end, timeCD, timeCD)
end

function CHeShenQiFuPage.OnQifuOne(self)

	local showTip = g_HeShenQiFuCtrl:IsShowTip()

	local count = data.huodongdata.HESHENQIFU_CONFIG[1].cost1
	local enough = g_AttrCtrl:GetTrueGoldCoin() >= count
	if showTip then 
		local windowConfirmInfo = {
			okCallback		= function ()
				if enough then
					g_HeShenQiFuCtrl:C2GSQiFuGetLotteryReward(1)
				else
					self:ShowChargeTip()
				end 
			end,
			okStr			= "确定",
			cancelStr		= "取消",
			msg             = "是否花费" .. tostring(count) .. "#cur_1祈福1次",
			TipBoxCb      = function (isShow)
				g_HeShenQiFuCtrl:SetTipShow(not isShow)
			end,
			pivot = enum.UIWidget.Pivot.Center,

		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		if enough then
			g_HeShenQiFuCtrl:C2GSQiFuGetLotteryReward(1)
		else
			self:ShowChargeTip()
		end
	end 

end


function CHeShenQiFuPage.OnQifuTen(self)

	local showTip = g_HeShenQiFuCtrl:IsShowTip()

	local count = data.huodongdata.HESHENQIFU_CONFIG[1].cost10

	local enough = g_AttrCtrl:GetTrueGoldCoin() >= count
	if showTip then 
		local windowConfirmInfo = {
			okCallback		= function ()
				if enough then
					g_HeShenQiFuCtrl:C2GSQiFuGetLotteryReward(10)
				else
					self:ShowChargeTip()
				end 
			end,
			okStr			= "确定",
			cancelStr		= "取消",
			msg             = "是否花费" .. tostring(count) .. "#cur_1祈福10次",
			TipBoxCb      = function (isShow)
				g_HeShenQiFuCtrl:SetTipShow(not isShow)
			end,
			pivot = enum.UIWidget.Pivot.Center,

		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		if enough then
			g_HeShenQiFuCtrl:C2GSQiFuGetLotteryReward(10)
		else
			self:ShowChargeTip()
		end 
	end 

end

function CHeShenQiFuPage.ShowChargeTip(self)
	
	local windowConfirmInfo = {
		msg = data.huodongdata.HESHENQIFU_TEXT[1004].content,
        pivot = enum.UIWidget.Pivot.Center,
		title = "提示",
		okCallback = function () 
			CNpcShopMainView:ShowView(function(oView) oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) end) 
		end,	
		okStr = "去充值",
		cancelStr = "以后再说",
		pivot = enum.UIWidget.Pivot.Center,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)

end

function CHeShenQiFuPage.OnClickInfoBtn(self)
	
	local id = define.Instruction.Config.QiFu
	if data.instructiondata.DESC[id] ~= nil then 

	    local content = {
	        title = data.instructiondata.DESC[id].title,
	        desc  = data.instructiondata.DESC[id].desc
	    }
	    g_WindowTipCtrl:SetWindowInstructionInfo(content)

	end 

end

function CHeShenQiFuPage.Destroy(self)
	if self.m_HeShenTimer then
		Utils.DelTimer(self.m_HeShenTimer)
		self.m_HeShenTimer = nil
	end
end

return CHeShenQiFuPage
local CDuanWuHuodongCtrl = class("CDuanWuHuodongCtrl", CCtrlBase)

function CDuanWuHuodongCtrl.ctor(self)

	CCtrlBase.ctor(self)


end

function CDuanWuHuodongCtrl.C2GSZongziOpenUI(self)

	nethuodong.C2GSZongziOpenUI()

end 

function CDuanWuHuodongCtrl.C2GSZongziExchange(self, type, goldcoin)

	nethuodong.C2GSZongziExchange(type, goldcoin)

end 

function CDuanWuHuodongCtrl.C2GSDuanwuQifuOpenUI(self)

	nethuodong.C2GSDuanwuQifuOpenUI()

end 

function CDuanWuHuodongCtrl.C2GSDuanwuQifuSubmit(self)

	nethuodong.C2GSDuanwuQifuSubmit()

end 

function CDuanWuHuodongCtrl.C2GSDuanwuQifuReward(self, step)

	nethuodong.C2GSDuanwuQifuReward(step)

end

 function CDuanWuHuodongCtrl.GS2CZongziGameState(self, open)

 	if open == 1 then 
 		self.m_MatchState = true
 	else
 		self:ClearMatchData()
 		self:SetFirstOpenMatchState(0)
 	end 

 	self:OnEvent(define.DuanWuHuodong.Event.MatchState)

 end 

 function CDuanWuHuodongCtrl.GS2CRefreshZongziGame(self, data)

 	self.m_MatchSweetCnt = data.zongzi1 or 0
 	self.m_MatchSaltyCnt = data.zongzi2 or 0
 	self.m_MatchStartTime = data.starttime or 0
 	self.m_MatchEndTime = data.endtime or 0
 	self.m_MatchVoteCnt = data.vote_num or 0
 	self.m_MatchVoteBuy = data.vote_buy or 0
 	self:OnEvent(define.DuanWuHuodong.Event.MatchDataChange)

 end 

 function CDuanWuHuodongCtrl.GS2CDuanwuQifuState(self, open)

 	if open == 1 then 
 		self.m_QiFuState = true
 	else
 		self:ClearQiFuData()
 		self:SetFirstOpenQiFuState(0)
 	end 
 	self:OnEvent(define.DuanWuHuodong.Event.QiFuState)

 end 

 function CDuanWuHuodongCtrl.GS2CRefreshDuanwuQifu(self, data)

 	local map = {["starttime"] = "m_QiFuStartTime", ["endtime"] = "m_QiFuEndTime", ["total"] = "m_QiFuTotal", ["reward_step"] = "m_RewardList"}
 	local dTempInfo = {}
 	if data then
 		local dDecode = g_NetCtrl:DecodeMaskData(data, "duanwuQifu")
 		table.update(dTempInfo, dDecode)
 		for k , v in pairs(dTempInfo) do
 			if self[map[k]] ~= v then
 				self[map[k]] = v
 			end
 		end
 	end

 	-- self.m_QiFuStartTime = data.starttime
 	-- self.m_QiFuEndTime = data.endtime
 	-- self.m_QiFuTotal = data.total
 	-- self.m_RewardList = data.reward_step
 	self.m_QiFuState = data and true or false
 	self:OnEvent(define.DuanWuHuodong.Event.QiFuDataChange)

 end 

 function CDuanWuHuodongCtrl.GS2CRefreshZongziGame(self, data)

 	self.m_MatchSweetCnt = data.zongzi1 or 0
 	self.m_MatchSaltyCnt = data.zongzi2 or 0
 	self.m_MatchStartTime = data.starttime or 0
 	self.m_MatchEndTime = data.endtime or 0
 	self.m_MatchVoteCnt = data.vote_num or 0
 	self.m_MatchVoteBuy = data.vote_buy or 0
 	self:OnEvent(define.DuanWuHuodong.Event.MatchDataChange)

 end 

------------------------------qifu-------------------------
function CDuanWuHuodongCtrl.IsQiFuOpenLv(self)
	
	local info = DataTools.GetViewOpenData(define.System.DuanWuQiFu)
	if info then 
		if info.p_level <= g_AttrCtrl.grade then 
			return true
		end 
	end 

end

function CDuanWuHuodongCtrl.ClearQiFuData(self)
	
	self.m_QiFuStartTime = nil
	self.m_QiFuEndTime = nil
	self.m_QiFuTotal = nil
	self.m_RewardList = nil
	self.m_QiFuState = nil

end

function CDuanWuHuodongCtrl.IsHadQiFuData(self)
	
	return self.m_QiFuEndTime and true or false

end

function CDuanWuHuodongCtrl.OpenQiFuView(self)

	CDuanWuMainView:ShowView(function(oView)
		oView:OpenQiFuView()
		end )

end 

function CDuanWuHuodongCtrl.OpenMatchView(self)

	CDuanWuMainView:ShowView(function(oView)
		oView:OpenMatchView()
		end )

end 

function CDuanWuHuodongCtrl.GetQiFuEndTime(self)

	return self.m_QiFuEndTime 

end 

function CDuanWuHuodongCtrl.IsQiFuHuoDongOpen(self)
	
	local isOpenLv = self:IsQiFuOpenLv()
	return self.m_QiFuState and isOpenLv

end

function CDuanWuHuodongCtrl.GetQiFuInfoList(self)

	local configStep = data.huodongdata.DUANWUQIFUREWARDSTEP
	local infoList = {}
	infoList.curPoint = self.m_QiFuTotal or 0
	infoList.name = "祭品"
	infoList.stepList = {}
	for k, v in ipairs(configStep) do 
		local info = {}
		info.id = v.step
		local itemInfo =  self:GetQiFuRewardInfo(v.reward)
		if itemInfo then 
			info.icon = itemInfo.icon
		end 
		info.target = v.total
		info.rewardId = v.reward
		info.hadReward = self:IsHadGetTheReward(v.step)
		info.cnt = itemInfo.cnt
		if not info.hadReward then 
			info.canReward = infoList.curPoint >= v.total
		else
			info.canReward = false
		end  
		table.insert(infoList.stepList, info)
	end 
	return infoList

end 

function CDuanWuHuodongCtrl.IsHadGetTheReward(self, step)

	if not self.m_RewardList then 
		return false
	end 

	for k, v in ipairs(self.m_RewardList) do 
		if k == step then 
			if v == 1 then 
				return true
			end 
		end 
	end 

	return false

end

function CDuanWuHuodongCtrl.GetHuodongDes(self, id)

	local desInfo = data.instructiondata.DESC[id]
	if desInfo then 
		return desInfo.desc
	end  

end 

function CDuanWuHuodongCtrl.GetMatchHuodongDes(self)

	local desInfo = data.instructiondata.DESC[10072]
	if desInfo then 
		return desInfo.desc
	end  

end 

function CDuanWuHuodongCtrl.GetQiFuRewardInfo(self, rewardId)

	local config = data.rewarddata.DUANWUQIFU[rewardId]
	local itemInfo = config.item[1]
	if itemInfo then 
		local rewardItem = {}
		rewardItem.sid = itemInfo.sid
		rewardItem.cnt = itemInfo.amount
		local itemData = DataTools.GetItemData(itemInfo.sid)
		if itemData then
			rewardItem.icon = itemData.icon
		end
		return rewardItem
	end 

end 

function CDuanWuHuodongCtrl.GetQiFuJiPinInfo(self)

	local config = data.huodongdata.DUANWUQIFUCONFIG[1]
	local itemId =config.submit_sid
	local itemData = DataTools.GetItemData(itemId)
	local icon = itemData.icon
	local name = itemData.name
	local quality = itemData.quality
	local hadCount = g_ItemCtrl:GetBagItemAmountBySid(itemId)
	local info = {}
	info.name = name
	info.icon = icon
	info.cnt = hadCount
	info.sid = itemId
	info.quality = quality
	return info

end 

function CDuanWuHuodongCtrl.IsHadQiFuReward(self)
	
	local infoList = self:GetQiFuInfoList()
	for k, v in ipairs(infoList.stepList) do 
		if v.canReward then 
			return true
		end 
	end 

end

function CDuanWuHuodongCtrl.IsHadJiPin(self)

	local info = self:GetQiFuJiPinInfo()
	return info.cnt > 0

end 

function CDuanWuHuodongCtrl.SetFirstOpenQiFuState(self, state)
	
	IOTools.SetClientData("DuanWuQiFuClickState", state)

end

function CDuanWuHuodongCtrl.IsFirstOpenQiFu(self)

	local state = IOTools.GetClientData("DuanWuQiFuClickState")
	if not state or state == 0 then 
		return true
	end  

end

------------------------------zongzimatch ---------------------------
function CDuanWuHuodongCtrl.IsMatchOpenLv(self)
	
	local info = DataTools.GetViewOpenData(define.System.ZongZiGame)
	if info then 
		if info.p_level <= g_AttrCtrl.grade then 
			return true
		end 
	end 

end

function CDuanWuHuodongCtrl.SetFirstOpenMatchState(self, state)
	
	IOTools.SetClientData("DuanWuMatchClickState", state)

end

function CDuanWuHuodongCtrl.IsFirstOpenMatch(self)

	local state = IOTools.GetClientData("DuanWuMatchClickState")
	if not state or state == 0 then 
		return true
	end  

end

function CDuanWuHuodongCtrl.ClearMatchData(self)
	
	self.m_MatchSweetCnt = nil
	self.m_MatchSaltyCnt = nil
	self.m_MatchStartTime = nil
	self.m_MatchEndTime = nil
	self.m_MatchVoteCnt = nil
	self.m_MatchVoteBuy = nil
	self.m_MatchState = nil

end

function CDuanWuHuodongCtrl.IsHadMatchData(self)
	
	return self.m_MatchEndTime and true or false

end

function CDuanWuHuodongCtrl.IsMatchHuodongOpen(self)
	
	local isOpenLv = self:IsMatchOpenLv()
	return self.m_MatchState and isOpenLv

end

function CDuanWuHuodongCtrl.GetMatchEndTime(self)

	return self.m_MatchEndTime or 0

end 

function CDuanWuHuodongCtrl.GetRemainBuyTime(self)
	
	local buyLimit = data.huodongdata.ZONGZIGAMECONFIG[1].buy_limit
	return buyLimit - (self.m_MatchVoteBuy or 0)

end

function CDuanWuHuodongCtrl.GetZongZiTip(self, id)
 
	local config = data.huodongdata.ZONGZIGAMETEXT[id]
	if config then 
		return config.content
	end 

end 

function CDuanWuHuodongCtrl.GetZongZiInfoList(self)

	local zongZiInfoList = {
		{zongZiType = define.DuanWuHuodong.ZongZiType.Sweet , name = "甜粽子", point = self.m_MatchSweetCnt or 0 , max = 1000, icon = "duanwuhuodong_23",},
		{zongZiType = define.DuanWuHuodong.ZongZiType.Salty , name = "咸粽子", point = self.m_MatchSaltyCnt or 0 , max = 1000, icon = "duanwuhuodong_29",},
	}
	
	return zongZiInfoList

end 

function CDuanWuHuodongCtrl.GetDuiHuanJuanCnt(self)

	return self.m_MatchVoteCnt or 0

end 

function CDuanWuHuodongCtrl.GetYuanBaoDuiHuanCost(self)

	local config = data.huodongdata.ZONGZIGAMECONFIG[1]
	local cost = config.goldcoin_cost
	local hadCnt = self.m_MatchVoteBuy
	local str = string.gsub(cost, "num", hadCnt+1)
	local fun = loadstring("return " .. str)
	return fun()

end 

function CDuanWuHuodongCtrl.GetDuiHuanItemInfo(self)

	local info = {}
	info.name = "兑换劵"
	info.icon = 10052
	info.cnt = self:GetDuiHuanJuanCnt()
	return info

end 

function CDuanWuHuodongCtrl.Clear(self)
	
	self:ClearMatchData()
	self:ClearQiFuData()

end


return CDuanWuHuodongCtrl
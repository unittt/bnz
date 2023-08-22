local CAssembleTreasureCtrl = class("CAssembleTreasureCtrl", CCtrlBase)

function CAssembleTreasureCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Clear()
end

function CAssembleTreasureCtrl.Clear(self)
	-- body
	self.m_ServerRecord = {}
	self.m_SourtRecord = {}
	self.m_CurFreeCnt  = 0  -- 当前使用过的免费次数
	self.m_NextFreeTime = nil
	self:ResetTimer()

	self.m_IsOpenActivity = false
	self.m_ScoreValue = 0

	self.m_ExtraRewardNeedCnt = 0
	self.m_MaxFreeCnt = data.assembletreasuredata.CONFIG[1].free_count
	self.m_SourtState = {}
	self.m_CallBackID = nil
	self.m_ShowRank = false
	self.m_DonTip = false
	self.m_ScoreRank = nil
	self.m_ItemList = {}
end

function CAssembleTreasureCtrl.HasScoreRedPoint(self)
	local HasRedPoint = false
	for i,v in ipairs(self.m_SourtState) do
		if v.state == 1 then
			HasRedPoint = true
			break
		end
	end
	return HasRedPoint
end

function CAssembleTreasureCtrl.OneBtnRedPt(self) --可以免费聚宝
	-- body
	local HasRedPoint = false
	if self.m_MaxFreeCnt - self.m_CurFreeCnt == 0  then -- 每天第一次登陆免费
		HasRedPoint = true
	end
	if self.m_CurFreeCnt > 0 and self.m_NextFreeTime and self.m_NextFreeTime <= 0 then
		HasRedPoint = true
	end
	return HasRedPoint
end

function CAssembleTreasureCtrl.CheckOpenState(self)
	return self.m_IsOpenActivity and g_OpenSysCtrl:GetOpenSysState(define.System.JuBaoPen)
end

function CAssembleTreasureCtrl.HasMainMenuRedPt(self)
	-- body
	local HasRedPoint = false
	if self:HasScoreRedPoint() then
		HasRedPoint = true
	end
	if self:OneBtnRedPt() then
		HasRedPoint = true
	end
	if self.m_ShowRank then
		HasRedPoint = false
	end
	return HasRedPoint
end

function CAssembleTreasureCtrl.GS2CJuBaoPenInfo(self, pbdata)
	-- body
	self.m_CurFreeCnt = pbdata.free_count   
	self.m_NextFreeTime = pbdata.free_endtime - g_TimeCtrl:GetTimeS() 
	self.m_ExtraRewardNeedCnt = pbdata.ten_ext_times  
	self.m_SourtState = pbdata.score_reward 
	self.m_ScoreValue = pbdata.score   
	self:CalculateNextFreeTime()
	self:OnEvent(define.AssembleTreasure.Event.RefreshExtraAndScore)
end

function CAssembleTreasureCtrl.CalculateNextFreeTime(self)
	-- body
	self:ResetTimer()
	local function calculatetime()
		-- body
		self.m_NextFreeTime = (self.m_NextFreeTime or 0) - 1
		local hours = math.modf(self.m_NextFreeTime/3600)
        local minutes = math.floor ((self.m_NextFreeTime%3600)/60)
        local seconds = self.m_NextFreeTime % 60

		if self.m_NextFreeTime > 0 then
			self:OnEvent(define.AssembleTreasure.Event.RefreshSeconds, {hours=hours,minutes=minutes,seconds=seconds})
			return true
		-- else
		-- 	if self.m_NextFreeTime > - 5 then
		-- 		nethuodong.C2GSOpenJuBaoPenView()
		-- 		netrank.C2GSGetRankInfo(211, 1)
		-- 		return true
		-- 	else
		-- 		return false
		-- 	end
		end
	end

	self.m_NextTimer = Utils.AddTimer(calculatetime, 1, 1)
end

function CAssembleTreasureCtrl.GS2CJuBaoPen(self, pbdata)
	-- body
	self.m_ItemList = pbdata.rewards
	local oView = CAssembleTreasureView:GetView()
	if  not oView then
		self:PlayTween(pbdata)
	end
	self:OnEvent(define.AssembleTreasure.Event.TenTimeJuBao, pbdata)
end

function CAssembleTreasureCtrl.PlayTween(self, pbdata)
	-- body
 	local colorinfo = data.colorinfodata.ITEM

	if #pbdata.rewards <=1 then

		local oItemData = DataTools.GetItemData( pbdata.rewards[1].id)
		g_NotifyCtrl:FloatItemBox(oItemData.icon)

		local huodetipstr = string.format(colorinfo[oItemData.quality].color, oItemData.name)

		g_NotifyCtrl:FloatMsg("获得"..huodetipstr.."×"..string.format(colorinfo[oItemData.quality].color, pbdata.rewards[1].amount))
		return
	end

	local function msgCB() -- 获得额外奖励的提示
		-- body
		g_NotifyCtrl:FloatMsg(data.assembletreasuredata.TEXT[1008].content)
		for _,v in ipairs(pbdata.extrewards) do
			local dItemData = DataTools.GetItemData(v.id)
			g_NotifyCtrl:FloatMsg("获得"..string.format(colorinfo[dItemData.quality].color, dItemData.name).."×"..string.format(colorinfo[dItemData.quality].color, v.amount))
		end
	end
	-- 笨蛋 需求
	-- 获取福缘宝箱的Item位置
	local posArray = {[1] = {x =  -0.50260418653488 , y =  0.18437501788139,    z = 0},
					  [2] = {x =  -0.2734375        , y =  0.18437501788139,    z = 0},
					  [3] = {x =  -0.04427083581686 , y =  0.18437501788139,    z = 0},
					  [4] = {x =  0.18489584326744  , y =  0.18437501788139,    z = 0},
					  [5] = {x =  0.4140625         , y =  0.18437501788139,    z = 0}, 
					  [6] = {x =  -0.50260418653488 , y =  -0.028124999254942 , z = 0}, 
					  [7] = {x =  -0.2734375        , y =  -0.028124999254942,  z = 0}, 
					  [8] = {x =  -0.04427083581686,  y =  -0.028124999254942,  z = 0},
					  [9] = {x =  0.18489584326744,   y =  -0.028124999254942,  z = 0}, 
					  [10] ={x =  0.4140625,          y =  -0.028124999254942,  z = 0},
					}

	local floatItem = {}
	for i,v in ipairs(pbdata.rewards) do
		local item = DataTools.GetItemData(v.id)
		if i<=10 then
			table.insert(floatItem, { icon = item.icon, worldpos =  posArray[i]  })
		end
	end
	local oQuickID = g_ItemCtrl:GetQuickUseItemID(pbdata.rewards)
		local function tweemCB()
	    -- body
	    if oQuickID then
	        g_ItemCtrl:ItemQuickUse(oQuickID)
	    end
	end

	if  pbdata.extrewards and  next( pbdata.extrewards) then
		msgCB()
	end	
	g_NotifyCtrl:FloatMultipleItemBox(floatItem, false, tweemCB) 

end

function CAssembleTreasureCtrl.GS2CJuBaoPenStart(self, endTime, showrank)
	-- body
	self.m_ShowRank = false
	if showrank and showrank == 1 then
		self.m_ShowRank = true
	end
	self.m_IsOpenActivity = true
	self.m_LeftTime = endTime 
	self:OnEvent(define.AssembleTreasure.Event.RefreshState)
end

function CAssembleTreasureCtrl.GS2CJuBaoPenEnd(self, showrank)
	-- body
	if showrank and showrank == 1 then
		self.m_ShowRank = true
		nethuodong.C2GSOpenJuBaoPenView()
		netrank.C2GSGetRankInfo(211, 1)
	end
	if showrank and showrank == 2 then
		self.m_IsOpenActivity = false
	end
	self:OnEvent(define.AssembleTreasure.Event.RefreshState)
end

function CAssembleTreasureCtrl.GetBtnStateByIndex(self, score)
	-- body
	local oState = 0
	for _,v in ipairs(self.m_SourtState) do
		if score == v.score then
			oState = v.state
			break
		end
	end
	return oState
end


function CAssembleTreasureCtrl.GS2CJuBaoPenRecord(self, records)
	-- body
	if records then
		self.m_Record = records
	end
	self:OnEvent(define.AssembleTreasure.Event.RefreshRank, records)
end


function CAssembleTreasureCtrl.IsCancelConsumeTip(self)
	return self.m_DonTip
end

function CAssembleTreasureCtrl.GS2CGetRankInfo(self, pbdata)
	-- body
	if pbdata.idx~=211 then
		return
	end
	self.m_SourtRecord = pbdata.jubaopen_score_rank
	self.m_ScoreRank = pbdata.my_rank
	self:OnEvent(define.AssembleTreasure.Event.RefreshRank)
end

function CAssembleTreasureCtrl.IsAssembleTreasureItem(self)
	-- body
	local isBool = false
	if next(self.m_ItemList) then
		isBool = true
	end
	return isBool
end

function CAssembleTreasureCtrl.ResetTimer(self)
	if self.m_NextTimer then
		Utils.DelTimer(self.m_NextTimer)
		self.m_NextTimer = nil
	end
end

return CAssembleTreasureCtrl
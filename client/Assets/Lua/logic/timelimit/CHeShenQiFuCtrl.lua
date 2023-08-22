local CHeShenQiFuCtrl = class("CHeShenQiFuCtrl", CCtrlBase)


function CHeShenQiFuCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_ShowTip = true

end

function CHeShenQiFuCtrl.IsHuoDongOpen(self)
	
	return self.m_EndTime and self.m_EndTime > 0

end

function CHeShenQiFuCtrl.GS2CQiFuStart(self, endTime)
	
	self.m_EndTime = endTime
	self:OnEvent(define.HeShenQiFu.Event.Start) 

end

function CHeShenQiFuCtrl.GS2CQiFuEnd(self)

	self.m_EndTime = 0
	self:OnEvent(define.HeShenQiFu.Event.End) 

end


function CHeShenQiFuCtrl.GS2CQiFuReward(self, point, rewardlist)

	self.m_Point = point
	self.m_RewardList = rewardlist
	local t = {}
	t.point = point
	t.rewardlist = rewardlist
	self:OnEvent(define.HeShenQiFu.Event.QiFuReward, t)

end

function CHeShenQiFuCtrl.GS2CQiFuLottery(self, rewardlist)
	 self:OnEvent(define.HeShenQiFu.Event.QiFuLottery, rewardlist) 
end

function CHeShenQiFuCtrl.C2GSQiFuGetDegreeReward(self, index)
	nethuodong.C2GSQiFuGetDegreeReward(index)
end

function CHeShenQiFuCtrl.C2GSQiFuGetLotteryReward(self, flag)

	nethuodong.C2GSQiFuGetLotteryReward(flag)

end

function CHeShenQiFuCtrl.GetPoint(self)
	return self.m_Point or 0
end

function CHeShenQiFuCtrl.GetRewardStateList(self)
	return self.m_RewardList
end

function CHeShenQiFuCtrl.GetEndTime(self)
	return self.m_EndTime
end

function CHeShenQiFuCtrl.SetTipShow(self, isShow)
	
	self.m_ShowTip = isShow

end

function CHeShenQiFuCtrl.IsShowTip(self)
	
	return self.m_ShowTip

end

function CHeShenQiFuCtrl.Clear(self)
	
	self.m_ShowTip = true
	self.m_EndTime = 0
	self.m_Point = 0
	self.m_RewardList = {}

end

function CHeShenQiFuCtrl.IsHadUnReceiveReward(self)
	
	if self.m_RewardList then 
		for k, v in ipairs(self.m_RewardList) do 
			if v == 1 then 
				return true
			end 
		end 
	end 

end

return CHeShenQiFuCtrl
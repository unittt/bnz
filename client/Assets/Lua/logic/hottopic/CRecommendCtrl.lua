local CRecommendCtrl = class("CRecommendCtrl", CCtrlBase)

function CRecommendCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_AdvanceInfo = {}
end

CRecommendCtrl.m_HuodongDict = {
	[1] = "GIFTDAY",
	[2] = "ACTIVEPOINT",
	[3] = "WEEKDAY",
}

function CRecommendCtrl.GS2CForeShowInfo(self, list)
	if next(self.m_AdvanceInfo) then
		self.m_AdvanceInfo = {}
	end

	for k, v in pairs(list) do
		table.insert(self.m_AdvanceInfo, v)
	end

	table.sort(self.m_AdvanceInfo, function(a, b)
		return a.show_type < b.show_type
	end)
end

function CRecommendCtrl.GetRecommendInfo(self)
	return self.m_AdvanceInfo
end

function CRecommendCtrl.GetInfoByType(self, iType)
	local hd = self.m_HuodongDict[iType]
	local dConfig = data.recommenddata[hd]
	return dConfig
end

function CRecommendCtrl.IsRecommendOpen(self)
	local bRecommendOpen = g_OpenSysCtrl:GetOpenSysState("RECOMMEND")
	local bAdvanceOpen = g_OpenSysCtrl:GetOpenSysState("ADVANCE")

	local count = table.count(self.m_AdvanceInfo)
	local bCount = count > 0
	return (bRecommendOpen or bAdvanceOpen) and bCount
end

return CRecommendCtrl
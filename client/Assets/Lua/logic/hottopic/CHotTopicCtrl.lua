local CHotTopicCtrl = class("CHotTopicCtrl", CCtrlBase)

function CHotTopicCtrl.ctor(self)
	CCtrlBase.ctor(self)
	
	self.m_HuodongList = {}
	-- 记录非限时活动的view
	self.m_HuodongViews = {
		[1001] = "CCaishenGiftView",
		[1002] = "CSuperRebateView",
		[1006] = "CAssembleTreasureView",
		[1009] = "CEverydayRankView",
		[1015] = "CYuanBaoJoyView",
		[1017] = "CRebateJoyMainView",
	}

	self.m_SignCallback = nil
	self.m_HotCallback = nil
end

function CHotTopicCtrl.GS2CHotTopicList(self, list)

	if not next(list) and not g_RecommendCtrl:IsRecommendOpen() then
		return
	end

	if g_MarryPlotCtrl:IsPlayingWeddingPlot() then
		return
	end

	if next(self.m_HuodongList) then
		self.m_HuodongList = {}
	end

	for i, v in ipairs(list) do
		table.insert(self.m_HuodongList, v)
	end

	if g_EngageCtrl.m_EngageStatus then
		self.m_HotCallback = self.ShowHotTopicList
	end

	self:ShowHotTopicList()
end

function CHotTopicCtrl.IsHotTopicOpen(self)
	local count = table.count(self.m_HuodongList)
	return count > 0
end

function CHotTopicCtrl.GetHuodongList(self)
	return self.m_HuodongList
end

function CHotTopicCtrl.ShowHotTopicList(self)
	CHotTopicView:ShowView()
end

function CHotTopicCtrl.GetTextureNameById(self, id)
	local dConfig = data.huodongdata.HOTTOPIC

	for i, v in pairs(dConfig) do
	 	if v.id == id then
	 		return v.texture_name
	 	end
	 end 
end

function CHotTopicCtrl.OpenHuodongView(self, id)
	local dConfig = data.huodongdata.HOTTOPIC
	local dInfo = dConfig[id]

	local sname
	for k, v in pairs(define.System) do
		if dInfo.sys_name == v then
			sname = k
			break
		end
	end

	local timelimitlist = g_TimelimitCtrl:GetOpenTabList()
	local bTimeLimit = false
	for i, v in ipairs(timelimitlist) do
		if v.sys == sname then
			bTimeLimit = true
			break
		end
	end

	-- 如果是限时活动，打开限时活动分页
	if bTimeLimit then
		CTimelimitView:ShowView(function(oView)
			oView:ForceSelPage(sname)
		end)
	else 
	-- 如果不是限时活动，另外处理
	--[[
		财神送礼 -- CCaishenGiftView
		元宝狂欢 -- CYunBaoJoyView
		聚宝盆 -- CAssembleTreasureView
		超级返利 -- CSuperRebateView
		每日冲榜 -- CEveryDayRankView
	]]--

		local viewname = self.m_HuodongViews[id]
		if viewname then
			_G[viewname]:ShowView(function (oView)
				if oView["RefreshUI"] then
					oView:RefreshUI()
				end
			end)
		end
	end
end

return CHotTopicCtrl
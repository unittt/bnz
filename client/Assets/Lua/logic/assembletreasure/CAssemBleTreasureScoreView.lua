local CAssemBleTreasureScoreView = class("CAssemBleTreasureScoreView", CViewBase)

function CAssemBleTreasureScoreView.ctor(self, cb)
	-- body
	CViewBase.ctor(self, "UI/AssembleTreasure/AssembleTreasureScoreView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CAssemBleTreasureScoreView.OnCreateView(self)
	-- body
	self.m_ScoreScrollView = self:NewUI(1, CScrollView)
	self.m_ScoreGrid = self:NewUI(2, CGrid)
	self.m_ScoreBoxClone = self:NewUI(3, CBox)
	self.m_ScoreViewCloseBtn = self:NewUI(4, CButton)
	self.m_ScoreBoxClone:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
	g_AssembleTreasureCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTreasureCtrl"))
	
	self:InitContent()
end

function CAssemBleTreasureScoreView.InitContent(self)
	-- body

	local dScoreData = data.assembletreasuredata.SCORE_REWARD
	local oScoreList = {}
	for _,v in pairs(dScoreData) do
		table.insert(oScoreList, v)
	end

	for i,v in ipairs(oScoreList) do
		local sState = g_AssembleTreasureCtrl:GetBtnStateByIndex(v.score) 
		if sState ==  0 then --待完成
			v.sort = 2
		elseif sState == 1 then -- 可领取
			v.sort = 1 
		elseif sState == 2 then -- 已领取
			v.sort = 3
		end
	end

	table.sort(oScoreList, function (a,b)
		-- body
		if a.sort ~= b.sort then
			return a.sort < b.sort
		else
			return a.score < b.score
		end
	end)

	self.m_ScoreViewCloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ScoreGrid:Clear()
	for i,v in ipairs(oScoreList) do
		local box = self.m_ScoreGrid:GetChild(i)
		if not box then
			box = self:CreateScoreBox(v)
		end
		self.m_ScoreGrid:AddChild(box)
	end
	self.m_ScoreGrid:Reposition()
	self.m_ScoreScrollView:ResetPosition()

end

function CAssemBleTreasureScoreView.CreateScoreBox(self, info)
	-- body
	local dItemRewardData = data.assembletreasuredata.JUBAOPEN_REWARD[info.reward_idx]
	local dItemReward = table.copy (data.assembletreasuredata.JUBAOPEN_ITEMREWARD)
	local dItemCopy = {}
	for i,v in ipairs(dItemReward) do
		dItemCopy[v.idx] = v
	end
	local box = self.m_ScoreBoxClone:Clone()
	box:SetActive(true)
	box.grid = box:NewUI(1, CGrid)
	box.item = box:NewUI(2, CBox)
	box.item:SetActive(false)
	box.btn = box:NewUI(3, CButton)
	box.spr = box:NewUI(4, CSprite)
	box.lab = box:NewUI(5, CLabel)
	box.btnlab = box:NewUI(6, CLabel)
	box.redpt =box:NewUI(7, CSprite)
	box.grid:Clear()
	local virtuals = {
				{key = "gold", item = 1001},
				{key = "exp", item = 1005},
				{key = "summexp", item = 1007},
				{key = "silver", item = 1002},
				{key = "goldcoin", item = 1003},
			}
	for i,v in pairs(dItemRewardData) do
		if i == "item" then
			for _, index in pairs(v) do
				local itembox = box.item:Clone()
				itembox:SetActive(true)
				box.grid:AddChild(itembox)
				itembox.border = itembox:NewUI(1, CSprite)
				itembox.icon = itembox:NewUI(2, CSprite)
				itembox.cnt = itembox:NewUI(3, CLabel)
				local sid = tonumber( dItemCopy[index].sid )
				local dItemData  = DataTools.GetItemData(  sid )
				itembox.icon:SpriteItemShape(dItemData.icon)
				itembox.border:SetItemQuality(dItemData.quality)
				itembox.cnt:SetText( dItemCopy[index].amount )
				itembox.icon:AddUIEvent("click", callback(self, "OnClickIcon", sid, itembox.icon))
			end
		end
	end
	box.grid:Reposition()
	local state =  g_AssembleTreasureCtrl:GetBtnStateByIndex(info.score) 
	if state == 1 then -- 可领取
		box.redpt:SetActive(true)
		box.btn:SetActive(true)
		box.btn:SetSpriteName("h7_an_2")
		-- box.lab:SetText("")
		box.btnlab:SetText("[fff9e3]领取[-]")
		box.spr:SetActive(false)
	elseif state ==  2 then -- 已领取
		box.redpt:SetActive(false)
		box.btn:SetActive(false)
		box.spr:SetActive(true)
		-- box.lab:SetText("")
	elseif  state ==  0 then -- 未完成
		box.redpt:SetActive(false)
		box.btn:SetActive(true)
		box.btn:SetSpriteName("h7_an_5")
		box.btnlab:SetText("[5c6163]领取[-]")
		box.spr:SetActive(false)
		-- box.lab:SetText("积分:"..g_AssembleTreasureCtrl.m_ScoreValue.. "/"..info.score)
	end
	box.lab:SetText("积分: "..g_AssembleTreasureCtrl.m_ScoreValue.. "/"..info.score)
	box.btn:AddUIEvent("click", callback(self, "OnScoreBtnClick", info.score))
	return box
end

function CAssemBleTreasureScoreView.OnScoreBtnClick(self, score)
	-- body
	if score > g_AssembleTreasureCtrl.m_ScoreValue then
		g_NotifyCtrl:FloatMsg("聚宝积分不足，不能领取积分奖励")
		return
	end
	nethuodong.C2GSJuBaoPenScoreReward(score)
end

function CAssemBleTreasureScoreView.OnClickIcon(self,  itemsid, widget)
	-- body
	local config = {widget = widget}
	g_WindowTipCtrl:SetWindowItemTip(itemsid, config)
end

function CAssemBleTreasureScoreView.OnTreasureCtrl(self, oCtrl)
	-- body
	if  oCtrl.m_EventID == define.AssembleTreasure.Event.RefreshExtraAndScore then
		self:InitContent()
	end
	if not g_AssembleTreasureCtrl.m_IsOpenActivity then
		self:CloseView()
	end
end
return CAssemBleTreasureScoreView
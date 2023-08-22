local CAssemBleTreasureRankView = class("CAssemBleTreasureRankView", CViewBase)

function CAssemBleTreasureRankView.ctor(self, cb)
	-- body
	CViewBase.ctor(self, "UI/AssembleTreasure/AssembleTreasureServerView.prefab", cb)
	self.m_DepthType = "Dialog"
end

function CAssemBleTreasureRankView.OnCreateView(self)
	-- body
	self.m_JJCScrollView = self:NewUI(1, CScrollView)
	self.m_JJCGrid = self:NewUI(2, CGrid)
	self.m_JJCBoxClone = self:NewUI(3, CBox)
	self.m_JJCTipLabel = self:NewUI(4, CLabel)
	self.m_JJCClosseBtn = self:NewUI(5, CButton)
	self.m_JJCBoxClone:SetActive(false)

	self.m_JJCClosseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_AssembleTreasureCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTreasureCtrl"))
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
	self:InitContent()
end

function CAssemBleTreasureRankView.InitContent(self)
	-- body
	self.m_JJCGrid:Clear()
	local RankData = data.assembletreasuredata.RANK_REWARD

	for i=1, #RankData do
		local box = self.m_JJCGrid:GetChild(i)
		if not box then
			box = self:CreateJJCBoxClone(RankData[i], i)
			self.m_JJCGrid:AddChild(box)
		end
	end
	self.m_JJCGrid:Reposition()
	self.m_JJCScrollView:ResetPosition()
end

function CAssemBleTreasureRankView.CreateJJCBoxClone(self,  rankinfo, index)
	-- body
	local dItemData = data.assembletreasuredata.JUBAOPEN_REWARD[rankinfo.reward_idx]
	local dItemRewardData = table.copy (data.assembletreasuredata.JUBAOPEN_ITEMREWARD)
	local dItemCopy = {}
	for i,v in ipairs(dItemRewardData) do
		dItemCopy[v.idx] = v
	end
	local virtuals = {
				{key = "gold", item = 1001},
				{key = "exp", item = 1005},
				{key = "summexp", item = 1007},
				{key = "silver", item = 1002},
				{key = "goldcoin", item = 1003},
			}

	local box = self.m_JJCBoxClone:Clone()
	box:SetActive(true)

	box.ranklab = box:NewUI(1, CLabel)
	box.ranklab:SetText(rankinfo.desc)

	box.scrollview = box:NewUI(2, CScrollView)
	box.grid = box:NewUI(3, CGrid)
	box.rewarditem = box:NewUI(4, CBox)
	box.rewarditem:SetActive(false)

	box.grid:Clear()

	for i,v in pairs(dItemData) do
		if i == "item" then
			for _, index in pairs(v) do
				local itembox = box.rewarditem:Clone()
				itembox:SetActive(true)
				box.grid:AddChild(itembox)
				itembox.icon = itembox:NewUI(1, CSprite)
				itembox.border = itembox:NewUI(2, CSprite)
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
	return box

end

function CAssemBleTreasureRankView.OnClickIcon(self, itemsid, widget)
	-- body
	local config = {widget = widget}
	g_WindowTipCtrl:SetWindowItemTip(itemsid, config)
end

function CAssemBleTreasureRankView.OnTreasureCtrl(self, oCtrl)
	-- body
	if not oCtrl.m_IsOpenActivity then
		self:CloseView()
	end
end


return CAssemBleTreasureRankView

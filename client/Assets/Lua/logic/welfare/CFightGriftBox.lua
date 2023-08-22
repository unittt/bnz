local CFightGriftBox = class("CFightGriftBox", CBox)

function CFightGriftBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self:InitContent()
end

function CFightGriftBox.InitContent(self)

	self.m_Grid = self:NewUI(1, CGrid)
	self.m_ItemClone = self:NewUI(2, CBox)
	self.m_ExtraItem = self:NewUI(3, CBox)
	self.m_FightScore = self:NewUI(4, CLabel)
	self.m_LeftNum = self:NewUI(5, CLabel)
	self.m_GetBtn = self:NewUI(6, CButton)
	self.m_PromoteBtn = self:NewUI(7, CButton)
	self.m_GotSp = self:NewUI(8, CSprite)

	self.m_GetBtn:AddUIEvent("click", callback(self, "OnGetBtnClick"))
	self.m_PromoteBtn:AddUIEvent("click", callback(self, "OnPromoteBtnClick"))

	self.m_ItemClone:SetActive(false)
	self.m_ExtraItem:SetActive(false)
	
end

function CFightGriftBox.SetData(self, rewardlist)
	self.m_MultiItemList = {}

	self.m_Score = rewardlist.score
	local iStatus = rewardlist.status

	self.m_FightScore:SetText(self.m_Score)
	self:SetButtonState(iStatus)  --按钮状态

	local dConfig = g_WelfareCtrl:GetFightGiftConfig(self.m_Score)
	local slotlist = rewardlist.slot
	for i=1, 4 do
		local skey = "slot"..tostring(i)
		local index = slotlist[skey]         
		if index then
			local iSlot = dConfig[skey]
			local len = #iSlot
			local rewardidx = iSlot[index]
			local itemInfo = self:GetRewardItemInfo(rewardidx)
			itemInfo.slot = skey
			itemInfo.len = len
			itemInfo.index = index
			self:SetItemInfo(itemInfo)
		end	
	end
	self.m_Grid:Reposition()

	-- 额外奖励 --
	if slotlist.extra then
		local index = slotlist.extra
		if index then                       
			local iSlot = dConfig.extra  
			local len = #iSlot
			local rewardidx = iSlot[index]
			local itemInfo = self:GetRewardItemInfo(rewardidx)
			itemInfo.slot = "extra"
			itemInfo.len = len 
			itemInfo.rank = rewardlist.rank
			itemInfo.inrank = rewardlist.inrank
			self:SetExtraItemInfo(itemInfo) 
		end
	end

end

function CFightGriftBox.GetRewardItemInfo(self, rewardidx)
	local itemInfo = {}
	
	local rewarditem = DataTools.GetReward("FIGHTGIFTBAG", rewardidx)

	local sid, amount = (rewarditem.sid):match("^(%d+)%(Value=(%d+)%)")
	if amount then
		itemInfo.sid = sid
		itemInfo.amount = amount
	else
		itemInfo.sid = rewarditem.sid
		itemInfo.amount = rewarditem.amount
	end
	return itemInfo
end

function CFightGriftBox.GetRewardSlot(self, slot)
	local itemlist = {}
	local dConfig = g_WelfareCtrl:GetFightGiftConfig(self.m_Score)

	local dSlot = dConfig[slot]
	for i, rewardidx in ipairs(dSlot) do
		local item = DataTools.GetReward("FIGHTGIFTBAG", rewardidx)
		table.insert(itemlist, item)
	end
	return itemlist
end

function CFightGriftBox.SetButtonState(self, status)

	self.m_GetBtn:SetActive(status == 1)
	self.m_GotSp:SetActive(status == 2)
	self.m_PromoteBtn:SetActive(status == 0)

end

function CFightGriftBox.SetItemInfo(self, itemInfo)
	if itemInfo == nil then return end

	local itemInfo = itemInfo
	local idx = (itemInfo.slot):match("slot(%d+)")

	local oItem = self.m_Grid:GetChild(tonumber(idx))

	if not oItem then
		oItem = self.m_ItemClone:Clone()
		oItem.m_Icon = oItem:NewUI(1, CSprite)
		oItem.m_Amount = oItem:NewUI(2, CLabel)
		oItem.m_Quality = oItem:NewUI(3, CSprite)
		oItem.m_CanSelect = oItem:NewUI(4, CSprite) 
		oItem:SetActive(true)
		self.m_Grid:AddChild(oItem)
	end

	oItem.idx = itemInfo.index

	local dItem = DataTools.GetItemData(itemInfo.sid)
	oItem.m_Icon:SpriteItemShape(dItem.icon)
	oItem.m_Amount:SetText(itemInfo.amount)
	oItem.m_Quality:SetItemQuality(dItem.quality)
	oItem.m_CanSelect:SetActive(itemInfo.len > 1)
	self:CheckMultiItem(itemInfo)

	oItem:AddUIEvent("click", callback(self, "OnItemClick", itemInfo))
end

function CFightGriftBox.SetExtraItemInfo(self, itemInfo)
	if itemInfo == nil then return end

	local itemInfo = itemInfo
	local oItem = self.m_ExtraItem
	oItem.m_Icon = oItem:NewUI(1, CSprite)
	oItem.m_Amount = oItem:NewUI(2, CLabel)
	oItem.m_Quality = oItem:NewUI(3, CSprite)
	oItem.m_GotSp = oItem:NewUI(4, CSprite)
	oItem.m_CanSelect = oItem:NewUI(5, CSprite) 
	oItem.m_LeftNum = oItem:NewUI(6, CLabel) 
	oItem.m_OverSp = oItem:NewUI(7, CSprite)
	oItem.idx = itemInfo.index 
	oItem:SetActive(true)

	local dItem = DataTools.GetItemData(itemInfo.sid)
	local rank = itemInfo.rank
	local inrank = itemInfo.inrank

	oItem.m_Icon:SpriteItemShape(dItem.icon)
	oItem.m_Amount:SetText(itemInfo.amount)
	oItem.m_Quality:SetItemQuality(dItem.quality)
	oItem.m_CanSelect:SetActive(itemInfo.len > 1)
	oItem.m_LeftNum:SetText(rank)

	local leftTime = g_WelfareCtrl:GetFightGiftLeftTime()
	local oBoxCollider = oItem:GetComponent(classtype.BoxCollider)

	if inrank == 1 then --可领取
		oItem.m_LeftNum:SetText(string.format("第%d名", rank))
		self:CheckMultiItem(itemInfo)
	else --没有领取资格
		if leftTime > 0 then 
			if g_AttrCtrl.score >= self.m_Score then
				oItem.m_LeftNum:SetText(string.format("剩余:%d", rank))
				oItem.m_GotSp:SetActive(rank == 0)		
				oBoxCollider.enabled = false
			else
				oItem.m_LeftNum:SetText(string.format("剩余:%d", rank))
				oItem.m_GotSp:SetActive(rank == 0)
				oBoxCollider.enabled = (rank ~= 0)
			end	
		else  --已结束
			oItem.m_OverSp:SetActive(true)
			oItem.m_LeftNum:SetActive(false)
			oBoxCollider.enabled = false
		end
	end

	oItem:AddUIEvent("click", callback(self, "OnItemClick", itemInfo))
end

function CFightGriftBox.OnItemClick(self, itemInfo)
	local dItem 
	if itemInfo.slot == "extra" then
		dItem = self.m_ExtraItem
	else
		local idx = (itemInfo.slot):match("slot(%d+)")
	 	dItem = self.m_Grid:GetChild(tonumber(idx))
	end
	local isHideBtn = (not self.m_GetBtn:GetActive())
	
	if itemInfo.len > 1 then
		-- [[打开可选窗口]] --
		local itemlist = self:GetRewardSlot(itemInfo.slot)
		if isHideBtn then
			g_WindowTipCtrl:ShowItemBoxView({
				title = "可选",
                hideBtn = true,
                desc = "达到领取条件时，可以选择任意一样物品作为奖励",
                items = itemlist,
                comfirmText = "确定",
			})
		else
			local curIdx = dItem.idx
			g_WindowTipCtrl:ShowSelectRewardItemView(itemlist, curIdx, function(idx)
				if curIdx ~= idx then
					local score = self.m_Score
					local slot = itemInfo.slot
					local index = idx
					curIdx = idx
					nethuodong.C2GSFightGiftbagSetChoice(score, slot, index)
				end
			end)
		end
	else
		local args = { widget = dItem }
    	g_WindowTipCtrl:SetWindowItemTip(itemInfo.sid, args)
	end
end

function CFightGriftBox.OnGetBtnClick(self)
    local score = self.m_Score
    local iTotal = #self.m_MultiItemList
    if iTotal > 0 then
        local iRc = 1
        local itemInfo = self.m_MultiItemList[iRc]
        local iSlot = itemInfo.slot
        local iCurIdx = itemInfo.index or 1
        local items = self:GetRewardSlot(iSlot)
        local function cb(idx)
            if idx ~= iCurIdx then
                nethuodong.C2GSFightGiftbagSetChoice(score, iSlot, idx)
            end
            if iRc >= iTotal then
                g_WelfareCtrl:FightGiftbagGetReward(score)
            else
                iRc = iRc + 1
                itemInfo = self.m_MultiItemList[iRc]
                iSlot = itemInfo.index
                iCurIdx = itemInfo.index or 1
                Utils.AddTimer(function()
                    if Utils.IsNil(self) then return end
                    items = self:GetRewardSlot(itemInfo.slot)
                    g_WindowTipCtrl:ShowSelectRewardItemView(items, iCurIdx, cb)
                end, 0, 0)
            end
        end
        g_WindowTipCtrl:ShowSelectRewardItemView(items, iCurIdx, cb)
    else
        g_WelfareCtrl:FightGiftbagGetReward(score)
    end
end

function CFightGriftBox.CheckMultiItem(self, itemInfo)
	if itemInfo.len > 1 then
		table.insert(self.m_MultiItemList, itemInfo)
	end
end

function CFightGriftBox.OnPromoteBtnClick(self)
	local pLevel = data.opendata.OPEN.ZHIYIN.p_level
	if g_AttrCtrl.grade < pLevel then
		g_NotifyCtrl:FloatMsg(string.format("等级未达到%d级，系统暂未开放", pLevel))
		return
	end
	CGaideMainView:ShowView()  --提升界面
end

return CFightGriftBox
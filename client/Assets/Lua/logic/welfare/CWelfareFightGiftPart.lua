CWelfareFightGiftPart = class("CWelfareFightGiftPart", CPageBase)

function CWelfareFightGiftPart.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CWelfareFightGiftPart.OnInitPage(self)

	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_ItemGrid = self:NewUI(2, CGrid)
	self.m_GiftBoxClone = self:NewUI(3, CFightGriftBox)
	self.m_CurScore = self:NewUI(4, CLabel)
	self.m_LeftTime = self:NewUI(5, CLabel)
	self.m_GiftBoxClone:SetActive(false)

	self:InitContent()
	
end

function CWelfareFightGiftPart.InitContent(self)

	self:RefreshAll()
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelFareEvent"))

end

function CWelfareFightGiftPart.RefreshAll(self)
	
	local fightGiftConfig = self:GetGiftList()
	for i, dConfig in ipairs(fightGiftConfig) do
		local oBox = self.m_ItemGrid:GetChild(i)
		if oBox == nil then
			oBox = self.m_GiftBoxClone:Clone()
			self.m_ItemGrid:AddChild(oBox)
			self.m_ItemGrid:Reposition()
		end
		oBox:SetActive(true)
		self:SetGiftItemInfo(oBox, dConfig)	
	end
	--self.m_ScrollView:ResetPosition()

	local leftTime = g_WelfareCtrl:GetFightGiftLeftTime()
	if leftTime == 0 then
		local oParent = self.m_LeftTime:GetParent()
		oParent:GetComponent(classtype.UIWidget).text = ""
		self.m_LeftTime:SetText("额外奖励活动已结束")
	else
		self.m_LeftTime:SetText(g_TimeCtrl:GetLeftTimeDHM(leftTime))
	end
	self.m_CurScore:SetText(g_AttrCtrl.score)
end

function CWelfareFightGiftPart.GetGiftList(self)
	local fightGiftList = g_WelfareCtrl:GetFightGiftConfig()  --本地数据表
	local fightGiftConfig = {}
	for score, config in pairs(fightGiftList) do  --插入一张新的表中排序
		table.insert(fightGiftConfig, config)
	end

	table.sort( fightGiftConfig, function(a, b)
		return a.score < b.score
	end )
	return fightGiftConfig
end


function CWelfareFightGiftPart.GetFightGiftInfo(self)
	local giftList = {}
	local dGift = g_WelfareCtrl:GetFightGiftReward()

	for score, v in pairs(dGift) do
		table.insert(giftList, v)
	end

	table.sort(giftList, function(a, b)
		return a.score < b.score
	end)

	return giftList
end

function CWelfareFightGiftPart.GetRewardItemList(self, config)
	local rewardlist = {}
	rewardlist.slot = {}
	rewardlist.score = config.score

	local rewardInfo = g_WelfareCtrl:GetFightGiftReward(config.score)  --服务端数据表

	if rewardInfo == nil then
		return 
	end

	rewardlist.status = rewardInfo.status
	rewardlist.rank = rewardInfo.rank
	rewardlist.inrank = rewardInfo.inrank   

	local function GetSlotIndex(slot)
		if rewardInfo.slotlist then
			local temp = {}  --临时存储每个slot对应的idx
			local dSlot = rewardInfo.slotlist
			if dSlot then
				for _, v in pairs(dSlot) do
					if v.slot == 0 then
						temp["extra"] = v.index
					else
                        local skey = "slot"..v.slot
                        temp[skey] = v.index
					end
				end

				local idx = temp[slot] or 1
				return idx
			end
			return 1  --服务端没有记录，默认为1
		end
	end            
 	       ----- todo -----
	local dConfig = g_WelfareCtrl:GetFightGiftConfig(config.score)
	for k, v in pairs(dConfig) do
		if type(v) == "table" and table.count(v) > 0 then
			local index = GetSlotIndex(k)
			rewardlist.slot[k] = index
		end
	end
	return rewardlist
end

function CWelfareFightGiftPart.SetGiftItemInfo(self, oBox, config)

	local rewardlist = self:GetRewardItemList(config)
	if rewardlist then
		oBox:SetData(rewardlist)
	end
end

function CWelfareFightGiftPart.OnWelFareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WelFare.Event.RefreshFightGift then
		self:RefreshAll()
	end
end

return CWelfareFightGiftPart
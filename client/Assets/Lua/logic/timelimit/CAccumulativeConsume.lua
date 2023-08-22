local CAccumulativeConsume = class("CAccumulativeConsume", CPageBase)

function CAccumulativeConsume.ctor(self, cb)
	-- body
	CPageBase.ctor(self, cb)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Grid       = self:NewUI(2, CGrid)
	self.m_BoxClone   = self:NewUI(3, CBox)
	self.m_BoxClone:SetActive(false)
	self.m_SVArea     = self:NewUI(4, CWidget)
	self.m_TimeLab    = self:NewUI(5, CLabel)
	-- self.m_CurSeletItem = nil
	self.m_NextTimer = nil
	self.m_RewardDict = {}
	self:InitContent()
	self:CalculateTime()
end

function CAccumulativeConsume.CalculateTime(self)
	-- body
	if self.m_NextTimer then
        Utils.DelTimer(self.m_NextTimer)
        self.m_NextTimer = nil
    end
    local endtime = g_TimelimitCtrl.m_DayExpenseEndTime - g_TimeCtrl:GetTimeS()
	-- local function timer()
	-- 	if Utils.IsNil(self) then
	-- 		return
	-- 	end
	-- 	local day = math.floor(endtime/24/3600)
 --        local hours = math.modf(endtime/3600) - day*24
 --        local minutes = math.floor ((endtime%3600)/60)
 --        local seconds = endtime % 60
 --        endtime = endtime - 1
 --        if endtime >= 0 then
 --        	local str = "%d天%d小时%d分钟"
	-- 		self.m_TimeLab:SetText(string.format(str,day,hours,minutes))
 --            return true
 --        else
 --            return false
 --        end
 --    end
	-- self.m_NextTimer = Utils.AddTimer(timer, 1, 0.2)
	self.m_TimeLab:SetText(g_TimeCtrl:GetLeftTimeDHM(endtime))
end

function CAccumulativeConsume.InitContent(self)
	
	g_TimelimitCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshCAccumulativeConsume"))

	local rewardgroup = g_TimelimitCtrl.m_GroupKey or data.huodongdata.DAYEXPENSECONFIG.reward_new.group_key
	local dItemDic = self.m_RewardDict
	for i,v in ipairs(data.rewarddata.DAYEXPENSE_ITEMREWARD) do
		dItemDic[v.idx] = v
	end
	local stateinfo = {}
	if next(g_TimelimitCtrl.m_AccConsumeRewardList) then
		for i,v in ipairs(g_TimelimitCtrl.m_AccConsumeRewardList) do
			stateinfo[v.reward_key] = v
		end
	end
	local rewardlist = {}
	for i,v in ipairs(data.huodongdata.DAYEXPENSEREWARD) do
		if rewardgroup == v.group_key then
			table.insert(rewardlist, v)
		end
	end
	
	self.m_Grid:Clear()
	local projectlist = self.m_Grid:GetChildList()
	for i=1,#rewardlist do
		local v = rewardlist[i]
		local boxclone = nil
			if i>#projectlist then
				boxclone = self.m_BoxClone:Clone()
				boxclone:SetActive(true)
				self.m_Grid:AddChild(boxclone)
				boxclone.grid       = boxclone:NewUI(1, CGrid)
				boxclone.itemclone  = boxclone:NewUI(2, CBox)
				boxclone.itemclone:SetActive(false)
				boxclone.consumetip = boxclone:NewUI(3, CLabel)
				boxclone.btn        = boxclone:NewUI(4, CButton)
				boxclone.redpot     = boxclone:NewUI(5, CSprite)
				boxclone.lacktip    = boxclone:NewUI(6, CLabel)
				boxclone.hasreceive = boxclone:NewUI(7, CLabel)
				boxclone.bg         = boxclone:NewUI(8, CSprite)
			else
				boxclone = projectlist[i]
			end

		boxclone.grid:Clear()
		local itemlist = boxclone.grid:GetChildList()
		for k=1,5 do
			local s = "slot"..tostring(k)
			local grididx = 1
			if stateinfo[i] and next(stateinfo[i].grid_list) then
				for i,v in ipairs(stateinfo[i].grid_list) do
					if k == v.grid then
						grididx = v.option
						break
					end
				end
			end
			local oItem = dItemDic[v[s][grididx]]
			if not oItem then break end

			local itembox = nil
			if k>#itemlist then
				itembox = boxclone.itemclone:Clone()
				itembox:SetActive(true)
				boxclone.grid:AddChild(itembox)
				itembox.icon = itembox:NewUI(1, CSprite)
				itembox.border = itembox:NewUI(2, CSprite)
				itembox.amount = itembox:NewUI(3, CLabel)
				itembox.tag   =   itembox:NewUI(4, CSprite)
			end
			itembox.icon:SetGroup(self:GetInstanceID())
			
			if  #v[s] == 1 then
				itembox.tag:SetActive(false)
			else
				itembox.tag:SetActive(true)
			end
			
			local sid, amount = (oItem.sid):match("^(%d+)%(Value=(%d+)%)")
			if not sid then
				sid = oItem.sid
				amount = oItem.amount
			end
			local dItemData = DataTools.GetItemData(sid)
			itembox.icon:SpriteItemShape(dItemData.icon)
			local state = 0
			if stateinfo[i] then
				state = stateinfo[i].reward_state
			end
			itembox.reward_key = i
			itembox.gird = k
			itembox.selIdx = grididx
			itembox.itemList = self:GetItemList(v[s])
			itembox.sid = sid
			itembox.icon:AddUIEvent("click", callback(self, "OnItemClick", itembox, grididx, state))
			itembox.border:SetItemQuality(dItemData.quality)
			itembox.amount:SetText(amount)
		end

		boxclone.consumetip:SetText(v.expense)
		boxclone.btn:AddUIEvent("click", callback(self, "OnReceiveBtn", i))
		if v.expense > g_TimelimitCtrl.m_TodayConsume  then
			boxclone.lacktip:SetActive(true)
			boxclone.lacktip:SetText(v.expense - g_TimelimitCtrl.m_TodayConsume)
		else
			boxclone.lacktip:SetActive(false)
		end
		boxclone.redpot:SetActive(false)
		if stateinfo[i] then
			if stateinfo[i].reward_state == 1 then
				boxclone.btn:SetActive(true)
				boxclone.btn:SetSpriteName("h7_an_2")
				boxclone.hasreceive:SetActive(false)
				boxclone.lacktip:SetActive(false)
			elseif stateinfo[i].reward_state == 2 then
				boxclone.btn:SetActive(false)
				boxclone.hasreceive:SetActive(true)
				boxclone.lacktip:SetActive(false)
			else
				boxclone.lacktip:SetActive(true)
				boxclone.btn:SetActive(true)
				boxclone.btn:SetSpriteName("h7_an_5")
				boxclone.hasreceive:SetActive(false)
			end
		end
	end
end


function CAccumulativeConsume.OnReceiveBtn(self, idx)
	-- body
	if g_TimelimitCtrl:GetDayExpenseStateByIdx(idx) then
		self:OnGetReward(idx)
	else
		g_NotifyCtrl:FloatMsg("尚未达到领取条件")
	end
end


function CAccumulativeConsume.OnItemClick(self, itembox, selectidx, state)
	local list = itembox.itemList
	if not list then return end
	if #list == 1 then
		if itembox.sid then
			local config = {widget = itembox.icon}
			g_WindowTipCtrl:SetWindowItemTip(itembox.sid, config)
		end
	else
		if state == 0 or state == 2 then
			 g_WindowTipCtrl:ShowItemBoxView({
                title = "可选",
                hideBtn = true,
                items = list,
                comfirmText = "确定",
                desc = "达到领取条件，可以选择任意一样物品作为奖励",
            })
		elseif state == 1 then
			local cb = function (option, info)
				if selectidx ~= option then
					self:SetRewardOption(itembox, option, info)
				end
			end
			g_WindowTipCtrl:ShowSelectRewardItemView(list, selectidx, cb)
		end
	end
end


function CAccumulativeConsume.RefreshCAccumulativeConsume(self, oCtrl)
	-- body
	if oCtrl.m_EventID == define.Timelimit.Event.RefreshDayExpense then
		if oCtrl.m_DayExpenseState ~= 1 then
			g_TimelimitCtrl:GetOpenTabList()
			local oView = CTimelimitView:GetView()
			if oView then
				oView:HidePage("AccConsume")
				oView:SelDefaultPage()
			end
		end
		self:InitContent()
	elseif  oCtrl.m_EventID == define.Timelimit.Event.RefreshDayExpense then
		self:CalculateTime()
	end
end

function CAccumulativeConsume.SetRewardOption(self, itembox, option, info)
	nethuodong.C2GSDayExpenseSetRewardOption(g_TimelimitCtrl.m_GroupKey, itembox.reward_key, itembox.gird, option)
	local dItem = DataTools.GetItemData(info.sid)
	itembox.amount:SetText(info.amount)

	itembox.icon:SpriteItemShape(dItem.icon)
	itembox.border:SetItemQuality(dItem.quality)
end

function CAccumulativeConsume.OnGetReward(self, idx)
	local oBox = self.m_Grid:GetChild(idx)
	if not oBox then return end
	local itemBoxs = oBox.grid:GetChildList()
	local multis = {}
	for i, oItemBox in ipairs(itemBoxs) do
		local list = oItemBox.itemList
		if list and #list > 1 then
			table.insert(multis, oItemBox)
		end
	end
	local iTotal = #multis
	if iTotal > 0 then
        local iRc = 1
        local dItem = multis[iRc]
        local iCurIdx = dItem.selIdx or 1
        local function cb(option, info)
            if option ~= iCurIdx then
                self:SetRewardOption(dItem, option, info)
            end
            if iRc >= iTotal then
                nethuodong.C2GSDayExpenseGetReward(g_TimelimitCtrl.m_GroupKey, idx)
            else
                iRc = iRc + 1
                dItem = multis[iRc]
                iCurIdx = dItem.selIdx or 1
                Utils.AddTimer(function()
                    if Utils.IsNil(self) then return end
                    g_WindowTipCtrl:ShowSelectRewardItemView(dItem.itemList, iCurIdx, cb)
                end, 0, 0)
            end
        end
        g_WindowTipCtrl:ShowSelectRewardItemView(dItem.itemList, iCurIdx, cb)
	else
		nethuodong.C2GSDayExpenseGetReward(g_TimelimitCtrl.m_GroupKey, idx)
	end
end

function CAccumulativeConsume.GetItemList(self, list)
	local infolist = {}
	for i,v in ipairs(list) do
		table.insert(infolist, self.m_RewardDict[v])
	end
	local oItem = infolist[1].sid
	local sid = oItem:match("^(%d+)%(Value=(%d+)%)")
	if not sid then
		sid = tonumber(infolist[1].sid)
	end
	local dItemlist = {}
	for i,v in ipairs(infolist) do
		local dsid,amount = v.sid:match("^(%d+)%(Value=(%d+)%)")
		if not dsid then
			dsid = tonumber(v.sid)
			amount = v.amount
		end
		table.insert(dItemlist, {sid =dsid , amount = amount})
	end
	return dItemlist
end

return CAccumulativeConsume
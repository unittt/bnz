local CAssembleTreasureView = class("CAssembleTreasureView", CViewBase)

function CAssembleTreasureView.ctor(self, cb)
	-- body
	CViewBase.ctor(self, "UI/AssembleTreasure/AssembleTreasureView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_GroupName = "main"
	self.m_ItemList = {}
	self.m_DelayTimer = nil
	self.m_IsPlayingEffect = false 
	self.m_IsJuBao = false
	self.m_ActivityTimer = nil
	self.m_FinishEffect = nil
	self.m_ServerDelayer = nil
	self.m_SwitchList = {"一","二","三","四","五","六","七","八","九","十"}
	self.pbdata = nil
end

function CAssembleTreasureView.OnCreateView(self)
	-- body
	self.m_CloseBtn = self:NewUI(1, CButton)
	for i=2, 11 do
		table.insert(self.m_ItemList, self:NewUI(i, CBox))
	end
	self.m_RefreshTimeLab = self:NewUI(12, CLabel)
	self.m_OneBtn = self:NewUI(13, CButton)
	self.m_TenBtn = self:NewUI(14, CButton)
	self.m_TipBtn = self:NewUI(15, CButton)
	self.m_ExtraTimeLab = self:NewUI(16, CLabel)
	self.m_RedPoint = self:NewUI(17, CSprite)
	self.m_RecordClone = self:NewUI(18, CLabel)
	self.m_ActivityTimeLab = self:NewUI(19, CLabel)

	self.m_ServerScrollView = self:NewUI(20, CScrollView)
	self.m_ServerTable = self:NewUI(21, CTable)
	 
	self.m_ScoreBoxClone = self:NewUI(22, CBox)
	self.m_ScoreBoxClone:SetActive(false)
	self.m_SourtScrollView = self:NewUI(23, CScrollView)
	self.m_SourtTable = self:NewUI(24, CGrid)
	self.m_SilverSpr = self:NewUI(25, CSprite)
	self.m_GoldSpr = self:NewUI(26, CSprite)

	self.m_RankPart = self:NewUI(27, CBox)

	self.m_RankScrollView = self.m_RankPart:NewUI(1, CScrollView)
	self.m_RankGrid = self.m_RankPart:NewUI(2, CGrid)
	self.m_RankBox =self.m_RankPart:NewUI(3, CBox)
	self.m_RankBox:SetActive(false)
	self.m_MyRank = self.m_RankPart:NewUI(4, CLabel)
	self.m_MyName = self.m_RankPart:NewUI(5, CLabel)
	self.m_MyScore = self.m_RankPart:NewUI(6, CLabel)

	self.m_RightPart =self:NewUI(28, CBox)
	self.m_LeftPart = self:NewUI(29, CBox)
	self.m_SilverRedPt = self:NewUI(30, CSprite)

	self.m_MyInfo = self:NewUI(31, CBox)
	self.m_MyNameLab = self.m_MyInfo:NewUI(1, CLabel)
	self.m_MyRankLab = self.m_MyInfo:NewUI(2, CLabel)
	self.m_MyScoreLab = self.m_MyInfo:NewUI(3, CLabel)

	self.m_EffectPos = self:NewUI(32, CObject)
	self.m_ExtraSprBox = self:NewUI(33, CSprite)
	self.m_RankTipLab = self:NewUI(34, CLabel)

	self:InitRank()
	self:InitEvent()
	self:InitContent()
end

function CAssembleTreasureView.InitRank(self)
	-- body
	self.m_RankPart:SetActive(g_AssembleTreasureCtrl.m_ShowRank)
	if not g_AssembleTreasureCtrl.m_ShowRank then return end
	local rewarddic = {}	
	for i,v in ipairs(data.assembletreasuredata.JUBAOPEN_ITEMREWARD) do
		rewarddic[v.idx] = v 
	end
	local scoreReward = data.assembletreasuredata.RANK_REWARD
	self.m_RankGrid:Clear()
	local myInfo = {}
	table.print(g_AssembleTreasureCtrl.m_SourtRecord, "m_SourtRecord")
	if next(g_AssembleTreasureCtrl.m_SourtRecord) then
		for i, v in ipairs(g_AssembleTreasureCtrl.m_SourtRecord) do
			local tempIdx = i
			if g_AttrCtrl.pid == v.pid then
				myInfo = v
				myInfo.rank = i
			end

			local rankbox = self.m_RankGrid:GetChild(i)
			if not rankbox then
				rankbox = self.m_RankBox:Clone()
				rankbox:SetActive(true)
				self.m_RankGrid:AddChild(rankbox)
				rankbox.bg = rankbox:NewUI(1, CSprite)
				rankbox.top3bg = rankbox:NewUI(2, CSprite)
				rankbox.top3spr = rankbox:NewUI(3, CSprite)
				rankbox.toprank = rankbox:NewUI(4, CLabel)
				rankbox.name = rankbox:NewUI(5, CLabel)
			end
			rankbox.name:SetText(v.name)
			rankbox.name:AddUIEvent("click", callback(self, "OnLabelClick", v.pid))
			rankbox.score = rankbox:NewUI(6, CLabel)
			rankbox.score:SetText(v.score)
			-- rankbox.itemsv =rankbox:NewUI(7, CScrollView)
			rankbox.grid = rankbox:NewUI(8, CGrid)
			rankbox.item  = rankbox:NewUI(9, CBox)
			rankbox.item:SetActive(false)
			rankbox.grid:Clear()

			if tempIdx > 1 and tempIdx < 4 then
				tempIdx = 2
			elseif tempIdx >= 4 then
				tempIdx = 3
			end 

			local index = data.assembletreasuredata.RANK_REWARD[tempIdx].reward_idx
			local rewardlist = data.assembletreasuredata.JUBAOPEN_REWARD[index].item
			for i,v in ipairs(rewardlist) do
				local itembox = rankbox.grid:GetChild(i)
				if not itembox then
				    itembox = rankbox.item:Clone()
					itembox:SetActive(true)
					rankbox.grid:AddChild(itembox)
					itembox.border = itembox:NewUI(1, CSprite)
					itembox.icon = itembox:NewUI(2, CSprite)
					itembox.cnt = itembox:NewUI(3, CLabel)
				end
				local sid = tonumber(rewarddic[v].sid)
				local dItemData = DataTools.GetItemData(sid)
				itembox.border:SetItemQuality(dItemData.quality)
				itembox.icon:SpriteItemShape(dItemData.icon)
				itembox.cnt:SetText(rewarddic[v].amount)
				itembox.icon:AddUIEvent("click", callback(self, "OnClickIcon",sid, itembox.icon))
			end
			rankbox.grid:Reposition()

			-- set bei jing 
			if i%2 == 0 then 
				rankbox.bg:SetSpriteName("h7_1di")
			else
				rankbox.bg:SetSpriteName("h7_2di")
			end

			if i<= 3 then
				rankbox.top3bg:SetActive(true)
				rankbox.toprank:SetActive(false)
			else
				rankbox.top3bg:SetActive(false)
				rankbox.toprank:SetActive(true)
				rankbox.toprank:SetText("第"..self.m_SwitchList[i].."名")
			end

			if i == 1 then
				rankbox.top3spr:SetActive(true)
				rankbox.top3spr:SetSpriteName("h7_diyi")
			elseif i == 2 then
				rankbox.top3spr:SetActive(true)
				rankbox.top3spr:SetSpriteName("h7_dier")
			elseif i == 3 then
				rankbox.top3spr:SetActive(true)
				rankbox.top3spr:SetSpriteName("h7_disan")
			else
				rankbox.top3spr:SetActive(false)
			end
		end
	end	
	if next(myInfo) then
		self.m_MyRank:SetText("第"..self.m_SwitchList[myInfo.rank].."名")
		self.m_MyScore:SetText(myInfo.score)
	else
		self.m_MyRank:SetText("榜外")
		self.m_MyScore:SetText(g_AssembleTreasureCtrl.m_ScoreValue)
	end
	self.m_MyName:SetText(g_AttrCtrl.name)
	

	self.m_RankGrid:Reposition()
	self.m_RankScrollView:ResetPosition()
	
end

function CAssembleTreasureView.OnLabelClick(self, pid)
	-- body
   netplayer.C2GSGetPlayerInfo(pid)
end

function CAssembleTreasureView.OnClickIcon(self, itemsid, widget)
	g_WindowTipCtrl:SetWindowItemTip(itemsid, {widget = widget})
end

function CAssembleTreasureView.InitTipView(self, isTentime)
	local isFree = g_AssembleTreasureCtrl:OneBtnRedPt()
	-- 免费聚宝/一次
	if not isTentime and isFree then
		self:PlayEffect(isTentime)
		return
	end
	local dontip = g_AssembleTreasureCtrl:IsCancelConsumeTip()

	-- 花钱聚宝
	local config = data.assembletreasuredata.CONFIG[1]
	local disconut = config.once_goldcoin
	if isTentime then
		disconut = config.max_goldcoin
	end

	if g_AttrCtrl:GetTrueGoldCoin() < disconut then
		-- 元宝不足
		local windowTipInfo = {
			msg = data.assembletreasuredata.TEXT[1002].content,
        	pivot = enum.UIWidget.Pivot.Center,
			okCallback = function () 
				local oView = CNpcShopMainView:ShowView(function (oView )
					oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
				end )  
			 end,
			-- cancelCallback = function ()
			-- self:CloseView()
			-- end,
			okStr = "去充值",
			cancelStr = "以后再说",
		}	
		g_WindowTipCtrl:SetWindowConfirm(windowTipInfo)
	else
		if self.m_IsPlayingEffect then
			g_NotifyCtrl:FloatMsg(data.assembletreasuredata.TEXT[1015].content)
			return
		end
		if dontip then
			self:PlayEffect(isTentime)
		else
			CAssemBleTreasureTipView:ShowView(function (oView)
				oView:SetData(isTentime, disconut)
			end)
		end
	end
end

function CAssembleTreasureView.InitEvent(self)
	self.m_OneBtn:AddUIEvent("click", callback(self, "OnAssembleTreasure", false))
	self.m_TenBtn:AddUIEvent("click", callback(self, "OnAssembleTreasure", true))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnTipBtn"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_GoldSpr:AddUIEvent("click", callback(self, "OnGoldSpr"))
	self.m_SilverSpr:AddUIEvent("click", callback(self, "OnSilverSpr"))
	self.m_ExtraSprBox:AddUIEvent("click", callback(self, "OnExtraSpr"))
	
	g_AssembleTreasureCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTreasureCtrl"))
end

function CAssembleTreasureView.OnAssembleTreasure(self, isTentime)
	self:InitTipView(isTentime) -- TipView
end

function CAssembleTreasureView.OnTipBtn(self)
	local Id = 13002
	if data.instructiondata.DESC[Id]~=nil then
		local Content = {
			title = data.instructiondata.DESC[Id].title,
		 	desc = data.instructiondata.DESC[Id].desc
			}
		g_WindowTipCtrl:SetWindowInstructionInfo(Content)
	end

end

function CAssembleTreasureView.OnGoldSpr(self)
	CAssemBleTreasureRankView:ShowView()
end

function CAssembleTreasureView.OnSilverSpr(self)
	CAssemBleTreasureScoreView:ShowView()
end

function CAssembleTreasureView.OnExtraSpr(self)
		local itemreward = {}

		for _,v in ipairs(data.assembletreasuredata.JUBAOPEN_ITEMREWARD) do
			itemreward[v.idx] = v
		end

		local index = data.assembletreasuredata.CONFIG[1].ten_extra_reward

		local reward = data.assembletreasuredata.JUBAOPEN_REWARD[index]

		local items = {}
		
		for _,v in ipairs(reward.item) do
			table.insert(items, {sid = tonumber(itemreward[v].sid), amount = itemreward[v].amount} )
		end

	local args ={
		comfirmCb = nil,
		title = "额外奖励",
		items = items,
	}
	g_WindowTipCtrl:ShowItemBoxView(args)

end

function CAssembleTreasureView.OnTreasureCtrl(self, oCtrl)
	-- body
	if oCtrl.m_EventID == define.AssembleTreasure.Event.RefreshExtraAndScore then
		self:RefreshExtraLabel()
		self:SetRedPoint()
		self:RefreshFreeTime()
		self:RefreshMyInfo()
	end
	if oCtrl.m_EventID == define.AssembleTreasure.Event.RefreshRank  then
		self:RefreshServerRecord(oCtrl.m_EventData)
		self:InitRank()
		self:RefreshScoreRecord()
		--self:InitRankTipLab()
	end
	if oCtrl.m_EventID == define.AssembleTreasure.Event.RefreshSeconds then
		self:RefreshFreeTime(oCtrl.m_EventData)
	end

	if  oCtrl.m_EventID == define.AssembleTreasure.Event.RefreshState then
		self:SetState()
	end

	if  oCtrl.m_EventID == define.AssembleTreasure.Event.TenTimeJuBao then
		self:SetRewardCB(oCtrl.m_EventData)
	end
		
end

function CAssembleTreasureView.InitContent(self)
	nethuodong.C2GSOpenJuBaoPenView()

	self:RefreshItemPool()
	self:RefreshServerRecord()
	self:RefreshScoreRecord()
	self:RefreshExtraLabel()
	self:SetRedPoint()
	self:RefreshFreeTime()
	self:SetState()
	self:RefreshMyInfo()
	self:CalculateActivifyTime()
	--self:InitRankTipLab()

	g_AssembleTreasureCtrl:CalculateNextFreeTime()
end

-- function CAssembleTreasureView.InitRankTipLab(self)
-- 	local bShow = true
-- 	if g_AssembleTreasureCtrl.m_Record then
-- 		bShow = false
-- 	end
-- 	self.m_RankTipLab:SetActive(bShow)	
	
-- end

function CAssembleTreasureView.RefreshItemPool(self)
	-- body
	local dItemData = data.assembletreasuredata.JUBAOPEN_ITEMREWARD
	local dNorItemList = {}
	local dSpeItemList = {}
	for i,v in ipairs(dItemData) do
		if  v.is_display == 1 and v.is_special~=1 then
			table.insert(dNorItemList, v)
		end
		if  v.is_display == 1 and v.is_special==1 then
			table.insert(dSpeItemList, v)
		end
	end

	for i,box in ipairs(self.m_ItemList) do
		box.icon = box:NewUI(1, CSprite)
		box.border = box:NewUI(2, CSprite)
		box.cnt = box:NewUI(3, CLabel)
		local dItem = nil
		local sid = tonumber(dNorItemList[i] and dNorItemList[i].sid or dSpeItemList[i-8].sid ) 
		dItem = DataTools.GetItemData(  sid )
		box.icon:SpriteItemShape(dItem.icon)
		-- box.border:SetItemQuality(dItem.quality)
		box.border:SetActive(false)
		box.cnt:SetText(dNorItemList[i] and dNorItemList[i].amount or dSpeItemList[i-8].amount)
		box.icon:AddUIEvent("click", callback(self, "OnClickIcon",  sid, box.icon))
	end
end

function CAssembleTreasureView.RefreshServerRecord(self, records)
	-- body
	if Utils.IsNil(self) then return end
	local function fun()
		local sString = data.assembletreasuredata.TEXT[1009].content

		if records and  next(records) then
			self.m_ServerTable:Clear()
			for i = #records, 1, -1 do
				local v = records[i]
				local record = self.m_RecordClone:Clone()
				record:SetActive(true)
				self.m_ServerTable:AddChild(record)
				local oItem = DataTools.GetItemData(v.itemid)
				
				record:SetText(string.format(sString, v.rolename, oItem.name, v.num))
			end
			self.m_ServerTable:Reposition()
			self.m_ServerScrollView:ResetPosition()
		end
	end
	fun()
end

function CAssembleTreasureView.RefreshScoreRecord(self)
	-- body
	if Utils.IsNil(self) then return end

	if next(g_AssembleTreasureCtrl.m_SourtRecord) then
		self.m_SourtTable:Clear()
		for i,v in ipairs(g_AssembleTreasureCtrl.m_SourtRecord) do
			local record = self.m_ScoreBoxClone:Clone()
			record:SetActive(true)
			record.name = record:NewUI(1, CLabel)
			record.rank = record:NewUI(2, CLabel)
			record.score = record:NewUI(3, CLabel)

			record.name:SetText(v.name)
			record.rank:SetText("第"..self.m_SwitchList[i].."名")
			record.score:SetText(v.score)

			self.m_SourtTable:AddChild(record)
		end
		self.m_SourtTable:Reposition()
		self.m_SourtScrollView:ResetPosition()
	end
end

function CAssembleTreasureView.RefreshFreeTime(self, time)
	-- body
	if g_AssembleTreasureCtrl:OneBtnRedPt() then
		self.m_RefreshTimeLab:SetText(string.format(data.assembletreasuredata.TEXT[1011].content, g_AssembleTreasureCtrl.m_CurFreeCnt ))
		return
	end

	if g_AssembleTreasureCtrl.m_CurFreeCnt <= 0 then
		self.m_RefreshTimeLab:SetText(data.assembletreasuredata.TEXT[1013].content)
		return
	end

	local hours, minutes, seconds
	if time then
		if time.hours <0 then
        	hours = ""
        else
        	hours = tostring(time.hours).."小时"
        end

        if time.minutes <0 and time.hours <0 then
        	minutes = ""
        else
        	minutes = tostring(time.minutes).."分钟"
        end

        if time.seconds <0 and time.minutes <0 and time.hours <0  then
        	seconds = ""
        else
        	seconds = tostring(time.seconds).."秒"
        end

		local sTime = hours .. minutes .. seconds
		self.m_RefreshTimeLab:SetText(string.format(data.assembletreasuredata.TEXT[1012].content, sTime))
	end
end

function CAssembleTreasureView.RefreshExtraLabel(self)
	-- body
	local sString = data.assembletreasuredata.TEXT[1014].content
	self.m_ExtraTimeLab:SetText(string.format(sString,  tostring(g_AssembleTreasureCtrl.m_ExtraRewardNeedCnt)))
end

function CAssembleTreasureView.SetRedPoint(self)

	self.m_RedPoint:SetActive(g_AssembleTreasureCtrl:OneBtnRedPt())
	self.m_SilverRedPt:SetActive(g_AssembleTreasureCtrl:HasScoreRedPoint())
end

function CAssembleTreasureView.PlayEffect(self, isTentime)
	-- body
	local itemCnt = isTentime and 11 or 1
	local list = g_ItemCtrl:GetBagItemListByType(g_ItemCtrl.m_BagTypeEnum.all)
	local dvalue = g_ItemCtrl.m_BagOpenCount - #list
	if dvalue < itemCnt then
		g_NotifyCtrl:FloatMsg("背包空间不足")
		return
	end
	self.m_IsTenTime = isTentime
	
	local path = isTentime and "Effect/UI/ui_eff_0091/Prefabs/ui_eff_0091.prefab" or "Effect/UI/ui_eff_0090/Prefabs/ui_eff_0090.prefab"
	
	self.m_IsPlayingEffect = true
	
	local function effectDone ()
		if Utils.IsNil(self) then
			self.m_FinishEffect:Destroy()
			return false
		end
		self.m_FinishEffect:SetParent(self.m_EffectPos.m_Transform)
	end

	self.m_FinishEffect = CEffect.New(path, self:GetLayer(), false, effectDone)
	local function  delay()
		if Utils.IsNil(self) then
			return false
		end
		nethuodong.C2GSJuBaoPen(isTentime and 10 or 1)
		self.m_IsJuBao = true
		self.m_IsPlayingEffect = false
		self.m_IsTenTime = nil
		self.m_FinishEffect:Destroy()
		return false
	end

	self.m_DelayTimer = Utils.AddTimer(delay, 0.2, 2)
end

function CAssembleTreasureView.SetRewardCB(self, pbdata)
	------- todo effect
	local isTentime = pbdata.times == 10 
	self.pbdata = pbdata
	-- self.m_IsPlayingEffect = true

	-- if self.m_DelayTimer  then
	-- 	Utils.DelTimer(self.m_DelayTimer)
	-- 	self.m_DelayTimer = nil
	-- end

	-- local path = isTentime and "Effect/UI/ui_eff_0091/Prefabs/ui_eff_0091.prefab" or "Effect/UI/ui_eff_0090/Prefabs/ui_eff_0090.prefab"
	
	-- local function effectDone ()
	-- 	if Utils.IsNil(self) then
	-- 		self.m_FinishEffect:Destroy()
	-- 		return false
	-- 	end
	-- 	self.m_FinishEffect:SetParent(self.m_EffectPos.m_Transform)
	-- end
	local colorinfo = data.colorinfodata.ITEM

	local function msgCB() -- 获得额外奖励的提示
		-- body
		g_NotifyCtrl:FloatMsg(data.assembletreasuredata.TEXT[1008].content)
		if pbdata.extrewards and  next( pbdata.extrewards) then 
			for _,v in ipairs(pbdata.extrewards) do
				local dItemData = DataTools.GetItemData(v.id)                                      -- 建议符号使用×，比较美观
				g_NotifyCtrl:FloatMsg("获得"..string.format(colorinfo[dItemData.quality].color, dItemData.name).."×"..string.format(colorinfo[dItemData.quality].color, v.amount))
			end
		end
	end

	local oQuickID = g_ItemCtrl:GetQuickUseItemID(pbdata.rewards)

	local function  delay()
		if Utils.IsNil(self) then
			return false
		end
		
		self.pbdata = nil

		g_NotifyCtrl:FloatMsg(data.assembletreasuredata.TEXT[1005].content)

		if isTentime then 

			CFuyuanTreasureRewardView:ShowView(function (oView)
				oView:SetData(pbdata.rewards, msgCB)
			end)
		else
			local oQuickID = g_ItemCtrl:GetQuickUseItemID(pbdata.rewards)

			local function tweemCB()
		    -- body
			    if oQuickID then
			        g_ItemCtrl:ItemQuickUse(oQuickID)
				 end
			end

			local oItemData = DataTools.GetItemData( pbdata.rewards[1].id)

			g_NotifyCtrl:FloatItemBox(oItemData.icon, nil ,nil ,nil , tweemCB)

			local huodetipstr = string.format(colorinfo[oItemData.quality].color, oItemData.name)

			g_NotifyCtrl:FloatMsg("获得"..huodetipstr.."×"..string.format(colorinfo[oItemData.quality].color, pbdata.rewards[1].amount))

			-- 额外奖励的提醒
			if  pbdata.extrewards and  next( pbdata.extrewards) then
				msgCB()
			end
		end

		-- self.m_IsPlayingEffect = false
		-- self.m_FinishEffect:Destroy()

		return false
	end

	-- self.m_FinishEffect = CEffect.New(path, self:GetLayer(), false, effectDone)
	delay()
	-- self.m_DelayTimer = Utils.AddTimer(delay, 0.2, 3)
end

function CAssembleTreasureView.SetState(self)
	-- body
	local isShowRank = g_AssembleTreasureCtrl.m_ShowRank
	self.m_LeftPart:SetActive(not isShowRank)
	self.m_RightPart:SetActive(not isShowRank)
	self.m_RankPart:SetActive(isShowRank)
	if not g_AssembleTreasureCtrl.m_IsOpenActivity then
		self:CloseView()
	end

end

function CAssembleTreasureView.RefreshMyInfo(self)
	-- body
	self.m_MyNameLab:SetText(g_AttrCtrl.name)
	self.m_MyScoreLab:SetText(g_AssembleTreasureCtrl.m_ScoreValue)
	local myInfo = {}
	if next(g_AssembleTreasureCtrl.m_SourtRecord) then
		for i,v in ipairs(g_AssembleTreasureCtrl.m_SourtRecord) do
			if g_AttrCtrl.pid == v.pid then
				myInfo = v
				myInfo.rank = i
				break
			end
		end
	end
	local str = ""
	if myInfo.rank then
		str = "第"..self.m_SwitchList[myInfo.rank].."名"
	else
		str = "榜外"
	end
	self.m_MyRankLab:SetText(str)
end

function CAssembleTreasureView.CalculateActivifyTime(self)
	-- body
	local cb = function (time)
        if not time then 
        	if Utils.IsNil(self) then
        		return
        	end
            self.m_ActivityTimeLab:SetText("活动结束")
        else
            self.m_ActivityTimeLab:SetText(time)
        end 
    end
	
	local endtime = g_AssembleTreasureCtrl.m_LeftTime

	if endtime and endtime > 0 then 
		local leftTime = endtime - g_TimeCtrl:GetTimeS()
		g_TimeCtrl:StartCountDown(self, leftTime, 1, cb)
	end 

end

function CAssembleTreasureView.OnClose(self)
	-- body
	-- if  self.pbdata  then

	-- 	local pbdata = self.pbdata

 -- 		local colorinfo = data.colorinfodata.ITEM

	-- 	if #pbdata.rewards <=1 then

	-- 		local oItemData = DataTools.GetItemData( pbdata.rewards[1].id)
	-- 		g_NotifyCtrl:FloatItemBox(oItemData.icon)

	-- 		local huodetipstr = string.format(colorinfo[oItemData.quality].color, oItemData.name)

	-- 		g_NotifyCtrl:FloatMsg("获得"..huodetipstr.."×"..string.format(colorinfo[oItemData.quality].color, pbdata.rewards[1].amount))

	-- 		g_ViewCtrl:CloseView(self)

 -- 			return
 -- 		end

	
	-- 	local function msgCB() -- 获得额外奖励的提示
	-- 		-- body
	-- 		g_NotifyCtrl:FloatMsg(data.assembletreasuredata.TEXT[1008].content)
	-- 		for _,v in ipairs(pbdata.extrewards) do
	-- 			local dItemData = DataTools.GetItemData(v.id)
	-- 			g_NotifyCtrl:FloatMsg("获得"..string.format(colorinfo[dItemData.quality].color, dItemData.name).."×"..string.format(colorinfo[dItemData.quality].color, v.amount))
	-- 		end
	-- 	end

	-- 	-- 关闭界面UI还要显示入袋动画
	-- 	-- 获取福缘宝箱的Item位置
	-- 	local posArray = {[1] = {x =  -0.50260418653488 , y =  0.18437501788139,    z = 0},
	-- 					  [2] = {x =  -0.2734375        , y =  0.18437501788139,    z = 0},
	-- 					  [3] = {x =  -0.04427083581686 , y =  0.18437501788139,    z = 0},
	-- 					  [4] = {x =  0.18489584326744  , y =  0.18437501788139,    z = 0},
	-- 					  [5] = {x =  0.4140625         , y =  0.18437501788139,    z = 0}, 
	-- 					  [6] = {x =  -0.50260418653488 , y =  -0.028124999254942 , z = 0}, 
	-- 					  [7] = {x =  -0.2734375        , y =  -0.028124999254942,  z = 0}, 
	-- 					  [8] = {x =  -0.04427083581686,  y =  -0.028124999254942,  z = 0},
	-- 					  [9] = {x =  0.18489584326744,   y =  -0.028124999254942,  z = 0}, 
	-- 					  [10] ={x =  0.4140625,          y =  -0.028124999254942,  z = 0},
	-- 					}

	-- 	local floatItem = {}
	-- 	for i,v in ipairs(pbdata.rewards) do
	-- 		local item = DataTools.GetItemData(v.id)
	-- 		if i<=10 then
	-- 			table.insert(floatItem, { icon = item.icon, worldpos =  posArray[i]  })
	-- 		end
	-- 	end
	-- 	local oQuickID = g_ItemCtrl:GetQuickUseItemID(pbdata.rewards)
	-- 		local function tweemCB()
	-- 	    -- body
	-- 	    if oQuickID then
	-- 	        g_ItemCtrl:ItemQuickUse(oQuickID)
	-- 	    end
	-- 	end

	-- 	if  pbdata.extrewards and  next( pbdata.extrewards) then
	-- 		msgCB()
	-- 	end	
	-- 	g_NotifyCtrl:FloatMultipleItemBox(floatItem, false, tweemCB) 
	-- end
	-- self.pbdata = nil

	g_AssembleTreasureCtrl:ResetTimer()

  	if self.m_DelayTimer then
  		Utils.DelTimer(self.m_DelayTimer)
  		self.m_DelayTimer = nil
  		if not self.m_IsJuBao then
  			nethuodong.C2GSJuBaoPen(self.m_IsTenTime and 10 or 1)
  		end
  	end

  	local oView = CAssemBleTreasureTipView:GetView()
  	if oView then
  		oView:CloseView()
  	end
  	oView = CWindowComfirmView:GetView()
  	if oView then
  		oView:CloseView()
  	end

	g_ViewCtrl:CloseView(self)

	if g_HotTopicCtrl.m_SignCallback then
    	g_HotTopicCtrl:m_SignCallback()
    	g_HotTopicCtrl.m_SignCallback = nil
    end

end

return CAssembleTreasureView
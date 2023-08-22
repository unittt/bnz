local CGuideHelpCtrl = class("CGuideHelpCtrl", CCtrlBase)

function CGuideHelpCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_CancelGuide = false

	self.m_NotRestartGuide = {}--{"Improve"}
	self.m_NotFinishGuideList = {"War3"}

	self.m_PreOpenGuideId = 3
	self.m_RideGuideId = 8
	self.m_WingGuideId = 21
	self.m_PreOpenConfigList = {}
	for k,v in pairs(data.opendata.PREOPEN) do
		table.insert(self.m_PreOpenConfigList, v)
	end
	table.sort(self.m_PreOpenConfigList, function(a, b) return a.reward_grade < b.reward_grade end)
	for k,v in ipairs(self.m_PreOpenConfigList) do
		if v.id == 3 then
			self.m_PreOpenGuideIndex = k
		elseif v.id == 8 then
			self.m_RideGuideIndex = k
		elseif v.id == self.m_WingGuideId then
			self.m_WingGuideIndex = k
		end
	end

	self.m_PreOpenInfoInit = false
	self.m_PreOpenRewardedList = {}
	self.m_IsRidePrizeGet = false
	self.m_IsWingPrizeGet = false

	self.m_GuideExtraInfoList = {}
	self.m_GuideExtraInfoHashList = {}
	self.m_GuideLinkInfoList = {}
	self.m_GuideLinkActualList = {}

	self.m_GuideInfoInit = false

	self.m_GuideEquipList = {}
	self.m_GuideEquipHashList = {}

	self.m_OrgCount = 0
	self.m_no_guide = 0

	self.m_IsOnlineUseUpgradePack = {}
	self.m_IsOnlineRewareGradeGift = {}
	self.m_IsOnlineClickGradeGift = {}

	self.m_IsOnlineShowLeadRideGet = false
	self.m_IsAskOrgCountInit = false

	self:GetGuideDataConfigList()
end

function CGuideHelpCtrl.Clear(self)
	self.m_PreOpenInfoInit = false
	self.m_PreOpenRewardedList = {}
	self.m_GuideInfoInit = false
	self.m_OrgCount = 0
	self.m_IsOnlineUseUpgradePack = {}
	self.m_IsOnlineRewareGradeGift = {}
	self.m_IsOnlineClickGradeGift = {}
	self.m_IsClickGetPartnerGuide = false
	self.m_IsPreOpenPrizeGet = false
	self.m_IsRidePrizeGet = false
	self.m_IsGetPartnerClick = false
	self.m_IsEightLoginGetClick = false
	self.m_IsWingPrizeGet = false
	self.m_IsOnlineShowLeadRideGet = false
	self.m_IsAskOrgCountInit = false
end

function CGuideHelpCtrl.ClearAfterLoginRole(self)
	self.m_IsAskOrgCountInit = false
end

function CGuideHelpCtrl.IsNoGuide(self)
	return self.m_no_guide == 1;
end

----------------功能预告协议返回--------------

function CGuideHelpCtrl.GS2CLoginPreopenGiftInfo(self, pbdata)
	local rewarded = pbdata.rewarded --已领取的系统id
	self.m_PreOpenRewardedList = {}
	table.copy(rewarded, self.m_PreOpenRewardedList)
	self:OnEvent(define.Guide.Event.PreOpen)
	self.m_PreOpenInfoInit = true
	g_GuideHelpCtrl:CheckAllNotifyGuide()
end

function CGuideHelpCtrl.GS2CRewardPreopenGift(self, pbdata)
	local sys_id = pbdata.sys_id --领取功能预告礼包
	table.insert(self.m_PreOpenRewardedList, sys_id)
	self:OnEvent(define.Guide.Event.PreOpen)
end

function CGuideHelpCtrl.GetIsHasNotRewardPreOpen(self)
	for k,v in ipairs(self.m_PreOpenConfigList) do
		if not self:GetIsPreOpenHasRewarded(v.id) and v.reward_grade <= g_AttrCtrl.grade then
			return v
		end
	end
	return
end

function CGuideHelpCtrl.GetIsPreOpenHasRewarded(self, sysid)
	for k,v in pairs(self.m_PreOpenRewardedList) do
		if v == sysid then
			return true
		end
	end
end

function CGuideHelpCtrl.SendPreOpenEvent(self)
	self:OnEvent(define.Guide.Event.PreOpen)
end

--暂时没有用
function CGuideHelpCtrl.GetPreOpenList(self)
	local preOpen
	for k,v in ipairs(self.m_PreOpenConfigList) do
		if not self:GetIsPreOpenHasRewarded(v.id) and v.show_grade <= g_AttrCtrl.grade then
			preOpen = v
			break
		end
	end
	if preOpen then
		local list = {preOpen}
		for k,v in ipairs(self.m_PreOpenConfigList) do
			if preOpen.id ~= v.id and not self:GetIsPreOpenHasRewarded(v.id) and v.show_grade <= g_AttrCtrl.grade and preOpen.group == v.group then
				table.insert(list, v)
			end
		end
		return list
	else
		return {}
	end
end

function CGuideHelpCtrl.GetIsPreOpenGuideFit(self)
	--or g_GuideHelpCtrl.m_IsPreOpenPrizeGet
	if (not self:GetIsPreOpenHasRewarded(self.m_PreOpenGuideId)) and self.m_PreOpenConfigList[self.m_PreOpenGuideIndex].reward_grade <= g_AttrCtrl.grade then
		return true
	end
end

function CGuideHelpCtrl.GetIsRideGuideFit(self)
	--or g_GuideHelpCtrl.m_IsRidePrizeGet
	if (not self:GetIsPreOpenHasRewarded(self.m_RideGuideId)) and self.m_PreOpenConfigList[self.m_RideGuideIndex].reward_grade <= g_AttrCtrl.grade then
		return true
	end
end

function CGuideHelpCtrl.GetIsWingGuideFit(self)
	--or g_GuideHelpCtrl.m_IsWingPrizeGet
	if (not self:GetIsPreOpenHasRewarded(self.m_WingGuideId)) and self.m_PreOpenConfigList[self.m_WingGuideIndex].reward_grade <= g_AttrCtrl.grade then
		return true
	end
end

function CGuideHelpCtrl.GetPreOpenNewList(self)
	local oHasNotReward = self:GetIsHasNotRewardPreOpen()
	if oHasNotReward then
		return {oHasNotReward}
	else
		local preOpen
		for k,v in ipairs(self.m_PreOpenConfigList) do
			if g_AttrCtrl.grade < v.reward_grade then
				preOpen = v
				break
			end
		end
		if preOpen then
			local list = {preOpen}
			for k,v in ipairs(self.m_PreOpenConfigList) do
				if preOpen.id ~= v.id and g_AttrCtrl.grade < v.reward_grade and preOpen.group == v.group then
					table.insert(list, v)
				end
			end
			return list
		else
			return {}
		end
	end

	-- if g_AttrCtrl.grade >= self.m_PreOpenConfigList[#self.m_PreOpenConfigList].reward_grade and self:GetIsHasNotRewardPreOpen() then
	-- 	return {self.m_PreOpenConfigList[#self.m_PreOpenConfigList]}
	-- end
end

function CGuideHelpCtrl.GetFirstNotRewardPreOpen(self)
	local preOpen
	for k,v in ipairs(self.m_PreOpenConfigList) do
		if g_AttrCtrl.grade >= v.reward_grade and not self:GetIsPreOpenHasRewarded(v.id) then
			preOpen = v
			break
		end
	end
	return preOpen
end

function CGuideHelpCtrl.GetPreOpenConfigKey(self, oId)
	for k,v in ipairs(self.m_PreOpenConfigList) do
		if v.id == oId then
			return k
		end
	end
end

--以后要根据需求修改 1是图片 2是文字
function CGuideHelpCtrl.GetPreOpenNameText(self, oPreOpenId)
	if oPreOpenId == 1 then
		return 1, "h7_huoban_yugao"
	elseif oPreOpenId == 2 then
		return 1, "打造"
	elseif oPreOpenId == 3 then
		return 1, "h7_zuoqi_yugao"
	elseif oPreOpenId == 4 then
		return 2, "副本"
	elseif oPreOpenId == 5 then
		return 2, "修炼"
	else
		return 2, "未知名字"
	end
end

--获取奖励，不只是道具(type 1)，还有伙伴(type 2)，坐骑(type 3) 宠物(type 4)
function CGuideHelpCtrl.GetRewardList(self, rewardType, id, bIsForceBindGoldCoin)
	local itemList = {}
	local function InsertItemList(sid, typeName, amount, type)
		local item = DataTools.GetItemData(sid, typeName)
		if item then
			table.insert(itemList, {item = item, amount = amount, type = type, sid = sid})
		end
	end
	local function InsertPartnerList(sid, amount, type)
		local oPartner = data.partnerdata.INFO[tonumber(sid)]
		if oPartner then
			table.insert(itemList, {partner = oPartner, amount = amount, type = type})
		end
	end
	local function InsertRideList(sid, amount, type)
		local oRide = data.ridedata.RIDEINFO[tonumber(sid)]
		if oRide then
			table.insert(itemList, {ride = oRide, amount = amount, type = type})
		end
	end
	local function InsertSummonList(sid, amount, type)
		local oSummon = data.summondata.INFO[tonumber(sid)]
		if oSummon then
			table.insert(itemList, {summon = oSummon, amount = amount, type = type})
		end
	end
	local function AnalysisRewardInfo(RewardInfo)
		if RewardInfo.exp and tostring(RewardInfo.exp) ~= "0" and string.len(RewardInfo.exp) > 0 then InsertItemList(1005, "VIRTUAL", tonumber(RewardInfo.exp) or 0, 1) end --and tonumber(RewardInfo.exp) and tonumber(RewardInfo.exp) > 0
		if RewardInfo.silver and tostring(RewardInfo.silver) ~= "0" and string.len(RewardInfo.silver) > 0 then InsertItemList(1002, "VIRTUAL", tonumber(RewardInfo.silver) or 0, 1) end --and tonumber(RewardInfo.silver) and tonumber(RewardInfo.silver) > 0
		if RewardInfo.gold and tostring(RewardInfo.gold) ~= "0" and string.len(RewardInfo.gold) > 0 then InsertItemList(1001, "VIRTUAL", tonumber(RewardInfo.gold) or 0, 1) end --and tonumber(RewardInfo.gold) and tonumber(RewardInfo.gold) > 0
		if RewardInfo.summexp and tostring(RewardInfo.summexp) ~= "0" and string.len(RewardInfo.summexp) > 0 then InsertItemList(1007, "VIRTUAL", tonumber(RewardInfo.summexp) or 0, 1) end --and tonumber(RewardInfo.summexp) and tonumber(RewardInfo.summexp) > 0
		if RewardInfo.goldcoin and tostring(RewardInfo.goldcoin) ~= "0" and string.len(RewardInfo.goldcoin) > 0 then 
			if bIsForceBindGoldCoin then
				InsertItemList(1004, "VIRTUAL", tonumber(RewardInfo.goldcoin) or 0, 1)
			else
				InsertItemList(1003, "VIRTUAL", tonumber(RewardInfo.goldcoin) or 0, 1)
			end
		end
		if RewardInfo.partner and RewardInfo.partner ~= "" then InsertPartnerList(RewardInfo.partner, 1, 2) end
		if RewardInfo.ride and RewardInfo.ride ~= "" then InsertRideList(RewardInfo.ride, 1, 3) end
		if RewardInfo.summon and next(RewardInfo.summon) then
			for k,v in ipairs(RewardInfo.summon) do
				InsertSummonList(v.sid, 1, 4) 
			end			
		end
		if RewardInfo.item and #RewardInfo.item > 0 then
			for _,v in ipairs(RewardInfo.item) do
				local oAmount = 0
				if v.itemarg then
					oAmount = tonumber(string.sub(v.itemarg, string.find(v.itemarg, "=")+1, string.find(v.itemarg, ")")-1)) or 0
				else
					oAmount = tonumber(v.amount) or 0
				end
				--暂时屏蔽小于1000的sid，以后要去掉
				if v.sid >= 1000 then
					if not v.type or v.type == 0 then
						if v.sid and oAmount > 0 then
							InsertItemList(v.sid, nil, oAmount, 1)
						end
					else
						if v.sid and oAmount > 0 then
							local oSid =  DataTools.GetItemFiterResult(v.sid , g_AttrCtrl.roletype, g_AttrCtrl.sex)
							if oSid ~= -1 then
								InsertItemList(oSid, nil, oAmount, 1)
							end
						end
					end
				end
			end
		end
	end
	local rewardInfo = DataTools.GetReward(rewardType, id)
	if rewardInfo then
		AnalysisRewardInfo(rewardInfo)
	end
	return itemList
end

---------------以下是引导相关--------------

--extra定义 hasplay,notplay,   weaponselect, weaponselect20,weaponselect30,weaponselect40         sumshow,sumselect, item1select, rideitemselect
function CGuideHelpCtrl.GS2CNewbieGuideInfo(self, pbdata)
	self.m_no_guide = pbdata.no_guide
	if pbdata.no_guide == 0 then
		local guide_links = pbdata.guide_links
		local exdata = pbdata.exdata --可以存储玩家选择是否玩过回合制等信息

		local datalist = string.split(exdata, ",")
		self.m_GuideExtraInfoList = {}
		table.copy(datalist, self.m_GuideExtraInfoList)
		self.m_GuideExtraInfoHashList = {}
		for k,v in pairs(datalist) do
			self.m_GuideExtraInfoHashList[v] = true
		end

		self.m_GuideLinkInfoList = {}
		-- table.copy(guide_links, self.m_GuideLinkInfoList)
		self.m_GuideLinkInfoList = guide_links

		self.m_GuideLinkActualList = {}
		for k,v in pairs(self.m_GuideLinkInfoList) do
			if v.step > 0 then
				local totalStep = 0
				if CGuideData[v.linkid] and CGuideData[v.linkid].guide_list then
					totalStep = #CGuideData[v.linkid].guide_list
				end
				if totalStep > v.step and not table.index(self.m_NotRestartGuide, v.linkid) then
					--没完成的引导
					local list = {guide_links = {{linkid = v.linkid, step = 0, exdata = ""}}}
					local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
					netnewbieguide.C2GSUpdateNewbieGuideInfo(encode.mask, encode.guide_links, encode.exdata)
				else
					--已经完成引导
					if not table.index(self.m_NotFinishGuideList, v.linkid) then
						table.insert(self.m_GuideLinkActualList, {key = v.linkid})
						for i = 1, totalStep do
							table.insert(self.m_GuideLinkActualList, {key = v.linkid.."_"..i})
						end
					end
				end			
			end
		end

		if not self.m_CancelGuide then
			g_GuideCtrl.m_Flags = {}
			g_GuideCtrl:ResetUpdateInfo()
			g_GuideCtrl:LoginInit(self.m_GuideLinkActualList)

			if not self:GetIsGuideExtraInfoKeyExist("hasplay") and not self:GetIsGuideExtraInfoKeyExist("notplay") then
				-- CGuideSelectView:ShowView()
				if self.m_FindViewTimer then
					Utils.DelTimer(self.m_FindViewTimer)
					self.m_FindViewTimer = nil
				end
				CGuideView:ShowView()
				local oGuideView = CGuideView:GetView()
				if not oGuideView or g_ViewCtrl.m_LoadingViews["CGuideView"] then
					local function onFind()
						oGuideView = CGuideView:GetView()
						if not(not oGuideView or g_ViewCtrl.m_LoadingViews["CGuideView"]) then
							self:SelectHasPlayModel()
							return false
						end
						return true
					end
					self.m_FindViewTimer = Utils.AddTimer(onFind, 0.1, 0.1)
				else
					self:SelectHasPlayModel()
				end				
			end
			if self:GetIsGuideExtraInfoKeyExist("sumshow") and not self:GetIsGuideExtraInfoKeyExist("sumselect") then
				CGuideSelectSummonView:ShowView()
			end
		end

		self.m_GuideInfoInit = true
	else
		self.m_GuideExtraInfoList = {}
		self.m_GuideExtraInfoHashList = {}
		self.m_GuideLinkInfoList = {}
		self.m_GuideLinkActualList = {}
		self.m_GuideInfoInit = false
	end

	printc("CGuideHelpCtrl.GS2CNewbieGuideInfo")

	-- local list = {guide_links = 1, exdata = "还会"}
	-- local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
	-- printc("CGuideCtrl.ctor mask", encode.mask)
	-- table.print(encode, "CGuideCtrl.ctor")
end

--帮派数量相关
function CGuideHelpCtrl.GS2CGetNewbieGuildInfo(self, pbdata)
	self.m_OrgCount = pbdata.org_cnt
	self.m_IsAskOrgCountInit = true
	g_GuideCtrl:OnTriggerAll()
end

--检查是否选择过一个模式来玩
function CGuideHelpCtrl.CheckHasSelect(self)
	return self:GetIsGuideExtraInfoKeyExist("hasplay") or self:GetIsGuideExtraInfoKeyExist("notplay")
end

function CGuideHelpCtrl.GetIsGuideExtraInfoKeyExist(self, sKey)
	-- for k,v in pairs(self.m_GuideExtraInfoList) do
	-- 	if v == sKey then
	-- 		return true
	-- 	end
	-- end

	return self.m_GuideExtraInfoHashList[sKey] == true
end

function CGuideHelpCtrl.TurnGuideExtraListToStr(self)
	local str = ""
	for k,v in pairs(g_GuideHelpCtrl.m_GuideExtraInfoList) do
		if str == "" then
			str = str..v
		else
			str = str..","..v
		end
	end
	return str
end

function CGuideHelpCtrl.CheckGuideActualLink(self, sKey)
	for k,v in pairs(self.m_GuideLinkActualList) do
		if v.key == sKey then
			return true
		end
	end
end

function CGuideHelpCtrl.SelectHasPlayModel(self)
	g_UploadDataCtrl:SetDotUpload("25")
	if not g_GuideHelpCtrl:CheckHasSelect() then
		table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "hasplay")
		g_GuideHelpCtrl.m_GuideExtraInfoHashList["hasplay"] = true
	end
	local list = {exdata = g_GuideHelpCtrl:TurnGuideExtraListToStr()}
	local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
	netnewbieguide.C2GSUpdateNewbieGuideInfo(encode.mask, encode.guide_links, encode.exdata)
	g_GuideCtrl:OnTriggerAll()
	-- 发送打点Log(新手引导开始)
	g_LogCtrl:SendLog(101)
end

-------------------以后要根据需求修改-------------------

--检查必要触发条件
function CGuideHelpCtrl.CheckNecessaryCondition(self, guidetype, bNotCheckConfig)
	if not g_GuideHelpCtrl.m_GuideInfoInit then
		return false
	end
	if g_OpenSysCtrl.m_IsSysOpenShowing then
		return false
	end
	if not bNotCheckConfig and not self.m_GuideConfigList[guidetype] then
		return false
	end
	if not self:GetIsGuideExtraInfoKeyExist("hasplay") and not self:GetIsGuideExtraInfoKeyExist("notplay") then
		return false
	end
	
	local config = data.guideconfigdata.GUIDENOTPLAY[guidetype]
	if g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("notplay") then
		config = data.guideconfigdata.GUIDENOTPLAY[guidetype]
	elseif g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("hasplay") then
		config = data.guideconfigdata.GUIDEHASPLAY[guidetype]
	end
	if not config then
		return false
	end
	local argslist = string.split(config.args, ",")
	if config.type == 0 then
		return true
	elseif config.type == 101 then
		return g_TaskCtrl.m_TaskDataDic[tonumber(argslist[1])] == nil
	elseif config.type == 102 then
		return g_TaskCtrl.m_TaskDataDic[tonumber(argslist[1])] ~= nil
	elseif config.type == 103 then
		return g_AttrCtrl.grade >= tonumber(argslist[1])
	elseif config.type == 104 then
		return g_OpenSysCtrl:GetOpenSysState(argslist[1])
	elseif config.type == 105 then
		for k,v in pairs(argslist) do
			if g_ItemCtrl:GetBagItemAmountBySid(tonumber(v)) > 0 then
				return true
			end
		end
		return false
	elseif config.type == 106 then
		return g_ItemCtrl:GetBagItemAmountBySid(tonumber(argslist[1])) > 0
	elseif config.type == 107 then
	elseif config.type == 108 then
		-- table.print(argslist, "CGuideHelpCtrl.CheckNecessaryCondition 108")
		for k,v in ipairs(argslist) do
			if g_TaskCtrl.m_TaskDataDic[tonumber(v)] ~= nil then
				return true
			end
		end
		return false
	elseif config.type == 110 then
		local partnerId = tonumber(argslist[1])
		local partnerConfig = data.partnerdata.INFO[partnerId]
		local needLv = tonumber(string.sub(partnerConfig.pre_condition, string.find(partnerConfig.pre_condition, ":")+1 , -1))
		return g_ItemCtrl:GetBagItemAmountBySid(partnerConfig.cost.id) >= partnerConfig.cost.amount --and g_AttrCtrl.grade >= needLv
	elseif config.type == 111 then
		return g_HorseCtrl:GetHorseById(tonumber(argslist[1]))
	else
		return true
	end
end

function CGuideHelpCtrl.GetGuideDataConfigList(self)
	self.m_GuideConfigList = {}
	for k,v in pairs(CGuideData.Trigger_Check_NotPlay) do
		for g,h in pairs(v) do
			self.m_GuideConfigList[h] = true
		end
	end
	for k,v in pairs(CGuideData.Trigger_Check_HasPlay) do
		for g,h in pairs(v) do
			self.m_GuideConfigList[h] = true
		end
	end
end

----------------获取guideconfig配置里面的数据-----------------

--获取装备的快速使用，引导的时候才弹窗
function CGuideHelpCtrl.GetEquipNewQuickUseList(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["EquipGetNew"]
	if not config then
		return {}
	end
	local argslist = string.split(config.args, ",")
	local list = {}
	for k,v in pairs(argslist) do
		table.insert(list, tonumber(v))
	end
	return list
end

function CGuideHelpCtrl.GetSummonSelectTaskId(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["SummonGet"]
	if not config then
		return
	end
	local argslist = string.split(config.args, ",")
	return tonumber(argslist[1])
end

function CGuideHelpCtrl.GetItem1SelectItemSid(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["UseItem"]
	if not config then
		return
	end
	local argslist = string.split(config.args, ",")
	return tonumber(argslist[1])
end

function CGuideHelpCtrl.GetItem10SelectItemSid(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["UseItem10"]
	if not config then
		return
	end
	local argslist = string.split(config.args, ",")
	return tonumber(argslist[1])
end

function CGuideHelpCtrl.GetItem20SelectItemSid(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["UseItem20"]
	if not config then
		return
	end
	local argslist = string.split(config.args, ",")
	return tonumber(argslist[1])
end

function CGuideHelpCtrl.GetItem30SelectItemSid(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["UseItem30"]
	if not config then
		return
	end
	local argslist = string.split(config.args, ",")
	return tonumber(argslist[1])
end

function CGuideHelpCtrl.GetItem40SelectItemSid(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["UseItem40"]
	if not config then
		return
	end
	local argslist = string.split(config.args, ",")
	return tonumber(argslist[1])
end

function CGuideHelpCtrl.GetEquip10QuickUseList(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["EquipGet10"]
	if not config then
		return {}
	end
	local argslist = string.split(config.args, ",")
	local list = {}
	for k,v in pairs(argslist) do
		table.insert(list, tonumber(v))
	end
	return list
end

function CGuideHelpCtrl.GetEquip20QuickUseList(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["EquipGet20"]
	if not config then
		return {}
	end
	local argslist = string.split(config.args, ",")
	local list = {}
	for k,v in pairs(argslist) do
		table.insert(list, tonumber(v))
	end
	return list
end

function CGuideHelpCtrl.GetEquip30QuickUseList(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["EquipGet30"]
	if not config then
		return {}
	end
	local argslist = string.split(config.args, ",")
	local list = {}
	for k,v in pairs(argslist) do
		table.insert(list, tonumber(v))
	end
	return list
end

function CGuideHelpCtrl.GetEquip40QuickUseList(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["EquipGet40"]
	if not config then
		return {}
	end
	local argslist = string.split(config.args, ",")
	local list = {}
	for k,v in pairs(argslist) do
		table.insert(list, tonumber(v))
	end
	return list
end

function CGuideHelpCtrl.CheckUseItemGrade(self, oItemSid)
	if oItemSid == self:GetItem10SelectItemSid() then
		return 10
	elseif oItemSid == self:GetItem20SelectItemSid() then
		return 20
	elseif oItemSid == self:GetItem30SelectItemSid() then
		return 30
	elseif oItemSid == self:GetItem40SelectItemSid() then
		return 40
	end
end

function CGuideHelpCtrl.GetPartner1(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["GetPartner"]
	if not config then
		return
	end
	local argslist = string.split(config.args, ",")
	return tonumber(argslist[1])
end

function CGuideHelpCtrl.GetRide(self)
	local config = data.guideconfigdata.GUIDENOTPLAY["Ride"]
	if not config then
		return
	end
	local argslist = string.split(config.args, ",")
	return tonumber(argslist[1])
end

--------------引导新调整------------------

function CGuideHelpCtrl.CheckAllNotifyGuide(self)
	--暂时屏蔽
	-- if true then return end
	for k,v in pairs(define.GuideNotify.Order) do
		self:ShowNotifyDetail(v)
	end
end

function CGuideHelpCtrl.ShowNotify(self, iType)
	CGuideNotifyView:ShowView(function (oView)
		oView:RefreshUI(iType)
	end)

	if iType == define.GuideNotify.Type.Ride then
		g_GuideHelpCtrl.m_IsOnlineShowLeadRideGet = true
		g_GuideCtrl:OnTriggerAll()
	end
end

--这里的条件基本跟guidedata的一致
function CGuideHelpCtrl.ShowNotifyDetail(self, iType)
	local oHasPlay = self:GetIsGuideExtraInfoKeyExist("hasplay")
	local oNotPlay = self:GetIsGuideExtraInfoKeyExist("notplay")
	if not (oHasPlay or oNotPlay) then
		return
	end
	local oHasDone = self:GetIsGuideExtraInfoKeyExist(iType)
	if oHasDone then
		return
	end
	if iType == define.GuideNotify.Type.GradeGift10 and --oHasPlay and 
	g_OpenSysCtrl:GetOpenSysState(define.System.UpgradePack) and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(10) then
		self:NotifySendToGS(iType)
	end
	if iType == define.GuideNotify.Type.GradeGift20 and 
	g_OpenSysCtrl:GetOpenSysState(define.System.UpgradePack) and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(20) then
		self:NotifySendToGS(iType)
	end
	if iType == define.GuideNotify.Type.GradeGift30 and 
	g_OpenSysCtrl:GetOpenSysState(define.System.UpgradePack) and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(30) then
		self:NotifySendToGS(iType)
	end
	if iType == define.GuideNotify.Type.GradeGift40 and 
	g_OpenSysCtrl:GetOpenSysState(define.System.UpgradePack) and g_UpgradePacksCtrl:IsCanRewardUpgragePackByGrade(40) then
		self:NotifySendToGS(iType)
	end
	if iType == define.GuideNotify.Type.XiuLian and 
	g_OpenSysCtrl:GetOpenSysState(define.System.Cultivation) then
		self:NotifySendToGS(iType)
	end
	if iType == define.GuideNotify.Type.GetPartner and 
	( g_GuideHelpCtrl:CheckNecessaryCondition("GetPartner", true) and not g_PartnerCtrl:GetRecruitPartnerDataByID(g_GuideHelpCtrl:GetPartner1()) ) and g_OpenSysCtrl:GetOpenSysState(define.System.Partner) then
		self:NotifySendToGS(iType)
	end
	if oNotPlay and iType == define.GuideNotify.Type.OrgSkill and 
	g_OpenSysCtrl:GetOpenSysState(define.System.OrgSkill)then
		self:NotifySendToGS(iType)
	end
	if iType == define.GuideNotify.Type.Ride and 
	g_OpenSysCtrl:GetOpenSysState(define.System.Horse) and g_GuideHelpCtrl.m_PreOpenInfoInit and g_GuideHelpCtrl:GetIsRideGuideFit() then
		self:NotifySendToGS(iType)
	end
end

function CGuideHelpCtrl.NotifySendToGS(self, iType)
	if self.m_GuideInfoInit and not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist(iType) then
		table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, iType)
		g_GuideHelpCtrl.m_GuideExtraInfoHashList[iType] = true
		local list = {exdata = g_GuideHelpCtrl:TurnGuideExtraListToStr()}
		local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
		netnewbieguide.C2GSUpdateNewbieGuideInfo(encode.mask, encode.guide_links, encode.exdata)

		self:ShowNotify(iType)
	end
end

----------------------------------------------------

--对许仙进行升阶，写死的
function CGuideHelpCtrl.GetPartner2(self)
	return 10001
end

--升阶的材料，写死的
function CGuideHelpCtrl.CheckPartner2UpgradeCondition(self)
	local sysState = not g_OpenSysCtrl.m_IsSysOpenShowing
	local partnerConfig = data.partnerdata.INFO[self:GetPartner2()]
	return g_ItemCtrl:GetBagItemAmountBySid(partnerConfig.cost.id) > 0 and g_ItemCtrl:GetBagItemAmountBySid(30660) >= 5 and sysState 
	and g_PartnerCtrl:GetRecruitPartnerDataByID(self:GetPartner2()) and g_PartnerCtrl:GetRecruitPartnerDataByID(self:GetPartner2()).quality < #data.partnerdata.QUALITY
	and g_OpenSysCtrl:GetOpenSysState(define.System.PartnerJJ) and g_OpenSysCtrl:GetOpenSysState(define.System.Partner)
end

--第二个宠物的配置id，写死的
function CGuideHelpCtrl.GetSummon2(self)
	return 1002
end

function CGuideHelpCtrl.CheckTaskGuideState(self)
	--暂时屏蔽
	-- if g_GuideHelpCtrl.m_GuideInfoInit then
	-- 	local sCondition1 = CGuideData["Task1"].necessary_condition
	-- 	local sCondition2 = CGuideData["Task2"].necessary_condition
	-- 	if (self.m_GuideConfigList["Task1"] and g_GuideCtrl:CallGuideFunc(sCondition1) and not g_GuideCtrl.m_Flags["Task1"]) 
	-- 	or (self.m_GuideConfigList["Task2"] and g_GuideCtrl:CallGuideFunc(sCondition2) and not g_GuideCtrl.m_Flags["Task2"]) then
	-- 		return true
	-- 	end
	-- end
	return false
end

function CGuideHelpCtrl.GetSummonComposeTypeId(self)
	return {2029, 2030}
end

return CGuideHelpCtrl
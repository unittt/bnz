local CSummonCtrl = class("CSummonCtrl", CCtrlBase)

function CSummonCtrl.ctor(self)	
	CCtrlBase.ctor(self)
	self:Clear()
	self:CheckXiYouConfig()
	self:InitAptiConfig()

	self.m_UnlockTab = {
		[1] = "",
		[2] = define.System.SummonLy,
		[3] = "",
	}
end

-- 打开UI界面Open处理 Begin
function CSummonCtrl.ShowView(self, cls, cb)
	local defaultIndex = self:GetDefaultTabIndex()
	if defaultIndex then
		CViewBase.ShowView(cls, cb)
	end
end

function CSummonCtrl.GetDefaultTabIndex(self)
	for i,v in ipairs(self.m_UnlockTab) do
		local open = g_OpenSysCtrl:GetOpenSysState(v)
		if open then
			return i
		end
	end
end

function CSummonCtrl.IsSpecityTabOpen(self, index)
	local openKey = self.m_UnlockTab[index]
	if openKey == "" then
		return true
	end
	return g_OpenSysCtrl:GetOpenSysState(openKey)
end
-- 打开UI界面Open处理 End

function CSummonCtrl.Clear(self)
	self.m_SummonsDic = {}
	self.m_SummonsSort = {}
	self.m_CurSelSummonId = nil
	self.m_CompoundInfo = nil
	self.m_WashNewid = 0
	self.m_FollowId = 0
	self.m_FightId = nil
	self.m_SummonMax = 10 --最大宠物格子
	self.m_CurSummonBoxCnt = 5 --当前宠物格子
	self.m_SummonSkillMax = 12	--最大宠物技能格子
	self.m_ExtSize = 0 -- 扩展携带宠物上限个数
	self.m_EffRecord = {}
	self.m_RightCompoundId = nil
	self.m_LeftCompoundId = nil
	--以下是宠物仓库
	self.m_CKExtSize = 4
	self.m_CKSummondata = {}
	self.m_CKChooseSum = nil
	self.m_NpcDict = nil
	self.m_StudyTab = nil
end

function CSummonCtrl.InitAptiConfig(self)
    self.m_AptiConfig = {
        {key = "attack", name = "攻击资质"},
        {key = "defense", name = "防御资质"},
        {key = "health", name = "体力资质"},
        {key = "mana", name = "法力资质"},
        {key = "speed", name = "速度资质"},
        {key = "grow", name = "成   长"},
    }
end

function CSummonCtrl.GetAptiConfig(self)
	return self.m_AptiConfig
end

-- 获取累计经验值
function CSummonCtrl.GetCumulativeSummonExp(self, lv)
	if lv <= 0 then
		return 0
	end
	return data.upgradedata.DATA[lv].sum_summon_exp
end

function CSummonCtrl.SetInitPropertyInfo(self, dPb, fightid, extsize)
	if dPb == nil then
		printc("当前没有宠物信息")
		return
	end
	self.m_SummonsDic = {}
	self.m_SummonsSort = {}
	self.m_CurSelSummonId = nil
	self.m_FightId = fightid
	self.m_CurSummonBoxCnt = self.m_CurSummonBoxCnt
	self.m_ExtSize = extsize
	for i,v in pairs(dPb) do
		self.m_SummonsDic[v.id] = v
		table.insert(self.m_SummonsSort, v)		
	end		
	table.sort(self.m_SummonsSort,function (a, b)		
		if a ~= nil and b ~= nil then 
			if a.typeid ~= b.typeid then
				return a.typeid > b.typeid
			else
				return a.traceno < b.traceno
			end
		end 
	end)
	if #self.m_SummonsSort > 0 and not self.m_FightId then
		self.m_CurSelSummonId = self.m_SummonsSort[1].id
	end
	
	self:GetSummonEffRecord()
	self:OnEvent(define.Summon.Event.UpdateRedPoint)
	self:OnEvent(define.Summon.Event.SetFightId)
end

function CSummonCtrl.UpdateMaskInfo(self, dPb, id)
	for k,v in pairs(dPb) do
		if k == "grade" and self.m_SummonsDic[id][k] ~= v then
			g_AudioCtrl:PlaySound(define.Audio.SoundPath.Summon)
		end
		if self.m_SummonsDic[id][k] ~= nil and  k ~= "mask" and v ~= self.m_SummonsDic[id][k] then
			self.m_SummonsDic[id][k] = v
		end
	end
	for i,v in ipairs(self.m_SummonsSort) do
		if v.id == id then
			self.m_SummonsSort[i] = self.m_SummonsDic[id]	
		end
	end
	self:OnEvent(define.Summon.Event.UpdateSummonInfo, self.m_SummonsDic[id])
end

function CSummonCtrl.AddSummon(self, summondata)
	g_AudioCtrl:PlaySound(define.Audio.SoundPath.Summon)
	self.m_SummonsDic[summondata.id] = summondata
	table.insert(self.m_SummonsSort,summondata)	
	table.sort(self.m_SummonsSort,function (a, b)		
		if a ~= nil and b ~= nil then 
			if a.typeid ~= b.typeid then
				return a.typeid > b.typeid
			else
				return a.traceno < b.traceno
			end
		end 
	end)
	if self.WashNewid == summondata.id then
		self.m_CurSelSummonId = summondata.id
		self:OnEvent(define.Summon.Event.WashSummonAdd, summondata)
		self.WashNewid = 0
	else
		self.m_CurSelSummonId = summondata.id
		self:AddRedPointEffectRecord(summondata)
		self:OnEvent(define.Summon.Event.AddSummon, summondata)
	end
end

function CSummonCtrl.SetFightid(self, id)
	self.m_FightId = id
	self:OnEvent(define.Summon.Event.SetFightId, id)
end

function CSummonCtrl.GetFightid(self)
	return self.m_FightId 
end

function  CSummonCtrl.GetWashNewid(self)
	return self.m_WashNewid
end

function CSummonCtrl.SetCurSelSummon(self, id)
	self.m_CurSelSummonId = id 
end

function CSummonCtrl.GetCurSelSummon(self)
	-- 有出战宠物默认选中
	if not self.m_CurSelSummonId then
		if self.m_FightId and self.m_FightId ~= 0 then
			self.m_CurSelSummonId = self.m_FightId
		else
			self.m_CurSelSummonId = self:GetSummonIdByIndex(1)
		end
	end
	return self.m_CurSelSummonId
end

function CSummonCtrl.GetCurSummonInfo(self)
	local iSummonId = self:GetCurSelSummon()
	if iSummonId then
		return self.m_SummonsDic[iSummonId]
	end
end

function CSummonCtrl.GS2CDelSummon(self, id, newid)
	self.m_SummonsDic[id] = nil
	if next(self.m_SummonsDic) == nil then
		self:SetCurSelSummon(nil)
	end
	local traceno = nil
	for k,v in pairs(self.m_SummonsSort) do
	   if v.id == id then 
	   		 traceno = v.traceno
	   		 table.remove(self.m_SummonsSort, k)		 	
	   		break
	   end
	end
	if id == self.m_CurSelSummonId then
		self.m_CurSelSummonId = nil
	end
	self.WashNewid = newid
	self:DelSummonItem(traceno)
	if newid ~= 0 then 
	 	self:OnEvent(define.Summon.Event.WashDelSummon, traceno)
	else
		self:OnEvent(define.Summon.Event.DelSummon, traceno) 
		self:DelRedPointEffectRecord(traceno)
	end
end

function CSummonCtrl.GetSummon(self, summonid)
	return self.m_SummonsDic[summonid]
end

function CSummonCtrl.GetSummonAmount(self)
	return #self.m_SummonsSort
end

function CSummonCtrl.IsSummonPoint(self)
	for k,v in pairs(self.m_SummonsSort) do
		if v["point"] > 0 then
			return v.id
		end
	end
	return false
end

function CSummonCtrl.GetSummons(self)
	return self.m_SummonsDic
end

--宠物合成引导使用
function CSummonCtrl.GetIsNeedSummonComposeGuide(self)
	local bIsNeed1 = false
	local bIsNeed2 = false
	for k,v in pairs(self.m_SummonsDic) do
		if v.typeid == g_GuideHelpCtrl:GetSummonComposeTypeId()[1] then--and v.rank == "A" then
			bIsNeed1 = true
			break
		end
	end
	for k,v in pairs(self.m_SummonsDic) do
		if v.typeid == g_GuideHelpCtrl:GetSummonComposeTypeId()[2] then--and v.rank == "A" then
			bIsNeed2 = true
			break
		end
	end
	return bIsNeed1 and bIsNeed2
end

function CSummonCtrl.GetSummonIdByIndex(self, index)
	if next(self.m_SummonsSort) == nil then
		return nil
	end
	return self.m_SummonsSort[index].id
end

function CSummonCtrl.GetCurFightSummonInfo(self)
	if self.m_FightId ~= nil and self.m_FightId ~= 0  then
		return self.m_SummonsDic[self.m_FightId]
	else
		return nil
	end
end

function CSummonCtrl.StudySkill(self, summonid, skillid)
	netsummon.C2GSStickSkill(summonid,skillid)	
end

function CSummonCtrl.StudySkillUpGrade(self, summonid, skillid)
	netsummon.C2GSSummonSkillLevelUp(summonid,skillid)
end

function CSummonCtrl.ChangeName(self, summonid, name)
	netsummon.C2GSSummonChangeName(summonid,name)
end

function CSummonCtrl.UpdatePoint(self, summonid, data)
	netsummon.C2GSSummonAssignPoint(summonid,data)
end

function CSummonCtrl.ReleaseSummon(self, summonid)
	netsummon.C2GSReleaseSummon(summonid)
end

function CSummonCtrl.UpdateScheme(self, summonid, data)
	netsummon.C2GSSummonAutoAssignScheme(summonid, data)
end

function CSummonCtrl.IsOpenAutoAssign(self, summonid, flag)
	netsummon.C2GSSummonOpenAutoAssign(summonid, flag)
end

function CSummonCtrl.SetFight(self, summonid, fight)
	netsummon.C2GSSummonSetFight(summonid, fight)
end

function CSummonCtrl.SendIsFollow(self, summonid, flag)
	netsummon.C2GSSummonFollow(summonid, flag)
end

function CSummonCtrl.WashSummon(self, summonid)
	netsummon.C2GSWashSummon(summonid)
end

function CSummonCtrl.SendCombineSummon(self, summonid1, summonid2)
	netsummon.C2GSCombineSummon(summonid1, summonid2)
end

function CSummonCtrl.ReceiveCombineSummon(self, summonid1, summonid2,newsummonid)
	self:ClearCompoundSelRecord()
	CSummonComOutView:ShowView(function (oView)
		oView:SetData(newsummonid)
	end)
	self:OnEvent(define.Summon.Event.CombineSummonShow, newsummonid)
end

function CSummonCtrl.ReceiveFollowId(self, id)
	self.m_FollowId = id 
	self:OnEvent(define.Summon.Event.SetFollow, id)
end

function CSummonCtrl.NotFollowSummon(self)
	if self.m_FollowId then
		self:SendIsFollow(self.m_FollowId, 2)		
	end
end

function CSummonCtrl.C2GSUseAptitudePellet(self, summonid, aptitude, flag)
	netsummon.C2GSUseAptitudePellet(summonid, aptitude, flag)
end

function CSummonCtrl.C2GSUseSummonExpBook(self, summonid, count)
	netsummon.C2GSUseSummonExpBook(summonid, count)
end

function CSummonCtrl.C2GSUseLifePellet(self, summonid, count,sid)
	netsummon.C2GSUseLifePellet(summonid, count,sid)
end

function CSummonCtrl.C2GSUsePointPellet(self, summonid, attr)
	if attr == nil then 
		attr = 6
	end 
	netsummon.C2GSUsePointPellet(summonid, attr)
end

function CSummonCtrl.C2GSSummonRestPointUI(self, summonid)
	netsummon.C2GSSummonRestPointUI(summonid)
end

function CSummonCtrl.C2GSSummonRequestAuto(self, summonid)
	netsummon.C2GSSummonRequestAuto(summonid)
end

function CSummonCtrl.C2GSExchangeSummon(self, id)
	netsummon.C2GSExchangeSummon(id)
end 

--GS2C
function CSummonCtrl.GS2CSummonInitAttrInfo(self, id, initaddattr)
	CSummonWashPointView:ShowView(function(oView)
		oView:SetData(id, initaddattr)		
	end)
end

function CSummonCtrl.GS2CSummonAutoAssignScheme(self, id, switch, scheme)
	CSummonAddPointSchemeView:ShowView(function(oView)
		oView:SetData(id, scheme)		
	end)
end

function CSummonCtrl.GS2CGetSummonSecProp(self, info)
	for k,v in pairs(info) do
		self.m_SummonsDic[v.summid][v.name] = v.base + v.extra + v.ratio 
		self.m_SummonsDic[v.summid][v.name .. "_extra"] = v.extra
		self.m_SummonsDic[v.summid][v.name .. "_ratio"] = v.ratio 
	end
	self:OnEvent(define.Summon.Event.GetSummonSecProp)
end

-----------------------------------------------------------
--道具使用打开界面
function CSummonCtrl.CheckSummon(self)
	if next(self.m_SummonsDic) == nil then  
		g_NotifyCtrl:FloatMsg("您当前没有宠物!")
		return false
	end 
	return true
end

function CSummonCtrl.ShowWashView(self)--还童丹
	if self:CheckSummon() == false then 
		return
	end
	CSummonMainView:ShowView(function (view)
		view:ShowSubPageByIndex(view:GetPageIndex("Adjust"))
	end)	
end

function CSummonCtrl.ShowSutdySkillView(self)--技能石
	if self:CheckSummon() == false then 
		return
	end
	CSummonMainView:ShowView(function (view)
		view:ShowSubPageByIndex(view:GetPageIndex("Adjust"))
		local part = view:GetCurrentPage()
		part:OnStudySkill()
	end)	
end

function CSummonCtrl.ShowCultureView(self)--资质丹
	if self:CheckSummon() == false then 
		return
	end
	CSummonMainView:ShowView(function (view)
		view:ShowSubPageByIndex(view:GetPageIndex("Adjust"))
		local part = view:GetCurrentPage()
		part:OnCulture()
	end)	
end

function CSummonCtrl.ShowWashPointView(self, bShowReset)--洗点丹
	if self:CheckSummon() == false then 
		return
	end
	    CSummonMainView:ShowView(function (view)
			view:ShowSubPageByIndex(view:GetPageIndex("Property"))
			local part = view:GetCurrentPage()
			part:ShowAddPtView(bShowReset)
	end)	
end

function CSummonCtrl.ShowPropertyView(self, iItemId)--宠物经验,奇异丹,宠物寿命丹
	if self:CheckSummon() == false then 
		return
	end
	CSummonMainView:ShowView(function (view)
		view:ShowSubPageByIndex(view:GetPageIndex("Property"))
		if iItemId then
			view:HandleItemTip(iItemId)
		end
	end)
end

function CSummonCtrl.ShowSummonStudyBookView(self) --宠物打书
	if self:CheckSummon() == false then 
		return
	end
	CSummonMainView:ShowView(function (view)
		view:ShowSubPageByIndex(view:GetPageIndex("Adjust"))
		local part = view:GetCurrentPage()
		part:OnStudySkill()
	end)
end

function CSummonCtrl.ShowCompoundView(self) --宠物合成
	if self:CheckSummon() == false then 
		return
	end
	CSummonMainView:ShowView(function (view)
		view:ShowSubPageByIndex(view:GetPageIndex("Adjust"))
		local part = view:GetCurrentPage()
		part:OnCompoundShow()
	end)
end

--显示宠物合成预览界面
function CSummonCtrl.ShowComposePreView(self, iSum1, iSum2)
	local oSum1, oSum2 = self.m_SummonsDic[iSum1], self.m_SummonsDic[iSum2]
	if not oSum1 or not oSum2 then
		g_NotifyCtrl:FloatMsg("请选择要合成的宠物哦")
		return
	end
	CSummonComposePreView:ShowView(function (oView)
		oView:RefreshUI(oSum1, oSum2)
	end)
end

---------------------- 红点 --------------------------
function CSummonCtrl.AddRedPointEffectRecord(self, summondata)
	-- 野生宠不显示红点
	if summondata.type == 1 then return end
	self.m_EffRecord[tostring(summondata.traceno)] = {}
	self.m_EffRecord[tostring(summondata.traceno)].id = summondata.id
	IOTools.SetRoleData("summon_EffRecord_"..g_AttrCtrl.pid, self.m_EffRecord)
	self:OnEvent(define.Summon.Event.UpdateRedPoint, true)
end

function CSummonCtrl.DelRedPointEffectRecord(self, traceno)
	if self.m_EffRecord[tostring(traceno)] then
		self.m_EffRecord[tostring(traceno)] = nil
		IOTools.SetRoleData("summon_EffRecord_"..g_AttrCtrl.pid, self.m_EffRecord)
		self:DelayEvent(define.Summon.Event.UpdateRedPoint, false)
		g_PromoteCtrl:DelSys("SUMMON_NEW")
	end
end

function CSummonCtrl.GetSummonEffRecord(self)
	if next(self.m_EffRecord) == nil then
		self.m_EffRecord = IOTools.GetRoleData("summon_EffRecord_"..g_AttrCtrl.pid) or {}
		local bSave = false
		for k, d in pairs(self.m_EffRecord) do
			if d.id <= 0 then
				self.m_EffRecord[k] = nil
				bSave = true
			end
		end
		if bSave then
			self:SaveSummonEffRecord(nil, true)
		end
	end
	return self.m_EffRecord
end

function CSummonCtrl.SaveSummonEffRecord(self, data, flag)
	if data then
		self.m_EffRecord = data
	end
	if flag then 
		IOTools.SetRoleData("summon_EffRecord_"..g_AttrCtrl.pid, self.m_EffRecord)
	end
end

function CSummonCtrl.IsHasRedPoint(self)
	local dEff = self:GetSummonEffRecord()
	for _, d in pairs(self.m_EffRecord) do
		if d.id and self.m_SummonsDic[d.id] then
			return true
		end
	end
	return false
end

function CSummonCtrl.IsSummonHasRedPoint(self, iSummon)
	local dEff = self:GetSummonEffRecord()
	for _, d in pairs(self.m_EffRecord) do
		if iSummon == d.id then
			return true
		end
	end
	return false
end
---------------------------------------------

function CSummonCtrl.GetAuctionSummonList(self)
	local list = {}
	for i,summon in pairs(self.m_SummonsDic) do
		if summon.grade < (g_AttrCtrl.server_grade - 10) and summon.id ~= self.m_FightId and 
			DataTools.GetAuctionItemData(summon.typeid)	~= nil then
			table.insert(list, summon)
		end
	end
	return list
end

function CSummonCtrl.GetIsSummonExistByTypeId(self, typeid)
	for k,v in pairs(self.m_SummonsDic) do
		if v.typeid == typeid then
			return true
		end
	end
end

function CSummonCtrl.CheckXiYouConfig(self)
	self.m_SumXiYouConfig = {}
	table.copy(data.summondata.XIYOU, self.m_SumXiYouConfig)
	-- if self.m_SumXiYouConfig[2].sid3 == 1003 then
	-- 	table.remove(self.m_SumXiYouConfig, 2)
	-- end
end

----------------  new ----------------------
function CSummonCtrl.GetCopoundData(self)
	if not self.m_CompoundInfo then
	    local CopoundData = data.summondata.XIYOU
	    local tempData = {}
	    for i,v in ipairs(CopoundData) do
	        tempData[v.sid3] = v
	    end
	    self.m_CompoundInfo = tempData
	end
    return self.m_CompoundInfo
end

function CSummonCtrl.DelSummonItem(self, traceno)
	local sTn = tostring(traceno)
	if self.m_EffRecord[sTn] then
		self.m_EffRecord[sTn] = nil
		self:SaveSummonEffRecord(self.m_EffRecord, true)
	end 
	self:OnEvent(define.Summon.Event.UpdateRedPoint)
end

-- 合成材料
function CSummonCtrl.GetCompoundMatList(self)
	local matList = {}
	for k, v in ipairs(self.m_SummonsSort) do
		if v.id ~= self.m_LeftCompoundId and v.id ~= self.m_RightCompoundId and not SummonDataTool.IsExpensiveSumm(v.type) and v.type > 1 then--SummonDataTool.IsRare(v) then
			table.insert(matList, v)
		end
	end
	return matList
end

function CSummonCtrl.GetSummonByTypeIds(self, summonIds)
	local summons = {}
	for k, v in ipairs(self.m_SummonsSort) do
		if not (v.id == self.m_LeftCompoundId or v.id == self.m_RightCompoundId) then
			for _, id in ipairs(summonIds) do
				if v.typeid == id then
					table.insert(summons, v)
					break
				end
			end
		end
	end
	return summons
end

function CSummonCtrl.SelCompoundMat(self, dSummon, bRight)
	local dEventData = {
		dSummon = dSummon,
		bRight = bRight,
	}
	if bRight then
		self.m_RightCompoundId = dSummon.id
	else
		self.m_LeftCompoundId = dSummon.id
	end
	self:OnEvent(define.Summon.Event.SetCompoundSummon, dEventData)
end

function CSummonCtrl.ClearCompoundSelRecord(self)
	self.m_RightCompoundId = nil
	self.m_LeftCompoundId = nil
end

function CSummonCtrl.SelSummonStudyItem(self, itemInfo)
	self:OnEvent(define.Summon.Event.SelStudyItem, itemInfo)
end

function CSummonCtrl.ChangeSummonShow(self, iSummonId)
	self.m_CurSelSummonId = iSummonId
	self:OnEvent(define.Summon.Event.ChangeSummonShow, iSummonId)
end

function CSummonCtrl.CheckGuildItemList(self, iCat, iSub, dInfo)
	-- 是否是宠物信息
	if iCat==2 and (iSub==1 or iSub==2) then
		local itemList = {}
		for i, v in ipairs(dInfo) do
			local itemId = v.sid
			local dItem = DataTools.GetItemData(itemId, "SUMMSKILL")
			local iSkId = dItem.skid
			local dSk = iSkId and SummonDataTool.GetSummonSkillInfo(iSkId)
			-- 暂不显示潜能
			if dSk then -- itemId == 30000 or 
				local d = {}
				d.price = v.price
				d.goodId = v.good_id
				d.id = itemId
				d.skid = iSkId
				
				if dSk then
					d.sortId = dSk.sort_id
					d.skType = dSk.skill_type
				end
				table.insert(itemList, d)
			end
		end
		local dCurSumm = self:GetCurSummonInfo()
		if not dCurSumm then return end
		local dSumm = SummonDataTool.GetSummonInfo(dCurSumm.typeid)
		local iSummType = 1 == dSumm.autopoint and 0 or 1
		table.sort(itemList, function(a, b)
			-- if not a.skType and not b.skType then
			-- 	return a.skid < b.skid
			-- elseif not a.skType or not b.skType then
			-- 	return b.skType and true or false
			-- end
			if a.skType == b.skType then
				return a.sortId < b.sortId
			elseif a.skType == iSummType or b.skType == iSummType then
				return a.skType == iSummType
			else -- 类型2排在中间
				return a.skType == 2
			end
		end)
		local dEventData = {
			info = itemList,
			subId = iSub,
		}
		self:OnEvent(define.Summon.Event.ReceiveGuildInfo, dEventData)
	end
end

function CSummonCtrl.SetStudyGuildItem(self, itemId)
	self.m_StudyGuildItemId = itemId
	if itemId then
		self.m_StudyGuildItemCnt = g_ItemCtrl:GetBagItemAmountBySid(itemId)
	else
		self.m_StudyGuildItemCnt = nil
	end
end

function CSummonCtrl.GetStudyGuildItemInfo(self)
	if self.m_StudyGuildItemId then
		local dItem = {
			id = self.m_StudyGuildItemId,
			cnt = self.m_StudyGuildItemCnt,
		}
		return dItem
	end
end

function CSummonCtrl.CheckBuyGuildItem(self, dGuild)
	local iRecord = self.m_StudyGuildItemId
	if iRecord and iRecord == dGuild.sid then
		local itemList = g_ItemCtrl:GetBagItemListBySid(iRecord)
		if itemList and #itemList > 0 then
            local dItem = DataTools.GetItemData(iRecord, "SUMMSKILL")
            if dItem.skid or iRecord == 30000 then
            	local itemObjId = itemList[1].m_ID
            	self:StudySkill(self.m_CurSelSummonId, itemObjId)
                self:SetStudyGuildItem(nil)
            end
		end
	end
end

--//宠物仓库部分哟

function CSummonCtrl.GS2CLoginCkSummon(self, summondata, extsize) --登陆时就会有消息下发
	-- body
	self.m_CKSummondata = summondata 
	if extsize ~= 0 then
		self.m_CKExtSize = 4 + extsize 
	end
end

function CSummonCtrl.ShowCKView(self) --点击NPC
	local oView = CSummonWarehouseView:ShowView(function (oView)
		-- body
		oView:SetCKSummonData(self.m_CKSummondata, self.m_CKExtSize)
	end)
end


function CSummonCtrl.GS2CSummonCkExtendSize(self, extcksize)  --增加格子
	-- body
	if extcksize then

		self.m_CKExtSize = 4 + extcksize
		self:OnEvent(define.Summon.Event.AddCkExtendSize, self.m_CKExtSize)
	end
end


function CSummonCtrl.GS2CSummonExtendSize(self, extsize) --携带宠物上限增加
	-- body
	if self.m_ExtSize and extsize > self.m_ExtSize then
		g_NotifyCtrl:FloatMsg(string.format("宠物格子成功拓展至%d个", 5 + extsize))
	end
	self.m_ExtSize = extsize
	self:OnEvent(define.Summon.Event.AddExtendSize, extsize)
end

function CSummonCtrl.GS2CAddCkSummon(self, summondata)  --存入仓库
	-- body
	table.insert(self.m_CKSummondata, summondata)
	self:OnEvent(define.Summon.Event.AddCKSummon, summondata)
end

function CSummonCtrl.GS2CDelCkSummon(self, id) -- 取回
	-- body
	local dSummon = nil
	for i,v in ipairs(self.m_CKSummondata) do
		if id == v.id then
			dSummon = v
			table.remove(self.m_CKSummondata, i)
			break
		end
	end
	self:OnEvent(define.Summon.Event.DelCKSummon, dSummon)
end

function CSummonCtrl.CKChooseSum(self, sumid)
	-- body
	self.m_CKChooseSum = sumid
end

-- 装备合成
function CSummonCtrl.SummonEquipCombine(self, itemId)
	self:OnEvent(define.Summon.Event.SummonEquipCombine, itemId)
end

-- 珍兽/神兽合成界面
function CSummonCtrl.ShowComposePreById(self, iSummonId)
	CSummonComposePreView:ShowView(function (oView)
		oView:ShowSpecificSumm(iSummonId)
	end)
end

function CSummonCtrl.ExchangeSpcSummon(self, iSummonId)
	local excList = SummonDataTool.GetSpcExchanges(iSummonId)
	if #excList < 1 then
		printc("没有兑换配置----------", iSummonId)
		return
	end
	local dConfig = excList[1]
	if dConfig.sid1~=0 and dConfig.sid2~=0 then
		local sid1List = self:GetSummonByTypeIds({dConfig.sid1})
		local sid2List = self:GetSummonByTypeIds({dConfig.sid2})
		if next(sid1List) and next(sid2List) then
	        CSummonSpcComposeView:ShowView(function(oView)
	            oView:SetData(iSummonId)
	        end)
	    else
	    	local dSummon1 = SummonDataTool.GetSummonInfo(dConfig.sid1)
	    	local dSummon2 = SummonDataTool.GetSummonInfo(dConfig.sid2)
	    	g_NotifyCtrl:FloatMsg(string.format("您身上没有%s和%s，无法合成", dSummon1.name, dSummon2.name))
	    end
	else
		local dConfig = self:CheckAllExchangeItem(iSummonId, function()
			local excList = SummonDataTool.GetSpcExchanges(iSummonId)
			if excList and excList[1] then
				netsummon.C2GSShenShouExchange(excList[1].eid,nil,nil,1)
			end
		end)
		if not dConfig then return end
		local dCost = dConfig.cost[1]
		if not dCost then return end
		local dItem = DataTools.GetItemData(dCost.sid) or {}
	    local dSumm = SummonDataTool.GetSummonInfo(iSummonId)
	    local windowTipInfo = {
	        msg = string.format("是否使用%d个%s兑换%s", dCost.num, dItem.name, dSumm.name),
	        okCallback = function () 
	            netsummon.C2GSShenShouExchange(dConfig.eid)
	        end,
	    }
	    g_WindowTipCtrl:SetWindowConfirm(windowTipInfo)
	end
end

function CSummonCtrl.CheckAllExchangeItem(self, iSummonId, cb)
	local excList = SummonDataTool.GetSpcExchanges(iSummonId)
	local iCnt = #excList
	for i, dExc in ipairs(excList) do
		local bEnough = self:CheckExchangeItemCnt(dExc)
		if bEnough then
			return dExc
		elseif i >= iCnt then
			local dItem = dExc.cost[1]
			local iCnt = g_ItemCtrl:GetBagItemAmountBySid(dItem.sid)
		    local t = {
		        sid = dItem.sid,
		        count = iCnt,
		        amount = dItem.num or 0,
		    }
			g_QuickGetCtrl:CurrLackItemInfo({t},{},nil,cb)
			return nil
		end
	end
end

function CSummonCtrl.CheckExchangeItemCnt(self, dExc)
	for i, v in ipairs(dExc.cost) do
		local iCnt = g_ItemCtrl:GetBagItemAmountBySid(v.sid)
		if iCnt < v.num then
			return false
		end
	end
	return true
end

-- 合宠积分
function CSummonCtrl.GetSummonComposeScore(self)
	if not self.m_LeftCompoundId or not self.m_RightCompoundId then
		return
	end
    local dLSummon = self:GetSummon(self.m_LeftCompoundId)
    local dRSummon = self:GetSummon(self.m_RightCompoundId)
    if not dLSummon or not dRSummon then
    	return
    end
    local iScore = SummonDataTool.GetComposeScore(dLSummon, dRSummon) + 5
    return iScore
end

function CSummonCtrl.GetTaskNeedSumCount(self, oSumSid, isBaoBaoSubmit)
	local summonCount = 0
	for _,summonData in pairs(self.m_SummonsDic) do
		if isBaoBaoSubmit then
			if summonData.typeid == oSumSid and summonData.key ~= 1 and (summonData.type == 1 or (summonData.type == 2 and summonData.zhenpin == 0)) and summonData.id ~= g_SummonCtrl.m_FightId then --or summonData.grade == 0
				summonCount = summonCount + 1
			end
		else
			if summonData.typeid == oSumSid and summonData.key ~= 1 and (summonData.type == 1) and summonData.id ~= g_SummonCtrl.m_FightId then --or summonData.grade == 0
				summonCount = summonCount + 1
			end
		end
	end
	return summonCount
end

-- 暂不导表
function CSummonCtrl.GetExchangeNpcId(self, iSummonId)
	if not self.m_NpcDict then
		self.m_NpcDict = {
	        [5001] = 5288,
	        [5002] = 5287,
	        [5003] = 5289,
	        [4002] = 5290,
	        [5004] = 5291,
	        [5005] = 5292,
	        [5006] = 5293,
	    }
	end
	return self.m_NpcDict[iSummonId]
end

function CSummonCtrl.GotoExchangeNpc(self, iSummonId)
    if g_WarCtrl:IsWar() then
        g_NotifyCtrl:FloatMsg("请脱离战斗后再进行操作")
       return
	elseif g_KuafuCtrl:IsInKS(true) then
		return
	end
	local iNpc = self:GetExchangeNpcId(iSummonId)
	if iNpc then
		g_MapTouchCtrl:WalkToGlobalNpc(iNpc)
		CItemMainView:CloseView()
		CSummonMainView:OnClose()
	end
end

function CSummonCtrl.GS2CSummonWashTips(self, iSummId)
    CSummonWashComfirmView:ShowView(function(oView)
        oView:SetSummonId(iSummId)
    end)
end

--------------------- 进阶 ---------------------
function CSummonCtrl.GetSummonAdvList(self)
	local summonList = {}
	for i, v in ipairs(self.m_SummonsSort) do
		if SummonDataTool.IsGodSummon(v.type) then
			table.insert(summonList, v)
		end
	end
	return summonList
end

function CSummonCtrl.GetSummonZhenshouAdvList(self)
	local summonList = {}
	for i, v in ipairs(self.m_SummonsSort) do
		if v.type == 8 then
			table.insert(summonList, v)
		end
	end
	return summonList
end

function CSummonCtrl.ShowSummonAdvView(self, iSummon)
	local dSummon = SummonDataTool.GetSummonInfo(iSummon)
	if not self:GetIsSummonExistByTypeId(iSummon) and dSummon then
		g_NotifyCtrl:FloatMsg(string.format("你身上尚未携带%s，无法进行进阶", dSummon.name))
		return
	end
	CSummonAdvanceView:ShowView(function(oView)
		oView:SelectSummon(dSummon)
	end)
end

----------------------- 链接 ---------------------
function CSummonCtrl.ShowSummonLinkView(self, summonId, fixedIdx)
    local dConfig = data.summondata.FIXEDPROPERTY[fixedIdx]
    if not dConfig then return end
    local dLink = {}
    local dSummonInfo = table.copy(dConfig)
    self:SetSummonLinkFormulaVal(dSummonInfo, dLink)
    self:SetSummonLinkSkill(dSummonInfo, dLink)
    self:SetSummonLinkAptitude(dSummonInfo, dLink)
    self:SetSummonLinkOther(dSummonInfo, dLink, summonId)
    CSummonLinkView:ShowView(function(oView)
        oView:SetSummon(dLink)
    end)
end

function CSummonCtrl.SetSummonLinkFormulaVal(self, dSummonInfo, dLink)
    local dParams = {}
    for k, v in pairs(dSummonInfo) do
        if type(v) == "table" then
            for i, j in pairs(v) do
                if type(i) ~= "number" then
                    dParams[i] = j
                end
            end
        else
            dParams[k] = v
        end
    end
    local dFormulaDict = data.summondata.calformula
    local lCalcKey = {"max_hp", "max_mp", "phy_attack", "phy_defense", "mag_attack", "mag_defense", "speed"}
    local sFormula, val
    for _, key in ipairs(lCalcKey) do
        sFormula = dFormulaDict[key].formula
        val = string.eval(sFormula, dParams) --公式运算
        dLink[key] = math.floor(val)
    end
end

function CSummonCtrl.SetSummonLinkSkill(self, dSummonInfo, dLink)
    local handler = function(key)
        local list = {}
        for _, s in ipairs(dSummonInfo[key]) do
            table.insert(list, {sk = s, level = 1})
        end
        dLink[key] = list
    end
    handler("skill")
    handler("talent")
end

function CSummonCtrl.SetSummonLinkAptitude(self, dSummonInfo, dLink)
    dLink.curaptitude = dSummonInfo.aptitude
    dLink.maxaptitude = dSummonInfo.aptitude
end

function CSummonCtrl.SetSummonLinkOther(self, dSummonInfo, dLink, summonId)
    local dSummonConfig = DataTools.GetSummonInfo(summonId)
    dLink.score = dSummonConfig.type
    dLink.type = dSummonConfig.type
    dLink.name = dSummonConfig.name
    dLink.model_info = {shape = dSummonConfig.shape}
    dLink.typeid = summonId
    for k, v in pairs(dSummonInfo) do
        if not dLink[k] then
            dLink[k] = v
        end
    end
    self:SetSummonLinkScore(dLink, summonId)
end

function CSummonCtrl.SetSummonLinkScore(self, dLink, summonId)
    -- 宠物评分两部分 [[(aptitude+grow*1.3)/5]], 10*lv + 技能评分
    local formula = DataTools.GetSummonInfo(summonId).score
    local curaptitudeScore = 0
    for _, aptitude in pairs(dLink.curaptitude) do
        curaptitudeScore = curaptitudeScore + aptitude
    end

    formula = string.gsub(formula, "aptitude", curaptitudeScore)
    formula = string.gsub(formula, "grow", dLink.grow)
    local val = loadstring("return "..formula)
    val = dLink.grade*10 + val()   

    local skillscore  = 0
    for i,v in pairs(dLink.skill) do
        local str = data.summondata.SKILL[v.sk].fight_score
        str = string.gsub(str, "lv", v.level)
        skillscore = loadstring("return "..str)() + skillscore
    end
    for i,v in pairs(dLink.talent) do
        local str = data.summondata.SKILL[v.sk].fight_score
        str = string.gsub(str, "lv", v.level)
        skillscore = loadstring("return "..str)() + skillscore
    end
    local iScore = skillscore + val
    dLink.summon_score = iScore

    -- rank calc
    local sRank
    for _, info in pairs(data.summondata.SCORE) do
        local min, max = unpack(info["score"])
        if max then
            if iScore >= min and iScore < max then
                sRank = info.rank
                break
            end
        else
            if iScore > min then
                sRank = info.rank
                break
            end
        end
    end
    dLink.rank = sRank
end

function CSummonCtrl.GetSummonBindRideId(self, summonId)
	
	for k, summon in pairs(self.m_SummonsSort) do 
		if summon.id == summonId then 
			return summon.bind_ride
		end 
	end 

end

function CSummonCtrl.CheckQuickOrder(self)
	local dQuick = g_WarCtrl.m_QuickMagicIDSummon
	if not dQuick then
		return
	end
	for k, v in pairs(dQuick) do
		local dSumm = self:GetSummon(k)
		local bValue = false
		if dSumm then
			if v == 101 then
				bValue = true
			else
				local skList = SummonDataTool.GetSkillInfo(dSumm)
				for _, d in ipairs(skList) do
					local dSkill = SummonDataTool.GetSummonSkillInfo(d.sk)
					if dSkill and dSkill.pflist and next(dSkill.pflist) then
						local iPf = dSkill.pflist[1]
						if iPf == v then
							bValue = true
							break
						end
					end
				end
			end
		end
		if not bValue then
			dQuick[k] = nil
		end
	end
end

return CSummonCtrl
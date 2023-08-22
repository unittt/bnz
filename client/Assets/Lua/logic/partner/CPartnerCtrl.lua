local CPartnerCtrl = class("CPartnerCtrl", CCtrlBase)

function CPartnerCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_PartnerRecord = {
		View = {
			TabIndex = 1,
		},
		Logic = {
			RedState = false,
		}
	}

	-- 服务器数据
	self.m_SvrPartnerList = {}
	self.m_CurLineup = -1
	self.m_LineupList = {}
	self:GetStaticData()

	--阵容修改的UI数据
	self.m_LocalLineup = 1
	self.m_LocalSelectedPartner = -1

	--战斗中界面关闭比较阵容是否修改所需数据
	self.m_OriginalPos = {}		
	self.m_IsPosChanged = false

	self.m_RedPointStatus = {}
	self.m_EquipRedPoint = {}
	self.m_PartnerNotSelectFirst = nil
end

function CPartnerCtrl.Clear(self)
	self.m_SvrPartnerList = {}
	self.m_CurLineup = -1
	self.m_LineupList = {}
	--阵容修改的UI数据
	self.m_LocalLineup = 1
	self.m_LocalSelectedPartner = -1

	self.m_RedPointStatus = {}
	self.m_PartnerNotSelectFirst = nil
end

function CPartnerCtrl.GetStaticData(self)
	-- 配表数据
	self.m_RolepointConfig = data.rolepointdata.ROLEPOINT
	self.m_RolepointKey = {}
	--TODO:临时手动加上需要显示的属性
	table.insert(self.m_RolepointKey, "cure_power")
	for _,config in pairs(self.m_RolepointConfig) do
		for k,v in pairs(config) do
			table.insert(self.m_RolepointKey, k)
		end
		return
	end
end

function CPartnerCtrl.GetPartnerInfoList(self, tableIndex)
	local typeID = (tableIndex or 1) - 1
	local partnerList = {}
	local partnerLineUp = {}
	--TODO:未完成的伙伴需要屏蔽可以在下面加入
	for _,v in pairs(data.partnerdata.INFO) do
		if typeID <= 0 or typeID == v.type then
			table.insert(partnerList, v)
			local data = self:GetRecruitPartnerDataByID(v.id)
			local lineup = data and self:IsInCurLineup(data.id) or false
			partnerLineUp[v.id] = {data = data, lineup = lineup}
		end
	end

	table.sort(partnerList, function (x, y)
		local xData = partnerLineUp[x.id].data
		local yData = partnerLineUp[y.id].data

		-- 顺序根据状态排列:已上阵->已招募->没招募
		-- 同状态的根据等级\突破\品质由大到小排列
		if xData and yData then
			local xUpline = partnerLineUp[x.id].lineup
			local yUpline = partnerLineUp[y.id].lineup
			if xUpline == yUpline then
				if xData.grade == yData.grade then
					if xData.upper == yData.upper then
						if xData.quality == yData.quality then
							return x.id < y.id
						end
						return xData.quality > yData.quality
					end
					return xData.upper > yData.upper
				end
				return xData.grade > yData.grade
			elseif xUpline then
				return true
			elseif yUpline then
				return false
			end
		elseif xData then
			return true
		elseif yData then
			return false
		else
			local xIsRecuite = self:GetRedPointStatus(x.id) == define.Partner.RedPoint.Recruit
			local yIsRecuite = self:GetRedPointStatus(y.id) == define.Partner.RedPoint.Recruit
			if xIsRecuite and not yIsRecuite then
				return true
			elseif not xIsRecuite and yIsRecuite then
				return false
			end
		end
		return self:GetPartnerInfoConditionLV(x) < self:GetPartnerInfoConditionLV(y)
	end)
	return partnerList
end

function CPartnerCtrl.GetFirstCouldZMPartner(self)
	local oPartnerList = self:GetPartnerInfoList()
	for k,v in ipairs(oPartnerList) do
		if self:GetRedPointStatus(v.id) == define.Partner.RedPoint.Recruit then
			return v
		end
	end
end

function CPartnerCtrl.GetFirstCouldUpgradePartner(self)
	for i,dSPartner in ipairs(g_PartnerCtrl.m_SvrPartnerList) do
        local iStatus = g_PartnerCtrl:GetRedPointStatus(dSPartner.sid)
        if iStatus == define.Partner.RedPoint.Upgrade then
            return dSPartner
        end
    end
end

function CPartnerCtrl.GetPartnerInfoConditionLV(self, partnerInfo)
	local condeitionStrs = string.split(partnerInfo.pre_condition, "%:")
	if #condeitionStrs ~= 2 then
		printerror("错误：招募条件填写错误，伙伴ID", self.m_PartnerInfo.id)
		return
	end
	if condeitionStrs[1] == "LV" then
		return tonumber(condeitionStrs[2])
	end
	return 0
end

function CPartnerCtrl.GetPartnerDataList(self, bIsMainBuddy, bIsGroupBuddy)
	local partnerList = {}
	for _,v in ipairs(self.m_SvrPartnerList) do
		local partnerInfo = DataTools.GetPartnerInfo(v.sid)
		local list = {}
		for g, h in pairs(partnerInfo) do
			list[g] = h
		end
		list.serverid = v.id
		if bIsMainBuddy then
			list.sortindex = g_JjcCtrl:GetIsJjcMainBuddyIsInFight(v.id) and 1 or 0
		end
		if bIsGroupBuddy then
			list.sortindex = g_JjcCtrl:GetIsJjcChallengeBuddyIsInFight(v.id) and 1 or 0
		end
		table.insert(partnerList, list)
	end
	if bIsMainBuddy or bIsGroupBuddy then
		table.sort(partnerList, function (a, b)
			return a.sortindex > b.sortindex
		end)
	end
	return partnerList
end

function CPartnerCtrl.GetPartnerSkillInfoList(self, partnerID, grade)
	grade = grade or 100000
	local partnerSkill = DataTools.GetPartnerSkillUnlock(partnerID)
	local skillInfoList = {}

	for _,v in ipairs(partnerSkill) do
		if v.class > grade then
			break
		end
		for _,skillID in ipairs(v.unlock_skill) do
			local skillInfo = DataTools.GetPartnerSpecialSkill(skillID)
			local dSkill = self:GetPartnerSkillData(partnerID, skillID)
			if not dSkill then
				dSkill = {sk = skillID, level = 1}
			end
			if skillInfo.protect == 1 then
				table.insert(skillInfoList, 1, dSkill)
			else
				table.insert(skillInfoList, dSkill)
			end
		end
	end
	return skillInfoList
end

function CPartnerCtrl.GetPartnerSkillData(self, partnerID, skillID)
	local partnerData = self:GetRecruitPartnerDataByID(partnerID)
	if partnerData then
		local skillList = partnerData.skill
		for _,v in ipairs(skillList) do
			if v.sk == skillID then
				return v
			end
		end
	end
end

function CPartnerCtrl.GetPartnerSkillDesc(self, skillID, skillLevel, unSuilt)
	skillLevel = skillLevel or 1
	local skillInfo = DataTools.GetPartnerSpecialSkill(skillID)
	local findEff = string.find(skillInfo.desc, "#eff")
	local descStr = string.split(skillInfo.desc, "#eff")
	local valueDesc = {}
	for _,effect in ipairs(skillInfo.skill_effect) do
		local strs = string.split(effect, '%=')
		local formula = string.gsub(strs[2], "level", skillLevel)
		local func = loadstring("return " .. formula)
		local v = func()
		if string.find(strs[1], "ratio") then
			v = v*100 .. "%"
		end
		table.insert(valueDesc, v)
	end
	local finalDesc = ""
	if findEff then
		local colorStr = unSuilt and "" or "#G"
		for i,v in ipairs(valueDesc) do
			finalDesc = finalDesc .. descStr[i] .. colorStr .. v .. "[-]"
		end
	else
		finalDesc = skillInfo.desc
	end
	return finalDesc
end

function CPartnerCtrl.GetPartnerType(self, tableIndex)
	local typeID = (tableIndex or 1) - 1
	return data.partnerdata.TYPE[typeID]
end

-- 获取已招募的伙伴(PID)
function CPartnerCtrl.GetRecruitPartnerDataByID(self, partnerID)
	for _,v in ipairs(self.m_SvrPartnerList) do
		if v.sid == partnerID then
			return v
		end
	end
end
-- 获取已招募的伙伴(SID)
function CPartnerCtrl.GetRecruitPartnerDataBySID(self, partnerSid)
	for _,v in ipairs(self.m_SvrPartnerList) do
		if v.id == partnerSid then
			return v
		end
	end
end

function CPartnerCtrl.GetPartnerCurExp(self, partnerID)
	local partnerData = self:GetRecruitPartnerDataByID(partnerID)
	if partnerData then
		local curExp = partnerData.exp
		-- local expInfo = data.upgradedata.DATA
		-- for i=2,partnerData.grade do
		-- 	curExp = curExp - expInfo[i].partner_exp
		-- end
		return curExp > 0 and curExp or 0
	end
end

function CPartnerCtrl.GetPartnerPropScore(self, partnerID)
	-- local propScore = 0
	-- local partnerPoint = DataTools.GetPartnerPoint(partnerID)
	-- local partnerProp = DataTools.GetPartnerProp(partnerID)
	-- local t = {partnerPoint, partnerProp} 

	-- local formula = nil
	-- for _,v in pairs(data.rolepointdata.ROLEBASICSCORE) do
	-- 	for i,p in ipairs(t) do
	-- 		if p[v.macro] then
	-- 			local param = p[v.macro]
	-- 			param = string.gsub(param, "level", 1)
	-- 			param = string.gsub(param, "quality", 1)
	-- 			local funcParam = loadstring("return " .. param)
	-- 			if i == 2 and v.macro == "max_mp" then
	-- 				param = funcParam() + 1 * 20 + 30
	-- 			end
	-- 			formula = string.gsub(v.command, "attr", param)
	-- 			local func = loadstring("return " .. formula)
	-- 			propScore = propScore + func()
	-- 		end
	-- 	end
	-- end
	local dPropData = data.partnerdata.PROP[partnerID]
	local formula = dPropData.score
	formula = string.gsub(formula, "quality", 1)
	local func = loadstring("return "..formula)
	return func()
end

function CPartnerCtrl.GetPartSkillScore(self, partnerID)
	local skillScore = 0
	local skills = DataTools.GetPartnerSkillUnlock(partnerID)
	if skills and skills[1] and skills[1].unlock_skill then
		for _,v in ipairs(skills[1].unlock_skill) do
			local skillInfo = DataTools.GetPartnerSpecialSkill(v)
			local formula = string.gsub(skillInfo.score, "lv", 1)
			local func = loadstring("return " .. formula)
			skillScore = skillScore + func()
		end
	end
	return skillScore
end

function CPartnerCtrl.GetPartnerScore(self, partnerID)
	local partnerData = self:GetRecruitPartnerDataByID(partnerID)
	if partnerData then
		-- 服务器伙伴数据直接读取数据，不再由前端计算
		return partnerData.score
	end

	local propScore = self:GetPartnerPropScore(partnerID)
	local skillScore = self:GetPartSkillScore(partnerID)
	return Mathf.Floor(propScore + skillScore)
end

-- 计算指定伙伴默认品质（白即1阶）
-- 注意：这里copy一份属性，不是表格的数据，需要表格数据从这里取：DataTools.GetPartnerProp(partnerID)
function CPartnerCtrl.GetCalculusPartnerProp(self, partnerID)
	local level = 1
	local partnerPoint = DataTools.GetPartnerPoint(partnerID, level)
	local partnerProp = DataTools.GetPartnerProp(partnerID)
	local partnerPropCopy = table.copy(partnerProp)
	for _,key in ipairs(self.m_RolepointKey) do
		-- 这里是单独加点的计算
		-- local value = 0
		-- if key == "max_mp" then
		-- 	value = level * 20 + 30
		-- else
		-- 	for k,v in pairs(self.m_RolepointConfig) do
		-- 		value = value + v[key]*partnerPoint[k]
		-- 	end
		-- end
		-- partnerPropCopy[key] = Mathf.Floor(partnerPropCopy[key] + value)

		-- 2017.09.08 修改为 这样的计算（喜樑需求）
		local formula = string.gsub(partnerPropCopy[key], "level", 1)
		formula = string.gsub(formula, "quality", 1)
		local func = loadstring("return " .. formula)
		partnerPropCopy[key] = Mathf.Floor(func())
	end
	return partnerPropCopy
end

-- 获取指定类型伙伴道具（1、升级 2、突破 3、进阶）
function CPartnerCtrl.GetPartnerCultureItemInfo(self, partnerID, type)
	local partnerData = self:GetRecruitPartnerDataByID(partnerID)
	local cultureType = 1
	local param = 1
	if type then
		cultureType = type
	elseif partnerData then
		local upperInfo = DataTools.GetPartnerUpperInfo(partnerData.upper)
		if partnerData.grade >= upperInfo.level then
			cultureType = 2
		end
	end
	if cultureType == 2 then
		param = partnerData and partnerData.upper or 1
	elseif cultureType == 3 then
		param = partnerData and partnerData.quality or 1
	end
	local funName = {"GetPartnerExpItem", "GetPartnerUpperItem", "GetPartnerQualityItem"}
	local f = self[funName[cultureType]]
	local itemList = f(self, partnerID, param)
	return {cultureType = cultureType, itemList = itemList}
end

function CPartnerCtrl.GetPartnerExpItem(self)
	local itemSidList = {30661, 30662, 30663}
	local itemList = {}
	for _,v in ipairs(itemSidList) do
		local item = {}
		item.info = DataTools.GetPartnerItem(v)
		item.amount = g_ItemCtrl:GetBagItemAmountBySid(v)
		item.cost = 1
		table.insert(itemList, item)
	end
	return itemList
end

function CPartnerCtrl.GetPartnerUpperItem(self, partnerid, upper)
	local upperInfo = DataTools.GetPartnerUpperLimit(partnerid, upper)
	local itemList = {}
	for _,v in ipairs(upperInfo.cost) do
		local item = {}
		item.info = DataTools.GetPartnerItem(v.itemid)
		item.amount = g_ItemCtrl:GetBagItemAmountBySid(v.itemid)
		item.cost = v.amount
		table.insert(itemList, item)
	end
	return itemList
end

function CPartnerCtrl.GetPartnerQualityItem(self, partnerID, quality)
	local qulityInfo = DataTools.GetPartnerQualitycost(partnerID, quality)
	local itemList = {}
	if qulityInfo then
		for _,v in ipairs(qulityInfo.upgrade_cost) do
			local item = {}
			item.info = DataTools.GetPartnerItem(v.itemid)
			item.amount = g_ItemCtrl:GetPartnerItemAmountBySid(v.itemid)
			item.cost = v.amount
			table.insert(itemList, item)
		end
	end
	return itemList
end

-- 服务器数据下发
function CPartnerCtrl.GS2CLoginPartner(self, partners)
	-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "GS2CLoginPartner", "登录获取伙伴信息"))
	self.m_SvrPartnerList = {}
	for i,v in ipairs(partners) do
		table.insert(self.m_SvrPartnerList, v)
	end
	table.sort(self.m_SvrPartnerList, function (x, y)
		return x.sid < y.sid
	end)
	self:ResetRedPointStatus()
	self:ResetAllEquipRedPoint(true, true)
end

function CPartnerCtrl.GS2CPartnerPropChange(self, partnerid, partnerProp)
	-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "GS2CPartnerPropChange", "伙伴属性变更"))
	local partnerData = self:GetRecruitPartnerDataBySID(partnerid)
	if not partnerData then
		printerror("当前不存在的伙伴服务器ID：", partnerid)
		return
	end
	local offsetData = {}
	local cultureType = 0
	local refListBox = false
	local refEquip = false
	local bRefreshRedPoint = false
	for k,v in pairs(partnerProp) do
		--TODO:突破取消
		-- if k == "upper" and v > partnerData[k] then
		-- 	cultureType = 1
		-- 	refListBox = true
		-- else
		if k == "quality" and v > partnerData[k] then
			cultureType = 2
			refListBox = true
			bRefreshRedPoint = true
		elseif k == "grade" and v ~= partnerData[k] then
			refListBox = true
			bRefreshRedPoint = true
		elseif (k == "equipsid") then
			refEquip = true
		end
		if type(v) ~= "table" then
			offsetData[k] = v - partnerData[k]
		end
		partnerData[k] = v
	end

	if refListBox then
		-- 升级、进阶、招募、突破，伙伴音效
		g_AudioCtrl:PlaySound(define.Audio.SoundPath.Partner)
	end

	if bRefreshRedPoint then
		self:ResetRedPointStatus()
		g_PromoteCtrl:UpdatePromoteData(8)
		g_PromoteCtrl:UpdatePromoteData(9)
	end

	if refEquip then
		self:ResetAllEquipRedPoint(true, true)
	end

	local cultureInfo = {partnerData = partnerData, offsetData = offsetData, cultureType = cultureType, refListBox = refListBox, refEquip = refEquip, partnerid = partnerData.sid}
	self:OnEvent(define.Partner.Event.PropChange, cultureInfo)
end

function CPartnerCtrl.GS2CAddPartner(self, partner)
	-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "GS2CAddPartner", "增加伙伴"))
	if self:GetRecruitPartnerDataBySID(partner.id) then
		printerror("已存在伙伴:" .. DataTools.GetPartnerInfo(partner.sid).name .. "，请检查代码错误")
		return
	end

	--伙伴招募引导相关
	if partner.sid == g_GuideHelpCtrl:GetPartner1() then
		g_GuideHelpCtrl.m_IsClickGetPartnerGuide = true
	end

	table.insert(self.m_SvrPartnerList, partner)
	table.sort(self.m_SvrPartnerList, function (x, y)
		return x.sid < y.sid
	end)
	self:OnEvent(define.Partner.Event.AddPartner, partner.sid)

	-- 伙伴音效
	g_AudioCtrl:PlaySound(define.Audio.SoundPath.Partner)

	g_GuideCtrl:OnTriggerAll()
	g_GuideHelpCtrl:CheckAllNotifyGuide()
	self:ResetRedPointStatus()
	g_PromoteCtrl:UpdatePromoteData(8)
	g_PromoteCtrl:UpdatePromoteData(9)
	self:ResetAllEquipRedPoint(true ,true)
end

function CPartnerCtrl.GS2CUpgradeSkill(self, partnerid, skiinfo)
	-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "GS2CUpgradeSkill", "伙伴技能变更"))
	local partnerData = self:GetRecruitPartnerDataBySID(partnerid)
	if not partnerData then
		printerror("当前不存在的伙伴服务器ID：", partnerid)
		return
	end
	local skillList = partnerData.skill
	local skillInfo = nil
	for _,nv in ipairs(skiinfo) do
		for _,ov in ipairs(skillList) do
			if ov.sk == nv.sk then
				ov.level = nv.level

				skill = DataTools.GetPartnerSpecialSkill(ov.sk)
				skillInfo = {
					partnerid = partnerid,
					info = skill,
					data = ov,
				}
				break
			end
		end
		if skillInfo then
			break
		end
	end
	self:OnEvent(define.Partner.Event.UpgradeSkill, skillInfo)
end

function CPartnerCtrl.OpenPartnerMainView(self, itemid)
	local partnerInfo = DataTools.GetpartnerInfoByItemID(itemid)
	CPartnerMainView:ShowView(function (oView)
		oView:ResetCloseBtn()
		if itemid >= 30600 and itemid < 30630 then
			-- printc("============ 招募界面，指定伙伴ID")
			oView:SetSpecificPartnerIDNode(partnerInfo.id)
		elseif itemid == 30660 then
			-- printc("============ 进阶界面")
			if next(self.m_SvrPartnerList) then
				oView:ShowSpecificPart(1)
			end
		elseif itemid >= 30661 and itemid <= 30665 then
			-- printc("============ 伙伴升级、突破界面")
		end
	end)
end

function CPartnerCtrl.GS2CAllLineupInfo(self, iCurLineup, dInfo)
	self.m_CurLineup = iCurLineup
	for _,v in pairs(dInfo) do
		self:SetLineupInfo(v)
	end
	self.m_OriginalPos = {}
	if self.m_LineupList[self.m_CurLineup] then
		self.m_OriginalPos = table.copy(self.m_LineupList[self.m_CurLineup].pos_list)
	end
	self.m_IsPosChanged = false
	self:OnEvent(define.Partner.Event.UpdateAllLineup)
end

function CPartnerCtrl.GS2CSingleLineupInfo(self, dInfo)
	self:SetLineupInfo(dInfo)
	--阵法同步伙伴设置
	if dInfo.lineup == self.m_CurLineup then
		if g_FormationCtrl:GetCurrentFmt() ~= 0 then
			g_FormationCtrl:SetCurrentFmt(dInfo.fmt_id)
		end
		g_FormationCtrl:SetCurrentPartnerList(dInfo.pos_list)
	end
	self:OnEvent(define.Partner.Event.UpdateLineup, dInfo.lineup)
end

function CPartnerCtrl.SetLineupInfo(self, dInfo)
	-- TODO:不能直接对pbdata直接操作，只作读取
	-- local bHasPos = false
	-- for k,v in pairs(dInfo) do
	-- 	if k == "pos_list" then
	-- 		bHasPos = true
	-- 		break
	-- 	end
	-- end
	-- if not bHasPos then
	-- 	dInfo.pos_list = {}
	-- end
	local dLineup = {pos_list = {}}
	table.copy(dInfo, dLineup)
	self.m_LineupList[dInfo.lineup] = dLineup
end

function CPartnerCtrl.SetCurLineup(self, iLineup)
	self.m_CurLineup = iLineup
	--阵法同步伙伴设置
	local dInfo = self.m_LineupList[iLineup]
	if dInfo then
		if g_FormationCtrl:GetCurrentFmt() ~= 0 then
			g_FormationCtrl:SetCurrentFmt(dInfo.fmt_id)
		end
		g_FormationCtrl:SetCurrentPartnerList(dInfo.pos_list)
	else
		if g_FormationCtrl:GetCurrentFmt() ~= 0 then
			g_FormationCtrl:SetCurrentFmt(1)
		end
		g_FormationCtrl:SetCurrentPartnerList({})
	end
	self:OnEvent(define.Partner.Event.UpdateAllLineup)
end

function CPartnerCtrl.GetCurLineup(self)
	return self.m_CurLineup
end

function CPartnerCtrl.GetLocalLineup(self)
	return self.m_LocalLineup
end

function CPartnerCtrl.SetLocalLineup(self, iLineup)
	self.m_LocalLineup = iLineup
end

function CPartnerCtrl.SetLocalSelectedPartner(self, iPid)
	self.m_LocalSelectedPartner = iPid
end

function CPartnerCtrl.GetLocalSelectedPartner(self)
	return self.m_LocalSelectedPartner
end

function CPartnerCtrl.GetLineupInfoByIndex(self, iIndex)
	return self.m_LineupList[iIndex]
end

function CPartnerCtrl.GetPosListByFmtId(self, iFmtId)
	local result = {}
	for k,dInfo in pairs(self.m_LineupList) do
		if dInfo.fmt_id == iFmtId then
			table.copy(dInfo.pos_list, result)
		end
	end
	return result
end

function CPartnerCtrl.GetPosListByLineupId(self, iLineup)
	local result = {}
	for k,dInfo in pairs(self.m_LineupList) do
		if dInfo.lineup == iLineup then
			table.copy(dInfo.pos_list, result)
		end
	end
	return result
end

function CPartnerCtrl.ChangetLineupPos(self, iLineup, iOldId, iNewId)
	local dInfo = self.m_LineupList[iLineup]
	if not dInfo then
		dInfo = {
			lineup = iLineup,
  			fmt_id = 1,        
    		pos_list = {}
    	}
    	self.m_LineupList[iLineup] = dInfo
	end
	if iOldId and iNewId then
		self:SwapLineupPos(iLineup, iOldId, iNewId)
	elseif iOldId then
		self:RemoveLineupPosByPid(iLineup, iOldId)
	elseif iNewId then
		table.insert(dInfo.pos_list, iNewId)
	end
	--TODO:TEST
	-- self:GS2CSingleLineupInfo(dInfo)
	netpartner.C2GSSetPartnerPosInfo(iLineup, dInfo.fmt_id, dInfo.pos_list)
	if g_WarCtrl:IsWar() then
		self.m_IsPosChanged = false
		for i,pid in ipairs(self.m_OriginalPos) do
			if pid ~= dInfo.pos_list[i] then
				self.m_IsPosChanged = true
				break
			end
		end
	end
end

function CPartnerCtrl.RemoveLineupPosByPid(self, iLineup, iPid)
	local dInfo = self.m_LineupList[iLineup]
	local iIndex = table.index(dInfo.pos_list, iPid)
	table.remove(dInfo.pos_list, iIndex)
	table.print(dInfo)
end

function CPartnerCtrl.SwapLineupPos(self, iLineup, iId1, iId2)
	local dInfo = self.m_LineupList[iLineup]
	local iIndex1 = table.index(dInfo.pos_list, iId1)
	local iIndex2 = table.index(dInfo.pos_list, iId2)
	if iIndex1 then
		dInfo.pos_list[iIndex1] = iId2
	end
	if iIndex2 then
		dInfo.pos_list[iIndex2] = iId1
	end
end

function CPartnerCtrl.IsInLineup(self, sid, iLineup)
	local dInfo = self.m_LineupList[iLineup]
	if not dInfo then
		return false
	end
	for _,pid in ipairs(dInfo.pos_list) do
		if pid == sid then
			return true
		end
	end
	return false
end

function CPartnerCtrl.IsInCurLineup(self, sid)
	return self:IsInLineup(sid, self.m_CurLineup)
end

function CPartnerCtrl.GetPartnerProtectSkill(self, partnerID)
	local partnerData = self:GetRecruitPartnerDataByID(partnerID)
	if partnerData then
		local skillList = partnerData.skill
		for _,v in ipairs(skillList) do
			local skillInfo = DataTools.GetPartnerSpecialSkill(v.sk)
			if skillInfo.protect == 1 then
				return v
			end
		end
	end
end

------------------麻烦的红点-----------------------
function CPartnerCtrl.ResetRedPointStatus(self)
	local dPreRedStatus = table.copy(self.m_RedPointStatus)
	self.m_RedPointStatus = {}
	for i,dPartner in pairs(data.partnerdata.INFO) do
        local dSPartner = self:GetRecruitPartnerDataByID(dPartner.id)
        local iCostItem = dPartner.cost.id
        local iItemAmount = g_ItemCtrl:GetPartnerItemAmountBySid(iCostItem)
        local iUnlockLv = self:GetPartnerInfoConditionLV(dPartner)
        if not dSPartner and iItemAmount > 0 and iUnlockLv <= g_AttrCtrl.grade then
			self.m_RedPointStatus[dPartner.id] = define.Partner.RedPoint.Recruit            
        end
    end

	local dUpgradeInfo = data.partnerdata.QUALITYCOST[10001]
	if dUpgradeInfo then
		local dCost = dUpgradeInfo[1].upgrade_cost[2]
		local iMaterial = dCost.itemid --进阶通用材料
    	if g_ItemCtrl:GetPartnerItemAmountBySid(iMaterial) < dCost.amount then
    		if not table.equal(self.m_RedPointStatus, dPreRedStatus) then
    			self:OnEvent(define.Partner.Event.RefreshRedPoint)
    		end
    		return
    	end
	end
    
    for i,dSPartner in ipairs(self.m_SvrPartnerList) do
        local dInfo = DataTools.GetPartnerQualityInfo(dSPartner.quality + 1)  
        local dQualityInfo = DataTools.GetPartnerQualityInfo(dSPartner.quality)	
        if dInfo and (dSPartner.grade >= dQualityInfo.level) then
            local cultureItemInfo = self:GetPartnerCultureItemInfo(dSPartner.sid, 3)
            local bIsUpgrade = true
            for i,dItem in ipairs(cultureItemInfo.itemList) do
                if dItem.amount < dItem.cost then
                    bIsUpgrade = false
                end
            end
            if bIsUpgrade then
                self.m_RedPointStatus[dSPartner.sid] = define.Partner.RedPoint.Upgrade 
            end
        end 
    end

    if not table.equal(self.m_RedPointStatus, dPreRedStatus) then
    	self:OnEvent(define.Partner.Event.RefreshRedPoint)
    end
end

function CPartnerCtrl.GetRedPointStatus(self, sid)
	return self.m_RedPointStatus[sid]
end

----------------------伙伴装备红点---------------------------
function CPartnerCtrl.ResetAllEquipRedPointByItem(self, iTargetItem)
	for iItemId,v in pairs(data.partnerdata.EQUIPCOSTITEM) do
		if iTargetItem == iItemId then
			self:ResetAllEquipRedPoint(true, false)
			break
		end
	end	
end

function CPartnerCtrl.ResetAllEquipRedPointBySilver(self)
	self:ResetAllEquipRedPoint(false, true)
end

function CPartnerCtrl.ResetAllEquipRedPoint(self, bUpgrade, bStrength)
	if bUpgrade and bStrength then
		self.m_EquipRedPoint = {}
	end
	self.m_EquipCostItems = {}
	for iItemId,v in pairs(data.partnerdata.EQUIPCOSTITEM) do
		local iSum = g_ItemCtrl:GetBagItemAmountBySid(iItemId)
		self.m_EquipCostItems[iItemId] = iSum
	end	
	for i,dSPartner in ipairs(self.m_SvrPartnerList) do
		self:ResetEquipRedPoint(dSPartner, bUpgrade, bStrength)
	end
	self:OnEvent(define.Partner.Event.RefreshEquipRedPoint)
end

function CPartnerCtrl.ResetEquipRedPoint(self, dPartner, bUpgrade, bStrength)
	for i, dEquipInfo in ipairs(dPartner.equipsid) do
		local dEquipData = DataTools.GetPartnerEquipData(dEquipInfo.equip_sid)
		if not self.m_EquipRedPoint[dEquipInfo.equip_sid] then
			self.m_EquipRedPoint[dEquipInfo.equip_sid] = {}
		end
		if bUpgrade then
			local bEnableUpgrade = self:IsUpgradeEnabled(dPartner, dEquipInfo, dEquipData)
			self.m_EquipRedPoint[dEquipInfo.equip_sid].upgrade = bEnableUpgrade
		end
		if bStrength then
			local bEnableStrength = self:IsStrengthEnabled(dPartner, dEquipInfo, dEquipData)
			self.m_EquipRedPoint[dEquipInfo.equip_sid].strength = bEnableStrength
		end
	end
end

function CPartnerCtrl.IsStrengthEnabled(self, dPartner, dEquipInfo, dEquipData)
	--TODO:策划要求去掉
	return false
	-- if dPartner.grade <= dEquipInfo.strength then
	-- 	return
	-- end
	-- local dStrengthCost = data.partnerdata.STRENGTH_COST[dEquipInfo.strength + 1]
	-- if not dStrengthCost then
	-- 	return
	-- end
	-- local iCostAmount = dStrengthCost and dStrengthCost.strength_silver or 0
	-- return iCostAmount <= g_AttrCtrl.silver 
end

function CPartnerCtrl.IsUpgradeEnabled(self, dPartner, dEquipInfo, dEquipData)
	if dPartner.grade < dEquipInfo.level + 10 then
		return
	end

	local dUpgradeCost = data.partnerdata.UPGRADE_COST[dEquipInfo.level + 10]
	if not dUpgradeCost then
		return
	end
	local iAmount = dUpgradeCost.upgrade_cost_amount
	return self.m_EquipCostItems[dEquipData.upgrade_cost_sid] >= iAmount
end

function CPartnerCtrl.GetEquipRedPoint(self, iEquipId)
	return self.m_EquipRedPoint[iEquipId]
end

-- 伙伴链接技能相关
function CPartnerCtrl.GetLinkPartnerProtoctSkill(self, skillList)
	for _,v in ipairs(skillList) do
		local skillInfo = DataTools.GetPartnerSpecialSkill(v.sk)
		if skillInfo.protect == 1 then
			return v
		end
	end
end

function CPartnerCtrl.GetLinkPartnerSkillList(self, skillList)
	local list = {}
	local pSkill = nil
	for _,v in ipairs(skillList) do
		local skillInfo = DataTools.GetPartnerSpecialSkill(v.sk)
		if skillInfo.protect == 1 then
			pSkill = v
		else
			table.insert(list, v)
		end
	end
	table.sort(list, function (a, b)
		if a.level == b.level then
			return a.sk < b.sk
		end
		return a.level > b.level
	end)
	if pSkill then
		table.insert(list, 1, pSkill)
	end
	return list
end

return CPartnerCtrl
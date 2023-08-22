local CSkillCultivatePart = class("CSkillCultivatePart", CPageBase)

function CSkillCultivatePart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_SkillGrid = self:NewUI(1, CGrid)
	self.m_DescGrid = self:NewUI(2,CGrid)
	self.m_LearnBtn = self:NewUI(3, CButton)
	self.m_ItemLearnBtn = self:NewUI(4, CButton)
	self.m_SkillBoxClone = self:NewUI(5, CBox)
	self.m_TipBtn = self:NewUI(6, CButton)
	self.m_TypeSelectSpr = self:NewUI(7, CSprite)
	self.m_ItemBox = self:NewUI(8, CItemBaseBox)
	self.m_SilverBox = self:NewUI(9, CCurrencyBox)
	self.m_CostBox = self:NewUI(10, CCurrencyBox)
	self.m_SkillNameL = self:NewUI(11, CLabel)
	self.m_ExpBox = self:NewUI(12, CBox)
	self.m_ContentObj = self:NewUI(13, CObject)
	self.m_TipsLabel = self:NewUI(14, CLabel)
	self.m_LvLabel = self:NewUI(15, CLabel)
	self.m_ItemNameLabel = self:NewUI(16, CLabel)
	self.m_TypeChangeSpr = self:NewUI(17, CSprite)
	self.m_SkillLevelLbl = self:NewUI(18, CLabel)
	self.m_SkillIconSp = self:NewUI(19, CSprite)
	self.m_SkillDescGrid1 = self:NewUI(20, CBox)
	self.m_SkillDescGrid2 = self:NewUI(21, CBox)
	self.m_SkillDescGrid3 = self:NewUI(22, CBox)
	self.m_ItemCountLabel = self:NewUI(23, CLabel)
	
	self.m_SkillDecsGrid = {self.m_SkillDescGrid1, self.m_SkillDescGrid2, self.m_SkillDescGrid3}

	self.m_SkillGrid2 = self:NewUI(24, CGrid)
	self.m_SkillBoxClone2 = self:NewUI(25, CBox)
	self.m_FuncLbl = self:NewUI(26, CLabel)
	self.m_LearnTenBtn  = self:NewUI(27, CButton) -- 多次学习按钮
	self.m_LearnTenLab = self:NewUI(28, CLabel)
	self.m_UseTimeL = self:NewUI(29, CLabel)

	g_GuideCtrl:AddGuideUI("skill_cultivate_learn_btn", self.m_LearnBtn)

	self.m_SelectLearnBox = nil
	self.m_Timer = nil
	self.m_IsRequest = false
	self.m_RquestType = {
		item = 1,
		silver = 2,
		tentime = 3, --十次修炼
	}
	self.m_SkillBoxList = {}
	self.m_UpperLv = -1
	self.m_Cost = 0
	self.m_LongPressTime = {{1,3},{0.5,3},{0.2,3}} --{间隔时间，持续时间}
	self.m_LongPressIndex = 1
	self.m_TimeCount = 0

	-- TODO:修炼技能描述是写死的
	self.m_UpgradeRate = 2
	self.m_UpgradePoint = 5
	self:InitContent()
end

function CSkillCultivatePart.OnInitPage(self)
	
end

function CSkillCultivatePart.InitContent(self)
	self.m_SkillBoxClone:SetActive(false)
	self.m_SkillBoxClone2:SetActive(false)
	self.m_SilverBox:SetCurrencyType(define.Currency.Type.Silver)
	self.m_CostBox:SetCurrencyType(define.Currency.Type.Silver, true)

	self.m_LearnBtn:AddUIEvent("press", callback(self, "OnLongClickLearnSkill", 1))
	self.m_LearnBtn:AddUIEvent("click", callback(self, "OnClickLearnSkill", 1))

	self.m_LearnTenBtn:AddUIEvent("press", callback(self, "OnLongClickLearnSkill", 10))
	self.m_LearnTenBtn:AddUIEvent("click", callback(self, "OnClickLearnSkill", 10))

	self.m_ItemLearnBtn:AddUIEvent("click", callback(self, "OnItemLearnSKill"))
	self.m_TypeChangeSpr:AddUIEvent("click", callback(self, "OnChangeType"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTips"))

	g_SkillCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlSkillEvent"))
	
	self:RefreshAll()
	self:ShowSelectSkillSelect()
end

function CSkillCultivatePart.SetSelectedSkill(self, tSkill)
	self.m_CurSkill = tSkill
	self.m_CSkillData =  data.skilldata.CULTIVATION[tSkill.sk]
end

function CSkillCultivatePart.OnCtrlSkillEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Skill.Event.RefreshAllCultivate then
		self:RefreshSkillGrid()
		self:RefreshSkillGrid2()
	elseif oCtrl.m_EventID == define.Skill.Event.RefreshCultivate then
		local data = oCtrl.m_EventData
		if data.Skill and next(data.Skill) then
			self:RefreshSKillBox(data.Skill)
		end
		self.m_UpperLv = g_SkillCtrl:GetCultivateUpperLevel()
		self:RefreshLvLimit()
	elseif oCtrl.m_EventID == define.Skill.Event.SetCultivate then
		self:RefreshSeletStatus(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.Skill.Event.RefreshSkillMaxLevel then
		self.m_UpperLv = g_SkillCtrl:GetCultivateUpperLevel()
		self:RefreshLvLimit()
	end
end

function CSkillCultivatePart.OnClickTips(self)
	local zId = define.Instruction.Config.Cultivation
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CSkillCultivatePart.RefreshAll(self)
	self:RefreshSkillGrid()
	self:RefreshSkillGrid2()
	self:RefreshCost()
end

function CSkillCultivatePart.RefreshExp(self)
	local curExp = self.m_CurSkill.exp
	local maxExp = g_SkillCtrl:GetCultivateExp(self.m_CurSkill.level + 1, self.m_CurSkill.sk)

	if not self.m_ExpBox.m_Slider then
		self.m_ExpBox.m_Slider = self.m_ExpBox:NewUI(1, CSlider)
		self.m_ExpBox.m_ExpLabel = self.m_ExpBox:NewUI(2, CLabel)
	end
	self.m_ExpBox.m_Slider:SetValue(curExp/maxExp)
	self.m_ExpBox.m_ExpLabel:SetText(string.format("%d/%d", curExp, maxExp))
end

function CSkillCultivatePart.RefreshCost(self)
	local info = data.skilldata.CultivationLimitTime
	local dData = nil 
	for _,v in ipairs(info) do
		if g_AttrCtrl.grade < v.playerlevel then
			dData = v
			break
		end
	end
	if not dData then
		dData = info[#info]
	end
	self.m_CostBox:SetCurrencyCount(info[1].silvercost)
	self.m_SilverBox:SetWarningValue(dData.silvercost)
	self.m_LearnTenLab:SetText("学"..dData.time.."次")
end

function CSkillCultivatePart.RefreshDesc(self,dSkill)
	local sDesc = self.m_CSkillData.desc
	local sShortDesc = self.m_CSkillData.shortdesc
	local sName = self.m_CSkillData.name
	local sNextDesc = self.m_CSkillData.desc
	local iId = self.m_CurSkill.sk

	local iCurLevel = g_AttrCtrl.m_BadgeInfo and g_AttrCtrl.m_BadgeInfo.tid or 1001
  	local tTxData = data.touxiandata.DATA[iCurLevel]
  	local txConfig = g_SkillCtrl:SplitAtt(tTxData ,dSkill)
  	--local sTouxianStr = (tTxData and tonumber(txConfig[iId] or 0) > 0) and "+"..tonumber(txConfig[iId]) or ""
  	local sLevel = nil
  	if txConfig == 0 then
		sLevel= "[63432CFF]"..self.m_CurSkill.level.."级[-]"
	else
		sLevel= "[63432CFF]"..self.m_CurSkill.level.."[-][1D8E00FF]+"..txConfig.."级[-]"
	end

	local iUpgradeRate = (self.m_CurSkill.level+tonumber(txConfig or 0))*self.m_UpgradeRate
	local iUpgradePoint = (self.m_CurSkill.level+tonumber(txConfig or 0))*self.m_UpgradePoint
	local iNextUpgradeRate = iUpgradeRate + self.m_UpgradeRate
	local iNextUpgradePoint = iUpgradePoint + self.m_UpgradePoint
	-- 描述客户端自行拼接，差评! --我举双手碰瓷策划
	for i = 0, 3 do
		sDesc = string.gsub(sDesc, "{"..(i*2).."}", iUpgradeRate)
		sDesc = string.gsub(sDesc, "{"..(i*2 + 1).."}", iUpgradePoint)
		sNextDesc = string.gsub(sNextDesc, "{"..(i*2).."}", iNextUpgradeRate)
		sNextDesc = string.gsub(sNextDesc, "{"..(i*2 + 1).."}", iNextUpgradePoint)
	end

	local _, DescCount = string.gsub(sDesc, "|", "")
	DescCount = DescCount + 1
	local DescList = self:GetDescList(sDesc)
	local NextDescList = self:GetDescList(sNextDesc)
	local ShortDescList = self:GetDescList(self.m_CSkillData.shortdesc)
	
	for i=1, 3 do
		self.m_SkillDecsGrid[i]:SetActive(false)
	end
	for i=1, DescCount do
		self.m_SkillDecsGrid[i]:SetActive(true)
		local titleLbl = self.m_SkillDecsGrid[i]:NewUI(1, CLabel)
		local descLbl = self.m_SkillDecsGrid[i]:NewUI(2, CLabel)
		local nextdescLbl = self.m_SkillDecsGrid[i]:NewUI(3, CLabel)
		titleLbl:SetText(ShortDescList[i])
		descLbl:SetText(DescList[i])
		nextdescLbl:SetText(NextDescList[i])
	end
	
	self.m_SkillNameL:SetText(sName)
	self.m_SkillLevelLbl:SetText(sLevel)
	self.m_SkillIconSp:SpriteSkill(self.m_CSkillData.icon)
	self.m_FuncLbl:SetText(self.m_CSkillData.funcdesc)
	self:RefreshLvLimit()
end

function CSkillCultivatePart.GetDescList(self, skilldata)
	local index = 1
	local preindex = index
	local DescList = {}
	while true do
		index = string.find(skilldata, "|", index + 1)
		if not index then
			table.insert(DescList, string.sub(skilldata, preindex,string.len(skilldata)))
			break 
		end
		table.insert(DescList, string.sub(skilldata, preindex,index-1))
		preindex = index + 1
	end
	return DescList
end

--刷新修炼技能上限
function CSkillCultivatePart.RefreshLvLimit(self)
	self.m_LvLabel:SetText("[244B4EFF]"..self.m_UpperLv.."级[-]")
end

function CSkillCultivatePart.RefreshItem(self, itemId)
	local cItem = CItem.CreateDefault(itemId)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(itemId)
	cItem.m_SData.amount = iAmount

	local sName = DataTools.GetItemData(itemId,"OTHER").name
	self.m_ItemNameLabel:SetText(sName)
	if iAmount <= 0 then
		self.m_ItemCountLabel:SetActive(true)
		self.m_ItemCountLabel:SetDepth(51)
		self.m_ItemCountLabel:SetText(iAmount)
	else
		self.m_ItemCountLabel:SetActive(false)
		self.m_ItemCountLabel:SetDepth(2)
	end
	self.m_ItemBox:SetBagItem(cItem)
	self:RefreshItemUseTime(itemId)
end

function CSkillCultivatePart.RefreshItemUseTime(self, itemId)
	local iInfo = g_SkillCtrl:GetItemUseInfo(itemId)

	if not iInfo then
		return
	end

	if iInfo.flag_limit ~= 1 then
		self.m_UseTimeL:SetText("")
		return
	end
	local count = iInfo.count_limit or 0
	local text = string.format("[244B4E]今日还可使用:[-] #G%d#n", count)
	self.m_UseTimeL:SetText(text)
end

function CSkillCultivatePart.SetDefaultIndex(self,index)
	self.m_defaultIndex = index
	self:RefreshAll()
end

function CSkillCultivatePart.RefreshSkillGrid(self)
	self.m_SkillGrid:Clear()
	local selectedSkill = g_SkillCtrl:GetSelectedCultivateSkill()
	local skills = g_SkillCtrl:GetCultivateSkillList()
	self.m_UpperLv = g_SkillCtrl:GetCultivateUpperLevel()

	-- table.print(skills)
	for i, dSkill in ipairs(skills) do
		--只显示人物修炼技能
		if i <= 4 then
			local oBox = self:CreateSkillBox(dSkill)
			if i == (self.m_defaultIndex or 1) then
				self:OnSkillSelect(oBox)
			else
				oBox:SetSelected(false)
			end

			if g_SkillCtrl:IsSelectedCultivateSkill(dSkill.sk) then
				oBox.m_CultivateSpr:SetActive(true)
			end
			self.m_SkillBoxList[dSkill.sk] = oBox
			self.m_SkillGrid:AddChild(oBox)
		end
	end
end

function CSkillCultivatePart.CreateSkillBox(self, dSkill, bIsSum)
	local tData = data.skilldata.CULTIVATION[dSkill.sk]
	local oBox
	if bIsSum then
		oBox = self.m_SkillBoxClone2:Clone()
	else
		oBox = self.m_SkillBoxClone:Clone()
	end
	oBox:SetActive(true)
	oBox.m_SkillSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_LevelLabel = oBox:NewUI(3, CLabel)
	oBox.m_DescLabel =oBox:NewUI(4, CLabel)
	oBox.m_CultivateSpr =oBox:NewUI(5, CSprite)
	oBox.m_BGSpr =oBox:NewUI(6, CSprite)
	oBox.m_SelectLearnSpr =  oBox:NewUI(7, CSprite)
	oBox:AddUIEvent("click", callback(self, "OnSkillSelect"))
	oBox.m_Skill = dSkill
	table.print(oBox.m_Skill)
	oBox.m_SkillSpr:SpriteSkill(tData.icon)
	oBox.m_NameLabel:SetText(tData.name)
	local iCurLevel = g_AttrCtrl.m_BadgeInfo and g_AttrCtrl.m_BadgeInfo.tid or 1001
  	local tTxData = data.touxiandata.DATA[iCurLevel]
  	local txConfig = g_SkillCtrl:SplitAtt(tTxData ,dSkill)
  	--local sTouxianStr = (tTxData and tonumber(txConfig[dSkill.sk] or 0) > 0) and tonumber(txConfig[dSkill.sk]) or 0
  	if txConfig> 0 then						--[1D8E00FF]+"..txConfig.."级[-]"
		oBox.m_LevelLabel:SetText("[244B4EFF]等级:"..g_SkillCtrl.m_CultivateSkills[oBox.m_Skill.sk].level.."[-][1D8E00FF]+"..txConfig.."[-]")
	else
		oBox.m_LevelLabel:SetText("[244B4EFF]等级:"..g_SkillCtrl.m_CultivateSkills[oBox.m_Skill.sk].level.."[-]")
	end
	oBox.m_DescLabel:SetText(tData.shortdesc)
	if tData.type == 2 then
		oBox.m_BGSpr:SetActive(true)
	else
		oBox.m_BGSpr:SetActive(false)
	end
	return oBox
end

--宠物和伙伴修炼技能
function CSkillCultivatePart.RefreshSkillGrid2(self)
	self.m_SkillGrid2:Clear()
	local selectedSkill = g_SkillCtrl:GetSelectedCultivateSkill()
	local skills = g_SkillCtrl:GetCultivateSkillList()
	self.m_UpperLv = g_SkillCtrl:GetCultivateUpperLevel()

	-- table.print(skills)
	for i, dSkill in ipairs(skills) do
		--只显示宠物和伙伴修炼技能
		if i > 4 then
			local oBox = self:CreateSkillBox(dSkill, true)
			if i == (self.m_defaultIndex or 1) then
				self:OnSkillSelect(oBox)
			else
				oBox:SetSelected(false)
			end

			if g_SkillCtrl:IsSelectedCultivateSkill(dSkill.sk) then
				oBox.m_CultivateSpr:SetActive(true)
			end
			self.m_SkillBoxList[dSkill.sk] = oBox
			self.m_SkillGrid2:AddChild(oBox)
		end
	end
end

function CSkillCultivatePart.RefreshSKillBox(self, dSkill)
	local oBox = self.m_SkillBoxList[dSkill.sk]
	if oBox then
		oBox.m_Skill = dSkill
		local iCurLevel =g_AttrCtrl.m_BadgeInfo and g_AttrCtrl.m_BadgeInfo.tid  or 1001
  		local tTxData = data.touxiandata.DATA[iCurLevel]
  		local txConfig = g_SkillCtrl:SplitAtt(tTxData, dSkill)
  		--local sTouxianStr = 
  		if txConfig > 0 then
			oBox.m_LevelLabel:SetText("[244B4EFF]等级:"..dSkill.level.."[-][1D8E00FF]+"..txConfig.."[-]")
		else
			oBox.m_LevelLabel:SetText("[244B4EFF]等级:"..dSkill.level.."[-]")
		end
		self.m_UpperLv = g_SkillCtrl:GetCultivateUpperLevel()
		self:OnSkillSelect(oBox)
	end
end

function CSkillCultivatePart.RefreshSeletStatus(self, tSkills)
	local oBox = self.m_SkillBoxList[tSkills.preSkill]
	if oBox then
		oBox.m_CultivateSpr:SetActive(false)
	end
	oBox = self.m_SkillBoxList[tSkills.curSkill]
	oBox.m_CultivateSpr:SetActive(true)
	self:ShowSelectSkillSelect(tSkills)
end

function CSkillCultivatePart.ShowSelectSkillSelect(self, tSkills)
	-- body
	local list1 = self.m_SkillGrid:GetChildList()
	local list2 = self.m_SkillGrid2:GetChildList()
	if tSkills then
		for i,oBox in pairs(list1) do
			if oBox.m_Skill.sk~=tSkills.curSkill then
				oBox.m_SelectLearnSpr:SetActive(false)
			else
				oBox.m_SelectLearnSpr:SetActive(true)
			end
		end
		
		for i,oBox in pairs(list2) do
			if oBox.m_Skill.sk~=tSkills.curSkill then
				oBox.m_SelectLearnSpr:SetActive(false)
			else
				oBox.m_SelectLearnSpr:SetActive(true)
			end
		end
	else
		for i,oBox in pairs(list1) do
			oBox.m_SelectLearnSpr:SetActive(g_SkillCtrl:IsSelectedCultivateSkill(oBox.m_Skill.sk))
		end
		for i,oBox in pairs(list2) do
			oBox.m_SelectLearnSpr:SetActive(g_SkillCtrl:IsSelectedCultivateSkill(oBox.m_Skill.sk))
		end
	end
end


function CSkillCultivatePart.OnSkillSelect(self, oBox)
	self.m_SelectLearnBox = oBox
	oBox:SetSelected(true)
	self:SetSelectedSkill(oBox.m_Skill)

	local bIsSelected = g_SkillCtrl:IsSelectedCultivateSkill(oBox.m_Skill.sk)
	self.m_TypeSelectSpr:SetActive(bIsSelected)
	oBox.m_SelectLearnSpr:SetActive(bIsSelected)
	-- local config = DataTools.GetCultivationData(oBox.m_Skill.sk).costmoney
	-- local Index = self:GetRangeIndex(config,oBox.m_Skill.level)
	-- self.m_Cost = tonumber(config[Index].range)*5
	self:RefreshItem(DataTools.GetCultivationData(oBox.m_Skill.sk).costitem)
	self:RefreshExp()
	self:RefreshDesc(oBox.m_Skill)
	self.m_ContentObj:SetActive(true)
	self.m_TipsLabel:SetActive(false)
	if oBox.m_Skill.level >= self.m_UpperLv then --达到修炼上限
		self.m_LearnBtn:SetEnabled(false)

		self.m_LearnTenBtn:SetEnabled(false)

		self.m_ItemLearnBtn:SetEnabled(false)

	else
		self.m_LearnBtn:SetEnabled(true)

		self.m_LearnTenBtn:SetEnabled(true)

		self.m_ItemLearnBtn:SetEnabled(true)
	end
	-- self.m_ContentObj:SetActive(oBox.m_Skill.level < self.m_UpperLv)
	-- self.m_TipsLabel:SetActive(oBox.m_Skill.level >= self.m_UpperLv)
	-- local deslist = data.skilldata.XILIANTIPS
	-- for i,v in ipairs(deslist) do
	-- 	if g_SkillCtrl.m_CultivateLimitType == v.type then
	-- 		self.m_TipsLabel:SetText(v.des)
	-- 		break
	-- 	end
	-- end
	if oBox.m_Skill.level >= self.m_UpperLv then
		self.m_IsRequest = false
	end
end

function CSkillCultivatePart.OnLongClickLearnSkill(self, value)
	-- if g_WarCtrl:IsWar() then
	-- 	g_NotifyCtrl:FloatMsg("正在战斗中，请稍后再操作")
	-- 	return
	-- end
	self.m_IsRequest = not self.m_IsRequest 
	-- if self.m_Timer then
	-- 	Utils.DelTimer(self.m_Timer)
	-- end
	-- local learn = function()
	-- 	if self.m_Cost > g_AttrCtrl.silver then
	-- 		self:OpenSilverBuyWindow()
	-- 		return false
	-- 	end
	-- 	netskill.C2GSLearnCultivateSkill(self.m_RquestType.silver, self.m_CurSkill.sk)
	-- 	return self.m_IsRequest and self.m_ContentObj:GetActive()
	-- end 	
	-- self.m_Timer = Utils.AddTimer(learn, 1.0, 0)

	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	self.m_LongPressIndex = 2
	self:OnStartNewTimer(self.m_LongPressIndex, value)
end

--长按技能修炼，越来越快
function CSkillCultivatePart.OnStartNewTimer(self,index, value)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	self.m_TimeCount = 0
	local totalCount = self.m_LongPressTime[index][2]/define.Treasure.Time.Delta
	-- printc("总共的时间totalCount:"..totalCount)
	local function progress()
		self.m_TimeCount = self.m_TimeCount + 1
		if self.m_TimeCount%(self.m_LongPressTime[index][1]/0.02) == 0 then
			-- printc("我发送修炼协议index:"..index.." self.m_TimeCount:"..self.m_TimeCount)
			-- if self.m_Cost > g_AttrCtrl.silver then
			-- 	self:OpenSilverBuyWindow()
			-- 	return false
			-- end
			self:JudgeLackItem(1002, value)
			if g_QuickGetCtrl.m_IsLackItem then
				return false
			end
			if value == 1 then
				netskill.C2GSLearnCultivateSkill(self.m_RquestType.silver, self.m_CurSkill.sk)
			else--if value == 10 then
				netskill.C2GSLearnCultivateSkill(self.m_RquestType.tentime, self.m_CurSkill.sk)
			end
			return self.m_ContentObj:GetActive()
		end
		if self.m_TimeCount >= totalCount then
			self.m_LongPressIndex = index + 1
			if self.m_LongPressIndex >= 3 then
				self.m_LongPressIndex = 3
			end
			self:OnStartNewTimer(self.m_LongPressIndex, value)
			return false
		end
		return self.m_IsRequest
	end
	self.m_Timer = Utils.AddTimer(progress, 0.02, 0)
end

function CSkillCultivatePart.OnClickLearnSkill(self, value)
	-- if g_WarCtrl:IsWar() then
	-- 	g_NotifyCtrl:FloatMsg("正在战斗中，请稍后再操作")
	-- 	return
	-- end
	-- if self.m_Cost > g_AttrCtrl.silver then
	-- 	self:OpenSilverBuyWindow()
	-- 	return
	-- end
	self:JudgeLackItem(1002, value)
	if g_QuickGetCtrl.m_IsLackItem then
		return
	end
	if value ==1 then
		netskill.C2GSLearnCultivateSkill(self.m_RquestType.silver, self.m_CurSkill.sk)
	elseif value ==10 then
		netskill.C2GSLearnCultivateSkill(self.m_RquestType.tentime, self.m_CurSkill.sk)
	end
end

function CSkillCultivatePart.OnItemLearnSKill(self)
	-- if g_WarCtrl:IsWar() then
	-- 	g_NotifyCtrl:FloatMsg("正在战斗中，请稍后再操作")
	-- 	return
	-- end

	local sid = self.m_ItemBox:GetBagItem().m_SID
	local iInfo = g_SkillCtrl:GetItemUseInfo(sid)

	if iInfo and iInfo.flag_limit == 1 and iInfo.count_limit < 1 then
		g_NotifyCtrl:FloatMsg("今日次数已用完")
		return
	end

	self:JudgeLackItem(sid)
	if g_QuickGetCtrl.m_IsLackItem then
		return
	end
	netskill.C2GSLearnCultivateSkill(self.m_RquestType.item, self.m_CurSkill.sk)
end

-- 设置修炼类型：人物、伙伴
function CSkillCultivatePart.OnChangeType(self)
	g_NotifyCtrl:FloatMsg("更改类型")
	self.m_TypeSelectSpr:SetActive(true)
	netskill.C2GSSetCultivateSkill(self.m_CurSkill.sk)
end

-- function CSkillCultivatePart.OpenSilverBuyWindow(self)
-- 	local windowConfirmInfo = {
-- 		msg				= "银币不足，请购买？",
-- 		title			= "提示",
-- 		okCallback = function ()
-- 			CCurrencyView:ShowView(function(oView)
-- 				oView:SetCurrencyView(define.Currency.Type.Silver)
-- 			end)
-- 		end,
-- 	}
-- 	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
-- 		self.m_WinTipViwe = oView
-- 	end)
-- end

function CSkillCultivatePart.GetRangeIndex(self,pConfig,pLevel)
	local MinIndex = 1
	for k,v in ipairs(pConfig) do
		if v.level <= pLevel then
			MinIndex = k
		else
			break
		end
	end
	return MinIndex
end

function CSkillCultivatePart.JudgeLackItem(self, sid, value)
	local itemlist = {}
	local coinlist = {}
	if sid == 1002 then 
		-- local value = value or 1
		-- local config = DataTools.GetCultivationData(self.m_CurSkill.sk).costmoney
		-- local Index = self:GetRangeIndex(config,self.m_CurSkill.level)
		-- local cost  = value * tonumber(config[Index].range)*5
		local costinfo = data.skilldata.CultivationLimitTime

		if value == 1 then
			if costinfo[1].silvercost > g_AttrCtrl.silver then
				local t = {sid = 1002 , count = g_AttrCtrl.silver ,amount = costinfo[1].silvercost }
				table.insert(coinlist, t)
			end
		elseif value == 10 then
			local dData = nil 
			for _,v in ipairs(costinfo) do
				if g_AttrCtrl.grade < v.playerlevel then
					dData = v
					break
				end
			end
			if not dData then
				dData = costinfo[#costinfo]
			end
			if dData.silvercost > g_AttrCtrl.silver then
				local t = {sid = 1002 , count = g_AttrCtrl.silver ,amount = dData.silvercost }
				table.insert(coinlist, t)
			end
		end
	else
		local iSum = g_ItemCtrl:GetBagItemAmountBySid(sid)
		if  iSum == 0 then
			local t = {sid = sid , count = 0, amount = 1}
			table.insert(itemlist, t)
		end
	end
	g_QuickGetCtrl:CurrLackItemInfo(itemlist, coinlist)
end

return CSkillCultivatePart
local CSummonAdjustPart = class("CSummonAdjustPart", CPageBase)

-- 废弃脚本
function CSummonAdjustPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_StudySkillConsume = 0
	self.m_TrainToolItemId = 10031 --洗练物品ID
	self.m_ToolDesId = 2002
	self.m_TrainHintId_1 = 1013
	self.m_TrainHintId_2 = 1003
	self.m_TrainHintId_3 = 1027
	self.m_SummonSelHintId = 1045
	self.m_SummonEmptyHintId = 1030 
	self.m_CompoundUnlockId = 2009
	self.m_IsSelEmptyItem = false
	self.m_IsUnlockCompound= data.opendata.OPEN["SUMMON_HC"].p_level <= g_AttrCtrl.grade
	self.g_SummonCtrl = g_SummonCtrl
end

function CSummonAdjustPart.OnInitPage(self)
	self.m_WashBtn = self:NewUI(1, CButton)
	self.m_CompoundBtn = self:NewUI(2, CButton)
	self.m_SkillBtn = self:NewUI(3, CButton)
	self.m_CultureBtn = self:NewUI(9, CButton)
	self.m_WashBtn:SetGroup(self:GetInstanceID())
	self.m_CompoundBtn:SetGroup(self:GetInstanceID())	
	self.m_SkillBtn:SetGroup(self:GetInstanceID())
	self.m_CultureBtn:SetGroup(self:GetInstanceID())
	self.m_WashBtn:SetSelected(true)
	self.m_RStudySkillPage = self:NewUI(6, CSummonRStudySkillPageBox, true, self)
	self.m_CompoundPage = self:NewUI(8, CSummonCompoundPageBox)
	self.m_RSkillPage = self:NewUI(5, CSummonRSkillPageBox)
	self.m_LAttPage = self:NewUI(4, CSummonLAttrPageBox)
	self.m_LCulturePage = self:NewUI(10, CSummonCulturePageBox)
	self:InitContent()
end

function CSummonAdjustPart.InitContent(self)
	g_GuideCtrl:AddGuideUI("petview_compound_btn", self.m_CompoundBtn)

	self.m_CompoundBtn:SetGrey(not self.m_IsUnlockCompound)
	self.m_CurSummonId = self.g_SummonCtrl:GetCurSelSummon()
	if self.m_CurSummonId == nil then
		self.m_CurSummonId = self.g_SummonCtrl:GetSummonIdByIndex(1)
		self.g_SummonCtrl:SetCurSelSummon(self.m_CurSummonId)
	end 
	self:InitBtns()
	self:InitEvent()
	self:OnWash()
end 

function CSummonAdjustPart.InitBtns(self)
	self.m_Btns = self.m_RSkillPage:NewUI(5, CBox)
    self.m_ToolPic = self.m_Btns:NewUI(1, CButton)
    self.m_ToolName = self.m_Btns:NewUI(2, CLabel)
    self.m_ToolCount = self.m_Btns:NewUI(3, CLabel)
    self.m_ToolDesBtn = self.m_Btns:NewUI(4, CButton) 
	self.m_TrainBtn = self.m_Btns:NewUI(5, CButton)
	local item = DataTools.GetItemData(self.m_TrainToolItemId)
	self.m_ToolPic:SpriteItemShape(item.icon)
    self.m_ToolName:SetText(item.name)
	self.m_ToolPic:AddUIEvent("click", function ()
		-- local config = {widget = self.m_ToolPic}
		-- g_WindowTipCtrl:SetWindowItemTip(self.m_TrainToolItemId, config)
		g_WindowTipCtrl:SetWindowGainItemTip(self.m_TrainToolItemId) 
	end)
end

--更新信息
function CSummonAdjustPart.SetPropertyInfo(self, summonId, isChange)
	local  dp = g_SummonCtrl:GetSummon(summonId)
	if dp == nil then 
		return
	end	
	self.m_CurSummonId = summonId
	g_SummonCtrl:SetCurSelSummon(self.m_CurSummonId)
	if self.m_LAttPage:GetActive() then
		self.m_LAttPage:SetInfo(self.m_CurSummonId)
		if isChange == nil then
			self.m_LAttPage:UpdateAllItem(self.m_CurSummonId)			
		end
	end
	if self.m_RSkillPage:GetActive() then 
		self.m_RSkillPage:SetInfo(self.m_CurSummonId)
	end
	if self.m_RStudySkillPage:GetActive() then 
		self.m_RStudySkillPage:SetInfo(self.m_CurSummonId)
	end
	if self.m_LCulturePage:GetActive() then
		self.m_LCulturePage:SetInfo(self.m_CurSummonId)
	end
	self:UpdateToolsConut()
end

function CSummonAdjustPart.OnCtrlEvent(self, oCtrl)
	if self:GetActive() == false then
		return
	end
	if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo and self.m_CurSummonId == oCtrl.m_EventData.id then	
		self:SetPropertyInfo(self.m_CurSummonId)
	end	
	if oCtrl.m_EventID == define.Summon.Event.WashDelSummon then
		self.m_LAttPage:DelSummonItem(oCtrl.m_EventData)
	end 
	if oCtrl.m_EventID == define.Summon.Event.DelSummon then
		self.m_LAttPage:DelSummonItem(oCtrl.m_EventData)	
		if next(g_SummonCtrl:GetSummons()) == nil then
			g_SummonCtrl:SetCurSelSummon(nil)
			--g_NotifyCtrl:FloatSummonMsg(self.m_SummonEmptyHintId)
			self.m_ParentView:OnClose()
		end
		if g_SummonCtrl:GetSummon(self.m_CurSummonId) == nil then
			self.m_CurSummonId = g_SummonCtrl:GetSummonIdByIndex(1)
			g_SummonCtrl:SetCurSelSummon(self.m_CurSummonId)
		end
		if self.m_LAttPage:GetActive() then
			self.m_LAttPage:UpdateAllItem(self.m_CurSummonId)		
		end
	end
	if oCtrl.m_EventID == define.Summon.Event.WashSummonAdd then 
		local summon = g_SummonCtrl:GetSummon(oCtrl.m_EventData)
		if summon ~= nil then 
			self.m_CurSummonId = oCtrl.m_EventData
			self:SetPropertyInfo(self.m_CurSummonId)
		end				
	end
	if oCtrl.m_EventID == define.Summon.Event.AddSummon then 
		if self.m_LAttPage:GetActive() then
			self.m_LAttPage:UpdateAllItem(self.m_CurSummonId)
		end
	end
	if oCtrl.m_EventID == define.Summon.Event.BagItemUpdate then 					
		self.m_CurSummonId = self.g_SummonCtrl:GetCurSelSummon()
		if self.g_SummonCtrl:GetSummon(self.m_CurSummonId) == nil then 
			return
		end	
		--刷新还童丹数量
		self:UpdateToolsConut()
	end
	--显示新的合成宠物界面
	if oCtrl.m_EventID == define.Summon.Event.CombineSummonShow then 
		self.m_CurSummonId = oCtrl.m_EventData
		CSummonComOutView:ShowView(function (oView)
			oView:SetData(self.m_CurSummonId)
		end)
		self.m_CompoundPage:CompoundHide()		
	end
	--切换宠物
	if oCtrl.m_EventID == define.Summon.Event.ChangeSummonShow then
		if oCtrl.m_EventData == nil then
			self.m_IsSelEmptyItem = true
			return
		end
		self.m_IsSelEmptyItem = false
		self:SetPropertyInfo(oCtrl.m_EventData, true)
	end 
end

function CSummonAdjustPart.UpdateToolsConut(self)
	local count = g_ItemCtrl:GetBagItemAmountBySid(self.m_TrainToolItemId)
	local oWashData = self:GetWashCostData()[self.g_SummonCtrl:GetSummon(self.m_CurSummonId).carrygrade]
	if not oWashData then
		return
	end
	--self.m_ToolCount:SetColor(Color.green)
	local cnt = oWashData.cnt
	-- if count < cnt then 
	-- 	self.m_ToolCount:SetColor(Color.red)
	-- end
	local text = count >= cnt and string.format("[1D8E00]%s/%s[-]", count, cnt) or string.format("[D71420]%s/%s[-]", count, cnt)
	self.m_ToolCount:SetText(text)
end

function CSummonAdjustPart.InitEvent(self)
	g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_TrainBtn:AddUIEvent("click", callback(self, "OnTrain"))
	self.m_SkillBtn:AddUIEvent("click", callback(self, "OnStudySkill"))
	self.m_WashBtn:AddUIEvent("click", callback(self, "OnWash"))
	self.m_CompoundBtn:AddUIEvent("click", callback(self, "OnCompoundShow"))
	self.m_CultureBtn:AddUIEvent("click", callback(self, "OnCulture"))	
	self.m_ToolDesBtn:AddUIEvent("click",function ()
	local zContent = {title = "洗宠",desc = data.summondata.TEXT[self.m_ToolDesId].content}
    	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	end)	
end

--显示合成页面
function CSummonAdjustPart.OnCompoundShow(self)
	if not self.m_IsUnlockCompound then
		local msg = data.summondata.TEXT[self.m_CompoundUnlockId].content
		msg = string.gsub(msg, "#grade", data.opendata.OPEN["SUMMON_HC"].p_level)
		g_NotifyCtrl:FloatMsg(msg)
		self:OnWash()
		return
	end
	self.m_CompoundBtn:SetSelected(true)
	self.m_LAttPage:SetActive(false)
	self.m_RSkillPage:SetActive(false)
	self.m_RStudySkillPage:SetActive(false)
	self.m_LCulturePage:SetActive(false)
	self.m_CompoundPage:SetActive(true)
	self.m_CompoundPage:CompoundHide()
end

--显示技能页面
function CSummonAdjustPart.OnStudySkill(self)
	self.m_RSkillPage:SetActive(false)
	self.m_CompoundPage:SetActive(false)
	self.m_LCulturePage:SetActive(false)
	self.m_LAttPage:SetActive(true)
	self.m_SkillBtn:SetSelected(true)
	self.m_RStudySkillPage:SetActive(true)
	self:SetPropertyInfo(self.m_CurSummonId)
end

--显示培养页面
function CSummonAdjustPart.OnCulture(self)
	self.m_RStudySkillPage:SetActive(false)	
	self.m_RSkillPage:SetActive(false)
	self.m_CompoundPage:SetActive(false)
	self.m_CultureBtn:SetSelected(true)
	self.m_LAttPage:SetActive(true)
	self.m_LCulturePage:SetActive(true)
	self:SetPropertyInfo(self.m_CurSummonId)
end

--显示洗练
function CSummonAdjustPart.OnWash(self)
	self.m_WashBtn:SetSelected(true)
	self.m_RStudySkillPage:SetActive(false)
	self.m_CompoundPage:SetActive(false)
	self.m_LCulturePage:SetActive(false)
	self.m_RSkillPage:SetActive(true)	
	self.m_LAttPage:SetActive(true)
	self:SetPropertyInfo(self.m_CurSummonId)
end

--洗练
function CSummonAdjustPart.OnTrain(self)
	--self.m_CurTime = g_TimeCtrl:GetTimeS()
	if self.m_IsSelEmptyItem then
		g_NotifyCtrl:FloatSummonMsg(self.m_SummonSelHintId)
		return
	end
	if self.m_CurSummonId == self.g_SummonCtrl.m_FightId then
		g_NotifyCtrl:FloatSummonMsg(self.m_TrainHintId_1)
		return
	end
	printc("On Click Train ---------------- ")
	local rank = {S = true, SS = true, SSS = true}
	local summon = self.g_SummonCtrl:GetSummon(self.m_CurSummonId)
	-- TODO:策划需求临时修改，暂时不做等级过滤
	-- if summon.type ~= 1 and summon.grade > 10 then
	-- 	g_NotifyCtrl:FloatSummonMsg(self.m_TrainHintId_2)
	-- 	return
	-- end
	-- 临时去掉了
	-- self:JudgeLackList()
	-- if g_QuickGetCtrl.m_IsLackItem then
	-- 	return
	-- end
	if rank[summon.rank] == true or #summon.skill >= 4 then
		local windowConfirmInfo = {
		msg				= data.summondata.TEXT[self.m_TrainHintId_3].content,
		title			= "洗练",
		okCallback = function ()
			self.g_SummonCtrl:WashSummon(self.m_CurSummonId)
		end,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self.g_SummonCtrl:WashSummon(self.m_CurSummonId)
	end
end

function CSummonAdjustPart.GetWashCostData(self)
	return data.summondata.WASHDATA
end

function CSummonAdjustPart.OnShowPage(self)
	self.m_CurSummonId = g_SummonCtrl:GetCurSelSummon()
	if  self.m_CurSummonId == nil then 
		self.m_CurSummonId = g_SummonCtrl:GetSummonIdByIndex(1)
	end	
	g_SummonCtrl.m_LAttrPage = self.m_LAttPage	
	self:SetPropertyInfo(self.m_CurSummonId)
end

function CSummonAdjustPart.JudgeLackList(self)
	local oWashData = self:GetWashCostData()[self.g_SummonCtrl:GetSummon(self.m_CurSummonId).carrygrade]
	local cnt = oWashData.cnt
	local iSum = g_ItemCtrl:GetBagItemAmountBySid(self.m_TrainToolItemId)
	local itemlist = {}
	if iSum < cnt then
		local t = {sid = self.m_TrainToolItemId, count = iSum, amount = cnt}
		table.insert(itemlist, t)
	end
	g_QuickGetCtrl:CurrLackItemInfo(itemlist,{})
end
return CSummonAdjustPart
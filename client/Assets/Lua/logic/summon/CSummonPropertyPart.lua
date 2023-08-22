local CSummonPropertyPart = class("CSummonPropertyPart", CPageBase)

function CSummonPropertyPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_SummonFreeHintId = 1028
	self.m_SummonFollowHintId = 1029
	self.m_SummonEmptyHintId = 1030
	self.m_SummonSelHintId = 1045
	self.m_SummonFollowHintId_2 = 1047
	self.m_SummonBackHintId_1 = 1046
	self.m_SummonFreeHintId_2 = 1048
	self.m_IsWarChangeHintId = 1049
	self.m_IsSelEmptyItem = false
end

function CSummonPropertyPart.OnInitPage(self)
	self.m_EquipBtn = self:NewUI(1, CButton)
	self.m_AttPageBtn = self:NewUI(2, CButton)
	self.m_SkillBtn = self:NewUI(3, CButton)
	self.m_RAttPage = self:NewUI(4, CSummonRAttrPageBox)	
	self.m_FollowBtn = self:NewUI(5, CButton)
	self.m_FightBtn = self:NewUI(6, CButton)
	self.m_FreeBtn = self:NewUI(7, CButton)
	
	self.m_LAttPage = self:NewUI(8, CSummonLAttrPageBox)
	self.m_RSkillPage = self:NewUI(9, CSummonRSkillPageBox)
	self:InitContent()	
end

function CSummonPropertyPart.InitContent(self)
	g_GuideCtrl:AddGuideUI("pet_fight_btn", self.m_FightBtn)

	self.m_CurSummonId = g_SummonCtrl:GetCurSelSummon()
	if  self.m_CurSummonId == nil then
		self.m_CurSummonId = g_SummonCtrl:GetSummonIdByIndex(1)
		g_SummonCtrl:SetCurSelSummon(self.m_CurSummonId)
	end 
	self.m_LAttPage:SetActive(true)
	self.m_RAttPage:SetActive(true)						
	self.m_RSkillPage:SetActive(false)
	self.m_AttPageBtn:AddUIEvent("click", callback(self, "OnAttPage"))
	self.m_AttPageBtn:SetGroup(self:GetInstanceID())
	self.m_AttPageBtn:SetSelected(true)
	self.m_SkillBtn:AddUIEvent("click", callback(self, "SkillInfo"))
	self.m_SkillBtn:SetGroup(self:GetInstanceID())
	self.m_EquipBtn:SetActive(false) --屏蔽宠物装备按钮
	self.m_EquipBtn:SetGroup(self:GetInstanceID())
	self.m_FreeBtn:AddUIEvent("click", callback(self, "Free"))
	self.m_FightBtn:AddUIEvent("click", callback(self, "IsFight"))
	self.m_FollowBtn:AddUIEvent("click", callback(self, "OnIsFollow"))
	g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))	
end

--事件回调
function CSummonPropertyPart.OnCtrlEvent(self, oCtrl)
	if self:GetActive() == false then
		return
	end
	local g_SummonCtrl = g_SummonCtrl
	--更新宠物信息
	if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo and self.m_CurSummonId == oCtrl.m_EventData.id then	
		self.m_LAttPage:UpdateAllItem(self.m_CurSummonId)
		self:SetPropertyInfo(self.m_CurSummonId)
	end
	--删除宠物
	if oCtrl.m_EventID == define.Summon.Event.DelSummon then
		self.m_LAttPage:DelSummonItem(oCtrl.m_EventData)	
		if next(g_SummonCtrl:GetSummons()) == nil then
			self.m_ParentView:OnClose()
			g_SummonCtrl:SetCurSelSummon(nil)
			--g_NotifyCtrl:FloatSummonMsg(self.m_SummonEmptyHintId)
			return
		end		
		if g_SummonCtrl:GetSummon(self.m_CurSummonId) == nil then
			self.m_CurSummonId = g_SummonCtrl:GetSummonIdByIndex(1)
			g_SummonCtrl:SetCurSelSummon(self.m_CurSummonId)
		end
		self.m_LAttPage:UpdateAllItem(self.m_CurSummonId)
		self:SetPropertyInfo(self.m_CurSummonId)
	end
	--响应是否参战
	if oCtrl.m_EventID == define.Summon.Event.SetFightId then
		if oCtrl.m_EventData == nil then	
			return
		end
		self.m_LAttPage:SetFight(oCtrl.m_EventData, self.m_CurSummonId)
		if g_WarCtrl:IsWar() then
			g_NotifyCtrl:FloatSummonMsg(self.m_IsWarChangeHintId)
		end
	    if oCtrl.m_EventData == 0 then
			self.m_FightBtn:SetText("参战")		
		else
			self.m_FightBtn:SetText("休息")
		end 		
	end
	--添加宠物
	if oCtrl.m_EventID == define.Summon.Event.AddSummon then
		self.m_LAttPage:UpdateAllItem(self.m_CurSummonId)	
	end
	--是否跟随
	if oCtrl.m_EventID == define.Summon.Event.SetFollow then
		if oCtrl.m_EventData == self.m_CurSummonId then
			self.m_FollowBtn:SetText("收回")
			g_NotifyCtrl:FloatSummonMsg(self.m_SummonFollowHintId_2)
		else
			self.m_FollowBtn:SetText("跟随")
			g_NotifyCtrl:FloatSummonMsg(self.m_SummonBackHintId_1)	
		end 
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

--显示基础属性
function CSummonPropertyPart.OnAttPage(self)
	self.m_RSkillPage:SetActive(false)
	self.m_RAttPage:SetActive(true)
	self.m_LAttPage:SetActive(true)	
	self:SetPropertyInfo(self.m_CurSummonId)
end

--显示技能信息
function CSummonPropertyPart.SkillInfo(self)
	self.m_RSkillPage:SetActive(true)
	self.m_LAttPage:SetActive(true)
	self.m_RAttPage:SetActive(false)
	self:SetPropertyInfo(self.m_CurSummonId)
	self.m_LAttPage:SetItemRedPoint(self.m_CurSummonId, false)
end

--设置跟随
function CSummonPropertyPart.OnIsFollow(self)
	if self.m_IsSelEmptyItem then
		g_NotifyCtrl:FloatSummonMsg(self.m_SummonSelHintId)
		return
	end

	-- if g_HorseCtrl:IsUsingFlyRide() then 
	-- 	g_NotifyCtrl:FloatSummonMsg(1053)
	-- 	return
	-- end 

	if self.m_CurSummonId == g_SummonCtrl.m_FollowId then 
		g_SummonCtrl:SendIsFollow(self.m_CurSummonId, 2)		
	elseif (not g_TeamCtrl:IsJoinTeam()) or (g_TeamCtrl:IsLeader()) then
		g_SummonCtrl:SendIsFollow(self.m_CurSummonId, 1)		
	else
		g_NotifyCtrl:FloatSummonMsg(self.m_SummonFollowHintId)
	end
	self.m_LAttPage:SetItemRedPoint(self.m_CurSummonId, false)
end

--放生宠物
function CSummonPropertyPart.Free(self)
	if self.m_IsSelEmptyItem then
		g_NotifyCtrl:FloatSummonMsg(self.m_SummonSelHintId)
		return
	end
	if self.m_CurSummonId == g_SummonCtrl.m_FightId then 
		g_NotifyCtrl:FloatSummonMsg(self.m_SummonFreeHintId)
		return
	end
	if self.m_CurSummonId == g_SummonCtrl.m_FollowId then 
		g_NotifyCtrl:FloatSummonMsg(self.m_SummonFreeHintId_2)
		return
	end
	self:WildFree()
	-- local summon = g_SummonCtrl:GetSummon(self.m_CurSummonId)
	-- if summon.type >= 3 then 
	-- 	self:WildFree()
	-- else
	-- 	g_SummonCtrl:ReleaseSummon(self.m_CurSummonId)
	-- end
end

--变异宠物放生
function CSummonPropertyPart.SpecialFree(self)
	SummonFreeSureView:ShowView()
end

--普通宠物放生
function CSummonPropertyPart.WildFree(self)
	local summon = g_SummonCtrl:GetSummon(self.m_CurSummonId)
	local sDesc = "[63432c]宠物放生后将无法找回，确定放生[-]#P"..summon.name.."#n？"
	local windowConfirmInfo = {
		msg = sDesc,
		title = "提示",
		okCallback = function ()		 						
			g_SummonCtrl:ReleaseSummon(self.m_CurSummonId)
		end,	
		cancelCallback = nil,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

--设置参战宠物
function CSummonPropertyPart.IsFight(self)
	if self.m_IsSelEmptyItem then
		g_NotifyCtrl:FloatSummonMsg(self.m_SummonSelHintId)
		return
	end
	if self.m_CurSummonId == g_SummonCtrl.m_FightId then 
		g_SummonCtrl:SetFight(self.m_CurSummonId, 0)
	else		
		g_SummonCtrl:SetFight(self.m_CurSummonId, 1)
	end	
end

--更新宠物信息
function CSummonPropertyPart.SetPropertyInfo(self, summonId)
	if g_SummonCtrl:GetSummon(summonId) == nil then
		printc("宠物不存在")
		return
	end
	g_SummonCtrl:SetCurSelSummon(summonId)
	self.m_CurSummonId = summonId
	self.m_LAttPage:SetInfo(summonId)	
	self.m_RSkillPage:SetInfo(summonId, "")
	self.m_RAttPage:SetInfo(summonId)
	self:SetBtnInfo(summonId)
end

function CSummonPropertyPart.SetBtnInfo(self, summonId)
	local g_SummonCtrl = g_SummonCtrl
	if summonId == g_SummonCtrl.m_FightId then 
		self.m_FightBtn:SetText("休息")
	else
		self.m_FightBtn:SetText("参战")
	end
	if summonId == g_SummonCtrl.m_FollowId then 
		self.m_FollowBtn:SetText("收回")			
	else		
		self.m_FollowBtn:SetText("跟随")
	end			
end

function CSummonPropertyPart.OnShowPage(self)
	self.m_CurSummonId = g_SummonCtrl:GetCurSelSummon()
	if self.m_CurSummonId == nil or self.m_CurSummonId == 0 then 
		self.m_CurSummonId = g_SummonCtrl:GetSummonIdByIndex(1)
	end
	g_SummonCtrl.m_LAttrPage = self.m_LAttPage
	self.m_LAttPage:UpdateAllItem(self.m_CurSummonId)
	self:SetPropertyInfo(self.m_CurSummonId)	
end

return CSummonPropertyPart
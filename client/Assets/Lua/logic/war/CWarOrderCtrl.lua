local CWarOrderCtrl = class("CWarOrderCtrl")
CWarOrderCtrl.g_OrderTime = 30
CWarOrderCtrl.g_AutoOrderTime = 2
--ÒÑÖ§³Öorder
--Attack Magic Escape Protect Defend Call
function CWarOrderCtrl.ctor(self)
	CDelayCallBase.ctor(self)
	self.m_OrderDone = {hero=false, summon=false, global = false}
	self.m_OrderInfo = {name="", targetID=nil, orderID=nil}
	self.m_GlobalOrderInfo = {name="", targetID=nil, orderID=nil, extral=nil}
	self.m_IsCanOrder = false
	self.m_TimeInfo = nil
	self.m_ChooseMagic = nil
end

function CWarOrderCtrl.GetOrderInfo(self)
	return self.m_OrderInfo
end

function CWarOrderCtrl.GetGlobalOrderInfo(self)
	return self.m_GlobalOrderInfo
end

function CWarOrderCtrl.IsOrderDone(self, sKey)
	return self.m_OrderDone[sKey]
end

function CWarOrderCtrl.Bout(self, iOrderTime)
	if g_WarCtrl:GetViewSide() then
		return
	end

	self.m_IsCanOrder = true
	self.m_OrderDone = {hero=false, summon=false, global = false}
	local oWarView = CWarMainView:GetView()
	if oWarView then
		oWarView:CheckShow()
	end
	iOrderTime = iOrderTime or CWarOrderCtrl.g_OrderTime
	self.m_TimeInfo = {start_time = g_TimeCtrl:GetTimeS(), order_time = iOrderTime}
	self.m_IsHero = true
	local oFloatView = CWarFloatView:GetView()
	if oFloatView then
		self.m_TimeInfo = {start_time = g_TimeCtrl:GetTimeS(), order_time = iOrderTime}
		oFloatView.m_BoutTimeBox:StartCountDown()
		if not g_WarCtrl:IsAutoWar() then
			oFloatView:ShowTipBeforeOrder()
		end
	end
	self.m_ChooseMagic = nil
	self:DefaultOrder()
end

function CWarOrderCtrl.DefaultOrder(self)
	self.m_OrderInfo.name = "Attack"
	if not self:HasGlobalOrder() then
		self:ShowSelectTarget(true, false)
	end
end

function CWarOrderCtrl.GetRemainTime(self)
	if self.m_TimeInfo then
		local iRemain = self.m_TimeInfo.order_time - (g_TimeCtrl:GetTimeS() - self.m_TimeInfo.start_time)
		return iRemain
	else
		return nil
	end
end

function CWarOrderCtrl.GetAutoEndTime(self)
	return CWarOrderCtrl.g_OrderTime - CWarOrderCtrl.g_AutoOrderTime
end

function CWarOrderCtrl.GetAutoOrderTime(self)
	return CWarOrderCtrl.g_AutoOrderTime
end

function CWarOrderCtrl.IsCanOrder(self)
	return self.m_IsCanOrder
end

function CWarOrderCtrl.HasGlobalOrder(self)
	return self.m_GlobalOrderInfo.name ~= ""
end

function CWarOrderCtrl.FinishOrder(self)
	self.m_IsCanOrder = false
	self.m_OrderInfo = {name="", targetID=nil, orderID=nil}
	self.m_OrderDone = {hero=false, summon=false}
	if not self:HasGlobalOrder() then
		self:ShowSelectTarget(false)
	end
	self.m_OrderTimeInfo = nil
	self.m_TimeInfo = nil
	local oWarView = CWarMainView:GetView()
	if oWarView then
		oWarView:CheckShow()
	end
	local oFloatView = CWarFloatView:GetView()
	if oFloatView and not self:HasGlobalOrder() then
		oFloatView:FinishOrder()
	end
	local oWarItemView = CWarItemView:GetView()
	if oWarItemView then
		oWarItemView:CloseView()
	end
	g_ViewCtrl:CloseGroup("WarOrder")
end

function CWarOrderCtrl.FinishGlobalOrder(self)
	self.m_IsGlobal = false
	self.m_GlobalOrderInfo = {name="", targetID=nil, orderID=nil, extral=nil}
	self.m_OrderDone = {global = false}
	self:ShowSelectTarget(false)
	local oFloatView = CWarFloatView:GetView()
	if oFloatView then
		oFloatView:FinishOrder()
	end
end

function CWarOrderCtrl.TimeUp(self)
	printc("TimeUp!!!! Bout | CurTimes" .. tostring(g_WarCtrl.m_Bout), g_TimeCtrl:GetTimeS(), g_WarCtrl.m_FirstSpecityWarStep, g_WarCtrl.m_Bout)
	if g_WarCtrl.m_IsFirstSpecityWar then
		if g_WarCtrl.m_FirstSpecityWarStep == 2 and g_WarCtrl.m_Bout == 1 then
			g_WarCtrl.m_FirstSpecityWarStep = 3
			warsimulate.Bout1()
		elseif g_WarCtrl.m_FirstSpecityWarStep == 3 and g_WarCtrl.m_Bout == 2 then
			g_WarCtrl.m_FirstSpecityWarStep = 4
			g_WarCtrl.m_IsAutoWar = 1
			warsimulate.Bout2()
		elseif g_WarCtrl.m_FirstSpecityWarStep == 4 and g_WarCtrl.m_Bout == 3 then
			g_WarCtrl.m_FirstSpecityWarStep = 5
			g_WarCtrl.m_IsAutoWar = 1
			warsimulate.Bout3()
		end
		return
	end

	--[[
	g_WarCtrl:SetAutoWar(1)
	if self.m_OrderDone.hero == false then
		self:HeroAutoWar()
	end
	if self.m_OrderDone.summon == false then
		self:SummonAutoWar()
	end
	netwar.C2GSWarAutoFight(g_WarCtrl:GetWarID(), 1)
	self:FinishOrder()
	]]--
	self:FinishOrder()
end

function CWarOrderCtrl.GetRandomVictim()
	local victims = {}
	for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		if not oWarrior:IsAlly() then
			table.insert(victims, oWarrior)
		end
	end
	local i = Utils.RandomInt(1, #victims)
	return victims[i]
end

function CWarOrderCtrl.HeroAutoWar(self)
	local id = g_WarCtrl:GetHeroAutoMagic()
	local target = self:GetRandomVictim()
	local dInfo
	if id == 101 then
		dInfo = {name="Attack", targetID=target.m_ID}
	elseif id == 102 then
		dInfo = {name="Defend"}
	else
		dInfo = {name="Magic", targetID=target.m_ID, orderID=id}
	end
	self.m_IsHero = true
	self.m_OrderInfo = dInfo
	self:SendOrder()
end

function CWarOrderCtrl.SummonAutoWar(self)
	local id = g_WarCtrl:GetSummonAutoMagic()
	local target = self:GetRandomVictim()
	local dInfo
	if id == 101 then
		dInfo = {name="Attack", targetID=target.m_ID}
	elseif id == 102 then
		dInfo = {name="Defend"}
	else
		dInfo = {name="Magic", targetID=target.m_ID, orderID=id}
	end
	self.m_IsHero = false
	self.m_OrderInfo = dInfo
	self:SendOrder()
end

function CWarOrderCtrl.SetGlobalOrder(self, sOrderName, iOrderID, sExtral)
	self.m_GlobalOrderInfo = {name=sOrderName, targetID=nil, orderID=iOrderID, extral = sExtral}
	self.m_IsGlobal = true 
	self:CheckSelTarget()
end

function CWarOrderCtrl.SetHeroOrder(self, sOrderName, iOrderID)
	self:FinishGlobalOrder()
	self.m_OrderInfo = {name=sOrderName, targetID=nil, orderID=iOrderID}
	self.m_IsHero = true
	self.m_ChooseMagic = true
	self:CheckSelTarget()
end

function CWarOrderCtrl.SetSummonOrder(self, sOrderName, iOrderID)
	self:FinishGlobalOrder()
	self.m_OrderInfo = {name=sOrderName, targetID=nil, orderID=iOrderID}
	self.m_IsHero = false
	self.m_ChooseMagic = true
	self:CheckSelTarget()
end

function CWarOrderCtrl.CheckSelTarget(self)
	if self:IsNeedSelTarget(self.m_OrderInfo.name) or self:IsNeedSelTarget(self.m_GlobalOrderInfo.name) then
		local oFloatView = CWarFloatView:GetView()
		if oFloatView then
			oFloatView:ShowOrderTip()
		end
		self:ShowSelectTarget(true)
	else
		self:SendOrder()
	end
end

function CWarOrderCtrl.IsNeedSelTarget(self, sOrderName)
	local list = {"Attack", "Magic", "Protect", "WarItem", "TeamAppoint", "AddTeamCmd", "ClearTeamCmd"}
	return table.index(list, sOrderName) ~= nil
end

function CWarOrderCtrl.SetTargetID(self, iTargetID)
	if g_WarCtrl.m_IsFirstSpecityWar and g_WarCtrl:GetBout() ~= 1 then
		-- 首战斗除首回合外跳过
		return
	end

	local oFloatView = CWarFloatView:GetView()
	if oFloatView then
		oFloatView:HideOrderTip()
	end
	--ÓÅÏÈÖ´ÐÐglobalµÄ²Ù×÷Ñ¡Ôñ£¬¶øºó»Ö¸´Ö´ÐÐÆÕÍ¨µÄ¹¥»÷Ä§·¨ÃüÁî
	if self.m_IsGlobal then
		self.m_GlobalOrderInfo.targetID = iTargetID
		self:ShowSelectTarget(false)
		self:SendGlobalOrder()
		if self.m_OrderInfo.name ~= "" then
			--×Ô¶¯Õ½¶·²»ÏÔÊ¾floatview
			-- if g_WarCtrl:IsAutoWar() then
				self:ShowSelectTarget(true)
			-- else
			-- 	self:CheckSelTarget()
			-- end
		end
		return
	end
	self.m_OrderInfo.targetID = iTargetID
	self:SendOrder()
end

function CWarOrderCtrl.ShowSelectTarget(self, canOrder, showSprite)
	if showSprite ~= false then
		showSprite = true
	end
	local list = g_WarCtrl:GetWarriors()
	for i, oWarrior in pairs(list) do
		if Utils.IsExist(oWarrior) then
			if canOrder then
				local bTarget = self:IsGlobalOrderTarget(oWarrior) or self:IsOrderTarget(oWarrior)
				oWarrior:ShowSelSpr(bTarget, showSprite)
				oWarrior.m_Actor:SetColliderEnbled(bTarget or oWarrior:IsAlly())
			else
				oWarrior:ShowSelSpr(false)
				oWarrior.m_Actor:SetColliderEnbled(true)
			end
		end
	end
end

function CWarOrderCtrl.ShowWarriorSelectTarget(self, oWarrior)
	if Utils.IsExist(oWarrior) then
		if self.m_ChooseMagic or not self:HasGlobalOrder() then
			local bTarget = self:IsGlobalOrderTarget(oWarrior) or self:IsOrderTarget(oWarrior)
			oWarrior:ShowSelSpr(bTarget, self.m_ChooseMagic and true or false)
			oWarrior.m_Actor:SetColliderEnbled(bTarget or oWarrior:IsAlly())
		end
	end
end

function CWarOrderCtrl.CancelSelectTarget(self)
	self.m_OrderInfo.orderID = nil
	self.m_GlobalOrderInfo.orderID = nil
	self.m_IsGlobal = false
	self.m_ChooseMagic = nil
	local oFloatView = CWarFloatView:GetView()
	if oFloatView then
		oFloatView:HideOrderTip()
		oFloatView:ShowTipBeforeOrder()
	end
	self:DefaultOrder()
	-- self:ShowSelectTarget(false)
end

function CWarOrderCtrl.IsGlobalOrderTarget(self, targetobj)
	if not self.m_IsGlobal then
		return false
	end
	local funcname = "Global"..self.m_GlobalOrderInfo.name.."Condition"
	local f = self[funcname]
	if f then
		return f(self, targetobj)
	else
		return false
	end
end

function CWarOrderCtrl.IsOrderTarget(self, targetobj)
	if self.m_IsGlobal then
		return false
	end
	local funcname = self.m_IsHero and "Hero" or "Summon"
	funcname = funcname..self.m_OrderInfo.name.."Condition"
	local f = self[funcname]
	if f then
		return f(self, targetobj)
	else
		return false
	end
end

function CWarOrderCtrl.SendGlobalOrder(self)
	local funcname = self.m_IsGlobal and "Global" or ""
	funcname = funcname..self.m_GlobalOrderInfo.name.."Send"
	local f = self[funcname]
	if f then
		f(self)
		self.m_OrderDone.global = true
	else
		return
	end
	self:FinishGlobalOrder()
end

function CWarOrderCtrl.SendOrder(self)
	local funcname = self.m_IsHero and "Hero" or "Summon"
	funcname = funcname..self.m_OrderInfo.name.."Send"
	local f = self[funcname]
	if f then
		f(self)
		if self.m_IsHero then
			self.m_OrderDone.hero = true
		else
			self.m_OrderDone.summon = true
		end
	end
	if self.m_OrderDone.hero or self.m_OrderDone.summon then
		if g_WarCtrl.m_SummonWid then
			if self.m_OrderDone.summon then
				self:FinishOrder()
			else
				self.m_IsHero = false
				local oFloatView = CWarFloatView:GetView()
				if oFloatView then
					oFloatView:ShowTipBeforeOrder()
				end
				self:DefaultOrder()
			end
			local oWarView = CWarMainView:GetView()
			if oWarView then
				oWarView:CheckShow()
			end
		else
			self:FinishOrder()
		end
	end
	-- self:ShowSelectTarget(false)
end

function CWarOrderCtrl.SetCurOrderWid(self, wid)
	if self.m_CurOrderWid == wid then
		return
	end
	local oLastWarrior = g_WarCtrl:GetWarrior(self.m_CurOrderWid)
	if oLastWarrior then
		-- oLastWarrior:DelBindObj("warrior_tip") 
	end
	if wid then
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior then
			-- oWarrior:AddBindObj("warrior_tip") 
		end
	end
	self.m_CurOrderWid = wid

	if g_WarCtrl.m_IsFirstSpecityWar then
		local oWarView = CWarMainView:GetView()
		if oWarView then
			oWarView:CheckShow()
		end
	end
end

--ÅÐ¶ÏÄ¿±êº¯Êý
function CWarOrderCtrl.MagicCondition(self, targetobj, wid)
	local iMagicId = self.m_OrderInfo.orderID
	if g_MarrySkillCtrl:IsMarryMagic(iMagicId, targetobj) then
		return g_MarrySkillCtrl:MagicSelCondition(iMagicId, targetobj)
	end		
	local dMagic = DataTools.GetMagicData(iMagicId)
	local bTarget = nil
	if dMagic.target_type == define.Magic.Target.Ally then
		if iMagicId == 1207 or iMagicId == 3008 then
			bTarget = targetobj:IsAlly() and not targetobj:IsHeroOwn()
		else
			bTarget = targetobj:IsAlly()
		end
	elseif dMagic.target_type == define.Magic.Target.Enemy then
		bTarget = not targetobj:IsAlly()
	elseif dMagic.target_type == define.Magic.Target.Self then
		bTarget = targetobj.m_ID == wid
	end
	-- if dMagic.target_status == define.War.Status.Alive then
	-- 	bTarget = targetobj:IsAlive() and bTarget
	-- elseif dMagic.target_status == define.War.Status.Died then
	-- 	bTarget = not targetobj:IsAlive() and bTarget
	-- end
	return bTarget
end

function CWarOrderCtrl.HeroAttackCondition(self, targetobj)
	return not targetobj:IsAlly()
end

function CWarOrderCtrl.HeroMagicCondition(self, targetobj)
	return self:MagicCondition(targetobj, g_WarCtrl.m_HeroWid)
end

function CWarOrderCtrl.HeroProtectCondition(self, targetobj)
	return targetobj:IsAlly() and targetobj.m_Pid ~= g_AttrCtrl.pid
end

function CWarOrderCtrl.HeroWarItemCondition(self, targetobj)
	local oItem = g_ItemCtrl.m_BagItems[self.m_OrderInfo.orderID]
	if 10039 == oItem:GetSValueByKey("sid") then
		return not targetobj:IsAlly()
	end

	if 10174 == oItem:GetSValueByKey("sid") then

		local ally = targetobj:IsAlly()
		local spId = targetobj:GetSpecailId()
		local isNianShou = spId == 1
		return (not ally) and isNianShou

	end

	return targetobj:IsAlly()
end

function CWarOrderCtrl.SummonAttackCondition(self, targetobj)
	return not targetobj:IsAlly()
end

function CWarOrderCtrl.SummonMagicCondition(self, targetobj)
	return self:MagicCondition(targetobj, g_WarCtrl.m_SummonWid)
end

function CWarOrderCtrl.SummonProtectCondition(self, targetobj)
	return targetobj:IsAlly() and targetobj.m_ID ~= g_WarCtrl.m_SummonWid
end

function CWarOrderCtrl.SummonWarItemCondition(self, targetobj)
	local oItem = g_ItemCtrl.m_BagItems[self.m_OrderInfo.orderID]
	if 10039 == oItem:GetSValueByKey("sid") then
		return not targetobj:IsAlly()
	end

	if 10174 == oItem:GetSValueByKey("sid") then

		local ally = targetobj:IsAlly()
		local spId = targetobj:GetSpecailId()
		local isNianShou = spId == 1
		return (not ally) and isNianShou

	end

	return targetobj:IsAlly()
end

----------------------¶ÓÎéÖ¸»ÓÏà¹Ø--------------------------
function CWarOrderCtrl.GlobalTeamAppointCondition(self, targetobj)
	local bTarget = false
	if targetobj:IsPlayer() and targetobj:IsAlly() then
		bTarget = targetobj.m_ID ~= g_WarCtrl.m_HeroWid
	end
	return bTarget
end

function CWarOrderCtrl.GlobalClearTeamCmdCondition(self, targetobj)
	return targetobj:HasTeamCmd()
end

function CWarOrderCtrl.GlobalAddTeamCmdCondition(self, targetobj)
	if self.m_GlobalOrderInfo.orderID == define.Team.WarCmdTarget.Member then
		return targetobj:IsAlly()
	elseif self.m_GlobalOrderInfo.orderID == define.Team.WarCmdTarget.Enemy then
		return not targetobj:IsAlly()
	end
	return false
end
----------------------¶ÓÎéÖ¸»Ó end--------------------------

--·¢°üº¯Êý
function CWarOrderCtrl.HeroAttackSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarNormalAttack(warid, g_WarCtrl.m_HeroWid, self.m_OrderInfo.targetID)
	g_WarCtrl.m_AutoMagic.hero = 101
end

function CWarOrderCtrl.HeroMagicSend(self)
	if g_WarCtrl.m_IsFirstSpecityWar and g_WarCtrl.m_FirstSpecityWarStep == 2 and g_WarCtrl:GetBout() == 1 then
		g_WarCtrl.m_FirstSpecityWarStep = 3
		warsimulate.Bout1()
		return
	end

	local warid = g_WarCtrl:GetWarID()
	local dData = DataTools.GetMagicData(self.m_OrderInfo.orderID)
	if dData.magic_type ~= define.Warrior.MagicType.Se and not g_MarrySkillCtrl:IsMarryMagic(self.m_OrderInfo.orderID) then
		g_WarCtrl.m_QuickMagicIDHero = self.m_OrderInfo.orderID
		g_WarCtrl:OnEvent(define.War.Event.RefreshQuick)
	end
	netwar.C2GSWarSkill(warid, {g_WarCtrl.m_HeroWid}, {self.m_OrderInfo.targetID}, self.m_OrderInfo.orderID)
	g_WarCtrl.m_AutoMagic.hero = self.m_OrderInfo.orderID
end

function CWarOrderCtrl.HeroProtectSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarProtect(warid, g_WarCtrl.m_HeroWid, self.m_OrderInfo.targetID)
end

function CWarOrderCtrl.HeroDefendSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarDefense(warid, g_WarCtrl.m_HeroWid)
	g_WarCtrl.m_AutoMagic.hero = 102
end

function CWarOrderCtrl.HeroEscapeSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarEscape(warid, g_WarCtrl.m_HeroWid)
end

function CWarOrderCtrl.HeroCallSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarSummon(warid, g_WarCtrl.m_HeroWid, self.m_OrderInfo.orderID)
end

function CWarOrderCtrl.HeroWarItemSend(self)

	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarUseItem(warid, g_WarCtrl.m_HeroWid, self.m_OrderInfo.targetID, self.m_OrderInfo.orderID)
	
end


function CWarOrderCtrl.SummonAttackSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarNormalAttack(warid, g_WarCtrl.m_SummonWid, self.m_OrderInfo.targetID)
	g_WarCtrl.m_AutoMagic.summon = 101
end

function CWarOrderCtrl.SummonMagicSend(self)
	local warid = g_WarCtrl:GetWarID()
	local summon = g_WarCtrl:GetSummon()
	if summon and summon.m_SummonID then
		g_WarCtrl.m_QuickMagicIDSummon[summon.m_SummonID] = self.m_OrderInfo.orderID
	end
	g_WarCtrl:OnEvent(define.War.Event.RefreshQuickSummon)
	netwar.C2GSWarSkill(warid, {g_WarCtrl.m_SummonWid}, {self.m_OrderInfo.targetID}, self.m_OrderInfo.orderID)
	g_WarCtrl.m_AutoMagic.summon = self.m_OrderInfo.orderID
end

function CWarOrderCtrl.SummonProtectSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarProtect(warid, g_WarCtrl.m_SummonWid, self.m_OrderInfo.targetID)
end

function CWarOrderCtrl.SummonDefendSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarDefense(warid, g_WarCtrl.m_SummonWid)
	g_WarCtrl.m_AutoMagic.summon = 102
end

function CWarOrderCtrl.SummonEscapeSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarEscape(warid, g_WarCtrl.m_SummonWid)
end

function CWarOrderCtrl.SummonWarItemSend(self)
	local warid = g_WarCtrl:GetWarID()
	netwar.C2GSWarUseItem(warid, g_WarCtrl.m_SummonWid, self.m_OrderInfo.targetID, self.m_OrderInfo.orderID)
end

function CWarOrderCtrl.GlobalTeamAppointSend(self)
	local oWarrior = g_WarCtrl:GetWarrior(self.m_GlobalOrderInfo.targetID)
	netteam.C2GSSetAppointMem(oWarrior.m_Pid, 1)
end

function CWarOrderCtrl.GlobalClearTeamCmdSend(self)
	local oWarrior = g_WarCtrl:GetWarrior(self.m_GlobalOrderInfo.targetID)
	netwar.C2GSWarCommand(g_WarCtrl:GetWarID(), g_WarCtrl.m_HeroWid, oWarrior.m_ID)
end

function CWarOrderCtrl.GlobalAddTeamCmdSend(self)
	local oWarrior = g_WarCtrl:GetWarrior(self.m_GlobalOrderInfo.targetID)
	netwar.C2GSWarCommand(g_WarCtrl:GetWarID(), g_WarCtrl.m_HeroWid, oWarrior.m_ID, self.m_GlobalOrderInfo.extral)
end

return CWarOrderCtrl
local CMiBaoConvoyCtrl = class("CMiBaoConvoyCtrl", CCtrlBase)

function CMiBaoConvoyCtrl.ctor(self)

	CCtrlBase.ctor(self)

	self.m_ActivityState = nil
	self.m_ActivityTime = nil
	self.m_ConvoyTime = nil
	self.m_ConvoyProgress = nil
	self.m_ConvoyCnt = nil
	self.m_BeRobCnt = nil
	self.m_RobCnt = nil

	self.m_MiBaoConfig = data.huodongdata.MIBAOCONFIG[1]

end 

function CMiBaoConvoyCtrl.Clear(self)

	if self.m_Timer then 
		Utils.DelTimer(self.m_Timer)
	end 

	self.m_ActivityState = nil
	self.m_ActivityTime = nil
	self.m_ConvoyTime = nil
	self.m_ConvoyProgress = nil
	self.m_ConvoyCnt = nil
	self.m_BeRobCnt = nil
	self.m_RobCnt = nil

end 

function CMiBaoConvoyCtrl.GS2CTreasureConvoyState(self, state, endTime)
	
	self.m_ActivityState = state
	self.m_ActivityTime = endTime

	self:TryOpenCheckNpcArea()
	self:OnEvent(define.MiBaoConvoy.Event.StateChange)

end

function CMiBaoConvoyCtrl.GS2CTreasureConvoyInfo(self, info)
	
	self.m_ConvoyTime = info.convoy_endtime
	self.m_ConvoyProgress = info.convoy_pregress
	self.m_ConvoyCnt = info.convoy_count
	self.m_BeRobCnt = info.robbed_count
	self.m_RobCnt = info.rob_count
	self:OnEvent(define.MiBaoConvoy.Event.ConvoyInfo)

end

function CMiBaoConvoyCtrl.GS2CTreasureConvoyOpenView(self)

	CMiBaoTaskView:ShowView()	

end

function CMiBaoConvoyCtrl.GS2CTreasureConvoyFlag(self, flag)
	
	self.m_Flag = flag
	if flag == 1 then 
		self:AddConvoyTag()
	elseif flag == 0 then 
		self:DelConvoyTag()
	end 

end

function CMiBaoConvoyCtrl.C2GSTreasureConvoySelectTask(self, mibaoType)
	
	nethuodong.C2GSTreasureConvoySelectTask(mibaoType)

end

function CMiBaoConvoyCtrl.C2GSTreasureConvoyRob(self, pid)
	
	nethuodong.C2GSTreasureConvoyRob(pid)

end

function CMiBaoConvoyCtrl.C2GSTreasureConvoyMatchRob(self)

	nethuodong.C2GSTreasureConvoyMatchRob()

end 

function CMiBaoConvoyCtrl.C2GSTreasureConvoyEnterNpcArea(self, pid)
	
	nethuodong.C2GSTreasureConvoyEnterNpcArea(pid)

end

function CMiBaoConvoyCtrl.C2GSTreasureConvoyExitNpcArea(self, pid)
	
	nethuodong.C2GSTreasureConvoyExitNpcArea(pid)

end

------------------------infterface----------------------
function CMiBaoConvoyCtrl.IsShowConvoyTag(self)
	
	return self.m_Flag == 1

end

function CMiBaoConvoyCtrl.AddConvoyTag(self)

	local hero = g_MapCtrl:GetHero()
	if hero then 
		hero:AddBindObj("convoyTag")
		local defaultSpeed = g_MapCtrl:GetWalkerDefaultSpeed(true)
		local ratio = self:GetSpeedRatio()
		local speed = defaultSpeed * ratio
		hero:SetMoveSpeed(speed)
	end 

end 

function CMiBaoConvoyCtrl.DelConvoyTag(self)

	local hero = g_MapCtrl:GetHero()
	if hero then 
		hero:DelBindObj("convoyTag")
		hero:SetMoveSpeed()
	end 

end 

function CMiBaoConvoyCtrl.TryRob(self, pid)
	
	self:C2GSTreasureConvoyRob(pid)

end

function CMiBaoConvoyCtrl.CheckNpcArea(self)

	local hero = g_MapCtrl:GetHero()
	local checkArea = function ()
		if hero and not Utils.IsNil(hero) then 
			local nearNpc = nil
			local nearNpcPos = nil
			local nearDis = 100
			local heroPos = Vector2.New(hero:GetPos().x, hero:GetPos().y)
			local npcList = self:GetNpcList()
			for k, id in ipairs(npcList) do 
					local oNpc = g_MapCtrl:GetNpcByType(id)
					if oNpc then 
						local npcPos =  Vector2.New(oNpc:GetPos().x, oNpc:GetPos().y)
						local dis = Vector2.Distance(npcPos, heroPos)
						if dis < nearDis then 
							nearDis = dis
							nearNpc = oNpc
							nearNpcPos = npcPos
						end 
					end 
				end 

				if nearNpc then 
					local dis =  Vector2.Distance(nearNpcPos, heroPos)
					if dis > self:GetAreaLimit() then 
						if hero.m_InNpcArea == nil then 
							self:C2GSTreasureConvoyExitNpcArea(hero.m_Pid) 
							hero.m_InNpcArea = false
						else
							if hero.m_InNpcArea then
								self:C2GSTreasureConvoyExitNpcArea(hero.m_Pid) 
								hero.m_InNpcArea = false
							end 	
						end  
					else
						if hero.m_InNpcArea == nil then 
							self:C2GSTreasureConvoyEnterNpcArea(hero.m_Pid)
							hero.m_InNpcArea = true
						else
							if not hero.m_InNpcArea then 
								self:C2GSTreasureConvoyEnterNpcArea(hero.m_Pid)
								hero.m_InNpcArea = true	
							end 
						end  
					end  
				end 
			end
			return true
		end

	if self.m_Timer then 
		Utils.DelTimer(self.m_Timer)
	end 
	self.m_Timer = Utils.AddTimer(checkArea, 1, 1)
	 
end

function CMiBaoConvoyCtrl.GetActivityState(self)
	
	return self.m_ActivityState

end

function CMiBaoConvoyCtrl.IsInProcess(self)

	if self.m_ActivityState and self.m_ActivityState == define.MiBaoConvoy.State.Process then 
		return true
	else
		return false
	end 

end

function CMiBaoConvoyCtrl.IsInPrepare(self)
	
	if self.m_ActivityState and self.m_ActivityState == define.MiBaoConvoy.State.Prepare then 
		return true
	else
		return false
	end 

end

function CMiBaoConvoyCtrl.IsInFinish(self)
	
	if self.m_ActivityState and self.m_ActivityState == define.MiBaoConvoy.State.Finish then 
		return true
	else
		return false
	end 

end

function CMiBaoConvoyCtrl.IsHadConvoyTask(self)
	
	if self.m_ConvoyTime and self.m_ConvoyTime > 0 then 
		return true
	end 
	return false

end

--活动结束时间戳
function CMiBaoConvoyCtrl.GetAvtivityEndTime(self)
	
	return self.m_ActivityTime or 0

end

--护送时间
function CMiBaoConvoyCtrl.GetConvoyTime(self)
	
	return self.m_ConvoyTime or 0

end

--护送进度
function CMiBaoConvoyCtrl.GetConvoyProgress(self)

	return self.m_ConvoyProgress or 0

end

function CMiBaoConvoyCtrl.GetConvoyTotalProgress(self)

	return table.count(self.m_MiBaoConfig.npcs)

end

--护送次数
function CMiBaoConvoyCtrl.GetConvoyCnt(self)
	
	return self.m_ConvoyCnt or 0

end

function CMiBaoConvoyCtrl.GetConvoyTotalCnt(self)
	
	return self.m_MiBaoConfig.convoy_limit

end

--被劫次数
function CMiBaoConvoyCtrl.BeRobCnt(self)
	
	return self.m_BeRobCnt or 0

end

function CMiBaoConvoyCtrl.BeRobTotalCnt(self)
	
	return self.m_MiBaoConfig.robbed_limit

end

--打劫次数
function CMiBaoConvoyCtrl.RobCnt(self)
	
	return self.m_RobCnt or 0
end

function CMiBaoConvoyCtrl.RobTotalCnt(self)
	
	return self.m_MiBaoConfig.rob_limit	

end

function CMiBaoConvoyCtrl.SceneChange(self)

	self:TryOpenActivityInfoView()
	self:TryOpenCheckNpcArea()

end 

function CMiBaoConvoyCtrl.TryOpenActivityInfoView(self)

	local oView = CMiBaoActivityInfoView:GetView() 
	if g_MapCtrl:IsInMiBaoConvoyMap() then 
		if g_WarCtrl:IsWar() then
			if oView then 
				CMiBaoActivityInfoView:CloseView()
			end 
		else
			if not oView then 
				CMiBaoActivityInfoView:ShowView()
			end 
		end 
	else
		if oView then 
			CMiBaoActivityInfoView:CloseView()
		end 
	end 

end

function CMiBaoConvoyCtrl.TryOpenCheckNpcArea(self)

	if g_MapCtrl:IsInMiBaoConvoyMap() then
		if g_WarCtrl:IsWar() then
			if self.m_Timer then 
				Utils.DelTimer(self.m_Timer)
			end 
		else
			if self:IsInProcess() then 
				self:CheckNpcArea()
			else
				if self.m_Timer then 
					Utils.DelTimer(self.m_Timer)
				end 
			end 
		end 
	end 

end 

function CMiBaoConvoyCtrl.CalcuFun(self, str)
	
	local v = string.gsub(str,"lv", g_AttrCtrl.grade)
	local func = loadstring("return " .. v)
	return func()

end

--获取总奖励
function CMiBaoConvoyCtrl.GetTotalReward(self, mibaoType)
	
	local rewardConfig = data.rewarddata.MIBAOREWARD
	local silverIdList = {1001,1002,1003}
	local goldIdList = {2001,2002,2003} 
	local total = 0
	if mibaoType == define.MiBaoConvoy.Type.normal then 
		for k, v in ipairs(silverIdList) do
			local str = rewardConfig[v].silver
			total = total + self:CalcuFun(str)
		end 
	elseif mibaoType == define.MiBaoConvoy.Type.advance then 
		for k, v in ipairs(goldIdList) do
			local str = rewardConfig[v].gold
			total = total + self:CalcuFun(str)
		end 
	end 

	return total

end

--押金
function CMiBaoConvoyCtrl.GetDeposit(self, mibaoType)
	
	local mibaoConfig = data.huodongdata.MIBAOCONFIG[1]
	if mibaoType == define.MiBaoConvoy.Type.normal then 
		return self:CalcuFun(mibaoConfig.normal_cashpledge)
	elseif mibaoType == define.MiBaoConvoy.Type.advance then 
		return self:CalcuFun(mibaoConfig.advance_cashpledge)
	end

end

function CMiBaoConvoyCtrl.IsEnoughDeposit(self, mibaoType)
	
	local deposit = self:GetDeposit(mibaoType)
	if mibaoType == define.MiBaoConvoy.Type.normal then 
		if deposit <= g_AttrCtrl.silver then 
			return true
		else
			return false
		end 
	elseif mibaoType == define.MiBaoConvoy.Type.advance then 
		if deposit <= g_AttrCtrl.gold then 
			return true
		else
			return false
		end 
	end 

end

function CMiBaoConvoyCtrl.GetAreaLimit(self)

	return self.m_MiBaoConfig.area_limit

end

function CMiBaoConvoyCtrl.GetNpcList(self)

	return self.m_MiBaoConfig.npcs

end 

function CMiBaoConvoyCtrl.GetTextTip(self, id)
	
	local info = data.huodongdata.MIBAOTEXT[id]
	if info then 
		return info.content
	end 
	
end

function CMiBaoConvoyCtrl.GetSpeedRatio(self)
	
	local info = data.huodongdata.MIBAOCONFIG[1]
	if info then 
		return info.move_speed / 100
	end 

end

return CMiBaoConvoyCtrl
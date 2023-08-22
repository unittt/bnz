CcrapsCtrl = class("CcrapsCtrl", CCtrlBase)

function CcrapsCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_Time = 0
	self.m_OnLineTimer = nil
	self.m_CrapTime = nil
end

function CcrapsCtrl.GetGoldCoinCost(self, goldcoincnt)
	local cnt = tostring(goldcoincnt)
	local formula = data.huodongdata.SHOOTCRAPS[1].exchange_goldcoin
    local formulatext = string.gsub(formula, "cnt", cnt)
    local costCoin = string.eval(formulatext, {math = math})
    return costCoin
end

--开始摇塞子
function CcrapsCtrl.C2GSShootCrapStart(self)
	nethuodong.C2GSShootCrapStart()
end 

--摇塞子表现效果结束，通知服务器发奖励
function CcrapsCtrl.C2GSShootCrapEnd(self)
	nethuodong.C2GSShootCrapEnd()
end

--打开摇塞子界面
function CcrapsCtrl.GS2CShootCrapOpen(self, info)
	-- if self.m_OnLineTimer then
	-- 	Utils.DelTimer(self.m_OnLineTimer)
	-- end

	CScheduleCrapsView:ShowView(function (oView)
		oView:SetInfo(info)
		oView:InitDiceGrid(info.sixcnt)
	end)
end

-- function CcrapsCtrl.GS2CUpdateShootcrapOnlineTime(self, time)
-- 	-- body
-- 	if self.m_OnLineTimer then
-- 		Utils.DelTimer(self.m_OnLineTimer)
-- 		self.m_OnLineTimer = nil
-- 	end

-- 	if time and time> 0 then
-- 		self.m_Time = time
-- 		local function timer()
-- 			-- body
-- 			self.m_Time = self.m_Time - 1
-- 			if self.m_Time >= 0 then
-- 				self:OnEvent(define.Crap.Event.Timer)
-- 				return true
-- 			else   
-- 				self:OnEvent(define.Crap.Event.TimerEnd) 
-- 				return false
-- 			end
-- 		end
-- 		self.m_OnLineTimer = Utils.AddTimer(timer, 1, 0.02)
-- 	end
-- end

--更新剩余次数
function CcrapsCtrl.GS2CShootCrapUpdate(self, info)
	local view = CScheduleCrapsView:GetView()
	if view then
		if next(info.sixlitemlist) and info.sixcnt == 0 then
			info.sixcnt = 6
		end
		view:SetInfo(info)
	end
end

--开始摇骰子，结束后上行发奖励
function CcrapsCtrl.GS2CShootCrapEnd(self, info)
	local view = CScheduleCrapsView:GetView()
	if view then
		view:StartLottery(info)
	end
end

function CcrapsCtrl.GS2CShootCrapReward(self, exp, silver, item)
	local view = CScheduleCrapsView:GetView()
	if view then
		view:SetReward() -- exp, silver
	end
end

return CcrapsCtrl
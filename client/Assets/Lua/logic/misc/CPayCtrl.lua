local CPayCtrl = class("CPayCtrl", CCtrlBase)

function CPayCtrl.ctor(self)
	-- recordtime
	self.m_PayidDic = {}

	self.m_IsPay = false
	self.m_TimerForPay = nil
	
	-- IOS内购签单字典
	self.m_RestoreResultDic = {}
end

function CPayCtrl.SetLockByPayID(self, payid)
	if self.m_PayidDic[payid] then
		return
	end
	self.m_PayidDic[payid] = true
end

function CPayCtrl.UnLockByPayID(self, payid)
	self.m_PayidDic[payid] = nil
end

function CPayCtrl.IsLockByPayID(self, payid)
	return self.m_PayidDic[payid]
end

function CPayCtrl.IsLockByPay(self)
	return self.m_IsLockByPay
end

function CPayCtrl.LockByPay(self)
	self.m_IsLockByPay = true
end

function CPayCtrl.UnlockByPay(self)
	self.m_IsLockByPay = false
end

function CPayCtrl.Charge(self, payid, callback)
	-- if Utils.IsEditor() then
	-- 	g_NotifyCtrl:FloatMsg("编辑器模式下无法进行充值...")
 --    	return
	-- end
	
 --    if g_LoginPhoneCtrl.m_IsQrPC then
 --    	g_NotifyCtrl:FloatMsg("请到移动端进行充值...")
 --    	return
 --    end

 --    if Utils.IsWin() then
 --    	g_NotifyCtrl:FloatMsg("pc端无法进行充值...")
 --    	return
	-- end	

	if g_SdkCtrl:IsIOSNativePay() then
		if self:IsLockByPayID(payid) then
			g_NotifyCtrl:FloatMsg("该充值购买正在进行中，请稍候...")
			return
		end
		self:SetLockByPayID(payid)
	end

	if g_GameDataCtrl:GetChannel() == "demi" then
		if self:IsLockByPay() then
			g_NotifyCtrl:FloatMsg("正在充值购买进行中，请稍候...")
			return
		end
		self:LockByPay()
		if self.m_TimerForPay then
	       Utils.DelTimer(self.m_TimerForPay)
	       self.m_TimerForPay = nil
    	end
    	local function DelayUnlock()
        	self:UnlockByPay()
    	end
    	self.m_TimerForPay = Utils.AddTimer(DelayUnlock,0,2)
	end

	local iFuseSDK = g_GameDataCtrl:GetChannel() == "demi" and 1 or 0
	netother.C2GSRequestPay(payid, 1, iFuseSDK)
end


return CPayCtrl